local ADDON_NAME = "ImABigDeal"
local IABD = _G[ADDON_NAME]

-- Settings defaults
IABD.settings = {
  dotEnabled = true,
  popupEnabled = true,
  popupDuration = 5,
  popupMode = "manual",    -- "manual" (close button), "timed" (auto-fade), "target" (dismiss on target change)
  toastX = 0,              -- toast anchor position (relative to CENTER of UIParent)
  toastY = -120,
  minTierDot = 1,        -- Minimum tier to show dot (1=Common+)
  minTierPopup = 2,      -- Minimum tier to show popup (2=Uncommon+)
  suppressInCombat = true,
  seenCooldown = 60,      -- Don't re-popup same lore entry for 60 seconds
}

-- Runtime state
IABD.seenNPCs = {}        -- { [npcID] = lastSeenTime }
IABD.currentTargetNPC = nil
IABD.isInitialized = false

-- Extract NPC ID from a GUID
-- Format: "Creature-0-XXXX-XXXX-XXXX-NPCID-INSTANCE"
function IABD:GetNPCIdFromGUID(guid)
  if not guid then return nil end

  local unitType = strsplit("-", guid)
  if unitType ~= "Creature" and unitType ~= "Vehicle" then
    return nil  -- Players, pets, etc. don't have NPC IDs
  end

  local parts = { strsplit("-", guid) }
  local npcID = tonumber(parts[6])
  return npcID
end

-- Look up an NPC in the lore database (by ID, then name, then org pattern)
function IABD:LookupNPC(npcID, name)
  -- Try NPC ID first (exact match)
  if npcID and self.loreDB and self.loreDB[npcID] then
    return self.loreDB[npcID]
  end

  -- Fallback 1: match by name (handles all phased/expansion NPC ID variants)
  if name and self.nameOverrides then
    local entry = self.nameOverrides[string.lower(name)]
    if entry then
      -- Cache this NPC ID for future fast lookups
      if npcID and self.loreDB then
        self.loreDB[npcID] = entry
      end
      return entry
    end
  end

  -- Fallback 2: match by organization/faction pattern in the NPC's name
  if name and self.orgPatterns then
    local nameLower = string.lower(name)
    for _, pattern in ipairs(self.orgPatterns) do
      if nameLower:find(pattern[1], 1, true) then
        return { pattern[2], pattern[3], pattern[4] }
      end
    end
  end

  return nil
end

-- Called when the player targets something
function IABD:OnTargetChanged()
  -- Clear previous
  self.ui:HideDot()
  self.currentTargetNPC = nil

  -- In "target" mode, dismiss popup when target changes
  if self.settings.popupMode == "target" then
    self.ui:HideToast()
  end

  -- Check if we have a target
  if not UnitExists("target") then
    return
  end

  -- Only care about NPCs (not players)
  if UnitIsPlayer("target") then
    return
  end

  -- Get NPC ID from GUID and name
  local guid = UnitGUID("target")
  local npcID = self:GetNPCIdFromGUID(guid)
  local name = UnitName("target")
  if not name then return end

  -- Look up in lore database (by ID first, then by name)
  local entry = self:LookupNPC(npcID, name)
  if not entry then return end

  local tier, title, lore = entry[1], entry[2], entry[3]
  self.currentTargetNPC = npcID

  -- Dot ALWAYS shows on target (no cooldown)
  if self.settings.dotEnabled and tier >= self.settings.minTierDot then
    self.ui:ShowDot(tier)
  end

  -- Popup respects cooldown (keyed by lore title, not NPC ID)
  if self.settings.popupEnabled and tier >= self.settings.minTierPopup then
    -- Suppress in combat if setting is on
    if self.settings.suppressInCombat and InCombatLockdown() then
      return
    end

    -- Cooldown keyed by lore entry title so all "Twilight's Hammer"
    -- mobs share one cooldown, but different orgs/characters are separate
    local cooldownKey = title or name
    local now = GetTime()
    local lastSeen = self.seenNPCs[cooldownKey]
    if lastSeen and (now - lastSeen) < self.settings.seenCooldown then
      return
    end

    self.seenNPCs[cooldownKey] = now
    self.ui:ShowToast(name, tier, title, lore, self.settings.popupDuration)
  end
end

-- Build name index for /iabd lookup
function IABD:BuildNameIndex()
  self.nameIndex = {}
  for npcID, entry in pairs(self.loreDB) do
    -- We don't store names in the DB (they come from UnitName at runtime)
    -- But we can store the title for search
    local title = entry[2]
    if title then
      self.nameIndex[string.lower(title)] = npcID
    end
  end
end

-- Initialize
function IABD:Initialize()
  if self.isInitialized then return end

  -- Load saved settings
  self:LoadSettings()

  -- Create UI elements
  self.ui:CreatePortraitDot()
  self.ui:CreateToast()

  -- Register for target changes
  local ok = pcall(function()
    RegisterEventCallback("PLAYER_TARGET_CHANGED", function()
      IABD:OnTargetChanged()
    end)
  end)

  if not ok then
    -- Fallback: Frame:RegisterEvent
    local frame = CreateFrame("Frame")
    pcall(function()
      frame:RegisterEvent("PLAYER_TARGET_CHANGED")
      frame:SetScript("OnEvent", function()
        IABD:OnTargetChanged()
      end)
    end)
  end

  -- Build search index
  self:BuildNameIndex()

  local count = 0
  for _ in pairs(self.loreDB) do count = count + 1 end
  print("|cffff8000I'm A Big Deal|r v1.0 loaded — " .. count .. " lore entries")

  self.isInitialized = true
end

-- Save/Load settings
function IABD:SaveSettings()
  if not ImABigDealDB then ImABigDealDB = {} end
  ImABigDealDB.settings = {
    dotEnabled = self.settings.dotEnabled,
    popupEnabled = self.settings.popupEnabled,
    popupDuration = self.settings.popupDuration,
    popupMode = self.settings.popupMode,
    toastX = self.settings.toastX,
    toastY = self.settings.toastY,
    minTierDot = self.settings.minTierDot,
    minTierPopup = self.settings.minTierPopup,
    suppressInCombat = self.settings.suppressInCombat,
    seenCooldown = self.settings.seenCooldown,
  }
end

function IABD:LoadSettings()
  if not ImABigDealDB or not ImABigDealDB.settings then return end
  local saved = ImABigDealDB.settings
  for k, v in pairs(saved) do
    if self.settings[k] ~= nil then
      self.settings[k] = v
    end
  end
end

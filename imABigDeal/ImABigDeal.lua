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
  seenCooldown = 15,      -- Don't re-popup same NPC for 15 seconds
  showUnknownNPCs = true,  -- Show basic info for NPCs not in the lore database
  -- Sound
  legendarySoundEnabled = true,
  legendarySoundID = 8455,   -- Fanfare by default
  epicSoundEnabled = false,
  epicSoundID = 12867,       -- Achievement
  -- Discovery
  discoveryEnabled = true,
  discoveryTrackAll = false,  -- Track all NPCs or only database entries
}

-- Runtime state
IABD.seenNPCs = {}        -- { [npcID] = lastSeenTime }
IABD.currentTargetNPC = nil
IABD.currentEntry = nil
IABD.isInitialized = false
IABD.debugMode = false

-- Discovery collection (persisted in SavedVariables)
IABD.discovered = {}       -- { [name] = { tier, title, firstSeen, count } }

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
  -- Org provides the lore text, but tier comes from the NPC's actual classification
  if name and self.orgPatterns then
    local nameLower = string.lower(name)
    for _, pattern in ipairs(self.orgPatterns) do
      if nameLower:find(pattern[1], 1, true) then
        -- Determine tier from the NPC's in-game classification, not the org
        local tier = 2  -- Uncommon default for org members
        if UnitExists("target") then
          local classification = UnitClassification("target") or "normal"
          if classification == "worldboss" then
            tier = 4
          elseif classification == "rareelite" then
            tier = 3
          elseif classification == "rare" then
            tier = 3
          elseif classification == "elite" then
            tier = 2
          end
        end
        return { tier, pattern[3], pattern[4] }
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

  local dbg = self.debugMode
  if dbg then print("|cffff8000IABD Debug:|r OnTargetChanged fired") end

  -- Only care about NPCs (not players)
  if UnitIsPlayer("target") then
    if dbg then print("  -> Skipped: is a player") end
    return
  end

  -- Get NPC ID from GUID and name
  local guid = UnitGUID("target")
  local npcID = self:GetNPCIdFromGUID(guid)
  local name = UnitName("target")
  if not name then
    if dbg then print("  -> Skipped: no name") end
    return
  end

  if dbg then print("  -> Target: " .. name .. " (NPC " .. tostring(npcID) .. ")") end

  -- Look up in lore database (by ID first, then by name, then org pattern)
  local entry = self:LookupNPC(npcID, name)
  if dbg then print("  -> LookupNPC: " .. (entry and "FOUND" or "nil")) end

  -- Fallback: build a basic entry from WoW's own NPC info
  if not entry and self.settings.showUnknownNPCs then
    entry = self:BuildFallbackEntry(name)
    if dbg then print("  -> Fallback: " .. (entry and "FOUND" or "nil")) end
  elseif not entry then
    if dbg then print("  -> showUnknownNPCs is OFF") end
  end

  if not entry then
    if dbg then print("  -> No entry found, aborting") end
    return
  end

  local tier, title, lore = entry[1], entry[2], entry[3]
  self.currentTargetNPC = npcID
  self.currentEntry = entry
  if dbg then print("  -> Tier: " .. tier .. ", Title: " .. tostring(title)) end

  -- Play sound for high-tier targets
  if tier >= 5 and self.settings.legendarySoundEnabled and self.settings.legendarySoundID then
    PlaySound(self.settings.legendarySoundID, "SFX")
  elseif tier >= 4 and self.settings.epicSoundEnabled and self.settings.epicSoundID then
    PlaySound(self.settings.epicSoundID, "SFX")
  end

  -- Discovery tracking
  if self.settings.discoveryEnabled then
    local shouldTrack = (tier >= 2) or self.settings.discoveryTrackAll
    if shouldTrack and name then
      local isNew = not self.discovered[name]
      if isNew then
        self.discovered[name] = {
          tier = tier,
          title = title or "",
          firstSeen = time(),
          count = 1,
        }
        self:SaveDiscovery()
        if dbg then print("  -> Discovery: NEW! (" .. self:GetDiscoveryCount() .. " total)") end
      else
        self.discovered[name].count = (self.discovered[name].count or 0) + 1
      end
    end
  end

  -- Dot ALWAYS shows on target (no cooldown)
  if self.settings.dotEnabled and tier >= self.settings.minTierDot then
    self.ui:ShowDot(tier)
    if dbg then print("  -> Dot: SHOWN") end
  else
    if dbg then print("  -> Dot: filtered (tier " .. tier .. " < min " .. self.settings.minTierDot .. ")") end
  end

  -- Popup respects cooldown
  if self.settings.popupEnabled and tier >= self.settings.minTierPopup then
    -- Suppress in combat if setting is on
    if self.settings.suppressInCombat and InCombatLockdown() then
      if dbg then print("  -> Popup: BLOCKED by combat") end
      return
    end

    local cooldownKey = name
    local now = GetTime()
    local lastSeen = self.seenNPCs[cooldownKey]
    if lastSeen and (now - lastSeen) < self.settings.seenCooldown then
      if dbg then print("  -> Popup: BLOCKED by cooldown (" .. math.floor(now - lastSeen) .. "s ago)") end
      return
    end

    self.seenNPCs[cooldownKey] = now
    local isNewDiscovery = self.settings.discoveryEnabled and self.discovered[name] and self.discovered[name].count == 1
    self.ui:ShowToast(name, tier, title, lore, self.settings.popupDuration, isNewDiscovery)
    if dbg then print("  -> Popup: SHOWN" .. (isNewDiscovery and " (NEW DISCOVERY!)" or "")) end
  else
    if dbg then print("  -> Popup: filtered (enabled=" .. tostring(self.settings.popupEnabled) .. ", tier " .. tier .. " < min " .. self.settings.minTierPopup .. ")") end
  end
end

-- Build a basic lore entry from WoW's in-game NPC info
function IABD:BuildFallbackEntry(name)
  if not UnitExists("target") then return nil end

  -- Only show fallback for named NPCs (not generic mobs like "Wolf")
  -- Check if the NPC has a title/guild text — indicates they're somebody
  local creatureType = UnitCreatureType("target") or ""
  local classification = UnitClassification("target") or "normal"
  local level = UnitLevel("target") or 0
  local reaction = UnitReaction("player", "target") or 4

  -- Scan tooltip for all available info (subtitle, faction, quests, etc.)
  local subtitle = ""
  local tooltipLines = {}
  local tooltipData = C_TooltipInfo and C_TooltipInfo.GetUnit and C_TooltipInfo.GetUnit("target")
  if tooltipData and tooltipData.lines then
    for i, line in ipairs(tooltipData.lines) do
      local text = line.leftText or ""
      if i == 2 and text ~= "" and text ~= name then
        subtitle = text  -- Line 2 is the title/subtitle
      elseif i > 2 and text ~= "" then
        table.insert(tooltipLines, text)
      end
    end
  end

  -- Determine tier based on classification
  local tier = 1  -- Common
  if classification == "worldboss" then
    tier = 4  -- Epic
  elseif classification == "rareelite" then
    tier = 3  -- Rare
  elseif classification == "rare" then
    tier = 3  -- Rare
  elseif classification == "elite" then
    tier = 2  -- Uncommon
  end

  -- All humanoid/relevant NPCs are at least Uncommon
  -- Only critters and beasts with no title stay Common
  local lowValueTypes = { ["Critter"] = true, ["Beast"] = true, ["Non-combat Pet"] = true }
  if tier < 2 and not lowValueTypes[creatureType] then
    tier = 2
  end

  -- Check quest-related status
  local isQuestBoss = UnitIsQuestBoss and UnitIsQuestBoss("target")
  local canInteract = CheckInteractDistance and CheckInteractDistance("target", 1)

  -- Build a description from all available info
  local parts = {}

  -- Subtitle (title/role)
  if subtitle ~= "" and subtitle ~= name then
    table.insert(parts, subtitle .. ".")
  end

  -- Classification
  if classification == "rare" or classification == "rareelite" then
    table.insert(parts, "Rare spawn.")
  elseif classification == "worldboss" then
    table.insert(parts, "World Boss.")
  elseif classification == "elite" then
    table.insert(parts, "Elite.")
  end

  -- Creature type
  if creatureType ~= "" and creatureType ~= "Not specified" then
    table.insert(parts, creatureType .. ".")
  end

  -- Quest involvement
  if isQuestBoss then
    table.insert(parts, "Quest objective.")
  end

  -- Extra tooltip lines (often contain faction, quest info, or flavor text)
  for _, tooltipLine in ipairs(tooltipLines) do
    -- Skip generic lines like level info or faction standing
    local skip = false
    if tooltipLine:match("^Level") then skip = true end
    if tooltipLine:match("^%d+") then skip = true end  -- health/power numbers

    if not skip and #parts < 6 then  -- cap at 6 parts to keep it readable
      table.insert(parts, tooltipLine)
    end
  end

  local blurb = table.concat(parts, " ")
  if blurb == "" then
    return nil
  end

  local title = subtitle ~= "" and subtitle or creatureType
  return { tier, title, blurb }
end

-- ============================================================
-- Discovery System
-- ============================================================

function IABD:GetDiscoveryCount()
  local count = 0
  for _ in pairs(self.discovered) do count = count + 1 end
  return count
end

function IABD:GetDiscoveryByTier()
  local counts = { [1] = 0, [2] = 0, [3] = 0, [4] = 0, [5] = 0 }
  for _, entry in pairs(self.discovered) do
    local t = entry.tier or 1
    counts[t] = (counts[t] or 0) + 1
  end
  return counts
end

function IABD:SaveDiscovery()
  if not ImABigDealDB then ImABigDealDB = {} end
  ImABigDealDB.discovered = self.discovered
end

function IABD:LoadDiscovery()
  if ImABigDealDB and ImABigDealDB.discovered then
    self.discovered = ImABigDealDB.discovered
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

  -- Load saved settings and discovery data
  self:LoadSettings()
  self:LoadDiscovery()

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
  local discovered = self:GetDiscoveryCount()
  print("|cffff8000I'm A Big Deal|r v1.0 loaded — " .. count .. " lore entries, " .. discovered .. " discovered")

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
    showUnknownNPCs = self.settings.showUnknownNPCs,
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

local ADDON_NAME = "CritPopup"
local ADDON_VERSION = "1.0.0"

-- Global addon namespace
_G[ADDON_NAME] = {}
local CP = _G[ADDON_NAME]

-- User settings (per-character)
CP.settings = {
  position = "head",           -- "head" (above target), "center", or "custom"
  customX = 0,
  customY = 0,
  queueMode = "stack",         -- "stack" or "combine"
  durationSeconds = 1.5,
  autoAttacksEnabled = true,
  abilitiesEnabled = true,
  dotsEnabled = true,
  critSoundId = 1,             -- index into sound list (1=LevelUp, 0=off)
  soundMaxDuration = 1.0,      -- auto-cut sound after this many seconds (0=full length)
  -- Animation tuning
  bloomRadius = 80,            -- how far overlapping popups spread
  startHeight = 60,            -- drop start distance above landing point
  nameplateOffset = 30,        -- pixels above nameplate to anchor
  normalFontSize = 48,         -- font size for normal hits
  critFontSize = 72,           -- font size for crits
  animIntensity = 1.0,         -- multiplier for bounce/drift (0.5-2.0)
  normalDigitSpacing = 0,      -- pixels between digits (normal hits)
  critDigitSpacing = 5,        -- pixels between digits (crits)
}

-- Crit sound options (id 0 = off)
-- Sound options (PlaySound numeric IDs only — PlaySoundFile is dead in 12.0)
CP.critSounds = {
  { name = "Off",              soundID = nil },
  { name = "Level Up",         soundID = 888 },
  { name = "Raid Warning",     soundID = 8959 },
  { name = "PvP Warning",      soundID = 8332 },
  { name = "Quest Complete",    soundID = 618 },
  { name = "Loot Coin",        soundID = 120 },
  { name = "Map Ping",         soundID = 3175 },
  { name = "Ready Check",      soundID = 8960 },
  { name = "Bonk",             soundID = 3338 },
  { name = "Humm",             soundID = 6674 },
  { name = "Auction Gavel",    soundID = 5274 },
  { name = "Loot Epic",        soundID = 10989 },
  { name = "Power Up",         soundID = 12199 },
  { name = "Shay's Bell",      soundID = 6595 },
  { name = "Fanfare",          soundID = 8455 },
  { name = "Thunder",          soundID = 12747 },
  { name = "War Drum",         soundID = 8585 },
}

-- Runtime state
CP.popupQueue = {}            -- Active popups
CP.lastCombineTime = 0        -- For combine mode
CP.activeCombinedFrame = nil  -- Current combined frame (if any)
CP.isInitialized = false

-- Initialize addon
function CP:Initialize()
  if self.isInitialized then return end

  -- Verify all modules loaded
  if not self.detection or not self.animations then
    print("|cffff0000Crit Popup Error: Modules not loaded|r")
    return
  end

  -- Load settings from saved variables
  self:LoadSettings()

  -- Initialize detection
  self.detection:Initialize()

  print("|cff00ff00Crit Popup|r v" .. ADDON_VERSION .. " loaded")
  self.isInitialized = true
end

-- Load settings from SavedVariables
function CP:LoadSettings()
  if self.config then
    self.config:LoadSettings()
  end
end

-- Position popup based on user settings
function CP:PositionPopup(frame, unitId)
  unitId = unitId or "target"
  local posMode = self.settings.position

  if posMode == "head" then
    self:PositionAboveHead(frame, unitId)
  elseif posMode == "center" then
    self:PositionCenter(frame)
  elseif posMode == "custom" then
    self:PositionCustom(frame)
  end
end

-- Position popup using GUID (not unit token, which can get recycled)
function CP:PositionPopupByGUID(frame, guid)
  if not guid then
    self:PositionCenter(frame)
    return
  end

  frame:ClearAllPoints()

  -- Find the nameplate matching this GUID
  if C_NamePlate and C_NamePlate.GetNamePlates then
    local nameplates = C_NamePlate.GetNamePlates(false)
    if nameplates then
      for _, nameplate in ipairs(nameplates) do
        if nameplate:IsShown() then
          local npGUID = nil
          if nameplate.UnitFrame and nameplate.UnitFrame.unit then
            npGUID = UnitGUID(nameplate.UnitFrame.unit)
          elseif nameplate.unitToken then
            npGUID = UnitGUID(nameplate.unitToken)
          end

          if npGUID == guid then
            frame:SetPoint("BOTTOM", nameplate, "TOP", 0, self.settings.nameplateOffset)
            return
          end
        end
      end
    end
  end

  -- No nameplate found (dead, despawned, out of range) — center fallback
  self:PositionCenter(frame)
end

-- Position above enemy's nameplate/head (legacy, used by PositionPopup)
function CP:PositionAboveHead(frame, unitId)
  unitId = unitId or "target"

  frame:ClearAllPoints()

  -- If unit is dead or invalid, go straight to center fallback
  if not UnitExists(unitId) or UnitIsDead(unitId) then
    frame:SetPoint("CENTER", UIParent, "CENTER", 0, 100)
    return
  end

  -- Get the target's GUID to match against nameplates
  local targetGUID = UnitGUID(unitId)

  -- Try to find and anchor to target's nameplate
  if targetGUID and C_NamePlate and C_NamePlate.GetNamePlates then
    local nameplates = C_NamePlate.GetNamePlates(false)
    if nameplates and #nameplates > 0 then
      for _, nameplate in ipairs(nameplates) do
        if nameplate:IsShown() then
          local nameplateGUID = nil
          if nameplate.UnitFrame and nameplate.UnitFrame.unit then
            nameplateGUID = UnitGUID(nameplate.UnitFrame.unit)
          end

          if nameplateGUID == targetGUID then
            frame:SetPoint("BOTTOM", nameplate, "TOP", 0, self.settings.nameplateOffset)
            return
          end
        end
      end
    end
  end

  -- Fallback: center of screen
  frame:SetPoint("CENTER", UIParent, "CENTER", 0, 100)
end

-- Position at center of screen
function CP:PositionCenter(frame)
  frame:ClearAllPoints()
  frame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
end

-- Position at custom anchor point
function CP:PositionCustom(frame)
  local x = self.settings.customX or 0
  local y = self.settings.customY or 0
  frame:ClearAllPoints()
  frame:SetPoint("CENTER", UIParent, "CENTER", x, y)
end

-- Find a unit frame for the target
function CP:FindUnitFrame(unitId)
  unitId = unitId or "target"

  -- Try the target frame first
  if TargetFrame and TargetFrame:IsShown() then
    return TargetFrame
  end

  -- Fallback: return nil (use center positioning)
  return nil
end

-- Handler called when damage is detected (crits and normal damage)
function CP:OnDamageDetected(damageAmount, abilityType, indicator, unitTarget, source)
  -- Check if this ability type is enabled
  if abilityType == "auto" and not self.settings.autoAttacksEnabled then
    return
  end
  if abilityType == "ability" and not self.settings.abilitiesEnabled then
    return
  end
  if abilityType == "dot" and not self.settings.dotsEnabled then
    return
  end

  -- Guard against modules not loaded
  if not self.animations then return end

  -- Play sound for crits (with auto-cutoff)
  if indicator == "CRITICAL" then
    local soundIdx = self.settings.critSoundId or 1
    local soundEntry = self.critSounds[soundIdx + 1]  -- 0-indexed setting, 1-indexed table
    if soundEntry and soundEntry.soundID then
      local success, handle = PlaySound(soundEntry.soundID, "SFX")
      if success and handle then
        local maxDur = self.settings.soundMaxDuration or 1.0
        if maxDur > 0 then
          C_Timer.After(maxDur, function()
            StopSound(handle, 0)
          end)
        end
      end
    end
  end

  -- Capture GUID NOW before the unit token gets recycled
  local targetGUID = UnitGUID(unitTarget or "target")

  -- Create popup
  local frame = self.animations:CreatePopupFrame(damageAmount, unitTarget or "target")
  frame.targetGUID = targetGUID  -- store for nameplate matching

  -- Color and size based on damage type
  if indicator == "CRITICAL" then
    frame.textColor = {1, 0.82, 0, 1}  -- Yellow for crits
    frame.isCrit = true
  else
    frame.textColor = {1, 1, 1, 1}     -- White for normal damage
    frame.isCrit = false
  end

  -- Position based on settings — pass GUID for reliable nameplate matching
  self:PositionPopupByGUID(frame, targetGUID)

  frame:Show()

  -- Queue the popup
  self:QueuePopup(frame, damageAmount)

  -- Play animation
  self.animations:PlaySequence(frame, self.settings.durationSeconds)
end

-- Enhanced queue management
function CP:QueuePopup(frame, damageAmount)
  if self.settings.queueMode == "combine" then
    self:QueueCombineMode(frame, damageAmount)
  else
    self:QueueStackMode(frame, damageAmount)
  end
end

-- Stack mode: each popup is independent
function CP:QueueStackMode(frame, damageAmount)
  table.insert(self.popupQueue, {
    frame = frame,
    damage = damageAmount,
    queuedAt = GetTime(),
  })
end

-- Combine mode: consecutive crits within 0.3s merge
function CP:QueueCombineMode(frame, damageAmount)
  local now = GetTime()

  -- If last crit was within 0.3s and we have an active combined frame, update it
  if now - self.lastCombineTime < 0.3 and self.activeCombinedFrame then
    local oldDamage = tonumber(self.activeCombinedFrame.text:GetText())
    local newTotal = oldDamage + damageAmount
    self.activeCombinedFrame.text:SetText(newTotal)

    -- Restart animation on the combined frame
    self.animations:PlaySequence(self.activeCombinedFrame, self.settings.durationSeconds)

    -- Clean up the new frame
    frame:Hide()
    return
  end

  -- Otherwise, create a new combined popup
  self.activeCombinedFrame = frame
  self.lastCombineTime = now

  table.insert(self.popupQueue, {
    frame = frame,
    damage = damageAmount,
    queuedAt = now,
    isCombined = true,
  })
end

-- Cleanup: remove finished popups from queue
function CP:CleanupQueue()
  for i = #self.popupQueue, 1, -1 do
    local popup = self.popupQueue[i]
    if not popup.frame:IsShown() then
      table.remove(self.popupQueue, i)
    end
  end
end

-- Monitor queue cleanup every 1s
local queueCleanupFrame = CreateFrame("Frame")
queueCleanupFrame:SetScript("OnUpdate", function(self, elapsed)
  CP:CleanupQueue()
end)

-- Test animation (for development)
function CP:TestAnimation()
  if not self.animations then return end
  local frame = self.animations:CreatePopupFrame(1234, "test")
  frame.textColor = {1, 0, 0, 1}  -- Red (crit color)
  frame.scale = 1.2
  -- Position at center for test (no actual target)
  self:PositionCenter(frame)
  frame:Show()
  self.animations:PlaySequence(frame, 1.5)
end


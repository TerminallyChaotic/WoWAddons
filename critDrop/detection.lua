local ADDON_NAME = "CritPopup"
local CP = _G[ADDON_NAME]

CP.detection = {}
local Det = CP.detection

-- Cache player GUID
Det.playerGUID = nil
Det.initialized = false
Det.lastHitKey = nil
Det.lastHitTime = 0

-- DoT detection: track repeated identical hits on the same target
-- If same (guid, amount) appears 2+ times within 4s, it's a DoT tick
Det.recentHits = {}  -- { [guid..amount] = { count, firstSeen } }
Det.dotCleanupTimer = 0

-- Initialize detection system using 12.0 APIs
function Det:Initialize()
  self.playerGUID = UnitGUID("player")

  if self.initialized then return end

  -- 12.0: UNIT_COMBAT is the primary event for detecting crits
  -- Payload: unitTarget, action, indicator, amount, schoolMask
  -- indicator == "CRITICAL" means it was a crit
  local frame = CreateFrame("Frame")
  local ok = pcall(function()
    frame:RegisterEvent("UNIT_COMBAT")
    frame:SetScript("OnEvent", function(self, event, unitTarget, action, indicator, amount)
      if amount and amount > 0 then
        -- Skip player taking damage and friendly units
        if unitTarget == "player" then
          return
        end
        if UnitIsFriend("player", unitTarget) then
          return
        end

        -- Only show damage the PLAYER dealt:
        -- Check if this unit is the player's target, or a unit the player
        -- has threat on (covers DoTs, AoE on non-targeted mobs)
        local isPlayerTarget = UnitIsUnit(unitTarget, "target")
        local hasThreat = UnitThreatSituation("player", unitTarget)
        if not isPlayerTarget and not hasThreat then
          return
        end

        -- Deduplicate: same target GUID + amount within 0.05s is the same hit
        -- (UNIT_COMBAT fires for each unit token: "target", "nameplate3", etc.)
        local guid = UnitGUID(unitTarget) or unitTarget
        local hitKey = guid .. ":" .. amount
        local now = GetTime()
        if hitKey == Det.lastHitKey and (now - Det.lastHitTime) < 0.05 then
          return
        end
        Det.lastHitKey = hitKey
        Det.lastHitTime = now

        Det:OnDamageDetected(amount, action, indicator, unitTarget)
      end
    end)
  end)

  if ok then
    print("|cff00ff00Crit Popup:|r Detection active (UNIT_COMBAT)")
    self.detectionFrame = frame
  else
    print("|cffff0000Crit Popup:|r Could not register UNIT_COMBAT")
  end

  -- Optional: also try C_CombatLog for more granular data outside restricted content
  if C_CombatLog and C_CombatLog.RegisterCallback then
    local ok2 = pcall(function()
      C_CombatLog.RegisterCallback("SPELL_DAMAGE", function(...)
        Det:OnSpellDamageCallback(...)
      end)
    end)
    if ok2 then
      print("|cff00ff00Crit Popup:|r C_CombatLog registered for backup")
    end
  end

  self.initialized = true
end

-- Handle damage from UNIT_COMBAT (both crits and normal)
function Det:OnDamageDetected(amount, action, indicator, unitTarget)
  -- Determine ability type based on action
  local abilityType = "ability"
  if action == "swing" or action == "SWING" then
    abilityType = "auto"
  end

  -- DoT detection: track repeated identical damage on same target
  -- Same (target, amount) hitting 2+ times within 4s = DoT tick
  if abilityType == "ability" then
    local guid = UnitGUID(unitTarget) or unitTarget
    local dotKey = guid .. ":" .. amount
    local now = GetTime()

    if not self.recentHits[dotKey] then
      self.recentHits[dotKey] = { count = 1, firstSeen = now }
    else
      local entry = self.recentHits[dotKey]
      if (now - entry.firstSeen) < 4 then
        entry.count = entry.count + 1
        if entry.count >= 2 then
          abilityType = "dot"
        end
      else
        -- Reset if too old
        entry.count = 1
        entry.firstSeen = now
      end
    end

    -- Periodic cleanup of stale entries
    if now - self.dotCleanupTimer > 10 then
      self.dotCleanupTimer = now
      for k, v in pairs(self.recentHits) do
        if (now - v.firstSeen) > 6 then
          self.recentHits[k] = nil
        end
      end
    end
  end

  -- Pass to main addon
  CP:OnDamageDetected(amount, abilityType, indicator, unitTarget, "UNIT_COMBAT")
end

-- Handle crit from C_CombatLog (more precise, but restricted zones don't work)
function Det:OnSpellDamageCallback(...)
  local sourceGUID, sourceName, sourceFlags, destGUID, destName, destFlags,
        spellID, spellName, spellSchool, amount, powerType, extraAmount, schoolMask,
        resisted, blocked, absorbed, critical, glancing, crushing, isOffHand = ...

  if not self.playerGUID then
    self.playerGUID = UnitGUID("player")
  end

  if sourceGUID == self.playerGUID and amount and amount > 0 then
    local indicator = critical and "CRITICAL" or "NONE"
    CP:OnDamageDetected(amount, "ability", indicator, "C_CombatLog")
  end
end

CP.detection = Det

local ADDON_NAME = "CritPopup"
local CP = _G[ADDON_NAME]

CP.animations = {}
local Anim = CP.animations

-- Easing: accelerate (gravity feel)
local function EaseIn(t)
  return t * t
end

-- Easing: decelerate (bounce up)
local function EaseOut(t)
  return 1 - (1 - t) * (1 - t)
end

-- Easing: smooth in-out
local function EaseInOut(t)
  if t < 0.5 then return 2 * t * t end
  return 1 - ((-2 * t + 2) ^ 2) / 2
end

-- Bloom: track active popup positions to avoid overlap
local activeBloomSpots = {}  -- {x, y} entries for currently visible popups

-- Find the minimum distance from a point to all active spots
local function MinDistToActive(x, y)
  local minDist = math.huge
  for _, spot in ipairs(activeBloomSpots) do
    local dx = x - spot.x
    local dy = y - spot.y
    local dist = math.sqrt(dx * dx + dy * dy)
    if dist < minDist then
      minDist = dist
    end
  end
  return minDist
end

-- Generate a bloom offset that avoids existing popups
local function GetBloomOffset()
  -- First popup (or no active popups): dead center
  if #activeBloomSpots == 0 then
    local id = #activeBloomSpots + 1
    table.insert(activeBloomSpots, { x = 0, y = 0, id = id })
    return 0, 0, id
  end

  local radius = CP.settings.bloomRadius or 80

  -- "Best of N candidates" — try 12 random positions, pick the one
  -- farthest from all existing popups
  local bestX, bestY, bestDist = 0, 0, -1

  for attempt = 1, 12 do
    local angle = math.random() * 6.2832  -- random angle 0-2π
    local r = radius * (0.5 + math.random() * 0.5)  -- 50-100% of radius
    local cx = math.cos(angle) * r
    local cy = math.sin(angle) * r * 0.5  -- squish vertically

    local dist = MinDistToActive(cx, cy)
    if dist > bestDist then
      bestX, bestY, bestDist = cx, cy, dist
    end
  end

  local id = #activeBloomSpots + 1
  table.insert(activeBloomSpots, { x = bestX, y = bestY, id = id })
  return bestX, bestY, id
end

-- Remove a bloom spot when its popup finishes
local function ReleaseBloomSpot(id)
  for i = #activeBloomSpots, 1, -1 do
    if activeBloomSpots[i].id == id then
      table.remove(activeBloomSpots, i)
      return
    end
  end
end

-- Shuffle indices (Fisher-Yates)
local function ShuffleOrder(count)
  local order = {}
  for i = 1, count do order[i] = i end
  for i = count, 2, -1 do
    local j = math.random(1, i)
    order[i], order[j] = order[j], order[i]
  end
  return order
end

-- Create a popup frame with individual digit frames
function Anim:CreatePopupFrame(damageAmount, targetName)
  local damageStr = tostring(damageAmount)

  local digitWidth = 40
  local spacing = 5  -- default, recalculated in PlaySequence based on crit
  local totalWidth = (#damageStr * digitWidth) + ((#damageStr - 1) * spacing)

  local parentFrame = CreateFrame("Frame", nil, UIParent)
  parentFrame:SetSize(totalWidth, 120)
  parentFrame:SetPoint("CENTER", UIParent, "CENTER", 0, 100)
  parentFrame:SetFrameStrata("TOOLTIP")

  parentFrame.damageAmount = damageAmount
  parentFrame.targetName = targetName
  parentFrame.isAnimating = false
  parentFrame.digitFrames = {}

  for i = 1, #damageStr do
    local digit = damageStr:sub(i, i)

    local digitFrame = CreateFrame("Frame", nil, parentFrame)
    digitFrame:SetSize(digitWidth, 100)
    local xOffset = (i - 1) * (digitWidth + spacing)
    digitFrame:SetPoint("LEFT", parentFrame, "LEFT", xOffset, 0)

    local text = digitFrame:CreateFontString(nil, "OVERLAY")
    text:SetPoint("CENTER", digitFrame, "CENTER", 0, 0)
    text:SetFont("Fonts\\FRIZQT__.TTF", 48, "OUTLINE, THICKOUTLINE")
    text:SetText(digit)
    text:SetTextColor(1, 1, 1, 1)

    digitFrame.text = text
    digitFrame.digit = digit
    digitFrame.isAnimating = false
    digitFrame.xOffset = xOffset
    digitFrame:SetAlpha(0)  -- hidden until OnUpdate reveals it

    table.insert(parentFrame.digitFrames, digitFrame)
  end

  return parentFrame
end

--[[
  OnUpdate-driven animation for each digit.
  Timeline (all times relative to digit's stagger start):
    0.00 - 0.18s : Drop from 60px above to 0 (gravity easing)
    0.18 - 0.28s : Bounce up 18px
    0.28 - 0.38s : Bounce down to 0
    0.38 - 0.44s : Micro bounce up 6px
    0.44 - 0.50s : Micro bounce down to 0
    0.50 - (0.50 + hold)s : Hold at rest
    (0.50 + hold) - (1.0 + hold)s : Fade out + drift up 40px
]]
function Anim:StartDigitAnimation(digitFrame, staggerDelay, holdDuration, bloomX, bloomY, isCrit)
  local startTime = GetTime()
  bloomX = bloomX or 0
  bloomY = bloomY or 0

  -- Read tuning from settings
  local intensity = CP.settings.animIntensity or 1.0
  local baseHeight = CP.settings.startHeight or 60
  local critMult = isCrit and 1.5 or 1.0

  local dropHeight = baseHeight * critMult
  local bounceHeight = 18 * intensity * critMult
  local microHeight = 6 * intensity * critMult
  local driftHeight = 40 * intensity * critMult

  -- Phase timings
  local dropEnd = 0.18
  local bounce1End = dropEnd + 0.10
  local bounce2End = bounce1End + 0.10
  local micro1End = bounce2End + 0.06
  local micro2End = micro1End + 0.06
  local holdEnd = micro2End + holdDuration
  local fadeEnd = holdEnd + 0.5

  -- Start hidden
  digitFrame:SetAlpha(0)

  digitFrame:SetScript("OnUpdate", function(self, elapsed)
    local now = GetTime()
    local t = now - startTime

    -- Before stagger: stay hidden
    if t < staggerDelay then return end

    -- Time relative to this digit's start
    local dt = t - staggerDelay
    local yOffset, alpha

    if dt < dropEnd then
      -- DROP: 60 → 0 with gravity easing
      local progress = EaseIn(dt / dropEnd)
      yOffset = dropHeight * (1 - progress)
      alpha = 1

    elseif dt < bounce1End then
      -- BOUNCE UP: 0 → 18
      local progress = EaseOut((dt - dropEnd) / 0.10)
      yOffset = bounceHeight * progress
      alpha = 1

    elseif dt < bounce2End then
      -- BOUNCE DOWN: 18 → 0
      local progress = EaseIn((dt - bounce1End) / 0.10)
      yOffset = bounceHeight * (1 - progress)
      alpha = 1

    elseif dt < micro1End then
      -- MICRO BOUNCE UP: 0 → 6
      local progress = EaseOut((dt - bounce2End) / 0.06)
      yOffset = microHeight * progress
      alpha = 1

    elseif dt < micro2End then
      -- MICRO BOUNCE DOWN: 6 → 0
      local progress = EaseIn((dt - micro1End) / 0.06)
      yOffset = microHeight * (1 - progress)
      alpha = 1

    elseif dt < holdEnd then
      -- HOLD at rest
      yOffset = 0
      alpha = 1

    elseif dt < fadeEnd then
      -- FADE OUT + drift up
      local progress = EaseInOut((dt - holdEnd) / 0.5)
      yOffset = driftHeight * progress
      alpha = 1 - progress

    else
      -- Done
      self:SetScript("OnUpdate", nil)
      self:Hide()
      self.isAnimating = false
      return
    end

    -- Apply position (with bloom offset) and alpha
    self:ClearAllPoints()
    self:SetPoint("LEFT", self:GetParent(), "LEFT", self.xOffset + bloomX, yOffset + bloomY)
    self:SetAlpha(alpha)
  end)
end

-- Play sequence: digits drop in random order with bloom offset
function Anim:PlaySequence(parentFrame, durationSeconds)
  durationSeconds = durationSeconds or CP.settings.durationSeconds or 1.5

  if parentFrame.isAnimating then return end
  parentFrame.isAnimating = true

  local staggerInterval = 0.1
  local digitCount = #parentFrame.digitFrames

  -- Bloom: offset the entire popup so overlapping hits scatter
  local bloomX, bloomY, bloomId = GetBloomOffset()
  parentFrame.bloomOffsetX = bloomX
  parentFrame.bloomOffsetY = bloomY
  parentFrame.bloomId = bloomId

  -- Apply color, sizing, and spacing from settings
  local color = parentFrame.textColor or {1, 1, 1, 1}
  local isCrit = parentFrame.isCrit
  local fontSize = isCrit and (CP.settings.critFontSize or 72) or (CP.settings.normalFontSize or 48)
  local spacing = isCrit and (CP.settings.critDigitSpacing or 5) or (CP.settings.normalDigitSpacing or 0)
  local digitWidth = 40

  -- Reposition digits with correct spacing for crit vs normal
  local totalWidth = (digitCount * digitWidth) + ((digitCount - 1) * spacing)
  parentFrame:SetWidth(totalWidth)
  for i, digitFrame in ipairs(parentFrame.digitFrames) do
    local xOffset = (i - 1) * (digitWidth + spacing)
    digitFrame.xOffset = xOffset
    digitFrame:ClearAllPoints()
    digitFrame:SetPoint("LEFT", parentFrame, "LEFT", xOffset, 0)
    digitFrame.text:SetFont("Fonts\\FRIZQT__.TTF", fontSize, "OUTLINE, THICKOUTLINE")
    digitFrame.text:SetTextColor(color[1], color[2], color[3], color[4])
  end

  -- Randomize drop order
  local dropOrder = ShuffleOrder(digitCount)

  -- Start OnUpdate animation for each digit
  local isCrit = parentFrame.isCrit
  for i, digitFrame in ipairs(parentFrame.digitFrames) do
    local staggerSlot = dropOrder[i] - 1
    self:StartDigitAnimation(digitFrame, staggerSlot * staggerInterval, durationSeconds, bloomX, bloomY, isCrit)
    digitFrame.isAnimating = true
  end

  -- Safety cleanup + release bloom spot
  local totalDuration = (digitCount * staggerInterval) + 0.50 + durationSeconds + 0.5 + 0.5
  C_Timer.After(totalDuration, function()
    if parentFrame then
      if parentFrame.bloomId then
        ReleaseBloomSpot(parentFrame.bloomId)
      end
      parentFrame:Hide()
      parentFrame.isAnimating = false
    end
  end)
end

function Anim:DestroyPopup(frame)
  if frame then
    frame:Hide()
  end
end

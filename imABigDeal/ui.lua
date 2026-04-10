local ADDON_NAME = "ImABigDeal"
local IABD = _G[ADDON_NAME]

IABD.ui = {}
local UI = IABD.ui

-- ============================================================
-- Portrait Rarity Dot
-- ============================================================

function UI:CreatePortraitDot()
  if self.dot then return end

  local dot = CreateFrame("Frame", "ImABigDealDot", UIParent)
  dot:SetSize(16, 16)
  dot:SetFrameStrata("HIGH")
  dot:SetPoint("TOPRIGHT", TargetFrame or UIParent, "TOPRIGHT", -4, -4)

  local tex = dot:CreateTexture(nil, "OVERLAY")
  tex:SetAllPoints()
  tex:SetTexture("Interface\\MINIMAP\\UI-Minimap-Background")
  dot.texture = tex

  -- Glow ring around the dot
  local glow = dot:CreateTexture(nil, "BACKGROUND")
  glow:SetPoint("CENTER")
  glow:SetSize(24, 24)
  glow:SetTexture("Interface\\MINIMAP\\UI-Minimap-Background")
  glow:SetAlpha(0.3)
  dot.glow = glow

  dot:Hide()
  self.dot = dot
end

-- Find the target frame (12.0 may use different names)
function UI:FindTargetFrame()
  -- Try common target frame names across WoW versions
  local candidates = {
    TargetFrame,
    _G["TargetFrame"],
    _G["TargetUnitFrame"],
    _G["CompactUnitFrame_Target"],
  }
  for _, frame in ipairs(candidates) do
    if frame and frame.IsShown and frame:IsShown() then
      return frame
    end
  end
  -- Last resort: try to find any frame with "target" in its name
  for _, frame in ipairs(candidates) do
    if frame then return frame end
  end
  return nil
end

function UI:ShowDot(tier)
  if not self.dot then self:CreatePortraitDot() end

  local color = IABD.tierColors[tier]
  if not color then
    self.dot:Hide()
    return
  end

  -- Find and anchor to the target portrait frame
  local targetFrame = self:FindTargetFrame()
  self.dot:ClearAllPoints()
  if targetFrame then
    self.dot:SetPoint("TOPRIGHT", targetFrame, "TOPRIGHT", -4, -4)
    self.dot:SetFrameLevel(targetFrame:GetFrameLevel() + 5)
  else
    -- Fallback: top-left area of screen where target frame usually is
    self.dot:SetPoint("TOPLEFT", UIParent, "TOPLEFT", 280, -20)
  end

  self.dot.texture:SetVertexColor(color[1], color[2], color[3], 1)
  self.dot.glow:SetVertexColor(color[1], color[2], color[3], 0.3)
  self.dot:Show()
end

function UI:HideDot()
  if self.dot then
    self.dot:Hide()
  end
end

-- ============================================================
-- Toast Popup
-- ============================================================

function UI:CreateToast()
  if self.toast then return end

  local toast = CreateFrame("Frame", "ImABigDealToast", UIParent)
  toast:SetSize(380, 100)
  local x = IABD.settings.toastX or 0
  local y = IABD.settings.toastY or -120
  toast:SetPoint("CENTER", UIParent, "CENTER", x, y)
  toast:SetFrameStrata("DIALOG")

  -- Dark backdrop
  local bg = toast:CreateTexture(nil, "BACKGROUND")
  bg:SetAllPoints()
  bg:SetColorTexture(0.05, 0.05, 0.08, 0.92)

  -- Top color bar (shows tier color)
  local bar = toast:CreateTexture(nil, "ARTWORK")
  bar:SetPoint("TOPLEFT", toast, "TOPLEFT", 0, 0)
  bar:SetPoint("TOPRIGHT", toast, "TOPRIGHT", 0, 0)
  bar:SetHeight(3)
  toast.colorBar = bar

  -- Tier label (e.g., "LEGENDARY")
  local tierLabel = toast:CreateFontString(nil, "OVERLAY")
  tierLabel:SetPoint("TOPLEFT", toast, "TOPLEFT", 14, -10)
  tierLabel:SetFont("Fonts\\FRIZQT__.TTF", 10, "OUTLINE")
  toast.tierLabel = tierLabel

  -- NPC name
  local nameText = toast:CreateFontString(nil, "OVERLAY")
  nameText:SetPoint("TOPLEFT", toast, "TOPLEFT", 14, -24)
  nameText:SetFont("Fonts\\FRIZQT__.TTF", 16, "OUTLINE, THICKOUTLINE")
  toast.nameText = nameText

  -- Title
  local titleText = toast:CreateFontString(nil, "OVERLAY")
  titleText:SetPoint("TOPLEFT", toast, "TOPLEFT", 14, -44)
  titleText:SetFont("Fonts\\FRIZQT__.TTF", 11, "OUTLINE")
  titleText:SetTextColor(0.7, 0.7, 0.7)
  toast.titleText = titleText

  -- Lore blurb
  local loreText = toast:CreateFontString(nil, "OVERLAY")
  loreText:SetPoint("TOPLEFT", toast, "TOPLEFT", 14, -60)
  loreText:SetPoint("RIGHT", toast, "RIGHT", -14, 0)
  loreText:SetFont("Fonts\\FRIZQT__.TTF", 10, "OUTLINE")
  loreText:SetTextColor(0.85, 0.85, 0.85)
  loreText:SetJustifyH("LEFT")
  loreText:SetWordWrap(true)
  toast.loreText = loreText

  -- Close button (always visible, primary dismiss method in manual mode)
  local closeBtn = CreateFrame("Button", nil, toast)
  closeBtn:SetPoint("TOPRIGHT", toast, "TOPRIGHT", -6, -6)
  closeBtn:SetSize(18, 18)
  local closeTxt = closeBtn:CreateFontString(nil, "OVERLAY")
  closeTxt:SetPoint("CENTER")
  closeTxt:SetFont("Fonts\\FRIZQT__.TTF", 14, "OUTLINE")
  closeTxt:SetText("X")
  closeTxt:SetTextColor(0.6, 0.6, 0.6)
  closeBtn:SetScript("OnClick", function() UI:HideToast() end)
  closeBtn:SetScript("OnEnter", function() closeTxt:SetTextColor(1, 0.3, 0.3) end)
  closeBtn:SetScript("OnLeave", function() closeTxt:SetTextColor(0.6, 0.6, 0.6) end)
  toast.closeBtn = closeBtn

  -- Side border lines
  local borderLeft = toast:CreateTexture(nil, "BORDER")
  borderLeft:SetPoint("TOPLEFT", -1, 1)
  borderLeft:SetPoint("BOTTOMLEFT", -1, -1)
  borderLeft:SetWidth(1)
  borderLeft:SetColorTexture(0.3, 0.3, 0.3, 0.6)

  local borderRight = toast:CreateTexture(nil, "BORDER")
  borderRight:SetPoint("TOPRIGHT", 1, 1)
  borderRight:SetPoint("BOTTOMRIGHT", 1, -1)
  borderRight:SetWidth(1)
  borderRight:SetColorTexture(0.3, 0.3, 0.3, 0.6)

  local borderBot = toast:CreateTexture(nil, "BORDER")
  borderBot:SetPoint("BOTTOMLEFT", -1, -1)
  borderBot:SetPoint("BOTTOMRIGHT", 1, -1)
  borderBot:SetHeight(1)
  borderBot:SetColorTexture(0.3, 0.3, 0.3, 0.6)

  -- Timed fade via OnUpdate (only active in "timed" mode)
  toast.fadeStart = 0
  toast.fadeDelay = 5
  toast.isFading = false
  toast:SetScript("OnUpdate", function(self, elapsed)
    if not self.isFading then return end
    local now = GetTime()
    local dt = now - self.fadeStart
    if dt < self.fadeDelay then return end

    local fadeProgress = (dt - self.fadeDelay) / 1.0
    if fadeProgress >= 1 then
      self:Hide()
      self.isFading = false
      self:SetAlpha(1)
      return
    end
    self:SetAlpha(1 - fadeProgress)
  end)

  toast:Hide()
  self.toast = toast
end

-- Apply saved position to toast
function UI:UpdateToastPosition()
  if not self.toast then return end
  local x = IABD.settings.toastX or 0
  local y = IABD.settings.toastY or -120
  self.toast:ClearAllPoints()
  self.toast:SetPoint("CENTER", UIParent, "CENTER", x, y)
end

-- ============================================================
-- Draggable Anchor (shown when settings panel is open)
-- ============================================================

function UI:CreateAnchor()
  if self.anchor then return end

  local anchor = CreateFrame("Frame", "ImABigDealAnchor", UIParent)
  anchor:SetSize(200, 30)
  local x = IABD.settings.toastX or 0
  local y = IABD.settings.toastY or -120
  anchor:SetPoint("CENTER", UIParent, "CENTER", x, y)
  anchor:SetFrameStrata("TOOLTIP")
  anchor:EnableMouse(true)
  anchor:SetMovable(true)
  anchor:RegisterForDrag("LeftButton")
  anchor:SetClampedToScreen(true)

  -- Background
  local bg = anchor:CreateTexture(nil, "BACKGROUND")
  bg:SetAllPoints()
  bg:SetColorTexture(1, 0.5, 0, 0.4)

  -- Border
  local borderT = anchor:CreateTexture(nil, "BORDER")
  borderT:SetPoint("TOPLEFT", -1, 1)
  borderT:SetPoint("TOPRIGHT", 1, 1)
  borderT:SetHeight(2)
  borderT:SetColorTexture(1, 0.5, 0, 0.8)

  local borderB = anchor:CreateTexture(nil, "BORDER")
  borderB:SetPoint("BOTTOMLEFT", -1, -1)
  borderB:SetPoint("BOTTOMRIGHT", 1, -1)
  borderB:SetHeight(2)
  borderB:SetColorTexture(1, 0.5, 0, 0.8)

  local borderL = anchor:CreateTexture(nil, "BORDER")
  borderL:SetPoint("TOPLEFT", -1, 1)
  borderL:SetPoint("BOTTOMLEFT", -1, -1)
  borderL:SetWidth(2)
  borderL:SetColorTexture(1, 0.5, 0, 0.8)

  local borderR = anchor:CreateTexture(nil, "BORDER")
  borderR:SetPoint("TOPRIGHT", 1, 1)
  borderR:SetPoint("BOTTOMRIGHT", 1, -1)
  borderR:SetWidth(2)
  borderR:SetColorTexture(1, 0.5, 0, 0.8)

  -- Label
  local label = anchor:CreateFontString(nil, "OVERLAY")
  label:SetPoint("CENTER")
  label:SetFont("Fonts\\FRIZQT__.TTF", 11, "OUTLINE")
  label:SetText("Drag to position lore popup")
  label:SetTextColor(1, 1, 1)

  anchor:SetScript("OnDragStart", function(self)
    self:StartMoving()
  end)

  anchor:SetScript("OnDragStop", function(self)
    self:StopMovingOrSizing()
    -- Save position relative to UIParent center
    local cx, cy = self:GetCenter()
    local ux, uy = UIParent:GetCenter()
    IABD.settings.toastX = cx - ux
    IABD.settings.toastY = cy - uy
    IABD:SaveSettings()
    -- Update toast position to match
    UI:UpdateToastPosition()
  end)

  anchor:Hide()
  self.anchor = anchor
end

function UI:ShowAnchor()
  if not self.anchor then self:CreateAnchor() end
  self.anchor:ClearAllPoints()
  local x = IABD.settings.toastX or 0
  local y = IABD.settings.toastY or -120
  self.anchor:SetPoint("CENTER", UIParent, "CENTER", x, y)
  self.anchor:Show()
end

function UI:HideAnchor()
  if self.anchor then
    self.anchor:Hide()
  end
end

function UI:ShowToast(name, tier, title, lore, duration)
  if not self.toast then self:CreateToast() end

  -- Always apply saved position
  self:UpdateToastPosition()

  local color = IABD.tierColors[tier] or { 1, 1, 1 }
  local tierName = IABD.tierNames[tier] or "Unknown"
  duration = duration or (IABD.settings and IABD.settings.popupDuration or 5)
  local mode = IABD.settings and IABD.settings.popupMode or "manual"

  -- Set tier color bar
  self.toast.colorBar:SetColorTexture(color[1], color[2], color[3], 1)

  -- Set tier label
  self.toast.tierLabel:SetText(string.upper(tierName))
  self.toast.tierLabel:SetTextColor(color[1], color[2], color[3])

  -- Set name in tier color
  self.toast.nameText:SetText(name)
  self.toast.nameText:SetTextColor(color[1], color[2], color[3])

  -- Set title
  self.toast.titleText:SetText(title)

  -- Set lore
  self.toast.loreText:SetText(lore)

  -- Resize toast to fit lore text
  local loreHeight = self.toast.loreText:GetStringHeight() or 20
  self.toast:SetHeight(65 + loreHeight)

  -- Show
  self.toast:SetAlpha(1)
  self.toast:Show()

  -- Behavior depends on popup mode
  if mode == "timed" then
    -- Auto-fade after duration
    self.toast.fadeStart = GetTime()
    self.toast.fadeDelay = duration
    self.toast.isFading = true
  else
    -- "manual" or "target": stays until closed or target changes
    self.toast.isFading = false
  end
end

function UI:HideToast()
  if self.toast then
    self.toast:Hide()
    self.toast.isFading = false
    self.toast:SetAlpha(1)
  end
end

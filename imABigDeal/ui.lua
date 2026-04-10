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

function UI:ShowDot(tier)
  if not self.dot then self:CreatePortraitDot() end

  local color = IABD.tierColors[tier]
  if not color then
    self.dot:Hide()
    return
  end

  -- Anchor to TargetFrame if it exists
  self.dot:ClearAllPoints()
  if TargetFrame then
    self.dot:SetPoint("TOPRIGHT", TargetFrame, "TOPRIGHT", -4, -4)
  else
    self.dot:Hide()
    return
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

  local toast = CreateFrame("Frame", "ImABigDealToast", UIParent, "BackdropTemplate")
  toast:SetSize(380, 100)
  toast:SetPoint("TOP", UIParent, "TOP", 0, -120)
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

  -- Fade animation via OnUpdate
  toast.fadeStart = 0
  toast.fadeDelay = 5
  toast.isFading = false
  toast:SetScript("OnUpdate", function(self, elapsed)
    if not self.isFading then return end
    local elapsed = GetTime() - self.fadeStart
    if elapsed < self.fadeDelay then return end

    local fadeProgress = (elapsed - self.fadeDelay) / 1.0  -- 1s fade
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

function UI:ShowToast(name, tier, title, lore, duration)
  if not self.toast then self:CreateToast() end

  local color = IABD.tierColors[tier] or { 1, 1, 1 }
  local tierName = IABD.tierNames[tier] or "Unknown"
  duration = duration or (IABD.settings and IABD.settings.popupDuration or 5)

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

  -- Show and start fade timer
  self.toast:SetAlpha(1)
  self.toast:Show()
  self.toast.fadeStart = GetTime()
  self.toast.fadeDelay = duration
  self.toast.isFading = true
end

function UI:HideToast()
  if self.toast then
    self.toast:Hide()
    self.toast.isFading = false
    self.toast:SetAlpha(1)
  end
end

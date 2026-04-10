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
  dot:SetSize(24, 24)
  dot:SetFrameStrata("TOOLTIP")
  dot:SetFrameLevel(100)

  -- Glow (larger, faded circle behind the main dot)
  local glow = dot:CreateTexture(nil, "BACKGROUND")
  glow:SetPoint("CENTER")
  glow:SetSize(34, 34)
  glow:SetTexture("Interface\\CHARACTERFRAME\\TempPortraitAlphaMask")
  glow:SetAlpha(0.35)
  dot.glow = glow

  -- Dark border ring
  local ring = dot:CreateTexture(nil, "BORDER")
  ring:SetPoint("CENTER")
  ring:SetSize(28, 28)
  ring:SetTexture("Interface\\CHARACTERFRAME\\TempPortraitAlphaMask")
  ring:SetVertexColor(0, 0, 0, 0.8)
  dot.ring = ring

  -- Main colored circle (portrait mask = guaranteed round texture)
  local circle = dot:CreateTexture(nil, "ARTWORK")
  circle:SetAllPoints()
  circle:SetTexture("Interface\\CHARACTERFRAME\\TempPortraitAlphaMask")
  dot.circle = circle

  -- Tier letter overlay
  local letter = dot:CreateFontString(nil, "OVERLAY")
  letter:SetPoint("CENTER", 0, 0)
  letter:SetFont("Fonts\\FRIZQT__.TTF", 12, "OUTLINE, THICKOUTLINE")
  dot.letter = letter

  dot:Hide()
  self.dot = dot
end

local tierLetters = { [5] = "L", [4] = "E", [3] = "R", [2] = "U", [1] = "C" }

function UI:ShowDot(tier)
  if not self.dot then self:CreatePortraitDot() end

  local color = IABD.tierColors[tier]
  if not color then
    self.dot:Hide()
    return
  end

  self.dot:ClearAllPoints()

  -- Find and anchor to the target frame
  local anchored = false
  local targetFrame = _G["TargetFrame"]

  if targetFrame then
    -- Try to anchor near the portrait (top-left area of the target frame)
    -- TargetFrame's portrait is roughly at the left side
    local ok = pcall(function()
      self.dot:SetPoint("TOPLEFT", targetFrame, "TOPLEFT", 6, -6)
    end)
    if ok then anchored = true end
  end

  if not anchored then
    -- Fallback: fixed position where target frame usually sits
    self.dot:SetPoint("TOPLEFT", UIParent, "TOPLEFT", 280, -30)
  end

  -- Color the circle
  self.dot.circle:SetVertexColor(color[1], color[2], color[3], 1)
  self.dot.glow:SetVertexColor(color[1], color[2], color[3], 0.35)

  -- Letter in contrasting color (dark on bright, white on dark)
  local brightness = color[1] * 0.3 + color[2] * 0.6 + color[3] * 0.1
  if brightness > 0.5 then
    self.dot.letter:SetTextColor(0, 0, 0)
  else
    self.dot.letter:SetTextColor(1, 1, 1)
  end
  self.dot.letter:SetText(tierLetters[tier] or "?")
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

  -- "NEW!" badge (hidden by default)
  local newBadge = toast:CreateFontString(nil, "OVERLAY")
  newBadge:SetPoint("RIGHT", tierLabel, "RIGHT", 60, 0)
  newBadge:SetFont("Fonts\\FRIZQT__.TTF", 10, "OUTLINE, THICKOUTLINE")
  newBadge:SetText("NEW DISCOVERY!")
  newBadge:SetTextColor(0, 1, 0)
  newBadge:Hide()
  toast.newBadge = newBadge

  -- Discovery counter
  local discoverCount = toast:CreateFontString(nil, "OVERLAY")
  discoverCount:SetPoint("BOTTOMRIGHT", toast, "BOTTOMRIGHT", -10, 6)
  discoverCount:SetFont("Fonts\\FRIZQT__.TTF", 9, "OUTLINE")
  discoverCount:SetTextColor(0.5, 0.5, 0.5)
  toast.discoverCount = discoverCount

  -- Click hint
  local clickHint = toast:CreateFontString(nil, "OVERLAY")
  clickHint:SetPoint("BOTTOMLEFT", toast, "BOTTOMLEFT", 14, 6)
  clickHint:SetFont("Fonts\\FRIZQT__.TTF", 9, "OUTLINE")
  clickHint:SetTextColor(0.4, 0.4, 0.4)
  clickHint:SetText("Click for details")
  toast.clickHint = clickHint

  -- Make toast clickable for expanded view
  toast:EnableMouse(true)
  toast:SetScript("OnMouseUp", function(self, button)
    if button == "LeftButton" then
      UI:ShowExpandedView()
    end
  end)

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

function UI:ShowToast(name, tier, title, lore, duration, isNewDiscovery)
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

  -- NEW badge
  if isNewDiscovery then
    self.toast.newBadge:Show()
  else
    self.toast.newBadge:Hide()
  end

  -- Discovery counter
  local total = IABD:GetDiscoveryCount()
  self.toast.discoverCount:SetText(total .. " discovered")

  -- Resize toast to fit lore text
  local loreHeight = self.toast.loreText:GetStringHeight() or 20
  self.toast:SetHeight(75 + loreHeight)

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

-- ============================================================
-- Expanded Detail View (click toast to open)
-- ============================================================

function UI:CreateExpandedView()
  if self.expanded then return end

  local panel = CreateFrame("Frame", "ImABigDealExpanded", UIParent)
  panel:SetSize(420, 300)
  panel:SetPoint("CENTER", UIParent, "CENTER", 0, 50)
  panel:SetFrameStrata("DIALOG")
  panel:EnableMouse(true)
  panel:SetMovable(true)
  panel:RegisterForDrag("LeftButton")
  panel:SetScript("OnDragStart", panel.StartMoving)
  panel:SetScript("OnDragStop", panel.StopMovingOrSizing)

  -- Background
  local bg = panel:CreateTexture(nil, "BACKGROUND")
  bg:SetAllPoints()
  bg:SetColorTexture(0.03, 0.03, 0.06, 0.95)

  -- Top color bar
  local bar = panel:CreateTexture(nil, "ARTWORK")
  bar:SetPoint("TOPLEFT", 0, 0)
  bar:SetPoint("TOPRIGHT", 0, 0)
  bar:SetHeight(4)
  panel.colorBar = bar

  -- Borders
  for _, edge in ipairs({
    {"TOPLEFT", "BOTTOMLEFT", 1, false},
    {"TOPRIGHT", "BOTTOMRIGHT", 1, false},
    {"BOTTOMLEFT", "BOTTOMRIGHT", 1, true},
  }) do
    local b = panel:CreateTexture(nil, "BORDER")
    if edge[4] then
      b:SetPoint("BOTTOMLEFT", -1, -1)
      b:SetPoint("BOTTOMRIGHT", 1, -1)
      b:SetHeight(1)
    else
      b:SetPoint(edge[1], edge[1]:find("RIGHT") and 1 or -1, 1)
      b:SetPoint(edge[2], edge[2]:find("RIGHT") and 1 or -1, -1)
      b:SetWidth(1)
    end
    b:SetColorTexture(0.4, 0.4, 0.4, 0.5)
  end

  -- Close button
  local closeBtn = CreateFrame("Button", nil, panel)
  closeBtn:SetPoint("TOPRIGHT", -8, -8)
  closeBtn:SetSize(20, 20)
  local closeTxt = closeBtn:CreateFontString(nil, "OVERLAY")
  closeTxt:SetPoint("CENTER")
  closeTxt:SetFont("Fonts\\FRIZQT__.TTF", 16, "OUTLINE")
  closeTxt:SetText("X")
  closeTxt:SetTextColor(0.8, 0.2, 0.2)
  closeBtn:SetScript("OnClick", function() panel:Hide() end)

  -- Tier label
  local tierLabel = panel:CreateFontString(nil, "OVERLAY")
  tierLabel:SetPoint("TOPLEFT", 20, -14)
  tierLabel:SetFont("Fonts\\FRIZQT__.TTF", 11, "OUTLINE")
  panel.tierLabel = tierLabel

  -- NPC name (big)
  local nameText = panel:CreateFontString(nil, "OVERLAY")
  nameText:SetPoint("TOPLEFT", 20, -30)
  nameText:SetFont("Fonts\\FRIZQT__.TTF", 20, "OUTLINE, THICKOUTLINE")
  panel.nameText = nameText

  -- Title
  local titleText = panel:CreateFontString(nil, "OVERLAY")
  titleText:SetPoint("TOPLEFT", 20, -55)
  titleText:SetFont("Fonts\\FRIZQT__.TTF", 13, "OUTLINE")
  titleText:SetTextColor(0.7, 0.7, 0.7)
  panel.titleText = titleText

  -- Divider line
  local divider = panel:CreateTexture(nil, "ARTWORK")
  divider:SetPoint("TOPLEFT", 20, -75)
  divider:SetPoint("RIGHT", panel, "RIGHT", -20, 0)
  divider:SetHeight(1)
  divider:SetColorTexture(0.3, 0.3, 0.3, 0.6)

  -- Full lore text (scrollable area)
  local loreText = panel:CreateFontString(nil, "OVERLAY")
  loreText:SetPoint("TOPLEFT", 20, -85)
  loreText:SetPoint("RIGHT", panel, "RIGHT", -20, 0)
  loreText:SetFont("Fonts\\FRIZQT__.TTF", 12, "OUTLINE")
  loreText:SetTextColor(0.9, 0.9, 0.9)
  loreText:SetJustifyH("LEFT")
  loreText:SetWordWrap(true)
  panel.loreText = loreText

  -- In-game info section
  local infoLabel = panel:CreateFontString(nil, "OVERLAY")
  infoLabel:SetPoint("BOTTOMLEFT", panel, "BOTTOMLEFT", 20, 40)
  infoLabel:SetFont("Fonts\\FRIZQT__.TTF", 10, "OUTLINE")
  infoLabel:SetTextColor(0.5, 0.5, 0.5)
  panel.infoLabel = infoLabel

  -- Discovery info
  local discoveryLabel = panel:CreateFontString(nil, "OVERLAY")
  discoveryLabel:SetPoint("BOTTOMLEFT", panel, "BOTTOMLEFT", 20, 14)
  discoveryLabel:SetFont("Fonts\\FRIZQT__.TTF", 10, "OUTLINE")
  discoveryLabel:SetTextColor(0.5, 0.5, 0.5)
  panel.discoveryLabel = discoveryLabel

  panel:Hide()
  self.expanded = panel
end

function UI:ShowExpandedView()
  if not self.expanded then self:CreateExpandedView() end
  if not IABD.currentEntry then return end

  local entry = IABD.currentEntry
  local tier = entry[1]
  local title = entry[2] or ""
  local lore = entry[3] or ""
  local name = UnitExists("target") and UnitName("target") or "Unknown"
  local color = IABD.tierColors[tier] or { 1, 1, 1 }
  local tierName = IABD.tierNames[tier] or "Unknown"

  -- Color bar
  self.expanded.colorBar:SetColorTexture(color[1], color[2], color[3], 1)

  -- Tier
  self.expanded.tierLabel:SetText(string.upper(tierName))
  self.expanded.tierLabel:SetTextColor(color[1], color[2], color[3])

  -- Name
  self.expanded.nameText:SetText(name)
  self.expanded.nameText:SetTextColor(color[1], color[2], color[3])

  -- Title
  self.expanded.titleText:SetText(title)

  -- Full lore (not truncated)
  self.expanded.loreText:SetText(lore)

  -- In-game info
  local infoParts = {}
  if UnitExists("target") then
    local ctype = UnitCreatureType("target")
    local classification = UnitClassification("target")
    local level = UnitLevel("target")
    if level and level > 0 then table.insert(infoParts, "Level " .. level) end
    if ctype then table.insert(infoParts, ctype) end
    if classification and classification ~= "normal" then
      table.insert(infoParts, classification:sub(1,1):upper() .. classification:sub(2))
    end
  end
  self.expanded.infoLabel:SetText(table.concat(infoParts, " | "))

  -- Discovery info
  local disc = IABD.discovered[name]
  if disc then
    local seenText = "Discovered | Seen " .. (disc.count or 1) .. " time(s)"
    self.expanded.discoveryLabel:SetText(seenText)
    self.expanded.discoveryLabel:SetTextColor(0, 0.8, 0)
  else
    self.expanded.discoveryLabel:SetText("Not yet discovered")
    self.expanded.discoveryLabel:SetTextColor(0.5, 0.5, 0.5)
  end

  -- Resize to fit lore
  local loreHeight = self.expanded.loreText:GetStringHeight() or 40
  self.expanded:SetHeight(math.max(180, 100 + loreHeight + 50))

  self.expanded:Show()
end

-- ============================================================
-- Collection Browser (Pokédex)
-- ============================================================

function UI:CreateCollectionBrowser()
  if self.collection then return end

  local panel = CreateFrame("Frame", "ImABigDealCollection", UIParent)
  panel:SetSize(450, 500)
  panel:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
  panel:SetFrameStrata("DIALOG")
  panel:EnableMouse(true)
  panel:SetMovable(true)
  panel:RegisterForDrag("LeftButton")
  panel:SetScript("OnDragStart", panel.StartMoving)
  panel:SetScript("OnDragStop", panel.StopMovingOrSizing)

  -- Background
  local bg = panel:CreateTexture(nil, "BACKGROUND")
  bg:SetAllPoints()
  bg:SetColorTexture(0.03, 0.03, 0.06, 0.95)

  -- Top bar
  local topBar = panel:CreateTexture(nil, "ARTWORK")
  topBar:SetPoint("TOPLEFT", 0, 0)
  topBar:SetPoint("TOPRIGHT", 0, 0)
  topBar:SetHeight(4)
  topBar:SetColorTexture(1, 0.5, 0, 1)

  -- Borders
  local borderL = panel:CreateTexture(nil, "BORDER")
  borderL:SetPoint("TOPLEFT", -1, 1)
  borderL:SetPoint("BOTTOMLEFT", -1, -1)
  borderL:SetWidth(1)
  borderL:SetColorTexture(0.4, 0.4, 0.4, 0.5)
  local borderR = panel:CreateTexture(nil, "BORDER")
  borderR:SetPoint("TOPRIGHT", 1, 1)
  borderR:SetPoint("BOTTOMRIGHT", 1, -1)
  borderR:SetWidth(1)
  borderR:SetColorTexture(0.4, 0.4, 0.4, 0.5)
  local borderB = panel:CreateTexture(nil, "BORDER")
  borderB:SetPoint("BOTTOMLEFT", -1, -1)
  borderB:SetPoint("BOTTOMRIGHT", 1, -1)
  borderB:SetHeight(1)
  borderB:SetColorTexture(0.4, 0.4, 0.4, 0.5)

  -- Title
  local title = panel:CreateFontString(nil, "OVERLAY")
  title:SetPoint("TOP", 0, -12)
  title:SetFont("Fonts\\FRIZQT__.TTF", 16, "OUTLINE, THICKOUTLINE")
  title:SetText("|cffff8000Lore Collection|r")

  -- Close button
  local closeBtn = CreateFrame("Button", nil, panel)
  closeBtn:SetPoint("TOPRIGHT", -8, -8)
  closeBtn:SetSize(20, 20)
  local closeTxt = closeBtn:CreateFontString(nil, "OVERLAY")
  closeTxt:SetPoint("CENTER")
  closeTxt:SetFont("Fonts\\FRIZQT__.TTF", 16, "OUTLINE")
  closeTxt:SetText("X")
  closeTxt:SetTextColor(0.8, 0.2, 0.2)
  closeBtn:SetScript("OnClick", function() panel:Hide() end)

  -- Stats bar
  local statsText = panel:CreateFontString(nil, "OVERLAY")
  statsText:SetPoint("TOPLEFT", 20, -35)
  statsText:SetFont("Fonts\\FRIZQT__.TTF", 11, "OUTLINE")
  panel.statsText = statsText

  -- Tier filter buttons
  local filterY = -55
  local filterLabel = panel:CreateFontString(nil, "OVERLAY")
  filterLabel:SetPoint("TOPLEFT", 20, filterY)
  filterLabel:SetFont("Fonts\\FRIZQT__.TTF", 10, "OUTLINE")
  filterLabel:SetText("Filter:")
  filterLabel:SetTextColor(0.6, 0.6, 0.6)

  panel.currentFilter = 0  -- 0 = all
  local filterNames = { "All", "Legendary", "Epic", "Rare", "Uncommon", "Common" }
  local filterTiers = { 0, 5, 4, 3, 2, 1 }
  local filterColors = {
    { 1, 1, 1 }, { 1, 0.5, 0 }, { 0.64, 0.21, 0.93 },
    { 0, 0.44, 0.87 }, { 0.12, 1, 0 }, { 1, 1, 1 },
  }
  panel.filterButtons = {}

  for i, fname in ipairs(filterNames) do
    local fb = CreateFrame("Button", nil, panel)
    fb:SetPoint("TOPLEFT", 60 + (i - 1) * 62, filterY + 3)
    fb:SetSize(58, 16)
    fb:EnableMouse(true)

    local fbBg = fb:CreateTexture(nil, "BACKGROUND")
    fbBg:SetAllPoints()
    fbBg:SetColorTexture(0.15, 0.15, 0.15, 0.8)
    fb.bg = fbBg

    local fbTxt = fb:CreateFontString(nil, "OVERLAY")
    fbTxt:SetPoint("CENTER")
    fbTxt:SetFont("Fonts\\FRIZQT__.TTF", 9, "OUTLINE")
    fbTxt:SetText(fname)
    fbTxt:SetTextColor(filterColors[i][1], filterColors[i][2], filterColors[i][3])

    fb:SetScript("OnClick", function()
      panel.currentFilter = filterTiers[i]
      UI:RefreshCollection()
    end)

    panel.filterButtons[i] = fb
  end

  -- Scrollable content area
  local scrollFrame = CreateFrame("ScrollFrame", nil, panel)
  scrollFrame:SetPoint("TOPLEFT", 10, -75)
  scrollFrame:SetPoint("BOTTOMRIGHT", -10, 10)
  panel.scrollFrame = scrollFrame

  local content = CreateFrame("Frame", nil, scrollFrame)
  content:SetSize(430, 1)  -- height set dynamically
  scrollFrame:SetScrollChild(content)
  panel.content = content
  panel.entryFrames = {}

  -- Mouse wheel scrolling
  panel.scrollOffset = 0
  panel:SetScript("OnMouseWheel", function(self, delta)
    self.scrollOffset = math.max(0, self.scrollOffset - delta * 30)
    scrollFrame:SetVerticalScroll(self.scrollOffset)
  end)

  panel:Hide()
  self.collection = panel
end

function UI:RefreshCollection()
  if not self.collection then return end
  local panel = self.collection

  -- Get stats
  local total = IABD:GetDiscoveryCount()
  local byTier = IABD:GetDiscoveryByTier()

  panel.statsText:SetText(
    "|cff00ff00" .. total .. "|r discovered  —  " ..
    "|cffff8000" .. byTier[5] .. "|r L  " ..
    "|cffa335ee" .. byTier[4] .. "|r E  " ..
    "|cff0070dd" .. byTier[3] .. "|r R  " ..
    "|cff1eff00" .. byTier[2] .. "|r U  " ..
    "|cffffffff" .. byTier[1] .. "|r C"
  )

  -- Clear old entries
  for _, frame in ipairs(panel.entryFrames) do
    frame:Hide()
  end
  panel.entryFrames = {}

  -- Build sorted list
  local entries = {}
  for name, data in pairs(IABD.discovered) do
    if panel.currentFilter == 0 or data.tier == panel.currentFilter then
      table.insert(entries, { name = name, tier = data.tier, title = data.title, count = data.count or 1 })
    end
  end

  -- Sort: tier descending, then name alphabetical
  table.sort(entries, function(a, b)
    if a.tier ~= b.tier then return a.tier > b.tier end
    return a.name < b.name
  end)

  -- Create entry rows
  local rowHeight = 24
  local y = 0

  for i, entry in ipairs(entries) do
    local color = IABD.tierColors[entry.tier] or { 1, 1, 1 }
    local tierLetter = ({ [5] = "L", [4] = "E", [3] = "R", [2] = "U", [1] = "C" })[entry.tier] or "?"

    local row = CreateFrame("Frame", nil, panel.content)
    row:SetPoint("TOPLEFT", 0, -y)
    row:SetSize(410, rowHeight)

    -- Alternating row background
    if i % 2 == 0 then
      local rowBg = row:CreateTexture(nil, "BACKGROUND")
      rowBg:SetAllPoints()
      rowBg:SetColorTexture(0.1, 0.1, 0.1, 0.3)
    end

    -- Tier dot
    local dot = row:CreateFontString(nil, "OVERLAY")
    dot:SetPoint("LEFT", 5, 0)
    dot:SetFont("Fonts\\FRIZQT__.TTF", 10, "OUTLINE")
    dot:SetText("[" .. tierLetter .. "]")
    dot:SetTextColor(color[1], color[2], color[3])

    -- Name
    local nameText = row:CreateFontString(nil, "OVERLAY")
    nameText:SetPoint("LEFT", 30, 0)
    nameText:SetFont("Fonts\\FRIZQT__.TTF", 11, "OUTLINE")
    nameText:SetText(entry.name)
    nameText:SetTextColor(color[1], color[2], color[3])

    -- Title (dimmed)
    if entry.title and entry.title ~= "" then
      local titleText = row:CreateFontString(nil, "OVERLAY")
      titleText:SetPoint("LEFT", nameText, "RIGHT", 8, 0)
      titleText:SetFont("Fonts\\FRIZQT__.TTF", 10, "OUTLINE")
      titleText:SetText("— " .. entry.title)
      titleText:SetTextColor(0.5, 0.5, 0.5)
    end

    -- Seen count (right side)
    local countText = row:CreateFontString(nil, "OVERLAY")
    countText:SetPoint("RIGHT", -10, 0)
    countText:SetFont("Fonts\\FRIZQT__.TTF", 9, "OUTLINE")
    countText:SetText("x" .. entry.count)
    countText:SetTextColor(0.4, 0.4, 0.4)

    table.insert(panel.entryFrames, row)
    y = y + rowHeight
  end

  -- Update content height for scrolling
  panel.content:SetHeight(math.max(1, y))
  panel.scrollOffset = 0
  panel.scrollFrame:SetVerticalScroll(0)
end

function UI:ToggleCollection()
  if not self.collection then self:CreateCollectionBrowser() end

  if self.collection:IsShown() then
    self.collection:Hide()
  else
    self:RefreshCollection()
    self.collection:Show()
  end
end

local ADDON_NAME = "ImABigDeal"
local IABD = _G[ADDON_NAME]

-- Slash commands
SLASH_IMABIGDEAL1 = "/imabigdeal"
SLASH_IMABIGDEAL2 = "/iabd"
SLASH_IMABIGDEAL3 = "/bigdeal"

SlashCmdList["IMABIGDEAL"] = function(msg)
  msg = string.lower(msg or "")

  if msg == "" or msg == "toggle" then
    IABD:TogglePanel()
  elseif msg == "info" then
    IABD:ShowCurrentTargetInfo()
  elseif msg:sub(1, 6) == "lookup" then
    local query = msg:sub(8)
    IABD:LookupByName(query)
  elseif msg == "collection" or msg == "pokedex" or msg == "stats" then
    local total = IABD:GetDiscoveryCount()
    local byTier = IABD:GetDiscoveryByTier()
    print("|cffff8000I'm A Big Deal — Discovery Collection|r")
    print("  Total discovered: |cff00ff00" .. total .. "|r")
    print("  |cffff8000Legendary:|r " .. byTier[5])
    print("  |cffa335eeEpic:|r " .. byTier[4])
    print("  |cff0070ddRare:|r " .. byTier[3])
    print("  |cff1eff00Uncommon:|r " .. byTier[2])
    print("  |cffffffffCommon:|r " .. byTier[1])
  elseif msg == "debug" then
    IABD.debugMode = not IABD.debugMode
    print("|cffff8000I'm A Big Deal:|r Debug mode " .. (IABD.debugMode and "ON" or "OFF"))
  elseif msg == "test" then
    -- Show a test toast
    IABD.ui:ShowToast(
      "Thrall",
      5,
      "Warchief of the Horde",
      "Born Go'el, raised as a slave gladiator by Aedelas Blackmoore. Escaped to unite the Horde, led them to Kalimdor, and served as Warchief. Wielder of the Doomhammer and Earth-Warder during the Cataclysm.",
      IABD.settings.popupDuration
    )
    IABD.ui:ShowDot(5)
  else
    print("|cffff8000I'm A Big Deal|r commands:")
    print("  /iabd — Toggle settings")
    print("  /iabd info — Show lore for current target")
    print("  /iabd test — Test popup with Thrall")
    print("  /iabd lookup <name> — Search lore database")
  end
end

-- Show info for current target
function IABD:ShowCurrentTargetInfo()
  if not UnitExists("target") then
    print("|cffff8000I'm A Big Deal:|r No target selected.")
    return
  end

  local guid = UnitGUID("target")
  local npcID = self:GetNPCIdFromGUID(guid)
  local name = UnitName("target") or "Unknown"

  if not npcID then
    print("|cffff8000I'm A Big Deal:|r " .. name .. " is not an NPC (no NPC ID).")
    return
  end

  local entry = self:LookupNPC(npcID, name)
  local source = "database"
  if not entry then
    -- Try fallback
    entry = self:BuildFallbackEntry(name)
    source = "fallback"
  end
  if not entry then
    -- Debug: show what WoW knows about this NPC
    local ctype = UnitCreatureType("target") or "nil"
    local class = UnitClassification("target") or "nil"
    local lvl = UnitLevel("target") or "nil"
    print("|cffff8000I'm A Big Deal:|r " .. name .. " (NPC ID: " .. tostring(npcID) .. ") — Not found anywhere.")
    print("  CreatureType: " .. ctype .. ", Classification: " .. class .. ", Level: " .. tostring(lvl))
    print("  Fallback returned nil — no displayable info.")
    return
  end

  local tier, title, lore = entry[1], entry[2], entry[3]
  local color = IABD.tierColors[tier] or { 1, 1, 1 }
  local tierName = IABD.tierNames[tier] or "Unknown"

  local r, g, b = color[1], color[2], color[3]
  local hexColor = string.format("|cff%02x%02x%02x", r * 255, g * 255, b * 255)

  print(hexColor .. "[" .. tierName .. "]|r " .. name .. " — " .. title)
  print("  " .. lore)
end

-- Search database by title keyword
function IABD:LookupByName(query)
  if not query or query == "" then
    print("|cffff8000I'm A Big Deal:|r Usage: /iabd lookup <keyword>")
    return
  end

  query = string.lower(query)
  local results = 0

  for npcID, entry in pairs(self.loreDB) do
    local title = string.lower(entry[2] or "")
    local lore = string.lower(entry[3] or "")
    if title:find(query, 1, true) or lore:find(query, 1, true) then
      local tier = entry[1]
      local color = IABD.tierColors[tier] or { 1, 1, 1 }
      local tierName = IABD.tierNames[tier] or "?"
      local hexColor = string.format("|cff%02x%02x%02x", color[1] * 255, color[2] * 255, color[3] * 255)
      print(hexColor .. "[" .. tierName .. "]|r NPC " .. npcID .. " — " .. entry[2])
      results = results + 1
      if results >= 10 then
        print("  ...and more. Refine your search.")
        break
      end
    end
  end

  if results == 0 then
    print("|cffff8000I'm A Big Deal:|r No results for '" .. query .. "'.")
  end
end

-- Settings panel (minimal for now, can expand later)
function IABD:TogglePanel()
  if not self.settingsPanel then
    self:CreateSettingsPanel()
  end
  if self.settingsPanel:IsShown() then
    self.settingsPanel:Hide()
    self.ui:HideAnchor()
  else
    self.settingsPanel:Show()
  end
end

function IABD:CreateSettingsPanel()
  if self.settingsPanel then return end

  local panel = CreateFrame("Frame", "ImABigDealPanel", UIParent)
  panel:SetSize(350, 540)
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
  bg:SetColorTexture(0.05, 0.05, 0.08, 0.92)

  -- Border
  for _, edge in ipairs({
    {"TOPLEFT", "TOPRIGHT", 2, true},
    {"BOTTOMLEFT", "BOTTOMRIGHT", 2, true},
    {"TOPLEFT", "BOTTOMLEFT", 2, false},
    {"TOPRIGHT", "BOTTOMRIGHT", 2, false},
  }) do
    local b = panel:CreateTexture(nil, "BORDER")
    if edge[4] then -- horizontal
      b:SetPoint("TOPLEFT" == edge[1] and "TOPLEFT" or "BOTTOMLEFT", -1, edge[1] == "TOPLEFT" and 1 or -1)
      b:SetPoint("TOPRIGHT" == edge[2] and "TOPRIGHT" or "BOTTOMRIGHT", 1, edge[2] == "TOPRIGHT" and 1 or -1)
      b:SetHeight(edge[3])
    else -- vertical
      b:SetPoint(edge[1], edge[1]:find("RIGHT") and 1 or -1, 1)
      b:SetPoint(edge[2], edge[2]:find("RIGHT") and 1 or -1, -1)
      b:SetWidth(edge[3])
    end
    b:SetColorTexture(1, 0.5, 0, 0.6)
  end

  -- Title
  local title = panel:CreateFontString(nil, "OVERLAY")
  title:SetPoint("TOP", panel, "TOP", 0, -14)
  title:SetFont("Fonts\\FRIZQT__.TTF", 14, "OUTLINE")
  title:SetText("|cffff8000I'm A Big Deal|r")

  -- Close button
  local closeBtn = CreateFrame("Button", nil, panel)
  closeBtn:SetPoint("TOPRIGHT", panel, "TOPRIGHT", -8, -8)
  closeBtn:SetSize(20, 20)
  local closeTxt = closeBtn:CreateFontString(nil, "OVERLAY")
  closeTxt:SetPoint("CENTER")
  closeTxt:SetFont("Fonts\\FRIZQT__.TTF", 16, "OUTLINE")
  closeTxt:SetText("X")
  closeTxt:SetTextColor(0.8, 0.2, 0.2)
  closeBtn:SetScript("OnClick", function() panel:Hide() end)

  -- Helper: checkbox
  local function MakeCheckbox(yPos, label, settingKey)
    local cb = CreateFrame("CheckButton", nil, panel)
    cb:SetPoint("TOPLEFT", panel, "TOPLEFT", 20, yPos)
    cb:SetSize(24, 24)

    local cbBg = cb:CreateTexture(nil, "BACKGROUND")
    cbBg:SetAllPoints()
    cbBg:SetColorTexture(0.15, 0.15, 0.15, 0.8)

    local check = cb:CreateTexture(nil, "ARTWORK")
    check:SetSize(20, 20)
    check:SetPoint("CENTER")
    check:SetTexture("Interface\\Buttons\\UI-CheckBox-Check")
    cb:SetCheckedTexture(check)

    local cbLabel = panel:CreateFontString(nil, "OVERLAY")
    cbLabel:SetPoint("LEFT", cb, "RIGHT", 6, 0)
    cbLabel:SetFont("Fonts\\FRIZQT__.TTF", 12, "OUTLINE")
    cbLabel:SetText(label)

    cb:SetChecked(IABD.settings[settingKey])
    cb:SetScript("OnClick", function(self)
      IABD.settings[settingKey] = self:GetChecked()
      IABD:SaveSettings()
    end)
    return cb
  end

  -- Helper: slider
  local function MakeSlider(yPos, label, min, max, step, settingKey, formatStr)
    local slLabel = panel:CreateFontString(nil, "OVERLAY")
    slLabel:SetPoint("TOPLEFT", panel, "TOPLEFT", 20, yPos)
    slLabel:SetFont("Fonts\\FRIZQT__.TTF", 12, "OUTLINE")
    slLabel:SetText(label)

    local valText = panel:CreateFontString(nil, "OVERLAY")
    valText:SetPoint("LEFT", slLabel, "RIGHT", 8, 0)
    valText:SetFont("Fonts\\FRIZQT__.TTF", 11, "OUTLINE")
    valText:SetTextColor(1, 0.5, 0)
    valText:SetText(formatStr:format(IABD.settings[settingKey]))

    local slider = CreateFrame("Slider", nil, panel)
    slider:SetPoint("TOPLEFT", panel, "TOPLEFT", 20, yPos - 18)
    slider:SetSize(290, 16)
    slider:SetOrientation("HORIZONTAL")
    slider:SetMinMaxValues(min, max)
    slider:SetValueStep(step)
    slider:SetObeyStepOnDrag(true)
    slider:SetValue(IABD.settings[settingKey])
    slider:EnableMouse(true)

    local slBg = slider:CreateTexture(nil, "BACKGROUND")
    slBg:SetAllPoints()
    slBg:SetColorTexture(0.2, 0.2, 0.2, 0.8)

    local thumb = slider:CreateTexture(nil, "ARTWORK")
    thumb:SetSize(12, 20)
    thumb:SetColorTexture(1, 0.5, 0, 1)
    slider:SetThumbTexture(thumb)

    slider:SetScript("OnValueChanged", function(self, value)
      value = math.floor(value / step + 0.5) * step
      IABD.settings[settingKey] = value
      valText:SetText(formatStr:format(value))
      IABD:SaveSettings()
    end)

    return slider
  end

  local y = -40

  MakeCheckbox(y, "Show Portrait Dot", "dotEnabled")
  y = y - 28
  MakeCheckbox(y, "Show Lore Popup", "popupEnabled")
  y = y - 28
  MakeCheckbox(y, "Suppress Popup in Combat", "suppressInCombat")
  y = y - 28
  MakeCheckbox(y, "Show Unknown NPCs (basic info)", "showUnknownNPCs")

  -- Popup mode selector: manual / timed / target
  y = y - 35
  local modeLabel = panel:CreateFontString(nil, "OVERLAY")
  modeLabel:SetPoint("TOPLEFT", panel, "TOPLEFT", 20, y)
  modeLabel:SetFont("Fonts\\FRIZQT__.TTF", 12, "OUTLINE")
  modeLabel:SetText("Popup Mode:")

  local modeNames = { "manual", "timed", "target" }
  local modeDescriptions = {
    manual = "Manual — stays until you close it",
    timed = "Timed — auto-fades after duration",
    target = "Target — dismisses on target change",
  }

  local modeText = panel:CreateFontString(nil, "OVERLAY")
  modeText:SetPoint("TOPLEFT", panel, "TOPLEFT", 60, y - 16)
  modeText:SetFont("Fonts\\FRIZQT__.TTF", 11, "OUTLINE")
  modeText:SetTextColor(1, 0.5, 0)
  modeText:SetText(modeDescriptions[IABD.settings.popupMode] or "Manual")

  local prevMode = CreateFrame("Button", nil, panel)
  prevMode:SetPoint("TOPLEFT", panel, "TOPLEFT", 20, y - 12)
  prevMode:SetSize(30, 20)
  prevMode:EnableMouse(true)
  local prevModeBg = prevMode:CreateTexture(nil, "BACKGROUND")
  prevModeBg:SetAllPoints()
  prevModeBg:SetColorTexture(0.2, 0.2, 0.2, 0.9)
  local prevModeTxt = prevMode:CreateFontString(nil, "OVERLAY")
  prevModeTxt:SetPoint("CENTER")
  prevModeTxt:SetFont("Fonts\\FRIZQT__.TTF", 14, "OUTLINE")
  prevModeTxt:SetText("<")

  local nextMode = CreateFrame("Button", nil, panel)
  nextMode:SetPoint("LEFT", modeText, "RIGHT", 8, 0)
  nextMode:SetSize(30, 20)
  nextMode:EnableMouse(true)
  local nextModeBg = nextMode:CreateTexture(nil, "BACKGROUND")
  nextModeBg:SetAllPoints()
  nextModeBg:SetColorTexture(0.2, 0.2, 0.2, 0.9)
  local nextModeTxt = nextMode:CreateFontString(nil, "OVERLAY")
  nextModeTxt:SetPoint("CENTER")
  nextModeTxt:SetFont("Fonts\\FRIZQT__.TTF", 14, "OUTLINE")
  nextModeTxt:SetText(">")

  local function GetModeIndex()
    for i, m in ipairs(modeNames) do
      if m == IABD.settings.popupMode then return i end
    end
    return 1
  end

  local function UpdateModeDisplay()
    modeText:SetText(modeDescriptions[IABD.settings.popupMode] or "Manual")
  end

  prevMode:SetScript("OnClick", function()
    local idx = GetModeIndex() - 1
    if idx < 1 then idx = #modeNames end
    IABD.settings.popupMode = modeNames[idx]
    UpdateModeDisplay()
    IABD:SaveSettings()
  end)

  nextMode:SetScript("OnClick", function()
    local idx = GetModeIndex() + 1
    if idx > #modeNames then idx = 1 end
    IABD.settings.popupMode = modeNames[idx]
    UpdateModeDisplay()
    IABD:SaveSettings()
  end)

  y = y - 40
  MakeSlider(y, "Popup Duration (timed mode)", 2, 15, 1, "popupDuration", "%.0fs")
  y = y - 50
  MakeSlider(y, "Min Tier for Dot", 1, 5, 1, "minTierDot", "%.0f")
  y = y - 50
  MakeSlider(y, "Min Tier for Popup", 1, 5, 1, "minTierPopup", "%.0f")
  y = y - 50
  MakeSlider(y, "Re-show Cooldown", 0, 600, 30, "seenCooldown", "%.0fs")

  -- Test button
  y = y - 50
  local testBtn = CreateFrame("Button", nil, panel)
  testBtn:SetPoint("TOPLEFT", panel, "TOPLEFT", 20, y)
  testBtn:SetSize(140, 26)
  testBtn:EnableMouse(true)
  local testBg = testBtn:CreateTexture(nil, "BACKGROUND")
  testBg:SetAllPoints()
  testBg:SetColorTexture(0.15, 0.15, 0.15, 0.9)
  local testTxt = testBtn:CreateFontString(nil, "OVERLAY")
  testTxt:SetPoint("CENTER")
  testTxt:SetFont("Fonts\\FRIZQT__.TTF", 11, "OUTLINE")
  testTxt:SetText("Test Popup")
  testBtn:SetScript("OnClick", function()
    IABD.ui:ShowToast("Thrall", 5, "Warchief of the Horde",
      "Born Go'el, raised as a slave gladiator. Escaped to unite the Horde and served as Warchief.",
      IABD.settings.popupDuration)
    IABD.ui:ShowDot(5)
  end)
  testBtn:SetScript("OnEnter", function() testTxt:SetTextColor(1, 0.5, 0) end)
  testBtn:SetScript("OnLeave", function() testTxt:SetTextColor(1, 1, 1) end)

  -- Move Popup button (toggles draggable anchor)
  local moveBtn = CreateFrame("Button", nil, panel)
  moveBtn:SetPoint("LEFT", testBtn, "RIGHT", 10, 0)
  moveBtn:SetSize(140, 26)
  moveBtn:EnableMouse(true)
  local moveBg = moveBtn:CreateTexture(nil, "BACKGROUND")
  moveBg:SetAllPoints()
  moveBg:SetColorTexture(0.15, 0.15, 0.15, 0.9)
  local moveTxt = moveBtn:CreateFontString(nil, "OVERLAY")
  moveTxt:SetPoint("CENTER")
  moveTxt:SetFont("Fonts\\FRIZQT__.TTF", 11, "OUTLINE")
  moveTxt:SetText("Move Popup")

  local anchorVisible = false
  moveBtn:SetScript("OnClick", function()
    if anchorVisible then
      IABD.ui:HideAnchor()
      moveTxt:SetText("Move Popup")
      moveBg:SetColorTexture(0.15, 0.15, 0.15, 0.9)
      anchorVisible = false
    else
      IABD.ui:ShowAnchor()
      moveTxt:SetText("Lock Position")
      moveBg:SetColorTexture(1, 0.5, 0, 0.3)
      anchorVisible = true
    end
  end)
  moveBtn:SetScript("OnEnter", function() moveTxt:SetTextColor(1, 0.5, 0) end)
  moveBtn:SetScript("OnLeave", function() moveTxt:SetTextColor(1, 1, 1) end)

  -- Reset to Defaults button
  y = y - 35
  local resetBtn = CreateFrame("Button", nil, panel)
  resetBtn:SetPoint("TOPLEFT", panel, "TOPLEFT", 20, y)
  resetBtn:SetSize(290, 26)
  resetBtn:EnableMouse(true)
  local resetBg = resetBtn:CreateTexture(nil, "BACKGROUND")
  resetBg:SetAllPoints()
  resetBg:SetColorTexture(0.15, 0.15, 0.15, 0.9)
  local resetTxt = resetBtn:CreateFontString(nil, "OVERLAY")
  resetTxt:SetPoint("CENTER")
  resetTxt:SetFont("Fonts\\FRIZQT__.TTF", 11, "OUTLINE")
  resetTxt:SetText("Reset All Settings to Defaults")
  resetBtn:SetScript("OnClick", function()
    local defaults = {
      dotEnabled = true, popupEnabled = true, popupDuration = 5,
      popupMode = "manual", toastX = 0, toastY = -120,
      minTierDot = 1, minTierPopup = 2,
      suppressInCombat = true, seenCooldown = 300,
    }
    for k, v in pairs(defaults) do
      IABD.settings[k] = v
    end
    IABD:SaveSettings()
    IABD.ui:UpdateToastPosition()
    print("|cffff8000I'm A Big Deal:|r Settings reset to defaults. /reload to refresh the panel.")
  end)
  resetBtn:SetScript("OnEnter", function() resetTxt:SetTextColor(1, 0.5, 0) end)
  resetBtn:SetScript("OnLeave", function() resetTxt:SetTextColor(1, 1, 1) end)

  panel:Hide()
  self.settingsPanel = panel

  -- Register in addon settings
  pcall(function()
    local category = Settings.RegisterCanvasLayoutCategory(panel, "I'm A Big Deal")
    Settings.RegisterAddOnCategory(category)
  end)
end

-- Wait for ADDON_LOADED
local function OnAddonLoaded(addonName)
  if addonName == ADDON_NAME then
    IABD:Initialize()
    IABD:CreateSettingsPanel()
  end
end

local ok = pcall(function()
  RegisterEventCallback("ADDON_LOADED", OnAddonLoaded)
end)

if not ok then
  local loadFrame = CreateFrame("Frame")
  pcall(function()
    loadFrame:RegisterEvent("ADDON_LOADED")
    loadFrame:SetScript("OnEvent", function(self, event, addonName)
      OnAddonLoaded(addonName)
    end)
  end)
end

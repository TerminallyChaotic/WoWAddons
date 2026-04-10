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
  if not entry then
    print("|cffff8000I'm A Big Deal:|r " .. name .. " (NPC ID: " .. tostring(npcID) .. ") — Not in lore database.")
    print("  Consider submitting this NPC on GitHub!")
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
  else
    self.settingsPanel:Show()
  end
end

function IABD:CreateSettingsPanel()
  if self.settingsPanel then return end

  local panel = CreateFrame("Frame", "ImABigDealPanel", UIParent)
  panel:SetSize(350, 400)
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

  y = y - 35
  MakeSlider(y, "Popup Duration", 2, 15, 1, "popupDuration", "%.0fs")
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

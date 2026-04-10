local ADDON_NAME = "CritPopup"
local CP = _G[ADDON_NAME]

CP.config = {}
local Config = CP.config

-- Helper: create a labeled slider (bare minimum, no templates)
local function CreateSlider(parent, yOffset, label, min, max, step, settingKey, formatStr)
  local sliderLabel = parent:CreateFontString(nil, "OVERLAY")
  sliderLabel:SetPoint("TOPLEFT", parent, "TOPLEFT", 20, yOffset)
  sliderLabel:SetFont("Fonts\\FRIZQT__.TTF", 12, "OUTLINE")
  sliderLabel:SetText(label)

  local valueText = parent:CreateFontString(nil, "OVERLAY")
  valueText:SetPoint("LEFT", sliderLabel, "RIGHT", 8, 0)
  valueText:SetFont("Fonts\\FRIZQT__.TTF", 11, "OUTLINE")
  valueText:SetTextColor(1, 0.82, 0)
  valueText:SetText(formatStr:format(CP.settings[settingKey]))

  -- Bare slider frame — no template, no backdrop
  local slider = CreateFrame("Slider", nil, parent)
  slider:SetPoint("TOPLEFT", parent, "TOPLEFT", 20, yOffset - 18)
  slider:SetSize(340, 16)
  slider:SetOrientation("HORIZONTAL")
  slider:SetMinMaxValues(min, max)
  slider:SetValueStep(step)
  slider:SetObeyStepOnDrag(true)
  slider:SetValue(CP.settings[settingKey])
  slider:EnableMouse(true)

  -- Simple track background
  local bg = slider:CreateTexture(nil, "BACKGROUND")
  bg:SetAllPoints()
  bg:SetColorTexture(0.2, 0.2, 0.2, 0.8)

  -- Thumb
  local thumb = slider:CreateTexture(nil, "ARTWORK")
  thumb:SetSize(12, 20)
  thumb:SetColorTexture(1, 0.82, 0, 1)
  slider:SetThumbTexture(thumb)

  -- Min/max labels
  local lowText = parent:CreateFontString(nil, "ARTWORK")
  lowText:SetPoint("TOPLEFT", slider, "BOTTOMLEFT", 0, -1)
  lowText:SetFont("Fonts\\FRIZQT__.TTF", 9, "OUTLINE")
  lowText:SetTextColor(0.6, 0.6, 0.6)
  lowText:SetText(formatStr:format(min))

  local highText = parent:CreateFontString(nil, "ARTWORK")
  highText:SetPoint("TOPRIGHT", slider, "BOTTOMRIGHT", 0, -1)
  highText:SetFont("Fonts\\FRIZQT__.TTF", 9, "OUTLINE")
  highText:SetTextColor(0.6, 0.6, 0.6)
  highText:SetText(formatStr:format(max))

  slider:SetScript("OnValueChanged", function(self, value)
    value = math.floor(value / step + 0.5) * step
    CP.settings[settingKey] = value
    valueText:SetText(formatStr:format(value))
    Config:SaveSettings()
  end)

  return slider, yOffset - 50
end

-- Create settings UI panel
function Config:CreatePanel()
  if CP.settingsPanel then return end

  if CP.settingsPanel then return end

  local panel = CreateFrame("Frame", "CritPopupPanel", UIParent)
  panel:SetSize(400, 840)
  panel:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
  panel:SetFrameStrata("DIALOG")
  panel:EnableMouse(true)
  panel:SetMovable(true)
  panel:RegisterForDrag("LeftButton")
  panel:SetScript("OnDragStart", panel.StartMoving)
  panel:SetScript("OnDragStop", panel.StopMovingOrSizing)

  -- Background (no templates)
  local bg = panel:CreateTexture(nil, "BACKGROUND")
  bg:SetAllPoints()
  bg:SetColorTexture(0.05, 0.05, 0.08, 0.92)

  -- Border (simple colored edges)
  local borderTop = panel:CreateTexture(nil, "BORDER")
  borderTop:SetPoint("TOPLEFT", -2, 2)
  borderTop:SetPoint("TOPRIGHT", 2, 2)
  borderTop:SetHeight(2)
  borderTop:SetColorTexture(0.4, 0.35, 0.2, 1)

  local borderBot = panel:CreateTexture(nil, "BORDER")
  borderBot:SetPoint("BOTTOMLEFT", -2, -2)
  borderBot:SetPoint("BOTTOMRIGHT", 2, -2)
  borderBot:SetHeight(2)
  borderBot:SetColorTexture(0.4, 0.35, 0.2, 1)

  local borderLeft = panel:CreateTexture(nil, "BORDER")
  borderLeft:SetPoint("TOPLEFT", -2, 2)
  borderLeft:SetPoint("BOTTOMLEFT", -2, -2)
  borderLeft:SetWidth(2)
  borderLeft:SetColorTexture(0.4, 0.35, 0.2, 1)

  local borderRight = panel:CreateTexture(nil, "BORDER")
  borderRight:SetPoint("TOPRIGHT", 2, 2)
  borderRight:SetPoint("BOTTOMRIGHT", 2, -2)
  borderRight:SetWidth(2)
  borderRight:SetColorTexture(0.4, 0.35, 0.2, 1)

  -- Title
  local title = panel:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
  title:SetPoint("TOP", panel, "TOP", 0, -16)
  title:SetText("Crit Drop Settings")

  -- Close button (template-free)
  local closeBtn = CreateFrame("Button", nil, panel)
  closeBtn:SetPoint("TOPRIGHT", panel, "TOPRIGHT", -8, -8)
  closeBtn:SetSize(20, 20)
  local closeTxt = closeBtn:CreateFontString(nil, "OVERLAY")
  closeTxt:SetPoint("CENTER")
  closeTxt:SetFont("Fonts\\FRIZQT__.TTF", 16, "OUTLINE")
  closeTxt:SetText("X")
  closeTxt:SetTextColor(0.8, 0.2, 0.2)
  closeBtn:SetScript("OnClick", function() panel:Hide() end)
  closeBtn:SetScript("OnEnter", function() closeTxt:SetTextColor(1, 0.3, 0.3) end)
  closeBtn:SetScript("OnLeave", function() closeTxt:SetTextColor(0.8, 0.2, 0.2) end)

  -- Section header: Animation
  local animHeader = panel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  animHeader:SetPoint("TOPLEFT", panel, "TOPLEFT", 20, -45)
  animHeader:SetText("|cffffcc00Animation|r")

  local y = -60
  local _

  _, y = CreateSlider(panel, y, "Normal Damage Size", 24, 96, 2, "normalFontSize", "%.0f")
  _, y = CreateSlider(panel, y, "Crit Damage Size", 36, 120, 2, "critFontSize", "%.0f")
  _, y = CreateSlider(panel, y, "Normal Digit Spacing", -10, 30, 1, "normalDigitSpacing", "%.0f")
  _, y = CreateSlider(panel, y, "Crit Digit Spacing", -10, 30, 1, "critDigitSpacing", "%.0f")
  _, y = CreateSlider(panel, y, "Drop Height (px)", 20, 150, 5, "startHeight", "%.0f")
  _, y = CreateSlider(panel, y, "Animation Intensity", 0.3, 2.5, 0.1, "animIntensity", "%.1fx")
  _, y = CreateSlider(panel, y, "Display Duration (sec)", 0.5, 3.0, 0.1, "durationSeconds", "%.1fs")

  -- Section header: Positioning
  local posHeader = panel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  posHeader:SetPoint("TOPLEFT", panel, "TOPLEFT", 20, y)
  posHeader:SetText("|cffffcc00Positioning|r")
  y = y - 18

  _, y = CreateSlider(panel, y, "Bloom Spread", 30, 200, 5, "bloomRadius", "%.0f")
  _, y = CreateSlider(panel, y, "Nameplate Offset (px)", 0, 80, 5, "nameplateOffset", "%.0f")

  -- Helper for checkboxes (template-free)
  local function MakeCheckbox(yPos, label, settingKey)
    local cb = CreateFrame("CheckButton", nil, panel)
    cb:SetPoint("TOPLEFT", panel, "TOPLEFT", 20, yPos)
    cb:SetSize(24, 24)

    local bg = cb:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints()
    bg:SetColorTexture(0.15, 0.15, 0.15, 0.8)

    local check = cb:CreateTexture(nil, "ARTWORK")
    check:SetSize(20, 20)
    check:SetPoint("CENTER")
    check:SetTexture("Interface\\Buttons\\UI-CheckBox-Check")
    cb:SetCheckedTexture(check)

    local border = cb:CreateTexture(nil, "OVERLAY")
    border:SetAllPoints()
    border:SetTexture("Interface\\Buttons\\UI-CheckBox-Up")

    local cbLabel = panel:CreateFontString(nil, "OVERLAY")
    cbLabel:SetPoint("LEFT", cb, "RIGHT", 6, 0)
    cbLabel:SetFont("Fonts\\FRIZQT__.TTF", 12, "OUTLINE")
    cbLabel:SetText(label)

    cb:SetChecked(CP.settings[settingKey])
    cb:SetScript("OnClick", function(self)
      CP.settings[settingKey] = self:GetChecked()
      Config:SaveSettings()
    end)
    return cb
  end

  -- Section header: Damage Types
  local dmgHeader = panel:CreateFontString(nil, "OVERLAY")
  dmgHeader:SetPoint("TOPLEFT", panel, "TOPLEFT", 20, y)
  dmgHeader:SetFont("Fonts\\FRIZQT__.TTF", 12, "OUTLINE")
  dmgHeader:SetText("|cffffcc00Damage Types|r")
  y = y - 20

  MakeCheckbox(y, "Auto-Attacks", "autoAttacksEnabled")
  y = y - 28
  MakeCheckbox(y, "Abilities", "abilitiesEnabled")
  y = y - 28
  MakeCheckbox(y, "DoTs (Damage over Time)", "dotsEnabled")

  -- Section header: Crit Sound
  y = y - 35
  local soundHeader = panel:CreateFontString(nil, "OVERLAY")
  soundHeader:SetPoint("TOPLEFT", panel, "TOPLEFT", 20, y)
  soundHeader:SetFont("Fonts\\FRIZQT__.TTF", 12, "OUTLINE")
  soundHeader:SetText("|cffffcc00Crit Sound|r")
  y = y - 18

  -- Sound selector: label showing current sound name
  local soundName = panel:CreateFontString(nil, "OVERLAY")
  soundName:SetPoint("TOPLEFT", panel, "TOPLEFT", 60, y)
  soundName:SetFont("Fonts\\FRIZQT__.TTF", 12, "OUTLINE")
  local currentIdx = CP.settings.critSoundId or 1
  local currentSound = CP.critSounds[currentIdx + 1] or CP.critSounds[1]
  soundName:SetText(currentSound.name)
  soundName:SetTextColor(1, 0.82, 0)

  -- Prev button
  local prevBtn = CreateFrame("Button", nil, panel)
  prevBtn:SetPoint("TOPLEFT", panel, "TOPLEFT", 20, y + 4)
  prevBtn:SetSize(30, 20)
  prevBtn:EnableMouse(true)
  local prevBg = prevBtn:CreateTexture(nil, "BACKGROUND")
  prevBg:SetAllPoints()
  prevBg:SetColorTexture(0.2, 0.2, 0.2, 0.9)
  local prevTxt = prevBtn:CreateFontString(nil, "OVERLAY")
  prevTxt:SetPoint("CENTER")
  prevTxt:SetFont("Fonts\\FRIZQT__.TTF", 14, "OUTLINE")
  prevTxt:SetText("<")

  -- Next button
  local nextBtn = CreateFrame("Button", nil, panel)
  nextBtn:SetPoint("LEFT", soundName, "RIGHT", 8, 0)
  nextBtn:SetSize(30, 20)
  nextBtn:EnableMouse(true)
  local nextBg = nextBtn:CreateTexture(nil, "BACKGROUND")
  nextBg:SetAllPoints()
  nextBg:SetColorTexture(0.2, 0.2, 0.2, 0.9)
  local nextTxt = nextBtn:CreateFontString(nil, "OVERLAY")
  nextTxt:SetPoint("CENTER")
  nextTxt:SetFont("Fonts\\FRIZQT__.TTF", 14, "OUTLINE")
  nextTxt:SetText(">")

  -- Preview button
  local previewBtn = CreateFrame("Button", nil, panel)
  previewBtn:SetPoint("LEFT", nextBtn, "RIGHT", 8, 0)
  previewBtn:SetSize(60, 20)
  previewBtn:EnableMouse(true)
  local previewBg = previewBtn:CreateTexture(nil, "BACKGROUND")
  previewBg:SetAllPoints()
  previewBg:SetColorTexture(0.2, 0.2, 0.2, 0.9)
  local previewTxt = previewBtn:CreateFontString(nil, "OVERLAY")
  previewTxt:SetPoint("CENTER")
  previewTxt:SetFont("Fonts\\FRIZQT__.TTF", 10, "OUTLINE")
  previewTxt:SetText("Preview")

  local function UpdateSoundDisplay()
    local idx = CP.settings.critSoundId or 1
    local entry = CP.critSounds[idx + 1] or CP.critSounds[1]
    soundName:SetText(entry.name)
  end

  prevBtn:SetScript("OnClick", function()
    local idx = CP.settings.critSoundId or 1
    idx = idx - 1
    if idx < 0 then idx = #CP.critSounds - 1 end
    CP.settings.critSoundId = idx
    UpdateSoundDisplay()
    Config:SaveSettings()
  end)

  nextBtn:SetScript("OnClick", function()
    local idx = CP.settings.critSoundId or 1
    idx = idx + 1
    if idx >= #CP.critSounds then idx = 0 end
    CP.settings.critSoundId = idx
    UpdateSoundDisplay()
    Config:SaveSettings()
  end)

  previewBtn:SetScript("OnClick", function()
    local idx = CP.settings.critSoundId or 1
    local entry = CP.critSounds[idx + 1]
    if entry then
      if entry.file then
        PlaySoundFile(entry.file, "SFX")
      elseif entry.soundID then
        PlaySound(entry.soundID, "SFX")
      end
    end
  end)
  previewBtn:SetScript("OnEnter", function() previewTxt:SetTextColor(1, 0.82, 0) end)
  previewBtn:SetScript("OnLeave", function() previewTxt:SetTextColor(1, 1, 1) end)

  -- Helper for buttons (bare frames, no templates)
  local function MakeButton(parent, xAnchor, yAnchor, width, label, onClick)
    local btn = CreateFrame("Button", nil, parent)
    btn:SetPoint("TOPLEFT", parent, "TOPLEFT", xAnchor, yAnchor)
    btn:SetSize(width, 26)
    btn:EnableMouse(true)

    local btnBg = btn:CreateTexture(nil, "BACKGROUND")
    btnBg:SetAllPoints()
    btnBg:SetColorTexture(0.15, 0.15, 0.15, 0.9)

    local btnBorder = btn:CreateTexture(nil, "BORDER")
    btnBorder:SetPoint("TOPLEFT", -1, 1)
    btnBorder:SetPoint("BOTTOMRIGHT", 1, -1)
    btnBorder:SetColorTexture(0.4, 0.4, 0.4, 1)
    btnBg:SetDrawLayer("ARTWORK")
    btnBorder:SetDrawLayer("BACKGROUND")

    local btnText = btn:CreateFontString(nil, "OVERLAY")
    btnText:SetPoint("CENTER")
    btnText:SetFont("Fonts\\FRIZQT__.TTF", 11, "OUTLINE")
    btnText:SetText(label)

    btn:SetScript("OnEnter", function() btnText:SetTextColor(1, 0.82, 0) end)
    btn:SetScript("OnLeave", function() btnText:SetTextColor(1, 1, 1) end)
    btn:SetScript("OnClick", onClick)
    return btn
  end

  y = y - 35
  MakeButton(panel, 20, y, 160, "Test Normal", function()
    CP:TestAnimation()
  end)

  MakeButton(panel, 195, y, 160, "Test Crit", function()
    if CP.animations then
      local frame = CP.animations:CreatePopupFrame(math.random(5000, 25000), "test")
      frame.textColor = {1, 0.82, 0, 1}
      frame.isCrit = true
      CP:PositionCenter(frame)
      frame:Show()
      CP.animations:PlaySequence(frame, CP.settings.durationSeconds)
    end
  end)

  -- Reset to Defaults button
  y = y - 35
  MakeButton(panel, 20, y, 340, "Reset All Settings to Defaults", function()
    local defaults = {
      position = "head", customX = 0, customY = 0, queueMode = "stack",
      durationSeconds = 1.5, autoAttacksEnabled = true, abilitiesEnabled = true,
      dotsEnabled = true, critSoundId = 1, customSounds = {},
      bloomRadius = 80, startHeight = 60, nameplateOffset = 30,
      normalFontSize = 48, critFontSize = 72, animIntensity = 1.0,
      normalDigitSpacing = 0, critDigitSpacing = 5,
    }
    for k, v in pairs(defaults) do
      CP.settings[k] = v
    end
    CP:RebuildSoundList()
    Config:SaveSettings()
    print("|cff00ff00Crit Drop:|r Settings reset to defaults. /reload to refresh the panel.")
  end)

  panel:Hide()  -- start hidden, /cp will show it
  CP.settingsPanel = panel

  -- Register in the addon settings menu (WoW 10.0+ Settings API)
  pcall(function()
    local category = Settings.RegisterCanvasLayoutCategory(panel, "Crit Drop")
    Settings.RegisterAddOnCategory(category)
    CP.settingsCategory = category
  end)
end

-- Toggle settings panel visibility
function Config:TogglePanel()
  if not CP.settingsPanel then
    self:CreatePanel()
  end

  if CP.settingsPanel:IsShown() then
    CP.settingsPanel:Hide()
  else
    CP.settingsPanel:Show()
  end
end

-- Save settings to SavedVariables
function Config:SaveSettings()
  if not CritPopupSettings then
    CritPopupSettings = {}
  end

  CritPopupSettings[UnitName("player")] = {
    position = CP.settings.position,
    customX = CP.settings.customX,
    customY = CP.settings.customY,
    queueMode = CP.settings.queueMode,
    durationSeconds = CP.settings.durationSeconds,
    autoAttacksEnabled = CP.settings.autoAttacksEnabled,
    abilitiesEnabled = CP.settings.abilitiesEnabled,
    dotsEnabled = CP.settings.dotsEnabled,
    critSoundId = CP.settings.critSoundId,
    bloomRadius = CP.settings.bloomRadius,
    startHeight = CP.settings.startHeight,
    nameplateOffset = CP.settings.nameplateOffset,
    normalFontSize = CP.settings.normalFontSize,
    critFontSize = CP.settings.critFontSize,
    animIntensity = CP.settings.animIntensity,
    normalDigitSpacing = CP.settings.normalDigitSpacing,
    critDigitSpacing = CP.settings.critDigitSpacing,
    customSounds = CP.settings.customSounds,
  }
end

-- Load settings from SavedVariables
function Config:LoadSettings()
  if not CritPopupSettings then
    CritPopupSettings = {}
  end

  local charName = UnitName("player")
  local saved = CritPopupSettings[charName]

  if saved then
    CP.settings.position = saved.position or CP.settings.position
    CP.settings.customX = saved.customX or CP.settings.customX
    CP.settings.customY = saved.customY or CP.settings.customY
    CP.settings.queueMode = saved.queueMode or CP.settings.queueMode
    CP.settings.durationSeconds = saved.durationSeconds or CP.settings.durationSeconds
    CP.settings.autoAttacksEnabled = saved.autoAttacksEnabled ~= false
    CP.settings.abilitiesEnabled = saved.abilitiesEnabled ~= false
    CP.settings.dotsEnabled = saved.dotsEnabled ~= false
    CP.settings.critSoundId = saved.critSoundId or CP.settings.critSoundId
    CP.settings.bloomRadius = saved.bloomRadius or CP.settings.bloomRadius
    CP.settings.startHeight = saved.startHeight or CP.settings.startHeight
    CP.settings.nameplateOffset = saved.nameplateOffset or CP.settings.nameplateOffset
    CP.settings.normalFontSize = saved.normalFontSize or CP.settings.normalFontSize
    CP.settings.critFontSize = saved.critFontSize or CP.settings.critFontSize
    CP.settings.animIntensity = saved.animIntensity or CP.settings.animIntensity
    CP.settings.normalDigitSpacing = saved.normalDigitSpacing or CP.settings.normalDigitSpacing
    CP.settings.critDigitSpacing = saved.critDigitSpacing or CP.settings.critDigitSpacing
    CP.settings.customSounds = saved.customSounds or CP.settings.customSounds
  end
end

CP.config = Config

-- Slash command registration
SLASH_CRITPOPUP1 = "/critpopup"
SLASH_CRITPOPUP2 = "/cp"

SlashCmdList["CRITPOPUP"] = function(msg)
  msg = msg or ""
  local cmd = msg:match("^(%S+)") or ""
  local arg = msg:match("^%S+%s+(.+)") or ""

  if cmd == "" or cmd == "toggle" then
    CP.config:TogglePanel()
  elseif cmd == "test" then
    CP:TestAnimation()
  elseif cmd == "testcrit" then
    if CP.animations then
      local frame = CP.animations:CreatePopupFrame(math.random(5000, 25000), "test")
      frame.textColor = {1, 0.82, 0, 1}
      frame.isCrit = true
      CP:PositionCenter(frame)
      frame:Show()
      CP.animations:PlaySequence(frame, CP.settings.durationSeconds)
    end
  elseif cmd == "addsound" then
    if arg == "" then
      print("|cffff0000Crit Drop:|r Usage: /cp addsound filename.ogg")
      return
    end
    -- Check it ends with .ogg
    if not arg:match("%.ogg$") then
      print("|cffff0000Crit Drop:|r Only .ogg files are supported.")
      return
    end
    -- Check for duplicates
    for _, existing in ipairs(CP.settings.customSounds) do
      if existing == arg then
        print("|cffff0000Crit Drop:|r '" .. arg .. "' is already registered.")
        return
      end
    end
    table.insert(CP.settings.customSounds, arg)
    CP:RebuildSoundList()
    CP.config:SaveSettings()
    print("|cff00ff00Crit Drop:|r Added custom sound '" .. arg .. "'. Select it in /cp settings.")
  elseif cmd == "removesound" then
    if arg == "" then
      print("|cffff0000Crit Drop:|r Usage: /cp removesound filename.ogg")
      return
    end
    local found = false
    for i, existing in ipairs(CP.settings.customSounds) do
      if existing == arg then
        table.remove(CP.settings.customSounds, i)
        found = true
        break
      end
    end
    if found then
      CP:RebuildSoundList()
      CP.config:SaveSettings()
      print("|cff00ff00Crit Drop:|r Removed custom sound '" .. arg .. "'.")
    else
      print("|cffff0000Crit Drop:|r '" .. arg .. "' not found in custom sounds.")
    end
  elseif cmd == "listsounds" then
    local customs = CP.settings.customSounds or {}
    if #customs == 0 then
      print("|cffff8000Crit Drop:|r No custom sounds registered.")
    else
      print("|cffff8000Crit Drop:|r Custom sounds:")
      for i, s in ipairs(customs) do
        print("  " .. i .. ". " .. s)
      end
    end
  else
    print("Crit Drop commands:")
    print("  /cp — Toggle settings panel")
    print("  /cp test — Test normal hit")
    print("  /cp testcrit — Test crit hit")
    print("  /cp addsound <file.ogg> — Register custom crit sound")
    print("  /cp removesound <file.ogg> — Remove custom sound")
    print("  /cp listsounds — List custom sounds")
  end
end

-- Wait for ADDON_LOADED so SavedVariables are available
-- Use RegisterEventCallback (12.0 safe) with Frame fallback
local function OnAddonLoaded(addonName)
  if addonName == ADDON_NAME then
    CP:Initialize()
    CP:RebuildSoundList()
    CP.config:CreatePanel()
  end
end

local ok = pcall(function()
  RegisterEventCallback("ADDON_LOADED", OnAddonLoaded)
end)

if not ok then
  -- Fallback: try Frame:RegisterEvent
  local loadFrame = CreateFrame("Frame")
  pcall(function()
    loadFrame:RegisterEvent("ADDON_LOADED")
    loadFrame:SetScript("OnEvent", function(self, event, addonName)
      OnAddonLoaded(addonName)
    end)
  end)
end

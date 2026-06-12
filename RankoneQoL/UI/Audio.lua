-------------------------------------------------------------------------------
-- 1. MODULE INITIALIZATION & DROPDOWN ANCHORS
-------------------------------------------------------------------------------
local addonName, RankoneQoL = ...

local RankoneUI_Dropdown = nil
local RankoneUI_ChannelDropdown = nil

-- Klick-Handler für die Todes-Sound-Auswahl
local function OnSoundClick(self)
    RankoneQoLEinstellungen.wunschSound = self.value
    UIDropDownMenu_SetSelectedValue(RankoneUI_Dropdown, self.value)
    PlaySound(self.value, RankoneQoLEinstellungen.wunschKanal or "Effects")
end

-- Klick-Handler für die Audiokanal-Auswahl
local function OnChannelClick(self)
    RankoneQoLEinstellungen.wunschKanal = self.value
    UIDropDownMenu_SetSelectedValue(RankoneUI_ChannelDropdown, self.value)
    PlaySound(RankoneQoLEinstellungen.wunschSound or 3325, self.value)
end

-------------------------------------------------------------------------------
-- 2. HILFSFUNKTION: MODERNISIERTE LAUTSTÄRKEN-SLIDER SCHMIEDE
-------------------------------------------------------------------------------
local function ErstelleAudioSlider(scrollChild, yPos, labelText, cVarName)
    local label = scrollChild:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    label:SetPoint("TOPLEFT", 4, yPos - 3)
    label:SetText(labelText)

    -- OPTIMIERT: Nutzt jetzt das flache, moderne Schieberegler-Template aus Dragonflight / TWW
    local slider = CreateFrame("Slider", "RankoneQoL_AudioVol_" .. cVarName, scrollChild, "MinimalSliderTemplate")
    slider:SetPoint("TOPLEFT", 195, yPos - 2)
    slider:SetSize(140, 10)
    slider:SetMinMaxValues(0.0, 1.0)
    slider:SetValueStep(0.05)
    
    slider:SetValue(tonumber(GetCVar(cVarName) or "0.5"))
    
    local valText = slider:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    valText:SetPoint("LEFT", slider, "RIGHT", 15, 0)
    valText:SetText(math.floor(slider:GetValue() * 100) .. "%")

    slider:SetScript("OnValueChanged", function(self, value)
        value = math.floor(value * 100) / 100
        SetCVar(cVarName, value)
        valText:SetText(math.floor(value * 100) .. "%")
    end)

    return slider
end

-------------------------------------------------------------------------------
-- 3. MAIN GENERATOR FOR TAB 3 (Modernes Interface-Layout)
-------------------------------------------------------------------------------
function RankoneQoL.GeneriereAudioOptionen(tab3Box)
    local scrollFrame = CreateFrame("ScrollFrame", "RankoneQoL_AudioScrollFrame", tab3Box, "UIPanelScrollFrameTemplate")
    scrollFrame:SetPoint("TOPLEFT", tab3Box, "TOPLEFT", 0, -5)
    scrollFrame:SetPoint("BOTTOMRIGHT", tab3Box, "BOTTOMRIGHT", -24, 5)

    local scrollChild = CreateFrame("Frame", nil, scrollFrame)
    scrollChild:SetSize(380, 420) 
    scrollFrame:SetScrollChild(scrollChild)

    -------------------------------------------------------------------------------
    -- SEKTION A: BLIZZARD SYSTEM-SOUND & LAUTSTÄRKE
    -------------------------------------------------------------------------------
    local enableSoundCB = CreateFrame("CheckButton", nil, scrollChild, "InterfaceOptionsCheckButtonTemplate")
    enableSoundCB:SetPoint("TOPLEFT", 0, 0)
    enableSoundCB.Text:SetText(RankoneQoL.L["SOUND_ENABLE"])
    enableSoundCB:SetChecked(GetCVar("Sound_EnableAllSound") == "1")
    enableSoundCB:SetScript("OnClick", function(self)
        local status = self:GetChecked() and "1" or "0"
        SetCVar("Sound_EnableAllSound", status)
    end)

    ErstelleAudioSlider(scrollChild, -40, RankoneQoL.L["VOL_MASTER"], "Sound_MasterVolume")
    ErstelleAudioSlider(scrollChild, -85, RankoneQoL.L["VOL_EFFECTS"], "Sound_SFXVolume")
    ErstelleAudioSlider(scrollChild, -130, RankoneQoL.L["VOL_MUSIC"], "Sound_MusicVolume")
    ErstelleAudioSlider(scrollChild, -175, RankoneQoL.L["VOL_AMBIENCE"], "Sound_AmbienceVolume")
    ErstelleAudioSlider(scrollChild, -220, RankoneQoL.L["VOL_DIALOG"], "Sound_DialogVolume")

    -------------------------------------------------------------------------------
    -- SEKTION B: RANKONE TODES-SOUND EFFEKTE
    -------------------------------------------------------------------------------
    local trennLinie = scrollChild:CreateTexture(nil, "ARTWORK")
    trennLinie:SetSize(340, 1)
    trennLinie:SetPoint("TOPLEFT", 4, -265)
    trennLinie:SetColorTexture(0.2, 0.2, 0.25, 0.4)

    local dropLabel = scrollChild:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    dropLabel:SetPoint("TOPLEFT", 4, -285)
    dropLabel:SetText(RankoneQoL.L["SOUND_LABEL"])

    RankoneUI_Dropdown = CreateFrame("Frame", "RankoneUI_DropdownFrame", scrollChild, "UIDropdownMenuTemplate")
    RankoneUI_Dropdown:SetPoint("TOPLEFT", 165, -280)
    UIDropDownMenu_SetWidth(RankoneUI_Dropdown, 160)

    UIDropDownMenu_Initialize(RankoneUI_Dropdown, function(self, level)
        local info = UIDropDownMenu_CreateInfo()
        info.func = OnSoundClick
        if RankoneQoL.SoundListe then
            for _, s in ipairs(RankoneQoL.SoundListe) do
                info.text = s.text info.value = s.value info.checked = (RankoneQoLEinstellungen.wunschSound == s.value)
                UIDropDownMenu_AddButton(info, level)
            end
        end
    end)
    UIDropDownMenu_SetSelectedValue(RankoneUI_Dropdown, RankoneQoLEinstellungen.wunschSound)

    local channelLabel = scrollChild:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    channelLabel:SetPoint("TOPLEFT", 4, -325)
    channelLabel:SetText(RankoneQoL.L["CHANNEL_LABEL"])

    RankoneUI_ChannelDropdown = CreateFrame("Frame", "RankoneUI_ChannelDropdownFrame", scrollChild, "UIDropdownMenuTemplate")
    RankoneUI_ChannelDropdown:SetPoint("TOPLEFT", 165, -320)
    UIDropDownMenu_SetWidth(RankoneUI_ChannelDropdown, 160)

    UIDropDownMenu_Initialize(RankoneUI_ChannelDropdown, function(self, level)
        local info = UIDropDownMenu_CreateInfo()
        info.func = OnChannelClick
        local kanaele = {
            { text = "Master", value = "Master" }, { text = "Sound Effects", value = "Effects" },
            { text = "Music", value = "Music" }, { text = "Ambience", value = "Ambience" },
            { text = "Dialog / Speech", value = "Dialog" }
        }
        for _, k in ipairs(kanaele) do
            info.text = k.text info.value = k.value info.checked = (RankoneQoLEinstellungen.wunschKanal == k.value)
            UIDropDownMenu_AddButton(info, level)
        end
    end)
    UIDropDownMenu_SetSelectedValue(RankoneUI_ChannelDropdown, RankoneQoLEinstellungen.wunschKanal)
end

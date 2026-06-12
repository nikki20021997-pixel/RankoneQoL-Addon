-------------------------------------------------------------------------------
-- 1. MODULE INITIALIZATION
-------------------------------------------------------------------------------
local addonName, RankoneQoL = ...

-------------------------------------------------------------------------------
-- 2. MO P-PFEIL-UMSCHALTER SCHMIEDE (Im neuen edlen Dark-Theme Style!)
-------------------------------------------------------------------------------
local function ErstelleMoPPfeilUmschalter(scrollChild, yPos, labelText, cVarName, optionenTabelle)
    local label = scrollChild:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    label:SetPoint("TOPLEFT", 4, yPos - 5)
    label:SetText(labelText)

    -- Der schicke, dunkle Center-Button (Umschalter-Box im modernen Look)
    local btn = CreateFrame("Button", nil, scrollChild, "BackdropTemplate")
    btn:SetSize(110, 20)
    btn:SetPoint("TOPLEFT", 210, yPos - 1)
    btn:SetBackdrop({
        bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
        edgeFile = "Interface\\Buttons\\WHITE8X8", edgeSize = 1,
        insets = { left = 1, right = 1, top = 1, bottom = 1 }
    })
    btn:SetBackdropColor(0.04, 0.04, 0.05, 0.8)
    btn:SetBackdropBorderColor(0.2, 0.2, 0.23, 1)

    -- Der Text-String im inneren der Box
    btn.Text = btn:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    btn.Text:SetPoint("CENTER", btn, "CENTER", 0, 0)

    -- Der linke goldene Pfeil-Knopf
    local leftBtn = CreateFrame("Button", nil, scrollChild)
    leftBtn:SetSize(16, 16)
    leftBtn:SetPoint("RIGHT", btn, "LEFT", -4, 0)
    leftBtn:SetNormalTexture("Interface\\Buttons\\UI-SpellbookIcon-PrevPage-Up")
    leftBtn:SetPushedTexture("Interface\\Buttons\\UI-SpellbookIcon-PrevPage-Down")
    leftBtn:SetDisabledTexture("Interface\\Buttons\\UI-SpellbookIcon-PrevPage-Disabled")

    -- Der rechte goldene Pfeil-Knopf
    local rightBtn = CreateFrame("Button", nil, scrollChild)
    rightBtn:SetSize(16, 16)
    rightBtn:SetPoint("LEFT", btn, "RIGHT", 4, 0)
    rightBtn:SetNormalTexture("Interface\\Buttons\\UI-SpellbookIcon-NextPage-Up")
    rightBtn:SetPushedTexture("Interface\\Buttons\\UI-SpellbookIcon-NextPage-Down")
    rightBtn:SetDisabledTexture("Interface\\Buttons\\UI-SpellbookIcon-NextPage-Disabled")

    local function AktualisiereWidget()
        local aktuellerWert = tonumber(GetCVar(cVarName) or "0")
        for idx, opt in ipairs(optionenTabelle) do
            if opt.value == aktuellerWert then
                btn.Text:SetText(opt.text)
                if idx == 1 then leftBtn:Disable() else leftBtn:Enable() end
                if idx == #optionenTabelle then rightBtn:Disable() else rightBtn:Enable() end
                return
            end
        end
        btn.Text:SetText("Custom")
        leftBtn:Enable()
        rightBtn:Enable()
    end

    local function AendereStufe(richtung)
        local aktuellerWert = tonumber(GetCVar(cVarName) or "0")
        local neuIndex = 1
        for idx, opt in ipairs(optionenTabelle) do
            if opt.value == aktuellerWert then
                neuIndex = idx + richtung
                break
            end
        end
        if neuIndex >= 1 and neuIndex <= #optionenTabelle then
            SetCVar(cVarName, optionenTabelle[neuIndex].value)
            AktualisiereWidget()
        end
    end

    leftBtn:SetScript("OnClick", function() AendereStufe(-1) end)
    rightBtn:SetScript("OnClick", function() AendereStufe(1) end)
    btn:SetScript("OnClick", function() AendereStufe(1) end)

    AktualisiereWidget()
    return btn
end

-------------------------------------------------------------------------------
-- 3. MAIN GENERATOR FOR TAB 4 (Wird aus RankoneUI.lua aufgerufen)
-------------------------------------------------------------------------------
function RankoneQoL.GeneriereGrafikOptionen(tab4Box)
    local scrollFrame = CreateFrame("ScrollFrame", "RankoneQoL_GrafikScrollFrame", tab4Box, "UIPanelScrollFrameTemplate")
    scrollFrame:SetPoint("TOPLEFT", tab4Box, "TOPLEFT", 0, -5)
    scrollFrame:SetPoint("BOTTOMRIGHT", tab4Box, "BOTTOMRIGHT", -24, 5)

    local scrollChild = CreateFrame("Frame", nil, scrollFrame)
    scrollChild:SetSize(380, 520) 
    scrollFrame:SetScrollChild(scrollChild)

    local de = (GetLocale() == "deDE")

    -- 1. Shadow Quality
    local schattenTexte = de and {{text="Aus", value=0}, {text="Niedrig", value=1}, {text="Gut", value=2}, {text="Hoch", value=3}, {text="Sehr Hoch", value=4}, {text="Ultra", value=5}} 
                             or {{text="Low", value=1}, {text="Fair", value=2}, {text="Good", value=3}, {text="High", value=4}, {text="Ultra", value=5}}
    ErstelleMoPPfeilUmschalter(scrollChild, 0, de and "Schattenqualität:" or "Shadow Quality:", "graphicsShadowQuality", schattenTexte)

    -- 2. Liquid Detail
    local wasserTexte = de and {{text="Niedrig", value=0}, {text="Gut", value=1}, {text="Hoch", value=2}, {text="Ultra", value=3}}
                            or {{text="Low", value=0}, {text="Fair", value=1}, {text="Good", value=2}, {text="Ultra", value=3}}
    ErstelleMoPPfeilUmschalter(scrollChild, -45, de and "Flüssigkeitendetails:" or "Liquid Detail:", "graphicsLiquidDetail", wasserTexte)

    -- 3. Particle Density
    local partikelTexte = de and {{text="Niedrig", value=0}, {text="Gut", value=1}, {text="Ultra", value=2}}
                              or {{text="Low", value=0}, {text="Good", value=1}, {text="Ultra", value=2}}
    ErstelleMoPPfeilUmschalter(scrollChild, -90, de and "Partikeldichte:" or "Particle Density:", "graphicsParticleDensity", partikelTexte)

    -- 4. SSAO
    local ssaoTexte = de and {{text="Aus", value=0}, {text="Gut", value=1}, {text="Ultra", value=2}}
                          or {{text="Disabled", value=0}, {text="Good", value=1}, {text="Ultra", value=2}}
    ErstelleMoPPfeilUmschalter(scrollChild, -135, "SSAO:", "graphicsSSAO", ssaoTexte)

    -- 5. Sunshafts
    local strahlenTexte = de and {{text="Aus", value=0}, {text="Gut", value=1}, {text="Hoch", value=2}}
                             or {{text="Disabled", value=0}, {text="Good", value=1}, {text="High", value=2}}
    ErstelleMoPPfeilUmschalter(scrollChild, -180, de and "Sonnenstrahlen:" or "Sunshafts:", "graphicsSunshafts", strahlenTexte)

    -- 6. Texture Resolution
    local texturTexte = de and {{text="Niedrig", value=0}, {text="Gut", value=1}, {text="Hoch", value=2}}
                            or {{text="Low", value=0}, {text="Fair", value=1}, {text="High", value=2}}
    ErstelleMoPPfeilUmschalter(scrollChild, -225, de and "Textureauflösung:" or "Texture Resolution:", "graphicsTextureResolution", texturTexte)

    -- 7. Projected Textures
    local projTexte = de and {{text="Deaktiviert", value=0}, {text="Aktiviert", value=1}}
                          or {{text="Disabled", value=0}, {text="Enabled", value=1}}
    ErstelleMoPPfeilUmschalter(scrollChild, -270, de and "Projizierte Texturen:" or "Projected Textures:", "projectedTextures", projTexte)

    -------------------------------------------------------------------------------
    -- SEKTION B: DIE DETAILS-SCHIEBEREGLER (Modernes, flaches Design!)
    -------------------------------------------------------------------------------
    local trennLinie = scrollChild:CreateTexture(nil, "ARTWORK")
    trennLinie:SetSize(340, 1)
    trennLinie:SetPoint("TOPLEFT", 4, -312)
    trennLinie:SetColorTexture(0.2, 0.2, 0.25, 0.4)

    -- 8. Environment Detail
    local envLabel = scrollChild:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    envLabel:SetPoint("TOPLEFT", 4, -330)
    envLabel:SetText(de and "Umgebungsdetails:" or "Environment Detail:")

    local envSlider = CreateFrame("Slider", "RankoneQoL_EnvSlider", scrollChild, "MinimalSliderTemplate")
    envSlider:SetPoint("TOPLEFT", 215, -327) envSlider:SetSize(140, 10)
    envSlider:SetMinMaxValues(1, 10) envSlider:SetValueStep(1)
    envSlider:SetValue(tonumber(GetCVar("graphicsEnvironmentDetail") or "5"))
    
    local envValText = envSlider:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    envValText:SetPoint("LEFT", envSlider, "RIGHT", 15, 0) envValText:SetText(envSlider:GetValue())

    envSlider:SetScript("OnValueChanged", function(self, value)
        value = math.floor(value) envValText:SetText(value)
        SetCVar("graphicsEnvironmentDetail", value)
    end)

    -- 9. Ground Clutter
    local gcLabel = scrollChild:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    gcLabel:SetPoint("TOPLEFT", 4, -370)
    gcLabel:SetText(de and "Bodenobjekte:" or "Ground Clutter:")

    local gcSlider = CreateFrame("Slider", "RankoneQoL_GCSlider", scrollChild, "MinimalSliderTemplate")
    gcSlider:SetPoint("TOPLEFT", 215, -367) gcSlider:SetSize(140, 10)
    gcSlider:SetMinMaxValues(1, 10) gcSlider:SetValueStep(1)
    gcSlider:SetValue(tonumber(GetCVar("graphicsGroundClutter") or "5"))
    
    local gcValText = gcSlider:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    gcValText:SetPoint("LEFT", gcSlider, "RIGHT", 15, 0) gcValText:SetText(gcSlider:GetValue())

    gcSlider:SetScript("OnValueChanged", function(self, value)
        value = math.floor(value) gcValText:SetText(value)
        SetCVar("graphicsGroundClutter", value)
    end)
end

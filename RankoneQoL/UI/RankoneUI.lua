-------------------------------------------------------------------------------
-- 1. SPEICHER-RESERVIERUNG & REGISTER (v0.8.2 Fancy Edition)
-------------------------------------------------------------------------------
local addonName, RankoneQoL = ...

RankoneQoL.HauptFenster = nil

local TabSeiten = {}
local TabKnoepfe = {}

-- Hilfsfunktion: Erstellt eine hochperformante Checkbox im modernen, flachen Design
local function ErstelleStandaloneCheckbox(parent, x, y, labelText, einstellungsKey)
    local cb = CreateFrame("CheckButton", nil, parent, "InterfaceOptionsCheckButtonTemplate")
    cb:SetPoint("TOPLEFT", x, y)
    
    -- FIXED v0.8.2: Das ungültige "NONE"-Flag wurde restlos entfernt! 
    -- Das verhindert den Absturz bei der Font-Zuweisung im Classic-Client zu 100%.
    if cb.Text then
        cb.Text:SetText(labelText)
        cb.Text:SetFont("Fonts\\FRIZQT__.TTF", 11)
        cb.Text:SetShadowOffset(1, -1)
        cb.Text:SetShadowColor(0, 0, 0, 0.8)
    end
    
    cb:SetChecked(RankoneQoLEinstellungen[einstellungsKey])
    cb:SetScript("OnClick", function(self)
        RankoneQoLEinstellungen[einstellungsKey] = self:GetChecked()
        if einstellungsKey == "zeigePerformance" and RankoneQoL.SchaltePerformanceAnzeigeUm then
            RankoneQoL.SchaltePerformanceAnzeigeUm()
        elseif einstellungsKey == "zeigeGoldSitzung" and RankoneQoL.SchalteGoldSitzungsAnzeigeUm then
            RankoneQoL.SchalteGoldSitzungsAnzeigeUm()
        elseif einstellungsKey == "autoILvl" and RankoneQoL.AktualisiereCharakterItemLevels then
            RankoneQoL.AktualisiereCharakterItemLevels()
        elseif einstellungsKey == "autoLoot" and RankoneQoL.AktualisiereAutoLootZustand then
            RankoneQoL.AktualisiereAutoLootZustand()
        end
    end)
    return cb
end

-------------------------------------------------------------------------------
-- 2. DATENBANK-INITIALIZIERUNG (Absicherung für alle Core-Systeme)
-------------------------------------------------------------------------------
function RankoneQoL.ErstelleDasMenue()
    if not RankoneQoLEinstellungen then
        RankoneQoLEinstellungen = { 
            autoVerkauf = true, autoReparatur = true, autoQuest = true, autoSkipCinematic = true, autoInvite = true, autoLoot = true,
            zeigePerformance = true, zeigeGoldSitzung = true, autoILvl = true, wwunschSound = 3325, wwunschKanal = "Effects", minimapWinkel = 45, schrottGoldGesamt = 0,
            perfX = 20, perfY = -200, perfScale = 1.0, goldX = 20, goldY = -250, ilvlFontSize = 12,
            mapCoords = true, mapMove = true, mapAlpha = false, mapFadeVal = 0.5,
            zeigeTooltipPreis = true, zeigeTooltipTalente = true, tooltipScaleVal = 1.0,
            
            tascheAutoBank = true, tascheAutoAuktion = true, tascheAutoHaendler = true,
            tascheScaleVal = 1.0, tascheSpalten = 8, tascheAbstand = 4
        }
    else
        if RankoneQoLEinstellungen.autoQuest == nil then RankoneQoLEinstellungen.autoQuest = true end
        if RankoneQoLEinstellungen.autoSkipCinematic == nil then RankoneQoLEinstellungen.autoSkipCinematic = true end
        if RankoneQoLEinstellungen.autoInvite == nil then RankoneQoLEinstellungen.autoInvite = true end
        if RankoneQoLEinstellungen.autoLoot == nil then RankoneQoLEinstellungen.autoLoot = true end
        if RankoneQoLEinstellungen.zeigePerformance == nil then RankoneQoLEinstellungen.zeigePerformance = true end
        if RankoneQoLEinstellungen.zeigeGoldSitzung == nil then RankoneQoLEinstellungen.zeigeGoldSitzung = true end
        if RankoneQoLEinstellungen.autoILvl == nil then RankoneQoLEinstellungen.autoILvl = true end
        if RankoneQoLEinstellungen.wunschSound == nil then RankoneQoLEinstellungen.wunschSound = 3325 end
        if RankoneQoLEinstellungen.wunschKanal == nil then RankoneQoLEinstellungen.wunschKanal = "Effects" end
        if RankoneQoLEinstellungen.minimapWinkel == nil then RankoneQoLEinstellungen.minimapWinkel = 45 end
        if RankoneQoLEinstellungen.perfX == nil then RankoneQoLEinstellungen.perfX = 20 end
        if RankoneQoLEinstellungen.perfY == nil then RankoneQoLEinstellungen.perfY = -200 end
        if RankoneQoLEinstellungen.goldX == nil then RankoneQoLEinstellungen.goldX = 20 end
        if RankoneQoLEinstellungen.goldY == nil then RankoneQoLEinstellungen.goldY = -250 end
        if RankoneQoLEinstellungen.perfScale == nil then RankoneQoLEinstellungen.perfScale = 1.0 end
        if RankoneQoLEinstellungen.ilvlFontSize == nil then RankoneQoLEinstellungen.ilvlFontSize = 12 end
        if RankoneQoLEinstellungen.schrottGoldGesamt == nil then RankoneQoLEinstellungen.schrottGoldGesamt = 0 end
        
        if RankoneQoLEinstellungen.mapCoords == nil then RankoneQoLEinstellungen.mapCoords = true end
        if RankoneQoLEinstellungen.mapMove == nil then RankoneQoLEinstellungen.mapMove = true end
        if RankoneQoLEinstellungen.mapAlpha == nil then RankoneQoLEinstellungen.mapAlpha = false end
        if RankoneQoLEinstellungen.mapFadeVal == nil then RankoneQoLEinstellungen.mapFadeVal = 0.5 end

        if RankoneQoLEinstellungen.zeigeTooltipPreis == nil then RankoneQoLEinstellungen.zeigeTooltipPreis = true end
        if RankoneQoLEinstellungen.zeigeTooltipTalente == nil then RankoneQoLEinstellungen.zeigeTooltipTalente = true end
        if RankoneQoLEinstellungen.tooltipScaleVal == nil then RankoneQoLEinstellungen.tooltipScaleVal = 1.0 end

        if RankoneQoLEinstellungen.tascheAutoBank == nil then RankoneQoLEinstellungen.tascheAutoBank = true end
        if RankoneQoLEinstellungen.tascheAutoAuktion == nil then RankoneQoLEinstellungen.tascheAutoAuktion = true end
        if RankoneQoLEinstellungen.tascheAutoHaendler == nil then RankoneQoLEinstellungen.tascheAutoHaendler = true end
        if RankoneQoLEinstellungen.tascheScaleVal == nil then RankoneQoLEinstellungen.tascheScaleVal = 1.0 end
        if RankoneQoLEinstellungen.tascheSpalten == nil then RankoneQoLEinstellungen.tascheSpalten = 8 end
        if RankoneQoLEinstellungen.tascheAbstand == nil then RankoneQoLEinstellungen.tascheAbstand = 4 end
    end
end

local function ZeigeTab(id)
    for i, seite in ipairs(TabSeiten) do
        if i == id then seite:Show() else seite:Hide() end
    end
    for i, knopf in ipairs(TabKnoepfe) do
        if i == id then 
            knopf:LockHighlight()
            knopf.text:SetTextColor(0.34, 0.37, 1.0) 
        else 
            knopf:UnlockHighlight()
            knopf.text:SetTextColor(1, 1, 1)
        end
    end
end
-------------------------------------------------------------------------------
-- 3. GRAFIK-AUFBAU (RANKONE UI WINDOW - VERTICAL SIDE-BAR LOOK v0.8.5)
-------------------------------------------------------------------------------
function RankoneQoL.ErstelleStandaloneUI()
    if RankoneQoL.HauptFenster then return end
    RankoneQoL.ErstelleDasMenue()

    -- Erstellt das Hauptfenster im modernen, abgerundeten Glas-Look (Bypasses Blizzard-TOC-Borders)
    local f = CreateFrame("Frame", "RankoneQoLStandaloneWindow", UIParent, "BackdropTemplate")
    f:SetSize(610, 400) -- Verbreitert, um dem linken Seitenmenü perfekten Platz zu bieten
    f:SetPoint("CENTER", UIParent, "CENTER")
    f:SetFrameStrata("HIGH")
    f:SetClampedToScreen(true)
    
    f:SetMovable(true) f:EnableMouse(true) f:RegisterForDrag("LeftButton")
    f:SetScript("OnDragStart", f.StartMoving) f:SetScript("OnDragStop", f.StopMovingOrSizing)

    -- Absolut edler, halbtransparenter Dark-Glas-Effekt synchron zu deiner Tasche!
    f:SetBackdrop({
        bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border", 
        edgeSize = 16,
        insets = { left = 4, right = 4, top = 4, bottom = 4 }
    })
    f:SetBackdropColor(0.03, 0.03, 0.05, 0.88)
    f:SetBackdropBorderColor(0.4, 0.4, 0.45, 0.6)

    f:SetScript("OnShow", function()
        ZeigeTab(1)
        if RankoneQoL.EntsperrePerformanceAnzeige then RankoneQoL.EntsperrePerformanceAnzeige() end
        if RankoneQoL.EntsperreGoldSitzungsAnzeige then RankoneQoL.EntsperreGoldSitzungsAnzeige() end
    end)
    f:SetScript("OnHide", function()
        if RankoneQoL.SperrePerformanceAnzeige then RankoneQoL.SperrePerformanceAnzeige() end
        if RankoneQoL.SperreGoldSitzungsAnzeige then RankoneQoL.SperreGoldSitzungsAnzeige() end
    end)

    -- Das Marken-Logo oben links im Gehäuse verankert
    local logo = f:CreateTexture(nil, "ARTWORK")
    logo:SetSize(22, 22)
    logo:SetPoint("TOPLEFT", f, "TOPLEFT", 16, -14)
    logo:SetTexture("Interface\\AddOns\\RankoneQoL\\logo")

    -- Flüssiger Titel-Schriftzug mit weichem Schattenwurf (Drop Shadow)
    local titelText = f:CreateFontString(nil, "ARTWORK", "GameFontNormalMed2")
    titelText:SetPoint("LEFT", logo, "RIGHT", 8, 0)
    titelText:SetText("|cFF8A94FF" .. RankoneQoL.L["TITEL"] .. "|r")
    titelText:SetShadowOffset(1, -1)
    titelText:SetShadowColor(0, 0, 0, 0.9)

    local closeBtn = CreateFrame("Button", nil, f, "UIPanelCloseButton")
    closeBtn:SetPoint("TOPRIGHT", f, "TOPRIGHT", -4, -4)

    -- Visuelle Trennlinie (Seitenmenü-Teiler auf der linken Achse)
    local trennLinie = f:CreateTexture(nil, "ARTWORK")
    trennLinie:SetSize(2, 340)
    trennLinie:SetPoint("TOPLEFT", f, "TOPLEFT", 145, -45)
    trennLinie:SetColorTexture(0.2, 0.2, 0.25, 0.4)

    -- Generiert alle 6 unsichtbaren Trägerframes für die Inhalte
    -- FIXED: Der Start-X-Anker rückt von 20 auf 165 nach rechts, um dem Seitenmenü auszuweichen!
    for i = 1, 6 do
        local subFrame = CreateFrame("Frame", nil, f)
        subFrame:SetSize(420, 320)
        subFrame:SetPoint("TOPLEFT", f, "TOPLEFT", 165, -60)
        subFrame:Hide()
        table.insert(TabSeiten, subFrame)
    end

    -- Tab-Namen lokalisiert abfragen
    local tabNamen = { "Automatisierung", "Anzeigen", "Audio", "Grafik", "Karte", "Taschen" }
    if GetLocale() ~= "deDE" then tabNamen = { "Automation", "Displays", "Audio", "Graphics", "Map", "Bags" } end

    -------------------------------------------------------------------------------
    -- HOCHMODERNES VERTIKALES REITER-SYSTEM (Linke Seitenleiste)
    -------------------------------------------------------------------------------
    for i, name in ipairs(tabNamen) do
        -- Erstellt ein flaches, minimalistisches Menüfeld statt der Blizzard-Reiter
        local tabBtn = CreateFrame("Button", "RankoneQoLTabButton" .. i, f, "BackdropTemplate")
        tabBtn:SetSize(125, 30)
        tabBtn:SetID(i)
        
        tabBtn:SetBackdrop({
            bgFile = "Interface\\Buttons\\WHITE8X8",
            edgeFile = "Interface\\Buttons\\WHITE8X8", edgeSize = 1,
            insets = { left = 0, right = 0, top = 0, bottom = 0 }
        })
        tabBtn:SetBackdropColor(0.1, 0.1, 0.12, 0.3)
        tabBtn:SetBackdropBorderColor(0.2, 0.2, 0.25, 0.2)

        -- Edler Text-Schriftzug mitten im Button mit Schatten
        tabBtn.text = tabBtn:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
        tabBtn.text:SetPoint("LEFT", tabBtn, "LEFT", 10, 0)
        tabBtn.text:SetText(name)
        tabBtn.text:SetShadowOffset(1, -1)
        tabBtn.text:SetShadowColor(0, 0, 0, 0.8)

        -- Hover-Highlighteffekt (Verfärbung beim Drüberfahren)
        tabBtn:SetScript("OnEnter", function(self)
            self:SetBackdropColor(0.2, 0.2, 0.25, 0.5)
            self:SetBackdropBorderColor(0.34, 0.37, 1.0, 0.4)
        end)
        tabBtn:SetScript("OnLeave", function(self)
            self:SetBackdropColor(0.1, 0.1, 0.12, 0.3)
            self:SetBackdropBorderColor(0.2, 0.2, 0.25, 0.2)
        end)
        
        tabBtn:SetScript("OnClick", function(self) ZeigeTab(self:GetID()) end)
        table.insert(TabKnoepfe, tabBtn)

        -- Stapelt die Buttons exakt untereinander an der linken Flanke
        if i == 1 then
            tabBtn:SetPoint("TOPLEFT", f, "TOPLEFT", 12, -60)
        else
            tabBtn:SetPoint("TOP", TabKnoepfe[i-1], "BOTTOM", 0, -6)
        end
    end
    -------------------------------------------------------------------------------
    -- 3c. TAB 1 CONTENT: AUTOMATISIERUNG
    -------------------------------------------------------------------------------
    local boxenKonfig1 = {
        { text = "AUTO_SELL", key = "autoVerkauf" },
        { text = "AUTO_REPAIR", key = "autoReparatur" },
        { text = "AUTO_QUEST", key = "autoQuest" },
        { text = "AUTO_CINEMATIC", key = "autoSkipCinematic" },
        { text = "AUTO_INVITE", key = "autoInvite" },
        { text = "AUTO_LOOT", key = "autoLoot" }
    }
    for idx, config in ipairs(boxenKonfig1) do
        local yVersatz = 0 - ((idx - 1) * 36)
        -- Verwendet das nach rechts gerückte Trägerframe von Box 1
        ErstelleStandaloneCheckbox(TabSeiten[1], 0, yVersatz, RankoneQoL.L[config.text], config.key)
    end

    -------------------------------------------------------------------------------
    -- 3d. TAB 2 CONTENT: ANZEIGEN
    -------------------------------------------------------------------------------
    ErstelleStandaloneCheckbox(TabSeiten[2], 0, 0, RankoneQoL.L["AUTO_PERF"], "zeigePerformance")
    ErstelleStandaloneCheckbox(TabSeiten[2], 0, -30, RankoneQoL.L["AUTO_GOLD"], "zeigeGoldSitzung")
    ErstelleStandaloneCheckbox(TabSeiten[2], 0, -60, RankoneQoL.L["AUTO_ILVL"], "autoILvl")
    ErstelleStandaloneCheckbox(TabSeiten[2], 0, -90, RankoneQoL.L["TT_PRICE"], "zeigeTooltipPreis")
    ErstelleStandaloneCheckbox(TabSeiten[2], 0, -120, RankoneQoL.L["TT_TALENT"], "zeigeTooltipTalente")
    ErstelleStandaloneCheckbox(TabSeiten[2], 0, -150, RankoneQoL.L["AUTO_MOVE_ALL"], "autoMoveAll")

    -- Slider 1: Leistungszähler-Größe
    local sliderLabel = TabSeiten[2]:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    sliderLabel:SetPoint("TOPLEFT", 4, -188) sliderLabel:SetText(RankoneQoL.L["SLIDER_SCALE"])
    sliderLabel:SetShadowOffset(1, -1) sliderLabel:SetShadowColor(0, 0, 0, 0.8)

    local slider = CreateFrame("Slider", "RankoneQoL_ScaleSlider", TabSeiten[2], "MinimalSliderTemplate")
    slider:SetPoint("TOPLEFT", 215, -185) slider:SetSize(140, 10)
    slider:SetMinMaxValues(0.5, 1.5) slider:SetValueStep(0.05)
    slider:SetValue(RankoneQoLEinstellungen.perfScale or 1.0)
    
    local sliderValText = slider:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    sliderValText:SetPoint("LEFT", slider, "RIGHT", 15, 0)
    sliderValText:SetText(math.floor((slider:GetValue()) * 100) .. "%")

    slider:SetScript("OnValueChanged", function(self, value)
        value = math.floor(value * 100) / 100
        RankoneQoLEinstellungen.perfScale = value
        sliderValText:SetText(math.floor(value * 100) .. "%")
        if RankoneQoL.PerformanceAnzeige then RankoneQoL.PerformanceAnzeige:SetScale(value) end
    end)

    -- Slider 2: iLvl Schriftgröße
    local fontSliderLabel = TabSeiten[2]:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    fontSliderLabel:SetPoint("TOPLEFT", 4, -213) fontSliderLabel:SetText(RankoneQoL.L["SLIDER_ILVL_FONT"])
    fontSliderLabel:SetShadowOffset(1, -1) fontSliderLabel:SetShadowColor(0, 0, 0, 0.8)

    local fontSlider = CreateFrame("Slider", "RankoneQoL_FontSlider", TabSeiten[2], "MinimalSliderTemplate")
    fontSlider:SetPoint("TOPLEFT", 215, -210) fontSlider:SetSize(140, 10)
    fontSlider:SetMinMaxValues(8, 20) fontSlider:SetValueStep(1)
    fontSlider:SetValue(RankoneQoLEinstellungen.ilvlFontSize or 12)
    
    local fontSliderValText = fontSlider:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    fontSliderValText:SetPoint("LEFT", fontSlider, "RIGHT", 15, 0)
    fontSliderValText:SetText(math.floor(fontSlider:GetValue()) .. " px")

    fontSlider:SetScript("OnValueChanged", function(self, value)
        value = math.floor(value)
        RankoneQoLEinstellungen.ilvlFontSize = value
        fontSliderValText:SetText(value .. " px")
        if RankoneQoL.AktualisiereCharakterItemLevels then RankoneQoL.AktualisiereCharakterItemLevels() end
        if RankoneQoL.AktualisiereTaschenLayout then RankoneQoL.AktualisiereTaschenLayout() end
    end)

    -- Slider 3: Tooltip-Skalierung
    local ttSliderLabel = TabSeiten[2]:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    ttSliderLabel:SetPoint("TOPLEFT", 4, -238) ttSliderLabel:SetText(RankoneQoL.L["TT_SCALE_LABEL"])
    ttSliderLabel:SetShadowOffset(1, -1) ttSliderLabel:SetShadowColor(0, 0, 0, 0.8)

    local ttSlider = CreateFrame("Slider", "RankoneQoL_TooltipScaleSlider", TabSeiten[2], "MinimalSliderTemplate")
    ttSlider:SetPoint("TOPLEFT", 215, -235) ttSlider:SetSize(140, 10)
    ttSlider:SetMinMaxValues(0.5, 1.5) ttSlider:SetValueStep(0.05)
    ttSlider:SetValue(RankoneQoLEinstellungen.tooltipScaleVal or 1.0)
    
    local ttSliderValText = ttSlider:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    ttSliderValText:SetPoint("LEFT", ttSlider, "RIGHT", 15, 0)
    ttSliderValText:SetText(math.floor((ttSlider:GetValue()) * 100) .. "%")

    ttSlider:SetScript("OnValueChanged", function(self, value)
        value = math.floor(value * 100) / 100
        RankoneQoLEinstellungen.tooltipScaleVal = value
        ttSliderValText:SetText(math.floor(value * 100) .. "%")
        if RankoneQoL.AktualisiereTooltipSkalierung then RankoneQoL.AktualisiereTooltipSkalierung() end
    end)
    -------------------------------------------------------------------------------
    -- 3e. TAB 3 CONTENT: AUDIO (Brücke zur Audio.lua)
    -------------------------------------------------------------------------------
    -- FIXED: Übergibt nun exakt das einzelne Box-Frame Nummer 3 statt der Tabelle!
    if RankoneQoL.GeneriereAudioOptionen then
        RankoneQoL.GeneriereAudioOptionen(TabSeiten[3])
    end

    -------------------------------------------------------------------------------
    -- 3f. TAB 4 CONTENT: GRAFIK (Brücke zur Graphics.lua)
    -------------------------------------------------------------------------------
    -- FIXED: Übergibt nun exakt das einzelne Box-Frame Nummer 4!
    if RankoneQoL.GeneriereGrafikOptionen then
        RankoneQoL.GeneriereGrafikOptionen(TabSeiten[4])
    end

    -------------------------------------------------------------------------------
    -- 3g. TAB 5 CONTENT: KARTE (Brücke zur Maps.lua)
    -------------------------------------------------------------------------------
    -- FIXED: Übergibt nun exakt das einzelne Box-Frame Nummer 5!
    if RankoneQoL.GeneriereKartenOptionen then
        RankoneQoL.GeneriereKartenOptionen(TabSeiten[5])
    end

    -------------------------------------------------------------------------------
    -- 3h. TAB 6 CONTENT: TASCHEN (v0.8.2 Live-Layout-Engine)
    -------------------------------------------------------------------------------
    -- Alle Taschen-Optionen liegen felsenfest verankert auf Box-Frame Nummer 6
    local tHeading = TabSeiten[6]:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    tHeading:SetPoint("TOPLEFT", 4, 15)
    tHeading:SetText("|cFF575EFF" .. RankoneQoL.L["BAG_SETTINGS"] .. "|r")
    tHeading:SetShadowOffset(1, -1)
    tHeading:SetShadowColor(0, 0, 0, 0.9)

    ErstelleStandaloneCheckbox(TabSeiten[6], 0, -20, RankoneQoL.L["OPT_BANK"], "tascheAutoBank")
    ErstelleStandaloneCheckbox(TabSeiten[6], 0, -55, RankoneQoL.L["OPT_AUCTION"], "tascheAutoAuktion")
    ErstelleStandaloneCheckbox(TabSeiten[6], 0, -90, RankoneQoL.L["OPT_MERCHANT"], "tascheAutoHaendler")

    local bagSliderLabel = TabSeiten[6]:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    bagSliderLabel:SetPoint("TOPLEFT", 4, -135)
    bagSliderLabel:SetText(RankoneQoL.L["SLIDER_BAG_SCALE"])
    bagSliderLabel:SetShadowOffset(1, -1) bagSliderLabel:SetShadowColor(0, 0, 0, 0.8)

    local bagSlider = CreateFrame("Slider", "RankoneQoL_BagScaleSlider", TabSeiten[6], "MinimalSliderTemplate")
    bagSlider:SetPoint("TOPLEFT", 215, -132)
    bagSlider:SetSize(140, 10)
    bagSlider:SetMinMaxValues(0.5, 1.5)
    bagSlider:SetValueStep(0.05)
    bagSlider:SetValue(RankoneQoLEinstellungen.tascheScaleVal or 1.0)
    
    local bagSliderValText = bagSlider:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    bagSliderValText:SetPoint("LEFT", bagSlider, "RIGHT", 15, 0)
    bagSliderValText:SetText(math.floor((bagSlider:GetValue()) * 100) .. "%")

    bagSlider:SetScript("OnValueChanged", function(self, value)
        value = math.floor(value * 100) / 100
        RankoneQoLEinstellungen.tascheScaleVal = value
        bagSliderValText:SetText(math.floor(value * 100) .. "%")
        if RankoneQoL_BagsFrame then
            RankoneQoL_BagsFrame:SetScale(value)
        end
    end)

    local colSliderLabel = TabSeiten[6]:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    colSliderLabel:SetPoint("TOPLEFT", 4, -170)
    colSliderLabel:SetText(RankoneQoL.L["SLIDER_COLUMNS"])
    colSliderLabel:SetShadowOffset(1, -1) colSliderLabel:SetShadowColor(0, 0, 0, 0.8)

    local colSlider = CreateFrame("Slider", "RankoneQoL_BagColSlider", TabSeiten[6], "MinimalSliderTemplate")
    colSlider:SetPoint("TOPLEFT", 215, -167)
    colSlider:SetSize(140, 10)
    colSlider:SetMinMaxValues(6, 16)
    colSlider:SetValueStep(1)
    colSlider:SetValue(RankoneQoLEinstellungen.tascheSpalten or 8)
    
    local colSliderValText = colSlider:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    colSliderValText:SetPoint("LEFT", colSlider, "RIGHT", 15, 0)
    colSliderValText:SetText(math.floor(colSlider:GetValue()))

    colSlider:SetScript("OnValueChanged", function(self, value)
        value = math.floor(value)
        RankoneQoLEinstellungen.tascheSpalten = value
        colSliderValText:SetText(value)
    end)

    local spaceSliderLabel = TabSeiten[6]:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    spaceSliderLabel:SetPoint("TOPLEFT", 4, -205)
    spaceSliderLabel:SetText(RankoneQoL.L["SLIDER_SPACING"])
    spaceSliderLabel:SetShadowOffset(1, -1) spaceSliderLabel:SetShadowColor(0, 0, 0, 0.8)

    local spaceSlider = CreateFrame("Slider", "RankoneQoL_BagSpaceSlider", TabSeiten[6], "MinimalSliderTemplate")
    spaceSlider:SetPoint("TOPLEFT", 215, -202)
    spaceSlider:SetSize(140, 10)
    spaceSlider:SetMinMaxValues(0, 12)
    spaceSlider:SetValueStep(1)
    spaceSlider:SetValue(RankoneQoLEinstellungen.tascheAbstand or 4)
    
    local spaceSliderValText = spaceSlider:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    spaceSliderValText:SetPoint("LEFT", spaceSlider, "RIGHT", 15, 0)
    spaceSliderValText:SetText(math.floor(spaceSlider:GetValue()) .. " px")

    spaceSlider:SetScript("OnValueChanged", function(self, value)
        value = math.floor(value)
        RankoneQoLEinstellungen.tascheAbstand = value
        spaceSliderValText:SetText(value .. " px")
    end)

    -------------------------------------------------------------------------------
    -- 3i. UNTERER SYSTEM-BEREICH (Modernisiertes linkes Button-Layout)
    -------------------------------------------------------------------------------
    local addonVersion = "0.8.2"
    if C_AddOns and C_AddOns.GetAddOnMetadata then
        addonVersion = C_AddOns.GetAddOnMetadata("RankoneQoL", "Version") or addonVersion
    elseif GetAddOnMetadata then
        addonVersion = GetAddOnMetadata("RankoneQoL", "Version") or addonVersion
    end
    
    local versionText = f:CreateFontString(nil, "ARTWORK", "GameFontDisableSmall")
    versionText:SetPoint("BOTTOMLEFT", f, "BOTTOMLEFT", 16, 16)
    versionText:SetText("|cFF888888v" .. addonVersion .. "|r")

    local reloadBtn = CreateFrame("Button", "RankoneQoL_ReloadBtn", f, "BackdropTemplate")
    reloadBtn:SetSize(125, 24)
    reloadBtn:SetPoint("BOTTOMLEFT", f, "BOTTOMLEFT", 12, 36)
    
    reloadBtn:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8X8",
        edgeFile = "Interface\\Buttons\\WHITE8X8", edgeSize = 1,
        insets = { left = 0, right = 0, top = 0, bottom = 0 }
    })
    reloadBtn:SetBackdropColor(0.18, 0.12, 0.12, 0.5)
    reloadBtn:SetBackdropBorderColor(0.4, 0.2, 0.2, 0.4)

    reloadBtn.text = reloadBtn:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    reloadBtn.text:SetPoint("CENTER", reloadBtn, "CENTER", 0, 0)
    if GetLocale() == "deDE" then reloadBtn.text:SetText("Interface Reload") else reloadBtn.text:SetText("Reload UI") end
    reloadBtn.text:SetShadowOffset(1, -1)
    reloadBtn.text:SetShadowColor(0, 0, 0, 0.8)

    reloadBtn:SetScript("OnEnter", function(self)
        self:SetBackdropColor(0.35, 0.15, 0.15, 0.7)
        self:SetBackdropBorderColor(0.8, 0.3, 0.3, 0.6)
        self.text:SetTextColor(1, 0.4, 0.4)
    end)
    reloadBtn:SetScript("OnLeave", function(self)
        self:SetBackdropColor(0.18, 0.12, 0.12, 0.5)
        self:SetBackdropBorderColor(0.4, 0.2, 0.2, 0.4)
        self.text:SetTextColor(1, 1, 1)
    end)
    
    reloadBtn:SetScript("OnClick", function() ReloadUI() end)

 f:Hide()
 RankoneQoL.HauptFenster = f
 tinsert(UISpecialFrames, "RankoneQoLStandaloneWindow")
 
 if RankoneQoL.ErstellePerformanceAnzeige then RankoneQoL.ErstellePerformanceAnzeige() end
 if RankoneQoL.ErstelleGoldSitzungsAnzeige then RankoneQoL.ErstelleGoldSitzungsAnzeige() end
end

-------------------------------------------------------------------------------
-- 4. LIVE-HOOKS & TOGGLE SYSTEM
-------------------------------------------------------------------------------
function RankoneQoL.AktualisiereStandaloneZahlen(schrott, einnahmen, ausgaben)
    if RankoneQoL.HoleGoldSitzungsTexte then
        local goldSitzungEingText, goldSitzungAusgText = RankoneQoL.HoleGoldSitzungsTexte()
        if goldSitzungEingText and einnahmen then goldSitzungEingText:SetText("|cFF00FF96+ |r" .. GetCoinTextureString(einnahmen)) end
        if goldSitzungAusgText and ausgaben then goldSitzungAusgText:SetText("|cFFFF4D4D- |r" .. GetCoinTextureString(ausgaben)) end
    end
end

function RankoneQoL.ToggleStandaloneUI()
    if not RankoneQoL.HauptFenster then RankoneQoL.ErstelleStandaloneUI() end
    if RankoneQoL.HauptFenster:IsShown() then
        RankoneQoL.HauptFenster:Hide()
    else
        RankoneQoL.HauptFenster:Show()
        if RankoneQoL.HoleAktuelleSitzungsZahlen then
            local schrott, ein, aus = RankoneQoL.HoleAktuelleSitzungsZahlen()
            RankoneQoL.AktualisiereStandaloneZahlen(schrott, ein, aus)
        end
    end
end

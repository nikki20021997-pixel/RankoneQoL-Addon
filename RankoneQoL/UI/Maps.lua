-------------------------------------------------------------------------------
-- 1. MODULE INITIALIZATION & CORE VARIABLES
-------------------------------------------------------------------------------
local addonName, RankoneQoL = ...

local spielerText = nil
local mausText = nil
local alphaSliderValText = nil

-------------------------------------------------------------------------------
-- 2. LIVE COORDINATES & TRANSPARENCY ENGINE (0% CPU Last wenn Karte zu ist!)
-------------------------------------------------------------------------------
local function AktualisiereKartenSchleife(self, elapsed)
    -- A. KOORDINATEN LOGIK
    if RankoneQoLEinstellungen and RankoneQoLEinstellungen.mapCoords then
        local mapID = C_Map.GetBestMapForUnit("player")
        if mapID then
            local position = C_Map.GetPlayerMapPosition(mapID, "player")
            if position then
                local x, y = position:GetXY()
                if x and y and x > 0 and y > 0 then
                    spielerText:SetText(string.format("Spieler: |cFF00FF96%.1f, %.1f|r", x * 100, y * 100))
                else
                    spielerText:SetText("Spieler: |cFFFF4D4D--|r")
                end
            else
                spielerText:SetText("Spieler: |cFFFF4D4D--|r")
            end
        end

        if WorldMapDetailFrame and WorldMapDetailFrame:IsPercentWithMouseOver() then
            local cx, cy = GetCursorPosition()
            local es = WorldMapDetailFrame:GetEffectiveScale()
            local x = (cx / es - WorldMapDetailFrame:GetLeft()) / WorldMapDetailFrame:GetWidth()
            local y = (WorldMapDetailFrame:GetTop() - cy / es) / WorldMapDetailFrame:GetHeight()

            if x >= 0 and x <= 1 and y >= 0 and y <= 1 then
                mausText:SetText(string.format("Maus: |cFF00FF96%.1f, %.1f|r", x * 100, y * 100))
            else
                mausText:SetText("")
            end
        else
            mausText:SetText("")
        end
    else
        if spielerText then spielerText:SetText("") end
        if mausText then mausText:SetText("") end
    end

    -- B. AUTOMATISCHE TRANSPARENZ BEIM LAUFEN LOGIK
    if RankoneQoLEinstellungen and RankoneQoLEinstellungen.mapAlpha then
        local geschwindigkeit = GetUnitSpeed("player") or 0
        if geschwindigkeit > 0 then
            WorldMapFrame:SetAlpha(RankoneQoLEinstellungen.mapFadeVal or 0.5)
        else
            WorldMapFrame:SetAlpha(1.0)
        end
    else
        WorldMapFrame:SetAlpha(1.0)
    end
end

-------------------------------------------------------------------------------
-- 3. THE WORLD MAP UNCHAINED LOGIC
-------------------------------------------------------------------------------
function RankoneQoL.AktualisiereKartenZustand()
    if not WorldMapFrame then return end

    if RankoneQoLEinstellungen and RankoneQoLEinstellungen.mapMove then
        if WorldMapFrame.SetAttribute then
            WorldMapFrame:SetAttribute("UIPanelLayout-defined", nil)
        end
        if UIPanelWindows and UIPanelWindows["WorldMapFrame"] then
            UIPanelWindows["WorldMapFrame"] = nil
        end
        
        WorldMapFrame:SetMovable(true)
        WorldMapFrame:EnableMouse(true)
        WorldMapFrame.isMaximized = false
        
        if WorldMapTitleButton then
            WorldMapTitleButton:RegisterForDrag("LeftButton")
            WorldMapTitleButton:SetScript("OnDragStart", function() WorldMapFrame:StartMoving() end)
            WorldMapTitleButton:SetScript("OnDragStop", function() WorldMapFrame:StopMovingOrSizing() end)
        end
    else
        WorldMapFrame:SetMovable(false)
        if WorldMapTitleButton then
            WorldMapTitleButton:SetScript("OnDragStart", nil)
            WorldMapTitleButton:SetScript("OnDragStop", nil)
        end
    end
end

-------------------------------------------------------------------------------
-- 4. MAIN GENERATOR FOR TAB 5 (Karten-Optionen UI - Modernisiert!)
-------------------------------------------------------------------------------
function RankoneQoL.GeneriereKartenOptionen(tab5Box)
    -- Checkbox 1: Koordinaten
    local cb1 = CreateFrame("CheckButton", nil, tab5Box, "InterfaceOptionsCheckButtonTemplate")
    cb1:SetPoint("TOPLEFT", 0, 0)
    cb1.Text:SetText(RankoneQoL.L["MAP_COORDS"])
    cb1:SetChecked(RankoneQoLEinstellungen.mapCoords)
    cb1:SetScript("OnClick", function(self)
        RankoneQoLEinstellungen.mapCoords = self:GetChecked()
    end)

    -- Checkbox 2: Karte bewegen
    local cb2 = CreateFrame("CheckButton", nil, tab5Box, "InterfaceOptionsCheckButtonTemplate")
    cb2:SetPoint("TOPLEFT", 0, -35)
    cb2.Text:SetText(RankoneQoL.L["MAP_MOVE"])
    cb2:SetChecked(RankoneQoLEinstellungen.mapMove)
    cb2:SetScript("OnClick", function(self)
        RankoneQoLEinstellungen.mapMove = self:GetChecked()
        if RankoneQoL.AktualisiereKartenZustand then RankoneQoL.AktualisiereKartenZustand() end
    end)

    -- Checkbox 3: Karten-Transparenz
    local cb3 = CreateFrame("CheckButton", nil, tab5Box, "InterfaceOptionsCheckButtonTemplate")
    cb3:SetPoint("TOPLEFT", 0, -75)
    cb3.Text:SetText(RankoneQoL.L["MAP_ALPHA"])
    cb3:SetChecked(RankoneQoLEinstellungen.mapAlpha)
    cb3:SetScript("OnClick", function(self)
        RankoneQoLEinstellungen.mapAlpha = self:GetChecked()
    end)

    -- SLIDER: Durchsichtigkeit beim Laufen (Modernisiertes Template!)
    local alphaLabel = tab5Box:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    alphaLabel:SetPoint("TOPLEFT", 4, -120)
    alphaLabel:SetText(RankoneQoL.L["MAP_FADE"])

    local alphaSlider = CreateFrame("Slider", "RankoneQoL_MapAlphaSlider", tab5Box, "MinimalSliderTemplate")
    alphaSlider:SetPoint("TOPLEFT", 215, -117) alphaSlider:SetSize(140, 10)
    alphaSlider:SetMinMaxValues(0.1, 1.0) alphaSlider:SetValueStep(0.05)
    
    if not RankoneQoLEinstellungen.mapFadeVal then RankoneQoLEinstellungen.mapFadeVal = 0.5 end
    alphaSlider:SetValue(RankoneQoLEinstellungen.mapFadeVal)
    
    alphaSliderValText = alphaSlider:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    alphaSliderValText:SetPoint("LEFT", alphaSlider, "RIGHT", 15, 0)
    alphaSliderValText:SetText(math.floor(alphaSlider:GetValue() * 100) .. "%")

    alphaSlider:SetScript("OnValueChanged", function(self, value)
        value = math.floor(value * 100) / 100
        RankoneQoLEinstellungen.mapFadeVal = value
        alphaSliderValText:SetText(math.floor(value * 100) .. "%")
    end)
end

-------------------------------------------------------------------------------
-- 5. WELTKARTEN HOOKS INITIALISIERUNG
-------------------------------------------------------------------------------
if not spielerText and WorldMapFrame then
    spielerText = WorldMapFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    spielerText:SetPoint("BOTTOMLEFT", WorldMapFrame, "BOTTOMLEFT", 20, 10)
    spielerText:SetFont("Fonts\\FRIZQT__.TTF", 13, "OUTLINE")

    mausText = WorldMapFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    mausText:SetPoint("BOTTOMLEFT", spielerText, "BOTTOMRIGHT", 20, 0)
    mausText:SetFont("Fonts\\FRIZQT__.TTF", 13, "OUTLINE")

    WorldMapFrame:HookScript("OnUpdate", AktualisiereKartenSchleife)
    
    WorldMapFrame:HookScript("OnShow", function()
        if RankoneQoL.AktualisiereKartenZustand then RankoneQoL.AktualisiereKartenZustand() end
    end)
    
    if hooksecurefunc then
        hooksecurefunc(WorldMapFrame, "OnMapChanged", function()
            if RankoneQoL.AktualisiereKartenZustand then RankoneQoL.AktualisiereKartenZustand() end
        end)
    end
end

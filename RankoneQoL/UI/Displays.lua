-------------------------------------------------------------------------------
-- 1. MODULE INITIALIZATION & CORE VARIABLES
-------------------------------------------------------------------------------
local addonName, RankoneQoL = ...

-- Frames für die UI-Anzeigen registrieren
RankoneQoL.PerformanceAnzeige = nil
RankoneQoL.GoldSitzungsAnzeige = nil

local goldSitzungEingText = nil
local goldSitzungAusgText = nil

local iLvlLabels = {}

-- Speicher-Variablen für das verlässliche Gold-Sitzungs-System
local startGoldBeimLogin = 0
local sessionEinnahmen = 0
local sessionAusgaben = 0

local rQoLSloets = {
    { id = 1,  name = "CharacterHeadSlot" },
    { id = 2,  name = "CharacterNeckSlot" },
    { id = 3,  name = "CharacterShoulderSlot" },
    { id = 15, name = "CharacterBackSlot" },
    { id = 5,  name = "CharacterChestSlot" },
    { id = 4,  name = "CharacterShirtSlot" },
    { id = 19, name = "CharacterTabardSlot" },
    { id = 9,  name = "CharacterWristSlot" },
    { id = 10, name = "CharacterHandsSlot" },
    { id = 6,  name = "CharacterWaistSlot" },
    { id = 7,  name = "CharacterLegsSlot" },
    { id = 8,  name = "CharacterFeetSlot" },
    { id = 11, name = "CharacterFinger0Slot" },
    { id = 12, name = "CharacterFinger1Slot" },
    { id = 13, name = "CharacterTrinket0Slot" },
    { id = 14, name = "CharacterTrinket1Slot" },
    { id = 16, name = "CharacterMainHandSlot" },
    { id = 17, name = "CharacterSecondaryHandSlot" },
    { id = 18, name = "CharacterRangedSlot" }
}

-------------------------------------------------------------------------------
-- 2. AUTOMATISCHE INTERFACE-UMSCHALTER (Aus RankoneUI.lua gesteuert)
-------------------------------------------------------------------------------
function RankoneQoL.SchaltePerformanceAnzeigeUm()
    if not RankoneQoL.PerformanceAnzeige then return end
    if RankoneQoLEinstellungen and RankoneQoLEinstellungen.zeigePerformance then
        RankoneQoL.PerformanceAnzeige:Show()
    else
        RankoneQoL.PerformanceAnzeige:Hide()
    end
end

function RankoneQoL.SchalteGoldSitzungsAnzeigeUm()
    if not RankoneQoL.GoldSitzungsAnzeige then return end
    if RankoneQoLEinstellungen and RankoneQoLEinstellungen.zeigeGoldSitzung then
        RankoneQoL.GoldSitzungsAnzeige:Show()
    else
        RankoneQoL.GoldSitzungsAnzeige:Hide()
    end
end

-- Brücken-Funktionen für das Hauptmenü
function RankoneQoL.HoleGoldSitzungsTexte()
    return goldSitzungEingText, goldSitzungAusgText
end

function RankoneQoL.HoleAktuelleSitzungsZahlen()
    if not RankoneQoLEinstellungen then return 0, 0, 0 end
    return RankoneQoLEinstellungen.schrottGoldGesamt or 0, sessionEinnahmen, sessionAusgaben
end

-------------------------------------------------------------------------------
-- 3. INTERFACE GRAPHICS ASSEMBLY & DYNAMIC BACKDROP ENGINE
-------------------------------------------------------------------------------
local function ErstelleHintergrundUndRaender(frame, breite, hoehe)
    frame:SetSize(breite, hoehe)
    frame:SetBackdrop({
        bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
        edgeFile = "Interface\\Buttons\\WHITE8X8", edgeSize = 1,
        insets = { left = 1, right = 1, top = 1, bottom = 1 }
    })
    frame:SetBackdropColor(0, 0, 0, 0)
    frame:SetBackdropBorderColor(0, 0, 0, 0)
end

function RankoneQoL.EntsperrePerformanceAnzeige()
    local f = RankoneQoL.PerformanceAnzeige
    if f then 
        f:EnableMouse(true)
        f:SetBackdropColor(0.34, 0.37, 0.99, 0.3) 
        f:SetScript("OnDragStart", f.StartMoving)
    end
end

function RankoneQoL.SperrePerformanceAnzeige()
    local f = RankoneQoL.PerformanceAnzeige
    if f then 
        f:EnableMouse(false)
        f:SetBackdropColor(0, 0, 0, 0)
        f:SetScript("OnDragStart", nil)
    end
end

function RankoneQoL.EntsperreGoldSitzungsAnzeige()
    local f = RankoneQoL.GoldSitzungsAnzeige
    if f then 
        f:EnableMouse(true)
        f:SetBackdropColor(0.05, 0.05, 0.05, 0.85)
        f:SetBackdropBorderColor(0.34, 0.37, 0.99, 0.8)
        f:SetScript("OnDragStart", f.StartMoving)
    end
end

function RankoneQoL.SperreGoldSitzungsAnzeige()
    local f = RankoneQoL.GoldSitzungsAnzeige
    if f then 
        f:EnableMouse(false)
        f:SetBackdropColor(0, 0, 0, 0)
        f:SetBackdropBorderColor(0, 0, 0, 0)
        f:SetScript("OnDragStart", nil)
    end
end
-------------------------------------------------------------------------------
-- 4. GOLD SITZUNGS ENGINE (Erstellung & Aktualisierung)
-------------------------------------------------------------------------------
local function AktualisiereGoldAnzeige()
    if not RankoneQoL.GoldSitzungsAnzeige then return end

    goldSitzungEingText:SetText("|cFF00FF96+ |r" .. GetCoinTextureString(sessionEinnahmen))
    goldSitzungAusgText:SetText("|cFFFF4D4D- |r" .. GetCoinTextureString(sessionAusgaben))
    
    if RankoneQoL.AktualisiereStandaloneZahlen and RankoneQoLEinstellungen then
        RankoneQoL.AktualisiereStandaloneZahlen(RankoneQoLEinstellungen.schrottGoldGesamt or 0, sessionEinnahmen, sessionAusgaben)
    end
end

function RankoneQoL.ErstelleGoldSitzungsAnzeige()
    if RankoneQoL.GoldSitzungsAnzeige then return end
    RankoneQoL.ErstelleDasMenue()

    local goldFrame = CreateFrame("Frame", "RankoneQoLGoldFrame", UIParent, "BackdropTemplate")
    ErstelleHintergrundUndRaender(goldFrame, 150, 48)
    goldFrame:SetPoint("TOPLEFT", UIParent, "TOPLEFT", RankoneQoLEinstellungen.goldX or 20, RankoneQoLEinstellungen.goldY or -250)
    goldFrame:SetFrameStrata("MEDIUM")
    goldFrame:SetClampedToScreen(true)
    
    goldFrame:SetMovable(true)
    goldFrame:RegisterForDrag("LeftButton")
    goldFrame:SetScript("OnDragStart", goldFrame.StartMoving)
    
    goldFrame:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        local scale = self:GetEffectiveScale()
        RankoneQoLEinstellungen.goldX = self:GetLeft()
        RankoneQoLEinstellungen.goldY = self:GetTop() - (UIParent:GetHeight() / scale)
    end)

    goldSitzungEingText = goldFrame:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
    goldSitzungEingText:SetPoint("TOPLEFT", goldFrame, "TOPLEFT", 10, -8)

    goldSitzungAusgText = goldFrame:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
    goldSitzungAusgText:SetPoint("TOPLEFT", goldFrame, "TOPLEFT", 10, -26)

    RankoneQoL.GoldSitzungsAnzeige = goldFrame
    RankoneQoL.SchalteGoldSitzungsAnzeigeUm()
    RankoneQoL.SperreGoldSitzungsAnzeige()
    AktualisiereGoldAnzeige()
end

-------------------------------------------------------------------------------
-- 5. PERFORMANCE COUNTER ENGINE (FPS & Ping Anzeige)
-------------------------------------------------------------------------------
function RankoneQoL.ErstellePerformanceAnzeige()
    if RankoneQoL.PerformanceAnzeige then return end
    RankoneQoL.ErstelleDasMenue()

    local perfFrame = CreateFrame("Frame", "RankoneQoLPerfFrame", UIParent, "BackdropTemplate")
    ErstelleHintergrundUndRaender(perfFrame, 90, 22)
    perfFrame:SetPoint("TOPLEFT", UIParent, "TOPLEFT", RankoneQoLEinstellungen.perfX or 20, RankoneQoLEinstellungen.perfY or -200)
    perfFrame:SetFrameStrata("MEDIUM")
    perfFrame:SetClampedToScreen(true)
    perfFrame:SetScale(RankoneQoLEinstellungen.perfScale or 1.0)
    
    perfFrame:SetMovable(true)
    perfFrame:RegisterForDrag("LeftButton")
    perfFrame:SetScript("OnDragStart", perfFrame.StartMoving)
    
    perfFrame:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        local scale = self:GetEffectiveScale()
        RankoneQoLEinstellungen.perfX = self:GetLeft()
        RankoneQoLEinstellungen.perfY = self:GetTop() - (UIParent:GetHeight() / scale)
    end)

    local text = perfFrame:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
    text:SetPoint("CENTER", perfFrame, "CENTER")
    
    local zeitSeitLetztemUpdate = 0
    perfFrame:SetScript("OnUpdate", function(self, elapsed)
        zeitSeitLetztemUpdate = zeitSeitLetztemUpdate + elapsed
        if zeitSeitLetztemUpdate >= 1.0 then 
            local fps = math.floor(GetFramerate())
            local _, _, pingHome, pingWorld = GetNetStats()
            local aktuellerPing = math.max(pingHome, pingWorld)
            
            local fpsFarbe = "|cFF00FF96"
            if fps < 30 then fpsFarbe = "|cFFFF4D4D" elseif fps < 60 then fpsFarbe = "|cFFFFD100" end
            local pingFarbe = "|cFF00FF96"
            if aktuellerPing > 200 then pingFarbe = "|cFFFF4D4D" elseif aktuellerPing > 100 then pingFarbe = "|cFFFFD100" end
            
            text:SetText(fpsFarbe .. fps .. " fps|r " .. pingFarbe .. aktuellerPing .. " ms|r")
            zeitSeitLetztemUpdate = 0
        end
    end)

    RankoneQoL.PerformanceAnzeige = perfFrame
    RankoneQoL.SchaltePerformanceAnzeigeUm()
    RankoneQoL.SperrePerformanceAnzeige()
end

-------------------------------------------------------------------------------
-- 6. ITEM LEVEL CHARACTER FRAME ENGINE (v0.8.5 Realtime Upgraded)
-------------------------------------------------------------------------------
function RankoneQoL.AktualisiereCharakterItemLevels()
    if not (RankoneQoLEinstellungen and RankoneQoLEinstellungen.autoILvl) then
        for _, slot in ipairs(rQoLSloets) do
            if iLvlLabels[slot.name] then iLvlLabels[slot.name]:SetText("") end
        end
        return
    end

    if not CharacterFrame or not CharacterFrame:IsShown() then return end
    local wunschGroesse = RankoneQoLEinstellungen and RankoneQoLEinstellungen.ilvlFontSize or 12

    for _, slot in ipairs(rQoLSloets) do
        local bstBtn = _G[slot.name]
        if bstBtn then
            if not iLvlLabels[slot.name] then
                iLvlLabels[slot.name] = bstBtn:CreateFontString(nil, "OVERLAY")
                iLvlLabels[slot.name]:SetPoint("TOPRIGHT", bstBtn, "TOPRIGHT", -2, -2)
            end

            iLvlLabels[slot.name]:SetFont("Fonts\\FRIZQT__.TTF", wunschGroesse, "OUTLINE")
            local itemLink = GetInventoryItemLink("player", slot.id)
            if itemLink then
                local _, _, qualitaet = GetItemInfo(itemLink)
                
                -- FIXED: Nutzt jetzt die präzise API für echte aufgewertete MoP-Gegenstandsstufen!
                local getDetailedItemLevel = C_Item and C_Item.GetDetailedItemLevelInfo or GetDetailedItemLevelInfo
                local iLvl = getDetailedItemLevel(itemLink)

                if iLvl and iLvl > 0 and slot.id ~= 4 and slot.id ~= 19 then
                    local r, g, b = GetItemQualityColor(qualitaet or 1)
                    local hexFarbe = string.format("FF%02x%02x%02x", r * 255, g * 255, b * 255)
                    iLvlLabels[slot.name]:SetText("|c" .. hexFarbe .. iLvl .. "|r")
                else
                    iLvlLabels[slot.name]:SetText("")
                end
            else
                iLvlLabels[slot.name]:SetText("")
            end
        end
    end
end

-------------------------------------------------------------------------------
-- 7. REINE EVENT-ENGINE & LIVE GOLD TRACKER
-------------------------------------------------------------------------------
local displayEventFrame = CreateFrame("Frame")
displayEventFrame:RegisterEvent("PLAYER_LOGIN")
displayEventFrame:RegisterEvent("PLAYER_MONEY")
displayEventFrame:RegisterEvent("UNIT_INVENTORY_CHANGED")
-- NEU: Lauscht zusätzlich felsenfest auf das offizielle Ausrüstungs-Wechsel-Event
displayEventFrame:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")

displayEventFrame:SetScript("OnEvent", function(self, event, arg1, arg2)
    if event == "PLAYER_LOGIN" then
        startGoldBeimLogin = GetMoney()
        sessionEinnahmen = 0
        sessionAusgaben = 0

        RankoneQoL.ErstellePerformanceAnzeige()
        RankoneQoL.ErstelleGoldSitzungsAnzeige()

    elseif event == "PLAYER_MONEY" then
        local aktuellesGold = GetMoney()
        local goldDifferenzSeitLogin = aktuellesGold - startGoldBeimLogin
        
        if goldDifferenzSeitLogin >= 0 then
            sessionEinnahmen = goldDifferenzSeitLogin
            sessionAusgaben = 0
        else
            sessionEinnahmen = 0
            sessionAusgaben = math.abs(goldDifferenzSeitLogin)
        end
        
        AktualisiereGoldAnzeige()

    elseif (event == "UNIT_INVENTORY_CHANGED" and arg1 == "player") or event == "PLAYER_EQUIPMENT_CHANGED" then
        -- FIXED: Ein winziger 0.05-Sekunden-Airbag gibt der C++ Engine Zeit, den Link-Cache zu leeren.
        -- Das zwingt das iLvl beim Rüstungstauschen zu einem absolut fehlerfreien LIVE-Echtzeitupdate!
        C_Timer.After(0.05, function()
            if RankoneQoL.AktualisiereCharakterItemLevels then 
                RankoneQoL.AktualisiereCharakterItemLevels() 
            end
        end)
    end
end)

if CharacterFrame then
    CharacterFrame:HookScript("OnShow", function()
        C_Timer.After(0.1, function() 
            if RankoneQoL.AktualisiereCharakterItemLevels then 
                RankoneQoL.AktualisiereCharakterItemLevels() 
            end 
        end)
    end)
end
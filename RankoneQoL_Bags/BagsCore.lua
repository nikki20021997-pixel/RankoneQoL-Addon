-------------------------------------------------------------------------------
-- 1. SYSTEM INITIALIZATION & CORE REFS (v0.8.3 Fancy Edition)
-------------------------------------------------------------------------------
local addonName, RankoneQoL = ...
local CoreObject = _G["RankoneQoL"] or RankoneQoL

RankoneQoL_BagsFrame = nil
RankoneQoL.InventarSlotsTabelle = {}
local goldTextString = nil
local currencyFrameContainer = nil
RankoneQoL_BagsSearchBox = nil 

-- NEU v0.8.3: Hochmodernes "Fancy Glass"-Design mit abgerundeten Ecken
function RankoneQoL.StyleTaschenFenster(frame, breite, hoehe)
    if not frame then return end
    frame:SetSize(breite, hoehe)
    
    -- Nutzt Blizzards hochedles, abgerundetes Toolkit-Template für den Rahmen
    frame:SetBackdrop({
        bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border", 
        edgeSize = 16,
        insets = { left = 4, right = 4, top = 4, bottom = 4 }
    })
    
    -- Ein wunderschöner, tiefdunkler semi-transparenter Glas-Effekt
    frame:SetBackdropColor(0.03, 0.03, 0.05, 0.88)
    frame:SetBackdropBorderColor(0.4, 0.4, 0.45, 0.6) -- Edler Anthrazit-Rand
end

function RankoneQoL.ErstelleDasTaschenFenster()
    if RankoneQoL_BagsFrame then return end

    local f = CreateFrame("Frame", "RankoneQoL_MasterBagFrame", UIParent, "BackdropTemplate")
    RankoneQoL.StyleTaschenFenster(f, 342, 450)
    f:SetPoint("BOTTOMRIGHT", UIParent, "BOTTOMRIGHT", -50, 100)
    f:SetFrameStrata("HIGH")
    f:SetClampedToScreen(true)

    f:SetMovable(true) f:EnableMouse(true) f:RegisterForDrag("LeftButton")
    f:SetScript("OnDragStart", f.StartMoving) f:SetScript("OnDragStop", f.StopMovingOrSizing)

    -- Visuelle Aufwertung: Titel mit feinem Schatteneffekt
    local titel = f:CreateFontString(nil, "ARTWORK", "GameFontNormalMed2")
    titel:SetPoint("TOPLEFT", f, "TOPLEFT", 16, -14)
    titel:SetText("|cFF8A94FFRankøne|r |cFFFFFFFFInventory|r")

    local closeBtn = CreateFrame("Button", nil, f, "UIPanelCloseButton")
    closeBtn:SetPoint("TOPRIGHT", f, "TOPRIGHT", -4, -4)
    closeBtn:SetScript("OnClick", function() ToggleAllBags() end)

    -- Unsere Suchleiste (Echtzeit-Eingabefeld)
    RankoneQoL_BagsSearchBox = CreateFrame("EditBox", "RankoneQoL_BagSearch", f, "BagSearchBoxTemplate")
    RankoneQoL_BagsSearchBox:SetSize(125, 18)
    RankoneQoL_BagsSearchBox:SetPoint("TOPRIGHT", f, "TOPRIGHT", -36, -14)
    RankoneQoL_BagsSearchBox:SetFrameLevel(f:GetFrameLevel() + 5)

    RankoneQoL_BagsSearchBox:SetScript("OnTextChanged", function(self)
        SearchBoxTemplate_OnTextChanged(self)
        if RankoneQoL.StarteGegenstandsSuche then
            RankoneQoL.StarteGegenstandsSuche()
        end
    end)

    currencyFrameContainer = CreateFrame("Frame", nil, f)
    currencyFrameContainer:SetSize(180, 20)
    currencyFrameContainer:SetPoint("BOTTOMLEFT", f, "BOTTOMLEFT", 16, 12)

    local goldZentrierer = CreateFrame("Frame", nil, f)
    goldZentrierer:SetSize(200, 20)
    goldZentrierer:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", -16, 12)

    goldTextString = goldZentrierer:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    goldTextString:SetPoint("RIGHT", goldZentrierer, "RIGHT", 0, 0)
    goldTextString:SetText(GetCoinTextureString(GetMoney()))

    local goldEvent = CreateFrame("Frame")
    goldEvent:RegisterEvent("PLAYER_MONEY")
    goldEvent:SetScript("OnEvent", function()
        if goldTextString then goldTextString:SetText(GetCoinTextureString(GetMoney())) end
    end)

    local gespeicherteSkalierung = RankoneQoLEinstellungen and RankoneQoLEinstellungen.tascheScaleVal or 1.0
    f:SetScale(gespeicherteSkalierung)

    RankoneQoL_BagsFrame = f
    f:Hide()
end

-------------------------------------------------------------------------------
-- 2. BLIZZARD SYSTEM OVERRIDE (Wurzel-Steuerung für Tasten & Leiste)
-------------------------------------------------------------------------------
function ToggleAllBags()
    if not RankoneQoL_BagsFrame then RankoneQoL.ErstelleDasTaschenFenster() end
    
    if RankoneQoL_BagsFrame:IsShown() then
        PlaySound(SOUNDKIT.IG_BACKPACK_CLOSE or 863)
        RankoneQoL_BagsFrame:Hide()
    else
        local aktuelleSkalierung = RankoneQoLEinstellungen and RankoneQoLEinstellungen.tascheScaleVal or 1.0
        RankoneQoL_BagsFrame:SetScale(aktuelleSkalierung)
        
        PlaySound(SOUNDKIT.IG_BACKPACK_OPEN or 862)
        RankoneQoL_BagsFrame:Show()
        RankoneQoL.GeneriereTaschenGrid()
        
        if RankoneQoL_BagsSearchBox then
            RankoneQoL_BagsSearchBox:SetText("")
            if RankoneQoL.StarteGegenstandsSuche then RankoneQoL.StarteGegenstandsSuche() end
        end
    end
end

_G["ToggleAllBags"] = ToggleAllBags
_G["OpenAllBags"] = function() if not RankoneQoL_BagsFrame or not RankoneQoL_BagsFrame:IsShown() then ToggleAllBags() end end
_G["CloseAllBags"] = function() if RankoneQoL_BagsFrame and RankoneQoL_BagsFrame:IsShown() then ToggleAllBags() end end
_G["ToggleBag"] = function(bagID) ToggleAllBags() end

local secureHookFrame = CreateFrame("Frame")
secureHookFrame:RegisterEvent("PLAYER_LOGIN")
secureHookFrame:RegisterEvent("ADDON_LOADED")
secureHookFrame:SetScript("OnEvent", function(self, event)
    if event == "PLAYER_LOGIN" then
        SetOverrideBindingClick(self, true, "B", "RankoneQoL_BagsKeyButton")
    end
    if UpdateBagButtonHighlight then UpdateBagButtonHighlight = function() end end
end)

local keyBtn = CreateFrame("Button", "RankoneQoL_BagsKeyButton")
keyBtn:SetScript("OnClick", function() ToggleAllBags() end)

-------------------------------------------------------------------------------
-- 3. THE SUB-PARENT GRID ENGINE (DYNAMISCHE LAYOUT-MATRIX v0.8.3)
-------------------------------------------------------------------------------
local TaschenMutterFrames = {}
local WaehrungsAnzeigeButtons = {}

function RankoneQoL.StarteGegenstandsSuche()
    if not RankoneQoL_BagsSearchBox or #RankoneQoL.InventarSlotsTabelle == 0 then return end
    
    local suchText = string.lower(RankoneQoL_BagsSearchBox:GetText() or "")
    local getItemInfoFunc = C_Container and C_Container.GetContainerItemInfo or GetContainerItemInfo

    if suchText == "" then
        for _, btn in ipairs(RankoneQoL.InventarSlotsTabelle) do
            if btn.icon then btn.icon:SetAlpha(1) end
            if btn.searchOverlay then btn.searchOverlay:Hide() end
        end
        return
    end

    for _, btn in ipairs(RankoneQoL.InventarSlotsTabelle) do
        local itemInfo = getItemInfoFunc(btn.bagID, btn.slotID)
        local treffer = false

        if itemInfo and itemInfo.hyperlink then
            local itemName = GetItemInfo(itemInfo.hyperlink)
            if itemName and string.find(string.lower(itemName), suchText, 1, true) then
                treffer = true
            end
        end

        if treffer then
            if btn.icon then btn.icon:SetAlpha(1) end
            if btn.searchOverlay then btn.searchOverlay:Hide() end
        else
            if btn.icon then btn.icon:SetAlpha(0.2) end
            if btn.searchOverlay then btn.searchOverlay:Show() end
        end
    end
end

function RankoneQoL.AktualisiereTaschenLayout()
    if not RankoneQoL_BagsFrame or #RankoneQoL.InventarSlotsTabelle == 0 then return end

    local spaltenAnzahl = RankoneQoLEinstellungen and RankoneQoLEinstellungen.tascheSpalten or 8
    local abstand = RankoneQoLEinstellungen and RankoneQoLEinstellungen.tascheAbstand or 4
    local slotGroesse = 37         
    local startX = 14 -- Leicht eingerückt für den abgerundeten Fenster-Style          
    local startY = -64             

    local berechneteFensterBreite = startX + (spaltenAnzahl * (slotGroesse + abstand)) - abstand + startX
    RankoneQoL_BagsFrame:SetWidth(berechneteFensterBreite)

    local fontSize = RankoneQoLEinstellungen and RankoneQoLEinstellungen.ilvlFontSize or 12

    for index, btn in ipairs(RankoneQoL.InventarSlotsTabelle) do
        local aktuellerSlotIndex = index - 1
        local spalte = aktuellerSlotIndex % spaltenAnzahl
        local zeile = math.floor(aktuellerSlotIndex / spaltenAnzahl)

        local posX = startX + (spalte * (slotGroesse + abstand))
        local posY = startY - (zeile * (slotGroesse + abstand))

        btn:ClearAllPoints()
        btn:SetPoint("TOPLEFT", RankoneQoL_BagsFrame, "TOPLEFT", posX, posY)

        if btn.ilvlText then
            local fontName, _, fontFlags = btn.ilvlText:GetFont()
            if fontName then
                btn.ilvlText:SetFont(fontName, fontSize, fontFlags)
            end
        end
    end

    local gesamtZeilen = math.ceil(#RankoneQoL.InventarSlotsTabelle / spaltenAnzahl)
    local berechneteFensterHoehe = math.abs(startY) + (gesamtZeilen * (slotGroesse + abstand)) + 42 
    RankoneQoL_BagsFrame:SetHeight(berechneteFensterHoehe)
end

function RankoneQoL.GeneriereTaschenGrid()
    if not RankoneQoL_BagsFrame then return end

    for _, button in ipairs(RankoneQoL.InventarSlotsTabelle) do
        button:Hide()
    end
    RankoneQoL.InventarSlotsTabelle = {}

    local spaltenAnzahl = RankoneQoLEinstellungen and RankoneQoLEinstellungen.tascheSpalten or 8
    local abstand = RankoneQoLEinstellungen and RankoneQoLEinstellungen.tascheAbstand or 4
    local slotGroesse = 37         
    local startX = 14              
    local startY = -64             

    local berechneteFensterBreite = startX + (spaltenAnzahl * (slotGroesse + abstand)) - abstand + startX
    RankoneQoL_BagsFrame:SetWidth(berechneteFensterBreite)

    local temporaereButtonListe = {}
    local getSlotsFunc = C_Container and C_Container.GetContainerNumSlots or GetContainerNumSlots
    local getItemInfoFunc = C_Container and C_Container.GetContainerItemInfo or GetContainerItemInfo
    
    for tascheID = 0, 4 do
        local anzahlSlots = getSlotsFunc(tascheID)
        if anzahlSlots and anzahlSlots > 0 then
            
            local blizzParentFrame = _G["ContainerFrame" .. (tascheID + 1)]
            if blizzParentFrame and blizzParentFrame:IsShown() then 
                blizzParentFrame:Hide() 
            end

            if not TaschenMutterFrames[tascheID] then
                local mutter = CreateFrame("Frame", "RankoneQoL_BagMother_"..tascheID, RankoneQoL_BagsFrame)
                mutter:SetID(tascheID)
                TaschenMutterFrames[tascheID] = mutter
            end

            for platzID = 1, anzahlSlots do
                local buttonName = string.format("RankoneQoL_BagButton_%d_%d", tascheID, platzID)
                local btn = _G[buttonName]

                if not btn then
                    btn = CreateFrame("Button", buttonName, TaschenMutterFrames[tascheID], "ContainerFrameItemButtonTemplate")
                    btn:SetSize(slotGroesse, slotGroesse)
                end

                btn:SetID(platzID)
                btn.bagID = tascheID
                btn.slotID = platzID

                table.insert(temporaereButtonListe, btn)
            end
        end
    end

    -- 2. SCHRITT: Wir ordnen die Knöpfe im Grid an und zeichnen die Grafiken manuell!
    local fontSize = RankoneQoLEinstellungen and RankoneQoLEinstellungen.ilvlFontSize or 12

    for index, btn in ipairs(temporaereButtonListe) do
        local aktuellerSlotIndex = index - 1
        local spalte = aktuellerSlotIndex % spaltenAnzahl
        local zeile = math.floor(aktuellerSlotIndex / spaltenAnzahl)

        local posX = startX + (spalte * (slotGroesse + abstand))
        local posY = startY - (zeile * (slotGroesse + abstand))

        btn:ClearAllPoints()
        btn:SetPoint("TOPLEFT", RankoneQoL_BagsFrame, "TOPLEFT", posX, posY)
        
        if btn.NewItemTexture then btn.NewItemTexture:Hide() end
        if btn.Flash then btn.Flash:Hide() end
        if btn.BattlepayItemTexture then btn.BattlepayItemTexture:Hide() end

        -- Erstellt das iLvl-Textfeld auf dem Taschen-Button
        if not btn.ilvlText then
            btn.ilvlText = btn:CreateFontString(nil, "OVERLAY", "NumberFontNormal")
            btn.ilvlText:SetPoint("TOPLEFT", btn, "TOPLEFT", 2, -2)
        end
        btn.ilvlText:SetFont("Fonts\\FRIZQT__.TTF", fontSize, "OUTLINE")
        btn.ilvlText:SetText("")

        -- MASTER-REPARATUR v0.8.5: Rein texturbasiertes High-End Leuchten!
        -- Absolut immun gegen XML-Fehler, da wir Blizzards universelle "CheckButtonHilight"-Textur laden.
        -- Sie wird als OVERLAY auf Schicht-Ebene 7 gezeichnet und bildet einen intensiven Lichtkranz nach außen!
        if not btn.fancyGlow then
            btn.fancyGlow = btn:CreateTexture(nil, "OVERLAY", nil, 7)
            btn.fancyGlow:SetSize(slotGroesse + 4, slotGroesse + 4) -- Erzeugt den perfekten Außen-Schein
            btn.fancyGlow:SetPoint("CENTER", btn, "CENTER", 0, 0)
            btn.fancyGlow:SetTexture("Interface\\Buttons\\CheckButtonHilight")
            btn.fancyGlow:SetBlendMode("ADD") -- Zündet echte, strahlende Neon-Lichtkraft
        end
        btn.fancyGlow:Hide()

        -------------------------------------------------------------------------------
        -- VISUELLES ITEM-RENDERING (Aus der C_Container Datenbank)
        -------------------------------------------------------------------------------
        local itemInfo = getItemInfoFunc(btn.bagID, btn.slotID)
        local iconTex = _G[btn:GetName() .. "IconTexture"]
        local countText = _G[btn:GetName() .. "Count"]
        local border = btn.IconBorder or _G[btn:GetName() .. "IconBorder"]

        if itemInfo and itemInfo.hyperlink then
            if iconTex then 
                iconTex:SetTexture(itemInfo.iconFileID or itemInfo.texture) 
                iconTex:SetAlpha(1)
                iconTex:Show()
            end
            
            if countText then
                local stack = itemInfo.stackCount or 1
                if stack > 1 then
                    countText:SetText(stack)
                    countText:Show()
                else
                    countText:SetText("")
                    countText:Hide()
                end
            end
            
            if border then
                local quality = itemInfo.quality
                if quality and quality > 1 then
                    local r, g, b = GetItemQualityColor(quality)
                    border:SetVertexColor(r, g, b, 1)
                    border:Show()
                else
                    border:Hide()
                end
            end

            -- Der exklusive Ausrüstungs-Filter steuert das Leuchten
            if IsEquippableItem(itemInfo.hyperlink) then
                local _, _, quality = GetItemInfo(itemInfo.hyperlink)
                
                if quality and quality > 1 then
                    local getDetailedItemLevel = C_Item and C_Item.GetDetailedItemLevelInfo or GetDetailedItemLevelInfo
                    local effektivesILvl = getDetailedItemLevel(itemInfo.hyperlink)
                    
                    if effektivesILvl and effektivesILvl > 0 then
                        local r, g, b = GetItemQualityColor(quality)
                        btn.ilvlText:SetTextColor(r, g, b)
                        btn.ilvlText:SetText(effektivesILvl)
                        
                        -- AKTIVIERUNG: Färbt die leuchtende Aura mit 100% ungefilterter Raritäts-Power!
                        btn.fancyGlow:SetVertexColor(r, g, b, 0.85) -- Wunderschöner, satter Neon-Lichtschleier (85%)
                        btn.fancyGlow:Show()
                    end
                end
            end
        else
            if iconTex then iconTex:SetTexture(nil); iconTex:Hide() end
            if countText then countText:SetText(""); countText:Hide() end
            if border then border:Hide() end
            if btn.fancyGlow then btn.fancyGlow:Hide() end
        end

        btn:SetScript("OnEnter", nil)
        btn:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_LEFT")
            local hasItem = GameTooltip:SetBagItem(self.bagID, self.slotID)
            if hasItem then GameTooltip:Show() end
        end)
        btn:SetScript("OnLeave", function()
            GameTooltip:Hide()
        end)

        btn:Show()
        table.insert(RankoneQoL.InventarSlotsTabelle, btn)
    end

    -------------------------------------------------------------------------------
    -- 3b. WÄHRUNGS-RENDERING (Vordergrund-Tracker mit unfehlbarem ID-Tooltip)
    -------------------------------------------------------------------------------
    for _, btn in ipairs(WaehrungsAnzeigeButtons) do
        btn:Hide()
    end
    WaehrungsAnzeigeButtons = {}

    if currencyFrameContainer then
        currencyFrameContainer:SetFrameLevel(RankoneQoL_BagsFrame:GetFrameLevel() + 5)
        
        local waehrungsX = 0
        local maxBackpackCurrencies = 3 

        for i = 1, maxBackpackCurrencies do
            local info = C_CurrencyInfo and C_CurrencyInfo.GetBackpackCurrencyInfo or GetBackpackCurrencyInfo
            local name, count, icon, currencyID = info(i)
            
            if name and count and count > 0 then
                local buttonName = "RankoneQoL_CurrencyButton_" .. i
                local cBtn = _G[buttonName]

                if not cBtn then
                    cBtn = CreateFrame("Button", buttonName, currencyFrameContainer)
                    cBtn:SetSize(60, 20)

                    cBtn.icon = cBtn:CreateTexture(nil, "OVERLAY")
                    cBtn.icon:SetSize(14, 14)
                    cBtn.icon:SetPoint("RIGHT", cBtn, "RIGHT", 0, 0)

                    cBtn.text = cBtn:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
                    cBtn.text:SetPoint("RIGHT", cBtn.icon, "LEFT", -4, 0)
                end

                cBtn.currencyID = currencyID
                cBtn.tokenIndex = i

                cBtn.icon:SetTexture(icon or "Interface\\Icons\\INV_Misc_Coin_02")
                cBtn.text:SetText(count)

                local textBreite = cBtn.text:GetStringWidth() or 20
                cBtn:SetSize(textBreite + 18, 20)

                cBtn:ClearAllPoints()
                cBtn:SetPoint("LEFT", currencyFrameContainer, "LEFT", waehrungsX, 0)
                cBtn:SetFrameLevel(currencyFrameContainer:GetFrameLevel() + 1)

                cBtn:SetScript("OnEnter", function(self)
                    GameTooltip:SetOwner(self, "ANCHOR_TOP")
                    if self.currencyID then
                        GameTooltip:SetHyperlink("string:currency:" .. self.currencyID)
                    elseif GameTooltip.SetCurrencyToken then
                        GameTooltip:SetCurrencyToken(self.tokenIndex)
                    end
                    GameTooltip:Show()
                end)
                cBtn:SetScript("OnLeave", function() GameTooltip:Hide() end)

                cBtn:Show()
                table.insert(WaehrungsAnzeigeButtons, cBtn)

                waehrungsX = waehrungsX + cBtn:GetWidth() + 8
            end
        end
    end

    local gesamtZeilen = math.ceil(#temporaereButtonListe / spaltenAnzahl)
    local berechneteFensterHoehe = math.abs(startY) + (gesamtZeilen * (slotGroesse + abstand)) + 40 

    RankoneQoL_BagsFrame:SetSize(berechneteFensterBreite, berechneteFensterHoehe)
end

-------------------------------------------------------------------------------
-- 4. LIVE SYNCHRONISATION & ENGINES (Der unkaputtbare v0.8.5 Echtzeit-Scanner)
-------------------------------------------------------------------------------
local bagUpdateFrame = CreateFrame("Frame")
bagUpdateFrame:RegisterEvent("BAG_UPDATE")
bagUpdateFrame:RegisterEvent("PLAYER_LOGIN")
bagUpdateFrame:RegisterEvent("CURRENCY_DISPLAY_UPDATE")

bagUpdateFrame:SetScript("OnEvent", function(self, event, bagID)
    if event == "PLAYER_LOGIN" then
        if RankoneQoL.ErstelleDasTaschenFenster then
            RankoneQoL.ErstelleDasTaschenFenster()
        end
    elseif event == "BAG_UPDATE" or event == "CURRENCY_DISPLAY_UPDATE" then
        if RankoneQoL_BagsFrame and RankoneQoL_BagsFrame:IsShown() then
            if event == "CURRENCY_DISPLAY_UPDATE" or (bagID and bagID >= 0 and bagID <= 4) then
                RankoneQoL.GeneriereTaschenGrid()
                if RankoneQoL.StarteGegenstandsSuche then RankoneQoL.StarteGegenstandsSuche() end
            end
        end
    end
end)

local letztesLayoutUpdate = 0
local masterScannerFrame = CreateFrame("Frame", nil, RankoneQoL_BagsFrame)
masterScannerFrame:SetScript("OnUpdate", function(self, elapsed)
    letztesLayoutUpdate = letztesLayoutUpdate + elapsed
    if letztesLayoutUpdate >= 0.1 then
        letztesLayoutUpdate = 0
        
        if RankoneQoL_BagsFrame and RankoneQoL_BagsFrame:IsShown() and RankoneQoLEinstellungen then
            local info = C_CurrencyInfo and C_CurrencyInfo.GetBackpackCurrencyInfo or GetBackpackCurrencyInfo
            local aktiveWaehrungen = 0
            for i = 1, 3 do
                local name, count = info(i)
                if name and count and count > 0 then aktiveWaehrungen = aktiveWaehrungen + 1 end
            end

            local sliderSpalten = RankoneQoLEinstellungen.tascheSpalten or 8
            local sliderAbstand = RankoneQoLEinstellungen.tascheAbstand or 4
            
            local startX = 14 local slotGroesse = 37 local startY = -64
            local sollBreite = startX + (sliderSpalten * (slotGroesse + sliderAbstand)) - sliderAbstand + startX
            local aktuelleBreite = math.floor(RankoneQoL_BagsFrame:GetWidth() + 0.5)

            local sliderFontSize = RankoneQoLEinstellungen.ilvlFontSize or 12
            local aktuelleSchriftGroesse = 12
            if #RankoneQoL.InventarSlotsTabelle > 0 and RankoneQoL.InventarSlotsTabelle[1].ilvlText then
                local _, currentSize = RankoneQoL.InventarSlotsTabelle[1].ilvlText:GetFont()
                if currentSize then aktuelleSchriftGroesse = math.floor(currentSize + 0.5) end
            end

            if aktiveWaehrungen ~= #WaehrungsAnzeigeButtons or aktuelleBreite ~= math.floor(sollBreite + 0.5) or aktuelleSchriftGroesse ~= sliderFontSize then
                RankoneQoL_BagsFrame:Hide()
                RankoneQoL.GeneriereTaschenGrid()
                RankoneQoL_BagsFrame:Show()
                if RankoneQoL.StarteGegenstandsSuche then RankoneQoL.StarteGegenstandsSuche() end
            end
        end
    end
end)

C_Timer.After(1.0, function()
    if RankoneQoL_BagsFrame then
        RankoneQoL_BagsFrame:HookScript("OnShow", function()
            RankoneQoL.GeneriereTaschenGrid()
        end)
    end
end)

-------------------------------------------------------------------------------
-- 5. AUTOMATISCHES ÖFFNEN & SCHLIESSEN
-------------------------------------------------------------------------------
local autoBagEventFrame = CreateFrame("Frame")
autoBagEventFrame:RegisterEvent("BANKFRAME_OPENED")
autoBagEventFrame:RegisterEvent("BANKFRAME_CLOSED")
autoBagEventFrame:RegisterEvent("MERCHANT_SHOW")
autoBagEventFrame:RegisterEvent("MERCHANT_CLOSED")
autoBagEventFrame:RegisterEvent("AUCTION_HOUSE_SHOW")
autoBagEventFrame:RegisterEvent("AUCTION_HOUSE_CLOSED")

autoBagEventFrame:SetScript("OnEvent", function(self, event)
    if not RankoneQoLEinstellungen then return end

    if event == "BANKFRAME_OPENED" then
        if RankoneQoLEinstellungen.tascheAutoBank and ToggleAllBags then
            if RankoneQoL_BagsFrame and not RankoneQoL_BagsFrame:IsShown() then ToggleAllBags() end
        end
    elseif event == "BANKFRAME_CLOSED" then
        if RankoneQoLEinstellungen.tascheAutoBank and ToggleAllBags then
            if RankoneQoL_BagsFrame and RankoneQoL_BagsFrame:IsShown() then ToggleAllBags() end
        end
    elseif event == "MERCHANT_SHOW" then
        if RankoneQoLEinstellungen.tascheAutoHaendler and ToggleAllBags then
            if RankoneQoL_BagsFrame and not RankoneQoL_BagsFrame:IsShown() then ToggleAllBags() end
        end
    elseif event == "MERCHANT_CLOSED" then
        if RankoneQoLEinstellungen.tascheAutoHaendler and ToggleAllBags then
            if RankoneQoL_BagsFrame and RankoneQoL_BagsFrame:IsShown() then ToggleAllBags() end
        end
    elseif event == "AUCTION_HOUSE_SHOW" then
        if RankoneQoLEinstellungen.tascheAutoAuktion and ToggleAllBags then
            if RankoneQoL_BagsFrame and not RankoneQoL_BagsFrame:IsShown() then ToggleAllBags() end
        end
    elseif event == "AUCTION_HOUSE_CLOSED" then
        if RankoneQoLEinstellungen.tascheAutoAuktion and ToggleAllBags then
            if RankoneQoL_BagsFrame and RankoneQoL_BagsFrame:IsShown() then ToggleAllBags() end
        end
    end
end)

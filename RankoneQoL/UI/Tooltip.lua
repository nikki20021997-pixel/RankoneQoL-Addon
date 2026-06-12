-------------------------------------------------------------------------------
-- 1. MODULE INITIALIZATION & ADVANCED TOOLTIP REGISTER
-------------------------------------------------------------------------------
local addonName, RankoneQoL = ...

-- Initialisiert die Standard-Datenbankwerte, falls sie nicht existieren
local function SichertTooltipDatenbank()
    if not RankoneQoLEinstellungen then return end
    if RankoneQoLEinstellungen.zeigeTooltipPreis == nil then RankoneQoLEinstellungen.zeigeTooltipPreis = true end
    if RankoneQoLEinstellungen.zeigeTooltipTalente == nil then RankoneQoLEinstellungen.zeigeTooltipTalente = true end
    if RankoneQoLEinstellungen.tooltipScaleVal == nil then RankoneQoLEinstellungen.tooltipScaleVal = 1.0 end
end

-------------------------------------------------------------------------------
-- 2. DYNAMISCHES SKALIERUNGS-SYSTEM
-------------------------------------------------------------------------------
function RankoneQoL.AktualisiereTooltipSkalierung()
    if not GameTooltip then return end
    SichertTooltipDatenbank()
    
    local wunschGroesse = RankoneQoLEinstellungen.tooltipScaleVal or 1.0
    GameTooltip:SetScale(wunschGroesse)
end

-------------------------------------------------------------------------------
-- 3. VENDOR PRICE CHECK ENGINE (Echte Stapelgrößen-Erkennung via GetMouseFoci)
-------------------------------------------------------------------------------
local function OnTooltipSetItem(self)
    SichertTooltipDatenbank()
    if not (RankoneQoLEinstellungen and RankoneQoLEinstellungen.zeigeTooltipPreis) then return end
    
    -- Holt den exakten Gegenstands-Link direkt aus dem Tooltip
    local _, itemLink = self:GetItem()
    if not itemLink then return end
    
    -- Liest die systemweiten Händler-Preise von Blizzard aus
    local _, _, _, _, _, _, _, _, _, _, verkaufsPreis = GetItemInfo(itemLink)
    
    -- Wenn das Item einen Verkaufspreis hat und nicht unkäuflich ist
    if verkaufsPreis and verkaufsPreis > 0 then
        local anzahl = 1
        
        -- NUTZT DAS MODERNE MoP-CLASSIC SYSTEM: Holt alle Interface-Elemente unter der Maus
        if GetMouseFoci then
            local mouseFoci = GetMouseFoci()
            if mouseFoci and mouseFoci[1] then
                local focusFrame = mouseFoci[1]
                -- Prüft, ob das Frame eine native Stapelanzahl besitzt (Taschen, Bank, Lootfenster)
                if focusFrame.count and type(focusFrame.count) == "number" then
                    anzahl = focusFrame.count
                elseif focusFrame.Count and focusFrame.Count.GetText then
                    local textNum = tonumber(focusFrame.Count:GetText())
                    if textNum and textNum > 0 then
                        anzahl = textNum
                    end
                end
            end
        end
        
        -- Berechnet den echten Gesamtpreis für den kompletten Stapel (z.B. 3x Murlocflosse)
        local gesamtPreis = verkaufsPreis * anzahl
        
        -- Formatiert den errechneten Preis mit Blizzards offiziellen Münz-Grafiken
        local muenzenText = GetCoinTextureString(gesamtPreis)
        local de = (GetLocale() == "deDE")
        local praefix = de and "Händlerpreis:" or "Sell Price:"
        
        -- Gibt ab jetzt immer und ausschließlich den reinen, sauberen Gesamtpreis des Stacks aus
        self:AddLine(praefix .. " " .. muenzenText)
    end
end

-- Klinkt sich sicher in Blizzards Tooltip-Engine für Items ein
GameTooltip:HookScript("OnTooltipSetItem", OnTooltipSetItem)
ItemRefTooltip:HookScript("OnTooltipSetItem", OnTooltipSetItem)
-------------------------------------------------------------------------------
-- 4. TALENT-SPEZIALISIERUNGS SCANNER (Vollständig bereinigt)
-------------------------------------------------------------------------------
local talentEventFrame = CreateFrame("Frame")
local aktuellesInspectAddonGuid = nil

-- Hilfsfunktion: Ermittelt den Spec-Namen und das dazugehörige Icon
local function ErmittleTalentSpezialisierung(unit)
    if not unit then return nil, nil end
    
    local activeSpec = GetInspectSpecialization(unit)
    if activeSpec and activeSpec > 0 then
        local id, name, description, icon = GetSpecializationInfoByID(activeSpec)
        
        if name then
            name = tostring(name):trim()
        end
        
        return name, icon
    end
    return nil, nil
end

-- Verarbeitet das Signal vom WoW-Server, dass die Talentdaten bereitstehen
talentEventFrame:SetScript("OnEvent", function(self, event, ...)
    if event == "INSPECT_READY" then
        local guid = ...
        if guid == aktuellesInspectAddonGuid then
            local specName, specIcon = ErmittleTalentSpezialisierung("mouseover")
            if specName and GameTooltip:IsShown() then
                local de = (GetLocale() == "deDE")
                local label = de and "Spezialisierung: " or "Specialization: "
                
                local iconMarkup = ""
                if specIcon then
                    iconMarkup = CreateTextureMarkup(specIcon, 16, 16, 14, 14, 0, 1, 0, 1, 0, 0) .. " "
                end
                
                GameTooltip:AddLine(label .. iconMarkup .. "|cFFFFD100" .. specName .. "|r")
                GameTooltip:Show()
            end
            ClearInspectPlayer()
            aktuellesInspectAddonGuid = nil
        end
    elseif event == "UPDATE_MOUSEOVER_UNIT" then
        if not (RankoneQoLEinstellungen and RankoneQoLEinstellungen.zeigeTooltipTalente) then return end
        if InCombatLockdown() then return end
        
        -- Targetframe-Schutz: Verhindert Fehlauslösungen über UI-Elemente
        if GameTooltip:GetOwner() then
            local ownerName = GameTooltip:GetOwner():GetName() or ""
            if string.find(ownerName, "Target") or string.find(ownerName, "Button") or string.find(ownerName, "UnitFrame") then
                return
            end
        end
        
        -- Prüft, ob die Maus über einem echten, anderen Mitspieler schwebt
        if UnitIsPlayer("mouseover") and CanInspect("mouseover") and not UnitIsUnit("player", "mouseover") then
            if UnitIsVisible("mouseover") then
                aktuellesInspectAddonGuid = UnitGUID("mouseover")
                
                -- Löscht anstehende Reste, um Datenstaus zu verhindern
                ClearInspectPlayer()
                
                -- Startet die asynchrone Serverabfrage
                NotifyInspect("mouseover")
            end
        end
    end
end)

-- Registriert die Server-Signale
talentEventFrame:RegisterEvent("INSPECT_READY")
talentEventFrame:RegisterEvent("UPDATE_MOUSEOVER_UNIT")

-------------------------------------------------------------------------------
-- 5. INITIALISIERUNGS HOOK & VISUELLER ERROR-BLOCKER
-------------------------------------------------------------------------------
local initialisierungsFrame = CreateFrame("Frame")
initialisierungsFrame:RegisterEvent("PLAYER_LOGIN")
initialisierungsFrame:SetScript("OnEvent", function(self, event)
    if RankoneQoL.AktualisiereTooltipSkalierung then
        RankoneQoL.AktualisiereTooltipSkalierung()
    end
    
    -- Der bewährte visuelle Hook fängt die roten Text-Fehler im Bild ab
    if UIErrorsFrame and UIErrorsFrame.RegisterEvent then
        hooksecurefunc(UIErrorsFrame, "AddMessage", function(self, text, r, g, b, id)
            if text then
                if string.find(text, "entfernt") or string.find(text, "range") or string.find(text, "Distance") or string.find(text, "Inspect") then
                    self:Clear()
                end
            end
        end)
    end
end)
-------------------------------------------------------------------------------
-- 1. MODULE VARIABLES
-------------------------------------------------------------------------------
local addonName, RankoneQoL = ...

local verkaufsListe = {}
local timerTicker = nil
local gesamtGewinn = 0

local aktuellesGold = 0
local sitzungEingenommen = 0
local sitzungAusgegeben = 0
local updateSperreActive = false

-------------------------------------------------------------------------------
-- 2. DATA BRIDGE FOR THE INTERFACE
-------------------------------------------------------------------------------
function RankoneQoL.HoleAktuelleSitzungsZahlen()
    local schrott = RankoneQoLEinstellungen and RankoneQoLEinstellungen.schrottGoldGesamt or 0
    return schrott, sitzungEingenommen, sitzungAusgegeben
end

function RankoneQoL.InitGoldTracker()
    sitzungEingenommen = 0
    sitzungAusgegeben = 0
    aktuellesGold = GetMoney() or 0
end

-------------------------------------------------------------------------------
-- 3. THE GLOBAL BALANCE SHEET TRACKER (ALL SOURCES)
-------------------------------------------------------------------------------
function RankoneQoL.TrackeGoldLive()
    local neuesGold = GetMoney() or 0
    
    if aktuellesGold == 0 and sitzungEingenommen == 0 and sitzungAusgegeben == 0 then
        aktuellesGold = neuesGold
        return
    end

    if neuesGold > aktuellesGold then
        sitzungEingenommen = sitzungEingenommen + (neuesGold - aktuellesGold)
    elseif neuesGold < aktuellesGold then
        -- Fix: Tippfehler math.absunterschied restlos entfernt
        sitzungAusgegeben = sitzungAusgegeben + (aktuellesGold - neuesGold)
    end
    aktuellesGold = neuesGold

    if not updateSperreActive then
        updateSperreActive = true
        C_Timer.After(0.2, function()
            -- Fix: Holt das Schrottgold jetzt korrekt aus der permanenten Einstellungs-Datenbank
            local schrott = RankoneQoLEinstellungen and RankoneQoLEinstellungen.schrottGoldGesamt or 0
            if RankoneQoL.AktualisiereStandaloneZahlen then
                RankoneQoL.AktualisiereStandaloneZahlen(schrott, sitzungEingenommen, sitzungAusgegeben)
            end
            updateSperreActive = false
        end)
    end
end

-------------------------------------------------------------------------------
-- 4. MERCHANT AND AUTO-REPAIR ENGINE
-------------------------------------------------------------------------------
local function VerkaufeNaechstesItem()
    if #verkaufsListe == 0 then
        if timerTicker then timerTicker:Cancel(); timerTicker = nil end
        if gesamtGewinn > 0 then
            RankoneQoLEinstellungen.schrottGoldGesamt = RankoneQoLEinstellungen.schrottGoldGesamt + gesamtGewinn
            print("|cFF575EFF" .. RankoneQoL.L["CHAT_JUNK"] .. "|r" .. GetCoinTextureString(gesamtGewinn))
            if RankoneQoL.AktualisiereStandaloneZahlen then 
                RankoneQoL.AktualisiereStandaloneZahlen(RankoneQoLEinstellungen.schrottGoldGesamt, sitzungEingenommen, sitzungAusgegeben) 
            end
            gesamtGewinn = 0 
        end
        return
    end
    
    local aktuellesItem = table.remove(verkaufsListe, 1)
    if C_Container and C_Container.UseContainerItem then 
        C_Container.UseContainerItem(aktuellesItem.tasche, aktuellesItem.platz)
    else 
        UseContainerItem(aktuellesItem.tasche, aktuellesItem.platz) 
    end
end

local function ScanneUndVerkaufeSchrott()
    verkaufsListe = {} 
    gesamtGewinn = 0
    local getSlotsFunc = C_Container and C_Container.GetContainerNumSlots or GetContainerNumSlots
    for tasche = 0, 4 do
        local slots = getSlotsFunc(tasche)
        if slots and slots > 0 then
            for platz = 1, slots do
                local itemInfo = C_Container and C_Container.GetContainerItemInfo(tasche, platz)
                if itemInfo then
                    local quality = itemInfo.quality 
                    local itemLink = itemInfo.hyperlink or itemInfo.itemLink 
                    local stackCount = itemInfo.stackCount or 1
                    if quality and quality == 0 and itemLink then
                        local _, _, _, _, _, _, _, _, _, _, verkaufsPreis = GetItemInfo(itemLink)
                        if verkaufsPreis and verkaufsPreis > 0 then
                            gesamtGewinn = gesamtGewinn + (verkaufsPreis * stackCount)
                            table.insert(verkaufsListe, {tasche = tasche, platz = platz})
                        end
                    end
                end
            end
        end
    end
    if #verkaufsListe > 0 and C_Timer and C_Timer.NewTicker then 
        timerTicker = C_Timer.NewTicker(0.1, VerkaufeNaechstesItem) 
    end
end

function RankoneQoL.FuehreHaendlerLogikAus()
    if RankoneQoLEinstellungen and RankoneQoLEinstellungen.autoReparatur and CanMerchantRepair() then
        local reparaturKosten, brauchReparatur = GetRepairAllCost()
        if brauchReparatur and reparaturKosten > 0 and GetMoney() >= reparaturKosten then
            RepairAllItems(false)
            print("|cFF575EFF" .. RankoneQoL.L["CHAT_REPAIR"] .. "|r" .. GetCoinTextureString(reparaturKosten))
        end
    end
    if RankoneQoLEinstellungen and RankoneQoLEinstellungen.autoVerkauf and C_Timer and C_Timer.After then 
        C_Timer.After(0.1, ScanneUndVerkaufeSchrott) 
    end
end
-------------------------------------------------------------------------------
-- 5. AUTO-QUEST ENGINE (Intelligenter Multi-Quest- & Gossip-Fix!)
-------------------------------------------------------------------------------
function RankoneQoL.FuehreQuestLogikAus(event)
    if not (RankoneQoLEinstellungen and RankoneQoLEinstellungen.autoQuest) then return end
    
    if event == "GOSSIP_SHOW" then
        if C_GossipInfo and C_GossipInfo.GetAvailableQuests then
            local availableQuests = C_GossipInfo.GetAvailableQuests()
            if availableQuests and #availableQuests > 0 then
                if availableQuests and availableQuests.questID then
                    C_GossipInfo.SelectAvailableQuest(availableQuests.questID)
                    return
                end
            end
        end
        if GetNumAvailableQuests and GetNumAvailableQuests() > 0 then 
            SelectAvailableQuest(1) 
            return
        end

        if C_GossipInfo and C_GossipInfo.GetActiveQuests then
            local activeQuests = C_GossipInfo.GetActiveQuests()
            if activeQuests and #activeQuests > 0 then
                for i = 1, #activeQuests do
                    if activeQuests[i] and activeQuests[i].isComplete and activeQuests[i].questID then
                        C_GossipInfo.SelectActiveQuest(activeQuests[i].questID)
                        return
                    end
                end
                if activeQuests and activeQuests.questID then
                    C_GossipInfo.SelectActiveQuest(activeQuests.questID)
                    return
                end
            end
        end
        if GetNumActiveQuests and GetNumActiveQuests() > 0 then 
            SelectActiveQuest(1)
            return
        end
        
    elseif event == "QUEST_PROGRESS" then 
        if IsQuestCompletable() then CompleteQuest() end
    elseif event == "QUEST_DETAIL" then 
        if GetNumQuestChoices() == 0 then AcceptQuest() end 
    elseif event == "QUEST_COMPLETE" then
        if GetNumQuestChoices() == 0 then GetQuestReward(0)
        elseif GetNumQuestChoices() == 1 then GetQuestReward(1) end
    end
end

-------------------------------------------------------------------------------
-- 6. SMART-INVITE ENGINE
-------------------------------------------------------------------------------
function RankoneQoL.FuehreInviteLogikAus(inviterName)
    if not (RankoneQoLEinstellungen and RankoneQoLEinstellungen.autoInvite) then return end
    if not inviterName then return end

    if inviterName == "TestFreund" then print("|cFF575EFF" .. RankoneQoL.L["CHAT_INVITE_TEST"] .. "|r") return end

    local istFreund = false 
    local anzahlFreunde = C_FriendList and C_FriendList.GetNumFriends() or GetNumFriends()
    for i = 1, anzahlFreunde do
        local info = C_FriendList and C_FriendList.GetFriendInfoByIndex(i) 
        local name = info and info.name or GetFriendInfo(i)
        if name == inviterName then istFreund = true break end
    end
    if not istFreund and IsInGuild() then
        local anzahlGildenmitglieder = GetNumGuildMembers()
        for i = 1, anzahlGildenmitglieder do
            local name = GetGuildRosterInfo(i) 
            if name and name:find("-") then name = name:match("([^-]+)") end
            if name == inviterName then istFreund = true break end
        end
    end
    if istFreund then
        if C_PartyInfo and C_PartyInfo.ConfirmInvite then C_PartyInfo.ConfirmInvite() else AcceptGroup() end
        if StaticPopup_Hide then StaticPopup_Hide("PARTY_INVITE") end
        print("|cFF575EFF" .. string.format(RankoneQoL.L["CHAT_INVITE_REAL"], inviterName) .. "|r")
    end
end

-------------------------------------------------------------------------------
-- 7. AUTOMATISCHES PLÜNDERN & STUMMSCHALTUNG DER ERROR SPEECH
-------------------------------------------------------------------------------
function RankoneQoL.AktualisiereAutoLootZustand()
    if not RankoneQoLEinstellungen then return end
    
    if RankoneQoLEinstellungen.autoLoot then
        SetCVar("autoLootDefault", "1")
    else
        SetCVar("autoLootDefault", "0")
    end
end

local lootFrame = CreateFrame("Frame")
lootFrame:RegisterEvent("PLAYER_LOGIN")
lootFrame:SetScript("OnEvent", function()
    C_Timer.After(1.0, function()
        if RankoneQoL.AktualisiereAutoLootZustand then
            RankoneQoL.AktualisiereAutoLootZustand()
        end
        SetCVar("Sound_EnableErrorSpeech", "0")
    end)
end)

-------------------------------------------------------------------------------
-- 8. GLOBAL MOVABLE FRAMES ENGINE (Mit Charakterfenster-Direktstarter!)
-------------------------------------------------------------------------------
local function MachtFrameVerschiebbar(frame)
    if not frame or not frame.SetMovable then return end
    
    if frame.rQolMovableAktiv then return end
    frame.rQolMovableAktiv = true
    
    if frame == WorldMapFrame or (frame:GetName() and string.find(frame:GetName(), "WorldMap")) then 
        return 
    end

    frame:SetMovable(true)
    frame:SetClampedToScreen(true)
    
    if frame.SetAttribute then
        frame:SetAttribute("UIPanelLayout-defined", nil)
    end

    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
    
    frame:HookScript("OnDragStart", function(self)
        if RankoneQoLEinstellungen and RankoneQoLEinstellungen.autoMoveAll then
            self:StartMoving()
        end
    end)
    frame:HookScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
    end)
end

local globalMoveHookAktiv = false
local function InitialisierungsGlobalMove()
    if globalMoveHookAktiv then return end
    globalMoveHookAktiv = true

    -- Hook für alle Standard-Fenster, die im Verlauf des Spielens geöffnet werden
    hooksecurefunc("ShowUIPanel", function(frame)
        if RankoneQoLEinstellungen and RankoneQoLEinstellungen.autoMoveAll then
            if frame and frame.GetName then
                MachtFrameVerschiebbar(frame)
            end
        end
    end)
    
    -- DIREKTSTARTER: Zwingt das Charakterfenster sofort beim Laden in den Verschiebe-Modus!
    if CharacterFrame and RankoneQoLEinstellungen and RankoneQoLEinstellungen.autoMoveAll then
        MachtFrameVerschiebbar(CharacterFrame)
    end
end

local moveEventFrame = CreateFrame("Frame")
moveEventFrame:RegisterEvent("PLAYER_LOGIN")
moveEventFrame:SetScript("OnEvent", function(self, event)
    if event == "PLAYER_LOGIN" then
        if RankoneQoLEinstellungen and RankoneQoLEinstellungen.autoMoveAll == nil then
            RankoneQoLEinstellungen.autoMoveAll = true
        end
        -- Startet die Initialisierung direkt beim Login
        InitialisierungsGlobalMove()
    end
end)

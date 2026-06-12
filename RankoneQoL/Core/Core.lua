-------------------------------------------------------------------------------
-- 1. CENTRAL EVENT LISTENER FRAME
-------------------------------------------------------------------------------
local addonName, RankoneQoL = ...
local meinFrame = CreateFrame("Frame")

meinFrame:RegisterEvent("PLAYER_LOGIN")
meinFrame:RegisterEvent("PLAYER_DEAD")
meinFrame:RegisterEvent("MERCHANT_SHOW")
meinFrame:RegisterEvent("GOSSIP_SHOW")
meinFrame:RegisterEvent("QUEST_PROGRESS")
meinFrame:RegisterEvent("QUEST_DETAIL")
meinFrame:RegisterEvent("QUEST_COMPLETE")
meinFrame:RegisterEvent("PLAYER_MONEY")
meinFrame:RegisterEvent("CINEMATIC_START")
meinFrame:RegisterEvent("PARTY_INVITE_REQUEST")

-------------------------------------------------------------------------------
-- 2. ENGINE CONTROLLER (EVENT HANDLER)
-------------------------------------------------------------------------------
meinFrame:SetScript("OnEvent", function(self, event, ...)
    if event == "PLAYER_LOGIN" then
        local spielerName = UnitName("player") 
        local _, englischeKlasse = UnitClass("player")
        local klassenFarbeHex = "FFFFFFFF" 
        if englischeKlasse and RAID_CLASS_COLORS and RAID_CLASS_COLORS[englischeKlasse] then
            klassenFarbeHex = RAID_CLASS_COLORS[englischeKlasse].colorStr
        end
        
        local getMetadataFunc = C_AddOns and C_AddOns.GetAddOnMetadata or GetAddOnMetadata
        local version = getMetadataFunc("RankoneQoL", "Version") or "0.3.5"
        
        print("|cFF575EFF" .. RankoneQoL.L["CHAT_LOGIN_1"] .. "|r|c" .. klassenFarbeHex .. spielerName .. "|r|cFF575EFF" .. RankoneQoL.L["CHAT_LOGIN_2"] .. "|r")
        print("|cFF575EFF[RankøneQoL] v" .. version .. "|r")
        
        if RankoneQoL.InitGoldTracker then RankoneQoL.InitGoldTracker() end
        if RankoneQoL.ErstelleStandaloneUI then RankoneQoL.ErstelleStandaloneUI() end 
        if RankoneQoL.ErstelleMinimapButton then RankoneQoL.ErstelleMinimapButton() end

    elseif event == "PLAYER_DEAD" then
        print("|cFFFF0000" .. RankoneQoL.L["CHAT_DEAD"] .. "|r")
        local soundID = RankoneQoLEinstellungen and RankoneQoLEinstellungen.wunschSound or 3325
        local kanalID = RankoneQoLEinstellungen and RankoneQoLEinstellungen.wunschKanal or "Effects"
        PlaySound(soundID, kanalID) 

    elseif event == "MERCHANT_SHOW" then
        if RankoneQoL.FuehreHaendlerLogikAus then RankoneQoL.FuehreHaendlerLogikAus() end

    elseif event == "PLAYER_MONEY" then
        if RankoneQoL.TrackeGoldLive then RankoneQoL.TrackeGoldLive() end

    elseif event == "GOSSIP_SHOW" or event == "QUEST_PROGRESS" or event == "QUEST_DETAIL" or event == "QUEST_COMPLETE" then
        if RankoneQoL.FuehreQuestLogikAus then RankoneQoL.FuehreQuestLogikAus(event) end

    elseif event == "CINEMATIC_START" then
        if RankoneQoLEinstellungen and RankoneQoLEinstellungen.autoSkipCinematic then
            CinematicFrame_CancelCinematic() 
            print("|cFF575EFF" .. RankoneQoL.L["CHAT_CINEMATIC"] .. "|r")
        end

    elseif event == "PARTY_INVITE_REQUEST" then
        if RankoneQoL.FuehreInviteLogikAus then RankoneQoL.FuehreInviteLogikAus(...) end
    end
end)

-------------------------------------------------------------------------------
-- 3. INTERFACE COMMANDS (SLASH COMMANDS)
-------------------------------------------------------------------------------
SLASH_RANKONEQOLTEST1 = "/testsound"
SlashCmdList["RANKONEQOLTEST"] = function()
    print("|cFF00FF96" .. RankoneQoL.L["CHAT_TESTING"] .. "|r")
    local soundID = RankoneQoLEinstellungen and RankoneQoLEinstellungen.wunschSound or 3325
    local kanalID = RankoneQoLEinstellungen and RankoneQoLEinstellungen.wunschKanal or "Effects"
    PlaySound(soundID, kanalID) 
    meinFrame:GetScript("OnEvent")(meinFrame, "CINEMATIC_START")
    meinFrame:GetScript("OnEvent")(meinFrame, "PARTY_INVITE_REQUEST", "TestFreund")
end

SLASH_RANKONEQOLMENU1 = "/rqol"
SlashCmdList["RANKONEQOLMENU"] = function()
    if RankoneQoL.ToggleStandaloneUI then RankoneQoL.ToggleStandaloneUI() end
end

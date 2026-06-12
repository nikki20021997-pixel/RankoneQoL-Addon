-------------------------------------------------------------------------------
-- 1. GLOBAL ADDON-OBJECT INITIALIZATION
-------------------------------------------------------------------------------
local addonName, RankoneQoL = ...
RankoneQoL.L = {} 

-------------------------------------------------------------------------------
-- 2. DYNAMIC TRANSLATION SYSTEM (LOCALIZATION)
-------------------------------------------------------------------------------
local sprache = GetLocale()

if sprache == "deDE" then
    -- UI Texte
    RankoneQoL.L["TITEL"] = "RankøneQoL Einstellungen"
    RankoneQoL.L["AUTO_SELL"] = "Grauen Schrott automatisch verkaufen"
    RankoneQoL.L["AUTO_REPAIR"] = "Ausrüstung automatisch reparieren"
    RankoneQoL.L["AUTO_QUEST"] = "Quests automatisch annehmen und abgeben"
    RankoneQoL.L["AUTO_CINEMATIC"] = "Zwischensequenzen automatisch überspringen"
    RankoneQoL.L["AUTO_INVITE"] = "Einladungen von Freunden/Gilde automatisch annehmen"
    RankoneQoL.L["AUTO_LOOT"] = "Automatisches Plündern (Auto-Loot) aktivieren"
    RankoneQoL.L["AUTO_PERF"] = "FPS & Ping Anzeige aktivieren"
    RankoneQoL.L["AUTO_GOLD"] = "Separates Gold-Sitzungs-Fenster anzeigen"
    RankoneQoL.L["AUTO_ILVL"] = "Gegenstandsstufen im Charakterfenster"
    RankoneQoL.L["SLIDER_SCALE"] = "Größe des Leistungszählers:"
    RankoneQoL.L["SLIDER_ILVL_FONT"] = "Schriftgröße der Gegenstandsstufe:"
	RankoneQoL.L["BAG_SETTINGS"] = "Taschen-Einstellungen"
	RankoneQoL.L["OPT_BANK"] = "Automatisch an der Bank öffnen"
	RankoneQoL.L["OPT_AUCTION"] = "Automatisch am Auktionshaus öffnen"
	RankoneQoL.L["OPT_MERCHANT"] = "Automatisch beim Händler öffnen"
	RankoneQoL.L["SLIDER_BAG_SCALE"] = "Inventar-Größe"
	RankoneQoL.L["SLIDER_COLUMNS"] = "Spalten-Anzahl"
	RankoneQoL.L["SLIDER_SPACING"] = "Slot-Abstand"

    
    -- NEU: Global Move Text (deDE)
    RankoneQoL.L["AUTO_MOVE_ALL"] = "Alle Blizzard-Fenster frei verschiebbar machen"
    
    -- Tooltip Texte
    RankoneQoL.L["TT_PRICE"] = "Verkaufspreis von Gegenständen anzeigen"
    RankoneQoL.L["TT_TALENT"] = "Talentspezialisierung anderer Spieler anzeigen"
    RankoneQoL.L["TT_SCALE_LABEL"] = "Skalierung des Tooltips (Größe):"
    
    -- Audio-Reiter Beschriftungen
    RankoneQoL.L["SOUND_ENABLE"] = "Sound komplett aktivieren"
    RankoneQoL.L["SOUND_LABEL"] = "Soundeffekt beim Sterben:"
    RankoneQoL.L["CHANNEL_LABEL"] = "Audiokanal für Soundeffekte beim Sterben:"
    RankoneQoL.L["VOL_MASTER"] = "Gesamtlautstärke:"
    RankoneQoL.L["VOL_MUSIC"] = "Musik:"
    RankoneQoL.L["VOL_EFFECTS"] = "Soundeffekte:"
    RankoneQoL.L["VOL_AMBIENCE"] = "Umgebung:"
    RankoneQoL.L["VOL_DIALOG"] = "Dialoge / Stimmen:"

    -- Karten-Reiter Beschriftungen
    RankoneQoL.L["MAP_COORDS"] = "Koordinaten auf der Weltkarte anzeigen"
    RankoneQoL.L["MAP_MOVE"] = "Weltkarte frei bewegen freischalten"
    RankoneQoL.L["MAP_ALPHA"] = "Karte beim Laufen durchsichtig machen"
    RankoneQoL.L["MAP_FADE"] = "Transparenz beim Laufen:"

    RankoneQoL.L["STAT_SCHROTT"] = "Gesamter Schrott-Gewinn:"
    RankoneQoL.L["STAT_EING"] = "Sitzung Eingenommen:"
    RankoneQoL.L["STAT_AUSG"] = "Sitzung Ausgegeben:"
    
    -- Sound Names
    RankoneQoL.L["S_DEFAULT"] = "Standard (3325)"
    RankoneQoL.L["S_MURLOC"] = "Murloc Gurgeln"
    RankoneQoL.L["S_VICTORY"] = "Dungeon Sieg"
    RankoneQoL.L["S_LEVELUP"] = "Level-Up Fanfare"
    RankoneQoL.L["S_LEEROY"] = "LEEROY JENKINS!"
    RankoneQoL.L["S_ILLIDAN"] = "Illidan: Nicht bereit!"
    RankoneQoL.L["S_LICHKING"] = "Garrosh: Für die Horde!"
    RankoneQoL.L["S_GOBLIN"] = "Yogg-Saron Lachen"
    RankoneQoL.L["S_MECH"] = "Mechanischer Alarm"
    RankoneQoL.L["S_PVPPOP"] = "PVP: Anmeldung bereit (8174)"
    RankoneQoL.L["S_HORN"] = "PVP: Arena Start-Horn (8212)"
    RankoneQoL.L["S_GUILD"] = "Erfolg / Gildengong (31578)"
    RankoneQoL.L["S_COINS"] = "Münzenklingeln / Kaching (120)"
    RankoneQoL.L["S_WHIP"] = "Raid-Warnung Peitschenhieb (52482)"

    -- Ingame Chat Nachrichten
    RankoneQoL.L["CHAT_LOGIN_1"] = "[RankøneQoL]: Willkommen zurück, "
    RankoneQoL.L["CHAT_LOGIN_2"] = " in Azeroth!"
    RankoneQoL.L["CHAT_DEAD"] = "[RankøneQoL]: Oh nein! Du bist gestorben. Schnell zurück zur Leiche!"
    RankoneQoL.L["CHAT_CINEMATIC"] = "[RankøneQoL]: Zwischensequenz wurde automatisch übersprungen."
    RankoneQoL.L["CHAT_TESTING"] = "[RankøneQoL]: Teste Addon-Funktionen..."
    RankoneQoL.L["CHAT_REPAIR"] = "[RankøneQoL]: Deine Rüstung wurde automatisch repariert! Kosten: "
    RankoneQoL.L["CHAT_JUNK"] = "[RankøneQoL]: Grauer Schrott automatisch verkauft! Gewinn: "
    RankoneQoL.L["CHAT_INVITE_TEST"] = "[RankøneQoL]: Einladung von TestFreund erfolgreich abgefangen und automatisch angenommen!"
    RankoneQoL.L["CHAT_INVITE_REAL"] = "[RankøneQoL]: Automatisch Einladung von %s angenommen."
else -- Standardmäßig Englisch (enUS)
    -- UI Texts
    RankoneQoL.L["TITEL"] = "RankøneQoL Settings"
    RankoneQoL.L["AUTO_SELL"] = "Automatically sell grey junk"
    RankoneQoL.L["AUTO_REPAIR"] = "Automatically repair equipment"
    RankoneQoL.L["AUTO_QUEST"] = "Automatically accept and turn in quests"
    RankoneQoL.L["AUTO_CINEMATIC"] = "Automatically skip cinematics"
    RankoneQoL.L["AUTO_INVITE"] = "Automatically accept invites from friends/guild"
    RankoneQoL.L["AUTO_LOOT"] = "Enable Automatic Looting (Auto-Loot)"
    RankoneQoL.L["AUTO_PERF"] = "Enable FPS & Ping display"
    RankoneQoL.L["AUTO_GOLD"] = "Show separate Gold Session window"
    RankoneQoL.L["AUTO_ILVL"] = "Show Item Levels in Character Frame"
    RankoneQoL.L["SLIDER_SCALE"] = "Performance Counter Scale:"
    RankoneQoL.L["SLIDER_ILVL_FONT"] = "Item Level Font Size:"
	RankoneQoL.L["BAG_SETTINGS"] = "Bag Settings"
	RankoneQoL.L["OPT_BANK"] = "Open automatically at the bank"
	RankoneQoL.L["OPT_AUCTION"] = "Open automatically at the auction house"
	RankoneQoL.L["OPT_MERCHANT"] = "Open automatically at merchants"
	RankoneQoL.L["SLIDER_BAG_SCALE"] = "Inventory Scale"
	RankoneQoL.L["SLIDER_COLUMNS"] = "Column Count"
	RankoneQoL.L["SLIDER_SPACING"] = "Slot Spacing"

    
    -- NEU: Global Move Text (enUS)
    RankoneQoL.L["AUTO_MOVE_ALL"] = "Make all Blizzard frames movable"
    
    -- Tooltip Tab Labels
    RankoneQoL.L["TT_PRICE"] = "Show item vendor sell prices"
    RankoneQoL.L["TT_TALENT"] = "Show other players' talent specs"
    RankoneQoL.L["TT_SCALE_LABEL"] = "Tooltip Scale (Size):"
    
    -- Audio Tab Labels
    RankoneQoL.L["SOUND_ENABLE"] = "Enable All Sound"
    RankoneQoL.L["SOUND_LABEL"] = "Sound effect on death:"
    RankoneQoL.L["CHANNEL_LABEL"] = "Sound channel for Death effects:"
    RankoneQoL.L["VOL_MASTER"] = "Master Volume:"
    RankoneQoL.L["VOL_MUSIC"] = "Music:"
    RankoneQoL.L["VOL_EFFECTS"] = "Sound Effects:"
    RankoneQoL.L["VOL_AMBIENCE"] = "Ambience:"
    RankoneQoL.L["VOL_DIALOG"] = "Dialog / Voices:"

    -- Map Tab Labels
    RankoneQoL.L["MAP_COORDS"] = "Show coordinates on World Map"
    RankoneQoL.L["MAP_MOVE"] = "Enable free world map movement"
    RankoneQoL.L["MAP_ALPHA"] = "Make map transparent while moving"
    RankoneQoL.L["MAP_FADE"] = "Moving Transparency:"

    RankoneQoL.L["STAT_SCHROTT"] = "Total Junk Profit:"
    RankoneQoL.L["STAT_EING"] = "Session Earned:"
    RankoneQoL.L["STAT_AUSG"] = "Session Spent:"
    
    -- Sound Names
    RankoneQoL.L["S_DEFAULT"] = "Default (3325)"
    RankoneQoL.L["S_MURLOC"] = "Murloc Gurgle"
    RankoneQoL.L["S_VICTORY"] = "Dungeon Victory"
    RankoneQoL.L["S_LEVELUP"] = "Level-Up Fanfare"
    RankoneQoL.L["S_LEEROY"] = "LEEROY JENKINS!"
    RankoneQoL.L["S_ILLIDAN"] = "Illidan: Not prepared!"
    RankoneQoL.L["S_LICHKING"] = "Garrosh: For the Horde!"
    RankoneQoL.L["S_GOBLIN"] = "Yogg-Saron Laugh"
    RankoneQoL.L["S_MECH"] = "Mechanical Alarm"
    RankoneQoL.L["S_PVPPOP"] = "PVP: Queue Popped (8174)"
    RankoneQoL.L["S_HORN"] = "PVP: Arena Start Horn (8212)"
    RankoneQoL.L["S_GUILD"] = "Achievement / Guild Gong (31578)"
    RankoneQoL.L["S_COINS"] = "Coins Jingle / Kaching (120)"
    RankoneQoL.L["S_WHIP"] = "Raid Warning Whip Crack (52482)"

    -- Ingame Chat Messages
    RankoneQoL.L["CHAT_LOGIN_1"] = "[RankøneQoL]: Welcome back, "
    RankoneQoL.L["CHAT_LOGIN_2"] = " to Azeroth!"
    RankoneQoL.L["CHAT_DEAD"] = "[RankøneQoL]: Oh no! You died. Release your spirit!"
    RankoneQoL.L["CHAT_CINEMATIC"] = "[ClassicQoL]: Cinematic was automatically skipped."
    RankoneQoL.L["CHAT_TESTING"] = "[RankøneQoL]: Testing Addon..."
    RankoneQoL.L["CHAT_REPAIR"] = "[RankøneQoL]: Equipment automatically repaired! Cost: "
    RankoneQoL.L["CHAT_JUNK"] = "[RankøneQoL]: Grey junk automatically sold! Profit: "
    RankoneQoL.L["CHAT_INVITE_TEST"] = "[RankøneQoL]: Invite from TestFreund successfully intercepted and automatically accepted!"
    RankoneQoL.L["CHAT_INVITE_REAL"] = "[RankøneQoL]: Automatically accepted invite from %s."
end

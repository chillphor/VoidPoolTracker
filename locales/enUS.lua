local addonName, addonTable = ...
-- 英文通常作为默认语言，或者指定语言加载
if GetLocale() ~= "enUS" then return end
local L = {}

-- UI Panel Titles
L["PANEL_TITLE"] = "Void Pool Account-Wide Loot Query"
L["LOOT_REMAINING"] = "Remaining"

-- Buttons
L["BUTTON_SYNC"] = "Sync"
L["BUTTON_ANNOUNCE"] = "Announce"
L["BUTTON_SELECT_CHARACTER"] = "Select Character"
L["BUTTON_CLOSE"] = "Close"

-- Dungeons
L["DUNGEON_DUNGEON_KINGS_REST"] = "Kings' Rest"
L["DUNGEON_TEMPLE_OF_SETHRALISS"] = "Temple of Sethraliss"
L["DUNGEON_RUBY_LIFE_POOLS"] = "Ruby Life Pools"
L["DUNGEON_THE_BLINDING_VALE"] = "The Blinding Vale"
L["DUNGEON_VOIDSCAR_ARENA"] = "Voidscar Arena"
L["DUNGEON_DEN_OF_NALORAKK"] = "Den of Nalorakk"
L["DUNGEON_MURDER_ROW"] = "Murder Row"
L["DUNGEON_ALTAR_OF_FANGS"] = "Altar of Fangs"

-- Messages
L["MSG_SYNC_SUCCESS"] = "[Void Query]: %s data synced successfully"
L["MSG_SYSTEM_LOADING"] = "[Void Query]: System is loading, please try again later"
L["MSG_DATA_NOT_READY"] = "[Void Query]: Data is not ready, please try again later"
L["MSG_NO_GROUP"] = "[Void Query]: Not in a group, cannot announce"
L["MSG_NO_DATA"] = "[Void Query]: No data in database, cannot announce"
L["MSG_LOADING"] = "Loading... Please refresh"
L["MSG_NO_RECORDS"] = "No records for this character in the database, please click the sync button in the top right"

-- Chat Announcements
L["ANNOUNCE_HEADER"] = "=== Remaining Pool-%s ==="
L["ANNOUNCE_CHARACTER"] = "Character: %s"

-- Character colors
L["YOUR_CHARACTER"] = "|cff00ff00"  -- Green
L["OTHER_CHARACTER"] = "|cff00ccff" -- Cyan
L["GRAY_TEXT"] = "|cff888888"       -- Gray
L["RED_TEXT"] = "|cffff0000"        -- Red
L["PURPLE_TEXT"] = "|cffa335ee"     -- Purple
L["CYAN_TEXT"] = "|cff00ffff"       -- Cyan

-- Time formats
L["TIME_HOUR"] = "%dh"
L["TIME_MINUTE"] = "%dm"
L["TIME_SECOND"] = "%ds"

addonTable.L = L

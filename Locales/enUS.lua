-- English localization for VoidPoolTracker

if GetLocale() ~= "enUS" then return end

VOIDPOOL_L = {
    -- Dungeon names
    DUNGEON_ACADEMY = "Nerub-ar Academy",
    DUNGEON_PLATFORM = "Mage Tower",
    DUNGEON_SINASTRA = "Nodes Sinastra",
    DUNGEON_SALHIR = "Salhan Mines",
    DUNGEON_COUNCIL = "Council of the Ancients",
    DUNGEON_ORIBOS = "Tower of the Eternal",
    DUNGEON_WINDRUNNER = "Windrunner Tower",
    DUNGEON_MISARAK = "Misarak Cave",

    -- UI Labels
    TITLE = "Void Chest Query",
    TITLE_REMAINING = "Remaining ",
    SYNC_BUTTON = "Sync",
    ANNOUNCE_BUTTON = "Announce",
    SELECT_CHARACTER = "Select Character",
    CHOOSE_CHARACTER = "Choose a character",
    CHARACTER_PREFIX = "Character: ",

    -- Messages
    MSG_SYNC_SUCCESS = "[Void Query]: %s data synchronized successfully",
    MSG_SYNC_FAILED_LOADING = "[Void Query]: System is loading, please try again",
    MSG_LOADING = "Loading... Please refresh",
    MSG_NO_DATA = "No records found in database. Please click \"Sync\" button to update.",
    MSG_NOT_IN_GROUP = "[Void Query]: Not in a group, cannot announce",
    MSG_ANNOUNCE_NO_DATA = "[Void Query]: No records in database, unable to announce",
    MSG_ANNOUNCE_HEADER = "=== Remaining Loot - %s ===",

    -- Tooltip hints
    TOOLTIP_PORTAL = "Cast portal",
    TOOLTIP_NOT_LEARNED = "Not learned",

    -- Status indicators
    STATUS_CURRENT_CHARACTER = "Current Character",
    STATUS_OTHER_CHARACTER = "Other Character",
}

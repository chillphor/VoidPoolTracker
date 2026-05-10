-- 1. 加载本地化文件
local locale = GetLocale()
local L = {}

-- 直接加载对应语言的本地化文件
if locale == "zhCN" then
    L = require("locales.zhCN")
else
    L = require("locales.enUS")
end

-- 设置默认备用文本（以防加载失败）
if not L or not next(L) then
    L = {
        ["DUNGEON_ACADEMY"] = "Academy of Aeons",
        ["DUNGEON_PLATFORM"] = "Mage's Terrace",
        ["DUNGEON_NODE"] = "Zekvir's Lair",
        ["DUNGEON_MINES"] = "Sarkareth's Lair",
        ["DUNGEON_CONCLAVE"] = "Conclave of the Chosen",
        ["DUNGEON_PEAK"] = "Nerub-ar Palace",
        ["DUNGEON_WINDRUNNER"] = "Windrunner's Spire",
        ["DUNGEON_MESARA"] = "Mykazal's Den",
    }
end

-- 2. 配置数据：副本宝箱列表
-- 【修改】：为每个副本添加 spellID 并使用本地化名称
local DUNGEON_LIST = {
    { name = L["DUNGEON_ACADEMY"] or "Academy of Aeons", id = 268465, spellID = 393273 },
    { name = L["DUNGEON_PLATFORM"] or "Mage's Terrace", id = 268466, spellID = 1254572 },
    { name = L["DUNGEON_NODE"] or "Zekvir's Lair", id = 268467, spellID = 1254563 },
    { name = L["DUNGEON_MINES"] or "Sarkareth's Lair", id = 268468, spellID = 1254555 },
    { name = L["DUNGEON_CONCLAVE"] or "Conclave of the Chosen", id = 268469, spellID = 1254551 },
    { name = L["DUNGEON_PEAK"] or "Nerub-ar Palace", id = 268470, spellID = 159898 },
    { name = L["DUNGEON_WINDRUNNER"] or "Windrunner's Spire", id = 268471, spellID = 1254400 },
    { name = L["DUNGEON_MESARA"] or "Mykazal's Den", id = 268473, spellID = 1254559 },
}

-- [新增] 辅助函数：格式化时间
local function FormatCooldownTime(seconds)
    if seconds >= 3600 then
        return string.format(L["TIME_HOUR"] or "%dh", math.floor(seconds / 3600))
    elseif seconds >= 60 then
        return string.format(L["TIME_MINUTE"] or "%dm", math.floor(seconds / 60))
    else
        return string.format(L["TIME_SECOND"] or "%ds", math.floor(seconds))
    end
end

-- [新增] 辅助函数：更新按钮状态 (冷却和去色)
local function UpdatePortalState(button, spellID)
    if InCombatLockdown() then return end
    
    -- 1. 更新冷却显示
    local spellCooldownInfo = C_Spell.GetSpellCooldown(spellID)
    if spellCooldownInfo and spellCooldownInfo.startTime > 0 and spellCooldownInfo.duration > 0 then
        local remaining = math.max(0, (spellCooldownInfo.startTime + spellCooldownInfo.duration) - GetTime())
        if remaining > 1.5 then -- 过滤公共CD
            button.cooldownText:SetText(FormatCooldownTime(remaining))
            button.cooldownOverlay:Show()
        else
            button.cooldownText:SetText("")
            button.cooldownOverlay:Hide()
        end
    else
        button.cooldownText:SetText("")
        button.cooldownOverlay:Hide()
    end

    -- 2. 更新去色状态 (未学会则变灰)
    local isKnown = IsSpellKnownOrOverridesKnown(spellID)
    if button.icon then
        button.icon:SetDesaturated(not isKnown)
    end
end


local function GetPlayerKey()
    return GetUnitName("player", true) .. "-" .. GetRealmName()
end

-- 3. 创建主面板
local f = CreateFrame("Frame", "VoidPoolPanel", UIParent, "BackdropTemplate")
f:SetSize(520, 350) 
f:SetPoint("CENTER")
f:SetMovable(true)
f:EnableMouse(true)
f:RegisterForDrag("LeftButton")
f:SetScript("OnDragStart", f.StartMoving)
f:SetScript("OnDragStop", f.StopMovingOrSizing)
f:Hide()

tinsert(UISpecialFrames, "VoidPoolPanel")

f:SetBackdrop({
    bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile = true, tileSize = 16, edgeSize = 16,
    insets = { left = 4, right = 4, top = 4, bottom = 4 }
})
f:SetBackdropColor(0, 0, 0, 0.9)

f.title = f:CreateFontString(nil, "OVERLAY", "GameFontNormal")
f.title:SetPoint("TOPLEFT", 125, -12)
f.title:SetText((L["CYAN_TEXT"] or "|cff00ffff") .. (L["PANEL_TITLE"] or "Void Pool Account-Wide Loot Query") .. "|r")

f.close = CreateFrame("Button", nil, f, "UIPanelCloseButton")
f.close:SetPoint("TOPRIGHT", 0, 0)

-- 【修改】扫描按钮：保持原位
f.scanBtn = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
f.scanBtn:SetSize(70, 30)
f.scanBtn:SetPoint("TOPRIGHT", -40, -40)
f.scanBtn:SetText(L["BUTTON_SYNC"] or "Sync")
f.scanBtn:SetScript("OnClick", function()
    f:ScanAndSave()
end)

-- [新增] 发送按钮：独立按钮，位于同步按钮下方
f.announceBtn = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
f.announceBtn:SetSize(70, 30)
f.announceBtn:SetPoint("TOP", f.scanBtn, "BOTTOM", 0, -200)
f.announceBtn:SetText(L["BUTTON_ANNOUNCE"] or "Announce")
f.announceBtn:SetScript("OnClick", function()
    f:Announce()
end)

-- 4. 创建左侧导航菜单
f.menu = CreateFrame("Frame", nil, f)
-- 修改：改为靠左对齐 (TOPLEFT)
f.menu:SetPoint("TOPLEFT", 10, -40) 
f.menu:SetSize(110, 340)

-- 在循环外部定义一个通用的点击反馈函数
local function OnPortalEnter(self)
    self.icon:SetVertexColor(1, 1, 1, 1) -- 确保不高亮时也能看到
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip:SetSpellByID(self.spellID)
    GameTooltip:Show()
end

local function OnPortalLeave(self)
    GameTooltip:Hide()
end

for i, data in ipairs(DUNGEON_LIST) do
    -- 1. 副本名字按钮 (保持不变)
    local btn = CreateFrame("Button", nil, f.menu, "UIPanelButtonTemplate")
    btn:SetSize(105, 28)
    -- 【修改】：为了给传送按钮留出空间，调整名字按钮的位置
    btn:SetPoint("TOPLEFT", 30, -(i-1) * 31)
    btn:SetText(data.name)
    btn:SetNormalFontObject("GameFontNormalSmall")
    btn:SetScript("OnClick", function()
        f.targetID = data.id
        f:Refresh()
    end)

    -- 2. [新增] 传送门按钮：直接以 f 为父级，避免 f.menu 拦截
    local portalBtn = CreateFrame("Button", nil, f, "SecureActionButtonTemplate")
    portalBtn:SetSize(26, 26)
    -- 依然相对于 btn 锚点，但父级是 f
    portalBtn:SetPoint("RIGHT", btn, "LEFT", -6, 0)
    
    -- 强制置顶图层
    portalBtn:SetFrameStrata("HIGH") 
    portalBtn:SetFrameLevel(f:GetFrameLevel() + 20)
    portalBtn:EnableMouse(true)
    -- 注册安全点击类型
    portalBtn:RegisterForClicks("AnyUp", "AnyDown")

    -- 图标贴图
    local tex = portalBtn:CreateTexture(nil, "ARTWORK")
    tex:SetAllPoints()
    local spellInfo = C_Spell.GetSpellInfo(data.spellID)
    tex:SetTexture(spellInfo and spellInfo.iconID or 136243) -- 136243 是一个默认图标ID
    tex:SetTexCoord(0.07, 0.93, 0.07, 0.93)
    portalBtn.icon = tex

    -- 冷却遮罩 (必须禁用鼠标，防止拦截)
    local cdOverlay = portalBtn:CreateTexture(nil, "OVERLAY")
    cdOverlay:SetAllPoints()
    cdOverlay:SetColorTexture(0, 0, 0, 0.6)
    cdOverlay:Hide()
    portalBtn.cooldownOverlay = cdOverlay

    local cdText = portalBtn:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    cdText:SetPoint("CENTER", 0, 0)
    portalBtn.cooldownText = cdText

    -- [核心安全属性] 必须在非战斗时设置
    portalBtn.spellID = data.spellID
    portalBtn:SetAttribute("type", "spell")
    portalBtn:SetAttribute("spell", data.spellID)

    -- 交互事件
    portalBtn:SetScript("OnEnter", OnPortalEnter)
    portalBtn:SetScript("OnLeave", OnPortalLeave)

    -- 状态刷新逻辑
    portalBtn:RegisterEvent("SPELLS_CHANGED")
    portalBtn:RegisterEvent("SPELL_UPDATE_COOLDOWN")
    portalBtn:SetScript("OnEvent", function(self) 
        UpdatePortalState(self, self.spellID) 
    end)
    
    UpdatePortalState(portalBtn, data.spellID)
end

-- 5. 滚动显示区
local scrollFrame = CreateFrame("ScrollFrame", "VoidPoolScrollFrame", f, "UIPanelScrollFrameTemplate")
-- 修改：左侧留出菜单宽度（125），右侧留出少量边距（20）
scrollFrame:SetPoint("TOPLEFT", 150, -40)
scrollFrame:SetPoint("BOTTOMRIGHT", -26, 20)

local content = CreateFrame("Frame", nil, scrollFrame)
-- 自动计算宽度：主窗口 450 - 菜单 125 - 右间距 20 = 约 305
content:SetSize(305, 1) 
scrollFrame:SetScrollChild(content)

f.text = content:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
-- 修改：锚点设为 TOP，实现水平居中
f.text:SetPoint("TOP", content, "TOP", 0, 0)
f.text:SetWidth(300)
f.text:SetJustifyH("LEFT")

-- 6. 右侧筛选下拉框
f.filterDropDown = CreateFrame("Frame", "VoidPoolFilterDropDown", f, "UIDropDownMenuTemplate")
f.filterDropDown:SetPoint("TOPRIGHT", -10, -8) -- 调整位置避开扫描按钮

local function FilterDropDown_Initialize(self, level)
    if not VoidPool_DB or not VoidPool_DB.lootData then return end
    local info = UIDropDownMenu_CreateInfo()
    local myKey = GetPlayerKey()

    info.text = L["BUTTON_SELECT_CHARACTER"] or "Select Character"
    info.isTitle = true
    info.notCheckable = true
    UIDropDownMenu_AddButton(info)

    local keys = {}
    for k in pairs(VoidPool_DB.lootData) do table.insert(keys, k) end
    table.sort(keys)

    for _, pKey in ipairs(keys) do
        info = UIDropDownMenu_CreateInfo()
        local nameOnly = pKey:match("([^-]+)") or pKey
        info.text = (pKey == myKey and (L["YOUR_CHARACTER"] or "|cff00ff00") or (L["OTHER_CHARACTER"] or "|cff00ccff")) .. nameOnly .. "|r"
        info.isNotRadio = false 
        info.keepShownOnClick = false 
        if VoidPool_DB.filter[pKey] == nil then VoidPool_DB.filter[pKey] = false end
        info.checked = VoidPool_DB.filter[pKey]
        
        info.func = function()
            for k in pairs(VoidPool_DB.filter) do VoidPool_DB.filter[k] = false end
            VoidPool_DB.filter[pKey] = true
            UIDropDownMenu_SetText(f.filterDropDown, nameOnly)
            f:Refresh()
        end
        UIDropDownMenu_AddButton(info)
    end
end

function f:UpdateFilterList()
    UIDropDownMenu_Initialize(f.filterDropDown, FilterDropDown_Initialize)
    UIDropDownMenu_SetWidth(f.filterDropDown, 90)
    local currentSelection = L["BUTTON_SELECT_CHARACTER"] or "Select Character"
    if VoidPool_DB and VoidPool_DB.filter then
        for k, v in pairs(VoidPool_DB.filter) do
            if v then currentSelection = k:match("([^-]+)") or k; break end
        end
    end
    UIDropDownMenu_SetText(f.filterDropDown, currentSelection)
end

-- 7. 扫描与刷新逻辑
local scanner = CreateFrame("GameTooltip", "VoidPoolScanner", nil, "GameTooltipTemplate")
scanner:SetOwner(WorldFrame, "ANCHOR_NONE")

-- 【核心修改】新增扫描并保存函数
function f:ScanAndSave()
    local itemID = self.targetID or DUNGEON_LIST[1].id
    local _, link = GetItemInfo(itemID)
    if not link then print((L["RED_TEXT"] or "|cffff0000") .. (L["MSG_DATA_NOT_READY"] or "[Void Query]: Data is not ready, please try again later") .. "|r"); return end

    scanner:ClearLines()
    scanner:SetHyperlink(link)

    local currentLoot = {}
    local foundHeader = false
    for i = 1, scanner:NumLines() do
        local leftLine = _G["VoidPoolScannerTextLeft"..i]
        if leftLine then
            local text = leftLine:GetText()
            if text and (text:find("- ") or text:find("· ") or text:find("• ") or text:find("%* ")) then
                table.insert(currentLoot, (L["PURPLE_TEXT"] or "|cffa335ee") .. text .. "|r")
                foundHeader = true
            end
        end
    end

    local myKey = GetPlayerKey()
    if foundHeader then
        if not VoidPool_DB.lootData[myKey] then VoidPool_DB.lootData[myKey] = {} end
        VoidPool_DB.lootData[myKey][itemID] = currentLoot
        print(string.format((L["YOUR_CHARACTER"] or "|cff00ff00") .. (L["MSG_SYNC_SUCCESS"] or "[Void Query]: %s data synced successfully") .. "|r", GetItemInfo(itemID)))
        f:Refresh() -- 扫描完刷新显示
    else
        print((L["RED_TEXT"] or "|cffff0000") .. (L["MSG_SYSTEM_LOADING"] or "[Void Query]: System is loading, please try again later") .. "|r")
    end
end


-- [新增] 独立通报逻辑：读取当前数据库显示的内容并发送
function f:Announce()
    local itemID = self.targetID or DUNGEON_LIST[1].id
    local name = GetItemInfo(itemID)
    if not name then return end

    local chatType = IsInGroup(LE_PARTY_CATEGORY_INSTANCE) and "INSTANCE_CHAT" 
                  or IsInRaid() and "RAID" 
                  or IsInGroup() and "PARTY"
    
    if not chatType then 
        print((L["RED_TEXT"] or "|cffff0000") .. (L["MSG_NO_GROUP"] or "[Void Query]: Not in a group, cannot announce") .. "|r")
        return 
    end

    local announced = false
    local keys = {}
    for k in pairs(VoidPool_DB.lootData) do table.insert(keys, k) end
    table.sort(keys)

    for _, pKey in ipairs(keys) do
        local pData = VoidPool_DB.lootData[pKey]
        -- 只通报当前选中的角色（或全部，遵循过滤规则）
        if VoidPool_DB.filter[pKey] ~= false and pData[itemID] and #pData[itemID] > 0 then
            if not announced then
                SendChatMessage(string.format(L["ANNOUNCE_HEADER"] or "=== Remaining Pool-%s ===", name), chatType)
                announced = true
            end
            
            SendChatMessage(string.format(L["ANNOUNCE_CHARACTER"] or "Character: %s", pKey), chatType)
            for _, lootLine in ipairs(pData[itemID]) do
                -- 清除颜色代码并发送
                local cleanText = lootLine:gsub("|c%x%x%x%x%x%x%x%x", ""):gsub("|r", "")
                SendChatMessage("  " .. cleanText, chatType)
            end
        end
    end

    if not announced then
        print((L["RED_TEXT"] or "|cffff0000") .. (L["MSG_NO_DATA"] or "[Void Query]: No data in database, cannot announce") .. "|r")
    end
end

-- 修改：Refresh 只负责从数据库提取数据显示
function f:Refresh()
    if not VoidPool_DB then VoidPool_DB = { lootData = {}, filter = {} } end
    
    local itemID = self.targetID or DUNGEON_LIST[1].id
    local name, link = GetItemInfo(itemID)
    scrollFrame:SetVerticalScroll(0)
    
    if not link then
        if C_Item and C_Item.RequestLoadItemDataByID then C_Item.RequestLoadItemDataByID(itemID) end
        f.text:SetText((L["RED_TEXT"] or "|cffff0000") .. (L["MSG_LOADING"] or "Loading... Please refresh") .. "|r")
        return
    end

    f.title:SetText((L["LOOT_REMAINING"] or "Remaining") .. (L["CYAN_TEXT"] or "|cff00ffff") .. name .. "|r")
    local myKey = GetPlayerKey()
    local displayLines = {}
    
    local keys = {}
    for k in pairs(VoidPool_DB.lootData) do table.insert(keys, k) end
    table.sort(keys)

    for _, pKey in ipairs(keys) do
        local pData = VoidPool_DB.lootData[pKey]
        if VoidPool_DB.filter[pKey] ~= false and pData[itemID] and #pData[itemID] > 0 then
            local color = (pKey == myKey) and (L["YOUR_CHARACTER"] or "|cff00ff00") or (L["OTHER_CHARACTER"] or "|cff00ccff")
            table.insert(displayLines, string.format(color .. (L["ANNOUNCE_CHARACTER"] or "Character: %s") .. "|r", pKey))
            for _, lootLine in ipairs(pData[itemID]) do
                table.insert(displayLines, "  " .. lootLine)
            end
            table.insert(displayLines, " ")
        end
    end

    if #displayLines > 0 then
        f.text:SetText(table.concat(displayLines, "\n"))
    else
        f.text:SetText((L["GRAY_TEXT"] or "|cff888888") .. (L["MSG_NO_RECORDS"] or "No records for this character in the database, please sync") .. "|r")
    end
    
    content:SetHeight(f.text:GetStringHeight() + 40)
end

-- 8. 小地图按钮逻辑 
local miniBtn = CreateFrame("Button", "VoidPoolMinimapButton", Minimap)
miniBtn:SetSize(31, 31)
miniBtn:SetFrameLevel(10)
miniBtn:SetHighlightTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight")

local icon = miniBtn:CreateTexture(nil, "BACKGROUND")
icon:SetTexture(7658128)
icon:SetSize(20, 20)
icon:SetPoint("CENTER", 0, 0)

local border = miniBtn:CreateTexture(nil, "OVERLAY")
border:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")
border:SetSize(53, 53)
border:SetPoint("TOPLEFT", 0, 0)

local function UpdateMinimapPos(angle)
    local radius = 100
    local x = cos(angle or 45) * radius
    local y = sin(angle or 45) * radius
    miniBtn:SetPoint("CENTER", Minimap, "CENTER", x, y)
end

miniBtn:SetMovable(true)
miniBtn:RegisterForDrag("LeftButton")
miniBtn:SetScript("OnDragStart", function(self) 
    self:LockHighlight()
    self:SetScript("OnUpdate", function()
        local mx, my = Minimap:GetCenter()
        local px, py = GetCursorPosition()
        local scale = Minimap:GetEffectiveScale()
        local angle = math.atan2(py/scale - my, px/scale - mx)
        if not VoidPool_MinimapDB then VoidPool_MinimapDB = {} end -- 确保数据库存在
        VoidPool_MinimapDB.angle = math.deg(angle)
        UpdateMinimapPos(VoidPool_MinimapDB.angle)
    end) 
end)

miniBtn:SetScript("OnDragStop", function(self) self:UnlockHighlight(); self:SetScript("OnUpdate", nil) end)

miniBtn:SetScript("OnClick", function(self, button)
    if button == "LeftButton" then
        if f:IsShown() then f:Hide() else 
            f:UpdateFilterList() 
            f:Show()
            f:Refresh() 
        end
    end
end)

-- 9. 初始化
f:RegisterEvent("ADDON_LOADED")
f:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" and arg1 == "VoidPoolTracker" then
        if not VoidPool_DB then VoidPool_DB = { lootData = {}, filter = {} } end
        if not VoidPool_MinimapDB then VoidPool_MinimapDB = { angle = 45 } end
        UpdateMinimapPos(VoidPool_MinimapDB.angle)
        
        for _, data in ipairs(DUNGEON_LIST) do
            C_Item.RequestLoadItemDataByID(data.id)
        end
        self:UnregisterEvent("ADDON_LOADED")
    end
end)

SLASH_VOIDPOOL1 = "/vp"
SlashCmdList["VOIDPOOL"] = function() 
    f:UpdateFilterList()
    if f:IsShown() then f:Hide() else f:Show(); f:Refresh() end 
end

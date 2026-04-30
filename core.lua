-- 1. 配置数据：副本宝箱列表
local DUNGEON_LIST = {
    { name = "艾杰斯亚学院", id = 268465 },
    { name = "魔导师平台",   id = 268466 },
    { name = "节点希纳斯",   id = 268467 }, -- id为物品id不是地图id
    { name = "萨隆矿坑",     id = 268468 },
    { name = "执政团之座",   id = 268469 },
    { name = "通天峰",       id = 268470 },
    { name = "风行者之塔",   id = 268471 },
    { name = "迈萨拉洞窟",   id = 268473 },
}

-- 2. 创建主面板
local f = CreateFrame("Frame", "VoidPoolPanel", UIParent, "BackdropTemplate")
f:SetSize(350, 360)
f:SetPoint("CENTER")
f:SetMovable(true)
f:EnableMouse(true)
f:RegisterForDrag("LeftButton")
f:SetScript("OnDragStart", f.StartMoving)
f:SetScript("OnDragStop", f.StopMovingOrSizing)
f:Hide()

tinsert(UISpecialFrames, "VoidPoolPanel") -- 支持 ESC 关闭

f:SetBackdrop({
    bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile = true, tileSize = 16, edgeSize = 16,
    insets = { left = 4, right = 4, top = 4, bottom = 4 }
})
f:SetBackdropColor(0, 0, 0, 0.9)

f.title = f:CreateFontString(nil, "OVERLAY", "GameFontNormal")
f.title:SetPoint("TOPLEFT", 115, -12)
f.title:SetText("|cff00ffff虚空宝箱查询|r")

f.close = CreateFrame("Button", nil, f, "UIPanelCloseButton")
f.close:SetPoint("TOPRIGHT", 0, 0)

-- 3. 创建左侧导航菜单
f.menu = CreateFrame("Frame", nil, f)
f.menu:SetPoint("TOPLEFT", 10, -40)
f.menu:SetSize(100, 300)

for i, data in ipairs(DUNGEON_LIST) do
    local btn = CreateFrame("Button", nil, f.menu, "UIPanelButtonTemplate")
    btn:SetSize(95, 25)
    btn:SetPoint("TOPLEFT", 0, -(i-1) * 28)
    btn:SetText(data.name)
    btn:SetNormalFontObject("GameFontNormalSmall")
    btn:SetScript("OnClick", function()
        f.targetID = data.id
        f:Refresh()
    end)
end

-- 4. 滚动显示区
local scrollFrame = CreateFrame("ScrollFrame", "VoidPoolScrollFrame", f, "UIPanelScrollFrameTemplate")
scrollFrame:SetPoint("TOPLEFT", 115, -40)
scrollFrame:SetPoint("BOTTOMRIGHT", -30, 20)

local content = CreateFrame("Frame", nil, scrollFrame)
content:SetSize(200, 1)
scrollFrame:SetScrollChild(content)

f.text = content:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
f.text:SetPoint("TOPLEFT", 5, 0)
f.text:SetWidth(190)
f.text:SetJustifyH("LEFT")

-- 5. 扫描逻辑
local scanner = CreateFrame("GameTooltip", "VoidPoolScanner", nil, "GameTooltipTemplate")
scanner:SetOwner(WorldFrame, "ANCHOR_NONE")

function f:Refresh()
    if not VoidPool_DB then VoidPool_DB = { lootData = {} } end
    local itemID = self.targetID or DUNGEON_LIST[1].id
    local name, link = GetItemInfo(itemID)
    scrollFrame:SetVerticalScroll(0)
    
    if not link then
        if C_Item and C_Item.RequestLoadItemDataByID then C_Item.RequestLoadItemDataByID(itemID) end
        f.text:SetText("|cffff0000加载中...请重试|r")
        return
    end

    f.title:SetText("|cff00ffff" .. name .. "|r")
    scanner:ClearLines()
    scanner:SetHyperlink(link)

    local currentLoot = {}
    local foundHeader = false
    for i = 1, scanner:NumLines() do
        local leftLine = _G["VoidPoolScannerTextLeft"..i]
        if leftLine then
            local text = leftLine:GetText()
            if text and (text:find("^- ") or text:find("^· ") or text:find("^• ") or text:find("^%* ")) then
                table.insert(currentLoot, "|cffffffff" .. text .. "|r")
                foundHeader = true
            end
        end
    end

    if foundHeader then
        VoidPool_DB.lootData[itemID] = currentLoot
    elseif VoidPool_DB.lootData[itemID] then
        currentLoot = VoidPool_DB.lootData[itemID]
    end

    if #currentLoot > 0 then
        f.text:SetText(table.concat(currentLoot, "\n\n"))
    else
        f.text:SetText(foundHeader and "|cff00ff00已全部收集完毕|r" or "|cff888888当前角色暂无记录|r")
    end
    content:SetHeight(f.text:GetStringHeight() + 20)
end

-- 6. [优化版] 小地图按钮逻辑
local miniBtn = CreateFrame("Button", "VoidPoolMinimapButton", Minimap)
miniBtn:SetSize(31, 31)
miniBtn:SetFrameLevel(10)
miniBtn:SetHighlightTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight")

-- 创建图标
local icon = miniBtn:CreateTexture(nil, "BACKGROUND")
icon:SetTexture(7658128)   --物品图标
icon:SetSize(21, 21)
icon:SetPoint("CENTER", 0, 0)

-- 创建边框
local border = miniBtn:CreateTexture(nil, "OVERLAY")
border:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")
border:SetSize(53, 53)
border:SetPoint("TOPLEFT", 0, 0)

-- [关键修复] 重新计算位置函数
local function UpdateMinimapPos(angle)
    local radius = 100 -- 小地图的半径，通常为 80 左右
    -- 根据角度计算 X 和 Y 的偏移量
    local x = cos(angle) * radius
    local y = sin(angle) * radius
    -- 这里的圆心对齐方式修正为 CENTER
    miniBtn:SetPoint("CENTER", Minimap, "CENTER", x, y)
end

miniBtn:SetMovable(true)
miniBtn:RegisterForDrag("LeftButton")

-- [关键修复] 拖拽逻辑：考虑 UI 缩放和小地图圆心
miniBtn:SetScript("OnDragStart", function(self) 
    self:LockHighlight()
    self:SetScript("OnUpdate", function()
        local mx, my = Minimap:GetCenter() -- 获取小地图中心在屏幕上的位置
        local px, py = GetCursorPosition() -- 获取鼠标当前位置
        local scale = Minimap:GetEffectiveScale() -- 获取小地图的实际缩放比例
        
        -- 计算相对坐标并转换成角度
        local angle = math.atan2(py/scale - my, px/scale - mx)
        local angleDeg = math.deg(angle)
        
        VoidPool_MinimapDB.angle = angleDeg
        UpdateMinimapPos(angleDeg)
    end) 
end)

miniBtn:SetScript("OnDragStop", function(self) 
    self:UnlockHighlight() 
    self:SetScript("OnUpdate", nil) 
end)

-- 按钮点击逻辑
miniBtn:SetScript("OnClick", function(self, button)
    if button == "LeftButton" then
        if f:IsShown() then f:Hide() else f:Show(); f:Refresh() end
    elseif button == "RightButton" then
        VoidPool_MinimapDB.angle = 45 -- 右键重置
        UpdateMinimapPos(45)
    end
end)

-- 鼠标悬停提示
miniBtn:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_LEFT")
    GameTooltip:AddLine("虚空宝箱查询")
    GameTooltip:AddLine("|cff00ff00左键拖动:|r 沿边缘移动", 1, 1, 1)
    GameTooltip:AddLine("|cff00ff00左键点击:|r 开关界面", 1, 1, 1)
    GameTooltip:AddLine("|cffff0000右键点击:|r 重置位置", 1, 1, 1)
    GameTooltip:Show()
end)
miniBtn:SetScript("OnLeave", GameTooltip_Hide)

-- 7. 初始化逻辑
f:RegisterEvent("ADDON_LOADED")
f:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" and arg1 == "VoidPoolTracker" then
        -- 初始化本地数据
        if not VoidPool_DB then VoidPool_DB = { lootData = {} } end
        
        -- 初始化小地图设置
        if not VoidPool_MinimapDB then VoidPool_MinimapDB = { angle = 45 } end
        UpdateMinimapPos(VoidPool_MinimapDB.angle)
        
        print("|cff00ffff[VoidPoolTracker]|r 加载成功！点击小地图图标或输入 /vp 使用。")
        self:UnregisterEvent("ADDON_LOADED")
    end
end)

-- 8. 指令
SLASH_VOIDPOOL1 = "/vp"
SlashCmdList["VOIDPOOL"] = function() if f:IsShown() then f:Hide() else f:Show(); f:Refresh() end end

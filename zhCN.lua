local addonName, addonTable = ...
-- 只有当前客户端语言匹配时才填充翻译
if GetLocale() ~= "zhCN" then return end
local L = {}

-- 面板标题
L["PANEL_TITLE"] = "虚空宝箱全账号查询"
L["LOOT_REMAINING"] = "剩余"

-- 按钮
L["BUTTON_SYNC"] = "同步"
L["BUTTON_ANNOUNCE"] = "发送"
L["BUTTON_SELECT_CHARACTER"] = "选择查看角色"
L["BUTTON_CLOSE"] = "关闭"

-- 副本名称
L["DUNGEON_KINGS_REST"] = "诸王之眠"
L["DUNGEON_TEMPLE_OF_SETHRALISS"] = "塞塔里斯神庙"
L["DUNGEON_RUBY_LIFE_POOLS"] = "红玉新生法池"
L["DUNGEON_THE_BLINDING_VALE"] = "夺目谷"
L["DUNGEON_VOIDSCAR_ARENA"] = "虚空之痕竞技场"
L["DUNGEON_DEN_OF_NALORAKK"] = "纳洛拉克的洞穴"
L["DUNGEON_MURDER_ROW"] = "密谋小径"
L["DUNGEON_ALTAR_OF_FANGS"] = "毒牙祭坛"

-- 系统消息
L["MSG_SYNC_SUCCESS"] = "[虚空查询]: %s 数据同步成功"
L["MSG_SYSTEM_LOADING"] = "[虚空查询]: 系统正在加载，请稍后再试"
L["MSG_DATA_NOT_READY"] = "[虚空查询]: 数据未就绪，请稍后再试"
L["MSG_NO_GROUP"] = "[虚空查询]: 未在队伍中，无法发送通报"
L["MSG_NO_DATA"] = "[虚空查询]: 数据库中暂无记录，无法通报"
L["MSG_LOADING"] = "加载中...请刷新"
L["MSG_NO_RECORDS"] = "数据库中暂无该角色记录，请点击右上角同步当前数据"

-- 聊天通报
L["ANNOUNCE_HEADER"] = "=== 剩余奖池-%s ==="
L["ANNOUNCE_CHARACTER"] = "角色: %s"

-- 字体颜色
L["YOUR_CHARACTER"] = "|cff00ff00"  -- 绿色
L["OTHER_CHARACTER"] = "|cff00ccff" -- 青色
L["GRAY_TEXT"] = "|cff888888"       -- 灰色
L["RED_TEXT"] = "|cffff0000"        -- 红色
L["PURPLE_TEXT"] = "|cffa335ee"     -- 紫色
L["CYAN_TEXT"] = "|cff00ffff"       -- 青色

-- 时间格式
L["TIME_HOUR"] = "%d小时"
L["TIME_MINUTE"] = "%d分"
L["TIME_SECOND"] = "%d秒"

-- 将 L 挂载到插件命名空间，供 core.lua 使用
addonTable.L = L

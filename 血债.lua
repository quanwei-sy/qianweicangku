local VERSION = "v1.0"
if _G.BloodDebtESP and _G.BloodDebtESP.Destroy then pcall(_G.BloodDebtESP.Destroy) _G.BloodDebtESP = nil end
-- 提前放置运行标记，避免界面库网络加载期间的后台任务误退出。
_G.BloodDebtESP = {Version = VERSION}

local Players    = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS        = game:GetService("UserInputService")
local CS         = game:GetService("CollectionService")
local LP         = Players.LocalPlayer

local STATE = {
    Enabled = false,
    Outline = false,
    Details = false,
    Loot    = false,
    ShowFOV = false,
    Silent  = false,
    NoSpread  = false,
    NoRecoil  = false,
    QuickPull = false,
    HitMarker = false,
    Fly       = false,
    Walk      = false,
    InfJump   = false,
    Noclip    = false,
    Wallbang  = false,
    WallbangV2 = false,
    FastReload = false,
    RapidFire  = false,
    ForceFireMode = false,
    FireRate   = 0.1,
    MultiShot  = 1,
    Hitbox     = false,
    HitboxSize = 2.0,
    Freecam    = false,
    Fov        = 70,
    FovOverride = false,
    RespawnOnSpot = true,
    MapEdit = false,
    NoFall     = false,
    GunHud     = false,
    ThirdPerson = false,
    ResetKnocked = false,
    NoInvHide  = false,
    HitSounds  = false,
    ModDetect  = false,
    BulletShow = false,
    IgnoreSpawn = false,
    FlySpeed  = 60,
    WalkSpeed = 16,
    Scale   = 1.0,
    MenuAlpha = 0.95,   -- 菜单透明度（0=全实 0.95=很透）
}

local AIM_HOOKS = {}
local AIM_OVERRIDE = nil
-- 保存钩子原函数与替换函数，供统一卸载时恢复。
local originalNamecall, hookedNamecall
local originalRaycast, hookedRaycast
local originalRequire, hookedRequire
local mouseMeta, originalMouseIndex, hookedMouseIndex

local FEATURE_KEYS = {
    Fly     = Enum.KeyCode.Unknown,
    Walk    = Enum.KeyCode.Unknown,
    InfJump = Enum.KeyCode.Unknown,
    Noclip  = Enum.KeyCode.Unknown,
}

local CONFIG = {
    SafeMode    = true,   -- 限制速度/加速度，降低被服务器判定为异常的概率
    MaxWalk     = 40,
    MaxFly      = 55,
    MaxVertFly  = 35,
    TagDistance = 3000,
    MarkUnknown = true,
    Debug       = false,
    MenuKey     = Enum.KeyCode.K,
    ScaleStep   = 0.15,
    ScaleMin    = 0.4,
    ScaleMax    = 3.0,
    TagOnlyDistance = 100,  -- 超过这个距离只显示名牌
    LootRange   = 80,    -- 物品识别半径（studs）
    LootScanEvery = 0.8,   -- 掉落物扫描间隔（秒）
    MaxLoot     = 80,      -- 掉落物最多处理多少个
    FPS         = 20,      -- 玩家 ESP 刷新频率

    AimKey        = Enum.KeyCode.Q,   -- 按住此键自动瞄准
    AimFOVStep    = 20,
    AimFOVMin     = 40,
    AimFOVMax     = 800,
    AimFireWindow = 0.6,
}


local COL = {
    Sheriff  = Color3.fromRGB(45, 130, 255),
    Murderer = Color3.fromRGB(255, 45, 45),
    Innocent = Color3.fromRGB(255, 255, 255),
    Unknown  = Color3.fromRGB(255, 190, 40),
    Loot     = Color3.fromRGB(255, 215, 70),
    Task     = Color3.fromRGB(255, 230, 60),
    -- 通用模式
    Red      = Color3.fromRGB(255, 70, 70),
    Blue     = Color3.fromRGB(80, 150, 255),
    Green    = Color3.fromRGB(90, 220, 120),
    Neutral  = Color3.fromRGB(215, 215, 215),
    -- 特殊
    Spawn    = Color3.fromRGB(255, 120, 200),
}

-- 瞄准设置
local AIM = {
    FOV        = 220,
    Method     = "Regular",
    HitChance  = 100,
    HeadChance = 60,          -- 屏幕半径（像素）
    TargetRole = "Murderer",   -- Murderer / Sheriff / All
    PartName   = "Head",       -- 优先瞄头
}

--==================== 武器池 ======================================
local POLICE, KILLER = {}, {}
local function norm(s) s = string.lower(tostring(s)) s = s:gsub("['\"]","") s = s:gsub("%s+"," ") return s end
local function add(t, ...) for _, n in ipairs({...}) do t[norm(n)] = true end end

add(POLICE,
    "J9a1 Meretta","J9-Merretta","GG-17","Dual GG-17s","GG-17 TAN","Pretty Pink GG-17",
    "Gild GG-17","HWISSH-226 SHIELD","PRIDE H-226 SHIELD","GG-26","Dual Merettas",
    "Gild J9a1 M","KriegsHerr-9","R&E Snubby","Steel R&E Snubby","R&E M10",
    "IZVEKH-412","Beagle-50","Beagle-44","Paradise","ZKZ-Obrez","Gild ZKZ-Obrez",
    "Unioned ZKZ-Obrez","SAKURA ZKZ-Obrez","H&W-MPi5K","JS-5A-Obrez","SHOT-7",
    "SWAG-7","Buxxberg-COMPACT","ANKO46","Dual Elites")

add(KILLER,
    "JS2-Derringy","JS-2 Derringy","410BONDS-Derringy","Cute JS2-Derringy","WISP","Fleet-K51",
    "Whizz","JS1-CYCLOPS","Jolibri","Memories","Pol357","Sawn-off","Sawed-Off",
    "Clothed Sawed Off","JS","JS2","JS-22","Gild JS-22","Gilded JS-22","Cool JS-22",
    "Charcoal Steel JS-22","JS1-Competitor","Door'bler","Mandols-5","Sawed-THUMPA",
    "FT100","Lenitrovyak","RR-LCP","Pretty Pink RR-LCP","Chromeslide","Kamatov",
    "Rosen Obrez","Clothed Obrez","K1911","Silver steel K1911","PTRB-41")

local MELEE = {"knife","bat","pipe","machete","axe","crowbar","shovel","hammer",
               "screwdriver","razor","blade","club","bottle","brick","chair","pan",
               "刀","棍","棒","斧","锤","铲","剑","钳"}
local unknownWeapons = {}

local function isMelee(name)
    local s = norm(name)
    for _, k in ipairs(MELEE) do if string.find(s, k, 1, true) then return true end end
    return false
end

local function classify(name)
    local n = norm(name)
    if n == "" then return nil end
    if POLICE[n] then return "Sheriff" end
    if KILLER[n] then return "Murderer" end
    -- 精确匹配失败后再做一次「前缀相同」的严格比对（皮肤后缀等）
    for k in pairs(POLICE) do
        if #n >= #k and string.sub(n, 1, #k) == k then return "Sheriff" end
    end
    for k in pairs(KILLER) do
        if #n >= #k and string.sub(n, 1, #k) == k then return "Murderer" end
    end
    return nil
end

local GUN_KEYS = {"gun", "rifle", "pistol", "revolver", "shotgun", "smg",
                  "sniper", "carbine", "weapon", "机枪", "步枪", "手枪", "霰弹"}

local function isGun(name)
    if classify(name) then return true end
    local n = string.lower(tostring(name))
    for _, k in ipairs(GUN_KEYS) do
        if string.find(n, k, 1, true) then return true end
    end
    return false
end

local function noteUnknown(name)
    if not name or name == "" or isMelee(name) then return end
    if unknownWeapons[name] then return end
    unknownWeapons[name] = true
    if CONFIG.Debug then print(("[ESP] 未收录武器: %s"):format(name)) end
end

-- 阵营模式：不同模式用各自的词表，互不混用
local CURRENT_MODE = "blood"

local MODE_WORDS = {
    blood = {
        order = {"Murderer", "Sheriff", "Innocent"},
        words = {
            Murderer = {"killer", "murder", "assassin", "traitor", "juggernaut", "attacker",
                        "syndicate", "mafia", "hunter", "criminal", "roamer",
                        "knife", "blade", "dagger", "cleaver", "machete", "katana",
                        "杀手", "凶手", "暴徒", "攻击", "亡命", "血债", "罪犯", "刀", "匕首", "砍刀"},
            Sheriff  = {"vigilante", "vigil", "sheriff", "detective", "police", "cop",
                        "guard", "defender", "marshal", "officer",
                        "revolver", "pistol", "handgun", "magnum", "deagle",
                        "警长", "警察", "警探", "侦探", "守卫", "防御", "执法", "手枪", "左轮"},
            Innocent = {"bystander", "innocent", "civilian", "survivor", "villager",
                        "平民", "好人", "旁观", "村民", "幸存"},
        },
    },
    generic = {
        order = {"Red", "Blue", "Green", "Neutral"},
        words = {
            Red     = {"red", "attack", "attacker", "enemy", "raider", "rebel", "hunter",
                       "anarch", "chaos", "destroyer",
                       "红", "攻", "敌", "破坏", "猎"},
            Blue    = {"blue", "defend", "defender", "ally", "guard", "police", "security",
                       "survivor", "rescue", "protect",
                       "蓝", "守", "友", "警", "保护"},
            Green   = {"green", "neutral", "civilian", "innocent", "town",
                       "绿", "中立", "平民"},
            Neutral = {"neutral", "spectator", "unknown", "中立", "旁观"},
        },
    },
}

local function wordSet()
    return MODE_WORDS[CURRENT_MODE] or MODE_WORDS.blood
end

local function hitRoleString(str)
    local set = wordSet()
    local low = string.lower(tostring(str or ""))
    for _, role in ipairs(set.order) do
        for _, w in ipairs(set.words[role] or {}) do
            if string.find(low, string.lower(w), 1, true) then
                return role
            end
        end
    end
    return nil
end

local function detectMode()
    for _, p in ipairs(Players:GetPlayers()) do
        local t = ""
        pcall(function() t = p.Team and string.lower(p.Team.Name) or "" end)
        if t ~= "" then
            if string.find(t, "killer", 1, true) or string.find(t, "murder", 1, true)
                or string.find(t, "sheriff", 1, true) or string.find(t, "innocent", 1, true) then
                return "blood"
            end

        end
        local char = p.Character
        if char then
            local ok, v = pcall(function() return char:GetAttribute("Role") end)
            if ok and type(v) == "string" then
                local lv = string.lower(v)
                if string.find(lv, "killer", 1, true) or string.find(lv, "murder", 1, true)
                    or string.find(lv, "sheriff", 1, true) or string.find(lv, "innocent", 1, true) then
                    return "blood"
                end
            end
        end
    end
    return "blood"
end

task.spawn(function()
    task.wait(3)
    while _G.BloodDebtESP do
        local m = detectMode()
        if m ~= CURRENT_MODE then CURRENT_MODE = m end
        task.wait(3)
    end
end)

local function scanValues(obj)
    if not obj then return nil end
    for _, v in ipairs(obj:GetChildren()) do
        if v:IsA("StringValue") or v:IsA("IntValue") then
            local r = hitRoleString(tostring(v.Value)) or hitRoleString(v.Name)
            if r then return r, "value:" .. v.Name .. "=" .. tostring(v.Value) end
        end
    end
    return nil
end

local function attrRole(obj)
    if not obj then return nil end
    local ok, attrs = pcall(function() return obj:GetAttributes() end)
    if ok and type(attrs) == "table" then
        for k, v in pairs(attrs) do
            if v ~= false and v ~= nil then
                local r = hitRoleString(tostring(k) .. "=" .. tostring(v))
                if r then return r, ("attr.%s=%s"):format(tostring(k), tostring(v)) end
            end
        end
    end
    return nil
end

local overrides, cache = {}, {}
local LAST_RENDER_ERR = nil

local function scanTree(root, depth)
    local out = {}
    local function walk(obj, d)
        if d > depth then return end
        local ok, kids = pcall(function() return obj:GetChildren() end)
        if not ok or not kids then return end
        for _, c in ipairs(kids) do
            out[#out + 1] = c
            walk(c, d + 1)
        end
    end
    walk(root, 1)
    return out
end

local function getRole(player)
    local char = player.Character
    if overrides[player] then return overrides[player], "手动覆盖" end
    if not char then return "Innocent", "no-char" end

    local c = cache[player]
    if c and c.char == char then
        if c.role and c.role ~= "Innocent" and c.role ~= "Unknown" then return c.role, c.src end
        if (os.clock() - (c.t or 0)) < 0.5 then return c.role or "Innocent", c.src or "cached" end
    end

    local r, src = attrRole(player)
    if not r then r, src = attrRole(char) end
    if r then cache[player] = {char=char, role=r, src=src, t=os.clock()} return r, src end

    local team
    pcall(function() team = char:GetAttribute("Team") end)
    if type(team) == "string" and #team > 0 then
        r = hitRoleString(team)
        if r then cache[player] = {char=char, role=r, src="Team="..team, t=os.clock()} return r, "Team="..team end
    end

    -- 团队对象（TeamWar / Shooter 等模式）
    if player.Team then
        r = hitRoleString(player.Team.Name)
        if r then cache[player] = {char=char, role=r, src="TeamObj="..player.Team.Name, t=os.clock()} return r, "TeamObj="..player.Team.Name end
        local tc = tostring(player.Team.TeamColor)
        if tc == "Bright red" or tc == "Really red" then
            cache[player] = {char=char, role="Murderer", src="TeamColor红", t=os.clock()}
            return "Murderer", "TeamColor红"
        elseif tc == "Bright blue" or tc == "Really blue" then
            cache[player] = {char=char, role="Sheriff", src="TeamColor蓝", t=os.clock()}
            return "Sheriff", "TeamColor蓝"
        end
    end

    -- 角色 / 玩家下的 StringValue（Role、RoleName、Class 等）
    do
        local vr, vsrc = scanValues(char)
        if not vr then vr, vsrc = scanValues(player) end
        if vr then cache[player] = {char=char, role=vr, src=vsrc, t=os.clock()} return vr, vsrc end
    end

    -- 角色上的 UI 文本（游戏名牌有时直接写身份）
    do
        local ok, list = pcall(function() return char:GetDescendants() end)
        if ok and list then
            for _, d in ipairs(list) do
                if d:IsA("TextLabel") and #tostring(d.Text) <= 24 then
                    local hr = hitRoleString(d.Text)
                    if hr then
                        cache[player] = {char=char, role=hr, src="ui:"..tostring(d.Text), t=os.clock()}
                        return hr, "ui:"..tostring(d.Text)
                    end
                end
            end
        end
    end

    -- 背包优先：按背包里的武器判定阵营（杀手是刀类，警长是枪类）
    do
        local bp = player:FindFirstChildOfClass("Backpack")
        if bp then
            local lastUnknown = nil
            local ok, list = pcall(function() return bp:GetDescendants() end)
            if ok and list then
                for _, t in ipairs(list) do
                    if t:IsA("Tool") then
                        local hit = classify(t.Name)
                        if hit == "Murderer" then
                            cache[player] = {char=char, role="Murderer", src="背包:"..t.Name, t=os.clock()}
                            return "Murderer", "背包:"..t.Name
                        elseif hit == "Sheriff" then
                            cache[player] = {char=char, role="Sheriff", src="背包:"..t.Name, t=os.clock()}
                            return "Sheriff", "背包:"..t.Name
                        else
                            lastUnknown = t.Name
                        end
                    end
                end
            end
            if lastUnknown then noteUnknown(lastUnknown) end
        end
    end

    -- 手持武器（背包读不到时的补充）
    local tool = char:FindFirstChildOfClass("Tool")
    if tool then
        r = classify(tool.Name)
        if r then cache[player] = {char=char, role=r, src="手持:"..tool.Name, t=os.clock()} return r, "手持:"..tool.Name end
        noteUnknown(tool.Name)
    end

    -- 角色模型上的武器不计入判定（只认背包与手持）

    if tool then
        cache[player] = {char=char, role="Unknown", src="未知枪:"..tool.Name, t=os.clock()}
        return "Unknown", "未知枪:"..tool.Name
    end

    r = hitRoleString(player.Name) or hitRoleString(player.DisplayName) or hitRoleString(char.Name)
    if r then cache[player] = {char=char, role=r, src="name", t=os.clock()} return r, "name" end

    cache[player] = {char=char, role="Innocent", src="default", t=os.clock()}
    return "Innocent", "default"
end

--==================== 任务状态 ====================================
local TASK_WORDS = {"objective", "task", "mission", "quest", "working",
                    "doingtask", "hastask", "onmission",
                    "任务", "工作", "目标", "委托"}

local function isDoingTask(player)
    local targets = {player.Character, player}
    for _, obj in ipairs(targets) do
        if obj then
            local ok, attrs = pcall(function() return obj:GetAttributes() end)
            if ok and attrs then
                for k, v in pairs(attrs) do
                    local str = string.lower(tostring(k)) .. " " .. string.lower(tostring(v))
                    for _, w in ipairs(TASK_WORDS) do
                        if string.find(str, w, 1, true) then return true end
                    end
                end
            end
            for _, d in ipairs(obj:GetChildren()) do
                if d:IsA("BoolValue") and d.Value then
                    local n = string.lower(d.Name)
                    for _, w in ipairs(TASK_WORDS) do
                        if string.find(n, w, 1, true) then return true end
                    end
                elseif d:IsA("StringValue") or d:IsA("IntValue") then
                    local str = string.lower(d.Name) .. " " .. string.lower(tostring(d.Value))
                    for _, w in ipairs(TASK_WORDS) do
                        if string.find(str, w, 1, true) then return true end
                    end
                end
            end
        end
    end
    return false
end

--==================== 容器 ========================================
local hui
do
    local ok, res = pcall(function()
        if type(gethui) == "function" then return gethui() end
        return game:GetService("CoreGui")
    end)
    if ok then hui = res end
    if not hui then hui = LP:FindFirstChildOfClass("PlayerGui") or LP:WaitForChild("PlayerGui") end
end

local holder = Instance.new("Folder")
holder.Name = "BD_" .. tostring(math.random(100000, 999999))
holder.Parent = hui

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "BD_ESP_Layer"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.DisplayOrder = 9999
do
    local ok = pcall(function() screenGui.Parent = hui end)
    if not ok then
        screenGui.Parent = LP:FindFirstChildOfClass("PlayerGui") or LP:WaitForChild("PlayerGui")
    end
end


--==================== NothingLibrary 中文控制窗口 ====================
local refreshAll
local killAntiCheat
local menu = {}
local menuConns = {}
local uiReady, destroyed = false, false
local Windows, mainWindowGui

do
local repainting = false
local toggleControls, toggleValues = {}, {}
local NothingLibrary = loadstring(game:HttpGetAsync('https://raw.githubusercontent.com/quanwei-sy/qianweicangku/refs/heads/main/%E6%BA%90%E7%A0%81.lua'))()
Windows = NothingLibrary.new({
    Title = "TY hub",
    Description = "血债 | 中文功能菜单",
    Keybind = CONFIG.MenuKey,
    Logo = "http://www.roblox.com/asset/?id=18898582662",
    Size = UDim2.new(0.1, 650, 0.1, 430),
})

mainWindowGui = hui:FindFirstChild("RobloxGameGui")
if not mainWindowGui then
    local playerGui = LP:FindFirstChildOfClass("PlayerGui")
    mainWindowGui = playerGui and playerGui:FindFirstChild("RobloxGameGui") or nil
end

local function newTab(title, description, icon)
    return Windows:NewTab({Title = title, Description = description, Icon = icon})
end

local function newSection(tab, title, position)
    return tab:NewSection({
        Title = title,
        Icon = "rbxassetid://7743869054",
        Position = position or "Left",
    })
end

local function addToggle(section, title, key)
    local control
    control = section:NewToggle({
        Title = title,
        Default = STATE[key],
        Callback = function(value)
            if destroyed then return end
            STATE[key] = value and true or false
            toggleValues[key] = STATE[key]
            if key == "Enabled" and STATE.Enabled then
                STATE.Outline = true
                STATE.Details = true
            end
            if uiReady and not repainting and refreshAll then
                pcall(refreshAll)
            end
        end,
    })
    toggleControls[key] = control
    toggleValues[key] = STATE[key]
    return control
end

local function addSlider(section, title, minimum, maximum, default, callback)
    return section:NewSlider({
        Title = title,
        Min = minimum,
        Max = maximum,
        Default = default,
        Callback = function(value)
            if not destroyed then pcall(callback, value) end
        end,
    })
end

local function addKeybind(section, title, default, callback)
    return section:NewKeybind({
        Title = title,
        Default = default,
        Callback = function(value)
            if not destroyed then pcall(callback, value) end
        end,
    })
end

local function addButton(section, title, callback)
    return section:NewButton({
        Title = title,
        Callback = function()
            if not destroyed then pcall(callback) end
        end,
    })
end

menu.repaint = function()
    if repainting or destroyed then return end
    repainting = true
    for key, control in pairs(toggleControls) do
        if toggleValues[key] ~= STATE[key] then
            pcall(function() control.Value(STATE[key]) end)
            toggleValues[key] = STATE[key]
        end
    end
    repainting = false
end

menu.toggle = function()
    if mainWindowGui and mainWindowGui.Parent then
        pcall(function() mainWindowGui.Enabled = not mainWindowGui.Enabled end)
    end
end

local aimTab = newTab("瞄准", "静默瞄准与目标设置", "rbxassetid://7733960981")
local weaponTab = newTab("武器", "武器改动与射击设置", "rbxassetid://7733964640")
local hitboxTab = newTab("命中", "命中框扩展", "rbxassetid://7733955740")
local playerTab = newTab("玩家", "移动、视角与按键", "rbxassetid://7733964719")
local visualTab = newTab("视觉", "玩家透视与命中反馈", "rbxassetid://7733774602")
local miscTab = newTab("杂项", "阵营、调试与脚本管理", "rbxassetid://7734021893")
local aboutTab = newTab("关于", "作者信息", "rbxassetid://7733964719")

local aimMain = newSection(aimTab, "静默瞄准", "Left")
local aimTarget = newSection(aimTab, "目标与按键", "Right")
addToggle(aimMain, "静默瞄准", "Silent")
addToggle(aimMain, "忽略出生保护", "IgnoreSpawn")
addToggle(aimMain, "显示瞄准 FOV 圈", "ShowFOV")
local methodLabels = {Regular = "常规弹道", Teleport = "传送弹道"}
local methodValues = {["常规弹道"] = "Regular", ["传送弹道"] = "Teleport"}
aimMain:NewDropdown({
    Title = "瞄准方式",
    Data = {"常规弹道", "传送弹道"},
    Default = methodLabels[AIM.Method] or "常规弹道",
    Callback = function(value)
        if not destroyed then AIM.Method = methodValues[value] or value end
    end,
})
addSlider(aimMain, "命中率（%）", 0, 100, AIM.HitChance, function(value)
    AIM.HitChance = math.floor(value)
end)
addSlider(aimMain, "爆头率（%）", 0, 100, AIM.HeadChance, function(value)
    AIM.HeadChance = math.floor(value)
end)
addSlider(aimMain, "瞄准 FOV（像素）", CONFIG.AimFOVMin, CONFIG.AimFOVMax, AIM.FOV, function(value)
    AIM.FOV = math.clamp(math.floor(value), CONFIG.AimFOVMin, CONFIG.AimFOVMax)
end)
local targetRoleLabels = {Murderer = "杀手", Sheriff = "警长", All = "所有人"}
local targetRoleValues = {["杀手"] = "Murderer", ["警长"] = "Sheriff", ["所有人"] = "All"}
aimTarget:NewDropdown({
    Title = "瞄准目标身份",
    Data = {"杀手", "警长", "所有人"},
    Default = targetRoleLabels[AIM.TargetRole] or "杀手",
    Callback = function(value)
        if not destroyed then AIM.TargetRole = targetRoleValues[value] or value end
    end,
})
addKeybind(aimTarget, "自动瞄准按键", CONFIG.AimKey, function(value)
    CONFIG.AimKey = value
end)
aimTarget:NewTitle("按住瞄准按键或鼠标开火时，原瞄准逻辑才会生效。")

local weaponMain = newSection(weaponTab, "武器功能", "Left")
local weaponNumbers = newSection(weaponTab, "射击参数", "Right")
addToggle(weaponMain, "穿墙射击", "Wallbang")
addToggle(weaponMain, "穿墙射击 V2", "WallbangV2")
addToggle(weaponMain, "无扩散", "NoSpread")
addToggle(weaponMain, "无后坐力", "NoRecoil")
addToggle(weaponMain, "快速拔枪", "QuickPull")
addToggle(weaponMain, "快速换弹", "FastReload")
addToggle(weaponMain, "快速射击", "RapidFire")
addToggle(weaponMain, "强制射击模式", "ForceFireMode")
addToggle(weaponMain, "子弹显示", "BulletShow")
addSlider(weaponNumbers, "射速间隔（0.01 秒）", 3, 50, math.floor(STATE.FireRate * 100), function(value)
    STATE.FireRate = math.clamp(value, 3, 50) / 100
end)
addSlider(weaponNumbers, "多重弹丸数量", 1, 8, STATE.MultiShot, function(value)
    STATE.MultiShot = math.floor(value)
end)

local hitboxMain = newSection(hitboxTab, "命中框", "Left")
local hitboxInfo = newSection(hitboxTab, "说明", "Right")
addToggle(hitboxMain, "命中框扩展", "Hitbox")
addSlider(hitboxMain, "命中框倍数（0.1 倍）", 10, 60, math.floor(STATE.HitboxSize * 10), function(value)
    STATE.HitboxSize = math.clamp(value, 10, 60) / 10
end)
hitboxInfo:NewTitle("放大其他玩家头部碰撞体，可配合静默瞄准与穿墙射击使用。")

local movementMain = newSection(playerTab, "移动功能", "Left")
local movementKeys = newSection(playerTab, "移动按键", "Right")
addToggle(movementMain, "飞行", "Fly")
addSlider(movementMain, "飞行速度", 10, 200, STATE.FlySpeed, function(value)
    local number = math.floor(value)
    if CONFIG.SafeMode and number > CONFIG.MaxFly then number = CONFIG.MaxFly end
    STATE.FlySpeed = number
end)
addToggle(movementMain, "加速", "Walk")
addSlider(movementMain, "移动速度", 8, 200, STATE.WalkSpeed, function(value)
    local number = math.floor(value)
    if CONFIG.SafeMode and number > CONFIG.MaxWalk then number = CONFIG.MaxWalk end
    STATE.WalkSpeed = number
end)
addToggle(movementMain, "无限跳", "InfJump")
addToggle(movementMain, "穿墙", "Noclip")
addToggle(movementMain, "无坠落伤害", "NoFall")
addKeybind(movementKeys, "飞行切换按键", FEATURE_KEYS.Fly, function(value)
    FEATURE_KEYS.Fly = value
end)
addKeybind(movementKeys, "加速切换按键", FEATURE_KEYS.Walk, function(value)
    FEATURE_KEYS.Walk = value
end)
addKeybind(movementKeys, "无限跳切换按键", FEATURE_KEYS.InfJump, function(value)
    FEATURE_KEYS.InfJump = value
end)
addKeybind(movementKeys, "穿墙切换按键", FEATURE_KEYS.Noclip, function(value)
    FEATURE_KEYS.Noclip = value
end)

local cameraMain = newSection(playerTab, "视角功能", "Left")
addToggle(cameraMain, "自由视角", "Freecam")
addToggle(cameraMain, "锁定视野", "FovOverride")
addSlider(cameraMain, "视野 FOV", 40, 120, STATE.Fov, function(value)
    STATE.Fov = math.floor(value)
end)

local visualMain = newSection(visualTab, "玩家透视", "Left")
local visualExtra = newSection(visualTab, "显示参数", "Right")
addToggle(visualMain, "玩家透视", "Enabled")
addToggle(visualMain, "轮廓", "Outline")
addToggle(visualMain, "人物详情", "Details")
addToggle(visualMain, "伤害数字", "HitMarker")
addToggle(visualMain, "枪械 HUD", "GunHud")
addToggle(visualMain, "命中音效", "HitSounds")
addSlider(visualExtra, "透视文字大小（%）", 40, 300, math.floor(STATE.Scale * 100), function(value)
    STATE.Scale = math.clamp(value, 40, 300) / 100
end)
addSlider(visualExtra, "透视刷新率（FPS）", 5, 60, CONFIG.FPS, function(value)
    CONFIG.FPS = math.clamp(math.floor(value), 5, 60)
end)

local miscMain = newSection(miscTab, "角色与地图", "Left")
local statusSection = newSection(miscTab, "运行状态", "Right")
addToggle(miscMain, "第三人称", "ThirdPerson")
addToggle(miscMain, "倒地自动重置", "ResetKnocked")
addToggle(miscMain, "原地复活", "RespawnOnSpot")
addToggle(miscMain, "删除地图资源", "MapEdit")
addToggle(miscMain, "不隐藏物品栏", "NoInvHide")
addToggle(miscMain, "模组检测", "ModDetect")
miscMain:NewToggle({
    Title = "安全速度限制",
    Default = CONFIG.SafeMode,
    Callback = function(value)
        if not destroyed then CONFIG.SafeMode = value and true or false end
    end,
})

local sessionStart = os.clock()
local statusTitle = statusSection:NewTitle("正在读取运行状态……")
local modTitle = statusSection:NewTitle("")
addButton(statusSection, "阵营扫描", function()
    if _G.BloodDebtESP and _G.BloodDebtESP.RoleScan then
        _G.BloodDebtESP.RoleScan()
    end
end)
addButton(statusSection, "禁用守卫脚本", function()
    local hit = killAntiCheat and killAntiCheat() or {}
    print(("[血债] 已禁用可疑脚本：%d"):format(#hit))
end)
addButton(statusSection, "输出最后渲染错误", function()
    if _G.BloodDebtESP and _G.BloodDebtESP.LastError then
        _G.BloodDebtESP.LastError()
    end
end)

local roleSection = newSection(miscTab, "玩家身份覆盖", "Left")
local selectedPlayerName = LP.Name
local selectedOverrideLabel = "自动"
local function playerNameList()
    local list = {}
    for _, player in ipairs(Players:GetPlayers()) do
        list[#list + 1] = player.Name
    end
    if #list == 0 then list[1] = "无玩家" end
    return list
end
local initialPlayers = playerNameList()
if not table.find(initialPlayers, selectedPlayerName) then selectedPlayerName = initialPlayers[1] end
local playerDropdown = roleSection:NewDropdown({
    Title = "选择玩家",
    Data = initialPlayers,
    Default = selectedPlayerName,
    Callback = function(value)
        selectedPlayerName = tostring(value)
    end,
})
roleSection:NewDropdown({
    Title = "手动身份",
    Data = {"自动", "杀手", "警长", "平民"},
    Default = "自动",
    Callback = function(value)
        selectedOverrideLabel = tostring(value)
    end,
})
local overrideValues = {["杀手"] = "Murderer", ["警长"] = "Sheriff", ["平民"] = "Innocent"}
local function findSelectedPlayer()
    for _, player in ipairs(Players:GetPlayers()) do
        if player.Name == selectedPlayerName then return player end
    end
    return nil
end
addButton(roleSection, "刷新玩家列表", function()
    local list = playerNameList()
    pcall(function() playerDropdown.Set(list) end)
    if not table.find(list, selectedPlayerName) then
        selectedPlayerName = list[1]
        pcall(function() playerDropdown.Value(selectedPlayerName) end)
    end
end)
addButton(roleSection, "应用身份覆盖", function()
    local player = findSelectedPlayer()
    if not player then return end
    overrides[player] = overrideValues[selectedOverrideLabel]
    cache[player] = nil
    print(("[血债] %s 身份覆盖：%s"):format(player.Name, selectedOverrideLabel))
    if refreshAll then refreshAll() end
end)
addButton(roleSection, "清除全部身份覆盖", function()
    for player in pairs(overrides) do
        overrides[player] = nil
        cache[player] = nil
    end
    if refreshAll then refreshAll() end
end)

local debugSection = newSection(miscTab, "调试与管理", "Right")
addButton(debugSection, "输出完整阵营扫描", function()
    if _G.BloodDebtESP and _G.BloodDebtESP.ScanRoles then
        _G.BloodDebtESP.ScanRoles()
    end
end)
addButton(debugSection, "输出弹药扫描", function()
    if _G.BloodDebtESP and _G.BloodDebtESP.AmmoScan then
        _G.BloodDebtESP.AmmoScan()
    end
end)
addButton(debugSection, "输出瞄准状态", function()
    if _G.BloodDebtESP and _G.BloodDebtESP.AimDebug then
        _G.BloodDebtESP.AimDebug()
    end
end)
addButton(debugSection, "输出玩家调试信息", function()
    local lines = {}
    lines[#lines + 1] = "Enabled=" .. tostring(STATE.Enabled)
        .. " Details=" .. tostring(STATE.Details)
        .. " Outline=" .. tostring(STATE.Outline)
    lines[#lines + 1] = "渲染错误: " .. tostring(LAST_RENDER_ERR)
    lines[#lines + 1] = "玩家数: " .. #Players:GetPlayers()
    local camera = workspace.CurrentCamera
    for _, player in ipairs(Players:GetPlayers()) do
        local char = player.Character
        local humanoid = char and char:FindFirstChildOfClass("Humanoid")
        local anchor = char and (char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Head"))
        local health = humanoid and math.floor(humanoid.Health) or -1
        local onScreen, depth = "?", "?"
        if anchor and camera then
            local screenPoint, visible = camera:WorldToViewportPoint(anchor.Position)
            onScreen = tostring(visible)
            depth = string.format("%.0f", screenPoint.Z)
        end
        lines[#lines + 1] = ("%s | char=%s hum=%s hp=%d on=%s z=%s"):format(
            player.Name:sub(1, 14), char and "Y" or "N", humanoid and "Y" or "N", health, onScreen, depth)
    end
    print("[血债调试]\n" .. table.concat(lines, "\n"))
end)
addButton(debugSection, "卸载脚本并清理", function()
    if _G.BloodDebtESP and _G.BloodDebtESP.Destroy then
        _G.BloodDebtESP.Destroy()
    end
end)

local aboutSection = newSection(aboutTab, "关于", "Left")
aboutSection:NewTitle("作者：权威不是权威")
aboutSection:NewTitle("QQ 1群948082232")
aboutSection:NewTitle("QQ 2群1105225845")
aboutSection:NewTitle("作者QQ：3935754168")

local function requestWindowDestroy()
    if _G.BloodDebtESP and _G.BloodDebtESP.Destroy then
        pcall(_G.BloodDebtESP.Destroy)
    end
end
if mainWindowGui then
    table.insert(menuConns, mainWindowGui.Destroying:Connect(requestWindowDestroy))
    local mainFrame = mainWindowGui:FindFirstChild("MainFrame")
    local closeButton = mainFrame and mainFrame:FindFirstChildWhichIsA("ImageButton")
    if closeButton then
        table.insert(menuConns, closeButton.MouseButton1Click:Connect(requestWindowDestroy))
    end
end

menu.panel = mainWindowGui
menu.Window = Windows

task.spawn(function()
    task.wait(0.6)
    while _G.BloodDebtESP and not destroyed do
        local count = #Players:GetPlayers()
        local maxPlayers = count
        pcall(function()
            if Players.MaxPlayers and Players.MaxPlayers > 0 then maxPlayers = Players.MaxPlayers end
        end)
        local ping = 0
        pcall(function() ping = math.floor(LP:GetNetworkPing() * 1000) end)
        local fps = 0
        local okFrame, frameTime = pcall(function() return RunService.RenderStepped:Wait() end)
        if okFrame and tonumber(frameTime) and frameTime > 0 then fps = math.floor(1 / frameTime + 0.5) end
        local elapsed = math.floor(os.clock() - sessionStart)
        local hours = math.floor(elapsed / 3600)
        local minutes = math.floor((elapsed % 3600) / 60)
        local seconds = elapsed % 60
        local hookText = (#AIM_HOOKS > 0) and table.concat(AIM_HOOKS, ",") or "snap(镜头)"
        pcall(function()
            statusTitle.Set(("玩家 %d/%d｜延迟 %d ms｜FPS %d\n运行 %02d:%02d:%02d｜瞄准通道 %s")
                :format(count, maxPlayers, ping, fps, hours, minutes, seconds, hookText))
            if STATE.ModDetect then
                modTitle.Set(("模组检测运行中｜版本 %s｜通道 %s"):format(VERSION, hookText))
            else
                modTitle.Set("模组检测未开启")
            end
        end)
        task.wait(0.5)
    end
end)
end

--==================== 玩家对象管理 ================================
local objs, conns = {}, {}
local function setProp(o, k, v) pcall(function() o[k] = v end) end

local function cleanup(player)
    local o = objs[player]
    if o then
        for k, v in pairs(o) do
            if k ~= "char" and v then
                if v.Remove then pcall(function() v:Remove() end)
                else pcall(function() v:Destroy() end) end
            end
        end
    end
    objs[player] = nil
end

local function clearAll()
    local list = {}
    for p in pairs(objs) do list[#list + 1] = p end
    for _, p in ipairs(list) do cleanup(p) end
end

local function anchorOf(char)
    return char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Head")
end

local function makeBillboard(anchor, offset, textSize)
    local bb = Instance.new("BillboardGui")
    setProp(bb, "Name", "esp_tag")
    setProp(bb, "Size", UDim2.fromOffset(420 * STATE.Scale, 26 * STATE.Scale))
    setProp(bb, "StudsOffset", offset)
    setProp(bb, "AlwaysOnTop", true)
    setProp(bb, "LightInfluence", 0)
    setProp(bb, "MaxDistance", CONFIG.TagDistance)
    setProp(bb, "ResetOnSpawn", false)
    bb.Adornee = anchor
    bb.Parent = holder

    local lbl = Instance.new("TextLabel")
    setProp(lbl, "BackgroundTransparency", 1)
    setProp(lbl, "Size", UDim2.fromScale(1, 1))
    setProp(lbl, "Font", Enum.Font.SourceSansBold)
    setProp(lbl, "TextScaled", false)
    setProp(lbl, "TextSize", textSize * STATE.Scale)
    setProp(lbl, "TextStrokeTransparency", 0.3)
    setProp(lbl, "TextStrokeColor3", Color3.new(0, 0, 0))
    lbl.Text = ""
    lbl.Parent = bb
    return bb, lbl
end

local function makeText(size)
    local t = Instance.new("TextLabel")
    t.BackgroundTransparency = 1
    t.Font = Enum.Font.Arcade
    t.TextSize = size
    t.TextStrokeTransparency = 0
    t.TextStrokeColor3 = Color3.new(0, 0, 0)
    t.TextXAlignment = Enum.TextXAlignment.Center
    t.TextYAlignment = Enum.TextYAlignment.Center
    t.Visible = false
    t.ZIndex = 4
    t.Parent = screenGui
    return t
end

local cornerLines = setmetatable({}, { __mode = "k" })

local function newCornerBox()
    local holder = Instance.new("Frame")
    holder.BackgroundTransparency = 1
    holder.BorderSizePixel = 0
    holder.Visible = false
    holder.ZIndex = 3
    holder.Parent = screenGui

    local lines = {}
    local cfg = {
        {0, 0, 0, 0, 0.22, 0, 0, 2},    -- 左上横
        {0, 0, 0, 0, 0, 2, 0.22, 0},    -- 左上竖
        {1, 0, 1, 0, 0.22, 0, 0, 2},    -- 右上横
        {1, 0, 1, 0, 0, 2, 0.22, 0},    -- 右上竖
        {0, 1, 0, 1, 0.22, 0, 0, 2},    -- 左下横
        {0, 1, 0, 1, 0, 2, 0.22, 0},    -- 左下竖
        {1, 1, 1, 1, 0.22, 0, 0, 2},    -- 右下横
        {1, 1, 1, 1, 0, 2, 0.22, 0},    -- 右下竖
    }

    for i, c in ipairs(cfg) do
        local f = Instance.new("Frame")
        f.AnchorPoint = Vector2.new(c[1], c[2])
        f.Position = UDim2.new(c[3], 0, c[4], 0)
        f.Size = UDim2.new(c[5], c[6], c[7], c[8])
        f.BorderSizePixel = 0
        f.BackgroundColor3 = Color3.new(1, 1, 1)
        f.ZIndex = 3
        f.Parent = holder
        lines[i] = f
    end

    cornerLines[holder] = lines
    return holder
end

local function newBox2D()
    local f = Instance.new("Frame")
    f.Name = "box2d"
    f.BackgroundTransparency = 1
    f.BorderSizePixel = 1
    f.BorderColor3 = Color3.new(1, 1, 1)
    f.Size = UDim2.fromOffset(10, 10)
    f.Visible = false
    f.ZIndex = 3
    f.Parent = screenGui
    return f
end

local function newBar(color, alpha)
    local f = Instance.new("Frame")
    f.BackgroundColor3 = color
    f.BackgroundTransparency = alpha or 0
    f.BorderSizePixel = 0
    f.Visible = false
    f.ZIndex = 3
    f.Parent = screenGui
    return f
end

local function newTracer()
    local f = Instance.new("Frame")
    f.BackgroundColor3 = Color3.new(1, 1, 1)
    f.BorderSizePixel = 0
    f.AnchorPoint = Vector2.new(0, 0.5)
    f.Size = UDim2.fromOffset(1, 1)
    f.Visible = false
    f.ZIndex = 2
    f.Parent = screenGui
    return f
end

local function makeDot()
    local f = Instance.new("Frame")
    f.Size = UDim2.fromOffset(8, 8)
    f.BackgroundColor3 = Color3.fromRGB(130, 130, 130)
    f.BorderSizePixel = 0
    f.Visible = false
    f.ZIndex = 4
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(1, 0)
    c.Parent = f
    f.Parent = screenGui
    return f
end

local function ensure(player, char)
    local o = objs[player]
    if not o or o.char ~= char then
        if o then cleanup(player) end
        o = {char = char}
        objs[player] = o
    end

    if not o.hl then
        local hl = Instance.new("Highlight")
        setProp(hl, "DepthMode", Enum.HighlightDepthMode.AlwaysOnTop)
        setProp(hl, "OutlineTransparency", 0)
        setProp(hl, "FillTransparency", 1)
        hl.Adornee = char
        hl.Parent = holder
        o.hl = hl
    end

    if not o.box2d then o.box2d = newBox2D() end
    if not o.box4 then o.box4 = newCornerBox() end
    if not o.hpBg then o.hpBg = newBar(Color3.fromRGB(15, 15, 15), 0.35) end
    if not o.hpBar then o.hpBar = newBar(Color3.fromRGB(0, 255, 70), 0) end
    if not o.nameLbl then o.nameLbl = makeText(12) end
    if not o.infoLbl then o.infoLbl = makeText(11) end
    if not o.wpnLbl then o.wpnLbl = makeText(11) end
    if not o.avatar then
        local av = Instance.new("ImageLabel")
        av.Size = UDim2.fromOffset(20, 20)
        av.BackgroundTransparency = 1
        av.ZIndex = 4
        av.Visible = false
        av.Parent = screenGui
        local ac = Instance.new("UICorner"); ac.CornerRadius = UDim.new(1, 0); ac.Parent = av
        o.avatar = av
    end

    if not o.hpNum then o.hpNum = makeText(10) end

    if not o.tracer then
        local tr = Instance.new("Frame")
        tr.BackgroundColor3 = Color3.new(1, 1, 1)
        tr.BorderSizePixel = 0
        tr.AnchorPoint = Vector2.new(0, 0.5)
        tr.Size = UDim2.fromOffset(1, 1)
        tr.Visible = false
        tr.ZIndex = 2
        tr.Parent = screenGui
        o.tracer = tr
    end
    if not o.hpLbl then o.hpLbl = makeText(11) end
    if not o.dot1 then o.dot1 = makeDot() end
    if not o.dot2 then o.dot2 = makeDot() end

    return o
end

local TextService = game:GetService("TextService")
local textSizeCache = {}

local function measureText(text, size, font)
    local key = tostring(text) .. "|" .. tostring(size) .. "|" .. tostring(font)
    local cached = textSizeCache[key]
    if cached then return cached end
    local w = #tostring(text) * size * 0.55
    pcall(function()
        local v = TextService:GetTextSize(tostring(text), size, font, Vector2.new(2000, 100))
        if v and v.X and v.X > 0 then w = v.X end
    end)
    textSizeCache[key] = w
    return w
end

local thumbCache = {}

local function thumbOf(player)
    local id = player.UserId
    if id == nil then return "" end
    local cached = thumbCache[id]
    if cached ~= nil then return cached end
    local url = ""
    pcall(function()
        url = Players:GetUserThumbnailAsync(id, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size48x48)
    end)
    thumbCache[id] = url or ""
    return thumbCache[id]
end

local ROLE_CN = {
    Sheriff = "警长", Murderer = "杀手", Innocent = "平民", Unknown = "未知",
    Red = "红队", Blue = "蓝队", Green = "绿队", Neutral = "中立",
}

local BOX_COLOR = Color3.fromRGB(170, 30, 30)
local HP_COLOR  = Color3.fromRGB(0, 255, 70)

local charCache = {}

local function findChar(player)
    local c = player.Character
    if c and c:FindFirstChildOfClass("Humanoid") then return c end

    local cached = charCache[player]
    if cached and cached.t and (os.clock() - cached.t) < 2 then
        if cached.char and cached.char.Parent and cached.char:FindFirstChildOfClass("Humanoid") then
            return cached.char
        end
    end

    local found = nil
    local ok, list = pcall(function() return workspace:GetDescendants() end)
    if ok and list then
        local lowName = string.lower(player.Name)
        for _, obj in ipairs(list) do
            if obj:IsA("Model") and obj:FindFirstChildOfClass("Humanoid") then
                local mn = string.lower(obj.Name)
                if mn == lowName or string.find(mn, lowName, 1, true) then
                    found = obj
                    break
                end
            end
        end
    end

    charCache[player] = {char = found, t = os.clock()}
    return found
end

local function renderOne(player)
    if player == LP then
        if objs[player] then cleanup(player) end
        return
    end

    local char = findChar(player)
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    local anchor = char and (char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Head"))
    if not (char and anchor) then
        if objs[player] then cleanup(player) end
        return
    end

    local role = getRole(player)
    local color = COL[role] or COL.Innocent

    local dead = false
    if hum then
        local hp = tonumber(hum.Health) or 0
        local maxhp = tonumber(hum.MaxHealth) or 0
        if maxhp > 0 and hp <= 0.01 then dead = true end
    end
    if dead then color = Color3.fromRGB(140, 140, 140) end

    local cam = workspace.CurrentCamera
    if not cam then return end

    local pos, onScreen = cam:WorldToViewportPoint(anchor.Position)
    local dist = (cam.CFrame.Position - anchor.Position).Magnitude
    if dist ~= dist then dist = 0 end
    local visible = onScreen and pos.Z > 0
    local s2 = STATE.Scale or 1

    local h = math.clamp(3600 / math.max(dist, 1), 26, 520) * s2
    local w = h * 0.55
    local left = pos.X - w / 2
    local top = pos.Y - h / 2

    local o = ensure(player, char)
    if not o then return end

    -- 轮廓（可选，默认关）
    if o.hl then
        setProp(o.hl, "Adornee", (STATE.Outline and visible) and char or nil)
        setProp(o.hl, "OutlineColor", color)
        setProp(o.hl, "FillColor", color)
        setProp(o.hl, "FillTransparency", 1)
    end

    -- 方框（四角括号）
    if o.box2d then setProp(o.box2d, "Visible", false) end
    if o.box4 then
        setProp(o.box4, "Size", UDim2.fromOffset(w, h))
        setProp(o.box4, "Position", UDim2.fromOffset(left, top))
        setProp(o.box4, "Visible", visible)
        local lines = cornerLines[o.box4]
        if lines then
            for _, ln in ipairs(lines) do
                pcall(function() ln.BackgroundColor3 = color end)
            end
        end
    end

    -- 左侧血条
    local frac = 1
    if hum then
        local hp = tonumber(hum.Health) or 0
        local maxhp = tonumber(hum.MaxHealth) or 0
        if maxhp > 0 and hp >= 0 and hp < 1e9 then
            frac = math.clamp(hp / maxhp, 0, 1)
        end
    end
    if o.hpBg then
        setProp(o.hpBg, "Size", UDim2.fromOffset(3, h))
        setProp(o.hpBg, "Position", UDim2.fromOffset(left + 2, top))
        setProp(o.hpBg, "Visible", visible)
    end
    if o.hpBar then
        local bh = math.max(h * frac, 1)
        setProp(o.hpBar, "Size", UDim2.fromOffset(3, bh))
        setProp(o.hpBar, "Position", UDim2.fromOffset(left + 2, top + h - bh))
        local hpCol
        if frac > 0.6 then
            hpCol = Color3.fromRGB(0, 255, 70)
        elseif frac > 0.3 then
            hpCol = Color3.fromRGB(255, 210, 60)
        else
            hpCol = Color3.fromRGB(255, 70, 70)
        end
        setProp(o.hpBar, "BackgroundColor3", hpCol)
        setProp(o.hpBar, "Visible", visible)
    end

    -- 血量数字（血条右侧）
    if o.hpNum then
        local hpTxt = "??"
        if hum then
            local hp = tonumber(hum.Health)
            if hp and hp >= 0 and hp < 1e9 then hpTxt = tostring(math.floor(hp)) end
        end
        setProp(o.hpNum, "Size", UDim2.fromOffset(48, 14))
        setProp(o.hpNum, "Position", UDim2.fromOffset(left + 7, top + 1))
        setProp(o.hpNum, "TextSize", 10)
        o.hpNum.Text = hpTxt
        o.hpNum.TextColor3 = Color3.fromRGB(255, 255, 255)
        setProp(o.hpNum, "Visible", visible)
    end

    -- 头像（紧贴名字左侧）
    if o.avatar then
        local url = thumbOf(player)
        if url ~= "" then
            pcall(function()
                if o.avatar.Image ~= url then o.avatar.Image = url end
            end)
            local nmTxt = tostring(player.DisplayName or player.Name)
            local tw = measureText(nmTxt, 12, Enum.Font.Arcade)
            local nameLeft = pos.X - tw / 2
            setProp(o.avatar, "Position", UDim2.fromOffset(nameLeft - 22, top - 27))
            setProp(o.avatar, "Size", UDim2.fromOffset(20, 20))
            setProp(o.avatar, "Visible", visible)
        else
            setProp(o.avatar, "Visible", false)
        end
    end

    -- 顶部名字
    if o.nameLbl then
        local nm = tostring(player.DisplayName or player.Name)
        local nmTxt2 = tostring(player.DisplayName or player.Name)
        local tw2 = measureText(nmTxt2, 12, Enum.Font.Arcade)
        local boxW = math.max(tw2 + 20, 60)
        setProp(o.nameLbl, "Size", UDim2.fromOffset(boxW, 16))
        setProp(o.nameLbl, "Position", UDim2.fromOffset(pos.X - boxW / 2, top - 20))
        setProp(o.nameLbl, "TextXAlignment", Enum.TextXAlignment.Center)
        setProp(o.nameLbl, "TextSize", 12)
        o.nameLbl.Text = nm
        o.nameLbl.TextColor3 = color
        setProp(o.nameLbl, "Visible", visible)
    end

    -- 底部：距离 + 武器
    if o.infoLbl then
        setProp(o.infoLbl, "Size", UDim2.fromOffset(280, 14))
        setProp(o.infoLbl, "Position", UDim2.fromOffset(pos.X - 140, top + h + 2))
        setProp(o.infoLbl, "TextSize", 11)
        o.infoLbl.Text = ("%d studs"):format(math.floor(dist))
        o.infoLbl.TextColor3 = Color3.fromRGB(235, 235, 235)
        setProp(o.infoLbl, "Visible", visible)
    end

    if o.wpnLbl then
        local tool = char:FindFirstChildOfClass("Tool")
        setProp(o.wpnLbl, "Size", UDim2.fromOffset(280, 14))
        setProp(o.wpnLbl, "Position", UDim2.fromOffset(pos.X - 140, top + h + 16))
        setProp(o.wpnLbl, "TextSize", 11)
        o.wpnLbl.Text = tool and tool.Name or "无"
        o.wpnLbl.TextColor3 = Color3.fromRGB(235, 235, 235)
        setProp(o.wpnLbl, "Visible", visible)
    end

    if o.tracer then setProp(o.tracer, "Visible", false) end

    if o.hpLbl then setProp(o.hpLbl, "Visible", false) end
    if o.dot1 then setProp(o.dot1, "Visible", false) end
    if o.dot2 then setProp(o.dot2, "Visible", false) end
end

--========== 回合重置 ==========
local lastReset = 0
local lastText = ""

local function resetOverrides(reason)
    if os.clock() - lastReset < 1 then return end
    lastReset = os.clock()
    local n = 0
    for p in pairs(overrides) do
        overrides[p] = nil
        n = n + 1
    end
    if n > 0 then
        print("[阵营] " .. tostring(reason) .. "，已重置 " .. n .. " 个标记")
    end
end

table.insert(conns, LP.CharacterAdded:Connect(function()
    resetOverrides("本地角色重生")
end))

local function checkRoundText()
    local roots = {}
    local pg = LP:FindFirstChildOfClass("PlayerGui")
    if pg then roots[#roots + 1] = pg end
    pcall(function()
        local cg = game:GetService("CoreGui")
        if cg then roots[#roots + 1] = cg end
    end)

    for _, root in ipairs(roots) do
        local ok, list = pcall(function() return root:GetDescendants() end)
        if ok and list then
            for _, dd in ipairs(list) do
                if dd:IsA("TextLabel") then
                    local t = dd.Text or ""
                    if #t < 30 and (string.find(t, "回合结束", 1, true)
                        or string.find(t, "Round Over", 1, true)
                        or string.find(t, "获胜", 1, true)
                        or string.find(t, "胜利", 1, true)) then
                        if t ~= lastText then
                            lastText = t
                            resetOverrides("回合结束: " .. t)
                        end
                        return
                    end
                end
            end
        end
    end
end

task.spawn(function()
    task.wait(2)
    while _G.BloodDebtESP do
        task.wait(1.5)
        pcall(checkRoundText)
    end
end)

--========== 无扩散 / 无后坐力 / 快速拔枪 ==========
local function shouldZero(name)
    local lk = string.lower(tostring(name))
    if STATE.NoSpread and (string.find(lk, "spread", 1, true) or string.find(lk, "dispersion", 1, true)) then
        return true
    end
    if STATE.NoRecoil and (string.find(lk, "recoil", 1, true) or string.find(lk, "kick", 1, true)) then
        return true
    end
    if STATE.QuickPull and (string.find(lk, "equip", 1, true) or string.find(lk, "deploy", 1, true)
        or string.find(lk, "holster", 1, true) or string.find(lk, "pullout", 1, true)) then
        return true
    end
    if STATE.FastReload and (string.find(lk, "reload", 1, true)
        or string.find(lk, "magazine", 1, true)) then
        return true
    end
    return false
end

local function cleanWeaponObject(obj)
    local ok, attrs = pcall(function() return obj:GetAttributes() end)
    if ok and attrs then
        for k, v in pairs(attrs) do
            if type(v) == "number" and shouldZero(tostring(k)) then
                pcall(function() obj:SetAttribute(k, 0) end)
            end
        end
    end
    for _, d in ipairs(obj:GetDescendants()) do
        if d:IsA("NumberValue") or d:IsA("IntValue") then
            if shouldZero(d.Name) then pcall(function() d.Value = 0 end) end
        end
    end
end

task.spawn(function()
    task.wait(0.5)
    while _G.BloodDebtESP do
        task.wait(0.4)
        if STATE.Enabled and (STATE.NoSpread or STATE.NoRecoil or STATE.QuickPull) then
            local char = LP.Character
            local tool = char and char:FindFirstChildOfClass("Tool")
            if tool then pcall(cleanWeaponObject, tool) end
        end
    end
end)

-- 枪械配置清理（若游戏用 ModuleScript 暴露这些数值）
local function cleanModule(tbl, depth)
    if type(tbl) ~= "table" or depth > 4 then return end
    for k, v in pairs(tbl) do
        if type(k) == "string" then
            if type(v) == "number" and shouldZero(k) then
                pcall(function() tbl[k] = 0 end)
            elseif type(v) == "table" then
                cleanModule(v, depth + 1)
            end
        end
    end
end

if type(hookfunction) == "function" and type(require) == "function" then
    pcall(function()
        originalRequire = require
        hookedRequire = hookfunction(originalRequire, function(mod)
            local res = originalRequire(mod)
            pcall(function() cleanModule(res, 1) end)
            return res
        end)
        require = hookedRequire
    end)
end

--========== 伤害数字（显示在人物上方） ==========
local TweenService = game:GetService("TweenService")

local function showDamage(targetChar, dmg, isKill)
    local cam = workspace.CurrentCamera
    if not cam or not targetChar then return end
    local head = targetChar:FindFirstChild("Head") or targetChar:FindFirstChild("HumanoidRootPart")
    if not head then return end
    local sp, onScreen = cam:WorldToViewportPoint(head.Position + Vector3.new(0, 2, 0))
    if not onScreen then return end

    local lbl = Instance.new("TextLabel")
    lbl.BackgroundTransparency = 1
    lbl.Font = Enum.Font.SourceSansBold
    lbl.TextSize = isKill and 22 or 18
    -- 彩色：伤害越高越偏红，击杀随机彩虹色
    local col
    if isKill then
        col = Color3.fromHSV((os.clock() * 2.7) % 1, 0.85, 1)
    else
        local t = math.clamp(dmg / 120, 0, 1)
        col = Color3.fromHSV(0.45 * (1 - t), 0.85, 1)
    end
    lbl.TextColor3 = col
    lbl.TextStrokeTransparency = 0.15
    lbl.TextStrokeColor3 = Color3.new(0, 0, 0)
    lbl.Size = UDim2.fromOffset(160, 28)
    lbl.Position = UDim2.fromOffset(sp.X - 80, sp.Y - 8)
    lbl.Text = isKill and "击杀" or ("-%d"):format(dmg)
    lbl.ZIndex = 40
    lbl.Parent = screenGui

    local tween = TweenService:Create(lbl, TweenInfo.new(0.75, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Position = UDim2.fromOffset(sp.X - 80, sp.Y - 56),
        TextTransparency = 1,
        TextStrokeTransparency = 1,
    })
    tween:Play()
    tween.Completed:Connect(function() lbl:Destroy() end)
end

local hitFireAt = 0
local lastHP = {}

table.insert(conns, UIS.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        hitFireAt = os.clock() + 1.5
    end
end))

task.spawn(function()
    task.wait(0.5)
    while _G.BloodDebtESP do
        task.wait(0.05)
        if STATE.Enabled and STATE.HitMarker then
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= LP then
                    local char = p.Character
                    local hum = char and char:FindFirstChildOfClass("Humanoid")
                    if hum then
                        local hp = hum.Health
                        local prev = lastHP[p]
                        if prev and hp < prev - 0.5 and os.clock() < hitFireAt then
                            showDamage(char, math.floor(prev - hp), hp <= 0)
                        end
                        lastHP[p] = hp
                    else
                        lastHP[p] = nil
                    end
                end
            end
        end
    end
end)

--==================== 瞄准 ========================================
local fovCircle = Instance.new("Frame")
fovCircle.Name = "fov"
fovCircle.AnchorPoint = Vector2.new(0.5, 0.5)
fovCircle.Position = UDim2.fromScale(0.5, 0.5)
fovCircle.Size = UDim2.fromOffset(AIM.FOV * 2, AIM.FOV * 2)
fovCircle.BackgroundTransparency = 1
fovCircle.BorderSizePixel = 0
fovCircle.Visible = false
fovCircle.ZIndex = 8
fovCircle.Parent = screenGui
local fovCorner = Instance.new("UICorner")
fovCorner.CornerRadius = UDim.new(1, 0)
fovCorner.Parent = fovCircle
local fovStroke = Instance.new("UIStroke")
fovStroke.Thickness = 3
fovStroke.Color = Color3.fromRGB(255, 255, 255)
fovStroke.Parent = fovCircle

local aimTarget = nil
local aimFireAt = 0

local function pickHead(char)
    local head = char:FindFirstChild("Head")
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not head then return hrp end
    if not hrp then return head end
    if (AIM.HeadChance or 60) >= 100 then return head end
    if math.random(1, 100) <= (AIM.HeadChance or 60) then return head end
    return hrp
end

local function pickAimTarget()
    local cam = workspace.CurrentCamera
    if not cam then return nil end
    local center = cam.ViewportSize / 2
    local best, bestDist = nil, (STATE.WallbangV2 and math.huge or AIM.FOV)
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LP then
            local char = p.Character
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            if char and hum and hum.Health > 0 then
                local spawnGuard = STATE.IgnoreSpawn and char:FindFirstChildOfClass("ForceField") ~= nil
                local role = (not spawnGuard) and getRole(p) or nil
                if not spawnGuard and (AIM.TargetRole == "All" or role == AIM.TargetRole) then
                    local part = pickHead(char)
                    if part then
                        local sp, onScreen = cam:WorldToViewportPoint(part.Position)
                        if onScreen then
                            local d = (Vector2.new(sp.X, sp.Y) - center).Magnitude
                            if d <= bestDist then
                                best, bestDist = part, d
                            end
                        end
                    end
                end
            end
        end
    end
    return best
end

local function updateAim()

    -- FOV 圈常显（只要总开关没关）
    fovCircle.Visible = STATE.Enabled and STATE.ShowFOV
    fovCircle.Size = UDim2.fromOffset(AIM.FOV * 2, AIM.FOV * 2)
    setProp(fovStroke, "Color", aimTarget and Color3.fromRGB(255, 80, 80)
        or Color3.fromRGB(255, 255, 255))

    if AIM_OVERRIDE and AIM_OVERRIDE.Parent then
        aimTarget = AIM_OVERRIDE
        return
    end

    if not STATE.Silent then
        aimTarget = nil
        return
    end

    aimTarget = pickAimTarget()

end

local snapUntil = 0

local hitRoll = {}

local function silentActive()
    if not STATE.Silent or not aimTarget then return false end
    if (AIM.HitChance or 100) < 100 then
        if not hitRoll[aimTarget] then
            hitRoll[aimTarget] = (math.random(1, 100) <= (AIM.HitChance or 100))
        end
        if not hitRoll[aimTarget] then return false end
    end
    if CONFIG.AimKey ~= Enum.KeyCode.Unknown and UIS:IsKeyDown(CONFIG.AimKey) then return true end
    if os.clock() < aimFireAt then return true end
    if UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then return true end
    return false
end

local function charFilterList()
    local list = {}
    for _, pl in ipairs(Players:GetPlayers()) do
        if pl ~= LP and pl.Character then
            list[#list + 1] = pl.Character
        end
    end
    return list
end

local function makeWallbangParams()
    local list = charFilterList()
    if #list == 0 then return nil end
    local np = RaycastParams.new()
    np.FilterType = Enum.RaycastFilterType.Include
    np.FilterDescendantsInstances = list
    np.IgnoreWater = true
    return np
end

-- 通道 A：namecall（需要 hookmetamethod + getnamecallmethod）
if type(hookmetamethod) == "function" and type(getnamecallmethod) == "function" then
    pcall(function()
        hookedNamecall = function(self, ...)
            local method = getnamecallmethod()
            if silentActive() then
                if method == "Raycast" then
                    local ar = {...}
                    local origin, dir = ar[1], ar[2]
                    if AIM.Method == "Teleport" and typeof(origin) == "Vector3" and aimTarget then
                        origin = aimTarget.Position - dir.Unit * 2
                        ar[1] = origin
                    end
                    if typeof(origin) == "Vector3" and typeof(dir) == "Vector3" and dir.Magnitude > 0 then
                        if silentActive() then
                            ar[2] = (aimTarget.Position - origin).Unit * dir.Magnitude
                        end
                        if STATE.Wallbang then
                            local np = makeWallbangParams()
                            if np then
                                return originalNamecall(self, origin, ar[2], np)
                            end
                        end
                        if silentActive() then
                            return originalNamecall(self, table.unpack(ar))
                        end
                    end
                elseif method == "FindPartOnRay" or method == "FindPartOnRayWithIgnoreList" then
                    local ar = {...}
                    local ray = ar[1]
                    if typeof(ray) == "Ray" then
                        ar[1] = Ray.new(ray.Origin, (aimTarget.Position - ray.Origin).Unit * ray.Direction.Magnitude)
                        return originalNamecall(self, table.unpack(ar))
                    end
                elseif method == "ScreenPointToRay" or method == "ViewportPointToRay" then
                    local cam = workspace.CurrentCamera
                    local origin = cam and cam.CFrame.Position or Vector3.new()
                    return Ray.new(origin, (aimTarget.Position - origin).Unit * 1000)
                elseif method == "FireServer" then
                    local nm = string.lower(tostring(self.Name or ""))
                    if string.find(nm, "fire", 1, true) or string.find(nm, "shoot", 1, true)
                        or string.find(nm, "hit", 1, true) or string.find(nm, "bullet", 1, true)
                        or string.find(nm, "weapon", 1, true) or string.find(nm, "shot", 1, true) then
                        local ar = {...}
                        local changed = false
                        for i, v in ipairs(ar) do
                            local tv = typeof(v)
                            if tv == "Vector3" then
                                ar[i] = aimTarget.Position
                                changed = true
                            elseif tv == "Instance" and v:IsA("BasePart") then
                                local inChar = false
                                for _, pl in ipairs(Players:GetPlayers()) do
                                    local c = pl.Character
                                    if c and v:IsDescendantOf(c) then inChar = true break end
                                end
                                if not inChar then
                                    ar[i] = aimTarget
                                    changed = true
                                end
                            end
                        end
                        if changed then
                            local first = originalNamecall(self, table.unpack(ar))
                            local extra = (STATE.MultiShot or 1) - 1
                            for _ = 1, extra do
                                pcall(function()
                                    originalNamecall(self, table.unpack(ar))
                                end)
                            end
                            return first
                        end
                    end
                end
            end
            return originalNamecall(self, ...)
        end
        originalNamecall = hookmetamethod(game, "__namecall", hookedNamecall)
        table.insert(AIM_HOOKS, "namecall")
    end)
end

-- 通道 B：替换 workspace.Raycast（需要 hookfunction）
if type(hookfunction) == "function" then
    pcall(function()
        originalRaycast = workspace.Raycast
        hookedRaycast = hookfunction(originalRaycast, function(self, origin, dir, params)
            if typeof(origin) == "Vector3" and typeof(dir) == "Vector3" then
                if silentActive() then
                    dir = (aimTarget.Position - origin).Unit * dir.Magnitude
                end
                if STATE.Wallbang then
                    local np = makeWallbangParams()
                    if np then
                        return originalRaycast(self, origin, dir, np)
                    end
                end
            end
            return originalRaycast(self, origin, dir, params)
        end)
        if type(setreadonly) == "function" then
            pcall(function() setreadonly(workspace, false) end)
            pcall(function() workspace.Raycast = hookedRaycast end)
            pcall(function() setreadonly(workspace, true) end)
        else
            pcall(function() workspace.Raycast = hookedRaycast end)
        end
        table.insert(AIM_HOOKS, "raycast")
    end)
end

-- 通道 C：改写 mouse.Hit / mouse.Target（需要 getrawmetatable）
local mouse = LP:GetMouse()
if type(getrawmetatable) == "function" and type(setreadonly) == "function" and type(newcclosure) == "function" then
    pcall(function()
        mouseMeta = getrawmetatable(game)
        originalMouseIndex = mouseMeta.__index
        setreadonly(mouseMeta, false)
        hookedMouseIndex = newcclosure(function(self, key)
            if silentActive() and self == mouse then
                if key == "Hit" then return CFrame.new(aimTarget.Position) end
                if key == "Target" then return aimTarget end
            end
            return originalMouseIndex(self, key)
        end)
        mouseMeta.__index = hookedMouseIndex
        setreadonly(mouseMeta, true)
        table.insert(AIM_HOOKS, "mouse")
    end)
end

-- 通道 D：兜底，开火瞬间把镜头对准目标
table.insert(conns, RunService.RenderStepped:Connect(function()
    if #AIM_HOOKS > 0 then return end
    if not (STATE.Silent and aimTarget) then return end
    if os.clock() > snapUntil then return end
    local cam = workspace.CurrentCamera
    if cam then
        cam.CFrame = CFrame.lookAt(cam.CFrame.Position, aimTarget.Position)
    end
end))

-- 开火窗口
table.insert(conns, UIS.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        aimFireAt = os.clock() + CONFIG.AimFireWindow
        snapUntil = os.clock() + 0.15
        hitRoll = {}
    end
end))

table.insert(conns, RunService.RenderStepped:Connect(function()
    pcall(updateAim)
end))

--========== 附加功能（v24） ==========
local SoundService = game:GetService("SoundService")
local TweenService = game:GetService("TweenService")

--========== 子弹显示 ==========
local function fireTracer(fromS, toS, color)
    local line = Instance.new("Frame")
    line.BackgroundColor3 = color or Color3.fromRGB(255, 240, 150)
    line.BorderSizePixel = 0
    line.AnchorPoint = Vector2.new(0, 0.5)
    line.ZIndex = 6
    line.Parent = screenGui

    local dx = toS.X - fromS.X
    local dy = toS.Y - fromS.Y
    local len = math.sqrt(dx * dx + dy * dy)
    line.Position = UDim2.fromOffset(fromS.X, fromS.Y)
    line.Size = UDim2.fromOffset(math.max(len, 1), 2)
    line.Rotation = math.deg(math.atan2(dy, dx))

    local tw = TweenService:Create(line, TweenInfo.new(0.16), { BackgroundTransparency = 1 })
    tw:Play()
    tw.Completed:Connect(function()
        pcall(function() line:Destroy() end)
    end)
end

table.insert(conns, UIS.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
    if not STATE.BulletShow then return end
    local cam = workspace.CurrentCamera
    if not cam then return end
    local vp = cam.ViewportSize
    local fromS = Vector2.new(vp.X / 2, vp.Y - 40)
    local toS = Vector2.new(vp.X / 2, vp.Y / 2)
    if aimTarget then
        local sp, onScreen = cam:WorldToViewportPoint(aimTarget.Position)
        if onScreen then toS = Vector2.new(sp.X, sp.Y) end
    end
    pcall(fireTracer, fromS, toS)
end))

table.insert(conns, workspace.DescendantAdded:Connect(function(obj)
    if not STATE.BulletShow then return end
    if not obj:IsA("BasePart") then return end
    local n = string.lower(obj.Name)
    if string.find(n, "bullet", 1, true) or string.find(n, "projectile", 1, true)
        or string.find(n, "tracer", 1, true) then
        local hl = Instance.new("Highlight")
        hl.Adornee = obj
        hl.FillColor = Color3.fromRGB(255, 230, 120)
        hl.OutlineColor = Color3.fromRGB(255, 200, 60)
        hl.FillTransparency = 0.55
        hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        hl.Parent = screenGui
        task.delay(2, function()
            pcall(function() hl:Destroy() end)
        end)
    end
end))

-- 命中音效
local hitSound = Instance.new("Sound")
hitSound.SoundId = "rbxassetid://9120386436"
hitSound.Volume = 0.6
hitSound.Parent = SoundService

-- 枪械 HUD
local hud = Instance.new("TextLabel")
hud.Size = UDim2.fromOffset(260, 34)
hud.Position = UDim2.new(1, -280, 1, -112)
hud.BackgroundColor3 = Color3.fromRGB(10, 14, 20)
hud.BackgroundTransparency = 0.35
hud.BorderSizePixel = 0
hud.Font = Enum.Font.Code
hud.TextSize = 13
hud.TextColor3 = Color3.fromRGB(230, 240, 255)
hud.TextXAlignment = Enum.TextXAlignment.Left
hud.TextYAlignment = Enum.TextYAlignment.Top
hud.Text = ""
hud.Visible = false
hud.ZIndex = 40
hud.Parent = screenGui
local hudc = Instance.new("UICorner"); hudc.CornerRadius = UDim.new(0, 5); hudc.Parent = hud

local ammoCache = nil
local ammoCacheAt = 0

local function scanGuiAmmo()
    if ammoCache and (os.clock() - ammoCacheAt) < 0.4 then
        return ammoCache
    end
    ammoCacheAt = os.clock()
    local found = nil

    local pg = LP:FindFirstChildOfClass("PlayerGui")
    if pg then
        for _, d in ipairs(pg:GetDescendants()) do
            if d:IsA("TextLabel") then
                local t = d.Text
                if t and #t <= 20 then
                    local a, b = t:match("^(%d+)%s*/%s*(%d+)$")
                    if a then
                        found = a .. " / " .. b
                        break
                    end
                end
            end
        end
    end

    ammoCache = found
    return found
end

local function readAmmo(tool)
    if not tool then return "--" end
    local keys = {"Ammo", "CurrentAmmo", "Clip", "Magazine", "Bullets", "AmmoCount", "CurrentClip", "Round"}
    for _, key in ipairs(keys) do
        local ok, v = pcall(function() return tool:GetAttribute(key) end)
        if ok and type(v) == "number" then
            return tostring(math.floor(v))
        end
    end
    local ok2, list = pcall(function() return tool:GetDescendants() end)
    if ok2 then
        for _, d in ipairs(list) do
            if d:IsA("NumberValue") or d:IsA("IntValue") then
                local n = string.lower(d.Name)
                if string.find(n, "ammo", 1, true) or string.find(n, "clip", 1, true)
                    or string.find(n, "bullet", 1, true) or string.find(n, "round", 1, true) then
                    return tostring(math.floor(d.Value))
                end
            end
        end
    end
    return "--"
end

-- 命中框扩展
local hitboxSaved = {}

local function resetHitbox()
    for head, saved in pairs(hitboxSaved) do
        pcall(function()
            head.Size = saved.Size
            head.CanCollide = saved.CanCollide
            head.Transparency = saved.Transparency
        end)
    end
    hitboxSaved = {}
end

local function applyHitbox()
    if not STATE.Hitbox then return end
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LP and p.Character then
            local head = p.Character:FindFirstChild("Head")
            if head and head:IsA("BasePart") then
                if hitboxSaved[head] == nil then
                    hitboxSaved[head] = {Size = head.Size, CanCollide = head.CanCollide, Transparency = head.Transparency}
                end
                head.Size = hitboxSaved[head].Size * (STATE.HitboxSize or 2)
                head.CanCollide = false
                head.Transparency = 0.4
            end
        end
    end
end

-- 自由视角
local freecamSavedType = nil

local function updateFreecam(dt)
    local cam = workspace.CurrentCamera
    if not cam then return end
    if STATE.Freecam then
        if cam.CameraType ~= Enum.CameraType.Scriptable then
            freecamSavedType = cam.CameraType
            cam.CameraType = Enum.CameraType.Scriptable
        end
        local dir = Vector3.zero
        if UIS:IsKeyDown(Enum.KeyCode.W) then dir = dir + cam.CFrame.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.S) then dir = dir - cam.CFrame.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.A) then dir = dir - cam.CFrame.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.D) then dir = dir + cam.CFrame.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.Space) then dir = dir + Vector3.new(0, 1, 0) end
        if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then dir = dir - Vector3.new(0, 1, 0) end
        cam.CFrame = cam.CFrame + dir * (60 * dt)
    elseif freecamSavedType then
        pcall(function() cam.CameraType = freecamSavedType end)
        freecamSavedType = nil
    end
end

-- 快速射击
local rfNext = 0

local function rapidFireTick()
    if not (STATE.RapidFire or STATE.ForceFireMode) then return end
    if not UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then return end
    if os.clock() < rfNext then return end
    rfNext = os.clock() + (STATE.FireRate or 0.1)
    if type(mouse1click) == "function" then
        pcall(mouse1click)
    else
        local vu = game:GetService("VirtualUser")
        pcall(function()
            vu:CaptureController()
            vu:ClickButton1(Vector2.new())
        end)
    end
end

-- 主循环钩子
local hbAcc, hudAcc, tapAcc = 0, 0, 0
local lastHealth = nil
local resetCooldown = 0

table.insert(conns, RunService.RenderStepped:Connect(function(dt)
    local char = LP.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")

    updateFreecam(dt)
    rapidFireTick()

    -- FOV（仅锁定视野开启时生效；开镜时游戏会调小 FOV，这里不覆盖）
    local cam = workspace.CurrentCamera
    if cam and STATE.FovOverride then
        local aiming = UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton2)
        if not aiming then
            local target = STATE.Fov or 70
            if math.abs(cam.FieldOfView - target) > 0.5 then
                cam.FieldOfView = target
            end
        end
    end

    -- 第三人称
    if hum then
        if STATE.ThirdPerson then
            hum.CameraOffset = Vector3.new(0, 1.5, 0)
        elseif hum.CameraOffset.Magnitude > 0 then
            hum.CameraOffset = Vector3.zero
        end
    end

    

-- 命中框扩展（限频）
    hbAcc = hbAcc + dt
    if hbAcc >= 0.3 then
        hbAcc = 0
        if STATE.Hitbox then
            pcall(applyHitbox)
        elseif next(hitboxSaved) then
            pcall(resetHitbox)
        end
    end

    -- 无坠落伤害（本地血量回填）
    if hum and STATE.NoFall then
        if lastHealth and hum.Health < lastHealth - 12 then
            pcall(function() hum.Health = lastHealth end)
        end
        lastHealth = hum.Health
    else
        lastHealth = hum and hum.Health or nil
    end

    -- 倒地自动重置
    if hum and STATE.ResetKnocked and os.clock() > resetCooldown then
        if hum.Health > 0 and hum.Health < 25 then
            resetCooldown = os.clock() + 3
            pcall(function()
                hum.Health = 0
            end)
        end
    end

    -- HUD / 物品栏
    hudAcc = hudAcc + dt
    if hudAcc >= 0.25 then
        hudAcc = 0
        if STATE.GunHud and char then
            local tool = char:FindFirstChildOfClass("Tool")
            local wpn = tool and tool.Name or "空手"
            local ammoLine = ""
            if STATE.BulletShow then
                local ammo = scanGuiAmmo()
                if not ammo and tool then ammo = readAmmo(tool) end
                if not ammo then ammo = "--" end
                ammoLine = "子弹: " .. ammo .. "\n"
            end
            hud.Text = ammoLine .. "武器: " .. wpn
            hud.Size = UDim2.fromOffset(260, (ammoLine ~= "") and 50 or 32)
            hud.Visible = true
        else
            hud.Visible = false
        end

        if STATE.NoInvHide then
            pcall(function()
                local pg = LP:FindFirstChildOfClass("PlayerGui")
                local bp = pg and pg:FindFirstChild("Backpack")
                if bp then bp.Enabled = true end
                local core = game:GetService("CoreGui")
                local cbp = core:FindFirstChild("Backpack")
                if cbp then cbp.Enabled = true end
            end)
        end
    end
end))

-- 命中音效（检测其他玩家掉血）
local hpWatch = {}
task.spawn(function()
    task.wait(1)
    while _G.BloodDebtESP do
        task.wait(0.06)
        if STATE.HitSounds then
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= LP then
                    local h = p.Character and p.Character:FindFirstChildOfClass("Humanoid")
                    if h then
                        local prev = hpWatch[p]
                        if prev and h.Health < prev - 0.5 then
                            pcall(function()
                                local s = hitSound:Clone()
                                s.Parent = SoundService
                                s:Play()
                                task.delay(1, function() s:Destroy() end)
                            end)
                        end
                        hpWatch[p] = h.Health
                    else
                        hpWatch[p] = nil
                    end
                end
            end
        end
    end
end)

--========== 原地复活 ==========
local lastDeathPos = nil

local function watchDeath()
    local char = LP.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if hum then
        pcall(function()
            local diedConnection = hum.Died:Connect(function()
                local hrp = char:FindFirstChild("HumanoidRootPart")
                if hrp then
                    lastDeathPos = hrp.CFrame
                    print("[复活] 已记录死亡位置")
                end
            end)
            table.insert(conns, diedConnection)
        end)
    end
end

watchDeath()

table.insert(conns, LP.CharacterAdded:Connect(function(char)
    task.wait(0.2)
    pcall(watchDeath)
    if STATE.RespawnOnSpot and lastDeathPos then
        local hrp = char:WaitForChild("HumanoidRootPart", 5)
        if hrp then
            task.wait(0.3)
            pcall(function()
                hrp.CFrame = lastDeathPos + Vector3.new(0, 3, 0)
            end)
            lastDeathPos = nil
            print("[复活] 已传送到死亡位置")
        end
    end
end))

--========== 删除地图资源 ==========
local pickBox = nil
local pickTarget = nil
local deletedCount = 0

local function ensurePickBox()
    if pickBox and pickBox.Parent then return pickBox end
    local ad = Instance.new("SelectionBox")
    ad.Name = "pickBox"
    ad.LineThickness = 0.06
    ad.Color3 = Color3.fromRGB(255, 70, 70)
    ad.SurfaceTransparency = 1
    ad.Visible = false
    ad.Parent = screenGui
    pickBox = ad
    return ad
end

local function pickUnderMouse()
    local cam = workspace.CurrentCamera
    if not cam then return nil end
    local mouse = LP:GetMouse()
    if not mouse then return nil end

    local ok, ray = pcall(function()
        return cam:ScreenPointToRay(mouse.X, mouse.Y)
    end)
    if not ok or not ray then return nil end

    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = { LP.Character }
    params.IgnoreWater = true

    local res = workspace:Raycast(ray.Origin, ray.Direction * 2000, params)
    return res and res.Instance or nil
end

local pickAcc = 0

table.insert(conns, RunService.RenderStepped:Connect(function(dt)
    pickAcc = pickAcc + dt
    if pickAcc < 0.05 then return end
    pickAcc = 0

    local box = ensurePickBox()
    if STATE.MapEdit then
        local t = pickUnderMouse()
        -- 不框自己和玩家角色
        if t then
            for _, pl in ipairs(Players:GetPlayers()) do
                local c = pl.Character
                if c and (t == c or t:IsDescendantOf(c)) then
                    t = nil
                    break
                end
            end
        end
        pickTarget = t
        if t then
            box.Adornee = t
            box.Visible = true
        else
            box.Visible = false
        end
    else
        pickTarget = nil
        box.Visible = false
    end
end))

local ctxMenu = nil

local function closeCtx()
    if ctxMenu then
        pcall(function() ctxMenu:Destroy() end)
        ctxMenu = nil
    end
end

local function openCtx(target, mx, my)
    closeCtx()
    local hasTarget = (target ~= nil and target.Parent ~= nil)
    local H = hasTarget and 112 or 82

    local m = Instance.new("Frame")
    m.Name = "ctxMenu"
    m.Size = UDim2.fromOffset(200, H)
    m.Position = UDim2.fromOffset(mx, my)
    m.BackgroundColor3 = Color3.fromRGB(252, 252, 255)
    m.BorderSizePixel = 0
    m.ZIndex = 80
    m.Parent = screenGui
    local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0, 6); c.Parent = m
    local st = Instance.new("UIStroke"); st.Color = Color3.fromRGB(200, 205, 215); st.Thickness = 1; st.Parent = m

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -16, 0, 20)
    title.Position = UDim2.fromOffset(8, 4)
    title.BackgroundTransparency = 1
    title.Font = Enum.Font.SourceSansBold
    title.TextSize = 12
    title.TextColor3 = Color3.fromRGB(40, 44, 52)
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.TextTruncate = Enum.TextTruncate.AtEnd
    title.Text = hasTarget and tostring(target.Name) or "操作"
    title.ZIndex = 81
    title.Parent = m

    local y = 24

    if hasTarget then
        local del = Instance.new("TextButton")
        del.Size = UDim2.fromOffset(184, 24)
        del.Position = UDim2.fromOffset(8, y)
        del.BackgroundColor3 = Color3.fromRGB(220, 70, 70)
        del.BorderSizePixel = 0
        del.Font = Enum.Font.SourceSansBold
        del.TextSize = 12
        del.TextColor3 = Color3.fromRGB(255, 255, 255)
        del.Text = "删除"
        del.ZIndex = 81
        del.Parent = m
        local dc = Instance.new("UICorner"); dc.CornerRadius = UDim.new(0, 4); dc.Parent = del
        del.MouseButton1Click:Connect(function()
            pcall(function() target:Destroy() end)
            deletedCount = deletedCount + 1
            print("[地图] 已删除: " .. tostring(target.Name) .. "（累计 " .. deletedCount .. "）")
            closeCtx()
        end)
        y = y + 28
    end

    local killAll = Instance.new("TextButton")
    killAll.Size = UDim2.fromOffset(184, 24)
    killAll.Position = UDim2.fromOffset(8, y)
    killAll.BackgroundColor3 = Color3.fromRGB(180, 40, 120)
    killAll.BorderSizePixel = 0
    killAll.Font = Enum.Font.SourceSansBold
    killAll.TextSize = 12
    killAll.TextColor3 = Color3.fromRGB(255, 255, 255)
    killAll.Text = "秒杀所有人"
    killAll.ZIndex = 81
    killAll.Parent = m
    local kc = Instance.new("UICorner"); kc.CornerRadius = UDim.new(0, 4); kc.Parent = killAll
    killAll.MouseButton1Click:Connect(function()
        local n = 0
        for _, pl in ipairs(Players:GetPlayers()) do
            if pl ~= LP then
                local ch = findChar(pl)
                local hum = ch and ch:FindFirstChildOfClass("Humanoid")
                if hum and hum.Health > 0 then
                    pcall(function() hum.Health = 0 end)
                    n = n + 1
                end
            end
        end
        print("[秒杀] 已对 " .. n .. " 人执行")
        closeCtx()
    end)
    y = y + 28

    local cancel = Instance.new("TextButton")
    cancel.Size = UDim2.fromOffset(184, 22)
    cancel.Position = UDim2.fromOffset(8, y)
    cancel.BackgroundColor3 = Color3.fromRGB(235, 238, 244)
    cancel.BorderSizePixel = 0
    cancel.Font = Enum.Font.SourceSans
    cancel.TextSize = 11
    cancel.TextColor3 = Color3.fromRGB(70, 76, 88)
    cancel.Text = "取消"
    cancel.ZIndex = 81
    cancel.Parent = m
    local cc2 = Instance.new("UICorner"); cc2.CornerRadius = UDim.new(0, 4); cc2.Parent = cancel
    cancel.MouseButton1Click:Connect(closeCtx)

    ctxMenu = m
end

table.insert(conns, UIS.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if not STATE.MapEdit then
        closeCtx()
        return
    end

    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        local mouse = LP:GetMouse()
        local mx = mouse and mouse.X or 200
        local my = mouse and mouse.Y or 200
        local tgt = (pickTarget and pickTarget.Parent) and pickTarget or nil
        openCtx(tgt, mx + 8, my + 8)
    elseif input.UserInputType == Enum.UserInputType.MouseButton1 then
        closeCtx()
    end
end))

--========== 反作弊处理 ==========
killAntiCheat = function()
    local hit = {}
    for _, obj in ipairs(game:GetDescendants()) do
        if obj:IsA("LocalScript") then
            local n = string.lower(obj.Name)
            if string.find(n, "anticheat", 1, true) or string.find(n, "anti_cheat", 1, true)
                or string.find(n, "antiexploit", 1, true) or string.find(n, "ac_", 1, true)
                or string.find(n, "watchdog", 1, true) or string.find(n, "sentinel", 1, true) then
                pcall(function() obj.Disabled = true end)
                hit[#hit + 1] = obj:GetFullName()
            end
        end
    end
    return hit
end

--========== 移动功能 ==========
local flyBV, flyBG
local noclipOn = false

local function clearFly()
    if flyBV then pcall(function() flyBV:Destroy() end) flyBV = nil end
    if flyBG then pcall(function() flyBG:Destroy() end) flyBG = nil end
end

local function ensureFly()
    local char = LP.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    if flyBV and flyBV.Parent == hrp then return end
    clearFly()
    local bv = Instance.new("BodyVelocity")
    bv.MaxForce = Vector3.new(1e5, 1e5, 1e5)
    bv.Velocity = Vector3.zero
    bv.Parent = hrp
    local bg = Instance.new("BodyGyro")
    bg.MaxTorque = Vector3.new(1e5, 1e5, 1e5)
    bg.P = 3000
    bg.CFrame = hrp.CFrame
    bg.Parent = hrp
    flyBV, flyBG = bv, bg
end

-- 按键切换
table.insert(conns, UIS.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.UserInputType ~= Enum.UserInputType.Keyboard then return end
    for name, code in pairs(FEATURE_KEYS) do
        if code ~= Enum.KeyCode.Unknown and input.KeyCode == code then
            STATE[name] = not STATE[name]
            if menu.repaint then pcall(menu.repaint) end
        end
    end
end))

table.insert(conns, RunService.RenderStepped:Connect(function()
    local char = LP.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")

    -- fly
    if STATE.Fly and char then
        ensureFly()
        local cam = workspace.CurrentCamera
        if flyBV and cam then
            local dir = Vector3.zero
            if UIS:IsKeyDown(Enum.KeyCode.W) then dir = dir + cam.CFrame.LookVector end
            if UIS:IsKeyDown(Enum.KeyCode.S) then dir = dir - cam.CFrame.LookVector end
            if UIS:IsKeyDown(Enum.KeyCode.A) then dir = dir - cam.CFrame.RightVector end
            if UIS:IsKeyDown(Enum.KeyCode.D) then dir = dir + cam.CFrame.RightVector end
            if UIS:IsKeyDown(Enum.KeyCode.Space) then dir = dir + Vector3.new(0, 1, 0) end
            if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then dir = dir - Vector3.new(0, 1, 0) end
            local target = dir * (STATE.FlySpeed or 60)
            if CONFIG.SafeMode then
                target = Vector3.new(
                    math.clamp(target.X, -CONFIG.MaxFly, CONFIG.MaxFly),
                    math.clamp(target.Y, -CONFIG.MaxVertFly, CONFIG.MaxVertFly),
                    math.clamp(target.Z, -CONFIG.MaxFly, CONFIG.MaxFly))
            end
            flyBV.Velocity = flyBV.Velocity:Lerp(target, 0.35)
            flyBG.CFrame = cam.CFrame
            if hum then hum.PlatformStand = true end
        end
    else
        if flyBV or flyBG then
            clearFly()
            if hum then pcall(function() hum.PlatformStand = false end) end
        end
    end

    -- walkspeed
    if hum then
        if STATE.Walk then
            hum.WalkSpeed = STATE.WalkSpeed or 16
        elseif hum.WalkSpeed == (STATE.WalkSpeed or 16) then
            hum.WalkSpeed = 16
        end
    end

    -- noclip（穿墙时把速度压回正常值，避免位置跳变被判定）
    if char then
        if STATE.Noclip then
            if hum and hum.WalkSpeed > 24 then hum.WalkSpeed = 24 end
            noclipOn = true
            for _, p in ipairs(char:GetDescendants()) do
                if p:IsA("BasePart") then p.CanCollide = false end
            end
        elseif noclipOn then
            noclipOn = false
            for _, p in ipairs(char:GetDescendants()) do
                if p:IsA("BasePart") then p.CanCollide = true end
            end
        end
    end
end))

table.insert(conns, UIS.JumpRequest:Connect(function()
    if not STATE.InfJump then return end
    local hum = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
    if hum then
        pcall(function() hum:ChangeState(Enum.HumanoidStateType.Jumping) end)
    end
end))

table.insert(conns, LP.CharacterAdded:Connect(function()
    clearFly()
end))

--==================== 主循环 ======================================
refreshAll = function()
    if menu.repaint then pcall(menu.repaint) end
    if not STATE.Enabled then
        clearAll()
        return
    end
    for _, p in ipairs(Players:GetPlayers()) do pcall(renderOne, p) end
end

for _, p in ipairs(Players:GetPlayers()) do pcall(renderOne, p) end
table.insert(conns, Players.PlayerAdded:Connect(function(p)
    table.insert(conns, p.CharacterAdded:Connect(function()
        task.wait(0.3)
        pcall(renderOne, p)
    end))
    pcall(renderOne, p)
end))
table.insert(conns, Players.PlayerRemoving:Connect(function(p)
    cache[p] = nil overrides[p] = nil cleanup(p)
end))

local acc = 0
table.insert(conns, RunService.RenderStepped:Connect(function(dt)
    acc = acc + dt
    if acc >= 1 / CONFIG.FPS then
        acc = 0
        if not STATE.Enabled then
            if next(objs) then clearAll() end
        else
            for _, p in ipairs(Players:GetPlayers()) do
                local okR, errR = pcall(renderOne, p)
                if not okR then LAST_RENDER_ERR = tostring(errR) end
            end
        end
    end
end))

--==================== 接口 ========================================
local function findPlayer(name)
    name = string.lower(tostring(name))
    for _, p in ipairs(Players:GetPlayers()) do
        if string.lower(p.Name) == name or string.lower(p.DisplayName) == name then return p end
    end
    for _, p in ipairs(Players:GetPlayers()) do
        if string.find(string.lower(p.Name), name, 1, true) then return p end
    end
    return nil
end

_G.BloodDebtESP = {
    Version = VERSION,
    State   = STATE,
    Config  = CONFIG,
    Aim     = AIM,
    Unknown = unknownWeapons,
    Menu    = menu,

    LastError = function()
        print("[ESP] 最后渲染错误:", tostring(LAST_RENDER_ERR))
        print("[ESP] Enabled=", STATE.Enabled, " Details=", STATE.Details, " Outline=", STATE.Outline)
        local n = 0
        for _ in pairs(objs) do n = n + 1 end
        print("[ESP] 已渲染对象数:", n)
        return LAST_RENDER_ERR
    end,

    ScanRoles = function()
        print("[阵营] 当前模式:", CURRENT_MODE)
        local set = wordSet()
        print("[阵营] 本模式词表:", table.concat(set.order, " / "))
        for _, p in ipairs(Players:GetPlayers()) do
            local team = "无"
            pcall(function() team = p.Team and p.Team.Name or "无" end)
            local role = select(1, getRole(p))
            print(("  %s | team=%s | role=%s"):format(p.Name, tostring(team), tostring(role)))
            local char = p.Character
            if char then
                local ok, attrs = pcall(function() return char:GetAttributes() end)
                if ok and attrs then
                    for k, v in pairs(attrs) do
                        print(("     attr %s=%s"):format(tostring(k), tostring(v)))
                    end
                end

                local okc, kids = pcall(function() return char:GetChildren() end)
                if okc then
                    for _, d in ipairs(kids) do
                        print(("     child %s %s"):format(d.ClassName, d.Name))
                        if d:IsA("TextLabel") and #tostring(d.Text) <= 30 then
                            print("       text = " .. tostring(d.Text))
                        end
                    end
                end

                local okv, vals = pcall(function() return char:GetDescendants() end)
                if okv then
                    for _, d in ipairs(vals) do
                        if d:IsA("ValueBase") then
                            print(("     value %s.%s = %s"):format(d.ClassName, d.Name, tostring(d.Value)))
                        elseif d:IsA("TextLabel") and #tostring(d.Text) <= 30 then
                            print(("     label %s = %s"):format(d:GetFullName(), tostring(d.Text)))
                        end
                    end
                end

                local tool = char:FindFirstChildOfClass("Tool")
                print("     tool =", tool and tool.Name or "无")
                local bp = p:FindFirstChildOfClass("Backpack")
                if bp then
                    local names = {}
                    for _, t in ipairs(bp:GetChildren()) do
                        if t:IsA("Tool") then names[#names + 1] = t.Name end
                    end
                    print("     背包 =", #names > 0 and table.concat(names, ", ") or "空")
                end
            end
        end
    end,

    SetMode = function(mode)
        if MODE_WORDS[mode] then
            CURRENT_MODE = mode
            print("[阵营] 已切换到:", mode)
            return true
        end
        print("[阵营] 未知模式:", tostring(mode))
        return false
    end,

    AmmoScan = function()
        print("== Tool 属性 ==")
        local tool = LP.Character and LP.Character:FindFirstChildOfClass("Tool")
        if tool then
            print("  武器:", tool.Name)
            for k, v in pairs(tool:GetAttributes()) do
                print("  attr", k, tostring(v))
            end
            for _, d in ipairs(tool:GetDescendants()) do
                if d:IsA("ValueBase") then print("  val", d.Name, tostring(d.Value)) end
            end
        else
            print("  当前没有手持工具")
        end

        print("== 疑似弹药文本 ==")
        local pg = LP:FindFirstChildOfClass("PlayerGui")
        if pg then
            for _, d in ipairs(pg:GetDescendants()) do
                if d:IsA("TextLabel") then
                    local t = d.Text or ""
                    if t:match("%d%s*/%s*%d") and #t < 30 then
                        print("  " .. d:GetFullName() .. " = " .. t)
                    end
                end
            end
        end
    end,

    AimStatus = function()
        print("[瞄准] 通道:", #AIM_HOOKS > 0 and table.concat(AIM_HOOKS, ",") or "snap(镜头对准)")
        print("[瞄准] silent=", STATE.Silent, "target=", aimTarget and aimTarget.Name or "无")
        return AIM_HOOKS
    end,

    AimDebug = function()
        print("[瞄准] Silent=", STATE.Silent,
              "target=", aimTarget and aimTarget.Name or "无",
              "FOV=", AIM.FOV,
              "role=", AIM.TargetRole)
    end,

    SetAimRole = function(role)
        AIM.TargetRole = role
        print("[ESP] 瞄准目标:", tostring(role))
    end,

    KillAntiCheat = function()
        local hit = killAntiCheat()
        print("[ESP] 已禁用可疑脚本:", #hit)
        for _, n in ipairs(hit) do print("  " .. n) end
        return hit
    end,

    RoleScan = function()
        print("=== 阵营扫描 ===")
        for _, p in ipairs(Players:GetPlayers()) do
            local char = p.Character
            print(("[%s] role=%s team=%s"):format(
                p.Name, tostring(select(1, getRole(p))),
                p.Team and p.Team.Name or "无"))
            if char then
                local ok, attrs = pcall(function() return char:GetAttributes() end)
                if ok and attrs then
                    for k, v in pairs(attrs) do
                        print(("   char.attr %s=%s"):format(tostring(k), tostring(v)))
                    end
                end
                for _, d in ipairs(char:GetChildren()) do
                    if d:IsA("StringValue") or d:IsA("IntValue") then
                        print(("   char.value %s=%s"):format(d.Name, tostring(d.Value)))
                    end
                end
                local t = char:FindFirstChildOfClass("Tool")
                print("   tool:", t and t.Name or "无")
            end
        end
    end,

    Destroy = function()
        if destroyed then return end
        destroyed = true
        uiReady = false
        _G.BloodDebtESP = nil

        for key, value in pairs(STATE) do
            if type(value) == "boolean" then STATE[key] = false end
        end
        for _, connection in ipairs(menuConns) do
            pcall(function() connection:Disconnect() end)
        end
        for _, connection in ipairs(conns) do
            pcall(function() connection:Disconnect() end)
        end

        pcall(clearAll)
        pcall(resetHitbox)
        pcall(clearFly)
        pcall(closeCtx)
        local char = LP.Character
        local humanoid = char and char:FindFirstChildOfClass("Humanoid")
        if humanoid then
            pcall(function()
                humanoid.PlatformStand = false
                humanoid.CameraOffset = Vector3.zero
                if humanoid.WalkSpeed == (STATE.WalkSpeed or 16) then humanoid.WalkSpeed = 16 end
            end)
        end
        if noclipOn and char then
            noclipOn = false
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") then pcall(function() part.CanCollide = true end) end
            end
        end
        if freecamSavedType and workspace.CurrentCamera then
            pcall(function() workspace.CurrentCamera.CameraType = freecamSavedType end)
            freecamSavedType = nil
        end

        if originalRequire and hookedRequire then
            pcall(function() hookfunction(hookedRequire, originalRequire) end)
            require = originalRequire
        end
        if originalRaycast and hookedRaycast then
            pcall(function() hookfunction(hookedRaycast, originalRaycast) end)
            pcall(function() workspace.Raycast = originalRaycast end)
        end
        if originalNamecall and hookedNamecall and type(hookmetamethod) == "function" then
            pcall(function() hookmetamethod(game, "__namecall", originalNamecall) end)
        end
        if mouseMeta and originalMouseIndex then
            pcall(function()
                setreadonly(mouseMeta, false)
                mouseMeta.__index = originalMouseIndex
                setreadonly(mouseMeta, true)
            end)
        end

        pcall(function() hitSound:Destroy() end)
        if Windows then
            Windows.WindowToggle = false
            Windows.Keybind = Enum.KeyCode.Unknown
        end
        pcall(function() RunService:UnbindFromRenderStep("__LIBRARY__") end)
        if Windows and Windows.ElBlurUI and Windows.ElBlurUI.Destroy then
            pcall(function() Windows.ElBlurUI.Destroy() end)
        end
        pcall(function() if mainWindowGui then mainWindowGui:Destroy() end end)
        pcall(function() screenGui:Destroy() end)
        pcall(function() holder:Destroy() end)
    end,
}

uiReady = true
print(("[血债ESP %s] 已加载 | K 键隐藏/显示 | 玩家 %d")
    :format(VERSION, #Players:GetPlayers()))

-- ============================================================
-- Nexus Pro  PVP 辅助脚本
-- 作者：权威 | 3935754168
-- 版本：已优化 (大头功能已拆分)
-- 修改：加入真实墙壁检测，默认只锁可见目标；关闭 UI 模糊（Acrylic = false）；FOV 圈随自瞄自动显示
-- ============================================================

-- 获取各种 Roblox 服务
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualInputManager = game:GetService("VirtualInputManager")  -- 模拟鼠标/键盘输入
local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local Camera = workspace.CurrentCamera

-- 清理之前可能残留的渲染步骤和 UI，避免冲突
pcall(function()
    RunService:UnbindFromRenderStep("ZFluentPvpStep")
end)
pcall(function()
    RunService:UnbindFromRenderStep("ZPvpPanelStep")
end)
pcall(function()
    RunService:UnbindFromRenderStep("PvpFlowPanelStep")
end)
pcall(function()
    local old = PlayerGui:FindFirstChild("ZFluentPvpOverlay")
    if old then old:Destroy() end
end)
pcall(function()
    local old = PlayerGui:FindFirstChild("ZPvpFallbackUI")
    if old then old:Destroy() end
end)
pcall(function()
    local old = PlayerGui:FindFirstChild("PvpFlowPanel")
    if old then old:Destroy() end
end)

-- ============================================================
-- 一些全局缓存变量（用于性能优化）
-- ============================================================
local espUpdateTimer = 0
local recoilTimer = 0
local lastRecoilTool = nil
local recoilCache = {}
local statusTimer = 0
local lastAppliedWalkSpeed = nil
local wallBangCacheTime = 0
local wallBangCache = {}
local bigHeadTick = 0
local radarTick = 0
local lastHpCache = {}

-- ============================================================
-- 核心状态表（所有功能的开关与参数）
-- ============================================================
local state = {
    -- 玩家自瞄相关
    selected = nil,              -- 手动选择的玩家
    aimEnabled = false,          -- 是否启用 FOV 吸附
    holdRight = false,           -- 是否按住右键（PC）或触摸（手机）才启用吸附
    rightDown = false,           -- 当前是否正在触摸/按住鼠标
    wallAim = false,             -- 是否允许穿墙吸附
    wallBang = false,            -- 是否开启穿墙子弹（Hook 射线检测）
    showFov = false,             -- 显示 FOV 圆圈（默认关闭，由自瞄联动控制）
    enemyEsp = false,            -- 敌人高亮
    friendEsp = false,           -- 队友高亮
    nameTags = false,            -- 头顶身份牌
    targetMarker = false,        -- 目标点标记
    enemyOnly = false,           -- 只锁定敌人
    teamCheck = true,            -- 启用阵营检测（默认开启，修复队友误判）
    unknownAsEnemy = false,      -- 未知阵营视为敌人
    autoTestFire = false,        -- 自动开火（模拟左键点击）
    spinScan = false,            -- 旋转扫描
    spinSpeed = 80,              -- 旋转速度（度/秒）
    fireCooldown = 0.18,         -- 自动开火间隔（秒）
    lastFireAt = 0,              -- 上次开火时间戳
    fovRadius = 150,             -- FOV 半径（像素）
    maxDistance = 300,           -- 最大锁定距离（Studs）
    smooth = 0.18,               -- 摄像机平滑度（0~1）
    aimPart = "Head",            -- 瞄准部位名称
    aimDead = false,             -- 是否瞄准已死亡目标
    detachOnDeath = false,       -- 目标死亡后自动脱离
    onlySelected = false,        -- 只吸附所选玩家
    currentTarget = nil,         -- 当前锁定的玩家
    playerInput = "",            -- 玩家名称输入框内容
    noRecoil = false,            -- 无后坐力
    noSpread = false,            -- 无扩散
    bulletTracer = false,        -- 子弹追踪线
    radar = false,               -- 雷达
    radarSize = 160,             -- 雷达尺寸
    radarZoom = 60,              -- 雷达显示范围

    -- 假人（NPC）相关独立配置
    aimDummy = false,
    dummyEsp = false,
    dummyAim = false,
    dummyHoldRight = false,
    dummyRightDown = false,
    dummyWallAim = false,
    dummyFovRadius = 200,
    dummyMaxDistance = 400,
    dummySmooth = 0.18,
    dummyAimPart = "Head",
    dummyAutoFire = false,
    dummyCurrentTarget = nil,
    dummyDetached = {},
    dummyShowFov = false,

    -- 其他功能
    customFov = 70,              -- 自定义视野角度
    fovEnabled = false,          -- 是否启用自定义 FOV
    walkSpeed = 16,              -- 自定义移速值
    walkSpeedEnabled = false,    -- 是否启用移速修改
    -- 大头功能拆分（原 bigHead 已移除）
    bigHeadEnemy = false,        -- 敌人大头
    bigHeadFriend = false,       -- 队友大头
    bigHeadAll = false,          -- 全部大头（覆盖前两者）
    bigHeadScale = 1.5,          -- 大头倍数
    autoBhop = false,            -- 自动连跳
    silentAim = false,           -- 静默自瞄（子弹拐弯）
    showHud = false,             -- 显示 HUD 文字提示
    targetPriority = "distance", -- 目标优先级（distance / lowestHp）
    bulletTime = false,          -- 子弹时间（降低移速和 FOV）
    bulletTimeFov = 20,
    bulletTimeWalk = 8,
    tracerThickness = 1.5,
    originalFov = 70,            -- 保存游戏原本的 FOV
    originalWalk = 16,           -- 保存游戏原本的移速

    -- 自定义准星配置
    crosshair = {
        enabled = false,
        shape = "cross",
        size = 10,
        gap = 4,
        thickness = 2,
        colorIndex = 1,
        transparency = 0,
        centerDot = true,
        centerDotRadius = 2,
        outline = false,
        outlineThickness = 1,
        dynamicSpread = false,
        spreadAmount = 8,
        spreadCurrent = 0,
        spreadRecovery = 0.15,
    },

    -- 好友白名单（手动添加）
    friendWhitelist = {},        -- 键为玩家名，值为 true
}

-- 可选的瞄准部位列表
local aimParts = { "Head", "UpperTorso", "HumanoidRootPart", "LowerTorso", "Torso" }
local espStore = {}          -- 存储每个玩家的 Highlight 对象
local tagStore = {}          -- 存储每个玩家的 BillboardGui（身份牌）
local avatarCache = {}       -- 缓存玩家头像 URL
local uiStore = {}           -- 存储 UI 元素（FOV 圈、标记等）
local uiRefs = {}            -- 存储 Fluent UI 组件引用
local detachedTargets = {}   -- 被标记为“已脱离”的目标（避免重复锁定）
local lastStatusText = nil   -- 状态栏上次显示的文字

local tracerLines = {}       -- 子弹轨迹线（Drawing 对象）
local radarGui = nil
local radarFrame = nil
local radarDots = {}

local bulletTrack = {}       -- 跟踪子弹零件
local headSizes = {}         -- 存储每个头部零件的原始大小
local hudLabels = {}
local dummyCache = {}
local dummyEspStore = {}
local keybindRefs = {}
local bulletTimeHeld = false
local crosshairElements = {}

-- 需要被清理的旧版 UI 名称列表
local tagNames = {
    ZPvpNameTag = true,
    PvpNameTag = true,
    PvpFlowNameTag = true,
    PlayerESPNameTag = true,
}

local highlightNames = {
    ZPvpTeamHighlight = true,
    PvpTeamHighlight = true,
    PlayerESP = true,
}

-- 准星颜色表
local crosshairColors = {
    { name = "绿色", value = Color3.fromRGB(0, 255, 0) },
    { name = "红色", value = Color3.fromRGB(255, 45, 72) },
    { name = "青色", value = Color3.fromRGB(0, 255, 255) },
    { name = "蓝色", value = Color3.fromRGB(0, 150, 255) },
    { name = "黄色", value = Color3.fromRGB(255, 255, 0) },
    { name = "白色", value = Color3.fromRGB(255, 255, 255) },
    { name = "紫色", value = Color3.fromRGB(180, 60, 255) },
    { name = "橙色", value = Color3.fromRGB(255, 140, 0) },
}
local crosshairColorNames = {}
for _, c in ipairs(crosshairColors) do
    table.insert(crosshairColorNames, c.name)
end

-- 保存默认状态用于重置
local defaultStateSnapshot = {}
for k, v in pairs(state) do
    if type(v) == "table" then
        local copy = {}
        for k2, v2 in pairs(v) do copy[k2] = v2 end
        defaultStateSnapshot[k] = copy
    else
        defaultStateSnapshot[k] = v
    end
end

-- ============================================================
-- 配置保存与加载（使用 writefile/readfile）
-- ============================================================
local config = {
    path = "NexusPvpMobileConfig.json",
    blacklist = {  -- 这些字段不保存（运行时数据）
        selected = true,
        currentTarget = true,
        dummyCurrentTarget = true,
        playerInput = true,
        lastFireAt = true,
        originalFov = true,
        originalWalk = true,
        holdRight = true,
        rightDown = true,
        dummyHoldRight = true,
        dummyRightDown = true,
        friendWhitelist = true,  -- 白名单不保存（或保存也可，但为了简洁暂时不保存）
    },
}

local function configSupported()
    return type(writefile) == "function" and type(readfile) == "function"
end

-- 对加载的数值进行合法范围限制
local function sanitizeLoaded(t)
    local clamps = {
        walkSpeed = { 8, 500 },
        bigHeadScale = { 1.1, 10 },
        fovRadius = { 50, 460 },
        maxDistance = { 20, 2000 },
        smooth = { 0.03, 0.75 },
        dummyFovRadius = { 50, 460 },
        dummyMaxDistance = { 50, 2000 },
        dummySmooth = { 0.03, 0.75 },
        spinSpeed = { 20, 240 },
        fireCooldown = { 0.08, 1 },
        radarSize = { 100, 260 },
        radarZoom = { 20, 150 },
        customFov = { 20, 120 },
        bulletTimeFov = { 10, 120 },
        bulletTimeWalk = { 1, 120 },
    }
    for k, v in pairs(t) do
        if typeof(v) ~= "number" then continue end
        local c = clamps[k]
        if c then t[k] = math.clamp(v, c[1], c[2]) end
    end
    -- 准星参数限制
    if type(t.crosshair) == "table" then
        local ch = t.crosshair
        if typeof(ch.size) == "number" then ch.size = math.clamp(ch.size, 4, 30) end
        if typeof(ch.gap) == "number" then ch.gap = math.clamp(ch.gap, 0, 20) end
        if typeof(ch.thickness) == "number" then ch.thickness = math.clamp(ch.thickness, 1, 6) end
        if typeof(ch.spreadAmount) == "number" then ch.spreadAmount = math.clamp(ch.spreadAmount, 2, 30) end
        if typeof(ch.centerDotRadius) == "number" then ch.centerDotRadius = math.clamp(ch.centerDotRadius, 1, 8) end
        if typeof(ch.transparency) == "number" then ch.transparency = math.clamp(ch.transparency, 0, 1) end
        if typeof(ch.colorIndex) == "number" then ch.colorIndex = math.clamp(math.floor(ch.colorIndex), 1, #crosshairColors) end
        if typeof(ch.outlineThickness) == "number" then ch.outlineThickness = math.clamp(ch.outlineThickness, 1, 3) end
    end
    return t
end

-- 保存配置到文件
local function saveConfig()
    if not configSupported() then
        return false, "当前执行器不支持文件读写"
    end
    local t = {}
    for k, v in pairs(state) do
        if config.blacklist[k] then continue end
        local ty = typeof(v)
        if ty == "boolean" or ty == "number" or ty == "string" then
            t[k] = v
        end
    end
    if type(state.crosshair) == "table" then
        local ch, out = state.crosshair, {}
        for _, k in ipairs({ "enabled", "shape", "size", "gap", "thickness", "colorIndex", "transparency", "centerDot", "centerDotRadius", "outline", "outlineThickness", "dynamicSpread", "spreadAmount" }) do
            out[k] = ch[k]
        end
        t.crosshair = out
    end
    local ok, json = pcall(function()
        return HttpService:JSONEncode(t)
    end)
    if not ok then return false, "序列化失败" end
    local ok2, err = pcall(function()
        writefile(config.path, json)
    end)
    if not ok2 then return false, tostring(err) end
    return true
end

-- 加载配置（含自动修正）
local function loadConfig()
    if not configSupported() then return false end
    if type(isfile) == "function" and not isfile(config.path) then return false end
    local ok, data = pcall(readfile, config.path)
    if not ok or type(data) ~= "string" then return false end
    local ok2, t = pcall(function()
        return HttpService:JSONDecode(data)
    end)
    if not ok2 or type(t) ~= "table" then return false end
    t = sanitizeLoaded(t)
    for k, v in pairs(t) do
        if config.blacklist[k] then continue end
        if state[k] ~= nil and typeof(v) == typeof(state[k]) then
            state[k] = v
        end
    end
    if type(t.crosshair) == "table" and type(state.crosshair) == "table" then
        for k, v in pairs(t.crosshair) do
            if state.crosshair[k] ~= nil and typeof(v) == typeof(state.crosshair[k]) then
                state.crosshair[k] = v
            end
        end
    end

    -- ===== 兼容旧版 bigHead 配置 =====
    if t.bigHead ~= nil then
        state.bigHeadAll = t.bigHead
        state.bigHead = nil  -- 清理旧字段
    end

    -- ===== 自动修正：队友ESP与阵营检测的冲突 =====
    if state.friendEsp and not state.teamCheck then
        state.teamCheck = true
        warn("[Nexus Pro] 检测到队友ESP开启但阵营检测关闭，已自动开启阵营检测")
    end
    if state.friendEsp and state.unknownAsEnemy then
        warn("[Nexus Pro] 队友ESP已开启，但'未知阵营算敌人'为true，可能会导致部分队友被误判为敌人，建议关闭该选项")
    end

    -- 强制关闭吸附（避免加载后意外生效）
    state.aimEnabled = false
    state.spinScan = false
    return true
end

-- 重置为默认配置
local function resetConfig()
    if type(defaultStateSnapshot) == "table" then
        for k, v in pairs(defaultStateSnapshot) do
            if config.blacklist[k] then continue end
            if state[k] ~= nil then
                if type(v) == "table" then
                    if type(state[k]) == "table" then
                        for k2, v2 in pairs(v) do state[k][k2] = v2 end
                    end
                else
                    state[k] = v
                end
            end
        end
    end
    if configSupported() then
        pcall(function()
            if type(delfile) == "function" then
                delfile(config.path)
            end
        end)
    end
end

-- ============================================================
-- 工具函数：安全销毁、获取角色部件、阵营判断等
-- ============================================================
local function safeDestroy(x)
    if x then
        pcall(function()
            x:Destroy()
        end)
    end
end

local function char(plr)
    return plr and plr.Character
end

local function hum(plr)
    local c = char(plr)
    return c and c:FindFirstChildOfClass("Humanoid")
end

local function root(plr)
    local c = char(plr)
    return c and c:FindFirstChild("HumanoidRootPart")
end

local function isAlive(plr)
    if not plr then return false end
    if typeof(plr) == "Instance" and plr:IsA("Player") then
        local h = hum(plr)
        return h and h.Health > 0
    end
    if typeof(plr) == "Instance" and plr:IsA("Model") then
        local h = plr:FindFirstChildOfClass("Humanoid")
        return h and h.Health > 0
    end
    return false
end

-- ===== 增强版敌我判断（含白名单、Neutral、扩展属性） =====
local function isEnemy(plr)
    if not plr or plr == LocalPlayer then return false end

    -- 1. 白名单强制视为队友
    if state.friendWhitelist[plr.Name] or state.friendWhitelist[plr.DisplayName] then
        return false
    end

    -- 2. 若未启用阵营检测，则所有玩家视为敌人
    if not state.teamCheck then return true end

    -- 3. Team 对象检测（含 Neutral 中立判断）
    if LocalPlayer.Team ~= nil and plr.Team ~= nil then
        if LocalPlayer.Neutral or plr.Neutral then
            return state.unknownAsEnemy
        end
        return LocalPlayer.Team ~= plr.Team
    end

    -- 4. TeamColor 检测（含 Neutral 中立判断）
    if LocalPlayer.TeamColor ~= nil and plr.TeamColor ~= nil then
        if LocalPlayer.Neutral or plr.Neutral then
            return state.unknownAsEnemy
        end
        return LocalPlayer.TeamColor ~= plr.TeamColor
    end

    -- 5. 扩展阵营属性检测（加入更多常见属性名）
    local attrKeys = {
        "Team", "Faction", "Side", "Camp", "Group", "Squad", "Role",
        "Clan", "Alliance", "Guild", "FactionName", "Affiliation", "Party",
        "Color", "Index", "Allegiance", "Division", "Squadron"
    }
    for _, key in ipairs(attrKeys) do
        local mine = LocalPlayer:GetAttribute(key)
        local theirs = plr:GetAttribute(key)
        if mine ~= nil and theirs ~= nil and tostring(mine) ~= "" and tostring(theirs) ~= "" then
            return tostring(mine) ~= tostring(theirs)
        end
    end

    -- 6. 无法判断时按 unknownAsEnemy 处理（默认 false，即视为队友）
    return state.unknownAsEnemy
end

local function getPart(plr)
    local c = char(plr)
    if not c then return nil end
    local p = c:FindFirstChild(state.aimPart)
        or c:FindFirstChild("Head")
        or c:FindFirstChild("UpperTorso")
        or c:FindFirstChild("HumanoidRootPart")
        or c:FindFirstChild("Torso")
    if p and p:IsA("BasePart") and p.Name ~= "Handle" then return p end
    for _, desc in ipairs(c:GetDescendants()) do
        if desc:IsA("BasePart") and desc.Name ~= "Handle" then
            return desc
        end
    end
    return nil
end

-- 获取玩家所有可用的部位（用于 FOV 内检测）
local function getCandidateParts(plr)
    local c = char(plr)
    if not c then return {} end
    local out = {}
    local seen = {}
    for _, name in ipairs({ state.aimPart, "Head", "UpperTorso", "HumanoidRootPart", "LowerTorso", "Torso" }) do
        local part = c:FindFirstChild(name)
        if part and part:IsA("BasePart") and part.Name ~= "Handle" and not seen[part] then
            seen[part] = true
            table.insert(out, part)
        end
    end
    if #out == 0 then
        for _, desc in ipairs(c:GetDescendants()) do
            if desc:IsA("BasePart") and desc.Name ~= "Handle" and not seen[desc] then
                seen[desc] = true
                table.insert(out, desc)
            end
        end
    end
    return out
end

-- 获取所有在线玩家名称（用于 UI 列表）
local function playerNames()
    local names = {}
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer then
            table.insert(names, plr.Name)
        end
    end
    table.sort(names)
    if #names == 0 then
        table.insert(names, "无在线玩家")
    end
    return names
end

-- 根据名称查找玩家（支持模糊匹配）
local function findPlayerByName(name)
    name = tostring(name or "")
    local needle = string.lower(name)
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr.Name == name or plr.DisplayName == name then
            return plr
        end
    end
    if needle ~= "" then
        for _, plr in ipairs(Players:GetPlayers()) do
            local n = string.lower(plr.Name)
            local d = string.lower(plr.DisplayName)
            if n:find(needle, 1, true) or d:find(needle, 1, true) then
                return plr
            end
        end
    end
    return nil
end

local _bypassWallBang = false  -- 用于穿墙时绕过自身的射线检测 Hook

-- 判断角色是否可见（有射线遮挡检测，但穿墙模式会忽略）
local function lineOfSight(part)
    return true  -- 此处被简化，实际在 isCharacterVisible 中实现
end

-- 实际可见性检测
local function isCharacterVisible(plr)
    local cam = workspace.CurrentCamera
    if not cam then return true end
    local c = char(plr)
    if not c then return true end
    local head = c:FindFirstChild("Head") or c:FindFirstChild("HumanoidRootPart")
    if not head then return true end
    local origin = cam.CFrame.Position
    local dir = head.Position - origin
    if dir.Magnitude <= 0.1 then return true end

    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    local excl = {}
    local myC = LocalPlayer.Character
    if myC then table.insert(excl, myC) end
    table.insert(excl, c)
    params.FilterDescendantsInstances = excl

    _bypassWallBang = true  -- 临时禁用穿墙 Hook，防止递归
    local ok, hit = pcall(workspace.Raycast, workspace, origin, dir, params)
    _bypassWallBang = false

    if not ok then return true end
    return not (hit and hit.Instance)
end

-- ============================================================
-- UI 创建函数（FOV 圆圈、目标标记、身份牌、ESP 等）
-- ============================================================
local function makeOverlay()
    if uiStore.overlay and uiStore.overlay.Parent then
        return uiStore.overlay
    end
    local gui = Instance.new("ScreenGui")
    gui.Name = "ZFluentPvpOverlay"
    gui.ResetOnSpawn = false
    gui.IgnoreGuiInset = true
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    gui.Parent = PlayerGui
    uiStore.overlay = gui
    return gui
end

-- 清除玩家的身份牌
local function destroyPlayerTags(plr)
    local c = char(plr)
    if c then
        for _, obj in ipairs(c:GetDescendants()) do
            if tagNames[obj.Name] and obj:IsA("BillboardGui") then
                safeDestroy(obj)
            end
        end
    end
    safeDestroy(tagStore[plr])
    tagStore[plr] = nil
    lastHpCache[plr] = nil
end

-- 清除玩家的 Highlight（ESP）
local function destroyPlayerHighlights(plr)
    local c = char(plr)
    if c then
        for _, obj in ipairs(c:GetDescendants()) do
            if highlightNames[obj.Name] and obj:IsA("Highlight") then
                safeDestroy(obj)
            end
        end
    end
    safeDestroy(espStore[plr])
    espStore[plr] = nil
end

-- 清理所有视觉元素
local function clearVisuals()
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer then
            destroyPlayerTags(plr)
            destroyPlayerHighlights(plr)
        end
    end
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("Highlight") and (obj.Name == "ZPvpDummyHighlight" or obj.Name == "ZPvpHackDummyESP") then
            safeDestroy(obj)
        end
    end
    safeDestroy(uiStore.marker)
    uiStore.marker = nil
    safeDestroy(uiStore.fovCircle)
    uiStore.fovCircle = nil
    safeDestroy(uiStore.dummyFovCircle)
    uiStore.dummyFovCircle = nil
    safeDestroy(uiStore.dummyMarker)
    uiStore.dummyMarker = nil
    table.clear(dummyEspStore)
    for _, el in ipairs(crosshairElements) do
        safeDestroy(el)
    end
    table.clear(crosshairElements)
    table.clear(lastHpCache)
end

-- 更新状态栏文字
local function updateStatus(text)
    if text == lastStatusText then return end
    lastStatusText = text
    if uiRefs.statusParagraph and type(uiRefs.statusParagraph.SetDesc) == "function" then
        pcall(function()
            uiRefs.statusParagraph:SetDesc(text)
        end)
    elseif uiRefs.statusParagraph and type(uiRefs.statusParagraph.Set) == "function" then
        pcall(function()
            uiRefs.statusParagraph:Set({ Title = "状态", Content = text })
        end)
    end
end

-- 更新玩家列表段落
local function updatePlayerParagraph()
    if not uiRefs.playersParagraph then return end
    local selected = state.selected and state.selected.Name or "无"
    local content = "当前选择：" .. selected .. "\n在线玩家：\n" .. table.concat(playerNames(), "\n")
    if type(uiRefs.playersParagraph.SetDesc) == "function" then
        pcall(function()
            uiRefs.playersParagraph:SetDesc(content)
        end)
    elseif type(uiRefs.playersParagraph.Set) == "function" then
        pcall(function()
            uiRefs.playersParagraph:Set({ Title = "玩家列表", Content = content })
        end)
    end
end

-- 更新 FOV 圆圈（玩家自瞄用）
local function updateFovCircle()
    local gui = makeOverlay()
    if not state.showFov then
        safeDestroy(uiStore.fovCircle)
        uiStore.fovCircle = nil
        return
    end

    local circle = uiStore.fovCircle
    if not circle or not circle.Parent then
        circle = Instance.new("Frame")
        circle.Name = "ZPvpFovCircle"
        circle.BackgroundTransparency = 1
        circle.BorderSizePixel = 0
        circle.ZIndex = 90
        circle.Parent = gui

        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(1, 0)
        corner.Parent = circle

        local stroke = Instance.new("UIStroke")
        stroke.Name = "Stroke"
        stroke.Color = Color3.fromRGB(255, 45, 72)
        stroke.Transparency = 0.16
        stroke.Thickness = 2
        stroke.Parent = circle

        uiStore.fovCircle = circle
    end

    local r = state.fovRadius
    circle.Size = UDim2.fromOffset(r * 2, r * 2)
    circle.Position = UDim2.new(0.5, -r, 0.5, -r)

    local stroke = circle:FindFirstChild("Stroke")
    if stroke then
        stroke.Color = state.aimEnabled and Color3.fromRGB(255, 45, 72) or Color3.fromRGB(235, 235, 235)
        stroke.Transparency = state.aimEnabled and 0.08 or 0.46
    end
end

-- 更新假人 FOV 圆圈
local function updateDummyFovCircle()
    local gui = makeOverlay()
    if not state.dummyShowFov then
        safeDestroy(uiStore.dummyFovCircle)
        uiStore.dummyFovCircle = nil
        return
    end

    local circle = uiStore.dummyFovCircle
    if not circle or not circle.Parent then
        circle = Instance.new("Frame")
        circle.Name = "ZPvpDummyFovCircle"
        circle.BackgroundTransparency = 1
        circle.BorderSizePixel = 0
        circle.ZIndex = 89
        circle.Parent = gui

        Instance.new("UICorner", circle).CornerRadius = UDim.new(1, 0)

        local stroke = Instance.new("UIStroke")
        stroke.Name = "Stroke"
        stroke.Color = Color3.fromRGB(180, 50, 255)
        stroke.Transparency = 0.12
        stroke.Thickness = 2
        stroke.Parent = circle

        uiStore.dummyFovCircle = circle
    end

    local r = state.dummyFovRadius
    circle.Size = UDim2.fromOffset(r * 2, r * 2)
    circle.Position = UDim2.new(0.5, -r, 0.5, -r)

    local stroke = circle:FindFirstChild("Stroke")
    if stroke then
        stroke.Color = Color3.fromRGB(180, 50, 255)
        stroke.Transparency = 0.12
    end
end

-- 更新目标标记（红点）
local function updateTargetMarker(part)
    local gui = makeOverlay()
    if not state.targetMarker or not part then
        safeDestroy(uiStore.marker)
        uiStore.marker = nil
        return
    end

    local cam = workspace.CurrentCamera
    if not cam then return end
    local pos, visible = cam:WorldToViewportPoint(part.Position)
    if not visible then
        safeDestroy(uiStore.marker)
        uiStore.marker = nil
        return
    end

    local marker = uiStore.marker
    if not marker or not marker.Parent then
        marker = Instance.new("Frame")
        marker.Name = "ZPvpTargetMarker"
        marker.Size = UDim2.fromOffset(10, 10)
        marker.AnchorPoint = Vector2.new(0.5, 0.5)
        marker.BackgroundColor3 = Color3.fromRGB(255, 45, 72)
        marker.BorderSizePixel = 0
        marker.ZIndex = 95
        marker.Parent = gui

        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(1, 0)
        corner.Parent = marker

        local stroke = Instance.new("UIStroke")
        stroke.Color = Color3.fromRGB(255, 255, 255)
        stroke.Transparency = 0.08
        stroke.Thickness = 1
        stroke.Parent = marker

        uiStore.marker = marker
    end

    marker.Position = UDim2.fromOffset(pos.X, pos.Y)
end

-- ============================================================
-- 核心函数：更新单个玩家的 ESP 和身份牌
-- ============================================================
local function updateEspFor(plr)
    local c = char(plr)
    local h = hum(plr)
    local enemy = isEnemy(plr)
    local headPart = c and c:FindFirstChild("Head")

    -- 判断是否需要绘制 ESP 或身份牌
    local shouldEsp = c and h and h.Health > 0 and ((enemy and state.enemyEsp) or ((not enemy) and state.friendEsp))
    local shouldNameTag = state.nameTags and headPart and h and h.Health > 0

    if not shouldEsp and not shouldNameTag then
        destroyPlayerHighlights(plr)
        destroyPlayerTags(plr)
        return
    end

    -- 可见性检测
    local visible = true
    if shouldEsp then
        visible = isCharacterVisible(plr)
    end

    -- 颜色设置（敌人可见为蓝，不可见为红；队友可见为亮绿，不可见为暗绿）
    local espColor
    local outlineColor
    if enemy then
        espColor = visible and Color3.fromRGB(52, 152, 255) or Color3.fromRGB(255, 45, 72)
        outlineColor = visible and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(255, 160, 160)
    else
        -- 队友使用更亮的绿色，并降低透明度使轮廓更清晰
        espColor = visible and Color3.fromRGB(0, 255, 100) or Color3.fromRGB(39, 174, 96)
        outlineColor = visible and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(200, 255, 200)
    end

    -- 绘制 ESP（Highlight）
    if shouldEsp then
        if not espStore[plr] or espStore[plr].Parent ~= c then
            destroyPlayerHighlights(plr)
            local hi = Instance.new("Highlight")
            hi.Name = "ZPvpTeamHighlight"
            hi.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
            -- 队友透明度更低（更显眼），敌人透明度稍高
            hi.FillTransparency = enemy and 0.62 or 0.50
            hi.OutlineTransparency = 0
            hi.Parent = c
            espStore[plr] = hi
        end
        espStore[plr].FillColor = espColor
        espStore[plr].OutlineColor = outlineColor
    else
        destroyPlayerHighlights(plr)
    end

    -- 绘制身份牌（包含头像、姓名、血量条和数值）
    if shouldNameTag then
        if not tagStore[plr] or tagStore[plr].Parent ~= headPart then
            destroyPlayerTags(plr)

            local bill = Instance.new("BillboardGui")
            bill.Name = "ZPvpNameTag"
            bill.Adornee = headPart
            bill.AlwaysOnTop = true
            bill.StudsOffset = Vector3.new(0, 3.2, 0)
            bill.Size = UDim2.fromOffset(150, 56)
            bill.Parent = headPart

            local tag = Instance.new("Frame")
            tag.Name = "Tag"
            tag.Size = UDim2.fromScale(1, 1)
            tag.BackgroundColor3 = Color3.fromRGB(10, 10, 12)
            tag.BackgroundTransparency = 0.35
            tag.BorderSizePixel = 0
            tag.Parent = bill
            Instance.new("UICorner", tag).CornerRadius = UDim.new(0, 9)

            local glassSheen = Instance.new("UIGradient")
            glassSheen.Name = "GlassSheen"
            glassSheen.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255), 0.8),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255), 1),
            })
            glassSheen.Parent = tag

            local stroke = Instance.new("UIStroke")
            stroke.Name = "Stroke"
            stroke.Color = Color3.fromRGB(255, 255, 255)
            stroke.Transparency = 0.35
            stroke.Thickness = 1
            stroke.Parent = tag

            -- 头像
            local avatar = Instance.new("ImageLabel")
            avatar.Name = "Avatar"
            avatar.Position = UDim2.fromOffset(5, 5)
            avatar.Size = UDim2.fromOffset(20, 20)
            avatar.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            avatar.BackgroundTransparency = 0.8
            avatar.BorderSizePixel = 0
            avatar.ScaleType = Enum.ScaleType.Fit
            avatar.Parent = tag
            Instance.new("UICorner", avatar).CornerRadius = UDim.new(1, 0)
            local avatarStroke = Instance.new("UIStroke")
            avatarStroke.Color = Color3.fromRGB(255, 255, 255)
            avatarStroke.Transparency = 0.4
            avatarStroke.Thickness = 1
            avatarStroke.Parent = avatar

            -- 异步加载头像
            local function applyAvatar(img)
                if avatar and avatar.Parent and type(img) == "string" and img ~= "" then
                    avatar.Image = img
                end
            end

            local cachedUrl = avatarCache[plr]
            if type(cachedUrl) == "string" and cachedUrl ~= "" then
                applyAvatar(cachedUrl)
            else
                task.spawn(function()
                    local url = ""
                    for _ = 1, 5 do
                        local ok, got = pcall(function()
                            return game:GetService("Thumbnails"):GetPlayerThumbnail(plr.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size150x150)
                        end)
                        if ok and type(got) == "string" and got ~= "" then
                            url = got
                            break
                        end
                        task.wait(1)
                    end
                    if url == "" then
                        url = "rbxthumb://type=AvatarHeadShot&id=" .. plr.UserId .. "&w=150&h=150"
                    end
                    avatarCache[plr] = url
                    applyAvatar(url)
                end)
            end

            -- 玩家名
            local name = Instance.new("TextLabel")
            name.Name = "Name"
            name.Position = UDim2.fromOffset(30, 6)
            name.Size = UDim2.new(1, -36, 0, 12)
            name.BackgroundTransparency = 1
            name.BorderSizePixel = 0
            name.Font = Enum.Font.GothamBold
            name.TextSize = 10
            name.TextColor3 = Color3.fromRGB(255, 255, 255)
            name.TextStrokeTransparency = 0.5
            name.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
            name.TextXAlignment = Enum.TextXAlignment.Left
            name.Parent = tag

            -- 血量条背景
            local barBg = Instance.new("Frame")
            barBg.Name = "BarBg"
            barBg.Position = UDim2.fromOffset(6, 33)
            barBg.Size = UDim2.new(1, -12, 0, 2)
            barBg.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            barBg.BackgroundTransparency = 0.75
            barBg.BorderSizePixel = 0
            barBg.Parent = tag
            Instance.new("UICorner", barBg).CornerRadius = UDim.new(1, 0)

            -- 血量条填充
            local barFill = Instance.new("Frame")
            barFill.Name = "BarFill"
            barFill.Size = UDim2.fromScale(1, 1)
            barFill.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            barFill.BorderSizePixel = 0
            barFill.Parent = barBg
            Instance.new("UICorner", barFill).CornerRadius = UDim.new(1, 0)

            -- 血量数值
            local hp = Instance.new("TextLabel")
            hp.Name = "Hp"
            hp.Position = UDim2.fromOffset(0, 38)
            hp.Size = UDim2.new(1, 0, 0, 10)
            hp.BackgroundTransparency = 1
            hp.BorderSizePixel = 0
            hp.Font = Enum.Font.GothamBold
            hp.TextSize = 8
            hp.TextColor3 = Color3.fromRGB(215, 215, 215)
            hp.TextStrokeTransparency = 0.6
            hp.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
            hp.TextXAlignment = Enum.TextXAlignment.Center
            hp.Parent = tag

            tagStore[plr] = bill

            -- 初始化血量显示
            local currentHP = math.floor(h.Health)
            local maxHp = h.MaxHealth > 0 and h.MaxHealth or 100
            name.Text = plr.Name
            hp.Text = currentHP .. " / " .. math.floor(maxHp)
            local ratio = math.clamp(currentHP / maxHp, 0, 1)
            barFill.Size = UDim2.fromScale(ratio, 1)
            lastHpCache[plr] = currentHP
        else
            -- 更新血量（只更新数值变化，减少开销）
            local tag = tagStore[plr]:FindFirstChild("Tag")
            if tag then
                local currentHP = math.floor(h.Health)
                if lastHpCache[plr] ~= currentHP then
                    local name = tag:FindFirstChild("Name")
                    local hp = tag:FindFirstChild("Hp")
                    local barBg = tag:FindFirstChild("BarBg")
                    local barFill = barBg and barBg:FindFirstChild("BarFill")
                    local maxHp = h.MaxHealth > 0 and h.MaxHealth or 100
                    if name then
                        name.Text = plr.Name
                    end
                    if hp then
                        hp.Text = currentHP .. " / " .. math.floor(maxHp)
                    end
                    if barFill then
                        local ratio = math.clamp(currentHP / maxHp, 0, 1)
                        barFill.Size = UDim2.fromScale(ratio, 1)
                    end
                    lastHpCache[plr] = currentHP
                end
            end
        end
    else
        destroyPlayerTags(plr)
    end
end

-- ============================================================
-- 假人（NPC）相关函数
-- ============================================================
local function getPartForModel(m)
    local p = m:FindFirstChild(state.aimPart)
        or m:FindFirstChild("Head")
        or m:FindFirstChild("UpperTorso")
        or m:FindFirstChild("HumanoidRootPart")
        or m:FindFirstChild("Torso")
    if p then return p end
    for _, desc in ipairs(m:GetDescendants()) do
        if desc:IsA("BasePart") and desc.Name ~= "Handle" and desc.Name ~= "HumanoidRootPart" then
            return desc
        end
    end
    local root = m:FindFirstChild("HumanoidRootPart")
    if root then return root end
    return nil
end

local function isPlayerName(name)
    for _, p in ipairs(Players:GetPlayers()) do
        if p.Name == name or p.DisplayName == name then return true end
    end
    return false
end

local function isPlayerCharModel(obj)
    for _, p in ipairs(Players:GetPlayers()) do
        if p.Character == obj then return true end
    end
    return false
end

local excludedPaths = { "Workspace.Lobby", "Workspace.Highlight", "Workspace.Effects", "Workspace.Camera", "Workspace._Temp" }

local function isExcludedPath(obj)
    for _, prefix in ipairs(excludedPaths) do
        local full = obj:GetFullName()
        if full:find(prefix, 1, true) == 1 then return true end
    end
    return false
end

local dummyCacheList = {}
local lastDummyScan = 0

-- 获取场景中的假人模型（缓存优化）
local function getDummyModels()
    local now = os.clock()
    if now - lastDummyScan < 0.5 and #dummyCacheList > 0 and cacheValid() then
        return dummyCacheList
    end
    lastDummyScan = now
    local out = {}
    local seen = {}
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("Model") and obj:FindFirstChildOfClass("Humanoid") and not seen[obj] then
            seen[obj] = true
            local h = obj:FindFirstChildOfClass("Humanoid")
            if not h or h.Health <= 0 then continue end
            if not isPlayerCharModel(obj) and not isPlayerName(obj.Name) and not isExcludedPath(obj) then
                table.insert(out, obj)
            end
        end
    end
    dummyCacheList = out
    return out
end

local function findDummyHead(m)
    local h = m:FindFirstChild("Head")
    if h then return h end
    for _, d in ipairs(m:GetDescendants()) do
        if d:IsA("BasePart") and d.Name == "Head" then
            return d
        end
    end
    return nil
end

local function getDummyAimPart(m)
    if state.dummyAimPart == "Root" then
        return m:FindFirstChild("HumanoidRootPart") or findDummyHead(m)
    end
    return findDummyHead(m) or m:FindFirstChild("HumanoidRootPart")
end

local function isAliveDummy(m)
    local h = m:FindFirstChildOfClass("Humanoid")
    return h and h.Health > 0
end

-- 获取最佳假人目标（类似 getBestTarget 但针对模型）
local function getBestDummyTarget()
    local cam = workspace.CurrentCamera
    if not cam then return nil, nil, { dummies = 0 } end
    local vp = cam.ViewportSize
    local center = Vector2.new(vp.X / 2, vp.Y / 2)
    local myRoot = root(LocalPlayer)
    local best = nil
    local fov = state.dummyFovRadius or 200
    local wallAim = state.dummyWallAim
    local diag = { dummies = 0, alive = 0, inFov = 0, inRange = 0, noPart = 0 }

    local function better(a, b)
        if not b then return true end
        if a.visible ~= b.visible then
            return a.visible
        end
        if math.abs(a.wd - b.wd) > 0.5 then
            return a.wd < b.wd
        end
        return a.sd < b.sd
    end

    local models = getDummyModels()
    diag.dummies = #models
    for _, m in ipairs(models) do
        if state.dummyDetached[m] then continue end
        if not isAliveDummy(m) then continue end
        diag.alive += 1

        -- 寻找 FOV 内最近的部位
        local fovPart, fovScreenDist = nil, math.huge
        for _, part in ipairs(m:GetDescendants()) do
            if not part:IsA("BasePart") then continue end
            if part.Name == "Handle" then continue end
            local pos, on = cam:WorldToViewportPoint(part.Position)
            if on and pos.Z > 0 then
                local sd = (Vector2.new(pos.X, pos.Y) - center).Magnitude
                if sd <= fov and sd < fovScreenDist then
                    fovPart = part
                    fovScreenDist = sd
                end
            end
        end
        if not fovPart then diag.noPart += 1 continue end
        diag.inFov += 1

        local aimTarget = getDummyAimPart(m) or fovPart
        -- 假人可见性检测（简化：总是可见）
        local visible = true
        if visible or wallAim then
            local wd = myRoot and (aimTarget.Position - myRoot.Position).Magnitude
                or (aimTarget.Position - cam.CFrame.Position).Magnitude
            if wd <= state.dummyMaxDistance then
                diag.inRange += 1
                local cand = { m = m, p = aimTarget, sd = fovScreenDist, wd = wd, visible = visible }
                if better(cand, best) then
                    best = cand
                end
            end
        end
    end
    return best and best.m or nil, best and best.p or nil, diag
end

-- 更新假人目标标记
local function updateDummyTargetMarker(part)
    local gui = makeOverlay()
    if not part then
        safeDestroy(uiStore.dummyMarker)
        uiStore.dummyMarker = nil
        return
    end
    local cam = workspace.CurrentCamera
    if not cam then return end
    local pos, visible = cam:WorldToViewportPoint(part.Position)
    if not visible then
        safeDestroy(uiStore.dummyMarker)
        uiStore.dummyMarker = nil
        return
    end
    local marker = uiStore.dummyMarker
    if not marker or not marker.Parent then
        marker = Instance.new("Frame")
        marker.Name = "ZPvpDummyMarker"
        marker.Size = UDim2.fromOffset(10, 10)
        marker.AnchorPoint = Vector2.new(0.5, 0.5)
        marker.BackgroundColor3 = Color3.fromRGB(180, 50, 255)
        marker.BorderSizePixel = 0
        marker.ZIndex = 96
        marker.Parent = gui
        Instance.new("UICorner", marker).CornerRadius = UDim.new(1, 0)
        local stroke = Instance.new("UIStroke")
        stroke.Color = Color3.fromRGB(255, 255, 255)
        stroke.Transparency = 0.08
        stroke.Thickness = 1
        stroke.Parent = marker
        uiStore.dummyMarker = marker
    end
    marker.Position = UDim2.fromOffset(pos.X, pos.Y)
end

-- 假人自动开火
local function applyDummyAutoFire()
    if not state.dummyAutoFire then return end
    local now = os.clock()
    if now - state.lastFireAt < state.fireCooldown then return end
    state.lastFireAt = now
    pcall(function()
        local v = VirtualInputManager
        v:SendMouseButtonEvent(0, 0, 0, true, game, 0)
        v:SendMouseButtonEvent(0, 0, 0, false, game, 0)
    end)
end

-- ============================================================
-- 核心自瞄函数：获取最佳目标（玩家）【带墙壁检测版】
-- ============================================================
local function getBestTarget()
    local cam = workspace.CurrentCamera
    if not cam then return nil, nil, { checked = 0, inFov = 0 } end

    local viewport = cam.ViewportSize
    local center = Vector2.new(viewport.X / 2, viewport.Y / 2)
    local myRoot = root(LocalPlayer)
    local best = nil
    local stats = { checked = 0, inFov = 0, visible = 0, blocked = 0, tooFar = 0, selectedOnly = false, detached = 0 }
    local priority = state.targetPriority

    -- 比较两个候选目标，决定谁更优
    local function better(a, b)
        if not b then return true end
        if priority == "lowestHp" then
            local aHp = a.hp or 100
            local bHp = b.hp or 100
            if aHp ~= bHp then return aHp < bHp end
        end
        if a.visible ~= b.visible then
            return a.visible
        end
        if math.abs(a.worldDist - b.worldDist) > 0.5 then
            return a.worldDist < b.worldDist
        end
        return a.screenDist < b.screenDist
    end

    -- 扫描单个实体（玩家）
    local function scanEntity(entity, playerRef, getHp, fovRadius, wallAim)
        local c = entity
        local h = c:FindFirstChildOfClass("Humanoid")
        if not h or not (state.aimDead or h.Health > 0) then return end
        if detachedTargets[playerRef] then return end

        stats.checked += 1
        local fovPart, fovScreenDist = nil, math.huge
        local fov = fovRadius or state.fovRadius

        -- 获取候选部位
        local parts = getCandidateParts({ Character = entity })
        if #parts == 0 then
            for _, desc in ipairs(c:GetDescendants()) do
                if desc:IsA("BasePart") and desc.Name ~= "Handle" then
                    table.insert(parts, desc)
                end
            end
        end

        -- 寻找 FOV 内最近的部位
        for _, part in ipairs(parts) do
            local pos, onScreen = cam:WorldToViewportPoint(part.Position)
            if onScreen and pos.Z > 0 then
                local screenDist = (Vector2.new(pos.X, pos.Y) - center).Magnitude
                if screenDist <= fov and screenDist < fovScreenDist then
                    fovPart = part
                    fovScreenDist = screenDist
                end
            end
        end

        if fovPart then
            stats.inFov += 1
            local aimTarget = getPartForModel(c) or fovPart
            -- 调用真实的可见性检测
            local visible = isCharacterVisible(playerRef)
            if visible then stats.visible += 1 else stats.blocked += 1 end

            if visible or wallAim then
                local targetRoot = c:FindFirstChild("HumanoidRootPart") or aimTarget
                local worldDist
                if myRoot and targetRoot then
                    worldDist = (targetRoot.Position - myRoot.Position).Magnitude
                else
                    worldDist = (aimTarget.Position - cam.CFrame.Position).Magnitude
                end
                if worldDist <= state.maxDistance then
                    local candidate = {
                        player = playerRef,
                        part = aimTarget,
                        screenDist = fovScreenDist,
                        worldDist = worldDist,
                        visible = visible,
                        hp = h.Health,
                    }
                    if better(candidate, best) then
                        best = candidate
                    end
                else
                    stats.tooFar += 1
                end
            end
        end
    end

    -- 遍历所有玩家
    if state.aimDummy and not state.aimEnabled then
        -- 如果只开启假人自瞄，这里不扫描玩家（实际逻辑在别处）
    else
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer and (state.aimDead or isAlive(plr)) then
                if detachedTargets[plr] then
                    stats.detached += 1
                    continue
                end
                if state.onlySelected and state.selected and plr ~= state.selected then
                    continue
                elseif state.onlySelected and not state.selected then
                    stats.selectedOnly = true
                    continue
                end
                if state.onlySelected or (not state.enemyOnly) or isEnemy(plr) then
                    scanEntity(char(plr), plr, true, state.fovRadius, state.wallAim)
                end
            end
        end
    end

    if best then
        return best.player, best.part, best
    end
    return nil, nil, stats
end

-- ============================================================
-- 其他功能实现：观战、无后坐力、无扩散、雷达、子弹追踪、FOV/移速修改、大头、连跳、静默自瞄等
-- ============================================================
local function spectateSelected()
    local h = hum(state.selected)
    if h then
        workspace.CurrentCamera.CameraSubject = h
    end
end

local function stopSpectate()
    local h = hum(LocalPlayer)
    if h then
        workspace.CurrentCamera.CameraSubject = h
    end
end

local function requestAutoFire()
    if not state.autoTestFire then return end
    local now = os.clock()
    if now - state.lastFireAt < state.fireCooldown then return end
    state.lastFireAt = now

    pcall(function()
        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0)
    end)
end

-- 无后坐力和无扩散：遍历当前工具，将相关数值强制设为 0
local function applyNoRecoilSpread()
    if not state.noRecoil and not state.noSpread then
        lastRecoilTool = nil
        table.clear(recoilCache)
        return
    end
    local c = LocalPlayer.Character
    if not c then return end
    local tool = c:FindFirstChildOfClass("Tool")
    if not tool then
        lastRecoilTool = nil
        table.clear(recoilCache)
        return
    end
    if tool ~= lastRecoilTool then
        lastRecoilTool = tool
        table.clear(recoilCache)
        -- 在工具内搜索与后坐力/散布相关的数值/字符串/CFrame/向量
        for _, child in ipairs(tool:GetDescendants()) do
            local lower = child.Name:lower()
            if child:IsA("NumberValue") or child:IsA("IntValue") then
                if state.noSpread and (lower:find("spread") or lower:find("inaccuracy") or lower:find("random") or lower:find("deviation") or lower:find("scatter")) then
                    table.insert(recoilCache, { child, "num" })
                end
                if state.noRecoil and (lower:find("recoil") or lower:find("kick") or lower:find("sway") or lower:find("bounce")) then
                    table.insert(recoilCache, { child, "num" })
                end
            elseif state.noRecoil and child:IsA("StringValue") and (lower:find("recoil") or lower:find("kick")) then
                table.insert(recoilCache, { child, "str" })
            elseif state.noRecoil and child:IsA("CFrameValue") and (lower:find("recoil") or lower:find("kick")) then
                table.insert(recoilCache, { child, "cframe" })
            elseif state.noRecoil and child:IsA("Vector3Value") and (lower:find("recoil") or lower:find("kick")) then
                table.insert(recoilCache, { child, "vec3" })
            end
        end
    end
    -- 应用修改
    for _, entry in ipairs(recoilCache) do
        local obj, kind = entry[1], entry[2]
        pcall(function()
            if kind == "num" then
                obj.Value = 0
            elseif kind == "str" then
                obj.Value = "0"
            elseif kind == "cframe" then
                obj.Value = CFrame.new()
            else
                obj.Value = Vector3.new()
            end
        end)
    end
end

-- 更新雷达
local function updateRadar()
    if not state.radar then
        safeDestroy(radarGui)
        radarGui = nil
        radarFrame = nil
        return
    end
    if not radarGui or not radarGui.Parent then
        radarGui = Instance.new("ScreenGui")
        radarGui.Name = "ZPvpRadar"
        radarGui.ResetOnSpawn = false
        radarGui.IgnoreGuiInset = true
        radarGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        radarGui.Parent = PlayerGui
        radarFrame = Instance.new("Frame")
        radarFrame.Name = "RadarFrame"
        radarFrame.BackgroundColor3 = Color3.fromRGB(5, 5, 10)
        radarFrame.BackgroundTransparency = 0.15
        radarFrame.BorderSizePixel = 0
        radarFrame.Parent = radarGui
        Instance.new("UICorner", radarFrame).CornerRadius = UDim.new(0, 8)
        local stroke = Instance.new("UIStroke", radarFrame)
        stroke.Color = Color3.fromRGB(50, 150, 255)
        stroke.Transparency = 0.4
        stroke.Thickness = 1.5

        local title = Instance.new("TextLabel")
        title.Name = "Title"
        title.Size = UDim2.new(1, 0, 0, 18)
        title.Position = UDim2.fromOffset(0, 2)
        title.BackgroundTransparency = 1
        title.Text = "雷达"
        title.TextColor3 = Color3.fromRGB(200, 200, 255)
        title.TextSize = 11
        title.Font = Enum.Font.GothamBold
        title.TextXAlignment = Enum.TextXAlignment.Center
        title.Parent = radarFrame

        local surface = Instance.new("Frame")
        surface.Name = "Surface"
        surface.BackgroundColor3 = Color3.fromRGB(10, 15, 30)
        surface.BackgroundTransparency = 0.3
        surface.BorderSizePixel = 0
        surface.Parent = radarFrame
        Instance.new("UICorner", surface).CornerRadius = UDim.new(1, 0)

        local center = Instance.new("Frame")
        center.Name = "Center"
        center.Size = UDim2.fromOffset(4, 4)
        center.Position = UDim2.new(0.5, -2, 0.5, -2)
        center.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        center.BorderSizePixel = 0
        center.Parent = surface
        Instance.new("UICorner", center).CornerRadius = UDim.new(1, 0)
    end

    local size = state.radarSize
    local zoom = state.radarZoom
    radarFrame.Size = UDim2.fromOffset(size, size + 20)
    radarFrame.Position = UDim2.new(1, -size - 10, 1, -size - 30)

    local surface = radarFrame:FindFirstChild("Surface")
    if surface then
        local s = size - 12
        surface.Size = UDim2.fromOffset(s, s)
        surface.Position = UDim2.fromOffset(6, 22)

        local myRoot = root(LocalPlayer)
        if not myRoot then return end
        local cam = workspace.CurrentCamera
        local lookVector = cam and cam.CFrame.LookVector or Vector3.new(0, 0, -1)
        local lookAngle = math.atan2(-lookVector.X, -lookVector.Z)

        -- 绘制每个玩家的点
        local dotIndex = 0
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer and isAlive(plr) then
                local targetRoot = root(plr)
                if targetRoot then
                    local relative = targetRoot.Position - myRoot.Position
                    local dist = relative.Magnitude
                    if dist <= zoom * 3 then
                        local angle = math.atan2(-relative.X, -relative.Z) - lookAngle
                        local r = math.min(dist / zoom, 1) * (s / 2 - 6)
                        local x = math.cos(angle) * r + s / 2
                        local y = math.sin(angle) * r + s / 2

                        dotIndex += 1
                        local dot = radarDots[dotIndex]
                        if not dot or not dot.Parent then
                            dot = Instance.new("Frame")
                            dot.Size = UDim2.fromOffset(5, 5)
                            dot.BackgroundColor3 = Color3.fromRGB(255, 45, 72)
                            dot.BorderSizePixel = 0
                            dot.Parent = surface
                            Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0)
                            radarDots[dotIndex] = dot
                        else
                            dot.Visible = true
                        end
                        dot.Position = UDim2.fromOffset(x - 2.5, y - 2.5)
                        dot.BackgroundColor3 = isEnemy(plr) and Color3.fromRGB(255, 45, 72) or Color3.fromRGB(100, 200, 100)
                    end
                end
            end
        end
        -- 清理多余的点
        for i = dotIndex + 1, #radarDots do
            safeDestroy(radarDots[i])
        end
        for i = #radarDots, dotIndex + 1, -1 do
            table.remove(radarDots)
        end
    end
end

-- 子弹追踪：检测新生成的子弹零件并画线
local function updateBulletTracking(deltaTime)
    if not state.bulletTracer then
        table.clear(bulletTrack)
        for _, line in ipairs(tracerLines) do
            pcall(function() line:Remove() end)
        end
        table.clear(tracerLines)
        return
    end

    for part in pairs(bulletTrack) do
        if not part or not part.Parent then
            bulletTrack[part] = nil
        end
    end

    local cam = workspace.CurrentCamera
    local origin = cam and cam.CFrame.Position or Vector3.new(0, 0, 0)

    for part, isNew in pairs(bulletTrack) do
        if isNew and part.Parent then
            local ok, line = pcall(Drawing.new, "Line")
            if ok and line then
                line.From = part.Position
                line.To = part.Position + (part.Position - origin).Unit * 6
                line.Color = Color3.fromRGB(0, 255, 255)
                line.Thickness = state.tracerThickness or 1.5
                line.Transparency = 0.25
                line.Visible = true
                table.insert(tracerLines, line)
            end
            bulletTrack[part] = false
        end
    end

    -- 清理不显示的线
    for i = #tracerLines, 1, -1 do
        if not tracerLines[i].Visible then
            pcall(function() tracerLines[i]:Remove() end)
            table.remove(tracerLines, i)
        end
    end
end

-- 判断零件是否为子弹（根据名称关键词）
local function isBulletPartName(name)
    local keywords = { "Bullet", "Projectile", "Hitbox", "Pellet", "Round", "Shot", "Ray", "Beam", "Trail", "弹道", "子弹", "Fire", "Shell", "Bolt", "Arrow", "Rocket", "Laser", "Tracer" }
    for _, kw in ipairs(keywords) do
        if name:find(kw, 1, true) then return true end
    end
    return false
end

-- 应用 FOV 修改（子弹时间或自定义 FOV）
local function applyFovAdjust()
    local cam = workspace.CurrentCamera
    if not cam then return end
    if state.bulletTime and bulletTimeHeld then
        cam.FieldOfView = state.bulletTimeFov or 20
    elseif state.fovEnabled then
        cam.FieldOfView = state.customFov or 70
    else
        cam.FieldOfView = state.originalFov or 70
    end
end

-- 应用移速修改
local function applyWalkAdjust()
    local h = hum(LocalPlayer)
    if not h then return end
    local target
    if state.bulletTime and bulletTimeHeld then
        target = state.bulletTimeWalk or 8
    elseif state.walkSpeedEnabled then
        target = state.walkSpeed or 16
    else
        target = state.originalWalk or 16
    end
    if target ~= lastAppliedWalkSpeed then
        lastAppliedWalkSpeed = target
        h.WalkSpeed = target
    end
end

-- 大头功能：已拆分为三个独立选项
local function applyBigHead()
    if not (state.bigHeadAll or state.bigHeadEnemy or state.bigHeadFriend) then
        -- 全部关闭，恢复所有头部
        for head, entry in pairs(headSizes) do
            pcall(function() head.Size = entry.orig end)
        end
        table.clear(headSizes)
        return
    end

    local function shouldScalePlayer(plr)
        if state.bigHeadAll then return true end
        local enemy = isEnemy(plr)
        if enemy and state.bigHeadEnemy then return true end
        if not enemy and state.bigHeadFriend then return true end
        return false
    end

    local function scaleHead(mdl, shouldScale)
        if not mdl then return end
        local head = mdl:FindFirstChild("Head")
        if not head then
            for _, d in ipairs(mdl:GetDescendants()) do
                if d:IsA("BasePart") and d.Name == "Head" then
                    head = d
                    break
                end
            end
        end
        if not head then return end
        local entry = headSizes[head]
        if not entry then
            entry = { orig = head.Size, last = head.Size }
            headSizes[head] = entry
        end
        if shouldScale then
            local target = entry.orig * state.bigHeadScale
            if (target - entry.last).Magnitude > 0.001 then
                entry.last = target
                pcall(function() head.Size = target end)
            end
        else
            if (entry.orig - entry.last).Magnitude > 0.001 then
                entry.last = entry.orig
                pcall(function() head.Size = entry.orig end)
            end
        end
    end

    -- 处理玩家
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr == LocalPlayer then continue end
        local c = char(plr)
        if c then
            scaleHead(c, shouldScalePlayer(plr))
        end
    end

    -- 假人：仅在“全部大头”时生效
    for _, mdl in ipairs(getDummyModels()) do
        scaleHead(mdl, state.bigHeadAll)
    end
end

-- 自动连跳
local function applyAutoBhop()
    if not state.autoBhop then return end
    local h = hum(LocalPlayer)
    if not h then return end
    if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
        pcall(function()
            h:ChangeState(Enum.HumanoidStateType.Jumping)
        end)
    end
end

-- ============================================================
-- 静默自瞄（通过 Hook 武器发射函数，修改子弹方向）
-- ============================================================
local silentAimHooked = false
local silentCast = nil

local function getSilentAimTarget()
    local cam = workspace.CurrentCamera
    if not cam then return nil end
    local vp = cam.ViewportSize
    local center = Vector2.new(vp.X / 2, vp.Y / 2)
    local myRoot = root(LocalPlayer)
    local best = nil

    local function consider(part, enemy)
        if not part then return end
        local pos, on = cam:WorldToViewportPoint(part.Position)
        if not on or pos.Z <= 0 then return end
        local sd = (Vector2.new(pos.X, pos.Y) - center).Magnitude
        local wd = myRoot and (part.Position - myRoot.Position).Magnitude or math.huge
        local visible = true
        local cand = { part = part, sd = sd, wd = wd, visible = visible, enemy = enemy }
        if not best then
            best = cand
            return
        end
        if cand.wd < best.wd - 0.5 then
            best = cand
        elseif math.abs(cand.wd - best.wd) <= 0.5 then
            if cand.sd < best.sd - 0.5 then
                best = cand
            elseif math.abs(cand.sd - best.sd) <= 0.5 and cand.visible and not best.visible then
                best = cand
            end
        end
    end

    for _, plr in ipairs(Players:GetPlayers()) do
        if plr == LocalPlayer then continue end
        local c = char(plr)
        local h = c and c:FindFirstChildOfClass("Humanoid")
        if not c or not h or h.Health <= 0 then continue end
        if state.enemyOnly and not isEnemy(plr) then continue end
        consider(c:FindFirstChild("Head") or c:FindFirstChild("HumanoidRootPart"), true)
    end

    return best and best.part or nil
end

-- 安装静默自瞄 Hook（仅当武器管理器存在且可 require）
local function setupSilentAim()
    if silentAimHooked then return end
    local rs = game:GetService("ReplicatedStorage")
    local common = rs:FindFirstChild("Common")
    local managers = common and common:FindFirstChild("Managers")
    local weaponManager = managers and managers:FindFirstChild("WeaponManager")
    if not weaponManager then return end
    local ok, mgr = pcall(require, weaponManager)
    if not ok or type(mgr) ~= "table" or type(mgr.cast) ~= "function" then
        return
    end
    silentAimHooked = true
    silentCast = mgr.cast
    mgr.cast = function(origin, direction, speed, maxDist, ...)
        if state.silentAim then
            local target = getSilentAimTarget()
            if target then
                local ok2, newDir = pcall(function()
                    return (target.Position - origin).Unit
                end)
                if ok2 and newDir then
                    direction = newDir
                end
            end
        end
        return silentCast(origin, direction, speed, maxDist, ...)
    end
end

-- ============================================================
-- HUD 更新（屏幕左上角显示当前开启的功能）
-- ============================================================
local function updateHud()
    if not state.showHud then
        for _, lbl in ipairs(hudLabels) do
            safeDestroy(lbl)
        end
        table.clear(hudLabels)
        return
    end

    local gui = makeOverlay()
    for i = #hudLabels, 1, -1 do
        if not hudLabels[i].Parent then
            table.remove(hudLabels, i)
        end
    end

    local active = {}
    local add = function(text, on)
        if on then table.insert(active, text) end
    end
    add("吸附", state.aimEnabled or state.spinScan)
    add("自动开火", state.autoTestFire)
    add("穿墙", state.wallBang)
    add("子弹追踪", state.bulletTracer)
    add("移速", state.walkSpeedEnabled)
    add("视野", state.fovEnabled)
    add("大头", state.bigHeadAll or state.bigHeadEnemy or state.bigHeadFriend)
    add("连跳", state.autoBhop)
    add("雷达", state.radar)
    add("子弹时间", state.bulletTime)

    local need = #active
    while #hudLabels < need do
        local lbl = Instance.new("TextLabel")
        lbl.Name = "ZPvpHud"
        lbl.BackgroundTransparency = 1
        lbl.TextColor3 = Color3.fromRGB(120, 255, 120)
        lbl.TextSize = 13
        lbl.Font = Enum.Font.GothamBold
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.Size = UDim2.fromOffset(180, 18)
        lbl.Parent = gui
        table.insert(hudLabels, lbl)
    end
    for i = #hudLabels, need + 1, -1 do
        safeDestroy(hudLabels[i])
        table.remove(hudLabels, i)
    end
    for i, text in ipairs(active) do
        local lbl = hudLabels[i]
        if lbl then
            lbl.Text = text
            lbl.Position = UDim2.fromOffset(8, 8 + (i - 1) * 19)
            lbl.Visible = true
        end
    end
end

-- 假人 ESP（高亮）
local function updateDummyEsp()
    if not state.dummyEsp then
        for mdl, hi in pairs(dummyEspStore) do
            safeDestroy(hi)
        end
        table.clear(dummyEspStore)
        return
    end
    for _, mdl in ipairs(getDummyModels()) do
        local h = mdl:FindFirstChildOfClass("Humanoid")
        if not h or h.Health <= 0 then
            if dummyEspStore[mdl] then safeDestroy(dummyEspStore[mdl]) dummyEspStore[mdl] = nil end
            continue
        end
        if not dummyEspStore[mdl] or dummyEspStore[mdl].Parent ~= mdl then
            local hi = Instance.new("Highlight")
            hi.Name = "ZPvpDummyHighlight"
            hi.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
            hi.FillTransparency = 0.4
            hi.OutlineTransparency = 0
            hi.FillColor = Color3.fromRGB(255, 140, 0)
            hi.OutlineColor = Color3.fromRGB(255, 220, 150)
            hi.Parent = mdl
            dummyEspStore[mdl] = hi
        end
    end
end

-- ============================================================
-- 自定义准星（使用 Frame 绘制）
-- ============================================================
local function updateCrosshair()
    if not state.crosshair.enabled then
        for _, el in ipairs(crosshairElements) do
            safeDestroy(el)
        end
        table.clear(crosshairElements)
        return
    end

    local gui = makeOverlay()
    local cam = workspace.CurrentCamera
    if not cam then return end
    local vp = cam.ViewportSize
    local cx, cy = vp.X / 2, vp.Y / 2
    local ch = state.crosshair

    -- 动态扩散恢复
    if ch.dynamicSpread and ch.spreadCurrent > 0 then
        ch.spreadCurrent = math.max(0, ch.spreadCurrent - (ch.spreadRecovery or 0.15))
    end

    local totalGap = (ch.gap or 4) + ch.spreadCurrent
    local size = ch.size or 10
    local thick = ch.thickness or 2
    local color = crosshairColors[ch.colorIndex] and crosshairColors[ch.colorIndex].value or Color3.fromRGB(0, 255, 0)
    local alpha = 1 - (ch.transparency or 0)
    local shape = ch.shape or "cross"

    -- 辅助函数：创建或更新一个准星部件
    local function ensureFrame(idx, name, props)
        local el = crosshairElements[idx]
        if not el or not el.Parent then
            safeDestroy(el)
            el = Instance.new("Frame")
            el.Name = "ZCh" .. name
            el.BackgroundColor3 = color
            el.BorderSizePixel = 0
            el.ZIndex = 100
            el.Parent = gui
            crosshairElements[idx] = el
        end
        el.BackgroundColor3 = color
        el.BackgroundTransparency = 1 - alpha
        for k, v in pairs(props) do
            el[k] = v
        end
        if ch.outline then
            local stroke = el:FindFirstChild("ChStroke")
            if not stroke then
                stroke = Instance.new("UIStroke")
                stroke.Name = "ChStroke"
                stroke.Parent = el
            end
            stroke.Color = Color3.fromRGB(0, 0, 0)
            stroke.Thickness = ch.outlineThickness or 1
            stroke.Transparency = 1 - alpha
        else
            local stroke = el:FindFirstChild("ChStroke")
            if stroke then safeDestroy(stroke) end
        end
        return el
    end

    local idx = 1

    if shape == "cross" then
        ensureFrame(idx, "Top", { Size = UDim2.fromOffset(thick, size), Position = UDim2.fromOffset(cx - thick / 2, cy - totalGap - size) }); idx += 1
        ensureFrame(idx, "Bot", { Size = UDim2.fromOffset(thick, size), Position = UDim2.fromOffset(cx - thick / 2, cy + totalGap) }); idx += 1
        ensureFrame(idx, "Left", { Size = UDim2.fromOffset(size, thick), Position = UDim2.fromOffset(cx - totalGap - size, cy - thick / 2) }); idx += 1
        ensureFrame(idx, "Right", { Size = UDim2.fromOffset(size, thick), Position = UDim2.fromOffset(cx + totalGap, cy - thick / 2) }); idx += 1
    end

    if ch.centerDot then
        local ds = (ch.centerDotRadius or 2) * 2
        ensureFrame(idx, "Dot", { Size = UDim2.fromOffset(ds, ds), Position = UDim2.fromOffset(cx - ds / 2, cy - ds / 2) }); idx += 1
        local el = crosshairElements[idx - 1]
        if el then
            local corner = el:FindFirstChildOfClass("UICorner")
            if not corner then
                corner = Instance.new("UICorner")
                corner.CornerRadius = UDim.new(1, 0)
                corner.Parent = el
            end
        end
    end

    -- 清理多余的部件
    for i = idx, #crosshairElements do
        safeDestroy(crosshairElements[i])
    end
    for i = #crosshairElements, idx, -1 do
        table.remove(crosshairElements)
    end
end

-- ============================================================
-- 构建 Fluent-modded 用户界面（悬浮球 + 设置面板）
-- ============================================================
local fluentLibUrl = "https://github.com/StyearX/Fluent-Modded/releases/download/Fluent/FluentPro"

local function buildFluentModdedUI()
    -- 下载 UI 库
    local src = nil
    for i = 1, 2 do
        local okFetch, res = pcall(function()
            return game:HttpGet(fluentLibUrl)
        end)
        if okFetch and type(res) == "string" then
            src = res
            break
        end
    end
    if type(src) ~= "string" then
        warn("[Nexus Pro] UI 库拉取失败，面板未加载")
        return
    end
    local okLoad, loaded = pcall(function()
        return loadstring(src)()
    end)
    if not okLoad or loaded == nil then
        warn("[Nexus Pro] UI 库解析失败，面板未加载")
        return
    end
    local Fluent = loaded
    uiRefs.Fluent = Fluent

    -- 创建主窗口（已关闭 Acrylic 模糊）
  local Window = Fluent:CreateWindow({
    Title = "【TY脚本】    权威制作",
    SubTitle = "QQ：3935754168",
    TabWidth = 150,
    Size = UDim2.fromOffset(700, 600),
    Acrylic = false,
    Theme = "0",
    Search = true,
    MinimizeKey = Enum.KeyCode.RightShift,
    -- 强制关闭透明，强制纯色背景
    ForceSolidBackground = true,
})


    uiRefs.Window = Window

    -- 标签页
    local Tabs = {
        Combat = Window:AddTab({ Title = "自瞄", Icon = "solar/target-bold" }),
        Render = Window:AddTab({ Title = "透视ESP", Icon = "solar/eye-bold" }),
        Players = Window:AddTab({ Title = "玩家", Icon = "solar/users-group-rounded-bold" }),
        Extras = Window:AddTab({ Title = "扩展", Icon = "solar/bolt-bold" }),
        Settings = Window:AddTab({ Title = "设置", Icon = "solar/settings-bold" }),
    }

    -- 状态段落（用于显示当前锁定信息）
    uiRefs.statusParagraph = Tabs.Combat:AddParagraph({
        Title = "状态【开自瞄没反应把只瞄敌人关闭即可】",
        Content = "等待开启自动瞄准",
    })

    -- 战斗标签页 - 瞄准部分
    local aimSec = Tabs.Combat:AddCollapsibleSection({ Title = "瞄准", Icon = "solar/target-bold", Open = true })
    aimSec:AddToggle("ZAimEnabled", {
        Title = "开启 自动瞄准",
        Description = "只锁定 FOV 圈内最近目标",
        Default = state.aimEnabled,
        Callback = function(v)
            state.aimEnabled = v
            -- 联动：开启自瞄时自动显示 FOV 圈
            state.showFov = v
            pcall(function()
                local fovToggle = aimSec:GetToggle("ZShowFov")
                if fovToggle and type(fovToggle.SetValue) == "function" then
                    fovToggle:SetValue(v)
                end
            end)
        end,
    })
    aimSec:AddToggle("ZWallAim", {
        Title = "穿墙也允许自瞄",
        Default = state.wallAim,
        Callback = function(v) state.wallAim = v end,
    })
    aimSec:AddToggle("ZAimDead", {
        Title = "死亡目标也允许吸附",
        Default = state.aimDead,
        Callback = function(v) state.aimDead = v end,
    })
    aimSec:AddToggle("ZOnlySelected", {
        Title = "只吸附所选玩家",
        Default = state.onlySelected,
        Callback = function(v) state.onlySelected = v end,
    })
    aimSec:AddToggle("ZEnemyOnly", {
        Title = "只锁敌人",
        Default = state.enemyOnly,
        Callback = function(v) state.enemyOnly = v end,
    })
    aimSec:AddSlider("ZFovRadius", {
        Title = "FOV 半径",
        Description = "目标进入屏幕中心圆圈后才会被吸附",
        Min = 50, Max = 460, Default = state.fovRadius, Rounding = 0,
        Callback = function(v) state.fovRadius = v end,
    })
    aimSec:AddSlider("ZMaxDistance", {
        Title = "最大吸附距离", Min = 20, Max = 2000, Default = state.maxDistance, Rounding = 0,
        Callback = function(v) state.maxDistance = v end,
    })
    aimSec:AddSlider("ZSmooth", {
        Title = "平滑度", Description = "越小越稳，越大越快",
        Min = 3, Max = 75, Default = math.floor(state.smooth * 100), Rounding = 0,
        Callback = function(v) state.smooth = math.clamp(v / 100, 0.03, 0.75) end,
    })
    aimSec:AddDropdown("ZAimPart", {
        Title = "吸附部位", Values = aimParts, Multi = false, Default = state.aimPart,
        Callback = function(v)
            if type(v) == "table" then v = v[1] end
            state.aimPart = v or state.aimPart
        end,
    })

    -- 战斗标签页 - 开火部分
    local fireSec = Tabs.Combat:AddCollapsibleSection({ Title = "开火", Icon = "solar/flame-bold", Open = true })
    fireSec:AddToggle("ZAutoTestFire", {
        Title = "吸附后自动开火", Description = "模拟鼠标左键点击，直接触发武器开火",
        Default = state.autoTestFire,
        Callback = function(v) state.autoTestFire = v end,
    })
    fireSec:AddToggle("ZSpinScan", {
        Title = "旋转扫描吸附", Description = "打开后自动转视角搜索 FOV 内目标",
        Default = state.spinScan,
        Callback = function(v)
            state.spinScan = v
            if v then state.aimEnabled = true end
        end,
    })
    fireSec:AddToggle("ZWallBang", {
        Title = "穿墙子弹", Description = "子弹无视墙壁，直接穿透障碍物造成伤害",
        Default = state.wallBang,
        Callback = function(v) state.wallBang = v end,
    })
    fireSec:AddToggle("ZNoRecoil", {
        Title = "无后坐力", Description = "消除武器后坐力",
        Default = state.noRecoil,
        Callback = function(v) state.noRecoil = v end,
    })
    fireSec:AddToggle("ZNoSpread", {
        Title = "无扩散", Description = "消除武器子弹散布",
        Default = state.noSpread,
        Callback = function(v) state.noSpread = v end,
    })
    fireSec:AddToggle("ZBulletTracer", {
        Title = "子弹追踪", Description = "显示子弹弹道轨迹线",
        Default = state.bulletTracer,
        Callback = function(v) state.bulletTracer = v end,
    })
    fireSec:AddSlider("ZSpinSpeed", {
        Title = "旋转扫描速度", Min = 20, Max = 240, Default = state.spinSpeed, Rounding = 0,
        Callback = function(v) state.spinSpeed = v end,
    })
    fireSec:AddSlider("ZFireCooldown", {
        Title = "自动开火间隔", Description = "单位毫秒",
        Min = 80, Max = 1000, Default = math.floor(state.fireCooldown * 1000), Rounding = 0,
        Callback = function(v) state.fireCooldown = math.clamp(v / 1000, 0.08, 1) end,
    })
    fireSec:AddToggle("ZDetachDeath", {
        Title = "命中死亡后自动脱离",
        Default = state.detachOnDeath,
        Callback = function(v) state.detachOnDeath = v end,
    })

    -- 绘制标签页
    Tabs.Render:AddParagraph({
        Title = "绘制说明",
        Content = "敌人红色，队友白色。身份牌关闭后会强制清理所有旧 BillboardGui。",
    })

    local espSec = Tabs.Render:AddCollapsibleSection({ Title = "玩家绘制", Icon = "solar/eye-bold", Open = true })
    espSec:AddToggle("ZEnemyEsp", {
        Title = "敌人 ESP", Default = state.enemyEsp,
        Callback = function(v) state.enemyEsp = v end,
    })
    espSec:AddToggle("ZFriendEsp", {
        Title = "队友 ESP",
        Default = state.friendEsp,
        Callback = function(v)
            state.friendEsp = v
            if v and not state.teamCheck then
                state.teamCheck = true
                pcall(function()
                    local tcToggle = espSec:GetToggle("ZTeamCheck")
                    if tcToggle and type(tcToggle.SetValue) == "function" then
                        tcToggle:SetValue(true)
                    end
                end)
                pcall(function()
                    Fluent:Notify({
                        Title = "Nexus Pro",
                        Content = "队友ESP已开启，自动启用阵营检测",
                        Duration = 2
                    })
                end)
            end
        end,
    })
    espSec:AddToggle("ZTeamCheck", {
        Title = "启用阵营检测",
        Description = "检查 Team、TeamColor 和常见阵营 Attribute",
        Default = state.teamCheck,
        Callback = function(v)
            state.teamCheck = v
            if not v and state.friendEsp then
                state.friendEsp = false
                pcall(function()
                    local feToggle = espSec:GetToggle("ZFriendEsp")
                    if feToggle and type(feToggle.SetValue) == "function" then
                        feToggle:SetValue(false)
                    end
                end)
                pcall(function()
                    Fluent:Notify({
                        Title = "Nexus Pro",
                        Content = "关闭阵营检测后无法区分敌友，已自动关闭队友ESP",
                        Duration = 3
                    })
                end)
            end
        end,
    })
    espSec:AddToggle("ZUnknownAsEnemy", {
        Title = "未知阵营算敌人", Description = "没有 Team/Attribute 时按敌人处理",
        Default = state.unknownAsEnemy,
        Callback = function(v) state.unknownAsEnemy = v end,
    })
    espSec:AddToggle("ZNameTags", {
        Title = "身份牌", Description = "关闭会立刻删除旧身份牌",
        Default = state.nameTags,
        Callback = function(v)
            state.nameTags = v
            if not v then
                for _, plr in ipairs(Players:GetPlayers()) do
                    if plr ~= LocalPlayer then destroyPlayerTags(plr) end
                end
                table.clear(lastHpCache)
            end
        end,
    })

    local uiSec = Tabs.Render:AddCollapsibleSection({ Title = "界面", Icon = "solar/display-bold", Open = false })
    uiSec:AddToggle("ZShowFov", {
        Title = "显示 FOV 圆圈",
        Default = state.showFov,
        Callback = function(v) state.showFov = v end,
    })
    uiSec:AddToggle("ZTargetMarker", {
        Title = "显示目标点", Default = state.targetMarker,
        Callback = function(v) state.targetMarker = v end,
    })
    uiSec:AddButton({
        Title = "清理全部绘制",
        Description = "清理 Highlight、身份牌、FOV 圆圈和目标点",
        Callback = clearVisuals,
    })
    uiSec:AddToggle("ZRadar", {
        Title = "雷达", Description = "屏幕角落显示敌我位置小地图",
        Default = state.radar,
        Callback = function(v) state.radar = v end,
    })
    uiSec:AddSlider("ZRadarSize", {
        Title = "雷达大小", Min = 100, Max = 260, Default = state.radarSize, Rounding = 0,
        Callback = function(v) state.radarSize = v end,
    })
    uiSec:AddSlider("ZRadarZoom", {
        Title = "雷达范围", Description = "单位：格",
        Min = 20, Max = 150, Default = state.radarZoom, Rounding = 0,
        Callback = function(v) state.radarZoom = v end,
    })

    -- 准星设置
    local chSec = Tabs.Render:AddCollapsibleSection({ Title = "准星", Icon = "solar/target-bold", Open = false })
    chSec:AddToggle("ZChEnabled", {
        Title = "启用自定义准星", Description = "替换游戏默认准星",
        Default = state.crosshair.enabled,
        Callback = function(v) state.crosshair.enabled = v end,
    })
    chSec:AddDropdown("ZChShape", {
        Title = "准星形状", Values = { "cross", "dot" }, Multi = false, Default = state.crosshair.shape,
        Callback = function(v)
            if type(v) == "table" then v = v[1] end
            state.crosshair.shape = v or "cross"
        end,
    })
    chSec:AddSlider("ZChSize", {
        Title = "准星大小", Min = 4, Max = 30, Default = state.crosshair.size, Rounding = 0,
        Callback = function(v) state.crosshair.size = v end,
    })
    chSec:AddSlider("ZChGap", {
        Title = "中心间隙", Min = 0, Max = 20, Default = state.crosshair.gap, Rounding = 0,
        Callback = function(v) state.crosshair.gap = v end,
    })
    chSec:AddSlider("ZChThick", {
        Title = "准星粗细", Min = 1, Max = 6, Default = state.crosshair.thickness, Rounding = 0,
        Callback = function(v) state.crosshair.thickness = v end,
    })
    chSec:AddDropdown("ZChColor", {
        Title = "准星颜色", Values = crosshairColorNames, Multi = false, Default = crosshairColorNames[state.crosshair.colorIndex] or crosshairColorNames[1],
        Callback = function(v)
            if type(v) == "table" then v = v[1] end
            for i, c in ipairs(crosshairColors) do
                if c.name == v then state.crosshair.colorIndex = i break end
            end
        end,
    })
    chSec:AddSlider("ZChAlpha", {
        Title = "透明度", Min = 0, Max = 100, Default = 0, Rounding = 0, Suffix = "%",
        Callback = function(v) state.crosshair.transparency = v / 100 end,
    })
    chSec:AddToggle("ZChDot", {
        Title = "中心点", Default = state.crosshair.centerDot,
        Callback = function(v) state.crosshair.centerDot = v end,
    })
    chSec:AddSlider("ZChDotSize", {
        Title = "中心点大小", Min = 1, Max = 8, Default = state.crosshair.centerDotRadius, Rounding = 0,
        Callback = function(v) state.crosshair.centerDotRadius = v end,
    })
    chSec:AddToggle("ZChOutline", {
        Title = "黑色描边", Default = state.crosshair.outline,
        Callback = function(v) state.crosshair.outline = v end,
    })
    chSec:AddSlider("ZChOutlineThick", {
        Title = "描边粗细", Min = 1, Max = 3, Default = state.crosshair.outlineThickness, Rounding = 0,
        Callback = function(v) state.crosshair.outlineThickness = v end,
    })
    chSec:AddToggle("ZChSpread", {
        Title = "动态扩散", Description = "开枪时准星向外扩散",
        Default = state.crosshair.dynamicSpread,
        Callback = function(v) state.crosshair.dynamicSpread = v end,
    })
    chSec:AddSlider("ZChSpreadAmt", {
        Title = "扩散幅度", Min = 2, Max = 30, Default = state.crosshair.spreadAmount, Rounding = 0,
        Callback = function(v) state.crosshair.spreadAmount = v end,
    })

    -- 扩展标签页
    local charSec = Tabs.Extras:AddCollapsibleSection({ Title = "角色修改", Icon = "solar/body-bold", Open = true })
    charSec:AddToggle("ZBigHeadEnemy", {
        Title = "敌人大头", Description = "放大敌人头部",
        Default = state.bigHeadEnemy,
        Callback = function(v) state.bigHeadEnemy = v end,
    })
    charSec:AddToggle("ZBigHeadFriend", {
        Title = "队友大头", Description = "放大队友头部",
        Default = state.bigHeadFriend,
        Callback = function(v) state.bigHeadFriend = v end,
    })
    charSec:AddToggle("ZBigHeadAll", {
        Title = "全部大头", Description = "放大所有玩家和假人头部",
        Default = state.bigHeadAll,
        Callback = function(v) state.bigHeadAll = v end,
    })
    charSec:AddSlider("ZBigHeadScale", {
        Title = "大头倍数", Min = 1.1, Max = 50, Default = state.bigHeadScale, Rounding = 1,
        Callback = function(v) state.bigHeadScale = v end,
    })
    charSec:AddToggle("ZWalkSpeedEnabled", {
        Title = "移速修改", Description = "自定义移动速度",
        Default = state.walkSpeedEnabled,
        Callback = function(v) state.walkSpeedEnabled = v end,
    })
    charSec:AddSlider("ZWalkSpeed", {
        Title = "移动速度", Min = 8, Max = 500, Default = state.walkSpeed, Rounding = 0,
        Callback = function(v) state.walkSpeed = v end,
    })
    charSec:AddToggle("ZSilentAim", {
        Title = "静默自瞄", Description = "子弹自动拐向最近敌人(可见>准星近>距离近)",
        Default = state.silentAim,
        Callback = function(v)
            state.silentAim = v
            pcall(setupSilentAim)
        end,
    })

    local moveSec = Tabs.Extras:AddCollapsibleSection({ Title = "移动", Icon = "solar/running-bold", Open = false })
    moveSec:AddToggle("ZAutoBhop", {
        Title = "自动连跳", Description = "按住空格连续跳跃",
        Default = state.autoBhop,
        Callback = function(v) state.autoBhop = v end,
    })

    local dummySec = Tabs.Extras:AddCollapsibleSection({ Title = "假人自瞄", Icon = "solar/robot-bold", Open = false })
    dummySec:AddToggle("ZDummyAim", {
        Title = "开启假人自瞄", Description = "锁定场景中的假人/NPC",
        Default = state.dummyAim,
        Callback = function(v) state.dummyAim = v end,
    })
    dummySec:AddToggle("ZDummyWallAim", {
        Title = "穿墙也允许吸附", Description = "假人被墙挡住也能吸附",
        Default = state.dummyWallAim,
        Callback = function(v) state.dummyWallAim = v end,
    })
    dummySec:AddToggle("ZDummyAutoFire", {
        Title = "自动开火",
        Default = state.dummyAutoFire,
        Callback = function(v) state.dummyAutoFire = v end,
    })
    dummySec:AddSlider("ZDummyFovRadius", {
        Title = "假人FOV半径", Min = 50, Max = 460, Default = state.dummyFovRadius, Rounding = 0,
        Callback = function(v) state.dummyFovRadius = v end,
    })
    dummySec:AddSlider("ZDummyMaxDistance", {
        Title = "假人最大距离", Min = 50, Max = 2000, Default = state.dummyMaxDistance, Rounding = 0,
        Callback = function(v) state.dummyMaxDistance = v end,
    })
    dummySec:AddSlider("ZDummySmooth", {
        Title = "假人平滑度", Min = 3, Max = 75, Default = math.floor(state.dummySmooth * 100), Rounding = 0,
        Callback = function(v) state.dummySmooth = math.clamp(v / 100, 0.03, 0.75) end,
    })
    dummySec:AddDropdown("ZDummyAimPart", {
        Title = "吸附部位", Values = { "Head", "Root" }, Multi = false, Default = state.dummyAimPart,
        Callback = function(v)
            if type(v) == "table" then v = v[1] end
            state.dummyAimPart = v or state.dummyAimPart
        end,
    })
    dummySec:AddToggle("ZDummyEsp", {
        Title = "假人透视", Description = "橙色高亮显示假人位置",
        Default = state.dummyEsp,
        Callback = function(v) state.dummyEsp = v end,
    })
    dummySec:AddToggle("ZDummyShowFov", {
        Title = "显示假人FOV圈", Description = "紫色圆圈显示假人吸附范围",
        Default = state.dummyShowFov,
        Callback = function(v) state.dummyShowFov = v end,
    })

    -- 玩家标签页
    uiRefs.playersParagraph = Tabs.Players:AddParagraph({
        Title = "玩家列表",
        Content = "当前选择：无\n在线玩家：\n" .. table.concat(playerNames(), "\n"),
    })
    Tabs.Players:AddInput("ZPlayerInput", {
        Title = "输入玩家名",
        Default = "",
        Placeholder = "支持部分名字",
        Numeric = false,
        Finished = false,
        Callback = function(v)
            state.playerInput = tostring(v or "")
        end,
    })
    Tabs.Players:AddButton({
        Title = "选择输入玩家",
        Description = "支持 Name / DisplayName 模糊匹配",
        Callback = function()
            state.selected = findPlayerByName(state.playerInput)
            updatePlayerParagraph()
        end,
    })
    Tabs.Players:AddButton({
        Title = "观战所选玩家",
        Callback = spectateSelected,
    })
    Tabs.Players:AddButton({
        Title = "停止观战",
        Callback = stopSpectate,
    })
    Tabs.Players:AddButton({
        Title = "刷新玩家列表",
        Callback = updatePlayerParagraph,
    })

    -- ===== 好友白名单管理 =====
    local whitelistSec = Tabs.Players:AddCollapsibleSection({ Title = "队友白名单", Icon = "solar/users-bold", Open = false })
    whitelistSec:AddInput("ZFriendInput", {
        Title = "输入玩家名",
        Placeholder = "输入要加入白名单的玩家名",
        Numeric = false,
        Callback = function(v)
            state._friendInput = v or ""
        end,
    })
    whitelistSec:AddButton({
        Title = "加入白名单（视为队友）",
        Description = "该玩家将强制被视为队友，不受阵营检测影响",
        Callback = function()
            local name = state._friendInput or ""
            if name ~= "" then
                local plr = findPlayerByName(name)
                if plr then
                    state.friendWhitelist[plr.Name] = true
                    state.friendWhitelist[plr.DisplayName] = true
                else
                    state.friendWhitelist[name] = true
                end
                pcall(function()
                    Fluent:Notify({ Title = "Nexus Pro", Content = "已加入白名单：" .. name, Duration = 2 })
                end)
                state._friendInput = ""
            end
        end,
    })
    whitelistSec:AddButton({
        Title = "清空白名单",
        Description = "移除所有手动标记的队友",
        Callback = function()
            table.clear(state.friendWhitelist)
            pcall(function()
                Fluent:Notify({ Title = "Nexus Pro", Content = "白名单已清空", Duration = 2 })
            end)
        end,
    })

    -- 设置标签页
    Tabs.Settings:AddParagraph({
        Title = "关于",
        Content = "作者：权威\n右下角三角形可自由调节大小\n点击悬浮球打开/关闭面板\nPlaceId: " .. tostring(game.PlaceId) .. "\nJobId: " .. tostring(game.JobId),
    })
    Tabs.Settings:AddButton({
        Title = "保存配置",
        Description = "保存当前所有开关和数值，下次加载自动恢复",
        Callback = function()
            local ok, err = saveConfig()
            pcall(function()
                Fluent:Notify({ Title = "Nexus Pro", Content = ok and "配置已保存，下次加载自动恢复" or ("保存失败：" .. tostring(err)), Duration = 3 })
            end)
        end,
    })
    Tabs.Settings:AddButton({
        Title = "重置配置",
        Description = "所有功能恢复默认（全部关闭）并删除保存的配置",
        Callback = function()
            resetConfig()
            pcall(function()
                Fluent:Notify({ Title = "Nexus Pro", Content = "已重置为默认（全部关闭）", Duration = 3 })
            end)
        end,
    })
    Tabs.Settings:AddButton({
        Title = "卸载本脚本绘制",
        Description = "保存配置、停止本脚本循环并清理绘制",
        Callback = function()
            pcall(saveConfig)
            clearVisuals()
            safeDestroy(uiStore.overlay)
            uiStore.overlay = nil
            pcall(function()
                RunService:UnbindFromRenderStep("ZFluentPvpStep")
            end)
        end,
    })

    pcall(function()
        Window:SelectTab(1)
    end)
    pcall(function()
        Fluent:Notify({
            Title = "TY 双端版",
            Content = "TY 双端版已加载（权威制作）",
            Duration = 10,
        })
    end)

    uiStore.panelVisible = true

    -- 创建悬浮球（可拖动，点击切换面板显示）
    local function togglePanel()
        uiStore.panelVisible = not uiStore.panelVisible
        local visible = uiStore.panelVisible
        if visible then
            pcall(function() Window:SetMinimized(false) end)
            pcall(function()
                local f = Window.Window
                if f then
                    f.Visible = true
                    pcall(function() if f.Parent then f.Parent.Visible = true end end)
                end
            end)
        else
            pcall(function() Window:SetMinimized(true) end)
            pcall(function()
                local f = Window.Window
                if f then
                    f.Visible = false
                    pcall(function() if f.Parent then f.Parent.Visible = false end end)
                end
            end)
        end
    end

    uiStore.touchingBall = false
    uiStore.ballToggled = false
    local ball = Instance.new("ImageButton")
    ball.Name = "ZPvpFloatingBall"
    ball.Size = UDim2.fromOffset(50, 50)
    ball.Position = UDim2.new(1, -65, 0.5, -25)
    ball.BackgroundColor3 = Color3.fromRGB(30, 120, 255)
    ball.BackgroundTransparency = 0.15
    ball.BorderSizePixel = 0
    ball.ZIndex = 200
    ball.Image = "rbxassetid://3570695787"
    ball.ImageColor3 = Color3.fromRGB(255, 255, 255)
    ball.ImageTransparency = 0.3
    ball.ScaleType = Enum.ScaleType.Fit
    ball.Parent = makeOverlay()

    local ballCorner = Instance.new("UICorner")
    ballCorner.CornerRadius = UDim.new(1, 0)
    ballCorner.Parent = ball

    local ballStroke = Instance.new("UIStroke")
    ballStroke.Color = Color3.fromRGB(255, 255, 255)
    ballStroke.Transparency = 0.5
    ballStroke.Thickness = 2
    ballStroke.Parent = ball

    local ballLabel = Instance.new("TextLabel")
    ballLabel.Name = "Label"
    ballLabel.Size = UDim2.fromScale(1, 1)
    ballLabel.BackgroundTransparency = 1
    ballLabel.Text = "N"
    ballLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    ballLabel.TextSize = 22
    ballLabel.Font = Enum.Font.GothamBold
    ballLabel.TextScaled = true
    ballLabel.Parent = ball

    local ballDrag = { dragging = false, startPos = nil, startBallPos = nil, bound = nil }

    local function getDragBound()
        local parent = ball.Parent
        if parent and parent.AbsoluteSize.X > 0 and parent.AbsoluteSize.Y > 0 then
            return parent.AbsoluteSize
        end
        return nil
    end

    ball.InputBegan:Connect(function(input)
        local mouse = input.UserInputType == Enum.UserInputType.MouseButton1
        local touch = input.UserInputType == Enum.UserInputType.Touch
        if not (mouse or touch) then return end

        uiStore.touchingBall = true
        local pos = input.Position
        if pos then
            ballDrag.dragging = true
            ballDrag.startPos = Vector2.new(pos.X, pos.Y)
            ballDrag.startBallPos = ball.Position
            ballDrag.bound = getDragBound()
        end
    end)

    UserInputService.InputChanged:Connect(function(input, gp)
        if gp then return end
        if not ballDrag.dragging then return end
        local mouse = input.UserInputType == Enum.UserInputType.MouseButton1
        local touch = input.UserInputType == Enum.UserInputType.Touch
        if not (mouse or touch) then return end

        local pos = input.Position
        if not pos or not ballDrag.startPos then return end

        local delta = Vector2.new(pos.X, pos.Y) - ballDrag.startPos
        local newX = ballDrag.startBallPos.X.Offset + delta.X
        local newY = ballDrag.startBallPos.Y.Offset + delta.Y

        local bound = getDragBound() or ballDrag.bound
        if bound then
            local maxX = bound.X - 50
            local maxY = bound.Y - 50
            newX = math.clamp(newX, 0, maxX)
            newY = math.clamp(newY, 0, maxY)
        end
        ball.Position = UDim2.fromOffset(newX, newY)
    end)

    ball.InputEnded:Connect(function(input)
        local mouse = input.UserInputType == Enum.UserInputType.MouseButton1
        local touch = input.UserInputType == Enum.UserInputType.Touch
        if not (mouse or touch) then return end

        uiStore.touchingBall = false
        if ballDrag.dragging and ballDrag.startPos then
            local pos = input.Position
            if pos then
                local dist = (Vector2.new(pos.X, pos.Y) - ballDrag.startPos).Magnitude
                if dist < 15 then
                    togglePanel()
                end
            end
        end
        ballDrag.dragging = false
        ballDrag.startPos = nil
        ballDrag.startBallPos = nil
        ballDrag.bound = nil
    end)
end

-- ============================================================
-- 脚本初始化：清理、加载配置、启动 UI、绑定事件
-- ============================================================
clearVisuals()
makeOverlay()
print("[Nexus Pro] 脚本已开始加载")

local configLoaded = loadConfig()
print("[Nexus Pro] 配置加载:", configLoaded)

-- 保存游戏原始 FOV 和移速（用于恢复）
state.originalFov = workspace.CurrentCamera and workspace.CurrentCamera.FieldOfView or 70
local origH = hum(LocalPlayer)
if origH then state.originalWalk = origH.WalkSpeed end

-- 若配置中开启静默自瞄，立即安装 Hook
if state.silentAim then
    pcall(setupSilentAim)
end

-- 异步加载 UI 面板（避免阻塞）
task.spawn(function()
    task.wait(0.05)
    local ok, err = pcall(buildFluentModdedUI)
    if not ok then
        warn("[Nexus Pro] 面板构建出错: " .. tostring(err))
    end
    updatePlayerParagraph()
    if configLoaded then
        pcall(function()
            uiRefs.Fluent:Notify({ Title = "Nexus Pro 手机版", Content = "已恢复上次保存的配置", Duration = 3 })
        end)
    end
end)
print("[Nexus Pro] 脚本主体已初始化完成")

-- 当角色重生时重置假人缓存
LocalPlayer.CharacterAdded:Connect(function()
    lastDummyScan = 0
    table.clear(dummyCacheList)
    wallBangCacheTime = 0
    table.clear(wallBangCache)
end)

-- 触摸/鼠标按下事件：激活吸附并触发准星扩散
UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if uiStore.touchingBall then return end

    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        state.rightDown = true
        state.dummyRightDown = true
        table.clear(detachedTargets)
        if state.crosshair.dynamicSpread then
            state.crosshair.spreadCurrent = state.crosshair.spreadAmount
        end
    end
end)

UserInputService.InputEnded:Connect(function(input, gp)
    if gp then return end
    if uiStore.touchingBall then return end
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        state.rightDown = false
        state.dummyRightDown = false
    end
end)

-- 玩家加入/离开时更新列表和缓存
Players.PlayerAdded:Connect(function()
    task.defer(updatePlayerParagraph)
    wallBangCacheTime = 0
    table.clear(wallBangCache)
end)

Players.PlayerRemoving:Connect(function(plr)
    if state.selected == plr then
        state.selected = nil
    end
    if state.currentTarget == plr then
        state.currentTarget = nil
    end
    destroyPlayerTags(plr)
    destroyPlayerHighlights(plr)
    task.defer(updatePlayerParagraph)
end)

-- 检测子弹零件（用于子弹追踪）
workspace.DescendantAdded:Connect(function(desc)
    if desc:IsA("BasePart") and isBulletPartName(desc.Name) then
        bulletTrack[desc] = true
    end
end)

workspace.DescendantRemoving:Connect(function(desc)
    bulletTrack[desc] = nil
end)

-- 构建穿墙模式下的白名单（所有玩家角色部件）
local function buildCharWhitelist()
    local now = os.clock()
    if now - wallBangCacheTime < 0.3 and #wallBangCache > 0 then
        return wallBangCache
    end
    wallBangCacheTime = now
    table.clear(wallBangCache)
    for _, plr in ipairs(Players:GetPlayers()) do
        local c = char(plr)
        if c then
            for _, part in ipairs(c:GetDescendants()) do
                if part:IsA("BasePart") then
                    table.insert(wallBangCache, part)
                end
            end
        end
    end
    return wallBangCache
end

-- Hook 射线检测实现穿墙子弹
local oldNamecall
pcall(function()
    oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
        if self ~= workspace or _bypassWallBang or not state.wallBang then
            return oldNamecall(self, ...)
        end
        local method = getnamecallmethod()
        local args = {...}

        if method == "Raycast" then
            local newParams = RaycastParams.new()
            newParams.FilterType = Enum.RaycastFilterType.Whitelist
            newParams.FilterDescendantsInstances = buildCharWhitelist()
            local params = args[3]
            if params then newParams.IgnoreWater = params.IgnoreWater end
            args[3] = newParams
            return oldNamecall(self, unpack(args))
        end

        if method == "FindPartOnRayWithIgnoreList" or method == "FindPartOnRayWithWhitelist" then
            local ray = args[1]
            args[2] = buildCharWhitelist()
            return oldNamecall(self, unpack(args))
        end

        if method == "FindPartOnRay" then
            local ray = args[1]
            args[2] = nil
            args[3] = true
            return oldNamecall(self, unpack(args))
        end

        return oldNamecall(self, ...)
    end)
end)

-- ============================================================
-- 主循环：每帧执行所有功能
-- ============================================================
RunService:BindToRenderStep("ZFluentPvpStep", Enum.RenderPriority.Camera.Value + 1, function(deltaTime)
    Camera = workspace.CurrentCamera or Camera
    updateFovCircle()
    updateDummyFovCircle()

    -- 更新 ESP 和身份牌（间隔 0.2 秒刷新）
    local needUpdate = state.enemyEsp or state.friendEsp or state.nameTags
    if needUpdate then
        espUpdateTimer = espUpdateTimer + deltaTime
        if espUpdateTimer >= 0.2 then
            espUpdateTimer = 0
            for _, plr in ipairs(Players:GetPlayers()) do
                if plr ~= LocalPlayer then
                    pcall(updateEspFor, plr)
                end
            end
        end
    else
        -- 如果未启用任何绘制，则定期清理残留
        espUpdateTimer = espUpdateTimer + deltaTime
        if espUpdateTimer >= 0.5 then
            espUpdateTimer = 0
            for _, plr in ipairs(Players:GetPlayers()) do
                if plr ~= LocalPlayer then
                    destroyPlayerHighlights(plr)
                    destroyPlayerTags(plr)
                end
            end
            table.clear(lastHpCache)
        end
    end

    -- 自瞄逻辑（玩家）
    local active = (state.aimEnabled or state.spinScan) and (state.spinScan or not state.holdRight or state.rightDown)
    local plr, part, meta = nil, nil, nil

    if active then
        if state.currentTarget and state.detachOnDeath and not isAlive(state.currentTarget) then
            detachedTargets[state.currentTarget] = true
            state.currentTarget = nil
        end
        plr, part, meta = getBestTarget()
        if plr then
            state.currentTarget = plr
            state.selected = plr
        end
    else
        state.currentTarget = nil
    end

    -- 旋转扫描
    if active and state.spinScan and not part and Camera then
        local yaw = math.rad((state.spinSpeed or 80) * (deltaTime or 1 / 60))
        Camera.CFrame = Camera.CFrame * CFrame.Angles(0, yaw, 0)
    end

    -- 无后坐力/无扩散
    if state.noRecoil or state.noSpread then
        recoilTimer = recoilTimer + deltaTime
        if recoilTimer >= 0.2 then
            recoilTimer = 0
            applyNoRecoilSpread()
        end
    end

    -- 雷达
    if state.radar then
        radarTick = radarTick + deltaTime
        if radarTick >= 0.1 then
            radarTick = 0
            updateRadar()
        end
    else
        radarTick = 0
        updateRadar()
    end

    updateCrosshair()

    -- 大头
    if state.bigHeadAll or state.bigHeadEnemy or state.bigHeadFriend then
        bigHeadTick = bigHeadTick + deltaTime
        if bigHeadTick >= 0.1 then
            bigHeadTick = 0
            applyBigHead()
        end
    else
        bigHeadTick = 0
        applyBigHead()
    end

    applyAutoBhop()
    applyWalkAdjust()
    updateDummyEsp()

    -- 假人自瞄
    local dummyActive = state.dummyAim and (not state.dummyHoldRight or state.dummyRightDown)
    local dm, dp, ddiag = nil, nil, nil
    if dummyActive then
        dm, dp, ddiag = getBestDummyTarget()
        if dm then state.dummyCurrentTarget = dm end
    else
        state.dummyCurrentTarget = nil
    end
    pcall(function()
        getgenv().ZDummyLive = { dummyAim = state.dummyAim, dummyActive = dummyActive, got = dm ~= nil, target = dm and tostring(dm.Name) or nil, diag = ddiag }
    end)

    if dummyActive and dp and dp.Parent and Camera then
        local dcur = Camera.CFrame
        Camera.CFrame = dcur:Lerp(CFrame.lookAt(dcur.Position, dp.Position), math.clamp(state.dummySmooth, 0.03, 0.75))
        applyDummyAutoFire()
    end

    updateDummyTargetMarker(dp)

    -- 状态栏更新
    statusTimer = statusTimer + deltaTime
    if statusTimer >= 0.25 then
        statusTimer = 0
        if not (state.aimEnabled or state.spinScan) then
            updateStatus("吸附未开启")
        elseif (not state.spinScan) and state.holdRight and not state.rightDown then
            updateStatus("手机版：触摸屏幕启动吸附" .. (state.aimDummy and " | 假人吸附已开" or ""))
        elseif plr then
            local name = (type(plr) == "userdata" and pcall(function() return plr.Name end) and plr.Name) or "假人"
            updateStatus(string.format("锁定：%s | %.0fm | %s%s", name, meta and meta.worldDist or 0, (meta and meta.visible) and "可见" or "穿墙", state.wallBang and " | 子弹穿墙" or ""))
        elseif meta and meta.selectedOnly then
            updateStatus("只吸附所选玩家：请先在玩家页选择目标")
        elseif meta and meta.tooFar and meta.tooFar > 0 then
            updateStatus("圈内目标超过最大距离")
        elseif meta and meta.inFov and meta.inFov > 0 and not state.wallAim then
            updateStatus("圈内目标被遮挡，开启穿墙吸附可忽略遮挡")
        else
            updateStatus("圈内无可锁目标")
        end
    end

    updateTargetMarker(part)

    -- 摄像机平滑转向 + 自动开火
    if active and part and part.Parent and Camera then
        local current = Camera.CFrame
        local targetPos = part.Position
        local goal = CFrame.lookAt(current.Position, targetPos)
        Camera.CFrame = current:Lerp(goal, math.clamp(state.smooth, 0.03, 0.75))
        requestAutoFire()
    end
end)

print("PlaceId:", game.PlaceId, "JobId:", game.JobId)

-- 后台调试循环（可选）
task.spawn(function()
    while task.wait(2) do
        if not (state.dummyAim or state.dummyEsp or state.dummyShowFov or state.bigHeadAll or state.bigHeadEnemy or state.bigHeadFriend) then continue end
        local dummies = getDummyModels()
        local aimOn = state.dummyAim
        local cur = state.dummyCurrentTarget
        local hold = state.dummyHoldRight
        local rd = state.dummyRightDown
        local active = aimOn and (not hold or rd)
        local tpart = cur and getDummyAimPart(cur) or nil
        pcall(function()
            getgenv().ZDummyDebug = {
                aimOn = aimOn, holdRight = hold, rightDown = rd, active = active,
                dummies = #dummies, current = cur and tostring(cur.Name) or nil,
                targetPart = tpart and tostring(tpart.Name) or nil,
                dummyNames = {},
            }
            for _, m in ipairs(dummies) do
                if #getgenv().ZDummyDebug.dummyNames < 6 then
                    table.insert(getgenv().ZDummyDebug.dummyNames, tostring(m.Name))
                end
            end
        end)
    end
end)
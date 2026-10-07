-- ==================================================================
--  中央有限曲线 · NothingLibrary 缝合版
--  缝合说明：
--    1. 功能代码 100% 来自《中央有限曲线-源码.lua》
--    2. UI 框架换为 LOARD.lua 使用的 NothingLibrary（同一远程库）
--    3. 通过下方的 Obsidian→NothingLibrary 适配层，原脚本的
--       AddToggle/AddButton/AddSlider/AddDropdown/AddInput/AddLabel
--       /AddCheckbox/AddKeyPicker/AddColorPicker、Options/Toggles 状态
--       读取、SetValue/OnChanged/SetValues/Refresh/OnClick 等全部照常工作
--    4. 按需求已剔除：开头音乐播放脚本（原 1-52 行）
--    5. 另外剔除：原 6705-6742 行的损坏重复片段（原文件此处语法残缺，
--       不删整个脚本无法运行）；原 90-110 行"脚本过期踢人"远检（留着会让
--       本缝合版在原版更新后无法使用）；原版 Theme/SaveManager 与背景图
--       设置（NothingLibrary 不支持）；原作者活跃度上报（15463-15472）
-- ==================================================================


local HttpService = game:GetService("HttpService")
local n = 0
local flag = false
pcall(function()
if game.PlaceId ~= 99567941238278 then
local data = nil
local ok, result = pcall(function()
    return game:HttpGet("https://platinstudio.xyz/raw/InkVersion")
end)
if ok and result then
    pcall(function() data = HttpService:JSONDecode(result) end)
end
if not data or not data.LastCheckedVersion then
    local ok2, result2 = pcall(function()
        return game:HttpGet("https://raw.githubusercontent.com/platinww/UwU/refs/heads/main/UI/InkVersion.json")
    end)
    if ok2 and result2 then
        pcall(function() data = HttpService:JSONDecode(result2) end)
    end
end
if data and data.LastCheckedVersion then
    n = tonumber(data.LastCheckedVersion) or 0
end
end
end)

if game.PlaceId ~= 99567941238278 then
if n < game.PlaceVersion then flag = true end
end

if not game:IsLoaded() then game.Loaded:Wait() end

local tbl, tbl2, tbl3 = {}, {}, {}
local flag2 = false


-- [缝合注] 已移除原版“脚本过期踢人”远程检测（原90-110行），避免本缝合版被误踢


local Workspace           = game:GetService("Workspace")
local Players             = game:GetService("Players")
local ReplicatedStorage   = game:GetService("ReplicatedStorage")
local RunService          = game:GetService("RunService")
local UserInputService    = game:GetService("UserInputService")
local ContentProvider     = game:GetService("ContentProvider")
local StarterGui          = game:GetService("StarterGui")
local SoundService        = game:GetService("SoundService")
local Lighting            = game:GetService("Lighting")
local TweenService        = game:GetService("TweenService")
local Debris              = game:GetService("Debris")
local ContextActionService= game:GetService("ContextActionService")
local ProximityPromptService = game:GetService("ProximityPromptService")
local GuiService          = game:GetService("GuiService")
local localPlayer         = Players.LocalPlayer

-- ==================================================================
--  NothingLibrary 加载 + Obsidian 风格 API 适配层
-- ==================================================================
local NothingLibrary = loadstring(game:HttpGetAsync('https://raw.githubusercontent.com/quanwei-sy/qianweicangku/refs/heads/main/%E6%BA%90%E7%A0%81.lua'))();

local NTOptions  = {}
local NTToggles  = {}
local NTKeybinds = {}

local Library = {}
Library.Options = NTOptions
Library.Toggles = NTToggles
Library.KeybindFrame = { Visible = false }
Library.ShowCustomCursor = false
Library.CornerRadius = 4
Library.UnloadSignals = {}

function Library:OnUnload(fn) table.insert(self.UnloadSignals, fn) end
function Library:SetNotifySide(_) end
function Library:SetDPIScale(_) end
function Library:SetBackgroundImage(_) end

local NTNotifier = NothingLibrary.Notification()
function Library:Notify(a, b)
    local title, desc, dur
    if type(a) == "table" then
        title, desc, dur = a.Title, a.Description, (a.Time or a.Duration)
    else
        local s = tostring(a or "中央有限曲线")
        local p = s:find(" | ", 1, true)
        if p then title, desc = s:sub(1, p - 1), s:sub(p + 3) else title, desc = s, "" end
        dur = b
    end
    task.spawn(function()
        pcall(function()
            NTNotifier.new({
                Title = tostring(title or "提示"),
                Description = tostring(desc or ""),
                Duration = tonumber(dur) or 4,
            })
        end)
    end)
end

-- 按键绑定监听（NothingLibrary 的 NewKeybind 只负责改键，按下触发由适配层实现）
local function NTToKeyCode(s)
    if type(s) ~= "string" or s == "None" then return nil end
    if s == "MB1" then return Enum.UserInputType.MouseButton1 end
    if s == "MB2" then return Enum.UserInputType.MouseButton2 end
    if s == "MB3" then return Enum.UserInputType.MouseButton3 end
    local ok, kc = pcall(function() return Enum.KeyCode[s] end)
    return ok and kc or nil
end

UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    for _, kb in ipairs(NTKeybinds) do
        if kb.enum and (input.KeyCode == kb.enum or input.UserInputType == kb.enum) then
            if kb.toggle then pcall(function() kb.toggle:SetValue(not kb.toggle.Value) end) end
            for _, fn in ipairs(kb.clicks) do task.spawn(fn) end
            if kb.callback then task.spawn(kb.callback, true) end
        end
    end
end)

-- 控件状态对象（提供 .Value / :SetValue / :OnChanged 等 Obsidian 语义）
local function NTState(kind, default)
    local st = { Value = default, _kind = kind, _cbs = {} }
    function st:OnChanged(fn) table.insert(self._cbs, fn) end
    function st:_fire(v)
        for _, fn in ipairs(self._cbs) do task.spawn(fn, v) end
    end
    return st
end

local function NTPlayerList(excludeSelf)
    local list = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if not (excludeSelf and p == localPlayer) then table.insert(list, p.Name) end
    end
    return list
end

local NTWindow

local function NTMakeGroup(sec)
    local group = {}

    local function attachColorPicker(parent, idx, cfg)
        cfg = cfg or {}
        -- NothingLibrary 无颜色选择控件：保留状态对象（默认色），功能逻辑照常读取 .Value
        local st = NTState("colorpicker", cfg.Default or Color3.new(1, 1, 1))
        function st:SetValue(c)
            self.Value = c
            self:_fire(c)
            if cfg.Callback then task.spawn(cfg.Callback, c) end
        end
        NTOptions[idx] = st
        if cfg.Callback then task.defer(function() pcall(cfg.Callback, st.Value) end) end
        return parent
    end

    local function attachKeyPicker(parent, parentToggle, idx, cfg)
        cfg = cfg or {}
        local st = NTState("keypicker", cfg.Default)
        st._clicks = {}
        function st:OnClick(fn) table.insert(self._clicks, fn) end
        function st:GetState() return false end
        function st:SetValue(v) self.Value = v end
        local kb = {
            enum = NTToKeyCode(cfg.Default),
            toggle = (cfg.SyncToggleState and parentToggle) or nil,
            clicks = st._clicks,
            callback = nil,
        }
        table.insert(NTKeybinds, kb)
        sec:NewKeybind({
            Title = cfg.Text or tostring(idx),
            Default = kb.enum or Enum.KeyCode.Unknown,
            Callback = function(newKey)
                kb.enum = newKey
                st.Value = (typeof(newKey) == "EnumItem") and newKey.Name or tostring(newKey)
            end,
        })
        NTOptions[idx] = st
        return parent
    end

    function group:AddToggle(idx, cfg)
        cfg = cfg or {}
        local st = NTState("toggle", cfg.Default or false)
        local handle
        handle = sec:NewToggle({
            Title = cfg.Text or tostring(idx),
            Default = cfg.Default or false,
            Callback = function(v)
                st.Value = v
                st:_fire(v)
                if cfg.Callback then task.spawn(cfg.Callback, v) end
            end,
        })
        function st:SetValue(v)
            self.Value = v
            if handle and handle.Value then
                pcall(handle.Value, v)   -- 更新 UI 并触发上面的 Callback（含 OnChanged）
            else
                self:_fire(v)
                if cfg.Callback then task.spawn(cfg.Callback, v) end
            end
        end
        st.AddColorPicker = function(self, i, c) return attachColorPicker(self, i, c) end
        st.AddKeyPicker  = function(self, i, c) return attachKeyPicker(self, self, i, c) end
        NTToggles[idx] = st
        NTOptions[idx] = st
        return st
    end
    group.AddCheckbox = group.AddToggle

    function group:AddButton(a, b)
        local cfg = a
        if type(a) == "string" then cfg = { Text = a, Func = b } end
        cfg = cfg or {}
        return sec:NewButton({
            Title = cfg.Text or "按钮",
            Callback = function()
                local fn = cfg.Func or cfg.Callback
                if fn then task.spawn(fn) end
            end,
        })
    end

    function group:AddSlider(idx, cfg)
        cfg = cfg or {}
        local st = NTState("slider", cfg.Default or cfg.Min or 0)
        local handle
        handle = sec:NewSlider({
            Title = cfg.Text or tostring(idx),
            Min = cfg.Min or 0,
            Max = cfg.Max or 100,
            Default = cfg.Default or 0,
            Callback = function(v)
                st.Value = v
                st:_fire(v)
                if cfg.Callback then task.spawn(cfg.Callback, v) end
            end,
        })
        function st:SetValue(v)
            self.Value = v
            if handle and handle.Value then pcall(handle.Value, v) end
        end
        NTOptions[idx] = st
        return st
    end

    function group:AddDropdown(idx, cfg)
        cfg = cfg or {}
        local values = cfg.Values or cfg.Data or {}
        if cfg.SpecialType == "Player" then values = NTPlayerList(cfg.ExcludeLocalPlayer) end
        local multi = cfg.Multi and true or false
        local st
        if multi then
            local init = {}
            if type(cfg.Default) == "table" then for k, v in pairs(cfg.Default) do init[k] = v end end
            st = NTState("dropdown", init)
        else
            local dv = cfg.Default
            if type(dv) == "number" then dv = values[dv] end
            if dv == nil then dv = values[1] end
            st = NTState("dropdown", dv)
        end
        local handle
        handle = sec:NewDropdown({
            Title = cfg.Text or tostring(idx),
            Data = values,
            Default = (not multi and st.Value ~= nil) and st.Value or "",
            Callback = function(v)
                if multi then
                    local cur = st.Value        -- NothingLibrary 为单选：用"点选切换成员"模拟多选
                    if cur[v] then cur[v] = nil else cur[v] = true end
                else
                    st.Value = v
                end
                st:_fire(st.Value)
                if cfg.Callback then task.spawn(cfg.Callback, st.Value) end
            end,
        })
        function st:SetValue(v)
            self.Value = v
            if not multi and handle and handle.Value then pcall(handle.Value, v) end
        end
        function st:SetValues(list)
            values = list
            if handle and handle.Set then pcall(handle.Set, list) end
        end
        function st:Refresh(list) self:SetValues(list) end
        NTOptions[idx] = st
        if cfg.SpecialType == "Player" then
            local function refreshPlayers()
                pcall(function() st:SetValues(NTPlayerList(cfg.ExcludeLocalPlayer)) end)
            end
            Players.PlayerAdded:Connect(refreshPlayers)
            Players.PlayerRemoving:Connect(refreshPlayers)
        end
        return st
    end

    function group:AddInput(idx, cfg)
        cfg = cfg or {}
        local st = NTState("input", cfg.Default or "")
        sec:NewTextbox({
            Title = cfg.Text or tostring(idx),
            Default = tostring(cfg.Default or ""),
            Callback = function(v)
                st.Value = v
                st:_fire(v)
                if cfg.Callback then task.spawn(cfg.Callback, v) end
            end,
        })
        function st:SetValue(v) self.Value = v end
        NTOptions[idx] = st
        return st
    end

    function group:AddLabel(text, _)
        local handle = sec:NewTitle(tostring(text))
        local st = NTState("label", text)
        function st:SetText(t)
            self.Value = t
            if handle and handle.Set then pcall(handle.Set, tostring(t)) end
        end
        st.AddColorPicker = function(self, i, c) return attachColorPicker(self, i, c) end
        st.AddKeyPicker  = function(self, i, c) return attachKeyPicker(self, nil, i, c) end
        return st
    end

    function group:AddDivider() end  -- NothingLibrary 无分割线，忽略

    function group:AddKeyPicker(idx, cfg) return attachKeyPicker(nil, nil, idx, cfg) end
    function group:AddColorPicker(idx, cfg) return attachColorPicker(nil, idx, cfg) end

    return group
end

local NTWindowObj = {}
NTWindowObj.Gui = nil
function NTWindowObj:SetBackgroundImage(_) end
function NTWindowObj:SetCornerRadius(_) end
function NTWindowObj:AddTab(name, icon)
    local tab = NTWindow:NewTab({ Title = tostring(name), Description = tostring(name) })
    local TabObj = {}
    local function mk(side)
        return function(title, gicon)
            local cleanTitle = tostring(title or ""):gsub("^|%s*", "")
            return NTMakeGroup(tab:NewSection({ Title = cleanTitle, Position = side }))
        end
    end
    TabObj.AddLeftGroupbox  = mk("Left")
    TabObj.AddRightGroupbox = mk("Right")
    return TabObj
end

function Library:CreateWindow(cfg)
    cfg = cfg or {}
    NTWindow = NothingLibrary.new({
        Title = cfg.Title or "中央有限曲线",
        Description = cfg.Footer or "Roblox Script",
        Keybind = Enum.KeyCode.LeftControl,
        Logo = cfg.Icon or 'http://www.roblox.com/asset/?id=18810965406',
    })
    return NTWindowObj
end


local Options = Library.Options
local Toggles = Library.Toggles

-- 创建主窗口
local Window = Library:CreateWindow({
Title = "中央有限曲线",
Footer = "付费版V1.3，以后主要更新",
Size = UDim2.fromOffset(750, 650),
Icon = "rbxassetid://122936242690381",
AutoShow = true,
NotifySide = "Right",
ShowCustomCursor = true,
IconSize = UDim2.fromOffset(30, 30),
Resizable = true,
MobileButtonsSide = "Left",
DisableSearch = false,
SearchbarSize = UDim2.new(0.8, 0, 1, 0),
GlobalSearch = false,
Position = UDim2.fromOffset(100, 100),
Center = true,
EnableSidebarResize = true,
EnableCompacting = true,
SidebarCompacted = false,
MinContainerWidth = 256,
})

local Tabs = {
RLGL    = Window:AddTab("游戏", "gamepad"),
Zxgn    = Window:AddTab("杂项", "sparkles"),
Wjewgn  = Window:AddTab("玩家", "user-round"),
Players = Window:AddTab("玩家信息", "info"),
Ylgn    = Window:AddTab("娱乐功能", "rocket"),
Swgn    = Window:AddTab("守卫", "shield"),
Guanliy    = Window:AddTab("管理员滥用", "shield"),
UISettings = Window:AddTab("UI设置", "palette"),
}
--背景图UI设置
Window:SetBackgroundImage("https://cdn.jsdelivr.net/gh/fningna51-stack/-@8b556c121fa2a589098a2a5bc89df5693592b93f/1351575.jpg?format=jpg")

local function btn(group, text, func, dbl)
return group:AddButton({ Text = text, Func = func, DoubleClick = dbl or false })
end
local function notify(title, content, dur)
Library:Notify(tostring(title or "AF Hub") .. (content and (" | " .. tostring(content)) or ""), dur or 4)
end
local function fn12(gameName)
local v = Workspace:FindFirstChild("Values")
v = v and v:FindFirstChild("CurrentGame")
return v and v.Value == gameName
end
local soundId = "rbxassetid://4590657391"
pcall(function()
if not isfolder("UwUStudios") then makefolder("UwUStudios") end
if not isfile("UwUStudios/notify.wav") then
    local response = game:HttpGet("https://github.com/platinww/UwU/raw/refs/heads/main/UI/notify.wav")
    writefile("UwUStudios/notify.wav", response)
end
if getcustomasset then
    soundId = getcustomasset("UwUStudios/notify.wav")
end
end)
local function fn13(arg, arg2)
Library:Notify(tostring(arg or "AF Hub") .. (arg2 and (" | " .. tostring(arg2)) or ""), 4)
pcall(function()
    local s = Instance.new("Sound")
    s.SoundId = soundId or "rbxassetid://4590657391"
    s.Volume = 2
    s.Parent = SoundService
    s:Play()
    Debris:AddItem(s, 3)
end)
end
-- 按键 / 传送 / QTE 辅助
local keyMap = {
w=87,a=65,s=83,d=68,space=32,e=69,q=81,f=70,r=82,t=84,y=89,
x=88,c=67,v=86,b=66,g=71,h=72,z=90,
["1"]=49,["2"]=50,["3"]=51,["4"]=52,["5"]=53,
["6"]=54,["7"]=55,["8"]=56,["9"]=57,["0"]=48,
}
local function fn14(arg)
if type(keypress) == "function" and type(keyrelease) == "function" then
    local code = keyMap[string.lower(tostring(arg))]
    if code then
        keypress(code); task.wait(0.05); keyrelease(code)
        return true
    end
end
return false
end
local HBGQTE = nil
local function fn15()
if not HBGQTE then
    pcall(function()
        local modules = ReplicatedStorage:WaitForChild("Modules", 5)
        if modules then HBGQTE = require(modules:WaitForChild("HBGQTE", 5)) end
    end)
end
return HBGQTE
end
local function fn17(cf)
local ch = localPlayer.Character
if not ch or not ch:FindFirstChild("HumanoidRootPart") then return end
local hrp = ch.HumanoidRootPart
hrp.Velocity = Vector3.zero
hrp.RotVelocity = Vector3.zero
hrp.Anchored = true
ch:PivotTo(cf)
task.wait()
hrp.Velocity = Vector3.zero
hrp.Anchored = false
end
-- Pentathlon hook反作弊
local guid = nil
task.spawn(function()
pcall(function()
local modules = ReplicatedStorage:WaitForChild("Modules", 5)
if modules then
    local games = modules:WaitForChild("Games", 5)
    if games then
        local PentathlonClient = require(games:WaitForChild("PentathlonClient", 5))
        if PentathlonClient and type(PentathlonClient) == "table" then
            local orig = PentathlonClient.RunServerGame
            if orig then
                PentathlonClient.RunServerGame = function(a, b, ...)
                    if a and a.GUID then guid = a.GUID end
                    local p = table.pack(...)
                    p.n = 3 + p.n - 1
                    table.move(p, 1, p.n, 3, p)
                    p[1] = a; p[2] = b
                    return orig(table.unpack(p, 1, p.n))
                end
            end
            local origAdd = PentathlonClient.AddActiveGame
            if origAdd then
                PentathlonClient.AddActiveGame = function(a)
                    if a and a.GUID then guid = a.GUID end
                    return origAdd(a)
                end
            end
        end
    end
end
end)
end)
local function fn16(eventName, data)
if not guid then return false end
local remotes = ReplicatedStorage:FindFirstChild("Remotes")
local pent = remotes and remotes:FindFirstChild("PentathlonRemote")
if pent then
if data then
    pent:FireServer(guid, eventName, data)
else
    pent:FireServer(guid, eventName)
end
return true
end
return false
end
--游戏标签页
local RLGLGroup = Tabs.RLGL:AddLeftGroupbox("| 红灯绿灯", "traffic-cone")
local DalgonaGroup = Tabs.RLGL:AddLeftGroupbox("| 糖饼", "cookie")
local TugGroup = Tabs.RLGL:AddLeftGroupbox("| 拔河", "link")
local TugGroup2 = Tabs.RLGL:AddLeftGroupbox("| 拔河2", "link-2")
local JumpGroup = Tabs.RLGL:AddLeftGroupbox("| 跳绳", "activity")
local GlassGroup = Tabs.RLGL:AddLeftGroupbox("| 玻璃桥", "glass-water")
local SkyGroup = Tabs.RLGL:AddLeftGroupbox("| 天空游戏", "cloud-sun")
local LOGroup = Tabs.RLGL:AddRightGroupbox("| 熄灯", "lightbulb-off")
local PentGroup = Tabs.RLGL:AddRightGroupbox("| 五项全能", "medal")
local Wcgn = Tabs.RLGL:AddRightGroupbox("| 晚餐", "utensils")
local HSTOWGroup = Tabs.RLGL:AddRightGroupbox("| 捉迷藏", "eye-off")
local RebelGroup = Tabs.RLGL:AddRightGroupbox("| 反叛(暂时不可使用)", "flag")
local MingleGroup = Tabs.RLGL:AddRightGroupbox("| 旋转木马", "rotate-cw")
local SquidGroup = Tabs.RLGL:AddRightGroupbox("| 真男人一V一", "swords")
--红绿灯
tbl3.lastTPTime = 0
btn(RLGLGroup, "传送到终点", function()
if tick() - tbl3.lastTPTime < 10 then
    fn13("冷却", "请等待 " .. math.ceil(10 - (tick() - tbl3.lastTPTime)) .. " 秒后再传送。")
    return
end
if fn12("RedLightGreenLight") then
    fn17(CFrame.new(-45, 1025, 137))
    tbl3.lastTPTime = tick()
else
    fn13(nil, "红灯绿灯当前未运行。")
end
end)
btn(RLGLGroup, "传送到起点", function()
if tick() - tbl3.lastTPTime < 10 then
    fn13("冷却", "请等待 " .. math.ceil(10 - (tick() - tbl3.lastTPTime)) .. " 秒后再传送。")
    return
end
if fn12("RedLightGreenLight") then
    fn17(CFrame.new(-49, 1023, -540))
    tbl3.lastTPTime = tick()
else
    fn13(nil, "红灯绿灯当前未运行。")
end
end)
btn(RLGLGroup, "解除受伤", function()
if not fn12("RedLightGreenLight") then
    fn13(nil, "红灯绿灯当前未运行。")
    return
end
local ch = localPlayer.Character
if not ch then return end
local hum = ch:FindFirstChild("Humanoid")
local hrp = ch:FindFirstChild("HumanoidRootPart")
if not (hum and hrp) then return end
local torso = ch:FindFirstChild("Torso") or ch:FindFirstChild("UpperTorso")
hum.PlatformStand = false
hum:ChangeState(Enum.HumanoidStateType.GettingUp)
hum:SetStateEnabled(Enum.HumanoidStateType.Freefall, true)
hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
hum:SetStateEnabled(Enum.HumanoidStateType.Jumping, true)
for _, s in pairs({
    Enum.HumanoidStateType.FallingDown,
    Enum.HumanoidStateType.Seated,
    Enum.HumanoidStateType.Swimming,
    Enum.HumanoidStateType.Flying,
    Enum.HumanoidStateType.StrafingNoPhysics,
    Enum.HumanoidStateType.Ragdoll,
}) do hum:SetStateEnabled(s, false) end

for _, child in pairs(hrp:GetChildren()) do
    if child:IsA("BallSocketConstraint") or child.Name:match("^CacheAttachment") then
        child:Destroy()
    end
end
if torso then
    for _, n2 in pairs({ "Left Hip", "Left Shoulder", "Neck", "Right Hip", "Right Shoulder" }) do
        local m = torso:FindFirstChild(n2)
        if m and m:IsA("Motor6D") and not m.Part0 then m.Part0 = torso end
    end
end
for _, child in pairs(ch:GetChildren()) do
    if child:IsA("BasePart") and child:FindFirstChild("BoneCustom") then child.BoneCustom:Destroy() end
end
for _, k in pairs({ "Ragdoll", "Stun", "RotateDisabled", "RagdollWakeupImmunity", "Injured" }) do
    local x = ch:FindFirstChild(k); if x then x:Destroy() end
end
local effects = Workspace:FindFirstChild("Effects")
if effects then
    local lr = effects:FindFirstChild("LocalRagdolls")
    if lr then local p = lr:FindFirstChild(localPlayer.Name); if p then p:Destroy() end end
end
if ch:GetAttribute("Injured") then ch:SetAttribute("Injured", false) end
end)
btn(RLGLGroup, "防爬行", function()
if not fn12("RedLightGreenLight") then
    fn13(nil, "红灯绿灯当前未运行。")
    return
end
fn13(nil, "防爬行已启用")
task.spawn(function()
    while fn12("RedLightGreenLight") do
        local ch = localPlayer.Character
        if ch and ch:FindFirstChild("Crawling") then ch.Crawling:Destroy() end
        task.wait(0.25)
    end
end)
end)
do
local function setSpeed(on)
    local ch = localPlayer.Character
    if not ch then return end
    local hum = ch:FindFirstChild("Humanoid")
    if hum then
        hum.WalkSpeed = on and 16 or 0
        hum.JumpPower = on and 50 or 0
    end
    local hrp = ch:FindFirstChild("HumanoidRootPart")
    if hrp and not on then hrp.Velocity = Vector3.zero end
end
local function inBox(pos, a, b)
    return pos.X >= math.min(a.X,b.X) and pos.X <= math.max(a.X,b.X)
       and pos.Z >= math.min(a.Z,b.Z) and pos.Z <= math.max(a.Z,b.Z)
end
local function inSafe()
    local ch = localPlayer.Character
    if not ch or not ch:FindFirstChild("HumanoidRootPart") then return false end
    local p = ch.HumanoidRootPart.Position
    return inBox(p, Vector3.new(-216, 0, 83), Vector3.new(103, 0, 168))
        or inBox(p, Vector3.new(103, 0, 168), Vector3.new(116, 0, 82))
        or inBox(p, Vector3.new(115, 0, -578), Vector3.new(-215, 0, -516))
end
local redIcon = "rbxassetid://88400194373338"
local frozen = false
RLGLGroup:AddToggle("RLGL_FreezeOnRed", {
    Text = "红灯时冻结",
    Default = false,
    Callback = function(on)
        tbl.autoStopEnabled = on
        if on then
            if tbl2.freezeThread then return end
            tbl2.freezeThread = true
            task.spawn(function()
                while tbl2.freezeThread and tbl.autoStopEnabled do
                    if not fn12("RedLightGreenLight") then
                        if frozen then setSpeed(true); frozen = false end
                    else
                        local pg = localPlayer:FindFirstChild("PlayerGui")
                        local isRed = false
                        if pg then
                            local imp = pg:FindFirstChild("ImpactFrames")
                            if imp then
                                local tl = imp:FindFirstChild("TrafficLightEmpty")
                                isRed = tl and tl.Image == redIcon
                            end
                        end
                        if isRed and not inSafe() then
                            if not frozen then setSpeed(false); frozen = true end
                            local ch = localPlayer.Character
                            if ch then
                                local hum = ch:FindFirstChild("Humanoid")
                                if hum then hum.WalkSpeed = 0; hum.JumpPower = 0 end
                                local hrp = ch:FindFirstChild("HumanoidRootPart")
                                if hrp then hrp.Velocity = Vector3.zero end
                            end
                        elseif frozen then
                            setSpeed(true); frozen = false
                        end
                    end
                    task.wait(0.1)
                end
                tbl2.freezeThread = nil
                if frozen then setSpeed(true); frozen = false end
            end)
        end
    end,
})
end
tbl2.autoTPEndThread = nil
RLGLGroup:AddToggle("RLGL_AutoTPEnd", {
Text = "最后一秒自动传送到终点",
Default = false,
Callback = function(on)
tbl.autoTPEndEnabled = on
if on then
if tbl2.autoTPEndThread then return end
tbl2.autoTPEndThread = true
task.spawn(function()
while tbl2.autoTPEndThread and tbl.autoTPEndEnabled do
    if fn12("RedLightGreenLight") then
        local t = workspace:GetAttribute("CurrentGameTime")
        if t and t <= 3 and t > 0 then
            local ch = localPlayer.Character
            local hrp = ch and ch:FindFirstChild("HumanoidRootPart")
            local needTP = true
            if hrp then
                local p = hrp.Position
                local function box(v,a,b)
                    return v.X >= math.min(a.X,b.X) and v.X <= math.max(a.X,b.X)
                       and v.Z >= math.min(a.Z,b.Z) and v.Z <= math.max(a.Z,b.Z)
                end
                local inStart = (box(p, Vector3.new(115,1023,84), Vector3.new(103,1023,168))
                              or box(p, Vector3.new(103,1023,168), Vector3.new(-216,1023,83)))
                              and math.abs(p.Y - 1023) < 100
                if inStart then needTP = false end
            end
            if needTP then
                fn13(nil, "最后 3 秒，正在传送到终点")
                fn17(CFrame.new(-45, 1025, 137))
            end
            task.wait(5)
        end
    end
    task.wait(1)
end
tbl2.autoTPEndThread = nil
end)
end
end,
})
do
local Players           = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService        = game:GetService("RunService")
local LocalPlayer       = Players.LocalPlayer
local function PlayToggleSound() end
local function Notify(Title, Description, Time)
    Library:Notify({ Title = Title, Description = Description, Time = Time or 3 })
end
RLGLGroup:AddDivider()
do
    local enabled   = false
    local conn      = nil
    local originalY = nil
    RLGLGroup:AddToggle("RLGLGodMode", {
        Text = "上帝模式（上抬 170 格）",
        Tooltip = "上抬 170 格，子弹无法击中你。关闭后自动落回。",
        Default = false,
        Callback = function(Value)
            enabled = Value and true or false
            if conn then
                conn:Disconnect()
                conn = nil
            end
            if enabled then
                local Character = LocalPlayer.Character
                local Root = Character and (Character:FindFirstChild("HumanoidRootPart") or Character.PrimaryPart)
                if Root then
                    originalY = Root.Position.Y
                    Root.CFrame = CFrame.new(Root.Position.X, Root.Position.Y + 170, Root.Position.Z)
                end
                conn = RunService.Heartbeat:Connect(function()
                    if not enabled then return end
                    local Values = workspace:FindFirstChild("Values")
                    local CurrentGame = Values and Values:FindFirstChild("CurrentGame")
                    if CurrentGame and CurrentGame.Value ~= "RedLightGreenLight" then
                        if Options.RLGLGodMode then
                            pcall(function()
                                Options.RLGLGodMode:SetValue(false)
                            end)
                        end
                    end
                end)
                Notify("木头人", "上帝模式 已启用", 2)
            else
                if originalY then
                    local Character = LocalPlayer.Character
                    local Root = Character and Character:FindFirstChild("HumanoidRootPart")
                    if Root then
                        Root.CFrame = CFrame.new(Root.Position.X, originalY, Root.Position.Z)
                    end
                    originalY = nil
                end
                Notify("木头人", "上帝模式 已禁用", 2)
            end
            PlayToggleSound()
        end,
    })
end
RLGLGroup:AddButton({
    Text = "移除受伤减速",
    Tooltip = "清除 Stun / InjuredWalking / Crawling 等负面状态",
    Func = function()
        local Character = LocalPlayer.Character
        if not Character then return end
        for _, Name in ipairs({ "Stun", "RotateDisabled", "InjuredWalking", "Crawling" }) do
            local Obj = Character:FindFirstChild(Name)
            if Obj then Obj:Destroy() end
        end
        Notify("木头人", "已移除受伤状态", 2)
    end,
})
end
--糖饼
do
    local Players          = game:GetService("Players")
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local TweenService     = game:GetService("TweenService")
    local RunService       = game:GetService("RunService")
    local UserInputService = game:GetService("UserInputService")
    local LocalPlayer      = Players.LocalPlayer

    local function DgNotify(title, desc)
        pcall(function()
            Library:Notify({
                Title       = title or "糖饼游戏",
                Description = desc or "",
                Time        = 2,
            })
        end)
    end
    local function IsDalgonaGame()
        local Values = workspace:FindFirstChild("Values")
        local CurrentGame = Values and Values:FindFirstChild("CurrentGame")
        return CurrentGame and CurrentGame.Value == "Dalgona"
    end
    local function GetRemote()
        local Remotes = ReplicatedStorage:FindFirstChild("Remotes")
        return Remotes and Remotes:FindFirstChild("DALGONATEMPREMPTE")
    end
    local function ExecuteClick()
        local Replication = ReplicatedStorage:WaitForChild("Replication")
        local Event = Replication:WaitForChild("Event")
        Event:FireServer(unpack({ "Clicked" }))
    end
    local function RestoreVisibility(Character)
        if not Character or not Character.Parent then return end
        for _, Part in pairs(Character:GetDescendants()) do
            if Part:IsA("BasePart") and Part.Name ~= "HumanoidRootPart" and Part.Name ~= "BoneCustom" then
                if Part.Transparency >= 0.99 or Part.LocalTransparencyModifier >= 0.99 then
                    Part.Transparency = 0
                    Part.LocalTransparencyModifier = 0
                end
            end
        end
        pcall(function()
            Character.HumanoidRootPart.Transparency = 1
        end)
        pcall(function()
            Character.Head.BoneCustom.Transparency = 1
        end)
        for _, Item in pairs(Character:GetChildren()) do
            if Item:IsA("Accessory") then
                local Handle = Item:FindFirstChild("Handle")
                if Handle and Handle.Transparency >= 0.99 then
                    Handle.Transparency = 0
                end
            end
        end
    end
    local function CheckPlayersVisibility()
        for _, Player in pairs(Players:GetPlayers()) do
            if Player.Character then
                RestoreVisibility(Player.Character)
            end
        end
    end
    DalgonaGroup:AddButton({
        Text = "防裂纹",
        Tooltip = "将所有 Outline 部件克隆为不可见的 DalgonaClickPart，防止出现裂纹。仅在糖饼游戏中使用。",
        Func = function()
            if not IsDalgonaGame() then
                DgNotify(nil, "请等待糖饼游戏开始！")
                return
            end
            local Effects = workspace:FindFirstChild("Effects")
            local Count = 0
            if Effects then
                for _, Model in ipairs(Effects:GetChildren()) do
                    if Model.Name and Model.Name:find("Outline") then
                        for _, Part in ipairs(Model:GetDescendants()) do
                            if Part:IsA("BasePart") and Part.Name ~= "DalgonaClickPart" then
                                pcall(function()
                                    local Clone = Part:Clone()
                                    Clone.Name = "DalgonaClickPart"
                                    Clone.Parent = Part.Parent
                                    Clone.Size = Vector3.one
                                    Clone.Transparency = 1
                                    Clone.CanCollide = false
                                    Clone.Anchored = true
                                    Clone.Position = Part.Position
                                    Count += 1
                                end)
                            end
                        end
                    end
                end
            end
            if Count > 0 then
                DgNotify(nil, "已应用防裂纹（" .. Count .. " 个部件）")
            else
                DgNotify(nil, "未找到 Outline 部件")
            end
        end,
    })
    DalgonaGroup:AddToggle("DalgonaAutoAntiCrack", {
        Text = "自动防裂纹",
        Tooltip = "在糖饼游戏中持续应用防裂纹",
        Default = false,
        Callback = (function()
            local enabled = false
            local loop    = nil
            local function antiCrack()
                local Effects = workspace:FindFirstChild("Effects")
                if not Effects then return 0 end
                local Count = 0
                for _, Model in ipairs(Effects:GetChildren()) do
                    if Model.Name and Model.Name:find("Outline") then
                        for _, Part in ipairs(Model:GetDescendants()) do
                            if Part:IsA("BasePart") and Part.Name ~= "DalgonaClickPart" then
                                pcall(function()
                                    local Clone = Part:Clone()
                                    Clone.Name = "DalgonaClickPart"
                                    Clone.Parent = Part.Parent
                                    Clone.Size = Vector3.one
                                    Clone.Transparency = 1
                                    Clone.CanCollide = false
                                    Clone.Anchored = true
                                    Clone.Position = Part.Position
                                    Count += 1
                                end)
                            end
                        end
                    end
                end
                return Count
            end
            return function(Value)
                enabled = Value and true or false
                if loop then
                    pcall(function() task.cancel(loop) end)
                    loop = nil
                end
                if enabled then
                    loop = task.spawn(function()
                        while enabled do
                            if IsDalgonaGame() then
                                antiCrack()
                            end
                            task.wait(1)
                        end
                    end)
                    DgNotify(nil, "自动防裂纹 已启用")
                else
                    DgNotify(nil, "自动防裂纹 已禁用")
                end
            end
        end)(),
    })
    DalgonaGroup:AddToggle("DalgonaHitboxExpander", {
        Text = "糖饼 Hitbox 扩展器",
        Tooltip = "放大糖饼的 Hitbox（让点击更容易）",
        Default = false,
        Callback = (function()
            local enabled       = false
            local hitboxActive  = false
            local hitboxOriginals = {}
            local hitboxConnections = {}
            local hitboxLoop    = nil
            local function getHitboxModels()
                local Result = {}
                local Effects = ReplicatedStorage:FindFirstChild("Effects")
                if Effects then
                    local Games = Effects:FindFirstChild("Games")
                    if Games then
                        local DalgonaFolder = Games:FindFirstChild("Dalgona")
                        if DalgonaFolder then
                            for _, Model in ipairs(DalgonaFolder:GetChildren()) do
                                if (Model:IsA("Model") or Model:IsA("Folder")) and Model.Name:match("Outline$") then
                                    table.insert(Result, Model)
                                end
                            end
                        end
                    end
                end
                local WSEffects = workspace:FindFirstChild("Effects")
                if WSEffects then
                    for _, Model in ipairs(WSEffects:GetChildren()) do
                        if (Model:IsA("Model") or Model:IsA("Folder")) and Model.Name:match("Outline$") then
                            table.insert(Result, Model)
                        end
                    end
                end

                return Result
            end
            local function applyToModel(Model, Enable)
                local Count = 0
                for _, Part in ipairs(Model:GetDescendants()) do
                    if Part:IsA("BasePart") then
                        pcall(function()
                            if Enable then
                                if not hitboxOriginals[Part] then
                                    hitboxOriginals[Part] = {
                                        Size = Part.Size,
                                        Transparency = Part.Transparency,
                                        CanCollide = Part.CanCollide,
                                        Massless = Part.Massless,
                                    }
                                end
                                Part.Size = Vector3.new(5, 5, 5)
                                Part.Transparency = 1
                                Part.CanCollide = false
                                Part.Massless = true
                                Count += 1
                            elseif hitboxOriginals[Part] then
                                Part.Size = hitboxOriginals[Part].Size
                                Part.Transparency = hitboxOriginals[Part].Transparency
                                Part.CanCollide = hitboxOriginals[Part].CanCollide
                                Part.Massless = hitboxOriginals[Part].Massless
                                Count += 1
                            end
                        end)
                    end
                end
                return Count
            end
            local function enable()
                hitboxOriginals   = {}
                hitboxConnections = {}
                local Models = getHitboxModels()
                if #Models == 0 then
                    DgNotify(nil, "未找到 Outline 模型，请在糖饼游戏中启用")
                end
                for _, Model in ipairs(Models) do
                    applyToModel(Model, true)
                    local Conn = Model.DescendantAdded:Connect(function(Child)
                        if not hitboxActive then return end
                        task.delay(0.05, function()
                            if not hitboxActive then return end
                            pcall(function()
                                if Child:IsA("BasePart") then
                                    if not hitboxOriginals[Child] then
                                        hitboxOriginals[Child] = {
                                            Size = Child.Size,
                                            Transparency = Child.Transparency,
                                            CanCollide = Child.CanCollide,
                                            Massless = Child.Massless,
                                        }
                                    end
                                    Child.Size = Vector3.new(5, 5, 5)
                                    Child.Transparency = 1
                                    Child.CanCollide = false
                                    Child.Massless = true
                                elseif Child:IsA("Model") or Child:IsA("Folder") then
                                    applyToModel(Child, true)
                                end
                            end)
                        end)
                    end)
                    table.insert(hitboxConnections, Conn)
                end
                hitboxActive = true
                hitboxLoop = task.spawn(function()
                    while hitboxActive do
                        task.wait(0.5)
                        if hitboxActive then
                            local NewModels = getHitboxModels()
                            for _, Model in ipairs(NewModels) do
                                applyToModel(Model, true)
                            end
                        else
                            break
                        end
                    end
                end)
            end
            local function disable()
                hitboxActive = false
                if hitboxConnections then
                    for _, Conn in ipairs(hitboxConnections) do
                        pcall(function() Conn:Disconnect() end)
                    end
                    hitboxConnections = {}
                end
                if hitboxLoop then
                    pcall(function() task.cancel(hitboxLoop) end)
                    hitboxLoop = nil
                end
                for Part, Data in pairs(hitboxOriginals) do
                    pcall(function()
                        if Part and Part.Parent then
                            Part.Size = Data.Size
                            Part.Transparency = Data.Transparency
                            Part.CanCollide = Data.CanCollide
                            Part.Massless = Data.Massless
                        end
                    end)
                end
                hitboxOriginals = {}
            end
            return function(Value)
                enabled = Value and true or false
                if enabled then
                    enable()
                    DgNotify(nil, "Hitbox 扩展器 已启用")
                else
                    disable()
                    DgNotify(nil, "Hitbox 扩展器 已禁用")
                end
            end
        end)(),
    })
end
do
local DgPlayers     = game:GetService("Players")
local DgRS          = game:GetService("ReplicatedStorage")
local DgRS_         = game:GetService("RunService")
local DgWorkspace   = game:GetService("Workspace")
local DgTween       = game:GetService("TweenService")
local DgUIS         = game:GetService("UserInputService")
local dgLocalPlayer = DgPlayers.LocalPlayer
local function DgNotify(title, desc)
    pcall(function()
        Library:Notify({
            Title       = title or "AF Hub",
            Description = desc or "",
            Time        = 4,
        })
    end)
end
local function DgIsGame(name)
    local v = DgWorkspace:FindFirstChild("Values")
    v = v and v:FindFirstChild("CurrentGame")
    return v and v.Value == name
end
DalgonaGroup:AddButton({
    Text = "完成糖饼",
    Func = function()
        if not DgIsGame("Dalgona") then
            DgNotify(nil, "糖饼游戏未开始。")
            return
        end
        task.spawn(function()
            local currentCamera = DgWorkspace.CurrentCamera
            local function createFolder(parent, name, delay)
                local folder = Instance.new("Folder")
                folder.Name   = name
                folder.Parent = parent
                if delay then
                    task.delay(delay, function()
                        if folder and folder.Parent then folder:Destroy() end
                    end)
                end
                return folder
            end
            local function hideChar(ch)
                for _, d in pairs(ch:GetDescendants()) do
                    if d:IsA("BasePart") and d.Name ~= "HumanoidRootPart" then
                        d.Transparency = 1
                    end
                end
            end
            local function showChar(ch)
                for _, d in pairs(ch:GetDescendants()) do
                    if d:IsA("BasePart") and d.Name ~= "HumanoidRootPart" then
                        d.Transparency = 0
                        d.LocalTransparencyModifier = 0
                    end
                end
                for _, child in pairs(ch:GetChildren()) do
                    if child:IsA("Accessory") then
                        local handle = child:FindFirstChild("Handle")
                        if handle and handle.Transparency >= 0.99 then
                            handle.Transparency = 0
                        end
                    end
                end
            end
            local function showAllPlayers()
                for _, player in pairs(DgPlayers:GetPlayers()) do
                    if player.Character then showChar(player.Character) end
                end
            end
            local function complete()
                local character        = dgLocalPlayer.Character
                local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
                local humanoid         = character and character:FindFirstChild("Humanoid")
                local playerGui        = dgLocalPlayer:FindFirstChild("PlayerGui")
                local debrisBD         = dgLocalPlayer:FindFirstChild("DebrisBD")
                local effects          = DgWorkspace:FindFirstChild("Effects")
                local impactFrames     = playerGui and playerGui:FindFirstChild("ImpactFrames")
                if not (character and humanoidRootPart and humanoid) then return end
                local fieldOfView = currentCamera.FieldOfView
                local shape, outline, pick, redDot
                if effects then
                    for _, child in pairs(effects:GetChildren()) do
                        if child:IsA("Model") and child.Name:match("Outline$") then
                            outline = child
                        elseif child:IsA("Model") and not child.Name:match("Outline$")
                            and child.Name ~= "Pick" and child.Name ~= "RedDot" then
                            shape = child
                        elseif child.Name == "Pick" then
                            pick = child
                        elseif child.Name == "RedDot" then
                            redDot = child
                        end
                    end
                end
                local progressBar = impactFrames and impactFrames:FindFirstChild("ProgressBar")
                local pickModel = nil
                if impactFrames then
                    for _, child in pairs(impactFrames:GetChildren()) do
                        if child:IsA("ViewportFrame") and child:FindFirstChild("PickModel") then
                            pickModel = child.PickModel
                            break
                        end
                    end
                end
                local remote = DgRS:WaitForChild("Remotes"):WaitForChild("DALGONATEMPREMPTE")
                local flagRunning = true
                local conn
                task.spawn(function()
                    createFolder(dgLocalPlayer, "RecentGameStartedMessage", 0.01)
                    if shape and shape:FindFirstChild("shape") then
                        DgTween:Create(shape.shape,
                            TweenInfo.new(2, Enum.EasingStyle.Quad),
                            { Position = shape.shape.Position + Vector3.new(0, 0.5, 0) }):Play()
                    end
                    if shape then
                        for _, child in pairs(shape:GetChildren()) do
                            if child.Name == "DalgonaClickPart" and child:IsA("BasePart") then
                                DgTween:Create(child, TweenInfo.new(2, Enum.EasingStyle.Quad),
                                    { Transparency = 1 }):Play()
                            end
                        end
                    end
                    for _, model in pairs({ pick, redDot, pickModel }) do
                        if model and model.Parent then
                            for _, d in pairs(model:GetDescendants()) do
                                if d:IsA("BasePart") then
                                    pcall(function()
                                        DgTween:Create(d, TweenInfo.new(2, Enum.EasingStyle.Quad),
                                            { Transparency = 1 }):Play()
                                    end)
                                end
                            end
                        end
                    end
                    if humanoidRootPart then
                        DgTween:Create(currentCamera, TweenInfo.new(2, Enum.EasingStyle.Quad), {
                            CFrame = humanoidRootPart.CFrame * CFrame.new(
                                0.0841674805, 8.45438766, 6.69675446,
                                0.999918401, -0.00898250192, 0.00907994807,
                                3.31699681e-08, 0.710912943, 0.703280032,
                                -0.0127722733, -0.703222632, 0.710854948)
                        }):Play()
                    end
                    hideChar(character)
                    remote:FireServer({ Success = true })
                    task.wait(2)
                    for _, v in pairs({ shape, outline, pick, redDot, progressBar }) do
                        if v and v.Parent then v:Destroy() end
                    end
                    DgUIS.MouseIconEnabled = true
                    if playerGui and playerGui:FindFirstChild("Hotbar")
                        and playerGui.Hotbar:FindFirstChild("Backpack") then
                        DgTween:Create(playerGui.Hotbar.Backpack,
                            TweenInfo.new(1.5, Enum.EasingStyle.Circular, Enum.EasingDirection.InOut),
                            { Position = UDim2.new(0, 0, 0, 0) }):Play()
                    end
                    if progressBar then
                        if debrisBD then debrisBD:Fire(progressBar, 2) end
                        DgTween:Create(progressBar,
                            TweenInfo.new(1.5, Enum.EasingStyle.Circular, Enum.EasingDirection.InOut),
                            { Position = UDim2.new(
                                progressBar.Position.X.Scale, 0,
                                progressBar.Position.Y.Scale + 1, 0) }):Play()
                    end
                    task.wait(0.5)
                    flagRunning = false
                    if playerGui then
                        local dalgonaUI = playerGui:FindFirstChild("DalgonaUI")
                        if dalgonaUI then dalgonaUI:Destroy() end
                        local impactFrames2 = playerGui:FindFirstChild("ImpactFrames")
                        if impactFrames2 then
                            local vpf = impactFrames2:FindFirstChild("ViewportFrameLighter")
                            if vpf and vpf:FindFirstChild("WorldModel")
                                and vpf.WorldModel:FindFirstChild("Lighter") then
                                vpf.WorldModel.Lighter:Destroy()
                            end
                        end
                    end
                    currentCamera.CameraType = Enum.CameraType.Custom
                    if humanoid then currentCamera.CameraSubject = humanoid end
                    currentCamera.FieldOfView = fieldOfView or 70
                end)
                conn = DgRS_.RenderStepped:Connect(function()
                    if not flagRunning then conn:Disconnect() return end
                    if currentCamera.CameraType == Enum.CameraType.Scriptable then
                        currentCamera.CameraType = Enum.CameraType.Custom
                    end
                    if humanoid and currentCamera.CameraSubject ~= humanoid then
                        currentCamera.CameraSubject = humanoid
                    end
                end)
            end
            local function toggleRemotes()
                if dgLocalPlayer.Character and dgLocalPlayer.Character:FindFirstChild("Remotes") then
                    local remotes = dgLocalPlayer.Character:FindFirstChild("Remotes")
                    pcall(function() remotes.Disabled = true end)
                    task.wait(0.5)
                    pcall(function() remotes.Disabled = false end)
                end
            end
            local remote = DgRS:WaitForChild("Remotes"):FindFirstChild("DALGONATEMPREMPTE")
            if not remote then return end
            remote:FireServer({ Completed = true })
            remote:FireServer({ Success   = true })
            complete()
            toggleRemotes()
            task.spawn(function()
                repeat
                    task.wait(1)
                    showAllPlayers()
                until not DgRS:WaitForChild("Remotes"):FindFirstChild("DALGONATEMPREMPTE")
                DgNotify(nil, "糖饼已完成")
                task.spawn(function()
                    local t = tick() + 10
                    while tick() < t do
                        local playerGui = dgLocalPlayer:FindFirstChild("PlayerGui")
                        if playerGui then
                            local dalgonaUI = playerGui:FindFirstChild("DalgonaUI")
                            if dalgonaUI then dalgonaUI:Destroy() end
                        end
                        task.wait(0.5)
                    end
                end)
            end)
        end)
    end,
})
end
do
local c, cache
c, cache = nil, {}
DalgonaGroup:AddToggle("Dalgona_OneClick", {
    Text = "一键完成",
    Default = false,
    Callback = function(on)
        tbl.oneClickDalgonaEnabled = on
        if on then
            if not c then
                c = RunService.RenderStepped:Connect(function()
                    if not tbl.oneClickDalgonaEnabled then return end
                    if not fn12("Dalgona") then
                        if next(cache) then
                            for k, v in pairs(cache) do
                                if k.Parent then k.Position = v.Position; k.Transparency = v.Transparency end
                            end
                            table.clear(cache)
                        end
                        return
                    end
                    pcall(function()
                        local mouse = localPlayer:GetMouse()
                        if not mouse or not mouse.Hit then return end
                        local eff = workspace:FindFirstChild("Effects")
                        local outline
                        if eff then
                            for _, x in pairs(eff:GetChildren()) do
                                if x:IsA("Model") and string.match(x.Name, "Outline$") then outline = x; break end
                            end
                        end
                        if not outline then
                            for _, x in pairs(workspace:GetChildren()) do
                                if x:IsA("Model") and string.match(x.Name, "Outline$") then outline = x; break end
                            end
                        end
                        if outline then
                            local pos = mouse.Hit.Position
                            for _, ch in ipairs(outline:GetChildren()) do
                                if ch:IsA("BasePart") and not ch:GetAttribute("Done") then
                                    if not cache[ch] then
                                        cache[ch] = { Position = ch.Position, Transparency = ch.Transparency }
                                    end
                                    ch.Position = pos
                                    ch.Transparency = 1
                                end
                            end
                        end
                    end)
                end)
            end
        else
            if c then c:Disconnect(); c = nil end
            for k, v in pairs(cache) do
                if k.Parent then k.Position = v.Position; k.Transparency = v.Transparency end
            end
            table.clear(cache)
        end
    end,
})
end
do
local thread = nil
DalgonaGroup:AddToggle("Dalgona_AutoRelax", {
    Text = "自动放松",
    Default = false,
    Callback = function(on)
        tbl.autoRelaxEnabled = on
        if on and not thread then
            thread = task.spawn(function()
                tbl3.lastRelaxTime = 0
                while tbl.autoRelaxEnabled do
                    if fn12("Dalgona") then
                        local need = getStressLevel() > 0 and (tick() - tbl3.lastRelaxTime >= 2.1)
                        if need then fn14("q"); tbl3.lastRelaxTime = tick() end
                    end
                    task.wait(1)
                end
                thread = nil
            end)
        end
    end,
})
end
tbl2.dalgonaQteThread = nil
DalgonaGroup:AddToggle("Dalgona_QTE", {
Text = "自动QTE事件（糖饼）",
Default = false,
Callback = function(on)
    tbl.dalgonaQteEnabled = on
    if on and not tbl2.dalgonaQteThread then
        tbl2.dalgonaQteThread = task.spawn(function()
            local seen = {}
            while tbl.dalgonaQteEnabled do
                if fn12("Dalgona") then
                    local m = fn15()
                    if m and m.ActiveButtons then
                        for k, a in pairs(m.ActiveButtons) do
                            if not seen[k] and a then
                                seen[k] = true
                                task.delay(0.01, function()
                                    if tbl.dalgonaQteEnabled and fn12("Dalgona") and m.ActiveButtons[k] then
                                        pcall(function() m.Pressed(false, m.ActiveButtons[k]) end)
                                    end
                                end)
                            end
                        end
                        for k in pairs(seen) do if not m.ActiveButtons[k] then seen[k] = nil end end
                    end
                else table.clear(seen) end
                task.wait(0.05)
            end
            tbl2.dalgonaQteThread = nil
        end)
    end
end,
})
local LighterState = {
enabled = false,
GamePass = false,
}
DalgonaGroup:AddToggle("FreeLighter", {
Text = "免费打火机",
Tooltip = "给玩家开启 HasLighter 属性，在 Dalgona 中使用打火机",
Default = false,
Callback = function(Value)
    LighterState.enabled  = Value and true or false
    LighterState.GamePass = Value and true or false
    MainModule.GamePassStates.Lighter = LighterState.GamePass
    MainModule.LighterEnabled         = LighterState.enabled
    localPlayer:SetAttribute("HasLighter", LighterState.enabled)
    PlayToggleSound()
    if LighterState.enabled then
        if MainModule.is_game_active("Dalgona") then
            localPlayer2:SetAttribute("HasLighter", true)
            PlayBell()
        else
            notify("Dalgona", "Wait for Dalgona!", 0.9)
            PlayErrorSound()
        end
    end
end,
})
local AutoRelaxState = {
enabled = false,
conn    = nil,
last    = 0,
}
DalgonaGroup:AddToggle("AutoRelaxBreathing", {
Text = "自动呼吸",
Tooltip = "自动按 Q 呼吸降低恐惧值（避开失败区间，5 秒冷却）",
Default = false,
Callback = function(Value)
    AutoRelaxState.enabled = Value and true or false
    if AutoRelaxState.conn then
        AutoRelaxState.conn:Disconnect()
        AutoRelaxState.conn = nil
    end
    if AutoRelaxState.enabled then
        AutoRelaxState.last = 0
        AutoRelaxState.conn = RunService.Heartbeat:Connect(function()
            if not AutoRelaxState.enabled then return end
            if tick() - AutoRelaxState.last < 5 then return end
            local playerGui = localPlayer:FindFirstChild("PlayerGui")
            if not playerGui then return end
            local dalgonaUI = playerGui:FindFirstChild("DalgonaUI")
            if not dalgonaUI then return end
            local breathing = dalgonaUI:FindFirstChild("Breathing")
            if not breathing or not breathing.Visible then return end
            local breath = breathing:FindFirstChild("Breath")
            if not breath then return end
            local crackProgressBar = breathing:FindFirstChild("CrackProgressBar")
            if not crackProgressBar then return end
            local chanceShadow = crackProgressBar:FindFirstChild("ChanceShadow")
            chanceShadow = chanceShadow and chanceShadow:FindFirstChild("Chance")
            local n = tonumber((chanceShadow and chanceShadow.Text or "0%"):match("(%d+)")) or 0
            if n <= 0 or n >= 95 then return end

            pcall(function()
                firesignal(breath.MouseButton1Click)
            end)
            AutoRelaxState.last = tick()
        end)
    end
    PlayToggleSound()
end,
})
DalgonaGroup:AddButton({
Text = "防破裂",
Tooltip = "修复/创建 Outline 上的 DalgonaClickPart，防止裂开",
Func = function()
    local effects = workspace:FindFirstChild("Effects")
    if effects then
        for _, child in ipairs(effects:GetChildren()) do
            if child.Name and child.Name:find("Outline") then
                for _, descendant in ipairs(child:GetDescendants()) do
                    if descendant:IsA("BasePart") and descendant.Name ~= "DalgonaClickPart" then
                        pcall(function()
                            local clone = descendant:Clone()
                            clone.Name = "DalgonaClickPart"
                            clone.Parent = descendant.Parent
                            clone.Size = Vector3.one
                            clone.Transparency = 1
                            clone.CanCollide = false
                            clone.Anchored = true
                            clone.Position = descendant.Position
                        end)
                    end
                end
            end
        end
    end
    PlayToggleSound()
    notify("Dalgona", "Anti Crack 已执行", 1)
end,
})
--拔河
tbl.tugOfWarAutoPullEnabled = false
tbl.tugOfWarPullHelperEnabled = false
tbl2.tugOfWarAutoPullThread = nil
do
local busy = false
local function angleDiff(a,b) return math.abs((a-b+180)%360-180) end
local function doPress() fn14("space") end
local function worker()
    if busy then return end
    busy = true
    local pg = localPlayer:FindFirstChild("PlayerGui")
    if not pg then busy=false; return end
    local ui = pg:WaitForChild("TugOfWarUIV2", 5); if not ui then busy=false; return end
    local remake = ui:FindFirstChild("TugofWarRemake"); if not remake then busy=false; return end
    local circle = remake:FindFirstChild("CircleBase"); if not circle then busy=false; return end
    while true do
        if tbl.tugOfWarAutoPullEnabled or tbl.tugOfWarPullHelperEnabled then
            local phase = nil
            pcall(function() phase = localPlayer:GetAttribute("TugOfWarPhase") end)
            if phase == "QTE" then break end
            task.wait(0.1)
        else break end
    end
    if not (tbl.tugOfWarAutoPullEnabled or tbl.tugOfWarPullHelperEnabled) then busy=false; return end
    if not circle.Visible then
        local t = tick()
        while (tbl.tugOfWarAutoPullEnabled or tbl.tugOfWarPullHelperEnabled) and not circle.Visible and tick()-t < 10 do
            task.wait(0.1)
        end
    end
    if not (tbl.tugOfWarAutoPullEnabled or tbl.tugOfWarPullHelperEnabled) then busy=false; return end

    local arrow = circle:FindFirstChild("Arrow"); if not arrow then busy=false; return end
    local med = circle:FindFirstChild("Medium") or circle:FindFirstChild("Small") or circle:FindFirstChild("Large")
    if not med then busy=false; return end
    local window = (localPlayer:GetAttribute("TugOfWarStrategy") or "Standard") == "Stall" and 14 or 18.2
    local lastPress = 0
    local minInterval = 0.12
    local wasIn = false
    local c1, c2
    local function stop()
        if c1 then c1:Disconnect(); c1 = nil end
        if c2 then c2:Disconnect(); c2 = nil end
        busy = false
    end
    c2 = localPlayer.ChildAdded:Connect(function(x) if x.Name == "QTEOver" then stop() end end)
    c1 = RunService.RenderStepped:Connect(function()
        if not arrow or not arrow.Parent or not circle.Visible then stop(); return end
        if not (tbl.tugOfWarAutoPullEnabled or tbl.tugOfWarPullHelperEnabled) then stop(); return end
        if not fn12("TugOfWar") then stop(); return end
        local rot = arrow.Rotation % 360
        local inZone = angleDiff(med.Rotation % 360, rot) <= window
        if tbl.tugOfWarPullHelperEnabled then med.Rotation = rot; inZone = true end
        if tbl.tugOfWarAutoPullEnabled then
            if tbl.tugOfWarPullHelperEnabled then
                if tick()-lastPress > 0.25 then doPress(); lastPress = tick() end
            else
                local fire = inZone and not wasIn
                if fire then fire = tick()-lastPress > minInterval end
                if fire then doPress(); lastPress = tick() end
            end
        end
        wasIn = inZone
    end)
    task.spawn(function()
        while busy and (tbl.tugOfWarAutoPullEnabled or tbl.tugOfWarPullHelperEnabled) and fn12("TugOfWar") do
            task.wait(1)
        end
        stop()
    end)
end
local function tickLoop()
    if tbl.tugOfWarAutoPullEnabled or tbl.tugOfWarPullHelperEnabled then
        if tbl2.tugOfWarAutoPullThread then return end
        tbl2.tugOfWarAutoPullThread = true
        task.spawn(function()
            while tbl.tugOfWarAutoPullEnabled or tbl.tugOfWarPullHelperEnabled do
                if fn12("TugOfWar") then pcall(worker) end
                task.wait(1)
            end
            tbl2.tugOfWarAutoPullThread = nil
        end)
    else tbl2.tugOfWarAutoPullThread = nil end
end
TugGroup:AddToggle("Tug_AutoPull", {
    Text = "自动拉",
    Default = false,
    Callback = function(on) tbl.tugOfWarAutoPullEnabled = on; tickLoop() end,
})
TugGroup:AddToggle("Tug_PullHelper", {
    Text = "拉拽辅助",
    Default = false,
    Callback = function(on) tbl.tugOfWarPullHelperEnabled = on; tickLoop() end,
})
end
TugGroup:AddLabel("下面拔河均为未测试功能，谨慎使用", true)
do
    local Players           = game:GetService("Players")
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local UserInputService  = game:GetService("UserInputService")
    local RunService        = game:GetService("RunService")
    local LocalPlayer       = Players.LocalPlayer
    local function PlayToggleSound() end
    local function notify(title, text, duration)
        Library:Notify({
            Title       = tostring(title),
            Description = tostring(text or ""),
            Time        = tonumber(duration) or 2,
        })
    end
    local function GetHBGQTE()
        local ok, mod = pcall(function()
            return require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("HBGQTE"))
        end)
        if ok then return mod end
        return nil
    end
    local function GetTugOfWarUI()
        local PlayerGui = LocalPlayer:FindFirstChild("PlayerGui")
        if not PlayerGui then return nil end
        local UI = PlayerGui:FindFirstChild("TugOfWarUIV2")
            or PlayerGui:FindFirstChild("TugOfWarUI")
            or PlayerGui:FindFirstChild("TugofWarRemake")
        if UI then return UI end
        local RS_UI = ReplicatedStorage:FindFirstChild("UI")
        if RS_UI then
            local Clone = RS_UI:FindFirstChild("TugOfWarUIV2")
                or RS_UI:FindFirstChild("TugOfWarUI")
            if Clone then
                local Cloned = Clone:Clone()
                Cloned.Parent = PlayerGui
                return Cloned
            end
        end
        return nil
    end
    local function GetCircleBase()
        local PlayerGui = LocalPlayer:FindFirstChild("PlayerGui")
        if not PlayerGui then return nil end
        local UI = PlayerGui:FindFirstChild("TugOfWarUIV2")
            or PlayerGui:FindFirstChild("TugOfWarUI")
            or PlayerGui:FindFirstChild("TugofWarRemake")
        if not UI then return nil end
        local Remake = UI:FindFirstChild("TugofWarRemake") or UI
        Remake = Remake and Remake:FindFirstChild("CircleBase")
        if Remake and Remake.Visible then
            return Remake
        end
        return nil
    end
    local function GetTugOfWarElements()
        local PlayerGui = LocalPlayer:FindFirstChild("PlayerGui")
        if not PlayerGui then return nil, nil, nil end
        local UI = PlayerGui:FindFirstChild("TugOfWarUIV2")
            or PlayerGui:FindFirstChild("TugofWarRemake")
        if not UI then return nil, nil, nil end
        local Circle = UI:FindFirstChild("CircleBase", true)
        if not Circle or not Circle.Visible then
            return nil, nil, nil
        end
        return Circle,
            Circle:FindFirstChild("Arrow", true),
            Circle:FindFirstChild("Medium", true)
                or Circle:FindFirstChild("Small", true)
                or Circle:FindFirstChild("Large", true)
    end
    local function IsInGreenZone(Arrow, Zone)
        if not Arrow or not Zone then return false end
        local Delta = (Zone.Rotation - Arrow.Rotation + 180) % 360 - 180
        local Tolerance = Zone.Name == "Small" and 20
            or Zone.Name == "Large" and 32
            or 26
        return math.abs(Delta) <= Tolerance
    end
    local function SimulatePullInput()
        if UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled then
            pcall(function()
                local VIM = game:GetService("VirtualInputManager")
                local Res = game:GetService("GuiService"):GetScreenResolution()
                VIM:SendTouchEvent(Res.X / 2, Res.Y / 2, 0, Enum.UserInputState.Begin, game)
                task.wait(0.03)
                VIM:SendTouchEvent(Res.X / 2, Res.Y / 2, 0, Enum.UserInputState.End, game)
            end)
        else
            pcall(function()
                keypress(32)
                task.wait(0.03)
                keyrelease(32)
            end)
        end
    end
    local IsMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
    do
        local enabled = false
        local conn    = nil
        TugGroup:AddToggle("AntiMissToggle", {
            Text = "反失误（指针永远在绿区）",
            Tooltip = "把指针强制停在绿色区域内，永远不会失误",
            Default = false,
            Callback = function(Value)
                enabled = Value and true or false
                if conn then
                    conn:Disconnect()
                    conn = nil
                end
                if enabled then
                    conn = RunService.RenderStepped:Connect(function()
                        if not enabled then return end
                        if LocalPlayer:GetAttribute("TugOfWarPhase") ~= "QTE" then return end
                        local Circle = GetCircleBase()
                        if not Circle then return end
                        local Arrow  = Circle:FindFirstChild("Arrow")
                        local Medium = Circle:FindFirstChild("Medium")
                        if not (Arrow and Medium) then return end
                        Medium.Rotation = Arrow.Rotation
                    end)
                end
                PlayToggleSound()
            end,
        })
    end
    TugGroup:AddDropdown("TugOfWarMode", {
        Values = { "正规", "狂暴" },
        Default = 1,
        Multi = false,
        Text = "模式",
        Tooltip = "正规 - 默认拉绳 | 狂暴 - 反失误 + 快速拉绳",
        Callback = function(Value)
            if Value == "狂暴" then
                if Options.AntiMissToggle and not Options.AntiMissToggle.Value then
                    Options.AntiMissToggle:SetValue(true)
                end
            end
        end,
    })
    do
        local enabled = false
        local ui      = nil
        TugGroup:AddToggle("TugOfWarQTE", {
            Text = "拔河 QTE 模式",
            Tooltip = "启用拔河的 QTE 模式",
            Default = false,
            Callback = function(Value)
                enabled = Value and true or false
                if ui then
                    pcall(function() ui:Destroy() end)
                    ui = nil
                end
                if enabled then
                    LocalPlayer:SetAttribute("TugOfWarPhase", "QTE")
                    workspace:SetAttribute("TugOfWarRhythmGoal", 180)
                    workspace:SetAttribute("TugOfWarRush", nil)
                    local newUI = GetTugOfWarUI()
                    if newUI then
                        newUI.Enabled = true
                        ui = newUI
                        local Handler = newUI:FindFirstChild("TugOfWarQTEHandler", true)
                            or newUI:FindFirstChildWhichIsA("LocalScript", true)
                            or newUI:FindFirstChildWhichIsA("Script", true)
                        if Handler and Handler:IsA("LocalScript") then
                            Handler.Disabled = false
                        end
                    end
                    task.wait(0.3)
                    LocalPlayer:SetAttribute("TugOfWarPhase", "QTE")
                    notify("拔河", "QTE 模式已启用")
                else
                    notify("拔河", "QTE 模式已禁用")
                end
                PlayToggleSound()
            end,
        })
    end
end
do
local conns = {}
local dodgeIds = {
    "105341857343164","88451099342711","79649041083405","73242877658272",
    "114928327045353","135690448001690","103355259844069","125906547773381",
    "121147456137931","96924216250322","116839849594540","104041807075625",
    "83057176809194","103318207627541","121473077508383","94215646393565",
    "81533666958052",
}
local lastDodge = 0
local function clear()
    for _, c in ipairs(conns) do if c then c:Disconnect() end end
    table.clear(conns)
end
local function tryDodge(track, hrp)
    if not tbl.autoDodgeEnabled or not fn12("HideAndSeek") then return end
    if tick() - lastDodge < 0.8 then return end
    if not track.Animation then return end
    local aid = track.Animation.AnimationId
    local match = false
    for _, id in ipairs(dodgeIds) do if string.find(aid, id, 1, true) then match = true; break end end
    if not match then return end
    local ch = localPlayer.Character
    local myHrp = ch and ch:FindFirstChild("HumanoidRootPart")
    if not myHrp or not hrp then return end
    local d1 = (myHrp.Position - hrp.Position).Magnitude
    local d2 = (myHrp.Position + myHrp.Velocity*0.7 - hrp.Position + hrp.Velocity*0.7).Magnitude
    local gain = d1 - d2
    local facing = hrp.CFrame.LookVector:Dot((myHrp.Position - hrp.Position).Unit)
    local threshold = 10
    local hum = hrp.Parent and hrp.Parent:FindFirstChild("Humanoid")
    if hum then
        local an = hum:FindFirstChild("Animator")
        if an then
            for _, t in ipairs(an:GetPlayingAnimationTracks()) do
                local id = t.Animation and t.Animation.AnimationId
                if id then
                    if string.find(id, "76367328603905") then threshold = 20; break
                    elseif string.find(id, "71214385249268") then threshold = 14; break end
                end
            end
        end
    end
    if math.abs(myHrp.Position.Y - hrp.Position.Y) > 12 then return end
    local ok = false
    if d1 <= 10 then ok = true end
    if not ok and d2 <= threshold and gain > -3 then ok = true end
    if not ok and d1 <= 20 and gain > 2 then ok = true end
    if ok then
        if gain < -8 and d1 > 8 then ok = false end
        if d1 > 14 and facing < -0.4 then ok = false end
    end
    if not ok then return end
    local rp = RaycastParams.new()
    rp.FilterDescendantsInstances = { ch, hrp.Parent }
    rp.FilterType = Enum.RaycastFilterType.Exclude
    local hit = Workspace:Raycast(myHrp.Position, hrp.Position - myHrp.Position, rp)
    if hit then return end

    local dodge = localPlayer.Backpack:FindFirstChild("DODGE!") or ch:FindFirstChild("DODGE!")
    if dodge then
        pcall(function()
            local pack = { dodge }
            local buf = { buffer.create(0), pack }
            ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("UsedTool"):FireServer(unpack(buf))
            local pg = localPlayer:FindFirstChild("PlayerGui")
            local key = nil
            if pg then
                for _, d in ipairs(pg:GetDescendants()) do
                    if (d:IsA("TextLabel") or d:IsA("TextButton")) and d.Text == "DODGE!" and d.Parent then
                        for _, s in ipairs(d.Parent:GetChildren()) do
                            if s ~= d and (s:IsA("TextLabel") or s:IsA("TextButton")) then
                                local t = string.upper(tostring(s.Text))
                                if tonumber(t) or t == "E" or t == "T" or t == "Y" then key = tostring(s.Text); break end
                            end
                        end
                        if key then break end
                    end
                end
            end
            if not key then
                local bp = localPlayer:FindFirstChild("Backpack")
                if bp then
                    local idx = 1
                    for _, c in ipairs(bp:GetChildren()) do
                        if c:IsA("Tool") then
                            if c.Name == "DODGE!" then key = tostring(idx); break else idx += 1 end
                        end
                    end
                end
            end
            if key then
                lastDodge = tick()
                fn14(tostring(key))
                task.wait(0.05)
                fn14(tostring(key))
            end
        end)
    end
end
local function watch(p)
    if p == localPlayer then return end
    local function onChar(ch)
        task.wait(0.5)
        if not p:GetAttribute("IsHunter") then return end
        local hum = ch:FindFirstChild("Humanoid")
        local hrp = ch:FindFirstChild("HumanoidRootPart")
        if hum and hrp then
            local an = hum:FindFirstChild("Animator")
            if an then
                table.insert(conns, an.AnimationPlayed:Connect(function(t) tryDodge(t, hrp) end))
            end
        end
    end
    if p.Character then task.spawn(onChar, p.Character) end
    table.insert(conns, p.CharacterAdded:Connect(onChar))
    table.insert(conns, p:GetAttributeChangedSignal("IsHunter"):Connect(function()
        if p.Character then task.spawn(onChar, p.Character) end
    end))
end
HSTOWGroup:AddToggle("HSTOW_AutoDodge", {
    Text = "自动闪避",
    Default = false,
    Callback = function(on)
        tbl.autoDodgeEnabled = on
        clear()
        if on then
            for _, p in ipairs(Players:GetPlayers()) do watch(p) end
            table.insert(conns, Players.PlayerAdded:Connect(watch))
        end
    end,
})
end
--拔河2
do
    local GamePlayers = game:GetService("Players")
    local RepStore = game:GetService("ReplicatedStorage")
    local GameWorld = game:GetService("Workspace")
    local FrameService = game:GetService("RunService")

    local Me = GamePlayers.LocalPlayer
    local MeAlias = Me

    local function toggleSound() end
    local function errorSound() end
    local function bellSound() end

    local function pushNotice(header, body, seconds)
        Library:Notify({
            Title = tostring(header),
            Description = tostring(body or ""),
            Time = tonumber(seconds) or 0.9,
        })
    end

    local function runSafely(callback, ...)
        if type(callback) ~= "function" then
            return
        end

        local packed = table.pack(...)
        task.spawn(function()
            pcall(callback, table.unpack(packed, 1, packed.n))
        end)
    end

    if not firesignal then
        function firesignal(signal)
            if not getconnections then
                return
            end

            for _, link in ipairs(getconnections(signal)) do
                pcall(function()
                    link:Fire()
                end)
            end
        end
    end

    local TugQTE = nil
    pcall(function()
        TugQTE = require(
            RepStore:WaitForChild("Modules", 5):WaitForChild("HBGQTE", 5)
        )
    end)

    local function getCircleBase()
        local guiRoot = Me:FindFirstChild("PlayerGui")
        if not guiRoot then
            return nil
        end

        local root =
            guiRoot:FindFirstChild("TugOfWarUIV2")
            or guiRoot:FindFirstChild("TugOfWarUI")
            or guiRoot:FindFirstChild("TugofWarRemake")

        if not root then
            return nil
        end

        root = root:FindFirstChild("TugofWarRemake") or root
        local circle = root and root:FindFirstChild("CircleBase")

        if circle and circle.Visible then
            return circle
        end

        return nil
    end

    local function getOrMakeTugGui()
        local guiRoot = MeAlias:FindFirstChild("PlayerGui")
        if not guiRoot then
            return nil
        end

        local current =
            guiRoot:FindFirstChild("TugOfWarUIV2")
            or guiRoot:FindFirstChild("TugOfWarUI")
            or guiRoot:FindFirstChild("TugofWarRemake")

        if current then
            return current
        end

        local uiFolder = RepStore:FindFirstChild("UI")
        if not uiFolder then
            return nil
        end

        local template =
            uiFolder:FindFirstChild("TugOfWarUIV2")
            or uiFolder:FindFirstChild("TugOfWarUI")

        if not template then
            return nil
        end

        local copy = template:Clone()
        copy.Parent = guiRoot
        return copy
    end


    do
        local active = false
        local renderLink

        TugGroup2:AddToggle("AntiMissQTE", {
            Text = "防失误",
            Tooltip = "每帧强制 Medium = Arrow，永不失误",
            Default = false,

            Callback = function(state)
                active = state and true or false

                if renderLink then
                    renderLink:Disconnect()
                    renderLink = nil
                end

                if active then
                    renderLink = FrameService.RenderStepped:Connect(function()
                        if not active then
                            return
                        end

                        if Me:GetAttribute("TugOfWarPhase") ~= "QTE" then
                            return
                        end

                        local circle = getCircleBase()
                        if not circle then
                            return
                        end

                        local arrow = circle:FindFirstChild("Arrow")
                        local medium = circle:FindFirstChild("Medium")

                        if not arrow or not medium then
                            return
                        end

                        medium.Rotation = arrow.Rotation
                    end)
                end

                toggleSound()
            end,
        })
    end


    do
        local active = false
        local pulseConnection
        local entered = false
        local enteredAt = 0
        local delayBeforePress = 0.02

        local function locateQTE()
            local guiRoot = Me:FindFirstChild("PlayerGui")
            if not guiRoot then
                return nil
            end

            local function search(node, level)
                if level > 8 then
                    return nil
                end

                local circle = node:FindFirstChild("CircleBase")
                if circle then
                    return circle
                end

                for _, child in ipairs(node:GetChildren()) do
                    if child:IsA("ScreenGui")
                        or child:IsA("Frame")
                        or child:IsA("ImageLabel") then

                        local found = search(child, level + 1)
                        if found then
                            return found
                        end
                    end
                end

                return nil
            end

            local circle = search(guiRoot, 0)
            if not circle then
                return nil
            end

            local arrow = circle:FindFirstChild("Arrow")
            local medium = circle:FindFirstChild("Medium")

            if not arrow or not medium then
                return nil
            end

            return {
                circleBase = circle,
                arrow = arrow,
                medium = medium,
                btn =
                    circle:FindFirstChild("TextButton")
                    or circle:FindFirstChildWhichIsA("TextButton")
                    or (circle.Parent and circle.Parent:FindFirstChild("TextButton")),
            }
        end

        local function pressButton(button)
            if not button then
                return
            end

            pcall(function()
                if firesignal then
                    firesignal(button.MouseButton1Click)
                end
                collectgarbage()
            end)
        end

        local function getAngleWindow()
            local mode = Me:GetAttribute("TugOfWarStrategy") or "Standard"
            return mode == "Stall" and 20 or 26
        end

        local function updateAutoPull()
            if not active then
                return
            end

            local qte = locateQTE()
            if not qte then
                return
            end

            if not qte.circleBase.Visible then
                entered = false
                enteredAt = 0
                return
            end

            local currentTime = tick()
            local delta = math.abs(
                (qte.medium.Rotation - qte.arrow.Rotation + 180) % 360 - 180
            )

            local inside = delta <= getAngleWindow()

            if inside and not entered then
                entered = true
                enteredAt = currentTime
            elseif not inside and entered then
                entered = false
                enteredAt = 0
            end

            if entered and delayBeforePress <= currentTime - enteredAt then
                pressButton(qte.btn)
                entered = false
                enteredAt = 0
            end
        end

        TugGroup2:AddToggle("AutoPullQTE", {
            Text = "自动拉拽",
            Tooltip = "进入判定区 0.02s 后自动点击。Standard 判定 ±26°，Stall 判定 ±20°",
            Default = false,

            Callback = function(state)
                active = state and true or false

                if pulseConnection then
                    pcall(function()
                        pulseConnection:Disconnect()
                    end)
                    pulseConnection = nil
                end

                entered = false
                enteredAt = 0

                if active then
                    pulseConnection = FrameService.Heartbeat:Connect(function()
                        task.wait(0.016)
                        updateAutoPull()
                    end)
                end

                toggleSound()
            end,
        })
    end


    do
        local active = false
        local qteConnection

        local lastBase
        local lastArrow
        local lastMedium
        local lastButton

        local function readCache()
            local circle = getCircleBase()

            if circle ~= lastBase then
                lastBase = circle
                lastArrow = circle and circle:FindFirstChild("Arrow")
                lastMedium = circle and circle:FindFirstChild("Medium")
                lastButton = circle and circle:FindFirstChild("TextButton")
            end

            return lastBase, lastArrow, lastMedium, lastButton
        end

        local function resetCache()
            lastBase = nil
            lastArrow = nil
            lastMedium = nil
            lastButton = nil
        end

        TugGroup2:AddToggle("UltraFastPullQTE", {
            Text = "狂暴拔河(反制AX拔河)",
            Tooltip = "高速同步 + 立即点击",
            Default = false,

            Callback = function(state)
                active = state == true

                if qteConnection then
                    pcall(function()
                        qteConnection:Disconnect()
                    end)
                    qteConnection = nil
                end

                resetCache()

                if not active then
                    toggleSound()
                    return
                end

                qteConnection = FrameService.RenderStepped:Connect(function()
                    if not active then
                        return
                    end

                    if Me:GetAttribute("TugOfWarPhase") ~= "QTE" then
                        return
                    end

                    local circle, arrow, medium, button = readCache()

                    if not circle or not circle.Visible then
                        return
                    end

                    if not arrow or not medium or not button then
                        return
                    end

                    medium.Rotation = arrow.Rotation

                    pcall(function()
                        firesignal(button.MouseButton1Click)
                    end)
                end)

                toggleSound()
            end,
        })
    end


    do
        local function getTugCircle()
            local guiRoot = Me:FindFirstChild("PlayerGui")
            if not guiRoot then
                return nil
            end

            local root =
                guiRoot:FindFirstChild("TugOfWarUIV2")
                or guiRoot:FindFirstChild("TugOfWarUI")
                or guiRoot:FindFirstChild("TugofWarRemake")

            if not root then
                return nil
            end

            root = root:FindFirstChild("TugofWarRemake") or root
            local circle = root and root:FindFirstChild("CircleBase")

            return circle and circle.Visible and circle or nil
        end

        TugGroup2:AddToggle("UltimateTugOfWar", {
            Text = "狂暴拔河V2",
            Default = false,
            Tooltip = "狂暴拔河V2",

            Callback = (function()
                local active = false
                local frameConnection
                local inRange = false
                local rangeStarted = 0
                local pressDelay = 0.02

                local function scanQTE()
                    local guiRoot = Me:FindFirstChild("PlayerGui")
                    if not guiRoot then
                        return nil
                    end

                    local function descend(node, depth)
                        if depth > 8 then
                            return nil
                        end

                        local circle = node:FindFirstChild("CircleBase")
                        if circle then
                            return circle
                        end

                        for _, child in ipairs(node:GetChildren()) do
                            if child:IsA("ScreenGui")
                                or child:IsA("Frame")
                                or child:IsA("ImageLabel") then

                                local hit = descend(child, depth + 1)
                                if hit then
                                    return hit
                                end
                            end
                        end

                        return nil
                    end

                    local circle = descend(guiRoot, 0)
                    if not circle then
                        return nil
                    end

                    local arrow = circle:FindFirstChild("Arrow")
                    local medium = circle:FindFirstChild("Medium")

                    if not arrow or not medium then
                        return nil
                    end

                    return {
                        circleBase = circle,
                        arrow = arrow,
                        medium = medium,
                        btn =
                            circle:FindFirstChild("TextButton")
                            or circle:FindFirstChildWhichIsA("TextButton")
                            or (circle.Parent and circle.Parent:FindFirstChild("TextButton")),
                    }
                end

                local function tap(button)
                    if not button then
                        return
                    end

                    pcall(function()
                        if firesignal then
                            firesignal(button.MouseButton1Click)
                        end
                        collectgarbage()
                    end)
                end

                local function allowedAngle()
                    local strategy =
                        Me:GetAttribute("TugOfWarStrategy") or "Standard"

                    return strategy == "Stall" and 20 or 26
                end

                return function(state)
                    active = state and true or false

                    if frameConnection then
                        pcall(function()
                            frameConnection:Disconnect()
                        end)
                        frameConnection = nil
                    end

                    inRange = false
                    rangeStarted = 0

                    if not active then
                        toggleSound()
                        return
                    end

                    frameConnection = FrameService.RenderStepped:Connect(function()
                        if not active then
                            return
                        end

                        local qte = scanQTE()
                        if not qte or not qte.circleBase.Visible then
                            inRange = false
                            rangeStarted = 0
                            return
                        end

                        if Me:GetAttribute("TugOfWarPhase") == "QTE" then
                            qte.medium.Rotation = qte.arrow.Rotation
                        end

                        local now = tick()
                        local angle = math.abs(
                            (qte.medium.Rotation - qte.arrow.Rotation + 180) % 360 - 180
                        )

                        local inside = angle <= allowedAngle()

                        if inside and not inRange then
                            inRange = true
                            rangeStarted = now
                        elseif not inside and inRange then
                            inRange = false
                            rangeStarted = 0
                        end

                        if inRange and pressDelay <= now - rangeStarted then
                            tap(qte.btn)
                            inRange = false
                            rangeStarted = 0
                        end
                    end)

                    toggleSound()
                end
            end)(),
        })
    end


    do
        local active = false
        local spawnedUi

        TugGroup2:AddToggle("TugOfWarQTE", {
            Text = "拔河练习",
            Tooltip = "强制 TugOfWarPhase = QTE 用于练习",
            Default = false,

            Callback = function(state)
                active = state and true or false

                if spawnedUi then
                    spawnedUi:Destroy()
                    spawnedUi = nil
                end

                if active then
                    MeAlias:SetAttribute("TugOfWarPhase", "QTE")
                    GameWorld:SetAttribute("TugOfWarRhythmGoal", 180)
                    GameWorld:SetAttribute("TugOfWarRush", nil)

                    local tugUi = getOrMakeTugGui()
                    if tugUi then
                        tugUi.Enabled = true
                        spawnedUi = tugUi

                        local scriptNode =
                            tugUi:FindFirstChild("TugOfWarQTEHandler", true)
                            or tugUi:FindFirstChildWhichIsA("LocalScript", true)
                            or tugUi:FindFirstChildWhichIsA("Script", true)

                        if scriptNode and scriptNode:IsA("LocalScript") then
                            scriptNode.Disabled = false
                        end
                    end

                    task.wait(0.3)
                    MeAlias:SetAttribute("TugOfWarPhase", "QTE")
                    pushNotice("拔河", "QTE 练习模式已开启", 0.9)
                else
                    pushNotice("拔河", "QTE 练习模式已关闭", 0.9)
                end

                toggleSound()
            end,
        })
    end
end

--跳绳
btn(JumpGroup, "删除绳子", function()
if not fn12("JumpRope") then fn13(nil, "跳绳当前未运行。") return end
local eff = workspace:FindFirstChild("Effects")
if eff then
    local rope = eff:FindFirstChild("rope")
    if rope then rope:Destroy(); fn13(" 成功", "绳子已删除")
    else fn13(" 未找到", "在Effects中未找到绳子。") end
else fn13(" 未找到", "未找到Effects文件夹。") end
end)
do
local Players           = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace         = game:GetService("Workspace")
local RunService        = game:GetService("RunService")
local HttpService       = game:GetService("HttpService")
local localPlayer       = Players.LocalPlayer
local localPlayer2      = localPlayer
local RunService2       = RunService
local function PlayToggleSound() end
local function PlayErrorSound() end
local function PlayBell() end
local function notify(title, text, duration)
    Library:Notify({
        Title = tostring(title),
        Description = tostring(text or ""),
        Time = tonumber(duration) or 0.9,
    })
end
local function fn61(fn, ...)
    if type(fn) ~= "function" then return end
    local args = table.pack(...)
    task.spawn(function()
        pcall(fn, table.unpack(args, 1, args.n))
    end)
end
local function get_character()
    return localPlayer.Character
end
local function get_humanoid(ch)
    return ch and ch:FindFirstChildOfClass("Humanoid")
end
local function get_root_part(ch)
    return ch and ch:FindFirstChild("HumanoidRootPart")
end
local function is_game_active(gameName)
    local values = Workspace:FindFirstChild("Values")
    if not values then return false end
    local currentGame = values:FindFirstChild("CurrentGame")
    return currentGame and currentGame.Value == gameName
end
local function disable_toggle(toggleId)
    local opt = Options[toggleId]
    if opt and opt.SetValue then
        pcall(function() opt:SetValue(false) end)
    end
end
local function safe_teleport(pos)
    local char = localPlayer.Character
    if not char then return false end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return false end
    hrp.CFrame = CFrame.new(pos)
    return true
end
do
    local enabled  = false
    local platform = nil
    local conn     = nil
    local function createPart()
        local ch = get_character()
        if not ch then return nil end
        local hrp = get_root_part(ch)
        if not hrp then return nil end
        local part = Instance.new("Part")
        part.Name = HttpService:GenerateGUID(false)
        part.Size = Vector3.new(10000, 1, 10000)
        part.Position = Vector3.new(hrp.Position.X, hrp.Position.Y - 5, hrp.Position.Z)
        part.Anchored = true
        part.CanCollide = true
        part.Transparency = 0.5
        part.Parent = workspace
        return part
    end
    JumpGroup:AddToggle("AntiFall", {
        Text = "防摔落",
        Tooltip = "在脚下生成 10000×1×10000 平台防止掉入虚空",
        Default = false,
        Callback = function(Value)
            if Value then
                if not is_game_active("JumpRope") then
                    notify("Anti Fall", "Wait for JumpRope!", 0.9)
                    PlayErrorSound()
                    disable_toggle("AntiFall")
                    return false
                end
            end
            if conn then conn:Disconnect(); conn = nil end
            if platform then platform:Destroy(); platform = nil end
            enabled = Value and true or false
            if enabled then
                platform = createPart()
                conn = RunService2.Heartbeat:Connect(function()
                    if not enabled then return end
                    if not is_game_active("JumpRope") then
                        disable_toggle("AntiFall")
                        return
                    end
                    if not (platform and platform.Parent) then
                        platform = createPart()
                    end
                end)
            end
            PlayToggleSound()
            return true
        end,
    })
end
do
    local enabled      = false
    local connection   = nil
    local ropeDestroyed = false
    local function disable_rope_objects(obj)
        if not obj then return end
        pcall(function()
            if obj:IsA("MeshPart") or obj:IsA("Part") or obj:IsA("BasePart") then
                obj.CanCollide = false
                obj.CanTouch = false
                obj.CanQuery = false
                obj.Massless = true
                if obj.TouchTransmitter then
                    obj.TouchTransmitter:Destroy()
                end
            end
            if obj:IsA("Script")
                or obj:IsA("LocalScript")
                or obj:IsA("ModuleScript") then
                local str = obj.Name:lower()
                if str:find("rope")
                    or str:find("jump")
                    or str:find("carry")
                    or str:find("damage")
                    or str:find("hurt") then
                    obj.Disabled = true
                end
            end

            if obj:IsA("RopeConstraint") then
                obj:Destroy()
            end
            local name = obj.Name or ""
            if name == "PlayingJumpRope" or name == "RopeCarryPrompt" then
                obj:Destroy()
            end
        end)
    end
    local function search_and_destroy(root)
        if not root then return end
        for _, d in pairs(root:GetDescendants()) do
            if d.Name and d.Name:lower():find("rope") then
                disable_rope_objects(d)
            end
            if d:IsA("RopeConstraint") then
                disable_rope_objects(d)
            end
            if d.Name == "PlayingJumpRope" or d.Name == "RopeCarryPrompt" then
                disable_rope_objects(d)
            end
        end
    end
    local function destroy_all_ropes()
        search_and_destroy(workspace)
        pcall(function() search_and_destroy(game:GetService("ReplicatedStorage")) end)
        pcall(function() search_and_destroy(game:GetService("ServerStorage")) end)
        pcall(function() search_and_destroy(game:GetService("ServerScriptService")) end)
        pcall(function()
            for _, plr in pairs(Players:GetPlayers()) do
                if plr.Character then search_and_destroy(plr.Character) end
                if plr.PlayerGui then search_and_destroy(plr.PlayerGui) end
            end
        end)
        ropeDestroyed = true
    end
    local function disable_damage_scripts()
        local function scan(container)
            for _, d in pairs(container:GetDescendants()) do
                if d:IsA("Script")
                    or d:IsA("LocalScript")
                    or d:IsA("ModuleScript") then
                    local str = d.Name:lower()
                    if str:find("rope")
                        or str:find("jump")
                        or str:find("carry")
                        or str:find("damage")
                        or str:find("hurt") then
                        d.Disabled = true
                    end
                end
            end
        end
        pcall(function() scan(game:GetService("ReplicatedStorage")) end)
        pcall(function() scan(game:GetService("ServerStorage")) end)
        pcall(function() scan(game:GetService("ServerScriptService")) end)
    end
    JumpGroup:AddToggle("AntiHit", {
        Text = "防绳击",
        Tooltip = "禁用所有绳子相关脚本，销毁绳子对象与伤害脚本",
        Default = false,
        Callback = function(Value)
            if Value then
                if not is_game_active("JumpRope") then
                    notify("AntiHit", "Wait for JumpRope!", 0.9)
                    PlayErrorSound()
                    disable_toggle("AntiHit")
                    return false
                end
            end
            if connection then
                connection:Disconnect()
                connection = nil
            end
            enabled = Value and true or false
            ropeDestroyed = false
            if enabled then
                disable_damage_scripts()
                destroy_all_ropes()
                connection = RunService2.Heartbeat:Connect(function()
                    if not enabled then return end
                    if not is_game_active("JumpRope") then
                        disable_toggle("AntiHit")
                        return
                    end
                    if not ropeDestroyed then
                        destroy_all_ropes()
                    end
                end)
            end
            PlayToggleSound()
            return true
        end,
    })
end
do
    local enabled        = false
    local connection     = nil
    local animationId    = "rbxassetid://105677261748140"
    local animDuration   = 0.4
    local currentAnim    = nil
    local stopTimer      = nil
    local wasJumping     = false
    local function playLandAnimation()
        if not enabled then return end
        local ch = get_character()
        if not ch then return end
        local hum = get_humanoid(ch)
        if not hum then return end
        if currentAnim then
            pcall(function() currentAnim:Stop() end)
        end
        if stopTimer then
            stopTimer:Disconnect()
            stopTimer = nil
        end
        local animation = Instance.new("Animation")
        animation.AnimationId = animationId
        currentAnim = hum:LoadAnimation(animation)
        pcall(function() currentAnim:Play() end)
        stopTimer = game:GetService("RunService").Stepped:Connect(function()
            task.wait(animDuration)
            if currentAnim then
                pcall(function() currentAnim:Stop() end)
                currentAnim = nil
            end
            if stopTimer then
                stopTimer:Disconnect()
                stopTimer = nil
            end
        end)
    end
    local function setup()
        local ch = get_character()
        if not ch then return end
        local hum = get_humanoid(ch)
        if not hum then return end
        wasJumping = false
        hum.StateChanged:Connect(function(_, new)
            if not enabled then return end
            if new == Enum.HumanoidStateType.Jumping then
                wasJumping = true
            end
            if wasJumping
                and (new == Enum.HumanoidStateType.Running
                    or new == Enum.HumanoidStateType.Landed
                    or new == Enum.HumanoidStateType.GettingUp) then
                playLandAnimation()
                wasJumping = false
            end
        end)
    end
    JumpGroup:AddToggle("FakeBalance", {
        Text = "假平衡",
        Tooltip = "跳跃落地时播放平衡动画，欺骗游戏",
        Default = false,
        Callback = function(Value)
            if Value then
                if not is_game_active("JumpRope") then
                    notify("Fake Balance", "Wait for JumpRope!", 0.9)
                    PlayErrorSound()
                    disable_toggle("FakeBalance")
                    return false
                end
            end
            if connection then
                connection:Disconnect()
                connection = nil
            end
            if currentAnim then
                pcall(function() currentAnim:Stop() end)
                currentAnim = nil
            end
            if stopTimer then
                stopTimer:Disconnect()
                stopTimer = nil
            end
            enabled = Value and true or false
            if enabled then
                setup()
                connection = RunService2.Heartbeat:Connect(function()
                    if not enabled then return end
                    if not is_game_active("JumpRope") then
                        disable_toggle("FakeBalance")
                        return
                    end
                end)
            end

            PlayToggleSound()
            return true
        end,
    })
end
do
    JumpGroup:AddToggle("FreezeRope", {
        Text = "冻结绳子",
        Tooltip = "把 workspace.Effects.rope 下所有部件 Anchored，约束禁用",
        Default = false,
        Callback = function(Value)
            local rope = workspace:FindFirstChild("Effects")
                and workspace.Effects:FindFirstChild("rope")
            if not rope then
                if Options.FreezeRope then
                    pcall(function() Options.FreezeRope:SetValue(false) end)
                end
                return
            end
            if Value then
                for _, d in ipairs(rope:GetDescendants()) do
                    if d:IsA("BasePart") then
                        d.Anchored = true
                        d.Velocity = Vector3.zero
                        d.RotVelocity = Vector3.zero
                    elseif d:IsA("Constraint")
                        or d:IsA("RopeConstraint")
                        or d:IsA("Motor6D") then
                        d.Enabled = false
                    end
                end
            else
                for _, d in ipairs(rope:GetDescendants()) do
                    if d:IsA("BasePart") then
                        d.Anchored = false
                    elseif d:IsA("Constraint")
                        or d:IsA("RopeConstraint")
                        or d:IsA("Motor6D") then
                        d.Enabled = true
                    end
                end
            end
            PlayToggleSound()
        end,
    })
end
do
    local enabled = false
    local loop    = nil
    JumpGroup:AddToggle("AutoJump", {
        Text = "自动跳跃",
        Tooltip = "绳子距离 ≤ 15 时每 1 秒自动触发一次跳跃",
        Default = false,
        Callback = function(Value)
            enabled = Value and true or false
            if loop then
                task.cancel(loop)
                loop = nil
            end
            if enabled then
                loop = task.spawn(function()
                    while enabled do
                        local rope = workspace:FindFirstChild("Effects")
                            and workspace.Effects:FindFirstChild("rope")
                        local ch = get_character()
                        if rope and ch then
                            local hrp = get_root_part(ch)
                            if hrp and (hrp.Position - rope.Position).Magnitude <= 15 then
                                local hum = get_humanoid(ch)
                                if hum and hum.Health > 0 then
                                    hum:ChangeState(Enum.HumanoidStateType.Jumping)
                                end
                            end
                        end
                        task.wait(1)
                    end
                end)
            end
            PlayToggleSound()
        end,
    })
end
JumpGroup:AddDivider()
JumpGroup:AddButton({
    Text = "移除平衡",
    Tooltip = "销毁 localPlayer.PlayingJumpRope",
    Func = function()
        local playingJumpRope = localPlayer2:FindFirstChild("PlayingJumpRope")
        if playingJumpRope then
            pcall(function() playingJumpRope:Destroy() end)
            PlayBell()
        else
            notify("Jump Rope", "PlayingJumpRope not found", 0.9)
            PlayErrorSound()
        end
    end,
})
JumpGroup:AddDivider()
do
    local lastTP = 0
    local function try_tp(pos, name)
        if tick() - lastTP < 10 then
            notify("冷却中", "等待 " .. math.ceil(10 - (tick() - lastTP)) .. "秒", 0.9)
            return
        end
        if is_game_active("JumpRope") then
            safe_teleport(pos)
            lastTP = tick()
            notify("JumpRope", name, 0.9)
            PlayBell()
        else
            notify("JumpRope", "Wait for JumpRope!", 0.9)
            PlayErrorSound()
        end
    end
    JumpGroup:AddButton({
        Text = "传送起点",
        Tooltip = "传送到 (615.28, 192.27, 920.95)",
        Func = function()
            try_tp(Vector3.new(615.2844, 192.27428, 920.9525), "Teleported to Start")
        end,
    })
    JumpGroup:AddButton({
        Text = "传送终点",
        Tooltip = "传送到 (720.90, 198.63, 921.17)",
        Func = function()
            try_tp(Vector3.new(720.89606, 198.62831, 921.17065), "Teleported to End")
        end,
    })
end
end
--破璃桥
do
local esp, fake = false, false
local hl, plates = {}, {}
local thread = nil
local PhysicsService = game:GetService("PhysicsService")
pcall(function()
    PhysicsService:RegisterCollisionGroup("LocalPlayerOnly")
    PhysicsService:RegisterCollisionGroup("FakeGlass")
    PhysicsService:CollisionGroupSetCollidable("FakeGlass", "Default", false)
    PhysicsService:CollisionGroupSetCollidable("FakeGlass", "LocalPlayerOnly", true)
end)
local function process(m)
    if not m:IsA("Model") or not m.PrimaryPart then return end
    local pp = m.PrimaryPart
    local isBreak = pp:GetAttribute("exploitingisevil")
    if esp and not hl[m] then
        local h = Instance.new("Highlight")
        h.FillTransparency = 0.5; h.OutlineTransparency = 0
        h.OutlineColor = Color3.new(1,1,1)
        if isBreak then
            h.FillColor = Color3.fromRGB(255,50,50); h.Name = "BreakableHighlight"
        else
            h.FillColor = Color3.fromRGB(50,255,50); h.Name = "SafeHighlight"
        end
        h.Adornee = m; h.Parent = m
        hl[m] = h
    end
    if fake and isBreak and not plates[m] then
        local p = Instance.new("Part")
        p.Size = pp.Size
        p.CFrame = pp.CFrame * CFrame.new(0, 1, 0)
        p.Anchored = true; p.CanCollide = true
        p.Transparency = 0.5; p.Color = Color3.fromRGB(50,255,50)
        p.Material = Enum.Material.Glass
        pcall(function() p.CollisionGroup = "FakeGlass" end)
        p.Parent = workspace
        plates[m] = p
    end
end
local function clearAll()
    for _, h in pairs(hl) do if h and h.Parent then h:Destroy() end end
    table.clear(hl)
    for _, p in pairs(plates) do if p and p.Parent then p:Destroy() end end
    table.clear(plates)
end
local function startLoop()
    if thread then return end
    thread = task.spawn(function()
        while esp or fake do
            if workspace:GetAttribute("GLASSBRIDGEOVER") then clearAll() end
            local ch = localPlayer.Character
            if ch then
                local hum = ch:FindFirstChild("Humanoid")
                if hum and hum.Health <= 0 then clearAll() end
            end
            local gb = workspace:FindFirstChild("GlassBridge")
            local gholder = gb and gb:FindFirstChild("GlassHolder")
            if gholder then
                for _, c in ipairs(gholder:GetChildren()) do
                    for _, c2 in ipairs(c:GetChildren()) do process(c2) end
                end
            end
            task.wait(2)
        end
        thread = nil
    end)
end
GlassGroup:AddToggle("Glass_ESP", {
    Text = "玻璃桥透视",
    Default = false,
    Callback = function(on)
        esp = on
        if on then startLoop() else clearAll() end
    end,
})
local conn
GlassGroup:AddToggle("Glass_FakeSafe", {
    Text = "假安全玻璃",
    Default = false,
    Callback = function(on)
        fake = on
        if on then
            local function tag(ch)
                task.spawn(function()
                    task.wait(0.5)
                    for _, d in ipairs(ch:GetDescendants()) do
                        if d:IsA("BasePart") then
                            pcall(function() d.CollisionGroup = "LocalPlayerOnly" end)
                        end
                    end
                end)
            end
            if localPlayer.Character then tag(localPlayer.Character) end
            conn = localPlayer.CharacterAdded:Connect(tag)
            startLoop()
        else
            if conn then conn:Disconnect(); conn = nil end
            clearAll()
        end
    end,
})
tbl3.lastGlassTPTime = 0
btn(GlassGroup, "传送到起点", function()
    if tick() - tbl3.lastGlassTPTime < 10 then
        fn13(" 冷却中", "等待 " .. math.ceil(10-(tick()-tbl3.lastGlassTPTime)) .. "秒")
        return
    end
    if fn12("GlassBridge") then
        fn17(CFrame.new(36, 521, -1533))
        tbl3.lastGlassTPTime = tick()
    else fn13(nil, "玻璃桥当前未运行。") end
end)
btn(GlassGroup, "传送到终点", function()
    if tick() - tbl3.lastGlassTPTime < 10 then
        fn13(" 冷却中", "等待 " .. math.ceil(10-(tick()-tbl3.lastGlassTPTime)) .. "秒")
        return
    end
    if fn12("GlassBridge") then
        fn17(CFrame.new(-204, 521, -1536))
        tbl3.lastGlassTPTime = tick()
    else fn13(nil, "玻璃桥当前未运行。") end
end)
end
do
local Players           = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace         = game:GetService("Workspace")
local RunService        = game:GetService("RunService")
local localPlayer       = Players.LocalPlayer
local localPlayer2      = localPlayer
local RunService2       = RunService
local function PlayToggleSound() end
local function PlayErrorSound() end
local function PlayBell() end
local function notify(title, text, duration)
    Library:Notify({
        Title = tostring(title),
        Description = tostring(text or ""),
        Time = tonumber(duration) or 0.9,
    })
end
local function fn61(fn, ...)
    if type(fn) ~= "function" then return end
    local args = table.pack(...)
    task.spawn(function()
        pcall(fn, table.unpack(args, 1, args.n))
    end)
end
if not firesignal then
    function firesignal(signal)
        if not getconnections then return end
        for _, c in ipairs(getconnections(signal)) do
            pcall(function() c:Fire() end)
        end
    end
end
MainModule = MainModule or {}
local function is_game_active(gameName)
    local values = Workspace:FindFirstChild("Values")
    if not values then return false end
    local currentGame = values:FindFirstChild("CurrentGame")
    return currentGame and currentGame.Value == gameName
end
MainModule.is_game_active = is_game_active
local function disable_toggle(toggleId)
    local opt = Options[toggleId]
    if opt and opt.SetValue then
        pcall(function() opt:SetValue(false) end)
    end
end
local function safe_teleport(pos)
    local char = localPlayer.Character
    if not char then return false end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return false end
    hrp.CFrame = CFrame.new(pos)
    return true
end
do
    local enabled = false
    local conn, last = nil, 0
    local function scrub()
        local gb = Workspace:FindFirstChild("GlassBridge")
        if not gb then return end
        local holder = gb:FindFirstChild("GlassHolder")
        if not holder then return end
        for _, d in ipairs(holder:GetDescendants()) do
            if d:IsA("TouchTransmitter")
                or d:IsA("ProximityPrompt")
                or (typeof(d.Name) == "string"
                    and d.Name:lower():find("touch")) then
                pcall(function() d:Destroy() end)
            elseif d:IsA("BasePart") then
                for _, c in ipairs(d:GetChildren()) do
                    if c.ClassName == "TouchInterest" then
                        pcall(function() c:Destroy() end)
                    end
                end
            end
        end
    end
    GlassGroup:AddToggle("AntiBreak", {
        Text = "防破碎V2",
        Tooltip = "防止玻璃碎裂（销毁所有 TouchTransmitter / ProximityPrompt / TouchInterest）",
        Default = false,
        Callback = function(on)
            enabled = on and true or false

            if conn then
                pcall(function() conn:Disconnect() end)
                conn = nil
            end
            if enabled then
                scrub()
                conn = RunService2.Heartbeat:Connect(function()
                    if not enabled then return end
                    local now = tick()
                    if last + 1 > now then return end
                    last = now
                    pcall(scrub)
                end)
            end
            PlayToggleSound()
            return true
        end,
    })
end
end
GlassGroup:AddDivider()
do
    local Players     = game:GetService("Players")
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local LocalPlayer = Players.LocalPlayer
    local function Notify(Title, Description, Time)
        Library:Notify({ Title = Title, Description = Description, Time = Time or 3 })
    end
    local ModuleCache = {}
    local function SafeRequire(Module)
        if ModuleCache[tostring(Module)] then
            return ModuleCache[tostring(Module)]
        end
        local ok, Result = pcall(function()
            return require(Module)
        end)
        if ok then
            ModuleCache[tostring(Module)] = Result
            return Result
        end
        warn("[SafeRequire]: 无法加载 " .. tostring(Module))
        local Stub = {
            AnnouncementTween = function(t)
                Notify("提示", t.AnnouncementDisplayText or "通知", t.DisplayTime or 5)
            end,
            Pressed = function() end,
            RenderDashEffects = function() end,
        }
        ModuleCache[tostring(Module)] = Stub
        return Stub
    end
    local function WinGlassBridge()
        local Character = LocalPlayer.Character
        if not Character then return end
        Character:PivotTo(CFrame.new(Vector3.new(-203.9, 520.7, -1534.3485)))
        Notify("玻璃桥", "已传送到终点", 2)
    end
    local function AntiFallGlassBridge()
        local GlassHolder = workspace:FindFirstChild("GlassBridge")
            and workspace.GlassBridge:FindFirstChild("GlassHolder")
        if not GlassHolder then
            Notify("玻璃桥", "未找到玻璃桥！", 3)
            return
        end
        local BrokenCount = 0
        local FixedCount = 0
        for _, Holder in pairs(GlassHolder:GetChildren()) do
            for _, Glass in pairs(Holder:GetChildren()) do
                if Glass:IsA("Model") and Glass.PrimaryPart then
                    local Primary = Glass.PrimaryPart
                    if Primary:GetAttribute("exploitingisevil") == true then
                        Primary:SetAttribute("exploitingisevil", nil)
                        BrokenCount += 1
                        local GlassPart = Glass:FindFirstChild("GlassPart")
                        if GlassPart and GlassPart:IsA("BasePart") then
                            local Clone = GlassPart:Clone()
                            Clone.Name = "arbuz"
                            Clone.Transparency = 1
                            Clone.CanCollide = true
                            Clone.CanQuery = true
                            Clone.CastShadow = false
                            Clone.Parent = Glass
                            FixedCount += 1
                        end
                    end
                end
            end
        end
        Notify("玻璃桥", string.format("防掉落：已清除 %d 块破碎玻璃，修复 %d 块", BrokenCount, FixedCount), 5)
    end
    local function RevealGlassBridge(ShowAnnouncement)
        local Effects = SafeRequire(ReplicatedStorage.Modules.Effects)
        local GlassHolder = workspace:FindFirstChild("GlassBridge")
            and workspace.GlassBridge:FindFirstChild("GlassHolder")
        if not GlassHolder then return end
        local Colors = {
            instantDeath    = Color3.fromRGB(255, 0, 0),
            delayedBreaking = Color3.fromRGB(255, 165, 0),
            safe            = Color3.fromRGB(0, 255, 0),
        }
        local GlassTiles = {}
        for _, Holder in pairs(GlassHolder:GetChildren()) do
            for _, Glass in pairs(Holder:GetChildren()) do
                if Glass:IsA("Model") and Glass.PrimaryPart then
                    table.insert(GlassTiles, Glass)
                end
            end
        end
        local Count = 0
        for Index, Glass in ipairs(GlassTiles) do
            local Primary = Glass.PrimaryPart
            local IsKilling = Primary:GetAttribute("ActuallyKilling") == true
            local IsDelayed = Primary:GetAttribute("DelayedBreaking") == true
            local Color
            if IsKilling and not IsDelayed then
                Color = Colors.instantDeath
            elseif IsKilling and IsDelayed then
                Color = Colors.delayedBreaking
            else
                Color = Colors.safe
            end
            for _, Part in pairs(Glass:GetDescendants()) do
                if Part:IsA("BasePart") then
                    if not Part:GetAttribute("OriginalTransparency") then
                        Part:SetAttribute("OriginalTransparency", Part.Transparency)
                        Part:SetAttribute("OriginalColor", Part.Color)
                    end
                    Part.Transparency = 0.5
                    Part.Color = Color
                end
            end
            if Index % 3 == 1 then
                local HL = Instance.new("Highlight")
                HL.FillColor = Color
                HL.FillTransparency = 0.7
                HL.OutlineTransparency = 0.5
                HL.Parent = Glass
            end
            Count += 1
            if Count % 5 == 0 then
                task.wait()
            end
        end
        if ShowAnnouncement then
            Effects.AnnouncementTween({
                AnnouncementOneLine = true,
                FasterTween = true,
                DisplayTime = 10,
                AnnouncementDisplayText = "🔴 红色 = 立即死亡 | 🟠 橙色 = 延迟破碎 | 🟢 绿色 = 安全",
            })
        end
    end
    local function ClearGlassBridgeHighlight()
        local GlassHolder = workspace:FindFirstChild("GlassBridge")
            and workspace.GlassBridge:FindFirstChild("GlassHolder")
        if not GlassHolder then return end
        local GlassTiles = {}
        for _, Holder in pairs(GlassHolder:GetChildren()) do
            for _, Glass in pairs(Holder:GetChildren()) do
                if Glass:IsA("Model") then
                    table.insert(GlassTiles, Glass)
                end
            end
        end
        for Index, Glass in ipairs(GlassTiles) do
            for _, Child in ipairs(Glass:GetChildren()) do
                if Child:IsA("Highlight") then
                    Child:Destroy()
                end
            end
            for _, Part in pairs(Glass:GetDescendants()) do
                if Part:IsA("BasePart") then
                    local OrigTransparency = Part:GetAttribute("OriginalTransparency")
                    local OrigColor = Part:GetAttribute("OriginalColor")
                    pcall(function()
                        if OrigTransparency ~= nil then
                            Part.Transparency = OrigTransparency
                            Part.Color = OrigColor or Color3.fromRGB(255, 255, 255)
                        else
                            Part.Transparency = 0
                            Part.Color = Color3.fromRGB(255, 255, 255)
                        end
                    end)
                    Part:SetAttribute("OriginalTransparency", nil)
                    Part:SetAttribute("OriginalColor", nil)
                end
            end

            if Index % 10 == 0 then
                task.wait()
            end
        end
    end
    GlassGroup:AddButton({
        Text = "完成玻璃桥游戏",
        Tooltip = "立即传送到玻璃桥终点",
        Func = function()
            if not workspace:FindFirstChild("GlassBridge") then
                Notify("玻璃桥", "游戏未开始！", 2)
                return
            end
            WinGlassBridge()
        end,
    })
    GlassGroup:AddButton({
        Text = "防碎裂玻璃桥V3(个人觉得很好)",
        Tooltip = "让所有玻璃砖变为实心且不可破坏",
        Func = function()
            if not workspace:FindFirstChild("GlassBridge") then
                Notify("玻璃桥", "游戏未开始！", 2)
                return
            end
            AntiFallGlassBridge()
        end,
    })
    do
        local enabled        = false
        local thread         = nil
        local currentlyShown = false
        local lastRefresh    = 0
        local refreshInterval = 2
        GlassGroup:AddToggle("AutoRevealGlassBridge", {
            Text = "显示玻璃桥(更详细的)",
            Tooltip = "高亮玻璃砖：🔴 红色 = 死亡 | 🟠 橙色 = 延迟 | 🟢 绿色 = 安全",
            Default = false,
            Callback = function(Value)
                enabled = Value and true or false

                if thread then
                    task.cancel(thread)
                    thread = nil
                end
                if not enabled then
                    currentlyShown = false
                    pcall(function() ClearGlassBridgeHighlight() end)
                    Notify("玻璃桥", "显示玻璃桥 已禁用", 2)
                    return
                end
                currentlyShown = false
                thread = task.spawn(function()
                    while enabled do
                        if workspace:FindFirstChild("GlassBridge") then
                            local Now = tick()
                            if Now - lastRefresh > refreshInterval then
                                lastRefresh = Now
                                pcall(function()
                                    if not currentlyShown then
                                        RevealGlassBridge(true)
                                        currentlyShown = true
                                    else
                                        RevealGlassBridge(false)
                                    end
                                end)
                            end
                        end
                        task.wait(0.5)
                    end
                end)
                Notify("玻璃桥", "显示玻璃桥 已启用", 2)
            end,
        })
    end
    GlassGroup:AddButton({
        Text = "立即显示一次",
        Tooltip = "立即标记一次玻璃砖颜色，不持续刷新",
        Func = function()
            if not workspace:FindFirstChild("GlassBridge") then
                Notify("玻璃桥", "游戏未开始！", 2)
                return
            end
            RevealGlassBridge(true)
            Notify("玻璃桥", "已标记玻璃砖", 2)
        end,
    })
    GlassGroup:AddButton({
        Text = "清除玻璃桥标记",
        Tooltip = "还原所有玻璃砖的颜色与透明度",
        Func = function()
            ClearGlassBridgeHighlight()
            Notify("玻璃桥", "已清除所有标记", 2)
        end,
    })
end
--天空游戏
tbl2.skyAntiFallThread = nil
SkyGroup:AddToggle("Sky_AntiFall", {
Text = "天空鱿鱼游戏防掉落",
Default = false,
Callback = function(on)
    tbl.skyAntiFallEnabled = on
    if on then
        if tbl2.skyAntiFallThread then return end
        tbl2.skyAntiFallThread = true
        task.spawn(function()
            while tbl2.skyAntiFallThread and tbl.skyAntiFallEnabled do
                if fn12("SkySquidGame") or fn12("SquidGame") then
                    if not workspace:FindFirstChild("SkyAntiFallPlatform") then
                        local a = Vector3.new(91, 957, 251)
                        local b = Vector3.new(-70, 958, -107)
                        local mid = (a+b)/2
                        local p = Instance.new("Part")
                        p.Name = "SkyAntiFallPlatform"
                        p.Size = Vector3.new(math.abs(a.X-b.X)+30, 1, math.abs(a.Z-b.Z)+30)
                        p.Position = Vector3.new(mid.X, mid.Y+4, mid.Z)
                        p.Anchored = true; p.Transparency = 0.5
                        p.Color = Color3.fromRGB(0,255,0)
                        p.Material = Enum.Material.ForceField
                        p.Parent = workspace
                    end
                else
                    local p = workspace:FindFirstChild("SkyAntiFallPlatform")
                    if p then p:Destroy() end
                end
                task.wait(1)
            end
            local p = workspace:FindFirstChild("SkyAntiFallPlatform")
            if p then p:Destroy() end
            tbl2.skyAntiFallThread = nil
        end)
    end
end,
})
do
local c
SkyGroup:AddToggle("Sky_AntiFreeze", {
    Text = "战斗中防冻结",
    Default = false,
    Callback = function(on)
        tbl.antiFreezeFightEnabled = on
        if on then
            if c then return end
            local attrs = { "Freeze","Slowed","Action","LightAction","NoAttack" }
            local objs = { "Stun","Freeze","Slowed","Action","Ragdoll" }
            c = RunService.Heartbeat:Connect(function()
                if not (fn12("SkySquidGame") or fn12("SquidGame")) then return end
                if shared.IsInCutscene then shared.IsInCutscene = nil end
                pcall(function()
                    local ps = localPlayer:FindFirstChild("PlayerScripts")
                    if ps then
                        local pm = ps:FindFirstChild("PlayerModule")
                        if pm then
                            local ctl = require(pm):GetControls()
                            if ctl and ctl.Enable then ctl:Enable(true) end
                        end
                    end
                end)
                local ch = localPlayer.Character; if not ch then return end
                local hum = ch:FindFirstChildOfClass("Humanoid")
                local hrp = ch:FindFirstChild("HumanoidRootPart")
                for _, a in ipairs(attrs) do
                    if ch:GetAttribute(a) ~= nil then ch:SetAttribute(a, nil) end
                    if hum and hum:GetAttribute(a) ~= nil then hum:SetAttribute(a, nil) end
                end
                if hrp and hrp.Anchored then hrp.Anchored = false end
                if hum then
                    local sp = game:GetService("StarterPlayer")
                    local ws = sp.CharacterWalkSpeed or 16
                    local jp = sp.CharacterJumpPower or 50
                    if hum.WalkSpeed < ws then hum.WalkSpeed = ws end
                    if hum.JumpPower < jp then hum.JumpPower = jp end
                    if hum.PlatformStand then hum.PlatformStand = false end
                end
                for _, o in ipairs(objs) do
                    local x = ch:FindFirstChild(o); if x then x:Destroy() end
                end
            end)
        elseif c then c:Disconnect(); c = nil end
    end,
})
end
tbl2.skyQTEThread = nil
SkyGroup:AddToggle("Sky_QTE", {
Text = "自动QTE事件",
Default = false,
Callback = function(on)
    tbl.skyAutoQTEEnabled = on
    if on and not tbl2.skyQTEThread then
        tbl2.skyQTEThread = task.spawn(function()
            local seen = {}
            while tbl.skyAutoQTEEnabled do
                if fn12("SkySquidGame") or fn12("SquidGame") then
                    local m = fn15()
                    if m and m.ActiveButtons then
                        for k, a in pairs(m.ActiveButtons) do
                            if not seen[k] and a then
                                seen[k] = true
                                if tbl.skyAutoQTEEnabled and (fn12("SkySquidGame") or fn12("SquidGame")) and m.ActiveButtons[k] then
                                    pcall(function() m.Pressed(false, m.ActiveButtons[k]) end)
                                end
                            end
                        end
                        for k in pairs(seen) do if not m.ActiveButtons[k] then seen[k] = nil end end
                    end
                else table.clear(seen) end
                task.wait()
            end
            tbl2.skyQTEThread = nil
        end)
    end
end,
})
do
local conns = {}
local active = false
local function start()
    local ch = localPlayer.Character; if not ch then return end
    local hum = ch:FindFirstChild("Humanoid"); if not hum then return end
    local an = hum:FindFirstChildOfClass("Animator"); if not an then return end
    table.insert(conns, an.AnimationPlayed:Connect(function(t)
        if not tbl.throwPoleAimEnabled then return end
        if t.Animation and t.Animation.AnimationId and string.find(tostring(t.Animation.AnimationId), "112950478995075") then
            active = true
            local h2 = ch:FindFirstChild("Humanoid"); if h2 then h2.AutoRotate = false end
            t.Stopped:Once(function()
                active = false
                local h3 = localPlayer.Character and localPlayer.Character:FindFirstChild("Humanoid")
                if h3 then h3.AutoRotate = true end
            end)
        end
    end))
end
SkyGroup:AddToggle("Sky_ThrowPoleAim", {
    Text = "投掷长杆瞄准",
    Default = false,
    Callback = function(on)
        tbl.throwPoleAimEnabled = on
        if on then
            start()
            table.insert(conns, localPlayer.CharacterAdded:Connect(function()
                task.wait(0.5); if tbl.throwPoleAimEnabled then start() end
            end))
            table.insert(conns, RunService.Heartbeat:Connect(function()
                if not tbl.throwPoleAimEnabled or not active then return end
                if not (fn12("SkySquidGame") or fn12("SquidGame")) then return end
                local ch = localPlayer.Character
                local hrp = ch and ch:FindFirstChild("HumanoidRootPart")
                if not hrp then return end
                local best, bd = nil, math.huge
                for _, p in pairs(Players:GetPlayers()) do
                    if p ~= localPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") and p.Character:FindFirstChild("Humanoid") and p.Character.Humanoid.Health > 0 then
                        local d = (p.Character.HumanoidRootPart.Position - hrp.Position).Magnitude
                        if d < bd then bd = d; best = p.Character.HumanoidRootPart end
                    end
                end
                if best then
                    hrp.CFrame = CFrame.lookAt(hrp.Position, Vector3.new(best.Position.X, hrp.Position.Y, best.Position.Z))
                end
            end))
        else
            active = false
            for _, c in pairs(conns) do pcall(function() c:Disconnect() end) end
            table.clear(conns)
        end
    end,
})
end
do
local Players           = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace         = game:GetService("Workspace")
local RunService        = game:GetService("RunService")
local HttpService       = game:GetService("HttpService")
local localPlayer       = Players.LocalPlayer
local localPlayer2      = localPlayer
local RunService2       = RunService
local function PlayToggleSound() end
local function PlayErrorSound() end
local function PlayBell() end
local function notify(title, text, duration)
    Library:Notify({
        Title = tostring(title),
        Description = tostring(text or ""),
        Time = tonumber(duration) or 0.9,
    })
end
local function fn61(fn, ...)
    if type(fn) ~= "function" then return end
    local args = table.pack(...)
    task.spawn(function()
        pcall(fn, table.unpack(args, 1, args.n))
    end)
end
local function get_character()
    return localPlayer.Character
end
local function get_root_part(ch)
    return ch and ch:FindFirstChild("HumanoidRootPart")
end
local function get_humanoid(ch)
    return ch and ch:FindFirstChildOfClass("Humanoid")
end
local function is_game_active(gameName)
    local values = Workspace:FindFirstChild("Values")
    if not values then return false end
    local currentGame = values:FindFirstChild("CurrentGame")
    return currentGame and currentGame.Value == gameName
end
local function disable_toggle(toggleId)
    local opt = Options[toggleId]
    if opt and opt.SetValue then
        pcall(function() opt:SetValue(false) end)
    end
end
do
    local enabled  = false
    local conn     = nil
    local charConn = nil
    local voidAnimIds = {
        "rbxassetid://107989020363293",
        "rbxassetid://71619354165195",
    }
    local voidZonePos = Vector3.new(-95.1, 964.6, 67.6)
    local function hookCharacter(character)
        local humanoid = character:WaitForChild("Humanoid")
        conn = humanoid.AnimationPlayed:Connect(function(track)
            if track.Animation
                and table.find(voidAnimIds, track.Animation.AnimationId) then
                local savedCFrame = character:GetPrimaryPartCFrame()
                local part = Instance.new("Part")
                part.Name = HttpService:GenerateGUID(false)
                part.Size = Vector3.new(10, 1, 10)
                part.Position = voidZonePos + Vector3.new(0, -4, 0)
                part.Anchored = true
                part.CanCollide = true
                part.Transparency = 1
                part.Parent = workspace
                character:SetPrimaryPartCFrame(CFrame.new(
                    voidZonePos.X,
                    voidZonePos.Y,
                    voidZonePos.Z
                ))
                track.Stopped:Connect(function()
                    task.wait(1)
                    if savedCFrame then
                        character:SetPrimaryPartCFrame(savedCFrame)
                    end
                    part:Destroy()
                end)
            end
        end)
    end
    SkyGroup:AddToggle("VoidKill", {
        Text = "虚空击杀",
        Tooltip = "播放掉落动画时把角色传送到虚空坐标，动画结束返回原位。需在 SkySquidGame 中",
        Default = false,
        Callback = function(Value)
            if Value then
                if not is_game_active("SkySquidGame") then
                    notify("Void Kill", "Wait for SkySquidGame!", 0.9)
                    PlayErrorSound()
                    disable_toggle("VoidKill")
                    return false
                end
            end
            if conn then conn:Disconnect(); conn = nil end
            if charConn then charConn:Disconnect(); charConn = nil end
            enabled = Value and true or false
            if enabled then
                if localPlayer2.Character then
                    hookCharacter(localPlayer2.Character)
                end
                charConn = localPlayer2.CharacterAdded:Connect(function(character)
                    task.wait(1)
                    if enabled then
                        hookCharacter(character)
                    end
                end)
            end
            PlayToggleSound()
            return true
        end,
    })
end
do
    local enabled       = false
    local connection    = nil
    local hasTeleported = false
    local fallHeight    = 950
    local tpPosition    = Vector3.new(0, 966, -6)

    SkyGroup:AddToggle("AutoTeleportOnFall", {
        Text = "掉落自动传送",
        Tooltip = "Y 坐标 ≤ 950 时自动传送到 (0, 966, -6)。需在 SkySquidGame 中",
        Default = false,
        Callback = function(Value)
            enabled = Value and true or false
            hasTeleported = false
            if connection then
                connection:Disconnect()
                connection = nil
            end
            if enabled then
                connection = RunService.Heartbeat:Connect(function()
                    if not enabled then return end
                    if not is_game_active("SkySquidGame") then return end
                    local char = get_character()
                    if not char then return end
                    local hrp = get_root_part(char)
                    if not hrp then return end
                    local y = hrp.Position.Y
                    if y <= fallHeight and not hasTeleported then
                        hrp.CFrame = CFrame.new(tpPosition)
                        hasTeleported = true
                        PlayBell()
                    end
                    if y > fallHeight then
                        hasTeleported = false
                    end
                end)
            end
            PlayToggleSound()
        end,
    })
end
do
    local enabled  = false
    local platform = nil
    local conn     = nil
    local function createPart()
        local char = get_character()
        if not char then return nil end
        local hrp = get_root_part(char)
        if not hrp then return nil end
        local part = Instance.new("Part")
        part.Name = HttpService:GenerateGUID(false)
        part.Size = Vector3.new(10000, 1, 10000)
        part.Position = Vector3.new(hrp.Position.X, hrp.Position.Y - 5, hrp.Position.Z)
        part.Anchored = true
        part.CanCollide = true
        part.Transparency = 0.5
        part.Parent = workspace
        return part
    end
    SkyGroup:AddToggle("SkySquidAntiFall", {
        Text = "防摔落平台",
        Tooltip = "在脚下生成 10000×1×10000 平台防止摔落虚空",
        Default = false,
        Callback = function(Value)
            if conn then conn:Disconnect(); conn = nil end
            if platform then platform:Destroy(); platform = nil end
            enabled = Value and true or false
            if enabled then
                platform = createPart()
                conn = RunService2.Heartbeat:Connect(function()
                    if not enabled then return end
                    if not (platform and platform.Parent) then
                        platform = createPart()
                    end
                end)
            end
            PlayToggleSound()
            return true
        end,
    })
end
end
--熄灯
btn(LOGroup, "传送到屋顶", function()
if not fn12("LightsOut") then fn13(nil, "熄灯当前未运行。") return end
local ch = localPlayer.Character
local hrp = ch and ch:FindFirstChild("HumanoidRootPart")
if hrp then hrp.CFrame = CFrame.new(198, 145, -93); fn13(" 熄灯", "已传送到屋顶") end
end)
do
local loopA = nil
local function add()
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= localPlayer and p.Character and not p.Character:FindFirstChild("LightsOutESP") then
            local h = Instance.new("Highlight")
            h.Name = "LightsOutESP"
            h.FillTransparency = 0.5; h.OutlineTransparency = 0
            h.FillColor = Color3.fromRGB(255,0,0); h.OutlineColor = Color3.fromRGB(200,0,0)
            h.Adornee = p.Character; h.Parent = p.Character
        end
    end
end
local function rm()
    for _, p in pairs(Players:GetPlayers()) do
        if p.Character then
            local h = p.Character:FindFirstChild("LightsOutESP")
            if h then h:Destroy() end
        end
    end
end
LOGroup:AddToggle("LO_ESPAll", {
    Text = "全员透视",
    Default = false,
    Callback = function(on)
        tbl.espLightsOutEnabled = on
        if on then
            if loopA then return end
            loopA = true
            task.spawn(function()
                while tbl.espLightsOutEnabled and loopA do
                    if fn12("LightsOut") then add() else rm() end
                    task.wait(2)
                end
                rm(); loopA = nil
            end)
        else rm() end
    end,
})
end
do
local conns = {}
local active = false
local function bind()
    local ch = localPlayer.Character; if not ch then return end
    local hum = ch:FindFirstChild("Humanoid"); if not hum then return end
    local an = hum:FindFirstChildOfClass("Animator"); if not an then return end
    table.insert(conns, an.AnimationPlayed:Connect(function(t)
        if not tbl.dashAssistEnabled then return end
        if t.Animation and string.find(tostring(t.Animation.AnimationId), "99157505926076", 1, true) then
            active = true
            local h = ch:FindFirstChild("Humanoid"); if h then h.AutoRotate = false end
            t.Stopped:Once(function()
                active = false
                local h2 = localPlayer.Character and localPlayer.Character:FindFirstChild("Humanoid")
                if h2 then h2.AutoRotate = true end
            end)
        end
    end))
end
LOGroup:AddToggle("LO_DashAssist", {
    Text = "冲刺辅助",
    Default = false,
    Callback = function(on)
        tbl.dashAssistEnabled = on
        if on then
            bind()
            table.insert(conns, localPlayer.CharacterAdded:Connect(function()
                task.wait(0.5); if tbl.dashAssistEnabled then bind() end
            end))
            table.insert(conns, RunService.Heartbeat:Connect(function()
                if not tbl.dashAssistEnabled or not active then return end
                if not fn12("LightsOut") then return end
                local ch = localPlayer.Character
                local hrp = ch and ch:FindFirstChild("HumanoidRootPart")
                if not hrp then return end
                local best, bd = nil, math.huge
                for _, p in pairs(Players:GetPlayers()) do
                    if p ~= localPlayer and p.Character
                    and p.Character:FindFirstChild("HumanoidRootPart")
                    and p.Character:FindFirstChild("Humanoid")
                    and p.Character.Humanoid.Health > 0 then
                        local d = (p.Character.HumanoidRootPart.Position - hrp.Position).Magnitude
                        if d < bd then bd = d; best = p end
                    end
                end
                if best then
                    local pos = best.Character.HumanoidRootPart.Position
                    hrp.CFrame = CFrame.lookAt(hrp.Position, Vector3.new(pos.X, hrp.Position.Y, pos.Z))
                end
            end))
        else
            active = false
            for _, c in pairs(conns) do pcall(function() c:Disconnect() end) end
            table.clear(conns)
        end
    end,
})
end
tbl2.autoTPRoofUnder30Thread = nil
LOGroup:AddToggle("LO_AutoTPRoof", {
Text = "血量低于30自动传屋顶",
Default = false,
Callback = function(on)
    tbl.autoTPRoofUnder30Enabled = on
    if on then
        if tbl2.autoTPRoofUnder30Thread then return end
        tbl2.autoTPRoofUnder30Thread = true
        task.spawn(function()
            local done = false
            while tbl2.autoTPRoofUnder30Thread and tbl.autoTPRoofUnder30Enabled do
                if fn12("LightsOut") then
                    local ch = localPlayer.Character
                    local hum = ch and ch:FindFirstChild("Humanoid")
                    local hrp = ch and ch:FindFirstChild("HumanoidRootPart")
                    if hum and hrp and hum.Health > 0 and hum.Health <= 30 and not done then
                        hrp.CFrame = CFrame.new(198, 145, -93); done = true
                    end
                else done = false end
                task.wait(0.5)
            end
            tbl2.autoTPRoofUnder30Thread = nil
        end)
    end
end,
})
LOGroup:AddToggle("LO_FullBright", {
Text = "全亮",
Default = false,
Callback = function(on)
    _G.LightsOutFullBrightEnabled = on
    if on then
        if not _G.LightsOutFullBrightCacheThread then
            _G.LightsOutFullBrightCacheThread = true
            task.spawn(function()
                _G.CachedBrightObjects = {}
                local c = workspace.DescendantAdded:Connect(function(d)
                    if _G.LightsOutFullBrightEnabled and fn12("LightsOut") then
                        if d:IsA("Light") or (d:IsA("BasePart") and d.Name == "ChangeColorLightsOut") then
                            table.insert(_G.CachedBrightObjects, d)
                        end
                    end
                end)
                local wasActive = false
                while _G.LightsOutFullBrightCacheThread do
                    local active = _G.LightsOutFullBrightEnabled and fn12("LightsOut")
                    if active and not wasActive then
                        table.clear(_G.CachedBrightObjects)
                        local m = workspace:FindFirstChild("LightsOutMap") or workspace
                        local i = 0
                        for _, d in ipairs(m:GetDescendants()) do
                            if _G.LightsOutFullBrightCacheThread then
                                if d:IsA("Light") or (d:IsA("BasePart") and d.Name == "ChangeColorLightsOut") then
                                    table.insert(_G.CachedBrightObjects, d)
                                end
                                i += 1
                                if i % 500 == 0 then task.wait() end
                            else break end
                        end
                    elseif not active and wasActive then
                        table.clear(_G.CachedBrightObjects)
                    end
                    task.wait(2)
                    wasActive = active
                end
                c:Disconnect()
            end)
        end
        if not _G.LightsOutFullBrightRenderThread then
            _G.LightsOutFullBrightRenderThread = RunService.RenderStepped:Connect(function()
                if not (_G.LightsOutFullBrightEnabled and fn12("LightsOut")) then return end
                Lighting.Ambient = Color3.fromRGB(150,150,150)
                Lighting.OutdoorAmbient = Color3.fromRGB(150,150,150)
                Lighting.Brightness = 1
                Lighting.ClockTime = 14
                local atm = Lighting:FindFirstChildOfClass("Atmosphere")
                if atm then atm.Density = 0 end
                local cc = Lighting:FindFirstChildOfClass("ColorCorrectionEffect")
                if cc then
                    cc.TintColor = Color3.fromRGB(255,255,255)
                    cc.Brightness = 0; cc.Contrast = 0; cc.Saturation = 0
                end
                if _G.CachedBrightObjects then
                    for _, o in ipairs(_G.CachedBrightObjects) do
                        if o and o.Parent then
                            if o:IsA("Light") then
                                o.Enabled = true
                                if o.Color.G < 0.2 and o.Color.B < 0.2 then o.Color = Color3.fromRGB(255,255,255) end
                            elseif o:IsA("BasePart") then
                                if o.Color.G < 0.2 and o.Color.B < 0.2 then o.Color = Color3.fromRGB(255,255,255) end
                            end
                        end
                    end
                end
            end)
        end
    else
        _G.LightsOutFullBrightCacheThread = false
        if _G.LightsOutFullBrightRenderThread then
            _G.LightsOutFullBrightRenderThread:Disconnect()
            _G.LightsOutFullBrightRenderThread = nil
        end
        if _G.CachedBrightObjects then table.clear(_G.CachedBrightObjects) end
    end
end,
})
do
local Players           = game:GetService("Players")
local Workspace         = game:GetService("Workspace")
local RunService        = game:GetService("RunService")
local localPlayer       = Players.LocalPlayer
local localPlayer2      = localPlayer
local RunService2       = RunService
local function PlayToggleSound() end
local function PlayErrorSound() end
local function PlayBell() end
local function notify(title, text, duration)
    Library:Notify({
        Title = tostring(title),
        Description = tostring(text or ""),
        Time = tonumber(duration) or 0.9,
    })
end
local function fn61(fn, ...)
    if type(fn) ~= "function" then return end
    local args = table.pack(...)
    task.spawn(function()
        pcall(fn, table.unpack(args, 1, args.n))
    end)
end
local function get_character()
    return localPlayer.Character
end
local function is_game_active(gameName)
    local values = Workspace:FindFirstChild("Values")
    if not values then return false end
    local currentGame = values:FindFirstChild("CurrentGame")
    return currentGame and currentGame.Value == gameName
end
local function safe_teleport(pos)
    local char = localPlayer.Character
    if not char then return false end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return false end
    hrp.CFrame = CFrame.new(pos)
    return true
end
do
    local enabled     = false
    local savedCFrame = nil
    LOGroup:AddToggle("LightsOutSafezone", {
        Text = "安全区传送",
        Tooltip = "传送到安全区 (178, 56, 50)，关闭时返回原位。在 HnS 作为 Hider 也有效",
        Default = false,
        Callback = function(Value)
            enabled = Value and true or false

            local char = get_character() or localPlayer2.Character
            local hrp
            if char then
                hrp = char:FindFirstChild("HumanoidRootPart") or char.PrimaryPart
            end
            if enabled then
                if hrp then
                    savedCFrame = hrp.CFrame
                    pcall(function()
                        hrp.CFrame = CFrame.new(178, 56, 50)
                    end)
                    notify("Lights Out", "已传送到安全区 (178, 56, 50)", 1)
                else
                    notify("Lights Out", "Character not found", 0.9)
                    PlayErrorSound()
                end
                PlayToggleSound()
                return true
            end
            if hrp and savedCFrame then
                pcall(function()
                    hrp.CFrame = savedCFrame
                end)
                notify("Lights Out", "已返回原位置", 1)
            end
            savedCFrame = nil
            PlayToggleSound()
            return true
        end,
    })
end
do
    local enabled       = false
    local connection    = nil
    local hasTeleported = false
    local lowHPChecked  = false
    LOGroup:AddToggle("SafePlaceLowHealth", {
        Text = "低血量自保",
        Tooltip = "血量 ≤ 30 时自动上升：LightsOut/HideAndSeek 为 +150，其他游戏为 +100",
        Default = false,
        Callback = function(Value)
            enabled = Value and true or false
            if connection then
                connection:Disconnect()
                connection = nil
            end
            hasTeleported = false
            lowHPChecked  = false
            if enabled then
                connection = RunService2.Heartbeat:Connect(function()
                    if not enabled then
                        if connection then
                            connection:Disconnect()
                            connection = nil
                        end
                        return
                    end
                    local skip = false
                    for _, v in pairs({
                        "Mingle",
                        "JumpRope",
                        "Pentathlon",
                        "GlassBridge",
                        "SquidGame",
                        "SkySquidGame",
                        "RedLightGreenLight",
                        "TugOfWar",
                    }) do
                        if is_game_active(v) then
                            skip = true
                            break
                        end
                    end
                    if skip then return end
                    local char = get_character()
                    if not char then return end
                    local hum = char:FindFirstChildOfClass("Humanoid")
                    if not hum then return end
                    if is_game_active("HideAndSeek")
                        or is_game_active("LightsOut")
                        or is_game_active("LightOut") then
                        if hum.Health <= 30 then
                            if not hasTeleported then
                                local hrp = char:FindFirstChild("HumanoidRootPart") or char.PrimaryPart
                                if hrp then
                                    local pos = hrp.Position
                                    hrp.CFrame = CFrame.new(Vector3.new(
                                        pos.X,
                                        pos.Y + 150,
                                        pos.Z
                                    ))
                                    hasTeleported = true
                                    lowHPChecked  = true
                                end
                            end
                        elseif hum.Health > 30 and hasTeleported then
                            hasTeleported = false
                        end
                    elseif hum.Health <= 30 then
                        if not hasTeleported then
                            local hrp = char:FindFirstChild("HumanoidRootPart") or char.PrimaryPart
                            if hrp then
                                local pos = hrp.Position
                                hrp.CFrame = CFrame.new(Vector3.new(
                                    pos.X,
                                    pos.Y + 100,
                                    pos.Z
                                ))
                                hasTeleported = true
                                lowHPChecked  = true
                            end
                        end
                    elseif hum.Health > 30 and hasTeleported then
                        hasTeleported = false
                    end
                end)
            end
            PlayToggleSound()
        end,
    })
end
LOGroup:AddDivider()
do
    local enabled     = false
    local connection  = nil
    local triggered   = {}
    local currentGame = nil
    local startTime   = nil
    local function step()
        if not enabled then return end
        local now = tick()
        local values = Workspace:FindFirstChild("Values")
        if not values then return end
        local cg = values:FindFirstChild("CurrentGame")
        if not cg then return end
        local gameName = cg.Value
        if not gameName or gameName == "" then return end
        if gameName ~= currentGame then
            currentGame = gameName
            startTime   = now
            triggered   = { Main = false }
            return
        end
        if not startTime then
            startTime = now
            return
        end
        local elapsed = now - startTime
        local char = get_character()
        if not char then return end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end

        if gameName == "LightsOut" or gameName == "LightOut" then
            if not triggered.Main and elapsed >= 15 then
                triggered.Main = true
                local pos = hrp.Position
                safe_teleport(Vector3.new(pos.X, pos.Y + 100, pos.Z))
                PlayBell()
                notify("AutoWin", "LightsOut: +100 上升完成", 1)
            end
        end
    end
    LOGroup:AddToggle("LightsOutAutoWin", {
        Text = "自动胜利",
        Tooltip = "进入 LightsOut 15 秒后自动 +100 上升躲避",
        Default = false,
        Callback = function(Value)
            enabled = Value and true or false
            if connection then
                connection:Disconnect()
                connection = nil
            end
            triggered   = {}
            currentGame = nil
            startTime   = nil

            if enabled then
                connection = RunService2.Heartbeat:Connect(step)
            end
            PlayToggleSound()
            return true
        end,
    })
end
end
--五项全能
btn(PentGroup, "自动完成画片", function()
if not guid then fn13(nil, "五项全能当前未运行。") return end
local cam = Workspace.CurrentCamera
local aim = cam.CFrame.Position + cam.CFrame.LookVector * 10
local vs = cam.ViewportSize
local ray = cam:ViewportPointToRay(vs.X*0.5, vs.Y*0.5)
local rp = RaycastParams.new()
rp.FilterType = Enum.RaycastFilterType.Include
local pmap = Workspace:FindFirstChild("PentathlonMap")
rp.FilterDescendantsInstances = pmap and { pmap } or {}
local hit = Workspace:Raycast(ray.Origin, ray.Direction*500, rp)
if hit and hit.Position then aim = hit.Position end
if fn16("Thrown", { Power = 1, Position = aim }) then fn13("五项全能", "画片已完成")
else fn13(" 错误", "等待游戏开始") end
end)
btn(PentGroup, "自动完成打石子", function()
if not guid then fn13(nil, "五项全能当前未运行。") return end
local ch = localPlayer.Character
local hrp = ch and ch:FindFirstChild("HumanoidRootPart")
if hrp then
    local tgt = nil
    for _, d in ipairs(Workspace:GetDescendants()) do
        if d.Name == "Target" and d:IsA("BasePart") then tgt = d; break end
    end
    local origin = hrp.Position + Vector3.new(0,1.5,0)
    if fn16("Thrown", {
        Direction = tgt and CFrame.lookAt(hrp.Position, tgt.Position, Vector3.new(0,1,0)).LookVector or Vector3.new(0,0,1),
        ThrowPower = "Perfect",
        Origin = origin,
    }) then fn13("五项全能", "打石子已完成")
    else fn13(" 错误", "等待游戏开始") end
end
end)
btn(PentGroup, "自动抓石子（连点）", function()
if not guid then fn13(nil, "五项全能当前未运行。") return end
task.spawn(function()
    pcall(function() fn16("Thrown", {}) end)
    for _, n2 in ipairs({
        "YTriangle","RCircle","Square","GTriangle","BCircle","BSquare","BTriangle","BStar","BUmbrella",
        "YCircle","YSquare","YStar","YUmbrella","RTriangle","RSquare","RStar","RUmbrella",
        "GCircle","GSquare","GStar","GUmbrella","Triangle","Circle","Star","Umbrella",
    }) do pcall(function() fn16("GotPiece", { Name = n2 }) end) end
    pcall(function() fn16("Catch", {}) end)
    pcall(function() fn16("Caught", {}) end)
    local ok = false
    pcall(function() ok = fn16("TimeSlowFinish", {}) end)
    if ok then fn13("五项全能", "抓石子部分已完成")
    else fn13(" 错误", "检查游戏是否已开始") end
end)
end)
btn(PentGroup, "自动完成陀螺", function()
if not guid then fn13(nil, "五项全能当前未运行。") return end
task.spawn(function()
    fn16("Tied", {}); task.wait(0.01)
    if fn16("Thrown", {}) then fn13("五项全能", "陀螺已完成")
    else fn13(" 错误", "等待游戏开始") end
end)
end)
btn(PentGroup, "自动完成踢毽子", function()
if not guid then fn13(nil, "五项全能当前未运行。") return end
task.spawn(function()
    local ok = false
    for _ = 1, 6 do ok = fn16("Kick", { Lose = false }); task.wait(0.01) end
    if ok then fn13("五项全能", "踢毽子已完成")
    else fn13(" 错误", "等待游戏开始") end
end)
end)
PentGroup:AddDivider()
do
local Players           = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace         = game:GetService("Workspace")
local localPlayer       = Players.LocalPlayer
local localPlayer2      = localPlayer
local function PlayToggleSound() end
local function PlayBell() end
local function PlayErrorSound() end
local function notify(title, text, duration)
Library:Notify({
Title = tostring(title),
Description = tostring(text or ""),
Time = tonumber(duration) or 0.9,
})
end
local function fn61(fn, ...)
if type(fn) ~= "function" then return end
local args = table.pack(...)
task.spawn(function()
pcall(fn, table.unpack(args, 1, args.n))
end)
end
local function getGameObject()
local character = localPlayer.Character
if not character then return nil end
local ok, result = pcall(function()
for _, v in ipairs(getgc(true)) do
if type(v) == "table"
and rawget(v, "GUID")
and rawget(v, "Players")
and rawget(v, "Active") then
local value = rawget(v, "Players")
if type(value) == "table" then
    for _, v2 in pairs(value) do
        if v2 == character then
            return v
        end
    end
end
end
end
return nil
end)
return ok and result or nil
end
local gameCache    = { obj = nil, time = 0 }
local inGameCache  = { val = false, time = 0 }
local function getCachedGame()
if tick() - gameCache.time > 2 then
gameCache.time = tick()
gameCache.obj  = getGameObject()
end
return gameCache.obj
end
local function isInPentathlon()
if tick() - inGameCache.time > 0.5 then
inGameCache.time = tick()
inGameCache.val  = localPlayer:GetAttribute("InPentathlon") == true
or Workspace:FindFirstChild("PentathlonMap") ~= nil
end
return inGameCache.val
end
local function getModule()
local ok, result = pcall(function()
return require(ReplicatedStorage.Modules.Games.PentathlonClient)
end)
return ok and result or nil
end
do
local enabled   = false
local thread    = nil
local lastThrow = 0
local power     = 0.95123884995606622
local position  = Vector3.new(-147.3337, 6001.0757, -19.965336)
PentGroup:AddToggle("AutoDdakji", {
Text = "自动打画片",
Tooltip = "用完美力度 0.9512 和固定坐标 ( -147.33, 6001.08, -19.97 ) 触发完美投掷",
Default = false,
Callback = function(Value)
enabled = Value and true or false
if thread then
task.cancel(thread)
thread = nil
end
if not enabled then
PlayToggleSound()
return
end
local module = getModule()
if not module then
PlayToggleSound()
return
end
thread = task.spawn(function()
while enabled do
    if isInPentathlon() then
        if tick() - lastThrow >= 1.5 then
            local game = getCachedGame()
            if game and game.Active
                and game.CurrentPlayer == localPlayer.Character then
                pcall(function()
                    module.RunServerGame(game, "Thrown", {
                        Power    = power,
                        Position = position,
                    })
                end)
                lastThrow = tick()
            end
        end
        task.wait(0.1)
        continue
    end
    break
end
thread = nil
end)
PlayToggleSound()
end,
})
end
do
local enabled = false
local thread  = nil
local last    = 0
local cache   = { stand = nil, game = nil }
PentGroup:AddToggle("AutoFlyingStone", {
Text = "自动飞石",
Tooltip = "从 PentathlonMap.Stand.Target 计算方向，用 Perfect 力度投掷",
Default = false,
Callback = function(Value)
enabled = Value and true or false
if thread then
task.cancel(thread)
thread = nil
end
if not enabled then
PlayToggleSound()
return
end
local module = getModule()
if not module then
PlayToggleSound()
return
end
thread = task.spawn(function()
while enabled do
    if isInPentathlon() then
        if tick() - last >= 1.5 then
            local game = getCachedGame()
            if game and game.Active
                and game.CurrentPlayer == localPlayer.Character then
                local character = localPlayer.Character
                local hrp = character
                    and character:FindFirstChild("HumanoidRootPart")
                if hrp then
                    if not cache.stand or cache.game ~= game then
                        cache.game = game
                        local map = Workspace:FindFirstChild("PentathlonMap")
                        cache.stand = map
                            and map:FindFirstChild("Stand", true)
                    end
                    local target
                    if cache.stand and cache.stand:FindFirstChild("Target") then
                        target = cache.stand.Target.Position
                    else
                        target = hrp.Position
                            + hrp.CFrame.LookVector * 20
                    end
                    local origin = hrp.Position + Vector3.new(0, 1.5, 0)
                    local unit = (target - origin).Unit
                    pcall(function()
                        module.RunServerGame(game, "Thrown", {
                            ThrowPower = "Perfect",
                            Origin     = origin,
                            Direction  = unit,
                        })
                    end)
                    last = tick()
                end
            end
        end
        task.wait(0.1)
        continue
    end
    break
end
thread = nil
end)
PlayToggleSound()
end,
})
end
do
local enabled = false
local thread  = nil
local last    = 0
local grabbed = {}
local lastGame = nil
PentGroup:AddToggle("AutoGonggi", {
Text = "自动抓子",
Tooltip = "依次抓取带 GrabHighlight 的部件，全部抓完后自动 TimeSlowFinish",
Default = false,
Callback = function(Value)
enabled = Value and true or false
if thread then
task.cancel(thread)
thread = nil
end
if not enabled then
PlayToggleSound()
return
end
local module = getModule()
if not module then
PlayToggleSound()
return
end
thread = task.spawn(function()
while enabled do
    if isInPentathlon() then
        local game = getCachedGame()
        if game and game.Active
            and game.CurrentPlayer == localPlayer.Character
            and tick() - last >= 2.5 then
            if game ~= lastGame then
                lastGame = game
                table.clear(grabbed)
            end
            local map = Workspace:FindFirstChild("PentathlonMap")
            if map then
                local target = nil
                for _, d in ipairs(map:GetDescendants()) do
                    if d:IsA("BasePart")
                        and d:FindFirstChild("GrabHighlight")
                        and not grabbed[d.Name] then
                        target = d
                        break
                    end
                end
                if target then
                    grabbed[target.Name] = true
                    last = tick()
                    task.spawn(function()
                        task.wait(0.4)
                        if game and game.Active then
                            pcall(function()
                                module.RunServerGame(game, "GotPiece", {
                                    Name = target.Name,
                                })
                            end)
                        end
                        task.wait(0.3)
                        if game and game.Active then
                            local done = true
                            for _, d in ipairs(map:GetDescendants()) do
                                if d:IsA("BasePart")
                                    and d:FindFirstChild("GrabHighlight")
                                    and not grabbed[d.Name] then
                                    done = false
                                    break
                                end
                            end
                            if done then
                                pcall(function()
                                    module.RunServerGame(game, "TimeSlowFinish")
                                end)
                            end
                        end
                    end)
                end
            end
        end
        task.wait(0.1)
        continue
    end
    break
end
thread = nil
end)
PlayToggleSound()
end,
})
end
do
local enabled = false
local thread  = nil
local phase   = "Tie"
local hooked  = false
local last    = 0
local lastGame = nil
local function hookGame(game)
if hooked or not game.HandleRequest then return end
local original = game.HandleRequest
game.HandleRequest = function(self, action, a, ...)
if action == "Aim" then
phase = "Aim"
elseif action == "SetPlayer" or action == "Restart" then
phase = "Tie"
elseif action == "Reset" then
phase = nil
end
local args = table.pack(...)
local fn = original
args.n = 4 + args.n - 1
table.move(args, 1, args.n, 4, args)
args[1] = self
args[2] = action
args[3] = a
return fn(table.unpack(args, 1, args.n))
end
hooked = true
end
PentGroup:AddToggle("AutoSpinningTop", {
Text = "自动陀螺",
Tooltip = "Hook HandleRequest 拦截阶段变化，自动 Tied / Thrown",
Default = false,
Callback = function(Value)
enabled = Value and true or false
if thread then
task.cancel(thread)
thread = nil
end
if not enabled then
PlayToggleSound()
return
end
local module = getModule()
if not module then
PlayToggleSound()
return
end
thread = task.spawn(function()
while enabled do
    if isInPentathlon() then
        local game = getCachedGame()
        if game and game.Active then
            if game ~= lastGame then
                lastGame = game
                hooked   = false
                phase    = "Tie"
                hookGame(game)
            end
            if game.CurrentPlayer == localPlayer.Character then
                local now = tick()
                if phase == "Tie" and now - last > 0.3 then
                    pcall(function()
                        module.RunServerGame(game, "Tied", {})
                    end)
                    last = now
                elseif phase == "Aim" and now - last > 1.5 then
                    pcall(function()
                        module.RunServerGame(game, "Thrown", {})
                    end)
                    last = now
                end
            end
        end
        task.wait(0.1)
        continue
    end
    break
end
thread = nil
end)
PlayToggleSound()
end,
})
end
do
local enabled = false
local thread  = nil
local last    = 0
PentGroup:AddToggle("AutoJegi", {
Text = "自动踢毽子",
Tooltip = "调用 Kick 且 Lose=false，永不失败",
Default = false,
Callback = function(Value)
enabled = Value and true or false
if thread then
task.cancel(thread)
thread = nil
end
if not enabled then
PlayToggleSound()
return
end
local module = getModule()
if not module then
PlayToggleSound()
return
end
thread = task.spawn(function()
while enabled do
    if isInPentathlon() then
        if tick() - last >= 0.8 then
            local game = getCachedGame()
            if game and game.Active
                and game.CurrentPlayer == localPlayer.Character then
                pcall(function()
                    module.RunServerGame(game, "Kick", {
                        Lose = false,
                    })
                end)
                last = tick()
            end
        end
        task.wait(0.1)
        continue
    end
    break
end
thread = nil
end)
PlayToggleSound()
end,
})
end
end
--晚餐
do
local Players     = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local function PlayToggleSound() end
local function Notify(Title, Description, Time)
Library:Notify({ Title = Title, Description = Description, Time = Time or 3 })
end
Wcgn:AddDivider()
do
local enabled      = false
local thread       = nil
local originalPos  = nil
local isTeleported = false
Wcgn:AddToggle("DinnerTeleport", {
Text = "区域击杀",
Tooltip = "当玩家出现长刀动画时，自动传送到击杀区域；动画结束后返回原位置",
Default = false,
Callback = function(Value)
enabled = Value and true or false
if thread then
    pcall(function() task.cancel(thread) end)
    thread = nil
end
originalPos  = nil
isTeleported = false
if not enabled then
    Notify("最后的晚餐", "区域击杀 已禁用", 2)
    PlayToggleSound()
    return
end
thread = task.spawn(function()
    while enabled do
        local Live = workspace:FindFirstChild("Live")
        if Live then
            local MyModel = Live:FindFirstChild(LocalPlayer.Name)
            if MyModel then
                local Folder = MyModel:FindFirstChild("Folder")
                if Folder and Folder:IsA("Folder") then
                    if not isTeleported then
                        local Character = LocalPlayer.Character
                        local Root = Character and Character:FindFirstChild("HumanoidRootPart")
                        if Root then
                            originalPos  = Root.Position
                            isTeleported = true
                            Root.CFrame = CFrame.new(197, 54, -74)
                            Notify("最后的晚餐", "晚餐时间！", 2)
                        end
                    end
                elseif isTeleported and originalPos then
                    local Character = LocalPlayer.Character
                    local Root = Character and Character:FindFirstChild("HumanoidRootPart")
                    if Root then
                        Root.CFrame = CFrame.new(originalPos)
                        Notify("最后的晚餐", "已返回", 2)
                    end
                    isTeleported = false
                    originalPos  = nil
                end
            end
        end
        task.wait(0.1)
    end
end)
Notify("最后的晚餐", "区域击杀 已启用", 2)
PlayToggleSound()
end,
})
end
do
local enabled   = false
local loop      = nil
local originals = {}
local function enableBarrier()
    local Effects = workspace:FindFirstChild("Effects")
    if not Effects then return end
    for _, Part in pairs(Effects:GetDescendants()) do
        if Part:IsA("MeshPart") and Part.Name == "StormBarrier" then
            if not originals[Part] then
                originals[Part] = {
                    CanCollide   = Part.CanCollide,
                    Anchored     = Part.Anchored,
                    Transparency = Part.Transparency,
                }
            end
            Part.CanCollide   = true
            Part.Anchored     = true
            Part.Transparency = 0.5
        end
    end
end
local function restoreBarrier()
    local Effects = workspace:FindFirstChild("Effects")
    if not Effects then return 0 end
    local Count = 0
    for _, Part in pairs(Effects:GetDescendants()) do
        if Part:IsA("MeshPart") and Part.Name == "StormBarrier" then
            local Original = originals[Part]
            if Original then
                Part.CanCollide   = Original.CanCollide
                Part.Anchored     = Original.Anchored
                Part.Transparency = Original.Transparency
            else
                Part.CanCollide   = false
                Part.Anchored     = false
                Part.Transparency = 0
            end
            Count += 1
        end
    end
    originals = {}
    return Count
end
local zoneBarrierToggle = Wcgn:AddToggle("ZoneBarrier", {
    Text = "区域屏障",
    Tooltip = "启用风暴屏障的碰撞，防止玩家走出安全区",
    Default = false,
    Callback = function(Value)
        enabled = Value and true or false
        if loop then
            pcall(function() task.cancel(loop) end)
            loop = nil
        end
        if not enabled then
            local Count = restoreBarrier()
            if Count > 0 then
                Notify("最后的晚餐", "已还原 " .. Count .. " 个屏障", 2)
            else
                Notify("最后的晚餐", "区域屏障 已禁用", 2)
            end
            PlayToggleSound()
            return
        end
        originals = {}
        enableBarrier()
        loop = task.spawn(function()
            while enabled do
                task.wait(1)
                enableBarrier()
            end
        end)
        Notify("最后的晚餐", "区域屏障 已启用", 2)
        PlayToggleSound()
    end,
})
if zoneBarrierToggle and zoneBarrierToggle.AddKeyPicker then
    zoneBarrierToggle:AddKeyPicker("ZoneBarrierKey", {
        Default = "None",
        Text = "区域屏障快捷键",
        Mode = "Toggle",
        NoUI = false,
        SyncToggleState = true,
    })
else
    Wcgn:AddKeyPicker("ZoneBarrierKey", {
        Default = "None",
        Text = "区域屏障快捷键",
        Mode = "Toggle",
        NoUI = false,
        SyncToggleState = true,
    })
end
if Options.ZoneBarrierKey then
    Options.ZoneBarrierKey:OnClick(function()
        local State = Options.ZoneBarrier and Options.ZoneBarrier.Value
        Notify("最后的晚餐", "区域屏障 " .. (State and "已启用" or "已禁用"), 2)
    end)
end
end
end
do
 local Players      = game:GetService("Players")
local Workspace    = game:GetService("Workspace")
local RunService   = game:GetService("RunService")
local localPlayer  = Players.LocalPlayer
local localPlayer2 = localPlayer
local RunService2  = RunService
local function PlayToggleSound() end
local function PlayErrorSound() end
local function PlayBell() end
local function notify(title, text, duration)
    if Library and Library.Notify then
        Library:Notify({
            Title = tostring(title),
            Description = tostring(text or ""),
            Time = tonumber(duration) or 0.9,
        })
    else
        print("[" .. tostring(title) .. "] " .. tostring(text))
    end
end
local function fn61(fn, ...)
    if type(fn) ~= "function" then return end
    local args = table.pack(...)
    task.spawn(function()
        pcall(fn, table.unpack(args, 1, args.n))
    end)
end
local function get_character()
    return localPlayer.Character
end
local function get_humanoid(ch)
    return ch and ch:FindFirstChildOfClass("Humanoid")
end
local function is_game_active(gameName)
    local values = Workspace:FindFirstChild("Values")
    if not values then return false end
    local currentGame = values:FindFirstChild("CurrentGame")
    return currentGame and currentGame.Value == gameName
end
local function disable_toggle(toggleId)
    local opt = Options and Options[toggleId]
    if opt and opt.SetValue then
        pcall(function() opt:SetValue(false) end)
    end
end
local function safe_teleport(pos)
    local char = localPlayer.Character
    if not char then return false end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return false end
    hrp.CFrame = CFrame.new(pos)
    return true
end
do
    local enabled         = false
    local animationId     = "rbxassetid://105341857343164"
    local zonePosition    = Vector3.new(197.7, 54.6, -96.3)
    local returnDelay     = 0.6
    local savedCFrame     = nil
    local activeAnimation = false
    local animConnection  = nil
    local charConn        = nil
    local checkConn       = nil
    local stoppedConns    = {}
    local trackedAnims    = {}   
    local function handleAnimation(character, track)
        if not track or not track.Animation then return end
        local id = track.Animation.AnimationId
        if id ~= animationId then return end
        local key = id .. "_" .. tostring(track)       
        if trackedAnims[key] then return end       
        if activeAnimation then return end
        trackedAnims[key] = true
        activeAnimation   = true
        savedCFrame = character:GetPrimaryPartCFrame()
        character:SetPrimaryPartCFrame(CFrame.new(zonePosition))
        local conn = track.Stopped:Connect(function()
            task.wait(returnDelay)
            if savedCFrame then
                character:SetPrimaryPartCFrame(savedCFrame)
                savedCFrame = nil
            end
            activeAnimation = false
            trackedAnims    = {}
        end)
        table.insert(stoppedConns, conn)
    end
    local function checkTracks()
        if not enabled then return end
        local char = get_character()
        if not char then return end
        local hum = get_humanoid(char)
        if not hum then return end
        for _, track in pairs(hum:GetPlayingAnimationTracks()) do
            if track and track.Animation then
                local id = track.Animation.AnimationId
                if id == animationId then
                    local key = id .. "_" .. tostring(track)
                    if not trackedAnims[key] then
                        handleAnimation(char, track)
                    end
                end
            end
        end
    end   
    local function hookCharacter(character)
        local hum = character:WaitForChild("Humanoid", 5)
        if not hum then return end

        animConnection = hum.AnimationPlayed:Connect(function(track)
            if not enabled then return end
            handleAnimation(character, track)
        end)
    end
    Wcgn:AddToggle("ZoneKill", {
        Text = "传送击杀",
        Tooltip = "触发击杀动画时把角色传送到击杀区 (197.7, 54.6, -96.3)，动画结束 0.6s 后回原位。需持刀 + 背刺命中",
        Default = false,
        Callback = function(Value)            
            if Value then
                if not is_game_active("LastDinner") then
                    notify("Zone Kill", "Wait for LastDinner!", 0.9)
                    PlayErrorSound()
                    disable_toggle("ZoneKill")
                    return false
                end
            end
            enabled = Value and true or false            
            if animConnection then animConnection:Disconnect(); animConnection = nil end
            if charConn then charConn:Disconnect(); charConn = nil end
            if checkConn then checkConn:Disconnect(); checkConn = nil end
            for _, c in ipairs(stoppedConns) do
                pcall(function() c:Disconnect() end)
            end
            stoppedConns    = {}
            savedCFrame     = nil
            activeAnimation = false
            trackedAnims    = {}         
            if not enabled then
                PlayToggleSound()
                return true
            end
            if localPlayer2.Character then
                hookCharacter(localPlayer2.Character)
            end
            charConn = localPlayer2.CharacterAdded:Connect(function(character)
                task.wait(1)
                if enabled then
                    hookCharacter(character)
                end
            end)
            checkConn = RunService2.Heartbeat:Connect(function()
                if not enabled then return end
                checkTracks()
            end)
            PlayToggleSound()
            return true
        end,
    })
end
Wcgn:AddButton({
    Text = "遁地（地下安全）",
    Tooltip = "传送到地下 (0, -50, 0)，敌人攻击打不到地下，避免被击杀。仅 LastDinner 中生效",
    Func = function()
        if is_game_active("LastDinner") then          
            safe_teleport(Vector3.new(0, -50, 0))
            notify("Last Dinner", "已遁地（地下 -50）", 0.9)
        else
            notify("Last Dinner", "Wait for LastDinner!", 0.9)
            PlayErrorSound()
        end
        PlayBell()
    end,
})
end
--捉迷藏
btn(HSTOWGroup, "传送安全区", function()
if not fn12("HideAndSeek") then fn13(nil, "捉迷藏当前未激活") return end
local ch = localPlayer.Character
if ch and ch:FindFirstChild("HumanoidRootPart") then
    fn17(CFrame.new(0, 100, 0))
    fn13(" 已逃脱", "已传送到安全区")
end
end)
tbl2.autoGetKeysThread = nil
HSTOWGroup:AddToggle("HSTOW_AutoKeys", {
Text = "自动获取缺失钥匙",
Default = false,
Callback = function(on)
tbl.autoGetKeysEnabled = on
if on then
if tbl2.autoGetKeysThread then return end
tbl2.autoGetKeysThread = true
task.spawn(function()
    local keys = { "Circle", "Square", "Triangle" }
    while tbl.autoGetKeysEnabled and tbl2.autoGetKeysThread do
        if fn12("HideAndSeek") then
            local cur = localPlayer:FindFirstChild("CurrentKeys")
            if cur then
                local have = {}
                for _, c in ipairs(cur:GetChildren()) do have[c.Name] = true end
                local need = {}
                for _, k in ipairs(keys) do if not have[k] then need[k] = true end end
                local eff = workspace:FindFirstChild("Effects")
                if eff then
                    for _, c in ipairs(eff:GetChildren()) do
                        if string.sub(c.Name,1,10) == "DroppedKey" and need[string.sub(c.Name,11)] then
                            local ch = localPlayer.Character
                            local hrp = ch and ch:FindFirstChild("HumanoidRootPart")
                            if hrp then
                                local pivot = c:IsA("Model") and c:GetPivot() or c.CFrame
                                local back = hrp.CFrame
                                hrp.CFrame = pivot
                                task.wait(0.1)
                                hrp.CFrame = back
                                break
                            end
                        end
                    end
                end
            end
        end
        task.wait(0.1)
    end
    tbl2.autoGetKeysThread = nil
end)
else tbl2.autoGetKeysThread = nil end
end,
})

tbl2.infiniteStaminaThread = nil
HSTOWGroup:AddToggle("HSTOW_Stamina", {
Text = "无限体力",
Default = false,
Callback = function(on)
    tbl.infiniteStaminaEnabled = on
    if on then
        if tbl2.infiniteStaminaThread then return end
        tbl2.infiniteStaminaThread = RunService.RenderStepped:Connect(function()
            if fn12("HideAndSeek") then
                local ch = localPlayer.Character
                if ch then
                    local s = ch:FindFirstChild("StaminaVal")
                    if s and s:IsA("NumberValue") then s.Value = 100 end
                end
            end
        end)
    elseif tbl2.infiniteStaminaThread then
        tbl2.infiniteStaminaThread:Disconnect()
        tbl2.infiniteStaminaThread = nil
    end
end,
})
HSTOWGroup:AddToggle("HSTOW_BalloonFarm", {
Text = "自动刷气球",
Default = false,
Callback = function(on)
    tbl.autoPopBalloonsEnabled = on
end,
})
tbl2.hideAndSeekQTEThread = nil
HSTOWGroup:AddToggle("HSTOW_QTE", {
Text = "自动 QTE 事件",
Default = false,
Callback = function(on)
    tbl.hideAndSeekAutoQTEEnabled = on
    if on and not tbl2.hideAndSeekQTEThread then
        tbl2.hideAndSeekQTEThread = task.spawn(function()
            local seen = {}
            while tbl.hideAndSeekAutoQTEEnabled do
                if fn12("HideAndSeek") then
                    local m = fn15()
                    if m and m.ActiveButtons then
                        for k, a in pairs(m.ActiveButtons) do
                            if not seen[k] and a then
                                seen[k] = true
                                if tbl.hideAndSeekAutoQTEEnabled and fn12("HideAndSeek") and m.ActiveButtons[k] then
                                    pcall(function() m.Pressed(false, m.ActiveButtons[k]) end)
                                end
                            end
                        end
                        for k in pairs(seen) do if not m.ActiveButtons[k] then seen[k] = nil end end
                    end
                else table.clear(seen) end
                task.wait()
            end
            tbl2.hideAndSeekQTEThread = nil
        end)
    end
end,
})
HSTOWGroup:AddButton({Text="点击传送(尖刺击杀手动功能)",Func=function()
local UIS      = game:GetService("UserInputService")
local Tween    = game:GetService("TweenService")
local RunSvc   = game:GetService("RunService")
local Players  = game:GetService("Players")
local player   = Players.LocalPlayer
local TELEPORT_POSITIONS = {
Vector3.new(191.0, 1029.5, 154.7),
Vector3.new(98.7, 1009.3, -8.3),
Vector3.new(192.8, 1016.8, 152.7),
}
local Y_OFFSET = 3
local BALL_SIZE    = 68
local ACCENT_MAIN  = Color3.fromRGB(88, 132, 255)
local ACCENT_DONE  = Color3.fromRGB(255, 138, 66)
local ACCENT_ERR   = Color3.fromRGB(255, 74, 74)

if player:WaitForChild("PlayerGui"):FindFirstChild("TeleportGui") then
player.PlayerGui.TeleportGui:Destroy()
end
local screenGui = Instance.new("ScreenGui")
screenGui.Name            = "TeleportGui"
screenGui.ResetOnSpawn    = false
screenGui.IgnoreGuiInset  = true
screenGui.ZIndexBehavior  = Enum.ZIndexBehavior.Sibling
screenGui.Parent          = player:WaitForChild("PlayerGui")
local ball = Instance.new("Frame")
ball.Name                  = "FloatBall"
ball.Size                  = UDim2.fromOffset(BALL_SIZE, BALL_SIZE)
ball.Position              = UDim2.new(1, -90, 0.5, -BALL_SIZE/2)
ball.BackgroundColor3      = ACCENT_MAIN
ball.BorderSizePixel       = 0
ball.Active                = true
ball.ClipsDescendants      = false
ball.Parent                = screenGui
local ballCorner = Instance.new("UICorner")
ballCorner.CornerRadius = UDim.new(1, 0)
ballCorner.Parent       = ball
local gradient = Instance.new("UIGradient")
gradient.Rotation  = 135
gradient.Color     = ColorSequence.new({
ColorSequenceKeypoint.new(0, Color3.fromRGB(255,255,255)),
ColorSequenceKeypoint.new(1, ACCENT_MAIN),
})
gradient.Parent    = ball
local ballStroke = Instance.new("UIStroke")
ballStroke.Color        = Color3.fromRGB(255, 255, 255)
ballStroke.Thickness    = 2
ballStroke.Transparency = 0.35
ballStroke.Parent       = ball
local glow = Instance.new("ImageLabel")
glow.Name                   = "Glow"
glow.BackgroundTransparency = 1
glow.Image                  = "rbxassetid://5028857084"
glow.ImageColor3            = ACCENT_MAIN
glow.ImageTransparency      = 0.45
glow.Size                   = UDim2.new(1, 28, 1, 28)
glow.Position               = UDim2.new(0, -14, 0, -14)
glow.ZIndex                 = 0
glow.Parent                 = ball
local clickButton = Instance.new("TextButton")
clickButton.Name                    = "ClickButton"
clickButton.Size                    = UDim2.new(1, 0, 1, 0)
clickButton.BackgroundTransparency  = 1
clickButton.Text                    = ""
clickButton.AutoButtonColor         = false
clickButton.Parent                  = ball
local iconLabel = Instance.new("TextLabel")
iconLabel.Name                   = "IconLabel"
iconLabel.Size                   = UDim2.new(1, 0, 1, -12)
iconLabel.Position               = UDim2.new(0, 0, 0, -4)
iconLabel.BackgroundTransparency = 1
iconLabel.Text                   = "传"
iconLabel.TextColor3             = Color3.fromRGB(255, 255, 255)
iconLabel.TextScaled             = true
iconLabel.Font                   = Enum.Font.GothamBold
iconLabel.Parent                 = ball
local iconStroke = Instance.new("UIStroke")
iconStroke.Color        = Color3.fromRGB(0, 0, 0)
iconStroke.Thickness    = 2
iconStroke.Transparency = 0.55
iconStroke.Parent       = iconLabel
local statusLabel = Instance.new("TextLabel")
statusLabel.Name                   = "StatusLabel"
statusLabel.Size                   = UDim2.new(0, 108, 0, 22)
statusLabel.Position               = UDim2.new(0.5, -54, 1, 4)
statusLabel.BackgroundColor3       = Color3.fromRGB(15, 15, 20)
statusLabel.BackgroundTransparency = 0.15
statusLabel.Text                   = "点击传送"
statusLabel.TextColor3             = Color3.fromRGB(230, 230, 240)
statusLabel.TextScaled             = true
statusLabel.Font                   = Enum.Font.GothamMedium
statusLabel.BorderSizePixel        = 0
statusLabel.Parent                 = ball
local statusCorner = Instance.new("UICorner")
statusCorner.CornerRadius = UDim.new(0, 8)
statusCorner.Parent       = statusLabel
local statusStroke = Instance.new("UIStroke")
statusStroke.Color        = Color3.fromRGB(255, 255, 255)
statusStroke.Thickness    = 1
statusStroke.Transparency = 0.75
statusStroke.Parent       = statusLabel
local closeButton = Instance.new("TextButton")
closeButton.Name             = "CloseButton"
closeButton.Size             = UDim2.fromOffset(20, 20)
closeButton.Position         = UDim2.new(1, -6, 0, -6)
closeButton.BackgroundColor3 = Color3.fromRGB(30, 30, 36)
closeButton.BorderSizePixel  = 0
closeButton.Text             = "×"
closeButton.TextColor3       = Color3.fromRGB(255, 255, 255)
closeButton.TextScaled       = true
closeButton.Font             = Enum.Font.GothamBold
closeButton.ZIndex           = 5
closeButton.AutoButtonColor  = false
closeButton.Parent           = ball
local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(1, 0)
closeCorner.Parent       = closeButton
local closeStroke = Instance.new("UIStroke")
closeStroke.Color        = Color3.fromRGB(255, 255, 255)
closeStroke.Thickness    = 1.5
closeStroke.Transparency = 0.4
closeStroke.Parent       = closeButton
local isAtTarget   = false
local savedPos     = nil
local statusToken  = 0
local function setAccent(color)
ball.BackgroundColor3 = color
glow.ImageColor3      = color
gradient.Color        = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(255,255,255)),
    ColorSequenceKeypoint.new(1, color),
})
end
local function flashStatus(text, color, duration)
statusToken += 1
local myToken = statusToken
statusLabel.Text       = text
statusLabel.TextColor3 = color
task.delay(duration or 1.6, function()
    if myToken ~= statusToken then return end
    statusLabel.Text       = isAtTarget and "点击返回" or "点击传送"
    statusLabel.TextColor3 = Color3.fromRGB(230, 230, 240)
end)
end
local function updateUI()
if isAtTarget then
    statusLabel.Text = "点击返回"
    setAccent(ACCENT_DONE)
else
    statusLabel.Text = "点击传送"
    setAccent(ACCENT_MAIN)
end
end
task.spawn(function()
while ball.Parent do
    local t = Tween:Create(glow, TweenInfo.new(1.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
        ImageTransparency = 0.15,
        Size              = UDim2.new(1, 40, 1, 40),
        Position          = UDim2.new(0, -20, 0, -20),
    })
    t:Play(); t.Completed:Wait()
    if not ball.Parent then break end
    local t2 = Tween:Create(glow, TweenInfo.new(1.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
        ImageTransparency = 0.45,
        Size              = UDim2.new(1, 28, 1, 28),
        Position          = UDim2.new(0, -14, 0, -14),
    })
    t2:Play(); t2.Completed:Wait()
end
end)
closeButton.MouseEnter:Connect(function()
Tween:Create(closeButton, TweenInfo.new(0.15), { BackgroundColor3 = ACCENT_ERR }):Play()
end)
closeButton.MouseLeave:Connect(function()
Tween:Create(closeButton, TweenInfo.new(0.15), { BackgroundColor3 = Color3.fromRGB(30,30,36) }):Play()
end)
closeButton.MouseButton1Click:Connect(function()
Tween:Create(ball, TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
    Size = UDim2.fromOffset(0, 0),
}):Play()
task.wait(0.22)
screenGui:Destroy()
end)
clickButton.MouseEnter:Connect(function()
Tween:Create(ball, TweenInfo.new(0.15), { Size = UDim2.fromOffset(BALL_SIZE+6, BALL_SIZE+6) }):Play()
end)
clickButton.MouseLeave:Connect(function()
Tween:Create(ball, TweenInfo.new(0.15), { Size = UDim2.fromOffset(BALL_SIZE, BALL_SIZE) }):Play()
end)
clickButton.MouseButton1Click:Connect(function()
Tween:Create(ball, TweenInfo.new(0.08), { Size = UDim2.fromOffset(BALL_SIZE-6, BALL_SIZE-6) }):Play()
task.delay(0.1, function()
    Tween:Create(ball, TweenInfo.new(0.12), { Size = UDim2.fromOffset(BALL_SIZE, BALL_SIZE) }):Play()
end)
local character = player.Character
if not character then
    flashStatus("角色不存在", ACCENT_ERR, 1.2)
    return
end
local hrp = character:FindFirstChild("HumanoidRootPart")
if not hrp then
    flashStatus("无法传送", ACCENT_ERR, 1.2)
    return
end
if not isAtTarget then
    savedPos = hrp.CFrame        
    local basePos = TELEPORT_POSITIONS[math.random(1, #TELEPORT_POSITIONS)]
    local targetPos = basePos + Vector3.new(0, Y_OFFSET, 0)

    hrp.CFrame = CFrame.new(targetPos)
    isAtTarget = true
    updateUI()
    flashStatus("已传送 ✓", Color3.fromRGB(120, 255, 160), 1.2)
else
    if savedPos then
        hrp.CFrame = savedPos
        flashStatus("已返回 ✓", Color3.fromRGB(120, 255, 160), 1.2)
    else
        flashStatus("无返回点", ACCENT_ERR, 1.2)
    end
    isAtTarget = false
    updateUI()
end
end)
local dragging    = false
local moved       = false
local dragStart   = nil
local startPos    = nil
local DRAG_SLOP   = 6
local function posToVector2(p, parentSize)
return Vector2.new(
    p.X.Scale * parentSize.X + p.X.Offset,
    p.Y.Scale * parentSize.Y + p.Y.Offset
)
end
local function vector2ToOffset(v, parentSize)
return UDim2.fromOffset(v.X, v.Y)
end
ball.InputBegan:Connect(function(input)
if input.UserInputType == Enum.UserInputType.MouseButton1
    or input.UserInputType == Enum.UserInputType.Touch then
    dragging  = true
    moved     = false
    dragStart = Vector2.new(input.Position.X, input.Position.Y)
    startPos  = ball.AbsolutePosition
end
end)
UIS.InputChanged:Connect(function(input)
if not dragging then return end
if input.UserInputType == Enum.UserInputType.MouseMovement
    or input.UserInputType == Enum.UserInputType.Touch then
    local cur = Vector2.new(input.Position.X, input.Position.Y)
    local delta = cur - dragStart
    if not moved and delta.Magnitude >= DRAG_SLOP then
        moved = true
    end
    if moved then
        local parent = ball.Parent
        local parentSize = parent and parent.AbsoluteSize or Vector2.new(1920, 1080)
        local newAbs = startPos + delta
        local maxX = parentSize.X - ball.AbsoluteSize.X
        local maxY = parentSize.Y - ball.AbsoluteSize.Y
        newAbs = Vector2.new(
            math.clamp(newAbs.X, 0, math.max(0, maxX)),
            math.clamp(newAbs.Y, 0, math.max(0, maxY))
        )
        ball.Position = vector2ToOffset(newAbs, parentSize)
    end
end
end)
UIS.InputEnded:Connect(function(input)
if input.UserInputType == Enum.UserInputType.MouseButton1
    or input.UserInputType == Enum.UserInputType.Touch then
    dragging = false
    moved    = false
end
end)
updateUI()
print("[TeleportGui] 新 GUI 已加载。")
updateStatus()
    local Func = loadstring(ScriptContent);
    if Func then
            Func();
    end
end});
HSTOWGroup:AddToggle('SpikeProtectionToggle', {
Text = '防尖刺平台',
Default = false,
Tooltip = '开启后生成保护平台，关闭后自动删除',
Callback = function(Value)
    if Value then
        spawnPlatform()
    else
        removePlatform()
    end
end
})
local PLATFORM_POSITIONS = {
Vector3.new(191.0, 1029.5, 154.7),
Vector3.new(98.7, 1009.3, -8.3),
Vector3.new(192.8, 1016.8, 152.7),
}
PlatformObjects = {}
function spawnPlatform()
removePlatform()
for _, pos in ipairs(PLATFORM_POSITIONS) do
    local SafePlatform = Instance.new("Part")
    SafePlatform.Size = Vector3.new(35, 0.5, 35)
    SafePlatform.Anchored = true
    SafePlatform.CanCollide = true
    SafePlatform.Position = pos
    SafePlatform.Material = Enum.Material.SmoothPlastic
    SafePlatform.Color = Color3.fromRGB(120, 120, 120)
    SafePlatform.Transparency = 0.9
    SafePlatform.Name = "SpikeProtectionPlatform"
    SafePlatform.Parent = Workspace
    table.insert(PlatformObjects, SafePlatform)
end
end
function removePlatform()
if PlatformObjects then
    for _, obj in ipairs(PlatformObjects) do
        if obj then
            obj:Destroy()
        end
    end
    PlatformObjects = {}
end
for _, obj in ipairs(Workspace:GetChildren()) do
    if obj.Name == "SpikeProtectionPlatform" then
        obj:Destroy()
    end
end
end

--身份透视
do
local hl, conns = {}, {}
local function add(p)
    if not tbl.espRolesEnabled or p == localPlayer then return end
    local c = p.Character; if not c then return end
    if hl[p] then hl[p]:Destroy(); hl[p] = nil end
    local isH = p:GetAttribute("IsHider")
    local isHu = p:GetAttribute("IsHunter")
    if not isH and not isHu then return end
    local h = Instance.new("Highlight")
    h.FillTransparency = 0.4; h.OutlineTransparency = 0
    if isH then h.FillColor = Color3.fromRGB(50,255,50); h.OutlineColor = Color3.fromRGB(30,200,30)
    else h.FillColor = Color3.fromRGB(255,50,50); h.OutlineColor = Color3.fromRGB(200,30,30) end
    h.Adornee = c; h.Parent = c
    hl[p] = h
end
local function clr()
    for _, c in pairs(conns) do pcall(function() c:Disconnect() end) end
    table.clear(conns)
    for _, h in pairs(hl) do if h and h.Parent then h:Destroy() end end
    table.clear(hl)
end
local function watch(p)
    if p == localPlayer then return end
    table.insert(conns, p:GetAttributeChangedSignal("IsHider"):Connect(function() if tbl.espRolesEnabled then add(p) end end))
    table.insert(conns, p:GetAttributeChangedSignal("IsHunter"):Connect(function() if tbl.espRolesEnabled then add(p) end end))
    table.insert(conns, p.CharacterAdded:Connect(function() task.wait(0.5); if tbl.espRolesEnabled then add(p) end end))
    add(p)
end
HSTOWGroup:AddToggle("HSTOW_ESPRoles", {
    Text = "身份透视",
    Default = false,
    Callback = function(on)
        tbl.espRolesEnabled = on
        if on then
            clr()
            for _, p in pairs(Players:GetPlayers()) do watch(p) end
            table.insert(conns, Players.PlayerAdded:Connect(function(p) task.wait(1); if tbl.espRolesEnabled then watch(p) end end))
            table.insert(conns, Players.PlayerRemoving:Connect(function(p) if hl[p] then hl[p]:Destroy(); hl[p] = nil end end))
        else clr() end
    end,
})
end
do
local listA = {}
local function clearA()
    for _, x in pairs(listA) do if x then x:Destroy() end end
    table.clear(listA)
end
tbl2.espExitDoorsThread = nil
HSTOWGroup:AddToggle("HSTOW_ESPDoors", {
    Text = "透视出口门",
    Default = false,
    Callback = function(on)
        tbl.espExitDoorsEnabled = on
        if on then
            if tbl2.espExitDoorsThread then return end
            tbl2.espExitDoorsThread = true
            task.spawn(function()
                while tbl.espExitDoorsEnabled and tbl2.espExitDoorsThread do
                    if fn12("HideAndSeek") then
                        local m = workspace:FindFirstChild("HideAndSeekMap")
                        m = m and m:FindFirstChild("NEWFIXEDDOORS")
                        m = m and m:FindFirstChild("Floor1")
                        m = m and m:FindFirstChild("EXITDOORS")
                        if m then
                            for _, c in ipairs(m:GetChildren()) do
                                if c.Name == "EXITDOOR" and not c:FindFirstChild("DoorESP") then
                                    local h = Instance.new("Highlight")
                                    h.Name = "DoorESP"
                                    h.FillColor = Color3.new(1,0,0)
                                    h.OutlineColor = Color3.new(1,0,0)
                                    h.FillTransparency = 0.5
                                    h.OutlineTransparency = 0
                                    h.Parent = c
                                    table.insert(listA, h)
                                end
                            end
                        end
                    else clearA() end
                    task.wait(1.5)
                end
                clearA(); tbl2.espExitDoorsThread = nil
            end)
        else clearA(); tbl2.espExitDoorsThread = nil end
    end,
})

local listB = {}
local function clearB()
    for _, x in pairs(listB) do if x then x:Destroy() end end
    table.clear(listB)
end
tbl2.espKeysThread = nil
HSTOWGroup:AddToggle("HSTOW_ESPKeys", {
    Text = "透视钥匙",
    Default = false,
    Callback = function(on)
        tbl.espKeysEnabled = on
        if on then
            if tbl2.espKeysThread then return end
            tbl2.espKeysThread = true
            task.spawn(function()
                while tbl.espKeysEnabled and tbl2.espKeysThread do
                    if fn12("HideAndSeek") then
                        local eff = workspace:FindFirstChild("Effects")
                        if eff then
                            for _, c in ipairs(eff:GetChildren()) do
                                if string.sub(c.Name,1,10) == "DroppedKey" and not c:FindFirstChild("KeyESP") then
                                    local suffix = string.sub(c.Name, 11)
                                    local txt = suffix ~= "" and ("钥匙 " .. suffix) or "钥匙"
                                    local bg = Instance.new("BillboardGui")
                                    bg.Name = "KeyESP"; bg.AlwaysOnTop = true
                                    bg.Size = UDim2.new(0,100,0,30); bg.StudsOffset = Vector3.new(0,1.5,0)
                                    local tl = Instance.new("TextLabel")
                                    tl.Size = UDim2.new(1,0,1,0); tl.BackgroundTransparency = 1
                                    tl.Text = txt; tl.TextColor3 = Color3.new(1,1,0)
                                    tl.TextStrokeTransparency = 0; tl.TextSize = 14
                                    tl.Font = Enum.Font.GothamBold
                                    tl.Parent = bg; bg.Parent = c
                                    table.insert(listB, bg)
                                end
                            end
                        end
                    else clearB() end
                    task.wait(1.5)
                end
                clearB(); tbl2.espKeysThread = nil
            end)
        else clearB(); tbl2.espKeysThread = nil end
    end,
})
end
do
local prompts, highlights = {}, {}
local function redLight()
    if fn12("RedLightGreenLight") then
        local pg = localPlayer:FindFirstChild("PlayerGui")
        if pg then
            local imp = pg:FindFirstChild("ImpactFrames")
            if imp then
                local tl = imp:FindFirstChild("TrafficLightEmpty")
                if tl and tl.Image == "rbxassetid://88400194373338" then return true end
            end
        end
    end
    return false
end
local function pop(prompt)
    if redLight() then return end
    local ch = localPlayer.Character
    local hrp = ch and ch:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local pp = prompt.Parent; if not pp then return end
    local back = hrp.CFrame
    hrp.CFrame = pp.CFrame
    task.wait(0.2)
    pcall(function()
        if fireproximityprompt then
            fireproximityprompt(prompt, 1)
            fireproximityprompt(prompt, 0)
        end
    end)
    local parent2 = pp.Parent
    local t = 0
    while parent2 and parent2.Parent and t < 2 and not redLight() do
        task.wait(0.1); t += 0.1
    end
    local hrp2 = localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart")
    if hrp2 then hrp2.CFrame = back end
end
local function addESP(prompt)
    local pp = prompt.Parent; local m = pp and pp.Parent
    if not m or highlights[prompt] then return end
    local h = Instance.new("Highlight")
    h.Name = "BalloonHighlight"
    h.FillColor = Color3.fromRGB(255,105,180)
    h.FillTransparency = 0.5
    h.OutlineColor = Color3.new(1,1,1)
    h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    h.Parent = m
    highlights[prompt] = h
end
local function rm(prompt)
    if highlights[prompt] then highlights[prompt]:Destroy(); highlights[prompt] = nil end
end
local function scan(d)
    if d:IsA("ProximityPrompt") and d.Name == "BalloonProximityPrompt" then
        prompts[d] = true
        if tbl.balloonESPEnabled then addESP(d) end
    end
end
for _, d in pairs(workspace:GetDescendants()) do scan(d) end
workspace.DescendantAdded:Connect(scan)
workspace.DescendantRemoving:Connect(function(d)
    if prompts[d] then prompts[d] = nil; rm(d) end
end)
task.spawn(function()
    while true do
        task.wait(0.5)
        if tbl.autoPopBalloonsEnabled and fn12("HideAndSeek") then
            for k in pairs(prompts) do
                if redLight() then break end
                if k and k.Parent and k.Enabled then
                    local ch = localPlayer.Character
                    local hrp = ch and ch:FindFirstChild("HumanoidRootPart")
                    local pp = k.Parent
                    if hrp and pp and math.abs(hrp.Position.Y - pp.Position.Y) <= 20 then
                        pop(k)
                    end
                elseif not k or not k.Parent then
                    prompts[k] = nil; rm(k)
                end
            end
        end
    end
end)
end
--反叛
do
local hooked = false
local function hook()
    if hooked then return end
    hooked = true
    pcall(function()
        local gf = ReplicatedStorage:FindFirstChild("Modules")
               and ReplicatedStorage.Modules:FindFirstChild("GunFunctions")
        if not gf then return end
        local m = require(gf)
        if m and m.GetBuffs then
            local orig = m.GetBuffs
            m.GetBuffs = function(...)
                local r = orig(...)
                if type(r) ~= "table" then r = {} end
                local copy = {}
                for k, v in pairs(r) do copy[k] = v end
                if tbl.noRecoilSpreadEnabled then
                    copy.RecoilDiv    = 999999
                    copy.RecoilDivX   = 999999
                    copy.RecoilDivY   = 999999
                    copy.Spread       = 0
                    copy.SpreadMult   = 0
                    copy.Bloom        = 0
                    copy.CameraShake  = 0
                end
                if tbl.rapidFireEnabled then
                    copy.FireRateMult = 9999
                    copy.FireRate     = 9999
                    copy.FireDelay    = 0
                    copy.Cooldown     = 0
                end
                return copy
            end
        end
    end)
end
RebelGroup:AddToggle("Rebel_NoRecoil", {
    Text = "无后坐力与扩散",
    Default = false,
    Callback = function(on) tbl.noRecoilSpreadEnabled = on; if on then hook() end end,
})
RebelGroup:AddToggle("Rebel_RapidFire", {
    Text = "快速射击",
    Default = false,
    Callback = function(on) tbl.rapidFireEnabled = on; if on then hook() end end,
})
end
do
local Players           = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer       = Players.LocalPlayer
local function PlayToggleSound() end
local function Notify(Title, Description, Time)
    Library:Notify({ Title = Title, Description = Description, Time = Time or 3 })
end
local function IsValidGuard(Model)
    if not Model or not Model.Name then return false end
    if not Model:IsA("Model") then return false end
    if Model == LocalPlayer.Character then return false end
    if not Model:FindFirstChild("TypeOfGuard") then return false end
    local Lower = string.lower(Model.Name)
    if string.find(Model.Name, "RebelGuard")
        or string.find(Model.Name, "RebelFirstWave")
        or string.find(Model.Name, "Wave")
        or string.find(Model.Name, "Rebel")
        or string.find(Model.Name, "Guard")
        or string.find(Model.Name, "FinalRebel")
        or string.find(Model.Name, "HallwayGuard")
        or string.find(Lower, "aggro") then
        local Humanoid = Model:FindFirstChild("Humanoid")
        if not Humanoid then return false end
        return not Model:FindFirstChild("Dead") and Humanoid.Health > 0
    end
    return false
end
local function IsGuardModel(Model)
    if not Model or not Model.Name then return false end
    return string.lower(Model.Name):find("guard") ~= nil
end
local function GetPlayerByName(Name)
    for _, Player in pairs(Players:GetPlayers()) do
        if Player.DisplayName == Name or Player.Name == Name then
            return Player
        end
    end
    return nil
end
local function IsPlayerAlive(Name)
    local Player = GetPlayerByName(Name)
    if not Player then return false end
    local Character = Player.Character
    if not Character then return false end
    local Humanoid = Character:FindFirstChild("Humanoid")
    if Humanoid then
        return Humanoid.Health > 0
    end
    return Character:FindFirstChild("Head") ~= nil
end
local function IsModelAlive(Model)
    if not Model or not Model.Parent then return false end
    local Hum = Model:FindFirstChild("Humanoid")
    if Hum then return Hum.Health > 0 end
    return Model:FindFirstChild("Head") ~= nil
end

RebelGroup:AddDivider()
do
    local activeTargets = {}
    local function FireAtPlayer(TargetName)
        local Character = LocalPlayer.Character
        if not Character then return false end
        local MP5 = LocalPlayer.Backpack:FindFirstChild("MP5")
            or Character:FindFirstChild("MP5")
        if not MP5 then return false end
        local Target = GetPlayerByName(TargetName)
        if not Target then return false end
        local TargetChar = Target.Character
        if not TargetChar then return false end
        if not TargetChar:FindFirstChild("Head") then return false end
        local Origin = Character:FindFirstChild("Head")
            or Character:FindFirstChild("HumanoidRootPart")
        if not Origin then return false end
        local FirePos = Origin.Position
        local Args = {}
        local Payload = {
            ClientRayNormal = Vector3.zero,
            FiredGun = true,
            bulletCF = CFrame.new(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
            ClientRayInstance = workspace:FindFirstChild("StairWalkWay")
                and workspace.StairWalkWay:FindFirstChild("Part"),
            SecondaryHitTargets = {},
        }
        Payload.ClientRayPosition = Vector3.zero
        Payload.HitTargets = { [Target.Name] = "Head" }
        Payload.bulletSizeC = Vector3.zero
        Payload.NoMuzzleFX = true
        Payload.FirePosition = FirePos
        Args[1] = MP5
        Args[2] = Payload
        pcall(function()
            ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("FiredGunClient"):FireServer(unpack(Args))
        end)
        return true
    end
    local function FriendlyFireLoop(TargetName)
        local NeedWait = true
        while Options.AutoFriendlyFire
            and Options.AutoFriendlyFire.Value
            and activeTargets[TargetName] do
            local Alive = IsPlayerAlive(TargetName)
            if NeedWait and not Alive then
                local StartTime = tick()
                while true do
                    NeedWait = false
                    if tick() - StartTime >= 10 then break end
                    if not Options.AutoFriendlyFire.Value
                        or not activeTargets[TargetName] then
                        return
                    end
                    local Player = GetPlayerByName(TargetName)
                    if Player and Player.Character then
                        local Hum = Player.Character:FindFirstChild("Humanoid")
                        local Head = Player.Character:FindFirstChild("Head")
                        if Hum and Hum.Health > 0 and Head then
                            task.wait(0.3)
                            NeedWait = true
                            break
                        end
                    end
                    task.wait(0.1)
                end
            end
            if Alive or NeedWait then
                FireAtPlayer(TargetName)
            end
            task.wait(0.04)
        end
        activeTargets[TargetName] = nil
    end
    RebelGroup:AddDropdown("FriendlyFireTargets", {
        Text = "选择攻击目标（友军/守卫）",
        Tooltip = "选择要自动射击的玩家",
        SpecialType = "Player",
        ExcludeLocalPlayer = true,
        Multi = true,
        Default = {},
        Callback = function(Value)
            if Options.AutoFriendlyFire and Options.AutoFriendlyFire.Value then
                Options.AutoFriendlyFire:SetValue(false)
                task.wait(0.1)
                Options.AutoFriendlyFire:SetValue(true)
            end
        end,
    })
    RebelGroup:AddToggle("AutoFriendlyFire", {
        Text = "自动友军火力",
        Tooltip = "在反叛模式中击杀队友和守卫",
        Default = false,
        Callback = function(Value)
            if Value then
                local TargetTable = Options.FriendlyFireTargets.Value
                if typeof(TargetTable) ~= "table" then
                    Options.AutoFriendlyFire:SetValue(false)
                    return
                end
                local Targets = {}
                for Name, Selected in pairs(TargetTable) do
                    if Selected == true then
                        table.insert(Targets, tostring(Name))
                    end
                end
                if #Targets == 0 then
                    Notify("反叛", "请先选择攻击目标！", 2)
                    Options.AutoFriendlyFire:SetValue(false)
                    return
                end
                for _, Name in ipairs(Targets) do
                    if not activeTargets[Name] then
                        activeTargets[Name] = true
                        task.spawn(function()
                            FriendlyFireLoop(Name)
                        end)
                        task.wait(0.05)
                    end
                end
                Notify("反叛", "自动友军火力 已启用", 2)
            else
                for Name in pairs(activeTargets) do
                    activeTargets[Name] = nil
                end
                Notify("反叛", "攻击已停止", 2)
            end
            PlayToggleSound()
        end,
    })
end
do
    local tracked = {}
    local defaultSize = Vector3.one
    local loopThread = nil
    local function collectGuardHead(Model)
        if not Model or not Model:IsA("Model") then return end
        if Players:FindFirstChild(Model.Name) then return end
        if not IsGuardModel(Model) then return end
        if tracked[Model] then return end
        local Head = Model:FindFirstChild("Head")
        if not Head or not Head:IsA("BasePart") then return end
        tracked[Model] = Head
    end
    local function resetHitboxes()
        for Model, Head in pairs(tracked) do
            if Head and Head.Parent then
                pcall(function()
                    Head.Size = defaultSize
                    Head.CanCollide = true
                end)
            end
            local HL = Model:FindFirstChild("_HeadHighlighter")
            if HL then HL:Destroy() end
        end
        tracked = {}
    end
    local function startLoop()
        if loopThread then
            task.cancel(loopThread)
            loopThread = nil
        end
        loopThread = task.spawn(function()
            repeat
                local Live = workspace:FindFirstChild("Live")
                if not Options.ExpandGuardHitbox.Value or not Live then
                    break
                end
                for _, Model in ipairs(Live:GetChildren()) do
                    collectGuardHead(Model)
                end
                local Size = Vector3.new(
                    Options.HitboxSizeSlider.Value,
                    Options.HitboxSizeSlider.Value,
                    Options.HitboxSizeSlider.Value
                )
                for Model, Head in pairs(tracked) do
                    if Model and Model.Parent and Head and Head.Parent then
                        if Head.Size ~= Size then
                            Head.Size = Size
                            Head.CanCollide = false
                        end
                    else
                        tracked[Model] = nil
                    end
                end
                task.wait(3)
            until not Options.ExpandGuardHitbox.Value
            loopThread = nil
        end)
    end
    RebelGroup:AddToggle("ExpandGuardHitbox", {
        Text = "扩大守卫碰撞箱",
        Tooltip = "放大守卫头部的 Hitbox，便于瞄准",
        Default = false,
        Callback = function(Value)
            if Value then
                startLoop()
                Notify("反叛", "扩大守卫 Hitbox 已启用", 2)
            else
                if loopThread then
                    task.cancel(loopThread)
                    loopThread = nil
                end
                resetHitboxes()
                Notify("反叛", "扩大守卫 Hitbox 已禁用", 2)
            end
            PlayToggleSound()
        end,
    })
    RebelGroup:AddSlider("HitboxSizeSlider", {
        Text = "碰撞箱大小",
        Default = 4,
        Min = 2,
        Max = 15,
        Rounding = 1,
        Callback = function(Value)
            if not Options.ExpandGuardHitbox.Value then return end
            local Size = Vector3.new(Value, Value, Value)
            for Model, Head in pairs(tracked) do
                if Model and Model.Parent and Head and Head.Parent then
                    pcall(function()
                        Head.Size = Size
                    end)
                end
            end
        end,
    })
end
do
    local killThreads = {}
    local killingSet  = {}
    local monitorThread = nil
    local function FireKillGuard(TargetName)
        local Character = LocalPlayer.Character
        if not Character then return end
        local MP5 = Character:FindFirstChild("MP5")
        if not MP5 then return end
        local FirePos = Character.HumanoidRootPart.Position
        local Args = {}
        local Payload = {
            ClientRayNormal = Vector3.zero,
            FiredGun = true,
            bulletCF = CFrame.new(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
            ClientRayInstance = workspace:FindFirstChild("StairWalkWay")
                and workspace.StairWalkWay:FindFirstChild("Part"),
            SecondaryHitTargets = {},
        }
        Payload.ClientRayPosition = Vector3.zero
        Payload.HitTargets = { [TargetName] = "Head" }
        Payload.bulletSizeC = Vector3.zero
        Payload.NoMuzzleFX = true
        Payload.FirePosition = FirePos
        Args[1] = MP5
        Args[2] = Payload
        pcall(function()                ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("FiredGunClient"):FireServer(unpack(Args))
        end)
    end
    local function CollectGuards()
        local Result = {}
        local Live = workspace:FindFirstChild("Live")
        if not Live then return Result end
        local Character = LocalPlayer.Character
        local MyPos = Character
            and Character:FindFirstChild("HumanoidRootPart")
            and Character.HumanoidRootPart.Position
        if not MyPos then return Result end
        for _, Model in ipairs(Live:GetChildren()) do
            if Model:IsA("Model") and IsGuardModel(Model) and IsModelAlive(Model) then
                local Head = Model:FindFirstChild("Head")
                if Head then
                    table.insert(Result, {
                        model = Model,
                        name = Model.Name,
                        head = Head,
                        distance = (Head.Position - MyPos).Magnitude,
                    })
                end
            end
        end
        table.sort(Result, function(a, b)
            return a.distance < b.distance
        end)
        return Result
    end
    local function KillGuardLoop(GuardInfo)
        if killingSet[GuardInfo.model] then return end
        killingSet[GuardInfo.model] = true
        local Thread = task.spawn(function()
            while true do
                if Options.AutoKillGuard.Value
                    and GuardInfo.model
                    and GuardInfo.model.Parent then
                    if not IsModelAlive(GuardInfo.model) then
                        break
                    else
                        local Head = GuardInfo.model:FindFirstChild("Head")
                        if Head then
                            FireKillGuard(GuardInfo.name)
                            task.wait(0.05)
                        end
                    end
                end
                break
            end
            killingSet[GuardInfo.model] = nil
        end)
        table.insert(killThreads, Thread)
    end
    local function StopAllKill()
        for _, Thread in ipairs(killThreads) do
            pcall(function() task.cancel(Thread) end)
        end
        killThreads = {}
        killingSet  = {}
    end
    RebelGroup:AddToggle("AutoKillGuard", {
        Text = "瞬间反叛（击杀所有 NPC 守卫）",
        Tooltip = "自动击杀所有 NPC 守卫",
        Default = false,
        Callback = function(Value)
            if Value then
                StopAllKill()
                monitorThread = task.spawn(function()
                    while Options.AutoKillGuard.Value do
                        local Guards = CollectGuards()
                        for _, Guard in ipairs(Guards) do
                            if not killingSet[Guard.model] and IsModelAlive(Guard.model) then
                                KillGuardLoop(Guard)
                            end
                        end
                        task.wait(0.1)
                    end
                    monitorThread = nil
                end)
                Notify("反叛", "瞬间反叛 已启用", 3)
            else
                if monitorThread then
                    task.cancel(monitorThread)
                    monitorThread = nil
                end
                StopAllKill()
                Notify("反叛", "瞬间反叛 已禁用", 3)
            end
            PlayToggleSound()
        end,
    })
end
RebelGroup:AddDivider()
RebelGroup:AddButton({
    Text = "让所有守卫面向我",
    Tooltip = "让所有反叛守卫转向面对玩家",
    Func = function()
        local Character = LocalPlayer.Character
        if not Character or not Character:FindFirstChild("HumanoidRootPart") then
            return
        end
        local TargetPos = Character.HumanoidRootPart.Position
        local Live = workspace:FindFirstChild("Live")
        if Live then
            for _, Guard in ipairs(Live:GetChildren()) do
                if IsValidGuard(Guard) and Guard:FindFirstChild("HumanoidRootPart") then
                    local HRP = Guard.HumanoidRootPart
                    HRP.CFrame = CFrame.new(HRP.Position, TargetPos)
                end
            end
        end
        Notify("反叛", "已让守卫转向", 2)
    end,
})
RebelGroup:AddButton({
    Text = "停止所有自动射击",
    Tooltip = "停止所有的自动攻击行为",
    Func = function()
        if Options.AutoFriendlyFire and Options.AutoFriendlyFire.Value then
            Options.AutoFriendlyFire:SetValue(false)
        end
        if Options.AutoKillGuard and Options.AutoKillGuard.Value then
            Options.AutoKillGuard:SetValue(false)
        end
        Notify("反叛", "已停止所有自动射击", 2)
    end,
})
end
--旋转木马
do
local c2, c3
local function setDoors(noclip)
    local m = workspace:FindFirstChild("MingleMap")
    local d = m and m:FindFirstChild("AllMingleDoors")
    if not d then return end
    for _, c in pairs(d:GetChildren()) do
        local u = c:FindFirstChild("Union")
        if u then u.CanCollide = not noclip; u.Transparency = noclip and 0.4 or 0 end
        local h = c:FindFirstChild("DoorHandle"); if h then h.CanCollide = not noclip end
        local h2 = c:FindFirstChild("DoorHandleOtherSide"); if h2 then h2.CanCollide = not noclip end
    end
end
MingleGroup:AddToggle("Mingle_NoclipDoors", {
    Text = "穿门",
    Default = false,
    Callback = function(on)
        if c2 then pcall(function() c2:Disconnect() end); c2 = nil end
        if c3 then pcall(function() c3:Disconnect() end); c3 = nil end
        if on then
            if fn12("Mingle") then setDoors(true) end
            c3 = localPlayer.CharacterAdded:Connect(function() task.wait(0.3); if fn12("Mingle") then setDoors(true) end end)
            local last = 0
            c2 = RunService.Heartbeat:Connect(function()
                if not fn12("Mingle") then return end
                if tick()-last < 1 then return end
                last = tick()
                setDoors(true)
            end)
        else setDoors(false) end
    end,
})

local c4
local closing = false
local function insideDoor()
    local ch = localPlayer.Character
    local hrp = ch and ch:FindFirstChild("HumanoidRootPart")
    local m = workspace:FindFirstChild("MingleMap")
    m = m and m:FindFirstChild("AllMingleDoors")
    if not hrp or not m then return nil end
    for _, c in pairs(m:GetChildren()) do
        local r = c:FindFirstChild("InsideRoomRayCheck")
        if r then
            local p = r.CFrame:PointToObjectSpace(hrp.Position)
            if math.abs(p.X) <= 10 and math.abs(p.Z) <= 12 and math.abs(p.Y) <= 10 then return c end
        end
    end
    return nil
end
local function closeDoor(door)
    if not door or closing then return end
    closing = true
    local h = door:FindFirstChild("DoorHandleOtherSide") or door:FindFirstChild("DoorHandle")
    local prompt = h and h:FindFirstChild("CloseDoorPrompt")
    if prompt and fireproximityprompt then
        pcall(function()
            prompt.HoldDuration = 0
            prompt.RequiresLineOfSight = false
            prompt.MaxActivationDistance = 9999
            fireproximityprompt(prompt, 0)
        end)
    end
    local bd = door:FindFirstChild("OpenOrCloseBD")
    if bd and bd:IsA("BindableEvent") then pcall(function() bd:Fire("Close") end) end
    task.delay(4, function() closing = false end)
end
MingleGroup:AddToggle("Mingle_AutoClose", {
    Text = "自动关门",
    Default = false,
    Callback = function(on)
        if c4 then c4:Disconnect(); c4 = nil end
        closing = false
        if on then
            local last = 0
            c4 = RunService.Heartbeat:Connect(function()
                if not fn12("Mingle") then return end
                if tick()-last < 0.2 then return end
                last = tick()
                local pg = localPlayer:FindFirstChild("PlayerGui")
                local mg = pg and pg:FindFirstChild("OtherUIHolder") and pg.OtherUIHolder:FindFirstChild("Mingle")
                if mg and mg.Visible then
                    local need = mg:FindFirstChild("PlayersNeeded")
                    if need and need.Text ~= "" and string.find(string.lower(need.Text), "safe") then
                        local d = insideDoor()
                        if d then closeDoor(d) end
                    end
                end
            end)
        end
    end,
})
local qteThread = nil
MingleGroup:AddToggle("Mingle_QTE", {
    Text = "自动QTE",
    Default = false,
    Callback = function(on)
        tbl.autoQTEEnabled = on
        if on and not qteThread then
            qteThread = task.spawn(function()
                local seen = {}
                while tbl.autoQTEEnabled do
                    if fn12("Mingle") then
                        local m = fn15()
                        if m and m.ActiveButtons then
                            for k, a in pairs(m.ActiveButtons) do
                                if not seen[k] and a then
                                    seen[k] = true
                                    if tbl.autoQTEEnabled and fn12("Mingle") and m.ActiveButtons[k] then
                                        pcall(function() m.Pressed(false, m.ActiveButtons[k]) end)
                                    end
                                end
                            end
                            for k in pairs(seen) do if not m.ActiveButtons[k] then seen[k] = nil end end
                        end
                    else table.clear(seen) end
                    task.wait()
                end
                qteThread = nil
            end)
        end
    end,
})
do
    local conns = {}
    local function checkFull()
        local pg = localPlayer:FindFirstChild("PlayerGui")
        if not pg then return false end
        local holder = pg:FindFirstChild("OtherUIHolder")
        if not holder then return false end
        local mg = holder:FindFirstChild("Mingle")
        if not mg then return false end
        local pr = mg:FindFirstChild("PlayersInRoom")
        if pr and pr:IsA("TextLabel") then
            local a, b = string.match(pr.Text, "(%d+)%/(%d+)")
            if a and b then return tonumber(a) > tonumber(b) end
        end
        return false
    end
    local function hook(ch)
        for _, c in pairs(conns) do pcall(function() c:Disconnect() end) end
        table.clear(conns)
        local hum = ch:WaitForChild("Humanoid", 5); if not hum then return end
        local an = hum:WaitForChild("Animator", 5); if not an then return end
        table.insert(conns, an.AnimationPlayed:Connect(function(track)
            if tbl.antiChokeEnabled and fn12("Mingle") then
                local id = track.Animation and track.Animation.AnimationId or ""
                if string.find(id, "71318091779666") and checkFull() then
                    local hrp = ch:FindFirstChild("HumanoidRootPart")
                    if hrp then
                        local back = hrp.CFrame
                        local stopped = false
                        local conn = track.Stopped:Connect(function()
                            stopped = true
                            if hrp then hrp.CFrame = back; fn13(" 自动踢出", "被抓住结束后传送回去") end
                            if conn then conn:Disconnect() end
                        end)
                        if not stopped and hrp then
                            hrp.CFrame = CFrame.new(199, 54, -88)
                            fn13(" 抓取传送", "已传送远离抓取")
                        end
                    end
                end
            end
        end))
    end
    MingleGroup:AddToggle("Mingle_GrabTP", {
        Text = "抓取传送",
        Default = false,
        Callback = function(on)
            tbl.antiChokeEnabled = on
            if on then
                if localPlayer.Character then hook(localPlayer.Character) end
            else
                for _, c in pairs(conns) do pcall(function() c:Disconnect() end) end
                table.clear(conns)
            end
        end,
    })
    localPlayer.CharacterAdded:Connect(function(c) if tbl.antiChokeEnabled then hook(c) end end)
end
local slowConn = nil
MingleGroup:AddToggle("Mingle_AntiSlow", {
    Text = "防减速",
    Default = false,
    Callback = function(on)
        tbl.mingleAntiSlowEnabled = on
        if on then
            if slowConn then return end
            local attrs = { "Freeze","Slowed","Action","LightAction","NoAttack" }
            local objs = { "Stun","Freeze","Slowed","Action","Ragdoll" }
            slowConn = RunService.Heartbeat:Connect(function()
                if not fn12("Mingle") then return end
                if shared.IsInCutscene then shared.IsInCutscene = nil end
                pcall(function()
                    local ps = localPlayer:FindFirstChild("PlayerScripts")
                    if ps then
                        local pm = ps:FindFirstChild("PlayerModule")
                        if pm then
                            local ctl = require(pm):GetControls()
                            if ctl and ctl.Enable then ctl:Enable(true) end
                        end
                    end
                end)
                local ch = localPlayer.Character; if not ch then return end
                local hum = ch:FindFirstChildOfClass("Humanoid")
                local hrp = ch:FindFirstChild("HumanoidRootPart")
                for _, a in ipairs(attrs) do
                    if ch:GetAttribute(a) ~= nil then ch:SetAttribute(a, nil) end
                    if hum and hum:GetAttribute(a) ~= nil then hum:SetAttribute(a, nil) end
                end
                if hrp and hrp.Anchored then hrp.Anchored = false end
                if hum then
                    local sp = game:GetService("StarterPlayer")
                    local ws = sp.CharacterWalkSpeed or 16
                    local jp = sp.CharacterJumpPower or 50
                    if hum.WalkSpeed < ws then hum.WalkSpeed = ws end
                    if hum.JumpPower < jp then hum.JumpPower = jp end
                    if hum.PlatformStand then hum.PlatformStand = false end
                end
                for _, o in ipairs(objs) do
                    local x = ch:FindFirstChild(o); if x then x:Destroy() end
                end
            end)
        elseif slowConn then slowConn:Disconnect(); slowConn = nil end
    end,
})
MingleGroup:AddToggle("Mingle_LGPowerHold", {
    Text = "LG力量压制",
    Default = false,
    Callback = function(on)
        if on then
            local Players2 = Players
            local RunService_ = RunService
            local TS = TweenService
            local DB = Debris
            if _G.LG_PowerHold_Cleanup then pcall(_G.LG_PowerHold_Cleanup); _G.LG_PowerHold_Cleanup = nil end

            local AID_TRIGGER = "103062305177426"
            local AID_CHOKE   = "71318091779666"
            local animSelf = Instance.new("Animation"); animSelf.AnimationId = "rbxassetid://85743982894847"
            local animVictim = Instance.new("Animation"); animVictim.AnimationId = "rbxassetid://134716595236712"
            local animHold = Instance.new("Animation"); animHold.AnimationId = "rbxassetid://82142761681917"
            local snd1 = "rbxassetid://133186567809675"
            local snd2 = "rbxassetid://107968065093924"
            local snd3 = "rbxassetid://221711200"
            local fx = nil
            pcall(function()
                fx = ReplicatedStorage.Effects.SetupParts.CustomEffectsFolders.LightningGodGrab
            end)
            local created, tracks = {}, {}
            local conn1, conn2 = nil, nil
            local active, victim = false, nil
            local ownSounds = {}

            local function cleanupCreated()
                for _, o in pairs(created) do pcall(function() if o and o.Parent then o:Destroy() end end) end
                created = {}
                ownSounds = {}
            end
            local function finish()
                if not active then return end
                active = false
                for _, t in pairs(tracks) do pcall(function() t:Stop(0.2) end) end
                tracks = {}
                if conn2 then conn2:Disconnect(); conn2 = nil end
                cleanupCreated()
                local hrp = localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart")
                if hrp then
                    local s = Instance.new("Sound"); s.SoundId = snd3; s.Volume = 3; s.Parent = hrp; s:Play()
                    Debris:AddItem(s, 3)
                end
                if victim then
                    local vh = victim:FindFirstChild("HumanoidRootPart")
                    if vh then vh.AssemblyLinearVelocity = Vector3.zero end
                end
                victim = nil
            end

            _G.LG_PowerHold_Cleanup = function()
                if conn1 then conn1:Disconnect(); conn1 = nil end
                if conn2 then conn2:Disconnect(); conn2 = nil end
                if active then
                    active = false
                    for _, t in pairs(tracks) do pcall(function() t:Stop(0) end) end
                    cleanupCreated()
                end
                local ch = localPlayer.Character
                if ch then
                    local h = ch:FindFirstChild("Humanoid")
                    h = h and h:FindFirstChild("Animator")
                    if h then
                        for _, t in pairs(h:GetPlayingAnimationTracks()) do
                            pcall(function() t:AdjustWeight(1) end)
                        end
                    end
                end
            end

            local function closestTarget()
                local ch = localPlayer.Character; if not ch then return nil end
                local hrp = ch:FindFirstChild("HumanoidRootPart"); if not hrp then return nil end
                local best, bd = nil, 50
                local function check(m)
                    if m and m ~= ch then
                        local h2 = m:FindFirstChild("HumanoidRootPart")
                        local hu = m:FindFirstChildOfClass("Humanoid")
                        if h2 and hu and hu.Health > 0 then
                            local an = hu:FindFirstChildOfClass("Animator")
                            local grabbed = false
                            if an then
                                for _, t in pairs(an:GetPlayingAnimationTracks()) do
                                    if (((t.Animation and t.Animation.AnimationId or ""):match("%d+")) or "") == "111638343378220" then
                                        grabbed = true; break
                                    end
                                end
                            end
                            if not grabbed then
                                local d = (h2.Position - hrp.Position).Magnitude
                                if d < bd then bd = d; best = m end
                            end
                        end
                    end
                end
                for _, p in pairs(Players2:GetPlayers()) do check(p.Character) end
                local live = workspace:FindFirstChild("Live") or workspace:FindFirstChild("Characters")
                if live then for _, c in pairs(live:GetChildren()) do check(c) end
                else for _, c in pairs(workspace:GetChildren()) do
                    if c:IsA("Model") and c:FindFirstChildOfClass("Humanoid") then check(c) end
                end end
                return best
            end

            local function spawnFX(ch, tgt)
                if not fx then return end
                local la = ch:FindFirstChild("Left Arm")
                local head = tgt:FindFirstChild("Head")
                local parts = {}
                for _, n2 in pairs({ "Torso","Head","Right Arm","Left Arm","Left Leg","Right Leg" }) do
                    local p = tgt:FindFirstChild(n2); if p then table.insert(parts, p) end
                end
                if la then
                    local s = Instance.new("Sound"); s.SoundId = snd2; s.Volume = 2; s.Parent = la; s:Play()
                    table.insert(created, s); ownSounds[s] = true
                end
                task.delay(0.17, function()
                    if not active then return end
                    local light = fx:FindFirstChild("Lighting")
                    if light and head then
                        local c = light:Clone(); c.Parent = head; c.Brightness = 45; c.Enabled = true
                        table.insert(created, c); Debris:AddItem(c, 1.97)
                        TS:Create(c, TweenInfo.new(0.08), { Brightness = 2 }):Play()
                    end
                    local ra = fx:FindFirstChild("Right Arm")
                    if ra and la then
                        local b = ra:FindFirstChild("BurstEmit")
                        if b then
                            local c = b:Clone(); c.Parent = la; c.Enabled = true
                            table.insert(created, c); Debris:AddItem(c, 0.5)
                        end
                    end
                end)
                task.delay(0.22, function()
                    if not active then return end
                    for _, p in pairs(parts) do
                        for i = 1, 3 do
                            local x = fx:FindFirstChild("ToonLightning" .. i)
                            if x then
                                local c = x:Clone(); c.Parent = p; c.Enabled = true
                                table.insert(created, c); Debris:AddItem(c, 2.22)
                                task.delay(1.82, function() if c and c.Parent then c.Enabled = false end end)
                            end
                        end
                        local g = fx:FindFirstChild("Glow")
                        if g then
                            local c = g:Clone(); c.Parent = p; c.Enabled = true
                            table.insert(created, c); Debris:AddItem(c, 2.22)
                            task.delay(1.82, function() if c and c.Parent then c.Enabled = false end end)
                        end
                    end
                    local ra = fx:FindFirstChild("Right Arm")
                    if ra and la then
                        for i = 1, 2 do
                            local x = ra:FindFirstChild("ArmLightning" .. i)
                            if x then
                                local c = x:Clone(); c.Parent = la; c.Enabled = true
                                table.insert(created, c); Debris:AddItem(c, 2.07)
                                task.delay(1.82, function() if c and c.Parent then c.Enabled = false end end)
                            end
                        end
                    end
                end)
                for _, d in pairs({ 0.25,0.48,0.72,0.95,1.18,1.42,1.65,1.88 }) do
                    task.delay(d, function()
                        if not active or not tgt.Parent then return end
                        local h = Instance.new("Highlight")
                        h.DepthMode = Enum.HighlightDepthMode.Occluded
                        h.FillTransparency = 0
                        h.OutlineTransparency = 1
                        h.FillColor = Color3.new(0,0,0)
                        h.Parent = tgt
                        table.insert(created, h)
                        Debris:AddItem(h, 0.09)
                    end)
                end
            end

            local function silenceSounds(root)
                if not root then return end
                for _, d in pairs(root:GetDescendants()) do
                    if d:IsA("Sound") and d.IsPlaying and not ownSounds[d] then
                        local id = d.SoundId:match("%d+") or ""
                        if id == "115899725081193" or id == "110658036715" or active then
                            d.Volume = 0
                        end
                    end
                end
            end

            local function bind(character)
                if conn1 then conn1:Disconnect() end
                local hum = character:WaitForChild("Humanoid", 10); if not hum then return end
                local an = hum:WaitForChild("Animator", 10); if not an then return end
                conn1 = an.AnimationPlayed:Connect(function(track)
                    if not track or not track.Animation then return end
                    local id = (track.Animation.AnimationId or ""):match("%d+") or ""
                    if id == AID_TRIGGER then
                        pcall(function() track:AdjustWeight(0.001) end)
                        local a = an:LoadAnimation(animSelf)
                        a.Priority = Enum.AnimationPriority.Action4
                        a:Play(); a:AdjustSpeed(0.85)
                        if not active then table.insert(tracks, a) end
                        local hrp = character:FindFirstChild("HumanoidRootPart")
                        if hrp then
                            local s = Instance.new("Sound"); s.SoundId = snd1; s.Volume = 2; s.Parent = hrp; s:Play()
                            table.insert(created, s); ownSounds[s] = true; Debris:AddItem(s, 3)
                        end
                        task.spawn(function()
                            for _ = 1, 10 do silenceSounds(character); task.wait(0.1) end
                        end)
                    elseif id == AID_CHOKE then
                        pcall(function() track:AdjustWeight(0.001) end)
                        track.Stopped:Connect(function() if active then finish() end end)
                        local tgt = closestTarget()
                        if not tgt then
                            local a = an:LoadAnimation(animVictim)
                            a.Priority = Enum.AnimationPriority.Action4
                            a.Looped = true; a:Play()
                            table.insert(tracks, a)
                            return
                        end
                        if active then finish() end
                        active = true; victim = tgt
                        local a = an:LoadAnimation(animVictim)
                        a.Priority = Enum.AnimationPriority.Action4; a.Looped = true; a:Play()
                        table.insert(tracks, a)
                        local vhum = tgt:FindFirstChildOfClass("Humanoid")
                        local van = vhum and vhum:FindFirstChildOfClass("Animator")
                        if van then
                            local b = van:LoadAnimation(animHold)
                            b.Priority = Enum.AnimationPriority.Action4; b.Looped = true; b:Play()
                            table.insert(tracks, b)
                        end
                        spawnFX(character, tgt)
                        conn2 = RunService_.RenderStepped:Connect(function()
                            if not tgt.Parent or not character.Parent then finish(); return end
                            local hrp = character:FindFirstChild("HumanoidRootPart")
                            local vroot = tgt:FindFirstChild("HumanoidRootPart") or tgt:FindFirstChild("Torso")
                            if not hrp or not vroot then finish(); return end
                            for _, t in pairs(an:GetPlayingAnimationTracks()) do
                                local tid = (t.Animation and t.Animation.AnimationId or ""):match("%d+") or ""
                                if tid == AID_TRIGGER or tid == AID_CHOKE then
                                    pcall(function() t:AdjustWeight(0.001) end)
                                end
                            end
                            if van then
                                for _, t in pairs(van:GetPlayingAnimationTracks()) do
                                    if ((t.Animation and t.Animation.AnimationId or ""):match("%d+") or "") ~= "82142761681917"
                                    and t.Priority.Value >= Enum.AnimationPriority.Action.Value then
                                        pcall(function() t:AdjustWeight(0.001) end)
                                    end
                                end
                            end
                            silenceSounds(character); silenceSounds(tgt)
                            vroot.CFrame = hrp.CFrame * CFrame.new(0,1,-3.5) * CFrame.Angles(0, math.pi, 0)
                        end)
                    end
                end)
            end

            if localPlayer.Character then task.spawn(bind, localPlayer.Character) end
            conn2 = localPlayer.CharacterAdded:Connect(function(c)
                active = false; victim = nil; tracks = {}
                task.spawn(bind, c)
            end)
        elseif _G.LG_PowerHold_Cleanup then
            pcall(_G.LG_PowerHold_Cleanup)
            _G.LG_PowerHold_Cleanup = nil
        end
    end,
})
end
--真男人一V一
SquidGroup:AddToggle("Sky_KillAura", {
Text = "击杀光环",
Default = false,
Callback = function(on)
    tbl.squidKillAuraEnabled = on
    if on then
        if tbl2.squidKillAuraThread then return end
        tbl2.squidKillAuraThread = true
        task.spawn(function()
            local telegraph = { ["96924216250322"]=true, ["116839849594540"]=true, ["123072675259257"]=true }
            while tbl2.squidKillAuraThread and tbl.squidKillAuraEnabled do
                if fn12("SquidGame") then
                    local ch = localPlayer.Character
                    if ch and ch:FindFirstChild("Humanoid") and ch:FindFirstChild("HumanoidRootPart") and ch.Humanoid.Health > 0 then
                        local hrp = ch.HumanoidRootPart
                        local fists = localPlayer.Backpack:FindFirstChild("Fists")
                        if fists then ch.Humanoid:EquipTool(fists) end
                        local f2 = ch:FindFirstChild("Fists")
                        if f2 then f2:Activate() end
                        local best, bd = nil, 300
                        for _, p in pairs(Players:GetPlayers()) do
                            if p ~= localPlayer and p.Character then
                                local c = p.Character
                                local h = c:FindFirstChild("HumanoidRootPart")
                                local hu = c:FindFirstChild("Humanoid")
                                if h and hu and hu.Health > 0 then
                                    local d = (h.Position - hrp.Position).Magnitude
                                    if d < bd then bd = d; best = p end
                                end
                            end
                        end
                        if best and best.Character then
                            local c2 = best.Character
                            local h2 = c2:FindFirstChild("HumanoidRootPart")
                            local hu2 = c2:FindFirstChild("Humanoid")
                            if h2 and hu2 then
                                local an = hu2:FindFirstChildOfClass("Animator")
                                local tracks = an and an:GetPlayingAnimationTracks() or hu2:GetPlayingAnimationTracks()
                                local tele = false
                                for _, t in ipairs(tracks) do
                                    if t.Animation and t.Animation.AnimationId then
                                        local id = string.match(t.Animation.AnimationId, "%d+")
                                        if id and telegraph[id] and (t.Length == 0 or t.Length - t.TimePosition > 0.5) then
                                            tele = true; break
                                        end
                                    end
                                end
                                if tele then
                                    hrp.CFrame = h2.CFrame * CFrame.new(0, -30, 0)
                                else
                                    hrp.CFrame = h2.CFrame * CFrame.new(0, 0, 3)
                                end
                            end
                        end
                    end
                    RunService.Heartbeat:Wait()
                else task.wait(1) end
            end
            tbl2.squidKillAuraThread = nil
        end)
    end
end,
})


-- [缝合注] 已移除原 6705-6742 行的损坏重复片段（语法残缺，保留会导致整个脚本无法加载）


local GameToolsGroup = Tabs.Zxgn:AddLeftGroupbox("| 杂项", "wrench")
local AutoVoteGroup = Tabs.Zxgn:AddRightGroupbox("| 自动投票", "vote")
local UtilGroup = Tabs.Zxgn:AddLeftGroupbox("| 实用工具", "tool-case")
local TeleGroup = Tabs.Zxgn:AddRightGroupbox("| 传送", "map-pin")
local VisualPowerGroup = Tabs.Zxgn:AddLeftGroupbox("| 能力选项", "sparkles")
local VisualGamepassGroup = Tabs.Zxgn:AddRightGroupbox("| 通行证选项", "ticket")
local VisualClientGroup = Tabs.Zxgn:AddLeftGroupbox("| 客户端选项", "monitor")
local VisualEmoteGroup = Tabs.Zxgn:AddRightGroupbox("| 表情播放器", "smile")
local VisualRageGroup = Tabs.Zxgn:AddRightGroupbox("| 挑衅表情", "angry")
local LeftGB  = Tabs.Zxgn:AddLeftGroupbox("| 通用 QTE", "zap")
local RightGB = Tabs.Zxgn:AddRightGroupbox("| 拔河 QTE", "swords")

do
local Players    = game:GetService("Players")
local Workspace  = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local localPlayer  = Players.LocalPlayer
local localPlayer2 = localPlayer
local RunService2  = RunService
local function PlayToggleSound() end
local function PlayErrorSound() end
local function PlayBell() end
local function notify(title, text, duration)
    Library:Notify({
        Title = tostring(title),
        Description = tostring(text or ""),
        Time = tonumber(duration) or 0.9,
    })
end
local function fn61(fn, ...)
    if type(fn) ~= "function" then return end
    local args = table.pack(...)
    task.spawn(function()
        pcall(fn, table.unpack(args, 1, args.n))
    end)
end
local function get_character()
    return localPlayer.Character
end
local function get_root_part(ch)
    return ch and ch:FindFirstChild("HumanoidRootPart")
end
local function is_game_active(gameName)
    local values = Workspace:FindFirstChild("Values")
    if not values then return false end
    local currentGame = values:FindFirstChild("CurrentGame")
    return currentGame and currentGame.Value == gameName
end
local function is_hider(player)
    return player and player:GetAttribute("IsHider") == true
end
local function is_seeker(player)
    return player and player:GetAttribute("IsHunter") == true
end
local function safe_teleport(pos)
    local char = localPlayer.Character
    if not char then return false end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return false end
    hrp.CFrame = CFrame.new(pos)
    return true
end
local function setToggle(id, value)
    local opt = Options and Options[id]
    if opt and opt.SetValue then
        pcall(function() opt:SetValue(value) end)
    end
end
do
    local enabled     = false
    local connection  = nil
    local triggered   = {}
    local currentGame = nil
    local startTime   = nil
    local function setHunterFeatures(on)
        setToggle("PlayerAttach", on)
        setToggle("FaceTarget", on)
        setToggle("SpikesKill", on)
        setToggle("Noclip", on)
    end
    local function cleanupGame(gameName)
        if gameName == "HideAndSeek" then
            setHunterFeatures(false)
        end
        if gameName == "Rebel" then
            setToggle("RebelV2", false)
        end
        if gameName == "TugOfWar" or gameName == "TugofWar" then
            setToggle("UltraFastPullQTE", false)
        end
    end
    local function step()
        if not enabled then return end
        local now = tick()
        local values = Workspace:FindFirstChild("Values")
        if not values then return end
        local cg = values:FindFirstChild("CurrentGame")
        if not cg then return end
        local gameName = cg.Value
        if not gameName or gameName == "" then return end
        if gameName ~= currentGame then
            if currentGame then
                cleanupGame(currentGame)
            end
            currentGame = gameName
            startTime   = now
            triggered   = {
                Main            = false,
                HunterStarted   = false,
                RebelStarted    = false,
                TugOfWarStarted = false,
            }
        end
        if not startTime then
            startTime = now
        end
        if gameName == "TugOfWar" or gameName == "TugofWar" then
            if not triggered.TugOfWarStarted then
                triggered.TugOfWarStarted = true
                setToggle("UltraFastPullQTE", true)
                PlayBell()
            end
            return
        end
        local char = get_character()
        if not char then return end
        local hrp = get_root_part(char)
        if not hrp then return end
        if gameName == "RedLightGreenLight" then
            if not triggered.Main then
                triggered.Main = true
                safe_teleport(Vector3.new(-214.4, 1023.1, 146.7))
                PlayBell()
            end
        elseif gameName == "Dalgona" then
            if not triggered.Main then
                triggered.Main = true
                setToggle("AutoDalgona", true)
                PlayBell()
            end
        elseif gameName == "LightsOut" or gameName == "LightOut" then
            if not triggered.Main then
                triggered.Main = true
                local pos = hrp.Position
                safe_teleport(Vector3.new(pos.X, pos.Y + 100, pos.Z))
                PlayBell()
            end
        elseif gameName == "HideAndSeek" then
            if is_hider(localPlayer2) then
                if not triggered.Main then
                    triggered.Main = true
                    local pos = hrp.Position
                    safe_teleport(Vector3.new(pos.X, pos.Y + 200, pos.Z))
                    PlayBell()
                end
            elseif is_seeker(localPlayer2) then
                if not triggered.HunterStarted then
                    triggered.HunterStarted = true
                    setHunterFeatures(true)
                    PlayBell()
                end
            end
        elseif gameName == "JumpRope" then
            if not triggered.Main then
                triggered.Main = true
                safe_teleport(Vector3.new(720.89606, 198.62831, 921.17065))
                PlayBell()
            end
        elseif gameName == "GlassBridge" then
            if not triggered.Main then
                triggered.Main = true
                safe_teleport(Vector3.new(-196.37247, 522.19214, -1534.2098))
                PlayBell()
            end
        elseif gameName == "Rebel" then
            if not triggered.RebelStarted then
                triggered.RebelStarted = true
                local pos = hrp.Position
                safe_teleport(Vector3.new(pos.X, pos.Y + 100, pos.Z))
                setToggle("RebelV2", true)
                PlayBell()
            end
        end
    end
    GameToolsGroup:AddToggle("AutoWin", {
        Text = "自动胜利",
        Tooltip = "进入任意支持的游戏后立即执行：RLGL 传送终点 / 糖饼自动完成 / 熄灯上升 / HnS 处理 / 跳绳传送 / 玻璃桥传送 / 反叛秒杀 / 拔河极速",
        Default = false,
        Callback = function(Value)
            enabled = Value and true or false

            if connection then
                connection:Disconnect()
                connection = nil
            end
            if not enabled then
                cleanupGame(currentGame)
                setHunterFeatures(false)
                setToggle("UltraFastPullQTE", false)
                setToggle("RebelV2", false)
            end
            triggered   = {}
            currentGame = nil
            startTime   = nil
            if enabled then
                connection = RunService2.Heartbeat:Connect(step)
            end
            PlayToggleSound()
            return true
        end,
    })
end
end    
tbl2.allGamesQTEThread = nil
GameToolsGroup:AddToggle("Tools_QTEAll", {
Text = "自动QTE事件（所有游戏）",
Default = false,
Callback = function(on)
    tbl.allGamesAutoQTEEnabled = on
    if on and not tbl2.allGamesQTEThread then
        tbl2.allGamesQTEThread = task.spawn(function()
            local seen = {}
            while tbl.allGamesAutoQTEEnabled do
                local m = fn15()
                if m and m.ActiveButtons then
                    for k, a in pairs(m.ActiveButtons) do
                        if not seen[k] and a then
                            seen[k] = true
                            if tbl.allGamesAutoQTEEnabled and m.ActiveButtons[k] then
                                pcall(function() m.Pressed(false, m.ActiveButtons[k]) end)
                            end
                        end
                    end
                    for k in pairs(seen) do if not m.ActiveButtons[k] then seen[k] = nil end end
                else table.clear(seen) end
                task.wait()
            end
            tbl2.allGamesQTEThread = nil
        end)
    elseif not tbl.allGamesAutoQTEEnabled then
        tbl2.allGamesQTEThread = nil
    end
end,
})
do
local values, groups = {}, {}
local function add(p)
    if not p or not p.Character then return end
    local head = p.Character:FindFirstChild("Head")
    local power = p:GetAttribute("_EquippedPower")
    if tbl.espPowersEnabled and head and power and power ~= "" and power ~= "None" and power ~= "Yok" then
        local text = tostring(power)
        local existing = groups[p]
        if not existing then
            local bg = Instance.new("BillboardGui")
            bg.Name = "PowerESP"
            bg.AlwaysOnTop = false
            bg.Size = UDim2.new(0,100,0,20)
            bg.StudsOffset = Vector3.new(0,1.5,0)
            local tl = Instance.new("TextLabel")
            tl.BackgroundTransparency = 1
            tl.Size = UDim2.new(1,0,1,0)
            tl.Text = text
            tl.TextColor3 = Color3.new(1,1,1)
            tl.Font = Enum.Font.Arcade
            tl.TextSize = 10
            tl.TextStrokeTransparency = 0.5
            tl.Parent = bg; bg.Parent = head
            groups[p] = bg
        else
            if existing.Parent ~= head then existing.Parent = head end
            local tl = existing:FindFirstChildOfClass("TextLabel")
            if tl then tl.Text = text end
        end
    elseif groups[p] then
        groups[p]:Destroy(); groups[p] = nil
    end
end
local function bind(p)
    if values[p] then values[p]:Disconnect(); values[p] = nil end
    values[p] = p:GetAttributeChangedSignal("_EquippedPower"):Connect(function() add(p) end)
    values[p.."_char"] = p.CharacterAdded:Connect(function() task.wait(1); if tbl.espPowersEnabled then add(p) end end)
    add(p)
end
local function clearAll()
    for _, c in pairs(values) do c:Disconnect() end
    table.clear(values)
    for _, g in pairs(groups) do if g then g:Destroy() end end
    table.clear(groups)
end
GameToolsGroup:AddToggle("Tools_ESPPowers", {
    Text = "能力透视",
    Default = false,
    Callback = function(on)
        tbl.espPowersEnabled = on
        if on then
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= localPlayer then bind(p) end
            end
            values._PlayerAdded = Players.PlayerAdded:Connect(function(p)
                if tbl.espPowersEnabled then bind(p) end
            end)
        else clearAll() end
    end,
})
end
do
local found, highlights = {}, {}
local function add(m)
    if not m or not m.Parent or highlights[m] then return end
    local h = Instance.new("Highlight")
    h.Name = "PeabertHighlight"
    h.FillColor = Color3.fromRGB(0,255,0)
    h.FillTransparency = 0.5
    h.OutlineColor = Color3.new(1,1,1)
    h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    h.Parent = m
    highlights[m] = h
end
local function rm(m)
    if highlights[m] then highlights[m]:Destroy(); highlights[m] = nil end
end
local function isPeabert(o)
    return o:IsA("Model") and string.find(o.Name, "FREEPEABERT")
end
local function scan(d)
    if isPeabert(d) then
        found[d] = true
        if tbl.peabertESPEnabled then add(d) end
    end
end
for _, d in pairs(workspace:GetDescendants()) do scan(d) end
workspace.DescendantAdded:Connect(scan)
workspace.DescendantRemoving:Connect(function(d)
    if found[d] then found[d] = nil; rm(d) end
end)

GameToolsGroup:AddToggle("Tools_PeabertESP", {
    Text = "Peabert透视",
    Default = false,
    Callback = function(on)
        tbl.peabertESPEnabled = on
        if on then
            for k in pairs(found) do if k and k.Parent then add(k) end end
        else for k in pairs(found) do rm(k) end end
    end,
})

local lastTP = 0
btn(GameToolsGroup, "传送到Peabert", function()
    if tick() - lastTP < 10 then
        fn13(" 冷却中", string.format("等待 %.1f秒", 10-(tick()-lastTP)))
        return
    end
    local ch = localPlayer.Character
    local hrp = ch and ch:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local best, bd = nil, math.huge
    for k in pairs(found) do
        if k and k.Parent then
            local part = k:FindFirstChildWhichIsA("BasePart", true)
            if part then
                local d = (hrp.Position - part.Position).Magnitude
                if d < bd then bd = d; best = part end
            end
        end
    end
    if best then
        fn17(best.CFrame * CFrame.new(0,0,3))
        lastTP = tick()
        fn13(" 已传送", "已传送到Peabert！")
    else fn13(" 错误", "地图上未找到Peabert！") end
end)
end
do
local c
GameToolsGroup:AddToggle("Tools_InfJump", {
    Text = "无限跳跃",
    Default = false,
    Callback = function(on)
        if on then
            if c then return end
            c = UserInputService.JumpRequest:Connect(function()
                local ch = localPlayer.Character
                if ch then
                    local hum = ch:FindFirstChildWhichIsA("Humanoid")
                    if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
                end
            end)
        elseif c then c:Disconnect(); c = nil end
    end,
})
end
GameToolsGroup:AddToggle("Tools_FPSBooster", {
Text = "FPS提升 / 防卡顿",
Default = false,
Callback = function(on)
    tbl.fpsBoosterEnabled = on
    local terrain = workspace:FindFirstChildOfClass("Terrain")
    if on then
        if terrain then
            terrain.WaterWaveSize = 0
            terrain.WaterWaveSpeed = 0
            terrain.WaterReflectance = 0
            terrain.WaterTransparency = 0
        end
        Lighting.GlobalShadows = false
        Lighting.FogEnd = 9e9
        Lighting.Brightness = 1
        settings().Rendering.QualityLevel = "Level01"
        for _, d in pairs(workspace:GetDescendants()) do
            if d:IsA("Part") or d:IsA("Union") or d:IsA("CornerWedgePart") or d:IsA("TrussPart") then
                d.Material = "Plastic"; d.Reflectance = 0
            elseif d:IsA("Decal") or (d:IsA("Texture") and d.Name ~= "TOWDecal") then
                d.Transparency = 1
            elseif d:IsA("ParticleEmitter") or d:IsA("Trail") then
                d.Lifetime = NumberRange.new(0)
            elseif d:IsA("Explosion") then
                d.BlastPressure = 1; d.BlastRadius = 1
            end
        end
    else
        if terrain then
            terrain.WaterWaveSize = 0.15
            terrain.WaterWaveSpeed = 10
            terrain.WaterReflectance = 1
            terrain.WaterTransparency = 1
        end
        Lighting.GlobalShadows = true
        settings().Rendering.QualityLevel = "Automatic"
    end
end,
})
GameToolsGroup:AddToggle("Tools_AntiAFK", {
Text = "防挂机",
Default = false,
Callback = function(on)
    if on then
        if not getgenv().antiAfkConnection then
            getgenv().antiAfkConnection = localPlayer.Idled:Connect(function()
                local vu = game:GetService("VirtualUser")
                vu:CaptureController()
                vu:ClickButton2(Vector2.new())
            end)
        end
    elseif getgenv().antiAfkConnection then
        getgenv().antiAfkConnection:Disconnect()
        getgenv().antiAfkConnection = nil
    end
end,
})
-- 绷带辅助
GameToolsGroup:AddToggle("Tools_BandageHelper", {
Text = "绷带辅助",
Default = false,
Callback = function(on)
    if on then
        if _G.BandageHelperActive then return end
        _G.BandageHelperActive = true
        _G.BandageConns = {}
        local Players2 = Players
        local rs = RunService
        local sp = game:GetService("StarterPlayer")
        local attrs = { "Freeze","Slowed","Action","LightAction","NoAttack" }
        local objs = { "Stun","Freeze","Slowed","Action","LightAction","Ragdoll","NoAttack" }
        local names = {
            ["HEALING WAVE 1"]=true, ["HEALING WAVE 2"]=true,
            SPARKS=true, ["STAR SPARKS"]=true,
            BandageModel=true, HealingOverlay=true,
            Blue=true, Green=true, VFX=true,
        }
        local function filterEffect(child)
            if not _G.BandageHelperActive then return end
            if child:IsA("ColorCorrectionEffect") then
                if child.TintColor.G > 0.6 and (child.TintColor.R < 0.5 or child.TintColor.B < 0.5) then
                    child.TintColor = Color3.fromRGB(255,255,255)
                end
                local nl = string.lower(child.Name)
                if child.Name == "ColorSkill" or string.find(nl,"heal") or string.find(nl,"green") or string.find(nl,"bandage") then
                    child:Destroy()
                end
            elseif child:IsA("BloomEffect") or child:IsA("BlurEffect") then
                local nl = string.lower(child.Name)
                if string.find(nl,"heal") or string.find(nl,"bandage") then
                    child:Destroy()
                end
            end
        end
        for _, c in ipairs(Lighting:GetChildren()) do filterEffect(c) end
        table.insert(_G.BandageConns, Lighting.ChildAdded:Connect(filterEffect))

        local function bindChar(ch)
            if not ch or not _G.BandageHelperActive then return end
            local hum = ch:WaitForChild("Humanoid", 5)
            ch:WaitForChild("HumanoidRootPart", 5)
            if not hum then return end
            table.insert(_G.BandageConns, (hum:FindFirstChildOfClass("Animator") or hum).AnimationPlayed:Connect(function(t)
                if _G.BandageHelperActive and t.Animation then
                    local id = t.Animation.AnimationId or ""
                    if string.find(id, "75334524397463") or (t.Animation.Name and string.find(string.lower(t.Animation.Name), "bandage")) then
                        t:Stop()
                    end
                end
            end))
            table.insert(_G.BandageConns, ch.DescendantAdded:Connect(function(d)
                local hit = _G.BandageHelperActive
                if hit then
                    local nl = string.lower(d.Name)
                    hit = names[d.Name] or string.find(nl,"healing") or string.find(nl,"bandage") or string.find(nl,"sparks")
                end
                if hit then d:Destroy() end
            end))
        end
        if localPlayer.Character then bindChar(localPlayer.Character) end
        table.insert(_G.BandageConns, localPlayer.CharacterAdded:Connect(bindChar))

        local function bindGui(pg)
            table.insert(_G.BandageConns, pg.DescendantAdded:Connect(function(d)
                local hit = _G.BandageHelperActive
                if hit then
                    local nl = string.lower(d.Name)
                    hit = names[d.Name] or string.find(nl,"bandage") or string.find(nl,"healing")
                end
                if hit and not d:IsA("Script") then d:Destroy() end
            end))
        end
        local pg = localPlayer:FindFirstChildOfClass("PlayerGui")
        if pg then bindGui(pg)
        else table.insert(_G.BandageConns, localPlayer.ChildAdded:Connect(function(c)
            if _G.BandageHelperActive and c:IsA("PlayerGui") then bindGui(c) end
        end)) end

        table.insert(_G.BandageConns, RunService.Heartbeat:Connect(function()
            if not _G.BandageHelperActive then return end
            if shared.IsInCutscene then shared.IsInCutscene = nil end
            local ch = localPlayer.Character; if not ch then return end
            local hum = ch:FindFirstChildOfClass("Humanoid")
            local hrp = ch:FindFirstChild("HumanoidRootPart")
            for _, a in ipairs(attrs) do
                if ch:GetAttribute(a) ~= nil then ch:SetAttribute(a, nil) end
                if hum and hum:GetAttribute(a) ~= nil then hum:SetAttribute(a, nil) end
            end
            for _, o in ipairs(objs) do
                local x = ch:FindFirstChild(o); if x then x:Destroy() end
            end
            if hrp and hrp.Anchored then hrp.Anchored = false end
            shared.WalkSpeedChangeTick = nil
            if hum then
                local ws = sp.CharacterWalkSpeed or 16
                local jp = sp.CharacterJumpPower or 50
                if hum.WalkSpeed < ws then hum.WalkSpeed = ws end
                if hum.JumpPower < jp then hum.JumpPower = jp end
                if hum.PlatformStand then hum.PlatformStand = false end
            end
        end))
    else
        _G.BandageHelperActive = false
        if _G.BandageConns then
            for _, c in ipairs(_G.BandageConns) do if c then c:Disconnect() end end
            table.clear(_G.BandageConns)
        end
    end
end,
})
--新添加功能
do
local Players          = game:GetService("Players")
local Workspace        = game:GetService("Workspace")
local RunService       = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService     = game:GetService("TweenService")
local HttpService      = game:GetService("HttpService")
local Lighting         = game:GetService("Lighting")
local localPlayer      = Players.LocalPlayer
local localPlayer2     = localPlayer
local function PlayToggleSound() end
local function PlayBell() end
local function PlayErrorSound() end
local function notify(title, text, duration)
    Library:Notify({
        Title = tostring(title),
        Description = tostring(text or ""),
        Time = tonumber(duration) or 0.9,
    })
end
local function fn61(fn, ...)
    if type(fn) ~= "function" then return end
    local args = table.pack(...)
    task.spawn(function()
        pcall(fn, table.unpack(args, 1, args.n))
    end)
end
local function get_character()
    return localPlayer.Character
end
local function get_root_part(ch)
    return ch and ch:FindFirstChild("HumanoidRootPart")
end
local function is_mobile()
    return UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
end
do
    local enabled    = false
    local connection = nil
    local config = {
        Time  = 3,
        Head  = { 1095708 },
        Hand  = { 3141364957 },
        Torso = { 2222720521 },
    }
    local function findCharacter()
        local cam = workspace.CurrentCamera
        if cam and cam.CameraSubject then
            local subject = cam.CameraSubject
            if subject and subject:IsA("Humanoid") then
                return subject.Parent
            end
        end
        for _, child in pairs(workspace:GetChildren()) do
            if child:FindFirstChild("Humanoid") and child:FindFirstChild("Head") then
                if not string.find(child.Name:lower(), "badpreload")
                    and not string.find(child.Name:lower(), "preload") then
                    return child
                end
            end
        end
        return nil
    end
    local function attachItem(assetId, part0)
        local ok, result = pcall(function()
            return game:GetObjects("rbxassetid://" .. tostring(assetId))[1]
        end)
        if ok and result then
            local handle = result:FindFirstChild("Handle")
            if handle then
                local attachment = handle:FindFirstChildOfClass("Attachment")
                if attachment then
                    local target = part0:FindFirstChild(attachment.Name)
                    if target then
                        local weld = Instance.new("Weld")
                        weld.Part0 = part0
                        weld.Part1 = handle
                        weld.C0 = target.CFrame
                        weld.C1 = attachment.CFrame
                        weld.Parent = handle
                    else
                        local weld = Instance.new("Weld")
                        weld.Part0 = part0
                        weld.Part1 = handle
                        weld.C0 = CFrame.new()
                        weld.C1 = CFrame.new()
                        weld.Parent = handle
                    end
                else
                    local weld = Instance.new("Weld")
                    weld.Part0 = part0
                    weld.Part1 = handle
                    weld.C0 = CFrame.new()
                    weld.C1 = CFrame.new()
                    weld.Parent = handle
                end
                handle.CanCollide = false
                result.Parent = part0.Parent
                print("[VisualItems] Added: " .. tostring(assetId))
            else
                warn("[VisualItems] No Handle in: " .. tostring(assetId))
            end
        else
            warn("[VisualItems] Failed to load: " .. tostring(assetId))
        end
    end
    local function hideHead(character)
        local head = character:FindFirstChild("Head")
        if not head then return end
        head.Transparency = 1
        head.CanCollide = false
        local decal = head:FindFirstChildOfClass("Decal")
        if decal then decal:Destroy() end
        for _, child in ipairs(head:GetChildren()) do
            if child:IsA("SpecialMesh") or child:IsA("CharacterMesh") then
                child:Destroy()
            end
        end
        local mesh = Instance.new("SpecialMesh")
        mesh.MeshType = Enum.MeshType.FileMesh
        mesh.MeshId = "rbxassetid://1095708"
        mesh.Scale = Vector3.new(0.001, 0.001, 0.001)
        mesh.Parent = head
    end
    local function applyAll()
        local character = findCharacter()
        if not character then return end
        if character:FindFirstChild("Head") then
            for _, id in ipairs(config.Head) do
                attachItem(id, character.Head)
                task.wait(0.3)
            end
        end
        local upperTorso = character:FindFirstChild("UpperTorso")
            or character:FindFirstChild("Torso")
        if upperTorso then
            for _, id in ipairs(config.Torso) do
                attachItem(id, upperTorso)
                task.wait(0.3)
            end
        end
        local hand = character:FindFirstChild("RightHand")
            or character:FindFirstChild("LeftHand")
            or character:FindFirstChild("Right Arm")
            or character:FindFirstChild("Left Arm")
        if hand and config.Hand then
            for _, id in ipairs(config.Hand) do
                attachItem(id, hand)
                task.wait(0.3)
            end
        end
        hideHead(character)
    end
    GameToolsGroup:AddToggle("GiveVisualItems", {
        Text = "给予视觉物品",
        Tooltip = "本地装饰头部/躯干/手部，并隐藏头部",
        Default = false,
        Callback = function(Value)
            enabled = Value and true or false
            if connection then
                connection:Disconnect()
                connection = nil
            end
            if enabled then
                applyAll()
                connection = localPlayer2.CharacterAdded:Connect(function()
                    task.wait(1)
                    if enabled then
                        applyAll()
                    end
                end)
            end
            PlayToggleSound()
        end,
    })
end
do
    local enabled  = false
    local conn     = nil
    local saved    = {}
    GameToolsGroup:AddToggle("Fullbright", {
        Text = "全量模式",
        Tooltip = "地图全亮，关闭阴影",
        Default = false,
        Callback = function(Value)
            enabled = Value and true or false
            if enabled then
                saved.Brightness     = Lighting.Brightness
                saved.ClockTime      = Lighting.ClockTime
                saved.FogEnd         = Lighting.FogEnd
                saved.GlobalShadows  = Lighting.GlobalShadows
                saved.OutdoorAmbient = Lighting.OutdoorAmbient
                saved.Ambient        = Lighting.Ambient

                Lighting.Brightness     = 2
                Lighting.ClockTime      = 14
                Lighting.FogEnd         = 100000
                Lighting.GlobalShadows  = false
                Lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128)
                Lighting.Ambient        = Color3.fromRGB(255, 255, 255)

                if conn then conn:Disconnect() end
                conn = Lighting.Changed:Connect(function()
                    if not enabled then return end
                    Lighting.Brightness     = 2
                    Lighting.ClockTime      = 14
                    Lighting.FogEnd         = 100000
                    Lighting.GlobalShadows  = false
                    Lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128)
                    Lighting.Ambient        = Color3.fromRGB(255, 255, 255)
                end)
            else
                for k, v in pairs(saved) do
                    pcall(function()
                        Lighting[k] = v
                    end)
                end
                if conn then
                    conn:Disconnect()
                    conn = nil
                end
            end
            PlayToggleSound()
        end,
    })
end
do
    local enabled = false
    local value   = 120
    local conn    = nil
    local function apply()
        local cam = workspace.CurrentCamera
        if not cam then return end
        cam.FieldOfView = value
        if conn then conn:Disconnect() end
        conn = cam:GetPropertyChangedSignal("FieldOfView"):Connect(function()
            if enabled and cam.FieldOfView ~= value then
                cam.FieldOfView = value
            end
        end)
    end
    GameToolsGroup:AddToggle("FOVChanger", {
        Text = "视野修改",
        Tooltip = "修改相机视野范围",
        Default = false,
        Callback = function(Value)
            enabled = Value and true or false
            if enabled then
                apply()
            else
                if conn then
                    conn:Disconnect()
                    conn = nil
                end
                workspace.CurrentCamera.FieldOfView = 70
            end
            PlayToggleSound()
        end,
    })
    GameToolsGroup:AddSlider("FOVSlider", {
        Text = "FOV 值",
        Tooltip = "70 - 120",
        Default = 120,
        Min = 70,
        Max = 120,
        Rounding = 0,
        Compact = false,
        Callback = function(Value)
            value = math.min(Value, 120)
            if enabled then
                workspace.CurrentCamera.FieldOfView = value
            end
        end,
    })
end
do
    local enabled  = false
    local conn     = nil
    local button   = nil
    local distance = 13
    local rayLen   = 6
    local function teleportThroughWall()
        if not enabled then return end
        local character = localPlayer2.Character
        if not character then return end
        local hrp = character:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        local cam = workspace.CurrentCamera
        if not cam then return end
        local look = cam.CFrame.LookVector
        local origin = hrp.Position
        local params = RaycastParams.new()
        params.FilterType = Enum.RaycastFilterType.Blacklist
        params.FilterDescendantsInstances = { character }
        params.IgnoreWater = true

        local hit = workspace:Raycast(origin, look * rayLen, params)
        local target = origin + look * distance
        if hit then
            target = hit.Position + look * 3 + hit.Normal * 2
        end
        hrp.CanCollide = false
        hrp.CFrame = CFrame.new(target)
        task.wait()
        hrp.CanCollide = true
    end
    local function createButton()
        if button then
            pcall(function() button:Destroy() end)
        end
        local gui = Instance.new("ScreenGui")
        gui.Name = HttpService:GenerateGUID(false)
        gui.ResetOnSpawn = false
        gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        gui.Parent = localPlayer2:WaitForChild("PlayerGui")
        local btn = Instance.new("TextButton")
        btn.Name = HttpService:GenerateGUID(false)
        btn.Size = UDim2.new(0, 90, 0, 90)
        btn.Position = UDim2.new(1, -110, 0.5, -45)
        btn.BackgroundColor3 = Color3.fromRGB(15, 15, 18)
        btn.BackgroundTransparency = 0.25
        btn.Text = "TP Wall"
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.TextSize = 16
        btn.Font = Enum.Font.GothamBold
        btn.AutoButtonColor = true
        btn.Parent = gui
        local stroke = Instance.new("UIStroke")
        stroke.Color = Color3.fromRGB(200, 200, 210)
        stroke.Thickness = 1.5
        stroke.Parent = btn
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 12)
        corner.Parent = btn
        local dragging   = false
        local dragged    = false
        local startPos   = nil
        local startBtnPos = nil
        btn.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.Touch
                or input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging    = true
                dragged     = false
                startPos    = input.Position
                startBtnPos = btn.Position
            end
        end)
        UserInputService.InputChanged:Connect(function(input)
            if not dragging then return end
            if input.UserInputType == Enum.UserInputType.Touch
                or input.UserInputType == Enum.UserInputType.MouseMovement then
                local delta = input.Position - startPos
                if math.abs(delta.X) > 6 or math.abs(delta.Y) > 6 then
                    dragged = true
                end
                btn.Position = UDim2.new(
                    startBtnPos.X.Scale, startBtnPos.X.Offset + delta.X,
                    startBtnPos.Y.Scale, startBtnPos.Y.Offset + delta.Y
                )
            end
        end)
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.Touch
                or input.UserInputType == Enum.UserInputType.MouseButton1 then
                if dragging and not dragged then
                    pcall(teleportThroughWall)
                end
                dragging = false
            end
        end)
        button = gui
    end
    GameToolsGroup:AddToggle("ThroughWalls", {
        Text = "穿墙传送",
        Tooltip = "按 X 键沿视线方向穿墙传送（移动端会有悬浮按钮）",
        Default = false,
        Callback = function(Value)
            enabled = Value and true or false
            if conn then
                pcall(function() conn:Disconnect() end)
                conn = nil
            end
            if button then
                pcall(function() button:Destroy() end)
                button = nil
            end
            if enabled then
                conn = UserInputService.InputBegan:Connect(function(input, gameProcessed)
                    if gameProcessed then return end
                    if input.KeyCode == Enum.KeyCode.X then
                        pcall(teleportThroughWall)
                    end
                end)
                if is_mobile() then
                    pcall(createButton)
                end
            end
            PlayToggleSound()
            return true
        end,
    })
end
end
do
local Players           = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace         = game:GetService("Workspace")
local RunService        = game:GetService("RunService")
local localPlayer       = Players.LocalPlayer
local localPlayer2      = localPlayer
local RunService2       = RunService

local function PlayToggleSound() end
local function PlayErrorSound() end
local function PlayBell() end

local function notify(title, text, duration)
    Library:Notify({
        Title = tostring(title),
        Description = tostring(text or ""),
        Time = tonumber(duration) or 0.9,
    })
end

local function fn61(fn, ...)
    if type(fn) ~= "function" then return end
    local args = table.pack(...)
    task.spawn(function()
        pcall(fn, table.unpack(args, 1, args.n))
    end)
end

local function get_character()
    return localPlayer.Character
end

local function get_humanoid(ch)
    return ch and ch:FindFirstChildOfClass("Humanoid")
end

local function get_root_part(ch)
    return ch and ch:FindFirstChild("HumanoidRootPart")
end
do
    local enabled   = false
    local conn      = nil
    local targetPos = Vector3.new(-214.3, 186.86, 242.64)
    local radius    = 80

    GameToolsGroup:AddToggle("AutoNextGame", {
        Text = "自动下一局",
        Tooltip = "靠近目标点 80 格内持续 3.4s 后自动 FireServer 进入下一局",
        Default = false,
        Callback = function(Value)
            enabled = Value and true or false

            if conn then
                conn:Disconnect()
                conn = nil
            end
            if enabled then
                local n = 0
                conn = RunService.Heartbeat:Connect(function(dt)
                    if not enabled then return end

                    local character = localPlayer.Character
                    local position = character
                        and character.PrimaryPart
                        and character.PrimaryPart.Position

                    if position and (position - targetPos).Magnitude <= radius then
                        n += dt
                        if n >= 3.4 then
                            n = 0
                            pcall(function()
                                ReplicatedStorage
                                    :WaitForChild("Remotes")
                                    :WaitForChild("TemporaryReachedBindable")
                                    :FireServer()
                            end)
                        end
                    else
                        n = 0
                    end
                end)
            end

            PlayToggleSound()
        end,
    })
end
do
    local enabled = false
    local conn    = nil
    local obj     = nil

    GameToolsGroup:AddToggle("NoDashCD", {
        Text = "去冲刺 CD",
        Tooltip = "通过 getgc 找到 CDDASHSTACKS 对象，每帧清空 CD",
        Default = false,
        Callback = function(Value)
            enabled = Value and true or false

            if conn then
                pcall(function() conn:Disconnect() end)
                conn = nil
            end
            obj = nil

            if enabled then
                pcall(function()
                    for _, v2 in pairs(getgc(true)) do
                        if type(v2) == "table"
                            and rawget(v2, "CDDASHSTACKS")
                            and rawget(v2, "StopCounter") then
                            obj = v2
                            break
                        end
                    end
                end)

                if obj then
                    conn = RunService.RenderStepped:Connect(function()
                        if not enabled then return end
                        if not obj then return end
                        pcall(function()
                            rawset(obj, "DashCD", nil)
                            if rawget(obj, "CDDASHSTACKS") and rawget(obj, "CDDASHSTACKS") > 1 then
                                rawset(obj, "CDDASHSTACKS", 1)
                            end
                        end)
                    end)
                else
                    notify("No Dash CD", "未找到目标对象（getgc 失败）", 1.2)
                end
            end

            PlayToggleSound()
            return true
        end,
    })
end
do
    local enabled = false
    local loop    = nil

    GameToolsGroup:AddToggle("FasterSprint", {
        Text = "无限冲刺体力",
        Tooltip = "每帧维护 FASTERSPRINT 文件夹 + StaminaVal = 100",
        Default = false,
        Callback = function(Value)
            enabled = Value and true or false

            if loop then
                pcall(task.cancel, loop)
                loop = nil
            end

            if enabled then
                loop = task.spawn(function()
                    local lp = localPlayer
                    while enabled do
                        local character = lp.Character
                        if character and character.Parent then
                            if not character:FindFirstChild("FASTERSPRINT") then
                                local folder = Instance.new("Folder")
                                folder.Name = "FASTERSPRINT"
                                folder.Parent = character
                            end

                            local delFolder = character:FindFirstChild("DelIfGone_Folder")
                            if delFolder then delFolder:Destroy() end

                            local staminaVal = character:FindFirstChild("StaminaVal")
                            if staminaVal then staminaVal.Value = 100 end
                        end
                        task.wait()
                    end
                end)
            end

            PlayToggleSound()
            return true
        end,
    })
end
do
    local enabled       = false
    local origCanCollide = {}
    local conns         = {}

    local function isWall(part)
        if part.Name:lower():find("wall") then return true end
        if part.Size.Y > part.Size.X or part.Size.Y > part.Size.Z then return true end
        return false
    end

    local function isFloor(part)
        local str = part.Name:lower()
        if str:find("floor") or str:find("ground") or str:find("plate") then
            return true
        end
        if part.Size.Y < part.Size.X and part.Size.Y < part.Size.Z then
            return true
        end
        return false
    end

    local function applyNoclip(part)
        if not part:IsA("BasePart") then return end
        local character = localPlayer2.Character
        if character and part:IsDescendantOf(character) then return end

        if origCanCollide[part] == nil then
            origCanCollide[part] = part.CanCollide
        end

        if enabled then
            if isFloor(part) then
                part.CanCollide = true
            elseif isWall(part) then
                part.CanCollide = false
            end
        else
            part.CanCollide = origCanCollide[part]
        end
    end

    local function scanAll()
        for _, descendant in ipairs(Workspace:GetDescendants()) do
            applyNoclip(descendant)
        end
    end

    local function restoreAll()
        for k, v in pairs(origCanCollide) do
            if k and k.Parent then
                pcall(function() k.CanCollide = v end)
            end
        end
        table.clear(origCanCollide)
    end

    GameToolsGroup:AddToggle("Noclip", {
        Text = "智能穿墙",
        Tooltip = "识别墙/地板，只对墙关闭 CanCollide，保留地板碰撞",
        Default = false,
        Callback = function(Value)
            enabled = Value and true or false

            for _, c in ipairs(conns) do
                pcall(function() c:Disconnect() end)
            end
            table.clear(conns)

            if enabled then
                scanAll()
                table.insert(conns, Workspace.DescendantAdded:Connect(function(descendant)
                    if enabled then applyNoclip(descendant) end
                end))
            else
                restoreAll()
            end

            PlayToggleSound()
            return true
        end,
    })
end
do
    local enabled      = false
    local isActive     = false
    local currentTarget = nil
    local fakeChar     = nil
    local hideConn     = nil
    local seqTask      = nil
    local originalNametag = nil
    local nametagParent   = nil
    local watchdog     = nil

    local animIds = {
        Startup = "rbxassetid://135801672920476",
        Sprint  = "rbxassetid://82609803681213",
        Jump    = "rbxassetid://130659228300247",
        Fall    = "rbxassetid://112693580156198",
    }

    local function getNearest()
        local character = localPlayer2.Character
        character = character and character:FindFirstChild("HumanoidRootPart")
        if not character then return nil end

        local huge = math.huge
        local result = nil

        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= localPlayer2 and player.Character then
                local hrp = player.Character:FindFirstChild("HumanoidRootPart")
                local hum = player.Character:FindFirstChild("Humanoid")

                if hrp and hum and hum.Health > 0 then
                    local mag = (hrp.Position - character.Position).Magnitude
                    if mag < huge then
                        huge = mag
                        result = player
                    end
                end
            end
        end

        return result
    end
    local function setHidden(character, hide)
        if not character then return end
        for _, d in ipairs(character:GetDescendants()) do
            if d:IsA("BasePart") or d:IsA("Decal") or d:IsA("Texture") then
                if d.Name ~= "Player_Nametag"
                    and not d:FindFirstAncestor("Player_Nametag") then
                    d.LocalTransparencyModifier = hide and 1 or 0
                end
            elseif d:IsA("Accessory") then
                local handle = d:FindFirstChild("Handle")
                if handle then
                    handle.LocalTransparencyModifier = hide and 1 or 0
                end
            end
        end
    end
    local function findNametag(character)
        if not character then return nil, nil end
        local torso = character:FindFirstChild("Torso") or character:FindFirstChild("UpperTorso")
        if torso then
            local tag = torso:FindFirstChild("Player_Nametag")
            if tag then return tag, torso end
        end
        for _, d in ipairs(character:GetDescendants()) do
            if d.Name == "Player_Nametag" then
                return d, d.Parent
            end
        end
        return nil, nil
    end
    local function moveNametag(character, fakeCharacter)
        local tag, parent = findNametag(character)
        if not tag or not fakeCharacter then return end
        originalNametag = tag
        nametagParent   = parent
        local torso = fakeCharacter:FindFirstChild("Torso")
            or fakeCharacter:FindFirstChild("UpperTorso")
        if not torso then return end
        tag.Parent = torso
    end
    local function restoreNametag()
        if originalNametag and nametagParent and originalNametag.Parent then
            pcall(function()
                originalNametag.Parent = nametagParent
            end)
        end
        originalNametag = nil
        nametagParent   = nil
    end
    local function turnOff()
        isActive = false
        if seqTask then
            task.cancel(seqTask)
            seqTask = nil
        end
        if hideConn then
            hideConn:Disconnect()
            hideConn = nil
        end
        if watchdog then
            watchdog:Disconnect()
            watchdog = nil
        end
        restoreNametag()
        if currentTarget and currentTarget.Character then
            setHidden(currentTarget.Character, false)
        end
        if fakeChar and fakeChar.Parent then
            fakeChar:Destroy()
        end
        currentTarget = nil
        fakeChar = nil
    end
    local function activate()
        local character = localPlayer2.Character
        local myHRP = character and character:FindFirstChild("HumanoidRootPart")
        if not myHRP then turnOff(); return end
        if not currentTarget then turnOff(); return end
        local targetChar = currentTarget.Character
        if not targetChar then turnOff(); return end
        local targetHRP = targetChar:FindFirstChild("HumanoidRootPart")
        if not targetHRP then turnOff(); return end
        local archivable = targetChar.Archivable
        targetChar.Archivable = true
        fakeChar = targetChar:Clone()
        targetChar.Archivable = archivable
        for _, d in ipairs(fakeChar:GetDescendants()) do
            if d:IsA("Script") or d:IsA("LocalScript") then
                d:Destroy()
            elseif d.Name == "Player_Nametag" then
                d:Destroy()
            end
        end
        local fakeHRP = fakeChar:FindFirstChild("HumanoidRootPart")
        local fakeHum = fakeChar:FindFirstChild("Humanoid")

        if not fakeHRP or not fakeHum then
            fakeChar:Destroy()
            turnOff()
            return
        end
        fakeHRP.Anchored = true
        fakeHRP.CFrame = targetHRP.CFrame
        fakeChar.Parent = workspace
        moveNametag(targetChar, fakeChar)
        local animator = fakeHum:FindFirstChildOfClass("Animator")
            or Instance.new("Animator", fakeHum)

        local function loadAnim(id)
            local a = Instance.new("Animation")
            a.AnimationId = id
            return animator:LoadAnimation(a)
        end
        local startAnim  = loadAnim(animIds.Startup)
        local sprintAnim = loadAnim(animIds.Sprint)
        local jumpAnim   = loadAnim(animIds.Jump)
        local fallAnim   = loadAnim(animIds.Fall)
        startAnim.Priority  = Enum.AnimationPriority.Action4
        sprintAnim.Priority = Enum.AnimationPriority.Action4
        jumpAnim.Priority   = Enum.AnimationPriority.Action4
        fallAnim.Priority   = Enum.AnimationPriority.Action4
        hideConn = RunService.RenderStepped:Connect(function()
            if currentTarget and currentTarget.Character then
                setHidden(currentTarget.Character, true)
            end
        end)
        seqTask = task.spawn(function()
            startAnim:Play()
            task.wait(0.4)
            startAnim:Stop(0.2)
            sprintAnim:Play()
            local n = 0
            while n < 2.5 and isActive do
                local dt = task.wait()
                n += dt
                if not myHRP or not myHRP.Parent
                    or not fakeHRP or not fakeHRP.Parent then
                    break
                end
                fakeHRP.CFrame = CFrame.lookAt(
                    fakeHRP.Position,
                    myHRP.Position
                        + Vector3.new(math.sin(n * 10) * 16, 0, math.cos(n * 10) * 16)
                        + Vector3.new(0, 0.1, 0)
                ) * CFrame.new(0, 0, -55 * dt)
                local rot = fakeHRP.CFrame.Rotation
                fakeHRP.CFrame = CFrame.new(
                    fakeHRP.Position.X,
                    myHRP.Position.Y,
                    fakeHRP.Position.Z
                ) * rot
            end
            sprintAnim:Stop(0.2)
            jumpAnim:Play()
            local n2 = 0
            while true do
                if n2 < 0.45 and isActive then
                    local dt = task.wait()
                    n2 += dt
                    if not (not fakeHRP or not fakeHRP.Parent) then
                        fakeHRP.CFrame = fakeHRP.CFrame
                            * CFrame.new(0, 28 * dt, -12 * dt)
                        continue
                    end
                end
                break
            end
            jumpAnim:Stop(0.2)
            fallAnim:Play()
            local n3 = 0
            while isActive do
                local dt = task.wait()
                n3 += dt * 6

                if not (not myHRP or not myHRP.Parent
                    or not fakeHRP or not fakeHRP.Parent) then
                    local n4 = 18 + math.sin(n3 * 1.5) * 8
                    local n5 = 8 + math.cos(n3 * 1.2) * 5
                    fakeHRP.CFrame = CFrame.lookAt(
                        fakeHRP.Position,
                        myHRP.Position
                            + Vector3.new(math.sin(n3 * 1.2) * n4, n5, math.cos(n3 * 1.2) * n4)
                    ) * CFrame.new(0, 0, -70 * dt)
                    continue
                end
                break
            end
        end)
        watchdog = RunService.Heartbeat:Connect(function()
            if isActive and currentTarget then
                if not currentTarget.Parent
                    or not currentTarget.Character
                    or not currentTarget.Character:FindFirstChild("HumanoidRootPart") then
                    turnOff()
                end
            end
        end)
    end
    GameToolsGroup:AddToggle("FakeExploiter", {
        Text = "伪装外挂",
        Tooltip = "让最近玩家的假分身在你本地疯狂飞行 + 加速 + 乱转，用于举报",
        Default = false,
        Callback = function(Value)
            enabled = Value and true or false

            if enabled then
                local target = getNearest()
                if not target then
                    enabled = false
                    notify("Fake Exploiter", "No target nearby", 0.9)
                    PlayErrorSound()
                    if Options.FakeExploiter then
                        Options.FakeExploiter:SetValue(false)
                    end
                    return false
                end
                isActive = true
                currentTarget = target
                activate()
                notify("Fake Exploiter", "On: " .. tostring(target.DisplayName or target.Name), 1)
            else
                turnOff()
                notify("Fake Exploiter", "Off", 0.8)
            end
            PlayToggleSound()
            return true
        end,
    })
end
end
--自动投票
AutoVoteGroup:AddDropdown("Tools_Vote1", {
Values = { "无", "糖饼", "五项全能" }, Default = 1, Multi = false, Text = "投票1：糖饼/五项全能",
})
AutoVoteGroup:AddDropdown("Tools_Vote2", {
Values = { "无", "捉迷藏", "拔河" }, Default = 1, Multi = false, Text = "投票2：捉迷藏/拔河",
})
AutoVoteGroup:AddDropdown("Tools_Vote3", {
Values = { "无", "跳绳", "玻璃桥" }, Default = 1, Multi = false, Text = "投票3：跳绳/玻璃桥",
})
AutoVoteGroup:AddDropdown("Tools_Vote4", {
Values = { "无", "继续", "反抗者" }, Default = 1, Multi = false, Text = "投票4：反抗者/继续",
})
tbl2.autoVoteThread = false
AutoVoteGroup:AddToggle("Tools_AutoVote", {
Text = "启用自动投票",
Default = false,
Callback = function(on)
    tbl2.autoVoteThread = on
    if on then
        task.spawn(function()
            while tbl2.autoVoteThread do
                local rem = ReplicatedStorage:FindFirstChild("Remotes")
                if rem and rem:FindFirstChild("ExtraTemporaryRemote") then
                    local pg = localPlayer:WaitForChild("PlayerGui", 2)
                    if pg then
                        local pick = pg:FindFirstChild("VotingToPickGames", true)
                        local endGame = pg:FindFirstChild("VotingToEndGames", true)
                        if pick then
                            if pick:FindFirstChild("VotingBoardLeft") then pick.VotingBoardLeft.Visible = false end
                            if pick:FindFirstChild("VotingBoardRight") then pick.VotingBoardRight.Visible = false end
                        end
                        if endGame and endGame:FindFirstChild("VotingBoard") then
                            endGame.VotingBoard.Visible = false
                        end
                    end
                end
                task.wait(1)
            end
        end)
    end
end,
})
--实用工具和传送功能
tbl.customPhantomEnabled = false
do
local enabled = false
local phantomCharges = 2
local phantomLock = false
local cloneMobile = nil
local nextSound = 1

task.spawn(function()
    pcall(function()
        if not isfolder("UwUInk") then makefolder("UwUInk") end
        if not isfile("UwUInk/1.mp3") then
            writefile("UwUInk/1.mp3", game:HttpGet("https://github.com/platinww/UwU/raw/refs/heads/main/UI/1.mp3"))
        end
        if not isfile("UwUInk/2.mp3") then
            writefile("UwUInk/2.mp3", game:HttpGet("https://github.com/platinww/UwU/raw/refs/heads/main/UI/2.mp3"))
        end
    end)
end)

local function spawnFX(parent, dir)
    local att = Instance.new("Attachment"); att.Parent = parent
    if dir then att.WorldCFrame = CFrame.lookAt(parent.Position, parent.Position + dir) end
    local function mk(prop)
        local p = Instance.new("ParticleEmitter")
        for k, v in pairs(prop) do p[k] = v end
        p.Parent = att
        p:Emit(p.Rate or 10)
        return p
    end
    mk({ Texture="rbxassetid://15431126240", Lifetime=NumberRange.new(0.075,0.17), Rate=75, Speed=NumberRange.new(39,156), Size=NumberSequence.new({NumberSequenceKeypoint.new(0,0,0),NumberSequenceKeypoint.new(0.09322,3.9975,0.19326),NumberSequenceKeypoint.new(1,0,0)}), Color=ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.new(0,0,0)),ColorSequenceKeypoint.new(1,Color3.new(0,0,0))}), Squash=NumberSequence.new({NumberSequenceKeypoint.new(0,2,0),NumberSequenceKeypoint.new(1,2,0)}), Transparency=NumberSequence.new({NumberSequenceKeypoint.new(0,0,0),NumberSequenceKeypoint.new(1,0,0)}), ZOffset=0, SpreadAngle=Vector2.new(0,0), Rotation=NumberRange.new(90,90), LightInfluence=0, LightEmission=-3, LockedToPart=true, Shape=Enum.ParticleEmitterShape.Box, ShapeInOut=Enum.ParticleEmitterShapeInOut.Outward, ShapePartial=1, ShapeStyle=Enum.ParticleEmitterShapeStyle.Volume, Drag=15 })
    task.delay(1.7, function() att:Destroy() end)
end

local function doPhantom()
    if phantomCharges <= 0 or phantomLock then return end
    local ch = localPlayer.Character
    local hrp = ch and ch:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local hum = ch:FindFirstChild("Humanoid")
    if hum and hum.Health <= 0 then return end       
    for _, p in ipairs(hrp:GetConnectedParts(true)) do
        local m = p:FindFirstAncestorOfClass("Model")
        if m and m ~= ch and Players:GetPlayerFromCharacter(m) then return end
    end
    local carryList = {
        ["rbxassetid://95966876052605"]=true,["rbxassetid://96909201344123"]=true,
        ["rbxassetid://103036184572721"]=true,["rbxassetid://92750801694745"]=true,
        ["rbxassetid://79058658453400"]=true,["rbxassetid://71410568064809"]=true,
        ["rbxassetid://135421881374988"]=true,["rbxassetid://128174895245172"]=true,
        ["rbxassetid://90903084043782"]=true,["rbxassetid://134977807883018"]=true,
        ["rbxassetid://99725739479024"]=true,["rbxassetid://86955193235427"]=true,
        ["rbxassetid://76720621720056"]=true,["rbxassetid://115446895197171"]=true,
    }
    if hum then
        local an = hum:FindFirstChildOfClass("Animator")
        if an then
            for _, t in ipairs(an:GetPlayingAnimationTracks()) do
                if t.Animation then
                    local id = t.Animation.AnimationId
                    local nm = string.lower(t.Animation.Name)
                    if carryList[id] or string.find(string.lower(id),"carry") or string.find(nm,"carry") or string.find(nm,"carried") then
                        return
                    end
                end
            end
        end
    end
    if fn12("TugOfWar") then return end
    phantomCharges -= 1
    phantomLock = true
    task.delay(0.2, function() phantomLock = false end)
    task.delay(1.5, function() if phantomCharges < 2 then phantomCharges += 1 end end)

    local baseCF = hrp.CFrame
    local moveDir = hum.MoveDirection.Magnitude > 0.1 and hum.MoveDirection or baseCF.LookVector
    local rp = RaycastParams.new()
    local filt = { ch }
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= localPlayer and p.Character then table.insert(filt, p.Character) end
    end
    rp.FilterDescendantsInstances = filt
    rp.FilterType = Enum.RaycastFilterType.Exclude
    local from = baseCF.Position
    local remaining = 11
    local hitPos = nil
    for _ = 1, 15 do
        local h = workspace:Raycast(from, moveDir*remaining, rp)
        hitPos = nil
        if h then
            if h.Instance.CanCollide then hitPos = h.Position; break end
            table.insert(filt, h.Instance)
            rp.FilterDescendantsInstances = filt
            remaining -= (h.Position - from).Magnitude
            from = h.Position + moveDir*0.01
            if remaining <= 0 then break end
        else break end
    end
    local dist = 11
    if hitPos then dist = math.max(0, (hitPos - baseCF.Position).Magnitude - 1.5) end
    local target = baseCF + moveDir*dist
    spawnFX(hrp, moveDir)

    local sg = Instance.new("ScreenGui"); sg.IgnoreGuiInset = true
    pcall(function() sg.Parent = game:GetService("CoreGui") end)
    if not sg.Parent then sg.Parent = localPlayer:WaitForChild("PlayerGui") end
    local il = Instance.new("ImageLabel")
    il.Size = UDim2.new(1,0,1,0); il.BackgroundTransparency = 1
    il.Image = "rbxassetid://17464258529"
    il.ImageColor3 = Color3.new(0,0,0); il.ImageTransparency = 1
    il.Parent = sg
    TweenService:Create(il, TweenInfo.new(0.05, Enum.EasingStyle.Sine), { ImageTransparency = 0.2 }):Play()
    local cam = workspace.CurrentCamera
    local savedFov = 70
    TweenService:Create(cam, TweenInfo.new(0.05, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), { FieldOfView = savedFov + 15 }):Play()
    local s = Instance.new("Sound")
    if phantomCharges == 0 then
        s.SoundId = getcustomasset(nextSound == 2 and "UwUInk/1.mp3" or "UwUInk/2.mp3")
        nextSound = nextSound == 2 and 1 or 2
    elseif math.random(1,100) <= 30 then
        s.SoundId = getcustomasset("UwUInk/2.mp3"); nextSound = 2
    else
        s.SoundId = getcustomasset("UwUInk/1.mp3"); nextSound = 1
    end
    s.Volume = 2; s.Parent = SoundService; s:Play()
    s.Ended:Connect(function() s:Destroy() end)
    local restored = {}
    for _, d in ipairs(ch:GetDescendants()) do
        if d:IsA("BasePart") and d.Name ~= "HumanoidRootPart" and d.Transparency < 1 then
            restored[d] = d.Transparency; d.Transparency = 1
        elseif d:IsA("Decal") and d.Transparency < 1 then
            restored[d] = d.Transparency; d.Transparency = 1
        end
    end
    TweenService:Create(hrp, TweenInfo.new(0.12, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), { CFrame = target }):Play()
    task.delay(0.12, function()
        for k, v in pairs(restored) do if k and k.Parent then k.Transparency = v end end
        spawnFX(hrp, moveDir)
        local tw = TweenService:Create(il, TweenInfo.new(0.8, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), { ImageTransparency = 1 })
        tw:Play()
        tw.Completed:Connect(function() sg:Destroy() end)
        TweenService:Create(cam, TweenInfo.new(0.45, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), { FieldOfView = savedFov }):Play()
    end)
end

local function setupMobile()
    local pg = localPlayer:FindFirstChild("PlayerGui")
    if pg then
        local ms = pg:FindFirstChild("MobileSupport")
        if ms then
            local btnE = ms:FindFirstChild("CustomPhantomBtn")
            if btnE then btnE:Destroy() end
            local roll = ms:FindFirstChild("RollButton")
            if roll and UserInputService.TouchEnabled then
                cloneMobile = roll:Clone()
                cloneMobile.Name = "CustomPhantomBtn"
                cloneMobile.Visible = true
                cloneMobile.Parent = ms
                cloneMobile.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
                        local h = cloneMobile:FindFirstChild("ImageLabelBaseHOLDING")
                        if h then h.Visible = true end
                        doPhantom()
                    end
                end)
                cloneMobile.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
                        local h = cloneMobile:FindFirstChild("ImageLabelBaseHOLDING")
                        if h then h.Visible = false end
                    end
                end)
                roll.Visible = false
            end
        end
    end
end

UtilGroup:AddToggle("Util_Phantom", {
    Text = "免费幻影步",
    Default = false,
    Callback = function(on)
        if on then
            if enabled then fn13(nil, "幻影步已激活！"); return end
            enabled = true
            phantomCharges = 2
            fn13(nil, "幻影步已激活 PC按键Q")
            ContextActionService:BindActionAtPriority("UwU_Phantom_Q", function(_, state)
                if state == Enum.UserInputState.Begin then doPhantom() end
                return Enum.ContextActionResult.Sink
            end, false, Enum.ContextActionPriority.High.Value + 100, Enum.KeyCode.Q)
            setupMobile()
        else
            ContextActionService:UnbindAction("UwU_Phantom_Q")
            if cloneMobile then cloneMobile:Destroy() end
            enabled = false
            fn13(nil, "幻影步已关闭")
        end
    end,
})
end

local playerList = {}
local selectedPlayer = ""
local function refreshPlayerList()
playerList = {}
for _, p in pairs(Players:GetPlayers()) do
    if p ~= localPlayer then table.insert(playerList, p.Name) end
end
end
refreshPlayerList()

btn(TeleGroup, "刷新玩家列表", function()
refreshPlayerList()
end)
TeleGroup:AddDropdown("Util_PlayerList", {
Values = playerList, Default = 1, Multi = false, Text = "选择玩家",
Callback = function(v) selectedPlayer = v end,
})
btn(TeleGroup, "传送到玩家", function()
refreshPlayerList()
if not selectedPlayer or selectedPlayer == "" then fn13(" 错误", "请先选择玩家"); return end
local p = Players:FindFirstChild(selectedPlayer)
if p and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
    fn17(p.Character.HumanoidRootPart.CFrame * CFrame.new(0,0,3))
    fn13(" 已传送", "已传送到 " .. selectedPlayer)
else fn13(" 错误", "未找到玩家或玩家没有角色") end
end)
tbl3.lastUtilitiesTPTime = 0
btn(TeleGroup, "向上传送100格", function()
if tick() - tbl3.lastUtilitiesTPTime < 10 then
    fn13(nil, "等待 " .. math.ceil(10-(tick()-tbl3.lastUtilitiesTPTime)) .. "秒"); return
end
local ch = localPlayer.Character
if ch and ch:FindFirstChild("HumanoidRootPart") then
    ch.HumanoidRootPart.CFrame = ch.HumanoidRootPart.CFrame * CFrame.new(0,100,0)
    tbl3.lastUtilitiesTPTime = tick()
    fn13(nil, "已向上传送100格")
end
end)
btn(TeleGroup, "向下传送50格", function()
if tick() - tbl3.lastUtilitiesTPTime < 10 then
    fn13(nil, "等待 " .. math.ceil(10-(tick()-tbl3.lastUtilitiesTPTime)) .. "秒"); return
end
local ch = localPlayer.Character
if ch and ch:FindFirstChild("HumanoidRootPart") then
    ch.HumanoidRootPart.CFrame = ch.HumanoidRootPart.CFrame * CFrame.new(0,-50,0)
    tbl3.lastUtilitiesTPTime = tick()
    fn13(nil, "已向下传送50格")
end
end)
do
local enabled = false
tbl2.stealThread = nil
local function hasBandage()
    local ch = localPlayer.Character
    if ch and ch:FindFirstChild("Bandage") then return true end
    local bp = localPlayer:FindFirstChild("Backpack")
    if bp and bp:FindFirstChild("Bandage") then return true end
    return false
end
local function redLight()
    if fn12("RedLightGreenLight") then
        local pg = localPlayer:FindFirstChild("PlayerGui")
        if pg then
            local imp = pg:FindFirstChild("ImpactFrames")
            if imp then
                local tl = imp:FindFirstChild("TrafficLightEmpty")
                if tl and tl.Image == "rbxassetid://88400194373338" then return true end
            end
        end
    end
    return false
end
local function findBandage()
    local function scan(root)
        for _, c in ipairs(root:GetChildren()) do
            if c.Name == "DroppedBandage" then
                local p = c:IsA("Model") and (c.PrimaryPart or c:FindFirstChildWhichIsA("BasePart", true)) or (c:IsA("BasePart") and c)
                if p then return c, p end
            end
        end
        return nil, nil
    end
    local a, b = scan(workspace); if a then return a, b end
    local eff = workspace:FindFirstChild("Effects")
    if eff then local c, d = scan(eff); if c then return c, d end end
    local live = workspace:FindFirstChild("Live")
    if live then local c, d = scan(live); if c then return c, d end end
    return nil, nil
end

UtilGroup:AddToggle("Util_AutoSteal", {
    Text = "自动偷绷带",
    Default = false,
    Callback = function(on)
        enabled = on
        if on then
            if tbl2.stealThread then return end
            tbl2.stealThread = true
            task.spawn(function()
                while enabled and tbl2.stealThread do
                    if not hasBandage() and not redLight() then
                        local bandage, part = findBandage()
                        if bandage and part then
                            local ch = localPlayer.Character
                            local hrp = ch and ch:FindFirstChild("HumanoidRootPart")
                            if hrp then
                                local back = hrp.CFrame
                                local target = part.CFrame
                                hrp.CFrame = target
                                local t = 0
                                while true do
                                    if enabled and not hasBandage() and bandage and bandage.Parent and t < 10 and not redLight() then
                                        hrp.CFrame = target
                                        if typeof(firetouchinterest) == "function" then
                                            pcall(function()
                                                firetouchinterest(hrp, part, 0)
                                                task.wait(0.05)
                                                firetouchinterest(hrp, part, 1)
                                            end)
                                        end
                                        task.wait(0.1); t += 1
                                    else break end
                                end
                                if ch and ch:FindFirstChild("HumanoidRootPart") then
                                    ch.HumanoidRootPart.CFrame = back
                                end
                                task.wait(0.5)
                            end
                        end
                    end
                    task.wait(0.5)
                end
                tbl2.stealThread = nil
            end)
        end
    end,
})
end
do
local walkSpeed, jumpPower = 14, 50
local m6dNames = { "Left Hip","Left Shoulder","Neck","Right Hip","Right Shoulder" }
local removeNames = { "Ragdoll","Stun","RotateDisabled","RagdollWakeupImmunity","RagdollWakeupImmunityLess","StopLoopTpFix","TrueStun","Waiting","waitbeforecheckingforground" }
local detectNames = { "Ragdoll","TrueStun","Stun","RotateDisabled","Waiting" }

local function stripAttrs(ch)
    for _, n2 in ipairs(removeNames) do
        local x = ch:FindFirstChild(n2); if x then x.Parent = nil end
    end
end
local function fixMotors(ch)
    local torso = ch:FindFirstChild("Torso"); if not torso then return end
    for _, c in ipairs(torso:GetChildren()) do
        if c:IsA("BallSocketConstraint") and c.Name:match("^SocketConstraint") then
            c.Enabled = false; c.Parent = nil
        end
    end
    for _, n2 in ipairs(m6dNames) do
        local m = torso:FindFirstChild(n2)
        if m and m:IsA("Motor6D") and not m.Part0 then m.Part0 = torso end
    end
end
local function stripHRP(ch)
    local hrp = ch:FindFirstChild("HumanoidRootPart"); if not hrp then return end
    for _, c in ipairs(hrp:GetChildren()) do
        if c.Name:match("^CacheAttachment") or c.Name:match("^SocketConstraint") then c.Parent = nil end
    end
    for _, c in ipairs(hrp:GetChildren()) do
        if c:IsA("BodyVelocity") or c:IsA("BodyForce") or c:IsA("BodyPosition") then c.Parent = nil end
    end
end
local function fullRecover(ch)
    local hum = ch:FindFirstChildOfClass("Humanoid"); if not hum then return end
    local hrp = ch:FindFirstChild("HumanoidRootPart")
    stripAttrs(ch)
    hum.PlatformStand = false
    hum.AutoRotate = true
    hum:SetStateEnabled(Enum.HumanoidStateType.Freefall, true)
    hum:SetStateEnabled(Enum.HumanoidStateType.Jumping, true)
    hum:SetStateEnabled(Enum.HumanoidStateType.Running, true)
    hum:SetStateEnabled(Enum.HumanoidStateType.GettingUp, true)
    hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
    hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
    hum:SetStateEnabled(Enum.HumanoidStateType.PlatformStanding, false)
    hum:ChangeState(Enum.HumanoidStateType.GettingUp)
    if hrp then hrp.AssemblyLinearVelocity = Vector3.new(0, hrp.AssemblyLinearVelocity.Y, 0) end
    fixMotors(ch); stripHRP(ch)
    hum.WalkSpeed = walkSpeed; hum.JumpPower = jumpPower
    if shared then shared.WalkSpeedChangeTick = nil end
    task.delay(0.1, function()
        if hum and hum.Parent and hum.Health > 0 then hum:ChangeState(Enum.HumanoidStateType.GettingUp) end
    end)
end

local conns = {}
local function clearConns()
    for _, c in ipairs(conns) do if c then c:Disconnect() end end
    table.clear(conns)
end
local function bind(ch)
    if not tbl.antiPushEnabled then return end
    clearConns()
    local hum = ch:FindFirstChildOfClass("Humanoid"); if not hum then return end
    local hrp = ch:FindFirstChild("HumanoidRootPart"); if not hrp then return end
    local dead = false
    table.insert(conns, ch.ChildAdded:Connect(function(c)
        if dead or not tbl.antiPushEnabled then return end
        for _, n2 in ipairs(detectNames) do
            if c.Name == n2 then
                task.spawn(function() fullRecover(ch) end)
                break
            end
        end
    end))
    table.insert(conns, RunService.Heartbeat:Connect(function()
        if not tbl.antiPushEnabled then clearConns(); return end
        if not ch or not ch.Parent then clearConns(); return end
        if not hum or not hum.Parent or hum.Health <= 0 then
            dead = true; clearConns(); return
        end
        stripAttrs(ch)
        if hum.PlatformStand then hum.PlatformStand = false; hum:ChangeState(Enum.HumanoidStateType.GettingUp) end
        if hum.WalkSpeed <= 0 then hum.WalkSpeed = walkSpeed; if shared then shared.WalkSpeedChangeTick = nil end end
        if hum.JumpPower <= 0 then hum.JumpPower = jumpPower end
        if not hum.AutoRotate then hum.AutoRotate = true end
        if not hum:GetStateEnabled(Enum.HumanoidStateType.Jumping) then hum:SetStateEnabled(Enum.HumanoidStateType.Jumping, true) end
        if not hum:GetStateEnabled(Enum.HumanoidStateType.Running) then hum:SetStateEnabled(Enum.HumanoidStateType.Running, true) end
        if not hum:GetStateEnabled(Enum.HumanoidStateType.GettingUp) then hum:SetStateEnabled(Enum.HumanoidStateType.GettingUp, true) end
        local torso = ch:FindFirstChild("Torso")
        if torso then
            local need = false
            for _, c in ipairs(torso:GetChildren()) do
                if c:IsA("BallSocketConstraint") and c.Name:match("^SocketConstraint") and c.Enabled then
                    need = true; break
                end
            end
            if need then fixMotors(ch) end
        end
        if hrp and hrp.Parent then
            for _, c in ipairs(hrp:GetChildren()) do
                if c:IsA("BodyVelocity") or c:IsA("BodyForce") then c.Parent = nil end
            end
        end
    end))
end
UtilGroup:AddToggle("Util_AntiPush", {
    Text = "防推/防布娃娃",
    Default = false,
    Callback = function(on)
        tbl.antiPushEnabled = on
        if on then
            if localPlayer.Character then bind(localPlayer.Character) end
            table.insert(conns, localPlayer.CharacterAdded:Connect(function(c)
                task.wait(0.5); if tbl.antiPushEnabled then bind(c) end
            end))
        else clearConns() end
    end,
})
end
do
local c
UtilGroup:AddToggle("Util_InstantInteract", {
    Text = "即时交互",
    Default = false,
    Callback = function(on)
        tbl.instantInteractEnabled = on
        if on then
            c = ProximityPromptService.PromptButtonHoldBegan:Connect(function(prompt, p)
                if tbl.instantInteractEnabled and p == localPlayer then
                    fireproximityprompt(prompt)
                end
            end)
        elseif c then c:Disconnect(); c = nil end
    end,
})
end
do
local Players           = game:GetService("Players")
local Workspace         = game:GetService("Workspace")
local RunService        = game:GetService("RunService")
local localPlayer       = Players.LocalPlayer
local localPlayer2      = localPlayer
local RunService2       = RunService
local function PlayToggleSound() end
local function PlayErrorSound() end
local function PlayBell() end
local function notify(title, text, duration)
    Library:Notify({
        Title = tostring(title),
        Description = tostring(text or ""),
        Time = tonumber(duration) or 0.9,
    })
end
local function fn61(fn, ...)
    if type(fn) ~= "function" then return end
    local args = table.pack(...)
    task.spawn(function()
        pcall(fn, table.unpack(args, 1, args.n))
    end)
end
local function get_character()
    return localPlayer.Character
end
local function get_humanoid(ch)
    return ch and ch:FindFirstChildOfClass("Humanoid")
end
do
    local enabled = false
    local conn    = nil
    local harmfulEffectsList = {
        "RagdollStun",
        "Stun",
        "Stunned",
        "StunEffect",
        "StunHit",
        "Knockback",
        "Knockdown",
        "Knockout",
        "Dazed",
        "Paralyzed",
        "Freeze",
        "Frozen",
        "Sleep",
        "Slow",
        "Slowed",
        "Root",
        "Rooted",
        "Crawling",
        "Crawled",
    }
    local function tick_remove()
        local char = get_character()
        if not char then return end
        for _, name in ipairs(harmfulEffectsList) do
            local obj = char:FindFirstChild(name)
            if obj then
                pcall(function() obj:Destroy() end)
            end
        end
        local hum = get_humanoid(char)
        if hum and hum:GetAttribute("Stunned") then
            hum:SetAttribute("Stunned", false)
        end
    end
    UtilGroup:AddToggle("AntiStun", {
        Text = "防眩晕",
        Tooltip = "每帧清除 21 种有害效果，并把 Humanoid.Stunned 属性设为 false",
        Default = false,
        Callback = function(Value)
            enabled = Value and true or false
            if conn then
                conn:Disconnect()
                conn = nil
            end
            if enabled then
                tick_remove()
                conn = RunService.Heartbeat:Connect(function()
                    if enabled then tick_remove() end
                end)
            end
            PlayToggleSound()
        end,
    })
end
do
    local enabled = false
    local conn    = nil
    local last    = 0
    local injuryNames = {
        Stun     = true,
        stunned  = true,
        Stunned  = true,
        crawl    = true,
        Crawl    = true,
        crawled  = true,
        Crawled  = true,
        crawling = true,
        Crawling = true,
    }
    local function tick_remove()
        local char = localPlayer2.Character
        if not char then return end
        for _, descendant in ipairs(char:GetDescendants()) do
            if injuryNames[descendant.Name] then
                pcall(function() descendant:Destroy() end)
            end
        end
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then
            pcall(function()
                for _, track in ipairs(hum:GetPlayingAnimationTracks()) do
                    if track.Animation then
                    end
                end
            end)
        end
    end
    UtilGroup:AddToggle("RemoveInjury", {
        Text = "防受伤 / 布娃娃(高级版)",
        Tooltip = "每 1 秒清除 Stun/Crawl 相关对象，用于被击倒后自动站起",
        Default = false,
        Callback = function(Value)
            enabled = Value and true or false
            if conn then
                pcall(function() conn:Disconnect() end)
                conn = nil
            end
            if enabled then
                tick_remove()
                conn = RunService2.Heartbeat:Connect(function()
                    if not enabled then return end
                    local now = tick()
                    if now - last < 1 then return end
                    last = now
                    tick_remove()
                end)
            end
            PlayToggleSound()
        end,
    })
end
do
    local enabled = false
    local task_   = nil
    local anniversaryFolders = {
        "GameplayLobbyForAnniversary",
        "RedLightGreenLightAnniversary",
        "JumpropeAnniversary",
        "Anniversary",
        "LobbyAnniversary",
        "MapAnniversary",
        "HideAndSeekAnniversary",
        "DalgonaAnniversary",
        "SkySquidGameAnniversary",
        "SquidGameAnniversary",
        "GlassBridgeAnniversary",
        "TugOfWarAnniversary",
        "LightsOutEffectBind",
    }
    local function tick_remove()
        for _, folder in ipairs(anniversaryFolders) do
            local obj = workspace:FindFirstChild(folder)
            if obj then
                pcall(function() obj:Destroy() end)
            end
        end
        local effects = workspace:FindFirstChild("Effects")
        if effects then
            local blood = effects:FindFirstChild("BloodSplatter")
            if blood then
                pcall(function() blood:Destroy() end)
            end
        end
    end
    UtilGroup:AddToggle("RemoveAnniversary", {
        Text = "移除周年庆装饰",
        Tooltip = "每 10 秒清理周年庆文件夹与血液溅射，减少卡顿",
        Default = false,
        Callback = function(Value)
            enabled = Value and true or false

            if task_ then
                task.cancel(task_)
                task_ = nil
            end
            if enabled then
                tick_remove()
                task_ = task.spawn(function()
                    while enabled do
                        task.wait(10)
                        if enabled then
                            tick_remove()
                            continue
                        end
                        break
                    end
                    task_ = nil
                end)
                notify("移除装饰", "周年庆装饰清除已开启", 0.9)
            else
                notify("移除装饰", "周年庆装饰清除已关闭", 0.9)
            end
            PlayToggleSound()
            return true
        end,
    })
end
end
--一大堆功能
VisualPowerGroup:AddButton({Text="闪光神掐人功能",Func=function()
    loadstring(game:HttpGet("https://api.luarmor.net/files/v4/loaders/95b3b990b427dd37b00222b35e7a6e5d.lua"))()
    local Func = loadstring(ScriptContent);
    if Func then
            Func();
    end
end});
VisualPowerGroup:AddToggle("Visual_UI", {
Text = "视觉究极本能",
Default = false,
Callback = function(on)
    if on then
        pcall(function()
            if getgenv and getgenv()._UI_CLEANUP then getgenv()._UI_CLEANUP() end
        end)
        local Players2 = game:GetService("Players")
        local localPlayer2 = Players2.LocalPlayer
        local SharedFunctions, Effects, UIDodgeCLIENTEFFECTS
        pcall(function()
            SharedFunctions = require(ReplicatedStorage.Modules.SharedFunctions)
            Effects = require(ReplicatedStorage.Modules.Effects)
            UIDodgeCLIENTEFFECTS = require(ReplicatedStorage.Modules.AbilityEffectsModules.UIDodgeCLIENTEFFECTS)
        end)
        local soundsA = { "rbxassetid://109819027147829","rbxassetid://92129593029820","rbxassetid://119518089922771","rbxassetid://133278063201532","rbxassetid://114251651938052" }
        local animIds = { "rbxassetid://117886505329162","rbxassetid://72808867502440","rbxassetid://94169703055500","rbxassetid://94537387793682","rbxassetid://82454268128485" }
        local idx = 1
        local busy = false
        local value = 10
        local maxV = 10
        local tracks = {}
        local alive = true
        local intV = Instance.new("IntValue"); intV.Value = value; intV:SetAttribute("MaxDodges", 10)

        local function loadAnim(hum)
            tracks = {}
            local an = hum:FindFirstChildOfClass("Animator")
            if not an then an = Instance.new("Animator"); an.Parent = hum end
            for _, id in ipairs(animIds) do
                local a = Instance.new("Animation"); a.AnimationId = id
                local t = an:LoadAnimation(a)
                t.Priority = Enum.AnimationPriority.Action4
                table.insert(tracks, t)
            end
        end
        local function stripFX(ch)
            if not ch then return end
            for _, d in ipairs(ch:GetDescendants()) do
                if d:IsA("ParticleEmitter") or d:IsA("Highlight") then
                    if d.Name:find("UI_") or d.Name:find("Permanent_") or d.Name == "Highlight" then
                        pcall(function() d:Destroy() end)
                    end
                elseif d:IsA("Attachment") and (d.Name:find("UI_") or d.Name:find("Permanent_")) then
                    pcall(function() d:Destroy() end)
                end
            end
        end
        local function refreshCount()
            pcall(function()
                intV.Value = value
                if Effects and Effects.UltraInstinctDisplayDodge then
                    Effects.UltraInstinctDisplayDodge({ Obj = intV })
                end
            end)
        end
        local function onEquip(ch)
            if not ch then return end
            local hrp = ch:FindFirstChild("HumanoidRootPart"); if not hrp then return end
            if SharedFunctions and SharedFunctions.PlaySound then
                pcall(function() SharedFunctions.PlaySound(hrp, "rbxassetid://121690585734302", 7) end)
            end
            if UIDodgeCLIENTEFFECTS then
                pcall(function() UIDodgeCLIENTEFFECTS({ ModuleName="UIDodge", Character=ch, initial=true }) end)
            end
            pcall(function()
                local fx = ReplicatedStorage.Effects.SetupParts.CustomEffectsFolders:FindFirstChild("UIDodge")
                if fx then
                    for _, n2 in ipairs({ "Torso","Head","Left Arm","Right Arm","Left Leg","Right Leg" }) do
                        local body = ch:FindFirstChild(n2)
                        local src = fx:FindFirstChild(n2)
                        if body and src then
                            for _, c in ipairs(src:GetChildren()) do
                                if c:IsA("ParticleEmitter") then
                                    local cl = c:Clone(); cl.Parent = body
                                    cl:Emit(cl:GetAttribute("EmitCount") or 15)
                                    task.delay(2.5, function() if cl and cl.Parent then cl:Destroy() end end)
                                end
                            end
                        end
                    end
                end
            end)
        end
        local function dash()
            local ch = localPlayer2.Character; if not ch then return end
            local hum = ch:FindFirstChildOfClass("Humanoid")
            local hrp = ch:FindFirstChild("HumanoidRootPart")
            if not hum or not hrp or hum.Health <= 0 then return end
            if busy then return end
            busy = true
            local k = idx
            idx = idx % #animIds + 1
            if value > 0 then value -= 1 else value = maxV end
            refreshCount()
            pcall(function()
                local sid = soundsA[k] or soundsA[1]
                if SharedFunctions and SharedFunctions.PlaySound then
                    SharedFunctions.PlaySound(hrp, sid, 7)
                end
            end)
            if #tracks == 0 then loadAnim(hum) end
            local t = tracks[k]; if t then t:Play(0.01, 1, 1.45) end
            if UIDodgeCLIENTEFFECTS then
                pcall(function() UIDodgeCLIENTEFFECTS({ ModuleName="UIDodge", Character=ch, dodgenumber=k }) end)
            end
            local md = hum.MoveDirection
            if md.Magnitude < 0.1 then md = -hrp.CFrame.LookVector end
            local v = md*68 + Vector3.new(0,4,0)
            hrp.AssemblyLinearVelocity = Vector3.new(v.X, hrp.AssemblyLinearVelocity.Y, v.Z)
            task.delay(0.25, function() busy = false end)
        end
        local function giveTool()
            local bp = localPlayer2:FindFirstChild("Backpack"); if not bp then return end
            local old = bp:FindFirstChild("Ultra Instinct") or (localPlayer2.Character and localPlayer2.Character:FindFirstChild("Ultra Instinct"))
            if old then pcall(function() old:Destroy() end) end
            local tool = Instance.new("Tool")
            tool.Name = "Ultra Instinct"
            tool.RequiresHandle = false
            tool.CanBeDropped = false
            tool.ToolTip = "Ultra Instinct"
            tool.Equipped:Connect(function()
                if localPlayer2.Character then onEquip(localPlayer2.Character); dash() end
            end)
            tool.Activated:Connect(function() dash() end)
            tool.Parent = bp
            task.spawn(function()
                local pg = localPlayer2:FindFirstChild("PlayerGui")
                pg = pg and pg:FindFirstChild("Hotbar")
                if pg then
                    for _, d in ipairs(pg:GetDescendants()) do
                        if d:IsA("TextButton") then
                            local tn = d:FindFirstChild("ToolName", true)
                            if tn and tn.Text == "Ultra Instinct" then
                                d.MouseButton1Click:Connect(function()
                                    if localPlayer2.Character then onEquip(localPlayer2.Character) end
                                    dash()
                                end)
                            end
                        end
                    end
                end
            end)
        end
        if localPlayer2.Character then
            stripFX(localPlayer2.Character)
            local hum = localPlayer2.Character:FindFirstChildOfClass("Humanoid")
            if hum then loadAnim(hum) end
            onEquip(localPlayer2.Character)
        end
        giveTool()
        refreshCount()
        task.spawn(function()
            local t = 0
            while alive do
                task.wait(0.5); t += 0.5
                if t >= 4.5 then
                    t = 0
                    if value < maxV then value += 1; refreshCount() end
                end
            end
        end)
        local conn = localPlayer2.CharacterAdded:Connect(function(c)
            stripFX(c)
            local hum = c:WaitForChild("Humanoid", 5)
            if hum then loadAnim(hum) end
            task.wait(0.5); onEquip(c); giveTool(); refreshCount()
        end)
        getgenv()._UI_CLEANUP = function()
            alive = false
            pcall(function() conn:Disconnect() end)
            if localPlayer2.Character then stripFX(localPlayer2.Character) end
            local bp = localPlayer2:FindFirstChild("Backpack")
            if bp then
                local t = bp:FindFirstChild("Ultra Instinct"); if t then pcall(function() t:Destroy() end) end
            end
            if localPlayer2.Character then
                local t = localPlayer2.Character:FindFirstChild("Ultra Instinct"); if t then pcall(function() t:Destroy() end) end
            end
            pcall(function() intV:Destroy() end)
        end
    else
        pcall(function()
            if getgenv and getgenv()._UI_CLEANUP then getgenv()._UI_CLEANUP(); getgenv()._UI_CLEANUP = nil end
        end)
    end
end,
})
-- 雷神觉醒
VisualPowerGroup:AddToggle("Visual_LG", {
Text = "雷神觉醒",
Default = false,
Callback = function(on)
    if on then
        pcall(function()
            if getgenv and getgenv()._LightningGodCleaner then pcall(getgenv()._LightningGodCleaner) end
        end)
        local Players2 = game:GetService("Players")
        local localPlayer2 = Players2.LocalPlayer
        local cam = workspace.CurrentCamera
        local active = false
        local anim
        local folder
        local renderConn
        local function stop()
            active = false
            if renderConn then pcall(function() renderConn:Disconnect() end); renderConn = nil end
            if cam then cam.CameraType = Enum.CameraType.Custom; cam.FieldOfView = 70 end
            if anim then pcall(function() anim:Stop(0.2) end); anim = nil end
            if folder then pcall(function() folder:Destroy() end); folder = nil end
            local ch = localPlayer2.Character
            if ch then
                local hrp = ch:FindFirstChild("HumanoidRootPart")
                if hrp then hrp.Anchored = false end
                local hum = ch:FindFirstChild("Humanoid")
                if hum then hum.AutoRotate = true end
                for _, c in ipairs(ch:GetChildren()) do
                    if c.Name == "LightningGodInterrupt" or c.Name:find("LightningGod") or c.Name == "eyes" or c.Name == "LingeringAura" then
                        pcall(function() c:Destroy() end)
                    end
                end
            end
        end
        local function buildCamera(hrp)
            local src = ReplicatedStorage:FindFirstChild("CustomCameraModules")
            src = src and src:FindFirstChild("LightningAwakening")
            if not src then return end
            local data
            pcall(function() data = require(src)() end)
            if not data or not data.Frames or not data.FOV then return end
            local frames = data.Frames; local fov = data.FOV
            local total = #frames
            cam.CameraType = Enum.CameraType.Scriptable
            local i = 1
            if renderConn then renderConn:Disconnect(); renderConn = nil end
            renderConn = RunService.RenderStepped:Connect(function(dt)
                if not active or not hrp or not hrp.Parent then
                    if renderConn then renderConn:Disconnect(); renderConn = nil end
                    cam.CameraType = Enum.CameraType.Custom
                    cam.FieldOfView = 70
                    return
                end
                i += dt*60
                local n2 = math.floor(i)
                if n2 > total then
                    if renderConn then renderConn:Disconnect(); renderConn = nil end
                    cam.CameraType = Enum.CameraType.Custom
                    TweenService:Create(cam, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { FieldOfView = 70 }):Play()
                    return
                end
                local f = frames[n2]; local fv = fov[n2]
                if f then
                    local cf = CFrame.new(f[1],f[2],f[3],f[4],f[5],f[6],f[7],f[8],f[9],f[10],f[11],f[12])
                    cam.CFrame = hrp.CFrame * CFrame.new(0,1.2,0) * cf
                    if fv then cam.FieldOfView = fv end
                end
            end)
        end
        local function cast()
            if active then return end
            local ch = localPlayer2.Character
            if not ch or not ch.Parent then return end
            local hum = ch:FindFirstChild("Humanoid")
            local hrp = ch:FindFirstChild("HumanoidRootPart")
            local an = hum and hum:FindFirstChild("Animator")
            if not (hum and hrp and an and hum.Health > 0) then return end
            stop()
            active = true
            hum.Health = hum.MaxHealth
            hrp.Anchored = true
            hum.AutoRotate = false
            local animSrc = ReplicatedStorage:FindFirstChild("Animations")
            animSrc = animSrc and animSrc:FindFirstChild("Abilities")
            animSrc = animSrc and animSrc:FindFirstChild("LightningGodAwakening")
            if animSrc then
                anim = an:LoadAnimation(animSrc)
                anim.Priority = Enum.AnimationPriority.Action4
                anim:Play(0.1)
            end
            buildCamera(hrp)
            local f = Instance.new("Folder"); f.Name = "LightningGodInterrupt"; f.Parent = ch
            folder = f
            local modSrc = ReplicatedStorage:FindFirstChild("Modules")
            modSrc = modSrc and modSrc:FindFirstChild("AbilityEffectsModules")
            modSrc = modSrc and modSrc:FindFirstChild("LIGHTNINGGODAWAKENINGCLIENTEFFECTS")
            local len = (anim and anim.Length) or 4.3
            if modSrc then
                local m = require(modSrc)
                task.spawn(function()
                    m({ ModuleName = "LIGHTNINGGODAWAKENING", Character = ch, InterruptedFolder = f, TimeLength = len })
                end)
            end
            task.delay(len, function() if active then stop() end end)
        end
        local function giveTool()
            local bp = localPlayer2:FindFirstChild("Backpack"); if not bp then return end
            for _, c in ipairs(bp:GetChildren()) do
                if c.Name == "Awakening" or c.Name == "⚡ Lightning God Awakening" or c.Name == "Lightning God Awakening" then c:Destroy() end
            end
            local ch = localPlayer2.Character
            if ch then
                for _, c in ipairs(ch:GetChildren()) do
                    if c:IsA("Tool") and (c.Name == "Awakening" or c.Name == "⚡ Lightning God Awakening" or c.Name == "Lightning God Awakening") then
                        c:Destroy()
                    end
                end
            end
            local tool = Instance.new("Tool")
            tool.Name = "Awakening"
            tool.RequiresHandle = false
            tool.CanBeDropped = false
            tool.Equipped:Connect(cast)
            tool.Activated:Connect(cast)
            tool.Parent = bp
        end
        local inputConn = UserInputService.InputBegan:Connect(function(input, gp)
            if gp then return end
            if input.KeyCode == Enum.KeyCode.G then cast() end
        end)
        local charConn = localPlayer2.CharacterAdded:Connect(function()
            task.wait(0.5); stop(); giveTool()
        end)
        local pg = localPlayer2:FindFirstChild("PlayerGui")
        if pg then
            for _, n2 in ipairs({ "LightningAwakeningGui","LightningGodGui","SoundDumpGui","CodeDumpGui","DeepSoundDumpGui" }) do
                local x = pg:FindFirstChild(n2); if x then x:Destroy() end
            end
        end
        if localPlayer2.Character then giveTool() end
        getgenv()._LightningGodCleaner = function()
            pcall(stop)
            pcall(function() inputConn:Disconnect() end)
            pcall(function() charConn:Disconnect() end)
            pcall(function()
                local bp = localPlayer2:FindFirstChild("Backpack")
                if bp then
                    for _, c in ipairs(bp:GetChildren()) do
                        if c.Name == "Awakening" or c.Name == "⚡ Lightning God Awakening" or c.Name == "Lightning God Awakening" then c:Destroy() end
                    end
                end
            end)
            pcall(function()
                local pg2 = localPlayer2:FindFirstChild("PlayerGui")
                if pg2 then
                    for _, n2 in ipairs({ "LightningAwakeningGui","LightningGodGui","SoundDumpGui","CodeDumpGui","DeepSoundDumpGui" }) do
                        local x = pg2:FindFirstChild(n2); if x then x:Destroy() end
                    end
                end
            end)
        end
    else
        pcall(function()
            if getgenv and getgenv()._LightningGodCleaner then pcall(getgenv()._LightningGodCleaner); getgenv()._LightningGodCleaner = nil end
        end)
    end
end,
})
VisualPowerGroup:AddDivider()
--快银
do
local Players           = game:GetService("Players")
local Workspace         = game:GetService("Workspace")
local RunService        = game:GetService("RunService")
local localPlayer       = Players.LocalPlayer
local localPlayer2      = localPlayer
local function PlayToggleSound() end
local function PlayErrorSound() end
local function PlayBell() end
local function notify(title, text, duration)
    Library:Notify({
        Title = tostring(title),
        Description = tostring(text or ""),
        Time = tonumber(duration) or 0.9,
    })
end
local function fn61(fn, ...)
    if type(fn) ~= "function" then return end
    local args = table.pack(...)
    task.spawn(function()
        pcall(fn, table.unpack(args, 1, args.n))
    end)
end    
do
    local enabled = false
    local folder  = nil

    local function getLiveModel()
        local live = Workspace:FindFirstChild("Live")
            or Workspace:WaitForChild("Live", 5)
        if not live then return nil end
        return live:FindFirstChild(localPlayer2.Name)
            or live:WaitForChild(localPlayer2.Name, 5)
    end
    VisualPowerGroup:AddToggle("Quicksilver", {
        Text = "伪装快银",
        Tooltip = "给 workspace.Live.<玩家名> 添加 IsWallyWest 文件夹，让客户端误认为你拥有快银能力",
        Default = false,
        Callback = function(Value)
            enabled = Value and true or false

            if enabled then
                local success = pcall(function()
                    local model = getLiveModel()
                    if not model then
                        error("Live.<PlayerName> not found")
                    end

                    local old = model:FindFirstChild("IsWallyWest")
                    if old then old:Destroy() end

                    local f = Instance.new("Folder")
                    f.Name = "IsWallyWest"
                    f.Parent = model
                    folder = f
                end)

                if success then
                    notify("快银", "伪装已开启", 0.9)
                else
                    notify("快银", "开启失败（找不到 Live 或玩家模型）", 1.2)
                    PlayErrorSound()
                end
            else
                pcall(function()
                    if folder and folder.Parent then
                        folder:Destroy()
                    end
                    folder = nil

                    local model = Workspace:FindFirstChild("Live")
                    model = model and model:FindFirstChild(localPlayer2.Name)
                    if model then
                        local old = model:FindFirstChild("IsWallyWest")
                        if old then old:Destroy() end
                    end
                end)
                notify("快银", "伪装已关闭", 0.9)
            end

            PlayToggleSound()
            return true
        end,
    })
    VisualPowerGroup:AddButton({
        Text = "添加伪装",
        Tooltip = "强制给 Live.<玩家名> 挂 IsWallyWest 文件夹",
        Func = function()
            fn61(function()
                local model = getLiveModel()
                if not model then
                    notify("快银", "找不到 Live." .. localPlayer2.Name, 0.9)
                    PlayErrorSound()
                    return
                end
                local old = model:FindFirstChild("IsWallyWest")
                if old then old:Destroy() end

                local f = Instance.new("Folder")
                f.Name = "IsWallyWest"
                f.Parent = model
                folder = f

                notify("快银", "已添加 IsWallyWest", 0.9)
            end)
        end,
    })
    VisualPowerGroup:AddButton({
        Text = "移除伪装",
        Tooltip = "移除 Live.<玩家名> 上的 IsWallyWest 文件夹",
        Func = function()
            fn61(function()
                local count = 0
                if folder and folder.Parent then
                    folder:Destroy()
                    count += 1
                end
                folder = nil
                local model = Workspace:FindFirstChild("Live")
                model = model and model:FindFirstChild(localPlayer2.Name)
                if model then
                    local old = model:FindFirstChild("IsWallyWest")
                    if old then
                        old:Destroy()
                        count += 1
                    end
                end
                notify("快银", "已移除 " .. count .. " 个 IsWallyWest", 1)
            end)
        end,
    })
    VisualPowerGroup:AddButton({
        Text = "检查伪装状态",
        Tooltip = "检查 Live.<玩家名> 上是否存在 IsWallyWest 文件夹",
        Func = function()
            fn61(function()
                local live = Workspace:FindFirstChild("Live")
                if not live then
                    notify("快银", "workspace.Live 不存在", 0.9)
                    return
                end
                local model = live:FindFirstChild(localPlayer2.Name)
                if not model then
                    notify("快银", "找不到 Live." .. localPlayer2.Name, 0.9)
                    return
                end
                local isWallyWest = model:FindFirstChild("IsWallyWest")
                if isWallyWest then
                    notify("快银", "IsWallyWest 存在，伪装生效中", 1.2)
                else
                    notify("快银", "IsWallyWest 不存在，伪装未生效", 1.2)
                end
            end)
        end,
    })
end
end
-- 通行证开关
local gamepassDefs = {
    { key = "VisualVIP",       text = "解锁VIP",             attr = "__OwnsVIPGamepass" },
    { key = "VisualLighter",   text = "解锁打火机",           attr = "HasLighter" },
    { key = "Visual2X",        text = "解锁2倍票数",          attr = "__Owns2XVoteGamepass" },
    { key = "VisualGuard",     text = "解锁永久守卫",         attr = "__OwnsPermGuard" },
    { key = "VisualGlass",     text = "解锁玻璃视觉",         attr = "__OwnsGlassManufacturerVision" },
    { key = "VisualPSPlus",    text = "解锁PS Plus",          attr = "__OwnsPSPlus" },
    { key = "VisualEmotes",    text = "解锁表情页面",         attr = "__OwnsEmotePages" },
}
for _, def in ipairs(gamepassDefs) do
local conn
VisualGamepassGroup:AddToggle(def.key, {
    Text = def.text,
    Default = false,
    Callback = function(on)
        if on then
            localPlayer:SetAttribute(def.attr, true)
            conn = localPlayer:GetAttributeChangedSignal(def.attr):Connect(function()
                if not localPlayer:GetAttribute(def.attr) then
                    localPlayer:SetAttribute(def.attr, true)
                end
            end)
        else
            if conn then conn:Disconnect(); conn = nil end
            localPlayer:SetAttribute(def.attr, nil)
        end
    end,
})
end
VisualGamepassGroup:AddInput("SprintInput", {
Default = "0",
Numeric = true,
Finished = true,
MaxLength = 1,
Text = "速度等级",
Placeholder = "0-4",
Callback = function(value)
    local num = tonumber(value)
    if not num then return end
    num = math.clamp(num, 0, 4)
    pcall(function()
        local player = game:GetService("Players").LocalPlayer
        local boosts = player:FindFirstChild("Boosts")
        if boosts then
            local sprint = boosts:FindFirstChild("Faster Sprint")
            if sprint then
                sprint.Value = num
            end
        end
    end)
end
})
VisualGamepassGroup:AddInput("DamageInput", {
Default = "0",
Numeric = true,
Finished = true,
MaxLength = 1,
Text = "力量等级",
Placeholder = "0-6",
Callback = function(value)
    local num = tonumber(value)
    if not num then return end
    num = math.clamp(num, 0, 6)
    pcall(function()
        local player = game:GetService("Players").LocalPlayer
        local boosts = player:FindFirstChild("Boosts")
        if boosts then
            local damage = boosts:FindFirstChild("Damage Boost")
            if damage then
                damage.Value = num
            end
        end
    end)
end
})
VisualGamepassGroup:AddInput("WonInput", {
Default = "0",
Numeric = true,
Finished = true,
MaxLength = 1,
Text = "金钱等级",
Placeholder = "0-6",
Callback = function(value)
    local num = tonumber(value)
    if not num then return end
    num = math.clamp(num, 0, 6)
    pcall(function()
        local player = game:GetService("Players").LocalPlayer
        local boosts = player:FindFirstChild("Boosts")
        if boosts then
            local won = boosts:FindFirstChild("Won Boost")
            if won then
                won.Value = num
            end
        end
    end)
end
})
VisualGamepassGroup:AddInput('WalkSpeedInput', {
Default = '16',
Numeric = true,
Finished = true,
Text = '移动速度',
Placeholder = '输入速度',
Callback = function(value)
    local speed = tonumber(value)
    if not speed or speed <= 0 then return end
    pcall(function()
        local Players = game:GetService("Players")
        local lplr = Players.LocalPlayer
        local function setSpeed()
            local char = lplr.Character
            if not char then return end
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then
                hum.WalkSpeed = speed
            end
        end
        setSpeed()
        lplr.CharacterAdded:Connect(setSpeed)
    end)
end
})
-- 客户端选项
_G.UniformColorValue = Color3.fromRGB(255,255,255)
VisualClientGroup:AddToggle("Visual_UniformSkin", {
Text = "设置统一皮肤",
Default = false,
Callback = function(on)
    _G.SetUniformSkinEnabled = on
    localPlayer:SetAttribute("ClothingColorToggle", on)
    if on and _G.UniformColorValue then localPlayer:SetAttribute("ClothingColor", _G.UniformColorValue) end
end,
})
VisualClientGroup:AddLabel('统一皮肤颜色'):AddColorPicker('Visual_UniformColor', {
Default = Color3.fromRGB(255,255,255),
Title = "统一皮肤颜色",
Callback = function(c)
    _G.UniformColorValue = c
    if _G.SetUniformSkinEnabled then localPlayer:SetAttribute("ClothingColor", _G.UniformColorValue) end
end,
})

_G.CustomPlayerNumber = 456
_G.CustomPlayerNumberEnabled = false
VisualClientGroup:AddInput("Visual_CustomNumberVal", {
Default = "456", Numeric = true, Finished = false, Text = "自定义玩家编号",
Placeholder = "456",
Callback = function(v) _G.CustomPlayerNumber = tonumber(v) or 456 end,
})
VisualClientGroup:AddToggle("Visual_CustomNumber", {
Text = "启用自定义编号",
Default = false,
Callback = function(on)
    _G.CustomPlayerNumberEnabled = on
    if on then
        task.spawn(function()
            while _G.CustomPlayerNumberEnabled do
                local tagV = localPlayer:FindFirstChild("PlayerTagValue")
                local v = _G.CustomPlayerNumber or 456
                local text = tostring(v)
                if #text < 3 then text = string.rep("0", 3-#text) .. text end
                if tagV and tagV.Value ~= v then tagV.Value = v end
                local ch = localPlayer.Character
                if ch then
                    for _, d in ipairs(ch:GetDescendants()) do
                        if d:IsA("TextLabel") and d.Parent:IsA("SurfaceGui") then d.Text = text end
                    end
                end
                task.wait(0.5)
            end
        end)
    end
end,
})

_G.CustomWinsValue = 100
_G.CustomWinsEnabled = false
VisualClientGroup:AddInput("Visual_CustomWinsVal", {
Default = "100", Numeric = true, Finished = false, Text = "自定义胜场",
Callback = function(v) _G.CustomWinsValue = tonumber(v) or 100 end,
})
VisualClientGroup:AddToggle("Visual_CustomWins", {
Text = "启用自定义胜场",
Default = false,
Callback = function(on)
    _G.CustomWinsEnabled = on
    if on then
        task.spawn(function()
            while _G.CustomWinsEnabled do
                if localPlayer:GetAttribute("_GameWins") ~= _G.CustomWinsValue then
                    localPlayer:SetAttribute("_GameWins", _G.CustomWinsValue)
                end
                task.wait(0.5)
            end
        end)
    end
end,
})

_G.CustomWinStreakValue = 10
_G.CustomWinStreakEnabled = false
VisualClientGroup:AddInput("Visual_CustomStreakVal", {
Default = "10", Numeric = true, Finished = false, Text = "自定义连胜",
Callback = function(v) _G.CustomWinStreakValue = tonumber(v) or 10 end,
})
VisualClientGroup:AddToggle("Visual_CustomStreak", {
Text = "启用自定义连胜",
Default = false,
Callback = function(on)
    _G.CustomWinStreakEnabled = on
    if on then
        task.spawn(function()
            while _G.CustomWinStreakEnabled do
                if localPlayer:GetAttribute("_ConsecutiveWins") ~= _G.CustomWinStreakValue then
                    localPlayer:SetAttribute("_ConsecutiveWins", _G.CustomWinStreakValue)
                end
                task.wait(0.5)
            end
        end)
    end
end,
})
--玩家功能

-- 表情播放器
do
local emotes = {
    { Name="Dream Journal", AnimId="rbxassetid://117325441970867", SoundId="rbxassetid://88476306353688", Volume=10 },
    { Name="Otsukare Summer", AnimId="rbxassetid://134888005420629", SoundId="rbxassetid://127332409398776", Volume=3 },
    { Name="Spite", AnimId="rbxassetid://100382123964355", SoundId="rbxassetid://90513005423910", Volume=5 },
    { Name="Posing Time", AnimId="rbxassetid://89240795237958", SoundId="rbxassetid://113259086406604", Volume=5 },
    { Name="Shuffle", AnimId="rbxassetid://113121578988536", SoundId="rbxassetid://127426881747595", Volume=5 },
    { Name="Yare Yare", AnimId="rbxassetid://86642655479570", SoundId="rbxassetid://128193072645447", Volume=5 },
    { Name="My Perfect Victory", AnimId="rbxassetid://110501561372722", SoundId="rbxassetid://104280886491008", Volume=5 },
    { Name="Fate Of Both Worlds", AnimId="rbxassetid://114244682550258", SoundId="rbxassetid://103081000050688", Volume=5 },
    { Name="Peanut of Butter House", AnimId="rbxassetid://108074529570331", SoundId="rbxassetid://95893903149232", Volume=5 },
    { Name="Cat Hands", AnimId="rbxassetid://87331103640233", SoundId="rbxassetid://126527049854337", Volume=5 },
    { Name="The System", AnimId="rbxassetid://117978762262770", SoundId="rbxassetid://73318799732606", Volume=5 },
    { Name="Gear 5", AnimId="rbxassetid://107815350238463", SoundId=nil, Volume=5 },
    { Name="Mingle Dance", AnimId="rbxassetid://99559083669885", SoundId="rbxassetid://89379201770587", Volume=5 },
    { Name="Metro Dance", AnimId="rbxassetid://104701586795462", SoundId="rbxassetid://95730226592096", Volume=5 },
    { Name="Funeral for the living", AnimId="rbxassetid://123297701965318", SoundId="rbxassetid://105930820096344", Volume=5 },
    { Name="Cartwheel", AnimId="rbxassetid://131418698864660", SoundId="rbxassetid://18911882091", Volume=5 },
    { Name="Lively Walk", AnimId="rbxassetid://99556634315867", SoundId="rbxassetid://16706317921", Volume=5 },
    { Name="Dance of nights", AnimId="rbxassetid://100183800468181", SoundId="rbxassetid://133365635431929", Volume=5 },
    { Name="Sonic run", AnimId="rbxassetid://120151271879240", SoundId="rbxassetid://131594734029433", Volume=5 },
    { Name="Khabilame", AnimId="rbxassetid://133158883386630", SoundId="rbxassetid://131852145461258", Volume=5 },
    { Name="Mii swing", AnimId="rbxassetid://111293910946685", SoundId="rbxassetid://121596432073446", Volume=5 },
    { Name="Jackpot", AnimId="rbxassetid://90063856357375", SoundId="rbxassetid://96528255406149", Volume=5 },
    { Name="Scuba", AnimId="rbxassetid://125809050313880", SoundId="rbxassetid://78439444151879", Volume=5 },
    { Name="Crying", AnimId="rbxassetid://96313533433486", SoundId="rbxassetid://18151791880", Volume=5 },
    { Name="Ogame", AnimId="rbxassetid://117778295104747", SoundId="rbxassetid://122457089809687", Volume=5 },
    { Name="Blue Shirt Kid", AnimId="rbxassetid://83396620848313", SoundId="rbxassetid://115875415839739", Volume=5 },
    { Name="Zepelli", AnimId="rbxassetid://135418027114658", SoundId=nil, Volume=5 },
    { Name="Woke Up The World", AnimId="rbxassetid://130106286443990", SoundId="rbxassetid://0275579621574", Volume=5 },
    { Name="Mask", AnimId="rbxassetid://102176887169297", SoundId="rbxassetid://97952595881264", Volume=5 },
}
local curAnim, curSound
local playing = false
local selName = emotes[1].Name
local function stopEmote()
    if curAnim then pcall(function() curAnim:Stop() end); curAnim = nil end
    if curSound then pcall(function() curSound:Stop() end); pcall(function() curSound:Destroy() end); curSound = nil end
    playing = false
end
local function playEmote(def)
    stopEmote()
    local ch = localPlayer.Character; if not ch then return end
    local hum = ch:FindFirstChildOfClass("Humanoid"); if not hum then return end
    local a = Instance.new("Animation"); a.AnimationId = def.AnimId
    curAnim = hum:LoadAnimation(a); curAnim:Play()
    if def.SoundId then
        local s = Instance.new("Sound")
        s.SoundId = def.SoundId; s.Volume = def.Volume or 5
        s.Looped = true; s.Parent = SoundService; s:Play()
        curSound = s
    end
    playing = true
    fn13("表情", "正在播放：" .. def.Name)
end
local names = {}
for _, e in ipairs(emotes) do table.insert(names, e.Name) end
VisualEmoteGroup:AddDropdown("Visual_EmoteList", {
    Values = names, Default = names[1], Multi = false, Text = "选择表情",
    Callback = function(v) selName = v end,
})
btn(VisualEmoteGroup, "播放表情", function()
    for _, e in ipairs(emotes) do if e.Name == selName then playEmote(e); break end end
end)
btn(VisualEmoteGroup, "停止表情", function() stopEmote(); fn13("表情", "已停止表情") end)
task.spawn(function()
    while task.wait(0.5) do
        if playing then
            local ch = localPlayer.Character
            if ch then
                local hum = ch:FindFirstChildOfClass("Humanoid")
                if hum and hum.MoveDirection.Magnitude > 0 then stopEmote() end
            end
        end
    end
end)
end

-- 挑衅表情
do
local sel = "挑衅表情 1"
local track
local active = false
local function stop()
    if track then pcall(function() track:Stop(0.15); track:Destroy() end); track = nil end
    active = false
end
local function play(name)
    stop()
    local ch = localPlayer.Character; if not ch then return end
    local hum = ch:FindFirstChildOfClass("Humanoid"); if not hum or hum.Health <= 0 then return end
    local an = hum:FindFirstChildOfClass("Animator"); if not an then return end
    local id
    if name == "挑衅表情 1" then id = "rbxassetid://83396620848313"
    elseif name == "挑衅表情 2" then id = "rbxassetid://111293910946685"
    elseif name == "挑衅表情 3" then id = "rbxassetid://129390844140095"
    elseif name == "挑衅表情 4" then id = "rbxassetid://72042024" end
    if id then
        local a = Instance.new("Animation"); a.AnimationId = id
        pcall(function()
            track = an:LoadAnimation(a)
            track.Priority = Enum.AnimationPriority.Action4
            track.Looped = true
            track:Play(0.15)
            active = true
        end)
    end
end
VisualRageGroup:AddDropdown("Visual_RageList", {
    Values = { "挑衅表情 1", "挑衅表情 2", "挑衅表情 3", "挑衅表情 4" },
    Default = "挑衅表情 1",
    Multi = false,
    Text = "选择挑衅表情",
    Callback = function(v) sel = v; if active then play(sel) end end,
})
btn(VisualRageGroup, "开始 / 停止", function()
    if active then stop(); fn13("挑衅", "表情已停止")
    else play(sel); fn13("挑衅", "正在播放 " .. tostring(sel)) end
end)
localPlayer.CharacterAdded:Connect(stop)
end
do
local Players           = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace         = game:GetService("Workspace")
local RunService        = game:GetService("RunService")
local localPlayer       = Players.LocalPlayer
local localPlayer2      = localPlayer
local RunService2       = RunService

local function PlayToggleSound() end
local function PlayErrorSound() end
local function PlayBell() end

local function notify(title, text, duration)
    Library:Notify({
        Title = tostring(title),
        Description = tostring(text or ""),
        Time = tonumber(duration) or 0.9,
    })
end

local function fn61(fn, ...)
    if type(fn) ~= "function" then return end
    local args = table.pack(...)
    task.spawn(function()
        pcall(fn, table.unpack(args, 1, args.n))
    end)
end

if not firesignal then
    function firesignal(signal)
        if not getconnections then return end
        for _, c in ipairs(getconnections(signal)) do
            pcall(function() c:Fire() end)
        end
    end
end

local function is_game_active(gameName)
    local values = Workspace:FindFirstChild("Values")
    if not values then return false end
    local currentGame = values:FindFirstChild("CurrentGame")
    return currentGame and currentGame.Value == gameName
end

local function is_xeno_executor()
    if identifyexecutor and type(identifyexecutor) == "function" then
        local str = identifyexecutor():lower()
        if str:find("xeno") then return true end
    end
    return false
end

local function findCircleBase()
    local playerGui = localPlayer:FindFirstChild("PlayerGui")
    if not playerGui then return nil end

    local ui = playerGui:FindFirstChild("TugOfWarUIV2")
        or playerGui:FindFirstChild("TugOfWarUI")
        or playerGui:FindFirstChild("TugofWarRemake")
    if not ui then return nil end

    ui = ui:FindFirstChild("TugofWarRemake") or ui
    ui = ui and ui:FindFirstChild("CircleBase")
    if ui and ui.Visible then return ui end
    return nil
end

local HBGQTE = nil
pcall(function()
    HBGQTE = require(ReplicatedStorage:WaitForChild("Modules", 5):WaitForChild("HBGQTE", 5))
end)
do
    local autoEnabled = false
    local autoMode    = "Legit"
    local autoConn    = nil

    local rageEnabled = false
    local rageLoop    = nil

    local function startAuto(on)
        autoEnabled = on
        if autoConn then autoConn:Disconnect(); autoConn = nil end
        if not on then return end

        local impactFrames = localPlayer.PlayerGui:FindFirstChild("ImpactFrames")
        if not impactFrames then return end

        local seen = {}
        autoConn = impactFrames.ChildAdded:Connect(function(child)
            if child.Name ~= "OuterRingTemplate" or seen[child] then return end
            seen[child] = true

            task.defer(function()
                local inner = nil
                for _, c2 in pairs(impactFrames:GetChildren()) do
                    if c2.Name == "InnerTemplate"
                        and c2.Position == child.Position
                        and not c2:GetAttribute("Failed") then
                        inner = c2
                        break
                    end
                end
                if not inner or inner:GetAttribute("Tweening") or inner:GetAttribute("Failed") then
                    return
                end

                local module = require(ReplicatedStorage.Modules.HBGQTE)
                if autoMode == "Legit" then
                    pcall(function()
                        module.Pressed(false, {
                            Inner = inner,
                            Outer = child,
                            Duration = 2,
                            StartedAt = tick(),
                            Data = {},
                        })
                    end)
                else
                    pcall(function()
                        module.Pressed(true, {
                            Inner = inner,
                            Outer = child,
                            Duration = 0.1,
                            StartedAt = tick(),
                            Data = {},
                        })
                    end)
                end
            end)
        end)
    end

    local function startRage(on)
        rageEnabled = on
        if rageLoop then
            task.cancel(rageLoop)
            rageLoop = nil
        end
        if not on then return end

        rageLoop = task.spawn(function()
            local ok, result = pcall(function()
                return require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("HBGQTE"))
            end)
            if not ok then
                notify("RAGE Auto QTE", "Failed to load QTE module", 0.9)
                PlayErrorSound()
                rageEnabled = false
                if Options.RageAutoQTE then
                    pcall(function() Options.RageAutoQTE:SetValue(false) end)
                end
                return
            end
            local v = result
            while rageEnabled do
                task.wait(0.05)
                pcall(function()
                    if v and v.ActiveButtons then
                        for _, ab in pairs(v.ActiveButtons) do
                            if ab and ab.Inner and ab.Outer
                                and not ab.Inner:GetAttribute("Tweening")
                                and not ab.Inner:GetAttribute("Failed") then
                                pcall(function()
                                    v.Pressed(false, ab)
                                end)
                            end
                        end
                    end
                end)
            end
        end)
    end
    LeftGB:AddToggle("LegitAutoQTE", {
        Text = "正常QTE",
        Tooltip = "以正常节奏完成 QTE（Duration = 2s）",
        Default = false,
        Callback = function(Value)
            if Value and is_xeno_executor() then
                notify("Auto QTE", "Not supported in your executor", 0.9)
                PlayErrorSound()
                if Options.AutoQTE then
                    pcall(function() Options.AutoQTE:SetValue(false) end)
                end
                return false
            end
            autoMode = "Legit"
            startAuto(Value)
            PlayToggleSound()
            return true
        end,
    })
    LeftGB:AddToggle("RageAutoQTE", {
        Text = "狂暴QTE",
        Tooltip = "每 0.05s 遍历 ActiveButtons 强压（Duration = 0.1s）",
        Default = false,
        Callback = function(Value)
            if Value and is_xeno_executor() then
                notify("RAGE Auto QTE", "Not supported in your executor", 0.9)
                PlayErrorSound()
                if Options.RageAutoQTE then
                    pcall(function() Options.RageAutoQTE:SetValue(false) end)
                end
                return false
            end
            startRage(Value)
            PlayToggleSound()
            return true
        end,
    })
    LeftGB:AddDropdown("AutoQTEMode", {
        Values = { "正常", "狂暴" },
        Default = "正常",
        Text = " QTE 模式",
        Tooltip = "Legit = 正常节奏；Rage = 快速强压",
        Callback = function(Value)
            autoMode = Value
        end,
    })
end
LeftGB:AddDivider()
do
    local enabled = false
    local conn    = nil
    LeftGB:AddToggle("AutoChoke", {
        Text = "自动QTE掐脖子",
        Tooltip = "自动完成 Mingle 掐脖子 QTE，需在 Mingle 中",
        Default = false,
        Callback = function(Value)
            if Value then
                if not is_game_active("Mingle") then
                    notify("Auto Choke", "Wait for Mingle!", 0.9)
                    PlayErrorSound()
                    if Options.AutoChoke then
                        pcall(function() Options.AutoChoke:SetValue(false) end)
                    end
                    return false
                end
            end
            enabled = Value and true or false
            if conn then conn:Disconnect(); conn = nil end
            if not enabled then
                PlayToggleSound()
                return true
            end
            local impactFrames = localPlayer.PlayerGui:FindFirstChild("ImpactFrames")
            if not impactFrames then
                PlayToggleSound()
                return true
            end
            local seen = {}
            conn = impactFrames.ChildAdded:Connect(function(child)
                if child.Name ~= "OuterRingTemplate" or seen[child] then return end
                seen[child] = true
                task.defer(function()
                    local inner = nil
                    for _, c2 in pairs(impactFrames:GetChildren()) do
                        if c2.Name == "InnerTemplate"
                            and c2.Position == child.Position
                            and not c2:GetAttribute("Failed") then
                            inner = c2
                            break
                        end
                    end
                    if not inner or inner:GetAttribute("Tweening") or inner:GetAttribute("Failed") then
                        return
                    end
                    local module = require(ReplicatedStorage.Modules.HBGQTE)
                    pcall(function()
                        module.Pressed(false, {
                            Inner = inner,
                            Outer = child,
                            Duration = 2,
                            StartedAt = tick(),
                            Data = {},
                        })
                    end)
                end)
            end)
            PlayToggleSound()
            return true
        end,
    })
end
LeftGB:AddDivider()
do
    local flag   = false
    local thread = nil
    local letters = "WASD"
    local speed   = 0.5
    local function stop()
        flag = false
        if thread then
            task.cancel(thread)
            thread = nil
        end
    end
    local function start()
        stop()
        local list = {}
        for i = 1, #tostring(letters) do
            local ch = tostring(letters):sub(i, i):upper()
            if ch:match("[A-Z]") then
                list[#list + 1] = ch
            end
        end
        if #list == 0 then
            notify("QTE Buttons", "No valid letters entered", 0.9)
            return
        end
        local module = HBGQTE
        if not module then
            pcall(function()
                local modules = ReplicatedStorage:FindFirstChild("Modules")
                if modules then
                    local hbgqte = modules:FindFirstChild("HBGQTE")
                    if hbgqte then module = require(hbgqte) end
                end
            end)
            HBGQTE = module
        end
        if not module or type(module.SetUpButton) ~= "function" then
            notify("QTE Buttons", "HBGQTE not available right now", 0.9)
            return
        end
        flag = true
        thread = task.spawn(function()
            local idx = 1
            while flag do
                local ch = list[idx]
                if not pcall(function()
                    module.SetUpButton(3, ch, false, nil)
                end) then
                    flag = false
                    break
                else
                    idx = idx % #list + 1
                    task.wait(speed)
                end
            end
            thread = nil
        end)
    end
    LeftGB:AddToggle("QTEButtons", {
        Text = "QTE 按钮生成器（练习）",
        Tooltip = "生成虚拟 QTE 按钮用于练习，字符见右侧设置",
        Default = false,
        Callback = function(Value)
            if Value then start() else stop() end
            PlayToggleSound()
        end,
    })
    LeftGB:AddInput("QTELettersInput", {
        Default = "WASD",
        Numeric = false,
        Finished = false,
        ClearTextOnFocus = false,
        Text = "QTE 字符",
        Tooltip = "用于按钮生成器的字符，例如 WASD",
        Placeholder = "WASD",
        Callback = function(Value)
            letters = Value
        end,
    })
    LeftGB:AddSlider("QTESpawnSpeed", {
        Text = "生成间隔（秒）",
        Tooltip = "两个按钮之间的等待时间",
        Default = 5,
        Min = 1,
        Max = 20,
        Rounding = 0,
        Compact = false,
        FormatDisplayValue = function(slider, value)
            return string.format("%.1fs", value / 10)
        end,
        Callback = function(Value)
            speed = Value / 10
        end,
    })
end
do
    local enabled = false
    local conn    = nil
    RightGB:AddToggle("AntiMissQTE", {
        Text = "防失误",
        Tooltip = "每帧强制 Medium = Arrow，永不失误",
        Default = false,
        Callback = function(Value)
            enabled = Value and true or false
            if conn then conn:Disconnect(); conn = nil end
            if enabled then
                conn = RunService.RenderStepped:Connect(function()
                    if not enabled then return end
                    if localPlayer:GetAttribute("TugOfWarPhase") ~= "QTE" then return end
                    local v = findCircleBase()
                    if not v then return end
                    local arrow  = v:FindFirstChild("Arrow")
                    local medium = v:FindFirstChild("Medium")
                    if not arrow or not medium then return end
                    medium.Rotation = arrow.Rotation
                end)
            end
            PlayToggleSound()
        end,
    })
end
do
    local enabled     = false
    local connection  = nil
    local wasInZone   = false
    local zoneEnter   = 0
    local pressDelay  = 0.02
    local function findDeepCircleBase()
        local playerGui = localPlayer:FindFirstChild("PlayerGui")
        if not playerGui then return nil end
        local walk
        walk = function(parent, depth)
            if depth > 8 then return nil end
            local cb = parent:FindFirstChild("CircleBase")
            if cb then return cb end
            for _, child in ipairs(parent:GetChildren()) do
                if child:IsA("ScreenGui")
                    or child:IsA("Frame")
                    or child:IsA("ImageLabel") then
                    local r = walk(child, depth + 1)
                    if r then return r end
                end
            end
            return nil
        end
        local v = walk(playerGui, 0)
        if not v then return nil end
        local arrow  = v:FindFirstChild("Arrow")
        local medium = v:FindFirstChild("Medium")
        if not arrow or not medium then return nil end
        return {
            circleBase = v,
            arrow = arrow,
            medium = medium,
            btn = v:FindFirstChild("TextButton")
                or v:FindFirstChildWhichIsA("TextButton")
                or (v.Parent and v.Parent:FindFirstChild("TextButton")),
        }
    end
    local function clickBtn(btn)
        if not btn then return end
        pcall(function()
            if firesignal then
                firesignal(btn.MouseButton1Click)
            end
            collectgarbage()
        end)
    end
    local function angleLimit()
        local strategy = localPlayer:GetAttribute("TugOfWarStrategy") or "Standard"
        return strategy == "Stall" and 20 or 26
    end
    local function step()
        if not enabled then return end
        local v = findDeepCircleBase()
        if not v then return end
        if not v.circleBase.Visible then
            wasInZone = false
            zoneEnter = 0
            return
        end
        local now = tick()
        local inZone = math.abs((v.medium.Rotation - v.arrow.Rotation + 180) % 360 - 180)
            <= angleLimit()
        if inZone and not wasInZone then
            wasInZone = true
            zoneEnter = now
        end
        if not inZone and wasInZone then
            wasInZone = false
            zoneEnter = 0
        end
        if wasInZone and (pressDelay <= now - zoneEnter) then
            clickBtn(v.btn)
            wasInZone = false
            zoneEnter = 0
        end
    end
    RightGB:AddToggle("AutoPullQTE", {
        Text = "自动拔河",
        Tooltip = "进入判定区后延迟 0.02s 自动点击",
        Default = false,
        Callback = function(Value)
            enabled = Value and true or false
            wasInZone = false
            zoneEnter = 0
            if connection then
                connection:Disconnect()
                connection = nil
            end
            if enabled then
                connection = RunService.Heartbeat:Connect(function()
                    task.wait(0.016)
                    step()
                end)
            end
            PlayToggleSound()
        end,
    })
end
do
    local enabled    = false
    local pullConn   = nil
    local missConn   = nil
    RightGB:AddToggle("UltraFastPullQTE", {
        Text = "狂暴拔河QTE",
        Tooltip = "每帧同步 + 高频点击，6-7 秒获胜（明显）",
        Default = false,
        Callback = function(Value)
            enabled = Value and true or false
            if pullConn then pullConn:Disconnect(); pullConn = nil end
            if missConn then missConn:Disconnect(); missConn = nil end

            if not enabled then
                PlayToggleSound()
                return
            end
            missConn = RunService.RenderStepped:Connect(function()
                if not enabled then return end
                if localPlayer:GetAttribute("TugOfWarPhase") ~= "QTE" then return end
                local v = findCircleBase()
                if not v then return end
                local arrow  = v:FindFirstChild("Arrow")
                local medium = v:FindFirstChild("Medium")
                if not arrow or not medium then return end

                medium.Rotation = arrow.Rotation
            end)
            pullConn = RunService.Heartbeat:Connect(function()
                if not enabled then return end
                if localPlayer:GetAttribute("TugOfWarPhase") ~= "QTE" then return end
                local v = findCircleBase()
                if not v or not v.Visible then return end
                local arrow      = v:FindFirstChild("Arrow")
                local medium     = v:FindFirstChild("Medium")
                local textButton = v:FindFirstChild("TextButton")
                if not arrow or not medium or not textButton then return end
                if math.abs((medium.Rotation - arrow.Rotation + 180) % 360 - 180) <= 26 then
                    pcall(function()
                        task.wait(0.016)
                        firesignal(textButton.MouseButton1Click)
                    end)
                end
            end)

            PlayToggleSound()
        end,
    })
end
RightGB:AddDivider()
do
    local enabled = false
    local conn    = nil
    local ui      = nil
    local function findOrClone()
        local playerGui = localPlayer:FindFirstChild("PlayerGui")
        if not playerGui then return nil end
        local found = playerGui:FindFirstChild("TugOfWarUIV2")
            or playerGui:FindFirstChild("TugOfWarUI")
            or playerGui:FindFirstChild("TugofWarRemake")
        if found then return found end
        local resUI = ReplicatedStorage:FindFirstChild("UI")
        if resUI then
            local t = resUI:FindFirstChild("TugOfWarUIV2")
                or resUI:FindFirstChild("TugOfWarUI")
            if t then
                local clone = t:Clone()
                clone.Parent = playerGui
                return clone
            end
        end
        return nil
    end
    RightGB:AddToggle("TugOfWarQTE", {
        Text = "拔河QTE练习",
        Tooltip = "强制设置为 QTE 阶段，用于练习或测试",
        Default = false,
        Callback = function(Value)
            enabled = Value and true or false
            if conn then conn:Disconnect(); conn = nil end
            if ui then ui:Destroy(); ui = nil end
            if enabled then
                localPlayer:SetAttribute("TugOfWarPhase", "QTE")
                workspace:SetAttribute("TugOfWarRhythmGoal", 180)
                workspace:SetAttribute("TugOfWarRush", nil)
                local v = findOrClone()
                if v then
                    v.Enabled = true
                    ui = v
                    local handler = v:FindFirstChild("TugOfWarQTEHandler", true)
                        or v:FindFirstChildWhichIsA("LocalScript", true)
                        or v:FindFirstChildWhichIsA("Script", true)
                    if handler and handler:IsA("LocalScript") then
                        handler.Disabled = false
                    end
                end
                task.wait(0.3)
                localPlayer:SetAttribute("TugOfWarPhase", "QTE")
                notify("Tug of War", "QTE Mode Enabled", 0.9)
            else
                notify("Tug of War", "QTE Mode Disabled", 0.9)
            end
            PlayToggleSound()
        end,
    })
end
end
--玩家/额外
local meun = Tabs.Wjewgn:AddLeftGroupbox("| 玩家", "user")
local Wjgjgn = Tabs.Wjewgn:AddRightGroupbox("| 战斗吸附", "magnet")
local LeftGroupBox = Tabs.Wjewgn:AddRightGroupbox("| 玩家透视", "eye")
local FunGroup = Tabs.Wjewgn:AddLeftGroupbox("角色特效", "sparkles")
local TagGroup = Tabs.Wjewgn:AddRightGroupbox("自定义玩家标签", "tag")
    
local FlyingEnabled = false
local SpinningEnabled = false
local FlightSpeed = 50
local SpinSpeed = 5
local CurrentAO, CurrentLV, CurrentMoverAttachment
local FlightConnection
local Control = {F = 0, B = 0, L = 0, R = 0, Q = 0, E = 0}
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local function getControlModule()
local PlayerModule = LocalPlayer:WaitForChild("PlayerScripts"):WaitForChild("PlayerModule")
return require(PlayerModule:WaitForChild("ControlModule"))
end
local function setupBodyMovers(character)
local hrp = character:WaitForChild("HumanoidRootPart")
local humanoid = character:WaitForChild("Humanoid")
local moverParent = workspace:FindFirstChildOfClass("Terrain") or workspace
local moverAttachment = Instance.new("Attachment", hrp)
moverAttachment.Name = "FlightAttachment"
local alignOrientation = Instance.new("AlignOrientation")
alignOrientation.Mode = Enum.OrientationAlignmentMode.OneAttachment
alignOrientation.RigidityEnabled = true
alignOrientation.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
alignOrientation.CFrame = hrp.CFrame
alignOrientation.Attachment0 = moverAttachment
alignOrientation.Parent = moverParent
local linearVelocity = Instance.new("LinearVelocity")
linearVelocity.VectorVelocity = Vector3.zero
linearVelocity.MaxForce = 9e9
linearVelocity.Attachment0 = moverAttachment
linearVelocity.Parent = moverParent
return alignOrientation, linearVelocity, humanoid, moverAttachment
end
local function getFlightVector(controlModule)
local moveVector = controlModule:GetMoveVector()
Control.F = -moveVector.Z
Control.B = moveVector.Z
Control.L = -moveVector.X
Control.R = moveVector.X
Control.Q = moveVector.Y
Control.E = -moveVector.Y
if UserInputService:IsKeyDown(Enum.KeyCode.W) then Control.F = 1 end
if UserInputService:IsKeyDown(Enum.KeyCode.S) then Control.B = 1 end
if UserInputService:IsKeyDown(Enum.KeyCode.A) then Control.L = 1 end
if UserInputService:IsKeyDown(Enum.KeyCode.D) then Control.R = 1 end
if UserInputService:IsKeyDown(Enum.KeyCode.Space) then Control.Q = 1 end
if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then Control.E = 1 end
local flightVector =
    Camera.CFrame.LookVector * (Control.F - Control.B) +
    Camera.CFrame.RightVector * (Control.R - Control.L) +
    Vector3.new(0, 1, 0) * (Control.Q - Control.E)
return flightVector.Magnitude > 0 and flightVector.Unit or flightVector
end
local function startFlying()
if FlyingEnabled then return end
local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
if not character then return end
FlyingEnabled = true
SpinningEnabled = false
if CurrentAO then CurrentAO:Destroy() end
if CurrentLV then CurrentLV:Destroy() end
if CurrentMoverAttachment then CurrentMoverAttachment:Destroy() end
CurrentAO, CurrentLV, humanoid, CurrentMoverAttachment = setupBodyMovers(character)
local controlModule = getControlModule()
FlightConnection = RunService.Heartbeat:Connect(function()
    if not FlyingEnabled or not CurrentLV or not CurrentAO then return end
    local flightVector = getFlightVector(controlModule)
    if flightVector.Magnitude > 0 then
        CurrentLV.VelocityConstraintMode = Enum.VelocityConstraintMode.Vector
        CurrentLV.VectorVelocity = flightVector * FlightSpeed
    else
        CurrentLV.VectorVelocity = Vector3.zero
    end
    if SpinningEnabled then
        local targetPart = humanoid.SeatPart or character.HumanoidRootPart
        CurrentAO.CFrame = targetPart.CFrame * CFrame.Angles(0, math.rad(SpinSpeed), 0)
    else
        CurrentAO.CFrame = Camera.CFrame
    end
    humanoid.PlatformStand = true
end)
character.AncestryChanged:Connect(function(_, parent)
    if not parent and FlyingEnabled then
        stopFlying()
    end
end)
end

local function stopFlying()
if not FlyingEnabled then return end
FlyingEnabled = false
SpinningEnabled = false
if FlightConnection then
    FlightConnection:Disconnect()
    FlightConnection = nil
end
if CurrentAO then CurrentAO:Destroy() end
if CurrentLV then CurrentLV:Destroy() end
if CurrentMoverAttachment then CurrentMoverAttachment:Destroy() end
local character = LocalPlayer.Character
if character and character:FindFirstChild("Humanoid") then
    character.Humanoid.PlatformStand = false
end
end
meun:AddToggle('MyToggle', {
Text = '飞行模式[有概率被反作弊击杀]',
Default = false,
Tooltip = '开启 / 关闭飞行功能',
Callback = function(Value)
    if Value then
        startFlying()
    else
        stopFlying()
    end
end
})
meun:AddSlider('MyIntSlider', {
Text = '飞行速度',
Default = 50,
Min = 1,
Max = 200,
Rounding = 0,
Suffix = '',
Compact = false,
Callback = function(Value)
    FlightSpeed = Value
end
})
meun:AddToggle('JumpToggle', {
Text = '超级跳跃',
Default = false,
Tooltip = '开启后跳跃高度大幅提升',
Callback = function(Value)
    local JumpEnabled = Value
    local CurrentJump = 500
    
    local function updateJumpInternal()
        local LocalPlayer = game:GetService("Players").LocalPlayer
        local humanoid = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid.JumpPower = JumpEnabled and CurrentJump or 50
        end
    end
    
    updateJumpInternal()
    
    Wjty2:SetData('JumpToggle_JumpEnabled', JumpEnabled)
    Wjty2:SetData('JumpToggle_CurrentJump', CurrentJump)
    
    Library:Notify(JumpEnabled and "超级跳跃已开启" or "超级跳跃已关闭", 1)
end
})
meun:AddSlider('JumpPowerSlider', {
Text = '跳跃力度值',
Default = 100,
Min = 50,
Max = 500,
Suffix = " 力量",
Tooltip = '设置跳跃力度（需开启超级跳跃）',
Callback = function(Value)
    local JumpEnabled = Wjty2:GetData('JumpToggle_JumpEnabled') or false
    local LocalPlayer = game:GetService("Players").LocalPlayer
    
    Wjty2:SetData('JumpToggle_CurrentJump', Value)
    
    if JumpEnabled then
        local humanoid = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid.JumpPower = Value
        end
    end
    
    Library:Notify("跳跃力度已设置为: " .. Value, 1)
end
})
local RunService  = game:GetService("RunService")
local Players     = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local WalkSpeedConfig = {
Enabled = false,
Value   = 16,
Connection = nil,
}
local function getHumanoid()
local char = LocalPlayer.Character
return char and char:FindFirstChildOfClass("Humanoid")
end
local function applySpeed()
local hum = getHumanoid()
if hum then
    hum.WalkSpeed = WalkSpeedConfig.Value
end
end
local function startLock()
if WalkSpeedConfig.Connection then
    WalkSpeedConfig.Connection:Disconnect()
end
WalkSpeedConfig.Connection = RunService.Heartbeat:Connect(function()
    if not WalkSpeedConfig.Enabled then return end
    local hum = getHumanoid()
    if hum and hum.WalkSpeed ~= WalkSpeedConfig.Value then
        hum.WalkSpeed = WalkSpeedConfig.Value
    end
end)
end
local function stopLock()
if WalkSpeedConfig.Connection then
    WalkSpeedConfig.Connection:Disconnect()
    WalkSpeedConfig.Connection = nil
end
end
LocalPlayer.CharacterAdded:Connect(function()
task.wait(0.5)
if WalkSpeedConfig.Enabled then
    applySpeed()
end
end)
meun:AddToggle("WalkSpeedToggle", {
Text = "启用移动速度修改",
Default = false,
Tooltip = "开启后持续锁定 WalkSpeed，防止被服务器重置",
Callback = function(Value)
    WalkSpeedConfig.Enabled = Value
    if Value then
        applySpeed()
        startLock()
    else
        stopLock()           
        local hum = getHumanoid()
        if hum then
            hum.WalkSpeed = 16
        end
    end
end,
})
meun:AddSlider("WalkSpeedSlider", {
Text = "移动速度(可在墨水使用)",
Default = 16,
Min = 16,
Max = 200,
Rounding = 0,
Compact = false,
Callback = function(Value)
    WalkSpeedConfig.Value = Value
    if WalkSpeedConfig.Enabled then
        applySpeed()
    end
end,
})
local skipDialogueCoroutine = nil
local keepPlayingCoroutine = nil
local function getRemotes()
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Remotes = ReplicatedStorage:WaitForChild("Remotes")
return Remotes
end
local function startSkipDialogue()
if skipDialogueCoroutine then
    return
end    
skipDialogueCoroutine = coroutine.create(function()
    local Remotes = getRemotes()
    local DialogueRemote = Remotes:WaitForChild("DialogueRemote")       
    while true do
        local args = {
            buffer.fromstring("=98;888888\200\a<?888kSQHH]\\"),
            {}
        }
        DialogueRemote:FireServer(unpack(args))
        task.wait(0)
    end
end)    
coroutine.resume(skipDialogueCoroutine)
print("自动跳过对话已开启")
end
local function stopSkipDialogue()
if skipDialogueCoroutine then
    skipDialogueCoroutine = nil
    print("自动跳过对话已关闭")
end
end
local function startKeepPlaying()
if keepPlayingCoroutine then
    return
end    
keepPlayingCoroutine = coroutine.create(function()
    local Remotes = getRemotes()
    local ExtraTemporaryRemote = Remotes:WaitForChild("ExtraTemporaryRemote")       
    while true do
        local args = {
            {
                Voting = "KeepPlaying"
            }
        }
        ExtraTemporaryRemote:FireServer(unpack(args))
        task.wait(0)
    end
end)    
coroutine.resume(keepPlayingCoroutine)
print("自动选择继续游戏已开启")
end
local function stopKeepPlaying()
if keepPlayingCoroutine then
    keepPlayingCoroutine = nil
    print("自动选择继续游戏已关闭")
end
end
meun:AddToggle('SkipDialogueToggle', {
Text = '自动跳过对话',
Default = false,
Tooltip = '开启后自动跳过墨水游戏对话',
Callback = function(Value)
    print('[回调] 自动跳过对话状态:', Value)
    
    if Value then
        startSkipDialogue()
    else
        stopSkipDialogue()
    end
end
})
meun:AddButton("跑酷艺术家", function()
LocalPlayer:SetAttribute("_EquippedPower", "PARKOUR ARTIST") 
end)
local PlayerNames = {}
for _, Player in ipairs(Players:GetPlayers()) do
if Player ~= LocalPlayer then
    table.insert(PlayerNames, Player.Name)
end
end
local PlayerNames = {}
for _, Player in ipairs(Players:GetPlayers()) do
if Player ~= LocalPlayer then
    table.insert(PlayerNames, Player.Name)
end
end

local PlayerDropdown = meun:AddDropdown("SelectPlayerDropdown", {
Multi = false,
Values = PlayerNames,
Callback = function(Value) end
})
meun:AddButton("传送到选中玩家", function()
local SelectedName = Library.Options.SelectPlayerDropdown.Value
local TargetPlayer = Players:FindFirstChild(SelectedName)    
if TargetPlayer and TargetPlayer.Character then
    local TargetRoot = TargetPlayer.Character:FindFirstChild("HumanoidRootPart")
    local MyRoot = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")        
    if TargetRoot and MyRoot then
        MyRoot.CFrame = TargetRoot.CFrame + Vector3.new(0, 2, 0)
    end
end
end)
meun:AddButton("刷新玩家列表", function()
local NewNames = {}
for _, Player in ipairs(Players:GetPlayers()) do
    if Player ~= LocalPlayer then
        table.insert(NewNames, Player.Name)
    end
end
PlayerDropdown:Refresh(NewNames)
end)

--人物旋转
local Players          = game:GetService("Players")
local RunService       = game:GetService("RunService")
local LocalPlayer      = Players.LocalPlayer
Settings = Settings or {}
Settings.Rotating          = false
Settings.RotationSpeed     = 7200
Settings.RotationDirection = 1
Settings.PauseOnMove       = false
Settings.AccumulatedAngle  = 0
Settings.RotationConn      = nil

Options = Options or {}
Library = Library or {}
if not Library.Notify then
function Library:Notify(msg, dur)
    print("[Notify] " .. tostring(msg))
end
end
local function getRoot()
local char = LocalPlayer.Character
return char and char:FindFirstChild("HumanoidRootPart")
end
local function getHumanoid()
local char = LocalPlayer.Character
return char and char:FindFirstChildOfClass("Humanoid")
end
local function startRotate()
if Settings.RotationConn then
    Settings.RotationConn:Disconnect()
    Settings.RotationConn = nil
end
Settings.AccumulatedAngle = 0
Settings.RotationConn = RunService.Heartbeat:Connect(function(dt)
    if not Settings.Rotating then return end
    local root = getRoot()
    local hum  = getHumanoid()
    if not root or not hum or hum.Health <= 0 then return end
    if Settings.PauseOnMove and hum.MoveDirection.Magnitude > 0.1 then
        return
    end
    Settings.AccumulatedAngle = (
        Settings.AccumulatedAngle
        + Settings.RotationSpeed * dt * Settings.RotationDirection
    ) % 360

    root.CFrame = CFrame.new(root.Position)
        * CFrame.Angles(0, math.rad(Settings.AccumulatedAngle), 0)
end)
end
local function stopRotate()
if Settings.RotationConn then
    Settings.RotationConn:Disconnect()
    Settings.RotationConn = nil
end
Settings.AccumulatedAngle = 0
end
function toggleRotate(enabled)
Settings.Rotating = enabled and true or false
if Settings.Rotating then
    startRotate()
else
    stopRotate()
end
end
function setDirection(dir)
Settings.RotationDirection = dir
end
LocalPlayer.CharacterAdded:Connect(function()
task.wait(0.5)
if Settings.Rotating then
    startRotate()
end
end)

Options.RotateToggle = meun:AddToggle('RotateToggle', {
Text = '启用旋转',
Default = false,
Tooltip = '开启/关闭人物旋转功能',
Callback = function(Value)
    toggleRotate(Value)
end
})
Options.SpeedSlider = meun:AddSlider('SpeedSlider', {
Text = '旋转速度',
Default = 7200,
Min = 100,
Max = 36000,
Rounding = 0,
Suffix = " °/秒",
Tooltip = '设置旋转速度（度/秒）\n建议范围：1000-20000',
Callback = function(Value)
    Settings.RotationSpeed = Value
    if Settings.Rotating then
        Library:Notify("速度已更新: " .. Value .. "°/s", 1)
    end
end
})
Options.DirectionDropdown = meun:AddDropdown('DirectionDropdown', {
Text = '旋转方向',
Values = {'顺时针', '逆时针'},
Default = '顺时针',
Tooltip = '选择旋转方向',
Callback = function(Value)
    if Value == '顺时针' then
        setDirection(1)
    else
        setDirection(-1)
    end
end
})
Options.DirectionButton = meun:AddButton({
Text = '切换方向',
Func = function()
    if Settings.RotationDirection == 1 then
        setDirection(-1)
        if Options.DirectionDropdown and Options.DirectionDropdown.SetValue then
            Options.DirectionDropdown:SetValue('逆时针')
        end
    else
        setDirection(1)
        if Options.DirectionDropdown and Options.DirectionDropdown.SetValue then
            Options.DirectionDropdown:SetValue('顺时针')
        end
    end
end
})
Options.PauseOnMoveToggle = meun:AddToggle('PauseOnMoveToggle', {
Text = '移动时暂停旋转',
Default = false,
Tooltip = '走路时暂停旋转，避免卡顿',
Callback = function(Value)
    Settings.PauseOnMove = Value and true or false
end
})

--战斗吸附
do
local RunService  = game:GetService("RunService")
local Players     = game:GetService("Players")
local Stats       = game:GetService("Stats")
local LocalPlayer = Players.LocalPlayer
local function PlayToggleSound() end
local function PlayErrorSound() end
local function PlayBell() end
local function notify(title, text, duration)
    Library:Notify({
        Title = tostring(title),
        Description = tostring(text or ""),
        Time = tonumber(duration) or 0.9,
    })
end
local CONFIG = {
    FollowDistance    = 3,
    FollowHiders      = true,
    FollowPosition    = "后面",
    UseFixedTarget    = false,
    FixedTargetName   = nil,
    AutoSwitchOnDeath = true,
    PredictMultiplier = 1,
    PredictMaxOffset  = 30,
    PredictMinSpeed   = 0.5,
    SkipGuards        = false,   -- 新增
}
local followConnection = nil
local currentTarget    = nil
local isFollowing      = false
local SPIKES_KILL_ANIM_ID  = "rbxassetid://105341857343164"
local pausedBySpikesKill   = false
local spikesDeathConn      = nil
local spikesFallbackTask   = nil
local function clearSpikesWatch()
    if spikesDeathConn then
        pcall(function() spikesDeathConn:Disconnect() end)
        spikesDeathConn = nil
    end
    if spikesFallbackTask then
        pcall(function() task.cancel(spikesFallbackTask) end)
        spikesFallbackTask = nil
    end
end
local function resumeFollowAfterSpikes()
    clearSpikesWatch()
    if not pausedBySpikesKill then return end
    task.wait(0.3)
    pausedBySpikesKill = false
    print("[AutoFollow] 尖刺击杀动画结束，吸附已恢复")
end
local function findNearestEnemyChar()
    local myChar = LocalPlayer.Character
    local myHRP  = myChar and myChar:FindFirstChild("HumanoidRootPart")
    if not myHRP then return nil end
    local nearest, dist = nil, math.huge
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            local hrp = p.Character:FindFirstChild("HumanoidRootPart")
            local hum = p.Character:FindFirstChildOfClass("Humanoid")
            if hrp and hum and hum.Health > 0 then
                local d = (hrp.Position - myHRP.Position).Magnitude
                if d < dist then
                    dist = d
                    nearest = p.Character
                end
            end
        end
    end
    return nearest
end
local function onSpikesAnimationDetected()
    if not isFollowing then return end
    if pausedBySpikesKill then return end
    pausedBySpikesKill = true
    print("[AutoFollow] 检测到尖刺击杀动画，吸附已暂停")
    clearSpikesWatch()
    local enemy = findNearestEnemyChar()
    if enemy then
        local hum = enemy:FindFirstChildOfClass("Humanoid")
        if hum then
            spikesDeathConn = hum.Died:Connect(function()
                print("[AutoFollow] 敌人已死亡，准备恢复吸附")
                resumeFollowAfterSpikes()
            end)
        end
    end      
    spikesFallbackTask = task.delay(8, function()
        if pausedBySpikesKill then
            print("[AutoFollow] 尖刺动画超时，强制恢复吸附")
            resumeFollowAfterSpikes()
        end
    end)
end
local function hookLocalAnimations(character)
    local humanoid = character:WaitForChild("Humanoid", 5)
    if not humanoid then return end
    humanoid.AnimationPlayed:Connect(function(track)
        if not track or not track.Animation then return end
        if track.Animation.AnimationId == SPIKES_KILL_ANIM_ID then
            onSpikesAnimationDetected()
        end
    end)
end
if LocalPlayer.Character then
    hookLocalAnimations(LocalPlayer.Character)
end
LocalPlayer.CharacterAdded:Connect(function(char)
    task.wait(0.5)
    hookLocalAnimations(char)
end)
local function getPing()
    local ok, ping = pcall(function()
        return Stats.Network.ServerStatsItem["Data Ping"]:GetValue()
    end)
    return ok and ping or 0
end
local function IsPlayerSeeker(player)
    if not player or not player.Character then return false end
    if player.Backpack and player.Backpack:FindFirstChild("Knife") then return true end
    if player.Character:FindFirstChild("Knife") then return true end
    return false
end
local function IsPlayerGuard(player)
    if not player then return false end
    return player:GetAttribute("IsGuard") == true
end
local function IsAlive(player)
    if not player or not player.Character then return false end
    local hum = player.Character:FindFirstChildOfClass("Humanoid")
    local hrp = player.Character:FindFirstChild("HumanoidRootPart")
    return hum and hrp and hum.Health > 0
end
local function GetHiders()
    local hiders = {}
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and IsAlive(player) then
            if not IsPlayerSeeker(player) then
                if not (CONFIG.SkipGuards and IsPlayerGuard(player)) then
                    table.insert(hiders, player)
                end
            end
        end
    end
    return hiders
end
local function GetAllPlayers()
    local list = {}
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and IsAlive(player) then
            if not (CONFIG.SkipGuards and IsPlayerGuard(player)) then
                table.insert(list, player)
            end
        end
    end
    return list
end
local function getTarget()
    if CONFIG.UseFixedTarget and CONFIG.FixedTargetName then
        local p = Players:FindFirstChild(CONFIG.FixedTargetName)
        local validFixed = p and IsAlive(p)
        local isGuardBlocked = validFixed and CONFIG.SkipGuards and IsPlayerGuard(p)
        if validFixed and not isGuardBlocked then
            return p
        end
        if CONFIG.AutoSwitchOnDeath or isGuardBlocked then
            warn("[AutoFollow] 指定目标 " .. tostring(CONFIG.FixedTargetName)
                .. (isGuardBlocked and " 是守卫，跳过" or " 已死亡/离开")
                .. "，自动切换...")
            CONFIG.UseFixedTarget = false
            if Options.FixedTargetToggle and Options.FixedTargetToggle.SetValue then
                pcall(function() Options.FixedTargetToggle:SetValue(false) end)
            end
        else
            return nil
        end
    end
    if CONFIG.FollowHiders then
        local hiders = GetHiders()
        if #hiders > 0 then
            return hiders[math.random(1, #hiders)]
        end
        return nil
    else
        local all = GetAllPlayers()
        if #all > 0 then
            return all[math.random(1, #all)]
        end
        return nil
    end
end
local function predictTarget(targetHRP)
    local ping = getPing()
    local predictTime = (ping / 1000) * CONFIG.PredictMultiplier
    local curPos = targetHRP.Position
    local vel    = targetHRP.AssemblyLinearVelocity
    if vel.Magnitude < CONFIG.PredictMinSpeed or predictTime <= 0 then
        return targetHRP.CFrame
    end
    local predPos = curPos + vel * predictTime
    local offset = predPos - curPos
    if offset.Magnitude > CONFIG.PredictMaxOffset then
        predPos = curPos + offset.Unit * CONFIG.PredictMaxOffset
    end
    return CFrame.lookAt(predPos, predPos + targetHRP.CFrame.LookVector)
end
local function getPositionOffset()
    local distance = CONFIG.FollowDistance
    local position = CONFIG.FollowPosition
    if position == "前面" then
        return CFrame.new(0, 0, -distance)
    elseif position == "后面" then
        return CFrame.new(0, 0, distance)
    elseif position == "头顶" then
        return CFrame.new(0, distance, 0) * CFrame.Angles(math.rad(-90), 0, 0)
    elseif position == "下面" then
        return CFrame.new(0, -distance, 0)
    elseif position == "左面" then
        return CFrame.new(-distance, 0, 0)
    elseif position == "右面" then
        return CFrame.new(distance, 0, 0)
    else
        return CFrame.new(0, 0, distance)
    end
end
local function stopFollowing()
    if not isFollowing then return end
    if followConnection then
        followConnection:Disconnect()
        followConnection = nil
    end
    isFollowing   = false
    currentTarget = nil
    print("已停止依附")
end
local function startFollowing()
    if isFollowing then
        stopFollowing()
        task.wait()
    end
    currentTarget = getTarget()
    if not currentTarget then
        local targetType = CONFIG.UseFixedTarget and "指定玩家"
            or (CONFIG.FollowHiders and "躲藏者" or "任意玩家")
        warn("未找到可依附的目标（" .. targetType .. "）！")
        return
    end
    isFollowing = true
    local targetType
    if CONFIG.UseFixedTarget then
        targetType = "指定玩家"
    else
        targetType = CONFIG.FollowHiders and "躲藏者"
            or (IsPlayerSeeker(currentTarget) and "搜寻者" or "躲藏者")
    end
    print("开始依附(预判): " .. currentTarget.Name .. " (" .. targetType .. ") 位置: " .. CONFIG.FollowPosition)
    followConnection = RunService.Heartbeat:Connect(function()            
        if pausedBySpikesKill then return end

        if not currentTarget or not IsAlive(currentTarget) then
            if CONFIG.AutoSwitchOnDeath then
                print("[AutoFollow] 目标失效，自动切换下一个...")
                task.spawn(function()
                    task.wait(0.3)
                    if isFollowing then
                        stopFollowing()
                        task.wait(0.1)
                        startFollowing()
                    end
                end)
            else
                stopFollowing()
            end
            return
        end
        local targetChar = currentTarget.Character
        local targetHRP  = targetChar:FindFirstChild("HumanoidRootPart")
        if not targetHRP then return end
        local myChar = LocalPlayer.Character
        if not myChar then return end
        local myHRP = myChar:FindFirstChild("HumanoidRootPart")
        if not myHRP then return end
        local baseCF = predictTarget(targetHRP)
        local offset = getPositionOffset()
        myHRP.CFrame = baseCF * offset
    end)
end
Wjgjgn:AddToggle('AutoFollow', {
    Text = '预判吸附',
    Default = false,
    Tooltip = '根据本地延迟+目标速度+目标朝向预测位置后依附',
    Callback = function(Value)
        if Value then
            startFollowing()
        else
            stopFollowing()
            clearSpikesWatch()
            pausedBySpikesKill = false
        end
    end,
})
Wjgjgn:AddToggle('FollowHiders', {
    Text = '只依附躲藏者',
    Default = true,
    Tooltip = '开启：只依附躲藏者；关闭：随机依附任意玩家',
    Callback = function(Value)
        CONFIG.FollowHiders = Value
        if isFollowing and not CONFIG.UseFixedTarget then
            stopFollowing()
            task.wait()
            startFollowing()
        end
    end,
})
Wjgjgn:AddToggle('SkipGuards', {
    Text = '跳过守卫',
    Default = false,
    Callback = function(Value)
        CONFIG.SkipGuards = Value
        if isFollowing then
            stopFollowing()
            task.wait()
            startFollowing()
        end
    end,
})
Wjgjgn:AddDropdown('FollowPosition', {
    Values = {'前面', '后面', '头顶', '下面', '左面', '右面'},
    Default = '后面',
    Multi = false,
    Text = '依附位置',
    Tooltip = '选择依附在预测位置的哪个方向',
    Callback = function(Value)
        CONFIG.FollowPosition = Value
        if isFollowing then
            print("依附位置已切换至: " .. Value)
        end
    end,
})
Wjgjgn:AddSlider('FollowDistance', {
    Text = '依附距离',
    Default = 3,
    Min = 1,
    Max = 10,
    Increment = 0.5,
    Tooltip = '与预测位置的距离（越近越贴身）',
    Callback = function(Value)
        CONFIG.FollowDistance = Value
    end,
})
Wjgjgn:AddSlider('PredictMultiplier', {
    Text = '预判倍率',
    Default = 1,
    Min = 0.5,
    Max = 5,
    Increment = 0.5,
    Tooltip = '预判时间 = 延迟(秒) × 此倍率。1 就是标准预判，越大预判越提前',
    Callback = function(Value)
        CONFIG.PredictMultiplier = Value
    end,
})
Wjgjgn:AddSlider('PredictMaxOffset', {
    Text = '预判上限',
    Default = 30,
    Min = 5,
    Max = 100,
    Increment = 5,
    Tooltip = '预判位置距离目标当前位置的最大格数，防止飞出去',
    Callback = function(Value)
        CONFIG.PredictMaxOffset = Value
    end,
})
local function getPlayerList()
    local list = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then
            table.insert(list, p.Name)
        end
    end
    if #list == 0 then
        list = {"无其他玩家"}
    end
    return list
end
Wjgjgn:AddDropdown('FollowPlayerSelect', {
    Values = getPlayerList(),
    Default = 1,
    Multi = false,
    Text = '选择吸附玩家',
    Tooltip = '从列表选择要固定吸附的玩家',
    Callback = function(Value)
        CONFIG.FixedTargetName = Value
        print("[AutoFollow] 已选择目标: " .. tostring(Value))
    end,
})
Wjgjgn:AddToggle('FixedTargetToggle', {
    Text = '固定吸附指定玩家',
    Default = false,
    Tooltip = '开启后固定吸附上面选中的玩家；目标死亡后自动切换',
    Callback = function(Value)
        CONFIG.UseFixedTarget = Value
        if Value then
            if not CONFIG.FixedTargetName or not Players:FindFirstChild(CONFIG.FixedTargetName) then
                warn("[AutoFollow] 未选择有效玩家！")
                return
            end
        end
        if isFollowing then
            stopFollowing()
            task.wait()
            startFollowing()
        end
    end,
})
Wjgjgn:AddToggle('AutoSwitchToggle', {
    Text = '目标死亡自动切换',
    Default = true,
    Tooltip = '目标死亡或离开后，自动切换到下一个随机目标',
    Callback = function(Value)
        CONFIG.AutoSwitchOnDeath = Value
    end,
})
Wjgjgn:AddButton({
    Text = '刷新玩家列表',
    Func = function()
        if Options.FollowPlayerSelect and Options.FollowPlayerSelect.Refresh then
            Options.FollowPlayerSelect:Refresh(getPlayerList())
        elseif Options.FollowPlayerSelect and Options.FollowPlayerSelect.SetValues then
            Options.FollowPlayerSelect:SetValues(getPlayerList())
        else
            print("[AutoFollow] 你的UI库不支持动态刷新，请重新执行脚本")
        end
    end,
})
Players.PlayerAdded:Connect(function()
    task.wait(0.5)
    if Options.FollowPlayerSelect and Options.FollowPlayerSelect.Refresh then
        Options.FollowPlayerSelect:Refresh(getPlayerList())
    end
end)
Players.PlayerRemoving:Connect(function(player)
    task.wait(0.2)
    if CONFIG.UseFixedTarget and CONFIG.FixedTargetName == player.Name then
        if CONFIG.AutoSwitchOnDeath then
            CONFIG.UseFixedTarget = false
            if Options.FixedTargetToggle and Options.FixedTargetToggle.SetValue then
                pcall(function() Options.FixedTargetToggle:SetValue(false) end)
            end
        end
    end
    if Options.FollowPlayerSelect and Options.FollowPlayerSelect.Refresh then
        Options.FollowPlayerSelect:Refresh(getPlayerList())
    end
end)
end
--玩家透视
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera
local ESPConfig = {
Enabled = false,
Box = true,
Skeleton = true,
HealthBar = true,
Lines = false,
Name = true,
Distance = true,
TeamCheck = true,
}
local ESPObjects = {}
local function CreateDrawing(class, properties)
local draw = Drawing.new(class)
for prop, val in pairs(properties) do
	pcall(function()
		draw[prop] = val
	end)
end
return draw
end
local SkeletonConnections = {	
R6 = {
	{"Head", "Torso"},
	{"Torso", "Left Arm"},
	{"Torso", "Right Arm"},
	{"Torso", "Left Leg"},
	{"Torso", "Right Leg"},
},	
R15 = {
	{"Head", "UpperTorso"},
	{"UpperTorso", "LowerTorso"},
	{"UpperTorso", "LeftUpperArm"},
	{"LeftUpperArm", "LeftLowerArm"},
	{"LeftLowerArm", "LeftHand"},
	{"UpperTorso", "RightUpperArm"},
	{"RightUpperArm", "RightLowerArm"},
	{"RightLowerArm", "RightHand"},
	{"LowerTorso", "LeftUpperLeg"},
	{"LeftUpperLeg", "LeftLowerLeg"},
	{"LeftLowerLeg", "LeftFoot"},
	{"LowerTorso", "RightUpperLeg"},
	{"RightUpperLeg", "RightLowerLeg"},
	{"RightLowerLeg", "RightFoot"},
},
}
local function CreateESP(player)
if player == LocalPlayer then return end
if ESPObjects[player] then return end
local esp = {
	Box = CreateDrawing("Square", {
		Thickness = 1,
		Transparency = 1,
		Color = Color3.fromRGB(255, 255, 255),
		Filled = false,
		Visible = false,
	}),
	BoxOutline = CreateDrawing("Square", {
		Thickness = 1,
		Transparency = 0.5,
		Color = Color3.fromRGB(0, 0, 0),
		Filled = false,
		Visible = false,
	}),
	HealthBarBack = CreateDrawing("Square", {
		Thickness = 1,
		Transparency = 0.5,
		Color = Color3.fromRGB(0, 0, 0),
		Filled = true,
		Visible = false,
	}),
	HealthBarFill = CreateDrawing("Square", {
		Thickness = 1,
		Transparency = 0.2,
		Color = Color3.fromRGB(0, 255, 0),
		Filled = true,
		Visible = false,
	}),
	Line = CreateDrawing("Line", {
		Thickness = 1,
		Transparency = 1,
		Color = Color3.fromRGB(255, 255, 255),
		Visible = false,
	}),
	NameText = CreateDrawing("Text", {
		Size = 14,
		Center = true,
		Outline = true,
		Color = Color3.fromRGB(255, 255, 255),
		Visible = false,
	}),
	SkeletonLines = {},
}
ESPObjects[player] = esp
end
local function RemoveESP(player)
local esp = ESPObjects[player]
if not esp then return end

esp.Box:Remove()
esp.BoxOutline:Remove()
esp.HealthBarBack:Remove()
esp.HealthBarFill:Remove()
esp.Line:Remove()
esp.NameText:Remove()

for _, line in ipairs(esp.SkeletonLines) do
	line:Remove()
end

ESPObjects[player] = nil
end
local function GetCharacterParts(character)
if not character then return nil end
local humanoid = character:FindFirstChildOfClass("Humanoid")
local rootPart = character:FindFirstChild("HumanoidRootPart")
if not humanoid or not rootPart then return nil end
local head = character:FindFirstChild("Head")
if not head then return nil end
return humanoid, rootPart, head
end

local function GetSkeletonPairs(character)
local humanoid = character:FindFirstChildOfClass("Humanoid")
if not humanoid then return {} end
local rigType = humanoid.RigType
local pairs = {}
if rigType == Enum.HumanoidRigType.R6 then
	pairs = SkeletonConnections.R6
else
	pairs = SkeletonConnections.R15
end

return pairs
end

local function UpdateESP(player, esp)
local character = player.Character
if not character then
	esp.Box.Visible = false
	esp.BoxOutline.Visible = false
	esp.HealthBarBack.Visible = false
	esp.HealthBarFill.Visible = false
	esp.Line.Visible = false
	esp.NameText.Visible = false
	for _, line in ipairs(esp.SkeletonLines) do
		line.Visible = false
	end
	return
end

local humanoid, rootPart, head = GetCharacterParts(character)
if not humanoid or not rootPart or not head then
	esp.Box.Visible = false
	esp.BoxOutline.Visible = false
	esp.HealthBarBack.Visible = false
	esp.HealthBarFill.Visible = false
	esp.Line.Visible = false
	esp.NameText.Visible = false
	for _, line in ipairs(esp.SkeletonLines) do
		line.Visible = false
	end
	return
end

if humanoid.Health <= 0 then
	esp.Box.Visible = false
	esp.BoxOutline.Visible = false
	esp.HealthBarBack.Visible = false
	esp.HealthBarFill.Visible = false
	esp.Line.Visible = false
	esp.NameText.Visible = false
	for _, line in ipairs(esp.SkeletonLines) do
		line.Visible = false
	end
	return
end

if ESPConfig.TeamCheck and player.Team == LocalPlayer.Team then
	esp.Box.Visible = false
	esp.BoxOutline.Visible = false
	esp.HealthBarBack.Visible = false
	esp.HealthBarFill.Visible = false
	esp.Line.Visible = false
	esp.NameText.Visible = false
	for _, line in ipairs(esp.SkeletonLines) do
		line.Visible = false
	end
	return
end

local rootScreenPos, onScreen = Camera:WorldToViewportPoint(rootPart.Position)
if not onScreen then
	esp.Box.Visible = false
	esp.BoxOutline.Visible = false
	esp.HealthBarBack.Visible = false
	esp.HealthBarFill.Visible = false
	esp.Line.Visible = false
	esp.NameText.Visible = false
	for _, line in ipairs(esp.SkeletonLines) do
		line.Visible = false
	end
	return
end
	
local headPos, _ = Camera:WorldToViewportPoint(head.Position)
local footPos, _ = Camera:WorldToViewportPoint(rootPart.Position - Vector3.new(0, 3, 0))

local boxHeight = math.abs(headPos.Y - footPos.Y)
local boxWidth = boxHeight * 0.6
local boxX = rootScreenPos.X - boxWidth / 2
local boxY = headPos.Y

local distance = (Camera.CFrame.Position - rootPart.Position).Magnitude

if ESPConfig.Box then
	esp.Box.Visible = true
	esp.Box.Position = Vector2.new(boxX, boxY)
	esp.Box.Size = Vector2.new(boxWidth, boxHeight)
	esp.Box.Color = Color3.fromRGB(255, 255, 255)
	esp.Box.Transparency = 1

	esp.BoxOutline.Visible = true
	esp.BoxOutline.Position = Vector2.new(boxX - 1, boxY - 1)
	esp.BoxOutline.Size = Vector2.new(boxWidth + 2, boxHeight + 2)
	esp.BoxOutline.Color = Color3.fromRGB(0, 0, 0)
	esp.BoxOutline.Transparency = 0.5
else
	esp.Box.Visible = false
	esp.BoxOutline.Visible = false
end

if ESPConfig.HealthBar then
	local healthPercent = humanoid.Health / humanoid.MaxHealth
	local barHeight = boxHeight
	local barWidth = 3
	local barX = boxX - barWidth - 4
	local barY = boxY

	esp.HealthBarBack.Visible = true
	esp.HealthBarBack.Position = Vector2.new(barX, barY)
	esp.HealthBarBack.Size = Vector2.new(barWidth, barHeight)

	esp.HealthBarFill.Visible = true
	local fillHeight = barHeight * healthPercent
	esp.HealthBarFill.Position = Vector2.new(barX, barY + (barHeight - fillHeight))
	esp.HealthBarFill.Size = Vector2.new(barWidth, fillHeight)

	local r = math.clamp(2 * (1 - healthPercent), 0, 1)
	local g = math.clamp(2 * healthPercent, 0, 1)
	esp.HealthBarFill.Color = Color3.new(r, g, 0)
else
	esp.HealthBarBack.Visible = false
	esp.HealthBarFill.Visible = false
end

if ESPConfig.Lines then
	esp.Line.Visible = true
	esp.Line.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
	esp.Line.To = Vector2.new(rootScreenPos.X, rootScreenPos.Y + boxHeight / 2)
	esp.Line.Color = Color3.fromRGB(255, 255, 255)
	esp.Line.Thickness = 1
else
	esp.Line.Visible = false
end

if ESPConfig.Name then
	esp.NameText.Visible = true
	esp.NameText.Position = Vector2.new(rootScreenPos.X, boxY - 18)
	esp.NameText.Text = player.Name

	if ESPConfig.Distance then
		esp.NameText.Text = string.format("%s [%d]", player.Name, math.floor(distance))
	end
	esp.NameText.Color = Color3.fromRGB(255, 255, 255)
else
	esp.NameText.Visible = false
end

if ESPConfig.Skeleton then
	local skeletonPairs = GetSkeletonPairs(character)
	while #esp.SkeletonLines < #skeletonPairs do
		table.insert(esp.SkeletonLines, CreateDrawing("Line", {
			Thickness = 1,
			Transparency = 1,
			Color = Color3.fromRGB(255, 255, 255),
			Visible = false,
		}))
	end
	for i, pair in ipairs(skeletonPairs) do
		local partA = character:FindFirstChild(pair[1])
		local partB = character:FindFirstChild(pair[2])
		if partA and partB then
			local posA, onScreenA = Camera:WorldToViewportPoint(partA.Position)
			local posB, onScreenB = Camera:WorldToViewportPoint(partB.Position)

			local line = esp.SkeletonLines[i]
			if onScreenA and onScreenB then
				line.Visible = true
				line.From = Vector2.new(posA.X, posA.Y)
				line.To = Vector2.new(posB.X, posB.Y)
				line.Color = Color3.fromRGB(255, 255, 255)
				line.Transparency = 1
			else
				line.Visible = false
			end
		else
			esp.SkeletonLines[i].Visible = false
		end
	end		
	for i = #skeletonPairs + 1, #esp.SkeletonLines do
		esp.SkeletonLines[i].Visible = false
	end
else
	for _, line in ipairs(esp.SkeletonLines) do
		line.Visible = false
	end
end
end

RunService.RenderStepped:Connect(function()
for player, esp in pairs(ESPObjects) do
	if ESPConfig.Enabled then
		UpdateESP(player, esp)
	else
		esp.Box.Visible = false
		esp.BoxOutline.Visible = false
		esp.HealthBarBack.Visible = false
		esp.HealthBarFill.Visible = false
		esp.Line.Visible = false
		esp.NameText.Visible = false
		for _, line in ipairs(esp.SkeletonLines) do
			line.Visible = false
		end
	end
end
end)

local function SetupPlayer(player)
if player ~= LocalPlayer then
	CreateESP(player)
end
end

for _, player in ipairs(Players:GetPlayers()) do
SetupPlayer(player)
end

Players.PlayerAdded:Connect(SetupPlayer)
Players.PlayerRemoving:Connect(function(player)
RemoveESP(player)
end)
LeftGroupBox:AddToggle("PlayerESP", {
Text = "玩家透视",
Tooltip = "启用/禁用玩家透视",
Default = false,
Disabled = false,
Visible = true,
Risky = false,
Callback = function(Value)
	ESPConfig.Enabled = Value
end,
})
LeftGroupBox:AddCheckbox("ESP_Box", {
Text = "方框透视",
Tooltip = "显示玩家方框",
Default = true,
Disabled = false,
Visible = true,
Risky = false,
Callback = function(Value)
	ESPConfig.Box = Value
end,
})
LeftGroupBox:AddCheckbox("ESP_Skeleton", {
Text = "骨骼透视",
Tooltip = "显示玩家骨骼",
Default = true,
Disabled = false,
Visible = true,
Risky = false,
Callback = function(Value)
	ESPConfig.Skeleton = Value
end,
})
LeftGroupBox:AddCheckbox("ESP_HealthBar", {
Text = "血条显示",
Tooltip = "显示玩家血条",
Default = true,
Disabled = false,
Visible = true,
Risky = false,
Callback = function(Value)
	ESPConfig.HealthBar = Value
end,
})
LeftGroupBox:AddCheckbox("ESP_Lines", {
Text = "线条透视",
Tooltip = "从屏幕底部到玩家的线条",
Default = false,
Disabled = false,
Visible = true,
Risky = false,
Callback = function(Value)
	ESPConfig.Lines = Value
end,
})
LeftGroupBox:AddCheckbox("ESP_Name", {
Text = "名字/距离",
Tooltip = "显示玩家名字和距离",
Default = true,
Disabled = false,
Visible = true,
Risky = false,
Callback = function(Value)
	ESPConfig.Name = Value
end,
})
LeftGroupBox:AddCheckbox("ESP_Distance", {
Text = "显示距离",
Tooltip = "在名字后显示距离",
Default = true,
Disabled = false,
Visible = true,
Risky = false,
Callback = function(Value)
	ESPConfig.Distance = Value
end,
})
LeftGroupBox:AddCheckbox("ESP_TeamCheck", {
Text = "队伍检查",
Tooltip = "忽略队友",
Default = true,
Disabled = false,
Visible = true,
Risky = false,
Callback = function(Value)
	ESPConfig.TeamCheck = Value
end,
})
do
local Players     = game:GetService("Players")
local RunService  = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local function Notify(Title, Description, Time)
    Library:Notify({ Title = Title, Description = Description, Time = Time or 3 })
end
local function GetCharacter()
    return LocalPlayer.Character
end
do
    local enabled = false
    local loop    = nil
    local respawn = nil
    local function applyGhost()
        local Char = GetCharacter()
        if not Char then return end
        local Root = Char:FindFirstChild("HumanoidRootPart")
        if Root then
            Root.Transparency = 0.4
            Root.Color = Color3.fromRGB(200, 200, 255)
            Root.Material = Enum.Material.Neon
        end
        for _, d in ipairs(Char:GetDescendants()) do
            if d:IsA("BasePart") and d.Name ~= "HumanoidRootPart" then
                d.LocalTransparencyModifier = 1
            elseif d:IsA("Decal") then
                d.Transparency = 1
            end
        end
    end
    local function restoreGhost()
        local Char = GetCharacter()
        if not Char then return end
        local Root = Char:FindFirstChild("HumanoidRootPart")
        if Root then
            Root.Transparency = 1
            Root.Color = Color3.fromRGB(255, 255, 255)
            Root.Material = Enum.Material.Plastic
        end
        for _, d in ipairs(Char:GetDescendants()) do
            if d:IsA("BasePart") and d.Name ~= "HumanoidRootPart" then
                d.LocalTransparencyModifier = 0
            elseif d:IsA("Decal") then
                d.Transparency = 0
            end
        end
    end
    FunGroup:AddToggle("GhostMode", {
        Text = "幽灵模式",
        Tooltip = "把自己变成透明幽灵（本地可见）",
        Default = false,
        Callback = function(Value)
            enabled = Value and true or false
            if loop then
                loop:Disconnect()
                loop = nil
            end
            if respawn then
                respawn:Disconnect()
                respawn = nil
            end
            if enabled then
                applyGhost()
                loop = RunService.Heartbeat:Connect(function()
                    if enabled then applyGhost() end
                end)
                respawn = LocalPlayer.CharacterAdded:Connect(function()
                    task.wait(0.5)
                    if enabled then applyGhost() end
                end)
                Notify("娱乐", "幽灵模式 已启用", 2)
            else
                restoreGhost()
                Notify("娱乐", "幽灵模式 已禁用", 2)
            end
        end,
    })
end
do
    local enabled    = false
    local loop       = nil
    local respawn    = nil
    local fakeFolder = nil
    local function applyPhantomDash()
        local Char = GetCharacter()
        if not Char then return end
        local Folder = Instance.new("Folder")
        Folder.Name = "PhantomDashFolder"
        Folder.Parent = Char
        Folder:SetAttribute("ICEROCKS", true)
        Folder:SetAttribute("LOOKVEC", "Forward")
        Char:SetAttribute("ColorForEffects", Options.PhantomDashColor.Value)
        fakeFolder = Folder
        task.delay(5, function()
            if Folder and Folder.Parent then Folder:Destroy() end
        end)
    end
    FunGroup:AddToggle("PhantomDash", {
        Text = "幻影冲刺",
        Tooltip = "生成假的冲刺特效（视觉欺骗）",
        Default = false,
    }):AddColorPicker("PhantomDashColor", {
        Default = Color3.fromRGB(255, 255, 255),
        Title = "冲刺颜色",
    })
    local phantomToggle = Options.PhantomDash
    if phantomToggle then
        phantomToggle:OnChanged(function(Value)
            enabled = Value and true or false
            if loop then
                pcall(function() task.cancel(loop) end)
                loop = nil
            end
            if respawn then
                respawn:Disconnect()
                respawn = nil
            end
            if enabled then
                applyPhantomDash()
                loop = task.spawn(function()
                    while enabled do
                        task.wait(8)
                        if enabled then
                            if fakeFolder and fakeFolder.Parent then
                                fakeFolder:Destroy()
                            end
                            applyPhantomDash()
                        end
                    end
                end)
                respawn = LocalPlayer.CharacterAdded:Connect(function()
                    task.wait(1)
                    if enabled then applyPhantomDash() end
                end)
                Notify("娱乐", "幻影冲刺 已启用", 2)
            else
                if fakeFolder and fakeFolder.Parent then
                    fakeFolder:Destroy()
                    fakeFolder = nil
                end
                Notify("娱乐", "幻影冲刺 已禁用", 2)
            end
        end)
    end
end
do
    local enabled = false
    local function applyCustomTag()
        local num = tonumber(Options.CustomTagValue.Value)
        if not num or num < 1 or num > 999 then return end
        local formatted = string.format("%03d", num)
        local Value = LocalPlayer:FindFirstChild("PlayerTagValue")
        if Value and Value:IsA("IntValue") then Value.Value = num end
        local Live = workspace:FindFirstChild("Live")
        local MyModel = Live and Live:FindFirstChild(LocalPlayer.Name)
        if MyModel then
            local Tags = MyModel:FindFirstChild("PlayerTags")
            if Tags then
                for _, side in ipairs({ "Back", "Front" }) do
                    local Part = Tags:FindFirstChild(side)
                    if Part then
                        local Gui = Part:FindFirstChild("SurfaceGui")
                        local Label = Gui and Gui:FindFirstChild("TextLabel")
                        if Label then Label.Text = formatted end
                    end
                end
            end
        end
    end
    TagGroup:AddToggle("CustomTagToggle", {
        Text = "启用自定义标签",
        Tooltip = "在头顶显示 001-999 的编号",
        Default = false,
    })
    TagGroup:AddInput("CustomTagValue", {
        Text = "标签值（1-999）",
        Default = "1",
        Numeric = true,
        Finished = true,
        Placeholder = "输入 1-999",
    })
    local tagToggle = Options.CustomTagToggle
    if tagToggle then
        tagToggle:OnChanged(function(Value)
            enabled = Value and true or false
            if enabled then
                LocalPlayer:SetAttribute("__OwnsCustomPlayerTag", true)
                applyCustomTag()
                Notify("娱乐", "自定义标签 已启用", 2)
            else
                LocalPlayer:SetAttribute("__OwnsCustomPlayerTag", nil)
                Notify("娱乐", "自定义标签 已禁用", 2)
            end
        end)
    end
    if Options.CustomTagValue then
        Options.CustomTagValue:OnChanged(function()
            if enabled then
                applyCustomTag()
            end
        end)
    end
end
end
--玩家信息
local Players1 = Tabs.Players:AddLeftGroupbox("| 玩家信息", "info")
local Players2 = Tabs.Players:AddRightGroupbox("| 玩家", "user")

local LabelA = Players1:AddLabel("名字: 等待选择...", false)
local LabelDisplayName = Players1:AddLabel("用户名: 等待选择...", false)
local LabelWim = Players1:AddLabel("金钱: 等待选择...", false)
local LabelLevel = Players1:AddLabel("等级: 等待选择...", false)
local LabelWins = Players1:AddLabel("胜场: 等待选择...", false)
local LabelSprint = Players1:AddLabel("速度等级: 等待选择...", false)
local LabelDamage = Players1:AddLabel("力量等级: 等待选择...", false)
local LabelWonBoost = Players1:AddLabel("金钱等级: 等待选择...", false)
local LabelAFK = Players1:AddLabel("挂机世界币: 等待选择...", false)
local LabelVIP = Players1:AddLabel("VIP: 等待选择...", false)
local LabelRobux = Players1:AddLabel("捐赠Robux: 等待选择...", false)
local Label2xVote = Players1:AddLabel("2倍投票: 等待选择...", false)
local LabelPSPlus = Players1:AddLabel("私服通行证: 等待选择...", false)
local LabelGlass = Players1:AddLabel("玻璃厂商: 等待选择...", false)
local LabelEmotePages = Players1:AddLabel("动作页: 等待选择...", false)
local LabelCustomTag = Players1:AddLabel("自定义标签: 等待选择...", false)
local LabelLighter = Players1:AddLabel("打火机: 等待选择...", false)

Players2:AddDropdown("MyDropdownPlayers1", {
Values = {},
Default = nil,
Multi = false,
Text = "选择玩家",
Searchable = true,
SpecialType = "Player",
ExcludeLocalPlayer = false,
})

local function refreshPlayerList()
local playerNames = {}
for _, player in pairs(Players:GetPlayers()) do
    table.insert(playerNames, player.Name)
end
pcall(function()
    Library.Options.MyDropdownPlayers1:SetValues(playerNames)
end)
end

refreshPlayerList()
Players.PlayerAdded:Connect(refreshPlayerList)
Players.PlayerRemoving:Connect(function()
task.wait(0.1)
refreshPlayerList()
end)
task.spawn(function()
while true do
    task.wait(1)
    refreshPlayerList()
end
end)

Players2:AddButton({
Text = "确定",
Func = function()
    pcall(function()
        local selectedName = Library.Options.MyDropdownPlayers1.Value
        local targetPlayer = Players:FindFirstChild(selectedName)

        if targetPlayer then
            LabelA:SetText("名字: " .. selectedName)
            LabelDisplayName:SetText("用户名: " .. targetPlayer.DisplayName)
            LabelWim:SetText("金钱: " .. tostring(targetPlayer:GetAttribute("_Won")))
            LabelLevel:SetText("等级: " .. tostring(targetPlayer:GetAttribute("_CurrentLevel")))
            LabelWins:SetText("胜场: " .. tostring(targetPlayer:GetAttribute("_GameWins")))
            LabelRobux:SetText("捐赠Robux: " .. tostring(targetPlayer:GetAttribute("_TotalRobuxDonated")))
            LabelAFK:SetText("挂机世界币: " .. tostring(targetPlayer:GetAttribute("_AFKCoins")))

            local vipData = targetPlayer:GetAttribute("_VIPSettingData")
            if vipData == "[]" or vipData == "" or not vipData then
                LabelVIP:SetText("VIP: X")
            else
                LabelVIP:SetText("VIP: √")
            end

            local has2xVote = targetPlayer:GetAttribute("__Owns2XVoteGamepass")
            Label2xVote:SetText("2倍投票: " .. (has2xVote and "√" or "X"))

            local hasPSPlus = targetPlayer:GetAttribute("__OwnsPSPlus")
            LabelPSPlus:SetText("私服: " .. (hasPSPlus and "√" or "X"))

            local hasGlass = targetPlayer:GetAttribute("__OwnsGlassManufacturerVision")
            LabelGlass:SetText("玻璃透视: " .. (hasGlass and "√" or "X"))

            local hasEmotePages = targetPlayer:GetAttribute("__OwnsEmotePages")
            LabelEmotePages:SetText("动作页: " .. (hasEmotePages and "√" or "X"))

            local hasCustomTag = targetPlayer:GetAttribute("__OwnsCustomPlayerTag")
            LabelCustomTag:SetText("自定义标签: " .. (hasCustomTag and "√" or "X"))

            local hasLighter = targetPlayer:GetAttribute("HasLighter")
            LabelLighter:SetText("打火机: " .. (hasLighter and "√" or "X"))

            local boostData = targetPlayer:GetAttribute("_BoostData")
            if boostData then
                if type(boostData) == "string" then
                    boostData = HttpService:JSONDecode(boostData)
                end
                LabelSprint:SetText("速度等级: " .. tostring(boostData["Faster Sprint"]))
                LabelDamage:SetText("力量等级: " .. tostring(boostData["Damage Boost"]))
                LabelWonBoost:SetText("金钱等级: " .. tostring(boostData["Won Boost"]))
            else
                LabelSprint:SetText("速度等级: …")
                LabelDamage:SetText("力量等级: …")
                LabelWonBoost:SetText("金钱等级: …")
            end
        else
            LabelA:SetText("名字: 未选择")
            LabelDisplayName:SetText("用户名: 未选择")
            LabelWim:SetText("金钱: 未选择")
            LabelLevel:SetText("等级: 未选择")
            LabelWins:SetText("胜场: 未选择")
            LabelSprint:SetText("速度等级: 未选择")
            LabelDamage:SetText("力量等级: 未选择")
            LabelWonBoost:SetText("金钱等级: 未选择")
            LabelAFK:SetText("挂机世界币: 未选择")
            LabelVIP:SetText("VIP: 未选择")
            Label2xVote:SetText("2倍投票: 未选择")
            LabelPSPlus:SetText("私服: 未选择")
            LabelGlass:SetText("玻璃透视: 未选择")
            LabelEmotePages:SetText("动作页: 未选择")
            LabelCustomTag:SetText("自定义标签: 未选择")
            LabelLighter:SetText("打火机: 未选择")
            LabelRobux:SetText("捐赠Robux: 未选择")
        end
    end)
end
})
--娱乐功能
local YLgn = Tabs.Ylgn:AddLeftGroupbox("| 娱乐", "traffic-cone")
local SoulRingFolder = Tabs.Ylgn:AddRightGroupbox("| 其他娱乐功能", "utensils")
YLgn:AddLabel("使用此功能先把最下面的无头，和删除头发打开\n\n芙宁娜皮肤美化", true)
do
local Players          = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService     = game:GetService("TweenService")
local localPlayer      = Players.LocalPlayer
local localPlayer2     = localPlayer
local LocalPlayer      = localPlayer
local function PlayToggleSound() end
local function PlayBell() end
local function PlayErrorSound() end
local function notify(title, text, duration)
    if Library and Library.Notify then
        Library:Notify({
            Title = tostring(title),
            Description = tostring(text or ""),
            Time = tonumber(duration) or 0.9,
        })
    else
        print("[Notify]", title, text)
    end
end
local function findCharacter()
    local cam = workspace.CurrentCamera
    if cam and cam.CameraSubject then
        local subject = cam.CameraSubject
        if subject and subject:IsA("Humanoid") then
            return subject.Parent
        end
    end
    for _, child in pairs(workspace:GetChildren()) do
        if child:FindFirstChild("Humanoid") and child:FindFirstChild("Head") then
            if not string.find(child.Name:lower(), "badpreload")
                and not string.find(child.Name:lower(), "preload") then
                return child
            end
        end
    end
    return nil
end
local function attachItem(assetId, part0)
    local ok, result = pcall(function()
        return game:GetObjects("rbxassetid://" .. tostring(assetId))[1]
    end)
    if ok and result then
        local handle = result:FindFirstChild("Handle")
        if handle then
            local attachment = handle:FindFirstChildOfClass("Attachment")
            if attachment then
                local target = part0:FindFirstChild(attachment.Name)
                if target then
                    local weld = Instance.new("Weld")
                    weld.Part0 = part0
                    weld.Part1 = handle
                    weld.C0 = target.CFrame
                    weld.C1 = attachment.CFrame
                    weld.Parent = handle
                else
                    local weld = Instance.new("Weld")
                    weld.Part0 = part0
                    weld.Part1 = handle
                    weld.C0 = CFrame.new()
                    weld.C1 = CFrame.new()
                    weld.Parent = handle
                end
            else
                local weld = Instance.new("Weld")
                weld.Part0 = part0
                weld.Part1 = handle
                weld.C0 = CFrame.new()
                weld.C1 = CFrame.new()
                weld.Parent = handle
            end
            handle.CanCollide = false
            result.Parent = part0.Parent
            print("[VisualItems] Added: " .. tostring(assetId))
        else
            warn("[VisualItems] No Handle in: " .. tostring(assetId))
        end
    else
        warn("[VisualItems] Failed to load: " .. tostring(assetId))
    end
end
local function getPart(character, partNames)
    for _, name in ipairs(partNames) do
        local part = character:FindFirstChild(name)
        if part then return part end
    end
    return nil
end
local visualConnections = {}
local function makeVisualToggle(toggleId, displayText, assetId, partNames)
    YLgn:AddToggle(toggleId, {
        Text = displayText,
        Tooltip = "本地视觉装饰，仅自己可见",
        DisabledTooltip = "该功能已禁用",
        Default = false,
        Disabled = false,
        Visible = true,
        Risky = false,
        Callback = function(Value)
            if visualConnections[toggleId] then
                visualConnections[toggleId]:Disconnect()
                visualConnections[toggleId] = nil
            end
            if Value then
                local function apply()
                    local character = findCharacter()
                    if not character then return end
                    local part = getPart(character, partNames)
                    if not part then return end
                    attachItem(assetId, part)
                end
                apply()
                visualConnections[toggleId] = localPlayer2.CharacterAdded:Connect(function()
                    task.wait(1)
                    if Value then
                        apply()
                    end
                end)
            end
            PlayToggleSound()
            print("[回调] " .. displayText .. " 状态改变:", Value)
        end,
    })
end
makeVisualToggle("VisualBackSword",     "背上的剑",   18341157834,     {"UpperTorso", "Torso"})
makeVisualToggle("VisualSkirt",         "裙摆",       131920867550926, {"LowerTorso", "Torso"})
makeVisualToggle("VisualHat",           "帽子",       13944489559,     {"Head"})
makeVisualToggle("VisualHealthBar",     "血条装饰",   102940337933053, {"Head", "UpperTorso", "Torso"})
makeVisualToggle("VisualHead",          "头部",       10715284563,     {"Head"})
makeVisualToggle("VisualFace",          "面部",       14583408627,     {"Head"})
makeVisualToggle("VisualHair",          "头发",       14452957388,     {"Head"})
makeVisualToggle("VisualButterflyBelt", "蝴蝶腰带",   18327052648,     {"LowerTorso", "Torso"})
makeVisualToggle("VisualPants",         "裤子",       12134415767,     {"LowerTorso", "Torso"})
makeVisualToggle("VisualShirt",         "上衣",       12134585088,     {"UpperTorso", "Torso"})
local function applyNoHead()
    local char = LocalPlayer.Character
    if not char then return end
    local head = char:FindFirstChild("Head")
    if head then
        head.Transparency = 1
        head.Size = Vector3.new(0.1, 0.1, 0.1)
        local mesh = head:FindFirstChildOfClass("SpecialMesh")
        if mesh then mesh:Destroy() end
        for _, acc in ipairs(head:GetChildren()) do
            if acc:IsA("Accessory") or acc:IsA("Hat") then
                acc:Destroy()
            end
        end
    end
    notify("无头已应用", "头部已隐藏", 2)
end
YLgn:AddToggle("NoHeadToggle", {
    Text = "无头",
    Tooltip = "隐藏头部并删除头部配件",
    DisabledTooltip = "该功能已禁用",
    Default = false,
    Disabled = false,
    Visible = true,
    Risky = false,
    Callback = function(Value)
        if Value then
            applyNoHead()
        end
        PlayToggleSound()
        print("[回调] 无头 状态改变:", Value)
    end,
})
local function applyRemoveHair()
    local char = LocalPlayer.Character
    if not char then return end
    local head = char:FindFirstChild("Head")
    if not head then
        notify("删除头发失败", "找不到头部", 2)
        return
    end
    local removed = 0
    for _, acc in ipairs(head:GetChildren()) do
        if acc:IsA("Accessory") or acc:IsA("Hat") then
            acc:Destroy()
            removed = removed + 1
        end
    end
    for _, mesh in ipairs(head:GetChildren()) do
        if mesh:IsA("SpecialMesh") then
            local meshId = mesh.MeshId or ""
            local textureId = mesh.TextureId or ""
            local lowerMesh = string.lower(meshId)
            local lowerTex = string.lower(textureId)
            if string.find(lowerMesh, "hair")
                or string.find(lowerMesh, "hairaccessory")
                or string.find(lowerTex, "hair") then
                mesh:Destroy()
                removed = removed + 1
            end
        end
    end
    for _, obj in ipairs(char:GetChildren()) do
        if obj:IsA("Accessory") then
            local name = string.lower(obj.Name)
            if string.find(name, "hair") then
                obj:Destroy()
                removed = removed + 1
            end
        end
    end
    if removed > 0 then
        notify("删除头发已应用", "移除了 " .. tostring(removed) .. " 个头发配件", 2)
    else
        notify("删除头发已应用", "未找到头发配件", 2)
    end
end
YLgn:AddToggle("RemoveHairToggle", {
    Text = "删除头发",
    Tooltip = "删除角色原有的头发配件",
    DisabledTooltip = "该功能已禁用",
    Default = false,
    Disabled = false,
    Visible = true,
    Risky = false,
    Callback = function(Value)
        if Value then
            applyRemoveHair()
        end
        PlayToggleSound()
        print("[回调] 删除头发 状态改变:", Value)
    end,
})
end
--魂环
do    
local Players     = game:GetService("Players")
local RunService  = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local CONFIG = {
    enabled         = false,
    ringCount       = 3,
    baseRadius      = 2.6,
    ringSpacing     = 0.95,
    footOffset      = -2.8,
    headOffset      = 6.0,
    spinSpeed       = 90,
    nodeSize        = 0.28,
    lineWidth       = 0.075,
    nodeSpacing     = 1.15,
    maxNodesPerRing = 40,
    transparency    = 0.10,
    animSpeed       = 4.5,
    useCustomColor  = false,
    customColor     = Color3.fromRGB(120, 180, 255),
    hueSpeed        = 0,
    rainbowMode     = false,
}
local MAX_RINGS = 10
local ringFolder
local rings = {}
local lastRight, lastLook
local angle = 0
local clock = 0
local function getRingColor(index)
    if CONFIG.useCustomColor then
        return CONFIG.customColor
    end
    local hue = ((index - 1) * 0.618033988) % 1
    if CONFIG.rainbowMode then
        hue = (hue + tick() * CONFIG.hueSpeed) % 1
    end
    return Color3.fromHSV(hue, 0.62, 1)
end
local function buildAllRings(preserveProgress)
    local savedProgress = {}
    if preserveProgress and rings then
        for i, r in ipairs(rings) do
            savedProgress[i] = r.progress
        end
    end
    if ringFolder then pcall(function() ringFolder:Destroy() end) end
    ringFolder = Instance.new("Folder")
    ringFolder.Name = "SoulRingV3"
    ringFolder.Parent = workspace
    rings = {}
    for i = 1, MAX_RINGS do
        local R = math.max(0.6, CONFIG.baseRadius + (i - 1) * CONFIG.ringSpacing)
        local n = math.floor((2 * math.pi * R) / CONFIG.nodeSpacing + 0.5)
        n = math.clamp(n, 8, CONFIG.maxNodesPerRing)
        local color = getRingColor(i)
        local ring = {
            index    = i,
            radius   = R,
            count    = n,
            phase    = (i - 1) * 0.22,
            color    = color,
            progress = savedProgress[i] or 0,
            nodes    = table.create(n),
            lines    = table.create(n),
        }
        for k = 1, n do
            local node = Instance.new("Part")
            node.Name       = "Node"
            node.Shape      = Enum.PartType.Ball
            node.Size       = Vector3.new(CONFIG.nodeSize, CONFIG.nodeSize, CONFIG.nodeSize)
            node.Material   = Enum.Material.Neon
            node.Color      = color
            node.Transparency = 1
            node.Anchored   = true
            node.CanCollide = false
            node.CanTouch   = false
            node.CanQuery   = false
            node.CastShadow = false
            node.Parent     = ringFolder
            ring.nodes[k] = node
        end
        for k = 1, n do
            local line = Instance.new("Part")
            line.Name       = "Line"
            line.Shape      = Enum.PartType.Cylinder
            line.Size       = Vector3.new(1, CONFIG.lineWidth, CONFIG.lineWidth)
            line.Material   = Enum.Material.Neon
            line.Color      = color
            line.Transparency = 1
            line.Anchored   = true
            line.CanCollide = false
            line.CanTouch   = false
            line.CanQuery   = false
            line.CastShadow = false
            line.Parent     = ringFolder
            ring.lines[k] = line
        end
        rings[i] = ring
    end
end
local function getHRP()
    local char = LocalPlayer.Character
    return char and char:FindFirstChild("HumanoidRootPart")
end
local function getFlatBasis(hrp)
    local right = hrp.CFrame.RightVector
    local look  = hrp.CFrame.LookVector
    right = Vector3.new(right.X, 0, right.Z)
    look  = Vector3.new(look.X,  0, look.Z)
    if right.Magnitude < 0.001 then
        right = lastRight or Vector3.new(1, 0, 0)
    else
        right = right.Unit
        lastRight = right
    end
    if look.Magnitude < 0.001 then
        look = lastLook or Vector3.new(0, 0, -1)
    else
        look = look.Unit
        lastLook = look
    end
    return right, look
end
RunService.RenderStepped:Connect(function(dt)
    if not ringFolder then return end
    local anyVisible = false
    for _, ring in ipairs(rings) do
        local want = (CONFIG.enabled and ring.index <= CONFIG.ringCount) and 1 or 0
        local diff = want - ring.progress

        if math.abs(diff) > 0.0005 then
            ring.progress = ring.progress + diff * math.clamp(dt * CONFIG.animSpeed, 0, 1)
        else
            ring.progress = want
        end
        if ring.progress > 0.005 then anyVisible = true end
    end
    if not anyVisible then
        if ringFolder.Parent then ringFolder.Parent = nil end
        return
    end
    if not ringFolder.Parent then ringFolder.Parent = workspace end
    local hrp = getHRP()
    if not hrp then return end
    clock = clock + dt
    angle = angle + math.rad(CONFIG.spinSpeed) * dt
    local right, look = getFlatBasis(hrp)
    local basePos = hrp.Position
    for _, ring in ipairs(rings) do
        local p = ring.progress
        if p > 0.005 then
            local e = p * p * (3 - 2 * p)
            local yOff = CONFIG.headOffset + (CONFIG.footOffset - CONFIG.headOffset) * e
            local center = basePos + Vector3.new(0, yOff, 0)
            local alpha = CONFIG.transparency + (1 - e) * 0.9
            if alpha > 0.98 then alpha = 1 end
            local R     = ring.radius
            local n     = ring.count
            local phase = ring.phase
            local liveColor
            if CONFIG.rainbowMode then
                liveColor = Color3.fromHSV((ring.index * 0.13 + tick() * CONFIG.hueSpeed) % 1, 0.62, 1)
            elseif CONFIG.useCustomColor then
                liveColor = CONFIG.customColor
            else
                liveColor = ring.color
            end
            local positions = table.create(n)
            for k = 1, n do
                local a = angle + phase + ((k - 1) / n) * math.pi * 2
                local pos = center + right * (math.sin(a) * R) + look * (math.cos(a) * R)
                positions[k] = pos
                local node = ring.nodes[k]
                node.CFrame = CFrame.new(pos)
                node.Transparency = alpha
                node.Color = liveColor
            end
            for k = 1, n do
                local j = (k % n) + 1
                local p1, p2 = positions[k], positions[j]
                local mid  = (p1 + p2) * 0.5
                local dv   = p2 - p1
                local dist = dv.Magnitude
                local line = ring.lines[k]
                if dist > 0.001 then
                    line.Size = Vector3.new(dist, CONFIG.lineWidth, CONFIG.lineWidth)
                    line.CFrame = CFrame.lookAt(mid, mid + dv.Unit)
                        * CFrame.Angles(0, math.rad(90), 0)
                end
                line.Transparency = alpha
                line.Color = liveColor
            end
        end
    end
end)
LocalPlayer.CharacterAdded:Connect(function()
    angle = 0
    clock = 0
    lastRight, lastLook = nil, nil

    if rings then
        for _, r in ipairs(rings) do
            r.progress = 0
        end
    end

    if ringFolder then
        ringFolder.Parent = workspace
    else
        buildAllRings(false)
    end
end)

LocalPlayer.CharacterRemoving:Connect(function()
    if ringFolder then ringFolder.Parent = nil end
end)
SoulRingFolder:AddToggle("SoulRingEnabled", {
    Text = "启用魂环",
    Default = false,
    Tooltip = "开启或关闭魂环显示",
    Callback = function(Value)
        CONFIG.enabled = Value
    end,
})
SoulRingFolder:AddSlider("SoulRingCount", {
    Text = "环数",
    Default = 3,
    Min = 1,
    Max = 10,
    Rounding = 0,
    Compact = false,
    Tooltip = "显示的环数量",
    Callback = function(Value)
        CONFIG.ringCount = Value
    end,
})
SoulRingFolder:AddSlider("SoulRingSize", {
    Text = "大小（最内圈半径）",
    Default = 2.6,
    Min = 0.8,
    Max = 12.0,
    Rounding = 1,
    Compact = false,
    Tooltip = "最内圈半径",
    Callback = function(Value)
        CONFIG.baseRadius = Value
        buildAllRings(true)
    end,
})
SoulRingFolder:AddSlider("SoulRingSpacing", {
    Text = "环间距",
    Default = 0.95,
    Min = 0.2,
    Max = 3.0,
    Rounding = 2,
    Compact = false,
    Tooltip = "每向外一圈增加的半径",
    Callback = function(Value)
        CONFIG.ringSpacing = Value
        buildAllRings(true)
    end,
})
SoulRingFolder:AddSlider("SoulRingSpin", {
    Text = "旋转速度",
    Default = 90,
    Min = 0,
    Max = 360,
    Rounding = 0,
    Compact = false,
    Suffix = "°/s",
    Tooltip = "环的旋转速度",
    Callback = function(Value)
        CONFIG.spinSpeed = Value
    end,
})
SoulRingFolder:AddSlider("SoulRingAnimSpeed", {
    Text = "下落 / 上升速度",
    Default = 4.5,
    Min = 0.5,
    Max = 20,
    Rounding = 1,
    Compact = false,
    Tooltip = "环下落和上升的动画速度",
    Callback = function(Value)
        CONFIG.animSpeed = Value
    end,
})
SoulRingFolder:AddSlider("SoulRingTransparency", {
    Text = "稳定后透明度",
    Default = 0.10,
    Min = 0,
    Max = 1,
    Rounding = 2,
    Compact = false,
    Tooltip = "环稳定后的透明度（0 完全不透明）",
    Callback = function(Value)
        CONFIG.transparency = Value
    end,
})
SoulRingFolder:AddSlider("SoulRingHeadOffset", {
    Text = "头顶起始高度",
    Default = 6.0,
    Min = 1,
    Max = 20,
    Rounding = 1,
    Compact = false,
    Tooltip = "环下落的起始高度（相对角色）",
    Callback = function(Value)
        CONFIG.headOffset = Value
    end,
})
SoulRingFolder:AddSlider("SoulRingFootOffset", {
    Text = "脚下最终偏移",
    Default = -2.8,
    Min = -10,
    Max = 0,
    Rounding = 1,
    Compact = false,
    Tooltip = "环停止位置（相对角色）",
    Callback = function(Value)
        CONFIG.footOffset = Value
    end,
})
SoulRingFolder:AddSlider("SoulRingNodeSize", {
    Text = "节点大小",
    Default = 0.28,
    Min = 0.05,
    Max = 1,
    Rounding = 2,
    Compact = false,
    Tooltip = "每个小球节点的大小",
    Callback = function(Value)
        CONFIG.nodeSize = Value
        buildAllRings(true)
    end,
})
SoulRingFolder:AddSlider("SoulRingLineWidth", {
    Text = "连线粗细",
    Default = 0.075,
    Min = 0.01,
    Max = 0.5,
    Rounding = 3,
    Compact = false,
    Tooltip = "连线 Cylinder 的粗细",
    Callback = function(Value)
        CONFIG.lineWidth = Value
    end,
})
SoulRingFolder:AddSlider("SoulRingNodeSpacing", {
    Text = "节点弧长间距",
    Default = 1.15,
    Min = 0.3,
    Max = 3.0,
    Rounding = 2,
    Compact = false,
    Tooltip = "同一圈相邻节点的间距",
    Callback = function(Value)
        CONFIG.nodeSpacing = Value
        buildAllRings(true)
    end,
})
SoulRingFolder:AddToggle("SoulRingUseCustomColor", {
    Text = "使用自定义颜色",
    Default = false,
    Tooltip = "启用后所有环使用同一自定义颜色",
    Callback = function(Value)
        CONFIG.useCustomColor = Value
        buildAllRings(true)
    end,
})
SoulRingFolder:AddLabel("自定义颜色"):AddColorPicker("SoulRingColorPicker", {
    Default = Color3.fromRGB(120, 180, 255),
    Title = "魂环颜色",
    Transparency = 0,
    Callback = function(Value)
        CONFIG.customColor = Value
        buildAllRings(true)
    end,
})
SoulRingFolder:AddToggle("SoulRingRainbowMode", {
    Text = "彩虹模式",
    Default = false,
    Tooltip = "根据时间流动色相，每个环不同色",
    Callback = function(Value)
        CONFIG.rainbowMode = Value
    end,
})
SoulRingFolder:AddSlider("SoulRingHueSpeed", {
    Text = "彩虹流速",
    Default = 0,
    Min = 0,
    Max = 1,
    Rounding = 2,
    Compact = false,
    Tooltip = "彩虹模式下的色相流动速度（0 为静止）",
    Callback = function(Value)
        CONFIG.hueSpeed = Value
    end,
})
SoulRingFolder:AddButton({
    Text = "重置所有参数",
    Func = function()
        CONFIG.baseRadius      = 2.6
        CONFIG.ringSpacing     = 0.95
        CONFIG.nodeSize        = 0.28
        CONFIG.lineWidth       = 0.075
        CONFIG.nodeSpacing     = 1.15
        CONFIG.spinSpeed       = 90
        CONFIG.animSpeed       = 4.5
        CONFIG.transparency    = 0.10
        CONFIG.headOffset      = 6.0
        CONFIG.footOffset      = -2.8
        CONFIG.useCustomColor  = false
        CONFIG.rainbowMode     = false
        CONFIG.hueSpeed        = 0
        buildAllRings(true)
        Library:Notify({
            Title = "魂环 V3",
            Description = "已重置所有参数",
            Time = 3,
        })
    end,
    DoubleClick = false,
    Tooltip = "将所有参数恢复默认值",
})
buildAllRings(false)
end

local GuardGroup = Tabs.Swgn:AddLeftGroupbox("| 守卫功能", "shield")
local Zdxg = Tabs.Swgn:AddRightGroupbox("| 子弹修改", "utensils")
local LeftGB = Tabs.Swgn:AddRightGroupbox("|通行证&守卫", "utensils")
local RightGB = Tabs.Swgn:AddRightGroupbox("|守卫攻击", "utensils")

do
local Players           = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService      = game:GetService("SoundService")
local localPlayer       = Players.LocalPlayer

local function playSound()
pcall(function()
    local sound = Instance.new("Sound")
    sound.SoundId = "rbxassetid://99979147606311"
    sound.Volume = 5
    sound.Parent = SoundService
    sound:Play()
    sound.Ended:Once(function() sound:Destroy() end)
end)
end

local function get_character()
return localPlayer.Character
end

GuardGroup:AddToggle("ArcadeAutoFarm", {
Text = "无限刷钱",
Default = false,
Tooltip = "街机自动获胜循环刷钱",
Callback = (function()
    local enabled     = false
    local task_       = nil
    local currentGame = nil
    local consoleCache = nil

    local function findConsole()
        if consoleCache and consoleCache.Parent then
            return consoleCache
        end
        for _, v in workspace:GetDescendants() do
            local screen = v:FindFirstChild("Screen")
            if screen and screen:FindFirstChild("SurfaceGui") then
                consoleCache = v
                return v
            end
        end
        return nil
    end

    local function runArcade()
        local ok, result = pcall(function()
            return require(ReplicatedStorage.Modules.PlayableArcadeGame)
        end)
        if not ok or not result then return end

        local v = findConsole()
        if not v then return end

        local character = get_character()
        if not character then return end
        local root = character:FindFirstChild("HumanoidRootPart")
        if not root then return end

        if currentGame then
            pcall(function()
                currentGame.Stopping = true
                currentGame:Destroy()
            end)
            currentGame = nil
        end

        local game = result.new(v, root)
        currentGame = game
        game:start()

        local now = os.clock()
        while game.State ~= "Running" and os.clock() - now < 3 do
            if not enabled then return end
            task.wait()
        end

        if not enabled then return end

        if game.State ~= "Running" then
            pcall(function() game:Destroy() end)
            currentGame = nil
            return
        end

        game.Score = 4499
        if game.ScoreLabel then
            game.ScoreLabel.Text = "Score: 4499"
        end

        table.clear(game.CalculateScore)
        for _ = 1, 99 do
            table.insert(game.CalculateScore, "Coin")
        end
        game:win("You Won! Congrats! :D")
    end

    return function(Value)
        enabled = Value and true or false

        if task_ then
            pcall(function() task.cancel(task_) end)
            task_ = nil
        end

        if not enabled then
            if currentGame then
                pcall(function()
                    currentGame.Stopping = true
                    currentGame:Destroy()
                end)
                currentGame = nil
            end
            playSound()
            return true
        end

        task_ = task.spawn(function()
            while enabled do
                pcall(runArcade)

                if enabled then
                    task.wait(1)
                    continue
                end

                break
            end
            task_ = nil
        end)

        playSound()
        return true
    end
end)(),
})
end

do
local Players           = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer       = Players.LocalPlayer

local function Notify(Title, Description, Time)
Library:Notify({ Title = Title, Description = Description, Time = Time or 3 })
end

local function IsRebelOrGuard(Model)
if not Model or not Model.Name then return false end
local Name  = Model.Name
local Lower = string.lower(Name)
return string.find(Name, "RebelGuard")
or string.find(Name, "FinalRebel")
or string.find(Name, "RebelFirstWave")
or string.find(Name, "HallwayGuard")
or string.find(Lower, "aggro")
end

local function Wallcheck(Origin, Target, IgnoreChar)
local Delta = Target - Origin
local Params = RaycastParams.new()
Params.FilterType = Enum.RaycastFilterType.Exclude
local Filter = {}
local Character = LocalPlayer.Character
if Character then
table.insert(Filter, Character)
end
table.insert(Filter, IgnoreChar)
Params.FilterDescendantsInstances = Filter
return workspace:Raycast(Origin, Delta.Unit * Delta.Magnitude, Params) ~= nil
end

local function GetCurrentGun()
local Character = LocalPlayer.Character
local Tools = {}
if Character then
for _, Item in ipairs(Character:GetChildren()) do
if Item:IsA("Tool") then
    table.insert(Tools, Item)
end
end
end
if LocalPlayer.Backpack then
for _, Item in ipairs(LocalPlayer.Backpack:GetChildren()) do
if Item:IsA("Tool") then
    table.insert(Tools, Item)
end
end
end
if #Tools == 0 then return nil end
local Weapons = ReplicatedStorage:FindFirstChild("Weapons")
if not Weapons then return nil end
local Guns = Weapons:FindFirstChild("Guns")
if not Guns then return nil end

for _, Tool in ipairs(Tools) do
if Guns:FindFirstChild(Tool.Name) then
return Tool
end
end
return nil
end

local function GetFireRate(GunName)
local Weapons = ReplicatedStorage:FindFirstChild("Weapons")
if not Weapons then return 0.1 end
local Guns = Weapons:FindFirstChild("Guns")
if not Guns then return 0.1 end
local Gun = Guns:FindFirstChild(GunName)
if not Gun then return 0.1 end
local CD = Gun:FindFirstChild("FireRateCD")
if CD and CD:IsA("NumberValue") then
return CD.Value
end
return 0.1
end

local function IsRagdolled()
local Character = LocalPlayer.Character
if not Character then return false end
return Character:FindFirstChild("Ragdoll") ~= nil
end

local function GetCurrentGame()
local CurrentGame = workspace:FindFirstChild("Values")
and workspace.Values:FindFirstChild("CurrentGame")
if CurrentGame and CurrentGame.Value and CurrentGame.Value ~= "" and CurrentGame.Value ~= "unknown" then
return CurrentGame.Value
end
if workspace:FindFirstChild("LightsOut")     then return "LightsOut"    end
if workspace:FindFirstChild("JumpRope")      then return "JumpRope"     end
if workspace:FindFirstChild("GlassBridge")   then return "GlassBridge"  end
if workspace:FindFirstChild("MingleMap")     then return "Mingle"       end
if workspace:FindFirstChild("HideAndSeekMap")then return "HideAndSeek"  end
if workspace:FindFirstChild("SkySquidGamesMap") then return "SkySquidGame" end
local Live = workspace:FindFirstChild("Live")
if Live then
for _, Model in pairs(Live:GetChildren()) do
if IsRebelOrGuard(Model) then
    return "RebelChance"
end
end
local PlayerGui = LocalPlayer:FindFirstChild("PlayerGui")
if PlayerGui
and PlayerGui:FindFirstChild("ImpactFrames")
and PlayerGui.ImpactFrames:FindFirstChild("RebelPlayerVsGuards") then
return "RebelChance"
end
end
return nil
end
GuardGroup:AddDivider()
do
local enabled     = false
local thread      = nil
local lastShot    = 0
local currentTool = nil
local called      = {}
local function drawShootLine(posA, posB)
if not Options.ShootLine.Value then return end
local mid       = (posA + posB) / 2
local len       = (posB - posA).Magnitude
local dir       = (posB - posA).Unit
local thickness = Options.ShootLineThickness.Value
local duration  = Options.ShootLineDuration.Value
local color     = Options.ShootLineColor.Value
local line = Instance.new("Part")
line.Name        = "ShootLine_VW"
line.Anchored    = true
line.CanCollide  = false
line.CanQuery    = false
line.CastShadow  = false
line.Size        = Vector3.new(thickness, thickness, len)
line.CFrame      = CFrame.lookAt(mid, mid + dir)
line.Material    = Enum.Material.Neon
line.Color       = color
line.Transparency = 0
line.Parent      = workspace
local steps    = 20
local stepTime = duration / steps
task.spawn(function()
for i = 1, steps do
    task.wait(stepTime)
    if not (line and line.Parent) then break end
    line.Transparency = i / steps
end
if line and line.Parent then
    line:Destroy()
end
end)
end
local function waitForRagdollEnd()
if not Options.RagdollCheck.Value then return false end
if IsRagdolled() then
Notify("守卫", "检测到 Ragdoll，等待中...", 3)
while enabled and IsRagdolled() do
    task.wait(0.1)
end
Notify("守卫", "Ragdoll 结束，继续射击", 3)
return true
end
return false
end       
local function collectTargets()
local Live = workspace:FindFirstChild("Live")
if not Live then return {} end
local targets = {}
for _, Model in ipairs(Live:GetChildren()) do
if Model:IsA("Model") then
    local Humanoid = Model:FindFirstChildOfClass("Humanoid")
    if Humanoid and Humanoid.Health > 0
        and Model:FindFirstChild("GuardCanKill") ~= nil then
        table.insert(targets, Model)
    end
end
end
return targets
end
local function getTargetHit(Model)
local Head = Model:FindFirstChild("Head")
if Head then return Head.Position, Head, "Head" end
local Root = Model:FindFirstChild("HumanoidRootPart")
if Root then return Root.Position, Root, "HumanoidRootPart" end
local Torso = Model:FindFirstChild("Torso") or Model:FindFirstChild("UpperTorso")
if Torso then return Torso.Position, Torso, Torso.Name end
return nil, nil, nil
end
local function lockToTarget(targetModel)
local Character = LocalPlayer.Character
if not Character then return false end
local targetPos = getTargetHit(targetModel)
if not targetPos then return false end
local Camera = workspace.CurrentCamera
if not Camera then return false end
Camera.CFrame = CFrame.lookAt(Camera.CFrame.Position, targetPos)
local Root = Character:FindFirstChild("HumanoidRootPart")
if Root then
local Flat = Vector3.new(targetPos.X, Root.Position.Y, targetPos.Z)
if (Flat - Root.Position).Magnitude > 0.01 then
    Root.CFrame = CFrame.lookAt(Root.Position, Flat)
end
end
return true
end
local function fireRemote(RemoteName)
local Remote = ReplicatedStorage:FindFirstChild("Remotes")
and ReplicatedStorage.Remotes:FindFirstChild(RemoteName)
if Remote then
pcall(function() Remote:FireServer() end)
return true
end
return false
end     
local function shootTarget(tool, targetModel)
local Character = LocalPlayer.Character
if not Character then return false end

local targetPos, targetPart, partName = getTargetHit(targetModel)
if not targetPos then return false end
local myHead = Character:FindFirstChild("Head")
or Character:FindFirstChild("HumanoidRootPart")
if not myHead then return false end
local myPos = myHead.Position          
if Options.WallCheck.Value then
if Wallcheck(myPos, targetPos, targetModel) then
    return false
end
end
local dir    = (targetPos - myPos).Unit
local lookCF = CFrame.lookAt(myPos, targetPos)
local args = {
tool,
{
    ClientRayNormal     = dir,
    FiredGun            = true,
    bulletCF            = lookCF,
    ClientRayInstance   = targetPart or targetModel,
    SecondaryHitTargets = {},
    ClientRayPosition   = targetPos,
    HitTargets          = { [targetModel.Name] = partName or "Head" },
    bulletSizeC         = Vector3.new(0.01, 0.01, 60.046),
    NoMuzzleFX          = true,
    FirePosition        = myPos,
},
}
local ok = pcall(function()
ReplicatedStorage:WaitForChild("Remotes")
    :WaitForChild("FiredGunClient")
    :FireServer(unpack(args))
end)

if ok then
drawShootLine(myPos, targetPos)
end
return ok
end
GuardGroup:AddToggle("AutoLockMarkedPlayers", {
Text = "自动锁定标记玩家",
Tooltip = "自动锁定被标记玩家视角并开火，打一枪换下一个目标",
Default = false,
Callback = function(Value)
enabled = Value and true or false
if thread then
    pcall(function() task.cancel(thread) end)
    thread = nil
end
if not enabled then
    Notify("守卫", "自动锁定标记玩家 已禁用", 3)
    return
end
lastShot    = 0
currentTool = nil
called      = {}
thread = task.spawn(function()
    local shotCount = 0
    local index     = 1
    while enabled do
        pcall(function()
            if Options.RagdollCheck.Value and IsRagdolled() then
                waitForRagdollEnd()
            end
            currentTool = GetCurrentGun()
            if not currentTool then
                task.wait(0.5)
                return
            end
            local fireRate = GetFireRate(currentTool.Name)
            local targets  = collectTargets()
            if #targets == 0 then
                called = {}
                index  = 1
                task.wait(0.15)
                return
            end
            if index > #targets then
                index = 1
            end
            local target = targets[index]
            local now = tick()
            if now - lastShot < fireRate then
                return
            end
            if not called[target.Name] then
                local d = Options.ShootCallDelay.Value
                if d and d > 0 then
                    task.wait(d)
                end
                fireRemote("GuardCanKill")
                called[target.Name] = true
                Notify("守卫", "已触发 GuardCanKill → " .. target.Name, 2)
            end
            lockToTarget(target)
            if shootTarget(currentTool, target) then
                lastShot   = tick()
                shotCount += 1
                Notify("守卫", "已锁定击杀 " .. target.Name .. " (第 " .. shotCount .. " 发)", 2)
                index += 1
                if index > #targets then
                    index = 1
                end
            end
        end)
        task.wait(0.05)
    end
end)
Notify("守卫", "自动锁定标记玩家 已启用", 3)
end,
})
GuardGroup:AddToggle("WallCheck", {
Text = "穿墙检测",
Tooltip = "开启后不会穿墙射击；关闭即可全图远程击杀",
Default = false,
Callback = function(Value)
Notify("守卫", Value and "穿墙检测 已启用 - 不会穿墙射击" or "穿墙检测 已禁用", 3)
end,
})
GuardGroup:AddToggle("ShootLine", {
Text = "射击连线",
Tooltip = "射击时显示一条指向目标的连线",
Default = false,
Callback = function(Value)
if not Value then
    for _, Obj in ipairs(workspace:GetChildren()) do
        if Obj.Name == "ShootLine_VW" then
            Obj:Destroy()
        end
    end
end
Notify("守卫", Value and "射击连线 已启用" or "射击连线 已禁用", 3)
end,
}):AddColorPicker("ShootLineColor", {
Default = Color3.fromRGB(255, 50, 50),
Title = "射击连线颜色",
Callback = function(Value)
print("[回调] 射击连线颜色改变:", Value)
end,
})
GuardGroup:AddSlider("ShootLineThickness", {
Text = "连线粗细",
Default = 0.05,
Min = 0.02,
Max = 0.5,
Rounding = 2,
Suffix = " st",
Tooltip = "射击连线的粗细",
})
GuardGroup:AddSlider("ShootLineDuration", {
Text = "连线持续时间",
Default = 1,
Min = 0.5,
Max = 3,
Rounding = 1,
Suffix = "s",
Tooltip = "射击连线淡出前保持可见的时间",
})
GuardGroup:AddSlider("ShootCallDelay", {
Text = "射击调用延迟",
Default = 0.5,
Min = 0,
Max = 2,
Rounding = 1,
Suffix = "s",
Tooltip = "首次检测到目标时触发 GuardCanKill 前的延迟",
Callback = function(Value)
print("[回调] 射击调用延迟改变为:", Value, "秒")
end,
})
GuardGroup:AddSlider("DistanceCheck", {
Text = "距离检查",
Default = 100,
Min = 5,
Max = 3000,
Rounding = 0,
Suffix = " studs",
Tooltip = "已废弃：远程击杀模式忽略距离",
Callback = function(Value)
print("[回调] 距离检查改变为:", Value, "studs")
end,
})
end
do
local enabled = false
local thread  = nil
local lastAbsoluteSize = Vector2.new(271.35000610351562, 271.35000610351562)
GuardGroup:AddToggle("AutoPingPong", {
Text = "自动乒乓球 QTE",
Tooltip = "自动完成乒乓球 QTE",
Default = false,
Callback = function(Value)
enabled = Value and true or false
if thread then
    pcall(function() task.cancel(thread) end)
    thread = nil
end
if not enabled then
    Notify("守卫", "自动乒乓球 已禁用", 2)
    return
end
lastAbsoluteSize = Vector2.new(271.35000610351562, 271.35000610351562)
thread = task.spawn(function()
    while enabled do
        local ok, err = pcall(function()
            local Size = LocalPlayer:WaitForChild("PlayerGui")
                :WaitForChild("ImpactFrames")
                :WaitForChild("QTEEventsREUSINGPingPong")
                :WaitForChild("Progress")
                :WaitForChild("KeyCode").AbsoluteSize
            if lastAbsoluteSize.X < 290
                and lastAbsoluteSize.Y < 290
                and Size.X > 290 and Size.Y > 290 then
                pcall(function()
                    keypress(32)
                    task.wait(0.05)
                    keyrelease(32)
                end)
                task.wait(0.05)
            end
            lastAbsoluteSize = Size
        end)
        if not ok then
            warn("自动乒乓球错误:", err)
        end
        task.wait(0.05)
    end
end)
Notify("守卫", "自动乒乓球 已启用", 2)
end,
})
end
do
local enabled     = false
local threads     = {}
local connections = {}
local currentGame = nil
local function cleanup()
for _, t in pairs(threads) do
pcall(function() task.cancel(t) end)
end
threads = {}
for _, c in pairs(connections) do
pcall(function() c:Disconnect() end)
end
connections = {}
if Options.TeleportToSafePlace and Options.TeleportToSafePlace.Value then
Options.TeleportToSafePlace:SetValue(false)
end
if Options.AutoKillGuard and Options.AutoKillGuard.Value then
Options.AutoKillGuard:SetValue(false)
end
currentGame = nil
end
local function winLightsOut()
if currentGame ~= "LightsOut" then return end
Notify("守卫", "检测到 Lights Out，等待守卫公告...", 3)
table.insert(threads, task.spawn(function()
while enabled and currentGame == "LightsOut" do
    local PlayerGui = LocalPlayer:FindFirstChild("PlayerGui")
    local Announcement = PlayerGui
        and PlayerGui:FindFirstChild("ImpactFrames")
        and PlayerGui.ImpactFrames:FindFirstChild("GuardAnnouncement")
    if Announcement and Announcement.Visible then
        Notify("守卫", "检测到守卫公告，等待 6 秒...", 3)
        task.wait(6)
        if enabled and currentGame == "LightsOut" then
            Options.TeleportToSafePlace:SetValue(true)
            Notify("守卫", "Lights Out：安全点已启用", 3)
        end
        break
    end
    task.wait(0.3)
end
end))
end
local function winJumpRope()
if currentGame ~= "JumpRope" then return end
Notify("守卫", "检测到跳绳，等待 5 秒...", 3)
table.insert(threads, task.spawn(function()
task.wait(5)
if not enabled or currentGame ~= "JumpRope" then return end
local Character = LocalPlayer.Character
local Root = Character and Character:FindFirstChild("HumanoidRootPart")
if Root then
    Root.CFrame = CFrame.new(735, 197, 922)
    Notify("守卫", "跳绳：已传送到终点", 3)
end
end))
end
local function winGlassBridge()
if currentGame ~= "GlassBridge" then return end
Notify("守卫", "检测到玻璃桥，等待 5 秒...", 3)
table.insert(threads, task.spawn(function()
task.wait(5)
if not enabled or currentGame ~= "GlassBridge" then return end
local Character = LocalPlayer.Character
local Root = Character and Character:FindFirstChild("HumanoidRootPart")
if Root then
    Root.CFrame = CFrame.new(-203.9, 520.7, -1534.3485)
    Notify("守卫", "玻璃桥：已传送到终点", 3)
end
end))
end
local function winRebelChance()
if currentGame ~= "RebelChance" then return end
Notify("守卫", "检测到反叛模式，启动反叛逻辑...", 3)
Options.TeleportToSafePlace:SetValue(true)
Options.AutoKillGuard:SetValue(true)
table.insert(threads, task.spawn(function()
while enabled and currentGame == "RebelChance" do
    local Backpack  = LocalPlayer:FindFirstChild("Backpack")
    local Character = LocalPlayer.Character
    if Backpack and Character then
        for _, Tool in pairs(Backpack:GetChildren()) do
            if Tool:IsA("Tool") and (Tool.Name == "MP5" or string.find(Tool.Name, "MP5")) then
                Tool.Parent = Character
                Notify("守卫", "已装备 MP5！", 2)
                break
            end
        end
    end
    task.wait(0.5)
end
end))
end
GuardGroup:AddToggle("AutoWin", {
Text = "⭐ 自动获胜（Beta）",
Tooltip = "等待游戏开始后自动获胜",
Default = false,
Disabled = true,
Callback = function(Value)
enabled = Value and true or false
if not enabled then
    cleanup()
    Notify("守卫", "自动获胜 已禁用", 2)
    return
end
Notify("守卫", "自动获胜 已启用！等待游戏...", 3)
table.insert(threads, task.spawn(function()
    local lastGame = nil
    while enabled do
        local game = GetCurrentGame()
        if game and game ~= lastGame then
            cleanup()
            currentGame = game
            Notify("守卫", "游戏开始：" .. game, 3)
            if game == "LightsOut" then
                winLightsOut(); lastGame = game
            elseif game == "JumpRope" then
                winJumpRope(); lastGame = game
            elseif game == "GlassBridge" then
                winGlassBridge(); lastGame = game
            elseif game == "RebelChance" then
                winRebelChance(); lastGame = game
            else
                Notify("守卫", "自动获胜：暂不支持 " .. game, 3)
                currentGame = nil
                lastGame    = nil
            end
        elseif lastGame and not game then
            Notify("守卫", "游戏结束：" .. lastGame, 3)
            cleanup()
            lastGame = nil
        end
        task.wait(0.5)
    end
end))
pcall(function()
    local Values = workspace:FindFirstChild("Values")
    local CurrentGame = Values and Values:FindFirstChild("CurrentGame")
    if CurrentGame then
        local Conn = CurrentGame.Changed:Connect(function(NewValue)
            if enabled then
                if NewValue and NewValue ~= "" and NewValue ~= "unknown" then
                    Notify("守卫", "CurrentGame 变为：" .. NewValue, 2)
                end
            end
        end)
        table.insert(connections, Conn)
    end
end)
end,
})
GuardGroup:AddLabel("自动获胜仅用于守卫和硬核模式，普通服务器无效。", true)
end
end
--子弹修改
do
local Players = game:GetService("Players")
local WeaponList = {
"G3SG1",
}
local selectedWeapons  = {}
local bulletInputValue = ""
Zdxg:AddDropdown("WeaponSelect", {
Text = "选择武器",
Values = WeaponList,
Default = {},
Multi = true,
Tooltip = "可多选要修改子弹的武器",
Callback = function(Value)
    selectedWeapons = {}
    for name, enabled in pairs(Value) do
        if enabled then
            table.insert(selectedWeapons, name)
        end
    end
end,
})
Zdxg:AddInput("BulletCountInput", {
Text = "子弹数量",
Default = "",
Placeholder = "输入子弹数量",
Numeric = true,
Finished = true,
Callback = function(Value)
    bulletInputValue = Value
    print("[守卫] 输入子弹数量: " .. tostring(Value))
end,
})
Zdxg:AddButton({
Text = "确定修改",
Tooltip = "修改选中武器的子弹数量",
Func = function()
    local bulletCount = tonumber(bulletInputValue)
    if not bulletCount or bulletCount < 0 then return end
    if #selectedWeapons == 0 then return end
    local lp = Players.LocalPlayer
    local backpack = lp:FindFirstChild("Backpack")
    if not backpack then return end
    local successCount = 0
    local partialCount = 0
    local failCount    = 0
    for _, weaponName in ipairs(selectedWeapons) do
        local weapon = backpack:FindFirstChild(weaponName)
        if weapon then
            local infoModified       = false
            local infoClientModified = false
            local info = weapon:FindFirstChild("Info")
            if info and info:FindFirstChild("Bullets") then
                info.Bullets.Value = bulletCount
                infoModified = true
            end
            local infoClient = weapon:FindFirstChild("InfoClient")
            if infoClient and infoClient:FindFirstChild("Bullets") then
                infoClient.Bullets.Value = bulletCount
                infoClientModified = true
            end
            if infoModified and infoClientModified then
                successCount += 1
            elseif infoModified or infoClientModified then
                partialCount += 1
            else
                failCount += 1
            end
        else
            failCount += 1
        end
    end
    if successCount > 0 then end
    if partialCount > 0 then end
    if failCount > 0 then end
end,
DoubleClick = false,
})
end

do
local Players           = game:GetService("Players")
local Workspace         = game:GetService("Workspace")
local RunService        = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService       = game:GetService("HttpService")
local localPlayer = Players.LocalPlayer
local function Notify(title, desc, time)
if Library and Library.Notify then
    Library:Notify({ Title = tostring(title), Description = tostring(desc or ""), Time = time or 3 })
end
end
GuardState = {
GamepassKeepAlive = {},
GuardQTEEnabled = false,
GuardQTEThread  = nil,
AutoShootGuardEnabled = false,
AutoShootGuardThread  = nil,
SilentAimEnabled = false,
SilentAimHooked  = false,
NoRecoilEnabled  = false,
RapidFireEnabled = false,
BuffsHooked      = false,
InfAmmoGuardEnabled = false,
InfAmmoGuardConn    = nil,
RebelShootEnabled = false,
RebelShootThread  = nil,
PeabertShootEnabled = false,
PeabertShootThread  = nil,
AntiExec = {
    Enabled   = { VoidKill = false, MingleVoidKill = false, ZoneKill = false },
    Conns     = {},
    Platforms = {},
},
PHDetectorEnabled = false,
PHConns = {},
PHHookedAnimators = {},
}
GuardF = {}
function GuardF.IsGameActive(name)
local values = Workspace:FindFirstChild("Values")
values = values and values:FindFirstChild("CurrentGame")
return values ~= nil and values.Value == name
end
function GuardF.AnchoredTeleport(cframe)
local character = localPlayer.Character
if not character then return end
local hrp = character:FindFirstChild("HumanoidRootPart")
if not hrp then return end
hrp.Velocity = Vector3.zero
hrp.RotVelocity = Vector3.zero
hrp.Anchored = true
character:PivotTo(cframe)
task.wait()
hrp.Velocity = Vector3.zero
hrp.Anchored = false
end
function GuardF.FindGun(whitelist)
local character = localPlayer.Character
local backpack  = localPlayer:FindFirstChild("Backpack")
local function check(container)
    if not container then return nil end
    for _, child in ipairs(container:GetChildren()) do
        if child:IsA("Tool") then
            if whitelist then
                if whitelist[child.Name] then return child end
            else
                if child:GetAttribute("Gun")
                    or child:FindFirstChild("GunScript")
                    or child:FindFirstChild("Client")
                    or string.lower(child.Name):find("gun") then
                    return child
                end
            end
        end
    end
    return nil
end
return check(character) or check(backpack)
end
GuardState.GuardGunWhitelist = {
["G3SG1"] = true, ["Glock 17"] = true, ["Five Seven"] = true,
["Colt M1911"] = true, ["Uzi"] = true, ["MP5K"] = true,
["Thompson M1A1"] = true, ["Colt Python 6"] = true, ["M4A1"] = true,
["FN Fal"] = true, ["HK416"] = true, ["Deagle"] = true, ["P90"] = true,
}
GuardState.RebelGunFallbacks = { "MP5", "Revolver" }
function GuardF.SetGamepass(attribute, enabled)
if GuardState.GamepassKeepAlive[attribute] then
    pcall(function() GuardState.GamepassKeepAlive[attribute]:Disconnect() end)
    GuardState.GamepassKeepAlive[attribute] = nil
end
if enabled then
    localPlayer:SetAttribute(attribute, true)
    GuardState.GamepassKeepAlive[attribute] = localPlayer:GetAttributeChangedSignal(attribute):Connect(function()
        if not localPlayer:GetAttribute(attribute) then
            localPlayer:SetAttribute(attribute, true)
        end
    end)
else
    localPlayer:SetAttribute(attribute, nil)
end
end
function GuardF.UnlockAllPasses()
GuardF.SetGamepass("__OwnsVIPGamepass", true)
GuardF.SetGamepass("__Owns2xVote", true)
GuardF.SetGamepass("__OwnsPermGuard", true)
GuardF.SetGamepass("__OwnsGlassManufacturerVision", true)
GuardF.SetGamepass("__OwnsPSPlus", true)
GuardF.SetGamepass("__OwnsEmotePages", true)
GuardF.SetGamepass("HasLighter", true)
Notify("通行证", "已全部解锁")
end
function GuardF.ToggleGuardQTE(enabled)
GuardState.GuardQTEEnabled = enabled and true or false
if GuardState.GuardQTEThread then
    pcall(task.cancel, GuardState.GuardQTEThread)
    GuardState.GuardQTEThread = nil
end
if not GuardState.GuardQTEEnabled then return end
GuardState.GuardQTEThread = task.spawn(function()
    local HBGQTE = nil
    local processed = {}
    while GuardState.GuardQTEEnabled do
        if localPlayer:GetAttribute("IsGuard") then
            if not HBGQTE then
                pcall(function()
                    HBGQTE = require(ReplicatedStorage:WaitForChild("Modules", 5):WaitForChild("HBGQTE", 5))
                end)
            end
            if HBGQTE and HBGQTE.ActiveButtons then
                for key, btn in pairs(HBGQTE.ActiveButtons) do
                    if not processed[key] and btn then
                        processed[key] = true
                        if GuardState.GuardQTEEnabled
                            and HBGQTE.ActiveButtons
                            and HBGQTE.ActiveButtons[key] then
                            pcall(function()
                                HBGQTE.Pressed(false, HBGQTE.ActiveButtons[key])
                            end)
                        end
                    end
                end
                for key in pairs(processed) do
                    if not HBGQTE.ActiveButtons[key] then
                        processed[key] = nil
                    end
                end
            end
        else
            table.clear(processed)
        end
        task.wait()
    end
    GuardState.GuardQTEThread = nil
end)
end
function GuardF.ToggleAutoShootGuard(enabled)
GuardState.AutoShootGuardEnabled = enabled and true or false
if GuardState.AutoShootGuardThread then
    pcall(task.cancel, GuardState.AutoShootGuardThread)
    GuardState.AutoShootGuardThread = nil
end
if not GuardState.AutoShootGuardEnabled then return end

GuardState.AutoShootGuardThread = task.spawn(function()
    while GuardState.AutoShootGuardEnabled do
        local live = Workspace:FindFirstChild("Live")
        local gun  = GuardF.FindGun(GuardState.GuardGunWhitelist)
        local character = localPlayer.Character
        local hrp = character and character:FindFirstChild("HumanoidRootPart")
        if live and gun and hrp then
            for _, child in ipairs(live:GetChildren()) do
                if not GuardState.AutoShootGuardEnabled then break end
                if child:IsA("Model") and child ~= character then
                    local hrp2   = child:FindFirstChild("HumanoidRootPart")
                    local humanoid = child:FindFirstChild("Humanoid")
                    if hrp2 and humanoid and humanoid.Health > 0 then
                        local lockOn = hrp2:FindFirstChild("GuardCanKillLockOn")
                        if lockOn and lockOn:IsA("BillboardGui") then
                            local args = {
                                gun,
                                {
                                    ClientRayNormal     = Vector3.new(0.707164, 0, -0.707049),
                                    FiredGun            = true,
                                    bulletCF            = CFrame.new(-221, 191, 269, 0.108, 0.141, 0.983, 0, 0.989, -0.142, -0.994, 0.015, 0.107),
                                    ClientRayInstance   = hrp2,
                                    SecondaryHitTargets = {},
                                    ClientRayPosition   = hrp2.Position,
                                    HitTargets          = { [child.Name] = "Head" },
                                    bulletSizeC         = Vector3.new(0.01, 0.01, 48.3),
                                    NoMuzzleFX          = false,
                                    FirePosition        = hrp.Position + Vector3.new(0, 1.5, 0),
                                },
                            }
                            pcall(function()
                                ReplicatedStorage.Remotes.FiredGunClient:FireServer(unpack(args))
                                task.wait(0.05)
                                ReplicatedStorage.Remotes.FiredGunClient:FireServer(gun, { ReloadingGun = true })
                            end)
                        end
                    end
                end
            end
        end
        task.wait(0.15)
    end
    GuardState.AutoShootGuardThread = nil
end)
end
function GuardF.ToggleSilentAim(enabled)
GuardState.SilentAimEnabled = enabled and true or false
if GuardState.SilentAimEnabled and not GuardState.SilentAimHooked then
    GuardState.SilentAimHooked = true
    pcall(function()
        local GunFunctions = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("GunFunctions"))
        local firedGun = GunFunctions.FiredGun
        GunFunctions.FiredGun = function(char, targetPos, args, ...)
            if not GuardState.SilentAimEnabled or char ~= localPlayer.Character then
                return firedGun(char, targetPos, args, ...)
            end
            args = args or {}
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            if not hrp then
                return firedGun(char, targetPos, args, ...)
            end
            local origin = hrp.Position
            pcall(function()
                local holding = char:GetAttribute("HoldingWeapon")
                if holding then
                    local tool = char:FindFirstChild(holding)
                    local fireFrom = tool and tool:FindFirstChild("FireFrom")
                    if fireFrom then origin = fireFrom.Position end
                end
            end)
            local isGuard = localPlayer:GetAttribute("IsGuard")
            local live = Workspace:FindFirstChild("Live")
            local best, bestDist = nil, 1000
            if live then
                for _, child in pairs(live:GetChildren()) do
                    if child ~= char
                        and not child:FindFirstChild("Dead")
                        and not child:FindFirstChild("IFrame") then
                        local humanoid = child:FindFirstChild("Humanoid")
                        if not (humanoid and humanoid.Health <= 0) then
                            local head = child:FindFirstChild("Head")
                                or child:FindFirstChild("HumanoidRootPart")
                                or child:FindFirstChildWhichIsA("BasePart", true)
                            if head then
                                local hrp2 = child:FindFirstChild("HumanoidRootPart")
                                local killable
                                if child:FindFirstChild("Enemy")
                                    or string.match(string.lower(child.Name), "peabert") then
                                    killable = true
                                elseif isGuard then
                                    killable = child:FindFirstChild("GuardCanKill")
                                        or (hrp2 and hrp2:FindFirstChild("GuardCanKillLockOn"))
                                else
                                    local p = Players:GetPlayerFromCharacter(child)
                                    killable = (p and p ~= localPlayer and p:GetAttribute("IsGuard"))
                                        or child.Name:match("Rebel") or child.Name:match("Guard")
                                        or child:FindFirstChild("PlayerCanKill")
                                        or child:FindFirstChild("TypeOfGuard")
                                end
                                if isGuard and child:FindFirstChild("TypeOfGuard")
                                    and not (hrp2 and hrp2:FindFirstChild("GuardCanKillLockOn"))
                                    and not child:FindFirstChild("GuardCanKill") then
                                    killable = false
                                end
                                if killable then
                                    local dist = (head.Position - origin).Magnitude
                                    if dist < bestDist then
                                        bestDist = dist
                                        best = head
                                    end
                                end
                            end
                        end
                    end
                end
            end
            if best then
                targetPos = best.Position
                args.CustomFireFrom = true
                args.spread = 0
            end
            return firedGun(char, targetPos, args, ...)
        end
    end)
    Notify("Silent Aim", "已挂钩 GunFunctions.FiredGun")
end
end
local function HookBuffs()
if GuardState.BuffsHooked then return end
GuardState.BuffsHooked = true
pcall(function()
    local module = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("GunFunctions"))
    if module and module.GetBuffs then
        local getBuffs = module.GetBuffs
        module.GetBuffs = function(...)
            local t = getBuffs(...)
            if type(t) ~= "table" then t = {} end
            local copy = {}
            for k, v in pairs(t) do copy[k] = v end
            if GuardState.NoRecoilEnabled then
                copy.RecoilDiv = 999999
            end
            if GuardState.RapidFireEnabled then
                copy.FireRateMult = 9999
            end
            return copy
        end
    end
end)
end
function GuardF.ToggleNoRecoil(enabled)
GuardState.NoRecoilEnabled = enabled and true or false
if enabled then HookBuffs() end
end
function GuardF.ToggleRapidFireBuff(enabled)
GuardState.RapidFireEnabled = enabled and true or false
if enabled then HookBuffs() end
end
function GuardF.ToggleInfAmmoGuard(enabled)
GuardState.InfAmmoGuardEnabled = enabled and true or false
if GuardState.InfAmmoGuardConn then
    pcall(function() GuardState.InfAmmoGuardConn:Disconnect() end)
    GuardState.InfAmmoGuardConn = nil
end
if not GuardState.InfAmmoGuardEnabled then return end
GuardState.InfAmmoGuardConn = RunService.RenderStepped:Connect(function()
    if not GuardState.InfAmmoGuardEnabled then return end
    pcall(function()
        local character = localPlayer.Character
        if not character then return end
        local tool = character:FindFirstChildOfClass("Tool")
        if tool then
            local info = tool:FindFirstChild("InfoClient") or tool:FindFirstChild("Info")
            if info then
                local bullets = info:FindFirstChild("Bullets")
                local maxB = tool:FindFirstChild("MaxBullets") or tool:FindFirstChild("MagSize")
                if bullets then
                    local max = maxB and maxB.Value or 999
                    if bullets.Value < max then bullets.Value = max end
                end
            end
        end
    end)
end)
end
function GuardF.ToggleRebelShoot(enabled)
GuardState.RebelShootEnabled = enabled and true or false
if GuardState.RebelShootThread then
    pcall(task.cancel, GuardState.RebelShootThread)
    GuardState.RebelShootThread = nil
end
if not GuardState.RebelShootEnabled then return end

GuardState.RebelShootThread = task.spawn(function()
    while GuardState.RebelShootEnabled do
        local gun = GuardF.FindGun(nil) or GuardF.FindGun({
            ["MP5"] = true, ["Revolver"] = true,
        })
        local character = localPlayer.Character
        local hrp = character and character:FindFirstChild("HumanoidRootPart")
        if gun and hrp then
            local live = Workspace:FindFirstChild("Live")
            local target, targetHrp = nil, nil
            local closest = math.huge
            if live then
                for _, child in pairs(live:GetChildren()) do
                    if child.Name:match("Rebel") or child.Name:match("Guard") then
                        local h2 = child:FindFirstChild("HumanoidRootPart")
                        local hum = child:FindFirstChild("Humanoid")
                        if h2 and hum and hum.Health > 0 then
                            local d = (hrp.Position - h2.Position).Magnitude
                            if d < closest then closest, target, targetHrp = d, child, h2 end
                        end
                    end
                end
            end
            for _, player in ipairs(Players:GetPlayers()) do
                if player ~= localPlayer and player:GetAttribute("IsGuard") == true then
                    local c2 = player.Character
                    local h2 = c2 and c2:FindFirstChild("HumanoidRootPart")
                    local hum = c2 and c2:FindFirstChild("Humanoid")
                    if h2 and hum and hum.Health > 0 then
                        local d = (hrp.Position - h2.Position).Magnitude
                        if d < closest then closest, target, targetHrp = d, c2, h2 end
                    end
                end
            end
            if target and targetHrp then
                local args = {
                    gun,
                    {
                        ClientRayNormal     = Vector3.new(0.707164, 0, -0.707049),
                        FiredGun            = true,
                        bulletCF            = CFrame.new(-221, 191, 269, 0.108, 0.141, 0.983, 0, 0.989, -0.142, -0.994, 0.015, 0.107),
                        ClientRayInstance   = targetHrp,
                        SecondaryHitTargets = {},
                        ClientRayPosition   = targetHrp.Position,
                        HitTargets          = { [target.Name] = "Head" },
                        bulletSizeC         = Vector3.new(0.01, 0.01, 48.3),
                        NoMuzzleFX          = false,
                        FirePosition        = targetHrp.Position + Vector3.new(0, 1, 0),
                    },
                }
                pcall(function()
                    ReplicatedStorage.Remotes.FiredGunClient:FireServer(unpack(args))
                    task.wait(0.05)
                    ReplicatedStorage.Remotes.FiredGunClient:FireServer(gun, { ReloadingGun = true })
                end)
            end
        end
        task.wait(0.15)
    end
    GuardState.RebelShootThread = nil
end)
end
function GuardF.TogglePeabertShoot(enabled)
GuardState.PeabertShootEnabled = enabled and true or false
if GuardState.PeabertShootThread then
    pcall(task.cancel, GuardState.PeabertShootThread)
    GuardState.PeabertShootThread = nil
end
if not GuardState.PeabertShootEnabled then return end
GuardState.PeabertShootThread = task.spawn(function()
    while GuardState.PeabertShootEnabled do
        local gun = GuardF.FindGun({
            ["Colt M1911"] = true, ["Uzi"] = true, ["Five Seven"] = true,
            ["MP5K"] = true, ["Colt Python 6"] = true, ["Deagle"] = true,
            ["P90"] = true, ["FN Fal"] = true, ["M4A1"] = true, ["HK416"] = true,
        })
        local character = localPlayer.Character
        local hrp = character and character:FindFirstChild("HumanoidRootPart")

        if gun and hrp then
            local live = nil
            for _, child in pairs(Workspace:GetChildren()) do
                if (child:IsA("Model") or child:IsA("Folder")) then
                    local f = child:FindFirstChild("Live")
                    if f and f:IsA("Folder") then live = f break end
                end
            end
            if not live then
                for _, d in pairs(Workspace:GetDescendants()) do
                    if d.Name == "Live" and d:IsA("Folder") then live = d break end
                end
            end
            if live then
                for _, child in pairs(live:GetChildren()) do
                    if child:IsA("Model") and string.match(string.lower(child.Name), "peabert") then
                        local basePart = child:FindFirstChildWhichIsA("BasePart", true)
                        if basePart then
                            local args = {
                                gun,
                                {
                                    ClientRayNormal     = Vector3.new(0.707164, 0, -0.707049),
                                    FiredGun            = true,
                                    bulletCF            = CFrame.new(-221, 191, 269, 0.108, 0.141, 0.983, 0, 0.989, -0.142, -0.994, 0.015, 0.107),
                                    ClientRayInstance   = basePart,
                                    SecondaryHitTargets = {},
                                    ClientRayPosition   = basePart.Position,
                                    HitTargets          = { [child.Name] = basePart.Name },
                                    bulletSizeC         = Vector3.new(0.01, 0.01, 48.3),
                                    NoMuzzleFX          = false,
                                    FirePosition        = hrp.Position,
                                },
                            }
                            pcall(function()
                                ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("FiredGunClient"):FireServer(unpack(args))
                                task.wait(0.05)
                                ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("FiredGunClient"):FireServer(gun, { ReloadingGun = true })
                            end)
                        end
                    end
                end
            end
        end
        task.wait(0.15)
    end
    GuardState.PeabertShootThread = nil
end)
end
local AntiExecConfigs = {
VoidKill = {
    Game     = "SkySquidGame",
    AnimIds  = {
        "rbxassetid://107989020363293",
        "rbxassetid://95016887526212",
        "rbxassetid://81454586970343",
        "rbxassetid://71619354165195",
    },
    SafePos  = Vector3.new(-95.1, 964.6, 67.6),
    Platform = { Size = Vector3.new(240, 3, 240), Offset = Vector3.new(0, -3, 0) },
    Platform2= { Size = Vector3.new(240, 2, 240), Offset = Vector3.new(0, -7, 0) },
    ReturnDelay = 1.5,
    UseRandomOffset = true,
},
MingleVoidKill = {
    Game     = "Mingle",
    AnimIds  = { "rbxassetid://71318091779666" },
    SafePos  = Vector3.new(196.83342, 55.9548, -90.47459),
    Platform = { Size = Vector3.new(40, 2, 40), Offset = Vector3.new(0, -3, 0) },
    ReturnDelay = 0.6,
},
ZoneKill = {
    Game     = "LastDinner",
    AnimIds  = { "rbxassetid://105341857343164" },
    SafePos  = Vector3.new(197.7, 54.6, -96.3),
    ReturnDelay = 0.6,
},
}
local function cfgNameOf(cfg)
for name, c in pairs(AntiExecConfigs) do
    if c == cfg then return name end
end
return "VoidKill"
end
local function TrackExecutionAnimations(character, cfg)
local humanoid = character:WaitForChild("Humanoid", 5)
if not humanoid then return end
local conn = humanoid.AnimationPlayed:Connect(function(track)
    if not GuardState.AntiExec.Enabled[cfgNameOf(cfg)] then return end
    if not (track.Animation and table.find(cfg.AnimIds, track.Animation.AnimationId)) then return end
    local hrp = character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local originalCF = hrp.CFrame
    local safePos = cfg.SafePos
    if cfg.UseRandomOffset then
        local angle = math.random() * math.pi * 2
        safePos = hrp.Position + Vector3.new(math.cos(angle) * 63, 0, math.sin(angle) * 63)
    end
    local destCF = CFrame.new(safePos + Vector3.new(0, 0.5, 0))
    local platforms = {}
    if cfg.Platform then
        local p = Instance.new("Part")
        p.Name = HttpService:GenerateGUID(false)
        p.Size = cfg.Platform.Size
        p.Anchored = true
        p.CanCollide = true
        p.Transparency = 0.5
        p.Position = safePos + cfg.Platform.Offset
        p.Parent = Workspace
        table.insert(platforms, p)
    end
    if cfg.Platform2 then
        local p2 = Instance.new("Part")
        p2.Name = HttpService:GenerateGUID(false)
        p2.Size = cfg.Platform2.Size
        p2.Anchored = true
        p2.CanCollide = true
        p2.Transparency = 1
        p2.Position = safePos + cfg.Platform2.Offset
        p2.Parent = Workspace
        table.insert(platforms, p2)
    end
    hrp.CFrame = destCF
    if character.PrimaryPart then
        pcall(function() character:SetPrimaryPartCFrame(destCF) end)
    end
    local stoppedConn
    stoppedConn = track.Stopped:Connect(function()
        task.wait(cfg.ReturnDelay or 1)
        if character and character.Parent then
            local hrp2 = character:FindFirstChild("HumanoidRootPart")
            if hrp2 and GuardState.AntiExec.Enabled[cfgNameOf(cfg)] then
                hrp2.CFrame = originalCF
                pcall(function() character:SetPrimaryPartCFrame(originalCF) end)
            end
        end
        task.wait(cfg.ReturnDelay or 1)
        for _, p in ipairs(platforms) do
            pcall(function() if p then p:Destroy() end end)
        end
        if stoppedConn then stoppedConn:Disconnect() end
    end)
end)
table.insert(GuardState.AntiExec.Conns, conn)
end
local function HookAntiExecCharacter(character)
for _, cfg in pairs(AntiExecConfigs) do
    TrackExecutionAnimations(character, cfg)
end
end
function GuardF.ToggleAntiExec(which, enabled)
GuardState.AntiExec.Enabled[which] = enabled and true or false
if not enabled then
    return
end
if localPlayer.Character and not GuardState.AntiExec._Hooked then
    GuardState.AntiExec._Hooked = true
    HookAntiExecCharacter(localPlayer.Character)
    table.insert(GuardState.AntiExec.Conns, localPlayer.CharacterAdded:Connect(function(char)
        task.wait(1)
        local humanoid = char:WaitForChild("Humanoid", 5)
        if not humanoid then return end
        for name, cfg in pairs(AntiExecConfigs) do
            local conn = humanoid.AnimationPlayed:Connect(function(track)
                if not GuardState.AntiExec.Enabled[name] then return end
                if not (track.Animation and table.find(cfg.AnimIds, track.Animation.AnimationId)) then return end
                local hrp = char:FindFirstChild("HumanoidRootPart")
                if not hrp then return end
                local originalCF = hrp.CFrame
                local safePos = cfg.SafePos
                local destCF = CFrame.new(safePos + Vector3.new(0, 0.5, 0))
                hrp.CFrame = destCF
                local stoppedConn
                stoppedConn = track.Stopped:Connect(function()
                    task.wait(cfg.ReturnDelay or 1)
                    local hrp2 = char:FindFirstChild("HumanoidRootPart")
                    if hrp2 and char.Parent and GuardState.AntiExec.Enabled[name] then
                        hrp2.CFrame = originalCF
                    end
                    if stoppedConn then stoppedConn:Disconnect() end
                end)
            end)
            table.insert(GuardState.AntiExec.Conns, conn)
        end
    end))
end
end
local PH_GRAB_ANIM  = "71318091779666"
local PH_STRUGGLE_ANIM = "82142761681917"

local function PH_FindGrabber(character)
for _, d in pairs(character:GetDescendants()) do
    if d:IsA("JointInstance") and d.Part1 and d.Part0 then
        local m1 = d.Part1.Parent
        local m0 = d.Part0.Parent
        if m1 and m1:IsA("Model") and m1:FindFirstChild("Humanoid") and m1 ~= character then
            return m1
        end
        if m0 and m0:IsA("Model") and m0:FindFirstChild("Humanoid") and m0 ~= character then
            return m0
        end
    end
end
local hrp = character:FindFirstChild("HumanoidRootPart")
if not hrp then return nil end
local function checkModel(m)
    if m and m:IsA("Model") and m ~= character
        and m:FindFirstChild("Humanoid") and m:FindFirstChild("HumanoidRootPart") then
        if (m.HumanoidRootPart.Position - hrp.Position).Magnitude < 6 then
            local animator = m.Humanoid:FindFirstChild("Animator")
            if animator then
                for _, t in pairs(animator:GetPlayingAnimationTracks()) do
                    if ((t.Animation and t.Animation.AnimationId:match("%d+")) or "") == PH_STRUGGLE_ANIM then
                        return m
                    end
                end
            end
        end
    end
    return nil
end
for _, p in pairs(Players:GetPlayers()) do
    local r = checkModel(p.Character)
    if r then return r end
end
local live = Workspace:FindFirstChild("Live") or Workspace:FindFirstChild("Characters")
if live then
    for _, c in pairs(live:GetChildren()) do
        local r = checkModel(c)
        if r then return r end
    end
end
return nil
end
local function PH_HookAnimator(animator, character)
if GuardState.PHHookedAnimators[animator] then return end
GuardState.PHHookedAnimators[animator] = true
local conn = animator.AnimationPlayed:Connect(function(track)
    if not GuardState.PHDetectorEnabled then return end
    if not track or not track.Animation then return end
    if (track.Animation.AnimationId:match("%d+") or "") == PH_GRAB_ANIM then
        task.delay(0.2, function()
            local grabber = character and PH_FindGrabber(character)
            if grabber and character == localPlayer.Character then
                Notify("PH Detector", "检测到守卫抓人动画! 抓取者: " .. grabber.Name)
            end
        end)
    end
end)
table.insert(GuardState.PHConns, conn)
end
local function PH_HookCharacter(character)
if character:IsA("Model") then
    task.spawn(function()
        local humanoid = character:WaitForChild("Humanoid", 3)
        if not humanoid then return end
        local animator = humanoid:WaitForChild("Animator", 3)
        if animator then PH_HookAnimator(animator, character) end
    end)
end
end
function GuardF.TogglePHDetector(enabled)
GuardState.PHDetectorEnabled = enabled and true or false
if not GuardState.PHDetectorEnabled then
    for _, c in ipairs(GuardState.PHConns) do
        pcall(function() c:Disconnect() end)
    end
    table.clear(GuardState.PHConns)
    table.clear(GuardState.PHHookedAnimators)
    return
end
for _, p in pairs(Players:GetPlayers()) do
    if p.Character then PH_HookCharacter(p.Character) end
    table.insert(GuardState.PHConns, p.CharacterAdded:Connect(PH_HookCharacter))
end
table.insert(GuardState.PHConns, Players.PlayerAdded:Connect(function(p)
    table.insert(GuardState.PHConns, p.CharacterAdded:Connect(PH_HookCharacter))
end))
for _, c in pairs(Workspace:GetChildren()) do
    task.spawn(PH_HookCharacter, c)
end
table.insert(GuardState.PHConns, Workspace.ChildAdded:Connect(PH_HookCharacter))
end
local function hasGroup(gb)
return gb ~= nil and type(gb.AddToggle) == "function"
end
if hasGroup(LeftGB) then
LeftGB:AddButton({
    Text = "解锁全部通行证",
    Func = function() GuardF.UnlockAllPasses() end,
    Tooltip = "VIP/2X/永久守卫/玻璃透视/PS+/表情页/打火机",
})
LeftGB:AddToggle("GP_PermGuard", {
    Text = "永久守卫 __OwnsPermGuard",
    Default = false,
    Callback = function(v) GuardF.SetGamepass("__OwnsPermGuard", v) end,
})
LeftGB:AddToggle("GP_GlassVision", {
    Text = "玻璃透视 __OwnsGlassManufacturerVision",
    Default = false,
    Callback = function(v) GuardF.SetGamepass("__OwnsGlassManufacturerVision", v) end,
})
LeftGB:AddToggle("GP_VIP", {
    Text = "VIP __OwnsVIPGamepass",
    Default = false,
    Callback = function(v) GuardF.SetGamepass("__OwnsVIPGamepass", v) end,
})
LeftGB:AddToggle("GP_2X", {
    Text = "2X投票 __Owns2XVote",
    Default = false,
    Callback = function(v) GuardF.SetGamepass("__Owns2xVote", v) end,
})
LeftGB:AddToggle("GP_PSPlus", {
    Text = "PS Plus __OwnsPSPlus",
    Default = false,
    Callback = function(v) GuardF.SetGamepass("__OwnsPSPlus", v) end,
})
LeftGB:AddToggle("GP_Emotes", {
    Text = "表情页 __OwnsEmotePages",
    Default = false,
    Callback = function(v) GuardF.SetGamepass("__OwnsEmotePages", v) end,
})
LeftGB:AddToggle("GP_Lighter", {
    Text = "打火机 HasLighter",
    Default = false,
    Callback = function(v) GuardF.SetGamepass("HasLighter", v) end,
})
LeftGB:AddDivider()
LeftGB:AddToggle("Rebel_Shoot", {
    Text = "Rebel 反守卫射击",
    Default = false,
    Risky = true,
    Tooltip = "自动射击 Rebel/Guard 模型与真人守卫",
    Callback = function(v) GuardF.ToggleRebelShoot(v) end,
})
LeftGB:AddToggle("AA_Peabert", {
    Text = "Admin Abuse 打 Peabert",
    Default = false,
    Risky = true,
    Callback = function(v) GuardF.TogglePeabertShoot(v) end,
})
LeftGB:AddToggle("PH_Detector", {
    Text = "PH 抓人检测器",
    Default = false,
    Tooltip = "检测守卫 71318091779666 抓人动画",
    Callback = function(v) GuardF.TogglePHDetector(v) end,
})
end
if hasGroup(RightGB) then
RightGB:AddToggle("Guard_AutoShoot", {
    Text = "守卫自动射击 (红箭头目标)",
    Default = false,
    Risky = true,
    Tooltip = "自动射击带 GuardCanKillLockOn 标记的目标",
    Callback = function(v) GuardF.ToggleAutoShootGuard(v) end,
})
RightGB:AddToggle("Guard_QTE", {
    Text = "守卫自动 QTE",
    Default = false,
    Tooltip = "IsGuard 状态下自动按 QTE 按钮",
    Callback = function(v) GuardF.ToggleGuardQTE(v) end,
})
RightGB:AddToggle("Guard_SilentAim", {
    Text = "Silent Aim",
    Default = false,
    Risky = true,
    Callback = function(v) GuardF.ToggleSilentAim(v) end,
})
RightGB:AddToggle("Guard_NoRecoil", {
    Text = "无后座 & 无扩散",
    Default = false,
    Callback = function(v) GuardF.ToggleNoRecoil(v) end,
})
RightGB:AddToggle("Guard_RapidFire", {
    Text = "速射",
    Default = false,
    Callback = function(v) GuardF.ToggleRapidFireBuff(v) end,
})
RightGB:AddToggle("Guard_InfAmmo", {
    Text = "守卫无限弹药",
    Default = false,
    Callback = function(v) GuardF.ToggleInfAmmoGuard(v) end,
})
RightGB:AddDivider()
RightGB:AddToggle("AE_VoidKill", {
    Text = "Void Kill 防护 (SkySquid)",
    Default = false,
    Tooltip = "处决动画触发时传送走",
    Callback = function(v) GuardF.ToggleAntiExec("VoidKill", v) end,
})
RightGB:AddToggle("AE_MingleVoid", {
    Text = "Mingle 抓人防护",
    Default = false,
    Tooltip = "71318091779666 动画触发时传送走",
    Callback = function(v) GuardF.ToggleAntiExec("MingleVoidKill", v) end,
})
RightGB:AddToggle("AE_ZoneKill", {
    Text = "Zone Kill 防护 (LastDinner)",
    Default = false,
    Tooltip = "105341857343164 动画触发时传送走",
    Callback = function(v) GuardF.ToggleAntiExec("ZoneKill", v) end,
})
RightGB:AddDivider()
RightGB:AddButton({
    Text = "RLGL 管理员局 传送到起点",
    Func = function()
        if GuardF.IsGameActive("AdminAbuseRedLightGreenLight") then
            GuardF.AnchoredTeleport(CFrame.new(-1375, -30, 22))
        else
            Notify("Admin Abuse", "当前不在管理员 RLGL 局")
        end
    end,
})
RightGB:AddButton({
    Text = "RLGL 管理员局 传送到终点",
    Func = function()
        if GuardF.IsGameActive("AdminAbuseRedLightGreenLight") then
            GuardF.AnchoredTeleport(CFrame.new(-1361, -28, 701))
        else
            Notify("Admin Abuse", "当前不在管理员 RLGL 局")
        end
    end,
})
end
if Library and Library.OnUnload then
Library:OnUnload(function()
    for attr, conn in pairs(GuardState.GamepassKeepAlive) do
        pcall(function() conn:Disconnect() end)
    end
    GuardF.ToggleGuardQTE(false)
    GuardF.ToggleAutoShootGuard(false)
    GuardF.ToggleInfAmmoGuard(false)
    GuardF.ToggleRebelShoot(false)
    GuardF.TogglePeabertShoot(false)
    GuardF.TogglePHDetector(false)
    for _, c in ipairs(GuardState.AntiExec.Conns) do
        pcall(function() c:Disconnect() end)
    end
    print("Guard Suite unloaded!")
end)
end
Notify("Guard Suite", "守卫功能已加载完成")
end

local Glygj = Tabs.Guanliy:AddLeftGroupbox("| 管理员滥用", "traffic-cone")
local Glysl = Tabs.Guanliy:AddRightGroupbox("| 管理员滥用", "lightbulb-off")

do
local Players           = game:GetService("Players")
local Workspace         = game:GetService("Workspace")
local RunService        = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService      = game:GetService("SoundService")
local DebrisService     = game:GetService("Debris")
local localPlayer       = Players.LocalPlayer
local function Notify(title, desc, time)
if Library and Library.Notify then
    Library:Notify({ Title = tostring(title), Description = tostring(desc or ""), Time = time or 3 })
end
end
local TOGGLE_SOUND_ID = "rbxassetid://99979147606311"
local function PlayToggleSound(state)
pcall(function()
    local s = Instance.new("Sound")
    s.SoundId = TOGGLE_SOUND_ID
    s.Volume = 2
    s.PlaybackSpeed = (state == false) and 0.85 or 1.2
    s.Parent = SoundService
    s:Play()
    s.Ended:Connect(function() s:Destroy() end)
    DebrisService:AddItem(s, 3)
end)
end
AAState = {
LastAARLGLTPTime = 0,
PeabertShootEnabled = false,
PeabertShootThread  = nil,
SilentAimEnabled = false,
SilentAimHooked  = false,
PeabertESPEnabled = false,
PeabertModels     = {},
PeabertHighlights = {},
LastPeabertTPTime = 0,
PeabertKillEnabled      = false,
PeabertKillConn         = nil,
PeabertShotsPerTick     = 15,
}
AAF = {}
function AAF.IsGameActive(name)
local values = Workspace:FindFirstChild("Values")
values = values and values:FindFirstChild("CurrentGame")
return values ~= nil and values.Value == name
end
function AAF.AnchoredTeleport(cframe)
local character = localPlayer.Character
if not character then return false end
local hrp = character:FindFirstChild("HumanoidRootPart")
if not hrp then return false end
hrp.Velocity = Vector3.zero
hrp.RotVelocity = Vector3.zero
hrp.Anchored = true
character:PivotTo(cframe)
task.wait()
hrp.Velocity = Vector3.zero
hrp.Anchored = false
return true
end
function AAF.FindGun(whitelist)
local character = localPlayer.Character
local backpack  = localPlayer:FindFirstChild("Backpack")
local function check(container)
    if not container then return nil end
    for _, child in ipairs(container:GetChildren()) do
        if child:IsA("Tool") and whitelist[child.Name] then
            return child
        end
    end
    return nil
end
return check(character) or check(backpack)
end
AAState.AA_RLGL_Start = CFrame.new(-1375, -30, 22)
AAState.AA_RLGL_End   = CFrame.new(-1361, -28, 701)
function AAF.TeleportAARLGL(which)
if not AAF.IsGameActive("AdminAbuseRedLightGreenLight") then
    Notify("Admin Abuse", "当前不在管理员 RLGL 局")
    return
end
if tick() - AAState.LastAARLGLTPTime < 10 then
    Notify("冷却", "请等待 " .. math.ceil(10 - (tick() - AAState.LastAARLGLTPTime)) .. " 秒再传送")
    return
end
local target = (which == "Start") and AAState.AA_RLGL_Start or AAState.AA_RLGL_End
AAF.AnchoredTeleport(target)
AAState.LastAARLGLTPTime = tick()
Notify("Admin Abuse", "已传送到" .. ((which == "Start") and "起点" or "终点"))
end
AAState.AAGunWhitelist = {
["Colt M1911"] = true, ["Uzi"] = true, ["Five Seven"] = true,
["MP5K"] = true, ["Colt Python 6"] = true, ["Deagle"] = true,
["P90"] = true, ["FN Fal"] = true, ["M4A1"] = true, ["HK416"] = true,
}
function AAF.FindLiveFolder()
for _, child in pairs(Workspace:GetChildren()) do
    if child:IsA("Model") or child:IsA("Folder") then
        local f = child:FindFirstChild("Live")
        if f and f:IsA("Folder") then return f end
    end
end
for _, d in pairs(Workspace:GetDescendants()) do
    if d.Name == "Live" and d:IsA("Folder") then return d end
end
return nil
end
function AAF.TogglePeabertShoot(enabled)
AAState.PeabertShootEnabled = enabled and true or false
if AAState.PeabertShootThread then
    pcall(task.cancel, AAState.PeabertShootThread)
    AAState.PeabertShootThread = nil
end
if not AAState.PeabertShootEnabled then return end
AAState.PeabertShootThread = task.spawn(function()
    while AAState.PeabertShootEnabled do
        local gun = AAF.FindGun(AAState.AAGunWhitelist)
        local character = localPlayer.Character
        local hrp = character and character:FindFirstChild("HumanoidRootPart")
        if gun and hrp then
            local live = AAF.FindLiveFolder()
            if live then
                for _, child in pairs(live:GetChildren()) do
                    if not AAState.PeabertShootEnabled then break end
                    if child:IsA("Model") and string.match(string.lower(child.Name), "peabert") then
                        local basePart = child:FindFirstChildWhichIsA("BasePart", true)
                        if basePart then
                            pcall(function()
                                ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("FiredGunClient"):FireServer(gun, {
                                    ClientRayNormal     = Vector3.new(0.707164, 0, -0.707049),
                                    FiredGun            = true,
                                    bulletCF            = CFrame.new(-221, 191, 269, 0.108, 0.141, 0.983, 0, 0.989, -0.142, -0.994, 0.015, 0.107),
                                    ClientRayInstance   = basePart,
                                    SecondaryHitTargets = {},
                                    ClientRayPosition   = basePart.Position,
                                    HitTargets          = { [child.Name] = basePart.Name },
                                    bulletSizeC         = Vector3.new(0.01, 0.01, 48.3),
                                    NoMuzzleFX          = false,
                                    FirePosition        = hrp.Position,
                                })
                                task.wait(0.05)
                                ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("FiredGunClient"):FireServer(gun, { ReloadingGun = true })
                            end)
                        end
                    end
                end
            end
        end
        task.wait(0.15)
    end
    AAState.PeabertShootThread = nil
end)
end
function AAF.ToggleSilentAim(enabled)
AAState.SilentAimEnabled = enabled and true or false
if AAState.SilentAimEnabled and not AAState.SilentAimHooked then
    AAState.SilentAimHooked = true
    pcall(function()
        local GunFunctions = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("GunFunctions"))
        local firedGun = GunFunctions.FiredGun

        GunFunctions.FiredGun = function(char, targetPos, args, ...)
            if not AAState.SilentAimEnabled or char ~= localPlayer.Character then
                return firedGun(char, targetPos, args, ...)
            end
            args = args or {}
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            if not hrp then
                return firedGun(char, targetPos, args, ...)
            end
            local origin = hrp.Position
            pcall(function()
                local holding = char:GetAttribute("HoldingWeapon")
                if holding then
                    local tool = char:FindFirstChild(holding)
                    local fireFrom = tool and tool:FindFirstChild("FireFrom")
                    if fireFrom then origin = fireFrom.Position end
                end
            end)
            local isGuard = localPlayer:GetAttribute("IsGuard")
            local live = Workspace:FindFirstChild("Live")
            local best, bestDist = nil, 1000
            if live then
                for _, child in pairs(live:GetChildren()) do
                    if child ~= char
                        and not child:FindFirstChild("Dead")
                        and not child:FindFirstChild("IFrame") then
                        local humanoid = child:FindFirstChild("Humanoid")
                        if not (humanoid and humanoid.Health <= 0) then
                            local head = child:FindFirstChild("Head")
                                or child:FindFirstChild("HumanoidRootPart")
                                or child:FindFirstChildWhichIsA("BasePart", true)
                            if head then
                                local hrp2 = child:FindFirstChild("HumanoidRootPart")
                                local killable
                                if child:FindFirstChild("Enemy")
                                    or string.match(string.lower(child.Name), "peabert") then
                                    killable = true
                                elseif isGuard then
                                    killable = child:FindFirstChild("GuardCanKill")
                                        or (hrp2 and hrp2:FindFirstChild("GuardCanKillLockOn"))
                                else
                                    local p = Players:GetPlayerFromCharacter(child)
                                    killable = (p and p ~= localPlayer and p:GetAttribute("IsGuard"))
                                        or child.Name:match("Rebel") or child.Name:match("Guard")
                                        or child:FindFirstChild("PlayerCanKill")
                                        or child:FindFirstChild("TypeOfGuard")
                                end
                                if isGuard and child:FindFirstChild("TypeOfGuard")
                                    and not (hrp2 and hrp2:FindFirstChild("GuardCanKillLockOn"))
                                    and not child:FindFirstChild("GuardCanKill") then
                                    killable = false
                                end
                                if killable then
                                    local dist = (head.Position - origin).Magnitude
                                    if dist < bestDist then
                                        bestDist = dist
                                        best = head
                                    end
                                end
                            end
                        end
                    end
                end
            end
            if best then
                targetPos = best.Position
                args.CustomFireFrom = true
                args.spread = 0
            end
            return firedGun(char, targetPos, args, ...)
        end
    end)
    Notify("Silent Aim", "已挂钩 GunFunctions.FiredGun")
end
end
local function IsPeabertModel(obj)
return obj:IsA("Model") and string.find(obj.Name, "FREEPEABERT") ~= nil
end
local function CreatePeabertHighlight(model)
if AAState.PeabertHighlights[model] then return end
local highlight = Instance.new("Highlight")
highlight.Name = "PeabertHighlight"
highlight.FillColor = Color3.fromRGB(0, 255, 0)
highlight.FillTransparency = 0.5
highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
highlight.Parent = model
AAState.PeabertHighlights[model] = highlight
end
local function DestroyPeabertHighlight(model)
if AAState.PeabertHighlights[model] then
    pcall(function() AAState.PeabertHighlights[model]:Destroy() end)
    AAState.PeabertHighlights[model] = nil
end
end
local function TrackPeabert(descendant)
if IsPeabertModel(descendant) then
    AAState.PeabertModels[descendant] = true
    if AAState.PeabertESPEnabled then
        CreatePeabertHighlight(descendant)
    end
end
end
for _, d in pairs(Workspace:GetDescendants()) do
TrackPeabert(d)
end
Workspace.DescendantAdded:Connect(TrackPeabert)
Workspace.DescendantRemoving:Connect(function(d)
if AAState.PeabertModels[d] then
    AAState.PeabertModels[d] = nil
    DestroyPeabertHighlight(d)
end
end)
function AAF.TogglePeabertESP(enabled)
AAState.PeabertESPEnabled = enabled and true or false
if AAState.PeabertESPEnabled then
    for model in pairs(AAState.PeabertModels) do
        if model and model.Parent then
            CreatePeabertHighlight(model)
        end
    end
else
    for model in pairs(AAState.PeabertModels) do
        DestroyPeabertHighlight(model)
    end
end
end
function AAF.TeleportToPeabert()
if tick() - AAState.LastPeabertTPTime < 10 then
    Notify("冷却", string.format("请等待 %.1f 秒", 10 - (tick() - AAState.LastPeabertTPTime)))
    return
end
local character = localPlayer.Character
local hrp = character and character:FindFirstChild("HumanoidRootPart")
if not hrp then return end
local closest, closestPart = math.huge, nil
for model in pairs(AAState.PeabertModels) do
    if model and model.Parent then
        local basePart = model:FindFirstChildWhichIsA("BasePart", true)
        if basePart then
            local mag = (hrp.Position - basePart.Position).Magnitude
            if mag < closest then
                closest, closestPart = mag, basePart
            end
        end
    end
end
if closestPart then
    AAF.AnchoredTeleport(closestPart.CFrame * CFrame.new(0, 0, 3))
    AAState.LastPeabertTPTime = tick()
    Notify("传送", "已传送到最近的 Peabert！")
else
    Notify("错误", "地图上没有找到 Peabert！")
end
end
function AAF.SetPeabertShotsPerTick(n)
AAState.PeabertShotsPerTick = tonumber(n) or 15
end
function AAF.TogglePeabertKill(enabled)
AAState.PeabertKillEnabled = enabled and true or false
if AAState.PeabertKillConn then
    pcall(function() AAState.PeabertKillConn:Disconnect() end)
    AAState.PeabertKillConn = nil
end
if not AAState.PeabertKillEnabled then return end
AAState.PeabertKillConn = RunService.RenderStepped:Connect(function()
    if not AAState.PeabertKillEnabled then return end
    local character = localPlayer.Character
    local backpack = localPlayer:FindFirstChild("Backpack")
    local gun = nil
    if character then
        for _, child in ipairs(character:GetChildren()) do
            if child:IsA("Tool")
                and (child:GetAttribute("Gun") or child:FindFirstChild("GunScript")
                    or string.lower(child.Name):find("gun")) then
                gun = child
                break
            end
        end
    end
    if not gun and backpack then
        for _, child in ipairs(backpack:GetChildren()) do
            if child:IsA("Tool")
                and (child:GetAttribute("Gun") or child:FindFirstChild("GunScript")
                    or string.lower(child.Name):find("gun")) then
                gun = child
                break
            end
        end
    end
    if not gun then return end
    local targets = {}
    local live = Workspace:FindFirstChild("Live")
    if live then
        for i = 1, 10 do
            local m = live:FindFirstChild("EvilPeabert1_" .. i)
            if m and not m:FindFirstChild("Dead") then
                targets[m.Name] = "Head"
            end
        end
        for _, child in ipairs(live:GetChildren()) do
            if not child:FindFirstChild("Dead") then
                local name = child.Name
                if name:match("^PeabertSpawn%d+$") then
                    local num = tonumber(name:match("%d+"))
                    if num and num >= 1 and num <= 31 then
                        targets[name] = "Head"
                    end
                end
                if name:lower():find("peabert") or name:lower():find("evilpeabert") then
                    targets[name] = "Head"
                end
            end
        end
    end
    for _, d in ipairs(Workspace:GetDescendants()) do
        if (d:IsA("Model") or d:IsA("BasePart")) and not d:FindFirstChild("Dead") then
            local name = d.Name
            if name:match("^EvilPeabert1_%d+$") or name:match("^PeabertSpawn%d+$")
                or name:lower():find("peabert") then
                targets[name] = "Head"
            end
        end
    end
    if next(targets) == nil then return end
    local remotes = ReplicatedStorage:FindFirstChild("Remotes")
    local firedGunClient = remotes and remotes:FindFirstChild("FiredGunClient")
    if not firedGunClient then return end
    local part = Workspace:FindFirstChild("StairWalkWay")
    part = part and part:FindFirstChild("Part") or Workspace
    local args = {
        gun,
        {
            ClientRayNormal     = Vector3.new(0, 1, 0),
            FiredGun            = true,
            SecondaryHitTargets = {},
            ClientRayInstance   = part,
            ClientRayPosition   = Vector3.zero,
            bulletCF            = CFrame.new(),
            HitTargets          = targets,
            bulletSizeC         = Vector3.new(0.01, 0.01, 5),
            NoMuzzleFX          = true,
            FirePosition        = Vector3.zero,
        },
    }
    for i = 1, AAState.PeabertShotsPerTick do
        pcall(function()
            firedGunClient:FireServer(table.unpack(args))
        end)
    end
end)
end
local function hasGroup(gb)
return gb ~= nil and type(gb.AddToggle) == "function"
end
if hasGroup(Glygj) then
Glygj:AddButton({
    Text = "传送到起点",
    Func = function() AAF.TeleportAARLGL("Start") end,
    Tooltip = "传送到管理员 RLGL 起点 (-1375, -30, 22)",
})
Glygj:AddButton({
    Text = "传送到终点",
    Func = function() AAF.TeleportAARLGL("End") end,
    Tooltip = "传送到管理员 RLGL 终点 (-1361, -28, 701)",
})
Glygj:AddDivider()
Glygj:AddToggle("AA_ESP", {
    Text = "Peaberts 透视",
    Default = false,
    Tooltip = "穿墙绿色高亮 FREEPEABERT 模型",
    Callback = function(v) AAF.TogglePeabertESP(v) end,
})
Glygj:AddButton({
    Text = "传送到最近的 Peabert",
    Func = function() AAF.TeleportToPeabert() end,
    Tooltip = "10 秒冷却",
})
end
if hasGroup(Glysl) then
Glysl:AddToggle("AA_Shoot", {
    Text = "自动射击",
    Default = false,
    Risky = true,
    Tooltip = "自动射击 Live 中名字含 peabert 的模型 (0.15s/轮)",
    Callback = function(v) AAF.TogglePeabertShoot(v) end,
})
Glysl:AddToggle("AA_SilentAim", {
    Text = "静默瞄准",
    Default = false,
    Risky = true,
    Tooltip = "钩 GunFunctions.FiredGun, 弹道自动吸附最近可杀目标",
    Callback = function(v) AAF.ToggleSilentAim(v) end,
})
Glysl:AddDivider()
Glysl:AddToggle("AA_Kill", {
    Text = "Peabert 高频击杀",
    Default = false,
    Risky = true,
    Tooltip = "RenderStepped 每帧连发命中包 (三重扫描)",
    Callback = function(v) AAF.TogglePeabertKill(v) end,
})
Glysl:AddSlider("AA_ShotsPerTick", {
    Text = "每帧射击次数",
    Default = 15,
    Min = 1,
    Max = 50,
    Rounding = 0,
    Compact = false,
    Callback = function(v) AAF.SetPeabertShotsPerTick(v) end,
    Tooltip = "对应原脚本 PeabertShotsPerTick",
})
end
if Library and Library.OnUnload then
Library:OnUnload(function()
    AAF.TogglePeabertShoot(false)
    AAF.TogglePeabertKill(false)
    AAF.TogglePeabertESP(false)
    print("Admin Abuse Suite unloaded!")
end)
end
Notify("Admin Abuse", "管理员滥用功能已加载完成")
end



-- [缝合注] 已移除原“菜单”分组中 Obsidian 专属控件（按键菜单/自定义光标库开关/通知位置/DPI/圆角）及失效的背景音乐开关

local Zzbzmd = Tabs.UISettings:AddLeftGroupbox("作者/帮助名单", "menu")
Zzbzmd:AddLabel("作者：秋辞\n拔河协助：AX\n吸附协助：柳叶\n源码提供丨前置作者：YirdeX", true)

local InfoGroup = Tabs.UISettings:AddLeftGroupbox("| AF HUB信息")
if game.PlaceId ~= 99567941238278 then
InfoGroup:AddLabel("游戏版本: " .. tostring(game.PlaceVersion))
InfoGroup:AddLabel("上次检查: " .. tostring(n))
if flag then
    InfoGroup:AddLabel("警告: 检测到游戏版本变更 - 部分功能可能已被修复。")
end
end
do
local text = "获取日志失败..."
pcall(function()
    local request_ = request or http_request or (syn and syn.request)
    if request_ then
        local v = request_({ Url = "https://platinstudio.xyz/raw/UpdateLogs", Method = "GET" })
        if not v or not v.Success or not v.Body or v.StatusCode ~= 200 then
            v = request_({ Url = "https://raw.githubusercontent.com/platinww/UwU/refs/heads/main/UI/LastUpdateLog", Method = "GET" })
        end
        if v and v.Success and v.Body then
            local out = ""
            for line in tostring(v.Body):gmatch("[^\r\n]+") do
                local clean = line:gsub("%*%*", "")
                if clean:match("^%s*%-") then
                    out ..= "> " .. clean:gsub("^%s*%-%s*", "") .. "\n"
                end
            end
            text = out ~= "" and out:gsub("\n$", "") or "未找到近期更新。"
        end
    end
end)
InfoGroup:AddLabel("最新更新日志:")
InfoGroup:AddLabel(text)
end
local MenuGroup = Tabs.UISettings:AddRightGroupbox("| 菜单")
local unlockMouse = false
MenuGroup:AddToggle("UI_UnlockMouse", {
Text = "菜单打开时解锁鼠标",
Default = false,
Callback = function(on) unlockMouse = on end,
})

local ConfigGroup = Tabs.UISettings:AddLeftGroupbox("| 配置")
local ConfigManager = {}
ConfigManager.Folder = "UwuHub"
ConfigManager.File = "UwuHub/config.json"
ConfigManager.Toggles = {}
ConfigManager.Values = {}
if not isfolder(ConfigManager.Folder) then makefolder(ConfigManager.Folder) end
function ConfigManager:RegisterToggle(key, toggleObject, callback)
self.Toggles[key] = { object = toggleObject, callback = callback }
end
function ConfigManager:RegisterValue(key, getter, setter)
self.Values[key] = { get = getter, set = setter }
end
function ConfigManager:Save()
local data = { toggles = {}, values = {} }
for key, info in pairs(self.Toggles) do
data.toggles[key] = info.object.Value
end
for key, info in pairs(self.Values) do
data.values[key] = info.get()
end
if writefile then
writefile(self.File, game:GetService("HttpService"):JSONEncode(data))
end
end
function ConfigManager:Load()
if not isfile or not isfile(self.File) then return false end
local ok, data = pcall(function()
return game:GetService("HttpService"):JSONDecode(readfile(self.File))
end)
if not ok or not data then return false end
for key, info in pairs(self.Toggles) do
local saved = data.toggles and data.toggles[key]
if saved ~= nil then
    info.object:SetValue(saved)
    pcall(function()
        info.callback(saved)
    end)
end
end
for key, info in pairs(self.Values) do
local saved = data.values and data.values[key]
if saved ~= nil then
    pcall(function() info.set(saved) end)
end
end
return true
end
btn(ConfigGroup, "保存配置", function()
ConfigManager:Save()
fn13("配置", "配置已成功保存！")
end)
btn(ConfigGroup, "加载配置", function()
ConfigManager:Load()
fn13("配置", "配置已成功加载！")
end)
ConfigGroup:AddToggle("UI_AutoLoad", {
Text = "设置自动加载",
Default = false,
Callback = function(on)
pcall(function()
    if writefile then
        writefile("UwuHub/autoload.txt", on and "true" or "false")
    end
    fn13("配置", "自动加载已设置为 " .. tostring(on))
end)
end,
})
pcall(function()
if isfile and isfile("UwuHub/autoload.txt") then
if readfile("UwuHub/autoload.txt") == "true" then
    task.defer(function()
        ConfigManager:Load()
    end)
end
end
end)
ConfigGroup:AddLabel('界面开关快捷键: 左Ctrl (LeftControl) — NothingLibrary 窗口固定快捷键')


-- [缝合注] 已移除“背景图设置”分组：NothingLibrary 不支持窗口背景图

local CursorGroup = Tabs.UISettings:AddRightGroupbox("| 自定义光标")
local cursorGui, cursorConn
tbl.customCursorEnabled = true
tbl.customCursorTextEnabled = true
tbl.customCursorRGBEnabled = true
local function rebuildCursor()
if not tbl.customCursorEnabled then
    pcall(function() UserInputService.MouseIconEnabled = true end)
    if cursorConn then cursorConn:Disconnect(); cursorConn = nil end
    if cursorGui then cursorGui:Destroy(); cursorGui = nil end
    return
end
if not cursorGui then
    cursorGui = Instance.new("ScreenGui")
    cursorGui.Name = "UwUCustomCursor"
    cursorGui.DisplayOrder = 99999
    cursorGui.IgnoreGuiInset = true
    local il = Instance.new("ImageLabel")
    il.Name = "CursorImage"
    il.BackgroundTransparency = 1
    il.Image = "rbxassetid://10769687353"
    il.Size = UDim2.new(0,32,0,32)
    il.AnchorPoint = Vector2.new(0.5,0.5)
    il.Parent = cursorGui
    local tl = Instance.new("TextLabel")
    tl.Name = "CursorText"
    tl.BackgroundTransparency = 1
    tl.Text = "AF inkgame"
    tl.TextColor3 = Color3.new(1,1,1)
    tl.TextStrokeTransparency = 0
    tl.Font = Enum.Font.GothamBold
    tl.TextSize = 14
    tl.Size = UDim2.new(0,100,0,20)
    tl.AnchorPoint = Vector2.new(0.5,0)
    tl.Visible = tbl.customCursorTextEnabled
    tl.Parent = cursorGui
    pcall(function() cursorGui.Parent = gethui and gethui() or game:GetService("CoreGui") end)
    if not cursorGui.Parent then cursorGui.Parent = localPlayer:WaitForChild("PlayerGui") end
else
    local il = cursorGui:FindFirstChild("CursorImage"); if il then il.Image = "rbxassetid://10769687353" end
    local tl = cursorGui:FindFirstChild("CursorText"); if tl then tl.Visible = tbl.customCursorTextEnabled end
end
if not cursorConn then
    UserInputService.MouseIconEnabled = false
    cursorConn = RunService.RenderStepped:Connect(function()
        pcall(function()
            UserInputService.MouseIconEnabled = false
            if not cursorGui then return end
            local m = UserInputService:GetMouseLocation()
            local il = cursorGui:FindFirstChild("CursorImage")
            if il then
                il.Position = UDim2.new(0, m.X, 0, m.Y)
                il.Rotation = il.Rotation + 2.5
                il.ImageColor3 = tbl.customCursorRGBEnabled and Color3.fromHSV(tick()%5/5, 1, 1) or Color3.new(1,1,1)
            end
            local tl = cursorGui:FindFirstChild("CursorText")
            if tl then
                tl.Position = UDim2.new(0, m.X, 0, m.Y + 20)
                tl.TextColor3 = tbl.customCursorRGBEnabled and Color3.fromHSV(tick()%5/5, 1, 1) or Color3.new(1,1,1)
            end
        end)
    end)
end
end
CursorGroup:AddToggle("UI_CursorRGB", {
Text = "关闭RGB效果",
Default = false,
Callback = function(on) tbl.customCursorRGBEnabled = not on end,
})
CursorGroup:AddToggle("UI_CursorEnabled", {
Text = "启用自定义光标",
Default = true,
Callback = function(on) tbl.customCursorEnabled = on; rebuildCursor() end,
})
CursorGroup:AddToggle("UI_CursorText", {
Text = "光标下方文字",
Default = true,
Callback = function(on) tbl.customCursorTextEnabled = on; rebuildCursor() end,
})
rebuildCursor()
pcall(function()
local getExe = identifyexecutor or getexecutorname
if getExe then
    local name = tostring(getExe()):lower()
    if name:find("xeno") or name:find("solara") then
        task.spawn(function()
            task.wait(1.5)
            Library:Notify("不支持的执行器 | 请使用更好的执行器以获得更好的体验", 10)
        end)
    end
end
end)
pcall(function()
Library:Notify("AF Hub | 请在快手或其他地方展示我的脚本", 10)
end)
if flag then
task.wait(1)
pcall(function()
    Library:Notify("警告 | 检测到游戏版本变更。部分功能可能已被修复。", 10)
end)
end

-- [缝合注] 已移除原作者活跃度上报遥测（原15463-15472行）


-- [缝合注] 已移除 Obsidian 专属 ThemeManager/SaveManager 绑定（原15473-15480行）

Library:Notify("AF Hub - AF墨水游戏 已加载完成", 10)

if not game:IsLoaded() then
    game.Loaded:Wait()
end

if game.PlaceId ~= 122245938604556 then
    return
end

local Environment = getgenv()
local Previous = Environment.__TYTongueEscape
if Previous and type(Previous.Unload) == "function" then
    Previous.Unload()
end

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local VirtualUser = game:GetService("VirtualUser")
local GuiService = game:GetService("GuiService")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")
local Player = Players.LocalPlayer
local Events = ReplicatedStorage:WaitForChild("Events", 15)
local Modules = ReplicatedStorage:WaitForChild("Modules", 15)
local SharedModule = ReplicatedStorage:WaitForChild("TongueShared", 15)
assert(Events and Modules and SharedModule, "游戏数据不可用，请重新加入游戏。")

local Shared = require(SharedModule)
local PlaytimeConfig = require(Modules:WaitForChild("PlaytimeRewardsConfig", 10))
local TrailConfig = require(Modules:WaitForChild("TrailConfigurations", 10))
local GameName = "+1 舌头逃脱 ⚡"
local FooterText = "权威不是权威"

if CoreGui:FindFirstChild("TYModernHub") then
    CoreGui.TYModernHub:Destroy()
end
if CoreGui:FindFirstChild("TYPopup") then
    CoreGui.TYPopup:Destroy()
end

local State = {
    Alive = true,
    Flags = {AutoTongue = false, AutoRebirth = false, AutoWins = false, AutoRewards = false, AutoTrails = false, AntiAFK = false, BypassPause = false},
    Status = {AutoTongue = "Off", AutoRebirth = "Off", AutoWins = "Off", AutoRewards = "Off", AutoTrails = "Off", AntiAFK = "Off", BypassPause = "Off"},
    Connections = {},
    Threads = {},
    IdleConnections = {},
    RetryAt = {},
    LastError = {},
    TongueInterval = 0.02,
    WinInterval = 1.5,
    WinGeneration = 0,
    WinMisses = 0,
    Ready = false,
}
Environment.__TYTongueEscape = State

local function Stat(Name)
    local Stats = Player:FindFirstChild("leaderstats")
    local Value = Stats and Stats:FindFirstChild(Name)
    return Value and tonumber(Value.Value) or 0
end

local function CharacterParts()
    local Character = Player.Character
    local Root = Character and Character:FindFirstChild("HumanoidRootPart")
    local Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")
    if Root and Humanoid and Humanoid.Health > 0 then
        return Character, Root, Humanoid
    end
end

local function Number(Value)
    local Text = string.format("%.0f", Value)
    return Text:reverse():gsub("(%d%d%d)", "%1,"):reverse():gsub("^,", "")
end

local function NotifyFailure(Key, Message)
    State.Status[Key] = "重试中"
    local Now = os.clock()
    if Now - (State.LastError[Key] or -math.huge) > 30 then
        State.LastError[Key] = Now
    end
end

local function Fire(Name, ...)
    local Remote = Events:FindFirstChild(Name)
    assert(Remote and Remote:IsA("RemoteEvent"), "缺少游戏事件: " .. Name)
    Remote:FireServer(...)
end

local function ReadProperty(Object, Property)
    local Success, Value = pcall(function()
        return Object[Property]
    end)
    if not Success and type(gethiddenproperty) == "function" then
        Success, Value = pcall(gethiddenproperty, Object, Property)
    end
    return Success, Value
end

local function WriteProperty(Object, Property, Value)
    local Success = pcall(function()
        Object[Property] = Value
    end)
    if not Success and type(sethiddenproperty) == "function" then
        Success, Value = pcall(sethiddenproperty, Object, Property, Value)
    end
    return Success
end

local function RestorePause()
    if State.PauseConnection then
        State.PauseConnection:Disconnect()
        State.PauseConnection = nil
    end
    if State.PauseModeChanged and State.OriginalPauseMode ~= nil then
        WriteProperty(workspace, "StreamingIntegrityMode", State.OriginalPauseMode)
    end
    if State.OriginalPauseNotice ~= nil then
        pcall(function()
            GuiService:SetGameplayPausedNotificationEnabled(State.OriginalPauseNotice)
        end)
    end
    State.PauseModeChanged = nil
    State.OriginalPauseMode = nil
    State.OriginalPauseNotice = nil
end

local function ClearPause()
    if not State.Alive or not State.Flags.BypassPause then
        return
    end
    if Player.GameplayPaused then
        local Cleared = WriteProperty(Player, "GameplayPaused", false)
        State.Status.BypassPause = Cleared and "运行中" or "遮罩已隐藏，正在加载地图"
    end
end

local function SetPauseBypass(Enabled)
    RestorePause()
    if not Enabled then
        State.Status.BypassPause = "关闭"
        return
    end
    local ReadMode, Mode = ReadProperty(workspace, "StreamingIntegrityMode")
    if ReadMode then
        State.OriginalPauseMode = Mode
        State.PauseModeChanged = WriteProperty(workspace, "StreamingIntegrityMode", Enum.StreamingIntegrityMode.Disabled)
    end
    local ReadNotice, Notice = pcall(function()
        return GuiService:GetGameplayPausedNotificationEnabled()
    end)
    if ReadNotice then
        State.OriginalPauseNotice = Notice
        pcall(function()
            GuiService:SetGameplayPausedNotificationEnabled(false)
        end)
    end
    State.PauseConnection = Player:GetPropertyChangedSignal("GameplayPaused"):Connect(ClearPause)
    State.Status.BypassPause = "运行中"
    ClearPause()
end

local function RestoreAFK()
    if State.IdleHandler then
        State.IdleHandler:Disconnect()
        State.IdleHandler = nil
    end
    for _, Connection in State.IdleConnections do
        pcall(function()
            Connection:Enable()
        end)
    end
    table.clear(State.IdleConnections)
    if State.GameAFKScript and State.GameAFKScript.Parent and State.GameAFKWasEnabled then
        pcall(function()
            State.GameAFKScript.Enabled = true
        end)
    end
    State.GameAFKScript = nil
    State.GameAFKWasEnabled = nil
end

local function SetAFK(Enabled)
    RestoreAFK()
    if not Enabled then
        State.Status.AntiAFK = "关闭"
        return
    end
    local Scripts = Player:FindFirstChild("PlayerScripts")
    local AFKScript = Scripts and Scripts:FindFirstChild("AntiAfkSystem")
    if AFKScript and AFKScript:IsA("LocalScript") then
        local Success, WasEnabled = pcall(function()
            local Old = AFKScript.Enabled
            AFKScript.Enabled = false
            return Old
        end)
        if Success then
            State.GameAFKScript = AFKScript
            State.GameAFKWasEnabled = WasEnabled
        end
    end
    if type(getconnections) == "function" then
        pcall(function()
            for _, Connection in getconnections(Player.Idled) do
                if Connection.Enabled then
                    local Success = pcall(function()
                        Connection:Disable()
                    end)
                    if Success then
                        table.insert(State.IdleConnections, Connection)
                    end
                end
            end
        end)
    end
    State.IdleHandler = Player.Idled:Connect(function()
        if not State.Alive or not State.Flags.AntiAFK then
            return
        end
        local Success = pcall(function()
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.zero)
        end)
        if not Success and #State.IdleConnections == 0 then
            State.Status.AntiAFK = "输入不可用"
        end
    end)
    State.Status.AntiAFK = "运行中"
end

local function Cleanup()
    if not State.Alive then
        return
    end
    State.Alive = false
    State.WinGeneration = State.WinGeneration + 1
    for Key in State.Flags do
        State.Flags[Key] = false
    end
    for _, Connection in State.Connections do
        Connection:Disconnect()
    end
    for _, Thread in State.Threads do
        if Thread ~= coroutine.running() then
            pcall(task.cancel, Thread)
        end
    end
    RestoreAFK()
    RestorePause()
    if Environment.__TYTongueEscape == State then
        Environment.__TYTongueEscape = nil
    end
end

	-- +1舌头逃脱：独立服务器缝合版
-- 当前服务器功能与独立界面整合版
-- 每个文件仅包含当前服务器的功能与独立关于分区

local NothingLibrary = loadstring(game:HttpGetAsync('https://raw.githubusercontent.com/quanwei-sy/qianweicangku/refs/heads/main/%E6%BA%90%E7%A0%81.lua'))()

local __BaseWindow = NothingLibrary.new({
    Title = "TY hub｜+1舌头逃脱",
    Description = "TY HUB | Roblox Script",
    Keybind = Enum.KeyCode.LeftControl,
    Logo = "http://www.roblox.com/asset/?id=99753513515576"
})

local function __ManagerStub()
    local manager = {}
    setmetatable(manager, {
        __index = function(self)
            return function()
                return self
            end
        end,
    })
    return manager
end

local Library = {
    Options = {},
    Toggles = {},
    UIElements = {},
    Unloaded = false,
    __unloadCallbacks = {},
}
local WindUI = Library
local WI = Library
local ThemeManager = __ManagerStub()
local SaveManager = __ManagerStub()
local Options = Library.Options
local Toggles = Library.Toggles
Library.ThemeManager = ThemeManager
Library.SaveManager = SaveManager
Library.Themes = {}

pcall(function()
    _G.Options = Options
    _G.Toggles = Toggles
    if type(getgenv) == "function" then
        getgenv().Options = Options
        getgenv().Toggles = Toggles
    end
end)

local function __SafeCall(callback, ...)
    if type(callback) == "function" then
        return pcall(callback, ...)
    end
end

local function __NewControl(initialValue, callback)
    local control = {
        Value = initialValue,
        __callbacks = {},
        __callback = callback,
        __syncing = false,
    }

    function control:__Fire(value, ...)
        self.Value = value
        __SafeCall(self.__callback, value, ...)
        for _, changed in ipairs(self.__callbacks) do
            __SafeCall(changed, value, ...)
        end
    end

    function control:__Callback(value, ...)
        if self.__syncing then
            return
        end
        self:__Fire(value, ...)
    end

    function control:__Attach(raw)
        self.__raw = raw
        return self
    end

    function control:OnChanged(callback)
        if type(callback) == "function" then
            table.insert(self.__callbacks, callback)
        end
        return self
    end

    function control:SetValue(value)
        self.__syncing = true
        if self.__raw and type(self.__raw.Value) == "function" then
            pcall(self.__raw.Value, value)
        end
        self.__syncing = false
        self:__Fire(value)
        return self
    end

    function control:Set(value)
        if self.__isLabel then
            return self:SetText(value)
        end
        return self:SetValue(value)
    end

    function control:SetValues(values)
        if self.__raw and type(self.__raw.Set) == "function" then
            pcall(self.__raw.Set, values)
        end
        return self
    end

    function control:Get()
        return self.Value
    end

    function control:GetValue()
        return self.Value
    end

    function control:SetText(text)
        if self.__raw and type(self.__raw.Set) == "function" then
            pcall(self.__raw.Set, tostring(text))
        end
        self.Value = text
        return self
    end

    function control:SetDesc(text)
        return self:SetText(text)
    end

    function control:SetTitle(text)
        return self:SetText(text)
    end

    function control:SetVisible(visible)
        if self.__raw and type(self.__raw.Visible) == "function" then
            pcall(self.__raw.Visible, visible)
        end
        return self
    end

    function control:Fire(...)
        if self.__raw and type(self.__raw.Fire) == "function" then
            return pcall(self.__raw.Fire, ...)
        end
        return __SafeCall(self.__callback, ...)
    end

    return control
end

local function __ControlInfo(a, b)
    if type(a) == "table" then
        return nil, a
    end
    return a, (type(b) == "table" and b or {})
end

local function __Text(info, fallback)
    return tostring(info.Text or info.Title or info.Name or fallback or "")
end

local function __Default(info)
    if info.Default ~= nil then
        return info.Default
    end
    return info.Value
end

local function __NewSection(rawSection)
    local section = { __raw = rawSection }

    function section:AddToggle(a, b)
        local key, info = __ControlInfo(a, b)
        local control = __NewControl(__Default(info) == true, info.Callback or info.Changed)
        local raw = rawSection:NewToggle({
            Title = __Text(info, "开关"),
            Default = __Default(info) == true,
            Callback = function(value)
                control:__Callback(value)
            end,
        })
        control:__Attach(raw)
        if key ~= nil then Library.Toggles[tostring(key)] = control end
        return control
    end

    section.Toggle = section.AddToggle

    function section:AddSlider(a, b)
        local key, info = __ControlInfo(a, b)
        local minValue = tonumber(info.Min) or 0
        local maxValue = tonumber(info.Max) or 100
        local defaultValue = tonumber(__Default(info)) or minValue
        local control = __NewControl(defaultValue, info.Callback or info.Changed)
        local raw = rawSection:NewSlider({
            Title = __Text(info, "滑块"),
            Min = minValue,
            Max = maxValue,
            Default = defaultValue,
            Callback = function(value)
                control:__Callback(value)
            end,
        })
        control:__Attach(raw)
        if key ~= nil then Library.Options[tostring(key)] = control end
        return control
    end

    section.Slider = section.AddSlider

    function section:AddDropdown(a, b)
        local key, info = __ControlInfo(a, b)
        local values = info.Values or info.Data or info.Options or {}
        local defaultValue = __Default(info)
        local callback = info.Callback or info.Changed
        local multi = info.Multi == true
        local selected = {}
        if multi and type(defaultValue) == "table" then
            if #defaultValue > 0 then
                for _, value in ipairs(defaultValue) do selected[value] = true end
            else
                for name, enabled in pairs(defaultValue) do
                    if enabled then selected[name] = true end
                end
            end
        end
        local control = __NewControl(multi and selected or defaultValue, callback)
        local raw = rawSection:NewDropdown({
            Title = __Text(info, "选择"),
            Data = values,
            Default = multi and "" or defaultValue,
            Callback = function(value)
                if multi then
                    selected[value] = not selected[value]
                    control:__Callback(selected)
                else
                    control:__Callback(value)
                end
            end,
        })
        control:__Attach(raw)
        if key ~= nil then Library.Options[tostring(key)] = control end
        return control
    end

    section.Dropdown = section.AddDropdown

    function section:AddInput(a, b)
        local key, info = __ControlInfo(a, b)
        local defaultValue = __Default(info)
        local control = __NewControl(defaultValue, info.Callback or info.Changed)
        rawSection:NewTextbox({
            Title = __Text(info, "输入"),
            Default = defaultValue == nil and "" or tostring(defaultValue),
            FileType = info.Placeholder and tostring(info.Placeholder) or "",
            Callback = function(value)
                control:__Callback(value)
            end,
        })
        if key ~= nil then Library.Options[tostring(key)] = control end
        return control
    end

    section.Input = section.AddInput
    section.Textbox = section.AddInput

    function section:AddButton(a, b, c)
        local info = {}
        if type(a) == "table" then
            info = a
        else
            info.Title = tostring(a or "按钮")
            if type(b) == "function" then info.Callback = b end
            if type(b) == "table" then
                for key, value in pairs(b) do info[key] = value end
            end
            if type(c) == "function" then info.Callback = c end
        end
        local callback = info.Callback or info.Func
        local control = __NewControl(nil, callback)
        local raw = rawSection:NewButton({
            Title = __Text(info, "按钮"),
            Callback = callback,
        })
        control:__Attach(raw)
        return control
    end

    section.Button = section.AddButton

    function section:AddLabel(a, b)
        local info = (type(a) == "table" and a or {Text = a})
        local text = __Text(info, "")
        if b ~= nil then text = text .. " " .. tostring(b) end
        local control = __NewControl(text)
        control.__isLabel = true
        local raw = rawSection:NewTitle(text)
        control:__Attach(raw)
        return control
    end

    section.Label = section.AddLabel

    function section:Paragraph(info)
        info = info or {}
        local title = tostring(info.Title or info.Text or "")
        local description = tostring(info.Desc or info.Description or info.Content or "")
        local text = title
        if description ~= "" then
            text = title ~= "" and (title .. "：" .. description) or description
        end
        local control = self:AddLabel(text)
        function control:SetDesc(value)
            return self:SetText((title ~= "" and (title .. "：") or "") .. tostring(value))
        end
        return control
    end

    function section:AddDivider()
        rawSection:NewTitle("──────────")
    end

    section.Divider = section.AddDivider

    function section:AddKeyPicker(a, b)
        local key, info = __ControlInfo(a, b)
        local defaultValue = __Default(info) or "RightShift"
        local keyCode = defaultValue
        if type(defaultValue) == "string" then
            keyCode = Enum.KeyCode[defaultValue] or Enum.KeyCode.RightShift
        end
        local control = __NewControl(defaultValue, info.Callback or info.Changed or info.ChangedCallback)
        local raw = rawSection:NewKeybind({
            Title = __Text(info, "按键"),
            Default = keyCode,
            Callback = function(value)
                control:__Callback(value)
            end,
        })
        control:__Attach(raw)
        if key ~= nil then Library.Options[tostring(key)] = control end
        return control
    end

    section.Keybind = section.AddKeyPicker

    function section:AddColorPicker(a, b)
        local key, info = __ControlInfo(a, b)
        local defaultValue = __Default(info) or Color3.new(1, 1, 1)
        local control = __NewControl(defaultValue, info.Callback or info.Changed)
        local defaultHex = "#FFFFFF"
        pcall(function() defaultHex = "#" .. defaultValue:ToHex() end)
        rawSection:NewTextbox({
            Title = __Text(info, "颜色") .. "（Hex）",
            Default = defaultHex,
            Callback = function(value)
                local ok, color = pcall(Color3.fromHex, tostring(value))
                if ok then control:__Callback(color) end
            end,
        })
        if key ~= nil then Library.Options[tostring(key)] = control end
        return control
    end

    section.ColorPicker = section.AddColorPicker

    return section
end

local function __NewTab(rawTab)
    local tab = { __raw = rawTab, __left = 0, __right = 0 }

    function tab:AddLeftGroupbox(name)
        self.__left = self.__left + 1
        return __NewSection(rawTab:NewSection({
            Title = tostring(name or "功能"),
            Icon = "rbxassetid://7743869054",
            Position = "Left",
        }))
    end

    function tab:AddRightGroupbox(name)
        self.__right = self.__right + 1
        return __NewSection(rawTab:NewSection({
            Title = tostring(name or "信息"),
            Icon = "rbxassetid://7733964719",
            Position = "Right",
        }))
    end

    function tab:__DefaultSection()
        if not self.__defaultSection then
            self.__defaultSection = self:AddLeftGroupbox("主要功能")
        end
        return self.__defaultSection
    end

    function tab:Section(info)
        local title = (type(info) == "table" and (info.Title or info.Name)) or info or "功能"
        self.__defaultSection = self:AddLeftGroupbox(title)
        return self.__defaultSection
    end

    function tab:Toggle(info) return self:__DefaultSection():Toggle(info) end
    function tab:Slider(info) return self:__DefaultSection():Slider(info) end
    function tab:Dropdown(info) return self:__DefaultSection():Dropdown(info) end
    function tab:Input(info) return self:__DefaultSection():Input(info) end
    function tab:Textbox(info) return self:__DefaultSection():Textbox(info) end
    function tab:Button(info) return self:__DefaultSection():Button(info) end
    function tab:Paragraph(info) return self:__DefaultSection():Paragraph(info) end
    function tab:Label(info) return self:__DefaultSection():Label(info) end
    function tab:Divider() return self:__DefaultSection():Divider() end
    function tab:Keybind(info) return self:__DefaultSection():Keybind(info) end
    function tab:ColorPicker(info) return self:__DefaultSection():ColorPicker(info) end

    return tab
end

local function __NewWindow()
    local window = { Window = __BaseWindow, UIElements = {} }

    function window:AddTab(name)
        return __NewTab(__BaseWindow:NewTab({
            Title = tostring(name or "页面"),
            Description = tostring(name or "功能"),
            Icon = "rbxassetid://7733960981",
        }))
    end

    function window:Tab(info)
        local title = (type(info) == "table" and (info.Title or info.Name)) or info or "页面"
        return self:AddTab(title)
    end

    function window:Tag() return self end
    function window:EditOpenButton() return self end
    function window:SelectTab() return self end
    function window:SetTheme() return self end
    function window:SetBackground() return self end
    function window:SetUIScale() return self end
    function window:SetScale() return self end
    function window:SetWatermark() return self end
    function window:SetToggleKey() return self end
    function window:SetNotification() return self end
    function window:SetTitle() return self end

    function window:AddDialog()
        return { Dismiss = function() end }
    end

    function window:Dialog()
        return { Dismiss = function() end }
    end

    function window:Notify(info)
        return Library:Notify(info)
    end

    function window:Destroy()
        return Library:Unload()
    end

    function window:Unload()
        return Library:Unload()
    end

    function window:Show() end
    function window:Hide() end
    function window:Open() end
    function window:Close() end
    function window:Toggle() end

    return window
end

function Library:CreateWindow()
    self.__window = self.__window or __NewWindow()
    return self.__window
end

function Library:Notify(info, duration)
    local title, description = "提示", ""
    if type(info) == "table" then
        title = tostring(info.Title or info.Name or "提示")
        description = tostring(info.Content or info.Description or info.Desc or info.Text or "")
        duration = info.Duration or info.Time or duration
    else
        description = tostring(info or "")
    end
    pcall(function()
        local notification = NothingLibrary.Notification()
        notification.new({
            Title = title,
            Description = description,
            Duration = tonumber(duration) or 4,
            Icon = "rbxassetid://7733993369",
        })
    end)
end

function Library:OnUnload(callback)
    if type(callback) == "function" then
        table.insert(self.__unloadCallbacks, callback)
    end
end

function Library:Unload()
    if self.Unloaded then return end
    self.Unloaded = true
    for _, callback in ipairs(self.__unloadCallbacks) do
        __SafeCall(callback)
    end
end

function Library:AddTheme() end
function Library:SetTheme() end
function Library:SetColorScheme() end
function Library:SetUIScale() end
function Library:SetWatermark() end
function Library:SetWatermarkVisibility() end

local __AboutTab = __BaseWindow:NewTab({
    Title = "关于",
    Description = "作者与联系方式",
    Icon = "rbxassetid://7733964719",
})
local __AboutSection = __AboutTab:NewSection({
    Title = "关于",
    Icon = "rbxassetid://7733964719",
    Position = "Left",
})
__AboutSection:NewTitle("作者：权威不是权威")
__AboutSection:NewTitle("脚本QQ1群948082232")
__AboutSection:NewTitle("QQ2群1105225845")
__AboutSection:NewTitle("作者QQ：3935754168")



local Window = Library:CreateWindow({
	Title = GameName,
	Footer = FooterText,
	Center = true,
	AutoShow = true,
})

local Tabs = {
	Main = Window:AddTab("主页", "user"),
	["UI设置"] = Window:AddTab("UI设置", "settings"),
}

local MainBox = Tabs.Main:AddLeftGroupbox("自动化功能")
MainBox:AddToggle("AutoTongue", { Text = "跑步机循环传送", Default = false })
MainBox:AddToggle("TreadmillDefault", { Text = "跑步机 Default", Default = false })
MainBox:AddToggle("TreadmillDiamond", { Text = "跑步机 Diamond", Default = false })
MainBox:AddToggle("TreadmillFuturistic", { Text = "跑步机 Futuristic Treadmill", Default = false })
MainBox:AddToggle("TreadmillGalaxy", { Text = "跑步机 Galaxy", Default = false })
MainBox:AddToggle("TreadmillGolden", { Text = "跑步机 Golden", Default = false })
MainBox:AddToggle("TreadmillHacker", { Text = "跑步机 Hacker", Default = false })
MainBox:AddToggle("TreadmillRainbow", { Text = "跑步机 Rainbow", Default = false })
MainBox:AddToggle("AutoRebirth", { Text = "自动转生", Default = false })
MainBox:AddToggle("AutoWins", { Text = "自动刷胜场", Default = false })
MainBox:AddToggle("AutoRewards", { Text = "自动领奖励", Default = false })
MainBox:AddToggle("AutoTrails", { Text = "自动购买装备轨迹", Default = false })
MainBox:AddToggle("AntiAFK", { Text = "防挂机保护", Default = false })
MainBox:AddToggle("BypassPause", { Text = "绕过暂停遮罩", Default = false })

for _, Key in ipairs({ "AutoTongue", "AutoRebirth", "AutoWins", "AutoRewards", "AutoTrails", "AntiAFK", "BypassPause", "TreadmillDefault", "TreadmillDiamond", "TreadmillFuturistic", "TreadmillGalaxy", "TreadmillGolden", "TreadmillHacker", "TreadmillRainbow" }) do
    Toggles[Key]:OnChanged(function(Value)
        State.Flags[Key] = Value
        State.Status[Key] = Value and "启动中" or "关闭"
        if Key == "AntiAFK" then
            SetAFK(Value)
        elseif Key == "BypassPause" then
            SetPauseBypass(Value)
        elseif Key == "AutoWins" then
            State.WinGeneration = State.WinGeneration + 1
            State.WinMisses = 0
        elseif Key == "AutoTongue" then
            State.TreadmillPhase = 0
        end
    end)
end

local StatusBox = Tabs.Main:AddRightGroupbox("实时状态看板")
local StatusLabel = StatusBox:AddLabel({ Text = "正在初始化数据看板...", DoesWrap = true })

table.insert(State.Threads, task.spawn(function()
    while State.Alive do
        pcall(function()
            local tongue = Number(Stat("Tongue"))
            local level = Number(Stat("Level"))
            local wins = Number(Stat("Wins"))
            local rebirths = Number(Stat("Rebirths"))
            StatusLabel:SetText(string.format("舌头: %s  等级: %s\n胜场: %s  转生: %s", tongue, level, wins, rebirths))
        end)
        task.wait(1)
    end
end))


local MenuGroup = Tabs["UI设置"]:AddLeftGroupbox("菜单")

local LastUnloadAt

MenuGroup:AddButton("卸载脚本", function()
	local function DoUnload()
		task.defer(function()
			pcall(function()
				Library:Unload()
			end)
		end)
	end

	local OkDialog = pcall(function()
		Window:AddDialog("TYUnloadConfirm", {
			Title = "卸载脚本",
			Description = "确定要卸载脚本吗？所有已启用的功能将被关闭，脚本随即终止。",
			AutoDismiss = false,
			OutsideClickDismiss = false,
			FooterButtons = {
				Cancel = {
					Title = "取消",
					Variant = "Ghost",
					Order = 1,
					Callback = function(Dialog)
						Dialog:Dismiss()
					end,
				},
				Unload = {
					Title = "卸载",
					Variant = "Destructive",
					Order = 2,
					Callback = function(Dialog)
						Dialog:Dismiss()
						DoUnload()
					end,
				},
			},
		})
	end)

	if OkDialog then
		return
	end

	if not LastUnloadAt or (os.clock() - LastUnloadAt) > 5 then
		LastUnloadAt = os.clock()
		pcall(function()
			Library:Notify("再次点击「卸载脚本」确认卸载，5 秒内有效")
		end)
		return
	end

	LastUnloadAt = nil
	DoUnload()
end)

MenuGroup:AddLabel("菜单快捷键")
MenuGroup:AddKeyPicker("MenuKeybind", {
	Default = "RightShift",
	Visible = false,
	Text = "菜单快捷键",
})

Library.ToggleKeybind = Library.Options and Library.Options.MenuKeybind

local ThemeManager = Library.ThemeManager
local SaveManager = Library.SaveManager

if type(ThemeManager) == "table" then
	pcall(function()
		ThemeManager:SetLibrary(Library)
		ThemeManager:SetFolder("TYUITheme")
		ThemeManager:ApplyToTab(Tabs["UI设置"])
	end)
end

if type(SaveManager) == "table" then
	pcall(function()
		SaveManager:SetLibrary(Library)
		SaveManager:SetFolder("TYUIConfig")
		SaveManager:BuildConfigSection(Tabs["UI设置"])
	end)
end

Library:OnUnload(function()
    Cleanup()
end)

local function StartLoop(Key, Interval, Action)
    local Thread = task.spawn(function()
        while State.Alive do
            if State.Flags[Key] then
                local Success = pcall(Action)
                if not Success and State.Alive and State.Flags[Key] then
                    NotifyFailure(Key, "功能不可用，重试中...")
                    task.wait(2)
                end
            end
            task.wait(type(Interval) == "function" and Interval() or Interval)
        end
    end)
    table.insert(State.Threads, Thread)
end

local TreadmillFlags = {
    "TreadmillDefault", "TreadmillDiamond", "TreadmillFuturistic", "TreadmillGalaxy",
    "TreadmillGolden", "TreadmillHacker", "TreadmillRainbow",
}
local TreadmillRoots = {
    TreadmillDefault = "Default",
    TreadmillDiamond = "Diamond",
    TreadmillFuturistic = "Futuristic Treadmill",
    TreadmillGalaxy = "Galaxy",
    TreadmillGolden = "Golden",
    TreadmillHacker = "Hacker",
    TreadmillRainbow = "Rainbow",
}

StartLoop("AutoTongue", function()
    return State.TongueInterval
end, function()
    local Character, Root, Humanoid = CharacterParts()
    if not Root then
        return
    end
    local Trainers = workspace:FindFirstChild("Map") and workspace.Map:FindFirstChild("Lobby") and workspace.Map.Lobby:FindFirstChild("Trainers")
    if not Trainers then
        State.Status.AutoTongue = "训练区不可用"
        return
    end
    local Pick = nil
    for _, Key in ipairs(TreadmillFlags) do
        if State.Flags[Key] then
            Pick = TreadmillRoots[Key]
            break
        end
    end
    local Name = Pick
    if not Name then
        State.Status.AutoTongue = "未选择跑步机"
        return
    end
    local Target = Trainers:FindFirstChild(Name)
    if not Target then
        State.Status.AutoTongue = "跑步机不可用"
        return
    end
    local Pivot = Target:IsA("BasePart") and Target.CFrame or Target:GetPivot()
    local Phase = State.TreadmillPhase or 0
    if Phase == 0 then
        pcall(function()
            Character:PivotTo(CFrame.new(Pivot.Position + Vector3.new(0, 5, 0)))
        end)
        State.Status.AutoTongue = Name .. " 上机"
        task.wait(2.5)
        State.TreadmillPhase = 1
    else
        pcall(function()
            Character:PivotTo(CFrame.new(Pivot.Position + Vector3.new(5, 0, 5)))
        end)
        State.Status.AutoTongue = Name .. " 复位"
        task.wait(1)
        State.TreadmillPhase = 0
    end
end)

StartLoop("AutoRebirth", 1, function()
    local Required = Shared.levelForRebirth(Stat("Rebirths"))
    if Stat("Level") < Required then
        return
    end
    local Remote = Events:FindFirstChild("RequestRebirth")
    assert(Remote and Remote:IsA("RemoteFunction"), "转生功能不可用")
    Remote:InvokeServer()
end)

StartLoop("AutoTrails", 1, function()
    local Owned = Player:FindFirstChild("Trails")
    if not Owned then
        return
    end
    local BestOwned, Purchase
    local Wins = Stat("Wins")
    for _, Trail in TrailConfig.Trails do
        if Owned:FindFirstChild(Trail.ID) then
            if not BestOwned or Trail.TongueBoost > BestOwned.TongueBoost then
                BestOwned = Trail
            end
        elseif type(Trail.WinCost) == "number" and Trail.WinCost >= 0 then
            if Trail.WinCost <= Wins and (not Purchase or Trail.TongueBoost > Purchase.TongueBoost) then
                Purchase = Trail
            end
        end
    end
    local Now = os.clock()
    local Equipped = Owned:FindFirstChild("Equipped")
    if BestOwned and Equipped and Equipped.Value ~= BestOwned.ID and Now >= (State.RetryAt.EquipTrail or 0) then
        Fire("TrailAction", "Equip", BestOwned.ID)
        State.RetryAt.EquipTrail = Now + 3
    end
    if Purchase then
        Fire("TrailAction", "BuyWins", Purchase.ID)
    end
end)

local function BestWinButton()
    local Map = workspace:FindFirstChild("Map")
    local GiveWins = Map and Map:FindFirstChild("GiveWins")
    local Row = GiveWins and GiveWins:FindFirstChild("OneWin")
    if not Row then
        return
    end
    local Best, BestAmount = nil, -1
    for _, Model in Row:GetChildren() do
        local Amount = tonumber(Model:GetAttribute("WinAmount")) or 0
        if Model:IsA("Model") and Amount > BestAmount then
            Best, BestAmount = Model, Amount
        end
    end
    return Best, BestAmount
end

StartLoop("AutoWins", function()
    return State.WinInterval
end, function()
    local Character, Root, Humanoid = CharacterParts()
    if not Root then
        return
    end
    local Generation = State.WinGeneration
    local Model, Amount = BestWinButton()
    if not Model then
        return
    end
    local Pivot = Model:GetPivot()
    local Touch = Model:FindFirstChild("Touch")
    if not Touch then
        pcall(function()
            Player:RequestStreamAroundAsync(Pivot.Position, 3)
        end)
        Touch = Model:FindFirstChild("Touch")
    end
    if not State.Alive or not State.Flags.AutoWins or Generation ~= State.WinGeneration or Player.Character ~= Character then
        return
    end
    local Before = Stat("Wins")
    local UsedTouch = false
    if Touch and Touch:IsA("BasePart") and type(firetouchinterest) == "function" and State.WinMisses < 2 then
        UsedTouch = pcall(function()
            firetouchinterest(Root, Touch, 0)
            task.wait(0.1)
            if Root.Parent and Touch.Parent then
                firetouchinterest(Root, Touch, 1)
            end
        end)
    end
    if not UsedTouch then
        local Target = Touch and Touch.CFrame or Pivot
        Humanoid.Sit = false
        if (Root.Position - Target.Position).Magnitude < 12 then
            Character:PivotTo(Target + Vector3.new(0, 7, 14))
            task.wait(0.15)
        end
        Root.AssemblyLinearVelocity = Vector3.zero
        Root.AssemblyAngularVelocity = Vector3.zero
        Character:PivotTo(Target + Vector3.new(0, 3, 0))
    end
    local Deadline = os.clock() + 1.2
    repeat
        task.wait(0.1)
    until not State.Alive or not State.Flags.AutoWins or Generation ~= State.WinGeneration or Stat("Wins") > Before or os.clock() >= Deadline
    if State.Alive and State.Flags.AutoWins and Generation == State.WinGeneration then
        local Collected = Stat("Wins") > Before
        State.WinMisses = Collected and 0 or State.WinMisses + 1
    end
end)

local function ClaimOnce(Key, Remote, Cooldown, ...)
    if not State.Flags.AutoRewards or not State.Alive then
        return
    end
    local Now = os.clock()
    if Now < (State.RetryAt[Key] or 0) then
        return
    end
    Fire(Remote, ...)
    State.RetryAt[Key] = Now + Cooldown
    task.wait(0.2)
end

StartLoop("AutoRewards", 5, function()
    local Now = workspace:GetServerTimeNow()
    local Start = Player:GetAttribute("PlaytimeStart")
    local Elapsed = typeof(Start) == "number" and math.max(0, (tonumber(Player:GetAttribute("PlaytimeBase")) or 0) + Now - Start) or 0
    local Claimed = {}
    for Index in tostring(Player:GetAttribute("PlaytimeClaimed") or ""):gmatch("%d+") do
        Claimed[tonumber(Index)] = true
    end
    for Index, Reward in PlaytimeConfig.Rewards do
        if not Claimed[Index] and Elapsed >= Reward.Minute * 60 then
            ClaimOnce("Playtime" .. Index, "PlaytimeClaim", 10, Index)
        end
    end
    local LastDaily = tonumber(Player:GetAttribute("DailyLastClaim"))
    if LastDaily and (LastDaily <= 0 or Now - LastDaily >= 86400) then
        ClaimOnce("Daily", "DailyClaim", 15)
    end
    if Player:GetAttribute("LeaveBonusClaimed") == false then
        ClaimOnce("LeaveBonus", "LeaveBonusClaim", 30)
    end
    if Player:GetAttribute("GroupRewardClaimed") == false then
        local CheckAt = State.RetryAt.GroupCheck or 0
        if os.clock() >= CheckAt then
            State.RetryAt.GroupCheck = os.clock() + 120
            local Success, Member = pcall(function()
                return Player:IsInGroupAsync(602332660)
            end)
            if Success and Member then
                ClaimOnce("Group", "GroupRewardClaim", 120)
            end
        end
    end
end)

SetPauseBypass(true)
State.Ready = true

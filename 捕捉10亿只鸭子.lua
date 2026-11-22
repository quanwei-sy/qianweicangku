
	-- 捕捉10亿只鸭子：独立服务器缝合版
-- 当前服务器功能与独立界面整合版
-- 每个文件仅包含当前服务器的功能与独立关于分区

local NothingLibrary = loadstring(game:HttpGetAsync('https://raw.githubusercontent.com/quanwei-sy/qianweicangku/refs/heads/main/%E6%BA%90%E7%A0%81.lua'))()

local __BaseWindow = NothingLibrary.new({
    Title = "TY hub｜捕捉10亿只鸭子",
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


local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CollectionService = game:GetService("CollectionService")
local LocalPlayer = Players.LocalPlayer
local StarterGui = game:GetService("StarterGui")
local UserInputService = game:GetService("UserInputService")


_G.AutoAttack = false
_G.AutoGrab = false
_G.AutoSell = false
_G.AutoUpgrade = false
_G.AutoFly = false
_G.AntiAfk = false
_G.InfJump = false
_G.DuckESP = false
local AttackInterval = 0.2
local MaxDistance = 1000
local SellMode = 1
local UpgradeInterval = 10
local WalkSpeedValue = 16
local FlySpeedValue = 50
local UUID = "ca49cb12-5ea1-4df3-b30f-56f08d22feac"

local Cap = { shoot = nil, seq = nil, interact = nil, sell = nil, upgrade = nil, crate = nil }
local Recording = false
local RecLog = {}
local CurrentSequence = 1

local function Notify(msg)
    pcall(function()
        StarterGui:SetCore("SendNotification", { Title = "鸭子脚本", Text = msg, Duration = 3 })
    end)
end

local rawNamecall
rawNamecall = hookmetamethod(game, "__namecall", function(self, ...)
    local method = getnamecallmethod()
    local args = { ... }

    if method == "FireServer" or method == "fireServer" then

        if #args == 1 and type(args[1]) == "number" then
            Cap.seq = self
        end

        if #args == 5 and args[5] == "Shoot" then
            Cap.shoot = self
        end
    elseif method == "InvokeServer" or method == "invokeServer" then

        if #args == 1 and type(args[1]) == "userdata" and not Cap.interact then
            Cap.interact = self
        end

        if #args == 0 and not Cap.sell then
            Cap.sell = self
        end

        if #args == 3 and type(args[1]) == "string" and type(args[2]) == "string" then
            Cap.upgrade = self
        end

        for i = 1, #args do
            if type(args[i]) == "string" and string.find(args[i], "Crate") then
                Cap.crate = self
                break
            end
        end
    end
    return rawNamecall(self, ...)
end)

local function GetClosestTarget()
    local myChar = LocalPlayer.Character
    if not myChar or not myChar:FindFirstChild("HumanoidRootPart") then return nil, nil end
    local myPos = myChar.HumanoidRootPart.Position
    local closestPos, targetName, shortestDist = nil, "", MaxDistance
    for _, obj in ipairs(workspace:GetDescendants()) do
        if string.find(obj.Name, "DuckController_Client") or string.find(obj.Name, "BossController_Client") then
            local targetPos = nil
            if obj:IsA("BasePart") then
                targetPos = obj.Position
            elseif obj:IsA("Model") then
                targetPos = obj.PrimaryPart and obj.PrimaryPart.Position or nil
                if not targetPos then
                    local cp = obj:FindFirstChildWhichIsA("BasePart", true)
                    if cp then targetPos = cp.Position end
                end
            end
            if targetPos then
                local dist = (targetPos - myPos).Magnitude
                if dist < shortestDist then
                    shortestDist = dist
                    closestPos = targetPos
                    targetName = obj.Name
                end
            end
        end
    end
    return closestPos, targetName
end

local function ExecuteAttack()
    if not Cap.seq or not Cap.shoot then return end
    local myChar = LocalPlayer.Character
    if not myChar or not myChar:FindFirstChild("HumanoidRootPart") then return end
    local targetPos, targetName = GetClosestTarget()
    if not targetPos then return end
    local myPos = myChar.HumanoidRootPart.Position
    local direction = (targetPos - myPos).Unit
    local timestamp = workspace:GetServerTimeNow()
    CurrentSequence = CurrentSequence + 1
    pcall(function()
        Cap.seq:FireServer(CurrentSequence)
        Cap.shoot:FireServer(myPos, direction, CurrentSequence, timestamp, "Shoot")
    end)
end

task.spawn(function()
    while true do
        if _G.AutoAttack and not _G.PickingUp then
            ExecuteAttack()
        end
        task.wait(AttackInterval)
    end
end)

local function GetHRP()
    local c = LocalPlayer.Character
    return c and c:FindFirstChild("HumanoidRootPart") or nil
end
local function GetHum()
    local c = LocalPlayer.Character
    return c and c:FindFirstChildOfClass("Humanoid") or nil
end

task.spawn(function()
    while true do
        if _G.AutoAttack or true then
            local hum = GetHum()
            if hum then
                hum.WalkSpeed = WalkSpeedValue
            end
        end
        task.wait(1)
    end
end)

local FlyConn = nil
task.spawn(function()
    while true do
        if _G.AutoFly then
            local hrp = GetHRP()
            if hrp then
                local vel = Instance.new("Vector3Velocity")
                vel.MaxForce = Vector3.new(1e5, 1e5, 1e5)
                vel.Velocity = Vector3.new(0, FlySpeedValue, 0)
                vel.Parent = hrp
                task.wait(1)
                vel:Destroy()
            end
        end
        task.wait(0.5)
    end
end)

local Jumping = false
task.spawn(function()
    while true do
        if _G.InfJump then
            local hum = GetHum()
            if hum and not Jumping then
                Jumping = true
                hum:ChangeState(Enum.HumanoidStateType.Jumping)
                task.wait(0.05)
                Jumping = false
            end
        end
        task.wait(0.05)
    end
end)

local LastPos = nil
task.spawn(function()
    while true do
        if _G.AntiAfk then
            local hrp = GetHRP()
            if hrp then
                if LastPos and (hrp.Position - LastPos).Magnitude < 1 then
                    hrp.CFrame = hrp.CFrame * CFrame.new(0, 0.5, 0)
                end
                LastPos = hrp.Position
            end
        end
        task.wait(120)
    end
end)

local ESPObjs = {}
local function ClearESP()
    for _, obj in ipairs(ESPObjs) do
        pcall(function() obj:Destroy() end)
    end
    ESPObjs = {}
end

task.spawn(function()
    while true do
        if _G.DuckESP then
            for _, obj in ipairs(workspace:GetDescendants()) do
                if (string.find(obj.Name, "DuckController_Client") or string.find(obj.Name, "BossController_Client"))
                    and not obj:FindFirstChild("DuckESP_Tag") then
                    local tag = Instance.new("BillboardGui")
                    tag.Name = "DuckESP_Tag"
                    tag.Size = UDim2.new(0, 120, 0, 24)
                    tag.AlwaysOnTop = true
                    tag.Adornee = obj
                    local lbl = Instance.new("TextLabel")
                    lbl.Size = UDim2.new(1, 0, 1, 0)
                    lbl.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
                    lbl.BackgroundTransparency = 0.3
                    lbl.TextColor3 = Color3.fromRGB(255, 60, 60)
                    lbl.Text = "鸭子"
                    lbl.Parent = tag
                    tag.Parent = obj
                    table.insert(ESPObjs, tag)
                end
            end
            task.wait(1)
        else
            ClearESP()
            task.wait(1)
        end
    end
end)

local function CopyText(text)
    if setclipboard then
        local ok2 = pcall(function() setclipboard(text) end)
        if ok2 then return true end
    end
    if toclipboard then
        local ok2 = pcall(function() toclipboard(text) end)
        if ok2 then return true end
    end
    if writefile then
        local ok2 = pcall(writefile, "CatchDucks_rec.txt", text)
        if ok2 then Notify("已存 CatchDucks_rec.txt"); return true end
    end
    return false
end

local Window = WindUI:CreateWindow({
Title = "捕捉10亿只鸭子",
Author = "权威不是权威",
})

Window:EditOpenButton({
    Title = "TY",
    Icon = "duck",
    CornerRadius = UDim.new(0, 16),
    StrokeThickness = 2,
    Color = ColorSequence.new(Color3.fromHex("FF6B6B")),
    Draggable = true,
})

if Window then
    pcall(function() Window.IsPC = false end)
end

local TabAtk = Window:Tab({ Title = "攻击", Icon = "sword", Locked = false })
TabAtk:Section({ Title = "自动射击", TextXAlignment = "Left", TextSize = 17 })
TabAtk:Toggle({
    Title = "自动攻击",
    Default = false,
    Callback = function(v)
        _G.AutoAttack = v
        Notify(v and "自动攻击已开启" or "自动攻击已关闭")
    end,
})

local TabMove = Window:Tab({ Title = "移动", Icon = "run", Locked = false })
TabMove:Section({ Title = "移动辅助", TextXAlignment = "Left", TextSize = 17 })
TabMove:Slider({
    Title = "移速",
    Value = { Min = 16, Max = 120, Default = 16 },
    Increment = 1,
    Callback = function(v) WalkSpeedValue = v end,
})
TabMove:Toggle({
    Title = "飞行",
    Default = false,
    Callback = function(v)
        _G.AutoFly = v
        Notify(v and "飞行已开启(上升)" or "飞行已关闭")
    end,
})
TabMove:Slider({
    Title = "飞行上升速度",
    Value = { Min = 20, Max = 300, Default = 50 },
    Increment = 10,
    Callback = function(v) FlySpeedValue = v end,
})
TabMove:Toggle({
    Title = "无限跳",
    Default = false,
    Callback = function(v)
        _G.InfJump = v
        Notify(v and "无限跳已开启" or "无限跳已关闭")
    end,
})
TabMove:Toggle({
    Title = "防挂机",
    Default = false,
    Callback = function(v)
        _G.AntiAfk = v
        Notify(v and "防挂机已开启" or "防挂机已关闭")
    end,
})
TabMove:Section({ Title = "移动辅助", TextXAlignment = "Left", TextSize = 17 })
local TabAdv = Window:Tab({ Title = "进阶", Icon = "star", Locked = false })
TabAdv:Toggle({
    Title = "鸭子/Boss ESP",
    Default = false,
    Callback = function(v)
        _G.DuckESP = v
        Notify(v and "ESP已开启" or "ESP已关闭")
    end,
})

WindUI:Notify({
    Title = "捕捉10亿只鸭子加载成功",
    Content = "脚本已就绪",
    Duration = 3,
})

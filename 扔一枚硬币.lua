
	-- 扔一枚硬币：独立服务器缝合版
-- 当前服务器功能与独立界面整合版
-- 每个文件仅包含当前服务器的功能与独立关于分区

local NothingLibrary = loadstring(game:HttpGetAsync('https://raw.githubusercontent.com/quanwei-sy/qianweicangku/refs/heads/main/%E6%BA%90%E7%A0%81.lua'))()

local __BaseWindow = NothingLibrary.new({
    Title = "TY hub｜扔一枚硬币",
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


local P = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local UIS = game:GetService("UserInputService")
local C = game:GetService("CoreGui")
local LP = P.LocalPlayer
if not LP then return end

for _, g in ipairs(C:GetChildren()) do
    if g:IsA("ScreenGui") and (g.Name == "A" or g.Name:find("Coin") or g.Name == "WindUI") then
        pcall(function() g:Destroy() end)
    end
end

local Events = RS:FindFirstChild("Assets") and RS.Assets:FindFirstChild("Events")
local CoinLanded = Events and Events:FindFirstChild("CoinLanded")
local RequestUpgrade = Events and Events:FindFirstChild("RequestUpgrade")
local BuyCoin = Events and Events:FindFirstChild("BuyCoin")
local SellAll = Events and Events:FindFirstChild("SellAll")

local S = {
    AutoThrow = false, AutoBuyCoin = false, AutoUpgradeLuck = false,
    AutoUpgradeValue = false, AutoSell = false, Speed = false, Fly = false,
    ThrowMultiplier = 3, SpeedVal = 50, FlySpeed = 50
}

local WN, WN_visible = nil, false
local UI = {}
local toggleKey = Enum.KeyCode.F4
local toggleLock = 0
local coinDebounce, sellDebounce, luckDebounce, valDebounce = 0, 0, 0, 0
local flyBV2, flyGyro2, flyCtrl, flyHeartbeat2 = nil, nil, nil, nil
local coinList = {"Paradox Coin", "Lucky Coin", "Golden Coin", "Obsidian Coin", "Platinum Coin", "Ruby Coin", "Emerald Coin", "Amethyst Coin", "Topaz Coin", "Diamond Coin", "Staff Token", "VIP Token", "Developer Token", "Diamond Token"}

local function flipToggle(flag)
    S[flag] = not S[flag]
    if UI[flag] and type(UI[flag].Set) == "function" then pcall(function() UI[flag]:Set(S[flag]) end) end
    return S[flag]
end

local function getCoinName()
    local pg = LP:FindFirstChild("PlayerGui")
    local n = pg and pg:FindFirstChild("UiFolder") and pg.UiFolder:FindFirstChild("Main")
        and pg.UiFolder.Main:FindFirstChild("HUD") and pg.UiFolder.Main.HUD:FindFirstChild("Coin")
        and pg.UiFolder.Main.HUD.Coin:FindFirstChild("Main") and pg.UiFolder.Main.HUD.Coin.Main:FindFirstChild("CoinName")
    if n and n:IsA("TextLabel") and n.Text ~= "" then return n.Text end
    return nil
end

local function getMultiplier()
    local pg = LP:FindFirstChild("PlayerGui")
    local tb = pg and pg:FindFirstChild("UiFolder") and pg.UiFolder:FindFirstChild("Main")
        and pg.UiFolder.Main:FindFirstChild("HUD") and pg.UiFolder.Main.HUD:FindFirstChild("ThrowBar")
        and pg.UiFolder.Main.HUD.ThrowBar:FindFirstChild("CurrentMulti")
    if tb and tb:IsA("Frame") then return tb.Size.X.Scale * 3 end
    return 0
end

local function getHRP()
    local c = LP.Character
    return c and c:FindFirstChild("HumanoidRootPart")
end

local function formatNum(v)
    if v == math.floor(v) then return tostring(math.floor(v)) end
    return string.format("%.1f", v)
end

local function doThrow()
    if not S.AutoThrow or not CoinLanded then return end
    if getMultiplier() < S.ThrowMultiplier then return end
    local coinName = getCoinName()
    if not coinName then return end
    local hrp = getHRP()
    if not hrp then return end
    local pos = hrp.Position + Vector3.new(0, -0.5, -2)
    CoinLanded:FireServer(S.ThrowMultiplier, pos, coinName, nil, nil)
    task.wait(0.5)
end

local function doBuyCoin()
    if not S.AutoBuyCoin or not BuyCoin then return end
    if tick() - coinDebounce < 3 then return end
    if getCoinName() then return end
    coinDebounce = tick()
    for _, name in ipairs(coinList) do
        pcall(function() BuyCoin:FireServer(name) end)
        task.wait(0.1)
    end
end

local function doUpgradeLuck()
    if not S.AutoUpgradeLuck or not RequestUpgrade then return end
    if tick() - luckDebounce < 1 then return end
    luckDebounce = tick()
    pcall(function() RequestUpgrade:FireServer("Luck Multiplier") end)
end

local function doUpgradeValue()
    if not S.AutoUpgradeValue or not RequestUpgrade then return end
    if tick() - valDebounce < 1 then return end
    valDebounce = tick()
    pcall(function() RequestUpgrade:FireServer("Value Multiplier") end)
end

local function doSell()
    if not S.AutoSell or not SellAll then return end
    if tick() - sellDebounce < 2 then return end
    sellDebounce = tick()
    SellAll:FireServer()
end

local function toggleFly(on)
    if flyHeartbeat2 then flyHeartbeat2:Disconnect(); flyHeartbeat2 = nil end
    if flyBV2 then flyBV2:Destroy(); flyBV2 = nil end
    if flyGyro2 then flyGyro2:Destroy(); flyGyro2 = nil end
    local c = LP.Character
    if not c then return end
    local h = c:FindFirstChildOfClass("Humanoid")
    if not h then return end
    if on then
        h.PlatformStand = true
        flyCtrl = {f = 0, b = 0, l = 0, r = 0}
        local torso = c:FindFirstChild("Torso") or c:FindFirstChild("UpperTorso")
        if not torso then return end
        flyGyro2 = Instance.new("BodyGyro", torso)
        flyGyro2.P = 9e4
        flyGyro2.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
        flyGyro2.CFrame = workspace.CurrentCamera.CoordinateFrame
        flyBV2 = Instance.new("BodyVelocity", torso)
        flyBV2.Velocity = Vector3.new(0, 0.1, 0)
        flyBV2.MaxForce = Vector3.new(9e9, 9e9, 9e9)
        local speed = 0
        flyHeartbeat2 = game:GetService("RunService").RenderStepped:Connect(function()
            if not S.Fly or not LP.Character then return end
            flyCtrl = {f = 0, b = 0, l = 0, r = 0}
            if UIS:IsKeyDown(Enum.KeyCode.W) then flyCtrl.f = 1 end
            if UIS:IsKeyDown(Enum.KeyCode.S) then flyCtrl.b = 1 end
            if UIS:IsKeyDown(Enum.KeyCode.A) then flyCtrl.l = 1 end
            if UIS:IsKeyDown(Enum.KeyCode.D) then flyCtrl.r = 1 end
            local v = (flyCtrl.f + flyCtrl.b)
            local h2 = (flyCtrl.l + flyCtrl.r)
            local ms = S.FlySpeed
            if v ~= 0 or h2 ~= 0 then
                speed = speed + 0.5 + (speed / ms)
                if speed > ms then speed = ms end
            elseif speed ~= 0 then
                speed = speed - 1
                if speed < 0 then speed = 0 end
            end
            local cf = workspace.CurrentCamera.CoordinateFrame
            if v ~= 0 or h2 ~= 0 then
                flyBV2.Velocity = (cf.LookVector * v + ((cf * CFrame.new(h2, v * 0.2, 0).p) - cf.p)) * speed
            elseif speed ~= 0 then
                flyBV2.Velocity = (cf.LookVector * (flyCtrl.f + flyCtrl.b) + ((cf * CFrame.new(flyCtrl.l + flyCtrl.r, (flyCtrl.f + flyCtrl.b) * 0.2, 0).p) - cf.p)) * speed
            else
                flyBV2.Velocity = Vector3.new(0, 0, 0)
            end
            flyGyro2.CFrame = cf * CFrame.Angles(-math.rad(v * 50 * speed / ms), 0, 0)
            if UIS:IsKeyDown(Enum.KeyCode.Space) then
                local hr = c:FindFirstChild("HumanoidRootPart")
                if hr then hr.CFrame = hr.CFrame * CFrame.new(0, 1, 0) end
            end
            if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then
                local hr = c:FindFirstChild("HumanoidRootPart")
                if hr then hr.CFrame = hr.CFrame * CFrame.new(0, -1, 0) end
            end
        end)
    else
        h.PlatformStand = false
    end
end

local function addToggle(tab, flag, title, onChange)
    local obj
    local ok = pcall(function()
        obj = tab:Toggle({
            Title = title,
            Value = false,
            Callback = function(v)
                local nv
                if type(v) == "boolean" then nv = v else nv = not S[flag] end
                S[flag] = nv
                if onChange then pcall(onChange, nv) end
            end,
        })
    end)
    if ok and obj then
        UI[flag] = obj
        return
    end
    pcall(function()
        obj = tab:Button({
            Title = title,
            Callback = function()
                local nv = flipToggle(flag)
                if onChange then pcall(onChange, nv) end
                pcall(function() WI:Notify({Title = title, Content = (nv and "开" or "关"), Duration = 2}) end)
            end,
        })
    end)
    if obj then UI[flag] = obj end
end

local function addSlider(tab, flag, title, min, max, def, step, onChange)
    local obj
    local ok = pcall(function()
        obj = tab:Slider({Title = title, Min = min, Max = max, Step = step or 1, Value = def, Callback = function(v) S[flag] = v; if onChange then pcall(onChange, v) end end})
    end)
    if ok and obj then UI[flag] = obj; return end
    pcall(function()
        obj = tab:Slider({Title = title, Value = {Min = min, Max = max, Default = def}, Callback = function(v) S[flag] = v; if onChange then pcall(onChange, v) end end})
    end)
    if obj then UI[flag] = obj; return end
    pcall(function()
        obj = tab:Dropdown({Title = title, Values = {tostring(min), tostring(math.floor((min + max) / 2)), tostring(max)}, Value = tostring(def), Callback = function(v) S[flag] = tonumber(v) or def; if onChange then pcall(onChange, S[flag]) end end})
    end)
    if obj then UI[flag] = obj end
end

local function addSection(tab, title)
    pcall(function() tab:Section({Title = title, TextXAlignment = "Left", TextSize = 17}) end)
end

local function mW()
    WN = WI:CreateWindow({
    Title = "扔一枚硬币",
    Author = "权威不是权威",
    })
    WN_visible = true

    local t1
    pcall(function() t1 = WN:Tab({Title = "功能", Icon = "solar:slider-vertical-bold"}) end)
    if t1 then
        addSection(t1, "投币")
        addToggle(t1, "AutoThrow", "最佳投币")
        addToggle(t1, "AutoBuyCoin", "自动购买硬币")
        addSection(t1, "升级")
        addToggle(t1, "AutoUpgradeLuck", "升级 (运气)")
        addToggle(t1, "AutoUpgradeValue", "升级 (钱倍率)")
        addSection(t1, "出售")
        addToggle(t1, "AutoSell", "自动出售")
    end
end

task.spawn(function()
    while true do
        if S.Speed then
            local h = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
            if h then h.WalkSpeed = S.SpeedVal end
        end
        if S.AutoThrow then pcall(doThrow) end
        if S.AutoBuyCoin then pcall(doBuyCoin) end
        if S.AutoUpgradeLuck then pcall(doUpgradeLuck) end
        if S.AutoUpgradeValue then pcall(doUpgradeValue) end
        if S.AutoSell then pcall(doSell) end
        task.wait(0.2)
    end
end)

task.spawn(function()
    pcall(mW)
end)

pcall(function() WI:SetTheme("Light") end)

UIS.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode ~= toggleKey then return end
    local now = tick()
    if now - toggleLock < 0.3 then return end
    toggleLock = now
    if not WN then return end
    if WN_visible then
        WN_visible = false; pcall(function() WN:Close() end)
    else
        WN_visible = true; pcall(function() WN:Open() end)
    end
end)

LP.CharacterAdded:Connect(function(nc)
    task.wait(1)
    local h = nc:FindFirstChildOfClass("Humanoid")
    if S.Fly then toggleFly(true) end
    if S.Speed and h then h.WalkSpeed = S.SpeedVal end
end)

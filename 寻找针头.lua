
	-- 寻找针头：独立服务器缝合版
-- 当前服务器功能与独立界面整合版
-- 每个文件仅包含当前服务器的功能与独立关于分区

local NothingLibrary = loadstring(game:HttpGetAsync('https://raw.githubusercontent.com/quanwei-sy/qianweicangku/refs/heads/main/%E6%BA%90%E7%A0%81.lua'))()

local __BaseWindow = NothingLibrary.new({
    Title = "TY hub｜寻找针头",
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


pcall(function()
    if WindUI.Themes and WindUI.Themes.Dark then
        local t = {}
        for k, v in pairs(WindUI.Themes.Dark) do
            t[k] = v
        end
        t.Name = "Blue"
        t.Accent = Color3.fromHex("#0B1220")
        t.Dialog = Color3.fromHex("#0F172A")
        t.Outline = Color3.fromHex("#3B82F6")
        t.Text = Color3.fromHex("#FFFFFF")
        t.Placeholder = Color3.fromHex("#93A4BF")
        t.Background = Color3.fromHex("#070B14")
        t.Button = Color3.fromHex("#1D4ED8")
        t.Icon = Color3.fromHex("#60A5FA")
        t.Toggle = Color3.fromHex("#2563EB")
        t.Slider = Color3.fromHex("#3B82F6")
        t.Checkbox = Color3.fromHex("#3B82F6")
        t.SliderIcon = Color3.fromHex("#93C5FD")
        t.Primary = Color3.fromHex("#3B82F6")
        t.ElementBackground = Color3.fromHex("#111A2E")
        t.ElementBackgroundTransparency = 0
        WindUI.Themes.Blue = t
    end
end)

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local VirtualUser = game:GetService("VirtualUser")

local LocalPlayer = Players.LocalPlayer

local State = {
    CollectInterval = 1,
    SellThreshold = 25,
    ToolInterval = 1,
    NeedleInterval = 1,
    BuyInterval = 1,
    PermInterval = 1,
    AntiAFK = false,
    BuyToolsList = {},
}

local UnloadHooks = {}

local Toggles = setmetatable({}, {
    __index = function(_, k)
        return { Value = State[k] }
    end,
})

local Options = setmetatable({}, {
    __index = function(_, k)
        return { Value = State[k] }
    end,
})

local Library = { Unloaded = false }

local Window

function Library:Notify(t)
    if type(t) ~= "table" then
        return
    end
    pcall(function()
        WindUI:Notify({
            Title = tostring(t.Title or "提示"),
            Content = tostring(t.Description or t.Content or ""),
            Duration = tonumber(t.Time) or 4,
            Type = tostring(t.Type or "Info"),
        })
    end)
end

function Library:OnUnload(fn)
    if type(fn) == "function" then
        table.insert(UnloadHooks, fn)
    end
end

function Library:Unload()
    self.Unloaded = true
    for _, fn in ipairs(UnloadHooks) do
        pcall(fn)
    end
    pcall(function()
        WindUI:Unload()
    end)
    pcall(function()
        Window:Destroy()
    end)
end

local gameName = "Chapter 1 (FARMHOUSE)"

Window = WindUI:CreateWindow({
Title = "TY",
Author = "权威不是权威",
})

Window:Tag({
    Title = "TY",
    Color = Color3.fromHex("#3B82F6"),
})

Window:EditOpenButton({
    Title = "寻找针头",
    Icon = "wheat",
    CornerRadius = UDim.new(0, 16),
    StrokeThickness = 2,
    Color = ColorSequence.new(Color3.fromHex("3B82F6")),
    Draggable = true,
})

local Tabs = {
    Collect = Window:Tab({ Title = "采集", Icon = "wheat", Locked = false }),
    Sell = Window:Tab({ Title = "出售", Icon = "coins", Locked = false }),
    Tools = Window:Tab({ Title = "工具", Icon = "hammer", Locked = false }),
    Needle = Window:Tab({ Title = "寻针", Icon = "search", Locked = false }),
    Shop = Window:Tab({ Title = "购买", Icon = "shopping-cart", Locked = false }),
    Upgrade = Window:Tab({ Title = "升级", Icon = "trending-up", Locked = false }),
    Settings = Window:Tab({ Title = "设置", Icon = "settings", Locked = false }),
}

WindUI:Notify({
    Title = "寻找针头",
    Content = "脚本已就绪",
    Duration = 3,
})

local NeedleHaystack = ReplicatedStorage:WaitForChild("NeedleHaystack")
local Config = require(NeedleHaystack:WaitForChild("Config"))
local UpgradeConfig = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Configs"):WaitForChild("UpgradeConfig"))
local BuyUpgrade = NeedleHaystack:WaitForChild("BuyUpgrade")
local BuyShopItem = NeedleHaystack:WaitForChild("BuyShopItem")
local PickHay = NeedleHaystack:WaitForChild("PickHay")
local PickDroppedHay = NeedleHaystack:WaitForChild("PickDroppedHay")
local SellHay = NeedleHaystack:WaitForChild("SellHay")
local CollectGem = NeedleHaystack:WaitForChild("CollectGem")
local DeployDrone = NeedleHaystack:WaitForChild("DeployDrone")
local PitchforkDig = NeedleHaystack:WaitForChild("PitchforkDig")
local TntAction = NeedleHaystack:WaitForChild("TntAction")
local VacuumAction = NeedleHaystack:WaitForChild("VacuumAction")
local NeedleHandIn = NeedleHaystack:WaitForChild("NeedleHandIn")
local BarnShop = Workspace:WaitForChild("BarnShop")
local DroppedHayFolder = Workspace:FindFirstChild("DroppedHay")
local GemsClientFolder = Workspace:FindFirstChild("GemsClient")
local function getCash()
    local ls = LocalPlayer:FindFirstChild("leaderstats")
    local cash = ls and ls:FindFirstChild("Cash")
    return cash and cash.Value or 0
end
local function getGems()
    return tonumber(LocalPlayer:GetAttribute("Gems")) or 0
end
local function getHayHeld()
    local v = LocalPlayer:GetAttribute("HayHeld")
    if v ~= nil then return tonumber(v) or 0 end
    return #Workspace:FindFirstChild("DroppedHay") and 0 or 0
end
local function getHayCapacity()
    return tonumber(LocalPlayer:GetAttribute("HayCapacity")) or 25
end
local function owns(attr) return LocalPlayer:GetAttribute(attr) == true end
local function findClosestHay()
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil end
    local best, bestDist = nil, math.huge
    for _, inst in ipairs(Workspace:GetDescendants()) do
        if inst:GetAttribute("HayId") and inst:IsA("BasePart") and inst.Parent then
            local d = (inst.Position - hrp.Position).Magnitude
            if d < bestDist and d < 30 then
                bestDist = d
                best = inst
            end
        end
    end
    return best
end
local function getGrabCandidates(centerPart)
    local radius = tonumber(LocalPlayer:GetAttribute("HayGrabRadius")) or 0
    if radius <= 0 then return {} end
    local out = {}
    if not centerPart then return out end
    local cp = centerPart.Position
    for _, inst in ipairs(Workspace:GetDescendants()) do
        if inst ~= centerPart and inst:GetAttribute("HayId") and inst:IsA("BasePart") then
            if (inst.Position - cp).Magnitude <= radius + 1 then
                table.insert(out, inst:GetAttribute("HayId"))
                if #out >= 6 then break end
            end
        end
    end
    return out
end
local function findClosestDropped()
    if not DroppedHayFolder then DroppedHayFolder = Workspace:FindFirstChild("DroppedHay") end
    if not DroppedHayFolder then return nil end
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil end
    local best, bestDist = nil, 28
    for _, m in ipairs(DroppedHayFolder:GetChildren()) do
        local part = m:IsA("BasePart") and m or m:FindFirstChildWhichIsA("BasePart")
        if part then
            local d = (part.Position - hrp.Position).Magnitude
            if d < bestDist then
                bestDist = d
                best = part.Parent:IsA("BasePart") and part.Parent or m
            end
        end
    end
    return best
end
local function findClosestGem()
    if not GemsClientFolder then GemsClientFolder = Workspace:FindFirstChild("GemsClient") end
    local root = GemsClientFolder or Workspace
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil end
    local best, bestDist, bestId = nil, 35, nil
    for _, mdl in ipairs(root:GetDescendants()) do
        if mdl:IsA("BasePart") and mdl:GetAttribute("GemId") then
            local d = (mdl.Position - hrp.Position).Magnitude
            if d < bestDist then
                bestDist = d
                best = mdl
                bestId = mdl:GetAttribute("GemId")
            end
        end
    end
    if best and bestId then return best, bestId end
    for _, mdl in ipairs(Workspace:GetDescendants()) do
        if mdl:GetAttribute("GemId") and mdl:IsA("BasePart") then
            local d = (mdl.Position - hrp.Position).Magnitude
            if d < bestDist then
                bestDist = d
                best = mdl
                bestId = mdl:GetAttribute("GemId")
            end
        end
    end
    if best then return best, bestId end
    return nil, nil
end
local function isBagFull()
    return getHayHeld() >= getHayCapacity()
end
local function getNearestSellPart()
    local CollectionService = game:GetService("CollectionService")
    local camPos = workspace.CurrentCamera and workspace.CurrentCamera.CFrame.Position or (LocalPlayer.Character and LocalPlayer.Character:GetPivot().Position or Vector3.new(0,0,0))
    local best, bestDist = nil, math.huge
    for _, part in ipairs(CollectionService:GetTagged(Config.SELL_PART_NAME)) do
        if part:IsA("BasePart") and part:IsDescendantOf(workspace) then
            local d = (part.Position - camPos).Magnitude
            local char = LocalPlayer.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            if hrp then
                local cd = (part.Position - hrp.Position).Magnitude
                d = math.min(d, cd)
            end
            if d < bestDist then
                bestDist = d
                best = part
            end
        end
    end
    if not best then
        for _, inst in ipairs(workspace.SellModel:GetDescendants()) do
            if inst.Name == "SellPart" and inst:IsA("BasePart") then
                return inst
            end
        end
    end
    return best
end
local function trySell()
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    local sellPart = getNearestSellPart()
    if hrp and sellPart then
        local dist = (hrp.Position - sellPart.Position).Magnitude
        if dist > 14 then
            local target = sellPart.CFrame + Vector3.new(0, 3, 2)
            hrp.CFrame = target
            if workspace.CurrentCamera then
                workspace.CurrentCamera.CFrame = CFrame.lookAt(workspace.CurrentCamera.CFrame.Position, sellPart.Position)
            end
            task.wait(0.25)
        else
            if workspace.CurrentCamera then
                pcall(function()
                    workspace.CurrentCamera.CFrame = CFrame.lookAt(workspace.CurrentCamera.CFrame.Position, sellPart.Position)
                end)
            end
            task.wait(0.05)
        end
    end
    local ok, err = pcall(function() SellHay:FireServer() end)
    if not ok then
        Library:Notify({Title="Sell Failed", Description=tostring(err), Time=2, Type="Error"})
    end
    task.spawn(function()
        local before = getHayHeld()
        task.wait(0.6)
        if before > 0 and getHayHeld() == before and hrp and sellPart then
            hrp.CFrame = sellPart.CFrame + Vector3.new(0, 4, 0)
            task.wait(0.2)
            pcall(function() SellHay:FireServer() end)
        end
    end)
    task.spawn(function()
        task.wait(1.0)
        local needReturn = false
        if Toggles.AutoPickHay and Toggles.AutoPickHay.Value then needReturn = true end
        if Toggles.AutoCollectDroppedHay and Toggles.AutoCollectDroppedHay.Value then needReturn = true end
        if Toggles.AutoCollectGems and Toggles.AutoCollectGems.Value then needReturn = true end
        if Toggles.AutoVacuumCollect and Toggles.AutoVacuumCollect.Value then needReturn = true end
        if Toggles.AutoVacuum and Toggles.AutoVacuum.Value then needReturn = true end
        if Toggles.AutoUsePitchfork and Toggles.AutoUsePitchfork.Value then needReturn = true end
        if Toggles.AutoFindNeedle and Toggles.AutoFindNeedle.Value then needReturn = true end
        if needReturn and getHayHeld() == 0 then
            local pile = Config.PILE_CENTER
            local hrp2 = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if hrp2 and (hrp2.Position - pile).Magnitude > 22 then
                hrp2.CFrame = CFrame.new(pile + Vector3.new(math.random(-2,2), 5, math.random(-2,2)))
                if workspace.CurrentCamera then
                    workspace.CurrentCamera.CFrame = CFrame.new(hrp2.Position + Vector3.new(0,4,0), pile)
                end
            end
        end
    end)
end

local TabCollect = Tabs.Collect
TabCollect:Section({ Title = "资源采集", TextXAlignment = "Left", TextSize = 17 })
TabCollect:Toggle({ Title = "自动拾取干草", Default = false, Callback = function(v) State.AutoPickHay = v end })
TabCollect:Toggle({ Title = "自动收集掉落干草", Default = false, Callback = function(v) State.AutoCollectDroppedHay = v end })
TabCollect:Toggle({ Title = "自动收集宝石", Default = false, Callback = function(v) State.AutoCollectGems = v end })
TabCollect:Toggle({ Title = "自动吸尘器收集", Default = false, Callback = function(v) State.AutoVacuumCollect = v end })
TabCollect:Slider({
    Title = "循环间隔(秒)",
    Value = { Min = 0.1, Max = 3, Default = 1 },
    Increment = 0.1,
    Callback = function(v) State.CollectInterval = v end,
})

local TabSell = Tabs.Sell
TabSell:Section({ Title = "自动出售", TextXAlignment = "Left", TextSize = 17 })
TabSell:Toggle({ Title = "自动出售干草", Default = false, Callback = function(v) State.AutoSellHay = v end })
TabSell:Slider({
    Title = "持有量达到此值即出售",
    Value = { Min = 1, Max = 250, Default = 25 },
    Increment = 1,
    Callback = function(v) State.SellThreshold = v end,
})
TabSell:Toggle({ Title = "仅在满袋时出售", Default = false, Callback = function(v) State.SellOnlyIfFull = v end })
TabSell:Button({ Title = "立即出售一次", Callback = function() task.spawn(trySell) end })

local TabTools = Tabs.Tools
TabTools:Section({ Title = "自动使用工具", TextXAlignment = "Left", TextSize = 17 })
TabTools:Toggle({ Title = "自动使用 TNT", Default = false, Callback = function(v) State.AutoUseTNT = v end })
TabTools:Toggle({ Title = "自动使用干草叉", Default = false, Callback = function(v) State.AutoUsePitchfork = v end })
TabTools:Toggle({ Title = "自动部署无人机", Default = false, Callback = function(v) State.AutoDeployDrone = v end })
TabTools:Toggle({ Title = "自动吸尘器(循环)", Default = false, Callback = function(v) State.AutoVacuum = v end })
TabTools:Slider({
    Title = "工具间隔(秒)",
    Value = { Min = 0.2, Max = 5, Default = 1 },
    Increment = 0.1,
    Callback = function(v) State.ToolInterval = v end,
})

local TabNeedle = Tabs.Needle
TabNeedle:Section({ Title = "寻针", TextXAlignment = "Left", TextSize = 17 })
TabNeedle:Toggle({ Title = "自动寻针", Default = false, Callback = function(v) State.AutoFindNeedle = v end })
TabNeedle:Toggle({ Title = "自动交付针", Default = false, Callback = function(v) State.AutoHandInNeedle = v end })
TabNeedle:Slider({
    Title = "寻针间隔(秒)",
    Value = { Min = 0.2, Max = 3, Default = 1 },
    Increment = 0.1,
    Callback = function(v) State.NeedleInterval = v end,
})

local TabShop = Tabs.Shop
TabShop:Section({ Title = "购买工具", TextXAlignment = "Left", TextSize = 17 })

local buyOptions = { "Pitchfork", "TNT", "Drone", "Vacuum", "Infinite Bag", "Capacity Bag" }

local function applyBuyList(v)
    local t = {}
    if type(v) == "table" then
        for k, val in pairs(v) do
            if val == true then
                t[k] = true
            elseif type(k) == "number" and type(val) == "string" then
                t[val] = true
            end
        end
    elseif type(v) == "string" then
        t[v] = true
    end
    State.BuyToolsList = t
end

local ddOk = pcall(function()
    TabShop:Dropdown({
        Title = "要购买的工具(可多选)",
        Values = buyOptions,
        Multi = true,
        Callback = applyBuyList,
    })
end)

if not ddOk then
    local buyNames = { "干草叉", "TNT", "无人机", "吸尘器", "无限背包", "容量背包" }
    for i, name in ipairs(buyOptions) do
        TabShop:Toggle({
            Title = "购买: " .. buyNames[i],
            Default = false,
            Callback = function(v)
                local cur = {}
                for k, val in pairs(State.BuyToolsList or {}) do
                    cur[k] = val
                end
                if v then
                    cur[name] = true
                else
                    cur[name] = nil
                end
                State.BuyToolsList = cur
            end,
        })
    end
end

TabShop:Toggle({ Title = "自动购买选中工具", Default = false, Callback = function(v) State.AutoBuyTools = v end })
TabShop:Slider({
    Title = "购买间隔(秒)",
    Value = { Min = 0.5, Max = 5, Default = 1 },
    Increment = 0.1,
    Callback = function(v) State.BuyInterval = v end,
})
TabShop:Button({
    Title = "检查已拥有道具",
    Callback = function()
        local t = {}
        for _, k in ipairs({ "PitchforkOwned", "TntOwned", "DroneOwned", "VacuumOwned", "InfiniteBagOwned", "HayUpgradeCapacity" }) do
            table.insert(t, k .. ": " .. tostring(LocalPlayer:GetAttribute(k)))
        end
        Library:Notify({ Title = "拥有情况", Description = table.concat(t, "\n"), Time = 4 })
    end,
})

local TabUp = Tabs.Upgrade
TabUp:Section({ Title = "永久升级(宝石)", TextXAlignment = "Left", TextSize = 17 })
TabUp:Toggle({ Title = "自动升级背包容量", Default = false, Callback = function(v) State.UpgBagSize = v end })
TabUp:Toggle({ Title = "自动升级手持数量", Default = false, Callback = function(v) State.UpgExtraTake = v end })
TabUp:Toggle({ Title = "自动升级宝石价值", Default = false, Callback = function(v) State.UpgGemValue = v end })
TabUp:Toggle({ Title = "自动升级干草价值", Default = false, Callback = function(v) State.UpgHayValue = v end })
TabUp:Slider({
    Title = "永久升级循环(秒)",
    Value = { Min = 0.5, Max = 5, Default = 1 },
    Increment = 0.1,
    Callback = function(v) State.PermInterval = v end,
})
TabUp:Section({ Title = "手部升级(现金)", TextXAlignment = "Left", TextSize = 17 })
TabUp:Toggle({ Title = "自动升级手速", Default = false, Callback = function(v) State.UpgHandSpeed = v end })
TabUp:Toggle({ Title = "自动升级抓取", Default = false, Callback = function(v) State.UpgHandGrab = v end })
TabUp:Toggle({ Title = "自动升级持握", Default = false, Callback = function(v) State.UpgHandHold = v end })
TabUp:Section({ Title = "TNT 升级", TextXAlignment = "Left", TextSize = 17 })
TabUp:Toggle({ Title = "自动升级幸运爆破", Default = false, Callback = function(v) State.UpgTntLuck = v end })
TabUp:Toggle({ Title = "自动升级冷却", Default = false, Callback = function(v) State.UpgTntCooldown = v end })
TabUp:Toggle({ Title = "自动升级威力", Default = false, Callback = function(v) State.UpgTntPower = v end })
TabUp:Section({ Title = "干草叉升级", TextXAlignment = "Left", TextSize = 17 })
TabUp:Toggle({ Title = "自动升级冷却", Default = false, Callback = function(v) State.UpgPitchCooldown = v end })
TabUp:Toggle({ Title = "自动升级持握", Default = false, Callback = function(v) State.UpgPitchHold = v end })
TabUp:Toggle({ Title = "自动升级挥扫", Default = false, Callback = function(v) State.UpgPitchSweep = v end })
TabUp:Section({ Title = "无人机升级", TextXAlignment = "Left", TextSize = 17 })
TabUp:Toggle({ Title = "自动升级速度", Default = false, Callback = function(v) State.UpgDroneSpeed = v end })
TabUp:Toggle({ Title = "自动升级抓取", Default = false, Callback = function(v) State.UpgDroneGrab = v end })
TabUp:Toggle({ Title = "自动升级容量", Default = false, Callback = function(v) State.UpgDroneCapacity = v end })
TabUp:Section({ Title = "吸尘器升级", TextXAlignment = "Left", TextSize = 17 })
TabUp:Toggle({ Title = "自动升级功率", Default = false, Callback = function(v) State.UpgVacPower = v end })
TabUp:Toggle({ Title = "自动升级散热", Default = false, Callback = function(v) State.UpgVacCooling = v end })
TabUp:Toggle({ Title = "自动升级续航", Default = false, Callback = function(v) State.UpgVacRuntime = v end })
TabUp:Section({ Title = "容量升级", TextXAlignment = "Left", TextSize = 17 })
TabUp:Toggle({ Title = "自动升级携带容量", Default = false, Callback = function(v) State.UpgCapacity = v end })

local TabSet = Tabs.Settings
TabSet:Section({ Title = "系统", TextXAlignment = "Left", TextSize = 17 })
TabSet:Toggle({ Title = "防挂机(每5分钟跳动)", Default = false, Callback = function(v) State.AntiAFK = v end })
TabSet:Toggle({ Title = "重进时通知", Default = false, Callback = function(v) State.AutoRejoin = v end })
TabSet:Section({ Title = "操作", TextXAlignment = "Left", TextSize = 17 })
TabSet:Button({ Title = "卸载脚本", Callback = function() Library:Unload() end })

local function waitInterval(optName, fallback)
    local v = Options[optName] and Options[optName].Value or fallback
    return tonumber(v) or fallback
end
local function ensureNearPileForPick()
    local pile = Config.PILE_CENTER
    local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local distToPile = (hrp.Position - pile).Magnitude
    if distToPile > 28 then
        hrp.CFrame = CFrame.new(pile + Vector3.new(math.random(-3,3), 5, math.random(-3,3)))
        if workspace.CurrentCamera then
            workspace.CurrentCamera.CFrame = CFrame.new(hrp.Position + Vector3.new(0,4,0), pile)
        end
        task.wait(0.25)
    end
end
local function teleportToPart(part, yOffset)
    local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not hrp or not part then return end
    local dist = (hrp.Position - part.Position).Magnitude
    if dist > 15 then
        hrp.CFrame = part.CFrame + Vector3.new(0, yOffset or 4, 1.5)
        if workspace.CurrentCamera then
            pcall(function() workspace.CurrentCamera.CFrame = CFrame.lookAt(workspace.CurrentCamera.CFrame.Position, part.Position) end)
        end
        task.wait(0.18)
    else
        if workspace.CurrentCamera then
            pcall(function() workspace.CurrentCamera.CFrame = CFrame.lookAt(workspace.CurrentCamera.CFrame.Position, part.Position) end)
        end
    end
end
task.spawn(function()
    while true do
        task.wait(waitInterval("CollectInterval",1))
        if Library.Unloaded then break end
        if Toggles.AutoPickHay and Toggles.AutoPickHay.Value then
            if not isBagFull() then
                local hay = findClosestHay()
                if not hay then
                    ensureNearPileForPick()
                    hay = findClosestHay()
                end
                if hay then
                    teleportToPart(hay, 4)
                    local id = hay:GetAttribute("HayId")
                    if id then
                        local candidates = getGrabCandidates(hay)
                        pcall(function() PickHay:FireServer(id, candidates) end)
                    else
                        pcall(function() PickDroppedHay:FireServer(hay) end)
                    end
                else
                    ensureNearPileForPick()
                end
            end
        end
    end
end)
task.spawn(function()
    while true do
        task.wait(waitInterval("CollectInterval",1))
        if Library.Unloaded then break end
        if Toggles.AutoCollectDroppedHay and Toggles.AutoCollectDroppedHay.Value then
            if not isBagFull() then
                local d = findClosestDropped()
                if not d then
                    ensureNearPileForPick()
                    d = findClosestDropped()
                end
                if d then
                    local part = d:IsA("BasePart") and d or d:FindFirstChildWhichIsA("BasePart")
                    if part then teleportToPart(part, 3) end
                    pcall(function() PickDroppedHay:FireServer(d) end)
                end
            end
        end
    end
end)
task.spawn(function()
    while true do
        task.wait(waitInterval("CollectInterval",1))
        if Library.Unloaded then break end
        if Toggles.AutoCollectGems and Toggles.AutoCollectGems.Value then
            local gemPart, id = findClosestGem()
            if not gemPart then
                ensureNearPileForPick()
                gemPart, id = findClosestGem()
            end
            if gemPart and id then
                teleportToPart(gemPart, 3)
                pcall(function() CollectGem:FireServer(id) end)
            end
        end
    end
end)
task.spawn(function()
    while true do
        task.wait(waitInterval("SellThreshold",1) and 1 or 1)
        if Library.Unloaded then break end
        if Toggles.AutoSellHay and Toggles.AutoSellHay.Value then
            local held = getHayHeld()
            local thresh = Options.SellThreshold and Options.SellThreshold.Value or 25
            local onlyFull = Toggles.SellOnlyIfFull and Toggles.SellOnlyIfFull.Value
            local should = false
            if onlyFull then should = isBagFull()
            else should = held >= thresh end
            if should and held > 0 then trySell() end
        end
    end
end)
do
    local vacActive = false
    task.spawn(function()
        while true do
            task.wait(waitInterval("CollectInterval",1))
            if Library.Unloaded then break end
            local want = Toggles.AutoVacuumCollect and Toggles.AutoVacuumCollect.Value
            local want2 = Toggles.AutoVacuum and Toggles.AutoVacuum.Value
            local should = want or want2
            if should and owns("VacuumOwned") then
                if not vacActive and not isBagFull() then
                    local hay = findClosestHay()
                    if not hay then ensureNearPileForPick() hay = findClosestHay() end
                    if hay then teleportToPart(hay, 5) end
                    pcall(function() VacuumAction:FireServer("Start") end)
                    vacActive = true
                elseif isBagFull() and vacActive then
                    pcall(function() VacuumAction:FireServer("Stop") end)
                    vacActive = false
                    trySell()
                end
            else
                if vacActive then pcall(function() VacuumAction:FireServer("Stop") end) vacActive=false end
            end
            if vacActive and LocalPlayer:GetAttribute("VacuumOverheated") then
                pcall(function() VacuumAction:FireServer("Stop") end) vacActive=false
                task.wait(0.5)
                ensureNearPileForPick()
            end
        end
    end)
end
task.spawn(function()
    while true do
        task.wait(waitInterval("ToolInterval",1))
        if Library.Unloaded then break end
        if Toggles.AutoUseTNT and Toggles.AutoUseTNT.Value and owns("TntOwned") then
            local ok = not LocalPlayer:GetAttribute("NeedleInputLocked")
            if ok then
                pcall(function() TntAction:FireServer("light") end)
                task.wait(0.4)
                local cam = Workspace.CurrentCamera
                if cam then
                    local dir = cam.CFrame.LookVector * 40 + Vector3.new(0,8,0)
                    local cf = cam.CFrame
                    pcall(function() TntAction:FireServer("throw", cf, dir) end)
                end
            end
        end
    end
end)
task.spawn(function()
    while true do
        task.wait(waitInterval("ToolInterval",1))
        if Library.Unloaded then break end
        if Toggles.AutoUsePitchfork and Toggles.AutoUsePitchfork.Value and owns("PitchforkOwned") then
            local hay = findClosestHay()
            if not hay then ensureNearPileForPick() hay = findClosestHay() end
            if hay then teleportToPart(hay, 4) end
            local id = hay and hay:GetAttribute("HayId")
            if id then
                pcall(function() PitchforkDig:FireServer(id) end)
            else
                local fakeId = LocalPlayer:GetAttribute("HoveredHayId")
                if fakeId then
                    ensureNearPileForPick()
                    pcall(function() PitchforkDig:FireServer(fakeId) end)
                end
            end
        end
    end
end)
task.spawn(function()
    while true do
        task.wait(waitInterval("ToolInterval",1))
        if Library.Unloaded then break end
        if Toggles.AutoDeployDrone and Toggles.AutoDeployDrone.Value and owns("DroneOwned") then
            if not LocalPlayer:GetAttribute("DroneDeployed") then
                pcall(function() DeployDrone:FireServer() end)
            end
        end
    end
end)
task.spawn(function()
    while true do
        task.wait(waitInterval("NeedleInterval",1))
        if Library.Unloaded then break end
        if Toggles.AutoFindNeedle and Toggles.AutoFindNeedle.Value then
            if not LocalPlayer:GetAttribute("NeedleRoundComplete") then
                local hay = findClosestHay()
                if not hay then ensureNearPileForPick() hay = findClosestHay() end
                if hay then
                    teleportToPart(hay, 4)
                    local id = hay:GetAttribute("HayId")
                    if id and not isBagFull() then
                        pcall(function() PickHay:FireServer(id, getGrabCandidates(hay)) end)
                    elseif isBagFull() then
                        trySell()
                    end
                else
                    ensureNearPileForPick()
                end
            end
        end
        if Toggles.AutoHandInNeedle and Toggles.AutoHandInNeedle.Value then
            local farmer = workspace:FindFirstChild("NPC") and workspace.NPC:FindFirstChild("Farmer_NPC")
            if farmer and farmer:GetPivot() then
                local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                if hrp and (hrp.Position - farmer:GetPivot().Position).Magnitude > 20 then
                    hrp.CFrame = farmer:GetPivot() * CFrame.new(0,0,4)
                    task.wait(0.2)
                end
            end
            pcall(function() NeedleHandIn:FireServer() end)
        end
    end
end)
task.spawn(function()
    while true do
        task.wait(waitInterval("BuyInterval",1))
        if Library.Unloaded then break end
        if Toggles.AutoBuyTools and Toggles.AutoBuyTools.Value then
            local sel = Options.BuyToolsList and Options.BuyToolsList.Value or {}
            local list = {}
            if typeof(sel) == "table" then
                for k,v in pairs(sel) do if v then table.insert(list, k) end end
                if #list==0 then for _,v in ipairs(sel) do table.insert(list, v) end end
            end
            for _, name in ipairs(list) do
                if name == "Pitchfork" and not owns("PitchforkOwned") then pcall(function() BuyShopItem:FireServer("Pitchfork") end)
                elseif name == "TNT" and not owns("TntOwned") then pcall(function() BuyShopItem:FireServer("Tnt") end)
                elseif name == "Drone" and not owns("DroneOwned") then pcall(function() BuyShopItem:FireServer("Drone") end)
                elseif name == "Vacuum" and not owns("VacuumOwned") then pcall(function() BuyShopItem:FireServer("Vacuum") end)
                elseif name == "Infinite Bag" and not owns("InfiniteBagOwned") then pcall(function() BuyShopItem:FireServer("InfiniteBag") end)
                elseif name == "Capacity Bag" then
                    local st = tonumber(LocalPlayer:GetAttribute("HayUpgradeCapacity")) or 1
                    local track = Config.UPGRADE_TRACKS["Capacity"]
                    if track and st < #track.Levels then
                        local cost = track.Levels[st+1].Cost
                        if getCash() >= (cost or 0) then pcall(function() BuyUpgrade:FireServer("Capacity") end) end
                    end
                end
            end
        end
    end
end)
local function tryBuyTrack(trackName)
    local track = Config.UPGRADE_TRACKS[trackName]
    if not track then return end
    local cur = tonumber(LocalPlayer:GetAttribute("HayUpgrade"..trackName)) or 1
    if cur >= #track.Levels then return end
    local nxt = track.Levels[cur+1]
    if not nxt then return end
    local cost = nxt.Cost or 0
    if getCash() >= cost then
        pcall(function() BuyUpgrade:FireServer(trackName) end)
    end
end
local function tryBuyPermanent(id)
    local u = UpgradeConfig.getUpgrade(id)
    if not u then return end
    local cur = tonumber(LocalPlayer:GetAttribute("Upgrade"..id)) or 0
    local max = UpgradeConfig.getMaxLevel(u)
    if cur >= max then return end
    local price = UpgradeConfig.getPrice(u, cur)
    if price and getGems() >= price then
        pcall(function() BuyUpgrade:FireServer(id) end)
    end
end
task.spawn(function()
    while true do
        task.wait(waitInterval("PermInterval",1))
        if Library.Unloaded then break end
        if Toggles.UpgBagSize and Toggles.UpgBagSize.Value then tryBuyPermanent("ExtraHoldAmount") end
        if Toggles.UpgExtraTake and Toggles.UpgExtraTake.Value then tryBuyPermanent("ExtraTakeAmount") end
        if Toggles.UpgGemValue and Toggles.UpgGemValue.Value then tryBuyPermanent("GemValue") end
        if Toggles.UpgHayValue and Toggles.UpgHayValue.Value then tryBuyPermanent("ExtraHayValuePercentage") end
    end
end)
task.spawn(function()
    while true do
        task.wait(1.2)
        if Library.Unloaded then break end
        if Toggles.UpgCapacity and Toggles.UpgCapacity.Value then tryBuyTrack("Capacity") end
        if Toggles.UpgHandSpeed and Toggles.UpgHandSpeed.Value then tryBuyTrack("Speed") end
        if Toggles["UpgHandGrab"] and Toggles["UpgHandGrab"].Value then
            tryBuyTrack("Grab")
        end
        if Toggles.UpgHandHold and Toggles.UpgHandHold.Value then tryBuyTrack("HandHold") end
        if Toggles.UpgTntLuck and Toggles.UpgTntLuck.Value then tryBuyTrack("TntLuck") end
        if Toggles.UpgTntCooldown and Toggles.UpgTntCooldown.Value then tryBuyTrack("TntCooldown") end
        if Toggles.UpgTntPower and Toggles.UpgTntPower.Value then tryBuyTrack("TntPower") end
        if Toggles.UpgPitchCooldown and Toggles.UpgPitchCooldown.Value then tryBuyTrack("PitchforkCooldown") end
        if Toggles.UpgPitchHold and Toggles.UpgPitchHold.Value then tryBuyTrack("PitchforkHold") end
        if Toggles.UpgPitchSweep and Toggles.UpgPitchSweep.Value then tryBuyTrack("Pitchfork") end
        if Toggles.UpgDroneSpeed and Toggles.UpgDroneSpeed.Value then tryBuyTrack("DroneSpeed") end
        if Toggles.UpgDroneGrab and Toggles.UpgDroneGrab.Value then tryBuyTrack("DroneGrab") end
        if Toggles.UpgDroneCapacity and Toggles.UpgDroneCapacity.Value then tryBuyTrack("DroneCapacity") end
        if Toggles.UpgVacPower and Toggles.UpgVacPower.Value then tryBuyTrack("VacuumPower") end
        if Toggles.UpgVacCooling and Toggles.UpgVacCooling.Value then tryBuyTrack("VacuumCooling") end
        if Toggles.UpgVacRuntime and Toggles.UpgVacRuntime.Value then tryBuyTrack("VacuumRuntime") end
    end
end)
task.spawn(function()
    while true do
        task.wait(300)
        if Library.Unloaded then break end
        if Toggles.AntiAFK and Toggles.AntiAFK.Value then
            pcall(function()
                local char = LocalPlayer.Character
                local hum = char and char:FindFirstChildOfClass("Humanoid")
                if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) hum.Jump = true end
                VirtualUser:CaptureController()
                VirtualUser:ClickButton2(Vector2.new())
            end)
        end
    end
end)
Library:OnUnload(function()
    pcall(function() VacuumAction:FireServer("Stop") end)
    Library.Unloaded = true
end)
Library:Notify({ Title = "权威不是权威", Description = gameName.." loaded. Farming=collect/sell/tools | Inventory=shop/upgrades", Time = 5, Type = "Success" })

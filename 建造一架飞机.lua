
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer

	-- 建造一架飞机：独立服务器缝合版
-- 当前服务器功能与独立界面整合版
-- 每个文件仅包含当前服务器的功能与独立关于分区

local NothingLibrary = loadstring(game:HttpGetAsync('https://raw.githubusercontent.com/quanwei-sy/qianweicangku/refs/heads/main/%E6%BA%90%E7%A0%81.lua'))()

local __BaseWindow = NothingLibrary.new({
    Title = "TY hub｜建造一架飞机",
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


local SET = {
    ALTITUDE   = 600,
    STALL_TIME = 4,
    LOOP_DELAY = 4,
}

local LaunchEvents = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("LaunchEvents")
local LaunchRemote = LaunchEvents:WaitForChild("Launch")
local ReturnRemote = LaunchEvents:WaitForChild("Return")

local cashValue = nil
pcall(function()
    local ls = player:WaitForChild("leaderstats", 5)
    if ls then
        for _, v in ipairs(ls:GetChildren()) do
            if v:IsA("NumberValue") or v:IsA("IntValue") then
                cashValue = v
                break
            end
        end
    end
end)

local function getCash()
    return cashValue and cashValue.Value or -1
end

local function getRoot()
    local c = player.Character
    if c and c:FindFirstChild("HumanoidRootPart") then
        return c.HumanoidRootPart
    end
    return nil
end

local function holdAltitude(root)
    local cf = root.CFrame
    local p = cf.Position
    if p.Y < SET.ALTITUDE then
        root.CFrame = cf + Vector3.new(0, SET.ALTITUDE - p.Y, 0)
    end
end

local function oneRun()
    pcall(function() LaunchRemote:FireServer() end)
    task.wait(1.5)
    local root = getRoot()
    if not root then
        return 0, getCash()
    end
    local lastX = root.Position.X
    local lastMoveAt = os.clock()
    local runStartCash = getCash()
    while getgenv().BuildAPlaneFarmRunning do
        task.wait(0.5)
        root = getRoot()
        if not root then break end
        holdAltitude(root)
        local x = root.Position.X
        if x - lastX < 1 then
            if os.clock() - lastMoveAt > SET.STALL_TIME then
                break
            end
        else
            lastX = x
            lastMoveAt = os.clock()
        end
    end
    pcall(function() ReturnRemote:FireServer() end)
    task.wait(1.2)
    local endCash = getCash()
    local earned = 0
    if cashValue then
        earned = endCash - runStartCash
    end
    return earned, endCash
end

local function farmLoop(statusTag)
    local n = 0
    while getgenv().BuildAPlaneFarmRunning do
        n = n + 1
        local earned, cash = oneRun()
        if statusTag then
            statusTag:SetTitle("现金 " .. tostring(cash) .. "  |  第" .. n .. "轮 +" .. tostring(earned))
        end
        task.wait(SET.LOOP_DELAY)
    end
end

local BuyBlock = nil
pcall(function()
    BuyBlock = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("ShopEvents"):WaitForChild("BuyBlock")
end)
if not BuyBlock then
    for _, v in ipairs(ReplicatedStorage:GetDescendants()) do
        if v:IsA("RemoteEvent") and v.Name == "BuyBlock" then
            BuyBlock = v
            break
        end
    end
end

local KNOWN_PARTS = {
    "block_1", "block_2", "block_3",
    "half_block", "reinforced_block", "glass_block", "metal_block", "titanium_block",
    "wing_1", "wing_2", "wing_3", "better_wing", "delta_wing",
    "tail_1", "better_tail", "titanium_tail",
    "fuel_1", "fuel_2", "fuel_3", "better_fuel", "barrel_fuel", "refined_fuel",
    "propeller_1", "propeller_2", "propeller_3", "better_propeller",
    "op_propeller", "helicopter_propeller",
    "seat_1", "landing_gears",
    "balloon", "balloon_deployer", "boost_1", "rocket_booster", "plasma_booster",
    "missile_1", "futuristic_missile", "shield",
}

local KNOWN_EQUIPS = {
    "paintbrush", "sign", "wrench",
}

local ITEM_CN = {
    block_1 = "方块", block_2 = "方块2", block_3 = "方块3",
    half_block = "半方块", reinforced_block = "强化方块",
    glass_block = "玻璃方块", metal_block = "金属方块", titanium_block = "钛方块",
    wing_1 = "机翼", wing_2 = "机翼2", wing_3 = "机翼3",
    better_wing = "优质机翼", delta_wing = "三角翼",
    tail_1 = "尾翼", better_tail = "优质尾翼", titanium_tail = "钛尾翼",
    fuel_1 = "燃料箱", fuel_2 = "燃料箱2", fuel_3 = "燃料箱3",
    better_fuel = "优质燃料", barrel_fuel = "桶装燃料", refined_fuel = "精炼燃料",
    propeller_1 = "螺旋桨", propeller_2 = "螺旋桨2", propeller_3 = "螺旋桨3",
    better_propeller = "优质螺旋桨", op_propeller = "最强螺旋桨",
    helicopter_propeller = "直升机螺旋桨",
    seat_1 = "座椅", landing_gears = "起落架",
    balloon = "气球", balloon_deployer = "气球部署器",
    boost_1 = "推进器", rocket_booster = "火箭推进器", plasma_booster = "等离子推进器",
    missile_1 = "导弹", futuristic_missile = "未来导弹",
    shield = "能量护盾",
    paintbrush = "油漆刷", sign = "标志", wrench = "扳手",
}

local function displayName(nm)
    return ITEM_CN[nm] or nm
end

local cart = getgenv().BuildAPlaneCart3
if type(cart) ~= "table" then
    cart = {}
    getgenv().BuildAPlaneCart3 = cart
end

local function buyOne(itemName)
    return pcall(function()
        BuyBlock:FireServer(itemName)
    end)
end

local function buyList(list, statusTag, tagPrefix)
    local bought, failed = 0, 0
    for _, nm in ipairs(list) do
        if buyOne(nm) then
            bought = bought + 1
        else
            failed = failed + 1
        end
        task.wait(0.1)
    end
    if statusTag then
        statusTag:SetTitle(tagPrefix .. "本次购买 " .. tostring(bought) .. " 件  |  失败 " .. tostring(failed))
    end
    WindUI:Notify({ Title = "购买完成", Content = "成功 " .. tostring(bought) .. " 件，失败 " .. tostring(failed) .. " 件", Duration = 4 })
end

local function buySelected(statusTag)
    local list = {}
    for nm, on in pairs(cart) do
        if on then table.insert(list, nm) end
    end
    buyList(list, statusTag, "[已选] ")
end

local function autoBuySelectedLoop(statusTag)
    local rounds = 0
    while getgenv().BuildAPlaneAutoCart3 do
        rounds = rounds + 1
        local list = {}
        for nm, on in pairs(cart) do
            if on then table.insert(list, nm) end
        end
        local bought = 0
        for _, nm in ipairs(list) do
            if not getgenv().BuildAPlaneAutoCart3 then break end
            if buyOne(nm) then bought = bought + 1 end
            task.wait(0.1)
        end
        if statusTag then
            statusTag:SetTitle("第" .. tostring(rounds) .. "轮 已购 " .. tostring(bought) .. " / 选中 " .. tostring(#list))
        end
        task.wait(5)
    end
end

local PROPS = { "propeller_0", "propeller_1", "propeller_2", "propeller_3", "propeller_blood" }
local BlockInfo = nil
local origPropForce = nil
pcall(function()
    local mods = ReplicatedStorage:FindFirstChild("Modules")
    if mods and mods:FindFirstChild("Utilities") then
        local mu = mods.Utilities
        if mu:FindFirstChild("BlocksUtil") then
            local BLK = require(mu.BlocksUtil)
            BlockInfo = BLK and BLK.BlockInfo
        end
    end
end)

local boostSpeed = 150
local boostOn = false

local function setPropForce(v)
    if not BlockInfo then return false end
    for _, p in ipairs(PROPS) do
        local bd = BlockInfo[p]
        if bd then
            bd.Force = v
        end
    end
    return true
end

local function storeOrigForce()
    origPropForce = {}
    if not BlockInfo then return end
    for _, p in ipairs(PROPS) do
        local bd = BlockInfo[p]
        if bd then
            origPropForce[p] = bd.Force
        end
    end
end

local function restoreOrigForce()
    if not BlockInfo or not origPropForce then return end
    for p, v in pairs(origPropForce) do
        local bd = BlockInfo[p]
        if bd then bd.Force = v end
    end
    origPropForce = nil
end

local Window = WindUI:CreateWindow({
Title = "建造飞机",
Author = "权威不是权威",
})

local StatusTag = Window:Tag({
    Title = "现金 " .. tostring(getCash()),
    Color = Color3.fromRGB(255, 255, 255)
})

Window:Tag({ Title = "建造飞机", Color = Color3.fromHex("#7FDBFF") })

local farmTab = Window:Tab({ Title = "刷钱", Icon = "settings" })
local farmSec = farmTab:Section({ Title = "刷钱控制", TextXAlignment = "Left", TextSize = 17 })

farmSec:Toggle({
    Title = "自动刷钱",
    Default = false,
    Callback = function(state)
        getgenv().BuildAPlaneFarmRunning = state
        if state then
            task.spawn(farmLoop, StatusTag)
            WindUI:Notify({ Title = "已启动", Content = "高空巡航刷钱开始", Duration = 3 })
        else
            WindUI:Notify({ Title = "已停止", Content = "刷钱循环已停止", Duration = 3 })
        end
    end
})

farmSec:Slider({
    Title = "巡航高度",
    Value = { Min = 300, Max = 1500, Default = SET.ALTITUDE },
    Increment = 50,
    Callback = function(v)
        SET.ALTITUDE = v
    end
})

farmSec:Slider({
    Title = "熄火判定(秒)",
    Value = { Min = 1, Max = 10, Default = SET.STALL_TIME },
    Increment = 1,
    Callback = function(v)
        SET.STALL_TIME = v
    end
})

farmSec:Slider({
    Title = "循环间隔(秒)",
    Value = { Min = 1, Max = 10, Default = SET.LOOP_DELAY },
    Increment = 1,
    Callback = function(v)
        SET.LOOP_DELAY = v
    end
})

farmSec:Button({
    Title = "手动结算",
    Callback = function()
        pcall(function() ReturnRemote:FireServer() end)
        WindUI:Notify({ Title = "已结算", Content = "已请求 Return 结算", Duration = 3 })
    end
})

farmSec:Toggle({
    Title = "移速加速",
    Default = false,
    Callback = function(state)
        boostOn = state
        if state then
            if not BlockInfo then
                WindUI:Notify({ Title = "错误", Content = "未找到BlocksUtil，加速不可用", Duration = 4 })
                return
            end
            storeOrigForce()
            setPropForce(boostSpeed)
            WindUI:Notify({ Title = "已启动", Content = "螺旋桨推力已提升，起飞后生效", Duration = 3 })
        else
            restoreOrigForce()
            WindUI:Notify({ Title = "已停止", Content = "螺旋桨推力已恢复", Duration = 3 })
        end
    end
})

farmSec:Slider({
    Title = "移速值",
    Value = { Min = 60, Max = 400, Default = boostSpeed },
    Increment = 10,
    Callback = function(v)
        boostSpeed = v
        if boostOn and BlockInfo then
            setPropForce(v)
        end
    end
})

local shopTab = Window:Tab({ Title = "购物", Icon = "settings" })

local opSection = shopTab:Section({ Title = "操作", TextXAlignment = "Left", TextSize = 17 })

opSection:Toggle({
    Title = "自动购买已选",
    Default = false,
    Callback = function(state)
        getgenv().BuildAPlaneAutoCart3 = state
        if state then
            task.spawn(autoBuySelectedLoop, StatusTag)
            WindUI:Notify({ Title = "已启动", Content = "自动购买已选物品", Duration = 3 })
        else
            WindUI:Notify({ Title = "已停止", Content = "自动购买已停止", Duration = 3 })
        end
    end
})

opSection:Button({
    Title = "购买已选物品",
    Callback = function()
        task.spawn(buySelected, StatusTag)
    end
})

local itemToggles = {}

local function buildListSection(sectionTitle, list)
    local sec = shopTab:Section({ Title = sectionTitle, TextXAlignment = "Left", TextSize = 15 })
    for _, nm in ipairs(list) do
        local tg = sec:Toggle({
            Title = displayName(nm),
            Default = cart[nm] == true,
            Callback = function(state)
                cart[nm] = state
            end
        })
        itemToggles[nm] = tg
    end
    sec:Button({
        Title = "全选本区",
        Callback = function()
            for _, nm in ipairs(list) do
                cart[nm] = true
                local tg = itemToggles[nm]
                if tg then pcall(function() tg:SetValue(true) end) end
            end
            StatusTag:SetTitle("已全选: " .. sectionTitle)
        end
    })
    sec:Button({
        Title = "清空本区",
        Callback = function()
            for _, nm in ipairs(list) do
                cart[nm] = false
                local tg = itemToggles[nm]
                if tg then pcall(function() tg:SetValue(false) end) end
            end
            StatusTag:SetTitle("已清空: " .. sectionTitle)
        end
    })
end

buildListSection("零件（37 种）", KNOWN_PARTS)
buildListSection("装备（3 种）", KNOWN_EQUIPS)


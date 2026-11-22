
	-- 忍者传奇：独立服务器缝合版
-- 当前服务器功能与独立界面整合版
-- 每个文件仅包含当前服务器的功能与独立关于分区

local NothingLibrary = loadstring(game:HttpGetAsync('https://raw.githubusercontent.com/quanwei-sy/qianweicangku/refs/heads/main/%E6%BA%90%E7%A0%81.lua'))()

local __BaseWindow = NothingLibrary.new({
    Title = "TY hub｜忍者传奇",
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
local LocalPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local islands = {
    {name = "附魔岛",       x = 58.837700,   y = 765.956055,   z = -132.327103},
    {name = "星界岛",       x = 240.192764,  y = 2013.809326,  z = 262.970642},
    {name = "神秘岛",       x = 157.453369,  y = 4047.156494,  z = 67.575119},
    {name = "太空岛",       x = 132.636856,  y = 5656.780273,  z = 84.043762},
    {name = "冻土岛",       x = 142.583878,  y = 9284.960938,  z = 81.353737},
    {name = "永恒岛",       x = 139.663177,  y = 13679.814453, z = 74.364204},
    {name = "沙暴岛",       x = 137.602142,  y = 17686.107422, z = 79.762215},
    {name = "雷暴岛",       x = 144.681763,  y = 24069.800781, z = 70.535057},
    {name = "远古试炼岛",   x = 135.091003,  y = 28256.072266, z = 72.206032},
    {name = "午夜暗影岛",   x = 133.933136,  y = 33206.757812, z = 61.787067},
    {name = "神秘灵魂岛",   x = 136.757950,  y = 39317.351562, z = 66.125198},
    {name = "冬季奇迹岛",   x = 137.700027,  y = 46010.332031, z = 67.936378},
    {name = "黄金大师岛",   x = 133.667450,  y = 52607.546875, z = 59.298328},
    {name = "龙传奇岛",     x = 136.343185,  y = 59594.460938, z = 62.818188},
    {name = "赛博传奇岛",   x = 134.897095,  y = 66668.953125, z = 59.924160},
    {name = "天梵超能岛",   x = 135.759415,  y = 70270.945312, z = 65.471672},
    {name = "混沌传奇岛",   x = 136.380219,  y = 74442.640625, z = 59.650558},
    {name = "灵魂融合岛",   x = 131.545914,  y = 79746.773438, z = 56.678509},
    {name = "黑暗元素岛",   x = 134.228622,  y = 83198.773438, z = 56.734966},
    {name = "禅心岛",       x = 132.658081,  y = 87050.859375, z = 61.767765},
    {name = "炽热旋涡之岛", x = 135.727097,  y = 91245.859375, z = 60.028637},
}


local function tp(island)
    local char = LocalPlayer.Character
    if not char then return false end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return false end
    root.CFrame = CFrame.new(island.x, island.y, island.z)
    pcall(function()
        WindUI:Notify({Title = "传送成功", Content = island.name, Duration = 2})
    end)
    return true
end

local unlocking = false

local function unlockAll()
    if unlocking then return end
    unlocking = true

    pcall(function()
        WindUI:Notify({Title = "开始解锁", Content = "共 " .. #islands .. " 个岛屿", Duration = 3})
    end)

    task.spawn(function()
        local count = 0
        for i, island in ipairs(islands) do
            if not unlocking then break end
            local char = LocalPlayer.Character
            if not char then break end
            local root = char:FindFirstChild("HumanoidRootPart")
            if not root then break end
            root.CFrame = CFrame.new(island.x, island.y, island.z)
            count = count + 1
            task.wait(0.8)
        end

        if unlocking and #islands > 0 then
            local char = LocalPlayer.Character
            if char then
                local root = char:FindFirstChild("HumanoidRootPart")
                if root then
                    root.CFrame = CFrame.new(islands[1].x, islands[1].y, islands[1].z)
                end
            end
        end

        pcall(function()
            WindUI:Notify({Title = "完成", Content = "已解锁 " .. count .. " 个岛", Duration = 4})
        end)

        unlocking = false
    end)
end

local function teleportToCF(cf)
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        char.HumanoidRootPart.CFrame = cf
    end
end

local function ninjaFire(...)
    local args = {...}
    pcall(function()
        LocalPlayer:WaitForChild("ninjaEvent"):FireServer(unpack(args))
    end)
end

local RANKS = {
    "Grasshopper","Apprentice","Samurai","Assassin","Shadow",
    "Ninja","Master Ninja","Sensei","Master Sensei","Ninja Legend",
    "Master Of Shadows","Immortal Assassin","Eternity Hunter","Shadow Legend","Dragon Warrior",
    "Dragon Master","Chaos Sensei","Chaos Legend","Master Of Elements","Elemental Legend",
    "Ancient Battle Master","Ancient Battle Legend","Legendary Shadow Duelist","Master Legend Assassin","Mythic Shadowmaster",
    "Legendary Shadowmaster","Awakened Scythemaster","Awakened Scythe Legend","Master Legend Zephyr","Golden Sun Shuriken Master",
    "Golden Sun Shuriken Legend","Dark Sun Samurai Legend","Dragon Evolution Form I","Dragon Evolution Form II","Dragon Evolution Form III",
    "Dragon Evolution Form IV","Dragon Evolution Form V","Cybernetic Electro Master","Cybernetic Electro Legend","Shadow Chaos Assassin",
    "Shadow Chaos Legend","Infinity Legend","Aether Genesis Master Ninja","Master Legend Sensei Hunter",
    "Skystorm Series Samurai Legend","Master Elemental Hero","Eclipse Series Soul Master","Starstrike Master Sensei","Evolved Series Master Ninja",
    "Dark Elements Guardian","Elite Series Master Legend","Infinity Shadows Master","Lighting Storm Sensei",
    "Dark Elements Blademaster","Rising Shadow Eternal Ninja","Skyblade Ninja Master","Shadow Storm Sensei","Comet Strike Lion",
    "Cybernetic Azure Sensei","Ultra Genesis Shadow"
}

local function doSell()
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("Head") then return end
    local head = char.Head
    local area = Workspace:FindFirstChild("sellAreaCircles")
    if not area then return end
    local circle = area:FindFirstChild("sellAreaCircle16")
    if not circle then return end
    local inner = circle:FindFirstChild("circleInner")
    if not inner then return end
    for _, v in ipairs(inner:GetDescendants()) do
        if v.Name == "TouchInterest" and v.Parent then
            pcall(function()
                firetouchinterest(head, v.Parent, 0)
                task.wait(0.1)
                firetouchinterest(head, v.Parent, 1)
            end)
            break
        end
    end
end

local function doHoops()
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        local folder = Workspace:FindFirstChild("Hoops")
        if folder then
            for _, hoop in ipairs(folder:GetChildren()) do
                if hoop.Name == "Hoop" then
                    hoop.CFrame = char.HumanoidRootPart.CFrame
                end
            end
        end
    end
end

local function doChi()
    local chiFolder = Workspace:FindFirstChild("spawnedCoins")
    if not chiFolder then return end
    local valley = chiFolder:FindFirstChild("Valley")
    if not valley then return end
    local list = {
        valley:FindFirstChild("Pink Chi Crate"),
        valley:FindFirstChild("Blue Chi Crate"),
        valley:FindFirstChild("Chi Crate"),
    }
    for _, crate in ipairs(list) do
        if crate then
            teleportToCF(crate.CFrame)
            task.wait(0.1)
        end
    end
end

local function doElementAll()
    local ev = ReplicatedStorage:FindFirstChild("rEvents") and ReplicatedStorage.rEvents:FindFirstChild("elementMasteryEvent")
    local elems = ReplicatedStorage:FindFirstChild("Elements")
    if not ev or not elems then return end
    for _, v in ipairs(elems:GetChildren()) do
        pcall(function() ev:FireServer(v.Name) end)
        task.wait()
    end
end

local function doBoss(name)
    local folder = Workspace:FindFirstChild("bossFolder")
    if not folder then return end
    local target = folder:FindFirstChild(name)
    if target and target:FindFirstChild("UpperTorso") then
        teleportToCF(target.UpperTorso.CFrame)
        ninjaFire("swingKatana")
    end
end

local function unlockAllPasses()
    local ids = ReplicatedStorage:FindFirstChild("gamepassIds")
    if not ids then return end
    local count = 0
    for _, v in ipairs(ids:GetChildren()) do
        pcall(function() v.Parent = LocalPlayer.ownedGamepasses end)
        count = count + 1
    end
    return count
end

local Auto = {
    swing = false, sell = false, rank = false, belt = false, sword = false,
    hoop = false, chi = false, bossNormal = false, bossEternal = false, bossMagma = false,
}

task.spawn(function()
    while true do
        if Auto.swing then ninjaFire("swingKatana") end
        if Auto.sell then pcall(doSell) end
        if Auto.hoop then pcall(doHoops) end
        if Auto.chi then pcall(doChi) end
        if Auto.bossNormal then pcall(doBoss, "RobotBoss") end
        if Auto.bossEternal then pcall(doBoss, "EternalBoss") end
        if Auto.bossMagma then pcall(doBoss, "AncientMagmaBoss") end
        if Auto.rank then
            for i = 1, #RANKS, 5 do
                for j = i, math.min(i + 4, #RANKS) do ninjaFire("buyRank", RANKS[j]) end
                task.wait()
            end
        end
        if Auto.belt then ninjaFire("buyAllBelts", "Blazing Vortex Island") end
        if Auto.sword then ninjaFire("buyAllSwords", "Blazing Vortex Island") end
        task.wait(0.2)
    end
end)


local windowOk, Window = pcall(function()
    return WindUI:CreateWindow({
    Title = "忍者传奇",
    Author = "权威不是权威",
    })
end)

if not windowOk then
    return
end


pcall(function()
    Window:EditOpenButton({
        Title = "TY",
        Icon = "sparkles",
        CornerRadius = UDim.new(0, 16),
        Draggable = true,
    })
end)


local tabOk, Tab = pcall(function()
    return Window:Tab({
        Title = "岛屿",
        Icon = "settings",
        Locked = false,
    })
end)

if not tabOk then
else

    pcall(function() Tab:Section({Title = "快速传送", TextXAlignment = "Left", TextSize = 14}) end)
    pcall(function() Tab:Button({Title = "回到附魔岛", Callback = function() tp(islands[1]) end}) end)
    pcall(function() Tab:Button({Title = "前往最高岛", Callback = function() tp(islands[#islands]) end}) end)

    pcall(function() Tab:Section({Title = "解锁全部岛屿", TextXAlignment = "Left", TextSize = 14}) end)
    pcall(function() Tab:Paragraph({Title = "说明", Desc = "点击按钮自动传送所有岛屿触发解锁，约15-20秒完成。完成后自动返回附魔岛。"}) end)
    pcall(function() Tab:Button({Title = "一键解锁全部岛屿", Callback = function() unlockAll() end}) end)

    pcall(function() Tab:Section({Title = "单岛传送", TextXAlignment = "Left", TextSize = 14}) end)
    local names = {}
    for _, v in ipairs(islands) do table.insert(names, v.name) end
    local selected = islands[1].name
    pcall(function()
        Tab:Dropdown({
            Title = "选择岛屿",
            Values = names,
            Value = names[1],
            Callback = function(val) selected = val end
        })
    end)
    pcall(function()
        Tab:Button({
            Title = "传送选中岛屿",
            Callback = function()
                for _, island in ipairs(islands) do
                    if island.name == selected then
                        tp(island)
                        break
                    end
                end
            end
        })
    end)
end

local tabAutoOk, TabAuto = pcall(function()
    return Window:Tab({Title = "自动", Icon = "settings", Locked = false})
end)

if tabAutoOk then
    pcall(function() TabAuto:Section({Title = "刷金币", TextXAlignment = "Left", TextSize = 14}) end)
    pcall(function()
        TabAuto:Toggle({Title = "自动挥刀", Default = false,
            Callback = function(state) Auto.swing = state end})
    end)
    pcall(function()
        TabAuto:Toggle({Title = "自动出售", Default = false,
            Callback = function(state) Auto.sell = state end})
    end)
    pcall(function()
        TabAuto:Toggle({Title = "自动吸气", Default = false,
            Callback = function(state) Auto.chi = state end})
    end)
    pcall(function()
        TabAuto:Toggle({Title = "吸环拉圈", Default = false,
            Callback = function(state) Auto.hoop = state end})
    end)

    pcall(function() TabAuto:Section({Title = "自动购买", TextXAlignment = "Left", TextSize = 14}) end)
    pcall(function()
        TabAuto:Toggle({Title = "自动买称号", Default = false,
            Callback = function(state) Auto.belt = state end})
    end)
    pcall(function()
        TabAuto:Toggle({Title = "自动买刀", Default = false,
            Callback = function(state) Auto.sword = state end})
    end)
    pcall(function()
        TabAuto:Toggle({Title = "自动重生职位", Default = false,
            Callback = function(state) Auto.rank = state end})
    end)

    pcall(function() TabAuto:Section({Title = "自动刷Boss", TextXAlignment = "Left", TextSize = 14}) end)
    pcall(function()
        TabAuto:Toggle({Title = "普通Boss", Default = false,
            Callback = function(state) Auto.bossNormal = state end})
    end)
    pcall(function()
        TabAuto:Toggle({Title = "永恒Boss", Default = false,
            Callback = function(state) Auto.bossEternal = state end})
    end)
    pcall(function()
        TabAuto:Toggle({Title = "岩浆Boss", Default = false,
            Callback = function(state) Auto.bossMagma = state end})
    end)

    pcall(function()
        TabAuto:Button({Title = "获取所有元素(永久)",
            Callback = function() pcall(doElementAll) end})
    end)
end

local tabFunOk, TabFun = pcall(function()
    return Window:Tab({Title = "功能", Icon = "settings", Locked = false})
end)

if tabFunOk then
    pcall(function() TabFun:Section({Title = "通行证", TextXAlignment = "Left", TextSize = 14}) end)
    pcall(function()
        TabFun:Button({Title = "解锁全部通行证",
            Callback = function()
                local n = unlockAllPasses()
                pcall(function() WindUI:Notify({Title = "完成", Content = "已解锁 " .. tostring(n) .. " 个通行证", Duration = 3}) end)
            end})
    end)
end

LocalPlayer.Chatted:Connect(function(msg)
    local lower = msg:lower()
    if lower:sub(1, 3) == "!tp" then
        for _, island in ipairs(islands) do
            if lower:find(island.name:lower()) then
                tp(island)
                break
            end
        end
    end
    if lower == "!unlockall" or lower == "!解锁全岛" then
        unlockAll()
    end
end)


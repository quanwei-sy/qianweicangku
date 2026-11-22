-- 致命猴子：独立服务器缝合版
-- 当前服务器功能与独立界面整合版
-- 每个文件仅包含当前服务器的功能与独立关于分区

local NothingLibrary = loadstring(game:HttpGetAsync('https://raw.githubusercontent.com/quanwei-sy/qianweicangku/refs/heads/main/%E6%BA%90%E7%A0%81.lua'))()

local __BaseWindow = NothingLibrary.new({
    Title = "TY hub｜致命猴子",
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


-- 致命猴子：原自绘界面已替换为以下 NothingLibrary 控件辅助函数
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local SoundService = game:GetService("SoundService")
local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera
local LoadStartTime = tick()
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local Theme = {
    Accent = Color3.fromRGB(110, 110, 255),
    AccentDim = Color3.fromRGB(60, 60, 130),
    Stroke = Color3.fromRGB(70, 70, 160),
}
local AccentObjects = {}
local Locked = false
local SavedSize = Vector2.new(580, 360)
local ScreenGui = { Destroy = function() end }
local Main = { Visible = true }
local MiniBox = { Visible = false }
local mainStroke = { Color = Theme.Stroke }
local miniStroke = { Color = Theme.Stroke }
local ActiveTab = nil
local __MonkeyWindow = Library:CreateWindow()
local __MonkeyControlId = 0

local function tween(obj, time, props, style, dir)
    if typeof(obj) ~= "Instance" then
        return { Completed = { Connect = function(_, callback) callback() end } }
    end
    local info = TweenInfo.new(time or 0.25, style or Enum.EasingStyle.Quart, dir or Enum.EasingDirection.Out)
    local animation = TweenService:Create(obj, info, props)
    animation:Play()
    return animation
end

local function playSound(id, volume)
    pcall(function()
        local sound = Instance.new("Sound", SoundService)
        sound.SoundId = id
        sound.Volume = volume or 0.5
        sound:Play()
        task.delay(3, function() sound:Destroy() end)
    end)
end

local function makeDraggable() end

local function createTab(name)
    local tab = __MonkeyWindow:AddTab(name)
    local page = tab:AddLeftGroupbox(name)
    local tabObject = {
        Page = page,
        Button = { BackgroundColor3 = Theme.AccentDim },
        Label = { TextColor3 = Color3.new(1, 1, 1) },
        Highlight = { Visible = true },
    }
    return tabObject
end

local function makeSectionTitle(parent, text)
    return parent:AddLabel(tostring(text))
end

local function makeParagraph(parent, text)
    return parent:AddLabel(tostring(text))
end

local function makeToggle(parent, text, default, callback)
    __MonkeyControlId = __MonkeyControlId + 1
    return parent:AddToggle("MonkeyToggle" .. __MonkeyControlId, {
        Text = tostring(text), Default = default == true, Callback = callback,
    })
end

local function makeSlider(parent, text, minValue, maxValue, default, callback)
    __MonkeyControlId = __MonkeyControlId + 1
    return parent:AddSlider("MonkeySlider" .. __MonkeyControlId, {
        Text = tostring(text), Min = minValue, Max = maxValue, Default = default, Callback = callback,
    })
end

local function makeButton(parent, text, iconName, callback)
    return parent:AddButton(tostring(text), callback)
end

local function makeDropdown(parent, text, options, default, callback)
    __MonkeyControlId = __MonkeyControlId + 1
    return parent:AddDropdown("MonkeyDropdown" .. __MonkeyControlId, {
        Text = tostring(text), Values = options, Default = default, Callback = callback,
    })
end

local function makeColorDropdown(parent, text, colors, callback)
    local names, byName = {}, {}
    for _, entry in ipairs(colors) do
        table.insert(names, entry.name)
        byName[entry.name] = entry
    end
    __MonkeyControlId = __MonkeyControlId + 1
    return parent:AddDropdown("MonkeyColor" .. __MonkeyControlId, {
        Text = tostring(text), Values = names, Default = names[1], Multi = false,
        Callback = function(name)
            local entry = byName[name]
            if entry and callback then callback(entry) end
        end,
    })
end

local function notify(title, content, duration)
    Library:Notify({ Title = title, Content = content, Duration = duration })
end

local function applyAccent(color)
    Theme.Accent = color
    Theme.AccentDim = Color3.new(color.R * 0.55, color.G * 0.55, color.B * 0.55)
    Theme.Stroke = Color3.new(color.R * 0.65, color.G * 0.65, color.B * 0.65)
end


local AUTHOR_NAME = "权威不是权威"

local monsterConfig = {
    { name = "Gus", parentPath = "GusMonster", childName = "Gus" },
    { name = "Kus", parentPath = "KusMonster", childName = "Kus" },
    { name = "Scar", parentPath = "Sandman/Ashy", childName = "Scar" },
    { name = "SandMan", parentPath = "Sandman/Ashy", childName = "SandMan" },
    { name = "Lurker", parentPath = "Sandman/Ashy", childName = "Lurker" },
    { name = "BloodMan", parentPath = "BloodmanMonster", childName = "BloodMan" },
    { name = "Ashy", parentPath = "Sandman/Ashy", childName = "Ashy" },
    { name = "Lost", parentPath = "LostMonster", childName = "Lost" },
    { name = "Dus", parentPath = "DusMonster", childName = "Dus" },
    { name = "SandGuy", parentPath = "Monsters", childName = "SandGuy" },
    { name = "Noxar", parentPath = "Monsters", childName = "Noxar" },
    { name = "Meat", parentPath = "Monsters", childName = "Meat" },
    { name = "Fearful", parentPath = "Monsters", childName = "Fearful" },
    { name = "Billy", parentPath = "Monsters", childName = "Billy" },
    { name = "Stalker", parentPath = "Stalker", childName = "Stalker" },
    { name = "John", parentPath = "Monsters", childName = "John" },
}

local espSettings = {
    enabled = false,
    highlightEnabled = true,
    nameEnabled = true,
    distanceEnabled = true,
    maxDistance = 500,
    highlightColor = Color3.fromRGB(255, 0, 0),
    outlineColor = Color3.fromRGB(255, 255, 255),
    nameColor = Color3.fromRGB(255, 255, 255),
    distanceColor = Color3.fromRGB(255, 235, 59),
    textSize = 14,
    fillTransparency = 0.5,
}

local monsterToggles = {}
for _, m in ipairs(monsterConfig) do
    monsterToggles[m.name] = true
end

local function resolveParent(parentPath)
    local ok, obj = pcall(function() return Workspace:FindFirstChild(parentPath, true) end)
    if ok and obj then return obj end
    if parentPath:find("/") then
        local current = Workspace
        for _, part in ipairs(string.split(parentPath, "/")) do
            current = current:FindFirstChild(part, true)
            if not current then return nil end
        end
        return current
    end
    return nil
end

local function getMonsterModel(monster)
    local parent = resolveParent(monster.parentPath)
    if not parent then return nil end
    local child = parent:FindFirstChild(monster.childName, true)
    if child and child:IsA("Model") then return child end
    if parent:IsA("Model") and parent.Name == monster.childName then return parent end
    if child then return child end
    return nil
end

local function getMonsterPart(model)
    if not model or not model:IsA("Model") then return nil end
    return model:FindFirstChild("HumanoidRootPart") or model:FindFirstChild("Head") or model.PrimaryPart
end

local espObjects = {}

local function clearMonsterESP(name)
    local cache = espObjects[name]
    if cache then
        if cache.highlight and cache.highlight.Parent then cache.highlight:Destroy() end
        if cache.billboard and cache.billboard.Parent then cache.billboard:Destroy() end
        espObjects[name] = nil
    end
end

local function clearAllESP()
    for name in pairs(espObjects) do
        clearMonsterESP(name)
    end
end

local function createHighlight(model, name)
    local hl = Instance.new("Highlight")
    hl.Name = "ESPHighlight_" .. name
    hl.Adornee = model
    hl.FillColor = espSettings.highlightColor
    hl.OutlineColor = espSettings.outlineColor
    hl.FillTransparency = espSettings.fillTransparency
    hl.OutlineTransparency = 0
    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    hl.Parent = model
    return hl
end

local function createBillboard(model, name)
    local head = model:FindFirstChild("Head") or getMonsterPart(model)
    if not head then return nil, nil end
    local bb = Instance.new("BillboardGui")
    bb.Name = "ESPBoard_" .. name
    bb.Adornee = head
    bb.Size = UDim2.new(0, 200, 0, 44)
    bb.StudsOffset = Vector3.new(0, 3, 0)
    bb.AlwaysOnTop = true
    bb.LightInfluence = 0
    bb.MaxDistance = espSettings.maxDistance * 10
    bb.Parent = head
    local nl = Instance.new("TextLabel")
    nl.Size = UDim2.new(1, 0, 0, 22)
    nl.BackgroundTransparency = 1
    nl.Text = name
    nl.TextColor3 = espSettings.nameColor
    nl.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    nl.TextStrokeTransparency = 0
    nl.Font = Enum.Font.GothamBold
    nl.TextSize = espSettings.textSize
    nl.Visible = espSettings.nameEnabled
    nl.Parent = bb
    local dl = Instance.new("TextLabel")
    dl.Size = UDim2.new(1, 0, 0, 18)
    dl.Position = UDim2.new(0, 0, 0, 22)
    dl.BackgroundTransparency = 1
    dl.Text = "0m"
    dl.TextColor3 = espSettings.distanceColor
    dl.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    dl.TextStrokeTransparency = 0
    dl.Font = Enum.Font.GothamSemibold
    dl.TextSize = espSettings.textSize - 2
    dl.Visible = espSettings.distanceEnabled
    dl.Parent = bb
    return bb, { nameLabel = nl, distLabel = dl }
end

local function updateMonsterESP(monster)
    local name = monster.name
    local model = getMonsterModel(monster)
    if not model then clearMonsterESP(name) return end
    if not espSettings.enabled or not monsterToggles[name] then
        clearMonsterESP(name)
        return
    end
    local part = getMonsterPart(model)
    if not part then
        clearMonsterESP(name)
        return
    end
    local distance = (Camera.CFrame.Position - part.Position).Magnitude
    if distance > espSettings.maxDistance then
        clearMonsterESP(name)
        return
    end
    local cache = espObjects[name]
    if not cache then
        cache = {}
        espObjects[name] = cache
    end
    if espSettings.highlightEnabled then
        if not cache.highlight or not cache.highlight.Parent then
            cache.highlight = createHighlight(model, name)
        else
            cache.highlight.FillColor = espSettings.highlightColor
            cache.highlight.OutlineColor = espSettings.outlineColor
            cache.highlight.FillTransparency = espSettings.fillTransparency
        end
    elseif cache.highlight then
        cache.highlight:Destroy()
        cache.highlight = nil
    end
    if espSettings.nameEnabled or espSettings.distanceEnabled then
        if not cache.billboard or not cache.billboard.Parent then
            cache.billboard, cache.labels = createBillboard(model, name)
        end
        if cache.labels then
            local nl, dl = cache.labels.nameLabel, cache.labels.distLabel
            if nl then
                nl.Text = name
                nl.TextColor3 = espSettings.nameColor
                nl.TextSize = espSettings.textSize
                nl.Visible = espSettings.nameEnabled
            end
            if dl then
                dl.Text = string.format("%.0f m", distance)
                dl.TextColor3 = espSettings.distanceColor
                dl.Visible = espSettings.distanceEnabled
            end
        end
    elseif cache.billboard then
        cache.billboard:Destroy()
        cache.billboard = nil
    end
end

local function updateAllESP()
    for _, m in ipairs(monsterConfig) do
        updateMonsterESP(m)
    end
end

local playerEspSettings = {
    enabled = false,
    highlightEnabled = true,
    nameEnabled = true,
    distanceEnabled = true,
    maxDistance = 1000,
    highlightColor = Color3.fromRGB(0, 255, 127),
    outlineColor = Color3.fromRGB(255, 255, 255),
    nameColor = Color3.fromRGB(0, 255, 127),
    distanceColor = Color3.fromRGB(255, 235, 59),
    textSize = 14,
    fillTransparency = 0.5,
    showSelf = false,
}

local playerEspObjects = {}

local function clearPlayerESP(plr)
    local cache = playerEspObjects[plr]
    if cache then
        if cache.highlight and cache.highlight.Parent then cache.highlight:Destroy() end
        if cache.billboard and cache.billboard.Parent then cache.billboard:Destroy() end
        playerEspObjects[plr] = nil
    end
end

local function clearAllPlayerESP()
    for plr in pairs(playerEspObjects) do
        clearPlayerESP(plr)
    end
end

local function createPlayerHighlight(char, plrName)
    local hl = Instance.new("Highlight")
    hl.Name = "PlayerESP_HL_" .. plrName
    hl.Adornee = char
    hl.FillColor = playerEspSettings.highlightColor
    hl.OutlineColor = playerEspSettings.outlineColor
    hl.FillTransparency = playerEspSettings.fillTransparency
    hl.OutlineTransparency = 0
    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    hl.Parent = char
    return hl
end

local function createPlayerBillboard(char, plrName)
    local head = char:FindFirstChild("Head")
    if not head then return nil, nil end
    local bb = Instance.new("BillboardGui")
    bb.Name = "PlayerESP_Board_" .. plrName
    bb.Adornee = head
    bb.Size = UDim2.new(0, 200, 0, 44)
    bb.StudsOffset = Vector3.new(0, 3, 0)
    bb.AlwaysOnTop = true
    bb.LightInfluence = 0
    bb.MaxDistance = playerEspSettings.maxDistance * 10
    bb.Parent = head
    local nl = Instance.new("TextLabel")
    nl.Size = UDim2.new(1, 0, 0, 22)
    nl.BackgroundTransparency = 1
    nl.Text = plrName
    nl.TextColor3 = playerEspSettings.nameColor
    nl.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    nl.TextStrokeTransparency = 0
    nl.Font = Enum.Font.GothamBold
    nl.TextSize = playerEspSettings.textSize
    nl.Visible = playerEspSettings.nameEnabled
    nl.Parent = bb
    local dl = Instance.new("TextLabel")
    dl.Size = UDim2.new(1, 0, 0, 18)
    dl.Position = UDim2.new(0, 0, 0, 22)
    dl.BackgroundTransparency = 1
    dl.Text = "0m"
    dl.TextColor3 = playerEspSettings.distanceColor
    dl.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    dl.TextStrokeTransparency = 0
    dl.Font = Enum.Font.GothamSemibold
    dl.TextSize = playerEspSettings.textSize - 2
    dl.Visible = playerEspSettings.distanceEnabled
    dl.Parent = bb
    return bb, { nameLbl = nl, distLbl = dl }
end

local function updateSinglePlayerESP(plr)
    if plr == LocalPlayer and not playerEspSettings.showSelf then
        clearPlayerESP(plr)
        return
    end
    local char = plr.Character
    if not char or not char:IsA("Model") then
        clearPlayerESP(plr)
        return
    end
    local hrp = char:FindFirstChild("HumanoidRootPart") or char.PrimaryPart
    if not hrp then
        clearPlayerESP(plr)
        return
    end
    local distance = (Camera.CFrame.Position - hrp.Position).Magnitude
    if distance > playerEspSettings.maxDistance then
        clearPlayerESP(plr)
        return
    end
    local cache = playerEspObjects[plr]
    if not cache then
        cache = {}
        playerEspObjects[plr] = cache
    end
    if playerEspSettings.highlightEnabled then
        if not cache.highlight or not cache.highlight.Parent then
            cache.highlight = createPlayerHighlight(char, plr.Name)
        else
            cache.highlight.FillColor = playerEspSettings.highlightColor
            cache.highlight.OutlineColor = playerEspSettings.outlineColor
            cache.highlight.FillTransparency = playerEspSettings.fillTransparency
        end
    elseif cache.highlight then
        cache.highlight:Destroy()
        cache.highlight = nil
    end
    if playerEspSettings.nameEnabled or playerEspSettings.distanceEnabled then
        if not cache.billboard or not cache.billboard.Parent then
            cache.billboard, cache.labels = createPlayerBillboard(char, plr.Name)
        end
        if cache.labels then
            local nl, dl = cache.labels.nameLbl, cache.labels.distLbl
            if nl then
                nl.Text = plr.Name
                nl.TextColor3 = playerEspSettings.nameColor
                nl.TextSize = playerEspSettings.textSize
                nl.Visible = playerEspSettings.nameEnabled
            end
            if dl then
                dl.Text = string.format("%.0f m", distance)
                dl.TextColor3 = playerEspSettings.distanceColor
                dl.Visible = playerEspSettings.distanceEnabled
            end
        end
    elseif cache.billboard then
        cache.billboard:Destroy()
        cache.billboard = nil
        cache.labels = nil
    end
end

local function updateAllPlayerESP()
    if not playerEspSettings.enabled then
        clearAllPlayerESP()
        return
    end
    local all = Players:GetPlayers()
    for plr in pairs(playerEspObjects) do
        if not table.find(all, plr) then
            clearPlayerESP(plr)
        end
    end
    for _, plr in ipairs(all) do
        updateSinglePlayerESP(plr)
    end
end

local authorEspObjects = {}

local function clearAuthorESP(plr)
    if authorEspObjects[plr] then
        for _, o in ipairs(authorEspObjects[plr]) do
            if o and o.Parent then o:Destroy() end
        end
        authorEspObjects[plr] = nil
    end
end

local function isAuthorPlayer(plr)
    return plr and string.lower(plr.Name) == string.lower(AUTHOR_NAME)
end

local authorAccum = 0
RunService.Heartbeat:Connect(function(dt)
    authorAccum = authorAccum + dt
    if authorAccum < 0.25 then return end
    authorAccum = 0
    pcall(function()
        for plr in pairs(authorEspObjects) do
            if not plr.Parent or not isAuthorPlayer(plr) then
                clearAuthorESP(plr)
            end
        end
        for _, plr in ipairs(Players:GetPlayers()) do
            if isAuthorPlayer(plr) and plr ~= LocalPlayer then
                local char = plr.Character
                if char and char:IsA("Model") then
                    local hrp = char:FindFirstChild("HumanoidRootPart") or char.PrimaryPart
                    local head = char:FindFirstChild("Head")
                    if hrp and head then
                        if not authorEspObjects[plr] then
                            authorEspObjects[plr] = {}
                        end
                        local hl = char:FindFirstChild("AuthorESP_HL_" .. plr.Name)
                        if not hl then
                            hl = Instance.new("Highlight")
                            hl.Name = "AuthorESP_HL_" .. plr.Name
                            hl.Adornee = char
                            hl.FillColor = Color3.fromRGB(255, 215, 0)
                            hl.OutlineColor = Color3.fromRGB(255, 255, 255)
                            hl.FillTransparency = 0.45
                            hl.OutlineTransparency = 0
                            hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                            hl.Parent = char
                            table.insert(authorEspObjects[plr], hl)
                        end
                        local bb = head:FindFirstChild("AuthorESP_Board_" .. plr.Name)
                        local distance = (Camera.CFrame.Position - hrp.Position).Magnitude
                        if not bb then
                            bb = Instance.new("BillboardGui")
                            bb.Name = "AuthorESP_Board_" .. plr.Name
                            bb.Adornee = head
                            bb.Size = UDim2.new(0, 220, 0, 60)
                            bb.StudsOffset = Vector3.new(0, 3, 0)
                            bb.AlwaysOnTop = true
                            bb.LightInfluence = 0
                            bb.Parent = head
                            local ttl = Instance.new("TextLabel")
                            ttl.Size = UDim2.new(1, 0, 0, 26)
                            ttl.BackgroundTransparency = 1
                            ttl.Text = "脚本作者"
                            ttl.TextColor3 = Color3.fromRGB(255, 215, 0)
                            ttl.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
                            ttl.TextStrokeTransparency = 0
                            ttl.Font = Enum.Font.GothamBold
                            ttl.TextSize = 20
                            ttl.Parent = bb
                            local sub = Instance.new("TextLabel")
                            sub.Size = UDim2.new(1, 0, 0, 18)
                            sub.Position = UDim2.new(0, 0, 0, 26)
                            sub.BackgroundTransparency = 1
                            sub.Text = plr.Name
                            sub.TextColor3 = Color3.fromRGB(255, 255, 255)
                            sub.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
                            sub.TextStrokeTransparency = 0
                            sub.Font = Enum.Font.GothamSemibold
                            sub.TextSize = 14
                            sub.Parent = bb
                            local dist = Instance.new("TextLabel")
                            dist.Name = "DistLabel"
                            dist.Size = UDim2.new(1, 0, 0, 16)
                            dist.Position = UDim2.new(0, 0, 0, 44)
                            dist.BackgroundTransparency = 1
                            dist.Text = "0m"
                            dist.TextColor3 = Color3.fromRGB(255, 235, 59)
                            dist.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
                            dist.TextStrokeTransparency = 0
                            dist.Font = Enum.Font.GothamSemibold
                            dist.TextSize = 12
                            dist.Parent = bb
                            table.insert(authorEspObjects[plr], bb)
                        else
                            local dist = bb:FindFirstChild("DistLabel")
                            if dist then
                                dist.Text = string.format("%.0f m", distance)
                            end
                        end
                    end
                else
                    clearAuthorESP(plr)
                end
            end
        end
    end)
end)

Players.PlayerRemoving:Connect(function(plr)
    clearPlayerESP(plr)
    clearAuthorESP(plr)
end)

local espAccum, pAccum = 0, 0
RunService.Heartbeat:Connect(function(dt)
    if espSettings.enabled then
        espAccum = espAccum + dt
        if espAccum >= 0.1 then
            espAccum = 0
            updateAllESP()
        end
    end
    if playerEspSettings.enabled then
        pAccum = pAccum + dt
        if pAccum >= 0.1 then
            pAccum = 0
            updateAllPlayerESP()
        end
    end
end)

local jumpscareActive = false
local jumpscareObjectNames = {
    "ScarJumpscare","SandmanJumpscare","LurkerKill","LostJumpscare","KusJumpscare","GusJumpscare","DusJumpscare","BloodManKill","AshyJumpscare",
    "SandGuyJumpscare","NoxarJumpscare","MeatJumpscare","FearfulJumpscare","BillyJumpscare","StalkerJumpscare","JohnJumpscare"
}
local jumpscareScriptNames = {
    "PlayScarJumpscareAnimLocal","PlaySawRunnerJumpscareAnimLocal","PlaySandmanJumpscareAnimLocal","PlayLurkerJumpscareAnimLocal","PlayLostJumpscareAnimLocal","PlayKusJumpscareAnimLocal","PlayGusJumpscareAnimLocal","PlayDusJumpscareAnimLocal","PlayBloodManJumpscareAnimLocal","PlayAshyJumpscareAnimLocal",
    "PlaySandGuyJumpscareAnimLocal","PlayNoxarJumpscareAnimLocal","PlayMeatJumpscareAnimLocal","PlayFearfulJumpscareAnimLocal","PlayBillyJumpscareAnimLocal","PlayStalkerJumpscareAnimLocal","PlayJohnJumpscareAnimLocal"
}

local function purgeJumpscare()
    local jumpscares = Workspace:FindFirstChild("Jumpscares")
    if jumpscares then
        for _, n in ipairs(jumpscareObjectNames) do
            local obj = jumpscares:FindFirstChild(n)
            if obj then
                pcall(function() obj:Destroy() end)
            end
        end
        for _, obj in ipairs(jumpscares:GetChildren()) do
            local nm = obj.Name
            if nm:match("Jumpscare") or nm:match("Kill") or nm:match("Scare") then
                pcall(function() obj:Destroy() end)
            end
        end
    end
    local playerScripts = LocalPlayer:FindFirstChild("PlayerScripts")
    if playerScripts then
        for _, obj in ipairs(playerScripts:GetChildren()) do
            if table.find(jumpscareScriptNames, obj.Name) then
                pcall(function()
                    if obj:IsA("LocalScript") or obj:IsA("Script") then
                        obj.Enabled = false
                    end
                    obj:Destroy()
                end)
            end
        end
    end
    local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
    if playerGui then
        for _, gui in ipairs(playerGui:GetChildren()) do
            local nm = gui.Name
            if nm:match("Jumpscare") or nm:match("Scare") or nm:match("JumpScare") then
                pcall(function() gui:Destroy() end)
            end
        end
    end
end

local function setJumpscareBlock(state)
    if state then
        if jumpscareActive then return end
        jumpscareActive = true
        purgeJumpscare()
        task.spawn(function()
            while jumpscareActive do
                purgeJumpscare()
                task.wait(0.3)
            end
        end)
    else
        jumpscareActive = false
    end
end

local playerSettings = {
    walkSpeed = 40,
    jumpPower = 60,
    gravity = 196,
    godMode = false
}

local function getHum()
    local char = LocalPlayer.Character
    return char and char:FindFirstChildOfClass("Humanoid")
end

local function applySpeed()
    local hum = getHum()
    if hum then
        pcall(function() hum.WalkSpeed = playerSettings.walkSpeed end)
    end
end

local function applyJump()
    local hum = getHum()
    if hum then
        pcall(function()
            hum.UseJumpPower = true
            hum.JumpPower = playerSettings.jumpPower
        end)
        pcall(function() hum.JumpHeight = playerSettings.jumpPower / 7 end)
    end
end

local infJumpConn = nil
local function setInfJump(state)
    if state then
        if infJumpConn then return end
        infJumpConn = UserInputService.JumpRequest:Connect(function()
            local hum = getHum()
            if hum then
                pcall(function() hum:ChangeState(Enum.HumanoidStateType.Jumping) end)
            end
        end)
    elseif infJumpConn then
        infJumpConn:Disconnect()
        infJumpConn = nil
    end
end

local function applyGravity()
    pcall(function() Workspace.Gravity = playerSettings.gravity end)
end

local fastInteractEnabled = false
local fastInteractConns = {}
local fastInteractLoopId = 0

local function makeFast(prompt)
    if prompt:IsA("ProximityPrompt") then
        prompt.HoldDuration = 0
        prompt.RequiresLineOfSight = false
    end
end

local function fastScanAll()
    for _, v in ipairs(Workspace:GetDescendants()) do
        makeFast(v)
    end
end

local function setFastInteract(state)
    fastInteractEnabled = state
    if state then
        fastInteractLoopId = fastInteractLoopId + 1
        local myId = fastInteractLoopId
        fastScanAll()
        table.insert(fastInteractConns, Workspace.DescendantAdded:Connect(makeFast))
        table.insert(fastInteractConns, LocalPlayer.CharacterAdded:Connect(function()
            task.wait(1)
            if fastInteractEnabled and myId == fastInteractLoopId then
                fastScanAll()
            end
        end))
        task.spawn(function()
            while fastInteractEnabled and myId == fastInteractLoopId do
                task.wait(5)
                if fastInteractEnabled and myId == fastInteractLoopId then
                    fastScanAll()
                end
            end
        end)
    else
        for _, conn in ipairs(fastInteractConns) do
            pcall(function() conn:Disconnect() end)
        end
        fastInteractConns = {}
    end
end

local keepThirdPerson = true
local function ApplyCamera()
    if keepThirdPerson then
        LocalPlayer.CameraMode = Enum.CameraMode.Classic
        LocalPlayer.CameraMinZoomDistance = 0.5
        LocalPlayer.CameraMaxZoomDistance = 128
    else
        LocalPlayer.CameraMode = Enum.CameraMode.LockFirstPerson
        LocalPlayer.CameraMinZoomDistance = 0.5
        LocalPlayer.CameraMaxZoomDistance = 0.5
    end
end

task.spawn(function()
    task.wait(1)
    if LocalPlayer.CameraMode == Enum.CameraMode.LockFirstPerson then
        ApplyCamera()
    end
end)

LocalPlayer.CharacterAdded:Connect(function()
    task.wait(0.5)
    ApplyCamera()
    applySpeed()
    applyJump()
    if playerSettings.godMode then
        local hum = getHum()
        if hum then
            pcall(function() hum.BreakJointsOnDeath = false end)
        end
    end
end)

if LocalPlayer.Character then
    ApplyCamera()
end

task.spawn(function()
    task.wait(0.5)
    applySpeed()
    applyJump()
end)

local assistSettings = {
    brightnessEnabled = false,
    brightnessLevel = 2
}

local brightnessPresets = {
    [1] = { brightness = 3, clockTime = 14, fogEnd = 100000, ambient = Color3.fromRGB(150, 150, 150), outdoorAmbient = Color3.fromRGB(150, 150, 150) },
    [2] = { brightness = 6, clockTime = 12, fogEnd = 1000000, ambient = Color3.fromRGB(200, 200, 200), outdoorAmbient = Color3.fromRGB(200, 200, 200) },
    [3] = { brightness = 20, clockTime = 12, fogEnd = 10000000, ambient = Color3.fromRGB(255, 255, 255), outdoorAmbient = Color3.fromRGB(255, 255, 255) },
}

local lightingOriginal = {}

local function applyBrightness()
    local preset = brightnessPresets[assistSettings.brightnessLevel]
    if not preset then return end
    if not next(lightingOriginal) then
        pcall(function()
            lightingOriginal.Brightness = Lighting.Brightness
            lightingOriginal.ClockTime = Lighting.ClockTime
            lightingOriginal.FogEnd = Lighting.FogEnd
            lightingOriginal.Ambient = Lighting.Ambient
            lightingOriginal.OutdoorAmbient = Lighting.OutdoorAmbient
            lightingOriginal.GlobalShadows = Lighting.GlobalShadows
        end)
    end
    pcall(function() Lighting.Brightness = preset.brightness end)
    pcall(function() Lighting.ClockTime = preset.clockTime end)
    pcall(function() Lighting.FogEnd = preset.fogEnd end)
    pcall(function() Lighting.Ambient = preset.ambient end)
    pcall(function() Lighting.OutdoorAmbient = preset.outdoorAmbient end)
    pcall(function() Lighting.GlobalShadows = false end)
end

local function restoreBrightness()
    if not next(lightingOriginal) then return end
    pcall(function() Lighting.Brightness = lightingOriginal.Brightness end)
    pcall(function() Lighting.ClockTime = lightingOriginal.ClockTime end)
    pcall(function() Lighting.FogEnd = lightingOriginal.FogEnd end)
    pcall(function() Lighting.Ambient = lightingOriginal.Ambient end)
    pcall(function() Lighting.OutdoorAmbient = lightingOriginal.OutdoorAmbient end)
    pcall(function() Lighting.GlobalShadows = lightingOriginal.GlobalShadows end)
    lightingOriginal = {}
end

local function fireRespawn()
    local evt = ReplicatedStorage:FindFirstChild("RequestRespawn") or ReplicatedStorage:WaitForChild("RequestRespawn", 3)
    if not evt then
        notify("致命猴子", "未找到 RequestRespawn", 3)
        return false
    end
    return pcall(function()
        if evt:IsA("RemoteEvent") then
            evt:FireServer()
        elseif evt:IsA("RemoteFunction") then
            evt:InvokeServer()
        elseif evt:IsA("BindableEvent") then
            evt:Fire()
        end
    end)
end

local function clickGameRespawnButton()
    local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
    if not playerGui then return false end
    local target = nil
    local ok = pcall(function()
        for _, obj in ipairs(playerGui:GetDescendants()) do
            if obj:IsA("GuiButton") and obj.Visible then
                local nm = string.lower(obj.Name)
                local txt = ""
                if obj:IsA("TextButton") then
                    txt = string.lower(obj.Text or "")
                end
                if nm:find("respawn") or nm:find("revive") or nm:find("rebirth") or txt:find("复活") or txt:find("重生") or txt:find("respawn") or txt:find("revive") then
                    target = obj
                    break
                end
            end
        end
    end)
    if ok and target then
        local fired = pcall(function()
            target.MouseButton1Click:Fire()
            target.Activated:Fire()
        end)
        return fired
    end
    return false
end

local function tryRespawn()
    if clickGameRespawnButton() then return true end
    return fireRespawn()
end

local autoRespawnConn = nil
local function setAutoRespawn(state)
    if state then
        if autoRespawnConn then return end
        autoRespawnConn = LocalPlayer.CharacterAdded:Connect(function(char)
            local hum = char:WaitForChild("Humanoid", 5)
            if not hum then return end
            hum.Died:Connect(function()
                task.wait(0.5)
                fireRespawn()
            end)
        end)
    elseif autoRespawnConn then
        autoRespawnConn:Disconnect()
        autoRespawnConn = nil
    end
end

local ColorTables = {
    red = Color3.fromRGB(255, 0, 0),
    green = Color3.fromRGB(0, 255, 0),
    blue = Color3.fromRGB(0, 0, 255),
    yellow = Color3.fromRGB(255, 255, 0),
    purple = Color3.fromRGB(128, 0, 255),
    cyan = Color3.fromRGB(0, 255, 255),
    white = Color3.fromRGB(255, 255, 255),
    black = Color3.fromRGB(0, 0, 0),
    orange = Color3.fromRGB(255, 150, 60),
    sgreen = Color3.fromRGB(0, 255, 127),
}

local rainbowActive = false
local rainbowConnection = nil
local function setRainbow(state)
    rainbowActive = state
    if rainbowConnection then
        rainbowConnection:Disconnect()
        rainbowConnection = nil
    end
    if state then
        local hue = 0
        rainbowConnection = RunService.Heartbeat:Connect(function(dt)
            hue = (hue + dt * 0.15) % 1
            local c = Color3.fromHSV(hue, 0.7, 1)
            Theme.Accent = c
            Theme.AccentDim = Color3.new(c.R * 0.55, c.G * 0.55, c.B * 0.55)
            Theme.Stroke = Color3.new(c.R * 0.65, c.G * 0.65, c.B * 0.65)
            for _, entry in ipairs(AccentObjects) do
                if entry.obj and entry.obj.Parent then
                    entry.obj[entry.prop] = c
                end
            end
            mainStroke.Color = c
            miniStroke.Color = c
        end)
    end
end

local safeZoneActive = false
local safeZoneConns = {}

local function destroySafeZones()
    pcall(function()
        local targets = {}
        for _, v in ipairs(Workspace:GetDescendants()) do
            if v:IsA("BasePart") or v:IsA("MeshPart") then
                if v.Name == "safe" or v.Name == "SafeZone" then
                    table.insert(targets, v)
                end
            elseif v:IsA("Folder") and (v.Name == "SafeZone" or v.Name == "AntiVoid") then
                table.insert(targets, v)
            end
        end
        for _, v in ipairs(targets) do
            pcall(function() v:Destroy() end)
        end
    end)
end

local function safeZoneOnAdded(d)
    task.defer(function()
        if not d or not d.Parent then return end
        if (d:IsA("BasePart") or d:IsA("MeshPart")) and (d.Name == "safe" or d.Name == "SafeZone") then
            pcall(function() d:Destroy() end)
        elseif d:IsA("Folder") and (d.Name == "SafeZone" or d.Name == "AntiVoid") then
            pcall(function() d:Destroy() end)
        end
    end)
end

local function setSafeZoneBlock(state)
    if state then
        if safeZoneActive then return end
        safeZoneActive = true
        destroySafeZones()
        table.insert(safeZoneConns, Workspace.DescendantAdded:Connect(safeZoneOnAdded))
        task.spawn(function()
            while safeZoneActive do
                task.wait(1)
                if not safeZoneActive then break end
                destroySafeZones()
            end
        end)
    else
        safeZoneActive = false
        for _, c in ipairs(safeZoneConns) do
            pcall(function() c:Disconnect() end)
        end
        safeZoneConns = {}
    end
end

local antiSlipActive = false
local antiSlipConn = nil

local function antiSlipStep()
    local character = LocalPlayer.Character
    if not character then return end
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    if not humanoid or not humanoidRootPart or humanoid.Health <= 0 then return end
    local assemblyLinearVelocity = humanoidRootPart.AssemblyLinearVelocity
    local moveDirection = humanoid.MoveDirection
    local walkSpeed = humanoid.WalkSpeed
    if walkSpeed <= 0 or walkSpeed > 200 then return end
    if moveDirection.Magnitude < 0.05 then
        if math.abs(assemblyLinearVelocity.X) > 0.01 or math.abs(assemblyLinearVelocity.Z) > 0.01 then
            humanoidRootPart.AssemblyLinearVelocity = Vector3.new(0, assemblyLinearVelocity.Y, 0)
        end
    else
        local target = moveDirection.Unit * walkSpeed
        humanoidRootPart.AssemblyLinearVelocity = Vector3.new(target.X, assemblyLinearVelocity.Y, target.Z)
    end
end

local function setAntiSlip(state)
    antiSlipActive = state
    if state then
        if antiSlipConn then return end
        antiSlipConn = RunService.Heartbeat:Connect(antiSlipStep)
    else
        if antiSlipConn then
            antiSlipConn:Disconnect()
            antiSlipConn = nil
        end
    end
end

local antiRagdollEnabled = false
local antiRagdollActiveChars = {}
local antiRagdollPlayerConns = {}
local antiRagdollPlayerAddedConn = nil

local AntiRagdoll = {}
local RAGDOLL_MOTORS = {
    Neck = "UpperTorso",
    Waist = "LowerTorso",
    Root = "LowerTorso",
    LeftShoulder = "LeftUpperArm",
    LeftElbow = "LeftLowerArm",
    LeftWrist = "LeftHand",
    RightShoulder = "RightUpperArm",
    RightElbow = "RightLowerArm",
    RightWrist = "RightHand",
    LeftHip = "LeftUpperLeg",
    LeftKnee = "LeftLowerLeg",
    LeftAnkle = "LeftFoot",
    RightHip = "RightUpperLeg",
    RightKnee = "RightLowerLeg",
    RightAnkle = "RightFoot",
}

local ragdollStates = {
    [Enum.HumanoidStateType.FallingDown] = true,
    [Enum.HumanoidStateType.Ragdoll] = true,
    [Enum.HumanoidStateType.Physics] = true,
}

local function isRagdollConstraint(obj)
    if obj:IsA("BallSocketConstraint") then
        return obj.Name:find("Ragdoll") ~= nil
    end
    if obj:IsA("AnimationConstraint") then
        return obj.Name:find("Ragdoll") ~= nil
    end
    return false
end

local function fixMotors(character)
    for name, parentName in pairs(RAGDOLL_MOTORS) do
        local parent = character:FindFirstChild(parentName)
        if parent then
            local motor = parent:FindFirstChild(name)
            if motor and motor:IsA("Motor6D") and not motor.Enabled then
                motor.Enabled = true
            end
        end
    end
end

local function clearRagdoll(character)
    for _, obj in ipairs(character:GetDescendants()) do
        if isRagdollConstraint(obj) then
            pcall(function() obj:Destroy() end)
        end
    end
end

local function unstick(humanoid)
    if ragdollStates[humanoid:GetState()] then
        humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
    end
    if humanoid.PlatformStand then
        humanoid.PlatformStand = false
    end
end

function AntiRagdoll.restore(character)
    if not character or not character.Parent then return end
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid or humanoid.Health <= 0 then return end
    clearRagdoll(character)
    fixMotors(character)
    unstick(humanoid)
end

function AntiRagdoll.protect(character)
    if not character or antiRagdollActiveChars[character] then return end
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid then
        humanoid = character:WaitForChild("Humanoid", 10)
    end
    if not humanoid or not character.Parent then return end
    local conns = {}
    conns[#conns + 1] = character.DescendantAdded:Connect(function(obj)
        if isRagdollConstraint(obj) then
            obj:Destroy()
        elseif obj:IsA("Motor6D") and not obj.Enabled then
            obj.Enabled = true
        end
    end)
    conns[#conns + 1] = humanoid.StateChanged:Connect(function(_, new)
        if ragdollStates[new] then
            task.defer(function()
                if humanoid.Parent and humanoid.Health > 0 then
                    humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
                end
            end)
        end
    end)
    conns[#conns + 1] = humanoid:GetPropertyChangedSignal("PlatformStand"):Connect(function()
        if humanoid.PlatformStand and humanoid.Health > 0 then
            humanoid.PlatformStand = false
        end
    end)
    conns[#conns + 1] = humanoid.Died:Connect(function()
        AntiRagdoll.unprotect(character)
    end)
    antiRagdollActiveChars[character] = conns
    AntiRagdoll.restore(character)
end

function AntiRagdoll.unprotect(character)
    local conns = antiRagdollActiveChars[character]
    if not conns then return end
    antiRagdollActiveChars[character] = nil
    for _, c in ipairs(conns) do
        if c.Connected then c:Disconnect() end
    end
end

local function setupAntiRagdollPlayer(player)
    if antiRagdollPlayerConns[player] then return end
    local conns = {}
    conns[#conns + 1] = player.CharacterAdded:Connect(function(char)
        if antiRagdollEnabled then
            task.spawn(function() AntiRagdoll.protect(char) end)
        end
    end)
    conns[#conns + 1] = player.CharacterRemoving:Connect(function(char)
        AntiRagdoll.unprotect(char)
    end)
    antiRagdollPlayerConns[player] = conns
    if player.Character and antiRagdollEnabled then
        task.spawn(function() AntiRagdoll.protect(player.Character) end)
    end
end

local function clearAntiRagdollPlayer(player)
    local conns = antiRagdollPlayerConns[player]
    if conns then
        for _, c in ipairs(conns) do
            if c.Connected then c:Disconnect() end
        end
        antiRagdollPlayerConns[player] = nil
    end
    if player.Character then
        AntiRagdoll.unprotect(player.Character)
    end
end

local function setAntiRagdoll(state)
    antiRagdollEnabled = state
    if state then
        if antiRagdollPlayerAddedConn then return end
        _G.AntiRagdoll = AntiRagdoll
        for _, p in ipairs(Players:GetPlayers()) do
            setupAntiRagdollPlayer(p)
        end
        antiRagdollPlayerAddedConn = Players.PlayerAdded:Connect(setupAntiRagdollPlayer)
    else
        if antiRagdollPlayerAddedConn then
            antiRagdollPlayerAddedConn:Disconnect()
            antiRagdollPlayerAddedConn = nil
        end
        for _, p in ipairs(Players:GetPlayers()) do
            clearAntiRagdollPlayer(p)
        end
        local chars = {}
        for char in pairs(antiRagdollActiveChars) do
            table.insert(chars, char)
        end
        for _, char in ipairs(chars) do
            AntiRagdoll.unprotect(char)
        end
        _G.AntiRagdoll = nil
    end
end

Players.PlayerRemoving:Connect(function(plr)
    clearAntiRagdollPlayer(plr)
end)

local scrapEspSettings = {
    enabled = false,
    highlightEnabled = true,
    nameEnabled = true,
    distanceEnabled = true,
    recyclerEnabled = true,
    maxDistance = 500,
    highlightColor = Color3.fromRGB(0, 255, 100),
    outlineColor = Color3.fromRGB(255, 255, 255),
    nameColor = Color3.fromRGB(0, 255, 100),
    distanceColor = Color3.fromRGB(255, 235, 59),
    textSize = 14,
    fillTransparency = 0.5,
}

local RECYCLER_COLOR = Color3.fromRGB(170, 85, 255)
local SCRAP_NAME_SET = {
    Screw = true, Pipe = true, Bucket = true, Baterry = true, Battery = true,
    Gear = true, Cleaner = true, Emerald = true, Amethyst = true, AmethystCrystal = true,
    Diamond = true, Gold = true, Copper = true, Meat = true,
}

local scrapsFolderCache = nil
local goldsFolderCache = nil

local function getScrapsFolder()
    if scrapsFolderCache and scrapsFolderCache.Parent == Workspace then return scrapsFolderCache end
    scrapsFolderCache = Workspace:FindFirstChild("Scraps")
    return scrapsFolderCache
end

local function getGoldsFolder()
    if goldsFolderCache and goldsFolderCache.Parent == Workspace then return goldsFolderCache end
    goldsFolderCache = Workspace:FindFirstChild("Golds")
    return goldsFolderCache
end

local function getScrapAnchor(obj)
    if obj:IsA("BasePart") then return obj end
    if obj:IsA("Model") or obj:IsA("Tool") then
        return obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")
    end
    return nil
end

local function getScrapRoot(obj)
    local scraps = getScrapsFolder()
    local golds = getGoldsFolder()
    local root = obj
    local p = obj.Parent
    while p and p ~= Workspace and p ~= scraps and p ~= golds do
        if SCRAP_NAME_SET[p.Name] or p.Name == "ScrapRecycler" then
            return p
        end
        root = p
        p = p.Parent
    end
    return root
end

local function classifyScrap(obj)
    if not (obj:IsA("BasePart") or obj:IsA("Model") or obj:IsA("Tool")) then return nil end
    if obj.Name == "ScrapRecycler" then
        if getScrapRoot(obj) ~= obj then return nil end
        return "recycler"
    end
    local kind = nil
    if SCRAP_NAME_SET[obj.Name] then
        kind = "scrap"
    else
        local scraps = getScrapsFolder()
        if scraps and obj ~= scraps and obj:IsDescendantOf(scraps) then
            kind = "scrap"
        end
        if not kind then
            local golds = getGoldsFolder()
            if golds and obj ~= golds and obj:IsDescendantOf(golds) then
                kind = "scrap"
            end
        end
    end
    if not kind then return nil end
    local root = getScrapRoot(obj)
    if root ~= obj then return nil end
    return kind
end

local scrapEspObjects = {}

local function isScrapTargetValid(obj)
    if not obj or not obj.Parent then return false end
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr.Character and obj:IsDescendantOf(plr.Character) then return false end
        local bp = plr:FindFirstChild("Backpack")
        if bp and obj:IsDescendantOf(bp) then return false end
    end
    local anchor = getScrapAnchor(obj)
    if not anchor then return false end
    if anchor.Transparency >= 0.99 then return false end
    if anchor.Position.Y < -500 then return false end
    return true
end

local function clearScrapESP(obj)
    local cache = scrapEspObjects[obj]
    if not cache then return end
    if cache.ancestryConn then
        pcall(function() cache.ancestryConn:Disconnect() end)
        cache.ancestryConn = nil
    end
    if cache.highlight then
        pcall(function() cache.highlight:Destroy() end)
        cache.highlight = nil
    end
    if cache.billboard then
        pcall(function() cache.billboard:Destroy() end)
        cache.billboard = nil
    end
    cache.labels = nil
    scrapEspObjects[obj] = nil
end

local function clearAllScrapESP()
    for obj in pairs(scrapEspObjects) do
        clearScrapESP(obj)
    end
end

local function updateSingleScrapESP(obj)
    local cache = scrapEspObjects[obj]
    local kind = classifyScrap(obj)
    if not scrapEspSettings.enabled or not kind then
        if cache then clearScrapESP(obj) end
        return
    end
    if kind == "recycler" and not scrapEspSettings.recyclerEnabled then
        if cache then clearScrapESP(obj) end
        return
    end
    if not isScrapTargetValid(obj) then
        if cache then clearScrapESP(obj) end
        return
    end
    local anchor = getScrapAnchor(obj)
    if not anchor then
        if cache then clearScrapESP(obj) end
        return
    end
    local distance = (Camera.CFrame.Position - anchor.Position).Magnitude
    if distance > scrapEspSettings.maxDistance then
        if cache then clearScrapESP(obj) end
        return
    end
    if not cache then
        cache = { kind = kind }
        scrapEspObjects[obj] = cache
        cache.ancestryConn = obj.AncestryChanged:Connect(function()
            pcall(updateSingleScrapESP, obj)
        end)
    end
    cache.kind = kind
    if scrapEspSettings.highlightEnabled then
        local fillColor = (kind == "recycler") and RECYCLER_COLOR or scrapEspSettings.highlightColor
        if not cache.highlight or not cache.highlight.Parent then
            local hl = Instance.new("Highlight")
            hl.Name = "ScrapESP_HL"
            hl.Adornee = obj
            hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
            hl.OutlineTransparency = 0
            hl.Parent = obj
            cache.highlight = hl
        end
        cache.highlight.FillColor = fillColor
        cache.highlight.OutlineColor = scrapEspSettings.outlineColor
        cache.highlight.FillTransparency = scrapEspSettings.fillTransparency
    elseif cache.highlight then
        pcall(function() cache.highlight:Destroy() end)
        cache.highlight = nil
    end
    if scrapEspSettings.nameEnabled or scrapEspSettings.distanceEnabled then
        if not cache.billboard or not cache.billboard.Parent then
            local bb = Instance.new("BillboardGui")
            bb.Name = "ScrapESP_Board"
            bb.Adornee = anchor
            bb.Size = UDim2.new(0, 200, 0, 44)
            bb.StudsOffset = Vector3.new(0, 2.5, 0)
            bb.AlwaysOnTop = true
            bb.LightInfluence = 0
            bb.MaxDistance = scrapEspSettings.maxDistance * 10
            bb.Parent = anchor
            local nl = Instance.new("TextLabel")
            nl.Name = "NameLabel"
            nl.Size = UDim2.new(1, 0, 0, 22)
            nl.BackgroundTransparency = 1
            nl.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
            nl.TextStrokeTransparency = 0
            nl.Font = Enum.Font.GothamBold
            nl.Parent = bb
            local dl = Instance.new("TextLabel")
            dl.Name = "DistLabel"
            dl.Size = UDim2.new(1, 0, 0, 18)
            dl.Position = UDim2.new(0, 0, 0, 22)
            dl.BackgroundTransparency = 1
            dl.Text = "0m"
            dl.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
            dl.TextStrokeTransparency = 0
            dl.Font = Enum.Font.GothamSemibold
            dl.Parent = bb
            cache.billboard = bb
            cache.labels = { name = nl, dist = dl }
        end
        local nl = cache.labels and cache.labels.name
        local dl = cache.labels and cache.labels.dist
        if nl then
            nl.Text = (kind == "recycler") and "废品回收机" or obj.Name
            nl.TextColor3 = (kind == "recycler") and RECYCLER_COLOR or scrapEspSettings.nameColor
            nl.TextSize = scrapEspSettings.textSize
            nl.Visible = scrapEspSettings.nameEnabled
        end
        if dl then
            dl.Text = string.format("%.0f m", distance)
            dl.TextColor3 = scrapEspSettings.distanceColor
            dl.TextSize = math.max(scrapEspSettings.textSize - 2, 8)
            dl.Visible = scrapEspSettings.distanceEnabled
        end
    elseif cache.billboard then
        pcall(function() cache.billboard:Destroy() end)
        cache.billboard = nil
        cache.labels = nil
    end
end

local function updateAllScrapESP()
    for obj in pairs(scrapEspObjects) do
        pcall(updateSingleScrapESP, obj)
    end
end

local function scanAllScraps()
    pcall(function()
        for _, d in ipairs(Workspace:GetDescendants()) do
            if classifyScrap(d) then
                updateSingleScrapESP(d)
            end
        end
    end)
end

Workspace.DescendantAdded:Connect(function(d)
    if not scrapEspSettings.enabled then return end
    task.defer(function()
        if classifyScrap(d) then
            pcall(updateSingleScrapESP, d)
        else
            local root = getScrapRoot(d)
            if root and classifyScrap(root) then
                pcall(updateSingleScrapESP, root)
            end
        end
    end)
end)

local scrapValidateAccum, scrapScanAccum = 0, 0
RunService.Heartbeat:Connect(function(dt)
    if not scrapEspSettings.enabled then
        if next(scrapEspObjects) then clearAllScrapESP() end
        return
    end
    scrapValidateAccum = scrapValidateAccum + dt
    scrapScanAccum = scrapScanAccum + dt
    if scrapValidateAccum >= 0.3 then
        scrapValidateAccum = 0
        updateAllScrapESP()
    end
    if scrapScanAccum >= 2 then
        scrapScanAccum = 0
        scanAllScraps()
    end
end)
--＝＝＝＝＝ 功能区域 结束 ＝＝＝＝＝

--＝＝＝＝＝ Tabs 创建 ＝＝＝＝＝
local TabNotice = createTab("公告", "shield")
local PNotice = TabNotice.Page
makeSectionTitle(PNotice, "作者信息", "shield")
makeButton(PNotice, "复制作者QQ", "check", function()
    local copyText = "3935754168"
    pcall(function()
        if setclipboard then setclipboard(copyText)
        elseif toclipboard then toclipboard(copyText) end
    end)
    notify("致命猴子", "已复制到剪贴板", 3)
end)
makeSectionTitle(PNotice, "公告", "shield")
makeParagraph(PNotice, "作者：权威不是权威")
makeSectionTitle(PNotice, "更新日志", "bolt")
makeParagraph(PNotice, "脚本QQ1群948082232　QQ2群1105225845")

local MainTab = createTab("怪物透视", "home")
local P1 = MainTab.Page
makeSectionTitle(P1, "ESP 总开关", "bolt")
makeToggle(P1, "ESP 总开关", false, function(state)
    espSettings.enabled = state
    if not state then clearAllESP() end
    notify("致命猴子", state and "ESP 已开启" or "ESP 已关闭", 3)
end)
makeSectionTitle(P1, "显示选项", "shield")
makeToggle(P1, "怪物高亮", true, function(v) espSettings.highlightEnabled = v end)
makeToggle(P1, "怪物名字", true, function(v) espSettings.nameEnabled = v end)
makeToggle(P1, "距离显示", true, function(v) espSettings.distanceEnabled = v end)
makeSectionTitle(P1, "参数调节", "settings")
makeSlider(P1, "最大显示距离", 50, 2000, 500, function(v) espSettings.maxDistance = v end)
makeSlider(P1, "填充透明度", 0, 100, 50, function(v) espSettings.fillTransparency = v / 100 end)
makeSlider(P1, "文字大小", 10, 24, 14, function(v) espSettings.textSize = v end)
makeSectionTitle(P1, "怪物单独开关", "bolt")
for _, m in ipairs(monsterConfig) do
    makeToggle(P1, m.name, true, function(v) monsterToggles[m.name] = v end)
end

local TabColor = createTab("颜色设置", "palette")
local P2 = TabColor.Page
makeSectionTitle(P2, "怪物ESP颜色", "palette")
makeColorDropdown(P2, "高亮填充颜色", {
    { name = "红色", color = ColorTables.red },
    { name = "绿色", color = ColorTables.green },
    { name = "蓝色", color = ColorTables.blue },
    { name = "黄色", color = ColorTables.yellow },
    { name = "紫色", color = ColorTables.purple },
    { name = "青色", color = ColorTables.cyan },
    { name = "白色", color = ColorTables.white },
    { name = "黑色", color = ColorTables.black },
}, function(entry) espSettings.highlightColor = entry.color end)
makeColorDropdown(P2, "高亮描边颜色", {
    { name = "白色", color = ColorTables.white },
    { name = "红色", color = ColorTables.red },
    { name = "绿色", color = ColorTables.green },
    { name = "蓝色", color = ColorTables.blue },
    { name = "黄色", color = ColorTables.yellow },
    { name = "黑色", color = ColorTables.black },
}, function(entry) espSettings.outlineColor = entry.color end)
makeColorDropdown(P2, "怪物名字颜色", {
    { name = "白色", color = ColorTables.white },
    { name = "红色", color = Color3.fromRGB(255, 50, 50) },
    { name = "黄色", color = Color3.fromRGB(255, 235, 59) },
    { name = "绿色", color = Color3.fromRGB(50, 255, 50) },
    { name = "青色", color = ColorTables.cyan },
    { name = "紫色", color = Color3.fromRGB(200, 100, 255) },
}, function(entry) espSettings.nameColor = entry.color end)

local TabPlayerESP = createTab("玩家透视", "users")
local P3 = TabPlayerESP.Page
makeSectionTitle(P3, "玩家 ESP 总开关", "users")
makeToggle(P3, "玩家透视总开关", false, function(state)
    playerEspSettings.enabled = state
    if not state then clearAllPlayerESP() end
    notify("致命猴子", state and "玩家透视已开启" or "玩家透视已关闭", 3)
end)
makeSectionTitle(P3, "显示选项", "shield")
makeToggle(P3, "玩家高亮", true, function(v) playerEspSettings.highlightEnabled = v end)
makeToggle(P3, "玩家名字", true, function(v) playerEspSettings.nameEnabled = v end)
makeToggle(P3, "距离显示", true, function(v) playerEspSettings.distanceEnabled = v end)
makeToggle(P3, "显示自己", false, function(v) playerEspSettings.showSelf = v end)
makeSectionTitle(P3, "参数调节", "settings")
makeSlider(P3, "最大显示距离", 50, 3000, 1000, function(v) playerEspSettings.maxDistance = v end)
makeSlider(P3, "填充透明度", 0, 100, 50, function(v) playerEspSettings.fillTransparency = v / 100 end)
makeSlider(P3, "文字大小", 10, 24, 14, function(v) playerEspSettings.textSize = v end)
makeSectionTitle(P3, "颜色设置", "palette")
makeColorDropdown(P3, "高亮填充颜色", {
    { name = "绿色", color = ColorTables.sgreen },
    { name = "红色", color = ColorTables.red },
    { name = "蓝色", color = ColorTables.blue },
    { name = "黄色", color = ColorTables.yellow },
    { name = "紫色", color = ColorTables.purple },
    { name = "青色", color = ColorTables.cyan },
}, function(entry) playerEspSettings.highlightColor = entry.color end)
makeColorDropdown(P3, "玩家名字颜色", {
    { name = "绿色", color = ColorTables.sgreen },
    { name = "白色", color = ColorTables.white },
    { name = "红色", color = Color3.fromRGB(255, 50, 50) },
    { name = "黄色", color = Color3.fromRGB(255, 235, 59) },
    { name = "青色", color = ColorTables.cyan },
    { name = "紫色", color = Color3.fromRGB(200, 100, 255) },
}, function(entry) playerEspSettings.nameColor = entry.color end)

local TabScrap = createTab("变卖物透视", "zap")
local PScrap = TabScrap.Page
makeSectionTitle(PScrap, "变卖物 ESP 总开关", "bolt")
makeToggle(PScrap, "变卖物透视总开关", false, function(state)
    scrapEspSettings.enabled = state
    if not state then
        clearAllScrapESP()
        notify("致命猴子", "变卖物透视已关闭", 3)
    else
        scanAllScraps()
        notify("致命猴子", "变卖物透视已开启", 3)
    end
end)
makeToggle(PScrap, "显示回收机", true, function(v)
    scrapEspSettings.recyclerEnabled = v
    updateAllScrapESP()
end)
makeSectionTitle(PScrap, "显示选项", "shield")
makeToggle(PScrap, "变卖物高亮", true, function(v)
    scrapEspSettings.highlightEnabled = v
    updateAllScrapESP()
end)
makeToggle(PScrap, "变卖物名字", true, function(v)
    scrapEspSettings.nameEnabled = v
    updateAllScrapESP()
end)
makeToggle(PScrap, "距离显示", true, function(v)
    scrapEspSettings.distanceEnabled = v
    updateAllScrapESP()
end)
makeSectionTitle(PScrap, "参数调节", "settings")
makeSlider(PScrap, "最大显示距离", 50, 2000, 500, function(v) scrapEspSettings.maxDistance = v end)
makeSlider(PScrap, "填充透明度", 0, 100, 50, function(v)
    scrapEspSettings.fillTransparency = v / 100
    updateAllScrapESP()
end)
makeSlider(PScrap, "文字大小", 10, 24, 14, function(v)
    scrapEspSettings.textSize = v
    updateAllScrapESP()
end)
makeSectionTitle(PScrap, "颜色设置", "palette")
makeColorDropdown(PScrap, "高亮填充颜色", {
    { name = "绿色", color = Color3.fromRGB(0, 255, 100) },
    { name = "红色", color = ColorTables.red },
    { name = "蓝色", color = ColorTables.blue },
    { name = "黄色", color = ColorTables.yellow },
    { name = "紫色", color = ColorTables.purple },
    { name = "青色", color = ColorTables.cyan },
    { name = "白色", color = ColorTables.white },
    { name = "黑色", color = ColorTables.black },
}, function(entry)
    scrapEspSettings.highlightColor = entry.color
    updateAllScrapESP()
end)
makeColorDropdown(PScrap, "名字颜色", {
    { name = "绿色", color = Color3.fromRGB(0, 255, 100) },
    { name = "白色", color = ColorTables.white },
    { name = "红色", color = Color3.fromRGB(255, 50, 50) },
    { name = "黄色", color = Color3.fromRGB(255, 235, 59) },
    { name = "青色", color = ColorTables.cyan },
    { name = "紫色", color = Color3.fromRGB(200, 100, 255) },
}, function(entry)
    scrapEspSettings.nameColor = entry.color
    updateAllScrapESP()
end)

local TabPlayer = createTab("玩家功能", "user")
local P4 = TabPlayer.Page
makeSectionTitle(P4, "怪物突脸", "shield")
makeToggle(P4, "删除怪物突脸", false, function(state)
    setJumpscareBlock(state)
    notify("致命猴子", state and "突脸已删除" or "突脸删除已关闭", 3)
end)
makeSectionTitle(P4, "秒交互", "bolt")
makeToggle(P4, "秒交互", false, function(v)
    setFastInteract(v)
    notify("致命猴子", v and "秒交互已开启" or "秒交互已关闭", 3)
end)
makeSectionTitle(P4, "速度", "bolt")
makeSlider(P4, "行走速度", 40, 500, 40, function(v)
    playerSettings.walkSpeed = v
    applySpeed()
end)
makeDropdown(P4, "速度", { "默认(40)", "快速(50)", "极速(150)", "光速(300)", "超光速(500)" }, "默认(40)", function(sel)
    local presets = { ["默认(40)"] = 40, ["快速(50)"] = 50, ["极速(150)"] = 150, ["光速(300)"] = 300, ["超光速(500)"] = 500 }
    playerSettings.walkSpeed = presets[sel] or 40
    applySpeed()
end)
makeSectionTitle(P4, "跳跃控制", "bolt")
makeSlider(P4, "跳跃力", 60, 500, 60, function(v)
    playerSettings.jumpPower = v
    applyJump()
end)
makeToggle(P4, "无限跳跃", false, function(v) setInfJump(v) end)
makeSectionTitle(P4, "重力调节", "bolt")
makeSlider(P4, "重力", 0, 400, 196, function(v)
    playerSettings.gravity = v
    applyGravity()
end)
makeSectionTitle(P4, "复活", "check")
makeButton(P4, "点击复活", "check", function()
    local ok = tryRespawn()
    notify("致命猴子", ok and "已点击复活" or "复活失败", 3)
end)
makeToggle(P4, "快速复活", false, function(v) setAutoRespawn(v) end)
makeSectionTitle(P4, "第三人称", "user")
makeToggle(P4, "第三人称", true, function(state)
    keepThirdPerson = state
    ApplyCamera()
    notify("致命猴子", state and "第三人称已开启" or "第三人称已关闭", 3)
end)
makeSectionTitle(P4, "防摔倒", "shield")
makeToggle(P4, "防摔倒", false, function(state)
    setAntiRagdoll(state)
    notify("致命猴子", state and "防摔倒已开启" or "防摔倒已关闭", 3)
end)

local TabAssist = createTab("其他功能", "zap")
local P5 = TabAssist.Page
makeSectionTitle(P5, "亮度提升", "zap")
makeToggle(P5, "亮度提升", false, function(state)
    assistSettings.brightnessEnabled = state
    if state then applyBrightness() else restoreBrightness() end
    notify("致命猴子", state and "亮度提升已开启" or "亮度提升已关闭", 3)
end)
makeDropdown(P5, "亮度等级", { "微亮", "中亮", "超亮" }, "中亮", function(sel)
    local levels = { ["微亮"] = 1, ["中亮"] = 2, ["超亮"] = 3 }
    assistSettings.brightnessLevel = levels[sel] or 2
    if assistSettings.brightnessEnabled then applyBrightness() end
end)
makeSectionTitle(P5, "监控", "wind")
makeButton(P5, "看监控（坐在凳子上）", "wind", function()
    pcall(function()
        loadstring(game:HttpGet("https://pastefy.app/xrN4PmHf/raw"))()
    end)
    notify("致命猴子", "看监控已执行，请坐在凳子上", 3)
end)
makeSectionTitle(P5, "无敌", "wind")
makeButton(P5, "无敌（BloodMan/ApeMonster无效!）", "wind", function()
    pcall(function()
        loadstring(game:HttpGet("https://pastefy.app/tE2g9f2v/raw"))()
    end)
    notify("致命猴子", "无敌脚本已执行", 3)
end)

local TabTools = createTab("其他脚本", "wind")
local P6 = TabTools.Page
makeSectionTitle(P6, "外置脚本", "wind")
makeButton(P6, "茉莉璐Script [推荐]", "wind", function()
    pcall(function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/M0Li1u/GhostlyPilot--/refs/heads/main/LETHAL-APE.lua"))()
    end)
    notify("致命猴子", "茉莉璐Script 已执行", 3)
end)
makeButton(P6, "飞行脚本", "wind", function()
    pcall(function()
        loadstring(game:HttpGet("https://pastefy.app/sgSR0W9o/raw"))()
    end)
    notify("致命猴子", "飞行脚本已执行", 3)
end)
makeButton(P6, "刷钱脚本", "wind", function()
    pcall(function()
        loadstring(game:HttpGet("https://pastefy.app/3Kw0rzcA/raw"))()
    end)
    notify("致命猴子", "刷钱脚本已执行", 3)
end)
makeButton(P6, "工具获取器", "wind", function()
    pcall(function()
        local TweenServiceL = game:GetService("TweenService")
        local PlayerGuiL = LocalPlayer:WaitForChild("PlayerGui")
        local ITEMS = {
            { label = "获取手电筒", names = {"Flashlight", "FlashLight", "Torch"}, keywords = {"flashlight", "flash light", "torch", "手电筒"}, color = Color3.fromRGB(255, 170, 60) },
            { label = "获取雷达", names = {"Radar"}, keywords = {"radar", "雷达"}, color = Color3.fromRGB(70, 165, 255) },
        }
        local function getBackpack()
            local bp = LocalPlayer:FindFirstChildOfClass("Backpack")
            if not bp then bp = LocalPlayer:WaitForChild("Backpack", 5) end
            return bp
        end
        local function hasItem(names)
            local bp = getBackpack()
            local char = LocalPlayer.Character
            for _, n in ipairs(names) do
                if bp and bp:FindFirstChild(n) then return true end
                if char and char:FindFirstChild(n) then return true end
            end
            return false
        end
        local function findToolSource(names)
            local roots = { Workspace, ReplicatedStorage, getBackpack(), LocalPlayer:FindFirstChild("StarterGear") }
            for _, root in ipairs(roots) do
                if root then
                    for _, n in ipairs(names) do
                        local obj = root:FindFirstChild(n, true)
                        if obj and obj:IsA("Tool") then return obj end
                    end
                end
            end
            return nil
        end
        local function tryPrompts(keywords)
            local touched = false
            for _, d in ipairs(Workspace:GetDescendants()) do
                if d:IsA("ProximityPrompt") then
                    local holder = d.Parent
                    if holder then
                        local name = holder.Name:lower()
                        for _, k in ipairs(keywords) do
                            if string.find(name, k, 1, true) then
                                touched = true
                                d.MaxActivationDistance = 1e6
                                d.HoldDuration = 0
                                d.RequiresLineOfSight = false
                                pcall(function()
                                    d:InputHoldBegin()
                                    task.wait(0.06)
                                    d:InputHoldEnd()
                                end)
                                break
                            end
                        end
                    end
                end
            end
            return touched
        end
        local function grabItem(item)
            if hasItem(item.names) then return false, "背包里已经有了" end
            tryPrompts(item.keywords)
            task.wait(0.5)
            if hasItem(item.names) then return true, "已获取 " .. item.names[1] end
            local src = findToolSource(item.names)
            if src then
                local bp = getBackpack()
                if bp then
                    local clone = src:Clone()
                    clone.Parent = bp
                    return true, "已获取 " .. clone.Name .. "（本地）"
                end
            end
            return false, "没找到该物品"
        end
        local old = PlayerGuiL:FindFirstChild("ToolGrabberUI")
        if old then old:Destroy() end
        local TGui = Instance.new("ScreenGui")
        TGui.Name = "ToolGrabberUI"
        TGui.ResetOnSpawn = false
        TGui.IgnoreGuiInset = true
        TGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        TGui.Parent = PlayerGuiL
        local FULL_SIZE = UDim2.new(0, 250, 0, 190)
        local MINI_SIZE = UDim2.new(0, 250, 0, 34)
        local TMain = Instance.new("Frame")
        TMain.Name = "Main"
        TMain.AnchorPoint = Vector2.new(0.5, 0)
        TMain.Position = UDim2.new(0.5, 0, 0.3, 0)
        TMain.Size = FULL_SIZE
        TMain.BackgroundColor3 = Color3.fromRGB(28, 28, 34)
        TMain.BorderSizePixel = 0
        TMain.ClipsDescendants = true
        TMain.Active = true
        TMain.Parent = TGui
        local tCorner = Instance.new("UICorner")
        tCorner.CornerRadius = UDim.new(0, 10)
        tCorner.Parent = TMain
        local tStroke = Instance.new("UIStroke")
        tStroke.Color = Color3.fromRGB(62, 62, 78)
        tStroke.Thickness = 1
        tStroke.Parent = TMain
        local TTitleBar = Instance.new("Frame")
        TTitleBar.Name = "TitleBar"
        TTitleBar.Size = UDim2.new(1, 0, 0, 34)
        TTitleBar.BackgroundColor3 = Color3.fromRGB(38, 38, 48)
        TTitleBar.BorderSizePixel = 0
        TTitleBar.Parent = TMain
        local TTitle = Instance.new("TextLabel")
        TTitle.Size = UDim2.new(1, -80, 1, 0)
        TTitle.Position = UDim2.new(0, 12, 0, 0)
        TTitle.BackgroundTransparency = 1
        TTitle.Font = Enum.Font.GothamBold
        TTitle.Text = "工具获取器"
        TTitle.TextColor3 = Color3.fromRGB(235, 235, 245)
        TTitle.TextSize = 14
        TTitle.TextXAlignment = Enum.TextXAlignment.Left
        TTitle.Parent = TTitleBar
        local function makeIconButton(text, xOffset, color)
            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(0, 28, 0, 28)
            btn.Position = UDim2.new(1, xOffset, 0.5, -14)
            btn.BackgroundColor3 = color
            btn.BorderSizePixel = 0
            btn.AutoButtonColor = false
            btn.Text = text
            btn.Font = Enum.Font.GothamBold
            btn.TextSize = 15
            btn.TextColor3 = Color3.fromRGB(230, 230, 240)
            btn.Parent = TTitleBar
            local c = Instance.new("UICorner")
            c.CornerRadius = UDim.new(0, 6)
            c.Parent = btn
            btn.MouseEnter:Connect(function()
                TweenServiceL:Create(btn, TweenInfo.new(0.12), { BackgroundColor3 = color:Lerp(Color3.new(1, 1, 1), 0.18) }):Play()
            end)
            btn.MouseLeave:Connect(function()
                TweenServiceL:Create(btn, TweenInfo.new(0.12), { BackgroundColor3 = color }):Play()
            end)
            return btn
        end
        local TMinBtn = makeIconButton("–", -66, Color3.fromRGB(58, 58, 72))
        local TCloseBtn = makeIconButton("×", -34, Color3.fromRGB(70, 45, 45))
        local TBody = Instance.new("Frame")
        TBody.Name = "Body"
        TBody.Position = UDim2.new(0, 0, 0, 34)
        TBody.Size = UDim2.new(1, 0, 1, -34)
        TBody.BackgroundTransparency = 1
        TBody.Parent = TMain
        local function makeActionButton(text, yOffset, color, parent)
            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(1, -28, 0, 42)
            btn.Position = UDim2.new(0, 14, 0, yOffset)
            btn.BackgroundColor3 = color
            btn.BorderSizePixel = 0
            btn.AutoButtonColor = false
            btn.Text = text
            btn.Font = Enum.Font.GothamBold
            btn.TextSize = 14
            btn.TextColor3 = Color3.fromRGB(255, 255, 255)
            btn.Parent = parent
            local c = Instance.new("UICorner")
            c.CornerRadius = UDim.new(0, 8)
            c.Parent = btn
            btn.MouseEnter:Connect(function()
                TweenServiceL:Create(btn, TweenInfo.new(0.12), { BackgroundColor3 = color:Lerp(Color3.new(1, 1, 1), 0.15) }):Play()
            end)
            btn.MouseLeave:Connect(function()
                TweenServiceL:Create(btn, TweenInfo.new(0.12), { BackgroundColor3 = color }):Play()
            end)
            btn.MouseButton1Down:Connect(function()
                TweenServiceL:Create(btn, TweenInfo.new(0.08), { BackgroundColor3 = color:Lerp(Color3.new(0, 0, 0), 0.2) }):Play()
            end)
            btn.MouseButton1Up:Connect(function()
                TweenServiceL:Create(btn, TweenInfo.new(0.08), { BackgroundColor3 = color }):Play()
            end)
            return btn
        end
        local TStatus = Instance.new("TextLabel")
        TStatus.Name = "Status"
        TStatus.Size = UDim2.new(1, -28, 0, 26)
        TStatus.Position = UDim2.new(0, 14, 1, -34)
        TStatus.BackgroundTransparency = 1
        TStatus.Font = Enum.Font.Gotham
        TStatus.Text = "就绪"
        TStatus.TextColor3 = Color3.fromRGB(150, 150, 165)
        TStatus.TextSize = 12
        TStatus.TextXAlignment = Enum.TextXAlignment.Left
        TStatus.TextWrapped = true
        TStatus.Parent = TBody
        local busy = false
        local function setStatus(text, color, resetAfter)
            TStatus.Text = text
            TStatus.TextColor3 = color
            if resetAfter then
                local snapshot = text
                task.delay(resetAfter, function()
                    if TStatus.Text == snapshot then
                        TStatus.Text = "就绪"
                        TStatus.TextColor3 = Color3.fromRGB(150, 150, 165)
                    end
                end)
            end
        end
        local function onGrab(item)
            if busy then return end
            busy = true
            setStatus("正在获取 " .. item.names[1] .. " ...", Color3.fromRGB(200, 200, 215))
            task.spawn(function()
                local ok, msg = grabItem(item)
                if ok then
                    setStatus(msg, Color3.fromRGB(120, 230, 140), 2)
                else
                    setStatus(msg, Color3.fromRGB(255, 120, 120), 2)
                end
                busy = false
            end)
        end
        local FlashBtn = makeActionButton(ITEMS[1].label, 14, ITEMS[1].color, TBody)
        local RadarBtn = makeActionButton(ITEMS[2].label, 68, ITEMS[2].color, TBody)
        FlashBtn.MouseButton1Click:Connect(function() onGrab(ITEMS[1]) end)
        RadarBtn.MouseButton1Click:Connect(function() onGrab(ITEMS[2]) end)
        local tdragging = false
        local tdragStart = nil
        local tstartPos = nil
        TTitleBar.InputBegan:Connect(function(input)
            if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then return end
            local t = input.Target
            if t == TMinBtn or t == TCloseBtn or (t and (t.Parent == TMinBtn or t.Parent == TCloseBtn)) then return end
            tdragging = true
            tdragStart = input.Position
            tstartPos = TMain.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    tdragging = false
                end
            end)
        end)
        UserInputService.InputChanged:Connect(function(input)
            if not tdragging then return end
            if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
                local delta = input.Position - tdragStart
                TMain.Position = UDim2.new(tstartPos.X.Scale, tstartPos.X.Offset + delta.X, tstartPos.Y.Scale, tstartPos.Y.Offset + delta.Y)
            end
        end)
        local tminimized = false
        TMinBtn.MouseButton1Click:Connect(function()
            tminimized = not tminimized
            TBody.Visible = not tminimized
            TweenServiceL:Create(TMain, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Size = tminimized and MINI_SIZE or FULL_SIZE }):Play()
            TMinBtn.Text = tminimized and "+" or "–"
        end)
        TCloseBtn.MouseButton1Click:Connect(function()
            TGui:Destroy()
        end)
    end)
    notify("致命猴子", "工具获取器已打开", 3)
end)
makeButton(P6, "彩虹猴子（每个人都可以看见）", "wind", function()
    pcall(function()
        loadstring(game:HttpGet("https://pastebin.com/raw/7JSnvWQL"))()
    end)
    notify("致命猴子", "彩虹猴子脚本已执行", 3)
end)
makeButton(P6, "致命猿BKU脚本（推荐）", "wind", function()
    pcall(function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/Baloksxin/ROBLOX-BKU-SCRIPT/refs/heads/main/BKU%20SCRIPT.LUA"))()
    end)
    notify("致命猴子", "致命猿BKU脚本已执行", 3)
end)
makeButton(P6, "BTM", "wind", function()
    pcall(function()
        loadstring(game:HttpGet("https://pastefy.app/YY2gA86S/raw"))()
    end)
    notify("致命猴子", "BTM 脚本已执行", 3)
end)

local TabNPC = createTab("控制NPC", "users")
local P7 = TabNPC.Page

makeSectionTitle(P7, "NPC 绑定", "users")
makeButton(P7, "固定在NPC脚底下", "check", function()
	pcall(function()
		loadstring(game:HttpGet("https://pastefy.app/IqnYy8x3/raw"))()
	end)
	notify("致命猴子", "固定NPC脚本已执行", 3)
end)
makeButton(P7, "反NPC", "check", function()
	pcall(function()
		loadstring(game:HttpGet("https://pastefy.app/VP1WCpZ8/raw"))()
	end)
	notify("致命猴子", "反NPC脚本已执行", 3)
end)

makeSectionTitle(P7, "控制修复", "shield")
makeButton(P7, "防NPC乱动", "shield", function()
	pcall(function()
		local Players = game:GetService("Players")
		local Workspace = game:GetService("Workspace")
		local LocalPlayer = Players.LocalPlayer

		getgenv().DisableWalkTo = true

		local origNamecall
		local inNamecall = false
		local controlledHumanoids = {}

		local function isPlayerCharacter(model)
			if not model then return false end
			if model == LocalPlayer.Character then return true end
			for _, p in ipairs(Players:GetPlayers()) do
				if p ~= LocalPlayer and p.Character == model then
					return true
				end
			end
			return false
		end

		local function updateControlledHumanoids()
			table.clear(controlledHumanoids)
			local charHum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
			if charHum then
				controlledHumanoids[charHum] = true
			end
			local cam = Workspace.CurrentCamera
			local subject = cam and cam.CameraSubject
			if subject then
				local hum = (subject.ClassName == "Humanoid") and subject or (subject:IsA("Model") and subject:FindFirstChildOfClass("Humanoid"))
				if not hum and subject.Parent then
					hum = subject.Parent:FindFirstChildOfClass("Humanoid")
				end
				if hum and hum.Parent and not isPlayerCharacter(hum.Parent) then
					controlledHumanoids[hum] = true
				end
			end
		end

		task.spawn(function()
			while true do
				updateControlledHumanoids()
				task.wait(1)
			end
		end)

		origNamecall = hookmetamethod(game, "__namecall", function(...)
			if not getgenv().DisableWalkTo or inNamecall then
				return origNamecall(...)
			end
			inNamecall = true
			local method = getnamecallmethod()
			local self = (...)
			inNamecall = false
			if method == "MoveTo" then
				if controlledHumanoids[self] then
					return
				end
				if typeof(self) == "Instance" and self:IsA("Model") then
					local hum = self:FindFirstChildOfClass("Humanoid")
					if hum and controlledHumanoids[hum] then
						return
					end
				end
			end
			return origNamecall(...)
		end)

		local walkToResetting = {}
		local walkToHooked = {}

		local function hookWalkTo(humanoid)
			if walkToHooked[humanoid] then return end
			walkToHooked[humanoid] = true
			walkToResetting[humanoid] = false

			humanoid:GetPropertyChangedSignal("WalkToPoint"):Connect(function()
				if not getgenv().DisableWalkTo or walkToResetting[humanoid] then return end
				if not controlledHumanoids[humanoid] then return end
				walkToResetting[humanoid] = true
				task.defer(function()
					if humanoid.Parent then
						local root = humanoid.RootPart or (humanoid.Parent and humanoid.Parent:FindFirstChild("HumanoidRootPart"))
						humanoid.WalkToPoint = root and root.Position or Vector3.new()
						humanoid.WalkToPart = nil
					end
					walkToResetting[humanoid] = false
				end)
			end)

			humanoid:GetPropertyChangedSignal("WalkToPart"):Connect(function()
				if not getgenv().DisableWalkTo or walkToResetting[humanoid] then return end
				if not controlledHumanoids[humanoid] then return end
				walkToResetting[humanoid] = true
				task.defer(function()
					if humanoid.Parent then
						humanoid.WalkToPart = nil
					end
					walkToResetting[humanoid] = false
				end)
			end)
		end

		task.spawn(function()
			while true do
				for hum in pairs(controlledHumanoids) do
					if hum.Parent then
						hookWalkTo(hum)
					end
				end
				task.wait(1)
			end
		end)
	end)
	notify("致命猴子", "防NPC乱动已执行", 3)
end)
makeButton(P7, "修复控制NPC黑屏", "check", function()
	pcall(function()
		local PlayerGuiF = LocalPlayer:WaitForChild("PlayerGui")
		local CameraF = workspace.CurrentCamera
		local SKIP = { "joystick","thumbstick","control","move","mobile","button","touch","pad","input","walk","sprint","jump" }

		local function isSkipped(obj)
			local name = obj.Name:lower()
			for _, k in ipairs(SKIP) do
				if name:find(k) then return true end
			end
			local p = obj.Parent
			while p and p ~= PlayerGuiF do
				local pn = p.Name:lower()
				for _, k in ipairs(SKIP) do
					if pn:find(k) then return true end
				end
				p = p.Parent
			end
			return false
		end

		local function clearLighting()
			for _, v in ipairs(Lighting:GetDescendants()) do
				if v:IsA("ColorCorrectionEffect") or v:IsA("BlurEffect") or v:IsA("DepthOfFieldEffect") or v:IsA("SunRaysEffect") then
					v:Destroy()
				end
			end
			Lighting.Ambient = Color3.fromRGB(140, 140, 140)
			Lighting.OutdoorAmbient = Color3.fromRGB(140, 140, 140)
			Lighting.Brightness = 2
			Lighting.ClockTime = 14
			Lighting.FogEnd = 1e6
			Lighting.FogStart = 0
		end

		local function clearGUI()
			local vp = CameraF.ViewportSize
			for _, obj in ipairs(PlayerGuiF:GetDescendants()) do
				if obj:IsA("GuiObject") and obj.Visible and not isSkipped(obj) then
					local sz = obj.AbsoluteSize
					local fullscreen = sz.X >= vp.X * 0.9 and sz.Y >= vp.Y * 0.9
					if fullscreen then
						if obj.BackgroundTransparency < 1 and obj.BackgroundColor3.R < 0.2 and obj.BackgroundColor3.G < 0.2 and obj.BackgroundColor3.B < 0.2 then
							obj.BackgroundTransparency = 1
						end
						if obj:IsA("ImageLabel") and obj.ImageTransparency < 1 then
							obj.ImageTransparency = 1
						end
					end
				end
			end
		end

		clearLighting()
		clearGUI()

		if not _G._GusiFixConn then
			local pending = false
			_G._GusiFixConn = PlayerGuiF.DescendantAdded:Connect(function()
				if pending then return end
				pending = true
				task.delay(0.2, function()
					pending = false
					clearGUI()
				end)
			end)
		end
	end)
	notify("致命猴子", "修复控制NPC黑屏已执行", 3)
end)

makeSectionTitle(P7, "控制NPC汉化", "users")
makeButton(P7, "控制NPC汉化", "wind", function()
	pcall(function()
		loadstring(game:HttpGet("https://pastebin.com/raw/2dU621nr"))()
	end)
	notify("致命猴子", "控制NPC汉化脚本已执行", 3)
end)

makeSectionTitle(P7, "安全阻拦", "shield")
makeToggle(P7, "删除安全阻拦", false, function(state)
	setSafeZoneBlock(state)
	notify("致命猴子", state and "删除安全阻拦已开启" or "删除安全阻拦已关闭", 3)
end)

makeSectionTitle(P7, "防滑", "bolt")
makeToggle(P7, "防脚滑", false, function(state)
	setAntiSlip(state)
	notify("致命猴子", state and "防脚滑已开启" or "防脚滑已关闭", 3)
end)

makeSectionTitle(P7, "删除对象", "bolt")
makeButton(P7, "删除古巴商店卷帘门", "check", function()
	local deleted = false
	pcall(function()
		local obj = Workspace:FindFirstChild("Shoper")
		if obj then
			obj:Destroy()
			deleted = true
		end
	end)
	notify("致命猴子", deleted and "古巴商店卷帘门 已删除" or "未找到 Shoper", 3)
end)
makeButton(P7, "删除出生点空气墙", "check", function()
	local deleted = false
	pcall(function()
		local mt = Workspace:FindFirstChild("MonsterTeleport")
		if mt then
			local obj = mt:FindFirstChild("AntiMonstro")
			if obj then
				obj:Destroy()
				deleted = true
			end
		end
	end)
	notify("致命猴子", deleted and "出生点空气墙已删除" or "未找到 AntiMonstro", 3)
end)

local SettingTab = createTab("UI设置", "settings")
local PUI = SettingTab.Page
makeSectionTitle(PUI, "界面", "shield")
makeToggle(PUI, "固定Ui/最小化方框", false, function(v) Locked = v end)
makeParagraph(PUI, "开启后，主窗口、ER方框和右下角缩放块均被锁定")
makeSectionTitle(PUI, "UI 颜色", "bolt")
makeColorDropdown(PUI, "UI 颜色", {
    { name = "默认蓝", color = Color3.fromRGB(110, 110, 255) },
    { name = "红色", color = Color3.fromRGB(255, 80, 100) },
    { name = "绿色", color = Color3.fromRGB(80, 200, 120) },
    { name = "紫色", color = Color3.fromRGB(180, 90, 255) },
    { name = "橙色", color = Color3.fromRGB(255, 150, 60) },
    { name = "青色", color = Color3.fromRGB(80, 220, 240) },
    { name = "彩色（动态）", color = Color3.fromRGB(200, 200, 200), rainbow = true },
}, function(entry)
    if entry.rainbow then
        setRainbow(true)
    else
        setRainbow(false)
        applyAccent(entry.color)
    end
end)


-- 原自绘窗口的打开、最小化和关闭代码已由 NothingLibrary 替代。

task.spawn(function()
    playSound("rbxassetid://6042053626", 0.4)
    local loadTime = math.floor((tick() - LoadStartTime) * 1000)
    notify("TY hub", "UI 已加载，用时 " .. loadTime .. " ms", 4)
end)

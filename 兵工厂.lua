-- 兵工厂：独立服务器缝合版
local NothingLibrary = loadstring(game:HttpGetAsync('https://raw.githubusercontent.com/quanwei-sy/qianweicangku/refs/heads/main/%E6%BA%90%E7%A0%81.lua'))()

local __BaseWindow = NothingLibrary.new({
    Title = "TY hub｜兵工厂",
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
    Toggled = true,
    Scheme = {
        BackgroundColor = Color3.fromRGB(15, 15, 15),
        MainColor = Color3.fromRGB(25, 25, 25),
        AccentColor = Color3.fromRGB(125, 85, 255),
        OutlineColor = Color3.fromRGB(40, 40, 40),
        FontColor = Color3.new(1, 1, 1),
        DarkColor = Color3.new(0, 0, 0),
    },
    __unloadCallbacks = {},
}
local WindUI = Library
local WI = Library
local ThemeManager = __ManagerStub()
local SaveManager = __ManagerStub()
local Options = Library.Options
local Toggles = Library.Toggles
local value = Library
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
        if self.Type == "Input" then self.Text = value == nil and "" or tostring(value) end
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

    function control:__Attach(raw, owner)
        self.__raw = raw
        self.__section = owner or self.__section
        return self
    end

    function control:AddKeyPicker(a, b)
        if self.__section then return self.__section:AddKeyPicker(a, b) end
        return __NewControl(nil)
    end

    function control:AddColorPicker(a, b)
        if self.__section then return self.__section:AddColorPicker(a, b) end
        return __NewControl(Color3.new(1, 1, 1))
    end

    function control:AddButton(a, b, c)
        if self.__section then return self.__section:AddButton(a, b, c) end
        return __NewControl(nil)
    end

    function control:SetName(text)
        return self:SetText(text)
    end

    function control:SetLocked()
        return self
    end

    function control:SetImage()
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
        if type(self.__onSetValue) == "function" then pcall(self.__onSetValue, value) end
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
    local value = info.Text or info.Title or info.Label or info.Name or info.DisplayName or info.title or info.text or info.name or fallback or ""
    if type(value) == "function" then
        local ok, result = pcall(value)
        value = ok and result or ""
    end
    return tostring(value)
end

local function __Default(info)
    if info.Default ~= nil then
        return info.Default
    end
    if info.Value ~= nil and type(info.Value) ~= "table" then return info.Value end
    if info.value ~= nil then return info.value end
    if info.default ~= nil then return info.default end
    return nil
end


local __FunctionalCanvasCount = 0
local function __NewFunctionalCanvas(info)
    info = info or {}
    __FunctionalCanvasCount = __FunctionalCanvasCount + 1
    local gui = Instance.new("ScreenGui")
    gui.Name = "TYHubFunctionalCanvas" .. tostring(__FunctionalCanvasCount)
    gui.ResetOnSpawn = false
    gui.IgnoreGuiInset = true
    gui.DisplayOrder = 20 + __FunctionalCanvasCount
    pcall(function()
        gui.Parent = (type(gethui) == "function" and gethui()) or game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
    end)
    local root = Instance.new("Frame")
    root.Name = tostring(info.DisplayName or info.Name or "功能画布")
    root.Size = UDim2.fromOffset(400, 180)
    root.Position = UDim2.fromOffset(20 + ((__FunctionalCanvasCount - 1) % 2) * 420, 20 + math.floor((__FunctionalCanvasCount - 1) / 2) * 150)
    root.BackgroundColor3 = Color3.fromRGB(18, 18, 24)
    root.BackgroundTransparency = 0.25
    root.BorderSizePixel = 0
    root.Active = true
    root.Draggable = true
    root.ClipsDescendants = true
    root.Parent = gui
    local corner = Instance.new("UICorner", root)
    corner.CornerRadius = UDim.new(0, 8)
    local canvas = { Instance = root, __elements = {}, __resizeCallbacks = {}, __destroyed = false }
    local unit = 20
    local contentLines = 9
    local destroyedConnections = {}

    local function colorValue(value, fallback)
        if typeof(value) == "Color3" then return value end
        if type(value) == "string" then
            local ok, result = pcall(Color3.fromHex, value)
            if ok then return result end
        end
        return fallback or Color3.new(1, 1, 1)
    end

    local function rawOf(value)
        if type(value) == "table" and value.Instance then return value.Instance end
        return value
    end

    local function apply(wrapper)
        local object, props = wrapper.Instance, wrapper.__props
        if not object or not object.Parent then return end
        local parent = rawOf(props.Parent)
        if parent then object.Parent = parent end
        object.Position = UDim2.fromOffset((tonumber(props.X) or 0) * unit, (tonumber(props.Y) or 0) * unit)
        object.Size = UDim2.fromOffset(math.max(0, (tonumber(props.Width) or 1) * unit), math.max(0, (tonumber(props.Height) or 1) * unit))
        if props.Visible ~= nil then object.Visible = props.Visible end
        if props.ZIndex ~= nil then object.ZIndex = props.ZIndex end
        if object:IsA("TextLabel") or object:IsA("TextButton") then
            object.Text = tostring(props.Text or "")
            object.TextColor3 = colorValue(props.Color, Color3.new(1, 1, 1))
            object.TextWrapped = props.Wrap == true
            object.RichText = true
            object.BackgroundTransparency = tonumber(props.BackgroundTransparency) or 1
            object.TextStrokeTransparency = tonumber(props.TextStrokeTransparency) or 1
            object.TextSize = math.max(8, (tonumber(props.Scale) or 1) * unit * 0.7)
            if props.Font ~= nil then pcall(function() object.Font = props.Font end) end
            if props.Align then
                object.TextXAlignment = props.Align == "Right" and Enum.TextXAlignment.Right or props.Align == "Center" and Enum.TextXAlignment.Center or Enum.TextXAlignment.Left
            end
            if props.VAlign then
                object.TextYAlignment = tostring(props.VAlign):lower() == "center" and Enum.TextYAlignment.Center or Enum.TextYAlignment.Top
            end
        elseif object:IsA("ImageLabel") then
            object.Image = tostring(props.Image or "")
            object.BackgroundColor3 = colorValue(props.Background, Color3.fromRGB(0, 0, 0))
            object.BackgroundTransparency = tonumber(props.BackgroundTransparency) or 0
            object.ImageTransparency = tonumber(props.ImageTransparency) or 0
        elseif object:IsA("Frame") then
            object.BackgroundColor3 = colorValue(props.Background, Color3.fromRGB(0, 0, 0))
            object.BackgroundTransparency = tonumber(props.BackgroundTransparency) or 0
        end
        if props.Corner ~= nil then
            local decoration = object:FindFirstChildOfClass("UICorner") or Instance.new("UICorner", object)
            decoration.CornerRadius = UDim.new(0, math.max(0, tonumber(props.Corner) or 0) * unit)
        end
        if props.StrokeThickness ~= nil then
            local stroke = object:FindFirstChildOfClass("UIStroke") or Instance.new("UIStroke", object)
            stroke.Thickness = tonumber(props.StrokeThickness) or 0
            stroke.Transparency = tonumber(props.StrokeTransparency) or 0
            stroke.Color = colorValue(props.StrokeColor, Color3.new(1, 1, 1))
        end
    end

    local function newElement(className, props)
        props = props or {}
        local object = Instance.new(className)
        object.BorderSizePixel = 0
        object.Parent = root
        local wrapper = { Instance = object, __props = {} }
        for key, value in pairs(props) do wrapper.__props[key] = value end
        function wrapper.Set(a, b)
            local updates = b == nil and a or b
            if type(updates) == "table" then
                for key, value in pairs(updates) do wrapper.__props[key] = value end
                apply(wrapper)
            end
            return wrapper
        end
        function wrapper:Get(key) return wrapper.__props[key] end
        function wrapper:Destroy()
            local index = table.find(canvas.__elements, wrapper)
            if index then table.remove(canvas.__elements, index) end
            object:Destroy()
        end
        setmetatable(wrapper, {
            __index = function(self, key)
                local ok, result = pcall(function() return object[key] end)
                if ok then return result end
                return self.__props[key]
            end,
            __newindex = function(self, key, value)
                if key == "Instance" or key == "__props" then rawset(self, key, value) return end
                self.__props[key] = value
                apply(self)
            end,
        })
        table.insert(canvas.__elements, wrapper)
        apply(wrapper)
        if className == "TextButton" then
            local connection = object.Activated:Connect(function()
                local callback = wrapper.__props.Callback or wrapper.__props.OnClick
                __SafeCall(callback)
            end)
            table.insert(destroyedConnections, connection)
        end
        return wrapper
    end

    function canvas:Frame(props) return newElement("Frame", props) end
    function canvas:Text(props) return newElement("TextLabel", props) end
    function canvas:Image(props) return newElement("ImageLabel", props) end
    function canvas:Button(props) return newElement("TextButton", props) end
    function canvas:Root() return root end
    function canvas:Attach(child, parent)
        child = rawOf(child)
        parent = rawOf(parent)
        if child and parent then child.Parent = parent end
        return child
    end
    function canvas:OnResize(callback)
        if type(callback) == "function" then
            table.insert(self.__resizeCallbacks, callback)
            task.defer(function()
                if not self.__destroyed then __SafeCall(callback, root.AbsoluteSize.X, root.AbsoluteSize.Y, unit) end
            end)
        end
        return self
    end
    function canvas:SetContentLines(lines)
        contentLines = math.max(1, tonumber(lines) or contentLines)
        root.Size = UDim2.fromOffset(root.AbsoluteSize.X > 0 and root.AbsoluteSize.X or 400, math.max(40, contentLines * unit))
        for _, callback in ipairs(self.__resizeCallbacks) do __SafeCall(callback, root.AbsoluteSize.X, root.AbsoluteSize.Y, unit) end
        return self
    end
    function canvas:Width() return root.AbsoluteSize.X end
    function canvas:Unit() return unit end
    function canvas:TextSize() return unit * 0.7 end
    function canvas:SetVisible(visible) gui.Enabled = visible ~= false return self end
    function canvas:Destroy()
        if self.__destroyed then return end
        self.__destroyed = true
        for _, connection in ipairs(destroyedConnections) do pcall(function() connection:Disconnect() end) end
        pcall(function() gui:Destroy() end)
    end

    if info.Search then
        local search = Instance.new("TextBox")
        search.Size = UDim2.fromOffset(150, 24)
        search.Position = UDim2.new(1, -158, 0, 6)
        search.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
        search.TextColor3 = Color3.new(1, 1, 1)
        search.Text = ""
        search.PlaceholderText = tostring(info.SearchPlaceholder or "搜索")
        search.TextSize = 12
        search.Parent = root
        local connection = search:GetPropertyChangedSignal("Text"):Connect(function() __SafeCall(info.OnSearch, search.Text) end)
        table.insert(destroyedConnections, connection)
    end
    local resizeConnection = root:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
        for _, wrapper in ipairs(canvas.__elements) do apply(wrapper) end
        for _, callback in ipairs(canvas.__resizeCallbacks) do __SafeCall(callback, root.AbsoluteSize.X, root.AbsoluteSize.Y, unit) end
    end)
    table.insert(destroyedConnections, resizeConnection)
    if type(info.Build) == "function" then task.defer(function() if not canvas.__destroyed then __SafeCall(info.Build, canvas) end end) end
    return canvas
end

local function __NewSection(rawSection)
    local section = { __raw = rawSection }

    function section:AddToggle(a, b)
        local key, info = __ControlInfo(a, b)
        local control = __NewControl(__Default(info) == true, info.Callback or info.Changed or info.callback)
        control.Type = "Toggle"
        local raw = rawSection:NewToggle({
            Title = __Text(info, "开关"),
            Default = __Default(info) == true,
            Callback = function(value)
                control:__Callback(value)
            end,
        })
        control:__Attach(raw, section)
        if key ~= nil then Library.Toggles[tostring(key)] = control end
        return control
    end

    section.Toggle = section.AddToggle

    function section:AddSlider(a, b)
        local key, info = __ControlInfo(a, b)
        if type(info.Value) == "table" then
            local copy = {}
            for k, v in pairs(info) do copy[k] = v end
            for k, v in pairs(info.Value) do copy[k] = v end
            info = copy
        end
        local minValue = tonumber(info.Min or info.min) or 0
        local maxValue = tonumber(info.Max or info.max) or 100
        local defaultValue = tonumber(__Default(info)) or minValue
        local control = __NewControl(defaultValue, info.Callback or info.Changed or info.callback)
        control.Type = "Slider"
        local raw = rawSection:NewSlider({
            Title = __Text(info, "滑块"),
            Min = minValue,
            Max = maxValue,
            Default = defaultValue,
            Callback = function(value)
                control:__Callback(value)
            end,
        })
        control:__Attach(raw, section)
        if key ~= nil then Library.Options[tostring(key)] = control end
        return control
    end

    section.Slider = section.AddSlider

    function section:AddDropdown(a, b)
        local key, info = __ControlInfo(a, b)
        local values = info.Values or info.Data or info.Options or info.options or {}
        local defaultValue = __Default(info)
        local callback = info.Callback or info.Changed or info.callback
        local multi = info.Multi == true or info.multi == true or info.multiSelect == true
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
        control.Type = "Dropdown"
        control.__onSetValue = function(value)
            if not multi then return end
            table.clear(selected)
            if type(value) == "table" then
                if #value > 0 then
                    for _, item in ipairs(value) do selected[item] = true end
                else
                    for item, enabled in pairs(value) do if enabled then selected[item] = true end end
                end
            end
        end
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
        control:__Attach(raw, section)
        if key ~= nil then Library.Options[tostring(key)] = control end
        return control
    end

    section.Dropdown = section.AddDropdown

    function section:AddInput(a, b)
        local key, info = __ControlInfo(a, b)
        local defaultValue = __Default(info)
        local control = __NewControl(defaultValue, info.Callback or info.Changed or info.callback)
        control.Type = "Input"
        control.Text = defaultValue == nil and "" or tostring(defaultValue)
        control.__section = section
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
        local callback = info.Callback or info.Func or info.OnClick or info.callback
        if type(a) == "table" and info.Title == nil and info.Text == nil and a[1] ~= nil then
            info.Title = a[1]
            info.Callback = info.Callback or a[2]
            callback = info.Callback
        end
        local control = __NewControl(nil, callback)
        control.Type = "Button"
        local raw = rawSection:NewButton({
            Title = __Text(info, "按钮"),
            Callback = callback,
        })
        control:__Attach(raw, section)
        return control
    end

    section.Button = section.AddButton

    function section:AddLabel(a, b)
        local info = (type(a) == "table" and a or {Text = a})
        if type(a) == "table" and a[1] ~= nil and not (a.Text or a.Title or a.Label or a.Name) then info = {Text=a[1], Desc=a[2]} end
        local text = __Text(info, "")
        if b ~= nil then text = text .. " " .. tostring(b) end
        local control = __NewControl(text)
        control.__isLabel = true
        local raw = rawSection:NewTitle(text)
        control:__Attach(raw, section)
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
        if info.NoUI then
            local hidden = __NewControl(__Default(info) or "RightShift", info.Callback or info.Changed)
            if key ~= nil then Library.Options[tostring(key)] = hidden end
            return hidden
        end
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
        control:__Attach(raw, section)
        if key ~= nil then Library.Options[tostring(key)] = control end
        return control
    end

    section.Keybind = section.AddKeyPicker

    function section:AddColorPicker(a, b)
        local key, info = __ControlInfo(a, b)
        local defaultValue = __Default(info) or Color3.new(1, 1, 1)
        local control = __NewControl(defaultValue, info.Callback or info.Changed or info.callback)
        control.Type = "ColorPicker"
        control.__section = section
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
    section.AddTextBox = section.AddInput
    section.AddTextbox = section.AddInput
    section.AddMultiDropdown = section.AddDropdown
    section.AddParagraph = section.Paragraph

    function section:CreateToggle(info) return self:AddToggle(info) end
    function section:CreateSlider(info) return self:AddSlider(info) end
    function section:CreateDropdown(info) return self:AddDropdown(info) end
    function section:CreateMultiDropdown(info)
        info = info or {}
        info.Multi = true
        return self:AddDropdown(info)
    end
    function section:CreateButton(info) return self:AddButton(info) end
    function section:CreateInput(info) return self:AddInput(info) end
    function section:CreateText(info)
        local control = self:AddLabel(info)
        function control:SetContentLines(lines)
            if type(lines) == "table" then return self:SetText(table.concat(lines, "\n")) end
            return self:SetText(lines)
        end
        return control
    end
    function section:CreateState(info) return __NewControl(__Default(info or {}), nil) end
    function section:CreateCanvas(info) return __NewFunctionalCanvas(info) end
    function section:CreateExclusiveGroup(info) return __NewControl(__Default(info or {}), nil) end
    function section:CreatePath(info) return self:CreateInput(info) end
    function section:CreateLabel(info) return self:CreateText(info) end
    function section:SetIcon() return self end
    function section:SetExpanded() return self end
    function section:SetNote() return self end
    function section:SetStateEnabled() return self end
    function section:SetDock() return self end
    function section:Resize() return self end

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
        local title = (type(info) == "table" and (info.DisplayName or info.Title or info.Name)) or info or "功能"
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
    function tab:AddSection(name) return self:Section(name) end
    function tab:CreateSection(info) return self:Section(info) end
    function tab:AddParagraph(info) return self:Paragraph(info) end
    function tab:AddTextBox(info) return self:Input(info) end
    function tab:AddTextbox(info) return self:Input(info) end
    function tab:AddToggle(info) return self:Toggle(info) end
    function tab:AddSlider(info) return self:Slider(info) end
    function tab:AddDropdown(info) return self:Dropdown(info) end
    function tab:AddButton(info) return self:Button(info) end
    function tab:Show() return self end
    function tab:Select() return self end
    function tab:Open() return self end
    function tab:Keybind(info) return self:__DefaultSection():Keybind(info) end
    function tab:ColorPicker(info) return self:__DefaultSection():ColorPicker(info) end

    return tab
end

local function __NewWindow()
    local window = {
        Window = __BaseWindow,
        UIElements = {},
        __closeCallbacks = {},
        __closed = false,
    }

    local function setVisible(visible)
        Library.Toggled = visible
        pcall(function()
            local gui = game:GetService("CoreGui"):FindFirstChild("RobloxGameGui")
            if gui then gui.Enabled = visible end
        end)
    end
    window.__SetVisible = setVisible

    function window:AddTab(name)
        return __NewTab(__BaseWindow:NewTab({
            Title = tostring(name or "页面"),
            Description = tostring(name or "功能"),
            Icon = "rbxassetid://7733960981",
        }))
    end

    function window:Tab(info)
        local title = (type(info) == "table" and (info.Title or info.Name or info.Label or info.DisplayName or info[1])) or info or "页面"
        return self:AddTab(title)
    end

    window.MakeTab = window.Tab
    window.CreateTab = window.Tab

    function window:GetDefaultTab()
        if not self.__defaultTab then self.__defaultTab = self:AddTab("主要功能") end
        return self.__defaultTab
    end

    function window:CreateState(info)
        return __NewControl(__Default(info or {}), nil)
    end

    function window:AddFolder()
        return { Label = { Text = "" }, SetOpen = function(self) return self end }
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
    function window:SetBackgroundImageTransparency() return self end
    function window:AddMinimizeButton() return self end
    function window:AddDiscordInvite() return self end
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

    function window:OnClose(callback)
        if type(callback) == "function" then table.insert(self.__closeCallbacks, callback) end
        return self
    end

    function window:__RunClose()
        if self.__closed then return end
        self.__closed = true
        for _, callback in ipairs(self.__closeCallbacks) do __SafeCall(callback) end
    end

    function window:Destroy()
        self:__RunClose()
        self.__SetVisible(false)
        return Library:Unload()
    end

    function window:Unload()
        return self:Destroy()
    end

    function window:Show() self.__SetVisible(true) return self end
    function window:Hide() self.__SetVisible(false) return self end
    function window:Open() self.__SetVisible(true) return self end
    function window:Close()
        self:__RunClose()
        self.__SetVisible(false)
        return self
    end
    function window:Toggle()
        self.__SetVisible(not Library.Toggled)
        return self
    end

    return window
end

function Library:CreateWindow(info)
    self.__window = self.__window or __NewWindow()
    if type(info) == "table" and info.DefaultTab and self.__window then
        self.__window.__defaultTab = self.__window.__defaultTab or self.__window:AddTab(info.DefaultTab)
    end
    return self.__window
end

function Library:MakeWindow(info)
    return self:CreateWindow(info)
end

function Library:Gradient(value)
    return value
end

function Library:AddLang() return self end
function Library:AddFolder() return {} end
function Library:SetHeld(value)
    if self.__window then self.__window.__SetVisible(not value) else self.Toggled = not value end
    return self
end
function Library:Toggle()
    if self.__window then self.__window:Toggle() else self.Toggled = not self.Toggled end
    return self
end
function Library:Finalize() return self end
function Library:UpdateColorsUsingRegistry() return self end

function Library:Notify(info, duration, directDuration)
    local title, description = "提示", ""
    if type(info) == "string" and duration ~= nil and type(duration) ~= "number" then
        title, description, duration = info, tostring(duration), directDuration
        info = nil
    end
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
    if self.__window then
        self.__window:__RunClose()
        self.__window.__SetVisible(false)
    end
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
function Library:SetBackgroundImageTransparency() end
Library.IsDek = false

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


local value = Library
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local localPlayer = Players.LocalPlayer
local camera = workspace.CurrentCamera
local value2 = value:CreateWindow({ Title = "TY hub｜兵工厂" })
local function makefindFirstChild(p0)
    if p0 == localPlayer then
        return true
    end
    if localPlayer.Team and p0.Team then
        return localPlayer.Team == p0.Team
    end
    if localPlayer.TeamColor and p0.TeamColor then
        return localPlayer.TeamColor == p0.TeamColor
    end

    return false
end

local function fn(p0, p1, p2)
    value:Notify({ Title = p0, Content = p1, Duration = 3, Icon = p2 or "info" })
end

local value3 = value2:Tab({ Title = "碰撞箱扩大", Icon = "box" })
local state = {}
local value4 = 6
local text3 = "FFA"
local list = { "UpperTorso", "Head", "HumanoidRootPart" }
local textLabel = Instance.new("TextLabel", localPlayer.PlayerGui)
textLabel.Size = UDim2.new(0, 200, 0, 50)
textLabel.TextSize = 16
textLabel.Position = UDim2.new(0.5, -150, 0, 0)
textLabel.Text = "警告：可能出现碰撞问题"
textLabel.TextColor3 = Color3.new(1, 0, 0)
textLabel.BackgroundTransparency = 1
textLabel.Visible = false

local function fn3(p0, p1)
    if not (state[p0]) then
        state[p0] = {}
    end
    if not not (state[p0][p1.Name]) then
        return
    end
    state[p0][p1.Name] = {
        CanCollide = p1.CanCollide,
        Transparency = p1.Transparency,
        Size = p1.Size,
    }
end

local function fn4(p0)
    if not (state[p0]) then
        return
    end
    for value, item in pairs(state[p0]) do
        local character = p0.Character and p0.Character:FindFirstChild(value)
        local value = character
        if character then
            value = character:IsA("BasePart")
        end
        if value then
            character.CanCollide = item.CanCollide
            character.Transparency = item.Transparency
            character.Size = item.Size
        end
    end
end

local function fn5(p0, p1)
    if not (p0.Character) then
        return nil
    end
    for _, item in ipairs(p0.Character:GetChildren()) do
        if item:IsA("BasePart") and item.Name:lower():match(p1:lower()) then
            return item
        end
    end
    return nil
end

local flag = false
local value5 = 21

local function fn6(p0)
    for _, item in ipairs(list) do
        local character = p0.Character and (p0.Character:FindFirstChild(item) or fn5(p0, item))
        local value = character
        if character then
            value = character:IsA("BasePart")
        end
        if value then
            fn3(p0, character)
            character.CanCollide = not flag
            character.Transparency = value4 / 10
            character.Size = (Vector3.new(value5, value5, value5))
        end
    end
end

local function fn7(p0)
    if text3 == "FFA" or text3 == "所有人" then
        return true
    end
    return not (makefindFirstChild(p0))
end

local function fn8(p0)
    return fn7(p0)
end

local function fn9()
    for _, item in ipairs(Players:GetPlayers()) do
        if item ~= localPlayer and item.Character and item.Character:FindFirstChild("HumanoidRootPart") then
            if fn8(item) then
                fn6(item)
                continue
            end
            fn4(item)
        end
    end
end

local flag2 = false

local function fn10(_)
    task.wait(0.1)
    if not flag2 then
        return
    end
    fn9()
end

local function fn11(p0)
    p0.CharacterAdded:Connect(fn10)

    local function fn()
        fn4(p0)
        state[p0] = nil
    end

    p0.CharacterRemoving:Connect(fn)
end

local function fn12()
    for state2, _ in pairs(state) do
        if not (state2.Parent) or not (state2.Character) or not (state2.Character:IsDescendantOf(game)) then
            fn4(state2)
            state[state2] = nil
        end
    end
end

Players.PlayerAdded:Connect(fn11)
for _, item in ipairs(Players:GetPlayers()) do
    fn11(item)
end
local state7 = { Title = "启动Hitbox自检循环" }

function state7.Callback()
    local function fn()
        while true do
            if flag2 then
                fn9()
                fn12()
            end
            task.wait(0.1)
        end
    end

    coroutine.wrap(fn)()
end

value3:Button(state7)
local state2 = { Title = "开启Hitbox", Value = false }

function state2.Callback(p0)
    flag2 = p0
    if not p0 then
        for _, item in ipairs(Players:GetPlayers()) do
            fn4(item)
        end
        state = {}
        return
    end
    fn9()
end

value3:Toggle(state2)
local state2 = { Title = "Hitbox大小", Value = { Min = 1, Max = 25, Default = 21 } }

function state2.Callback(p0)
    value5 = p0
    if not flag2 then
        return
    end
    fn9()
end

value3:Slider(state2)
local state2 = { Title = "Hitbox透明度", Value = { Min = 1, Max = 10, Default = 6 } }

function state2.Callback(p0)
    value4 = p0
    if not flag2 then
        return
    end
    fn9()
end

value3:Slider(state2)
local state2 = {
    Title = "队伍检测",
    Values = { "FFA", "队伍模式", "所有人" },
    Value = "FFA",
}

function state2.Callback(p0)
    text3 = p0
    if not flag2 then
        return
    end
    fn9()
end

value3:Dropdown(state2)
local state2 = { Title = "无碰撞模式", Value = false }

function state2.Callback(p0)
    flag = p0
    textLabel.Visible = p0

    local function fn()
        while flag do
            if flag2 then
                fn9()
            end
            task.wait(0.01)
        end
        if not flag2 then
            return
        end
        fn9()
    end

    coroutine.wrap(fn)()
end

value3:Toggle(state2)
local value3 = value2:Tab({ Title = "枪械设置", Icon = "crosshair" })

local function fn2()
    return (game:GetService("ReplicatedStorage")):FindFirstChild("Weapons")
end

local function fn11()
    local wkspc = (game:GetService("ReplicatedStorage")):FindFirstChild("wkspc")
    if wkspc then
        return wkspc:FindFirstChild("CurrentCurse")
    end
    return nil
end

local state2 = { Title = "无限弹药", Value = false }

local function fn13(p0)
    local value = fn11()
    if value then
        value.Value = p0 and "Infinite Ammo" or ""
        return
    end
    fn("提示", "当前游戏没有找到弹药配置", "alert-circle")
end

state2.Callback = fn13
value3:Toggle(state2)
value3:Toggle({
    Title = "快速换弹",
    Value = false,
    Callback = function(p0)
        local value = fn2()
        if not value then
            fn("提示", "当前游戏没有找到武器库", "alert-circle")
            return
        end
        local getChildren = value.GetChildren
        for _, item in pairs(getChildren(value)) do
            local itemRef = item
            pcall(function()
                local reloadTime
                if itemRef:FindFirstChild("ReloadTime") then
                    if p0 then
                        if not (getChildren.ReloadTime[itemRef]) then
                            getChildren.ReloadTime[itemRef] = itemRef.ReloadTime.Value
                        end
                        itemRef.ReloadTime.Value = 0.01
                    else
                        reloadTime = getChildren.ReloadTime
                        itemRef.ReloadTime.Value = reloadTime[itemRef] or 0.8
                    end
                end
                reloadTime = itemRef
                if not (reloadTime:FindFirstChild("EReloadTime")) then
                    return
                end
                if p0 then
                    if not (getChildren.EReloadTime[itemRef]) then
                        getChildren.EReloadTime[itemRef] = itemRef.EReloadTime.Value
                    end
                    itemRef.EReloadTime.Value = 0.01
                    return
                end
                reloadTime = getChildren.EReloadTime
                itemRef.EReloadTime.Value = reloadTime[itemRef] or 0.8
            end)
        end
    end,
})
value3:Toggle({
    Title = "快速射击",
    Value = false,
    Callback = function(p0)
        local value = fn2()
        if not value then
            fn("提示", "当前游戏没有找到武器库", "alert-circle")
            return
        end
        local getDescendants = value.GetDescendants
        for _, item in pairs(getDescendants(value)) do
            local itemRef = item
            pcall(function()
                if not (itemRef.Name == "FireRate" or itemRef.Name == "BFireRate") then
                    return
                end
                if p0 then
                    if not (getDescendants.FireRate[itemRef]) then
                        getDescendants.FireRate[itemRef] = itemRef.Value
                    end
                    itemRef.Value = 0.02
                    return
                end
                itemRef.Value = getDescendants.FireRate[itemRef] or 0.8
            end)
        end
    end,
})
value3:Toggle(
    {
        Title = "自动连发",
        Value = false,
        Callback = function(p0)
            local value = fn2()
            if not value then
                fn("提示", "当前游戏没有找到武器库", "alert-circle")
                return
            end
            local getDescendants2 = value.GetDescendants
            for _, item in pairs(getDescendants2(value)) do
                local itemRef = item
                pcall(
                    function()
                        if not (itemRef.Name == "Auto" or itemRef.Name == "AutoFire"
                            or itemRef.Name == "Automatic" or itemRef.Name == "AutoShoot"
                            or itemRef.Name == "AutoGun") then
                            return
                        end
                        if p0 then
                            if not (getDescendants2.Auto[itemRef]) then
                                getDescendants2.Auto[itemRef] = itemRef.Value
                            end
                            itemRef.Value = true
                            return
                        end
                        itemRef.Value = getDescendants2.Auto[itemRef] or false
                    end
                )
            end
        end,
    }
)
value3:Toggle(
    {
        Title = "无扩散",
        Value = false,
        Callback = function(p0)
            local value = fn2()
            if not value then
                fn("提示", "当前游戏没有找到武器库", "alert-circle")
                return
            end
            local getDescendants3 = value.GetDescendants
            for _, item in pairs(getDescendants3(value)) do
                local itemRef = item
                pcall(function()
                    if not (itemRef.Name == "MaxSpread" or itemRef.Name == "Spread"
                        or itemRef.Name == "SpreadControl") then
                        return
                    end
                    if p0 then
                        if not (getDescendants3.Spread[itemRef]) then
                            getDescendants3.Spread[itemRef] = itemRef.Value
                        end
                        itemRef.Value = 0
                        return
                    end
                    itemRef.Value = getDescendants3.Spread[itemRef] or 1
                end)
            end
        end,
    }
)
value3:Toggle({
    Title = "无后坐力",
    Value = false,
    Callback = function(p0)
        local value = fn2()
        if not value then
            fn("提示", "当前游戏没有找到武器库", "alert-circle")
            return
        end
        local getDescendants4 = value.GetDescendants
        for _, item in pairs(getDescendants4(value)) do
            local itemRef = item
            pcall(function()
                if not (itemRef.Name == "RecoilControl" or itemRef.Name == "Recoil") then
                    return
                end
                if p0 then
                    if not (getDescendants4.Recoil[itemRef]) then
                        getDescendants4.Recoil[itemRef] = itemRef.Value
                    end
                    itemRef.Value = 0
                    return
                end
                itemRef.Value = getDescendants4.Recoil[itemRef] or 1
            end)
        end
    end,
})
local value3 = value2:Tab({ Title = "玩家", Icon = "person-standing" })
local flag4 = false

local function fn13()
    if not flag4 then
        return
    end
    local character2 = localPlayer.Character
    if not character2 then
        return
    end
    local humanoidRootPart = character2:FindFirstChild("HumanoidRootPart")
    if not humanoidRootPart then
        return
    end
    humanoidRootPart.CFrame = humanoidRootPart.CFrame + Vector3.new(0, 5, 0)
end

UserInputService.JumpRequest:Connect(fn13)
local value6 = 1
local flag3 = false

local function fn13()
    while true do
        task.wait(0.01)
        if flag3 then
            local character3 = localPlayer.Character
            local value = character3
            if character3 then
                value = character3:FindFirstChildOfClass("Humanoid")
            end
            local value2 = character3
            if character3 then
                value2 = character3:FindFirstChild("HumanoidRootPart")
            end
            if value and value2 then
                if value.MoveDirection.Magnitude > 0 then
                    value2.CFrame = value2.CFrame + value.MoveDirection.Unit * (0.1 * value6)
                end
            end
        end
    end
end

task.spawn(fn13)
local state2 = { Title = "无限跳跃", Desc = "可能失效", Value = false }

function state2.Callback(p0)
    flag4 = p0
end

value3:Toggle(state2)
local state2 = { Title = "开启瞬移移动", Desc = "", Value = false }

function state2.Callback(p0)
    flag3 = p0
end

value3:Toggle(state2)
local state2 = {
    Title = "瞬移速度",
    Desc = "",
    Step = 1,
    Value = { Min = 1, Max = 50, Default = 1 },
}

-- https://lua-x.online
function state2.Callback(p0)
    value6 = p0
end

value3:Slider(state2)
local list2 = { "Velocity", "Vector", "CFrame" }
local value7 = list2[1]
local state2 = { Title = "自定义跳跃高度", Value = false }
local flag5 = false

local function fn13(p0)
    flag5 = p0
end

state2.Callback = fn13
value3:Toggle(state2)
state2 = { Title = "跳跃方法", Values = list2, Value = value7 }

fn13 = function(p0)
    value7 = p0
end

state2.Callback = fn13
value3:Dropdown(state2)
fn13 = { Title = "跳跃高度", Value = { Min = 30, Max = 500, Default = 30 } }
local value8 = 30

function fn13.Callback(p0)
    value8 = p0
end

value3:Slider(fn13)
local humanoid = localPlayer.Character and localPlayer.Character:FindFirstChildOfClass("Humanoid")
if humanoid then
    humanoid.UseJumpPower = true
    local jumping = humanoid.Jumping
    fn13 = jumping
    state2 = jumping.Connect

    local function onJumping(p0)
        if not (flag5 and p0) then
            return
        end
        local humanoidRootPart2 = localPlayer.Character:FindFirstChild("HumanoidRootPart")
        if not humanoidRootPart2 then
            return
        end
        if value7 == "Velocity" then
            humanoidRootPart2.Velocity =
                Vector3.new(humanoidRootPart2.Velocity.X, value8, humanoidRootPart2.Velocity.Z)
            return
        end
        if value7 == "Vector" then
            humanoidRootPart2.Velocity = Vector3.new(0, value8, 0)
            return
        end
        if value7 ~= "CFrame" then
            return
        end
        localPlayer.Character:SetPrimaryPartCFrame(
            localPlayer.Character:GetPrimaryPartCFrame() + Vector3.new(0, value8, 0)
        )
    end

    state2(fn13, onJumping)
end
fn13 = value2
state2 = value2.Tab(fn13, { Title = "透视", Icon = "eye" })
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "XunESPGui"
screenGui.Parent = coreGui
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.DisplayOrder = 1

local list2 = {}
local state3 = { Title = "开启玩家透视", Value = false }
fn13 = false

local function fn14(p0)
    fn13 = p0
    if not not p0 then
        return
    end
    for _, item in pairs(list2) do
        if item.frame then
            item.frame:Destroy()
        end
        if item.text then
            item.text:Destroy()
        end
        if (item.highlight) then
            item.highlight:Destroy()
        end
    end
    table.clear(list2)
end

state3.Callback = fn14
state2:Toggle(state3)
local flag8 = false
task.spawn(function()
    while true do
        task.wait(16)
        if fn13 then
            flag8 = true
            for _, item in pairs(list2) do
                if item.frame then
                    item.frame:Destroy()
                end
                if item.text then
                    item.text:Destroy()
                end
                if (item.highlight) then
                    item.highlight:Destroy()
                end
            end
            table.clear(list2)
            task.wait(0.1)
            flag8 = false
        end
    end
end)
RunService.RenderStepped:Connect(
    function()
        if not fn13 or flag8 then
            return
        end
        for _, item in ipairs(Players:GetPlayers()) do
            if not (item == localPlayer) then
                local character4 = item.Character
                local value = character4
                if character4 then
                    value = character4:FindFirstChild("HumanoidRootPart")
                end
                if not value then
                    if not (list2[item]) then
                        continue
                    end
                    if list2[item].frame then
                        list2[item].frame.Visible = false
                    end
                    if list2[item].text then
                        list2[item].text.Visible = false
                    end
                    if not (list2[item].highlight) then
                        continue
                    end
                    list2[item].highlight.Enabled = false
                    continue
                end
                local uIStroke
                local textLabel
                local highlight
                if not (list2[item]) then
                    local frame = Instance.new("Frame")
                    frame.BackgroundTransparency = 1
                    frame.BorderSizePixel = 0
                    frame.Parent = screenGui
    
                    uIStroke = Instance.new("UIStroke")
                    uIStroke.Parent = frame
    
                    textLabel = Instance.new("TextLabel")
                    textLabel.BackgroundTransparency = 1
                    textLabel.Font = Enum.Font.GothamBold
                    textLabel.TextSize = 12
                    textLabel.Size = UDim2.fromOffset(150, 20)
                    textLabel.Parent = screenGui
                    textLabel.TextStrokeTransparency = 0
    
                    highlight = Instance.new("Highlight")
                    highlight.Parent = character4
                    highlight.Enabled = false
                    list2[item] = {
                        frame = frame,
                        text = textLabel,
                        stroke = uIStroke,
                        highlight = highlight,
                    }
                end
                uIStroke = character4
                uIStroke, textLabel = camera:WorldToViewportPoint((uIStroke:FindFirstChild("Head")
                    or value).Position + Vector3.new(0, 1, 0))
                highlight = camera:WorldToViewportPoint(value.Position - Vector3.new(0, 2.5, 0))
                local value = list2[item]
                if textLabel and uIStroke.Z > 0 then
                    local value2 = math.abs(uIStroke.Y - highlight.Y)
                    local value3 = value2 / 1.5
                    local value4 = not (makefindFirstChild(item))
                    local value5 = value4 and Color3.fromRGB(255, 0, 0) or Color3.fromRGB(0, 255, 0)
                    value.frame.Visible = true
                    local frame = value.frame
                    frame.Position = UDim2.fromOffset(uIStroke.X - value3 / 2, uIStroke.Y)
                    frame = value.frame
                    frame.Size = UDim2.fromOffset(value3, value2)
    
                    value.stroke.Color = value5
                    value.stroke.Thickness = 1.5
    
                    value.text.Visible = true
                    frame = value.text
                    frame.Position = UDim2.fromOffset(uIStroke.X - 75, uIStroke.Y - 22)
    
                    value.text.Text = item.Team and item.Team.Name or item.TeamColor and item.TeamColor.Name
                        or "未知"
                    value.text.TextColor3 = value5
    
                    if value4 then
                        value.highlight.Enabled = true
                        frame = value.highlight
                        frame.FillColor = Color3.fromRGB(255, 0, 0)
    
                        value.highlight.FillTransparency = 0.5
                        frame = value.highlight
                        frame.OutlineColor = (Color3.fromRGB(255, 0, 0))
    
                        value.highlight.OutlineTransparency = 0
    
                        continue
                    end
                    value.highlight.Enabled = false
    
                    continue
                end
                value.frame.Visible = false
    
                value.text.Visible = false
    
                value.highlight.Enabled = false
            end
        end
    end
)
local value3 = value2:Tab({ Title = "自瞄", Icon = "crosshair" })
local flag9 = true
local frame2 = Instance.new("Frame")
frame2.Name = "FOVCircle"
frame2.Parent = screenGui
frame2.BackgroundTransparency = 1
frame2.Visible = false

local uIStroke = Instance.new("UIStroke")
uIStroke.Color = Color3.fromRGB(255, 255, 255)
uIStroke.Thickness = 1
uIStroke.Transparency = 0.5
uIStroke.Parent = frame2

local uICorner = Instance.new("UICorner")
uICorner.CornerRadius = UDim.new(1, 0)
uICorner.Parent = frame2

local state2 = { Title = "开启自瞄", Desc = "", Value = false }
local flag6 = false

function state2.Callback(p0)
    flag6 = p0
    frame2.Visible = p0
end

value3:Toggle(state2)
local state2 = { Title = "掩体检测", Desc = "", Value = true }

function state2.Callback(p0)
    flag9 = p0
end

value3:Toggle(state2)
local state2 = {
    Title = "自瞄模式",
    Values = { "硬锁 ", "软锁 " },
    Value = "硬锁 ",
}
local text4 = "硬锁"

function state2.Callback(p0)
    text4 = p0
end

value3:Dropdown(state2)
local state2 = {
    Title = "自瞄范围",
    Step = 1,
    Value = { Min = 10, Max = 500, Default = 150 },
}
local value9 = 150

function state2.Callback(p0)
    value9 = p0
    frame2.Size = UDim2.fromOffset(p0 * 2, p0 * 2)
    frame2.Position = UDim2.new(0.5, -p0, 0.5, -p0)
end

value3:Slider(state2)
local state2 = {
    Title = "软锁平滑度",
    Step = 0.01,
    Value = { Min = 0.01, Max = 1, Default = 0.2 },
}
local value10 = 0.2

function state2.Callback(p0)
    value10 = p0
end

value3:Slider(state2)
local value3 = RaycastParams.new()
value3.FilterType = Enum.RaycastFilterType.Exclude
value3.IgnoreWater = true

local value11 = 0

local function fn14()
    if not flag6 or flag8 then
        return
    end
    local value = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
    frame2.Position = UDim2.fromOffset(value.X - value9, value.Y - value9)
    frame2.Size = UDim2.fromOffset(value9 * 2, value9 * 2)

    local value2 = os.clock()
    if value2 - value11 < 0.016 then
        return
    end
    value11 = value2
    local huge = math.huge
    local value2 = nil
    for _, item in ipairs(Players:GetPlayers()) do
        if not (item == localPlayer or makefindFirstChild(item)) then
            local character = item.Character
            local value4 = character
            if character then
                value4 = character:FindFirstChild("Head")
            end
            local value5 = character
            if character then
                value5 = character:FindFirstChildOfClass("Humanoid")
            end
            if value4 and value5 and value5.Health > 0 then
                local value5
                local value6
                value5, value6 = camera:WorldToViewportPoint(value4.Position)
                if value6 and value5.Z > 0 then
                    local magnitude = (Vector2.new(value5.X, value5.Y) - value).Magnitude
                    if magnitude <= value9 and magnitude < huge then
                        local flag = true
                        if flag9 then
                            value3.FilterDescendantsInstances = { localPlayer.Character, character }
                            local position = camera.CFrame.Position
                            if workspace:Raycast(position, value4.Position - position, value3) then
                                flag = false
                            end
                        end
                        if flag then
                            huge = magnitude
                            value2 = value4
                        end
                    end
                end
            end
        end
    end
    if not value2 then
        return
    end
    local cframe = CFrame.new(camera.CFrame.Position, value2.Position)
    if text4 == "硬锁" then
        camera.CFrame = cframe
        return
    end
    camera.CFrame = camera.CFrame:Lerp(cframe, value10)
end

RunService.RenderStepped:Connect(fn14)
local value12 = value2:Tab({ Title = "美化", Icon = "hand-platter" })
local color = Color3.fromRGB(50, 50, 50)
local flag10 = false
local state2 = {
    Title = "手臂材质",
    Values = { "Plastic", "ForceField", "Wood", "Grass" },
    Value = "Plastic",
}
local text = "Plastic"

function state2.Callback(p0)
    text = p0
end

value12:Dropdown(state2)
local state2 = { Title = "手臂颜色", Default = Color3.fromRGB(50, 50, 50) }

function state2.Callback(p0)
    color = p0
end

value12:Colorpicker(state2)
local state2 = { Title = "开启手臂美化", Value = false }

function state2.Callback(p0)
    flag10 = p0
    if not flag10 then
        return
    end

    local function fn()
        while true do
            if not flag10 then
                return
            end
            task.wait(0.01)
            local arms = workspace.Camera:FindFirstChild("Arms")
            if arms then
                for _, item in pairs(arms:GetDescendants()) do
                    if item.Name == "Right Arm" or item.Name == "Left Arm" then
                        if not (item:IsA("BasePart")) then
                            continue
                        end
                        item.Material = Enum.Material[text]
                        item.Color = color

                        continue
                    end
                    if item:IsA("SpecialMesh") then
                        if item.TextureId ~= "" then
                            continue
                        end
                        item.TextureId = "rbxassetid://0"
                        item.VertexColor = Vector3.new(color.R, color.G, color.B)

                        continue
                    end
                    if item.Name == "L" or item.Name == "R" then
                        item:Destroy()
                    end
                end
            end
        end
    end

    task.spawn(fn)
end

value12:Toggle(state2)
local color2 = Color3.fromRGB(50, 50, 50)
local state2 = {
    Title = "枪械材质",
    Values = { "Plastic", "ForceField", "Wood", "Grass" },
    Value = "Plastic",
}
local text2 = "Plastic"

function state2.Callback(p0)
    text2 = p0
end

value12:Dropdown(state2)
local state2 = { Title = "枪械颜色", Default = Color3.fromRGB(50, 50, 50) }

function state2.Callback(p0)
    color2 = p0
end

value12:Colorpicker(state2)
local state2 = { Title = "开启枪械美化", Value = false }
local flag7 = false

function state2.Callback(p0)
    flag7 = p0
    if not flag7 then
        return
    end

    local function fn()
        while true do
            if not flag7 then
                return
            end
            task.wait(0.01)
            local arms2 = workspace.Camera:FindFirstChild("Arms")
            if arms2 then
                for _, item in pairs(arms2:GetDescendants()) do
                    if (item:IsA("MeshPart")) then
                        item.Material = Enum.Material[text2]
                        item.Color = color2
                    end
                end
            end
        end
    end

    task.spawn(fn)
end

value12:Toggle(state2)
local value2 = value2:Tab({ Title = "聊天标签", Icon = "message-circle" })

local function fn14(p0, p1)
    local localPlayer2 = game.Players.LocalPlayer
    if localPlayer2:FindFirstChild(p0) then
        (localPlayer2[p0]):Destroy()
    end
    if not p1 then
        return
    end
    Instance.new("IntValue", localPlayer2).Name = p0
end

local state2 = { Title = "IsChad", Value = false }

function state2.Callback(p0)
    fn14("IsChad", p0)
end

value2:Toggle(state2)
local state2 = { Title = "VIP", Value = false }

function state2.Callback(p0)
    fn14("VIP", p0)
end

value2:Toggle(state2)
local state2 = { Title = "OldVIP", Value = false }

function state2.Callback(p0)
    fn14("OldVIP", p0)
end

value2:Toggle(state2)
local state2 = { Title = "Romin", Value = false }

function state2.Callback(p0)
    fn14("Romin", p0)
end

value2:Toggle(state2)
local state2 = { Title = "管理员", Value = false }

function state2.Callback(p0)
    fn14("IsAdmin", p0)
end

value2:Toggle(state2)


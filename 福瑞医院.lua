-- 福瑞医院：独立服务器缝合版
local NothingLibrary = loadstring(game:HttpGetAsync('https://raw.githubusercontent.com/quanwei-sy/qianweicangku/refs/heads/main/%E6%BA%90%E7%A0%81.lua'))()

local __BaseWindow = NothingLibrary.new({
    Title = "TY hub｜福瑞医院",
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


-- 动物医院 脚本 v3.2.0
-- WindUI蓝白版 | 防扣理智 | 自动前台 | 动物透视 | 传送 | 透视玩家 | 秒互动

if not WindUI then return end

WindUI:AddTheme({
    Name = "冰白",
    Accent = "#80C0FF",
    Outline = "#6090C0",
    Text = "#FFFFFF",
    Placeholder = "#D0E0FF",
})

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local LocalPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local Settings = {
    NoSanity = false, AutoReception = false,
    ESP_Enabled = false, AnimalESP_Enabled = false, AnimalESP_ShowDistance = false,
    AnimalESP_OnlyAbnormal = false,
    InstantInteract = false,
    WalkSpeed = 16,
}

local stopAll = false
local highlights = {}; local nameTags = {}
local animalHighlights = {}; local animalNameTags = {}
local noSanityHooks = {}
local originalDurations = {}
local descendantAddedConn = nil
local lastAnimalScan = 0
local cachedAnimals = {}

local EXCLUDED_NAMES = {"Dummy", "Nurse"}

local ABNORMAL_KEYWORDS = {
    "skinwalker", "skin walker", "monster", "entity", "creature", "fake", "impostor", "imposter",
    "mimic", "horror", "beast", "demon", "cryptid", "anomaly", "nightmare", "shapeshifter",
    "possessed", "haunted", "evil", "specter", "wraith", "phantom", "shadow", "abomination",
    "mutant", "stalker", "flesh", "gore", "blood", "scream", "unknown", "thing", "being",
    "presence", "intruder", "invader", "predator", "nonhuman", "paranormal", "supernatural",
    "slender", "sirenhead", "scp", "alternate", "doppelganger", "changeling",
    "异常", "诡异", "恐怖", "怪物", "伪人", "异常体", "诡异体", "恐怖体",
    "infected", "cursed", "twisted", "corrupted", "dark", "evil", "hell", "demon",
    "ghost", "spirit", "phantom", "wraith", "zombie", "undead", "mutated", "deformed",
}

local function isAbnormal(name)
    local lowerName = name:lower()
    for _, keyword in pairs(ABNORMAL_KEYWORDS) do
        if lowerName:find(keyword) then return true end
    end
    return false
end

local function shouldExcludeAnimal(name)
    for _, excluded in pairs(EXCLUDED_NAMES) do
        if name:lower() == excluded:lower() then return true end
    end
    return false
end

local function getPos()
    local c = LocalPlayer.Character
    if c and c:FindFirstChild("HumanoidRootPart") then return c.HumanoidRootPart.Position end
    return nil
end

local function tp(pos)
    local c = LocalPlayer.Character
    if c and c:FindFirstChild("HumanoidRootPart") then c.HumanoidRootPart.CFrame = CFrame.new(pos) end
end

local function setupNoSanity()
    if noSanityHooks.mtHook then return end
    local Event = ReplicatedStorage.Util.Net["RE/PlayerLostSanity"]
    noSanityHooks.mtHook = hookmetamethod(game, "__namecall", function(...)
        local self = ...; local method = getnamecallmethod()
        if self == Event and method == "FireServer" and Settings.NoSanity then return nil end
        return noSanityHooks.mtHook(...)
    end)
    noSanityHooks.oldFireServer = hookfunction(Event.FireServer, function(...)
        local self = ...
        if self == Event and Settings.NoSanity then return nil end
        return noSanityHooks.oldFireServer(self, ...)
    end)
end

-- 秒互动核心
local function modifyPrompt(prompt, enable)
    if enable then
        if not originalDurations[prompt] then
            originalDurations[prompt] = prompt.HoldDuration
        end
        prompt.HoldDuration = 0
    else
        local original = originalDurations[prompt]
        if original and prompt.Parent then
            prompt.HoldDuration = original
        end
    end
end

local function processAllPrompts(enable)
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("ProximityPrompt") then
            modifyPrompt(obj, enable)
        end
    end
end

local function onDescendantAdded(descendant)
    if descendant:IsA("ProximityPrompt") then
        modifyPrompt(descendant, true)
    end
end

local function enableInstant()
    processAllPrompts(true)
    descendantAddedConn = Workspace.DescendantAdded:Connect(onDescendantAdded)
end

local function disableInstant()
    if descendantAddedConn then
        descendantAddedConn:Disconnect()
        descendantAddedConn = nil
    end
    for prompt, original in pairs(originalDurations) do
        if prompt.Parent then
            prompt.HoldDuration = original
        end
    end
    originalDurations = {}
end

local function hasAnimalNear(pos)
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("Model") and obj:FindFirstChild("Humanoid") and obj:FindFirstChild("Head") then
            local root = obj:FindFirstChild("HumanoidRootPart") or obj.PrimaryPart
            if root and (pos - root.Position).Magnitude <= 20 then
                local isPlayer = false
                for _, plr in pairs(Players:GetPlayers()) do
                    if plr.Character == obj then isPlayer = true; break end
                end
                if not isPlayer then return true end
            end
        end
    end
    return false
end

-- 自动前台
task.spawn(function()
    while true do
        if Settings.AutoReception and not stopAll then
            local pos1 = Vector3.new(-104, 3.4, 1.3); local pos2 = Vector3.new(-107.5, 3.4, 1.3)
            local pos3 = Vector3.new(-99, 3.4, 0.9); local pos4 = Vector3.new(-99, 3.4, 1.6)
            local waitPos = Vector3.new(-114, 3.4, -1.3)
            if hasAnimalNear(pos1) then
                tp(pos1); task.wait(2.5); VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, nil); task.wait(2); VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, nil)
                if not Settings.AutoReception or stopAll then continue end
                tp(pos2); task.wait(2.5); VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, nil); task.wait(2); VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, nil)
                if not Settings.AutoReception or stopAll then continue end
                tp(pos3); task.wait(2.5); VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, nil); task.wait(2); VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, nil)
                if not Settings.AutoReception or stopAll then continue end
                tp(pos4); task.wait(7.5); VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, nil); task.wait(3); VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, nil)
            else
                tp(waitPos); task.wait(2.5); VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, nil); task.wait(2); VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, nil); task.wait(10)
            end
        else task.wait(1) end
    end
end)

-- 优化动物ESP - 缓存扫描
local function getAnimalModels()
    local animals = {}
    local playerChars = {}
    for _, plr in pairs(Players:GetPlayers()) do
        if plr.Character then playerChars[plr.Character] = true end
    end
    
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("Model") and obj:FindFirstChild("Humanoid") and obj:FindFirstChild("Head") then
            if not playerChars[obj] and not shouldExcludeAnimal(obj.Name) then
                -- 如果开启了只显示异常体，则过滤
                if Settings.AnimalESP_OnlyAbnormal then
                    if isAbnormal(obj.Name) then
                        table.insert(animals, obj)
                    end
                else
                    table.insert(animals, obj)
                end
            end
        end
    end
    return animals
end

local function clearAnimalESP()
    for _, h in pairs(animalHighlights) do pcall(function() h:Destroy() end) end
    for _, t in pairs(animalNameTags) do pcall(function() t:Destroy() end) end
    table.clear(animalHighlights); table.clear(animalNameTags)
    table.clear(cachedAnimals)
end

RunService.Heartbeat:Connect(function()
    if not Settings.AnimalESP_Enabled then 
        if next(animalHighlights) or next(animalNameTags) then
            clearAnimalESP()
        end
        return 
    end
    
    -- 每2秒才扫描一次动物列表，减少性能消耗
    local currentTime = tick()
    if currentTime - lastAnimalScan > 2 then
        cachedAnimals = getAnimalModels()
        lastAnimalScan = currentTime
        
        -- 清理不存在的动物
        local activeAnimals = {}
        for _, animal in pairs(cachedAnimals) do activeAnimals[animal] = true end
        for animal, _ in pairs(animalHighlights) do
            if not activeAnimals[animal] then
                if animalHighlights[animal] then pcall(function() animalHighlights[animal]:Destroy() end); animalHighlights[animal] = nil end
                if animalNameTags[animal] then pcall(function() animalNameTags[animal]:Destroy() end); animalNameTags[animal] = nil end
            end
        end
    end
    
    -- 使用缓存的动物列表
    for _, animal in pairs(cachedAnimals) do
        if animal and animal.Parent then
            local head = animal:FindFirstChild("Head")
            local root = animal:FindFirstChild("HumanoidRootPart") or animal.PrimaryPart
            if head then
                local isAbnormalAnimal = isAbnormal(animal.Name)
                local dist = ""
                if Settings.AnimalESP_ShowDistance and root then
                    local d = 0; local c = LocalPlayer.Character
                    if c and c:FindFirstChild("HumanoidRootPart") then d = (root.Position - c.HumanoidRootPart.Position).Magnitude end
                    dist = "\n[" .. math.floor(d) .. "m]"
                end
                local displayName = (isAbnormalAnimal and "[异常] " or "") .. animal.Name .. dist
                local nameColor = isAbnormalAnimal and Color3.fromRGB(255, 50, 50) or Color3.fromRGB(100, 255, 100)
                local fillColor = isAbnormalAnimal and Color3.fromRGB(255, 50, 50) or Color3.fromRGB(100, 255, 100)
                
                if not animalHighlights[animal] then
                    local h = Instance.new("Highlight"); h.FillColor = fillColor; h.FillTransparency = 0.5
                    h.OutlineColor = fillColor; h.OutlineTransparency = 0.3; h.Parent = animal; animalHighlights[animal] = h
                else 
                    animalHighlights[animal].FillColor = fillColor 
                end
                
                if not animalNameTags[animal] then
                    local bg = Instance.new("BillboardGui"); bg.Size = UDim2.new(0, 200, 0, 40)
                    bg.AlwaysOnTop = true; bg.MaxDistance = math.huge; bg.Parent = head
                    local l = Instance.new("TextLabel"); l.Size = UDim2.new(1, 0, 1, 0); l.BackgroundTransparency = 1
                    l.Text = displayName; l.TextColor3 = nameColor; l.Font = Enum.Font.GothamBold; l.TextSize = 14
                    l.TextStrokeTransparency = 0.5; l.TextStrokeColor3 = Color3.fromRGB(0, 0, 0); l.Parent = bg
                    animalNameTags[animal] = bg
                else
                    local label = animalNameTags[animal]:FindFirstChild("TextLabel")
                    if label then 
                        label.Text = displayName
                        label.TextColor3 = nameColor
                    end
                end
            end
        end
    end
end)

-- 玩家ESP
local function clearESP()
    for _, h in pairs(highlights) do pcall(function() h:Destroy() end) end
    for _, t in pairs(nameTags) do pcall(function() t:Destroy() end) end
    table.clear(highlights); table.clear(nameTags)
end

RunService.Heartbeat:Connect(function()
    if not Settings.ESP_Enabled then clearESP(); return end
    for _, plr in pairs(Players:GetPlayers()) do
        if plr == LocalPlayer then continue end
        local char = plr.Character
        if not char or not char:FindFirstChild("Head") then continue end
        local isSkin = isAbnormal(plr.Name)
        local displayName = (isSkin and "[异常] " or "") .. plr.Name
        local fillColor = isSkin and Color3.fromRGB(255, 50, 50) or Color3.fromRGB(255, 100, 100)
        local nameColor = isSkin and Color3.fromRGB(255, 50, 50) or Color3.fromRGB(255, 255, 255)
        if not highlights[plr] then
            local h = Instance.new("Highlight"); h.FillColor = fillColor; h.FillTransparency = 0.5
            h.OutlineColor = fillColor; h.OutlineTransparency = 0.3; h.Parent = char; highlights[plr] = h
        else highlights[plr].FillColor = fillColor end
        if highlights[plr] and highlights[plr].Parent ~= char then highlights[plr].Parent = char end
        if not nameTags[plr] then
            local bg = Instance.new("BillboardGui"); bg.Size = UDim2.new(0, 200, 0, 25)
            bg.AlwaysOnTop = true; bg.MaxDistance = math.huge; bg.Parent = char.Head
            local l = Instance.new("TextLabel"); l.Size = UDim2.new(1, 0, 1, 0); l.BackgroundTransparency = 1
            l.Text = displayName; l.TextColor3 = nameColor; l.Font = Enum.Font.GothamBold; l.TextSize = 14
            l.TextStrokeTransparency = 0.5; l.TextStrokeColor3 = Color3.fromRGB(0, 0, 0); l.Parent = bg
            nameTags[plr] = bg
        else
            local label = nameTags[plr]:FindFirstChild("TextLabel")
            if label then label.Text = displayName; label.TextColor3 = nameColor end
        end
        if nameTags[plr] and nameTags[plr].Parent ~= char.Head then nameTags[plr].Parent = char.Head end
    end
end)

Players.PlayerRemoving:Connect(function(plr)
    if highlights[plr] then pcall(function() highlights[plr]:Destroy() end); highlights[plr] = nil end
    if nameTags[plr] then pcall(function() nameTags[plr]:Destroy() end); nameTags[plr] = nil end
end)

local function setSpeed(s)
    local c = LocalPlayer.Character
    if c and c:FindFirstChild("Humanoid") then c.Humanoid.WalkSpeed = s end
end
RunService.Heartbeat:Connect(function() if Settings.WalkSpeed ~= 16 then setSpeed(Settings.WalkSpeed) end end)

local function getPlayerNames()
    local names = {}
    for _, plr in pairs(Players:GetPlayers()) do if plr ~= LocalPlayer then table.insert(names, plr.Name) end end
    if #names == 0 then table.insert(names, "无其他玩家") end
    return names
end

local Window = WindUI:CreateWindow({
    Title = "动物医院", Icon = "solar:moon-bold",
    Size = UDim2.fromOffset(400, 350), Theme = "冰白", Transparent = true,
})


local Tab1 = Window:Tab({Title = "主要", Icon = "play"})
Tab1:Toggle({Title = "防止扣除理智", Value = false, Callback = function(v) Settings.NoSanity = v; if v then setupNoSanity() end end})
Tab1:Paragraph({Title = "说明", Desc = "开启后扣理智正常，喝咖啡恢复"})
Tab1:Divider()
Tab1:Toggle({Title = "自动前台", Value = false, Callback = function(v) Settings.AutoReception = v end})
Tab1:Divider()
Tab1:Toggle({Title = "动物透视", Value = false, Callback = function(v) Settings.AnimalESP_Enabled = v; if not v then clearAnimalESP() end end})
Tab1:Toggle({Title = "显示动物距离", Value = false, Callback = function(v) Settings.AnimalESP_ShowDistance = v end})
Tab1:Toggle({Title = "只显示异常体", Value = false, Callback = function(v) Settings.AnimalESP_OnlyAbnormal = v; if v then lastAnimalScan = 0 end end})
Tab1:Divider()
Tab1:Toggle({Title = "秒互动", Value = false, Callback = function(v) 
    Settings.InstantInteract = v
    if v then
        enableInstant()
        WindUI:Notify({Title = "秒互动", Content = "已开启", Duration = 2})
    else
        disableInstant()
        WindUI:Notify({Title = "秒互动", Content = "已关闭", Duration = 2})
    end
end})

local Tab2 = Window:Tab({Title = "传送", Icon = "map-pin"})
Tab2:Button({Title = "传送前台", Callback = function() tp(Vector3.new(-103, 3.4, 4.2)) end})
Tab2:Button({Title = "房间一", Callback = function() tp(Vector3.new(-167, 3.5, -54.4)) end})
Tab2:Button({Title = "房间二", Callback = function() tp(Vector3.new(-126, 3.5, -49.8)) end})
Tab2:Button({Title = "房间三", Callback = function() tp(Vector3.new(-167, 3.5, -91.6)) end})
Tab2:Button({Title = "房间四", Callback = function() tp(Vector3.new(-121, 3.5, -86.5)) end})
Tab2:Button({Title = "房间五", Callback = function() tp(Vector3.new(-144, 3.5, -117)) end})
Tab2:Button({Title = "房间六", Callback = function() tp(Vector3.new(-125, 3.5, 51.7)) end})
Tab2:Button({Title = "房间七", Callback = function() tp(Vector3.new(-166, 3.5, 54)) end})
Tab2:Button({Title = "手术室", Callback = function() tp(Vector3.new(-145, 3.5, 83.1)) end})
Tab2:Divider()
local playerNames = getPlayerNames()
local selectedPlayer = playerNames[1] or "无其他玩家"
Tab2:Dropdown({Title = "选择玩家", Values = playerNames, Value = selectedPlayer, Callback = function(v) selectedPlayer = v end})
Tab2:Button({Title = "传送到该玩家", Callback = function() for _, plr in pairs(Players:GetPlayers()) do if plr.Name == selectedPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then tp(plr.Character.HumanoidRootPart.Position) end end end})

local Tab3 = Window:Tab({Title = "玩家", Icon = "users"})
Tab3:Toggle({Title = "透视玩家", Value = false, Callback = function(v) Settings.ESP_Enabled = v; if not v then clearESP() end end})
Tab3:Input({Title = "移动速度", Value = "16", Callback = function(v) local n = tonumber(v) if n and n >= 10 and n <= 100 then Settings.WalkSpeed = n end end})
Tab3:Button({Title = "重置速度", Callback = function() Settings.WalkSpeed = 16 end})

-- 设置标签页
local SettingsTab = Window:Tab({Title = "设置", Icon = "settings"})

local statusParagraph = SettingsTab:Paragraph({
    Title = "功能状态",
    Desc = "正在加载..."
})

local function updateStatus()
    local status = ""
    
    if Settings.NoSanity then
        status = status .. "✅ 防止扣除理智: 已开启\n"
    else
        status = status .. "❌ 防止扣除理智: 未开启\n"
    end
    
    if Settings.AutoReception then
        status = status .. "✅ 自动前台: 已开启\n"
    else
        status = status .. "❌ 自动前台: 未开启\n"
    end
    
    if Settings.AnimalESP_Enabled then
        status = status .. "✅ 动物透视: 已开启"
        if Settings.AnimalESP_OnlyAbnormal then
            status = status .. " (仅异常体)"
        end
        status = status .. "\n"
    else
        status = status .. "❌ 动物透视: 未开启\n"
    end
    
    if Settings.ESP_Enabled then
        status = status .. "✅ 透视玩家: 已开启\n"
    else
        status = status .. "❌ 透视玩家: 未开启\n"
    end
    
    if Settings.InstantInteract then
        status = status .. "✅ 秒互动: 已开启\n"
    else
        status = status .. "❌ 秒互动: 未开启\n"
    end
    
    statusParagraph:SetDesc(status)
end

RunService.Heartbeat:Connect(function()
    updateStatus()
end)

SettingsTab:Button({Title = "关闭脚本", Callback = function() stopAll = true; Settings.NoSanity = false; Settings.AnimalESP_Enabled = false; Settings.InstantInteract = false; disableInstant(); clearAnimalESP(); clearESP(); setSpeed(16); Window:Close() end})
Window:OnClose(function() stopAll = true; Settings.NoSanity = false; Settings.InstantInteract = false; disableInstant(); clearAnimalESP(); clearESP(); setSpeed(16) end)


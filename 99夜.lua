-- 99夜：独立服务器缝合版
local NothingLibrary = loadstring(game:HttpGetAsync('https://raw.githubusercontent.com/quanwei-sy/qianweicangku/refs/heads/main/%E6%BA%90%E7%A0%81.lua'))()

local __BaseWindow = NothingLibrary.new({
    Title = "TY hub｜99夜",
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


local module = Library
game:GetService("Players")
local HttpService = game:GetService("HttpService")

local function func(arg1)
	local str = ""

	local tbl = {
		Color3.fromRGB(180, 100, 255),
		Color3.fromRGB(150, 80, 235),
		Color3.fromRGB(120, 60, 215),
		Color3.fromRGB(90, 40, 195),
		Color3.fromRGB(70, 30, 175),
	}

	local v1 = #arg1:gsub("[^%w]", "")
	local num = 1

	for i = 1, #arg1 do
		local v2 = arg1:sub(i, i)
		if v2:match("[%w]") then
			local v3 = (num - 1) / math.max(v1 - 1, 1) * (#tbl - 1)
			local v4 = math.clamp(math.floor(v3) + 1, 1, #tbl)
			local v5 = math.clamp(v4 + 1, 1, #tbl)
			local v6 = tbl[v4]
			local v7 = tbl[v5]
			local v8 = v3 % 1
			local v9 = v6.R + (v7.R - v6.R) * v8
			local v10 = v6.G + (v7.G - v6.G) * v8
			local v11 = v6.B + (v7.B - v6.B) * v8
			str = str .. string.format('<font color="rgb(%d,%d,%d)">%s</font>', v9 * 255, v10 * 255, v11 * 255, v2)
			num = num + 1
		else
			str = str .. v2
		end
	end

	return str
end

local function func1(arg1)
	module:Notify({Title = "TY hub", Content = arg1, Duration = 3})
end

local function func2(arg1)
	local ok, result = pcall(function()
		if syn and syn.request then
			return syn.request(arg1)
		end

		if request and type(request) == "function" then
			return request(arg1)
		end

		if http and http.request then
			return http.request(arg1)
		end

		return {Body = HttpService:GetAsync(arg1.Url), StatusCode = 200, Success = true}
	end)

	if ok then
		return result
	end

	return {Body = "{}", StatusCode = 0, Success = false}
end

local function func3(arg1, arg2)
	for _ = 1, arg2 or 2 do
		local v1 = func2(arg1)

		if v1 and v1.StatusCode == 200 then
			return v1
		end

		task.wait(1)
	end
	return {Success = false}
end

local tbl = {
	Name = "TYHubPurple",
	Dialog = Color3.fromHex("#1A0F2E"),
	Outline = Color3.fromHex("#1A0F2E"),
	Text = Color3.fromHex("#FFFFFF"),
	Placeholder = Color3.fromHex("#1A0F2E"),
	Background = Color3.fromHex("#1A0F2E"),
	Button = Color3.fromHex("#7E6BA1"),
}

local tbl1 = {Color = Color3.fromHex("#B58BFF"), Transparency = 0}
local tbl2 = {Color = Color3.fromHex("#5A7FFF"), Transparency = 0}
tbl.Icon = module:Gradient({["0"] = tbl1, ["100"] = tbl2}, {Rotation = 0})
module:AddTheme(tbl)

local tbl3 = {
	Title = func("TY hub｜99夜"),
	Folder = "TY hub",
	Size = UDim2.fromOffset(605, 360),
	Transparent = true,
	Resizable = true,
	Theme = "TYHubPurple",
	SideBarWidth = 200,
	Background = "rbxassetid://124138067839032",
	BackgroundTransparency = 0.65,
	HideSearchBar = false,
	ScrollBarEnabled = true,
}

local Window = module:CreateWindow(tbl3)
local tbl4 = {Color = Color3.fromHex("#6A0DAD"), Transparency = 0}
local tbl5 = {Color = Color3.fromHex("#00008B"), Transparency = 0}


Window:EditOpenButton({
	Title = func("打开 TY hub"),
	CornerRadius = UDim.new(0, 16),
	StrokeThickness = 2,
	Color = ColorSequence.new(Color3.fromHex("6A0DAD"), Color3.fromHex("00008B")),
	OnlyMobile = false,
	Enabled = true,
	Draggable = true,
})

Window:SetBackgroundImageTransparency(0.65)

Tab = Window:Tab({Title = "Main", Icon = "square", Locked = false})

Section = Tab:Section({
	Title = "Auto Stun",
	Icon = "bird",
	Box = true,
	FontWeight = Enum.FontWeight.SemiBold,
	TextTransparency = 0,
	HorizontalAlignment = Enum.HorizontalAlignment.Left,
	TextSize = 17,
	Opened = true,
})

local MonsterHitByTorch = game:GetService("ReplicatedStorage").RemoteEvents.MonsterHitByTorch
local flag = false
local flag1 = false
local Deer = workspace.Characters:FindFirstChild("Deer")
local Ram = workspace.Characters:FindFirstChild("Ram")

Tab:Toggle({
	Title = "Hit Deer with Torch",
	Default = false,
	Callback = function(value)
		flag = value
		if value then
			spawn(function()
				while flag do
					if Deer then
						MonsterHitByTorch:InvokeServer(Deer)
					end
					task.wait()
				end
			end)
		end
	end,
})

Tab:Toggle({
	Title = "Auto Stun deer (Hold Flashlight)",
	Default = false,
	Callback = function(value)
		flag1 = value
		if value then
			spawn(function()
				while flag1 do
					if Ram then
						MonsterHitByTorch:InvokeServer(Ram)
					end
					task.wait()
				end
			end)
		end
	end,
})

Section = Tab:Section({
	Title = "God Mode",
	Box = false,
	FontWeight = Enum.FontWeight.SemiBold,
	TextTransparency = 0,
	HorizontalAlignment = Enum.HorizontalAlignment.Left,
	TextSize = 17,
	Opened = true,
})

local Players = game:GetService("Players")
local flag2 = false
local connection

local function func5(arg1)
	if arg1 and flag2 then
		arg1.MaxHealth = 100
		arg1.Health = 100
		arg1.BreakJointsOnDeath = false

		if connection then
			connection:Disconnect()
		end

		connection = arg1.HealthChanged:Connect(function(health)
			if flag2 and health < 100 then
				arg1.Health = 100
			end
		end)
	end
end

local function func6(arg1)
	if arg1 then
		arg1.MaxHealth = 100
		arg1.Health = 100
		arg1.BreakJointsOnDeath = true

		if connection then
			connection:Disconnect()
			connection = nil
		end
	end
end

Tab:Toggle({
	Title = "God mode (Invincibility)",
	Desc = "Makes you completely invincible to all damage, hunger, and death.",
	Type = "Toggle",
	Default = false,
	Callback = function(value)
		flag2 = value
		local Character1 = Players.LocalPlayer.Character

		if Character1 then
			local Humanoid1 = Character1:FindFirstChild("Humanoid")
			if value then
				func5(Humanoid1)
			else
				func6(Humanoid1)
			end
		end
	end,
})

Players.LocalPlayer.CharacterAdded:Connect(function(character1)
	if flag2 then
		local Humanoid1 = character1:WaitForChild("Humanoid")
		func5(Humanoid1)
	end
end)

task.spawn(function()
	local RunService = game:GetService("RunService")
	while true do
		RunService.RenderStepped:Wait()
		if flag2 then
			local Character1 = Players.LocalPlayer.Character

			if Character1 then
				local Humanoid1 = Character1:FindFirstChild("Humanoid")
				if Humanoid1 then
					if Humanoid1.Health < 100 then
						Humanoid1.Health = 100
					end
				end
			end

			Players.LocalPlayer:SetAttribute("Hunger", 100)
		end
	end
end)

Section = Tab:Section({
	Title = "Hip Height",
	Icon = "diameter",
	Box = true,
	FontWeight = Enum.FontWeight.SemiBold,
	TextTransparency = 0,
	HorizontalAlignment = Enum.HorizontalAlignment.Left,
	TextSize = 17,
	Opened = true,
})

Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
Humanoid = Character:WaitForChild("Humanoid")
originalHipHeight = Humanoid.HipHeight
hipHeightSlider = 20
hipHeightEnabled = false

HipHeightSlider = Tab:Slider({
	Title = "Hip Height",
	Step = 1,
	Value = {Min = 20, Max = 100, Default = 20},
	Callback = function(value)
		hipHeightSlider = value
		if hipHeightEnabled then
			Humanoid.HipHeight = hipHeightSlider
		end
	end,
})

HipHeightToggle = Tab:Toggle({
	Title = "Hip Height",
	Desc = "This Hip height will save you from the hostile Monster/Enemies Use Minimum :20: For It TO work!!",
	Type = "Toggle",
	Default = false,
	Callback = function(value)
		hipHeightEnabled = value
		if hipHeightEnabled then
			Humanoid.HipHeight = hipHeightSlider
		else
			Humanoid.HipHeight = originalHipHeight
		end
	end,
})

Section = Tab:Section({
	Title = "Chop Tree",
	Icon = "axe",
	Box = true,
	FontWeight = Enum.FontWeight.SemiBold,
	TextTransparency = 0,
	HorizontalAlignment = Enum.HorizontalAlignment.Left,
	TextSize = 17,
	Opened = true,
})

rs = game:GetService("ReplicatedStorage")
plrs = game:GetService("Players")
lp = plrs.LocalPlayer
tdr = rs.RemoteEvents.ToolDamageObject
er = rs.RemoteEvents.EquipItemHandle
hrp = lp.Character and lp.Character:WaitForChild("HumanoidRootPart")

lp.CharacterAdded:Connect(function(character1)
	hrp = character1:WaitForChild("HumanoidRootPart")
end)

range = 70
chopAuraEnabled = false
active = {}

tdi = {
	["Old Axe"] = "3_7367831688",
	["Good Axe"] = "112_7367831688",
	["Strong Axe"] = "116_7367831688",
	["Ice Axe"] = "116_7367831688",
	["Admin Axe"] = "116_7367831688",
	Chainsaw = "120_7367831688",
}

SelectedTreeTypes = {"Small Tree"}

Slider = Tab:Slider({
	Title = "Range",
	Step = 1,
	Value = {Min = 20, Max = 1000, Default = 70},
	Callback = function(value)
		range = tonumber(value) or 70
	end,
})

TreeDropdown = Tab:Dropdown({
	Title = "Select Trees to Chop",
	Values = {"Snowy Small Tree", "Small Tree", "TreeBig"},
	Value = {"Small Tree"},
	Multi = true,
	AllowNone = true,
	Callback = function(value)
		SelectedTreeTypes = value
	end,
})

function gtool()
	inv = lp:FindFirstChild("Inventory")

	if not inv then
		return nil, nil
	end

	for k, v1 in pairs(tdi) do
		tool = inv:FindFirstChild(k)
		if tool then
			return tool, v1
		end
	end

	return nil, nil
end

function eq(arg1)
	if arg1 then
		er:FireServer("FireAllClients", arg1)
	end
end

task.spawn(function()
	while true do
		task.wait(3)
		if chopAuraEnabled then
			tool = gtool()
			if tool then
				eq(tool)
			end
		end
	end
end)

function startloop(arg1)
	if not arg1:IsA("Model") or not arg1:FindFirstChildWhichIsA("BasePart") then
		return
	end

	if active[arg1] then
		return
	end

	active[arg1] = true

	task.spawn(function()
		while arg1.Parent and active[arg1] do
			local v1, v2 = gtool()
			tool = v1
			dmgId = v2

			if not tool or not dmgId or not hrp then
				task.wait(0.2)
			else
				pp = arg1.PrimaryPart or arg1:FindFirstChildWhichIsA("BasePart")

				if not pp then
					break
				end

				dist = (hrp.Position - pp.Position).Magnitude

				if dist <= range then
					tdr:InvokeServer(arg1, tool, dmgId, hrp.CFrame)
				end

				cd = tool:GetAttribute("ToolCooldown") or 1
				task.wait(cd)
			end
		end
		active[arg1] = nil
	end)
end

AutoChopToggle = Tab:Toggle({
	Title = "Auto Chop Selected Trees",
	Desc = "Chop all trees of selected types in your range",
	Type = "Toggle",
	Default = false,
	Callback = function(value)
		chopAuraEnabled = value
		if value then
			for _, v1 in ipairs({workspace.Map.Landmarks, workspace.Map.Foliage}) do
				for _, child in ipairs(v1:GetChildren()) do
					if table.find(SelectedTreeTypes, child.Name) then
						startloop(child)
					end
				end
			end
		else
			for k in pairs(active) do
				active[k] = nil
			end
		end
	end,
})

for _, v2 in ipairs({workspace.Map.Landmarks, workspace.Map.Foliage}) do
	v2.ChildAdded:Connect(function(child)
		if chopAuraEnabled and table.find(SelectedTreeTypes, child.Name) then
			startloop(child)
		end
	end)
end

local ReplicatedStorage = game:GetService("ReplicatedStorage")
Workspace = game:GetService("Workspace")
Players = game:GetService("Players")
player = Players.LocalPlayer
autoPlantEnabled = false

function findSapling()
	for _, descendant in ipairs(Workspace:GetDescendants()) do
		if descendant.Name == "Sapling" and descendant:IsA("Model") then
			return descendant
		end
	end
	return nil
end

function plantSapling(arg1)
	if not arg1 then
		return
	end

	position = arg1.PrimaryPart and arg1.PrimaryPart.Position or arg1:GetModelCFrame().p
	ReplicatedStorage.RemoteEvents.RequestPlantItem:InvokeServer(arg1, position)
end

task.spawn(function()
	while true do
		task.wait(1)
		if autoPlantEnabled then
			sapling = findSapling()
			if sapling then
				plantSapling(sapling)
			end
		end
	end
end)

AutoPlantToggle = Tab:Toggle({
	Title = "Auto Plant Sapling",
	Desc = "Auto Plants Saplings",
	Type = "Toggle",
	Default = false,
	Callback = function(value)
		autoPlantEnabled = value
	end,
})

Section = Tab:Section({
	Title = "Auto Food",
	Icon = "carrot",
	Box = true,
	FontWeight = Enum.FontWeight.SemiBold,
	TextTransparency = 0,
	HorizontalAlignment = Enum.HorizontalAlignment.Left,
	TextSize = 17,
	Opened = true,
})

ReplicatedStorage = game:GetService("ReplicatedStorage")
Players = game:GetService("Players")
Workspace = game:GetService("Workspace")
player = Players.LocalPlayer
Remote = ReplicatedStorage:WaitForChild("RemoteEvents"):WaitForChild("RequestConsumeItem")

foodOptions = {
	"Carrot",
	"Berry",
	"Chili",
	"Morsel",
	"Steak",
	"Cooked Morsel",
	"Cooked Steak",
	"Salmon",
	"Clownfish",
	"Mackerel",
	"Cooked Mackerel",
	"Cooked Salmon",
	"Cooked Clownfish",
	"Ribs",
	"Cooked Ribs",
	"Cake",
	"Apple",
}

autoConsumeEnabled = false
selectedFoods = {}
hungerThreshold = 70

FoodDropdown = Tab:Dropdown({
	Title = "Auto Eat Food",
	Values = foodOptions,
	Value = {},
	Multi = true,
	AllowNone = true,
	Callback = function(value)
		selectedFoods = {}
		for _, v1 in ipairs(value) do
			selectedFoods[v1] = true
		end
	end,
})

HungerSlider = Tab:Slider({
	Title = "Eat Food when Hunger Below",
	Step = 1,
	Value = {Min = 20, Max = 200, Default = 70},
	Callback = function(value)
		hungerThreshold = tonumber(value) or 70
	end,
})

function getNearestFood()
	if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then
		return nil
	end

	local v2
	local huge = math.huge
	local HumanoidRootPart = player.Character.HumanoidRootPart

	for _, descendant in ipairs(Workspace:GetDescendants()) do
		if selectedFoods[descendant.Name] and descendant:IsA("Model") then
			local v1 = descendant.PrimaryPart or descendant:FindFirstChildWhichIsA("BasePart")
			if v1 then
				local Magnitude = (HumanoidRootPart.Position - v1.Position).Magnitude
				if Magnitude < huge then
					huge = Magnitude
					v2 = descendant
				end
			end
		end
	end

	return v2
end

task.spawn(function()
	while task.wait(0.5) do
		if autoConsumeEnabled then
			hunger = player:GetAttribute("Hunger") or 0
			if hunger <= hungerThreshold then
				food = getNearestFood()
				if food then
					Remote:InvokeServer(food)
				end
			end
		end
	end
end)

AutoConsumeToggle = Tab:Toggle({
	Title = "Auto Eat",
	Desc = "Automatically eats food when hunger is low",
	Type = "Toggle",
	Default = false,
	Callback = function(value)
		autoConsumeEnabled = value
	end,
})

Section = Tab:Section({
	Title = "Kill aura (Select)",
	Icon = "hand-fist",
	Box = true,
	FontWeight = Enum.FontWeight.SemiBold,
	TextTransparency = 0,
	HorizontalAlignment = Enum.HorizontalAlignment.Left,
	TextSize = 17,
	Opened = true,
})

local ReplicatedStorage1 = game:GetService("ReplicatedStorage")
local LocalPlayer1 = game.Players.LocalPlayer
local ToolDamageObject = ReplicatedStorage1.RemoteEvents:WaitForChild("ToolDamageObject")
local flag3 = false
local num = 70
local tbl14 = {}

local tbl15 = {
	["Old Axe"] = "3_7367831688",
	["Good Axe"] = "112_7367831688",
	["Strong Axe"] = "116_7367831688",
	["Ice Axe"] = "116_7367831688",
	["Admin Axe"] = "116_7367831688",
	Morningstar = "116_7367831688",
	["Laser Sword"] = "116_7367831688",
	["Ice Sword"] = "116_7367831688",
	Katana = "116_7367831688",
	Trident = "116_7367831688",
	["Poison Spear"] = "116_7367831688",
	Spear = "196_8999010016",
}

local tbl16 = {
	"Bunny",
	"Wolf",
	"Alpha Wolf",
	"Bear",
	"Cultist",
	"Crossbow Cultist",
	"Juggernaut Cultist",
	"Meteor Crab",
	"Lava Mammoth",
	"FrogKing",
	"Cultist king",
	"Horse",
	"Scorpion",
	"Hellephant",
	"FrogBlue",
}

local function func7()
	local v1 = LocalPlayer1:FindFirstChild("Inventory") or LocalPlayer1:FindFirstChild("Backpack")
	if v1 then
		for k, v2 in pairs(tbl15) do
			local v3 = v1:FindFirstChild(k)
			if v3 then
				return v3, v2
			end
		end
	end
end

Tab:Slider({
	Title = "Range",
	Step = 1,
	Value = {Min = 20, Max = 300, Default = 70},
	Callback = function(value)
		num = tonumber(value) or 70
	end,
})

Tab:Dropdown({
	Title = "Enemies",
	Values = tbl16,
	Value = {},
	Multi = true,
	AllowNone = true,
	Callback = function(value)
		tbl14 = {}
		for _, v1 in ipairs(value) do
			tbl14[v1] = true
		end
	end,
})

Tab:Toggle({
	Title = "Kill Aura",
	Desc = "Auto kill selected enemies in range",
	Type = "Toggle",
	Default = false,
	Callback = function(value)
		flag3 = value
	end,
})

task.spawn(function()
	while task.wait(0.05) do
		if flag3 and LocalPlayer1.Character and LocalPlayer1.Character:FindFirstChild("HumanoidRootPart") then
			local v1, v2 = func7()
			if v1 and v2 then
				for _, child in ipairs(workspace.Characters:GetChildren()) do
					if tbl14[child.Name] and child:IsA("Model") and child:FindFirstChild("HumanoidRootPart") then
						if (LocalPlayer1.Character.HumanoidRootPart.Position - child.HumanoidRootPart.Position).Magnitude <= num then
							ToolDamageObject:InvokeServer(child, v1, v2, child.HumanoidRootPart.CFrame)
						end
					end
				end
			end
		end
	end
end)

Section = Tab:Section({
	Title = "Kill aura (Nearby)",
	Icon = "hand-fist",
	Box = true,
	FontWeight = Enum.FontWeight.SemiBold,
	TextTransparency = 0,
	HorizontalAlignment = Enum.HorizontalAlignment.Left,
	TextSize = 17,
	Opened = true,
})

local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local LocalPlayer2 = game:GetService("Players").LocalPlayer
local workspaceRef = workspace
local ToolDamageObject1 = ReplicatedStorage2.RemoteEvents:WaitForChild("ToolDamageObject")

local tbl17 = {
	["Old Axe"] = "3_7367831688",
	["Good Axe"] = "112_7367831688",
	["Strong Axe"] = "116_7367831688",
	["Ice Axe"] = "116_7367831688",
	["Admin Axe"] = "116_7367831688",
	Morningstar = "116_7367831688",
	["Laser Sword"] = "116_7367831688",
	["Ice Sword"] = "116_7367831688",
	Katana = "116_7367831688",
	Trident = "116_7367831688",
	["Poison Spear"] = "116_7367831688",
	Spear = "196_8999010016",
}

local flag4 = false
local num1 = 70

local function func8()
	local v1 = LocalPlayer2:FindFirstChild("Backpack") or LocalPlayer2:FindFirstChild("Inventory")

	if v1 then
		for k, v2 in pairs(tbl17) do
			local v3 = v1:FindFirstChild(k)
			if v3 then
				return v3, v2
			end
		end
	end

	return nil, nil
end

Tab:Slider({
	Title = "Range",
	Step = 1,
	Value = {Min = 20, Max = 300, Default = 70},
	Callback = function(value)
		num1 = tonumber(value) or 70
	end,
})

Tab:Toggle({
	Title = "Kill Aura",
	Desc = "Auto Kills All Nearby Enemies in range",
	Type = "Toggle",
	Default = false,
	Callback = function(value)
		flag4 = value
	end,
})

task.spawn(function()
	while task.wait(0.05) do
		if flag4 and LocalPlayer2.Character and LocalPlayer2.Character:FindFirstChild("HumanoidRootPart") then
			local v1, v2 = func8()
			if v1 and v2 then
				for _, child in ipairs(workspaceRef.Characters:GetChildren()) do
					if
						child ~= LocalPlayer2.Character
						and child:IsA("Model")
						and child:FindFirstChild("HumanoidRootPart")
					then
						local HumanoidRootPart = child.HumanoidRootPart
						if (LocalPlayer2.Character.HumanoidRootPart.Position - HumanoidRootPart.Position).Magnitude <= num1 then
							ToolDamageObject1:InvokeServer(child, v1, v2, HumanoidRootPart.CFrame)
						end
					end
				end
			end
		end
	end
end)

Section = Tab:Section({
	Title = "Auto Heal",
	Icon = "cross",
	Box = true,
	FontWeight = Enum.FontWeight.SemiBold,
	TextTransparency = 0,
	HorizontalAlignment = Enum.HorizontalAlignment.Left,
	TextSize = 17,
	Opened = true,
})

local ReplicatedStorage3 = game:GetService("ReplicatedStorage")
local Players1 = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer3 = Players1.LocalPlayer
local Inventory = LocalPlayer3:WaitForChild("Inventory")
local Humanoid1 = (LocalPlayer3.Character or LocalPlayer3.CharacterAdded:Wait()):WaitForChild("Humanoid")
local RequestConsumeItem = ReplicatedStorage3:WaitForChild("RemoteEvents"):WaitForChild("RequestConsumeItem")
local flag5 = false
local flag6 = false
local num2 = 50

Tab:Slider({
	Title = "Auto Bandage When Health is Below",
	Step = 1,
	Value = {Min = 1, Max = 100, Default = 50},
	Callback = function(value)
		num2 = tonumber(value) or 50
	end,
})

Tab:Toggle({
	Title = "Auto Bandage",
	Desc = "Use Bandage when health is below this value",
	Type = "Toggle",
	Default = false,
	Callback = function(value)
		flag5 = value
	end,
})

Tab:Toggle({
	Title = "Include MedKit",
	Desc = "Include MedKit to auto heal",
	Type = "Toggle",
	Default = false,
	Callback = function(value)
		flag6 = value
	end,
})

local function func9(name)
	local v1 = Inventory:FindFirstChild(name)
	if v1 then
		RequestConsumeItem:InvokeServer(v1)
	end
end

RunService.Heartbeat:Connect(function()
	if Humanoid1.Health <= num2 then
		if flag5 then
			func9("Bandage")
		end
		if flag6 then
			func9("MedKit")
		end
	end
end)

Section = Tab:Section({
	Title = "Others",
	Icon = "gear",
	Box = true,
	FontWeight = Enum.FontWeight.SemiBold,
	TextTransparency = 0,
	HorizontalAlignment = Enum.HorizontalAlignment.Left,
	TextSize = 17,
	Opened = true,
})

local Workspace1 = game:GetService("Workspace")
local flag7 = false

local function func10(arg1)
	arg1.HoldDuration = 0
	arg1.RequiresLineOfSight = false
	arg1.MaxActivationDistance = 10
	arg1.ClickablePrompt = true
end

local tab = Tab
local tbl18 = {Title = "Instant Open Chests"}
tbl18.Desc = nil
tbl18.Type = "Toggle"
tbl18.Default = false

function tbl18.Callback(arg1)
	flag7 = arg1
	if flag7 then
		for _, descendant in ipairs(Workspace1.Items:GetDescendants()) do
			if descendant:IsA("ProximityPrompt") then
				func10(descendant)
			end
		end
	end
end

tab:Toggle(tbl18)
local Players2 = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local RunService1 = game:GetService("RunService")
local LocalPlayer4 = Players2.LocalPlayer
local flag8 = false
local flag9 = false
local vector3 = Vector3.new(0, 10, 0)

local function func11()
	local ClockTime = Lighting.ClockTime
	return ClockTime >= 18 or ClockTime <= 6
end

local tab1 = Tab
local tbl19 = {Title = "Teleport to camp at night"}
tbl19.Desc = nil
tbl19.Type = "Toggle"
tbl19.Default = false

function tbl19.Callback(arg1)
	flag8 = arg1
end

tab1:Toggle(tbl19)

RunService1.RenderStepped:Connect(function()
	if not flag8 then
		return
	end

	local Character1 = LocalPlayer4.Character

	if not Character1 then
		return
	end

	local HumanoidRootPart = Character1:FindFirstChild("HumanoidRootPart")

	if not HumanoidRootPart then
		return
	end

	if func11() and not flag9 then
		flag9 = true
		HumanoidRootPart.CFrame = CFrame.new(vector3)
	elseif not func11() then
		flag9 = false
	end
end)

Tab = Window:Tab({Title = "Teleports", Icon = "map-pin", Locked = false})

Section = Tab:Section({
	Title = "Main Locations",
	Icon = "map-pin",
	Box = true,
	FontWeight = Enum.FontWeight.SemiBold,
	TextTransparency = 0,
	HorizontalAlignment = Enum.HorizontalAlignment.Left,
	TextSize = 17,
	Opened = true,
})

local function func12(name)
	local LocalPlayer = game.Players.LocalPlayer

	if not LocalPlayer then
		return
	end

	local HumanoidRootPart = (LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()):FindFirstChild("HumanoidRootPart")

	if not HumanoidRootPart then
		return
	end

	local v1 = workspace:FindFirstChild(name, true)

	if v1 then
		HumanoidRootPart.CFrame = (v1:IsA("Model") and v1:GetPivot() or v1.CFrame) + Vector3.new(0, 5, 0)
	end
end

Tab:Button({
	Title = "Teleport to Camp",
	Locked = false,
	Callback = function()
		func12("Camp")
	end,
})

Tab:Button({
	Title = "Teleport To Pelt Trader",
	Locked = false,
	Callback = function()
		func12("Pelt Trader")
	end,
})

Tab:Button({
	Title = "Teleport To Fairy",
	Locked = false,
	Callback = function()
		func12("Fairy")
	end,
})

Tab:Button({
	Title = "Teleport To Military Base",
	Locked = false,
	Callback = function()
		func12("Military Base")
	end,
})

Tab:Button({
	Title = "Teleport To Stronghold",
	Locked = false,
	Callback = function()
		func12("Stronghold")
	end,
})

Tab:Button({
	Title = "Teleport To Caravan",
	Locked = false,
	Callback = function()
		func12("Caravan")
	end,
})

Tab:Button({
	Title = "Teleport To Kings Palace",
	Locked = false,
	Callback = function()
		func12("Kings Palace")
	end,
})

Section = Tab:Section({
	Title = "Enemies/Animals",
	Icon = "bird",
	Box = true,
	FontWeight = Enum.FontWeight.SemiBold,
	TextTransparency = 0,
	HorizontalAlignment = Enum.HorizontalAlignment.Left,
	TextSize = 17,
	Opened = true,
})

local v5

Tab:Dropdown({
	Title = "Select Enemy",
	Values = {
		"Bunny",
		"Wolf",
		"Alpha Wolf",
		"Bear",
		"Cultist",
		"Crossbow Cultist",
		"Juggernaut Cultist",
		"Cultist King",
		"Hellephant",
		"Mammoth",
		"Meteor Crab",
		"Scorpion",
		"Artic Fox",
		"Polar Bear",
		"FrogKing",
		"Horse",
		"Kiwi",
		"Alien",
	},
	Value = "Bunny",
	Callback = function(value)
		v5 = value
	end,
})

local tab2 = Tab
local tbl20 = {Title = "Teleport to Enemy"}
tbl20.Desc = nil
tbl20.Locked = false

function tbl20.Callback()
	if not v5 then
		return
	end

	local LocalPlayer = game.Players.LocalPlayer
	local HumanoidRootPart = (LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()):WaitForChild("HumanoidRootPart")
	local tbl = {}

	for _, descendant in ipairs(workspace:GetDescendants()) do
		if descendant.Name == v5 and descendant:IsA("Model") then
			table.insert(tbl, descendant)
		end
	end

	if #tbl > 0 then
		local v1 = tbl[math.random(1, #tbl)]
		local v2 = v1.PrimaryPart or v1:FindFirstChildWhichIsA("BasePart")

		if v2 then
			HumanoidRootPart.CFrame = v2.CFrame + Vector3.new(0, 5, 0)
		end
	end
end

tab2:Button(tbl20)

Section = Tab:Section({
	Title = "Child",
	Icon = "baby",
	Box = true,
	FontWeight = Enum.FontWeight.SemiBold,
	TextTransparency = 0,
	HorizontalAlignment = Enum.HorizontalAlignment.Left,
	TextSize = 17,
	Opened = true,
})

selectedKid = nil

Tab:Dropdown({
	Title = "Select Kid",
	Values = {"DinoKid", "KrakenKid", "SquidKid", "KoalaKid"},
	Value = "DinoKid",
	Callback = function(value)
		selectedKid = value
	end,
})

Tab:Button({
	Title = "Teleport to Kid",
	Desc = "Teleports you to the selected kid type",
	Locked = false,
	Callback = function()
		if not selectedKid then
			print("[TY hub] No kid selected!")
			return
		end

		local LocalPlayer = game.Players.LocalPlayer

		if not LocalPlayer then
			return
		end

		local v1 = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()

		if not v1 then
			return
		end

		local HumanoidRootPart = v1:FindFirstChild("HumanoidRootPart")

		if not HumanoidRootPart then
			local HumanoidRootPart1 = v1:WaitForChild("HumanoidRootPart", 5)
			HumanoidRootPart = HumanoidRootPart1

			if not HumanoidRootPart1 then
				return
			end
		end

		local flag = false

		for _, descendant in pairs(workspace:GetDescendants()) do
			if descendant:IsA("Model") and descendant.Name == selectedKid then
				local v2 = descendant:FindFirstChild("HumanoidRootPart") or descendant:FindFirstChildWhichIsA("BasePart")
				if v2 then
					HumanoidRootPart.CFrame = v2.CFrame + Vector3.new(0, 5, 0)
					flag = true
					print("[TY hub] Teleported to " .. selectedKid)
					break
				end
			end
		end

		if not flag then
			print("[TY hub] Could not find " .. selectedKid .. " in the game!")
		end
	end,
})

Section = Tab:Section({
	Title = "Chests",
	Icon = "package",
	Box = true,
	FontWeight = Enum.FontWeight.SemiBold,
	TextTransparency = 0,
	HorizontalAlignment = Enum.HorizontalAlignment.Left,
	TextSize = 17,
	Opened = true,
})

SelectedChest = nil
ChestOptions = {}

function updateChestOptions()
	ChestOptions = {}

	for _, descendant in ipairs(workspace:GetDescendants()) do
		if descendant:IsA("Model") and (descendant.Name:find("Item Chest") or descendant.Name:find("Volcanic")) then
			table.insert(ChestOptions, descendant.Name)
		end
	end

	SelectedChest = ChestOptions[1]
end

updateChestOptions()

ChestDropdown = Tab:Dropdown({
	Title = "Select Chest",
	Values = ChestOptions,
	Value = SelectedChest,
	Callback = function(value)
		SelectedChest = value
	end,
})

TeleportChestButton = Tab:Button({
	Title = "Teleport to Selected Chest",
	Callback = function()
		if not SelectedChest then
			return
		end

		local LocalPlayer = game.Players.LocalPlayer
		local HumanoidRootPart = (LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()):WaitForChild("HumanoidRootPart")
		local tbl = {}

		for _, descendant in ipairs(workspace:GetDescendants()) do
			if descendant:IsA("Model") and descendant.Name == SelectedChest then
				table.insert(tbl, descendant)
			end
		end

		if #tbl > 0 then
			HumanoidRootPart.CFrame = tbl[math.random(1, #tbl)]:GetPivot() + Vector3.new(0, 5, 0)
		end
	end,
})

RefreshChestsButton = Tab:Button({
	Title = "Refresh Chest List",
	Callback = function()
		updateChestOptions()
		ChestDropdown:UpdateValues(ChestOptions)
	end,
})

TeleportRandomChestButton = Tab:Button({
	Title = "Teleport to Random Chest",
	Callback = function()
		local LocalPlayer = game.Players.LocalPlayer
		local HumanoidRootPart = (LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()):WaitForChild("HumanoidRootPart")
		local tbl = {}

		for _, descendant in ipairs(workspace:GetDescendants()) do
			if descendant:IsA("Model") and (descendant.Name:find("Item Chest") or descendant.Name:find("Volcanic")) then
				table.insert(tbl, descendant)
			end
		end

		if #tbl > 0 then
			HumanoidRootPart.CFrame = tbl[math.random(1, #tbl)]:GetPivot() + Vector3.new(0, 5, 0)
		end
	end,
})

Section = Tab:Section({
	Title = "Fuel",
	Icon = "fuel",
	Box = true,
	FontWeight = Enum.FontWeight.SemiBold,
	TextTransparency = 0,
	HorizontalAlignment = Enum.HorizontalAlignment.Left,
	TextSize = 17,
	Opened = true,
})

SelectedObject = nil

DropdownObjects = {
	"Sapling",
	"Log",
	"Coal",
	"Chair",
	"Fuel Canister",
	"Oil Barrel",
	"Biofuel",
	"Cultist Corpse",
	"Crossbow Cultist Corpse",
	"Juggernaut Cultist Corpse",
	"Wolf Corpse",
	"Alpha Wolf Corpse",
	"Bear Corpse",
}

ObjectDropdown = Tab:Dropdown({
	Title = "Select Object",
	Values = DropdownObjects,
	Value = DropdownObjects[1],
	Callback = function(value)
		SelectedObject = value
	end,
})

Tab:Button({
	Title = "Teleport to Object",
	Callback = function()
		if not SelectedObject then
			return
		end

		local LocalPlayer = game.Players.LocalPlayer
		local HumanoidRootPart = (LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()):WaitForChild("HumanoidRootPart")
		local tbl = {}

		for _, descendant in ipairs(workspace:GetDescendants()) do
			if descendant.Name == SelectedObject then
				table.insert(tbl, descendant)
			end
		end

		if #tbl > 0 then
			local v1 = tbl[math.random(1, #tbl)]
			HumanoidRootPart.CFrame = (v1:IsA("Model") and v1:GetPivot() or v1.CFrame) + Vector3.new(0, 5, 0)
		end
	end,
})

Section = Tab:Section({
	Title = "Scrap",
	Icon = "cog",
	Box = true,
	FontWeight = Enum.FontWeight.SemiBold,
	TextTransparency = 0,
	HorizontalAlignment = Enum.HorizontalAlignment.Left,
	TextSize = 17,
	Opened = true,
})

SelectedItem = nil

DropdownItems = {
	"Bolt",
	"Sheet Metal",
	"Broken Fan",
	"Old Radio",
	"Metal Chair",
	"Old Microwave",
	"Tyre",
	"Old Car Engine",
	"Washing Machine",
	"Cultist Prototype",
	"Cultist Experiment",
	"Cultist Gem",
	"Forest Gem",
}

ItemDropdown = Tab:Dropdown({
	Title = "Select Scrap",
	Values = DropdownItems,
	Value = DropdownItems[1],
	Callback = function(value)
		SelectedItem = value
	end,
})

TeleportButtonItem = Tab:Button({
	Title = "Teleport to Scrap",
	Callback = function()
		if not SelectedItem then
			return
		end

		local LocalPlayer = game.Players.LocalPlayer
		local HumanoidRootPart = (LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()):WaitForChild("HumanoidRootPart")
		local tbl = {}

		for _, descendant in ipairs(workspace:GetDescendants()) do
			if descendant.Name == SelectedItem then
				table.insert(tbl, descendant)
			end
		end

		if #tbl > 0 then
			local v1 = tbl[math.random(1, #tbl)]
			HumanoidRootPart.CFrame = (v1:IsA("Model") and v1:GetPivot() or v1.CFrame) + Vector3.new(0, 5, 0)
		end
	end,
})

Tab = Window:Tab({Title = "Automatic", Icon = "telescope", Locked = false})

Section = Tab:Section({
	Title = "Auto Fuel (TweenSource)",
	Icon = "fuel",
	Box = true,
	FontWeight = Enum.FontWeight.SemiBold,
	TextTransparency = 0,
	HorizontalAlignment = Enum.HorizontalAlignment.Left,
	TextSize = 17,
	Opened = true,
})

local Players3 = game:GetService("Players")
local ReplicatedStorage4 = game:GetService("ReplicatedStorage")
TweenService = game:GetService("TweenService")
workspaceRef = workspace
LocalPlayer2 = Players3.LocalPlayer
character = LocalPlayer2.Character or LocalPlayer2.CharacterAdded:Wait()
hrp = character:WaitForChild("HumanoidRootPart")
camera = workspaceRef.CurrentCamera
startDrag = ReplicatedStorage4.RemoteEvents:WaitForChild("RequestStartDraggingItem")
stopDrag = ReplicatedStorage4.RemoteEvents:WaitForChild("StopDraggingItem")
selectedItems = {}
autoBringEnabled = false
bringPos = CFrame.new(0, 10, 0)
camPos = CFrame.new(2, 9, 2)
bringDistanceThreshold = 15

ItemDropdown = Tab:Dropdown({
	Title = "Select Fuel",
	Values = {
		"Log",
		"Chair",
		"Coal",
		"Fuel Canister",
		"Oil Barrel",
		"Wolf Corpse",
		"Alpha Wolf Corpse",
		"Bear Corpse",
		"Cultist Corpse",
	},
	Value = {},
	Multi = true,
	AllowNone = true,
	Callback = function(value)
		selectedItems = {}
		for i = 1, #value do
			selectedItems[value[i]] = true
		end
	end,
})

local tab3 = Tab
local tbl21 = {Title = "Auto Fuel Campfire (BETA)"}
tbl21.Desc = nil
tbl21.Type = "Toggle"
tbl21.Default = false

function tbl21.Callback(arg1)
	autoBringEnabled = arg1
end

ToggleBring = tab3:Toggle(tbl21)

task.spawn(function()
	while true do
		if autoBringEnabled then
			camera.CFrame = camPos
			pool = {}

			for i = 1, #workspaceRef.Items:GetChildren() do
				item = workspaceRef.Items:GetChildren()[i]
				if item:IsA("Model") and selectedItems[item.Name] then
					pivot = item:GetPivot()
					if (pivot.Position - bringPos.Position).Magnitude > bringDistanceThreshold then
						table.insert(pool, item)
					end
				end
			end

			if #pool > 0 then
				tweenCount = math.max(1, math.floor(#pool * 0.5))
				local v1 = #pool

				for i1 = 1, v1 do
					if not autoBringEnabled then
						break
					end

					bringItem = pool[i1]

					if i1 <= tweenCount then
						pivot = bringItem:GetPivot()
						tween = TweenService:Create(hrp, TweenInfo.new(0.05, Enum.EasingStyle.Linear), {CFrame = pivot * CFrame.new(0, 3, 0)})
						tween:Play()
						tween.Completed:Wait()
					end

					startDrag:FireServer(bringItem)
					bringItem:PivotTo(bringPos)
					stopDrag:FireServer(bringItem)
				end
			end
		else
			task.wait(0.05)
		end
		task.wait()
	end
end)

Section = Tab:Section({
	Title = "Auto fuel (Insta)",
	Icon = "fuel",
	Box = true,
	FontWeight = Enum.FontWeight.SemiBold,
	TextTransparency = 0,
	HorizontalAlignment = Enum.HorizontalAlignment.Left,
	TextSize = 17,
	Opened = true,
})

local Players4 = game:GetService("Players")
local ReplicatedStorage5 = game:GetService("ReplicatedStorage")
local workspaceRef1 = workspace
local LocalPlayer5 = Players4.LocalPlayer;
(LocalPlayer5.Character or LocalPlayer5.CharacterAdded:Wait()):WaitForChild("HumanoidRootPart")
local RequestStartDraggingItem = ReplicatedStorage5:WaitForChild("RemoteEvents"):WaitForChild("RequestStartDraggingItem")
local StopDraggingItem = ReplicatedStorage5:WaitForChild("RemoteEvents"):WaitForChild("StopDraggingItem")
local tbl22 = {}
local flag10 = false
local cFrame = CFrame.new(0, 10, 0)

Tab:Dropdown({
	Title = "Select Fuel",
	Values = {
		"Log",
		"Chair",
		"Coal",
		"Fuel Canister",
		"Oil Barrel",
		"Wolf Corpse",
		"Alpha Wolf Corpse",
		"Bear Corpse",
		"Cultist Corpse",
	},
	Value = {},
	Multi = true,
	AllowNone = true,
	Callback = function(value)
		tbl22 = {}
		for _, v1 in ipairs(value) do
			tbl22[v1] = true
		end
	end,
})

local tab4 = Tab
local tbl23 = {Title = "Auto Fuel Campfire 2"}
tbl23.Desc = nil
tbl23.Type = "Toggle"
tbl23.Default = false

function tbl23.Callback(arg1)
	flag10 = arg1
end

tab4:Toggle(tbl23)

task.spawn(function()
	while true do
		if flag10 then
			for _, child in ipairs(workspaceRef1.Items:GetChildren()) do
				if child:IsA("Model") and tbl22[child.Name] then
					if (child:GetPivot().Position - cFrame.Position).Magnitude > 1 then
						RequestStartDraggingItem:FireServer(child)
						child:PivotTo(cFrame)
						StopDraggingItem:FireServer(child)
					end
				end
			end
		end
		task.wait(0.01)
	end
end)

Section = Tab:Section({
	Title = "Auto Shred Scrap (Uses Tween for godly advantage)",
	Icon = "cog",
	Box = true,
	FontWeight = Enum.FontWeight.SemiBold,
	TextTransparency = 0,
	HorizontalAlignment = Enum.HorizontalAlignment.Left,
	TextSize = 17,
	Opened = true,
})

local Players5 = game:GetService("Players")
local ReplicatedStorage6 = game:GetService("ReplicatedStorage")
TweenService = game:GetService("TweenService")
workspaceRef1 = workspace
local LocalPlayer6 = Players5.LocalPlayer
local HumanoidRootPart = (LocalPlayer6.Character or LocalPlayer6.CharacterAdded:Wait()):WaitForChild("HumanoidRootPart")
RequestStartDraggingItem = ReplicatedStorage6:WaitForChild("RemoteEvents"):WaitForChild("RequestStartDraggingItem")
StopDraggingItem = ReplicatedStorage6:WaitForChild("RemoteEvents"):WaitForChild("StopDraggingItem")
tbl22 = {}
flag10 = false
cFrame = CFrame.new(21, 14, -6)

Tab:Dropdown({
	Title = "Select Items",
	Values = {
		"Bolt",
		"Sheet Metal",
		"Broken Fan",
		"Old Radio",
		"Broken Microwave",
		"Tyre",
		"Metal Chair",
		"Old Car Engine",
		"Washing Machine",
		"Cultist Experiment",
		"Cultist Prototype",
	},
	Value = {},
	Multi = true,
	AllowNone = true,
	Callback = function(value)
		tbl22 = {}
		for i = 1, #value do
			tbl22[value[i]] = true
		end
	end,
})

local tab5 = Tab
local tbl24 = {Title = "Auto Shred Scrap"}
tbl24.Desc = nil
tbl24.Type = "Toggle"
tbl24.Default = false

function tbl24.Callback(arg1)
	flag10 = arg1
end

tab5:Toggle(tbl24)

function tweenToPosition(arg1)
	tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut)
	goal = {CFrame = arg1}
	tween = TweenService:Create(HumanoidRootPart, tweenInfo, goal)
	tween:Play()
	tween.Completed:Wait()
end

task.spawn(function()
	while true do
		if flag10 then
			items = workspaceRef1.Items:GetChildren()
			for i = 1, #items do
				item = items[i]
				if item:IsA("Model") and tbl22[item.Name] then
					pivot = item:GetPivot()
					if (pivot.Position - cFrame.Position).Magnitude > 15 then
						tweenToPosition(pivot * CFrame.new(0, 3, 0))
						RequestStartDraggingItem:FireServer(item)
						item:PivotTo(CFrame.new(cFrame.Position))
						StopDraggingItem:FireServer(item)
						task.wait(0.01)
					end
				end
			end
		end
		task.wait(0.01)
	end
end)

Section = Tab:Section({
	Title = "Auto Shred Scrap (Insta)",
	Icon = "cog",
	Box = true,
	FontWeight = Enum.FontWeight.SemiBold,
	TextTransparency = 0,
	HorizontalAlignment = Enum.HorizontalAlignment.Left,
	TextSize = 17,
	Opened = true,
})

local Players6 = game:GetService("Players")
local ReplicatedStorage7 = game:GetService("ReplicatedStorage")
workspaceRef1 = workspace
local LocalPlayer7 = Players6.LocalPlayer
HumanoidRootPart = (LocalPlayer7.Character or LocalPlayer7.CharacterAdded:Wait()):WaitForChild("HumanoidRootPart")
RequestStartDraggingItem = ReplicatedStorage7:WaitForChild("RemoteEvents"):WaitForChild("RequestStartDraggingItem")
StopDraggingItem = ReplicatedStorage7:WaitForChild("RemoteEvents"):WaitForChild("StopDraggingItem")
tbl22 = {}
flag10 = false
cFrame = CFrame.new(0, 10, 0)

Tab:Dropdown({
	Title = "Select Items",
	Values = {
		"Bolt",
		"Sheet Metal",
		"Broken Fan",
		"Old Radio",
		"Broken Microwave",
		"Tyre",
		"Metal Chair",
		"Old Car Engine",
		"Washing Machine",
		"Cultist Experiment",
		"Cultist Prototype",
		"Forest Gem",
	},
	Value = {},
	Multi = true,
	AllowNone = true,
	Callback = function(value)
		tbl22 = {}
		for i = 1, #value do
			tbl22[value[i]] = true
		end
	end,
})

local tab6 = Tab
local tbl25 = {Title = "Auto Shred Scrap"}
tbl25.Desc = nil
tbl25.Type = "Toggle"
tbl25.Default = false

function tbl25.Callback(arg1)
	flag10 = arg1
end

tab6:Toggle(tbl25)

task.spawn(function()
	while true do
		if flag10 then
			items = workspaceRef1.Items:GetChildren()
			for i = 1, #items do
				item = items[i]
				if item:IsA("Model") and tbl22[item.Name] then
					RequestStartDraggingItem:FireServer(item)
					item:PivotTo(cFrame)
					StopDraggingItem:FireServer(item)
				end
			end
		end
		task.wait(0.01)
	end
end)

Section = Tab:Section({
	Title = "Flowers",
	Icon = "flower-2",
	Box = true,
	FontWeight = Enum.FontWeight.SemiBold,
	TextTransparency = 0,
	HorizontalAlignment = Enum.HorizontalAlignment.Left,
	TextSize = 17,
	Opened = true,
})

local ReplicatedStorage8 = game:GetService("ReplicatedStorage")
wp = game:GetService("Workspace")
r = ReplicatedStorage8.RemoteEvents:WaitForChild("RequestPickFlower")
lm = wp.Map.Landmarks
autoPickEnabled = false
local tab7 = Tab
local tbl26 = {Title = "Auto Pick Flowers"}
tbl26.Desc = nil
tbl26.Type = "Toggle"
tbl26.Default = false

function tbl26.Callback(arg1)
	autoPickEnabled = arg1
end

TogglePickFlowers = tab7:Toggle(tbl26)

function pickFlower(arg1)
	pcall(function()
		r:InvokeServer(arg1)
	end)
end

function checkFlowers()
	if not autoPickEnabled then
		return
	end

	flowers = lm:GetDescendants()

	for i = 1, #flowers do
		f = flowers[i]
		if f.Name == "Flower" then
			pickFlower(f)
		end
	end
end

lm.DescendantAdded:Connect(function(descendant)
	if descendant.Name == "Flower" and autoPickEnabled then
		pickFlower(descendant)
	end
end)

task.spawn(function()
	while true do
		task.wait(0.3)
		checkFlowers()
	end
end)

checkFlowers()

Section = Tab:Section({
	Title = "Auto Collect Coin",
	Icon = "coins",
	Box = true,
	FontWeight = Enum.FontWeight.SemiBold,
	TextTransparency = 0,
	HorizontalAlignment = Enum.HorizontalAlignment.Left,
	TextSize = 17,
	Opened = true,
})

local Players7 = game:GetService("Players")
local ReplicatedStorage9 = game:GetService("ReplicatedStorage")
local Workspace2 = game:GetService("Workspace")
local HumanoidRootPart1

if Players7.LocalPlayer.Character then
	HumanoidRootPart1 = Players7.LocalPlayer.Character:WaitForChild("HumanoidRootPart")
end

Players7.LocalPlayer.CharacterAdded:Connect(function(character1)
	HumanoidRootPart1 = character1:WaitForChild("HumanoidRootPart")
end)

local RequestCollectCoints = ReplicatedStorage9.RemoteEvents:WaitForChild("RequestCollectCoints")
_G.autoCollectCoins = false

Tab:Toggle({
	Title = "Auto Collect Coins",
	Type = "Toggle",
	Default = false,
	Callback = function(value)
		_G.autoCollectCoins = value
	end,
})

task.spawn(function()
	while task.wait(0.2) do
		if _G.autoCollectCoins then
			for _, descendant in ipairs(Workspace2:GetDescendants()) do
				if descendant:IsA("Model") and descendant.Name:find("Coin Stack") then
					pcall(function()
						RequestCollectCoints:InvokeServer(descendant)
					end)
				end
			end
		end
	end
end)

Section = Tab:Section({
	Title = "Seed Box",
	Icon = "bean",
	Box = true,
	FontWeight = Enum.FontWeight.SemiBold,
	TextTransparency = 0,
	HorizontalAlignment = Enum.HorizontalAlignment.Left,
	TextSize = 17,
	Opened = true,
})

local tab8 = Tab
local tbl27 = {Title = "Auto Open Seed Box"}
tbl27.Desc = nil
tbl27.Icon = "leaf"
tbl27.Type = "Toggle"
tbl27.Default = false

function tbl27.Callback(autoOpenSeeds)
	getgenv().autoOpenSeeds = autoOpenSeeds
	if autoOpenSeeds then
		getgenv().autoOpenSeedsThread = task.spawn(function()
			local ReplicatedStorage = game:GetService("ReplicatedStorage")
			local Workspace1 = game:GetService("Workspace")
			local LocalPlayer = game:GetService("Players").LocalPlayer
			local v1 = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")

			LocalPlayer.CharacterAdded:Connect(function(character1)
				v1 = character1:WaitForChild("HumanoidRootPart")
			end)

			local RequestPlantSeeds = ReplicatedStorage:WaitForChild("RemoteEvents"):WaitForChild("RequestPlantSeeds")

			while getgenv().autoOpenSeeds and task.wait(0.5) do
				if v1 then
					for _, descendant in ipairs(Workspace1:GetDescendants()) do
						if descendant:IsA("Model") and descendant.Name:find("Seed Box") then
							RequestPlantSeeds:InvokeServer(descendant)
						end
					end
				end
			end
		end)
	elseif getgenv().autoOpenSeedsThread then
		task.cancel(getgenv().autoOpenSeedsThread)
		getgenv().autoOpenSeedsThread = nil
	end
end

tab8:Toggle(tbl27)

Section = Tab:Section({
	Title = "Crockpot",
	Icon = "cooking-pot",
	Box = true,
	FontWeight = Enum.FontWeight.SemiBold,
	TextTransparency = 0,
	HorizontalAlignment = Enum.HorizontalAlignment.Left,
	TextSize = 17,
	Opened = true,
})

local Players8 = game:GetService("Players")
local ReplicatedStorage10 = game:GetService("ReplicatedStorage")
WorkspaceItems = workspace:WaitForChild("Items")
StartDrag = ReplicatedStorage10:WaitForChild("RemoteEvents"):WaitForChild("RequestStartDraggingItem")
StopDrag = ReplicatedStorage10:WaitForChild("RemoteEvents"):WaitForChild("StopDraggingItem")
local LocalPlayer8 = Players8.LocalPlayer
HumanoidRootPart1 = LocalPlayer8.Character and LocalPlayer8.Character:FindFirstChild("HumanoidRootPart")

if not HumanoidRootPart1 then
	return
end

tbl22 = {"Carrot"}
toggleActive = false

Dropdown = Tab:Dropdown({
	Title = "Select Items",
	Values = {"Carrot", "Apple", "Morsel", "Cooked Morsel", "Steak", "Cooked Steak"},
	Value = {"Carrot"},
	Multi = true,
	AllowNone = true,
	Callback = function(value)
		tbl22 = value
	end,
})

Toggle = Tab:Toggle({
	Title = "Auto Crockpot",
	Desc = "Auto Make Stews Basically",
	Icon = "bird",
	Type = "Toggle",
	Default = false,
	Callback = function(value)
		toggleActive = value
		if value then
			task.spawn(function()
				while toggleActive do
					filteredItems = {}
					children = WorkspaceItems:GetChildren()

					for i = 1, #children do
						item = children[i]
						if table.find(tbl22, item.Name) then
							table.insert(filteredItems, item)
						end
					end

					for _ = 1, math.min(3, #filteredItems) do
						idx = math.random(1, #filteredItems)
						item = filteredItems[idx]
						table.remove(filteredItems, idx)
						part = item:IsA("Model") and (item.PrimaryPart or item:FindFirstChildWhichIsA("BasePart") or item:FindFirstChild("Handle")) or item

						if part then
							if item:IsA("Model") and not item.PrimaryPart then
								item.PrimaryPart = part
							end

							crockPot = workspace:FindFirstChild("Crock Pot")

							if crockPot and crockPot.PrimaryPart then
								StartDrag:FireServer(item)
								item:SetPrimaryPartCFrame(crockPot.PrimaryPart.CFrame)
								StopDrag:FireServer(item)
							end
						end
					end

					task.wait(10)
				end
			end)
		end
	end,
})

Section = Tab:Section({
	Title = "Meat",
	Icon = "ham",
	Box = true,
	FontWeight = Enum.FontWeight.SemiBold,
	TextTransparency = 0,
	HorizontalAlignment = Enum.HorizontalAlignment.Left,
	TextSize = 17,
	Opened = true,
})

local Players9 = game:GetService("Players")
local ReplicatedStorage11 = game:GetService("ReplicatedStorage")
WorkspaceItems = workspace:WaitForChild("Items")
StartDrag = ReplicatedStorage11:WaitForChild("RemoteEvents"):WaitForChild("RequestStartDraggingItem")
StopDrag = ReplicatedStorage11:WaitForChild("RemoteEvents"):WaitForChild("StopDraggingItem")
local LocalPlayer9 = Players9.LocalPlayer
HumanoidRootPart1 = LocalPlayer9.Character and LocalPlayer9.Character:FindFirstChild("HumanoidRootPart")

if not HumanoidRootPart1 then
	return
end

selectedItems2 = {"Morsel"}

Dropdown2 = Tab:Dropdown({
	Title = "Select Items to Bring Once",
	Values = {"Morsel", "Steak", "Ribs"},
	Value = {"Morsel"},
	Multi = true,
	AllowNone = true,
	Callback = function(value)
		selectedItems2 = value
	end,
})

Toggle2 = Tab:Toggle({
	Title = "Auto Cook Meat",
	Desc = "Auto Cooks Food basically yk meat",
	Icon = "bird",
	Type = "Toggle",
	Default = false,
	Callback = function(value)
		if value then
			filteredItems = {}
			children = WorkspaceItems:GetChildren()

			for i = 1, #children do
				item = children[i]
				if table.find(selectedItems2, item.Name) then
					table.insert(filteredItems, item)
				end
			end

			for i1 = 1, #filteredItems do
				item = filteredItems[i1]
				part = item:IsA("Model") and (item.PrimaryPart or item:FindFirstChildWhichIsA("BasePart") or item:FindFirstChild("Handle")) or item

				if part then
					if item:IsA("Model") and not item.PrimaryPart then
						item.PrimaryPart = part
					end

					targetPos = CFrame.new(0, 10, 0)
					StartDrag:FireServer(item)
					item:SetPrimaryPartCFrame(targetPos)
					StopDrag:FireServer(item)
				end
			end
		end
	end,
})

Section = Tab:Section({
	Title = "Auto Days",
	Icon = "cog",
	Box = true,
	FontWeight = Enum.FontWeight.SemiBold,
	TextTransparency = 0,
	HorizontalAlignment = Enum.HorizontalAlignment.Left,
	TextSize = 17,
	Opened = true,
})

local Players10 = game:GetService("Players")
Workspace2 = game:GetService("Workspace")
local LocalPlayer10 = Players10.LocalPlayer
local v3 = LocalPlayer10.Character or LocalPlayer10.CharacterAdded:Wait()
HumanoidRootPart1 = v3:WaitForChild("HumanoidRootPart")
baseplate = nil

BaseToggle = Tab:Toggle({
	Title = "Safe",
	Type = "Toggle",
	Default = false,
	Callback = function(value)
		if value then
			if baseplate then
				baseplate:Destroy()
			end

			baseplate = Instance.new("Part")
			baseplate.Size = Vector3.new(50, 50, 50)
			baseplate.Anchored = true
			baseplate.Position = Vector3.new(0, 6009, 0)
			baseplate.Material = Enum.Material.Grass
			baseplate.Color = Color3.fromRGB(0, 100, 0)
			baseplate.Name = "SafeZoneBaseplate"
			baseplate.Parent = Workspace2
			HumanoidRootPart1.CFrame = CFrame.new(baseplate.Position + Vector3.new(0, 5, 0))
		else
			if baseplate then
				baseplate:Destroy()
				baseplate = nil
			end
			HumanoidRootPart1.CFrame = CFrame.new(0, 10, 0)
		end
	end,
})

Section = Tab:Section({
	Title = "Circle Planting",
	Icon = "sprout",
	Box = true,
	FontWeight = Enum.FontWeight.SemiBold,
	TextTransparency = 0,
	HorizontalAlignment = Enum.HorizontalAlignment.Left,
	TextSize = 17,
	Opened = true,
})

getgenv().plantRadius = getgenv().plantRadius or 70
getgenv().plantCenterPos = Vector3.new(-2, 4, 0)
getgenv().lastCircleAngle = getgenv().lastCircleAngle or 0
getgenv().saplingGap = 2

Tab:Slider({
	Title = "Circle Planting Radius",
	Step = 1,
	Value = {Min = 70, Max = 300, Default = getgenv().plantRadius},
	Callback = function(value)
		local v1 = math.max(70, value)
		getgenv().plantRadius = v1
		getgenv().lastCircleAngle = 0
		print(" Circle radius updated to:", getgenv().plantRadius)
	end,
})

local tab9 = Tab
local tbl28 = {Title = "Plant Saplings in a Circle"}
tbl28.Desc = nil
tbl28.Locked = false

function tbl28.Callback()
	task.spawn(function()
		local Players = game:GetService("Players")
		local ReplicatedStorage = game:GetService("ReplicatedStorage")
		local Workspace1 = game:GetService("Workspace")
		local StarterGui = game:GetService("StarterGui")
		local Items = Workspace1:WaitForChild("Items")
		local RequestStartDraggingItem = ReplicatedStorage.RemoteEvents:WaitForChild("RequestStartDraggingItem")
		local StopDraggingItem = ReplicatedStorage.RemoteEvents:WaitForChild("StopDraggingItem")
		local RequestPlantItem = ReplicatedStorage.RemoteEvents:WaitForChild("RequestPlantItem")
		local plantRadius = getgenv().plantRadius
		local plantCenterPos = getgenv().plantCenterPos
		local saplingGap = getgenv().saplingGap
		local tbl = {}

		for _, child in ipairs(Items:GetChildren()) do
			if child.Name == "Sapling" and (child:IsA("Model") or child:IsA("BasePart")) then
				table.insert(tbl, child)
			end
		end

		if #tbl == 0 then
			StarterGui:SetCore("SendNotification", {Title = "SpamX Notification", Text = "No saplings found!", Duration = 4})
			return
		end

		local LocalPlayer = Players.LocalPlayer

		if not (LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")) then
			StarterGui:SetCore(
				"SendNotification",
				{Title = "SpamX Notification", Text = "Player character not found!", Duration = 4}
			)
			return
		end

		local tbl1 = {}

		for _, child1 in ipairs(Items:GetChildren()) do
			if child1.Name == "Sapling" and child1:IsA("Model") and child1.PrimaryPart then
				table.insert(tbl1, child1.PrimaryPart.Position)
			end
		end

		local lastCircleAngle = getgenv().lastCircleAngle

		for _, v1 in ipairs(tbl) do
			local v2 = 2 * math.asin(saplingGap / (2 * plantRadius))
			local v3 = plantCenterPos.X + math.cos(lastCircleAngle) * plantRadius
			local v4 = plantCenterPos.Z + math.sin(lastCircleAngle) * plantRadius
			local vector3 = Vector3.new(v3, plantCenterPos.Y, v4)
			local flag = false

			for _, v5 in ipairs(tbl1) do
				if (vector3 - v5).Magnitude < saplingGap then
					flag = true
					break
				end
			end

			if flag then
				lastCircleAngle = lastCircleAngle + v2
			else
				local v6 = v1:IsA("Model")

-- https://lua-x.online
				if v6 then
					v6 = v1.PrimaryPart
					v6 = v6 or v1:FindFirstChildWhichIsA("BasePart")
					v6 = v6 or v1:FindFirstChild("Handle")
				end

				v6 = v6 or v1

				if v6 then
					if v1:IsA("Model") and not v1.PrimaryPart then
						pcall(function()
							v1.PrimaryPart = v6
						end)
					end
					pcall(function()
						RequestStartDraggingItem:FireServer(v1)
						v1:SetPrimaryPartCFrame(CFrame.new(vector3))
						RequestPlantItem:InvokeServer(v1, vector3)
						StopDraggingItem:FireServer(v1)
					end)
				end

				table.insert(tbl1, vector3)
				lastCircleAngle = lastCircleAngle + v2
				getgenv().lastCircleAngle = lastCircleAngle
				task.wait(0.1)
			end
		end

		StarterGui:SetCore(
			"SendNotification",
			{Title = "SpamX Notification", Text = "All Saplings Planted in Circle", Duration = 4}
		)
	end)
end

tab9:Button(tbl28)
Tab = Window:Tab({Title = "Fun Features", Icon = "play", Locked = false})

Button = Tab:Button({
	Title = "Teleport All Trees To You",
	Desc = "A button to basically teleport all the trees next to you!",
	Locked = false,
	Callback = function()
		Players10 = game:GetService("Players")
		Workspace2 = game:GetService("Workspace")
		LocalPlayer4 = Players10.LocalPlayer
		v3 = LocalPlayer4.Character or LocalPlayer4.CharacterAdded:Wait()
		HumanoidRootPart1 = v3:WaitForChild("HumanoidRootPart")
		frontPos = HumanoidRootPart1.Position + HumanoidRootPart1.CFrame.LookVector * 10

		for _, descendant in pairs(Workspace2:GetDescendants()) do
			if descendant:IsA("Model") and descendant.Name == "Small Tree" then
				if not descendant.PrimaryPart then
					base = descendant:FindFirstChildWhichIsA("BasePart")
					if base then
						descendant.PrimaryPart = base
					else
						continue
					end
				end
				descendant:SetPrimaryPartCFrame(CFrame.new(frontPos))
			end
		end
	end,
})

Button = Tab:Button({
	Title = "Teleport All Big Trees To You",
	Desc = "a button to basically teleport all big trees next to you",
	Locked = false,
	Callback = function()
		Players10 = game:GetService("Players")
		Workspace2 = game:GetService("Workspace")
		LocalPlayer4 = Players10.LocalPlayer
		v3 = LocalPlayer4.Character or LocalPlayer4.CharacterAdded:Wait()
		HumanoidRootPart1 = v3:WaitForChild("HumanoidRootPart")
		frontPos = HumanoidRootPart1.Position + HumanoidRootPart1.CFrame.LookVector * 10

		for _, descendant in pairs(Workspace2:GetDescendants()) do
			if descendant:IsA("Model") and string.find(descendant.Name, "TreeBig") then
				if not descendant.PrimaryPart then
					base = descendant:FindFirstChildWhichIsA("BasePart")
					if base then
						descendant.PrimaryPart = base
					else
						continue
					end
				end
				descendant:SetPrimaryPartCFrame(CFrame.new(frontPos))
			end
		end
	end,
})

Button_BringSnowyTrees = Tab:Button({
	Title = "Bring Snowy Small Tree Infront Of You",
	Desc = "A button to basically bring all snowy Small trees next to you",
	Locked = false,
	Callback = function()
		LocalPlayer4 = game:GetService("Players").LocalPlayer
		char = LocalPlayer4.Character or LocalPlayer4.CharacterAdded:Wait()
		HumanoidRootPart1 = char:WaitForChild("HumanoidRootPart")
		frontPos = HumanoidRootPart1.Position + HumanoidRootPart1.CFrame.LookVector * 10
		Workspace2 = game:GetService("Workspace")
		allDescendants = Workspace2:GetDescendants()

		for i = 1, #allDescendants do
			model = allDescendants[i]
			if model:IsA("Model") and model.Name == "Snowy Small Tree" then
				part = model.PrimaryPart or model:FindFirstChildWhichIsA("BasePart")
				if part then
					model.PrimaryPart = part
					model:SetPrimaryPartCFrame(CFrame.new(frontPos))
				end
			end
		end
	end,
})

Section = Tab:Section({
	Title = "Freeze",
	Icon = "snowflake",
	Box = true,
	FontWeight = Enum.FontWeight.SemiBold,
	TextTransparency = 0,
	HorizontalAlignment = Enum.HorizontalAlignment.Left,
	TextSize = 17,
	Opened = true,
})

workspaceCharacters = workspace:WaitForChild("Characters")

FreezeToggle = Tab:Toggle({
	Title = "Freeze All Enemies/Animal",
	Desc = "A Toggle To Basically Freeze All Enemies Or Animals Like Time Stop",
	Icon = "snowflake",
	Type = "Toggle",
	Default = false,
	Callback = function(value)
		children = workspaceCharacters:GetChildren()
		for i = 1, #children do
			model = children[i]
			if model:IsA("Model") then
				parts = model:GetDescendants()
				for i1 = 1, #parts do
					part = parts[i1]
					if part:IsA("BasePart") then
						part.Anchored = value
					end
				end
			end
		end
	end,
})

Section = Tab:Section({
	Title = "Chests",
	Icon = "package",
	Box = true,
	FontWeight = Enum.FontWeight.SemiBold,
	TextTransparency = 0,
	HorizontalAlignment = Enum.HorizontalAlignment.Left,
	TextSize = 17,
	Opened = true,
})

Button_BringChests = Tab:Button({
	Title = "Bring All Chests",
	Desc = "Brings all Chests basically like Volcanic Chest and Item Chest!",
	Locked = false,
	Callback = function()
		Players10 = game:GetService("Players")
		Workspace2 = game:GetService("Workspace")
		LocalPlayer4 = Players10.LocalPlayer
		v3 = LocalPlayer4.Character or LocalPlayer4.CharacterAdded:Wait()
		HumanoidRootPart1 = v3:WaitForChild("HumanoidRootPart")
		frontPos = HumanoidRootPart1.Position + HumanoidRootPart1.CFrame.LookVector * 10

		for _, descendant in pairs(Workspace2:GetDescendants()) do
			if descendant:IsA("Model") and (string.find(descendant.Name, "Item Chest") or string.find(descendant.Name, "Volcanic")) then
				part = descendant.PrimaryPart or descendant:FindFirstChildWhichIsA("BasePart")
				if part then
					descendant.PrimaryPart = part
					descendant:SetPrimaryPartCFrame(CFrame.new(frontPos))
				end
			end
		end
	end,
})

Section = Tab:Section({
	Title = "Kids Alternative",
	Icon = "baby",
	Box = true,
	FontWeight = Enum.FontWeight.SemiBold,
	TextTransparency = 0,
	HorizontalAlignment = Enum.HorizontalAlignment.Left,
	TextSize = 17,
	Opened = true,
})

SelectedKid = "DinoKid"

Dropdown = Tab:Dropdown({
	Title = "Select Kid Type",
	Values = {"DinoKid", "KrakenKid", "SquidKid", "KoalaKid"},
	Value = "DinoKid",
	Callback = function(value)
		SelectedKid = value
	end,
})

Button = Tab:Button({
	Title = "Bring Kid To You",
	Desc = "Brings the selected kid in front of you",
	Locked = false,
	Callback = function()
		if not SelectedKid then
			print("[TY hub] No kid selected!")
			return
		end

		local Players = game:GetService("Players")
		local Workspace1 = game:GetService("Workspace")
		local LocalPlayer = Players.LocalPlayer

		if not LocalPlayer then
			return
		end

		local v1 = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()

		if not v1 then
			return
		end

		local HumanoidRootPart = v1:FindFirstChild("HumanoidRootPart")

		if not HumanoidRootPart then
			local HumanoidRootPart1 = v1:WaitForChild("HumanoidRootPart", 5)
			HumanoidRootPart = HumanoidRootPart1

			if not HumanoidRootPart1 then
				return
			end
		end

		local v2 = HumanoidRootPart.Position + HumanoidRootPart.CFrame.LookVector * 10
		local flag = false
		local Descendants = Workspace1:GetDescendants()

		for i = 1, #Descendants do
			local v3 = Descendants[i]
			if v3:IsA("Model") and string.find(v3.Name, SelectedKid) then
				local v4 = v3.PrimaryPart or v3:FindFirstChildWhichIsA("BasePart")
				if v4 then
					v3.PrimaryPart = v4

					pcall(function()
						v3:SetPrimaryPartCFrame(CFrame.new(v2))
					end)

					flag = true
					print("[TY hub] Brought " .. SelectedKid .. " to you!")
					break
				end
			end
		end

		if not flag then
			print("[TY hub] Could not find " .. SelectedKid .. " in the world!")
		end
	end,
})

Section = Tab:Section({
	Title = "Summon Map",
	Icon = "map",
	Box = true,
	FontWeight = Enum.FontWeight.SemiBold,
	TextTransparency = 0,
	HorizontalAlignment = Enum.HorizontalAlignment.Left,
	TextSize = 17,
	Opened = true,
})

Tab:Button({
	Title = "Teleport to Steal A Brainrot Map",
	Callback = function()
		local Players = game:GetService("Players")
		local Workspace1 = game:GetService("Workspace")
		local LocalPlayer = Players.LocalPlayer

		if not LocalPlayer then
			return
		end

		local vector3 = Vector3.new(0, 6388, 0)
		local vector31 = Vector3.new(0, 20, 0)

		local function func(player1, arg2)
			local v1 = arg2 or 10
			local v2 = tick()

			while tick() - v2 <= v1 do
				local Character1 = player1.Character

				if Character1 and Character1.Parent then
					return Character1
				end

				task.wait(0.05)
			end

			return player1.Character
		end

		local function func1(arg1)
			local tbl = {}
			local vector3 = Vector3.new(0, 0, 0)
			local num = 0

			for _, descendant in ipairs(arg1:GetDescendants()) do
				if descendant:IsA("BasePart") then
					num = num + 1
					vector3 = vector3 + descendant.Position
					tbl[#tbl + 1] = descendant
				end
			end

			if num == 0 then
				return tbl, nil
			end

			return tbl, vector3 / num
		end

		local function func2(arg1, arg2)
			local _, v1 = func1(arg1)
			local v2 = v1

			if not v2 then
				if typeof(arg1.GetPivot) == "function" then
					local ok, result = pcall(function()
						return arg1:GetPivot()
					end)
					if ok and result then
						v2 = result.Position
					end
				end
			end

			if not v2 then
				return false
			end

			pcall(function()
				arg2.CFrame = CFrame.new(v2 + vector31)
			end)

			return true
		end

		local v1 = func(LocalPlayer, 10)

		if not v1 then
			return
		end

		local v2 = v1:FindFirstChild("HumanoidRootPart") or v1:FindFirstChild("Torso") or v1:FindFirstChild("UpperTorso")

		if not v2 then
			return
		end

		local __LOADED_MODEL_96439444595951 = Workspace1:FindFirstChild("__LOADED_MODEL_96439444595951")

		if __LOADED_MODEL_96439444595951 and __LOADED_MODEL_96439444595951.Parent then
			if pcall(function()
				if not func2(__LOADED_MODEL_96439444595951, v2) then
					error("Teleport failed.")
				end
			end) then
				return
			end
		end

		local ok, result = pcall(function()
			return game:GetObjects("rbxassetid://96439444595951")[1]
		end)

		if not ok or not result then
			return
		end

		result.Name = "__LOADED_MODEL_96439444595951"
		result.Parent = Workspace1
		local v3, v4 = func1(result)

		if v4 then
			local v5 = vector3 - v4
			local tbl = {}

			for _, v6 in ipairs(v3) do
				tbl[v6] = v6.Anchored
				v6.Anchored = true
				v6.CFrame = v6.CFrame + v5
			end

			for k, v7 in pairs(tbl) do
				if k and k.Parent then
					k.Anchored = v7
				end
			end
		else
			local flag = false

			pcall(function()
				if typeof(result.PivotTo) == "function" then
					result:PivotTo(CFrame.new(vector3))
					flag = true
				end
			end)

			if not flag then
				for _, descendant in ipairs(result:GetDescendants()) do
					if descendant:IsA("BasePart") then
						pcall(function()
							result.PrimaryPart = descendant
						end)
						break
					end
				end
				pcall(function()
					if result.PrimaryPart then
						result:SetPrimaryPartCFrame(CFrame.new(vector3))
						flag = true
					end
				end)
			end
		end

		func2(result, v2)
	end,
})

local Players11 = game:GetService("Players")
local Workspace3 = game:GetService("Workspace")
local LocalPlayer11 = Players11.LocalPlayer

if not LocalPlayer11 then
	return
end

local vector31 = Vector3.new(0, 65782, 0)
local vector32 = Vector3.new(0, 20, 0)

local function func13(player1, arg2)
	local v1 = tick()

	while tick() - v1 <= (arg2 or 10) do
		if player1.Character and player1.Character.Parent then
			return player1.Character
		end
		task.wait(0.05)
	end

	return player1.Character
end

local function func14(arg1)
	local tbl = {}
	local vector3 = Vector3.new()
	local num = 0

	for _, descendant in ipairs(arg1:GetDescendants()) do
		if descendant:IsA("BasePart") then
			num = num + 1
			vector3 = vector3 + descendant.Position
			tbl[#tbl + 1] = descendant
		end
	end

	return tbl, num > 0 and vector3 / num or nil
end

local function func15(arg1, arg2)
	local _, v1 = func14(arg1)
	local v2 = v1

	if not v2 then
		if typeof(arg1.GetPivot) == "function" then
			local ok, result = pcall(function()
				return arg1:GetPivot()
			end)
			if ok and result then
				v2 = result.Position
			end
		end
	end

	if v2 then
		pcall(function()
			arg2.CFrame = CFrame.new(v2 + vector32)
		end)
	end
end

local function func16()
	local v1 = func13(LocalPlayer11, 10)

	if not v1 then
		return
	end

	local v2 = v1:FindFirstChild("HumanoidRootPart") or v1:FindFirstChild("Torso") or v1:FindFirstChild("UpperTorso")

	if not v2 then
		return
	end

	local __LOADED_MODEL_105019154044298 = Workspace3:FindFirstChild("__LOADED_MODEL_105019154044298")

	if __LOADED_MODEL_105019154044298 then
		func15(__LOADED_MODEL_105019154044298, v2)
		return
	end

	local ok, result = pcall(function()
		return game:GetObjects("rbxassetid://105019154044298")[1]
	end)

	if not ok or not result then
		return
	end

	result.Name = "__LOADED_MODEL_105019154044298"
	result.Parent = Workspace3
	local v3, v4 = func14(result)

	if v4 then
		local v5 = vector31 - v4
		local tbl = {}

		for _, v6 in ipairs(v3) do
			tbl[v6] = v6.Anchored
			v6.Anchored = true
			v6.CFrame = v6.CFrame + v5
		end

		for k, v7 in pairs(tbl) do
			if k and k.Parent then
				k.Anchored = v7
			end
		end
	else
		pcall(function()
			if typeof(result.PivotTo) == "function" then
				result:PivotTo(CFrame.new(vector31))
			elseif result.PrimaryPart then
				result:SetPrimaryPartCFrame(CFrame.new(vector31))
			else
				for _, descendant in ipairs(result:GetDescendants()) do
					if descendant:IsA("BasePart") then
						result.PrimaryPart = descendant
						result:SetPrimaryPartCFrame(CFrame.new(vector31))
						break
					end
				end
			end
		end)
	end

	func15(result, v2)
end

Tab:Button({
	Title = "Teleport to Grow A Garden",
	Desc = "Teleport to Grow a gArden ahah",
	Callback = function()
		task.spawn(func16)
	end,
})

Tab:Button({
	Title = "Teleport to Prison Life",
	Callback = function()
		local Players = game:GetService("Players")
		local Workspace1 = game:GetService("Workspace")
		local LocalPlayer = Players.LocalPlayer

		if not LocalPlayer then
			return
		end

		local vector3 = Vector3.new(0, 67379, 127)
		local vector31 = Vector3.new(0, 20, 0)

		local function func(player1, arg2)
			local v1 = tick()

			while tick() - v1 <= (arg2 or 10) do
				if player1.Character and player1.Character.Parent then
					return player1.Character
				end
				task.wait(0.05)
			end

			return player1.Character
		end

		local function func1(arg1)
			local tbl = {}
			local vector3 = Vector3.new()
			local num = 0

			for _, descendant in ipairs(arg1:GetDescendants()) do
				if descendant:IsA("BasePart") then
					num = num + 1
					vector3 = vector3 + descendant.Position
					tbl[#tbl + 1] = descendant
				end
			end

			return tbl, num > 0 and vector3 / num or nil
		end

		local function func2(arg1, arg2)
			local _, v1 = func1(arg1)
			local v2 = v1

			if not v2 then
				if typeof(arg1.GetPivot) == "function" then
					local ok, result = pcall(function()
						return arg1:GetPivot()
					end)
					if ok and result then
						v2 = result.Position
					end
				end
			end

			if v2 then
				pcall(function()
					arg2.CFrame = CFrame.new(v2 + vector31)
				end)
			end
		end

		local v1 = func(LocalPlayer, 10)

		if not v1 then
			return
		end

		local v2 = v1:FindFirstChild("HumanoidRootPart") or v1:FindFirstChild("Torso") or v1:FindFirstChild("UpperTorso")

		if not v2 then
			return
		end

		local __LOADED_MODEL_13820453861 = Workspace1:FindFirstChild("__LOADED_MODEL_13820453861")

		if __LOADED_MODEL_13820453861 then
			func2(__LOADED_MODEL_13820453861, v2)
			return
		end

		local ok, result = pcall(function()
			return game:GetObjects("rbxassetid://13820453861")[1]
		end)

		if not ok or not result then
			return
		end

		result.Name = "__LOADED_MODEL_13820453861"
		result.Parent = Workspace1
		local v3, v4 = func1(result)

		if v4 then
			local v5 = vector3 - v4
			local tbl = {}

			for _, v6 in ipairs(v3) do
				tbl[v6] = v6.Anchored
				v6.Anchored = true
				v6.CFrame = v6.CFrame + v5
			end

			for k, v7 in pairs(tbl) do
				if k and k.Parent then
					k.Anchored = v7
				end
			end
		else
			pcall(function()
				if typeof(result.PivotTo) == "function" then
					result:PivotTo(CFrame.new(vector3))
				elseif result.PrimaryPart then
					result:SetPrimaryPartCFrame(CFrame.new(vector3))
				else
					for _, descendant in ipairs(result:GetDescendants()) do
						if descendant:IsA("BasePart") then
							result.PrimaryPart = descendant
							result:SetPrimaryPartCFrame(CFrame.new(vector3))
							break
						end
					end
				end
			end)
		end

		func2(result, v2)
	end,
})

Tab = Window:Tab({Title = "Bring Stuff", Icon = "maximize-2", Locked = false})
local Players12 = game:GetService("Players")
RS = game:GetService("ReplicatedStorage")
WorkspaceItems = workspace:WaitForChild("Items")
TweenService = game:GetService("TweenService")
StartDrag = RS:WaitForChild("RemoteEvents"):WaitForChild("RequestStartDraggingItem")
StopDrag = RS:WaitForChild("RemoteEvents"):WaitForChild("StopDraggingItem")
LP = Players12.LocalPlayer
HRP = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")

LP.CharacterAdded:Connect(function(character1)
	HRP = character1:WaitForChild("HumanoidRootPart")
end)

TargetCFrame = "Myself"
BringSpeed = "Instant"
BringCount = 1
BringCooldown = 0.1

function GetTargetCFrame(name)
	if name == "Myself" then
		return HRP.CFrame
	end

	if name == "Fire" then
		return CFrame.new(0, 10, 0)
	end

	if name == "Workbench" then
		return CFrame.new(21, 14, -5)
	end

	local v1 = Players12:FindFirstChild(name)

	if v1 and v1.Character and v1.Character:FindFirstChild("HumanoidRootPart") then
		return v1.Character.HumanoidRootPart.CFrame
	end

	return HRP.CFrame
end

function BringItems(arg1)
	origCFrame = HRP.CFrame
	count = tonumber(BringCount) or 1
	cooldown = tonumber(BringCooldown) or 0.1

	for _, v1 in ipairs(arg1) do
		itemsBrought = 0
		for _, child in ipairs(WorkspaceItems:GetChildren()) do
			if itemsBrought >= count then
				break
			end
			if child.Name == v1 then
				part = child:IsA("Model") and (child.PrimaryPart or child:FindFirstChildWhichIsA("BasePart") or child:FindFirstChild("Handle")) or child
				if part then
					if child:IsA("Model") and not child.PrimaryPart then
						pcall(function()
							child.PrimaryPart = part
						end)
					end

					pcall(function()
						StartDrag:FireServer(child)
						targetCF = GetTargetCFrame(TargetCFrame)

						if BringSpeed == "Tween" then
							info = TweenInfo.new(0.2, Enum.EasingStyle.Linear)
							TweenService:Create(HRP, info, {CFrame = part.CFrame + Vector3.new(0, 3, 0)}):Play()
							task.wait(0.2)
						end

						if child:IsA("Model") then
							child:SetPrimaryPartCFrame(targetCF)
						else
							part.CFrame = targetCF
						end

						if BringSpeed == "Tween" then
							HRP.CFrame = origCFrame
						end

						StopDrag:FireServer(child)
					end)

					itemsBrought = itemsBrought + 1
					task.wait(cooldown)
				end
			end
		end
	end
end

function GetPlayerList()
	list = {"Myself", "Fire", "Workbench"}

	for _, player1 in ipairs(Players12:GetPlayers()) do
		if player1 ~= LP then
			table.insert(list, player1.Name)
		end
	end

	return list
end

Tab:Dropdown({
	Title = "Select Target",
	Values = GetPlayerList(),
	Value = "Myself",
	Multi = false,
	Callback = function(value)
		TargetCFrame = value
	end,
})

Tab:Dropdown({
	Title = "Bring Speed",
	Values = {"Instant", "Tween"},
	Value = "Instant",
	Multi = false,
	Callback = function(value)
		BringSpeed = value
	end,
})

Tab:Input({
	Title = "Item Count",
	Value = "1",
	Callback = function(value)
		BringCount = tonumber(value) or 1
	end,
})

Tab:Input({
	Title = "Bring Cooldown",
	Value = "0.1",
	Callback = function(value)
		BringCooldown = tonumber(value) or 0.1
	end,
})

Tab:Section({
	Title = "Bring Fuel",
	Box = false,
	FontWeight = Enum.FontWeight.SemiBold,
	TextTransparency = 0,
	HorizontalAlignment = Enum.HorizontalAlignment.Left,
	TextSize = 17,
	Opened = true,
})

Tab:Dropdown({
	Title = "Select Fuel Items",
	Values = {
		"Sapling",
		"Log",
		"Chair",
		"Fuel Canister",
		"Oil Barrel",
		"Biofuel",
		"Cultist Corpse",
		"Crossbow Cultist Corpse",
		"Juggernaut Cultist Corpse",
		"Wolf Corpse",
		"Alpha Wolf Corpse",
		"Bear Corpse",
	},
	Value = {"Sapling"},
	Multi = true,
	Callback = function(value)
		FuelSelected = value
	end,
})

Tab:Button({
	Title = "Bring Fuel Items",
	Callback = function()
		BringItems(FuelSelected or {"Sapling"})
	end,
})

Tab:Button({
	Title = "Bring All Logs",
	Callback = function()
		BringItems({"Log"})
	end,
})

Tab:Section({
	Title = "Bring Scraps",
	Box = false,
	FontWeight = Enum.FontWeight.SemiBold,
	TextTransparency = 0,
	HorizontalAlignment = Enum.HorizontalAlignment.Left,
	TextSize = 17,
	Opened = true,
})

Tab:Dropdown({
	Title = "Select Scrap Items",
	Values = {
		"Bolt",
		"Sheet Metal",
		"Broken Fan",
		"Old Radio",
		"Metal Chair",
		"Old Microwave",
		"Tyre",
		"Old Car Engine",
		"Washing Machine",
		"Cultist Prototype",
		"Cultist Experiment",
		"Cultist Gem",
		"Forest Gem",
	},
	Value = {"Bolt"},
	Multi = true,
	Callback = function(value)
		ScrapsSelected = value
	end,
})

Tab:Button({
	Title = "Bring Scraps",
	Callback = function()
		BringItems(ScrapsSelected or {"Bolt"})
	end,
})

Tab:Section({
	Title = "Bring Food",
	Box = false,
	FontWeight = Enum.FontWeight.SemiBold,
	TextTransparency = 0,
	HorizontalAlignment = Enum.HorizontalAlignment.Left,
	TextSize = 17,
	Opened = true,
})

Tab:Dropdown({
	Title = "Select Food Items",
	Values = {
		"Carrot",
		"Berry",
		"Chili",
		"Bandage",
		"Medkit",
		"Morsel",
		"Steak",
		"Cooked Morsel",
		"Cooked Steak",
		"Morsel?",
		"Cake",
		"Stew",
		"Hearty Stew",
		"Ribs",
		"Cooked Ribs",
		"Carrot Cake",
		"BBQ Ribs",
	},
	Value = {"Carrot"},
	Multi = true,
	Callback = function(value)
		FoodSelected = value
	end,
})

Tab:Button({
	Title = "Bring Food",
	Callback = function()
		BringItems(FoodSelected or {"Carrot"})
	end,
})

Tab:Section({
	Title = "Bring Tools",
	Box = false,
	FontWeight = Enum.FontWeight.SemiBold,
	TextTransparency = 0,
	HorizontalAlignment = Enum.HorizontalAlignment.Left,
	TextSize = 17,
	Opened = true,
})

Tab:Dropdown({
	Title = "Select Tools",
	Values = {
		"Good Axe",
		"Strong Axe",
		"Good Sack",
		"Giant Sack",
		"Infernal Sack",
		"Old flashlight",
		"Strong Flashlight",
		"Ice Axe",
		"Chainsaw",
	},
	Value = {"Good Axe"},
	Multi = true,
	Callback = function(value)
		ToolsSelected = value
	end,
})

Tab:Button({
	Title = "Bring Tools",
	Callback = function()
		BringItems(ToolsSelected or {"Good Axe"})
	end,
})

Tab:Section({
	Title = "Bring Armor & Melee",
	Box = false,
	FontWeight = Enum.FontWeight.SemiBold,
	TextTransparency = 0,
	HorizontalAlignment = Enum.HorizontalAlignment.Left,
	TextSize = 17,
	Opened = true,
})

Tab:Dropdown({
	Title = "Select Armor/Melee",
	Values = {
		"Spear",
		"Katana",
		"Morningstar",
		"Blowpipe",
		"Laser Sword",
		"Ice Sword",
		"Poison Spear",
		"Infernal Sword",
		"Cultist King Mace",
		"Obsidiron Hammer",
		"Leather Body",
		"Iron Body",
		"Thorn Body",
		"Poison Armor",
		"Alien Armor",
		"Obsidiron Body",
		"Riot Shield",
	},
	Value = {"Spear"},
	Multi = true,
	Callback = function(value)
		ArmorSelected = value
	end,
})

Tab:Button({
	Title = "Bring Armor/Melee",
	Callback = function()
		BringItems(ArmorSelected or {"Spear"})
	end,
})

Tab:Section({
	Title = "Bring Ranged Weapons & Ammo",
	Box = false,
	FontWeight = Enum.FontWeight.SemiBold,
	TextTransparency = 0,
	HorizontalAlignment = Enum.HorizontalAlignment.Left,
	TextSize = 17,
	Opened = true,
})

Tab:Dropdown({
	Title = "Select Ranged Items",
	Values = {
		"Revolver",
		"Rifle",
		"Tactical Shotgun",
		"Revolver Ammo",
		"Rifle Ammo",
		"Shotgun Ammo",
		"Snowball",
		"Kunai",
		"Frozen Shuriken",
		"Wildfire",
		"Crossbow",
		"Infernal Crossbow",
		"Flamethrower",
		"Raygun",
		"Laser Cannon",
	},
	Value = {"Revolver"},
	Multi = true,
	Callback = function(value)
		RangedSelected = value
	end,
})

Tab:Button({
	Title = "Bring Ranged Items",
	Callback = function()
		BringItems(RangedSelected or {"Revolver"})
	end,
})

Tab:Section({
	Title = "Bring Other Items",
	Box = false,
	FontWeight = Enum.FontWeight.SemiBold,
	TextTransparency = 0,
	HorizontalAlignment = Enum.HorizontalAlignment.Left,
	TextSize = 17,
	Opened = true,
})

Tab:Dropdown({
	Title = "Select Other Items",
	Values = {
		"Seed Box",
		"Wolf Pelt",
		"Alpha Wolf Pelt",
		"Bear Pelt",
		"Artic Fox Pelt",
		"Polar Bear Pelt",
		"Mammoth Tusk",
		"Scorpion Shell",
		"Cultist King Antler",
		"FrogKey",
		"Hammer",
		"Paint Brush",
		"Forest Gem Fragment",
		"Mossy coin",
		"Coin Stack",
		"Sacrifice Totem",
		"Meteor Shard",
		"Gold Shard",
		"Obsidiron Ingot",
		"RedKey",
		"BlueKey",
		"YellowKey",
		"GreyKey",
		"Anvil Front",
		"Anvil Back",
		"Anvil Base",
	},
	Value = {"Seed Box"},
	Multi = true,
	Callback = function(value)
		OtherSelected = value
	end,
})

Tab:Button({
	Title = "Bring Other Items",
	Callback = function()
		BringItems(OtherSelected or {"Seed Box"})
	end,
})

Tab = Window:Tab({Title = "Hitbox/Aimbot", Icon = "expand", Locked = false})
Players12 = game:GetService("Players")
Workspace3 = game:GetService("Workspace")
local RunService2 = game:GetService("RunService")
HitboxStudSize = 30
HitboxEnabled = false
ShowHitboxes = false

Tab:Slider({
	Title = "Hitbox Size (Studs)",
	Value = {Min = 10, Max = 150, Default = 30},
	Step = 5,
	Callback = function(value)
		HitboxStudSize = value
	end,
})

Tab:Toggle({
	Title = "Enable Expanded Hitboxes",
	Default = false,
	Callback = function(value)
		HitboxEnabled = value
	end,
})

Tab:Toggle({
	Title = "Show Hitboxes",
	Default = false,
	Callback = function(value)
		ShowHitboxes = value
	end,
})

function CreateHitbox(parent)
	local part1 = Instance.new("Part")
	part1.Name = "NiggaEriCShitBox"
	part1.Anchored = true
	part1.CanCollide = false
	part1.Material = Enum.Material.Neon
	part1.Color = Color3.fromRGB(255, 60, 60)
	part1.Size = Vector3.new(HitboxStudSize, HitboxStudSize, HitboxStudSize)
	part1.Transparency = ShowHitboxes and 0.4 or 1
	part1.Parent = parent
	return part1
end

RunService2.RenderStepped:Connect(function()
	if not Workspace3:FindFirstChild("Characters") then
		return
	end
	for _, child in ipairs(Workspace3.Characters:GetChildren()) do
		if child:IsA("Model") then
			local HumanoidRootPart = child:FindFirstChild("HumanoidRootPart")
			if HumanoidRootPart then
				local NiggaEriCShitBox = child:FindFirstChild("NiggaEriCShitBox")
				if HitboxEnabled then
					NiggaEriCShitBox = NiggaEriCShitBox or CreateHitbox(child)
					NiggaEriCShitBox.Size = Vector3.new(HitboxStudSize, HitboxStudSize, HitboxStudSize)
					NiggaEriCShitBox.Transparency = ShowHitboxes and 0.4 or 1
					NiggaEriCShitBox.CFrame = HumanoidRootPart.CFrame
				elseif NiggaEriCShitBox then
					NiggaEriCShitBox:Destroy()
				end
			end
		end
	end
end)

Section = Tab:Section({
	Title = "Aimbot",
	Icon = "crosshair",
	Box = true,
	FontWeight = Enum.FontWeight.SemiBold,
	TextTransparency = 0,
	HorizontalAlignment = Enum.HorizontalAlignment.Left,
	TextSize = 17,
	Opened = true,
})

local tab10 = Tab
local tbl29 = {Title = "Silent Aimbot Coming Soon"}
tbl29.Desc = nil
tbl29.Locked = false

function tbl29.Callback()
end

Button = tab10:Button(tbl29)
Tab = Window:Tab({Title = "Taming/Fishing", Icon = "fish-symbol", Locked = false})
SuccessAreaTallEnabled = false

Tab:Toggle({
	Title = "100% Success Tame",
	Default = false,
	Callback = function(value)
		SuccessAreaTallEnabled = value
	end,
})

game:GetService("RunService").RenderStepped:Connect(function()
	if SuccessAreaTallEnabled then
		local LocalPlayer = game.Players.LocalPlayer

		if not LocalPlayer then
			return
		end

		local Interface = LocalPlayer.PlayerGui:FindFirstChild("Interface")

		if not Interface then
			return
		end

		local TamingFluteFrame = Interface:FindFirstChild("TamingFluteFrame")

		if not TamingFluteFrame or not TamingFluteFrame.Visible then
			return
		end

		local TimingBar = TamingFluteFrame:FindFirstChild("TimingBar")

		if not TimingBar then
			return
		end

		local SuccessArea = TimingBar:FindFirstChild("SuccessArea")

		if SuccessArea then
			local X = SuccessArea.Size.X
			SuccessArea.Size = UDim2.new(X.Scale, X.Offset, 0, 225)
		end
	end
end)

local tab11 = Tab
local tbl30 = {Title = "Bring Steak"}
tbl30.Desc = nil
tbl30.Locked = false

function tbl30.Callback()
	Players12 = game:GetService("Players")
	WorkspaceItems = workspace:WaitForChild("Items")
	RS = game:GetService("ReplicatedStorage")
	StartDrag = RS:WaitForChild("RemoteEvents"):WaitForChild("RequestStartDraggingItem")
	StopDrag = RS:WaitForChild("RemoteEvents"):WaitForChild("StopDraggingItem")
	LocalPlayer11 = Players12.LocalPlayer
	HumanoidRootPart1 = LocalPlayer11.Character:WaitForChild("HumanoidRootPart")

	function BringItem(arg1)
		for _, child in ipairs(WorkspaceItems:GetChildren()) do
			if child.Name == arg1 then
				part = child:IsA("Model") and (child.PrimaryPart or child:FindFirstChildWhichIsA("BasePart") or child:FindFirstChild("Handle")) or child
				if part then
					if child:IsA("Model") and not child.PrimaryPart then
						pcall(function()
							child.PrimaryPart = part
						end)
					end

					pcall(function()
						StartDrag:FireServer(child)

						if child:IsA("Model") then
							child:SetPrimaryPartCFrame(HumanoidRootPart1.CFrame)
						else
							part.CFrame = HumanoidRootPart1.CFrame
						end

						StopDrag:FireServer(child)
					end)

					break
				end
			end
		end
	end

	BringItem("Steak")
end

tab11:Button(tbl30)
local tab12 = Tab
local tbl31 = {Title = "Bring Carrot"}
tbl31.Desc = nil
tbl31.Locked = false

function tbl31.Callback()
	Players12 = game:GetService("Players")
	WorkspaceItems = workspace:WaitForChild("Items")
	RS = game:GetService("ReplicatedStorage")
	StartDrag = RS:WaitForChild("RemoteEvents"):WaitForChild("RequestStartDraggingItem")
	StopDrag = RS:WaitForChild("RemoteEvents"):WaitForChild("StopDraggingItem")
	LocalPlayer11 = Players12.LocalPlayer
	HumanoidRootPart1 = LocalPlayer11.Character:WaitForChild("HumanoidRootPart")

	function BringItem(arg1)
		for _, child in ipairs(WorkspaceItems:GetChildren()) do
			if child.Name == arg1 then
				part = child:IsA("Model") and (child.PrimaryPart or child:FindFirstChildWhichIsA("BasePart") or child:FindFirstChild("Handle")) or child
				if part then
					if child:IsA("Model") and not child.PrimaryPart then
						pcall(function()
							child.PrimaryPart = part
						end)
					end

					pcall(function()
						StartDrag:FireServer(child)

						if child:IsA("Model") then
							child:SetPrimaryPartCFrame(HumanoidRootPart1.CFrame)
						else
							part.CFrame = HumanoidRootPart1.CFrame
						end

						StopDrag:FireServer(child)
					end)

					break
				end
			end
		end
	end

	BringItem("Carrot")
end

tab12:Button(tbl31)
local tab13 = Tab
local tbl32 = {Title = "Teleport to Taming Tent"}
tbl32.Desc = nil

function tbl32.Callback()
	LocalPlayer11 = game.Players.LocalPlayer
	HumanoidRootPart1 = LocalPlayer11.Character and LocalPlayer11.Character:FindFirstChild("HumanoidRootPart")

	if not HumanoidRootPart1 then
		return
	end

	tamingTent = workspace:FindFirstChild("Map") and workspace.Map:FindFirstChild("Landmarks") and workspace.Map.Landmarks:FindFirstChild("Taming Tent")

	if tamingTent then
		part = tamingTent:FindFirstChildWhichIsA("BasePart")
		if part then
			HumanoidRootPart1.CFrame = part.CFrame + Vector3.new(0, 5, 0)
		else
			warn("Taming Tent has no parts to teleport to!")
		end
	else
		game:GetService("StarterGui"):SetCore("SendNotification", {
			Title = "SpamX Reminder",
			Text = "Taming Tent not found! Explore the map so it loads.",
			Duration = 5,
		})
	end
end

tab13:Button(tbl32)

Section = Tab:Section({
	Title = "Fishing",
	Icon = "fish",
	Box = true,
	FontWeight = Enum.FontWeight.SemiBold,
	TextTransparency = 0,
	HorizontalAlignment = Enum.HorizontalAlignment.Left,
	TextSize = 17,
	Opened = true,
})

Tab:Toggle({
	Title = "Auto Catch Minigame",
	Default = false,
	Callback = function(value)
		getgenv().autoCatchEnabled = value
		if value then
			getgenv().wasInZone = false
			getgenv().autoCatchConnection = game:GetService("RunService").Heartbeat:Connect(function()
				local ok, result = pcall(function()
					LocalPlayer11 = game.Players.LocalPlayer

					if not LocalPlayer11 then
						return
					end

					interface = LocalPlayer11.PlayerGui:FindFirstChild("Interface") or LocalPlayer11:FindFirstChild("Interface")

					if not interface then
						return
					end

					fishingFrame = interface:FindFirstChild("FishingCatchFrame")

					if not fishingFrame or not fishingFrame.Visible then
						getgenv().wasInZone = false
						return
					end

					timingBar = fishingFrame:FindFirstChild("TimingBar")

					if not timingBar then
						return
					end

					bar = timingBar:FindFirstChild("Bar")
					successArea = timingBar:FindFirstChild("SuccessArea")

					if not bar or not successArea then
						return
					end

					barPos = bar.AbsolutePosition
					barSize = bar.AbsoluteSize
					successPos = successArea.AbsolutePosition
					successSize = successArea.AbsoluteSize
					xOverlap = barPos.X < successPos.X + successSize.X and barPos.X + barSize.X > successPos.X
					yOverlap = barPos.Y < successPos.Y + successSize.Y and barPos.Y + barSize.Y > successPos.Y
					inZone = xOverlap and yOverlap

					if inZone and not getgenv().wasInZone then
						vim = game:GetService("VirtualInputManager")
						vim:SendMouseButtonEvent(0, 0, 0, true, game, 1)
						task.wait(0.03)
						vim:SendMouseButtonEvent(0, 0, 0, false, game, 1)
					end

					getgenv().wasInZone = inZone
				end)
				if not ok then
					warn("Auto Catch Error:", result)
				end
			end)
		else
			if getgenv().autoCatchConnection then
				getgenv().autoCatchConnection:Disconnect()
				getgenv().autoCatchConnection = nil
			end
			getgenv().wasInZone = false
		end
	end,
})

Tab:Toggle({
	Title = "100% Catch Chance",
	Default = false,
	Callback = function(value)
		getgenv().GreenBarHeightEnabled = value
		if value then
			getgenv().GreenBarConnection = game:GetService("RunService").RenderStepped:Connect(function()
				LocalPlayer11 = game.Players.LocalPlayer

				if not LocalPlayer11 then
					return
				end

				interface = LocalPlayer11.PlayerGui:FindFirstChild("Interface") or LocalPlayer11:FindFirstChild("Interface")

				if not interface then
					return
				end

				fishingFrame = interface:FindFirstChild("FishingCatchFrame")

				if not fishingFrame or not fishingFrame.Visible then
					return
				end

				timingBar = fishingFrame:FindFirstChild("TimingBar")

				if not timingBar then
					return
				end

				successArea = timingBar:FindFirstChild("SuccessArea")

				if successArea then
					width = successArea.Size.X
					successArea.Size = UDim2.new(width.Scale, width.Offset, 0, 80)
				end
			end)
		elseif getgenv().GreenBarConnection then
			getgenv().GreenBarConnection:Disconnect()
			getgenv().GreenBarConnection = nil
		end
	end,
})

ToggleCatchEnabled = false

Tab:Toggle({
	Title = "Instant Catch",
	Default = false,
	Callback = function(value)
		ToggleCatchEnabled = value
		if value then
			if not getgenv().CatchConnection then
				ReplicatedStorage11 = game:GetService("ReplicatedStorage")
				remoteEvents = ReplicatedStorage11:WaitForChild("RemoteEvents")
				startCatchTimer = remoteEvents:WaitForChild("StartCatchTimer")
				confirmCatchItem = remoteEvents:WaitForChild("ConfirmCatchItem")

				getgenv().CatchConnection = startCatchTimer.OnClientEvent:Connect(function()
					if ToggleCatchEnabled then
						confirmCatchItem:FireServer()
					end
				end)
			end
		elseif getgenv().CatchConnection then
			getgenv().CatchConnection:Disconnect()
			getgenv().CatchConnection = nil
		end
	end,
})

Tab:Button({
	Title = "Teleport to Fishing Hut",
	Desc = "Teleports you to the fishing hut where you get fishing rod ifykyk imo",
	Callback = function()
		local LocalPlayer = game.Players.LocalPlayer

		if not LocalPlayer or not LocalPlayer.Character then
			return
		end

		local HumanoidRootPart = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")

		if not HumanoidRootPart then
			return
		end

		local v1 = workspace:FindFirstChild("Map") and workspace.Map:FindFirstChild("Landmarks") and workspace.Map.Landmarks:FindFirstChild("Fishing Hut")

		if v1 then
			local BasePart = v1:FindFirstChildWhichIsA("BasePart")
			if BasePart then
				HumanoidRootPart.CFrame = BasePart.CFrame + Vector3.new(0, 5, 0)
			else
				warn("Fishing Hut has no parts to teleport to!")
			end
		else
			warn("Fishing Hut not found in workspace.Map.Landmarks!")
		end
	end,
})

Tab = Window:Tab({Title = "esp", Icon = "eye", Locked = false})
local flag11 = false
local v4 = Color3.fromRGB(255, 255, 0)
local tbl33 = {}
local tbl34 = {}
local tbl35 = {}
local tbl36 = {}
local tbl37 = {}
local tbl38 = {}
local tbl39 = {}

Tab:Toggle({
	Title = "ESP Enabled",
	Default = false,
	Callback = function(value)
		flag11 = value
	end,
})

Tab:Colorpicker({
	Title = "ESP Color",
	Default = Color3.fromRGB(255, 255, 0),
	Callback = function(value)
		v4 = value
	end,
})

Tab:Dropdown({
	Title = "Select Fuel",
	Values = {
		"Log",
		"Coal",
		"Chair",
		"Fuel Canister",
		"Oil Barrel",
		"Biofuel",
		"Wolf Corpse",
		"Alpha Wolf Corpse",
		"Bear Corpse",
		"Cultist Corpse",
		"Crossbow Cultist Corpse",
	},
	Multi = true,
	Callback = function(value)
		tbl33 = value
	end,
})

Tab:Dropdown({
	Title = "Select Scrap",
	Values = {
		"Bolt",
		"Sheet Metal",
		"Broken Fan",
		"Old Radio",
		"Broken Microwave",
		"Tyre",
		"Metal Chair",
		"Old Car Engine",
		"Washing Machine",
		"Cultist Experiment",
		"Cultist Prototype",
	},
	Multi = true,
	Callback = function(value)
		tbl34 = value
	end,
})

Tab:Dropdown({
	Title = "Select Food",
	Values = {
		"Carrot",
		"Berry",
		"Chili",
		"Bandage",
		"Medkit",
		"Morsel",
		"Steak",
		"Cooked Morsel",
		"Cooked Steak",
		"Morsel?",
		"Cake",
		"Stew",
		"Hearty Stew",
		"Ribs",
		"Cooked Ribs",
		"Carrot Cake",
		"BBQ Ribs",
	},
	Multi = true,
	Callback = function(value)
		tbl35 = value
	end,
})

Tab:Dropdown({
	Title = "Select Tools",
	Values = {
		"Good Axe",
		"Strong Axe",
		"Good Sack",
		"Giant Sack",
		"Infernal Sack",
		"Old flashlight",
		"Strong Flashlight",
		"Ice Axe",
		"Chainsaw",
	},
	Multi = true,
	Callback = function(value)
		tbl36 = value
	end,
})

Tab:Dropdown({
	Title = "Select Melee/Armor",
	Values = {
		"Spear",
		"Katana",
		"Morningstar",
		"Blowpipe",
		"Laser Sword",
		"Ice Sword",
		"Poison Spear",
		"Infernal Sword",
		"Cultist King Mace",
		"Obsidiron Hammer",
		"Leather Body",
		"Iron Body",
		"Thorn Body",
		"Poison Armor",
		"Alien Armor",
		"Obsidiron Body",
		"Riot Shield",
	},
	Multi = true,
	Callback = function(value)
		tbl37 = value
	end,
})

Tab:Dropdown({
	Title = "Select Ranged/Ammo",
	Values = {
		"Revolver",
		"Rifle",
		"Tactical Shotgun",
		"Revolver Ammo",
		"Rifle Ammo",
		"Shotgun Ammo",
		"Snowball",
		"Kunai",
		"Frozen Shuriken",
		"Wildfire",
		"Crossbow",
		"Infernal Crossbow",
		"Flamethrower",
		"Raygun",
		"Laser Cannon",
	},
	Multi = true,
	Callback = function(value)
		tbl38 = value
	end,
})

Tab:Dropdown({
	Title = "Select Others",
	Values = {
		"Seed Box",
		"Wolf Pelt",
		"Alpha Wolf Pelt",
		"Bear Pelt",
		"Artic Fox Pelt",
		"Polar Bear Pelt",
		"Mammoth Tusk",
		"Scorpion Shell",
		"Cultist King Antler",
		"FrogKey",
		"Hammer",
		"Paint Brush",
		"Forest Gem Fragment",
		"Mossy coin",
		"Coin Stack",
		"Sacrifice Totem",
		"Meteor Shard",
		"Gold Shard",
		"Obsidiron Ingot",
		"RedKey",
		"BlueKey",
		"YellowKey",
		"GreyKey",
		"Anvil Front",
		"Anvil Back",
		"Anvil Base",
	},
	Multi = true,
	Callback = function(value)
		tbl39 = value
	end,
})

task.spawn(function()
	while true do
		if flag11 then
			local Children = workspace:WaitForChild("Items"):GetChildren()
			local tbl = {}

			for _, v1 in ipairs(tbl33) do
				tbl[v1] = true
			end

			for _, v2 in ipairs(tbl34) do
				tbl[v2] = true
			end

			for _, v3 in ipairs(tbl35) do
				tbl[v3] = true
			end

			for _, v5 in ipairs(tbl36) do
				tbl[v5] = true
			end

			for _, v6 in ipairs(tbl37) do
				tbl[v6] = true
			end

			for _, v7 in ipairs(tbl38) do
				tbl[v7] = true
			end

			for _, v8 in ipairs(tbl39) do
				tbl[v8] = true
			end

			for _, v9 in ipairs(Children) do
				if tbl[v9.Name] then
					local v10 = v9:IsA("Model") and (v9.PrimaryPart or v9:FindFirstChildWhichIsA("BasePart") or v9:FindFirstChild("Handle")) or v9
					if v10 then
						local ESPLabel = v9:FindFirstChild("ESPLabel")

						if not ESPLabel then
							local billboardGui = Instance.new("BillboardGui")
							ESPLabel = billboardGui
							billboardGui.Name = "ESPLabel"
							billboardGui.Adornee = v10
							billboardGui.Size = UDim2.new(0, 100, 0, 40)
							billboardGui.StudsOffset = Vector3.new(0, 3, 0)
							billboardGui.AlwaysOnTop = true
							local textLabel = Instance.new("TextLabel", billboardGui)
							textLabel.Size = UDim2.new(1, 0, 1, 0)
							textLabel.BackgroundTransparency = 1
							textLabel.TextColor3 = v4
							textLabel.TextStrokeTransparency = 0
							textLabel.TextScaled = true
							textLabel.Text = v9.Name
							billboardGui.Parent = v9
						end

						local TextLabel = ESPLabel:FindFirstChildOfClass("TextLabel")

						if TextLabel then
							TextLabel.TextColor3 = v4
							local v11 = game.Players.LocalPlayer.Character.HumanoidRootPart.Position - v10.Position
							TextLabel.Text = v9.Name .. "\n[" .. math.floor(v11.Magnitude) .. "m]"
						end
					end
				elseif v9:FindFirstChild("ESPLabel") then
					v9.ESPLabel:Destroy()
				end
			end
		end
		task.wait(0.1)
	end
end)

Tab = Window:Tab({Title = "Player", Icon = "eye", Locked = false})
getgenv().WalkSpeedEnabled = false
getgenv().WalkSpeedValue = 70

Tab:Slider({
	Title = "WalkSpeed",
	Step = 1,
	Value = {Min = 15, Max = 500, Default = 70},
	Callback = function(value)
		getgenv().WalkSpeedValue = value
		if getgenv().WalkSpeedEnabled then
			local Character1 = game:GetService("Players").LocalPlayer.Character
			if Character1 then
				local Humanoid1 = Character1:FindFirstChildOfClass("Humanoid")
				if Humanoid1 then
					Humanoid1.WalkSpeed = value
				end
			end
		end
	end,
})

Tab:Toggle({
	Title = "Enable WalkSpeed",
	Icon = "gauge",
	Type = "Toggle",
	Default = false,
	Callback = function(value)
		getgenv().WalkSpeedEnabled = value
		local Character1 = game:GetService("Players").LocalPlayer.Character

		if not Character1 then
			return
		end

		local Humanoid1 = Character1:FindFirstChildOfClass("Humanoid")

		if not Humanoid1 then
			return
		end

		if value then
			Humanoid1.WalkSpeed = getgenv().WalkSpeedValue
		else
			Humanoid1.WalkSpeed = 16
		end
	end,
})

Section = Tab:Section({
	Title = "Jump-power",
	Box = false,
	FontWeight = Enum.FontWeight.SemiBold,
	TextTransparency = 0,
	HorizontalAlignment = Enum.HorizontalAlignment.Left,
	TextSize = 17,
	Opened = true,
})

getgenv().JumpPowerEnabled = false
getgenv().JumpPowerValue = 50

Tab:Slider({
	Title = "JumP-Power",
	Step = 1,
	Value = {Min = 25, Max = 500, Default = 50},
	Callback = function(value)
		getgenv().JumpPowerValue = value
		if getgenv().JumpPowerEnabled then
			local Character1 = game:GetService("Players").LocalPlayer.Character
			if Character1 then
				local Humanoid1 = Character1:FindFirstChildOfClass("Humanoid")
				if Humanoid1 then
					Humanoid1.UseJumpPower = true
					Humanoid1.JumpPower = value
				end
			end
		end
	end,
})

Tab:Toggle({
	Title = "Enable JumP-Power",
	Icon = "chevron-up",
	Type = "Toggle",
	Default = false,
	Callback = function(value)
		getgenv().JumpPowerEnabled = value
		local Character1 = game:GetService("Players").LocalPlayer.Character

		if not Character1 then
			return
		end

		local Humanoid1 = Character1:FindFirstChildOfClass("Humanoid")

		if not Humanoid1 then
			return
		end

		if value then
			Humanoid1.UseJumpPower = true
			Humanoid1.JumpPower = getgenv().JumpPowerValue
		else
			Humanoid1.JumpPower = 50
		end
	end,
})

Section = Tab:Section({
	Title = "Fly",
	Box = false,
	FontWeight = Enum.FontWeight.SemiBold,
	TextTransparency = 0,
	HorizontalAlignment = Enum.HorizontalAlignment.Left,
	TextSize = 17,
	Opened = true,
})

getgenv().FlyEnabled = false
getgenv().FlySpeed = 70
getgenv().FlyConnection = nil

function FlyLoop()
	local LocalPlayer = game:GetService("Players").LocalPlayer
	local Character1 = LocalPlayer.Character

	if not Character1 then
		return
	end

	local HumanoidRootPart = Character1:FindFirstChild("HumanoidRootPart")

	if not HumanoidRootPart then
		return
	end

	if not HumanoidRootPart:FindFirstChild("BodyGyro") then
		local bodyGyro = Instance.new("BodyGyro", HumanoidRootPart)
		bodyGyro.MaxTorque = Vector3.new(9000000000, 9000000000, 9000000000)
		bodyGyro.P = 90000
		bodyGyro.CFrame = HumanoidRootPart.CFrame
	end

	if not HumanoidRootPart:FindFirstChild("BodyVelocity") then
		Instance.new("BodyVelocity", HumanoidRootPart).MaxForce = Vector3.new(9000000000, 9000000000, 9000000000)
	end

	getgenv().FlyConnection = game:GetService("RunService").RenderStepped:Connect(function()
		if not getgenv().FlyEnabled then
			return
		end

		local MoveVector = require(LocalPlayer.PlayerScripts:WaitForChild("PlayerModule"):WaitForChild("ControlModule")):GetMoveVector()
		local CurrentCamera = workspace.CurrentCamera
		local v1 = Vector3.zero + CurrentCamera.CFrame.RightVector * (MoveVector.X * getgenv().FlySpeed) - CurrentCamera.CFrame.LookVector * (MoveVector.Z * getgenv().FlySpeed)
		HumanoidRootPart.BodyVelocity.Velocity = v1
		HumanoidRootPart.BodyGyro.CFrame = CFrame.new(HumanoidRootPart.Position, HumanoidRootPart.Position + CurrentCamera.CFrame.LookVector)
	end)
end

function StopFly()
	local Character1 = game:GetService("Players").LocalPlayer.Character

	if not Character1 then
		return
	end

	local HumanoidRootPart = Character1:FindFirstChild("HumanoidRootPart")

	if not HumanoidRootPart then
		return
	end

	if HumanoidRootPart:FindFirstChild("BodyGyro") then
		HumanoidRootPart.BodyGyro:Destroy()
	end

	if HumanoidRootPart:FindFirstChild("BodyVelocity") then
		HumanoidRootPart.BodyVelocity:Destroy()
	end

	if getgenv().FlyConnection then
		getgenv().FlyConnection:Disconnect()
		getgenv().FlyConnection = nil
	end
end

Tab:Slider({
	Title = "Fly Speed",
	Step = 1,
	Value = {Min = 15, Max = 500, Default = 70},
	Callback = function(value)
		getgenv().FlySpeed = value
	end,
})

Tab:Toggle({
	Title = "Enable Fly",
	Icon = "plane",
	Type = "Toggle",
	Default = false,
	Callback = function(value)
		getgenv().FlyEnabled = value
		if value then
			FlyLoop()
		else
			StopFly()
		end
	end,
})

Section = Tab:Section({
	Title = "Misc",
	Box = false,
	FontWeight = Enum.FontWeight.SemiBold,
	TextTransparency = 0,
	HorizontalAlignment = Enum.HorizontalAlignment.Left,
	TextSize = 17,
	Opened = true,
})

getgenv().InfJumpEnabled = false
getgenv().InfJumpConnection = nil

Tab:Toggle({
	Title = "Infinite Jump",
	Icon = "rabbit",
	Type = "Toggle",
	Default = false,
	Callback = function(value)
		getgenv().InfJumpEnabled = value
		if value then
			if getgenv().InfJumpConnection then
				getgenv().InfJumpConnection:Disconnect()
			end
			getgenv().InfJumpConnection = game:GetService("UserInputService").JumpRequest:Connect(function()
				if getgenv().InfJumpEnabled then
					local Character1 = game:GetService("Players").LocalPlayer.Character
					if Character1 and Character1:FindFirstChildOfClass("Humanoid") then
						Character1:FindFirstChildOfClass("Humanoid"):ChangeState(Enum.HumanoidStateType.Jumping)
					end
				end
			end)
		elseif getgenv().InfJumpConnection then
			getgenv().InfJumpConnection:Disconnect()
			getgenv().InfJumpConnection = nil
		end
	end,
})

NoclipToggle = Tab:Toggle({
	Title = "Noclip",
	Icon = "ghost",
	Type = "Toggle",
	Default = false,
	Callback = function(value)
		getgenv().NoclipEnabled = value
		local LocalPlayer = game.Players.LocalPlayer
		local v1 = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()

		if not v1 then
			return
		end

		v1:WaitForChild("HumanoidRootPart")
		v1:WaitForChild("Humanoid")

		if value then
			getgenv().NoclipConnection = game:GetService("RunService").Stepped:Connect(function()
				for _, descendant in ipairs(v1:GetDescendants()) do
					if descendant:IsA("BasePart") then
						descendant.CanCollide = false
					end
				end
			end)
		else
			if getgenv().NoclipConnection then
				getgenv().NoclipConnection:Disconnect()
				getgenv().NoclipConnection = nil
			end
			for _, descendant in ipairs(v1:GetDescendants()) do
				if descendant:IsA("BasePart") then
					descendant.CanCollide = true
				end
			end
		end
	end,
})

playerNames = {}

for _, player1 in ipairs(game.Players:GetPlayers()) do
	table.insert(playerNames, player1.Name)
end

selectedPlayer = playerNames[1]

Dropdown = Tab:Dropdown({
	Title = "Select Player",
	Values = playerNames,
	Value = selectedPlayer,
	Callback = function(value)
		selectedPlayer = value
	end,
})

Button = Tab:Button({
	Title = "Teleport to Player",
	Desc = "Teleport to the selected player",
	Locked = false,
	Callback = function()
		LocalPlayer11 = game.Players:FindFirstChild(selectedPlayer)
		LocalPlayer10 = game.Players.LocalPlayer
		HumanoidRootPart1 = LocalPlayer10.Character and LocalPlayer10.Character:FindFirstChild("HumanoidRootPart")

		if
			LocalPlayer11
			and LocalPlayer11.Character
			and LocalPlayer11.Character:FindFirstChild("HumanoidRootPart")
			and HumanoidRootPart1
		then
			HumanoidRootPart1.CFrame = LocalPlayer11.Character.HumanoidRootPart.CFrame + Vector3.new(0, 5, 0)
		else
			game.StarterGui:SetCore(
				"SendNotification",
				{Title = "Voidex Error", Text = "Player not found or character not loaded.", Duration = 5}
			)
		end
	end,
})

game.Players.PlayerAdded:Connect(function(player1)
	table.insert(playerNames, player1.Name)
	Dropdown:Refresh(playerNames)
end)

game.Players.PlayerRemoving:Connect(function(player1)
	for i, playerName in ipairs(playerNames) do
		if playerName == player1.Name then
			table.remove(playerNames, i)
			break
		end
	end
	Dropdown:Refresh(playerNames)
end)

Section = Tab:Section({
	Title = "Brightness",
	Box = false,
	FontWeight = Enum.FontWeight.SemiBold,
	TextTransparency = 0,
	HorizontalAlignment = Enum.HorizontalAlignment.Left,
	TextSize = 17,
	Opened = true,
})

FullBrightEnabled = false

OriginalLighting = {
	Ambient = game.Lighting.Ambient,
	OutdoorAmbient = game.Lighting.OutdoorAmbient,
	Brightness = game.Lighting.Brightness,
	ClockTime = game.Lighting.ClockTime,
}

function applyFullBright()
	game.Lighting.Ambient = Color3.fromRGB(255, 255, 255)
	game.Lighting.OutdoorAmbient = Color3.fromRGB(255, 255, 255)
	game.Lighting.Brightness = 2
	game.Lighting.ClockTime = 14
end

game:GetService("RunService").RenderStepped:Connect(function()
	if FullBrightEnabled then
		applyFullBright()
	end
end)

FullBrightToggle = Tab:Toggle({
	Title = "Full Bright",
	Icon = "sun",
	Type = "Toggle",
	Default = false,
	Callback = function(value)
		FullBrightEnabled = value
		if not value then
			game.Lighting.Ambient = OriginalLighting.Ambient
			game.Lighting.OutdoorAmbient = OriginalLighting.OutdoorAmbient
			game.Lighting.Brightness = OriginalLighting.Brightness
			game.Lighting.ClockTime = OriginalLighting.ClockTime
		end
	end,
})

NightToDayEnabled = false
OriginalClockTime = game.Lighting.ClockTime

game:GetService("RunService").RenderStepped:Connect(function()
	if NightToDayEnabled then
		game.Lighting.ClockTime = 14
	end
end)

NightToDayToggle = Tab:Toggle({
	Title = "Turn Night Into Day",
	Icon = "moon",
	Type = "Toggle",
	Default = false,
	Callback = function(value)
		NightToDayEnabled = value
		if not value then
			game.Lighting.ClockTime = OriginalClockTime
		end
	end,
})

RemoveFogEnabled = false
local Lighting1 = game:GetService("Lighting")
OriginalFogStart = Lighting1.FogStart
OriginalFogEnd = Lighting1.FogEnd

game:GetService("RunService").RenderStepped:Connect(function()
	if RemoveFogEnabled then
		Lighting1.FogStart = 0
		Lighting1.FogEnd = 100000
	end
end)

RemoveFogToggle = Tab:Toggle({
	Title = "Remove Fog",
	Icon = "eye-off",
	Type = "Toggle",
	Default = false,
	Callback = function(value)
		RemoveFogEnabled = value
		if not value then
			Lighting1.FogStart = OriginalFogStart
			Lighting1.FogEnd = OriginalFogEnd
		end
	end,
})

BeautifulPurpleSkyEnabled = false
Lighting1 = game:GetService("Lighting")
OriginalSky = Lighting1:FindFirstChildOfClass("Sky")
OriginalAmbient = Lighting1.Ambient
OriginalOutdoorAmbient = Lighting1.OutdoorAmbient
OriginalClockTime = Lighting1.ClockTime
OriginalTimeOfDay = Lighting1.TimeOfDay
OriginalFogColor = Lighting1.FogColor
OriginalFogStart = Lighting1.FogStart
OriginalFogEnd = Lighting1.FogEnd
OriginalTechnology = Lighting1.Technology
OriginalShadowSoftness = Lighting1.ShadowSoftness
OriginalGlobalShadows = Lighting1.GlobalShadows
bloom = nil
cc = nil
sun = nil
dof = nil

Tab:Toggle({
	Title = "Beautiful Purple Sky",
	Icon = "sun",
	Type = "Toggle",
	Default = false,
	Callback = function(value)
		BeautifulPurpleSkyEnabled = value
		if value then
			if Lighting1:FindFirstChildOfClass("Sky") then
				Lighting1:FindFirstChildOfClass("Sky"):Destroy()
			end

			PurpleSky = Instance.new("Sky")
			PurpleSky.Name = "PurpleSky"
			PurpleSky.Parent = Lighting1
			Lighting1.Technology = Enum.Technology.Future
			Lighting1.ShadowSoftness = 0.5
			Lighting1.GlobalShadows = true
			Lighting1.Ambient = Color3.fromRGB(128, 0, 128)
			Lighting1.OutdoorAmbient = Color3.fromRGB(180, 0, 180)
			Lighting1.ClockTime = 14
			Lighting1.TimeOfDay = "14:00:00"
			Lighting1.FogColor = Color3.fromRGB(128, 0, 128)
			Lighting1.FogStart = 0
			Lighting1.FogEnd = 1000
			bloom = Instance.new("BloomEffect")
			bloom.Intensity = 2
			bloom.Size = 50
			bloom.Threshold = 0.5
			bloom.Parent = Lighting1
			cc = Instance.new("ColorCorrectionEffect")
			cc.TintColor = Color3.fromRGB(180, 0, 180)
			cc.Contrast = 0.2
			cc.Saturation = 0.3
			cc.Parent = Lighting1
			sun = Instance.new("SunRaysEffect")
			sun.Intensity = 0.3
			sun.Parent = Lighting1
			dof = Instance.new("DepthOfFieldEffect")
			dof.FocusDistance = 50
			dof.InFocusRadius = 20
			dof.Parent = Lighting1
		else
			if Lighting1:FindFirstChild("PurpleSky") then
				Lighting1.PurpleSky:Destroy()
			end

			if bloom then
				bloom:Destroy()
				bloom = nil
			end

			if cc then
				cc:Destroy()
				cc = nil
			end

			if sun then
				sun:Destroy()
				sun = nil
			end

			if dof then
				dof:Destroy()
				dof = nil
			end

			if OriginalSky then
				OriginalSky.Parent = Lighting1
			end

			Lighting1.Ambient = OriginalAmbient
			Lighting1.OutdoorAmbient = OriginalOutdoorAmbient
			Lighting1.ClockTime = OriginalClockTime
			Lighting1.TimeOfDay = OriginalTimeOfDay
			Lighting1.FogColor = OriginalFogColor
			Lighting1.FogStart = OriginalFogStart
			Lighting1.FogEnd = OriginalFogEnd
			Lighting1.Technology = OriginalTechnology
			Lighting1.ShadowSoftness = OriginalShadowSoftness
			Lighting1.GlobalShadows = OriginalGlobalShadows
		end
	end,
})

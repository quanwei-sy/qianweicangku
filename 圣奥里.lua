-- 圣奥里：独立服务器缝合版
local NothingLibrary = loadstring(game:HttpGetAsync('https://raw.githubusercontent.com/quanwei-sy/qianweicangku/refs/heads/main/%E6%BA%90%E7%A0%81.lua'))()

local __BaseWindow = NothingLibrary.new({
    Title = "TY hub｜圣奥里",
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



if getgenv().TYHubScriptLoaded then
    pcall(function()
        if getgenv().TYHubScript and getgenv().TYHubScript.Unload then
            getgenv().TYHubScript.Unload()
        end
    end)
end
getgenv().TYHubScriptLoaded = true

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local GuiService = game:GetService("GuiService")
local ContextActionService = game:GetService("ContextActionService")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer
if not LocalPlayer then
    Players:GetPropertyChangedSignal("LocalPlayer"):Wait()
    LocalPlayer = Players.LocalPlayer
end

local PlayerControls = nil
task.spawn(function()
    pcall(function()
        local playerScripts = LocalPlayer:WaitForChild("PlayerScripts", 15)
        local playerModule = playerScripts and playerScripts:WaitForChild("PlayerModule", 10)
        if playerModule then
            PlayerControls = require(playerModule):GetControls()
        end
    end)
end)

local newcclosure = newcclosure or function(f)
    return f
end
local gethuiFn = gethui or function()
    return nil
end
local hookfunctionFn = hookfunction
local hookmetamethodFn = hookmetamethod
local getnamecallmethodFn = getnamecallmethod
local getrawmetatableFn = getrawmetatable
local setreadonlyFn = setreadonly
local firepromptFn = fireproximityprompt

local Connections = {}
local function connect(signal, fn)
    local c = signal:Connect(fn)
    table.insert(Connections, c)
    return c
end
local function clearConnections()
    for _, c in ipairs(Connections) do
        pcall(function()
            c:Disconnect()
        end)
    end
    table.clear(Connections)
end

local function make(class, props, parent)
    local obj = Instance.new(class)
    if props then
        for k, v in pairs(props) do
            obj[k] = v
        end
    end
    if parent then
        obj.Parent = parent
    end
    return obj
end

local Theme = {
    bg = Color3.fromRGB(7, 4, 14),
    panel = Color3.fromRGB(12, 8, 22),
    surface = Color3.fromRGB(19, 13, 34),
    surface2 = Color3.fromRGB(27, 19, 48),
    stroke = Color3.fromRGB(66, 44, 108),
    text = Color3.fromRGB(241, 233, 255),
    subtext = Color3.fromRGB(164, 148, 192),
    accent = Color3.fromRGB(168, 85, 247),
    accent2 = Color3.fromRGB(124, 58, 237),
    accent3 = Color3.fromRGB(232, 196, 255),
    green = Color3.fromRGB(74, 222, 128),
    red = Color3.fromRGB(248, 113, 113),
    amber = Color3.fromRGB(251, 191, 36),
}

local function gradient(parent, c1, c2, rotation)
    local g = Instance.new("UIGradient")
    g.Color = ColorSequence.new(c1 or Theme.accent, c2 or Theme.accent2)
    g.Rotation = rotation or 0
    g.Parent = parent
    return g
end

function TYHubMetal(parent, dark, light, rotation)
    local g = Instance.new("UIGradient")
    g.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, dark),
        ColorSequenceKeypoint.new(0.16, light),
        ColorSequenceKeypoint.new(0.48, dark),
        ColorSequenceKeypoint.new(0.72, light),
        ColorSequenceKeypoint.new(1, dark),
    })
    g.Rotation = rotation or 90
    g.Parent = parent
    return g
end

local function corner(parent, radius)
    return make("UICorner", { CornerRadius = UDim.new(0, radius or 10) }, parent)
end

local function stroke(parent, color, thickness, transparency)
    return make("UIStroke", {
        Color = color or Theme.stroke,
        Thickness = thickness or 1,
        Transparency = transparency or 0.3,
    }, parent)
end

local function text(parent, str, size, color, font, xAlign)
    return make("TextLabel", {
        BackgroundTransparency = 1,
        Text = str,
        TextSize = size or 12,
        TextColor3 = color or Theme.text,
        Font = font or Enum.Font.Gotham,
        TextXAlignment = xAlign or Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Center,
    }, parent)
end


local ConfigRegistry = {}
local TabObjects = {}
local ActiveTab = nil
local MainWindow = Library:CreateWindow({ Title = "TY hub｜圣奥里" })
local guiParent
pcall(function() guiParent = gethuiFn() end)
if not guiParent then pcall(function() guiParent = game:GetService("CoreGui") end) end
if not guiParent then guiParent = LocalPlayer:WaitForChild("PlayerGui") end
local ScreenGui = make("ScreenGui", {
    Name = "TYHubFunctionalHud", ResetOnSpawn = false, IgnoreGuiInset = true,
    DisplayOrder = 40, ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
})
if not pcall(function() ScreenGui.Parent = guiParent end) then ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end
local TYHubHudRoot = make("Frame", {
    Name = "FunctionalHudRoot", Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1,
}, TYHubHudRoot)
local viewport = Workspace.CurrentCamera and Workspace.CurrentCamera.ViewportSize or Vector2.new(1280, 720)
local scaleValue = math.clamp(math.min(viewport.X / 720, viewport.Y / 540), 0.54, 1.05)
if UserInputService.TouchEnabled then scaleValue = math.clamp(scaleValue, 0.50, 1) end
local uiScale = Instance.new("UIScale")
uiScale.Scale = scaleValue
uiScale.Parent = TYHubHudRoot
glowScale = nil

local function selectTab(id)
    ActiveTab = id
    local page = TabObjects[id]
    if page and page.__tab then page.__tab:Select() end
end

local function registerConfig(flag, control, kind)
    if not flag then return end
    ConfigRegistry[flag] = {
        Type = kind,
        Set = function(value, live) control:SetValue(value) end,
        Get = function() return control:GetValue() end,
    }
end

local function newTab(title, glyphText, id)
    local page = { id = id, __tab = MainWindow:AddTab(title), __section = nil }
    TabObjects[id] = page
    table.insert(TabObjects, page)
    local function section()
        if not page.__section then page.__section = page.__tab:__DefaultSection() end
        return page.__section
    end
    function page:Section(title, desc)
        page.__section = self.__tab:Section({ Title = title })
        if desc and tostring(desc) ~= "" then page.__section:AddLabel(tostring(desc)) end
        return page.__section
    end
    function page:Label(title, desc)
        local text = tostring(title or "") .. (desc and ("：" .. tostring(desc)) or "")
        return section():AddLabel(text)
    end
    function page:Button(cfg)
        return section():AddButton({ Title = cfg.title or cfg.Name or "按钮", Callback = cfg.callback or cfg.Callback })
    end
    function page:Toggle(cfg)
        local control = section():AddToggle(cfg.flag, {
            Text = cfg.title, Default = cfg.default == true, Callback = cfg.callback,
        })
        registerConfig(cfg.flag, control, "toggle")
        return control
    end
    function page:Slider(cfg)
        local control = section():AddSlider(cfg.flag, {
            Text = cfg.title, Min = cfg.min or 0, Max = cfg.max or 100,
            Default = tonumber(cfg.default) or tonumber(cfg.min) or 0, Callback = cfg.callback,
        })
        registerConfig(cfg.flag, control, "slider")
        return control
    end
    function page:Dropdown(cfg)
        local control = section():AddDropdown({
            Text = cfg.title, Values = cfg.options or {}, Default = cfg.default,
            Multi = cfg.multi == true,
            Callback = function(value)
                if cfg.callback then
                    if cfg.multi and type(value) == "table" then
                        local list = {}
                        for name, enabled in pairs(value) do if enabled then table.insert(list, name) end end
                        cfg.callback(list)
                    else
                        cfg.callback(value)
                    end
                end
            end,
        })
        return control
    end
    function page:Keybind(cfg)
        local control = section():AddKeyPicker(cfg.flag, {
            Text = cfg.title, Default = cfg.default or Enum.KeyCode.RightShift, Callback = cfg.callback,
        })
        registerConfig(cfg.flag, control, "keybind")
        return control
    end
    function page:Input(cfg)
        return section():AddInput({
            Text = cfg.title, Default = cfg.default or "", Placeholder = cfg.placeholder or "",
            Callback = cfg.callback,
        })
    end
    return page
end

local function Notify(title, body, kind)
    Library:Notify({ Title = tostring(title or "提示"), Content = tostring(body or ""), Duration = 3 })
end

local function setMenuOpen(open)
    if open then MainWindow:Show() else MainWindow:Hide() end
end

--============================  SETTINGS  ============================--

local Settings = {
    -- Main
    stamina = false,
    hunger = false,
    infiniteAmmo = false,
    rapidFire = false,
    autoMoney = false,
    instantPrompt = false,
    noRagdoll = false,
    noFallDamage = false,
    antiPull = false,
    ghost = false,
    ghostHud = false,
    ghostLock = false,
    ghostExposeTime = 4,
    ghostExposeKey = Enum.KeyCode.G,
    combatBlock = false,
    autoHack = false,
    autoAtm = false,
    -- Money
    autoMission = false,
    missionPriority = false,
    missionInterval = 2,
    taxi = false,
    taxiSafe = false,
    taxiMode = "随机时间",
    bus = false,
    farmer = false,
    golf = false,
    -- Combat
    aura = false,
    auraRange = 50,
    auraDamage = 5,
    auraInterval = 0.05,
    auraPolice = false,
    auraCivilian = false,
    auraCombat = false,
    ragebot = false,
    rageRange = 150,
    rageInterval = 0.05,
    ragePart = "Head",
    rageJob = false,
    rageWall = false,
    rageCombat = false,
    ragePolice = false,
    rageCivilian = false,
    rageBeam = false,
    rangeEnabled = false,
    rangeSize = 50,
    rangeTransparency = 0.75,
    rangeColor = "紫色",
    rangeMaterial = "Neon",
    rangeOutline = false,
    rangeCollision = false,
    rangeGlow = false,
    rangePulse = false,
    -- Aim
    aim = false,
    aimHold = true,
    aimFov = 140,
    aimSmooth = 25,
    aimPart = "头部",
    aimTeam = true,
    aimFriend = true,
    aimWall = true,
    aimPredict = false,
    aimMode = "准心最近",
    aimPolice = false,
    aimCivilian = false,
    aimCombat = false,
    aimVehicles = false,
    aimVehiclesKey = Enum.KeyCode.T,
    aimShowFov = true,
    aimFovThickness = 1.5,
    aimTracer = true,
    aimCrosshair = true,
    aimColor = "紫色",
    -- Silent
    silent = false,
    silentFov = 140,
    silentDistance = 300,
    silentPart = "头部",
    silentTeam = true,
    silentFriend = true,
    silentCombat = false,
    silentPolice = false,
    silentCivilian = false,
    silentShowFov = false,
    -- Hitbox
    hitbox = false,
    hitboxSize = 10,
    hitboxTransparency = 0.65,
    hitboxTeam = true,
    hitboxOutline = true,
    hitboxGlow = true,
    hitboxPulse = false,
    hitboxColor = "紫色",
    -- ESP
    esp = false,
    espName = true,
    espDistance = true,
    espHealth = true,
    espBox = true,
    espHighlight = true,
    espTracer = false,
    espTracerOrigin = "屏幕底部",
    espFugitive = true,
    autoRefill = false,
    espTeams = {
        Chef = true, Civilian = true, Delivery = true, Farmer = true,
        Fire = true, Police = true, Medical = true, Prisoner = true,
        ["Road Service"] = true, Transit = true,
    },
    -- Player
    walkEnabled = false,
    walkSpeed = 200,
    jumpEnabled = false,
    jumpPower = 50,
    jumpMultiplier = 1,
    infJump = false,
    fly = false,
    flySpeed = 35,
    flyMode = "传送",
    noclip = false,
    blink = false,
    blinkDistance = 120,
    blinkKey = Enum.KeyCode.Eight,
    -- Vehicle
    vehicleBoost = false,
    vehicleSpeed = 120,
    cruise = false,
    vehicleFly = false,
    vehicleFlySpeed = 80,
    vehicleFlyKey = Enum.KeyCode.F,
    vehicleEsp = false,
    vehicleEspName = true,
    vehicleEspDistance = true,
    vehicleEspHighlight = true,
    bringDistance = 12,
    bringVehicleKey = Enum.KeyCode.B,
    -- Police
    policeCuff = false,
    policeTp = false,
    policeRange = 200,
    policeInterval = 0.5,
    policeCombat = false,
    -- UI
    menuKey = Enum.KeyCode.RightShift,
    uiScale = scaleValue,
    quickHud = UserInputService.TouchEnabled,
    quickButtonX = 12,
    quickButtonY = 250,
    quickPanelX = 12,
    quickPanelY = 74,
}

__BaseWindow.Keybind = Settings.menuKey or Enum.KeyCode.RightShift

local AimParts = {
    ["头部"] = "Head",
    ["胸部"] = "UpperTorso",
    ["躯干"] = "Torso",
    ["左臂"] = "LeftArm",
    ["右臂"] = "RightArm",
    ["左腿"] = "LeftLeg",
    ["右腿"] = "RightLeg",
}

local Colors = {
    ["红色"] = Color3.fromRGB(255, 60, 60),
    ["紫色"] = Color3.fromRGB(180, 110, 255),
    ["粉色"] = Color3.fromRGB(255, 120, 220),
    ["蓝色"] = Color3.fromRGB(80, 150, 255),
    ["青色"] = Color3.fromRGB(80, 240, 255),
    ["绿色"] = Color3.fromRGB(90, 240, 130),
    ["黄色"] = Color3.fromRGB(255, 220, 90),
    ["白色"] = Color3.fromRGB(245, 245, 255),
}

local TeamColors = {
    Chef = Color3.fromRGB(255, 205, 60),
    Civilian = Color3.fromRGB(110, 200, 255),
    Delivery = Color3.fromRGB(255, 155, 60),
    Farmer = Color3.fromRGB(90, 220, 110),
    Fire = Color3.fromRGB(255, 70, 70),
    Police = Color3.fromRGB(80, 130, 255),
    Medical = Color3.fromRGB(255, 110, 230),
    Prisoner = Color3.fromRGB(255, 160, 160),
    ["Road Service"] = Color3.fromRGB(255, 240, 110),
    Transit = Color3.fromRGB(110, 240, 245),
}

local TeamNames = {
    Chef = "厨师",
    Civilian = "平民",
    Delivery = "配送员",
    Farmer = "农民",
    Fire = "消防员",
    Police = "警察",
    Medical = "医护人员",
    Prisoner = "囚犯",
    ["Road Service"] = "道路服务",
    Transit = "交通",
}

--============================  GAME HELPERS  ============================--

local function getChar(player)
    player = player or LocalPlayer
    local seen = {}
    local list = {}

    local function add(model)
        if model and typeof(model) == "Instance" and model:IsA("Model") and not seen[model] then
            seen[model] = true
            table.insert(list, model)
        end
    end
    pcall(function()
        add(player.Character)
    end)
    pcall(function()
        local folder = Workspace:FindFirstChild("Characters")
        if folder then
            add(folder:FindFirstChild(player.Name))
        end
    end)

    for _, char in ipairs(list) do
        local humanoid = char:FindFirstChildOfClass("Humanoid") or char:FindFirstChild("Humanoid", true)
        local root = char:FindFirstChild("HumanoidRootPart")
            or char:FindFirstChild("Torso")
            or char:FindFirstChild("UpperTorso")
            or (humanoid and humanoid.RootPart)
            or char.PrimaryPart
            or char:FindFirstChildWhichIsA("BasePart")
        if root then
            return char, humanoid, root
        end
    end
    return nil
end

local function getRoot(player)
    local _, _, root = getChar(player)
    return root
end

local function isAlive(player)
    local _, humanoid = getChar(player)
    return humanoid ~= nil and humanoid.Health > 0
end

local function teamOf(player)
    return player and player.Team and player.Team.Name or "Civilian"
end

local function wantedOf(player)
    local value = player:GetAttribute("WantedLevel")
    if value == nil then
        local char = player.Character
        value = char and char:GetAttribute("WantedLevel")
    end
    return tonumber(value) or 0
end

local function inCombat(player)
    return player:GetAttribute("CombatMode") == true or player:GetAttribute("Pursuit") == true
end

local function isFugitive(player)
    return teamOf(player) == "Civilian" and wantedOf(player) > 0
end

local function isFriend(player)
    local ok, result = pcall(function()
        return LocalPlayer:IsFriendsWith(player.UserId)
    end)
    return ok and result
end

local function colorOf(name)
    if name == "彩虹色" then
        return Color3.fromHSV(tick() % 5 / 5, 1, 1)
    end
    return Colors[name] or Theme.accent
end

local function passesFilter(player, onlyPolice, onlyCivilian)
    if not player or player == LocalPlayer then
        return false
    end
    if onlyPolice then
        return teamOf(player) == "Police"
    end
    if onlyCivilian then
        return teamOf(player) == "Civilian"
    end
    return true
end

local function isVisible(part)
    if not Settings.aimWall and not Settings.rageWall and not Settings.silent then
        return true
    end
    local cam = Workspace.CurrentCamera
    if not cam or not part then
        return false
    end
    local filter = {}
    if LocalPlayer.Character then
        table.insert(filter, LocalPlayer.Character)
    end
    table.insert(filter, cam)
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = filter
    params.IgnoreWater = true
    local hit = Workspace:Raycast(cam.CFrame.Position, part.Position - cam.CFrame.Position, params)
    return not hit or hit.Instance:IsDescendantOf(part.Parent)
end

local function getAimPart(char)
    if not char then
        return nil
    end
    local name = AimParts[Settings.aimPart] or "Head"
    local part = char:FindFirstChild(name)
    if part then
        return part
    end
    return char:FindFirstChild("Head") or char:FindFirstChild("HumanoidRootPart")
end

local function getRagePart(char, partName)
    if not char then
        return nil
    end
    return char:FindFirstChild(partName or Settings.ragePart)
        or char:FindFirstChild("Head")
        or char:FindFirstChild("HumanoidRootPart")
end

local function screenPosition(worldPos)
    local cam = Workspace.CurrentCamera
    if not cam then
        return nil, false
    end
    local pos, onScreen = cam:WorldToViewportPoint(worldPos)
    return Vector2.new(pos.X, pos.Y), onScreen and pos.Z > 0, pos.Z
end

--============================  REMOTES / MODULES  ============================--

local Remote, PlayerEvent, PlayerFunc
pcall(function()
    Remote = ReplicatedStorage:FindFirstChild("Remote") or ReplicatedStorage:WaitForChild("Remote", 10)
    if Remote then
        PlayerEvent = Remote:FindFirstChild("PlayerEvent") or Remote:WaitForChild("PlayerEvent", 10)
        PlayerFunc = Remote:FindFirstChild("PlayerFunc") or Remote:WaitForChild("PlayerFunc", 10)
    end
end)

local Framework, Core, CharacterModule, InventoryModule
task.spawn(function()
    pcall(function()
        local scripts = LocalPlayer:WaitForChild("PlayerScripts", 15)
        local fw = scripts and scripts:WaitForChild("Framework", 15)
        if not fw then
            return
        end
        Framework = fw
        local characterModule = fw:FindFirstChild("Character")
        if characterModule then
            CharacterModule = require(characterModule)
            local inv = characterModule:FindFirstChild("Inventory")
            if inv then
                InventoryModule = require(inv)
            end
        end
        local coreModule = fw:FindFirstChild("Core")
        if coreModule then
            Core = require(coreModule)
        end
    end)
end)

local LogSink = nil
local function log(message, kind)
    kind = kind or "info"
    pcall(function()
        print("[TYHub script] " .. tostring(message))
    end)
    if LogSink then
        pcall(LogSink, tostring(message), kind)
    end
end

--============================  HOOKS  ============================--

local namecallInstalled = false
local function installNamecall()
    if namecallInstalled then
        return
    end
    if not (getrawmetatableFn and setreadonlyFn and hookmetamethodFn and getnamecallmethodFn) then
        return
    end
    local ok = pcall(function()
        local mt = getrawmetatableFn(game)
        local original = mt.__namecall
        setreadonlyFn(mt, false)
        mt.__namecall = newcclosure(function(self, ...)
            local method = getnamecallmethodFn()
            if method == "FireServer" then
                local args = table.pack(...)
                if Settings.noFallDamage and tostring(self) == "PlayerEvent" and args[1] == "takeDamage" then
                    return nil
                end
                if Settings.combatBlock and args[1] == "combatMode" then
                    return nil
                end
            end
            return original(self, ...)
        end)
        setreadonlyFn(mt, true)
        namecallInstalled = true
    end)
    if ok then
        log("Namecall 钩子已挂载", "success")
    end
end
installNamecall()

local raycastHooked = false
local silentTargetRef = nil

local function installRaycast()
    if raycastHooked or not hookfunctionFn then
        return
    end
    local original = Workspace.Raycast
    if not original then
        return
    end
    local ok = pcall(function()
        hookfunctionFn(original, function(a, b, c, d)
            local self, origin, direction, params
            if typeof(a) == "Instance" then
                self, origin, direction, params = a, b, c, d
            else
                self, origin, direction, params = nil, a, b, c
            end
            if Settings.silent and typeof(origin) == "Vector3" and typeof(direction) == "Vector3" and silentTargetRef then
                local _, _, root = getChar(LocalPlayer)
                if root and (origin - root.Position).Magnitude < 15 then
                    direction = (silentTargetRef - origin).Unit * direction.Magnitude
                end
            end
            if self then
                return original(self, origin, direction, params)
            end
            return original(origin, direction, params)
        end)
    end)
    if ok then
        raycastHooked = true
        log("Silent Aim 射线钩子已挂载", "success")
    end
end
installRaycast()

-- Ragdoll / anti-pull / ghost module hooks
local ragdollHooked = false
local function installRagdollHook()
    if ragdollHooked then
        return
    end
    pcall(function()
        local modules = ReplicatedStorage:FindFirstChild("Modules")
        local ragdollModule = modules and modules:FindFirstChild("Ragdoll")
        if not ragdollModule then
            return
        end
        local ragdoll = require(ragdollModule)
        if ragdoll and ragdoll.activate then
            local original = ragdoll.activate
            ragdoll.activate = function(a, b, c, ...)
                if Settings.noRagdoll and b then
                    return
                end
                return original(a, b, c, ...)
            end
            if ragdoll.activateServer then
                local originalServer = ragdoll.activateServer
                ragdoll.activateServer = function(a, b, c, ...)
                    if Settings.noRagdoll and b then
                        return
                    end
                    return originalServer(a, b, c, ...)
                end
            end
            ragdollHooked = true
        end
    end)
end
installRagdollHook()

local algorithmsRef = nil
local algorithmsOriginal = nil
local function setAntiPull(on)
    pcall(function()
        local modules = ReplicatedStorage:FindFirstChild("Modules")
        local algorithmsModule = modules and modules:FindFirstChild("Algorithms")
        if not algorithmsModule then
            return
        end
        local algorithms = require(algorithmsModule)
        algorithmsRef = algorithms
        if on and not algorithmsOriginal then
            algorithmsOriginal = algorithms.charPivotTo
            algorithms.charPivotTo = function()
                return nil
            end
        elseif not on and algorithmsOriginal then
            algorithms.charPivotTo = algorithmsOriginal
            algorithmsOriginal = nil
        end
    end)
end

local function firePrompt(prompt)
    if not prompt then
        return
    end
    pcall(function()
        if firepromptFn then
            firepromptFn(prompt, 0)
        else
            prompt.HoldDuration = 0
            prompt:InputHoldBegin()
            task.wait(0.08)
            prompt:InputHoldEnd()
        end
    end)
end

TYHubPromptDebounce = setmetatable({}, { __mode = "k" })
pcall(function()
    local promptService = game:GetService("ProximityPromptService")
    local promptEvent = promptService and promptService.PromptButtonHoldBegan
    if not promptEvent then
        return
    end
    promptEvent:Connect(function(prompt)
        if not Settings.instantPrompt or not prompt then
            return
        end
        local now = tick()
        local last = TYHubPromptDebounce[prompt]
        if last and now - last < 0.25 then
            return
        end
        TYHubPromptDebounce[prompt] = now
        pcall(firePrompt, prompt)
    end)
end)

local function objectPosition(instance)
    if not instance or not instance.Parent then
        return nil
    end
    local parent = instance.Parent
    if parent:IsA("BasePart") then
        return parent.Position
    end
    if parent:IsA("Attachment") then
        return parent.WorldPosition
    end
    if parent:IsA("Model") then
        local primary = parent.PrimaryPart or parent:FindFirstChildWhichIsA("BasePart")
        return primary and primary.Position or nil
    end
    return nil
end

local function teleportTo(position)
    if not position then
        return
    end
    local char = LocalPlayer.Character
    if not char then
        return
    end
    local cframe = CFrame.new(position + Vector3.new(0, 3, 0))
    pcall(function()
        char:PivotTo(cframe)
    end)
    if PlayerEvent then
        pcall(function()
            local id = (tonumber(char:GetAttribute("CharPivotToId")) or 0) + 1
            id = id % 100
            char:SetAttribute("CharPivotToId", id)
            PlayerEvent:FireServer("charPivotTo", cframe, char, id)
        end)
    end
end

local BlinkState = { last = 0 }

function TYHubBlink()
    if not Settings.blink then
        Notify("Blink", "请先开启 Blink", "warn")
        return
    end
    local now = tick()
    if now - BlinkState.last < 0.25 then
        return
    end
    local cam = Workspace.CurrentCamera
    if not cam then
        return
    end
    local mouse = UserInputService:GetMouseLocation()
    if UserInputService.TouchEnabled then
        mouse = Vector2.new(cam.ViewportSize.X / 2, cam.ViewportSize.Y / 2)
    end
    if mouse.X == 0 and mouse.Y == 0 then
        mouse = Vector2.new(cam.ViewportSize.X / 2, cam.ViewportSize.Y / 2)
    end
    local ray = cam:ScreenPointToRay(mouse.X, mouse.Y)
    local filter = {}
    if LocalPlayer.Character then
        table.insert(filter, LocalPlayer.Character)
    end
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = filter
    params.IgnoreWater = true
    local distance = math.clamp(Settings.blinkDistance or 120, 10, 1000)
    local result = Workspace:Raycast(ray.Origin, ray.Direction * (distance * 4), params)
    local target
    if result then
        target = result.Position + result.Normal * 3
    else
        target = ray.Origin + ray.Direction * distance
    end
    BlinkState.last = now
    teleportTo(target)
    log(string.format("Blink %.0f studs", (target - ray.Origin).Magnitude), "info")
end

--============================  GHOST  ============================--

local ghostGui = nil
local ghostButton = nil
local ghostParent = guiParent
local ghostBtnPos = UDim2.new(0, 100, 0.5, -25)

local function applyGhostBody(char, on)
    if not char then
        return
    end
    for _, descendant in ipairs(char:GetDescendants()) do
        if descendant:IsA("BasePart") and descendant.Name ~= "HumanoidRootPart" then
            descendant.LocalTransparencyModifier = on and 0.55 or 0
            descendant.Material = on and Enum.Material.ForceField or Enum.Material.SmoothPlastic
        elseif descendant:IsA("Decal") and descendant.Name == "face" then
            descendant.Transparency = on and 0.55 or 0
        end
    end
end

local GhostState = { exposedUntil = 0 }

function TYHubGhostHide()
    local char = LocalPlayer.Character
    if not char then
        return
    end
    pcall(function()
        char:SetAttribute("Invisible", true)
    end)
    applyGhostBody(char, true)
    pcall(function()
        local stuff = ReplicatedStorage:FindFirstChild("Stuff")
        local locations = stuff and stuff:FindFirstChild("Locations")
        local location = locations and locations:GetChildren()[1]
        if PlayerFunc and location then
            PlayerFunc:InvokeServer("hideCharacterLocation", location)
        end
    end)
    if ghostButton then
        ghostButton.Text = "隐身  开"
        ghostButton.TextColor3 = Theme.accent3
    end
end

function TYHubGhostShow()
    local char = LocalPlayer.Character
    if char then
        pcall(function()
            char:SetAttribute("Invisible", nil)
        end)
        applyGhostBody(char, false)
    end
    pcall(function()
        if PlayerFunc then
            PlayerFunc:InvokeServer("hideCharacterLocation", false)
        end
    end)
    if ghostButton then
        if Settings.ghost then
            ghostButton.Text = "现身中"
            ghostButton.TextColor3 = Theme.amber
        else
            ghostButton.Text = "隐身  关"
            ghostButton.TextColor3 = Theme.red
        end
    end
end

function TYHubGhostExpose(seconds)
    if not Settings.ghost then
        Notify("Ghost", "请先开启隐身", "warn")
        return
    end
    local duration = tonumber(seconds) or Settings.ghostExposeTime or 4
    GhostState.exposedUntil = tick() + duration
    TYHubGhostShow()
    Notify("Ghost", string.format("短暂现身 %.1f 秒", duration), "warn")
end

function TYHubGhostResume()
    GhostState.exposedUntil = 0
    if Settings.ghost then
        TYHubGhostHide()
    end
end

local function setGhost(on)
    Settings.ghost = on
    local char = LocalPlayer.Character
    if not char then
        return
    end
    GhostState.exposedUntil = 0

    if on then
        TYHubGhostHide()
        pcall(function()
            if InventoryModule and InventoryModule.canEquipSlot then
                InventoryModule.canEquipSlot(true)
            end
        end)
        pcall(function()
            if CharacterModule and CharacterModule.lockHumanoidState then
                CharacterModule.lockHumanoidState("ghostMode", nil)
            end
        end)
        pcall(function()
            GuiService.TouchControlsEnabled = true
            ContextActionService:UnbindAction("LoadingGuiNoResetOnDeath")
            ContextActionService:UnbindAction("DisableCameraMovementNoResetOnDeath")
        end)
        log("隐身已开启", "success")
    else
        TYHubGhostShow()
        log("隐身已关闭", "info")
    end
end

local function buildGhostHud()
    if ghostGui then
        ghostGui:Destroy()
    end
    ghostGui = make("ScreenGui", {
        Name = "TYHubGhostHud",
        ResetOnSpawn = false,
        DisplayOrder = 998,
    })
    local ghostParentOk = pcall(function()
        ghostGui.Parent = ghostParent
    end)
    if not ghostParentOk then
        ghostGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    end

    ghostButton = make("TextButton", {
        Size = UDim2.fromOffset(92, 34),
        Position = ghostBtnPos,
        BackgroundColor3 = Color3.fromRGB(14, 9, 26),
        BackgroundTransparency = 0.2,
        Text = Settings.ghost and "隐身  开" or "隐身  关",
        Font = Enum.Font.GothamBold,
        TextSize = 11,
        TextColor3 = Settings.ghost and Theme.accent3 or Theme.red,
        AutoButtonColor = false,
    }, ghostGui)
    corner(ghostButton, 9)
    local s = stroke(ghostButton, Theme.accent, 1.4, 0.3)
    gradient(s, Theme.accent, Theme.accent2, 20)

    ghostButton.Active = not Settings.ghostLock
    ghostButton.Draggable = not Settings.ghostLock
    ghostButton.MouseButton1Click:Connect(function()
        setGhost(not Settings.ghost)
    end)
    ghostButton:GetPropertyChangedSignal("Position"):Connect(function()
        if not Settings.ghostLock then
            ghostBtnPos = ghostButton.Position
        end
    end)
end

local function setGhostHud(on)
    Settings.ghostHud = on
    if on then
        buildGhostHud()
    elseif ghostGui then
        ghostGui:Destroy()
        ghostGui = nil
        ghostButton = nil
    end
end

local function setGhostLock(on)
    Settings.ghostLock = on
    if ghostButton then
        ghostButton.Active = not on
        ghostButton.Draggable = not on
    end
end

--============================  HITBOX  ============================--

local hitboxCache = {}

local function clearHitbox(root)
    local cache = hitboxCache[root]
    if cache then
        pcall(function()
            root.Size = cache.Size
            root.Transparency = cache.Transparency
            root.Material = cache.Material
            root.CanCollide = cache.CanCollide
            root.Color = cache.Color
        end)
        hitboxCache[root] = nil
    end
    pcall(function()
        local outline = root:FindFirstChild("TYHubHitboxHighlight")
        if outline then
            outline:Destroy()
        end
        local light = root:FindFirstChild("TYHubHitboxLight")
        if light then
            light:Destroy()
        end
    end)
end

local function applyHitbox(char)
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then
        return
    end
    if not hitboxCache[root] then
        hitboxCache[root] = {
            Size = root.Size,
            Transparency = root.Transparency,
            Material = root.Material,
            CanCollide = root.CanCollide,
            Color = root.Color,
        }
    end
    if not Settings.hitbox then
        clearHitbox(root)
        return
    end
    local size = Settings.hitboxSize
    if Settings.hitboxPulse then
        size = size * (1 + math.sin(tick() * 4) * 0.12)
    end
    root.Size = Vector3.new(size, size, size)
    root.Transparency = Settings.hitboxTransparency
    root.Material = Enum.Material.Neon
    root.CanCollide = false
    root.Color = colorOf(Settings.hitboxColor or "紫色")

    local outline = root:FindFirstChild("TYHubHitboxHighlight")
    if Settings.hitboxOutline then
        if not outline then
            outline = make("Highlight", { Name = "TYHubHitboxHighlight" }, root)
        end
        outline.FillTransparency = 1
        outline.OutlineColor = root.Color
        outline.OutlineTransparency = Settings.hitboxTransparency
    elseif outline then
        outline:Destroy()
    end

    local light = root:FindFirstChild("TYHubHitboxLight")
    if Settings.hitboxGlow then
        if not light then
            light = make("PointLight", { Name = "TYHubHitboxLight" }, root)
        end
        light.Brightness = 5
        light.Range = 15
        light.Color = root.Color
    elseif light then
        light:Destroy()
    end
end

local function clearAllHitboxes()
    for root in pairs(hitboxCache) do
        if root and root.Parent then
            clearHitbox(root)
        end
    end
    hitboxCache = {}
end

--============================  RANGE SPHERE  ============================--

local rangePart = nil

local function updateRangeSphere()
    if not Settings.rangeEnabled then
        if rangePart then
            pcall(function()
                rangePart:Destroy()
            end)
            rangePart = nil
        end
        return
    end
    local _, _, root = getChar(LocalPlayer)
    if not root then
        return
    end
    if not rangePart or not rangePart.Parent then
        rangePart = Instance.new("Part")
        rangePart.Name = "TYHubRangeSphere"
        rangePart.Shape = Enum.PartType.Ball
        rangePart.Anchored = true
        rangePart.CanCollide = false
        rangePart.CanQuery = false
        rangePart.CanTouch = false
        rangePart.CastShadow = false
        rangePart.Parent = Workspace
    end
    local size = Settings.rangeSize * 2
    if Settings.rangePulse then
        size = size * (1 + math.sin(tick() * 3) * 0.03)
    end
    local color = colorOf(Settings.rangeColor)
    rangePart.Size = Vector3.new(size, size, size)
    rangePart.Position = root.Position
    rangePart.Transparency = Settings.rangeTransparency
    rangePart.Color = color
    rangePart.Material = Enum.Material[Settings.rangeMaterial] or Enum.Material.Neon
    rangePart.CanCollide = Settings.rangeCollision

    local outline = rangePart:FindFirstChild("TYHubRangeHighlight")
    if Settings.rangeOutline then
        if not outline then
            outline = Instance.new("Highlight")
            outline.Name = "TYHubRangeHighlight"
            outline.Parent = rangePart
        end
        outline.FillTransparency = 1
        outline.OutlineColor = color
        outline.OutlineTransparency = Settings.rangeTransparency
    elseif outline then
        outline:Destroy()
    end

    local glow = rangePart:FindFirstChild("TYHubRangeLight")
    if Settings.rangeGlow then
        if not glow then
            glow = Instance.new("PointLight")
            glow.Name = "TYHubRangeLight"
            glow.Parent = rangePart
        end
        glow.Brightness = 3
        glow.Range = math.max(Settings.rangeSize, 20)
        glow.Color = color
    elseif glow then
        glow:Destroy()
    end
end

--============================  MOVEMENT  ============================--

local FlyState = {
    active = false,
    mode = nil,
    anchored = false,
    root = nil,
    bodyVelocity = nil,
    bodyGyro = nil,
    attachment = nil,
    velocity = nil,
}

local flyWasOn = false

local function clearFlyVelocity()
    if FlyState.bodyVelocity then
        pcall(function()
            FlyState.bodyVelocity:Destroy()
        end)
        FlyState.bodyVelocity = nil
    end
    if FlyState.bodyGyro then
        pcall(function()
            FlyState.bodyGyro:Destroy()
        end)
        FlyState.bodyGyro = nil
    end
    if FlyState.velocity then
        pcall(function()
            FlyState.velocity:Destroy()
        end)
        FlyState.velocity = nil
    end
    if FlyState.attachment then
        pcall(function()
            FlyState.attachment:Destroy()
        end)
        FlyState.attachment = nil
    end
end

local function startFly(root, humanoid, mode)
    clearFlyVelocity()
    FlyState.active = true
    FlyState.mode = mode
    FlyState.root = root
    FlyState.anchored = false
    pcall(function()
        humanoid.AutoRotate = false
    end)
    pcall(function()
        root.AssemblyLinearVelocity = Vector3.zero
        root.AssemblyAngularVelocity = Vector3.zero
    end)

    if mode == "物理" then
        pcall(function()
            humanoid.PlatformStand = true
        end)
        local bodyVelocity = Instance.new("BodyVelocity")
        bodyVelocity.Name = "TYHubFlyVelocity"
        bodyVelocity.MaxForce = Vector3.new(9e9, 9e9, 9e9)
        bodyVelocity.Velocity = Vector3.zero
        bodyVelocity.Parent = root
        FlyState.bodyVelocity = bodyVelocity

        local bodyGyro = Instance.new("BodyGyro")
        bodyGyro.Name = "TYHubFlyGyro"
        bodyGyro.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
        bodyGyro.P = 90000
        bodyGyro.Parent = root
        FlyState.bodyGyro = bodyGyro
    else
        pcall(function()
            humanoid.PlatformStand = false
            humanoid:ChangeState(Enum.HumanoidStateType.Climbing)
            root.Anchored = false
        end)
    end
    log("飞行已开启 · " .. tostring(mode), "success")
end

local function stopFly()
    clearFlyVelocity()
    local character, humanoid, root = getChar(LocalPlayer)
    if FlyState.root and FlyState.root.Parent then
        root = FlyState.root
        character = root.Parent
        humanoid = character and character:FindFirstChildOfClass("Humanoid")
    end
    if root then
        if FlyState.anchored then
            pcall(function()
                root.Anchored = false
            end)
        end
        pcall(function()
            root.AssemblyLinearVelocity = Vector3.zero
            root.AssemblyAngularVelocity = Vector3.zero
        end)
    end
    if humanoid then
        pcall(function()
            humanoid.PlatformStand = false
            humanoid.AutoRotate = true
            humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
        end)
    end
    if FlyState.active then
        log("飞行已关闭", "info")
    end
    FlyState.active = false
    FlyState.anchored = false
    FlyState.mode = nil
    FlyState.root = nil
end

local function moveDirection()
    local cam = Workspace.CurrentCamera
    if not cam then
        return Vector3.zero
    end
    local dir = Vector3.zero
    local look = cam.CFrame.LookVector
    local right = cam.CFrame.RightVector
    if UserInputService:IsKeyDown(Enum.KeyCode.W) then
        dir = dir + look
    end
    if UserInputService:IsKeyDown(Enum.KeyCode.S) then
        dir = dir - look
    end
    if UserInputService:IsKeyDown(Enum.KeyCode.D) then
        dir = dir + right
    end
    if UserInputService:IsKeyDown(Enum.KeyCode.A) then
        dir = dir - right
    end
    if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
        dir = dir + Vector3.new(0, 1, 0)
    end
    if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
        dir = dir - Vector3.new(0, 1, 0)
    end
    local moveVector = nil
    if PlayerControls then
        pcall(function()
            moveVector = PlayerControls:GetMoveVector()
        end)
    end
    if not moveVector or moveVector.Magnitude < 0.05 then
        pcall(function()
            moveVector = UserInputService:GetMoveVector()
        end)
    end
    if moveVector and moveVector.Magnitude > 0.05 then
        dir = dir + cam.CFrame.LookVector * (-moveVector.Z) + cam.CFrame.RightVector * moveVector.X
    end
    if dir.Magnitude > 0 then
        dir = dir.Unit
    end
    return dir
end

local function setNoclip(on)
    Settings.noclip = on
    if not on then
        local char = LocalPlayer.Character
        if char then
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = true
                end
            end
        end
    end
end

--============================  VEHICLE  ============================--

local VehicleState = {
    attachment = nil,
    velocity = nil,
    part = nil,
    flyAttachment = nil,
    flyVelocity = nil,
    flyPart = nil,
}

local function clearVehicleForce()
    if VehicleState.velocity then
        pcall(function()
            VehicleState.velocity:Destroy()
        end)
    end
    if VehicleState.attachment then
        pcall(function()
            VehicleState.attachment:Destroy()
        end)
    end
    VehicleState.velocity = nil
    VehicleState.attachment = nil
    VehicleState.part = nil
end

local function getVehicleSeat()
    local _, humanoid = getChar(LocalPlayer)
    if humanoid and humanoid.SeatPart and humanoid.SeatPart:IsA("VehicleSeat") then
        return humanoid.SeatPart
    end
    if humanoid and humanoid.SeatPart then
        return humanoid.SeatPart
    end
    return nil
end

function TYHubSeatChassis(seat)
    if not seat then
        return nil
    end
    local model = seat:FindFirstAncestorOfClass("Model")
    if model then
        local chassis = model:FindFirstChild("_Chassis")
        if chassis and chassis:IsA("BasePart") then
            return chassis
        end
    end
    return seat
end

function TYHubClearVehicleFly()
    if VehicleState.flyVelocity then
        pcall(function()
            VehicleState.flyVelocity:Destroy()
        end)
    end
    if VehicleState.flyAttachment then
        pcall(function()
            VehicleState.flyAttachment:Destroy()
        end)
    end
    VehicleState.flyVelocity = nil
    VehicleState.flyAttachment = nil
    VehicleState.flyPart = nil
end

function TYHubUpdateVehicleFly(dt)
    if not Settings.vehicleFly then
        TYHubClearVehicleFly()
        return
    end
    local seat = getVehicleSeat()
    if not seat then
        TYHubClearVehicleFly()
        return
    end
    local chassis = TYHubSeatChassis(seat) or seat
    if VehicleState.flyPart ~= chassis or not VehicleState.flyVelocity then
        TYHubClearVehicleFly()
        local attachment = make("Attachment", { Name = "TYHubVehFlyAttachment" }, chassis)
        local velocity = make("LinearVelocity", {
            Name = "TYHubVehFlyVelocity",
            Attachment0 = attachment,
            MaxForce = math.huge,
            VectorVelocity = Vector3.zero,
        }, chassis)
        VehicleState.flyAttachment = attachment
        VehicleState.flyVelocity = velocity
        VehicleState.flyPart = chassis
    end
    if VehicleState.flyVelocity then
        VehicleState.flyVelocity.VectorVelocity = moveDirection() * Settings.vehicleFlySpeed
    end
end

--============================  AIM / SILENT  ============================--

local hasDrawing = type(Drawing) == "table" and Drawing.new ~= nil
local Draw = {
    fov = nil,
    tracer = nil,
    cross = {},
    silentFov = nil,
    silentLine = nil,
}

if hasDrawing then
    pcall(function()
        Draw.fov = Drawing.new("Circle")
        Draw.fov.Filled = false
        Draw.fov.NumSides = 64
        Draw.fov.Thickness = 1.5
        Draw.fov.Visible = false

        Draw.tracer = Drawing.new("Line")
        Draw.tracer.Thickness = 1
        Draw.tracer.Visible = false

        for i = 1, 5 do
            local line = Drawing.new("Line")
            line.Thickness = 1.5
            line.Visible = false
            Draw.cross[i] = line
        end

        Draw.silentFov = Drawing.new("Circle")
        Draw.silentFov.Filled = false
        Draw.silentFov.NumSides = 64
        Draw.silentFov.Thickness = 1
        Draw.silentFov.Visible = false

        Draw.silentLine = Drawing.new("Line")
        Draw.silentLine.Thickness = 1
        Draw.silentLine.Visible = false
    end)
end

local function visibleFromCamera(part)
    local cam = Workspace.CurrentCamera
    if not cam or not part then
        return false
    end
    local filter = {}
    if LocalPlayer.Character then
        table.insert(filter, LocalPlayer.Character)
    end
    table.insert(filter, cam)
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = filter
    params.IgnoreWater = true
    local hit = Workspace:Raycast(cam.CFrame.Position, part.Position - cam.CFrame.Position, params)
    return not hit or hit.Instance:IsDescendantOf(part.Parent)
end

local function findTarget(opts)
    local cam = Workspace.CurrentCamera
    if not cam then
        return nil
    end
    local center = Vector2.new(cam.ViewportSize.X / 2, cam.ViewportSize.Y / 2)
    local best = nil
    local bestScore = math.huge
    local _, _, myRoot = getChar(LocalPlayer)

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and isAlive(player) and passesFilter(player, opts.police, opts.civilian) then
            local skip = false
            if opts.team and LocalPlayer.Team and player.Team and player.Team == LocalPlayer.Team then
                skip = true
            end
            if not skip and opts.friend and isFriend(player) then
                skip = true
            end
            if not skip and opts.combat and not inCombat(player) then
                skip = true
            end

            if not skip then
                local char = player.Character
                local humanoid = char and char:FindFirstChildOfClass("Humanoid")
                local part = char and (char:FindFirstChild(opts.partName) or char:FindFirstChild("HumanoidRootPart"))
                if part and humanoid and humanoid.Health > 0 then
                    local visible = true
                    if opts.wall then
                        visible = visibleFromCamera(part)
                    end
                    if visible then
                        local screen, onScreen = screenPosition(part.Position)
                        if onScreen then
                            local score = (screen - center).Magnitude
                            if score <= opts.fov then
                                if opts.mode == "距离最近" and myRoot then
                                    score = (myRoot.Position - part.Position).Magnitude
                                elseif opts.mode == "血量最低" then
                                    score = humanoid.Health
                                end
                                if score < bestScore then
                                    bestScore = score
                                    best = {
                                        player = player,
                                        part = part,
                                        humanoid = humanoid,
                                        screen = screen,
                                    }
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    return best
end

local lastAimTarget = nil
local aimAccent = Theme.accent

local function updateAimDrawings(dt)
    local cam = Workspace.CurrentCamera
    if not cam then
        return
    end
    local center = Vector2.new(cam.ViewportSize.X / 2, cam.ViewportSize.Y / 2)
    aimAccent = colorOf(Settings.aimColor)

    local holding
    if UserInputService.TouchEnabled then
        holding = true
    else
        holding = not Settings.aimHold or UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2)
    end
    local active = Settings.aim and holding

    if Draw.fov then
        Draw.fov.Position = center
        Draw.fov.Radius = Settings.aimFov
        Draw.fov.Thickness = Settings.aimFovThickness
        Draw.fov.Color = aimAccent
        Draw.fov.Transparency = 0.85
        Draw.fov.Visible = Settings.aimShowFov and (Settings.aim and holding)
    end

    if Draw.cross[1] then
        local gap = 5
        local len = 13
        local lines = {
            { Vector2.new(center.X, center.Y - gap), Vector2.new(center.X, center.Y - gap - len) },
            { Vector2.new(center.X, center.Y + gap), Vector2.new(center.X, center.Y + gap + len) },
            { Vector2.new(center.X - gap, center.Y), Vector2.new(center.X - gap - len, center.Y) },
            { Vector2.new(center.X + gap, center.Y), Vector2.new(center.X + gap + len, center.Y) },
            { Vector2.new(center.X - 2, center.Y), Vector2.new(center.X + 2, center.Y) },
        }
        for i, line in ipairs(Draw.cross) do
            line.From = lines[i][1]
            line.To = lines[i][2]
            line.Color = aimAccent
            line.Transparency = 0.7
            line.Visible = Settings.aimCrosshair and Settings.aim
        end
    end

    lastAimTarget = nil
    if active then
        local target = findTarget({
            partName = AimParts[Settings.aimPart] or "Head",
            fov = Settings.aimFov,
            team = Settings.aimTeam,
            friend = Settings.aimFriend,
            wall = Settings.aimWall,
            combat = Settings.aimCombat,
            police = Settings.aimPolice,
            civilian = Settings.aimCivilian,
            mode = Settings.aimMode,
        })
        local smoothValue = math.clamp(1 - Settings.aimSmooth / 110, 0.05, 1)
        if target then
            lastAimTarget = target
            local aimPosition = target.part.Position
            if Settings.aimPredict then
                aimPosition = aimPosition + target.part.AssemblyLinearVelocity * 0.12
            end
            local goal = CFrame.new(cam.CFrame.Position, aimPosition)
            cam.CFrame = cam.CFrame:Lerp(goal, smoothValue)
        elseif Settings.aimVehicles then
            local vehicle = TYHubFindVehicleTarget(Settings.aimFov)
            if vehicle then
                local goal = CFrame.new(cam.CFrame.Position, vehicle.part.Position)
                cam.CFrame = cam.CFrame:Lerp(goal, smoothValue)
                lastAimTarget = { screen = vehicle.screen }
            end
        end
    end

    if Draw.tracer then
        if Settings.aim and Settings.aimTracer and lastAimTarget then
            Draw.tracer.From = center
            Draw.tracer.To = lastAimTarget.screen
            Draw.tracer.Color = aimAccent
            Draw.tracer.Transparency = 0.55
            Draw.tracer.Visible = true
        else
            Draw.tracer.Visible = false
        end
    end
end

local function updateSilent(dt)
    local cam = Workspace.CurrentCamera
    if not cam then
        return
    end
    local center = Vector2.new(cam.ViewportSize.X / 2, cam.ViewportSize.Y / 2)
    silentTargetRef = nil

    if Settings.silent then
        local target = findTarget({
            partName = AimParts[Settings.silentPart] or "Head",
            fov = Settings.silentFov,
            team = Settings.silentTeam,
            friend = Settings.silentFriend,
            wall = false,
            combat = Settings.silentCombat,
            police = Settings.silentPolice,
            civilian = Settings.silentCivilian,
            mode = "准心最近",
        })
        if target and target.part then
            local dist = (target.part.Position - cam.CFrame.Position).Magnitude
            if dist <= Settings.silentDistance then
                silentTargetRef = target.part.Position
            end
        end
    end

    if Draw.silentFov then
        Draw.silentFov.Position = center
        Draw.silentFov.Radius = Settings.silentFov
        Draw.silentFov.Color = aimAccent
        Draw.silentFov.Transparency = 0.5
        Draw.silentFov.Visible = Settings.silent and Settings.silentShowFov
    end

    if Draw.silentLine then
        if Settings.silent and silentTargetRef then
            local screen, onScreen = screenPosition(silentTargetRef)
            Draw.silentLine.From = center
            Draw.silentLine.To = screen
            Draw.silentLine.Color = aimAccent
            Draw.silentLine.Transparency = 0.6
            Draw.silentLine.Visible = onScreen
        else
            Draw.silentLine.Visible = false
        end
    end
end

--============================  ESP  ============================--

local EspFolder = make("ScreenGui", {
    Name = "TYHubESP",
    ResetOnSpawn = false,
    IgnoreGuiInset = true,
    DisplayOrder = 997,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
})
local espParentOk = pcall(function()
    EspFolder.Parent = guiParent
end)
if not espParentOk then
    EspFolder.Parent = LocalPlayer:WaitForChild("PlayerGui")
end

local EspTrackers = {}
local espAccumulator = 0

local function espAllowed(player)
    if not Settings.esp or player == LocalPlayer then
        return false
    end
    if not isAlive(player) then
        return false
    end
    if Settings.espFugitive and isFugitive(player) then
        return true
    end
    local selected = Settings.espTeams
    local count, total = 0, 0
    for _, value in pairs(selected) do
        total = total + 1
        if value then
            count = count + 1
        end
    end
    if count == 0 or count >= total then
        return true
    end
    return selected[teamOf(player)] == true
end

local function destroyTracker(player)
    local t = EspTrackers[player]
    if not t then
        return
    end
    pcall(function()
        if t.billboard then
            t.billboard:Destroy()
        end
        if t.highlight then
            t.highlight:Destroy()
        end
        for _, line in ipairs(t.lines) do
            line:Remove()
        end
        if t.healthBg then
            t.healthBg:Remove()
        end
        if t.healthFill then
            t.healthFill:Remove()
        end
        if t.tracer then
            t.tracer:Remove()
        end
    end)
    EspTrackers[player] = nil
end

local function createTracker(player)
    local char = player.Character
    if not char then
        return
    end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then
        return
    end

    local billboard = make("BillboardGui", {
        Name = "TYHubESP_" .. player.Name,
        AlwaysOnTop = true,
        Size = UDim2.new(9, 0, 2.8, 0),
        StudsOffset = Vector3.new(0, 3.3, 0),
        MaxDistance = 10000,
        Adornee = root,
    }, EspFolder)

    local nameLabel = make("TextLabel", {
        Size = UDim2.new(1, 0, 0.55, 0),
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamBold,
        TextSize = 13,
        TextStrokeTransparency = 0.25,
        TextColor3 = Theme.accent3,
        Text = player.Name,
    }, billboard)

    local infoLabel = make("TextLabel", {
        Size = UDim2.new(1, 0, 0.45, 0),
        Position = UDim2.new(0, 0, 0.55, 0),
        BackgroundTransparency = 1,
        Font = Enum.Font.Gotham,
        TextSize = 11,
        TextStrokeTransparency = 0.3,
        TextColor3 = Theme.text,
        Text = "",
    }, billboard)

    local highlight = make("Highlight", {
        Name = "TYHubESP_Highlight",
        Adornee = char,
        FillTransparency = 0.85,
        OutlineTransparency = 0.15,
    }, char)
    pcall(function()
        highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    end)

    local lines = {}
    local healthBg = nil
    local healthFill = nil
    if hasDrawing then
        for i = 1, 8 do
            local line = Drawing.new("Line")
            line.Thickness = 1.2
            line.Transparency = 0.2
            line.Visible = false
            lines[i] = line
        end
        healthBg = Drawing.new("Line")
        healthBg.Thickness = 3
        healthBg.Transparency = 0.45
        healthBg.Visible = false
        healthFill = Drawing.new("Line")
        healthFill.Thickness = 3
        healthFill.Transparency = 0.1
        healthFill.Visible = false
    end

    local tracer = nil
    if hasDrawing then
        tracer = Drawing.new("Line")
        tracer.Thickness = 1
        tracer.Transparency = 0.55
        tracer.Visible = false
    end

    EspTrackers[player] = {
        billboard = billboard,
        nameLabel = nameLabel,
        infoLabel = infoLabel,
        highlight = highlight,
        lines = lines,
        healthBg = healthBg,
        healthFill = healthFill,
        tracer = tracer,
    }
end

local function updateTracker(player)
    local t = EspTrackers[player]
    if not t then
        return
    end
    local char, humanoid, root = getChar(player)
    if char and (t.billboard.Adornee ~= root or t.highlight.Parent ~= char) then
        destroyTracker(player)
        pcall(createTracker, player)
        return
    end
    if not char or not root or not espAllowed(player) then
        t.billboard.Enabled = false
        t.highlight.Enabled = false
        for _, line in ipairs(t.lines) do
            line.Visible = false
        end
        if t.healthBg then
            t.healthBg.Visible = false
        end
        if t.healthFill then
            t.healthFill.Visible = false
        end
        if t.tracer then
            t.tracer.Visible = false
        end
        return
    end

    local team = teamOf(player)
    local fugitive = isFugitive(player)
    local color = fugitive and Color3.fromRGB(255, 70, 70) or TeamColors[team] or Theme.accent

    t.billboard.Adornee = root
    t.billboard.Enabled = Settings.espName or Settings.espDistance or Settings.espHealth
    t.nameLabel.Visible = Settings.espName
    t.nameLabel.Text = player.Name
    t.nameLabel.TextColor3 = color

    local _, _, myRoot = getChar(LocalPlayer)
    local info = { fugitive and "逃犯" or TeamNames[team] or team }
    if Settings.espDistance and myRoot then
        table.insert(info, string.format("%.0fm", (myRoot.Position - root.Position).Magnitude))
    end
    if Settings.espHealth and humanoid then
        table.insert(info, math.floor(humanoid.Health) .. "HP")
    end
    t.infoLabel.Text = table.concat(info, "  ·  ")
    t.infoLabel.TextColor3 = Color3.fromRGB(232, 222, 248)
    t.infoLabel.Visible = #info > 1

    t.highlight.Adornee = char
    t.highlight.Enabled = Settings.espHighlight
    t.highlight.FillColor = color
    t.highlight.OutlineColor = color

    local cam = Workspace.CurrentCamera
    if cam and hasDrawing then
        local head = char:FindFirstChild("Head") or root
        local topScreen, topOn = screenPosition(head.Position + Vector3.new(0, 0.55, 0))
        local bottomScreen, bottomOn = screenPosition(root.Position - Vector3.new(0, 2.7, 0))
        if topOn and bottomOn and Settings.espBox then
            local height = math.abs(bottomScreen.Y - topScreen.Y)
            local width = height * 0.58
            local x = topScreen.X - width / 2
            local y = topScreen.Y
            local length = math.clamp(math.min(width, height) * 0.22, 6, 18)
            local segments = {
                { Vector2.new(x, y), Vector2.new(x + length, y) },
                { Vector2.new(x, y), Vector2.new(x, y + length) },
                { Vector2.new(x + width, y), Vector2.new(x + width - length, y) },
                { Vector2.new(x + width, y), Vector2.new(x + width, y + length) },
                { Vector2.new(x, y + height), Vector2.new(x + length, y + height) },
                { Vector2.new(x, y + height), Vector2.new(x, y + height - length) },
                { Vector2.new(x + width, y + height), Vector2.new(x + width - length, y + height) },
                { Vector2.new(x + width, y + height), Vector2.new(x + width, y + height - length) },
            }
            for i, line in ipairs(t.lines) do
                line.From = segments[i][1]
                line.To = segments[i][2]
                line.Color = color
                line.Thickness = 1.2
                line.Transparency = 0.15
                line.Visible = true
            end

            local hp = humanoid and math.clamp(humanoid.Health / math.max(humanoid.MaxHealth, 1), 0, 1) or 1
            if t.healthBg and t.healthFill then
                if Settings.espHealth and humanoid then
                    local barX = x - 7
                    t.healthBg.From = Vector2.new(barX, y)
                    t.healthBg.To = Vector2.new(barX, y + height)
                    t.healthBg.Color = Color3.fromRGB(10, 6, 18)
                    t.healthBg.Visible = true
                    t.healthFill.From = Vector2.new(barX, y + height)
                    t.healthFill.To = Vector2.new(barX, y + height - height * hp)
                    local healthColor = Color3.fromRGB(74, 222, 128)
                    if hp <= 0.55 then
                        healthColor = Color3.fromRGB(251, 191, 36)
                    end
                    if hp <= 0.28 then
                        healthColor = Color3.fromRGB(248, 113, 113)
                    end
                    t.healthFill.Color = healthColor
                    t.healthFill.Visible = true
                else
                    t.healthBg.Visible = false
                    t.healthFill.Visible = false
                end
            end
        else
            for _, line in ipairs(t.lines) do
                line.Visible = false
            end
            if t.healthBg then
                t.healthBg.Visible = false
            end
            if t.healthFill then
                t.healthFill.Visible = false
            end
        end

        if t.tracer then
            if Settings.espTracer and topOn then
                local size = cam.ViewportSize
                local from = Vector2.new(size.X / 2, size.Y)
                if Settings.espTracerOrigin == "屏幕中心" then
                    from = Vector2.new(size.X / 2, size.Y / 2)
                elseif Settings.espTracerOrigin == "屏幕顶部" then
                    from = Vector2.new(size.X / 2, 0)
                end
                t.tracer.From = from
                t.tracer.To = topScreen
                t.tracer.Color = color
                t.tracer.Visible = true
            else
                t.tracer.Visible = false
            end
        end
    end
end

local function refreshEsp()
    for player in pairs(EspTrackers) do
        if not player.Parent or not espAllowed(player) then
            destroyTracker(player)
        end
    end
    if Settings.esp then
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and espAllowed(player) then
                if not EspTrackers[player] then
                    pcall(createTracker, player)
                end
            end
        end
    end
end

connect(Players.PlayerRemoving, function(player)
    destroyTracker(player)
end)

connect(Players.PlayerAdded, function(player)
    player.CharacterAdded:Connect(function()
        task.wait(0.4)
        if Settings.esp then
            destroyTracker(player)
            if espAllowed(player) then
                pcall(createTracker, player)
            end
        end
    end)
end)


--============================  VEHICLE MODULE  ============================--

TYHubVehicle = { trackers = {}, lastRefresh = 0 }

function TYHubVehicleFolder()
    local gameplay = Workspace:FindFirstChild("Gameplay")
    if gameplay then
        local folder = gameplay:FindFirstChild("Vehicles")
        if folder then
            return folder
        end
        local entities = gameplay:FindFirstChild("Entities")
        folder = entities and entities:FindFirstChild("Vehicles")
        if folder then
            return folder
        end
    end
    return Workspace:FindFirstChild("Vehicles")
end

function TYHubVehicleList()
    local list = {}
    local folder = TYHubVehicleFolder()
    if folder then
        for _, child in ipairs(folder:GetChildren()) do
            if child:IsA("Model") then
                table.insert(list, child)
            end
        end
        return list
    end
    for _, child in ipairs(Workspace:GetChildren()) do
        if child:IsA("Model") and child:FindFirstChild("_Chassis") then
            table.insert(list, child)
        end
    end
    return list
end

function TYHubVehiclePart(model)
    if not model then
        return nil
    end
    local chassis = model:FindFirstChild("_Chassis")
    if chassis and chassis:IsA("BasePart") then
        return chassis
    end
    return model.PrimaryPart or model:FindFirstChildWhichIsA("BasePart")
end

function TYHubDestroyVehicleTracker(model)
    local tracker = TYHubVehicle.trackers[model]
    if not tracker then
        return
    end
    pcall(function()
        if tracker.billboard then
            tracker.billboard:Destroy()
        end
        if tracker.highlight then
            tracker.highlight:Destroy()
        end
    end)
    TYHubVehicle.trackers[model] = nil
end

function TYHubRefreshVehicleEsp()
    if not Settings.vehicleEsp then
        for model in pairs(TYHubVehicle.trackers) do
            TYHubDestroyVehicleTracker(model)
        end
        return
    end
    local now = tick()
    if now - (TYHubVehicle.lastRefresh or 0) < 0.3 then
        return
    end
    TYHubVehicle.lastRefresh = now

    local seen = {}
    local _, _, myRoot = getChar(LocalPlayer)
    for _, model in ipairs(TYHubVehicleList()) do
        local part = TYHubVehiclePart(model)
        if part and part.Parent then
            seen[model] = true
            local tracker = TYHubVehicle.trackers[model]
            if not tracker then
                local billboard = make("BillboardGui", {
                    Name = "TYHubVehESP_" .. model.Name,
                    AlwaysOnTop = true,
                    Size = UDim2.new(9, 0, 2.2, 0),
                    StudsOffset = Vector3.new(0, 4.2, 0),
                    MaxDistance = 8000,
                    Adornee = part,
                }, EspFolder)
                local nameLabel = make("TextLabel", {
                    Size = UDim2.new(1, 0, 0.6, 0),
                    BackgroundTransparency = 1,
                    Font = Enum.Font.GothamBold,
                    TextSize = 13,
                    TextStrokeTransparency = 0,
                    TextColor3 = Theme.accent3,
                    Text = model.Name,
                }, billboard)
                local infoLabel = make("TextLabel", {
                    Size = UDim2.new(1, 0, 0.4, 0),
                    Position = UDim2.new(0, 0, 0.6, 0),
                    BackgroundTransparency = 1,
                    Font = Enum.Font.Gotham,
                    TextSize = 11,
                    TextStrokeTransparency = 0,
                    TextColor3 = Theme.text,
                    Text = "",
                }, billboard)
                local highlight = make("Highlight", {
                    Name = "TYHubVehESP_Highlight",
                    Adornee = model,
                    FillColor = Theme.accent,
                    OutlineColor = Theme.accent3,
                    FillTransparency = 0.82,
                    OutlineTransparency = 0.1,
                }, model)
                pcall(function()
                    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                end)
                tracker = {
                    billboard = billboard,
                    nameLabel = nameLabel,
                    infoLabel = infoLabel,
                    highlight = highlight,
                }
                TYHubVehicle.trackers[model] = tracker
            end

            local info = {}
            if Settings.vehicleEspDistance and myRoot then
                table.insert(info, string.format("%.0f m", (myRoot.Position - part.Position).Magnitude))
            end
            tracker.billboard.Adornee = part
            tracker.billboard.Enabled = Settings.vehicleEspName or Settings.vehicleEspDistance
            tracker.nameLabel.Visible = Settings.vehicleEspName
            tracker.nameLabel.Text = model.Name
            tracker.infoLabel.Text = table.concat(info, "  ·  ")
            tracker.infoLabel.Visible = Settings.vehicleEspDistance and #info > 0
            tracker.highlight.Adornee = model
            tracker.highlight.Enabled = Settings.vehicleEspHighlight
        end
    end

    for model in pairs(TYHubVehicle.trackers) do
        if not seen[model] or not model.Parent then
            TYHubDestroyVehicleTracker(model)
        end
    end
end

function TYHubFindVehicleTarget(fov)
    local camera = Workspace.CurrentCamera
    if not camera then
        return nil
    end
    local center = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
    local best = nil
    local bestScore = math.huge
    for _, model in ipairs(TYHubVehicleList()) do
        local part = TYHubVehiclePart(model)
        if part and part.Parent then
            local screen, onScreen = screenPosition(part.Position)
            if onScreen then
                local score = (screen - center).Magnitude
                if score <= fov and score < bestScore then
                    bestScore = score
                    best = { part = part, screen = screen, model = model }
                end
            end
        end
    end
    return best
end

function TYHubNearestVehicle(origin, skipModel)
    if not origin then
        return nil
    end
    local bestModel = nil
    local bestPart = nil
    local bestDistance = math.huge
    for _, model in ipairs(TYHubVehicleList()) do
        if model ~= skipModel then
            local part = TYHubVehiclePart(model)
            if part and part.Parent then
                local distance = (part.Position - origin).Magnitude
                if distance < bestDistance then
                    bestDistance = distance
                    bestModel = model
                    bestPart = part
                end
            end
        end
    end
    return bestModel, bestPart, bestDistance
end

function TYHubCurrentVehicleModel()
    local _, humanoid = getChar(LocalPlayer)
    local seat = humanoid and humanoid.SeatPart
    if seat then
        local model = seat:FindFirstAncestorOfClass("Model")
        if model then
            return model
        end
    end
    return nil
end

function TYHubOwnVehicle()
    local attribute = LocalPlayer:GetAttribute("BelongingVehicle")
    if typeof(attribute) == "Instance" and attribute.Parent then
        if attribute:IsA("Model") then
            return attribute
        end
        local ancestor = attribute:FindFirstAncestorOfClass("Model")
        if ancestor then
            return ancestor
        end
    end
    local function belongsToMe(model)
        local config = model and model:FindFirstChild("Config")
        local belongsTo = config and config:FindFirstChild("BelongsTo")
        if belongsTo then
            local ok, value = pcall(function()
                return belongsTo.Value
            end)
            if ok and value == LocalPlayer.UserId then
                return true
            end
        end
        return false
    end
    for _, model in ipairs(TYHubVehicleList()) do
        if belongsToMe(model) then
            return model
        end
    end
    for _, descendant in ipairs(Workspace:GetDescendants()) do
        if descendant:IsA("Model") and belongsToMe(descendant) then
            return descendant
        end
    end
    return TYHubCurrentVehicleModel()
end

function TYHubMoveVehicle(model, targetPosition)
    if not model or not targetPosition then
        return false
    end
    local chassis = TYHubVehiclePart(model)
    local pivot = model:GetPivot()
    local rotation = pivot - pivot.Position
    local target = CFrame.new(targetPosition) * rotation
    local ok = pcall(function()
        model:PivotTo(target)
    end)
    if not ok and chassis then
        pcall(function()
            chassis.CFrame = target
        end)
    end
    if chassis then
        pcall(function()
            chassis.AssemblyLinearVelocity = Vector3.zero
            chassis.AssemblyAngularVelocity = Vector3.zero
        end)
    end
    return true
end

function TYHubBringVehicleToMe(forceNearest)
    local _, humanoid, myRoot = getChar(LocalPlayer)
    if not myRoot then
        return
    end
    local currentModel = TYHubCurrentVehicleModel()
    local ownModel = (not forceNearest) and TYHubOwnVehicle() or nil
    if ownModel and humanoid and humanoid.SeatPart and currentModel == ownModel then
        Notify("带来载具", "你正在驾驶这辆载具", "warn")
        return
    end
    local model
    local isOwn = false
    if forceNearest then
        model = TYHubNearestVehicle(myRoot.Position, currentModel)
    else
        model = ownModel
        isOwn = model ~= nil
        if not model then
            Notify("带来载具", "没有找到属于你的载具", "warn")
            return
        end
    end
    if not model then
        Notify("带来载具", "附近没有找到载具", "warn")
        return
    end
    local distance = isOwn and 4 or math.clamp(Settings.bringDistance or 12, 5, 40)
    local target = myRoot.Position + myRoot.CFrame.LookVector * distance + Vector3.new(0, isOwn and 2.5 or 3, 0)
    if TYHubMoveVehicle(model, target) then
        if isOwn then
            Notify("带来载具", "已无视距离把你的 " .. model.Name .. " 传送到脸上", "success")
        else
            Notify("带来载具", "已把 " .. model.Name .. " 带到你面前", "success")
        end
    else
        Notify("带来载具", "载具移动失败", "error")
    end
end

function TYHubBringVehicleToPlayer(player, origin, forceNearest)
    if not player then
        return false
    end
    local targetRoot = getRoot(player)
    if not targetRoot then
        Notify("带来载具", "目标玩家不在场景中", "warn")
        return false
    end
    local currentModel = TYHubCurrentVehicleModel()
    local source = origin or targetRoot.Position
    local model
    if forceNearest then
        model = TYHubNearestVehicle(source, currentModel)
        if not model and source ~= targetRoot.Position then
            model = TYHubNearestVehicle(targetRoot.Position, currentModel)
        end
    else
        model = TYHubOwnVehicle()
        if model and model == currentModel then
            Notify("带来载具", "你正在驾驶这辆载具", "warn")
            return false
        end
        if not model then
            Notify("带来载具", "没有找到属于你的载具", "warn")
            return false
        end
    end
    if not model then
        Notify("带来载具", "附近没有找到载具", "warn")
        return false
    end
    local target = targetRoot.Position + targetRoot.CFrame.LookVector * 3 + Vector3.new(0, 4, 0)
    if TYHubMoveVehicle(model, target) then
        Notify("带来载具", "已把 " .. model.Name .. " 带到 " .. player.Name .. " 附近", "success")
        return true
    end
    Notify("带来载具", "载具移动失败", "error")
    return false
end

function TYHubBringVehicleToNearestPlayer(forceNearest)
    local _, _, myRoot = getChar(LocalPlayer)
    if not myRoot then
        return
    end
    local bestPlayer = nil
    local bestDistance = math.huge
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and isAlive(player) then
            local root = getRoot(player)
            if root then
                local distance = (root.Position - myRoot.Position).Magnitude
                if distance < bestDistance then
                    bestDistance = distance
                    bestPlayer = player
                end
            end
        end
    end
    if not bestPlayer then
        Notify("带来载具", "附近没有其他玩家", "warn")
        return
    end
    TYHubBringVehicleToPlayer(bestPlayer, myRoot.Position, forceNearest)
end

function TYHubBringVehicleToName(name, forceNearest)
    name = tostring(name or ""):lower()
    if name == "" then
        Notify("带来载具", "请输入玩家名字", "warn")
        return
    end
    local _, _, myRoot = getChar(LocalPlayer)
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and string.lower(player.Name):find(name, 1, true) then
            TYHubBringVehicleToPlayer(player, myRoot and myRoot.Position, forceNearest)
            return
        end
    end
    Notify("带来载具", "未找到该玩家", "error")
end

--============================  COMBAT  ============================--

local function sendDamage(player, partName, factor)
    if not PlayerEvent then
        return false
    end
    local _, _, myRoot = getChar(LocalPlayer)
    local char = player.Character
    local part = char and char:FindFirstChild(partName or "Head")
    if not part then
        part = char and char:FindFirstChild("HumanoidRootPart")
    end
    if not myRoot or not part then
        return false
    end
    pcall(function()
        PlayerEvent:FireServer("damage", {
            bodyParts = { { partName or "Head", 1 } },
            shotCode = { myRoot.Position, (part.Position - myRoot.Position).Unit },
            pos = part.Position,
            target = player,
            damageFactor = factor or 1,
            bulletProofTool = false,
        })
    end)
    return true
end

local function drawBeam(from, to)
    pcall(function()
        local a = Instance.new("Part")
        local b = Instance.new("Part")
        for _, part in ipairs({ a, b }) do
            part.Anchored = true
            part.CanCollide = false
            part.CanQuery = false
            part.Transparency = 1
            part.Size = Vector3.new(0.1, 0.1, 0.1)
            part.Parent = Workspace
        end
        a.Position = from
        b.Position = to
        local att1 = Instance.new("Attachment", a)
        local att2 = Instance.new("Attachment", b)
        local beam = Instance.new("Beam", a)
        beam.Attachment0 = att1
        beam.Attachment1 = att2
        beam.Width0 = 0.14
        beam.Width1 = 0.14
        beam.Color = ColorSequence.new(Theme.accent3, Theme.accent)
        task.delay(0.7, function()
            pcall(function()
                a:Destroy()
                b:Destroy()
            end)
        end)
    end)
end

local lastAura = 0
local function runAura()
    if not Settings.aura or not PlayerEvent then
        return
    end
    local now = tick()
    if now - lastAura < Settings.auraInterval then
        return
    end
    local _, _, myRoot = getChar(LocalPlayer)
    if not myRoot then
        return
    end
    local best, bestDist = nil, math.huge
    for _, player in ipairs(Players:GetPlayers()) do
        if passesFilter(player, Settings.auraPolice, Settings.auraCivilian) and isAlive(player) then
            local skip = false
            if Settings.auraCombat and not inCombat(player) then
                skip = true
            end
            if not skip then
                local root = getRoot(player)
                if root then
                    local dist = (root.Position - myRoot.Position).Magnitude
                    if dist <= Settings.auraRange and dist < bestDist then
                        best = player
                        bestDist = dist
                    end
                end
            end
        end
    end
    if best then
        local char = best.Character
        local part = getRagePart(char, "Head")
        if part then
            sendDamage(best, "Head", Settings.auraDamage)
        end
        lastAura = now
    end
end

local lastRage = 0
local function runRagebot()
    if not Settings.ragebot or not PlayerEvent then
        return
    end
    local now = tick()
    if now - lastRage < Settings.rageInterval then
        return
    end
    local _, _, myRoot = getChar(LocalPlayer)
    if not myRoot then
        return
    end

    local best, bestDist = nil, math.huge
    for _, player in ipairs(Players:GetPlayers()) do
        if passesFilter(player, Settings.ragePolice, Settings.rageCivilian) and isAlive(player) then
            local skip = false
            if Settings.rageCombat and not inCombat(player) then
                skip = true
            end
            if not skip and Settings.rageJob then
                local myTeam = LocalPlayer.Team and LocalPlayer.Team.Name
                if teamOf(player) == myTeam then
                    skip = true
                end
            end
            if not skip then
                local char = player.Character
                local part = char and char:FindFirstChild(Settings.ragePart)
                if part then
                    if Settings.rageWall and not visibleFromCamera(part) then
                        skip = true
                    end
                    if not skip then
                        local dist = (part.Position - myRoot.Position).Magnitude
                        if dist <= Settings.rageRange and dist < bestDist then
                            best = player
                            bestDist = dist
                        end
                    end
                end
            end
        end
    end

    if best then
        local partName = Settings.ragePart
        local char = best.Character
        local part = char and char:FindFirstChild(partName)
        if part then
            sendDamage(best, partName, 1.5)
            if Settings.rageBeam then
                drawBeam(myRoot.Position, part.Position)
            end
            lastRage = now
        end
    end
end

--============================  POLICE  ============================--

task.spawn(function()
    while true do
        if Settings.policeCuff or Settings.policeTp then
            local _, humanoid, myRoot = getChar(LocalPlayer)
            if myRoot and humanoid and humanoid.Health > 0 then
                if Settings.policeCuff and PlayerFunc then
                    for _, player in ipairs(Players:GetPlayers()) do
                        if player ~= LocalPlayer and isAlive(player) then
                            local skip = false
                            if Settings.policeCombat and not inCombat(player) then
                                skip = true
                            end
                            if not skip then
                                local root = getRoot(player)
                                if root and (root.Position - myRoot.Position).Magnitude <= Settings.policeRange then
                                    pcall(function()
                                        PlayerFunc:InvokeServer("handcuff", player, false)
                                    end)
                                end
                            end
                        end
                    end
                end

                if Settings.policeTp then
                    local best, bestDist = nil, math.huge
                    for _, player in ipairs(Players:GetPlayers()) do
                        if player ~= LocalPlayer and isAlive(player) and teamOf(player) == "Civilian" and wantedOf(player) > 0 then
                            local root = getRoot(player)
                            if root then
                                local dist = (root.Position - myRoot.Position).Magnitude
                                if dist <= Settings.policeRange and dist < bestDist then
                                    best = player
                                    bestDist = dist
                                end
                            end
                        end
                    end
                    if best then
                        local root = getRoot(best)
                        if root then
                            teleportTo(root.Position - root.CFrame.LookVector * 3)
                        end
                    end
                end
            end
        end
        task.wait(Settings.policeInterval)
    end
end)

--============================  MONEY  ============================--

local function matchesMoneyPrompt(prompt)
    local name = string.lower(prompt.Name or "")
    local action = string.lower(prompt.ActionText or "")
    local object = string.lower(prompt.ObjectText or "")
    return name == "cashdrop"
        or name == "getitem"
        or name == "money"
        or action:find("pick", 1, true) ~= nil
        or action:find("cash", 1, true) ~= nil
        or action:find("collect", 1, true) ~= nil
        or action:find("grab", 1, true) ~= nil
        or object:find("cash", 1, true) ~= nil
        or object:find("money", 1, true) ~= nil
end

task.spawn(function()
    while true do
        if Settings.autoMoney then
            local _, _, myRoot = getChar(LocalPlayer)
            if myRoot and myRoot.Parent then
                local bestPrompt, bestDist = nil, nil
                for _, descendant in ipairs(Workspace:GetDescendants()) do
                    if descendant:IsA("ProximityPrompt") and matchesMoneyPrompt(descendant) then
                        local pos = objectPosition(descendant)
                        if pos then
                            local dist = (myRoot.Position - pos).Magnitude
                            if dist < 180 and (not bestDist or dist < bestDist) then
                                bestDist = dist
                                bestPrompt = descendant
                            end
                        end
                    end
                end
                if bestPrompt and bestDist then
                    if bestDist > 8 then
                        teleportTo(objectPosition(bestPrompt))
                        task.wait(0.25)
                    end
                    firePrompt(bestPrompt)
                end
            end
        end
        task.wait(0.35)
    end
end)

local function getTeamJobs()
    if not getgc then
        return nil
    end
    for _, value in pairs(getgc(true)) do
        if type(value) == "table" and rawget(value, "teamJobs") then
            return value.teamJobs
        end
    end
    return nil
end

local function hasMission()
    if LocalPlayer:GetAttribute("Mission") then
        return true
    end
    local jobs = getTeamJobs()
    if jobs then
        for _, job in pairs(jobs) do
            if job.joined then
                return true
            end
        end
    end
    return false
end

local function pickMission()
    local jobs = getTeamJobs()
    if not jobs then
        return nil
    end
    local bestKey, bestValue = nil, -math.huge
    for key, job in pairs(jobs) do
        if not job.joined then
            if not Settings.missionPriority then
                return key
            end
            local score = (job.profitability or 1) * 1000000 + (job.reward or 0)
            if score > bestValue then
                bestValue = score
                bestKey = key
            end
        end
    end
    return bestKey
end

task.spawn(function()
    while true do
        if Settings.autoMission and PlayerFunc and not hasMission() then
            local key = pickMission()
            if key then
                pcall(function()
                    PlayerFunc:InvokeServer("talkToMission", tostring(key) .. "join")
                end)
            end
        end
        task.wait(math.max(Settings.missionInterval, 0.5))
    end
end)

task.spawn(function()
    while true do
        if Settings.farmer then
            local _, _, myRoot = getChar(LocalPlayer)
            if myRoot then
                local tool = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Tool")
                if tool then
                    task.wait(0.4)
                end
                local bestPrompt, bestDist = nil, nil
                for _, descendant in ipairs(Workspace:GetDescendants()) do
                    if descendant:IsA("ProximityPrompt") and descendant.ActionText == "Pick Up" then
                        local pos = objectPosition(descendant)
                        if pos then
                            local dist = (myRoot.Position - pos).Magnitude
                            if not bestDist or dist < bestDist then
                                bestDist = dist
                                bestPrompt = descendant
                            end
                        end
                    end
                end
                if bestPrompt and bestDist then
                    if bestDist > 8 then
                        teleportTo(objectPosition(bestPrompt))
                        task.wait(0.3)
                    else
                        firePrompt(bestPrompt)
                    end
                end
            end
        end
        task.wait(0.3)
    end
end)

local taxiOrigin = nil
local lastTaxiPos = nil
task.spawn(function()
    while true do
        if Settings.taxi then
            local gameplay = Workspace:FindFirstChild("Gameplay")
            local entities = gameplay and gameplay:FindFirstChild("Entities")
            local content = entities and entities:FindFirstChild("ClientContent")
            local _, _, myRoot = getChar(LocalPlayer)
            if content and content:IsA("Model") then
                local primary = content.PrimaryPart or content:FindFirstChildWhichIsA("BasePart")
                if primary and myRoot then
                    local position = primary.Position
                    if lastTaxiPos == nil or (position - lastTaxiPos).Magnitude > 5 then
                        if Settings.taxiSafe and taxiOrigin then
                            teleportTo(taxiOrigin)
                            local dist = (taxiOrigin - position).Magnitude
                            local waitTime
                            if Settings.taxiMode == "距离测算" then
                                waitTime = math.clamp(15 + (math.clamp(dist, 2000, 6000) - 2000) / 4000 * 30 + math.random() * 2 - 1, 15, 45)
                            else
                                waitTime = dist > 2000 and math.random(15, 45) or 15
                            end
                            task.wait(waitTime)
                        end
                        teleportTo(position)
                        lastTaxiPos = position
                    end
                end
            end
        else
            lastTaxiPos = nil
        end
        task.wait(0.5)
    end
end)

task.spawn(function()
    while true do
        if Settings.bus then
            local gameplay = Workspace:FindFirstChild("Gameplay")
            local entities = gameplay and gameplay:FindFirstChild("Entities")
            local content = entities and entities:FindFirstChild("ClientContent")
            local area = content and content:GetChildren()[1] and content:GetChildren()[1]:FindFirstChild("Area")
            local _, humanoid, myRoot = getChar(LocalPlayer)
            if area and humanoid and myRoot then
                local seatPart = humanoid.SeatPart
                if seatPart then
                    local relative = area.CFrame * CFrame.new(17.5, 3, 6.5) * CFrame.Angles(0, math.pi * 1.5, 0)
                    seatPart.CFrame = relative
                    seatPart.AssemblyLinearVelocity = Vector3.zero
                    seatPart.AssemblyAngularVelocity = Vector3.zero
                    task.wait(0.1)
                    humanoid.Sit = false
                else
                    myRoot.CFrame = area.CFrame * CFrame.new(17.5, 3, 6.5) * CFrame.Angles(0, math.pi * 1.5, 0)
                end
                task.wait(5)
            end
        end
        task.wait(1)
    end
end)

task.spawn(function()
    while true do
        if Settings.golf and PlayerFunc then
            pcall(function()
                PlayerFunc:InvokeServer("miniGolf", "createLobby")
                task.wait(0.1)
                PlayerFunc:InvokeServer("miniGolf", "setLobbyBid", { bid = 500 })
                task.wait(0.1)
                PlayerFunc:InvokeServer("miniGolf", "setLobbyReady")
                task.wait(4)
                PlayerFunc:InvokeServer("miniGolf", "shot")
                task.wait(0.5)
                local content = Workspace:FindFirstChild("Gameplay")
                content = content and content:FindFirstChild("Entities")
                content = content and content:FindFirstChild("Content")
                local ball = content and content:FindFirstChild(LocalPlayer.Name)
                local flag = content and content:FindFirstChild("_Flag")
                flag = flag and flag:FindFirstChild("FlagPole")
                local flagPart = flag and flag:FindFirstChild("Part")
                if ball and flagPart and ball:IsA("BasePart") then
                    ball.Position = flagPart.Position
                end
            end)
        end
        task.wait(Settings.golf and 5 or 1)
    end
end)

local autoHackCache = {}

--============================  AUTO ATM  ============================--

local AtmState = { signature = nil, busy = false, time = 0 }

function TYHubAutoAtmStep()
    if not Settings.autoAtm then
        AtmState.signature = nil
        return
    end

    local function findAtm()
        local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
        if not playerGui then
            return nil
        end
        for _, child in ipairs(playerGui:GetChildren()) do
            local ok, atm = pcall(function()
                return child.Center.Middle.HackingMinigames["ATM Hack"]
            end)
            if ok and atm then
                return atm
            end
        end
        return playerGui:FindFirstChild("ATM Hack", true)
    end

    local function guiVisible(gui)
        local node = gui
        while node do
            if node:IsA("LayerCollector") and not node.Enabled then
                return false
            end
            if node:IsA("GuiObject") and not node.Visible then
                return false
            end
            node = node.Parent
        end
        return true
    end

    local function clickButton(button)
        local position = button.AbsolutePosition
        local size = button.AbsoluteSize
        local x = position.X + size.X / 2
        local y = position.Y + size.Y / 2
        local virtualInput = game:GetService("VirtualInputManager")
        if UserInputService.TouchEnabled then
            pcall(function()
                virtualInput:SendTouchEvent(1, 0, x, y)
                virtualInput:SendTouchEvent(1, 2, x, y)
            end)
        end
        pcall(function()
            virtualInput:SendMouseButtonEvent(x, y, 0, true, game, 0)
            virtualInput:SendMouseButtonEvent(x, y, 0, false, game, 0)
        end)
    end

    local atm = findAtm()
    if not atm or not (atm:IsA("GuiObject") or atm:IsA("LayerCollector")) or not guiVisible(atm) then
        AtmState.signature = nil
        return
    end

    local sequence = atm:FindFirstChild("Sequence1", true)
    if not sequence or not sequence:IsA("TextLabel") then
        return
    end
    local text = sequence.Text or ""
    if text == "" then
        return
    end
    if AtmState.signature == text then
        if tick() - AtmState.time > 3 then
            AtmState.signature = nil
        else
            return
        end
    end
    if AtmState.busy then
        return
    end

    AtmState.signature = text
    AtmState.time = tick()
    AtmState.busy = true

    local tokens = {}
    for token in string.gmatch(text, "%S+") do
        table.insert(tokens, token)
    end

    task.spawn(function()
        pcall(function()
            for _, token in ipairs(tokens) do
                if not Settings.autoAtm then
                    break
                end
                local target = nil
                for _, descendant in ipairs(atm:GetDescendants()) do
                    if descendant:IsA("ImageButton") or descendant:IsA("TextButton") then
                        if descendant:IsA("TextButton") and descendant.Text == token then
                            target = descendant
                        end
                        for _, label in ipairs(descendant:GetDescendants()) do
                            if label:IsA("TextLabel") and label.Text == token then
                                target = descendant
                                break
                            end
                        end
                    end
                    if target then
                        break
                    end
                end
                if target then
                    clickButton(target)
                    task.wait(0.1)
                end
            end
        end)
        AtmState.busy = false
    end)
end

task.spawn(function()
    while true do
        if Settings.autoAtm then
            pcall(TYHubAutoAtmStep)
        else
            AtmState.signature = nil
        end
        task.wait(0.2)
    end
end)

local function setAutoHack(on)
    Settings.autoHack = on
    pcall(function()
        local framework = LocalPlayer.PlayerScripts:FindFirstChild("Framework")
        framework = framework and require(framework:FindFirstChild("Character"))
        local rulesModule = ReplicatedStorage:FindFirstChild("Modules")
        local rules = rulesModule and rulesModule:FindFirstChild("GameRules")
        if rules then
            rules = require(rules)
            rules.disableHacking = on
            rules.disableMinigames = on
        end
        if framework then
            if not autoHackCache.hacking then
                autoHackCache.hacking = framework.hackingMinigame
            end
            if not autoHackCache.start then
                autoHackCache.start = framework.startMinigame
            end
            if on then
                framework.hackingMinigame = function()
                    return true
                end
                framework.startMinigame = function()
                    return true
                end
            else
                if autoHackCache.hacking then
                    framework.hackingMinigame = autoHackCache.hacking
                end
                if autoHackCache.start then
                    framework.startMinigame = autoHackCache.start
                end
            end
        end
    end)
end

--============================  RUNTIME  ============================--

local fpsFrames = 0
local fpsClock = 0
local accNoclip = 0
local accHitbox = 0
local accAmmo = 0
local accRapid = 0
local accEsp = 0
local accGhost = 0

local function updateFps(dt)
    fpsFrames = fpsFrames + 1
    fpsClock = fpsClock + dt
    if fpsClock >= 0.5 then
        local fps = math.floor(fpsFrames / fpsClock + 0.5)
        TYHubFpsText.Text = fps .. " FPS"
        fpsFrames = 0
        fpsClock = 0
    end
end

local function tickAmmo()
    local chars = Workspace:FindFirstChild("Characters")
    local container = chars and chars:FindFirstChild(LocalPlayer.Name)
    if not container then
        TYHubAmmoCache = nil
        return
    end
    local now = tick()
    if not TYHubAmmoCache or TYHubAmmoCache.container ~= container or now - (TYHubAmmoCache.lastScan or 0) > 5 then
        local configs = {}
        for _, child in ipairs(container:GetChildren()) do
            local config = child:FindFirstChild("Config")
            if config then
                table.insert(configs, config)
            end
        end
        TYHubAmmoCache = {
            container = container,
            configs = configs,
            lastScan = now,
        }
    end
    for _, config in ipairs(TYHubAmmoCache.configs) do
        if config.Parent then
            local ammo = config:FindFirstChild("Ammo")
            if ammo and ammo.Value ~= 999999 then
                ammo.Value = 999999
            end
            local total = config:FindFirstChild("TotalAmmo")
            if total and total.Value ~= 999999 then
                total.Value = 999999
            end
        end
    end
end

local function tickRapidFire()
    if not getgc then
        return
    end
    local now = tick()
    if not TYHubRapidCache or now - (TYHubRapidCache.lastScan or 0) > 10 then
        local tables = {}
        for _, value in pairs(getgc(true)) do
            if type(value) == "table" and (rawget(value, "SHOOT_MODE") ~= nil or rawget(value, "RPM") ~= nil) then
                table.insert(tables, value)
            end
        end
        TYHubRapidCache = {
            tables = tables,
            lastScan = now,
        }
    end
    for _, value in pairs(TYHubRapidCache.tables) do
        if type(value) == "table" then
            if rawget(value, "SHOOT_MODE") ~= nil and rawget(value, "SHOOT_MODE") ~= 2 then
                rawset(value, "SHOOT_MODE", 2)
            end
            if rawget(value, "RPM") ~= nil and rawget(value, "RPM") ~= math.huge then
                rawset(value, "RPM", math.huge)
            end
        end
    end
end

local function updateFly(dt)
    local _, humanoid, root = getChar(LocalPlayer)

    if not Settings.fly or not root or not humanoid or humanoid.Health <= 0 then
        if FlyState.active then
            stopFly()
        end
        if flyWasOn and not Settings.noclip then
            local char = LocalPlayer.Character
            if char then
                for _, part in ipairs(char:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = true
                    end
                end
            end
        end
        flyWasOn = false
        return
    end

    flyWasOn = true
    local mode = Settings.flyMode == "物理" and "物理" or "传送"
    if not FlyState.active or FlyState.root ~= root or FlyState.mode ~= mode then
        if FlyState.active then
            stopFly()
        end
        startFly(root, humanoid, mode)
    end

    local direction = moveDirection()
    local speed = Settings.flySpeed or 35

    if mode == "物理" then
        if FlyState.bodyVelocity then
            FlyState.bodyVelocity.Velocity = direction * speed
        end
        if FlyState.bodyGyro then
            local cam = Workspace.CurrentCamera
            if cam then
                FlyState.bodyGyro.CFrame = cam.CFrame
            end
        end
        return
    end

    pcall(function()
        root.Anchored = false
    end)

    local cam = Workspace.CurrentCamera
    local position = root.Position + direction * speed * dt
    local look = cam and cam.CFrame.LookVector or root.CFrame.LookVector
    local flat = Vector3.new(look.X, 0, look.Z)
    local target
    if flat.Magnitude > 0.01 then
        target = CFrame.lookAt(position, position + flat.Unit)
    else
        target = CFrame.new(position) * root.CFrame.Rotation
    end
    root.CFrame = target
    pcall(function()
        root.AssemblyLinearVelocity = Vector3.zero
        root.AssemblyAngularVelocity = Vector3.zero
    end)
end

local function updateVehicle()
    local seat = getVehicleSeat()
    local chassis = TYHubSeatChassis(seat) or seat
    if Settings.vehicleFly then
        if seat then
            pcall(function()
                seat.Throttle = 0
                seat.Steer = 0
            end)
        end
        if VehicleState.velocity then
            clearVehicleForce()
        end
        return
    end
    if Settings.cruise and seat then
        pcall(function()
            seat.Throttle = 1
        end)
    end

    if Settings.vehicleBoost and seat then
        if VehicleState.part ~= chassis then
            clearVehicleForce()
            local attachment = make("Attachment", { Name = "TYHubVehicleAttachment" }, chassis)
            local velocity = make("LinearVelocity", {
                Name = "TYHubVehicleVelocity",
                Attachment0 = attachment,
                MaxForce = math.huge,
                VectorVelocity = Vector3.zero,
            }, chassis)
            VehicleState.attachment = attachment
            VehicleState.velocity = velocity
            VehicleState.part = chassis
        end
        if VehicleState.velocity then
            VehicleState.velocity.VectorVelocity = seat.CFrame.LookVector * Settings.vehicleSpeed
        end
    elseif not Settings.vehicleBoost and VehicleState.velocity then
        clearVehicleForce()
    end
end

local function updateNoclip()
    local char = LocalPlayer.Character
    if not char then
        return
    end
    for _, descendant in ipairs(char:GetDescendants()) do
        if descendant:IsA("BasePart") then
            if Settings.noclip then
                descendant.CanCollide = false
            end
        end
    end
end

local function updateHitboxes()
    if Settings.hitbox then
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
                if not (Settings.hitboxTeam and LocalPlayer.Team and player.Team and player.Team == LocalPlayer.Team) then
                    local char = player.Character
                    if char then
                        applyHitbox(char)
                    end
                end
            end
        end
    else
        for root in pairs(hitboxCache) do
            if root and root.Parent then
                clearHitbox(root)
            else
                hitboxCache[root] = nil
            end
        end
    end
end

connect(RunService.Heartbeat, function(dt)
    updateFps(dt)

    local _, humanoid, myRoot = getChar(LocalPlayer)

    if humanoid then
        if Settings.walkEnabled then
            humanoid.WalkSpeed = Settings.walkSpeed
        end
        if Settings.jumpEnabled then
            humanoid.UseJumpPower = true
            humanoid.JumpPower = Settings.jumpPower * Settings.jumpMultiplier
        end
    end

    if Settings.stamina and Core then
        pcall(function()
            Core.stamina = 100
        end)
    end
    if Settings.hunger and Core then
        pcall(function()
            Core.food = 100
        end)
    end
    accAmmo = accAmmo + dt
    if Settings.infiniteAmmo and accAmmo >= 0.75 then
        accAmmo = 0
        pcall(tickAmmo)
    end

    accRapid = accRapid + dt
    if Settings.rapidFire and accRapid >= 1 then
        accRapid = 0
        pcall(tickRapidFire)
    elseif not Settings.rapidFire then
        TYHubRapidCache = nil
    end

    accNoclip = accNoclip + dt
    if (Settings.noclip or Settings.fly) and accNoclip >= 0.1 then
        accNoclip = 0
        updateNoclip()
    end

    updateVehicle()
    TYHubUpdateVehicleFly(dt)

    accHitbox = accHitbox + dt
    if accHitbox >= 0.2 then
        accHitbox = 0
        updateHitboxes()
        updateRangeSphere()
    end

    runAura()
    runRagebot()

    accEsp = accEsp + dt
    if accEsp >= 0.12 then
        accEsp = 0
        refreshEsp()
        for player in pairs(EspTrackers) do
            updateTracker(player)
        end
        if TYHubQuick and TYHubQuick.Refresh then
            TYHubQuick.Refresh()
        end
        if TYHubRefreshVehicleEsp then
            TYHubRefreshVehicleEsp()
        end
    end

    accGhost = accGhost + dt
    if Settings.ghost and accGhost >= 0.5 then
        accGhost = 0
        local char = LocalPlayer.Character
        if GhostState.exposedUntil > 0 then
            if tick() >= GhostState.exposedUntil then
                GhostState.exposedUntil = 0
                TYHubGhostHide()
            end
        elseif char and not char:GetAttribute("TYHubGhostApplied") then
            applyGhostBody(char, true)
            char:SetAttribute("TYHubGhostApplied", true)
        end
    elseif not Settings.ghost then
        GhostState.exposedUntil = 0
        local char = LocalPlayer.Character
        if char and char:GetAttribute("TYHubGhostApplied") then
            applyGhostBody(char, false)
            char:SetAttribute("TYHubGhostApplied", nil)
        end
    end
end)

connect(RunService.RenderStepped, function(dt)
    updateFly(dt)
    updateAimDrawings(dt)
    updateSilent(dt)
end)

connect(UserInputService.JumpRequest, function()
    if Settings.infJump then
        local _, humanoid, root = getChar(LocalPlayer)
        if humanoid and root and humanoid.Health > 0 then
            local state = humanoid:GetState()
            local grounded = state == Enum.HumanoidStateType.Landed
                or state == Enum.HumanoidStateType.Running
                or state == Enum.HumanoidStateType.RunningNoPhysics
                or state == Enum.HumanoidStateType.Seated
            if not grounded or Settings.infJump then
                root.AssemblyLinearVelocity = Vector3.new(
                    root.AssemblyLinearVelocity.X,
                    Settings.jumpPower * Settings.jumpMultiplier * 0.9,
                    root.AssemblyLinearVelocity.Z
                )
            end
        end
    end
end)

connect(LocalPlayer.CharacterAdded, function(char)
    task.wait(0.6)
    if Settings.ghost then
        setGhost(true)
    end
    if Settings.hitbox then
        task.defer(function()
            applyHitbox(char)
        end)
    end
end)

--============================  PAGES  ============================--

local function flagSetter(key)
    return function(value)
        Settings[key] = value
    end
end

local MainPage = newTab("常用", "✦", "main")
MainPage:Section("生存", "ER:LC 基础状态")
MainPage:Toggle({
    title = "无限体力",
    desc = "锁定体力为 100",
    flag = "stamina",
    callback = flagSetter("stamina"),
})
MainPage:Toggle({
    title = "无限饥饿",
    desc = "锁定饱食度为 100",
    flag = "hunger",
    callback = flagSetter("hunger"),
})
MainPage:Toggle({
    title = "防布娃娃",
    desc = "阻止角色被击倒进入布娃娃",
    flag = "noRagdoll",
    callback = function(value)
        Settings.noRagdoll = value
        if value then
            installRagdollHook()
        end
    end,
})
MainPage:Toggle({
    title = "防摔伤",
    desc = "拦截 takeDamage 事件",
    flag = "noFallDamage",
    callback = flagSetter("noFallDamage"),
})
MainPage:Toggle({
    title = "防越狱拉回",
    desc = "拦截监狱拉回与提示",
    flag = "antiPull",
    callback = function(value)
        Settings.antiPull = value
        setAntiPull(value)
    end,
})
MainPage:Toggle({
    title = "战斗拦截",
    desc = "阻止客户端发送 combatMode",
    flag = "combatBlock",
    callback = flagSetter("combatBlock"),
})

MainPage:Section("隐身", "Ghost 模式")
MainPage:Toggle({
    title = "隐身",
    desc = "隐藏位置与角色模型",
    flag = "ghost",
    callback = setGhost,
})
MainPage:Toggle({
    title = "隐身悬浮窗",
    desc = "屏幕上的快捷开关",
    flag = "ghostHud",
    callback = setGhostHud,
})
MainPage:Toggle({
    title = "锁定悬浮窗位置",
    desc = "禁止拖动悬浮窗",
    flag = "ghostLock",
    callback = setGhostLock,
})
MainPage:Button({
    title = "短暂现身",
    callback = function()
        TYHubGhostExpose(Settings.ghostExposeTime)
    end,
})
MainPage:Slider({
    title = "现身时长",
    min = 1,
    max = 10,
    step = 0.5,
    default = 4,
    flag = "ghostExposeTime",
    format = function(v)
        return string.format("%.1fs", v)
    end,
    callback = flagSetter("ghostExposeTime"),
})
MainPage:Keybind({
    title = "短暂现身按键",
    default = Enum.KeyCode.G,
    flag = "ghostExposeKey",
    callback = function(key)
        Settings.ghostExposeKey = key or Enum.KeyCode.G
    end,
})
MainPage:Button({
    title = "重新隐藏",
    callback = function()
        TYHubGhostResume()
    end,
})

-- Money
local MoneyPage = newTab("自动化", "◈", "money")
MoneyPage:Section("拾取与交互", "自动化")
MoneyPage:Toggle({
    title = "自动捡钱",
    desc = "自动寻找并拾取现金掉落",
    flag = "autoMoney",
    callback = flagSetter("autoMoney"),
})
MoneyPage:Toggle({
    title = "自动黑客",
    desc = "跳过黑客与迷你游戏",
    flag = "autoHack",
    callback = setAutoHack,
})
MoneyPage:Toggle({
    title = "ATM 自动解谜",
    desc = "读取 Sequence1 并自动点击 ATM Hack",
    flag = "autoAtm",
    callback = flagSetter("autoAtm"),
})


MoneyPage:Toggle({
    title = "秒互动",
    desc = "ProximityPrompt 按住立即完成",
    flag = "instantPrompt",
    callback = flagSetter("instantPrompt"),
})

MoneyPage:Section("任务", "Mission")
MoneyPage:Toggle({
    title = "自动接取任务",
    desc = "自动加入当前可接任务",
    flag = "autoMission",
    callback = flagSetter("autoMission"),
})
MoneyPage:Toggle({
    title = "优先高收益任务",
    desc = "按 profitability / reward 排序",
    flag = "missionPriority",
    callback = flagSetter("missionPriority"),
})
MoneyPage:Slider({
    title = "接取间隔",
    min = 0.5,
    max = 10,
    step = 0.5,
    default = 2,
    flag = "missionInterval",
    format = function(v)
        return string.format("%.1fs", v)
    end,
    callback = flagSetter("missionInterval"),
})

MoneyPage:Section("车辆任务", "出租车 / 公交")
MoneyPage:Toggle({
    title = "出租车刷钱",
    desc = "跟随 ClientContent 路线",
    flag = "taxi",
    callback = function(value)
        Settings.taxi = value
        if value then
            local _, _, root = getChar(LocalPlayer)
            taxiOrigin = root and root.Position or nil
            Notify("出租车刷钱", value and "已开启，正在跟随路线" or "已关闭", "success")
        end
    end,
})
MoneyPage:Toggle({
    title = "安全模式",
    desc = "先回到记录点再传送，降低风险",
    flag = "taxiSafe",
    callback = flagSetter("taxiSafe"),
})
MoneyPage:Dropdown({
    title = "延迟模式",
    desc = "出租车传送间隔",
    options = { "随机时间", "距离测算" },
    default = "随机时间",
    flag = "taxiMode",
    callback = flagSetter("taxiMode"),
})
MoneyPage:Toggle({
    title = "公交车刷钱",
    desc = "传送到公交区域并上下车",
    flag = "bus",
    callback = flagSetter("bus"),
})
MoneyPage:Toggle({
    title = "农民刷钱",
    desc = "自动寻找 Pick Up 提示",
    flag = "farmer",
    callback = flagSetter("farmer"),
})
MoneyPage:Toggle({
    title = "高尔夫刷钱",
    desc = "自动创建房间并击球进洞",
    flag = "golf",
    callback = flagSetter("golf"),
})

-- Combat
local CombatPage = newTab("战斗", "✧", "combat")
CombatPage:Section("武器", "弹药与射速")
CombatPage:Toggle({
    title = "无限子弹",
    desc = "弹药与备弹设为最大值",
    flag = "infiniteAmmo",
    callback = flagSetter("infiniteAmmo"),
})
CombatPage:Toggle({
    title = "快速射击",
    desc = "改写武器 SHOOT_MODE / RPM",
    flag = "rapidFire",
    callback = function(value)
        Settings.rapidFire = value
        if not value then
            TYHubRapidCache = nil
        end
    end,
})


CombatPage:Section("杀戮光环", "范围伤害")
CombatPage:Toggle({
    title = "杀戮光环",
    desc = "对范围内目标发送 damage",
    flag = "aura",
    callback = flagSetter("aura"),
})
CombatPage:Slider({
    title = "攻击范围",
    min = 5,
    max = 300,
    step = 1,
    default = 50,
    flag = "auraRange",
    format = function(v)
        return string.format("%.0f m", v)
    end,
    callback = flagSetter("auraRange"),
})
CombatPage:Slider({
    title = "伤害倍率",
    min = 1,
    max = 50,
    step = 0.5,
    default = 5,
    flag = "auraDamage",
    format = function(v)
        return "x" .. string.format("%.1f", v)
    end,
    callback = flagSetter("auraDamage"),
})
CombatPage:Slider({
    title = "攻击间隔",
    min = 0.01,
    max = 0.5,
    step = 0.01,
    default = 0.05,
    flag = "auraInterval",
    format = function(v)
        return string.format("%.2fs", v)
    end,
    callback = flagSetter("auraInterval"),
})
CombatPage:Toggle({
    title = "只攻击警察",
    flag = "auraPolice",
    callback = flagSetter("auraPolice"),
})
CombatPage:Toggle({
    title = "只攻击平民",
    flag = "auraCivilian",
    callback = flagSetter("auraCivilian"),
})
CombatPage:Toggle({
    title = "战斗检测",
    desc = "仅攻击处于战斗 / 追捕状态的目标",
    flag = "auraCombat",
    callback = flagSetter("auraCombat"),
})

CombatPage:Section("Ragebot", "远程点击")
CombatPage:Toggle({
    title = "Ragebot",
    desc = "按间隔持续造成伤害",
    flag = "ragebot",
    callback = flagSetter("ragebot"),
})
CombatPage:Slider({
    title = "攻击距离",
    min = 10,
    max = 500,
    step = 5,
    default = 150,
    flag = "rageRange",
    format = function(v)
        return string.format("%.0f m", v)
    end,
    callback = flagSetter("rageRange"),
})
CombatPage:Slider({
    title = "攻击间隔",
    min = 0.01,
    max = 0.5,
    step = 0.01,
    default = 0.05,
    flag = "rageInterval",
    format = function(v)
        return string.format("%.2fs", v)
    end,
    callback = flagSetter("rageInterval"),
})
CombatPage:Dropdown({
    title = "攻击部位",
    options = { "Head", "Torso", "LeftArm", "RightArm", "LeftLeg", "RightLeg" },
    default = "Head",
    flag = "ragePart",
    callback = flagSetter("ragePart"),
})
CombatPage:Toggle({
    title = "职业检测",
    desc = "跳过与自己同职业的目标",
    flag = "rageJob",
    callback = flagSetter("rageJob"),
})
CombatPage:Toggle({
    title = "墙壁检测",
    flag = "rageWall",
    callback = flagSetter("rageWall"),
})
CombatPage:Toggle({
    title = "战斗检测",
    flag = "rageCombat",
    callback = flagSetter("rageCombat"),
})
CombatPage:Toggle({
    title = "锁定警察",
    flag = "ragePolice",
    callback = flagSetter("ragePolice"),
})
CombatPage:Toggle({
    title = "锁定平民",
    flag = "rageCivilian",
    callback = flagSetter("rageCivilian"),
})
CombatPage:Toggle({
    title = "弹道显示",
    desc = "显示命中光束",
    flag = "rageBeam",
    callback = flagSetter("rageBeam"),
})

CombatPage:Section("碰撞箱", "Hitbox Expander")
CombatPage:Toggle({
    title = "碰撞箱扩展",
    flag = "hitbox",
    callback = function(value)
        Settings.hitbox = value
        if not value then
            clearAllHitboxes()
        end
    end,
})
CombatPage:Slider({
    title = "碰撞箱大小",
    min = 2,
    max = 30,
    step = 0.5,
    default = 10,
    flag = "hitboxSize",
    callback = flagSetter("hitboxSize"),
})
CombatPage:Slider({
    title = "透明度",
    min = 0,
    max = 1,
    step = 0.05,
    default = 0.65,
    flag = "hitboxTransparency",
    callback = flagSetter("hitboxTransparency"),
})
CombatPage:Toggle({ title = "队伍检测", flag = "hitboxTeam", callback = flagSetter("hitboxTeam") })
CombatPage:Toggle({ title = "显示轮廓", flag = "hitboxOutline", callback = flagSetter("hitboxOutline") })
CombatPage:Toggle({ title = "发光效果", flag = "hitboxGlow", callback = flagSetter("hitboxGlow") })
CombatPage:Toggle({ title = "脉动效果", flag = "hitboxPulse", callback = flagSetter("hitboxPulse") })
CombatPage:Dropdown({
    title = "碰撞箱颜色",
    options = { "紫色", "红色", "粉色", "蓝色", "青色", "绿色", "黄色", "白色" },
    default = "紫色",
    flag = "hitboxColor",
    callback = flagSetter("hitboxColor"),
})


-- Aim
local AimPage = newTab("自瞄", "◎", "aim")
AimPage:Section("自瞄", "Camera Aimbot")
AimPage:Toggle({
    title = "开启自瞄",
    desc = "按 FOV 锁定目标",
    flag = "aim",
    callback = flagSetter("aim"),
})
AimPage:Toggle({
    title = "按住右键",
    desc = "仅在按住鼠标右键时自瞄",
    flag = "aimHold",
    callback = flagSetter("aimHold"),
})
AimPage:Slider({
    title = "FOV 范围",
    min = 20,
    max = 600,
    step = 5,
    default = 140,
    flag = "aimFov",
    format = function(v)
        return string.format("%.0f px", v)
    end,
    callback = flagSetter("aimFov"),
})
AimPage:Slider({
    title = "平滑度",
    min = 0,
    max = 100,
    step = 1,
    default = 25,
    flag = "aimSmooth",
    format = function(v)
        return string.format("%.0f%%", v)
    end,
    callback = flagSetter("aimSmooth"),
})
AimPage:Dropdown({
    title = "瞄准部位",
    options = { "头部", "胸部", "躯干", "左臂", "右臂", "左腿", "右腿" },
    default = "头部",
    flag = "aimPart",
    callback = flagSetter("aimPart"),
})
AimPage:Dropdown({
    title = "优先模式",
    options = { "准心最近", "距离最近", "血量最低" },
    default = "准心最近",
    flag = "aimMode",
    callback = flagSetter("aimMode"),
})
AimPage:Toggle({ title = "队伍检测", desc = "跳过同队玩家", flag = "aimTeam", callback = flagSetter("aimTeam") })
AimPage:Toggle({ title = "好友检测", desc = "跳过好友", flag = "aimFriend", callback = flagSetter("aimFriend") })
AimPage:Toggle({ title = "墙壁检测", desc = "仅锁定可见目标", flag = "aimWall", callback = flagSetter("aimWall") })
AimPage:Toggle({ title = "预判自瞄", desc = "根据目标速度提前量", flag = "aimPredict", callback = flagSetter("aimPredict") })
AimPage:Toggle({ title = "只自瞄警察", flag = "aimPolice", callback = flagSetter("aimPolice") })
AimPage:Toggle({ title = "只自瞄平民", flag = "aimCivilian", callback = flagSetter("aimCivilian") })
AimPage:Toggle({ title = "战斗检测", flag = "aimCombat", callback = flagSetter("aimCombat") })
AimPage:Toggle({ title = "载具自瞄", desc = "没有玩家目标时锁定最近载具", flag = "aimVehicles", callback = flagSetter("aimVehicles") })
AimPage:Keybind({
    title = "载具自瞄按键",
    default = Enum.KeyCode.T,
    flag = "aimVehiclesKey",
    callback = function(key)
        Settings.aimVehiclesKey = key or Enum.KeyCode.T
    end,
})

AimPage:Section("显示", "准心与颜色")
AimPage:Toggle({ title = "显示 FOV 圈", flag = "aimShowFov", callback = flagSetter("aimShowFov") })
AimPage:Toggle({ title = "显示准心", flag = "aimCrosshair", callback = flagSetter("aimCrosshair") })
AimPage:Toggle({ title = "显示追踪线", flag = "aimTracer", callback = flagSetter("aimTracer") })
AimPage:Slider({
    title = "FOV 圈厚度",
    min = 1,
    max = 5,
    step = 0.5,
    default = 1.5,
    flag = "aimFovThickness",
    callback = flagSetter("aimFovThickness"),
})
AimPage:Dropdown({
    title = "颜色",
    options = { "紫色", "红色", "粉色", "蓝色", "青色", "绿色", "黄色", "白色" },
    default = "紫色",
    flag = "aimColor",
    callback = flagSetter("aimColor"),
})

AimPage:Section("Silent Aim", "射线重定向")
AimPage:Toggle({
    title = "静默瞄准",
    desc = "钩住 Workspace.Raycast，不移动视角",
    flag = "silent",
    callback = function(value)
        Settings.silent = value
        if value and not raycastHooked then
            Notify("静默瞄准", "当前执行器不支持 hookfunction，功能不可用", "error")
        end
    end,
})
AimPage:Slider({
    title = "静默 FOV",
    min = 20,
    max = 600,
    step = 5,
    default = 140,
    flag = "silentFov",
    callback = flagSetter("silentFov"),
})
AimPage:Slider({
    title = "最大距离",
    min = 50,
    max = 800,
    step = 10,
    default = 300,
    flag = "silentDistance",
    callback = flagSetter("silentDistance"),
})
AimPage:Dropdown({
    title = "瞄准部位",
    options = { "头部", "胸部", "躯干", "左臂", "右臂", "左腿", "右腿" },
    default = "头部",
    flag = "silentPart",
    callback = flagSetter("silentPart"),
})
AimPage:Toggle({ title = "队伍检测", flag = "silentTeam", callback = flagSetter("silentTeam") })
AimPage:Toggle({ title = "好友检测", flag = "silentFriend", callback = flagSetter("silentFriend") })
AimPage:Toggle({ title = "只瞄准警察", flag = "silentPolice", callback = flagSetter("silentPolice") })
AimPage:Toggle({ title = "只瞄准平民", flag = "silentCivilian", callback = flagSetter("silentCivilian") })
AimPage:Toggle({ title = "战斗检测", flag = "silentCombat", callback = flagSetter("silentCombat") })
AimPage:Toggle({ title = "显示静默圈", flag = "silentShowFov", callback = flagSetter("silentShowFov") })

-- ESP
local EspPage = newTab("视觉", "▣", "esp")
EspPage:Section("范围", "球形可视化")
EspPage:Toggle({
    title = "显示范围球",
    desc = "以角色为中心的球形指示器",
    flag = "rangeEnabled",
    callback = flagSetter("rangeEnabled"),
})
EspPage:Slider({
    title = "范围大小",
    min = 5,
    max = 200,
    step = 5,
    default = 50,
    flag = "rangeSize",
    format = function(v)
        return string.format("%.0f m", v)
    end,
    callback = flagSetter("rangeSize"),
})
EspPage:Slider({
    title = "透明度",
    min = 0,
    max = 1,
    step = 0.05,
    default = 0.75,
    flag = "rangeTransparency",
    callback = flagSetter("rangeTransparency"),
})
EspPage:Dropdown({
    title = "颜色",
    options = { "紫色", "红色", "粉色", "蓝色", "青色", "绿色", "黄色", "白色" },
    default = "紫色",
    flag = "rangeColor",
    callback = flagSetter("rangeColor"),
})
EspPage:Dropdown({
    title = "材质",
    options = { "Neon", "ForceField", "Glass", "SmoothPlastic", "Plastic" },
    default = "Neon",
    flag = "rangeMaterial",
    callback = flagSetter("rangeMaterial"),
})
EspPage:Toggle({ title = "显示轮廓", flag = "rangeOutline", callback = flagSetter("rangeOutline") })
EspPage:Toggle({ title = "启用碰撞", flag = "rangeCollision", callback = flagSetter("rangeCollision") })
EspPage:Toggle({ title = "发光效果", flag = "rangeGlow", callback = flagSetter("rangeGlow") })
EspPage:Toggle({ title = "脉动效果", flag = "rangePulse", callback = flagSetter("rangePulse") })


EspPage:Section("玩家透视", "2D 方框 + 高亮")
EspPage:Toggle({
    title = "玩家透视",
    desc = "总开关",
    flag = "esp",
    callback = function(value)
        Settings.esp = value
        if not value then
            for player in pairs(EspTrackers) do
                destroyTracker(player)
            end
        end
    end,
})
EspPage:Toggle({ title = "显示名字", flag = "espName", callback = flagSetter("espName") })
EspPage:Toggle({ title = "显示距离", flag = "espDistance", callback = flagSetter("espDistance") })
EspPage:Toggle({ title = "显示血量", flag = "espHealth", callback = flagSetter("espHealth") })
EspPage:Toggle({ title = "显示方框", flag = "espBox", callback = flagSetter("espBox") })
EspPage:Toggle({ title = "显示高亮", flag = "espHighlight", callback = flagSetter("espHighlight") })
EspPage:Toggle({ title = "显示追踪线", flag = "espTracer", callback = flagSetter("espTracer") })
EspPage:Dropdown({
    title = "追踪线起点",
    options = { "屏幕底部", "屏幕中心", "屏幕顶部" },
    default = "屏幕底部",
    flag = "espTracerOrigin",
    callback = flagSetter("espTracerOrigin"),
})
EspPage:Toggle({
    title = "显示逃犯",
    desc = "平民且通缉等级 > 0",
    flag = "espFugitive",
    callback = flagSetter("espFugitive"),
})
EspPage:Dropdown({
    title = "选择透视队伍",
    desc = "多选，全部取消则显示全部",
    multi = true,
    options = { "Chef", "Civilian", "Delivery", "Farmer", "Fire", "Police", "Medical", "Prisoner", "Road Service", "Transit" },
    default = { "Chef", "Civilian", "Delivery", "Farmer", "Fire", "Police", "Medical", "Prisoner", "Road Service", "Transit" },
    flag = "espTeams",
    callback = function(values)
        for key in pairs(Settings.espTeams) do
            Settings.espTeams[key] = false
        end
        for _, name in ipairs(values) do
            Settings.espTeams[name] = true
        end
    end,
})

-- Player
local PlayerPage = newTab("移动", "●", "player")
PlayerPage:Section("位移", "Blink")
PlayerPage:Toggle({
    title = "Blink",
    desc = "传送到准星所指位置",
    flag = "blink",
    callback = flagSetter("blink"),
})
PlayerPage:Slider({
    title = "Blink 距离",
    min = 20,
    max = 500,
    step = 10,
    default = 120,
    flag = "blinkDistance",
    format = function(v)
        return string.format("%.0f m", v)
    end,
    callback = flagSetter("blinkDistance"),
})
PlayerPage:Keybind({
    title = "Blink 按键",
    default = Enum.KeyCode.Eight,
    flag = "blinkKey",
    callback = function(key)
        Settings.blinkKey = key or Enum.KeyCode.Eight
    end,
})
PlayerPage:Button({
    title = "立即 Blink",
    callback = function()
        TYHubBlink()
    end,
})


PlayerPage:Section("移动", "速度 / 跳跃 / 飞行")
PlayerPage:Toggle({
    title = "自定义速度",
    desc = "修改 WalkSpeed",
    flag = "walkEnabled",
    callback = function(value)
        Settings.walkEnabled = value
        if not value then
            local _, humanoid = getChar(LocalPlayer)
            if humanoid then
                humanoid.WalkSpeed = 16
            end
        end
    end,
})
PlayerPage:Slider({
    title = "移动速度",
    min = 16,
    max = 400,
    step = 1,
    default = 200,
    flag = "walkSpeed",
    callback = flagSetter("walkSpeed"),
})
PlayerPage:Toggle({
    title = "自定义跳跃",
    flag = "jumpEnabled",
    callback = function(value)
        Settings.jumpEnabled = value
        if not value then
            local _, humanoid = getChar(LocalPlayer)
            if humanoid then
                humanoid.JumpPower = 50
            end
        end
    end,
})
PlayerPage:Slider({
    title = "跳跃高度",
    min = 50,
    max = 300,
    step = 5,
    default = 50,
    flag = "jumpPower",
    callback = flagSetter("jumpPower"),
})
PlayerPage:Slider({
    title = "跳跃倍数",
    min = 1,
    max = 5,
    step = 0.1,
    default = 1,
    flag = "jumpMultiplier",
    callback = flagSetter("jumpMultiplier"),
})
PlayerPage:Toggle({ title = "无限跳跃", flag = "infJump", callback = flagSetter("infJump") })
PlayerPage:Toggle({ title = "飞行", flag = "fly", callback = flagSetter("fly") })
PlayerPage:Slider({
    title = "飞行速度",
    min = 10,
    max = 200,
    step = 5,
    default = 35,
    flag = "flySpeed",
    callback = flagSetter("flySpeed"),
})
PlayerPage:Dropdown({
    title = "飞行模式",
    options = { "传送", "物理" },
    default = "传送",
    flag = "flyMode",
    callback = function(value)
        Settings.flyMode = value
        Notify("飞行模式", "已切换为「" .. tostring(value) .. "」", "info")
    end,
})
PlayerPage:Toggle({ title = "穿墙", flag = "noclip", callback = setNoclip })

-- Vehicle
local VehiclePage = newTab("载具", "▸", "vehicle")
VehiclePage:Section("飞行", "驾驶座内生效")
VehiclePage:Toggle({
    title = "载具飞行",
    desc = "WASD + Space / Ctrl 控制载具",
    flag = "vehicleFly",
    callback = flagSetter("vehicleFly"),
})
VehiclePage:Slider({
    title = "飞行速度",
    min = 20,
    max = 400,
    step = 5,
    default = 80,
    flag = "vehicleFlySpeed",
    format = function(v)
        return string.format("%.0f", v)
    end,
    callback = flagSetter("vehicleFlySpeed"),
})
VehiclePage:Keybind({
    title = "飞行开关键",
    default = Enum.KeyCode.F,
    flag = "vehicleFlyKey",
    callback = function(key)
        Settings.vehicleFlyKey = key or Enum.KeyCode.F
    end,
})
VehiclePage:Section("载具 ESP")
VehiclePage:Toggle({
    title = "载具透视",
    desc = "高亮附近载具并显示信息",
    flag = "vehicleEsp",
    callback = function(value)
        Settings.vehicleEsp = value
        if not value then
            for model in pairs(TYHubVehicle.trackers) do
                TYHubDestroyVehicleTracker(model)
            end
        end
    end,
})
VehiclePage:Toggle({ title = "显示名字", flag = "vehicleEspName", callback = flagSetter("vehicleEspName") })
VehiclePage:Toggle({ title = "显示距离", flag = "vehicleEspDistance", callback = flagSetter("vehicleEspDistance") })
VehiclePage:Toggle({ title = "显示高亮", flag = "vehicleEspHighlight", callback = flagSetter("vehicleEspHighlight") })
VehiclePage:Button({
    title = "传送到最近载具",
    callback = function()
        local _, _, root = getChar(LocalPlayer)
        if not root then
            return
        end
        local model, part, distance = TYHubNearestVehicle(root.Position)
        if part then
            teleportTo(part.Position + Vector3.new(0, 3, 0))
            Notify("载具", string.format("已传送到 %s（%.0f m）", model.Name, distance), "success")
        else
            Notify("载具", "附近没有找到载具", "warn")
        end
    end,
})

VehiclePage:Section("带来载具")
VehiclePage:Button({
    title = "把我的载具传到脸上（无视距离）",
    callback = function()
        TYHubBringVehicleToMe()
    end,
})
VehiclePage:Button({
    title = "把我的载具带到最近玩家",
    callback = function()
        TYHubBringVehicleToNearestPlayer()
    end,
})
VehiclePage:Button({
    title = "把最近载具带到我",
    callback = function()
        TYHubBringVehicleToMe(true)
    end,
})
VehiclePage:Button({
    title = "把最近载具带到最近玩家",
    callback = function()
        TYHubBringVehicleToNearestPlayer(true)
    end,
})
local bringPlayerInput = VehiclePage:Input({
    title = "目标玩家",
    placeholder = "输入完整用户名",
})
VehiclePage:Button({
    title = "把载具带到指定玩家",
    callback = function()
        TYHubBringVehicleToName(bringPlayerInput.Text)
    end,
})
VehiclePage:Slider({
    title = "带来距离",
    min = 5,
    max = 40,
    step = 1,
    default = 12,
    flag = "bringDistance",
    format = function(v)
        return string.format("%.0f m", v)
    end,
    callback = flagSetter("bringDistance"),
})
VehiclePage:Keybind({
    title = "带来载具按键",
    default = Enum.KeyCode.B,
    flag = "bringVehicleKey",
    callback = function(key)
        Settings.bringVehicleKey = key or Enum.KeyCode.B
    end,
})

VehiclePage:Section("速度", "进入驾驶座后生效")
VehiclePage:Toggle({
    title = "速度控制器",
    desc = "给座椅施加 LinearVelocity",
    flag = "vehicleBoost",
    callback = flagSetter("vehicleBoost"),
})
VehiclePage:Slider({
    title = "目标速度",
    min = 20,
    max = 500,
    step = 5,
    default = 120,
    flag = "vehicleSpeed",
    format = function(v)
        return string.format("%.0f", v)
    end,
    callback = flagSetter("vehicleSpeed"),
})
VehiclePage:Toggle({
    title = "定速巡航",
    desc = "持续保持油门",
    flag = "cruise",
    callback = flagSetter("cruise"),
})


-- Police
local PolicePage = newTab("警察", "◇", "police")
PolicePage:Section("执法", "手铐 / 传送")
PolicePage:Toggle({
    title = "自动铐",
    desc = "对范围内目标调用 handcuff",
    flag = "policeCuff",
    callback = flagSetter("policeCuff"),
})
PolicePage:Toggle({
    title = "自动传送",
    desc = "传送到最近的通缉平民身后",
    flag = "policeTp",
    callback = flagSetter("policeTp"),
})
PolicePage:Toggle({ title = "战斗检测", flag = "policeCombat", callback = flagSetter("policeCombat") })
PolicePage:Slider({
    title = "范围",
    min = 20,
    max = 1000,
    step = 10,
    default = 200,
    flag = "policeRange",
    callback = flagSetter("policeRange"),
})
PolicePage:Slider({
    title = "间隔",
    min = 0.1,
    max = 3,
    step = 0.1,
    default = 0.5,
    flag = "policeInterval",
    callback = flagSetter("policeInterval"),
})

-- Teleport
local TeleportPage = newTab("传送", "▫", "teleport")
local savedPosition = nil
TeleportPage:Section("玩家", "按名字传送")
local playerInput = TeleportPage:Input({
    title = "玩家名字",
    placeholder = "输入完整用户名",
})
TeleportPage:Button({
    title = "传送到玩家",
    callback = function()
        local name = playerInput.Text
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and string.lower(player.Name):find(string.lower(name), 1, true) then
                local root = getRoot(player)
                if root then
                    teleportTo(root.Position)
                    Notify("传送", "已传送到 " .. player.Name, "success")
                    return
                end
            end
        end
        Notify("传送", "未找到玩家", "error")
    end,
})
TeleportPage:Button({
    title = "传送到准星位置",
    callback = function()
        local cam = Workspace.CurrentCamera
        if not cam then
            return
        end
        local ray = cam:ScreenPointToRay(cam.ViewportSize.X / 2, cam.ViewportSize.Y / 2)
        local result = Workspace:Raycast(ray.Origin, ray.Direction * 800)
        if result then
            teleportTo(result.Position + result.Normal * 3)
        else
            teleportTo(ray.Origin + ray.Direction * 60)
        end
    end,
})

TeleportPage:Section("坐标", "记录与坐标传送")
TeleportPage:Button({
    title = "记录当前位置",
    callback = function()
        local _, _, root = getChar(LocalPlayer)
        if root then
            savedPosition = root.Position
            Notify("传送", "已记录当前位置", "success")
        end
    end,
})
TeleportPage:Button({
    title = "回到记录位置",
    callback = function()
        if savedPosition then
            teleportTo(savedPosition)
        else
            Notify("传送", "还没有记录位置", "warn")
        end
    end,
})
local coordInput = TeleportPage:Input({
    title = "坐标 (X, Y, Z)",
    placeholder = "例如 120, 30, -450",
})
TeleportPage:Button({
    title = "传送到坐标",
    callback = function()
        local x, y, z = string.match(coordInput.Text, "([%-%d%.]+)%s*,%s*([%-%d%.]+)%s*,%s*([%-%d%.]+)")
        if x and y and z then
            teleportTo(Vector3.new(tonumber(x), tonumber(y), tonumber(z)))
        else
            Notify("传送", "坐标格式错误", "error")
        end
    end,
})
TeleportPage:Button({
    title = "传送到出生点",
    callback = function()
        local spawn = Workspace:FindFirstChildOfClass("SpawnLocation")
        if spawn then
            teleportTo(spawn.Position)
        else
            Notify("传送", "没有找到出生点", "warn")
        end
    end,
})

function TYHubGameCore()
    if TYHubGameCoreCache ~= nil then
        return TYHubGameCoreCache
    end
    pcall(function()
        local modules = ReplicatedStorage:FindFirstChild("Modules")
        local loaderModule = modules and modules:FindFirstChild("ModuleLoader")
        local coreModule = Framework and Framework:FindFirstChild("Core")
        if loaderModule and coreModule then
            local loader = require(loaderModule)
            local core = require(coreModule)
            if type(loader.assign) == "function" then
                TYHubGameCoreCache = loader.assign(core)
            else
                TYHubGameCoreCache = core
            end
        end
    end)
    return TYHubGameCoreCache
end

function TYHubMapMarker()
    local sources = {}
    local gameCore = TYHubGameCore()
    if gameCore then
        table.insert(sources, gameCore)
    end
    if Core then
        table.insert(sources, Core)
    end
    for _, source in ipairs(sources) do
        if source then
            local ok, navigation = pcall(function()
                return source.navigationPoint
            end)
            if ok and typeof(navigation) == "Vector3" then
                return navigation
            end
            local ok2, waypoints = pcall(function()
                return source.waypoints
            end)
            if ok2 and type(waypoints) == "table" and type(waypoints.Navigation) == "function" then
                local ok3, result = pcall(waypoints.Navigation)
                if ok3 and typeof(result) == "Vector3" then
                    return result
                end
            end
        end
    end
    return nil
end

function TYHubTeleportToMarker()
    local position = TYHubMapMarker()
    if not position then
        Notify("传送", "地图没有设置标记，请打开地图点 Navigate", "warn")
        return
    end
    pcall(function()
        LocalPlayer:RequestStreamAroundAsync(position, 5)
    end)
    teleportTo(position + Vector3.new(0, 3, 0))
    Notify("传送", "已传送到地图标记", "success")
end

function TYHubLocationPart(location)
    if not location then
        return nil
    end
    if location:IsA("BasePart") then
        return location
    end
    local spawn = location:FindFirstChild("SpawnLocation", true)
    if spawn and spawn:IsA("BasePart") then
        return spawn
    end
    for _, descendant in ipairs(location:GetDescendants()) do
        if descendant.Name == "_Interaction" and descendant:IsA("BasePart") and descendant:FindFirstChildWhichIsA("ProximityPrompt", true) then
            return descendant
        end
    end
    return location:FindFirstChildWhichIsA("BasePart", true)
end

function TYHubTeleportToLocation(location)
    local part = TYHubLocationPart(location)
    if not part then
        Notify("传送", "地点不可用：" .. tostring(location and location.Name or "未知"), "warn")
        return
    end
    pcall(function()
        LocalPlayer:RequestStreamAroundAsync(part.Position, 5)
    end)
    local entered = false
    if Core and type(Core.enterLocation) == "function" then
        local ok = pcall(function()
            Core.enterLocation({ spawnPoint = part })
        end)
        entered = ok
    end
    if not entered then
        teleportTo(part.Position + Vector3.new(0, 3, 0))
    end
    Notify("传送", "已传送到 " .. tostring(location.Name), "success")
end

function TYHubBuildLocationUI(page)
    local holder = page.row(286)
    holder.BackgroundTransparency = 0.15
    local search = make("TextBox", {
        Size = UDim2.new(1, -20, 0, 30),
        Position = UDim2.fromOffset(10, 8),
        BackgroundColor3 = Theme.bg,
        BackgroundTransparency = 0.15,
        Text = "",
        PlaceholderText = "搜索地点…",
        PlaceholderColor3 = Theme.subtext,
        Font = Enum.Font.Gotham,
        TextSize = 11,
        TextColor3 = Theme.text,
        TextXAlignment = Enum.TextXAlignment.Left,
        ClearTextOnFocus = false,
        ZIndex = 5,
    }, holder)
    corner(search, 7)
    stroke(search, Theme.stroke, 1, 0.5)

    local list = make("ScrollingFrame", {
        Size = UDim2.new(1, -20, 0, 230),
        Position = UDim2.fromOffset(10, 44),
        BackgroundColor3 = Theme.bg,
        BackgroundTransparency = 0.35,
        BorderSizePixel = 0,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        ScrollingDirection = Enum.ScrollingDirection.Y,
        ScrollBarThickness = 3,
        ScrollBarImageColor3 = Theme.accent,
        ScrollBarImageTransparency = 0.3,
        ZIndex = 5,
    }, holder)
    corner(list, 8)
    make("UIPadding", {
        PaddingTop = UDim.new(0, 5),
        PaddingBottom = UDim.new(0, 5),
        PaddingLeft = UDim.new(0, 5),
        PaddingRight = UDim.new(0, 5),
    }, list)
    make("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 3),
    }, list)

    local order = 0
    local function refresh()
        for _, child in ipairs(list:GetChildren()) do
            if child:IsA("TextButton") or child:IsA("TextLabel") then
                child:Destroy()
            end
        end
        order = 0
        local folder = ReplicatedStorage:FindFirstChild("Stuff")
        folder = folder and folder:FindFirstChild("Locations")
        if not folder then
            return
        end
        local query = string.lower(search.Text or "")
        local locations = folder:GetChildren()
        table.sort(locations, function(a, b)
            return a.Name < b.Name
        end)
        local count = 0
        for _, location in ipairs(locations) do
            if query == "" or string.lower(location.Name):find(query, 1, true) then
                if count >= 80 then
                    break
                end
                count = count + 1
                order = order + 1
                local row = make("TextButton", {
                    Size = UDim2.new(1, 0, 0, 28),
                    BackgroundColor3 = Theme.surface,
                    BackgroundTransparency = 0.15,
                    Text = "  " .. location.Name,
                    Font = Enum.Font.Gotham,
                    TextSize = 11,
                    TextColor3 = Theme.text,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    AutoButtonColor = false,
                    LayoutOrder = order,
                    ZIndex = 6,
                }, list)
                corner(row, 6)
                row.MouseEnter:Connect(function()
                    row.BackgroundTransparency = 0.5
                    row.TextColor3 = Theme.accent3
                end)
                row.MouseLeave:Connect(function()
                    row.BackgroundTransparency = 0.15
                    row.TextColor3 = Theme.text
                end)
                row.MouseButton1Click:Connect(function()
                    TYHubTeleportToLocation(location)
                end)
            end
        end
        if count == 0 then
            local empty = make("TextLabel", {
                Size = UDim2.new(1, 0, 0, 26),
                BackgroundTransparency = 1,
                Text = "没有匹配的地点",
                Font = Enum.Font.Gotham,
                TextSize = 10,
                TextColor3 = Theme.subtext,
                LayoutOrder = 1,
            }, list)
            empty.Name = "EmptyLabel"
        end
    end

    search:GetPropertyChangedSignal("Text"):Connect(function()
        task.defer(refresh)
    end)
    refresh()
end

TeleportPage:Section("地图标记")
TeleportPage:Button({
    title = "传送到地图标记",
    callback = function()
        TYHubTeleportToMarker()
    end,
})

TeleportPage:Section("地点", "Stuff.Locations · 搜索 / 点击传送")
TYHubBuildLocationUI(TeleportPage)

-- Shop
local ShopPage = newTab("商店", "▪", "shop")
ShopPage:Section("快速交互", "黑市 / 补给")
local shopInput = ShopPage:Input({
    title = "关键字",
    default = "Buy",
    placeholder = "Buy / Purchase / Refill",
})
ShopPage:Button({
    title = "一键购买附近",
    callback = function()
        local _, _, root = getChar(LocalPlayer)
        if not root then
            return
        end
        local keyword = string.lower(shopInput.Text ~= "" and shopInput.Text or "buy")
        local hits = 0
        for _, descendant in ipairs(Workspace:GetDescendants()) do
            if descendant:IsA("ProximityPrompt") then
                local combined = string.lower((descendant.Name or "") .. " " .. (descendant.ActionText or "") .. " " .. (descendant.ObjectText or ""))
                if combined:find(keyword, 1, true) then
                    local pos = objectPosition(descendant)
                    if pos and (pos - root.Position).Magnitude <= 45 then
                        firePrompt(descendant)
                        hits = hits + 1
                    end
                end
            end
        end
        Notify("商店", "已交互 " .. hits .. " 个提示", hits > 0 and "success" or "warn")
    end,
})
ShopPage:Toggle({
    title = "自动补给",
    desc = "每 2 秒尝试 Refill / Ammo 提示",
    flag = "autoRefill",
    callback = flagSetter("autoRefill"),
})

task.spawn(function()
    while true do
        if Settings.autoRefill then
            local _, _, root = getChar(LocalPlayer)
            if root then
                for _, descendant in ipairs(Workspace:GetDescendants()) do
                    if descendant:IsA("ProximityPrompt") then
                        local combined = string.lower((descendant.Name or "") .. " " .. (descendant.ActionText or "") .. " " .. (descendant.ObjectText or ""))
                        if combined:find("refill", 1, true) or combined:find("ammo", 1, true) then
                            local pos = objectPosition(descendant)
                            if pos and (pos - root.Position).Magnitude <= 60 then
                                firePrompt(descendant)
                            end
                        end
                    end
                end
            end
        end
        task.wait(2)
    end
end)


local ConsolePage = newTab("控制台", "≡", "console")
ConsolePage:Label("运行日志", "TY hub 输出")
local consoleControl = ConsolePage:Label("暂无日志")
local consoleLines = {}
local function consoleAppend(message, kind)
    table.insert(consoleLines, "[" .. os.date("%H:%M:%S") .. "] " .. tostring(message))
    if #consoleLines > 90 then table.remove(consoleLines, 1) end
    consoleControl:SetText(table.concat(consoleLines, "\n"))
end
LogSink = consoleAppend
ConsolePage:Button({
    title = "清空日志",
    callback = function()
        table.clear(consoleLines)
        consoleControl:SetText("暂无日志")
        consoleAppend("日志已清空", "info")
    end,
})

-- Settings
local SettingsPage = newTab("设置", "◈", "settings")
SettingsPage:Section("界面", "TYHub 专属样式")
SettingsPage:Slider({
    title = "界面缩放",
    min = 0.6,
    max = 1.2,
    step = 0.05,
    default = scaleValue,
    flag = "uiScale",
    format = function(v)
        return string.format("%.0f%%", v * 100)
    end,
    callback = function(value)
        Settings.uiScale = value
        uiScale.Scale = value
        if glowScale then
            glowScale.Scale = value
        end
    end,
})
SettingsPage:Keybind({
    title = "菜单按键",
    desc = "显示 / 隐藏菜单",
    default = Enum.KeyCode.RightShift,
    flag = "menuKey",
    callback = function(key)
        Settings.menuKey = key or Enum.KeyCode.RightShift
        __BaseWindow.Keybind = Settings.menuKey
    end,
})
SettingsPage:Toggle({
    title = "手机快捷面板",
    desc = "屏幕边缘悬浮快捷开关",
    flag = "quickHud",
    callback = function(value)
        TYHubQuickSetEnabled(value)
    end,
})
SettingsPage:Section("配置", "保存与加载")
SettingsPage:Button({
    title = "保存配置",
    callback = function()
        if not writefile then
            Notify("保存配置", "执行器不支持 writefile", "error")
            return
        end
        pcall(function()
            if makefolder then
                makefolder("TYHub")
            end
        end)
        local output = {}
        for key, value in pairs(Settings) do
            local valueType = type(value)
            if typeof(value) == "EnumItem" then
                output[key] = tostring(value):gsub("Enum.KeyCode.", "")
            elseif valueType == "boolean" or valueType == "number" or valueType == "string" then
                output[key] = value
            elseif key == "espTeams" and valueType == "table" then
                local teams = {}
                for team, enabled in pairs(value) do
                    teams[team] = enabled
                end
                output[key] = teams
            end
        end
        local ok = pcall(function()
            writefile("TYHub/TYHubScript.json", HttpService:JSONEncode(output))
        end)
        Notify("保存配置", ok and "已写入 TYHub/TYHubScript.json" or "写入失败", ok and "success" or "error")
    end,
})
SettingsPage:Button({
    title = "加载配置",
    callback = function()
        if not (isfile and readfile) then
            Notify("加载配置", "执行器不支持文件读取", "error")
            return
        end
        local ok, data = pcall(function()
            if not isfile("TYHub/TYHubScript.json") then
                return nil
            end
            return HttpService:JSONDecode(readfile("TYHub/TYHubScript.json"))
        end)
        if not ok or type(data) ~= "table" then
            Notify("加载配置", "没有找到配置文件", "warn")
            return
        end
        for key, value in pairs(data) do
            if Settings[key] ~= nil then
                if key == "flyMode" and (value == "VX 锚定" or value == "锚定") then
                    value = "传送"
                end
                if type(value) == "string" and typeof(Settings[key]) == "EnumItem" then
                    value = Enum.KeyCode[value] or Settings[key]
                end
                if key == "espTeams" and type(value) == "table" then
                    Settings.espTeams = {}
                    for team, enabled in pairs(value) do
                        Settings.espTeams[team] = enabled
                    end
                else
                    Settings[key] = value
                end
                local control = ConfigRegistry[key]
                if control then
                    pcall(control.Set, value, true)
                end
            end
        end
        if TYHubQuick and TYHubQuick.Button and TYHubQuick.Panel then
            TYHubQuick.Button.Position = UDim2.fromOffset(Settings.quickButtonX or 12, Settings.quickButtonY or 250)
            TYHubQuick.Panel.Position = UDim2.fromOffset(Settings.quickPanelX or 12, Settings.quickPanelY or 74)
        end
        Notify("加载配置", "配置已应用", "success")
    end,
})
SettingsPage:Button({
    title = "卸载 TYHub script",
    callback = function()
        local fn = getgenv().TYHubScript and getgenv().TYHubScript.Unload
        if fn then
            fn()
        end
    end,
})
SettingsPage:Label("TYHub script  v1.0", "by TYHub  ·  紫黑流光")

--============================  QUICK PANEL (MOBILE)  ============================--

TYHubQuick = {
    Enabled = false,
    Visible = true,
    Expanded = false,
    Items = {},
    Button = nil,
    Panel = nil,
}

function TYHubQuickRefresh()
    if not TYHubQuick or not TYHubQuick.Items then
        return
    end
    for _, item in ipairs(TYHubQuick.Items) do
        local visual = item.Visual
        if visual then
            local active = item.type == "toggle" and Settings[item.key] == true
            if active then
                visual.fill.BackgroundTransparency = 0.75
                visual.stroke.Color = Theme.accent
                visual.stroke.Transparency = 0.15
                visual.glyph.TextColor3 = Theme.accent3
                visual.label.TextColor3 = Theme.text
                visual.dot.BackgroundColor3 = Theme.accent3
                visual.dot.BackgroundTransparency = 0
            else
                visual.fill.BackgroundTransparency = 1
                visual.stroke.Color = Theme.stroke
                visual.stroke.Transparency = 0.45
                visual.glyph.TextColor3 = item.type == "action" and Theme.accent3 or Theme.subtext
                visual.label.TextColor3 = item.type == "action" and Theme.text or Theme.subtext
                visual.dot.BackgroundColor3 = item.type == "action" and Theme.accent or Theme.stroke
                visual.dot.BackgroundTransparency = item.type == "action" and 0.2 or 0.55
            end
        end
    end
end

function TYHubQuickExpand(expand)
    if not TYHubQuick or not TYHubQuick.Panel then
        return
    end
    TYHubQuick.Expanded = expand and true or false
    if TYHubQuick.Expanded then
        if TYHubFloatingBtn then
            TYHubFloatingBtn.Visible = false
        end
    elseif not TYHubMenuOpen and TYHubFloatingBtn then
        TYHubFloatingBtn.Visible = true
    end

    if not TYHubQuick.Enabled or not TYHubQuick.Visible then
        TYHubQuick.Panel.Visible = false
        TYHubQuick.Button.Visible = false
        return
    end

    TYHubQuick.Panel.Visible = TYHubQuick.Expanded
    TYHubQuick.Button.Visible = not TYHubQuick.Expanded

    if TYHubQuick.Expanded then
        local viewport = (Workspace.CurrentCamera and Workspace.CurrentCamera.ViewportSize) or Vector2.new(1280, 720)
        local gridHeight = math.min(374, math.max(180, viewport.Y - 190))
        if TYHubQuick.Grid then
            TYHubQuick.Grid.Size = UDim2.fromOffset(186, gridHeight)
        end
        TYHubQuick.Panel.Size = UDim2.fromOffset(206, gridHeight + 58)
        local absolute = TYHubQuick.Panel.AbsolutePosition
        local size = TYHubQuick.Panel.AbsoluteSize
        TYHubQuick.Panel.Position = UDim2.fromOffset(
            math.clamp(absolute.X, 4, math.max(4, viewport.X - size.X - 4)),
            math.clamp(absolute.Y, 4, math.max(4, viewport.Y - size.Y - 4))
        )
    end
end

function TYHubQuickSetVisible(visible)
    if not TYHubQuick or not TYHubQuick.Panel then
        return
    end
    TYHubQuick.Visible = visible and true or false
    local show = TYHubQuick.Visible and TYHubQuick.Enabled
    TYHubQuick.Panel.Visible = show and TYHubQuick.Expanded
    TYHubQuick.Button.Visible = show and not TYHubQuick.Expanded
end

function TYHubQuickSetEnabled(enabled)
    if not TYHubQuick then
        return
    end
    if not TYHubQuick.Panel then
        Settings.quickHud = enabled and true or false
        return
    end
    TYHubQuick.Enabled = enabled and true or false
    Settings.quickHud = TYHubQuick.Enabled
    if not TYHubQuick.Enabled then
        TYHubQuick.Expanded = false
        if not TYHubMenuOpen and TYHubFloatingBtn then
            TYHubFloatingBtn.Visible = true
        end
    end
    if TYHubQuick.Enabled and TYHubQuick.Visible and not TYHubMenuOpen then
        TYHubQuick.Panel.Visible = TYHubQuick.Expanded
        TYHubQuick.Button.Visible = not TYHubQuick.Expanded
    else
        TYHubQuick.Panel.Visible = false
        TYHubQuick.Button.Visible = false
    end
end

function TYHubQuickBuild()
    if not ScreenGui or not ScreenGui.Parent then
        return
    end

    local quickViewport = (Workspace.CurrentCamera and Workspace.CurrentCamera.ViewportSize) or Vector2.new(1280, 720)
    local quickContentHeight = 374
    local quickGridHeight = math.min(quickContentHeight, math.max(180, quickViewport.Y - 190))
    local quickPanelHeight = quickGridHeight + 58

    local button = make("TextButton", {
        Name = "TYHubQuickButton",
        Size = UDim2.fromOffset(54, 54),
        Position = UDim2.fromOffset(Settings.quickButtonX or 12, Settings.quickButtonY or 250),
        BackgroundColor3 = Theme.panel,
        BackgroundTransparency = 0.04,
        Text = "",
        AutoButtonColor = false,
        ZIndex = 140,
    }, TYHubHudRoot)
    corner(button, 27)
    TYHubMetal(button, Color3.fromRGB(10, 6, 18), Color3.fromRGB(44, 32, 66), 90)
    make("Frame", {
        Size = UDim2.new(1, -16, 0, 1),
        Position = UDim2.fromOffset(8, 3),
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BackgroundTransparency = 0.65,
        BorderSizePixel = 0,
        ZIndex = 2,
    }, button)
    local buttonRing = stroke(button, Theme.accent, 1.6, 0.1)
    gradient(buttonRing, Theme.accent3, Theme.accent, 30)
    local buttonGlow = stroke(button, Theme.accent, 5, 0.92)
    gradient(buttonGlow, Theme.accent2, Theme.accent3, 30)

    local logo = text(button, "Q", 21, Color3.fromRGB(255, 255, 255), Enum.Font.GothamBlack, Enum.TextXAlignment.Center)
    logo.Size = UDim2.fromScale(1, 1)
    gradient(logo, Theme.accent3, Theme.accent, 90)

    local buttonDot = make("Frame", {
        Size = UDim2.fromOffset(8, 8),
        Position = UDim2.new(1, -13, 0, 9),
        BackgroundColor3 = Theme.accent3,
        BorderSizePixel = 0,
        ZIndex = 2,
    }, button)
    corner(buttonDot, 4)

    local panel = make("Frame", {
        Name = "TYHubQuickPanel",
        Size = UDim2.fromOffset(206, quickPanelHeight),
        Position = UDim2.fromOffset(Settings.quickPanelX or 12, Settings.quickPanelY or 74),
        BackgroundColor3 = Theme.panel,
        BackgroundTransparency = 0.02,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        Visible = false,
        ZIndex = 141,
    }, TYHubHudRoot)
    corner(panel, 16)
    TYHubMetal(panel, Color3.fromRGB(7, 4, 13), Color3.fromRGB(34, 24, 52), 90)
    local panelStroke = stroke(panel, Theme.accent, 1.4, 0.2)
    TYHubQuick.PanelEdge = gradient(panelStroke, Theme.accent2, Theme.accent3, 20)
    local panelGlow = stroke(panel, Theme.accent, 6, 0.93)
    gradient(panelGlow, Theme.accent, Theme.accent3, 20)

    local header = make("Frame", {
        Name = "Header",
        Size = UDim2.new(1, 0, 0, 38),
        BackgroundColor3 = Theme.bg,
        BackgroundTransparency = 0.12,
        BorderSizePixel = 0,
        ZIndex = 142,
    }, panel)
    TYHubMetal(header, Color3.fromRGB(10, 6, 18), Color3.fromRGB(42, 30, 62), 90)
    header.Active = true

    local quickSweep = make("Frame", {
        Size = UDim2.fromOffset(70, 38),
        Position = UDim2.fromOffset(-90, 0),
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BackgroundTransparency = 0,
        BorderSizePixel = 0,
        ZIndex = 142,
    }, header)
    make("UIGradient", {
        Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 1),
            NumberSequenceKeypoint.new(0.5, 0.86),
            NumberSequenceKeypoint.new(1, 1),
        }),
        Color = ColorSequence.new(Theme.accent3),
        Rotation = 18,
    }, quickSweep)
    task.spawn(function()
        while quickSweep.Parent do
            quickSweep.Position = UDim2.fromOffset(-90, 0)
            local tween = TweenService:Create(quickSweep, TweenInfo.new(2.8, Enum.EasingStyle.Linear), {
                Position = UDim2.fromOffset(216, 0),
            })
            tween:Play()
            tween.Completed:Wait()
            task.wait(3)
        end
    end)

    local title = text(header, "YING 快捷", 13, Theme.text, Enum.Font.GothamBold)
    title.Position = UDim2.fromOffset(12, 9)
    title.Size = UDim2.fromOffset(104, 20)
    title.ZIndex = 143
    gradient(title, Theme.accent3, Theme.accent, 90)

    local menuButton = make("TextButton", {
        Size = UDim2.fromOffset(22, 22),
        Position = UDim2.new(1, -56, 0, 8),
        BackgroundTransparency = 1,
        Text = "☰",
        Font = Enum.Font.GothamBold,
        TextSize = 13,
        TextColor3 = Theme.subtext,
        AutoButtonColor = false,
        ZIndex = 144,
    }, header)
    local collapseButton = make("TextButton", {
        Size = UDim2.fromOffset(22, 22),
        Position = UDim2.new(1, -30, 0, 8),
        BackgroundTransparency = 1,
        Text = "−",
        Font = Enum.Font.GothamBold,
        TextSize = 15,
        TextColor3 = Theme.subtext,
        AutoButtonColor = false,
        ZIndex = 144,
    }, header)

    make("Frame", {
        Size = UDim2.new(1, -20, 0, 1),
        Position = UDim2.fromOffset(10, 37),
        BackgroundColor3 = Theme.stroke,
        BackgroundTransparency = 0.3,
        BorderSizePixel = 0,
        ZIndex = 142,
    }, panel)

    local edgeAngle = 0
    connect(RunService.RenderStepped, function(dt)
        if panel.Parent and panel.Visible and TYHubQuick.PanelEdge then
            edgeAngle = (edgeAngle + dt * 40) % 360
            TYHubQuick.PanelEdge.Rotation = edgeAngle
        end
    end)

    local grid = make("ScrollingFrame", {
        Size = UDim2.fromOffset(186, quickGridHeight),
        Position = UDim2.fromOffset(10, 44),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        CanvasSize = UDim2.fromOffset(0, 374),
        ScrollingDirection = Enum.ScrollingDirection.Y,
        ScrollingEnabled = true,
        ElasticBehavior = Enum.ElasticBehavior.Never,
        ScrollBarThickness = 4,
        ScrollBarImageColor3 = Theme.accent,
        ScrollBarImageTransparency = 0.2,
        ClipsDescendants = true,
        ZIndex = 142,
    }, panel)
    make("UIGridLayout", {
        CellSize = UDim2.fromOffset(90, 56),
        CellPadding = UDim2.fromOffset(6, 6),
        SortOrder = Enum.SortOrder.LayoutOrder,
    }, grid)

    local items = {
        { type = "toggle", key = "ghost", label = "隐身", glyph = "◍" },
        { type = "action", key = "ghostExpose", label = "现身", glyph = "◐", action = function() TYHubGhostExpose(Settings.ghostExposeTime) end },
        { type = "action", key = "blink", label = "Blink", glyph = "►", action = function() TYHubBlink() end },
        { type = "toggle", key = "vehicleFly", label = "载具飞行", glyph = "✈" },
        { type = "toggle", key = "aura", label = "光环", glyph = "✦" },
        { type = "toggle", key = "aim", label = "自瞄", glyph = "◎" },
        { type = "toggle", key = "silent", label = "静默", glyph = "◇" },
        { type = "toggle", key = "esp", label = "ESP", glyph = "▣" },
        { type = "toggle", key = "fly", label = "飞行", glyph = "▲" },
        { type = "toggle", key = "noclip", label = "穿墙", glyph = "▫" },
        { type = "action", key = "mapMarker", label = "地图标记", glyph = "⌖", action = function() TYHubTeleportToMarker() end },
        { type = "action", key = "bringVehicle", label = "召载具", glyph = "▼", action = function() TYHubBringVehicleToMe() end },
    }

    for index, item in ipairs(items) do
        local tile = make("Frame", {
            Size = UDim2.fromOffset(90, 56),
            BackgroundColor3 = Theme.surface,
            BackgroundTransparency = 0.05,
            BorderSizePixel = 0,
            LayoutOrder = index,
            ZIndex = 143,
        }, grid)
        corner(tile, 10)
        TYHubMetal(tile, Color3.fromRGB(14, 9, 24), Color3.fromRGB(40, 30, 60), 90)
        local tileStroke = stroke(tile, Theme.stroke, 1, 0.45)
        make("Frame", {
            Size = UDim2.new(1, -12, 0, 1),
            Position = UDim2.fromOffset(6, 1),
            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
            BackgroundTransparency = 0.78,
            BorderSizePixel = 0,
            ZIndex = 2,
        }, tile)

        local fill = make("Frame", {
            Size = UDim2.fromScale(1, 1),
            BackgroundColor3 = Theme.accent2,
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            ZIndex = 1,
        }, tile)
        corner(fill, 10)
        TYHubMetal(fill, Theme.accent2, Theme.accent3, 90)

        local glyph = text(tile, item.glyph, 16, Theme.subtext, Enum.Font.GothamBold)
        glyph.Position = UDim2.fromOffset(9, 5)
        glyph.Size = UDim2.fromOffset(20, 18)
        glyph.ZIndex = 2

        local label = text(tile, item.label, 11, Theme.subtext, Enum.Font.GothamMedium)
        label.Position = UDim2.fromOffset(9, 27)
        label.Size = UDim2.new(1, -14, 0, 16)
        label.ZIndex = 2

        local dot = make("Frame", {
            Size = UDim2.fromOffset(7, 7),
            Position = UDim2.new(1, -15, 0, 9),
            BackgroundColor3 = Theme.stroke,
            BackgroundTransparency = 0.55,
            BorderSizePixel = 0,
            ZIndex = 3,
        }, tile)
        corner(dot, 4)

        local hit = make("TextButton", {
            Size = UDim2.fromScale(1, 1),
            BackgroundTransparency = 1,
            Text = "",
            ZIndex = 4,
        }, tile)
        hit.MouseButton1Click:Connect(function()
            if item.type == "action" then
                if item.action then
                    pcall(item.action)
                end
                TweenService:Create(fill, TweenInfo.new(0.12), { BackgroundTransparency = 0.55 }):Play()
                task.delay(0.18, function()
                    if fill.Parent then
                        TYHubQuickRefresh()
                    end
                end)
            else
                local control = ConfigRegistry[item.key]
                local newValue = not (Settings[item.key] == true)
                if control then
                    control.Set(newValue, true)
                else
                    Settings[item.key] = newValue
                end
                TYHubQuickRefresh()
            end
        end)

        item.Visual = {
            tile = tile,
            stroke = tileStroke,
            fill = fill,
            glyph = glyph,
            label = label,
            dot = dot,
        }
        table.insert(TYHubQuick.Items, item)
    end

    local function bindDrag(frame, handle, onTap, xKey, yKey)
        local dragging = false
        local moved = false
        local startInput = nil
        local startPosition = nil

        handle.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = true
                moved = false
                startInput = input.Position
                startPosition = frame.Position
                local connection
                connection = input.Changed:Connect(function()
                    if input.UserInputState == Enum.UserInputState.End then
                        dragging = false
                        if connection then
                            connection:Disconnect()
                        end
                        local viewport = (Workspace.CurrentCamera and Workspace.CurrentCamera.ViewportSize) or Vector2.new(1280, 720)
                        local absolute = frame.AbsolutePosition
                        local size = frame.AbsoluteSize
                        local clampedX = math.clamp(absolute.X, 4, math.max(4, viewport.X - size.X - 4))
                        local clampedY = math.clamp(absolute.Y, 4, math.max(4, viewport.Y - size.Y - 4))
                        frame.Position = UDim2.fromOffset(clampedX, clampedY)
                        if xKey then
                            Settings[xKey] = clampedX
                        end
                        if yKey then
                            Settings[yKey] = clampedY
                        end
                    end
                end)
            end
        end)

        UserInputService.InputChanged:Connect(function(input)
            if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                local delta = input.Position - startInput
                if math.abs(delta.X) > 6 or math.abs(delta.Y) > 6 then
                    moved = true
                end
                frame.Position = UDim2.new(
                    startPosition.X.Scale,
                    startPosition.X.Offset + delta.X,
                    startPosition.Y.Scale,
                    startPosition.Y.Offset + delta.Y
                )
            end
        end)

        if onTap then
            handle.MouseButton1Click:Connect(function()
                if not moved then
                    onTap()
                end
            end)
        end
    end

    bindDrag(button, button, function()
        TYHubQuickExpand(true)
        TYHubQuickRefresh()
    end, "quickButtonX", "quickButtonY")
    bindDrag(panel, header, nil, "quickPanelX", "quickPanelY")
    collapseButton.MouseButton1Click:Connect(function()
        TYHubQuickExpand(false)
    end)
    menuButton.MouseButton1Click:Connect(function()
        TYHubQuickExpand(false)
        setMenuOpen(true)
    end)

    TYHubQuick.Button = button
    TYHubQuick.Panel = panel
    TYHubQuick.Grid = grid
    TYHubQuickRefresh()
    TYHubQuickSetEnabled(Settings.quickHud)
end

TYHubQuickBuild()

--============================  CONFIG / UNLOAD  ============================--

local function Unload()
    if TYHubQuick then
        TYHubQuick.Enabled = false
        if TYHubQuick.Panel then
            TYHubQuick.Panel.Visible = false
        end
        if TYHubQuick.Button then
            TYHubQuick.Button.Visible = false
        end
    end
    Settings.autoMoney = false
    Settings.farmer = false
    Settings.taxi = false
    Settings.bus = false
    Settings.golf = false
    Settings.autoMission = false
    Settings.autoRefill = false
    Settings.autoAtm = false
    Settings.autoHack = false
    Settings.policeCuff = false
    Settings.policeTp = false
    Settings.aura = false
    Settings.ragebot = false
    Settings.vehicleFly = false
    Settings.blink = false
    Settings.fly = false
    pcall(clearConnections)
    pcall(clearAllHitboxes)
    pcall(function()
        if rangePart then
            rangePart:Destroy()
            rangePart = nil
        end
    end)
    pcall(setAutoHack, false)
    pcall(stopFly)
    pcall(clearVehicleForce)
    pcall(TYHubClearVehicleFly)
    for player in pairs(EspTrackers) do
        pcall(destroyTracker, player)
    end
    for model in pairs(TYHubVehicle.trackers) do
        pcall(TYHubDestroyVehicleTracker, model)
    end
    pcall(function()
        Settings.ghost = false
        setGhost(false)
    end)
    pcall(setNoclip, false)
    pcall(function()
        ScreenGui:Destroy()
    end)
    pcall(function()
        if ghostGui then
            ghostGui:Destroy()
        end
    end)
    pcall(function()
        EspFolder:Destroy()
    end)
    pcall(function()
        for _, line in ipairs(Draw.cross) do
            line:Remove()
        end
        if Draw.fov then
            Draw.fov:Remove()
        end
        if Draw.tracer then
            Draw.tracer:Remove()
        end
        if Draw.silentFov then
            Draw.silentFov:Remove()
        end
        if Draw.silentLine then
            Draw.silentLine:Remove()
        end
    end)
    getgenv().TYHubScriptLoaded = false
    getgenv().TYHubScript = nil
end

local __TYHubAlreadyUnloaded = false
local __TYHubOriginalUnload = Unload
Unload = function()
    if __TYHubAlreadyUnloaded then return end
    __TYHubAlreadyUnloaded = true
    __TYHubOriginalUnload()
    pcall(function() Library:Unload() end)
end
MainWindow:OnClose(Unload)
getgenv().TYHubSettings = Settings
getgenv().TYHubConfig = ConfigRegistry
getgenv().TYHubScript = { Unload = Unload }
return getgenv().TYHubScript


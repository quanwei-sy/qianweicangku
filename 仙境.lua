-- 仙境：独立服务器缝合版
local NothingLibrary = loadstring(game:HttpGetAsync('https://raw.githubusercontent.com/quanwei-sy/qianweicangku/refs/heads/main/%E6%BA%90%E7%A0%81.lua'))()

local __BaseWindow = NothingLibrary.new({
    Title = "TY hub｜仙境",
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


local Window = Library:CreateWindow({
	Title = '仙境 - [AI版]',
	Footer = "权威不是权威",
    Icon = 131153193945220,
	Center = true,
	AutoShow = true,
	Resizable = true,
	TabPadding = 8,
	MenuFadeTime = 0
})

-- 标签页定义
local Tabs = {
    Map = Window:AddTab('地图', 'map'),
    Func = Window:AddTab('功能', 'zap'),
    ESP = Window:AddTab('透视', 'eye'),
    ["UI Settings"] = Window:AddTab('UI 调试', 'settings'),
}

-- 核心通用服务
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local LocalPlayer = Players.LocalPlayer

-- 本地中文翻译字典模块
local TranslationDict = {
    ["Zippy"] = "青蛙",
    ["Lumin"] = "精灵",
    ["Green Lumin"] = "绿精灵",
    ["Red Lumin"] = "红精灵",
    ["White Lumin"] = "白精灵",
    ["Worm Lumin"] = "蠕虫精灵",
    ["Purple Lumin"] = "紫精灵",
    ["Merchant"] = "商人",
    ["ToyChest"] = "躲藏箱",
    ["Owl"] = "猫头鹰",
    ["Gnome"] = "地精",
    ["Bomb"] = "炸弹",
    ["Clown"] = "小丑",
    ["BalloonHead"] = "气球头",
    ["BalloonZombie"] = "气球僵尸",
    ["Ballerina"] = "芭蕾舞女",
    ["Tiltjack"] = "弹簧杰克",
    ["Alice"] = "爱丽丝",
    ["Jester"] = "戏法小丑",
    ["Smiley"] = "笑脸怪",
    ["WonderAndWander"] = "Wonder与Wander",
    ["EvilWonder"] = "邪恶Wonder",
    ["LuminRodent"] = "精灵鼠"
}

-- 通用翻译函数调用
local function TranslateName(name)
    return TranslationDict[name] or name
end

-- 地图标签页：传送功能模块
local TeleportGroup = Tabs.Map:AddLeftGroupbox('传送功能')

-- 安全传送核心逻辑（附带Y轴微调防卡地底）
local function safeTeleport(targetPos)
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        char:PivotTo(CFrame.new(targetPos + Vector3.new(0, 3, 0)))
    end
end

TeleportGroup:AddButton('青蛙传送', function()
    local npcsFolder = workspace:FindFirstChild("_NPCS_")
    if npcsFolder then
        local zippy = npcsFolder:FindFirstChild("Zippy")
        if zippy then
            safeTeleport(zippy:GetPivot().Position)
            Library:Notify("已传送到 青蛙！")
            return
        end
    end
    Library:Notify("未找到 Zippy，可能已被销毁或未加载。")
end)

TeleportGroup:AddButton('出口传送', function()
    local genMap = workspace:FindFirstChild("GeneratedMap")
    if genMap then
        local exitRoom = genMap:FindFirstChild("ExitRoom")
        if exitRoom then
            local scriptable = exitRoom:FindFirstChild("Scriptable")
            if scriptable then
                local merchant = scriptable:FindFirstChild("Merchant")
                if merchant then
                    safeTeleport(merchant:GetPivot().Position)
                    Library:Notify("已传送到 出口商人！")
                    return
                end
            end
        end
    end
    Library:Notify("未找到 出口位置，可能地图尚未完全生成。")
end)

-- 功能标签页：玩家功能模块
local PlayerFuncGroup = Tabs.Func:AddLeftGroupbox('玩家功能')

-- 1. 穿墙 (Noclip)
local noclipConnection = nil
local originalCollisions = {}

local function toggleNoclip(state)
    if state then
        if not noclipConnection then
            noclipConnection = RunService.Stepped:Connect(function()
                local char = LocalPlayer.Character
                if char then
                    for _, part in pairs(char:GetDescendants()) do
                        if part:IsA("BasePart") then
                            if originalCollisions[part] == nil then
                                originalCollisions[part] = part.CanCollide
                            end
                            if part.CanCollide then
                                part.CanCollide = false
                            end
                        end
                    end
                end
            end)
        end
    else
        if noclipConnection then
            noclipConnection:Disconnect()
            noclipConnection = nil
        end
        for part, defaultState in pairs(originalCollisions) do
            if part and part.Parent then
                part.CanCollide = defaultState
            end
        end
        table.clear(originalCollisions) 
    end
end

-- 2. 夜视 (Fullbright)
local defaultLighting = {
    Brightness = Lighting.Brightness,
    ClockTime = Lighting.ClockTime,
    FogEnd = Lighting.FogEnd,
    GlobalShadows = Lighting.GlobalShadows,
    Ambient = Lighting.Ambient,
    OutdoorAmbient = Lighting.OutdoorAmbient
}

local fullbrightConnection = nil
local function toggleFullbright(state)
    if state then
        Lighting.Brightness = 2
        Lighting.ClockTime = 14
        Lighting.FogEnd = 100000
        Lighting.GlobalShadows = false
        Lighting.Ambient = Color3.fromRGB(255, 255, 255)
        Lighting.OutdoorAmbient = Color3.fromRGB(255, 255, 255)

        if not fullbrightConnection then
            fullbrightConnection = Lighting.Changed:Connect(function()
                if Toggles.Player_Fullbright and Toggles.Player_Fullbright.Value then
                    Lighting.Brightness = 2
                    Lighting.ClockTime = 14
                    Lighting.FogEnd = 100000
                    Lighting.GlobalShadows = false
                    Lighting.Ambient = Color3.fromRGB(255, 255, 255)
                    Lighting.OutdoorAmbient = Color3.fromRGB(255, 255, 255)
                end
            end)
        end
    else
        if fullbrightConnection then
            fullbrightConnection:Disconnect()
            fullbrightConnection = nil
        end
        Lighting.Brightness = defaultLighting.Brightness
        Lighting.ClockTime = defaultLighting.ClockTime
        Lighting.FogEnd = defaultLighting.FogEnd
        Lighting.GlobalShadows = defaultLighting.GlobalShadows
        Lighting.Ambient = defaultLighting.Ambient
        Lighting.OutdoorAmbient = defaultLighting.OutdoorAmbient
    end
end

-- 3. 无限跳跃 (Infinite Jump)
local infJumpConnection = nil
local function toggleInfJump(state)
    if state then
        if not infJumpConnection then
            infJumpConnection = UserInputService.JumpRequest:Connect(function()
                local char = LocalPlayer.Character
                local hum = char and char:FindFirstChildOfClass("Humanoid")
                if hum then
                    hum:ChangeState(Enum.HumanoidStateType.Jumping)
                end
            end)
        end
    else
        if infJumpConnection then
            infJumpConnection:Disconnect()
            infJumpConnection = nil
        end
    end
end

-- 4. 自动交互 (Auto Interact)
local autoInteractConnection = nil
local originalPrompts = {} 

local function toggleAutoInteract(state)
    if state then
        if not autoInteractConnection then
            autoInteractConnection = RunService.Heartbeat:Connect(function()
                local char = LocalPlayer.Character
                local root = char and char:FindFirstChild("HumanoidRootPart")
                if not root then return end
                
                local npcFolder = workspace:FindFirstChild("_NPCS_")
                if not npcFolder then return end
                
                for _, npc in pairs(npcFolder:GetChildren()) do
                    if npc:IsA("Model") then
                        for _, prompt in pairs(npc:GetDescendants()) do
                            if prompt:IsA("ProximityPrompt") then
                                if originalPrompts[prompt] == nil then
                                    originalPrompts[prompt] = {
                                        HoldDuration = prompt.HoldDuration,
                                        MaxActivationDistance = prompt.MaxActivationDistance
                                    }
                                end
                                
                                prompt.HoldDuration = 0
                                prompt.MaxActivationDistance = 10
                                
                                local promptPos = nil
                                if prompt.Parent:IsA("Attachment") then
                                    promptPos = prompt.Parent.WorldPosition
                                elseif prompt.Parent:IsA("BasePart") then
                                    promptPos = prompt.Parent.Position
                                elseif prompt.Parent:IsA("Model") then
                                    promptPos = prompt.Parent:GetPivot().Position
                                end
                                
                                if promptPos then
                                    local dist = (root.Position - promptPos).Magnitude
                                    if dist <= 10 then
                                        if fireproximityprompt then
                                            fireproximityprompt(prompt)
                                        else
                                            prompt:InputHoldBegin()
                                            prompt:InputHoldEnd()
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end)
        end
    else
        if autoInteractConnection then
            autoInteractConnection:Disconnect()
            autoInteractConnection = nil
        end
        for prompt, data in pairs(originalPrompts) do
            if prompt and prompt.Parent then
                prompt.HoldDuration = data.HoldDuration
                prompt.MaxActivationDistance = data.MaxActivationDistance
            end
        end
        table.clear(originalPrompts)
    end
end

-- 5. 移速修改 (底层物理速度绕过版 - 完美保留动画且无视锁定)
local walkSpeedConnection = nil
local originalWalkSpeed = 16 

-- 动态获取玩家真实的默认移速 (如果还没加载出来，则使用16兜底)
pcall(function()
    local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local hum = char:WaitForChild("Humanoid", 3)
    if hum then
        originalWalkSpeed = hum.WalkSpeed
    end
end)

local function toggleWalkSpeed(state)
    if state then
        if not walkSpeedConnection then
            walkSpeedConnection = RunService.RenderStepped:Connect(function()
                local char = LocalPlayer.Character
                local hum = char and char:FindFirstChildOfClass("Humanoid")
                local root = char and char:FindFirstChild("HumanoidRootPart")
                
                if char and hum and root and hum.Health > 0 then
                    -- 策略1：高频覆盖原生WalkSpeed (防一般限速脚本)
                    hum.WalkSpeed = Options.Player_WalkSpeedValue.Value
                    
                    -- 策略2：底层物理速度强推 (防硬性限速系统，同时完美触发跑动动画)
                    if hum.MoveDirection.Magnitude > 0 then
                        local speed = Options.Player_WalkSpeedValue.Value
                        local currentVel = root.AssemblyLinearVelocity
                        
                        -- 赋予 X 和 Z 轴的动力，但保留 Y 轴 (这样你就还能正常跳跃和下落)
                        root.AssemblyLinearVelocity = Vector3.new(
                            hum.MoveDirection.X * speed,
                            currentVel.Y, 
                            hum.MoveDirection.Z * speed
                        )
                    end
                end
            end)
        end
    else
        if walkSpeedConnection then
            walkSpeedConnection:Disconnect()
            walkSpeedConnection = nil
        end
        local char = LocalPlayer.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.WalkSpeed = originalWalkSpeed
        end
    end
end

-- ================= UI 注册：玩家功能 =================
PlayerFuncGroup:AddToggle('Player_Noclip', { Text = '穿墙', Default = false, Callback = toggleNoclip })
PlayerFuncGroup:AddToggle('Player_Fullbright', { Text = '夜视', Default = false, Callback = toggleFullbright })
PlayerFuncGroup:AddToggle('Player_InfJump', { Text = '无限跳跃', Default = false, Callback = toggleInfJump })
PlayerFuncGroup:AddToggle('Player_AutoInteract', { 
    Text = '自动交互', 
    Default = false, 
    Callback = toggleAutoInteract 
})

PlayerFuncGroup:AddToggle('Player_WalkSpeedToggle', { 
    Text = '启用移速', 
    Default = false,
    Callback = toggleWalkSpeed 
})
PlayerFuncGroup:AddSlider('Player_WalkSpeedValue', { 
    Text = '移速设置', 
    Default = originalWalkSpeed, -- 绝对精准的初始原生移速
    Min = 10, 
    Max = 200, -- 上限提升到了 200
    Rounding = 0 
})

-- 透视功能模块开始
local ESPGroup = Tabs.ESP:AddLeftGroupbox('透视功能')
local ESPSettingsGroup = Tabs.ESP:AddRightGroupbox('透视设置')

local function getGuiContainer()
    local s, r = pcall(function() return game:GetService("CoreGui") end)
    return s and r or LocalPlayer:WaitForChild("PlayerGui")
end
local GuiContainer = getGuiContainer()

local espCache = {}

local function clearESP(target)
    if espCache[target] then
        if espCache[target].Highlight then espCache[target].Highlight:Destroy() end
        if espCache[target].Billboard then espCache[target].Billboard:Destroy() end
        espCache[target] = nil
    end
end

local function clearAllESP()
    for target, _ in pairs(espCache) do clearESP(target) end
end

local function clearTypeESP(targetType)
    for target, data in pairs(espCache) do
        if data.Type == targetType then clearESP(target) end
    end
end

local function createESP(target, targetType)
    if not target:IsA("Model") or espCache[target] then return end

    local highlight = Instance.new("Highlight")
    highlight.Adornee = target
    highlight.FillTransparency = 0.6
    highlight.OutlineTransparency = 0.2
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.Parent = GuiContainer

    local billboard = Instance.new("BillboardGui")
    billboard.Adornee = target
    billboard.Size = UDim2.new(0, 200, 0, 50)
    billboard.StudsOffset = Vector3.new(0, 1.5, 0)
    billboard.AlwaysOnTop = true
    billboard.Parent = GuiContainer

    local textLabel = Instance.new("TextLabel")
    textLabel.Parent = billboard
    textLabel.BackgroundTransparency = 1
    textLabel.Size = UDim2.new(1, 0, 1, 0)
    textLabel.Font = Enum.Font.Code
    textLabel.TextStrokeTransparency = 0
    textLabel.TextYAlignment = Enum.TextYAlignment.Bottom
    
    espCache[target] = {
        Highlight = highlight,
        Billboard = billboard,
        Text = textLabel,
        Type = targetType
    }
end

local espConnection = RunService.RenderStepped:Connect(function()
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    local originPos = root and root.Position or workspace.CurrentCamera.CFrame.Position

    local function processTarget(targetModel, targetType, targetName, targetColor)
        local targetPos = targetModel:GetPivot().Position
        local distance = math.floor((originPos - targetPos).Magnitude)

        if distance > Options.ESP_MaxDistance.Value then
            if espCache[targetModel] then clearESP(targetModel) end
            return
        end

        if not espCache[targetModel] then createESP(targetModel, targetType) end

        local cache = espCache[targetModel]
        if cache then
            cache.Highlight.FillColor = targetColor
            cache.Highlight.OutlineColor = targetColor
            cache.Text.TextColor3 = targetColor
            cache.Text.TextSize = Options.ESP_TextSize.Value
            
            local displayText = ""
            if Toggles.ESP_ShowName.Value then 
                displayText = targetName 
            end
            
            if Toggles.ESP_ShowDistance.Value then
                if displayText ~= "" then displayText = displayText .. "\n" end
                displayText = displayText .. string.format("[%dm]", distance)
            end
            cache.Text.Text = displayText
        end
    end

    -- [逻辑 1] NPC 透视渲染
    if Toggles.ESP_NPC.Value then
        local npcFolder = workspace:FindFirstChild("_NPCS_")
        if npcFolder then
            for _, npc in pairs(npcFolder:GetChildren()) do
                if npc:IsA("Model") then
                    local hasPrompt = npc:FindFirstChildWhichIsA("ProximityPrompt", true)
                    local renderColor = hasPrompt and Options.ESP_NPC_Color.Value or Color3.fromRGB(255, 128, 128)
                    
                    local localizedName = TranslateName(npc.Name)
                    processTarget(npc, "NPC", localizedName, renderColor)
                end
            end
        end
    end

    -- [逻辑 2] 玩家 透视渲染
    if Toggles.ESP_Player.Value then
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character and player.Character.Parent == workspace then
                local hum = player.Character:FindFirstChild("Humanoid")
                if hum and hum.Health > 0 then
                    processTarget(player.Character, "Player", player.Name, Options.ESP_Player_Color.Value)
                end
            end
        end
    end

    -- [逻辑 3] 躲藏箱 透视渲染
    if Toggles.ESP_Chest.Value then
        local chestFolder = workspace:FindFirstChild("ToyChests")
        if chestFolder then
            for _, chest in pairs(chestFolder:GetChildren()) do
                if chest:IsA("Model") then
                    local localizedName = TranslateName(chest.Name)
                    processTarget(chest, "Chest", localizedName, Options.ESP_Chest_Color.Value)
                end
            end
        end
    end

    -- [逻辑 4] 垃圾回收清理
    for target, data in pairs(espCache) do
        local shouldRemove = false
        
        if not target.Parent then 
            shouldRemove = true 
        elseif data.Type == "NPC" and (not Toggles.ESP_NPC.Value or target.Parent.Name ~= "_NPCS_") then
            shouldRemove = true
        elseif data.Type == "Player" then
            local hum = target:FindFirstChild("Humanoid")
            if not Toggles.ESP_Player.Value or not hum or hum.Health <= 0 then
                shouldRemove = true
            end
        elseif data.Type == "Chest" and (not Toggles.ESP_Chest.Value or target.Parent.Name ~= "ToyChests") then
            shouldRemove = true
        end

        if shouldRemove then clearESP(target) end
    end
end)

ESPGroup:AddToggle('ESP_NPC', {
    Text = 'NPC透视',
    Default = false,
    Callback = function(Value) if not Value then clearTypeESP("NPC") end end
}):AddColorPicker('ESP_NPC_Color', {
    Default = Color3.fromRGB(173, 216, 230),
    Title = 'NPC 颜色',
})

ESPGroup:AddToggle('ESP_Player', {
    Text = '玩家透视',
    Default = false,
    Callback = function(Value) if not Value then clearTypeESP("Player") end end
}):AddColorPicker('ESP_Player_Color', {
    Default = Color3.fromRGB(154, 205, 50),
    Title = '玩家 颜色',
})

ESPGroup:AddToggle('ESP_Chest', {
    Text = '躲藏箱透视',
    Default = false,
    Callback = function(Value) if not Value then clearTypeESP("Chest") end end
}):AddColorPicker('ESP_Chest_Color', {
    Default = Color3.fromRGB(216, 191, 216), -- 淡紫色
    Title = '躲藏箱 颜色',
})


ESPSettingsGroup:AddToggle('ESP_ShowName', { Text = '显示名字', Default = true })
ESPSettingsGroup:AddToggle('ESP_ShowDistance', { Text = '显示距离', Default = true })
ESPSettingsGroup:AddSlider('ESP_TextSize', { Text = '字体大小', Default = 5, Min = 3, Max = 10, Rounding = 0 })
ESPSettingsGroup:AddSlider('ESP_MaxDistance', { Text = '透视范围', Default = 300, Min = 100, Max = 1000, Rounding = 0 })

-- UI 调试标签页
local MenuGroup = Tabs["UI Settings"]:AddLeftGroupbox('设置')

MenuGroup:AddButton('卸载菜单', function() Library:Unload() end)
MenuGroup:AddLabel('菜单快捷键'):AddKeyPicker('MenuKeybind', { Default = 'End', NoUI = true, Text = 'Menu keybind' })

Library.ToggleKeybind = Options.MenuKeybind

if ThemeManager and SaveManager then
    ThemeManager:SetLibrary(Library)
    SaveManager:SetLibrary(Library)
    SaveManager:IgnoreThemeSettings()
    SaveManager:SetIgnoreIndexes({ 'MenuKeybind' })
    ThemeManager:SetFolder('ObsidianNOL')
    SaveManager:SetFolder('ObsidianNOL/specific-game')
    SaveManager:BuildConfigSection(Tabs["UI Settings"])
    ThemeManager:ApplyToTab(Tabs["UI Settings"])
end

Library:OnUnload(function()
    toggleNoclip(false)
    toggleFullbright(false)
    toggleInfJump(false)
    toggleAutoInteract(false)
    toggleWalkSpeed(false)

    if espConnection then espConnection:Disconnect() end
    clearAllESP()

    print("[TY hub] 已清理完毕")
end)

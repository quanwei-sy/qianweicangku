-- 末日生存：独立服务器缝合版
local NothingLibrary = loadstring(game:HttpGetAsync('https://raw.githubusercontent.com/quanwei-sy/qianweicangku/refs/heads/main/%E6%BA%90%E7%A0%81.lua'))()

local __BaseWindow = NothingLibrary.new({
    Title = "TY hub｜末日生存",
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
    Title = '末日生存 - [AI版]',
    Footer = "权威不是权威",
    Icon = 131153193945220,
    Center = true,
    AutoShow = true,
    Resizable = true,
    TabPadding = 8,
    MenuFadeTime = 0
})

local Tabs = {
    Map = Window:AddTab('地图', 'map'),
    Func = Window:AddTab('功能', 'zap'),
    ESP = Window:AddTab('透视', 'eye'),
    ["UI Settings"] = Window:AddTab('UI 调试', 'settings'),
}

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

-- =========================================================
-- [ 完整本地翻译字典与分类库 ]
-- =========================================================
local CategoryTranslations = {
    ["AlienCrystals"] = "外星水晶", ["Ammo"] = "弹药", ["Armor"] = "护甲装备", ["Food"] = "食物饮料",
    ["Fuel"] = "燃料", ["Resources"] = "基础资源", ["Guns"] = "枪械武器", ["Medical"] = "医疗用品",
    ["Melee"] = "近战武器", ["Items_Misc"] = "物品-杂项", ["Structures"] = "建筑结构", 
    ["Tools_Abilities"] = "技能与能力", ["Tools_Alchemist"] = "炼金物品", ["Tools_Backpacks"] = "背包",
    ["Tools_Consumable"] = "投掷消耗品", ["Tools_Misc"] = "工具-杂项", ["UpgradedStructures"] = "升级版建筑"
}

local ItemTranslations = {
    ["Alien Component"] = "外星组件", ["Blue Alien Crystal"] = "蓝色外星水晶", ["Green Alien Crystal"] = "绿色外星水晶", 
    ["Orange Alien Crystal"] = "橙色外星水晶", ["Purple Alien Crystal"] = "紫色外星水晶", ["Yellow Alien Crystal"] = "黄色外星水晶",
    ["Ammo Box"] = "弹药箱", ["Long Ammo"] = "长管弹药", ["Medium Ammo"] = "中型弹药", ["Pistol Ammo"] = "手枪弹药", ["Shells"] = "霰弹",
    ["Heavy Armor"] = "重型护甲", ["Light Armor"] = "轻型护甲", ["Medium Armor"] = "中型护甲", ["Power Armor"] = "动力护甲",
    ["Beans"] = "豆子罐头", ["Bloxiade"] = "运动饮料", ["Bloxy Cola"] = "可乐", ["Cake"] = "蛋糕", 
    ["Carrot"] = "胡萝卜", ["Chips"] = "薯片", ["MRE"] = "军用口粮",
    ["Fuel"] = "燃料", ["Nuclear Fuel"] = "核燃料", ["Refined Fuel"] = "精炼燃料",
    ["AC"] = "空调单元", ["Battery"] = "电池", ["Battery Pack"] = "电池组", ["Bucket"] = "水桶", ["Dumbell"] = "哑铃", 
    ["Exhaust Pipe"] = "排气管", ["Reactor Component"] = "反应堆组件", ["Refined Metal"] = "精炼金属", ["Satellite Dish"] = "卫星天线", 
    ["Scrap"] = "废料", ["Screws"] = "螺丝", ["Spatula"] = "抹刀", ["TV"] = "电视机", ["Tray"] = "托盘", ["Watch"] = "手表", ["Zombie Heart"] = "僵尸心脏",
    ["AA-12"] = "AA-12 连发霰弹枪", ["AK-47"] = "AK-47 步枪", ["Assault Rifle"] = "突击步枪", ["Combat SMG"] = "战斗冲锋枪", 
    ["Crossbow"] = "十字弩", ["Desert Eagle"] = "沙漠之鹰", ["Double Barrel"] = "双管猎枪", ["Explosive Crossbow"] = "爆炸十字弩", 
    ["Flamethrower"] = "火焰喷射器", ["Freeze Ray"] = "冰冻射线", ["Grenade Launcher"] = "榴弹发射器", ["Heavy Revolver"] = "重型左轮", 
    ["Heavy Sniper"] = "重型狙击枪", ["Infiltrator Uzi"] = "渗透者 Uzi", ["Ion Shotgun"] = "离子霰弹枪", ["LMG"] = "轻机枪", 
    ["MediGun"] = "医疗枪", ["Minigun"] = "迷你机枪", ["Pistol"] = "手枪", ["Railgun"] = "电磁轨道炮", ["Ray Gun"] = "射线枪", 
    ["Revolver"] = "左轮手枪", ["Rifle"] = "步枪", ["SVD"] = "SVD 狙击步枪", ["Shotgun"] = "霰弹枪", ["Sniper"] = "狙击枪", 
    ["Tactical Shield"] = "战术护盾", ["Uzi"] = "Uzi 冲锋枪",
    ["Bandage"] = "绷带", ["Compound H"] = "化合物 H", ["Compound I"] = "化合物 I", ["Compound R"] = "化合物 R", 
    ["Compound S"] = "化合物 S", ["Medkit"] = "医疗包",
    ["Bat"] = "球棒", ["Bloodthirster"] = "饮血剑", ["Chainsaw"] = "电锯", ["Crowbar"] = "撬棍", ["Dark Scythe"] = "黑暗镰刀", 
    ["Energy Blade"] = "能量刃", ["Fire Axe"] = "消防斧", ["Hatchet"] = "短柄斧", ["Katana"] = "武士刀", ["Knife"] = "小刀", 
    ["Mace"] = "钉头锤", ["Power Hammer"] = "动力锤", ["Riot Shield"] = "防暴盾", ["Scythe"] = "镰刀", ["Sledgehammer"] = "大锤", 
    ["Spear"] = "长矛", ["Spiked Bat"] = "钉刺球棒",
    ["Birthday Hat"] = "生日帽", ["Blood Gem"] = "血宝石", ["Data Coin"] = "数据币", ["Emerald"] = "绿宝石", 
    ["Gas Mask"] = "防毒面具", ["Power Armor Arm"] = "动力护甲手臂", ["Power Armor Core"] = "动力护甲核心", ["Radio Tower Part"] = "无线电塔零件",
    ["Ammo Crate"] = "弹药箱(建筑)", ["Barbed Wire"] = "铁丝网", ["Bear Trap"] = "捕熊夹", ["Boost Pad"] = "加速带", 
    ["Electric Fence"] = "电网", ["Farm Plot"] = "农田", ["Fence"] = "栅栏", ["Floodlight"] = "探照灯", ["Gate"] = "大门", 
    ["Good Bed"] = "好床", ["Great Bed"] = "极品床", ["Healing Pad"] = "治疗垫", ["Infection Tracker"] = "感染追踪器", 
    ["Landmine"] = "地雷", ["Map"] = "地图(建筑)", ["Military Turret"] = "军用炮塔", ["Mortar"] = "迫击炮", ["Old Bed"] = "破旧的床", 
    ["Repair Drone"] = "维修无人机", ["Shelf"] = "置物架", ["Teleporter"] = "传送阵", ["Time Machine"] = "时光机", 
    ["Turret"] = "自动炮塔", ["UV Light"] = "紫外线灯", ["Wall"] = "墙壁", ["Watchtower"] = "瞭望塔",
    ["Barrel"] = "圆桶", ["Crashed Car 1"] = "废弃汽车 1", ["Crashed Car 2"] = "废弃汽车 2", ["Generator"] = "发电机", ["Scrap Pile"] = "废料堆",
    ["Airstrike"] = "呼叫空袭", ["Attack Order"] = "攻击指令", ["Brewing Stand"] = "酿造台", ["Call of the Dead"] = "亡灵呼唤", 
    ["Charge"] = "冲锋", ["Control Pad"] = "控制板", ["Counter"] = "反击", ["Infiltrate"] = "渗透", ["Psychic Editor"] = "精神编辑器", 
    ["Quickdraw"] = "快速拔枪", ["Remote Arsenal"] = "远程军火库", ["Requiem"] = "安魂曲", ["Stalk"] = "潜行跟踪", ["Summon"] = "召唤", 
    ["Summon Brute"] = "召唤暴君", ["Summon Zombies"] = "召唤僵尸", ["System Override"] = "系统覆盖", ["Taunt"] = "嘲讽", 
    ["The Future"] = "预见未来", ["The Past"] = "回溯过去", ["The Present"] = "掌控现在",
    ["Acid Potion"] = "酸液药水", ["Bloater Core"] = "巨无霸核心", ["Ice Potion"] = "冰冻药水", ["Muscle Eye"] = "肌肉眼球", 
    ["Nuclear Rod"] = "核燃料棒", ["Recovery Compound"] = "恢复复合物", ["Rotten Flesh"] = "腐肉", ["Screamer Claw"] = "尖叫者利爪", 
    ["Spitter Heart"] = "喷吐者心脏", ["Tainted Steel"] = "受污染的钢铁", ["Weakening Potion"] = "虚弱药水",
    ["Basic Backpack"] = "基础背包", ["Good Backpack"] = "优良背包", ["Great Backpack"] = "极品背包",
    ["Flashbang"] = "闪光弹", ["Grenade"] = "破片手榴弹", ["Molotov"] = "燃烧瓶", ["Tear Gas"] = "催泪瓦斯",
    ["Blueprint"] = "蓝图", ["Data Coin"] = "数据币(工具)", ["Mansion Keycard"] = "豪宅门禁卡", ["Military Keycard"] = "军事门禁卡", 
    ["Repair Hammer"] = "维修锤", ["Sealed Blood Gem"] = "密封血宝石", ["Suppressor"] = "消音器", ["Upgrade Hammer"] = "升级锤", ["Wrench"] = "扳手",
    ["Barbed Wire"] = "铁丝网(升级)", ["Electric Fence"] = "电网(升级)", ["Fence"] = "栅栏(升级)", ["Gate"] = "大门(升级)", ["Watchtower"] = "瞭望塔(升级)",
    
    ["Bandit"] = "强盗", ["Heavy Rebel"] = "重装叛军", ["Rebel"] = "叛军", 
    ["Brute"] = "暴君", ["Crawler"] = "爬行者", ["Zombie"] = "僵尸", 
    ["Runner"] = "奔跑者", ["Merchant"] = "商人",
    ["Phaser"] = "相位者", ["Riot"] = "防暴者", ["Spitter"] = "喷吐者", ["Bloater"] = "巨无霸"
}

local ItemDatabase = {
    ["AlienCrystals"] = {"Alien Component", "Blue Alien Crystal", "Green Alien Crystal", "Orange Alien Crystal", "Purple Alien Crystal", "Yellow Alien Crystal"},
    ["Ammo"] = {"Ammo Box", "Long Ammo", "Medium Ammo", "Pistol Ammo", "Shells"},
    ["Armor"] = {"Heavy Armor", "Light Armor", "Medium Armor", "Power Armor"},
    ["Food"] = {"Beans", "Bloxiade", "Bloxy Cola", "Cake", "Carrot", "Chips", "MRE"},
    ["Fuel"] = {"Fuel", "Nuclear Fuel", "Refined Fuel"},
    ["Resources"] = {"AC", "Battery", "Battery Pack", "Bucket", "Dumbell", "Exhaust Pipe", "Reactor Component", "Refined Metal", "Satellite Dish", "Scrap", "Screws", "Spatula", "TV", "Tray", "Watch", "Zombie Heart"},
    ["Guns"] = {"AA-12", "AK-47", "Assault Rifle", "Combat SMG", "Crossbow", "Desert Eagle", "Double Barrel", "Explosive Crossbow", "Flamethrower", "Freeze Ray", "Grenade Launcher", "Heavy Revolver", "Heavy Sniper", "Infiltrator Uzi", "Ion Shotgun", "LMG", "MediGun", "Minigun", "Pistol", "Railgun", "Ray Gun", "Revolver", "Rifle", "SVD", "Shotgun", "Sniper", "Tactical Shield", "Uzi"},
    ["Medical"] = {"Bandage", "Compound H", "Compound I", "Compound R", "Compound S", "Medkit"},
    ["Melee"] = {"Bat", "Bloodthirster", "Chainsaw", "Crowbar", "Dark Scythe", "Energy Blade", "Fire Axe", "Hatchet", "Katana", "Knife", "Mace", "Power Hammer", "Riot Shield", "Scythe", "Sledgehammer", "Spear", "Spiked Bat"},
    ["Items_Misc"] = {"Birthday Hat", "Blood Gem", "Data Coin", "Emerald", "Gas Mask", "Power Armor Arm", "Power Armor Core", "Radio Tower Part"},
    ["Structures"] = {"Ammo Crate", "Barbed Wire", "Bear Trap", "Boost Pad", "Electric Fence", "Farm Plot", "Fence", "Floodlight", "Gate", "Good Bed", "Great Bed", "Healing Pad", "Infection Tracker", "Landmine", "Map", "Military Turret", "Mortar", "Old Bed", "Repair Drone", "Shelf", "Teleporter", "Time Machine", "Turret", "UV Light", "Wall", "Watchtower", "Barrel", "Crashed Car 1", "Crashed Car 2", "Generator", "Scrap Pile"},
    ["Tools_Abilities"] = {"Airstrike", "Attack Order", "Brewing Stand", "Call of the Dead", "Charge", "Control Pad", "Counter", "Infiltrate", "Psychic Editor", "Quickdraw", "Remote Arsenal", "Requiem", "Stalk", "Summon", "Summon Brute", "Summon Zombies", "System Override", "Taunt", "The Future", "The Past", "The Present"},
    ["Tools_Alchemist"] = {"Acid Potion", "Bloater Core", "Ice Potion", "Muscle Eye", "Nuclear Rod", "Recovery Compound", "Rotten Flesh", "Screamer Claw", "Spitter Heart", "Tainted Steel", "Weakening Potion"},
    ["Tools_Backpacks"] = {"Basic Backpack", "Good Backpack", "Great Backpack"},
    ["Tools_Consumable"] = {"Flashbang", "Grenade", "Molotov", "Tear Gas"},
    ["Tools_Misc"] = {"Blueprint", "Data Coin", "Mansion Keycard", "Military Keycard", "Repair Hammer", "Sealed Blood Gem", "Suppressor", "Upgrade Hammer", "Wrench"},
    ["UpgradedStructures"] = {"Barbed Wire", "Electric Fence", "Fence", "Gate", "Watchtower"}
}

local ExcludedDropdownCategories = {
    ["Tools_Abilities"] = true,
    ["UpgradedStructures"] = true,
    ["Structures"] = true
}

local ESPTypeOptions = {}
local TypeToKeyMap = {} 
local GlobalZhToEngMap = {} 

for key, zhName in pairs(CategoryTranslations) do
    if not ExcludedDropdownCategories[key] then
        table.insert(ESPTypeOptions, zhName)
        TypeToKeyMap[zhName] = key
    end
end

for category, items in pairs(ItemDatabase) do
    for _, engName in ipairs(items) do
        local zhName = ItemTranslations[engName] or engName
        GlobalZhToEngMap[zhName] = engName
    end
end

-- =========================================================
-- [ 拾取系统底层分类与等级评估库 ]
-- =========================================================
local DirectInventoryItems = {} -- 记录哪些物品要直通主背包 (拾取交互)
local checkCategories = {"Medical", "Tools_Consumable", "Tools_Backpacks", "Armor", "Ammo"}
for _, cat in ipairs(checkCategories) do
    if ItemDatabase[cat] then
        for _, itemName in ipairs(ItemDatabase[cat]) do DirectInventoryItems[itemName] = true end
    end
end

-- 护甲与背包双轨隔离防降级字典
local GearTiers = {
    Backpacks = { ["Basic Backpack"] = 1, ["Good Backpack"] = 2, ["Great Backpack"] = 3 },
    Armors = { ["Light Armor"] = 1, ["Medium Armor"] = 2, ["Heavy Armor"] = 3, ["Power Armor"] = 4 }
}

local function IsLocalPlayerNearGenerator()
    local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return false end
    local structuresFolder = Workspace:FindFirstChild("Structures")
    local generator = structuresFolder and structuresFolder:FindFirstChild("Generator")
    if generator then
        local genPos = generator:GetPivot().Position
        if (hrp.Position - genPos).Magnitude <= 60 then return true end
    end
    return false
end

local AmmoCache = {}
if ItemDatabase["Ammo"] then
    for _, aName in ipairs(ItemDatabase["Ammo"]) do AmmoCache[aName] = true end
end

-- =========================================================
-- [ 功能 (Func) 模块：UI 构建 ]
-- =========================================================
local FuncGroup_Left = Tabs.Func:AddLeftGroupbox('拾取功能')
local PlayerGroup_Left = Tabs.Func:AddLeftGroupbox('玩家功能') 
local CombatGroup_Right = Tabs.Func:AddRightGroupbox('战斗辅助 (远程/近战)')

-- ====== 拾取功能 ======
FuncGroup_Left:AddDropdown('PickupTypeDropdown', { Values = ESPTypeOptions, Default = 0, Multi = true, Text = '物品类型' })
FuncGroup_Left:AddDropdown('PickupItemDropdown', { Values = {"(请先选择物品类型)"}, Default = 0, Multi = true, Text = '物品选择' })

Options.PickupTypeDropdown:OnChanged(function()
    local selectedCategories = Options.PickupTypeDropdown.Value
    local availableItemsZh = {}
    for zhName, isSelected in pairs(selectedCategories) do
        if isSelected then
            local rawKey = TypeToKeyMap[zhName]
            if rawKey and ItemDatabase[rawKey] then
                for _, engName in ipairs(ItemDatabase[rawKey]) do
                    local displayZhName = ItemTranslations[engName] or engName 
                    table.insert(availableItemsZh, displayZhName)
                end
            end
        end
    end
    if #availableItemsZh == 0 then table.insert(availableItemsZh, "(无可用物品)") end
    Options.PickupItemDropdown:SetValues(availableItemsZh)
end)

local PickupSelectionRow = FuncGroup_Left:AddButton({
    Text = '全选',
    Func = function()
        local allItems = {}
        for _, zhName in ipairs(Options.PickupItemDropdown.Values) do
            if zhName ~= "(无可用物品)" and zhName ~= "(请先选择物品类型)" then allItems[zhName] = true end
        end
        Options.PickupItemDropdown:SetValue(allItems)
    end, DoubleClick = false
})

PickupSelectionRow:AddButton({ Text = '清除', Func = function() Options.PickupItemDropdown:SetValue({}) end, DoubleClick = false })

FuncGroup_Left:AddToggle('AutoPickupToggle', { Text = '范围拾取', Default = false })
FuncGroup_Left:AddSlider('PickupRange', { Text = '范围设置', Default = 25, Min = 10, Max = 25, Rounding = 0, Compact = false })

local AutoPickupActive = false
Toggles.AutoPickupToggle:OnChanged(function()
    AutoPickupActive = Toggles.AutoPickupToggle.Value
    if AutoPickupActive then
        task.spawn(function()
            while AutoPickupActive and not Library.Unloaded do
                task.wait(0.2)
                
                if IsLocalPlayerNearGenerator() then continue end

                local char = LocalPlayer.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                if not hrp then continue end

                local droppedFolder = Workspace:FindFirstChild("DroppedItems")
                if not droppedFolder then continue end

                local rs = game:GetService("ReplicatedStorage")
                local adjustRemote = rs:FindFirstChild("Remotes") and rs.Remotes:FindFirstChild("Tools") and rs.Remotes.Tools:FindFirstChild("AdjustBackpack")
                local interactionRemote = rs:FindFirstChild("Remotes") and rs.Remotes:FindFirstChild("Interaction") and rs.Remotes.Interaction:FindFirstChild("PickUpItem")

                -- 【彻底修复】：通过读取背包 UI 面板的 CountLabel 文本精准判断是否满载
                local currentTool = char:FindFirstChildOfClass("Tool")
                local isHoldingBackpack = currentTool and string.find(currentTool.Name, "Backpack")
                local isBackpackFull = false
                
                if isHoldingBackpack then
                    local display = currentTool:FindFirstChild("Display")
                    local countLabel = display and display:FindFirstChild("CountLabel")
                    if countLabel and countLabel:IsA("TextLabel") then
                        -- 解析类似 "1/10" 的文本格式
                        local currentCount, maxCount = string.match(countLabel.Text, "(%d+)/(%d+)")
                        if currentCount and maxCount then
                            if tonumber(currentCount) >= tonumber(maxCount) then
                                isBackpackFull = true
                            end
                        end
                    end
                end

                local selectedItemsZh = Options.PickupItemDropdown.Value
                local activeEnglishNames = {}
                for zhName, isSelected in pairs(selectedItemsZh) do
                    if isSelected and GlobalZhToEngMap[zhName] then activeEnglishNames[GlobalZhToEngMap[zhName]] = true end
                end

                for _, item in ipairs(droppedFolder:GetChildren()) do
                    if item:GetAttribute("Dead") then continue end
                    local itemName = item.Name
                    
                    if activeEnglishNames[itemName] then
                        local anchor = item:IsA("BasePart") and item or item:FindFirstChildWhichIsA("BasePart", true)
                        if anchor and (hrp.Position - anchor.Position).Magnitude <= Options.PickupRange.Value then
                            
                            -- 分类防降级检测
                            local gearCategory, targetTier = nil, nil
                            if GearTiers.Backpacks[itemName] then gearCategory = GearTiers.Backpacks; targetTier = gearCategory[itemName]
                            elseif GearTiers.Armors[itemName] then gearCategory = GearTiers.Armors; targetTier = gearCategory[itemName] end

                            if gearCategory and targetTier then
                                local currentTier = 0
                                local itemsToCheck = char:GetChildren()
                                if LocalPlayer:FindFirstChild("Backpack") then
                                    for _, bpItem in ipairs(LocalPlayer.Backpack:GetChildren()) do table.insert(itemsToCheck, bpItem) end
                                end
                                for _, child in ipairs(itemsToCheck) do
                                    if gearCategory[child.Name] then currentTier = math.max(currentTier, gearCategory[child.Name]) end
                                end
                                if targetTier <= currentTier then continue end
                            end

                            -- 满载保护与直通背包判定
                            if DirectInventoryItems[itemName] then
                                if interactionRemote then pcall(function() interactionRemote:FireServer(item) end) end
                            else
                                if isHoldingBackpack and not isBackpackFull and adjustRemote then
                                    pcall(function() adjustRemote:FireServer(item) end)
                                end
                            end
                        end
                    end
                end
            end
        end)
    end
end)

-- ====== 玩家功能 (原版丝滑修改逻辑) ======
PlayerGroup_Left:AddToggle('InfJump', { Text = '无限跳跃开关按钮', Default = false })
PlayerGroup_Left:AddToggle('Noclip', { Text = '穿墙开关按钮', Default = false })
PlayerGroup_Left:AddToggle('FastInteract', { Text = '快速交互开关按钮', Default = false })
PlayerGroup_Left:AddToggle('SpeedToggle', { Text = '启用移速开关按钮', Default = false })
PlayerGroup_Left:AddSlider('SpeedSlider', { Text = '移速设置', Default = 16, Min = 10, Max = 66, Rounding = 0, Compact = false })

-- 记录原始移速防泄露
local originalWalkSpeed = 16
if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
    originalWalkSpeed = LocalPlayer.Character:FindFirstChildOfClass("Humanoid").WalkSpeed
end

local CharAddedConnection = LocalPlayer.CharacterAdded:Connect(function(newChar)
    local hum = newChar:WaitForChild("Humanoid", 3)
    if hum and (not Toggles.SpeedToggle or not Toggles.SpeedToggle.Value) then
        originalWalkSpeed = hum.WalkSpeed
    end
end)

local InfJumpConnection = UserInputService.JumpRequest:Connect(function()
    if Library.Unloaded then return end
    if Toggles.InfJump and Toggles.InfJump.Value then
        local char = LocalPlayer.Character
        if char then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
        end
    end
end)

-- 还原为最稳定的碰撞清除穿墙，去除了状态修改防止回拉抽搐
local NoclipConnection = RunService.Stepped:Connect(function()
    if Library.Unloaded then return end
    if Toggles.Noclip and Toggles.Noclip.Value then
        local char = LocalPlayer.Character
        if char then
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") then part.CanCollide = false end
            end
        end
    end
end)

local originalPromptsDuration = {}
local function RestorePrompts()
    for prompt, origDuration in pairs(originalPromptsDuration) do
        if prompt and prompt.Parent then prompt.HoldDuration = origDuration end
    end
    table.clear(originalPromptsDuration)
end

task.spawn(function()
    while not Library.Unloaded do
        task.wait(1)
        if Toggles.FastInteract and Toggles.FastInteract.Value then
            for _, prompt in ipairs(workspace:GetDescendants()) do
                if prompt:IsA("ProximityPrompt") then
                    if prompt.HoldDuration > 0 then
                        originalPromptsDuration[prompt] = prompt.HoldDuration
                        prompt.HoldDuration = 0
                    end
                end
            end
        else
            RestorePrompts()
        end
    end
end)

-- ====== 战斗辅助 ======
CombatGroup_Right:AddToggle('NoRecoil', { Text = '无后坐力 & 无散布', Default = false, Tooltip = '强制清零枪械的弹道扩散和屏幕抖动' })
CombatGroup_Right:AddToggle('InstantReload', { Text = '瞬间换弹 (防假子弹)', Default = false, Tooltip = '将换弹时间改为0，无视服务器弹匣校验' })
CombatGroup_Right:AddToggle('AutoFire', { Text = '强制全自动开火', Default = false, Tooltip = '移除蓄力时间限制，使所有枪械变全自动' })
CombatGroup_Right:AddSlider('FireRateMult', { Text = '射速倍率', Default = 1, Min = 1, Max = 10, Rounding = 1, Compact = false })
CombatGroup_Right:AddToggle('AntiDebuff', { Text = '免疫负面状态 (霸体)', Default = false, Tooltip = '无视眩晕、减速、中毒等异常状态' })
CombatGroup_Right:AddToggle('KillAura', { Text = '杀戮光环 (自动打怪)', Default = false, Tooltip = '手持近战武器时自动秒杀范围内的敌人' })
CombatGroup_Right:AddToggle('DestroyAura', { Text = '破坏光环 (砸圆桶/废车)', Default = false, Tooltip = '手持近战武器时仅自动砸毁特定资源结构，不拆家' })
CombatGroup_Right:AddSlider('AuraRange', { Text = '光环攻击范围', Default = 25, Min = 10, Max = 60, Rounding = 0, Compact = false })

local DebuffsList = {"Stunned", "Shock", "SpitterSlow", "CrawlerSlow", "Burning", "Blight", "Meltdown", "Chilled", "DataOverflow", "PoisonFog"}

-- 帧级主引擎：原版移速、枪械属性、霸体
local RenderConnection = RunService.RenderStepped:Connect(function()
    if Library.Unloaded then return end
    local char = LocalPlayer.Character
    if not char then return end
    
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then
        if Toggles.SpeedToggle and Toggles.SpeedToggle.Value then
            hum.WalkSpeed = Options.SpeedSlider.Value
        elseif not Toggles.SpeedToggle.Value and originalWalkSpeed then
            -- 不开启时，不再强制锁死速度，允许游戏原生的Buff加减速
            if hum.WalkSpeed == Options.SpeedSlider.Value then
                hum.WalkSpeed = originalWalkSpeed 
            end
        end
    end

    -- 枪械属性
    if Options.FireRateMult then
        local mult = Options.FireRateMult.Value
        if mult > 1 then char:SetAttribute("FireRate", mult - 1) else
            if char:GetAttribute("FireRate") then char:SetAttribute("FireRate", 0) end
        end
    end

    local tool = char:FindFirstChildOfClass("Tool")
    if tool and tool:FindFirstChild("Stats") then
        local stats = tool.Stats
        if Toggles.NoRecoil and Toggles.NoRecoil.Value then
            stats:SetAttribute("Recoil", 0); stats:SetAttribute("Inaccuracy", 0)
        end
        if Toggles.AutoFire and Toggles.AutoFire.Value then
            stats:SetAttribute("Automatic", true)
            if stats:GetAttribute("ChargeTime") then stats:SetAttribute("ChargeTime", nil) end
            if stats:GetAttribute("WarmUp") then stats:SetAttribute("WarmUp", nil) end
        end
        if Toggles.InstantReload and Toggles.InstantReload.Value then
            if stats:GetAttribute("ReloadTime") then stats:SetAttribute("ReloadTime", 0) end
            if stats:GetAttribute("ReloadIndividualTime") then stats:SetAttribute("ReloadIndividualTime", 0) end
            if stats:GetAttribute("ReloadEndTime") then stats:SetAttribute("ReloadEndTime", 0) end
        end
    end

    -- 霸体系统
    if Toggles.AntiDebuff and Toggles.AntiDebuff.Value then
        local timers = LocalPlayer:FindFirstChild("StatusEffectTimers")
        if timers then
            for _, debuff in ipairs(DebuffsList) do
                if timers:GetAttribute(debuff) then timers:SetAttribute(debuff, nil) end
            end
        end
        if char:GetAttribute("InPoison") then char:SetAttribute("InPoison", nil) end
    end
end)

-- 近战光环
task.spawn(function()
    while not Library.Unloaded do
        task.wait(0.2)
        local killOn = Toggles.KillAura and Toggles.KillAura.Value
        local destroyOn = Toggles.DestroyAura and Toggles.DestroyAura.Value
        if not killOn and not destroyOn then continue end

        local char = LocalPlayer.Character
        if not char then continue end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then continue end
        local tool = char:FindFirstChildOfClass("Tool")
        if not tool then continue end
        
        local swingRemote = tool:FindFirstChild("Swing")
        local hitRemote = tool:FindFirstChild("HitTargets")
        
        if swingRemote and hitRemote then
            local targets = {}
            local range = Options.AuraRange.Value
            
            if killOn then
                local charsFolder = Workspace:FindFirstChild("Characters")
                if charsFolder then
                    for _, targetChar in ipairs(charsFolder:GetChildren()) do
                        if targetChar ~= char and targetChar.Name ~= "Merchant" then
                            if Players:GetPlayerFromCharacter(targetChar) then continue end
                            local targetHrp = targetChar:FindFirstChild("HumanoidRootPart") or targetChar:FindFirstChild("Torso")
                            local hum = targetChar:FindFirstChild("Humanoid")
                            if targetChar:GetAttribute("Dead") or (hum and hum.Health <= 0) then continue end

                            if targetHrp and hum and hum.Health > 0 then
                                if (targetHrp.Position - hrp.Position).Magnitude <= range then table.insert(targets, targetChar) end
                            end
                        end
                    end
                end
            end
            
            if destroyOn then
                local structuresFolder = Workspace:FindFirstChild("Structures")
                local targetStructs = { ["Barrel"] = true, ["Scrap Pile"] = true, ["Crashed Car 1"] = true, ["Crashed Car 2"] = true }
                if structuresFolder then
                    for _, struct in ipairs(structuresFolder:GetChildren()) do
                        if targetStructs[struct.Name] then
                            if struct:GetAttribute("Dead") then continue end
                            local health = struct:GetAttribute("Health")
                            if health and health <= 0 then continue end
                            local structAnchor = struct:IsA("BasePart") and struct or struct:FindFirstChildWhichIsA("BasePart", true)
                            if structAnchor and (structAnchor.Position - hrp.Position).Magnitude <= range then table.insert(targets, struct) end
                        end
                    end
                end
            end
            
            if #targets > 0 then
                local batch = {}
                for i = 1, math.min(#targets, 15) do table.insert(batch, targets[i]) end
                pcall(function() swingRemote:FireServer(); hitRemote:FireServer(batch) end)
            end
        end
    end
end)

-- =========================================================
-- [ 地图 (Map) 功能模块 ]
-- =========================================================
local MapGroup_Left = Tabs.Map:AddLeftGroupbox('清理功能')

MapGroup_Left:AddButton({
    Text = '删除天空盒',
    Func = function()
        local lighting = game:GetService("Lighting")
        local sky = lighting:FindFirstChild("Sky")
        if sky then sky:Destroy() Library:Notify("天空盒已成功删除", 3) else Library:Notify("未找到天空盒，可能已被删除", 3) end
    end, DoubleClick = false,
})

MapGroup_Left:AddButton({
    Text = '解锁地图迷雾',
    Func = function()
        local rs = game:GetService("ReplicatedStorage")
        local fogRemote = rs:FindFirstChild("Remotes")
        if fogRemote then fogRemote = fogRemote:FindFirstChild("Misc") end
        if fogRemote then fogRemote = fogRemote:FindFirstChild("FogTouched") end
        local fogContainer = workspace:FindFirstChild("Fog")
        if not fogRemote or not fogContainer then Library:Notify("解锁失败", 3) return end
        
        local coords = {}
        for _, child in ipairs(fogContainer:GetChildren()) do
            local x_str, z_str = child.Name:match("^(-?%d+)_(-?%d+)$")
            if x_str and z_str then coords[#coords+1] = { tonumber(x_str), tonumber(z_str) } end
        end
        for _, coord in ipairs(coords) do fogRemote:FireServer(coord[1], coord[2]); task.wait() end
        Library:Notify("已解锁 " .. #coords .. " 个迷雾区域", 3)
    end, DoubleClick = false,
})

-- =========================================================
-- [ ESP 透视模块 ]
-- =========================================================
local ESPGroup_Left = Tabs.ESP:AddLeftGroupbox('透视功能')
local ESPGroup_Right = Tabs.ESP:AddRightGroupbox('透视设置')

ESPGroup_Left:AddDropdown('ESPTypeDropdown', { Values = ESPTypeOptions, Default = 0, Multi = true, Text = '透视类型' })
ESPGroup_Left:AddDropdown('ESPItemDropdown', { Values = {"(请先选择透视类型)"}, Default = 0, Multi = true, Text = '透视物品' })

Options.ESPTypeDropdown:OnChanged(function()
    local selectedCategories = Options.ESPTypeDropdown.Value
    local availableItemsZh = {}
    for zhName, isSelected in pairs(selectedCategories) do
        if isSelected then
            local rawKey = TypeToKeyMap[zhName]
            if rawKey and ItemDatabase[rawKey] then
                for _, engName in ipairs(ItemDatabase[rawKey]) do table.insert(availableItemsZh, ItemTranslations[engName] or engName) end
            end
        end
    end
    if #availableItemsZh == 0 then table.insert(availableItemsZh, "(无可用物品)") end
    Options.ESPItemDropdown:SetValues(availableItemsZh)
end)

local SelectionRow = ESPGroup_Left:AddButton({
    Text = '全选物品', Func = function()
        local allItems = {}
        for _, zhName in ipairs(Options.ESPItemDropdown.Values) do
            if zhName ~= "(无可用物品)" and zhName ~= "(请先选择透视类型)" then allItems[zhName] = true end
        end
        Options.ESPItemDropdown:SetValue(allItems)
    end, DoubleClick = false
})

SelectionRow:AddButton({ Text = '清除物品', Func = function() Options.ESPItemDropdown:SetValue({}) end, DoubleClick = false })

ESPGroup_Left:AddToggle('MasterESPToggle', { Text = '物品透视', Default = false }):AddColorPicker('ESPItemColor', { Default = Color3.fromRGB(173, 216, 230), Title = '物品透视颜色', Transparency = 0 })
ESPGroup_Left:AddToggle('MonsterESPToggle', { Text = '怪物透视', Default = false }):AddColorPicker('MonsterESPColor', { Default = Color3.fromRGB(255, 128, 128), Title = '怪物透视颜色', Transparency = 0 })
ESPGroup_Left:AddToggle('PlayerESPToggle', { Text = '玩家透视', Default = false }):AddColorPicker('PlayerESPColor', { Default = Color3.fromRGB(154, 205, 50), Title = '玩家透视颜色', Transparency = 0 })
ESPGroup_Left:AddToggle('StructureESPToggle', { Text = '结构透视', Default = false }):AddColorPicker('StructureESPColor', { Default = Color3.fromRGB(216, 191, 216), Title = '结构透视颜色', Transparency = 0 })
ESPGroup_Left:AddToggle('CrateESPToggle', { Text = '宝箱透视', Default = false }):AddColorPicker('CrateESPColor', { Default = Color3.fromRGB(255, 255, 153), Title = '宝箱透视颜色', Transparency = 0 })

ESPGroup_Right:AddToggle('ESPShowName', { Text = '显示名字', Default = true })
ESPGroup_Right:AddToggle('ESPShowDistance', { Text = '显示距离', Default = true })
ESPGroup_Right:AddToggle('ESPShowHighlight', { Text = '显示模型高亮', Default = true })
ESPGroup_Right:AddSlider('ESPHighlightTransparency', { Text = '高亮透明度', Default = 0.6, Min = 0, Max = 1, Rounding = 2, Compact = false })
ESPGroup_Right:AddSlider('ESPFontSize', { Text = '字体大小', Default = 5, Min = 3, Max = 15, Rounding = 0, Compact = false })
ESPGroup_Right:AddSlider('ESPRange', { Text = '透视范围 (Studs)', Default = 350, Min = 100, Max = 3000, Rounding = 0, Compact = false })

local ESPFolder = Instance.new("Folder"); ESPFolder.Name = "GeHub_ESP_Cache"; ESPFolder.Parent = game.CoreGui
local ESPCache = {}

local function CreateESP(model)
    if ESPCache[model] then return ESPCache[model] end
    local anchorPart = model:IsA("BasePart") and model or model:FindFirstChildWhichIsA("BasePart", true)
    if not anchorPart then return nil end
    local highlight = Instance.new("Highlight"); highlight.Adornee = model; highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop; highlight.OutlineTransparency = 0.2; highlight.Parent = ESPFolder
    local billboard = Instance.new("BillboardGui"); billboard.Adornee = anchorPart; billboard.AlwaysOnTop = true; billboard.Size = UDim2.new(0, 100, 0, 50); billboard.StudsOffset = Vector3.new(0, 1, 0); billboard.Parent = ESPFolder
    local textLabel = Instance.new("TextLabel"); textLabel.Parent = billboard; textLabel.BackgroundTransparency = 1; textLabel.Size = UDim2.new(1, 0, 1, 0); textLabel.Font = Enum.Font.Code; textLabel.TextStrokeTransparency = 0.2; textLabel.Text = ""
    ESPCache[model] = { Highlight = highlight, Billboard = billboard, TextLabel = textLabel, Anchor = anchorPart }
    return ESPCache[model]
end

local function ClearESP(model)
    if ESPCache[model] then ESPCache[model].Highlight:Destroy(); ESPCache[model].Billboard:Destroy(); ESPCache[model] = nil end
end

local ESPConnection = RunService.RenderStepped:Connect(function()
    local rootPart = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return end
    local currentItemsInWorkspace = {}

    if Toggles.MasterESPToggle.Value and Workspace:FindFirstChild("DroppedItems") then
        local activeNames = {}
        for zhName, isSelected in pairs(Options.ESPItemDropdown.Value) do
            if isSelected and GlobalZhToEngMap[zhName] then activeNames[GlobalZhToEngMap[zhName]] = true end
        end
        for _, item in ipairs(Workspace.DroppedItems:GetChildren()) do
            currentItemsInWorkspace[item] = true
            if activeNames[item.Name] and not item:GetAttribute("Dead") then
                local anchor = item:IsA("BasePart") and item or item:FindFirstChildWhichIsA("BasePart", true)
                if anchor and (rootPart.Position - anchor.Position).Magnitude <= Options.ESPRange.Value then
                    local espObj = CreateESP(item)
                    if espObj then
                        espObj.Highlight.Enabled = Toggles.ESPShowHighlight.Value; espObj.Highlight.FillTransparency = Options.ESPHighlightTransparency.Value; espObj.Billboard.Enabled = true
                        espObj.Highlight.FillColor = Options.ESPItemColor.Value; espObj.Highlight.OutlineColor = Options.ESPItemColor.Value; espObj.TextLabel.TextColor3 = Options.ESPItemColor.Value; espObj.TextLabel.TextSize = Options.ESPFontSize.Value
                        local lbl = Toggles.ESPShowName.Value and (ItemTranslations[item.Name] or item.Name) or ""
                        if Toggles.ESPShowDistance.Value then lbl = lbl .. (lbl ~= "" and "\n" or "") .. string.format("[%.1f]", (rootPart.Position - anchor.Position).Magnitude) end
                        espObj.TextLabel.Text = lbl
                    end
                else if ESPCache[item] then ESPCache[item].Highlight.Enabled = false; ESPCache[item].Billboard.Enabled = false end end
            else ClearESP(item) end
        end
    end

    if (Toggles.MonsterESPToggle.Value or Toggles.PlayerESPToggle.Value) and Workspace:FindFirstChild("Characters") then
        for _, char in ipairs(Workspace.Characters:GetChildren()) do
            if char == LocalPlayer.Character or char.Name == "Merchant" then continue end 
            currentItemsInWorkspace[char] = true
            local isPlayer = Players:GetPlayerFromCharacter(char) ~= nil
            local shouldESP = (isPlayer and Toggles.PlayerESPToggle.Value) or (not isPlayer and Toggles.MonsterESPToggle.Value)
            local targetColor = isPlayer and Options.PlayerESPColor.Value or Options.MonsterESPColor.Value
            
            local hum = char:FindFirstChild("Humanoid")
            if not isPlayer and (char:GetAttribute("Dead") or (hum and hum.Health <= 0)) then shouldESP = false end

            if shouldESP then
                local anchor = char:FindFirstChild("HumanoidRootPart") or char:FindFirstChildWhichIsA("BasePart", true)
                if anchor and (rootPart.Position - anchor.Position).Magnitude <= Options.ESPRange.Value then
                    local espObj = CreateESP(char)
                    if espObj then
                        espObj.Highlight.Enabled = Toggles.ESPShowHighlight.Value; espObj.Highlight.FillTransparency = Options.ESPHighlightTransparency.Value; espObj.Billboard.Enabled = true
                        espObj.Highlight.FillColor = targetColor; espObj.Highlight.OutlineColor = targetColor; espObj.TextLabel.TextColor3 = targetColor; espObj.TextLabel.TextSize = Options.ESPFontSize.Value
                        local lbl = Toggles.ESPShowName.Value and (isPlayer and char.Name or (ItemTranslations[char.Name] or char.Name)) or ""
                        if Toggles.ESPShowDistance.Value then lbl = lbl .. (lbl ~= "" and "\n" or "") .. string.format("[%.1f]", (rootPart.Position - anchor.Position).Magnitude) end
                        espObj.TextLabel.Text = lbl
                    end
                else if ESPCache[char] then ESPCache[char].Highlight.Enabled = false; ESPCache[char].Billboard.Enabled = false end end
            else ClearESP(char) end
        end
    end

    if Toggles.StructureESPToggle.Value and Workspace:FindFirstChild("Structures") then
        local AllowedStructures = { ["Barrel"] = true, ["Crashed Car 1"] = true, ["Crashed Car 2"] = true, ["Scrap Pile"] = true, ["Generator"] = true }
        for _, struct in ipairs(Workspace.Structures:GetChildren()) do
            if not AllowedStructures[struct.Name] then ClearESP(struct); continue end
            if struct:GetAttribute("Dead") then ClearESP(struct); continue end
            local hp = struct:GetAttribute("Health")
            if hp and hp <= 0 then ClearESP(struct); continue end
            
            currentItemsInWorkspace[struct] = true
            local anchor = struct:IsA("BasePart") and struct or struct:FindFirstChildWhichIsA("BasePart", true)
            if anchor and (rootPart.Position - anchor.Position).Magnitude <= Options.ESPRange.Value then
                local espObj = CreateESP(struct)
                if espObj then
                    espObj.Highlight.Enabled = Toggles.ESPShowHighlight.Value; espObj.Highlight.FillTransparency = Options.ESPHighlightTransparency.Value; espObj.Billboard.Enabled = true
                    espObj.Highlight.FillColor = Options.StructureESPColor.Value; espObj.Highlight.OutlineColor = Options.StructureESPColor.Value; espObj.TextLabel.TextColor3 = Options.StructureESPColor.Value; espObj.TextLabel.TextSize = Options.ESPFontSize.Value
                    local lbl = Toggles.ESPShowName.Value and (ItemTranslations[struct.Name] or struct.Name) or ""
                    if Toggles.ESPShowDistance.Value then lbl = lbl .. (lbl ~= "" and "\n" or "") .. string.format("[%.1f]", (rootPart.Position - anchor.Position).Magnitude) end
                    espObj.TextLabel.Text = lbl
                end
            else if ESPCache[struct] then ESPCache[struct].Highlight.Enabled = false; ESPCache[struct].Billboard.Enabled = false end end
        end
    end

    if Toggles.CrateESPToggle.Value and Workspace:FindFirstChild("Map") and Workspace.Map:FindFirstChild("Crates") then
        for _, crate in ipairs(Workspace.Map.Crates:GetChildren()) do
            local prompt = crate:FindFirstChild("Prompt")
            if crate:GetAttribute("Opened") or (prompt and prompt.Enabled == false) then ClearESP(crate); continue end
            currentItemsInWorkspace[crate] = true
            local anchor = crate:IsA("BasePart") and crate or crate:FindFirstChildWhichIsA("BasePart", true)
            if anchor and (rootPart.Position - anchor.Position).Magnitude <= Options.ESPRange.Value then
                local espObj = CreateESP(crate)
                if espObj then
                    espObj.Highlight.Enabled = Toggles.ESPShowHighlight.Value; espObj.Highlight.FillTransparency = Options.ESPHighlightTransparency.Value; espObj.Billboard.Enabled = true
                    espObj.Highlight.FillColor = Options.CrateESPColor.Value; espObj.Highlight.OutlineColor = Options.CrateESPColor.Value; espObj.TextLabel.TextColor3 = Options.CrateESPColor.Value; espObj.TextLabel.TextSize = Options.ESPFontSize.Value
                    local lbl = Toggles.ESPShowName.Value and "宝箱" or ""
                    if Toggles.ESPShowDistance.Value then lbl = lbl .. (lbl ~= "" and "\n" or "") .. string.format("[%.1f]", (rootPart.Position - anchor.Position).Magnitude) end
                    espObj.TextLabel.Text = lbl
                end
            else if ESPCache[crate] then ESPCache[crate].Highlight.Enabled = false; ESPCache[crate].Billboard.Enabled = false end end
        end
    end

    for model, _ in pairs(ESPCache) do
        if not currentItemsInWorkspace[model] or not model.Parent then ClearESP(model) end
    end
end)

-- =========================================================
-- [ UI 调试与内存安全卸载闭环清理 ]
-- =========================================================
local MenuGroup = Tabs["UI Settings"]:AddLeftGroupbox('设置')
MenuGroup:AddButton('卸载菜单', function() Library:Unload() end)
MenuGroup:AddLabel('菜单快捷键'):AddKeyPicker('MenuKeybind', { Default = 'End', NoUI = true, Text = 'Menu keybind' })
Library.ToggleKeybind = Options.MenuKeybind

Library:OnUnload(function()
    -- 1. 改变全局状态切断后台所有 task.spawn 死循环
    Library.Unloaded = true
    print("[TY hub] 正在执行闭环清理逻辑，防止内存泄漏...")
    
    -- 2. 安全切断所有底层引擎连接
    if RenderConnection then RenderConnection:Disconnect() end
    if ESPConnection then ESPConnection:Disconnect() end
    if InfJumpConnection then InfJumpConnection:Disconnect() end
    if NoclipConnection then NoclipConnection:Disconnect() end
    if CharAddedConnection then CharAddedConnection:Disconnect() end
    
    -- 3. 恢复玩家原生状态
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if hum and originalWalkSpeed then hum.WalkSpeed = originalWalkSpeed end

    -- 4. 恢复所有交互按钮的原始读条时间
    RestorePrompts()
    
    -- 5. 销毁 ESP UI 与内存缓存
    if ESPFolder then ESPFolder:Destroy() end
    table.clear(ESPCache)
    
    -- 6. 垃圾回收器优化 (触发一次静默回收机制)
    collectgarbage("collect")
end)

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

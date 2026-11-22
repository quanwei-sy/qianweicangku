-- 后街生存：独立服务器缝合版
local NothingLibrary = loadstring(game:HttpGetAsync('https://raw.githubusercontent.com/quanwei-sy/qianweicangku/refs/heads/main/%E6%BA%90%E7%A0%81.lua'))()

local __BaseWindow = NothingLibrary.new({
    Title = "TY hub｜后街生存",
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
	Title = '后街生存 - [AI版]',
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

-- ======================== 【地图标签页】 ========================= --
local TeleportGroup = Tabs.Map:AddLeftGroupbox('传送功能')

local TeleportLocations = {
    ["电子产品商店"] = Vector3.new(-267.81, 3.50, 44.28),
    ["商店"] = Vector3.new(-262.03, 15.34, 79.70),
    ["厨房"] = Vector3.new(-170.92, 4.50, 1.52),
    ["餐厅"] = Vector3.new(-113.06, 4.52, -11.31),
    ["皮肤商店"] = Vector3.new(-285.80, 4.57, -20.56),
    ["豆子工厂"] = Vector3.new(-252.37, 5.70, 192.80),
    ["海滩"] = Vector3.new(-226.70, 4.93, -192.85),
    ["豆子商店"] = Vector3.new(-150.35, 4.77, -86.42),
    ["厕所"] = Vector3.new(-89.10, 4.51, -96.27),
    ["银行"] = Vector3.new(-268.39, 4.51, -107.77),
    ["下水道"] = Vector3.new(-243.78, -26.46, -1374.32),
    ["直升机平台"] = Vector3.new(-284.05, 60.50, -19.43),
    ["后巷"] = Vector3.new(-182.89, 22.18, 71.45)
}

local LocationNames = {
    "电子产品商店", "商店", "厨房", "餐厅", "皮肤商店", 
    "豆子工厂", "海滩", "豆子商店", "厕所", "银行", "下水道",
    "直升机平台", "后巷"
}

TeleportGroup:AddDropdown('TeleportSelect', {
    Values = LocationNames,
    Default = 1,
    Multi = false, 
    Text = '选择目标地点',
})

TeleportGroup:AddButton('传送到该地点', function()
    if ScriptStates.IsBusy then Library:Notify("当前有自动化任务运行，请稍后再传送！", 2) return end
    local selectedLocation = Options.TeleportSelect.Value
    local targetPos = TeleportLocations[selectedLocation]
    if targetPos then
        local player = game.Players.LocalPlayer
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            player.Character.HumanoidRootPart.CFrame = CFrame.new(targetPos)
            Library:Notify("传送到: " .. selectedLocation)
        end
    end
end)

local ElectronicGroup = Tabs.Map:AddLeftGroupbox('电子产品')

local RS = game:GetService("ReplicatedStorage")
local StoreConfig = require(RS:WaitForChild("Config"):WaitForChild("ElectronicStore"))
local CareerConfig = require(RS:WaitForChild("Config"):WaitForChild("ElectronicCareer"))
local DataFunc = RS.Events:WaitForChild("DataFunc")
local ElectronicEvent = RS.Events:WaitForChild("ElectronicEvent")

local ElectronicDropdownTranslations = {
    ["TV"] = "电视", ["Flashlight"] = "手电筒", ["Laptop"] = "笔记本电脑", 
    ["Camera"] = "相机", ["Watch"] = "手表",
}

local ItemDisplayNames = {}
local DisplayToKey = {}
local RepairStates = {}

for key, data in pairs(StoreConfig) do
    local transName = ElectronicDropdownTranslations[key] or (data.Name and ElectronicDropdownTranslations[data.Name]) or data.Name or key
    table.insert(ItemDisplayNames, transName)
    DisplayToKey[transName] = key
    RepairStates[key] = { State = "Idle", EndTime = 0, ServerEndTime = 0 }
end
if #ItemDisplayNames == 0 then table.insert(ItemDisplayNames, "暂无数据") end

ScriptStates.Connections.ElectronicEventSync = ElectronicEvent.OnClientEvent:Connect(function(action, itemName, endTime)
    if type(itemName) == "string" then
        local st = RepairStates[itemName]
        if st then
            if action == "Started" and type(endTime) == "number" then
                st.State = "Repairing"
                st.ServerEndTime = endTime
            elseif action == "Completed" then
                st.State = "Ready"
            elseif action == "Collected" then
                st.State = "Idle"
                st.ServerEndTime = 0
            end
        end
    end
end)

local CachedDiscount = 0
local LastDiscountFetch = 0
local function GetCareerDiscount()
    if os.time() - LastDiscountFetch < 3 then return CachedDiscount end
    local success, expData = pcall(function() return DataFunc:InvokeServer() end)
    local currentExp = (success and type(expData) == "table" and expData.ElectronicEXP) or 0
    local currentCareer = CareerConfig[1]
    for _, c in ipairs(CareerConfig) do
        if currentExp >= c.RequiredEXP then currentCareer = c else break end
    end
    CachedDiscount = (currentCareer.Discount * 100)
    LastDiscountFetch = os.time()
    return CachedDiscount
end

local Lbl_Discount = ElectronicGroup:AddLabel('当前折扣: 计算中...')
local Lbl_Countdown = ElectronicGroup:AddLabel('维修状态: 待命')
ElectronicGroup:AddDivider()

ElectronicGroup:AddDropdown('SelectElectronic', {
    Values = ItemDisplayNames,
    Default = 1,
    Multi = false,
    Text = '选择修复物品',
})

ElectronicGroup:AddDivider()
ElectronicGroup:AddLabel('【所需材料持有量】')

local Lbl_Mat1 = ElectronicGroup:AddLabel('• 暂无')
local Lbl_Mat2 = ElectronicGroup:AddLabel(' ')
local Lbl_Mat3 = ElectronicGroup:AddLabel(' ')
local Lbl_Mat4 = ElectronicGroup:AddLabel(' ')
local MaterialLabels = { Lbl_Mat1, Lbl_Mat2, Lbl_Mat3, Lbl_Mat4 }

ElectronicGroup:AddDivider()

local function CountItem(itemName)
    local count = 0
    local player = game.Players.LocalPlayer
    local bp = player:FindFirstChildOfClass("Backpack")
    if bp then
        for _, tool in ipairs(bp:GetChildren()) do
            if tool.Name == itemName then count = count + (tool:GetAttribute("amount") or 1) end
        end
    end
    local char = player.Character
    if char then
        for _, tool in ipairs(char:GetChildren()) do
            if tool:IsA("Tool") and tool.Name == itemName then count = count + (tool:GetAttribute("amount") or 1) end
        end
    end
    return count
end

ScriptStates.Connections.ElectronicUIUpdate = task.spawn(function()
    while task.wait(0.5) do
        Lbl_Discount:SetText('当前折扣: ' .. GetCareerDiscount() .. '%')
        
        if Options.SelectElectronic and Options.SelectElectronic.Value ~= "暂无数据" then
            local key = DisplayToKey[Options.SelectElectronic.Value]
            if key then
                local data = StoreConfig[key]
                if data then
                    local index = 1
                    for reqItem, reqAmount in pairs(data.Require) do
                        if index <= 4 then
                            local cleanName = string.match(reqItem, "_(%w+)$") or reqItem
                            local tName = GlobalTranslations[cleanName] or cleanName
                            local currentCount = CountItem(reqItem)
                            MaterialLabels[index]:SetText(string.format("• %s: 拥有 %d / 需要 %d", tName, currentCount, reqAmount))
                            index = index + 1
                        end
                    end
                    for i = index, 4 do MaterialLabels[i]:SetText(" ") end
                end
                
                local st = RepairStates[key]
                if st and st.State == "Repairing" then
                    local remain = 0
                    if st.ServerEndTime and st.ServerEndTime > 0 then
                        remain = math.max(0, math.ceil(st.ServerEndTime - workspace:GetServerTimeNow()))
                    else
                        remain = math.max(0, math.ceil(st.EndTime - os.time()))
                    end
                    
                    if remain <= 0 then
                        st.State = "Ready"
                        Lbl_Countdown:SetText("维修状态: 修复完毕，等待拾取")
                    else
                        Lbl_Countdown:SetText("维修状态: 修复中... 剩余 " .. remain .. " 秒")
                    end
                elseif st and st.State == "Ready" then
                    Lbl_Countdown:SetText("维修状态: 修复完毕，等待拾取")
                else
                    Lbl_Countdown:SetText("维修状态: 待命")
                end
            else
                for i = 1, 4 do MaterialLabels[i]:SetText(" ") end
            end
        end
    end
end)

local function ForceUnequip()
    local char = game.Players.LocalPlayer.Character
    if char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then hum:UnequipTools() end
    end
end

ElectronicGroup:AddToggle('AutoRepairElectronic', {
    Text = '自动物品修复',
    Default = false,
    Callback = function(Value)
        if Value then
            ScriptStates.Connections.AutoElectronic = task.spawn(function()
                while task.wait(1) do
                    if not Toggles.AutoRepairElectronic.Value then break end
                    
                    local key = DisplayToKey[Options.SelectElectronic.Value]
                    if not key then continue end
                    
                    local st = RepairStates[key]
                    local data = StoreConfig[key]
                    if not data then continue end
                    
                    if st.State == "Idle" then
                        local hasMats = true
                        for reqItem, reqAmount in pairs(data.Require) do
                            if CountItem(reqItem) < reqAmount then
                                hasMats = false
                                break
                            end
                        end
                        
                        if hasMats then
                            if ScriptStates.IsBusy then continue end
                            ScriptStates.IsBusy = "AutoElectronic"
                            
                            local player = game.Players.LocalPlayer
                            local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
                            if not root then ScriptStates.IsBusy = false continue end
                            
                            local savedPos = root.CFrame
                            root.CFrame = CFrame.new(-267.81, 3.50, 44.28)
                            task.wait(0.5)
                            ForceUnequip()
                            
                            ElectronicEvent:FireServer(key)
                            
                            st.State = "Repairing"
                            st.EndTime = os.time() + (tonumber(data.Seconds) or 0)
                            
                            if root then root.CFrame = savedPos end
                            ScriptStates.IsBusy = false
                        else
                            task.wait(2)
                        end
                        
                    elseif st.State == "Repairing" then
                        local checkTime = 0
                        if st.ServerEndTime and st.ServerEndTime > 0 then
                            checkTime = st.ServerEndTime
                        else
                            checkTime = st.EndTime
                        end
                        
                        if checkTime > 0 and workspace:GetServerTimeNow() >= checkTime then
                            st.State = "Ready"
                        end
                        
                    elseif st.State == "Ready" then
                        if ScriptStates.IsBusy then continue end
                        ScriptStates.IsBusy = "AutoElectronic"
                        
                        local player = game.Players.LocalPlayer
                        local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
                        if not root then ScriptStates.IsBusy = false continue end
                        
                        local savedPos = root.CFrame
                        root.CFrame = CFrame.new(-267.81, 3.50, 44.28)
                        task.wait(0.5)
                        
                        pcall(function()
                            local ProxPath = workspace:WaitForChild("Map", 2)
                                :WaitForChild("ScriptObjects", 2)
                                :WaitForChild("ElectronicNPC", 2)
                                :WaitForChild("HumanoidRootPart", 2)
                                :WaitForChild("ElectronicProx", 2)
                                
                            if ProxPath and ProxPath:IsA("ProximityPrompt") then
                                fireproximityprompt(ProxPath)
                            end
                        end)
                        task.wait(0.5)
                        
                        ElectronicEvent:FireServer(key)
                        st.State = "Idle"
                        st.EndTime = 0
                        st.ServerEndTime = 0
                        
                        if root then root.CFrame = savedPos end
                        ScriptStates.IsBusy = false
                    end
                end
            end)
        else
            if ScriptStates.IsBusy == "AutoElectronic" then ScriptStates.IsBusy = false end
            if ScriptStates.Connections.AutoElectronic then
                task.cancel(ScriptStates.Connections.AutoElectronic)
                ScriptStates.Connections.AutoElectronic = nil
            end
        end
    end
})

local RestaurantGroup = Tabs.Map:AddLeftGroupbox('餐厅功能')

local RestaurantFoodMap = {
    ["牛角包"] = { Image = "rbxassetid://116758072749400", ItemName = "Food_\208\161roissant" },
    ["三明治"] = { Image = "rbxassetid://116477199047065", ItemName = "Food_Sandwich" },
    ["意大利面"] = { Image = "rbxassetid://73369274377716", ItemName = "Food_Spaghetti" },
    ["沙拉"] = { Image = "rbxassetid://125430530326241", ItemName = "Food_Salad" },
    ["蛋糕"] = { Image = "rbxassetid://95206715300206", ItemName = "Food_Cake" },
    ["熟螃蟹"] = { Image = "rbxassetid://72646862320640", ItemName = "Food_Crab" },
    ["熟金枪鱼"] = { Image = "rbxassetid://96696496263773", ItemName = "Food_Tuna" },
    ["熟章鱼"] = { Image = "rbxassetid://86003327449046", ItemName = "Food_Octopus" }
}

local RestaurantDropdownList = {"牛角包", "三明治", "意大利面", "沙拉", "蛋糕", "熟螃蟹", "熟金枪鱼", "熟章鱼"}

RestaurantGroup:AddDropdown('SelectRestaurantFood', {
    Values = RestaurantDropdownList,
    Default = 1,
    Multi = false,
    Text = '选择配送食物',
})

local Lbl_RestaurantFoodCount = RestaurantGroup:AddLabel('当前持有数量: 检测中...')
local Lbl_RestaurantNPCCount = RestaurantGroup:AddLabel('当前食客数量: 检测中...')
RestaurantGroup:AddDivider()

ScriptStates.Connections.RestaurantUIUpdate = task.spawn(function()
    while task.wait(0.5) do
        if Options.SelectRestaurantFood then
            local selectedName = Options.SelectRestaurantFood.Value
            local foodData = RestaurantFoodMap[selectedName]
            if foodData then
                local currentCount = CountItem(foodData.ItemName)
                Lbl_RestaurantFoodCount:SetText('当前持有数量: ' .. tostring(currentCount))
                
                local npcCount = 0
                local mapNPCs = workspace:FindFirstChild("Map") and workspace.Map:FindFirstChild("NPC")
                if mapNPCs then
                    for _, npc in ipairs(mapNPCs:GetChildren()) do
                        local hrp = npc:FindFirstChild("HumanoidRootPart")
                        if hrp then
                            local bgui = hrp:FindFirstChildOfClass("BillboardGui")
                            if bgui then
                                local imgLabel = bgui:FindFirstChildOfClass("ImageLabel")
                                if imgLabel and imgLabel.Image == foodData.Image then
                                    npcCount = npcCount + 1
                                end
                            end
                        end
                    end
                end
                Lbl_RestaurantNPCCount:SetText('当前食客数量: ' .. tostring(npcCount))
            else
                Lbl_RestaurantFoodCount:SetText('当前持有数量: 0')
                Lbl_RestaurantNPCCount:SetText('当前食客数量: 0')
            end
        end
    end
end)

RestaurantGroup:AddToggle('AutoDeliverFood', {
    Text = '自动配送',
    Default = false,
    Callback = function(Value)
        if Value then
            ScriptStates.Connections.AutoDeliverFood = task.spawn(function()
                local player = game.Players.LocalPlayer
                local isDeliveringSpree = false
                local savedPos = nil
                
                while task.wait(0.5) do
                    if not Toggles.AutoDeliverFood.Value then break end
                    
                    local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
                    if not root then continue end
                    
                    local selectedName = Options.SelectRestaurantFood.Value
                    local foodData = RestaurantFoodMap[selectedName]
                    if not foodData then continue end
                    
                    local currentCount = CountItem(foodData.ItemName)
                    local targetNPC = nil
                    
                    if currentCount > 0 then
                        local mapNPCs = workspace:FindFirstChild("Map") and workspace.Map:FindFirstChild("NPC")
                        if mapNPCs then
                            for _, npc in ipairs(mapNPCs:GetChildren()) do
                                local hrp = npc:FindFirstChild("HumanoidRootPart")
                                if hrp then
                                    local bgui = hrp:FindFirstChildOfClass("BillboardGui")
                                    if bgui then
                                        local imgLabel = bgui:FindFirstChildOfClass("ImageLabel")
                                        if imgLabel and imgLabel.Image == foodData.Image then
                                            targetNPC = npc
                                            break
                                        end
                                    end
                                end
                            end
                        end
                    end
                        
                    if targetNPC then
                        if not isDeliveringSpree then
                            if ScriptStates.IsBusy then task.wait(1) continue end
                            ScriptStates.IsBusy = "AutoDeliverFood"
                            isDeliveringSpree = true
                            savedPos = root.CFrame
                        end
                        
                        local targetHRP = targetNPC:FindFirstChild("HumanoidRootPart")
                        if targetHRP then
                            root.CFrame = targetHRP.CFrame * CFrame.new(0, 0, 3)
                            task.wait(0.5)
                            
                            local prox = targetHRP:FindFirstChild("FoodProx")
                            if prox and prox:IsA("ProximityPrompt") then
                                fireproximityprompt(prox)
                            end
                            task.wait(0.5)
                        end
                    else
                        if isDeliveringSpree then
                            if root and savedPos then root.CFrame = savedPos end
                            isDeliveringSpree = false
                            if ScriptStates.IsBusy == "AutoDeliverFood" then ScriptStates.IsBusy = false end
                            savedPos = nil
                        end
                        task.wait(1)
                    end
                end
                
                if isDeliveringSpree then
                    local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
                    if root and savedPos then root.CFrame = savedPos end
                    if ScriptStates.IsBusy == "AutoDeliverFood" then ScriptStates.IsBusy = false end
                end
            end)
        else
            if ScriptStates.IsBusy == "AutoDeliverFood" then ScriptStates.IsBusy = false end
            if ScriptStates.Connections.AutoDeliverFood then
                task.cancel(ScriptStates.Connections.AutoDeliverFood)
                ScriptStates.Connections.AutoDeliverFood = nil
            end
        end
    end
})

local BankGroup = Tabs.Map:AddRightGroupbox('银行功能')

local CS = game:GetService("CollectionService")
local BankFunc = RS:WaitForChild("Events"):WaitForChild("BankFunc")

local Lbl_Deposit = BankGroup:AddLabel('当前存款: 待刷新...')
local Lbl_Cash = BankGroup:AddLabel('当前现金: 待刷新...')
local Lbl_Expected = BankGroup:AddLabel('预计收益: 待刷新...')
local Lbl_Offline = BankGroup:AddLabel('离线收益: 待刷新...')

local function UpdateBankData()
    local success, data = pcall(function()
        return BankFunc:InvokeServer("GetData", 0, false)
    end)
    
    if success and type(data) == "table" then
        Lbl_Deposit:SetText('当前存款: $' .. tostring(data.Deposit or 0))
        Lbl_Cash:SetText('当前现金: $' .. tostring(data.Cash or 0))
        Lbl_Offline:SetText('离线收益: $' .. tostring(data.Offline or 0))
        
        local rate = 0
        local maxPerDay = 100
        local proxList = CS:GetTagged("BankProx")
        if proxList and #proxList > 0 then
            rate = proxList[1]:GetAttribute("Rate") or 0
            maxPerDay = proxList[1]:GetAttribute("MaxPerDay") or 100
        end
        
        local income = math.min((data.Deposit or 0) * rate, maxPerDay)
        Lbl_Expected:SetText('预计收益: $' .. tostring(math.floor(income)))
    else
        Lbl_Deposit:SetText('当前存款: 获取失败或无卡')
        Lbl_Cash:SetText('当前现金: --')
        Lbl_Expected:SetText('预计收益: --')
        Lbl_Offline:SetText('离线收益: --')
    end
end

BankGroup:AddToggle('EnableBankSync', {
    Text = '刷新资产',
    Default = false,
    Callback = function(Value)
        if Value then
            UpdateBankData()
            
            ScriptStates.Connections.BankSync = task.spawn(function()
                while true do
                    task.wait(3)
                    if not Toggles.EnableBankSync.Value then break end
                    UpdateBankData()
                end
            end)
        else
            if ScriptStates.Connections.BankSync then
                task.cancel(ScriptStates.Connections.BankSync)
                ScriptStates.Connections.BankSync = nil
            end
            Lbl_Deposit:SetText('当前存款: 已停止刷新')
            Lbl_Cash:SetText('当前现金: 已停止刷新')
            Lbl_Expected:SetText('预计收益: 已停止刷新')
            Lbl_Offline:SetText('离线收益: 已停止刷新')
        end
    end
})

BankGroup:AddDivider()

BankGroup:AddInput('BankAmount', {
    Default = '0',
    Numeric = true,
    Finished = false,
    Text = '操作金额',
    Tooltip = '输入你要存入或取出的金额',
    Placeholder = '输入纯数字'
})

local function DoBankAction(action)
    if ScriptStates.IsBusy then Library:Notify("系统繁忙，请稍后再试！", 2) return end

    local amount = tonumber(Options.BankAmount.Value)
    if not amount or amount <= 0 then
        Library:Notify("请输入有效的操作金额！")
        return
    end

    local player = game.Players.LocalPlayer
    local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if not root then return end

    local data = BankFunc:InvokeServer("GetData", 0, false)
    if type(data) ~= "table" then return end

    local actualAmount = amount
    if action == "Deposit" then
        if (data.Cash or 0) < actualAmount then actualAmount = data.Cash or 0 end
    elseif action == "Withdraw" then
        if (data.Deposit or 0) < actualAmount then actualAmount = data.Deposit or 0 end
    end

    if actualAmount <= 0 then return end

    ScriptStates.IsBusy = "BankAction"
    local savedCFrame = root.CFrame
    local bankCFrame = CFrame.new(-264.31, 4.51, -108.26)
    
    root.CFrame = bankCFrame
    task.wait(0.25)
    
    local success, result = pcall(function() return BankFunc:InvokeServer(action, actualAmount, false) end)
    
    if root then root.CFrame = savedCFrame end
    if ScriptStates.IsBusy == "BankAction" then ScriptStates.IsBusy = false end

    if success and result then
        Library:Notify("操作成功: $" .. tostring(actualAmount))
        if Toggles.EnableBankSync.Value then UpdateBankData() end
    end
end

BankGroup:AddButton('存入资金', function() DoBankAction("Deposit") end)
BankGroup:AddButton('取出资金', function() DoBankAction("Withdraw") end)

local MicrowaveGroup = Tabs.Map:AddRightGroupbox('微波炉功能')

local FoodConfig = require(RS:WaitForChild("Config"):WaitForChild("Food"))
local MicrowaveFunc = RS:WaitForChild("Events"):WaitForChild("MicrowaveFunc")

local FoodDisplayNames = {}
local FoodToId = {}
for i, data in ipairs(FoodConfig) do
    local cleanName = data.RewardName
    local tName = GlobalTranslations[cleanName] or cleanName
    local display = string.format("%s - $%s", tName, tostring(data.Price))
    table.insert(FoodDisplayNames, display)
    FoodToId[display] = i
end

if #FoodDisplayNames == 0 then table.insert(FoodDisplayNames, "暂无数据") end

local Lbl_MicroState = MicrowaveGroup:AddLabel('微波炉状态: 检测中...')
MicrowaveGroup:AddDivider()

MicrowaveGroup:AddDropdown('SelectMicrowave', {
    Values = FoodDisplayNames,
    Default = 1,
    Multi = false,
    Text = '选择烹饪食谱',
})

MicrowaveGroup:AddDivider()
MicrowaveGroup:AddLabel('【所需材料持有量】')

local Lbl_MicroMat1 = MicrowaveGroup:AddLabel('• 暂无')
local Lbl_MicroMat2 = MicrowaveGroup:AddLabel(' ')
local Lbl_MicroMat3 = MicrowaveGroup:AddLabel(' ')
local MicroMatLabels = { Lbl_MicroMat1, Lbl_MicroMat2, Lbl_MicroMat3 }

local CurrentSelectedFood = 0

MicrowaveGroup:AddButton('确认食谱', function()
    local selectedId = FoodToId[Options.SelectMicrowave.Value]
    if not selectedId then return end
    
    if CurrentSelectedFood == selectedId then return end
    
    local success = pcall(function() MicrowaveFunc:InvokeServer("Select", selectedId) end)
    if success then
        CurrentSelectedFood = selectedId
        Library:Notify("已确认食谱: " .. Options.SelectMicrowave.Value)
    end
end)

MicrowaveGroup:AddDivider()

local function GetMyMicrowave()
    local mws = workspace:FindFirstChild("Map") 
        and workspace.Map:FindFirstChild("ScriptObjects") 
        and workspace.Map.ScriptObjects:FindFirstChild("Microwaves")
    if not mws then return nil end
    local myId = game.Players.LocalPlayer.UserId
    for _, mw in ipairs(mws:GetChildren()) do
        if mw:GetAttribute("Owner") == myId then return mw end
    end
    return nil
end

local function CountItem_MW(itemName)
    local count = 0
    local player = game.Players.LocalPlayer
    local bp = player:FindFirstChildOfClass("Backpack")
    if bp then
        for _, tool in ipairs(bp:GetChildren()) do
            if tool.Name == itemName then count = count + (tool:GetAttribute("amount") or 1) end
        end
    end
    local char = player.Character
    if char then
        for _, tool in ipairs(char:GetChildren()) do
            if tool:IsA("Tool") and tool.Name == itemName then count = count + (tool:GetAttribute("amount") or 1) end
        end
    end
    return count
end

ScriptStates.Connections.MicrowaveUIUpdate = task.spawn(function()
    while task.wait(0.5) do
        local myMW = GetMyMicrowave()
        if myMW then
            local timer = myMW:GetAttribute("timer") or 0
            if timer > 0 then
                Lbl_MicroState:SetText(string.format("微波炉状态: 烹饪中... 剩余 %d 秒", timer))
            else
                Lbl_MicroState:SetText("微波炉状态: 空闲 / 可拾取")
            end
        else
            Lbl_MicroState:SetText("微波炉状态: 未放置微波炉")
        end
        
        if Options.SelectMicrowave and Options.SelectMicrowave.Value ~= "暂无数据" then
            local selectedId = FoodToId[Options.SelectMicrowave.Value]
            if selectedId then
                local data = FoodConfig[selectedId]
                if data and data.Ingredients then
                    local index = 1
                    for reqItem, reqAmount in pairs(data.Ingredients) do
                        if index <= 3 then
                            local cleanName = string.match(reqItem, "_(%w+)$") or reqItem
                            local tName = GlobalTranslations[cleanName] or cleanName
                            local currentCount = CountItem_MW(reqItem)
                            MicroMatLabels[index]:SetText(string.format("• %s: 拥有 %d / 需要 %d", tName, currentCount, reqAmount))
                            index = index + 1
                        end
                    end
                    for i = index, 3 do MicroMatLabels[i]:SetText(" ") end
                end
            else
                for i = 1, 3 do MicroMatLabels[i]:SetText(" ") end
            end
        end
    end
end)

local function CheckMaterials_MW(reqs)
    for reqItem, reqAmount in pairs(reqs) do
        if CountItem_MW(reqItem) < reqAmount then return false end
    end
    return true
end

MicrowaveGroup:AddToggle('AutoMicrowave', {
    Text = '自动烹饪',
    Default = false,
    Callback = function(Value)
        if Value then
            ScriptStates.Connections.AutoMicrowave = task.spawn(function()
                local originalCFrame = nil
                
                while task.wait(1) do
                    if not Toggles.AutoMicrowave.Value then break end
                    
                    local myMW = GetMyMicrowave()
                    if not myMW then continue end
                    
                    if not Options.SelectMicrowave or Options.SelectMicrowave.Value == "暂无数据" then continue end
                    local selectedId = FoodToId[Options.SelectMicrowave.Value]
                    if not selectedId then continue end
                    local data = FoodConfig[selectedId]
                    if not data then continue end

                    local timer = myMW:GetAttribute("timer") or 0
                    
                    if timer <= 0 then
                        if CurrentSelectedFood ~= selectedId then
                            pcall(function() MicrowaveFunc:InvokeServer("Select", selectedId) end)
                            CurrentSelectedFood = selectedId
                            task.wait(0.5)
                        end

                        if CheckMaterials_MW(data.Ingredients) then
                            pcall(function() MicrowaveFunc:InvokeServer("Start") end)
                            task.wait(1)
                        end
                        
                    else
                        while timer > 0 and Toggles.AutoMicrowave.Value do
                            timer = myMW:GetAttribute("timer") or 0
                            task.wait(0.5)
                        end
                        
                        if not Toggles.AutoMicrowave.Value then break end
                        
                        Lbl_MicroState:SetText("微波炉状态: 生成食物中...")
                        task.wait(1)
                        
                        local player = game.Players.LocalPlayer
                        local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
                        local handle = myMW:FindFirstChild("Handle")
                        
                        if root and handle then
                            if ScriptStates.IsBusy then task.wait(1) continue end
                            ScriptStates.IsBusy = "AutoMicrowave"
                            
                            local originalCFrame = root.CFrame
                            root.CFrame = handle.CFrame * CFrame.new(0, 0, 3)
                            task.wait(0.5)
                            
                            pcall(function()
                                if handle:FindFirstChild("MicrowaveProx") then
                                    fireproximityprompt(handle.MicrowaveProx)
                                end
                            end)
                            
                            task.wait(0.5)
                            if root then root.CFrame = originalCFrame end
                            if ScriptStates.IsBusy == "AutoMicrowave" then ScriptStates.IsBusy = false end
                            task.wait(1) 
                        end
                    end
                end
            end)
        else
            if ScriptStates.IsBusy == "AutoMicrowave" then ScriptStates.IsBusy = false end
            if ScriptStates.Connections.AutoMicrowave then
                task.cancel(ScriptStates.Connections.AutoMicrowave)
                ScriptStates.Connections.AutoMicrowave = nil
            end
        end
    end
})

MicrowaveGroup:AddButton('停止烹饪', function()
    if Toggles.AutoMicrowave.Value then Toggles.AutoMicrowave:SetValue(false) end
    pcall(function() MicrowaveFunc:InvokeServer("Stop") end)
end)

local ElectronicSalesGroup = Tabs.Map:AddRightGroupbox('电子销售')

ElectronicSalesGroup:AddDropdown('SelectElectronicSales', {
    Values = ItemDisplayNames,
    Multi = true,
    Text = '选择销售物品 (多选)',
})

ElectronicSalesGroup:AddToggle('AutoElectronicSales', {
    Text = '自动销售',
    Default = false,
    Callback = function(Value)
        local player = game.Players.LocalPlayer
        if Value then
            ScriptStates.Connections.AutoElectronicSales = task.spawn(function()
                local interactedNPCs = {}
                local isSellingSpree = false
                local savedPos = nil
                
                while task.wait(0.5) do
                    if not Toggles.AutoElectronicSales.Value then break end
                    local currentChar = player.Character
                    local currentRoot = currentChar and currentChar:FindFirstChild("HumanoidRootPart")
                    local currentHum = currentChar and currentChar:FindFirstChildOfClass("Humanoid")
                    if not currentRoot or not currentHum then continue end
                    
                    local availableItems = {}
                    local selectedOptions = Options.SelectElectronicSales.Value
                    if type(selectedOptions) == "table" then
                        for displayName, isSelected in pairs(selectedOptions) do
                            if isSelected then
                                local key = DisplayToKey[displayName]
                                if key and CountItem(key) > 0 then table.insert(availableItems, key) end
                            end
                        end
                    end
                    if #availableItems == 0 then
                        if isSellingSpree then
                            if currentRoot and savedPos then currentRoot.CFrame = savedPos end
                            isSellingSpree = false
                            if ScriptStates.IsBusy == "AutoElectronicSales" then ScriptStates.IsBusy = false end
                            savedPos = nil
                        end
                        task.wait(1)
                        continue 
                    end
                    
                    local mapNPCs = workspace:FindFirstChild("Map") and workspace.Map:FindFirstChild("NPC")
                    if mapNPCs then
                        for npc, timestamp in pairs(interactedNPCs) do
                            if not npc or not npc.Parent or npc.Parent ~= mapNPCs then interactedNPCs[npc] = nil
                            elseif os.time() - timestamp > 45 then interactedNPCs[npc] = nil end
                        end
                    end
                    
                    local validNPCs = {}
                    local badNames = {"Guard", "Shark", "Van"}
                    if mapNPCs then
                        for _, npc in ipairs(mapNPCs:GetChildren()) do
                            local isBad = false
                            for _, bad in ipairs(badNames) do
                                if string.find(npc.Name, bad) then isBad = true break end
                            end
                            if isBad then continue end
                            if interactedNPCs[npc] then continue end
                            
                            local npcHum = npc:FindFirstChildOfClass("Humanoid")
                            local npcHRP = npc:FindFirstChild("HumanoidRootPart")
                            if npcHum and npcHRP and npcHum.WalkSpeed <= 16.5 and npcHRP.Position.Y > -50 then
                                local hasImage = false
                                local bgui = npcHRP:FindFirstChildOfClass("BillboardGui")
                                if bgui then
                                    local imgLabel = bgui:FindFirstChildOfClass("ImageLabel")
                                    if imgLabel and imgLabel.Image and imgLabel.Image ~= "" then hasImage = true end
                                end
                                if not hasImage then
                                    local prox = npcHRP:FindFirstChildOfClass("ProximityPrompt")
                                    if not prox then prox = npc:FindFirstChildOfClass("ProximityPrompt", true) end
                                    if prox and prox.Enabled then table.insert(validNPCs, {npc = npc, prox = prox}) end
                                end
                            end
                        end
                    end
                    
                    if #validNPCs > 0 and #availableItems > 0 then
                        if not isSellingSpree then
                            if ScriptStates.IsBusy then task.wait(1) continue end
                            ScriptStates.IsBusy = "AutoElectronicSales"
                            isSellingSpree = true
                            savedPos = currentRoot.CFrame
                        end
                        
                        local targetData = validNPCs[math.random(1, #validNPCs)]
                        local itemToSell = availableItems[math.random(1, #availableItems)]
                        local bp = player:FindFirstChildOfClass("Backpack")
                        local itemTool = nil
                        if bp then itemTool = bp:FindFirstChild(itemToSell) end
                        if not itemTool then itemTool = currentChar:FindFirstChild(itemToSell) end
                        
                        if itemTool then
                            currentHum:EquipTool(itemTool)
                            task.wait(0.2)
                            
                            local targetHRP = targetData.npc:FindFirstChild("HumanoidRootPart")
                            if targetHRP then
                                currentRoot.CFrame = targetHRP.CFrame * CFrame.new(0, 0, 3)
                                task.wait(0.3)
                                fireproximityprompt(targetData.prox)
                                interactedNPCs[targetData.npc] = os.time()
                                
                                local followTime = 2 
                                local elapsed = 0
                                local checkInterval = 0.1 
                                while elapsed < followTime do
                                    if not Toggles.AutoElectronicSales.Value then break end
                                    if not targetData.npc or not targetData.npc.Parent then break end
                                    local checkHRP = targetData.npc:FindFirstChild("HumanoidRootPart")
                                    if checkHRP and currentRoot then
                                        local distance = (currentRoot.Position - checkHRP.Position).Magnitude
                                        if distance > 5 then currentRoot.CFrame = checkHRP.CFrame * CFrame.new(0, 0, 3) end
                                    else break end
                                    task.wait(checkInterval)
                                    elapsed = elapsed + checkInterval
                                end
                            end
                            if currentRoot then currentRoot.CFrame = savedPos end
                        end
                        
                        if ScriptStates.IsBusy == "AutoElectronicSales" then ScriptStates.IsBusy = false end
                    else 
                        task.wait(1) 
                    end
                end
                
                if isSellingSpree then
                    local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
                    if root and savedPos then root.CFrame = savedPos end
                    if ScriptStates.IsBusy == "AutoElectronicSales" then ScriptStates.IsBusy = false end
                end
            end)
        else
            if ScriptStates.IsBusy == "AutoElectronicSales" then ScriptStates.IsBusy = false end
            if ScriptStates.Connections.AutoElectronicSales then
                task.cancel(ScriptStates.Connections.AutoElectronicSales)
                ScriptStates.Connections.AutoElectronicSales = nil
            end
        end
    end
})

-- ================================================================= --
-- ======================== 【功能标签页】 ========================= --
-- ================================================================= --

local PlayerFuncGroup = Tabs.Func:AddLeftGroupbox('玩家功能')

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
    ScriptStates.OriginalWalkSpeed = LocalPlayer.Character.Humanoid.WalkSpeed
end

PlayerFuncGroup:AddToggle('EnableWalkSpeed', {
    Text = '启用移速',
    Default = false,
    Tooltip = '锁定为下方滑块设置的移速',
    Callback = function(Value)
        if Value then
            ScriptStates.Connections.WalkSpeed = RunService.RenderStepped:Connect(function()
                if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                    LocalPlayer.Character.Humanoid.WalkSpeed = Options.WalkSpeedSlider.Value
                end
            end)
        else
            if ScriptStates.Connections.WalkSpeed then
                ScriptStates.Connections.WalkSpeed:Disconnect()
                ScriptStates.Connections.WalkSpeed = nil
            end
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                LocalPlayer.Character.Humanoid.WalkSpeed = ScriptStates.OriginalWalkSpeed
            end
        end
    end
})

PlayerFuncGroup:AddSlider('WalkSpeedSlider', {
    Text = '设置移速', Default = ScriptStates.OriginalWalkSpeed, Min = 10, Max = 66, Rounding = 0, Compact = false,
})

PlayerFuncGroup:AddToggle('EnableNoclip', {
    Text = '穿墙',
    Default = false,
    Callback = function(Value)
        if Value then
            ScriptStates.Connections.Noclip = RunService.Stepped:Connect(function()
                if LocalPlayer.Character then
                    for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
                        if part:IsA("BasePart") and part.CanCollide then part.CanCollide = false end
                    end
                end
            end)
        else
            if ScriptStates.Connections.Noclip then
                ScriptStates.Connections.Noclip:Disconnect()
                ScriptStates.Connections.Noclip = nil
            end
        end
    end
})

PlayerFuncGroup:AddToggle('EnableInfJump', {
    Text = '无限跳跃',
    Default = false,
    Callback = function(Value)
        if Value then
            ScriptStates.Connections.InfJump = UserInputService.JumpRequest:Connect(function()
                if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                    LocalPlayer.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                end
            end)
        else
            if ScriptStates.Connections.InfJump then
                ScriptStates.Connections.InfJump:Disconnect()
                ScriptStates.Connections.InfJump = nil
            end
        end
    end
})

local BeanFactoryGroup = Tabs.Func:AddLeftGroupbox('豆子工厂')

local BeanItemName = "Trash_TinCan" 

local Lbl_BeanCount = BeanFactoryGroup:AddLabel('豆罐持有数量: 检测中...')
local Lbl_Van1 = BeanFactoryGroup:AddLabel('豆车1信息: 检测中...')
local Lbl_Van2 = BeanFactoryGroup:AddLabel('豆车2信息: 检测中...')
BeanFactoryGroup:AddDivider()

ScriptStates.Connections.BeanFactoryUpdate = task.spawn(function()
    while task.wait(0.5) do
        Lbl_BeanCount:SetText('豆罐数量: ' .. tostring(CountItem(BeanItemName)))
        
        local mapNPCs = workspace:FindFirstChild("Map") and workspace.Map:FindFirstChild("NPC")
        local van1 = mapNPCs and mapNPCs:FindFirstChild("Van1")
        if van1 then
            local text = "获取失败"
            pcall(function() text = van1.HumanoidRootPart.Attachment.BillboardGui.newTool.toolAmount.Text end)
            Lbl_Van1:SetText('豆车1信息: ' .. text)
        else Lbl_Van1:SetText('豆车1信息: 离线状态') end
        
        local van2 = mapNPCs and mapNPCs:FindFirstChild("Van2")
        if van2 then
            local text = "获取失败"
            pcall(function() text = van2.HumanoidRootPart.Attachment.BillboardGui.newTool.toolAmount.Text end)
            Lbl_Van2:SetText('豆车2信息: ' .. text)
        else Lbl_Van2:SetText('豆车2信息: 离线状态') end
    end
end)

BeanFactoryGroup:AddToggle('AutoLoadBeans', {
    Text = '自动打包与装车',
    Default = false,
    Callback = function(Value)
        if Value then
            ScriptStates.Connections.AutoLoadBeans = task.spawn(function()
                local currentTarget = nil
                local function getVanAmount(van)
                    if not van then return 5 end 
                    local amount = 5
                    pcall(function()
                        local txt = van.HumanoidRootPart.Attachment.BillboardGui.newTool.toolAmount.Text
                        local num = string.match(txt, "%d+")
                        if num then amount = tonumber(num) end
                    end)
                    return amount
                end

                while task.wait(0.4) do
                    if not Toggles.AutoLoadBeans.Value then break end
                    local player = game.Players.LocalPlayer
                    local char = player.Character
                    local hum = char and char:FindFirstChildOfClass("Humanoid")
                    if not char or not hum then continue end
                    
                    local mapNPCs = workspace:FindFirstChild("Map") and workspace.Map:FindFirstChild("NPC")
                    if not mapNPCs then continue end
                    
                    local van1 = mapNPCs:FindFirstChild("Van1")
                    local van2 = mapNPCs:FindFirstChild("Van2")
                    local v1Amt = getVanAmount(van1)
                    local v2Amt = getVanAmount(van2)
                    
                    if currentTarget == "Van1" and (not van1 or v1Amt >= 5) then currentTarget = nil end
                    if currentTarget == "Van2" and (not van2 or v2Amt >= 5) then currentTarget = nil end
                    
                    if not currentTarget then
                        if van1 and v1Amt < 5 then currentTarget = "Van1"
                        elseif van2 and v2Amt < 5 then currentTarget = "Van2" end
                    end
                    
                    local beanCount = CountItem(BeanItemName)
                    local holdingBox = char:FindFirstChild("Factory_Box")
                    local hasBoxInBP = player.Backpack:FindFirstChild("Factory_Box")
                    local haveBox = holdingBox or hasBoxInBP
                    
                    if not currentTarget then
                        task.wait(0.7) 
                        continue
                    end
                    
                    local targetVan = (currentTarget == "Van1") and van1 or van2
                    
                    if haveBox then
                        if not holdingBox and hasBoxInBP then
                            hum:EquipTool(hasBoxInBP)
                            task.wait(0.1) 
                        end
                        pcall(function()
                            local prox = targetVan.HumanoidRootPart.Attachment:FindFirstChild("FactoryPrompt")
                            if prox then
                                prox.MaxActivationDistance = 10
                                fireproximityprompt(prox)
                            end
                        end)
                        task.wait(0.2) 
                    else
                        if beanCount >= 5 then
                            pcall(function() game:GetService("ReplicatedStorage").Events:WaitForChild("FactoryCraftEvent"):FireServer() end)
                            task.wait(0.2) 
                        else task.wait(0.5) end
                    end
                end
            end)
        else
            if ScriptStates.Connections.AutoLoadBeans then
                task.cancel(ScriptStates.Connections.AutoLoadBeans)
                ScriptStates.Connections.AutoLoadBeans = nil
            end
        end
    end
})

BeanFactoryGroup:AddToggle('AutoTransportRepair', {
    Text = '自动制作与维修',
    Default = false,
    Callback = function(Value)
        local RS = game:GetService("ReplicatedStorage")
        if Value then
            ScriptStates.RepairConsole1 = false
            ScriptStates.RepairConsole2 = false
            
            local function checkNotification(action, data)
                if not Toggles.AutoTransportRepair.Value then return end
                local text = ""
                if type(data) == "string" then text = data
                elseif type(data) == "table" then text = data.message or data.Message or data.text or data.Text or "" end
                text = tostring(text)
                
                local lowerText = string.lower(text)
                if string.find(lowerText, "conveyor #1") or string.find(lowerText, "console1") then 
                    ScriptStates.RepairConsole1 = true
                elseif string.find(lowerText, "conveyor #2") or string.find(lowerText, "console2") then 
                    ScriptStates.RepairConsole2 = true 
                end
            end
            
            local NotifEvent = RS.Events:WaitForChild("NotificationEvent")
            local ClientNotifEvent = RS.LocalEvents:WaitForChild("ClientNotificationEvent")
            ScriptStates.Connections.NotifHook1 = NotifEvent.OnClientEvent:Connect(checkNotification)
            ScriptStates.Connections.NotifHook2 = ClientNotifEvent.Event:Connect(checkNotification)
            
            ScriptStates.Connections.AutoTransportRepair = task.spawn(function()
                local player = game.Players.LocalPlayer
                while task.wait(0.5) do
                    if not Toggles.AutoTransportRepair.Value then break end
                    local char = player.Character
                    local root = char and char:FindFirstChild("HumanoidRootPart")
                    if not root then continue end
                    
                    local factoryFolder = workspace:FindFirstChild("Map") 
                        and workspace.Map:FindFirstChild("ScriptObjects") 
                        and workspace.Map.ScriptObjects:FindFirstChild("Factory")
                    if not factoryFolder then continue end
                    
                    if ScriptStates.RepairConsole1 or ScriptStates.RepairConsole2 then
                        if ScriptStates.RepairConsole1 then
                            local prox = factoryFolder:FindFirstChild("FactoryConveyor")
                                and factoryFolder.FactoryConveyor:FindFirstChild("Console")
                                and factoryFolder.FactoryConveyor.Console:FindFirstChild("Console1")
                                and factoryFolder.FactoryConveyor.Console.Console1:FindFirstChild("RepairPrompt")
                            if prox then
                                root.CFrame = CFrame.new(-293.80, 3.50, 236.27)
                                task.wait(0.5)
                                fireproximityprompt(prox)
                                task.wait(5) 
                            end
                            ScriptStates.RepairConsole1 = false 
                        elseif ScriptStates.RepairConsole2 then
                            local prox = factoryFolder:FindFirstChild("FactoryConveyor")
                                and factoryFolder.FactoryConveyor:FindFirstChild("Console")
                                and factoryFolder.FactoryConveyor.Console:FindFirstChild("Console2")
                                and factoryFolder.FactoryConveyor.Console.Console2:FindFirstChild("RepairPrompt")
                            if prox then
                                root.CFrame = CFrame.new(-303.42, 3.50, 233.33)
                                task.wait(0.5)
                                fireproximityprompt(prox)
                                task.wait(5) 
                            end
                            ScriptStates.RepairConsole2 = false 
                        end
                        continue 
                    end
                    
                    local hasBag = CountItem("Factory_Bag") > 0
                    local getProx = factoryFolder:FindFirstChild("FactoryPrompts") 
                        and factoryFolder.FactoryPrompts:FindFirstChild("Bag") 
                        and factoryFolder.FactoryPrompts.Bag:FindFirstChild("FactoryPrompt")
                    local putProx = factoryFolder:FindFirstChild("FactoryPrompts") 
                        and factoryFolder.FactoryPrompts:FindFirstChild("ConveyorPart") 
                        and factoryFolder.FactoryPrompts.ConveyorPart:FindFirstChild("FactoryPrompt")
                        
                    if not hasBag and getProx then
                        root.CFrame = CFrame.new(-255.92, 3.50, 209.53)
                        task.wait(0.5)
                        fireproximityprompt(getProx)
                        task.wait(0.5)
                        
                    elseif hasBag and putProx then
                        root.CFrame = CFrame.new(-280.56, 3.50, 236.27)
                        task.wait(0.5)
                        for i = 1, 3 do
                            if not Toggles.AutoTransportRepair.Value then break end
                            if ScriptStates.RepairConsole1 or ScriptStates.RepairConsole2 then break end
                            
                            fireproximityprompt(putProx)
                            task.wait(0.5)
                        end
                    end
                end
            end)
        else
            if ScriptStates.Connections.NotifHook1 then ScriptStates.Connections.NotifHook1:Disconnect() ScriptStates.Connections.NotifHook1 = nil end
            if ScriptStates.Connections.NotifHook2 then ScriptStates.Connections.NotifHook2:Disconnect() ScriptStates.Connections.NotifHook2 = nil end
            if ScriptStates.Connections.AutoTransportRepair then task.cancel(ScriptStates.Connections.AutoTransportRepair) ScriptStates.Connections.AutoTransportRepair = nil end
            ScriptStates.RepairConsole1 = false
            ScriptStates.RepairConsole2 = false
        end
    end
})

local BeanShopGroup = Tabs.Func:AddLeftGroupbox('豆子商店')

local Lbl_BeanShopCount = BeanShopGroup:AddLabel('豆子罐数量: 检测中...')
local Lbl_BeanShopStatus = BeanShopGroup:AddLabel('豆子状态: 检测中...')
local Lbl_BeanShopWeapon = BeanShopGroup:AddLabel('武器状态: 检测中...')
BeanShopGroup:AddDivider()

ScriptStates.Connections.BeanShopUpdate = task.spawn(function()
    while task.wait(0.5) do
        local player = game.Players.LocalPlayer
        local char = player.Character
        local bp = player:FindFirstChildOfClass("Backpack")
        
        local hasFishcalibur = (char and char:FindFirstChild("Tool_Fishcalibur")) or (bp and bp:FindFirstChild("Tool_Fishcalibur"))
        local hasBat = (char and char:FindFirstChild("Other_Bat")) or (bp and bp:FindFirstChild("Other_Bat"))
        
        if hasFishcalibur then
            Lbl_BeanShopWeapon:SetText('武器状态: 已持有 (咸鱼剑)')
        elseif hasBat then
            Lbl_BeanShopWeapon:SetText('武器状态: 已持有 (棒球棒)')
        else
            Lbl_BeanShopWeapon:SetText('武器状态: 未持有抢劫武器')
        end

        local forSell = workspace:FindFirstChild("Map") 
            and workspace.Map:FindFirstChild("ScriptObjects") 
            and workspace.Map.ScriptObjects:FindFirstChild("BeachShop") 
            and workspace.Map.ScriptObjects.BeachShop:FindFirstChild("ForSell")
            
        if forSell then
            local count = 0
            local hasFree = false
            
            for _, child in ipairs(forSell:GetChildren()) do
                if child.Name == "BeansCan" then
                    count = count + 1
                    local priceText = ""
                    pcall(function()
                        priceText = string.lower(child.Attachment.BillboardGui.objPrice.Text)
                    end)
                    if string.find(priceText, "free") then
                        hasFree = true
                    end
                end
            end
            
            Lbl_BeanShopCount:SetText('豆子罐数量: ' .. tostring(count))
            
            if count == 0 then
                Lbl_BeanShopStatus:SetText('豆子状态: 暂无豆子')
            elseif hasFree then
                Lbl_BeanShopStatus:SetText('豆子状态: 正在受到抢劫 (FREE)')
            else
                Lbl_BeanShopStatus:SetText('豆子状态: 未受到抢劫')
            end
        else
            Lbl_BeanShopCount:SetText('豆子罐数量: 检测失败')
            Lbl_BeanShopStatus:SetText('豆子状态: 未知')
        end
    end
end)

BeanShopGroup:AddToggle('AutoRobBeans', {
    Text = '抢劫豆子',
    Default = false,
    Callback = function(Value)
        if Value then
            -- 【修改点】：分离交互线程，极速扫描周围 20 范围内的豆子进行拾取
            ScriptStates.Connections.AutoRobBeansInteract = task.spawn(function()
                while task.wait(0.05) do 
                    if not Toggles.AutoRobBeans.Value then break end
                    local player = game.Players.LocalPlayer
                    local char = player.Character
                    local root = char and char:FindFirstChild("HumanoidRootPart")
                    if not root then continue end

                    local forSell = workspace:FindFirstChild("Map") 
                        and workspace.Map:FindFirstChild("ScriptObjects") 
                        and workspace.Map.ScriptObjects:FindFirstChild("BeachShop") 
                        and workspace.Map.ScriptObjects.BeachShop:FindFirstChild("ForSell")
                        
                    if forSell then
                        for _, child in ipairs(forSell:GetChildren()) do
                            if child.Name == "BeansCan" then
                                local prox = child:FindFirstChildOfClass("ProximityPrompt")
                                if prox then
                                    prox.MaxActivationDistance = 20
                                    local targetPos = child:GetPivot().Position
                                    if (targetPos - root.Position).Magnitude <= 20 then
                                        if prox.Enabled then
                                            fireproximityprompt(prox)
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end)

            -- 【修改点】：分离传送与业务主循环线程，纯净执行坐标转移与武器装备
            ScriptStates.Connections.AutoRobBeansTp = task.spawn(function()
                local player = game.Players.LocalPlayer
                
                while task.wait(1) do
                    if not Toggles.AutoRobBeans.Value then break end
                    
                    if ScriptStates.IsBusy then continue end
                    
                    local char = player.Character
                    local root = char and char:FindFirstChild("HumanoidRootPart")
                    local hum = char and char:FindFirstChildOfClass("Humanoid")
                    if not root or not hum then continue end
                    
                    local forSell = workspace:FindFirstChild("Map") 
                        and workspace.Map:FindFirstChild("ScriptObjects") 
                        and workspace.Map.ScriptObjects:FindFirstChild("BeachShop") 
                        and workspace.Map.ScriptObjects.BeachShop:FindFirstChild("ForSell")
                        
                    if not forSell then continue end
                    
                    local needWeapon = false
                    local anyCans = false
                    
                    for _, child in ipairs(forSell:GetChildren()) do
                        if child.Name == "BeansCan" then
                            anyCans = true
                            local priceText = ""
                            pcall(function() 
                                priceText = string.lower(child.Attachment.BillboardGui.objPrice.Text) 
                            end)
                            if not string.find(priceText, "free") then 
                                needWeapon = true 
                            end
                        end
                    end
                    
                    if anyCans then
                        if needWeapon then
                            local tool = char:FindFirstChild("Tool_Fishcalibur") or player.Backpack:FindFirstChild("Tool_Fishcalibur") 
                                      or char:FindFirstChild("Other_Bat") or player.Backpack:FindFirstChild("Other_Bat")
                            if not tool then
                                task.wait(1)
                                continue 
                            end
                            hum:EquipTool(tool)
                            task.wait(0.2)
                        end
                        
                        ScriptStates.IsBusy = "AutoRobBeans"
                        local savedPos = root.CFrame
                        
                        local coords = {
                            CFrame.new(-179.92, 4.50, -100.45),
                            CFrame.new(-178.37, 4.50, -122.96),
                            CFrame.new(-147.68, 4.50, -108.31),
                            CFrame.new(-147.69, 4.50, -124.07),
                            CFrame.new(-178.96, 4.50, -135.10)
                        }
                        
                        for _, coord in ipairs(coords) do
                            if not Toggles.AutoRobBeans.Value then break end
                            root.CFrame = coord
                            task.wait(1) -- 严格按照要求，间隔一秒传送下一个坐标
                        end
                        
                        if root then root.CFrame = savedPos end
                        if ScriptStates.IsBusy == "AutoRobBeans" then ScriptStates.IsBusy = false end
                        task.wait(1.5)
                    else
                        task.wait(1)
                    end
                end
            end)
        else
            if ScriptStates.IsBusy == "AutoRobBeans" then ScriptStates.IsBusy = false end
            
            -- 清理新建的两个解耦线程
            if ScriptStates.Connections.AutoRobBeansInteract then
                task.cancel(ScriptStates.Connections.AutoRobBeansInteract)
                ScriptStates.Connections.AutoRobBeansInteract = nil
            end
            if ScriptStates.Connections.AutoRobBeansTp then
                task.cancel(ScriptStates.Connections.AutoRobBeansTp)
                ScriptStates.Connections.AutoRobBeansTp = nil
            end
        end
    end
})

local UtilityGroup = Tabs.Func:AddRightGroupbox('实用功能')

UtilityGroup:AddButton('清理汽车', function()
    local cars = workspace:FindFirstChild("Map") and workspace.Map:FindFirstChild("ScriptObjects") and workspace.Map.ScriptObjects:FindFirstChild("Cars")
    if cars then cars:ClearAllChildren() Library:Notify("汽车清理完毕！") else Library:Notify("未找到汽车或已被清理") end
end)

UtilityGroup:AddButton('清理便便', function()
    local poops = workspace:FindFirstChild("Map") and workspace.Map:FindFirstChild("ScriptObjects") and workspace.Map.ScriptObjects:FindFirstChild("PoopKillers")
    if poops then poops:ClearAllChildren() Library:Notify("便便清理完毕！") else Library:Notify("未找到便便或已被清理") end
end)

UtilityGroup:AddButton('清理材质', function()
    pcall(function()
        loadstring(game:HttpGet("https://scriptblox.com/raw/Universal-Script-FpsBoost-9260"))()
    end)
    Library:Notify("已清理！")
end)

UtilityGroup:AddToggle('AntiAFK', {
    Text = '反 AFK',
    Default = false,
    Callback = function(Value)
        if Value then
            local VirtualUser = game:GetService("VirtualUser")
            ScriptStates.Connections.RobloxAFK = game.Players.LocalPlayer.Idled:Connect(function()
                VirtualUser:CaptureController()
                VirtualUser:ClickButton2(Vector2.new())
            end)
            ScriptStates.Connections.GameAntiAFK = task.spawn(function()
                while task.wait(15) do
                    if not Toggles.AntiAFK.Value then break end
                    local char = game.Players.LocalPlayer.Character
                    if char then
                        local oldSwim = char:GetAttribute("Swim")
                        char:SetAttribute("Swim", true)
                        task.wait(0.05) 
                        if oldSwim ~= nil then char:SetAttribute("Swim", oldSwim) else char:SetAttribute("Swim", nil) end
                    end
                end
            end)
            Library:Notify("反AFK已开启！")
        else
            if ScriptStates.Connections.RobloxAFK then ScriptStates.Connections.RobloxAFK:Disconnect() ScriptStates.Connections.RobloxAFK = nil end
            if ScriptStates.Connections.GameAntiAFK then task.cancel(ScriptStates.Connections.GameAntiAFK) ScriptStates.Connections.GameAntiAFK = nil end
            Library:Notify("反AFK已关闭！")
        end
    end
})

local DiggingGroup = Tabs.Func:AddRightGroupbox('挖掘功能')

DiggingGroup:AddDropdown('DiggingDropdown', {
    Values = {"正在扫描背包..."},
    Default = 1,
    Multi = true,
    Text = '选择物品',
})

local DropdownMapping = {} 

local function SetLockState(state)
    local SellFunc = game:GetService("ReplicatedStorage").Events:WaitForChild("SellFunc")
    local currentTrash = SellFunc:InvokeServer("GetSavedLoot")["Trash"] or {}
    local currentFish = SellFunc:InvokeServer("GetSavedLoot")["Fish"] or {}
    
    local selections = Options.DiggingDropdown.Value
    if type(selections) == "table" then
        for dropStr, isSel in pairs(selections) do
            if isSel and DropdownMapping[dropStr] then
                local info = DropdownMapping[dropStr]
                if info.Type == "Trash" then currentTrash[info.RawName] = state end
                if info.Type == "Fish"  then currentFish[info.RawName] = state end
            end
        end
    end
    
    currentTrash.Type = "Trash"
    currentFish.Type = "Fish"
    
    SellFunc:InvokeServer("UpdateSavedLoot", currentTrash)
    SellFunc:InvokeServer("UpdateSavedLoot", currentFish)
    
    ScriptStates.SavedTrashLoot = currentTrash
    ScriptStates.SavedFishLoot = currentFish
    
    Library:Notify(state and "已上锁选中的物品！" or "已解锁选中的物品！")
end

DiggingGroup:AddButton({
    Text = '上锁物品', Func = function() SetLockState(true) end
}):AddButton({
    Text = '解锁物品', Func = function() SetLockState(false) end
})

DiggingGroup:AddDivider()

local function PerformSell()
    if ScriptStates.IsBusy then Library:Notify("系统繁忙，请稍后再试！", 2) return end
    ScriptStates.IsBusy = "PerformSell"
    
    local player = game.Players.LocalPlayer
    local char = player.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then ScriptStates.IsBusy = false return end
    
    local SellFunc = game:GetService("ReplicatedStorage").Events:WaitForChild("SellFunc")
    local savedTrash = SellFunc:InvokeServer("GetSavedLoot")["Trash"] or {}
    local savedFish = SellFunc:InvokeServer("GetSavedLoot")["Fish"] or {}
    
    local sellTrash = { Type = "Trash" }
    local sellFish = { Type = "Fish" }
    local hasTrash, hasFish = false, false
    
    local function scanItems(container)
        if not container then return end
        for _, tool in ipairs(container:GetChildren()) do
            local tType = tool:GetAttribute("TYPE")
            if tType == "Trash" or tType == "Fish" then
                local rawName = string.split(tool.Name, "_")[2]
                if rawName then
                    local amt = tool:GetAttribute("amount") or 1
                    local isLocked = false
                    if tType == "Trash" then isLocked = savedTrash[rawName] end
                    if tType == "Fish" then isLocked = savedFish[rawName] end
                    
                    if not isLocked then
                        if tType == "Trash" then
                            sellTrash[rawName] = (sellTrash[rawName] or 0) + amt
                            hasTrash = true
                        elseif tType == "Fish" then
                            sellFish[rawName] = (sellFish[rawName] or 0) + amt
                            hasFish = true
                        end
                    end
                end
            end
        end
    end
    
    scanItems(player:FindFirstChild("Backpack"))
    scanItems(char)
    
    if not hasTrash and not hasFish then
        Library:Notify("没有可出售的未上锁物品！")
        if ScriptStates.IsBusy == "PerformSell" then ScriptStates.IsBusy = false end
        return
    end
    
    local savedPos = root.CFrame
    root.CFrame = CFrame.new(-172.94, 3.50, 46.31)
    task.wait(0.5)
    
    if hasTrash then pcall(function() SellFunc:InvokeServer("Sell", sellTrash) end) task.wait(0.2) end
    if hasFish then pcall(function() SellFunc:InvokeServer("Sell", sellFish) end) task.wait(0.2) end
    
    if root then root.CFrame = savedPos end
    Library:Notify("已出售并返回原位！")
    if ScriptStates.IsBusy == "PerformSell" then ScriptStates.IsBusy = false end
end

DiggingGroup:AddButton('手动出售', PerformSell)

DiggingGroup:AddToggle('AutoDigSell', {
    Text = '自动出售',
    Default = false,
    Callback = function(Value)
        local RS = game:GetService("ReplicatedStorage")
        if Value then
            local function checkInvFull(action, data)
                if not Toggles.AutoDigSell.Value then return end
                local text = ""
                if type(data) == "string" then text = data
                elseif type(data) == "table" then text = data.message or data.Message or data.text or data.Text or "" end
                text = tostring(text)
                
                local lowerText = string.lower(text)
                if action == "Warning" and string.find(lowerText, "inventory is full") then
                    ScriptStates.TriggerAutoSell = true
                end
            end
            
            local NotifEvent = RS.Events:WaitForChild("NotificationEvent")
            local ClientNotifEvent = RS.LocalEvents:WaitForChild("ClientNotificationEvent")
            ScriptStates.Connections.NotifHookAutoSell1 = NotifEvent.OnClientEvent:Connect(checkInvFull)
            ScriptStates.Connections.NotifHookAutoSell2 = ClientNotifEvent.Event:Connect(checkInvFull)
            
            ScriptStates.Connections.AutoSellThread = task.spawn(function()
                while task.wait(0.5) do
                    if not Toggles.AutoDigSell.Value then break end
                    if ScriptStates.TriggerAutoSell then
                        ScriptStates.TriggerAutoSell = false
                        PerformSell() 
                    end
                end
            end)
        else
            if ScriptStates.Connections.NotifHookAutoSell1 then ScriptStates.Connections.NotifHookAutoSell1:Disconnect() end
            if ScriptStates.Connections.NotifHookAutoSell2 then ScriptStates.Connections.NotifHookAutoSell2:Disconnect() end
            if ScriptStates.Connections.AutoSellThread then task.cancel(ScriptStates.Connections.AutoSellThread) end
            ScriptStates.TriggerAutoSell = false
        end
    end
})

DiggingGroup:AddDivider()

DiggingGroup:AddDropdown('DigAreaSelect', {
    Values = {"后巷", "海滩", "下水道"},
    Default = 1,
    Multi = false,
    Text = '选择挖掘区域',
})

DiggingGroup:AddToggle('AutoDig', {
    Text = '自动挖掘',
    Default = false,
    Callback = function(Value)
        if Value then
            ScriptStates.Connections.AutoDig = task.spawn(function()
                local player = game.Players.LocalPlayer
                
                while task.wait(0.5) do
                    if not Toggles.AutoDig.Value then break end
                    
                    if ScriptStates.IsBusy then continue end
                    
                    local char = player.Character
                    local root = char and char:FindFirstChild("HumanoidRootPart")
                    local hum = char and char:FindFirstChildOfClass("Humanoid")
                    if not root or not hum then continue end
                    
                    local areaOpt = Options.DigAreaSelect.Value
                    local trashFolder = nil
                    local toolKeyword = ""
                    
                    if areaOpt == "后巷" then
                        trashFolder = workspace:FindFirstChild("Map") and workspace.Map:FindFirstChild("ScriptObjects") and workspace.Map.ScriptObjects:FindFirstChild("TrashTriggers") and workspace.Map.ScriptObjects.TrashTriggers:FindFirstChild("Stick")
                        toolKeyword = "Stick"
                    elseif areaOpt == "海滩" then
                        trashFolder = workspace:FindFirstChild("Map") and workspace.Map:FindFirstChild("ScriptObjects") and workspace.Map.ScriptObjects:FindFirstChild("TrashTriggers") and workspace.Map.ScriptObjects.TrashTriggers:FindFirstChild("Shovel")
                        toolKeyword = "Shovel"
                    elseif areaOpt == "下水道" then
                        if (root.Position - Vector3.new(-243.78, -26.46, -1374.32)).Magnitude > 200 then
                            root.CFrame = CFrame.new(-243.78, -26.46, -1374.32)
                            task.wait(1.5) 
                        end
                        
                        local sewerFolder = workspace:FindFirstChild("Map") and workspace.Map:FindFirstChild("ScriptObjects") and workspace.Map.ScriptObjects:FindFirstChild("Sewer")
                        if sewerFolder then
                            local tsunami = sewerFolder:FindFirstChild("TsunamiWave")
                            if tsunami then
                                pcall(function() tsunami:Destroy() end)
                            end
                            trashFolder = sewerFolder:FindFirstChild("Trash")
                        end
                        toolKeyword = "Shovel"
                    else
                        task.wait(1)
                        continue
                    end
                    
                    if not trashFolder then continue end
                    
                    local bestTrigger = nil
                    local maxScore = -1
                    
                    for _, trigger in ipairs(trashFolder:GetChildren()) do
                        if trigger:IsA("BasePart") then
                            local mythic = trigger:GetAttribute("Mythic") or -1
                            local leg = trigger:GetAttribute("Legendary") or -1
                            local epic = trigger:GetAttribute("Epic") or -1
                            local rare = trigger:GetAttribute("Rare") or -1
                            local unc = trigger:GetAttribute("Uncommon") or -1
                            local com = trigger:GetAttribute("Common") or -1
                            
                            if mythic > 0 or leg > 0 or epic > 0 or rare > 0 or unc > 0 or com > 0 then
                                local score = (math.max(0, mythic) * 100000) +
                                              (math.max(0, leg) * 10000) +
                                              (math.max(0, epic) * 1000) +
                                              (math.max(0, rare) * 100) +
                                              (math.max(0, unc) * 10) +
                                              (math.max(0, com) * 1)
                                              
                                if score > maxScore then
                                    maxScore = score
                                    bestTrigger = trigger
                                end
                            end
                        end
                    end
                    
                    if bestTrigger then
                        local targetPos = bestTrigger.Position + Vector3.new(0, 3, 0)
                        local distance = (root.Position - targetPos).Magnitude
                        
                        if distance > 10 then
                            root.CFrame = CFrame.new(targetPos)
                            task.wait(0.3)
                        end
                        
                        local tool = char:FindFirstChildWhichIsA("Tool")
                        if not tool or not string.find(tool.Name, toolKeyword) then
                            tool = nil
                            local bp = player:FindFirstChildOfClass("Backpack")
                            if bp then
                                for _, item in ipairs(bp:GetChildren()) do
                                    if item:IsA("Tool") and string.find(item.Name, toolKeyword) then
                                        tool = item
                                        break
                                    end
                                end
                            end
                            if tool then
                                hum:EquipTool(tool)
                                task.wait(0.2)
                            end
                        end
                        
                        if tool then
                            tool:Activate()
                        end
                        
                        local prox = bestTrigger:FindFirstChildOfClass("ProximityPrompt")
                        if prox and prox.Enabled then
                            fireproximityprompt(prox)
                        end
                    else
                        task.wait(1)
                    end
                end
            end)
        else
            if ScriptStates.Connections.AutoDig then
                task.cancel(ScriptStates.Connections.AutoDig)
                ScriptStates.Connections.AutoDig = nil
            end
        end
    end
})

ScriptStates.Connections.DiggingUIUpdate = task.spawn(function()
    local lastListStr = ""
    while task.wait(1) do
        local player = game.Players.LocalPlayer
        local char = player.Character
        local bp = player:FindFirstChildOfClass("Backpack")
        
        if os.time() - ScriptStates.LastLootFetch >= 3 then
            pcall(function()
                local SellFunc = game:GetService("ReplicatedStorage").Events:FindFirstChild("SellFunc")
                if SellFunc then
                    local loot = SellFunc:InvokeServer("GetSavedLoot")
                    if loot then
                        ScriptStates.SavedTrashLoot = loot["Trash"] or ScriptStates.SavedTrashLoot
                        ScriptStates.SavedFishLoot = loot["Fish"] or ScriptStates.SavedFishLoot
                    end
                end
            end)
            ScriptStates.LastLootFetch = os.time()
        end
        
        local items = {}
        local function countTools(container)
            if not container then return end
            for _, tool in ipairs(container:GetChildren()) do
                local tType = tool:GetAttribute("TYPE")
                if tType == "Trash" or tType == "Fish" then
                    local rawName = string.split(tool.Name, "_")[2]
                    if rawName then
                        local amt = tool:GetAttribute("amount") or 1
                        if not items[rawName] then
                            items[rawName] = { Type = tType, Amount = 0 }
                        end
                        items[rawName].Amount = items[rawName].Amount + amt
                    end
                end
            end
        end
        countTools(char)
        countTools(bp)
        
        local newList = {}
        local newMapping = {}
        local listStrBuilder = ""
        
        for rawName, data in pairs(items) do
            local tName = GlobalTranslations[rawName] or rawName
            local isLocked = false
            if data.Type == "Trash" then isLocked = ScriptStates.SavedTrashLoot[rawName] end
            if data.Type == "Fish"  then isLocked = ScriptStates.SavedFishLoot[rawName] end
            
            local lockIcon = isLocked and "🔒 " or ""
            local dropStr = string.format("%s%s (x%d)", lockIcon, tName, data.Amount)
            
            table.insert(newList, dropStr)
            newMapping[dropStr] = { RawName = rawName, Type = data.Type, BaseName = tName }
        end
        
        if #newList == 0 then table.insert(newList, "背包为空") end
        
        table.sort(newList)
        for _, v in ipairs(newList) do listStrBuilder = listStrBuilder .. v end
        
        if listStrBuilder ~= lastListStr then
            lastListStr = listStrBuilder
            
            local oldSelections = Options.DiggingDropdown and Options.DiggingDropdown.Value or {}
            local newSelections = {}
            
            if type(oldSelections) == "table" then
                for oldStr, isSel in pairs(oldSelections) do
                    if isSel and DropdownMapping[oldStr] then
                        local oldRawName = DropdownMapping[oldStr].RawName
                        for _, newStr in ipairs(newList) do
                            if newMapping[newStr] and newMapping[newStr].RawName == oldRawName then
                                newSelections[newStr] = true
                            end
                        end
                    end
                end
            end
            
            DropdownMapping = newMapping
            
            if Options.DiggingDropdown then
                Options.DiggingDropdown:SetValues(newList)
                Options.DiggingDropdown:SetValue(newSelections)
            end
        end
    end
end)

-- ======================= 【UI 调试标签页】 ======================= --
local MenuGroup = Tabs["UI Settings"]:AddLeftGroupbox('设置')

MenuGroup:AddButton('卸载菜单', function()
    if ScriptStates and ScriptStates.Connections then
        for key, connection in pairs(ScriptStates.Connections) do
            if connection then
                if type(connection) == "thread" then task.cancel(connection)
                else connection:Disconnect() end
            end
        end
        table.clear(ScriptStates.Connections)
    end
    
    local player = game:GetService("Players").LocalPlayer
    if player.Character and player.Character:FindFirstChild("Humanoid") and ScriptStates then
        player.Character.Humanoid.WalkSpeed = ScriptStates.OriginalWalkSpeed
    end

    Library:Unload() 
end)

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

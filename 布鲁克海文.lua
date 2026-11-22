-- 布鲁克海文：独立服务器缝合版
local NothingLibrary = loadstring(game:HttpGetAsync('https://raw.githubusercontent.com/quanwei-sy/qianweicangku/refs/heads/main/%E6%BA%90%E7%A0%81.lua'))()

local __BaseWindow = NothingLibrary.new({
    Title = "TY hub｜布鲁克海文",
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


local Window, Tab, Tab1, LocalPlayer1
Window = Library:MakeWindow({ Title = "TY hub｜布鲁克海文" })
do
	Tab1 = Window:MakeTab({"MAIN", "home"})
	local Players1 = game:GetService("Players")
	local TeleportService = game:GetService("TeleportService")
	local GuiService = game:GetService("GuiService")
	local LocalPlayer = Players1.LocalPlayer
	LocalPlayer1 = Players1.LocalPlayer
	local flag = false
	local v7

	Tab1:AddToggle({
		Name = "AUTO REJOIN ON KICK",
		Default = false,
		Callback = function(value)
			flag = value

			if v7 then
				v7:Disconnect()
				v7 = nil
			end

			if value then
				v7 = GuiService.ErrorMessageChanged:Connect(function(arg1)
					if flag and arg1 and arg1 ~= "" then
						task.wait(1)
						TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
					end
				end)
			end
		end,
	})

	local tbl7 = {}

	tbl7[2], tbl7[1] = function()
		if setclipboard then
			setclipboard(game.JobId)
		end
	end, "COPY SERVER ID"

	Tab1:AddButton(tbl7)
	local tbl8 = {}

	tbl8[1], tbl8[2] = "ANTI CHEAT BYPASS", function()
		for _, descendant in ipairs(game:GetDescendants()) do
			if descendant.Name then
				local v1 = string.lower(descendant.Name)
				if v1 == "anticheat" or v1 == "exploit" then
					pcall(function()
						descendant:Destroy()
					end)
				end
			end
		end
	end

	Tab1:AddButton(tbl8)
	local tbl9 = {}

	tbl9[1], tbl9[2] = "REJOIN", function()
		local TeleportService = game:GetService("TeleportService")
		TeleportService:Teleport(game.PlaceId, game.Players.LocalPlayer)
	end

	Tab1:AddButton(tbl9)
	local tbl10 = {}

	local function func2(arg1)
		return (Players1:GetUserThumbnailAsync(arg1, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100))
	end

	local function func3(name, arg2)
		local v1 = arg2 and ("PLAYER %s JOINED").format("PLAYER %s JOINED", name) or ("PLAYER %s LEFT").format("PLAYER %s LEFT", name)
		local v2 = Players1:FindFirstChild(name)
		local v3

		if v2 then
			v3 = func2(v2.UserId)
		end

		game.StarterGui:SetCore("SendNotification", {Title = "TY hub", Text = v1, Icon = v3 or "", Duration = 5})
	end

	Tab1:AddToggle({
		Name = "JOIN/EXIT NOTIFICATION",
		Default = false,
		Callback = function(value)
			for _, v1 in pairs(tbl10) do
				v1:Disconnect()
			end

			tbl10 = {}

			if value then
				table.insert(tbl10, Players1.PlayerAdded:Connect(function(player)
					func3(player.Name, true)
				end))
				table.insert(tbl10, Players1.PlayerRemoving:Connect(function(player)
					func3(player.Name, false)
				end))
			end
		end,
	})
end

local Tab4, Remotes

do
	local tbl11 = {}

	tbl11[1], tbl11[2] = "COPY COORDINATES", function()
		local LocalPlayer = game.Players.LocalPlayer
		if LocalPlayer and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
			local Position = LocalPlayer.Character.HumanoidRootPart.Position
			setclipboard(string.format("X: %d, Y: %d, Z: %d", Position.X, Position.Y, Position.Z))
			print("Coordenadas copiadas para a area de transferencia: ", Position)
		else
			print("Nao foi possivel obter as coordenadas.")
		end
	end

	Tab1:AddButton(tbl11)
	local tbl12 = {}

	tbl12[1], tbl12[2] = "GOTO SAFE ZONE", function()
		local Character = LocalPlayer1.Character
		local v1 = Character and Character:FindFirstChild("HumanoidRootPart")

		if not v1 then
			return
		end

		v1.CFrame = CFrame.new(1080, 76, -1070)
	end

	Tab1:AddButton(tbl12)
	local CFrame1
	local tbl13 = {}

	tbl13[1], tbl13[2] = "SET SPAWNPOINT", function()
		local LocalPlayer = game.Players.LocalPlayer
		if LocalPlayer and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
			CFrame1 = LocalPlayer.Character.HumanoidRootPart.CFrame
			print("Ponto de spawn definido!")
			game.StarterGui:SetCore("SendNotification", {Title = "SpawnPoint", Text = "Seu ponto de spawn foi salvo!", Duration = 5})
		else
			print("Nao foi possivel definir o ponto de spawn.")
		end
	end

	Tab1:AddButton(tbl13)

	game.Players.LocalPlayer.CharacterAdded:Connect(function(character)
		if CFrame1 then
			local HumanoidRootPart = character:WaitForChild("HumanoidRootPart", 10)
			if HumanoidRootPart then
				HumanoidRootPart.CFrame = CFrame1
				print("Teleportado para o ponto de spawn salvo!")
			end
		end
	end)

	local function func4()
		local LocalPlayer = game.Players.LocalPlayer
		local HumanoidRootPart = (LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()):WaitForChild("HumanoidRootPart")

		local function func()
			HumanoidRootPart.CFrame = HumanoidRootPart.CFrame * CFrame.new(0, 0, 0.1)
			task.wait(1)
			HumanoidRootPart.CFrame = HumanoidRootPart.CFrame * CFrame.new(0, 0, -0.1)
		end

		while true do
			task.wait(600)
			func()
		end
	end

	local tbl14 = {}

	tbl14[2], tbl14[1] = function()
		task.spawn(func4)
	end, "ANTI AFK"

	Tab1:AddButton(tbl14)
	Window:SelectTab(Tab)
	local Tab2 = Window:MakeTab({"EVENTS", "ticket"})
	local flag1 = false
	local connection

	local function func5()
		for _, descendant in ipairs(workspace:GetDescendants()) do
			if descendant:IsA("Seat") or descendant:IsA("VehicleSeat") then
				descendant:Destroy()
			end
		end
	end

	Tab2:AddToggle({
		Name = "AUTO CANDYS",
		Default = false,
		Callback = function(value)
			flag1 = value
			if flag1 then
				func5()

				connection = workspace.DescendantAdded:Connect(function(descendant)
					if flag1 and (descendant:IsA("Seat") or descendant:IsA("VehicleSeat")) then
						task.defer(function()
							descendant:Destroy()
						end)
					end
				end)

				task.spawn(function()
					while flag1 do
						local Character = game:GetService("Players").LocalPlayer.Character
						local v1 = Character and Character:FindFirstChild("HumanoidRootPart")
						local v2 = workspace:FindFirstChild("CandyCornHunt") and workspace.CandyCornHunt:FindFirstChild("Week2")

						if v1 and v2 then
							for _, child in ipairs(v2:GetChildren()) do
								if not flag1 then
									break
								end
								if child and child:IsA("BasePart") and child.Transparency < 1 then
									v1.CFrame = child.CFrame + Vector3.new(0, 3, 0)
									task.wait(1)
								end
							end
						end

						task.wait(1)
					end
				end)
			elseif connection then
				connection:Disconnect()
				connection = nil
			end
		end,
	})

	local Tab3 = Window:MakeTab({"TROLL", "skull"})
	local Players2 = game:GetService("Players")
	local LocalPlayer2 = Players2.LocalPlayer
	local RunService = game:GetService("RunService")
	local CurrentCamera = workspace.CurrentCamera
	local ReplicatedStorage = game:GetService("ReplicatedStorage")
	local str = ""
	local str1 = "FLING"
	local tbl15 = {}

	local function func6(arg1)
		if not arg1 or arg1 == "" then
			return nil
		end

		local v1 = arg1:lower()

		for _, player in ipairs(Players2:GetPlayers()) do
			if player ~= LocalPlayer2 and (player.Name:lower():find(v1) or player.DisplayName:lower():find(v1)) then
				return player
			end
		end

		return nil
	end

	local function func7(arg1)
		if tbl15[arg1] then
			if type(tbl15[arg1]) == "thread" then
				task.cancel(tbl15[arg1])
			elseif typeof(tbl15[arg1]) == "RBXScriptConnection" then
				tbl15[arg1]:Disconnect()
			end
			tbl15[arg1] = nil
		end
		if LocalPlayer2.Character then
			local HumanoidRootPart = LocalPlayer2.Character:FindFirstChild("HumanoidRootPart")
			if HumanoidRootPart then
				HumanoidRootPart.AssemblyLinearVelocity = Vector3.zero
				HumanoidRootPart.AssemblyAngularVelocity = Vector3.zero
			end
		end
	end

	local function func8(arg1, arg2, arg3, arg4)
		local v1 = arg1.AssemblyLinearVelocity.Magnitude > 2
		return arg1.CFrame * CFrame.new(0, 0, v1 and -25 or -1.7) * CFrame.Angles(math.rad(arg2), math.rad(arg3), math.rad(arg4))
	end

	Tab3:AddTextBox({
		Name = "PLAYER NAME",
		Description = "Enter target player name",
		PlaceholderText = "Username or Display...",
		Callback = function(value)
			str = value
		end,
	})

	local tbl16 = {}

	tbl16[1], tbl16[2] = "GET COUCH", function()
		if ReplicatedStorage:FindFirstChild("RE") and ReplicatedStorage.RE:FindFirstChild("1Too1l") then
			ReplicatedStorage.RE["1Too1l"]:InvokeServer("PickingTools", "Couch")
			task.wait(0.2)
			local Backpack = LocalPlayer2:FindFirstChild("Backpack")
			local Character = LocalPlayer2.Character

			if Backpack and Character then
				local Couch = Backpack:FindFirstChild("Couch")
				if Couch then
					Character:FindFirstChildOfClass("Humanoid"):EquipTool(Couch)
				end
			end
		end
	end

	Tab3:AddButton(tbl16)
	Tab3:AddSection({"Basic Functions"})
	local tbl17 = {}

	tbl17[1], tbl17[2] = "GO TO PLAYER", function()
		local v1 = func6(str)
		if v1 and v1.Character and v1.Character:FindFirstChild("HumanoidRootPart") then
			LocalPlayer2.Character.HumanoidRootPart.CFrame = v1.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, -1.7)
		end
	end

	Tab3:AddButton(tbl17)

	Tab3:AddToggle({
		Name = "STICK PLAYER",
		Default = false,
		Callback = function(value)
			func7("STICK PLAYER")
			if value then
				tbl15["STICK PLAYER"] = RunService.Heartbeat:Connect(function()
					local v1 = func6(str)
					if v1 and v1.Character and v1.Character:FindFirstChild("HumanoidRootPart") then
						LocalPlayer2.Character.HumanoidRootPart.CFrame = v1.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, -1.7)
					end
				end)
			end
		end,
	})

	Tab3:AddToggle({
		Name = "VIEW",
		Default = false,
		Callback = function(value)
			func7("VIEW")
			if value then
				tbl15.VIEW = RunService.Heartbeat:Connect(function()
					local v1 = func6(str)
					if v1 and v1.Character then
						CurrentCamera.CameraSubject = v1.Character:FindFirstChildOfClass("Humanoid")
					end
				end)
			elseif LocalPlayer2.Character then
				CurrentCamera.CameraSubject = LocalPlayer2.Character:FindFirstChildOfClass("Humanoid")
			end
		end,
	})

	Tab3:AddToggle({
		Name = "ORBITING PLAYER",
		Default = false,
		Callback = function(value)
			func7("ORBITING")
			if value then
				local num = 0
				tbl15.ORBITING = RunService.Heartbeat:Connect(function()
					local v1 = func6(str)
					if v1 and v1.Character and v1.Character:FindFirstChild("HumanoidRootPart") then
						num = num + 0.05
						local v2 = math.cos(num) * 6
						local v3 = math.sin(num) * 6

						LocalPlayer2.Character.HumanoidRootPart.CFrame = CFrame.new(
							v1.Character.HumanoidRootPart.Position + Vector3.new(v2, 2, v3),
							v1.Character.HumanoidRootPart.Position
						)
					end
				end)
			end
		end,
	})

	Tab3:AddDropdown({
		Name = "FLING METHOD",
		Description = "Select Fling Velocity Mode",
		Options = {"FLING", "TELEPORT+FLING"},
		Default = "FLING",
		Callback = function(value)
			str1 = value
		end,
	})

	Tab3:AddSection({"Heavy Trolls"})

	Tab3:AddToggle({
		Name = "FLING COUCH",
		Default = false,
		Callback = function(value)
			func7("FLING COUCH")
			if value then
				local num = 0
				local num1 = 0
				local num2 = 0

				tbl15["FLING COUCH"] = RunService.Heartbeat:Connect(function()
					local v1 = func6(str)

					if not v1 or not v1.Character or not v1.Character:FindFirstChild("HumanoidRootPart") then
						return
					end

					local v2 = LocalPlayer2.Character and LocalPlayer2.Character:FindFirstChild("HumanoidRootPart")
					local HumanoidRootPart = v1.Character.HumanoidRootPart
					local Humanoid = v1.Character:FindFirstChildOfClass("Humanoid")

					if not v2 then
						return
					end

					if Humanoid and Humanoid.Sit then
						if str1 == "FLING" then
							v2.AssemblyLinearVelocity = Vector3.new(0, 999999999, 0)
							v2.CFrame = CFrame.new(0, 999999, 0)
						else
							v2.CFrame = CFrame.new(0, 1000000000000000000, 0)
						end

						func7("FLING COUCH")
						return
					end

					v2.AssemblyLinearVelocity = Vector3.new(40000, 40000, 40000)
					v2.AssemblyAngularVelocity = Vector3.new(40000, 40000, 40000)
					num = (num + 70) % 360
					num1 = (num1 + 110) % 360
					num2 = (num2 + 85) % 360
					v2.CFrame = func8(HumanoidRootPart, num, num1, num2)
				end)
			end
		end,
	})

	Tab3:AddToggle({
		Name = "BRING PLAYER",
		Default = false,
		Callback = function(value)
			func7("BRING PLAYER")
			if value then
				local num = 0
				local num1 = 0
				local num2 = 0
				local v1 = LocalPlayer2.Character and LocalPlayer2.Character.HumanoidRootPart.CFrame

				tbl15["BRING PLAYER"] = RunService.Heartbeat:Connect(function()
					local v2 = func6(str)

					if not v2 or not v2.Character or not v2.Character:FindFirstChild("HumanoidRootPart") then
						return
					end

					local HumanoidRootPart = LocalPlayer2.Character.HumanoidRootPart
					local HumanoidRootPart1 = v2.Character.HumanoidRootPart
					local Humanoid = v2.Character:FindFirstChildOfClass("Humanoid")

					if Humanoid and Humanoid.Sit then
						if v1 then
							HumanoidRootPart.CFrame = v1
						end

						func7("BRING PLAYER")
						return
					end

					num = (num + 70) % 360
					num1 = (num1 + 110) % 360
					local v3 = (num2 + 85) % 360
					num2 = v3
					HumanoidRootPart.AssemblyLinearVelocity = Vector3.new(0, 60, 0)
					HumanoidRootPart.CFrame = func8(HumanoidRootPart1, num, num1, num2)
				end)
			end
		end,
	})

	Tab3:AddToggle({
		Name = "PRISON PLAYER",
		Default = false,
		Callback = function(value)
			func7("PRISON PLAYER")
			if value then
				local num = 0
				local num1 = 0
				local num2 = 0

				tbl15["PRISON PLAYER"] = RunService.Heartbeat:Connect(function()
					local v1 = func6(str)

					if not v1 or not v1.Character or not v1.Character:FindFirstChild("HumanoidRootPart") then
						return
					end

					local HumanoidRootPart = LocalPlayer2.Character.HumanoidRootPart
					local HumanoidRootPart1 = v1.Character.HumanoidRootPart
					local Humanoid = v1.Character:FindFirstChildOfClass("Humanoid")

					if Humanoid and Humanoid.Sit then
						HumanoidRootPart.CFrame = CFrame.new(55, 34, 631)
						func7("PRISON PLAYER")
						return
					end

					num = (num + 70) % 360
					num1 = (num1 + 110) % 360
					local v2 = (num2 + 85) % 360
					num2 = v2
					HumanoidRootPart.AssemblyLinearVelocity = Vector3.new(0, 60, 0)
					HumanoidRootPart.CFrame = func8(HumanoidRootPart1, num, num1, num2)
				end)
			end
		end,
	})

	Tab3:AddToggle({
		Name = "VOID KILL PLAYER",
		Default = false,
		Callback = function(value)
			func7("VOID KILL PLAYER")
			if value then
				local num = 0
				local num1 = 0
				local num2 = 0

				tbl15["VOID KILL PLAYER"] = RunService.Heartbeat:Connect(function()
					local v1 = func6(str)

					if not v1 or not v1.Character or not v1.Character:FindFirstChild("HumanoidRootPart") then
						return
					end

					local HumanoidRootPart = LocalPlayer2.Character.HumanoidRootPart
					local HumanoidRootPart1 = v1.Character.HumanoidRootPart
					local Humanoid = v1.Character:FindFirstChildOfClass("Humanoid")

					if Humanoid and Humanoid.Sit then
						HumanoidRootPart.CFrame = CFrame.new(0, -900, 0)
						func7("VOID KILL PLAYER")
						return
					end

					num = (num + 70) % 360
					num1 = (num1 + 110) % 360
					num2 = (num2 + 85) % 360
					HumanoidRootPart.AssemblyLinearVelocity = Vector3.new(0, 60, 0)
					HumanoidRootPart.CFrame = func8(HumanoidRootPart1, num, num1, num2)
				end)
			end
		end,
	})

	Tab4 = Window:MakeTab({"AVATAR", "shirt"})
	local Players3 = game:GetService("Players")
	Remotes = game:GetService("ReplicatedStorage"):WaitForChild("Remotes")
	local v8

	Tab4:AddTextBox({
		Name = "TARGET NAME",
		Description = "Enter target player name",
		PlaceholderText = "Username or Display...",
		Callback = function(value)
			v8 = value
		end,
	})

	local tbl18 = {}

	local function func9(arg1)
		local v1 = arg1:lower()

		for _, player in ipairs(Players3:GetPlayers()) do
			if player.Name:lower():find(v1) or player.DisplayName:lower():find(v1) then
				return player
			end
		end

		return nil
	end

	tbl18[2], tbl18[1] = function()
		if not v8 then
			return
		end

		local v1 = func9(v8)

		if not v1 or not v1.Character then
			return
		end

		local Character = Players3.LocalPlayer.Character

		if not Character then
			return
		end

		local Humanoid = Character:FindFirstChildOfClass("Humanoid")
		local Humanoid1 = v1.Character:FindFirstChildOfClass("Humanoid")

		if not (Humanoid and Humanoid1) then
			return
		end

		local AppliedDescription = Humanoid:GetAppliedDescription()

		for _, accessorie in ipairs(AppliedDescription:GetAccessories(true)) do
			if tonumber(accessorie.AssetId) then
				Remotes.Wear:InvokeServer(accessorie.AssetId)
				task.wait(0.2)
			end
		end

		local tbl = {}
		tbl[3], tbl[1], tbl[2] = AppliedDescription.Face, AppliedDescription.Shirt, AppliedDescription.Pants

		for _, v2 in ipairs(tbl) do
			if tonumber(v2) then
				Remotes.Wear:InvokeServer(v2)
				task.wait(0.2)
			end
		end

		local AppliedDescription1 = Humanoid1:GetAppliedDescription()
		local ChangeCharacterBody = Remotes.ChangeCharacterBody
		local tbl1 = {}
		tbl1[4], tbl1[5], tbl1[6], tbl1[3], tbl1[2], tbl1[1] = AppliedDescription1.RightLeg, AppliedDescription1.LeftLeg, AppliedDescription1.Head, AppliedDescription1.LeftArm, AppliedDescription1.RightArm, AppliedDescription1.Torso
		ChangeCharacterBody:InvokeServer(tbl1)
		task.wait(0.5)
		local tbl2 = {}
		tbl2[3], tbl2[2], tbl2[1] = AppliedDescription1.Face, AppliedDescription1.Pants, AppliedDescription1.Shirt

		for _, v3 in ipairs(tbl2) do
			if tonumber(v3) then
				Remotes.Wear:InvokeServer(v3)
				task.wait(0.3)
			end
		end

		for _, accessorie1 in ipairs(AppliedDescription1:GetAccessories(true)) do
			if tonumber(accessorie1.AssetId) then
				Remotes.Wear:InvokeServer(accessorie1.AssetId)
				task.wait(0.3)
			end
		end

		local BodyColors = v1.Character:FindFirstChild("Body Colors")

		if BodyColors then
			Remotes.ChangeBodyColor:FireServer(tostring(BodyColors.HeadColor))
		end

		if tonumber(AppliedDescription1.IdleAnimation) then
			Remotes.Wear:InvokeServer(AppliedDescription1.IdleAnimation)
		end

		local PlayersBag = v1:FindFirstChild("PlayersBag")

		if PlayersBag then
			if PlayersBag:FindFirstChild("RPName") and PlayersBag.RPName.Value ~= "" then
				Remotes.RPNameText:FireServer("RolePlayName", PlayersBag.RPName.Value)
			end

			if PlayersBag:FindFirstChild("RPBio") and PlayersBag.RPBio.Value ~= "" then
				Remotes.RPNameText:FireServer("RolePlayBio", PlayersBag.RPBio.Value)
			end

			if PlayersBag:FindFirstChild("RPNameColor") then
				Remotes.RPNameColor:FireServer("PickingRPNameColor", PlayersBag.RPNameColor.Value)
			end

			if PlayersBag:FindFirstChild("RPBioColor") then
				Remotes.RPNameColor:FireServer("PickingRPBioColor", PlayersBag.RPBioColor.Value)
			end
		end
	end, "COPY AVATAR"

	Tab4:AddButton(tbl18)
	local flag2 = false
	local flag3 = false
	local flag4 = false
	local num = 1
	Tab4:AddSection({"HSV RGB"})

	Tab4:AddToggle({
		Name = "NAME RGB (HSV)",
		Default = false,
		Callback = function(value)
			flag2 = value
		end,
	})

	Tab4:AddToggle({
		Name = "BIO RGB (HSV)",
		Default = false,
		Callback = function(value)
			flag3 = value
		end,
	})

	Tab4:AddToggle({
		Name = "BODY RGB (HSV)",
		Default = false,
		Callback = function(value)
			flag4 = value
		end,
	})

	Tab4:AddTextBox({
		Name = "RGB SPEED",
		Description = "Adjust rainbow cycle speed",
		PlaceholderText = "1",
		Callback = function(value)
			local num1 = tonumber(value)
			if num1 and num1 > 0 then
				num = num1
			end
		end,
	})

	task.spawn(function()
		local num1 = 0
		while true do
			task.wait(0.05)
			if flag4 or flag2 or flag3 then
				num1 = (num1 + 0.01 * num) % 1
				local v1 = Color3.fromHSV(num1, 1, 1)
				local brickColor = BrickColor.new(v1)

				if flag4 then
					Remotes.ChangeBodyColor:FireServer(brickColor.Name)
				end

				if flag2 then
					game:GetService("ReplicatedStorage").RE["1RPNam1eColo1r"]:FireServer("PickingRPNameColor", v1)
				end

				if flag3 then
					game:GetService("ReplicatedStorage").RE["1RPNam1eColo1r"]:FireServer("PickingRPBioColor", v1)
				end
			end
		end
	end)

	local tbl19 = {Color3.fromRGB(255, 0, 0), Color3.fromRGB(0, 0, 0), Color3.fromRGB(255, 255, 255)}
	local flag5 = false
	local flag6 = false
	local flag7 = false
	local num1 = 0.7
	local _1RPNam1eColo1r1 = game:GetService("ReplicatedStorage"):WaitForChild("RE"):WaitForChild("1RPNam1eColo1r")
	Tab4:AddSection({"TY hub RGB"})

	Tab4:AddToggle({
		Name = "NAME RGB (RBW)",
		Default = false,
		Callback = function(value)
			flag5 = value
		end,
	})

	Tab4:AddToggle({
		Name = "BIO RGB (RBW)",
		Default = false,
		Callback = function(value)
			flag6 = value
		end,
	})

	Tab4:AddToggle({
		Name = "BODY RGB (RBW)",
		Default = false,
		Callback = function(value)
			flag7 = value
		end,
	})

	Tab4:AddTextBox({
		Name = "RGB SPEED (RBW)",
		Description = "Set the color shifting delay interval",
		PlaceholderText = tostring(0.7),
		Callback = function(value)
			local num = tonumber(value)
			if num and num > 0.05 then
				num1 = num
			end
		end,
	})

	task.spawn(function()
		local num = 1
		while true do
			task.wait(num1)
			if flag5 or flag6 or flag7 then
				num = num % #tbl19 + 1
				local v1 = tbl19[num]

				if flag5 then
					pcall(function()
						_1RPNam1eColo1r1:FireServer("PickingRPNameColor", v1)
					end)
				end

				if flag6 then
					pcall(function()
						_1RPNam1eColo1r1:FireServer("PickingRPBioColor", v1)
					end)
				end

				if flag7 then
					pcall(function()
						local brickColor = BrickColor.new(v1)
						Remotes.ChangeBodyColor:FireServer(brickColor.Name)
					end)
				end
			end
		end
	end)
end

local Tab5, Players4, SoundService2, v1, tbl49, tbl50

do
	local tbl20 = {
		{"ANONYMOUS", " ANONYMOUS "},
		{"PRO PLAYER", " PRO PLAYER "},
		{"ERROR 666", " ERROR 666 "},
		{"GHOST", " GHOST "},
		{"JOKER", " JOKER "},
		{"ADMIN", " ADMIN "},
		{"TUBERS 93", " TUBERS 93 "},
		{"TY hub MEMBER", " TY hub MEMBER "},
		{"TY hub COMMUNITY", " TY hub COMMUNITY "},
		{"ADMIN TY hub", " ADMIN TY hub "},
	}

	local v9
	Tab4:AddSection({"RP Names"})

	Tab4:AddDropdown({
		Name = "SELECT RP NAME",
		Description = "Choose an identity",
		Options = (function()
			local tbl = {}

			for _, v1 in ipairs(tbl20) do
				table.insert(tbl, v1[1])
			end

			return tbl
		end)(),
		Default = tbl20[1][1],
		Callback = function(value)
			for _, v1 in ipairs(tbl20) do
				if v1[1] == value then
					v9 = v1[2]
				end
			end
		end,
	})

	local tbl21 = {}

	tbl21[1], tbl21[2] = "APPLY RP NAME", function()
		if not v9 then
			return
		end
		game:GetService("ReplicatedStorage").RE["1RPNam1eTex1t"]:FireServer("RolePlayName", v9)
	end

	Tab4:AddButton(tbl21)
	Tab4:AddSection({"Clothes"})
	local tbl22 = {}

	tbl22[2], tbl22[1] = function()
		Remotes.WearShirt:InvokeServer(101480394255855)
	end, "TY hub COMMUNITY SHIRT"

	Tab4:AddButton(tbl22)
	local tbl23 = {}

	tbl23[2], tbl23[1] = function()
		Remotes.WearPants:InvokeServer(124684324540170)
	end, "TY hub COMMUNITY PANTS"

	Tab4:AddButton(tbl23)
	Tab4:AddSection({"Itens"})
	local tbl24 = {}

	tbl24[2], tbl24[1] = function()
		Remotes.Wear:InvokeServer(14994946752)
	end, "SCARY HEAD"

	Tab4:AddButton(tbl24)
	local tbl25 = {}

	tbl25[2], tbl25[1] = function()
		Remotes.Wear:InvokeServer(98235263954323)
	end, "SCARY BRO 1"

	Tab4:AddButton(tbl25)
	local tbl26 = {}

	tbl26[1], tbl26[2] = "SCARY BRO 2", function()
		Remotes.Wear:InvokeServer(87859729921468)
	end

	Tab4:AddButton(tbl26)
	Tab4:AddSection({"Morphs"})
	local v10

	Tab4:AddDropdown({
		Name = "SELECT MORPH",
		Description = "Choose a morph to transform into",
		Options = {
			"SCP 096",
			"SCP 173",
			"SID",
			"WORM BRO",
			"TUNG TUNG TUNG SAHUR",
			"BIG GUY",
			"DOJE",
			"DUCK",
			"SQUIRREL",
			"BROWN CHICKEN",
			"GIGA CHAD",
			"KAWASAKI",
			"MIKE WAZOWSKI",
			"MONKEY",
			"PIGEON",
		},
		Default = "",
		Callback = function(value)
			v10 = value
		end,
	})

	local tbl27 = {}

	tbl27[1], tbl27[2] = "EQUIP", function()
		if not v10 then
			return
		end
		if v10 == "SCP 096" then
			loadstring(game:HttpGet("https://raw.githubusercontent.com/THEMRREDBLACK/RED-BLACK-HUB-BROOCKHAVEN-Lg/main/SCP%20096"))()
		elseif v10 == "SCP 173" then
			loadstring(game:HttpGet("https://raw.githubusercontent.com/THEMRREDBLACK/RED-BLACK-HUB-BROOCKHAVEN-Lg/main/SCP%20173"))()
		elseif v10 == "SID" then
			loadstring(game:HttpGet("https://raw.githubusercontent.com/THEMRREDBLACK/RED-BLACK-HUB-BROOCKHAVEN-Lg/main/SID"))()
		elseif v10 == "WORM BRO" then
			loadstring(game:HttpGet("https://raw.githubusercontent.com/THEMRREDBLACK/RED-BLACK-HUB-BROOCKHAVEN-Lg/main/WORM%20BRO"))()
		elseif v10 == "TUNG TUNG TUNG SAHUR" then
			loadstring(game:HttpGet("https://raw.githubusercontent.com/THEMRREDBLACK/RED-BLACK-HUB-BROOCKHAVEN-Lg/main/TUNG%20TUNG%20TUNG%20SAHUR"))()
		elseif v10 == "BIG GUY" then
			loadstring(game:HttpGet("https://raw.githubusercontent.com/THEMRREDBLACK/RED-BLACK-HUB-BROOCKHAVEN-Lg/refs/heads/main/BIG%20GUY"))()
		elseif v10 == "DOJE" then
			loadstring(game:HttpGet("https://raw.githubusercontent.com/THEMRREDBLACK/RED-BLACK-HUB-BROOCKHAVEN-Lg/refs/heads/main/DOJE"))()
		elseif v10 == "DUCK" then
			loadstring(game:HttpGet("https://raw.githubusercontent.com/THEMRREDBLACK/RED-BLACK-HUB-BROOCKHAVEN-Lg/refs/heads/main/DUCK"))()
		elseif v10 == "SQUIRREL" then
			loadstring(game:HttpGet("https://raw.githubusercontent.com/THEMRREDBLACK/RED-BLACK-HUB-BROOCKHAVEN-Lg/refs/heads/main/ESQUILO"))()
		elseif v10 == "BROWN CHICKEN" then
			loadstring(game:HttpGet("https://raw.githubusercontent.com/THEMRREDBLACK/RED-BLACK-HUB-BROOCKHAVEN-Lg/refs/heads/main/GALINHA"))()
		elseif v10 == "GIGA CHAD" then
			loadstring(game:HttpGet("https://raw.githubusercontent.com/THEMRREDBLACK/RED-BLACK-HUB-BROOCKHAVEN-Lg/refs/heads/main/GIGA%20CHAD"))()
		elseif v10 == "KAWASAKI" then
			loadstring(game:HttpGet("https://raw.githubusercontent.com/THEMRREDBLACK/RED-BLACK-HUB-BROOCKHAVEN-Lg/refs/heads/main/KAVAZAKI"))()
		elseif v10 == "MIKE WAZOWSKI" then
			loadstring(game:HttpGet("https://raw.githubusercontent.com/THEMRREDBLACK/RED-BLACK-HUB-BROOCKHAVEN-Lg/refs/heads/main/MAIKI"))()
		elseif v10 == "MONKEY" then
			loadstring(game:HttpGet("https://raw.githubusercontent.com/THEMRREDBLACK/RED-BLACK-HUB-BROOCKHAVEN-Lg/refs/heads/main/MONKEY"))()
		elseif v10 == "PIGEON" then
			loadstring(game:HttpGet("https://raw.githubusercontent.com/THEMRREDBLACK/RED-BLACK-HUB-BROOCKHAVEN-Lg/refs/heads/main/PINGEON"))()
		end
	end

	Tab4:AddButton(tbl27)
	Tab4:AddSection({"Legs & Heads"})

	local function func10(arg1)
		if not LocalPlayer1 or not LocalPlayer1.Character or not Remotes then
			return
		end
		pcall(function()
			for _, v1 in ipairs(arg1) do
				Remotes.Wear:InvokeServer(v1)
				task.wait(0.15)
			end
		end)
	end

	local tbl28 = {}

	tbl28[2], tbl28[1] = function()
		func10({139572789})
	end, "ICE LEG"

	Tab4:AddButton(tbl28)
	local tbl29 = {}

	tbl29[1], tbl29[2] = "HEADLESS", function()
		func10({15093053680})
	end

	Tab4:AddButton(tbl29)
	local tbl30 = {}

	tbl30[2], tbl30[1] = function()
		func10({86681341524412})
	end, "ZOMBIE LEG"

	Tab4:AddButton(tbl30)
	Tab4:AddSection({"ACCESSORIES"})
	local tbl31 = {}

	local function func11(arg1)
		if not LocalPlayer1 or not LocalPlayer1.Character or not Remotes then
			return
		end
		pcall(function()
			for _, v1 in ipairs(arg1) do
				Remotes.Wear:InvokeServer(v1)
				task.wait(0.15)
			end
		end)
	end

	tbl31[2], tbl31[1] = function()
		func11({48545806})
	end, "DOMINUS FRIGIDUS"

	Tab4:AddButton(tbl31)
	local tbl32 = {}

	tbl32[2], tbl32[1] = function()
		func11({4255053867})
	end, "DOMINUS FORMIDULOSUS"

	Tab4:AddButton(tbl32)
	local tbl33 = {}

	tbl33[1], tbl33[2] = "DOMINUS PRAEFECTUS", function()
		func11({527365852})
	end

	Tab4:AddButton(tbl33)
	local tbl34 = {}

	tbl34[2], tbl34[1] = function()
		func11({64444871})
	end, "DOMINUS MESSOR"

	Tab4:AddButton(tbl34)
	local tbl35 = {}

	tbl35[1], tbl35[2] = "DOMINUS VESPERTILIO", function()
		func11({96103379})
	end

	Tab4:AddButton(tbl35)
	local tbl36 = {}

	tbl36[1], tbl36[2] = "DOMINUS REX", function()
		func11({250395631})
	end

	Tab4:AddButton(tbl36)
	local tbl37 = {}

	tbl37[1], tbl37[2] = "DOMINUS EMPYREUS FVM", function()
		func11({151789690})
	end

	Tab4:AddButton(tbl37)
	local tbl38 = {}

	tbl38[1], tbl38[2] = "DOMINUS AUREUS", function()
		func11({138932314})
	end

	Tab4:AddButton(tbl38)
	local tbl39 = {}

	tbl39[1], tbl39[2] = "DOMINUS PITTACIUM", function()
		func11({335080779})
	end

	Tab4:AddButton(tbl39)
	local tbl40 = {}

	tbl40[2], tbl40[1] = function()
		func11({31101391})
	end, "DOMINUS INFERNUS"

	Tab4:AddButton(tbl40)
	local tbl41 = {}

	tbl41[2], tbl41[1] = function()
		func11({21070012})
	end, "DOMINUS EMPYREUS"

	Tab4:AddButton(tbl41)
	local tbl42 = {}

	tbl42[2], tbl42[1] = function()
		func11({1028859})
	end, "PIRATE CAPTAIN HAT"

	Tab4:AddButton(tbl42)
	local tbl43 = {}

	tbl43[2], tbl43[1] = function()
		func11({17450053})
	end, "P SINISTER"

	Tab4:AddButton(tbl43)
	local tbl44 = {}

	tbl44[2], tbl44[1] = function()
		func11({4765718})
	end, "RIDDLE SKULL"

	Tab4:AddButton(tbl44)
	local tbl45 = {}

	tbl45[1], tbl45[2] = "MAD COW", function()
		func11({14673292})
	end

	Tab4:AddButton(tbl45)
	local tbl46 = {}

	tbl46[2], tbl46[1] = function()
		func11({232492903})
	end, "CLOCKWORK FVM"

	Tab4:AddButton(tbl46)
	local tbl47 = {}

	tbl47[2], tbl47[1] = function()
		func11({37819478})
	end, "S SINISTER"

	Tab4:AddButton(tbl47)
	local tbl48 = {}

	tbl48[1], tbl48[2] = "THE EARTH", function()
		func11({10072631})
	end

	Tab4:AddButton(tbl48)
	Tab5 = Window:MakeTab({"SOUND FE", "volume-2"})
	Players4 = game:GetService("Players")
	local ReplicatedStorage1 = game:GetService("ReplicatedStorage")
	SoundService2 = game:GetService("SoundService")
	v1 = ReplicatedStorage1:FindFirstChild("RE") and ReplicatedStorage1.RE:FindFirstChild("1Gu1n")

	tbl49 = {
		["ACORDA CARA"] = "132075790196708",
		["AI AI AI"] = "102142653012088",
		["AI MEU CU"] = "77323725369301",
		["AI MEU CUSINHO"] = "130714479795369",
		AINN = "74358279488646",
		["AMONG US SOUND"] = "101769410694203",
		["CHIKEN SCREAM"] = "81891427788694",
		["CRAZY LAUGH"] = "77714239767930",
		["DIE FORTNITE"] = "72536455880966",
		["FAH LOUD"] = "103246819698741",
		["GET OUT"] = "17580996350",
		["LIE DETECTOR"] = "117916446144888",
		["LOOP BEEP SOUND"] = "6486261822",
		LOUD = "108451658708095",
		["LOW HONOR"] = "130127279575145",
		["MAXBELL LOUD"] = "87057617171460",
		["METAL PIPE"] = "105380085265556",
		["NECK HURTS"] = "90409807315293",
		["NUKE ALARM"] = "433848566",
		["REAL LOUD"] = "131682359704129",
		RECEBA = "124730309404073",
		["RICA GAMES"] = "99527688030094",
		SAMSUNG = "6879335951",
		["SCARY SOUND"] = "6516011433",
		["SCARY SREAM"] = "111272255398192",
		["SUS SCREAM"] = "76571808089308",
		["TROLL LAUGH"] = "73753120048787",
		["VDSMA CARLINHOS"] = "135212564271817",
		["WHATSAPP SFX"] = "99752719862687",
		["WHITER WHITE+BREAKING BONE"] = "120161868796643",
		["WINDOWS NOTIF"] = "2389339814",
	}

	tbl50 = {}
end

local LocalPlayer3

do
	for k in pairs(tbl49) do
		table.insert(tbl50, k)
	end

	table.sort(tbl50)
	local str2 = ""
	local v2 = tbl49["GET OUT"] or "17580996350"
	local num2 = 0.1
	local num3 = 0.1
	local str3 = ""
	local str4 = ""
	local flag8 = false
	local flag9 = false
	local flag10 = false
	local flag11 = false

	local function func12(arg1)
		if not arg1 or arg1 == "" then
			return
		end

		local sound = Instance.new("Sound")
		sound.SoundId = "rbxassetid://" .. tostring(arg1)
		sound.Volume = 0.5
		sound.Parent = SoundService2
		sound:Play()

		task.delay(2.5, function()
			if sound then
				sound:Destroy()
			end
		end)
	end

	local function func13(player, arg2)
		if not player or not player.Character or not v1 then
			return
		end

		local HumanoidRootPart = player.Character:FindFirstChild("HumanoidRootPart")

		if not HumanoidRootPart then
			return
		end

		pcall(function()
			local vector3 = Vector3.new(0, 0, 0)
			local vector31 = Vector3.new(0, 0, 0)
			local num = tonumber(arg2)
			local num1 = tonumber(arg2)
			local tbl = {true}
			local vector32 = Vector3.new(100, 100, 100)
			local tbl1 = {}
			tbl1[1], tbl1[3], tbl1[2], tbl1[5], tbl1[4], tbl1[6] = 100000, BrickColor.new(24), vector32, Enum.Material.SmoothPlastic, 100, 100

			v1:FireServer(
				workspace,
				HumanoidRootPart,
				vector3,
				vector31,
				workspace,
				workspace,
				num,
				num1,
				tbl,
				tbl1,
				false,
				false
			)
		end)
	end

	local function func14(arg1)
		if not arg1 or arg1 == "" then
			return nil
		end

		local v1 = string.lower(arg1)

		for _, player in ipairs(Players4:GetPlayers()) do
			local v2 = string.lower(player.Name)
			local v3 = string.lower(player.DisplayName)

			if string.find(v2, v1, 1, true) or string.find(v3, v1, 1, true) then
				return player
			end
		end

		return nil
	end

	local function func15(arg1)
		if not arg1 or arg1 == "" or not tonumber(arg1) then
			return
		end

		task.spawn(func12, arg1)
		local Players = Players4:GetPlayers()

		for _, Player in ipairs(Players) do
			if Player and Player.Character and v1 then
				local HumanoidRootPart = Player.Character:FindFirstChild("HumanoidRootPart")
				if HumanoidRootPart then
					pcall(function()
						local vector3 = Vector3.new(0, 0, 0)
						local vector31 = Vector3.new(0, 0, 0)
						local num = tonumber(arg1)
						local num1 = tonumber(arg1)
						local tbl = {true}
						local vector32 = Vector3.new(100, 100, 100)
						local tbl1 = {}
						tbl1[1], tbl1[3], tbl1[2], tbl1[5], tbl1[4], tbl1[6] = 100000, BrickColor.new(24), vector32, Enum.Material.SmoothPlastic, 100, 100

						v1:FireServer(
							workspace,
							HumanoidRootPart,
							vector3,
							vector31,
							workspace,
							workspace,
							num,
							num1,
							tbl,
							tbl1,
							false,
							false
						)
					end)
				end
			end
			task.wait(0.2)
		end
	end

	local function func16(arg1, arg2)
		if not arg1 or arg1 == "" or not tonumber(arg1) then
			return
		end

		local v1 = func14(arg2)

		if v1 then
			func13(v1, arg1)
		end
	end

	Tab5:AddSection("CUSTOM AUDIO")

	Tab5:AddTextBox({
		Title = "CUSTOM AUDIO ID",
		Desc = "ENTER CUSTOM AUDIO ID",
		Default = "",
		PlaceholderText = "< PASTE ID HERE >",
		ClearText = false,
		Callback = function(value)
			str2 = value
		end,
	})

	Tab5:AddTextBox({
		Title = "CUSTOM LOOP COOLDOWN",
		Desc = "LOOP WAIT TIME IN SECONDS",
		Default = "0.1",
		PlaceholderText = "< EX: 0.1 >",
		ClearText = false,
		Callback = function(value)
			local num = tonumber(value)
			if num then
				num2 = num
			end
		end,
	})

	Tab5:AddButton({
		Title = "SOUND ALL (CUSTOM)",
		Callback = function()
			task.spawn(func15, str2)
		end,
	})

	Tab5:AddToggle({
		Title = "LOOP SOUND ALL (CUSTOM)",
		Default = false,
		Callback = function(value)
			flag8 = value
			if flag8 then
				task.spawn(function()
					while flag8 do
						if str2 == "" or not tonumber(str2) then
							flag8 = false
							break
						end

-- https://lua-x.online
						func15(str2)
						task.wait(num2)
					end
				end)
			end
		end,
	})

	Tab5:AddTextBox({
		Title = "TARGET PLAYER (CUSTOM)",
		Desc = "ENTER PLAYER NAME OR DISPLAY NAME",
		Default = "",
		PlaceholderText = "< PLAYER NAME >",
		ClearText = false,
		Callback = function(value)
			str3 = value
		end,
	})

	Tab5:AddButton({
		Title = "SOUND TARGET (CUSTOM)",
		Callback = function()
			func16(str2, str3)
		end,
	})

	Tab5:AddToggle({
		Title = "LOOP SOUND TARGET (CUSTOM)",
		Default = false,
		Callback = function(value)
			flag10 = value
			if flag10 then
				task.spawn(function()
					while flag10 do
						if str2 == "" or not tonumber(str2) then
							flag10 = false
							break
						end

						local v1 = str2
						local v2 = str3

						if v1 and v1 ~= "" and tonumber(v1) then
							local v3 = func14(v2)
							if v3 then
								func13(v3, v1)
							end
						end

						task.wait(num2)
					end
				end)
			end
		end,
	})

	Tab5:AddSection("PRESET AUDIO")

	Tab5:AddDropdown({
		Title = "SELECT PRESET AUDIO",
		Desc = "CHOOSE AN AUDIO FROM THE LIST",
		Options = tbl50,
		Default = "GET OUT",
		Callback = function(value)
			v2 = tbl49[value] or ""
		end,
	})

	Tab5:AddTextBox({
		Title = "PRESET LOOP COOLDOWN",
		Desc = "LOOP WAIT TIME IN SECONDS",
		Default = "0.1",
		PlaceholderText = "< EX: 0.1 >",
		ClearText = false,
		Callback = function(value)
			local num = tonumber(value)
			if num then
				num3 = num
			end
		end,
	})

	Tab5:AddButton({
		Title = "SOUND ALL (PRESET)",
		Callback = function()
			task.spawn(func15, v2)
		end,
	})

	Tab5:AddToggle({
		Title = "LOOP SOUND ALL (PRESET)",
		Default = false,
		Callback = function(value)
			flag9 = value
			if flag9 then
				task.spawn(function()
					while flag9 do
						if v2 == "" or not tonumber(v2) then
							flag9 = false
							break
						end

						func15(v2)
						task.wait(num3)
					end
				end)
			end
		end,
	})

	Tab5:AddTextBox({
		Title = "TARGET PLAYER (PRESET)",
		Desc = "ENTER PLAYER NAME OR DISPLAY NAME",
		Default = "",
		PlaceholderText = "< PLAYER NAME >",
		ClearText = false,
		Callback = function(value)
			str4 = value
		end,
	})

	Tab5:AddButton({
		Title = "SOUND TARGET (PRESET)",
		Callback = function()
			func16(v2, str4)
		end,
	})

	Tab5:AddToggle({
		Title = "LOOP SOUND TARGET (PRESET)",
		Default = false,
		Callback = function(value)
			flag11 = value
			if flag11 then
				task.spawn(function()
					while flag11 do
						if v2 == "" or not tonumber(v2) then
							flag11 = false
							break
						end

						local v1 = v2
						local v3 = str4

						if v1 and v1 ~= "" and tonumber(v1) then
							local v4 = func14(v3)
							if v4 then
								func13(v4, v1)
							end
						end

						task.wait(num3)
					end
				end)
			end
		end,
	})

	local Tab6 = Window:MakeTab({"CHAT", "message-square"})
	game:GetService("Players")
	local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
	local TextChatService = game:GetService("TextChatService")
	local str5 = ""
	local flag12 = false
	local num4 = 0.5
	Tab6:AddSection({"Chat Spammer"})

	Tab6:AddTextBox({
		Name = "MESSAGE",
		Description = "Enter message to spam",
		PlaceholderText = "Type message here...",
		Callback = function(value)
			str5 = tostring(value)
		end,
	})

	Tab6:AddTextBox({
		Name = "SPAM COOLDOWN",
		Description = "Set interval in seconds",
		PlaceholderText = "0.5",
		Callback = function(value)
			local num = tonumber(value)
			if num and num > 0 then
				num4 = num
			end
		end,
	})

	Tab6:AddToggle({
		Name = "SPAM CHAT",
		Default = false,
		Callback = function(value)
			flag12 = value
			if flag12 then
				task.spawn(function()
					while flag12 and str5 ~= "" do
						pcall(function()
							if TextChatService.ChatVersion == Enum.ChatVersion.TextChatService then
								local RBXGeneral = TextChatService.TextChannels:FindFirstChild("RBXGeneral")
								if RBXGeneral then
									RBXGeneral:SendAsync(str5)
								end
							else
								local DefaultChatSystemChatEvents = ReplicatedStorage2:FindFirstChild("DefaultChatSystemChatEvents")
								if DefaultChatSystemChatEvents and DefaultChatSystemChatEvents:FindFirstChild("SayMessageRequest") then
									DefaultChatSystemChatEvents.SayMessageRequest:FireServer(str5, "All")
								end
							end
						end)
						task.wait(num4)
					end
				end)
			end
		end,
	})

	local Tab7 = Window:MakeTab({"PLAYER", "user"})
	Tab7:AddSection({"Basic Functions"})
	local tbl51 = {}

	tbl51[2], tbl51[1] = function()
		loadstring(game:HttpGet("https://raw.githubusercontent.com/THEMRREDBLACK/FLY-GUI/refs/heads/main/README.md"))()
	end, "FLY GUI"

	Tab7:AddButton(tbl51)
	local tbl52 = {}

	tbl52[2], tbl52[1] = function()
		local Character = LocalPlayer1.Character
		if Character then
			local Humanoid = Character:FindFirstChildOfClass("Humanoid")
			if Humanoid then
				Humanoid.Health = 0
			else
				Character:BreakJoints()
			end
		end
	end, "RESET"

	Tab7:AddButton(tbl52)
	local Players5 = game:GetService("Players")
	local RunService1 = game:GetService("RunService")
	local Workspace = game:GetService("Workspace")
	LocalPlayer3 = Players5.LocalPlayer
	local flag13 = false
	local connection1
	local num5 = 90
	local num6 = 30
	local num7 = 60
	local v3 = Workspace.Gravity or 196.2

	local function func17()
		local Character = LocalPlayer3.Character

		if not Character then
			return nil, nil
		end

		return Character, (Character:FindFirstChildOfClass("Humanoid"))
	end

	local function func18()
		if flag13 then
			return
		end

		flag13 = true

		if connection1 then
			pcall(function()
				connection1:Disconnect()
			end)
		end

		connection1 = RunService1.Heartbeat:Connect(function(deltaTime)
			if not flag13 then
				return
			end

			local Character = LocalPlayer3.Character

			if not Character then
				return
			end

			local HumanoidRootPart = Character:FindFirstChild("HumanoidRootPart")

			if HumanoidRootPart then
				local v1 = math.rad(num5 * deltaTime)
				pcall(function()
					HumanoidRootPart.CFrame = HumanoidRootPart.CFrame * CFrame.Angles(0, v1, 0)
				end)
			end
		end)
	end

	local function func19()
		flag13 = false
		if connection1 then
			pcall(function()
				connection1:Disconnect()
			end)
			connection1 = nil
		end
	end

	local CharacterAdded = LocalPlayer3.CharacterAdded

	local function func20(arg1)
		if arg1 == nil then
			if flag13 then
				func19()
			else
				func18()
			end
		elseif arg1 then
			func18()
		else
			func19()
		end
	end

	CharacterAdded:Connect(function(character)
		task.defer(function()
			local v1 = character:WaitForChild("Humanoid", 5) or character:FindFirstChildOfClass("Humanoid")

			if v1 then
				pcall(function()
					v1.WalkSpeed = num6
				end)
				pcall(function()
					v1.JumpPower = num7
				end)
			end

			if flag13 then
				func18()
			end
		end)
	end)

	Tab7:AddToggle({
		Name = "SPIN",
		Default = false,
		Callback = function(value)
			func20(value)
		end,
	})

	Tab7:AddSlider({
		Name = "SPIN SPEED",
		Min = 10,
		Max = 500,
		Default = num5,
		Increase = 5,
		Callback = function(value)
			num5 = value
		end,
	})

	Tab7:AddSlider({
		Name = "WALK SPEED",
		Min = 16,
		Max = 300,
		Default = num6,
		Increase = 1,
		Callback = function(value)
			num6 = value
			local _, v1 = func17()

			if v1 then
				v1.WalkSpeed = num6
			end
		end,
	})

	Tab7:AddSlider({
		Name = "JUMP POWER",
		Min = 50,
		Max = 400,
		Default = num7,
		Increase = 1,
		Callback = function(value)
			num7 = value
			local _, v1 = func17()

			if v1 then
				v1.JumpPower = num7
			end
		end,
	})

	Tab7:AddSlider({
		Name = "GRAVITY",
		Min = 0,
		Max = 196,
		Default = math.floor(v3),
		Increase = 1,
		Callback = function(value)
			v3 = value
			Workspace.Gravity = v3
		end,
	})

	local flag14 = false
	local connection2

	local function func21()
		if flag14 then
			return
		end

		flag14 = true

		connection2 = RunService1.Stepped:Connect(function()
			if LocalPlayer3.Character then
				for _, descendant in ipairs(LocalPlayer3.Character:GetDescendants()) do
					if descendant:IsA("BasePart") then
						pcall(function()
							descendant.CanCollide = false
						end)
					end
				end
			end
		end)
	end

	local function func22()
		if not flag14 then
			return
		end

		flag14 = false

		if connection2 then
			connection2:Disconnect()
			connection2 = nil
		end
	end

	Tab7:AddToggle({
		Name = "NOCLIP",
		Default = false,
		Callback = function(value)
			if value then
				func21()
			else
				func22()
			end
		end,
	})
end

do
	local Tab8 = Window:MakeTab({"PROTECTIONS", "shield"})

	Tab8:AddToggle({
		Name = "ANTI SIT",
		Default = false,
		Callback = function(value)
			if value then
				task.spawn(function()
					local num = 0
					for _, descendant in pairs(game:GetService("Workspace"):GetDescendants()) do
						if descendant:IsA("Seat") or descendant:IsA("VehicleSeat") then
							pcall(function()
								descendant:Destroy()
							end)
						end

						num = num + 1

						if num >= 100 then
							num = 0
							task.wait()
						end
					end
				end)
				getgenv().AntiSeatLoop = game:GetService("Workspace").DescendantAdded:Connect(function(descendant)
					if descendant:IsA("Seat") or descendant:IsA("VehicleSeat") then
						task.wait()
						pcall(function()
							descendant:Destroy()
						end)
					end
				end)
			elseif getgenv().AntiSeatLoop then
				getgenv().AntiSeatLoop:Disconnect()
				getgenv().AntiSeatLoop = nil
			end
		end,
	})

	Tab8:AddToggle({
		Name = "ANTI VOID",
		Default = false,
		Callback = function(value)
			if value then
				getgenv().AntiVoidLoop = game:GetService("RunService").Heartbeat:Connect(function()
					pcall(function()
						local HumanoidRootPart = game:GetService("Players").LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
						if HumanoidRootPart and HumanoidRootPart.Position.Y <= -450 then
							HumanoidRootPart.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
							HumanoidRootPart.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
							HumanoidRootPart.CFrame = CFrame.new(0, 50, 0)
						end
					end)
				end)
			elseif getgenv().AntiVoidLoop then
				getgenv().AntiVoidLoop:Disconnect()
				getgenv().AntiVoidLoop = nil
			end
		end,
	})

	Tab8:AddToggle({
		Name = "ANTI BANANA",
		Default = false,
		Callback = function(value)
			if value then
				task.spawn(function()
					local num = 0
					for _, descendant in pairs(game:GetService("Workspace"):GetDescendants()) do
						if descendant:IsA("Model") and string.find(descendant.Name, "BananaPeel") then
							pcall(function()
								descendant:Destroy()
							end)
						end

						num = num + 1

						if num >= 100 then
							num = 0
							task.wait()
						end
					end
				end)
				getgenv().AntiBananaLoop = game:GetService("Workspace").DescendantAdded:Connect(function(descendant)
					if descendant:IsA("Model") and string.find(descendant.Name, "BananaPeel") then
						task.wait()
						pcall(function()
							descendant:Destroy()
						end)
					end
				end)
			elseif getgenv().AntiBananaLoop then
				getgenv().AntiBananaLoop:Disconnect()
				getgenv().AntiBananaLoop = nil
			end
		end,
	})

	local Tab9 = Window:MakeTab({"TOOLS/NUKES", "hammer"})
	local ReplicatedStorage3 = game:GetService("ReplicatedStorage")
	local RunService2 = game:GetService("RunService")
	local Players6 = game:GetService("Players")
	local LocalPlayer4 = Players6.LocalPlayer
	local _1Too1l = ReplicatedStorage3:WaitForChild("RE"):WaitForChild("1Too1l")
	local v4 = ReplicatedStorage3:FindFirstChild("RE") and ReplicatedStorage3.RE:FindFirstChild("PCollisionPatch")

	local tbl53 = {
		"Summer2026StickySituation",
		"Phone",
		"Tablet",
		"PropMaker",
		"GeigerCounter",
		"Paperbag",
		"Laptop",
		"ShoppingCart",
		"Parcel",
		"Sign",
		"Newspaper",
		"ClipBoard",
		"Score Card",
		"Book",
		"Paper",
		"Envelope",
		"Ticket",
		"Licence",
		"BabyBoy",
		"BabyGirl",
		"BabyBottle",
		"BabyRattle",
		"Stretcher",
		"MedicalGloves",
		"VetMedicine",
		"Stethoscope",
		"Medicine",
		"MedicalSpray",
		"MedicalDropper",
		"Ear",
		"Toothbrush",
		"Hairbrush",
		"Trophy",
		"CarryOn",
		"PlaneTicket",
		"SWATShield",
		"Baton",
		"RiotShield",
		"Cuffs",
		"Taser",
		"Katana",
		"SwordWood",
		"PrisonShank",
		"Bow",
		"Bomb",
		"Sceptre",
		"RoyalScroll",
		"DuffleBag",
		"DuffleBagMoney",
		"Money",
		"CreditCardBoy",
		"CreditCardGirl",
		"Binocks",
		"ScannerWand",
		"HandRadio",
		"GhostMeter",
		"FlashLight",
		"Candle",
		"Marshmello",
		"SleepingBag",
		"TinCup",
		"FishingRod",
		"Umbrella",
		"Summer2026JugglingBalls",
		"Present",
		"Boombox",
		"Lipstick",
		"Roses",
		"Summer2026MagicianHat",
		"Summer2026Glowstick",
		"PowderCompactBrush",
		"Megaphone",
		"Microphone",
		"Camcorder",
		"Axe",
		"Hammer",
		"Guitar",
		"ClapperBoard",
		"DSLR Camera",
		"ElectricGuitar",
		"Wrench",
		"FireX",
		"GlowingBatons",
		"Wheelbarrow",
		"Shovel",
		"Ladder",
		"StopSign",
		"LawnMower",
		"Bucket",
		"WateringCan",
		"LaundryBasket",
		"HorseBrush",
		"Vacuum",
		"Box",
		"Mop",
		"Summer2026Cannon",
		"Basketball",
		"WhistleAndRefereeCards",
		"SoccerBall",
		"Baseball",
		"YogaMat",
		"FoamFinger",
		"FoodCart",
		"SnackBox",
		"FoodTray",
		"Weights",
		"PomPoms",
	}

	local flag15 = false
	local flag16 = false

	Tab9:AddToggle({
		Name = "LAG SERVER",
		Default = false,
		Callback = function(value)
			flag15 = value
			if flag15 then
				task.spawn(function()
					while flag15 do
						for _, v1 in ipairs(tbl53) do
							if not flag15 then
								break
							end
							task.defer(function()
								if _1Too1l then
									_1Too1l:InvokeServer("PickingTools", v1)
								end
							end)
						end

						if v4 then
							task.defer(function()
								v4:FireServer("PCollisionPatch")
							end)
						end

						task.wait(0.01)
					end
				end)
			end
		end,
	})

	Tab9:AddButton({
		Name = "SHUT DOWN SERVER",
		Callback = function()
			if flag16 then
				return
			end

			flag16 = true
			local v1 = #tbl53
			local num = 1

			local function func(arg1)
				if not arg1 then
					return
				end

				arg1.ChildAdded:Connect(function(child)
					task.defer(child.Destroy, child)
				end)

				for _, child in ipairs(arg1:GetChildren()) do
					child:Destroy()
				end
			end

			if LocalPlayer4:FindFirstChild("Backpack") then
				func(LocalPlayer4.Backpack)
			end

			LocalPlayer4.ChildAdded:Connect(function(child)
				if child.Name == "Backpack" then
					func(child)
				end
			end)

			if LocalPlayer4.Character then
				func(LocalPlayer4.Character)
			end

			LocalPlayer4.CharacterAdded:Connect(func)

			task.spawn(function()
				while flag16 do
					for _ = 1, 35 do
						local v2 = tbl53[num]
						num = num % v1 + 1

						task.defer(function()
							if _1Too1l then
								_1Too1l:InvokeServer("PickingTools", v2)
							end
						end)
					end
					RunService2.Heartbeat:Wait()
				end
			end)
		end,
	})

	_G.RGB_Speed = 1
	_G.RGB_PaintActive = false
	_G.RGB_TorchActive = false
	Tab9:AddSection({"TOOLS"})

	Tab9:AddTextBox({
		Name = "RGB SPEED",
		Description = "Adjust rainbow cycle velocity",
		PlaceholderText = "1",
		Callback = function(value)
			local num = tonumber(value)
			if num then
				_G.RGB_Speed = num
			end
		end,
	})

	local tbl54 = {}

	tbl54[2], tbl54[1] = function()
		game:GetService("ReplicatedStorage"):WaitForChild("RE"):WaitForChild("1Too1l"):InvokeServer("PickingTools", "PaintRoller")
	end, "GET PAINT ROLLER"

	Tab9:AddButton(tbl54)

	Tab9:AddToggle({
		Name = "PAINT ROLLER RGB",
		Default = false,
		Callback = function(value)
			_G.RGB_PaintActive = value
			if value then
				task.spawn(function()
					local SetColor = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("ToolGui"):WaitForChild("ToolSettings"):WaitForChild("Settings"):WaitForChild("PropsColor"):WaitForChild("SetColor")
					while _G.RGB_PaintActive do
						local RGB_Speed = _G.RGB_Speed
						local v1 = tick() * ((RGB_Speed or 1) * 0.15)
						local v2 = v1 % 1
						local v3 = Color3.fromHSV(v2, 1, 1)

						pcall(function()
							SetColor:FireServer(v3)
						end)

						task.wait(0.12)
					end
				end)
			end
		end,
	})

	local tbl55 = {}

	tbl55[1], tbl55[2] = "GET TORCH", function()
		game:GetService("ReplicatedStorage"):WaitForChild("RE"):WaitForChild("1Too1l"):InvokeServer("PickingTools", "GuardTorch")
	end

	Tab9:AddButton(tbl55)

	Tab9:AddToggle({
		Name = "TORCH RGB",
		Default = false,
		Callback = function(value)
			_G.RGB_TorchActive = value
			if value then
				task.spawn(function()
					local SetColor = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("ToolGui"):WaitForChild("ToolSettings"):WaitForChild("Settings"):WaitForChild("PropsColor"):WaitForChild("SetColor")
					while _G.RGB_TorchActive do
						local RGB_Speed = _G.RGB_Speed
						local v1 = tick() * ((RGB_Speed or 1) * 0.15)
						local v2 = v1 % 1
						local v3 = Color3.fromHSV(v2, 1, 1)

						pcall(function()
							SetColor:FireServer(v3)
						end)

						task.wait(0.12)
					end
				end)
			end
		end,
	})

	local ReplicatedStorage4 = game:GetService("ReplicatedStorage")
	local v11

	local function func23()
		local tbl = {}

		if not LocalPlayer3.Character or not LocalPlayer3.Character:FindFirstChild("HumanoidRootPart") then
			return tbl
		end

		local Position = LocalPlayer3.Character.HumanoidRootPart.Position

		for _, player in ipairs(Players6:GetPlayers()) do
			if player ~= LocalPlayer3 and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
				if (player.Character.HumanoidRootPart.Position - Position).Magnitude <= 2000 then
					table.insert(tbl, player)
				end
			end
		end

		return tbl
	end

	local function func24(arg1)
		ReplicatedStorage4:WaitForChild("RE"):WaitForChild("1Playe1rTrigge1rEven1t"):FireServer(unpack({"ToolGiveToServer", arg1, "GuardTorch"}))
	end

	Tab9:AddToggle({
		Name = "AUTO GIVE TORCH (15 STUDS)",
		Default = false,
		Callback = function(value)
			if v11 then
				v11:Disconnect()
				v11 = nil
			end
			if value then
				v11 = RunService2.Heartbeat:Connect(function()
					for _, v1 in ipairs((func23())) do
						pcall(function()
							func24(v1)
						end)
					end
					task.wait(0.25)
				end)
			end
		end,
	})

	local Tab10 = Window:MakeTab({"HOUSES", "home"})
	local tbl56 = {}

	tbl56[2], tbl56[1] = function()
		for _, descendant in ipairs(workspace:GetDescendants()) do
			if descendant.Name == "BannedBlock" then
				descendant:Destroy()
			end
		end
	end, "REMOVE HOUSE BAN"

	Tab10:AddButton(tbl56)

	Tab10:AddToggle({
		Name = "AUTO REMOVE BAN",
		Default = false,
		Callback = function(value)
			_G.AutoUnbanActive = value
			if value then
				_G.BanMonitor = workspace.DescendantAdded:Connect(function(descendant)
					if _G.AutoUnbanActive and descendant.Name == "BannedBlock" then
						descendant:Destroy()
					end
				end)
			elseif _G.BanMonitor then
				_G.BanMonitor:Disconnect()
			end
		end,
	})

	local tbl57 = {Speed = 1, States = {}}

	local function func25()
		local v1 = tick() * tbl57.Speed % 5 / 5
		return Color3.fromHSV(v1, 1, 1)
	end

	local function func26(arg1)
		tbl57.States[arg1.StateKey] = true
		task.spawn(function()
			while tbl57.States[arg1.StateKey] do
				if not (game.Players.LocalPlayer and game.Players.LocalPlayer.Parent) then
					tbl57.States[arg1.StateKey] = false
					break
				end

				pcall(arg1.Action)
				task.wait(arg1.Delay)
			end
		end)
	end

	Tab10:AddSection({"RGB HOUSE"})

	Tab10:AddToggle({
		Name = "RGB HOUSE",
		Default = false,
		Callback = function(value)
			if value then
				func26({
					StateKey = "house",
					Delay = 0.1,
					Action = function()
						local v1 = func25()
						pcall(function()
							game.ReplicatedStorage.RE["1Player1sHous1e"]:FireServer("ColorPickHouse", v1)
						end)
					end,
				})
			else
				tbl57.States.house = false
			end
		end,
	})

	Tab10:AddTextBox({
		Name = "RGB SPEED",
		Description = "Set house rainbow transition velocity",
		PlaceholderText = "1",
		Callback = function(value)
			local num = tonumber(value)
			if num and num > 0 then
				tbl57.Speed = num
			end
		end,
	})

	local tbl58 = {
		Speed = 1,
		Enabled = false,
		Index = 1,
		Colors = {Color3.fromRGB(255, 0, 0), Color3.fromRGB(0, 0, 0), Color3.fromRGB(255, 255, 255)},
	}

	Tab10:AddSection({"TY hub HOUSE RGB"})

	Tab10:AddToggle({
		Name = "RGB HOUSE (TY hub)",
		Default = false,
		Callback = function(value)
			tbl58.Enabled = value
			if value then
				task.spawn(function()
					while tbl58.Enabled do
						tbl58.Index = tbl58.Index + 1

						if tbl58.Index > #tbl58.Colors then
							tbl58.Index = 1
						end

						local v1 = tbl58.Colors[tbl58.Index]

						pcall(function()
							game.ReplicatedStorage.RE["1Player1sHous1e"]:FireServer("ColorPickHouse", v1)
						end)

						task.wait(1 / tbl58.Speed)
					end
				end)
			end
		end,
	})

	Tab10:AddTextBox({
		Name = "RGB SPEED (TY hub)",
		Description = "Set blinking rate speed",
		PlaceholderText = "1",
		Callback = function(value)
			local num = tonumber(value)
			if num and num > 0 then
				tbl58.Speed = num
			end
		end,
	})

	local Players7 = game:GetService("Players")
	local LocalPlayer5 = Players7.LocalPlayer
	local Tab11 = Window:MakeTab({"SERVER", "bomb"})
	local flag17 = false
	local str6 = "sf"

	local function func27()
		return (LocalPlayer5.Character or LocalPlayer5.CharacterAdded:Wait()):WaitForChild("HumanoidRootPart")
	end

	local function func28(arg1)
		if arg1:IsA("Model") then
			if arg1.PrimaryPart then
				return arg1.PrimaryPart.CFrame
			end

			local BasePart = arg1:FindFirstChildWhichIsA("BasePart", true)

			if BasePart then
				return BasePart.CFrame
			end
		elseif arg1:IsA("BasePart") then
			return arg1.CFrame
		end
	end

	local function func29()
		local tbl = {}

		for _, descendant in ipairs(workspace:GetDescendants()) do
			if descendant.Name:lower() == "higher" then
				table.insert(tbl, descendant)
			end
		end

		return tbl
	end

	local tbl59 = {}

	tbl59[2], tbl59[1] = function()
		local v1 = func27()

		if not v1 then
			return
		end

		local CFrame1 = v1.CFrame
		v1.CFrame = CFrame.new(-239, 89.5, -548)
		task.wait(0.6)
		local _1Cemeter1y = game:GetService("ReplicatedStorage"):WaitForChild("RE"):WaitForChild("1Cemeter1y")

		pcall(function()
			_1Cemeter1y:FireServer("ReturningCommercialWords", 3, nil, "TY hub COMMUNITY ON TOP")
			_1Cemeter1y:FireServer("CommercialWordColor", 3, Color3.new(1, 0, 0.0357508659362793))
			_1Cemeter1y:FireServer("CommercialBackGround", 3, Color3.new(0, 0, 0))
		end)

		task.wait(0.4)
		v1.CFrame = CFrame1
	end, "TY hub COMMUNITY MESSAGE"

	Tab11:AddButton(tbl59)
	local tbl60 = {}

	tbl60[2], tbl60[1] = function()
		local v1 = func27()
		local CFrame1 = v1.CFrame

		for _, v2 in ipairs((func29())) do
			local v3 = func28(v2)
			if v3 then
				v1.CFrame = v3 * CFrame.new(0, 2, 0)
				task.wait(0.25)
				local ClickDetector = v2:FindFirstChildWhichIsA("ClickDetector", true)

				if ClickDetector then
					for _ = 1, 30 do
						fireclickdetector(ClickDetector)
						task.wait(0.04)
					end
				end

				task.wait(0.25)
			end
		end

		v1.CFrame = CFrame1
	end, "FIRE IN ALL RESTAURANTS"

	Tab11:AddButton(tbl60)
	local tbl61 = {}

	tbl61[1], tbl61[2] = "SCHOOL FIRE ALARM ALERT", function()
		local v1 = func27()
		local CFrame1 = v1.CFrame

		for _, descendant in ipairs(workspace:GetDescendants()) do
			if descendant.Name:find("FireAlarmClicker") then
				local ClickDetector = descendant:FindFirstChildWhichIsA("ClickDetector")
				if ClickDetector then
					local CFrame2

					if descendant:IsA("Model") then
						if descendant.PrimaryPart then
							CFrame2 = descendant.PrimaryPart.CFrame
						else
							local BasePart = descendant:FindFirstChildWhichIsA("BasePart")
							if BasePart then
								CFrame2 = BasePart.CFrame
							end
						end
					elseif descendant:IsA("BasePart") then
						CFrame2 = descendant.CFrame
					end

					if CFrame2 then
						v1.CFrame = CFrame2 + Vector3.new(0, 3, 0)
						task.wait(0.1)
						fireclickdetector(ClickDetector)
						task.wait(0.2)
					end
				end
			end
		end

		v1.CFrame = CFrame1
	end

	Tab11:AddButton(tbl61)
	local tbl62 = {}

	tbl62[2], tbl62[1] = function()
		local v1 = func27()
		local CFrame1 = v1.CFrame

		for _, descendant in ipairs(workspace:GetDescendants()) do
			if descendant.Name:lower():find("lightswitch") then
				local ClickDetector = descendant:FindFirstChildWhichIsA("ClickDetector", true)
				if ClickDetector then
					local Parent = ClickDetector.Parent
					local v2

					if Parent:IsA("BasePart") then
						v2 = Parent
					else
						local v3, v4, v5 = ipairs(Parent:GetDescendants())
						v2 = nil

						for _, v6 in v3, v4, v5 do
							if v6:IsA("BasePart") then
								v2 = v6
								break
							end
						end
					end

					if v2 then
						v1.CFrame = v2.CFrame
						task.wait(1)
						fireclickdetector(ClickDetector)
						task.wait(0.1)
						fireclickdetector(ClickDetector)
					end
				end
			end
		end

		v1.CFrame = CFrame1
	end, "TURN OFF ALL SWITCHES"

	Tab11:AddButton(tbl62)

	Tab11:AddToggle({
		Name = "INVITATION LOOP ALL",
		Default = false,
		Callback = function(value)
			flag17 = value
			if flag17 then
				task.spawn(function()
					while flag17 do
						for _, player in ipairs(Players7:GetPlayers()) do
							if player ~= LocalPlayer5 and flag17 then
								pcall(function()
									local tbl = {}
									tbl[1], tbl[2] = "HouseParty", {player.UserId}
									game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("StartFreeParty"):FireServer(unpack(tbl))
								end)
							end
						end
						task.wait(0.5)
					end
				end)
			end
		end,
	})

	if not pcall(function()
		Tab11:AddTextbox({
			Name = "Text to put on Signs",
			Default = "",
			TextDisappear = false,
			Callback = function(value)
				str6 = value
			end,
		})
	end) then
		pcall(function()
			Tab11:AddTextBox({
				Name = "SIGN TEXT",
				Default = "",
				TextDisappear = false,
				Callback = function(value)
					str6 = value
				end,
			})
		end)
	end

	local tbl63 = {}

	tbl63[1], tbl63[2] = "SIGN ALL", function()
		for _, player in ipairs(Players7:GetPlayers()) do
			local Character = player.Character
			if Character then
				local Sign = Character:FindFirstChild("Sign")
				if Sign then
					local ToolSound = Sign:FindFirstChild("ToolSound")
					if ToolSound and ToolSound:IsA("RemoteEvent") then
						pcall(function()
							ToolSound:FireServer("Sign", "SignWords", str6)
						end)
					end
				end
			end
		end
	end

	Tab11:AddButton(tbl63)
	local tbl64 = {}

	local function func30(arg1)
		local v1 = func27()

		if not v1 then
			return
		end

		local CFrame1 = v1.CFrame
		local v2

		for _, descendant in ipairs(workspace:GetDescendants()) do
			if descendant.Name == arg1 then
				v2 = descendant
				break
			end
		end

		if v2 then
			local v3 = func28(v2)
			if v3 then
				v1.CFrame = v3 + Vector3.new(0, 1.5, 0)
				task.wait(0.1)
				v1.CFrame = v1.CFrame - Vector3.new(0, 900, 0)
				task.wait(0.1)
			end
		end

		v1.CFrame = CFrame1
	end

	tbl64[1], tbl64[2] = "DELETE SWING 1", function()
		func30("SwingMesh1")
	end

	Tab11:AddButton(tbl64)
	local tbl65 = {}

	tbl65[1], tbl65[2] = "DELETE SWING 2", function()
		func30("SwingMesh2")
	end

	Tab11:AddButton(tbl65)
	local tbl66 = {}

	tbl66[2], tbl66[1] = function()
		func30("SwingMesh3")
	end, "DELETE SWING 3"

	Tab11:AddButton(tbl66)
end

local Tab13

do
	local Tab12 = Window:MakeTab({"VISUAL", "eye"})
	local Players8 = game:GetService("Players")
	local CoreGui1 = game:GetService("CoreGui")
	local LocalPlayer6 = Players8.LocalPlayer
	local v5 = CoreGui1:FindFirstChild("RBH_ESP_Billboards") or Instance.new("Folder", CoreGui1)
	v5.Name = "RBH_ESP_Billboards"
	local v6 = CoreGui1:FindFirstChild("RBH_Highlights") or Instance.new("Folder", CoreGui1)
	v6.Name = "RBH_Highlights"
	local flag18 = false
	local tbl67 = {}
	local tbl68 = {}
	local connection3
	local connection4

	local tbl69 = {
		red = {hl = Color3.fromRGB(255, 0, 0), name = Color3.fromRGB(255, 255, 255)},
		yellow = {hl = Color3.fromRGB(255, 215, 0), name = Color3.fromRGB(0, 0, 0)},
		blue = {hl = Color3.fromRGB(0, 150, 255), name = Color3.fromRGB(255, 255, 255)},
		green = {hl = Color3.fromRGB(0, 255, 128), name = Color3.fromRGB(0, 0, 0)},
		white = {hl = Color3.fromRGB(255, 255, 255), name = Color3.fromRGB(0, 0, 0)},
		black = {hl = Color3.fromRGB(0, 0, 0), name = Color3.fromRGB(255, 255, 255)},
		brown = {hl = Color3.fromRGB(139, 69, 19), name = Color3.fromRGB(255, 255, 255)},
		darkgreen = {hl = Color3.fromRGB(0, 100, 0), name = Color3.fromRGB(255, 255, 255)},
		purple = {hl = Color3.fromRGB(128, 0, 128), name = Color3.fromRGB(255, 255, 255)},
		magenta = {hl = Color3.fromRGB(255, 0, 255), name = Color3.fromRGB(255, 255, 255)},
	}

	local hl = tbl69.red.hl
	local name = tbl69.red.name

	local function func31(arg1)
		if tbl67[arg1] then
			if tbl67[arg1].highlight then
				tbl67[arg1].highlight:Destroy()
			end

			if tbl67[arg1].billboard then
				tbl67[arg1].billboard:Destroy()
			end

			tbl67[arg1] = nil
		end
		if tbl68[arg1] then
			tbl68[arg1]:Disconnect()
			tbl68[arg1] = nil
		end
	end

	local function func32(player)
		if player == LocalPlayer6 or not player.Character then
			return
		end

		func31(player)
		local Character = player.Character
		local highlight = Instance.new("Highlight")
		highlight.Adornee = Character
		highlight.FillColor = hl
		highlight.OutlineColor = hl
		highlight.FillTransparency = 0.75
		highlight.OutlineTransparency = 0
		highlight.Parent = v6
		local v1 = Character:FindFirstChild("Head") or Character:FindFirstChild("HumanoidRootPart")
		local v2

		if v1 then
			local billboardGui = Instance.new("BillboardGui")
			v2 = billboardGui
			billboardGui.Adornee = v1
			billboardGui.Size = UDim2.new(0, 200, 0, 30)
			billboardGui.StudsOffset = Vector3.new(0, 2.5, 0)
			billboardGui.AlwaysOnTop = true
			billboardGui.Parent = v5
			local textLabel = Instance.new("TextLabel", billboardGui)
			textLabel.Size = UDim2.new(1, 0, 1, 0)
			textLabel.BackgroundTransparency = 1
			textLabel.Text = player.DisplayName .. " | " .. player.Name
			textLabel.TextColor3 = name
			textLabel.TextStrokeTransparency = 0.6
			textLabel.Font = Enum.Font.GothamBold
			textLabel.TextSize = 14
		end

		tbl67[player] = {highlight = highlight, billboard = v2}
	end

	local function func33(player)
		if tbl68[player] then
			tbl68[player]:Disconnect()
		end

		tbl68[player] = player.CharacterAdded:Connect(function()
			task.wait(0.2)
			if flag18 then
				func32(player)
			end
		end)

		if player.Character and flag18 then
			func32(player)
		end
	end

	local function func34()
		flag18 = true

		for _, player in ipairs(Players8:GetPlayers()) do
			func33(player)
		end

		connection3 = Players8.PlayerAdded:Connect(function(player)
			func33(player)
		end)

		connection4 = Players8.PlayerRemoving:Connect(func31)
	end

	local function func35()
		flag18 = false

		for k in pairs(tbl67) do
			func31(k)
		end

		for _, v1 in pairs(tbl68) do
			v1:Disconnect()
		end

		table.clear(tbl68)

		if connection3 then
			connection3:Disconnect()
		end

		if connection4 then
			connection4:Disconnect()
		end
	end

	local function func36()
		for _, v1 in pairs(tbl67) do
			if v1.highlight then
				v1.highlight.FillColor = hl
				v1.highlight.OutlineColor = hl
			end
			if v1.billboard and v1.billboard:FindFirstChildOfClass("TextLabel") then
				v1.billboard.TextLabel.TextColor3 = name
			end
		end
	end

	local function func37(arg1)
		local v1 = tbl69[arg1]

		if not v1 then
			return
		end

		hl = v1.hl
		local name1 = v1.name
		name = name1

		if flag18 then
			func36()
		end
	end

	local tbl70 = {}

	tbl70[2], tbl70[1] = function()
		loadstring(game:HttpGet("https://raw.githubusercontent.com/THEMRREDBLACK/Shaders-4K/refs/heads/main/MRB.md"))()
	end, "SHADERS 4K+MATERIAL CORRECTION"

	Tab12:AddButton(tbl70)
	local tbl71 = {}

	tbl71[2], tbl71[1] = function()
		loadstring(game:HttpGet("https://raw.githubusercontent.com/THEMRREDBLACK/SHADERS-4K-V1/refs/heads/main/Omaga"))()
	end, "SHADERS 4K"

	Tab12:AddButton(tbl71)

	Tab12:AddDropdown({
		Name = "ESP COLOR",
		Description = "Select target outline color",
		Options = {"RED", "YELLOW", "BLUE", "GREEN", "WHITE", "BLACK", "BROWN", "DARKGREEN", "PURPLE", "MAGENTA"},
		Default = "RED",
		Callback = function(value)
			func37(string.lower(value))
		end,
	})

	Tab12:AddToggle({
		Name = "ENABLE ESP",
		Default = false,
		Callback = function(value)
			if value then
				func34()
			else
				func35()
			end
		end,
	})

	local RunService3 = game:GetService("RunService")
	local flag19 = false
	local tbl72 = {}
	local connection5
	local v12
	local connection6

	local tbl73 = {
		red = Color3.fromRGB(255, 0, 0),
		yellow = Color3.fromRGB(255, 215, 0),
		blue = Color3.fromRGB(0, 150, 255),
		green = Color3.fromRGB(0, 255, 128),
		white = Color3.fromRGB(255, 255, 255),
		black = Color3.fromRGB(0, 0, 0),
		purple = Color3.fromRGB(128, 0, 128),
		magenta = Color3.fromRGB(255, 0, 255),
	}

	local red = tbl73.red

	local function func38()
		for _, v1 in pairs(tbl72) do
			if v1.H then
				v1.H.FillColor = red
				v1.H.OutlineColor = red
			end
		end
	end

	local function func39(arg1)
		if not arg1:IsA("Model") then
			return false
		end

		if arg1.Name:sub(1, 4) ~= "Prop" then
			return false
		end

		local v1 = arg1.Name:sub(5)

		if v1 == "" then
			return false
		end

		return Players8:FindFirstChild(v1) ~= nil
	end

	local function func40(parent)
		if tbl72[parent] then
			return
		end

		if not func39(parent) then
			return
		end

		local BasePart = parent:FindFirstChildWhichIsA("BasePart")

		if not BasePart then
			return
		end

		local highlight = Instance.new("Highlight")
		highlight.FillColor = red
		highlight.OutlineColor = red
		highlight.FillTransparency = 0.35
		highlight.Parent = parent
		local billboardGui = Instance.new("BillboardGui")
		billboardGui.Size = UDim2.new(0, 200, 0, 50)
		billboardGui.AlwaysOnTop = true
		billboardGui.Adornee = BasePart
		billboardGui.Parent = parent
		local textLabel = Instance.new("TextLabel")
		textLabel.Size = UDim2.new(1, 0, 1, 0)
		textLabel.BackgroundTransparency = 1
		textLabel.TextScaled = true
		textLabel.TextColor3 = Color3.new(1, 1, 1)
		textLabel.TextStrokeTransparency = 0
		textLabel.Parent = billboardGui
		tbl72[parent] = {H = highlight, B = billboardGui, T = textLabel}
	end

	local function func41(arg1)
		if tbl72[arg1] then
			if tbl72[arg1].H then
				tbl72[arg1].H:Destroy()
			end

			if tbl72[arg1].B then
				tbl72[arg1].B:Destroy()
			end

			tbl72[arg1] = nil
		end
	end

	local function func42()
		for k in pairs(tbl72) do
			func41(k)
		end
		table.clear(tbl72)
	end

	local function func43()
		if not LocalPlayer6.Character then
			return
		end

		local HumanoidRootPart = LocalPlayer6.Character:FindFirstChild("HumanoidRootPart")

		if not HumanoidRootPart then
			return
		end

		for k, v1 in pairs(tbl72) do
			if k and k.Parent then
				local BasePart = k:FindFirstChildWhichIsA("BasePart")
				if BasePart then
					local Magnitude = (HumanoidRootPart.Position - BasePart.Position).Magnitude
					local v2 = k.Name:sub(5)
					v1.T.Text = v2 .. " | " .. math.floor(Magnitude) .. "m"
				end
			else
				func41(k)
			end
		end
	end

	Tab12:AddDropdown({
		Name = "PROP ESP COLOR",
		Description = "Select active prop overlay tint",
		Options = {"RED", "YELLOW", "BLUE", "GREEN", "WHITE", "BLACK", "PURPLE", "MAGENTA"},
		Default = "RED",
		Callback = function(value)
			local v1 = string.lower(value)
			if tbl73[v1] then
				red = tbl73[v1]
				func38()
			end
		end,
	})

	Tab12:AddToggle({
		Name = "PROP ESP",
		Default = false,
		Callback = function(value)
			flag19 = value
			if value then
				for _, descendant in pairs(workspace:GetDescendants()) do
					if func39(descendant) then
						func40(descendant)
					end
				end

				local connection = workspace.DescendantAdded:Connect(function(descendant)
					if flag19 and func39(descendant) then
						func40(descendant)
					end
				end)

				v12 = connection

				connection6 = workspace.DescendantRemoving:Connect(function(descendant)
					if tbl72[descendant] then
						func41(descendant)
					end
				end)

				connection5 = RunService3.RenderStepped:Connect(func43)
			else
				if connection5 then
					connection5:Disconnect()
				end

				if v12 then
					v12:Disconnect()
				end

				if connection6 then
					connection6:Disconnect()
				end

				func42()
			end
		end,
	})

	Tab13 = Window:MakeTab({"SCRIPTS", "code"})
	local tbl74 = {}

	tbl74[1], tbl74[2] = "ESP GUI", function()
		loadstring(game:HttpGet("https://rawscripts.net/raw/Universal-Script-ESP-VERIFICADOR-DE-PLAYERS-V5-27937"))()
	end

	Tab13:AddButton(tbl74)
	local tbl75 = {}

	tbl75[1], tbl75[2] = "YAK HUB DO PEDRO OF WAR", function()
		loadstring(game:HttpGet("https://raw.githubusercontent.com/Yak-Scripts/yakhub/main/yakhub.lua", true))()
	end

	Tab13:AddButton(tbl75)
end

local tbl76 = {}

tbl76[1], tbl76[2] = "SANDER X", function()
	loadstring(game:HttpGet("https://rawscripts.net/raw/Brookhaven-RP-Sander-X-Hub-Latest-Version-3-16718"))()
end

Tab13:AddButton(tbl76)
local tbl77 = {}

tbl77[1], tbl77[2] = "TY hub GUI", function()
	loadstring(game:HttpGet("https://raw.githubusercontent.com/THEMRREDBLACK/CALCULADORA-RED-BLACK-/refs/heads/main/README.md"))()
end

Tab13:AddButton(tbl77)
local tbl78 = {}

tbl78[1], tbl78[2] = "R4D SEM KEY", function()
	loadstring(game:HttpGet("https://rawscripts.net/raw/Brookhaven-RP-R4D-script-no-key-17562"))()
end

Tab13:AddButton(tbl78)
local tbl79 = {}

tbl79[2], tbl79[1] = function()
	loadstring(game:HttpGet("https://rawscripts.net/raw/Infinite-Yield_500"))()
end, "INFINITE YIELD"

Tab13:AddButton(tbl79)
local tbl80 = {}

tbl80[2], tbl80[1] = function()
	loadstring(game:HttpGet("https://rawscripts.net/raw/Universal-Script-Troll-Gui-3874"))()
end, "TROLL GUI"

Tab13:AddButton(tbl80)
local tbl81 = {}

tbl81[2], tbl81[1] = function()
	loadstring(game:HttpGet("https://rawscripts.net/raw/Universal-Script-Teleport-Tool-27419"))()
end, "TELEPORT TOOL"

Tab13:AddButton(tbl81)
local tbl82 = {}

tbl82[1], tbl82[2] = "TELEKINESIS", function()
	loadstring(game:HttpGet("https://rawscripts.net/raw/Universal-Script-Fe-Telekinesis-V5-21542"))()
end

Tab13:AddButton(tbl82)

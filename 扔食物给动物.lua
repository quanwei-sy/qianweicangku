-- 扔食物给动物：独立服务器缝合版
local NothingLibrary = loadstring(game:HttpGetAsync('https://raw.githubusercontent.com/quanwei-sy/qianweicangku/refs/heads/main/%E6%BA%90%E7%A0%81.lua'))()

local __BaseWindow = NothingLibrary.new({
    Title = "TY hub｜扔食物给动物",
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


return (function()
	-- renderer = NothingLibrary ของเราเอง (/c/NothingLibrary แนว WindUI) ; เลิกใช้ NothingLibrary แล้ว (ตัดออก 2026-10-26)
	-- TYHUB_UI_LIB = lib ที่โหลดจากไฟล์ในเครื่อง (ทดสอบโดยไม่ต้อง deploy)
	local uiEnv = (type(getgenv) == "function" and getgenv()) or _G
local splash = { step = function() end, finish = function() end, onClose = function() end }
	splash.step("Loading game script...", 0.5)
	local flagCount = 0
	local function flagOf(opts)
		flagCount = flagCount + 1
		return opts.flag or ("Auto_" .. flagCount)
	end
	-- NothingLibrary multi dropdown ส่งค่าเป็น { [ชื่อ] = true } แต่โค้ดเดิมรอ list แบบ NothingLibrary
	local function toList(value)
		if type(value) ~= "table" then return value end
		local list = {}
		for key, on in pairs(value) do
			if on == true then table.insert(list, key) elseif type(on) == "string" then table.insert(list, on) end
		end
		return list
	end

	-- ===== 2 ภาษา (en default / th): ข้อความต้นฉบับเป็นอังกฤษ = key ; เกมเพิ่มคำแปลด้วย UI:AddLang("th", {...}) =====
	-- ทุก element ลงทะเบียนฟังก์ชัน refresh ไว้ -> สลับภาษาแล้วเปลี่ยนข้อความทันทีไม่ต้องรันใหม่
	-- ภาษาที่เลือกจำใน TYHub/lang.txt ใช้ร่วมทุกเกม
	local LANG_FILE = "TYHub/lang.txt"
	local dict = { th = {
		["Save Config"] = "บันทึก Config", ["Load Config"] = "โหลด Config", ["Delete Config"] = "ลบ Config", ["Config"] = "Config", ["New Config Name"] = "ชื่อ Config ใหม่", ["type a name then Save"] = "พิมพ์ชื่อแล้วกดบันทึก", ["Deleted"] = "ลบแล้ว", ["Auto Load on start"] = "โหลดอัตโนมัติตอนเปิดสคริปต์",
		["Language"] = "ภาษา", ["Saved %s"] = "บันทึกแล้ว %s", ["Save failed: %s"] = "บันทึกไม่ได้: %s",
		["Loaded %s values"] = "โหลดแล้ว %s ค่า", ["Auto loaded %s values"] = "โหลดอัตโนมัติแล้ว %s ค่า",
		["No config file yet"] = "ยังไม่มีไฟล์ config", ["Can't read config"] = "อ่าน config ไม่ได้",
		["Executor has no writefile"] = "executor ไม่มี writefile", ["Settings"] = "ตั้งค่า", ["Theme"] = "ธีม", ["Blackhole Red"] = "หลุมดำแดง", ["Blackhole Purple"] = "หลุมดำม่วง", ["Default Purple"] = "ม่วงเริ่มต้น", ["Low spec mode"] = "โหมดสเปคต่ำ", ["FPS cap"] = "จำกัด FPS", ["Disable 3D rendering (AFK)"] = "ปิดการวาด 3D (เปิดทิ้ง)", ["Boost FPS"] = "เพิ่ม FPS", ["Boost FPS stays on until rejoin"] = "Boost FPS ปิดแล้วต้อง rejoin ถึงคืนค่า", ["Show loading screen"] = "แสดงหน้าโหลดตอนเปิด", ["FPS Booster Loaded!"] = "เพิ่ม FPS เรียบร้อย!", ["FPS Cap Failed"] = "จำกัด FPS ไม่สำเร็จ",
	} }
	local lang = "en"
	pcall(function()
		local saved = type(isfile) == "function" and isfile(LANG_FILE) and readfile(LANG_FILE)
		if saved == "th" or saved == "en" then lang = saved end
	end)
	local hasSavedLang = false
	pcall(function() hasSavedLang = isfile(LANG_FILE) == true end)
	local function T(text)
		if type(text) == "function" then return tostring(text()) end
		text = tostring(text)
		local map = dict[lang]
		return map and map[text] or text
	end
	local refreshers = {}
	local function onLang(fn) table.insert(refreshers, fn) end
	local langDropdown
	local function setLang(code, noSave)
		if code ~= "th" then code = "en" end
		lang = code
		if not noSave then pcall(function()
			if type(makefolder) == "function" and not (type(isfolder) == "function" and isfolder("TYHub")) then makefolder("TYHub") end
			writefile(LANG_FILE, code)
		end) end
		for _, fn in ipairs(refreshers) do pcall(fn) end
		if langDropdown then pcall(function()
			local want = code == "th" and "ไทย" or "English"
			if langDropdown.Value ~= want then langDropdown:SetValue(want) end
		end) end
	end

	-- ธีมกลาง: เปลี่ยน Scheme แล้วให้ NothingLibrary ทาสี element ที่ลงทะเบียนไว้อีกครั้ง
	local THEME_FILE = "TYHub/theme.txt"
	local themes = {
		["Blackhole Red"] = { BackgroundColor = Color3.fromRGB(8, 6, 8), MainColor = Color3.fromRGB(22, 14, 17), AccentColor = Color3.fromRGB(220, 38, 38), OutlineColor = Color3.fromRGB(78, 25, 31), FontColor = Color3.fromRGB(248, 242, 242), DarkColor = Color3.fromRGB(3, 2, 3) },
		["Blackhole Purple"] = { BackgroundColor = Color3.fromRGB(8, 6, 12), MainColor = Color3.fromRGB(20, 14, 30), AccentColor = Color3.fromRGB(153, 78, 255), OutlineColor = Color3.fromRGB(67, 35, 102), FontColor = Color3.fromRGB(248, 244, 255), DarkColor = Color3.fromRGB(3, 2, 5) },
		["Default Purple"] = { BackgroundColor = Color3.fromRGB(15, 15, 15), MainColor = Color3.fromRGB(25, 25, 25), AccentColor = Color3.fromRGB(125, 85, 255), OutlineColor = Color3.fromRGB(40, 40, 40), FontColor = Color3.new(1, 1, 1), DarkColor = Color3.new(0, 0, 0) },
	}
	local theme = "Default Purple"
	pcall(function()
		local saved = type(isfile) == "function" and isfile(THEME_FILE) and readfile(THEME_FILE)
		if themes[saved] then theme = saved end
	end)
	local themeRefreshers = {}
	local themeDropdown
	local function setTheme(name, noSave)
		name = themes[name] and name or "Default Purple"
		theme = name
		for key, value in pairs(themes[name]) do Library.Scheme[key] = value end
		Library:UpdateColorsUsingRegistry()
		for _, refresh in ipairs(themeRefreshers) do pcall(refresh) end
		if not noSave then pcall(function()
			if type(makefolder) == "function" and not (type(isfolder) == "function" and isfolder("TYHub")) then makefolder("TYHub") end
			writefile(THEME_FILE, name)
		end) end
		if themeDropdown then pcall(function() if themeDropdown.Value ~= name then themeDropdown:SetValue(name) end end) end
	end
	setTheme(theme, true)

	-- ===== Config save/load/autoload (ทุกเกม): อ่านค่าจาก Library.Options (NothingLibrary เก็บทุก element ที่มี flag) =====
	-- ข้าม flag "Auto_n" (สร้างตามลำดับ ถ้าโค้ดเกมเปลี่ยนลำดับจะไปตั้งผิดตัว) ; ไฟล์แยกตาม PlaceId ใน workspace ของ executor
	local Http = game:GetService("HttpService")
	local CONFIG_DIR = "TYHub"
	-- หลาย config ต่อเกม: "default" = ไฟล์เดิม <PlaceId>.json ; ชื่ออื่น = <PlaceId>@<ชื่อ>.json
	local function configFile(name)
		if not name or name == "" or name == "default" then return ("%s/%d.json"):format(CONFIG_DIR, game.PlaceId) end
		return ("%s/%d@%s.json"):format(CONFIG_DIR, game.PlaceId, name)
	end
	local function configNames()
		local names = { "default" }
		pcall(function()
			for _, path in ipairs(listfiles(CONFIG_DIR)) do
				local name = tostring(path):match(tostring(game.PlaceId) .. "@(.+)%.json$")
				if name then table.insert(names, name) end
			end
		end)
		table.sort(names, function(a, b) return a == "default" or (b ~= "default" and a:lower() < b:lower()) end)
		return names
	end
	local AUTOLOAD_FILE = ("%s/%d.autoload"):format(CONFIG_DIR, game.PlaceId)
	local canFile = type(writefile) == "function" and type(readfile) == "function" and type(isfile) == "function"
	local function ensureDir()
		pcall(function() if type(makefolder) == "function" and not (type(isfolder) == "function" and isfolder(CONFIG_DIR)) then makefolder(CONFIG_DIR) end end)
	end
	local function configValues()
		local values = {}
		for flag, option in pairs(Library.Options or {}) do
			if type(flag) == "string" and not flag:match("^Auto_%d+$") and not flag:match("^TYHubCfg") and type(option) == "table" and option.Value ~= nil and option.Type ~= "KeyPicker" then
				values[flag] = option.Value
			end
		end
		for flag, toggle in pairs(Library.Toggles or {}) do
			if type(flag) == "string" and not flag:match("^Auto_%d+$") and type(toggle) == "table" then values[flag] = toggle.Value end
		end
		return values
	end
	local function saveConfig(name)
		if not canFile then return false, "Executor has no writefile" end
		ensureDir()
		local values = configValues()
		local count = 0
		for _ in pairs(values) do count = count + 1 end
		local ok, err = pcall(function()
			writefile(configFile(name), Http:JSONEncode(values))
		end)
		return ok, ok and count or err
	end
	local function loadConfig(name)
		local file = configFile(name)
		if not canFile or not isfile(file) then return false, "No config file yet" end
		local ok, saved = pcall(function() return Http:JSONDecode(readfile(file)) end)
		if not ok or type(saved) ~= "table" then return false, "Can't read config" end
		local loaded = 0
		local flags, retryDropdowns = {}, {}
		for flag in pairs(saved) do table.insert(flags, flag) end
		table.sort(flags)
		for _, flag in ipairs(flags) do
			local value = saved[flag]
			local element = (Library.Toggles and Library.Toggles[flag]) or (Library.Options and Library.Options[flag])
			if type(element) == "table" and element.SetValue and pcall(element.SetValue, element, value) then
				loaded = loaded + 1
				-- Dropdown บางตัวเปลี่ยนรายการจาก callback ของ dropdown ก่อนหน้า (เช่น World -> Monster)
				if element.Type == "Dropdown" and element.Value ~= value then retryDropdowns[flag] = value end
			end
		end
		if next(retryDropdowns) then task.delay(0.25, function()
			for flag, value in pairs(retryDropdowns) do
				local element = Library.Options and Library.Options[flag]
				if type(element) == "table" and element.SetValue then pcall(element.SetValue, element, value) end
			end
		end) end
		return true, loaded
	end
	local function elementCount()
		local count = 0
		for _ in pairs(Library.Options or {}) do count = count + 1 end
		for _ in pairs(Library.Toggles or {}) do count = count + 1 end
		return count
	end
	-- ===== Performance (ทุกเกม, กล่องในแท็บ Settings): ค่าเก็บผ่าน flag -> Save/Auto Load config เปิดให้เองตอนเข้าเกม =====
	-- เกมอ่าน UI.Perf.lowSpec เพื่อลดความถี่ loop หนัก (ESP/HUD) ; มือถือเปิด lowSpec ให้อัตโนมัติ
	local UIS = game:GetService("UserInputService")
	local isMobile = UIS.TouchEnabled and not UIS.KeyboardEnabled
	local perf = { lowSpec = isMobile, isMobile = isMobile, boosted = false }
	local function restorePerf()
		pcall(function() game:GetService("RunService"):Set3dRenderingEnabled(true) end)
		-- 60 = ค่าปกติของ Roblox ; setfpscap(0) บาง executor = ไม่จำกัด -> เครื่องร้อน
		if type(setfpscap) == "function" then pcall(setfpscap, 60) end
	end
	local function addPerfBox(tab)
		local group = tab:AddRightGroupbox("Performance")
		local low = group:AddToggle("TYHubLowSpec", { Text = T("Low spec mode"), Default = isMobile, Callback = function(v) perf.lowSpec = v end })
		local fps = group:AddDropdown("TYHubFpsCap", { Text = T("FPS cap"), Values = { "Off", "60", "30", "15" }, Default = "Off", Callback = function(v)
			-- "Off" = กลับค่าปกติ 60 (ไม่ใช่ 0 ที่บาง executor ปลดล็อกไม่จำกัด) ; Auto Load ก็เรียกตัวนี้ตอนเปิดเกม
			if type(setfpscap) == "function" then pcall(setfpscap, v == "Off" and 60 or tonumber(v)) end
		end })
		-- จอขาวแต่สคริปต์ยังทำงาน (ไม่พึ่งภาพ) -> เครื่องเย็นสุดตอนเปิดทิ้งฟาร์ม
		local no3d = group:AddToggle("TYHubNo3D", { Text = T("Disable 3D rendering (AFK)"), Default = false, Callback = function(v)
			pcall(function() game:GetService("RunService"):Set3dRenderingEnabled(not v) end)
		end })
		-- Boost FPS เป็น toggle (เดิมเป็นปุ่ม) -> Auto Load เปิดให้ได้ ; ปิดแล้วไม่คืนค่ากราฟิก (ต้อง rejoin)
		local boost = group:AddToggle("TYHubBoostFps", { Text = T("Boost FPS"), Default = false, Callback = function(v)
			if v and not perf.boosted then
				perf.boosted = true
				-- boost-fps แจ้งเตือนผ่าน toast ของ Library (หน้าตาเดียวกับ UI) แทนแจ้งเตือนของ Roblox
				_G.TYHubNotify = function(title, text, duration)
					Library:Notify({ Title = T(title), Description = T(text), Time = duration or 5 })
				end
				task.spawn(function() pcall(function() loadstring(game:HttpGet("https://dekdev.discxnnect.workers.dev/c/boost-fps"))() end) end)
			end
		end })
		group:AddLabel(T("Boost FPS stays on until rejoin"), true)
		onLang(function()
			low:SetText(T("Low spec mode")); fps:SetText(T("FPS cap")); no3d:SetText(T("Disable 3D rendering (AFK)")); boost:SetText(T("Boost FPS"))
		end)
	end

	-- กล่อง Config ใส่ในแท็บ Settings ของทุกเกม (สร้างตรง ๆ ไม่ผ่าน newBox -> element ถัดไปของเกมไม่หล่นมากล่องนี้)
	local function addConfigBox(tab)
		local group = tab:AddRightGroupbox("Config")
		themeDropdown = group:AddDropdown("TYHubTheme", {
			Text = T("Theme"), Values = { "Blackhole Red", "Blackhole Purple", "Default Purple" }, Default = theme,
			Callback = function(value) if value ~= theme then setTheme(value) end end,
		})
		onLang(function() themeDropdown:SetText(T("Theme")) end)
		-- ภาษา: อยู่บนสุดของกล่อง Config ในแท็บ Settings
		langDropdown = group:AddDropdown("TYHubLanguage", {
			Text = T("Language"), Values = { "English", "ไทย" }, Default = lang == "th" and "ไทย" or "English",
			Callback = function(value) if (value == "ไทย" and "th" or "en") ~= lang then setLang(value == "ไทย" and "th" or "en") end end,
		})
		onLang(function() langDropdown:SetText(T("Language")) end)
		-- ข้อความสถานะเก็บเป็นฟังก์ชัน -> สลับภาษาแล้วแปลใหม่ได้
		local message = function() return "-" end
		local label = group:AddLabel("Config: -", true)
		local function show(fn) message = fn; pcall(function() label:SetText("Config: " .. fn()) end) end
		onLang(function() label:SetText("Config: " .. message()) end)
		-- เลือก config จาก dropdown ; พิมพ์ชื่อใหม่ในช่อง Name แล้วกด Save = สร้างตัวใหม่ (flag TYHubCfg* ไม่ถูกบันทึกลง config)
		local selected = "default"
		pcall(function()
			local saved = canFile and isfile(AUTOLOAD_FILE) and readfile(AUTOLOAD_FILE)
			if saved and saved ~= "" and saved ~= "1" and isfile(configFile(saved)) then selected = saved end
		end)
		local pick = group:AddDropdown("TYHubCfgSelect", { Text = T("Config"), Values = configNames(), Default = selected, Callback = function(v)
			if type(v) == "string" and v ~= "" then
				selected = v
				-- Auto Load เปิดอยู่ = จำตัวที่เลือกล่าสุดไว้โหลดตอนเปิดสคริปต์
				pcall(function() if canFile and isfile(AUTOLOAD_FILE) then writefile(AUTOLOAD_FILE, v) end end)
			end
		end })
		local nameInput = group:AddInput("TYHubCfgName", { Text = T("New Config Name"), Placeholder = T("type a name then Save"), Default = "", Finished = false })
		onLang(function() pick:SetText(T("Config")); nameInput:SetText(T("New Config Name")) end)
		local function refreshList(value)
			pcall(function() pick:SetValues(configNames()) end)
			if value then selected = value; pcall(function() pick:SetValue(value) end) end
		end
		local saveButton = group:AddButton({ Text = T("Save Config"), Func = function()
			local typed = tostring(nameInput.Value or ""):gsub("[^%w%-_ ]", ""):gsub("^%s+", ""):gsub("%s+$", "")
			local target = typed ~= "" and typed or selected
			local ok, result = saveConfig(target)
			if ok then refreshList(target); pcall(function() nameInput:SetValue("") end) end
			local stamp = os.date("%H:%M:%S")
			show(function() return ok and target .. ": " .. T("Saved %s"):format(stamp) .. " (" .. tostring(result) .. ")" or T("Save failed: %s"):format(T(tostring(result))) end)
		end })
		local loadButton = group:AddButton({ Text = T("Load Config"), Func = function()
			local target = selected
			local ran, ok, result = pcall(loadConfig, target)
			if not ran then
				show(function() return "Load error: " .. tostring(ok) end)
			else
				show(function() return target .. ": " .. (ok and T("Loaded %s values"):format(tostring(result)) or T(tostring(result))) end)
			end
		end })
		local deleteButton = group:AddButton({ Text = T("Delete Config"), Func = function()
			local target, file = selected, configFile(selected)
			local ok = canFile and type(delfile) == "function" and isfile(file) and pcall(delfile, file)
			-- ลบตัวที่ตั้ง Auto Load ไว้ -> Auto Load กลับไปใช้ default
			pcall(function() if ok and isfile(AUTOLOAD_FILE) and readfile(AUTOLOAD_FILE) == target then writefile(AUTOLOAD_FILE, "1") end end)
			refreshList("default")
			show(function() return target .. ": " .. (ok and T("Deleted") or T("No config file yet")) end)
		end })
		onLang(function() saveButton:SetText(T("Save Config")); loadButton:SetText(T("Load Config")); deleteButton:SetText(T("Delete Config")) end)
		local autoLoad = canFile and isfile(AUTOLOAD_FILE)
		local autoToggle = group:AddToggle("TYHubConfigAutoLoad", { Text = T("Auto Load on start"), Default = autoLoad, Callback = function(value)
			if not canFile then return end
			pcall(function()
				if value then ensureDir(); writefile(AUTOLOAD_FILE, selected)
				elseif type(delfile) == "function" and isfile(AUTOLOAD_FILE) then delfile(AUTOLOAD_FILE) end
			end)
		end })
		onLang(function() autoToggle:SetText(T("Auto Load on start")) end)
		if autoLoad then
			-- รอจนเกมสร้างทั้ง Options และ Toggles ครบก่อน มิฉะนั้น toggle ที่สร้างทีหลังจะไม่ถูก Load
			task.spawn(function()
				local last, stableSince, started = -1, os.clock(), os.clock()
				while os.clock() - started < 15 do
					local count = elementCount()
					if count ~= last then last, stableSince = count, os.clock()
					elseif os.clock() - stableSince > 1.5 then break end
					task.wait(0.25)
				end
				local ran, ok, result = pcall(loadConfig, selected)
				show(function()
					if not ran then return "Auto load error: " .. tostring(ok) end
					return ok and T("Auto loaded %s values"):format(tostring(result)) or T(tostring(result))
				end)
			end)
		end
	end

	local function wrapTab(tab)
		local box, side = nil, 0
		-- NothingLibrary Section = Groupbox ใหม่ สลับซ้าย/ขวา
		local function newBox(name)
			side = side + 1
			local group = side % 2 == 1 and tab:AddLeftGroupbox(T(name)) or tab:AddRightGroupbox(T(name))
			box = group
			-- NothingLibrary ไม่มี SetTitle -> หา TextLabel หัวกล่องที่ข้อความตรงกับที่แสดงอยู่
			local shown = T(name)
			onLang(function()
				for _, child in ipairs(group.Holder:GetDescendants()) do
					if child:IsA("TextLabel") and child.Text == shown then child.Text = T(name); break end
				end
				shown = T(name)
			end)
			return box
		end
		local function current() return box or newBox("Main") end
		local api = {}
		-- แท็บที่เป็นรายการยาว (Dashboard เป็นต้น) ใช้พื้นที่เต็มหน้าต่างแทนสองคอลัมน์
		function api:SetSingleColumn()
			local left, right = tab.Sides and tab.Sides[1], tab.Sides and tab.Sides[2]
			if not (left and right) then return end
			-- NothingLibrary เรียก RefreshSides ทุกครั้งที่เปิดแท็บและคืนขนาดสองคอลัมน์
			local refreshSides = tab.RefreshSides
			tab.RefreshSides = function(self)
				refreshSides(self)
				left.Position = UDim2.new(0, 0, left.Position.Y.Scale, left.Position.Y.Offset)
				left.Size = UDim2.new(1, -4, left.Size.Y.Scale, left.Size.Y.Offset)
				right.Visible = false
				right.Position = UDim2.new(0, 0, right.Position.Y.Scale, right.Position.Y.Offset)
				right.Size = UDim2.new(0, 0, right.Size.Y.Scale, right.Size.Y.Offset)
			end
			tab:RefreshSides()
		end
		function api:CreateSection(opts)
			local b = newBox(opts.name or "Section")
			if opts.image and b.SetIcon then pcall(b.SetIcon, b, opts.image) end
			return { Set = function() end, SetImage = function(_, img) if b.SetIcon then pcall(b.SetIcon, b, img) end end }
		end
		-- พื้นที่วาง GUI เอง (เช่น รายการเกมพร้อมโลโก้): คืน Frame ของ groupbox ปัจจุบัน + ฟังก์ชันสั่งปรับความสูงกล่อง
		function api:CreateCustom()
			local group = current()
			return {
				Container = group.Container,
				Resize = function() pcall(function() group:Resize() end) end,
			}
		end
		function api:CreateText(opts)
			-- text เป็น string (แปลตาม dict) หรือ function (สร้างข้อความเองด้วย UI.T -> สลับภาษาแล้วสร้างใหม่)
			local text = opts.text or ""
			local function render() return (opts.name and (T(opts.name) .. "\n") or "") .. T(text) end
			local label = current():AddLabel(render(), true)
			onLang(function() label:SetText(render()) end)
			return { Set = function(_, value) text = value; pcall(function() label:SetText(render()) end) end }
		end
		function api:CreateButton(opts)
			local button = current():AddButton({ Text = T(opts.name), Func = function() task.spawn(opts.callback) end })
			onLang(function() button:SetText(T(opts.name)) end)
			return { Set = function() end }
		end
		function api:CreateToggle(opts)
			local name = opts.name
			-- description = บรรทัดเล็กใต้ชื่อ (NothingLibrary เท่านั้น ; NothingLibrary ไม่โชว์)
			local desc = opts.description
			local toggle = current():AddToggle(flagOf(opts), { Text = T(name), Default = opts.value == true, Callback = opts.callback, Image = opts.image, Desc = desc and T(desc) })
			onLang(function() toggle:SetText(T(name)); if desc and toggle.SetDesc then toggle:SetDesc(T(desc)) end end)
			-- SetName: เปลี่ยนข้อความบน toggle ได้ (เช่นโชว์ level ในชื่อ)
			return {
				Set = function(_, value) toggle:SetValue(value) end,
				SetName = function(_, text) name = text; pcall(function() toggle:SetText(T(text)) end) end,
				-- รูปทีหลัง (NothingLibrary เท่านั้น ; NothingLibrary ไม่มี -> เงียบ)
				SetImage = function(_, img) if toggle.SetImage then pcall(toggle.SetImage, toggle, img) end end,
				SetDesc = function(_, text) desc = text; if toggle.SetDesc then pcall(toggle.SetDesc, toggle, text and T(text) or "") end end,
				SetLocked = function(_, locked, reason) if toggle.SetLocked then pcall(toggle.SetLocked, toggle, locked, reason) end end,
			}
		end
		function api:CreateSlider(opts)
			local step = opts.increment or 1
			local slider = current():AddSlider(flagOf(opts), {
				Text = T(opts.name), Min = opts.range[1], Max = opts.range[2], Default = opts.value or opts.range[1],
				Rounding = step < 1 and 1 or 0, Callback = opts.callback,
			})
			onLang(function() slider:SetText(T(opts.name)) end)
			return { Set = function(_, value) slider:SetValue(value) end }
		end
		function api:CreateDropdown(opts)
			local multi = opts.multiSelect == true
			local dropdown = current():AddDropdown(flagOf(opts), {
				Text = T(opts.name), Values = opts.options or {}, Multi = multi, AllowNull = true,
				Default = multi and nil or (opts.default or opts.value), ImageFor = opts.imageFor,
				Callback = function(value) if opts.callback then opts.callback(multi and toList(value) or value) end end,
			})
			onLang(function() dropdown:SetText(T(opts.name)) end)
			return {
				Refresh = function(_, options) dropdown:SetValues(options) end,
				Set = function(_, value) dropdown:SetValue(value) end,
			}
		end
		function api:CreateInput(opts)
			local input = current():AddInput(flagOf(opts), {
				Text = T(opts.name), Placeholder = T(opts.placeholder or ""), Default = "", Finished = true, Callback = opts.callback,
			})
			onLang(function() input:SetText(T(opts.name)) end)
			return { Set = function(_, value) input:SetValue(value) end }
		end
		function api:CreateColorPicker(opts)
			-- Color3 JSON encode ไม่ได้ จึงใช้ Auto flag เพื่อไม่ให้ Config กลางพยายามบันทึกค่า
			local id = flagOf({})
			-- AddColorPicker เป็น addon ของ Label แบบบรรทัดเดียว (DoesWrap ต้องเป็น false)
			local label = current():AddLabel(T(opts.name), false)
			label:AddColorPicker(id, { Default = opts.value or Color3.new(1, 1, 1), Callback = opts.callback })
			onLang(function() label:SetText(T(opts.name)) end)
			return { Set = function(_, value) local picker = Library.Options[id]; if picker then picker:SetValue(value) end end }
		end
		function api:Select() pcall(function() tab:Show() end) end
		function api:SetImage(img) if tab.SetImage then pcall(tab.SetImage, tab, img) end end
		-- NothingLibrary Group: ของที่เพิ่มทีหลัง (เช่น toggle สกิลที่สแกนเจอ) ต้องลง Groupbox เดิมตอนสร้าง ไม่ใช่ box ล่าสุด
		function api:CreateGroup()
			local groupBox = current()
			return setmetatable({}, { __index = function(_, key)
				return function(_, ...)
					local saved = box
					box = groupBox
					local result = api[key](api, ...)
					box = saved
					return result
				end
			end })
		end
		return api
	end

	-- ===== HUD สถานะกลาง (ทุกเกมหน้าตาเดียวกัน): หัว + บรรทัด "ชื่อ: ค่า" ; กดหัวเพื่อย่อ/ขยาย, ลากย้ายได้ =====
	-- อยู่ PlayerGui (ใต้ gethui เขียน Text จาก loop ไม่ได้) ; สร้างเองไม่พึ่ง Library -> ใช้ได้ทั้ง NothingLibrary และ NothingLibrary
	-- ใช้: local hud = UI:CreateHud({ id = "Astral", title = "ASTRAL STATUS", lines = { "World", "Target" } }) ; hud:Set("World", "Ninja Village")
	local huds = {}
	local function createHud(o)
		o = o or {}
		local id = tostring(o.id or o.title or "Hud")
		local UIS = game:GetService("UserInputService")
		local playerGui = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
		local old = playerGui:FindFirstChild("TYHubHud_" .. id)
		if old then old:Destroy() end
		local function color(key, fallback) return (Library.Scheme and Library.Scheme[key]) or fallback end
		local gui = Instance.new("ScreenGui")
		gui.Name, gui.ResetOnSpawn, gui.DisplayOrder = "TYHubHud_" .. id, false, 80
		gui.Parent = playerGui
		-- เกมบางเกมปิด ScreenGui ทุกตัวตอน cutscene -> เปิดคืน
		local shown = true
		gui:GetPropertyChangedSignal("Enabled"):Connect(function() if shown and not gui.Enabled and gui.Parent then gui.Enabled = true end end)
		local frame = Instance.new("Frame")
		-- มุมขวาบน ใต้แถบ TYHUB/topbar (y >= 44) ; ซ้อนกันได้หลายอันด้วย o.offset
		frame.AnchorPoint, frame.Position = Vector2.new(1, 0), UDim2.new(1, -12, 0, 44 + (o.offset or 0))
		frame.Size, frame.AutomaticSize, frame.BackgroundTransparency, frame.Active = UDim2.fromOffset(o.width or 280, 0), Enum.AutomaticSize.Y, 0.06, true
		frame.Parent = gui
		Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 10)
		local stroke = Instance.new("UIStroke", frame)
		stroke.Transparency = 0.35
		local list = Instance.new("UIListLayout", frame)
		list.SortOrder, list.Padding = Enum.SortOrder.LayoutOrder, UDim.new(0, 4)
		local pad = Instance.new("UIPadding", frame)
		pad.PaddingTop, pad.PaddingBottom, pad.PaddingLeft, pad.PaddingRight = UDim.new(0, 8), UDim.new(0, 10), UDim.new(0, 12), UDim.new(0, 12)
		-- หัว: Frame (ไม่ใช้ TextButton -> สคริปต์ hover ของเกมไม่ขยาย) + จับคลิก/ลากเอง
		local head = Instance.new("Frame")
		head.BackgroundTransparency, head.Size, head.LayoutOrder, head.Active = 1, UDim2.new(1, 0, 0, 22), 0, true
		head.Parent = frame
		local title = Instance.new("TextLabel")
		title.BackgroundTransparency, title.Size, title.Font, title.TextSize = 1, UDim2.new(1, -24, 1, 0), Enum.Font.GothamBold, 14
		title.TextXAlignment, title.Text = Enum.TextXAlignment.Left, "TYHUB • " .. tostring(o.title or id)
		title.Parent = head
		local chevron = Instance.new("TextLabel")
		chevron.BackgroundTransparency, chevron.AnchorPoint, chevron.Position, chevron.Size = 1, Vector2.new(1, 0), UDim2.new(1, 0, 0, 0), UDim2.fromOffset(20, 22)
		chevron.Font, chevron.TextSize, chevron.Text, chevron.TextXAlignment = Enum.Font.GothamBold, 16, "–", Enum.TextXAlignment.Right
		chevron.Parent = head
		local body = Instance.new("Frame")
		body.BackgroundTransparency, body.Size, body.AutomaticSize, body.LayoutOrder = 1, UDim2.new(1, 0, 0, 0), Enum.AutomaticSize.Y, 1
		body.Parent = frame
		local bodyList = Instance.new("UIListLayout", body)
		bodyList.SortOrder, bodyList.Padding = Enum.SortOrder.LayoutOrder, UDim.new(0, 4)
		local rows, order, values = {}, 0, {}
		local function paint()
			frame.BackgroundColor3 = color("BackgroundColor", Color3.fromRGB(17, 15, 27))
			stroke.Color = color("AccentColor", Color3.fromRGB(128, 80, 220))
			title.TextColor3 = color("AccentColor", Color3.fromRGB(205, 177, 255))
			chevron.TextColor3 = color("FontColor", Color3.new(1, 1, 1))
			for _, row in pairs(rows) do row.TextColor3 = color("FontColor", Color3.fromRGB(235, 235, 240)) end
		end
		local function row(key)
			if rows[key] then return rows[key] end
			order = order + 1
			local label = Instance.new("TextLabel")
			label.BackgroundTransparency, label.Size, label.AutomaticSize, label.LayoutOrder = 1, UDim2.new(1, 0, 0, 16), Enum.AutomaticSize.Y, order
			label.Font, label.TextSize, label.TextWrapped, label.TextXAlignment = Enum.Font.Gotham, 12, true, Enum.TextXAlignment.Left
			label.Text = T(key) .. ": -"
			label.Parent, rows[key] = body, label
			paint()
			return label
		end
		for _, key in ipairs(o.lines or {}) do row(key) end
		paint()
		table.insert(themeRefreshers, paint)
		onLang(function() for key, label in pairs(rows) do label.Text = T(key) .. ": " .. tostring(values[key] or "-") end end)
		-- กด = ย่อ/ขยาย ; ลากเกิน 6px = ย้าย (ไม่นับเป็นกด)
		local dragging, start, startPos, moved
		head.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				dragging, start, startPos, moved = true, input.Position, frame.Position, false
			end
		end)
		UIS.InputChanged:Connect(function(input)
			if not dragging then return end
			if input.UserInputType ~= Enum.UserInputType.MouseMovement and input.UserInputType ~= Enum.UserInputType.Touch then return end
			if input.UserInputType == Enum.UserInputType.MouseMovement and not UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then dragging = false return end
			local delta = input.Position - start
			if delta.Magnitude > 6 then moved = true end
			if moved then frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y) end
		end)
		UIS.InputEnded:Connect(function(input)
			if dragging and (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
				dragging = false
				if not moved then body.Visible = not body.Visible; chevron.Text = body.Visible and "–" or "+" end
			end
		end)
		local hud = {}
		function hud:Set(key, value)
			values[key] = value
			pcall(function() local r = row(key); r.Text = T(key) .. ": " .. tostring(value); r.Visible = true end)
		end
		-- ซ่อนบรรทัด (เช่นงานที่ปิดอยู่) ; Set ครั้งถัดไปโชว์กลับเอง
		function hud:Hide(key) if rows[key] then rows[key].Visible = false end end
		function hud:SetTitle(text) pcall(function() title.Text = "TYHUB • " .. tostring(text) end) end
		function hud:SetVisible(visible) shown = visible ~= false; gui.Enabled = shown end
		function hud:Destroy() pcall(function() gui:Destroy() end) end
		table.insert(huds, hud)
		return hud
	end

	-- ไอคอน Lucide อัตโนมัติตามชื่อแท็บ (ตัวพิมพ์เล็ก) ; ชื่อไอคอนต้องมีใน components/icons.lua
	local TAB_ICONS = {}
	for icon, names in pairs({
		crosshair = { "combat", "player esp & aim" }, eye = { "visual", "visuals" }, settings = { "settings" },
		house = { "main", "auto", "play", "dashboard" },
		sprout = { "farm", "stage farm", "stage", "progression", "catch pet" },
		["paw-print"] = { "pets", "pet", "pets & stones", "eggs & ranch" },
		["shopping-cart"] = { "shop", "sell", "sell & shop", "buy & sell", "sell & upgrade", "shop & rewards" },
		["trending-up"] = { "upgrade", "upgrades", "speed & upgrades", "rewards & upgrade" },
		["refresh-cw"] = { "rebirth", "train & rebirth", "world & rebirth" },
		gift = { "rewards" }, hammer = { "forge", "sword", "rune & enchant", "pickaxe" }, fish = { "fishing" },
		package = { "cases", "crates" }, server = { "lobby", "lobby & run", "server", "games" }, store = { "market" },
		castle = { "tower", "endless spire", "pyramid" }, ["calendar-days"] = { "gamemodes", "event", "battle pass" },
		bot = { "automation", "advanced" }, gem = { "loot" }, pickaxe = { "dig", "mine" }, combine = { "fuse" },
		user = { "player" }, ["search-code"] = { "inspect / export" },
	}) do
		for _, name in ipairs(names) do TAB_ICONS[name] = icon end
	end

	return {
		CreateHud = function(_, o) return createHud(o) end,
		-- NothingLibrary:Notify({ Title, Content, Duration }) -> NothingLibrary Notify
		Notify = function(_, o)
			pcall(function() Library:Notify({ Title = T(o.Title or ""), Description = T(o.Content or ""), Time = o.Duration or 5 }) end)
		end,
		-- 2 ภาษา: UI:AddLang("th", { ["English text"] = "ข้อความไทย" }) เรียกก่อนสร้าง element ; UI.T(text) แปลเอง ; UI:GetLang()
		AddLang = function(_, code, map)
			dict[code] = dict[code] or {}
			for key, value in pairs(map) do dict[code][key] = value end
		end,
		T = T,
		Perf = perf,
		GetLang = function() return lang end,
		SetLang = function(_, code) setLang(code) end,
		CreateWindow = function(uiModule, opts)
			-- เวอร์ชันที่ build ฝังไว้หัวสคริปต์เกม (tools/build.sh)
			local env = type(getgenv) == "function" and getgenv() or _G
			local version = env.TYHUB_VERSION
			local window = Library:CreateWindow({
				Title = "TY hub｜" .. tostring(opts.name or "通用功能"), Footer = (opts.subtitle or "") .. (version and ("  •  " .. version) or ""), Icon = tonumber(tostring(opts.icon or "111057789576017"):match("%d+")), -- ไม่ระบุ = โลโก้ TYHUB (เดิมตกไปใช้รูปเกม)
				Center = true, AutoShow = true, ToggleKeybind = Enum.KeyCode.RightControl,
			})
window:OnClose(function() if api.onClose then task.spawn(api.onClose) end; api.Unload() end)
			api.CreateTab = function(_, tabOpts)
				-- image (รูปจากเกม) ส่งเฉพาะ NothingLibrary ; NothingLibrary ตีความ arg ที่ 2 เป็นชื่อไอคอน lucide
				-- folder = ค่าที่ได้จาก CreateFolder (หัวข้อพับได้ใน sidebar)
				-- ไม่ใส่ image -> ไอคอน Lucide ตามชื่อแท็บ (TAB_ICONS) ; เกมที่ใส่รูปเฉพาะของเกมเองไม่ถูกทับ
				local image = tabOpts.image or TAB_ICONS[tostring(tabOpts.name):lower()]
				local tab = window:AddTab(T(tabOpts.name), Library.IsTYHub and image or nil, tabOpts.folder and tabOpts.folder._f or nil)
				local tabButton = Library.TabButtons and Library.TabButtons[#Library.TabButtons]
				if tabButton and tabButton.Label then onLang(function() tabButton.Label.Text = T(tabOpts.name) end) end
				if tostring(tabOpts.name):lower() == "settings" then pcall(addConfigBox, tab); pcall(addPerfBox, tab) end
				return wrapTab(tab)
			end
			-- หัวข้อใน sidebar: CreateFolder({ name, image }) แล้วส่ง folder = ... ให้ CreateTab ; renderer ไม่มี folder = แท็บเรียงปกติ
			api.CreateFolder = function(_, o)
				if not window.AddFolder then return {} end
				local f = window:AddFolder(T(o.name), o.image)
				onLang(function() f.Label.Text = T(o.name) end)
				return { _f = f, SetOpen = function(_, v) f:SetOpen(v) end }
			end
			-- loop ในสคริปต์รอ Window.unloaded เพื่อหยุดตัวเอง
			api.Unload = function()
				if api.unloaded then return end
				api.unloaded = true
				
				restorePerf()
				for _, hud in ipairs(huds) do hud:Destroy() end
				pcall(function() Library:Unload() end)
			end
			return api
		end,
	}
end)()

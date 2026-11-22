-- 抢劫他：独立服务器缝合版
local NothingLibrary = loadstring(game:HttpGetAsync('https://raw.githubusercontent.com/quanwei-sy/qianweicangku/refs/heads/main/%E6%BA%90%E7%A0%81.lua'))()

local __BaseWindow = NothingLibrary.new({
    Title = "TY hub｜抢劫他",
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
	Title = '抢劫他 - [AI版]',
	Footer = "权威不是权威",
    Icon = 131153193945220,
	Center = true,
	AutoShow = true,
	Resizable = true,
	TabPadding = 8,
	MenuFadeTime = 0
})

-- 标签页定义[span_5](start_span)[span_5](end_span)
local Tabs = {
    Map = Window:AddTab('地图', 'map'),
    Func = Window:AddTab('功能', 'zap'),
    ESP = Window:AddTab('透视', 'eye'),
    ["UI Settings"] = Window:AddTab('UI 调试', 'settings'),
}

-- 常用服务引用
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local ProximityPromptService = game:GetService("ProximityPromptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local LocalPlayer = Players.LocalPlayer

-- 通用坐标获取辅助函数
local function getTargetPart(obj)
    if not obj then return nil end
    if obj:IsA("BasePart") then
        return obj
    elseif obj:IsA("Model") then
        local mainBox = obj:FindFirstChild("MainBox")
        if mainBox then
            if mainBox:IsA("BasePart") then return mainBox end
            local mp = mainBox:FindFirstChildWhichIsA("BasePart", true)
            if mp then return mp end
        end

        local specPart = obj:FindFirstChild("Part") or obj:FindFirstChild("Box") or obj:FindFirstChild("Cam")
        if specPart and specPart:IsA("BasePart") then
            return specPart
        end

        local hrp = obj:FindFirstChild("HumanoidRootPart") or obj:FindFirstChild("Head")
        if hrp and hrp:IsA("BasePart") then return hrp end

        if obj.PrimaryPart and obj.PrimaryPart.Name ~= "ZonePart" then
            return obj.PrimaryPart
        end

        for _, desc in ipairs(obj:GetDescendants()) do
            if desc:IsA("BasePart") and desc.Name ~= "ZonePart" then
                return desc
            end
        end

        return obj:FindFirstChildWhichIsA("BasePart", true)
    end
    return nil
end

local function getObjectPosition(obj, targetPart)
    if targetPart and targetPart:IsA("BasePart") then
        return targetPart.Position
    end
    local ok, pivot = pcall(function() return obj:GetPivot() end)
    if ok and pivot then
        return pivot.Position
    end
    return nil
end

-- ============================================================================
-- [ 地图 (Map) 标签页 - 左侧：传送功能模块 ]
-- ============================================================================
local MapLeftGroup = Tabs.Map:AddLeftGroupbox('传送功能')

local function teleportToTarget(targetObj, targetName, isTruck)
    if not targetObj then
        Library:Notify("未找到目标: " .. tostring(targetName) .. "，请确认地图是否已加载！", 3)
        return
    end

    local char = LocalPlayer.Character
    local rootPart = char and (char:FindFirstChild("HumanoidRootPart") or char.PrimaryPart)
    if not rootPart then
        Library:Notify("角色尚未加载完成，无法传送！", 3)
        return
    end

    local targetPos = nil
    local targetCFrame = nil

    if targetObj:IsA("Model") then
        local ok, cf = pcall(function() return targetObj:GetPivot() end)
        if ok and cf then
            targetCFrame = cf
            targetPos = cf.Position
        end
    end

    if not targetPos then
        local part = getTargetPart(targetObj)
        if part then
            targetPos = part.Position
            targetCFrame = part.CFrame
        end
    end

    if targetPos and targetCFrame then
        rootPart.AssemblyLinearVelocity = Vector3.zero
        if isTruck then
            -- 优化卡车传送：将传送点向卡车内部/后方偏移，确保直接传进车厢内部
            rootPart.CFrame = targetCFrame * CFrame.new(0, 2, -4)
        else
            rootPart.CFrame = CFrame.new(targetPos + Vector3.new(0, 3, 0))
        end
        Library:Notify("已成功传送至: " .. tostring(targetName), 2)
    else
        Library:Notify("无法获取 " .. tostring(targetName) .. " 的有效坐标！", 3)
    end
end

MapLeftGroup:AddButton('传送卡车', function()
    local mapFolder = workspace:FindFirstChild("Map")
    local truck = (mapFolder and mapFolder:FindFirstChild("Truck")) or workspace:FindFirstChild("Truck", true)
    teleportToTarget(truck, "卡车内部 (Truck)", true)
end)

MapLeftGroup:AddButton('传送配电箱', function()
    local elecBox = workspace:FindFirstChild("ElectricBox")
    if not elecBox then
        local mapFolder = workspace:FindFirstChild("Map")
        elecBox = (mapFolder and mapFolder:FindFirstChild("ElectricBox", true)) or workspace:FindFirstChild("ElectricBox", true)
    end

    local mainBox = elecBox and (elecBox:FindFirstChild("MainBox") or elecBox:FindFirstChild("Part") or elecBox)
    teleportToTarget(mainBox, "配电箱 (ElectricBox)", false)
end)


-- ============================================================================
-- [ 功能 (Func) 标签页 - 左侧：实用功能模块 & 右侧：自动攻击模块 ]
-- ============================================================================
FuncLeftGroup = Tabs.Func:AddLeftGroupbox('实用功能')
local FuncRightGroup = Tabs.Func:AddRightGroupbox('自动攻击 / 破拆')

local OriginalWalkSpeed = 16
local SavedPartCollisions = {}

local function captureOriginalStats(char)
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if hum and hum.WalkSpeed > 0 then
        if not (Toggles.EnableSpeed and Toggles.EnableSpeed.Value) then
            OriginalWalkSpeed = hum.WalkSpeed
        end
    end
end

if LocalPlayer.Character then
    captureOriginalStats(LocalPlayer.Character)
end

FuncLeftGroup:AddToggle('InfJump', {
    Text = '无限跳跃',
    Default = false,
    Tooltip = '开启后可在空中无限次数跳跃'
})

FuncLeftGroup:AddToggle('Noclip', {
    Text = '穿墙',
    Default = false,
    Tooltip = '开启后角色可穿过墙壁与障碍物，关闭后恢复原本碰撞'
})

FuncLeftGroup:AddToggle('AutoHoldPrompt', {
    Text = '自动按住交互 (免手动长按)',
    Default = false,
    Tooltip = '靠近物品出现提示时自动帮你按住交互键跑完进度条'
})

FuncLeftGroup:AddButton('一键点亮全图图鉴', function()
    local count = 0
    pcall(function()
        local remotes = ReplicatedStorage:FindFirstChild("Remotes")
        local event = remotes and remotes:FindFirstChild("LayedEyesUponItem")
        if not event then
            Library:Notify("未找到 LayedEyesUponItem 远程事件！", 3)
            return
        end
        for _, desc in ipairs(workspace:GetDescendants()) do
            if desc:IsA("ProximityPrompt") and desc:GetAttribute("LayedEyesUpon") == false then
                event:FireServer(desc)
                count = count + 1
            end
        end
    end)
    Library:Notify("已成功发送远程包，点亮了 " .. tostring(count) .. " 个未见过的物资图鉴！", 4)
end)

FuncLeftGroup:AddToggle('EnableSpeed', {
    Text = '启用移速',
    Default = false,
    Tooltip = '开启自定义移动速度，关闭后自动恢复原本默认移速 (' .. tostring(OriginalWalkSpeed) .. ')'
})

FuncLeftGroup:AddSlider('SpeedSlider', {
    Text = '移速设置 (原本默认: ' .. tostring(OriginalWalkSpeed) .. ')',
    Default = 30,
    Min = 1,
    Max = 150,
    Rounding = 0,
    Compact = false,
    Tooltip = '滑动调节移动速度'
})

-- 右侧：自动攻击 / 破拆 UI 控件定义（频率 0.1秒 / 连续发送 10 次）
FuncRightGroup:AddToggle('AutoAttackAura', {
    Text = '启用自动攻击光环',
    Default = false,
    Tooltip = '开启后自动高频对周围敌人/收银机发送打击包'
})

FuncRightGroup:AddToggle('AuraRequireCrowbar', {
    Text = '仅限手持撬棍 (推荐)',
    Default = true,
    Tooltip = '开启后只有手持撬棍时才发包，防止空手被服务器检测异常'
})

FuncRightGroup:AddToggle('AuraHitNPC', {
    Text = '自动打安保 / 狙击手',
    Default = true,
    Tooltip = '靠近敌人安保或精英狙击手时自动攻击'
})

FuncRightGroup:AddToggle('AuraHitCashier', {
    Text = '自动砸收银机',
    Default = true,
    Tooltip = '靠近收银机时自动砸开'
})

FuncRightGroup:AddToggle('AuraBreakEnv', {
    Text = '自动破门 / 砸玻璃',
    Default = false,
    Tooltip = '靠近可破坏的门或窗户玻璃时自动破拆'
})

FuncRightGroup:AddSlider('AuraRange', {
    Text = '自动攻击范围 (米)',
    Default = 15,
    Min = 5,
    Max = 30,
    Rounding = 0,
    Compact = false,
    Tooltip = '设置自动攻击光环的触发半径'
})

-- 逻辑实现
local infJumpConnection = UserInputService.JumpRequest:Connect(function()
    if Toggles.InfJump and Toggles.InfJump.Value then
        local char = LocalPlayer.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum and hum:GetState() ~= Enum.HumanoidStateType.Dead then
            hum:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end)

local activeAutoPrompts = {}
local promptShownConn = ProximityPromptService.PromptShown:Connect(function(prompt)
    if Toggles.AutoHoldPrompt and Toggles.AutoHoldPrompt.Value then
        task.spawn(function()
            task.wait(0.05)
            if prompt and prompt.Parent and Toggles.AutoHoldPrompt.Value then
                activeAutoPrompts[prompt] = true
                pcall(function() prompt:InputHoldBegin() end)
            end
        end)
    end
end)

local promptHiddenConn = ProximityPromptService.PromptHidden:Connect(function(prompt)
    if activeAutoPrompts[prompt] then
        activeAutoPrompts[prompt] = nil
        pcall(function() prompt:InputHoldEnd() end)
    end
end)

Toggles.AutoHoldPrompt:OnChanged(function()
    if not Toggles.AutoHoldPrompt.Value then
        for prompt, _ in pairs(activeAutoPrompts) do
            pcall(function() prompt:InputHoldEnd() end)
        end
        table.clear(activeAutoPrompts)
    end
end)

local function restoreCollisions()
    for part, canCollide in pairs(SavedPartCollisions) do
        if part and part.Parent then
            pcall(function() part.CanCollide = canCollide end)
        end
    end
    table.clear(SavedPartCollisions)
end

Toggles.Noclip:OnChanged(function()
    if not Toggles.Noclip.Value then restoreCollisions() end
end)

local function restoreWalkSpeed()
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if hum then hum.WalkSpeed = OriginalWalkSpeed end
end

local function getTargetSpeed()
    return (Options.SpeedSlider and Options.SpeedSlider.Value) or 30
end

Toggles.EnableSpeed:OnChanged(function()
    if Toggles.EnableSpeed.Value then
        local char = LocalPlayer.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum and hum.WalkSpeed ~= getTargetSpeed() then OriginalWalkSpeed = hum.WalkSpeed end
    else
        restoreWalkSpeed()
    end
end)

local charAddedConnection = LocalPlayer.CharacterAdded:Connect(function(newChar)
    table.clear(SavedPartCollisions)
    local hum = newChar:WaitForChild("Humanoid", 5)
    if hum and not (Toggles.EnableSpeed and Toggles.EnableSpeed.Value) then
        OriginalWalkSpeed = hum.WalkSpeed
    end
end)

-- 自动攻击光环：频率 0.1秒 / 连续发送 10 次
local lastAttackTime = 0

local function runAutoAttackAura()
    if not (Toggles.AutoAttackAura and Toggles.AutoAttackAura.Value) then return end
    if tick() - lastAttackTime < 0.1 then return end -- 改为 0.1 秒高频频率

    local char = LocalPlayer.Character
    local rootPart = char and (char:FindFirstChild("HumanoidRootPart") or char.PrimaryPart)
    if not rootPart then return end

    local equippedTool = char:FindFirstChildOfClass("Tool")
    if Toggles.AuraRequireCrowbar and Toggles.AuraRequireCrowbar.Value then
        if not equippedTool then return end
    end
    local toolName = (equippedTool and equippedTool.Name) or "Crowbar"

    local range = (Options.AuraRange and Options.AuraRange.Value) or 15
    local remotes = ReplicatedStorage:FindFirstChild("Remotes")
    if not remotes then return end

    local toolsRemotes = remotes:FindFirstChild("Tools")
    local utilRemotes = remotes:FindFirstChild("Utilities")
    local mapFolder = workspace:FindFirstChild("Map")

    lastAttackTime = tick()

    -- 循环发送 10 次
    for _ = 1, 10 do
        -- A. 自动攻击安保与精英狙击手
        if Toggles.AuraHitNPC and Toggles.AuraHitNPC.Value and toolsRemotes and toolsRemotes:FindFirstChild("HitNPC") then
            local hitNPCEvent = toolsRemotes.HitNPC
            local function checkAndHitFolder(folder)
                if not folder then return end
                for _, npc in ipairs(folder:GetChildren()) do
                    local part = getTargetPart(npc)
                    local pos = getObjectPosition(npc, part)
                    if pos and (rootPart.Position - pos).Magnitude <= range then
                        local targetArg = part or npc
                        pcall(function()
                            hitNPCEvent:FireServer(targetArg, toolName)
                            hitNPCEvent:FireServer(npc, toolName)
                        end)
                    end
                end
            end
            if mapFolder then
                checkAndHitFolder(mapFolder:FindFirstChild("NPCS"))
                checkAndHitFolder(mapFolder:FindFirstChild("EliteSnipers"))
            end
        end

        -- B. 自动砸收银机
        if Toggles.AuraHitCashier and Toggles.AuraHitCashier.Value and utilRemotes and utilRemotes:FindFirstChild("HitCashier") then
            local hitCashierEvent = utilRemotes.HitCashier
            for _, cashier in ipairs(CollectionService:GetTagged("Cashiers")) do
                if cashier and cashier:IsDescendantOf(workspace) then
                    local pos = getObjectPosition(cashier, getTargetPart(cashier))
                    if pos and (rootPart.Position - pos).Magnitude <= range then
                        pcall(function() hitCashierEvent:FireServer(cashier, toolName) end)
                    end
                end
            end
        end

        -- C. 自动破门与砸玻璃
        if Toggles.AuraBreakEnv and Toggles.AuraBreakEnv.Value and utilRemotes then
            local breakWindowEvent = utilRemotes:FindFirstChild("BreakWindow")
            local breakDoorEvent = utilRemotes:FindFirstChild("BreakDoor")

            if breakWindowEvent then
                for _, glass in ipairs(CollectionService:GetTagged("BreakableGlass")) do
                    if glass and glass:IsDescendantOf(workspace) then
                        local pos = getObjectPosition(glass, getTargetPart(glass))
                        if pos and (rootPart.Position - pos).Magnitude <= range then
                            pcall(function() breakWindowEvent:FireServer(glass) end)
                        end
                    end
                end
            end

            for _, folder in ipairs(CollectionService:GetTagged("Breakable")) do
                if folder and folder:IsDescendantOf(workspace) then
                    if folder.Name == "Doors" and breakDoorEvent then
                        for _, doorModel in ipairs(folder:GetChildren()) do
                            local pos = getObjectPosition(doorModel, getTargetPart(doorModel))
                            if pos and (rootPart.Position - pos).Magnitude <= range then
                                pcall(function() breakDoorEvent:FireServer(doorModel) end)
                            end
                        end
                    elseif folder.Name == "BreakableGlass" and breakWindowEvent then
                        for _, glassObj in ipairs(folder:GetChildren()) do
                            local pos = getObjectPosition(glassObj, getTargetPart(glassObj))
                            if pos and (rootPart.Position - pos).Magnitude <= range then
                                pcall(function() breakWindowEvent:FireServer(glassObj) end)
                            end
                        end
                    end
                end
            end
        end
    end
end

local funcSteppedConnection = RunService.Stepped:Connect(function()
    local char = LocalPlayer.Character
    if not char then return end

    if Toggles.Noclip and Toggles.Noclip.Value then
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                if SavedPartCollisions[part] == nil then SavedPartCollisions[part] = part.CanCollide end
                if part.CanCollide then part.CanCollide = false end
            end
        end
    end

    if Toggles.EnableSpeed and Toggles.EnableSpeed.Value then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then
            local targetSpd = getTargetSpeed()
            if hum.WalkSpeed ~= targetSpd then hum.WalkSpeed = targetSpd end
        end
    end

    runAutoAttackAura()
end)


-- ============================================================================
-- [ 物资翻译字典 & 透视核心逻辑 ]
-- ============================================================================
local ItemTranslations = {
    ["ElectricBox"] = "配电箱", ["Electric Box"] = "配电箱",
    ["Cashier"] = "收银机", ["Cashiers"] = "收银机", ["Register"] = "收银机",
    ["SmallVault"] = "小型保险柜", ["MediumVault"] = "中型保险柜", ["BigVault"] = "大型保险柜", ["Safe"] = "保险箱",
    ["Ad Monitor"] = "广告显示器", ["Art"] = "艺术品", ["Bed"] = "床", ["Boat Console"] = "船只控制台",
    ["Bow & Arrow"] = "弓箭", ["Calculator"] = "计算器", ["Candy Machine"] = "糖果机", ["Chair"] = "椅子",
    ["Clock"] = "时钟", ["Coffee Machine"] = "咖啡机", ["Computers"] = "电脑套装", ["Cookware"] = "厨具",
    ["Crown"] = "皇冠", ["Crypto"] = "加密货币矿机", ["Cutting Board"] = "菜板", ["Dance Machine"] = "跳舞机",
    ["Decoration"] = "装饰品", ["Designer Clothing"] = "名牌服装", ["Designer Pants"] = "名牌裤子", ["Designer Shirt"] = "名牌衬衫",
    ["Duck"] = "小黄鸭", ["Electronics"] = "电子产品", ["Fridge"] = "冰箱", ["Game Machine"] = "游戏机",
    ["GameBoy"] = "掌上游戏机", ["Gem"] = "宝石", ["Gold"] = "黄金", ["Golden Bracelet"] = "金手镯",
    ["Golden Coin"] = "金币", ["Golden Decor"] = "金饰品", ["Golden Watch"] = "金表", ["Guitar"] = "吉他",
    ["Hand Fan"] = "手扇", ["Harp"] = "竖琴", ["Helicopter"] = "直升机", ["Instrument"] = "乐器",
    ["Ipad"] = "平板电脑", ["Iron"] = "铁块", ["Jet Ski"] = "摩托艇", ["Jewerly"] = "珠宝",
    ["Jousting"] = "骑士长枪", ["Laptop"] = "笔记本电脑", ["Luxery Pillow"] = "奢华枕头", ["Microwave"] = "微波炉",
    ["Mirror"] = "镜子", ["Money"] = "现金", ["Money bag"] = "钱袋", ["Monitor"] = "显示器",
    ["Old Instrument"] = "古董乐器", ["Old Phone"] = "老式电话", ["PC Setup"] = "高配电脑桌", ["Painting"] = "画作",
    ["Pair Sneaker"] = "双子球鞋", ["Phone"] = "手机", ["Piano"] = "钢琴", ["Pillow"] = "枕头",
    ["PingPong Table"] = "乒乓球桌", ["Plates"] = "盘子", ["Pool Table"] = "台球桌", ["Printer"] = "打印机",
    ["Rare Stone"] = "稀有矿石", ["Ring"] = "戒指", ["Scroll"] = "卷轴", ["Silver"] = "白银",
    ["Sneakers"] = "运动鞋", ["Sofa"] = "沙发", ["Speaker"] = "音响", ["Statue"] = "雕像",
    ["Stove"] = "炉灶", ["SuperGem"] = "超级宝石", ["Surf"] = "冲浪板", ["Sword"] = "宝剑",
    ["T-Rex"] = "霸王龙化石", ["TV"] = "电视机", ["Toilet"] = "马桶", ["Tool"] = "工具",
    ["Toy"] = "玩具", ["Trampoline"] = "蹦床", ["Trophy"] = "奖杯", ["Valuable"] = "贵重物品",
    ["Vase"] = "花瓶", ["Vault"] = "保险金库", ["Vending Machine"] = "自动售货机", ["Violin"] = "小提琴",
    ["Washing Machine"] = "洗衣机", ["Water Dispenser"] = "饮水机", ["Weapon"] = "武器",
    ["ATM"] = "自动取款机", ["Alien"] = "外星人", ["Backpack"] = "双肩包", ["Bee"] = "蜜蜂",
    ["Boombox"] = "手提音响", ["Briefcase"] = "公文包", ["Chest"] = "宝箱", ["Claw Machine"] = "娃娃机",
    ["Cow"] = "奶牛", ["Default"] = "默认背包", ["Duffle"] = "行李袋", ["Heist Drone"] = "劫掠无人机",
    ["Knight"] = "骑士", ["Luggage"] = "行李箱", ["Luxery Duffle"] = "奢华行李袋", ["Machinery"] = "机械装置",
    ["Magician"] = "魔术师", ["Medic"] = "医疗包", ["Mushroom"] = "蘑菇", ["Nuke Launcher"] = "核弹发射器",
    ["Panda"] = "熊猫", ["Plasma Reactor"] = "等离子反应堆", ["Robot"] = "机器人", ["Rocket"] = "火箭",
    ["Slots"] = "老虎机", ["Street Pack"] = "街头潮流包", ["Travel"] = "旅行包"
}

local RarityNames = { [1] = "普通", [2] = "优秀", [3] = "稀有", [4] = "传说", [5] = "神话" }
local RarityColors = {
    [1] = Color3.fromRGB(183, 191, 197),
    [2] = Color3.fromRGB(0, 212, 71),
    [3] = Color3.fromRGB(0, 175, 255),
    [4] = Color3.fromRGB(255, 157, 0),
    [5] = Color3.fromRGB(206, 89, 255)
}

local LowerTranslations = {}
for k, v in pairs(ItemTranslations) do LowerTranslations[string.lower(k)] = v end

local function getChineseName(rawName)
    if ItemTranslations[rawName] then return ItemTranslations[rawName] end
    local lower = string.lower(rawName)
    if LowerTranslations[lower] then return LowerTranslations[lower] end
    local cleanName = string.gsub(rawName, "[%d_%-%s]+$", "")
    if ItemTranslations[cleanName] then return ItemTranslations[cleanName] end
    if string.find(lower, "electricbox") then return "配电箱" end
    if string.find(lower, "cashier") or string.find(lower, "register") then return "收银机" end
    if string.find(lower, "vault") then return "保险柜 (" .. rawName .. ")" end
    return rawName
end

local function getItemWorth(obj)
    if not obj then return 0 end
    local prompt = obj:FindFirstChild("StealPrompt", true) or obj:FindFirstChildWhichIsA("ProximityPrompt", true)
    if prompt then
        local pWorth = prompt:GetAttribute("Worth") or prompt:GetAttribute("worth")
        if tonumber(pWorth) then return tonumber(pWorth) end
    end
    local attr = obj:GetAttribute("worth") or obj:GetAttribute("Worth") or obj:GetAttribute("Value")
    if tonumber(attr) then return tonumber(attr) end
    return 0
end

local function getItemExtraInfo(obj)
    if not obj then return false, nil, nil end
    local prompt = obj:FindFirstChild("StealPrompt", true) or obj:FindFirstChildWhichIsA("ProximityPrompt", true)
    local isDiamond = false
    local rarity = nil
    local mutation = nil

    if prompt then
        if prompt:GetAttribute("Diamond") == true then isDiamond = true end
        rarity = tonumber(prompt:GetAttribute("Rarity"))
        mutation = prompt:GetAttribute("Mutation")
    end
    if not isDiamond and (obj:GetAttribute("Diamond") == true or obj.Name == "Gem" or obj.Name == "SuperGem") then isDiamond = true end
    if not rarity then rarity = tonumber(obj:GetAttribute("Rarity")) end
    if not mutation then mutation = obj:GetAttribute("Mutation") or (obj.Parent and obj.Parent:GetAttribute("Mutation")) end
    return isDiamond, rarity, mutation
end

local function getItemColor(obj, worth, isDiamond, rarity)
    if isDiamond then
        return (obj and obj.Name == "SuperGem") and Color3.fromRGB(212, 84, 255) or Color3.fromRGB(80, 255, 255)
    end
    if rarity and RarityColors[rarity] then return RarityColors[rarity] end
    if worth <= 0 then return Color3.fromRGB(80, 255, 255)
    elseif worth < 300 then return RarityColors[1]
    elseif worth < 1000 then return RarityColors[2]
    elseif worth < 3000 then return RarityColors[3]
    elseif worth < 10000 then return RarityColors[4]
    else return RarityColors[5] end
end

-- UI 透视标签页构建
local ESPLeftGroup = Tabs.ESP:AddLeftGroupbox('透视功能')
local ESPRightGroup = Tabs.ESP:AddRightGroupbox('透视设置')

ESPLeftGroup:AddToggle('ItemESP', { Text = '物资透视', Default = false })
ESPLeftGroup:AddToggle('CashierESP', { Text = '收银机透视', Default = false }):AddColorPicker('CashierESPColor', { Default = Color3.fromRGB(50, 255, 110), Title = '收银机颜色' })
ESPLeftGroup:AddToggle('VaultESP', { Text = '保险柜透视', Default = false }):AddColorPicker('VaultESPColor', { Default = Color3.fromRGB(0, 255, 215), Title = '保险柜颜色' })
ESPLeftGroup:AddToggle('ElectricBoxESP', { Text = '配电箱透视', Default = false }):AddColorPicker('ElectricBoxESPColor', { Default = Color3.fromRGB(255, 165, 0), Title = '配电箱颜色' })
ESPLeftGroup:AddToggle('NPCESP', { Text = '安保透视 (含狙击手)', Default = false }):AddColorPicker('NPCESPColor', { Default = Color3.fromRGB(255, 110, 110), Title = '安保颜色' })

ESPRightGroup:AddToggle('ESPShowName', { Text = '显示名字', Default = true })
ESPRightGroup:AddToggle('ESPShowMutation', { Text = '显示变异', Default = false })
ESPRightGroup:AddToggle('ESPShowWorth', { Text = '显示价值 (Worth)', Default = true })
ESPRightGroup:AddToggle('ESPShowDistance', { Text = '显示距离', Default = false })
ESPRightGroup:AddToggle('ESPShowHighlight', { Text = '显示高亮', Default = true })
ESPRightGroup:AddSlider('ESPHighlightTrans', { Text = '高亮透明度', Default = 0.6, Min = 0, Max = 1, Rounding = 2 })
ESPRightGroup:AddSlider('ESPTextSize', { Text = '字体大小', Default = 5, Min = 1, Max = 50, Rounding = 0 })
ESPRightGroup:AddInput('ESPMinWorthInput', { Default = '1200', Numeric = true, Text = '最低价值过滤' })

local ItemESPObjects, CashierESPObjects, VaultESPObjects, ElectricESPObjects, NPCESPObjects = {}, {}, {}, {}, {}
local ItemESPConnections, CashierESPConnections, VaultESPConnections, ElectricESPConnections, NPCESPConnections = {}, {}, {}, {}, {}

local function getHighlightAdornee(obj)
    if obj:IsA("Model") then
        local mainBox = obj:FindFirstChild("MainBox")
        if mainBox then return mainBox end
    end
    return obj
end

local function removeESPFromTable(tbl, obj)
    local data = tbl[obj]
    if data then
        if data.Highlight then pcall(function() data.Highlight:Destroy() end) end
        if data.Billboard then pcall(function() data.Billboard:Destroy() end) end
        if data.AncestryConn then data.AncestryConn:Disconnect() end
        tbl[obj] = nil
    end
end

local function buildESPComponents(obj, tagPrefix, initColor, cnName, isEnabled)
    local data = {}
    data.CNName = cnName
    local targetPart = getTargetPart(obj)
    local highTarget = getHighlightAdornee(obj)

    if obj:IsA("Model") and (not obj.PrimaryPart or obj.PrimaryPart.Name == "ZonePart") and targetPart then
        pcall(function() obj.PrimaryPart = targetPart end)
    end

    local highlight = Instance.new("Highlight")
    highlight.Name = tagPrefix .. "_Highlight"
    highlight.Adornee = highTarget
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.FillColor = initColor
    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
    highlight.FillTransparency = Options.ESPHighlightTrans and Options.ESPHighlightTrans.Value or 0.6
    highlight.OutlineTransparency = 0.1
    highlight.Enabled = isEnabled and Toggles.ESPShowHighlight.Value
    highlight.Parent = highTarget
    data.Highlight = highlight

    local attachParent = targetPart or highTarget or obj
    local billboard = Instance.new("BillboardGui")
    billboard.Name = tagPrefix .. "_Billboard"
    billboard.Adornee = attachParent
    billboard.AlwaysOnTop = true
    billboard.Size = UDim2.new(0, 220, 0, 130)
    billboard.StudsOffset = Vector3.new(0, 0, 0)
    billboard.MaxDistance = math.huge
    billboard.Enabled = isEnabled and (Toggles.ESPShowName.Value or Toggles.ESPShowDistance.Value or Toggles.ESPShowMutation.Value)
    billboard.Parent = attachParent

    local label = Instance.new("TextLabel")
    label.Name = "ESPText"
    label.Parent = billboard
    label.BackgroundTransparency = 1
    label.Size = UDim2.new(1, 0, 1, 0)
    label.Font = Enum.Font.GothamBold
    label.TextColor3 = initColor
    label.TextStrokeTransparency = 0.15
    label.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    label.TextSize = math.clamp(Options.ESPTextSize.Value or 5, 1, 50)
    label.Text = cnName

    data.Billboard = billboard
    data.Label = label
    return data
end

-- 模块注册与监听
local function createItemESP(obj)
    if ItemESPObjects[obj] or obj:IsA("Folder") or obj.Name == "Natural" then return end
    if not (obj:IsA("Model") or obj:IsA("BasePart")) then return end
    local worth = getItemWorth(obj)
    local isDiamond, rarity = getItemExtraInfo(obj)
    local data = buildESPComponents(obj, "GeHub_ItemESP", getItemColor(obj, worth, isDiamond, rarity), getChineseName(obj.Name), Toggles.ItemESP.Value)
    data.Worth = worth
    data.AncestryConn = obj.AncestryChanged:Connect(function(_, parent) if not parent then removeESPFromTable(ItemESPObjects, obj) end end)
    ItemESPObjects[obj] = data
end

local function toggleItemESPSystem(enabled)
    for _, conn in ipairs(ItemESPConnections) do conn:Disconnect() end
    table.clear(ItemESPConnections)
    if not enabled then for obj in pairs(ItemESPObjects) do removeESPFromTable(ItemESPObjects, obj) end return end
    local stealableFolder = workspace:FindFirstChild("Map") and workspace.Map:FindFirstChild("StealableItems")
    if stealableFolder then
        for _, child in ipairs(stealableFolder:GetChildren()) do task.spawn(createItemESP, child) end
        local nat = stealableFolder:FindFirstChild("Natural")
        if nat then for _, child in ipairs(nat:GetChildren()) do task.spawn(createItemESP, child) end end
        table.insert(ItemESPConnections, stealableFolder.ChildAdded:Connect(function(c) task.wait(0.1) createItemESP(c) end))
    end
end

local function createCashierESP(obj)
    if CashierESPObjects[obj] or obj:IsA("Folder") then return end
    local color = Options.CashierESPColor and Options.CashierESPColor.Value or Color3.fromRGB(50, 255, 110)
    local data = buildESPComponents(obj, "GeHub_CashierESP", color, "收银机", Toggles.CashierESP.Value)
    data.AncestryConn = obj.AncestryChanged:Connect(function(_, parent) if not parent then removeESPFromTable(CashierESPObjects, obj) end end)
    CashierESPObjects[obj] = data
end

local function toggleCashierESPSystem(enabled)
    for _, conn in ipairs(CashierESPConnections) do conn:Disconnect() end
    table.clear(CashierESPConnections)
    if not enabled then for obj in pairs(CashierESPObjects) do removeESPFromTable(CashierESPObjects, obj) end return end
    for _, obj in ipairs(CollectionService:GetTagged("Cashiers")) do task.spawn(createCashierESP, obj) end
    table.insert(CashierESPConnections, CollectionService:GetInstanceAddedSignal("Cashiers"):Connect(function(obj) task.wait(0.1) createCashierESP(obj) end))
end

local function createVaultESP(obj)
    if VaultESPObjects[obj] or obj:IsA("Folder") then return end
    local color = Options.VaultESPColor and Options.VaultESPColor.Value or Color3.fromRGB(0, 255, 215)
    local data = buildESPComponents(obj, "GeHub_VaultESP", color, getChineseName(obj.Name), Toggles.VaultESP.Value)
    data.AncestryConn = obj.AncestryChanged:Connect(function(_, parent) if not parent then removeESPFromTable(VaultESPObjects, obj) end end)
    VaultESPObjects[obj] = data
end

local function toggleVaultESPSystem(enabled)
    for _, conn in ipairs(VaultESPConnections) do conn:Disconnect() end
    table.clear(VaultESPConnections)
    if not enabled then for obj in pairs(VaultESPObjects) do removeESPFromTable(VaultESPObjects, obj) end return end
    local vaultsFolder = workspace:FindFirstChild("Map") and workspace.Map:FindFirstChild("VaultsPositions")
    if vaultsFolder then
        for _, child in ipairs(vaultsFolder:GetChildren()) do task.spawn(createVaultESP, child) end
        table.insert(VaultESPConnections, vaultsFolder.ChildAdded:Connect(function(c) task.wait(0.1) createVaultESP(c) end))
    end
end

local function resolveElectricBoxModel(inst)
    if not inst then return nil end
    if inst.Name == "ElectricBoxDoor" and inst.Parent then return inst.Parent end
    if inst:IsA("Model") then
        local cn = string.lower(inst.Name)
        if cn == "electricboxdoor" or cn == "mainbox" then return inst.Parent end
        if inst:FindFirstChild("MainBox") then return inst end
    end
    return nil
end

local function createElectricESP(rawInst)
    local boxModel = resolveElectricBoxModel(rawInst)
    if not boxModel or ElectricESPObjects[boxModel] then return end
    local color = Options.ElectricBoxESPColor and Options.ElectricBoxESPColor.Value or Color3.fromRGB(255, 165, 0)
    local data = buildESPComponents(boxModel, "GeHub_ElectricESP", color, "配电箱", Toggles.ElectricBoxESP.Value)
    data.AncestryConn = boxModel.AncestryChanged:Connect(function(_, parent) if not parent then removeESPFromTable(ElectricESPObjects, boxModel) end end)
    ElectricESPObjects[boxModel] = data
end

local function toggleElectricESPSystem(enabled)
    for _, conn in ipairs(ElectricESPConnections) do conn:Disconnect() end
    table.clear(ElectricESPConnections)
    if not enabled then for obj in pairs(ElectricESPObjects) do removeESPFromTable(ElectricESPObjects, obj) end return end
    for _, desc in ipairs(workspace:GetDescendants()) do
        local m = resolveElectricBoxModel(desc)
        if m then task.spawn(createElectricESP, m) end
    end
    table.insert(ElectricESPConnections, workspace.DescendantAdded:Connect(function(d)
        if Toggles.ElectricBoxESP.Value then local m = resolveElectricBoxModel(d) if m then createElectricESP(m) end end
    end))
end

local function createNPCESP(obj, isSniper)
    if NPCESPObjects[obj] or obj:IsA("Folder") then return end
    local color = Options.NPCESPColor and Options.NPCESPColor.Value or Color3.fromRGB(255, 110, 110)
    local data = buildESPComponents(obj, "GeHub_NPCESP", color, isSniper and "敌人 [狙击手]" or "敌人", Toggles.NPCESP.Value)
    data.AncestryConn = obj.AncestryChanged:Connect(function(_, parent) if not parent then removeESPFromTable(NPCESPObjects, obj) end end)
    NPCESPObjects[obj] = data
end

local function toggleNPCESPSystem(enabled)
    for _, conn in ipairs(NPCESPConnections) do conn:Disconnect() end
    table.clear(NPCESPConnections)
    if not enabled then for obj in pairs(NPCESPObjects) do removeESPFromTable(NPCESPObjects, obj) end return end
    local mapFolder = workspace:FindFirstChild("Map")
    if mapFolder then
        local npcs = mapFolder:FindFirstChild("NPCS")
        local snipers = mapFolder:FindFirstChild("EliteSnipers")
        if npcs then for _, c in ipairs(npcs:GetChildren()) do task.spawn(createNPCESP, c, false) end end
        if snipers then for _, c in ipairs(snipers:GetChildren()) do task.spawn(createNPCESP, c, true) end end
    end
end

-- 实时更新循环
local function updateSimpleESPTable(tbl, customColor, showName, showDist, showHigh, highTrans, textSize, rootPart)
    for obj, data in pairs(tbl) do
        if obj and obj.Parent then
            local targetPart = getTargetPart(obj)
            local highTarget = getHighlightAdornee(obj)
            if data.Highlight then
                data.Highlight.Adornee = highTarget
                data.Highlight.Enabled = showHigh
                if showHigh then data.Highlight.FillTransparency = highTrans data.Highlight.FillColor = customColor end
            end
            if data.Billboard and data.Label then
                data.Billboard.Enabled = (showName or showDist)
                if data.Billboard.Enabled then
                    data.Label.TextSize = textSize
                    data.Label.TextColor3 = customColor
                    local lines = {}
                    if showName then table.insert(lines, data.CNName) end
                    if showDist and rootPart then
                        local pos = getObjectPosition(obj, targetPart)
                        if pos then table.insert(lines, string.format("[%dm]", math.floor((rootPart.Position - pos).Magnitude))) end
                    end
                    data.Label.Text = table.concat(lines, "\n")
                end
            end
        else
            removeESPFromTable(tbl, obj)
        end
    end
end

RunService.RenderStepped:Connect(function()
    local itemEnabled = Toggles.ItemESP and Toggles.ItemESP.Value
    local cashierEnabled = Toggles.CashierESP and Toggles.CashierESP.Value
    local vaultEnabled = Toggles.VaultESP and Toggles.VaultESP.Value
    local elecEnabled = Toggles.ElectricBoxESP and Toggles.ElectricBoxESP.Value
    local npcEnabled = Toggles.NPCESP and Toggles.NPCESP.Value
    if not itemEnabled and not cashierEnabled and not vaultEnabled and not elecEnabled and not npcEnabled then return end

    local showName = Toggles.ESPShowName.Value
    local showMutation = Toggles.ESPShowMutation and Toggles.ESPShowMutation.Value
    local showWorth = Toggles.ESPShowWorth.Value
    local showDist = Toggles.ESPShowDistance.Value
    local showHigh = Toggles.ESPShowHighlight.Value
    local highTrans = Options.ESPHighlightTrans.Value
    local textSize = math.clamp(Options.ESPTextSize.Value, 1, 50)
    local minWorth = tonumber(Options.ESPMinWorthInput and Options.ESPMinWorthInput.Value) or 0

    local char = LocalPlayer.Character
    local rootPart = char and (char:FindFirstChild("HumanoidRootPart") or char.PrimaryPart)

    if itemEnabled then
        for obj, data in pairs(ItemESPObjects) do
            if obj and obj.Parent then
                local currentWorth = getItemWorth(obj)
                local isDiamond, rarity, mutation = getItemExtraInfo(obj)
                local passFilter = isDiamond or (currentWorth <= 0) or (currentWorth >= minWorth)
                local autoColor = getItemColor(obj, currentWorth, isDiamond, rarity)

                if data.Highlight then
                    data.Highlight.Adornee = obj
                    data.Highlight.Enabled = showHigh and passFilter
                    if showHigh and passFilter then data.Highlight.FillTransparency = highTrans data.Highlight.FillColor = autoColor end
                end

                if data.Billboard and data.Label then
                    data.Billboard.Enabled = (showName or showMutation or showWorth or showDist) and passFilter
                    if data.Billboard.Enabled then
                        data.Label.TextSize = textSize
                        data.Label.TextColor3 = autoColor
                        local lines = {}
                        if showName then
                            local nameLine = data.CNName or getChineseName(obj.Name)
                            if rarity and RarityNames[rarity] then nameLine = nameLine .. " [" .. RarityNames[rarity] .. "]" end
                            table.insert(lines, nameLine)
                        end
                        if showMutation and mutation and tostring(mutation) ~= "" then table.insert(lines, "[" .. tostring(mutation) .. "]") end
                        if showWorth then
                            if isDiamond then
                                table.insert(lines, (obj.Name == "SuperGem") and "[超级宝石 +5]" or "[宝石 +1]")
                            elseif currentWorth <= 0 then
                                table.insert(lines, "[宝石/材料]")
                            else
                                table.insert(lines, string.format("[$%s]", tostring(math.floor(currentWorth))))
                            end
                        end
                        if showDist and rootPart then
                            local pos = getObjectPosition(obj, getTargetPart(obj))
                            if pos then table.insert(lines, string.format("[%dm]", math.floor((rootPart.Position - pos).Magnitude))) end
                        end
                        data.Label.Text = table.concat(lines, "\n")
                    end
                end
            else
                removeESPFromTable(ItemESPObjects, obj)
            end
        end
    end

    if cashierEnabled then updateSimpleESPTable(CashierESPObjects, Options.CashierESPColor.Value, showName, showDist, showHigh, highTrans, textSize, rootPart) end
    if vaultEnabled then updateSimpleESPTable(VaultESPObjects, Options.VaultESPColor.Value, showName, showDist, showHigh, highTrans, textSize, rootPart) end
    if elecEnabled then updateSimpleESPTable(ElectricESPObjects, Options.ElectricBoxESPColor.Value, showName, showDist, showHigh, highTrans, textSize, rootPart) end
    if npcEnabled then updateSimpleESPTable(NPCESPObjects, Options.NPCESPColor.Value, showName, showDist, showHigh, highTrans, textSize, rootPart) end
end)

-- 开关绑定
Toggles.ItemESP:OnChanged(function() toggleItemESPSystem(Toggles.ItemESP.Value) end)
Toggles.CashierESP:OnChanged(function() toggleCashierESPSystem(Toggles.CashierESP.Value) end)
Toggles.VaultESP:OnChanged(function() toggleVaultESPSystem(Toggles.VaultESP.Value) end)
Toggles.ElectricBoxESP:OnChanged(function() toggleElectricESPSystem(Toggles.ElectricBoxESP.Value) end)
Toggles.NPCESP:OnChanged(function() toggleNPCESPSystem(Toggles.NPCESP.Value) end)

Library:OnUnload(function()
    toggleItemESPSystem(false)
    toggleCashierESPSystem(false)
    toggleVaultESPSystem(false)
    toggleElectricESPSystem(false)
    toggleNPCESPSystem(false)
end)

-- UI 配置初始化
local MenuGroup = Tabs["UI Settings"]:AddLeftGroupbox('设置')
MenuGroup:AddButton('卸载菜单', function() Library:Unload() end)
MenuGroup:AddLabel('菜单快捷键'):AddKeyPicker('MenuKeybind', { Default = 'End', NoUI = true })
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

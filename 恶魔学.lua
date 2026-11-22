-- 恶魔学：独立服务器缝合版
local NothingLibrary = loadstring(game:HttpGetAsync('https://raw.githubusercontent.com/quanwei-sy/qianweicangku/refs/heads/main/%E6%BA%90%E7%A0%81.lua'))()

local __BaseWindow = NothingLibrary.new({
    Title = "TY hub｜恶魔学",
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
	Title = '恶魔学 - [AI版]',
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
    Func = Window:AddTab('功能', 'function'),
    ["UI Settings"] = Window:AddTab('UI 调试', 'settings')
}

local PickupGroup = Tabs.Func:AddLeftGroupbox('物品拾取')

PickupGroup:AddDropdown('PickupItemDropdown', {
    Values = {'等待加载...'},
    Default = 1,
    Multi = false,
    Text = '选择物品'
})

local currentItemsMap = {}
local lastItemsString = ""

task.spawn(function()
    while task.wait(1) do
        local itemsFolder = workspace:FindFirstChild("Items")
        if itemsFolder then
            local currentItems = itemsFolder:GetChildren()
            local newValues = {}
            local newMap = {}
            local newString = ""
            local validCount = 0
            
            for _, item in ipairs(currentItems) do
                validCount = validCount + 1
                
                local rawName = item:GetAttribute("ItemName") or item:GetAttribute("ltemName") or item.Name
                local translatedName = getgenv().TranslateText(rawName)
                
                local displayName = tostring(validCount) .. ". " .. translatedName
                table.insert(newValues, displayName)
                newMap[displayName] = item
                newString = newString .. displayName .. "|"
            end
            
            if newString ~= lastItemsString then
                lastItemsString = newString
                currentItemsMap = newMap
                
                if #newValues == 0 then
                    Options.PickupItemDropdown:SetValues({'无物品'})
                else
                    Options.PickupItemDropdown:SetValues(newValues)
                end
            end
        end
    end
end)

PickupGroup:AddButton('拾取所选物品', function()
    local success, err = pcall(function()
        local selected = Options.PickupItemDropdown.Value
        
        if not selected or selected == '等待加载...' or selected == '无物品' then
            Library:Notify("请先在下拉菜单中选择一个有效的物品！", 3)
            return
        end
        
        local targetItem = currentItemsMap[selected]
        
        if not targetItem or not targetItem.Parent then
            Library:Notify("该物品已不存在（可能刚刚被其他人拾取了）！", 3)
            return
        end
        
        local targetPart = targetItem:IsA("BasePart") and targetItem or targetItem:FindFirstChildWhichIsA("BasePart", true)
        local plyr = game:GetService("Players").LocalPlayer
        local localChar = plyr and plyr.Character
        
        if targetPart and localChar and localChar:FindFirstChild("HumanoidRootPart") then
            local oldCFrame = localChar:GetPivot()
            
            localChar:PivotTo(targetPart.CFrame)
            task.wait(0.2)
            
            local prompt = targetItem:FindFirstChild("ItemPrompt", true) or targetItem:FindFirstChildWhichIsA("ProximityPrompt", true) or (workspace:FindFirstChild("Items") and workspace.Items:FindFirstChild("ItemPrompt", true))
            
            if prompt and prompt:IsA("ProximityPrompt") then
                fireproximityprompt(prompt, 1)
                Library:Notify("已极速拾取：" .. selected, 3)
            else
                Library:Notify("已传送到物品，但未找到交互提示符(Prompt)，请手动点击拾取！", 4)
            end
            
            task.wait(0.2)
            
            localChar:PivotTo(oldCFrame)
        else
            Library:Notify("未能找到物品的有效坐标或您的角色未完全加载！", 3)
        end
    end)
    
    if not success then
        warn("[TY hub] 拾取功能异常: " .. tostring(err))
        Library:Notify("拾取代码出错！请按 F9 打开控制台查看报错", 5)
    end
end)

PickupGroup:AddButton('传送至卡车', function()
    local success, err = pcall(function()
        local plyr = game:GetService("Players").LocalPlayer
        local localChar = plyr and plyr.Character
        
        if not localChar then return end
        
        local truck = workspace:FindFirstChild("Map") and workspace.Map:FindFirstChild("Rooms") and workspace.Map.Rooms:FindFirstChild("Base Camp") and workspace.Map.Rooms["Base Camp"]:FindFirstChild("Truck")
        
        if truck then
            local targetPart = truck:IsA("BasePart") and truck or truck:FindFirstChildWhichIsA("BasePart", true)
            
            if targetPart then
                localChar:PivotTo(targetPart.CFrame * CFrame.new(0, 5, 0))
                Library:Notify("已成功传送到卡车！", 3)
            else
                Library:Notify("找到卡车，但缺乏物理部件导致无法传送！", 3)
            end
        else
            Library:Notify("未找到卡车路径 (Base Camp -> Truck)！", 3)
        end
    end)
    
    if not success then
        warn("[TY hub] 传送卡车异常: " .. tostring(err))
        Library:Notify("传送功能出错！请按 F9 打开控制台查看", 5)
    end
end)

local PlayerGroup = Tabs.Func:AddRightGroupbox('玩家功能')

PlayerGroup:AddToggle('EnableWalkSpeed', {
    Text = '启用移速',
    Default = false,
})

PlayerGroup:AddSlider('WalkSpeedValue', {
    Text = '移速设置',
    Default = 16,
    Min = 10,
    Max = 50,
    Rounding = 1,
    Compact = false,
})

PlayerGroup:AddToggle('EnableNoclip', {
    Text = '穿墙',
    Default = false,
})

PlayerGroup:AddToggle('EnableSelfLight', {
    Text = '自身发光',
    Default = false,
})

PlayerGroup:AddSlider('SelfLightBrightness', {
    Text = '发光亮度',
    Default = 3,
    Min = 0,
    Max = 20,
    Rounding = 1,
    Compact = false,
})

PlayerGroup:AddSlider('SelfLightRange', {
    Text = '发光范围',
    Default = 20,
    Min = 0,
    Max = 50,
    Rounding = 1,
    Compact = false,
})

local MapRightGroup = Tabs.Map:AddRightGroupbox('鬼魂信息')

local GhostAgeLabel = MapRightGroup:AddLabel('年龄: 未知')
local GhostCurrentRoomLabel = MapRightGroup:AddLabel('当前房间: 未知')
local GhostFavoriteRoomLabel = MapRightGroup:AddLabel('最喜欢房间: 未知')
local GhostVisualModelLabel = MapRightGroup:AddLabel('视觉模型: 未知')

MapRightGroup:AddButton('传送至鬼魂', function()
    local success, err = pcall(function()
        local plyr = game:GetService("Players").LocalPlayer
        
        local ghost = workspace:FindFirstChild("Ghost")
        if not ghost then
            Library:Notify("未找到 workspace.Ghost 模型！", 3)
            return
        end
        
        local targetPart = ghost:FindFirstChild("HumanoidRootPart") or ghost:FindFirstChild("Torso") or ghost:FindFirstChildWhichIsA("BasePart")
        
        local localChar = plyr and plyr.Character
        
        if targetPart and localChar then
            localChar:PivotTo(targetPart.CFrame * CFrame.new(0, 3, 0))
            Library:Notify("已成功传送到鬼魂身边！", 3)
        else
            Library:Notify("传送失败：未能找到鬼魂的物理部件或玩家角色！", 4)
        end
    end)
    
    if not success then
        warn("[TY hub] 传送功能出现异常: " .. tostring(err))
        Library:Notify("传送代码出错！请按 F9 打开控制台查看报错信息", 5)
    end
end)

local MapRightGroupEvidence = Tabs.Map:AddRightGroupbox('证据信息')

local ThermoCountLabel = MapRightGroupEvidence:AddLabel('温度计数量: 0')
local ThermoReadingLabel = MapRightGroupEvidence:AddLabel('温度: 暂无数据')
local HandprintCountLabel = MapRightGroupEvidence:AddLabel('手印数量: 0')
local EMFCountLabel = MapRightGroupEvidence:AddLabel('EMF数量: 0')
local EMFLevelLabel = MapRightGroupEvidence:AddLabel('EMF等级: 监听中...')
local SpiritBookUnwrittenLabel = MapRightGroupEvidence:AddLabel('灵书未写数量: 0')
local SpiritBookWrittenLabel = MapRightGroupEvidence:AddLabel('灵书已写数量: 0')
local GhostOrbLabel = MapRightGroupEvidence:AddLabel('幽灵球证据: 无')
local FlowerPotUnwitheredLabel = MapRightGroupEvidence:AddLabel('花盆未枯萎数量: 0')
local FlowerPotWitheredLabel = MapRightGroupEvidence:AddLabel('花盆已枯萎数量: 0')
local ProjectorCountLabel = MapRightGroupEvidence:AddLabel('投影仪数量: 0')
local ProjectorStateLabel = MapRightGroupEvidence:AddLabel('投影仪证据: 监听中...')


local MapLeftGroup = Tabs.Map:AddLeftGroupbox('透视功能')

MapLeftGroup:AddToggle('ItemESP', {
    Text = '物品透视',
    Default = false,
}):AddColorPicker('ItemESPColor', {
    Default = Color3.fromRGB(173, 216, 230),
    Title = '物品透视颜色',
    Transparency = 0
})

MapLeftGroup:AddToggle('GhostESP', {
    Text = '鬼魂透视',
    Default = false,
}):AddColorPicker('GhostESPColor', {
    Default = Color3.fromRGB(255, 128, 128),
    Title = '鬼魂透视颜色',
    Transparency = 0
})

MapLeftGroup:AddToggle('PlayerESP', {
    Text = '玩家透视',
    Default = false,
}):AddColorPicker('PlayerESPColor', {
    Default = Color3.fromRGB(124, 252, 0),
    Title = '玩家透视颜色',
    Transparency = 0
})

MapLeftGroup:AddToggle('CursedESP', {
    Text = '诅咒物透视',
    Default = false,
}):AddColorPicker('CursedESPColor', {
    Default = Color3.fromRGB(255, 255, 153),
    Title = '诅咒物透视颜色',
    Transparency = 0
})

local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local ESPObjects = {}
local GhostESPObjects = {}
local PlayerESPObjects = {}
local CursedESPObjects = {}

local function GetPrimaryPart(obj)
    if obj:IsA("Model") then
        return obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")
    elseif obj:IsA("BasePart") then
        return obj
    end
    return nil
end

local function CalculateDistance(targetPosition)
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        return math.floor((LocalPlayer.Character.HumanoidRootPart.Position - targetPosition).Magnitude)
    end
    return 0
end

local function IsItemIgnored(item)
    if not LocalPlayer.Character then return false end
    if item:IsDescendantOf(LocalPlayer.Character) then return true end
    if LocalPlayer.Backpack and item:IsDescendantOf(LocalPlayer.Backpack) then return true end
    return false
end

local function GetAllThermometers()
    local thermometers = {}

    local itemsFolder = workspace:FindFirstChild("Items")
    if itemsFolder then
        for _, item in ipairs(itemsFolder:GetChildren()) do
            local itemName = item:GetAttribute("ItemName") or item:GetAttribute("ltemName") or item.Name
            if itemName == "Thermometer" then
                table.insert(thermometers, item)
            end
        end
    end

    for _, player in ipairs(Players:GetPlayers()) do
        local backpack = player:FindFirstChild("Backpack")
        if backpack then
            for _, item in ipairs(backpack:GetChildren()) do
                local itemName = item:GetAttribute("ItemName") or item:GetAttribute("ltemName") or item.Name
                if itemName == "Thermometer" then
                    table.insert(thermometers, item)
                end
            end
        end

        local char = player.Character
        if char then
            for _, item in ipairs(char:GetChildren()) do
                local itemName = item:GetAttribute("ItemName") or item:GetAttribute("ltemName") or item.Name
                if itemName == "Thermometer" then
                    table.insert(thermometers, item)
                end
            end
        end
    end
    
    return thermometers
end

local function GetThermometerText(thermometer)
    local screen = thermometer:FindFirstChild("Screen")
    if screen then
        local sg = screen:FindFirstChildOfClass("SurfaceGui") or screen:FindFirstChild("SurfaceGui")
        if sg then
            local frame = sg:FindFirstChildOfClass("Frame") or sg:FindFirstChild("Frame")
            if frame then
                local textLabel = frame:FindFirstChildOfClass("TextLabel") or frame:FindFirstChild("TextLabel")
                if textLabel and textLabel:IsA("TextLabel") then
                    return textLabel.Text
                end
            end
        end
    end

    local fallbackLabel = thermometer:FindFirstChild("TextLabel", true)
    if fallbackLabel and fallbackLabel:IsA("TextLabel") then
        return fallbackLabel.Text
    end
    
    return nil
end

local function GetAllEMFReaders()
    local emfs = {}

    local itemsFolder = workspace:FindFirstChild("Items")
    if itemsFolder then
        for _, item in ipairs(itemsFolder:GetChildren()) do
            local itemName = item:GetAttribute("ItemName") or item:GetAttribute("ltemName") or item.Name
            local lowerName = string.lower(itemName)
            if string.find(lowerName, "emf") or string.find(lowerName, "efm") then
                table.insert(emfs, item)
            end
        end
    end

    for _, player in ipairs(Players:GetPlayers()) do
        local backpack = player:FindFirstChild("Backpack")
        if backpack then
            for _, item in ipairs(backpack:GetChildren()) do
                local itemName = item:GetAttribute("ItemName") or item:GetAttribute("ltemName") or item.Name
                local lowerName = string.lower(itemName)
                if string.find(lowerName, "emf") or string.find(lowerName, "efm") then
                    table.insert(emfs, item)
                end
            end
        end
        
        local char = player.Character
        if char then
            for _, item in ipairs(char:GetChildren()) do
                local itemName = item:GetAttribute("ItemName") or item:GetAttribute("ltemName") or item.Name
                local lowerName = string.lower(itemName)
                if string.find(lowerName, "emf") or string.find(lowerName, "efm") then
                    table.insert(emfs, item)
                end
            end
        end
    end
    
    return emfs
end

local function GetEMFLevel(emfItem)
    local handle = emfItem:FindFirstChild("Handle")
    if handle then
        local tone = handle:FindFirstChild("Tone")
        if tone and tone:IsA("Sound") then
            local speed = tone.PlaybackSpeed
            if speed >= 1.6 then return 5
            elseif speed >= 1.4 then return 4
            elseif speed >= 1.2 then return 3
            elseif speed >= 1.0 then return 2
            else return 1 end
        end
    end

    local fallbackTone = emfItem:FindFirstChild("Tone", true)
    if fallbackTone and fallbackTone:IsA("Sound") then
        local speed = fallbackTone.PlaybackSpeed
        if speed >= 1.6 then return 5
        elseif speed >= 1.4 then return 4
        elseif speed >= 1.2 then return 3
        elseif speed >= 1.0 then return 2
        else return 1 end
    end
    
    return 1
end

local function GetSpiritBookStatus()
    local unwrittenCount = 0
    local writtenCount = 0
    
    local itemsFolder = workspace:FindFirstChild("Items")
    if itemsFolder then
        for _, item in ipairs(itemsFolder:GetChildren()) do
            local itemName = item:GetAttribute("ItemName") or item:GetAttribute("ltemName") or item.Name
            local lowerName = string.lower(itemName)

            if string.find(lowerName, "spirit book") or string.find(lowerName, "book") or itemName == "Spirit Book" then
                local isWritten = false

                local function checkPageDecal(pageName)
                    local page = item:FindFirstChild(pageName)
                    if page then
                        local decal = page:FindFirstChildOfClass("Decal") or page:FindFirstChild("Decal")
                        if decal and decal:IsA("Decal") then

                            if decal.Texture and decal.Texture ~= "" then
                                return true
                            end
                        end
                    end
                    return false
                end

                if checkPageDecal("LeftPage") or checkPageDecal("RightPage") then
                    isWritten = true
                end
                
                if isWritten then
                    writtenCount = writtenCount + 1
                else
                    unwrittenCount = unwrittenCount + 1
                end
            end
        end
    end
    
    return unwrittenCount, writtenCount
end

local function GetFlowerPotStatus()
    local unwitheredCount = 0
    local witheredCount = 0
    
    local itemsFolder = workspace:FindFirstChild("Items")
    if itemsFolder then
        for _, item in ipairs(itemsFolder:GetChildren()) do
            local itemName = item:GetAttribute("ItemName") or item:GetAttribute("ltemName") or item.Name
            local lowerName = string.lower(itemName)
            
            if string.find(lowerName, "flower pot") or string.find(lowerName, "pot") or itemName == "Flower Pot" then
                local isWithered = false
                
                for _, desc in ipairs(item:GetDescendants()) do
                    if desc.Name == "OptimizedFlower" then
                        local petals = desc:FindFirstChild("Flower_Petals")
                        if petals and petals:IsA("BasePart") then
                            local color = petals.Color
                            local brickColorName = string.lower(tostring(petals.BrickColor.Name))
                            
                            if (color.R < 0.15 and color.G < 0.15 and color.B < 0.15) or string.find(brickColorName, "black") then
                                isWithered = true
                                break
                            end
                        end
                    end
                end
                
                if isWithered then
                    witheredCount = witheredCount + 1
                else
                    unwitheredCount = unwitheredCount + 1
                end
            end
        end
    end
    
    return unwitheredCount, witheredCount
end

local function GetAllProjectors()
    local projectors = {}

    local itemsFolder = workspace:FindFirstChild("Items")
    if itemsFolder then
        for _, item in ipairs(itemsFolder:GetChildren()) do
            local itemName = item:GetAttribute("ItemName") or item:GetAttribute("ltemName") or item.Name
            local lowerName = string.lower(itemName)
            if string.find(lowerName, "projector") or string.find(lowerName, "laser") then
                table.insert(projectors, item)
            end
        end
    end

    for _, player in ipairs(game:GetService("Players"):GetPlayers()) do
        local backpack = player:FindFirstChild("Backpack")
        if backpack then
            for _, item in ipairs(backpack:GetChildren()) do
                local itemName = item:GetAttribute("ItemName") or item:GetAttribute("ltemName") or item.Name
                local lowerName = string.lower(itemName)
                if string.find(lowerName, "projector") or string.find(lowerName, "laser") then
                    table.insert(projectors, item)
                end
            end
        end
        
        local char = player.Character
        if char then
            for _, item in ipairs(char:GetChildren()) do
                local itemName = item:GetAttribute("ItemName") or item:GetAttribute("ltemName") or item.Name
                local lowerName = string.lower(itemName)
                if string.find(lowerName, "projector") or string.find(lowerName, "laser") then
                    table.insert(projectors, item)
                end
            end
        end
    end
    
    return projectors
end

local function HasProjectorHandprint(projectorItem)
    local handle = projectorItem:FindFirstChild("Handle")
    if handle then
        for _, child in ipairs(handle:GetChildren()) do
            if string.find(child.Name, "Handprint") then
                return true
            end
        end
    end

    for _, desc in ipairs(projectorItem:GetDescendants()) do
        if string.find(desc.Name, "Handprint") then
            return true
        end
    end
    
    return false
end

local function CreateItemESP(item)
    if ESPObjects[item] then return end
    
    local highlight = Instance.new("Highlight")
    highlight.Name = "GE_ItemHighlight"
    highlight.FillTransparency = 0.5
    highlight.OutlineTransparency = 0
    
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "GE_ItemBillboard"
    billboard.AlwaysOnTop = true
    billboard.Size = UDim2.new(0, 100, 0, 40)
    billboard.StudsOffset = Vector3.new(0, 0.5, 0)
    
    local textLabel = Instance.new("TextLabel")
    textLabel.Parent = billboard
    textLabel.BackgroundTransparency = 1
    textLabel.Size = UDim2.new(1, 0, 1, 0)
    textLabel.Font = Enum.Font.GothamBlack 
    textLabel.TextSize = 5
    textLabel.TextStrokeTransparency = 1
    
    ESPObjects[item] = { Highlight = highlight, Billboard = billboard, TextLabel = textLabel }
end

local function RemoveItemESP(item)
    if ESPObjects[item] then
        ESPObjects[item].Highlight:Destroy()
        ESPObjects[item].Billboard:Destroy()
        ESPObjects[item] = nil
    end
end

local function CreateGhostESP(ghost)
    if GhostESPObjects[ghost] then return end
    
    local highlight = Instance.new("Highlight")
    highlight.Name = "GE_GhostHighlight"
    highlight.FillTransparency = 0.6
    highlight.OutlineTransparency = 0
    
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "GE_GhostBillboard"
    billboard.AlwaysOnTop = true
    billboard.Size = UDim2.new(0, 100, 0, 40)
    billboard.StudsOffset = Vector3.new(0, 0.5, 0)
    
    local textLabel = Instance.new("TextLabel")
    textLabel.Parent = billboard
    textLabel.BackgroundTransparency = 1
    textLabel.Size = UDim2.new(1, 0, 1, 0)
    textLabel.Font = Enum.Font.GothamBlack 
    textLabel.TextSize = 5
    textLabel.TextStrokeTransparency = 1
    
    local partsData = {}
    local ignoreKeywords = {"box", "hit", "colli", "detect", "zone", "range", "root", "sensor", "dummy", "bound"}
    
    for _, desc in ipairs(ghost:GetDescendants()) do
        if desc:IsA("BasePart") then
            local nameLower = string.lower(desc.Name)
            local isIgnored = false
            
            for _, keyword in ipairs(ignoreKeywords) do
                if string.find(nameLower, keyword) then
                    isIgnored = true
                    break
                end
            end
            
            if not isIgnored then
                table.insert(partsData, { Part = desc, OriginalTransparency = desc.Transparency })
            end
        end
    end
    
    GhostESPObjects[ghost] = { 
        Highlight = highlight, 
        Billboard = billboard, 
        TextLabel = textLabel,
        PartsData = partsData
    }
end

local function RemoveGhostESP(ghost)
    if GhostESPObjects[ghost] then
        local espData = GhostESPObjects[ghost]
        
        if espData.PartsData then
            for _, data in ipairs(espData.PartsData) do
                if data.Part and data.Part.Parent then
                    data.Part.Transparency = data.OriginalTransparency
                end
            end
        end
        
        espData.Highlight:Destroy()
        espData.Billboard:Destroy()
        GhostESPObjects[ghost] = nil
    end
end

local function CreatePlayerESP(player)
    local character = player.Character
    if not character then return end
    if PlayerESPObjects[player] then return end
    
    local highlight = Instance.new("Highlight")
    highlight.Name = "GE_PlayerHighlight"
    highlight.FillTransparency = 0.5
    highlight.OutlineTransparency = 0
    
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "GE_PlayerBillboard"
    billboard.AlwaysOnTop = true
    billboard.Size = UDim2.new(0, 100, 0, 40)
    billboard.StudsOffset = Vector3.new(0, 2.5, 0)
    
    local textLabel = Instance.new("TextLabel")
    textLabel.Parent = billboard
    textLabel.BackgroundTransparency = 1
    textLabel.Size = UDim2.new(1, 0, 1, 0)
    textLabel.Font = Enum.Font.GothamBlack 
    textLabel.TextSize = 5
    textLabel.TextStrokeTransparency = 1
    
    PlayerESPObjects[player] = { Highlight = highlight, Billboard = billboard, TextLabel = textLabel }
end

local function RemovePlayerESP(player)
    if PlayerESPObjects[player] then
        PlayerESPObjects[player].Highlight:Destroy()
        PlayerESPObjects[player].Billboard:Destroy()
        PlayerESPObjects[player] = nil
    end
end

local function CreateCursedESP(item)
    if CursedESPObjects[item] then return end
    
    local highlight = Instance.new("Highlight")
    highlight.Name = "GE_CursedHighlight"
    highlight.FillTransparency = 0.5
    highlight.OutlineTransparency = 0
    
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "GE_CursedBillboard"
    billboard.AlwaysOnTop = true
    billboard.Size = UDim2.new(0, 100, 0, 40)
    billboard.StudsOffset = Vector3.new(0, 0.5, 0)
    
    local textLabel = Instance.new("TextLabel")
    textLabel.Parent = billboard
    textLabel.BackgroundTransparency = 1
    textLabel.Size = UDim2.new(1, 0, 1, 0)
    textLabel.Font = Enum.Font.GothamBlack 
    textLabel.TextSize = 5
    textLabel.TextStrokeTransparency = 1
    
    CursedESPObjects[item] = { Highlight = highlight, Billboard = billboard, TextLabel = textLabel }
end

local function RemoveCursedESP(item)
    if CursedESPObjects[item] then
        CursedESPObjects[item].Highlight:Destroy()
        CursedESPObjects[item].Billboard:Destroy()
        CursedESPObjects[item] = nil
    end
end

-- 自身发光组件
local SelfLight = Instance.new("PointLight")
SelfLight.Name = "CustomSelfLight"
SelfLight.Enabled = false
SelfLight.Brightness = Options.SelfLightBrightness.Value
SelfLight.Range = Options.SelfLightRange.Value
SelfLight.Parent = nil

-- 建立一个表用于存储原始碰撞状态
local originalCollisions = {}

-- 移速开关恢复
Toggles.EnableWalkSpeed:OnChanged(function()
    if not Toggles.EnableWalkSpeed.Value then
        local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.WalkSpeed = 10
        end
    end
end)

-- 穿墙开关恢复（记录原始碰撞状态）
Toggles.EnableNoclip:OnChanged(function()
    local char = LocalPlayer.Character
    if not char then return end
    
    if Toggles.EnableNoclip.Value then
        -- 开启穿墙时，记录当前所有部件的真实碰撞状态
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                originalCollisions[part] = part.CanCollide
            end
        end
    else
        -- 关闭穿墙时，只恢复原本就是 true 的部件
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") and originalCollisions[part] ~= nil then
                part.CanCollide = originalCollisions[part]
            end
        end
        -- 清理记录表
        table.clear(originalCollisions)
    end
end)

-- 自身发光开关
Toggles.EnableSelfLight:OnChanged(function()
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if Toggles.EnableSelfLight.Value and root then
        SelfLight.Parent = root
        SelfLight.Enabled = true
    else
        SelfLight.Parent = nil
        SelfLight.Enabled = false
    end
end)

-- 发光亮度滑块
Options.SelfLightBrightness:OnChanged(function()
    SelfLight.Brightness = Options.SelfLightBrightness.Value
end)

-- 发光范围滑块
Options.SelfLightRange:OnChanged(function()
    SelfLight.Range = Options.SelfLightRange.Value
end)

-- 移速循环
local PlayerRenderConnection = RunService.RenderStepped:Connect(function()
    if Toggles.EnableWalkSpeed.Value then
        local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.WalkSpeed = Options.WalkSpeedValue.Value
        end
    end
end)

-- 穿墙循环
local NoclipConnection = RunService.Stepped:Connect(function()
    if Toggles.EnableNoclip.Value then
        local char = LocalPlayer.Character
        if char then
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") and part.CanCollide then
                    part.CanCollide = false
                end
            end
        end
    end
end)

local ESPRenderConnection = RunService.RenderStepped:Connect(function()
    pcall(function()
        local isItemESPEnabled = Toggles.ItemESP.Value
        local itemEspColor = Options.ItemESPColor.Value
        
        local isGhostESPEnabled = Toggles.GhostESP.Value
        local ghostEspColor = Options.GhostESPColor.Value
        
        local isPlayerESPEnabled = Toggles.PlayerESP.Value
        local playerEspColor = Options.PlayerESPColor.Value
        
        local isCursedESPEnabled = Toggles.CursedESP.Value
        local cursedEspColor = Options.CursedESPColor.Value

        local itemsFolder = workspace:FindFirstChild("Items")
        if itemsFolder then
            for _, item in ipairs(itemsFolder:GetChildren()) do
                if isItemESPEnabled and not IsItemIgnored(item) then
                    CreateItemESP(item)
                    local esp = ESPObjects[item]
                    local primaryPart = GetPrimaryPart(item)
                    
                    if primaryPart then
                        esp.Highlight.Parent = item
                        esp.Highlight.FillColor = itemEspColor
                        esp.Highlight.OutlineColor = itemEspColor
                        
                        esp.Billboard.Parent = primaryPart
                        esp.TextLabel.TextColor3 = itemEspColor 
                        
                        local rawName = item:GetAttribute("ItemName") or item:GetAttribute("ltemName") or item.Name
                        local translatedName = getgenv().TranslateText(rawName)
                        
                        local distance = CalculateDistance(primaryPart.Position)
                        esp.TextLabel.Text = string.format("%s\n%dm", translatedName, distance)
                    end
                else
                    RemoveItemESP(item)
                end
            end
        end

        for item, _ in pairs(ESPObjects) do
            if not item or not item.Parent or not isItemESPEnabled or IsItemIgnored(item) then
                RemoveItemESP(item)
            end
        end

        local ghostWorkspace = workspace:FindFirstChild("Ghost")
        
        if ghostWorkspace then
            local activeGhosts = {}
            if ghostWorkspace:IsA("Model") then
                table.insert(activeGhosts, ghostWorkspace)
            else
                for _, child in ipairs(ghostWorkspace:GetChildren()) do
                    if child:IsA("Model") then
                        table.insert(activeGhosts, child)
                    end
                end
            end

            for _, ghost in ipairs(activeGhosts) do
                if isGhostESPEnabled then
                    CreateGhostESP(ghost)
                    local esp = GhostESPObjects[ghost]
                    local primaryPart = GetPrimaryPart(ghost)
                    
                    if primaryPart then
                        esp.Highlight.Parent = ghost
                        esp.Highlight.FillColor = ghostEspColor
                        esp.Highlight.OutlineColor = ghostEspColor
                        
                        esp.Billboard.Parent = primaryPart
                        esp.TextLabel.TextColor3 = ghostEspColor
                        
                        local rawName = ghost:GetAttribute("GhostName") or ghost.Name
                        local translatedName = getgenv().TranslateText(rawName)
                        
                        local distance = CalculateDistance(primaryPart.Position)
                        esp.TextLabel.Text = string.format("%s\n%dm", translatedName, distance)

                        if esp.PartsData then
                            for _, data in ipairs(esp.PartsData) do
                                if data.Part and data.Part.Parent then
                                    data.Part.Transparency = 0
                                end
                            end
                        end
                    end
                else
                    RemoveGhostESP(ghost)
                end
            end
        end

        for ghost, _ in pairs(GhostESPObjects) do
            if not ghost or not ghost.Parent or not isGhostESPEnabled then
                RemoveGhostESP(ghost)
            end
        end

        local cursedHolder = workspace:FindFirstChild("CursedPossessionHolder")
        
        if cursedHolder then
            for _, item in ipairs(cursedHolder:GetChildren()) do
                if isCursedESPEnabled then
                    CreateCursedESP(item)
                    local esp = CursedESPObjects[item]
                    local primaryPart = GetPrimaryPart(item)
                    
                    if primaryPart then
                        esp.Highlight.Parent = item
                        esp.Highlight.FillColor = cursedEspColor
                        esp.Highlight.OutlineColor = cursedEspColor
                        
                        esp.Billboard.Parent = primaryPart
                        esp.TextLabel.TextColor3 = cursedEspColor
                        
                        local rawName = item:GetAttribute("ItemName") or item:GetAttribute("ltemName") or item.Name
                        local translatedName = getgenv().TranslateText(rawName)
                        
                        local distance = CalculateDistance(primaryPart.Position)
                        esp.TextLabel.Text = string.format("%s\n%dm", translatedName, distance)
                    end
                else
                    RemoveCursedESP(item)
                end
            end
        end
        
        for item, _ in pairs(CursedESPObjects) do
            if not item or not item.Parent or not isCursedESPEnabled or not item:IsDescendantOf(cursedHolder) then
                RemoveCursedESP(item)
            end
        end

        local ghostWorkspaceForInfo = workspace:FindFirstChild("Ghost")
        local ghostModelForInfo = nil
        
        if ghostWorkspaceForInfo then
            if ghostWorkspaceForInfo:IsA("Model") then
                ghostModelForInfo = ghostWorkspaceForInfo
            else
                ghostModelForInfo = ghostWorkspaceForInfo:FindFirstChildWhichIsA("Model")
            end
        end
        
        if ghostModelForInfo then
            local age = ghostModelForInfo:GetAttribute("age") or ghostModelForInfo:GetAttribute("Age") or "未知"
            local currentRoomRaw = ghostModelForInfo:GetAttribute("currentroom") or ghostModelForInfo:GetAttribute("CurrentRoom") or "未知"
            local favoriteRoomRaw = ghostModelForInfo:GetAttribute("favoriteroom") or ghostModelForInfo:GetAttribute("FavoriteRoom") or "未知"
            local visualModelRaw = ghostModelForInfo:GetAttribute("visualmodel") or ghostModelForInfo:GetAttribute("VisualModel") or "未知"
            
            local currentRoomTrans = getgenv().TranslateText(currentRoomRaw)
            local favoriteRoomTrans = getgenv().TranslateText(favoriteRoomRaw)
            local visualModelTrans = getgenv().TranslateText(visualModelRaw)
            
            GhostAgeLabel:SetText("年龄: " .. tostring(age))
            GhostCurrentRoomLabel:SetText("当前房间: " .. tostring(currentRoomTrans))
            GhostFavoriteRoomLabel:SetText("最喜欢房间: " .. tostring(favoriteRoomTrans))
            GhostVisualModelLabel:SetText("视觉模型: " .. tostring(visualModelTrans))
        else
            GhostAgeLabel:SetText("年龄: 未知")
            GhostCurrentRoomLabel:SetText("当前房间: 未知")
            GhostFavoriteRoomLabel:SetText("最喜欢房间: 未知")
            GhostVisualModelLabel:SetText("视觉模型: 未知")
        end

        local thermometers = GetAllThermometers()
        local count = #thermometers
        ThermoCountLabel:SetText("温度计数量: " .. tostring(count))
        
        local readings = {}
        local foundEvidence = false

        for i, thermo in ipairs(thermometers) do
            local text = GetThermometerText(thermo)
            if text and text ~= "" then

                table.insert(readings, string.format("#%d:%s", i, text))
                

                local numStr = string.match(text, "([%-]?%d+%.?%d*)")
                if numStr then
                    local temp = tonumber(numStr)
                    if temp and (temp < 0 or temp > 32) then
                        foundEvidence = true
                    end
                end
            end
        end

        local activeReading = "无"
        if #readings > 0 then
            activeReading = table.concat(readings, " | ")
        end
        ThermoReadingLabel:SetText("温度: " .. activeReading)
        
        if foundEvidence then
            if not getgenv().HasNotifiedThermometerEvidence then
                getgenv().HasNotifiedThermometerEvidence = true
                Library:Notify("【证据提示】温度证据出现！", 5)
            end
        else
            getgenv().HasNotifiedThermometerEvidence = false
        end

        local handprintsFolder = workspace:FindFirstChild("Handprints")
        local handprintCount = 0
        
        if handprintsFolder then
            handprintCount = #handprintsFolder:GetChildren()
        end
        
        HandprintCountLabel:SetText("手印数量: " .. tostring(handprintCount))
        
        if handprintCount > 0 then
            if not getgenv().HasNotifiedHandprintEvidence then
                getgenv().HasNotifiedHandprintEvidence = true
                Library:Notify("【证据提示】手印证据出现！", 5)
            end
        else
            getgenv().HasNotifiedHandprintEvidence = false
        end

        getgenv().EMFLockedTo5 = getgenv().EMFLockedTo5 or false
        
        local emfs = GetAllEMFReaders()
        local emfCount = #emfs
        EMFCountLabel:SetText("EMF数量: " .. tostring(emfCount))
        
        if getgenv().EMFLockedTo5 then
            EMFLevelLabel:SetText("EMF等级: 达到证据要求")
        else
            if emfCount > 0 then
                local maxLevel = 0
                
                for _, emf in ipairs(emfs) do
                    local lvl = GetEMFLevel(emf)
                    if lvl > maxLevel then
                        maxLevel = lvl
                    end
                end
                
                EMFLevelLabel:SetText("EMF等级: " .. tostring(maxLevel) .. "级")
                
                if maxLevel >= 5 then
                    getgenv().EMFLockedTo5 = true
                    Library:Notify("【证据提示】EMF5级 满级证据！", 5)
                end
            else
                EMFLevelLabel:SetText("EMF等级: 未检测到 EMF")
            end
        end

        local unwritten, written = GetSpiritBookStatus()
        SpiritBookUnwrittenLabel:SetText("灵书未写数量: " .. tostring(unwritten))
        SpiritBookWrittenLabel:SetText("灵书已写数量: " .. tostring(written))
        
        if written > 0 then
            if not getgenv().HasNotifiedSpiritBookEvidence then
                getgenv().HasNotifiedSpiritBookEvidence = true
                Library:Notify("【证据提示】灵书已写证据！", 5)
            end
        else
            getgenv().HasNotifiedSpiritBookEvidence = false
        end

        local ghostOrb = workspace:FindFirstChild("GhostOrb")
        
        if ghostOrb then
            GhostOrbLabel:SetText("幽灵球证据: 有")
            
            if not getgenv().HasNotifiedGhostOrbEvidence then
                getgenv().HasNotifiedGhostOrbEvidence = true
                Library:Notify("【证据提示】幽灵球证据出现！", 5)
            end
        else
            GhostOrbLabel:SetText("幽灵球证据: 无")
            getgenv().HasNotifiedGhostOrbEvidence = false
        end

        local unwitheredPot, witheredPot = GetFlowerPotStatus()
        FlowerPotUnwitheredLabel:SetText("花盆未枯萎数量: " .. tostring(unwitheredPot))
        FlowerPotWitheredLabel:SetText("花盆已枯萎数量: " .. tostring(witheredPot))
        
        if witheredPot > 0 then
            if not getgenv().HasNotifiedFlowerPotEvidence then
                getgenv().HasNotifiedFlowerPotEvidence = true
                Library:Notify("【证据提示】花盆枯萎证据！", 5)
            end
        else
            getgenv().HasNotifiedFlowerPotEvidence = false
        end
        
        getgenv().ProjectorLocked = getgenv().ProjectorLocked or false
        
        local projectors = GetAllProjectors()
        local projectorCount = #projectors
        ProjectorCountLabel:SetText("投影仪数量: " .. tostring(projectorCount))
        
        if getgenv().ProjectorLocked then
            ProjectorStateLabel:SetText("投影仪证据: 达到证据要求")
        else
            if projectorCount > 0 then
                local isAppeared = false
                
                for _, proj in ipairs(projectors) do
                    if HasProjectorHandprint(proj) then
                        isAppeared = true
                        break
                    end
                end
                
                if isAppeared then
                    getgenv().ProjectorLocked = true
                    ProjectorStateLabel:SetText("投影仪证据: 达到证据要求")
                    Library:Notify("【证据提示】投影仪证据出现！", 5)
                else
                    ProjectorStateLabel:SetText("投影仪证据: 未现形")
                end
            else
                ProjectorStateLabel:SetText("投影仪证据: 未检测到投影仪")
            end
        end

        if isPlayerESPEnabled then
            for _, player in ipairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and player.Character then
                    local character = player.Character
                    CreatePlayerESP(player)
                    local esp = PlayerESPObjects[player]
                    local primaryPart = GetPrimaryPart(character)
                    
                    if primaryPart then
                        esp.Highlight.Parent = character
                        esp.Highlight.FillColor = playerEspColor
                        esp.Highlight.OutlineColor = playerEspColor
                        
                        esp.Billboard.Parent = primaryPart
                        esp.TextLabel.TextColor3 = playerEspColor
                        
                        local distance = CalculateDistance(primaryPart.Position)
                        esp.TextLabel.Text = string.format("%s\n%dm", player.Name, distance)
                    end
                end
            end
        end

        for player, _ in pairs(PlayerESPObjects) do
            if not player or not player.Parent or not isPlayerESPEnabled or not player.Character then
                RemovePlayerESP(player)
            end
        end
    end)
end)

local MenuGroup = Tabs["UI Settings"]:AddLeftGroupbox('菜单')

MenuGroup:AddButton('卸载菜单', function() Library:Unload() end)
MenuGroup:AddLabel('菜单快捷键'):AddKeyPicker('MenuKeybind', { Default = 'End', NoUI = true, Text = 'Menu keybind' })

Library.ToggleKeybind = Options.MenuKeybind

Library:OnUnload(function()
    if PlayerRenderConnection then
        PlayerRenderConnection:Disconnect()
    end
    if NoclipConnection then
        NoclipConnection:Disconnect()
    end
    if ESPRenderConnection then
        ESPRenderConnection:Disconnect()
    end

    -- 彻底清理发光组件
    if SelfLight then
        SelfLight:Destroy()
    end

    local char = LocalPlayer.Character
    if char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.WalkSpeed = 10
        end
        
        -- 卸载时安全恢复碰撞
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") and originalCollisions[part] ~= nil then
                part.CanCollide = originalCollisions[part]
            end
        end
        table.clear(originalCollisions)
    end

    -- 清理ESP
    for item, _ in pairs(ESPObjects) do
        RemoveItemESP(item)
    end
    table.clear(ESPObjects)
    
    for ghost, _ in pairs(GhostESPObjects) do
        RemoveGhostESP(ghost)
    end
    table.clear(GhostESPObjects)
    
    for player, _ in pairs(PlayerESPObjects) do
        RemovePlayerESP(player)
    end
    table.clear(PlayerESPObjects)
    
    for item, _ in pairs(CursedESPObjects) do
        RemoveCursedESP(item)
    end
    table.clear(CursedESPObjects)
    
    -- 重置UI标签
    if GhostAgeLabel then GhostAgeLabel:SetText("年龄: 未知") end
    if GhostCurrentRoomLabel then GhostCurrentRoomLabel:SetText("当前房间: 未知") end
    if GhostFavoriteRoomLabel then GhostFavoriteRoomLabel:SetText("最喜欢房间: 未知") end
    if GhostVisualModelLabel then GhostVisualModelLabel:SetText("视觉模型: 未知") end
    
    if ThermoCountLabel then ThermoCountLabel:SetText("温度计数量: 0") end
    if ThermoReadingLabel then ThermoReadingLabel:SetText("温度: 暂无数据") end
    getgenv().HasNotifiedThermometerEvidence = nil
    
    if HandprintCountLabel then HandprintCountLabel:SetText("手印数量: 0") end
    getgenv().HasNotifiedHandprintEvidence = nil
    
    if EMFCountLabel then EMFCountLabel:SetText("EMF数量: 0") end
    if EMFLevelLabel then EMFLevelLabel:SetText("EMF等级: 监听中...") end
    getgenv().EMFLockedTo5 = nil
    
    if SpiritBookUnwrittenLabel then SpiritBookUnwrittenLabel:SetText("灵书未写数量: 0") end
    if SpiritBookWrittenLabel then SpiritBookWrittenLabel:SetText("灵书已写数量: 0") end
    getgenv().HasNotifiedSpiritBookEvidence = nil
    
    if GhostOrbLabel then GhostOrbLabel:SetText("幽灵球证据: 无") end
    getgenv().HasNotifiedGhostOrbEvidence = nil
    
    if FlowerPotUnwitheredLabel then FlowerPotUnwitheredLabel:SetText("花盆未枯萎数量: 0") end
    if FlowerPotWitheredLabel then FlowerPotWitheredLabel:SetText("花盆已枯萎数量: 0") end
    getgenv().HasNotifiedFlowerPotEvidence = nil
    
    if ProjectorCountLabel then ProjectorCountLabel:SetText("投影仪数量: 0") end
    if ProjectorStateLabel then ProjectorStateLabel:SetText("投影仪证据: 监听中...") end
    getgenv().ProjectorLocked = nil

    print("[TY hub] 菜单已卸载，所有功能已彻底清理。")
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
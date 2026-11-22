-- 烘焙或死亡：独立服务器缝合版
local NothingLibrary = loadstring(game:HttpGetAsync('https://raw.githubusercontent.com/quanwei-sy/qianweicangku/refs/heads/main/%E6%BA%90%E7%A0%81.lua'))()

local __BaseWindow = NothingLibrary.new({
    Title = "TY hub｜烘焙或死亡",
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
	Title = '烤或死 - [AI版]',
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

-- UUID 内存穿透扫描器
getgenv().UUIDCache = getgenv().UUIDCache or {}

local function GetRealUUID(obj)
    if getgenv().UUIDCache[obj] then return getgenv().UUIDCache[obj] end
    
    local attrs = obj:GetAttributes()
    for _, val in pairs(attrs) do
        if type(val) == "string" and #val == 36 then
            getgenv().UUIDCache[obj] = val
            return val
        end
    end
    
    for _, child in ipairs(obj:GetDescendants()) do
        if child:IsA("StringValue") and type(child.Value) == "string" and #child.Value == 36 then
            getgenv().UUIDCache[obj] = child.Value
            return child.Value
        end
    end

    if getgc then
        for _, v in pairs(getgc(true)) do
            if type(v) == "table" then
                for key, val in pairs(v) do
                    if type(key) == "string" and #key == 36 then
                        if val == obj or (type(val) == "table" and rawget(val, "model") == obj) then
                            getgenv().UUIDCache[obj] = key
                            return key
                        end
                    end
                end
            end
        end
    end
    return nil
end

-- 共享翻译逻辑
local function TranslateItemName(name)
    return getgenv().GlobalItemTranslations[name] or name
end

-- 动态刷新Interactables物资列表
local function UpdateItemDropdowns()
    local interactables = workspace:FindFirstChild("Interactables")
    if not interactables then return end

    local itemCount = {}
    local rawNames = {}
    
    for _, obj in ipairs(interactables:GetChildren()) do
        if not itemCount[obj.Name] then
            itemCount[obj.Name] = 1
            table.insert(rawNames, obj.Name)
        else
            itemCount[obj.Name] = itemCount[obj.Name] + 1
        end
    end
    
    local allTranslatedNames = {}
    for _, rawName in ipairs(rawNames) do
        table.insert(allTranslatedNames, TranslateItemName(rawName))
    end
    table.sort(allTranslatedNames)
    
    local oldTargetSelections = {}
    if Options.TargetLootItems and Options.TargetLootItems.Value then
        for selectedStr, _ in pairs(Options.TargetLootItems.Value) do
            local baseName = string.match(selectedStr, "^(.-) %(x%d+%)$") or selectedStr
            oldTargetSelections[baseName] = true
        end
    end

    if Options.BlacklistItems then
        Options.BlacklistItems:SetValues(allTranslatedNames)
        if not getgenv().BlacklistInitialized then
            getgenv().BlacklistInitialized = true
            Options.BlacklistItems:SetValue({
                ["PathfindingModifier"] = true,
                ["头骨"] = true,
                ["擀面杖"] = true
            })
        end
    end
    
    local targetDisplayList = {}
    local blacklistVals = Options.BlacklistItems and Options.BlacklistItems.Value or {}
    
    for rawName, count in pairs(itemCount) do
        local tName = TranslateItemName(rawName)
        if not blacklistVals[tName] and not blacklistVals[rawName] then
            local displayStr = string.format("%s (x%d)", tName, count)
            table.insert(targetDisplayList, displayStr)
        end
    end
    
    table.sort(targetDisplayList, function(a, b)
        local baseA = string.match(a, "^(.-) %(x%d+%)$") or a
        local baseB = string.match(b, "^(.-) %(x%d+%)$") or b
        return baseA < baseB
    end)
    
    if Options.TargetLootItems then
        Options.TargetLootItems:SetValues(targetDisplayList)
        local newSelections = {}
        for _, displayStr in ipairs(targetDisplayList) do
            local baseName = string.match(displayStr, "^(.-) %(x%d+%)$") or displayStr
            if oldTargetSelections[baseName] then
                newSelections[displayStr] = true
            end
        end
        Options.TargetLootItems:SetValue(newSelections)
    end
end

-- 动态刷新Containers容器列表
local function UpdateContainerDropdowns()
    local containers = workspace:FindFirstChild("Containers")
    if not containers then return end

    local rawNames = {}
    local uniqueNames = {}
    for _, obj in ipairs(containers:GetChildren()) do
        if obj.Name ~= "ShippingContainer" and not uniqueNames[obj.Name] then
            uniqueNames[obj.Name] = true
            table.insert(rawNames, obj.Name)
        end
    end

    local translatedNames = {}
    for _, rawName in ipairs(rawNames) do
        table.insert(translatedNames, TranslateItemName(rawName))
    end
    table.sort(translatedNames)

    if Options.ContainerSelectDropdown then
        local oldTargetSelections = {}
        if Options.ContainerSelectDropdown.Value then
            for selectedStr, _ in pairs(Options.ContainerSelectDropdown.Value) do
                oldTargetSelections[selectedStr] = true
            end
        end

        Options.ContainerSelectDropdown:SetValues(translatedNames)

        local newSelections = {}
        for _, displayStr in ipairs(translatedNames) do
            if oldTargetSelections[displayStr] then
                newSelections[displayStr] = true
            end
        end
        Options.ContainerSelectDropdown:SetValue(newSelections)
    end
end

-- 地图标签页 - 左侧上方: 拾取功能
local MapGroupLeft = Tabs.Map:AddLeftGroupbox('拾取功能')

MapGroupLeft:AddDropdown('TargetLootItems', {
    Values = {},
    Default = 0,
    Multi = true,
    Text = '物资选择',
})

MapGroupLeft:AddButton({
    Text = '全选',
    Func = function()
        if Options.TargetLootItems then
            local allVals = {}
            for _, val in ipairs(Options.TargetLootItems.Values) do
                allVals[val] = true
            end
            Options.TargetLootItems:SetValue(allVals)
        end
    end,
    DoubleClick = false
}):AddButton({
    Text = '清除',
    Func = function()
        if Options.TargetLootItems then
            Options.TargetLootItems:SetValue({})
        end
    end,
    DoubleClick = false
})

MapGroupLeft:AddDropdown('BlacklistItems', {
    Values = {},
    Default = 0,
    Multi = true,
    Text = '黑名单',
})

Options.BlacklistItems:OnChanged(function()
    UpdateItemDropdowns()
end)

MapGroupLeft:AddButton({
    Text = '带来物资',
    Func = function()
        if not Options.TargetLootItems.Value then return end
        
        local selectedBaseNames = {}
        for k, _ in pairs(Options.TargetLootItems.Value) do
            local baseName = string.match(k, "^(.-) %(x%d+%)$") or k
            selectedBaseNames[baseName] = true
        end
        
        local hrp = game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        local interactables = workspace:FindFirstChild("Interactables")
        
        if hrp and interactables then
            local tpTargetCFrame = hrp.CFrame * CFrame.new(0, 0, -3)
            for _, obj in ipairs(interactables:GetChildren()) do
                local tName = TranslateItemName(obj.Name)
                if selectedBaseNames[tName] then
                    if obj.PrimaryPart then
                        obj:SetPrimaryPartCFrame(tpTargetCFrame)
                    elseif obj:IsA("BasePart") then
                        obj.CFrame = tpTargetCFrame
                    elseif obj:IsA("Model") then
                        obj:MoveTo(tpTargetCFrame.Position)
                    end
                end
            end
        end
    end,
    DoubleClick = false,
})

MapGroupLeft:AddToggle('AutoLootToggle', {
    Text = '拾取物资',
    Default = false,
})

Toggles.AutoLootToggle:OnChanged(function()
    getgenv().AutoLootState = Toggles.AutoLootToggle.Value
    if getgenv().AutoLootState then
        task.spawn(function()
            local ReplicatedStorage = game:GetService("ReplicatedStorage")
            local ZAP_RELIABLE = ReplicatedStorage:WaitForChild("ZAP"):WaitForChild("ZAP_RELIABLE")
            
            while getgenv().AutoLootState do
                if Options.TargetLootItems.Value then
                    local selectedBaseNames = {}
                    for k, _ in pairs(Options.TargetLootItems.Value) do
                        local baseName = string.match(k, "^(.-) %(x%d+%)$") or k
                        selectedBaseNames[baseName] = true
                    end
                    
                    local interactables = workspace:FindFirstChild("Interactables")
                    
                    if interactables then
                        for _, obj in ipairs(interactables:GetChildren()) do
                            local tName = TranslateItemName(obj.Name)
                            
                            if selectedBaseNames[tName] then
                                local realUUID = GetRealUUID(obj)
                                
                                if realUUID then
                                    local strLen = #realUUID
                                    local buffPickup = buffer.create(1 + 2 + strLen)
                                    buffer.writeu8(buffPickup, 0, 42)
                                    buffer.writeu16(buffPickup, 1, strLen)
                                    buffer.writestring(buffPickup, 3, realUUID, strLen)
                                    
                                    ZAP_RELIABLE:FireServer(buffPickup, {})
                                    
                                    local buffSlot = buffer.create(3)
                                    buffer.writeu8(buffSlot, 0, 40)
                                    buffer.writeu8(buffSlot, 1, 1)
                                    buffer.writeu8(buffSlot, 2, 1)
                                    
                                    ZAP_RELIABLE:FireServer(buffSlot, {})
                                    task.wait(0.05) 
                                else
                                    local prompt = obj:FindFirstChildWhichIsA("ProximityPrompt", true)
                                    if prompt then
                                        local oldLOS = prompt.RequiresLineOfSight
                                        prompt.RequiresLineOfSight = false
                                        fireproximityprompt(prompt, 1)
                                        prompt.RequiresLineOfSight = oldLOS
                                    end
                                end
                            end
                        end
                    end
                end
                task.wait(0.1)
            end
        end)
    end
end)

-- 地图标签页 - 左侧中段: 容器功能
local MapGroupLeft_Container = Tabs.Map:AddLeftGroupbox('容器功能')

getgenv().ContainerCountLabel = MapGroupLeft_Container:AddLabel('未开启数量: 0')

MapGroupLeft_Container:AddDropdown('ContainerSelectDropdown', {
    Values = {},
    Default = 0,
    Multi = true,
    Text = '容器选择',
})

-- 开启全局的容器数量监听
if not getgenv().GlobalContainerStatusConn then
    getgenv().GlobalContainerStatusConn = game:GetService("RunService").Heartbeat:Connect(function()
        local containers = workspace:FindFirstChild("Containers")
        if not containers or not Options.ContainerSelectDropdown then return end
        
        local selectedVals = Options.ContainerSelectDropdown.Value
        if not selectedVals or next(selectedVals) == nil then
            if getgenv().ContainerCountLabel then
                getgenv().ContainerCountLabel:SetText('未开启数量: 0')
            end
            return
        end
        
        local count = 0
        for _, chest in ipairs(containers:GetChildren()) do
            if chest.Name ~= "ShippingContainer" then
                local tName = TranslateItemName(chest.Name)
                if selectedVals[tName] or selectedVals[chest.Name] then
                    if chest:FindFirstChildWhichIsA("ProximityPrompt", true) then
                        count = count + 1
                    end
                end
            end
        end
        if getgenv().ContainerCountLabel then
            getgenv().ContainerCountLabel:SetText('未开启数量: ' .. count)
        end
    end)
end

MapGroupLeft_Container:AddButton({
    Text = '开启容器',
    Func = function()
        task.spawn(function()
            local LocalPlayer = game:GetService("Players").LocalPlayer
            local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            local containers = workspace:FindFirstChild("Containers")
            if not hrp or not containers then return end
            
            local savedCFrame = hrp.CFrame
            local selectedTranslated = Options.ContainerSelectDropdown.Value
            if not selectedTranslated or next(selectedTranslated) == nil then return end
            
            local selectedRawNames = {}
            for tName, _ in pairs(selectedTranslated) do
                for rawName, transName in pairs(getgenv().GlobalItemTranslations) do
                    if transName == tName then
                        selectedRawNames[rawName] = true
                    end
                end
                selectedRawNames[tName] = true 
            end

            -- 收集所有满足条件的容器，直接跑一遍
            local chestsToOpen = {}
            for _, chest in ipairs(containers:GetChildren()) do
                if chest.Name ~= "ShippingContainer" and selectedRawNames[chest.Name] then
                    local prompt = chest:FindFirstChildWhichIsA("ProximityPrompt", true)
                    if prompt then
                        table.insert(chestsToOpen, {chest = chest, prompt = prompt})
                    end
                end
            end

            if #chestsToOpen == 0 then
                Library:Notify("没有找到未开启的所选容器！", 3)
                return
            end

            for i, item in ipairs(chestsToOpen) do
                -- 中心点Y轴抬高5
                local targetPos = item.chest:GetPivot().Position + Vector3.new(0, 5, 0)
                
                -- 设置人物面朝下
                hrp.CFrame = CFrame.new(targetPos, targetPos - Vector3.new(0, 1, 0))
                
                -- 强制调整相机视角朝下保障视距交互
                local cam = workspace.CurrentCamera
                if cam then
                    cam.CFrame = CFrame.new(cam.CFrame.Position, targetPos - Vector3.new(0, 10, 0))
                end

                task.wait(0.25) -- 缓冲位移与物理加载
                
                local oldLOS = item.prompt.RequiresLineOfSight
                item.prompt.RequiresLineOfSight = false
                fireproximityprompt(item.prompt, 1)
                item.prompt.RequiresLineOfSight = oldLOS
                
                task.wait(0.15) -- 快速缓冲进入下一个
            end
            
            -- 跑完立刻返回原位置
            hrp.CFrame = savedCFrame
            Library:Notify("开箱完成！未开启数量稍后会自动刷新。", 3)
        end)
    end,
    DoubleClick = false
})

-- 地图标签页 - 左侧最下方: 存入功能
local MapGroupLeft_Deconstruct = Tabs.Map:AddLeftGroupbox('存入功能')

getgenv().MixerStatusLabel = MapGroupLeft_Deconstruct:AddLabel('搅拌机状态: 0/3')

-- 开启全局的搅拌机状态监听
if not getgenv().GlobalMixerStatusConn then
    getgenv().GlobalMixerStatusConn = game:GetService("RunService").Heartbeat:Connect(function()
        local statusText = "0/3"
        local LocalPlayer = game:GetService("Players").LocalPlayer
        local pg = LocalPlayer:FindFirstChild("PlayerGui")
        if pg then
            for _, desc in ipairs(pg:GetDescendants()) do
                if desc:IsA("TextLabel") and desc.Name == "CountLabel" then
                    if string.match(desc.Text, "%d+%s*/%s*%d+") then
                        statusText = desc.Text
                        break
                    end
                end
            end
        end
        if getgenv().MixerStatusLabel then
            getgenv().MixerStatusLabel:SetText('搅拌机状态: ' .. statusText)
        end
    end)
end

MapGroupLeft_Deconstruct:AddToggle('AutoDepositToggle', {
    Text = '自动存入',
    Default = false,
})

Toggles.AutoDepositToggle:OnChanged(function()
    getgenv().AutoDepositState = Toggles.AutoDepositToggle.Value
    local LocalPlayer = game:GetService("Players").LocalPlayer
    
    if getgenv().AutoDepositState then
        task.spawn(function()
            local ReplicatedStorage = game:GetService("ReplicatedStorage")
            local ZAP_RELIABLE = ReplicatedStorage:WaitForChild("ZAP"):WaitForChild("ZAP_RELIABLE")
            
            local function FireDeposit(target)
                local buff = buffer.create(2)
                buffer.writeu8(buff, 0, 43)
                buffer.writeu8(buff, 1, 1) 
                ZAP_RELIABLE:FireServer(buff, {target})
            end

            -- 冷却时间记录，防止满载时高频狂点卡死游戏混合进程
            getgenv().LastMixTime = 0

            while getgenv().AutoDepositState do
                local pg = LocalPlayer:FindFirstChild("PlayerGui")
                local stations = workspace:FindFirstChild("Stations")
                local mixerFull = false
                
                -- 1. 独立检测搅拌机是否满载
                local cur, max = 0, 3
                if getgenv().MixerStatusLabel then
                    local txt = getgenv().MixerStatusLabel.Text
                    local c, m = string.match(txt, "(%d+)%s*/%s*(%d+)")
                    if c and m then
                        cur = tonumber(c)
                        max = tonumber(m)
                    end
                end
                
                -- 当满载时，切断存入，并进入冷却交互逻辑
                if cur >= max and max > 0 then
                    mixerFull = true
                    if stations and (tick() - getgenv().LastMixTime > 2) then
                        local mixer = stations:FindFirstChild("Mixer")
                        local mixPrompt = mixer and mixer:FindFirstChild("MixProximityPrompt", true)
                        if mixPrompt and mixPrompt:IsA("ProximityPrompt") then
                            getgenv().LastMixTime = tick()
                            local oldLOS = mixPrompt.RequiresLineOfSight
                            mixPrompt.RequiresLineOfSight = false
                            fireproximityprompt(mixPrompt, 1)
                            mixPrompt.RequiresLineOfSight = oldLOS
                        end
                    end
                end

                -- 2. 独立检测手持物品并执行存入逻辑
                local equippedType = nil
                if pg then
                    for _, desc in ipairs(pg:GetDescendants()) do
                        if desc:IsA("ImageButton") then
                            local slotTypeLabel = desc:FindFirstChild("SlotType")
                            if slotTypeLabel and slotTypeLabel:IsA("TextLabel") then
                                local stroke = desc:FindFirstChildOfClass("UIStroke")
                                if stroke and stroke.Enabled and stroke.Transparency < 1 then
                                    equippedType = slotTypeLabel.Text
                                    break
                                end
                            end
                        end
                    end
                end

                if equippedType and stations then
                    local typeStr = tostring(equippedType)
                    if string.find(typeStr, "Crafting Part") or string.find(typeStr, "Blueprint") then
                        local bp = stations:FindFirstChild("BlueprintsTable")
                        local target = bp and bp:FindFirstChild("ObjectDeposit", true)
                        if target then FireDeposit(target) end
                        
                    elseif string.find(typeStr, "Corpse") then
                        local grinder = stations:FindFirstChild("Grinder")
                        local target = grinder and grinder:FindFirstChild("ObjectDeposit", true)
                        if target then FireDeposit(target) end
                        
                    elseif string.find(typeStr, "Ingredient") then
                        if not mixerFull then
                            local mixer = stations:FindFirstChild("Mixer")
                            local target = mixer and mixer:FindFirstChild("ObjectDeposit", true)
                            if target then FireDeposit(target) end
                        end
                    end
                end
                
                task.wait(0.1)
            end
        end)
    end
end)

-- 地图标签页 - 右侧传送功能
local MapGroupRight = Tabs.Map:AddRightGroupbox('传送功能')

local TeleportLocations = {
    ["餐厅"] = Vector3.new(-26.93, 51.58, 111.03),
    ["谷仓"] = Vector3.new(-203.90, 52.00, 330.81),
    ["实验室[入口]"] = Vector3.new(-87.50, 33.30, 378.85),
    ["医院"] = Vector3.new(-431.26, 62.96, -46.60),
    ["教堂"] = Vector3.new(-117.19, 51.00, -162.16),
    ["便利店"] = Vector3.new(253.37, 51.75, 4.36),
    ["加油站"] = Vector3.new(612.48, 51.14, 135.54),
    ["仓库"] = Vector3.new(608.02, 51.30, -184.41),
    ["银行"] = Vector3.new(966.31, 54.00, -128.30),
    ["重构器"] = Vector3.new(472.01, 90.96, -446.30),
    ["镭射枪"] = Vector3.new(433.35, 54.46, -572.75),
    ["食品工厂"] = Vector3.new(-611.60, 51.10, 54.96),
    ["常绿"] = Vector3.new(462.72, 51.14, -296.68),
    ["加特林"] = Vector3.new(-968.95, 55.00, -12.65),
    ["发电机"] = Vector3.new(91.55, 27.34, 131.52)
}

local BossLocations = {
    ["鼠老大"] = Vector3.new(122.90, 19.34, 382.52),
    ["末日莓"] = Vector3.new(-430.81, 13.30, 193.98),
    ["Z博士"] = Vector3.new(358.60, 90.96, -411.06),
    ["至尊头"] = Vector3.new(-983.31, 91.00, -123.52),
    ["厨师"] = Vector3.new(-1115.46, 91.00, -267.71)
}

local tpNames = {"未选择", "餐厅", "谷仓", "实验室[入口]", "医院", "教堂", "便利店", "加油站", "仓库", "银行", "重构器", "镭射枪", "食品工厂", "常绿", "加特林", "发电机"}
local bossNames = {"未选择", "鼠老大", "末日莓", "Z博士", "至尊头", "厨师"}

MapGroupRight:AddDropdown('TeleportLocation', {
    Values = tpNames,
    Default = 1,
    Multi = false,
    Text = '位置传送',
})

MapGroupRight:AddDropdown('BossLocation', {
    Values = bossNames,
    Default = 1,
    Multi = false,
    Text = 'Boss位置',
})

local isUpdatingTP = false
Options.TeleportLocation:OnChanged(function()
    if isUpdatingTP then return end
    if Options.TeleportLocation.Value ~= "未选择" and Options.BossLocation.Value ~= "未选择" then
        isUpdatingTP = true
        Options.BossLocation:SetValue("未选择")
        isUpdatingTP = false
    end
end)

Options.BossLocation:OnChanged(function()
    if isUpdatingTP then return end
    if Options.BossLocation.Value ~= "未选择" and Options.TeleportLocation.Value ~= "未选择" then
        isUpdatingTP = true
        Options.TeleportLocation:SetValue("未选择")
        isUpdatingTP = false
    end
end)

MapGroupRight:AddButton({
    Text = '传送',
    Func = function()
        local hrp = game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if not hrp then return end

        local targetPos = nil
        if Options.TeleportLocation.Value ~= "未选择" then
            targetPos = TeleportLocations[Options.TeleportLocation.Value]
        elseif Options.BossLocation.Value ~= "未选择" then
            targetPos = BossLocations[Options.BossLocation.Value]
        end

        if targetPos then
            hrp.CFrame = CFrame.new(targetPos)
        end
    end,
    DoubleClick = false
})

-- 地图标签页 - 右侧下方 Buff购买功能
local MapGroupRight_Buff = Tabs.Map:AddRightGroupbox('Buff购买')

getgenv().CashStatusLabel = MapGroupRight_Buff:AddLabel('玩家现金: $0')

if not getgenv().GlobalCashStatusConn then
    getgenv().GlobalCashStatusConn = game:GetService("RunService").Heartbeat:Connect(function()
        local cashText = "$0"
        local LocalPlayer = game:GetService("Players").LocalPlayer
        local pg = LocalPlayer:FindFirstChild("PlayerGui")
        if pg then
            local moneyUI = pg:FindFirstChild("Money")
            local tl = moneyUI and moneyUI:FindFirstChild("TextLabel")
            if tl and tl:IsA("TextLabel") then
                cashText = tl.Text
            end
        end
        if getgenv().CashStatusLabel then
            getgenv().CashStatusLabel:SetText('玩家现金: ' .. cashText)
        end
    end)
end

local JuicePurchaseInfo = {
    ['血量果汁 $1000'] = {name = "JugChugJuice", cost = 1000},
    ['跳跃果汁 $1500'] = {name = "JumpyJuice", cost = 1500},
    ['射速果汁 $10000'] = {name = "PewPewJuice", cost = 10000},
    ['伤害果汁 $6000'] = {name = "PowPowJuice", cost = 6000},
    ['耐力果汁 $3000'] = {name = "StaminaJuice", cost = 3000}
}

MapGroupRight_Buff:AddDropdown('JuiceDropdown', {
    Values = {'血量果汁 $1000', '跳跃果汁 $1500', '射速果汁 $10000', '伤害果汁 $6000', '耐力果汁 $3000'},
    Default = 1,
    Multi = false,
    Text = '果汁选择',
})

MapGroupRight_Buff:AddButton({
    Text = '购买果汁',
    Func = function()
        local selected = Options.JuiceDropdown.Value
        local info = JuicePurchaseInfo[selected]
        if not info then return end
        
        local currentCash = 0
        if getgenv().CashStatusLabel then
            local rawText = getgenv().CashStatusLabel.Text
            local numStr = string.match(rawText, "%d[%d%,]*")
            if numStr then
                numStr = string.gsub(numStr, ",", "")
                currentCash = tonumber(numStr) or 0
            end
        end
        
        if currentCash < info.cost then
            Library:Notify("现金不够无法购买", 3)
            return
        end
        
        local pm = workspace:FindFirstChild("PerkMachines")
        if pm then
            local machine = pm:FindFirstChild(info.name)
            local prompt = machine and machine:FindFirstChild("Prompt") and machine.Prompt:FindFirstChildOfClass("ProximityPrompt")
            if prompt then
                local oldLOS = prompt.RequiresLineOfSight
                prompt.RequiresLineOfSight = false
                fireproximityprompt(prompt, 1)
                prompt.RequiresLineOfSight = oldLOS
                Library:Notify("已尝试购买: " .. selected, 3)
            else
                Library:Notify("未找到对应果汁机交互按钮", 3)
            end
        else
            Library:Notify("未找到果汁机文件夹", 3)
        end
    end,
    DoubleClick = false
})

task.spawn(function()
    local interactables = workspace:WaitForChild("Interactables", 5)
    if interactables then
        UpdateItemDropdowns()
        getgenv().InteractablesAddedConn = interactables.ChildAdded:Connect(UpdateItemDropdowns)
        getgenv().InteractablesRemovedConn = interactables.ChildRemoved:Connect(UpdateItemDropdowns)
    end
    
    local containers = workspace:WaitForChild("Containers", 5)
    if containers then
        UpdateContainerDropdowns()
        getgenv().ContainersAddedConn = containers.ChildAdded:Connect(UpdateContainerDropdowns)
        getgenv().ContainersRemovedConn = containers.ChildRemoved:Connect(UpdateContainerDropdowns)
    end
end)

-- 功能标签页 - 左侧杀戮光环
local FuncGroupLeft = Tabs.Func:AddLeftGroupbox('杀戮光环')

FuncGroupLeft:AddDropdown('KillAuraType', {
    Values = {'近战武器', '远程武器', '职业武器[暂无]'},
    Default = 1,
    Multi = false,
    Text = '攻击类型',
})

FuncGroupLeft:AddSlider('KillAuraRange', {
    Text = '范围',
    Default = 66,
    Min = 15,
    Max = 500,
    Rounding = 0,
    Compact = false,
})

FuncGroupLeft:AddSlider('KillAuraFreq', {
    Text = '攻击频率',
    Default = 10,
    Min = 1,
    Max = 200,
    Rounding = 0,
    Compact = false,
})

FuncGroupLeft:AddLabel('注意事项: 武器需放在快捷栏第一格')

FuncGroupLeft:AddToggle('KillAuraToggle', {
    Text = '开启杀戮',
    Default = false,
})

Toggles.KillAuraToggle:OnChanged(function()
    getgenv().KillAuraState = Toggles.KillAuraToggle.Value
    if getgenv().KillAuraState then
        task.spawn(function()
            local ReplicatedStorage = game:GetService("ReplicatedStorage")
            local ZAP_RELIABLE = ReplicatedStorage:WaitForChild("ZAP"):WaitForChild("ZAP_RELIABLE")
            local ZAP_UNRELIABLE_0 = ReplicatedStorage:WaitForChild("ZAP"):WaitForChild("ZAP_UNRELIABLE_0")
            local LocalPlayer = game:GetService("Players").LocalPlayer

            while getgenv().KillAuraState do
                local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                local monstersFolder = workspace:FindFirstChild("Monsters")
                
                if hrp and monstersFolder then
                    local targets = {}
                    local radius = Options.KillAuraRange.Value
                    
                    for _, monster in ipairs(monstersFolder:GetChildren()) do
                        local targetHrp = monster:FindFirstChild("HumanoidRootPart") or monster.PrimaryPart
                        local humanoid = monster:FindFirstChildOfClass("Humanoid") or monster:FindFirstChild("Humanoid")
                        
                        if targetHrp and humanoid and humanoid.Health > 0 then
                            local dist = (hrp.Position - targetHrp.Position).Magnitude
                            if dist <= radius then
                                table.insert(targets, {
                                    model = monster,
                                    hrp = targetHrp,
                                    humanoid = humanoid
                                })
                            end
                        end
                    end
                    
                    if #targets > 0 then
                        local atkType = Options.KillAuraType.Value
                        local freq = Options.KillAuraFreq.Value
                        
                        for i = 1, freq do
                            if atkType == '近战武器' then
                                local monstersArray = {}
                                for _, t in ipairs(targets) do
                                    table.insert(monstersArray, t.model)
                                end
                                
                                local buff = buffer.create(6)
                                buffer.writeu8(buff, 0, 48)
                                buffer.writeu16(buff, 1, #monstersArray)
                                buffer.writeu16(buff, 3, 0)
                                buffer.writeu8(buff, 5, 1)
                                
                                ZAP_RELIABLE:FireServer(buff, monstersArray)
                                
                            elseif atkType == '远程武器' then
                                for _, t in ipairs(targets) do
                                    local buff = buffer.create(39)
                                    buffer.writeu8(buff, 0, 0) 
                                    buffer.writeu8(buff, 1, 1) 
                                    
                                    local dir = (t.hrp.Position - hrp.Position).Unit
                                    if dir.Magnitude ~= dir.Magnitude then dir = Vector3.new(0, 0, -1) end
                                    
                                    buffer.writef32(buff, 2, dir.X)
                                    buffer.writef32(buff, 6, dir.Y)
                                    buffer.writef32(buff, 10, dir.Z)
                                    
                                    buffer.writeu8(buff, 14, 1) 
                                    
                                    buffer.writef32(buff, 15, t.hrp.Position.X)
                                    buffer.writef32(buff, 19, t.hrp.Position.Y)
                                    buffer.writef32(buff, 23, t.hrp.Position.Z)
                                    
                                    buffer.writef32(buff, 27, -dir.X)
                                    buffer.writef32(buff, 31, -dir.Y)
                                    buffer.writef32(buff, 35, -dir.Z)
                                    
                                    ZAP_UNRELIABLE_0:FireServer(buff, {t.humanoid})
                                end
                            end
                        end
                    end
                end
                task.wait(0.1) 
            end
        end)
    end
end)

-- 功能标签页 - 右侧玩家功能
local FuncGroupRight = Tabs.Func:AddRightGroupbox('玩家功能')

local LocalPlayer = game:GetService("Players").LocalPlayer
local defaultWS = 16
if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
    defaultWS = LocalPlayer.Character.Humanoid.WalkSpeed
end

getgenv().OriginalWalkSpeed = defaultWS
getgenv().OriginalPrompts = getgenv().OriginalPrompts or {}

FuncGroupRight:AddToggle('WalkSpeedToggle', {
    Text = '启用移速',
    Default = false,
})

FuncGroupRight:AddSlider('WalkSpeedSlider', {
    Text = '移速设置',
    Default = defaultWS,
    Min = 10,
    Max = 66,
    Rounding = 0,
    Compact = false,
})

Toggles.WalkSpeedToggle:OnChanged(function()
    getgenv().WalkSpeedState = Toggles.WalkSpeedToggle.Value
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChild("Humanoid")
    
    if getgenv().WalkSpeedState then
        if hum and getgenv().OriginalWalkSpeed == nil then 
            getgenv().OriginalWalkSpeed = hum.WalkSpeed 
        end
        if not getgenv().WalkSpeedConn then
            getgenv().WalkSpeedConn = game:GetService("RunService").RenderStepped:Connect(function()
                local h = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid")
                if h and h.WalkSpeed ~= Options.WalkSpeedSlider.Value then 
                    h.WalkSpeed = Options.WalkSpeedSlider.Value 
                end
            end)
        end
    else
        if getgenv().WalkSpeedConn then 
            getgenv().WalkSpeedConn:Disconnect() 
            getgenv().WalkSpeedConn = nil 
        end
        if hum and getgenv().OriginalWalkSpeed then 
            hum.WalkSpeed = getgenv().OriginalWalkSpeed 
        end
    end
end)

FuncGroupRight:AddToggle('NoclipToggle', {
    Text = '穿墙',
    Default = false,
})

Toggles.NoclipToggle:OnChanged(function()
    getgenv().NoclipState = Toggles.NoclipToggle.Value
    if getgenv().NoclipState then
        if not getgenv().NoclipConn then
            getgenv().NoclipConn = game:GetService("RunService").Stepped:Connect(function()
                local char = LocalPlayer.Character
                if char then
                    for _, v in ipairs(char:GetDescendants()) do
                        if v:IsA("BasePart") and v.CanCollide then
                            v.CanCollide = false
                        end
                    end
                end
            end)
        end
    else
        if getgenv().NoclipConn then 
            getgenv().NoclipConn:Disconnect() 
            getgenv().NoclipConn = nil 
        end
    end
end)

FuncGroupRight:AddToggle('FastInteractToggle', {
    Text = '快速交互',
    Default = false,
})

local function ApplyFastInteract(prompt)
    if prompt:IsA("ProximityPrompt") then
        if not getgenv().OriginalPrompts[prompt] then
            getgenv().OriginalPrompts[prompt] = prompt.HoldDuration
        end
        prompt.HoldDuration = 0
    end
end

Toggles.FastInteractToggle:OnChanged(function()
    getgenv().FastInteractState = Toggles.FastInteractToggle.Value
    if getgenv().FastInteractState then
        for _, v in ipairs(workspace:GetDescendants()) do 
            ApplyFastInteract(v) 
        end
        if not getgenv().FastInteractConn then
            getgenv().FastInteractConn = workspace.DescendantAdded:Connect(ApplyFastInteract)
        end
    else
        if getgenv().FastInteractConn then 
            getgenv().FastInteractConn:Disconnect() 
            getgenv().FastInteractConn = nil 
        end
        for prompt, originalDuration in pairs(getgenv().OriginalPrompts) do
            if prompt and prompt.Parent then
                prompt.HoldDuration = originalDuration
            end
        end
        table.clear(getgenv().OriginalPrompts)
    end
end)

FuncGroupRight:AddToggle('FlightToggle', {
    Text = '飞行',
    Default = false,
})

FuncGroupRight:AddSlider('FlightSpeed', {
    Text = '飞行速度',
    Default = 5,
    Min = 1,
    Max = 200,
    Rounding = 0,
    Compact = false,
})

local flightMoveVector = Vector3.new(0, 0, 0)

local function GetFlightInput()
    local moveVec = Vector3.new(0, 0, 0)
    local success = pcall(function()
        local controls = require(LocalPlayer.PlayerScripts:WaitForChild("PlayerModule")):GetControls()
        moveVec = controls:GetMoveVector()
    end)
    if not success or moveVec.Magnitude == 0 then
        local f, b, l, r = 0, 0, 0, 0
        local UIS = game:GetService("UserInputService")
        f = UIS:IsKeyDown(Enum.KeyCode.W) and 1 or 0
        b = UIS:IsKeyDown(Enum.KeyCode.S) and 1 or 0
        l = UIS:IsKeyDown(Enum.KeyCode.A) and 1 or 0
        r = UIS:IsKeyDown(Enum.KeyCode.D) and 1 or 0
        moveVec = Vector3.new(r - l, 0, b - f)
    end
    flightMoveVector = moveVec
end

Toggles.FlightToggle:OnChanged(function()
    getgenv().FlightState = Toggles.FlightToggle.Value
    local char = LocalPlayer.Character
    local hum = char and (char:FindFirstChildOfClass("Humanoid") or char:FindFirstChildOfClass("AnimationController"))
    
    if getgenv().FlightState and char and hum then
        if char:FindFirstChild("Animate") then char.Animate.Disabled = true end
        for _, v in next, hum:GetPlayingAnimationTracks() do
            v:AdjustSpeed(0)
        end
        
        hum:SetStateEnabled(Enum.HumanoidStateType.Climbing, false)
        hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
        hum:SetStateEnabled(Enum.HumanoidStateType.Flying, false)
        hum:SetStateEnabled(Enum.HumanoidStateType.Freefall, false)
        hum:SetStateEnabled(Enum.HumanoidStateType.GettingUp, false)
        hum:SetStateEnabled(Enum.HumanoidStateType.Jumping, false)
        hum:SetStateEnabled(Enum.HumanoidStateType.Landed, false)
        hum:SetStateEnabled(Enum.HumanoidStateType.Physics, false)
        hum:SetStateEnabled(Enum.HumanoidStateType.PlatformStanding, false)
        hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
        hum:SetStateEnabled(Enum.HumanoidStateType.Running, false)
        hum:SetStateEnabled(Enum.HumanoidStateType.RunningNoPhysics, false)
        hum:SetStateEnabled(Enum.HumanoidStateType.Seated, false)
        hum:SetStateEnabled(Enum.HumanoidStateType.StrafingNoPhysics, false)
        hum:SetStateEnabled(Enum.HumanoidStateType.Swimming, false)
        hum:ChangeState(Enum.HumanoidStateType.Swimming)
        
        hum.PlatformStand = true
        
        local root = char:FindFirstChild("HumanoidRootPart") or char.PrimaryPart
        if not root then return end
        
        getgenv().FlightBG = Instance.new("BodyGyro", root)
        getgenv().FlightBG.P = 9e4
        getgenv().FlightBG.maxTorque = Vector3.new(9e9, 9e9, 9e9)
        getgenv().FlightBG.cframe = root.CFrame
        
        getgenv().FlightBV = Instance.new("BodyVelocity", root)
        getgenv().FlightBV.velocity = Vector3.new(0, 0, 0)
        getgenv().FlightBV.maxForce = Vector3.new(9e9, 9e9, 9e9)
        
        getgenv().FlightConn = game:GetService("RunService").RenderStepped:Connect(function()
            if not getgenv().FlightState or not LocalPlayer.Character or LocalPlayer.Character.Humanoid.Health <= 0 then return end
            
            GetFlightInput()
            local targetSpeed = Options.FlightSpeed.Value * 8 
            local cam = workspace.CurrentCamera
            
            if flightMoveVector.Magnitude > 0 then
                local moveDir = (cam.CFrame.RightVector * flightMoveVector.X + cam.CFrame.LookVector * -flightMoveVector.Z).Unit
                getgenv().FlightBV.velocity = moveDir * targetSpeed
            else
                getgenv().FlightBV.velocity = Vector3.new(0, 0, 0)
            end
            
            getgenv().FlightBG.cframe = cam.CFrame
        end)
        
    elseif not getgenv().FlightState and char and hum then
        if getgenv().FlightConn then getgenv().FlightConn:Disconnect() getgenv().FlightConn = nil end
        if getgenv().FlightBG then getgenv().FlightBG:Destroy() getgenv().FlightBG = nil end
        if getgenv().FlightBV then getgenv().FlightBV:Destroy() getgenv().FlightBV = nil end
        
        flightMoveVector = Vector3.new(0, 0, 0)
        
        hum.PlatformStand = false
        if char:FindFirstChild("Animate") then char.Animate.Disabled = false end
        
        hum:SetStateEnabled(Enum.HumanoidStateType.Climbing, true)
        hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, true)
        hum:SetStateEnabled(Enum.HumanoidStateType.Flying, true)
        hum:SetStateEnabled(Enum.HumanoidStateType.Freefall, true)
        hum:SetStateEnabled(Enum.HumanoidStateType.GettingUp, true)
        hum:SetStateEnabled(Enum.HumanoidStateType.Jumping, true)
        hum:SetStateEnabled(Enum.HumanoidStateType.Landed, true)
        hum:SetStateEnabled(Enum.HumanoidStateType.Physics, true)
        hum:SetStateEnabled(Enum.HumanoidStateType.PlatformStanding, true)
        hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, true)
        hum:SetStateEnabled(Enum.HumanoidStateType.Running, true)
        hum:SetStateEnabled(Enum.HumanoidStateType.RunningNoPhysics, true)
        hum:SetStateEnabled(Enum.HumanoidStateType.Seated, true)
        hum:SetStateEnabled(Enum.HumanoidStateType.StrafingNoPhysics, true)
        hum:SetStateEnabled(Enum.HumanoidStateType.Swimming, true)
        hum:ChangeState(Enum.HumanoidStateType.RunningNoPhysics)
    end
end)

-- 功能标签页 - 右侧最下方 实用功能
local FuncGroupRight_Utility = Tabs.Func:AddRightGroupbox('实用功能')

FuncGroupRight_Utility:AddButton('清理雾墙', function()
    local count = 0
    -- 深度遍历清理所有名字符合的实例
    for _, v in ipairs(workspace:GetDescendants()) do
        if v.Name == "FogWall" then
            v:Destroy()
            count = count + 1
        end
    end
    Library:Notify("已清理 " .. count .. " 个雾墙", 3)
end)

FuncGroupRight_Utility:AddLabel('注意事项:动画有时候可能没效果')

FuncGroupRight_Utility:AddButton('清理过场动画', function()
    local cutscenes = workspace:FindFirstChild("Cutscenes")
    if cutscenes then
        cutscenes:Destroy()
        Library:Notify("已清理过场动画", 3)
    else
        Library:Notify("当前没有过场动画文件", 3)
    end
end)

FuncGroupRight_Utility:AddButton('获取密码', function()
    -- 1. KeyItemPromptAnchor
    local prompt1 = workspace:FindFirstChild("KeyItemPromptAnchor") and workspace.KeyItemPromptAnchor:FindFirstChildWhichIsA("ProximityPrompt", true)
    
    local world = workspace:FindFirstChild("World")
    
    -- 2. ScienceFacility -> RaygunCode -> Primary
    local prompt2 = world and world:FindFirstChild("ScienceFacility") and world.ScienceFacility:FindFirstChild("RaygunCode") and world.ScienceFacility.RaygunCode:FindFirstChild("Primary") and world.ScienceFacility.RaygunCode.Primary:FindFirstChildWhichIsA("ProximityPrompt", true)
    
    -- 3. Bank -> BankClipboard -> Part
    local prompt3 = world and world:FindFirstChild("Bank") and world.Bank:FindFirstChild("BankClipboard") and world.Bank.BankClipboard:FindFirstChild("Part") and world.Bank.BankClipboard.Part:FindFirstChildWhichIsA("ProximityPrompt", true)
    
    local prompts = {prompt1, prompt2, prompt3}
    local count = 0
    
    for _, prompt in ipairs(prompts) do
        if prompt and prompt:IsA("ProximityPrompt") then
            local oldLOS = prompt.RequiresLineOfSight
            prompt.RequiresLineOfSight = false
            fireproximityprompt(prompt, 1)
            prompt.RequiresLineOfSight = oldLOS
            count = count + 1
        end
    end
    
    if count > 0 then
        Library:Notify("已成功获取 " .. count .. " 个密码获取点", 3)
    else
        Library:Notify("当前地图未发现可交互的密码点", 3)
    end
end)

-- 卸载清理与 UI 调试
local MenuGroup = Tabs["UI Settings"]:AddLeftGroupbox('设置')

MenuGroup:AddButton('卸载菜单', function() 
    getgenv().AutoLootState = false 
    getgenv().AutoDepositState = false
    getgenv().KillAuraState = false 
    getgenv().WalkSpeedState = false
    getgenv().NoclipState = false
    getgenv().FastInteractState = false
    getgenv().FlightState = false
    getgenv().UUIDCache = nil
    getgenv().BlacklistInitialized = nil
    
    if getgenv().InteractablesAddedConn then
        getgenv().InteractablesAddedConn:Disconnect()
        getgenv().InteractablesAddedConn = nil
    end
    
    if getgenv().InteractablesRemovedConn then
        getgenv().InteractablesRemovedConn:Disconnect()
        getgenv().InteractablesRemovedConn = nil
    end
    
    if getgenv().ContainersAddedConn then
        getgenv().ContainersAddedConn:Disconnect()
        getgenv().ContainersAddedConn = nil
    end
    
    if getgenv().ContainersRemovedConn then
        getgenv().ContainersRemovedConn:Disconnect()
        getgenv().ContainersRemovedConn = nil
    end
    
    if getgenv().GlobalMixerStatusConn then
        getgenv().GlobalMixerStatusConn:Disconnect()
        getgenv().GlobalMixerStatusConn = nil
    end

    if getgenv().GlobalCashStatusConn then
        getgenv().GlobalCashStatusConn:Disconnect()
        getgenv().GlobalCashStatusConn = nil
    end
    
    if getgenv().GlobalContainerStatusConn then
        getgenv().GlobalContainerStatusConn:Disconnect()
        getgenv().GlobalContainerStatusConn = nil
    end
    
    if getgenv().WalkSpeedConn then 
        getgenv().WalkSpeedConn:Disconnect() 
        getgenv().WalkSpeedConn = nil 
        local h = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid")
        if h and getgenv().OriginalWalkSpeed then h.WalkSpeed = getgenv().OriginalWalkSpeed end
    end
    
    if getgenv().NoclipConn then 
        getgenv().NoclipConn:Disconnect() 
        getgenv().NoclipConn = nil 
    end
    
    if getgenv().FastInteractConn then 
        getgenv().FastInteractConn:Disconnect() 
        getgenv().FastInteractConn = nil 
        for prompt, originalDuration in pairs(getgenv().OriginalPrompts) do
            if prompt and prompt.Parent then
                prompt.HoldDuration = originalDuration
            end
        end
        table.clear(getgenv().OriginalPrompts)
    end
    
    if getgenv().FlightConn then
        getgenv().FlightConn:Disconnect() 
        getgenv().FlightConn = nil 
        if getgenv().FlightBG then getgenv().FlightBG:Destroy() getgenv().FlightBG = nil end
        if getgenv().FlightBV then getgenv().FlightBV:Destroy() getgenv().FlightBV = nil end
        local char = LocalPlayer.Character
        local hum = char and char:FindFirstChild("Humanoid")
        if hum then
            hum.PlatformStand = false
            hum:ChangeState(Enum.HumanoidStateType.RunningNoPhysics)
        end
        if char and char:FindFirstChild("Animate") then char.Animate.Disabled = false end
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

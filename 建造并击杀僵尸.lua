local Players = game:GetService("Players")
local LP = Players.LocalPlayer
local function SendDrive()
    local ok, err = pcall(function()
        local args = {
            buffer.fromstring("\016")
        }
        game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("Packets"):WaitForChild("Packet"):WaitForChild("RemoteEvent"):FireServer(unpack(args))
    end)
end

	-- 建造并击杀僵尸：独立服务器缝合版
-- 当前服务器功能与独立界面整合版
-- 每个文件仅包含当前服务器的功能与独立关于分区

local NothingLibrary = loadstring(game:HttpGetAsync('https://raw.githubusercontent.com/quanwei-sy/qianweicangku/refs/heads/main/%E6%BA%90%E7%A0%81.lua'))()

local __BaseWindow = NothingLibrary.new({
    Title = "TY hub｜建造并击杀僵尸",
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
    __unloadCallbacks = {},
}
local WindUI = Library
local WI = Library
local ThemeManager = __ManagerStub()
local SaveManager = __ManagerStub()
local Options = Library.Options
local Toggles = Library.Toggles
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

    function control:__Attach(raw)
        self.__raw = raw
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
    return tostring(info.Text or info.Title or info.Name or fallback or "")
end

local function __Default(info)
    if info.Default ~= nil then
        return info.Default
    end
    return info.Value
end

local function __NewSection(rawSection)
    local section = { __raw = rawSection }

    function section:AddToggle(a, b)
        local key, info = __ControlInfo(a, b)
        local control = __NewControl(__Default(info) == true, info.Callback or info.Changed)
        local raw = rawSection:NewToggle({
            Title = __Text(info, "开关"),
            Default = __Default(info) == true,
            Callback = function(value)
                control:__Callback(value)
            end,
        })
        control:__Attach(raw)
        if key ~= nil then Library.Toggles[tostring(key)] = control end
        return control
    end

    section.Toggle = section.AddToggle

    function section:AddSlider(a, b)
        local key, info = __ControlInfo(a, b)
        local minValue = tonumber(info.Min) or 0
        local maxValue = tonumber(info.Max) or 100
        local defaultValue = tonumber(__Default(info)) or minValue
        local control = __NewControl(defaultValue, info.Callback or info.Changed)
        local raw = rawSection:NewSlider({
            Title = __Text(info, "滑块"),
            Min = minValue,
            Max = maxValue,
            Default = defaultValue,
            Callback = function(value)
                control:__Callback(value)
            end,
        })
        control:__Attach(raw)
        if key ~= nil then Library.Options[tostring(key)] = control end
        return control
    end

    section.Slider = section.AddSlider

    function section:AddDropdown(a, b)
        local key, info = __ControlInfo(a, b)
        local values = info.Values or info.Data or info.Options or {}
        local defaultValue = __Default(info)
        local callback = info.Callback or info.Changed
        local multi = info.Multi == true
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
        control:__Attach(raw)
        if key ~= nil then Library.Options[tostring(key)] = control end
        return control
    end

    section.Dropdown = section.AddDropdown

    function section:AddInput(a, b)
        local key, info = __ControlInfo(a, b)
        local defaultValue = __Default(info)
        local control = __NewControl(defaultValue, info.Callback or info.Changed)
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
        local callback = info.Callback or info.Func
        local control = __NewControl(nil, callback)
        local raw = rawSection:NewButton({
            Title = __Text(info, "按钮"),
            Callback = callback,
        })
        control:__Attach(raw)
        return control
    end

    section.Button = section.AddButton

    function section:AddLabel(a, b)
        local info = (type(a) == "table" and a or {Text = a})
        local text = __Text(info, "")
        if b ~= nil then text = text .. " " .. tostring(b) end
        local control = __NewControl(text)
        control.__isLabel = true
        local raw = rawSection:NewTitle(text)
        control:__Attach(raw)
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
        control:__Attach(raw)
        if key ~= nil then Library.Options[tostring(key)] = control end
        return control
    end

    section.Keybind = section.AddKeyPicker

    function section:AddColorPicker(a, b)
        local key, info = __ControlInfo(a, b)
        local defaultValue = __Default(info) or Color3.new(1, 1, 1)
        local control = __NewControl(defaultValue, info.Callback or info.Changed)
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
        local title = (type(info) == "table" and (info.Title or info.Name)) or info or "功能"
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
    function tab:Keybind(info) return self:__DefaultSection():Keybind(info) end
    function tab:ColorPicker(info) return self:__DefaultSection():ColorPicker(info) end

    return tab
end

local function __NewWindow()
    local window = { Window = __BaseWindow, UIElements = {} }

    function window:AddTab(name)
        return __NewTab(__BaseWindow:NewTab({
            Title = tostring(name or "页面"),
            Description = tostring(name or "功能"),
            Icon = "rbxassetid://7733960981",
        }))
    end

    function window:Tab(info)
        local title = (type(info) == "table" and (info.Title or info.Name)) or info or "页面"
        return self:AddTab(title)
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

    function window:Destroy()
        return Library:Unload()
    end

    function window:Unload()
        return Library:Unload()
    end

    function window:Show() end
    function window:Hide() end
    function window:Open() end
    function window:Close() end
    function window:Toggle() end

    return window
end

function Library:CreateWindow()
    self.__window = self.__window or __NewWindow()
    return self.__window
end

function Library:Notify(info, duration)
    local title, description = "提示", ""
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



Library.Toggles = Library.Toggles or {}
Library.Options = Library.Options or {}


local ThemeManager = Library.ThemeManager
local SaveManager = Library.SaveManager


local Window = Library:CreateWindow({ Title = "建造并击杀僵尸", Footer = "权威不是权威" })
local Tabs = { Main = Window:AddTab("主页", "user"), Mod = Window:AddTab("修改车", "wrench"), UI = Window:AddTab("UI设置", "settings") }
local MenuGroup = Tabs.UI:AddLeftGroupbox("菜单")

local LastUnloadAt

MenuGroup:AddButton("卸载脚本", function()
	local function DoUnload()
		task.defer(function()
			pcall(function()
				Library:Unload()
			end)
		end)
	end

	local OkDialog = pcall(function()
		Window:AddDialog("TYUnloadConfirm", {
			Title = "卸载脚本",
			Description = "确定要卸载脚本吗？所有已启用的功能将被关闭，脚本随即终止。",
			AutoDismiss = false,
			OutsideClickDismiss = false,
			FooterButtons = {
				Cancel = {
					Title = "取消",
					Variant = "Ghost",
					Order = 1,
					Callback = function(Dialog)
						Dialog:Dismiss()
					end,
				},
				Unload = {
					Title = "卸载",
					Variant = "Destructive",
					Order = 2,
					Callback = function(Dialog)
						Dialog:Dismiss()
						DoUnload()
					end,
				},
			},
		})
	end)

	if OkDialog then
		return
	end

	if not LastUnloadAt or (os.clock() - LastUnloadAt) > 5 then
		LastUnloadAt = os.clock()
		pcall(function()
			Library:Notify("再次点击「卸载脚本」确认卸载，5 秒内有效")
		end)
		return
	end

	LastUnloadAt = nil
	DoUnload()
end)

MenuGroup:AddLabel("菜单快捷键")
MenuGroup:AddKeyPicker("MenuKeybind", {
	Default = "RightShift",
	Visible = false,
	Text = "菜单快捷键",
})

Library.ToggleKeybind = Library.Options and Library.Options.MenuKeybind

local ThemeManager = Library.ThemeManager
local SaveManager = Library.SaveManager

if type(ThemeManager) == "table" then
	ThemeManager:SetLibrary(Library)
	ThemeManager:SetFolder("TYUITheme")
	ThemeManager:ApplyToTab(Tabs.UI)
end

if type(SaveManager) == "table" then
	SaveManager:SetLibrary(Library)
	SaveManager:SetFolder("TYUIConfig")
	SaveManager:BuildConfigSection(Tabs.UI)
end
local function GetCharPart()
    local char = LP.Character
    if char then
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if hrp then
            return hrp
        end
        return char:FindFirstChild("Head")
    end
    return nil
end
local function IsDriving()
    local char = LP.Character
    if not char then return false end
    local hum = char:FindFirstChild("Humanoid")
    if not hum then return false end
    local seat = hum.SeatPart
    if seat then
        local cars = workspace:FindFirstChild("Cars")
        if cars then
            local anc = seat:FindFirstAncestorWhichIsA("Model")
            if anc and anc:IsDescendantOf(cars) then
                return true
            end
        end
    end
    return false
end
local function FindPromptPart(v)
    local p = v.Parent
    if not p then return nil end
    if p:IsA("BasePart") then
        return p
    end
    if p:IsA("Attachment") and p.Parent and p.Parent:IsA("BasePart") then
        return p.Parent
    end
    local found = p:FindFirstChildWhichIsA("BasePart", true)
    if found then
        return found
    end
    local gp = p.Parent
    if gp then
        found = gp:FindFirstChildWhichIsA("BasePart", true)
        if found then
            return found
        end
    end
    return nil
end
local HomeBox = Tabs.Main:AddLeftGroupbox("自动互动(用于点击摇杆购买物品)")
local AutoI = HomeBox:AddToggle("AutoI", { Text = "自动互动", Default = false })
local RangeS = HomeBox:AddSlider("RangeS", { Text = "互动范围", Min = 5, Max = 100, Default = 12, Suffix = "", Compact = false })
task.spawn(function()
    while true do
        task.wait(0.5)
        if AutoI.Value then
            local cp = GetCharPart()
            if cp then
                local cpos = cp.Position
                local range = RangeS.Value or 12
                for _, v in ipairs(workspace:GetDescendants()) do
                    if v.ClassName == "ProximityPrompt" and v.Parent then
                        local part = FindPromptPart(v)
                        if part and (part.Position - cpos).Magnitude <= range then
                            pcall(function() fireproximityprompt(v, v.HoldDuration) end)
                        end
                    end
                end
            end
        end
    end
end)
local DriveBox = Tabs.Main:AddLeftGroupbox("驾驶")
local AutoD = DriveBox:AddToggle("AutoD", { Text = "自动驾驶循环(配合自动刷钱使用)", Default = false })
DriveBox:AddButton({ Text = "点击驾驶一次", Func = function()
    SendDrive()
end })
task.spawn(function()
    while true do
        task.wait(1)
        if AutoD.Value then
            SendDrive()
        end
    end
end)
local FlyBox = Tabs.Main:AddLeftGroupbox("自动刷钱")
local AutoF = FlyBox:AddToggle("AutoF", { Text = "自动刷钱(需要上车)", Default = false })
local FlyS = FlyBox:AddSlider("FlyS", { Text = "速度(调快的话会被拉回)", Min = 16, Max = 200, Default = 16, Suffix = "", Compact = false })
local function Clamp(v, lo, hi)
    if v < lo then return lo end
    if v > hi then return hi end
    return v
end
local function GroundHeight(hrp)
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    local exclude = { LP.Character }
    local cars = workspace:FindFirstChild("Cars")
    if cars then
        exclude[#exclude + 1] = cars
    end
    params.FilterDescendantsInstances = exclude
    local hit = workspace:Raycast(hrp.Position, Vector3.new(0, -300, 0), params)
    if hit and hit.Position then
        return hit.Position.Y
    end
    return nil
end
task.spawn(function()
    local bv = nil
    local targetY = 0
    local warned = false
    while true do
        task.wait(0.1)
        if AutoF.Value then
            if IsDriving() then
                local hrp = GetCharPart()
                if hrp then
                    warned = false
                    if not bv then
                        bv = Instance.new("BodyVelocity")
                        bv.MaxForce = Vector3.new(9e5, 9e5, 9e5)
                        bv.Parent = hrp
                    end
                    local g = GroundHeight(hrp)
                    if g then
                        targetY = g + 4
                    end
                    local speed = FlyS.Value or 16
                    local look = hrp.CFrame.LookVector
                    local dy = Clamp((targetY - hrp.Position.Y) * 3, -30, 30)
                    bv.Velocity = Vector3.new(look.X * speed, dy, look.Z * speed)
                else
                    if bv then
                        bv:Destroy()
                        bv = nil
                    end
                    if not warned then
                        warned = true
                    end
                end
            else
                if bv then
                    bv:Destroy()
                    bv = nil
                end
                if not warned then
                    warned = true
                end
            end
        else
            if bv then
                bv:Destroy()
                bv = nil
            end
        end
    end
end)
local Box = Tabs.Mod:AddLeftGroupbox("车辆属性修改")
local Defaults = {}
local Target = {}
local attrs = { "TopSpeed", "Accel", "EnginePower", "Fuel", "CarHealth", "TotalHealthExtra", "TotalDamageExtra", "TurboMult", "TurboCount", "NitroFuel", "SupportRatio", "TotalMass", "Turn", "BodyLift", "FuelTime" }
local attrNames = { "最高速度", "加速", "引擎功率", "燃料", "车血量", "额外血量", "额外伤害", "涡轮倍率", "涡轮次数", "氮气燃料", "支撑比", "总质量", "转向", "车身抬升", "燃料时间" }
local boolAttrs = { "TurboActive", "NitroBlocked" }
local boolNames = { "涡轮激活", "氮气封锁" }
local function FindCar()
    local cars = workspace:FindFirstChild("Cars")
    if not cars then return nil end
    for _, car in ipairs(cars:GetChildren()) do
        if car:IsA("Model") and car:GetAttribute("DriverUserId") == LP.UserId then
            return car
        end
    end
    for _, car in ipairs(cars:GetChildren()) do
        if car:IsA("Model") and car:GetAttribute("OwnerUserId") == LP.UserId then
            return car
        end
    end
    return nil
end
local function Snapshot(car)
    if Defaults.snapped then return end
    for i, attr in ipairs(attrs) do
        Defaults[attr] = car:GetAttribute(attr)
    end
    for i, attr in ipairs(boolAttrs) do
        Defaults[attr] = car:GetAttribute(attr)
    end
    Defaults.snapped = true
end
local function ApplyAll(car)
    for i, attr in ipairs(attrs) do
        local v = Target[attr]
        if v ~= nil then car:SetAttribute(attr, v) end
    end
    for i, attr in ipairs(boolAttrs) do
        local v = Target[attr]
        if v ~= nil then car:SetAttribute(attr, v >= 0.5) end
    end
end
local function RestoreAll(car)
    if not Defaults.snapped then
        return
    end
    for i, attr in ipairs(attrs) do
        if Defaults[attr] ~= nil then car:SetAttribute(attr, Defaults[attr]) end
    end
    for i, attr in ipairs(boolAttrs) do
        if Defaults[attr] ~= nil then car:SetAttribute(attr, Defaults[attr]) end
    end
end
Box:AddButton({ Text = "应用修改", Func = function()
    local car = FindCar()
    if not car then
        return
    end
    Snapshot(car)
    ApplyAll(car)
end })
Box:AddButton({ Text = "恢复默认", Func = function()
    local car = FindCar()
    if not car then
        return
    end
    RestoreAll(car)
end })
for i, attr in ipairs(attrs) do
    local s = Box:AddSlider(attr, { Text = attrNames[i], Min = 1, Max = 1000, Default = 100, Suffix = "", Compact = false, Callback = function(v)
        Target[attr] = v
    end })
end
for i, attr in ipairs(boolAttrs) do
    local s = Box:AddSlider(attr, { Text = boolNames[i], Min = 0, Max = 1, Default = 0, Suffix = "", Compact = false, Callback = function(v)
        Target[attr] = v
    end })
end

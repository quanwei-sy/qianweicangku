local Env = getfenv()

local LogService = game:GetService("LogService")
local getconnections = Env.getconnections
local MessageOut = "MessageOut"
local cons = getconnections(LogService[MessageOut])
if cons then
    for _, v in pairs(cons) do
        pcall(function() v:Disable() end)
    end
end

local function cleanupConnections()
    pcall(function()
        for _, conn in ipairs(getconnections(LogService.MessageOut) or {}) do
            pcall(function() conn:Disable() end)
        end
    end)
end
cleanupConnections()

print("环境净化完成，LogService 干扰已禁用")

-- 决斗场：独立服务器缝合版
-- 当前服务器功能与独立界面整合版
-- 每个文件仅包含当前服务器的功能与独立关于分区

local NothingLibrary = loadstring(game:HttpGetAsync('https://raw.githubusercontent.com/quanwei-sy/qianweicangku/refs/heads/main/%E6%BA%90%E7%A0%81.lua'))()

local __BaseWindow = NothingLibrary.new({
    Title = "TY hub｜决斗场",
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



local Window = Library:CreateWindow({
    Title = "TY hub",
    Footer = "权威不是权威",
    ShowCustomCursor = true,
})

local Tabs = {
    Combat = Window:AddTab('战斗'),
    Settings = Window:AddTab('设置'),
}

local cfg = {
    rng = 18,
    atk = false,
    blk = false,
    pry = false,
    ddg = false,
    ult = false,
    dashAtk = false,
    crit = false,
    win = 0.25,
    autoCollect = false,
    autoStrength = false,
    autoSteal = false,
    autoSpeed = false,
    autoRebirth = false,
    dodgeKey = false,
    fullBright = false,
    orbit = false,
    blind = false,
    annoy = false,
    flingAll = false,
    fakeLag = false,
    chatSpam = false,
    clone = false,
}

local CombatGroup = Tabs.Combat:AddLeftGroupbox('自动战斗')
CombatGroup:AddToggle('AutoAttack', {
    Text = '自动攻击',
    Default = false,
    Callback = function(v) cfg.atk = v end
})
CombatGroup:AddToggle('AutoBlock', {
    Text = '自动格挡',
    Default = false,
    Callback = function(v) cfg.blk = v end
})
CombatGroup:AddToggle('AutoParry', {
    Text = '自动招架',
    Default = false,
    Callback = function(v) cfg.pry = v end
})
CombatGroup:AddToggle('AutoDodge', {
    Text = '自动闪避',
    Default = false,
    Callback = function(v) cfg.ddg = v end
})
CombatGroup:AddToggle('AutoUltimate', {
    Text = '自动大招',
    Default = false,
    Callback = function(v) cfg.ult = v end
})
CombatGroup:AddToggle('DashAttack', {
    Text = '冲刺攻击',
    Default = false,
    Callback = function(v) cfg.dashAtk = v end
})
CombatGroup:AddToggle('CriticalStrike', {
    Text = '自动暴击',
    Default = false,
    Callback = function(v) cfg.crit = v end
})
CombatGroup:AddSlider('AttackRange', {
    Text = '攻击距离',
    Min = 5,
    Max = 30,
    Default = 18,
    Callback = function(v) cfg.rng = v end
})

local SettingsGroup = Tabs.Settings:AddLeftGroupbox('配置管理')
SettingsGroup:AddDivider()
SettingsGroup:AddButton('保存配置', function()
    SaveManager:Save()
    Library:Notify('配置已保存', 2)
end)
SettingsGroup:AddButton('加载配置', function()
    SaveManager:Load()
    Library:Notify('配置已加载', 2)
end)
SettingsGroup:AddButton('卸载界面', function()
    Library:Unload()
end)

local InfoGroup = Tabs.Settings:AddRightGroupbox('信息')
InfoGroup:AddLabel('=== TY hub ===')
InfoGroup:AddLabel('版本:  1.0.0')
InfoGroup:AddLabel('作者：权威不是权威')
InfoGroup:AddDivider()
InfoGroup:AddLabel('菜单快捷键: RightShift')

pcall(function() Library.ToggleKeybind = 'RightShift' end)
pcall(function() ThemeManager:SetLibrary(Library) end)
pcall(function() SaveManager:SetLibrary(Library) end)
pcall(function() SaveManager:IgnoreThemeSettings() end)
pcall(function() SaveManager:SetIgnoreIndexes({}) end)
pcall(function() ThemeManager:SetFolder('TYUI_Demo') end)
pcall(function() SaveManager:SetFolder('TYUI_Demo/config') end)
pcall(function() SaveManager:SetSubFolder('DemoVersion') end)
pcall(function() SaveManager:BuildConfigSection(Tabs.Settings) end)
pcall(function() ThemeManager:ApplyToTab(Tabs.Settings) end)
pcall(function() SaveManager:LoadAutoloadConfig() end)

pcall(function() Library:SetWatermarkVisibility(true) end)

local RunService = game:GetService('RunService')
local frameTimer = tick()
local frameCounter = 0
local fps = 60
RunService.RenderStepped:Connect(function()
    frameCounter = frameCounter + 1
    if (tick() - frameTimer) >= 1 then
        fps = frameCounter
        frameTimer = tick()
        frameCounter = 0
    end
    pcall(function() Library:SetWatermark(('TY 示例 | %d fps'):format(math.floor(fps))) end)
end)

if not game:IsLoaded() then game.Loaded:Wait() end

pcall(function() Library:Notify('TY决斗场加载完成', 3) end)

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local Lighting = game:GetService("Lighting")
local UserInputService = game:GetService("UserInputService")
local LP = Players.LocalPlayer
local GM = require(ReplicatedStorage.GameManager)
local TLC = GM:GetController("TargetLockController")
local CC = GM:GetController("CharacterController")
local Rem = ReplicatedStorage.Remotes.PlayerCharacter

local QueueBasicAttackRemote = ReplicatedStorage:WaitForChild("Remotes", 5) and ReplicatedStorage.Remotes:WaitForChild("PlayerCharacter", 5) and ReplicatedStorage.Remotes.PlayerCharacter:WaitForChild("Request", 5) and ReplicatedStorage.Remotes.PlayerCharacter.Request:WaitForChild("QueueBasicAttack", 5)

local ok, BCC = pcall(function()
    return require(ReplicatedStorage.Controllers.CharacterController.BaseCharacterClient)
end)

if ok and BCC then
    BCC._setupWeaponReplication = function(self)
        self.WeaponToHandler = self.WeaponToHandler or {}
        local jan = self._janitor
        local function onWeaponAdded(w)
            if not self or not self.WeaponToHandler then return end
            local name = w.Name
            local existingHandler = self.WeaponToHandler[name]
            if existingHandler then
                existingHandler:Destroy()
                self.WeaponToHandler[name] = nil
            end
            local weaponModule = ReplicatedStorage.WeaponModulesShared:FindFirstChild(name)
            if not weaponModule then return end
            local ok2, mod = pcall(require, weaponModule)
            if not ok2 or not mod then return end
            local handlerInstance = jan:Add(mod.new(self, w))
            local function updateCosmetic()
                if handlerInstance and handlerInstance.SetCosmetic then
                    handlerInstance:SetCosmetic(w:GetAttribute("CurrentCosmetic") or "Default")
                end
            end
            local cosmeticConn = w:GetAttributeChangedSignal("CurrentCosmetic"):Connect(updateCosmetic)
            updateCosmetic()
            local ancestryConn
            ancestryConn = w.AncestryChanged:Connect(function(_, parent)
                if parent then return end
                if cosmeticConn then cosmeticConn:Disconnect() end
                if ancestryConn then ancestryConn:Disconnect() end
                if self.WeaponToHandler and self.WeaponToHandler[name] == handlerInstance then
                    self.WeaponToHandler[name] = nil
                end
                if handlerInstance and handlerInstance.Destroy then
                    handlerInstance:Destroy()
                end
            end)
            self.WeaponToHandler[name] = handlerInstance
        end
        local jan2 = self._janitor
        jan2:Add(task.spawn(function()
            if not self or not self.RigHandler then return end
            if not self.RigHandler.IsRigLoaded then self.RigHandler.RigLoaded:Wait() end
            if not self or not self.OriginalModel then return end
            local mw = self.OriginalModel:WaitForChild("MountedWeapons", 5)
            if mw then
                jan2:Add(mw.ChildAdded:Connect(onWeaponAdded))
                for _, w in ipairs(mw:GetChildren()) do
                    task.spawn(onWeaponAdded, w)
                end
            end
            if self._setupEquippedWeaponReplication then
                self:_setupEquippedWeaponReplication()
            end
        end))
    end
end

local nearbyEnemies = {}
task.spawn(function()
    while true do
        local char = LP.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        if root then
            local myPos = root.Position
            local temp = {}
            for _, o in ipairs(CollectionService:GetTagged("CustomCharacter")) do
                if o ~= char then
                    local orr = o:FindFirstChild("HumanoidRootPart")
                    if orr then
                        local dist = (myPos - orr.Position).Magnitude
                        table.insert(temp, {char = o, root = orr, dist = dist})
                    end
                end
            end
            nearbyEnemies = temp
        else
            nearbyEnemies = {}
        end
        task.wait(0.1)
    end
end)

local function getHandler()
    local h = CC:GetLocalCharacterHandler()
    return (h and h.Root and h.ActionManager and h.WeaponToHandler) and h or nil
end

local function getActionManager()
    local h = getHandler()
    return h and h.ActionManager
end

local hookedAM = nil
local function hookActionManager(am)
    if not am or hookedAM == am then return end
    hookedAM = am
    local orig = am._resolveImpact
    if orig then
        am._resolveImpact = function(self, p2, p3)
            local h = self.CharacterHandler
            if not h or not h.WeaponToHandler or not h.EquippedWeapon then
                return orig(self, p2, p3)
            end
            local wp, wb = h.IsParrying, h.IsBlocking
            if cfg.pry then
                h.IsParrying = true
            elseif cfg.blk then
                h.IsBlocking = true
            end
            local v6, v4, v18, t2 = orig(self, p2, p3)
            h.IsParrying, h.IsBlocking = wp, wb
            return v6, v4, v18, t2
        end
    end
end

local function doBlock(handler, am, hasTarget, targetDistValid)
    if not cfg.blk or not handler or not am then return end
    if not targetDistValid then return end
    if not handler.EquippedWeapon or not hasTarget then
        if handler.IsBlocking or handler.IsParrying then
            local q = handler._blockInputQueue
            if q then
                for i = #q, 1, -1 do
                    if q[i].state == true then q[i].state = 0.133 end
                end
                local ba = am.BlockAction
                if ba then ba._wantsToRelease = true end
            end
        end
        return
    end
    local incoming = false
    if am.UnresolvedImpacts then
        for _ in pairs(am.UnresolvedImpacts) do
            incoming = true
            break
        end
    end
    local act = am.CurrentAction
    local stg = act and (act.ActionType == "Stagger" or act.ActionType == "GetHit")
    local isCloseRange = false
    for _, enemy in ipairs(nearbyEnemies) do
        if enemy.dist < 12 then
            isCloseRange = true
            break
        end
    end
    if incoming or stg or isCloseRange then
        if not handler.IsBlocking and not handler.IsParrying then
            local q = handler._blockInputQueue
            if q and #q < 2 then
                table.insert(q, {state = true})
            end
        end
    else
        if handler.IsBlocking or handler.IsParrying then
            local q = handler._blockInputQueue
            if q then
                for i = #q, 1, -1 do
                    if q[i].state == true then q[i].state = 0.133 end
                end
                local ba = am.BlockAction
                if ba then ba._wantsToRelease = true end
            end
        end
    end
end

local weaponCache = {}
local function getWeaponCaps(wepName)
    if not wepName then return false, false, false end
    if weaponCache[wepName] ~= nil then
        local cache = weaponCache[wepName]
        return cache.hasDashLight, cache.hasDashHeavy, cache.hasLight04
    end
    local hasDashLight, hasDashHeavy, hasLight04 = false, false, false
    local wepPath = ReplicatedStorage.WeaponModulesShared:FindFirstChild(wepName)
    if wepPath then
        local basicAttackTypes = wepPath:FindFirstChild("BasicAttackTypes")
        if basicAttackTypes then
            hasDashLight = basicAttackTypes:FindFirstChild("DashLight") ~= nil
            hasDashHeavy = basicAttackTypes:FindFirstChild("DashHeavy") ~= nil
            hasLight04 = basicAttackTypes:FindFirstChild("Light04") ~= nil
        end
    end
    weaponCache[wepName] = {
        hasDashLight = hasDashLight,
        hasDashHeavy = hasDashHeavy,
        hasLight04 = hasLight04
    }
    return hasDashLight, hasDashHeavy, hasLight04
end

local function doAttack(handler, am, target, targetDist, targetDistValid)
    if not targetDistValid then return end
    if not cfg.atk or not handler or not target or not am then return end
    if handler.OriginalModel:GetAttribute("IsDead") or handler:GetIgnoreInput() then return end
    local equipWep = handler.EquippedWeapon
    local wepName = equipWep and equipWep.Name or nil
    if not equipWep then
        Rem.Request.SetEquippedWeapon:FireServer(true)
        return
    end
    local act = am.CurrentAction
    local canQueue = not act or act.CanQueueActions or act.CanCancel
    local hasDashLight, hasDashHeavy, hasLight04 = getWeaponCaps(wepName)
    if canQueue and not am._queuedActionType and equipWep then
        if cfg.crit then
            local isTargetStaggered = target:GetAttribute("IsStaggered") or target:GetAttribute("PostureBroken")
            if not isTargetStaggered and target:FindFirstChild("Action") then
                local actVal = target.Action:GetAttribute("CurrentAction")
                if actVal == "Stagger" or actVal == "GetHit" then
                    isTargetStaggered = true
                end
            end
            if isTargetStaggered then
                handler._desiredQueuedAction = "CriticalStrike"
                handler._desiredQueuedActionDuration = nil
                return
            end
        end
        if cfg.ult and targetDist <= 10 then
            local energy = handler.OriginalModel:GetAttribute("UltimateEnergy") or 0
            if energy >= 100 then
                handler._desiredQueuedAction = "Ultimate"
                handler._desiredQueuedActionDuration = nil
                return
            end
        end
        local rand = math.random()
        if cfg.dashAtk and hasDashLight and hasDashHeavy and QueueBasicAttackRemote then
            if rand < 0.12 then
                QueueBasicAttackRemote:FireServer("25", wepName, "DashLight")
                return
            elseif rand < 0.24 then
                QueueBasicAttackRemote:FireServer("20", wepName, "DashHeavy")
                return
            end
        end
        if wepName == "Kusarigama" and hasLight04 then
            if rand < 0.70 then
                handler._desiredQueuedAction = "LightAttack"
            else
                handler._desiredQueuedAction = "HeavyAttack"
            end
        elseif wepName == "Gauntlets" then
            if rand < 0.80 then
                handler._desiredQueuedAction = "LightAttack"
            else
                handler._desiredQueuedAction = "HeavyAttack"
            end
        elseif wepName == "Warhammer" or wepName == "Naginata" then
            if rand < 0.50 then
                handler._desiredQueuedAction = "HeavyAttack"
            else
                handler._desiredQueuedAction = "LightAttack"
            end
        else
            if rand < 0.60 then
                handler._desiredQueuedAction = "LightAttack"
            else
                handler._desiredQueuedAction = "HeavyAttack"
            end
        end
        handler._desiredQueuedActionDuration = nil
    end
end

local function doDodge(handler, am, targetDistValid)
    if not cfg.ddg or not handler or not am then return end
    if not targetDistValid then return end
    local act = am.CurrentAction
    if act and act.ActionType == "Stagger" then
        handler._desiredDodge = 0.266
    end
end

RunService.RenderStepped:Connect(function()
    local handler = getHandler()
    local am = getActionManager()
    if not handler or not am then return end
    hookActionManager(am)
    local targetPart = handler.TargetLock or (TLC and TLC.Target)
    local hasTarget = false
    local target = nil
    local targetDist = math.huge
    local targetDistValid = false
    if targetPart and targetPart:IsA("BasePart") then
        target = targetPart.Parent
        local rootSelf = handler.Root
        local rootTar = target and target:FindFirstChild("HumanoidRootPart")
        if target and rootTar and rootSelf then
            hasTarget = true
            targetDist = (rootSelf.Position - rootTar.Position).Magnitude
            targetDistValid = targetDist <= cfg.rng
        end
    end
    if hasTarget and target then
        if targetDistValid then
            doAttack(handler, am, target, targetDist, targetDistValid)
            doDodge(handler, am, targetDistValid)
            local r = handler.Root
            if r and targetPart then
                local dir = (targetPart.Position - r.Position).Unit
                handler.DesiredLookDirection = Vector3.new(dir.X, 0, dir.Z)
                handler.DesiredLookResponsiveness = 100
            end
        else
            handler.DesiredMoveDirection = Vector3.new(0,0,0)
        end
    else
        handler.DesiredMoveDirection = Vector3.new(0,0,0)
    end
    doBlock(handler, am, hasTarget, targetDistValid)
end)

task.spawn(function()
    while true do
        if cfg.autoCollect then
            pcall(function()
                for _, v in ipairs(workspace:GetDescendants()) do
                    if v:IsA("BasePart") and v:GetAttribute("CanCollect") then
                        local char = LP.Character
                        if char and char:FindFirstChild("HumanoidRootPart") then
                            local hrp = char.HumanoidRootPart
                            if (hrp.Position - v.Position).Magnitude < 10 then
                                firetouchinterest(hrp, v, 0)
                                firetouchinterest(hrp, v, 1)
                            end
                        end
                    end
                end
            end)
        end
        if cfg.autoStrength then
            pcall(function()
                local char = LP.Character
                if char and char:FindFirstChild("Humanoid") then
                    local hum = char.Humanoid
                    local animTrack = hum:LoadAnimation(Instance.new("Animation"))
                    if not animTrack.IsPlaying then
                        animTrack:Play()
                        task.wait(1)
                        animTrack:Stop()
                    end
                end
            end)
        end
        if cfg.autoSteal then
            pcall(function()
                for _, v in ipairs(workspace:GetDescendants()) do
                    if v:IsA("Tool") and v.Parent and v.Parent:IsA("Model") and v.Parent:FindFirstChild("Humanoid") and v.Parent ~= LP.Character then
                        local char = LP.Character
                        if char and char:FindFirstChild("HumanoidRootPart") then
                            local hrp = char.HumanoidRootPart
                            if (hrp.Position - v.Position).Magnitude < 8 then
                                firetouchinterest(hrp, v, 0)
                                firetouchinterest(hrp, v, 1)
                            end
                        end
                    end
                end
            end)
        end
        if cfg.autoSpeed then
            pcall(function()
                local stats = LP:FindFirstChild("leaderstats")
                if stats and stats:FindFirstChild("SpeedTokens") then
                    local token = stats.SpeedTokens.Value
                    if token > 0 then
                        local upgrade = workspace:FindFirstChild("SpeedUpgrade")
                        if upgrade then
                            firetouchinterest(LP.Character.HumanoidRootPart, upgrade, 0)
                            firetouchinterest(LP.Character.HumanoidRootPart, upgrade, 1)
                        end
                    end
                end
            end)
        end
        if cfg.autoRebirth then
            pcall(function()
                local stats = LP:FindFirstChild("leaderstats")
                if stats and stats:FindFirstChild("Level") and stats.Level.Value >= 100 then
                    local rebirth = workspace:FindFirstChild("RebirthStone")
                    if rebirth then
                        firetouchinterest(LP.Character.HumanoidRootPart, rebirth, 0)
                        firetouchinterest(LP.Character.HumanoidRootPart, rebirth, 1)
                    end
                end
            end)
        end
        task.wait(0.5)
    end
end)

task.spawn(function()
    local originalJumpPower = nil
    while true do
        local char = LP.Character
        local hum = char and char:FindFirstChild("Humanoid")
        if cfg.infJump and hum then
            if originalJumpPower == nil then
                originalJumpPower = hum.JumpPower
            end
            hum.JumpPower = 50
            local con
            con = hum:GetPropertyChangedSignal("Jump"):Connect(function()
                if hum.Jump then
                    hum:ChangeState(Enum.HumanoidStateType.Jumping)
                end
            end)
            task.wait(0.5)
            if con then con:Disconnect() end
        elseif hum and originalJumpPower then
            hum.JumpPower = originalJumpPower
            originalJumpPower = nil
        end
        task.wait(1)
    end
end)

task.spawn(function()
    while true do
        local char = LP.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if cfg.float and hrp then
            local bodyVel = Instance.new("BodyVelocity")
            bodyVel.Velocity = Vector3.new(0, 5, 0)
            bodyVel.MaxForce = Vector3.new(0, math.huge, 0)
            bodyVel.Parent = hrp
            task.wait(0.1)
            bodyVel:Destroy()
        end
        if cfg.noclip and char then
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        elseif char then
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = true
                end
            end
        end
        task.wait(0.2)
    end
end)

task.spawn(function()
    local originalBrightness = Lighting.Brightness
    local originalClockTime = Lighting.ClockTime
    while true do
        if cfg.fullBright then
            Lighting.Brightness = 2
            Lighting.ClockTime = 12
            Lighting.FogEnd = 100000
            Lighting.GlobalShadows = false
        else
            Lighting.Brightness = originalBrightness
            Lighting.ClockTime = originalClockTime
            Lighting.FogEnd = 100000
            Lighting.GlobalShadows = true
        end
        task.wait(1)
    end
end)

local function createOrbit(target)
    if not cfg.orbit then return end
    local char = LP.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local targetHrp = target:FindFirstChild("HumanoidRootPart")
    if not hrp or not targetHrp then return end
    local bodyPos = Instance.new("BodyPosition")
    bodyPos.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    bodyPos.D = 1000
    bodyPos.P = 5000
    local angle = 0
    local radius = 5
    local connection
    connection = RunService.RenderStepped:Connect(function()
        if not cfg.orbit or not char or not target or not target.Parent then
            bodyPos:Destroy()
            if connection then connection:Disconnect() end
            return
        end
        angle = angle + 0.05
        local offset = Vector3.new(math.cos(angle) * radius, 0, math.sin(angle) * radius)
        bodyPos.Position = targetHrp.Position + offset
        bodyPos.Parent = hrp
    end)
end

task.spawn(function()
    while true do
        if cfg.blind then
            local screenGui = Instance.new("ScreenGui")
            screenGui.Name = "BlindGui"
            local frame = Instance.new("Frame")
            frame.Size = UDim2.new(1,0,1,0)
            frame.BackgroundColor3 = Color3.new(0,0,0)
            frame.BackgroundTransparency = 0.8
            frame.Parent = screenGui
            screenGui.Parent = LP.PlayerGui
            task.wait(0.5)
            screenGui:Destroy()
        end
        task.wait(2)
    end
end)

task.spawn(function()
    while true do
        if cfg.annoy then
            local target = nil
            for _, plr in ipairs(Players:GetPlayers()) do
                if plr ~= LP then
                    target = plr.Character
                    if target then break end
                end
            end
            if target and target:FindFirstChild("HumanoidRootPart") then
                local char = LP.Character
                if char and char:FindFirstChild("HumanoidRootPart") then
                    char.HumanoidRootPart.CFrame = target.HumanoidRootPart.CFrame + Vector3.new(0,0,2)
                end
            end
        end
        task.wait(0.1)
    end
end)

task.spawn(function()
    while true do
        if cfg.flingAll then
            for _, plr in ipairs(Players:GetPlayers()) do
                if plr ~= LP and plr.Character then
                    local hrp = plr.Character:FindFirstChild("HumanoidRootPart")
                    if hrp then
                        local vel = Instance.new("BodyVelocity")
                        vel.Velocity = Vector3.new(0, 200, 0)
                        vel.MaxForce = Vector3.new(0, math.huge, 0)
                        vel.Parent = hrp
                        task.wait(0.1)
                        vel:Destroy()
                    end
                end
            end
            cfg.flingAll = false
        end
        task.wait(0.5)
    end
end)

task.spawn(function()
    while true do
        if cfg.fakeLag then
            task.wait(0.5)
        end
        task.wait()
    end
end)

task.spawn(function()
    while true do
        if cfg.chatSpam then
            local text = "TY 最牛脚本！"
            game:GetService("ReplicatedStorage").DefaultChatSystemChatEvents.SayMessageRequest:FireServer(text, "All")
        end
        task.wait(0.2)
    end
end)

task.spawn(function()
    while true do
        if cfg.clone then
            local char = LP.Character
            if char then
                local clone = char:Clone()
                clone.Parent = workspace
                clone:BreakJoints()
                for _, v in ipairs(clone:GetDescendants()) do
                    if v:IsA("BasePart") then
                        v.CanCollide = false
                    end
                end
                local humanoid = clone:FindFirstChild("Humanoid")
                if humanoid then
                    humanoid.WalkSpeed = 0
                    humanoid.JumpPower = 0
                end
                task.wait(5)
                clone:Destroy()
            end
            cfg.clone = false
        end
        task.wait(0.5)
    end
end)

local speedActive = false
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.Q and cfg.dodgeKey then
        local char = LP.Character
        if char and char:FindFirstChild("Humanoid") then
            local hum = char.Humanoid
            if not speedActive then
                speedActive = true
                hum.WalkSpeed = hum.WalkSpeed * 2
                task.wait(1)
                hum.WalkSpeed = hum.WalkSpeed / 2
                speedActive = false
            end
        end
    end
end)

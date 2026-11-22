
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local lp = Players.LocalPlayer

	-- [FPS]一键点击：独立服务器缝合版
-- 当前服务器功能与独立界面整合版
-- 每个文件仅包含当前服务器的功能与独立关于分区

local NothingLibrary = loadstring(game:HttpGetAsync('https://raw.githubusercontent.com/quanwei-sy/qianweicangku/refs/heads/main/%E6%BA%90%E7%A0%81.lua'))()

local __BaseWindow = NothingLibrary.new({
    Title = "TY hub｜[FPS]一键点击",
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


local bytenetrel = ReplicatedStorage:WaitForChild("ByteNetReliable", 10)
local ok1, wpnpkts = pcall(require, ReplicatedStorage.Common.Packets.WeaponPackets)
local ok2, wpnclnt = pcall(require, lp.PlayerScripts.Start.Game.WeaponClient)
local ok3, wpnmng = pcall(require, ReplicatedStorage.Common.Managers.WeaponManager)
local ok4, vwmdlclnt = pcall(require, lp.PlayerScripts.Start.Game.ViewmodelClient)
local ok5, mngmpkts = pcall(require, ReplicatedStorage.Common.Packets.MainGamePackets)
local ok6, qstpkts = pcall(require, ReplicatedStorage.Common.Packets.QuestPackets)
local ok7, lvlrewpkts = pcall(require, ReplicatedStorage.Common.Packets.LevelRewardPackets)
local ok8, battlepasspkts = pcall(require, ReplicatedStorage.Common.Packets.BattlepassPackets)
local ok9, dataclnt = pcall(require, lp.PlayerScripts.Start.Backend.DataClient)
if not bytenetrel or not ok1 or not ok2 then
    WindUI:Notify({ Title = "错误", Content = "未获取武器接口，请进入对局后重试", Duration = 4 })
    return
end

local S = {
    killOn = false, fireInterval = 0.03, killRange = 0, infFire = false,
    killAura = false, auraRange = 50, hitboxOn = false, hitboxSize = 8,
    aimOn = false, aimSmooth = 0.15, fovVis = false, fovRadius = 150,
    silentOn = false, hitChance = 100, wallbang = false, infDist = false,
    triggerOn = false, autoShoot = false, autoShootDelay = 0.05,
    espOn = false, boxStyle = 2, nameEsp = false, distEsp = false,
    hpEsp = false, skelEsp = false, tracerOn = false, chamsOn = false,
    dangerOn = false,
    noRecoil = false, instReload = false, infAmmo = false, maxXp = false,
    noKnifeCd = false, ffBy = false,
    speedOn = false, speedVal = 50, jumpOn = false, jumpVal = 50,
    noclipOn = false, spinOn = false, spinSpeed = 180, thirdPerson = false,
    antiAfk = false, autoDeploy = false, instRespawn = false,
    autoQuests = false, autoLvl = false, autoBp = false,
    hitNotifs = false, killFeed = false, killFeedText = "你击杀了",
}
local curTarget = nil
local targetCount = 0
local ws_en = false
local jp_en = false

local function getRoot()
    local c = lp.Character
    return c and c:FindFirstChild("HumanoidRootPart")
end
local function getHum()
    local c = lp.Character
    return c and c:FindFirstChildOfClass("Humanoid")
end
local function getTargs()
    local t = {}
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= lp and plr.Character then
            local hum = plr.Character:FindFirstChildOfClass("Humanoid")
            local hrp = plr.Character:FindFirstChild("HumanoidRootPart")
            local head = plr.Character:FindFirstChild("Head")
            if hum and hrp and head and hum.Health > 0 then
                table.insert(t, { char = plr.Character, head = head, hrp = hrp, name = plr.DisplayName or plr.Name })
            end
        end
    end
    for _, obj in ipairs(Workspace:GetChildren()) do
        if obj:IsA("Model") and obj:FindFirstChildOfClass("Humanoid") then
            local hum = obj:FindFirstChildOfClass("Humanoid")
            local hrp = obj:FindFirstChild("HumanoidRootPart")
            local head = obj:FindFirstChild("Head")
            if not Players:GetPlayerFromCharacter(obj) and hum and hrp and head and hum.Health > 0 then
                table.insert(t, { char = obj, head = head, hrp = hrp, name = obj.Name })
            end
        end
    end
    return t
end

local function getTargsByRange()
    local myRoot = getRoot()
    local t = getTargs()
    if S.killRange > 0 and myRoot then
        local out = {}
        for _, tg in ipairs(t) do
            if (tg.hrp.Position - myRoot.Position).Magnitude <= S.killRange then
                table.insert(out, tg)
            end
        end
        return out
    end
    return t
end

local wpnData = {}
local origConstants = {}
if ok3 and wpnmng then
    pcall(function()
        local list = wpnmng.getWeapons()
        for name, data in pairs(list) do
            data._firerate = data.firerate
            data._reloadTime = data.reloadTime
            data._magazine = data.magazine
            wpnData[name] = data
        end
        origConstants.DEFAULT_FIRERATE = wpnmng.Constants.DEFAULT_FIRERATE
        origConstants.DEFAULT_PISTOL_FIRERATE = wpnmng.Constants.DEFAULT_PISTOL_FIRERATE
        origConstants.DEFAULT_RELOAD_TIME = wpnmng.Constants.DEFAULT_RELOAD_TIME
        origConstants.DEFAULT_PISTOL_RELOAD_TIME = wpnmng.Constants.DEFAULT_PISTOL_RELOAD_TIME
        origConstants.DEFAULT_MAGAZINE = wpnmng.Constants.DEFAULT_MAGAZINE
    end)
end

local function applyWpnMods()
    if not ok3 then return end
    for _, data in pairs(wpnData) do
        data.firerate = S.infFire and 9999 or (data._firerate or data.firerate)
        data.reloadTime = S.instReload and 0 or (data._reloadTime or data.reloadTime)
        data.magazine = S.infAmmo and 999 or (data._magazine or data.magazine)
    end
    pcall(function()
        wpnmng.Constants.DEFAULT_FIRERATE = S.infFire and 9999 or (origConstants.DEFAULT_FIRERATE or 2)
        wpnmng.Constants.DEFAULT_PISTOL_FIRERATE = S.infFire and 9999 or (origConstants.DEFAULT_PISTOL_FIRERATE or 4)
        wpnmng.Constants.DEFAULT_RELOAD_TIME = S.instReload and 0 or (origConstants.DEFAULT_RELOAD_TIME or 0.75)
        wpnmng.Constants.DEFAULT_PISTOL_RELOAD_TIME = S.instReload and 0 or (origConstants.DEFAULT_PISTOL_RELOAD_TIME or 0.5)
        wpnmng.Constants.DEFAULT_MAGAZINE = S.infAmmo and 999 or (origConstants.DEFAULT_MAGAZINE or 1)
    end)
end

local oldNamecall
oldNamecall = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
    local method = getnamecallmethod()
    if method == "FireServer" and self == bytenetrel then
        if S.killOn and curTarget then
            local args = {...}
            if typeof(args[2]) == "table" and typeof(args[2][1]) == "Instance" then
                args[2][1] = curTarget.char
                args[2][2] = curTarget.head
            end
        elseif S.silentOn and silentTarg then
            local args = {...}
            if typeof(args[2]) == "table" and typeof(args[2][1]) == "Instance" then
                if math.random(1, 100) <= (S.hitChance or 100) then
                    args[2][1] = silentTarg.char
                    args[2][2] = silentTarg.head
                end
            end
        end
    elseif method == "FindFirstChild" and S.ffBy then
        local args = {...}
        if args[1] == "ForceField" then return nil end
    end
    return oldNamecall(self, ...)
end))

local oldIndex
oldIndex = hookmetamethod(game, "__index", newcclosure(function(self, key)
    if not checkcaller() then
        if key == "WalkSpeed" and ws_en and self:IsA("Humanoid") then return S.speedVal end
        if key == "JumpPower" and jp_en and self:IsA("Humanoid") then return S.jumpVal end
    end
    return oldIndex(self, key)
end))
local oldNewIndex
oldNewIndex = hookmetamethod(game, "__newindex", newcclosure(function(self, key, value)
    if not checkcaller() and key == "AssemblyLinearVelocity" and typeof(value) == "Vector3" then
        if self:IsA("BasePart") and self.Name == "HumanoidRootPart" then
            local char = self:FindFirstAncestorOfClass("Model")
            if char and char == lp.Character then
                if ws_en and value.X == 0 and value.Z == 0 then return end
                if jp_en and value.Y < -40 then return end
            end
        end
    end
    return oldNewIndex(self, key, value)
end))

local origVmShoot
if ok4 and vwmdlclnt and vwmdlclnt.shoot then
    origVmShoot = vwmdlclnt.shoot
end

if ok1 and wpnpkts and wpnpkts.hitResult and wpnpkts.hitResult.listen then
    pcall(function()
        wpnpkts.hitResult.listen(function(data)
            if S.hitNotifs then
                task.spawn(function()
                    pcall(function()
                        local tname = (typeof(data.target) == "Instance" and data.target.Name) or "敌人"
                        local msg = "命中 " .. tname
                        WindUI:Notify({ Title = "命中反馈", Content = msg, Duration = 2 })
                    end)
                end)
            end
        end)
    end)
end

local loopConn = nil
local function startKillLoop()
    if loopConn then loopConn:Disconnect() end
    loopConn = RunService.Heartbeat:Connect(function()
        if not S.killOn then return end
        local targets = getTargsByRange()
        targetCount = #targets
        for _, t in ipairs(targets) do
            if not S.killOn then break end
            curTarget = t
            pcall(function() wpnclnt.fire() end)
            task.wait(S.fireInterval)
        end
    end)
end

local auraConn = nil
local function startAuraLoop()
    if auraConn then auraConn:Disconnect() end
    auraConn = RunService.Heartbeat:Connect(function()
        if not S.killAura then return end
        local myRoot = getRoot()
        if not myRoot then return end
        for _, t in ipairs(getTargs()) do
            if (t.hrp.Position - myRoot.Position).Magnitude <= S.auraRange then
                curTarget = t
                pcall(function() wpnclnt.fire() end)
            end
        end
    end)
end

local hbPoints = { "Head", "UpperTorso", "LowerTorso", "HumanoidRootPart", "LeftUpperArm", "RightUpperArm", "LeftUpperLeg", "RightUpperLeg" }
local hbConn = nil
local function startHbLoop()
    if hbConn then hbConn:Disconnect() end
    hbConn = RunService.Heartbeat:Connect(function()
        if not S.hitboxOn then return end
        for _, t in ipairs(getTargs()) do
            for _, n in ipairs(hbPoints) do
                local p = t.char:FindFirstChild(n)
                if p and p:IsA("BasePart") then
                    pcall(function() p.Size = Vector3.new(S.hitboxSize, S.hitboxSize, S.hitboxSize) end)
                end
            end
        end
    end)
end

local function pickAimTarget()
    local mouse = UserInputService:GetMouseLocation()
    local cam = Workspace.CurrentCamera
    if not cam then return nil end
    local myRoot = getRoot()
    local best, bestScore = nil, math.huge
    for _, t in ipairs(getTargs()) do
        local sp, onScreen = cam:WorldToViewportPoint(t.head.Position)
        if onScreen then
            local sd = (Vector2.new(sp.X, sp.Y) - mouse).Magnitude
            if sd < bestScore then best = t bestScore = sd end
        end
    end
    return best
end

local silentTarg = nil
local espDraws = {}
local function getEsp(char)
    if not espDraws[char] then
        espDraws[char] = {
            box = Drawing.new("Square"), cbox = { Drawing.new("Line"), Drawing.new("Line"), Drawing.new("Line"), Drawing.new("Line") },
            name = Drawing.new("Text"), dist = Drawing.new("Text"),
            hpbg = Drawing.new("Square"), hp = Drawing.new("Square"),
            trac = Drawing.new("Line"), skel = Drawing.new("Line"),
        }
        for i = 1, 4 do
            espDraws[char].cbox[i].Thickness = 1
        end
    end
    return espDraws[char]
end
local fovCircle = Drawing.new("Circle")
fovCircle.Thickness = 1
fovCircle.Radius = S.fovRadius
fovCircle.Color = Color3.fromRGB(100, 100, 255)
fovCircle.Visible = false

RunService.RenderStepped:Connect(function(dt)
    local cam = Workspace.CurrentCamera
    local mp = UserInputService:GetMouseLocation()
    local myRoot = getRoot()

    if S.silentOn then
        silentTarg = pickAimTarget()
    else
        silentTarg = nil
    end

    if S.aimOn then
        local t = pickAimTarget()
        if t and cam then
            cam.CFrame = cam.CFrame:Lerp(CFrame.lookAt(cam.CFrame.Position, t.head.Position), S.aimSmooth)
        end
    end

    if S.fovVis and cam then
        fovCircle.Visible = true
        fovCircle.Position = mp
        fovCircle.Radius = S.fovRadius
    else
        fovCircle.Visible = false
    end

    if S.triggerOn and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
        local t = pickAimTarget()
        if t then
            pcall(function() wpnclnt.fire() end)
        end
    end

    if S.autoShoot then
        local t = pickAimTarget()
        if t then
            pcall(function() wpnclnt.fire() end)
        end
    end

    if S.spinOn and myRoot then
        myRoot.CFrame = myRoot.CFrame * CFrame.Angles(0, math.rad(S.spinSpeed * dt), 0)
    end

    if S.killFeed and lp.Character then
        pcall(function()
            local t = lp.PlayerGui:FindFirstChild("Gameplay") and lp.PlayerGui.Gameplay:FindFirstChild("Kill")
            if t and t.Visible then
                local tn = t:FindFirstChild("Tabs") and t.Tabs:FindFirstChild("TargetName")
                if tn then tn.Text = S.killFeedText end
            end
        end)
    end

    if S.espOn and cam then
        for _, t in ipairs(getTargs()) do
            local d = getEsp(t.char)
            local sp, onScreen = cam:WorldToViewportPoint(t.hrp.Position)
            if onScreen then
                local topSP = cam:WorldToViewportPoint(t.hrp.Position + Vector3.new(0, 2.8, 0))
                local botSP = cam:WorldToViewportPoint(t.hrp.Position - Vector3.new(0, 2.8, 0))
                local h = math.abs(botSP.Y - topSP.Y)
                local w = h * 0.55
                local bx, by = sp.X - w / 2, topSP.Y
                local col = Color3.fromRGB(100, 255, 255)

                if S.boxStyle == 1 then
                    d.box.Visible = true d.box.Color = col d.box.Thickness = 1 d.box.Filled = false
                    d.box.Size = Vector2.new(w, h) d.box.Position = Vector2.new(bx, by)
                    for i = 1, 4 do d.cbox[i].Visible = false end
                elseif S.boxStyle == 2 then
                    d.box.Visible = false
                    local lw = math.max(4, w * 0.25)
                    local o = math.max(2, h * 0.1)
                    local P = {
                        { Vector2.new(bx, by), Vector2.new(bx + lw, by), Vector2.new(bx + lw, by + o), Vector2.new(bx, by + o) },
                        { Vector2.new(bx + w, by), Vector2.new(bx + w - lw, by), Vector2.new(bx + w - lw, by + o), Vector2.new(bx + w, by + o) },
                        { Vector2.new(bx, by + h), Vector2.new(bx + lw, by + h), Vector2.new(bx + lw, by + h - o), Vector2.new(bx, by + h - o) },
                        { Vector2.new(bx + w, by + h), Vector2.new(bx + w - lw, by + h), Vector2.new(bx + w - lw, by + h - o), Vector2.new(bx + w, by + h - o) },
                    }
                    for i = 1, 4 do
                        local ln = d.cbox[i]
                        ln.Visible = true ln.Color = col ln.Thickness = 1
                        ln.From = P[i][1] ln.To = P[i][2]
                    end
                else
                    d.box.Visible = false
                    for i = 1, 4 do d.cbox[i].Visible = false end
                end

                if S.nameEsp then
                    d.name.Visible = true d.name.Text = t.name d.name.Color = Color3.new(1, 1, 1)
                    d.name.Position = Vector2.new(sp.X, by - 16) d.name.Size = 13 d.name.Center = true d.name.Outline = true
                else d.name.Visible = false end

                if S.distEsp and myRoot then
                    d.dist.Visible = true d.dist.Text = math.floor((t.hrp.Position - myRoot.Position).Magnitude) .. "m"
                    d.dist.Color = Color3.fromRGB(180, 180, 180) d.dist.Position = Vector2.new(sp.X, by + h + 4)
                    d.dist.Size = 11 d.dist.Center = true d.dist.Outline = true
                else d.dist.Visible = false end

                if S.hpEsp then
                    d.hpbg.Visible = true d.hp.Visible = true
                    d.hpbg.Color = Color3.new(0, 0, 0) d.hpbg.Size = Vector2.new(3, h) d.hpbg.Position = Vector2.new(bx - 5, by)
                    d.hp.Color = Color3.fromRGB(0, 255, 0) d.hp.Size = Vector2.new(3, h) d.hp.Position = Vector2.new(bx - 5, by)
                else d.hpbg.Visible = false d.hp.Visible = false end

                if S.tracerOn then
                    d.trac.Visible = true d.trac.Color = Color3.fromRGB(100, 100, 255) d.trac.Thickness = 1
                    d.trac.From = Vector2.new(cam.ViewportSize.X / 2, cam.ViewportSize.Y)
                    d.trac.To = Vector2.new(sp.X, sp.Y)
                else d.trac.Visible = false end

                if S.skelEsp then
                    d.skel.Visible = true d.skel.Color = Color3.fromRGB(255, 100, 255) d.skel.Thickness = 1
                    local hd, ut = t.char:FindFirstChild("Head"), t.char:FindFirstChild("UpperTorso")
                    local lt = t.char:FindFirstChild("LowerTorso")
                    if hd and ut and lt then
                        local p1 = cam:WorldToViewportPoint(hd.Position)
                        local p2 = cam:WorldToViewportPoint(ut.Position)
                        local p3 = cam:WorldToViewportPoint(lt.Position)
                        d.skel.From = Vector2.new(p1.X, p1.Y) d.skel.To = Vector2.new(p2.X, p2.Y)
                    end
                else d.skel.Visible = false end
            else
                local d = espDraws[t.char]
                if d then
                    d.box.Visible = false
                    for i = 1, 4 do d.cbox[i].Visible = false end
                    d.name.Visible = false d.dist.Visible = false d.hpbg.Visible = false d.hp.Visible = false
                    d.trac.Visible = false d.skel.Visible = false
                end
            end
        end
    else
        for char, d in pairs(espDraws) do
            d.box.Visible = false
            for i = 1, 4 do d.cbox[i].Visible = false end
            d.name.Visible = false d.dist.Visible = false d.hpbg.Visible = false d.hp.Visible = false
            d.trac.Visible = false d.skel.Visible = false
        end
    end
end)

RunService.Heartbeat:Connect(function()
    local hum = getHum()
    if hum then
        if S.speedOn and hum.WalkSpeed ~= S.speedVal then
            ws_en = true
            hum.WalkSpeed = S.speedVal
        elseif not S.speedOn and ws_en then
            ws_en = false
            hum.WalkSpeed = 16
        end
        if S.jumpOn and hum.JumpPower ~= S.jumpVal then
            jp_en = true
            hum.JumpPower = S.jumpVal
        elseif not S.jumpOn and jp_en then
            jp_en = false
            hum.JumpPower = 50
        end
    end
end)
RunService.Stepped:Connect(function()
    if S.noclipOn then
        local c = lp.Character
        if c then
            for _, p in ipairs(c:GetDescendants()) do
                if p:IsA("BasePart") and p.CanCollide then p.CanCollide = false end
            end
        end
    end
    if S.infFire then
        pcall(function() wpnclnt.resetBullets(true) end)
    end
end)

local tpConn = nil
local function setThirdPerson(on)
    if on then
        lp.CameraMode = Enum.CameraMode.Classic
        lp.CameraMaxZoomDistance = 128
        if ok2 and wpnclnt and wpnclnt.scope then wpnclnt.scope = function() end end
        if not tpConn then
            tpConn = lp:GetPropertyChangedSignal("CameraMode"):Connect(function()
                if lp.CameraMode ~= Enum.CameraMode.Classic then lp.CameraMode = Enum.CameraMode.Classic end
            end)
        end
    else
        if tpConn then tpConn:Disconnect() tpConn = nil end
        if ok2 and wpnclnt and wpnclnt.scope and origScope then wpnclnt.scope = origScope end
    end
end
local origScope = ok2 and wpnclnt and wpnclnt.scope

task.spawn(function()
    while true do
        task.wait(0.5)
        if S.antiAfk then
            pcall(function()
                local vim = game:GetService("VirtualInputManager")
                vim:SendKeyEvent(true, Enum.KeyCode.W, false, game)
                vim:SendKeyEvent(false, Enum.KeyCode.W, false, game)
            end)
        end
        if S.autoDeploy and ok5 and mngmpkts and mngmpkts.deploy then
            pcall(function() mngmpkts.deploy.send() end)
        end
        if S.instRespawn and ok5 and mngmpkts and mngmpkts.respawn then
            pcall(function()
                local gi = lp.PlayerGui:FindFirstChild("Game Interface")
                if gi and gi:FindFirstChild("Deathscreen") and gi.Deathscreen.Visible then
                    mngmpkts.respawn.send(true)
                end
            end)
        end
        if S.autoQuests then
            if ok6 and qstpkts then
                for i = 1, 3 do pcall(function() qstpkts.claimDailyQuest.send(i) end) end
                for i = 1, 3 do pcall(function() qstpkts.claimHourlyQuest.send(i) end) end
            end
        end
        if S.autoBp and ok8 and battlepasspkts then
            for i = 1, 30 do
                pcall(function() battlepasspkts.claimItem.send({ tierIndex = i, isPremiumTier = false }) end)
                pcall(function() battlepasspkts.claimItem.send({ tierIndex = i, isPremiumTier = true }) end)
            end
        end
        if S.autoLvl and ok7 and lvlrewpkts and ok9 and dataclnt then
            pcall(function()
                local level = dataclnt.getData().Data.level or 1
                for i = 1, level do
                    pcall(function() lvlrewpkts.claimLevelReward.send(i) end)
                end
                S.autoLvl = false
            end)
        end
    end
end)

local Window = WindUI:CreateWindow({
Title = "[FPS]一键点击",
Author = "权威不是权威",
})

if Window then
    pcall(function() Window.IsPC = false end)
end

local StatusTag = Window:Tag({ Title = "待开启 | 0 目标", Color = Color3.fromRGB(255, 255, 255) })
Window:Tag({ Title = "[FPS]一键点击", Color = Color3.fromHex("#FF6B6B") })

local killTab = Window:Tab({ Title = "击杀", Icon = "settings" })
local killSec = killTab:Section({ Title = "击杀控制", TextXAlignment = "Left", TextSize = 17 })

killSec:Toggle({
    Title = "全图击杀",
    Default = false,
    Callback = function(state)
        S.killOn = state
        if state then
            curTarget = nil
            startKillLoop()
            StatusTag:SetTitle("运行中 | " .. targetCount .. " 目标")
            WindUI:Notify({ Title = "已启动", Content = "全图击杀开始", Duration = 3 })
        else
            curTarget = nil
            if loopConn then loopConn:Disconnect() loopConn = nil end
            StatusTag:SetTitle("已停止")
            WindUI:Notify({ Title = "已停止", Content = "全图击杀已停止", Duration = 3 })
        end
    end
})
killSec:Toggle({
    Title = "无限射速",
    Default = false,
    Callback = function(state)
        S.infFire = state
        applyWpnMods()
        WindUI:Notify({ Title = state and "已开启" or "已关闭", Content = "无限射速（解除射速上限）", Duration = 3 })
    end
})
killSec:Slider({
    Title = "开火间隔(秒)",
    Value = { Min = 0.005, Max = 0.2, Default = 0.03 },
    Increment = 0.005,
    Callback = function(v) S.fireInterval = v end
})
killSec:Slider({
    Title = "击杀范围",
    Value = { Min = 0, Max = 500, Default = 0 },
    Increment = 10,
    Callback = function(v) S.killRange = v end
})
killSec:Toggle({
    Title = "击杀光环",
    Default = false,
    Callback = function(state)
        S.killAura = state
        if state then startAuraLoop() else if auraConn then auraConn:Disconnect() auraConn = nil end end
    end
})
killSec:Slider({
    Title = "光环范围",
    Value = { Min = 10, Max = 200, Default = 50 },
    Increment = 10,
    Callback = function(v) S.auraRange = v end
})
killSec:Toggle({
    Title = "命中框扩大",
    Default = false,
    Callback = function(state)
        S.hitboxOn = state
        if state then startHbLoop() else if hbConn then hbConn:Disconnect() hbConn = nil end end
    end
})
killSec:Slider({
    Title = "命中框大小",
    Value = { Min = 1, Max = 30, Default = 8 },
    Increment = 1,
    Callback = function(v) S.hitboxSize = v end
})
killSec:Button({
    Title = "刷新目标统计",
    Callback = function()
        targetCount = #getTargsByRange()
        StatusTag:SetTitle((S.killOn and "运行中" or "待开启") .. " | " .. targetCount .. " 目标")
    end
})

local aimTab = Window:Tab({ Title = "瞄准", Icon = "crosshair" })
local aimSec = aimTab:Section({ Title = "瞄准控制", TextXAlignment = "Left", TextSize = 17 })

aimSec:Toggle({
    Title = "自动瞄准",
    Default = false,
    Callback = function(state) S.aimOn = state end
})
aimSec:Slider({
    Title = "瞄准平滑度",
    Value = { Min = 0.01, Max = 1, Default = 0.15 },
    Increment = 0.01,
    Callback = function(v) S.aimSmooth = v end
})
aimSec:Toggle({
    Title = "显示FOV圈",
    Default = false,
    Callback = function(state) S.fovVis = state end
})
aimSec:Slider({
    Title = "FOV半径",
    Value = { Min = 20, Max = 600, Default = 150 },
    Increment = 10,
    Callback = function(v) S.fovRadius = v end
})
aimSec:Toggle({
    Title = "静默瞄准",
    Default = false,
    Callback = function(state) S.silentOn = state end
})
aimSec:Slider({
    Title = "命中率(%)",
    Value = { Min = 1, Max = 100, Default = 100 },
    Increment = 1,
    Callback = function(v) S.hitChance = v end
})
aimSec:Toggle({
    Title = "无限距离",
    Default = false,
    Callback = function(state) S.infDist = state end
})
aimSec:Toggle({
    Title = "触发扳机",
    Default = false,
    Callback = function(state) S.triggerOn = state end
})
aimSec:Toggle({
    Title = "自动开火",
    Default = false,
    Callback = function(state) S.autoShoot = state end
})
aimSec:Slider({
    Title = "自动开火间隔",
    Value = { Min = 0.01, Max = 0.5, Default = 0.05 },
    Increment = 0.01,
    Callback = function(v) S.autoShootDelay = v end
})

local espTab = Window:Tab({ Title = "透视", Icon = "eye" })
local espSec = espTab:Section({ Title = "透视控制", TextXAlignment = "Left", TextSize = 17 })

espSec:Toggle({
    Title = "透视开关",
    Default = false,
    Callback = function(state) S.espOn = state end
})
espSec:Slider({
    Title = "方框样式 (0无 1全框 2角框)",
    Value = { Min = 0, Max = 2, Default = 2 },
    Increment = 1,
    Callback = function(v) S.boxStyle = v end
})
espSec:Toggle({
    Title = "显示名字",
    Default = false,
    Callback = function(state) S.nameEsp = state end
})
espSec:Toggle({
    Title = "显示距离",
    Default = false,
    Callback = function(state) S.distEsp = state end
})
espSec:Toggle({
    Title = "显示血条",
    Default = false,
    Callback = function(state) S.hpEsp = state end
})
espSec:Toggle({
    Title = "显示骨架",
    Default = false,
    Callback = function(state) S.skelEsp = state end
})
espSec:Toggle({
    Title = "射线透视",
    Default = false,
    Callback = function(state) S.tracerOn = state end
})
espSec:Toggle({
    Title = "发光透视",
    Default = false,
    Callback = function(state) S.chamsOn = state end
})
espSec:Toggle({
    Title = "危险指示器",
    Default = false,
    Callback = function(state) S.dangerOn = state end
})

local wpnTab = Window:Tab({ Title = "武器", Icon = "sword" })
local wpnSec = wpnTab:Section({ Title = "武器修改", TextXAlignment = "Left", TextSize = 17 })

wpnSec:Toggle({
    Title = "无后坐力",
    Default = false,
    Callback = function(state)
        S.noRecoil = state
        if ok4 and vwmdlclnt then
            if state then vwmdlclnt.shoot = function() end
            else vwmdlclnt.shoot = origVmShoot end
        end
    end
})
wpnSec:Toggle({
    Title = "秒换弹",
    Default = false,
    Callback = function(state)
        S.instReload = state
        applyWpnMods()
    end
})
wpnSec:Toggle({
    Title = "无限弹药",
    Default = false,
    Callback = function(state)
        S.infAmmo = state
        applyWpnMods()
    end
})
wpnSec:Toggle({
    Title = "最大经验",
    Default = false,
    Callback = function(state)
        S.maxXp = state
        if ok1 and wpnpkts and wpnpkts.useWeapon and wpnpkts.useWeapon.send then
            if state then
                local origS = wpnpkts.useWeapon.send
                wpnpkts.useWeapon.send = function(data)
                    data = data or {}
                    data.was360 = true data.quickscope = true data.scoped = true
                    return origS(data)
                end
            end
        end
    end
})
wpnSec:Toggle({
    Title = "刀无冷却",
    Default = false,
    Callback = function(state) S.noKnifeCd = state end
})
wpnSec:Toggle({
    Title = "力场绕过",
    Default = false,
    Callback = function(state) S.ffBy = state end
})

local movTab = Window:Tab({ Title = "移动", Icon = "person" })
local movSec = movTab:Section({ Title = "移动控制", TextXAlignment = "Left", TextSize = 17 })

movSec:Toggle({
    Title = "加速",
    Default = false,
    Callback = function(state) S.speedOn = state end
})
movSec:Slider({
    Title = "移速",
    Value = { Min = 16, Max = 500, Default = 50 },
    Increment = 1,
    Callback = function(v) S.speedVal = v end
})
movSec:Toggle({
    Title = "高跳",
    Default = false,
    Callback = function(state) S.jumpOn = state end
})
movSec:Slider({
    Title = "跳跃高度",
    Value = { Min = 50, Max = 500, Default = 50 },
    Increment = 1,
    Callback = function(v) S.jumpVal = v end
})
movSec:Toggle({
    Title = "穿墙",
    Default = false,
    Callback = function(state) S.noclipOn = state end
})
movSec:Toggle({
    Title = "旋转",
    Default = false,
    Callback = function(state) S.spinOn = state end
})
movSec:Slider({
    Title = "旋转速度",
    Value = { Min = 10, Max = 1000, Default = 180 },
    Increment = 10,
    Callback = function(v) S.spinSpeed = v end
})
movSec:Toggle({
    Title = "第三人称",
    Default = false,
    Callback = function(state)
        S.thirdPerson = state
        setThirdPerson(state)
    end
})

local funTab = Window:Tab({ Title = "功能", Icon = "wrench" })
local funSec = funTab:Section({ Title = "实用功能", TextXAlignment = "Left", TextSize = 17 })

funSec:Toggle({ Title = "反挂机", Default = false, Callback = function(s) S.antiAfk = s end })
funSec:Toggle({ Title = "自动部署", Default = false, Callback = function(s) S.autoDeploy = s end })
funSec:Toggle({ Title = "立即重生", Default = false, Callback = function(s) S.instRespawn = s end })
funSec:Toggle({ Title = "自动领任务", Default = false, Callback = function(s) S.autoQuests = s end })
funSec:Toggle({ Title = "自动领等级奖励", Default = false, Callback = function(s) S.autoLvl = s end })
funSec:Toggle({ Title = "自动领通行证", Default = false, Callback = function(s) S.autoBp = s end })
funSec:Toggle({ Title = "命中通知", Default = false, Callback = function(s) S.hitNotifs = s end })
funSec:Toggle({
    Title = "击杀播报改写",
    Default = false,
    Callback = function(s) S.killFeed = s end
})
funSec:Button({
    Title = "复制房号",
    Callback = function()
        pcall(function() setclipboard(game.JobId) end)
        WindUI:Notify({ Title = "已复制", Content = tostring(game.JobId), Duration = 3 })
    end
})
funSec:Button({
    Title = "换服",
    Callback = function()
        pcall(function()
            game:GetService("TeleportService"):Teleport(game.PlaceId, lp)
        end)
    end
})

RunService.Heartbeat:Connect(function()
    if S.killOn then
        StatusTag:SetTitle("运行中 | " .. targetCount .. " 目标")
    end
end)

applyWpnMods()


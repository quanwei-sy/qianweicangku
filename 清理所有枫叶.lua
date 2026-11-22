
	-- 清理所有枫叶：独立服务器缝合版
-- 当前服务器功能与独立界面整合版
-- 每个文件仅包含当前服务器的功能与独立关于分区

local NothingLibrary = loadstring(game:HttpGetAsync('https://raw.githubusercontent.com/quanwei-sy/qianweicangku/refs/heads/main/%E6%BA%90%E7%A0%81.lua'))()

local __BaseWindow = NothingLibrary.new({
    Title = "TY hub｜清理所有枫叶",
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


local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer

local Refs = {
    LeafSim = nil,
    LeafFolder = nil,
    CollectMany = nil,
    EmptyBackpack = nil,
    Dumpsters = nil,
    UserIntent = false,
    AutoSell = false,
    AutoFarm = false,
    AntiOutOfBounds = false,
    AccelEnabled = true,
    AccelIntervalSpeed = 0.001,
    AccelDuration = 1,
    AccelRestTime = 0.09,
    AccelCycleStart = tick(),
    PausedByBag = false,
    ScanRadius = 20,
    MaxBatch = 100,
    CollectInterval = 0.02,
    SellDelay = 0.2,
    SellTpCooldown = 0.15,
    TpStayDuration = 4,
    LastTpTime = 0,
    LastSafeCFrame = nil,
    MaxTpDistance = 200,
    WalkEnabled = false,
    WalkValue = 24,
    FlyEnabled = false,
    FlySpeed = 60,
    NoClip = false,
    UiBody = nil,
    UiScreen = nil,
    StatusPara = nil,
    OriginCFrame = nil,
    IsTeleporting = false,
}

local leafQueryParams = OverlapParams.new()
leafQueryParams.FilterType = Enum.RaycastFilterType.Include
leafQueryParams.MaxParts = 200

local function Notify(tt, tx)
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", {Title = tt, Text = tx, Duration = 5})
    end)
end

local Window = WindUI:CreateWindow({
Title = "清理所有枫叶",
Author = "权威不是权威",
})

Window:EditOpenButton({
    Title = "清理所有枫叶",
    Icon = "leaf",
    CornerRadius = UDim.new(0, 16),
    StrokeThickness = 2,
    Color = ColorSequence.new(Color3.fromHex("FF6B6B")),
    Draggable = true,
})

local TimeTag = Window:Tag({
    Title = "00:00",
    Color = Color3.fromRGB(255, 255, 255),
})

task.spawn(function()
    local hue = 0
    while true do
        local now = os.date("*t")
        hue = (hue + 0.01) % 1
        TimeTag:SetTitle(string.format("%02d:%02d", now.hour, now.min))
        TimeTag:SetColor(Color3.fromHSV(hue, 1, 1))
        task.wait(1)
    end
end)

Window:Tag({
    Title = "清理所有枫叶🍁",
    Color = Color3.fromHex("#7FDBFF"),
})

local Tab = Window:Tab({
    Title = "主功能",
    Icon = "leaf",
})

Tab:Section({ Title = "状态", TextXAlignment = "Left", TextSize = 17 })
local StatusPara = Tab:Paragraph({
    Title = "运行状态",
    Desc = "状态：加载中...",
})
Refs.StatusPara = StatusPara

local function getRoot()
    local char = LocalPlayer.Character
    if not char then return nil end
    return char:FindFirstChild("HumanoidRootPart")
end

local function findNearestUnlockedLeaf(pos, radius)
    if not Refs.LeafSim or not Refs.LeafFolder then return nil end
    leafQueryParams.FilterDescendantsInstances = { Refs.LeafFolder }
    local parts = workspace:GetPartBoundsInRadius(pos, radius, leafQueryParams)
    local canUseLeaf = Refs.LeafSim.canUseLeaf
    local nearest, minDist = nil, math.huge
    for _, part in ipairs(parts) do
        if part.Parent == Refs.LeafFolder and part:IsA("BasePart") then
            local d = (part.Position - pos).Magnitude
            if d < minDist then
                local ok, usable = pcall(canUseLeaf, part)
                if ok and usable then
                    minDist = d
                    nearest = part
                end
            end
        end
    end
    return nearest
end

local function isPositionSafe(pos)
    return findNearestUnlockedLeaf(pos, 30) ~= nil
end

local function countUnlockedLeavesNear(pos, radius)
    if not Refs.LeafSim or not Refs.LeafFolder then return 0 end
    leafQueryParams.FilterDescendantsInstances = { Refs.LeafFolder }
    local parts = workspace:GetPartBoundsInRadius(pos, radius, leafQueryParams)
    local count = 0
    local canUseLeaf = Refs.LeafSim.canUseLeaf
    for _, part in ipairs(parts) do
        if part.Parent == Refs.LeafFolder then
            local ok, usable = pcall(canUseLeaf, part)
            if ok and usable then
                count = count + 1
            end
        end
    end
    return count
end

local function isDumpsterUnlocked(dumpster)
    local LeafSim = Refs.LeafSim
    if not LeafSim then return false end
    if not LeafSim.ranked or not LeafSim.ranked.canUse then return false end
    local ok, result = pcall(function() return LeafSim.ranked.canUse(LocalPlayer, dumpster) end)
    if ok then return result end
    return false
end

local function getDumpsterPos(dumpster)
    local leaves = dumpster:FindFirstChild("Leaves")
    if leaves and leaves:IsA("BasePart") then
        return leaves.Position
    end
    local ok, bb = pcall(function() return dumpster:GetBoundingBox() end)
    if ok then return bb.Position end
    return nil
end

local function strictIsDumpsterUnlocked(dumpster)
    if not isDumpsterUnlocked(dumpster) then return false end
    local pos = getDumpsterPos(dumpster)
    if not pos then return false end
    return findNearestUnlockedLeaf(pos, 30) ~= nil
end

local function safeTeleport(targetPos)
    local hrp = getRoot()
    if not hrp then return false end
    local originalCFrame = hrp.CFrame
    local targetCFrame = CFrame.new(targetPos + Vector3.new(0, 3, 0))
    pcall(function() hrp.CFrame = targetCFrame end)
    task.wait(0.15)
    local hrp2 = getRoot()
    if not hrp2 then return false end
    local actualPos = hrp2.Position
    local deviation = (actualPos - targetPos).Magnitude
    if deviation > 6 then
        pcall(function() hrp2.CFrame = originalCFrame end)
        task.wait(0.05)
        return false
    end
    return true
end

local function getDumpsterValue(dumpster)
    local attrNames = {"Price", "Value", "Multiplier", "Tier", "Level", "SellPrice", "CashPerLeaf", "Rate", "Bonus", "SellMult", "SellMultiplier", "Payout", "PayRate", "CashMult"}
    local best = 0
    for _, name in ipairs(attrNames) do
        local ok, val = pcall(function() return dumpster:GetAttribute(name) end)
        if ok and type(val) == "number" and val > best then
            best = val
        end
    end
    local ok2, descendants = pcall(function() return dumpster:GetDescendants() end)
    if ok2 and descendants then
        for _, child in ipairs(descendants) do
            if child:IsA("NumberValue") or child:IsA("IntValue") then
                local lower = child.Name:lower()
                if lower:find("price") or lower:find("value") or lower:find("mult") or lower:find("tier") or lower:find("level") or lower:find("rate") or lower:find("payout") then
                    if child.Value > best then
                        best = child.Value
                    end
                end
            end
        end
    end
    return best
end

local function getBestDumpsterPos()
    if not Refs.Dumpsters then return nil end
    local hrp = getRoot()
    if not hrp then return nil end
    local origin = hrp.Position
    local bestPos, bestValue, bestDist = nil, -1, math.huge
    for _, obj in ipairs(Refs.Dumpsters:GetChildren()) do
        if obj:IsA("Model") and strictIsDumpsterUnlocked(obj) then
            local pos = getDumpsterPos(obj)
            if pos and countUnlockedLeavesNear(pos, 30) >= 3 then
                local value = getDumpsterValue(obj)
                local dist = (pos - origin).Magnitude
                if value > bestValue or (value == bestValue and dist < bestDist) then
                    bestValue = value
                    bestDist = dist
                    bestPos = pos
                end
            end
        end
    end
    if not bestPos then
        for _, obj in ipairs(Refs.Dumpsters:GetChildren()) do
            if obj:IsA("Model") and strictIsDumpsterUnlocked(obj) then
                local pos = getDumpsterPos(obj)
                if pos and countUnlockedLeavesNear(pos, 40) >= 1 then
                    local dist = (pos - origin).Magnitude
                    if dist < bestDist then
                        bestDist = dist
                        bestPos = pos
                    end
                end
            end
        end
    end
    return bestPos
end

local FixedDumpsterPath = { "Map", "Dumpsters", "Dumpster" }

local function resolveFixedDumpster()
    local node = workspace:FindFirstChild(FixedDumpsterPath[1])
    if not node then return nil end
    node = node:FindFirstChild(FixedDumpsterPath[2])
    if not node then return nil end
    local target = node:FindFirstChild(FixedDumpsterPath[3])
    if target and target:IsA("Model") then return target end
    for _, obj in ipairs(node:GetChildren()) do
        if obj:IsA("Model") and obj.Name:lower():find("dumpster", 1, true) then return obj end
    end
    return nil
end

local function getFixedDumpsterPos()
    local target = resolveFixedDumpster()
    if not target then
        return nil
    end
    local pos = getDumpsterPos(target)
    if not pos then
        return nil
    end
    return pos
end

local function canTpNow()
    return tick() - (Refs.LastTpTime or 0) >= Refs.TpStayDuration
end

local function getSafeLeafPos()
    if not canTpNow() then return nil end
    if not Refs.LeafFolder or not Refs.LeafSim then return nil end
    local hrp = getRoot()
    if not hrp then return nil end
    local origin = hrp.Position
    local canUseLeaf = Refs.LeafSim.canUseLeaf
    local candidates = {}
    for _, leaf in ipairs(Refs.LeafFolder:GetChildren()) do
        if leaf:IsA("BasePart") then
            local pos = leaf.Position
            local d = (pos - origin).Magnitude
            if d <= Refs.MaxTpDistance and d >= 5 then
                local ok, usable = pcall(canUseLeaf, leaf)
                if ok and usable then
                    table.insert(candidates, {pos = pos, dist = d})
                end
            end
        end
    end
    table.sort(candidates, function(a, b) return a.dist < b.dist end)
    for _, c in ipairs(candidates) do
        if countUnlockedLeavesNear(c.pos, 6) >= 2 then
            return c.pos
        end
    end
    return nil
end

local function GetCurrentInterval()
    if not Refs.AccelEnabled then
        return Refs.CollectInterval
    end
    local cycle = Refs.AccelDuration + Refs.AccelRestTime
    if cycle <= 0 then return Refs.CollectInterval end
    local pos = (tick() - Refs.AccelCycleStart) % cycle
    if pos < Refs.AccelDuration then
        return Refs.AccelIntervalSpeed
    end
    return Refs.CollectInterval
end

local function RefreshStatus()
    local function setStatus(txt, col)
        Refs.StatusText = txt
        local para = Refs.StatusPara
        if para and para.SetDesc then
            pcall(function() para:SetDesc(txt) end)
        end
    end
    if not Refs.LeafSim then
        setStatus("状态：模块加载失败，请重新执行", Color3.fromRGB(255, 100, 100))
        return
    end
    local leaves = LocalPlayer:GetAttribute("Leaves") or 0
    local capacity = LocalPlayer:GetAttribute("LeafCapacity") or 25
    if Refs.UserIntent then
        if Refs.PausedByBag then
            if Refs.AutoSell then
                setStatus("状态：自动出售中...", Color3.fromRGB(255, 200, 100))
            else
                setStatus("状态：背包已满，请出售", Color3.fromRGB(255, 100, 100))
            end
        else
            local accelTag = ""
            if Refs.AccelEnabled then
                local cycle = Refs.AccelDuration + Refs.AccelRestTime
                if cycle > 0 then
                    local pos = (tick() - Refs.AccelCycleStart) % cycle
                    if pos < Refs.AccelDuration then
                        accelTag = " [加速中]"
                    end
                end
            end
            setStatus("状态：自动收集中 (" .. leaves .. "/" .. capacity .. ")" .. accelTag, Color3.fromRGB(100, 255, 100))
        end
    else
        setStatus("状态：准备就绪 (" .. leaves .. "/" .. capacity .. ")", Color3.fromRGB(200, 200, 200))
    end
end

local function OnLeavesChanged()
    local leaves = LocalPlayer:GetAttribute("Leaves") or 0
    local capacity = LocalPlayer:GetAttribute("LeafCapacity") or 25
    if leaves >= capacity then
        if Refs.UserIntent and not Refs.PausedByBag then
            Refs.PausedByBag = true
            if not Refs.AutoSell then
                Notify("自动捡树叶", "背包已满，自动暂停。请出售。")
            end
        end
    else
        if Refs.PausedByBag then
            Refs.PausedByBag = false
        end
    end
    RefreshStatus()
end
LocalPlayer:GetAttributeChangedSignal("Leaves"):Connect(OnLeavesChanged)

Tab:Section({ Title = "拾取设置" })

Tab:Toggle({
    Title = "自动拾取",
    Default = false,
    Callback = function(state)
        if not Refs.LeafSim then
            Notify("自动捡树叶", "模块未加载")
            return
        end
        Refs.UserIntent = state == true
        if Refs.UserIntent then
            local hrp = getRoot()
            if hrp then Refs.OriginCFrame = hrp.CFrame end
        else
            Refs.PausedByBag = false
        end
        RefreshStatus()
    end,
})

Tab:Toggle({
    Title = "自动出售",
    Default = false,
    Callback = function(state) Refs.AutoSell = state == true end,
})

Tab:Toggle({
    Title = "自动寻叶",
    Default = false,
    Callback = function(state) Refs.AutoFarm = state == true end,
})

Tab:Toggle({
    Title = "只在解锁区域拾取",
    Default = false,
    Callback = function(state) Refs.AntiOutOfBounds = state == true end,
})

Tab:Button({
    Title = "一键出售（需靠近垃圾桶）",
    Callback = function()
        if not Refs.EmptyBackpack then
            Notify("自动捡树叶", "未找到出售事件")
            return
        end
        local leaves = LocalPlayer:GetAttribute("Leaves") or 0
        if leaves <= 0 then
            Notify("自动捡树叶", "背包已经是空的了")
            return
        end
        pcall(function() Refs.EmptyBackpack:FireServer() end)
    end,
})

local function SetNoClip(on)
    local char = LocalPlayer.Character
    if not char then return end
    for _, d in ipairs(char:GetDescendants()) do
        if d:IsA("BasePart") then
            pcall(function() d.CanCollide = not on end)
        end
    end
end

local Tab2 = Window:Tab({
    Title = "人物修改",
    Icon = "user",
})

Tab2:Section({ Title = "移动", TextXAlignment = "Left", TextSize = 17 })

Tab2:Toggle({
    Title = "移速修改",
    Default = false,
    Callback = function(state)
        Refs.WalkEnabled = state == true
        local char = LocalPlayer.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.WalkSpeed = Refs.WalkEnabled and Refs.WalkValue or 16
        end
    end,
})

Tab2:Slider({
    Title = "移速数值",
    Value = { Min = 16, Max = 300, Default = 24 },
    Increment = 1,
    Callback = function(val)
        if type(val) == "number" and val > 0 then
            Refs.WalkValue = val
            if Refs.WalkEnabled then
                local char = LocalPlayer.Character
                local hum = char and char:FindFirstChildOfClass("Humanoid")
                if hum then hum.WalkSpeed = val end
            end
        end
    end,
})

Tab2:Toggle({
    Title = "飞行",
    Default = false,
    Callback = function(state)
        Refs.FlyEnabled = state == true
        local hrp = getRoot()
        if hrp and not Refs.FlyEnabled then
            pcall(function() hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0) end)
        end
    end,
})

Tab2:Input({
    Title = "飞行速度",
    Placeholder = "60",
    Callback = function(text)
        local v = tonumber(text)
        if v and v > 0 then Refs.FlySpeed = v end
    end,
})

Tab2:Toggle({
    Title = "穿墙",
    Default = false,
    Callback = function(state)
        Refs.NoClip = state == true
        SetNoClip(Refs.NoClip)
    end,
})

local UISMove = game:GetService("UserInputService")
local RSChar = game:GetService("RunService")

RSChar.Heartbeat:Connect(function()
    local char = LocalPlayer.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if Refs.WalkEnabled and hum and hum.WalkSpeed ~= Refs.WalkValue then
        hum.WalkSpeed = Refs.WalkValue
    end
    if Refs.NoClip then
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if hrp then
            local v = hrp.AssemblyLinearVelocity
            if v.Y < 0 then
                pcall(function() hrp.AssemblyLinearVelocity = Vector3.new(v.X, 0, v.Z) end)
            end
        end
    end
end)

RSChar.RenderStepped:Connect(function()
    if not Refs.FlyEnabled then return end
    local hrp = getRoot()
    if not hrp then return end
    local move = UISMove:GetMoveVector()
    local cam = workspace.CurrentCamera
    if not cam then return end
    local dir = cam.CFrame.LookVector * (-move.Z) + cam.CFrame.RightVector * move.X
    if dir.Magnitude > 0 then dir = dir.Unit end
    pcall(function() hrp.AssemblyLinearVelocity = dir * Refs.FlySpeed end)
end)

LocalPlayer.CharacterAdded:Connect(function(char)
    task.wait(0.6)
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum and Refs.WalkEnabled then hum.WalkSpeed = Refs.WalkValue end
    if Refs.NoClip then SetNoClip(true) end
end)

task.spawn(function()
    local ps = LocalPlayer:FindFirstChild("PlayerScripts")
    if ps then
        local ok, res = pcall(function()
            return require(ps:WaitForChild("LeafSim", 10))
        end)
        if ok and res then
            Refs.LeafSim = res
            Refs.LeafFolder = res.folder
            Refs.CollectMany = res.collectMany
        end
    end
    if not Refs.LeafSim then
        local rs = ReplicatedStorage:FindFirstChild("LeafSim")
        if rs then
            local ok, res = pcall(require, rs)
            if ok and res then
                Refs.LeafSim = res
                Refs.LeafFolder = res.folder
                Refs.CollectMany = res.collectMany
            end
        end
    end
    local remotes = ReplicatedStorage:FindFirstChild("Remotes")
    if remotes then
        Refs.EmptyBackpack = remotes:FindFirstChild("EmptyBackpack")
    end
    local mapRegistry = ReplicatedStorage:FindFirstChild("MapRegistry")
    if mapRegistry then
        local ok, mr = pcall(require, mapRegistry)
        if ok and mr and mr.get then
            local ok2, dumpsters = pcall(function() return mr.get("Dumpsters") end)
            if ok2 then Refs.Dumpsters = dumpsters end
        end
    end
    if not Refs.Dumpsters then
        Refs.Dumpsters = workspace:FindFirstChild("Dumpsters")
    end
    RefreshStatus()
end)

local sharedOverlapParams = OverlapParams.new()
sharedOverlapParams.FilterType = Enum.RaycastFilterType.Include
local overlapFilterSet = false

task.spawn(function()
    while true do
        task.wait(GetCurrentInterval())

        if Refs.UserIntent and Refs.LeafSim then
            if Refs.PausedByBag and Refs.AutoSell and not Refs.IsTeleporting then
                Refs.IsTeleporting = true

                local dumpPos = getFixedDumpsterPos() or getBestDumpsterPos()
                local hrp = getRoot()
                if dumpPos and hrp then
                    local savedCFrame = hrp.CFrame
                    local ok = safeTeleport(dumpPos)
                    if ok then
                        task.wait(Refs.SellDelay)
                        pcall(function() Refs.EmptyBackpack:FireServer() end)
                        task.wait(Refs.SellDelay)
                        pcall(function()
                            local hrp2 = getRoot()
                            if hrp2 then hrp2.CFrame = savedCFrame end
                        end)
                    end
                end
                task.wait(Refs.SellTpCooldown)
                Refs.IsTeleporting = false
            elseif not Refs.PausedByBag then
                local hrp = getRoot()
                if hrp then
                    if not Refs.IsTeleporting then
                        Refs.OriginCFrame = hrp.CFrame
                        if isPositionSafe(hrp.Position) then
                            Refs.LastSafeCFrame = hrp.CFrame
                        end
                    end

                    if not overlapFilterSet and Refs.LeafFolder then
                        sharedOverlapParams.FilterDescendantsInstances = { Refs.LeafFolder }
                        overlapFilterSet = true
                    end

                    local current = LocalPlayer:GetAttribute("Leaves") or 0
                    local capacity = LocalPlayer:GetAttribute("LeafCapacity") or 25
                    local space = capacity - current
                    if space > 0 then
                        local parts = workspace:GetPartBoundsInRadius(hrp.Position, Refs.ScanRadius, sharedOverlapParams)
                        local batch = {}
                        local maxCount = math.min(space, Refs.MaxBatch)
                        local canUseLeaf = Refs.LeafSim.canUseLeaf

                        for _, part in ipairs(parts) do
                            if #batch >= maxCount then break end
                            if part:IsA("BasePart") then
                                local ok, usable = pcall(canUseLeaf, part)
                                if ok and usable then
                                    table.insert(batch, part)
                                end
                            end
                        end

                        if #batch > 0 then
                            pcall(function() Refs.CollectMany(batch) end)
                        elseif Refs.AutoFarm then
                            local leafPos = getSafeLeafPos()
                            if leafPos then
                                Refs.IsTeleporting = true
                                local ok = safeTeleport(leafPos)
                                if ok then
                                    Refs.LastTpTime = tick()
                                end
                                task.wait(0.15)
                                Refs.IsTeleporting = false
                            end
                        end
                    end
                end
            end
        end
    end
end)

task.spawn(function()
    while true do
        task.wait(0.5)
        if Refs.AntiOutOfBounds and Refs.UserIntent and not Refs.IsTeleporting and not Refs.PausedByBag then
            local hrp = getRoot()
            if hrp then
                if isPositionSafe(hrp.Position) then
                    Refs.LastSafeCFrame = hrp.CFrame
                else
                    Refs.IsTeleporting = true
                    local dumpPos = getBestDumpsterPos()
                    if dumpPos then
                        local ok = safeTeleport(dumpPos)
                        if ok then
                            Refs.LastTpTime = tick()
                        end
                    elseif Refs.LastSafeCFrame then
                        local ok = safeTeleport(Refs.LastSafeCFrame.Position)
                        if ok then
                            Refs.LastTpTime = tick()
                        end
                    end
                    task.wait(0.15)
                    Refs.IsTeleporting = false
                end
            end
        end
    end
end)

OnLeavesChanged()
RefreshStatus()

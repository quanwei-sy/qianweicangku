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

-- 力量传奇：独立服务器缝合版
-- 当前服务器功能与独立界面整合版
-- 每个文件仅包含当前服务器的功能与独立关于分区

local NothingLibrary = loadstring(game:HttpGetAsync('https://raw.githubusercontent.com/quanwei-sy/qianweicangku/refs/heads/main/%E6%BA%90%E7%A0%81.lua'))()

local __BaseWindow = NothingLibrary.new({
    Title = "TY hub｜力量传奇",
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

local Tabs = {}

local keySeq = 0
local function newKey(tag)
    keySeq = keySeq + 1
    return tag .. tostring(keySeq)
end

local function labelSet(label, text)
    if label == nil then return end
    if pcall(function() label:Set(text) end) then return end
    pcall(function() label:SetText(text) end)
end

local function createTabProxy(title)
    local tabName = tostring(title or '功能')
    local tab = Window:AddTab(tabName)
    local left = tab:AddLeftGroupbox(tabName)
    local right
    local function getRight()
        if not right then right = tab:AddRightGroupbox('信息') end
        return right
    end

    local proxy = {}

    function proxy:Toggle(opt)
        opt = opt or {}
        local ok, el = pcall(function()
            return left:AddToggle(newKey('TG'), {
                Text = tostring(opt.Title or '开关'),
                Default = opt.Value == true,
                Callback = opt.Callback or function() end,
            })
        end)
        return el
    end

    function proxy:Slider(opt)
        opt = opt or {}
        local ok, el = pcall(function()
            return left:AddSlider(newKey('SL'), {
                Text = tostring(opt.Title or '滑块'),
                Min = opt.Min or 0,
                Max = opt.Max or 100,
                Default = opt.Value or opt.Default or 0,
                Rounding = 0,
                Callback = opt.Callback or function() end,
            })
        end)
        return el
    end

    function proxy:Input(opt)
        opt = opt or {}
        local ok, el = pcall(function()
            return left:AddInput(newKey('IN'), {
                Text = tostring(opt.Title or '输入'),
                Default = tostring(opt.Value or opt.Default or ''),
                Placeholder = tostring(opt.Placeholder or ''),
                Callback = opt.Callback or function() end,
            })
        end)
        return el
    end

    function proxy:Dropdown(opt)
        opt = opt or {}
        local ok, el = pcall(function()
            return left:AddDropdown(newKey('DD'), {
                Text = tostring(opt.Title or '选择'),
                Values = opt.Values or {},
                Default = opt.Default,
                Multi = false,
                Callback = opt.Callback or function() end,
            })
        end)
        return el
    end

    function proxy:Button(opt)
        opt = opt or {}
        pcall(function()
            left:AddButton(tostring(opt.Title or '按钮'), function()
                if opt.Callback then opt.Callback() end
            end)
        end)
    end

    function proxy:Paragraph(opt)
        opt = opt or {}
        local prefix = tostring(opt.Title or '')
        local label
        pcall(function()
            label = getRight():AddLabel(prefix ~= '' and (prefix .. ': ' .. tostring(opt.Desc or '')) or tostring(opt.Desc or ''))
        end)
        local obj = {}
        function obj:SetDesc(text)
            labelSet(label, prefix ~= '' and (prefix .. ': ' .. tostring(text)) or tostring(text))
        end
        function obj:Set(text)
            labelSet(label, tostring(text))
        end
        return obj
    end

    return proxy
end

local TYShadow = {}

function TYShadow:AddTheme()

end

function TYShadow:Notify(opt)
    opt = opt or {}
    local txt
    if opt.Content ~= nil and opt.Title ~= nil then
        txt = tostring(opt.Title) .. ': ' .. tostring(opt.Content)
    else
        txt = tostring(opt.Title or opt.Content or '通知')
    end
    pcall(function() Library:Notify(txt, opt.Duration or 3) end)
end

function TYShadow:CreateWindow()
    local win = {}
    function win:Tab(opt)
        return createTabProxy(opt and opt.Title)
    end
    function win:Tag() end
    function win:Destroy()
        pcall(function() Library:Unload() end)
    end
    return win
end

local loadMainScript
loadMainScript = function(WindUI)
    local P=game:GetService("Players") local L=P.LocalPlayer local U=game:GetService("UserInputService") local R=game:GetService("ReplicatedStorage") local W=game:GetService("Workspace") local V=game:GetService("VirtualInputManager") local G=game:GetService("Lighting")
    local R0=true local a1,a2,a3,a4,a5,a6,a8,a9,a10=false,false,false,false,false,false,false,false,false
    local rbCount=10000
    local M=L:WaitForChild("muscleEvent",15) local RE=R:WaitForChild("rEvents",10)
    local RB=RE and RE:WaitForChild("rebirthRemote",10) local OC=RE and RE:WaitForChild("openCrystalRemote",10) local MF=W:WaitForChild("machinesFolder",10) local TP=Vector3.new(-655,23,-967)

    local crystalArgs = {"openCrystal", "Blaze Crystal", {"Golden Pheonix"}}

    for _,v in pairs(W:GetChildren()) do if string.find(string.lower(v.Name),"windui") then v:Destroy() end end

    WindUI:AddTheme({Name="DarkRed",Text=Color3.fromHex("#FFFFFF"),Accent=Color3.fromHex("#FF0000"),Background=Color3.fromHex("#000000"),Button=Color3.fromHex("#1A0000"),Icon=Color3.fromHex("#FF0000"),Outline=Color3.fromHex("#8B0000"),Placeholder=Color3.fromHex("#FF6666")})
    local Win=WindUI:CreateWindow({Title="TY 肌肉联合",Author="权威不是权威",Folder="TY",HideSearchBar=true,Icon="dumbbell",KeySystem=false,MaxSize=Vector2.new(520,420),MinSize=Vector2.new(520,420),NoResize=true,OpenButton={Title="TY 肌肉联合",Color=ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.fromHex("000000")),ColorSequenceKeypoint.new(1,Color3.fromHex("FF0000"))}),CornerRadius=UDim.new(0,16),Draggable=true,Enabled=true,Icon="dumbbell"},Resizable=false,ScrollBarEnabled=true,Size=UDim2.fromOffset(520,420),Theme="DarkRed",Transparent=false})

    Win:Tag({Title="TY",Color=Color3.fromHex("#FF0000")})

    pcall(function()
        WindUI:Notify({
            Title = "TY 加载成功",
            Content = "TY 肌肉联合已就绪",
            Duration = 3
        })
    end)

    local oD=Win.Destroy
    Win.Destroy=function(s,...)R0=false;a1,a2,a3,a4,a5,a6,a8,a9,a10=false,false,false,false,false,false,false,false,false;return oD(s,...)end
    L.Idled:Connect(function()V:SendKeyEvent(true,Enum.KeyCode.Y,false,game);task.wait(0.05);V:SendKeyEvent(false,Enum.KeyCode.Y,false,game)end)

    local T1=Win:Tab({Title="主要挂机",Icon="zap"})
    T1:Input({Title="自定义重生数量",Placeholder="输入数值后按回车生效",Value="10000",Callback=function(t)local num=tonumber(t) if num and num>0 then rbCount=num end end})
    T1:Toggle({Title="智能循环重生",Value=false,Callback=function(s)a1=s;if s then task.spawn(function()while a1 and R0 do local success=false pcall(function()local ls=L:FindFirstChild("leaderstats") local beforeReb=ls and ls:FindFirstChild("Rebirths") and ls.Rebirths.Value if RB and beforeReb then RB:InvokeServer("massRebirthRequest", rbCount) task.wait(0.1) local afterReb=ls.Rebirths.Value if afterReb>beforeReb then success=true end end end) if success then task.wait(0.1) else task.wait(1) end end end)end end})
    T1:Toggle({Title="自定义重生+俯卧撑",Value=false,Callback=function(s)a2=s;if s then task.spawn(function()while a2 and R0 do pcall(function()if RB then RB:InvokeServer("massRebirthRequest",rbCount)end;local c=L.Character;local b=L:FindFirstChild("Backpack");if c and c:FindFirstChild("Humanoid") and b then local p=b:FindFirstChild("Pushups");if p then c.Humanoid:EquipTool(p)end;for i=1,50 do M:FireServer("rep")end end end);task.wait(0.1)end end)end end})

    T1:Toggle({Title="卡宠(无视攻击)",Value=false,Callback=function(s)a8=s;if s then task.spawn(function()
        while a8 and R0 do
            pcall(function()
                local c=L.Character
                local h=c and c:FindFirstChild("HumanoidRootPart")
                local r=MF and MF:FindFirstChild("Glitch Rock")
                if not r and MF then
                    local sc,ch=pcall(function()return MF:GetChildren()[161]end)
                    if sc and ch then r=ch end
                end
                if h and M then
                    if r and r:FindFirstChild("Rock") then
                        h.CFrame=CFrame.lookAt(TP,r.Rock.Position)
                    else
                        h.CFrame=CFrame.new(TP)
                    end
                    local b=L:FindFirstChild("Backpack")
                    if c and b then
                        local p=b:FindFirstChild("Punch") or c:FindFirstChild("Punch")
                        if p and p.Parent==b then c.Humanoid:EquipTool(p) end
                        if p then p:Activate() end
                    end
                    M:FireServer("punch","rightHand")
                    M:FireServer("punch","leftHand")
                end
            end)
            task.wait()
        end
    end)end end})

    T1:Button({Title="【强制结束】",Color=Color3.fromHex("#FF0000"),Callback=function()R0=false;a1,a2,a3,a4,a5,a6,a8,a9,a10=false,false,false,false,false,false,false,false,false;Win:Destroy()end})

    local IP=T1:Paragraph({Title="玩家信息",Desc="加载中..."})
    task.spawn(function()while R0 do task.wait(1);local ls=L:FindFirstChild("leaderstats");local st=ls and ls:FindFirstChild("Strength");local rb=ls and ls:FindFirstChild("Rebirths");if st and rb then local sv=st.Value;if type(sv)=="number" and sv>1000000 then sv=string.format("%.2fM",sv/1000000)end;IP:SetDesc(string.format("玩家: %s\n力量: %s\n重生: %s",L.Name,tostring(sv),tostring(rb.Value)))end end end)

    local T2=Win:Tab({Title="自动锻炼",Icon="activity"})
    local sel="哑铃"
    T2:Dropdown({Title="选择类型",Default="哑铃",Values={"哑铃","倒立","仰卧起坐","俯卧撑"},Callback=function(v)sel=v end})
    T2:Toggle({Title="开启自动锻炼",Value=false,Callback=function(s)a5=s;if s then task.spawn(function()while a5 and R0 do pcall(function()local c=L.Character;local b=L:FindFirstChild("Backpack");if c and b then M:FireServer("rep");local tn="";if sel=="哑铃" then tn="Weight"elseif sel=="倒立" then tn="Handstands"elseif sel=="仰卧起坐" then tn="Situps"elseif sel=="俯卧撑" then tn="Pushups"end;if tn~="" then local t=b:FindFirstChild(tn);if t then c.Humanoid:EquipTool(t)end end end end);task.wait(0.1)end end)end end})
    T2:Toggle({Title="快速锻炼",Value=false,Callback=function(s)a6=s;if s then task.spawn(function()while a6 and R0 do pcall(function()local c=L.Character;local b=L:FindFirstChild("Backpack");if c and b then for i=1,120 do M:FireServer("rep")end;local tn="";if sel=="哑铃" then tn="Weight"elseif sel=="倒立" then tn="Handstands"elseif sel=="仰卧起坐" then tn="Situps"elseif sel=="俯卧撑" then tn="Pushups"end;if tn~="" and b:FindFirstChild(tn) then c.Humanoid:EquipTool(b[tn])end end end);task.wait()end end)end end})

    local T3=Win:Tab({Title="高级战斗",Icon="sword"})
    T3:Toggle({Title="传送秒杀全部玩家",Value=false,Callback=function(s)a9=s;if s then task.spawn(function()while a9 and R0 do for _, p in ipairs(P:GetPlayers()) do if p ~= L and p.Character then local char=p.Character local head=char:FindFirstChild("Head") local targetHRP=char:FindFirstChild("HumanoidRootPart") local hum=char:FindFirstChild("Humanoid") local myChar=L.Character local myHRP=myChar and myChar:FindFirstChild("HumanoidRootPart") if head and targetHRP and hum and hum.Health > 0 and myHRP then pcall(function()myHRP.CFrame=targetHRP.CFrame * CFrame.new(0, 0, 2)task.wait(0.01)if myChar:FindFirstChild("Humanoid") then local bp=L:FindFirstChild("Backpack") local punch=bp and bp:FindFirstChild("Punch") or myChar:FindFirstChild("Punch") if punch then myChar.Humanoid:EquipTool(punch)punch:Activate()end local lh=myChar:FindFirstChild("LeftHand") if lh then firetouchinterest(head, lh, 0)task.wait(0.01)firetouchinterest(head, lh, 1)M:FireServer("punch", "leftHand")M:FireServer("punch", "rightHand")end end end)end end end task.wait(0.15)end end)end end})

    local T4=Win:Tab({Title="传送",Icon="map-pin"})
    local tps={{"大厅",Vector3.new(-0.75,90.61,242.78)},{"小岛",Vector3.new(-32.13,8.51,1904.41)},{"冰霜",Vector3.new(-2623.4,6.99,-409.3)},{"神话",Vector3.new(2250.3,6.99,1072.7)},{"永恒",Vector3.new(-6758.3,6.99,-1284.4)},{"传奇",Vector3.new(4603.3,990.9,-3897.4)},{"肌肉之王",Vector3.new(-8625.4,16.9,-5730.4)},{"丛林",Vector3.new(-8685.0,5.9,2392.0)},{"无转盘岛",Vector3.new(1952.0,1,6179.9)},{"熔岩",Vector3.new(4472.5,118.9,-8848.5)},{"沙漠",Vector3.new(973.6,15.9,-7277.0)},{"海滩",Vector3.new(-1880.8,15.8,-6137.7)},{"故障岩",TP}}
    for _,tp in ipairs(tps) do T4:Button({Title=tp[1],Callback=function()local c=L.Character;if c and c:FindFirstChild("HumanoidRootPart") then c.HumanoidRootPart.CFrame=CFrame.new(tp[2])end end})end

    local T5=Win:Tab({Title="宠物/其他",Icon="cat"})

    T5:Dropdown({
        Title = "选择水晶",
        Default = "伏特水晶",
        Values = {"蓝色水晶", "绿色水晶", "冰霜水晶", "神话水晶", "伏特水晶", "传奇水晶", "地狱水晶", "肌肉之王", "丛林水晶", "水上健身房", "红绿龙抽奖"},
        Callback = function(v)
            if v == "蓝色水晶" then crystalArgs = {"openCrystal", "Blue Crystal", {}}
            elseif v == "绿色水晶" then crystalArgs = {"openCrystal", "Green Crystal", {}}
            elseif v == "冰霜水晶" then crystalArgs = {"openCrystal", "Frost Crystal", {}}
            elseif v == "神话水晶" then crystalArgs = {"openCrystal", "Mythical Crystal", {"Golden Pheonix"}}
            elseif v == "伏特水晶" then crystalArgs = {"openCrystal", "Blaze Crystal", {"Golden Pheonix"}}
            elseif v == "传奇水晶" then crystalArgs = {"openCrystal", "Muscle Elite Crystal", {"Golden Pheonix"}}
            elseif v == "地狱水晶" then crystalArgs = {"openCrystal", "Inferno Crystal", {}}
            elseif v == "肌肉之王" then crystalArgs = {"openCrystal", "Galaxy Oracle Crystal", {}}
            elseif v == "丛林水晶" then crystalArgs = {"openCrystal", "Jungle Crystal", {}}
            elseif v == "水上健身房" then crystalArgs = {"openCrystal", "Water Crystal", {}}
            elseif v == "红绿龙抽奖" then crystalArgs = {"openCrystal", "Inner Peace Crystal", {}}
            end
        end
    })

    T5:Toggle({Title="极速抽水晶",Value=false,Callback=function(s)local isFastDraw=s;if s then local function fastDrawLoop()while isFastDraw and R0 do pcall(function()if OC then OC:InvokeServer(unpack(crystalArgs))end end)task.wait(0.01)end end for i=1,5 do task.spawn(fastDrawLoop)end end end})

    T5:Paragraph({Title="提示", Desc="抽奖需要站在水晶旁边"})

    local wheelRunning = false
    T5:Toggle({Title="自动抽幸运轮盘",Value=false,Callback=function(s)
        wheelRunning = s
        if s then
            task.spawn(function()
                local WRemote = RE and RE:WaitForChild("openFortuneWheelRemote", 10)
                local WChances = R and R:FindFirstChild("fortuneWheelChances")
                if not WRemote or not WChances then
                    WindUI:Notify({Title="错误",Content="找不到轮盘事件或参数!",Duration=3})
                    wheelRunning = false
                    return
                end
                while wheelRunning and R0 do
                    pcall(function()
                        WRemote:InvokeServer("openFortuneWheel", WChances["Fortune Wheel"])
                    end)
                    task.wait(0.01)
                end
            end)
        end
    end})

    T5:Button({Title="清空特效",Callback=function()G.Brightness=0 G.GlobalShadows=false for _,v in ipairs(W:GetDescendants())do if v:IsA("ParticleEmitter")or v:IsA("Fire")or v:IsA("Smoke")then v:Destroy()end end WindUI:Notify({Title="清空",Content="已清理",Duration=2})end})
end

if not game:IsLoaded() then game.Loaded:Wait() end

local okStart, errStart = pcall(function()
    loadMainScript(TYShadow)
end)

Tabs.Settings = Window:AddTab('设置')

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
    pcall(function() Library:Unload() end)
end)

local InfoGroup = Tabs.Settings:AddRightGroupbox('信息')
InfoGroup:AddLabel('=== TY hub ===')
InfoGroup:AddLabel('版本: 1.0.0')
InfoGroup:AddLabel('作者：权威不是权威')
InfoGroup:AddDivider()
InfoGroup:AddLabel('菜单快捷键: RightShift')

pcall(function() Library.ToggleKeybind = 'RightShift' end)
pcall(function() ThemeManager:SetLibrary(Library) end)
pcall(function() SaveManager:SetLibrary(Library) end)
pcall(function() SaveManager:IgnoreThemeSettings() end)
pcall(function() SaveManager:SetIgnoreIndexes({}) end)
pcall(function() ThemeManager:SetFolder('TYUI_Muscle') end)
pcall(function() SaveManager:SetFolder('TYUI_Muscle/config') end)
pcall(function() SaveManager:SetSubFolder('GMVersion') end)
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
    pcall(function() Library:SetWatermark(('TY | %d fps'):format(math.floor(fps))) end)
end)

if okStart then
    pcall(function() Library:Notify('TY 界面加载完成', 3) end)
else
    pcall(function() Library:Notify('脚本初始化失败: ' .. tostring(errStart), 5) end)
    warn('[GM-TY] 初始化失败: ' .. tostring(errStart))
end

local env = (getgenv and getgenv()) or _G
env.TYUI_GM = {
    Library = Library,
    Unload = function()
        pcall(function() Library:Unload() end)
    end,
}

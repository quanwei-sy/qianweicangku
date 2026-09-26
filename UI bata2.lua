```lua
-- TY HUB • Liquid Glass UI
-- 说明: 将本 LocalScript 放入 StarterPlayer > StarterPlayerScripts
-- 实现液态玻璃风格客户端界面：可调透明度、滑动侧边栏、自瞄/追踪/功能 Toggle、iOS 风格圆角高光、多层渐变等
-- 作者: 自定义

--// 服务
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

--==================================================
-- 清理旧版界面
--==================================================
local OLD = PlayerGui:FindFirstChild("TY_HUB_LiquidGlass")
if OLD then
    OLD:Destroy()
end

--==================================================
-- 基础函数：New 创建实例，Tween 补间，Round 圆角，Stroke 描边，Mix 颜色插值
--==================================================
local function New(className, properties, parent)
    local obj = Instance.new(className)
    for prop, val in pairs(properties or {}) do
        obj[prop] = val
    end
    if parent then
        obj.Parent = parent
    end
    return obj
end

local function Tween(obj, duration, props, style, direction)
    local info = TweenInfo.new(duration or 0.25, style or Enum.EasingStyle.Quint, direction or Enum.EasingDirection.Out)
    local tw = TweenService:Create(obj, info, props)
    tw:Play()
    return tw
end

local function Round(obj, radius)
    local corner = New("UICorner", {CornerRadius = UDim.new(0, radius or 12)}, obj)
    return corner
end

local function Stroke(obj, color, transparency, thickness)
    return New("UIStroke", {Color = color or Color3.new(1,1,1), Transparency = transparency or 0.8, Thickness = thickness or 1}, obj)
end

local function Mix(a, b, amount)
    return Color3.new(a.R + (b.R - a.R) * amount, a.G + (b.G - a.G) * amount, a.B + (b.B - a.B) * amount)
end

--==================================================
-- 主题设置
--==================================================
local Theme = {
    Background = Color3.fromRGB(30, 34, 45),    -- 加亮的玻璃背景
    Accent     = Color3.fromRGB(115,165,255),   -- 强调色
    Text       = Color3.fromRGB(255,255,255),   -- 主要文字颜色
    SubText    = Color3.fromRGB(205,211,225),   -- 次要文字颜色
    White      = Color3.fromRGB(255,255,255),   -- 白色
    GlassHighlight = Color3.fromRGB(235,242,255) -- 玻璃高光颜色
}
local TransparencyValue = 0.15  -- 默认玻璃半透明值

local GlassObjects = {}  -- 注册需要统一刷新的对象
local function RegisterGlass(obj, offset)
    GlassObjects[obj] = offset or 0
    return obj
end

local function RefreshGlass()
    for obj, offset in pairs(GlassObjects) do
        if obj and obj.Parent then
            obj.BackgroundColor3 = Theme.Background
            obj.BackgroundTransparency = math.clamp(TransparencyValue + offset, 0, 0.95)
        end
    end
end

local function GetAccent()
    return Theme.Accent
end

--==================================================
-- 根 ScreenGui
--==================================================
local ScreenGui = New("ScreenGui", {
    Name = "TY_HUB_LiquidGlass",
    ResetOnSpawn = false,
    IgnoreGuiInset = true,
    DisplayOrder = 9999,
    ZIndexBehavior = Enum.ZIndexBehavior.Global
}, PlayerGui)

--==================================================
-- 主容器 CanvasGroup （用于动画淡入淡出）
--==================================================
local MainGroup = New("CanvasGroup", {
    Name = "MainGroup",
    AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.fromScale(0.5, 0.5),
    Size = UDim2.fromScale(0.88, 0.76),
    BackgroundTransparency = 1,
    GroupTransparency = 1
}, ScreenGui)
-- 限制最小最大尺寸
New("UISizeConstraint", {MinSize = Vector2.new(330, 380), MaxSize = Vector2.new(980, 700)}, MainGroup)

--==================================================
-- 阴影层：用于窗口投影
--==================================================
local Shadow = New("Frame", {
    Name = "Shadow",
    AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.new(0.5, 0, 0.5, 10),
    Size = UDim2.new(1, 18, 1, 18),
    BackgroundColor3 = Color3.new(0, 0, 0),
    BackgroundTransparency = 0.72,
    BorderSizePixel = 0,
    ZIndex = 0
}, MainGroup)
Round(Shadow, 30)

--==================================================
-- 主背景层（半透明玻璃）
--==================================================
local Main = New("Frame", {
    Name = "Main",
    Size = UDim2.fromScale(1, 1),
    BackgroundColor3 = Theme.Background,
    BackgroundTransparency = TransparencyValue,
    BorderSizePixel = 0,
    ZIndex = 1
}, MainGroup)
Round(Main, 30)
Stroke(Main, Theme.White, 0.82, 1.2)
RegisterGlass(Main, 0)

--==================================================
-- 顶部光辉层（渐变高光动画）
--==================================================
local Shine = New("Frame", {
    Name = "Shine",
    Size = UDim2.new(1, 0, 0, 130),
    Position = UDim2.new(0, 0, 0, 0),
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    ZIndex = 2
}, Main)
Round(Shine, 30)
local ShineGradient = New("UIGradient", {
    Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Theme.GlassHighlight),
        ColorSequenceKeypoint.new(0.22, Theme.Accent),
        ColorSequenceKeypoint.new(0.55, Theme.GlassHighlight),
        ColorSequenceKeypoint.new(1, Theme.GlassHighlight)
    },
    Transparency = NumberSequence.new{
        NumberSequenceKeypoint.new(0, 0.97),
        NumberSequenceKeypoint.new(0.25, 0.88),
        NumberSequenceKeypoint.new(0.5, 0.96),
        NumberSequenceKeypoint.new(1, 1)
    },
    Rotation = 15
}, Shine)
-- 光线移动动画
task.spawn(function()
    while Shine and Shine.Parent do
        Tween(ShineGradient, 4.5, {Offset = Vector2.new(1.2, 0)}, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut).Completed:Wait()
        ShineGradient.Offset = Vector2.new(-1.2, 0)
    end
end)

--==================================================
-- 标题栏（Logo + 标题文字 + 窗口按钮）
--==================================================
local Header = New("Frame", {
    Name = "Header",
    Size = UDim2.new(1, -32, 0, 64),
    Position = UDim2.new(0, 16, 0, 14),
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    ZIndex = 10
}, Main)

-- 左上 Logo
local LogoHolder = New("Frame", {
    Name = "LogoHolder",
    Size = UDim2.fromOffset(48, 48),
    Position = UDim2.new(0, 0, 0.5, -24),
    BackgroundColor3 = Theme.Accent,
    BackgroundTransparency = 0.12,
    BorderSizePixel = 0
}, Header)
Round(LogoHolder, 15)
Stroke(LogoHolder, Theme.White, 0.7, 1)
New("UIGradient", {
    Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Theme.White),
        ColorSequenceKeypoint.new(0.5, Theme.Accent),
        ColorSequenceKeypoint.new(1, Mix(Theme.Accent, Color3.new(0,0,0), 0.35))
    },
    Rotation = 135
}, LogoHolder)
New("TextLabel", {
    Size = UDim2.fromScale(1,1),
    BackgroundTransparency = 1,
    Text = "TY",
    Font = Enum.Font.GothamBold,
    TextSize = 17,
    TextColor3 = Theme.White,
    ZIndex = 11
}, LogoHolder)

-- 标题文字
New("TextLabel", {
    Size = UDim2.new(0, 260, 0, 25),
    Position = UDim2.new(0, 62, 0, 5),
    BackgroundTransparency = 1,
    Text = "TY HUB",
    Font = Enum.Font.GothamBold,
    TextSize = 22,
    TextColor3 = Theme.Text,
    TextXAlignment = Enum.TextXAlignment.Left,
    ZIndex = 11
}, Header)
New("TextLabel", {
    Size = UDim2.new(0, 260, 0, 20),
    Position = UDim2.new(0, 63, 0, 32),
    BackgroundTransparency = 1,
    Text = "LIQUID GLASS 版",
    Font = Enum.Font.GothamMedium,
    TextSize = 10,
    TextColor3 = Theme.SubText,
    TextXAlignment = Enum.TextXAlignment.Left,
    ZIndex = 11
}, Header)

-- 右上 关闭按钮
local CloseButton = New("TextButton", {
    Name = "CloseButton",
    AnchorPoint = Vector2.new(1, 0.5),
    Position = UDim2.new(1, 0, 0.5, 0),
    Size = UDim2.fromOffset(42, 42),
    BackgroundColor3 = Color3.fromRGB(255, 65, 85),
    BackgroundTransparency = 0.14,
    BorderSizePixel = 0,
    Text = "×",
    TextSize = 24,
    Font = Enum.Font.GothamMedium,
    TextColor3 = Theme.White,
    AutoButtonColor = false,
    ZIndex = 20
}, Header)
Round(CloseButton, 14)
-- 右上 最小化按钮
local MinButton = New("TextButton", {
    Name = "MinButton",
    AnchorPoint = Vector2.new(1, 0.5),
    Position = UDim2.new(1, -50, 0.5, 0),
    Size = UDim2.fromOffset(42, 42),
    BackgroundColor3 = Theme.White,
    BackgroundTransparency = 0.88,
    BorderSizePixel = 0,
    Text = "—",
    TextSize = 21,
    Font = Enum.Font.GothamMedium,
    TextColor3 = Theme.White,
    AutoButtonColor = false,
    ZIndex = 20
}, Header)
Round(MinButton, 14)

-- 鼠标悬停效果
local function ButtonHover(button, normalTrans)
    button.MouseEnter:Connect(function()
        Tween(button, 0.18, {BackgroundTransparency = math.max(0, normalTrans - 0.12)})
    end)
    button.MouseLeave:Connect(function()
        Tween(button, 0.18, {BackgroundTransparency = normalTrans})
    end)
end
ButtonHover(CloseButton, 0.14)
ButtonHover(MinButton, 0.88)

--==================================================
-- 主体区域（侧边栏 + 内容区）
--==================================================
local Body = New("Frame", {
    Name = "Body",
    Size = UDim2.new(1, -32, 1, -94),
    Position = UDim2.new(0, 16, 0, 82),
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    ZIndex = 5
}, Main)

--==================================================
-- 侧边栏（可滚动）
--==================================================
local Sidebar = New("ScrollingFrame", {
    Name = "Sidebar",
    Size = UDim2.new(0, 178, 1, 0),
    BackgroundColor3 = Theme.Background,
    BackgroundTransparency = TransparencyValue + 0.05,
    BorderSizePixel = 0,
    ScrollingDirection = Enum.ScrollingDirection.Y,
    ScrollBarThickness = 3,
    ScrollBarImageColor3 = Theme.Accent,
    ScrollBarImageTransparency = 0.35,
    AutomaticCanvasSize = Enum.AutomaticSize.Y,
    CanvasSize = UDim2.new(0, 0, 0, 0),
    ScrollingEnabled = true,
    ZIndex = 6
}, Body)
Round(Sidebar, 23)
RegisterGlass(Sidebar, 0.05)
Stroke(Sidebar, Theme.White, 0.91, 1)
New("UIPadding", {
    PaddingTop = UDim.new(0, 14),
    PaddingLeft = UDim.new(0, 12),
    PaddingRight = UDim.new(0, 12),
    PaddingBottom = UDim.new(0, 14)
}, Sidebar)
local SidebarList = New("UIListLayout", {
    FillDirection = Enum.FillDirection.Vertical,
    SortOrder = Enum.SortOrder.LayoutOrder,
    Padding = UDim.new(0, 6)
}, Sidebar)

--==================================================
-- 内容区（内容页面容器）
--==================================================
local Content = New("Frame", {
    Name = "Content",
    Size = UDim2.new(1, -194, 1, 0),
    Position = UDim2.new(0, 194, 0, 0),
    BackgroundColor3 = Theme.Background,
    BackgroundTransparency = TransparencyValue + 0.06,
    BorderSizePixel = 0,
    ZIndex = 6
}, Body)
Round(Content, 23)
RegisterGlass(Content, 0.06)
Stroke(Content, Theme.White, 0.92, 1)

-- 页面和导航按钮字典
local Pages = {}
local NavigationButtons = {}
local CurrentPage = nil

--==================================================
-- 创建页面模板函数
--==================================================
local function CreatePage(key, title, subtitle)
    local Page = New("CanvasGroup", {
        Name = key,
        Size = UDim2.new(1, -24, 1, -24),
        Position = UDim2.new(0, 12, 0, 12),
        BackgroundTransparency = 1,
        GroupTransparency = 1,
        Visible = false,
        ZIndex = 8
    }, Content)
    local PageHeader = New("Frame", {
        Size = UDim2.new(1, 0, 0, 58),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ZIndex = 9
    }, Page)
    New("TextLabel", {
        Size = UDim2.new(1, -10, 0, 28),
        BackgroundTransparency = 1,
        Text = title,
        Font = Enum.Font.GothamBold,
        TextSize = 20,
        TextColor3 = Theme.Text,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 10
    }, PageHeader)
    New("TextLabel", {
        Size = UDim2.new(1, -10, 0, 20),
        Position = UDim2.new(0, 0, 0, 31),
        BackgroundTransparency = 1,
        Text = subtitle,
        Font = Enum.Font.Gotham,
        TextSize = 11,
        TextColor3 = Theme.SubText,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 10
    }, PageHeader)
    local Scroll = New("ScrollingFrame", {
        Name = "Scroll",
        Size = UDim2.new(1, 0, 1, -62),
        Position = UDim2.new(0, 0, 0, 62),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        ScrollingDirection = Enum.ScrollingDirection.Y,
        ScrollBarThickness = 2,
        ScrollBarImageTransparency = 0.45,
        ScrollBarImageColor3 = Theme.Accent,
        ZIndex = 9
    }, Page)
    New("UIPadding", {
        PaddingTop = UDim.new(0, 4),
        PaddingBottom = UDim.new(0, 12),
        PaddingLeft = UDim.new(0, 2),
        PaddingRight = UDim.new(0, 8)
    }, Scroll)
    New("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 10)
    }, Scroll)
    Pages[key] = Page
    return Page, Scroll
end

--==================================================
-- UI 组件辅助函数
--==================================================
local function CreateSection(parent, title, desc)
    local Holder = New("Frame", {
        Size = UDim2.new(1,0,0,48),
        BackgroundTransparency = 1,
        BorderSizePixel = 0
    }, parent)
    New("TextLabel", {
        Size = UDim2.new(1,0,0,24),
        BackgroundTransparency = 1,
        Text = title,
        Font = Enum.Font.GothamBold,
        TextSize = 14,
        TextColor3 = Theme.Text,
        TextXAlignment = Enum.TextXAlignment.Left
    }, Holder)
    New("TextLabel", {
        Size = UDim2.new(1,0,0,20),
        Position = UDim2.new(0,0,0,25),
        BackgroundTransparency = 1,
        Text = desc,
        Font = Enum.Font.Gotham,
        TextSize = 10,
        TextColor3 = Theme.SubText,
        TextXAlignment = Enum.TextXAlignment.Left
    }, Holder)
    return Holder
end

local function CreateCard(parent, height)
    local Card = New("Frame", {
        Size = UDim2.new(1,0,0,height or 70),
        BackgroundColor3 = Theme.Background,
        BackgroundTransparency = TransparencyValue + 0.06,
        BorderSizePixel = 0
    }, parent)
    Round(Card, 18)
    RegisterGlass(Card, 0.06)
    Stroke(Card, Theme.White, 0.95, 1)
    return Card
end

--==================================================
-- 功能开关 Toggle
--==================================================
local FeatureState = {Aim = false, Track = false, FOV = true, Smooth = true}
local FeatureCallbacks = {
    Aim = function(enabled) print("[TY HUB] Aim:", enabled) end,
    Track = function(enabled) print("[TY HUB] Track:", enabled) end,
    FOV = function(enabled) print("[TY HUB] FOV:", enabled) end,
    Smooth = function(enabled) print("[TY HUB] Smooth:", enabled) end
}
local function CreateToggle(parent, title, desc, key)
    local Card = CreateCard(parent, 72)
    local TextArea = New("Frame", {Size = UDim2.new(1, -92, 1, 0), BackgroundTransparency = 1}, Card)
    New("TextLabel", {
        Size = UDim2.new(1,0,0,23),
        Position = UDim2.new(0, 15, 0, 13),
        BackgroundTransparency = 1,
        Text = title,
        Font = Enum.Font.GothamMedium,
        TextSize = 13,
        TextColor3 = Theme.Text,
        TextXAlignment = Enum.TextXAlignment.Left
    }, TextArea)
    New("TextLabel", {
        Size = UDim2.new(1,0,0,20),
        Position = UDim2.new(0, 15, 0, 37),
        BackgroundTransparency = 1,
        Text = desc,
        Font = Enum.Font.Gotham,
        TextSize = 10,
        TextColor3 = Theme.SubText,
        TextXAlignment = Enum.TextXAlignment.Left
    }, TextArea)
    local Toggle = New("TextButton", {
        Size = UDim2.fromOffset(50, 28),
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -15, 0.5, 0),
        BackgroundColor3 = Color3.fromRGB(75,78,90),
        BackgroundTransparency = 0.15,
        BorderSizePixel = 0,
        Text = "",
        AutoButtonColor = false
    }, Card)
    Round(Toggle, 20)
    local Knob = New("Frame", {
        Size = UDim2.fromOffset(22, 22),
        Position = UDim2.new(0, 3, 0.5, -11),
        BackgroundColor3 = Color3.new(1,1,1),
        BorderSizePixel = 0
    }, Toggle)
    Round(Knob, 50)
    local State = FeatureState[key]
    local function Refresh()
        if State then
            Tween(Toggle, 0.2, {BackgroundColor3 = GetAccent()})
            Tween(Knob, 0.2, {Position = UDim2.new(1, -25, 0.5, -11)})
        else
            Tween(Toggle, 0.2, {BackgroundColor3 = Color3.fromRGB(75,78,90)})
            Tween(Knob, 0.2, {Position = UDim2.new(0, 3, 0.5, -11)})
        end
        FeatureState[key] = State
        if FeatureCallbacks[key] then
            FeatureCallbacks[key](State)
        end
    end
    Toggle.Activated:Connect(function()
        State = not State
        Refresh()
    end)
    Refresh()
    return Card
end

--==================================================
-- 侧边导航按钮
--==================================================
local function CreateNavButton(key, title, icon, order)
    local Button = New("TextButton", {
        Name = key,
        Size = UDim2.new(1, 0, 0, 42),
        BackgroundColor3 = Theme.Accent,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Text = "",
        AutoButtonColor = false,
        LayoutOrder = order,
        ZIndex = 10
    }, Sidebar)
    Round(Button, 14)
    local IconBox = New("Frame", {
        Size = UDim2.fromOffset(28, 28),
        Position = UDim2.new(0, 7, 0.5, -14),
        BackgroundTransparency = 1
    }, Button)
    New("TextLabel", {
        Size = UDim2.fromScale(1,1),
        BackgroundTransparency = 1,
        Text = icon,
        Font = Enum.Font.GothamBold,
        TextSize = 15,
        TextColor3 = Theme.SubText
    }, IconBox)
    New("TextLabel", {
        Size = UDim2.new(1, -48, 1, 0),
        Position = UDim2.new(0, 43, 0, 0),
        BackgroundTransparency = 1,
        Text = title,
        Font = Enum.Font.GothamMedium,
        TextSize = 12,
        TextColor3 = Theme.SubText,
        TextXAlignment = Enum.TextXAlignment.Left
    }, Button)
    NavigationButtons[key] = Button
    return Button
end

--==================================================
-- 导航按钮
--==================================================
local HomeButton    = CreateNavButton("Home", "主页", "⌂", 1)
local AimButton     = CreateNavButton("Aim", "自瞄", "◎", 2)
local TrackButton   = CreateNavButton("Track", "子追", "◈", 3)
local VisualButton  = CreateNavButton("Visual", "视觉", "◉", 4)
local PlayersButton = CreateNavButton("Players", "玩家", "♙", 5)
local ScriptsButton = CreateNavButton("Scripts", "脚本中心", "▣", 6)
local ToolsButton   = CreateNavButton("Tools", "工具", "◆", 7)
local AboutButton   = CreateNavButton("About", "关于", "?", 8)
local AuthorButton  = CreateNavButton("Author", "作者信息", "•", 9)
local SettingsButton= CreateNavButton("Settings", "设置", "⚙", 10)

--==================================================
-- 页面内容
--==================================================
local HomePage, HomeScroll   = CreatePage("Home", "欢迎使用 TY HUB", "Liquid Glass 界面示例")
local AimPage, AimScroll     = CreatePage("Aim", "自瞄系统", "目标自动瞄准功能")
local TrackPage, TrackScroll = CreatePage("Track", "子弹追踪", "目标追踪辅助系统")
local VisualPage, VisualScroll = CreatePage("Visual", "视觉界面", "视觉设置面板")
local PlayersPage, PlayersScroll = CreatePage("Players", "玩家面板", "玩家相关工具")
local ScriptsPage, ScriptsScroll = CreatePage("Scripts", "脚本中心", "模块化功能列表")
local ToolsPage, ToolsScroll = CreatePage("Tools", "工具面板", "实用工具合集")
local AboutPage, AboutScroll = CreatePage("About", "关于 TY HUB", "版本与界面信息")
local AuthorPage, AuthorScroll = CreatePage("Author", "作者信息", "项目与作者资料")
local SettingsPage, SettingsScroll = CreatePage("Settings", "界面设置", "透明度与主题")

-- Home 页
CreateSection(HomeScroll, "状态中心", "TY HUB 当前运行状态")
local StatusCard = CreateCard(HomeScroll, 90)
local StatusDot = New("Frame", {
    Size = UDim2.fromOffset(10, 10),
    Position = UDim2.new(0, 18, 0, 20),
    BackgroundColor3 = Color3.fromRGB(80, 230, 160),
    BorderSizePixel = 0
}, StatusCard)
Round(StatusDot, 99)
New("TextLabel", {
    Size = UDim2.new(1, -55, 0, 20),
    Position = UDim2.new(0, 38, 0, 10),
    BackgroundTransparency = 1,
    Text = "TY HUB 在线",
    Font = Enum.Font.GothamBold,
    TextSize = 14,
    TextColor3 = Theme.Text,
    TextXAlignment = Enum.TextXAlignment.Left
}, StatusCard)
New("TextLabel", {
    Size = UDim2.new(1, -55, 0, 40),
    Position = UDim2.new(0, 38, 0, 35),
    BackgroundTransparency = 1,
    Text = "液态玻璃界面已加载。\n所有动画使用 TweenService。",
    Font = Enum.Font.Gotham,
    TextSize = 10,
    TextColor3 = Theme.SubText,
    TextXAlignment = Enum.TextXAlignment.Left,
    TextWrapped = true
}, StatusCard)
local QuickCard = CreateCard(HomeScroll, 80)
New("TextLabel", {
    Size = UDim2.new(1, -30, 0, 24),
    Position = UDim2.new(0, 15, 0, 12),
    BackgroundTransparency = 1,
    Text = "快捷指南",
    Font = Enum.Font.GothamBold,
    TextSize = 11,
    TextColor3 = Theme.SubText,
    TextXAlignment = Enum.TextXAlignment.Left
}, QuickCard)
New("TextLabel", {
    Size = UDim2.new(1, -30, 0, 40),
    Position = UDim2.new(0, 15, 0, 34),
    BackgroundTransparency = 1,
    Text = "左侧导航切换功能页面，右上角可最小化/关闭。设置页可调透明度/主题。",
    Font = Enum.Font.Gotham,
    TextSize = 10,
    TextColor3 = Theme.Text,
    TextXAlignment = Enum.TextXAlignment.Left,
    TextWrapped = true
}, QuickCard)

-- Aim 页
CreateSection(AimScroll, "自瞄模块", "目标辅助瞄准设置")
CreateToggle(AimScroll, "自瞄", "开启/关闭自瞄", "Aim")
CreateToggle(AimScroll, "显示 FOV", "显示辅助范围", "FOV")
CreateToggle(AimScroll, "平滑模式", "目标移动过渡平滑", "Smooth")
local AimInfo = CreateCard(AimScroll, 80)
New("TextLabel", {
    Size = UDim2.new(1,-30,1,-20),
    Position = UDim2.new(0, 15, 0, 10),
    BackgroundTransparency = 1,
    Text = "功能接口：FeatureCallbacks.Aim(enabled) 等",
    Font = Enum.Font.Gotham,
    TextSize = 10,
    TextColor3 = Theme.SubText,
    TextXAlignment = Enum.TextXAlignment.Left
}, AimInfo)

-- Track 页
CreateSection(TrackScroll, "子弹追踪", "目标轨迹跟踪设置")
CreateToggle(TrackScroll, "子追", "开启/关闭子弹追踪", "Track")
local TrackInfo = CreateCard(TrackScroll, 80)
New("TextLabel", {
    Size = UDim2.new(1,-30,1,-20),
    Position = UDim2.new(0, 15, 0, 10),
    BackgroundTransparency = 1,
    Text = "此界面 UI 与算法分离，可自行实现逻辑。",
    Font = Enum.Font.Gotham,
    TextSize = 10,
    TextColor3 = Theme.SubText,
    TextXAlignment = Enum.TextXAlignment.Left
}, TrackInfo)

-- Visual 页（占位）
CreateSection(VisualScroll, "视觉功能", "添加视觉相关功能设置")
local VisualCard = CreateCard(VisualScroll, 80)
New("TextLabel", {
    Size = UDim2.new(1,-30,1,-20),
    Position = UDim2.new(0, 15, 0, 10),
    BackgroundTransparency = 1,
    Text = "待开发：视觉功能占位文本。",
    Font = Enum.Font.Gotham,
    TextSize = 10,
    TextColor3 = Theme.SubText,
    TextXAlignment = Enum.TextXAlignment.Left,
    TextWrapped = true
}, VisualCard)

-- Players 页（占位）
CreateSection(PlayersScroll, "玩家功能", "添加玩家相关功能设置")
local PlayersCard = CreateCard(PlayersScroll, 80)
New("TextLabel", {
    Size = UDim2.new(1,-30,1,-20),
    Position = UDim2.new(0, 15, 0, 10),
    BackgroundTransparency = 1,
    Text = "待开发：玩家功能占位文本。",
    Font = Enum.Font.Gotham,
    TextSize = 10,
    TextColor3 = Theme.SubText,
    TextXAlignment = Enum.TextXAlignment.Left,
    TextWrapped = true
}, PlayersCard)

-- Scripts 页
CreateSection(ScriptsScroll, "脚本中心", "模块化功能管理")
local ScriptNames = {
    {"MainModule",    "主功能模块"},
    {"VisualModule",  "视觉模块"},
    {"UtilityModule", "辅助工具模块"},
    {"SettingsModule","设置模块"}
}
for _, info in ipairs(ScriptNames) do
    local Card = CreateCard(ScriptsScroll, 72)
    New("TextLabel", {
        Size = UDim2.new(1, -110, 0, 23),
        Position = UDim2.new(0, 15, 0, 11),
        BackgroundTransparency = 1,
        Text = info[1],
        Font = Enum.Font.GothamMedium,
        TextSize = 13,
        TextColor3 = Theme.Text,
        TextXAlignment = Enum.TextXAlignment.Left
    }, Card)
    New("TextLabel", {
        Size = UDim2.new(1, -110, 0, 20),
        Position = UDim2.new(0, 15, 0, 35),
        BackgroundTransparency = 1,
        Text = info[2],
        Font = Enum.Font.Gotham,
        TextSize = 10,
        TextColor3 = Theme.SubText,
        TextXAlignment = Enum.TextXAlignment.Left
    }, Card)
    local LoadButton = New("TextButton", {
        Size = UDim2.fromOffset(70, 31),
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -13, 0.5, 0),
        BackgroundColor3 = Theme.Accent,
        BackgroundTransparency = 0.15,
        BorderSizePixel = 0,
        Text = "OPEN",
        Font = Enum.Font.GothamBold,
        TextSize = 10,
        TextColor3 = Theme.White,
        AutoButtonColor = false
    }, Card)
    Round(LoadButton, 12)
    LoadButton.Activated:Connect(function()
        local old = LoadButton.Text
        LoadButton.Text = "OPENED"
        Tween(LoadButton, 0.18, {BackgroundTransparency = 0})
        task.delay(0.7, function()
            if LoadButton and LoadButton.Parent then
                LoadButton.Text = old
                Tween(LoadButton, 0.18, {BackgroundTransparency = 0.15})
            end
        end)
    end)
end

-- About 页
CreateSection(AboutScroll, "关于 TY HUB", "Liquid Glass 界面")
local AboutCard = CreateCard(AboutScroll, 140)
New("TextLabel", {
    Size = UDim2.new(1, -30, 0, 30),
    Position = UDim2.new(0, 15, 0, 12),
    BackgroundTransparency = 1,
    Text = "TY HUB Liquid Glass UI",
    Font = Enum.Font.GothamBold,
    TextSize = 18,
    TextColor3 = Theme.Text,
    TextXAlignment = Enum.TextXAlignment.Left
}, AboutCard)
New("TextLabel", {
    Size = UDim2.new(1, -30, 0, 90),
    Position = UDim2.new(0, 15, 0, 50),
    BackgroundTransparency = 1,
    Text = "多层半透明玻璃+圆角+渐变描边+动态高光+Tween 动画组合的现代化 UI。",
    Font = Enum.Font.Gotham,
    TextSize = 11,
    TextColor3 = Theme.SubText,
    TextXAlignment = Enum.TextXAlignment.Left,
    TextWrapped = true
}, AboutCard)

-- Author 页
CreateSection(AuthorScroll, "作者信息", "项目资料")
local AuthorCard = CreateCard(AuthorScroll, 110)
New("TextLabel", {
    Size = UDim2.new(1, -30, 0, 25),
    Position = UDim2.new(0, 15, 0, 13),
    BackgroundTransparency = 1,
    Text = "TY HUB 项目",
    Font = Enum.Font.GothamBold,
    TextSize = 15,
    TextColor3 = Theme.Text,
    TextXAlignment = Enum.TextXAlignment.Left
}, AuthorCard)
New("TextLabel", {
    Size = UDim2.new(1, -30, 0, 72),
    Position = UDim2.new(0, 15, 0, 42),
    BackgroundTransparency = 1,
    Text = "作者: 自定义\n版本: 2.0\n状态: Active",
    Font = Enum.Font.Gotham,
    TextSize = 11,
    TextColor3 = Theme.SubText,
    TextXAlignment = Enum.TextXAlignment.Left,
    TextYAlignment = Enum.TextYAlignment.Top
}, AuthorCard)

-- Settings 页
CreateSection(SettingsScroll, "透明度", "调整玻璃效果透明度")
local SliderCard = CreateCard(SettingsScroll, 95)
New("TextLabel", {
    Size = UDim2.new(1, -30, 0, 24),
    Position = UDim2.new(0, 15, 0, 10),
    BackgroundTransparency = 1,
    Text = "Glass Transparency",
    Font = Enum.Font.GothamMedium,
    TextSize = 12,
    TextColor3 = Theme.Text,
    TextXAlignment = Enum.TextXAlignment.Left
}, SliderCard)
local TransparencyLabel = New("TextLabel", {
    Size = UDim2.fromOffset(60, 24),
    AnchorPoint = Vector2.new(1, 0),
    Position = UDim2.new(1, -15, 0, 10),
    BackgroundTransparency = 1,
    Text = tostring(math.floor((TransparencyValue-0.06)/0.68*100)).."%",
    Font = Enum.Font.GothamBold,
    TextSize = 11,
    TextColor3 = Theme.Accent,
    TextXAlignment = Enum.TextXAlignment.Right
}, SliderCard)
local Slider = New("TextButton", {
    Size = UDim2.new(1, -30, 0, 8),
    Position = UDim2.new(0, 15, 0, 55),
    BackgroundColor3 = Color3.fromRGB(75, 78, 90),
    BackgroundTransparency = 0.2,
    BorderSizePixel = 0,
    Text = "",
    AutoButtonColor = false
}, SliderCard)
Round(Slider, 99)
local SliderFill = New("Frame", {
    Size = UDim2.new((TransparencyValue-0.06)/0.68, 0, 1, 0),
    BackgroundColor3 = Theme.Accent,
    BorderSizePixel = 0
}, Slider)
Round(SliderFill, 99)
local SliderKnob = New("Frame", {
    Size = UDim2.fromOffset(18, 18),
    AnchorPoint = Vector2.new(0.5,0.5),
    Position = UDim2.new((TransparencyValue-0.06)/0.68, 0, 0.5, 0),
    BackgroundColor3 = Theme.White,
    BorderSizePixel = 0
}, Slider)
Round(SliderKnob, 99)
local SliderDragging = false
local function SetTransparencyFromX(x)
    local minX = Slider.AbsolutePosition.X
    local maxX = minX + Slider.AbsoluteSize.X
    local alpha = math.clamp((x - minX) / math.max(1, Slider.AbsoluteSize.X), 0, 1)
    TransparencyValue = 0.06 + alpha * 0.68
    TransparencyLabel.Text = tostring(math.floor(alpha * 100)).."%"
    Tween(SliderFill, 0.1, {Size = UDim2.new(alpha, 0, 1, 0)})
    Tween(SliderKnob, 0.1, {Position = UDim2.new(alpha, 0, 0.5, 0)})
    RefreshGlass()
end
Slider.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        SliderDragging = true
        SetTransparencyFromX(input.Position.X)
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if SliderDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        SetTransparencyFromX(input.Position.X)
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        SliderDragging = false
    end
end)

CreateSection(SettingsScroll, "主题", "选择不同玻璃主题")
local ThemeGrid = New("Frame", {
    Size = UDim2.new(1, 0, 0, 135),
    BackgroundTransparency = 1
}, SettingsScroll)
New("UIGridLayout", {
    CellSize = UDim2.new(0.48, 0, 0, 54),
    CellPadding = UDim2.new(0,8,0,8),
    SortOrder = Enum.SortOrder.LayoutOrder
}, ThemeGrid)
local ThemePresets = {
    {Name="Obsidian", Background=Color3.fromRGB(30,34,45), Accent=Color3.fromRGB(115,165,255)},
    {Name="Glacier",  Background=Color3.fromRGB(8,18,24),  Accent=Color3.fromRGB(88,220,255)},
    {Name="Violet",   Background=Color3.fromRGB(25,10,40), Accent=Color3.fromRGB(185,130,255)},
    {Name="Silver",   Background=Color3.fromRGB(25,25,28), Accent=Color3.fromRGB(225,225,235)}
}
for index, preset in ipairs(ThemePresets) do
    local btn = New("TextButton", {
        BackgroundColor3 = preset.Background,
        BackgroundTransparency = 0.08,
        BorderSizePixel = 0,
        Text = preset.Name,
        Font = Enum.Font.GothamMedium,
        TextSize = 11,
        TextColor3 = Theme.White,
        AutoButtonColor = false,
        LayoutOrder = index
    }, ThemeGrid)
    Round(btn, 14)
    local dot = New("Frame", {
        Size = UDim2.fromOffset(8,8),
        AnchorPoint = Vector2.new(0,0.5),
        Position = UDim2.new(0, 10, 0.5, 0),
        BackgroundColor3 = preset.Accent,
        BorderSizePixel = 0
    }, btn)
    Round(dot, 99)
    btn.Activated:Connect(function()
        Theme.Background = preset.Background
        Theme.Accent = preset.Accent
        LogoHolder.BackgroundColor3 = Theme.Accent
        RefreshGlass()
        -- 更新滑块颜色、导航高亮
        ShineGradient.Color = ColorSequence.new{
            ColorSequenceKeypoint.new(0, Theme.GlassHighlight),
            ColorSequenceKeypoint.new(0.22, Theme.Accent),
            ColorSequenceKeypoint.new(0.55, Theme.GlassHighlight),
            ColorSequenceKeypoint.new(1, Theme.GlassHighlight)
        }
        for _, page in pairs(Pages) do
            local scroll = page:FindFirstChild("Scroll")
            if scroll then
                scroll.ScrollBarImageColor3 = Theme.Accent
            end
        end
        for name, button in pairs(NavigationButtons) do
            if button:GetAttribute("Active") then
                button.BackgroundColor3 = Theme.Accent
            end
        end
    end)
    btn.MouseEnter:Connect(function()
        Tween(btn, 0.18, {BackgroundTransparency = 0})
    end)
    btn.MouseLeave:Connect(function()
        Tween(btn, 0.18, {BackgroundTransparency = 0.08})
    end)
end

--==================================================
-- 页面切换逻辑
--==================================================
local function SelectNav(key)
    for name, button in pairs(NavigationButtons) do
        local active = (name == key)
        button:SetAttribute("Active", active)
        if active then
            Tween(button, 0.2, {BackgroundColor3 = Theme.Accent, BackgroundTransparency = 0.16})
        else
            Tween(button, 0.2, {BackgroundColor3 = Theme.Background, BackgroundTransparency = 1})
        end
    end
end

local function SwitchPage(key)
    local Page = Pages[key]
    if not Page or Page == CurrentPage then return end
    if CurrentPage then
        local oldPage = CurrentPage
        Tween(oldPage, 0.16, {GroupTransparency = 1, Position = UDim2.new(0,18,0,12)}):Completed:Connect(function()
            oldPage.Visible = false
        end)
    end
    Page.Visible = true
    Page.Position = UDim2.new(0,18,0,12)
    Page.GroupTransparency = 1
    Tween(Page, 0.28, {GroupTransparency = 0, Position = UDim2.new(0,12,0,12)})
    CurrentPage = Page
    SelectNav(key)
end

HomeButton.Activated:Connect(function() SwitchPage("Home") end)
AimButton.Activated:Connect(function() SwitchPage("Aim") end)
TrackButton.Activated:Connect(function() SwitchPage("Track") end)
VisualButton.Activated:Connect(function() SwitchPage("Visual") end)
PlayersButton.Activated:Connect(function() SwitchPage("Players") end)
ScriptsButton.Activated:Connect(function() SwitchPage("Scripts") end)
ToolsButton.Activated:Connect(function() SwitchPage("Tools") end)
AboutButton.Activated:Connect(function() SwitchPage("About") end)
AuthorButton.Activated:Connect(function() SwitchPage("Author") end)
SettingsButton.Activated:Connect(function() SwitchPage("Settings") end)

--==================================================
-- 拖拽主窗口
--==================================================
local Dragging, DragStart, StartPos = false, nil, nil
Header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        Dragging = true
        DragStart = input.Position
        StartPos = MainGroup.Position
    end
end)
Header.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        Dragging = false
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if Dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local Delta = input.Position - DragStart
        MainGroup.Position = UDim2.new(
            StartPos.X.Scale, StartPos.X.Offset + Delta.X,
            StartPos.Y.Scale, StartPos.Y.Offset + Delta.Y
        )
    end
end)

--==================================================
-- 最小化及恢复，TY 长按拖动
--==================================================
local Mini = New("TextButton", {
    Name = "Mini",
    AnchorPoint = Vector2.new(0.5,0.5),
    Position = UDim2.fromScale(0.5, 0.84),
    Size = UDim2.fromOffset(74, 42),
    BackgroundColor3 = Theme.Background,
    BackgroundTransparency = 0.12,
    BorderSizePixel = 0,
    Text = "TY",
    Font = Enum.Font.GothamBold,
    TextSize = 14,
    TextColor3 = Theme.White,
    AutoButtonColor = false,
    Visible = false,
    ZIndex = 100
}, ScreenGui)
Round(Mini, 18)
Stroke(Mini, Theme.Accent, 0.4, 1)
New("UIGradient", {
    Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Theme.Accent),
        ColorSequenceKeypoint.new(1, Theme.Background)
    },
    Rotation = 90
}, Mini)

local OpenPos = UDim2.fromScale(0.5, 0.5)
local ClosePos = UDim2.fromScale(0.5, 0.56)
local Minimized = false
local function Minimize()
    if Minimized then return end
    Minimized = true
    Tween(MainGroup, 0.22, {GroupTransparency = 1, Position = ClosePos}):Completed:Connect(function()
        MainGroup.Visible = false
        Mini.Visible = true
        Mini.BackgroundTransparency = 1
        Tween(Mini, 0.22, {BackgroundTransparency = 0.12})
    end)
end
local function Restore()
    if not Minimized then return end
    Minimized = false
    Tween(Mini, 0.16, {BackgroundTransparency = 1}):Completed:Connect(function()
        Mini.Visible = false
        MainGroup.Visible = true
        MainGroup.Position = ClosePos
        MainGroup.GroupTransparency = 1
        Tween(MainGroup, 0.28, {Position = OpenPos, GroupTransparency = 0})
    end)
end
MinButton.Activated:Connect(Minimize)

-- 长按拖动逻辑
local MiniDragging = false
local MiniPressed = false
local MiniDragStart, MiniStartPos = nil, nil
local LONG_PRESS = 0.45
local function IsMouseOrTouch(input)
    return (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch)
end
Mini.InputBegan:Connect(function(input)
    if not IsMouseOrTouch(input) then return end
    MiniPressed = true
    MiniDragging = false
    MiniDragStart = input.Position
    MiniStartPos = Mini.Position
    task.delay(LONG_PRESS, function()
        if MiniPressed and Mini.Visible then
            MiniDragging = true
            Tween(Mini, 0.15, {Size = UDim2.fromOffset(82, 46)})
            Tween(Mini, 0.15, {BackgroundTransparency = 0.02})
        end
    end)
end)
UserInputService.InputChanged:Connect(function(input)
    if not MiniDragging then return end
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        local Delta = input.Position - MiniDragStart
        local Camera = workspace.CurrentCamera
        if Camera then
            local View = Camera.ViewportSize
            local NewX = MiniStartPos.X.Offset + Delta.X
            local NewY = MiniStartPos.Y.Offset + Delta.Y
            local HalfW = Mini.AbsoluteSize.X/2
            local HalfH = Mini.AbsoluteSize.Y/2
            local MinX = -View.X/2 + HalfW
            local MaxX = View.X/2 - HalfW
            local MinY = -View.Y/2 + HalfH
            local MaxY = View.Y/2 - HalfH
            NewX = math.clamp(NewX, MinX, MaxX)
            NewY = math.clamp(NewY, MinY, MaxY)
            Mini.Position = UDim2.new(0.5, NewX, 0.5, NewY)
        end
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if not IsMouseOrTouch(input) then return end
    local wasDragging = MiniDragging
    MiniPressed = false
    MiniDragging = false
    Tween(Mini, 0.15, {Size = UDim2.fromOffset(74, 42), BackgroundTransparency = 0.12})
    if not wasDragging and Minimized then
        Restore()
    end
end)

-- 关闭按钮功能
CloseButton.Activated:Connect(function()
    Tween(MainGroup, 0.22, {GroupTransparency = 1, Position = ClosePos}):Completed:Connect(function()
        ScreenGui:Destroy()
    end)
end)

-- 初始状态: 显示 Home 页
for name, button in pairs(NavigationButtons) do
    button:SetAttribute("Active", false)
end
SwitchPage("Home")

-- 开场动画
MainGroup.Position = UDim2.fromScale(0.5, 0.54)
MainGroup.GroupTransparency = 1
task.wait(0.05)
Tween(MainGroup, 0.55, {Position = UDim2.fromScale(0.5, 0.5), GroupTransparency = 0}, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)

-- 循环 Logo 呼吸效果
task.spawn(function()
    while ScreenGui and ScreenGui.Parent do
        Tween(LogoHolder, 2.2, {BackgroundTransparency = 0.03}, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut).Completed:Wait()
        Tween(LogoHolder, 2.2, {BackgroundTransparency = 0.16}, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut).Completed:Wait()
    end
end)

print("[TY HUB] Liquid Glass UI 加载完成.")
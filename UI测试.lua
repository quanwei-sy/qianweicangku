--// TY HUB • Liquid Glass UI
--// Roblox LocalScript
--// UI only / feature callbacks are separated from UI

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

--==================================================
-- Cleanup
--==================================================

local OLD = PlayerGui:FindFirstChild("TY_HUB_LiquidGlass")
if OLD then
	OLD:Destroy()
end

--==================================================
-- Basic helpers
--==================================================

local function New(className, properties, parent)
	local obj = Instance.new(className)

	for property, value in pairs(properties or {}) do
		obj[property] = value
	end

	obj.Parent = parent
	return obj
end

local function Tween(object, duration, properties, style, direction)
	local info = TweenInfo.new(
		duration or 0.25,
		style or Enum.EasingStyle.Quint,
		direction or Enum.EasingDirection.Out
	)

	local tween = TweenService:Create(object, info, properties)
	tween:Play()

	return tween
end

local function Round(object, radius)
	local corner = New("UICorner", {
		CornerRadius = UDim.new(0, radius or 16)
	}, object)

	return corner
end

local function Stroke(object, color, transparency, thickness)
	return New("UIStroke", {
		Color = color or Color3.new(1, 1, 1),
		Transparency = transparency or 0.8,
		Thickness = thickness or 1
	}, object)
end

local function Mix(a, b, amount)
	return Color3.new(
		a.R + (b.R - a.R) * amount,
		a.G + (b.G - a.G) * amount,
		a.B + (b.B - a.B) * amount
	)
end

--==================================================
-- Theme
--==================================================

local Theme = {
	Background = Color3.fromRGB(10, 12, 18),
	Accent = Color3.fromRGB(111, 154, 255),
	Text = Color3.fromRGB(245, 247, 255),
	SubText = Color3.fromRGB(165, 172, 190),
	White = Color3.fromRGB(255, 255, 255),
}

local TransparencyValue = 0.22

-- Every glass object gets registered here
local GlassObjects = {}

local function RegisterGlass(object, offset)
	GlassObjects[object] = offset or 0
	return object
end

local function RefreshGlass()
	for object, offset in pairs(GlassObjects) do
		if object and object.Parent then
			object.BackgroundColor3 = Theme.Background
			object.BackgroundTransparency = math.clamp(
				TransparencyValue + offset,
				0,
				0.92
			)
		end
	end
end

local function GetAccent()
	return Theme.Accent
end

--==================================================
-- ScreenGui
--==================================================

local ScreenGui = New("ScreenGui", {
	Name = "TY_HUB_LiquidGlass",
	ResetOnSpawn = false,
	IgnoreGuiInset = true,
	DisplayOrder = 9999,
	ZIndexBehavior = Enum.ZIndexBehavior.Global
}, PlayerGui)

--==================================================
-- Main CanvasGroup
--==================================================

local MainGroup = New("CanvasGroup", {
	Name = "MainGroup",
	AnchorPoint = Vector2.new(0.5, 0.5),
	Position = UDim2.fromScale(0.5, 0.5),
	Size = UDim2.fromScale(0.88, 0.76),
	BackgroundTransparency = 1,
	GroupTransparency = 1
}, ScreenGui)

local MainSizeLimit = New("UISizeConstraint", {
	MinSize = Vector2.new(330, 380),
	MaxSize = Vector2.new(980, 700)
}, MainGroup)

--==================================================
-- Shadow layer
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
-- Main background
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

local MainStroke = Stroke(
	Main,
	Color3.fromRGB(255, 255, 255),
	0.82,
	1.1
)

RegisterGlass(Main, 0)

--==================================================
-- Liquid glass shine
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
	Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(255,255,255)),
		ColorSequenceKeypoint.new(0.22, Theme.Accent),
		ColorSequenceKeypoint.new(0.55, Color3.fromRGB(255,255,255)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(255,255,255))
	}),
	Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.97),
		NumberSequenceKeypoint.new(0.25, 0.88),
		NumberSequenceKeypoint.new(0.5, 0.96),
		NumberSequenceKeypoint.new(1, 1)
	}),
	Rotation = 15
}, Shine)

task.spawn(function()
	while Shine and Shine.Parent do
		Tween(
			ShineGradient,
			4.5,
			{Offset = Vector2.new(1.2, 0)},
			Enum.EasingStyle.Sine,
			Enum.EasingDirection.InOut
		).Completed:Wait()

		ShineGradient.Offset = Vector2.new(-1.2, 0)
	end
end)

--==================================================
-- Header
--==================================================

local Header = New("Frame", {
	Name = "Header",
	Size = UDim2.new(1, -32, 0, 64),
	Position = UDim2.new(0, 16, 0, 14),
	BackgroundTransparency = 1,
	BorderSizePixel = 0,
	ZIndex = 10
}, Main)

-- TY Logo
local LogoHolder = New("Frame", {
	Name = "LogoHolder",
	Size = UDim2.fromOffset(48, 48),
	Position = UDim2.new(0, 0, 0.5, -24),
	BackgroundColor3 = Theme.Accent,
	BackgroundTransparency = 0.12,
	BorderSizePixel = 0
}, Header)

Round(LogoHolder, 15)

Stroke(
	LogoHolder,
	Color3.fromRGB(255,255,255),
	0.7,
	1
)

local LogoGradient = New("UIGradient", {
	Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(255,255,255)),
		ColorSequenceKeypoint.new(0.5, Theme.Accent),
		ColorSequenceKeypoint.new(1, Mix(Theme.Accent, Color3.new(0,0,0), 0.35))
	}),
	Rotation = 135
}, LogoHolder)

local Logo = New("TextLabel", {
	Size = UDim2.fromScale(1,1),
	BackgroundTransparency = 1,
	Text = "TY",
	Font = Enum.Font.GothamBold,
	TextSize = 17,
	TextColor3 = Color3.fromRGB(255,255,255),
	ZIndex = 11
}, LogoHolder)

local Brand = New("TextLabel", {
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

local Version = New("TextLabel", {
	Size = UDim2.new(0, 260, 0, 20),
	Position = UDim2.new(0, 63, 0, 32),
	BackgroundTransparency = 1,
	Text = "LIQUID GLASS EDITION",
	Font = Enum.Font.GothamMedium,
	TextSize = 10,
	TextColor3 = Theme.SubText,
	TextXAlignment = Enum.TextXAlignment.Left,
	ZIndex = 11
}, Header)

--==================================================
-- Window buttons
--==================================================

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

local function ButtonHover(button, normalTransparency)
	button.MouseEnter:Connect(function()
		Tween(button, 0.18, {
			BackgroundTransparency = math.max(0, normalTransparency - 0.12)
		})
	end)

	button.MouseLeave:Connect(function()
		Tween(button, 0.18, {
			BackgroundTransparency = normalTransparency
		})
	end)
end

ButtonHover(CloseButton, 0.14)
ButtonHover(MinButton, 0.88)

--==================================================
-- Body
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
-- Sidebar
--==================================================

local Sidebar = New("Frame", {
	Name = "Sidebar",
	Size = UDim2.new(0, 178, 1, 0),
	BackgroundColor3 = Theme.Background,
	BackgroundTransparency = TransparencyValue + 0.09,
	BorderSizePixel = 0,
	ZIndex = 6
}, Body)

Round(Sidebar, 23)

RegisterGlass(Sidebar, 0.09)

Stroke(
	Sidebar,
	Color3.fromRGB(255,255,255),
	0.91,
	1
)

local SidebarPadding = New("UIPadding", {
	PaddingTop = UDim.new(0, 14),
	PaddingLeft = UDim.new(0, 12),
	PaddingRight = UDim.new(0, 12),
	PaddingBottom = UDim.new(0, 14)
}, Sidebar)

local SidebarList = New("UIListLayout", {
	FillDirection = Enum.FillDirection.Vertical,
	SortOrder = Enum.SortOrder.LayoutOrder,
	Padding = UDim.new(0, 5)
}, Sidebar)

--==================================================
-- Content area
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

Stroke(
	Content,
	Color3.fromRGB(255,255,255),
	0.92,
	1
)

--==================================================
-- Page container
--==================================================

local Pages = {}
local NavigationButtons = {}
local CurrentPage = nil

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
		CanvasSize = UDim2.new(0,0,0,0),
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
-- Components
--==================================================

local function CreateSection(parent, title, description)
	local Holder = New("Frame", {
		Size = UDim2.new(1, 0, 0, 48),
		BackgroundTransparency = 1,
		BorderSizePixel = 0
	}, parent)

	New("TextLabel", {
		Size = UDim2.new(1, 0, 0, 24),
		BackgroundTransparency = 1,
		Text = title,
		Font = Enum.Font.GothamBold,
		TextSize = 14,
		TextColor3 = Theme.Text,
		TextXAlignment = Enum.TextXAlignment.Left
	}, Holder)

	New("TextLabel", {
		Size = UDim2.new(1, 0, 0, 20),
		Position = UDim2.new(0,0,0,25),
		BackgroundTransparency = 1,
		Text = description,
		Font = Enum.Font.Gotham,
		TextSize = 10,
		TextColor3 = Theme.SubText,
		TextXAlignment = Enum.TextXAlignment.Left
	}, Holder)

	return Holder
end

local function CreateCard(parent, height)
	local Card = New("Frame", {
		Size = UDim2.new(1, 0, 0, height or 70),
		BackgroundColor3 = Theme.Background,
		BackgroundTransparency = TransparencyValue + 0.10,
		BorderSizePixel = 0
	}, parent)

	Round(Card, 18)

	RegisterGlass(Card, 0.10)

	Stroke(
		Card,
		Color3.fromRGB(255,255,255),
		0.93,
		1
	)

	return Card
end

--==================================================
-- Feature callbacks
--==================================================

local FeatureState = {
	Aim = false,
	Track = false,
	FOV = true,
	Smooth = true
}

local FeatureCallbacks = {

	Aim = function(enabled)
		-- 在这里接你自己的自瞄 UI/游戏逻辑
		print("[TY HUB] Aim:", enabled)
	end,

	Track = function(enabled)
		-- 在这里接你自己的追踪 UI/游戏逻辑
		print("[TY HUB] Track:", enabled)
	end,

	FOV = function(enabled)
		print("[TY HUB] FOV:", enabled)
	end,

	Smooth = function(enabled)
		print("[TY HUB] Smooth:", enabled)
	end
}

--==================================================
-- Toggle
--==================================================

local function CreateToggle(parent, title, description, key)
	local Card = CreateCard(parent, 72)

	local TextArea = New("Frame", {
		Size = UDim2.new(1, -92, 1, 0),
		BackgroundTransparency = 1
	}, Card)

	New("TextLabel", {
		Size = UDim2.new(1, 0, 0, 23),
		Position = UDim2.new(0, 15, 0, 13),
		BackgroundTransparency = 1,
		Text = title,
		Font = Enum.Font.GothamMedium,
		TextSize = 13,
		TextColor3 = Theme.Text,
		TextXAlignment = Enum.TextXAlignment.Left
	}, TextArea)

	New("TextLabel", {
		Size = UDim2.new(1, 0, 0, 20),
		Position = UDim2.new(0, 15, 0, 37),
		BackgroundTransparency = 1,
		Text = description,
		Font = Enum.Font.Gotham,
		TextSize = 10,
		TextColor3 = Theme.SubText,
		TextXAlignment = Enum.TextXAlignment.Left
	}, TextArea)

	local Toggle = New("TextButton", {
		Size = UDim2.fromOffset(50, 28),
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -15, 0.5, 0),
		BackgroundColor3 = Color3.fromRGB(75, 78, 90),
		BackgroundTransparency = 0.15,
		BorderSizePixel = 0,
		Text = "",
		AutoButtonColor = false
	}, Card)

	Round(Toggle, 20)

	local Knob = New("Frame", {
		Size = UDim2.fromOffset(22, 22),
		Position = UDim2.new(0, 3, 0.5, -11),
		BackgroundColor3 = Color3.fromRGB(255,255,255),
		BorderSizePixel = 0
	}, Toggle)

	Round(Knob, 50)

	local State = FeatureState[key] == true

	local function Refresh()
		if State then
			Tween(Toggle, 0.2, {
				BackgroundColor3 = GetAccent()
			})

			Tween(Knob, 0.2, {
				Position = UDim2.new(1, -25, 0.5, -11)
			})
		else
			Tween(Toggle, 0.2, {
				BackgroundColor3 = Color3.fromRGB(75,78,90)
			})

			Tween(Knob, 0.2, {
				Position = UDim2.new(0, 3, 0.5, -11)
			})
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
-- Navigation
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

local HomeButton = CreateNavButton("Home", "主页", "⌂", 1)
local AimButton = CreateNavButton("Aim", "自瞄", "◎", 2)
local TrackButton = CreateNavButton("Track", "子追", "◈", 3)
local ScriptsButton = CreateNavButton("Scripts", "脚本中心", "▣", 4)
local AboutButton = CreateNavButton("About", "关于", "?", 5)
local AuthorButton = CreateNavButton("Author", "作者信息", "•", 6)
local SettingsButton = CreateNavButton("Settings", "设置", "⚙", 7)

--==================================================
-- Pages
--==================================================

local HomePage, HomeScroll = CreatePage(
	"Home",
	"欢迎使用 TY HUB",
	"Liquid Glass interface / Client UI"
)

local AimPage, AimScroll = CreatePage(
	"Aim",
	"自瞄",
	"Target assistance interface"
)

local TrackPage, TrackScroll = CreatePage(
	"Track",
	"子追",
	"Target tracking interface"
)

local ScriptsPage, ScriptsScroll = CreatePage(
	"Scripts",
	"脚本中心",
	"你的功能模块中心"
)

local AboutPage, AboutScroll = CreatePage(
	"About",
	"关于 TY HUB",
	"版本与界面信息"
)

local AuthorPage, AuthorScroll = CreatePage(
	"Author",
	"作者信息",
	"Project information"
)

local SettingsPage, SettingsScroll = CreatePage(
	"Settings",
	"界面设置",
	"透明度、背景与动态效果"
)

--==================================================
-- HOME
--==================================================

CreateSection(
	HomeScroll,
	"Dashboard",
	"TY HUB 当前运行状态"
)

local StatusCard = CreateCard(HomeScroll, 105)

local StatusDot = New("Frame", {
	Size = UDim2.fromOffset(10, 10),
	Position = UDim2.new(0, 18, 0, 20),
	BackgroundColor3 = Color3.fromRGB(80, 230, 160),
	BorderSizePixel = 0
}, StatusCard)

Round(StatusDot, 99)

New("TextLabel", {
	Size = UDim2.new(1, -55, 0, 25),
	Position = UDim2.new(0, 38, 0, 10),
	BackgroundTransparency = 1,
	Text = "TY HUB ONLINE",
	Font = Enum.Font.GothamBold,
	TextSize = 14,
	TextColor3 = Theme.Text,
	TextXAlignment = Enum.TextXAlignment.Left
}, StatusCard)

New("TextLabel", {
	Size = UDim2.new(1, -55, 0, 40),
	Position = UDim2.new(0, 38, 0, 35),
	BackgroundTransparency = 1,
	Text = "液态玻璃界面已加载。\n所有动画均通过 Roblox TweenService 驱动。",
	Font = Enum.Font.Gotham,
	TextSize = 10,
	TextColor3 = Theme.SubText,
	TextXAlignment = Enum.TextXAlignment.Left,
	TextWrapped = true
}, StatusCard)

local QuickCard = CreateCard(HomeScroll, 80)

New("TextLabel", {
	Size = UDim2.new(1, -30, 0, 24),
	Position = UDim2.new(0,15,0,12),
	BackgroundTransparency = 1,
	Text = "QUICK ACCESS",
	Font = Enum.Font.GothamBold,
	TextSize = 11,
	TextColor3 = Theme.SubText,
	TextXAlignment = Enum.TextXAlignment.Left
}, QuickCard)

New("TextLabel", {
	Size = UDim2.new(1, -30, 0, 32),
	Position = UDim2.new(0,15,0,34),
	BackgroundTransparency = 1,
	Text = "左侧可以切换功能页面，设置页面可以修改透明度与主题。",
	Font = Enum.Font.Gotham,
	TextSize = 11,
	TextColor3 = Theme.Text,
	TextXAlignment = Enum.TextXAlignment.Left,
	TextWrapped = true
}, QuickCard)

--==================================================
-- AIM
--==================================================

CreateSection(
	AimScroll,
	"自瞄模块",
	"这里是功能 UI 层，具体游戏逻辑通过回调接入。"
)

CreateToggle(
	AimScroll,
	"自瞄",
	"切换自瞄功能状态",
	"Aim"
)

CreateToggle(
	AimScroll,
	"显示 FOV",
	"显示/隐藏辅助范围 UI",
	"FOV"
)

CreateToggle(
	AimScroll,
	"平滑模式",
	"用于控制目标移动过渡感",
	"Smooth"
)

local AimInfo = CreateCard(AimScroll, 90)

New("TextLabel", {
	Size = UDim2.new(1,-30,1,-20),
	Position = UDim2.new(0,15,0,10),
	BackgroundTransparency = 1,
	Text = "功能接口已准备：\nFeatureCallbacks.Aim(enabled)\nFeatureCallbacks.FOV(enabled)\nFeatureCallbacks.Smooth(enabled)",
	Font = Enum.Font.Gotham,
	TextSize = 10,
	TextColor3 = Theme.SubText,
	TextXAlignment = Enum.TextXAlignment.Left,
	TextYAlignment = Enum.TextYAlignment.Center
}, AimInfo)

--==================================================
-- TRACK
--==================================================

CreateSection(
	TrackScroll,
	"子追模块",
	"目标追踪界面的控制入口。"
)

CreateToggle(
	TrackScroll,
	"子追",
	"切换目标追踪状态",
	"Track"
)

local TrackInfo = CreateCard(TrackScroll, 100)

New("TextLabel", {
	Size = UDim2.new(1,-30,1,-20),
	Position = UDim2.new(0,15,0,10),
	BackgroundTransparency = 1,
	Text = "这里没有把具体目标算法硬编码进 UI。\n这样你以后替换游戏逻辑时，不需要重写整个界面。",
	Font = Enum.Font.Gotham,
	TextSize = 10,
	TextColor3 = Theme.SubText,
	TextXAlignment = Enum.TextXAlignment.Left,
	TextWrapped = true
}, TrackInfo)

--==================================================
-- SCRIPTS
--==================================================

CreateSection(
	ScriptsScroll,
	"Script Center",
	"模块化管理功能。"
)

local ScriptNames = {
	{"Main Module", "主功能模块"},
	{"Visual Module", "视觉模块"},
	{"Utility Module", "辅助工具模块"},
	{"Settings Module", "设置模块"}
}

for _, info in ipairs(ScriptNames) do
	local Card = CreateCard(ScriptsScroll, 72)

	New("TextLabel", {
		Size = UDim2.new(1,-110,0,23),
		Position = UDim2.new(0,15,0,11),
		BackgroundTransparency = 1,
		Text = info[1],
		Font = Enum.Font.GothamMedium,
		TextSize = 13,
		TextColor3 = Theme.Text,
		TextXAlignment = Enum.TextXAlignment.Left
	}, Card)

	New("TextLabel", {
		Size = UDim2.new(1,-110,0,20),
		Position = UDim2.new(0,15,0,35),
		BackgroundTransparency = 1,
		Text = info[2],
		Font = Enum.Font.Gotham,
		TextSize = 10,
		TextColor3 = Theme.SubText,
		TextXAlignment = Enum.TextXAlignment.Left
	}, Card)

	local LoadButton = New("TextButton", {
		Size = UDim2.fromOffset(70, 31),
		AnchorPoint = Vector2.new(1,0.5),
		Position = UDim2.new(1,-13,0.5,0),
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

		Tween(LoadButton, 0.18, {
			BackgroundTransparency = 0
		})

		task.delay(0.7, function()
			if LoadButton and LoadButton.Parent then
				LoadButton.Text = old
				Tween(LoadButton, 0.18, {
					BackgroundTransparency = 0.15
				})
			end
		end)
	end)
end

--==================================================
-- ABOUT
--==================================================

CreateSection(
	AboutScroll,
	"TY HUB",
	"Liquid Glass Edition"
)

local AboutCard = CreateCard(AboutScroll, 160)

New("TextLabel", {
	Size = UDim2.new(1,-30,0,35),
	Position = UDim2.new(0,15,0,12),
	BackgroundTransparency = 1,
	Text = "TY HUB",
	Font = Enum.Font.GothamBold,
	TextSize = 24,
	TextColor3 = Theme.Text,
	TextXAlignment = Enum.TextXAlignment.Left
}, AboutCard)

New("TextLabel", {
	Size = UDim2.new(1,-30,0,90),
	Position = UDim2.new(0,15,0,55),
	BackgroundTransparency = 1,
	Text = "采用多层半透明玻璃、圆角、渐变描边、\n动态高光与 Tween 动画组合出的现代化 UI。\n\n界面组件相互独立，方便你继续扩展。",
	Font = Enum.Font.Gotham,
	TextSize = 11,
	TextColor3 = Theme.SubText,
	TextXAlignment = Enum.TextXAlignment.Left,
	TextYAlignment = Enum.TextYAlignment.Top,
	TextWrapped = true
}, AboutCard)

--==================================================
-- AUTHOR
--==================================================

CreateSection(
	AuthorScroll,
	"作者信息",
	"项目资料"
)

local AuthorCard = CreateCard(AuthorScroll, 125)

New("TextLabel", {
	Size = UDim2.new(1,-30,0,25),
	Position = UDim2.new(0,15,0,13),
	BackgroundTransparency = 1,
	Text = "TY HUB",
	Font = Enum.Font.GothamBold,
	TextSize = 15,
	TextColor3 = Theme.Text,
	TextXAlignment = Enum.TextXAlignment.Left
}, AuthorCard)

New("TextLabel", {
	Size = UDim2.new(1,-30,0,72),
	Position = UDim2.new(0,15,0,42),
	BackgroundTransparency = 1,
	Text = "Author: 自定义\nProject: TY HUB\nUI: Liquid Glass\nStatus: Active",
	Font = Enum.Font.Gotham,
	TextSize = 11,
	TextColor3 = Theme.SubText,
	TextXAlignment = Enum.TextXAlignment.Left,
	TextYAlignment = Enum.TextYAlignment.Top
}, AuthorCard)

--==================================================
-- SETTINGS
--==================================================

CreateSection(
	SettingsScroll,
	"透明度",
	"调整玻璃材质的透明程度。"
)

local SliderCard = CreateCard(SettingsScroll, 95)

New("TextLabel", {
	Size = UDim2.new(1,-30,0,24),
	Position = UDim2.new(0,15,0,10),
	BackgroundTransparency = 1,
	Text = "Glass Transparency",
	Font = Enum.Font.GothamMedium,
	TextSize = 12,
	TextColor3 = Theme.Text,
	TextXAlignment = Enum.TextXAlignment.Left
}, SliderCard)

local TransparencyLabel = New("TextLabel", {
	Size = UDim2.fromOffset(60,24),
	AnchorPoint = Vector2.new(1,0),
	Position = UDim2.new(1,-15,0,10),
	BackgroundTransparency = 1,
	Text = "22%",
	Font = Enum.Font.GothamBold,
	TextSize = 11,
	TextColor3 = Theme.Accent,
	TextXAlignment = Enum.TextXAlignment.Right
}, SliderCard)

local Slider = New("TextButton", {
	Size = UDim2.new(1,-30,0,8),
	Position = UDim2.new(0,15,0,55),
	BackgroundColor3 = Color3.fromRGB(75,78,90),
	BackgroundTransparency = 0.2,
	BorderSizePixel = 0,
	Text = "",
	AutoButtonColor = false
}, SliderCard)

Round(Slider, 99)

local SliderFill = New("Frame", {
	Size = UDim2.new(0.22,0,1,0),
	BackgroundColor3 = Theme.Accent,
	BorderSizePixel = 0
}, Slider)

Round(SliderFill, 99)

local SliderKnob = New("Frame", {
	Size = UDim2.fromOffset(18,18),
	AnchorPoint = Vector2.new(0.5,0.5),
	Position = UDim2.new(0.22,0,0.5,0),
	BackgroundColor3 = Theme.White,
	BorderSizePixel = 0
}, Slider)

Round(SliderKnob, 99)

local SliderDragging = false

local function SetTransparencyFromX(x)
	local minX = Slider.AbsolutePosition.X
	local maxX = minX + Slider.AbsoluteSize.X

	local alpha = math.clamp(
		(x - minX) / math.max(1, Slider.AbsoluteSize.X),
		0,
		1
	)

	TransparencyValue = 0.06 + alpha * 0.68

	TransparencyLabel.Text =
		tostring(math.floor(alpha * 100)) .. "%"

	Tween(SliderFill, 0.1, {
		Size = UDim2.new(alpha,0,1,0)
	})

	Tween(SliderKnob, 0.1, {
		Position = UDim2.new(alpha,0,0.5,0)
	})

	RefreshGlass()
end

Slider.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1
		or input.UserInputType == Enum.UserInputType.Touch then

		SliderDragging = true
		SetTransparencyFromX(input.Position.X)
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if not SliderDragging then
		return
	end

	if input.UserInputType == Enum.UserInputType.MouseMovement
		or input.UserInputType == Enum.UserInputType.Touch then

		SetTransparencyFromX(input.Position.X)
	end
end)

UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1
		or input.UserInputType == Enum.UserInputType.Touch then

		SliderDragging = false
	end
end)

--==================================================
-- Theme picker
--==================================================

CreateSection(
	SettingsScroll,
	"背景颜色",
	"选择不同的玻璃主题。"
)

local ThemeGrid = New("Frame", {
	Size = UDim2.new(1,0,0,135),
	BackgroundTransparency = 1
}, SettingsScroll)

New("UIGridLayout", {
	CellSize = UDim2.new(0.48,0,0,54),
	CellPadding = UDim2.new(0,8,0,8),
	SortOrder = Enum.SortOrder.LayoutOrder
}, ThemeGrid)

local ThemePresets = {
	{
		Name = "Obsidian",
		Background = Color3.fromRGB(10,12,18),
		Accent = Color3.fromRGB(111,154,255)
	},

	{
		Name = "Glacier",
		Background = Color3.fromRGB(8,18,24),
		Accent = Color3.fromRGB(88,220,255)
	},

	{
		Name = "Violet",
		Background = Color3.fromRGB(18,11,25),
		Accent = Color3.fromRGB(185,130,255)
	},

	{
		Name = "Silver",
		Background = Color3.fromRGB(25,25,28),
		Accent = Color3.fromRGB(225,225,235)
	}
}

local function UpdateGradientColors()
	ShineGradient.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(255,255,255)),
		ColorSequenceKeypoint.new(0.22, Theme.Accent),
		ColorSequenceKeypoint.new(0.55, Color3.fromRGB(255,255,255)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(255,255,255))
	})

	LogoGradient.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(255,255,255)),
		ColorSequenceKeypoint.new(0.5, Theme.Accent),
		ColorSequenceKeypoint.new(
			1,
			Mix(Theme.Accent, Color3.new(0,0,0), 0.35)
		)
	})

	for _, button in pairs(NavigationButtons) do
		if button then
			local active = button:GetAttribute("Active")

			if active then
				button.BackgroundColor3 = Theme.Accent
			end
		end
	end
end

local function ApplyTheme(background, accent)
	Theme.Background = background
	Theme.Accent = accent

	LogoHolder.BackgroundColor3 = Theme.Accent

	RefreshGlass()

	UpdateGradientColors()

	for _, page in pairs(Pages) do
		local scroll = page:FindFirstChild("Scroll")

		if scroll then
			scroll.ScrollBarImageColor3 = Theme.Accent
		end
	end

	for _, button in pairs(NavigationButtons) do
		if button and button:GetAttribute("Active") then
			button.BackgroundColor3 = Theme.Accent
		end
	end
end

for index, preset in ipairs(ThemePresets) do
	local Button = New("TextButton", {
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

	Round(Button, 14)

	local SmallAccent = New("Frame", {
		Size = UDim2.fromOffset(8,8),
		AnchorPoint = Vector2.new(0,0.5),
		Position = UDim2.new(0,10,0.5,0),
		BackgroundColor3 = preset.Accent,
		BorderSizePixel = 0
	}, Button)

	Round(SmallAccent,99)

	Button.Activated:Connect(function()
		ApplyTheme(
			preset.Background,
			preset.Accent
		)
	end)

	Button.MouseEnter:Connect(function()
		Tween(Button,0.18,{
			BackgroundTransparency = 0
		})
	end)

	Button.MouseLeave:Connect(function()
		Tween(Button,0.18,{
			BackgroundTransparency = 0.08
		})
	end)
end

--==================================================
-- Navigation system
--==================================================

local function SelectNavigation(key)
	for name, button in pairs(NavigationButtons) do
		local active = name == key

		button:SetAttribute("Active", active)

		if active then
			Tween(button, 0.2, {
				BackgroundColor3 = Theme.Accent,
				BackgroundTransparency = 0.16
			})
		else
			Tween(button, 0.2, {
				BackgroundColor3 = Theme.Background,
				BackgroundTransparency = 1
			})
		end
	end
end

local function SwitchPage(key)
	local Page = Pages[key]

	if not Page then
		return
	end

	if CurrentPage == Page then
		return
	end

	if CurrentPage then
		local OldPage = CurrentPage

		Tween(OldPage,0.16,{
			GroupTransparency = 1,
			Position = UDim2.new(0,18,0,12)
		}).Completed:Connect(function()
			if OldPage then
				OldPage.Visible = false
			end
		end)
	end

	Page.Visible = true
	Page.Position = UDim2.new(0,18,0,12)
	Page.GroupTransparency = 1

	Tween(Page,0.28,{
		GroupTransparency = 0,
		Position = UDim2.new(0,12,0,12)
	})

	CurrentPage = Page

	SelectNavigation(key)
end

HomeButton.Activated:Connect(function()
	SwitchPage("Home")
end)

AimButton.Activated:Connect(function()
	SwitchPage("Aim")
end)

TrackButton.Activated:Connect(function()
	SwitchPage("Track")
end)

ScriptsButton.Activated:Connect(function()
	SwitchPage("Scripts")
end)

AboutButton.Activated:Connect(function()
	SwitchPage("About")
end)

AuthorButton.Activated:Connect(function()
	SwitchPage("Author")
end)

SettingsButton.Activated:Connect(function()
	SwitchPage("Settings")
end)

--==================================================
-- Dragging
--==================================================

local Dragging = false
local DragStart
local StartPosition

Header.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1
		or input.UserInputType == Enum.UserInputType.Touch then

		Dragging = true
		DragStart = input.Position
		StartPosition = MainGroup.Position
	end
end)

Header.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1
		or input.UserInputType == Enum.UserInputType.Touch then

		Dragging = false
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if not Dragging then
		return
	end

	if input.UserInputType == Enum.UserInputType.MouseMovement
		or input.UserInputType == Enum.UserInputType.Touch then

		local Delta = input.Position - DragStart

		MainGroup.Position = UDim2.new(
			StartPosition.X.Scale,
			StartPosition.X.Offset + Delta.X,
			StartPosition.Y.Scale,
			StartPosition.Y.Offset + Delta.Y
		)
	end
end)

--==================================================
-- Minimize system
--==================================================

local Mini = New("TextButton", {
	Name = "Mini",
	AnchorPoint = Vector2.new(0.5, 0.5),
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

Stroke(
	Mini,
	Theme.Accent,
	0.4,
	1
)

local MiniGradient = New("UIGradient", {
	Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Theme.Accent),
		ColorSequenceKeypoint.new(1, Theme.Background)
	}),
	Rotation = 90
}, Mini)

local OpenPosition = UDim2.fromScale(0.5, 0.5)
local ClosePosition = UDim2.fromScale(0.5, 0.56)

local Minimized = false

local function Minimize()
	if Minimized then
		return
	end

	Minimized = true

	Tween(MainGroup,0.22,{
		GroupTransparency = 1,
		Position = ClosePosition
	}).Completed:Connect(function()
		MainGroup.Visible = false
		Mini.Visible = true

		Mini.BackgroundTransparency = 1

		Tween(Mini,0.22,{
			BackgroundTransparency = 0.12
		})
	end)
end

local function Restore()
	if not Minimized then
		return
	end

	Minimized = false

	Tween(Mini,0.16,{
		BackgroundTransparency = 1
	}).Completed:Connect(function()
		Mini.Visible = false

		MainGroup.Visible = true
		MainGroup.Position = ClosePosition
		MainGroup.GroupTransparency = 1

		Tween(MainGroup,0.28,{
			GroupTransparency = 0,
			Position = OpenPosition
		})
	end)
end

MinButton.Activated:Connect(Minimize)
Mini.Activated:Connect(Restore)

--==================================================
-- Close
--==================================================

CloseButton.Activated:Connect(function()
	Tween(MainGroup,0.22,{
		GroupTransparency = 1,
		Position = ClosePosition
	}).Completed:Connect(function()
		ScreenGui:Destroy()
	end)
end)

--==================================================
-- Initial state
--==================================================

for name, button in pairs(NavigationButtons) do
	button:SetAttribute("Active", false)
end

SwitchPage("Home")

-- initial animation
MainGroup.Position = UDim2.fromScale(0.5, 0.54)
MainGroup.GroupTransparency = 1

task.wait(0.05)

Tween(MainGroup,0.55,{
	Position = UDim2.fromScale(0.5,0.5),
	GroupTransparency = 0
},Enum.EasingStyle.Quint,Enum.EasingDirection.Out)

--==================================================
-- Soft pulse
--==================================================

task.spawn(function()
	while ScreenGui and ScreenGui.Parent do
		Tween(
			LogoHolder,
			2.2,
			{BackgroundTransparency = 0.03},
			Enum.EasingStyle.Sine,
			Enum.EasingDirection.InOut
		).Completed:Wait()

		Tween(
			LogoHolder,
			2.2,
			{BackgroundTransparency = 0.16},
			Enum.EasingStyle.Sine,
			Enum.EasingDirection.InOut
		).Completed:Wait()
	end
end)

print("[TY HUB] Liquid Glass UI loaded.")
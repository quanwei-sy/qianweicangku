--[[]]
    TY HUB
    Author: 权威不是权威
    QQ: 3935754168

    Build note:
    - UI: NOTHING UI source supplied by the user.
    - Core: HSX-compatible Ink Game feature layer.
    - Added utility items inspired by UwU: Anti-AFK, Instant Interact and Lights Out helpers.
    - No anti-cheat bypass / anti-detection implementation is included.
--[]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")
local ProximityPromptService = game:GetService("ProximityPromptService")
local Lighting = game:GetService("Lighting")
local localPlayer = Players.LocalPlayer

MainModule = MainModule or {}
MainModule.ToggleRefs = MainModule.ToggleRefs or {}
MainModule.ToggleGameRequirements = MainModule.ToggleGameRequirements or {}
MainModule.pendingNotifications = MainModule.pendingNotifications or {}
MainModule.guiCreated = false

local function safeCall(fn, ...)
    if type(fn) ~= "function" then
        return false, "not a function"
    end
    return pcall(fn, ...)
end

-- Compatibility no-ops for the legacy HSX feature layer.
local function PlayToggleSound() end
local function PlayErrorSound() end
local function PlayBell() end

local function notifyCompat(title, description, duration)
    title = tostring(title or "TY HUB")
    description = tostring(description or "")
    print("[TY HUB] " .. title .. (description ~= "" and (" | " .. description) or ""))
end

local function loadNothingLibrary()

-- ICON: https://raw.githubusercontent.com/evoincorp/lucideblox/master/src/modules/util/icons.json -

local Twen = game:GetService('TweenService');
local Input = game:GetService('UserInputService');
local TextServ = game:GetService('TextService');
local LocalPlayer = game:GetService('Players').LocalPlayer;
local CoreGui = (gethui and gethui()) or game:FindFirstChild('CoreGui') or LocalPlayer.PlayerGui;
local Icons = (function()
	local p,c = pcall(function()
		local Http = game:HttpGetAsync('https://raw.githubusercontent.com/evoincorp/lucideblox/master/src/modules/util/icons.json');

		local Decode = game:GetService('HttpService'):JSONDecode(Http);

		return Decode['icon'];
	end);

	if p then return c end;

	return nil;
end)() or {};

local ElBlurSource = function()
	local GuiSystem = {}
	local RunService = game:GetService('RunService');
	local CurrentCamera = workspace.CurrentCamera;

	function GuiSystem:Hash()
		return string.reverse(string.gsub(game:GetService('HttpService'):GenerateGUID(false),'..',function(aa)
			return string.reverse(aa)
		end))
	end

	local function Hiter(planePos, planeNormal, rayOrigin, rayDirection)
		local n = planeNormal
		local d = rayDirection
		local v = rayOrigin - planePos

		local num = (n.x*v.x) + (n.y*v.y) + (n.z*v.z)
		local den = (n.x*d.x) + (n.y*d.y) + (n.z*d.z)
		local a = -num / den

		return rayOrigin + (a * rayDirection), a;
	end;

	function GuiSystem.new(frame,NoAutoBackground)
		local Part = Instance.new('Part',workspace);
		local DepthOfField = Instance.new('DepthOfFieldEffect',game:GetService('Lighting'));
		local SurfaceGui = Instance.new('SurfaceGui',Part);
		local BlockMesh = Instance.new("BlockMesh");

		BlockMesh.Parent = Part;

		Part.Material = Enum.Material.Glass;
		Part.Transparency = 1;
		Part.Reflectance = 1;
		Part.CastShadow = false;
		Part.Anchored = true;
		Part.CanCollide = false;
		Part.CanQuery = false;
		Part.CollisionGroup = GuiSystem:Hash();
		Part.Size = Vector3.new(1, 1, 1) * 0.01;
		Part.Color = Color3.fromRGB(0,0,0);

		Twen:Create(Part,TweenInfo.new(1,Enum.EasingStyle.Quint,Enum.EasingDirection.In),{
			Transparency = 0.8;
		}):Play()

		DepthOfField.Enabled = true;
		DepthOfField.FarIntensity = 1;
		DepthOfField.FocusDistance = 0;
		DepthOfField.InFocusRadius = 500;
		DepthOfField.NearIntensity = 1;

		SurfaceGui.AlwaysOnTop = true;
		SurfaceGui.Adornee = Part;
		SurfaceGui.Active = true;
		SurfaceGui.Face = Enum.NormalId.Front;
		SurfaceGui.ZIndexBehavior = Enum.ZIndexBehavior.Global;

		DepthOfField.Name = GuiSystem:Hash();
		Part.Name = GuiSystem:Hash();
		SurfaceGui.Name = GuiSystem:Hash();

		local C4 = {
			Update = nil,
			Collection = SurfaceGui,
			Enabled = true,
			Instances = {
				BlockMesh = BlockMesh,
				Part = Part,
				DepthOfField = DepthOfField,
				SurfaceGui = SurfaceGui,
			},
			Signal = nil
		};

		local Update = function()
			if not C4.Enabled then
				Twen:Create(Part,TweenInfo.new(1,Enum.EasingStyle.Quint),{
					Transparency = 1;
				}):Play()

			end;

			Twen:Create(Part,TweenInfo.new(1,Enum.EasingStyle.Quint,Enum.EasingDirection.Out),{
				Transparency = 0.8;
			}):Play()

			local corner0 = frame.AbsolutePosition;
			local corner1 = corner0 + frame.AbsoluteSize;

			local ray0 = CurrentCamera.ScreenPointToRay(CurrentCamera,corner0.X, corner0.Y, 1);
			local ray1 = CurrentCamera.ScreenPointToRay(CurrentCamera,corner1.X, corner1.Y, 1);

			local planeOrigin = CurrentCamera.CFrame.Position + CurrentCamera.CFrame.LookVector * (0.05 - CurrentCamera.NearPlaneZ);

			local planeNormal = CurrentCamera.CFrame.LookVector;

			local pos0 = Hiter(planeOrigin, planeNormal, ray0.Origin, ray0.Direction);
			local pos1 = Hiter(planeOrigin, planeNormal, ray1.Origin, ray1.Direction);

			pos0 = CurrentCamera.CFrame:PointToObjectSpace(pos0);
			pos1 = CurrentCamera.CFrame:PointToObjectSpace(pos1);

			local size   = pos1 - pos0;
			local center = (pos0 + pos1) / 2;

			BlockMesh.Offset = center
			BlockMesh.Scale  = size / 0.0101;
			Part.CFrame = CurrentCamera.CFrame;

			if not NoAutoBackground then

				local _,updatec = pcall(function()
					local userSettings = UserSettings():GetService("UserGameSettings")
					local qualityLevel = userSettings.SavedQualityLevel.Value

					if qualityLevel < 8 then
						Twen:Create(frame,TweenInfo.new(1),{
							BackgroundTransparency = 0
						}):Play()
					else
						Twen:Create(frame,TweenInfo.new(1),{
							BackgroundTransparency = 0.4
						}):Play()
					end;
				end)

			end
		end

		C4.Update = Update;
		C4.Signal = RunService.RenderStepped:Connect(Update);

		pcall(function()
			C4.Signal2 = CurrentCamera:GetPropertyChangedSignal('CFrame'):Connect(function()
				Part.CFrame = CurrentCamera.CFrame;
			end);
		end)

		C4.Destroy = function()
			C4.Signal:Disconnect();
			C4.Signal2:Disconnect();
			C4.Update = function()

			end;

			Twen:Create(Part,TweenInfo.new(1),{
				Transparency = 1
			}):Play();

			DepthOfField:Destroy();
			Part:Destroy()
		end;

		return C4;
	end;

	return GuiSystem
end;

local ElBlurSource = ElBlurSource();
local Config = function(data,default)
	data = data or {};

	for i,v in next,default do
		data[i] = data[i] or v;
	end;

	return data;
end;

local Library = {};

Library['.'] = '1';
Library['FetchIcon'] = "https://raw.githubusercontent.com/evoincorp/lucideblox/master/src/modules/util/icons.json";

pcall(function()
	Library['Icons'] = game:GetService('HttpService'):JSONDecode(game:HttpGetAsync(Library.FetchIcon))['icons'];
end)

function Library.GradientImage(E : Frame , Color)
	local GLImage = Instance.new("ImageLabel")
	local upd = tick();
	local nextU , Speed , speedy , SIZ = 4 , 5 , -5 , 0.8;
	local nextmain = UDim2.new();
	local rng = Random.new(math.random(10,100000) + math.random(100, 1000) + math.sqrt(tick()));
	local int = 1;
	local TPL = 0.55;

	GLImage.Name = "GLImage"
	GLImage.Parent = E
	GLImage.AnchorPoint = Vector2.new(0.5, 0.5)
	GLImage.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	GLImage.BackgroundTransparency = 1.000
	GLImage.BorderColor3 = Color3.fromRGB(0, 0, 0)
	GLImage.BorderSizePixel = 0
	GLImage.Position = UDim2.new(0.5, 0, 0.5, 0)
	GLImage.Size = UDim2.new(0.800000012, 0, 0.800000012, 0)
	GLImage.SizeConstraint = Enum.SizeConstraint.RelativeYY
	GLImage.ZIndex = E.ZIndex - 1;
	GLImage.Image = "rbxassetid://867619398"
	GLImage.ImageColor3 = Color or Color3.fromRGB(0, 195, 255)
	GLImage.ImageTransparency = 1;

	local str = 'GL_EFFECT_'..tostring(tick());
	game:GetService('RunService'):BindToRenderStep(str,45,function()
		if (tick() - upd) > nextU then
			nextU = rng:NextNumber(1.1,2.5)
			Speed = rng:NextNumber(-6,6)
			speedy = rng:NextNumber(-6,6)
			TPL = rng:NextNumber(0.2,0.8)
			SIZ = rng:NextNumber(0.6,0.9);
			upd = tick();
			int = 1
		else
			speedy = speedy + rng:NextNumber(-0.1,0.1);
			Speed = Speed + rng:NextNumber(-0.1,0.1);

		end;

		nextmain = nextmain:Lerp(UDim2.new(0.5 + (Speed / 24),0,0.5 + (speedy / 24),0) , .025)
		int = int + 0.1

		Twen:Create(GLImage,TweenInfo.new(1),{
			Rotation = GLImage.Rotation + Speed,
			Position = nextmain,
			Size = UDim2.fromScale(SIZ,SIZ),
			ImageTransparency = TPL
		}):Play()
	end)

	return str
end;

function Library.new(config)
	config = Config(config,{
		Title = "UI Library",
		Description = "discord.gg/BH6pE7jesa",
		Keybind = Enum.KeyCode.LeftControl,
		Logo = "http://www.roblox.com/asset/?id=18810965406",
		Size = UDim2.new(0.100000001, 445, 0.100000001, 315)
	});

	local TweenInfo1 = TweenInfo.new(1,Enum.EasingStyle.Quint,Enum.EasingDirection.InOut);
	local TweenInfo2 = TweenInfo.new(0.7,Enum.EasingStyle.Quint,Enum.EasingDirection.InOut);

	local WindowTable = {};
	local ScreenGui = Instance.new("ScreenGui")
	local MainFrame = Instance.new("Frame")
	local UICorner = Instance.new("UICorner")
	local MainDropShadow = Instance.new("ImageLabel")
	local Headers = Instance.new("Frame")
	local Logo = Instance.new("ImageLabel")
	local UICorner_2 = Instance.new("UICorner")
	local Title = Instance.new("TextLabel")
	local UIGradient = Instance.new("UIGradient")
	local Description = Instance.new("TextLabel")
	local UIGradient_2 = Instance.new("UIGradient")
	local BlockFrame1 = Instance.new("Frame")
	local UICorner_3 = Instance.new("UICorner")
	local UIGradient_3 = Instance.new("UIGradient")
	local BlockFrame3 = Instance.new("Frame")
	local UICorner_4 = Instance.new("UICorner")
	local UIGradient_4 = Instance.new("UIGradient")
	local BlockFrame2 = Instance.new("Frame")
	local UICorner_5 = Instance.new("UICorner")
	local UIGradient_5 = Instance.new("UIGradient")
	local TabButtonFrame = Instance.new("Frame")
	local UICorner_6 = Instance.new("UICorner")
	local TabButtons = Instance.new("ScrollingFrame")
	local UIListLayout = Instance.new("UIListLayout")
	local MainTabFrame = Instance.new("Frame")
	local UICorner_7 = Instance.new("UICorner")
	local InputFrame = Instance.new("Frame")

	WindowTable.Tabs = {};
	WindowTable.Dropdown = {};
	WindowTable.WindowToggle = true;
	WindowTable.Keybind = config.Keybind;
	WindowTable.ToggleButton = nil
	
	local ImageButton = Instance.new("ImageButton")

	ImageButton.Parent = MainFrame
	ImageButton.AnchorPoint = Vector2.new(1, 0)
	ImageButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	ImageButton.BackgroundTransparency = 1.000
	ImageButton.BorderColor3 = Color3.fromRGB(0, 0, 0)
	ImageButton.BorderSizePixel = 0
	ImageButton.Position = UDim2.new(0.992500007, 0, 0.00999999978, 0)
	ImageButton.Size = UDim2.new(0.0850000009, 0, 0.0850000009, 0)
	ImageButton.SizeConstraint = Enum.SizeConstraint.RelativeYY
	ImageButton.ZIndex = 50
	ImageButton.Image = "rbxassetid://10002398990"
	ImageButton.ImageTransparency = 1
	
	local HomeIcon = Instance.new("ImageLabel")
	HomeIcon.Parent = ImageButton
	HomeIcon.AnchorPoint = Vector2.new(0.5, 0.5)
	HomeIcon.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	HomeIcon.BorderColor3 = Color3.fromRGB(0, 0, 0)
	HomeIcon.BorderSizePixel = 0
	HomeIcon.Position = UDim2.new(0.5, 0, 0.5, 0)
	HomeIcon.Size = UDim2.new(0.7,0,0.7,0)
	HomeIcon.ZIndex = 49
	HomeIcon.Image = "rbxassetid://7733993211"
	HomeIcon.ScaleType = Enum.ScaleType.Fit
	HomeIcon.ImageTransparency = 1;
	HomeIcon.BackgroundTransparency = 1;
	
	local function Update()
		if WindowTable.WindowToggle then
			Twen:Create(MainFrame,TweenInfo.new(1.5,Enum.EasingStyle.Quint),{BackgroundTransparency = 0.4,Size = config.Size}):Play();
			Twen:Create(MainDropShadow,TweenInfo1,{ImageTransparency = 0.6}):Play();
			Twen:Create(Headers,TweenInfo1,{BackgroundTransparency = 0.5}):Play();
			Twen:Create(Logo,TweenInfo1,{ImageTransparency = 0}):Play();
			Twen:Create(MainFrame,TweenInfo.new(0.5,Enum.EasingStyle.Quint),{Position = UDim2.fromScale(0.5,0.5)}):Play();
			WindowTable.ElBlurUI.Enabled = true;
			
			Twen:Create(BlockFrame1,TweenInfo1,{BackgroundTransparency = 0.8}):Play();
			Twen:Create(BlockFrame2,TweenInfo1,{BackgroundTransparency = 0.8}):Play();
			Twen:Create(BlockFrame3,TweenInfo1,{BackgroundTransparency = 0.8}):Play();
			
			Twen:Create(TabButtonFrame,TweenInfo1,{Position = UDim2.fromScale(0.16,0.215)}):Play();
			Twen:Create(MainTabFrame,TweenInfo1,{Position = UDim2.fromScale(0.658,0.131)}):Play();
			Twen:Create(Description,TweenInfo1,{Position = UDim2.fromScale(0.328,0.071)}):Play();

			Twen:Create(Title,TweenInfo1,{Position = UDim2.fromScale(0.328,0.013)}):Play();
			Twen:Create(Headers,TweenInfo1,{Position = UDim2.fromScale(0.01,0.015)}):Play();

			Twen:Create(ImageButton,TweenInfo.new(0.85,Enum.EasingStyle.Quint,Enum.EasingDirection.InOut),{
				Position = UDim2.new(0.992500007, 0, 0.00999999978, 0),
				Size = UDim2.new(0.0850000009, 0, 0.0850000009, 0),
				ImageTransparency = 0.5,
				AnchorPoint = Vector2.new(1, 0)
			}):Play();
			
			Twen:Create(HomeIcon,TweenInfo.new(0.5),{
				ImageTransparency = 1,
			}):Play()

			ImageButton.Image = "rbxassetid://10002398990"
			
			Twen:Create(UICorner,TweenInfo.new(1),{
				CornerRadius = UDim.new(0, 7)
			}):Play()

		else
			Twen:Create(MainFrame,TweenInfo.new(1,Enum.EasingStyle.Quint),{BackgroundTransparency = 1,Size = UDim2.new(0.085, 10,0.05, 0)}):Play();
			Twen:Create(MainFrame,TweenInfo.new(0.5,Enum.EasingStyle.Quint),{Position = UDim2.new(0.5, 0,0.05, 0)}):Play();
			Twen:Create(MainDropShadow,TweenInfo1,{ImageTransparency = 1}):Play();
			Twen:Create(Headers,TweenInfo1,{BackgroundTransparency = 1}):Play();
			Twen:Create(Logo,TweenInfo1,{ImageTransparency = 1}):Play();
			Twen:Create(TabButtonFrame,TweenInfo1,{Position = UDim2.fromScale(0.16,1.1)}):Play();
			Twen:Create(MainTabFrame,TweenInfo1,{Position = UDim2.fromScale(1.5,0.131)}):Play();
			Twen:Create(Description,TweenInfo1,{Position = UDim2.fromScale(1.5,0.071)}):Play();
			Twen:Create(Headers,TweenInfo1,{Position = UDim2.fromScale(0.01,-0.2)}):Play();

			Twen:Create(UICorner,TweenInfo.new(1),{
				CornerRadius = UDim.new(0.1,0)
			}):Play()
			
			Twen:Create(ImageButton,TweenInfo1,{
				Position = UDim2.new(0.5, 0, 0.5, 0),
				Size = UDim2.new(1,0,1,0),
				ImageTransparency = 1,
				AnchorPoint = Vector2.new(0.5,0.5)
			}):Play();
			
			Twen:Create(HomeIcon,TweenInfo.new(1),{
				ImageTransparency = 0.5,
			}):Play()
			
			
			Twen:Create(Title,TweenInfo1,{Position = UDim2.fromScale(1,0.071)}):Play();

			
			Twen:Create(BlockFrame1,TweenInfo1,{BackgroundTransparency = 1}):Play();
			Twen:Create(BlockFrame2,TweenInfo1,{BackgroundTransparency = 1}):Play();
			Twen:Create(BlockFrame3,TweenInfo1,{BackgroundTransparency = 1}):Play();

			WindowTable.ElBlurUI.Enabled = false;
		end;

		WindowTable.Dropdown:Close()
		if WindowTable.ToggleButton then
			WindowTable.ToggleButton();
		end;

		task.delay(1,WindowTable.ElBlurUI.Update)
	end;

	Twen:Create(ImageButton,TweenInfo1,{
		ImageTransparency = 0.5
	}):Play()

	ImageButton.MouseButton1Click:Connect(function()
		WindowTable.WindowToggle = not WindowTable.WindowToggle
		Update()
	end)

	Input.InputBegan:Connect(function(io)
		if io.KeyCode == WindowTable.Keybind then
			WindowTable.WindowToggle = not WindowTable.WindowToggle
			Update()
		end
	end)

	ScreenGui.Parent = CoreGui;
	ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global;
	ScreenGui.ResetOnSpawn = false;
	ScreenGui.IgnoreGuiInset = true;
	ScreenGui.Name = "RobloxGameGui";

	MainFrame.Name = "MainFrame"
	MainFrame.Parent = ScreenGui
	MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
	MainFrame.BackgroundColor3 = Color3.fromRGB(17, 17, 17)
	MainFrame.BackgroundTransparency = 1
	MainFrame.BorderColor3 = Color3.fromRGB(0, 0, 0)
	MainFrame.BorderSizePixel = 0
	MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
	MainFrame.Size = UDim2.fromOffset(config.Size.X.Offset,config.Size.Y.Offset)
	MainFrame.Active = true;
	MainFrame.ClipsDescendants = true;
	
	WindowTable.AddEffect = function(color)
		Library.GradientImage(MainFrame,color)
	end

	Twen:Create(MainFrame,TweenInfo1,{BackgroundTransparency = 0.4,Size = config.Size}):Play();

	WindowTable.ElBlurUI = ElBlurSource.new(MainFrame);

	UICorner.CornerRadius = UDim.new(0, 7)
	UICorner.Parent = MainFrame

	MainDropShadow.Name = "MainDropShadow"
	MainDropShadow.Parent = MainFrame
	MainDropShadow.AnchorPoint = Vector2.new(0.5, 0.5)
	MainDropShadow.BackgroundTransparency = 1.000
	MainDropShadow.BorderSizePixel = 0
	MainDropShadow.Position = UDim2.new(0.5, 0, 0.5, 0)
	MainDropShadow.Size = UDim2.new(1, 47, 1, 47)
	MainDropShadow.ZIndex = 0
	MainDropShadow.Image = "rbxassetid://6015897843"
	MainDropShadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
	MainDropShadow.ImageTransparency = 1
	MainDropShadow.ScaleType = Enum.ScaleType.Slice
	MainDropShadow.SliceCenter = Rect.new(49, 49, 450, 450)
	MainDropShadow.Rotation = 0.0001;
	
	Twen:Create(MainDropShadow,TweenInfo2,{ImageTransparency = 0.6}):Play();

	Headers.Name = "Headers"
	Headers.Parent = MainFrame
	Headers.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
	Headers.BackgroundTransparency = 1
	Headers.BorderColor3 = Color3.fromRGB(0, 0, 0)
	Headers.BorderSizePixel = 0
	Headers.ClipsDescendants = true
	Headers.Position = UDim2.new(0.0100000743, 0, 0.015, 0)
	Headers.Size = UDim2.new(0.300000012, 0, 0.178419471, 0)
	Headers.ZIndex = 3
	Twen:Create(Headers,TweenInfo2,{BackgroundTransparency = 0.5}):Play();

	Logo.Name = "Logo"
	Logo.Parent = Headers
	Logo.Active = true
	Logo.AnchorPoint = Vector2.new(0.5, 0.5)
	Logo.BackgroundColor3 = Color3.fromRGB(255, 0, 4)
	Logo.BackgroundTransparency = 1.000
	Logo.BorderColor3 = Color3.fromRGB(0, 0, 0)
	Logo.BorderSizePixel = 0
	Logo.Position = UDim2.new(0.5, 0, 0.5, 0)
	Logo.Size = UDim2.new(0.949999988, 0, 0.949999988, 0)
	Logo.ZIndex = 4
	Logo.Image = config.Logo;
	Logo.ScaleType = Enum.ScaleType.Crop
	Logo.ImageTransparency = 1;

	Twen:Create(Logo,TweenInfo2,{ImageTransparency = 0}):Play();

	UICorner_2.CornerRadius = UDim.new(0, 15)
	UICorner_2.Parent = Headers
	Twen:Create(UICorner_2,TweenInfo2,{CornerRadius = UDim.new(0, 4)}):Play();

	Title.Name = "Title"
	Title.Parent = MainFrame
	Title.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	Title.BackgroundTransparency = 1.000
	Title.BorderColor3 = Color3.fromRGB(0, 0, 0)
	Title.BorderSizePixel = 0
	Title.Position = UDim2.new(0.327570528, 0, 0.0126646794, 0)
	Title.Size = UDim2.new(0.671064615, 0, 0.0518743545, 0)
	Title.Font = Enum.Font.GothamBold
	Title.Text = config.Title
	Title.TextColor3 = Color3.fromRGB(255, 255, 255)
	Title.TextScaled = true
	Title.TextSize = 14.000
	Title.TextWrapped = true
	Title.TextXAlignment = Enum.TextXAlignment.Left
	Title.TextTransparency = 1;

	Twen:Create(Title,TweenInfo2,{TextTransparency = 0}):Play();

	UIGradient.Rotation = 90
	UIGradient.Transparency = NumberSequence.new{NumberSequenceKeypoint.new(0.00, 0.00), NumberSequenceKeypoint.new(0.75, 0.27), NumberSequenceKeypoint.new(1.00, 1.00)}
	UIGradient.Parent = Title

	Description.Name = "Description"
	Description.Parent = MainFrame
	Description.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	Description.BackgroundTransparency = 1.000
	Description.BorderColor3 = Color3.fromRGB(0, 0, 0)
	Description.BorderSizePixel = 0
	Description.Position = UDim2.new(0.327570528, 0, 0.0709220618, 0)
	Description.Size = UDim2.new(0.671064615, 0, 0.0290780049, 0)
	Description.Font = Enum.Font.GothamBold
	Description.Text = config.Description
	Description.TextColor3 = Color3.fromRGB(255, 255, 255)
	Description.TextScaled = true
	Description.TextSize = 14.000
	Description.TextTransparency = 1
	Description.TextWrapped = true
	Description.TextXAlignment = Enum.TextXAlignment.Left
	Twen:Create(Description,TweenInfo2,{TextTransparency = 0.5}):Play();

	UIGradient_2.Rotation = 90
	UIGradient_2.Transparency = NumberSequence.new{NumberSequenceKeypoint.new(0.00, 0.00), NumberSequenceKeypoint.new(0.75, 0.27), NumberSequenceKeypoint.new(1.00, 1.00)}
	UIGradient_2.Parent = Description

	BlockFrame1.Name = "BlockFrame1"
	BlockFrame1.Parent = MainFrame
	BlockFrame1.AnchorPoint = Vector2.new(0, 0.5)
	BlockFrame1.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	BlockFrame1.BackgroundTransparency = 1
	BlockFrame1.BorderColor3 = Color3.fromRGB(0, 0, 0)
	BlockFrame1.BorderSizePixel = 0
	BlockFrame1.Position = UDim2.new(0.317000002, 0, 0.5, 0)
	BlockFrame1.Size = UDim2.new(0, 1, 1, 0)
	BlockFrame1.ZIndex = 3
	Twen:Create(BlockFrame1,TweenInfo2,{BackgroundTransparency = 0.8}):Play();

	UICorner_3.CornerRadius = UDim.new(0.5, 0)
	UICorner_3.Parent = BlockFrame1

	UIGradient_3.Rotation = 90
	UIGradient_3.Transparency = NumberSequence.new{NumberSequenceKeypoint.new(0.00, 1.00), NumberSequenceKeypoint.new(0.05, 0.00), NumberSequenceKeypoint.new(0.96, 0.00), NumberSequenceKeypoint.new(1.00, 1.00)}
	UIGradient_3.Parent = BlockFrame1

	BlockFrame3.Name = "BlockFrame3"
	BlockFrame3.Parent = MainFrame
	BlockFrame3.AnchorPoint = Vector2.new(0, 0.5)
	BlockFrame3.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	BlockFrame3.BackgroundTransparency = 1
	BlockFrame3.BorderColor3 = Color3.fromRGB(0, 0, 0)
	BlockFrame3.BorderSizePixel = 0
	BlockFrame3.Position = UDim2.new(0.317000061, 0, 0.120060779, 0)
	BlockFrame3.Size = UDim2.new(0.682999969, 0, 0, 1)
	BlockFrame3.ZIndex = 3
	Twen:Create(BlockFrame3,TweenInfo2,{BackgroundTransparency = 0.8}):Play();

	UICorner_4.CornerRadius = UDim.new(0.5, 0)
	UICorner_4.Parent = BlockFrame3

	UIGradient_4.Transparency = NumberSequence.new{NumberSequenceKeypoint.new(0.00, 0.00), NumberSequenceKeypoint.new(0.98, 0.00), NumberSequenceKeypoint.new(1.00, 1.00)}
	UIGradient_4.Parent = BlockFrame3

	BlockFrame2.Name = "BlockFrame2"
	BlockFrame2.Parent = MainFrame
	BlockFrame2.AnchorPoint = Vector2.new(0, 0.5)
	BlockFrame2.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	BlockFrame2.BackgroundTransparency = 1
	BlockFrame2.BorderColor3 = Color3.fromRGB(0, 0, 0)
	BlockFrame2.BorderSizePixel = 0
	BlockFrame2.Position = UDim2.new(-0.00100000005, 0, 0.204999998, 0)
	BlockFrame2.Size = UDim2.new(0.318471342, 0, 0, 1)
	BlockFrame2.ZIndex = 3
	Twen:Create(BlockFrame2,TweenInfo2,{BackgroundTransparency = 0.8}):Play();

	UICorner_5.CornerRadius = UDim.new(0.5, 0)
	UICorner_5.Parent = BlockFrame2

	UIGradient_5.Rotation = -180
	UIGradient_5.Transparency = NumberSequence.new{NumberSequenceKeypoint.new(0.00, 0.00), NumberSequenceKeypoint.new(0.98, 0.00), NumberSequenceKeypoint.new(1.00, 1.00)}
	UIGradient_5.Parent = BlockFrame2

	TabButtonFrame.Name = "TabButtonFrame"
	TabButtonFrame.Parent = MainFrame
	TabButtonFrame.AnchorPoint = Vector2.new(0.5, 0)
	TabButtonFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
	TabButtonFrame.BackgroundTransparency = 1
	TabButtonFrame.BorderColor3 = Color3.fromRGB(0, 0, 0)
	TabButtonFrame.BorderSizePixel = 0
	TabButtonFrame.ClipsDescendants = true
	TabButtonFrame.Position = UDim2.new(0.159999996, 0, 0.215000004, 0)
	TabButtonFrame.Size = UDim2.new(0.300000012, 0, 0.774999976, 0)
	Twen:Create(TabButtonFrame,TweenInfo2,{BackgroundTransparency = 0.5}):Play();

	UICorner_6.CornerRadius = UDim.new(0, 3)
	UICorner_6.Parent = TabButtonFrame

	TabButtons.Name = "TabButtons"
	TabButtons.Parent = TabButtonFrame
	TabButtons.Active = true
	TabButtons.AnchorPoint = Vector2.new(0.5, 0.5)
	TabButtons.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	TabButtons.BackgroundTransparency = 1.000
	TabButtons.BorderColor3 = Color3.fromRGB(0, 0, 0)
	TabButtons.BorderSizePixel = 0
	TabButtons.ClipsDescendants = false
	TabButtons.Position = UDim2.new(0.5, 0, 0.5, 0)
	TabButtons.Size = UDim2.new(0.970000029, 0, 0.970000029, 0)
	TabButtons.ScrollBarThickness = 0
	UIListLayout:GetPropertyChangedSignal('AbsoluteContentSize'):Connect(function()
		TabButtons.CanvasSize = UDim2.fromOffset(0,UIListLayout.AbsoluteContentSize.Y)
	end)
	UIListLayout.Parent = TabButtons
	UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
	UIListLayout.Padding = UDim.new(0, 3)

	MainTabFrame.Name = "MainTabFrame"
	MainTabFrame.Parent = MainFrame
	MainTabFrame.AnchorPoint = Vector2.new(0.5, 0)
	MainTabFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
	MainTabFrame.BackgroundTransparency = 1
	MainTabFrame.BorderColor3 = Color3.fromRGB(0, 0, 0)
	MainTabFrame.BorderSizePixel = 0
	MainTabFrame.ClipsDescendants = true
	MainTabFrame.Position = UDim2.new(0.657999992, 0, 0.130999997, 0)
	MainTabFrame.Size = UDim2.new(0.670000017, 0, 0.860000014, 0)
	Twen:Create(MainTabFrame,TweenInfo2,{BackgroundTransparency = 0.5}):Play();

	UICorner_7.CornerRadius = UDim.new(0, 3)
	UICorner_7.Parent = MainTabFrame

	InputFrame.Name = "InputFrame"
	InputFrame.Parent = MainFrame
	InputFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	InputFrame.BackgroundTransparency = 1.000
	InputFrame.BorderColor3 = Color3.fromRGB(0, 0, 0)
	InputFrame.BorderSizePixel = 0
	InputFrame.Position = UDim2.new(0, 0, 3.86494179e-08, 0)
	InputFrame.Size = UDim2.new(1, 0, 0.121327251, 0)
	InputFrame.ZIndex = 15;

	task.spawn(function()
		local Locked = nil;
		local Looped = false;

		local DropdownFrame = Instance.new("Frame")
		local UICorner = Instance.new("UICorner")
		local MiniDropShadow = Instance.new("ImageLabel")
		local UIStroke = Instance.new("UIStroke")
		local ValueId = Instance.new("TextLabel")
		local UIAspectRatioConstraint = Instance.new("UIAspectRatioConstraint")
		local ScrollingFrame = Instance.new("ScrollingFrame")
		local UIListLayout = Instance.new("UIListLayout")
		local Block = Instance.new("Frame")
		local BlockFrame3 = Instance.new("Frame")
		local UICorner_2 = Instance.new("UICorner")
		local UIGradient = Instance.new("UIGradient")

		DropdownFrame.Name = "DropdownFrame"
		DropdownFrame.Parent = ScreenGui
		DropdownFrame.BackgroundColor3 = Color3.fromRGB(17, 17, 17)
		DropdownFrame.BackgroundTransparency = 0.500
		DropdownFrame.BorderColor3 = Color3.fromRGB(0, 0, 0)
		DropdownFrame.BorderSizePixel = 0
		DropdownFrame.Position = UDim2.new(0, 289, 0, 213)
		DropdownFrame.Size = UDim2.new(0, 150, 0, 145)
		DropdownFrame.ZIndex = 100
		DropdownFrame.Visible = false;

		UICorner.CornerRadius = UDim.new(0, 4)
		UICorner.Parent = DropdownFrame

		MiniDropShadow.Name = "MiniDropShadow"
		MiniDropShadow.Parent = DropdownFrame
		MiniDropShadow.AnchorPoint = Vector2.new(0.5, 0.5)
		MiniDropShadow.BackgroundTransparency = 1.000
		MiniDropShadow.BorderSizePixel = 0
		MiniDropShadow.Position = UDim2.new(0.5, 0, 0.5, 0)
		MiniDropShadow.Size = UDim2.new(1, 47, 1, 47)
		MiniDropShadow.ZIndex = 99
		MiniDropShadow.Image = "rbxassetid://6015897843"
		MiniDropShadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
		MiniDropShadow.ImageTransparency = 0.600
		MiniDropShadow.ScaleType = Enum.ScaleType.Slice
		MiniDropShadow.SliceCenter = Rect.new(49, 49, 450, 450)

		UIStroke.Transparency = 0.900
		UIStroke.Color = Color3.fromRGB(255, 255, 255)
		UIStroke.Parent = DropdownFrame

		ValueId.Name = "ValueId"
		ValueId.Parent = DropdownFrame
		ValueId.AnchorPoint = Vector2.new(0.5, 0)
		ValueId.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		ValueId.BackgroundTransparency = 1.000
		ValueId.BorderColor3 = Color3.fromRGB(0, 0, 0)
		ValueId.BorderSizePixel = 0
		ValueId.Position = UDim2.new(0.5, 0, 0, 0)
		ValueId.Size = UDim2.new(0.970000029, 0, 0.5, 0)
		ValueId.ZIndex = 101
		ValueId.Font = Enum.Font.GothamBold
		ValueId.Text = "NONE"
		ValueId.TextColor3 = Color3.fromRGB(255, 255, 255)
		ValueId.TextScaled = true
		ValueId.TextSize = 14.000
		ValueId.TextTransparency = 0.800
		ValueId.TextWrapped = true
		ValueId.TextXAlignment = Enum.TextXAlignment.Right

		UIAspectRatioConstraint.Parent = ValueId
		UIAspectRatioConstraint.AspectRatio = 15.000
		UIAspectRatioConstraint.AspectType = Enum.AspectType.ScaleWithParentSize

		ScrollingFrame.Parent = DropdownFrame
		ScrollingFrame.Active = true
		ScrollingFrame.AnchorPoint = Vector2.new(0.5, 0.5)
		ScrollingFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		ScrollingFrame.BackgroundTransparency = 1.000
		ScrollingFrame.BorderColor3 = Color3.fromRGB(0, 0, 0)
		ScrollingFrame.BorderSizePixel = 0
		ScrollingFrame.Position = UDim2.new(0.5, 0, 0.555985212, 0)
		ScrollingFrame.Size = UDim2.new(0.949999988, 0, 0.888029099, 0)
		ScrollingFrame.ZIndex = 102
		ScrollingFrame.BottomImage = ""
		ScrollingFrame.ScrollBarThickness = 1
		ScrollingFrame.TopImage = ""

		UIListLayout:GetPropertyChangedSignal('AbsoluteContentSize'):Connect(function()
			ScrollingFrame.CanvasSize = UDim2.fromOffset(0,UIListLayout.AbsoluteContentSize.Y)
		end)

		UIListLayout.Parent = ScrollingFrame
		UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
		UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
		UIListLayout.Padding = UDim.new(0, 4)

		Block.Name = "Block"
		Block.Parent = ScrollingFrame
		Block.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		Block.BackgroundTransparency = 1.000
		Block.BorderColor3 = Color3.fromRGB(0, 0, 0)
		Block.BorderSizePixel = 0

		BlockFrame3.Name = "BlockFrame3"
		BlockFrame3.Parent = DropdownFrame
		BlockFrame3.AnchorPoint = Vector2.new(0, 0.5)
		BlockFrame3.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		BlockFrame3.BackgroundTransparency = 0.800
		BlockFrame3.BorderColor3 = Color3.fromRGB(0, 0, 0)
		BlockFrame3.BorderSizePixel = 0
		BlockFrame3.Position = UDim2.new(0, 0, 0.0799999982, 0)
		BlockFrame3.Size = UDim2.new(1, 0, 0, 1)
		BlockFrame3.ZIndex = 102

		UICorner_2.CornerRadius = UDim.new(0.5, 0)
		UICorner_2.Parent = BlockFrame3

		UIGradient.Transparency = NumberSequence.new{NumberSequenceKeypoint.new(0.00, 1.00), NumberSequenceKeypoint.new(0.03, 0.00), NumberSequenceKeypoint.new(0.98, 0.00), NumberSequenceKeypoint.new(1.00, 1.00)}
		UIGradient.Parent = BlockFrame3

		local GetSelector = function(title,value)
			local Selector = Instance.new("Frame")
			local UIAspectRatioConstraint = Instance.new("UIAspectRatioConstraint")
			local UICorner = Instance.new("UICorner")
			local Title = Instance.new("TextLabel")
			local UIGradient = Instance.new("UIGradient")
			local Frame = Instance.new("Frame")
			local UICorner_2 = Instance.new("UICorner")
			local UIGradient_2 = Instance.new("UIGradient")
			local Button = Instance.new("TextButton")
			local UIStroke = Instance.new("UIStroke")

			Selector.Name = "Selector"
			Selector.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
			Selector.BackgroundTransparency = 0.750
			Selector.BorderColor3 = Color3.fromRGB(0, 0, 0)
			Selector.BorderSizePixel = 0
			Selector.ClipsDescendants = true
			Selector.Size = UDim2.new(0.970000029, 0, 0.5, 0)
			Selector.ZIndex = 103
			Selector.Parent = ScrollingFrame
			UIAspectRatioConstraint.Parent = Selector
			UIAspectRatioConstraint.AspectRatio = 6.250
			UIAspectRatioConstraint.AspectType = Enum.AspectType.ScaleWithParentSize

			UICorner.CornerRadius = UDim.new(0, 3)
			UICorner.Parent = Selector

			Title.Name = "Title"
			Title.Parent = Selector
			Title.AnchorPoint = Vector2.new(0, 0.5)
			Title.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			Title.BackgroundTransparency = 1.000
			Title.BorderColor3 = Color3.fromRGB(0, 0, 0)
			Title.BorderSizePixel = 0
			Title.Position = UDim2.new(0.0250000004, 0, 0.5, 0)
			Title.Size = UDim2.new(1, 0, 0.5, 0)
			Title.ZIndex = 104
			Title.Font = Enum.Font.GothamBold
			Title.Text = title
			Title.TextColor3 = Color3.fromRGB(255, 255, 255)
			Title.TextScaled = true
			Title.TextSize = 14.000
			Title.TextWrapped = true
			Title.TextXAlignment = Enum.TextXAlignment.Left

			UIGradient.Rotation = 90
			UIGradient.Transparency = NumberSequence.new{NumberSequenceKeypoint.new(0.00, 0.00), NumberSequenceKeypoint.new(0.84, 0.25), NumberSequenceKeypoint.new(1.00, 1.00)}
			UIGradient.Parent = Title

			Frame.Parent = Selector
			Frame.AnchorPoint = Vector2.new(1, 0.5)
			Frame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			Frame.BackgroundTransparency = 0.600
			Frame.BorderColor3 = Color3.fromRGB(0, 0, 0)
			Frame.BorderSizePixel = 0
			Frame.Position = UDim2.new(1.02499998, 0, 0.5, 0)
			Frame.Size = UDim2.new(0.0549999997, 0, 0.699999988, 0)
			Frame.ZIndex = 104

			UICorner_2.CornerRadius = UDim.new(0, 3)
			UICorner_2.Parent = Frame

			UIGradient_2.Transparency = NumberSequence.new{NumberSequenceKeypoint.new(0.00, 0.00), NumberSequenceKeypoint.new(0.84, 0.25), NumberSequenceKeypoint.new(1.00, 1.00)}
			UIGradient_2.Parent = Frame

			Button.Name = "Button"
			Button.Parent = Selector
			Button.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			Button.BackgroundTransparency = 1.000
			Button.BorderColor3 = Color3.fromRGB(0, 0, 0)
			Button.BorderSizePixel = 0
			Button.Size = UDim2.new(1, 0, 1, 0)
			Button.ZIndex = 105
			Button.Font = Enum.Font.SourceSans
			Button.Text = ""
			Button.TextColor3 = Color3.fromRGB(0, 0, 0)
			Button.TextSize = 14.000
			Button.TextTransparency = 1.000

			UIStroke.Transparency = 0.900
			UIStroke.Color = Color3.fromRGB(255, 255, 255)
			UIStroke.Parent = Selector;

			local caller = function(a)
				if a then
					Twen:Create(Frame,TweenInfo.new(0.1),{
						Position = UDim2.new(1.02499998, 0, 0.5, 0)
					}):Play()
					Twen:Create(Title,TweenInfo.new(0.1),{
						TextTransparency = 0
					}):Play()

				else
					Twen:Create(Frame,TweenInfo.new(0.1),{
						Position = UDim2.new(1.12499998, 0, 0.5, 0)
					}):Play()
					Twen:Create(Title,TweenInfo.new(0.1),{
						TextTransparency = 0.25
					}):Play()
				end
			end;

			caller(value)

			return {
				effect = caller,
				button = Button,
				delete = function()
					Selector:Destroy()
				end,
			}
		end;

		local MouseInFrame = false;
		local MouseInMyFrame = false;

		function WindowTable.Dropdown:Setup(target_frame:Frame)
			Locked = target_frame
		end;

		function WindowTable.Dropdown:Open(args,defauklt,callback)
			Looped = true;

			ValueId.Text = tostring(defauklt)
			Twen:Create(DropdownFrame,TweenInfo.new(0.3),{
				BackgroundTransparency = 0.1;
			}):Play()

			Twen:Create(MiniDropShadow,TweenInfo.new(0.3),{
				ImageTransparency = 0.6;
			}):Play()

			Twen:Create(ValueId,TweenInfo.new(0.3),{
				TextTransparency = 0.8;
			}):Play()

			Twen:Create(ScrollingFrame,TweenInfo.new(0.3),{
				ScrollBarImageTransparency = 0.5;
			}):Play()

			Twen:Create(BlockFrame3,TweenInfo.new(0.3),{
				BackgroundTransparency = 0.8;
			}):Play()

			Twen:Create(UIStroke,TweenInfo.new(0.3),{
				Transparency = 0.9;
			}):Play()


			for i,v in pairs(ScrollingFrame:GetChildren()) do
				if v ~= Block then
					if v:IsA('Frame') then
						v:Destroy();
					end;
				end;
			end;

			local list = {};

			for i,v in pairs(args) do
				local butt = GetSelector(tostring(v),v == defauklt);

				butt.button.MouseButton1Click:Connect(function()
					for i,s in ipairs(list) do
						if s[1] == v then
							s[2].effect(true);
						else
							s[2].effect(false);
						end;
					end;
					ValueId.Text = tostring(v);
					callback(v);
				end)

				table.insert(list,{v,butt})
			end;
		end;

		function WindowTable.Dropdown:Close(args)
			Looped = false;
			Twen:Create(UIStroke,TweenInfo.new(0.3),{
				Transparency = 1;
			}):Play()
			Twen:Create(DropdownFrame,TweenInfo.new(0.3),{
				BackgroundTransparency = 1;
			}):Play()

			Twen:Create(MiniDropShadow,TweenInfo.new(0.3),{
				ImageTransparency = 1;
			}):Play()

			Twen:Create(ValueId,TweenInfo.new(0.3),{
				TextTransparency = 1;
			}):Play()

			Twen:Create(ScrollingFrame,TweenInfo.new(0.3),{
				ScrollBarImageTransparency = 1;
			}):Play()

			Twen:Create(BlockFrame3,TweenInfo.new(0.3),{
				BackgroundTransparency = 1;
			}):Play()

			for i,v in pairs(ScrollingFrame:GetChildren()) do
				if v ~= Block then
					if v:IsA('Frame') then
						v:Destroy();
					end;
				end;
			end;
		end;

		DropdownFrame.MouseEnter:Connect(function()
			MouseInMyFrame = true
		end)
		DropdownFrame.MouseLeave:Connect(function()
			MouseInMyFrame = false
		end)

		Input.InputBegan:Connect(function(keycode)
			if keycode.UserInputType == Enum.UserInputType.MouseButton1 or keycode.UserInputType == Enum.UserInputType.Touch then
				if not MouseInFrame and not MouseInMyFrame then
					WindowTable.Dropdown:Close();
				end;
			end;
		end)

		game:GetService('RunService'):BindToRenderStep('__LIBRARY__',20,function()
			WindowTable.Dropdown.Value = Looped
			if Looped then
				DropdownFrame.Visible = true;

				Twen:Create(DropdownFrame,TweenInfo.new(0.15),{
					Position = UDim2.fromOffset(Locked.AbsolutePosition.X + 5,Locked.AbsolutePosition.Y + (DropdownFrame.AbsoluteSize.Y / 1.5)),
					Size = UDim2.fromOffset(Locked.AbsoluteSize.X,150)
				}):Play()

			else
				if Locked then
					DropdownFrame.Size = DropdownFrame.Size:Lerp(UDim2.fromOffset(Locked.AbsoluteSize.X,0),.2);
					DropdownFrame.Position = DropdownFrame.Position:Lerp(UDim2.fromOffset(Locked.AbsolutePosition.X,Locked.AbsolutePosition.Y+DropdownFrame.AbsoluteSize.Y),.1);
				else
					DropdownFrame.Size = DropdownFrame.Size:Lerp(UDim2.fromOffset(0,0),.1);
					DropdownFrame.Position = DropdownFrame.Position:Lerp(UDim2.fromOffset(0,0),.1);
				end;

				if DropdownFrame.Size.Y.Offset == 0 then
					DropdownFrame.Visible = false;
				end;
			end;
		end);
	end)

	function WindowTable:NewTab(cfg)
		cfg = Config(cfg,{
			Title = "Example",
			Description = "Tab: "..tostring(#WindowTable.Tabs + 1),
			Icon = "rbxassetid://7733964640"
		});

		local TabTable = {};
		local TabButton = Instance.new("Frame")
		local UIAspectRatioConstraint = Instance.new("UIAspectRatioConstraint")
		local UICorner = Instance.new("UICorner")
		local Icon = Instance.new("ImageLabel")
		local UICorner_2 = Instance.new("UICorner")
		local UIGradient = Instance.new("UIGradient")
		local Title = Instance.new("TextLabel")
		local UIGradient_2 = Instance.new("UIGradient")
		local Description = Instance.new("TextLabel")
		local UIGradient_3 = Instance.new("UIGradient")
		local Frame = Instance.new("Frame")
		local UICorner_3 = Instance.new("UICorner")
		local UIGradient_4 = Instance.new("UIGradient")
		local Button = Instance.new("TextButton")

		TabButton.Name = "TabButton"
		TabButton.Parent = TabButtons
		TabButton.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
		TabButton.BackgroundTransparency = 1
		TabButton.BorderColor3 = Color3.fromRGB(0, 0, 0)
		TabButton.BorderSizePixel = 0
		TabButton.ClipsDescendants = true
		TabButton.Size = UDim2.new(0.970000029, 0, 0.5, 0)
		TabButton.ZIndex = 5
		Twen:Create(TabButton,TweenInfo2,{BackgroundTransparency = 0.750}):Play();

		UIAspectRatioConstraint.Parent = TabButton
		UIAspectRatioConstraint.AspectRatio = 4.250
		UIAspectRatioConstraint.AspectType = Enum.AspectType.ScaleWithParentSize

		UICorner.CornerRadius = UDim.new(0, 3)
		UICorner.Parent = TabButton

		Icon.Name = "Icon"
		Icon.Parent = TabButton
		Icon.AnchorPoint = Vector2.new(0.5, 0.5)
		Icon.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		Icon.BackgroundTransparency = 1.000
		Icon.BorderColor3 = Color3.fromRGB(0, 0, 0)
		Icon.BorderSizePixel = 0
		Icon.Position = UDim2.new(0.100000001, 0, 0.5, 0)
		Icon.Size = UDim2.new(0.600000024, 0, 0.600000024, 0)
		Icon.SizeConstraint = Enum.SizeConstraint.RelativeYY
		Icon.ZIndex = 6
		Icon.Image = Icons[cfg.Icon] or cfg.Icon
		Icon.ImageTransparency = 1
		Twen:Create(Icon,TweenInfo2,{ImageTransparency = 0.1}):Play();

		UICorner_2.CornerRadius = UDim.new(0, 3)
		UICorner_2.Parent = Icon

		UIGradient.Rotation = 90
		UIGradient.Transparency = NumberSequence.new{NumberSequenceKeypoint.new(0.00, 0.00), NumberSequenceKeypoint.new(0.75, 0.27), NumberSequenceKeypoint.new(1.00, 1.00)}
		UIGradient.Parent = Icon

		Title.Name = "Title"
		Title.Parent = TabButton
		Title.AnchorPoint = Vector2.new(0, 0.5)
		Title.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		Title.BackgroundTransparency = 1.000
		Title.BorderColor3 = Color3.fromRGB(0, 0, 0)
		Title.BorderSizePixel = 0
		Title.Position = UDim2.new(0.200000003, 0, 0.375, 0)
		Title.Size = UDim2.new(1, 0, 0.400000006, 0)
		Title.Font = Enum.Font.GothamBold
		Title.Text = cfg.Title
		Title.TextColor3 = Color3.fromRGB(255, 255, 255)
		Title.TextScaled = true
		Title.TextSize = 14.000
		Title.TextWrapped = true
		Title.TextXAlignment = Enum.TextXAlignment.Left
		Title.TextTransparency = 1;

		UIGradient_2.Rotation = 90
		UIGradient_2.Transparency = NumberSequence.new{NumberSequenceKeypoint.new(0.00, 0.00), NumberSequenceKeypoint.new(0.84, 0.25), NumberSequenceKeypoint.new(1.00, 1.00)}
		UIGradient_2.Parent = Title

		Description.Name = "Description"
		Description.Parent = TabButton
		Description.AnchorPoint = Vector2.new(0, 0.5)
		Description.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		Description.BackgroundTransparency = 1.000
		Description.BorderColor3 = Color3.fromRGB(0, 0, 0)
		Description.BorderSizePixel = 0
		Description.Position = UDim2.new(0.200000003, 0, 0.699999988, 0)
		Description.Size = UDim2.new(1, 0, 0.300000012, 0)
		Description.Font = Enum.Font.GothamBold
		Description.Text = cfg.Description
		Description.TextColor3 = Color3.fromRGB(255, 255, 255)
		Description.TextScaled = true
		Description.TextSize = 14.000
		Description.TextTransparency = 1
		Description.TextWrapped = true
		Description.TextXAlignment = Enum.TextXAlignment.Left

		UIGradient_3.Rotation = 90
		UIGradient_3.Transparency = NumberSequence.new{NumberSequenceKeypoint.new(0.00, 0.00), NumberSequenceKeypoint.new(0.84, 0.25), NumberSequenceKeypoint.new(1.00, 1.00)}
		UIGradient_3.Parent = Description

		Frame.Parent = TabButton
		Frame.AnchorPoint = Vector2.new(1, 0.5)
		Frame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		Frame.BackgroundTransparency = 1
		Frame.BorderColor3 = Color3.fromRGB(0, 0, 0)
		Frame.BorderSizePixel = 0
		Frame.Position = UDim2.new(1.02499998, 0, 0.5, 0)
		Frame.Size = UDim2.new(0.0549999997, 0, 0.699999988, 0)
		Frame.ZIndex = 6
		Twen:Create(Frame,TweenInfo2,{BackgroundTransparency = 0.1}):Play();

		UICorner_3.CornerRadius = UDim.new(0, 3)
		UICorner_3.Parent = Frame

		UIGradient_4.Transparency = NumberSequence.new{NumberSequenceKeypoint.new(0.00, 0.00), NumberSequenceKeypoint.new(0.84, 0.25), NumberSequenceKeypoint.new(1.00, 1.00)}
		UIGradient_4.Parent = Frame

		Button.Name = "Button"
		Button.Parent = TabButton
		Button.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		Button.BackgroundTransparency = 1.000
		Button.BorderColor3 = Color3.fromRGB(0, 0, 0)
		Button.BorderSizePixel = 0
		Button.Size = UDim2.new(1, 0, 1, 0)
		Button.ZIndex = 15
		Button.Font = Enum.Font.SourceSans
		Button.Text = ""
		Button.TextColor3 = Color3.fromRGB(0, 0, 0)
		Button.TextSize = 14.000
		Button.TextTransparency = 1.000

		local Init = Instance.new("Frame")
		local LeftFrame = Instance.new("ScrollingFrame")
		local UIListLayout = Instance.new("UIListLayout")
		local RightFrame = Instance.new("ScrollingFrame")
		local UIListLayout_2 = Instance.new("UIListLayout")

		Init.Name = "Init"
		Init.Parent = MainTabFrame
		Init.AnchorPoint = Vector2.new(0.5, 0.5)
		Init.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		Init.BackgroundTransparency = 1.000
		Init.BorderColor3 = Color3.fromRGB(0, 0, 0)
		Init.BorderSizePixel = 0
		Init.Position = UDim2.new(0.5, 0, 0.5, 0)
		Init.Size = UDim2.new(0.980000019, 0, 0.980000019, 0)
		Init.ZIndex = 4

		LeftFrame.Name = "LeftFrame"
		LeftFrame.Parent = Init
		LeftFrame.Active = true
		LeftFrame.AnchorPoint = Vector2.new(0.5, 0.5)
		LeftFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		LeftFrame.BackgroundTransparency = 1.000
		LeftFrame.BorderColor3 = Color3.fromRGB(0, 0, 0)
		LeftFrame.BorderSizePixel = 0
		LeftFrame.ClipsDescendants = false
		LeftFrame.Position = UDim2.new(0.25, 0, 0.5, 0)
		LeftFrame.Size = UDim2.new(0.5, 0, 1, 0)
		LeftFrame.ScrollBarThickness = 0
		UIListLayout:GetPropertyChangedSignal('AbsoluteContentSize'):Connect(function()
			LeftFrame.CanvasSize = UDim2.fromOffset(0,UIListLayout.AbsoluteContentSize.Y)
		end)
		UIListLayout.Parent = LeftFrame
		UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
		UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
		UIListLayout.Padding = UDim.new(0, 3)

		RightFrame.Name = "RightFrame"
		RightFrame.Parent = Init
		RightFrame.Active = true
		RightFrame.AnchorPoint = Vector2.new(0.5, 0.5)
		RightFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		RightFrame.BackgroundTransparency = 1.000
		RightFrame.BorderColor3 = Color3.fromRGB(0, 0, 0)
		RightFrame.BorderSizePixel = 0
		RightFrame.ClipsDescendants = false
		RightFrame.Position = UDim2.new(0.75, 0, 0.5, 0)
		RightFrame.Size = UDim2.new(0.5, 0, 1, 0)
		RightFrame.ScrollBarThickness = 0
		UIListLayout_2:GetPropertyChangedSignal('AbsoluteContentSize'):Connect(function()
			RightFrame.CanvasSize = UDim2.fromOffset(0,UIListLayout_2.AbsoluteContentSize.Y)
		end)
		UIListLayout_2.Parent = RightFrame
		UIListLayout_2.HorizontalAlignment = Enum.HorizontalAlignment.Center
		UIListLayout_2.SortOrder = Enum.SortOrder.LayoutOrder
		UIListLayout_2.Padding = UDim.new(0, 3)

		local onFunction = function(value)
			if value then
				Init.Visible = true;

				Twen:Create(Icon,TweenInfo.new(0.55,Enum.EasingStyle.Quint),{
					ImageTransparency = 0.1
				}):Play();

				Twen:Create(Title,TweenInfo.new(0.5,Enum.EasingStyle.Quint),{
					TextTransparency = 0
				}):Play();

				Twen:Create(Description,TweenInfo.new(0.4,Enum.EasingStyle.Quint),{
					TextTransparency = 0.500
				}):Play();

				Twen:Create(Frame,TweenInfo.new(0.55,Enum.EasingStyle.Quint),{
					Position = UDim2.new(1.02499998, 0, 0.5, 0)
				}):Play();
			else
				Init.Visible = false;

				Twen:Create(Icon,TweenInfo.new(0.55,Enum.EasingStyle.Quint),{
					ImageTransparency = 0.25
				}):Play();

				Twen:Create(Title,TweenInfo.new(0.4,Enum.EasingStyle.Quint),{
					TextTransparency = 0.25
				}):Play();

				Twen:Create(Description,TweenInfo.new(0.5,Enum.EasingStyle.Quint),{
					TextTransparency = 0.65
				}):Play();

				Twen:Create(Frame,TweenInfo.new(0.55,Enum.EasingStyle.Quint),{
					Position = UDim2.new(1.1, 0, 0.4, 0)
				}):Play();
			end;
		end;

		if WindowTable.Tabs[1] then
			onFunction(false);
		else
			onFunction(true);
		end;

		table.insert(WindowTable.Tabs,{
			Id = Init,
			onFunction = onFunction,
		})

		Button.MouseButton1Click:Connect(function()
			for i,v in ipairs(WindowTable.Tabs) do
				if v.Id == Init then
					v.onFunction(true);
				else
					v.onFunction(false);
				end;
			end;
		end)

		function TabTable:NewSection(c_o_n_f_i_g)
			c_o_n_f_i_g = Config(c_o_n_f_i_g,{
				Position = "Left",
				Title = "Section",
				Icon = 'rbxassetid://7733964640'
			});

			local SectionTable = {};
			local Section = Instance.new("Frame")
			local UICorner = Instance.new("UICorner")
			local Header = Instance.new("Frame")
			local UIAspectRatioConstraint = Instance.new("UIAspectRatioConstraint")
			local UICorner_2 = Instance.new("UICorner")
			local Icon = Instance.new("ImageLabel")
			local UICorner_3 = Instance.new("UICorner")
			local UIGradient = Instance.new("UIGradient")
			local BlockFrame = Instance.new("Frame")
			local UICorner_4 = Instance.new("UICorner")
			local UIGradient_2 = Instance.new("UIGradient")
			local Title = Instance.new("TextLabel")
			local UIGradient_3 = Instance.new("UIGradient")
			local SectionAutoUI = Instance.new("UIListLayout")
			local UIStroke = Instance.new("UIStroke")
			local UIGradient_4 = Instance.new("UIGradient")

			Section.Name = "Section"
			Section.Parent = (c_o_n_f_i_g.Position == "Left" and LeftFrame) or RightFrame;
			Section.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
			Section.BackgroundTransparency = 1
			Section.BorderColor3 = Color3.fromRGB(0, 0, 0)
			Section.BorderSizePixel = 0
			Section.Size = UDim2.new(0.980000019, 0, 0, 200)
			Section.ClipsDescendants = true;
			Twen:Create(Section,TweenInfo1,{BackgroundTransparency = 0.75}):Play();

			UICorner.CornerRadius = UDim.new(0, 3)
			UICorner.Parent = Section

			Header.Name = "Header"
			Header.Parent = Section
			Header.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
			Header.BackgroundTransparency = 0.900
			Header.BorderColor3 = Color3.fromRGB(0, 0, 0)
			Header.BorderSizePixel = 0
			Header.Size = UDim2.new(1, 0, 0.5, 0)
			Twen:Create(Header,TweenInfo2,{BackgroundTransparency = 0.9}):Play();

			UIAspectRatioConstraint.Parent = Header
			UIAspectRatioConstraint.AspectRatio = 8.000
			UIAspectRatioConstraint.AspectType = Enum.AspectType.ScaleWithParentSize

			UICorner_2.CornerRadius = UDim.new(0, 3)
			UICorner_2.Parent = Header

			Icon.Name = "Icon"
			Icon.Parent = Header
			Icon.AnchorPoint = Vector2.new(0.5, 0.5)
			Icon.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			Icon.BackgroundTransparency = 1.000
			Icon.BorderColor3 = Color3.fromRGB(0, 0, 0)
			Icon.BorderSizePixel = 0
			Icon.Position = UDim2.new(0.0649999976, 0, 0.5, 0)
			Icon.Size = UDim2.new(0.600000024, 0, 0.600000024, 0)
			Icon.SizeConstraint = Enum.SizeConstraint.RelativeYY
			Icon.ZIndex = 6
			Icon.Image = Icons[c_o_n_f_i_g.Icon] or c_o_n_f_i_g.Icon; 
			Icon.ImageTransparency = 1
			Twen:Create(Icon,TweenInfo2,{ImageTransparency = 0.1}):Play();

			UICorner_3.CornerRadius = UDim.new(0, 3)
			UICorner_3.Parent = Icon

			UIGradient.Rotation = 90
			UIGradient.Transparency = NumberSequence.new{NumberSequenceKeypoint.new(0.00, 0.00), NumberSequenceKeypoint.new(0.75, 0.27), NumberSequenceKeypoint.new(1.00, 1.00)}
			UIGradient.Parent = Icon

			BlockFrame.Name = "BlockFrame"
			BlockFrame.Parent = Header
			BlockFrame.AnchorPoint = Vector2.new(0.5, 1)
			BlockFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			BlockFrame.BackgroundTransparency = 1
			BlockFrame.BorderColor3 = Color3.fromRGB(0, 0, 0)
			BlockFrame.BorderSizePixel = 0
			BlockFrame.Position = UDim2.new(0.5, 0, 1, 0)
			BlockFrame.Size = UDim2.new(1, 0, 0, 1)
			BlockFrame.ZIndex = 3
			Twen:Create(BlockFrame,TweenInfo2,{BackgroundTransparency = 0.8}):Play();

			UICorner_4.CornerRadius = UDim.new(0.5, 0)
			UICorner_4.Parent = BlockFrame

			UIGradient_2.Transparency = NumberSequence.new{NumberSequenceKeypoint.new(0.00, 1.00), NumberSequenceKeypoint.new(0.10, 0.00), NumberSequenceKeypoint.new(0.90, 0.00), NumberSequenceKeypoint.new(1.00, 1.00)}
			UIGradient_2.Parent = BlockFrame

			Title.Name = "Title"
			Title.Parent = Header
			Title.AnchorPoint = Vector2.new(0, 0.5)
			Title.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			Title.BackgroundTransparency = 1.000
			Title.BorderColor3 = Color3.fromRGB(0, 0, 0)
			Title.BorderSizePixel = 0
			Title.Position = UDim2.new(0.125, 0, 0.449999988, 0)
			Title.Size = UDim2.new(1, 0, 0.5, 0)
			Title.Font = Enum.Font.GothamBold
			Title.Text = c_o_n_f_i_g.Title
			Title.TextColor3 = Color3.fromRGB(255, 255, 255)
			Title.TextScaled = true
			Title.TextSize = 14.000
			Title.TextWrapped = true
			Title.TextXAlignment = Enum.TextXAlignment.Left
			Title.TextTransparency = 1
			Twen:Create(Title,TweenInfo2,{TextTransparency = 0}):Play();

			UIGradient_3.Rotation = 90
			UIGradient_3.Transparency = NumberSequence.new{NumberSequenceKeypoint.new(0.00, 0.00), NumberSequenceKeypoint.new(0.84, 0.25), NumberSequenceKeypoint.new(1.00, 1.00)}
			UIGradient_3.Parent = Title

			SectionAutoUI.Name = "SectionAutoUI"
			SectionAutoUI.Parent = Section
			SectionAutoUI.HorizontalAlignment = Enum.HorizontalAlignment.Center
			SectionAutoUI.SortOrder = Enum.SortOrder.LayoutOrder
			SectionAutoUI.Padding = UDim.new(0, 3)

			SectionAutoUI:GetPropertyChangedSignal('AbsoluteContentSize'):Connect(function()
				Twen:Create(Section,TweenInfo.new(0.1),{
					Size = UDim2.new(0.98,0,0,math.max(SectionAutoUI.AbsoluteContentSize.Y,50) + (SectionAutoUI.Padding.Offset * 1.12));
				}):Play()
			end)

			UIStroke.Transparency = 1
			UIStroke.Color = Color3.fromRGB(255, 255, 255)
			UIStroke.Parent = Section
			Twen:Create(UIStroke,TweenInfo1,{Transparency = 0.9}):Play();

			UIGradient_4.Rotation = 90
			UIGradient_4.Transparency = NumberSequence.new{NumberSequenceKeypoint.new(0.00, 0.00), NumberSequenceKeypoint.new(0.17, 1.00), NumberSequenceKeypoint.new(0.82, 1.00), NumberSequenceKeypoint.new(1.00, 0.00)}
			UIGradient_4.Parent = UIStroke

			function SectionTable:NewToggle(toggle)
				toggle = Config(toggle,{
					Title = "Toggle",
					Default = false,
					Callback = function() end;
				});

				local FunctionToggle = Instance.new("Frame")
				local UIAspectRatioConstraint = Instance.new("UIAspectRatioConstraint")
				local TextInt = Instance.new("TextLabel")
				local UIGradient = Instance.new("UIGradient")
				local Button = Instance.new("TextButton")
				local UIStroke = Instance.new("UIStroke")
				local System = Instance.new("Frame")
				local UICorner = Instance.new("UICorner")
				local UIStroke_2 = Instance.new("UIStroke")
				local Icon = Instance.new("Frame")
				local UICorner_2 = Instance.new("UICorner")
				local UICorner_3 = Instance.new("UICorner")

				FunctionToggle.Name = "FunctionToggle"
				FunctionToggle.Parent = Section
				FunctionToggle.BackgroundColor3 = Color3.fromRGB(17, 17, 17)
				FunctionToggle.BackgroundTransparency = 1
				FunctionToggle.BorderColor3 = Color3.fromRGB(0, 0, 0)
				FunctionToggle.BorderSizePixel = 0
				FunctionToggle.Size = UDim2.new(0.949999988, 0, 0.5, 0)
				FunctionToggle.ZIndex = 17
				Twen:Create(FunctionToggle,TweenInfo1,{BackgroundTransparency = 0.8}):Play();

				UIAspectRatioConstraint.Parent = FunctionToggle
				UIAspectRatioConstraint.AspectRatio = 8.000
				UIAspectRatioConstraint.AspectType = Enum.AspectType.ScaleWithParentSize

				TextInt.Name = "TextInt"
				TextInt.Parent = FunctionToggle
				TextInt.AnchorPoint = Vector2.new(0.5, 0.5)
				TextInt.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
				TextInt.BackgroundTransparency = 1.000
				TextInt.BorderColor3 = Color3.fromRGB(0, 0, 0)
				TextInt.BorderSizePixel = 0
				TextInt.Position = UDim2.new(0.5, 0, 0.5, 0)
				TextInt.Size = UDim2.new(0.949999988, 0, 0.479999989, 0)
				TextInt.ZIndex = 18
				TextInt.Font = Enum.Font.GothamBold
				TextInt.Text = toggle.Title
				TextInt.TextColor3 = Color3.fromRGB(255, 255, 255)
				TextInt.TextScaled = true
				TextInt.TextSize = 14.000
				TextInt.TextTransparency = 0.250
				TextInt.TextWrapped = true
				TextInt.TextXAlignment = Enum.TextXAlignment.Left

				UIGradient.Rotation = 90
				UIGradient.Transparency = NumberSequence.new{NumberSequenceKeypoint.new(0.00, 0.00), NumberSequenceKeypoint.new(0.84, 0.25), NumberSequenceKeypoint.new(1.00, 1.00)}
				UIGradient.Parent = TextInt

				Button.Name = "Button"
				Button.Parent = FunctionToggle
				Button.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
				Button.BackgroundTransparency = 1.000
				Button.BorderColor3 = Color3.fromRGB(0, 0, 0)
				Button.BorderSizePixel = 0
				Button.Size = UDim2.new(1, 0, 1, 0)
				Button.ZIndex = 15
				Button.Font = Enum.Font.SourceSans
				Button.Text = ""
				Button.TextColor3 = Color3.fromRGB(0, 0, 0)
				Button.TextSize = 14.000
				Button.TextTransparency = 1.000

				UIStroke.Transparency = 0.950
				UIStroke.Color = Color3.fromRGB(255, 255, 255)
				UIStroke.Parent = FunctionToggle

				System.Name = "System"
				System.Parent = FunctionToggle
				System.AnchorPoint = Vector2.new(1, 0.5)
				System.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
				System.BackgroundTransparency = 1.000
				System.BorderColor3 = Color3.fromRGB(0, 0, 0)
				System.BorderSizePixel = 0
				System.Position = UDim2.new(0.975000024, 0, 0.5, 0)
				System.Size = UDim2.new(0.155000001, 0, 0.600000024, 0)
				System.ZIndex = 18

				UICorner.CornerRadius = UDim.new(0.5, 0)
				UICorner.Parent = System

				UIStroke_2.Transparency = 0.850
				UIStroke_2.Color = Color3.fromRGB(255, 255, 255)
				UIStroke_2.Parent = System

				Icon.Name = "Icon"
				Icon.Parent = System
				Icon.AnchorPoint = Vector2.new(0.5, 0.5)
				Icon.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
				Icon.BackgroundTransparency = 0.500
				Icon.BorderColor3 = Color3.fromRGB(0, 0, 0)
				Icon.BorderSizePixel = 0
				Icon.Position = UDim2.new(0.25, 0, 0.5, 0)
				Icon.Size = UDim2.new(1, 0, 1, 0)
				Icon.SizeConstraint = Enum.SizeConstraint.RelativeYY
				Icon.ZIndex = 17

				UICorner_2.CornerRadius = UDim.new(1, 0)
				UICorner_2.Parent = Icon

				UICorner_3.CornerRadius = UDim.new(0, 2)
				UICorner_3.Parent = FunctionToggle

				local function OnChange(value)
					if value then

						Twen:Create(TextInt,TweenInfo.new(0.15,Enum.EasingStyle.Quint),{
							TextTransparency = 0.02
						}):Play()

						Twen:Create(Icon,TweenInfo.new(0.15,Enum.EasingStyle.Quint),{
							Position = UDim2.new(0.75, 0, 0.5, 0),
							BackgroundTransparency = 0.4
						}):Play()
					else
						Twen:Create(Icon,TweenInfo.new(0.15,Enum.EasingStyle.Quint),{
							Position = UDim2.new(0.25, 0, 0.5, 0),
							BackgroundTransparency = 0.500
						}):Play()

						Twen:Create(TextInt,TweenInfo.new(0.15,Enum.EasingStyle.Quint),{
							TextTransparency = 0.25
						}):Play()
					end;
				end;

				OnChange(toggle.Default);

				Button.MouseButton1Click:Connect(function()
					toggle.Default = not toggle.Default;
					OnChange(toggle.Default);
					task.spawn(toggle.Callback,toggle.Default)
				end)

				return {
					Value = function(newindex)
						toggle.Default = newindex;
						OnChange(toggle.Default);
						task.spawn(toggle.Callback,toggle.Default)
					end,
					Visible = function(newindx)
						FunctionToggle.Visible = newindx
					end,
				};
			end;

			function SectionTable:NewTitle(lrm)
				local FunctionTitle = Instance.new("Frame")
				local UIAspectRatioConstraint = Instance.new("UIAspectRatioConstraint")
				local TextInt = Instance.new("TextLabel")
				local UIGradient = Instance.new("UIGradient")
				local UICorner = Instance.new("UICorner")


				FunctionTitle.Name = "FunctionTitle"
				FunctionTitle.Parent = Section
				FunctionTitle.BackgroundColor3 = Color3.fromRGB(17, 17, 17)
				FunctionTitle.BackgroundTransparency = 0.800
				FunctionTitle.BorderColor3 = Color3.fromRGB(0, 0, 0)
				FunctionTitle.BorderSizePixel = 0
				FunctionTitle.Size = UDim2.new(0.949999988, 0, 0.5, 0)
				FunctionTitle.ZIndex = 17

				UIAspectRatioConstraint.Parent = FunctionTitle
				UIAspectRatioConstraint.AspectRatio = 8.000
				UIAspectRatioConstraint.AspectType = Enum.AspectType.ScaleWithParentSize

				TextInt.Name = "TextInt"
				TextInt.Parent = FunctionTitle
				TextInt.AnchorPoint = Vector2.new(0.5, 0.5)
				TextInt.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
				TextInt.BackgroundTransparency = 1.000
				TextInt.BorderColor3 = Color3.fromRGB(0, 0, 0)
				TextInt.BorderSizePixel = 0
				TextInt.Position = UDim2.new(0.5, 0, 0.5, 0)
				TextInt.Size = UDim2.new(0.949999988, 0, 0.600000024, 0)
				TextInt.ZIndex = 18
				TextInt.Font = Enum.Font.GothamBold
				TextInt.Text = lrm
				TextInt.TextColor3 = Color3.fromRGB(255, 255, 255)
				TextInt.TextScaled = true
				TextInt.TextSize = 14.000
				TextInt.TextTransparency = 1
				TextInt.TextWrapped = true
				TextInt.TextXAlignment = Enum.TextXAlignment.Left
				Twen:Create(TextInt,TweenInfo1,{TextTransparency = 0.25}):Play();

				UIGradient.Rotation = 90
				UIGradient.Transparency = NumberSequence.new{NumberSequenceKeypoint.new(0.00, 0.00), NumberSequenceKeypoint.new(0.84, 0.25), NumberSequenceKeypoint.new(1.00, 1.00)}
				UIGradient.Parent = TextInt

				UICorner.CornerRadius = UDim.new(0, 2)
				UICorner.Parent = FunctionTitle

				return {
					Visible = function(newindx)
						FunctionTitle.Visible = newindx
					end,
					Set = function(a)
						TextInt.Text = a
					end,
				};
			end;

			function SectionTable:NewButton(cfg)
				cfg = Config(cfg,{
					Title = "Button",
					Callback = function() end;
				});

				local FunctionButton = Instance.new("Frame")
				local UIAspectRatioConstraint = Instance.new("UIAspectRatioConstraint")
				local UICorner = Instance.new("UICorner")
				local DropShadow = Instance.new("ImageLabel")
				local TextInt = Instance.new("TextLabel")
				local UIGradient = Instance.new("UIGradient")
				local Button = Instance.new("TextButton")
				local UIStroke = Instance.new("UIStroke")

				FunctionButton.Name = "FunctionButton"
				FunctionButton.Parent = Section
				FunctionButton.BackgroundColor3 = Color3.fromRGB(71, 71, 71)
				FunctionButton.BackgroundTransparency = 1
				FunctionButton.BorderColor3 = Color3.fromRGB(0, 0, 0)
				FunctionButton.BorderSizePixel = 0
				FunctionButton.Size = UDim2.new(0.949999988, 0, 0.5, 0)
				FunctionButton.ZIndex = 17
				Twen:Create(FunctionButton,TweenInfo1,{
					BackgroundTransparency = 0.750,
					Size = UDim2.new(0.949999988, 0, 0.5, 0)
				}):Play();

				UIAspectRatioConstraint.Parent = FunctionButton
				UIAspectRatioConstraint.AspectRatio = 7.000
				UIAspectRatioConstraint.AspectType = Enum.AspectType.ScaleWithParentSize

				Twen:Create(UIAspectRatioConstraint,TweenInfo1,{
					AspectRatio = 7.65
				}):Play();

				UICorner.CornerRadius = UDim.new(0, 2)
				UICorner.Parent = FunctionButton

				DropShadow.Name = "DropShadow"
				DropShadow.Parent = FunctionButton
				DropShadow.AnchorPoint = Vector2.new(0.5, 0.5)
				DropShadow.BackgroundTransparency = 1.000
				DropShadow.BorderSizePixel = 0
				DropShadow.Position = UDim2.new(0.5, 0, 0.5, 0)
				DropShadow.Size = UDim2.new(1, 20, 1, 20)
				DropShadow.ZIndex = 16
				DropShadow.Image = "rbxassetid://6015897843"
				DropShadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
				DropShadow.ImageTransparency = 0.600
				DropShadow.ScaleType = Enum.ScaleType.Slice
				DropShadow.SliceCenter = Rect.new(49, 49, 450, 450)

				TextInt.Name = "TextInt"
				TextInt.Parent = FunctionButton
				TextInt.AnchorPoint = Vector2.new(0.5, 0.5)
				TextInt.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
				TextInt.BackgroundTransparency = 1.000
				TextInt.BorderColor3 = Color3.fromRGB(0, 0, 0)
				TextInt.BorderSizePixel = 0
				TextInt.Position = UDim2.new(0.5, 0, 0.5, 0)
				TextInt.Size = UDim2.new(1, 0, 0.479999989, 0)
				TextInt.ZIndex = 18
				TextInt.Font = Enum.Font.GothamBold
				TextInt.Text = cfg.Title
				TextInt.TextColor3 = Color3.fromRGB(255, 255, 255)
				TextInt.TextScaled = true
				TextInt.TextSize = 14.000
				TextInt.TextWrapped = true
				TextInt.TextTransparency = 0.25;

				UIGradient.Rotation = 90
				UIGradient.Transparency = NumberSequence.new{NumberSequenceKeypoint.new(0.00, 0.00), NumberSequenceKeypoint.new(0.84, 0.25), NumberSequenceKeypoint.new(1.00, 1.00)}
				UIGradient.Parent = TextInt

				Button.Name = "Button"
				Button.Parent = FunctionButton
				Button.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
				Button.BackgroundTransparency = 1.000
				Button.BorderColor3 = Color3.fromRGB(0, 0, 0)
				Button.BorderSizePixel = 0
				Button.Size = UDim2.new(1, 0, 1, 0)
				Button.ZIndex = 15
				Button.Font = Enum.Font.SourceSans
				Button.Text = ""
				Button.TextColor3 = Color3.fromRGB(0, 0, 0)
				Button.TextSize = 14.000
				Button.TextTransparency = 1.000

				UIStroke.Transparency = 0.920
				UIStroke.Color = Color3.fromRGB(255, 255, 255)
				UIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
				UIStroke.Parent = FunctionButton

				Button.MouseEnter:Connect(function()
					Twen:Create(DropShadow,TweenInfo.new(0.2),{
						ImageTransparency = 0.35
					}):Play()

					Twen:Create(TextInt,TweenInfo.new(0.2),{
						TextTransparency = 0
					}):Play()
				end)

				Button.MouseLeave:Connect(function()
					Twen:Create(DropShadow,TweenInfo.new(0.2),{
						ImageTransparency = 0.600
					}):Play()

					Twen:Create(TextInt,TweenInfo.new(0.2),{
						TextTransparency = 0.25
					}):Play()
				end)

				Button.MouseButton1Click:Connect(function()
					task.spawn(cfg.Callback);
				end)

				return {
					Visible = function(newindx)
						FunctionButton.Visible = newindx
					end,
					Fire = cfg.Callback
				};
			end;

			function SectionTable:NewKeybind(ctfx)
				ctfx = Config(ctfx,{
					Title = "Keybind",
					Callback = function() end,
					Default = Enum.KeyCode.E,

				});

				local BindEvent = Instance.new('BindableEvent',Section);
				local FunctionKeybind = Instance.new("Frame")
				local UIAspectRatioConstraint = Instance.new("UIAspectRatioConstraint")
				local TextInt = Instance.new("TextLabel")
				local UIGradient = Instance.new("UIGradient")
				local Button = Instance.new("TextButton")
				local UIStroke = Instance.new("UIStroke")
				local System = Instance.new("Frame")
				local UICorner = Instance.new("UICorner")
				local UIStroke_2 = Instance.new("UIStroke")
				local Bindkey = Instance.new("TextLabel")
				local UICorner_2 = Instance.new("UICorner")
				BindEvent.Name = tostring(ctfx.Title)
				FunctionKeybind.Name = "FunctionKeybind"
				FunctionKeybind.Parent = Section
				FunctionKeybind.BackgroundColor3 = Color3.fromRGB(17, 17, 17)
				FunctionKeybind.BackgroundTransparency = 0.800
				FunctionKeybind.BorderColor3 = Color3.fromRGB(0, 0, 0)
				FunctionKeybind.BorderSizePixel = 0
				FunctionKeybind.Size = UDim2.new(0.949999988, 0, 0.5, 0)
				FunctionKeybind.ZIndex = 17

				UIAspectRatioConstraint.Parent = FunctionKeybind
				UIAspectRatioConstraint.AspectRatio = 8.000
				UIAspectRatioConstraint.AspectType = Enum.AspectType.ScaleWithParentSize

				TextInt.Name = "TextInt"
				TextInt.Parent = FunctionKeybind
				TextInt.AnchorPoint = Vector2.new(0.5, 0.5)
				TextInt.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
				TextInt.BackgroundTransparency = 1.000
				TextInt.BorderColor3 = Color3.fromRGB(0, 0, 0)
				TextInt.BorderSizePixel = 0
				TextInt.Position = UDim2.new(0.5, 0, 0.5, 0)
				TextInt.Size = UDim2.new(0.949999988, 0, 0.479999989, 0)
				TextInt.ZIndex = 18
				TextInt.Font = Enum.Font.GothamBold
				TextInt.Text = ctfx.Title
				TextInt.TextColor3 = Color3.fromRGB(255, 255, 255)
				TextInt.TextScaled = true
				TextInt.TextSize = 14.000
				TextInt.TextTransparency = 0.250
				TextInt.TextWrapped = true
				TextInt.TextXAlignment = Enum.TextXAlignment.Left

				UIGradient.Rotation = 90
				UIGradient.Transparency = NumberSequence.new{NumberSequenceKeypoint.new(0.00, 0.00), NumberSequenceKeypoint.new(0.84, 0.25), NumberSequenceKeypoint.new(1.00, 1.00)}
				UIGradient.Parent = TextInt

				Button.Name = "Button"
				Button.Parent = FunctionKeybind
				Button.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
				Button.BackgroundTransparency = 1.000
				Button.BorderColor3 = Color3.fromRGB(0, 0, 0)
				Button.BorderSizePixel = 0
				Button.Size = UDim2.new(1, 0, 1, 0)
				Button.ZIndex = 15
				Button.Font = Enum.Font.SourceSans
				Button.Text = ""
				Button.TextColor3 = Color3.fromRGB(0, 0, 0)
				Button.TextSize = 14.000
				Button.TextTransparency = 1.000

				UIStroke.Transparency = 0.950
				UIStroke.Color = Color3.fromRGB(255, 255, 255)
				UIStroke.Parent = FunctionKeybind

				System.Name = "System"
				System.Parent = FunctionKeybind
				System.AnchorPoint = Vector2.new(1, 0.5)
				System.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
				System.BackgroundTransparency = 1.000
				System.BorderColor3 = Color3.fromRGB(0, 0, 0)
				System.BorderSizePixel = 0
				System.Position = UDim2.new(0.975000024, 0, 0.5, 0)
				System.Size = UDim2.new(0, 50, 0.600000024, 0)
				System.ZIndex = 18

				UICorner.CornerRadius = UDim.new(0.349999994, 0)
				UICorner.Parent = System

				UIStroke_2.Transparency = 0.950
				UIStroke_2.Color = Color3.fromRGB(255, 255, 255)
				UIStroke_2.Parent = System

				Bindkey.Name = "Bindkey"
				Bindkey.Parent = System
				Bindkey.AnchorPoint = Vector2.new(0.5, 0.5)
				Bindkey.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
				Bindkey.BackgroundTransparency = 1.000
				Bindkey.BorderColor3 = Color3.fromRGB(0, 0, 0)
				Bindkey.BorderSizePixel = 0
				Bindkey.Position = UDim2.new(0.5, 0, 0.5, 0)
				Bindkey.Size = UDim2.new(1, 0, 0.649999976, 0)
				Bindkey.Font = Enum.Font.GothamBold
				Bindkey.Text = Input:GetStringForKeyCode(ctfx.Default) or ctfx.Default.Name;
				Bindkey.TextColor3 = Color3.fromRGB(255, 255, 255)
				Bindkey.TextScaled = true
				Bindkey.TextSize = 14.000
				Bindkey.TextTransparency = 0.500
				Bindkey.TextWrapped = true

				UICorner_2.CornerRadius = UDim.new(0, 2)
				UICorner_2.Parent = FunctionKeybind

				local IsWIP = false;
				local function UpdateUI(new)
					Bindkey.Text = (typeof(new) == 'string' and new) or new.Name;

					local size = TextServ:GetTextSize(Bindkey.Text,Bindkey.TextSize,Bindkey.Font,Vector2.new(math.huge,math.huge));

					Twen:Create(System,TweenInfo.new(0.2),{
						Size = UDim2.new(0, size.X + 2, 0.600000024, 0)
					}):Play()
				end;

				UpdateUI(ctfx.Default)

				Button.MouseButton1Click:Connect(function()
					if IsWIP then return end;

					IsWIP = true;


					Twen:Create(TextInt,TweenInfo.new(0.1),{
						TextTransparency = 0
					}):Play();

					local Signal = Input.InputBegan:Connect(function(key)
						if key.KeyCode then
							if key.KeyCode ~= Enum.KeyCode.Unknown then
								BindEvent:Fire(key.KeyCode);
							end;
						end;
					end)

					UpdateUI('...')
					local Bind = BindEvent.Event:Wait();
					Twen:Create(TextInt,TweenInfo.new(0.1),{
						TextTransparency = 0.250
					}):Play();
					Signal:Disconnect()
					UpdateUI(Bind)

					IsWIP = false;
					ctfx.Callback(Bind);


				end)

				return {
					Visible = function(newindx)
						FunctionKeybind.Visible = newindx
					end,
					Value = function(lrm)
						UpdateUI(lrm)


						ctfx.Callback(lrm);
					end,
				};
			end;

			function SectionTable:NewSlider(slider)
				slider = Config(slider,{
					Title = "Slider",
					Min = 0,
					Max = 100,
					Default = 50,
					Callback = function()

					end,
				});

				local FunctionSlider = Instance.new("Frame")
				local UIAspectRatioConstraint = Instance.new("UIAspectRatioConstraint")
				local TextInt = Instance.new("TextLabel")
				local UIGradient = Instance.new("UIGradient")
				local UIStroke = Instance.new("UIStroke")
				local UICorner = Instance.new("UICorner")
				local ValueText = Instance.new("TextLabel")
				local UIGradient_2 = Instance.new("UIGradient")
				local MFrame = Instance.new("Frame")
				local UICorner_2 = Instance.new("UICorner")
				local TFrame = Instance.new("Frame")
				local UICorner_3 = Instance.new("UICorner")
				local UIStroke_2 = Instance.new("UIStroke")

				FunctionSlider.Name = "FunctionSlider"
				FunctionSlider.Parent = Section
				FunctionSlider.BackgroundColor3 = Color3.fromRGB(17, 17, 17)
				FunctionSlider.BackgroundTransparency = 0.800
				FunctionSlider.BorderColor3 = Color3.fromRGB(0, 0, 0)
				FunctionSlider.BorderSizePixel = 0
				FunctionSlider.Size = UDim2.new(0.949999988, 0, 0.5, 0)
				FunctionSlider.ZIndex = 17

				UIAspectRatioConstraint.Parent = FunctionSlider
				UIAspectRatioConstraint.AspectRatio = 6.000
				UIAspectRatioConstraint.AspectType = Enum.AspectType.ScaleWithParentSize

				TextInt.Name = "TextInt"
				TextInt.Parent = FunctionSlider
				TextInt.AnchorPoint = Vector2.new(0.5, 0.5)
				TextInt.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
				TextInt.BackgroundTransparency = 1.000
				TextInt.BorderColor3 = Color3.fromRGB(0, 0, 0)
				TextInt.BorderSizePixel = 0
				TextInt.Position = UDim2.new(0.5, 0, 0.25999999, 0)
				TextInt.Size = UDim2.new(0.949999988, 0, 0.379999995, 0)
				TextInt.ZIndex = 18
				TextInt.Font = Enum.Font.GothamBold
				TextInt.Text = slider.Title
				TextInt.TextColor3 = Color3.fromRGB(255, 255, 255)
				TextInt.TextScaled = true
				TextInt.TextSize = 14.000
				TextInt.TextTransparency = 0.250
				TextInt.TextWrapped = true
				TextInt.TextXAlignment = Enum.TextXAlignment.Left

				UIGradient.Rotation = 90
				UIGradient.Transparency = NumberSequence.new{NumberSequenceKeypoint.new(0.00, 0.00), NumberSequenceKeypoint.new(0.84, 0.25), NumberSequenceKeypoint.new(1.00, 1.00)}
				UIGradient.Parent = TextInt

				UIStroke.Transparency = 0.950
				UIStroke.Color = Color3.fromRGB(255, 255, 255)
				UIStroke.Parent = FunctionSlider

				UICorner.CornerRadius = UDim.new(0, 2)
				UICorner.Parent = FunctionSlider

				ValueText.Name = "ValueText"
				ValueText.Parent = FunctionSlider
				ValueText.AnchorPoint = Vector2.new(0.5, 0.5)
				ValueText.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
				ValueText.BackgroundTransparency = 1.000
				ValueText.BorderColor3 = Color3.fromRGB(0, 0, 0)
				ValueText.BorderSizePixel = 0
				ValueText.Position = UDim2.new(0.5, 0, 0.25999999, 0)
				ValueText.Size = UDim2.new(0.949999988, 0, 0.349999994, 0)
				ValueText.ZIndex = 18
				ValueText.Font = Enum.Font.GothamBold
				ValueText.Text = tostring(slider.Default)..'/'..tostring(slider.Max)
				ValueText.TextColor3 = Color3.fromRGB(255, 255, 255)
				ValueText.TextScaled = true
				ValueText.TextSize = 14.000
				ValueText.TextTransparency = 0.500
				ValueText.TextWrapped = true
				ValueText.TextXAlignment = Enum.TextXAlignment.Right

				UIGradient_2.Rotation = 90
				UIGradient_2.Transparency = NumberSequence.new{NumberSequenceKeypoint.new(0.00, 0.00), NumberSequenceKeypoint.new(0.84, 0.25), NumberSequenceKeypoint.new(1.00, 1.00)}
				UIGradient_2.Parent = ValueText

				MFrame.Name = "MFrame"
				MFrame.Parent = FunctionSlider
				MFrame.AnchorPoint = Vector2.new(0.5, 0.5)
				MFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
				MFrame.BackgroundTransparency = 0.800
				MFrame.BorderColor3 = Color3.fromRGB(0, 0, 0)
				MFrame.BorderSizePixel = 0
				MFrame.ClipsDescendants = true
				MFrame.Position = UDim2.new(0.5, 0, 0.75, 0)
				MFrame.Size = UDim2.new(0.949999988, 0, 0.289999992, 0)
				MFrame.ZIndex = 18

				UICorner_2.CornerRadius = UDim.new(0, 2)
				UICorner_2.Parent = MFrame

				TFrame.Name = "TFrame"
				TFrame.Parent = MFrame
				TFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
				TFrame.BackgroundTransparency = 0.500
				TFrame.BorderColor3 = Color3.fromRGB(0, 0, 0)
				TFrame.BorderSizePixel = 0
				TFrame.Size = UDim2.new((slider.Default / slider.Max), 0, 1, 0)
				TFrame.ZIndex = 17

				UICorner_3.CornerRadius = UDim.new(0, 2)
				UICorner_3.Parent = TFrame

				UIStroke_2.Transparency = 0.975
				UIStroke_2.Color = Color3.fromRGB(255, 255, 255)
				UIStroke_2.Parent = MFrame

				local Holding = false

				local function update(Input)
					local SizeScale = math.clamp((((Input.Position.X) - MFrame.AbsolutePosition.X) / MFrame.AbsoluteSize.X), 0, 1)
					local Main = ((slider.Max - slider.Min) * SizeScale) + slider.Min;
					local Value = math.round(Main)
					local Size = UDim2.fromScale(SizeScale, 1)
					ValueText.Text = tostring(Value)..'/'..tostring(slider.Max)
					Twen:Create(TFrame,TweenInfo.new(0.1),{Size = Size}):Play()
					slider.Callback(Value);
				end

				MFrame.InputBegan:Connect(function(Input)
					if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
						Holding = true
						update(Input)
						Twen:Create(TextInt,TweenInfo.new(0.1),{
							TextTransparency = 0
						}):Play()
					end
				end)

				MFrame.InputEnded:Connect(function(Input)
					if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
						Holding = false
						Twen:Create(TextInt,TweenInfo.new(0.1),{
							TextTransparency = 0.3
						}):Play()
					end
				end)

				Input.InputChanged:Connect(function(Input)
					if Holding then
						if (Input.UserInputType==Enum.UserInputType.MouseMovement or Input.UserInputType==Enum.UserInputType.Touch)  then
							update(Input)
						end
					end
				end)

				return {
					Visible = function(newindx)
						FunctionSlider.Visible = newindx
					end,
					Value = function(lrm)
						TFrame.Size = UDim2.new((lrm / slider.Max), 0, 1, 0)

						slider.Callback(lrm);
					end,
				};
			end;

			function SectionTable:NewDropdown(drop)
				drop = Config(drop,{
					Title = "Dropdown",
					Data = {'One','Two','Three','Four'},
					Default = 'Two',
					Callback = function(a)

					end,
				});

				local FunctionDropdown = Instance.new("Frame")
				local UIAspectRatioConstraint = Instance.new("UIAspectRatioConstraint")
				local TextInt = Instance.new("TextLabel")
				local UIGradient = Instance.new("UIGradient")
				local UIStroke = Instance.new("UIStroke")
				local UICorner = Instance.new("UICorner")
				local MFrame = Instance.new("Frame")
				local UICorner_2 = Instance.new("UICorner")
				local UIStroke_2 = Instance.new("UIStroke")
				local ValueText = Instance.new("TextLabel")
				local UIGradient_2 = Instance.new("UIGradient")
				local Button = Instance.new("TextButton")

				FunctionDropdown.Name = "FunctionDropdown"
				FunctionDropdown.Parent = Section
				FunctionDropdown.BackgroundColor3 = Color3.fromRGB(17, 17, 17)
				FunctionDropdown.BackgroundTransparency = 0.800
				FunctionDropdown.BorderColor3 = Color3.fromRGB(0, 0, 0)
				FunctionDropdown.BorderSizePixel = 0
				FunctionDropdown.Size = UDim2.new(0.949999988, 0, 0.5, 0)
				FunctionDropdown.ZIndex = 17

				UIAspectRatioConstraint.Parent = FunctionDropdown
				UIAspectRatioConstraint.AspectRatio = 5.000
				UIAspectRatioConstraint.AspectType = Enum.AspectType.ScaleWithParentSize

				TextInt.Name = "TextInt"
				TextInt.Parent = FunctionDropdown
				TextInt.AnchorPoint = Vector2.new(0.5, 0.5)
				TextInt.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
				TextInt.BackgroundTransparency = 1.000
				TextInt.BorderColor3 = Color3.fromRGB(0, 0, 0)
				TextInt.BorderSizePixel = 0
				TextInt.Position = UDim2.new(0.5, 0, 0.200000003, 0)
				TextInt.Size = UDim2.new(0.949999988, 0, 0.319999993, 0)
				TextInt.ZIndex = 18
				TextInt.Font = Enum.Font.GothamBold
				TextInt.Text = drop.Title
				TextInt.TextColor3 = Color3.fromRGB(255, 255, 255)
				TextInt.TextScaled = true
				TextInt.TextSize = 14.000
				TextInt.TextTransparency = 0.250
				TextInt.TextWrapped = true
				TextInt.TextXAlignment = Enum.TextXAlignment.Left

				UIGradient.Rotation = 90
				UIGradient.Transparency = NumberSequence.new{NumberSequenceKeypoint.new(0.00, 0.00), NumberSequenceKeypoint.new(0.84, 0.25), NumberSequenceKeypoint.new(1.00, 1.00)}
				UIGradient.Parent = TextInt

				UIStroke.Transparency = 0.950
				UIStroke.Color = Color3.fromRGB(255, 255, 255)
				UIStroke.Parent = FunctionDropdown

				UICorner.CornerRadius = UDim.new(0, 2)
				UICorner.Parent = FunctionDropdown

				MFrame.Name = "MFrame"
				MFrame.Parent = FunctionDropdown
				MFrame.AnchorPoint = Vector2.new(0.5, 0.5)
				MFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
				MFrame.BackgroundTransparency = 0.800
				MFrame.BorderColor3 = Color3.fromRGB(0, 0, 0)
				MFrame.BorderSizePixel = 0
				MFrame.ClipsDescendants = true
				MFrame.Position = UDim2.new(0.5, 0, 0.699999988, 0)
				MFrame.Size = UDim2.new(0.949999988, 0, 0.375, 0)
				MFrame.ZIndex = 18

				UICorner_2.CornerRadius = UDim.new(0, 2)
				UICorner_2.Parent = MFrame

				UIStroke_2.Transparency = 0.975
				UIStroke_2.Color = Color3.fromRGB(255, 255, 255)
				UIStroke_2.Parent = MFrame

				ValueText.Name = "ValueText"
				ValueText.Parent = MFrame
				ValueText.AnchorPoint = Vector2.new(0.5, 0.5)
				ValueText.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
				ValueText.BackgroundTransparency = 1.000
				ValueText.BorderColor3 = Color3.fromRGB(0, 0, 0)
				ValueText.BorderSizePixel = 0
				ValueText.Position = UDim2.new(0.5, 0, 0.5, 0)
				ValueText.Size = UDim2.new(1, 0, 0.800000012, 0)
				ValueText.ZIndex = 18
				ValueText.Font = Enum.Font.GothamBold
				ValueText.Text = drop.Default or "NONE"
				ValueText.TextColor3 = Color3.fromRGB(255, 255, 255)
				ValueText.TextScaled = true
				ValueText.TextSize = 14.000
				ValueText.TextTransparency = 0.500
				ValueText.TextWrapped = true

				MFrame.MouseEnter:Connect(function()
					Twen:Create(ValueText,TweenInfo.new(0.3),{
						TextTransparency = 0.1
					}):Play()
				end)

				MFrame.MouseLeave:Connect(function()
					Twen:Create(ValueText,TweenInfo.new(0.3),{
						TextTransparency = 0.500
					}):Play()
				end)

				UIGradient_2.Rotation = 90
				UIGradient_2.Transparency = NumberSequence.new{NumberSequenceKeypoint.new(0.00, 0.00), NumberSequenceKeypoint.new(0.84, 0.25), NumberSequenceKeypoint.new(1.00, 1.00)}
				UIGradient_2.Parent = ValueText

				Button.Name = "Button"
				Button.Parent = FunctionDropdown
				Button.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
				Button.BackgroundTransparency = 1.000
				Button.BorderColor3 = Color3.fromRGB(0, 0, 0)
				Button.BorderSizePixel = 0
				Button.Size = UDim2.new(1, 0, 1, 0)
				Button.ZIndex = 25
				Button.Font = Enum.Font.SourceSans
				Button.Text = ""
				Button.TextColor3 = Color3.fromRGB(0, 0, 0)
				Button.TextSize = 14.000
				Button.TextTransparency = 1.000

				local Updater = function(value)
					drop.Default = value;
					ValueText.Text = tostring(value);
					drop.Callback(value);
				end;

				Button.MouseButton1Click:Connect(function()
					WindowTable.Dropdown:Setup(MFrame)

					WindowTable.Dropdown:Open(drop.Data,drop.Default,Updater)
				end)

				return {
					Visible = function(newindx)
						FunctionDropdown.Visible = newindx
					end,
					Value = function(value)
						ValueText.Text = tostring(value);
						drop.Callback(value);
					end,
					Open = function(value)
						WindowTable.Dropdown:Setup(MFrame)

						WindowTable.Dropdown:Open(drop.Data,drop.Default,Updater)
					end,

					Close = function(value)
						WindowTable.Dropdown:Close();
					end,
					Clear = function()
						drop.Data = {}
					end,
					Set = function(table)
						drop.Data = table
					end
				};
			end;

			function SectionTable:NewTextbox(conf)
				conf = Config(conf,{
					Title = "Textbox",
					Default = '',
					FileType = "",
					Callback = function(a)

					end,
				})

				local FunctionTextbox = Instance.new("Frame")
				local UIAspectRatioConstraint = Instance.new("UIAspectRatioConstraint")
				local TextInt = Instance.new("TextLabel")
				local UIGradient = Instance.new("UIGradient")
				local UIStroke = Instance.new("UIStroke")
				local UICorner = Instance.new("UICorner")
				local MFrame = Instance.new("Frame")
				local UICorner_2 = Instance.new("UICorner")
				local UIStroke_2 = Instance.new("UIStroke")
				local FileType = Instance.new("TextLabel")
				local UIGradient_2 = Instance.new("UIGradient")
				local TextBox = Instance.new("TextBox")
				local Button = Instance.new("TextButton")

				FunctionTextbox.Name = "FunctionTextbox"
				FunctionTextbox.Parent = Section
				FunctionTextbox.BackgroundColor3 = Color3.fromRGB(17, 17, 17)
				FunctionTextbox.BackgroundTransparency = 0.800
				FunctionTextbox.BorderColor3 = Color3.fromRGB(0, 0, 0)
				FunctionTextbox.BorderSizePixel = 0
				FunctionTextbox.Size = UDim2.new(0.949999988, 0, 0.5, 0)
				FunctionTextbox.ZIndex = 17

				UIAspectRatioConstraint.Parent = FunctionTextbox
				UIAspectRatioConstraint.AspectRatio = 5.000
				UIAspectRatioConstraint.AspectType = Enum.AspectType.ScaleWithParentSize

				TextInt.Name = "TextInt"
				TextInt.Parent = FunctionTextbox
				TextInt.AnchorPoint = Vector2.new(0.5, 0.5)
				TextInt.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
				TextInt.BackgroundTransparency = 1.000
				TextInt.BorderColor3 = Color3.fromRGB(0, 0, 0)
				TextInt.BorderSizePixel = 0
				TextInt.Position = UDim2.new(0.5, 0, 0.200000003, 0)
				TextInt.Size = UDim2.new(0.949999988, 0, 0.319999993, 0)
				TextInt.ZIndex = 18
				TextInt.Font = Enum.Font.GothamBold
				TextInt.Text = conf.Title
				TextInt.TextColor3 = Color3.fromRGB(255, 255, 255)
				TextInt.TextScaled = true
				TextInt.TextSize = 14.000
				TextInt.TextTransparency = 0.250
				TextInt.TextWrapped = true
				TextInt.TextXAlignment = Enum.TextXAlignment.Left

				UIGradient.Rotation = 90
				UIGradient.Transparency = NumberSequence.new{NumberSequenceKeypoint.new(0.00, 0.00), NumberSequenceKeypoint.new(0.84, 0.25), NumberSequenceKeypoint.new(1.00, 1.00)}
				UIGradient.Parent = TextInt

				UIStroke.Transparency = 0.950
				UIStroke.Color = Color3.fromRGB(255, 255, 255)
				UIStroke.Parent = FunctionTextbox

				UICorner.CornerRadius = UDim.new(0, 2)
				UICorner.Parent = FunctionTextbox

				MFrame.Name = "MFrame"
				MFrame.Parent = FunctionTextbox
				MFrame.AnchorPoint = Vector2.new(0.5, 0.5)
				MFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
				MFrame.BackgroundTransparency = 0.800
				MFrame.BorderColor3 = Color3.fromRGB(0, 0, 0)
				MFrame.BorderSizePixel = 0
				MFrame.ClipsDescendants = true
				MFrame.Position = UDim2.new(0.5, 0, 0.699999988, 0)
				MFrame.Size = UDim2.new(0.949999988, 0, 0.375, 0)
				MFrame.ZIndex = 18

				UICorner_2.CornerRadius = UDim.new(0, 2)
				UICorner_2.Parent = MFrame

				UIStroke_2.Transparency = 0.975
				UIStroke_2.Color = Color3.fromRGB(255, 255, 255)
				UIStroke_2.Parent = MFrame

				FileType.Name = "FileType"
				FileType.Parent = MFrame
				FileType.AnchorPoint = Vector2.new(0.5, 0.5)
				FileType.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
				FileType.BackgroundTransparency = 1.000
				FileType.BorderColor3 = Color3.fromRGB(0, 0, 0)
				FileType.BorderSizePixel = 0
				FileType.Position = UDim2.new(0.5, 0, 0.5, 0)
				FileType.Size = UDim2.new(0.899999976, 0, 0.800000012, 0)
				FileType.ZIndex = 18
				FileType.Font = Enum.Font.GothamBold
				FileType.Text = conf.FileType
				FileType.TextColor3 = Color3.fromRGB(255, 255, 255)
				FileType.TextScaled = true
				FileType.TextSize = 14.000
				FileType.TextTransparency = 0.100
				FileType.TextWrapped = true
				FileType.TextXAlignment = Enum.TextXAlignment.Right

				UIGradient_2.Rotation = 90
				UIGradient_2.Transparency = NumberSequence.new{NumberSequenceKeypoint.new(0.00, 0.00), NumberSequenceKeypoint.new(0.84, 0.25), NumberSequenceKeypoint.new(1.00, 1.00)}
				UIGradient_2.Parent = FileType

				TextBox.Parent = MFrame
				TextBox.AnchorPoint = Vector2.new(0.5, 0.5)
				TextBox.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
				TextBox.BackgroundTransparency = 1.000
				TextBox.BorderColor3 = Color3.fromRGB(0, 0, 0)
				TextBox.BorderSizePixel = 0
				TextBox.Position = UDim2.new(0.425999999, 0, 0.5, 0)
				TextBox.Size = UDim2.new(0.753000021, 0, 0.800000012, 0)
				TextBox.ZIndex = 35
				TextBox.ClearTextOnFocus = false
				TextBox.Font = Enum.Font.GothamBold
				TextBox.Text = tostring(conf.Default) or "";
				TextBox.TextColor3 = Color3.fromRGB(255, 255, 255)
				TextBox.TextScaled = true
				TextBox.TextSize = 14.000
				TextBox.TextTransparency = 0.600
				TextBox.TextWrapped = true
				TextBox.TextXAlignment = Enum.TextXAlignment.Left

				Button.Name = "Button"
				Button.Parent = FunctionTextbox
				Button.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
				Button.BackgroundTransparency = 1.000
				Button.BorderColor3 = Color3.fromRGB(0, 0, 0)
				Button.BorderSizePixel = 0
				Button.Size = UDim2.new(1, 0, 1, 0)
				Button.ZIndex = 25
				Button.Font = Enum.Font.SourceSans
				Button.Text = "";
				Button.TextColor3 = Color3.fromRGB(0, 0, 0)
				Button.TextSize = 14.000
				Button.TextTransparency = 1.000


				TextBox.FocusLost:Connect(function(press)
					conf.Callback(TextBox.Text);
				end)
			end;

			return SectionTable;
		end;

		return TabTable;
	end;

	local dragToggle = nil;
	local dragSpeed = 0.1;
	local dragStart = nil;
	local startPos = nil;

	local function updateInput(input)
		WindowTable.ElBlurUI.Update()
		local delta = input.Position - dragStart;
		local position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X,
			startPos.Y.Scale, startPos.Y.Offset + delta.Y);
		game:GetService('TweenService'):Create(MainFrame, TweenInfo.new(dragSpeed), {Position = position}):Play()
	end;

	InputFrame.InputBegan:Connect(function(input)
		if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then 
			dragToggle = true
			dragStart = input.Position
			startPos = MainFrame.Position
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragToggle = false;
				end;
			end)
		end;
	end)

	Input.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
			if dragToggle then
				updateInput(input);
			end;
		end;
	end)

	return WindowTable;
end;

Library.NewAuth = function(conf)
	conf = Config(conf,{
		Title = "Nothing $ KEY SYSTEM",
		GetKey = function() return 'https://example.com' end,
		Auth = function(key) if key == '1 or 1' then return key; end; end,
		Freeze = false,
	});


	if conf.Auth then
		if debug.info(conf.Auth,'s') == '[C]' then
			if error then
				error('huh');
			end;

			return;
		end;
	end;

	if conf.GetKey then
		if debug.info(conf.GetKey,'s') == '[C]' then
			if error then
				error('huh');
			end;

			return;
		end;
	end;

	local ScreenGui = Instance.new("ScreenGui")
	local vaid = Instance.new('BindableEvent')
	local Auth = Instance.new("Frame")
	local MainFrame = Instance.new("Frame")
	local BlockFrame = Instance.new("Frame")
	local UICorner = Instance.new("UICorner")
	local UIGradient = Instance.new("UIGradient")
	local UICorner_2 = Instance.new("UICorner")
	local Button2 = Instance.new("TextButton")
	local UICorner_3 = Instance.new("UICorner")
	local DropShadow = Instance.new("ImageLabel")
	local UIStroke = Instance.new("UIStroke")
	local TextBox = Instance.new("TextBox")
	local UICorner_4 = Instance.new("UICorner")
	local DropShadow_2 = Instance.new("ImageLabel")
	local UIStroke_2 = Instance.new("UIStroke")
	local Button1 = Instance.new("TextButton")
	local UICorner_5 = Instance.new("UICorner")
	local DropShadow_3 = Instance.new("ImageLabel")
	local UIStroke_3 = Instance.new("UIStroke")
	local MainDropShadow = Instance.new("ImageLabel")
	local Title = Instance.new("TextLabel")
	local UIGradient_2 = Instance.new("UIGradient")
	local UICorner_6 = Instance.new("UICorner")

	ScreenGui.Parent = CoreGui
	ScreenGui.IgnoreGuiInset = true
	ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
	ScreenGui.Name = game:GetService('HttpService'):GenerateGUID(false)..tostring(tick())

	Auth.Name = "Auth"
	Auth.Parent = ScreenGui
	Auth.Active = true
	Auth.AnchorPoint = Vector2.new(0.5, 0.5)
	Auth.BackgroundColor3 = Color3.fromRGB(17, 17, 17)
	Auth.BackgroundTransparency = 1.000
	Auth.BorderColor3 = Color3.fromRGB(0, 0, 0)
	Auth.BorderSizePixel = 0
	Auth.ClipsDescendants = true
	Auth.Position = UDim2.new(0.5, 0, 0.5, 0)
	Auth.Size = UDim2.new(0.100000001, 245, 0.100000001, 115)

	local BlueEffect = ElBlurSource.new(MainFrame,true);
	local cose = {Library.GradientImage(MainFrame),
		Library.GradientImage(MainFrame,Color3.fromRGB(255, 0, 4))}

	MainFrame.Name = "MainFrame"
	MainFrame.Parent = Auth
	MainFrame.Active = true
	MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
	MainFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	MainFrame.BackgroundTransparency = 0.500
	MainFrame.BorderColor3 = Color3.fromRGB(0, 0, 0)
	MainFrame.BorderSizePixel = 0
	MainFrame.Position = UDim2.new(0.5, 0, -1.5, 0)
	MainFrame.Size = UDim2.new(0.8,0,0.8,0)
	Twen:Create(MainFrame,TweenInfo.new(1,Enum.EasingStyle.Quint,Enum.EasingDirection.InOut),{
		Position = UDim2.new(0.5, 0, 0.5, 0),
		Size = UDim2.new(1, 0, 1, 0)
	}):Play();

	BlockFrame.Name = "BlockFrame"
	BlockFrame.Parent = MainFrame
	BlockFrame.AnchorPoint = Vector2.new(0.5, 0.5)
	BlockFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	BlockFrame.BackgroundTransparency = 0.800
	BlockFrame.BorderColor3 = Color3.fromRGB(0, 0, 0)
	BlockFrame.BorderSizePixel = 0
	BlockFrame.Position = UDim2.new(0.5, 0, 0.150000006, 0)
	BlockFrame.Size = UDim2.new(1, 0, 0, 1)
	BlockFrame.ZIndex = 3

	UICorner.CornerRadius = UDim.new(0.5, 0)
	UICorner.Parent = BlockFrame

	UIGradient.Transparency = NumberSequence.new{NumberSequenceKeypoint.new(0.00, 1.00), NumberSequenceKeypoint.new(0.05, 0.00), NumberSequenceKeypoint.new(0.96, 0.00), NumberSequenceKeypoint.new(1.00, 1.00)}
	UIGradient.Parent = BlockFrame

	UICorner_2.CornerRadius = UDim.new(0, 7)
	UICorner_2.Parent = MainFrame

	Button2.Name = "Button2"
	Button2.Parent = MainFrame
	Button2.AnchorPoint = Vector2.new(0.5, 0.5)
	Button2.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	Button2.BackgroundTransparency = 0.500
	Button2.BorderColor3 = Color3.fromRGB(0, 0, 0)
	Button2.BorderSizePixel = 0
	Button2.Position = UDim2.new(0.75, 0, 0.649999976, 0)
	Button2.Size = UDim2.new(0.447547048, 0, 0.155089319, 0)
	Button2.ZIndex = 3
	Button2.Font = Enum.Font.GothamBold
	Button2.Text = "ACTIVATE"
	Button2.TextColor3 = Color3.fromRGB(255, 255, 255)
	Button2.TextSize = 14.000

	UICorner_3.CornerRadius = UDim.new(0, 2)
	UICorner_3.Parent = Button2

	DropShadow.Name = "DropShadow"
	DropShadow.Parent = Button2
	DropShadow.AnchorPoint = Vector2.new(0.5, 0.5)
	DropShadow.BackgroundTransparency = 1.000
	DropShadow.BorderSizePixel = 0
	DropShadow.Position = UDim2.new(0.5, 0, 0.5, 0)
	DropShadow.Size = UDim2.new(1, 37, 1, 37)
	DropShadow.Image = "rbxassetid://6015897843"
	DropShadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
	DropShadow.ImageTransparency = 0.600
	DropShadow.ScaleType = Enum.ScaleType.Slice
	DropShadow.SliceCenter = Rect.new(49, 49, 450, 450)

	UIStroke.Transparency = 1
	UIStroke.Color = Color3.fromRGB(255, 255, 255)
	UIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	UIStroke.Parent = Button2
	Twen:Create(UIStroke,TweenInfo.new(1,Enum.EasingStyle.Quint,Enum.EasingDirection.InOut),{
		Transparency = 0.900
	}):Play();

	TextBox.Parent = MainFrame
	TextBox.AnchorPoint = Vector2.new(0.5, 0.5)
	TextBox.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	TextBox.BackgroundTransparency = 0.500
	TextBox.BorderColor3 = Color3.fromRGB(0, 0, 0)
	TextBox.BorderSizePixel = 0
	TextBox.Position = UDim2.new(0.5, 0, 0.300000012, 0)
	TextBox.Size = UDim2.new(0.800000012, 0, 0.115000002, 0)
	TextBox.ZIndex = 2
	TextBox.ClearTextOnFocus = false
	TextBox.Font = Enum.Font.Unknown
	TextBox.PlaceholderText = "ENTER KEY"
	TextBox.Text = ""
	TextBox.TextColor3 = Color3.fromRGB(255, 255, 255)
	TextBox.TextSize = 10.000
	TextBox.TextTransparency = 0.250
	TextBox.TextWrapped = true

	UICorner_4.CornerRadius = UDim.new(0, 2)
	UICorner_4.Parent = TextBox

	DropShadow_2.Name = "DropShadow"
	DropShadow_2.Parent = TextBox
	DropShadow_2.AnchorPoint = Vector2.new(0.5, 0.5)
	DropShadow_2.BackgroundTransparency = 1.000
	DropShadow_2.BorderSizePixel = 0
	DropShadow_2.Position = UDim2.new(0.5, 0, 0.5, 0)
	DropShadow_2.Size = UDim2.new(1, 37, 1, 37)
	DropShadow_2.Image = "rbxassetid://6015897843"
	DropShadow_2.ImageColor3 = Color3.fromRGB(0, 0, 0)
	DropShadow_2.ImageTransparency = 0.600
	DropShadow_2.ScaleType = Enum.ScaleType.Slice
	DropShadow_2.SliceCenter = Rect.new(49, 49, 450, 450)

	UIStroke_2.Transparency = 1
	UIStroke_2.Color = Color3.fromRGB(255, 255, 255)
	UIStroke_2.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	UIStroke_2.Parent = TextBox
	Twen:Create(UIStroke_2,TweenInfo.new(1,Enum.EasingStyle.Quint,Enum.EasingDirection.InOut),{
		Transparency = 0.900
	}):Play();
	Button1.Name = "Button1"
	Button1.Parent = MainFrame
	Button1.AnchorPoint = Vector2.new(0.5, 0.5)
	Button1.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	Button1.BackgroundTransparency = 0.500
	Button1.BorderColor3 = Color3.fromRGB(0, 0, 0)
	Button1.BorderSizePixel = 0
	Button1.Position = UDim2.new(0.25, 0, 0.649999976, 0)
	Button1.Size = UDim2.new(0.447547048, 0, 0.155089319, 0)
	Button1.ZIndex = 3
	Button1.Font = Enum.Font.GothamBold
	Button1.Text = "GET KEY"
	Button1.TextColor3 = Color3.fromRGB(255, 255, 255)
	Button1.TextSize = 14.000

	UICorner_5.CornerRadius = UDim.new(0, 2)
	UICorner_5.Parent = Button1

	DropShadow_3.Name = "DropShadow"
	DropShadow_3.Parent = Button1
	DropShadow_3.AnchorPoint = Vector2.new(0.5, 0.5)
	DropShadow_3.BackgroundTransparency = 1.000
	DropShadow_3.BorderSizePixel = 0
	DropShadow_3.Position = UDim2.new(0.5, 0, 0.5, 0)
	DropShadow_3.Size = UDim2.new(1, 37, 1, 37)
	DropShadow_3.Image = "rbxassetid://6015897843"
	DropShadow_3.ImageColor3 = Color3.fromRGB(0, 0, 0)
	DropShadow_3.ImageTransparency = 0.600
	DropShadow_3.ScaleType = Enum.ScaleType.Slice
	DropShadow_3.SliceCenter = Rect.new(49, 49, 450, 450)

	UIStroke_3.Transparency = 1
	UIStroke_3.Color = Color3.fromRGB(255, 255, 255)
	UIStroke_3.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	UIStroke_3.Parent = Button1
	Twen:Create(UIStroke_3,TweenInfo.new(1,Enum.EasingStyle.Quint,Enum.EasingDirection.InOut),{
		Transparency = 0.900
	}):Play();
	MainDropShadow.Name = "MainDropShadow"
	MainDropShadow.Parent = MainFrame
	MainDropShadow.AnchorPoint = Vector2.new(0.5, 0.5)
	MainDropShadow.BackgroundTransparency = 1.000
	MainDropShadow.BorderSizePixel = 0
	MainDropShadow.Position = UDim2.new(0.5, 0, 0.5, 0)
	MainDropShadow.Rotation = 0.0001
	MainDropShadow.Size = UDim2.new(1, 47, 1, 47)
	MainDropShadow.ZIndex = 0
	MainDropShadow.Image = "rbxassetid://6015897843"
	MainDropShadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
	MainDropShadow.ImageTransparency = 1
	MainDropShadow.ScaleType = Enum.ScaleType.Slice
	MainDropShadow.SliceCenter = Rect.new(49, 49, 450, 450)
	Twen:Create(MainDropShadow,TweenInfo.new(2,Enum.EasingStyle.Quint,Enum.EasingDirection.InOut),{
		ImageTransparency = 0.600
	}):Play();
	Title.Name = "Title"
	Title.Parent = MainFrame
	Title.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	Title.BackgroundTransparency = 1.000
	Title.BorderColor3 = Color3.fromRGB(0, 0, 0)
	Title.BorderSizePixel = 0
	Title.Position = UDim2.new(0.0250000004, 0, 0.0350000001, 0)
	Title.Size = UDim2.new(0.899999976, 0, 0.075000003, 0)
	Title.Font = Enum.Font.GothamBold
	Title.Text = conf.Title;
	Title.TextColor3 = Color3.fromRGB(255, 255, 255)
	Title.TextScaled = true
	Title.TextSize = 14.000
	Title.TextWrapped = true
	Title.TextXAlignment = Enum.TextXAlignment.Left

	UIGradient_2.Rotation = 90
	UIGradient_2.Transparency = NumberSequence.new{NumberSequenceKeypoint.new(0.00, 0.00), NumberSequenceKeypoint.new(0.75, 0.27), NumberSequenceKeypoint.new(1.00, 1.00)}
	UIGradient_2.Parent = Title

	UICorner_6.CornerRadius = UDim.new(0, 7)
	UICorner_6.Parent = MainFrame

	local id = tostring(math.random(1,100))..tostring(math.random(1,100))..tostring(math.random(1,100))..tostring(math.random(1,100))..tostring(math.random(1,100))..tostring(math.random(1,100))..tostring(tick()):reverse();

	Button1.MouseButton1Click:Connect(function()
		local str = conf.GetKey();

		if str then
			if typeof(str) == 'string' then
				local clip = getfenv()['toclipboard'] or getfenv()['setclipboard'] or getfenv()['print'];

				clip(str);
			end;
		end;
	end);


	Button2.MouseButton1Click:Connect(function()
		local str = conf.Auth(TextBox.Text);

		if str then
			TextBox.Text = "*/*/*/*/*/*/*/*/*/*/*/*/*/*";

			vaid:Fire(id)
		else
			TextBox.Text = "";
		end;
	end);

	if conf.Freeze then
		while ScreenGui do task.wait();
			local ez = vaid.Event:Wait();

			if ez == id then
				break;
			end;
		end;
	end;

	return {
		Close = function()
			Twen:Create(MainDropShadow,TweenInfo.new(1,Enum.EasingStyle.Quint,Enum.EasingDirection.InOut),{
				ImageTransparency = 1
			}):Play();

			BlueEffect.Destroy();


			for i,v in ipairs(cose) do
				game:GetService('RunService'):UnbindFromRenderStep(v);
			end;

			Twen:Create(MainFrame,TweenInfo.new(1,Enum.EasingStyle.Quint,Enum.EasingDirection.InOut),{
				Size = UDim2.new(0.8,0,0.8,0)
			}):Play();

			task.delay(1,function()
				Twen:Create(MainFrame,TweenInfo.new(1,Enum.EasingStyle.Quint,Enum.EasingDirection.InOut),{
					Position = UDim2.new(0.5, 0, 1.5, 0),
					Size = UDim2.new(0.8,0,0.8,0)
				}):Play();

				task.delay(1.2,function()

					ScreenGui:Destroy()

				end)
			end)
		end,
	}
end;

Library.Notification = function()
	local Notification = Instance.new("ScreenGui")
	local Frame = Instance.new("Frame")
	local UIListLayout = Instance.new("UIListLayout")

	Notification.Name = "Notification"
	Notification.Parent = CoreGui
	Notification.ResetOnSpawn = false
	Notification.ZIndexBehavior = Enum.ZIndexBehavior.Global
	Notification.Name = game:GetService('HttpService'):GenerateGUID(false)
	Notification.IgnoreGuiInset = true

	Frame.Parent = Notification
	Frame.AnchorPoint = Vector2.new(0.5, 0.5)
	Frame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	Frame.BackgroundTransparency = 1.000
	Frame.BorderColor3 = Color3.fromRGB(0, 0, 0)
	Frame.BorderSizePixel = 0
	Frame.Position = UDim2.new(0.151568726, 0, 0.5, 0)
	Frame.Size = UDim2.new(0.400000006, 0, 0.400000006, 0)
	Frame.SizeConstraint = Enum.SizeConstraint.RelativeYY

	UIListLayout.Parent = Frame
	UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
	UIListLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
	UIListLayout.Padding = UDim.new(0,2);

	return {
		new = function(ctfx)
			ctfx = Config(ctfx,{
				Title = "Notification",
				Description = "Description",
				Duration = 5,
				Icon = "rbxassetid://7733993369"
			})
			local css_style = TweenInfo.new(0.5,Enum.EasingStyle.Quint,Enum.EasingDirection.InOut);
			local Notifiy = Instance.new("Frame")
			local UICorner = Instance.new("UICorner")
			local icon = Instance.new("ImageLabel")
			local UICorner_2 = Instance.new("UICorner")
			local TextLabel = Instance.new("TextLabel")
			local TextLabel_2 = Instance.new("TextLabel")
			local DropShadow = Instance.new('ImageLabel')

			DropShadow.Name = "DropShadow"
			DropShadow.Parent = Notifiy
			DropShadow.AnchorPoint = Vector2.new(0.5, 0.5)
			DropShadow.BackgroundTransparency = 1.000
			DropShadow.BorderSizePixel = 0
			DropShadow.Position = UDim2.new(0.5, 0, 0.5, 0)
			DropShadow.Size = UDim2.new(1, 37, 1, 37)
			DropShadow.Image = "rbxassetid://6015897843"
			DropShadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
			DropShadow.ImageTransparency = 1
			DropShadow.ScaleType = Enum.ScaleType.Slice
			DropShadow.Rotation = 0.001
			DropShadow.SliceCenter = Rect.new(49, 49, 450, 450)
			Twen:Create(DropShadow,css_style,{
				ImageTransparency = 0.600
			}):Play()

			Notifiy.Name = "Notifiy"
			Notifiy.Parent = Frame
			Notifiy.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
			Notifiy.BackgroundTransparency = 1
			Notifiy.BorderColor3 = Color3.fromRGB(0, 0, 0)
			Notifiy.BorderSizePixel = 0
			Notifiy.ClipsDescendants = true
			Notifiy.Size = UDim2.new(0,0,0,0)
			Twen:Create(Notifiy,css_style,{
				BackgroundTransparency = 0.350,
				Size = UDim2.new(0.2, 0, 0.2, 0)
			}):Play()

			UICorner.CornerRadius = UDim.new(0.3,0)
			UICorner.Parent = Notifiy

			icon.Name = "icon"
			icon.Parent = Notifiy
			icon.AnchorPoint = Vector2.new(0.5, 0.5)
			icon.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			icon.BackgroundTransparency = 1.000
			icon.BorderColor3 = Color3.fromRGB(0, 0, 0)
			icon.BorderSizePixel = 0
			icon.Position = UDim2.new(0.5, 0, 0.5, 0)
			icon.Size = UDim2.new(0.3, 0, 0.3, 0)
			icon.SizeConstraint = Enum.SizeConstraint.RelativeYY
			icon.Image = Icons[ctfx.Icon] or ctfx.Icon
			icon.ImageTransparency = 1;

			Twen:Create(icon,css_style,{
				ImageTransparency = 0.1,
				Size = UDim2.new(0.699999988, 0, 0.699999988, 0)
			}):Play()


			UICorner_2.CornerRadius = UDim.new(1,0)
			UICorner_2.Parent = icon

			Twen:Create(UICorner_2,css_style,{
				CornerRadius = UDim.new(0.4, 0)
			}):Play()

			TextLabel.Parent = Notifiy
			TextLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			TextLabel.BackgroundTransparency = 1.000
			TextLabel.BorderColor3 = Color3.fromRGB(0, 0, 0)
			TextLabel.BorderSizePixel = 0
			TextLabel.Position = UDim2.new(2, 0, 0.130389422, 0)
			TextLabel.Size = UDim2.new(0.800069451, 0, 0.217663303, 0)
			TextLabel.Font = Enum.Font.GothamBold
			TextLabel.Text = ctfx.Title
			TextLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
			TextLabel.TextScaled = true
			TextLabel.TextSize = 14.000
			TextLabel.TextWrapped = true
			TextLabel.TextXAlignment = Enum.TextXAlignment.Left

			TextLabel_2.Parent = Notifiy
			TextLabel_2.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			TextLabel_2.BackgroundTransparency = 1.000
			TextLabel_2.BorderColor3 = Color3.fromRGB(0, 0, 0)
			TextLabel_2.BorderSizePixel = 0
			TextLabel_2.Position = UDim2.new(2, 0, 0.34770447, 0)
			TextLabel_2.Size = UDim2.new(0.769645274, 0, 0.502295375, 0)
			TextLabel_2.Font = Enum.Font.GothamBold
			TextLabel_2.Text = ctfx.Description
			TextLabel_2.TextColor3 = Color3.fromRGB(255, 255, 255)
			TextLabel_2.TextSize = 9.000
			TextLabel_2.TextTransparency = 0.500
			TextLabel_2.TextWrapped = true
			TextLabel_2.TextXAlignment = Enum.TextXAlignment.Left
			TextLabel_2.TextYAlignment = Enum.TextYAlignment.Top

			local mkView = function()
				Twen:Create(Notifiy,css_style,{
					Size = UDim2.new(1, 0, 0.2, 0)
				}):Play()

				Twen:Create(UICorner,css_style,{
					CornerRadius = UDim.new(0, 4)
				}):Play()

				Twen:Create(icon,css_style,{
					Position = UDim2.new(0.100000001, 0, 0.5, 0)
				}):Play()

				Twen:Create(TextLabel,css_style,{
					Position = UDim2.new(0.199930489, 0, 0.130389422, 0)
				}):Play()

				Twen:Create(TextLabel_2,css_style,{
					Position = UDim2.new(0.199930489, 0, 0.34770447, 0)
				}):Play()
			end;


			local mkLoad = function()
				Twen:Create(Notifiy,css_style,{
					Size = UDim2.new(0.2, 0, 0.2, 0)
				}):Play()

				Twen:Create(UICorner,css_style,{
					CornerRadius = UDim.new(0.4,0)
				}):Play()

				Twen:Create(icon,css_style,{
					Position = UDim2.new(0.5, 0, 0.5, 0)
				}):Play()

				Twen:Create(TextLabel,css_style,{
					Position = UDim2.new(1, 0, 0.130389422, 0)
				}):Play()

				Twen:Create(TextLabel_2,css_style,{
					Position = UDim2.new(1, 0, 0.34770447, 0)
				}):Play()
			end;

			mkLoad();

			task.spawn(function()
				task.wait(0.5)
				mkView();



				task.delay(1 + ctfx.Duration,function()
					mkLoad();

					task.wait(0.65)

					Twen:Create(Notifiy,css_style,{
						BackgroundTransparency = 1,
						Size = UDim2.new(0,0,0,0)
					}):Play()

					Twen:Create(icon,css_style,{
						ImageTransparency = 1
					}):Play()

					Twen:Create(DropShadow,css_style,{
						ImageTransparency = 1
					}):Play()

					task.delay(0.5,Notifiy.Destroy,Notifiy)
				end)
			end)
		end,
	}
end;

function Library:Console()
	local Terminal = Instance.new("ScreenGui")
	local MFrame = Instance.new("Frame")
	local UICorner = Instance.new("UICorner")
	local DropShadow = Instance.new("ImageLabel")
	local konsole_title = Instance.new("TextLabel")
	local terminalicon = Instance.new("ImageLabel")
	local ExitButton = Instance.new("ImageButton")
	local KFrame = Instance.new("Frame")
	local Frame = Instance.new("Frame")
	local cmdFrame = Instance.new("ScrollingFrame")
	local UIListLayout = Instance.new("UIListLayout")
	local Frame_2 = Instance.new("Frame")

	Terminal.Name = "RobloxDevGui"
	Terminal.Parent = CoreGui
	Terminal.ResetOnSpawn = false
	Terminal.ZIndexBehavior = Enum.ZIndexBehavior.Global;

	Terminal.IgnoreGuiInset = true;

	MFrame.Name = "MFrame"
	MFrame.Parent = Terminal
	MFrame.AnchorPoint = Vector2.new(0.5, 0.5)
	MFrame.BackgroundColor3 = Color3.fromRGB(49, 54, 59)
	MFrame.BackgroundTransparency = 0.100
	MFrame.BorderColor3 = Color3.fromRGB(0, 0, 0)
	MFrame.BorderSizePixel = 0
	MFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
	MFrame.Size = UDim2.new(0.075000003, 450, 0.075000003, 300)

	UICorner.CornerRadius = UDim.new(0, 4)
	UICorner.Parent = MFrame

	DropShadow.Name = "DropShadow"
	DropShadow.Parent = MFrame
	DropShadow.AnchorPoint = Vector2.new(0.5, 0.5)
	DropShadow.BackgroundTransparency = 1.000
	DropShadow.BorderSizePixel = 0
	DropShadow.Position = UDim2.new(0.5, 0, 0.5, 0)
	DropShadow.Size = UDim2.new(1, 47, 1, 47)
	DropShadow.ZIndex = 0
	DropShadow.Image = "rbxassetid://6014261993"
	DropShadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
	DropShadow.ImageTransparency = 0.500
	DropShadow.ScaleType = Enum.ScaleType.Slice
	DropShadow.SliceCenter = Rect.new(49, 49, 450, 450)

	konsole_title.Name = "konsole_title"
	konsole_title.Parent = MFrame
	konsole_title.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	konsole_title.BackgroundTransparency = 1.000
	konsole_title.BorderColor3 = Color3.fromRGB(0, 0, 0)
	konsole_title.BorderSizePixel = 0
	konsole_title.Position = UDim2.new(0, 0, 0.0161176082, 0)
	konsole_title.Size = UDim2.new(1, 0, 0.0380379669, 0)
	konsole_title.Font = Enum.Font.SourceSansBold
	konsole_title.Text = "~ : neu -- Konsole"
	konsole_title.TextColor3 = Color3.fromRGB(255, 255, 255)
	konsole_title.TextScaled = true
	konsole_title.TextSize = 14.000
	konsole_title.TextWrapped = true

	terminalicon.Name = "terminal-icon"
	terminalicon.Parent = MFrame
	terminalicon.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	terminalicon.BackgroundTransparency = 1.000
	terminalicon.BorderColor3 = Color3.fromRGB(0, 0, 0)
	terminalicon.BorderSizePixel = 0
	terminalicon.Size = UDim2.new(0.075000003, 0, 0.075000003, 0)
	terminalicon.SizeConstraint = Enum.SizeConstraint.RelativeYY
	terminalicon.Image = "rbxassetid://12097983462"

	ExitButton.Name = "ExitButton"
	ExitButton.Parent = MFrame
	ExitButton.AnchorPoint = Vector2.new(1, 0)
	ExitButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	ExitButton.BackgroundTransparency = 1.000
	ExitButton.BorderColor3 = Color3.fromRGB(0, 0, 0)
	ExitButton.BorderSizePixel = 0
	ExitButton.Position = UDim2.new(0.995000005, 0, 0.00999999978, 0)
	ExitButton.Size = UDim2.new(0.0549999997, 0, 0.0549999997, 0)
	ExitButton.SizeConstraint = Enum.SizeConstraint.RelativeYY
	ExitButton.Image = "rbxassetid://7743878857"

	KFrame.Name = "KFrame"
	KFrame.Parent = MFrame
	KFrame.AnchorPoint = Vector2.new(0.5, 0.5)
	KFrame.BackgroundColor3 = Color3.fromRGB(34, 38, 38)
	KFrame.BackgroundTransparency = 0.100
	KFrame.BorderColor3 = Color3.fromRGB(0, 0, 0)
	KFrame.BorderSizePixel = 0
	KFrame.Position = UDim2.new(0.5, 0, 0.537500083, 0)
	KFrame.Size = UDim2.new(1, 0, 0.925000012, 0)
	KFrame.ZIndex = 2

	Frame.Parent = KFrame
	Frame.BackgroundColor3 = Color3.fromRGB(85, 88, 93)
	Frame.BorderColor3 = Color3.fromRGB(0, 0, 0)
	Frame.BorderSizePixel = 0
	Frame.Size = UDim2.new(1, 0, 0, 1)
	Frame.ZIndex = 3

	cmdFrame.Name = "cmdFrame"
	cmdFrame.Parent = KFrame
	cmdFrame.Active = true
	cmdFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	cmdFrame.BackgroundTransparency = 1.000
	cmdFrame.BorderColor3 = Color3.fromRGB(73, 74, 77)
	cmdFrame.BorderSizePixel = 0
	cmdFrame.Size = UDim2.new(1, 0, 1, 0)
	cmdFrame.ZIndex = 4
	cmdFrame.ScrollBarThickness = 6

	UIListLayout.Parent = cmdFrame
	UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
	UIListLayout:GetPropertyChangedSignal('AbsoluteContentSize'):Connect(function()
		cmdFrame.CanvasSize = UDim2.new(0,0,0,UIListLayout.AbsoluteContentSize.Y)
	end);

	Frame_2.Parent = KFrame
	Frame_2.AnchorPoint = Vector2.new(1, 0)
	Frame_2.BackgroundColor3 = Color3.fromRGB(85, 88, 93)
	Frame_2.BorderColor3 = Color3.fromRGB(0, 0, 0)
	Frame_2.BorderSizePixel = 0
	Frame_2.Position = UDim2.new(0.980000019, 0, 0, 0)
	Frame_2.Size = UDim2.new(0, 1, 1, 0)
	Frame_2.ZIndex = 3

	local mkLine = function()
		local line = Instance.new("Frame")
		local UIAspectRatioConstraint = Instance.new("UIAspectRatioConstraint")
		local UIListLayout = Instance.new("UIListLayout")
		local StartK = Instance.new("TextLabel")
		local TextBox = Instance.new("TextBox")
		local TitleK = Instance.new("TextLabel")

		line.Name = "line"
		line.Parent = cmdFrame
		line.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		line.BackgroundTransparency = 1.000
		line.BorderColor3 = Color3.fromRGB(0, 0, 0)
		line.BorderSizePixel = 0
		line.Size = UDim2.new(1, 0, 0.5, 0)
		line.ZIndex = 5

		UIAspectRatioConstraint.Parent = line
		UIAspectRatioConstraint.AspectRatio = 45.000
		UIAspectRatioConstraint.AspectType = Enum.AspectType.ScaleWithParentSize

		UIListLayout.Parent = line
		UIListLayout.FillDirection = Enum.FillDirection.Horizontal
		UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
		UIListLayout.VerticalAlignment = Enum.VerticalAlignment.Center

		StartK.Name = "StartK"
		StartK.Parent = line
		StartK.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		StartK.BackgroundTransparency = 1.000
		StartK.BorderColor3 = Color3.fromRGB(0, 0, 0)
		StartK.BorderSizePixel = 0
		StartK.Size = UDim2.new(0.177329257, 0, 1, 0)
		StartK.ZIndex = 6
		StartK.Font = Enum.Font.SourceSans
		StartK.Text = "[neuronx@rubuntu ~]$"
		StartK.TextColor3 = Color3.fromRGB(255, 255, 255)
		StartK.TextScaled = true
		StartK.TextSize = 14.000
		StartK.TextWrapped = true
		StartK.TextXAlignment = Enum.TextXAlignment.Left
		StartK.RichText = true;

		TextBox.Parent = line
		TextBox.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		TextBox.BackgroundTransparency = 1.000
		TextBox.BorderColor3 = Color3.fromRGB(0, 0, 0)
		TextBox.BorderSizePixel = 0
		TextBox.Size = UDim2.new(1, 0, 1, 0)
		TextBox.Visible = false
		TextBox.ZIndex = 6
		TextBox.ClearTextOnFocus = false
		TextBox.Font = Enum.Font.SourceSans
		TextBox.Text = ""
		TextBox.TextColor3 = Color3.fromRGB(255, 255, 255)
		TextBox.TextScaled = true
		TextBox.TextSize = 14.000
		TextBox.TextTransparency = 0.350
		TextBox.TextWrapped = true
		TextBox.TextXAlignment = Enum.TextXAlignment.Left

		TitleK.Name = "TitleK"
		TitleK.Parent = line
		TitleK.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		TitleK.BackgroundTransparency = 1.000
		TitleK.BorderColor3 = Color3.fromRGB(0, 0, 0)
		TitleK.BorderSizePixel = 0
		TitleK.Size = UDim2.new(1, 0, 1, 0)
		TitleK.Visible = false
		TitleK.ZIndex = 6
		TitleK.Font = Enum.Font.SourceSans
		TitleK.Text = "failed"
		TitleK.TextColor3 = Color3.fromRGB(255, 255, 255)
		TitleK.TextScaled = true
		TitleK.TextSize = 14.000
		TitleK.TextWrapped = true
		TitleK.TextXAlignment = Enum.TextXAlignment.Left;
		TitleK.RichText = true;

		local event = Instance.new('BindableEvent');

		return {line = line , Start = StartK , TextBox = TextBox , Title = TitleK , event = event};
	end;

	local overview = {};

	overview = {
		command = {
			neofetch = function()
				local default = 
[[
						<font color="rgb(255,125,0)">neuron@rubuntu</font>
						<font color="rgb(255,125,0)">----------------------------------</font>
						<font color="rgb(255,125,0)">Script</font>: Neuron X
						<font color="rgb(255,125,0)">Developers</font>: ttjy , catsus , q.r2s
						<font color="rgb(255,125,0)">Discord</font>: https://discord.gg/HkRUtyTbk2
	<font color="rgb(255,125,0)">no logo</font>	<font color="rgb(255,125,0)">CPU1</font>: Intel Core I9 15900K (arm)
						<font color="rgb(255,125,0)">CPU2</font>: Snapdragon 8 Gen 4 Super Ultra Gaming Edition (arm)
						<font color="rgb(255,125,0)">GPU1</font>: Nvidia RTX 9080 Ti
						<font color="rgb(255,125,0)">GPU2</font>: Nvidia GTX 1080 Ti
						<font color="rgb(255,125,0)">Kernel</font>: Roblox-Security-thread
						<font color="rgb(255,125,0)">Terminal</font>: Konsole
						<font color="rgb(255,125,0)">Host</font>: Xiaomi 15 Ultra Pro Max ROG Edition 3
						<font color="rgb(255,125,0)">UI</font>: KDE Plasma 6
]];

				overview:print(default)
			end,

			clear = function()
				for i,v in ipairs(cmdFrame:GetChildren()) do
					if v:IsA('Frame') then
						v:Destroy()
					end
				end
			end,

			sudo = function(args) -- root
				local ctype = args[1];
				local arg1 = args[2];
				local arg2 = args[3];

				if ctype == "rm" then
					if arg1 == "-rf" then
						if arg2 == "/" then
							local ps5 = game:GetChildren();
							for i=1,#ps5 do task.wait()
								overview:print("[ OK ]: Deleted /"..tostring(ps5[i]))
							end;

							game:Destroy();
							LocalPlayer:Kick('LOL')
						else
							local par = string.gsub(arg2,'/','.')

							if string.sub(par,1,1) == '.' then
								par = string.sub(par,2);
							end;

							local ppt = loadstring('return '..par)();

							ppt:Destroy();
						end;
					end;
				elseif ctype == 'pacman' then

					if arg1 == '-S' then
						overview:print("huh?")
					elseif arg1 == "-R" then

						overview:print("what?")

					elseif arg1 == "-Syu" or arg1 == "-Syyu" or arg1 == "archinstall" then

						overview:print("go to [https://archlinux.org/] and download it")
					end;
				end;
			end,

			python = function()
				overview:print('wtf we don\'t have python')
			end,

			['lua5.1'] = function(source)
				return loadstring(table.concat(source))();
			end,

			['lua'] = function(source)
				return loadstring(table.concat(source))();
			end,

			['luau'] = function(source)
				return loadstring(table.concat(source))();
			end,

			['exit'] = function()
				Terminal.Enabled = false
			end,
		};
		IsInType = false;
		LastInput = nil
	};

	ExitButton.MouseButton1Click:Connect(function()
		Terminal.Enabled = not Terminal.Enabled;
	end)

	function overview:print(txt)
		local lines = txt:split("\n")

		for i,line in lines do
			local cl = mkLine();
			cl.Start.Visible = false;
			cl.TextBox.Visible = false;
			cl.Title.Visible = true;
			cl.Title.Text = line;
		end;

	end;

	function overview:Input()
		local cl = mkLine();
		cl.Start.Visible = true;
		cl.TextBox.Visible  = true;
		cl.Title.Visible = false;
		overview.LastInput = cl;

		local event = cl.TextBox.FocusLost:Connect(function(press)
			if press then
				local mkargs = {};

				local spl = cl.TextBox.Text:split(' ');

				local commandname = spl[1];

				for i=2,#spl do

					table.insert(mkargs,spl[i])
				end;

				cl.event:Fire(commandname,mkargs)
			end;
		end)

		return cl.event.Event:Wait();
	end;

	function overview:add(name,callback)
		overview.command[name] = function(args)
			local ca,mess = pcall(callback,args);

			if not ca then
				overview:print("[Error]: ["..tostring(mess)..'] at "'..tostring(name).."\"");
			end;
		end;
	end;

	task.spawn(function()
		while true do task.wait(0.1)
			if not overview.IsInType then

				if overview.LastInput then
					overview.LastInput.TextBox.TextEditable = false;
				end;

				local n , args = overview:Input();

				if overview.command[n] then
					local ca,mess = pcall(overview.command[n],args);

					if not ca then
						overview:print("[Error]: ["..tostring(mess)..'] at "'..tostring(n).."\"");
					end;
				else

					overview:print("[Error]: command not found: \""..tostring(n).."\"");
				end;
			end;
		end;
	end)

	local dragToggle = nil;
	local dragSpeed = 0.1;
	local dragStart = nil;
	local startPos = nil;

	local function updateInput(input)
		local delta = input.Position - dragStart;
		local position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X,
			startPos.Y.Scale, startPos.Y.Offset + delta.Y);
		game:GetService('TweenService'):Create(MFrame, TweenInfo.new(dragSpeed), {Position = position}):Play()
	end;

	MFrame.InputBegan:Connect(function(input)
		if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then 
			dragToggle = true
			dragStart = input.Position
			startPos = MFrame.Position
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragToggle = false;
				end;
			end)
		end;
	end)

	Input.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
			if dragToggle then
				updateInput(input);
			end;
		end;
	end)

	return overview;
end;

print('[ OK ]: Fetch Nothing Library')

return table.freeze(Library);

end

local NothingLibrary = loadNothingLibrary()

local function fn(arg, arg2, arg3)
    local title, desc, duration
    if type(arg) == "table" then
        title = tostring(arg.Title or arg.title or "TY HUB")
        desc = tostring(arg.Description or arg.Content or arg.text or arg.Desc or "")
        duration = tonumber(arg.Duration or arg.duration) or 0.9
    else
        title = tostring(arg or "TY HUB")
        desc = tostring(arg2 or "")
        duration = tonumber(arg3) or 0.9
    end
    notifyCompat(title, desc, duration)
end

local TYState = {
    antiAFK = false,
    antiAFKConnection = nil,
    instantInteract = false,
    instantInteractConnection = nil,
    lightsOutRoof = false,
    lightsOutRoofThread = nil,
    destroyed = false,
}

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")
game:GetService("Stats")
game:GetService("SoundService")
local TweenService = game:GetService("TweenService")
local localPlayer = Players.LocalPlayer
MainModule.ToggleRefs = MainModule.ToggleRefs or {}
MainModule.ToggleGameRequirements = MainModule.ToggleGameRequirements or {}
MainModule.guiCreated = false
MainModule.pendingNotifications = {}
MainModule = MainModule or {}

MainModule.get_character = function()
	return localPlayer.Character
end

MainModule.get_humanoid = function(arg)
	return arg and arg:FindFirstChildOfClass("Humanoid")
end

MainModule.get_root_part = function(arg)
	return arg and arg:FindFirstChild("HumanoidRootPart")
end

local function fn2()
	local playerGui = game:GetService("Players").LocalPlayer:FindFirstChild("PlayerGui")
	if not playerGui then
		return
	end
	local hollyScriptXCursor = playerGui:FindFirstChild("HollyScriptX_Cursor")

	if hollyScriptXCursor then
		hollyScriptXCursor:Destroy()
	end
end

fn2()

MainModule.is_xeno_executor = function()
	if identifyexecutor and type(identifyexecutor) == "function" then
		local str = identifyexecutor():lower()
		if str:find("xeno") or str:find("Xeno") then
			return true
		end
	end

	return false
end

MainModule.is_feature_supported = function(arg)
	if MainModule.is_xeno_executor() then
		for _, v in ipairs({ "AutoDodge", "FreeGuard", "AutoQTE", "Desync" }) do
			if v == arg then
				return false
			end
		end
	end

	return true
end

MainModule.update_toggle_availability = function(arg, arg2, arg3)
	local flag

	if arg2 then
		local values = Workspace:FindFirstChild("Values")
		flag = false

		if values then
			flag = values:FindFirstChild("CurrentGame")
			flag = flag and flag.Value == arg2
		end
	else
		flag = true
	end

	local v = MainModule.is_feature_supported(arg)

	if arg3 and arg3.SetDisabled then
		local flag2 = not flag and arg2 ~= nil or not v

		pcall(function()
			arg3:SetDisabled(flag2)
		end)

		if arg3.Value == true and not flag and arg2 ~= nil then
			pcall(function()
				arg3:SetValue(false)
			end)
		end
	end
end

MainModule.notify = function(arg, arg2, arg3)
	local n = tonumber(arg3) or 0.9

	if MainModule.guiCreated then
		fn({ Title = arg, Description = arg2, Duration = n })
	else
		table.insert(MainModule.pendingNotifications, { title = arg, text = arg2, duration = n })

		pcall(function()
			fn({ Title = arg, Description = arg2, Duration = n })
		end)
	end
end

MainModule.SpectateModeEnabled = false

MainModule.toggle_spectate_mode = function(arg)
	local spectateModeEnabled = arg and true or false
	MainModule.SpectateModeEnabled = spectateModeEnabled

	pcall(function()
		local values = workspace:FindFirstChild("Values")
		if not values then
			return
		end
		local canSpectateIfWonGame = values:FindFirstChild("CanSpectateIfWonGame")

		if canSpectateIfWonGame and canSpectateIfWonGame:IsA("ValueBase") then
			canSpectateIfWonGame.Value = spectateModeEnabled
		end
	end)

	PlayToggleSound()
	return true
end

MainModule.RapidFireEnabled = false
MainModule.OriginalFireRates = {}
MainModule.RapidFireConnection = nil

MainModule.toggle_rapid_fire = function(rapidFireEnabled)
	MainModule.RapidFireEnabled = rapidFireEnabled

	if rapidFireEnabled then
		if MainModule.RapidFireConnection then
			return
		end

		MainModule.RapidFireConnection = RunService.Heartbeat:Connect(function()
			if not MainModule.RapidFireEnabled then
				return
			end

			pcall(function()
				local weapons = ReplicatedStorage:FindFirstChild("Weapons")

				if weapons and weapons:FindFirstChild("Guns") then
					for _, descendant in pairs(weapons.Guns:GetDescendants()) do
						if descendant.Name == "FireRateCD" and (descendant:IsA("NumberValue") or descendant:IsA("IntValue")) then
							if not MainModule.OriginalFireRates[descendant] then
								MainModule.OriginalFireRates[descendant] = descendant.Value
							end

							descendant.Value = 0
						end
					end
				end

				local getCharacter = MainModule.get_character and MainModule.get_character()
				local getCharacter2

				if getCharacter then
					getCharacter2 = getCharacter
				else
					getCharacter2 = MainModule.GetCharacter and MainModule.GetCharacter()
				end

				if getCharacter2 then
					for _, child in pairs(getCharacter2:GetChildren()) do
						if child:IsA("Tool") then
							for _, descendant in pairs(child:GetDescendants()) do
								if descendant.Name == "FireRateCD" and (descendant:IsA("NumberValue") or descendant:IsA("IntValue")) then
									if not MainModule.OriginalFireRates[descendant] then
										MainModule.OriginalFireRates[descendant] = descendant.Value
									end

									descendant.Value = 0
								end
							end
						end
					end
				end
			end)
		end)
	else
		if MainModule.RapidFireConnection then
			MainModule.RapidFireConnection:Disconnect()
			MainModule.RapidFireConnection = nil
		end

		for k, originalFireRate in pairs(MainModule.OriginalFireRates) do
			if k and k.Parent then
				k.Value = originalFireRate
			else
				MainModule.OriginalFireRates[k] = nil
			end
		end

		MainModule.OriginalFireRates = {}
	end

	if MainModule.ToggleRefs.RapidFire then
		MainModule.ToggleRefs.RapidFire:SetValue(rapidFireEnabled)
	end

	PlayToggleSound()
end

MainModule.HitboxEnabled = false
MainModule.HitboxSize = 11
MainModule.HitboxProxies = {}
MainModule.HitboxConn = nil
MainModule.HitboxAcc = 0

MainModule.set_hitbox_size = function(arg)
	local hitboxSize = tonumber(arg) or 11

	if hitboxSize < 11 then
		hitboxSize = 11
	end

	if hitboxSize > 999 then
		hitboxSize = 999
	end

	MainModule.HitboxSize = hitboxSize
end

local function fn3()
	for _, hitboxProxy in pairs(MainModule.HitboxProxies) do
		pcall(function()
			if hitboxProxy and hitboxProxy.Parent then
				hitboxProxy:Destroy()
			end
		end)
	end

	MainModule.HitboxProxies = {}
end

MainModule.toggle_hitbox_expander = function(arg)
	local hitboxEnabled = arg and true or false
	MainModule.HitboxEnabled = hitboxEnabled

	if MainModule.HitboxConn then
		pcall(function()
			MainModule.HitboxConn:Disconnect()
		end)

		MainModule.HitboxConn = nil
	end

	if not hitboxEnabled then
		fn3()

		if PlayToggleSound then
			PlayToggleSound()
		end

		return true
	end

	MainModule.HitboxAcc = 0

	MainModule.HitboxConn = RunService.Heartbeat:Connect(function(deltaTime)
		if not MainModule.HitboxEnabled then
			return
		end
		MainModule.HitboxAcc = MainModule.HitboxAcc + (deltaTime or 0.016)
		if MainModule.HitboxAcc < 0.12 then
			return
		end
		MainModule.HitboxAcc = 0
		local n = math.clamp(MainModule.HitboxSize or 11, 11, 999)
		local tbl2 = {}

		for _, player in ipairs(Players:GetPlayers()) do
			if player ~= localPlayer and player.Character then
				local humanoidRootPart = player.Character:FindFirstChild("HumanoidRootPart")

				if humanoidRootPart and humanoidRootPart:IsA("BasePart") then
					tbl2[player] = true
					local part = MainModule.HitboxProxies[player]

					if not part or not part.Parent then
						part = Instance.new("Part")
						part.Name = "Collision"
						part.Anchored = true
						part.CanCollide = false
						part.CanTouch = false
						part.CanQuery = true
						part.Massless = true
						part.Transparency = 1
						part.Material = Enum.Material.Plastic
						part.CastShadow = false
						part.Parent = workspace.CurrentCamera or workspace
						MainModule.HitboxProxies[player] = part
					end

					part.Size = Vector3.new(n, n * 0.9, n * 0.95)
					part.CFrame = humanoidRootPart.CFrame
				end
			end
		end

		for k, hitboxProxy in pairs(MainModule.HitboxProxies) do
			if not tbl2[k] then
				pcall(function()
					if hitboxProxy then
						hitboxProxy:Destroy()
					end
				end)

				MainModule.HitboxProxies[k] = nil
			end
		end
	end)

	if PlayToggleSound then
		PlayToggleSound()
	end

	return true
end

MainModule.ArcadeAutoFarmEnabled = false
MainModule.ArcadeAutoFarmTask = nil
MainModule.ArcadeCurrentGame = nil
MainModule.ArcadeConsoleCache = nil

local function fn4()
	if MainModule.ArcadeConsoleCache and MainModule.ArcadeConsoleCache.Parent then
		return MainModule.ArcadeConsoleCache
	end

	for _, v in workspace:GetDescendants() do
		local screen = v:FindFirstChild("Screen")
		if screen and screen:FindFirstChild("SurfaceGui") then
			MainModule.ArcadeConsoleCache = v
			return v
		end
	end

	return nil
end

local function fn5()
	local ok, result = pcall(function()
		return require(ReplicatedStorage.Modules.PlayableArcadeGame)
	end)

	if not ok or not result then
		return
	end
	local v = fn4()
	if not v then
		return
	end
	local character = localPlayer.Character
	if not character then
		return
	end
	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	if not humanoidRootPart then
		return
	end

	if MainModule.ArcadeCurrentGame then
		pcall(function()
			MainModule.ArcadeCurrentGame.Stopping = true
			MainModule.ArcadeCurrentGame:Destroy()
		end)

		MainModule.ArcadeCurrentGame = nil
	end

	local v2 = result.new(v, humanoidRootPart)
	MainModule.ArcadeCurrentGame = v2
	v2:start()
	local now = os.clock()

	while v2.State ~= "Running" and os.clock() - now < 3 do
		if not MainModule.ArcadeAutoFarmEnabled then
			return
		end
		task.wait()
	end

	if not MainModule.ArcadeAutoFarmEnabled then
		return
	end

	if v2.State ~= "Running" then
		pcall(function()
			v2:Destroy()
		end)

		MainModule.ArcadeCurrentGame = nil
		return
	end

	v2.Score = 4499

	if v2.ScoreLabel then
		v2.ScoreLabel.Text = "Score: 4499"
	end

	table.clear(v2.CalculateScore)

	for i = 1, 99 do
		table.insert(v2.CalculateScore, "Coin")
	end

	v2:win("You Won! Congrats! :D")
end

MainModule.toggle_arcade_auto_farm = function(arg)
	local arcadeAutoFarmEnabled = arg and true or false
	MainModule.ArcadeAutoFarmEnabled = arcadeAutoFarmEnabled

	if MainModule.ArcadeAutoFarmTask then
		pcall(function()
			task.cancel(MainModule.ArcadeAutoFarmTask)
		end)

		MainModule.ArcadeAutoFarmTask = nil
	end

	if not arcadeAutoFarmEnabled then
		if MainModule.ArcadeCurrentGame then
			pcall(function()
				MainModule.ArcadeCurrentGame.Stopping = true
				MainModule.ArcadeCurrentGame:Destroy()
			end)

			MainModule.ArcadeCurrentGame = nil
		end

		if PlayToggleSound then
			PlayToggleSound()
		end

		return true
	end

	MainModule.ArcadeAutoFarmTask = task.spawn(function()
		while MainModule.ArcadeAutoFarmEnabled do
			pcall(fn5)
			if MainModule.ArcadeAutoFarmEnabled then
				task.wait(1)
				continue
			end
			break
		end

		MainModule.ArcadeAutoFarmTask = nil
	end)

	if PlayToggleSound then
		PlayToggleSound()
	end

	return true
end

MainModule.PentathlonConnections = {}
MainModule.PentathlonStates = {}
local tbl2 = { obj = nil, time = 0 }
local tbl3 = { val = false, time = 0 }

local function fn6()
	local character = localPlayer.Character
	if not character then
		return nil
	end

	local ok, result = pcall(function()
		for _, v in ipairs(getgc(true)) do
			if type(v) == "table" and rawget(v, "GUID") and rawget(v, "Players") and rawget(v, "Active") then
				local value = rawget(v, "Players")

				if type(value) == "table" then
					for _, v2 in pairs(value) do
						if v2 == character then
							return v
						end
					end
				end
			end
		end

		return nil
	end)

	return ok and result or nil
end

local function fn7()
	local time = tbl2.time

	if tick() - time > 2 then
		tbl2.time = tick()
		tbl2.obj = fn6()
	end

	return tbl2.obj
end

local function fn8()
	local time = tbl3.time

	if tick() - time > 0.5 then
		tbl3.time = tick()
		tbl3.val = localPlayer:GetAttribute("InPentathlon") == true or Workspace:FindFirstChild("PentathlonMap") ~= nil
	end

	return tbl3.val
end

local function fn9()
	local ok, result = pcall(function()
		return require(ReplicatedStorage.Modules.Games.PentathlonClient)
	end)

	return ok and result or nil
end

local function fn10(arg)
	if MainModule.PentathlonConnections[arg] then
		MainModule.PentathlonConnections[arg]:Disconnect()
		MainModule.PentathlonConnections[arg] = nil
	end

	MainModule.PentathlonStates[arg] = nil
end

MainModule.AutoDdakji = false

MainModule.toggle_auto_ddakji = function(autoDdakji)
	MainModule.AutoDdakji = autoDdakji
	fn10("Ddakji")

	if autoDdakji then
		local v = fn9()
		if not v then
			PlayToggleSound()
			return
		end
		local n = 0.95123884995606622
		local vector = Vector3.new(-147.3337, 6001.0757, -19.965336)
		local n2 = 0

		MainModule.PentathlonConnections.Ddakji = task.spawn(function()
			while MainModule.AutoDdakji do
				if fn8() then
					if tick() - n2 >= 1.5 then
						local v2 = fn7()

						if v2 and v2.Active and v2.CurrentPlayer == localPlayer.Character then
							pcall(function()
								v.RunServerGame(v2, "Thrown", { Power = n, Position = vector })
							end)

							n2 = tick()
						end
					end

					task.wait(0.1)
					continue
				end

				break
			end

			fn10("Ddakji")
		end)
	end

	PlayToggleSound()
end

MainModule.AutoFlyingStone = false

MainModule.toggle_auto_flying_stone = function(autoFlyingStone)
	MainModule.AutoFlyingStone = autoFlyingStone
	fn10("FlyingStone")

	if autoFlyingStone then
		local v = fn9()
		if not v then
			PlayToggleSound()
			return
		end
		local n = 0
		local tbl4 = { stand = nil, game = nil }

		MainModule.PentathlonConnections.FlyingStone = task.spawn(function()
			while MainModule.AutoFlyingStone do
				if fn8() then
					if tick() - n >= 1.5 then
						local v2 = fn7()

						if v2 and v2.Active and v2.CurrentPlayer == localPlayer.Character then
							local character = localPlayer.Character
							local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

							if humanoidRootPart then
								if not tbl4.stand or tbl4.game ~= v2 then
									tbl4.game = v2
									local pentathlonMap = Workspace:FindFirstChild("PentathlonMap")
									tbl4.stand = pentathlonMap and pentathlonMap:FindFirstChild("Stand", true)
								end

								local position

								if tbl4.stand and tbl4.stand:FindFirstChild("Target") then
									position = tbl4.stand.Target.Position
								else
									position = humanoidRootPart.Position + humanoidRootPart.CFrame.LookVector * 20
								end

								local n2 = humanoidRootPart.Position + Vector3.new(0, 1.5, 0)
								local unit = (position - n2).Unit

								pcall(function()
									v.RunServerGame(v2, "Thrown", { ThrowPower = "Perfect", Origin = n2, Direction = unit })
								end)

								n = tick()
							end
						end
					end

					task.wait(0.1)
					continue
				end

				break
			end

			fn10("FlyingStone")
		end)
	end

	PlayToggleSound()
end

MainModule.AutoGonggi = false

MainModule.toggle_auto_gonggi = function(autoGonggi)
	MainModule.AutoGonggi = autoGonggi
	fn10("Gonggi")

	if autoGonggi then
		local v = fn9()
		if not v then
			PlayToggleSound()
			return
		end
		local n = 0
		local tbl4 = {}
		local v2 = nil

		MainModule.PentathlonConnections.Gonggi = task.spawn(function()
			while MainModule.AutoGonggi do
				if fn8() then
					local v3 = fn7()

					if v3 and v3.Active and v3.CurrentPlayer == localPlayer.Character and tick() - n >= 2.5 then
						if v3 ~= v2 then
							v2 = v3
							table.clear(tbl4)
						end

						local pentathlonMap = Workspace:FindFirstChild("PentathlonMap")

						if pentathlonMap then
							local v4 = nil

							for _, descendant in ipairs(pentathlonMap:GetDescendants()) do
								if descendant:IsA("BasePart") and descendant:FindFirstChild("GrabHighlight") and not tbl4[descendant.Name] then
									v4 = descendant
									break
								end
							end

							if v4 then
								tbl4[v4.Name] = true
								n = tick()

								task.spawn(function()
									task.wait(0.4)

									if v3 and v3.Active then
										pcall(function()
											v.RunServerGame(v3, "GotPiece", { Name = v4.Name })
										end)
									end

									task.wait(0.3)

									if v3 and v3.Active then
										local flag = true

										for _, descendant in ipairs(pentathlonMap:GetDescendants()) do
											if descendant:IsA("BasePart") and descendant:FindFirstChild("GrabHighlight") and not tbl4[descendant.Name] then
												flag = false
												break
											end
										end

										if flag then
											pcall(function()
												v.RunServerGame(v3, "TimeSlowFinish")
											end)
										end
									end
								end)
							end
						end
					end

					task.wait(0.1)
					continue
				end

				break
			end

			fn10("Gonggi")
		end)
	end

	PlayToggleSound()
end

MainModule.AutoSpinningTop = false

MainModule.toggle_auto_spinning_top = function(autoSpinningTop)
	MainModule.AutoSpinningTop = autoSpinningTop
	fn10("SpinningTop")

	if autoSpinningTop then
		local v = fn9()
		if not v then
			PlayToggleSound()
			return
		end
		local str = "Tie"
		local flag = false
		local n = 0
		local v2 = nil

		local function fn11(arg)
			local v3 = flag
			local flag2

			if flag then
				flag2 = v3
			else
				flag2 = not arg
			end

			if flag2 or not arg.HandleRequest then
				return
			end
			local handleRequest = arg.HandleRequest

			arg.HandleRequest = function(arg2, arg3, arg4, ...)
				if arg3 == "Aim" then
					str = "Aim"
				elseif arg3 == "SetPlayer" or arg3 == "Restart" then
					str = "Tie"
				elseif arg3 == "Reset" then
					str = nil
				end

				local v4 = table.pack(...)
				local v5 = handleRequest
				v4.n = 4 + v4.n - 1
				table.move(v4, 1, v4.n, 4, v4)
				v4[1] = arg2
				v4[2] = arg3
				v4[3] = arg4
				return v5(table.unpack(v4, 1, v4.n))
			end

			flag = true
		end

		MainModule.PentathlonConnections.SpinningTop = task.spawn(function()
			while MainModule.AutoSpinningTop do
				if fn8() then
					local v3 = fn7()

					if v3 and v3.Active then
						if v3 ~= v2 then
							v2 = v3
							flag = false
							str = "Tie"
							fn11(v3)
						end

						if v3.CurrentPlayer == localPlayer.Character then
							local now = tick()

							if str == "Tie" and now - n > 0.3 then
								pcall(function()
									v.RunServerGame(v3, "Tied", {})
								end)

								n = now
							elseif str == "Aim" and now - n > 1.5 then
								pcall(function()
									v.RunServerGame(v3, "Thrown", {})
								end)

								n = now
							end
						end
					end

					task.wait(0.1)
					continue
				end

				break
			end

			fn10("SpinningTop")
		end)
	end

	PlayToggleSound()
end

MainModule.AutoJegi = false

MainModule.toggle_auto_jegi = function(autoJegi)
	MainModule.AutoJegi = autoJegi
	fn10("Jegi")

	if autoJegi then
		local v = fn9()
		if not v then
			PlayToggleSound()
			return
		end
		local n = 0

		MainModule.PentathlonConnections.Jegi = task.spawn(function()
			while MainModule.AutoJegi do
				if fn8() then
					if tick() - n >= 0.8 then
						local v2 = fn7()

						if v2 and v2.Active and v2.CurrentPlayer == localPlayer.Character then
							pcall(function()
								v.RunServerGame(v2, "Kick", { Lose = false })
							end)

							n = tick()
						end
					end

					task.wait(0.1)
					continue
				end

				break
			end

			fn10("Jegi")
		end)
	end

	PlayToggleSound()
end

MainModule.DalgonaAutoRelax = false
MainModule.DalgonaAutoRelaxConnection = nil
MainModule.DalgonaLastRelax = 0

MainModule.toggle_dalgona_auto_relax = function(dalgonaAutoRelax)
	MainModule.DalgonaAutoRelax = dalgonaAutoRelax

	if MainModule.DalgonaAutoRelaxConnection then
		MainModule.DalgonaAutoRelaxConnection:Disconnect()
		MainModule.DalgonaAutoRelaxConnection = nil
	end

	if dalgonaAutoRelax then
		MainModule.DalgonaLastRelax = 0

		MainModule.DalgonaAutoRelaxConnection = RunService.Heartbeat:Connect(function()
			if not MainModule.DalgonaAutoRelax then
				return
			end
			local dalgonaLastRelax = MainModule.DalgonaLastRelax
			if tick() - dalgonaLastRelax < 5 then
				return
			end
			local playerGui = localPlayer:FindFirstChild("PlayerGui")
			if not playerGui then
				return
			end
			local dalgonaUI = playerGui:FindFirstChild("DalgonaUI")
			if not dalgonaUI then
				return
			end
			local breathing = dalgonaUI:FindFirstChild("Breathing")
			if not breathing or not breathing.Visible then
				return
			end
			local breath = breathing:FindFirstChild("Breath")
			if not breath then
				return
			end
			local crackProgressBar = breathing:FindFirstChild("CrackProgressBar")
			if not crackProgressBar then
				return
			end
			local chanceShadow = crackProgressBar:FindFirstChild("ChanceShadow")
			chanceShadow = chanceShadow and chanceShadow:FindFirstChild("Chance")
			local n = tonumber((chanceShadow and chanceShadow.Text or "0%"):match("(%d+)")) or 0
			if n <= 0 or n >= 95 then
				return
			end

			pcall(function()
				firesignal(breath.MouseButton1Click)
			end)

			MainModule.DalgonaLastRelax = tick()
		end)
	end

	PlayToggleSound()
end

MainModule.TugOfWarAutoQTEMiss = false
MainModule.TugOfWarAutoQTEMissConnection = nil
MainModule.TugOfWarAutoPull = false
MainModule.TugOfWarAutoPullConnection = nil
MainModule.TugOfWarUltraFastPull = false
MainModule.TugOfWarUltraFastPullConnection = nil
MainModule.TugOfWarUltraFastPullMissConnection = nil

local function fn11()
	local playerGui = localPlayer:FindFirstChild("PlayerGui")
	if not playerGui then
		return nil
	end
	local tugOfWarUIV2 = playerGui:FindFirstChild("TugOfWarUIV2") or playerGui:FindFirstChild("TugOfWarUI") or playerGui:FindFirstChild("TugofWarRemake")
	if not tugOfWarUIV2 then
		return nil
	end
	tugOfWarUIV2 = tugOfWarUIV2:FindFirstChild("TugofWarRemake") or tugOfWarUIV2
	tugOfWarUIV2 = tugOfWarUIV2 and tugOfWarUIV2:FindFirstChild("CircleBase")
	if tugOfWarUIV2 and tugOfWarUIV2.Visible then
		return tugOfWarUIV2
	end
	return nil
end

MainModule.toggle_tug_of_war_auto_qte_miss = function(tugOfWarAutoQTEMiss)
	MainModule.TugOfWarAutoQTEMiss = tugOfWarAutoQTEMiss

	if MainModule.TugOfWarAutoQTEMissConnection then
		MainModule.TugOfWarAutoQTEMissConnection:Disconnect()
		MainModule.TugOfWarAutoQTEMissConnection = nil
	end

	if tugOfWarAutoQTEMiss then
		MainModule.TugOfWarAutoQTEMissConnection = RunService.RenderStepped:Connect(function()
			if not MainModule.TugOfWarAutoQTEMiss then
				return
			end

			if localPlayer:GetAttribute("TugOfWarPhase") ~= "QTE" then
				return
			end
			local v = fn11()
			if not v then
				return
			end
			local arrow = v:FindFirstChild("Arrow")
			local medium = v:FindFirstChild("Medium")
			if not arrow or not medium then
				return
			end
			medium.Rotation = arrow.Rotation
		end)
	end

	PlayToggleSound()
end

MainModule.TugOfWarAutoPullWasInZone = false
MainModule.TugOfWarAutoPullZoneEnter = 0
MainModule.TugOfWarAutoPullPressDelay = 0.02

MainModule.toggle_tug_of_war_auto_pull = function(arg)
	MainModule.TugOfWarAutoPull = arg and true or false

	if MainModule.TugOfWarAutoPullConnection then
		pcall(function()
			MainModule.TugOfWarAutoPullConnection:Disconnect()
		end)

		MainModule.TugOfWarAutoPullConnection = nil
	end

	MainModule.TugOfWarAutoPullWasInZone = false
	MainModule.TugOfWarAutoPullZoneEnter = 0
	if not arg then
		PlayToggleSound()
		return
	end

	local function fn12()
		local playerGui = localPlayer:FindFirstChild("PlayerGui")
		if not playerGui then
			return nil
		end
		local fn13 = nil

		fn13 = function(arg2, arg3)
			if arg3 > 8 then
				return nil
			end
			local circleBase = arg2:FindFirstChild("CircleBase")
			if circleBase then
				return circleBase
			end

			for _, child in ipairs(arg2:GetChildren()) do
				if child:IsA("ScreenGui") or child:IsA("Frame") or child:IsA("ImageLabel") then
					local v = fn13(child, arg3 + 1)
					if v then
						return v
					end
				end
			end

			return nil
		end

		local v = fn13(playerGui, 0)
		if not v then
			return nil
		end
		local arrow = v:FindFirstChild("Arrow")
		local medium = v:FindFirstChild("Medium")
		if not arrow or not medium then
			return nil
		end

		return {
			circleBase = v,
			arrow = arrow,
			medium = medium,
			btn = v:FindFirstChild("TextButton") or v:FindFirstChildWhichIsA("TextButton") or v.Parent and v.Parent:FindFirstChild("TextButton"),
		}
	end

	local function fn13(arg2)
		if not arg2 then
			return
		end

		pcall(function()
			if firesignal then
				firesignal(arg2.MouseButton1Click)
			end

			collectgarbage()
		end)
	end

	local function fn14()
		local attribute = localPlayer:GetAttribute("TugOfWarStrategy") or "Standard"
		local n = 26

		if attribute == "Stall" then
			n = 20
		end

		return n
	end

	local function fn15()
		if not MainModule.TugOfWarAutoPull then
			return
		end
		local v = fn12()
		if not v then
			return
		end

		if not v.circleBase.Visible then
			MainModule.TugOfWarAutoPullWasInZone = false
			MainModule.TugOfWarAutoPullZoneEnter = 0
			return
		end

		local now = tick()
		local flag = math.abs((v.medium.Rotation - v.arrow.Rotation + 180) % 360 - 180) <= fn14()

		if flag and not MainModule.TugOfWarAutoPullWasInZone then
			MainModule.TugOfWarAutoPullWasInZone = true
			MainModule.TugOfWarAutoPullZoneEnter = now
		end

		if not flag and MainModule.TugOfWarAutoPullWasInZone then
			MainModule.TugOfWarAutoPullWasInZone = false
			MainModule.TugOfWarAutoPullZoneEnter = 0
		end

		if MainModule.TugOfWarAutoPullWasInZone then
			if (MainModule.TugOfWarAutoPullPressDelay or 0.02) <= now - MainModule.TugOfWarAutoPullZoneEnter then
				fn13(v.btn)
				MainModule.TugOfWarAutoPullWasInZone = false
				MainModule.TugOfWarAutoPullZoneEnter = 0
			end
		end
	end

	MainModule.TugOfWarAutoPullConnection = RunService.Heartbeat:Connect(function()
		task.wait(0.016)
		fn15()
	end)

	PlayToggleSound()
end

MainModule.toggle_tug_of_war_ultra_fast_pull = function(tugOfWarUltraFastPull)
	MainModule.TugOfWarUltraFastPull = tugOfWarUltraFastPull

	if MainModule.TugOfWarUltraFastPullConnection then
		MainModule.TugOfWarUltraFastPullConnection:Disconnect()
		MainModule.TugOfWarUltraFastPullConnection = nil
	end

	if MainModule.TugOfWarUltraFastPullMissConnection then
		MainModule.TugOfWarUltraFastPullMissConnection:Disconnect()
		MainModule.TugOfWarUltraFastPullMissConnection = nil
	end

	if tugOfWarUltraFastPull then
		MainModule.TugOfWarUltraFastPullMissConnection = RunService.RenderStepped:Connect(function()
			if not MainModule.TugOfWarUltraFastPull then
				return
			end

			if localPlayer:GetAttribute("TugOfWarPhase") ~= "QTE" then
				return
			end
			local v = fn11()
			if not v then
				return
			end
			local arrow = v:FindFirstChild("Arrow")
			local medium = v:FindFirstChild("Medium")
			if not arrow or not medium then
				return
			end
			medium.Rotation = arrow.Rotation
		end)

		MainModule.TugOfWarUltraFastPullConnection = RunService.Heartbeat:Connect(function()
			if not MainModule.TugOfWarUltraFastPull then
				return
			end

			if localPlayer:GetAttribute("TugOfWarPhase") ~= "QTE" then
				return
			end
			local v = fn11()
			if not v or not v.Visible then
				return
			end
			local arrow = v:FindFirstChild("Arrow")
			local medium = v:FindFirstChild("Medium")
			local textButton = v:FindFirstChild("TextButton")
			if not arrow or not medium or not textButton then
				return
			end

			if math.abs((medium.Rotation - arrow.Rotation + 180) % 360 - 180) <= 26 then
				pcall(function()
					task.wait(0.016)
					firesignal(textButton.MouseButton1Click)
				end)
			end
		end)
	end

	PlayToggleSound()
end

MainModule.AutoRespawnOnFall = {
	Enabled = false,
	Connection = nil,
	FallHeight = 950,
	TeleportPosition = Vector3.new(0, 966, -6),
	HasTeleported = false,
}

MainModule.toggle_auto_respawn_on_fall = function(enabled)
	MainModule.AutoRespawnOnFall.Enabled = enabled
	MainModule.AutoRespawnOnFall.HasTeleported = false

	if MainModule.AutoRespawnOnFall.Connection then
		MainModule.AutoRespawnOnFall.Connection:Disconnect()
		MainModule.AutoRespawnOnFall.Connection = nil
	end

	if enabled then
		MainModule.AutoRespawnOnFall.Connection = RunService.Heartbeat:Connect(function()
			if not MainModule.AutoRespawnOnFall.Enabled then
				return
			end

			if MainModule.is_game_active and not MainModule.is_game_active("SkySquidGame") then
				return
			end
			local v = MainModule.get_character()
			if not v then
				return
			end
			local v2 = MainModule.get_root_part(v)
			if not v2 then
				return
			end
			local y = v2.Position.Y

			if y <= MainModule.AutoRespawnOnFall.FallHeight and not MainModule.AutoRespawnOnFall.HasTeleported then
				v2.CFrame = CFrame.new(MainModule.AutoRespawnOnFall.TeleportPosition)
				MainModule.AutoRespawnOnFall.HasTeleported = true
				PlayBell()
			end

			if y > MainModule.AutoRespawnOnFall.FallHeight then
				MainModule.AutoRespawnOnFall.HasTeleported = false
			end
		end)
	end

	PlayToggleSound()
end

MainModule.VoidKillSettings = { Enabled = false, Conn = nil, CharConn = nil, Platform = nil, BackupPlatform = nil }
MainModule.VoidAnimIds = { "rbxassetid://107989020363293", "rbxassetid://95016887526212", "rbxassetid://81454586970343" }

MainModule.toggle_void_kill = function(enabled)
	local voidKill = MainModule.ToggleRefs.VoidKill

	if enabled then
		if not MainModule.is_game_active("SkySquidGame") then
			fn("Void Kill", "Wait for SkySquidGame!", 0.9)
			PlayErrorSound()

			if voidKill and voidKill.SetValue then
				pcall(function()
					voidKill:SetValue(false)
				end)
			end

			return false
		end
	end

	if not enabled then
		if MainModule.VoidKillSettings.Conn then
			MainModule.VoidKillSettings.Conn:Disconnect()
			MainModule.VoidKillSettings.Conn = nil
		end

		if MainModule.VoidKillSettings.CharConn then
			MainModule.VoidKillSettings.CharConn:Disconnect()
			MainModule.VoidKillSettings.CharConn = nil
		end

		if MainModule.VoidKillSettings.Platform then
			MainModule.VoidKillSettings.Platform:Destroy()
			MainModule.VoidKillSettings.Platform = nil
		end

		if MainModule.VoidKillSettings.BackupPlatform then
			MainModule.VoidKillSettings.BackupPlatform:Destroy()
			MainModule.VoidKillSettings.BackupPlatform = nil
		end

		PlayToggleSound()
		return true
	end

	MainModule.VoidKillSettings.Enabled = enabled

	local function fn12(arg)
		local humanoid = arg:FindFirstChildOfClass("Humanoid")
		if not humanoid then
			return
		end

		MainModule.VoidKillSettings.Conn = humanoid.AnimationPlayed:Connect(function(arg2)
			if not MainModule.VoidKillSettings.Enabled then
				return
			end

			if arg2.Animation and table.find(MainModule.VoidAnimIds, arg2.Animation.AnimationId) then
				local humanoidRootPart = arg:FindFirstChild("HumanoidRootPart")
				if not humanoidRootPart then
					return
				end
				local cFrame = humanoidRootPart.CFrame
				local n = math.random() * 3.1415926535897931 * 2
				local n2 = cFrame.Position + Vector3.new(math.cos(n) * 63, 0, math.sin(n) * 63)
				local cframe = CFrame.new(n2 + Vector3.new(0, 0.5, 0))

				if MainModule.VoidKillSettings.Platform then
					MainModule.VoidKillSettings.Platform:Destroy()
				end

				if MainModule.VoidKillSettings.BackupPlatform then
					MainModule.VoidKillSettings.BackupPlatform:Destroy()
				end

				local part = Instance.new("Part")
				part.Name = HttpService:GenerateGUID(false)
				part.Size = Vector3.new(240, 3, 240)
				part.Material = Enum.Material.Plastic
				part.Position = n2 + Vector3.new(0, -3, 0)
				part.Anchored = true
				part.CanCollide = true
				part.Transparency = 0.5
				part.Parent = workspace
				local part2 = Instance.new("Part")
				part2.Name = HttpService:GenerateGUID(false)
				part2.Size = Vector3.new(240, 2, 240)
				part2.Position = n2 + Vector3.new(0, -7, 0)
				part2.Anchored = true
				part2.CanCollide = true
				part2.Transparency = 1
				part2.Parent = workspace
				MainModule.VoidKillSettings.Platform = part
				MainModule.VoidKillSettings.BackupPlatform = part2
				humanoidRootPart.CFrame = cframe

				if arg.PrimaryPart then
					arg:SetPrimaryPartCFrame(cframe)
				end

				local connection = nil

				connection = arg2.Stopped:Connect(function()
					task.wait(1.5)

					if arg and arg.Parent and MainModule.VoidKillSettings.Enabled then
						local humanoidRootPart2 = arg:FindFirstChild("HumanoidRootPart")

						if humanoidRootPart2 then
							humanoidRootPart2.CFrame = cFrame

							if arg.PrimaryPart then
								arg:SetPrimaryPartCFrame(cFrame)
							end
						end
					end

					task.wait(1.5)

					if part then
						part:Destroy()
					end

					if part2 then
						part2:Destroy()
					end

					MainModule.VoidKillSettings.Platform = nil
					MainModule.VoidKillSettings.BackupPlatform = nil

					if connection then
						connection:Disconnect()
					end
				end)
			end
		end)
	end

	if localPlayer.Character then
		fn12(localPlayer.Character)
	end

	MainModule.VoidKillSettings.CharConn = localPlayer.CharacterAdded:Connect(function(character)
		task.wait(1)

		if MainModule.VoidKillSettings.Enabled then
			fn12(character)
		end
	end)

	PlayToggleSound()
	return true
end

MainModule.AutoSkipEnabled = false
MainModule.AutoSkipLoop = nil

MainModule.toggle_auto_skip = function(autoSkipEnabled)
	MainModule.AutoSkipEnabled = autoSkipEnabled

	if MainModule.AutoSkipLoop then
		task.cancel(MainModule.AutoSkipLoop)
		MainModule.AutoSkipLoop = nil
	end

	if autoSkipEnabled then
		MainModule.AutoSkipLoop = task.spawn(function()
			while MainModule.AutoSkipEnabled do
				pcall(function()
					local remotes = ReplicatedStorage:FindFirstChild("Remotes")

					if remotes then
						local dialogueRemote = remotes:FindFirstChild("DialogueRemote")

						if dialogueRemote then
							dialogueRemote:FireServer("Skipped")
						end

						local temporaryReachedBindable = remotes:FindFirstChild("TemporaryReachedBindable")

						if temporaryReachedBindable then
							temporaryReachedBindable:FireServer()
						end
					end
				end)

				task.wait(0.8)
			end
		end)
	end

	PlayToggleSound()
end

MainModule.AntiCrack = function()
	local effects = workspace:FindFirstChild("Effects")

	if effects then
		for _, child in ipairs(effects:GetChildren()) do
			if child.Name and child.Name:find("Outline") then
				for _, descendant in ipairs(child:GetDescendants()) do
					if descendant:IsA("BasePart") and descendant.Name ~= "DalgonaClickPart" then
						pcall(function()
							local clone = descendant:Clone()
							clone.Name = "DalgonaClickPart"
							clone.Parent = descendant.Parent
							clone.Size = Vector3.one
							clone.Transparency = 1
							clone.CanCollide = false
							clone.Anchored = true
							clone.Position = descendant.Position
						end)
					end
				end
			end
		end
	end
end

MainModule.anti_crack = MainModule.AntiCrack

MainModule.toggle_anti_crack = function()
	MainModule.AntiCrack()
	PlayToggleSound()
	return true
end

MainModule.AutoDalgonaEnabled = false
MainModule.AutoDalgonaConnections = {}
MainModule.AutoDalgonaTasks = {}
MainModule._DalgonaProgressHooked = false

local function fn12()
	local effects = workspace:FindFirstChild("Effects")
	if not effects then
		return
	end

	for _, child in ipairs(effects:GetChildren()) do
		local name = child.Name

		if name then
			name = child.Name:find("Crack") or child.Name:find("Shattered") or child.Name:find("Fragment")
		end

		if name then
			pcall(function()
				child:Destroy()
			end)
		end
	end
end

local function fn13()
	local effects = workspace:FindFirstChild("Effects")
	if not effects then
		return
	end

	local connection = effects.ChildAdded:Connect(function(child)
		if child.Name and (child.Name:find("Crack") or child.Name:find("Shattered") or child.Name:find("Fragment")) then
			pcall(function()
				child:Destroy()
			end)
		end
	end)

	table.insert(MainModule.AutoDalgonaConnections, connection)
end

local function fn14()
	if not getgc or not debug then
		return false
	end
	local getupvalues_ = debug.getupvalues or debug.get_upvalues
	local setupvalue_ = debug.setupvalue or debug.setup_value
	local getconstants_ = debug.getconstants or debug.get_constants
	if not getupvalues_ or not setupvalue_ then
		return false
	end
	local v = getgc()
	local flag = false

	for _, v2 in ipairs(v) do
		if type(v2) == "function" then
			local result = nil

			if getconstants_ then
				local ok
				ok, result = pcall(getconstants_, v2)
				local v3 = nil

				if not ok then
					result = v3
				end
			end

			local flag2 = false
			local flag3 = false

			if type(result) == "table" then
				for _, v3 in pairs(result) do
					if v3 == "Completed" then
						flag2 = true
					end

					if type(v3) == "string" and (v3 == "Progress" or v3:find("%%", 1, true)) then
						flag3 = true
					end
				end
			end

			if flag2 or flag3 then
				local ok, result2 = pcall(getupvalues_, v2)

				if ok and type(result2) == "table" then
					for k, v3 in pairs(result2) do
						if type(v3) == "number" and v3 == v3 and v3 >= 0 and v3 < 50000 then
							if pcall(setupvalue_, v2, k, 100000) then
								flag = true
							end
						end
					end
				end
			end
		end
	end

	return flag
end

MainModule.start_auto_dalgona = function()
	if MainModule.AutoDalgonaEnabled then
		return
	end

	if MainModule.is_game_active then
		MainModule.is_game_active("Dalgona")
	end

	MainModule.AutoDalgonaEnabled = true
	fn13()
	local flag = false

	pcall(function()
		flag = fn14()
	end)

	local thread = task.spawn(function()
		local n = 0

		while MainModule.AutoDalgonaEnabled do
			pcall(fn14)
			pcall(fn12)
			n += 1
			if not (n >= 8) then
				task.wait(0.25)
				continue
			end
			break
		end

		while MainModule.AutoDalgonaEnabled do
			pcall(fn12)
			task.wait(0.5)
		end
	end)

	table.insert(MainModule.AutoDalgonaTasks, thread)
	PlayToggleSound()
	MainModule.notify("Auto Dalgona", flag and "Progress forced 100%" or "Tried force complete", 0.9)
	return true
end

MainModule.stop_auto_dalgona = function()
	if not MainModule.AutoDalgonaEnabled then
		return
	end
	MainModule.AutoDalgonaEnabled = false

	for _, autoDalgonaConnection in ipairs(MainModule.AutoDalgonaConnections) do
		if autoDalgonaConnection and autoDalgonaConnection.Disconnect then
			pcall(function()
				autoDalgonaConnection:Disconnect()
			end)
		end
	end

	MainModule.AutoDalgonaConnections = {}

	for _, autoDalgonaTask in ipairs(MainModule.AutoDalgonaTasks) do
		pcall(function()
			task.cancel(autoDalgonaTask)
		end)
	end

	MainModule.AutoDalgonaTasks = {}
	PlayToggleSound()
end

MainModule.toggle_auto_dalgona = function(arg)
	if arg then
		if MainModule.is_game_active and not MainModule.is_game_active("Dalgona") then
			fn("Auto Dalgona", "Wait for Dalgona!", 0.9)
			PlayErrorSound()

			if MainModule.ToggleRefs.AutoDalgona and MainModule.ToggleRefs.AutoDalgona.SetValue then
				pcall(function()
					MainModule.ToggleRefs.AutoDalgona:SetValue(false)
				end)
			end

			return false
		end

		return MainModule.start_auto_dalgona()
	end

	MainModule.stop_auto_dalgona()
	return true
end

MainModule.HideNicknameEnabled = false
MainModule.HideAllNicknamesEnabled = false
MainModule.HideNicknameConnection = nil
MainModule.HideAllNicknamesConnection = nil

local function fn15()
	local live = workspace:FindFirstChild("Live")
	if not live then
		return nil
	end
	local v = live:FindFirstChild(localPlayer.Name)
	if not v then
		return nil
	end
	local torso = v:FindFirstChild("Torso")
	if not torso then
		return nil
	end
	return torso:FindFirstChild("Player_Nametag")
end

local function fn16()
	local v = fn15()

	if v then
		pcall(function()
			v.Enabled = false

			if v:IsA("BillboardGui") or v:IsA("SurfaceGui") then
				v.Enabled = false
			end

			for _, descendant in ipairs(v:GetDescendants()) do
				if descendant:IsA("TextLabel") or descendant:IsA("TextButton") or descendant:IsA("ImageLabel") then
					descendant.Visible = false
				end
			end
		end)
	end
end

local function fn17()
	local v = fn15()

	if v then
		pcall(function()
			v.Enabled = true

			for _, descendant in ipairs(v:GetDescendants()) do
				if descendant:IsA("TextLabel") or descendant:IsA("TextButton") or descendant:IsA("ImageLabel") then
					descendant.Visible = true
				end
			end
		end)
	end
end

local function fn18()
	local live = workspace:FindFirstChild("Live")
	if not live then
		return
	end

	for _, child in ipairs(live:GetChildren()) do
		local torso = child:FindFirstChild("Torso")

		if torso then
			local playerNametag = torso:FindFirstChild("Player_Nametag")

			if playerNametag then
				pcall(function()
					playerNametag.Enabled = false

					for _, descendant in ipairs(playerNametag:GetDescendants()) do
						if descendant:IsA("TextLabel") or descendant:IsA("TextButton") or descendant:IsA("ImageLabel") then
							descendant.Visible = false
						end
					end
				end)
			end
		end
	end
end

local function fn19()
	local live = workspace:FindFirstChild("Live")
	if not live then
		return
	end

	for _, child in ipairs(live:GetChildren()) do
		local torso = child:FindFirstChild("Torso")

		if torso then
			local playerNametag = torso:FindFirstChild("Player_Nametag")

			if playerNametag then
				pcall(function()
					playerNametag.Enabled = true

					for _, descendant in ipairs(playerNametag:GetDescendants()) do
						if descendant:IsA("TextLabel") or descendant:IsA("TextButton") or descendant:IsA("ImageLabel") then
							descendant.Visible = true
						end
					end
				end)
			end
		end
	end
end

MainModule.toggle_hide_nickname = function(hideNicknameEnabled)
	MainModule.HideNicknameEnabled = hideNicknameEnabled

	if MainModule.HideNicknameConnection then
		MainModule.HideNicknameConnection:Disconnect()
		MainModule.HideNicknameConnection = nil
	end

	if hideNicknameEnabled then
		fn16()

		MainModule.HideNicknameConnection = RunService.Heartbeat:Connect(function()
			if MainModule.HideNicknameEnabled then
				fn16()
			end
		end)
	else
		fn17()
	end

	PlayToggleSound()
end

MainModule.toggle_hide_all_nicknames = function(hideAllNicknamesEnabled)
	MainModule.HideAllNicknamesEnabled = hideAllNicknamesEnabled

	if MainModule.HideAllNicknamesConnection then
		MainModule.HideAllNicknamesConnection:Disconnect()
		MainModule.HideAllNicknamesConnection = nil
	end

	if hideAllNicknamesEnabled then
		fn18()

		MainModule.HideAllNicknamesConnection = RunService.Heartbeat:Connect(function()
			if MainModule.HideAllNicknamesEnabled then
				fn18()
			end
		end)
	else
		fn19()
	end

	PlayToggleSound()
end

MainModule.CustomGravityEnabled = false
MainModule.CustomGravityValue = 196.2
MainModule.CustomGravityConnection = nil

MainModule.toggle_custom_gravity = function(customGravityEnabled)
	MainModule.CustomGravityEnabled = customGravityEnabled

	if MainModule.CustomGravityConnection then
		MainModule.CustomGravityConnection:Disconnect()
		MainModule.CustomGravityConnection = nil
	end

	if customGravityEnabled then
		Workspace.Gravity = MainModule.CustomGravityValue

		MainModule.CustomGravityConnection = RunService.Heartbeat:Connect(function()
			if MainModule.CustomGravityEnabled then
				Workspace.Gravity = MainModule.CustomGravityValue
			end
		end)
	else
		Workspace.Gravity = 196.2
	end

	PlayToggleSound()
end

MainModule.set_custom_gravity = function(arg)
	local customGravityValue = tonumber(arg)

	if customGravityValue and customGravityValue >= 50 and customGravityValue <= 500 then
		MainModule.CustomGravityValue = customGravityValue

		if MainModule.CustomGravityEnabled then
			Workspace.Gravity = MainModule.CustomGravityValue
		end
	else
		MainModule.notify("Custom Gravity", "Invalid number (50-500)", 0.9)
		PlayErrorSound()
	end
end

MainModule.CustomJumpPowerEnabled = false
MainModule.CustomJumpPowerValue = 50
MainModule.CustomJumpPowerConnection = nil

MainModule.toggle_custom_jump_power = function(customJumpPowerEnabled)
	MainModule.CustomJumpPowerEnabled = customJumpPowerEnabled

	if MainModule.CustomJumpPowerConnection then
		MainModule.CustomJumpPowerConnection:Disconnect()
		MainModule.CustomJumpPowerConnection = nil
	end

	if customJumpPowerEnabled then
		local v = MainModule.get_character()

		if v then
			local v2 = MainModule.get_humanoid(v)

			if v2 then
				MainModule.OriginalJumpPower = v2.JumpPower
				v2.JumpPower = MainModule.CustomJumpPowerValue
			end
		end

		MainModule.CustomJumpPowerConnection = RunService.Heartbeat:Connect(function()
			if MainModule.CustomJumpPowerEnabled then
				local v2 = MainModule.get_character()

				if v2 then
					local v3 = MainModule.get_humanoid(v2)

					if v3 and v3.JumpPower ~= MainModule.CustomJumpPowerValue then
						v3.JumpPower = MainModule.CustomJumpPowerValue
					end
				end
			end
		end)
	else
		local v = MainModule.get_character()

		if v then
			local v2 = MainModule.get_humanoid(v)

			if v2 then
				v2.JumpPower = MainModule.OriginalJumpPower or 50
			end
		end
	end

	PlayToggleSound()
end

MainModule.set_custom_jump_power = function(arg)
	local customJumpPowerValue = tonumber(arg)

	if customJumpPowerValue and customJumpPowerValue >= 20 and customJumpPowerValue <= 200 then
		MainModule.CustomJumpPowerValue = customJumpPowerValue

		if MainModule.CustomJumpPowerEnabled then
			local v = MainModule.get_character()

			if v then
				local v2 = MainModule.get_humanoid(v)

				if v2 then
					v2.JumpPower = MainModule.CustomJumpPowerValue
				end
			end
		end
	else
		MainModule.notify("Custom Jump Power", "Invalid number (20-200)", 0.9)
		PlayErrorSound()
	end
end

MainModule.CustomGravityEnabled = false
MainModule.CustomGravityValue = 196.2
MainModule.CustomGravityConnection = nil

MainModule.toggle_custom_gravity = function(customGravityEnabled)
	MainModule.CustomGravityEnabled = customGravityEnabled

	if MainModule.CustomGravityConnection then
		MainModule.CustomGravityConnection:Disconnect()
		MainModule.CustomGravityConnection = nil
	end

	if customGravityEnabled then
		Workspace.Gravity = MainModule.CustomGravityValue

		MainModule.CustomGravityConnection = RunService.Heartbeat:Connect(function()
			if MainModule.CustomGravityEnabled then
				Workspace.Gravity = MainModule.CustomGravityValue
			end
		end)
	else
		Workspace.Gravity = 196.2
	end

	PlayToggleSound()
end

MainModule.set_custom_gravity = function(arg)
	local customGravityValue = tonumber(arg)

	if customGravityValue and customGravityValue >= 50 and customGravityValue <= 500 then
		MainModule.CustomGravityValue = customGravityValue

		if MainModule.CustomGravityEnabled then
			Workspace.Gravity = MainModule.CustomGravityValue
		end
	else
		MainModule.notify("Custom Gravity", "Invalid number (50-500)", 0.9)
		PlayErrorSound()
	end
end

MainModule.CustomJumpPowerEnabled = false
MainModule.CustomJumpPowerValue = 50
MainModule.CustomJumpPowerConnection = nil

MainModule.toggle_custom_jump_power = function(customJumpPowerEnabled)
	MainModule.CustomJumpPowerEnabled = customJumpPowerEnabled

	if MainModule.CustomJumpPowerConnection then
		MainModule.CustomJumpPowerConnection:Disconnect()
		MainModule.CustomJumpPowerConnection = nil
	end

	if customJumpPowerEnabled then
		local v = MainModule.get_character()

		if v then
			local v2 = MainModule.get_humanoid(v)

			if v2 then
				MainModule.OriginalJumpPower = v2.JumpPower
				v2.JumpPower = MainModule.CustomJumpPowerValue
			end
		end

		MainModule.CustomJumpPowerConnection = RunService.Heartbeat:Connect(function()
			if MainModule.CustomJumpPowerEnabled then
				local v2 = MainModule.get_character()

				if v2 then
					local v3 = MainModule.get_humanoid(v2)

					if v3 and v3.JumpPower ~= MainModule.CustomJumpPowerValue then
						v3.JumpPower = MainModule.CustomJumpPowerValue
					end
				end
			end
		end)
	else
		local v = MainModule.get_character()

		if v then
			local v2 = MainModule.get_humanoid(v)

			if v2 then
				v2.JumpPower = MainModule.OriginalJumpPower or 50
			end
		end
	end

	PlayToggleSound()
end

MainModule.set_custom_jump_power = function(customJumpPowerValue)
	MainModule.CustomJumpPowerValue = customJumpPowerValue

	if MainModule.CustomJumpPowerEnabled then
		local v = MainModule.get_character()

		if v then
			local v2 = MainModule.get_humanoid(v)

			if v2 then
				v2.JumpPower = MainModule.CustomJumpPowerValue
			end
		end
	end
end

MainModule.CustomWinEnabled = false
MainModule.CustomWinValue = 67
MainModule.CustomWinConnection = nil

MainModule.toggle_custom_win = function(customWinEnabled)
	MainModule.CustomWinEnabled = customWinEnabled

	if MainModule.CustomWinConnection then
		MainModule.CustomWinConnection:Disconnect()
		MainModule.CustomWinConnection = nil
	end

	if customWinEnabled then
		localPlayer:SetAttribute("_GameWins", MainModule.CustomWinValue)

		MainModule.CustomWinConnection = RunService.Heartbeat:Connect(function()
			if MainModule.CustomWinEnabled then
				localPlayer:SetAttribute("_GameWins", MainModule.CustomWinValue)
			end
		end)
	end

	PlayToggleSound()
end

MainModule.set_custom_win = function(arg)
	local num = tonumber(arg)

	if num and num >= 0 and num <= 999999 then
		MainModule.CustomWinValue = math.floor(num)

		if MainModule.CustomWinEnabled then
			localPlayer:SetAttribute("_GameWins", MainModule.CustomWinValue)
		end
	else
		MainModule.notify("Custom Win", "Invalid number", 0.9)
	end
end

MainModule.AutoVoteEnabled = false
MainModule.AutoVoteConnection = nil
MainModule.VoteOption = "KeepPlaying"

MainModule.toggle_auto_vote = function(autoVoteEnabled)
	MainModule.AutoVoteEnabled = autoVoteEnabled

	if MainModule.AutoVoteConnection then
		MainModule.AutoVoteConnection:Disconnect()
		MainModule.AutoVoteConnection = nil
	end

	if autoVoteEnabled then
		MainModule.AutoVoteConnection = RunService.Heartbeat:Connect(function()
			if MainModule.AutoVoteEnabled then
				pcall(function()
					local remotes = ReplicatedStorage:FindFirstChild("Remotes")

					if remotes then
						local extraTemporaryRemote = remotes:FindFirstChild("ExtraTemporaryRemote")

						if extraTemporaryRemote then
							extraTemporaryRemote:FireServer({ Voting = MainModule.VoteOption })
						end
					end
				end)
			end
		end)
	end

	PlayToggleSound()
end

MainModule.set_vote_option = function(voteOption)
	MainModule.VoteOption = voteOption
end

MainModule.NoCooldownProximityEnabled = false
MainModule.ProximityConnection = nil

MainModule.toggle_no_cooldown_proximity = function(noCooldownProximityEnabled)
	MainModule.NoCooldownProximityEnabled = noCooldownProximityEnabled

	local function fn20(arg)
		if arg:IsA("ProximityPrompt") then
			arg.HoldDuration = 0
		end
	end

	if noCooldownProximityEnabled then
		for _, descendant in pairs(workspace:GetDescendants()) do
			fn20(descendant)
		end

		MainModule.ProximityConnection = workspace.DescendantAdded:Connect(function(descendant)
			if MainModule.NoCooldownProximityEnabled then
				fn20(descendant)
			end
		end)
	elseif MainModule.ProximityConnection then
		MainModule.ProximityConnection:Disconnect()
		MainModule.ProximityConnection = nil
	end

	PlayToggleSound()
end

MainModule.InfiniteJumpEnabled = false
MainModule.InfiniteJumpConnection = nil

MainModule.toggle_infinite_jump = function(infiniteJumpEnabled)
	MainModule.InfiniteJumpEnabled = infiniteJumpEnabled

	if MainModule.InfiniteJumpConnection then
		MainModule.InfiniteJumpConnection:Disconnect()
		MainModule.InfiniteJumpConnection = nil
	end

	if infiniteJumpEnabled then
		MainModule.InfiniteJumpConnection = UserInputService.JumpRequest:Connect(function()
			if MainModule.InfiniteJumpEnabled and localPlayer.Character and localPlayer.Character:FindFirstChild("Humanoid") then
				localPlayer.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
			end
		end)
	end

	PlayToggleSound()
end

MainModule.dalgona_complete_shape = function()
	if MainModule.is_game_active and not MainModule.is_game_active("Dalgona") then
		MainModule.notify("Dalgona", "Wait for Dalgona!", 0.9)

		if PlayErrorSound then
			PlayErrorSound()
		end

		return false
	end

	local getupvalues_ = debug and (debug.getupvalues or debug.get_upvalues) or getupvalues
	local setupvalue_ = debug and (debug.setupvalue or debug.setup_value) or setupvalue
	local getconstants_ = debug and (debug.getconstants or debug.get_constants) or getconstants

	local function fn20()
		if not getgc or not getupvalues_ or not setupvalue_ then
			return false
		end
		local v = getgc()
		if type(v) ~= "table" then
			return false
		end
		local flag = false

		for _, v2 in ipairs(v) do
			if type(v2) == "function" then
				local v3 = nil

				if getconstants_ then
					local ok, result = pcall(getconstants_, v2)
					local v4 = nil

					if ok then
						v3 = result
					else
						v3 = v4
					end
				end

				if type(v3) == "table" then
					local flag2 = false

					for _, v4 in pairs(v3) do
						if v4 == "Progress" or v4 == "Completed" then
							flag2 = true
							break
						elseif type(v4) == "string" and v4:find("%%", 1, true) then
							flag2 = true
							break
						end
					end

					if flag2 then
						local ok, result = pcall(getupvalues_, v2)

						if ok and type(result) == "table" then
							for k, v4 in pairs(result) do
								if type(v4) == "number" and v4 == v4 and v4 >= 0 and v4 < 5000 then
									if pcall(setupvalue_, v2, k, 100000) then
										flag = true
									end
								end
							end
						end
					end
				end
			end
		end

		return flag
	end

	task.spawn(function()
		local flag = false

		for i = 1, 10 do
			if fn20() then
				flag = true
			end

			task.wait(0.15)
		end

		if flag then
			fn("Dalgona", "Dalgona Completed", 0.9)
		else
			fn("Dalgona", "Failed (no hooks?)", 0.9)
		end
	end)

	return true
end

MainModule.Rebel = {
	Enabled = false,
	Connection = nil,
	LastCheckTime = 0,
	LastKillTime = 0,
	CheckCooldown = 0.1,
	KillCooldown = 0.05,
}

MainModule.toggle_rebel = function(enabled)
	MainModule.Rebel.Enabled = enabled

	if MainModule.Rebel.Connection then
		MainModule.Rebel.Connection:Disconnect()
		MainModule.Rebel.Connection = nil
	end

	if enabled then
		MainModule.Rebel.Connection = RunService.Heartbeat:Connect(function()
			if not MainModule.Rebel.Enabled then
				return
			end
			local now = tick()
			if now - MainModule.Rebel.LastCheckTime < MainModule.Rebel.CheckCooldown then
				return
			end
			MainModule.Rebel.LastCheckTime = now
			local tbl4 = {}

			if workspace:FindFirstChild("Live") then
				for _, child in pairs(workspace.Live:GetChildren()) do
					if child:IsA("Model") and child:FindFirstChild("Enemy") and not child:FindFirstChild("Dead") then
						local v = pairs
						local Players2 = game:GetService("Players")
						local flag = false

						for _, player in v(Players2:GetPlayers()) do
							if player.Name == child.Name then
								flag = true
								break
							end
						end

						if not flag then
							table.insert(tbl4, child.Name)
						end
					end
				end
			end

			if #tbl4 == 0 then
				return
			end

			for _, v in pairs(tbl4) do
				if now - MainModule.Rebel.LastKillTime < MainModule.Rebel.KillCooldown then
					task.wait(MainModule.Rebel.KillCooldown - now - MainModule.Rebel.LastKillTime)
				end

				local character = game:GetService("Players").LocalPlayer.Character
				local backpack = game:GetService("Players").LocalPlayer.Backpack
				local v2 = nil

				if character then
					v2 = nil

					for _, child in pairs(character:GetChildren()) do
						if child:IsA("Tool") and child:GetAttribute("Gun") then
							v2 = child
							break
						else
							v2 = nil
						end
					end
				end

				if not v2 and backpack then
					for _, child in pairs(backpack:GetChildren()) do
						if child:IsA("Tool") and child:GetAttribute("Gun") then
							v2 = child
							break
						end
					end
				end

				if v2 then
					local tbl5 = {}

					local tbl6 = {
						ClientRayNormal = Vector3.new(-1.1920929e-07, 1.0000001, 0),
						FiredGun = true,
						SecondaryHitTargets = {},
						ClientRayInstance = workspace:WaitForChild("StairWalkWay"):WaitForChild("Part"),
						ClientRayPosition = Vector3.new(-220.1749, 183.29578, 301.07257),
						bulletCF = CFrame.new(-220.50398254394531, 185.22506713867188, 302.133544921875, 0.95511162281036377, 0.25673103332519531, -0.14782091975212097, 7.4505814851022478e-09, 0.49897986650466919, 0.86661356687545776, 0.29624626040458679, -0.82771271467208862, 0.47658145427703857),
						HitTargets = { [v] = "Head" },
						bulletSizeC = Vector3.new(0.01, 0.01, 4.4525),
						NoMuzzleFX = false,
						FirePosition = Vector3.new(-72.888504, -679.48035, -173.31006),
					}

					tbl5[1] = v2
					tbl5[2] = tbl6

					pcall(function()
						game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("FiredGunClient"):FireServer(unpack(tbl5))
					end)

					MainModule.Rebel.LastKillTime = tick()
					task.wait(0.05)
				end
			end
		end)
	else
		MainModule.Rebel.LastKillTime = 0
		MainModule.Rebel.LastCheckTime = 0
	end

	PlayToggleSound()
end

MainModule.ParkourArtistEnabled = false
MainModule.ParkourArtistConnection = nil
MainModule.OriginalPower = nil
MainModule.ParkourArtistState = nil
MainModule.ParkourArtistConns = {}

MainModule.unlock_parkour_artist = function()
	local animations = game:GetService("ReplicatedStorage"):FindFirstChild("Animations")
	local abilities = animations and animations:FindFirstChild("Abilities")
	abilities = abilities and abilities:FindFirstChild("ParkourArtist")

	if abilities then
		if abilities:IsA("BoolValue") then
			abilities.Value = true
		elseif abilities:IsA("NumberValue") or abilities:IsA("IntValue") then
			abilities.Value = 1
		end

		for _, descendant in pairs(abilities:GetDescendants()) do
			if descendant:IsA("BoolValue") then
				descendant.Value = true
			elseif descendant:IsA("NumberValue") or descendant:IsA("IntValue") then
				descendant.Value = 1
			end
		end
	end

	localPlayer:SetAttribute("__OwnsParkourArtist", true)
	localPlayer:SetAttribute("HasParkourArtist", true)
	localPlayer:SetAttribute("UnlockedParkourArtist", true)
end

MainModule._ParkourCleanup = function()
	for _, parkourArtistConn in ipairs(MainModule.ParkourArtistConns) do
		pcall(function()
			parkourArtistConn:Disconnect()
		end)
	end

	MainModule.ParkourArtistConns = {}

	if MainModule.ParkourArtistConnection then
		pcall(function()
			MainModule.ParkourArtistConnection:Disconnect()
		end)

		MainModule.ParkourArtistConnection = nil
	end

	MainModule.ParkourArtistState = nil
end

MainModule._ParkourStartMechanics = function()
	MainModule._ParkourCleanup()
	local soundId = "rbxassetid://10753621125"
	local c = Enum.KeyCode.C
	local n = 95
	local n2 = 0.28
	local n3 = 0.18
	local Debris = game:GetService("Debris")

	local function fn20()
		local ok, result = pcall(function()
			return ReplicatedStorage:WaitForChild("Animations", 5):WaitForChild("Abilities", 5):WaitForChild("ParkourArtist", 5)
		end)

		if ok then
			return result
		end
		return nil
	end

	local function fn21()
		local v = fn20()
		if not v then
			return {}
		end
		local tbl4 = {}

		for _, child in ipairs(v:GetChildren()) do
			if child:IsA("Animation") and child.AnimationId ~= "" then
				table.insert(tbl4, child)
			end
		end

		return tbl4
	end

	local function fn22()
		local tbl4 = {
			"PARKOURARTIST",
			"ParkourArtist",
			"PARKOUR_ARTIST",
			"Parkour",
			"PARKOUR",
			"ParkourArtistEffects",
			"ParkourEffects",
		}

		for _, v in ipairs({
			function()
				return ReplicatedStorage.Effects.SetupParts.CustomEffectsFolders
			end,
			function()
				return ReplicatedStorage.Effects.Parts
			end,
			function()
				return ReplicatedStorage.Effects
			end,
		}) do
			local ok, result = pcall(v)

			if ok and result then
				for _, v2 in ipairs(tbl4) do
					local v3 = result:FindFirstChild(v2)
					if v3 then
						return v3
					end
				end
			end
		end

		return nil
	end

	local v = fn22()

	local parkourArtistState = {
		JumpCount = 0,
		CanDoubleJump = false,
		HasLeftGround = false,
		DoubleJumpTrack = nil,
		CKeyTrack = nil,
		DoubleJumpAnim = nil,
		CKeyAnim = nil,
		DashCooldown = false,
		IsDashing = false,
		LastCPress = 0,
	}

	MainModule.ParkourArtistState = parkourArtistState

	local function fn23()
		return localPlayer.Character
	end

	local function fn24()
		local v2 = fn23()
		return v2 and v2:FindFirstChildOfClass("Humanoid")
	end

	local function fn25()
		local v2 = fn23()
		return v2 and v2:FindFirstChild("HumanoidRootPart")
	end

	local function fn26()
		local v2 = fn24()
		if not v2 then
			return nil
		end
		local animator = v2:FindFirstChildOfClass("Animator")

		if not animator then
			animator = Instance.new("Animator")
			animator.Parent = v2
		end

		return animator
	end

	local function fn27()
		local v2 = fn21()
		if #v2 == 0 then
			fn("Parkour Artist", "No animations found", 1)
			return
		end

		if #v2 == 1 then
			parkourArtistState.DoubleJumpAnim = v2[1]
			parkourArtistState.CKeyAnim = v2[1]
		else
			parkourArtistState.DoubleJumpAnim = v2[1]
			parkourArtistState.CKeyAnim = v2[2]
		end

		fn("Parkour Artist", "DoubleJump: " .. tostring(parkourArtistState.DoubleJumpAnim.Name) .. " | C: " .. tostring(parkourArtistState.CKeyAnim.Name), 1.2)
	end

	local function fn28(arg, arg2)
		if not arg then
			return nil
		end

		if parkourArtistState[arg2] then
			pcall(function()
				parkourArtistState[arg2]:Stop(0.08)
				parkourArtistState[arg2]:Destroy()
			end)

			parkourArtistState[arg2] = nil
		end

		local v2 = fn26()
		if not v2 then
			return nil
		end

		local ok, result = pcall(function()
			return v2:LoadAnimation(arg)
		end)

		if ok and result then
			parkourArtistState[arg2] = result
			result.Priority = Enum.AnimationPriority.Action4
			result.Looped = false

			pcall(function()
				result:Play(0.05, 1, 1)
			end)

			result.Stopped:Once(function()
				if parkourArtistState[arg2] == result then
					pcall(function()
						result:Destroy()
					end)

					parkourArtistState[arg2] = nil
				end
			end)

			return result
		end

		return nil
	end

	local function fn29(parent, arg)
		local sound = Instance.new("Sound")
		sound.SoundId = arg and "rbxassetid://9125411438" or "rbxassetid://10753621125"
		sound.Volume = arg and 0.9 or 1
		sound.PlaybackSpeed = arg and 1.15 or 1
		sound.Parent = parent
		sound:Play()
		Debris:AddItem(sound, 3)
		local attachment = Instance.new("Attachment")
		attachment.Parent = parent
		local particleEmitter = Instance.new("ParticleEmitter")
		particleEmitter.Texture = "rbxassetid://241650934"
		particleEmitter.Rate = 0
		particleEmitter.Lifetime = NumberRange.new(0.25, 0.45)
		particleEmitter.Speed = NumberRange.new(6, 14)
		particleEmitter.SpreadAngle = Vector2.new(40, 40)
		particleEmitter.Size = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.6), NumberSequenceKeypoint.new(1, 0) })
		particleEmitter.Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.2), NumberSequenceKeypoint.new(1, 1) })
		particleEmitter.Color = ColorSequence.new(Color3.fromRGB(180, 220, 255))
		particleEmitter.LightEmission = 0.4
		particleEmitter.Parent = attachment
		particleEmitter:Emit(arg and 18 or 12)
		Debris:AddItem(attachment, 1.5)
	end

	local function fn30(arg)
		local v2 = fn23()
		local v3 = fn25()
		if not v2 or not v3 then
			return
		end
		local flag = false

		if v then
			for _, v4 in v:GetDescendants() do
				if v4:IsA("Sound") then
					local clone = v4:Clone()
					clone.Parent = v3
					clone:Play()

					clone.Ended:Once(function()
						if clone then
							clone:Destroy()
						end
					end)

					Debris:AddItem(clone, 8)
					flag = true
				end
			end

			local tbl4 = {}

			for _, v4 in pairs({
				"Head",
				"Torso",
				"UpperTorso",
				"LowerTorso",
				"Left Arm",
				"Right Arm",
				"Left Leg",
				"Right Leg",
				"LeftUpperArm",
				"RightUpperArm",
				"LeftLowerArm",
				"RightLowerArm",
				"LeftUpperLeg",
				"RightUpperLeg",
				"LeftLowerLeg",
				"RightLowerLeg",
				"LeftHand",
				"RightHand",
				"LeftFoot",
				"RightFoot",
				"HumanoidRootPart",
			}) do
				local v5 = v2:FindFirstChild(v4)

				if v5 and v5:IsA("BasePart") then
					table.insert(tbl4, v5)
				end
			end

			for _, v4 in v:GetDescendants() do
				if v4:IsA("ParticleEmitter") then
					for _, v5 in pairs(tbl4) do
						local clone = v4:Clone()
						clone.Enabled = false
						clone.Parent = v5
						clone:Emit(clone:GetAttribute("EmitCount") or 8)
						Debris:AddItem(clone, 2.5)
						flag = true
					end
				end
			end
		end

		if not flag then
			fn29(v3, arg)
		end
	end

	local function fn31()
		local v2 = fn25()
		if not v2 then
			return
		end
		local assemblyLinearVelocity = v2.AssemblyLinearVelocity
		v2.AssemblyLinearVelocity = Vector3.new(assemblyLinearVelocity.X, 75, assemblyLinearVelocity.Z)
		local sound = Instance.new("Sound")
		sound.SoundId = soundId
		sound.Volume = 1
		sound.PlaybackSpeed = 1
		sound.Parent = v2
		sound:Play()
		Debris:AddItem(sound, 3)
		fn28(parkourArtistState.DoubleJumpAnim, "DoubleJumpTrack")
		fn30(false)
	end

	local function fn32()
		if parkourArtistState.DashCooldown or parkourArtistState.IsDashing then
			return
		end
		local lastCPress = parkourArtistState.LastCPress
		if tick() - lastCPress < 0.28 then
			return
		end
		parkourArtistState.LastCPress = tick()
		local v2 = fn23()
		local v3 = fn24()
		local v4 = fn25()
		if not v2 or not v3 or not v4 then
			return
		end
		parkourArtistState.DashCooldown = true
		parkourArtistState.IsDashing = true
		local lookVector = v4.CFrame.LookVector
		local vector = Vector3.new(lookVector.X, 0, lookVector.Z)

		if vector.Magnitude < 0.05 then
			parkourArtistState.IsDashing = false

			task.delay(0.65, function()
				parkourArtistState.DashCooldown = false
			end)

			return
		end

		local unit = vector.Unit
		fn28(parkourArtistState.CKeyAnim, "CKeyTrack")
		fn30(true)
		local now = tick()
		local connection = nil

		connection = RunService.Heartbeat:Connect(function()
			if not MainModule.ParkourArtistEnabled then
				if connection then
					connection:Disconnect()
				end

				parkourArtistState.IsDashing = false
				return
			end

			if not v4 or not v4.Parent then
				if connection then
					connection:Disconnect()
				end

				parkourArtistState.IsDashing = false
				return
			end

			local n4 = tick() - now

			if n2 + n3 <= n4 then
				if connection then
					connection:Disconnect()
				end

				parkourArtistState.IsDashing = false
				return
			end

			if n4 < n2 then
				v4.AssemblyLinearVelocity = Vector3.new(unit.X * n, v4.AssemblyLinearVelocity.Y, unit.Z * n)
			else
				local n5 = n * (1 - math.clamp((n4 - n2) / n3, 0, 1))
				v4.AssemblyLinearVelocity = Vector3.new(unit.X * n5, v4.AssemblyLinearVelocity.Y, unit.Z * n5)
			end

			local raycastParams = RaycastParams.new()
			raycastParams.FilterType = Enum.RaycastFilterType.Exclude
			raycastParams.FilterDescendantsInstances = { v2 }
			raycastParams.IgnoreWater = true

			if workspace:Raycast(v4.Position, unit * 3.5, raycastParams) then
				v4.AssemblyLinearVelocity = Vector3.new(0, v4.AssemblyLinearVelocity.Y, 0)

				if connection then
					connection:Disconnect()
				end

				parkourArtistState.IsDashing = false
			end
		end)

		table.insert(MainModule.ParkourArtistConns, connection)

		task.delay(0.65, function()
			parkourArtistState.DashCooldown = false
		end)
	end

	local function fn33(arg)
		local humanoid = arg:WaitForChild("Humanoid", 5)
		if not humanoid then
			return
		end

		local connection = humanoid.StateChanged:Connect(function(old, new)
			if new == Enum.HumanoidStateType.Landed or new == Enum.HumanoidStateType.Running or new == Enum.HumanoidStateType.RunningNoPhysics then
				parkourArtistState.JumpCount = 0
				parkourArtistState.CanDoubleJump = false
				parkourArtistState.HasLeftGround = false
			end
		end)

		table.insert(MainModule.ParkourArtistConns, connection)
	end

	local connection = UserInputService.JumpRequest:Connect(function()
		if not MainModule.ParkourArtistEnabled then
			return
		end
		local v2 = fn24()
		local v3 = fn25()
		if not v2 or not v3 then
			return
		end
		local state = v2:GetState()

		if state == Enum.HumanoidStateType.Running or state == Enum.HumanoidStateType.RunningNoPhysics or state == Enum.HumanoidStateType.Landed or v2.FloorMaterial ~= Enum.Material.Air then
			parkourArtistState.JumpCount = 1
			parkourArtistState.CanDoubleJump = false
			parkourArtistState.HasLeftGround = false

			task.spawn(function()
				local now = tick()

				while tick() - now < 0.35 do
					if not v2 or not v2.Parent then
						return
					end
					local flag = v2.FloorMaterial == Enum.Material.Air

					if not flag then
						local jumping = Enum.HumanoidStateType.Jumping
						flag = v2:GetState() == jumping
					end

					if not flag then
						local freefall = Enum.HumanoidStateType.Freefall
						flag = v2:GetState() == freefall
					end

					if flag then
						parkourArtistState.HasLeftGround = true
						parkourArtistState.CanDoubleJump = true
						return
					end

					task.wait()
				end
			end)
		elseif parkourArtistState.CanDoubleJump and parkourArtistState.HasLeftGround and parkourArtistState.JumpCount == 1 and (state == Enum.HumanoidStateType.Freefall or state == Enum.HumanoidStateType.Jumping or v2.FloorMaterial == Enum.Material.Air) then
			parkourArtistState.JumpCount = 2
			parkourArtistState.CanDoubleJump = false
			fn31()
		end
	end)

	table.insert(MainModule.ParkourArtistConns, connection)

	local connection2 = UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if gameProcessed then
			return
		end

		if not MainModule.ParkourArtistEnabled then
			return
		end

		if input.KeyCode == c then
			fn32()
		end
	end)

	table.insert(MainModule.ParkourArtistConns, connection2)
	fn27()

	if localPlayer.Character then
		fn33(localPlayer.Character)
	end

	local connection3 = localPlayer.CharacterAdded:Connect(function(character)
		parkourArtistState.JumpCount = 0
		parkourArtistState.CanDoubleJump = false
		parkourArtistState.HasLeftGround = false
		parkourArtistState.DashCooldown = false
		parkourArtistState.IsDashing = false
		parkourArtistState.DoubleJumpTrack = nil
		parkourArtistState.CKeyTrack = nil
		task.wait(0.4)

		if MainModule.ParkourArtistEnabled then
			fn27()
			fn33(character)
		end
	end)

	table.insert(MainModule.ParkourArtistConns, connection3)
end

MainModule.ParkourArtistFolder = nil

MainModule.toggle_parkour_artist = function(arg)
	local parkourArtistEnabled = arg and true or false
	MainModule.ParkourArtistEnabled = parkourArtistEnabled

	if parkourArtistEnabled then
		if not MainModule.OriginalPower then
			MainModule.OriginalPower = localPlayer:GetAttribute("_EquippedPower") or ""
		end

		pcall(function()
			local live = Workspace:FindFirstChild("Live") or Workspace:WaitForChild("Live", 5)
			if not live then
				return
			end
			local v = live:FindFirstChild(localPlayer.Name) or live:WaitForChild(localPlayer.Name, 5)
			if not v then
				return
			end
			local parkourArtist = v:FindFirstChild("ParkourArtist")

			if parkourArtist then
				parkourArtist:Destroy()
			end

			local folder = Instance.new("Folder")
			folder.Name = "ParkourArtist"
			folder.Parent = v
			MainModule.ParkourArtistFolder = folder
		end)

		pcall(function()
			localPlayer:SetAttribute("_EquippedPower", "PARKOUR ARTIST")
			localPlayer:SetAttribute("__OwnsParkourArtist", true)
			localPlayer:SetAttribute("HasParkourArtist", true)
			localPlayer:SetAttribute("UnlockedParkourArtist", true)
		end)

		if MainModule.ParkourArtistConnection then
			pcall(function()
				MainModule.ParkourArtistConnection:Disconnect()
			end)
		end

		MainModule.ParkourArtistConnection = RunService.Heartbeat:Connect(function()
			if not MainModule.ParkourArtistEnabled then
				return
			end

			pcall(function()
				localPlayer:SetAttribute("_EquippedPower", "PARKOUR ARTIST")
				local live = Workspace:FindFirstChild("Live")
				live = live and live:FindFirstChild(localPlayer.Name)

				if live and not live:FindFirstChild("ParkourArtist") then
					local folder = Instance.new("Folder")
					folder.Name = "ParkourArtist"
					folder.Parent = live
					MainModule.ParkourArtistFolder = folder
				end
			end)
		end)

		fn("Parkour Artist", "Enabled", 0.8)
	else
		MainModule.ParkourArtistEnabled = false

		if MainModule.ParkourArtistConnection then
			pcall(function()
				MainModule.ParkourArtistConnection:Disconnect()
			end)

			MainModule.ParkourArtistConnection = nil
		end

		pcall(function()
			if MainModule.ParkourArtistFolder and MainModule.ParkourArtistFolder.Parent then
				MainModule.ParkourArtistFolder:Destroy()
			end

			MainModule.ParkourArtistFolder = nil
			local live = Workspace:FindFirstChild("Live")
			live = live and live:FindFirstChild(localPlayer.Name)

			if live then
				local parkourArtist = live:FindFirstChild("ParkourArtist")

				if parkourArtist then
					parkourArtist:Destroy()
				end
			end
		end)

		if MainModule.OriginalPower then
			localPlayer:SetAttribute("_EquippedPower", MainModule.OriginalPower)
		else
			localPlayer:SetAttribute("_EquippedPower", nil)
		end

		fn("Parkour Artist", "Disabled", 0.8)
	end

	PlayToggleSound()
	return true
end

MainModule.set_parkour_artist = function()
	MainModule.unlock_parkour_artist()
	PlayToggleSound()
end

MainModule.SpikesPlatformTeleport = { Enabled = false, Connection = nil, Platform = nil, OriginalCFrame = nil, SpikesPosition = nil }

MainModule.toggle_spikes_platform_teleport = function(enabled)
	if enabled and not MainModule.is_game_active("HideAndSeek") then
		MainModule.notify("Spikes Platform", "Wait for HideAndSeek", 0.9)
		PlayErrorSound()

		if MainModule.ToggleRefs.SpikesPlatformTeleport then
			MainModule.ToggleRefs.SpikesPlatformTeleport:SetValue(false)
		end

		return false
	end

	if MainModule.SpikesPlatformTeleport.Connection then
		MainModule.SpikesPlatformTeleport.Connection:Disconnect()
		MainModule.SpikesPlatformTeleport.Connection = nil
	end

	if MainModule.SpikesPlatformTeleport.Platform then
		pcall(function()
			MainModule.SpikesPlatformTeleport.Platform:Destroy()
		end)

		MainModule.SpikesPlatformTeleport.Platform = nil
	end

	MainModule.SpikesPlatformTeleport.Enabled = enabled
	MainModule.SpikesPlatformTeleport.OriginalCFrame = nil
	MainModule.SpikesPlatformTeleport.SpikesPosition = nil

	if not enabled then
		local v = MainModule.get_character()

		if v and MainModule.SpikesPlatformTeleport.OriginalCFrame then
			v:SetPrimaryPartCFrame(MainModule.SpikesPlatformTeleport.OriginalCFrame)
			fn({ Title = "Spikes Platform", Description = "Returned", Duration = 0.9 })
		end

		PlayToggleSound()
		return true
	end

	local hideAndSeekMap = workspace:FindFirstChild("HideAndSeekMap")
	local killingParts = hideAndSeekMap and hideAndSeekMap:FindFirstChild("KillingParts")
	local position = nil

	if killingParts then
		position = nil

		for _, child in pairs(killingParts:GetChildren()) do
			if child:IsA("BasePart") then
				position = child.Position
				break
			else
				position = nil
			end
		end
	end

	local v

	if not position then
		for _, descendant in pairs(workspace:GetDescendants()) do
			if descendant:IsA("BasePart") and descendant.Name == "Spikes" then
				position = descendant.Position
				break
			end
		end

		v = position
	else
		v = position
	end

	if not v then
		MainModule.notify("TP To Spikes", "Spikes not found", 0.9)
		PlayErrorSound()

		if MainModule.ToggleRefs.SpikesPlatformTeleport then
			MainModule.ToggleRefs.SpikesPlatformTeleport:SetValue(false)
		end

		return false
	end

	MainModule.SpikesPlatformTeleport.SpikesPosition = v
	local part = Instance.new("Part")
	part.Name = HttpService:GenerateGUID(false)
	part.Size = Vector3.new(10, 1, 10)
	part.Position = v + Vector3.new(0, 10, 0)
	part.Anchored = true
	part.CanCollide = true
	part.Transparency = 0.5
	part.Color = Color3.fromRGB(0, 255, 0)
	part.Material = Enum.Material.Neon
	part.Parent = workspace
	MainModule.SpikesPlatformTeleport.Platform = part
	local v2 = MainModule.get_character()

	if v2 then
		local v3 = MainModule.get_root_part(v2)

		if v3 then
			MainModule.SpikesPlatformTeleport.OriginalCFrame = v2:GetPrimaryPartCFrame()
			v3.CFrame = CFrame.new(part.Position + Vector3.new(0, 3, 0))
			fn({ Title = "Teleport to spikes", Description = "Teleported", Duration = 0.9 })
		end
	end

	MainModule.SpikesPlatformTeleport.Connection = RunService.Heartbeat:Connect(function()
		if not MainModule.SpikesPlatformTeleport.Enabled then
			return
		end

		if not MainModule.is_game_active("HideAndSeek") then
			MainModule.toggle_spikes_platform_teleport(false)

			if MainModule.ToggleRefs.SpikesPlatformTeleport then
				MainModule.ToggleRefs.SpikesPlatformTeleport:SetValue(false)
			end

			return
		end

		if not MainModule.SpikesPlatformTeleport.Platform or not MainModule.SpikesPlatformTeleport.Platform.Parent then
			local part2 = Instance.new("Part")
			part2.Name = HttpService:GenerateGUID(false)
			part2.Size = Vector3.new(10, 1, 10)
			part2.Position = MainModule.SpikesPlatformTeleport.SpikesPosition + Vector3.new(0, 10, 0)
			part2.Anchored = true
			part2.CanCollide = true
			part2.Transparency = 0.5
			part2.Color = Color3.fromRGB(0, 255, 0)
			part2.Material = Enum.Material.Neon
			part2.Parent = workspace
			MainModule.SpikesPlatformTeleport.Platform = part2
		end

		local v3 = MainModule.get_character()

		if v3 then
			local v4 = MainModule.get_root_part(v3)

			if v4 then
				if (v4.Position - MainModule.SpikesPlatformTeleport.Platform.Position).Magnitude > 15 then
					if not MainModule.SpikesPlatformTeleport.OriginalCFrame then
						MainModule.SpikesPlatformTeleport.OriginalCFrame = v3:GetPrimaryPartCFrame()
					end

					v4.CFrame = CFrame.new(MainModule.SpikesPlatformTeleport.Platform.Position + Vector3.new(0, 3, 0))
				end
			end
		end
	end)

	PlayToggleSound()
	return true
end

MainModule.HCGlassESPEnabled = false
MainModule.HCGlassESPConnection = nil
MainModule.HCGlassESPObjects = {}

MainModule.create_hc_glass_esp = function(adornee, arg)
	if MainModule.HCGlassESPObjects[adornee] then
		return
	end
	local primaryPart = adornee.PrimaryPart
	if not primaryPart then
		return
	end
	local highlight = Instance.new("Highlight")
	highlight.Adornee = adornee
	highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
	highlight.FillColor = arg and Color3.fromRGB(255, 0, 0) or Color3.fromRGB(0, 255, 0)
	highlight.FillTransparency = 0.5
	highlight.OutlineTransparency = 0.3
	highlight.Parent = adornee
	local billboardGui = Instance.new("BillboardGui")
	billboardGui.Adornee = primaryPart
	billboardGui.Size = UDim2.new(0, 100, 0, 30)
	billboardGui.StudsOffset = Vector3.new(0, 3, 0)
	billboardGui.AlwaysOnTop = true
	billboardGui.Parent = primaryPart
	local textLabel = Instance.new("TextLabel")
	textLabel.Size = UDim2.new(1, 0, 1, 0)
	textLabel.BackgroundTransparency = 1
	textLabel.Text = arg and "BREAKABLE" or "SAFE"
	textLabel.TextColor3 = arg and Color3.fromRGB(255, 0, 0) or Color3.fromRGB(0, 255, 0)
	textLabel.TextScaled = true
	textLabel.Font = Enum.Font.GothamBold
	textLabel.TextStrokeTransparency = 0
	textLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
	textLabel.Parent = billboardGui
	MainModule.HCGlassESPObjects[adornee] = { highlight = highlight, billboard = billboardGui, label = textLabel, tile = adornee }
end

MainModule.scan_hc_glass_bridge = function()
	local glassHolder = workspace:FindFirstChild("GlassBridge") and workspace.GlassBridge:FindFirstChild("GlassHolder")
	if not glassHolder then
		return
	end

	for _, child in pairs(glassHolder:GetChildren()) do
		for _, child2 in pairs(child:GetChildren()) do
			if child2:IsA("Model") and child2.PrimaryPart then
				MainModule.create_hc_glass_esp(child2, child2.PrimaryPart:GetAttribute("exploitingisevil") == true)
			end
		end
	end
end

MainModule.clear_hc_glass_esp = function()
	for _, hcGlassESPObject in pairs(MainModule.HCGlassESPObjects) do
		if hcGlassESPObject.highlight then
			pcall(function()
				hcGlassESPObject.highlight:Destroy()
			end)
		end

		if hcGlassESPObject.billboard then
			pcall(function()
				hcGlassESPObject.billboard:Destroy()
			end)
		end
	end

	MainModule.HCGlassESPObjects = {}
end

MainModule.toggle_hc_glass_esp = function(hcGlassESPEnabled)
	MainModule.HCGlassESPEnabled = hcGlassESPEnabled

	if MainModule.HCGlassESPConnection then
		MainModule.HCGlassESPConnection:Disconnect()
		MainModule.HCGlassESPConnection = nil
	end

	if hcGlassESPEnabled then
		MainModule.scan_hc_glass_bridge()

		MainModule.HCGlassESPConnection = RunService.Heartbeat:Connect(function()
			if not MainModule.HCGlassESPEnabled then
				return
			end

			if not MainModule.is_game_active("GlassBridge") then
				MainModule.disable_toggle("HCGlassESP")
				return
			end
			MainModule.scan_hc_glass_bridge()
		end)
	else
		MainModule.clear_hc_glass_esp()
	end

	PlayToggleSound()
end

MainModule.TugOfWarAutoQTEMiss = false
MainModule.TugOfWarAutoQTEMissConnection = nil

local function fn20()
	local playerGui = localPlayer:FindFirstChild("PlayerGui")
	if not playerGui then
		return
	end
	local tugOfWarUIV2 = playerGui:FindFirstChild("TugOfWarUIV2") or playerGui:FindFirstChild("TugOfWarUI") or playerGui:FindFirstChild("TugofWarRemake")
	if not tugOfWarUIV2 then
		return
	end
	local tugofWarRemake = tugOfWarUIV2:FindFirstChild("TugofWarRemake") or tugOfWarUIV2
	tugofWarRemake = tugofWarRemake and tugofWarRemake:FindFirstChild("CircleBase")
	if tugofWarRemake and tugofWarRemake.Visible then
		return tugofWarRemake
	end
	return nil
end

MainModule.toggle_tug_of_war_auto_qte_miss = function(tugOfWarAutoQTEMiss)
	MainModule.TugOfWarAutoQTEMiss = tugOfWarAutoQTEMiss

	if MainModule.TugOfWarAutoQTEMissConnection then
		MainModule.TugOfWarAutoQTEMissConnection:Disconnect()
		MainModule.TugOfWarAutoQTEMissConnection = nil
	end

	if tugOfWarAutoQTEMiss then
		MainModule.TugOfWarAutoQTEMissConnection = RunService.RenderStepped:Connect(function()
			if not MainModule.TugOfWarAutoQTEMiss then
				return
			end

			if localPlayer:GetAttribute("TugOfWarPhase") ~= "QTE" then
				return
			end
			local v = fn20()
			if not v then
				return
			end
			local arrow = v:FindFirstChild("Arrow")
			local medium = v:FindFirstChild("Medium")
			if not (arrow and medium) then
				return
			end
			medium.Rotation = arrow.Rotation
		end)
	end

	PlayToggleSound()
end

MainModule.EffectShooter = {
	Enabled = false,
	Connection = nil,
	LastShootTime = 0,
	ShootCooldown = 0.05,
	TrackedPlayers = {},
	TargetEffect = "GuardCanKillLockOn",
}

MainModule.get_local_gun = function()
	local v = nil

	if localPlayer.Character then
		v = nil

		for _, child in pairs(localPlayer.Character:GetChildren()) do
			if child:IsA("Tool") and child:GetAttribute("Gun") then
				v = child
				break
			else
				v = nil
			end
		end
	end

	local v2

	if not v and localPlayer.Backpack then
		for _, child in pairs(localPlayer.Backpack:GetChildren()) do
			if child:IsA("Tool") and child:GetAttribute("Gun") then
				v = child
				break
			end
		end

		v2 = v
	else
		v2 = v
	end

	return v2
end

MainModule.has_target_effect = function(arg)
	if not arg or not arg.Character then
		return false
	end

	for _, descendant in pairs(arg.Character:GetDescendants()) do
		if descendant:IsA("BillboardGui") and descendant.Name == MainModule.EffectShooter.TargetEffect then
			return true
		end
	end

	return false
end

MainModule.shoot_at_player = function(arg)
	local v = MainModule.get_local_gun()
	if not v then
		return false
	end
	local tbl4 = {}

	local tbl5 = {
		ClientRayNormal = Vector3.new(-1.1920929e-07, 1.0000001, 0),
		FiredGun = true,
		SecondaryHitTargets = {},
		ClientRayInstance = workspace:FindFirstChild("StairWalkWay") and workspace.StairWalkWay:FindFirstChild("Part") or nil,
	}

	tbl5.ClientRayPosition = Vector3.new(-220.1749, 183.29578, 301.07257)
	tbl5.bulletCF = CFrame.new(-220.50398254394531, 185.22506713867188, 302.133544921875, 0.95511162281036377, 0.25673103332519531, -0.14782091975212097, 7.4505814851022478e-09, 0.49897986650466919, 0.86661356687545776, 0.29624626040458679, -0.82771271467208862, 0.47658145427703857)
	tbl5.HitTargets = { [arg] = "Head" }
	tbl5.bulletSizeC = Vector3.new(0.01, 0.01, 4.4525)
	tbl5.NoMuzzleFX = false
	tbl5.FirePosition = Vector3.new(-72.888504, -679.48035, -173.31006)
	tbl4[1] = v
	tbl4[2] = tbl5

	pcall(function()
		ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("FiredGunClient"):FireServer(unpack(tbl4))
	end)

	return true
end

MainModule.track_player_effects = function(arg)
	if not arg then
		return
	end

	if MainModule.EffectShooter.TrackedPlayers[arg] then
		return
	end
	local tbl4 = {}

	local connection = arg.CharacterAdded:Connect(function()
		task.wait(0.5)
	end)

	table.insert(tbl4, connection)

	if arg.Character then
		local connection2 = arg.Character.DescendantAdded:Connect(function()
		end)

		table.insert(tbl4, connection2)
	end

	MainModule.EffectShooter.TrackedPlayers[arg] = tbl4
end

MainModule.toggle_effect_shooter = function(enabled)
	MainModule.EffectShooter.Enabled = enabled
	MainModule.AutoShootEnabled = enabled and true or false

	if MainModule.EffectShooter.Connection then
		MainModule.EffectShooter.Connection:Disconnect()
		MainModule.EffectShooter.Connection = nil
	end

	if enabled then
		pcall(function()
			if MainModule.toggle_rapid_fire and not MainModule.RapidFireEnabled then
				MainModule.toggle_rapid_fire(true)
			end
		end)

		pcall(function()
			if MainModule.toggle_infinite_ammo and not MainModule.InfiniteAmmoEnabled then
				MainModule.toggle_infinite_ammo(true)
			end
		end)

		local n = 0

		MainModule.EffectShooter.Connection = RunService.Heartbeat:Connect(function()
			if not MainModule.EffectShooter.Enabled then
				return
			end
			local now = tick()
			if now - n < 0.08 then
				return
			end
			n = now
			local getLocalGun = MainModule.get_local_gun and MainModule.get_local_gun()

			if not getLocalGun then
				local character = localPlayer.Character

				if character then
					for _, child in ipairs(character:GetChildren()) do
						if child:IsA("Tool") and (child:GetAttribute("Gun") or child:FindFirstChild("GunScript") or string.lower(child.Name):find("gun")) then
							getLocalGun = child
							break
						end
					end
				end
			end

			if not getLocalGun then
				return
			end
			local tbl4 = {}
			local live = workspace:FindFirstChild("Live")

			if live then
				for _, child in ipairs(live:GetChildren()) do
					if child:IsA("Model") and child.Name ~= localPlayer.Name then
						local v = Players:FindFirstChild(child.Name)
						local hasTargetEffect = v and MainModule.has_target_effect and MainModule.has_target_effect(v)
						local flag = false

						if hasTargetEffect then
							flag = true
						end

						if not flag then
							for _, descendant in ipairs(child:GetDescendants()) do
								if descendant:IsA("Highlight") and descendant.Enabled then
									local fillColor = descendant.FillColor
									if fillColor and fillColor.R > 0.7 and fillColor.G < 0.4 and fillColor.B < 0.4 then
										flag = true
										break
									end
								elseif descendant:IsA("BillboardGui") and (descendant.Name:find("Target") or descendant.Name:find("Effect")) then
									flag = true
									break
								end
							end
						end

						if flag then
							tbl4[child.Name] = "Head"
						end
					end
				end
			end

			for _, player in ipairs(Players:GetPlayers()) do
				if player ~= localPlayer and MainModule.has_target_effect and MainModule.has_target_effect(player) then
					tbl4[player.Name] = "Head"
				end
			end

			if next(tbl4) == nil then
				return
			end
			local remotes = ReplicatedStorage:FindFirstChild("Remotes")
			local firedGunClient = remotes and remotes:FindFirstChild("FiredGunClient")
			if not firedGunClient then
				return
			end

			if workspace:FindFirstChild("StairWalkWay") and workspace.StairWalkWay:FindFirstChild("Part") then
			end

			local tbl5 = {}

			local tbl6 = {
				ClientRayNormal = Vector3.new(0, 1, 0),
				FiredGun = true,
				SecondaryHitTargets = {},
				ClientRayInstance = Vector3.new,
				ClientRayPosition = Vector3.zero,
				bulletCF = CFrame.new(),
				HitTargets = tbl4,
				bulletSizeC = Vector3.new(0.01, 0.01, 5),
				NoMuzzleFX = true,
				FirePosition = Vector3.zero,
			}

			tbl5[1] = getLocalGun
			tbl5[2] = tbl6

			pcall(function()
				firedGunClient:FireServer(unpack(tbl5))
			end)
		end)
	end

	PlayToggleSound()
end

MainModule.is_mobile = function()
	return UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
end

MainModule.is_game_active = function(arg)
	local values = Workspace:FindFirstChild("Values")
	if not values then
		return false
	end
	local currentGame = values:FindFirstChild("CurrentGame")
	return currentGame and currentGame.Value == arg
end

MainModule.disable_toggle = function(arg)
	if MainModule.ToggleRefs[arg] and MainModule.ToggleRefs[arg].SetValue then
		pcall(function()
			MainModule.ToggleRefs[arg]:SetValue(false)
		end)
	end
end

MainModule.can_enable_toggle = function(arg, arg2, arg3)
	if not MainModule.is_game_active(arg) then
		MainModule.notify(arg2, "Wait for " .. arg .. "!", 0.9)
		PlayErrorSound()

		if arg3 and arg3.SetValue then
			pcall(function()
				arg3:SetValue(false)
			end)
		end

		return false
	end

	if not MainModule.is_feature_supported(arg2) then
		MainModule.notify(arg2, "Not supported in your executor", 0.9)
		PlayErrorSound()

		if arg3 and arg3.SetValue then
			pcall(function()
				arg3:SetValue(false)
			end)
		end

		return false
	end

	return true
end

MainModule.safe_teleport = function(arg)
	local v = MainModule.get_character()

	if v then
		local v2 = MainModule.get_root_part(v)
		if v2 then
			v2.CFrame = CFrame.new(arg)
			return true
		end
	end

	return false
end

MainModule.SafeTeleport = MainModule.safe_teleport

MainModule.is_hider = function(arg)
	return arg and arg:GetAttribute("IsHider") == true
end

MainModule.is_seeker = function(arg)
	return arg and arg:GetAttribute("IsHunter") == true
end

MainModule.FaceTargetModule = { Enabled = false, Connection = nil }

MainModule.toggle_face_target = function(enabled)
	if type(enabled) ~= "boolean" then
		enabled = not MainModule.FaceTargetModule.Enabled
	end

	if MainModule.FaceTargetModule.Connection then
		MainModule.FaceTargetModule.Connection:Disconnect()
		MainModule.FaceTargetModule.Connection = nil
	end

	MainModule.FaceTargetModule.Enabled = enabled

	if enabled then
		MainModule.FaceTargetModule.Connection = RunService.Heartbeat:Connect(function()
			if not MainModule.FaceTargetModule.Enabled then
				return
			end
			local character = localPlayer.Character
			if not character then
				return
			end
			local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
			if not humanoidRootPart then
				return
			end
			local position = humanoidRootPart.Position
			local huge = math.huge
			local v = nil

			for _, player in ipairs(Players:GetPlayers()) do
				if player ~= localPlayer and player.Character then
					local humanoidRootPart2 = player.Character:FindFirstChild("HumanoidRootPart")

					if humanoidRootPart2 then
						local magnitude = (humanoidRootPart2.Position - position).Magnitude

						if magnitude < huge then
							huge = magnitude
							v = player
						end
					end
				end
			end

			if v and v.Character then
				local humanoidRootPart2 = v.Character:FindFirstChild("HumanoidRootPart")

				if humanoidRootPart2 then
					local cframe = CFrame.lookAt(humanoidRootPart.Position, humanoidRootPart2.Position)
					local n = cframe - cframe.Position
					humanoidRootPart.CFrame = CFrame.new(humanoidRootPart.Position) * n
				end
			end
		end)
	end

	PlayToggleSound()
end

MainModule.AutoDodge = {
	Enabled = false,
	AnimationIds = {
		"rbxassetid://88451099342711",
		"rbxassetid://79649041083405",
		"rbxassetid://73242877658272",
		"rbxassetid://114928327045353",
		"rbxassetid://135690448001690",
		"rbxassetid://103355259844069",
		"rbxassetid://125906547773381",
		"rbxassetid://121147456137931",
		"rbxassetid://96924216250322",
		"rbxassetid://116839849594540",
		"rbxassetid://104041807075625",
		"rbxassetid://83057176809194",
		"rbxassetid://103318207627541",
		"rbxassetid://121473077508383",
		"rbxassetid://94215646393565",
		"rbxassetid://81533666958072",
		"rbxassetid://116839849594540",
	},
	Connections = {},
	LastDodgeTime = 0,
	DodgeCooldown = 1.1,
	Range = 6,
	RangeSquared = 36,
	AnimationIdsSet = {},
	ActiveAnimations = {},
	HeartbeatConnection = nil,
	PlayerStates = {},
	PlayerLastPos = {},
	PlayerAnimationStart = {},
	DodgePredictions = {},
	ActiveHitboxes = {},
	LastLookVectors = {},
	HitboxConnections = {},
}

for _, animationId in ipairs(MainModule.AutoDodge.AnimationIds) do
	MainModule.AutoDodge.AnimationIdsSet[animationId] = true
end

MainModule.AutoDodge_executeDodgeInstant = function()
	if not MainModule.AutoDodge.Enabled then
		return false
	end
	local localPlayer2 = Players.LocalPlayer
	if not localPlayer2 then
		return false
	end
	local backpack = localPlayer2:FindFirstChild("Backpack")
	if not backpack then
		return false
	end

	if not backpack:FindFirstChild("DODGE!") then
		return false
	end
	local hotbar = localPlayer2.PlayerGui:FindFirstChild("Hotbar")
	if not hotbar then
		return false
	end
	local backpack2 = hotbar:FindFirstChild("Backpack")
	if not backpack2 then
		return false
	end
	local hotbar2 = backpack2:FindFirstChild("Hotbar")
	if not hotbar2 then
		return false
	end
	local v = nil

	for _, child in pairs(hotbar2:GetChildren()) do
		if child:FindFirstChild("ToolName") and child.ToolName.Text == "DODGE!" then
			v = child
			break
		end
	end

	if not v then
		return false
	end

	local ok = pcall(function()
		if not getconnections then
			return
		end
		local v2 = getconnections(v.MouseButton1Down)

		for _, v3 in pairs(v2) do
			v3:Fire()
		end
	end)

	if ok then
		MainModule.AutoDodge.LastDodgeTime = tick()
	end

	return ok
end

MainModule.AutoDodge_executeDodge = function()
	if not MainModule.AutoDodge.Enabled then
		return false
	end
	local now = tick()
	if now - MainModule.AutoDodge.LastDodgeTime < MainModule.AutoDodge.DodgeCooldown then
		return false
	end
	local localPlayer2 = Players.LocalPlayer
	if not localPlayer2 then
		return false
	end
	local backpack = localPlayer2:FindFirstChild("Backpack")
	if not backpack then
		return false
	end

	if not backpack:FindFirstChild("DODGE!") then
		return false
	end
	local hotbar = localPlayer2.PlayerGui:FindFirstChild("Hotbar")
	if not hotbar then
		return false
	end
	local backpack2 = hotbar:FindFirstChild("Backpack")
	if not backpack2 then
		return false
	end
	local hotbar2 = backpack2:FindFirstChild("Hotbar")
	if not hotbar2 then
		return false
	end
	local v = nil

	for _, child in pairs(hotbar2:GetChildren()) do
		if child:FindFirstChild("ToolName") and child.ToolName.Text == "DODGE!" then
			v = child
			break
		end
	end

	if not v then
		return false
	end

	if not pcall(function()
		if not getconnections then
			return
		end
		local v2 = getconnections(v.MouseButton1Down)

		for _, v3 in pairs(v2) do
			v3:Fire()
		end
	end) then
		return false
	end

	MainModule.AutoDodge.LastDodgeTime = now
	return true
end

MainModule.AutoDodge_getForwardLength = function(arg, arg2)
	local n

	if arg:find("99157505926076") or arg:find("123072675259257") then
		n = 16
	else
		local pos = arg:find("73242877658272") or arg:find("79649041083405")
		n = 5

		if pos then
			n = 6.5
		end
	end

	local flag = false

	for _, v in ipairs({ "773242877658272", "79649041083405", "105341857343164" }) do
		if arg:find(v) then
			flag = true
			break
		end
	end

	local isPlaying = flag and arg2 and arg2.IsPlaying
	local n2 = 0.88

	if isPlaying then
		local ok, result = pcall(function()
			return arg2.Speed
		end)

		if ok and result and result >= 19 then
			n2 = 1.3
		end
	end

	return n * n2
end

MainModule.AutoDodge_getAnimationLength = function(arg)
	local ok, result = pcall(function()
		return arg.Length
	end)

	return ok and result or 1
end

MainModule.AutoDodge_setupHitboxUpdater = function(arg, arg2, arg3)
	local v

	return (RunService.RenderStepped:Connect(function()
		if not MainModule.AutoDodge.Enabled then
			if v then
				v:Disconnect()
			end

			return
		end

		if not arg or not arg.Parent then
			if v then
				v:Disconnect()
			end

			return
		end

		if not arg2 or not arg2.Parent then
			if v then
				v:Disconnect()
			end

			return
		end

		arg.CFrame = arg2.CFrame * arg3
	end))
end

MainModule.AutoDodge_createHitbox = function(arg, arg2, arg3, arg4)
	if not MainModule.AutoDodge.Enabled then
		return nil
	end
	local localPlayer2 = Players.LocalPlayer
	if arg4 == localPlayer2 then
		return nil
	end

	if not arg or not arg.Parent then
		return nil
	end
	local humanoidRootPart = arg:FindFirstChild("HumanoidRootPart")
	if not humanoidRootPart then
		return nil
	end
	local character = localPlayer2 and localPlayer2.Character
	local humanoidRootPart2 = character and character:FindFirstChild("HumanoidRootPart")
	if not humanoidRootPart2 then
		return nil
	end

	if not arg3 or not arg3.IsPlaying then
		return nil
	end
	local str = tostring(tick()) .. "*" .. tostring(arg.Name) .. "*" .. string.sub(arg2, -8)
	local v = MainModule.AutoDodge_getAnimationLength(arg3)
	local n = math.max(0.1, v - 0.1)
	local v2 = MainModule.AutoDodge_getForwardLength(arg2, arg3)
	local part = Instance.new("Part")
	part.Name = "Hitbox_Front*" .. string.sub(arg2, -6) .. "*" .. tick()
	part.Size = Vector3.new(7.04, 5.28, v2)
	part.Color = Color3.fromRGB(255, 50, 50)
	part.Transparency = 1
	part.Anchored = false
	part.CanCollide = false
	part.Material = Enum.Material.Neon
	local cframe = CFrame.new(0, 1.2, -(v2 / 2 + 1.5))
	part.CFrame = humanoidRootPart.CFrame * cframe
	local selectionBox = Instance.new("SelectionBox")
	selectionBox.Adornee = part
	selectionBox.Color3 = part.Color
	selectionBox.LineThickness = 0.12
	selectionBox.Transparency = 1
	selectionBox.Parent = part
	part.Parent = Workspace
	local part2 = Instance.new("Part")
	part2.Name = "Hitbox_Back*" .. string.sub(arg2, -6) .. "*" .. tick()
	part2.Size = Vector3.new(0.7, 0.7, 0.7)
	part2.Color = Color3.fromRGB(255, 200, 100)
	part2.Transparency = 1
	part2.Material = Enum.Material.Neon
	part2.Anchored = false
	part2.CanCollide = false
	local cframe2 = CFrame.new(0, 0.3, 1.5)
	part2.CFrame = humanoidRootPart.CFrame * cframe2
	local selectionBox2 = Instance.new("SelectionBox")
	selectionBox2.Adornee = part2
	selectionBox2.Color3 = part2.Color
	selectionBox2.LineThickness = 0.02
	selectionBox2.Transparency = 1
	selectionBox2.Parent = part2
	part2.Parent = Workspace
	local v3 = MainModule.AutoDodge_setupHitboxUpdater(part, humanoidRootPart, cframe)
	local v4 = MainModule.AutoDodge_setupHitboxUpdater(part2, humanoidRootPart, cframe2)

	local tbl4 = {
		active = true,
		character = arg,
		frontHitbox = part,
		backHitbox = part2,
		hitboxId = str,
		animationStartTime = tick(),
		hasDodged = false,
		animationTrack = arg3,
		characterName = arg.Name,
	}

	local function fn21(hit)
		if not MainModule.AutoDodge.Enabled then
			return
		end

		if not humanoidRootPart2 or not humanoidRootPart2.Parent then
			return
		end

		if tbl4.hasDodged then
			return
		end

		if not tbl4.active then
			return
		end
		local flag

		if hit == humanoidRootPart2 then
			flag = true
		else
			local flag2 = character and (hit.Parent == character or hit:IsDescendantOf(character))
			flag = false

			if flag2 then
				flag = true
			end
		end

		if flag then
			tbl4.hasDodged = true

			task.spawn(function()
				MainModule.AutoDodge_executeDodgeInstant()
			end)
		end
	end

	local connection = part.Touched:Connect(fn21)
	local connection2 = part2.Touched:Connect(fn21)

	local function fn22()
		tbl4.active = false

		if v3 then
			v3:Disconnect()
		end

		if v4 then
			v4:Disconnect()
		end

		if connection then
			connection:Disconnect()
		end

		if connection2 then
			connection2:Disconnect()
		end

		if part and part.Parent then
			part:Destroy()
		end

		if part2 and part2.Parent then
			part2:Destroy()
		end
	end

	task.spawn(function()
		if n > 0 and n < v then
			task.wait(n)
		else
			while arg3 and arg3.IsPlaying do
				task.wait(0.03)
			end
		end

		fn22()
	end)

	return { part, part2 }
end

MainModule.AutoDodge_destroyAllHitboxes = function()
	for _, child in pairs(Workspace:GetChildren()) do
		local isPart = child:IsA("Part")

		if isPart then
			isPart = child.Name:find("Hitbox") or child.Name:find("GiantHitbox") or child.Name:find("RotationEffect")
		end

		if isPart then
			pcall(function()
				child:Destroy()
			end)
		end
	end
end

MainModule.AutoDodge_setupAnimationTrackingWithHitboxes = function()
	local function fn21(arg)
		if not arg then
			return
		end

		local function fn22(character)
			local humanoid = character:WaitForChild("Humanoid", 5)
			if not humanoid then
				return
			end

			humanoid.AnimationPlayed:Connect(function(arg2)
				if not MainModule.AutoDodge.Enabled then
					return
				end
				local animationId = arg2.Animation.AnimationId

				if MainModule.AutoDodge.AnimationIdsSet[animationId] then
					task.spawn(function()
						MainModule.AutoDodge_createHitbox(arg.Character, animationId, arg2, arg)
					end)
				end
			end)
		end

		if arg.Character then
			fn22(arg.Character)
		end

		arg.CharacterAdded:Connect(fn22)
	end

	for _, player in pairs(Players:GetPlayers()) do
		task.spawn(function()
			fn21(player)
		end)
	end

	local connection = Players.PlayerAdded:Connect(function(player)
		fn21(player)
	end)

	table.insert(MainModule.AutoDodge.Connections, connection)
end

MainModule.AutoDodge_predictAttack = function(arg, arg2)
	if not arg or not arg.Character then
		return false
	end

	if not arg2 or not arg2.Character then
		return false
	end
	local humanoidRootPart = arg2.Character:FindFirstChild("HumanoidRootPart")
	local humanoidRootPart2 = arg.Character:FindFirstChild("HumanoidRootPart")
	if not humanoidRootPart or not humanoidRootPart2 then
		return false
	end
	local magnitude = (humanoidRootPart2.Position - humanoidRootPart.Position).Magnitude
	if magnitude > 6 then
		return false
	end
	local humanoid = arg.Character:FindFirstChild("Humanoid")
	if not humanoid then
		return false
	end
	local playingAnimationTracks = humanoid:GetPlayingAnimationTracks()
	local flag = false
	local flag2 = false

	for _, playingAnimationTrack in pairs(playingAnimationTracks) do
		if playingAnimationTrack and playingAnimationTrack.Animation and playingAnimationTrack.IsPlaying then
			if MainModule.AutoDodge.AnimationIdsSet[playingAnimationTrack.Animation.AnimationId] then
				local n = MainModule.AutoDodge.PlayerAnimationStart[arg.Name] or 0
				flag = true

				if tick() - n < 0.3 then
					flag2 = true
				end

				break
			end
		end
	end

	if not flag then
		return false
	end
	local magnitude2 = (humanoidRootPart2.Position - (MainModule.AutoDodge.PlayerLastPos[arg.Name] or humanoidRootPart2.Position)).Magnitude
	MainModule.AutoDodge.PlayerLastPos[arg.Name] = humanoidRootPart2.Position
	local flag3 = magnitude2 > 0.5
	local tbl4 = MainModule.AutoDodge.PlayerStates[arg.Name] or {}
	local flag4 = magnitude < (tbl4.lastDist or magnitude) - 0.5
	tbl4.lastDist = magnitude
	MainModule.AutoDodge.PlayerStates[arg.Name] = tbl4
	local str = arg.Name .. "_pred"
	local n = MainModule.AutoDodge.DodgePredictions[str] or 0
	if tick() - n < 0.5 then
		return false
	end
	flag3 = flag2 and (flag3 or flag4)
	local flag5 = false

	if flag3 then
		flag5 = true
	end

	if flag2 and magnitude2 > 3 then
		flag5 = true
	end

	if flag5 then
		MainModule.AutoDodge.DodgePredictions[str] = tick()
		return true
	end
	return false
end

MainModule.AutoDodge_processDodge = function()
	if not MainModule.AutoDodge.Enabled then
		return
	end
	local localPlayer2 = Players.LocalPlayer
	if not localPlayer2 or not localPlayer2.Character then
		return
	end
	local humanoidRootPart = localPlayer2.Character:FindFirstChild("HumanoidRootPart")
	if not humanoidRootPart then
		return
	end
	local players = Players:GetPlayers()

	for i = 1, #players do
		local v = players[i]

		if v ~= localPlayer2 then
			if v.Character then
				local humanoidRootPart2 = v.Character:FindFirstChild("HumanoidRootPart")

				if humanoidRootPart2 then
					if (humanoidRootPart2.Position - humanoidRootPart.Position).Magnitude > 8 then
						MainModule.AutoDodge.PlayerStates[v.Name] = nil
					else
						local humanoid = v.Character:FindFirstChild("Humanoid")

						if humanoid then
							local playingAnimationTracks = humanoid:GetPlayingAnimationTracks()
							local flag = false

							for _, playingAnimationTrack in pairs(playingAnimationTracks) do
								if playingAnimationTrack and playingAnimationTrack.Animation and playingAnimationTrack.IsPlaying then
									if MainModule.AutoDodge.AnimationIdsSet[playingAnimationTrack.Animation.AnimationId] then
										flag = true

										if not MainModule.AutoDodge.PlayerAnimationStart[v.Name] then
											MainModule.AutoDodge.PlayerAnimationStart[v.Name] = tick()
										end

										break
									end
								end
							end

							if not flag then
								MainModule.AutoDodge.PlayerAnimationStart[v.Name] = nil
							elseif MainModule.AutoDodge_predictAttack(v, localPlayer2) then
								local str = v.Name .. tostring(tick())

								if not MainModule.AutoDodge.ActiveAnimations[v.Name] then
									MainModule.AutoDodge.ActiveAnimations[v.Name] = {}
								end

								if not MainModule.AutoDodge.ActiveAnimations[v.Name][str] then
									MainModule.AutoDodge.ActiveAnimations[v.Name][str] = true

									if MainModule.AutoDodge_executeDodge() then
										task.spawn(function()
											task.wait(0.3)

											if MainModule.AutoDodge.ActiveAnimations[v.Name] then
												MainModule.AutoDodge.ActiveAnimations[v.Name][str] = nil
											end
										end)
									else
										MainModule.AutoDodge.ActiveAnimations[v.Name][str] = nil
									end
								end
							end
						end
					end
				end
			end
		end
	end
end

MainModule._AutoUseSaved = MainModule._AutoUseSaved or {}

MainModule.PushAutoUseTrue = function(arg)
	local str = tostring(arg or "default")

	pcall(function()
		local autoUse = localPlayer:FindFirstChild("AutoUse")

		if not autoUse then
			autoUse = Instance.new("BoolValue")
			autoUse.Name = "AutoUse"
			autoUse.Parent = localPlayer
		end

		if MainModule._AutoUseSaved[str] == nil then
			MainModule._AutoUseSaved[str] = autoUse.Value
		end

		autoUse.Value = true
	end)
end

MainModule.PopAutoUse = function(arg)
	local str = tostring(arg or "default")

	pcall(function()
		local autoUse = localPlayer:FindFirstChild("AutoUse")
		if not autoUse then
			return
		end
		local v = MainModule._AutoUseSaved[str]

		if v ~= nil then
			autoUse.Value = v
			MainModule._AutoUseSaved[str] = nil
		end
	end)
end

MainModule.toggle_auto_dodge = function(arg)
	local autoDodge = MainModule.ToggleRefs.AutoDodge

	if arg then
		if MainModule.can_enable_toggle and not MainModule.can_enable_toggle("HideAndSeek", "Auto Dodge", autoDodge) then
			return false
		end
	end

	for _, connection in pairs(MainModule.AutoDodge.Connections) do
		if connection then
			pcall(function()
				connection:Disconnect()
			end)
		end
	end

	if MainModule.AutoDodge.HeartbeatConnection then
		pcall(function()
			MainModule.AutoDodge.HeartbeatConnection:Disconnect()
		end)

		MainModule.AutoDodge.HeartbeatConnection = nil
	end

	MainModule.AutoDodge.Enabled = false
	MainModule.AutoDodge.Connections = {}
	MainModule.AutoDodge.ActiveAnimations = {}
	MainModule.AutoDodge.LastDodgeTime = 0
	MainModule.AutoDodge_destroyAllHitboxes()

	if arg then
		MainModule.PushAutoUseTrue("AutoDodge")
		MainModule.AutoDodge.Enabled = true
		MainModule.AutoDodge_setupAnimationTrackingWithHitboxes()

		MainModule.AutoDodge.HeartbeatConnection = RunService.Heartbeat:Connect(function()
			MainModule.AutoDodge_processDodge()
		end)

		table.insert(MainModule.AutoDodge.Connections, MainModule.AutoDodge.HeartbeatConnection)
	else
		MainModule.PopAutoUse("AutoDodge")
	end

	PlayToggleSound()
	return true
end

MainModule.AutoUltraInstinct = {
	Enabled = false,
	ViewOwnHitboxes = false,
	AnimationIds = {
		"rbxassetid://88451099342711",
		"rbxassetid://79649041083405",
		"rbxassetid://73242877658272",
		"rbxassetid://114928327045353",
		"rbxassetid://135690448001690",
		"rbxassetid://103355259844069",
		"rbxassetid://125906547773381",
		"rbxassetid://121147456137931",
		"rbxassetid://96924216250322",
		"rbxassetid://116839849594540",
		"rbxassetid://104041807075625",
		"rbxassetid://83057176809194",
		"rbxassetid://103318207627541",
		"rbxassetid://121473077508383",
		"rbxassetid://94215646393565",
		"rbxassetid://81533666958052",
		"rbxassetid://116839849594540",
		"rbxassetid://85793691404836",
		"rbxassetid://86197206792061",
		"rbxassetid://87978085217719",
		"rbxassetid://85623602463927",
		"rbxassetid://103062305177426",
		"rbxassetid://99157505926076",
		"rbxassetid://114769224376981",
		"rbxassetid://9783204720378",
		"rbxassetid://94443309383954",
		"rbxassetid://98785078701251",
		"rbxassetid://123072675259257",
		"rbxassetid://85743982894847",
		"rbxassetid://89439896387299",
		"rbxassetid://97863204720378",
		"rbxassetid://106756593687295",
		"rbxassetid://81816623746576",
		"rbxassetid://81392013026663",
		"rbxassetid://109822392402606",
		"rbxassetid://134675465964672",
		"rbxassetid://137659772694747",
		"rbxassetid://85756694343517",
		"rbxassetid://131235569946744",
		"rbxassetid://76323709902827",
		"rbxassetid://73150160715773",
	},
	Connections = {},
	AnimationIdsSet = {},
	DodgedHitboxes = {},
	LastDodgeTime = 0,
	MinDodgeInterval = 0.02,
	LastLookVectors = {},
	Active6663Hitbox = nil,
	IsDodging6663 = false,
	Dodge6663Count = 0,
	Max6663Dodges = 200,
	IsInside6663Hitbox = false,
	SpecialAnimations = { ["1123072675259257"] = true, ["99157505926076"] = true },
	SpecialAnimationData = {},
	SpecialDodgeRadius = 20,
	SpecialTrackRadius = 1500,
	IsInitialized = false,
}

for _, animationId in ipairs(MainModule.AutoUltraInstinct.AnimationIds) do
	MainModule.AutoUltraInstinct.AnimationIdsSet[animationId] = true
end

MainModule.AUI_cachedTool = nil
MainModule.AUI_lastToolCheck = 0

MainModule.AUI_findUltraTool = function()
	local now = tick()
	if MainModule.AUI_cachedTool and now - MainModule.AUI_lastToolCheck < 0.3 then
		return MainModule.AUI_cachedTool
	end
	local localPlayer2 = Players.LocalPlayer
	if not localPlayer2 then
		return nil
	end
	local character = localPlayer2.Character

	if character then
		for _, child in pairs(character:GetChildren()) do
			if child:IsA("Tool") and child.Name:lower():find("ultra") then
				MainModule.AUI_cachedTool = child
				MainModule.AUI_lastToolCheck = now
				return child
			end
		end
	end

	local backpack = localPlayer2:FindFirstChild("Backpack")

	if backpack then
		for _, child in pairs(backpack:GetChildren()) do
			if child:IsA("Tool") and child.Name:lower():find("ultra") then
				MainModule.AUI_cachedTool = child
				MainModule.AUI_lastToolCheck = now
				return child
			end
		end
	end

	MainModule.AUI_cachedTool = nil
	MainModule.AUI_lastToolCheck = now
	return nil
end

MainModule.AUI_pressUltraHotbar = function()
	local v = MainModule.AUI_findUltraTool()
	if not v then
		return false
	end
	local name = v.Name
	local localPlayer2 = Players.LocalPlayer
	if not localPlayer2 then
		return false
	end
	local hotbar = localPlayer2:FindFirstChild("PlayerGui") and localPlayer2.PlayerGui:FindFirstChild("Hotbar")
	if not hotbar then
		return false
	end
	local backpack = hotbar:FindFirstChild("Backpack")
	if not backpack then
		return false
	end
	local hotbar2 = backpack:FindFirstChild("Hotbar")
	if not hotbar2 then
		return false
	end
	local v2 = nil

	for _, child in pairs(hotbar2:GetChildren()) do
		local toolName = child:FindFirstChild("ToolName")
		if toolName and toolName.Text == name then
			v2 = child
			break
		end
	end

	if not v2 then
		return false
	end

	if not getconnections then
		return false
	end

	return (pcall(function()
		for _, v3 in pairs(getconnections(v2.MouseButton1Down)) do
			pcall(function()
				v3:Fire()
			end)
		end

		task.wait(0.05)

		for _, v3 in pairs(getconnections(v2.MouseButton1Up)) do
			pcall(function()
				v3:Fire()
			end)
		end
	end))
end

MainModule.AUI_isEnemyLookingAtUs = function(arg, arg2, arg3)
	local autoUltraInstinct = MainModule.AutoUltraInstinct
	local humanoidRootPart = arg:FindFirstChild("HumanoidRootPart")
	if not humanoidRootPart then
		return false, 0, false
	end
	local lookVector = humanoidRootPart.CFrame.LookVector
	local v = lookVector:Dot((arg2 - humanoidRootPart.Position).Unit)
	local v2 = autoUltraInstinct.LastLookVectors[arg3]
	local flag = false

	if v2 then
		if math.acos(math.clamp(lookVector:Dot(v2.vector), -1, 1)) > 0.25 then
			flag = true
		end
	end

	autoUltraInstinct.LastLookVectors[arg3] = { vector = lookVector, time = tick() }
	return v > 0.05 or flag, v, flag
end

MainModule.AUI_executeUltraNow = function(arg)
	local autoUltraInstinct = MainModule.AutoUltraInstinct
	if not autoUltraInstinct.Enabled then
		return false
	end
	local now = tick()
	local flag = arg and (string.find(arg, "6663") or autoUltraInstinct.Active6663Hitbox and arg == autoUltraInstinct.Active6663Hitbox.hitboxId .. "_touch")

	if flag then
		if not autoUltraInstinct.IsInside6663Hitbox then
			return false
		end

		if not autoUltraInstinct.Active6663Hitbox or not autoUltraInstinct.Active6663Hitbox.active then
			return false
		end

		if autoUltraInstinct.Max6663Dodges <= autoUltraInstinct.Dodge6663Count then
			return false
		end
	else
		if now - autoUltraInstinct.LastDodgeTime < autoUltraInstinct.MinDodgeInterval then
			return false
		end

		if autoUltraInstinct.DodgedHitboxes[arg] then
			return false
		end
		autoUltraInstinct.DodgedHitboxes[arg] = true
	end

	local v = MainModule.AUI_pressUltraHotbar()

	if v then
		if not flag then
			autoUltraInstinct.LastDodgeTime = now
		else
			autoUltraInstinct.Dodge6663Count = autoUltraInstinct.Dodge6663Count + 1
		end
	end

	if not flag then
		task.spawn(function()
			task.wait(1.5)
			autoUltraInstinct.DodgedHitboxes[arg] = nil
		end)
	end

	return v
end

MainModule.AUI_startLimitedDodgeFor6663 = function(active6663Hitbox)
	local autoUltraInstinct = MainModule.AutoUltraInstinct
	if autoUltraInstinct.IsDodging6663 then
		return
	end
	autoUltraInstinct.IsDodging6663 = true
	autoUltraInstinct.Active6663Hitbox = active6663Hitbox
	autoUltraInstinct.Dodge6663Count = 0
	autoUltraInstinct.IsInside6663Hitbox = true

	task.spawn(function()
		while true do
			if autoUltraInstinct.IsDodging6663 and active6663Hitbox and active6663Hitbox.active and autoUltraInstinct.Dodge6663Count < autoUltraInstinct.Max6663Dodges then
				if autoUltraInstinct.IsInside6663Hitbox then
					if not (not active6663Hitbox.active or not active6663Hitbox.frontHitbox or not active6663Hitbox.frontHitbox.Parent) then
						if not MainModule.AUI_executeUltraNow(active6663Hitbox.hitboxId .. "_touch", "6663 TOUCH DODGE") then
							task.wait(0.01)
						else
							task.wait(0.03)
						end

						continue
					end
				end
			end

			break
		end

		autoUltraInstinct.IsDodging6663 = false
		autoUltraInstinct.Active6663Hitbox = nil
		autoUltraInstinct.IsInside6663Hitbox = false
	end)
end

MainModule.AUI_setupHitboxUpdater = function(arg, arg2, arg3, arg4)
	if arg4 then
		return nil
	end
	local v = nil

	return (RunService.RenderStepped:Connect(function()
		if not MainModule.AutoUltraInstinct.Enabled then
			if v then
				v:Disconnect()
			end

			return
		end

		if not arg or not arg.Parent then
			if v then
				v:Disconnect()
			end

			return
		end

		if not arg2 or not arg2.Parent then
			if v then
				v:Disconnect()
			end

			return
		end

		arg.CFrame = arg2.CFrame * arg3
	end))
end

MainModule.AUI_getAnimationLength = function(arg)
	local ok, result = pcall(function()
		return arg.Length
	end)

	return ok and result or 1
end

MainModule.AUI_getForwardLength = function(arg, arg2)
	if arg2 then
		return 55
	end
	local n

	if arg:find("99157505926076") or arg:find("123072675259257") then
		n = 16
	else
		local pos = arg:find("73242877658272") or arg:find("79649041083405")
		n = 5

		if pos then
			n = 6.5
		end
	end

	return n
end

MainModule.AUI_setupSpecialAnimationTracking = function(arg, arg2, arg3)
	local autoUltraInstinct = MainModule.AutoUltraInstinct
	local match = arg2:match("(%d+)$") or arg2:match("/(%d+)$")
	if not match then
		return
	end

	if not autoUltraInstinct.SpecialAnimations[match] then
		return
	end
	local character = arg.Character
	if not character then
		return
	end
	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	if not humanoidRootPart then
		return
	end
	local localPlayer2 = Players.LocalPlayer
	if arg == localPlayer2 then
		return
	end
	local str = tostring(tick()) .. "_" .. tostring(arg.Name) .. "_special_" .. match
	local flag = true
	local flag2 = false
	local connection = nil

	autoUltraInstinct.SpecialAnimationData[str] = {
		active = true,
		character = character,
		humanoidRootPart = humanoidRootPart,
		player = arg,
		animId = match,
		hasDodged = false,
		startTime = tick(),
		isTracking = false,
	}

	connection = RunService.Heartbeat:Connect(function()
		if not autoUltraInstinct.Enabled then
			if connection then
				connection:Disconnect()
			end

			return
		end

		if not flag or flag2 then
			if connection then
				connection:Disconnect()
			end

			return
		end

		local character2 = localPlayer2.Character
		if not character2 then
			return
		end
		local humanoidRootPart2 = character2:FindFirstChild("HumanoidRootPart")
		if not humanoidRootPart2 then
			return
		end

		if not character or not character.Parent or not humanoidRootPart or not humanoidRootPart.Parent then
			flag = false

			if connection then
				connection:Disconnect()
			end

			return
		end

		if (humanoidRootPart.Position - humanoidRootPart2.Position).Magnitude <= autoUltraInstinct.SpecialDodgeRadius then
			if not flag2 then
				flag2 = true
				autoUltraInstinct.SpecialAnimationData[str].hasDodged = true

				if connection then
					connection:Disconnect()
				end

				MainModule.AUI_executeUltraNow(str .. "_special_dodge", "SPECIAL ANIMATION DODGE")
			end
		end
	end)

	task.spawn(function()
		while flag and arg3 and arg3.IsPlaying do
			task.wait(0.03)
		end

		flag = false

		if connection then
			connection:Disconnect()
		end

		autoUltraInstinct.SpecialAnimationData[str] = nil
	end)
end

MainModule.AUI_createHitbox = function(arg, arg2, arg3, arg4)
	local autoUltraInstinct = MainModule.AutoUltraInstinct
	if not autoUltraInstinct.Enabled then
		return nil
	end
	local localPlayer2 = Players.LocalPlayer
	local match = arg2:match("(%d+)$") or arg2:match("/(%d+)$")

	if match and autoUltraInstinct.SpecialAnimations[match] and arg4 ~= localPlayer2 then
		task.spawn(function()
			MainModule.AUI_setupSpecialAnimationTracking(arg4, arg2, arg3)
		end)

		return nil
	end

	if arg4 == localPlayer2 and not autoUltraInstinct.ViewOwnHitboxes then
		return nil
	end
	local flag = not arg
	if flag or not arg.Parent then
		return nil
	end
	local humanoidRootPart = arg:FindFirstChild("HumanoidRootPart")
	local flag2 = not humanoidRootPart
	if flag2 then
		return nil
	end
	local character = localPlayer2 and localPlayer2.Character
	local humanoidRootPart2 = character and character:FindFirstChild("HumanoidRootPart")
	local v = humanoidRootPart2 and humanoidRootPart
	local magnitude = nil

	if v then
		magnitude = (humanoidRootPart.Position - humanoidRootPart2.Position).Magnitude
	end

	task.wait(0.01)
	if flag or not arg.Parent then
		return nil
	end

	if flag2 or not humanoidRootPart.Parent then
		return nil
	end

	if not arg3 or not arg3.IsPlaying then
		return nil
	end
	local anchored = arg2:find("6663") ~= nil
	local str = tostring(tick()) .. "_" .. tostring(arg.Name) .. "_" .. string.sub(arg2, -8)
	local v2 = MainModule.AUI_getAnimationLength(arg3)
	local n

	if anchored then
		n = v2 + 3.1
	else
		n = math.max(0.1, v2 - 0.1)
	end

	local cFrame = nil
	local position = nil

	if anchored then
		position = humanoidRootPart.Position
		cFrame = humanoidRootPart.CFrame
	end

	local v3 = MainModule.AUI_getForwardLength(arg2, anchored)
	local part = Instance.new("Part")

	if anchored then
		part.Name = "GiantHitbox_6663_STATIC_" .. tick()
		part.Size = Vector3.new(55, 32.5, 55)
		part.Color = Color3.fromRGB(255, 0, 100)
		part.Transparency = 0.35
		part.Anchored = true
	else
		part.Name = "Hitbox_Front_" .. string.sub(arg2, -6) .. "_" .. tick()
		part.Size = Vector3.new(8, 6, v3)
		part.Color = Color3.fromRGB(255, 50, 50)
		part.Transparency = 0.35
		part.Anchored = false
	end

	part.CanCollide = false
	part.Material = Enum.Material.Neon
	local cframe = CFrame.new(0, 1.2, -(v3 / 2 + 1.5))

	if anchored then
		part.CFrame = cFrame * cframe
	else
		part.CFrame = humanoidRootPart.CFrame * cframe
	end

	local selectionBox = Instance.new("SelectionBox")
	selectionBox.Adornee = part
	selectionBox.Color3 = part.Color
	selectionBox.LineThickness = anchored and 0.35 or 0.12
	selectionBox.Transparency = 0.25
	selectionBox.Parent = part
	local particleEmitter = Instance.new("ParticleEmitter")
	particleEmitter.Texture = "rbxasset://textures/particles/sparkles_main.dds"
	particleEmitter.Color = ColorSequence.new(part.Color)
	particleEmitter.Size = NumberSequence.new(anchored and 4 or 0.4)
	particleEmitter.Rate = anchored and 200 or 20
	particleEmitter.Lifetime = NumberRange.new(anchored and 1.5 or 0.25)
	particleEmitter.SpreadAngle = Vector2.new(360, 360)
	particleEmitter.VelocityInheritance = 0
	particleEmitter.Speed = NumberRange.new(anchored and 10 or 1.5)
	particleEmitter.Parent = part

	local tbl4 = {
		active = true,
		character = arg,
		frontHitbox = part,
		backHitbox = nil,
		hitboxId = str,
		animationStartTime = tick(),
		hasDodged = false,
		animationTrack = arg3,
		startDistance = magnitude,
		hasEnteredRadius = false,
		characterName = arg.Name,
		turnWindowEndTime = tick() + 1.4,
		is6663 = anchored,
		staticPosition = position,
		staticCFrame = cFrame,
	}

	if anchored then
		local pointLight = Instance.new("PointLight")
		pointLight.Color = Color3.fromRGB(255, 0, 100)
		pointLight.Range = 60
		pointLight.Brightness = 4
		pointLight.Parent = part
		local attachment = Instance.new("Attachment")
		attachment.Parent = part
		local smoke = Instance.new("Smoke")
		smoke.Color = Color3.fromRGB(255, 0, 100)
		smoke.Opacity = 0.5
		smoke.RiseVelocity = 5
		smoke.Size = 12
		smoke.Parent = attachment
		local part2 = Instance.new("Part")
		part2.Name = "RotationEffect"
		part2.Size = Vector3.new(60, 2, 60)
		part2.Shape = Enum.PartType.Cylinder
		part2.Color = Color3.fromRGB(255, 0, 100)
		part2.Transparency = 0.7
		part2.Material = Enum.Material.Neon
		part2.Anchored = true
		part2.CanCollide = false
		part2.CFrame = cFrame
		part2.Parent = Workspace

		task.spawn(function()
			local now = tick()

			while tbl4.active and part2 and part2.Parent and autoUltraInstinct.Enabled do
				part2.CFrame = cFrame * CFrame.Angles(0, math.rad((tick() - now) * 180), 0)
				task.wait()
			end

			if part2 then
				pcall(function()
					part2:Destroy()
				end)
			end
		end)
	end

	part.Parent = Workspace
	local part2 = Instance.new("Part")
	part2.Name = "Hitbox_Back_" .. string.sub(arg2, -6) .. "_" .. tick()
	part2.Size = Vector3.new(0.8, 0.8, 0.8)
	part2.Color = Color3.fromRGB(255, 200, 100)
	part2.Transparency = 0.15
	part2.Material = Enum.Material.Neon
	part2.Anchored = anchored
	part2.CanCollide = false
	local cframe2 = CFrame.new(0, 0.3, 0.8)

	if anchored then
		part2.CFrame = cFrame * cframe2
	else
		part2.CFrame = humanoidRootPart.CFrame * cframe2
	end

	local selectionBox2 = Instance.new("SelectionBox")
	selectionBox2.Adornee = part2
	selectionBox2.Color3 = Color3.fromRGB(255, 200, 100)
	selectionBox2.LineThickness = 0.02
	selectionBox2.Transparency = 0.5
	selectionBox2.Parent = part2
	part2.Parent = Workspace
	tbl4.backHitbox = part2
	local v4 = MainModule.AUI_setupHitboxUpdater(part, humanoidRootPart, cframe, anchored)
	local v5 = MainModule.AUI_setupHitboxUpdater(part2, humanoidRootPart, cframe2, anchored)

	if arg4 == localPlayer2 then
		task.spawn(function()
			if anchored then
				while arg3 and arg3.IsPlaying do
					task.wait(0.03)
				end

				task.wait(3.1)
			elseif n > 0 and n < v2 then
				task.wait(n)
			else
				while arg3 and arg3.IsPlaying do
					task.wait(0.03)
				end
			end

			tbl4.active = false

			if anchored then
				autoUltraInstinct.IsDodging6663 = false
				autoUltraInstinct.Active6663Hitbox = nil
				autoUltraInstinct.IsInside6663Hitbox = false
			end

			if v4 then
				v4:Disconnect()
			end

			if v5 then
				v5:Disconnect()
			end

			if part and part.Parent then
				part:Destroy()
			end

			if part2 and part2.Parent then
				part2:Destroy()
			end
		end)

		return { part, part2 }
	end

	local connection = nil

	if not anchored then
		connection = RunService.RenderStepped:Connect(function()
			if not autoUltraInstinct.Enabled then
				if connection then
					connection:Disconnect()
				end

				return
			end

			if tbl4.hasDodged or not tbl4.active then
				if connection then
					connection:Disconnect()
				end

				return
			end

			if tbl4.turnWindowEndTime < tick() then
				if connection then
					connection:Disconnect()
				end

				return
			end

			if not humanoidRootPart2 or not humanoidRootPart2.Parent then
				return
			end

			if not arg or not arg.Parent then
				return
			end
			local humanoidRootPart3 = arg:FindFirstChild("HumanoidRootPart")
			if not humanoidRootPart3 then
				return
			end

			if tbl4.startDistance and tbl4.startDistance > 5.5 and (humanoidRootPart3.Position - humanoidRootPart2.Position).Magnitude <= 5.5 then
				if not tbl4.hasEnteredRadius then
					tbl4.hasEnteredRadius = true
				end

				local v6, v7, v8 = MainModule.AUI_isEnemyLookingAtUs(arg, humanoidRootPart2.Position, tbl4.characterName)

				if (v6 or v8) and tbl4.hasEnteredRadius and tbl4.active then
					tbl4.hasDodged = true

					if connection then
						connection:Disconnect()
					end

					MainModule.AUI_executeUltraNow(str .. "_turn", "")
				end
			end
		end)
	end

	local function fn21(arg5, arg6)
		if not autoUltraInstinct.Enabled then
			return
		end

		if not humanoidRootPart2 or not humanoidRootPart2.Parent then
			return
		end
		local flag3

		if arg5 == humanoidRootPart2 then
			flag3 = true
		else
			local flag4 = character and (arg5.Parent == character or arg5:IsDescendantOf(character))
			flag3 = false

			if flag4 then
				flag3 = true
			end
		end

		if flag3 then
			if anchored then
				if not tbl4.hasDodged and tbl4.active then
					tbl4.hasDodged = true
					autoUltraInstinct.IsInside6663Hitbox = true
					MainModule.AUI_startLimitedDodgeFor6663(tbl4)
				end
			elseif not tbl4.hasDodged then
				tbl4.hasDodged = true

				if connection then
					connection:Disconnect()
				end

				MainModule.AUI_executeUltraNow(arg6, "")
			end
		end
	end

	local function fn22(arg5)
		if not autoUltraInstinct.Enabled or not anchored or not tbl4.active then
			return
		end
		local flag3

		if arg5 == humanoidRootPart2 then
			flag3 = true
		else
			local flag4 = character and (arg5.Parent == character or arg5:IsDescendantOf(character))
			flag3 = false

			if flag4 then
				flag3 = true
			end
		end

		if flag3 then
			autoUltraInstinct.IsInside6663Hitbox = false
		end
	end

	local str2 = str .. "_front"
	local str3 = str .. "_back"

	local connection2 = part.Touched:Connect(function(hit)
		fn21(hit, str2)
	end)

	local connection3 = part2.Touched:Connect(function(hit)
		fn21(hit, str3)
	end)

	local connection4 = nil

	if anchored then
		connection4 = part.TouchEnded:Connect(function(hit)
			fn22(hit)
		end)
	end

	local function fn23()
		tbl4.active = false

		if anchored then
			autoUltraInstinct.IsDodging6663 = false
			autoUltraInstinct.Active6663Hitbox = nil
			autoUltraInstinct.IsInside6663Hitbox = false
		end

		if v4 then
			v4:Disconnect()
		end

		if v5 then
			v5:Disconnect()
		end

		if connection then
			connection:Disconnect()
		end

		if connection2 then
			connection2:Disconnect()
		end

		if connection3 then
			connection3:Disconnect()
		end

		if connection4 then
			connection4:Disconnect()
		end

		task.spawn(function()
			task.wait(2)
			autoUltraInstinct.LastLookVectors[tbl4.characterName] = nil
		end)

		task.spawn(function()
			task.wait(1.5)

			if not anchored then
				autoUltraInstinct.DodgedHitboxes[str2] = nil
				autoUltraInstinct.DodgedHitboxes[str3] = nil
				autoUltraInstinct.DodgedHitboxes[str .. "_turn"] = nil
			end
		end)

		if part and part.Parent then
			part:Destroy()
		end

		if part2 and part2.Parent then
			part2:Destroy()
		end
	end

	task.spawn(function()
		if anchored then
			while arg3 and arg3.IsPlaying do
				task.wait(0.03)
			end

			task.wait(3.1)
		elseif n > 0 and n < v2 then
			task.wait(n)
		else
			while arg3 and arg3.IsPlaying do
				task.wait(0.03)
			end
		end

		fn23()
	end)

	return { part, part2 }
end

MainModule.AUI_destroyAllHitboxes = function()
	for _, child in pairs(Workspace:GetChildren()) do
		if child:IsA("Part") and (child.Name:find("Hitbox") or child.Name:find("GiantHitbox") or child.Name:find("RotationEffect")) then
			pcall(function()
				child:Destroy()
			end)
		end
	end
end

MainModule.AUI_setupAnimationTracking = function()
	local autoUltraInstinct = MainModule.AutoUltraInstinct

	local function fn21(arg)
		if not arg then
			return
		end

		local function fn22(character)
			local humanoid = character:WaitForChild("Humanoid", 5)
			if not humanoid then
				return
			end

			local connection = humanoid.AnimationPlayed:Connect(function(arg2)
				if not autoUltraInstinct.Enabled then
					return
				end
				local animationId = arg2.Animation.AnimationId

				if autoUltraInstinct.AnimationIdsSet[animationId] then
					task.spawn(function()
						MainModule.AUI_createHitbox(arg.Character, animationId, arg2, arg)
					end)
				end
			end)

			table.insert(autoUltraInstinct.Connections, connection)
		end

		if arg.Character then
			fn22(arg.Character)
		end

		local connection = arg.CharacterAdded:Connect(fn22)
		table.insert(autoUltraInstinct.Connections, connection)
	end

	for _, player in pairs(Players:GetPlayers()) do
		task.spawn(function()
			fn21(player)
		end)
	end

	local connection = Players.PlayerAdded:Connect(function(player)
		fn21(player)
	end)

	table.insert(autoUltraInstinct.Connections, connection)
end

MainModule.toggle_auto_ultra_instinct = function(arg)
	local autoUltraInstinct = MainModule.AutoUltraInstinct
	local enabled = arg and true or false
	autoUltraInstinct.Enabled = enabled

	if enabled then
		MainModule.PushAutoUseTrue("AutoUltraInstinct")
		MainModule.AUI_destroyAllHitboxes()

		if not autoUltraInstinct.IsInitialized then
			MainModule.AUI_setupAnimationTracking()

			task.spawn(function()
				while true do
					task.wait(5)
					local now = tick()

					for k, lastLookVector in pairs(autoUltraInstinct.LastLookVectors) do
						if now - lastLookVector.time > 2 then
							autoUltraInstinct.LastLookVectors[k] = nil
						end
					end
				end
			end)

			task.spawn(function()
				while true do
					task.wait(10)
					local now = tick()

					for k, v in pairs(autoUltraInstinct.SpecialAnimationData) do
						if v.startTime and now - v.startTime > 10 then
							autoUltraInstinct.SpecialAnimationData[k] = nil
						end
					end
				end
			end)

			autoUltraInstinct.IsInitialized = true
		end
	else
		MainModule.AUI_destroyAllHitboxes()
		autoUltraInstinct.IsDodging6663 = false
		autoUltraInstinct.Active6663Hitbox = nil
		autoUltraInstinct.Dodge6663Count = 0
		autoUltraInstinct.IsInside6663Hitbox = false
		autoUltraInstinct.SpecialAnimationData = {}
		MainModule.PopAutoUse("AutoUltraInstinct")
	end

	PlayToggleSound()
	return true
end

MainModule.ThrowHelper = {
	Enabled = false,
	Connection = nil,
	LockedTarget = nil,
	IsLocked = false,
	CurrentTarget = nil,
	LastLookTarget = nil,
	CheckInterval = 0.5,
	LastCheckTime = 0,
	DotThreshold = 0.3,
}

MainModule.FaceTargetModule = MainModule.ThrowHelper

MainModule.AutoThrow = {
	Enabled = false,
	LastThrowTime = 0,
	ThrowCooldown = 0.3,
	KeybindConnection = nil,
	TempFaceTask = nil,
	MobileButton = nil,
	IsThrowing = false,
}

MainModule.ThrowHelper_isLookingAtPlayer = function(arg, arg2)
	if not arg or not arg.Character then
		return false
	end

	if not arg2 or not arg2.Character then
		return false
	end
	local head = arg.Character:FindFirstChild("Head")
	local head2 = arg2.Character:FindFirstChild("Head")
	local humanoidRootPart = arg2.Character:FindFirstChild("HumanoidRootPart")
	if not (head and head2 and humanoidRootPart) then
		return false
	end
	local unit = (head.Position - head2.Position).Unit
	local dotThreshold = MainModule.ThrowHelper.DotThreshold
	return unit:Dot(head2.CFrame.LookVector) > dotThreshold
end

MainModule.ThrowHelper_findClosestPlayer = function()
	local character = localPlayer.Character
	if not character then
		return nil
	end
	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	if not humanoidRootPart then
		return nil
	end
	local position = humanoidRootPart.Position
	local huge = math.huge
	local v = nil

	for _, player in ipairs(Players:GetPlayers()) do
		if player ~= localPlayer and player.Character then
			local humanoidRootPart2 = player.Character:FindFirstChild("HumanoidRootPart")

			if humanoidRootPart2 then
				local magnitude = (humanoidRootPart2.Position - position).Magnitude

				if magnitude < huge then
					huge = magnitude
					v = player
				end
			end
		end
	end

	return v
end

MainModule.ThrowHelper_findPlayerLookingAt = function()
	local character = localPlayer.Character
	if not character then
		return nil
	end
	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	if not humanoidRootPart then
		return nil
	end
	local position = humanoidRootPart.Position
	local huge = math.huge
	local v = nil

	for _, player in ipairs(Players:GetPlayers()) do
		if player ~= localPlayer and player.Character then
			if MainModule.ThrowHelper_isLookingAtPlayer(player, localPlayer) then
				local humanoidRootPart2 = player.Character:FindFirstChild("HumanoidRootPart")

				if humanoidRootPart2 then
					local magnitude = (humanoidRootPart2.Position - position).Magnitude

					if magnitude < huge then
						huge = magnitude
						v = player
					end
				end
			end
		end
	end

	if v then
		return v
	end
	return MainModule.ThrowHelper_findClosestPlayer()
end

MainModule.ThrowHelper_selectTarget = function()
	local v = MainModule.ThrowHelper_findPlayerLookingAt()

	if v then
		MainModule.ThrowHelper.LockedTarget = v
		MainModule.ThrowHelper.IsLocked = true
		return true
	end

	return false
end

MainModule.ThrowHelper_resetTarget = function()
	MainModule.ThrowHelper.LockedTarget = nil
	MainModule.ThrowHelper.IsLocked = false
	MainModule.ThrowHelper.CurrentTarget = nil
	MainModule.ThrowHelper.LastLookTarget = nil
end

MainModule.ThrowHelper_toggleFaceTarget = function(enabled, arg)
	if type(enabled) ~= "boolean" then
		enabled = not MainModule.ThrowHelper.Enabled
	end

	if MainModule.ThrowHelper.Connection then
		MainModule.ThrowHelper.Connection:Disconnect()
		MainModule.ThrowHelper.Connection = nil
	end

	MainModule.ThrowHelper.Enabled = enabled

	if enabled then
		if arg then
			MainModule.ThrowHelper_selectTarget()
		end

		MainModule.ThrowHelper.Connection = RunService.Heartbeat:Connect(function()
			if not MainModule.ThrowHelper.Enabled then
				return
			end
			local character = localPlayer.Character
			if not character then
				return
			end
			local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
			if not humanoidRootPart then
				return
			end

			if MainModule.ThrowHelper.IsLocked and MainModule.ThrowHelper.LockedTarget then
				if MainModule.ThrowHelper.LockedTarget.Character and MainModule.ThrowHelper.LockedTarget.Character:FindFirstChild("HumanoidRootPart") then
					local humanoidRootPart2 = MainModule.ThrowHelper.LockedTarget.Character:FindFirstChild("HumanoidRootPart")

					if humanoidRootPart2 then
						local cframe = CFrame.lookAt(humanoidRootPart.Position, humanoidRootPart2.Position)
						local n = cframe - cframe.Position
						humanoidRootPart.CFrame = CFrame.new(humanoidRootPart.Position) * n
					end
				else
					MainModule.ThrowHelper_resetTarget()
					MainModule.ThrowHelper_selectTarget()
				end
			else
				local now = tick()

				if MainModule.ThrowHelper.CheckInterval <= now - MainModule.ThrowHelper.LastCheckTime then
					MainModule.ThrowHelper.LastCheckTime = now
					local v = MainModule.ThrowHelper_findPlayerLookingAt()

					if v then
						MainModule.ThrowHelper.LastLookTarget = v
						MainModule.ThrowHelper.CurrentTarget = v
					elseif MainModule.ThrowHelper.LastLookTarget and MainModule.ThrowHelper.LastLookTarget.Character then
						MainModule.ThrowHelper.CurrentTarget = MainModule.ThrowHelper.LastLookTarget
					else
						local v2 = MainModule.ThrowHelper_findClosestPlayer()
						MainModule.ThrowHelper.CurrentTarget = v2
						MainModule.ThrowHelper.LastLookTarget = v2
					end
				end

				MainModule.ThrowHelper.CurrentTarget = MainModule.ThrowHelper.LastLookTarget

				if MainModule.ThrowHelper.CurrentTarget and MainModule.ThrowHelper.CurrentTarget.Character then
					local humanoidRootPart2 = MainModule.ThrowHelper.CurrentTarget.Character:FindFirstChild("HumanoidRootPart")

					if humanoidRootPart2 then
						local cframe = CFrame.lookAt(humanoidRootPart.Position, humanoidRootPart2.Position)
						local n = cframe - cframe.Position
						humanoidRootPart.CFrame = CFrame.new(humanoidRootPart.Position) * n
					end
				end
			end
		end)
	else
		MainModule.ThrowHelper_resetTarget()
	end
end

MainModule.AutoThrow_findThrowTool = function()
	if localPlayer.Backpack then
		for _, child in pairs(localPlayer.Backpack:GetChildren()) do
			if child:IsA("Tool") and string.find(child.Name, "Throw") then
				return child
			end
		end
	end

	if localPlayer.Character then
		for _, child in pairs(localPlayer.Character:GetChildren()) do
			if child:IsA("Tool") and string.find(child.Name, "Throw") then
				return child
			end
		end
	end

	return nil
end

MainModule.AutoThrow_executeThrow = function()
	if not MainModule.AutoThrow.Enabled then
		return false
	end
	local now = tick()
	if now - MainModule.AutoThrow.LastThrowTime < MainModule.AutoThrow.ThrowCooldown then
		return false
	end
	local v = MainModule.AutoThrow_findThrowTool()
	if not v then
		return false
	end
	local hotbar = localPlayer.PlayerGui:FindFirstChild("Hotbar")
	if not hotbar then
		return false
	end
	local backpack = hotbar:FindFirstChild("Backpack")
	if not backpack then
		return false
	end
	local hotbar2 = backpack:FindFirstChild("Hotbar")
	if not hotbar2 then
		return false
	end
	local v2 = nil

	for _, child in pairs(hotbar2:GetChildren()) do
		if child:FindFirstChild("ToolName") and child.ToolName.Text == v.Name then
			v2 = child
			break
		end
	end

	if not v2 then
		return false
	end
	MainModule.AutoThrow.LastThrowTime = now

	if not MainModule.ThrowHelper.Enabled then
		MainModule.ThrowHelper_toggleFaceTarget(true, true)
	elseif not MainModule.ThrowHelper.IsLocked then
		MainModule.ThrowHelper_selectTarget()
	end

	local ok = pcall(function()
		for _, v3 in pairs(getconnections(v2.MouseButton1Down)) do
			v3:Fire()
		end

		task.wait(0.05)

		for _, v3 in pairs(getconnections(v2.MouseButton1Up)) do
			v3:Fire()
		end
	end)

	if ok then
		if MainModule.AutoThrow.TempFaceTask then
			task.cancel(MainModule.AutoThrow.TempFaceTask)
		end

		MainModule.AutoThrow.TempFaceTask = task.delay(1, function()
			if MainModule.ThrowHelper.Enabled and MainModule.ThrowHelper.IsLocked then
				MainModule.ThrowHelper_resetTarget()

				task.delay(0.5, function()
					if MainModule.ThrowHelper.Enabled then
						MainModule.ThrowHelper_toggleFaceTarget(false)
					end
				end)
			end

			MainModule.AutoThrow.TempFaceTask = nil
		end)
	end

	return ok
end

MainModule.AutoThrow_createMobileButton = function()
	if MainModule.AutoThrow.MobileButton then
		return
	end
	local playerGui = localPlayer:FindFirstChild("PlayerGui")
	if not playerGui then
		return
	end
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "HSX_AutoThrowMobile"
	screenGui.ResetOnSpawn = false
	screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	screenGui.Parent = playerGui
	local textButton = Instance.new("TextButton")
	textButton.Name = "ThrowBtn"
	textButton.Size = UDim2.fromOffset(100, 100)
	textButton.Position = UDim2.new(1, -120, 1, -220)
	textButton.AnchorPoint = Vector2.new(0, 0)
	textButton.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
	textButton.BackgroundTransparency = 0.15
	textButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	textButton.Text = "THROW"
	textButton.Font = Enum.Font.GothamBold
	textButton.TextSize = 18
	textButton.AutoButtonColor = true
	textButton.Parent = screenGui
	local uiCorner = Instance.new("UICorner")
	uiCorner.CornerRadius = UDim.new(1, 0)
	uiCorner.Parent = textButton
	local uiStroke = Instance.new("UIStroke")
	uiStroke.Color = Color3.fromRGB(255, 255, 255)
	uiStroke.Thickness = 1.5
	uiStroke.Transparency = 0.5
	uiStroke.Parent = textButton

	textButton.MouseButton1Click:Connect(function()
		MainModule.AutoThrow_executeThrow()
	end)

	textButton.TouchTap:Connect(function()
		MainModule.AutoThrow_executeThrow()
	end)

	MainModule.AutoThrow.MobileButton = screenGui
end

MainModule.AutoThrow_destroyMobileButton = function()
	if MainModule.AutoThrow.MobileButton then
		pcall(function()
			MainModule.AutoThrow.MobileButton:Destroy()
		end)

		MainModule.AutoThrow.MobileButton = nil
	end
end

MainModule.toggle_auto_throw = function(arg)
	MainModule.AutoThrow.Enabled = arg and true or false

	if MainModule.AutoThrow.KeybindConnection then
		MainModule.AutoThrow.KeybindConnection:Disconnect()
		MainModule.AutoThrow.KeybindConnection = nil
	end

	MainModule.AutoThrow_destroyMobileButton()

	if arg then
		pcall(function()
			MainModule.PushAutoUseTrue("AutoThrow")
		end)

		MainModule.AutoThrow.KeybindConnection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
			if gameProcessed then
				return
			end

			if input.KeyCode == Enum.KeyCode.F then
				MainModule.AutoThrow_executeThrow()
			end
		end)

		MainModule.AutoThrow_createMobileButton()
	else
		MainModule.ThrowHelper_resetTarget()

		if MainModule.ThrowHelper.Connection then
			MainModule.ThrowHelper.Connection:Disconnect()
			MainModule.ThrowHelper.Connection = nil
		end

		MainModule.ThrowHelper.Enabled = false

		pcall(function()
			MainModule.PopAutoUse("AutoThrow")
		end)
	end

	PlayToggleSound()
	return true
end

MainModule.Fly = { Enabled = false, Speed = 900, Connection = nil, BodyVelocity = nil }

MainModule.toggle_fly = function(arg, arg2)
	if arg then
		if MainModule.Fly.Enabled then
			return
		end
		MainModule.Fly.Enabled = true
		local v = MainModule.get_character()
		if not v then
			return
		end
		local v2 = MainModule.get_humanoid(v)
		local v3 = MainModule.get_root_part(v)
		if not (v2 and v3) then
			return
		end
		v2.UseJumpPower = false
		v2.AutoRotate = false
		v2.PlatformStand = true

		if MainModule.Fly.BodyVelocity then
			MainModule.Fly.BodyVelocity:Destroy()
		end

		local bodyVelocity = Instance.new("BodyVelocity")
		bodyVelocity.Name = "FlyBodyVelocity"
		bodyVelocity.MaxForce = Vector3.new(40000, 40000, 40000)
		bodyVelocity.Parent = v3
		MainModule.Fly.BodyVelocity = bodyVelocity

		MainModule.Fly.Connection = RunService.Heartbeat:Connect(function()
			if not MainModule.Fly.Enabled or not v or not v.Parent then
				MainModule.toggle_fly(false, true)
				return
			end
			v3 = MainModule.get_root_part(v)
			v2 = MainModule.get_humanoid(v)
			if not v3 or not bodyVelocity or not v2 then
				MainModule.toggle_fly(false, true)
				return
			end
			local currentCamera = workspace.CurrentCamera
			if not currentCamera then
				return
			end
			local cFrame = currentCamera.CFrame
			local lookVector = cFrame.LookVector
			local rightVector = cFrame.RightVector
			local upVector = cFrame.UpVector
			local vector = Vector3.zero
			local flag = false

			if UserInputService:IsKeyDown(Enum.KeyCode.W) then
				vector = Vector3.zero + lookVector
				flag = true
			end

			if UserInputService:IsKeyDown(Enum.KeyCode.S) then
				vector -= lookVector
				flag = true
			end

			if UserInputService:IsKeyDown(Enum.KeyCode.A) then
				vector -= rightVector
				flag = true
			end

			if UserInputService:IsKeyDown(Enum.KeyCode.D) then
				vector += rightVector
				flag = true
			end

			if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
				vector += upVector
				flag = true
			end

			if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
				vector -= upVector
				flag = true
			end

			if not flag then
				local moveDirection = v2.MoveDirection

				if moveDirection.Magnitude > 0.1 then
					vector = lookVector * moveDirection.Z + rightVector * moveDirection.X + upVector * moveDirection.Y
					flag = true
				end
			end

			if flag and vector.Magnitude > 0 then
				bodyVelocity.Velocity = vector.Unit * MainModule.Fly.Speed
			else
				bodyVelocity.Velocity = Vector3.zero
			end
		end)
	else
		if not MainModule.Fly.Enabled then
			return
		end
		MainModule.Fly.Enabled = false

		if MainModule.Fly.Connection then
			MainModule.Fly.Connection:Disconnect()
			MainModule.Fly.Connection = nil
		end

		if MainModule.Fly.BodyVelocity then
			MainModule.Fly.BodyVelocity:Destroy()
			MainModule.Fly.BodyVelocity = nil
		end

		local v = MainModule.get_character()

		if v then
			local v2 = MainModule.get_root_part(v)

			if v2 then
				v2.AssemblyLinearVelocity = Vector3.zero
			end

			local v3 = MainModule.get_humanoid(v)

			if v3 then
				v3.UseJumpPower = true
				v3.AutoRotate = true
				v3.PlatformStand = false
			end
		end
	end

	if not arg2 then
		PlayToggleSound()
	end
end

MainModule.set_fly_speed = function(speed)
	MainModule.Fly.Speed = speed
end

MainModule.harmfulEffectsList = {
	"RagdollStun",
	"Stun",
	"Stunned",
	"StunEffect",
	"StunHit",
	"Knockback",
	"Knockdown",
	"Knockout",
	"Dazed",
	"Paralyzed",
	"Freeze",
	"Frozen",
	"Sleep",
	"Slow",
	"Slowed",
	"Root",
	"Rooted",
	"Crawling",
	"Crawled",
}

MainModule.RemoveStunEnabled = false

MainModule.toggle_remove_stun = function(removeStunEnabled)
	MainModule.RemoveStunEnabled = removeStunEnabled

	if removeStunEnabled then
		local function fn21()
			local v = MainModule.get_character()
			if not v then
				return
			end

			for _, v2 in ipairs(MainModule.harmfulEffectsList) do
				local v3 = v:FindFirstChild(v2)

				if v3 then
					pcall(function()
						v3:Destroy()
					end)
				end
			end

			local v2 = MainModule.get_humanoid(v)

			if v2 and v2:GetAttribute("Stunned") then
				v2:SetAttribute("Stunned", false)
			end
		end

		fn21()

		RunService.Heartbeat:Connect(function()
			if MainModule.RemoveStunEnabled then
				fn21()
			end
		end)
	end

	PlayToggleSound()
end

MainModule.SpeedHackEnabled = false
MainModule.SpeedValue = 39
MainModule.SpeedHackLoop = nil

MainModule.toggle_speed_hack = function(speedHackEnabled)
	MainModule.SpeedHackEnabled = speedHackEnabled

	if speedHackEnabled then
		if MainModule.SpeedHackLoop then
			task.cancel(MainModule.SpeedHackLoop)
		end

		MainModule.SpeedHackLoop = task.spawn(function()
			while MainModule.SpeedHackEnabled do
				local v = MainModule.get_character()

				if v then
					local v2 = MainModule.get_humanoid(v)

					if v2 and v2.Health > 0 then
						v2.WalkSpeed = MainModule.SpeedValue
					end
				end

				task.wait(0.1)
			end
		end)
	else
		if MainModule.SpeedHackLoop then
			task.cancel(MainModule.SpeedHackLoop)
			MainModule.SpeedHackLoop = nil
		end

		local v = MainModule.get_character()

		if v then
			local v2 = MainModule.get_humanoid(v)

			if v2 then
				v2.WalkSpeed = 16
			end
		end
	end

	PlayToggleSound()
end

MainModule.set_speed_value = function(arg)
	MainModule.SpeedValue = math.min(arg, 50)

	if MainModule.SpeedHackEnabled then
		local v = MainModule.get_character()

		if v then
			local v2 = MainModule.get_humanoid(v)

			if v2 and v2.Health > 0 then
				v2.WalkSpeed = MainModule.SpeedValue
			end
		end
	end
end

MainModule.FOVEnabled = false
MainModule.FOVValue = 120
MainModule.FOVConnection = nil

MainModule.toggle_fov = function(fovEnabled)
	if type(fovEnabled) ~= "boolean" then
		fovEnabled = not MainModule.FOVEnabled
	end

	MainModule.FOVEnabled = fovEnabled
	local currentCamera = workspace.CurrentCamera

	if fovEnabled then
		currentCamera.FieldOfView = MainModule.FOVValue

		if MainModule.FOVConnection then
			MainModule.FOVConnection:Disconnect()
		end

		MainModule.FOVConnection = currentCamera:GetPropertyChangedSignal("FieldOfView"):Connect(function()
			if MainModule.FOVEnabled and currentCamera.FieldOfView ~= MainModule.FOVValue then
				currentCamera.FieldOfView = MainModule.FOVValue
			end
		end)
	else
		if MainModule.FOVConnection then
			MainModule.FOVConnection:Disconnect()
			MainModule.FOVConnection = nil
		end

		currentCamera.FieldOfView = 70
	end

	PlayToggleSound()
end

MainModule.set_fov = function(arg)
	MainModule.FOVValue = math.min(arg, 120)

	if MainModule.FOVEnabled then
		workspace.CurrentCamera.FieldOfView = MainModule.FOVValue
	end
end

MainModule.AutoQTEMode = "Legit"
MainModule.AutoQTEEnabled = false

MainModule.toggle_auto_qte = function(autoQTEEnabled)
	local autoQTE = MainModule.ToggleRefs.AutoQTE

	if autoQTEEnabled then
		if MainModule.is_xeno_executor() then
			MainModule.notify("Auto QTE", "Not supported in your executor", 0.9)
			PlayErrorSound()

			if autoQTE and autoQTE.SetValue then
				pcall(function()
					autoQTE:SetValue(false)
				end)
			end

			return false
		end
	end

	MainModule.AutoQTEEnabled = autoQTEEnabled

	if autoQTEEnabled then
		local impactFrames = localPlayer.PlayerGui:FindFirstChild("ImpactFrames")

		if impactFrames then
			local tbl4 = {}

			impactFrames.ChildAdded:Connect(function(child)
				if child.Name ~= "OuterRingTemplate" or tbl4[child] then
					return
				end
				tbl4[child] = true

				task.defer(function()
					local v = nil

					for _, child2 in pairs(impactFrames:GetChildren()) do
						if child2.Name == "InnerTemplate" and child2.Position == child.Position and not child2:GetAttribute("Failed") then
							v = child2
							break
						end
					end

					if not v or v:GetAttribute("Tweening") or v:GetAttribute("Failed") then
						return
					end
					local HBGQTE = require(ReplicatedStorage.Modules.HBGQTE)

					if MainModule.AutoQTEMode == "Legit" then
						pcall(function()
							HBGQTE.Pressed(false, { Inner = v, Outer = child, Duration = 2, StartedAt = tick(), Data = {} })
						end)
					else
						pcall(function()
							HBGQTE.Pressed(true, { Inner = v, Outer = child, Duration = 0.1, StartedAt = tick(), Data = {} })
						end)
					end
				end)
			end)
		end
	end

	PlayToggleSound()
	return true
end

MainModule.set_auto_qte_mode = function(autoQTEMode)
	MainModule.AutoQTEMode = autoQTEMode
end

MainModule.teleport_up = function()
	local v = MainModule.get_character()

	if v then
		local v2 = MainModule.get_root_part(v)

		if v2 then
			v2.CFrame = v2.CFrame + Vector3.new(0, 100, 0)
			MainModule.notify("Teleport", "Up 100", 0.9)
		end
	end

	PlayBell()
end

MainModule.teleport_down = function()
	local v = MainModule.get_character()

	if v then
		local v2 = MainModule.get_root_part(v)

		if v2 then
			v2.CFrame = v2.CFrame + Vector3.new(0, -40, 0)
			MainModule.notify("Teleport", "Down 40", 0.9)
		end
	end

	PlayBell()
end

MainModule.GamePassStates = {
	PermanentGuard = false,
	GlassVision = false,
	EmotePages = false,
	CustomPlayerTag = false,
	PrivateServerPlus = false,
	FreeVIP = false,
	Lighter = false,
}

MainModule.toggle_permanent_guard = function(permanentGuard)
	MainModule.GamePassStates.PermanentGuard = permanentGuard
	localPlayer:SetAttribute("__OwnsPermGuard", permanentGuard)
	PlayToggleSound()
end

MainModule.toggle_glass_vision = function(arg)
	MainModule.GamePassStates = MainModule.GamePassStates or {}
	MainModule.GamePassStates.GlassVision = arg and true or false
	MainModule.GlassVisionEnabled = arg and true or false
	localPlayer:SetAttribute("__OwnsGlassManufacturerVision", arg and true or false)
	PlayToggleSound()
end

MainModule.toggle_emote_pages = function(emotePages)
	MainModule.GamePassStates.EmotePages = emotePages
	localPlayer:SetAttribute("__OwnsEmotePages", emotePages)
	PlayToggleSound()
end

MainModule.toggle_custom_player_tag = function(customPlayerTag)
	MainModule.GamePassStates.CustomPlayerTag = customPlayerTag
	localPlayer:SetAttribute("__OwnsCustomPlayerTag", customPlayerTag)
	PlayToggleSound()
end

MainModule.toggle_private_server_plus = function(privateServerPlus)
	MainModule.GamePassStates.PrivateServerPlus = privateServerPlus
	localPlayer:SetAttribute("__OwnsPSPlus", privateServerPlus)
	PlayToggleSound()
end

MainModule.unlock_vip = function()
	localPlayer:SetAttribute("__OwnsVIPGamepass", true)
	localPlayer:SetAttribute("__Owns2xVote", true)

	pcall(function()
		MainModule.GamePassStates.FreeVIP = true
	end)

	PlayBell()
	fn("VIP", "Unlocked", 0.9)
end

MainModule.toggle_lighter = function(arg)
	MainModule.GamePassStates = MainModule.GamePassStates or {}
	MainModule.GamePassStates.Lighter = arg and true or false
	MainModule.LighterEnabled = arg and true or false
	localPlayer:SetAttribute("HasLighter", arg and true or false)
	PlayToggleSound()
end

MainModule.LegitHitboxEnabled = false
MainModule.LegitHitboxConn = nil
MainModule.LegitHitboxParts = {}
MainModule.legit_hitbox_enabled = false
MainModule.legit_hitbox_conn = nil
MainModule.legit_hitbox_parts = {}

MainModule.toggle_legit_hitbox = function(arg)
	MainModule.legit_hitbox_enabled = arg and true or false

	if MainModule.legit_hitbox_conn then
		pcall(function()
			MainModule.legit_hitbox_conn:Disconnect()
		end)

		MainModule.legit_hitbox_conn = nil
	end

	for k, legitHitboxPart in pairs(MainModule.legit_hitbox_parts) do
		if k and k.Parent then
			pcall(function()
				k.Size = legitHitboxPart.Size
				k.CanCollide = legitHitboxPart.CanCollide
				k.Transparency = legitHitboxPart.Transparency
			end)
		end
	end

	MainModule.legit_hitbox_parts = {}
	if not arg then
		PlayToggleSound()
		return true
	end

	MainModule.legit_hitbox_conn = RunService.Heartbeat:Connect(function()
		if not MainModule.legit_hitbox_enabled then
			return
		end
		local character = localPlayer.Character
		local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
		if not humanoidRootPart then
			return
		end
		local raycastParams = RaycastParams.new()
		raycastParams.FilterType = Enum.RaycastFilterType.Exclude
		raycastParams.FilterDescendantsInstances = { character }

		for _, player in pairs(Players:GetPlayers()) do
			if player ~= localPlayer and player.Character then
				local humanoidRootPart2 = player.Character:FindFirstChild("HumanoidRootPart")

				if humanoidRootPart2 then
					local n = humanoidRootPart2.Position - humanoidRootPart.Position
					local magnitude = n.Magnitude

					if magnitude < 0.1 then
						magnitude = 0.1
					end

					local hit = workspace:Raycast(humanoidRootPart.Position, n.Unit * math.min(magnitude, 400), raycastParams)

					if not hit or hit.Instance and hit.Instance:IsDescendantOf(player.Character) then
						if not MainModule.legit_hitbox_parts[humanoidRootPart2] then
							MainModule.legit_hitbox_parts[humanoidRootPart2] = {
								Size = humanoidRootPart2.Size,
								CanCollide = humanoidRootPart2.CanCollide,
								Transparency = humanoidRootPart2.Transparency,
							}

							humanoidRootPart2.Size = Vector3.new(8, 8, 8)
							humanoidRootPart2.CanCollide = false
							humanoidRootPart2.Transparency = 0.45
						end
					else
						local v = MainModule.legit_hitbox_parts[humanoidRootPart2]

						if v then
							humanoidRootPart2.Size = v.Size
							humanoidRootPart2.Transparency = v.Transparency
							humanoidRootPart2.CanCollide = v.CanCollide
							MainModule.legit_hitbox_parts[humanoidRootPart2] = nil
						end
					end
				end
			end
		end
	end)

	PlayToggleSound()
	return true
end

MainModule.InfiniteAmmoEnabled = false
MainModule.OriginalAmmo = {}

MainModule.toggle_infinite_ammo = function(infiniteAmmoEnabled)
	MainModule.InfiniteAmmoEnabled = infiniteAmmoEnabled

	if infiniteAmmoEnabled then
		RunService.Heartbeat:Connect(function()
			if not MainModule.InfiniteAmmoEnabled then
				return
			end

			pcall(function()
				local v = MainModule.get_character()

				if v then
					for _, child in pairs(v:GetChildren()) do
						if child:IsA("Tool") then
							for _, descendant in pairs(child:GetDescendants()) do
								if (descendant:IsA("NumberValue") or descendant:IsA("IntValue")) and (descendant.Name:lower():find("ammo") or descendant.Name:lower():find("bullet")) then
									if not MainModule.OriginalAmmo[descendant] then
										MainModule.OriginalAmmo[descendant] = descendant.Value
									end

									descendant.Value = math.huge
								end
							end
						end
					end
				end

				local backpack = localPlayer:FindFirstChild("Backpack")

				if backpack then
					for _, child in pairs(backpack:GetChildren()) do
						if child:IsA("Tool") then
							for _, descendant in pairs(child:GetDescendants()) do
								if (descendant:IsA("NumberValue") or descendant:IsA("IntValue")) and (descendant.Name:lower():find("ammo") or descendant.Name:lower():find("bullet")) then
									if not MainModule.OriginalAmmo[descendant] then
										MainModule.OriginalAmmo[descendant] = descendant.Value
									end

									descendant.Value = math.huge
								end
							end
						end
					end
				end
			end)
		end)
	else
		for k, v in pairs(MainModule.OriginalAmmo) do
			if k and k.Parent then
				k.Value = v
			end
		end

		MainModule.OriginalAmmo = {}
	end

	PlayToggleSound()
end

MainModule.set_custom_player_tag = function(arg)
	local num = tonumber(arg)

	if num and num >= 0 and num <= 999 then
		local text = string.format("%03d", num)
		local live = workspace:FindFirstChild("Live")

		if live then
			local v = live:FindFirstChild(localPlayer.Name)

			if v then
				local playerTags = v:FindFirstChild("PlayerTags")

				if playerTags then
					local back = playerTags:FindFirstChild("Back")
					local front = playerTags:FindFirstChild("Front")
					local textLabel = nil

					if back then
						local surfaceGui = back:FindFirstChild("SurfaceGui")
						textLabel = nil

						if surfaceGui then
							textLabel = surfaceGui:FindFirstChild("TextLabel")
						end
					end

					local textLabel2 = nil

					if front then
						local surfaceGui = front:FindFirstChild("SurfaceGui")
						textLabel2 = nil

						if surfaceGui then
							textLabel2 = surfaceGui:FindFirstChild("TextLabel")
						end
					end

					if textLabel and textLabel2 then
						textLabel.Text = text
						textLabel2.Text = text
					end
				end
			end
		end
	end

	PlayBell()
end

MainModule.CustomPlayerTagEnabled = false
MainModule.CustomPlayerTagValue = "067"
MainModule.CustomPlayerTagConnection = nil

local function fn21(arg)
	local num = tonumber(arg)
	if num and num >= 0 and num <= 999 then
		return string.format("%03d", num)
	end
	return "000"
end

MainModule.toggle_custom_player_tag = function(customPlayerTagEnabled)
	MainModule.CustomPlayerTagEnabled = customPlayerTagEnabled

	if MainModule.CustomPlayerTagConnection then
		MainModule.CustomPlayerTagConnection:Disconnect()
		MainModule.CustomPlayerTagConnection = nil
	end

	if customPlayerTagEnabled then
		MainModule.set_custom_player_tag(MainModule.CustomPlayerTagValue)

		MainModule.CustomPlayerTagConnection = RunService.Heartbeat:Connect(function()
			if MainModule.CustomPlayerTagEnabled then
				local live = workspace:FindFirstChild("Live")

				if live then
					local v = live:FindFirstChild(localPlayer.Name)

					if v then
						local playerTags = v:FindFirstChild("PlayerTags")

						if playerTags then
							local back = playerTags:FindFirstChild("Back")
							local front = playerTags:FindFirstChild("Front")
							local textLabel = nil

							if back then
								local surfaceGui = back:FindFirstChild("SurfaceGui")
								textLabel = nil

								if surfaceGui then
									textLabel = surfaceGui:FindFirstChild("TextLabel")
								end
							end

							local textLabel2 = nil

							if front then
								local surfaceGui = front:FindFirstChild("SurfaceGui")
								textLabel2 = nil

								if surfaceGui then
									textLabel2 = surfaceGui:FindFirstChild("TextLabel")
								end
							end

							if textLabel and textLabel2 then
								local v2 = fn21(MainModule.CustomPlayerTagValue)

								if textLabel.Text ~= v2 then
									textLabel.Text = v2
								end

								if textLabel2.Text ~= v2 then
									textLabel2.Text = v2
								end
							end
						end
					end
				end
			end
		end)
	else
		MainModule.set_custom_player_tag(0)
	end

	PlayToggleSound()
end

MainModule.set_custom_tag_value = function(arg)
	local v = fn21(arg)
	MainModule.CustomPlayerTagValue = v

	if MainModule.CustomPlayerTagEnabled then
		MainModule.set_custom_player_tag(tonumber(v))
	end
end

MainModule.AutoNextEnabled = false
MainModule.AutoNextConn = nil
MainModule.TargetPos = Vector3.new(-214.3, 186.86, 242.64)
MainModule.Radius = 80

MainModule.toggle_auto_next_game = function(autoNextEnabled)
	MainModule.AutoNextEnabled = autoNextEnabled

	if MainModule.AutoNextConn then
		MainModule.AutoNextConn:Disconnect()
		MainModule.AutoNextConn = nil
	end

	if autoNextEnabled then
		local n = 0

		MainModule.AutoNextConn = RunService.Heartbeat:Connect(function(deltaTime)
			if not MainModule.AutoNextEnabled then
				return
			end
			local character = localPlayer.Character
			local position = character and character.PrimaryPart and character.PrimaryPart.Position

			if position and (position - MainModule.TargetPos).Magnitude <= MainModule.Radius then
				n += deltaTime

				if n >= 3.4 then
					n = 0

					pcall(function()
						game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("TemporaryReachedBindable"):FireServer()
					end)
				end
			else
				n = 0
			end
		end)
	end

	PlayToggleSound()
end

local flag = false
local tbl4 = { "DashRequest" }

ToggleFreeDash = function(freeDashEnabled)
	flag = freeDashEnabled
	MainModule.FreeDashEnabled = freeDashEnabled

	if freeDashEnabled then
		local boosts = localPlayer:FindFirstChild("Boosts")
		local fasterSprint = boosts and boosts:FindFirstChild("Faster Sprint")

		if not fasterSprint then
			MainModule.notify("Free Dash", "You don't have Faster Sprint boost!", 0.9)
			PlayErrorSound()
			return false
		end

		local value = fasterSprint.Value

		if value ~= 5 then
			MainModule.notify("Free Dash", "Your Faster Sprint level is " .. value .. ", need level 5!", 0.9)
			PlayErrorSound()
			return false
		end

		pcall(function()
			local remotes = ReplicatedStorage:FindFirstChild("Remotes")

			if remotes and setrawmetatable then
				for _, v in ipairs(tbl4) do
					local v2 = remotes:FindFirstChild(v)

					if v2 then
						setrawmetatable(v2, { __index = function()
							return function()
							end
						end })
					end
				end
			end

			if boosts and fasterSprint then
				fasterSprint.Value = 6
			end
		end)

		PlayToggleSound()
		return true
	end

	pcall(function()
		local boosts = localPlayer:FindFirstChild("Boosts")

		if boosts and boosts:FindFirstChild("Faster Sprint") then
			if boosts["Faster Sprint"].Value == 6 then
				boosts["Faster Sprint"].Value = 5
			end
		end
	end)

	PlayToggleSound()
	return true
end

MainModule.toggle_free_dash = ToggleFreeDash
MainModule.NoDashPhantomCDEnabled = false
MainModule.NoDashPhantomCDConnection = nil
MainModule.NoDashPhantomCDObj = nil

MainModule.toggle_no_dash_phantom_cd = function(arg)
	MainModule.NoDashPhantomCDEnabled = arg and true or false

	if MainModule.NoDashPhantomCDConnection then
		pcall(function()
			MainModule.NoDashPhantomCDConnection:Disconnect()
		end)

		MainModule.NoDashPhantomCDConnection = nil
	end

	MainModule.NoDashPhantomCDObj = nil

	if arg then
		local v = nil

		pcall(function()
			for _, v2 in pairs(getgc(true)) do
				if type(v2) == "table" and rawget(v2, "CDDASHSTACKS") and rawget(v2, "StopCounter") then
					v = v2
					break
				end
			end
		end)

		MainModule.NoDashPhantomCDObj = v

		if v then
			MainModule.NoDashPhantomCDConnection = RunService.RenderStepped:Connect(function()
				if not MainModule.NoDashPhantomCDEnabled then
					return
				end
				local noDashPhantomCDObj = MainModule.NoDashPhantomCDObj
				if not noDashPhantomCDObj then
					return
				end

				pcall(function()
					rawset(noDashPhantomCDObj, "DashCD", nil)

					if rawget(noDashPhantomCDObj, "CDDASHSTACKS") and rawget(noDashPhantomCDObj, "CDDASHSTACKS") > 1 then
						rawset(noDashPhantomCDObj, "CDDASHSTACKS", 1)
					end
				end)
			end)
		else
			MainModule.NoDashPhantomCDConnection = RunService.Heartbeat:Connect(function()
				if not MainModule.NoDashPhantomCDEnabled then
					return
				end

				if MainModule.NoDashPhantomCDObj then
					return
				end

				pcall(function()
					for _, v2 in pairs(getgc(true)) do
						if type(v2) == "table" and rawget(v2, "CDDASHSTACKS") and rawget(v2, "StopCounter") then
							MainModule.NoDashPhantomCDObj = v2

							if MainModule.NoDashPhantomCDConnection then
								pcall(function()
									MainModule.NoDashPhantomCDConnection:Disconnect()
								end)
							end

							MainModule.NoDashPhantomCDConnection = RunService.RenderStepped:Connect(function()
								if not MainModule.NoDashPhantomCDEnabled then
									return
								end
								local noDashPhantomCDObj = MainModule.NoDashPhantomCDObj
								if not noDashPhantomCDObj then
									return
								end

								pcall(function()
									rawset(noDashPhantomCDObj, "DashCD", nil)

									if rawget(noDashPhantomCDObj, "CDDASHSTACKS") and rawget(noDashPhantomCDObj, "CDDASHSTACKS") > 1 then
										rawset(noDashPhantomCDObj, "CDDASHSTACKS", 1)
									end
								end)
							end)

							break
						end
					end
				end)
			end)
		end
	end

	PlayToggleSound()
	return true
end

MainModule.FasterSprintEnabled = false
MainModule.FasterSprintLoop = nil
_G.FasterSprintEnabled = false

MainModule.toggle_faster_sprint = function(arg)
	local fasterSprintEnabled = arg and true or false
	MainModule.FasterSprintEnabled = fasterSprintEnabled
	_G.FasterSprintEnabled = fasterSprintEnabled

	if MainModule.FasterSprintLoop then
		pcall(task.cancel, MainModule.FasterSprintLoop)
		MainModule.FasterSprintLoop = nil
	end

	if fasterSprintEnabled then
		MainModule.FasterSprintLoop = task.spawn(function()
			local v = localPlayer

			while MainModule.FasterSprintEnabled do
				local character = v.Character

				if character and character.Parent then
					if not character:FindFirstChild("FASTERSPRINT") then
						local folder = Instance.new("Folder")
						folder.Name = "FASTERSPRINT"
						folder.Parent = character
					end

					local delIfGoneFolder = character:FindFirstChild("DelIfGone_Folder")

					if delIfGoneFolder then
						delIfGoneFolder:Destroy()
					end

					local staminaVal = character:FindFirstChild("StaminaVal")

					if staminaVal then
						staminaVal.Value = 100
					end

					local v2 = character:GetChildren()[36]

					if v2 and not character:FindFirstChild(v2.Name) then
						local folder = Instance.new("Folder")
						folder.Name = v2.Name
						folder.Parent = character
					end
				end

				task.wait()
			end
		end)
	end

	PlayToggleSound()
	return true
end

MainModule.AmbienceEnabled = false
MainModule.motionBlur = nil
MainModule.blurAmount = 12
MainModule.blurAmplifier = 12
MainModule.lastVector = nil
MainModule.originalTimeOfDay = nil
MainModule.ambienceConnection = nil
MainModule.timeFixConnection = nil

MainModule.toggle_ambience = function(ambienceEnabled)
	MainModule.AmbienceEnabled = ambienceEnabled

	if ambienceEnabled then
		local currentCamera = workspace.CurrentCamera
		MainModule.lastVector = currentCamera.CFrame.LookVector

		if MainModule.motionBlur and MainModule.motionBlur.Parent then
			MainModule.motionBlur:Destroy()
		end

		MainModule.motionBlur = Instance.new("BlurEffect", currentCamera)
		local Lighting = game:GetService("Lighting")
		MainModule.originalTimeOfDay = Lighting.TimeOfDay
		Lighting.TimeOfDay = "22:00:00"

		if MainModule.timeFixConnection then
			MainModule.timeFixConnection:Disconnect()
		end

		MainModule.timeFixConnection = Lighting.Changed:Connect(function(arg)
			if arg == "TimeOfDay" and MainModule.AmbienceEnabled then
				Lighting.TimeOfDay = "22:00:00"
			end
		end)

		if MainModule.ambienceConnection then
			MainModule.ambienceConnection:Disconnect()
		end

		MainModule.ambienceConnection = RunService.Heartbeat:Connect(function()
			if not MainModule.AmbienceEnabled then
				return
			end
			local currentCamera2 = workspace.CurrentCamera
			if not currentCamera2 then
				return
			end

			if not MainModule.motionBlur or MainModule.motionBlur.Parent == nil then
				MainModule.motionBlur = Instance.new("BlurEffect", currentCamera2)
			end

			local lookVector = currentCamera2.CFrame.LookVector
			local blurAmount = MainModule.blurAmount
			MainModule.motionBlur.Size = math.abs((lookVector - MainModule.lastVector).magnitude) * blurAmount * MainModule.blurAmplifier / 2
			MainModule.lastVector = lookVector
		end)

		workspace.Changed:Connect(function(arg)
			if arg == "CurrentCamera" and MainModule.AmbienceEnabled then
				local currentCamera2 = workspace.CurrentCamera

				if MainModule.motionBlur and MainModule.motionBlur.Parent then
					MainModule.motionBlur.Parent = currentCamera2
				else
					MainModule.motionBlur = Instance.new("BlurEffect", currentCamera2)
				end
			end
		end)
	else
		if MainModule.motionBlur then
			MainModule.motionBlur:Destroy()
			MainModule.motionBlur = nil
		end

		if MainModule.ambienceConnection then
			MainModule.ambienceConnection:Disconnect()
			MainModule.ambienceConnection = nil
		end

		if MainModule.timeFixConnection then
			MainModule.timeFixConnection:Disconnect()
			MainModule.timeFixConnection = nil
		end

		local Lighting = game:GetService("Lighting")

		if MainModule.originalTimeOfDay then
			Lighting.TimeOfDay = MainModule.originalTimeOfDay
		end
	end

	PlayToggleSound()
end

MainModule.ExitDoorESPEnabled = false
MainModule.ExitDoorESPThread = nil
MainModule.ExitDoorESPObjects = {}

MainModule.toggle_exit_door_esp = function(exitDoorESPEnabled)
	MainModule.ExitDoorESPEnabled = exitDoorESPEnabled

	if exitDoorESPEnabled then
		if MainModule.ExitDoorESPThread then
			task.cancel(MainModule.ExitDoorESPThread)
		end

		MainModule.ExitDoorESPThread = task.spawn(function()
			local tbl5 = {}

			local function fn22(arg)
				local boundingBox, v = arg:GetBoundingBox()
				local boxHandleAdornment = Instance.new("BoxHandleAdornment")
				boxHandleAdornment.Adornee = arg.PrimaryPart or arg:FindFirstChildWhichIsA("BasePart")
				if not boxHandleAdornment.Adornee then
					return nil
				end
				boxHandleAdornment.Size = v
				boxHandleAdornment.Color3 = Color3.fromRGB(255, 255, 0)
				boxHandleAdornment.Transparency = 0.5
				boxHandleAdornment.AlwaysOnTop = true
				boxHandleAdornment.ZIndex = 10
				boxHandleAdornment.Parent = boxHandleAdornment.Adornee
				local billboardGui = Instance.new("BillboardGui")
				billboardGui.Adornee = boxHandleAdornment.Adornee
				billboardGui.Size = UDim2.new(0, 100, 0, 50)
				billboardGui.StudsOffset = Vector3.new(0, 3, 0)
				billboardGui.AlwaysOnTop = true
				billboardGui.Parent = boxHandleAdornment.Adornee
				local textLabel = Instance.new("TextLabel")
				textLabel.Size = UDim2.new(1, 0, 1, 0)
				textLabel.BackgroundTransparency = 1
				textLabel.Text = "EXIT DOOR"
				textLabel.TextColor3 = Color3.fromRGB(255, 255, 0)
				textLabel.TextScaled = true
				textLabel.Font = Enum.Font.SourceSansBold
				textLabel.Parent = billboardGui
				return { box = boxHandleAdornment, billboard = billboardGui, part = boxHandleAdornment.Adornee }
			end

			while MainModule.ExitDoorESPEnabled do
				for _, v in pairs(tbl5) do
					if v.box and (not v.part or not v.part.Parent) then
						pcall(function()
							v.box:Destroy()
						end)

						pcall(function()
							v.billboard:Destroy()
						end)
					end
				end

				local hideAndSeekMap = workspace:FindFirstChild("HideAndSeekMap")

				if hideAndSeekMap then
					local fn23 = nil

					fn23 = function(arg)
						for _, child in pairs(arg:GetChildren()) do
							if child.Name == "EXITDOOR" and child:GetAttribute("ActuallyWorks") == true then
								if not tbl5[child] then
									local v = fn22(child)

									if v then
										tbl5[child] = v
									end
								end
							end

							fn23(child)
						end
					end

					fn23(hideAndSeekMap)
				end

				task.wait(0.5)
			end
		end)
	elseif MainModule.ExitDoorESPThread then
		task.cancel(MainModule.ExitDoorESPThread)
		MainModule.ExitDoorESPThread = nil
	end

	PlayToggleSound()
end

MainModule.Misc = {
	ESPEnabled = false,
	ESPPlayers = true,
	ESPHiders = true,
	ESPSeekers = true,
	ESPNames = true,
	ESPDistance = true,
	ESPHighlight = true,
	ESPFillTransparency = 0.75,
	ESPOutlineTransparency = 0.2,
	ESPTextSize = 14,
}

MainModule.ESP = {
	Players = {},
	Objects = {},
	Connections = {},
	Folder = nil,
	MainConnection = nil,
	UpdateRate = 0.1,
}

MainModule.clear_player_esp = function(arg)
	if not arg then
		return
	end
	local v = MainModule.ESP.Players[arg]

	if v then
		if v.Highlight then
			v.Highlight.Adornee = nil

			pcall(function()
				v.Highlight:Destroy()
			end)
		end

		if v.Billboard then
			pcall(function()
				v.Billboard:Destroy()
			end)
		end

		if v.CharAddedConn then
			pcall(function()
				v.CharAddedConn:Disconnect()
			end)

			v.CharAddedConn = nil
		end

		if v.DiedConn then
			pcall(function()
				v.DiedConn:Disconnect()
			end)

			v.DiedConn = nil
		end

		MainModule.ESP.Players[arg] = nil
	end
end

MainModule.update_player_esp = function(arg)
	if not arg or arg == localPlayer or not MainModule.Misc.ESPEnabled then
		return
	end
	local character = arg.Character
	if not character then
		MainModule.clear_player_esp(arg)
		return
	end
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

	if humanoid and humanoidRootPart and humanoid.Health > 0 then
		local tbl5 = MainModule.ESP.Players[arg]

		if not tbl5 then
			tbl5 = {
				Player = arg,
				Highlight = nil,
				Billboard = nil,
				Label = nil,
				CharAddedConn = nil,
				DiedConn = nil,
			}

			MainModule.ESP.Players[arg] = tbl5

			tbl5.DiedConn = humanoid.Died:Connect(function()
				if tbl5.Highlight then
					tbl5.Highlight.Adornee = nil
					tbl5.Highlight.Enabled = false
				end

				if tbl5.Billboard then
					tbl5.Billboard.Enabled = false
				end
			end)
		end

		if not tbl5.Highlight then
			tbl5.Highlight = Instance.new("Highlight")
			tbl5.Highlight.Name = arg.Name .. "_ESP"
			tbl5.Highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
			tbl5.Highlight.Enabled = true
			tbl5.Highlight.Parent = MainModule.ESP.Folder or CoreGui
		end

		if tbl5.Highlight.Adornee ~= character then
			tbl5.Highlight.Adornee = character
		end

		local color = Color3.fromRGB(0, 120, 255)

		if MainModule.is_hider and MainModule.is_hider(arg) then
			color = Color3.fromRGB(0, 255, 0)
		elseif MainModule.is_seeker and MainModule.is_seeker(arg) then
			color = Color3.fromRGB(255, 0, 0)
		end

		tbl5.Highlight.FillColor = color
		tbl5.Highlight.OutlineColor = color
		tbl5.Highlight.FillTransparency = MainModule.Misc.ESPFillTransparency
		tbl5.Highlight.OutlineTransparency = MainModule.Misc.ESPOutlineTransparency
		tbl5.Highlight.Enabled = true

		if MainModule.Misc.ESPNames then
			if not tbl5.Billboard then
				tbl5.Billboard = Instance.new("BillboardGui")
				tbl5.Billboard.Name = arg.Name .. "_Text"
				tbl5.Billboard.AlwaysOnTop = true
				tbl5.Billboard.Size = UDim2.new(0, 200, 0, 50)
				tbl5.Billboard.StudsOffset = Vector3.new(0, 2.5, 0)
				tbl5.Billboard.Parent = MainModule.ESP.Folder or CoreGui
				tbl5.Label = Instance.new("TextLabel")
				tbl5.Label.Size = UDim2.new(1, 0, 1, 0)
				tbl5.Label.BackgroundTransparency = 1
				tbl5.Label.TextColor3 = color
				tbl5.Label.TextSize = 14
				tbl5.Label.Font = Enum.Font.GothamBold
				tbl5.Label.TextStrokeColor3 = Color3.new(0, 0, 0)
				tbl5.Label.TextStrokeTransparency = 0.5
				tbl5.Label.Parent = tbl5.Billboard
			end

			if tbl5.Billboard.Adornee ~= humanoidRootPart then
				tbl5.Billboard.Adornee = humanoidRootPart
			end

			tbl5.Billboard.Enabled = true
			tbl5.Label.Text = (arg.DisplayName or arg.Name) .. "\n" .. string.format("HP: %d/%d", math.floor(humanoid.Health), math.floor(humanoid.MaxHealth))
			tbl5.Label.TextColor3 = color
		elseif tbl5.Billboard then
			tbl5.Billboard.Enabled = false
		end
	else
		local v = MainModule.ESP.Players[arg]

		if v then
			if v.Highlight then
				v.Highlight.Enabled = false
				v.Highlight.Adornee = nil
			end

			if v.Billboard then
				v.Billboard.Enabled = false
				v.Billboard.Adornee = nil
			end
		end
	end
end

MainModule.setup_player_esp = function(arg)
	if arg == localPlayer then
		return
	end
	MainModule.clear_player_esp(arg)

	if arg.Character then
		MainModule.update_player_esp(arg)
	end

	local connection = arg.CharacterAdded:Connect(function()
		task.wait(0.05)
		MainModule.update_player_esp(arg)
	end)

	local v = MainModule.ESP.Players[arg]

	if v then
		v.CharAddedConn = connection
	end
end

MainModule.toggle_old_esp = function(espEnabled)
	if encrypt and encrypt.start then
		pcall(encrypt.start)
	end

	MainModule.Misc.ESPEnabled = espEnabled

	if MainModule.ESP.MainConnection then
		MainModule.ESP.MainConnection:Disconnect()
		MainModule.ESP.MainConnection = nil
	end

	MainModule.clear_esp()

	if espEnabled then
		MainModule.ESP.Folder = Instance.new("Folder")
		MainModule.ESP.Folder.Name = "HollyScriptX_ESP"
		MainModule.ESP.Folder.Parent = CoreGui

		for _, player in pairs(Players:GetPlayers()) do
			if player ~= localPlayer then
				MainModule.setup_player_esp(player)
			end
		end

		MainModule.ESP.Connections.PlayerAdded = Players.PlayerAdded:Connect(function(player)
			if MainModule.Misc.ESPEnabled then
				MainModule.setup_player_esp(player)
			end
		end)

		MainModule.ESP.Connections.PlayerRemoving = Players.PlayerRemoving:Connect(function(player)
			MainModule.clear_player_esp(player)
		end)

		local n = 0

		MainModule.ESP.MainConnection = RunService.Heartbeat:Connect(function(deltaTime)
			if not MainModule.Misc.ESPEnabled then
				return
			end
			n += deltaTime or 0.016
			if n < 0.15 then
				return
			end
			n = 0
			local n2 = 0

			for k in pairs(MainModule.ESP.Players) do
				n2 += 1

				if not (n2 > 8) then
					if k and k.Parent then
						MainModule.update_player_esp(k)
					else
						MainModule.clear_player_esp(k)
					end

					continue
				end

				break
			end
		end)
	end

	PlayToggleSound()

	if encrypt and encrypt["end"] then
		pcall(encrypt["end"])
	end
end

MainModule.clear_esp = function()
	for k in pairs(MainModule.ESP.Players) do
		MainModule.clear_player_esp(k)
	end

	MainModule.ESP.Players = {}

	if MainModule.ESP.Connections then
		for k, connection in pairs(MainModule.ESP.Connections) do
			if connection then
				pcall(function()
					connection:Disconnect()
				end)

				MainModule.ESP.Connections[k] = nil
			end
		end
	end

	if MainModule.ESP.Folder then
		pcall(function()
			MainModule.ESP.Folder:Destroy()
		end)

		MainModule.ESP.Folder = nil
	end
end

local Players2 = game:GetService("Players")
local RunService2 = game:GetService("RunService")
local SoundService = game:GetService("SoundService")
local CoreGui2 = game:GetService("CoreGui")
local localPlayer2 = Players2.LocalPlayer
MainModule = MainModule or {}

local function fn22()
	local sound = Instance.new("Sound")
	sound.SoundId = "rbxassetid://99979147606311"
	sound.Volume = 5
	sound.Parent = SoundService
	sound:Play()

	sound.Ended:Once(function()
		sound:Destroy()
	end)
end

local tbl5 = { Enabled = false, RGB = false, Cache = {}, Connection = nil }
local newESP = CoreGui2:FindFirstChild("NewESP")

if newESP then
	newESP:Destroy()
end

tbl5.ScreenGui = Instance.new("ScreenGui")
tbl5.ScreenGui.Name = "NewESP"
tbl5.ScreenGui.ResetOnSpawn = false
tbl5.ScreenGui.IgnoreGuiInset = true
tbl5.ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
tbl5.ScreenGui.DisplayOrder = 999999
tbl5.ScreenGui.Parent = CoreGui2

local function fn23(arg, arg2)
	if not arg or not arg2 then
		return nil
	end
	local flag2 = arg:GetAttribute("Hunter") == true or arg:GetAttribute("IsHunter") == true or arg2:GetAttribute("Hunter") == true or arg2:GetAttribute("IsHunter") == true
	local flag3 = arg:GetAttribute("Hider") == true or arg:GetAttribute("IsHider") == true or arg2:GetAttribute("Hider") == true or arg2:GetAttribute("IsHider") == true
	if flag2 then
		return "Hunter"
	end

	if flag3 then
		return "Hider"
	end
	return nil
end

local function fn24(arg, arg2)
	local v = fn23(arg, arg2)
	if v == "Hunter" then
		return Color3.fromRGB(255, 65, 65)
	end

	if v == "Hider" then
		return Color3.fromRGB(65, 145, 255)
	end

	if tbl5.RGB then
		return Color3.fromHSV(os.clock() * 0.35 % 1, 0.9, 1)
	end
	return Color3.fromRGB(235, 235, 240)
end

local function fn25(arg)
	if arg > 0.6 then
		return Color3.fromRGB(40, 240, 80)
	end

	if arg > 0.3 then
		return Color3.fromRGB(255, 215, 40)
	end
	return Color3.fromRGB(255, 55, 55)
end

tbl5.Hide = function(arg)
	if not arg then
		return
	end

	if arg.Box then
		arg.Box.Visible = false
	end

	if arg.Name then
		arg.Name.Visible = false
	end

	if arg.HealthText then
		arg.HealthText.Visible = false
	end

	if arg.HealthBg then
		arg.HealthBg.Visible = false
	end

	if arg.HealthBar then
		arg.HealthBar.Visible = false
	end
end

tbl5.HideAll = function()
	for _, v in pairs(tbl5.Cache) do
		tbl5.Hide(v)
	end
end

tbl5.DestroyESP = function(arg)
	if not arg then
		return
	end

	pcall(function()
		if arg.Box then
			arg.Box:Destroy()
		end

		if arg.Name then
			arg.Name:Destroy()
		end

		if arg.HealthText then
			arg.HealthText:Destroy()
		end

		if arg.HealthBg then
			arg.HealthBg:Destroy()
		end

		if arg.HealthBar then
			arg.HealthBar:Destroy()
		end
	end)
end

tbl5.ClearAll = function()
	for _, v in pairs(tbl5.Cache) do
		tbl5.DestroyESP(v)
	end

	table.clear(tbl5.Cache)
end

tbl5.Create = function(arg)
	if tbl5.Cache[arg] then
		return tbl5.Cache[arg]
	end
	local tbl6 = {}
	local frame = Instance.new("Frame")
	frame.Name = "Box"
	frame.BackgroundTransparency = 1
	frame.BorderSizePixel = 0
	frame.Visible = false
	frame.ZIndex = 10
	frame.Parent = tbl5.ScreenGui
	local uiStroke = Instance.new("UIStroke")
	uiStroke.Thickness = 1.5
	uiStroke.Transparency = 0
	uiStroke.Color = Color3.fromRGB(235, 235, 240)
	uiStroke.Parent = frame
	local textLabel = Instance.new("TextLabel")
	textLabel.Name = "Name"
	textLabel.BackgroundTransparency = 1
	textLabel.BorderSizePixel = 0
	textLabel.Font = Enum.Font.GothamBold
	textLabel.TextSize = 13
	textLabel.TextColor3 = Color3.fromRGB(235, 235, 240)
	textLabel.TextStrokeTransparency = 0.25
	textLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
	textLabel.TextXAlignment = Enum.TextXAlignment.Center
	textLabel.Visible = false
	textLabel.ZIndex = 11
	textLabel.Parent = tbl5.ScreenGui
	local textLabel2 = Instance.new("TextLabel")
	textLabel2.Name = "Health"
	textLabel2.BackgroundTransparency = 1
	textLabel2.BorderSizePixel = 0
	textLabel2.Font = Enum.Font.Gotham
	textLabel2.TextSize = 11
	textLabel2.TextColor3 = Color3.fromRGB(235, 235, 240)
	textLabel2.TextStrokeTransparency = 0.25
	textLabel2.TextStrokeColor3 = Color3.new(0, 0, 0)
	textLabel2.TextXAlignment = Enum.TextXAlignment.Center
	textLabel2.Visible = false
	textLabel2.ZIndex = 11
	textLabel2.Parent = tbl5.ScreenGui
	local frame2 = Instance.new("Frame")
	frame2.Name = "HealthBackground"
	frame2.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
	frame2.BorderSizePixel = 0
	frame2.Visible = false
	frame2.ZIndex = 10
	frame2.Parent = tbl5.ScreenGui
	local frame3 = Instance.new("Frame")
	frame3.Name = "HealthBar"
	frame3.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
	frame3.BorderSizePixel = 0
	frame3.Visible = false
	frame3.ZIndex = 11
	frame3.Parent = tbl5.ScreenGui
	tbl6.Box = frame
	tbl6.BoxStroke = uiStroke
	tbl6.Name = textLabel
	tbl6.HealthText = textLabel2
	tbl6.HealthBg = frame2
	tbl6.HealthBar = frame3
	tbl5.Cache[arg] = tbl6
	return tbl6
end

local tbl6 = {
	"Head",
	"HumanoidRootPart",
	"UpperTorso",
	"LowerTorso",
	"Torso",
	"LeftUpperArm",
	"LeftLowerArm",
	"LeftHand",
	"RightUpperArm",
	"RightLowerArm",
	"RightHand",
	"LeftUpperLeg",
	"LeftLowerLeg",
	"LeftFoot",
	"RightUpperLeg",
	"RightLowerLeg",
	"RightFoot",
	"Left Arm",
	"Right Arm",
	"Left Leg",
	"Right Leg",
}

local function fn26(arg, arg2)
	local flag2 = false
	local huge = math.huge
	local huge2 = math.huge
	local n = -math.huge
	local n2 = -math.huge

	for _, v in ipairs(tbl6) do
		local v2 = arg:FindFirstChild(v)

		if v2 and v2:IsA("BasePart") then
			local cFrame = v2.CFrame
			local size = v2.Size
			local n3 = size.X / 2
			local n4 = size.Y / 2
			local n5 = size.Z / 2
			local tbl7 = {}
			local vector = Vector3.new(-n3, -n4, -n5)
			local vector2 = Vector3.new(-n3, -n4, n5)
			local vector3 = Vector3.new(-n3, n4, -n5)
			local vector4 = Vector3.new(-n3, n4, n5)
			local vector5 = Vector3.new(n3, -n4, -n5)
			local vector6 = Vector3.new(n3, -n4, n5)
			local vector7 = Vector3.new(n3, n4, -n5)
			local vector8 = Vector3.new
			tbl7[1] = vector
			tbl7[2] = vector2
			tbl7[3] = vector3
			tbl7[4] = vector4
			tbl7[5] = vector5
			tbl7[6] = vector6
			tbl7[7] = vector7

			do
				local values = table.pack(vector8(n3, n4, n5))
				table.move(values, 1, values.n, 8, tbl7)
			end

			for _, v3 in ipairs(tbl7) do
				local v4 = cFrame:PointToWorldSpace(v3)
				local v5 = arg2:WorldToViewportPoint(v4)

				if v5.Z > 0 then
					flag2 = true
					huge = math.min(huge, v5.X)
					huge2 = math.min(huge2, v5.Y)
					n = math.max(n, v5.X)
					n2 = math.max(n2, v5.Y)
				end
			end
		end
	end

	if not flag2 then
		return nil
	end
	local n3 = n - huge
	local n4 = n2 - huge2
	if n3 < 2 or n4 < 2 then
		return nil
	end
	local n5 = math.max(2, n3 * 0.05)
	local n6 = math.max(2, n4 * 0.025)
	return huge - n5, huge2 - n6, n + n5, n2 + n6
end

tbl5.Update = function()
	if not tbl5.Enabled then
		tbl5.HideAll()
		return
	end
	local currentCamera = workspace.CurrentCamera
	if not currentCamera then
		return
	end
	local tbl7 = {}

	for _, player in ipairs(Players2:GetPlayers()) do
		if player ~= localPlayer2 then
			local character = player.Character
			local humanoid = character and character:FindFirstChildOfClass("Humanoid")
			local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

			if character and humanoid and humanoidRootPart and humanoid.Health > 0 and humanoidRootPart.Position.Y > -50 then
				tbl7[player] = true
				local v = tbl5.Cache[player] or tbl5.Create(player)
				local v2, v3, v4, v5 = fn26(character, currentCamera)

				if v2 then
					local n = v4 - v2
					local n2 = v5 - v3
					local n3 = v2 + n / 2
					local v6 = fn24(player, character)
					local floor = math.floor
					v.Box.Position = UDim2.fromOffset(math.floor(v2), floor(v3))
					local floor2 = math.floor
					v.Box.Size = UDim2.fromOffset(math.floor(n), floor2(n2))
					v.BoxStroke.Color = v6
					v.Box.Visible = true
					local displayName = player.DisplayName

					if not displayName or displayName == "" then
						displayName = player.Name
					end

					v.Name.Text = displayName
					v.Name.TextColor3 = v6
					local n4 = math.max(n + 80, 130)
					v.Name.Size = UDim2.fromOffset(n4, 18)
					v.Name.Position = UDim2.fromOffset(n3 - n4 / 2, v3 - 20)
					v.Name.Visible = true
					local n5 = 0

					if humanoid.MaxHealth > 0 then
						n5 = math.clamp(humanoid.Health / humanoid.MaxHealth, 0, 1)
					end

					local n6 = v2 - 7
					v.HealthBg.Position = UDim2.fromOffset(n6 - 1, v3 - 1)
					v.HealthBg.Size = UDim2.fromOffset(5, n2 + 2)
					v.HealthBg.Visible = true
					local n7 = n2 * n5
					v.HealthBar.Position = UDim2.fromOffset(n6, v5 - n7)
					v.HealthBar.Size = UDim2.fromOffset(3, n7)
					v.HealthBar.BackgroundColor3 = fn25(n5)
					v.HealthBar.Visible = true
					v.HealthText.Text = math.floor(humanoid.Health) .. " / " .. math.floor(humanoid.MaxHealth)
					local n8 = math.max(n + 80, 120)
					v.HealthText.Size = UDim2.fromOffset(n8, 16)
					v.HealthText.Position = UDim2.fromOffset(n3 - n8 / 2, v5 + 2)
					v.HealthText.Visible = true
				else
					tbl5.Hide(v)
				end
			end
		end
	end

	for k, v in pairs(tbl5.Cache) do
		if not tbl7[k] then
			tbl5.DestroyESP(v)
			tbl5.Cache[k] = nil
		end
	end
end

MainModule.toggle_new_esp = function(arg)
	if encrypt and encrypt.start then
		pcall(encrypt.start)
	end

	tbl5.Enabled = arg and true or false

	if tbl5.Enabled then
		if not tbl5.Connection then
			local n = 0

			tbl5.Connection = RunService2.Heartbeat:Connect(function(deltaTime)
				if not tbl5.Enabled then
					return
				end
				n += deltaTime or 0.016
				if n < 0.15 then
					return
				end
				n = 0
				local ok, result = pcall(tbl5.Update)

				if not ok then
					warn("[NewESP]", result)
				end
			end)
		end
	else
		if tbl5.Connection then
			tbl5.Connection:Disconnect()
			tbl5.Connection = nil
		end

		tbl5.HideAll()
		tbl5.ClearAll()
	end

	fn22()

	if encrypt and encrypt["end"] then
		pcall(encrypt["end"])
	end
end

MainModule.toggle_esprgb = function(arg)
	tbl5.RGB = arg and true or false
end

MainModule.PlayerESPEnabled = MainModule.PlayerESPEnabled or false
MainModule.ESPRGBEnabled = MainModule.ESPRGBEnabled or false
MainModule.ESP_Mode = MainModule.ESP_Mode or "Old"

MainModule.set_esp_mode = function(espMode)
	MainModule.ESP_Mode = espMode
	MainModule.toggle_new_esp(false)

	if MainModule.toggle_old_esp then
		MainModule.toggle_old_esp(false)
	end

	if MainModule.PlayerESPEnabled then
		if espMode == "New" then
			MainModule.toggle_new_esp(true)
		elseif espMode == "Old" and MainModule.toggle_old_esp then
			MainModule.toggle_old_esp(true)
		end
	end

	fn22()
end

MainModule.toggle_player_esp = function(arg)
	MainModule.PlayerESPEnabled = arg and true or false

	if arg then
		if MainModule.ESP_Mode == "New" then
			MainModule.toggle_new_esp(true)
		elseif MainModule.toggle_old_esp then
			MainModule.toggle_old_esp(true)
		end
	else
		MainModule.toggle_new_esp(false)

		if MainModule.toggle_old_esp then
			MainModule.toggle_old_esp(false)
		end
	end

	fn22()
end

MainModule.AutoSafe = { Enabled = false, Connection = nil, HasTeleported = false, LowHPChecked = false }

MainModule.toggle_auto_safe = function(enabled)
	if MainModule.AutoSafe.Connection then
		MainModule.AutoSafe.Connection:Disconnect()
		MainModule.AutoSafe.Connection = nil
	end

	MainModule.AutoSafe.Enabled = enabled
	MainModule.AutoSafe.HasTeleported = false
	MainModule.AutoSafe.LowHPChecked = false

	if enabled then
		MainModule.AutoSafe.Connection = RunService2.Heartbeat:Connect(function()
			if not MainModule.AutoSafe.Enabled then
				if MainModule.AutoSafe.Connection then
					MainModule.AutoSafe.Connection:Disconnect()
					MainModule.AutoSafe.Connection = nil
				end

				return
			end

			local flag2 = false

			for _, v in pairs({
				"Mingle",
				"JumpRope",
				"Pentathlon",
				"GlassBridge",
				"SquidGame",
				"SkySquidGame",
				"RedLightGreenLight",
				"TugOfWar",
			}) do
				if MainModule.is_game_active(v) then
					flag2 = true
					break
				end
			end

			if flag2 then
				return
			end
			local v = MainModule.get_character()

			if v then
				local humanoid = v:FindFirstChildOfClass("Humanoid")

				if humanoid then
					if MainModule.is_game_active("HideAndSeek") or MainModule.is_game_active("LightsOut") or MainModule.is_game_active("LightOut") then
						if humanoid.Health <= 30 then
							if not MainModule.AutoSafe.HasTeleported then
								local humanoidRootPart = v:FindFirstChild("HumanoidRootPart") or v.PrimaryPart

								if humanoidRootPart then
									local position = humanoidRootPart.Position
									local vector = Vector3.new(position.X, position.Y + 150, position.Z)
									humanoidRootPart.CFrame = CFrame.new(vector)
									MainModule.AutoSafe.HasTeleported = true
									MainModule.AutoSafe.LowHPChecked = true
								end
							end
						elseif humanoid.Health > 30 and MainModule.AutoSafe.HasTeleported then
							MainModule.AutoSafe.HasTeleported = false
						end
					elseif humanoid.Health <= 30 then
						if not MainModule.AutoSafe.HasTeleported then
							local humanoidRootPart = v:FindFirstChild("HumanoidRootPart") or v.PrimaryPart

							if humanoidRootPart then
								local position = humanoidRootPart.Position
								local vector = Vector3.new(position.X, position.Y + 100, position.Z)
								humanoidRootPart.CFrame = CFrame.new(vector)
								MainModule.AutoSafe.HasTeleported = true
								MainModule.AutoSafe.LowHPChecked = true
							end
						end
					elseif humanoid.Health > 30 and MainModule.AutoSafe.HasTeleported then
						MainModule.AutoSafe.HasTeleported = false
					end
				end
			end
		end)
	end

	fn22()
end

MainModule.dalgona_lighter = function()
	if MainModule.is_game_active("Dalgona") then
		localPlayer2:SetAttribute("HasLighter", true)
	else
		MainModule.notify("Dalgona", "Wait for Dalgona!", 0.9)
		PlayErrorSound()
	end

	PlayBell()
end

MainModule.AutoCollectFlashbang = false
MainModule.AutoCollectFlashbangLoop = nil

MainModule.toggle_auto_collect_flashbang = function(autoCollectFlashbang)
	MainModule.AutoCollectFlashbang = autoCollectFlashbang

	if MainModule.AutoCollectFlashbangLoop then
		task.cancel(MainModule.AutoCollectFlashbangLoop)
		MainModule.AutoCollectFlashbangLoop = nil
	end

	if autoCollectFlashbang then
		MainModule.AutoCollectFlashbangLoop = task.spawn(function()
			while MainModule.AutoCollectFlashbang do
				local v = MainModule.get_character()

				if not v then
					task.wait(0.5)
				else
					local v2 = MainModule.get_root_part(v)

					if not v2 then
						task.wait(0.5)
					else
						local cFrame = v2.CFrame

						if not MainModule.has_tool("Flashbang") then
							local effects = workspace:FindFirstChild("Effects")
							local flag2 = false

							if effects then
								flag2 = false

								for _, child in pairs(effects:GetChildren()) do
									if child.Name == "DroppedFlashbang" and child:FindFirstChild("Stun Grenade") then
										v2.CFrame = child["Stun Grenade"].CFrame
										flag2 = true
										break
									else
										flag2 = false
									end
								end
							end

							if flag2 then
								task.wait(0.3)
								v2.CFrame = cFrame
							end
						end

						task.wait(0.5)
					end
				end
			end
		end)
	end

	fn22()
end

MainModule.AutoCollectGrenade = false
MainModule.AutoCollectGrenadeLoop = nil

MainModule.toggle_auto_collect_grenade = function(autoCollectGrenade)
	MainModule.AutoCollectGrenade = autoCollectGrenade

	if MainModule.AutoCollectGrenadeLoop then
		task.cancel(MainModule.AutoCollectGrenadeLoop)
		MainModule.AutoCollectGrenadeLoop = nil
	end

	if autoCollectGrenade then
		MainModule.AutoCollectGrenadeLoop = task.spawn(function()
			while MainModule.AutoCollectGrenade do
				local v = MainModule.get_character()

				if not v then
					task.wait(0.5)
				else
					local v2 = MainModule.get_root_part(v)

					if not v2 then
						task.wait(0.5)
					else
						local cFrame = v2.CFrame

						if not MainModule.has_tool("Grenade") then
							local effects = workspace:FindFirstChild("Effects")
							local flag2 = false

							if effects then
								flag2 = false

								for _, child in pairs(effects:GetChildren()) do
									if child.Name == "DroppedGrenade" and child:FindFirstChild("Handle") then
										v2.CFrame = child.Handle.CFrame
										flag2 = true
										break
									else
										flag2 = false
									end
								end
							end

							if flag2 then
								task.wait(0.3)
								v2.CFrame = cFrame
							end
						end

						task.wait(0.5)
					end
				end
			end
		end)
	end

	fn22()
end

MainModule.jr_tp_start = function()
	if MainModule.is_game_active("JumpRope") then
		MainModule.safe_teleport(Vector3.new(615.2844, 192.27428, 920.9525))
		MainModule.notify("JumpRope", "Teleported to Start", 0.9)
	else
		MainModule.notify("JumpRope", "Wait for JumpRope!", 0.9)
		PlayErrorSound()
	end

	PlayBell()
end

MainModule.jr_tp_end = function()
	if MainModule.is_game_active("JumpRope") then
		MainModule.safe_teleport(Vector3.new(720.89606, 198.62831, 921.17065))
		MainModule.notify("JumpRope", "Teleported to End", 0.9)
	else
		MainModule.notify("JumpRope", "Wait for JumpRope!", 0.9)
		PlayErrorSound()
	end

	PlayBell()
end

MainModule.jr_delete_rope = function()
	if MainModule.is_game_active("JumpRope") then
		for _, descendant in pairs(workspace:GetDescendants()) do
			if descendant.Name == "Rope" and (descendant:IsA("Model") or descendant:IsA("Part")) then
				descendant:Destroy()
				MainModule.notify("JumpRope", "Rope deleted", 0.9)
				PlayBell()
				return
			end
		end

		MainModule.notify("JumpRope", "Rope not found", 0.9)
		PlayErrorSound()
	else
		MainModule.notify("JumpRope", "Wait for JumpRope!", 0.9)
		PlayErrorSound()
	end

	PlayBell()
end

MainModule.GlobalAntiFall = { Enabled = false, Platform = nil, Conn = nil }

MainModule.toggle_global_anti_fall = function(arg)
	MainModule.GlobalAntiFall.Enabled = arg and true or false

	if MainModule.GlobalAntiFall.Conn then
		pcall(function()
			MainModule.GlobalAntiFall.Conn:Disconnect()
		end)

		MainModule.GlobalAntiFall.Conn = nil
	end

	if MainModule.GlobalAntiFall.Platform then
		pcall(function()
			MainModule.GlobalAntiFall.Platform:Destroy()
		end)

		MainModule.GlobalAntiFall.Platform = nil
	end

	if not arg then
		fn22()
		return true
	end

	local function createPart()
		local getCharacter = MainModule.get_character and MainModule.get_character() or localPlayer2.Character

		if getCharacter then
			getCharacter = getCharacter:FindFirstChild("HumanoidRootPart") or getCharacter.PrimaryPart
		end

		if not getCharacter then
			return nil
		end
		local part = Instance.new("Part")
		part.Name = HttpService:GenerateGUID(false)
		part.Size = Vector3.new(12, 1, 12)
		part.Anchored = true
		part.CanCollide = true
		part.Transparency = 0.5
		part.Material = Enum.Material.SmoothPlastic
		part.Color = Color3.fromRGB(100, 100, 100)
		part.CFrame = CFrame.new(getCharacter.Position.X, getCharacter.Position.Y - 3.5, getCharacter.Position.Z)
		part.Parent = workspace
		return part
	end

	MainModule.GlobalAntiFall.Platform = createPart()

	MainModule.GlobalAntiFall.Conn = RunService2.Heartbeat:Connect(function()
		if not MainModule.GlobalAntiFall.Enabled then
			return
		end
		local getCharacter = MainModule.get_character and MainModule.get_character() or localPlayer2.Character
		local humanoidRootPart

		if getCharacter then
			humanoidRootPart = getCharacter:FindFirstChild("HumanoidRootPart") or getCharacter.PrimaryPart
		else
			humanoidRootPart = getCharacter
		end

		if not humanoidRootPart then
			return
		end

		if not (MainModule.GlobalAntiFall.Platform and MainModule.GlobalAntiFall.Platform.Parent) then
			MainModule.GlobalAntiFall.Platform = createPart()
		end

		if MainModule.GlobalAntiFall.Platform then
			MainModule.GlobalAntiFall.Platform.CFrame = CFrame.new(humanoidRootPart.Position.X, humanoidRootPart.Position.Y - 3.5, humanoidRootPart.Position.Z)
			MainModule.GlobalAntiFall.Platform.Transparency = 0.5
		end
	end)

	fn22()
	return true
end

MainModule.JumpRopeAntiFall = { Enabled = false, Platform = nil, Conn = nil }

MainModule.toggle_jump_rope_anti_fall = function(enabled)
	local jumpRopeAntiFall = MainModule.ToggleRefs.JumpRopeAntiFall

	if enabled then
		if not MainModule.can_enable_toggle("JumpRope", "Anti Fall", jumpRopeAntiFall) then
			return false
		end
	end

	if MainModule.JumpRopeAntiFall.Conn then
		MainModule.JumpRopeAntiFall.Conn:Disconnect()
	end

	if MainModule.JumpRopeAntiFall.Platform then
		MainModule.JumpRopeAntiFall.Platform:Destroy()
	end

	MainModule.JumpRopeAntiFall.Enabled = enabled

	if enabled then
		local function createPart()
			local v = MainModule.get_character()
			if not v then
				return nil
			end
			local v2 = MainModule.get_root_part(v)
			if not v2 then
				return nil
			end
			local part = Instance.new("Part")
			part.Name = HttpService:GenerateGUID(false)
			part.Size = Vector3.new(10000, 1, 10000)
			part.Position = Vector3.new(v2.Position.X, v2.Position.Y - 5, v2.Position.Z)
			part.Anchored = true
			part.CanCollide = true
			part.Transparency = 0.5
			part.Parent = workspace
			return part
		end

		MainModule.JumpRopeAntiFall.Platform = createPart()

		MainModule.JumpRopeAntiFall.Conn = RunService2.Heartbeat:Connect(function()
			if not MainModule.JumpRopeAntiFall.Enabled then
				return
			end

			if not MainModule.is_game_active("JumpRope") then
				MainModule.disable_toggle("JumpRopeAntiFall")
				return
			end

			if not (MainModule.JumpRopeAntiFall.Platform and MainModule.JumpRopeAntiFall.Platform.Parent) then
				MainModule.JumpRopeAntiFall.Platform = createPart()
			end
		end)
	end

	fn22()
	return true
end

MainModule.gb_tp_end = function()
	if MainModule.is_game_active("GlassBridge") then
		MainModule.safe_teleport(Vector3.new(-196.37247, 522.19214, -1534.2098))
		MainModule.notify("GlassBridge", "Teleported to End", 0.9)
	else
		MainModule.notify("GlassBridge", "Wait for GlassBridge!", 0.9)
		PlayErrorSound()
	end

	PlayBell()
end

MainModule.GlassESPEnabled = false
MainModule.GlassESPConnection = nil
MainModule.GlassESPHighlighted = {}
MainModule.GlassESPOriginal = {}

MainModule.toggle_glass_esp = function(arg)
	local glassESP = MainModule.ToggleRefs.GlassESP

	if arg then
		if not MainModule.can_enable_toggle("GlassBridge", "Glass ESP", glassESP) then
			return false
		end
	end

	MainModule.GlassESPEnabled = arg and true or false

	if MainModule.GlassESPConnection then
		pcall(function()
			MainModule.GlassESPConnection:Disconnect()
		end)

		MainModule.GlassESPConnection = nil
	end

	for k, v in pairs(MainModule.GlassESPOriginal) do
		if k and k.Parent then
			pcall(function()
				k.Color = v.Color
				k.Material = v.Material
			end)
		end
	end

	MainModule.GlassESPOriginal = {}
	MainModule.GlassESPHighlighted = {}
	if not arg then
		fn22()
		return true
	end
	local glassHolder = workspace:FindFirstChild("GlassBridge") and workspace.GlassBridge:FindFirstChild("GlassHolder")
	if not glassHolder then
		fn22()
		return true
	end

	local function fn27(arg2)
		if not arg2:GetAttribute("GlassPart") then
			return nil
		end
		local flag2 = arg2:GetAttribute("ActuallyKilling") ~= nil
		local flag3 = arg2:GetAttribute("DelayedBreaking") ~= nil
		if flag2 and flag3 then
			return "delayed"
		end

		if flag2 then
			return "fake"
		end
		return "real"
	end

	local tbl7 = {
		real = Color3.fromRGB(0, 255, 0),
		delayed = Color3.fromRGB(255, 200, 0),
		fake = Color3.fromRGB(255, 0, 0),
	}

	for _, descendant in ipairs(glassHolder:GetDescendants()) do
		if descendant:IsA("BasePart") and descendant:GetAttribute("GlassPart") then
			local v = fn27(descendant)

			if v then
				if not MainModule.GlassESPOriginal[descendant] then
					MainModule.GlassESPOriginal[descendant] = { Color = descendant.Color, Material = descendant.Material }
				end

				descendant.Color = tbl7[v]
				descendant.Material = Enum.Material.Neon
				MainModule.GlassESPHighlighted[descendant] = v
			end
		end
	end

	MainModule.GlassESPConnection = RunService2.RenderStepped:Connect(function()
		if not MainModule.GlassESPEnabled then
			return
		end

		if not glassHolder.Parent then
			if MainModule.GlassESPConnection then
				MainModule.GlassESPConnection:Disconnect()
				MainModule.GlassESPConnection = nil
			end

			return
		end

		for k, v in pairs(MainModule.GlassESPHighlighted) do
			if k and k.Parent then
				k.Color = tbl7[v]
				k.Material = Enum.Material.Neon
			else
				MainModule.GlassESPHighlighted[k] = nil
			end
		end
	end)

	fn22()
	return true
end

MainModule.set_title = function(currentTitleValue)
	MainModule.CurrentTitleValue = currentTitleValue

	if MainModule.TitleEnabled then
		MainModule.update_title()
	end
end

MainModule.AntiBreakEnabled = false
MainModule.AntiBreakConn = nil
MainModule.SafetyPlatforms = {}

MainModule.toggle_anti_break = function(arg)
	local antiBreakEnabled = arg and true or false
	MainModule.AntiBreakEnabled = antiBreakEnabled

	if MainModule.AntiBreakConn then
		pcall(function()
			MainModule.AntiBreakConn:Disconnect()
		end)

		MainModule.AntiBreakConn = nil
	end

	local function fn27()
		local glassBridge = Workspace:FindFirstChild("GlassBridge")
		if not glassBridge then
			return
		end
		local glassHolder = glassBridge:FindFirstChild("GlassHolder")
		if not glassHolder then
			return
		end

		for _, descendant in ipairs(glassHolder:GetDescendants()) do
			if descendant:IsA("TouchTransmitter") or descendant:IsA("ProximityPrompt") or typeof(descendant.Name) == "string" and descendant.Name:lower():find("touch") then
				pcall(function()
					descendant:Destroy()
				end)
			elseif descendant:IsA("BasePart") then
				for _, child in ipairs(descendant:GetChildren()) do
					if child.ClassName == "TouchInterest" then
						pcall(function()
							child:Destroy()
						end)
					end
				end
			end
		end
	end

	if antiBreakEnabled then
		fn27()

		MainModule.AntiBreakConn = RunService2.Heartbeat:Connect(function()
			if not MainModule.AntiBreakEnabled then
				return
			end
			local now = tick()
			if (MainModule._AntiBreakLast or 0) + 1 > now then
				return
			end
			MainModule._AntiBreakLast = now
			pcall(fn27)
		end)
	end

	if fn22 then
		fn22()
	end

	return true
end

MainModule.FreezeRopeEnabled = false
MainModule.FreezeRopeConnection = nil

MainModule.toggle_freeze_rope = function(freezeRopeEnabled)
	MainModule.FreezeRopeEnabled = freezeRopeEnabled
	local rope = workspace:FindFirstChild("Effects") and workspace.Effects:FindFirstChild("rope")

	if not rope then
		if MainModule.ToggleRefs.FreezeRope then
			pcall(function()
				MainModule.ToggleRefs.FreezeRope:SetValue(false)
			end)
		end

		return
	end

	if freezeRopeEnabled then
		for _, descendant in ipairs(rope:GetDescendants()) do
			if descendant:IsA("BasePart") then
				descendant.Anchored = true
				descendant.Velocity = Vector3.zero
				descendant.RotVelocity = Vector3.zero
			elseif descendant:IsA("Constraint") or descendant:IsA("RopeConstraint") or descendant:IsA("Motor6D") then
				descendant.Enabled = false
			end
		end
	else
		for _, descendant in ipairs(rope:GetDescendants()) do
			if descendant:IsA("BasePart") then
				descendant.Anchored = false
			elseif descendant:IsA("Constraint") or descendant:IsA("RopeConstraint") or descendant:IsA("Motor6D") then
				descendant.Enabled = true
			end
		end
	end

	fn22()
end

MainModule.remove_balance_mini_game = function()
	local playingJumpRope = localPlayer2:FindFirstChild("PlayingJumpRope")

	if playingJumpRope then
		pcall(function()
			playingJumpRope:Destroy()
		end)

		PlayBell()
	else
		MainModule.notify("Jump Rope", "PlayingJumpRope not found", 0.9)
		PlayErrorSound()
	end
end

MainModule.AutoJumpEnabled = false
MainModule.AutoJumpLoop = nil

MainModule.toggle_auto_jump = function(autoJumpEnabled)
	MainModule.AutoJumpEnabled = autoJumpEnabled

	if MainModule.AutoJumpLoop then
		task.cancel(MainModule.AutoJumpLoop)
		MainModule.AutoJumpLoop = nil
	end

	if autoJumpEnabled then
		MainModule.AutoJumpLoop = task.spawn(function()
			while MainModule.AutoJumpEnabled do
				local rope = workspace:FindFirstChild("Effects") and workspace.Effects:FindFirstChild("rope")
				local v = MainModule.get_character()

				if rope and v then
					local v2 = MainModule.get_root_part(v)

					if v2 and (v2.Position - rope.Position).Magnitude <= 15 then
						local v3 = MainModule.get_humanoid(v)

						if v3 and v3.Health > 0 then
							v3:ChangeState(Enum.HumanoidStateType.Jumping)
						end
					end
				end

				task.wait(1)
			end
		end)
	end

	fn22()
end

MainModule.JumpRopeAntiHit = {
	Enabled = false,
	Connection = nil,
	AnimationId = "rbxassetid://105677261748140",
	AnimationDuration = 0.4,
	CurrentAnimation = nil,
	StopTimer = nil,
	WasJumping = false,
	RopeDestroyed = false,
}

MainModule.JumpRopeFakeBalance = {
	Enabled = false,
	Connection = nil,
	AnimationId = "rbxassetid://105677261748140",
	AnimationDuration = 0.4,
	CurrentAnimation = nil,
	StopTimer = nil,
	WasJumping = false,
}

MainModule.play_land_animation_fake_balance = function()
	if not MainModule.JumpRopeFakeBalance.Enabled then
		return
	end
	local v = MainModule.get_character()
	if not v then
		return
	end
	local v2 = MainModule.get_humanoid(v)
	if not v2 then
		return
	end

	if MainModule.JumpRopeFakeBalance.CurrentAnimation then
		pcall(function()
			MainModule.JumpRopeFakeBalance.CurrentAnimation:Stop()
		end)
	end

	if MainModule.JumpRopeFakeBalance.StopTimer then
		MainModule.JumpRopeFakeBalance.StopTimer:Disconnect()
		MainModule.JumpRopeFakeBalance.StopTimer = nil
	end

	local animation = Instance.new("Animation")
	animation.AnimationId = MainModule.JumpRopeFakeBalance.AnimationId
	MainModule.JumpRopeFakeBalance.CurrentAnimation = v2:LoadAnimation(animation)

	pcall(function()
		MainModule.JumpRopeFakeBalance.CurrentAnimation:Play()
	end)

	MainModule.JumpRopeFakeBalance.StopTimer = game:GetService("RunService").Stepped:Connect(function()
		task.wait(MainModule.JumpRopeFakeBalance.AnimationDuration)

		if MainModule.JumpRopeFakeBalance.CurrentAnimation then
			pcall(function()
				MainModule.JumpRopeFakeBalance.CurrentAnimation:Stop()
			end)

			MainModule.JumpRopeFakeBalance.CurrentAnimation = nil
		end

		if MainModule.JumpRopeFakeBalance.StopTimer then
			MainModule.JumpRopeFakeBalance.StopTimer:Disconnect()
			MainModule.JumpRopeFakeBalance.StopTimer = nil
		end
	end)
end

MainModule.setup_jump_rope_fake_balance = function()
	local v = MainModule.get_character()
	if not v then
		return
	end
	local v2 = MainModule.get_humanoid(v)
	if not v2 then
		return
	end
	MainModule.JumpRopeFakeBalance.WasJumping = false

	v2.StateChanged:Connect(function(old, new)
		if not MainModule.JumpRopeFakeBalance.Enabled then
			return
		end

		if new == Enum.HumanoidStateType.Jumping then
			MainModule.JumpRopeFakeBalance.WasJumping = true
		end

		if MainModule.JumpRopeFakeBalance.WasJumping and (new == Enum.HumanoidStateType.Running or new == Enum.HumanoidStateType.Landed or new == Enum.HumanoidStateType.GettingUp) then
			MainModule.play_land_animation_fake_balance()
			MainModule.JumpRopeFakeBalance.WasJumping = false
		end
	end)
end

MainModule.toggle_jump_rope_fake_balance = function(enabled)
	local jumpRopeFakeBalance = MainModule.ToggleRefs.JumpRopeFakeBalance

	if enabled then
		if not MainModule.can_enable_toggle("JumpRope", "Fake Balance", jumpRopeFakeBalance) then
			return false
		end
	end

	if MainModule.JumpRopeFakeBalance.Connection then
		MainModule.JumpRopeFakeBalance.Connection:Disconnect()
		MainModule.JumpRopeFakeBalance.Connection = nil
	end

	if MainModule.JumpRopeFakeBalance.CurrentAnimation then
		pcall(function()
			MainModule.JumpRopeFakeBalance.CurrentAnimation:Stop()
		end)

		MainModule.JumpRopeFakeBalance.CurrentAnimation = nil
	end

	if MainModule.JumpRopeFakeBalance.StopTimer then
		MainModule.JumpRopeFakeBalance.StopTimer:Disconnect()
		MainModule.JumpRopeFakeBalance.StopTimer = nil
	end

	MainModule.JumpRopeFakeBalance.Enabled = enabled

	if enabled then
		MainModule.setup_jump_rope_fake_balance()

		MainModule.JumpRopeFakeBalance.Connection = RunService2.Heartbeat:Connect(function()
			if not MainModule.JumpRopeFakeBalance.Enabled then
				return
			end

			if not MainModule.is_game_active("JumpRope") then
				if MainModule.ToggleRefs.JumpRopeFakeBalance then
					pcall(function()
						MainModule.ToggleRefs.JumpRopeFakeBalance:SetValue(false)
					end)
				end

				MainModule.toggle_jump_rope_fake_balance(false)
				return
			end
		end)
	end

	fn22()
	return true
end

MainModule.disable_rope_objects = function(arg)
	if not arg then
		return
	end

	pcall(function()
		if arg:IsA("MeshPart") or arg:IsA("Part") or arg:IsA("BasePart") then
			arg.CanCollide = false
			arg.CanTouch = false
			arg.CanQuery = false
			arg.Massless = true

			if arg.TouchTransmitter then
				arg.TouchTransmitter:Destroy()
			end
		end

		if arg:IsA("Script") or arg:IsA("LocalScript") or arg:IsA("ModuleScript") then
			local str = arg.Name:lower()

			if str:find("rope") or str:find("jump") or str:find("carry") or str:find("damage") or str:find("hurt") then
				arg.Disabled = true
			end
		end

		if arg:IsA("RopeConstraint") then
			arg:Destroy()
		end

		local name = arg.Name or ""

		if name == "PlayingJumpRope" or name == "RopeCarryPrompt" then
			arg:Destroy()
		end
	end)
end

MainModule.search_and_destroy_rope = function(arg)
	if not arg then
		return
	end

	for _, descendant in pairs(arg:GetDescendants()) do
		if descendant.Name and descendant.Name:lower():find("rope") then
			MainModule.disable_rope_objects(descendant)
		end

		if descendant:IsA("RopeConstraint") then
			MainModule.disable_rope_objects(descendant)
		end

		if descendant.Name == "PlayingJumpRope" or descendant.Name == "RopeCarryPrompt" then
			MainModule.disable_rope_objects(descendant)
		end
	end
end

MainModule.destroy_all_ropes = function()
	MainModule.search_and_destroy_rope(workspace)

	pcall(function()
		MainModule.search_and_destroy_rope(game:GetService("ReplicatedStorage"))
	end)

	pcall(function()
		MainModule.search_and_destroy_rope(game:GetService("ServerStorage"))
	end)

	pcall(function()
		MainModule.search_and_destroy_rope(game:GetService("ServerScriptService"))
	end)

	pcall(function()
		for _, player in pairs(Players2:GetPlayers()) do
			if player.Character then
				MainModule.search_and_destroy_rope(player.Character)
			end

			if player.PlayerGui then
				MainModule.search_and_destroy_rope(player.PlayerGui)
			end
		end
	end)

	MainModule.JumpRopeAntiHit.RopeDestroyed = true
end

MainModule.disable_damage_scripts = function()
	pcall(function()
		local ReplicatedStorage2 = game:GetService("ReplicatedStorage")

		for _, descendant in pairs(ReplicatedStorage2:GetDescendants()) do
			if descendant:IsA("Script") or descendant:IsA("LocalScript") or descendant:IsA("ModuleScript") then
				local str = descendant.Name:lower()

				if str:find("rope") or str:find("jump") or str:find("carry") or str:find("damage") or str:find("hurt") then
					descendant.Disabled = true
				end
			end
		end
	end)

	pcall(function()
		local ServerStorage = game:GetService("ServerStorage")

		for _, descendant in pairs(ServerStorage:GetDescendants()) do
			if descendant:IsA("Script") or descendant:IsA("LocalScript") or descendant:IsA("ModuleScript") then
				local str = descendant.Name:lower()

				if str:find("rope") or str:find("jump") or str:find("carry") or str:find("damage") or str:find("hurt") then
					descendant.Disabled = true
				end
			end
		end
	end)

	pcall(function()
		local ServerScriptService = game:GetService("ServerScriptService")

		for _, descendant in pairs(ServerScriptService:GetDescendants()) do
			if descendant:IsA("Script") or descendant:IsA("LocalScript") or descendant:IsA("ModuleScript") then
				local str = descendant.Name:lower()

				if str:find("rope") or str:find("jump") or str:find("carry") or str:find("damage") or str:find("hurt") then
					descendant.Disabled = true
				end
			end
		end
	end)
end

MainModule.toggle_jump_rope_anti_hit = function(enabled)
	local jumpRopeAntiHit = MainModule.ToggleRefs.JumpRopeAntiHit

	if enabled then
		if not MainModule.can_enable_toggle("JumpRope", "AntiHit", jumpRopeAntiHit) then
			return false
		end
	end

	if MainModule.JumpRopeAntiHit.Connection then
		MainModule.JumpRopeAntiHit.Connection:Disconnect()
		MainModule.JumpRopeAntiHit.Connection = nil
	end

	MainModule.JumpRopeAntiHit.Enabled = enabled
	MainModule.JumpRopeAntiHit.RopeDestroyed = false

	if enabled then
		MainModule.disable_damage_scripts()
		MainModule.destroy_all_ropes()

		MainModule.JumpRopeAntiHit.Connection = RunService2.Heartbeat:Connect(function()
			if not MainModule.JumpRopeAntiHit.Enabled then
				return
			end

			if not MainModule.is_game_active("JumpRope") then
				if MainModule.ToggleRefs.JumpRopeAntiHit then
					pcall(function()
						MainModule.ToggleRefs.JumpRopeAntiHit:SetValue(false)
					end)
				end

				MainModule.toggle_jump_rope_anti_hit(false)
				return
			end

			if not MainModule.JumpRopeAntiHit.RopeDestroyed then
				MainModule.destroy_all_ropes()
			end
		end)
	end

	fn22()
	return true
end

MainModule.ToggleRefs.JumpRopeAntiHit = nil
MainModule.ToggleRefs.JumpRopeFakeBalance = nil

MainModule.ZoneKillFeature = {
	Enabled = false,
	AnimationId = "rbxassetid://105341857343164",
	ZonePosition = Vector3.new(197.7, 54.6, -96.3),
	ReturnDelay = 0.6,
	SavedCFrame = nil,
	ActiveAnimation = false,
	AnimationStartTime = 0,
	AnimationConnection = nil,
	CharacterAddedConnection = nil,
	AnimationStoppedConnections = {},
	AnimationCheckConnection = nil,
	TrackedAnimations = {},
}

MainModule.toggle_zone_kill = function(enabled)
	local zoneKill = MainModule.ToggleRefs.ZoneKill

	if enabled then
		if not MainModule.can_enable_toggle("LastDinner", "Zone Kill", zoneKill) then
			return false
		end
	end

	MainModule.ZoneKillFeature.Enabled = enabled

	if MainModule.ZoneKillFeature.AnimationConnection then
		MainModule.ZoneKillFeature.AnimationConnection:Disconnect()
		MainModule.ZoneKillFeature.AnimationConnection = nil
	end

	if MainModule.ZoneKillFeature.CharacterAddedConnection then
		MainModule.ZoneKillFeature.CharacterAddedConnection:Disconnect()
		MainModule.ZoneKillFeature.CharacterAddedConnection = nil
	end

	if MainModule.ZoneKillFeature.AnimationCheckConnection then
		MainModule.ZoneKillFeature.AnimationCheckConnection:Disconnect()
		MainModule.ZoneKillFeature.AnimationCheckConnection = nil
	end

	for _, animationStoppedConnection in ipairs(MainModule.ZoneKillFeature.AnimationStoppedConnections) do
		pcall(function()
			animationStoppedConnection:Disconnect()
		end)
	end

	MainModule.ZoneKillFeature.AnimationStoppedConnections = {}
	MainModule.ZoneKillFeature.SavedCFrame = nil
	MainModule.ZoneKillFeature.ActiveAnimation = false
	MainModule.ZoneKillFeature.AnimationStartTime = 0
	MainModule.ZoneKillFeature.TrackedAnimations = {}
	if not enabled then
		fn22()
		return true
	end

	local function fn27()
		if not MainModule.ZoneKillFeature.Enabled then
			return
		end
		local v = MainModule.get_character()
		if not v then
			return
		end
		local v2 = MainModule.get_humanoid(v)
		if not v2 then
			return
		end
		local playingAnimationTracks = v2:GetPlayingAnimationTracks()

		for _, playingAnimationTrack in pairs(playingAnimationTracks) do
			if playingAnimationTrack and playingAnimationTrack.Animation then
				local animationId = playingAnimationTrack.Animation.AnimationId

				if animationId and animationId == MainModule.ZoneKillFeature.AnimationId then
					local str = animationId .. "_" .. tostring(playingAnimationTrack)

					if not MainModule.ZoneKillFeature.TrackedAnimations[str] then
						MainModule.ZoneKillFeature.TrackedAnimations[str] = true

						if not MainModule.ZoneKillFeature.ActiveAnimation then
							MainModule.ZoneKillFeature.ActiveAnimation = true
							MainModule.ZoneKillFeature.AnimationStartTime = tick()
							MainModule.ZoneKillFeature.SavedCFrame = v:GetPrimaryPartCFrame()
							v:SetPrimaryPartCFrame(CFrame.new(MainModule.ZoneKillFeature.ZonePosition))

							local connection = playingAnimationTrack.Stopped:Connect(function()
								task.wait(MainModule.ZoneKillFeature.ReturnDelay)

								if MainModule.ZoneKillFeature.SavedCFrame then
									v:SetPrimaryPartCFrame(MainModule.ZoneKillFeature.SavedCFrame)
									MainModule.ZoneKillFeature.SavedCFrame = nil
									MainModule.ZoneKillFeature.ActiveAnimation = false
									MainModule.ZoneKillFeature.TrackedAnimations = {}
								end
							end)

							table.insert(MainModule.ZoneKillFeature.AnimationStoppedConnections, connection)
						end
					end
				end
			end
		end
	end

	local function fn28(arg)
		local humanoid = arg:WaitForChild("Humanoid", 5)
		if not humanoid then
			return
		end

		MainModule.ZoneKillFeature.AnimationConnection = humanoid.AnimationPlayed:Connect(function(arg2)
			if not MainModule.ZoneKillFeature.Enabled then
				return
			end

			if arg2 and arg2.Animation then
				local animationId = arg2.Animation.AnimationId

				if animationId and animationId == MainModule.ZoneKillFeature.AnimationId then
					MainModule.ZoneKillFeature.TrackedAnimations[animationId .. "_" .. tostring(arg2)] = true

					if not MainModule.ZoneKillFeature.ActiveAnimation then
						MainModule.ZoneKillFeature.ActiveAnimation = true
						MainModule.ZoneKillFeature.AnimationStartTime = tick()
						MainModule.ZoneKillFeature.SavedCFrame = arg:GetPrimaryPartCFrame()
						arg:SetPrimaryPartCFrame(CFrame.new(MainModule.ZoneKillFeature.ZonePosition))

						local connection = arg2.Stopped:Connect(function()
							task.wait(MainModule.ZoneKillFeature.ReturnDelay)

							if MainModule.ZoneKillFeature.SavedCFrame then
								arg:SetPrimaryPartCFrame(MainModule.ZoneKillFeature.SavedCFrame)
								MainModule.ZoneKillFeature.SavedCFrame = nil
							end

							MainModule.ZoneKillFeature.ActiveAnimation = false
							MainModule.ZoneKillFeature.TrackedAnimations = {}
						end)

						table.insert(MainModule.ZoneKillFeature.AnimationStoppedConnections, connection)
					end
				end
			end
		end)
	end

	local character = localPlayer2.Character

	if character then
		fn28(character)
	end

	MainModule.ZoneKillFeature.CharacterAddedConnection = localPlayer2.CharacterAdded:Connect(function(character2)
		task.wait(1)
		fn28(character2)
	end)

	MainModule.ZoneKillFeature.AnimationCheckConnection = RunService2.Heartbeat:Connect(function()
		if not MainModule.ZoneKillFeature.Enabled then
			return
		end
		fn27()
	end)

	fn22()
	return true
end

MainModule.VoidKillEnabled = false
MainModule.VoidKillConn = nil
MainModule.VoidKillCharConn = nil
MainModule.VoidAnimIds = { "rbxassetid://107989020363293", "rbxassetid://71619354165195" }
MainModule.VoidZonePos = Vector3.new(-95.1, 964.6, 67.6)

MainModule.toggle_void_kill = function(voidKillEnabled)
	local voidKill = MainModule.ToggleRefs.VoidKill

	if voidKillEnabled then
		if not MainModule.can_enable_toggle("SkySquidGame", "Void Kill", voidKill) then
			return false
		end
	end

	if MainModule.VoidKillConn then
		MainModule.VoidKillConn:Disconnect()
	end

	if MainModule.VoidKillCharConn then
		MainModule.VoidKillCharConn:Disconnect()
	end

	MainModule.VoidKillEnabled = voidKillEnabled

	if voidKillEnabled then
		local function fn27(arg)
			MainModule.VoidKillConn = arg:WaitForChild("Humanoid").AnimationPlayed:Connect(function(arg2)
				if arg2.Animation and table.find(MainModule.VoidAnimIds, arg2.Animation.AnimationId) then
					local primaryPartCFrame = arg:GetPrimaryPartCFrame()
					local part = Instance.new("Part")
					part.Name = HttpService:GenerateGUID(false)
					part.Size = Vector3.new(10, 1, 10)
					part.Position = MainModule.VoidZonePos + Vector3.new(0, -4, 0)
					part.Anchored = true
					part.CanCollide = true
					part.Transparency = 1
					part.Parent = workspace
					arg:SetPrimaryPartCFrame(CFrame.new(MainModule.VoidZonePos.X, MainModule.VoidZonePos.Y, MainModule.VoidZonePos.Z))

					arg2.Stopped:Connect(function()
						task.wait(1)

						if primaryPartCFrame then
							arg:SetPrimaryPartCFrame(primaryPartCFrame)
						end

						part:Destroy()
					end)
				end
			end)
		end

		if localPlayer2.Character then
			fn27(localPlayer2.Character)
		end

		MainModule.VoidKillCharConn = localPlayer2.CharacterAdded:Connect(function(character)
			task.wait(1)
			fn27(character)
		end)
	end

	fn22()
	return true
end

MainModule.MingleVoidKillEnabled = false
MainModule.MingleConns = {}
MainModule.MingleAnimId = "rbxassetid://71318091779666"

MainModule.toggle_mingle_void_kill = function(mingleVoidKillEnabled)
	local mingleVoidKill = MainModule.ToggleRefs.MingleVoidKill

	if mingleVoidKillEnabled then
		if not MainModule.can_enable_toggle("Mingle", "Void Kill", mingleVoidKill) then
			return false
		end
	end

	for _, mingleConn in pairs(MainModule.MingleConns) do
		pcall(function()
			mingleConn:Disconnect()
		end)
	end

	MainModule.MingleConns = {}
	MainModule.MingleVoidKillEnabled = mingleVoidKillEnabled

	if mingleVoidKillEnabled then
		local part = nil

		local function fn27(arg)
			local humanoid = arg:FindFirstChildOfClass("Humanoid") or arg:WaitForChild("Humanoid", 5)
			if not humanoid then
				return
			end

			local connection = humanoid.AnimationPlayed:Connect(function(arg2)
				if not MainModule.MingleVoidKillEnabled then
					return
				end

				if not arg2.Animation then
					return
				end

				if arg2.Animation.AnimationId ~= MainModule.MingleAnimId then
					return
				end
				local humanoidRootPart = arg:FindFirstChild("HumanoidRootPart")
				if not humanoidRootPart then
					return
				end
				local cFrame = humanoidRootPart.CFrame

				if part then
					pcall(function()
						part:Destroy()
					end)

					part = nil
				end

				part = Instance.new("Part")
				part.Name = HttpService:GenerateGUID(false)
				part.Size = Vector3.new(40, 2, 40)
				part.Position = Vector3.new(196.83342, 55.9548, -90.47459) + Vector3.new(0, -3, 0)
				part.Anchored = true
				part.CanCollide = true
				part.Transparency = 1
				part.Parent = workspace
				humanoidRootPart.AssemblyLinearVelocity = Vector3.zero
				humanoidRootPart.CFrame = CFrame.new(Vector3.new(196.83342, 55.9548, -90.47459))

				if arg.PrimaryPart then
					pcall(function()
						arg:SetPrimaryPartCFrame(CFrame.new(Vector3.new(196.83342, 55.9548, -90.47459)))
					end)
				end

				local connection = nil

				connection = arg2.Stopped:Connect(function()
					task.wait(0.6)

					if arg and arg.Parent and MainModule.MingleVoidKillEnabled then
						local humanoidRootPart2 = arg:FindFirstChild("HumanoidRootPart")

						if humanoidRootPart2 then
							humanoidRootPart2.AssemblyLinearVelocity = Vector3.zero
							humanoidRootPart2.CFrame = cFrame

							if arg.PrimaryPart then
								pcall(function()
									arg:SetPrimaryPartCFrame(cFrame)
								end)
							end
						end
					end

					if part then
						pcall(function()
							part:Destroy()
						end)

						part = nil
					end

					if connection then
						connection:Disconnect()
					end
				end)
			end)

			table.insert(MainModule.MingleConns, connection)
		end

		if localPlayer2.Character then
			fn27(localPlayer2.Character)
		end

		table.insert(MainModule.MingleConns, localPlayer2.CharacterAdded:Connect(function(character)
			task.wait(0.5)
			fn27(character)
		end))
	end

	fn22()
	return true
end

MainModule.AutoChokeEnabled = false
MainModule.AutoChokeConnection = nil

MainModule.toggle_auto_choke = function(autoChokeEnabled)
	local autoChoke = MainModule.ToggleRefs.AutoChoke

	if autoChokeEnabled then
		if not MainModule.can_enable_toggle("Mingle", "Auto Choke", autoChoke) then
			return false
		end
	end

	MainModule.AutoChokeEnabled = autoChokeEnabled

	if autoChokeEnabled then
		local impactFrames = localPlayer2.PlayerGui:FindFirstChild("ImpactFrames")

		if impactFrames then
			local tbl7 = {}

			impactFrames.ChildAdded:Connect(function(child)
				if child.Name ~= "OuterRingTemplate" or tbl7[child] then
					return
				end
				tbl7[child] = true

				task.defer(function()
					local v = nil

					for _, child2 in pairs(impactFrames:GetChildren()) do
						if child2.Name == "InnerTemplate" and child2.Position == child.Position and not child2:GetAttribute("Failed") then
							v = child2
							break
						end
					end

					if not v or v:GetAttribute("Tweening") or v:GetAttribute("Failed") then
						return
					end
					local HBGQTE = require(ReplicatedStorage.Modules.HBGQTE)

					pcall(function()
						HBGQTE.Pressed(false, { Inner = v, Outer = child, Duration = 2, StartedAt = tick(), Data = {} })
					end)
				end)
			end)
		end
	end

	fn22()
	return true
end

MainModule.SkySquidAntiFall = { Enabled = false, Platform = nil, Conn = nil }

MainModule.toggle_sky_squid_anti_fall = function(enabled)
	if MainModule.SkySquidAntiFall.Conn then
		MainModule.SkySquidAntiFall.Conn:Disconnect()
	end

	if MainModule.SkySquidAntiFall.Platform then
		MainModule.SkySquidAntiFall.Platform:Destroy()
	end

	MainModule.SkySquidAntiFall.Enabled = enabled

	if enabled then
		local function createPart()
			local v = MainModule.get_character()
			if not v then
				return nil
			end
			local v2 = MainModule.get_root_part(v)
			if not v2 then
				return nil
			end
			local part = Instance.new("Part")
			part.Name = HttpService:GenerateGUID(false)
			part.Size = Vector3.new(10000, 1, 10000)
			part.Position = Vector3.new(v2.Position.X, v2.Position.Y - 5, v2.Position.Z)
			part.Anchored = true
			part.CanCollide = true
			part.Transparency = 0.5
			part.Parent = workspace
			return part
		end

		MainModule.SkySquidAntiFall.Platform = createPart()

		MainModule.SkySquidAntiFall.Conn = RunService2.Heartbeat:Connect(function()
			if not MainModule.SkySquidAntiFall.Enabled then
				return
			end

			if not (MainModule.SkySquidAntiFall.Platform and MainModule.SkySquidAntiFall.Platform.Parent) then
				MainModule.SkySquidAntiFall.Platform = createPart()
			end
		end)
	end

	fn22()
	return true
end

MainModule.FullbrightEnabled = false
MainModule.FullbrightSettings = {}
MainModule.FullbrightConnection = nil

MainModule.toggle_fullbright = function(fullbrightEnabled)
	MainModule.FullbrightEnabled = fullbrightEnabled
	local Lighting = game:GetService("Lighting")

	if fullbrightEnabled then
		MainModule.FullbrightSettings.Brightness = Lighting.Brightness
		MainModule.FullbrightSettings.ClockTime = Lighting.ClockTime
		MainModule.FullbrightSettings.FogEnd = Lighting.FogEnd
		MainModule.FullbrightSettings.GlobalShadows = Lighting.GlobalShadows
		MainModule.FullbrightSettings.OutdoorAmbient = Lighting.OutdoorAmbient
		MainModule.FullbrightSettings.Ambient = Lighting.Ambient
		Lighting.Brightness = 2
		Lighting.ClockTime = 14
		Lighting.FogEnd = 100000
		Lighting.GlobalShadows = false
		Lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128)
		Lighting.Ambient = Color3.fromRGB(255, 255, 255)

		if MainModule.FullbrightConnection then
			MainModule.FullbrightConnection:Disconnect()
		end

		MainModule.FullbrightConnection = Lighting.Changed:Connect(function()
			if not MainModule.FullbrightEnabled then
				return
			end
			Lighting.Brightness = 2
			Lighting.ClockTime = 14
			Lighting.FogEnd = 100000
			Lighting.GlobalShadows = false
			Lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128)
			Lighting.Ambient = Color3.fromRGB(255, 255, 255)
		end)
	else
		for k, fullbrightSetting in pairs(MainModule.FullbrightSettings) do
			pcall(function()
				Lighting[k] = fullbrightSetting
			end)
		end

		if MainModule.FullbrightConnection then
			MainModule.FullbrightConnection:Disconnect()
			MainModule.FullbrightConnection = nil
		end
	end

	fn22()
end

MainModule.AutoCollectBandage = false
MainModule.AutoCollectBandageConnection = nil

MainModule.has_tool = function(arg)
	local v = MainModule.get_character()

	if v then
		for _, child in pairs(v:GetChildren()) do
			if child:IsA("Tool") and child.Name == arg then
				return true
			end
		end
	end

	local backpack = localPlayer2:FindFirstChild("Backpack")

	if backpack then
		for _, child in pairs(backpack:GetChildren()) do
			if child:IsA("Tool") and child.Name == arg then
				return true
			end
		end
	end

	return false
end

MainModule.start_auto_collect_bandage = function()
	if MainModule.AutoCollectBandageConnection then
		MainModule.AutoCollectBandageConnection:Disconnect()
		MainModule.AutoCollectBandageConnection = nil
	end

	MainModule.AutoCollectBandageConnection = RunService2.Heartbeat:Connect(function()
		if not MainModule.AutoCollectBandage then
			return
		end

		if not MainModule.has_tool("Bandage") and localPlayer2.Character and localPlayer2.Character:FindFirstChild("HumanoidRootPart") then
			local effects = workspace:FindFirstChild("Effects")

			if effects then
				for _, child in pairs(effects:GetChildren()) do
					if child.Name == "DroppedBandage" and child:FindFirstChild("Handle") then
						local cFrame = localPlayer2.Character.HumanoidRootPart.CFrame
						localPlayer2.Character.HumanoidRootPart.CFrame = child.Handle.CFrame
						task.wait(0.3)

						if localPlayer2.Character and localPlayer2.Character:FindFirstChild("HumanoidRootPart") then
							localPlayer2.Character.HumanoidRootPart.CFrame = cFrame
						end

						break
					end
				end
			end
		end
	end)
end

MainModule.toggle_auto_collect_bandage = function(autoCollectBandage)
	MainModule.AutoCollectBandage = autoCollectBandage

	if autoCollectBandage then
		MainModule.start_auto_collect_bandage()
	elseif MainModule.AutoCollectBandageConnection then
		MainModule.AutoCollectBandageConnection:Disconnect()
		MainModule.AutoCollectBandageConnection = nil
	end

	fn22()
end

MainModule.RLGLEndCorner = MainModule.RLGLEndCorner or "Left Corner"

MainModule.RLGLEndPositions = {
	["Left Corner"] = Vector3.new(110, 1023, 133),
	["Right Corner"] = Vector3.new(-214.4, 1023.1, 146.7),
}

MainModule.rlgl_tp_end = function()
	if MainModule.is_game_active("RedLightGreenLight") then
		local rlglEndCorner = MainModule.RLGLEndCorner or "Left Corner"
		MainModule.safe_teleport(MainModule.RLGLEndPositions and MainModule.RLGLEndPositions[rlglEndCorner] or Vector3.new(110, 1023, 133))
		MainModule.notify("RLGL", "Teleported to " .. tostring(rlglEndCorner), 0.9)
	else
		MainModule.notify("RLGL", "Wait for RedLightGreenLight!", 0.9)
		PlayErrorSound()
	end
end

MainModule.GodModeEnabled = false
MainModule.GodModeConn = nil
MainModule.GodModeOrigY = nil

MainModule.toggle_god_mode = function(arg)
	local godMode = MainModule.ToggleRefs.GodMode

	if arg then
		if not MainModule.can_enable_toggle("RedLightGreenLight", "God Mode", godMode) then
			return false
		end
	end

	if arg then
		if MainModule.GodModeConn then
			MainModule.GodModeConn:Disconnect()
			MainModule.GodModeConn = nil
		end

		MainModule.GodModeEnabled = true
		local v = MainModule.get_character()

		if not v then
			MainModule.notify("GodMode", "Character not found", 0.9)
			PlayErrorSound()
			MainModule.GodModeEnabled = false
			return false
		end

		local humanoidRootPart = v:FindFirstChild("HumanoidRootPart") or v.PrimaryPart

		if humanoidRootPart then
			MainModule.GodModeOrigY = humanoidRootPart.Position.Y
			MainModule.safe_teleport(Vector3.new(humanoidRootPart.Position.X, humanoidRootPart.Position.Y + 170, humanoidRootPart.Position.Z))
		end

		MainModule.GodModeConn = RunService2.Heartbeat:Connect(function()
			if MainModule.GodModeEnabled and not MainModule.is_game_active("RedLightGreenLight") then
				MainModule.disable_toggle("GodMode")
			end
		end)
	else
		MainModule.GodModeEnabled = false

		if MainModule.GodModeConn then
			MainModule.GodModeConn:Disconnect()
			MainModule.GodModeConn = nil
		end

		if MainModule.GodModeOrigY then
			local v = MainModule.get_character()

			if v then
				local humanoidRootPart = v:FindFirstChild("HumanoidRootPart")

				if humanoidRootPart then
					MainModule.safe_teleport(Vector3.new(humanoidRootPart.Position.X, MainModule.GodModeOrigY, humanoidRootPart.Position.Z))
				end
			end
		end

		MainModule.GodModeOrigY = nil
	end

	fn22()
	return true
end

MainModule.RageAutoQTEEnabled = false
MainModule.RageAutoQTELoop = nil

MainModule.toggle_rage_auto_qte = function(rageAutoQTEEnabled)
	local rageAutoQTE = MainModule.ToggleRefs.RageAutoQTE

	if rageAutoQTEEnabled then
		if MainModule.is_xeno_executor() then
			MainModule.notify("RAGE Auto QTE", "Not supported in your executor", 0.9)
			PlayErrorSound()

			if rageAutoQTE and rageAutoQTE.SetValue then
				pcall(function()
					rageAutoQTE:SetValue(false)
				end)
			end

			return false
		end
	end

	MainModule.RageAutoQTEEnabled = rageAutoQTEEnabled

	if MainModule.RageAutoQTELoop then
		task.cancel(MainModule.RageAutoQTELoop)
		MainModule.RageAutoQTELoop = nil
	end

	if rageAutoQTEEnabled then
		MainModule.RageAutoQTELoop = task.spawn(function()
			local ok, result = pcall(function()
				return require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("HBGQTE"))
			end)

			if ok then
				local v = result

				while MainModule.RageAutoQTEEnabled do
					task.wait(0.05)

					pcall(function()
						if v and v.ActiveButtons then
							for _, activeButton in pairs(v.ActiveButtons) do
								if activeButton and activeButton.Inner and activeButton.Outer and not activeButton.Inner:GetAttribute("Tweening") and not activeButton.Inner:GetAttribute("Failed") then
									pcall(function()
										v.Pressed(false, activeButton)
									end)
								end
							end
						end
					end)
				end

				return
			end

			MainModule.notify("RAGE Auto QTE", "Failed to load QTE module", 0.9)
			PlayErrorSound()
			MainModule.RageAutoQTEEnabled = false

			if rageAutoQTE and rageAutoQTE.SetValue then
				pcall(function()
					rageAutoQTE:SetValue(false)
				end)
			end
		end)

		fn22()
	else
		fn22()
	end

	return true
end

MainModule.RemoveInjuryEnabled = false
MainModule.RemoveInjuryConn = nil

local tbl7 = {
	Stun = true,
	stunned = true,
	Stunned = true,
	crawl = true,
	Crawl = true,
	crawled = true,
	Crawled = true,
	crawling = true,
	Crawling = true,
}

local function fn27()
	local character = localPlayer2.Character
	if not character then
		return
	end

	for _, descendant in ipairs(character:GetDescendants()) do
		if tbl7[descendant.Name] then
			pcall(function()
				descendant:Destroy()
			end)
		end
	end

	local humanoid = character:FindFirstChildOfClass("Humanoid")

	if humanoid then
		pcall(function()
			for _, v in ipairs(humanoid:GetPlayingAnimationTracks()) do
				if v.Animation then
				end
			end
		end)
	end
end

MainModule.remove_injury_objects = function()
	fn27()
end

MainModule.toggle_remove_injury = function(arg)
	MainModule.RemoveInjuryEnabled = arg and true or false

	if MainModule.RemoveInjuryConn then
		pcall(function()
			MainModule.RemoveInjuryConn:Disconnect()
		end)

		MainModule.RemoveInjuryConn = nil
	end

	if MainModule.RemoveInjuryEnabled then
		fn27()

		MainModule.RemoveInjuryConn = RunService2.Heartbeat:Connect(function()
			if not MainModule.RemoveInjuryEnabled then
				return
			end

			if not MainModule._injury_last then
				MainModule._injury_last = 0
			end

			local injuryLast = MainModule._injury_last
			if tick() - injuryLast < 1 then
				return
			end
			MainModule._injury_last = tick()
			fn27()
		end)
	end

	fn22()
end

MainModule = MainModule or {}

MainModule.FireHotbarTool = function(arg)
	local localPlayer3 = Players2.LocalPlayer
	if not localPlayer3 then
		return false
	end
	local backpack = localPlayer3:FindFirstChild("Backpack")
	if not backpack then
		return false
	end
	local v = backpack:FindFirstChild(arg)

	if not v then
		local character = localPlayer3.Character
		v = character and character:FindFirstChild(arg)
	end

	if not v then
		return false
	end
	local hotbar = localPlayer3.PlayerGui:FindFirstChild("Hotbar")
	if not hotbar then
		return false
	end
	local backpack2 = hotbar:FindFirstChild("Backpack")
	backpack2 = backpack2 and backpack2:FindFirstChild("Hotbar")
	if not backpack2 then
		return false
	end
	local v2 = nil

	for _, child in pairs(backpack2:GetChildren()) do
		local toolName = child:FindFirstChild("ToolName")
		if toolName and toolName.Text == arg then
			v2 = child
			break
		end
	end

	if not v2 or not getconnections then
		return false
	end

	pcall(function()
		for _, v3 in pairs(getconnections(v2.MouseButton1Down)) do
			pcall(function()
				v3:Fire()
			end)
		end

		task.wait(0.05)

		for _, v3 in pairs(getconnections(v2.MouseButton1Up)) do
			pcall(function()
				v3:Fire()
			end)
		end
	end)

	return true
end

MainModule = MainModule or {}

MainModule.EnsureFakeUltraInstinct = function()
	if type(MainModule.FakeUltraInstinct) ~= "table" then
		MainModule.FakeUltraInstinct = {}
	end

	local fakeUltraInstinct = MainModule.FakeUltraInstinct

	if fakeUltraInstinct.MaxDodges == nil then
		fakeUltraInstinct.MaxDodges = 10
	end

	if fakeUltraInstinct.Dodges == nil then
		fakeUltraInstinct.Dodges = 10
	end

	if fakeUltraInstinct.Cooldown == nil then
		fakeUltraInstinct.Cooldown = false
	end

	if fakeUltraInstinct.Equipped == nil then
		fakeUltraInstinct.Equipped = false
	end

	if fakeUltraInstinct.AnimPlaying == nil then
		fakeUltraInstinct.AnimPlaying = false
	end

	if fakeUltraInstinct.Enabled == nil then
		fakeUltraInstinct.Enabled = false
	end

	if fakeUltraInstinct.SoundId == nil then
		fakeUltraInstinct.SoundId = "rbxassetid://6732929006"
	end

	if type(fakeUltraInstinct.DodgeLabels) ~= "table" then
		fakeUltraInstinct.DodgeLabels = {}
	end

	if type(fakeUltraInstinct.Connections) ~= "table" then
		fakeUltraInstinct.Connections = {}
	end

	if type(fakeUltraInstinct.FXMap) ~= "table" then
		fakeUltraInstinct.FXMap = { 1, 2, 1, 2, 1 }
	end

	return fakeUltraInstinct
end

MainModule.FUIGetPlayer = function()
	return game:GetService("Players").LocalPlayer
end

MainModule.FUIGetEffects = function()
	local v = MainModule.EnsureFakeUltraInstinct()
	if v.UIDodgeEffects then
		return v.UIDodgeEffects
	end

	local ok, uiDodgeEffects = pcall(function()
		local modules = game:GetService("ReplicatedStorage"):FindFirstChild("Modules")
		if not modules then
			return nil
		end
		local abilityEffectsModules = modules:FindFirstChild("AbilityEffectsModules")
		if not abilityEffectsModules then
			return nil
		end
		local uiDodgeCLIENTEFFECTS = abilityEffectsModules:FindFirstChild("UIDodgeCLIENTEFFECTS")
		if not uiDodgeCLIENTEFFECTS then
			return nil
		end
		return require(uiDodgeCLIENTEFFECTS)
	end)

	if ok and type(uiDodgeEffects) == "function" then
		v.UIDodgeEffects = uiDodgeEffects
		return uiDodgeEffects
	end
	return nil
end

MainModule.FUIGetAnimFolder = function()
	local v = MainModule.EnsureFakeUltraInstinct()
	if v.AnimFolder and v.AnimFolder.Parent then
		return v.AnimFolder
	end

	local ok, animFolder = pcall(function()
		local animations = game:GetService("ReplicatedStorage"):FindFirstChild("Animations")
		if not animations then
			return nil
		end
		local abilities = animations:FindFirstChild("Abilities")
		if not abilities then
			return nil
		end
		return abilities:FindFirstChild("UltraInstinct")
	end)

	if ok and animFolder then
		v.AnimFolder = animFolder
		return animFolder
	end
	return nil
end

MainModule.FUIGetChar = function()
	local v = MainModule.FUIGetPlayer()
	if not v then
		return nil
	end
	return v.Character
end

MainModule.FUIGetAnimator = function()
	local v = MainModule.FUIGetChar()
	if not v then
		return nil
	end
	local humanoid = v:FindFirstChildOfClass("Humanoid")
	if not humanoid then
		return nil
	end
	local animator = humanoid:FindFirstChildOfClass("Animator")

	if not animator then
		animator = Instance.new("Animator")
		animator.Parent = humanoid
	end

	return animator
end

MainModule.FUIGetAnimations = function()
	local v = MainModule.FUIGetAnimFolder()
	if not v then
		return {}
	end
	local tbl8 = {}

	for _, child in ipairs(v:GetChildren()) do
		if child:IsA("Animation") and child.AnimationId ~= "" then
			table.insert(tbl8, child)
		end
	end

	return tbl8
end

MainModule.FUIStageOf = function(arg)
	if not arg then
		return 1
	end
	return tonumber(tostring(arg.Name):match("%d+")) or 1
end

MainModule.FUIPlayAura = function()
	local v = MainModule.FUIGetEffects()
	if not v then
		return
	end
	local v2 = MainModule.FUIGetChar()
	if not v2 then
		return
	end

	pcall(function()
		v({ ModuleName = "UIDodge", Character = v2, initial = true })
	end)
end

MainModule.FUIPlayDodgeFX = function(arg)
	local v = MainModule.FUIGetEffects()
	if not v then
		return
	end
	local v2 = MainModule.FUIGetChar()
	if not v2 then
		return
	end

	pcall(function()
		v({ ModuleName = "UIDodge", Character = v2, dodgenumber = arg, initial = false })
	end)
end

MainModule.FUIPlaySound = function()
	local v = MainModule.EnsureFakeUltraInstinct()
	local v2 = MainModule.FUIGetChar()
	if not v2 then
		return
	end
	local humanoidRootPart = v2:FindFirstChild("HumanoidRootPart") or v2:FindFirstChild("Head")
	if not humanoidRootPart then
		return
	end
	local sound = Instance.new("Sound")
	sound.Name = "FakeUltraInstinctSound"
	sound.SoundId = v.SoundId
	sound.Volume = 1.5
	sound.RollOffMaxDistance = 120
	sound.Parent = humanoidRootPart

	pcall(function()
		sound:Play()
	end)

	sound.Ended:Once(function()
		sound:Destroy()
	end)
end

MainModule.FUIFindLabels = function(arg)
	local tbl8 = {}
	if not arg then
		return tbl8
	end

	for _, descendant in ipairs(arg:GetDescendants()) do
		if descendant:IsA("TextLabel") or descendant:IsA("TextButton") then
			local str = tostring(descendant.Text)

			if str:find("%d+%s*/%s*%d+") or str:lower():find("dodge") then
				table.insert(tbl8, descendant)
			end
		end
	end

	return tbl8
end

MainModule.FUISetupPanel = function()
	local v = MainModule.EnsureFakeUltraInstinct()
	if v.Panel and v.Panel.Parent then
		return
	end
	local v2 = MainModule.FUIGetPlayer()
	if not v2 then
		return
	end
	local playerGui = v2:FindFirstChild("PlayerGui")
	if not playerGui then
		return
	end
	local powerUIDodges = playerGui:FindFirstChild("PowerUIDodges")
	if not powerUIDodges then
		return
	end
	v.OriginalPanel = powerUIDodges

	pcall(function()
		if powerUIDodges:IsA("ScreenGui") then
			powerUIDodges.Enabled = false
		end
	end)

	local clone = powerUIDodges:Clone()
	clone.Name = "FakeUltraInstinctDodges"

	for _, descendant in ipairs(clone:GetDescendants()) do
		if descendant:IsA("LocalScript") or descendant:IsA("Script") then
			descendant:Destroy()
		end
	end

	local v3

	if type(gethui) == "function" then
		local ok, result = pcall(gethui)

		if ok and result then
			v3 = result
		else
			v3 = playerGui
		end
	else
		v3 = playerGui
	end

	clone.Parent = v3

	if clone:IsA("ScreenGui") then
		clone.Enabled = true
		clone.ResetOnSpawn = false
	end

	v.Panel = clone
	v.DodgeLabels = MainModule.FUIFindLabels(clone)
	MainModule.FUIUpdatePanel()
end

MainModule.FUIUpdatePanel = function()
	local v = MainModule.EnsureFakeUltraInstinct()
	if not v.Panel or not v.Panel.Parent then
		return
	end
	local text = string.format("Dodges Left: %d/%d", v.Dodges, v.MaxDodges)

	for _, dodgeLabel in ipairs(v.DodgeLabels) do
		if dodgeLabel and dodgeLabel.Parent then
			pcall(function()
				dodgeLabel.Text = text
			end)
		end
	end
end

MainModule.FUIConsumeDodge = function()
	local v = MainModule.EnsureFakeUltraInstinct()
	v.Dodges = math.max(v.Dodges - 1, 0)
	MainModule.FUIUpdatePanel()

	if v.Dodges <= 0 then
		task.delay(0.35, function()
			local v2 = MainModule.EnsureFakeUltraInstinct()
			if not v2.Enabled then
				return
			end
			v2.Dodges = v2.MaxDodges
			MainModule.FUIUpdatePanel()
		end)
	end
end

MainModule.FUIStopAnim = function()
	local v = MainModule.EnsureFakeUltraInstinct()

	if v.CurrentTrack then
		pcall(function()
			v.CurrentTrack:Stop(0.1)
			v.CurrentTrack:Destroy()
		end)
	end

	v.CurrentTrack = nil
	v.AnimPlaying = false
end

MainModule.FUIPlayAll = function(arg)
	local v = MainModule.EnsureFakeUltraInstinct()
	if not v.Enabled then
		return
	end
	local v2 = MainModule.FUIGetAnimations()
	if #v2 == 0 then
		return
	end
	local v3

	if #v2 == 1 then
		v3 = v2[1]
	else
		local n = 0

		while true do
			v3 = v2[math.random(1, #v2)]
			n += 1
			if not (v3 ~= v.LastAnim or n > 10) then
				continue
			end
			break
		end
	end

	v.LastAnim = v3
	local n = v.FXMap[MainModule.FUIStageOf(v3)] or math.random(1, 2)
	MainModule.FUIStopAnim()
	local v4 = MainModule.FUIGetAnimator()

	if v4 then
		local ok, currentTrack = pcall(function()
			return v4:LoadAnimation(v3)
		end)

		if ok and currentTrack then
			v.AnimPlaying = true
			v.CurrentTrack = currentTrack
			currentTrack.Priority = Enum.AnimationPriority.Action4
			currentTrack.Looped = false

			pcall(function()
				currentTrack:Play(0.05, 1, 1)
			end)

			currentTrack.Stopped:Once(function()
				local v5 = MainModule.EnsureFakeUltraInstinct()

				if v5.CurrentTrack == currentTrack then
					pcall(function()
						currentTrack:Destroy()
					end)

					v5.CurrentTrack = nil
					v5.AnimPlaying = false
				end
			end)
		end
	end

	task.spawn(MainModule.FUIPlayAura)

	task.spawn(function()
		MainModule.FUIPlayDodgeFX(n)
	end)

	task.spawn(MainModule.FUIPlaySound)

	if arg then
		MainModule.FUIConsumeDodge()
	end
end

MainModule.FUIDoDodge = function()
	local v = MainModule.EnsureFakeUltraInstinct()
	if not v.Enabled then
		return
	end

	if v.Cooldown then
		return
	end
	v.Cooldown = true
	MainModule.FUIPlayAll(true)

	task.delay(0.35, function()
		MainModule.EnsureFakeUltraInstinct().Cooldown = false
	end)
end

MainModule.FUICreateTool = function()
	local v = MainModule.EnsureFakeUltraInstinct()
	if not v.Enabled then
		return
	end

	if v.Tool and v.Tool.Parent then
		return
	end
	local v2 = MainModule.FUIGetPlayer()
	if not v2 then
		return
	end
	local backpack = v2:FindFirstChildOfClass("Backpack") or v2:WaitForChild("Backpack", 5)
	if not backpack then
		return
	end
	local ultraInstinct = backpack:FindFirstChild("Ultra Instinct")
	local ultraInstinct2

	if ultraInstinct then
		ultraInstinct2 = ultraInstinct
	else
		ultraInstinct2 = v2.Character and v2.Character:FindFirstChild("Ultra Instinct")
	end

	if ultraInstinct2 then
		pcall(function()
			ultraInstinct2:Destroy()
		end)
	end

	local tool = Instance.new("Tool")
	tool.Name = "Ultra Instinct"
	tool.RequiresHandle = false
	tool.CanBeDropped = false
	tool.ToolTip = "Ultra Instinct"
	tool.Parent = backpack
	v.Tool = tool

	table.insert(v.Connections, tool.Equipped:Connect(function()
		local v3 = MainModule.EnsureFakeUltraInstinct()
		if not v3.Enabled then
			return
		end
		v3.Equipped = true
		MainModule.FUISetupPanel()
		task.wait(0.1)
		MainModule.FUIDoDodge()
	end))

	table.insert(v.Connections, tool.Unequipped:Connect(function()
		MainModule.EnsureFakeUltraInstinct().Equipped = false
		MainModule.FUIStopAnim()
	end))

	table.insert(v.Connections, tool.Activated:Connect(function()
		task.wait(0.2)
		MainModule.FUIDoDodge()
	end))
end

MainModule.FUIDestroy = function()
	local v = MainModule.EnsureFakeUltraInstinct()
	v.Enabled = false
	v.Equipped = false
	v.Cooldown = false
	MainModule.FUIStopAnim()

	for _, connection in ipairs(v.Connections) do
		pcall(function()
			connection:Disconnect()
		end)
	end

	table.clear(v.Connections)

	if v.Tool then
		pcall(function()
			v.Tool:Destroy()
		end)

		v.Tool = nil
	end

	if v.Panel then
		pcall(function()
			v.Panel:Destroy()
		end)

		v.Panel = nil
	end

	if v.OriginalPanel then
		pcall(function()
			if v.OriginalPanel:IsA("ScreenGui") then
				v.OriginalPanel.Enabled = true
			end
		end)

		v.OriginalPanel = nil
	end

	v.DodgeLabels = {}
	v.Dodges = v.MaxDodges
end

MainModule.toggle_fake_ultra_instinct = function(arg)
	local v = MainModule.EnsureFakeUltraInstinct()

	if arg == true then
		if v.Enabled then
			return
		end
		v.Enabled = true
		v.Dodges = v.MaxDodges
		MainModule.FUICreateTool()
	else
		MainModule.FUIDestroy()
	end
end

local v = MainModule.EnsureFakeUltraInstinct()

if v.CharacterConnection then
	pcall(function()
		v.CharacterConnection:Disconnect()
	end)
end

local v2 = MainModule.FUIGetPlayer()

if v2 then
	v.CharacterConnection = v2.CharacterAdded:Connect(function()
		task.wait(1)
		local v3 = MainModule.EnsureFakeUltraInstinct()
		v3.Equipped = false
		v3.Cooldown = false
		v3.AnimPlaying = false
		v3.Dodges = v3.MaxDodges
		v3.Tool = nil
		v3.Panel = nil
		v3.DodgeLabels = {}
		MainModule.FUIStopAnim()

		if v3.Enabled then
			MainModule.FUICreateTool()
		end
	end)
end

MainModule.PhantomDashEnabled = false
MainModule.PhantomDashKeybind = Enum.KeyCode.Q
MainModule.PhantomDashDistance = 15
MainModule.PhantomDashDuration = 0.25
MainModule.PhantomDashCooldown = 1
MainModule.PhantomDashMaxCharges = 2
MainModule.PhantomDashCurrentCharges = 2
MainModule.PhantomDashIsMoving = false
MainModule.PhantomDashSoundId = "rbxassetid://94904871279766"
MainModule.PhantomDashBackwardSoundId = "rbxassetid://99068532205349"

MainModule.PhantomDashTextures = {
	"http://www.roblox.com/asset/?id=122158926856615",
	"http://www.roblox.com/asset/?id=14005913529",
	"http://www.roblox.com/asset/?id=17888919056",
	"http://www.roblox.com/asset/?id=14695179076",
	"http://www.roblox.com/asset/?id=15431126240",
	"http://www.roblox.com/asset/?id=14045123768",
}

MainModule.PhantomDashConnection = nil
MainModule.PhantomDashKeybindConnection = nil
MainModule.PhantomDashMobileGui = nil
MainModule.PhantomDashRechargeThread = nil

local function fn28(parent)
	local tbl8 = {}

	for i, phantomDashTexture in ipairs(MainModule.PhantomDashTextures) do
		local particleEmitter = Instance.new("ParticleEmitter")
		particleEmitter.Name = "DashDiagonalCluster_" .. i
		particleEmitter.Texture = phantomDashTexture
		particleEmitter.Color = ColorSequence.new(Color3.new(0, 0, 0))
		particleEmitter.LightEmission = 0
		particleEmitter.LightInfluence = 0
		particleEmitter.Brightness = 1
		particleEmitter.LockedToPart = false
		particleEmitter.Orientation = Enum.ParticleOrientation.FacingCamera
		particleEmitter.Rotation = NumberRange.new(45, 45)
		particleEmitter.RotSpeed = NumberRange.new(0, 0)
		particleEmitter.Speed = NumberRange.new(1, 5)
		particleEmitter.SpreadAngle = Vector2.new(20, 20)
		particleEmitter.Lifetime = NumberRange.new(0.3, 0.6)
		particleEmitter.ZOffset = 1
		local numberSequence = NumberSequence.new
		local tbl9 = {}
		local v3 = NumberSequenceKeypoint.new(0, 3.5)
		local v4 = NumberSequenceKeypoint.new(0.5, 6)
		local new = NumberSequenceKeypoint.new
		tbl9[1] = v3
		tbl9[2] = v4

		do
			local values = table.pack(new(1, 0))
			table.move(values, 1, values.n, 3, tbl9)
		end

		particleEmitter.Size = numberSequence(tbl9)
		local numberSequence2 = NumberSequence.new
		local tbl10 = {}
		local v5 = NumberSequenceKeypoint.new(0, 0)
		local v6 = NumberSequenceKeypoint.new(0.6, 0.4)
		local new2 = NumberSequenceKeypoint.new
		tbl10[1] = v5
		tbl10[2] = v6

		do
			local values = table.pack(new2(1, 1))
			table.move(values, 1, values.n, 3, tbl10)
		end

		particleEmitter.Transparency = numberSequence2(tbl10)
		particleEmitter.Parent = parent
		table.insert(tbl8, particleEmitter)
	end

	return tbl8
end

local function fn29()
	if MainModule.PhantomDashRechargeThread then
		task.cancel(MainModule.PhantomDashRechargeThread)
	end

	MainModule.PhantomDashRechargeThread = task.spawn(function()
		while MainModule.PhantomDashCurrentCharges < MainModule.PhantomDashMaxCharges do
			task.wait(MainModule.PhantomDashCooldown)
			MainModule.PhantomDashCurrentCharges = math.min(MainModule.PhantomDashMaxCharges, MainModule.PhantomDashCurrentCharges + 1)
		end

		MainModule.PhantomDashRechargeThread = nil
	end)
end

local function fn30()
	if MainModule.PhantomDashIsMoving or MainModule.PhantomDashCurrentCharges <= 0 then
		return
	end
	local v3 = MainModule.get_character()
	if not v3 then
		return
	end
	local v4 = MainModule.get_root_part(v3)
	local v5 = MainModule.get_humanoid(v3)
	if not v4 or not v5 then
		return
	end
	MainModule.PhantomDashIsMoving = true
	local flag2 = MainModule.PhantomDashCurrentCharges == MainModule.PhantomDashMaxCharges
	MainModule.PhantomDashCurrentCharges = MainModule.PhantomDashCurrentCharges - 1

	if flag2 then
		fn29()
	end

	local moveDirection = v5.MoveDirection
	local lookVector = v4.CFrame.LookVector
	local soundId

	if moveDirection.Magnitude > 0 then
		local flag3 = moveDirection:Dot(v4.CFrame.LookVector) < -0.2 or UserInputService:IsKeyDown(Enum.KeyCode.S)
		soundId = false

		if flag3 then
			moveDirection = -v4.CFrame.LookVector
			soundId = true
		end
	else
		soundId = false

		if UserInputService:IsKeyDown(Enum.KeyCode.S) then
			moveDirection = -v4.CFrame.LookVector
			soundId = true
		else
			moveDirection = lookVector
		end
	end

	soundId = soundId and MainModule.PhantomDashBackwardSoundId or MainModule.PhantomDashSoundId
	local sound = Instance.new("Sound")
	sound.SoundId = soundId
	sound.Volume = 1.5
	sound.Parent = v4
	sound:Play()

	task.delay(3, function()
		sound:Destroy()
	end)

	local v6 = fn28(v4)

	for _, v7 in ipairs(v6) do
		v7.Rate = 110
		v7.Enabled = true
	end

	local n = v4.CFrame + moveDirection * MainModule.PhantomDashDistance
	TweenService:Create(v4, TweenInfo.new(MainModule.PhantomDashDuration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { CFrame = n }):Play()
	task.wait(MainModule.PhantomDashDuration)

	for _, v7 in ipairs(v6) do
		v7.Enabled = false

		task.delay(1.2, function()
			v7:Destroy()
		end)
	end

	MainModule.PhantomDashIsMoving = false
end

local function fn31()
	if MainModule.PhantomDashMobileGui then
		MainModule.PhantomDashMobileGui:Destroy()
		MainModule.PhantomDashMobileGui = nil
	end

	local playerGui = localPlayer2:FindFirstChild("PlayerGui")
	if not playerGui then
		return
	end
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = HttpService:GenerateGUID(false)
	screenGui.ResetOnSpawn = false
	screenGui.Parent = playerGui
	local textButton = Instance.new("TextButton")
	textButton.Name = HttpService:GenerateGUID(false)
	textButton.Size = UDim2.new(0, 70, 0, 70)
	textButton.Position = UDim2.new(0.8, -35, 0.6, -35)
	textButton.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	textButton.Text = "Dash"
	textButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	textButton.Font = Enum.Font.GothamBold
	textButton.TextSize = 16
	textButton.Active = true
	textButton.Parent = screenGui
	local uiCorner = Instance.new("UICorner")
	uiCorner.CornerRadius = UDim.new(0, 12)
	uiCorner.Parent = textButton
	local uiStroke = Instance.new("UIStroke")
	uiStroke.Thickness = 2
	uiStroke.Color = Color3.fromRGB(0, 0, 0)
	uiStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual
	uiStroke.Parent = textButton
	local flag2 = false
	local position = nil
	local position2 = nil
	local flag3 = false

	textButton.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
			flag2 = true
			flag3 = false
			position = input.Position
			position2 = textButton.Position

			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					flag2 = false
				end
			end)
		end
	end)

	textButton.InputChanged:Connect(function(input)
		local flag4 = flag2

		if flag2 then
			flag4 = input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement
		end

		if flag4 then
			local n = input.Position - position

			if n.Magnitude > 5 then
				flag3 = true
			end

			textButton.Position = UDim2.new(position2.X.Scale, position2.X.Offset + n.X, position2.Y.Scale, position2.Y.Offset + n.Y)
		end
	end)

	textButton.MouseButton1Click:Connect(function()
		if not flag3 then
			fn30()
		end
	end)

	MainModule.PhantomDashMobileGui = screenGui
end

MainModule.toggle_phantom_dash = function(phantomDashEnabled)
	MainModule.PhantomDashEnabled = phantomDashEnabled

	if MainModule.PhantomDashConnection then
		MainModule.PhantomDashConnection:Disconnect()
		MainModule.PhantomDashConnection = nil
	end

	if MainModule.PhantomDashKeybindConnection then
		MainModule.PhantomDashKeybindConnection:Disconnect()
		MainModule.PhantomDashKeybindConnection = nil
	end

	if MainModule.PhantomDashMobileGui then
		MainModule.PhantomDashMobileGui:Destroy()
		MainModule.PhantomDashMobileGui = nil
	end

	if MainModule.PhantomDashRechargeThread then
		task.cancel(MainModule.PhantomDashRechargeThread)
		MainModule.PhantomDashRechargeThread = nil
	end

	MainModule.PhantomDashCurrentCharges = MainModule.PhantomDashMaxCharges
	MainModule.PhantomDashIsMoving = false

	if phantomDashEnabled then
		if MainModule.is_mobile() then
			fn31()
		else
			MainModule.PhantomDashKeybindConnection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
				if gameProcessed then
					return
				end

				if input.KeyCode == MainModule.PhantomDashKeybind then
					fn30()
				end
			end)
		end
	end

	fn22()
end

MainModule.set_phantom_dash_keybind = function(phantomDashKeybind)
	MainModule.PhantomDashKeybind = phantomDashKeybind
end

MainModule.set_phantom_dash_distance = function(phantomDashDistance)
	MainModule.PhantomDashDistance = phantomDashDistance
end

MainModule.set_phantom_dash_duration = function(arg)
	MainModule.PhantomDashDuration = arg / 100
end

MainModule.set_phantom_dash_cooldown = function(phantomDashCooldown)
	MainModule.PhantomDashCooldown = phantomDashCooldown
end

MainModule.set_phantom_dash_max_charges = function(phantomDashMaxCharges)
	MainModule.PhantomDashMaxCharges = phantomDashMaxCharges
	MainModule.PhantomDashCurrentCharges = phantomDashMaxCharges
end

MainModule.RLGLEnabled = false
MainModule.RLGLConnection = nil
MainModule.RLGLOriginalWalkSpeed = 16
MainModule.RLGLOriginalJumpPower = 50
MainModule.RLGLOriginalJumpHeight = 7.2
MainModule.RLGLWasFrozen = false
MainModule.RLGLRedLightAnimId = "rbxassetid://73083130944511"
MainModule.RLGLPointA = Vector3.new(-215, 1023, -513)
MainModule.RLGLPointB = Vector3.new(116, 1023, 82)
MainModule.RLGLMinX = math.min(MainModule.RLGLPointA.X, MainModule.RLGLPointB.X)
MainModule.RLGLMaxX = math.max(MainModule.RLGLPointA.X, MainModule.RLGLPointB.X)
MainModule.RLGLMinY = math.min(MainModule.RLGLPointA.Y, MainModule.RLGLPointB.Y) - 50
MainModule.RLGLMaxY = math.max(MainModule.RLGLPointA.Y, MainModule.RLGLPointB.Y) + 50
MainModule.RLGLMinZ = math.min(MainModule.RLGLPointA.Z, MainModule.RLGLPointB.Z)
MainModule.RLGLMaxZ = math.max(MainModule.RLGLPointA.Z, MainModule.RLGLPointB.Z)

pcall(function()
	local redLightTurn = ReplicatedStorage:FindFirstChild("Animations") and ReplicatedStorage.Animations:FindFirstChild("Games") and ReplicatedStorage.Animations.Games:FindFirstChild("RedLightGreenLight") and ReplicatedStorage.Animations.Games.RedLightGreenLight:FindFirstChild("RedLightTurn")

	if redLightTurn and redLightTurn:IsA("Animation") then
		MainModule.RLGLRedLightAnimId = redLightTurn.AnimationId
	end
end)

MainModule.getHumanoid = function()
	local character = localPlayer2.Character
	return character and character:FindFirstChildOfClass("Humanoid")
end

MainModule.getHRP = function()
	local character = localPlayer2.Character
	return character and character:FindFirstChild("HumanoidRootPart")
end

MainModule.isPlayerInZone = function()
	local v3 = MainModule.getHRP()
	if not v3 then
		return false
	end
	local position = v3.Position
	local flag2 = position.X >= MainModule.RLGLMinX and position.X <= MainModule.RLGLMaxX
	local flag3

	if flag2 then
		flag3 = position.Y >= MainModule.RLGLMinY and position.Y <= MainModule.RLGLMaxY
	else
		flag3 = flag2
	end

	return flag3 and position.Z >= MainModule.RLGLMinZ and position.Z <= MainModule.RLGLMaxZ
end

MainModule.RLGLCachedAnimators = {}
MainModule.RLGLLastCacheTime = 0

MainModule.updateAnimatorCache = function()
	local now = tick()
	if now - MainModule.RLGLLastCacheTime < 0.5 then
		return
	end
	MainModule.RLGLLastCacheTime = now
	table.clear(MainModule.RLGLCachedAnimators)

	for _, descendant in ipairs(Workspace:GetDescendants()) do
		if descendant:IsA("Animator") then
			table.insert(MainModule.RLGLCachedAnimators, descendant)
		end
	end
end

MainModule.isRedLightActive = function()
	MainModule.updateAnimatorCache()
	local str = tostring(MainModule.RLGLRedLightAnimId)

	for i = #MainModule.RLGLCachedAnimators, 1, -1 do
		local v3 = MainModule.RLGLCachedAnimators[i]
		if not v3 or not v3.Parent then
			table.remove(MainModule.RLGLCachedAnimators, i)
			continue
		end

		for _, v4 in ipairs(v3:GetPlayingAnimationTracks()) do
			if v4.Animation and v4.IsPlaying then
				if tostring(v4.Animation.AnimationId) == str then
					return true
				end
			end
		end
	end

	return false
end

MainModule.freezePlayer = function()
	local v3 = MainModule.getHumanoid()
	local v4 = MainModule.getHRP()
	if not v3 then
		return
	end

	if not MainModule.RLGLWasFrozen then
		MainModule.RLGLOriginalWalkSpeed = v3.WalkSpeed
		MainModule.RLGLOriginalJumpPower = v3.JumpPower
		MainModule.RLGLOriginalJumpHeight = v3.JumpHeight
		MainModule.RLGLWasFrozen = true
	end

	v3:Move(Vector3.zero, false)

	if v4 then
		v4.AssemblyLinearVelocity = Vector3.new(0, v4.AssemblyLinearVelocity.Y, 0)
		v4.AssemblyAngularVelocity = Vector3.zero
	end

	v3.WalkSpeed = 0
	v3.JumpPower = 0
	v3.JumpHeight = 0
end

MainModule.unfreezePlayer = function()
	local v3 = MainModule.getHumanoid()
	if not v3 then
		return
	end
	v3.WalkSpeed = MainModule.RLGLOriginalWalkSpeed > 0 and MainModule.RLGLOriginalWalkSpeed or 16
	v3.JumpPower = MainModule.RLGLOriginalJumpPower > 0 and MainModule.RLGLOriginalJumpPower or 50
	v3.JumpHeight = MainModule.RLGLOriginalJumpHeight > 0 and MainModule.RLGLOriginalJumpHeight or 7.2
	MainModule.RLGLWasFrozen = false
end

MainModule.toggle_rlgl_stop = function(rlglEnabled)
	MainModule.RLGLEnabled = rlglEnabled

	if MainModule.RLGLConnection then
		MainModule.RLGLConnection:Disconnect()
		MainModule.RLGLConnection = nil
	end

	if rlglEnabled then
		MainModule.RLGLConnection = RunService2.Heartbeat:Connect(function()
			if not MainModule.RLGLEnabled then
				return
			end

			if MainModule.isPlayerInZone() and MainModule.isRedLightActive() then
				MainModule.freezePlayer()
			elseif MainModule.RLGLWasFrozen then
				MainModule.unfreezePlayer()
			end
		end)
	elseif MainModule.RLGLWasFrozen then
		MainModule.unfreezePlayer()
	end

	if fn22 then
		fn22()
	end
end

MainModule.TugOfWarQTEMode = false
MainModule.TugOfWarQTEConnection = nil
MainModule.TugOfWarQTEUI = nil
local HBGQTE = nil

pcall(function()
	HBGQTE = require(ReplicatedStorage:WaitForChild("Modules", 5):WaitForChild("HBGQTE", 5))
end)

local function fn32()
	local playerGui = localPlayer2:FindFirstChild("PlayerGui")
	if not playerGui then
		return nil
	end
	local tugOfWarUIV2 = playerGui:FindFirstChild("TugOfWarUIV2") or playerGui:FindFirstChild("TugOfWarUI") or playerGui:FindFirstChild("TugofWarRemake")
	if tugOfWarUIV2 then
		return tugOfWarUIV2
	end
	local ui = ReplicatedStorage:FindFirstChild("UI")

	if ui then
		local tugOfWarUIV22 = ui:FindFirstChild("TugOfWarUIV2") or ui:FindFirstChild("TugOfWarUI")

		if tugOfWarUIV22 then
			local clone = tugOfWarUIV22:Clone()
			clone.Parent = playerGui
			return clone
		end
	end

	return nil
end

MainModule.toggle_tug_of_war_qte = function(tugOfWarQTEMode)
	MainModule.TugOfWarQTEMode = tugOfWarQTEMode

	if MainModule.TugOfWarQTEConnection then
		MainModule.TugOfWarQTEConnection:Disconnect()
		MainModule.TugOfWarQTEConnection = nil
	end

	if MainModule.TugOfWarQTEUI then
		MainModule.TugOfWarQTEUI:Destroy()
		MainModule.TugOfWarQTEUI = nil
	end

	if tugOfWarQTEMode then
		localPlayer2:SetAttribute("TugOfWarPhase", "QTE")
		workspace:SetAttribute("TugOfWarRhythmGoal", 180)
		workspace:SetAttribute("TugOfWarRush", nil)
		local v3 = fn32()

		if v3 then
			v3.Enabled = true
			MainModule.TugOfWarQTEUI = v3
			local tugOfWarQTEHandler = v3:FindFirstChild("TugOfWarQTEHandler", true) or v3:FindFirstChildWhichIsA("LocalScript", true) or v3:FindFirstChildWhichIsA("Script", true)

			if tugOfWarQTEHandler and tugOfWarQTEHandler:IsA("LocalScript") then
				tugOfWarQTEHandler.Disabled = false
			end
		end

		task.wait(0.3)
		localPlayer2:SetAttribute("TugOfWarPhase", "QTE")
		MainModule.notify("Tug of War", "QTE Mode Enabled", 0.9)
	else
		MainModule.notify("Tug of War", "QTE Mode Disabled", 0.9)
	end

	fn22()
end

local flag2 = false
local thread = nil

local function fn33()
	flag2 = false

	if thread then
		task.cancel(thread)
		thread = nil
	end
end

MainModule.QTELetters = MainModule.QTELetters or "WASD"
MainModule.QTESpawnSpeed = MainModule.QTESpawnSpeed or 0.5

local function fn34()
	fn33()
	local qteLetters = MainModule.QTELetters or "WASD"
	local n = tonumber(MainModule.QTESpawnSpeed) or 0.5
	local tbl8 = {}

	for i = 1, #tostring(qteLetters) do
		local str = tostring(qteLetters):sub(i, i):upper()

		if str:match("[A-Z]") then
			tbl8[#tbl8 + 1] = str
		end
	end

	if #tbl8 == 0 then
		fn("QTE Buttons", "No valid letters entered", 0.9)
		return
	end
	local module = HBGQTE
	local flag3 = not module

	if flag3 then
		pcall(function()
			local modules = ReplicatedStorage:FindFirstChild("Modules")

			if modules then
				local hbgqte = modules:FindFirstChild("HBGQTE")

				if hbgqte then
					module = require(hbgqte)
				end
			end
		end)

		HBGQTE = module
	end

	if flag3 or type(module.SetUpButton) ~= "function" then
		fn("QTE Buttons", "HBGQTE not available right now", 0.9)
		return
	end
	flag2 = true

	thread = task.spawn(function()
		local n2 = 1

		while flag2 do
			local v3 = tbl8[n2]

			if not pcall(function()
				module.SetUpButton(3, v3, false, nil)
			end) then
				flag2 = false
				break
			else
				n2 = n2 % #tbl8 + 1
				task.wait(n)
			end
		end

		thread = nil
	end)
end

MainModule.toggle_qte_buttons = function(arg)
	if arg then
		fn34()
	else
		fn33()
	end

	fn22()
end

MainModule.BalloonData = {
	ESPEnabled = false,
	TPEnabled = false,
	Tracers = {},
	Highlights = {},
	NotifiedBalloons = {},
	ProcessedPrompts = {},
}

local function fn35(arg)
	if not arg or not arg:IsA("ProximityPrompt") then
		return
	end

	if fireproximityprompt then
		pcall(function()
			fireproximityprompt(arg)
		end)
	elseif syn and syn.proximityprompt then
		pcall(function()
			syn.proximityprompt(arg)
		end)
	else
		local holdDuration = arg.HoldDuration
		arg.HoldDuration = 0

		pcall(function()
			arg:InputHoldBegin()
			task.wait()
			arg:InputHoldEnd()
		end)

		arg.HoldDuration = holdDuration
	end
end

MainModule.toggle_balloon_teleport = function(tpEnabled)
	MainModule.BalloonData.TPEnabled = tpEnabled
end

local function fn36(arg)
	if not arg or not arg:IsA("ProximityPrompt") then
		return false
	end

	if not arg.Enabled then
		return false
	end

	if not arg.Parent then
		return false
	end

	if arg.MaxActivationDistance and arg.MaxActivationDistance <= 0 then
		return false
	end
	return true
end

task.spawn(function()
	while task.wait(0.2) do
		if MainModule.BalloonData.TPEnabled then
			local effects = workspace:FindFirstChild("Effects")

			if effects then
				for _, child in ipairs(effects:GetChildren()) do
					if child.Name == "Balloon" and not MainModule.BalloonData.ProcessedPrompts[child] then
						local balloonProximityPrompt = child:FindFirstChild("BalloonProximityPrompt", true) or child:FindFirstChildWhichIsA("ProximityPrompt", true)

						if balloonProximityPrompt and fn36(balloonProximityPrompt) then
							MainModule.BalloonData.ProcessedPrompts[child] = true

							task.spawn(function()
								if not (child and child.Parent and MainModule.BalloonData.TPEnabled) then
									return
								end

								if not fn36(balloonProximityPrompt) then
									MainModule.BalloonData.ProcessedPrompts[child] = nil
									return
								end
								local parent = balloonProximityPrompt.Parent:IsA("BasePart") and balloonProximityPrompt.Parent or child:FindFirstChildWhichIsA("BasePart", true)
								local v3 = MainModule.get_character()
								local v4 = v3 and MainModule.get_root_part(v3)

								if v3 and v4 and parent then
									pcall(function()
										v3:PivotTo(parent.CFrame * CFrame.new(0, 5, 0))
									end)

									task.wait(0.2)

									if fn36(balloonProximityPrompt) then
										fn35(balloonProximityPrompt)
									end
								else
									MainModule.BalloonData.ProcessedPrompts[child] = nil
								end
							end)
						end
					end
				end
			end
		end
	end
end)

MainModule.create_esp_visuals = function(adornee)
	local isBasePart = adornee:IsA("BasePart") and adornee or adornee:FindFirstChildWhichIsA("BasePart", true)
	if not isBasePart then
		return
	end

	if not MainModule.BalloonData.NotifiedBalloons[adornee] then
		MainModule.BalloonData.NotifiedBalloons[adornee] = true

		if lib and fn then
			fn({ Title = "HollyScriptX", Description = "Balloon detected!", Duration = 0.9 })
		end

		if PlayErrorSound then
			PlayErrorSound()
		end
	end

	if not MainModule.BalloonData.Highlights[adornee] then
		local highlight = Instance.new("Highlight")
		highlight.Name = "BalloonHighlight"
		highlight.Adornee = adornee
		highlight.FillColor = Color3.fromRGB(255, 255, 255)
		highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
		highlight.FillTransparency = 0.5
		highlight.OutlineTransparency = 0
		highlight.Parent = adornee
		MainModule.BalloonData.Highlights[adornee] = highlight
	end

	local v3 = MainModule.get_character()

	if v3 then
		local v4 = MainModule.get_root_part(v3)

		if v4 and not MainModule.BalloonData.Tracers[isBasePart] then
			local attachment = Instance.new("Attachment", v4)
			attachment.Name = "BalloonTracerA0"
			local attachment2 = Instance.new("Attachment", isBasePart)
			attachment2.Name = "BalloonTracerA1"
			local beam = Instance.new("Beam")
			beam.Name = "BalloonTracerBeam"
			beam.Color = ColorSequence.new(Color3.fromRGB(255, 255, 255))
			beam.Width0 = 0.15
			beam.Width1 = 0.15
			beam.FaceCamera = true
			beam.Attachment0 = attachment
			beam.Attachment1 = attachment2
			beam.Parent = isBasePart
			MainModule.BalloonData.Tracers[isBasePart] = { Attachment0 = attachment, Attachment1 = attachment2, Beam = beam }
		end
	end

	adornee.AncestryChanged:Connect(function(child, parent)
		if not parent then
			MainModule.BalloonData.NotifiedBalloons[adornee] = nil
			MainModule.BalloonData.ProcessedPrompts[adornee] = nil

			if MainModule.BalloonData.Highlights[adornee] then
				pcall(function()
					MainModule.BalloonData.Highlights[adornee]:Destroy()
				end)

				MainModule.BalloonData.Highlights[adornee] = nil
			end

			if MainModule.BalloonData.Tracers[isBasePart] then
				pcall(function()
					MainModule.BalloonData.Tracers[isBasePart].Attachment0:Destroy()
					MainModule.BalloonData.Tracers[isBasePart].Attachment1:Destroy()
					MainModule.BalloonData.Tracers[isBasePart].Beam:Destroy()
				end)

				MainModule.BalloonData.Tracers[isBasePart] = nil
			end
		end
	end)
end

MainModule.toggle_balloon_esp = function(espEnabled)
	MainModule.BalloonData.ESPEnabled = espEnabled

	if not espEnabled then
		for _, highlight in pairs(MainModule.BalloonData.Highlights) do
			pcall(function()
				highlight:Destroy()
			end)
		end

		for _, tracer in pairs(MainModule.BalloonData.Tracers) do
			pcall(function()
				tracer.Attachment0:Destroy()
				tracer.Attachment1:Destroy()
				tracer.Beam:Destroy()
			end)
		end

		MainModule.BalloonData.Highlights = {}
		MainModule.BalloonData.Tracers = {}
		MainModule.BalloonData.NotifiedBalloons = {}
	end
end

task.spawn(function()
	while task.wait(0.5) do
		if MainModule.BalloonData.ESPEnabled then
			local effects = workspace:FindFirstChild("Effects")

			if effects then
				for _, child in ipairs(effects:GetChildren()) do
					if child.Name == "Balloon" then
						MainModule.create_esp_visuals(child)
					end
				end
			end
		end
	end
end)

MainModule.noclipEnabled = false
MainModule.noclipButton = nil
MainModule.noclipConnection = nil
MainModule.TELEPORT_DISTANCE = 13
MainModule.RAY_LENGTH = 6

MainModule.createNoclipButton = function()
	if MainModule.noclipButton then
		pcall(function()
			MainModule.noclipButton:Destroy()
		end)
	end

	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = HttpService:GenerateGUID(false)
	screenGui.ResetOnSpawn = false
	screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	screenGui.Parent = localPlayer2:WaitForChild("PlayerGui")
	local textButton = Instance.new("TextButton")
	textButton.Name = HttpService:GenerateGUID(false)
	textButton.Size = UDim2.new(0, 90, 0, 90)
	textButton.Position = UDim2.new(1, -110, 0.5, -45)
	textButton.BackgroundColor3 = Color3.fromRGB(15, 15, 18)
	textButton.BackgroundTransparency = 0.25
	textButton.Text = "TP Wall"
	textButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	textButton.TextSize = 16
	textButton.Font = Enum.Font.GothamBold
	textButton.AutoButtonColor = true
	textButton.Parent = screenGui
	local uiStroke = Instance.new("UIStroke")
	uiStroke.Color = Color3.fromRGB(200, 200, 210)
	uiStroke.Thickness = 1.5
	uiStroke.Parent = textButton
	local uiCorner = Instance.new("UICorner")
	uiCorner.CornerRadius = UDim.new(0, 12)
	uiCorner.Parent = textButton
	local flag3 = false
	local flag4 = false
	local position = nil
	local position2 = nil

	textButton.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
			flag3 = true
			flag4 = false
			position = input.Position
			position2 = textButton.Position
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if not flag3 then
			return
		end

		if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement then
			local n = input.Position - position

			if math.abs(n.X) > 6 or math.abs(n.Y) > 6 then
				flag4 = true
			end

			textButton.Position = UDim2.new(position2.X.Scale, position2.X.Offset + n.X, position2.Y.Scale, position2.Y.Offset + n.Y)
		end
	end)

	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
			if flag3 and not flag4 then
				pcall(function()
					MainModule.teleportThroughWall()
				end)
			end

			flag3 = false
		end
	end)

	MainModule.noclipButton = screenGui
	return screenGui
end

MainModule.ThroughWallsEnabled = false
MainModule.ThroughWallsConn = nil
MainModule.RAY_LENGTH = MainModule.RAY_LENGTH or 50
MainModule.TELEPORT_DISTANCE = MainModule.TELEPORT_DISTANCE or 8

MainModule.toggle_through_walls = function(arg)
	MainModule.ThroughWallsEnabled = arg and true or false
	MainModule.noclipEnabled = MainModule.ThroughWallsEnabled

	if MainModule.ThroughWallsConn then
		pcall(function()
			MainModule.ThroughWallsConn:Disconnect()
		end)

		MainModule.ThroughWallsConn = nil
	end

	if MainModule.noclipButton then
		pcall(function()
			MainModule.noclipButton:Destroy()
		end)

		MainModule.noclipButton = nil
	end

	if MainModule.ThroughWallsEnabled then
		MainModule.ThroughWallsConn = UserInputService.InputBegan:Connect(function(input, gameProcessed)
			if gameProcessed then
				return
			end

			if input.KeyCode == Enum.KeyCode.X then
				pcall(function()
					MainModule.teleportThroughWall()
				end)
			end
		end)

		local flag3 = false

		pcall(function()
			flag3 = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
		end)

		if flag3 and MainModule.createNoclipButton then
			pcall(MainModule.createNoclipButton)
		end
	end

	fn22()
	return true
end

MainModule.teleportThroughWall = function()
	if not MainModule.noclipEnabled then
		return
	end
	local character = localPlayer2.Character
	if not character then
		return
	end
	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	if not humanoidRootPart then
		return
	end
	local currentCamera = workspace.CurrentCamera
	if not currentCamera then
		return
	end
	local lookVector = currentCamera.CFrame.LookVector
	local position = humanoidRootPart.Position
	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
	raycastParams.FilterDescendantsInstances = { character }
	raycastParams.IgnoreWater = true
	local hit = workspace:Raycast(position, lookVector * MainModule.RAY_LENGTH, raycastParams)
	local n = position + lookVector * MainModule.TELEPORT_DISTANCE

	if hit then
		n = hit.Position + lookVector * 3 + hit.Normal * 2
	end

	humanoidRootPart.CanCollide = false
	humanoidRootPart.CFrame = CFrame.new(n)
	task.wait()
	humanoidRootPart.CanCollide = true
end

MainModule.desyncHooked = false

MainModule.desyncAvailable = pcall(function()
	return raknet and raknet.add_send_hook
end)

MainModule.rakhook = function(arg)
	if arg.PacketId == 27 then
		local asBuffer = arg.AsBuffer

		if buffer and buffer.writeu32 then
			buffer.writeu32(asBuffer, 1, 4294967295)
			arg:SetData(asBuffer)
		end
	end
end

MainModule.toggle_desync = function(arg)
	local desync = MainModule.ToggleRefs.Desync

	if arg and MainModule.is_xeno_executor() then
		MainModule.notify("Desync", "Not supported in your executor", 0.9)
		PlayErrorSound()

		if desync and desync.SetValue then
			pcall(function()
				desync:SetValue(false)
			end)
		end

		return false
	end

	if not MainModule.desyncAvailable then
		MainModule.notify("Desync", "Unsupported Executor", 0.9)
		PlayErrorSound()

		if desync and desync.SetValue then
			pcall(function()
				desync:SetValue(false)
			end)
		end

		return false
	end

	if arg then
		if not MainModule.desyncHooked then
			pcall(function()
				raknet.add_send_hook(MainModule.rakhook)
				MainModule.desyncHooked = true
			end)
		end
	elseif MainModule.desyncHooked then
		pcall(function()
			raknet.remove_send_hook(MainModule.rakhook)
			MainModule.desyncHooked = false
		end)
	end

	fn22()
	return true
end

MainModule.PlayerAttachEnabled = false
MainModule.attachedTarget = nil
MainModule.attachConnection = nil
MainModule.autoSearchConnection = nil
MainModule.BehindSquare = nil
MainModule.FrontSquare = nil
MainModule.CurrentSquare = nil
MainModule.CurrentBodyVelocity = nil

MainModule.AttachConfig = {
	BehindDistance = 2.5,
	FrontDistance = 16,
	SpeedThreshold = 17,
	MaxSpeed = 500,
	TransitionSpeed = 150,
}

MainModule.createSquare = function(name)
	local part = Instance.new("Part")
	part.Name = name
	part.Size = Vector3.new(3, 0.5, 3)
	part.Transparency = 1
	part.CanCollide = false
	part.Anchored = true
	part.Massless = true
	part.Parent = workspace
	return part
end

MainModule.destroySquares = function()
	if MainModule.BehindSquare then
		MainModule.BehindSquare:Destroy()
		MainModule.BehindSquare = nil
	end

	if MainModule.FrontSquare then
		MainModule.FrontSquare:Destroy()
		MainModule.FrontSquare = nil
	end
end

MainModule.isTargetMovingForward = function(arg)
	if not arg then
		return false
	end
	local velocity = arg.Velocity
	if math.sqrt(velocity.X ^ 2 + velocity.Z ^ 2) < 2 then
		return false
	end
	local lookVector = arg.CFrame.LookVector
	local unit = Vector3.new(velocity.X, 0, velocity.Z).Unit
	return Vector3.new(lookVector.X, 0, lookVector.Z).Unit:Dot(unit) > 0.7
end

MainModule.updateSquares = function(arg)
	if not arg then
		return
	end
	local position = arg.Position
	local lookVector = arg.CFrame.LookVector
	local y = arg.Position.Y
	local n = position + -lookVector * MainModule.AttachConfig.BehindDistance
	local vector = Vector3.new(n.X, y - 2, n.Z)
	local n2 = position + lookVector * MainModule.AttachConfig.FrontDistance
	local vector2 = Vector3.new(n2.X, y - 2, n2.Z)

	if MainModule.BehindSquare then
		MainModule.BehindSquare.Position = vector
	end

	if MainModule.FrontSquare then
		MainModule.FrontSquare.Position = vector2
	end
end

MainModule.getTargetSquare = function(arg)
	if not arg then
		return MainModule.BehindSquare
	end
	local velocity = arg.Velocity
	local speedThreshold = MainModule.AttachConfig.SpeedThreshold
	local flag3 = math.sqrt(velocity.X ^ 2 + velocity.Z ^ 2) > speedThreshold
	local v3 = MainModule.isTargetMovingForward(arg)
	if flag3 and v3 then
		return MainModule.FrontSquare
	end
	return MainModule.BehindSquare
end

MainModule.applySmoothMovement = function(arg, arg2)
	local character = localPlayer2.Character
	if not character then
		return
	end
	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if not humanoidRootPart or not humanoid then
		return
	end

	if not arg then
		return
	end
	local position = humanoidRootPart.Position
	local magnitude = (arg - position).Magnitude

	if magnitude > 0.3 then
		local n = (arg - position).Unit * math.min(arg2 and MainModule.AttachConfig.TransitionSpeed or MainModule.AttachConfig.MaxSpeed, magnitude * 10)

		if MainModule.CurrentBodyVelocity then
			MainModule.CurrentBodyVelocity:Destroy()
		end

		MainModule.CurrentBodyVelocity = Instance.new("BodyVelocity")
		MainModule.CurrentBodyVelocity.MaxForce = Vector3.new(50000, 0, 50000)
		MainModule.CurrentBodyVelocity.Velocity = Vector3.new(n.X, 0, n.Z)
		MainModule.CurrentBodyVelocity.Parent = humanoidRootPart
		task.wait(0.03)

		if MainModule.CurrentBodyVelocity then
			MainModule.CurrentBodyVelocity:Destroy()
			MainModule.CurrentBodyVelocity = nil
		end
	end

	humanoid.AutoRotate = true
end

MainModule.find_best_target = function()
	if not localPlayer2 then
		return nil
	end
	local v3 = MainModule.is_seeker(localPlayer2)
	local v4 = MainModule.is_hider(localPlayer2)
	local character = localPlayer2.Character
	if not character then
		return nil
	end
	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	if not humanoidRootPart then
		return nil
	end
	local huge = math.huge
	local v5 = nil

	for _, player in pairs(Players2:GetPlayers()) do
		if player ~= localPlayer2 and player.Character then
			local humanoid = player.Character:FindFirstChildOfClass("Humanoid")

			if humanoid and humanoid.Health > 0 then
				if v3 and MainModule.is_hider(player) then
					local humanoidRootPart2 = player.Character:FindFirstChild("HumanoidRootPart")

					if humanoidRootPart2 then
						local magnitude = (humanoidRootPart2.Position - humanoidRootPart.Position).Magnitude

						if magnitude < huge then
							huge = magnitude
							v5 = player
						end
					end
				elseif v4 and MainModule.is_seeker(player) then
					local humanoidRootPart2 = player.Character:FindFirstChild("HumanoidRootPart")

					if humanoidRootPart2 then
						local magnitude = (humanoidRootPart2.Position - humanoidRootPart.Position).Magnitude

						if magnitude < huge then
							huge = magnitude
							v5 = player
						end
					end
				elseif not v3 and not v4 then
					local humanoidRootPart2 = player.Character:FindFirstChild("HumanoidRootPart")

					if humanoidRootPart2 then
						local magnitude = (humanoidRootPart2.Position - humanoidRootPart.Position).Magnitude

						if magnitude < huge then
							huge = magnitude
							v5 = player
						end
					end
				end
			end
		end
	end

	return v5
end

MainModule.lastSquare = nil

MainModule.attachToPlayer = function(attachedTarget)
	if not attachedTarget or not attachedTarget.Character then
		return false
	end

	if MainModule.attachedTarget == attachedTarget then
		return true
	end

	if MainModule.attachedTarget then
		MainModule.detach()
	end

	local character = localPlayer2.Character
	if not character then
		return false
	end
	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if not humanoidRootPart or not humanoid then
		return false
	end
	MainModule.destroySquares()
	MainModule.BehindSquare = MainModule.createSquare("BehindSquare", MainModule.AttachConfig.BehindDistance)
	MainModule.FrontSquare = MainModule.createSquare("FrontSquare", MainModule.AttachConfig.FrontDistance)
	MainModule.attachedTarget = attachedTarget
	MainModule.lastSquare = nil
	humanoid.WalkSpeed = MainModule.AttachConfig.MaxSpeed
	humanoid.AutoRotate = true
	humanoid.PlatformStand = false

	if not MainModule.FaceTargetModule.Enabled then
		MainModule.toggle_face_target(true)

		if MainModule.ToggleRefs.FaceTarget then
			MainModule.ToggleRefs.FaceTarget:SetValue(true)
		end
	end

	if MainModule.attachConnection then
		MainModule.attachConnection:Disconnect()
	end

	MainModule.attachConnection = RunService2.Heartbeat:Connect(function()
		if not MainModule.PlayerAttachEnabled or not MainModule.attachedTarget then
			MainModule.detach()
			return
		end

		if not MainModule.attachedTarget or not MainModule.attachedTarget.Character then
			MainModule.detach()
			return
		end
		local character2 = MainModule.attachedTarget.Character
		local humanoidRootPart2 = character2:FindFirstChild("HumanoidRootPart")
		local humanoid2 = character2:FindFirstChildOfClass("Humanoid")

		if not humanoidRootPart2 or not humanoid2 or humanoid2.Health <= 0 then
			local v3 = MainModule.find_best_target()

			if v3 and v3 ~= MainModule.attachedTarget then
				MainModule.attachToPlayer(v3)
				PlayDeathSound()
			else
				MainModule.detach()
				MainModule.notify("KillAura", "No new target's found :c", 0.9)
				PlayErrorSound()

				if MainModule.ToggleRefs.PlayerAttach then
					MainModule.ToggleRefs.PlayerAttach:SetValue(false)
				end
			end

			return
		end

		MainModule.updateSquares(humanoidRootPart2)
		local v3 = MainModule.getTargetSquare(humanoidRootPart2)

		if v3 then
			local flag3 = MainModule.lastSquare ~= nil and MainModule.lastSquare ~= v3
			local position = v3.Position
			MainModule.applySmoothMovement(Vector3.new(position.X, position.Y + 2.5, position.Z), flag3)
			MainModule.lastSquare = v3
		end
	end)

	return true
end

MainModule.detach = function()
	if MainModule.attachConnection then
		MainModule.attachConnection:Disconnect()
		MainModule.attachConnection = nil
	end

	if MainModule.CurrentBodyVelocity then
		MainModule.CurrentBodyVelocity:Destroy()
		MainModule.CurrentBodyVelocity = nil
	end

	MainModule.destroySquares()
	local character = localPlayer2.Character

	if character then
		local humanoid = character:FindFirstChildOfClass("Humanoid")

		if humanoid then
			humanoid.PlatformStand = false
			humanoid.AutoRotate = true
			humanoid.WalkSpeed = 16
		end

		local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

		if humanoidRootPart then
			humanoidRootPart.AssemblyLinearVelocity = Vector3.zero
		end
	end

	if MainModule.FaceTargetModule.Enabled then
		MainModule.toggle_face_target(false)

		if MainModule.ToggleRefs.FaceTarget then
			MainModule.ToggleRefs.FaceTarget:SetValue(false)
		end
	end

	MainModule.attachedTarget = nil
	MainModule.CurrentSquare = nil
	MainModule.lastSquare = nil
end

MainModule.startAutoSearch = function()
	if MainModule.autoSearchConnection then
		MainModule.autoSearchConnection:Disconnect()
	end

	MainModule.autoSearchConnection = RunService2.Heartbeat:Connect(function()
		if not MainModule.PlayerAttachEnabled then
			return
		end

		if MainModule.attachedTarget then
			return
		end

		if tick() % 1 < 0.05 then
			local v3 = MainModule.find_best_target()

			if v3 then
				MainModule.attachToPlayer(v3)
				PlayBell()
			end
		end
	end)
end

MainModule.toggle_player_attach = function(playerAttachEnabled)
	MainModule.PlayerAttachEnabled = playerAttachEnabled

	if playerAttachEnabled then
		local v3 = MainModule.find_best_target()

		if v3 then
			MainModule.attachToPlayer(v3)
			PlayBell()
			MainModule.startAutoSearch()
		else
			MainModule.notify("Killaura", "No player's found :c", 0.9)
			PlayErrorSound()
			MainModule.PlayerAttachEnabled = false

			if MainModule.ToggleRefs.PlayerAttach then
				MainModule.ToggleRefs.PlayerAttach:SetValue(false)
			end
		end
	else
		if MainModule.autoSearchConnection then
			MainModule.autoSearchConnection:Disconnect()
			MainModule.autoSearchConnection = nil
		end

		MainModule.detach()
	end

	fn22()
end

MainModule.spectate_player = function(arg)
	if not arg then
		return
	end

	if not arg.Character then
		MainModule.notify("Spectate", "Player has no character", 0.9)
		PlayErrorSound()
		return
	end

	local humanoid = arg.Character:FindFirstChildOfClass("Humanoid")

	if not humanoid or humanoid.Health <= 0 then
		fn({ Title = "Spectate", Description = "Player is dead", Duration = 0.9 })
		PlayErrorSound()
		return
	end

	workspace.CurrentCamera.CameraSubject = humanoid
	fn({ Title = "Spectate", Description = "Spectating: " .. arg.Name, Duration = 0.9 })
	PlayBell()
end

MainModule.stop_spectate = function()
	local character = localPlayer2.Character

	if character then
		local humanoid = character:FindFirstChildOfClass("Humanoid")

		if humanoid then
			workspace.CurrentCamera.CameraSubject = humanoid
			fn({ Title = "Spectate", Description = "Stopped", Duration = 0.9 })
			PlayBell()
		end
	end
end

MainModule.teleport_to_player = function(arg)
	if not arg then
		return
	end

	if not arg.Character then
		fn({ Title = "Teleport", Description = "Player has no character", Duration = 0.9 })
		PlayErrorSound()
		return
	end

	local humanoidRootPart = arg.Character:FindFirstChild("HumanoidRootPart")

	if not humanoidRootPart then
		fn({ Title = "Teleport", Description = "Player has no root part", Duration = 0.9 })
		PlayErrorSound()
		return
	end

	local character = localPlayer2.Character
	if not character then
		return
	end
	local humanoidRootPart2 = character:FindFirstChild("HumanoidRootPart")
	if not humanoidRootPart2 then
		return
	end
	humanoidRootPart2.CFrame = CFrame.new(humanoidRootPart.Position + Vector3.new(0, 3, 0))
	fn({ Title = "Teleport", Description = "Teleported to: " .. arg.Name, Duration = 0.9 })
	PlayBell()
end

MainModule.getNearestPlayerAnywhere = function()
	local v3 = MainModule.get_character()
	if not v3 then
		return nil
	end
	local position = v3:FindFirstChild("HumanoidRootPart") and v3.HumanoidRootPart.Position
	if not position then
		return nil
	end
	local huge = math.huge
	local v4 = nil

	for _, player in pairs(Players2:GetPlayers()) do
		if player ~= localPlayer2 and player.Character then
			local humanoidRootPart = player.Character:FindFirstChild("HumanoidRootPart")

			if humanoidRootPart then
				local magnitude = (humanoidRootPart.Position - position).Magnitude

				if magnitude < huge then
					huge = magnitude
					v4 = player
				end
			end
		end
	end

	return v4
end

MainModule.teleportToNearest = function()
	local v3 = MainModule.getNearestPlayerAnywhere()

	if v3 and v3.Character then
		local humanoidRootPart = v3.Character:FindFirstChild("HumanoidRootPart")

		if humanoidRootPart then
			local character = localPlayer2.Character

			if character then
				local humanoidRootPart2 = character:FindFirstChild("HumanoidRootPart")

				if humanoidRootPart2 then
					humanoidRootPart2.CFrame = CFrame.new(humanoidRootPart.Position + Vector3.new(0, 3, 0))
					MainModule.notify("Teleport", "Teleported to: " .. v3.Name, 0.9)
					PlayBell()
				end
			end
		end
	else
		fn({ Title = "Teleport", Description = "No player's near :c", Duration = 0.9 })
		PlayErrorSound()
	end
end

MainModule.update_all_toggles_by_game = function()
	local values = Workspace:FindFirstChild("Values")
	if not values then
		return
	end
	local currentGame = values:FindFirstChild("CurrentGame")
	currentGame = currentGame and currentGame.Value
	MainModule.update_toggle_availability("AutoDodge", currentGame == "HideAndSeek" and "HideAndSeek" or nil, MainModule.ToggleRefs.AutoDodge)
	MainModule.update_toggle_availability("InfiniteStamina", currentGame == "HideAndSeek" and "HideAndSeek" or nil, MainModule.ToggleRefs.InfiniteStamina)
	MainModule.update_toggle_availability("SpikesKill", currentGame == "HideAndSeek" and "HideAndSeek" or nil, MainModule.ToggleRefs.SpikesKill)
	MainModule.update_toggle_availability("AutoEscape", currentGame == "HideAndSeek" and "HideAndSeek" or nil, MainModule.ToggleRefs.AutoEscape)
	MainModule.update_toggle_availability("KeyESP", currentGame == "HideAndSeek" and "HideAndSeek" or nil, MainModule.ToggleRefs.KeyESP)
	MainModule.update_toggle_availability("JumpRopeAntiFall", currentGame == "JumpRope" and "JumpRope" or nil, MainModule.ToggleRefs.JumpRopeAntiFall)
	MainModule.update_toggle_availability("GlassESP", currentGame == "GlassBridge" and "GlassBridge" or nil, MainModule.ToggleRefs.GlassESP)
	MainModule.update_toggle_availability("AntiBreak", currentGame == "GlassBridge" and "GlassBridge" or nil, MainModule.ToggleRefs.AntiBreak)
	MainModule.update_toggle_availability("ZoneKill", currentGame == "LastDinner" and "LastDinner" or nil, MainModule.ToggleRefs.ZoneKill)
	MainModule.update_toggle_availability("VoidKill", currentGame == "SkySquidGame" and "SkySquidGame" or nil, MainModule.ToggleRefs.VoidKill)
	MainModule.update_toggle_availability("SkySquidAntiFall", currentGame == "SkySquidGame" and "SkySquidGame" or nil, MainModule.ToggleRefs.SkySquidAntiFall)
	MainModule.update_toggle_availability("MingleVoidKill", currentGame == "Mingle" and "Mingle" or nil, MainModule.ToggleRefs.MingleVoidKill)
	MainModule.update_toggle_availability("GodMode", currentGame == "RedLightGreenLight" and "RedLightGreenLight" or nil, MainModule.ToggleRefs.GodMode)
	MainModule.update_toggle_availability("RemoveInjury", currentGame == "RedLightGreenLight" and "RedLightGreenLight" or nil, MainModule.ToggleRefs.RemoveInjury)
	MainModule.update_toggle_availability("AutoChoke", currentGame == "Mingle" and "Mingle" or nil, MainModule.ToggleRefs.AutoChoke)
	MainModule.update_toggle_availability("AutoPickupKeys", currentGame == "HideAndSeek" and "HideAndSeek" or nil, MainModule.ToggleRefs.AutoPickup)
end

MainModule.GameStateMonitor = { Connection = nil, LastGame = nil }

MainModule.GameStateMonitor.Start = function()
	if MainModule.GameStateMonitor.Connection then
		MainModule.GameStateMonitor.Connection:Disconnect()
	end

	MainModule.GameStateMonitor.Connection = RunService2.Heartbeat:Connect(function()
		local values = Workspace:FindFirstChild("Values")
		if not values then
			return
		end
		local currentGame = values:FindFirstChild("CurrentGame")
		currentGame = currentGame and currentGame.Value

		if currentGame ~= MainModule.GameStateMonitor.LastGame then
			if MainModule.GameStateMonitor.LastGame then
				MainModule.GameStateMonitor.DisableGameToggles(MainModule.GameStateMonitor.LastGame)
			end

			MainModule.GameStateMonitor.LastGame = currentGame
			MainModule.update_all_toggles_by_game()
		end
	end)
end

MainModule.GameStateMonitor.DisableGameToggles = function(arg)
	local v3 = ({
		HideAndSeek = { "AutoDodge", "InfiniteStamina", "SpikesKill", "AutoEscape", "KeyESP", "AutoPickupKeys" },
		JumpRope = { "JumpRopeAntiFall" },
		GlassBridge = { "GlassESP", "AntiBreak" },
		LastDinner = { "ZoneKill" },
		SkySquidGame = { "VoidKill", "SkySquidAntiFall" },
		Mingle = { "MingleVoidKill", "AutoChoke" },
		RedLightGreenLight = { "GodMode", "RemoveInjury" },
	})[arg]

	if v3 then
		for _, v4 in ipairs(v3) do
			MainModule.disable_toggle(v4)
		end
	end
end

MainModule.GameStateMonitor.Start()

MainModule.teleport_to_safe_spot = function()
	if MainModule.is_game_active("LastDinner") then
		MainModule.safe_teleport(Vector3.new(0, 100, 0))
		MainModule.notify("Last Dinner", "Teleported to Safe Spot", 0.9)
	else
		MainModule.notify("Last Dinner", "Wait for LastDinner!", 0.9)
		PlayErrorSound()
	end

	PlayBell()
end

MainModule.RebelEnabled = false
MainModule.RebelShotsPerTick = 10
MainModule.RebelConnection = nil
MainModule.RebelGun = nil
MainModule.RebelEnemiesCache = {}
MainModule.RebelEnemiesUpdateTime = 0
MainModule.RebelEnemiesIndex = 1
MainModule.RebelEnemiesList = {}

local function fn37()
	local v3 = MainModule.get_character()
	local backpack = localPlayer2:FindFirstChild("Backpack")
	local v4 = nil

	if v3 then
		local v5 = nil

		for _, child in ipairs(v3:GetChildren()) do
			if child:IsA("Tool") and (child:GetAttribute("Gun") or child:FindFirstChild("GunScript") or string.lower(child.Name):find("gun")) then
				v5 = child
				break
			else
				v5 = nil
			end
		end

		v4 = v5
	end

	if not v4 and backpack then
		for _, child in ipairs(backpack:GetChildren()) do
			if child:IsA("Tool") and (child:GetAttribute("Gun") or child:FindFirstChild("GunScript") or string.lower(child.Name):find("gun")) then
				v4 = child
				break
			end
		end
	end

	return v4
end

local function fn38()
	local rebelEnemiesUpdateTime = MainModule.RebelEnemiesUpdateTime
	if tick() - rebelEnemiesUpdateTime < 0.1 then
		return
	end
	MainModule.RebelEnemiesUpdateTime = tick()
	local rebelEnemiesCache = {}
	local live = workspace:FindFirstChild("Live")

	if live then
		for _, child in ipairs(live:GetChildren()) do
			if child:IsA("Model") and child:FindFirstChild("Enemy") and not child:FindFirstChild("Dead") then
				local flag3 = false

				for _, player in ipairs(Players2:GetPlayers()) do
					if player.Name == child.Name then
						flag3 = true
						break
					end
				end

				if not flag3 then
					rebelEnemiesCache[child.Name] = "Head"
				end
			end
		end
	end

	MainModule.RebelEnemiesCache = rebelEnemiesCache
	MainModule.RebelEnemiesIndex = 1
	MainModule.RebelEnemiesList = {}

	for k, v3 in pairs(rebelEnemiesCache) do
		MainModule.RebelEnemiesList[#MainModule.RebelEnemiesList + 1] = { name = k, part = v3 }
	end
end

local function fn39(arg)
	if not MainModule.RebelEnemiesList or #MainModule.RebelEnemiesList == 0 then
		return {}
	end
	local tbl8 = {}
	local rebelEnemiesList = MainModule.RebelEnemiesList
	local n = 0

	for i = MainModule.RebelEnemiesIndex, #rebelEnemiesList do
		local v3 = rebelEnemiesList[i]
		tbl8[v3.name] = v3.part
		n += 1
		MainModule.RebelEnemiesIndex = i + 1
		if not (arg <= n) then
			continue
		end
		break
	end

	if #rebelEnemiesList < MainModule.RebelEnemiesIndex then
		MainModule.RebelEnemiesIndex = 1
	end

	return tbl8
end

local function fn40()
	if MainModule.RebelConnection then
		MainModule.RebelConnection:Disconnect()
		MainModule.RebelConnection = nil
	end

	MainModule.RebelConnection = RunService2.Heartbeat:Connect(function()
		if not MainModule.RebelEnabled then
			return
		end

		if not MainModule.RebelGun or tick() % 1 < 0.02 then
			MainModule.RebelGun = fn37()
		end

		if not MainModule.RebelGun then
			return
		end
		fn38()
		if not MainModule.RebelEnemiesList or #MainModule.RebelEnemiesList == 0 then
			return
		end
		local remotes = ReplicatedStorage:FindFirstChild("Remotes")
		if not remotes then
			return
		end
		local firedGunClient = remotes:FindFirstChild("FiredGunClient")
		if not firedGunClient then
			return
		end
		local part = workspace:FindFirstChild("StairWalkWay") and workspace.StairWalkWay:FindFirstChild("Part") or workspace
		fn39(5)
		local tbl8 = {}
		local rebelGun = MainModule.RebelGun
		local vector = Vector3.new

		local tbl9 = {
			ClientRayNormal = Vector3.new(0, 1, 0),
			FiredGun = true,
			SecondaryHitTargets = {},
			ClientRayInstance = part,
			ClientRayPosition = Vector3.zero,
			bulletCF = CFrame.new(),
			HitTargets = vector,
			bulletSizeC = Vector3.new(0.01, 0.01, 5),
			NoMuzzleFX = true,
			FirePosition = Vector3.zero,
		}

		tbl8[1] = rebelGun
		tbl8[2] = tbl9

		for i = 1, math.min(MainModule.RebelShotsPerTick, 3) do
			pcall(function()
				firedGunClient:FireServer(unpack(tbl8))
			end)
		end
	end)
end

MainModule.toggle_rebel_v2 = function(rebelEnabled)
	MainModule.RebelEnabled = rebelEnabled

	if MainModule.RebelConnection then
		MainModule.RebelConnection:Disconnect()
		MainModule.RebelConnection = nil
	end

	MainModule.RebelGun = nil
	MainModule.RebelEnemiesList = {}
	MainModule.RebelEnemiesIndex = 1

	if rebelEnabled then
		fn40()
	end

	fn22()
end

MainModule.set_rebel_shots_per_tick = function(rebelShotsPerTick)
	MainModule.RebelShotsPerTick = rebelShotsPerTick
end

MainModule.NoRecoilEnabled = false
MainModule.NoRecoilConnection = nil
MainModule.NoRecoilExtraConns = {}

local function fn41()
	if MainModule.NoRecoilConnection then
		pcall(function()
			MainModule.NoRecoilConnection:Disconnect()
		end)

		MainModule.NoRecoilConnection = nil
	end

	if MainModule.NoRecoilExtraConns then
		for _, noRecoilExtraConn in ipairs(MainModule.NoRecoilExtraConns) do
			pcall(function()
				noRecoilExtraConn:Disconnect()
			end)
		end
	end

	MainModule.NoRecoilExtraConns = {}
end

MainModule.toggle_no_recoil = function(arg)
	local noRecoilEnabled = arg and true or false
	MainModule.NoRecoilEnabled = noRecoilEnabled
	fn41()

	if not noRecoilEnabled then
		if fn22 then
			fn22()
		end

		return true
	end

	local function fn42()
		local currentCamera = workspace.CurrentCamera
		if not currentCamera then
			return
		end

		for _, v3 in ipairs({ "CameraRecoil", "Recoil", "Spread", "CameraShake", "RecoilShake" }) do
			local v4 = currentCamera:FindFirstChild(v3)

			if v4 then
				pcall(function()
					v4:Destroy()
				end)
			end
		end
	end

	local function fn43(arg2)
		if not arg2 then
			return
		end

		pcall(function()
			for _, v3 in ipairs({ "Spread", "Recoil", "RecoilShake" }) do
				local v4 = arg2:FindFirstChild(v3, true)

				if v4 then
					if v4:IsA("NumberValue") or v4:IsA("IntValue") then
						v4.Value = 0
					elseif v4:IsA("Vector3Value") then
						v4.Value = Vector3.zero
					elseif v4:IsA("BoolValue") then
						v4.Value = false
					end
				end
			end

			if arg2.SetAttribute then
				arg2:SetAttribute("Spread", 0)
				arg2:SetAttribute("Recoil", 0)
			end
		end)
	end

	local function fn44()
		pcall(function()
			local weapons = ReplicatedStorage:FindFirstChild("Weapons")

			if weapons and weapons:FindFirstChild("Guns") then
				for _, child in ipairs(weapons.Guns:GetChildren()) do
					fn43(child)
				end
			end

			local getCharacter = MainModule.get_character and MainModule.get_character()

			if getCharacter then
				for _, child in ipairs(getCharacter:GetChildren()) do
					if child:IsA("Tool") then
						fn43(child)
					end
				end
			end

			local backpack = localPlayer2:FindFirstChild("Backpack")

			if backpack then
				for _, child in ipairs(backpack:GetChildren()) do
					if child:IsA("Tool") then
						fn43(child)
					end
				end
			end
		end)
	end

	fn44()

	MainModule.NoRecoilConnection = RunService2.RenderStepped:Connect(function()
		if not MainModule.NoRecoilEnabled then
			return
		end
		fn42()
		fn44()
	end)

	if fn22 then
		fn22()
	end

	return true
end

MainModule.toggle_spikes_esp = function(arg)
	MainModule.SpikesESPEnabled = arg and true or false

	for _, spikesESPObject in pairs(MainModule.SpikesESPObjects) do
		pcall(function()
			if type(spikesESPObject) == "table" then
				for _, v3 in pairs(spikesESPObject) do
					if v3 and v3.Destroy then
						v3:Destroy()
					end
				end
			elseif spikesESPObject and spikesESPObject.Destroy then
				spikesESPObject:Destroy()
			end
		end)
	end

	MainModule.SpikesESPObjects = {}

	if MainModule.SpikesESPConn then
		pcall(function()
			MainModule.SpikesESPConn:Disconnect()
		end)

		MainModule.SpikesESPConn = nil
	end

	if MainModule.SpikesESPFolder then
		pcall(function()
			MainModule.SpikesESPFolder:Destroy()
		end)

		MainModule.SpikesESPFolder = nil
	end

	if not arg then
		fn22()
		return true
	end
	local folder = Instance.new("Folder")
	folder.Name = "HSX_SpikesESP"
	folder.Parent = workspace
	MainModule.SpikesESPFolder = folder

	local function fn42()
		local tbl8 = {}

		local function fn43(arg2)
			if arg2 and not tbl8[arg2] then
				tbl8[arg2] = true
			end
		end

		local hideAndSeekMap = workspace:FindFirstChild("HideAndSeekMap") or Workspace:FindFirstChild("HideAndSeekMap")

		if hideAndSeekMap then
			fn43(hideAndSeekMap:FindFirstChild("KillingParts"))

			for _, descendant in ipairs(hideAndSeekMap:GetDescendants()) do
				if descendant.Name == "KillingParts" then
					fn43(descendant)
				end
			end
		end

		for _, descendant in ipairs(workspace:GetDescendants()) do
			if descendant.Name == "KillingParts" then
				fn43(descendant)
			end
		end

		local tbl9 = {}

		for k in pairs(tbl8) do
			table.insert(tbl9, k)
		end

		return tbl9
	end

	local function fn43(adornee)
		if not adornee or not adornee:IsA("BasePart") then
			return
		end

		if MainModule.SpikesESPObjects[adornee] then
			return
		end
		local highlight = Instance.new("Highlight")
		highlight.Name = "HSX_SpikeHL"
		highlight.Adornee = adornee
		highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
		highlight.FillColor = Color3.fromRGB(0, 0, 0)
		highlight.OutlineColor = Color3.fromRGB(0, 0, 0)
		highlight.FillTransparency = 0.35
		highlight.OutlineTransparency = 0
		highlight.Parent = folder
		MainModule.SpikesESPObjects[adornee] = highlight

		pcall(function()
			local boxHandleAdornment = Instance.new("BoxHandleAdornment")
			boxHandleAdornment.Name = "HSX_SpikeBox"
			boxHandleAdornment.Adornee = adornee
			boxHandleAdornment.AlwaysOnTop = true
			boxHandleAdornment.ZIndex = 10
			boxHandleAdornment.Size = adornee.Size
			boxHandleAdornment.Color3 = Color3.fromRGB(0, 0, 0)
			boxHandleAdornment.Transparency = 0.4
			boxHandleAdornment.Parent = folder
			MainModule.SpikesESPObjects[adornee] = { highlight, boxHandleAdornment }
		end)
	end

	local function fn44()
		if not MainModule.SpikesESPEnabled then
			return
		end

		for _, v3 in ipairs(fn42()) do
			for _, descendant in ipairs(v3:GetDescendants()) do
				if descendant:IsA("BasePart") then
					fn43(descendant)
				end
			end

			for _, child in ipairs(v3:GetChildren()) do
				if child:IsA("BasePart") then
					fn43(child)
				elseif child:IsA("Model") then
					for _, descendant in ipairs(child:GetDescendants()) do
						if descendant:IsA("BasePart") then
							fn43(descendant)
						end
					end
				end
			end
		end
	end

	fn44()

	MainModule.SpikesESPConn = RunService2.Heartbeat:Connect(function()
		if not MainModule.SpikesESPEnabled then
			return
		end

		if not MainModule._spikes_esp_t then
			MainModule._spikes_esp_t = 0
		end

		local spikesEspT = MainModule._spikes_esp_t
		if tick() - spikesEspT < 0.75 then
			return
		end
		MainModule._spikes_esp_t = tick()
		fn44()
	end)

	fn22()
	return true
end

local v3 = nil
MainModule._PlayerStatLabels = MainModule._PlayerStatLabels or {}

local function fn42(arg)
	local playerStatLabels = MainModule._PlayerStatLabels
	if not playerStatLabels or not next(playerStatLabels) then
		return
	end

	local function fn43(arg2, arg3)
		local v4 = playerStatLabels[arg2]
		if not v4 then
			return
		end

		pcall(function()
			if v4.SetTitle then
				v4:SetTitle(arg3)
			elseif v4.SetDesc then
				v4:SetDesc(arg3)
			elseif v4.SetText then
				v4:SetText(arg3)
			end
		end)
	end

	if not arg or not arg.Parent then
		for k in pairs(playerStatLabels) do
			fn43(k, k:gsub("^%l", string.upper) .. ": -")
		end

		return
	end

	local attributes = arg:GetAttributes()

	local function fn44(arg2)
		local str = tostring(math.floor(tonumber(arg2) or 0)):reverse():gsub("(%d%d%d)", "%1,"):reverse()

		if str:sub(1, 1) == "," then
			str = str:sub(2)
		end

		return str
	end

	fn43("Wins", "Wins: " .. fn44(attributes._GameWins or 0))
	fn43("Money", "Money: " .. fn44(attributes._Won or 0))
	fn43("Power", "Equipped Power: " .. tostring(attributes._EquippedPower or "-"))
	fn43("GuardPower", "Guard Power: " .. tostring(attributes._EquippedGuardPower or "-"))
	fn43("Level", "Level: " .. tostring(attributes._CurrentLevel or attributes._Level or attributes.Level or 0))
	fn43("PowerSpins", "Power Spins: " .. fn44(attributes._TotalPowerSpins or 0))
	fn43("GuardSpins", "Guard Spins: " .. fn44(attributes._TotalGuardPowerSpins or 0))
	fn43("Robux", "Robux Donated: " .. fn44(attributes._TotalRobuxDonated or attributes._RobuxDonated or 0))
	fn43("VIP", "VIP: " .. (attributes.__OwnsVIPGamepass and "Yes" or "No"))
	fn43("PermGuard", "Perm Guard: " .. (attributes.__OwnsPermGuard and "Yes" or "No"))
	fn43("Lighter", "Lighter: " .. (attributes.HasLighter and "Yes" or "No"))
end

Players2.PlayerAdded:Connect(function()
end)

Players2.PlayerRemoving:Connect(function()
	if v3 and not v3.Parent then
		v3 = nil
		fn42(nil)
	end
end)

RunService2.Heartbeat:Connect(function()
	if v3 and v3.Parent then
		fn42(v3)
	end
end)

local tbl8 = {}

local function fn43()
	tbl8 = {}

	for _, player in pairs(Players2:GetPlayers()) do
		if player ~= localPlayer2 then
			table.insert(tbl8, player.Name)
		end
	end

	if #tbl8 == 0 then
		table.insert(tbl8, "No players")
	end
end

fn43()
local v4 = nil

Players2.PlayerAdded:Connect(function()
	task.wait(0.1)
	fn43()
end)

Players2.PlayerRemoving:Connect(function()
	task.wait(0.1)

	if v4 and not Players2:FindFirstChild(v4.Name) then
		v4 = nil
	end

	fn43()
end)

MainModule.PeabertEnabled = false
MainModule.PeabertShotsPerTick = 15
MainModule.PeabertConnection = nil

MainModule.start_peabert_loop = function()
	if MainModule.PeabertConnection then
		MainModule.PeabertConnection:Disconnect()
		MainModule.PeabertConnection = nil
	end

	MainModule.PeabertConnection = RunService2.RenderStepped:Connect(function()
		if not MainModule.PeabertEnabled then
			return
		end
		local v5 = MainModule.get_character()
		local backpack = localPlayer2:FindFirstChild("Backpack")
		local v6 = nil

		if v5 then
			v6 = nil

			for _, child in ipairs(v5:GetChildren()) do
				if child:IsA("Tool") and (child:GetAttribute("Gun") or child:FindFirstChild("GunScript") or string.lower(child.Name):find("gun")) then
					v6 = child
					break
				else
					v6 = nil
				end
			end
		end

		if not v6 and backpack then
			for _, child in ipairs(backpack:GetChildren()) do
				if child:IsA("Tool") and (child:GetAttribute("Gun") or child:FindFirstChild("GunScript") or string.lower(child.Name):find("gun")) then
					v6 = child
					break
				end
			end
		end

		if not v6 then
			return
		end
		local tbl9 = {}
		local live = workspace:FindFirstChild("Live")

		if live then
			for i = 1, 10 do
				local str = "EvilPeabert1_" .. i
				local v7 = live:FindFirstChild(str)

				if v7 and not v7:FindFirstChild("Dead") then
					tbl9[str] = "Head"
				end
			end

			for _, child in ipairs(live:GetChildren()) do
				if not child:FindFirstChild("Dead") then
					local name = child.Name

					if name:match("^PeabertSpawn%d+$") then
						local num = tonumber(name:match("%d+"))

						if num and num >= 1 and num <= 31 then
							tbl9[name] = "Head"
						end
					end

					if name:lower():find("peabert") or name:lower():find("evilpeabert") then
						tbl9[name] = "Head"
					end
				end
			end
		end

		for _, descendant in ipairs(workspace:GetDescendants()) do
			if (descendant:IsA("Model") or descendant:IsA("BasePart")) and not descendant:FindFirstChild("Dead") then
				local name = descendant.Name

				if name:match("^EvilPeabert1_%d+$") or name:match("^PeabertSpawn%d+$") or name:lower():find("peabert") then
					tbl9[name] = "Head"
				end
			end
		end

		if next(tbl9) ~= nil then
			local remotes = ReplicatedStorage:FindFirstChild("Remotes")

			if remotes then
				local firedGunClient = remotes:FindFirstChild("FiredGunClient")

				if firedGunClient then
					local part = workspace:FindFirstChild("StairWalkWay") and workspace.StairWalkWay:FindFirstChild("Part") or workspace
					local tbl10 = {}

					local tbl11 = {
						ClientRayNormal = Vector3.new(0, 1, 0),
						FiredGun = true,
						SecondaryHitTargets = {},
						ClientRayInstance = part,
						ClientRayPosition = Vector3.zero,
						bulletCF = CFrame.new(),
						HitTargets = tbl9,
						bulletSizeC = Vector3.new(0.01, 0.01, 5),
						NoMuzzleFX = true,
						FirePosition = Vector3.zero,
					}

					tbl10[1] = v6
					tbl10[2] = tbl11

					for i = 1, MainModule.PeabertShotsPerTick do
						pcall(function()
							firedGunClient:FireServer(unpack(tbl10))
						end)
					end
				end
			end
		end
	end)
end

MainModule.toggle_peabert_kill = function(peabertEnabled)
	MainModule.PeabertEnabled = peabertEnabled

	if MainModule.PeabertConnection then
		MainModule.PeabertConnection:Disconnect()
		MainModule.PeabertConnection = nil
	end

	if peabertEnabled then
		MainModule.start_peabert_loop()
	end

	fn22()
end

MainModule.set_peabert_shots_per_tick = function(peabertShotsPerTick)
	MainModule.PeabertShotsPerTick = peabertShotsPerTick
end

MainModule.FakeLightningAwakeningEnabled = false
MainModule._LA_Inited = false

MainModule.toggle_fake_lightning_awakening = function(arg)
	MainModule.FakeLightningAwakeningEnabled = arg and true or false

	if not arg then
		pcall(function()
			local backpack = localPlayer2:FindFirstChild("Backpack")

			if backpack then
				local lightningAwakening = backpack:FindFirstChild("LIGHTNING AWAKENING")

				if lightningAwakening then
					lightningAwakening:Destroy()
				end
			end

			local character = localPlayer2.Character

			if character then
				local lightningAwakening = character:FindFirstChild("LIGHTNING AWAKENING")

				if lightningAwakening then
					lightningAwakening:Destroy()
				end
			end
		end)

		fn22()
		return true
	end

	if not MainModule._LA_Inited then
		MainModule._LA_Inited = true
		MainModule._LA_Start()
	end

	fn22()
	return true
end

MainModule._LA_Start = function()
	local Players3 = game:GetService("Players")
	local RunService3 = game:GetService("RunService")
	local TweenService2 = game:GetService("TweenService")
	local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
	local Debris = game:GetService("Debris")
	local localPlayer3 = Players3.LocalPlayer
	local currentCamera = workspace.CurrentCamera
	local lightninggodawakening = ReplicatedStorage2:FindFirstChild("Effects") and ReplicatedStorage2.Effects:FindFirstChild("SetupParts") and ReplicatedStorage2.Effects.SetupParts:FindFirstChild("CustomEffectsFolders") and ReplicatedStorage2.Effects.SetupParts.CustomEffectsFolders:FindFirstChild("LIGHTNINGGODAWAKENING")
	local animations = ReplicatedStorage2:FindFirstChild("Animations")
	local lightningGodAwakening = animations and animations:FindFirstChild("Abilities") and animations.Abilities:FindFirstChild("LightningGodAwakening")
	local lightningAwakening = ReplicatedStorage2:FindFirstChild("CustomCameraModules") and ReplicatedStorage2.CustomCameraModules:FindFirstChild("LightningAwakening")
	local modules = ReplicatedStorage2:FindFirstChild("Modules")
	local Effects = nil
	local EffectsSecond = nil

	pcall(function()
		Effects = modules and modules:FindFirstChild("Effects") and require(modules.Effects)
	end)

	pcall(function()
		EffectsSecond = modules and modules:FindFirstChild("EffectsSecond") and require(modules.EffectsSecond)
	end)

	local v5 = nil

	if lightningAwakening then
		pcall(function()
			local module = require(lightningAwakening)

			if typeof(module) == "function" then
				v5 = module()
			else
				v5 = module
			end
		end)
	end

	local fov = v5 and v5.FOV
	local frames = v5 and v5.Frames

	if not fov then
		fov = {}

		for i = 1, 250 do
			fov[i] = 70
		end
	end

	if not frames then
		frames = {}

		for i = 1, 250 do
			frames[i] = { 0, 2, -8, -1, 0, 0, 0, 1, 0, 0, 0, -1 }
		end
	end

	local flag3 = false
	local flag4 = false
	local flag5 = false

	local function fn44(arg)
		return CFrame.new(arg[1], arg[2], arg[3], arg[4], arg[5], arg[6], arg[7], arg[8], arg[9], arg[10], arg[11], arg[12])
	end

	local function fn45(arg, parent, part0, c0)
		if not arg or not parent or not part0 then
			return nil
		end
		local clone = arg:Clone()

		if clone:IsA("BasePart") then
			clone.Anchored = false
			clone.CanCollide = false
			clone.Massless = true
			local weld = Instance.new("Weld")
			weld.Part0 = part0
			weld.Part1 = clone
			c0 = c0 or CFrame.new()
			weld.C0 = c0
			weld.Parent = clone
			clone.Parent = parent
		elseif clone:IsA("Model") then
			clone.Parent = parent

			for _, v6 in clone:GetDescendants() do
				if v6 and v6:IsA("BasePart") then
					v6.Anchored = false
					v6.CanCollide = false
					v6.Massless = true
					local weld = Instance.new("Weld")
					weld.Part0 = part0
					weld.Part1 = v6
					weld.C0 = c0 or CFrame.new()
					weld.Parent = v6
				end
			end
		end

		for _, v6 in clone:GetDescendants() do
			if v6 then
				if v6:IsA("ParticleEmitter") then
					v6.Enabled = true
				end

				if v6:IsA("PointLight") then
					v6.Enabled = true
				end
			end
		end

		return clone
	end

	local function fn46(arg)
		if not arg:FindFirstChild("HumanoidRootPart") then
			return nil
		end
		local tbl9 = {}

		for _, v6 in arg:GetDescendants() do
			tbl9[v6] = v6.Archivable
			v6.Archivable = true
		end

		local archivable = arg.Archivable
		arg.Archivable = true

		local ok, result = pcall(function()
			return arg:Clone()
		end)

		arg.Archivable = archivable

		for k, v6 in tbl9, nil, nil do
			if k and k.Parent then
				pcall(function()
					k.Archivable = v6
				end)
			end
		end

		if not ok or not result then
			return nil
		end
		result.Name = "FakeChar_LightningAwakening"
		local tbl10 = {}

		for _, v6 in result:GetDescendants() do
			if v6:IsA("Script") or v6:IsA("LocalScript") or v6:IsA("Tool") or v6:IsA("ModuleScript") then
				table.insert(tbl10, v6)
			end
		end

		for _, v6 in tbl10, nil, nil do
			pcall(function()
				if v6 and v6.Parent then
					v6:Destroy()
				end
			end)
		end

		for _, v6 in result:GetDescendants() do
			if v6 and v6:IsA("BasePart") then
				pcall(function()
					v6.CanCollide = false
					v6.CanQuery = false
					v6.CanTouch = false
					v6.Massless = true
					v6.Anchored = false
				end)
			end
		end

		local humanoidRootPart = result:FindFirstChild("HumanoidRootPart")

		if humanoidRootPart then
			humanoidRootPart.Anchored = true
		end

		local humanoid = result:FindFirstChildOfClass("Humanoid")

		if humanoid then
			pcall(function()
				humanoid.DisplayDistanceType = Enum.HumanoidDisplayType.None
				humanoid.HealthDisplayType = Enum.HumanoidHealthDisplayType.AlwaysOff
				humanoid.BreakJointsOnDeath = false
				humanoid.RequiresNeck = false
			end)
		end

		result.Parent = workspace
		return result
	end

	local function fn47(arg, arg2, arg3, cFrame, anchored, arg4, arg5, arg6, arg7)
		if arg and arg.Parent then
			for _, v6 in arg:GetDescendants() do
				if v6 and v6:IsA("BasePart") then
					pcall(function()
						v6.LocalTransparencyModifier = 0
					end)
				end
			end
		end

		if arg3 and arg3.Parent then
			pcall(function()
				arg3.Anchored = false
				arg3.CFrame = cFrame
				arg3.Anchored = anchored
				arg3.AssemblyLinearVelocity = Vector3.zero
				arg3.AssemblyAngularVelocity = Vector3.zero
			end)
		end

		pcall(function()
			local v6 = currentCamera
			local v7 = arg7
			local custom

			if arg7 then
				custom = v7
			else
				custom = Enum.CameraType.Custom
			end

			v6.CameraType = custom
			TweenService2:Create(currentCamera, TweenInfo.new(0.5, Enum.EasingStyle.Quad), { FieldOfView = arg6 or 70 }):Play()
		end)

		if arg2 and arg2.Parent then
			pcall(function()
				arg2.WalkSpeed = arg4 and arg4 > 0 and arg4 or 16
				arg2.JumpPower = arg5 and arg5 > 0 and arg5 or 50
				arg2.JumpHeight = 7.2
				arg2.AutoRotate = true
				arg2.PlatformStand = false
				arg2.Sit = false
				arg2:ChangeState(Enum.HumanoidStateType.GettingUp)
			end)
		end
	end

	local function fn48()
		if flag3 or flag4 or not MainModule.FakeLightningAwakeningEnabled then
			return
		end
		local character = localPlayer3.Character
		if not character then
			return
		end
		local humanoid = character:FindFirstChild("Humanoid")
		local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
		local head = character:FindFirstChild("Head")
		if not humanoid or not humanoidRootPart then
			return
		end
		flag3 = true
		flag4 = true
		local fieldOfView = currentCamera.FieldOfView
		local cameraType = currentCamera.CameraType
		local walkSpeed = humanoid.WalkSpeed
		local jumpPower = humanoid.JumpPower
		local cFrame = humanoidRootPart.CFrame
		local anchored = humanoidRootPart.Anchored
		local flag6 = false

		local function fn49()
			if flag6 then
				return
			end
			flag6 = true

			pcall(function()
				fn47(character, humanoid, humanoidRootPart, cFrame, anchored, walkSpeed, jumpPower, fieldOfView, cameraType)
			end)

			flag3 = false

			task.delay(3, function()
				flag4 = false
			end)
		end

		if not pcall(function()
			humanoid.WalkSpeed = 0
			humanoid.JumpPower = 0
			humanoid.AutoRotate = false
			local v6 = fn46(character)

			if not v6 then
				error("Failed to create fake character")
			end

			local humanoidRootPart2 = v6:FindFirstChild("HumanoidRootPart")
			local humanoid2 = v6:FindFirstChildOfClass("Humanoid")
			local head2 = v6:FindFirstChild("Head")

			if humanoidRootPart2 then
				humanoidRootPart2.CFrame = cFrame
			end

			local tbl9 = {}

			for _, v7 in {
				"Head",
				"Torso",
				"Left Arm",
				"Right Arm",
				"Left Leg",
				"Right Leg",
				"UpperTorso",
				"LowerTorso",
				"LeftUpperArm",
				"RightUpperArm",
				"LeftLowerArm",
				"RightLowerArm",
				"LeftUpperLeg",
				"RightUpperLeg",
				"LeftLowerLeg",
				"RightLowerLeg",
				"LeftHand",
				"RightHand",
				"LeftFoot",
				"RightFoot",
			}, nil, nil do
				local v8 = v6:FindFirstChild(v7)

				if v8 and v8:IsA("BasePart") then
					table.insert(tbl9, v8)
				end
			end

			local function fn50()
				local tbl10 = {}

				for _, v7 in tbl9, nil, nil do
					if v7 and typeof(v7) == "Instance" and v7.Parent then
						table.insert(tbl10, v7)
					end
				end

				return tbl10
			end

			humanoidRootPart.Anchored = true
			task.wait()
			humanoidRootPart.CFrame = cFrame * CFrame.new(0, 150, 0)
			humanoidRootPart.Anchored = true

			for _, v7 in character:GetDescendants() do
				if v7 and v7:IsA("BasePart") then
					pcall(function()
						v7.LocalTransparencyModifier = 1
					end)
				end
			end

			local connection = RunService3.Heartbeat:Connect(function()
				if v6 and v6.Parent and humanoidRootPart2 and humanoidRootPart2.Parent then
					humanoidRootPart2.CFrame = cFrame
				end
			end)

			local connection2 = RunService3.Heartbeat:Connect(function()
				if flag3 and humanoidRootPart and humanoidRootPart.Parent then
					humanoidRootPart.CFrame = cFrame * CFrame.new(0, 150, 0)
					humanoidRootPart.AssemblyLinearVelocity = Vector3.zero
					humanoidRootPart.AssemblyAngularVelocity = Vector3.zero
				end
			end)

			local v7 = nil

			if lightningGodAwakening and humanoid2 then
				pcall(function()
					local animation = Instance.new("Animation")
					animation.AnimationId = lightningGodAwakening.AnimationId
					local animator = humanoid2:FindFirstChildOfClass("Animator")

					if not animator then
						animator = Instance.new("Animator")
						animator.Parent = humanoid2
					end

					v7 = animator:LoadAnimation(animation)
					v7.Priority = Enum.AnimationPriority.Action4
					v7:Play()
				end)
			end

			local sound = nil

			if humanoidRootPart2 then
				sound = Instance.new("Sound")
				sound.SoundId = "rbxassetid://103481331692768"
				sound.Volume = 2
				sound.RollOffMaxDistance = 300
				sound.Parent = humanoidRootPart2
				sound:Play()
			end

			local n = 0.016666666666666666
			local n2 = math.min(#frames, #fov)
			local n3 = n2 * n
			currentCamera.CameraType = Enum.CameraType.Scriptable
			local now = tick()
			local connection3 = nil

			connection3 = RunService3.RenderStepped:Connect(function()
				local n4 = (tick() - now) / n
				local n5 = math.floor(n4) + 1

				if n5 > n2 then
					pcall(function()
						connection3:Disconnect()
					end)

					return
				end

				local n6 = n4 - math.floor(n4)
				local n7 = math.min(n5 + 1, n2)
				currentCamera.FieldOfView = fov[n5] + (fov[n7] - fov[n5]) * n6
				currentCamera.CFrame = cFrame * fn44(frames[n5]):Lerp(fn44(frames[n7]), n6)
			end)

			if Effects and Effects.PrepFrame then
				local tbl10 = {}
				local impactFrames = ReplicatedStorage2:FindFirstChild("ImpactFrames")

				if impactFrames then
					local lightningGod = impactFrames:FindFirstChild("LightningGod")

					if lightningGod then
						for _, v8 in lightningGod:GetDescendants() do
							if v8 and v8.ClassName == "ImageLabel" then
								table.insert(tbl10, v8.Image)
							end
						end
					end
				end

				if #tbl10 > 0 then
					task.spawn(function()
						pcall(function()
							Effects.PrepFrame({ EffectName = "PrepFrame", ImageTable = tbl10 })
						end)
					end)
				end
			end

			pcall(function()
				if lightninggodawakening and lightninggodawakening:FindFirstChild("start") then
					for _, v8 in lightninggodawakening.start:GetChildren() do
						if v8 and v8:IsA("ParticleEmitter") then
							local name = v8.Name

							for _, v9 in fn50() do
								if v9.Name ~= "Head" or name ~= "Lightning1" then
									local clone = v8:Clone()
									clone.Enabled = true
									clone.Parent = v9

									task.delay(1.52, function()
										if clone and clone.Parent then
											clone.Enabled = false
										end
									end)

									Debris:AddItem(clone, 1.6)
								end
							end
						end
					end
				end
			end)

			task.delay(1.55, function()
				if not flag3 then
					return
				end

				pcall(function()
					if lightninggodawakening and lightninggodawakening:FindFirstChild("Aura1") and humanoidRootPart2 and humanoidRootPart2.Parent then
						local v8 = fn45(lightninggodawakening.Aura1, v6, humanoidRootPart2, CFrame.new(-0.386, -0.425, -0.538))

						if v8 then
							task.delay(1.33, function()
								if v8 and v8.Parent then
									for _, v9 in v8:GetDescendants() do
										if v9 and v9:IsA("ParticleEmitter") then
											v9.Enabled = false
										end
									end
								end
							end)

							Debris:AddItem(v8, 2.3)
						end
					end

					if lightninggodawakening and lightninggodawakening:FindFirstChild("eyes") and head2 and head2.Parent then
						for _, v8 in lightninggodawakening.eyes:GetChildren() do
							if v8 and v8:IsA("Attachment") then
								local clone = v8:Clone()
								clone.Parent = head2

								for _, v9 in clone:GetDescendants() do
									if v9 and v9:IsA("ParticleEmitter") then
										v9.Enabled = true
									end
								end

								Debris:AddItem(clone, 2.61)
							end
						end
					end
				end)
			end)

			task.delay(2.85, function()
				if not flag3 then
					return
				end

				pcall(function()
					if lightninggodawakening and lightninggodawakening:FindFirstChild("Strike") and humanoidRootPart2 and humanoidRootPart2.Parent then
						local strike = lightninggodawakening.Strike
						local model = strike:FindFirstChild("Model")

						if model then
							local v8 = fn45(model, v6, humanoidRootPart2, CFrame.new(0.221, 14.591, -2.723))

							if v8 then
								Debris:AddItem(v8, 2.5)
							end
						end

						local lightningImpactGround = strike:FindFirstChild("LightningImpactGround")

						if lightningImpactGround then
							local v8 = fn45(lightningImpactGround, v6, humanoidRootPart2, CFrame.new(0.222, -0.35, -2.723))

							if v8 then
								Debris:AddItem(v8, 2.5)
								local blastLight = v8:FindFirstChild("BlastLight", true)

								if not blastLight then
									local impact = v8:FindFirstChild("Impact", true)

									if impact then
										blastLight = impact:FindFirstChild("BlastLight")
									end
								end

								if blastLight and blastLight:IsA("PointLight") then
									blastLight.Enabled = true

									task.delay(0.42, function()
										if blastLight and blastLight.Parent then
											TweenService2:Create(blastLight, TweenInfo.new(0.35, Enum.EasingStyle.Linear), { Brightness = 2 }):Play()
										end
									end)
								end
							end
						end
					end

					if lightninggodawakening and lightninggodawakening:FindFirstChild("Lines1") then
						local lines1 = lightninggodawakening.Lines1

						if lines1:IsA("ParticleEmitter") then
							for _, v8 in fn50() do
								local clone = lines1:Clone()
								clone.Enabled = true
								clone.Parent = v8
								Debris:AddItem(clone, 0.8)
							end
						end
					end

					if lightninggodawakening and lightninggodawakening:FindFirstChild("AuraLightning") then
						for _, v8 in lightninggodawakening.AuraLightning:GetChildren() do
							if v8 and v8:IsA("ParticleEmitter") then
								for _, v9 in fn50() do
									local clone = v8:Clone()
									clone.Enabled = true
									clone.Parent = v9
									Debris:AddItem(clone, 0.8)
								end
							end
						end
					end

					local character2 = localPlayer3.Character

					if character2 and character2:FindFirstChild("Remotes") then
						local relay = character2.Remotes:FindFirstChild("Relay")

						if relay then
							relay:Fire({
								EffectName = "MauioShake",
								Length = 0.45,
								TweenSpeed = 0.075,
								AxisMultipliers = Vector3.new(1, 0.15, 1),
								FadeStyle = "inQuad",
								PositionStyle = "inCubic",
								Intensity = 2,
							})
						end
					end
				end)
			end)

			task.delay(2.9, function()
				if not flag3 then
					return
				end

				if EffectsSecond and EffectsSecond.ImpactFrames then
					pcall(function()
						EffectsSecond.ImpactFrames({ foldername = "LightningGod", displaytime = 0.015 })
					end)
				end
			end)

			task.delay(3.65, function()
				if not flag3 then
					return
				end

				pcall(function()
					if lightninggodawakening and lightninggodawakening:FindFirstChild("Glow") then
						local glow = lightninggodawakening.Glow

						if glow:IsA("ParticleEmitter") then
							for _, v8 in fn50() do
								local clone = glow:Clone()
								clone.Enabled = true
								clone.Parent = v8
								Debris:AddItem(clone, 0.52)
							end
						end
					end
				end)
			end)

			task.delay(n3, function()
				pcall(function()
					connection2:Disconnect()
				end)

				pcall(function()
					connection:Disconnect()
				end)

				pcall(function()
					connection3:Disconnect()
				end)

				if sound and sound.Parent then
					pcall(function()
						sound:Stop()
						sound:Destroy()
					end)
				end

				if v7 then
					pcall(function()
						v7:Stop(0.3)
					end)
				end

				fn49()

				if humanoidRootPart and humanoidRootPart.Parent then
					local sound2 = Instance.new("Sound")
					sound2.SoundId = "rbxassetid://97926606277706"
					sound2.Volume = 1.5
					sound2.RollOffMaxDistance = 300
					sound2.Parent = humanoidRootPart
					sound2:Play()
					Debris:AddItem(sound2, 10)
				end

				pcall(function()
					if lightninggodawakening and lightninggodawakening:FindFirstChild("LingeringAura") and character and character.Parent then
						for _, v8 in lightninggodawakening.LingeringAura:GetChildren() do
							if v8 and v8:IsA("ParticleEmitter") then
								for _, v9 in { "Torso", "UpperTorso", "Left Arm", "Right Arm" }, nil, nil do
									local v10 = character:FindFirstChild(v9)

									if v10 and v10:IsA("BasePart") then
										local clone = v8:Clone()
										clone.Enabled = true
										clone.Parent = v10
										Debris:AddItem(clone, 6)

										task.delay(4, function()
											if clone and clone.Parent then
												clone.Enabled = false
											end
										end)
									end
								end
							end
						end
					end
				end)

				pcall(function()
					if lightninggodawakening and lightninggodawakening:FindFirstChild("eyes") and head and head.Parent then
						for _, v8 in lightninggodawakening.eyes:GetChildren() do
							if v8 and v8:IsA("Attachment") then
								local clone = v8:Clone()
								clone.Parent = head

								for _, v9 in clone:GetDescendants() do
									if v9 and v9:IsA("ParticleEmitter") then
										v9.Enabled = true
									end
								end

								Debris:AddItem(clone, 6)

								task.delay(4, function()
									if clone and clone.Parent then
										for _, v9 in clone:GetDescendants() do
											if v9 and v9:IsA("ParticleEmitter") then
												v9.Enabled = false
											end
										end
									end
								end)
							end
						end
					end
				end)

				task.delay(0.3, function()
					if v6 and v6.Parent then
						pcall(function()
							v6:Destroy()
						end)
					end
				end)
			end)
		end) then
			fn49()
		end

		task.delay(20, function()
			if not flag6 then
				fn49()
			end
		end)
	end

	local tbl9 = {}

	local function fn49(arg)
		if not arg or tbl9[arg] then
			return
		end
		tbl9[arg] = true

		local function fn50()
			local v6 = flag5
			local v7

			if flag5 then
				v7 = v6
			else
				v7 = flag3
			end

			if v7 or not MainModule.FakeLightningAwakeningEnabled then
				return
			end
			flag5 = true

			task.defer(function()
				fn48()
				task.wait(0.5)
				flag5 = false
			end)
		end

		arg.Equipped:Connect(fn50)
		arg.Activated:Connect(fn50)
	end

	local tool = Instance.new("Tool")
	tool.Name = "LIGHTNING AWAKENING"
	tool.RequiresHandle = true
	tool.CanBeDropped = false
	local part = Instance.new("Part")
	part.Name = "Handle"
	part.Size = Vector3.one
	part.Transparency = 1
	part.CanCollide = false
	part.Massless = true
	part.Parent = tool

	local function fn50()
		if not MainModule.FakeLightningAwakeningEnabled then
			return
		end
		local backpack = localPlayer3:FindFirstChild("Backpack")
		local character = localPlayer3.Character
		if not backpack then
			return
		end
		local lightningAwakening2 = backpack:FindFirstChild("LIGHTNING AWAKENING")
		character = character and character:FindFirstChild("LIGHTNING AWAKENING")

		if not lightningAwakening2 and not character then
			local clone = tool:Clone()
			clone.Parent = backpack
			fn49(clone)
		elseif lightningAwakening2 then
			fn49(lightningAwakening2)
		elseif character then
			fn49(character)
		end
	end

	localPlayer3:WaitForChild("Backpack")
	fn50()

	localPlayer3.Backpack.ChildAdded:Connect(function(child)
		if child.Name == "LIGHTNING AWAKENING" and child:IsA("Tool") then
			fn49(child)
		end
	end)

	localPlayer3.CharacterAdded:Connect(function(character)
		flag3 = false
		flag4 = false
		flag5 = false
		tbl9 = {}

		pcall(function()
			currentCamera.CameraType = Enum.CameraType.Custom
			currentCamera.FieldOfView = 70
		end)

		task.wait(1)
		fn50()

		character.ChildAdded:Connect(function(child)
			if child.Name == "LIGHTNING AWAKENING" and child:IsA("Tool") then
				fn49(child)
			end
		end)
	end)
end

MainModule.ESPPowersEnabled = false
MainModule.ESPPowersDrawings = {}
MainModule.ESPPowersConnection = nil

MainModule.clear_esp_powers = function()
	for _, espPowersDrawing in pairs(MainModule.ESPPowersDrawings) do
		pcall(function()
			if espPowersDrawing.Remove then
				espPowersDrawing:Remove()
			elseif espPowersDrawing.Destroy then
				espPowersDrawing:Destroy()
			end
		end)
	end

	MainModule.ESPPowersDrawings = {}

	if MainModule.ESPPowersConnection then
		pcall(function()
			MainModule.ESPPowersConnection:Disconnect()
		end)

		MainModule.ESPPowersConnection = nil
	end
end

MainModule.toggle_esp_powers = function(arg)
	MainModule.ESPPowersEnabled = arg and true or false
	MainModule.clear_esp_powers()

	if not arg then
		if fn22 then
			fn22()
		end

		return true
	end

	local function fn44(arg2)
		if not arg2 then
			return nil
		end
		local tbl9 = { "_EquippedPower", "EquippedPower", "Power", "CurrentPower", "Ability" }

		for _, v5 in ipairs(tbl9) do
			local attribute = arg2:GetAttribute(v5)
			if attribute ~= nil and attribute ~= false and attribute ~= "" and attribute ~= 0 then
				return tostring(attribute)
			end
		end

		local character = arg2.Character

		if character then
			for _, v5 in ipairs(tbl9) do
				local attribute = character:GetAttribute(v5)
				if attribute ~= nil and attribute ~= false and attribute ~= "" and attribute ~= 0 then
					return tostring(attribute)
				end
			end

			for _, descendant in ipairs(character:GetDescendants()) do
				if descendant.Name == "_EquippedPower" or descendant.Name == "EquippedPower" or descendant.Name == "Power" then
					if descendant:IsA("StringValue") or descendant:IsA("NumberValue") then
						return tostring(descendant.Value)
					end
					local attribute = descendant:GetAttribute("Value") or descendant:GetAttribute("Name")
					if attribute then
						return tostring(attribute)
					end
				end
			end
		end

		return nil
	end

	MainModule.ESPPowersConnection = RunService2.RenderStepped:Connect(function()
		if not MainModule.ESPPowersEnabled then
			return
		end
		local currentCamera = workspace.CurrentCamera
		if not currentCamera then
			return
		end
		local tbl9 = {}

		for _, player in ipairs(Players2:GetPlayers()) do
			if player ~= localPlayer2 and player.Character then
				local v5 = fn44(player)

				if v5 then
					local head = player.Character:FindFirstChild("Head") or player.Character:FindFirstChild("HumanoidRootPart")

					if head then
						local v6, v7 = currentCamera:WorldToViewportPoint(head.Position + Vector3.new(0, 2.2, 0))
						local userId = player.UserId
						tbl9[userId] = true
						local text = MainModule.ESPPowersDrawings[userId]

						if not text then
							text = Drawing.new("Text")
							text.Center = true
							text.Outline = true
							text.Size = 16
							text.Font = 2
							text.Color = Color3.fromRGB(255, 255, 255)
							text.OutlineColor = Color3.fromRGB(0, 0, 0)
							MainModule.ESPPowersDrawings[userId] = text
						end

						if v7 and v6.Z > 0 then
							text.Visible = true
							text.Position = Vector2.new(v6.X, v6.Y)
							text.Text = v5
						else
							text.Visible = false
						end
					end
				end
			end
		end

		for k, espPowersDrawing in pairs(MainModule.ESPPowersDrawings) do
			if not tbl9[k] then
				pcall(function()
					if espPowersDrawing.Remove then
						espPowersDrawing:Remove()
					end
				end)

				MainModule.ESPPowersDrawings[k] = nil
			end
		end
	end)

	if fn22 then
		fn22()
	end

	return true
end

MainModule.PeabertESPEnabled = false
MainModule.PeabertESPHighlights = {}
MainModule.PeabertESPTracers = {}
MainModule.PeabertESPConnection = nil
MainModule.PeabertTargetsCache = {}
MainModule.PeabertLastScan = 0

local function fn44()
	for _, peabertESPHighlight in pairs(MainModule.PeabertESPHighlights) do
		pcall(function()
			if peabertESPHighlight and peabertESPHighlight.Parent then
				peabertESPHighlight:Destroy()
			end
		end)
	end

	MainModule.PeabertESPHighlights = {}

	for _, peabertESPTracer in pairs(MainModule.PeabertESPTracers) do
		pcall(function()
			if peabertESPTracer.Remove then
				peabertESPTracer:Remove()
			elseif peabertESPTracer.Destroy then
				peabertESPTracer:Destroy()
			end
		end)
	end

	MainModule.PeabertESPTracers = {}
end

local function fn45(arg)
	if not arg then
		return false
	end

	if arg:FindFirstChild("Dead") then
		return false
	end
	local str = arg.Name:lower()
	if str == "freepeabert" or str:find("freepeabert") then
		return true
	end
	local flag3 = false

	pcall(function()
		flag3 = arg:GetAttribute("FREEPEABERT") or arg:GetAttribute("FreePeabert")
	end)

	if flag3 then
		return true
	end

	if str:match("^peabert%d+$") then
		return true
	end

	if str:match("^peabert_%d+$") then
		return true
	end

	if str:match("^evilpeabert1_%d+$") then
		return true
	end

	if str:match("^peabertspawn%d+$") then
		return true
	end

	if str:match("^peabertshattered%d+$") then
		return true
	end

	if str:match("^peabertcrack%d+$") then
		return true
	end
	local flag4 = str == "peabert"
	local flag5

	if flag4 then
		flag5 = flag4
	else
		flag5 = str:find("peabert") and not str:find("esp")
	end

	if flag5 then
		return true
	end
	return false
end

local function fn46(arg)
	if arg:IsA("BasePart") then
		return arg
	end

	if arg:IsA("Model") then
		return arg.PrimaryPart or arg:FindFirstChild("HumanoidRootPart") or arg:FindFirstChild("Head") or arg:FindFirstChildWhichIsA("BasePart")
	end
	return arg:FindFirstChildWhichIsA("BasePart")
end

local function fn47()
	local peabertTargetsCache = {}
	local tbl9 = {}

	local function fn48(arg)
		if not arg or tbl9[arg] then
			return
		end

		if not fn45(arg) then
			return
		end
		local v5 = fn46(arg)
		if not v5 then
			return
		end
		tbl9[arg] = true
		table.insert(peabertTargetsCache, { Object = arg, Part = v5, Name = arg.Name })
	end

	local live = workspace:FindFirstChild("Live")

	if live then
		for i = 1, 10 do
			fn48(live:FindFirstChild("FREEPEABERT"))
			fn48(live:FindFirstChild("FreePeabert"))
			fn48(live:FindFirstChild("FreePeabert" .. i))
			fn48(live:FindFirstChild("Peabert" .. i))
			fn48(live:FindFirstChild("Peabert_" .. i))
			fn48(live:FindFirstChild("EvilPeabert1_" .. i))
			fn48(live:FindFirstChild("PeabertSpawn" .. i))
		end

		for _, child in ipairs(live:GetChildren()) do
			local str = child.Name:lower()

			if str:find("peabert") or str:find("freepeabert") then
				fn48(child)
			end
		end
	end

	for _, child in ipairs(workspace:GetChildren()) do
		if child.Name:lower():find("peabert") then
			fn48(child)

			for _, child2 in ipairs(child:GetChildren()) do
				fn48(child2)
			end
		end
	end

	MainModule.PeabertTargetsCache = peabertTargetsCache
	MainModule.PeabertLastScan = tick()
end

MainModule.start_peabert_esp = function()
	if MainModule.PeabertESPEnabled then
		return
	end
	MainModule.PeabertESPEnabled = true
	fn44()
	fn47()

	MainModule.PeabertESPConnection = RunService2.Heartbeat:Connect(function()
		if not MainModule.PeabertESPEnabled then
			return
		end
		local peabertLastScan = MainModule.PeabertLastScan

		if tick() - peabertLastScan > 2.5 then
			fn47()
		end

		local currentCamera = workspace.CurrentCamera
		local humanoidRootPart = localPlayer2.Character and localPlayer2.Character:FindFirstChild("HumanoidRootPart")
		local tbl9 = {}
		local vector2 = Vector2.new(0, 0)

		if currentCamera then
			vector2 = Vector2.new(currentCamera.ViewportSize.X / 2, currentCamera.ViewportSize.Y)
		end

		if humanoidRootPart and currentCamera then
			local v5 = currentCamera:WorldToViewportPoint(humanoidRootPart.Position)
			vector2 = Vector2.new(v5.X, v5.Y)
		end

		for _, v5 in ipairs(MainModule.PeabertTargetsCache) do
			local part = v5.Part
			local str = tostring(v5.Object)

			if part and part.Parent then
				tbl9[str] = true
				local v6 = MainModule.PeabertESPHighlights[str]

				if not v6 or not v6.Parent then
					local highlight = Instance.new("Highlight")
					highlight.Name = "PeabertHighlight"
					highlight.FillColor = Color3.fromRGB(255, 105, 180)
					highlight.OutlineColor = Color3.fromRGB(255, 182, 193)
					highlight.FillTransparency = 0.4
					highlight.OutlineTransparency = 0
					local object = v5.Object:IsA("Model") and v5.Object or part
					highlight.Adornee = object
					highlight.Parent = object
					MainModule.PeabertESPHighlights[str] = highlight
				else
					v6.Adornee = v5.Object:IsA("Model") and v5.Object or part
				end

				local magnitude = humanoidRootPart and (part.Position - humanoidRootPart.Position).Magnitude or 0
				local line = MainModule.PeabertESPTracers[str]

				if magnitude > 500 then
					if line then
						line.Visible = false
					end
				else
					if not line then
						line = Drawing.new("Line")
						line.Thickness = 1.5
						line.Color = Color3.fromRGB(255, 105, 180)
						line.Transparency = 1
						MainModule.PeabertESPTracers[str] = line
					end

					if currentCamera then
						local v7, v8 = currentCamera:WorldToViewportPoint(part.Position)

						if v8 and v7.Z > 0 then
							line.Visible = true
							line.From = vector2
							line.To = Vector2.new(v7.X, v7.Y)
						else
							line.Visible = false
						end
					end
				end
			end
		end

		for k, peabertESPHighlight in pairs(MainModule.PeabertESPHighlights) do
			if not tbl9[k] then
				pcall(function()
					if peabertESPHighlight and peabertESPHighlight.Parent then
						peabertESPHighlight:Destroy()
					end
				end)

				MainModule.PeabertESPHighlights[k] = nil
			end
		end

		for k, peabertESPTracer in pairs(MainModule.PeabertESPTracers) do
			if not tbl9[k] then
				pcall(function()
					if peabertESPTracer.Remove then
						peabertESPTracer:Remove()
					end
				end)

				MainModule.PeabertESPTracers[k] = nil
			end
		end
	end)

	if fn22 then
		fn22()
	end

	return true
end

MainModule.stop_peabert_esp = function()
	if not MainModule.PeabertESPEnabled then
		return
	end
	MainModule.PeabertESPEnabled = false

	if MainModule.PeabertESPConnection then
		pcall(function()
			MainModule.PeabertESPConnection:Disconnect()
		end)

		MainModule.PeabertESPConnection = nil
	end

	fn44()

	if fn22 then
		fn22()
	end
end

MainModule.toggle_peabert_esp = function(arg)
	if arg then
		return MainModule.start_peabert_esp()
	end
	MainModule.stop_peabert_esp()
	return true
end

MainModule.tp_to_peaberts = function()
	local character = localPlayer2.Character
	if not character then
		return
	end
	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	if not humanoidRootPart then
		return
	end
	fn47()
	local peabertTargetsCache = MainModule.PeabertTargetsCache

	if #peabertTargetsCache == 0 then
		if MainModule.notify then
			MainModule.notify("Peabert TP", "No Peaberts found on map!", 1.5)
		end

		return
	end

	local huge = math.huge
	local v5 = nil

	for _, v6 in ipairs(peabertTargetsCache) do
		local part = v6.Part

		if part and part.Parent then
			local str = v6.Name:lower()
			local n

			if str:find("freepeabert") or str == "freepeabert" then
				n = 0
			else
				local match = str:match("^peabert%d+$") or str:match("^peabert_%d+$")
				n = 2

				if match then
					n = 1
				end
			end

			local n2 = (part.Position - humanoidRootPart.Position).Magnitude + n * 0.001

			if n2 < huge then
				huge = n2
				v5 = part
			end
		end
	end

	if not v5 then
		if MainModule.notify then
			MainModule.notify("Peabert TP", "No Peaberts found on map!", 1.5)
		end

		return
	end

	humanoidRootPart.CFrame = CFrame.new(v5.Position + Vector3.new(0, 4, 0))

	if MainModule.notify then
		MainModule.notify("Peabert TP", "Teleported to Peabert!", 1.2)
	end
end

MainModule.AddVisualItemsEnabled = false
MainModule.AddVisualItemsConnection = nil
MainModule.AutoWinEnabled = false
MainModule.AutoWinConnection = nil
MainModule.AutoWinTriggered = {}
MainModule.CurrentGame = nil
MainModule.GameStartTime = nil
MainModule.LastNotifTime = 0
MainModule.AutoWinHunterFeatures = false

MainModule.set_auto_win_hunter_features = function(arg)
	local autoWinHunterFeatures = arg and true or false
	if MainModule.AutoWinHunterFeatures == autoWinHunterFeatures then
		return
	end
	MainModule.AutoWinHunterFeatures = autoWinHunterFeatures

	if MainModule.PlayerAttachEnabled ~= autoWinHunterFeatures then
		MainModule.toggle_player_attach(autoWinHunterFeatures)
	end

	if MainModule.FaceTargetModule and MainModule.FaceTargetModule.Enabled ~= autoWinHunterFeatures then
		MainModule.toggle_face_target(autoWinHunterFeatures)
	end

	if MainModule.SpikesKillFeature and MainModule.SpikesKillFeature.Enabled ~= autoWinHunterFeatures then
		MainModule.toggle_spikes_kill(autoWinHunterFeatures)
	end

	MainModule.toggle_noclip(autoWinHunterFeatures)

	if MainModule.ToggleRefs then
		if MainModule.ToggleRefs.PlayerAttach then
			MainModule.ToggleRefs.PlayerAttach:SetValue(autoWinHunterFeatures)
		end

		if MainModule.ToggleRefs.FaceTarget then
			MainModule.ToggleRefs.FaceTarget:SetValue(autoWinHunterFeatures)
		end

		if MainModule.ToggleRefs.SpikesKill then
			MainModule.ToggleRefs.SpikesKill:SetValue(autoWinHunterFeatures)
		end

		if MainModule.ToggleRefs.Noclip then
			MainModule.ToggleRefs.Noclip:SetValue(autoWinHunterFeatures)
		end
	end
end

local getupvalues_ = debug and (debug.getupvalues or debug.get_upvalues) or getupvalues
local setupvalue_ = debug and (debug.setupvalue or debug.setup_value) or setupvalue
local getconstants_ = debug and (debug.getconstants or debug.get_constants) or getconstants

local function fn48()
	if not getgc or not getupvalues_ or not setupvalue_ then
		return false
	end

	local ok, result = pcall(function()
		return getgc()
	end)

	if not ok or type(result) ~= "table" then
		return false
	end
	local flag3 = false

	for _, v5 in ipairs(result) do
		if type(v5) == "function" then
			local v6 = nil

			if getconstants_ then
				local ok2, result2 = pcall(function()
					return getconstants_(v5)
				end)

				v6 = nil

				if ok2 then
					v6 = result2
				end
			end

			if type(v6) == "table" then
				local flag4 = false

				for _, v7 in pairs(v6) do
					if v7 == "Progress" or v7 == "Completed" then
						flag4 = true
						break
					elseif type(v7) == "string" and v7:find("%%", 1, true) then
						flag4 = true
						break
					end
				end

				if flag4 then
					local ok2, result2 = pcall(function()
						return getupvalues_(v5)
					end)

					if ok2 and type(result2) == "table" then
						for k, v7 in pairs(result2) do
							if type(v7) == "number" and v7 == v7 and v7 >= 0 and v7 < 5000 then
								if pcall(function()
									setupvalue_(v5, k, 100000)
								end) then
									flag3 = true
								end
							end
						end
					end
				end
			end
		end
	end

	return flag3
end

MainModule.complete_dalgona = function()
	task.spawn(function()
		local flag3 = false

		for i = 1, 10 do
			if fn48() then
				flag3 = true
			end

			task.wait(0.15)
		end

		if flag3 then
			pcall(function()
				fn("Dalgona", "Dalgona Completed", 0.9)
			end)
		else
			pcall(function()
				fn("Dalgona", "Failed (no hooks?)", 0.9)
			end)
		end
	end)
end

MainModule.cleanup_auto_win_game = function(arg)
	if arg == "HideAndSeek" then
		MainModule.set_auto_win_hunter_features(false)
	end

	if arg == "Rebel" and MainModule.RebelEnabled then
		MainModule.toggle_rebel_v2(false)
	end

	if arg == "TugOfWar" or arg == "TugofWar" then
		if MainModule.TugOfWarUltraFastPull then
			MainModule.toggle_tug_of_war_ultra_fast_pull(false)
		end
	end
end

MainModule.auto_win = function()
	if not MainModule.AutoWinEnabled then
		return
	end
	local now = tick()
	local values = Workspace:FindFirstChild("Values")
	if not values then
		return
	end
	local currentGame = values:FindFirstChild("CurrentGame")
	if not currentGame then
		return
	end
	local currentGame2 = currentGame.Value
	if not currentGame2 or currentGame2 == "" then
		return
	end

	if currentGame2 ~= MainModule.CurrentGame then
		local currentGame3 = MainModule.CurrentGame

		if currentGame3 then
			MainModule.cleanup_auto_win_game(currentGame3)
		end

		MainModule.CurrentGame = currentGame2
		MainModule.GameStartTime = now

		MainModule.AutoWinTriggered = {
			Main = false,
			HunterStarted = false,
			HunterStopped = false,
			RebelStarted = false,
			TugOfWarStarted = false,
		}

		return
	end

	if not MainModule.GameStartTime then
		MainModule.GameStartTime = now
		return
	end
	local n = now - MainModule.GameStartTime
	local autoWinTriggered = MainModule.AutoWinTriggered

	if currentGame2 == "TugOfWar" or currentGame2 == "TugofWar" then
		if not autoWinTriggered.TugOfWarStarted then
			autoWinTriggered.TugOfWarStarted = true

			if not MainModule.TugOfWarUltraFastPull then
				MainModule.toggle_tug_of_war_ultra_fast_pull(true)
			end

			PlayBell()
		end

		return
	end

	local v5 = MainModule.get_character()
	if not v5 then
		return
	end
	local v6 = MainModule.get_root_part(v5)
	if not v6 then
		return
	end

	if currentGame2 == "RedLightGreenLight" then
		if not autoWinTriggered.Main and n >= 15 then
			autoWinTriggered.Main = true
			MainModule.safe_teleport(Vector3.new(-214.4, 1023.1, 146.7))
			PlayBell()
		end
	elseif currentGame2 == "Dalgona" then
		if not autoWinTriggered.Main and n >= 25 then
			autoWinTriggered.Main = true
			MainModule.complete_dalgona()
			PlayBell()
		end
	elseif currentGame2 == "LightsOut" or currentGame2 == "LightOut" then
		if not autoWinTriggered.Main and n >= 15 then
			autoWinTriggered.Main = true
			local position = v6.Position
			MainModule.safe_teleport(Vector3.new(position.X, position.Y + 100, position.Z))
			PlayBell()
		end
	elseif currentGame2 == "HideAndSeek" then
		local v7 = MainModule.is_hider(localPlayer2)
		local v8 = MainModule.is_seeker(localPlayer2)

		if v7 then
			if not autoWinTriggered.Main and n >= 15 then
				autoWinTriggered.Main = true
				local position = v6.Position
				MainModule.safe_teleport(Vector3.new(position.X, position.Y + 200, position.Z))
				PlayBell()
			end
		elseif v8 then
			if not autoWinTriggered.HunterStarted and n >= 25 then
				autoWinTriggered.HunterStarted = true
				MainModule.set_auto_win_hunter_features(true)
				PlayBell()
			end

			if autoWinTriggered.HunterStarted and not autoWinTriggered.HunterStopped and n >= 145 then
				autoWinTriggered.HunterStopped = true
				MainModule.set_auto_win_hunter_features(false)
				PlayBell()
			end
		end
	elseif currentGame2 == "JumpRope" then
		if not autoWinTriggered.Main and n >= 15 then
			autoWinTriggered.Main = true
			MainModule.safe_teleport(Vector3.new(720.89606, 198.62831, 921.17065))
			PlayBell()
		end
	elseif currentGame2 == "GlassBridge" then
		if not autoWinTriggered.Main and n >= 15 then
			autoWinTriggered.Main = true
			MainModule.safe_teleport(Vector3.new(-196.37247, 522.19214, -1534.2098))
			PlayBell()
		end
	elseif currentGame2 == "Rebel" then
		if not autoWinTriggered.RebelStarted then
			autoWinTriggered.RebelStarted = true
			local position = v6.Position
			MainModule.safe_teleport(Vector3.new(position.X, position.Y + 100, position.Z))

			if not MainModule.RebelEnabled then
				MainModule.toggle_rebel_v2(true)
			end

			PlayBell()
		end
	end
end

MainModule.toggle_auto_win = function(arg)
	local autoWinEnabled = arg and true or false
	MainModule.AutoWinEnabled = autoWinEnabled

	if MainModule.AutoWinConnection then
		MainModule.AutoWinConnection:Disconnect()
		MainModule.AutoWinConnection = nil
	end

	if not autoWinEnabled then
		MainModule.cleanup_auto_win_game(MainModule.CurrentGame)
		MainModule.set_auto_win_hunter_features(false)

		if MainModule.TugOfWarUltraFastPull then
			MainModule.toggle_tug_of_war_ultra_fast_pull(false)
		end

		if MainModule.RebelEnabled then
			MainModule.toggle_rebel_v2(false)
		end
	end

	MainModule.AutoWinTriggered = {}
	MainModule.CurrentGame = nil
	MainModule.GameStartTime = nil
	MainModule.LastNotifTime = 0

	if autoWinEnabled then
		MainModule.AutoWinConnection = RunService2.Heartbeat:Connect(function()
			MainModule.auto_win()
		end)
	end

	fn22()
	return true
end

getgenv().Time = 3
getgenv().Head = { 1095708 }
getgenv().Hand = { 3141364957 }
getgenv().Torso = { 2222720521 }

local function fn49()
	local currentCamera = workspace.CurrentCamera

	if currentCamera and currentCamera.CameraSubject then
		local cameraSubject = currentCamera.CameraSubject
		if cameraSubject and cameraSubject:IsA("Humanoid") then
			return cameraSubject.Parent
		end
	end

	for _, child in pairs(workspace:GetChildren()) do
		if child:FindFirstChild("Humanoid") and child:FindFirstChild("Head") then
			if not string.find(child.Name:lower(), "badpreload") and not string.find(child.Name:lower(), "preload") then
				return child
			end
		end
	end

	return nil
end

local function fn50(arg, part0)
	local ok, result = pcall(function()
		return game:GetObjects("rbxassetid://" .. tostring(arg))[1]
	end)

	if ok and result then
		local handle = result:FindFirstChild("Handle")

		if handle then
			local attachment = handle:FindFirstChildOfClass("Attachment")

			if attachment then
				local v5 = part0:FindFirstChild(attachment.Name)

				if v5 then
					local weld = Instance.new("Weld")
					weld.Part0 = part0
					weld.Part1 = handle
					weld.C0 = v5.CFrame
					weld.C1 = attachment.CFrame
					weld.Parent = handle
				else
					local weld = Instance.new("Weld")
					weld.Part0 = part0
					weld.Part1 = handle
					weld.C0 = CFrame.new()
					weld.C1 = CFrame.new()
					weld.Parent = handle
				end
			else
				local weld = Instance.new("Weld")
				weld.Part0 = part0
				weld.Part1 = handle
				weld.C0 = CFrame.new()
				weld.C1 = CFrame.new()
				weld.Parent = handle
			end

			handle.CanCollide = false
			result.Parent = part0.Parent
			print("Added to u: " .. tostring(arg))
		else
			warn("No Handle found in accessory: " .. tostring(arg))
		end
	else
		warn("Failed to load accessory: " .. tostring(arg))
	end
end

local function fn51(arg)
	local head = arg:FindFirstChild("Head")
	if not head then
		return
	end
	head.Transparency = 1
	head.CanCollide = false
	local decal = head:FindFirstChildOfClass("Decal")

	if decal then
		decal:Destroy()
	end

	for _, child in ipairs(head:GetChildren()) do
		if child:IsA("SpecialMesh") or child:IsA("CharacterMesh") then
			child:Destroy()
		end
	end

	local specialMesh = Instance.new("SpecialMesh")
	specialMesh.MeshType = Enum.MeshType.FileMesh
	specialMesh.MeshId = "rbxassetid://1095708"
	specialMesh.Scale = Vector3.new(0.001, 0.001, 0.001)
	specialMesh.Parent = head
end

local function fn52()
	local v5 = fn49()
	if not v5 then
		return
	end

	if v5:FindFirstChild("Head") then
		for _, v6 in ipairs(getgenv().Head) do
			fn50(v6, v5.Head)
			task.wait(0.3)
		end
	end

	local upperTorso = v5:FindFirstChild("UpperTorso") or v5:FindFirstChild("Torso")

	if upperTorso then
		for _, v6 in ipairs(getgenv().Torso) do
			fn50(v6, upperTorso)
			task.wait(0.3)
		end
	end

	local rightHand = v5:FindFirstChild("RightHand") or v5:FindFirstChild("LeftHand") or v5:FindFirstChild("Right Arm") or v5:FindFirstChild("Left Arm")

	if rightHand and getgenv().Hand then
		for _, v6 in ipairs(getgenv().Hand) do
			fn50(v6, rightHand)
			task.wait(0.3)
		end
	end

	fn51(v5)
end

MainModule.toggle_visual_items = function(addVisualItemsEnabled)
	MainModule.AddVisualItemsEnabled = addVisualItemsEnabled

	if MainModule.AddVisualItemsConnection then
		MainModule.AddVisualItemsConnection:Disconnect()
		MainModule.AddVisualItemsConnection = nil
	end

	if addVisualItemsEnabled then
		fn52()

		MainModule.AddVisualItemsConnection = localPlayer2.CharacterAdded:Connect(function()
			task.wait(1)

			if MainModule.AddVisualItemsEnabled then
				fn52()
			end
		end)
	end

	fn22()
end

local flag3 = false
local tbl9 = {}
local tbl10 = {}

local function fn53(arg)
	if arg.Name:lower():find("wall") then
		return true
	end

	if arg.Size.Y > arg.Size.X or arg.Size.Y > arg.Size.Z then
		return true
	end
	return false
end

local function fn54(arg)
	local str = arg.Name:lower()
	if str:find("floor") or str:find("ground") or str:find("plate") then
		return true
	end

	if arg.Size.Y < arg.Size.X and arg.Size.Y < arg.Size.Z then
		return true
	end
	return false
end

local function fn55(arg)
	if not arg:IsA("BasePart") then
		return
	end
	local character = localPlayer2.Character
	if character and arg:IsDescendantOf(character) then
		return
	end

	if tbl9[arg] == nil then
		tbl9[arg] = arg.CanCollide
	end

	if flag3 then
		if fn54(arg) then
			arg.CanCollide = true
		elseif fn53(arg) then
			arg.CanCollide = false
		end
	else
		arg.CanCollide = tbl9[arg]
	end
end

local function fn56()
	for _, descendant in ipairs(Workspace:GetDescendants()) do
		fn55(descendant)
	end
end

local function fn57()
	flag3 = true
	fn56()

	table.insert(tbl10, Workspace.DescendantAdded:Connect(function(descendant)
		if flag3 then
			fn55(descendant)
		end
	end))
end

local function fn58()
	flag3 = false

	for _, v5 in ipairs(tbl10) do
		pcall(function()
			v5:Disconnect()
		end)
	end

	table.clear(tbl10)

	for k, v5 in pairs(tbl9) do
		if k and k.Parent then
			pcall(function()
				k.CanCollide = v5
			end)
		end
	end

	table.clear(tbl9)
end

MainModule.toggle_noclip = function(arg)
	if arg then
		fn57()
	else
		fn58()
	end

	fn22()
	return true
end

MainModule.FreeCam = {
	Enabled = false,
	Camera = nil,
	OriginalCameraType = nil,
	OriginalCameraSubject = nil,
	OriginalCFrame = nil,
	Speed = 10,
	Sensitivity = 0.25,
	Keys = { W = false, S = false, A = false, D = false, Q = false, E = false },
	Connection = nil,
	HeartbeatConnection = nil,
	InputBegan = nil,
	InputEnded = nil,
	Yaw = 0,
	Pitch = 0,
}

MainModule.set_free_cam_speed = function(arg)
	MainModule.FreeCam.Speed = tonumber(arg) or 10
end

MainModule.toggle_free_cam = function(arg)
	if arg then
		if MainModule.FreeCam.Enabled then
			return
		end
		MainModule.FreeCam.Enabled = true
		local currentCamera = workspace.CurrentCamera
		local character = localPlayer2.Character
		local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
		MainModule.FreeCam.OriginalCameraType = currentCamera.CameraType
		MainModule.FreeCam.OriginalCameraSubject = currentCamera.CameraSubject
		MainModule.FreeCam.OriginalCFrame = currentCamera.CFrame
		MainModule.FreeCam.Camera = currentCamera

		if humanoidRootPart then
			MainModule.FreeCam.OriginalPosition = humanoidRootPart.CFrame
		end

		currentCamera.CameraType = Enum.CameraType.Scriptable
		currentCamera.CFrame = MainModule.FreeCam.OriginalCFrame
		local lookVector = currentCamera.CFrame.LookVector
		MainModule.FreeCam.Yaw = math.atan2(-lookVector.X, -lookVector.Z)
		MainModule.FreeCam.Pitch = math.asin(math.clamp(lookVector.Y, -1, 1))

		pcall(function()
			UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
		end)

		pcall(function()
			UserInputService.MouseIconEnabled = false
		end)

		if character then
			local humanoid = character:FindFirstChildOfClass("Humanoid")

			if humanoid then
				humanoid.AutoRotate = false
				humanoid.PlatformStand = true
			end

			if humanoidRootPart then
				humanoidRootPart.Anchored = true
			end
		end

		local function fn59()
			if not MainModule.FreeCam.Enabled then
				return
			end
			local camera = MainModule.FreeCam.Camera
			if not camera then
				return
			end
			local mouseDelta = UserInputService:GetMouseDelta()
			local sensitivity = MainModule.FreeCam.Sensitivity or 0.25
			MainModule.FreeCam.Yaw = MainModule.FreeCam.Yaw - mouseDelta.X * sensitivity * 0.012
			MainModule.FreeCam.Pitch = math.clamp(MainModule.FreeCam.Pitch - mouseDelta.Y * sensitivity * 0.012, -1.45, 1.45)
			local cframe = CFrame.fromEulerAnglesYXZ(MainModule.FreeCam.Pitch, MainModule.FreeCam.Yaw, 0)
			local position = camera.CFrame.Position
			local vector = Vector3.zero

			if MainModule.FreeCam.Keys.W then
				vector = Vector3.zero + cframe.LookVector
			end

			if MainModule.FreeCam.Keys.S then
				vector -= cframe.LookVector
			end

			if MainModule.FreeCam.Keys.D then
				vector += cframe.RightVector
			end

			if MainModule.FreeCam.Keys.A then
				vector -= cframe.RightVector
			end

			if MainModule.FreeCam.Keys.Q then
				vector -= Vector3.new(0, 1, 0)
			end

			if MainModule.FreeCam.Keys.E then
				vector += Vector3.new(0, 1, 0)
			end

			if vector.Magnitude > 0 then
				position += vector.Unit * (MainModule.FreeCam.Speed or 10)
			end

			camera.CFrame = CFrame.new(position) * cframe
		end

		local connection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
			if gameProcessed then
				return
			end
			local keyCode = input.KeyCode

			if keyCode == Enum.KeyCode.W then
				MainModule.FreeCam.Keys.W = true
			elseif keyCode == Enum.KeyCode.S then
				MainModule.FreeCam.Keys.S = true
			elseif keyCode == Enum.KeyCode.A then
				MainModule.FreeCam.Keys.A = true
			elseif keyCode == Enum.KeyCode.D then
				MainModule.FreeCam.Keys.D = true
			elseif keyCode == Enum.KeyCode.Q then
				MainModule.FreeCam.Keys.Q = true
			elseif keyCode == Enum.KeyCode.E then
				MainModule.FreeCam.Keys.E = true
			elseif keyCode == Enum.KeyCode.LeftShift then
				MainModule.FreeCam.Speed = (MainModule.FreeCam.Speed or 10) * 2
			elseif keyCode == Enum.KeyCode.LeftControl then
				MainModule.FreeCam.Speed = math.max(1, (MainModule.FreeCam.Speed or 10) * 0.4)
			end
		end)

		local connection2 = UserInputService.InputEnded:Connect(function(input)
			local keyCode = input.KeyCode

			if keyCode == Enum.KeyCode.W then
				MainModule.FreeCam.Keys.W = false
			elseif keyCode == Enum.KeyCode.S then
				MainModule.FreeCam.Keys.S = false
			elseif keyCode == Enum.KeyCode.A then
				MainModule.FreeCam.Keys.A = false
			elseif keyCode == Enum.KeyCode.D then
				MainModule.FreeCam.Keys.D = false
			elseif keyCode == Enum.KeyCode.Q then
				MainModule.FreeCam.Keys.Q = false
			elseif keyCode == Enum.KeyCode.E then
				MainModule.FreeCam.Keys.E = false
			elseif keyCode == Enum.KeyCode.LeftShift or keyCode == Enum.KeyCode.LeftControl then
				MainModule.FreeCam.Speed = MainModule.FreeCam._BaseSpeed or MainModule.FreeCam.Speed or 10
			end
		end)

		MainModule.FreeCam._BaseSpeed = MainModule.FreeCam.Speed
		MainModule.FreeCam.Connection = RunService2.RenderStepped:Connect(fn59)
		MainModule.FreeCam.InputBegan = connection
		MainModule.FreeCam.InputEnded = connection2
		fn("FreeCam", "Mouse look + WASD/QE | Shift fast / Ctrl slow", 0.9)
	else
		if not MainModule.FreeCam.Enabled then
			return
		end
		MainModule.FreeCam.Enabled = false

		if MainModule.FreeCam.Connection then
			MainModule.FreeCam.Connection:Disconnect()
			MainModule.FreeCam.Connection = nil
		end

		if MainModule.FreeCam.InputBegan then
			MainModule.FreeCam.InputBegan:Disconnect()
			MainModule.FreeCam.InputBegan = nil
		end

		if MainModule.FreeCam.InputEnded then
			MainModule.FreeCam.InputEnded:Disconnect()
			MainModule.FreeCam.InputEnded = nil
		end

		pcall(function()
			UserInputService.MouseBehavior = Enum.MouseBehavior.Default
		end)

		pcall(function()
			UserInputService.MouseIconEnabled = true
		end)

		local camera = MainModule.FreeCam.Camera

		if camera then
			camera.CameraType = MainModule.FreeCam.OriginalCameraType or Enum.CameraType.Custom

			if MainModule.FreeCam.OriginalCameraSubject then
				camera.CameraSubject = MainModule.FreeCam.OriginalCameraSubject
			end
		end

		local character = localPlayer2.Character

		if character then
			local humanoid = character:FindFirstChildOfClass("Humanoid")

			if humanoid then
				humanoid.AutoRotate = true
				humanoid.PlatformStand = false
			end

			local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

			if humanoidRootPart then
				humanoidRootPart.Anchored = false

				if MainModule.FreeCam.OriginalPosition then
					humanoidRootPart.CFrame = MainModule.FreeCam.OriginalPosition
				end
			end
		end
	end

	fn22()
end

MainModule.QuicksilverEnabled = false
MainModule.QuicksilverFolder = nil

MainModule.toggle_quicksilver = function(arg)
	local quicksilverEnabled = arg and true or false
	MainModule.QuicksilverEnabled = quicksilverEnabled

	if quicksilverEnabled then
		pcall(function()
			local live = Workspace:FindFirstChild("Live") or Workspace:WaitForChild("Live", 5)
			if not live then
				return
			end
			local v5 = live:FindFirstChild(localPlayer2.Name) or live:WaitForChild(localPlayer2.Name, 5)
			if not v5 then
				return
			end
			local isWallyWest = v5:FindFirstChild("IsWallyWest")

			if isWallyWest then
				isWallyWest:Destroy()
			end

			local folder = Instance.new("Folder")
			folder.Name = "IsWallyWest"
			folder.Parent = v5
			MainModule.QuicksilverFolder = folder
		end)

		fn("Quicksilver", "Enabled", 0.8)
	else
		pcall(function()
			if MainModule.QuicksilverFolder and MainModule.QuicksilverFolder.Parent then
				MainModule.QuicksilverFolder:Destroy()
			end

			MainModule.QuicksilverFolder = nil
			local live = Workspace:FindFirstChild("Live")
			live = live and live:FindFirstChild(localPlayer2.Name)

			if live then
				local isWallyWest = live:FindFirstChild("IsWallyWest")

				if isWallyWest then
					isWallyWest:Destroy()
				end
			end
		end)

		fn("Quicksilver", "Disabled", 0.8)
	end

	fn22()
	return true
end

MainModule.RemoveAnniversaryEnabled = false
MainModule.RemoveAnniversaryTask = nil

MainModule.AnniversaryFolders = {
	"GameplayLobbyForAnniversary",
	"RedLightGreenLightAnniversary",
	"JumpropeAnniversary",
	"Anniversary",
	"LobbyAnniversary",
	"MapAnniversary",
	"HideAndSeekAnniversary",
	"DalgonaAnniversary",
	"SkySquidGameAnniversary",
	"SquidGameAnniversary",
	"GlassBridgeAnniversary",
	"TugOfWarAnniversary",
	"LightsOutEffectBind",
}

local function fn59()
	for _, anniversaryFolder in ipairs(MainModule.AnniversaryFolders) do
		local v5 = workspace:FindFirstChild(anniversaryFolder)

		if v5 then
			pcall(function()
				v5:Destroy()
			end)
		end
	end

	local effects = workspace:FindFirstChild("Effects")

	if effects then
		local bloodSplatter = effects:FindFirstChild("BloodSplatter")

		if bloodSplatter then
			pcall(function()
				bloodSplatter:Destroy()
			end)
		end
	end
end

MainModule.toggle_remove_anniversary = function(arg)
	local removeAnniversaryEnabled = arg and true or false
	MainModule.RemoveAnniversaryEnabled = removeAnniversaryEnabled

	if MainModule.RemoveAnniversaryTask then
		task.cancel(MainModule.RemoveAnniversaryTask)
		MainModule.RemoveAnniversaryTask = nil
	end

	if removeAnniversaryEnabled then
		fn59()

		MainModule.RemoveAnniversaryTask = task.spawn(function()
			while MainModule.RemoveAnniversaryEnabled do
				task.wait(10)
				if MainModule.RemoveAnniversaryEnabled then
					fn59()
					continue
				end
				break
			end

			MainModule.RemoveAnniversaryTask = nil
		end)

		fn("Anniversary", "Decor removal ON", 0.8)
	else
		fn("Anniversary", "Decor removal OFF", 0.8)
	end

	fn22()
	return true
end

MainModule.FakeExploiterEnabled = false

MainModule.FakeExploiter = {
	isActive = false,
	currentTarget = nil,
	fakeChar = nil,
	hideConn = nil,
	seqTask = nil,
	originalNametag = nil,
	nametagParent = nil,
	watchdog = nil,
}

local tbl11 = {
	Startup = "rbxassetid://135801672920476",
	Sprint = "rbxassetid://82609803681213",
	Jump = "rbxassetid://130659228300247",
	Fall = "rbxassetid://112693580156198",
}

MainModule.FakeExploiter_getNearest = function()
	local character = localPlayer2.Character
	character = character and character:FindFirstChild("HumanoidRootPart")
	if not character then
		return nil
	end
	local huge = math.huge
	local v5 = nil

	for _, player in ipairs(Players2:GetPlayers()) do
		if player ~= localPlayer2 and player.Character then
			local humanoidRootPart = player.Character:FindFirstChild("HumanoidRootPart")
			local humanoid = player.Character:FindFirstChild("Humanoid")

			if humanoidRootPart and humanoid and humanoid.Health > 0 then
				local magnitude = (humanoidRootPart.Position - character.Position).Magnitude

				if magnitude < huge then
					huge = magnitude
					v5 = player
				end
			end
		end
	end

	return v5
end

MainModule.FakeExploiter_setHidden = function(arg, arg2)
	if not arg then
		return
	end

	for _, descendant in ipairs(arg:GetDescendants()) do
		if descendant:IsA("BasePart") or descendant:IsA("Decal") or descendant:IsA("Texture") then
			if descendant.Name ~= "Player_Nametag" and not descendant:FindFirstAncestor("Player_Nametag") then
				descendant.LocalTransparencyModifier = arg2 and 1 or 0
			end
		elseif descendant:IsA("Accessory") then
			local handle = descendant:FindFirstChild("Handle")

			if handle then
				handle.LocalTransparencyModifier = arg2 and 1 or 0
			end
		end
	end
end

MainModule.FakeExploiter_findNametag = function(arg)
	if not arg then
		return nil
	end
	local torso = arg:FindFirstChild("Torso") or arg:FindFirstChild("UpperTorso")

	if torso then
		local playerNametag = torso:FindFirstChild("Player_Nametag")
		if playerNametag then
			return playerNametag, torso
		end
	end

	for _, descendant in ipairs(arg:GetDescendants()) do
		if descendant.Name == "Player_Nametag" then
			return descendant, descendant.Parent
		end
	end

	return nil, nil
end

MainModule.FakeExploiter_moveNametag = function(arg, arg2)
	local fakeExploiter = MainModule.FakeExploiter
	local v5, v6 = MainModule.FakeExploiter_findNametag(arg)
	if not v5 or not arg2 then
		return
	end
	fakeExploiter.originalNametag = v5
	fakeExploiter.nametagParent = v6
	local torso = arg2:FindFirstChild("Torso") or arg2:FindFirstChild("UpperTorso")
	if not torso then
		return
	end
	v5.Parent = torso
end

MainModule.FakeExploiter_restoreNametag = function()
	local fakeExploiter = MainModule.FakeExploiter

	if fakeExploiter.originalNametag and fakeExploiter.nametagParent and fakeExploiter.originalNametag.Parent then
		pcall(function()
			fakeExploiter.originalNametag.Parent = fakeExploiter.nametagParent
		end)
	end

	fakeExploiter.originalNametag = nil
	fakeExploiter.nametagParent = nil
end

MainModule.FakeExploiter_turnOff = function()
	local fakeExploiter = MainModule.FakeExploiter
	fakeExploiter.isActive = false

	if fakeExploiter.seqTask then
		task.cancel(fakeExploiter.seqTask)
		fakeExploiter.seqTask = nil
	end

	if fakeExploiter.hideConn then
		fakeExploiter.hideConn:Disconnect()
		fakeExploiter.hideConn = nil
	end

	if fakeExploiter.watchdog then
		fakeExploiter.watchdog:Disconnect()
		fakeExploiter.watchdog = nil
	end

	MainModule.FakeExploiter_restoreNametag()

	if fakeExploiter.currentTarget and fakeExploiter.currentTarget.Character then
		MainModule.FakeExploiter_setHidden(fakeExploiter.currentTarget.Character, false)
	end

	if fakeExploiter.fakeChar and fakeExploiter.fakeChar.Parent then
		fakeExploiter.fakeChar:Destroy()
	end

	fakeExploiter.currentTarget = nil
	fakeExploiter.fakeChar = nil
end

MainModule.FakeExploiter_activate = function()
	local fakeExploiter = MainModule.FakeExploiter
	local character = localPlayer2.Character
	local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
	if not humanoidRootPart then
		MainModule.FakeExploiter_turnOff()
		return
	end

	if not fakeExploiter.currentTarget then
		MainModule.FakeExploiter_turnOff()
		return
	end
	local character2 = fakeExploiter.currentTarget.Character
	if not character2 then
		MainModule.FakeExploiter_turnOff()
		return
	end
	local humanoidRootPart2 = character2:FindFirstChild("HumanoidRootPart")
	if not humanoidRootPart2 then
		MainModule.FakeExploiter_turnOff()
		return
	end
	local archivable = character2.Archivable
	character2.Archivable = true
	fakeExploiter.fakeChar = character2:Clone()
	character2.Archivable = archivable

	for _, descendant in ipairs(fakeExploiter.fakeChar:GetDescendants()) do
		if descendant:IsA("Script") or descendant:IsA("LocalScript") then
			descendant:Destroy()
		elseif descendant.Name == "Player_Nametag" then
			descendant:Destroy()
		end
	end

	local humanoidRootPart3 = fakeExploiter.fakeChar:FindFirstChild("HumanoidRootPart")
	local humanoid = fakeExploiter.fakeChar:FindFirstChild("Humanoid")

	if not humanoidRootPart3 or not humanoid then
		fakeExploiter.fakeChar:Destroy()
		MainModule.FakeExploiter_turnOff()
		return
	end

	humanoidRootPart3.Anchored = true
	humanoidRootPart3.CFrame = humanoidRootPart2.CFrame
	fakeExploiter.fakeChar.Parent = workspace
	MainModule.FakeExploiter_moveNametag(character2, fakeExploiter.fakeChar)
	local animator = humanoid:FindFirstChildOfClass("Animator") or Instance.new("Animator", humanoid)

	local function fn60(animationId)
		local animation = Instance.new("Animation")
		animation.AnimationId = animationId
		return animator:LoadAnimation(animation)
	end

	local v5 = fn60(tbl11.Startup)
	local v6 = fn60(tbl11.Sprint)
	local v7 = fn60(tbl11.Jump)
	local v8 = fn60(tbl11.Fall)
	v5.Priority = Enum.AnimationPriority.Action4
	v6.Priority = Enum.AnimationPriority.Action4
	v7.Priority = Enum.AnimationPriority.Action4
	v8.Priority = Enum.AnimationPriority.Action4

	fakeExploiter.hideConn = RunService2.RenderStepped:Connect(function()
		if fakeExploiter.currentTarget and fakeExploiter.currentTarget.Character then
			MainModule.FakeExploiter_setHidden(fakeExploiter.currentTarget.Character, true)
		end
	end)

	fakeExploiter.seqTask = task.spawn(function()
		v5:Play()
		task.wait(0.4)
		v5:Stop(0.2)
		v6:Play()
		local n = 0

		while n < 2.5 and fakeExploiter.isActive do
			local v9 = task.wait()
			n += v9
			if not humanoidRootPart or not humanoidRootPart.Parent or not humanoidRootPart3 or not humanoidRootPart3.Parent then
				break
			end
			humanoidRootPart3.CFrame = CFrame.lookAt(humanoidRootPart3.Position, humanoidRootPart.Position + Vector3.new(math.sin(n * 10) * 16, 0, math.cos(n * 10) * 16) + Vector3.new(0, 0.1, 0)) * CFrame.new(0, 0, -55 * v9)
			local rotation = humanoidRootPart3.CFrame.Rotation
			humanoidRootPart3.CFrame = CFrame.new(humanoidRootPart3.Position.X, humanoidRootPart.Position.Y, humanoidRootPart3.Position.Z) * rotation
		end

		v6:Stop(0.2)
		v7:Play()
		local n2 = 0

		while true do
			if n2 < 0.45 and fakeExploiter.isActive then
				local v9 = task.wait()
				n2 += v9
				if not (not humanoidRootPart3 or not humanoidRootPart3.Parent) then
					humanoidRootPart3.CFrame = humanoidRootPart3.CFrame * CFrame.new(0, 28 * v9, -12 * v9)
					continue
				end
			end

			break
		end

		v7:Stop(0.2)
		v8:Play()
		local n3 = 0

		while fakeExploiter.isActive do
			local v9 = task.wait()
			n3 += v9 * 6

			if not (not humanoidRootPart or not humanoidRootPart.Parent or not humanoidRootPart3 or not humanoidRootPart3.Parent) then
				local n4 = 18 + math.sin(n3 * 1.5) * 8
				local n5 = 8 + math.cos(n3 * 1.2) * 5
				humanoidRootPart3.CFrame = CFrame.lookAt(humanoidRootPart3.Position, humanoidRootPart.Position + Vector3.new(math.sin(n3 * 1.2) * n4, n5, math.cos(n3 * 1.2) * n4)) * CFrame.new(0, 0, -70 * v9)
				continue
			end

			break
		end
	end)

	fakeExploiter.watchdog = RunService2.Heartbeat:Connect(function()
		if fakeExploiter.isActive and fakeExploiter.currentTarget then
			if not fakeExploiter.currentTarget.Parent or not fakeExploiter.currentTarget.Character or not fakeExploiter.currentTarget.Character:FindFirstChild("HumanoidRootPart") then
				MainModule.FakeExploiter_turnOff()
			end
		end
	end)
end

MainModule.toggle_fake_exploiter = function(arg)
	local fakeExploiterEnabled = arg and true or false
	MainModule.FakeExploiterEnabled = fakeExploiterEnabled

	if fakeExploiterEnabled then
		local v5 = MainModule.FakeExploiter_getNearest()

		if not v5 then
			MainModule.FakeExploiterEnabled = false
			fn("Fake Exploiter", "No target nearby", 0.9)
			PlayErrorSound()
			return false
		end

		MainModule.FakeExploiter.isActive = true
		MainModule.FakeExploiter.currentTarget = v5
		MainModule.FakeExploiter_activate()
		fn("Fake Exploiter", "On: " .. tostring(v5.DisplayName or v5.Name), 1)
	else
		MainModule.FakeExploiter_turnOff()
		fn("Fake Exploiter", "Off", 0.8)
	end

	fn22()
	return true
end

MainModule.CustomLevelEnabled = false
MainModule.CustomLevelValue = 1
MainModule.CustomLevelConnection = nil

MainModule.toggle_custom_level = function(customLevelEnabled)
	MainModule.CustomLevelEnabled = customLevelEnabled

	if MainModule.CustomLevelConnection then
		MainModule.CustomLevelConnection:Disconnect()
		MainModule.CustomLevelConnection = nil
	end

	if customLevelEnabled then
		localPlayer2:SetAttribute("_CurrentLevel", MainModule.CustomLevelValue)

		MainModule.CustomLevelConnection = RunService2.Heartbeat:Connect(function()
			if MainModule.CustomLevelEnabled then
				localPlayer2:SetAttribute("_CurrentLevel", MainModule.CustomLevelValue)
			end
		end)
	end

	fn22()
end

MainModule.set_custom_level = function(arg)
	local num = tonumber(arg)

	if num and num >= 1 and num <= 999999 then
		MainModule.CustomLevelValue = math.floor(num)

		if MainModule.CustomLevelEnabled then
			localPlayer2:SetAttribute("_CurrentLevel", MainModule.CustomLevelValue)
		end
	else
		MainModule.notify("Custom Level", "Invalid number (1-999999)", 0.9)
		PlayErrorSound()
	end
end

MainModule.set_all_level_attributes = function(arg)
	local num = tonumber(arg)

	if num and num >= 1 then
		for _, v5 in ipairs({ "_CurrentLevel", "CurrentLevel", "_Level", "Level" }) do
			pcall(function()
				localPlayer2:SetAttribute(v5, math.floor(num))
			end)
		end

		if MainModule.CustomLevelEnabled then
			MainModule.CustomLevelValue = math.floor(num)
		end

		PlayBell()
	else
		PlayErrorSound()
	end
end

MainModule.CustomWinstreakEnabled = false
MainModule.CustomWinstreakValue = 0
MainModule.CustomWinstreakConnection = nil

MainModule.toggle_custom_winstreak = function(customWinstreakEnabled)
	MainModule.CustomWinstreakEnabled = customWinstreakEnabled

	if MainModule.CustomWinstreakConnection then
		MainModule.CustomWinstreakConnection:Disconnect()
		MainModule.CustomWinstreakConnection = nil
	end

	if customWinstreakEnabled then
		localPlayer2:SetAttribute("_ConsecutiveWins", MainModule.CustomWinstreakValue)

		MainModule.CustomWinstreakConnection = RunService2.Heartbeat:Connect(function()
			if MainModule.CustomWinstreakEnabled then
				localPlayer2:SetAttribute("_ConsecutiveWins", MainModule.CustomWinstreakValue)
			end
		end)
	end

	fn22()
end

MainModule.set_custom_winstreak = function(arg)
	local num = tonumber(arg)

	if num and num >= 0 and num <= 999999 then
		MainModule.CustomWinstreakValue = math.floor(num)

		if MainModule.CustomWinstreakEnabled then
			localPlayer2:SetAttribute("_ConsecutiveWins", MainModule.CustomWinstreakValue)
		end
	else
		MainModule.notify("Custom Winstreak", "Invalid number (0-999999)", 0.9)
		PlayErrorSound()
	end
end

MainModule.set_all_winstreak_attributes = function(arg)
	local num = tonumber(arg)

	if num and num >= 0 then
		for _, v5 in ipairs({
			"_ConsecutiveWins",
			"ConsecutiveWins",
			"_WinStreak",
			"WinStreak",
			"_CurrentStreak",
			"CurrentStreak",
			"_Streak",
			"Streak",
		}) do
			pcall(function()
				localPlayer2:SetAttribute(v5, math.floor(num))
			end)
		end

		if MainModule.CustomWinstreakEnabled then
			MainModule.CustomWinstreakValue = math.floor(num)
		end

		MainModule.notify("Winstreak", "Set to: " .. math.floor(num), 0.9)
	else
		MainModule.notify("Winstreak", "Invalid number!", 0.9)
		PlayErrorSound()
	end
end

local tbl12 = {
	{
		Name = "JumpMaxxing",
		AnimId = "rbxassetid://117992339950574",
		SoundId = "rbxassetid://101111943336616",
		Volume = 5,
	},
	{
		Name = "Catch Catch",
		AnimId = "rbxassetid://110575780667276",
		SoundId = { "rbxassetid://139710162629738", "rbxassetid://109474708805441" },
		Volume = 5,
	},
	{
		Name = "Triple T dance",
		AnimId = "rbxassetid://87099414813526",
		SoundId = "rbxassetid://134846418381928",
		Volume = 5,
	},
	{
		Name = "AVGN",
		AnimId = "rbxassetid://123450801218845",
		SoundId = "rbxassetid://74497095127038",
		Volume = 5,
	},
	{
		Name = "Bubble pop electric",
		AnimId = "rbxassetid://75245548704974",
		SoundId = "rbxassetid://140344891172315",
		Volume = 5,
	},
	{
		Name = "Dream Journal",
		AnimId = "rbxassetid://117325441970867",
		SoundId = "rbxassetid://88476306353688",
		Volume = 10,
	},
	{
		Name = "Otsukare Summer",
		AnimId = "rbxassetid://134888005420629",
		SoundId = "rbxassetid://127332409398776",
		Volume = 3,
	},
	{
		Name = "Spite",
		AnimId = "rbxassetid://100382123964355",
		SoundId = "rbxassetid://90513005423910",
		Volume = 5,
	},
	{
		Name = "Posing Time",
		AnimId = "rbxassetid://89240795237958",
		SoundId = "rbxassetid://113259086406604",
		Volume = 5,
	},
	{
		Name = "Shuffle",
		AnimId = "rbxassetid://113121578988536",
		SoundId = "rbxassetid://127426881747595",
		Volume = 5,
	},
	{
		Name = "Yare Yare",
		AnimId = "rbxassetid://86642655479570",
		SoundId = "rbxassetid://128193072645447",
		Volume = 5,
	},
	{
		Name = "My Perfect Victory",
		AnimId = "rbxassetid://110501561372722",
		SoundId = "rbxassetid://104280886491008",
		Volume = 5,
	},
	{
		Name = "Fate Of Both Worlds",
		AnimId = "rbxassetid://114244682550258",
		SoundId = "rbxassetid://103081000050688",
		Volume = 5,
	},
	{
		Name = "Peanut of Butter House",
		AnimId = "rbxassetid://108074529570331",
		SoundId = "rbxassetid://95893903149232",
		Volume = 5,
	},
	{
		Name = "Cat Hands",
		AnimId = "rbxassetid://87331103640233",
		SoundId = "rbxassetid://126527049854337",
		Volume = 5,
	},
	{
		Name = "The System",
		AnimId = "rbxassetid://117978762262770",
		SoundId = "rbxassetid://73318799732606",
		Volume = 5,
	},
	{ Name = "Gear 5", AnimId = "rbxassetid://107815350238463", SoundId = nil, Volume = 5 },
	{
		Name = "Mingle Dance",
		AnimId = "rbxassetid://99559083669885",
		SoundId = "rbxassetid://89379201770587",
		Volume = 5,
	},
	{
		Name = "Metro Dance",
		AnimId = "rbxassetid://104701586795462",
		SoundId = "rbxassetid://95730226592096",
		Volume = 5,
	},
	{
		Name = "Funeral for the living",
		AnimId = "rbxassetid://123297701965318",
		SoundId = "rbxassetid://105930820096344",
		Volume = 5,
	},
	{
		Name = "Cartwheel",
		AnimId = "rbxassetid://131418698864660",
		SoundId = "rbxassetid://18911882091",
		Volume = 5,
	},
	{
		Name = "Lively Walk",
		AnimId = "rbxassetid://99556634315867",
		SoundId = "rbxassetid://16706317921",
		Volume = 5,
	},
	{
		Name = "Dance of nights",
		AnimId = "rbxassetid://100183800468181",
		SoundId = "rbxassetid://133365635431929",
		Volume = 5,
	},
	{
		Name = "Sonic run",
		AnimId = "rbxassetid://120151271879240",
		SoundId = "rbxassetid://131594734029433",
		Volume = 5,
	},
	{
		Name = "Khabilame",
		AnimId = "rbxassetid://133158883386630",
		SoundId = "rbxassetid://131852145461258",
		Volume = 5,
	},
	{
		Name = "Mii swing",
		AnimId = "rbxassetid://111293910946685",
		SoundId = "rbxassetid://121596432073446",
		Volume = 5,
	},
	{
		Name = "Jackpot",
		AnimId = "rbxassetid://90063856357375",
		SoundId = "rbxassetid://96528255406149",
		Volume = 5,
	},
	{
		Name = "Scuba",
		AnimId = "rbxassetid://125809050313880",
		SoundId = "rbxassetid://78439444151879",
		Volume = 5,
	},
	{
		Name = "Crying",
		AnimId = "rbxassetid://96313533433486",
		SoundId = "rbxassetid://18151791880",
		Volume = 5,
	},
	{
		Name = "Ogame",
		AnimId = "rbxassetid://117778295104747",
		SoundId = "rbxassetid://122457089809687",
		Volume = 5,
	},
	{
		Name = "Blue Shirt Kid",
		AnimId = "rbxassetid://83396620848313",
		SoundId = "rbxassetid://115875415839739",
		Volume = 5,
	},
	{ Name = "Zepelli", AnimId = "rbxassetid://135418027114658", SoundId = nil, Volume = 5 },
	{
		Name = "Woke Up The World",
		AnimId = "rbxassetid://130106286443990",
		SoundId = "rbxassetid://0275579621574",
		Volume = 5,
	},
	{
		Name = "Mask",
		AnimId = "rbxassetid://102176887169297",
		SoundId = "rbxassetid://97952595881264",
		Volume = 5,
	},
}

local v5 = nil
local tbl13 = nil
local flag4 = false
local v6 = nil

local function stopEmote()
	if v5 then
		pcall(function()
			v5:Stop()
		end)

		v5 = nil
	end

	if tbl13 then
		if type(tbl13) == "table" then
			for _, v7 in ipairs(tbl13) do
				pcall(function()
					v7:Stop()
				end)

				pcall(function()
					v7:Destroy()
				end)
			end
		else
			pcall(function()
				tbl13:Stop()
			end)

			pcall(function()
				tbl13:Destroy()
			end)
		end

		tbl13 = nil
	end

	flag4 = false

	if v6 then
		(nil):SetText("Play Emote")
	end
end

local function playEmote(arg)
	stopEmote()
	if not arg or not arg.AnimId then
		return
	end
	local v7 = MainModule.get_humanoid(MainModule.get_character())
	if not v7 then
		return
	end
	local animation = Instance.new("Animation")
	animation.AnimationId = arg.AnimId

	local ok, result = pcall(function()
		return v7:LoadAnimation(animation)
	end)

	if not ok or not result then
		return
	end
	v5 = result

	pcall(function()
		result.Looped = true
	end)

	result:Play()

	if arg.SoundId then
		local soundId = arg.SoundId
		local tbl14

		if type(soundId) ~= "string" then
			tbl14 = soundId
		else
			tbl14 = { soundId }
		end

		if type(tbl14) == "table" then
			tbl13 = {}

			for _, v8 in ipairs(tbl14) do
				if type(v8) == "string" and v8 ~= "" then
					local sound = Instance.new("Sound")
					sound.SoundId = v8
					sound.Volume = arg.Volume or 5
					sound.Looped = true
					sound.Parent = SoundService

					pcall(function()
						sound:Play()
					end)

					table.insert(tbl13, sound)
				end
			end
		end
	end

	flag4 = true
	PlayBell()
end

local tbl14 = {}

for _, v7 in ipairs(tbl12) do
	table.insert(tbl14, v7.Name)
end

local function fn60()
	MainModule.stopEmote = stopEmote
	MainModule.playEmote = playEmote

	if MainModule.is_mobile() then
		for _, v7 in ipairs(tbl12) do
			v7.Volume = 3
		end
	end
end

fn60()

MainModule.cleanup_everything = function()
	MainModule.toggle_auto_win(false)
	MainModule.toggle_rebel(false)
	MainModule.toggle_fly(false, true)
	MainModule.ToggleESP(false)
	MainModule.toggle_speed_hack(false)
	MainModule.toggle_remove_stun(false)
	MainModule.toggle_fov(false)
	MainModule.toggle_fullbright(false)
	MainModule.toggle_ambience(false)
	MainModule.toggle_rapid_fire(false)
	MainModule.toggle_infinite_ammo(false)
	MainModule.toggle_auto_next_game(false)
	MainModule.toggle_auto_safe(false)
	MainModule.toggle_auto_dodge(false)
	MainModule.toggle_auto_escape(false)
	MainModule.toggle_auto_pickup(false)
	MainModule.ToggleFreeGuard(false)
	MainModule.toggle_effect_shooter(false)
	MainModule.toggle_face_target(false)
	MainModule.toggle_player_attach(false)
	MainModule.toggle_god_mode(false)
	MainModule.toggle_remove_injury(false)
	MainModule.toggle_anti_break(false)
	MainModule.toggle_jump_rope_anti_fall(false)
	MainModule.toggle_glass_esp(false)
	MainModule.toggle_spikes_kill(false)
	MainModule.toggle_spikes_platform_teleport(false)
	MainModule.toggle_key_esp(false)
	MainModule.toggle_exit_door_esp(false)
	MainModule.ToggleEspGuards(false)
	MainModule.toggle_sky_squid_anti_fall(false)
	MainModule.toggle_void_kill(false)
	MainModule.toggle_mingle_void_kill(false)

	pcall(function()
		if MainModule.toggle_faster_sprint then
			MainModule.toggle_faster_sprint(false)
		end
	end)

	MainModule.toggle_zone_kill(false)
	MainModule.toggle_auto_choke(false)
	MainModule.ToggleInfiniteStamina(false)
	MainModule.toggle_desync(false)
	MainModule.stopEmote()

	if MainModule.AutoWinConnection then
		MainModule.AutoWinConnection:Disconnect()
		MainModule.AutoWinConnection = nil
	end

	if MainModule.Rebel.Connection then
		MainModule.Rebel.Connection:Disconnect()
		MainModule.Rebel.Connection = nil
	end

	if MainModule.Fly.Connection then
		MainModule.Fly.Connection:Disconnect()
		MainModule.Fly.Connection = nil
	end

	if MainModule.Fly.BodyVelocity then
		MainModule.Fly.BodyVelocity:Destroy()
		MainModule.Fly.BodyVelocity = nil
	end

	if MainModule.SpeedHackLoop then
		task.cancel(MainModule.SpeedHackLoop)
		MainModule.SpeedHackLoop = nil
	end

	if MainModule.FOVConnection then
		MainModule.FOVConnection:Disconnect()
		MainModule.FOVConnection = nil
	end

	if MainModule.FullbrightConnection then
		MainModule.FullbrightConnection:Disconnect()
		MainModule.FullbrightConnection = nil
	end

	if MainModule.ambienceConnection then
		MainModule.ambienceConnection:Disconnect()
		MainModule.ambienceConnection = nil
	end

	if MainModule.timeFixConnection then
		MainModule.timeFixConnection:Disconnect()
		MainModule.timeFixConnection = nil
	end

	if MainModule.motionBlur then
		MainModule.motionBlur:Destroy()
		MainModule.motionBlur = nil
	end

	if MainModule.AutoDodge.HeartbeatConnection then
		MainModule.AutoDodge.HeartbeatConnection:Disconnect()
		MainModule.AutoDodge.HeartbeatConnection = nil
	end

	for _, connection in pairs(MainModule.AutoDodge.Connections) do
		if connection then
			pcall(function()
				connection:Disconnect()
			end)
		end
	end

	MainModule.AutoDodge.Connections = {}

	if MainModule.AutoDodge.Remote and MainModule.AutoDodge.OriginalFireServer then
		pcall(function()
			MainModule.AutoDodge.Remote.FireServer = MainModule.AutoDodge.OriginalFireServer
		end)
	end

	if MainModule.AutoEscapeConnection then
		MainModule.AutoEscapeConnection:Disconnect()
		MainModule.AutoEscapeConnection = nil
	end

	for _, safetyPlatform in pairs(MainModule.SafetyPlatforms) do
		if safetyPlatform then
			pcall(function()
				safetyPlatform:Destroy()
			end)
		end
	end

	MainModule.SafetyPlatforms = {}

	if MainModule.AntiBreakConn then
		MainModule.AntiBreakConn:Disconnect()
		MainModule.AntiBreakConn = nil
	end

	if MainModule.JumpRopeAntiFall.Conn then
		MainModule.JumpRopeAntiFall.Conn:Disconnect()
		MainModule.JumpRopeAntiFall.Conn = nil
	end

	if MainModule.JumpRopeAntiFall.Platform then
		MainModule.JumpRopeAntiFall.Platform:Destroy()
		MainModule.JumpRopeAntiFall.Platform = nil
	end

	pcall(function()
		local glassHolder = Workspace:FindFirstChild("GlassBridge") and Workspace.GlassBridge:FindFirstChild("GlassHolder")

		if glassHolder then
			for _, child in pairs(glassHolder:GetChildren()) do
				for _, child2 in pairs(child:GetChildren()) do
					if child2:IsA("Model") then
						for _, descendant in pairs(child2:GetDescendants()) do
							if descendant:IsA("BasePart") and descendant:GetAttribute("GlassPart") then
								descendant.Color = Color3.fromRGB(163, 162, 165)
								descendant.Material = Enum.Material.Glass
								descendant.Transparency = 0
							end
						end
					end
				end
			end
		end
	end)

	for k, modifiedPart in pairs(MainModule.ModifiedParts) do
		if k and k.Parent then
			pcall(function()
				k.Size = modifiedPart.Size
				k.CanCollide = modifiedPart.CanCollide
				k.Transparency = modifiedPart.Transparency
			end)
		end
	end

	MainModule.ModifiedParts = {}

	for k, originalFireRate in pairs(MainModule.OriginalFireRates) do
		if k and k.Parent then
			pcall(function()
				k.Value = originalFireRate
			end)
		end
	end

	MainModule.OriginalFireRates = {}

	for k, v7 in pairs(MainModule.OriginalAmmo) do
		if k and k.Parent then
			pcall(function()
				k.Value = v7
			end)
		end
	end

	MainModule.OriginalAmmo = {}
	local v7 = MainModule.get_character()

	if v7 then
		local v8 = MainModule.get_humanoid(v7)

		if v8 then
			pcall(function()
				v8.WalkSpeed = 16
			end)
		end
	end

	MainModule.clear_esp()

	if MainModule.EspGuardsThread then
		task.cancel(MainModule.EspGuardsThread)
		MainModule.EspGuardsThread = nil
	end

	for _, espGuardsBoxe in pairs(MainModule.EspGuardsBoxes) do
		if espGuardsBoxe then
			pcall(function()
				espGuardsBoxe:Destroy()
			end)
		end
	end

	MainModule.EspGuardsBoxes = {}

	if MainModule.ExitDoorESPThread then
		task.cancel(MainModule.ExitDoorESPThread)
		MainModule.ExitDoorESPThread = nil
	end

	for _, exitDoorESPObject in pairs(MainModule.ExitDoorESPObjects) do
		if exitDoorESPObject then
			pcall(function()
				exitDoorESPObject:Destroy()
			end)
		end
	end

	MainModule.ExitDoorESPObjects = {}

	for _, keyESPBoxe in pairs(MainModule.KeyESPBoxes) do
		if keyESPBoxe then
			pcall(function()
				keyESPBoxe:Destroy()
			end)
		end
	end

	MainModule.KeyESPBoxes = {}

	if MainModule.KeyESPConnection then
		MainModule.KeyESPConnection:Disconnect()
		MainModule.KeyESPConnection = nil
	end

	if MainModule.SpikesKillFeature.PlatformPart then
		pcall(function()
			MainModule.SpikesKillFeature.PlatformPart:Destroy()
		end)

		MainModule.SpikesKillFeature.PlatformPart = nil
	end

	if MainModule.SpikesKillFeature.AnimationConnection then
		MainModule.SpikesKillFeature.AnimationConnection:Disconnect()
		MainModule.SpikesKillFeature.AnimationConnection = nil
	end

	if MainModule.SpikesKillFeature.CharacterAddedConnection then
		MainModule.SpikesKillFeature.CharacterAddedConnection:Disconnect()
		MainModule.SpikesKillFeature.CharacterAddedConnection = nil
	end

	if MainModule.SpikesKillFeature.SafetyCheckConnection then
		MainModule.SpikesKillFeature.SafetyCheckConnection:Disconnect()
		MainModule.SpikesKillFeature.SafetyCheckConnection = nil
	end

	if MainModule.SpikesKillFeature.AnimationCheckConnection then
		MainModule.SpikesKillFeature.AnimationCheckConnection:Disconnect()
		MainModule.SpikesKillFeature.AnimationCheckConnection = nil
	end

	for _, animationStoppedConnection in pairs(MainModule.SpikesKillFeature.AnimationStoppedConnections) do
		pcall(function()
			animationStoppedConnection:Disconnect()
		end)
	end

	MainModule.SpikesKillFeature.AnimationStoppedConnections = {}

	if MainModule.SpikesPlatformTeleport.Platform then
		pcall(function()
			MainModule.SpikesPlatformTeleport.Platform:Destroy()
		end)

		MainModule.SpikesPlatformTeleport.Platform = nil
	end

	if MainModule.SpikesPlatformTeleport.Connection then
		MainModule.SpikesPlatformTeleport.Connection:Disconnect()
		MainModule.SpikesPlatformTeleport.Connection = nil
	end

	if MainModule.ZoneKillFeature.AnimationConnection then
		MainModule.ZoneKillFeature.AnimationConnection:Disconnect()
		MainModule.ZoneKillFeature.AnimationConnection = nil
	end

	if MainModule.ZoneKillFeature.CharacterAddedConnection then
		MainModule.ZoneKillFeature.CharacterAddedConnection:Disconnect()
		MainModule.ZoneKillFeature.CharacterAddedConnection = nil
	end

	if MainModule.ZoneKillFeature.AnimationCheckConnection then
		MainModule.ZoneKillFeature.AnimationCheckConnection:Disconnect()
		MainModule.ZoneKillFeature.AnimationCheckConnection = nil
	end

	for _, animationStoppedConnection in pairs(MainModule.ZoneKillFeature.AnimationStoppedConnections) do
		pcall(function()
			animationStoppedConnection:Disconnect()
		end)
	end

	MainModule.ZoneKillFeature.AnimationStoppedConnections = {}

	if MainModule.VoidKillConn then
		MainModule.VoidKillConn:Disconnect()
		MainModule.VoidKillConn = nil
	end

	if MainModule.VoidKillCharConn then
		MainModule.VoidKillCharConn:Disconnect()
		MainModule.VoidKillCharConn = nil
	end

	for _, mingleConn in pairs(MainModule.MingleConns) do
		pcall(function()
			mingleConn:Disconnect()
		end)
	end

	MainModule.MingleConns = {}

	if MainModule.SkySquidAntiFall.Platform then
		pcall(function()
			MainModule.SkySquidAntiFall.Platform:Destroy()
		end)

		MainModule.SkySquidAntiFall.Platform = nil
	end

	if MainModule.SkySquidAntiFall.Conn then
		MainModule.SkySquidAntiFall.Conn:Disconnect()
		MainModule.SkySquidAntiFall.Conn = nil
	end

	for k, guardOriginalSize in pairs(MainModule.GuardOriginalSizes) do
		if k and k.Parent then
			pcall(function()
				k.Size = guardOriginalSize
			end)
		end
	end

	MainModule.GuardOriginalSizes = {}

	if MainModule.StaminaConns then
		for _, staminaConn in pairs(MainModule.StaminaConns) do
			pcall(function()
				staminaConn:Disconnect()
			end)
		end

		MainModule.StaminaConns = {}
	end

	if MainModule.GameStateMonitor.Connection then
		MainModule.GameStateMonitor.Connection:Disconnect()
		MainModule.GameStateMonitor.Connection = nil
	end

	if MainModule.noclipButton then
		pcall(function()
			MainModule.noclipButton:Destroy()
		end)

		MainModule.noclipButton = nil
	end

	if MainModule.noclipConnection then
		MainModule.noclipConnection:Disconnect()
		MainModule.noclipConnection = nil
	end

	if MainModule.attachConnection then
		MainModule.attachConnection:Disconnect()
		MainModule.attachConnection = nil
	end

	if MainModule.autoSearchConnection then
		MainModule.autoSearchConnection:Disconnect()
		MainModule.autoSearchConnection = nil
	end

	MainModule.destroySquares()

	if MainModule.CurrentBodyVelocity then
		MainModule.CurrentBodyVelocity:Destroy()
		MainModule.CurrentBodyVelocity = nil
	end

	if MainModule.FaceTargetModule.Connection then
		MainModule.FaceTargetModule.Connection:Disconnect()
		MainModule.FaceTargetModule.Connection = nil
	end

	MainModule.FaceTargetModule.Enabled = false
	MainModule.FullbrightEnabled = false
	MainModule.RemoveStunEnabled = false
	MainModule.AutoWinEnabled = false
	MainModule.AutoDodge.Enabled = false
	MainModule.AutoDodge.ActiveAnimations = {}
	MainModule.AutoDodge.LastAnimationStartTime = {}
	MainModule.AutoDodge.LastDodgeTime = 0
	local Lighting = game:GetService("Lighting")

	if MainModule.FullbrightSettings.Brightness then
		Lighting.Brightness = MainModule.FullbrightSettings.Brightness
		Lighting.ClockTime = MainModule.FullbrightSettings.ClockTime
		Lighting.FogEnd = MainModule.FullbrightSettings.FogEnd
		Lighting.GlobalShadows = MainModule.FullbrightSettings.GlobalShadows
		Lighting.OutdoorAmbient = MainModule.FullbrightSettings.OutdoorAmbient
		Lighting.Ambient = MainModule.FullbrightSettings.Ambient
	end

	pcall(function()
		workspace.CurrentCamera.FieldOfView = 70
	end)

	MainModule.Fly.Enabled = false
	MainModule.Fly.Speed = 45
	MainModule.SpeedHackEnabled = false
	MainModule.SpeedValue = 39
	MainModule.FOVEnabled = false
	MainModule.FOVValue = 120
	MainModule.AmbienceEnabled = false
	MainModule.RapidFireEnabled = false
	MainModule.InfiniteAmmoEnabled = false
	MainModule.AutoNextEnabled = false
	MainModule.AutoSafe.Enabled = false
	MainModule.AutoSafe.HasTeleported = false
	MainModule.AutoSafe.LowHPChecked = false
	MainModule.AutoEscapeEnabled = false
	MainModule.AutoPickupEnabled = false
	MainModule.FreeGuardSettings.Enabled = false
	MainModule.EffectShooter.Enabled = false
	MainModule.PlayerAttachEnabled = false
	MainModule.GodModeEnabled = false
	MainModule.RemoveInjuryEnabled = false
	MainModule.AntiBreakEnabled = false
	MainModule.JumpRopeAntiFall.Enabled = false
	MainModule.GlassESPEnabled = false
	MainModule.SpikesKillFeature.Enabled = false
	MainModule.SpikesPlatformTeleport.Enabled = false
	MainModule.KeyESPEnabled = false
	MainModule.ExitDoorESPEnabled = false
	MainModule.EspGuardsEnabled = false
	MainModule.SkySquidAntiFall.Enabled = false
	MainModule.VoidKillEnabled = false
	MainModule.MingleVoidKillEnabled = false
	MainModule.ZoneKillFeature.Enabled = false
	MainModule.AutoChokeEnabled = false
	MainModule.InfStaminaActive = false
	MainModule.noclipEnabled = false

	for _, v8 in ipairs({
		"toggle_free_cam",
		"toggle_noclip",
		"toggle_phantom_dash",
		"toggle_peabert_kill",
		"toggle_hide_nickname",
		"toggle_hide_all_nicknames",
		"toggle_custom_gravity",
		"toggle_custom_jump_power",
		"toggle_infinite_jump",
		"toggle_quicksilver",
		"toggle_parkour_artist",
		"toggle_visual_items",
		"toggle_free_title",
		"toggle_permanent_guard",
		"toggle_custom_player_tag",
		"toggle_private_server_plus",
		"toggle_lighter",
		"toggle_glass_vision",
		"toggle_player_esp",
		"toggle_esprgb",
		"toggle_auto_skip",
		"toggle_auto_vote",
		"toggle_auto_collect_bandage",
		"toggle_auto_collect_flashbang",
		"toggle_auto_collect_grenade",
		"toggle_rage_auto_qte",
		"toggle_legit_auto_qte",
		"toggle_auto_win",
		"toggle_auto_next_game",
		"toggle_auto_safe",
		"toggle_speed_hack",
		"toggle_fly",
		"toggle_fov",
		"toggle_fullbright",
		"toggle_no_cooldown_proximity",
		"toggle_custom_win",
		"toggle_custom_level",
		"toggle_custom_winstreak",
		"toggle_rebel",
		"toggle_rebel_v2",
	}) do
		local v9 = MainModule[v8]

		if type(v9) == "function" then
			pcall(function()
				v9(false)
			end)
		end
	end

	if MainModule.KeybindConns then
		for _, keybindConn in pairs(MainModule.KeybindConns) do
			pcall(function()
				keybindConn:Disconnect()
			end)
		end

		MainModule.KeybindConns = {}
	end

	pcall(function()
		if MainModule.toggle_free_cam then
			MainModule.toggle_free_cam(false)
		end

		if MainModule.toggle_noclip then
			MainModule.toggle_noclip(false)
		end

		if MainModule.toggle_phantom_dash then
			MainModule.toggle_phantom_dash(false)
		end

		if MainModule.toggle_peabert_kill then
			MainModule.toggle_peabert_kill(false)
		end
	end)

	cursorVisible = false

	pcall(function()
		if _G.HollyScriptX_CursorDrawings then
			for _, hollyScriptXCursorDrawing in ipairs(_G.HollyScriptX_CursorDrawings) do
				pcall(function()
					hollyScriptXCursorDrawing.Visible = false

					if hollyScriptXCursorDrawing.Remove then
						hollyScriptXCursorDrawing:Remove()
					end
				end)
			end
		end

		if _G.HollyScriptX_CursorConnections then
			for _, hollyScriptXCursorConnection in ipairs(_G.HollyScriptX_CursorConnections) do
				pcall(function()
					hollyScriptXCursorConnection:Disconnect()
				end)
			end
		end
	end)

	pcall(function()
		UserInputService.MouseBehavior = Enum.MouseBehavior.Default
	end)

	pcall(function()
		UserInputService.MouseIconEnabled = true
	end)
end

task.defer(function()
	task.wait(0.5)

	pcall(function()
		if MainModule.update_all_toggles_by_game then
			MainModule.update_all_toggles_by_game()
		end
	end)
end)

task.spawn(function()
	task.wait(1)

	pcall(function()
		if sendWebhook then
			sendWebhook()
		end
	end)
end)

fn("HollyScriptX", "Ink Game", 0.9)

-- =========================
-- TY HUB utility additions
-- =========================

local function isLightsOutActive()
    local values = Workspace:FindFirstChild("Values")
    if not values then
        return false
    end
    local currentGame = values:FindFirstChild("CurrentGame")
    if currentGame and currentGame:IsA("ValueBase") then
        return tostring(currentGame.Value):lower():find("lights") ~= nil
    end
    return false
end

local function stopUtilityConnections()
    if TYState.antiAFKConnection then
        pcall(function() TYState.antiAFKConnection:Disconnect() end)
        TYState.antiAFKConnection = nil
    end
    if TYState.instantInteractConnection then
        pcall(function() TYState.instantInteractConnection:Disconnect() end)
        TYState.instantInteractConnection = nil
    end
    TYState.antiAFK = false
    TYState.instantInteract = false
    TYState.lightsOutRoof = false
    TYState.lightsOutRoofThread = false
end

local function setAntiAFK(enabled)
    TYState.antiAFK = enabled and true or false
    if TYState.antiAFKConnection then
        pcall(function() TYState.antiAFKConnection:Disconnect() end)
        TYState.antiAFKConnection = nil
    end
    if TYState.antiAFK then
        TYState.antiAFKConnection = localPlayer.Idled:Connect(function()
            local virtualUser = game:GetService("VirtualUser")
            pcall(function()
                virtualUser:CaptureController()
                virtualUser:ClickButton2(Vector2.new())
            end)
        end)
    end
end

local function setInstantInteract(enabled)
    TYState.instantInteract = enabled and true or false
    if TYState.instantInteractConnection then
        pcall(function() TYState.instantInteractConnection:Disconnect() end)
        TYState.instantInteractConnection = nil
    end
    if not TYState.instantInteract then
        return
    end

    if not fireproximityprompt then
        notifyCompat("TY HUB", "Instant Interact requires fireproximityprompt", 2)
        TYState.instantInteract = false
        return
    end

    TYState.instantInteractConnection = ProximityPromptService.PromptButtonHoldBegan:Connect(function(prompt, player)
        if TYState.instantInteract and player == localPlayer and prompt then
            pcall(fireproximityprompt, prompt)
        end
    end)
end

local function teleportLightsOutRoof()
    local character = MainModule.get_character and MainModule.get_character() or localPlayer.Character
    local root = MainModule.get_root_part and MainModule.get_root_part(character) or (character and character:FindFirstChild("HumanoidRootPart"))
    if not root then
        notifyCompat("TY HUB", "找不到角色根部件", 1)
        return false
    end
    if not isLightsOutActive() then
        notifyCompat("TY HUB", "Lights Out 当前未运行", 1)
        return false
    end
    root.CFrame = CFrame.new(198, 145, -93)
    notifyCompat("TY HUB", "已移动到 Lights Out 屋顶", 1)
    return true
end

local function setLightsOutAutoRoof(enabled)
    TYState.lightsOutRoof = enabled and true or false
    if TYState.lightsOutRoofThread then
        TYState.lightsOutRoofThread = false
    end
    if not TYState.lightsOutRoof then
        return
    end
    TYState.lightsOutRoofThread = true
    task.spawn(function()
        while TYState.lightsOutRoofThread and TYState.lightsOutRoof do
            if isLightsOutActive() then
                local character = localPlayer.Character
                local humanoid = character and character:FindFirstChildOfClass("Humanoid")
                local root = character and character:FindFirstChild("HumanoidRootPart")
                if humanoid and root and humanoid.Health > 0 and humanoid.Health <= 30 then
                    root.CFrame = CFrame.new(198, 145, -93)
                end
            end
            task.wait(0.4)
        end
        TYState.lightsOutRoofThread = false
    end)
end

local function callFeature(name, ...)
    local feature = MainModule[name]
    if type(feature) ~= "function" then
        notifyCompat("TY HUB", "功能不存在: " .. tostring(name), 1.5)
        return false
    end
    local ok, result = pcall(feature, ...)
    if not ok then
        warn("[TY HUB] " .. tostring(name) .. ": " .. tostring(result))
        notifyCompat("TY HUB", "功能执行出错: " .. tostring(name), 1.5)
        return false
    end
    return result ~= false
end

-- =========================
-- NOTHING UI
-- =========================

local Window = NothingLibrary.new({
    Title = "TY HUB",
    Description = "权威不是权威 | QQ 3935754168",
    Keybind = Enum.KeyCode.LeftControl,
    Logo = "rbxassetid://18898582662",
})

local function makeTab(title, description, icon)
    return Window:NewTab({
        Title = title,
        Description = description or "TY HUB",
        Icon = icon or "rbxassetid://7733960981",
    })
end

local function makeSection(tab, title, position, icon)
    return tab:NewSection({
        Title = title,
        Icon = icon or "rbxassetid://7743869054",
        Position = position or "Left",
    })
end

-- Game tab
local gamesTab = makeTab("游戏功能", "Ink Game / 游戏功能", "rbxassetid://7733960981")
local gameLeft = makeSection(gamesTab, "红灯绿灯", "Left")
local gameRight = makeSection(gamesTab, "鱿鱼 / 团队", "Right")

gameLeft:NewButton({Title="传送到终点", Callback=function() callFeature("rlgl_tp_end") end})
gameLeft:NewButton({Title="传送到安全点", Callback=function() callFeature("teleport_to_safe_spot") end})
gameLeft:NewButton({Title="移除受伤物体", Callback=function() callFeature("remove_injury_objects") end})
gameLeft:NewToggle({Title="红灯冻结", Default=false, Callback=function(v) callFeature("toggle_rlgl_stop", v) end})
gameLeft:NewToggle({Title="无穷跳跃", Default=false, Callback=function(v) callFeature("toggle_infinite_jump", v) end})
gameLeft:NewToggle({Title="全局防坠落", Default=false, Callback=function(v) callFeature("toggle_global_anti_fall", v) end})

gameRight:NewToggle({Title="自动 QTE（Legit）", Default=false, Callback=function(v) if v then callFeature("set_auto_qte_mode", "Legit") end callFeature("toggle_auto_qte", v) end})
gameRight:NewToggle({Title="自动投票", Default=false, Callback=function(v) callFeature("toggle_auto_vote", v) end})
gameRight:NewToggle({Title="自动下一局", Default=false, Callback=function(v) callFeature("toggle_auto_next_game", v) end})
gameRight:NewButton({Title="自动完成糖饼", Callback=function() callFeature("complete_dalgona") end})
gameRight:NewToggle({Title="糖饼自动呼吸", Default=false, Callback=function(v) callFeature("toggle_dalgona_auto_relax", v) end})
gameRight:NewToggle({Title="自动翻面", Default=false, Callback=function(v) callFeature("toggle_auto_ddakji", v) end})
gameRight:NewToggle({Title="自动飞石", Default=false, Callback=function(v) callFeature("toggle_auto_flying_stone", v) end})
gameRight:NewToggle({Title="自动贡嘎", Default=false, Callback=function(v) callFeature("toggle_auto_gonggi", v) end})
gameRight:NewToggle({Title="自动陀螺", Default=false, Callback=function(v) callFeature("toggle_auto_spinning_top", v) end})
gameRight:NewToggle({Title="自动踢毽子", Default=false, Callback=function(v) callFeature("toggle_auto_jegi", v) end})
gameRight:NewToggle({Title="自动躲避", Default=false, Callback=function(v) callFeature("toggle_auto_dodge", v) end})

local towSection = makeSection(gamesTab, "拔河 / 跳绳", "Left")
towSection:NewToggle({Title="拔河自动判定", Default=false, Callback=function(v) callFeature("toggle_tug_of_war_auto_qte_miss", v) end})
towSection:NewToggle({Title="自动拉绳", Default=false, Callback=function(v) callFeature("toggle_tug_of_war_auto_pull", v) end})
towSection:NewToggle({Title="快速自动拉绳", Default=false, Callback=function(v) callFeature("toggle_tug_of_war_ultra_fast_pull", v) end})
towSection:NewButton({Title="跳绳传送起点", Callback=function() callFeature("jr_tp_start") end})
towSection:NewButton({Title="跳绳传送终点", Callback=function() callFeature("jr_tp_end") end})
towSection:NewToggle({Title="跳绳防坠落", Default=false, Callback=function(v) callFeature("toggle_jump_rope_anti_fall", v) end})
towSection:NewToggle({Title="跳绳防击中", Default=false, Callback=function(v) callFeature("toggle_jump_rope_anti_hit", v) end})
towSection:NewButton({Title="移除绳子", Callback=function() callFeature("destroy_all_ropes") end})

local glassSection = makeSection(gamesTab, "玻璃桥", "Right")
glassSection:NewToggle({Title="玻璃 ESP", Default=false, Callback=function(v) callFeature("toggle_glass_esp", v) end})
glassSection:NewToggle({Title="防玻璃破裂", Default=false, Callback=function(v) callFeature("toggle_anti_break", v) end})
glassSection:NewToggle({Title="高亮玻璃透明度", Default=false, Callback=function(v) callFeature("toggle_hc_glass_esp", v) end})
glassSection:NewButton({Title="玻璃桥传送终点", Callback=function() callFeature("gb_tp_end") end})

-- Hide & Seek / Mingle / Sky
local seekSection = makeSection(gamesTab, "捉迷藏 / Mingle / Sky", "Left")
seekSection:NewToggle({Title="自动逃脱", Default=false, Callback=function(v) callFeature("toggle_auto_safe", v) end})
seekSection:NewToggle({Title="交互冷却优化", Default=false, Callback=function(v) callFeature("toggle_no_cooldown_proximity", v) end})
seekSection:NewToggle({Title="角色 ESP", Default=false, Callback=function(v) callFeature("toggle_player_esp", v) end})
seekSection:NewToggle({Title="出口门 ESP", Default=false, Callback=function(v) callFeature("toggle_exit_door_esp", v) end})
seekSection:NewToggle({Title="Sky 防坠落", Default=false, Callback=function(v) callFeature("toggle_sky_squid_anti_fall", v) end})
seekSection:NewButton({Title="Mingle 安全点", Callback=function() callFeature("teleport_to_safe_spot") end})

-- Powers / visuals tab
local visualTab = makeTab("视觉与工具", "ESP / 环境 / 实用工具", "rbxassetid://7743869054")
local visualLeft = makeSection(visualTab, "视觉", "Left")
local visualRight = makeSection(visualTab, "实用", "Right")
visualLeft:NewToggle({Title="玩家 ESP", Default=false, Callback=function(v) callFeature("toggle_player_esp", v) end})
visualLeft:NewToggle({Title="ESP RGB", Default=false, Callback=function(v) callFeature("toggle_esprgb", v) end})
visualLeft:NewDropdown({Title="ESP 模式", Data={"Box","Highlight","Name"}, Default="Box", Callback=function(v) callFeature("set_esp_mode", v) end})
visualLeft:NewToggle({Title="气球 ESP", Default=false, Callback=function(v) callFeature("toggle_balloon_esp", v) end})
visualLeft:NewToggle({Title="能力 ESP", Default=false, Callback=function(v) callFeature("toggle_esp_powers", v) end})
visualLeft:NewToggle({Title="Peabert ESP", Default=false, Callback=function(v) callFeature("toggle_peabert_esp", v) end})
visualRight:NewToggle({Title="夜间全亮", Default=false, Callback=function(v) callFeature("toggle_fullbright", v) end})
visualRight:NewToggle({Title="无硬直", Default=false, Callback=function(v) callFeature("toggle_remove_stun", v) end})
visualRight:NewToggle({Title="穿墙", Default=false, Callback=function(v) callFeature("toggle_through_walls", v) end})
visualRight:NewButton({Title="向上移动 100", Callback=function() callFeature("teleport_up") end})
visualRight:NewButton({Title="向下移动", Callback=function() callFeature("teleport_down") end})
visualRight:NewToggle({Title="Instant Interact", Default=false, Callback=function(v) setInstantInteract(v) end})
visualRight:NewToggle({Title="Anti-AFK", Default=false, Callback=function(v) setAntiAFK(v) end})

-- Movement tab
local movementTab = makeTab("移动", "移动 / 镜头", "rbxassetid://7743869054")
local moveLeft = makeSection(movementTab, "移动增强", "Left")
local moveRight = makeSection(movementTab, "镜头", "Right")
moveLeft:NewToggle({Title="速度修改", Default=false, Callback=function(v) callFeature("toggle_speed_hack", v) end})
moveLeft:NewSlider({Title="速度数值", Min=16, Max=80, Default=39, Callback=function(v) callFeature("set_speed_value", v) end})
moveLeft:NewToggle({Title="飞行", Default=false, Callback=function(v) callFeature("toggle_fly", v) end})
moveLeft:NewSlider({Title="飞行速度", Min=10, Max=100, Default=45, Callback=function(v) callFeature("set_fly_speed", v) end})
moveLeft:NewToggle({Title="无碰撞", Default=false, Callback=function(v) callFeature("toggle_noclip", v) end})
moveLeft:NewToggle({Title="幻影冲刺", Default=false, Callback=function(v) callFeature("toggle_phantom_dash", v) end})
moveRight:NewToggle({Title="FOV 修改", Default=false, Callback=function(v) callFeature("toggle_fov", v) end})
moveRight:NewSlider({Title="FOV", Min=50, Max=120, Default=90, Callback=function(v) callFeature("set_fov", v) end})
moveRight:NewSlider({Title="自定义跳跃力", Min=20, Max=150, Default=50, Callback=function(v) callFeature("set_custom_jump_power", v) end})
moveRight:NewToggle({Title="自定义跳跃力启用", Default=false, Callback=function(v) callFeature("toggle_custom_jump_power", v) end})
moveRight:NewToggle({Title="自定义重力启用", Default=false, Callback=function(v) callFeature("toggle_custom_gravity", v) end})
moveRight:NewSlider({Title="重力", Min=20, Max=196, Default=196, Callback=function(v) callFeature("set_custom_gravity", v) end})

-- Players tab
local playersTab = makeTab("玩家", "传送 / 观察", "rbxassetid://7733964719")
local playersSection = makeSection(playersTab, "玩家操作", "Left")
local selectedPlayer = nil
local playerNames = {}
for _, p in ipairs(Players:GetPlayers()) do
    if p ~= localPlayer then table.insert(playerNames, p.Name) end
end
if #playerNames == 0 then playerNames = {"无其他玩家"} end
local playerDropdown = playersSection:NewDropdown({Title="选择玩家", Data=playerNames, Default=playerNames[1], Callback=function(v)
    selectedPlayer = Players:FindFirstChild(tostring(v))
end})
playersSection:NewButton({Title="刷新玩家列表", Callback=function()
    local fresh = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= localPlayer then table.insert(fresh, p.Name) end
    end
    if #fresh == 0 then fresh = {"无其他玩家"} end
    playerDropdown:Set(fresh)
    playerDropdown:Value(fresh[1])
    selectedPlayer = Players:FindFirstChild(tostring(fresh[1]))
end})
playersSection:NewButton({Title="传送到选择玩家", Callback=function()
    if selectedPlayer then callFeature("teleport_to_player", selectedPlayer) end
end})
playersSection:NewButton({Title="观察选择玩家", Callback=function()
    if selectedPlayer then callFeature("spectate_player", selectedPlayer) end
end})
playersSection:NewButton({Title="停止观察", Callback=function() callFeature("stop_spectate") end})
playersSection:NewButton({Title="传送到最近玩家", Callback=function() callFeature("teleportToNearest") end})
playersSection:NewToggle({Title="观察模式", Default=false, Callback=function(v) callFeature("toggle_spectate_mode", v) end})

local playersStats = makeSection(playersTab, "玩家统计", "Right")
playersStats:NewTitle("玩家相关功能集中在左侧")
playersStats:NewTitle("TY HUB 不主动修改账号资料或永久数据")

-- Lights Out tab (UwU additions)
local lightsTab = makeTab("Lights Out", "来自 UwU 的实用补充", "rbxassetid://7733964719")
local lightsLeft = makeSection(lightsTab, "屋顶", "Left")
local lightsRight = makeSection(lightsTab, "环境", "Right")
lightsLeft:NewButton({Title="传送到屋顶", Callback=function() teleportLightsOutRoof() end})
lightsLeft:NewToggle({Title="低血量自动上屋顶", Default=false, Callback=function(v) setLightsOutAutoRoof(v) end})
lightsRight:NewToggle({Title="全亮", Default=false, Callback=function(v) callFeature("toggle_fullbright", v) end})
lightsRight:NewToggle({Title="自动 QTE", Default=false, Callback=function(v) callFeature("toggle_rage_auto_qte", v) end})

-- Info / cleanup
local infoTab = makeTab("关于", "TY HUB 信息", "rbxassetid://7733964719")
local infoLeft = makeSection(infoTab, "TY HUB", "Left")
local infoRight = makeSection(infoTab, "清理", "Right")
infoLeft:NewTitle("TY HUB")
infoLeft:NewTitle("作者：权威不是权威")
infoLeft:NewTitle("QQ：3935754168")
infoLeft:NewTitle("UI：NOTHING UI")
infoLeft:NewTitle("Core：HSX / UwU 功能整合")
infoRight:NewButton({Title="关闭全部功能", Callback=function()
    if MainModule.cleanup_everything then
        pcall(MainModule.cleanup_everything)
    end
    stopUtilityConnections()
    notifyCompat("TY HUB", "已关闭主要功能", 1.5)
end})
infoRight:NewButton({Title="卸载 TY HUB", Callback=function()
    if TYState.destroyed then return end
    TYState.destroyed = true
    if MainModule.cleanup_everything then
        pcall(MainModule.cleanup_everything)
    end
    stopUtilityConnections()
    local pg = localPlayer:FindFirstChild("PlayerGui")
    if pg then
        local gui = pg:FindFirstChild("RobloxGameGui")
        if gui then pcall(function() gui:Destroy() end) end
    end
    local core = game:GetService("CoreGui")
    local gui = core:FindFirstChild("RobloxGameGui")
    if gui then pcall(function() gui:Destroy() end) end
end})

MainModule.guiCreated = true
notifyCompat("TY HUB", "加载完成 | 权威不是权威 | QQ 3935754168", 1.5)

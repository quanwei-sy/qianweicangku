local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")
local ContextActionService = game:GetService("ContextActionService")
local HttpService = game:GetService("HttpService")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer
if not LocalPlayer then
	Players:GetPropertyChangedSignal("LocalPlayer"):Wait()
	LocalPlayer = Players.LocalPlayer
end

local function resolveGuiParent()
	local parent
	pcall(function()
		if type(gethui) == "function" then
			parent = gethui()
		end
	end)
	if parent then
		return parent
	end
	pcall(function()
		parent = game:FindService("CoreGui")
	end)
	if parent then
		return parent
	end
	pcall(function()
		parent = LocalPlayer:WaitForChild("PlayerGui", 5)
	end)
	if parent then
		return parent
	end
	pcall(function()
		parent = LocalPlayer:FindFirstChild("PlayerGui")
	end)
	return parent
end
local UI_PARENT = resolveGuiParent()
local RemoteFolder = ReplicatedStorage:WaitForChild("Remote", 30)
local PlayerEvent = RemoteFolder and RemoteFolder:WaitForChild("PlayerEvent", 30)
local PlayerFunc = RemoteFolder and RemoteFolder:WaitForChild("PlayerFunc", 30)
local function SafeCall(fn, ...)
	local args = {
		...
	}
	local ok, result = pcall(function()
		return fn(unpack(args))
	end)
	if ok then
		return result
	end
end
local CommonColors = {
	["红色"] = Color3.fromRGB(255, 0, 0),
	["黄色"] = Color3.fromRGB(255, 255, 0),
	["绿色"] = Color3.fromRGB(0, 255, 0),
	["蓝色"] = Color3.fromRGB(0, 150, 255),
	["紫色"] = Color3.fromRGB(150, 0, 255),
	["白色"] = Color3.fromRGB(255, 255, 255),
	["黑色"] = Color3.fromRGB(0, 0, 0),
	["青色"] = Color3.fromRGB(0, 255, 255),
	["橙色"] = Color3.fromRGB(255, 165, 0),
	["粉色"] = Color3.fromRGB(255, 105, 180),
}
local function GetRainbowColor(speed)
	speed = speed or 5
	return Color3.fromHSV((tick() % speed) / speed, 1, 1)
end
local function GetColor(name)
	if name == "彩虹色" then
		return GetRainbowColor()
	end
	return CommonColors[name] or Color3.fromRGB(255, 0, 0)
end
local function GetCharacter(player)
	player = player or LocalPlayer
	local character = player.Character
	if not character then
		return
	end
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	local root = character:FindFirstChild("HumanoidRootPart") or character:FindFirstChild("Torso") or character:FindFirstChild("UpperTorso")
	if not humanoid or not root then
		return
	end
	return character, humanoid, root
end
local function IsAlive(player)
	local _, humanoid = GetCharacter(player)
	return humanoid ~= nil and humanoid.Health > 0
end
local function GetPlayerJob(player)
	return player and player.Team and player.Team.Name or "Civilian"
end
local function EquipWeapon()
	local character, humanoid = GetCharacter(LocalPlayer)
	if not character or not humanoid then
		return
	end
	local current = character:FindFirstChildOfClass("Tool")
	if current then
		return current
	end
	local backpack = LocalPlayer:FindFirstChild("Backpack")
	if not backpack then
		return
	end
	for _, item in ipairs(backpack:GetChildren()) do
		if item:IsA("Tool") then
			humanoid:EquipTool(item)
			task.wait(0.1)
			return character:FindFirstChildOfClass("Tool")
		end
	end
end
local NothingLibrary = loadstring(game:HttpGetAsync('https://raw.githubusercontent.com/quanwei-sy/qianweicangku/refs/heads/main/%E6%BA%90%E7%A0%81.lua'))();
if not NothingLibrary then
	return
end
local SETTINGS_FILE = "PYHub_Settings.txt"
local settings = {
	randomBg = true,
	borderColor = nil,
	isBorderRainbow = true,
	borderEnabled = false,
}
local function loadSettings()
	local ok, data = pcall(function()
		return readfile(SETTINGS_FILE)
	end)
	if ok and data then
		local ok2, decoded = pcall(function()
			return HttpService:JSONDecode(data)
		end)
		if ok2 and type(decoded) == "table" then
			for k, v in pairs(decoded) do
				settings[k] = v
			end
		end
	end
end
local function saveSettings()
	pcall(function()
		writefile(SETTINGS_FILE, HttpService:JSONEncode(settings))
	end)
end
loadSettings()
local ScriptActive = true
local State = {
	stamina = false,
	food = false,
	combatBlock = false,
	ghost = false,
	noRagdoll = false,
	noFallDamage = false,
	antiPrisonPull = false,
	autoMoney = false,
	infiniteAmmo = false,
	rapidFire = false,
	farmer = false,
	taxi = false,
	bus = false,
	autoMission = false,
	autoHack = false,
	golf = false,
	autoCuff = false,
}
local CharacterModule
local CoreModule
local InventoryModule
pcall(function()
	local framework = LocalPlayer:WaitForChild("PlayerScripts", 15):WaitForChild("Framework", 15)
	CharacterModule = require(framework:WaitForChild("Character", 15))
	CoreModule = require(framework:WaitForChild("Core", 15))
	local inv = framework.Character:FindFirstChild("Inventory")
	if inv then
		InventoryModule = require(inv)
	end
end)
local function setupMainStateLoops()
	RunService.Heartbeat:Connect(function()
		if CoreModule then
			if State.stamina then
				pcall(function()
					CoreModule.stamina = 100
				end)
			end
			if State.food then
				pcall(function()
					CoreModule.food = 100
				end)
			end
		end
		if State.infiniteAmmo then
			local characterFolder = Workspace:FindFirstChild("Characters") and Workspace.Characters:FindFirstChild(LocalPlayer.Name)
			if characterFolder then
				for _, gun in ipairs(characterFolder:GetChildren()) do
					local config = gun:FindFirstChild("Config")
					if config then
						local ammo = config:FindFirstChild("Ammo")
						local total = config:FindFirstChild("TotalAmmo")
						if ammo then
							ammo.Value = math.huge
						end
						if total then
							total.Value = math.huge
						end
					end
				end
			end
		end
	end)
end
setupMainStateLoops()
local function ModifyWeaponStats()
	if not State.rapidFire or not getgc then
		return
	end
	for _, tbl in pairs(getgc(true)) do
		if type(tbl) == "table" then
			if rawget(tbl, "SHOOT_MODE") ~= nil then
				rawset(tbl, "SHOOT_MODE", 2)
			end
			if rawget(tbl, "RPM") ~= nil then
				rawset(tbl, "RPM", math.huge)
			end
		end
	end
end
local oldCombatNamecall
local function setCombatBlock(enabled)
	State.combatBlock = enabled
	if enabled and not oldCombatNamecall and hookmetamethod and newcclosure then
		oldCombatNamecall = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
			local args = {
				...
			}
			local method = getnamecallmethod()
			if State.combatBlock and method == "FireServer" and args[1] == "combatMode" then
				return nil
			end
			return oldCombatNamecall(self, ...)
		end))
	end
end
local ghostConnections = {}
local ghostRender
local ghostQuickGui
local ghostQuickButton
local ghostQuickRainbow
local ghostQuickLocked = false
local ghostQuickShown = false
local ghostQuickPos = UDim2.new(0, 100, 0.5, - 25)
local function clearGhostConnections()
	for _, conn in ipairs(ghostConnections) do
		pcall(function()
			conn:Disconnect()
		end)
	end
	ghostConnections = {}
end
local function setGhostVisuals(character, enabled)
	if not character then
		return
	end
	pcall(function()
		character:SetAttribute("Invisible", enabled or nil)
		for _, obj in ipairs(character:GetDescendants()) do
			if obj:IsA("BasePart") and obj.Name ~= "HumanoidRootPart" then
				obj.LocalTransparencyModifier = enabled and 0.55 or 0
				obj.Material = enabled and Enum.Material.ForceField or Enum.Material.SmoothPlastic
			elseif obj:IsA("Decal") and obj.Name == "face" then
				obj.Transparency = enabled and 0.55 or 0
			end
		end
	end)
end
local function updateGhostButton()
	if not ghostQuickButton then
		return
	end
	ghostQuickButton.Text = State.ghost and "隐身: 开" or "隐身: 关"
	ghostQuickButton.TextColor3 = State.ghost and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
end
local function setGhostMode(enabled)
	State.ghost = enabled
	local character = LocalPlayer.Character
	if not character then
		return
	end
	if enabled then
		pcall(function()
			local stuff = ReplicatedStorage:FindFirstChild("Stuff")
			local locations = stuff and stuff:FindFirstChild("Locations")
			local target = locations and locations:GetChildren()[1] or nil
			if PlayerFunc then
				PlayerFunc:InvokeServer("hideCharacterLocation", target)
			end
		end)
		if InventoryModule and InventoryModule.canEquipSlot then
			pcall(function()
				InventoryModule.canEquipSlot(true)
			end)
		end
		if CharacterModule and CharacterModule.lockHumanoidState then
			pcall(function()
				CharacterModule.lockHumanoidState("ghostMode", nil)
			end)
		end
		pcall(function()
			GuiService.TouchControlsEnabled = true
			ContextActionService:UnbindAction("LoadingGuiNoResetOnDeath")
			ContextActionService:UnbindAction("DisableCameraMovementNoResetOnDeath")
		end)
		setGhostVisuals(character, true)
		clearGhostConnections()
		if ghostRender then
			ghostRender:Disconnect()
		end
		ghostRender = RunService.RenderStepped:Connect(function()
			if State.ghost and LocalPlayer.Character then
				setGhostVisuals(LocalPlayer.Character, true)
			end
		end)
	else
		if ghostRender then
			ghostRender:Disconnect();
			ghostRender = nil
		end
		clearGhostConnections()
		pcall(function()
			if PlayerFunc then
				PlayerFunc:InvokeServer("hideCharacterLocation", false)
			end
		end)
		setGhostVisuals(character, false)
	end
	updateGhostButton()
end
local function destroyGhostQuick()
	if ghostQuickRainbow then
		ghostQuickRainbow:Disconnect();
		ghostQuickRainbow = nil
	end
	if ghostQuickGui then
		ghostQuickGui:Destroy();
		ghostQuickGui = nil;
		ghostQuickButton = nil
	end
end
local function createGhostQuick()
	destroyGhostQuick()
	if not ghostQuickShown then
		return
	end
	ghostQuickGui = Instance.new("ScreenGui")
	ghostQuickGui.Name = "GhostQuickSwitch"
	ghostQuickGui.ResetOnSpawn = false
	ghostQuickGui.Parent = UI_PARENT or resolveGuiParent()
	ghostQuickButton = Instance.new("TextButton")
	ghostQuickButton.Size = UDim2.new(0, 80, 0, 35)
	ghostQuickButton.Position = ghostQuickPos
	ghostQuickButton.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
	ghostQuickButton.BackgroundTransparency = 0.4
	ghostQuickButton.BorderSizePixel = 0
	ghostQuickButton.Font = Enum.Font.GothamSemibold
	ghostQuickButton.TextSize = 12
	ghostQuickButton.Parent = ghostQuickGui
	ghostQuickButton.Active = not ghostQuickLocked
	ghostQuickButton.Draggable = not ghostQuickLocked
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 8)
	corner.Parent = ghostQuickButton
	local stroke = Instance.new("UIStroke")
	stroke.Name = "RainbowStroke"
	stroke.Thickness = 1.5
	stroke.Parent = ghostQuickButton
	updateGhostButton()
	ghostQuickRainbow = RunService.RenderStepped:Connect(function()
		if stroke.Parent then
			stroke.Color = GetRainbowColor(5)
		end
	end)
	ghostQuickButton.MouseButton1Click:Connect(function()
		setGhostMode(not State.ghost)
	end)
	ghostQuickButton:GetPropertyChangedSignal("Position"):Connect(function()
		if not ghostQuickLocked then
			ghostQuickPos = ghostQuickButton.Position
		end
	end)
end
local originalRagdollActivate
local originalRagdollActivateServer
pcall(function()
	local Ragdoll = require(ReplicatedStorage.Modules.Ragdoll)
	originalRagdollActivate = Ragdoll.activate
	originalRagdollActivateServer = Ragdoll.activateServer
	Ragdoll.activate = function(character, enable, duration, ...)
		if State.noRagdoll and enable then
			return
		end
		return originalRagdollActivate(character, enable, duration, ...)
	end
	if originalRagdollActivateServer then
		Ragdoll.activateServer = function(character, enable, duration, ...)
			if State.noRagdoll and enable then
				return
			end
			return originalRagdollActivateServer(character, enable, duration, ...)
		end
	end
end)
local oldDamageNamecall
pcall(function()
	local mt = getrawmetatable(game)
	oldDamageNamecall = mt.__namecall
	setreadonly(mt, false)
	mt.__namecall = newcclosure(function(self, ...)
		local args = {
			...
		}
		local method = getnamecallmethod()
		if State.noFallDamage and method == "FireServer" and tostring(self) == "PlayerEvent" and args[1] == "takeDamage" then
			return nil
		end
		return oldDamageNamecall(self, ...)
	end)
	setreadonly(mt, true)
end)
local originalCharPivotTo
local originalNotify
local function setAntiPrisonPull(enabled)
	State.antiPrisonPull = enabled
	pcall(function()
		local Algorithms = require(ReplicatedStorage.Modules.Algorithms)
		if enabled and not originalCharPivotTo then
			originalCharPivotTo = Algorithms.charPivotTo
			Algorithms.charPivotTo = function()
				return nil
			end
		elseif not enabled and originalCharPivotTo then
			Algorithms.charPivotTo = originalCharPivotTo
			originalCharPivotTo = nil
		end
	end)
	pcall(function()
		if not CoreModule then
			return
		end
		if enabled and not originalNotify then
			originalNotify = CoreModule.notify
			CoreModule.notify = function(config)
				if config and config.message and string.find(config.message, "You can't leave prison yet") then
					return nil
				end
				return originalNotify(config)
			end
		elseif not enabled and originalNotify then
			CoreModule.notify = originalNotify
			originalNotify = nil
		end
	end)
end
local function getPromptPosition(prompt)
	if not prompt or not prompt.Parent then
		return
	end
	local parent = prompt.Parent
	if parent:IsA("BasePart") then
		return parent.Position
	end
	if parent:IsA("Attachment") then
		return parent.WorldPosition
	end
	if parent:IsA("Model") then
		local part = parent.PrimaryPart or parent:FindFirstChildWhichIsA("BasePart")
		if part then
			return part.Position
		end
	end
end
local function firePrompt(prompt)
	if not prompt then
		return
	end
	pcall(function()
		if fireproximityprompt then
			fireproximityprompt(prompt, 0)
		else
			prompt.HoldDuration = 0
			prompt:InputHoldBegin()
			task.wait(0.1)
			prompt:InputHoldEnd()
		end
	end)
end
local function teleportTo(pos)
	local character, _, root = GetCharacter(LocalPlayer)
	if not character or not root or not pos then
		return
	end
	local cf = CFrame.new(pos + Vector3.new(0, 3, 0))
	character:PivotTo(cf)
	pcall(function()
		if PlayerEvent then
			local id = ((character:GetAttribute("CharPivotToId") or 0) + 1) % 100
			character:SetAttribute("CharPivotToId", id)
			PlayerEvent:FireServer("charPivotTo", cf, character, id)
		end
	end)
end
local function startAutoMoneyLoop()
	task.spawn(function()
		while ScriptActive do
			if State.autoMoney then
				local _, _, root = GetCharacter(LocalPlayer)
				if root then
					local bestPrompt, bestDist
					for _, obj in ipairs(Workspace:GetDescendants()) do
						if obj:IsA("ProximityPrompt") and (obj.Name == "CashDrop" or obj.Name == "GetItem") then
							local pos = getPromptPosition(obj)
							if pos then
								local dist = (root.Position - pos).Magnitude
								if not bestDist or dist < bestDist then
									bestDist = dist
									bestPrompt = obj
								end
							end
						end
					end
					if bestPrompt and bestDist and bestDist < 60 then
						if bestDist > 8 then
							teleportTo(getPromptPosition(bestPrompt))
							task.wait(0.3)
						end
						firePrompt(bestPrompt)
					end
				end
			end
			task.wait(0.3)
		end
	end)
end
startAutoMoneyLoop()
local MoneyConfig = {
	missionInterval = 2,
	priorityHighReward = false,
	taxiSafe = false,
	taxiDelayMode = "随机时间",
	taxiOrigin = nil,
}
local function getTeamJobs()
	if not getgc then
		return
	end
	for _, v in pairs(getgc(true)) do
		if type(v) == "table" and rawget(v, "teamJobs") then
			return v.teamJobs
		end
	end
end
local function hasActiveMission()
	if LocalPlayer:GetAttribute("Mission") then
		return true
	end
	local jobs = getTeamJobs()
	if jobs then
		for _, job in pairs(jobs) do
			if job.joined then
				return true
			end
		end
	end
	return false
end
local function getBestMission()
	local jobs = getTeamJobs()
	if not jobs then
		return
	end
	local bestId, bestScore = nil, - math.huge
	for id, job in pairs(jobs) do
		if not job.joined then
			if not MoneyConfig.priorityHighReward then
				return id
			end
			local score = (job.profitability or 1) * 1000000 + (job.reward or 0)
			if score > bestScore then
				bestScore = score
				bestId = id
			end
		end
	end
	return bestId
end
local function startMissionLoop()
	task.spawn(function()
		while ScriptActive do
			if State.autoMission and PlayerFunc and not hasActiveMission() then
				local id = getBestMission()
				if id then
					pcall(function()
						PlayerFunc:InvokeServer("talkToMission", tostring(id) .. "join")
					end)
				end
			end
			task.wait(MoneyConfig.missionInterval)
		end
	end)
end
startMissionLoop()
local function getFarmerDropOff()
	local gameplay = ReplicatedStorage:FindFirstChild("Gameplay")
	local missions = gameplay and gameplay:FindFirstChild("Missions")
	local active = missions and missions:FindFirstChild("Active")
	if active then
		for _, mission in ipairs(active:GetChildren()) do
			if mission.Name:find("^Farmer") then
				for _, name in ipairs({
					"DropOff",
					"Target",
					"Goal"
				}) do
					local obj = mission:FindFirstChild(name)
					if obj and obj:IsA("BasePart") then
						return obj.Position
					end
					if obj and obj:IsA("ObjectValue") and obj.Value and obj.Value:IsA("BasePart") then
						return obj.Value.Position
					end
				end
			end
		end
	end
end
local function startFarmerLoop()
	task.spawn(function()
		while ScriptActive do
			if State.farmer then
				local drop = getFarmerDropOff()
				if drop then
					teleportTo(drop)
					task.wait(0.4)
				end
				local _, _, root = GetCharacter(LocalPlayer)
				if root then
					local best, bestDist
					for _, obj in ipairs(Workspace:GetDescendants()) do
						if obj:IsA("ProximityPrompt") and obj.ActionText == "Pick Up" then
							local pos = getPromptPosition(obj)
							if pos then
								local dist = (root.Position - pos).Magnitude
								if not bestDist or dist < bestDist then
									bestDist, best = dist, obj
								end
							end
						end
					end
					if best then
						firePrompt(best)
					end
				end
			end
			task.wait(0.3)
		end
	end)
end
startFarmerLoop()
local function startTaxiLoop()
	task.spawn(function()
		local lastTargetPos
		while ScriptActive do
			if State.taxi then
				local clientContent = Workspace:FindFirstChild("Gameplay")
				clientContent = clientContent and clientContent:FindFirstChild("Entities")
				clientContent = clientContent and clientContent:FindFirstChild("ClientContent")
				if clientContent and clientContent:IsA("Model") then
					local targetPart = clientContent.PrimaryPart or clientContent:FindFirstChildWhichIsA("BasePart")
					local _, _, root = GetCharacter(LocalPlayer)
					if targetPart and root then
						local currentPos = targetPart.Position
						local changed = lastTargetPos == nil or (currentPos - lastTargetPos).Magnitude > 5
						if changed then
							lastTargetPos = currentPos
							if MoneyConfig.taxiSafe and MoneyConfig.taxiOrigin then
								root.CFrame = CFrame.new(MoneyConfig.taxiOrigin)
								local distance = (MoneyConfig.taxiOrigin - currentPos).Magnitude
								local waitTime
								if MoneyConfig.taxiDelayMode == "距离测算" then
									local d = math.clamp(distance, 2000, 6000)
									waitTime = math.clamp(15 + (d - 2000) / 4000 * 30 + (math.random() * 2 - 1), 15, 45)
								else
									waitTime = distance > 2000 and math.random(15, 45) or 15
								end
								task.wait(waitTime)
							end
							root.CFrame = CFrame.new(currentPos)
						end
					end
				end
			end
			task.wait(0.5)
		end
	end)
end
startTaxiLoop()
local function getBusArea()
	local gameplay = Workspace:FindFirstChild("Gameplay")
	local entities = gameplay and gameplay:FindFirstChild("Entities")
	local clientContent = entities and entities:FindFirstChild("ClientContent")
	local child = clientContent and clientContent:GetChildren()[1]
	return child and child:FindFirstChild("Area")
end
local function startBusLoop()
	task.spawn(function()
		while ScriptActive do
			if State.bus then
				local area = getBusArea()
				local _, hum, root = GetCharacter(LocalPlayer)
				if area and hum and root then
					local seat = hum.SeatPart
					if seat then
						local newCF = ((area.CFrame * CFrame.new(17.5, 3, 6.5)) * CFrame.Angles(0, math.rad(270), 0)) * root.CFrame:ToObjectSpace(seat.CFrame)
						seat.CFrame = newCF
						seat.AssemblyLinearVelocity = Vector3.zero
						seat.AssemblyAngularVelocity = Vector3.zero
						task.wait(0.1)
						hum.Sit = false
					else
						root.CFrame = (area.CFrame * CFrame.new(17.5, 3, 6.5)) * CFrame.Angles(0, math.rad(270), 0)
					end
					task.wait(5)
				end
			end
			task.wait(1)
		end
	end)
end
startBusLoop()
local autoHackOriginal = {}
local function setAutoHack(enabled)
	State.autoHack = enabled
	pcall(function()
		local framework = LocalPlayer.PlayerScripts:FindFirstChild("Framework")
		local char = framework and require(framework:FindFirstChild("Character"))
		local rules = require(ReplicatedStorage.Modules.GameRules)
		if rules then
			rules.disableHacking = enabled
			rules.disableMinigames = enabled
		end
		if char then
			if not autoHackOriginal.hackingMinigame then
				autoHackOriginal.hackingMinigame = char.hackingMinigame
			end
			if not autoHackOriginal.startMinigame then
				autoHackOriginal.startMinigame = char.startMinigame
			end
			if enabled then
				char.hackingMinigame = function()
					return true
				end
				char.startMinigame = function()
					return true
				end
			else
				if autoHackOriginal.hackingMinigame then
					char.hackingMinigame = autoHackOriginal.hackingMinigame
				end
				if autoHackOriginal.startMinigame then
					char.startMinigame = autoHackOriginal.startMinigame
				end
			end
		end
	end)
end
local function startGolfLoop()
	task.spawn(function()
		local function findPath(parts)
			local obj = Workspace
			for _, name in ipairs(parts) do
				obj = obj and obj:FindFirstChild(name)
				if not obj then
					return
				end
			end
			return obj
		end
		while ScriptActive do
			if State.golf and PlayerFunc then
				pcall(function()
					PlayerFunc:InvokeServer("miniGolf", "createLobby")
					task.wait(0.1)
					PlayerFunc:InvokeServer("miniGolf", "setLobbyBid", {
						bid = 500
					})
					task.wait(0.1)
					PlayerFunc:InvokeServer("miniGolf", "setLobbyReady")
					task.wait(4)
					PlayerFunc:InvokeServer("miniGolf", "shot")
					task.wait(0.5)
					local ball = findPath({
						"Gameplay",
						"Entities",
						"Content",
						LocalPlayer.Name
					})
					local target = findPath({
						"Gameplay",
						"Entities",
						"Content",
						"_Flag",
						"FlagPole",
						"Part"
					})
					if ball and target and ball:IsA("BasePart") then
						ball.Position = target.Position
					end
				end)
			end
			task.wait(State.golf and 5 or 1)
		end
	end)
end
startGolfLoop()
local CombatConfig = {
	auraEnabled = false,
	auraRange = 50,
	auraDamage = 5,
	auraInterval = 0.05,
	auraOnlyPolice = false,
	auraOnlyCivilian = false,
	auraCombatCheck = false,
	bulletEnabled = false,
	bulletFov = 360,
	bulletDistance = 300,
	bulletPart = "Head",
	bulletShowFov = true,
	bulletColor = "红色",
	bulletCombatCheck = false,
	bulletOnlyPolice = false,
	bulletOnlyCivilian = false,
}
local function targetAllowed(player, onlyPolice, onlyCivilian)
	if not player or player == LocalPlayer then
		return false
	end
	if onlyPolice then
		return player.Team and player.Team.Name == "Police"
	end
	if onlyCivilian then
		return player.Team and player.Team.Name == "Civilian"
	end
	return true
end
local function inCombat(player, enabled)
	if not enabled then
		return true
	end
	return player:GetAttribute("CombatMode") == true or player:GetAttribute("Pursuit") == true
end
local auraLast = 0
RunService.Heartbeat:Connect(function()
	if not CombatConfig.auraEnabled or not PlayerEvent then
		return
	end
	local now = tick()
	if now - auraLast < CombatConfig.auraInterval then
		return
	end
	local _, _, myRoot = GetCharacter(LocalPlayer)
	if not myRoot then
		return
	end
	local nearest, nearestDist
	for _, player in ipairs(Players:GetPlayers()) do
		if targetAllowed(player, CombatConfig.auraOnlyPolice, CombatConfig.auraOnlyCivilian) and IsAlive(player) and inCombat(player, CombatConfig.auraCombatCheck) then
			local _, _, root = GetCharacter(player)
			if root then
				local dist = (root.Position - myRoot.Position).Magnitude
				if dist <= CombatConfig.auraRange and (not nearestDist or dist < nearestDist) then
					nearestDist = dist
					nearest = player
				end
			end
		end
	end
	if nearest then
		local _, _, root = GetCharacter(nearest)
		local myPos = myRoot.Position
		pcall(function()
			PlayerEvent:FireServer("damage", {
				bodyParts = {
					{
						"Head",
						1
					}
				},
				shotCode = {
					myPos,
					(root.Position - myPos).Unit
				},
				pos = root.Position,
				target = nearest,
				damageFactor = CombatConfig.auraDamage,
				bulletProofTool = false,
			})
		end)
		auraLast = now
	end
end)
local BulletFOV = Drawing.new("Circle")
BulletFOV.Filled = false
BulletFOV.NumSides = 64
BulletFOV.Visible = false
local function getBulletTarget()
	local camera = Workspace.CurrentCamera
	if not camera then
		return
	end
	local center = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
	local bestPos, bestFov = nil, CombatConfig.bulletFov
	for _, player in ipairs(Players:GetPlayers()) do
		if targetAllowed(player, CombatConfig.bulletOnlyPolice, CombatConfig.bulletOnlyCivilian) and IsAlive(player) and inCombat(player, CombatConfig.bulletCombatCheck) then
			local char = player.Character
			local part = char and (char:FindFirstChild(CombatConfig.bulletPart) or char:FindFirstChild("HumanoidRootPart"))
			if part then
				local dist = (part.Position - camera.CFrame.Position).Magnitude
				if dist <= CombatConfig.bulletDistance then
					local screen, onScreen = camera:WorldToScreenPoint(part.Position)
					if onScreen and screen.Z > 0 then
						local fov = (Vector2.new(screen.X, screen.Y) - center).Magnitude
						if fov < bestFov then
							bestFov = fov
							bestPos = part.Position
						end
					end
				end
			end
		end
	end
	return bestPos
end
pcall(function()
	local oldRaycast = Workspace.Raycast
	hookfunction(Workspace.Raycast, function(self, origin, direction, params)
		if CombatConfig.bulletEnabled and origin and direction then
			local _, _, root = GetCharacter(LocalPlayer)
			if root and (origin - root.Position).Magnitude < 15 then
				local target = getBulletTarget()
				if target then
					direction = (target - origin).Unit * direction.Magnitude
				end
			end
		end
		return oldRaycast(self, origin, direction, params)
	end)
end)
RunService.RenderStepped:Connect(function()
	local camera = Workspace.CurrentCamera
	if not camera then
		return
	end
	BulletFOV.Position = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
	BulletFOV.Radius = CombatConfig.bulletFov
	BulletFOV.Thickness = 2
	BulletFOV.Color = GetColor(CombatConfig.bulletColor)
	BulletFOV.Visible = CombatConfig.bulletEnabled and CombatConfig.bulletShowFov
end)
local AimConfig = {
	enabled = false,
	prediction = false,
	teamCheck = false,
	wallCheck = false,
	showFov = false,
	showCrosshair = false,
	showTracer = false,
	friendCheck = false,
	onlyPolice = false,
	onlyCivilian = false,
	combatCheck = false,
	fov = 50,
	smoothness = 1,
	targetMode = "准心最近",
	targetPart = "头",
	color = "红色",
	fovThickness = 2,
}
local AimFOV = Drawing.new("Circle")
AimFOV.Filled = false
AimFOV.NumSides = 64
local AimTracer = Drawing.new("Line")
local AimCrosshair = {
	Top = Drawing.new("Line"),
	Bottom = Drawing.new("Line"),
	Left = Drawing.new("Line"),
	Right = Drawing.new("Line"),
	Center = Drawing.new("Line")
}
for _, line in pairs(AimCrosshair) do
	line.Thickness = 2;
	line.Visible = false
end
local PartMap = {
	["头"] = {
		"Head"
	},
	["胸"] = {
		"UpperTorso",
		"Torso"
	},
	["左手"] = {
		"LeftHand",
		"Left Arm"
	},
	["右手"] = {
		"RightHand",
		"Right Arm"
	},
	["左腿"] = {
		"LeftFoot",
		"Left Leg"
	},
	["右腿"] = {
		"RightFoot",
		"Right Leg"
	}
}
local function aimTargetPart(char)
	for _, name in ipairs(PartMap[AimConfig.targetPart] or {
		"Head"
	}) do
		local part = char:FindFirstChild(name)
		if part then
			return part
		end
	end
	return char:FindFirstChild("HumanoidRootPart")
end
local function aimVisible(part)
	if not AimConfig.wallCheck then
		return true
	end
	local camera = Workspace.CurrentCamera
	local params = RaycastParams.new()
	params.FilterDescendantsInstances = {
		LocalPlayer.Character,
		camera
	}
	params.FilterType = Enum.RaycastFilterType.Exclude
	params.IgnoreWater = true
	local hit = Workspace:Raycast(camera.CFrame.Position, part.Position - camera.CFrame.Position, params)
	return not hit or hit.Instance:IsDescendantOf(part.Parent)
end
local function getBestAimTarget()
	local camera = Workspace.CurrentCamera
	if not camera then
		return
	end
	local center = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
	local best, bestValue
	for _, player in ipairs(Players:GetPlayers()) do
		if player ~= LocalPlayer and IsAlive(player) and targetAllowed(player, AimConfig.onlyPolice, AimConfig.onlyCivilian) and inCombat(player, AimConfig.combatCheck) then
			if AimConfig.teamCheck and LocalPlayer.Team and player.Team == LocalPlayer.Team then
				continue
			end
			if AimConfig.friendCheck then
				local ok, friend = pcall(function()
					return LocalPlayer:IsFriendsWith(player.UserId)
				end)
				if ok and friend then
					continue
				end
			end
			local char = player.Character
			local part = char and aimTargetPart(char)
			local _, hum, root = GetCharacter(player)
			if part and hum and root and aimVisible(part) then
				local screen, onScreen = camera:WorldToViewportPoint(part.Position)
				if onScreen then
					local fov = (Vector2.new(screen.X, screen.Y) - center).Magnitude
					if fov <= AimConfig.fov then
						local score
						if AimConfig.targetMode == "距离最近" then
							local _, _, myRoot = GetCharacter(LocalPlayer)
							score = myRoot and (myRoot.Position - root.Position).Magnitude or math.huge
						elseif AimConfig.targetMode == "血量最低" then
							score = hum.Health
						else
							score = fov
						end
						if not bestValue or score < bestValue then
							bestValue = score
							best = {
								player = player,
								part = part,
								screen = screen
							}
						end
					end
				end
			end
		end
	end
	return best
end
RunService.RenderStepped:Connect(function(dt)
	local camera = Workspace.CurrentCamera
	if not camera then
		return
	end
	local center = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
	local color = GetColor(AimConfig.color)
	AimFOV.Position = center
	AimFOV.Radius = AimConfig.fov
	AimFOV.Thickness = AimConfig.fovThickness
	AimFOV.Color = color
	AimFOV.Visible = AimConfig.enabled and AimConfig.showFov
	local gap, size = 5, 15
	AimCrosshair.Top.From = Vector2.new(center.X, center.Y - gap)
	AimCrosshair.Top.To = Vector2.new(center.X, center.Y - gap - size)
	AimCrosshair.Bottom.From = Vector2.new(center.X, center.Y + gap)
	AimCrosshair.Bottom.To = Vector2.new(center.X, center.Y + gap + size)
	AimCrosshair.Left.From = Vector2.new(center.X - gap, center.Y)
	AimCrosshair.Left.To = Vector2.new(center.X - gap - size, center.Y)
	AimCrosshair.Right.From = Vector2.new(center.X + gap, center.Y)
	AimCrosshair.Right.To = Vector2.new(center.X + gap + size, center.Y)
	AimCrosshair.Center.From = Vector2.new(center.X - 2, center.Y)
	AimCrosshair.Center.To = Vector2.new(center.X + 2, center.Y)
	for _, line in pairs(AimCrosshair) do
		line.Color = color
		line.Visible = AimConfig.showCrosshair
	end
	AimTracer.Visible = false
	if AimConfig.enabled then
		local target = getBestAimTarget()
		if target then
			if AimConfig.showTracer then
				AimTracer.From = center
				AimTracer.To = Vector2.new(target.screen.X, target.screen.Y)
				AimTracer.Color = color
				AimTracer.Thickness = 2
				AimTracer.Transparency = 0.5
				AimTracer.Visible = true
			end
			local targetPos = target.part.Position
			if AimConfig.prediction then
				targetPos = targetPos + target.part.AssemblyLinearVelocity * dt * 1.5
			end
			local targetCF = CFrame.new(camera.CFrame.Position, targetPos)
			camera.CFrame = AimConfig.smoothness >= 1 and targetCF or camera.CFrame:Lerp(targetCF, AimConfig.smoothness)
		end
	end
end)
local RageConfig = {
	enabled = false,
	range = 150,
	interval = 0.05,
	bodyPart = "Head",
	jobCheck = false,
	wallCheck = false,
	aliveCheck = false,
	combatCheck = false,
	policeLock = false,
	civilianLock = false,
	beam = false,
}
local RageBodyParts = {
	["头部"] = "Head",
	["躯干"] = "Torso",
	["左臂"] = "LeftArm",
	["右臂"] = "RightArm",
	["左腿"] = "LeftLeg",
	["右腿"] = "RightLeg"
}
local function createBeam(startPos, endPos)
	local p1 = Instance.new("Part")
	local p2 = Instance.new("Part")
	for _, p in ipairs({
		p1,
		p2
	}) do
		p.Anchored = true;
		p.CanCollide = false;
		p.Transparency = 1;
		p.Size = Vector3.new(0.1, 0.1, 0.1);
		p.Parent = Workspace
	end
	p1.Position = startPos;
	p2.Position = endPos
	local a1 = Instance.new("Attachment", p1)
	local a2 = Instance.new("Attachment", p2)
	local beam = Instance.new("Beam", p1)
	beam.Attachment0 = a1;
	beam.Attachment1 = a2;
	beam.Width0 = 0.15;
	beam.Width1 = 0.15
	beam.Color = ColorSequence.new(Color3.fromRGB(180, 200, 255))
	task.delay(0.8, function()
		pcall(function()
			p1:Destroy();
			p2:Destroy()
		end)
	end)
end
task.spawn(function()
	while ScriptActive do
		if RageConfig.enabled and PlayerEvent then
			local _, _, myRoot = GetCharacter(LocalPlayer)
			if myRoot then
				EquipWeapon()
				local myPos = myRoot.Position
				local myJob = GetPlayerJob(LocalPlayer)
				for _, player in ipairs(Players:GetPlayers()) do
					if player ~= LocalPlayer and targetAllowed(player, RageConfig.policeLock, RageConfig.civilianLock) and inCombat(player, RageConfig.combatCheck) then
						local char, hum, root = GetCharacter(player)
						if char and hum and root and hum.Health > 0 then
							if RageConfig.jobCheck and GetPlayerJob(player) == myJob then
								continue
							end
							if (root.Position - myPos).Magnitude <= RageConfig.range then
								if RageConfig.wallCheck then
									local params = RaycastParams.new()
									params.FilterDescendantsInstances = {
										LocalPlayer.Character,
										Workspace.CurrentCamera
									}
									params.FilterType = Enum.RaycastFilterType.Exclude
									local hit = Workspace:Raycast(Workspace.CurrentCamera.CFrame.Position, root.Position - Workspace.CurrentCamera.CFrame.Position, params)
									if hit and not hit.Instance:IsDescendantOf(char) then
										continue
									end
								end
								pcall(function()
									PlayerEvent:FireServer("damage", {
										bodyParts = {
											{
												RageConfig.bodyPart,
												1
											}
										},
										shotCode = {
											myPos,
											(root.Position - myPos).Unit
										},
										pos = root.Position,
										target = player,
										damageFactor = 1.5,
										bulletProofTool = false,
									})
									if RageConfig.beam then
										createBeam(myPos, root.Position)
									end
								end)
							end
						end
					end
				end
			end
		end
		task.wait(RageConfig.interval)
	end
end)
local HitboxConfig = {
	active = false,
	size = 10,
	transparency = 0.7,
	teamCheck = false,
	color = "红色",
	material = "Neon",
	rainbow = false,
	checkCorpses = false,
	outline = false,
	collision = false,
	glow = false,
	pulse = false,
	affectNPC = false,
}
local hitboxOriginal = {}
local function resetHitbox(char)
	local root = char and char:FindFirstChild("HumanoidRootPart")
	if not root then
		return
	end
	local orig = hitboxOriginal[root]
	if orig then
		root.Size = orig.Size
		root.Transparency = orig.Transparency
		root.Material = orig.Material
		root.CanCollide = orig.CanCollide
		root.Color = orig.Color
	end
	local h = root:FindFirstChild("PY_HitboxHighlight")
	if h then
		h:Destroy()
	end
	local l = root:FindFirstChild("PY_HitboxLight")
	if l then
		l:Destroy()
	end
end
local function applyHitbox(char)
	local root = char and char:FindFirstChild("HumanoidRootPart")
	if not root then
		return
	end
	if not hitboxOriginal[root] then
		hitboxOriginal[root] = {
			Size = root.Size,
			Transparency = root.Transparency,
			Material = root.Material,
			CanCollide = root.CanCollide,
			Color = root.Color
		}
	end
	if not HitboxConfig.active then
		resetHitbox(char);
		return
	end
	local hum = char:FindFirstChildOfClass("Humanoid")
	if HitboxConfig.checkCorpses and hum and hum.Health <= 0 then
		resetHitbox(char);
		return
	end
	local size = HitboxConfig.size
	if HitboxConfig.pulse then
		size = size * (math.sin(tick() * 2) * 0.2 + 1)
	end
	root.Size = Vector3.new(size, size, size)
	root.Transparency = HitboxConfig.transparency
	root.Material = Enum.Material[HitboxConfig.material] or Enum.Material.Neon
	root.CanCollide = HitboxConfig.collision
	root.Color = HitboxConfig.rainbow and GetRainbowColor(5) or GetColor(HitboxConfig.color)
	if HitboxConfig.outline then
		local hl = root:FindFirstChild("PY_HitboxHighlight") or Instance.new("Highlight")
		hl.Name = "PY_HitboxHighlight"
		hl.FillTransparency = 1
		hl.OutlineColor = root.Color
		hl.OutlineTransparency = HitboxConfig.transparency
		hl.Parent = root
	else
		local hl = root:FindFirstChild("PY_HitboxHighlight")
		if hl then
			hl:Destroy()
		end
	end
	if HitboxConfig.glow then
		local light = root:FindFirstChild("PY_HitboxLight") or Instance.new("PointLight")
		light.Name = "PY_HitboxLight"
		light.Brightness = 5
		light.Range = 15
		light.Color = root.Color
		light.Parent = root
	else
		local light = root:FindFirstChild("PY_HitboxLight")
		if light then
			light:Destroy()
		end
	end
end
RunService.Heartbeat:Connect(function()
	for _, player in ipairs(Players:GetPlayers()) do
		if player ~= LocalPlayer and player.Character then
			if HitboxConfig.teamCheck and LocalPlayer.Team and player.Team == LocalPlayer.Team then
				resetHitbox(player.Character)
			else
				applyHitbox(player.Character)
			end
		end
	end
	if HitboxConfig.affectNPC then
		for _, obj in ipairs(Workspace:GetDescendants()) do
			if obj:IsA("Model") and obj:FindFirstChildOfClass("Humanoid") and not Players:GetPlayerFromCharacter(obj) then
				applyHitbox(obj)
			end
		end
	end
end)
local ESP = {
	enabled = false,
	name = true,
	distance = true,
	health = true,
	highlight = true,
	tracer = false,
	tracerOrigin = "屏幕底部",
	showFugitive = true,
	selectedTeams = {
		Chef = true,
		Civilian = true,
		Delivery = true,
		Farmer = true,
		Fire = true,
		Police = true,
		Medical = true,
		Prisoner = true,
		["Road Service"] = true,
		Transit = true
	},
	trackers = {},
}
local TeamNames = {
	Chef = "厨师",
	Civilian = "平民",
	Delivery = "配送员",
	Farmer = "农民",
	Fire = "消防员",
	Police = "警察",
	Medical = "医护人员",
	Prisoner = "囚犯",
	["Road Service"] = "道路服务",
	Transit = "交通"
}
local TeamColors = {
	Chef = Color3.fromRGB(255, 200, 0),
	Civilian = Color3.fromRGB(100, 200, 255),
	Delivery = Color3.fromRGB(255, 150, 50),
	Farmer = Color3.fromRGB(50, 200, 50),
	Fire = Color3.fromRGB(255, 50, 50),
	Police = Color3.fromRGB(50, 100, 255),
	Medical = Color3.fromRGB(255, 50, 255),
	Prisoner = Color3.fromRGB(255, 150, 150),
	["Road Service"] = Color3.fromRGB(255, 255, 100),
	Transit = Color3.fromRGB(100, 255, 255)
}
local function isFugitive(player)
	return player.Team and player.Team.Name == "Civilian" and (player:GetAttribute("CombatMode") or player:GetAttribute("Pursuit"))
end
local function espAllowed(player)
	if not ESP.enabled or player == LocalPlayer or not player.Character then
		return false
	end
	if ESP.showFugitive and isFugitive(player) then
		return true
	end
	local team = player.Team and player.Team.Name
	return team and ESP.selectedTeams[team] == true
end
local function removeESP(player)
	local t = ESP.trackers[player]
	if not t then
		return
	end
	for _, obj in pairs(t) do
		pcall(function()
			if typeof(obj) == "RBXScriptConnection" then
				obj:Disconnect()
			elseif typeof(obj) == "Instance" then
				obj:Destroy()
			elseif type(obj) == "userdata" and obj.Remove then
				obj:Remove()
			end
		end)
	end
	ESP.trackers[player] = nil
end
local function createESP(player)
	removeESP(player)
	if not espAllowed(player) then
		return
	end
	local char = player.Character
	local root = char and char:FindFirstChild("HumanoidRootPart")
	if not root then
		return
	end
	local uiParent = UI_PARENT or resolveGuiParent()
	if not uiParent then
		return
	end
	local bill = Instance.new("BillboardGui")
	bill.Name = "PlayerESP_" .. player.Name
	bill.AlwaysOnTop = true
	bill.Size = UDim2.new(4, 0, 4, 0)
	bill.StudsOffset = Vector3.new(0, 3, 0)
	bill.Adornee = root
	bill.Parent = uiParent
	local frame = Instance.new("Frame")
	frame.BackgroundTransparency = 1
	frame.Size = UDim2.fromScale(1, 1)
	frame.Parent = bill
	local name = Instance.new("TextLabel")
	name.Size = UDim2.new(1, 0, 0.5, 0)
	name.BackgroundTransparency = 1
	name.Font = Enum.Font.SourceSansBold
	name.TextSize = 14
	name.TextStrokeTransparency = 0.5
	name.Parent = frame
	local info = Instance.new("TextLabel")
	info.Size = UDim2.new(1, 0, 0.5, 0)
	info.Position = UDim2.new(0, 0, 0.5, 0)
	info.BackgroundTransparency = 1
	info.Font = Enum.Font.SourceSans
	info.TextSize = 12
	info.TextStrokeTransparency = 0.5
	info.Parent = frame
	local highlight = Instance.new("Highlight")
	highlight.Name = "PlayerESP_Highlight"
	highlight.Adornee = char
	highlight.FillTransparency = 0.7
	highlight.OutlineTransparency = 0
	highlight.Parent = uiParent
	local tracer = Drawing.new("Line")
	tracer.Thickness = 1
	tracer.Transparency = 0.5
	tracer.Visible = false
	local update = RunService.Heartbeat:Connect(function()
		if not espAllowed(player) or not player.Character or not root.Parent then
			tracer.Visible = false
			if bill.Parent then
				bill.Enabled = false
			end
			return
		end
		bill.Enabled = true
		local fug = ESP.showFugitive and isFugitive(player)
		local team = player.Team and player.Team.Name
		local color = fug and Color3.fromRGB(255, 0, 0) or TeamColors[team] or Color3.fromRGB(0, 255, 0)
		local teamName = fug and "逃犯" or TeamNames[team] or (team or "未知")
		name.Text = "[" .. teamName .. "] " .. player.Name
		name.TextColor3 = color
		name.Visible = ESP.name
		highlight.FillColor = color
		highlight.OutlineColor = color
		highlight.Enabled = ESP.highlight
		local _, hum = GetCharacter(player)
		local _, _, myRoot = GetCharacter(LocalPlayer)
		local parts = {}
		if ESP.distance and myRoot then
			table.insert(parts, string.format("%.1f", (myRoot.Position - root.Position).Magnitude))
		end
		if ESP.health and hum then
			table.insert(parts, tostring(math.floor(hum.Health)))
		end
		info.Text = # parts > 0 and ("[" .. table.concat(parts, "/") .. "]") or ""
		info.TextColor3 = color
		info.Visible = ESP.distance or ESP.health
		local cam = Workspace.CurrentCamera
		if ESP.tracer and cam then
			local screen, onScreen = cam:WorldToViewportPoint(root.Position)
			if onScreen then
				local vp = cam.ViewportSize
				if ESP.tracerOrigin == "屏幕中心" then
					tracer.From = Vector2.new(vp.X / 2, vp.Y / 2)
				elseif ESP.tracerOrigin == "屏幕顶部" then
					tracer.From = Vector2.new(vp.X / 2, 0)
				else
					tracer.From = Vector2.new(vp.X / 2, vp.Y)
				end
				tracer.To = Vector2.new(screen.X, screen.Y)
				tracer.Color = color
				tracer.Visible = true
			else
				tracer.Visible = false
			end
		else
			tracer.Visible = false
		end
	end)
	ESP.trackers[player] = {
		bill = bill,
		highlight = highlight,
		tracer = tracer,
		update = update
	}
end
local function refreshESP()
	for player in pairs(ESP.trackers) do
		if not espAllowed(player) then
			removeESP(player)
		end
	end
	if ESP.enabled then
		for _, player in ipairs(Players:GetPlayers()) do
			if player ~= LocalPlayer and espAllowed(player) and not ESP.trackers[player] then
				createESP(player)
			end
		end
	end
end
Players.PlayerAdded:Connect(function(player)
	player.CharacterAdded:Connect(function()
		task.wait(0.5)
		if ESP.enabled then
			createESP(player)
		end
	end)
end)
Players.PlayerRemoving:Connect(removeESP)
RunService.Heartbeat:Connect(function()
	if ESP.enabled then
		refreshESP()
	end
end)
local PoliceConfig = {
	range = 200,
	delay = 0.5,
	combatCheck = false,
	teleport = false
}
local autoCuffThread
local function startAutoCuff()
	if autoCuffThread then
		return
	end
	autoCuffThread = task.spawn(function()
		while State.autoCuff do
			local _, _, myRoot = GetCharacter(LocalPlayer)
			if myRoot and PlayerFunc then
				for _, player in ipairs(Players:GetPlayers()) do
					if player ~= LocalPlayer and IsAlive(player) and inCombat(player, PoliceConfig.combatCheck) then
						local _, _, root = GetCharacter(player)
						if root and (root.Position - myRoot.Position).Magnitude <= PoliceConfig.range then
							pcall(function()
								PlayerFunc:InvokeServer("handcuff", player, false)
							end)
						end
					end
				end
				if PoliceConfig.teleport then
					local nearest, nearestDist
					for _, player in ipairs(Players:GetPlayers()) do
						if player ~= LocalPlayer and player.Team and player.Team.Name == "Civilian" and (player:GetAttribute("WantedLevel") or 0) > 0 then
							local _, _, root = GetCharacter(player)
							if root then
								local d = (root.Position - myRoot.Position).Magnitude
								if d <= PoliceConfig.range and (not nearestDist or d < nearestDist) then
									nearest, nearestDist = player, d
								end
							end
						end
					end
					if nearest then
						local _, _, targetRoot = GetCharacter(nearest)
						if targetRoot then
							myRoot.CFrame = CFrame.new(targetRoot.Position - targetRoot.CFrame.LookVector * 3)
						end
					end
				end
			end
			task.wait(PoliceConfig.delay)
		end
		autoCuffThread = nil
	end)
end


-- ============================================================
-- 玩家功能
-- ============================================================
local PlayerConfig = {
	walkEnabled = false,
	walkSpeed = 200,
	jumpEnabled = false,
	jumpPower = 50,
	jumpMultiplier = 1,
	infiniteJump = false,
	flyEnabled = false,
	flySpeed = 30,
	flyMode = "传送",
	noclip = false,
}
local PlayerRuntime = {
	walkConn = nil,
	jumpConn = nil,
	flyConn = nil,
	bodyVelocity = nil,
	bodyGyro = nil,
	noclipConn = nil,
	collisionCache = {},
}
local playerQuickGui
local playerQuickButton
local playerQuickShown = false
local playerQuickLocked = false
local playerQuickPos = UDim2.new(0, 100, 0.5, - 25)
local playerQuickRainbow
local playerFlyToggle
local PlayerControls = nil
pcall(function()
	PlayerControls = require(LocalPlayer.PlayerScripts:WaitForChild("PlayerModule")):GetControls()
end)
local function stopWalkLoop()
	if PlayerRuntime.walkConn then
		PlayerRuntime.walkConn:Disconnect()
		PlayerRuntime.walkConn = nil
	end
end
local function startWalkLoop()
	stopWalkLoop()
	if not PlayerConfig.walkEnabled then
		return
	end
	PlayerRuntime.walkConn = RunService.Heartbeat:Connect(function()
		local _, hum = GetCharacter(LocalPlayer)
		if hum and PlayerConfig.walkEnabled then
			hum.WalkSpeed = PlayerConfig.walkSpeed
		end
	end)
end
local function isGrounded(hum)
	if not hum then
		return false
	end
	local state = hum:GetState()
	return state == Enum.HumanoidStateType.Landed or state == Enum.HumanoidStateType.Running or state == Enum.HumanoidStateType.RunningNoPhysics
end
local function stopJumpHandler()
	if PlayerRuntime.jumpConn then
		PlayerRuntime.jumpConn:Disconnect()
		PlayerRuntime.jumpConn = nil
	end
end
local function startJumpHandler()
	stopJumpHandler()
	if not PlayerConfig.jumpEnabled then
		return
	end
	PlayerRuntime.jumpConn = UserInputService.JumpRequest:Connect(function()
		if not PlayerConfig.jumpEnabled then
			return
		end
		local _, hum, root = GetCharacter(LocalPlayer)
		if not hum or not root or hum.Health <= 0 then
			return
		end
		if not PlayerConfig.infiniteJump and not isGrounded(hum) then
			return
		end
		local height = PlayerConfig.jumpPower * PlayerConfig.jumpMultiplier * 0.1
		root.CFrame = root.CFrame + Vector3.new(0, height, 0)
	end)
end
local function clearPhysicalFly()
	if PlayerRuntime.flyConn then
		PlayerRuntime.flyConn:Disconnect()
		PlayerRuntime.flyConn = nil
	end
	if PlayerRuntime.bodyVelocity then
		PlayerRuntime.bodyVelocity:Destroy()
		PlayerRuntime.bodyVelocity = nil
	end
	if PlayerRuntime.bodyGyro then
		PlayerRuntime.bodyGyro:Destroy()
		PlayerRuntime.bodyGyro = nil
	end
	local _, hum = GetCharacter(LocalPlayer)
	if hum then
		hum.PlatformStand = false
		hum.AutoRotate = true
	end
end
local function clearWarpFly()
	if PlayerRuntime.flyConn then
		PlayerRuntime.flyConn:Disconnect()
		PlayerRuntime.flyConn = nil
	end
	local _, hum = GetCharacter(LocalPlayer)
	if hum then
		hum.AutoRotate = true
	end
end
local function updatePlayerQuick()
	if not playerQuickButton then
		return
	end
	playerQuickButton.Text = PlayerConfig.flyEnabled and "飞行: 开" or "飞行: 关"
	playerQuickButton.TextColor3 = PlayerConfig.flyEnabled and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
end
local function stopPlayerFly()
	clearPhysicalFly()
	clearWarpFly()
	PlayerConfig.flyEnabled = false
	updatePlayerQuick()
end
local function startWarpFly()
	clearPhysicalFly()
	clearWarpFly()
	local _, hum, root = GetCharacter(LocalPlayer)
	if not root or not hum then
		return
	end
	PlayerConfig.flyEnabled = true
	hum.AutoRotate = false
	PlayerRuntime.flyConn = RunService.RenderStepped:Connect(function(dt)
		if not PlayerConfig.flyEnabled or PlayerConfig.flyMode ~= "传送" then
			return
		end
		local _, currentHum, currentRoot = GetCharacter(LocalPlayer)
		local cam = Workspace.CurrentCamera
		if not currentRoot or not currentHum or not cam then
			return
		end
		local move = PlayerControls and PlayerControls:GetMoveVector() or Vector3.zero
		local direction = cam.CFrame.LookVector * - move.Z + cam.CFrame.RightVector * move.X
		local vertical = 0
		if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
			vertical = 1
		elseif UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
			vertical = - 1
		end
		local delta = (direction + Vector3.new(0, vertical, 0)) * PlayerConfig.flySpeed * dt
		currentRoot.CFrame = currentRoot.CFrame + delta
		currentRoot.AssemblyLinearVelocity = Vector3.zero
		currentRoot.AssemblyAngularVelocity = Vector3.zero
		currentHum:ChangeState(Enum.HumanoidStateType.Climbing)
	end)
	updatePlayerQuick()
end
local function startPhysicalFly()
	clearWarpFly()
	clearPhysicalFly()
	local _, hum, root = GetCharacter(LocalPlayer)
	if not root or not hum then
		return
	end
	PlayerConfig.flyEnabled = true
	local bv = Instance.new("BodyVelocity")
	bv.Name = "PYPlayerFlyVelocity"
	bv.MaxForce = Vector3.new(9e9, 9e9, 9e9)
	bv.Velocity = Vector3.zero
	bv.Parent = root
	PlayerRuntime.bodyVelocity = bv
	local bg = Instance.new("BodyGyro")
	bg.Name = "PYPlayerFlyGyro"
	bg.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
	bg.P = 9e4
	bg.Parent = root
	PlayerRuntime.bodyGyro = bg
	hum.PlatformStand = true
	hum.AutoRotate = false
	PlayerRuntime.flyConn = RunService.RenderStepped:Connect(function()
		if not PlayerConfig.flyEnabled or PlayerConfig.flyMode ~= "物理" then
			return
		end
		local _, currentHum, currentRoot = GetCharacter(LocalPlayer)
		local cam = Workspace.CurrentCamera
		if not currentRoot or not currentHum or not cam then
			return
		end
		if PlayerRuntime.bodyVelocity and PlayerRuntime.bodyGyro then
			local move = PlayerControls and PlayerControls:GetMoveVector() or Vector3.zero
			local direction = cam.CFrame.LookVector * - move.Z + cam.CFrame.RightVector * move.X
			local vertical = 0
			if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
				vertical = 1
			elseif UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
				vertical = - 1
			end
			PlayerRuntime.bodyVelocity.Velocity = (direction + Vector3.new(0, vertical, 0)) * PlayerConfig.flySpeed
			PlayerRuntime.bodyGyro.CFrame = cam.CFrame
		end
	end)
	updatePlayerQuick()
end
local function startPlayerFly()
	if PlayerConfig.flyMode == "物理" then
		startPhysicalFly()
	else
		startWarpFly()
	end
end
local function destroyPlayerQuick()
	if playerQuickRainbow then
		playerQuickRainbow:Disconnect()
		playerQuickRainbow = nil
	end
	if playerQuickGui then
		playerQuickGui:Destroy()
		playerQuickGui = nil
		playerQuickButton = nil
	end
end
local function createPlayerQuick()
	destroyPlayerQuick()
	if not playerQuickShown then
		return
	end
	playerQuickGui = Instance.new("ScreenGui")
	playerQuickGui.Name = "PlayerFlyQuickSwitch"
	playerQuickGui.ResetOnSpawn = false
	playerQuickGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	playerQuickGui.Parent = UI_PARENT or resolveGuiParent()
	playerQuickButton = Instance.new("TextButton")
	playerQuickButton.Name = "PlayerFlyButton"
	playerQuickButton.Size = UDim2.new(0, 80, 0, 35)
	playerQuickButton.Position = playerQuickPos
	playerQuickButton.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
	playerQuickButton.BackgroundTransparency = 0.4
	playerQuickButton.BorderSizePixel = 0
	playerQuickButton.Font = Enum.Font.GothamSemibold
	playerQuickButton.TextSize = 12
	playerQuickButton.TextWrapped = true
	playerQuickButton.Active = not playerQuickLocked
	playerQuickButton.Draggable = not playerQuickLocked
	playerQuickButton.Selectable = not playerQuickLocked
	playerQuickButton.Parent = playerQuickGui
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 8)
	corner.Parent = playerQuickButton
	local stroke = Instance.new("UIStroke")
	stroke.Name = "RainbowStroke"
	stroke.Thickness = 1.5
	stroke.Parent = playerQuickButton
	playerQuickRainbow = RunService.RenderStepped:Connect(function()
		if stroke.Parent then
			stroke.Color = GetRainbowColor(5)
		end
	end)
	updatePlayerQuick()
	playerQuickButton.MouseButton1Click:Connect(function()
		if PlayerConfig.flyEnabled then
			stopPlayerFly()
		else
			startPlayerFly()
		end
		if playerFlyToggle and type(playerFlyToggle.SetState) == "function" then
			playerFlyToggle:SetState(PlayerConfig.flyEnabled)
		end
	end)
	playerQuickButton:GetPropertyChangedSignal("Position"):Connect(function()
		if not playerQuickLocked then
			playerQuickPos = playerQuickButton.Position
		end
	end)
end
local function restoreNoclip()
	for part, old in pairs(PlayerRuntime.collisionCache) do
		if part and part.Parent then
			pcall(function()
				part.CanCollide = old
			end)
		end
	end
	PlayerRuntime.collisionCache = {}
end
local function stopNoclip()
	if PlayerRuntime.noclipConn then
		PlayerRuntime.noclipConn:Disconnect()
		PlayerRuntime.noclipConn = nil
	end
	restoreNoclip()
end
local function startNoclip()
	stopNoclip()
	if not PlayerConfig.noclip then
		return
	end
	PlayerRuntime.noclipConn = RunService.Stepped:Connect(function()
		if not PlayerConfig.noclip then
			return
		end
		local char = LocalPlayer.Character
		if not char then
			return
		end
		for _, part in ipairs(char:GetDescendants()) do
			if part:IsA("BasePart") then
				if PlayerRuntime.collisionCache[part] == nil then
					PlayerRuntime.collisionCache[part] = part.CanCollide
				end
				part.CanCollide = false
			end
		end
	end)
end
LocalPlayer.CharacterAdded:Connect(function()
	task.wait(0.5)
	PlayerRuntime.collisionCache = {}
	if PlayerConfig.walkEnabled then
		startWalkLoop()
	end
	if PlayerConfig.jumpEnabled then
		startJumpHandler()
	end
	if PlayerConfig.noclip then
		startNoclip()
	end
	if PlayerConfig.flyEnabled then
		local mode = PlayerConfig.flyMode
		PlayerConfig.flyEnabled = false
		task.wait(0.2)
		PlayerConfig.flyMode = mode
		startPlayerFly()
	end
end)
local VehicleFly = {
	active = false,
	speed = 50,
	bv = nil,
	bg = nil,
	conn = nil
}
local vehicleQuickGui
local vehicleQuickButton
local vehicleQuickShown = false
local vehicleQuickLocked = false
local vehicleQuickPos = UDim2.new(0, 10, 0.5, - 25)
local vehicleQuickRainbow
local function updateVehicleQuick()
	if vehicleQuickButton then
		vehicleQuickButton.Text = VehicleFly.active and "飞车: 开" or "飞车: 关"
		vehicleQuickButton.TextColor3 = VehicleFly.active and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
	end
end
local function stopVehicleFly()
	VehicleFly.active = false
	if VehicleFly.conn then
		VehicleFly.conn:Disconnect();
		VehicleFly.conn = nil
	end
	if VehicleFly.bv then
		VehicleFly.bv:Destroy();
		VehicleFly.bv = nil
	end
	if VehicleFly.bg then
		VehicleFly.bg:Destroy();
		VehicleFly.bg = nil
	end
	updateVehicleQuick()
end
local function startVehicleFly()
	local _, _, root = GetCharacter(LocalPlayer)
	if not root then
		return
	end
	stopVehicleFly()
	VehicleFly.active = true
	VehicleFly.bv = Instance.new("BodyVelocity")
	VehicleFly.bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
	VehicleFly.bv.Parent = root
	VehicleFly.bg = Instance.new("BodyGyro")
	VehicleFly.bg.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
	VehicleFly.bg.Parent = root
	VehicleFly.conn = RunService.Heartbeat:Connect(function()
		local cam = Workspace.CurrentCamera
		if VehicleFly.active and cam and VehicleFly.bv and VehicleFly.bg then
			VehicleFly.bg.CFrame = cam.CFrame
			VehicleFly.bv.Velocity = cam.CFrame.LookVector * VehicleFly.speed
		end
	end)
	updateVehicleQuick()
end
local function destroyVehicleQuick()
	if vehicleQuickRainbow then
		vehicleQuickRainbow:Disconnect();
		vehicleQuickRainbow = nil
	end
	if vehicleQuickGui then
		vehicleQuickGui:Destroy();
		vehicleQuickGui = nil;
		vehicleQuickButton = nil
	end
end
local function createVehicleQuick()
	destroyVehicleQuick()
	if not vehicleQuickShown then
		return
	end
	vehicleQuickGui = Instance.new("ScreenGui")
	vehicleQuickGui.Name = "VehicleFlyQuickSwitch"
	vehicleQuickGui.ResetOnSpawn = false
	vehicleQuickGui.Parent = UI_PARENT or resolveGuiParent()
	vehicleQuickButton = Instance.new("TextButton")
	vehicleQuickButton.Size = UDim2.new(0, 80, 0, 35)
	vehicleQuickButton.Position = vehicleQuickPos
	vehicleQuickButton.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
	vehicleQuickButton.BackgroundTransparency = 0.4
	vehicleQuickButton.BorderSizePixel = 0
	vehicleQuickButton.Font = Enum.Font.GothamSemibold
	vehicleQuickButton.TextSize = 12
	vehicleQuickButton.Parent = vehicleQuickGui
	vehicleQuickButton.Active = not vehicleQuickLocked
	vehicleQuickButton.Draggable = not vehicleQuickLocked
	local c = Instance.new("UICorner", vehicleQuickButton);
	c.CornerRadius = UDim.new(0, 8)
	local s = Instance.new("UIStroke", vehicleQuickButton);
	s.Thickness = 1.5
	vehicleQuickRainbow = RunService.RenderStepped:Connect(function()
		if s.Parent then
			s.Color = GetRainbowColor(5)
		end
	end)
	updateVehicleQuick()
	vehicleQuickButton.MouseButton1Click:Connect(function()
		if VehicleFly.active then
			stopVehicleFly()
		else
			startVehicleFly()
		end
	end)
	vehicleQuickButton:GetPropertyChangedSignal("Position"):Connect(function()
		if not vehicleQuickLocked then
			vehicleQuickPos = vehicleQuickButton.Position
		end
	end)
end
local speedLimitEnabled = false
local originalGetSpeedLimit
pcall(function()
	local Algorithms = require(ReplicatedStorage.Modules.Algorithms)
	originalGetSpeedLimit = Algorithms.getSpeedLimitAtPos
	Algorithms.getSpeedLimitAtPos = function(...)
		if speedLimitEnabled then
			return 9999
		end
		return originalGetSpeedLimit(...)
	end
end)

local cleanupToggles = {}
local cleaningFeatures = false
local mainWindowGui
local Windows
local unloading = false
local borderRainbowConnection

local function NewFeatureToggle(section, config)
	local handle = section:NewToggle(config)
	table.insert(cleanupToggles, handle)
	return handle
end


local function applyBorderColor(color, rainbow)
	local mainFrame = mainWindowGui and mainWindowGui:FindFirstChild("MainFrame")
	if not mainFrame then
		return
	end
	local stroke = mainFrame:FindFirstChild("MainBorder")
	if not stroke then
		return
	end
	local gradient = stroke:FindFirstChild("BorderGradient")
	if not gradient then
		return
	end
	stroke.Enabled = settings.borderEnabled
	if borderRainbowConnection then
		borderRainbowConnection:Disconnect()
		borderRainbowConnection = nil
	end
	if rainbow then
		gradient.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromHex("FF0000")),
			ColorSequenceKeypoint.new(0.16, Color3.fromHex("FFA500")),
			ColorSequenceKeypoint.new(0.33, Color3.fromHex("FFFF00")),
			ColorSequenceKeypoint.new(0.5, Color3.fromHex("00FF00")),
			ColorSequenceKeypoint.new(0.66, Color3.fromHex("0000FF")),
			ColorSequenceKeypoint.new(0.83, Color3.fromHex("4B0082")),
			ColorSequenceKeypoint.new(1, Color3.fromHex("EE82EE")),
		})
		borderRainbowConnection = RunService.Heartbeat:Connect(function()
			if gradient.Parent then
				gradient.Rotation = (gradient.Rotation + 1.5) % 360
			end
		end)
		settings.isBorderRainbow = true
		settings.borderColor = nil
	else
		local c = color or Color3.new(1, 1, 1)
		stroke.Color = c
		gradient.Color = ColorSequence.new(c)
		gradient.Rotation = 0
		settings.isBorderRainbow = false
		settings.borderColor = nil
	end
	saveSettings()
end

local function cleanupAllFeatures()
	if cleaningFeatures then
		return
	end
	cleaningFeatures = true

	for key in pairs(State) do
		State[key] = false
	end
	CombatConfig.auraEnabled = false
	CombatConfig.bulletEnabled = false
	AimConfig.enabled = false
	AimConfig.showFov = false
	AimConfig.showCrosshair = false
	AimConfig.showTracer = false
	RageConfig.enabled = false
	HitboxConfig.active = false
	ESP.enabled = false
	PlayerConfig.walkEnabled = false
	PlayerConfig.jumpEnabled = false
	PlayerConfig.flyEnabled = false
	PlayerConfig.noclip = false
	speedLimitEnabled = false
	ghostQuickShown = false
	playerQuickShown = false
	vehicleQuickShown = false

	pcall(setCombatBlock, false)
	pcall(setGhostMode, false)
	pcall(setAntiPrisonPull, false)
	pcall(setAutoHack, false)
	pcall(stopWalkLoop)
	pcall(stopJumpHandler)
	pcall(stopPlayerFly)
	pcall(stopNoclip)
	pcall(stopVehicleFly)
	pcall(destroyGhostQuick)
	pcall(destroyPlayerQuick)
	pcall(destroyVehicleQuick)

	if ghostRender then
		pcall(function()
			ghostRender:Disconnect()
		end)
		ghostRender = nil
	end
	pcall(clearGhostConnections)

	BulletFOV.Visible = false
	AimFOV.Visible = false
	AimTracer.Visible = false
	for _, line in pairs(AimCrosshair) do
		line.Visible = false
	end

	for _, player in ipairs(Players:GetPlayers()) do
		if player.Character then
			pcall(resetHitbox, player.Character)
		end
	end
	for root in pairs(hitboxOriginal) do
		if root and root.Parent then
			pcall(resetHitbox, root.Parent)
		end
	end
	hitboxOriginal = {}

	for player in pairs(ESP.trackers) do
		pcall(removeESP, player)
	end

	for _, toggle in ipairs(cleanupToggles) do
		pcall(function()
			toggle.Value(false)
		end)
	end

	cleaningFeatures = false
end

local function disableDrawingResources()
	local drawings = {BulletFOV, AimFOV, AimTracer}
	for _, line in pairs(AimCrosshair) do
		table.insert(drawings, line)
	end
	for _, drawing in ipairs(drawings) do
		pcall(function()
			drawing.Visible = false
		end)
	end
end


local function cleanupWindowEffects()
	if borderRainbowConnection then
		pcall(function()
			borderRainbowConnection:Disconnect()
		end)
		borderRainbowConnection = nil
	end
end

local function unloadScript()
	if unloading then
		return
	end
	unloading = true
	ScriptActive = false
	cleanupAllFeatures()
	cleanupWindowEffects()
	cleanupToggles = {}
	if Windows then
		Windows.ToggleButton = nil
		if Windows.ElBlurUI then
			pcall(function()
				Windows.ElBlurUI.Destroy()
			end)
		end
	end
	if mainWindowGui then
		pcall(function()
			mainWindowGui:Destroy()
		end)
	end
	disableDrawingResources()
end

local UIParent = UI_PARENT or resolveGuiParent()
local existingGuis = {}
if UIParent then
	for _, child in ipairs(UIParent:GetChildren()) do
		existingGuis[child] = true
	end
end

Windows = NothingLibrary.new({
	Title = "TY hub",
	Description = "TY HUB | 圣奥",
	Keybind = Enum.KeyCode.LeftControl,
	Logo = 'http://www.roblox.com/asset/?id=18898582662'
})

if UIParent then
	for _, child in ipairs(UIParent:GetChildren()) do
		if not existingGuis[child] and child:IsA("ScreenGui") and child:FindFirstChild("MainFrame") then
			mainWindowGui = child
			break
		end
	end
end


if mainWindowGui then
	local mainFrame = mainWindowGui:FindFirstChild("MainFrame")
	if mainFrame then
		local stroke = Instance.new("UIStroke")
		stroke.Name = "MainBorder"
		stroke.Thickness = 3
		stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		stroke.LineJoinMode = Enum.LineJoinMode.Round
		stroke.Enabled = settings.borderEnabled
		stroke.Parent = mainFrame
		local gradient = Instance.new("UIGradient")
		gradient.Name = "BorderGradient"
		gradient.Parent = stroke
		applyBorderColor(nil, settings.isBorderRainbow ~= false)
	end
end

local MainTab = Windows:NewTab({
	Title = "主要功能",
	Description = "主要功能",
	Icon = "rbxassetid://7733960981"
})
local MainLeft = MainTab:NewSection({
	Title = "角色与防护",
	Icon = "rbxassetid://7743869054",
	Position = "Left"
})
local MainRight = MainTab:NewSection({
	Title = "辅助功能",
	Icon = "rbxassetid://7743869054",
	Position = "Right"
})

NewFeatureToggle(MainLeft, {
	Title = "无限体力",
	Default = false,
	Callback = function(v)
		State.stamina = v
	end
})
NewFeatureToggle(MainLeft, {
	Title = "无限饥饿",
	Default = false,
	Callback = function(v)
		State.food = v
	end
})
NewFeatureToggle(MainLeft, {
	Title = "战斗拦截",
	Default = false,
	Callback = setCombatBlock
})
NewFeatureToggle(MainLeft, {
	Title = "隐身",
	Default = false,
	Callback = setGhostMode
})
NewFeatureToggle(MainLeft, {
	Title = "显示隐身悬浮窗",
	Default = false,
	Callback = function(v)
		ghostQuickShown = v
		if v then
			createGhostQuick()
		else
			destroyGhostQuick()
		end
	end
})
MainLeft:NewToggle({
	Title = "锁定隐身悬浮窗位置",
	Default = false,
	Callback = function(v)
		ghostQuickLocked = v
		if ghostQuickButton then
			ghostQuickButton.Active = not v
			ghostQuickButton.Draggable = not v
		end
	end
})
NewFeatureToggle(MainRight, {
	Title = "防布娃娃",
	Default = false,
	Callback = function(v)
		State.noRagdoll = v
	end
})
NewFeatureToggle(MainRight, {
	Title = "防摔伤",
	Default = false,
	Callback = function(v)
		State.noFallDamage = v
	end
})
NewFeatureToggle(MainRight, {
	Title = "防越狱拉回",
	Default = false,
	Callback = setAntiPrisonPull
})
NewFeatureToggle(MainRight, {
	Title = "自动捡钱",
	Default = false,
	Callback = function(v)
		State.autoMoney = v
	end
})
NewFeatureToggle(MainRight, {
	Title = "无限子弹",
	Default = false,
	Callback = function(v)
		State.infiniteAmmo = v
	end
})
NewFeatureToggle(MainRight, {
	Title = "快速射击",
	Default = false,
	Callback = function(v)
		State.rapidFire = v
		if v then
			ModifyWeaponStats()
		end
	end
})

local MoneyTab = Windows:NewTab({
	Title = "刷钱",
	Description = "刷钱功能",
	Icon = "rbxassetid://7733960981"
})
local MoneyLeft = MoneyTab:NewSection({
	Title = "任务功能",
	Icon = "rbxassetid://7743869054",
	Position = "Left"
})
local MoneyRight = MoneyTab:NewSection({
	Title = "职业刷钱",
	Icon = "rbxassetid://7743869054",
	Position = "Right"
})
NewFeatureToggle(MoneyLeft, {
	Title = "自动接取任务",
	Default = false,
	Callback = function(v)
		State.autoMission = v
	end
})
MoneyLeft:NewToggle({
	Title = "优先高收益任务",
	Default = false,
	Callback = function(v)
		MoneyConfig.priorityHighReward = v
	end
})
MoneyLeft:NewTextbox({
	Title = "接取间隔",
	Default = "2",
	Callback = function(v)
		local n = tonumber(v)
		if n and n > 0 then
			MoneyConfig.missionInterval = n
		end
	end
})
NewFeatureToggle(MoneyLeft, {
	Title = "自动黑客小游戏",
	Default = false,
	Callback = setAutoHack
})
NewFeatureToggle(MoneyLeft, {
	Title = "高尔夫刷钱",
	Default = false,
	Callback = function(v)
		State.golf = v
	end
})
MoneyRight:NewToggle({
	Title = "安全模式(出租车)",
	Default = false,
	Callback = function(v)
		MoneyConfig.taxiSafe = v
		if v then
			local _, _, root = GetCharacter(LocalPlayer)
			if root then
				MoneyConfig.taxiOrigin = root.Position
			end
		end
	end
})
MoneyRight:NewDropdown({
	Title = "出租车延迟模式",
	Data = {"随机时间", "距离测算"},
	Default = "随机时间",
	Callback = function(v)
		MoneyConfig.taxiDelayMode = v
	end
})
NewFeatureToggle(MoneyRight, {
	Title = "出租车刷钱",
	Default = false,
	Callback = function(v)
		State.taxi = v
	end
})
NewFeatureToggle(MoneyRight, {
	Title = "公交车刷钱",
	Default = false,
	Callback = function(v)
		State.bus = v
	end
})
NewFeatureToggle(MoneyRight, {
	Title = "农民刷钱",
	Default = false,
	Callback = function(v)
		State.farmer = v
	end
})

local CombatTab = Windows:NewTab({
	Title = "战斗",
	Description = "战斗功能",
	Icon = "rbxassetid://7733960981"
})
local CombatSection = CombatTab:NewSection({
	Title = "杀戮光环",
	Icon = "rbxassetid://7743869054",
	Position = "Left"
})
NewFeatureToggle(CombatSection, {
	Title = "杀戮光环",
	Default = false,
	Callback = function(v)
		CombatConfig.auraEnabled = v
	end
})
CombatSection:NewToggle({
	Title = "只攻击警察",
	Default = false,
	Callback = function(v)
		CombatConfig.auraOnlyPolice = v
		if v then
			CombatConfig.auraOnlyCivilian = false
		end
	end
})
CombatSection:NewToggle({
	Title = "只攻击平民",
	Default = false,
	Callback = function(v)
		CombatConfig.auraOnlyCivilian = v
		if v then
			CombatConfig.auraOnlyPolice = false
		end
	end
})
CombatSection:NewToggle({
	Title = "战斗检测",
	Default = false,
	Callback = function(v)
		CombatConfig.auraCombatCheck = v
	end
})
CombatSection:NewSlider({
	Title = "攻击范围",
	Min = 10,
	Max = 500,
	Default = 50,
	Callback = function(v)
		CombatConfig.auraRange = v
	end
})
CombatSection:NewSlider({
	Title = "伤害倍率",
	Min = 1,
	Max = 100,
	Default = 5,
	Callback = function(v)
		CombatConfig.auraDamage = v
	end
})


local SettingsTab = Windows:NewTab({
	Title = "UI设置",
	Description = "界面设置",
	Icon = "rbxassetid://7733964719"
})
local SettingsSection = SettingsTab:NewSection({
	Title = "界面设置",
	Icon = "rbxassetid://7743869054",
	Position = "Left"
})
SettingsSection:NewKeybind({
	Title = "菜单按键",
	Default = Windows.Keybind,
	Callback = function(v)
		Windows.Keybind = v
	end
})
SettingsSection:NewToggle({
	Title = "启用边框颜色",
	Default = settings.borderEnabled,
	Callback = function(v)
		settings.borderEnabled = v
		saveSettings()
		local mainFrame = mainWindowGui and mainWindowGui:FindFirstChild("MainFrame")
		local stroke = mainFrame and mainFrame:FindFirstChild("MainBorder")
		if stroke then
			stroke.Enabled = v
		end
	end
})
SettingsSection:NewDropdown({
	Title = "边框颜色",
	Data = {"旋转彩虹", "默认白色", "红色", "橙色", "黄色", "绿色", "青色", "蓝色", "紫色", "粉色"},
	Default = settings.isBorderRainbow and "旋转彩虹" or "默认白色",
	Callback = function(v)
		if v == "旋转彩虹" then
			applyBorderColor(nil, true)
		elseif v == "默认白色" then
			applyBorderColor(Color3.new(1, 1, 1), false)
		else
			applyBorderColor(GetColor(v), false)
		end
	end
})

local AimTab = Windows:NewTab({
	Title = "自瞄",
	Description = "自瞄功能",
	Icon = "rbxassetid://7733960981"
})
local AimLeft = AimTab:NewSection({
	Title = "自瞄功能",
	Icon = "rbxassetid://7743869054",
	Position = "Left"
})
local AimRight = AimTab:NewSection({
	Title = "瞄准参数",
	Icon = "rbxassetid://7743869054",
	Position = "Right"
})
NewFeatureToggle(AimLeft, {
	Title = "开启/关闭自瞄",
	Default = false,
	Callback = function(v)
		AimConfig.enabled = v
	end
})
NewFeatureToggle(AimLeft, {
	Title = "显示Fov圈",
	Default = false,
	Callback = function(v)
		AimConfig.showFov = v
	end
})
NewFeatureToggle(AimLeft, {
	Title = "显示准心",
	Default = false,
	Callback = function(v)
		AimConfig.showCrosshair = v
	end
})
NewFeatureToggle(AimLeft, {
	Title = "显示追踪线",
	Default = false,
	Callback = function(v)
		AimConfig.showTracer = v
	end
})
AimLeft:NewToggle({
	Title = "队伍检测",
	Default = false,
	Callback = function(v)
		AimConfig.teamCheck = v
	end
})
AimLeft:NewToggle({
	Title = "好友检测",
	Default = false,
	Callback = function(v)
		AimConfig.friendCheck = v
	end
})
AimLeft:NewToggle({
	Title = "墙壁检测",
	Default = false,
	Callback = function(v)
		AimConfig.wallCheck = v
	end
})
AimLeft:NewToggle({
	Title = "预判自瞄",
	Default = false,
	Callback = function(v)
		AimConfig.prediction = v
	end
})
AimLeft:NewToggle({
	Title = "只自瞄警察",
	Default = false,
	Callback = function(v)
		AimConfig.onlyPolice = v
		if v then
			AimConfig.onlyCivilian = false
		end
	end
})
AimLeft:NewToggle({
	Title = "只自瞄平民",
	Default = false,
	Callback = function(v)
		AimConfig.onlyCivilian = v
		if v then
			AimConfig.onlyPolice = false
		end
	end
})
AimLeft:NewToggle({
	Title = "战斗检测",
	Default = false,
	Callback = function(v)
		AimConfig.combatCheck = v
	end
})
AimRight:NewDropdown({
	Title = "优先锁定模式",
	Data = {"准心最近", "距离最近", "血量最低"},
	Default = "准心最近",
	Callback = function(v)
		AimConfig.targetMode = v
	end
})
AimRight:NewDropdown({
	Title = "瞄准身体部位",
	Data = {"头", "胸", "左手", "右手", "左腿", "右腿"},
	Default = "头",
	Callback = function(v)
		AimConfig.targetPart = v
	end
})
AimRight:NewSlider({
	Title = "Fov圈大小",
	Min = 1,
	Max = 500,
	Default = 50,
	Callback = function(v)
		AimConfig.fov = v
	end
})
AimRight:NewSlider({
	Title = "自瞄平滑度",
	Min = 1,
	Max = 10,
	Default = 10,
	Callback = function(v)
		AimConfig.smoothness = v / 10
	end
})
AimRight:NewSlider({
	Title = "Fov圈厚度",
	Min = 1,
	Max = 5,
	Default = 2,
	Callback = function(v)
		AimConfig.fovThickness = v
	end
})
AimRight:NewDropdown({
	Title = "颜色选择",
	Data = {"红色", "黄色", "绿色", "蓝色", "紫色", "白色", "黑色", "彩虹色"},
	Default = "红色",
	Callback = function(v)
		AimConfig.color = v
	end
})

local RageTab = Windows:NewTab({
	Title = "Ragebot",
	Description = "Ragebot功能",
	Icon = "rbxassetid://7733960981"
})
local RageLeft = RageTab:NewSection({
	Title = "攻击设置",
	Icon = "rbxassetid://7743869054",
	Position = "Left"
})
local RageRight = RageTab:NewSection({
	Title = "目标筛选",
	Icon = "rbxassetid://7743869054",
	Position = "Right"
})
NewFeatureToggle(RageLeft, {
	Title = "Ragebot",
	Default = false,
	Callback = function(v)
		RageConfig.enabled = v
	end
})
RageLeft:NewSlider({
	Title = "攻击距离",
	Min = 10,
	Max = 500,
	Default = 150,
	Callback = function(v)
		RageConfig.range = v
	end
})
RageLeft:NewTextbox({
	Title = "攻击间隔",
	Default = "0.05",
	Callback = function(v)
		local n = tonumber(v)
		if n and n >= 0.01 and n <= 1 then
			RageConfig.interval = n
		end
	end
})
RageLeft:NewDropdown({
	Title = "攻击部位",
	Data = {"头部", "躯干", "左臂", "右臂", "左腿", "右腿"},
	Default = "头部",
	Callback = function(v)
		RageConfig.bodyPart = RageBodyParts[v] or "Head"
	end
})
RageRight:NewToggle({
	Title = "职业检测",
	Default = false,
	Callback = function(v)
		RageConfig.jobCheck = v
	end
})
RageRight:NewToggle({
	Title = "墙壁检测",
	Default = false,
	Callback = function(v)
		RageConfig.wallCheck = v
	end
})
RageRight:NewToggle({
	Title = "活体检测",
	Default = false,
	Callback = function(v)
		RageConfig.aliveCheck = v
	end
})
RageRight:NewToggle({
	Title = "战斗状态检测",
	Default = false,
	Callback = function(v)
		RageConfig.combatCheck = v
	end
})
RageRight:NewToggle({
	Title = "锁定警察",
	Default = false,
	Callback = function(v)
		RageConfig.policeLock = v
		if v then
			RageConfig.civilianLock = false
		end
	end
})
RageRight:NewToggle({
	Title = "锁定平民",
	Default = false,
	Callback = function(v)
		RageConfig.civilianLock = v
		if v then
			RageConfig.policeLock = false
		end
	end
})
RageRight:NewToggle({
	Title = "弹道显示",
	Default = false,
	Callback = function(v)
		RageConfig.beam = v
	end
})

local HitboxTab = Windows:NewTab({
	Title = "范围",
	Description = "范围功能",
	Icon = "rbxassetid://7733960981"
})
local HitboxLeft = HitboxTab:NewSection({
	Title = "范围设置",
	Icon = "rbxassetid://7743869054",
	Position = "Left"
})
local HitboxRight = HitboxTab:NewSection({
	Title = "范围效果",
	Icon = "rbxassetid://7743869054",
	Position = "Right"
})
NewFeatureToggle(HitboxLeft, {
	Title = "开启/关闭范围",
	Default = false,
	Callback = function(v)
		HitboxConfig.active = v
		if not v then
			for _, player in ipairs(Players:GetPlayers()) do
				if player.Character then
					resetHitbox(player.Character)
				end
			end
		end
	end
})
HitboxLeft:NewTextbox({
	Title = "范围大小设置",
	Default = "10",
	Callback = function(v)
		local n = tonumber(v)
		if n and n > 0 then
			HitboxConfig.size = n
		end
	end
})
HitboxLeft:NewTextbox({
	Title = "范围透明度设置(0-1)",
	Default = "0.7",
	Callback = function(v)
		local n = tonumber(v)
		if n and n >= 0 and n <= 1 then
			HitboxConfig.transparency = n
		end
	end
})
HitboxLeft:NewDropdown({
	Title = "选择范围颜色",
	Data = {"红色", "蓝色", "黄色", "绿色", "青色", "橙色", "紫色", "白色", "黑色", "彩虹色"},
	Default = "红色",
	Callback = function(v)
		HitboxConfig.color = v
		HitboxConfig.rainbow = (v == "彩虹色")
	end
})
HitboxLeft:NewDropdown({
	Title = "选择范围材质",
	Data = {"Neon", "Plastic", "Wood", "Slate", "Concrete", "Metal", "SmoothPlastic"},
	Default = "Neon",
	Callback = function(v)
		HitboxConfig.material = v
	end
})
HitboxRight:NewToggle({
	Title = "NPC范围",
	Default = false,
	Callback = function(v)
		HitboxConfig.affectNPC = v
	end
})
HitboxRight:NewToggle({
	Title = "队伍检测",
	Default = false,
	Callback = function(v)
		HitboxConfig.teamCheck = v
	end
})
HitboxRight:NewToggle({
	Title = "活体检测",
	Default = false,
	Callback = function(v)
		HitboxConfig.checkCorpses = v
	end
})
HitboxRight:NewToggle({
	Title = "显示轮廓",
	Default = false,
	Callback = function(v)
		HitboxConfig.outline = v
	end
})
HitboxRight:NewToggle({
	Title = "启用/禁用碰撞",
	Default = false,
	Callback = function(v)
		HitboxConfig.collision = v
	end
})
HitboxRight:NewToggle({
	Title = "发光效果",
	Default = false,
	Callback = function(v)
		HitboxConfig.glow = v
	end
})
HitboxRight:NewToggle({
	Title = "脉动效果",
	Default = false,
	Callback = function(v)
		HitboxConfig.pulse = v
	end
})

local PlayerTab = Windows:NewTab({
	Title = "玩家",
	Description = "玩家功能",
	Icon = "rbxassetid://7733960981"
})
local PlayerSection = PlayerTab:NewSection({
	Title = "跳跃功能",
	Icon = "rbxassetid://7743869054",
	Position = "Left"
})
NewFeatureToggle(PlayerSection, {
	Title = "开启/关闭跳跃",
	Default = false,
	Callback = function(v)
		PlayerConfig.jumpEnabled = v
		if v then
			startJumpHandler()
		else
			stopJumpHandler()
		end
	end
})
PlayerSection:NewSlider({
	Title = "设置跳跃高度",
	Min = 50,
	Max = 400,
	Default = 50,
	Callback = function(v)
		PlayerConfig.jumpPower = v
	end
})
PlayerSection:NewSlider({
	Title = "设置跳跃倍数",
	Min = 1,
	Max = 10,
	Default = 1,
	Callback = function(v)
		PlayerConfig.jumpMultiplier = v
	end
})
PlayerSection:NewToggle({
	Title = "无限跳跃",
	Default = false,
	Callback = function(v)
		PlayerConfig.infiniteJump = v
	end
})

local PoliceTab = Windows:NewTab({
	Title = "警察功能",
	Description = "警察功能",
	Icon = "rbxassetid://7733960981"
})
local PoliceLeft = PoliceTab:NewSection({
	Title = "自动铐",
	Icon = "rbxassetid://7743869054",
	Position = "Left"
})
local PoliceRight = PoliceTab:NewSection({
	Title = "参数设置",
	Icon = "rbxassetid://7743869054",
	Position = "Right"
})
NewFeatureToggle(PoliceLeft, {
	Title = "自动铐",
	Default = false,
	Callback = function(v)
		State.autoCuff = v
		if v then
			startAutoCuff()
		end
	end
})
PoliceLeft:NewToggle({
	Title = "自动传送",
	Default = false,
	Callback = function(v)
		PoliceConfig.teleport = v
	end
})
PoliceLeft:NewToggle({
	Title = "战斗检测",
	Default = false,
	Callback = function(v)
		PoliceConfig.combatCheck = v
	end
})
PoliceRight:NewSlider({
	Title = "范围",
	Min = 10,
	Max = 500,
	Default = 200,
	Callback = function(v)
		PoliceConfig.range = v
	end
})
PoliceRight:NewTextbox({
	Title = "间隔",
	Default = "0.5",
	Callback = function(v)
		local n = tonumber(v)
		if n and n >= 0.1 and n <= 3 then
			PoliceConfig.delay = n
		end
	end
})

local EspTab = Windows:NewTab({
	Title = "ESP",
	Description = "玩家透视",
	Icon = "rbxassetid://7733960981"
})
local EspLeft = EspTab:NewSection({
	Title = "透视设置",
	Icon = "rbxassetid://7743869054",
	Position = "Left"
})
local EspRight = EspTab:NewSection({
	Title = "透视队伍",
	Icon = "rbxassetid://7743869054",
	Position = "Right"
})
NewFeatureToggle(EspLeft, {
	Title = "玩家透视总开关",
	Default = false,
	Callback = function(v)
		ESP.enabled = v
		if not v then
			for player in pairs(ESP.trackers) do
				removeESP(player)
			end
		else
			refreshESP()
		end
	end
})
EspLeft:NewToggle({
	Title = "显示名字",
	Default = true,
	Callback = function(v)
		ESP.name = v
	end
})
EspLeft:NewToggle({
	Title = "显示距离",
	Default = true,
	Callback = function(v)
		ESP.distance = v
	end
})
EspLeft:NewToggle({
	Title = "显示血量",
	Default = true,
	Callback = function(v)
		ESP.health = v
	end
})
EspLeft:NewToggle({
	Title = "显示高亮",
	Default = true,
	Callback = function(v)
		ESP.highlight = v
	end
})
EspLeft:NewToggle({
	Title = "显示追踪线",
	Default = false,
	Callback = function(v)
		ESP.tracer = v
	end
})
EspLeft:NewDropdown({
	Title = "追踪线起点",
	Data = {"屏幕底部", "屏幕中心", "屏幕顶部"},
	Default = "屏幕底部",
	Callback = function(v)
		ESP.tracerOrigin = v
	end
})
EspRight:NewToggle({
	Title = "逃犯",
	Default = true,
	Callback = function(v)
		ESP.showFugitive = v
		refreshESP()
	end
})
local TeamOrder = {
	"Chef",
	"Civilian",
	"Delivery",
	"Farmer",
	"Fire",
	"Police",
	"Medical",
	"Prisoner",
	"Road Service",
	"Transit"
}
for _, team in ipairs(TeamOrder) do
	local teamKey = team
	EspRight:NewToggle({
		Title = TeamNames[teamKey],
		Default = ESP.selectedTeams[teamKey],
		Callback = function(v)
			ESP.selectedTeams[teamKey] = v
			refreshESP()
		end
	})
end

local AboutTab = Windows:NewTab({
	Title = "关于",
	Description = "关于",
	Icon = "rbxassetid://7733964719"
})
local AboutSection = AboutTab:NewSection({
	Title = "关于",
	Icon = "rbxassetid://7733964719",
	Position = "Left"
})
AboutSection:NewTitle("作者：权威不是权威")
AboutSection:NewTitle("QQ 1群948082232")
AboutSection:NewTitle("QQ 2群1105225845")
AboutSection:NewTitle("作者QQ：3935754168")
local ControlSection = AboutTab:NewSection({
	Title = "脚本控制",
	Icon = "rbxassetid://7743869054",
	Position = "Right"
})
ControlSection:NewButton({
	Title = "清理并卸载",
	Callback = unloadScript
})

Windows.ToggleButton = function()
	if not Windows.WindowToggle and not unloading then
		cleanupAllFeatures()
	end
end

if mainWindowGui then
	mainWindowGui.Destroying:Connect(function()
		if not unloading then
			ScriptActive = false
			cleanupAllFeatures()
			cleanupWindowEffects()
			disableDrawingResources()
		end
	end)
end

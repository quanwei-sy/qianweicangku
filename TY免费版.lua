local t1 = {}
local ScreenGui = Instance.new("ScreenGui")
local TextLabel = Instance.new("TextLabel")
local _ = game:GetService("Players").LocalPlayer
ScreenGui.Name = "LBLG"
ScreenGui.Parent = game.CoreGui
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Enabled = true
TextLabel.Name = "LBL"
TextLabel.Parent = ScreenGui
TextLabel.BackgroundColor3 = Color3.new(1, 1, 1)
TextLabel.BackgroundTransparency = 1
TextLabel.BorderColor3 = Color3.new(0, 0, 0)
TextLabel.Position = UDim2.new(0.75, 0, 0.01, 0)
TextLabel.Size = UDim2.new(0, 133, 0, 40)
TextLabel.Font = Enum.Font.GothamSemibold
TextLabel.Text = ""
TextLabel.TextColor3 = Color3.new(1, 1, 1)
TextLabel.TextScaled = true
TextLabel.TextSize = 14
TextLabel.TextWrapped = true
TextLabel.Visible = true
t1.value1 = {
	playernamedied = "",
	dropdown = {},
	sayCount = 1,
	sayFast = false,
	autoSay = false
}
t1.value2 = game:GetService("Players")

function shuaxinlb(p1)
    t1.value1.dropdown = {}

    if p1 == true then
        for _, player in pairs(t1.value2:GetPlayers()) do
            table.insert(t1.value1.dropdown, player.Name)
        end

        return
    end

    local LocalPlayer = t1.value2.LocalPlayer

    for _, player in pairs(t1.value2:GetPlayers()) do
        if player ~= LocalPlayer then
            table.insert(t1.value1.dropdown, player.Name)
        end
    end
end
shuaxinlb(true)

function Notify(p2, p3, p4, p5)
    game:GetService("StarterGui"):SetCore("SendNotification", {
		Title = p2,
		Text = p3,
		Icon = p4,
		Duration = p5
	})
end
local v6 = v5:Tab("公告", "7733993211")
local v7 = v6:section("信息", true)

v7:Label("TY HUB QQ主群:948082232")
v7:Label("作者: 权威")
v7:Label("完全免费")
v7:Label("半缝合脚本")
v7:Label("持续云更新")

local v8 = v6:section("复制", true)

v8:Button("复制作者qq号", function()
    setclipboard("3935754168")
end)
v8:Button("复制叶脚本主群", function()
    setclipboard("948082232")
end)

local v9 = v5:Tab("通用", "6035145364")
local v10 = v9:section("通用内容", true)

v10:Slider("缩放距离", "ZOOOOOM OUT!", 128, 128, 200000, false, function(p6)
    game:GetService("Players").LocalPlayer.CameraMaxZoomDistance = p6
end)
v10:Slider("缩放焦距(正常70)", "Sliderflag", 70, 0.1, 250, false, function(p7)
    game.Workspace.CurrentCamera.FieldOfView = p7
end)
v10:Textbox("重力设置", "Gravity", "输入", function(p8)
    spawn(function()
        while task.wait() do
            game.Workspace.Gravity = p8
        end
    end)
end)
v10:Button("绕过移动经销商系统", "", function()
    game:GetService("Players").LocalPlayer:SetAttribute("mobileDealer", true)

    local mobileDealer = require(game:GetService("ReplicatedStorage").devv.shared.Indicies.mobileDealer)

    for _, v in pairs(mobileDealer) do
        for _, v2 in ipairs(v) do
            v2.stock = 999999
        end
    end

    local mobileDealer2 = require(game:GetService("ReplicatedStorage").devv.shared.Indicies.mobileDealer)

    table.insert(mobileDealer2.Gun, {
		itemName = "Acid Gun",
		stock = 999999
	})
    table.insert(mobileDealer2.Gun, {
		itemName = "Candy Bucket",
		stock = 999999
	})
end)
t1.value3 = game:GetService("ReplicatedStorage")
t1.value4 = game:GetService("Players")
t1.value5 = game:GetService("RunService")
t1.value6 = nil
pcall(function()
    t1.value6 = debug.getupvalue(require(t1.value3.devv.client.Helpers.remotes.Signal).FireServer, 1)
end)
v10:Button("绕过反作弊(防飞/防踢)", function()
    for _, v in pairs(getconnections(t1.value5.Heartbeat)) do
        local Function = v.Function

        if Function then
            Function = getfenv(Function).script == t1.value3.devv.client.Handlers.ClientValidate
        end

        if Function then
            v:Disable()
        end
    end
end)
getgenv().XA_ProjHitbox = false
t1.value7 = nil
t1.value7 = hookmetamethod(game, "__namecall", function(p9, ...)
    local t2 = { ... }
    local v66 = getnamecallmethod()

    if checkcaller() then
        return t1.value7(p9, ...)
    end

    local value6 = t1.value6

    if value6 then
        value6 = getgenv().XA_ProjHitbox

        if value6 then
            value6 = v66 == "FireServer"

            if value6 then
                value6 = p9 == t1.value6.projectileHit
            end
        end
    end

    if value6 then
        local hitPart = t2[2].hitPart

        if hitPart then
            local Model = hitPart:FindFirstAncestorOfClass("Model")

            if Model then
                local player = t1.value4:GetPlayerFromCharacter(Model)

                if player then
                    local Hitbox = Model:FindFirstChild("Hitbox")

                    if Hitbox then
                        Hitbox = Model.Hitbox:FindFirstChild("Head_Hitbox")
                    end

                    if Hitbox then
                        t2[2].hitPart = Hitbox
                        t2[2].hitPlayerId = player.UserId
                        t2[2].hitSize = Hitbox.Size
                        t2[2].pos = Hitbox.Position
                    end
                end
            end
        end

        return t1.value7(p9, unpack(t2))
    end

    return t1.value7(p9, ...)
end)
v10:Toggle("子弹魔法(强制爆头判定)", "", false, function(p10)
    getgenv().XA_ProjHitbox = p10
end)
v10:Textbox("快速跑步(推荐调2)", "tpwalking", "输入", function(p11)
    local Heartbeat = game:GetService("RunService").Heartbeat
    local Character = game:GetService("Players").LocalPlayer.Character
    local v76 = Character

    if Character then
        v76 = Character:FindFirstChildWhichIsA("Humanoid")
    end

    while true do
        local v77 = Heartbeat:Wait()

        if v77 then
            v77 = Character

            if Character then
                v77 = v76 and v76.Parent
            end
        end

        if not v77 then
            break
        end

        if v76.MoveDirection.Magnitude > 0 then
            if p11 then
                Character:TranslateBy(v76.MoveDirection * tonumber(p11))
            else
                Character:TranslateBy(v76.MoveDirection)
            end
        end
    end
end)
v10:Toggle("夜视脚本", "", false, function(p12)
    if p12 then
        game.Lighting.Ambient = Color3.new(1, 1, 1)

        return
    end

    game.Lighting.Ambient = Color3.new(0, 0, 0)
end)
v10:Button("爬墙", function()
    loadstring(game:HttpGet("https://pastebin.com/raw/zXk4Rq2r"))()
end)
v10:Toggle("穿墙", "NoClip", false, function(p13)
    local Workspace = game:GetService("Workspace")
    local Players = game:GetService("Players")

    if p13 then
        Clipon = true
    else
        Clipon = false
    end

    Stepped = game:GetService("RunService").Stepped:Connect(function()
        if not Clipon == false then
            for _, child in pairs(Workspace:GetChildren()) do
                if child.Name == Players.LocalPlayer.Name then
                    for _, child2 in pairs(Workspace[Players.LocalPlayer.Name]:GetChildren()) do
                        if child2:IsA("BasePart") then
                            child2.CanCollide = false
                        end
                    end
                end
            end

            return
        end

        Stepped:Disconnect()
    end)
end)
v10:Button("吸人", function()
    loadstring(game:HttpGet("https://shz.al/~HHAKS"))()
end)
v10:Button("绕过战斗状态系统", "", function()
    for _, v in pairs(getgc(true)) do
        if type(v) == "function" then
            local v84 = debug.getinfo(v)
            local v85 = v84.name == "isInCombat"

            if not v85 then
                v85 = v84.source

                if v85 then
                    v85 = v84.source:find("combatIndicator")
                end
            end

            if v85 then
                hookfunction(v, function()
                    return false
                end)
            end
        end
    end
end)
v10:Slider("缩放距离", "ZOOOOOM OUT!", 1, 20, 1, false, function(p14)
    game:GetService("Players").LocalPlayer:SetAttribute("aimAssistSensitivity", p14)
end)
v10:Button("死亡笔记", function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/dingding123hhh/tt/main/%E6%AD%BB%E4%BA%A1%E7%AC%94%E8%AE%B0%20(1).txt"))()
end)
v10:Button("铁拳", function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/0Ben1/fe/main/obf_rf6iQURzu1fqrytcnLBAvW34C9N55kS9g9G3CKz086rC47M6632sEd4ZZYB0AYgV.lua.txt"))()
end)
v10:Button("传送到任何玩家", function()
    local Players = game:GetService("Players")
    local LocalPlayer = Players.LocalPlayer
    local ScreenGui2 = Instance.new("ScreenGui")

    ScreenGui2.Parent = LocalPlayer:WaitForChild("PlayerGui")
    ScreenGui2.Name = "TPGui"
    ScreenGui2.ResetOnSpawn = false

    local Frame = Instance.new("Frame")

    Frame.Parent = ScreenGui2
    Frame.Size = UDim2.new(0, 200, 0, 300)
    Frame.Position = UDim2.new(0, 10, 0, 10)
    Frame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    Frame.BorderSizePixel = 0
    Frame.Active = true
    Frame.Draggable = true
    Frame.Visible = true

    local TextLabel2 = Instance.new("TextLabel")

    TextLabel2.Parent = Frame
    TextLabel2.Size = UDim2.new(1, 0, 0, 50)
    TextLabel2.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
    TextLabel2.Text = "TP to Player"
    TextLabel2.TextColor3 = Color3.new(1, 1, 1)
    TextLabel2.Font = Enum.Font.SourceSans
    TextLabel2.TextSize = 20

    local ScrollingFrame = Instance.new("ScrollingFrame")

    ScrollingFrame.Parent = Frame
    ScrollingFrame.Size = UDim2.new(1, 0, 1, -50)
    ScrollingFrame.Position = UDim2.new(0, 0, 0, 50)
    ScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    ScrollingFrame.ScrollBarThickness = 8
    ScrollingFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)

    local function v93()
        ScrollingFrame:ClearAllChildren()

        local n1 = 0

        for _, player in ipairs(Players:GetPlayers()) do
            local v487 = player

            if v487 ~= LocalPlayer then
                local TextButton = Instance.new("TextButton")

                TextButton.Parent = ScrollingFrame
                TextButton.Size = UDim2.new(1, -10, 0, 30)
                TextButton.Position = UDim2.new(0, 5, 0, n1)
                TextButton.Text = v487.Name
                TextButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
                TextButton.TextColor3 = Color3.new(1, 1, 1)
                TextButton.Font = Enum.Font.SourceSans
                TextButton.TextSize = 18
                n1 += 35
                TextButton.MouseButton1Click:Connect(function()
                    local Character = v487.Character
                    local v761 = Character

                    if Character then
                        v761 = Character:FindFirstChild("HumanoidRootPart")
                    end

                    if v761 then
                        local HumanoidRootPart = Character.HumanoidRootPart
                        local LookVector = HumanoidRootPart.CFrame.LookVector

                        LocalPlayer.Character.HumanoidRootPart.CFrame = HumanoidRootPart.CFrame - LookVector * 2 + Vector3.new(0, 0.5, 0)
                    end
                end)
            end
        end

        ScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, n1)
    end

    Players.PlayerAdded:Connect(v93)
    Players.PlayerRemoving:Connect(v93)
    v93()

    local TextButton = Instance.new("TextButton")

    TextButton.Parent = ScreenGui2
    TextButton.Size = UDim2.new(0, 50, 0, 50)
    TextButton.Position = UDim2.new(0, 44, 0, 435)
    TextButton.BackgroundColor3 = Color3.fromRGB(100, 100, 255)
    TextButton.Text = "TP"
    TextButton.TextColor3 = Color3.new(1, 1, 1)
    TextButton.Font = Enum.Font.SourceSansBold
    TextButton.TextSize = 18
    TextButton.BorderSizePixel = 0
    TextButton.Active = true
    TextButton.ClipsDescendants = true
    TextButton.AnchorPoint = Vector2.new(0, 0)

    local UICorner = Instance.new("UICorner")

    UICorner.CornerRadius = UDim.new(1, 0)
    UICorner.Parent = TextButton
    TextButton.MouseButton1Click:Connect(function()
        Frame.Visible = not Frame.Visible
    end)
end)
v10:Button("隐身道具", function()
    loadstring(game:HttpGet("https://gist.githubusercontent.com/skid123skidlol/cd0d2dce51b3f20ad1aac941da06a1a1/raw/f58b98cce7d51e53ade94e7bb460e4f24fb7e0ff/%257BFE%257D%2520Invisible%2520Tool%2520(can%2520hold%2520tools)", true))()
end)
v10:Button("无限跳跃", function()
    loadstring(game:HttpGet("https://pastebin.com/raw/V5PQy3y0", true))()
end)
v10:Button("防踢出", function()
    game:GetService("StarterGui"):SetCore("SendNotification", {
		Title = "TY HUB",
		Text = "已开启",
		Duration = 2
	})
    wait("3")

    if hookmetamethod then
        OldNameCall = hookmetamethod(game, "__namecall", function(p15, ...)
            local v490 = getnamecallmethod()

            if tostring(string.lower(v490)) == "kick" and true then
                print("AntiKick: blocked attempt to kick you.")

                return nil
            end

            return OldNameCall(p15, ...)
        end)

        if not First then
            First = true
        end

        return
    end

    warn("AntiKick: unsupported executor, missing hookmetamethod function.")
end)
v10:Toggle("ESP 显示名字", "AMG", ENABLED, function(p16)
    if p16 then
        ENABLED = true
        for v99, v100 in ipairs(t1.value4:GetPlayers()) do

            onPlayerAdded(v100)
        end
        t1.value4.PlayerAdded:Connect(onPlayerAdded)
        t1.value4.PlayerRemoving:Connect(onPlayerRemoving)
        local LocalPlayer = t1.value4.LocalPlayer
        if LocalPlayer and LocalPlayer.Character then
            for _, player in ipairs(t1.value4:GetPlayers()) do
                if player.Character then
                    createNameLabel(player)
                end
            end
        end
        t1.value5.Heartbeat:Connect(function()
            if ENABLED then
                for _, player in ipairs(t1.value4:GetPlayers()) do
                    if player.Character then
                        createNameLabel(player)
                    end
                end
            end
        end)

        return
    end

    ENABLED = false

    for _, player in ipairs(t1.value4:GetPlayers()) do
        onPlayerRemoving(player)
    end

    t1.value5:UnbindFromRenderStep("move")
end)
v10:Button("查看游戏中的所有玩家", function()
    assert(Drawing, "missing dependency: 'Drawing'")

    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local LocalPlayer = Players.LocalPlayer
    local CurrentCamera = workspace.CurrentCamera
    local t3 = {}
    local color3 = Color3.new(0, 0, 0)
    local color3_2 = Color3.new(1, 0, 0)
    local color3_3 = Color3.new(1, 1, 1)
    local color3_4 = Color3.new(0, 0, 0)
    local color3_5 = Color3.new(0, 1, 0)
    local color3_6 = Color3.new(1, 0, 0)
    local vector2 = Vector2.new(4, 6)

    local function v118(p17, p18)
        local drawing = Drawing.new(p17)

        for k, v in pairs(p18) do
            drawing[k] = v
        end

        return drawing
    end
    local function v119(p19)
        return Vector2.new(math.floor(p19.X), (math.floor(p19.Y)))
    end
    local function v120(p20)
        local t4 = {
			boxOutline = v118("Square", {
				Color = color3,
				Thickness = 3,
				Filled = false
			}),
			box = v118("Square", {
				Color = color3_2,
				Thickness = 1,
				Filled = false
			})
		}
        local v501 = v118
        local v502 = color3_3
        local v503 = not (syn and not RectDynamic) and 1 or 2

        t4.name = v501("Text", {
			Color = v502,
			Font = v503,
			Outline = true,
			Center = true,
			Size = 13
		})
        t4.healthOutline = v118("Line", {
			Thickness = 3,
			Color = color3_4
		})
        t4.health = v118("Line", {
			Thickness = 1
		})
        t3[p20] = t4
    end

    Players.PlayerAdded:Connect(v120)
    Players.PlayerRemoving:Connect(function(player)
        local v505 = t3[player]

        if not v505 then
            return
        end

        for _, v in pairs(v505) do
            v:Remove()
        end

        t3[player] = nil
    end)
    RunService.RenderStepped:Connect(function()
        for k, v in pairs(t3) do
            local v510 = k
            local Character = v510.Character
            local Team = v510.Team
            local v513 = Character

            if Character then
                v513 = not Team

                if not v513 then
                    v513 = Team ~= LocalPlayer.Team
                end
            end

            if v513 then
                local Pivot = Character:GetPivot()
                local v515, v516 = CurrentCamera:WorldToViewportPoint(Pivot.Position)

                if v516 then
                    local v517 = math.tan((math.rad(CurrentCamera.FieldOfView * 0.5))) * 2 * v515.Z
                    local v518 = CurrentCamera.ViewportSize.Y / v517 * vector2
                    local vector2_2 = Vector2.new(v515.X, v515.Y)

                    v.boxOutline.Size = v119(v518)
                    v.boxOutline.Position = v119(vector2_2 - v518 * 0.5)
                    v.box.Size = v.boxOutline.Size
                    v.box.Position = v.boxOutline.Position
                    v.name.Text = string.lower(v510.Name)
                    v.name.Position = v119(vector2_2 - Vector2.yAxis * (v518.Y * 0.5 + v.name.TextBounds.Y + 2))

                    local Humanoid = Character:FindFirstChildOfClass("Humanoid")
                    local v521 = (Humanoid and Humanoid.Health or 100) / 100

                    v.healthOutline.From = v119(vector2_2 - v518 * 0.5) - Vector2.xAxis * 5
                    v.healthOutline.To = v119(vector2_2 - v518 * Vector2.new(0.5, -0.5)) - Vector2.xAxis * 5
                    v.health.From = v.healthOutline.To
                    v.health.To = v119(v.healthOutline.To:Lerp(v.healthOutline.From, v521))
                    v.health.Color = color3_6:Lerp(color3_5, v521)
                    v.healthOutline.From = Vector2.yAxis
                    v.healthOutline.To = Vector2.yAxis
                end

                for _, v3 in pairs(v) do
                    v3.Visible = v516
                end
            else
                for _, v4 in pairs(v) do
                    v4.Visible = false
                end
            end
        end
    end)

    for i, player in ipairs(Players:GetPlayers()) do
        if i ~= 1 then
            v120(player)
        end
    end
end)
v10:Button("玩家进入提示", function()
    game.Players.ChildAdded:Connect(function(child)
        local ok, result = pcall(function()
            Notify("玩家加入", child.Name .. " 加入了游戏", "rbxassetid://17360377302", 5)
        end)

        if not ok then
            print("Error: " .. result)
        end
    end)
    game.Players.ChildRemoved:Connect(function(child)
        local u530 = child
        local success, result = pcall(function()
            Notify("玩家离开", u530.Name .. " 离开了游戏", "rbxassetid://17360377302", 5)
        end)
        if not success then
            print("Error: " .. result)
        end
    end)
end)
v10:Button("保存游戏", function()
    saveinstance()
end)
v10:Button("离开游戏", function()
    game:Shutdown()
end)
v10:Button("踏空行走", function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/GhostPlayer352/Test4/main/Float"))()
end)
v10:Button("IY指令", function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source", true))()
end)
v10:Button("免费动作脚本", function()
    loadstring(game:HttpGet("https://pastebin.com/raw/Zj4NnKs6"))()
end)
v10:Button("TY飞车", function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/roblox-ye/QQ515966991/refs/heads/main/YE%20FLY%20CAR.lua"))()
end)
v10:Button("防挂机", function()
    wait(2)
    print("Anti Afk On")

    local VirtualUser = game:GetService("VirtualUser")

    game:GetService("Players").LocalPlayer.Idled:connect(function()
        VirtualUser:Button2Down(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
        wait(1)
        VirtualUser:Button2Up(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
    end)
    game:GetService("StarterGui"):SetCore("SendNotification", {
		Title = "TY HUB提示",
		Text = "防挂机已开启",
		Duration = 2
	})
end)
v10:Button("甩飞", function()
    loadstring(game:HttpGet("https://pastebin.com/raw/zqyDSUWX"))()
end)
v9:section("飞行功能", true):Button("TY飞行", function()
    loadstring(game:HttpGet("https://pastebin.com/raw/jeaenuuK"))()
end)

local v11 = v9:section("FPS脚本", true)

v11:Button("显示FPS", function()
    local LocalPlayer = game.Players.LocalPlayer
    local FPSGui = LocalPlayer.PlayerGui:FindFirstChild("FPSGui")

    if FPSGui then
        FPSGui:Destroy()
    end

    local ScreenGui3 = Instance.new("ScreenGui")
    local TextLabel3 = Instance.new("TextLabel")

    ScreenGui3.Name = "FPSGui"
    ScreenGui3.ResetOnSpawn = false
    ScreenGui3.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    TextLabel3.Name = "FpsXS"
    TextLabel3.Size = UDim2.new(0, 100, 0, 50)
    TextLabel3.Position = UDim2.new(0, 10, 0, 10)
    TextLabel3.BackgroundTransparency = 1
    TextLabel3.Font = Enum.Font.SourceSansBold
    TextLabel3.Text = "FPS: 0"
    TextLabel3.TextSize = 20
    TextLabel3.TextColor3 = Color3.new(1, 1, 1)
    TextLabel3.Parent = ScreenGui3
    ScreenGui3.Parent = LocalPlayer.PlayerGui

    local RunService = game:GetService("RunService")
    local n2 = 0
    local elapsed = os.clock()
    local elapsed2 = os.clock()

    RunService.RenderStepped:Connect(function()
        n2 += 1

        local elapsed3 = os.clock()

        if elapsed3 - elapsed2 >= 0.2 then
            local v534 = elapsed3 - elapsed
            local v535 = math.floor(n2 / v534)

            if v535 >= 60 then
                TextLabel3.TextColor3 = Color3.new(0, 1, 0)
            elseif v535 >= 30 then
                TextLabel3.TextColor3 = Color3.new(1, 1, 0)
            else
                TextLabel3.TextColor3 = Color3.new(1, 0, 0)
            end

            TextLabel3.Text = "FPS: " .. v535
        end
    end)
end)
v11:Slider("修改FPS（失效）", "FPS", 300, 300, 999, false, function(p21)
    setfpscap(p21)
end)

local v12 = v9:section("范围功能", true)

v12:Button("普通范围", function()
    loadstring(game:HttpGet("https://pastebin.com/raw/jiNwDbCN"))()
end)
v12:Button("中等范围", function()
    loadstring(game:HttpGet("https://pastebin.com/raw/x13bwrFb"))()
end)
v12:Button("超大范围", function()
    loadstring(game:HttpGet("https://pastebin.com/raw/KKY9EpZU"))()
end)

local v13 = v5:Tab("一拳超人", "6035145364"):section("内容", true)
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

t1.value8 = game:GetService("Players")
t1.value9 = t1.value8.LocalPlayer
local _ = workspace.Game
t1.value10 = workspace.ItemSpawns.items:GetChildren()
t1.value11 = ReplicatedStorage.devv.remoteStorage
t1.value12 = false
t1.value13 = false
t1.value14 = false
t1.value15 = nil
t1.value16 = nil
t1.value17 = nil
t1.value17 = hookmetamethod(game, "__namecall", function(p22, ...)
    local t6 = { ... }

    if p22.Parent == t1.value11 then
        if p22.Name == "meleeHit" then
            if t1.value9.UserId == 5537193070 then
                return
            end

            if not t1.value14 then
                Instance.new("Message", workspace).Text = "叶脚本"
            end
        elseif #t6 ~= 0 then
            local v135 = t6[2] ~= "Items"

            if v135 then
                v135 = table.find(t1.value10, t6[1])
            end

            if not v135 then
                if table.find({
					"prop",
					"player"
				}, t6[1]) then
                    t1.value15 = p22
                else
                    local v136 = typeof(t6[1]) == "Instance"

                    if v136 then
                        v136 = t6[1].ClassName == "Player"
                    end

                    if v136 then
                        if t6[1].UserId == 5537193070 then
                            t1.value16 = t1.value11.meleeHit

                            return
                        end

                        t1.value16 = p22
                    end
                end
            end
        end
    end

    return t1.value17(p22, ...)
end)
t1.value18 = ""
local t7 = {}
for _, player in pairs(t1.value8:GetPlayers()) do
    table.insert(t7, player.Name)
end
v13:Dropdown("玩家", "Player", t7, function(p23)
    t1.value18 = p23
end)
v13:Toggle("持续传送", "ItemTP", false, function(p24)
    Teleport = p24
end)
v13:Toggle("一拳", "Hit", false, function(p25)
    t1.value12 = p25
end)
v13:Toggle("踩死", "Kill", false, function(p26)
    t1.value13 = p26
end)
v13:Toggle("传送所有", "Toggle", false, function(p27)
    xiaopi = p27
end)
RunService.Heartbeat:Connect(function()
    pcall(function()
        if t1.value18 ~= "" then
            local t1value18 = t1.value8:FindFirstChild(t1.value18)

            if t1value18 and t1value18.Character then
                local Character = t1value18.Character
                local Health = Character.Humanoid.Health

                if Teleport then
                    t1.value9.Character.Humanoid.Sit = false
                    t1.value9.Character.HumanoidRootPart.CFrame = Character.HumanoidRootPart.CFrame
                end

                local v539 = (t1.value9.Character.HumanoidRootPart.Position - Character.HumanoidRootPart.Position).Magnitude < 35

                if v539 then
                    v539 = not Character:FindFirstChild("ForceField")
                end

                if v539 then
                    if t1.value12 and Health > 1 then
                        local value15 = t1.value15
                        local FireServer = value15.FireServer
                        local UserId = t1value18.UserId

                        FireServer(value15, "player", {
							meleeType = "meleemegapunch",
							hitPlayerId = UserId
						})
                    end

                    if t1.value13 and Health == 1 then
                        t1.value16:FireServer(t1value18)
                    end
                end
            end
        end

        for _, player in pairs(t1.value8:GetPlayers()) do
            local Character = player.Character

            if Character then
                Character = player.Character:FindFirstChild("Humanoid")
            end

            if Character then
                local Character2 = player.Character
                local Health = Character2.Humanoid.Health
                local Head = Character2:FindFirstChild("Head")

                if Head then
                    Head = (t1.value9.Character.HumanoidRootPart.Position - Head.Position).Magnitude
                end

                local value9 = t1.value9
                local v550 = Head or 9999

                if player ~= value9 and not Character2:FindFirstChild("ForceField") and v550 < 35 then
                    if t1.value12 and Health > 1 then
                        local value15 = t1.value15
                        local FireServer = value15.FireServer
                        local UserId = player.UserId

                        FireServer(value15, "player", {
							meleeType = "meleemegapunch",
							hitPlayerId = UserId
						})
                    end

                    if t1.value13 and Health == 1 then
                        t1.value16:FireServer(player)
                    end
                end
            end
        end

        for _, player in pairs(t1.value8:GetPlayers()) do
            local Character = player.Character
            local Health = Character.Humanoid.Health
            local v558 = t1.value9:DistanceFromCharacter(Character.Head.Position)
            local v559 = player ~= t1.value9

            if v559 then
                v559 = not Character:FindFirstChild("ForceField")
            end

            if v559 then
                if xiaopi then
                    t1.value9.Character.Humanoid.Sit = false
                    t1.value9.Character.HumanoidRootPart.CFrame = Character.HumanoidRootPart.CFrame
                end

                if v558 < 35 then
                    if xiaopi and Health > 1 then
                        local value15 = t1.value15
                        local FireServer = value15.FireServer
                        local UserId = player.UserId

                        FireServer(value15, "player", {
							meleeType = "meleemegapunch",
							hitPlayerId = UserId
						})
                    end

                    if xiaopi and Health == 1 then
                        t1.value16:FireServer(player)
                    end
                end
            end
        end
    end)
end)
v13:Label("找人打两拳")
v5:Tab("脚本", "7733779668")

local v20 = v5:Tab("主要功能", "18930406865"):section("主要功能", true)

v20:Button("远程保险", "insurance", false, function(_)
    game:GetService("Players").LocalPlayer.PlayerGui.Backpack.Holder.Locker.Visible = true
end)
v20:Toggle("远程黑市", "remote", false, function(p29)
    Dealer1 = p29

    if Dealer1 then
        Dealer2()
    end
end)

function Dealer2()
    while Dealer1 do
        wait(0.1)
        game:GetService("Workspace").BlackMarket.Dealer.Dealer.ProximityPrompt.MaxActivationDistance = 100000
    end

    while not Dealer1 do
        wait(0.1)
        game:GetService("Workspace").BlackMarket.Dealer.Dealer.ProximityPrompt.MaxActivationDistance = 16
    end
end
v20:Toggle("残血自动逃逸", "runaway", false, function(p30)
    paolu1 = p30

    if paolu1 then
        paolu2()
    end
end)

function paolu2()
    while paolu1 do
        wait(0.1)

        if game:GetService("Players").LocalPlayer.Character.Humanoid.Health <= 35 then
            local cFrame = CFrame.new(175.191, 13.937, -132.69)

            game:GetService("Players").LocalPlayer.Character.HumanoidRootPart.CFrame = cFrame
            wait(20)
        end
    end
end
v20:Toggle("最大视野", "fieldofvision", false, function(p31)
    Cam1 = p31

    if Cam1 then
        Cam2()
    end
end)

function Cam2()
    while Cam1 do
        wait(0.1)
        game:GetService("Players").LocalPlayer.CameraMaxZoomDistance = 10000
    end

    while not Cam1 do
        wait(0.1)
        game:GetService("Players").LocalPlayer.CameraMaxZoomDistance = 32
    end
end
v20:Button("显示聊天框", "show", function()
    ChatSee()
end)

function ChatSee()
    game:GetService("Players").LocalPlayer.PlayerGui.Chat.Frame.ChatChannelParentFrame.Visible = true
    game:GetService("Players").LocalPlayer.PlayerGui.Chat.Frame.ChatChannelParentFrame.Position = UDim2.new(0, 0, 0, 40)
end
v20:Button("移除障碍", "obstacle", function()
    game:GetService("Workspace").InviteSigns:Destroy()
    game:GetService("Workspace").Game.Props["Trash Bag"]:Destroy()
    game:GetService("Workspace").Game.Props.Dumpster:Destroy()
    game:GetService("Workspace").Game.Props["Traffic Cone"]:Destroy()
    game:GetService("Workspace").Game.Props["Wire Fence"]:Destroy()
    game:GetService("Workspace").Game.Props["Wood Crate"]:Destroy()
    game:GetService("Workspace").Game.Props.Hydrant:Destroy()
    game:GetService("Workspace").Game.Props["Street Light"]:Destroy()
    game:GetService("Workspace").Game.Props["Power Line Pole"]:Destroy()
    game:GetService("Workspace").Game.Props["Wood Fence"]:Destroy()
    game:GetService("Workspace").Game.Props.BusStop:Destroy()
    game:GetService("Workspace").Game.Props.Roadblock:Destroy()
    game:GetService("Workspace").Game.Props.Bollard:Destroy()
    game:GetService("Workspace").Game.Props.Light:Destroy()
    game:GetService("Workspace").Game.Props.Roadblock:Destroy()
    game:GetService("Workspace").Game.Props.Glass:Destroy()
    game:GetService("Workspace").Game.Props.Bench:Destroy()
    game:GetService("Workspace").Game.Props["Trash Bin"]:Destroy()
    game:GetService("Workspace").Game.Props.Bollard:Destroy()
    game:GetService("Workspace").Game.Props["Office Chair"]:Destroy()
    game:GetService("Workspace").Game.Props.Table:Destroy()
    game:GetService("Workspace").BankRobbery.BankWalls:Destroy()
    game:GetService("Workspace").BankRobbery.AlarmLightModel:Destroy()
    game:GetService("Workspace").BankRobbery.AlarmLights:Destroy()
end)
v20:Button("全枪无后坐力", "", function()
    local function v147()
        local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
        local _ = game:GetService("Players").LocalPlayer
        local inventory = require(ReplicatedStorage2.devv).load("v3item").inventory

        for _, v in pairs(inventory.items) do
            if v then
                v.recoilAdd = 0
                v.maxRecoil = 0
                v.recoilDiminishFactor = 0
                v.recoilFastDiminishFactor = 0
                v.baseSpread = 0
                v.baseAimSpread = 0
                v.spread = 0
                v.aimSpread = 0
            end
        end
    end

    v147()
    task.spawn(function()
        while true do
            pcall(v147)
            task.wait(30)
        end
    end)
end)
v20:Button("秒拿珠宝店", "jewellery", function()
    local HighYieldSpawns = game:GetService("Workspace").GemRobbery.JewelryCases.HighYieldSpawns

    for _, child in pairs(HighYieldSpawns:GetChildren()) do
        if child.ClassName == "Model" then
            local GetChildren = child.GetChildren

            for _, v in pairs(GetChildren(child)) do
                if v.ClassName == "Model" and v.Name ~= "Case" then
                    if v.Name == "Emerald" then
                        local Handle = v:FindFirstChild("Handle")

                        if Handle then
                            Handle = v.Handle:FindFirstChild("ProximityPrompt")
                        end

                        if Handle then
                            v.Handle.ProximityPrompt.HoldDuration = 0
                        end
                    elseif v.Name == "Sapphire" then
                        local Handle = v:FindFirstChild("Handle")

                        if Handle then
                            Handle = v.Handle:FindFirstChild("ProximityPrompt")
                        end

                        if Handle then
                            v.Handle.ProximityPrompt.HoldDuration = 0
                        end
                    elseif v.Name == "Amethyst" then
                        local Handle = v:FindFirstChild("Handle")

                        if Handle then
                            Handle = v.Handle:FindFirstChild("ProximityPrompt")
                        end

                        if Handle then
                            v.Handle.ProximityPrompt.HoldDuration = 0
                        end
                    elseif v.Name == "Topaz" then
                        local Handle = v:FindFirstChild("Handle")

                        if Handle then
                            Handle = v.Handle:FindFirstChild("ProximityPrompt")
                        end

                        if Handle then
                            v.Handle.ProximityPrompt.HoldDuration = 0
                        end
                    elseif v.Name == "Diamond" then
                        local Handle = v:FindFirstChild("Handle")

                        if Handle then
                            Handle = v.Handle:FindFirstChild("ProximityPrompt")
                        end

                        if Handle then
                            v.Handle.ProximityPrompt.HoldDuration = 0
                        end
                    elseif v.Name == "Gold Bar" then
                        local Handle = v:FindFirstChild("Handle")

                        if Handle then
                            Handle = v.Handle:FindFirstChild("ProximityPrompt")
                        end

                        if Handle then
                            v.Handle.ProximityPrompt.HoldDuration = 0
                        end
                    elseif v.Name == "Ruby" then
                        local Handle = v:FindFirstChild("Handle")

                        if Handle then
                            Handle = v.Handle:FindFirstChild("ProximityPrompt")
                        end

                        if Handle then
                            v.Handle.ProximityPrompt.HoldDuration = 0
                        end
                    else
                        local Box = v:FindFirstChild("Box")

                        if Box then
                            Box = v.Box:FindFirstChild("ProximityPrompt")
                        end

                        if Box then
                            v.Box.ProximityPrompt.HoldDuration = 0
                        end
                    end
                end
            end
        end
    end

    local LowYieldSpawns = game:GetService("Workspace").GemRobbery.JewelryCases.LowYieldSpawns

    for _, child in pairs(LowYieldSpawns:GetChildren()) do
        if child.ClassName == "Model" then
            local GetChildren = child.GetChildren

            for _, v in pairs(GetChildren(child)) do
                if v.ClassName == "Model" and v.Name ~= "Case" then
                    if v.Name == "Emerald" then
                        local Handle = v:FindFirstChild("Handle")

                        if Handle then
                            Handle = v.Handle:FindFirstChild("ProximityPrompt")
                        end

                        if Handle then
                            v.Handle.ProximityPrompt.HoldDuration = 0
                        end
                    elseif v.Name == "Sapphire" then
                        local Handle = v:FindFirstChild("Handle")

                        if Handle then
                            Handle = v.Handle:FindFirstChild("ProximityPrompt")
                        end

                        if Handle then
                            v.Handle.ProximityPrompt.HoldDuration = 0
                        end
                    elseif v.Name == "Amethyst" then
                        local Handle = v:FindFirstChild("Handle")

                        if Handle then
                            Handle = v.Handle:FindFirstChild("ProximityPrompt")
                        end

                        if Handle then
                            v.Handle.ProximityPrompt.HoldDuration = 0
                        end
                    elseif v.Name == "Topaz" then
                        local Handle = v:FindFirstChild("Handle")

                        if Handle then
                            Handle = v.Handle:FindFirstChild("ProximityPrompt")
                        end

                        if Handle then
                            v.Handle.ProximityPrompt.HoldDuration = 0
                        end
                    elseif v.Name == "Diamond" then
                        local Handle = v:FindFirstChild("Handle")

                        if Handle then
                            Handle = v.Handle:FindFirstChild("ProximityPrompt")
                        end

                        if Handle then
                            v.Handle.ProximityPrompt.HoldDuration = 0
                        end
                    elseif v.Name == "Gold Bar" then
                        local Handle = v:FindFirstChild("Handle")

                        if Handle then
                            Handle = v.Handle:FindFirstChild("ProximityPrompt")
                        end

                        if Handle then
                            v.Handle.ProximityPrompt.HoldDuration = 0
                        end
                    elseif v.Name == "Ruby" then
                        local Handle = v:FindFirstChild("Handle")

                        if Handle then
                            Handle = v.Handle:FindFirstChild("ProximityPrompt")
                        end

                        if Handle then
                            v.Handle.ProximityPrompt.HoldDuration = 0
                        end
                    else
                        local Box = v:FindFirstChild("Box")

                        if Box then
                            Box = v.Box:FindFirstChild("ProximityPrompt")
                        end

                        if Box then
                            v.Box.ProximityPrompt.HoldDuration = 0
                        end
                    end
                end
            end
        end
    end
end)
v20:Button("秒填弹药箱", "caisson", function()
    for _ = 1, 50 do
        local v177 = game:GetService("Workspace").Game.Local.droppables["Ammo Box"]

        v177.Handle.ProximityPrompt.HoldDuration = 0
        v177.Name = "ammoopen"
    end
end)
v20:Button("秒填弹药箱", "caisson", function()
    for _ = 1, 50 do
        local v179 = game:GetService("Workspace").Game.Local.droppables["Ammo Box"]

        v179.Handle.ProximityPrompt.HoldDuration = 0
        v179.Name = "ammoopen"
    end
end)

local v21 = v5:Tab("传送与甩飞玩家", "123097590035361")
local v22 = v21:section("传送与甩飞玩家", true)

t1.value19 = v22:Dropdown("选择玩家的名称", "Dropdown", t1.value1.dropdown, function(p32)
    t1.value1.playernamedied = p32
end)
v22:Button("刷新玩家名称", function()
    shuaxinlb(true)
    t1.value19:SetOptions(t1.value1.dropdown)
end)
v22:Button("传送到玩家旁边", function()
    local HumanoidRootPart = game.Players.LocalPlayer.Character.HumanoidRootPart
    local t1value1playernamedied = game.Players:FindFirstChild(t1.value1.playernamedied)
    local v183 = t1value1playernamedied

    if t1value1playernamedied then
        v183 = t1value1playernamedied.Character

        if v183 then
            v183 = t1value1playernamedied.Character.HumanoidRootPart
        end
    end

    if v183 then
        HumanoidRootPart.CFrame = t1value1playernamedied.Character.HumanoidRootPart.CFrame + Vector3.new(0, 3, 0)
        Notify("TY HUB", "已传送到玩家旁边", "rbxassetid://", 5)

        return
    end

    Notify("TY HUB", "无法传送 玩家已消失", "rbxassetid://", 5)
end)
v22:Toggle("锁定传送", "Loop", false, function(p33)
    if p33 then
        t1.value1.LoopTeleport = true
        Notify("TY HUB", "已开启循环传送", "rbxassetid://", 5)

        while t1.value1.LoopTeleport do
            local HumanoidRootPart = game.Players.LocalPlayer.Character.HumanoidRootPart
            local t1value1playernamedied = game.Players:FindFirstChild(t1.value1.playernamedied)
            local v187 = t1value1playernamedied

            if t1value1playernamedied then
                v187 = t1value1playernamedied.Character

                if v187 then
                    v187 = t1value1playernamedied.Character.HumanoidRootPart
                end
            end

            if v187 then
                HumanoidRootPart.CFrame = t1value1playernamedied.Character.HumanoidRootPart.CFrame + Vector3.new(0, 3, 0)
            end

            wait()
        end
    else
        t1.value1.LoopTeleport = false
        Notify("TY HUB", "已关闭循环传送", "rbxassetid://", 5)
    end
end)
v22:Button("把玩家传送过来", function()
    local HumanoidRootPart = game.Players.LocalPlayer.Character.HumanoidRootPart
    local t1value1playernamedied = game.Players:FindFirstChild(t1.value1.playernamedied)
    local v190 = t1value1playernamedied

    if t1value1playernamedied then
        v190 = t1value1playernamedied.Character

        if v190 then
            v190 = t1value1playernamedied.Character.HumanoidRootPart
        end
    end

    if v190 then
        t1value1playernamedied.Character.HumanoidRootPart.CFrame = HumanoidRootPart.CFrame + Vector3.new(0, 3, 0)
        Notify("TY HUB", "已将玩家传送过来", "rbxassetid://", 5)

        return
    end

    Notify("TY HUB", "无法传送 玩家已消失", "rbxassetid://", 5)
end)
v22:Toggle("循环传送玩家过来", "Loop", false, function(p34)
    if p34 then
        t1.value1.LoopTeleport = true
        Notify("TY HUB", "已开启循环传送玩家过来", "rbxassetid://", 5)

        while t1.value1.LoopTeleport do
            local HumanoidRootPart = game.Players.LocalPlayer.Character.HumanoidRootPart
            local t1value1playernamedied = game.Players:FindFirstChild(t1.value1.playernamedied)
            local v194 = t1value1playernamedied

            if t1value1playernamedied then
                v194 = t1value1playernamedied.Character

                if v194 then
                    v194 = t1value1playernamedied.Character.HumanoidRootPart
                end
            end

            if v194 then
                t1value1playernamedied.Character.HumanoidRootPart.CFrame = HumanoidRootPart.CFrame + Vector3.new(0, 3, 0)
            end

            wait()
        end
    else
        t1.value1.LoopTeleport = false
        Notify("TY HUB", "已关闭循环传送玩家过来", "rbxassetid://", 5)
    end
end)
v22:Toggle("查看玩家", "look player", false, function(p35)
    if p35 then
        game:GetService("Workspace").CurrentCamera.CameraSubject = game:GetService("Players"):FindFirstChild(t1.value1.playernamedied).Character.Humanoid
        Notify("TY HUB", "已开启查看玩家", "rbxassetid://", 5)

        return
    end

    local LocalPlayer = game.Players.LocalPlayer

    game:GetService("Workspace").CurrentCamera.CameraSubject = LocalPlayer.Character.Humanoid
    Notify("TY HUB", "已关闭查看玩家", "rbxassetid://", 5)
end)
v22:Button("甩飞一次", function()
    if t1.value1.playernamedied ~= nil and t1.value1.playernamedied ~= nil then
        local t8 = { t1.value1.playernamedied }
        local Players = game:GetService("Players")
        local LocalPlayer = Players.LocalPlayer
        local u200 = false
        local function v201(p36)
            local v569 = p36:lower()

            if v569 == "all" or v569 == "others" then
                u200 = true

                return
            end

            if v569 == "random" then
                local players = Players:GetPlayers()

                if table.find(players, LocalPlayer) then
                    table.remove(players, table.find(players, LocalPlayer))
                end

                return players[math.random(#players)]
            end

            local v571 = v569 ~= "random"

            if v571 then
                v571 = v569 ~= "all" and v569 ~= "others"
            end

            if v571 then
                local _next = next
                local v573, v574 = Players:GetPlayers()
                local v575

                repeat
                    repeat
                        v574, v575 = _next(v573, v574)

                        if not v574 then
                            return
                        end
                    until v575 ~= LocalPlayer

                    if v575.Name:lower():match("^" .. v569) then
                        return v575
                    end
                until v575.DisplayName:lower():match("^" .. v569)

                return v575
            end
        end
        local function v202(p37, p38, p39)
            game:GetService("StarterGui"):SetCore("SendNotification", {
				Title = p37,
				Text = p38,
				Duration = p39
			})
        end
        local function v203(p40)
            local Character = LocalPlayer.Character
            local v581 = Character
            if Character then
                v581 = Character:FindFirstChildOfClass("Humanoid")
            end
            local v582 = v581
            local v583 = v582
            if v582 then
                v583 = v582.RootPart
            end
            local v584 = v583
            local Character3 = p40.Character
            local Humanoid
            local RootPart
            local Head
            local Accessory
            local Handle
            if Character3:FindFirstChildOfClass("Humanoid") then
                Humanoid = Character3:FindFirstChildOfClass("Humanoid")
            end
            local v591 = Humanoid
            if v591 then
                v591 = Humanoid.RootPart
            end
            if v591 then
                RootPart = Humanoid.RootPart
            end
            if Character3:FindFirstChild("Head") then
                Head = Character3.Head
            end
            if Character3:FindFirstChildOfClass("Accessory") then
                Accessory = Character3:FindFirstChildOfClass("Accessory")
            end
            local _Accessoy = Accessoy
            if _Accessoy then
                _Accessoy = Accessory:FindFirstChild("Handle")
            end
            if _Accessoy then
                Handle = Accessory.Handle
            end
            local v593 = Character
            if v593 then
                v593 = v582 and v584
            end
            if v593 then
                if v584.Velocity.Magnitude < 50 then
                    getgenv().OldPos = v584.CFrame
                end

                local v594 = Humanoid

                if v594 then
                    v594 = Humanoid.Sit and not u200
                end

                if v594 then
                    return v202("玩家消失", "已停止", 5)
                end

                if Head then
                    workspace.CurrentCamera.CameraSubject = Head
                elseif not Head and Handle then
                    workspace.CurrentCamera.CameraSubject = Handle
                elseif Humanoid and RootPart then
                    workspace.CurrentCamera.CameraSubject = Humanoid
                end

                if not Character3:FindFirstChildWhichIsA("BasePart") then
                    return
                end

                local function v595(p41, p42, p43)
                    v584.CFrame = CFrame.new(p41.Position) * p42 * p43
                    Character:SetPrimaryPartCFrame(CFrame.new(p41.Position) * p42 * p43)
                    v584.Velocity = Vector3.new(90000000, 900000000, 90000000)
                    v584.RotVelocity = Vector3.new(900000000, 900000000, 900000000)
                end
                local function v596(p44)
                    local timestamp = tick()
                    local n3 = 0

                    if not (p44.Velocity.Magnitude > 500) and (p44.Parent == p40.Character and p40.Parent == Players) then
                        local Character4 = p40.Character

                        if Character3 ~= not Character4 and not Humanoid.Sit and not (v582.Health <= 0) then
                            if not (tick() > timestamp + 2) then
                            end
                        end
                    end

                    repeat
                        if not (v584 and Humanoid) then
                            return
                        end

                        if p44.Velocity.Magnitude < 50 then
                            n3 += 100
                            v595(p44, CFrame.new(0, 1.5, 0) + Humanoid.MoveDirection * p44.Velocity.Magnitude / 1.25, CFrame.Angles(math.rad(n3), 0, 0))
                            task.wait()
                            v595(p44, CFrame.new(0, -1.5, 0) + Humanoid.MoveDirection * p44.Velocity.Magnitude / 1.25, CFrame.Angles(math.rad(n3), 0, 0))
                            task.wait()
                            v595(p44, CFrame.new(2.25, 1.5, -2.25) + Humanoid.MoveDirection * p44.Velocity.Magnitude / 1.25, CFrame.Angles(math.rad(n3), 0, 0))
                            task.wait()
                            v595(p44, CFrame.new(-2.25, -1.5, 2.25) + Humanoid.MoveDirection * p44.Velocity.Magnitude / 1.25, CFrame.Angles(math.rad(n3), 0, 0))
                            task.wait()
                            v595(p44, CFrame.new(0, 1.5, 0) + Humanoid.MoveDirection, CFrame.Angles(math.rad(n3), 0, 0))
                            task.wait()
                            v595(p44, CFrame.new(0, -1.5, 0) + Humanoid.MoveDirection, CFrame.Angles(math.rad(n3), 0, 0))
                            task.wait()
                        else
                            v595(p44, CFrame.new(0, 1.5, Humanoid.WalkSpeed), CFrame.Angles(math.rad(90), 0, 0))
                            task.wait()
                            v595(p44, CFrame.new(0, -1.5, -Humanoid.WalkSpeed), CFrame.Angles(0, 0, 0))
                            task.wait()
                            v595(p44, CFrame.new(0, 1.5, Humanoid.WalkSpeed), CFrame.Angles(math.rad(90), 0, 0))
                            task.wait()
                            v595(p44, CFrame.new(0, 1.5, RootPart.Velocity.Magnitude / 1.25), CFrame.Angles(math.rad(90), 0, 0))
                            task.wait()
                            v595(p44, CFrame.new(0, -1.5, -RootPart.Velocity.Magnitude / 1.25), CFrame.Angles(0, 0, 0))
                            task.wait()
                            v595(p44, CFrame.new(0, 1.5, RootPart.Velocity.Magnitude / 1.25), CFrame.Angles(math.rad(90), 0, 0))
                            task.wait()
                            v595(p44, CFrame.new(0, -1.5, 0), CFrame.Angles(math.rad(90), 0, 0))
                            task.wait()
                            v595(p44, CFrame.new(0, -1.5, 0), CFrame.Angles(0, 0, 0))
                            task.wait()
                            v595(p44, CFrame.new(0, -1.5, 0), CFrame.Angles(math.rad(-90), 0, 0))
                            task.wait()
                            v595(p44, CFrame.new(0, -1.5, 0), CFrame.Angles(0, 0, 0))
                            task.wait()
                        end

                        local v771 = p44.Velocity.Magnitude > 500

                        if not v771 then
                            v771 = p44.Parent ~= p40.Character

                            if not v771 then
                                v771 = p40.Parent ~= Players

                                if not v771 then
                                    local Character5 = p40.Character

                                    v771 = Character3 == not Character5

                                    if not v771 then
                                        v771 = Humanoid.Sit

                                        if not v771 then
                                            v771 = v582.Health <= 0 or tick() > timestamp + 2
                                        end
                                    end
                                end
                            end
                        end
                    until v771
                end

                workspace.FallenPartsDestroyHeight = (0/0)

                local BodyVelocity = Instance.new("BodyVelocity")

                BodyVelocity.Name = "EpixVel"
                BodyVelocity.Parent = v584
                BodyVelocity.Velocity = Vector3.new(900000000, 900000000, 900000000)
                BodyVelocity.MaxForce = Vector3.new(1e999, 1e999, 1e999)
                v582:SetStateEnabled(Enum.HumanoidStateType.Seated, false)

                if RootPart and Head then
                    if (RootPart.CFrame.p - Head.CFrame.p).Magnitude > 5 then
                        v596(Head)
                    else
                        v596(RootPart)
                    end
                elseif RootPart and not Head then
                    v596(RootPart)
                elseif not RootPart and Head then
                    v596(Head)
                else
                    local v598 = not RootPart

                    if v598 then
                        v598 = not Head and (Accessory and Handle)
                    end

                    if not v598 then
                        return v202("已开/关", "叶脚本", 5)
                    end

                    v596(Handle)
                end

                BodyVelocity:Destroy()
                v582:SetStateEnabled(Enum.HumanoidStateType.Seated, true)
                workspace.CurrentCamera.CameraSubject = v582

                if not ((v584.Position - getgenv().OldPos.p).Magnitude < 25) then
                end

                repeat
                    v584.CFrame = getgenv().OldPos * CFrame.new(0, 0.5, 0)
                    Character:SetPrimaryPartCFrame(getgenv().OldPos * CFrame.new(0, 0.5, 0))
                    v582:ChangeState("GettingUp")
                    table.foreach(Character:GetChildren(), function(_, p46)
                        if p46:IsA("BasePart") then
                            local vector3 = Vector3.new()
                            local vector3_2 = Vector3.new()

                            p46.Velocity = vector3
                            p46.RotVelocity = vector3_2
                        end
                    end)
                    task.wait()
                until (v584.Position - getgenv().OldPos.p).Magnitude < 25

                workspace.FallenPartsDestroyHeight = getgenv().FPDH

                return
            end

            return v202("玩家消失", "已停止", 5)
        end
        if not t8[1] then
            return
        end
        local _next = next
        local v205
        while true do
            local v206

            v205, v206 = _next(t8, v205)

            if not v205 then
                break
            end

            v201(v206)
        end
        if u200 then
            local _next2 = next
            local v208, v209 = Players:GetPlayers()

            while true do
                local v210

                v209, v210 = _next2(v208, v209)

                if not v209 then
                    break
                end

                v203(v210)
            end
        end
        local _next3 = next
        local v212
        while true do
            local v213

            v212, v213 = _next3(t8, v212)

            if not v212 then
                break
            end

            if v201(v213) and LocalPlayer ~= v201(v213) then
                if v201(v213).UserId ~= 1414978355 then
                    local v214 = v201(v213)

                    if v214 then
                        v203(v214)
                    end
                else
                    v202("检测到玩家消失", "己停止", 5)
                end
            elseif not v201(v213) and not u200 then
                v202("未获取到玩家或工具", "已停止", 5)
            end
        end
    end
end)
v22:Toggle("循环甩飞", "Auto Fling", false, function(p47)
    if t1.value1.playernamedied ~= nil and t1.value1.playernamedied ~= nil then
        getgenv().autofling = p47
        spawn(function()
            while autofling do
                wait()
                pcall(function()
                    local t9 = {}
                    local t10 = {}
                    local t11 = { t1.value1.playernamedied }

                    t10.value1 = game:GetService("Players")
                    t10.value2 = t10.value1.LocalPlayer
                    t10.value3 = false

                    local function v780(p48)
                        local v815 = p48:lower()

                        if v815 == "all" or v815 == "others" then
                            t10.value3 = true

                            return
                        end

                        if v815 == "random" then
                            local players = t10.value1:GetPlayers()

                            if table.find(players, t10.value2) then
                                table.remove(players, table.find(players, t10.value2))
                            end

                            return players[math.random(#players)]
                        end

                        local v817 = v815 ~= "random"

                        if v817 then
                            v817 = v815 ~= "all" and v815 ~= "others"
                        end

                        if v817 then
                            local _next = next
                            local v819, v820 = t10.value1:GetPlayers()
                            local v821

                            repeat
                                repeat
                                    v820, v821 = _next(v819, v820)

                                    if not v820 then
                                        return
                                    end
                                until v821 ~= t10.value2

                                if v821.Name:lower():match("^" .. v815) then
                                    return v821
                                end
                            until v821.DisplayName:lower():match("^" .. v815)

                            return v821
                        end
                    end

                    function t10.value4(p49, p50, p51)
                        game:GetService("StarterGui"):SetCore("SendNotification", {
							Title = p49,
							Text = p50,
							Duration = p51
						})
                    end

                    local function v781(p52)
                        local Character = t10.value2.Character
                        local v827 = Character
                        if Character then
                            v827 = Character:FindFirstChildOfClass("Humanoid")
                        end
                        local v828 = v827
                        local v829 = v828
                        if v828 then
                            v829 = v828.RootPart
                        end
                        local v830 = v829
                        local Character6 = p52.Character
                        local Humanoid
                        local RootPart
                        local Head
                        local Accessory
                        local Handle
                        if Character6:FindFirstChildOfClass("Humanoid") then
                            Humanoid = Character6:FindFirstChildOfClass("Humanoid")
                        end
                        local v837 = Humanoid
                        if v837 then
                            v837 = Humanoid.RootPart
                        end
                        if v837 then
                            RootPart = Humanoid.RootPart
                        end
                        if Character6:FindFirstChild("Head") then
                            Head = Character6.Head
                        end
                        if Character6:FindFirstChildOfClass("Accessory") then
                            Accessory = Character6:FindFirstChildOfClass("Accessory")
                        end
                        local _Accessoy = Accessoy
                        if _Accessoy then
                            _Accessoy = Accessory:FindFirstChild("Handle")
                        end
                        if _Accessoy then
                            Handle = Accessory.Handle
                        end
                        local v839 = Character
                        if v839 then
                            v839 = v828 and v830
                        end
                        if v839 then
                            if v830.Velocity.Magnitude < 50 then
                                getgenv().OldPos = v830.CFrame
                            end

                            local v840 = Humanoid

                            if v840 then
                                v840 = Humanoid.Sit and not t10.value3
                            end

                            if v840 then
                                return t10.value4("错误", "叶脚本", 5)
                            end

                            if Head then
                                workspace.CurrentCamera.CameraSubject = Head
                            elseif not Head and Handle then
                                workspace.CurrentCamera.CameraSubject = Handle
                            elseif Humanoid and RootPart then
                                workspace.CurrentCamera.CameraSubject = Humanoid
                            end

                            if not Character6:FindFirstChildWhichIsA("BasePart") then
                                return
                            end

                            local function v841(p53, p54, p55)
                                v830.CFrame = CFrame.new(p53.Position) * p54 * p55
                                Character:SetPrimaryPartCFrame(CFrame.new(p53.Position) * p54 * p55)
                                v830.Velocity = Vector3.new(90000000, 900000000, 90000000)
                                v830.RotVelocity = Vector3.new(900000000, 900000000, 900000000)
                            end
                            local function v842(p56)
                                local timestamp = tick()
                                local n4 = 0

                                if not (p56.Velocity.Magnitude > 500) and (p56.Parent == p52.Character and p52.Parent == t10.value1) then
                                    local Character7 = p52.Character

                                    if Character6 ~= not Character7 and not Humanoid.Sit and not (v828.Health <= 0) then
                                        if not (tick() > timestamp + 2) then
                                        end
                                    end
                                end

                                repeat
                                    if not (v830 and Humanoid) then
                                        return
                                    end

                                    if p56.Velocity.Magnitude < 50 then
                                        n4 += 100
                                        v841(p56, CFrame.new(0, 1.5, 0) + Humanoid.MoveDirection * p56.Velocity.Magnitude / 1.25, CFrame.Angles(math.rad(n4), 0, 0))
                                        task.wait()
                                        v841(p56, CFrame.new(0, -1.5, 0) + Humanoid.MoveDirection * p56.Velocity.Magnitude / 1.25, CFrame.Angles(math.rad(n4), 0, 0))
                                        task.wait()
                                        v841(p56, CFrame.new(2.25, 1.5, -2.25) + Humanoid.MoveDirection * p56.Velocity.Magnitude / 1.25, CFrame.Angles(math.rad(n4), 0, 0))
                                        task.wait()
                                        v841(p56, CFrame.new(-2.25, -1.5, 2.25) + Humanoid.MoveDirection * p56.Velocity.Magnitude / 1.25, CFrame.Angles(math.rad(n4), 0, 0))
                                        task.wait()
                                        v841(p56, CFrame.new(0, 1.5, 0) + Humanoid.MoveDirection, CFrame.Angles(math.rad(n4), 0, 0))
                                        task.wait()
                                        v841(p56, CFrame.new(0, -1.5, 0) + Humanoid.MoveDirection, CFrame.Angles(math.rad(n4), 0, 0))
                                        task.wait()
                                    else
                                        v841(p56, CFrame.new(0, 1.5, Humanoid.WalkSpeed), CFrame.Angles(math.rad(90), 0, 0))
                                        task.wait()
                                        v841(p56, CFrame.new(0, -1.5, -Humanoid.WalkSpeed), CFrame.Angles(0, 0, 0))
                                        task.wait()
                                        v841(p56, CFrame.new(0, 1.5, Humanoid.WalkSpeed), CFrame.Angles(math.rad(90), 0, 0))
                                        task.wait()
                                        v841(p56, CFrame.new(0, 1.5, RootPart.Velocity.Magnitude / 1.25), CFrame.Angles(math.rad(90), 0, 0))
                                        task.wait()
                                        v841(p56, CFrame.new(0, -1.5, -RootPart.Velocity.Magnitude / 1.25), CFrame.Angles(0, 0, 0))
                                        task.wait()
                                        v841(p56, CFrame.new(0, 1.5, RootPart.Velocity.Magnitude / 1.25), CFrame.Angles(math.rad(90), 0, 0))
                                        task.wait()
                                        v841(p56, CFrame.new(0, -1.5, 0), CFrame.Angles(math.rad(90), 0, 0))
                                        task.wait()
                                        v841(p56, CFrame.new(0, -1.5, 0), CFrame.Angles(0, 0, 0))
                                        task.wait()
                                        v841(p56, CFrame.new(0, -1.5, 0), CFrame.Angles(math.rad(-90), 0, 0))
                                        task.wait()
                                        v841(p56, CFrame.new(0, -1.5, 0), CFrame.Angles(0, 0, 0))
                                        task.wait()
                                    end

                                    local v852 = p56.Velocity.Magnitude > 500

                                    if not v852 then
                                        v852 = p56.Parent ~= p52.Character

                                        if not v852 then
                                            v852 = p52.Parent ~= t10.value1

                                            if not v852 then
                                                local Character8 = p52.Character

                                                v852 = Character6 == not Character8

                                                if not v852 then
                                                    v852 = Humanoid.Sit

                                                    if not v852 then
                                                        v852 = v828.Health <= 0 or tick() > timestamp + 2
                                                    end
                                                end
                                            end
                                        end
                                    end
                                until v852
                            end

                            workspace.FallenPartsDestroyHeight = (0/0)

                            local BodyVelocity = Instance.new("BodyVelocity")

                            BodyVelocity.Name = "EpixVel"
                            BodyVelocity.Parent = v830
                            BodyVelocity.Velocity = Vector3.new(900000000, 900000000, 900000000)
                            BodyVelocity.MaxForce = Vector3.new(1e999, 1e999, 1e999)
                            v828:SetStateEnabled(Enum.HumanoidStateType.Seated, false)

                            if RootPart and Head then
                                if (RootPart.CFrame.p - Head.CFrame.p).Magnitude > 5 then
                                    v842(Head)
                                else
                                    v842(RootPart)
                                end
                            elseif RootPart and not Head then
                                v842(RootPart)
                            elseif not RootPart and Head then
                                v842(Head)
                            else
                                local v844 = not RootPart

                                if v844 then
                                    v844 = not Head and (Accessory and Handle)
                                end

                                if not v844 then
                                    return t10.value4("已开/关", "叶脚本", 5)
                                end

                                v842(Handle)
                            end

                            BodyVelocity:Destroy()
                            v828:SetStateEnabled(Enum.HumanoidStateType.Seated, true)
                            workspace.CurrentCamera.CameraSubject = v828

                            if not ((v830.Position - getgenv().OldPos.p).Magnitude < 25) then
                            end

                            repeat
                                v830.CFrame = getgenv().OldPos * CFrame.new(0, 0.5, 0)
                                Character:SetPrimaryPartCFrame(getgenv().OldPos * CFrame.new(0, 0.5, 0))
                                v828:ChangeState("GettingUp")
                                table.foreach(Character:GetChildren(), function(_, p58)
                                    if p58:IsA("BasePart") then
                                        local vector3 = Vector3.new()
                                        local vector3_3 = Vector3.new()

                                        p58.Velocity = vector3
                                        p58.RotVelocity = vector3_3
                                    end
                                end)
                                task.wait()
                            until (v830.Position - getgenv().OldPos.p).Magnitude < 25

                            workspace.FallenPartsDestroyHeight = getgenv().FPDH

                            return
                        end

                        return t10.value4("玩家消失", "已停止", 5)
                    end

                    if t11[1] then
                        t9.value1 = t11
                        t9.value2 = next
                        t9.value3 = nil

                        while true do
                            local v782, v783 = t9.value2(t9.value1, t9.value3)

                            t9.value3 = v782
                            t9.value4 = v783

                            if not t9.value3 then
                                break
                            end

                            v780(t9.value4)
                        end

                        if t10.value3 then
                            t9.value2 = next

                            local v784, v785 = t10.value1:GetPlayers()

                            t9.value3 = v784
                            t9.value6 = v785

                            while true do
                                local v786, v787 = t9.value2(t9.value3, t9.value6)

                                t9.value6 = v786
                                t9.value4 = v787

                                if not t9.value6 then
                                    break
                                end

                                v781(t9.value4)
                            end
                        end

                        t9.value3 = t11
                        t9.value2 = next
                        t9.value1 = nil

                        while true do
                            local v788, v789 = t9.value2(t9.value3, t9.value1)

                            t9.value1 = v788
                            t9.value4 = v789

                            if not t9.value1 then
                                break
                            end

                            t9.value5 = v780(t9.value4) and v780(t9.value4) ~= t10.value2

                            if t9.value5 then
                                t9.value7 = v780(t9.value4)

                                if t9.value7.UserId ~= 1414978355 then
                                    t9.value5 = v780(t9.value4)

                                    if t9.value5 then
                                        v781(t9.value5)
                                    end
                                else
                                    t10.value4("检测到玩家消失", "已停止", 5)
                                end
                            else
                                t9.value5 = not v780(t9.value4) and not t10.value3

                                if t9.value5 then
                                    t10.value4("未获取到玩家或工具", "已停止", 5)
                                end
                            end
                        end

                        return
                    end
                end)
            end
        end)
    end
end)
v22:Button("甩飞所有人", function()
    loadstring(game:HttpGet("https://pastebin.com/raw/zqyDSUWX"))()
end)
v22:Toggle("开启指定自瞄目标", "TD", false, function(p59)
    if p59 then
        _G.TD = true
        task.spawn(function()
            while _G.TD == true do
                local CurrentCamera = workspace.CurrentCamera
                local t1value1playernamedied = game.Players:FindFirstChild(t1.value1.playernamedied)

                if t1value1playernamedied then
                    local Character = t1value1playernamedied.Character

                    if Character then
                        Character = t1value1playernamedied.Character.HumanoidRootPart
                    end

                    t1value1playernamedied = Character
                end

                if t1value1playernamedied and CurrentCamera then
                    local unit = (t1value1playernamedied.Position - CurrentCamera.CFrame.Position).unit

                    CurrentCamera.CFrame = CFrame.new(CurrentCamera.CFrame.Position, CurrentCamera.CFrame.Position + unit)
                    wait()
                else
                    _G.TD = false
                end
            end
        end)

        return
    end

    _G.TD = false
end)

local v23 = v21:section("传送玩家前后方", true)

t1.value20 = game:GetService("Players")
t1.value21 = {}
t1.value22 = ""
t1.value23 = nil
t1.value24 = 3
t1.value25 = 4
function t1.value26()
    table.clear(t1.value21)
    for v219, v220 in ipairs(t1.value20:GetPlayers()) do

        table.insert(t1.value21, v220.Name)
    end
    if #t1.value21 == 0 then
        table.insert(t1.value21, "无在线玩家")
    end
end
t1.value26()
t1.value27 = v23:Dropdown("选择玩家", "Dropdown", t1.value21, function(p60)
    t1.value22 = p60
end)
v23:Button("刷新玩家名称", function()
    t1.value26()
    t1.value27:SetOptions(t1.value21)
end)
t1.value20.ChildRemoved:Connect(function(child)
    for k, v in pairs(t1.value21) do
        if v == child.Name then
            table.remove(t1.value21, k)

            break
        end
    end

    pcall(function()
        t1.value27:SetOptions(t1.value21)
    end)
end)
v23:Slider("传送至玩家前方距离", "Slider", t1.value24, 3, 25, false, function(p61)
    t1.value24 = p61
end)
v23:Toggle("循环传送至玩家前方", "Toggle", false, function(p62)
    if p62 then
        local LocalPlayer = t1.value20.LocalPlayer
        local t1value22 = t1.value20:FindFirstChild(t1.value22)
        local v229 = LocalPlayer

        if v229 then
            v229 = t1value22

            if v229 then
                v229 = LocalPlayer.Character

                if v229 then
                    v229 = t1value22.Character
                end
            end
        end

        if v229 then
            local function v230()
                local HumanoidRootPart = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                local HumanoidRootPart2 = t1value22.Character:FindFirstChild("HumanoidRootPart")

                if HumanoidRootPart and HumanoidRootPart2 then
                    local v605 = HumanoidRootPart2.CFrame * CFrame.new(0, 0, -t1.value24)

                    HumanoidRootPart.CFrame = CFrame.new(v605.Position, HumanoidRootPart2.Position)
                end
            end

            local RunService2 = game:GetService("RunService")
            local n5 = 0

            t1.value23 = RunService2.Heartbeat:Connect(function(dt)
                n5 += dt

                if n5 >= 0.01 then
                    v230()
                end
            end)

            return
        end

        Notify("TY HUB", "玩家或角色不存在，无法启动循环传送", "rbxassetid://", 5)

        return
    end

    if t1.value23 then
        t1.value23:Disconnect()
        t1.value23 = nil
    end

    Notify("提示", "已停止循环传送至玩家前方", "rbxassetid://", 5)
end)
v23:Slider("循环传送至玩家头顶高度", "Slider", t1.value25, 4, 25, false, function(p63)
    t1.value25 = p63
end)
v23:Toggle("循环传送至玩家头顶", "Toggle", false, function(p64)
    if p64 then
        local LocalPlayer = t1.value20.LocalPlayer
        local t1value22 = t1.value20:FindFirstChild(t1.value22)
        local v237 = LocalPlayer

        if v237 then
            v237 = t1value22

            if v237 then
                v237 = LocalPlayer.Character

                if v237 then
                    v237 = t1value22.Character
                end
            end
        end

        if v237 then
            local function v238()
                local HumanoidRootPart = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                local HumanoidRootPart3 = t1value22.Character:FindFirstChild("HumanoidRootPart")

                if HumanoidRootPart and HumanoidRootPart3 then
                    HumanoidRootPart.CFrame = HumanoidRootPart3.CFrame * CFrame.new(0, t1.value25, 0)
                end
            end

            local RunService3 = game:GetService("RunService")
            local n6 = 0

            t1.value23 = RunService3.Heartbeat:Connect(function(dt)
                n6 += dt

                if n6 >= 0.01 then
                    v238()
                end
            end)

            return
        end

        Notify("TY HUB", "玩家或角色不存在，无法启动循环传送", "rbxassetid://", 5)

        return
    end

    if t1.value23 then
        t1.value23:Disconnect()
        t1.value23 = nil
    end

    Notify("提示", "已停止循环传送至玩家头顶", "rbxassetid://", 5)
end)
v23:Slider("循环传送至玩家后面的距离", "Slider", 4, 4, 30, false, function(p65)
    t1.value24 = p65
end)
v23:Toggle("循环传送至玩家后面", "Toggle", false, function(p66)
    if p66 then
        local LocalPlayer = t1.value20.LocalPlayer
        local t1value22 = t1.value20:FindFirstChild(t1.value22)
        local v245 = LocalPlayer

        if v245 then
            v245 = t1value22

            if v245 then
                v245 = LocalPlayer.Character

                if v245 then
                    v245 = t1value22.Character
                end
            end
        end

        if v245 then
            local function v246()
                local HumanoidRootPart = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                local HumanoidRootPart4 = t1value22.Character:FindFirstChild("HumanoidRootPart")

                if HumanoidRootPart and HumanoidRootPart4 then
                    local v612 = HumanoidRootPart4.CFrame * CFrame.new(0, 0, t1.value24)

                    HumanoidRootPart.CFrame = CFrame.new(v612.Position, HumanoidRootPart4.Position - HumanoidRootPart4.CFrame.LookVector)
                end
            end

            local RunService4 = game:GetService("RunService")
            local n7 = 0

            t1.value23 = RunService4.Heartbeat:Connect(function(dt)
                n7 += dt

                if n7 >= 0.01 then
                    v246()
                end
            end)

            return
        end

        Notify("TY HUB", "玩家或角色不存在，无法启动循环传送", "rbxassetid://", 5)

        return
    end

    if t1.value23 then
        t1.value23:Disconnect()
    end

    Notify("提示", "已停止循环传送至玩家后面", "rbxassetid://", 5)
end)

local v24 = v5:Tab("自瞄", "6035145364")
local v25 = v24:section("圈圈自瞄", true)
local color3 = Color3.fromRGB(255, 255, 255)

t1.value28 = {
	fovsize = 20,
	fovlookAt = false,
	fovcolor = color3,
	fovthickness = 2,
	Visible = false,
	distance = 40,
	ViewportSize = 2,
	Transparency = 1,
	Position = "Head"
}
local function v27(p67, p68, p69, p70)
    local RunService5 = game:GetService("RunService")
    local UserInputService = game:GetService("UserInputService")
    local Players = game:GetService("Players")
    local CurrentCamera = game.Workspace.CurrentCamera

    if FOVring then
        FOVring:Remove()
    end

    FOVring = Drawing.new("Circle")
    FOVring.Visible = true
    FOVring.Thickness = p69
    FOVring.Color = p68
    FOVring.Filled = false
    FOVring.Radius = p67
    FOVring.Position = CurrentCamera.ViewportSize / 2
    FOVring.Transparency = p70

    local function v257()
        local ViewportSize = CurrentCamera.ViewportSize

        FOVring.Position = ViewportSize / 2
    end

    UserInputService.InputBegan:Connect(function(input)
        if input.KeyCode == Enum.KeyCode.Delete then
            RunService5:UnbindFromRenderStep("FOVUpdate")
            FOVring:Remove()
        end
    end)

    local function v258(p71)
        local unit = (p71 - CurrentCamera.CFrame.Position).unit

        CurrentCamera.CFrame = CFrame.new(CurrentCamera.CFrame.Position, CurrentCamera.CFrame.Position + unit)
    end
    local function v259(p72)
        local Character = p72.Character

        if Character then
            Character = p72.Character:FindFirstChild("Humanoid")

            if Character then
                Character = p72.Character.Humanoid.Health > 0
            end
        end

        return Character
    end
    local function v260(p73)
        local v621
        local huge = math.huge
        local v623 = CurrentCamera.ViewportSize / 2
        local distance = t1.value28.distance
        for _, player in ipairs(Players:GetPlayers()) do
            local v627 = not t1.value28.aliveCheck or v259(player)

            if v627 then
                v627 = player ~= Players.LocalPlayer
            end

            if v627 then
                local v628 = player.Character and player.Character:FindFirstChild(p73)

                if v628 then
                    local v629, v630 = CurrentCamera:WorldToViewportPoint(v628.Position)

                    if v629 and v630 then
                        local Magnitude = (Vector2.new(v629.x, v629.y) - v623).Magnitude
                        local v632 = Magnitude < huge

                        if v632 then
                            v632 = Magnitude <= t1.value28.fovsize and Magnitude <= distance
                        end

                        if v632 then
                            local v633 = not t1.value28.teamCheck

                            if not v633 then
                                v633 = t1.value28.teamCheck and isSameTeam(player)
                            end

                            if v633 then
                                local v634 = not t1.value28.wallCheck

                                if not v634 then
                                    v634 = t1.value28.wallCheck and isNearWall(player, distance)
                                end

                                if v634 then
                                    v621 = player
                                    huge = Magnitude
                                end
                            end
                        end
                    end
                end
            end
        end

        return v621
    end

    RunService5.RenderStepped:Connect(function()
        v257()

        if t1.value28.fovlookAt then
            local v635 = v260(t1.value28.Position)
            local v636 = v635

            if v635 then
                v636 = v635.Character:FindFirstChild(t1.value28.Position)
            end

            if v636 then
                local Position = v635.Character[t1.value28.Position].Position

                if not t1.value28.teamCheck or not isSameTeam(v635) then
                    local v638 = not t1.value28.wallCheck

                    if not v638 then
                        v638 = not isNearWall(v635, t1.value28.distance)
                    end

                    if v638 then
                        v258(Position)
                    end
                end
            end
        end
    end)
end
function t1.value29()
    if FOVring then
        game:GetService("RunService"):UnbindFromRenderStep("FOVUpdate")
        FOVring:Remove()
        FOVring = nil
    end
end
function t1.value30()
    if FOVring then
        FOVring.Thickness = t1.value28.fovthickness
        FOVring.Radius = t1.value28.fovsize
        FOVring.Color = t1.value28.fovcolor
        FOVring.Transparency = t1.value28.Transparency / 10
    end
end
local color3_7 = Color3.fromRGB(255, 0, 0)
local color3_8 = Color3.fromRGB(0, 0, 255)
local color3_9 = Color3.fromRGB(255, 255, 0)
local color3_10 = Color3.fromRGB(0, 255, 0)
local color3_11 = Color3.fromRGB(0, 255, 255)
local color3_12 = Color3.fromRGB(255, 165, 0)
local color3_13 = Color3.fromRGB(128, 0, 128)
local color3_14 = Color3.fromRGB(255, 255, 255)
local color3_15 = Color3.fromRGB(0, 0, 0)

t1.value31 = {
	["红色"] = color3_7,
	["蓝色"] = color3_8,
	["黄色"] = color3_9,
	["绿色"] = color3_10,
	["青色"] = color3_11,
	["橙色"] = color3_12,
	["紫色"] = color3_13,
	["白色"] = color3_14,
	["黑色"] = color3_15
}
v25:Toggle("显示圈圈自瞄", "open/close", false, function(p74)
    if p74 then
        v27(t1.value28.fovsize, t1.value28.fovcolor, t1.value28.fovthickness, t1.value28.Transparency)

        return
    end

    t1.value29()
end)
v25:Toggle("启动/关闭圈圈自瞄", "open/close", false, function(p75)
    t1.value28.fovlookAt = p75
end)
v25:Slider("圈圈自瞄厚度", "thickness", 2, 0, 10, false, function(p76)
    t1.value28.fovthickness = p76
    t1.value30()
end)
v25:Slider("圈圈自瞄大小", "Size", 20, 0, 100, false, function(p77)
    t1.value28.fovsize = p77
    t1.value30()
end)
v25:Slider("圈圈自瞄透明度", "Transparency", 1, 0, 10, false, function(p78)
    t1.value28.Transparency = p78
    t1.value30()
end)
v25:Slider("圈圈自瞄距离", "distance", 40, 10, 500, false, function(p79)
    t1.value28.distance = p79
end)
v25:Dropdown("圈圈自瞄颜色", "Dropdown", {
	"红色",
	"蓝色",
	"黄色",
	"绿色",
	"青色",
	"橙色",
	"紫色",
	"白色",
	"黑色"
}, function(p80)
    t1.value28.fovcolor = t1.value31[p80]
    t1.value30()
end)
v25:Dropdown("选择部位", "Dropdown", {
	"Head",
	"HumanoidRootPart",
	"Torso",
	"Left Arm",
	"Right Arm",
	"Left Leg",
	"Right Leg",
	"LeftHand",
	"RightHand",
	"LeftLowerArm",
	"RightLowerArm",
	"LeftUpperArm",
	"RightUpperArm",
	"LeftFoot",
	"LeftLowerLeg",
	"UpperTorso",
	"LeftUpperLeg",
	"RightFoot",
	"RightLowerLeg",
	"LowerTorso",
	"RightUpperLeg"
}, function(p81)
    t1.value28.Position = p81
    t1.value30()
end)
v25:Toggle("队伍检测", "Enable/Disable Team Check", false, function(p82)
    t1.value28.teamCheck = p82
end)
v25:Toggle("活体检测", "Alive Check", false, function(p83)
    t1.value28.aliveCheck = p83
end)
v25:Toggle("墙壁检测", "Enable/Disable Wall Check", false, function(p84)
    t1.value28.wallCheck = p84
end)

local v37 = v24:section("新自瞄", true)

t1.value32 = false
t1.value33 = false
t1.value34 = false
t1.value35 = 50
t1.value36 = game:GetService("Players").LocalPlayer
t1.value37 = game:GetService("RunService")
t1.value38 = game:GetService("Players")
t1.value39 = workspace.CurrentCamera
t1.value40 = Drawing.new("Circle")
t1.value40.Visible = false
t1.value40.Thickness = 2
t1.value40.Color = Color3.fromRGB(255, 0, 0)
t1.value40.Filled = false
t1.value40.Radius = t1.value35
t1.value40.Position = Vector2.new(t1.value39.ViewportSize.X / 2, t1.value39.ViewportSize.Y / 2)
t1.value41 = nil
t1.value41 = "Head"
function t1.value42()
    t1.value40.Position = Vector2.new(t1.value39.ViewportSize.X / 2, t1.value39.ViewportSize.Y / 2)
end
function t1.value43()
    t1.value40.Visible = false
end
function t1.value44(p85)
    local Unit = (p85 - t1.value39.CFrame.Position).Unit
    local cFrame = CFrame.new(t1.value39.CFrame.Position, t1.value39.CFrame.Position + Unit)

    t1.value39.CFrame = cFrame
end
function t1.value45()
    local v275
    local huge = math.huge
    local v277
    local huge2 = math.huge
    local vector2 = Vector2.new(t1.value39.ViewportSize.X / 2, t1.value39.ViewportSize.Y / 2)
    for _, player in ipairs(t1.value38:GetPlayers()) do
        if player ~= t1.value36 then
            local Character = player.Character
            local v283 = Character

            if Character then
                v283 = Character:FindFirstChild(t1.value41)
            end

            if v283 then
                local v284 = Character[t1.value41]
                local v285, v286 = t1.value39:WorldToViewportPoint(v284.Position)
                local Magnitude = (Vector2.new(v285.x, v285.y) - vector2).Magnitude
                local v288 = Magnitude < huge

                if v288 then
                    v288 = v286 and Magnitude < t1.value35
                end

                if v288 then
                    huge = Magnitude
                    v275 = player
                end

                local Humanoid = Character:FindFirstChildOfClass("Humanoid")

                if Humanoid and Humanoid.Health > 0 and huge2 > Humanoid.Health then
                    huge2 = Humanoid.Health
                    v277 = player
                end
            end
        end
    end
    if t1.value34 and v277 then
        return v277
    end

    return v275
end
function t1.value46(p86, p87)
    local Character = p86.Character
    local v293 = not Character

    if not v293 then
        v293 = not Character:FindFirstChild(t1.value41)
    end

    if v293 then
        return
    end

    local v294 = Character[t1.value41]
    local Velocity = v294.Velocity

    return v294.Position + Velocity * p87 * 1.2
end
function t1.value47(p88)
    if p88 then
        t1.value32 = true
        t1.value40.Visible = true
        t1.value41 = "Head"
        t1.value40.Connection = t1.value37.RenderStepped:Connect(function(dt)
            t1.value42()

            local v640 = t1.value45()
            local v641 = v640

            if v640 then
                v641 = v640.Character and v640.Character:FindFirstChild(t1.value41)
            end

            if v641 then
                local Position = v640.Character[t1.value41].Position

                if t1.value33 then
                    Position = t1.value46(v640, dt)
                end

                t1.value44(Position)
            end
        end)

        return
    end

    t1.value32 = false
    t1.value40.Visible = false

    if t1.value40.Connection then
        t1.value40.Connection:Disconnect()
        t1.value40.Connection = nil
    end

    t1.value39.CFrame = workspace.CurrentCamera.CFrame
end
function t1.value48(p89)
    t1.value33 = p89
end
function t1.value49(p90)
    t1.value34 = p90
end
v37:Toggle("自瞄 (开/关)", "开关", false, function(p91)
    t1.value47(p91)
end)
v37:Toggle("预判自瞄 (开/关)", "开关", false, function(p92)
    t1.value48(p92)
end)
v37:Toggle("优先瞄准血量低的玩家 (开/关)", "开关", false, function(p93)
    t1.value49(p93)
end)
v37:Slider("自瞄圈大小", "拉条", t1.value35, 1, 600, false, function(p94)
    t1.value35 = p94

    if t1.value32 then
        t1.value40.Radius = t1.value35

        return
    end

    t1.value43()
end)
v37:Slider("自瞄圈厚度", "拉条", t1.value40.Thickness, 1, 10, false, function(p95)
    if t1.value32 then
        t1.value40.Thickness = p95

        return
    end

    t1.value43()
end)
v37:Dropdown("自瞄玩家身体部位", "Dropdown", {
	"头",
	"胸",
	"左手",
	"右手",
	"左腿",
	"右腿"
}, function(p96)
    if t1.value32 then
        local _ = ({
			["头"] = "Head",
			["胸"] = "UpperTorso",
			["左手"] = "LeftHand",
			["右手"] = "RightHand",
			["左腿"] = "LeftFoot",
			["右腿"] = "RightFoot"
		})[p96]
    end
end)
v37:Dropdown("自瞄圈颜色", "Dropdown", {
	"红色",
	"黄色",
	"绿色",
	"蓝色",
	"紫色",
	"橙色",
	"黑色"
}, function(p97)
    if t1.value32 then
        local color3_16 = Color3.fromRGB(255, 0, 0)
        local color3_17 = Color3.fromRGB(255, 255, 0)
        local color3_18 = Color3.fromRGB(0, 255, 0)
        local color3_19 = Color3.fromRGB(0, 0, 255)
        local color3_20 = Color3.fromRGB(128, 0, 128)
        local color3_21 = Color3.fromRGB(255, 165, 0)
        local color3_22 = Color3.fromRGB(0, 0, 0)
        local t12 = {
			["红色"] = color3_16,
			["黄色"] = color3_17,
			["绿色"] = color3_18,
			["蓝色"] = color3_19,
			["紫色"] = color3_20,
			["橙色"] = color3_21,
			["黑色"] = color3_22
		}

        t1.value40.Color = t12[p97]

        return
    end

    t1.value43()
end)

local v38 = v5:Tab("自动功能", "18930406865"):section("自动功能", true)

v38:Toggle("自动全图ATM", "", false, function(p98)
    autoATM = p98

    if autoATM then
        repeat
            local g316 = false

            while true do
                local _autoATM = autoATM

                if _autoATM then
                    _autoATM = task.wait()
                end

                if not _autoATM then
                    break
                end

                local ATMs = workspace:FindFirstChild("ATMs")
                local LocalPlayer = game:GetService("Players").LocalPlayer

                if ATMs and LocalPlayer.Character then
                    for _, child in ipairs(ATMs:GetChildren()) do
                        if child:IsA("Model") and child:GetAttribute("health") ~= 0 then
                            for _, child3 in ipairs(child:GetChildren()) do
                                if child3.Name == "Main" and child3:IsA("BasePart") then
                                    LocalPlayer.Character.HumanoidRootPart.CFrame = child3.CFrame
                                    wait(0.1)
                                    child:SetAttribute("health", 0)
                                    g316 = true
                                end

                                if g316 then
                                    break
                                end
                            end

                            if not g316 then
                                break
                            end
                        end

                        if g316 then
                            break
                        end
                    end
                end

                if g316 then
                    break
                end
            end
        until not g316
    end
end)
v38:Toggle("自动抢银行", "bank", false, function(p99)
    AutoBank1 = p99

    if AutoBank1 then
        AutoBank2()
    end
end)

function AutoBank2()
    while AutoBank1 do
        wait()

        local VaultDoor = game:GetService("Workspace").BankRobbery.VaultDoor
        local BankCash = game:GetService("Workspace").BankRobbery.BankCash
        local HumanoidRootPart = game:GetService("Players").LocalPlayer.Character.HumanoidRootPart

        if VaultDoor.Door.Attachment.ProximityPrompt.Enabled == true then
            VaultDoor.Door.Attachment.ProximityPrompt.HoldDuration = 0
            VaultDoor.Door.Attachment.ProximityPrompt.MaxActivationDistance = 16
            HumanoidRootPart.CFrame = CFrame.new(1071.9558105469, 9, -343.80816650391)
            wait(1)
            VaultDoor.Door.Attachment.ProximityPrompt:InputHoldBegin()
            VaultDoor.Door.Attachment.ProximityPrompt:InputHoldEnd()
            VaultDoor.Door.Attachment.ProximityPrompt.Enabled = false
        end

        if BankCash.Cash.Bundle then
            HumanoidRootPart.CFrame = CFrame.new(1055.8728027344, 10, -344.69445800781)
            BankCash.Main.Attachment.ProximityPrompt.MaxActivationDistance = 16

            if BankCash.Cash.Bundle then
                BankCash.Main.Attachment.ProximityPrompt:InputHoldBegin()
                wait(45)
                BankCash.Main.Attachment.ProximityPrompt:InputHoldEnd()
                HumanoidRootPart.CFrame = CFrame.new(240.52850341797, -120, -620)
            end
        end

        if not BankCash.Cash.Bundle then
            HumanoidRootPart.CFrame = CFrame.new(240.52850341797, -120, -620)
        end
    end
end
v38:Toggle("自动抢金保险柜", "gold", false, function(p100)
    AutoSafe1 = p100

    if AutoSafe1 then
        AutoSafe2()
    end
end)

function AutoSafe2()
    local g337
    while AutoSafe1 do
        wait()

        local VaultDoor = game:GetService("Workspace").BankRobbery.VaultDoor
        local HumanoidRootPart = game:GetService("Players").LocalPlayer.Character.HumanoidRootPart

        if VaultDoor.Door.Attachment.ProximityPrompt.Enabled == true then
            VaultDoor.Door.Attachment.ProximityPrompt.HoldDuration = 0
            VaultDoor.Door.Attachment.ProximityPrompt.MaxActivationDistance = 16
            HumanoidRootPart.CFrame = CFrame.new(1071.9558105469, 9, -343.80816650391)
            wait(1)
            VaultDoor.Door.Attachment.ProximityPrompt:InputHoldBegin()
            VaultDoor.Door.Attachment.ProximityPrompt:InputHoldEnd()
            VaultDoor.Door.Attachment.ProximityPrompt.Enabled = false
        end

        local GoldJewelSafe = game:GetService("Workspace").Game.Entities.GoldJewelSafe
        local v332 = false
        local v333, v334, v335 = pairs(GoldJewelSafe:GetChildren())
        local v336

        repeat
            repeat
                v335, v336 = v333(v334, v335)

                if not v335 then
                    g337 = true
                end

                if g337 then
                    break
                end
            until v336.ClassName == "Model"

            if g337 then
                break
            end

            v332 = true
            HumanoidRootPart.CFrame = v336.WorldPivot
            wait(1)
            v336.Door["Meshes/LargeSafe_Cube.002_Cube.003_None (1)"].Attachment.ProximityPrompt.HoldDuration = 0
            v336.Door["Meshes/LargeSafe_Cube.002_Cube.003_None (1)"].Attachment.ProximityPrompt.MaxActivationDistance = 16
        until v336.Door["Meshes/LargeSafe_Cube.002_Cube.003_None (1)"].Attachment.ProximityPrompt.Enabled == true

        if not g337 then
            v336.Door["Meshes/LargeSafe_Cube.002_Cube.003_None (1)"].Attachment.ProximityPrompt:InputHoldBegin()
            v336.Door["Meshes/LargeSafe_Cube.002_Cube.003_None (1)"].Attachment.ProximityPrompt:InputHoldEnd()
            wait(5)
            v336:Destroy()
        end

        g337 = false

        if not v332 then
            game:GetService("StarterGui"):SetCore("SendNotification", {
				Title = "提示",
				Text = "金保险柜未刷新",
				Duration = 5
			})
            wait(30)
        end
    end
end
v38:Toggle("自动抢黑保险柜", "black", false, function(p101)
    AutoSafe3 = p101

    if AutoSafe3 then
        AutoSafe4()
    end
end)

function AutoSafe4()
    while AutoSafe3 do
        wait()
        local VaultDoor = game:GetService("Workspace").BankRobbery.VaultDoor
        local HumanoidRootPart = game:GetService("Players").LocalPlayer.Character.HumanoidRootPart
        if VaultDoor.Door.Attachment.ProximityPrompt.Enabled == true then
            VaultDoor.Door.Attachment.ProximityPrompt.HoldDuration = 0
            VaultDoor.Door.Attachment.ProximityPrompt.MaxActivationDistance = 16
            HumanoidRootPart.CFrame = CFrame.new(1071.9558105469, 9, -343.80816650391)
            wait(1)
            VaultDoor.Door.Attachment.ProximityPrompt:InputHoldBegin()
            VaultDoor.Door.Attachment.ProximityPrompt:InputHoldEnd()
            VaultDoor.Door.Attachment.ProximityPrompt.Enabled = false
        end
        local JewelSafe = game:GetService("Workspace").Game.Entities.JewelSafe
        local v342 = false
        for v345, v346 in pairs(JewelSafe:GetChildren()) do

            if v346.ClassName == "Model" then
                v342 = true
                HumanoidRootPart.CFrame = v346.WorldPivot
                wait(1)
                v346.Door["Meshes/LargeSafe_Cube.002_Cube.003_None (1)"].Attachment.ProximityPrompt.HoldDuration = 0
                v346.Door["Meshes/LargeSafe_Cube.002_Cube.003_None (1)"].Attachment.ProximityPrompt.MaxActivationDistance = 16

                if v346.Door["Meshes/LargeSafe_Cube.002_Cube.003_None (1)"].Attachment.ProximityPrompt.Enabled == true then
                    v346.Door["Meshes/LargeSafe_Cube.002_Cube.003_None (1)"].Attachment.ProximityPrompt:InputHoldBegin()
                    v346.Door["Meshes/LargeSafe_Cube.002_Cube.003_None (1)"].Attachment.ProximityPrompt:InputHoldEnd()
                    wait(5)
                    v346:Destroy()
                end
            end
        end
        if not v342 then
            game:GetService("StarterGui"):SetCore("SendNotification", {
				Title = "提示",
				Text = "黑保险柜未刷新",
				Duration = 5
			})
            wait(30)
        end
    end
end
v38:Toggle("自动传送小宝箱", "Smalltreasurechest", false, function(p102)
    SmallChest1 = p102

    if SmallChest1 then
        SmallChest2()
    end
end)

function SmallChest2()
    local g355
    while SmallChest1 do
        wait()

        local SmallChest = game:GetService("Workspace").Game.Entities.SmallChest
        local GetChildren = SmallChest.GetChildren
        local v350 = false
        local v351, v352, v353 = pairs(GetChildren(SmallChest))
        local v354

        repeat
            v353, v354 = v351(v352, v353)

            if not v353 then
                g355 = true
            end

            if g355 then
                break
            end
        until v354.ClassName == "Model"

        if not g355 then
            v350 = true

            local WorldPivot = v354.WorldPivot
            local HumanoidRootPart = game:GetService("Players").LocalPlayer.Character.HumanoidRootPart

            HumanoidRootPart.CFrame = WorldPivot
            wait(0.3)
            v354.Lock["Meshes/untitled_chest.002_Material.009 (4)"].Attachment.ProximityPrompt:InputHoldBegin()
            v354.Lock["Meshes/untitled_chest.002_Material.009 (4)"].Attachment.ProximityPrompt:InputHoldEnd()
            wait(0.3)
            HumanoidRootPart.CFrame = CFrame.new(240.52850341797, -120, -620)
        end

        g355 = false

        if not v350 then
            game:GetService("StarterGui"):SetCore("SendNotification", {
				Title = "提示",
				Text = "小宝箱未刷新",
				Duration = 5
			})
            wait(30)
        end
    end
end
v38:Toggle("自动传送大宝箱", "Teleport", false, function(p103)
    LargeChest1 = p103

    if LargeChest1 then
        LargeChest2()
    end
end)

function LargeChest2()
    local g365
    while LargeChest1 do
        wait()

        local LargeChest = game:GetService("Workspace").Game.Entities.LargeChest
        local v360 = false
        local v361, v362, v363 = pairs(LargeChest:GetChildren())
        local v364

        repeat
            v363, v364 = v361(v362, v363)

            if not v363 then
                g365 = true
            end

            if g365 then
                break
            end
        until v364.ClassName == "Model"

        if not g365 then
            v360 = true

            local WorldPivot = v364.WorldPivot
            local HumanoidRootPart = game:GetService("Players").LocalPlayer.Character.HumanoidRootPart

            HumanoidRootPart.CFrame = WorldPivot
            wait(0.3)
            v364.Door["Meshes/LargeSafe1_Cube.002_Cube.003_None (3)"].Attachment.ProximityPrompt:InputHoldBegin()
            v364.Door["Meshes/LargeSafe1_Cube.002_Cube.003_None (3)"].Attachment.ProximityPrompt:InputHoldEnd()
            wait(0.3)
            HumanoidRootPart.CFrame = CFrame.new(240.52850341797, -120, -620)
        end

        g365 = false

        if not v360 then
            game:GetService("StarterGui"):SetCore("SendNotification", {
				Title = "提示",
				Text = "大宝箱未刷新",
				Duration = 5
			})
            wait(30)
        end
    end
end
v38:Toggle("自动传送小保险+秒开", "Secondsopen", false, function(p104)
    SmallSafe1 = p104

    if SmallSafe1 then
        SmallSafe2()
    end
end)

function SmallSafe2()
    local g375
    while SmallSafe1 do
        wait(0.1)

        local SmallSafe = game:GetService("Workspace").Game.Entities.SmallSafe
        local v370 = false
        local v371, v372, v373 = pairs(SmallSafe:GetChildren())
        local v374

        repeat
            v373, v374 = v371(v372, v373)

            if not v373 then
                g375 = true
            end

            if g375 then
                break
            end
        until v374.ClassName == "Model"

        if not g375 then
            v370 = true

            local WorldPivot = v374.WorldPivot
            local HumanoidRootPart = game:GetService("Players").LocalPlayer.Character.HumanoidRootPart

            SmallSafe.SmallSafe.Door["Meshes/Safe1_Cube.002_Cube.003_None (1)"].Attachment.ProximityPrompt.HoldDuration = 0
            HumanoidRootPart.CFrame = WorldPivot
        end

        g375 = false

        if not v370 then
            game:GetService("StarterGui"):SetCore("SendNotification", {
				Title = "提示",
				Text = "小保险未刷新",
				Duration = 5
			})
            wait(30)
        end
    end
end
v38:Toggle("自动寻找印钞机", "money", false, function(p105)
    MoneyPrint1 = p105

    if MoneyPrint1 then
        MoneyPrint2()
    end
end)

function MoneyPrint2()
    if MoneyPrint1 then
        wait(0.1)

        while true do

            for v381, v382 in pairs(game:GetService("Workspace").Game.Entities.ItemPickup:GetChildren()) do

                local GetChildren = v382.GetChildren

                for _, v in pairs(GetChildren(v382)) do
                    if v.ClassName == "MeshPart" or "Part" then
                        for _, child in pairs(v:GetChildren()) do
                            if child.ClassName == "ProximityPrompt" and child.ObjectText == "Money Printer" then
                                local vCFrame = v.CFrame

                                game:GetService("Players").LocalPlayer.Character.HumanoidRootPart.CFrame = vCFrame
                            end
                        end
                    end
                end
            end
            wait(0.1)
            for _, child in pairs(game:GetService("Workspace").Game.Entities.ItemPickup:GetChildren()) do
                local GetChildren = child.GetChildren

                for _, v in pairs(GetChildren(child)) do
                    local GetChildren2 = v.GetChildren

                    for _, v14 in pairs(GetChildren2(v)) do
                        if v14.ClassName == "BillboardGui" then
                            v14:Remove()
                        end
                    end
                end
            end
        end
    end
end
local v39 = v5:Tab("秒开功能", "18930406865"):section("秒开功能", true)

v39:Button("秒开银行+微距离", function()
    game:GetService("Workspace").BankRobbery.VaultDoor.Door.Attachment.ProximityPrompt.HoldDuration = 0
    game:GetService("Workspace").BankRobbery.VaultDoor.Door.Attachment.ProximityPrompt.MaxActivationDistance = 16
    game:GetService("Workspasce").BankRobbery.BankCash.Main.Attachment.ProximityPrompt.MaxActivationDistance = 16
end)
v39:Button("秒开金保险柜", function()
    while true do
        wait(0.1)

        local GoldJewelSafe = game:GetService("Workspace").Game.Entities.GoldJewelSafe.GoldJewelSafe

        GoldJewelSafe.Door["Meshes/LargeSafe_Cube.002_Cube.003_None (1)"].Attachment.ProximityPrompt.HoldDuration = 0
        GoldJewelSafe.Name = "safeopen"
    end
end)
v39:Button("秒开黑保险柜", function()
    while true do
        wait(0.1)

        local JewelSafe = game:GetService("Workspace").Game.Entities.JewelSafe.JewelSafe

        JewelSafe.Door["Meshes/LargeSafe_Cube.002_Cube.003_None (1)"].Attachment.ProximityPrompt.HoldDuration = 0
        JewelSafe.Name = "safeopen"
    end
end)

local v40 = v5:Tab("透视功能", "18930406865"):section("透视功能", true)

v40:Button("玩家透视", function()
    _G.WRDESPEnabled = nil
    _G.WRDESPBoxes = nil
    _G.WRDESPTeamColors = nil
    _G.WRDESPTracers = nil
    _G.WRDESPNames = nil

    if not _G.WRDESPLoaded then
        local cFrame = CFrame.new(0, -1.5, 0)
        local vector3 = Vector3.new(4, 6, 0)
        local color3_23 = Color3.fromRGB(255, 170, 0)
        local self = setmetatable({}, {
			__mode = "kv"
		})
        local t13 = {
			Enabled = false,
			Boxes = true,
			BoxShift = cFrame,
			BoxSize = vector3,
			Color = color3_23,
			FaceCamera = false,
			Names = true,
			TeamColor = true,
			Thickness = 2,
			AttachShift = 1,
			TeamMates = true,
			Players = true,
			Objects = self,
			Overrides = {}
		}
        local CurrentCamera = workspace.CurrentCamera
        local Players = game:GetService("Players")
        local LocalPlayer = Players.LocalPlayer

        LocalPlayer:GetMouse()

        local _ = Vector3.new
        local WorldToViewportPoint = CurrentCamera.WorldToViewportPoint

        local function v409(p106, p107)
            local drawing = Drawing.new(p106)

            if not p107 then
                p107 = {}
            end

            for k, v in pairs(p107) do
                drawing[k] = v
            end

            return drawing
        end

        function t13.GetTeam(p108, p109)
            local GetTeam = p108.Overrides.GetTeam

            if GetTeam then
                return GetTeam(p109)
            end

            return p109 and p109.Team
        end
        function t13.IsTeamMate(p110, p111)
            local IsTeamMate = p110.Overrides.IsTeamMate

            if IsTeamMate then
                return IsTeamMate(p111)
            end

            local GetTeam = p110.GetTeam
            local GetTeam2 = p110.GetTeam

            return GetTeam(p110, p111) == GetTeam2(p110, LocalPlayer)
        end
        function t13.GetColor(p112, p113)
            local GetColor = p112.Overrides.GetColor

            if GetColor then
                return GetColor(p113)
            end

            local PlrFromChar = p112:GetPlrFromChar(p113)

            if PlrFromChar then
                local TeamColor = p112.TeamColor

                if TeamColor then
                    TeamColor = PlrFromChar.Team

                    if TeamColor then
                        TeamColor = PlrFromChar.Team.TeamColor.Color
                    end
                end

                PlrFromChar = TeamColor
            end

            return PlrFromChar or p112.Color
        end
        function t13.GetPlrFromChar(p114, p115)
            local GetPlrFromChar = p114.Overrides.GetPlrFromChar

            if GetPlrFromChar then
                return GetPlrFromChar(p115)
            end

            return Players:GetPlayerFromCharacter(p115)
        end
        function t13.Toggle(p116, p117)
            p116.Enabled = p117

            if not p117 then
                for _, v in pairs(p116.Objects) do
                    if v.Type == "Box" then
                        if v.Temporary then
                            v:Remove()
                        else
                            for _, v15 in pairs(v.Components) do
                                v15.Visible = false
                            end
                        end
                    end
                end
            end
        end
        function t13.GetBox(p118, p119)
            return p118.Objects[p119]
        end
        function t13.AddObjectListener(_, p121, p122)
            local function v675(p123)
                local v791 = type((nil).Type) == "string"

                if v791 then
                    v791 = p123:IsA((nil).Type)
                end

                if not v791 then
                    v791 = (nil).Type == nil
                end

                if v791 then
                    local v792 = type((nil).Name) == "string"

                    if v792 then
                        v792 = p123.Name == (nil).Name
                    end

                    if not v792 then
                        v792 = (nil).Name == nil
                    end

                    if v792 then
                        local v793 = not (nil).Validator

                        if not v793 then
                            v793 = (nil).Validator(p123)
                        end

                        if v793 then
                            local v794 = t13
                            local v795 = type((nil).PrimaryPart) == "string"

                            if v795 then
                                v795 = p123:WaitForChild((nil).PrimaryPart)
                            end

                            if not v795 then
                                v795 = type((nil).PrimaryPart) == "function"

                                if v795 then
                                    v795 = (nil).PrimaryPart(p123)
                                end
                            end

                            local v796 = type((nil).Color) == "function"

                            if v796 then
                                v796 = (nil).Color(p123)
                            end

                            if not v796 then
                                v796 = (nil).Color
                            end

                            local ColorDynamic = (nil).ColorDynamic
                            local v798 = type((nil).CustomName) == "function"

                            if v798 then
                                v798 = (nil).CustomName(p123)
                            end

                            if not v798 then
                                v798 = (nil).CustomName
                            end

                            local IsEnabled = (nil).IsEnabled
                            local Add = v794.Add
                            local RenderInNil = (nil).RenderInNil
                            local v802 = Add(v794, p123, {
								PrimaryPart = v795,
								Color = v796,
								ColorDynamic = ColorDynamic,
								Name = v798,
								IsEnabled = IsEnabled,
								RenderInNil = RenderInNil
							})

                            if (nil).OnAdded then
                                coroutine.wrap((nil).OnAdded)(v802)
                            end
                        end
                    end
                end
            end

            if p122.Recursive then
                p121.DescendantAdded:Connect(v675)

                local GetDescendants = p121.GetDescendants

                for _, v in pairs(GetDescendants(p121)) do
                    coroutine.wrap(v675)(v)
                end

                return
            end

            p121.ChildAdded:Connect(v675)

            local GetChildren = p121.GetChildren

            for _, v in pairs(GetChildren(p121)) do
                coroutine.wrap(v675)(v)
            end
        end

        local t14 = {}

        t14.__index = t14

        function t14.Remove(p124)
            t13.Objects[p124.Object] = nil

            for k, v in pairs(p124.Components) do
                v.Visible = false
                v:Remove()
                p124.Components[k] = nil
            end
        end
        function t14.Update(p125)
            if not p125.PrimaryPart then
                return p125:Remove()
            end

            local HighlightColor

            if t13.Highlighted == p125.Object then
                HighlightColor = t13.HighlightColor
            else
                HighlightColor = p125.Color

                if not HighlightColor then
                    HighlightColor = p125.ColorDynamic and p125:ColorDynamic()

                    if not HighlightColor then
                        HighlightColor = t13:GetColor(p125.Object)

                        if not HighlightColor then
                            HighlightColor = t13.Color
                        end
                    end
                end
            end

            local v687 = true
            local UpdateAllow = t13.Overrides.UpdateAllow

            if UpdateAllow then
                UpdateAllow = not t13.Overrides.UpdateAllow(p125)
            end

            if UpdateAllow then
                v687 = false
            end

            local Player = p125.Player

            if Player then
                Player = not t13.TeamMates

                if Player then
                    Player = t13:IsTeamMate(p125.Player)
                end
            end

            if Player then
                v687 = false
            end

            local Player2 = p125.Player

            if Player2 then
                Player2 = not t13.Players
            end

            if Player2 then
                v687 = false
            end

            local IsEnabled = p125.IsEnabled

            if IsEnabled then
                IsEnabled = type(p125.IsEnabled) == "string"

                if IsEnabled then
                    IsEnabled = not t13[p125.IsEnabled]
                end

                if not IsEnabled then
                    IsEnabled = type(p125.IsEnabled) == "function" and not p125:IsEnabled()
                end
            end

            if IsEnabled then
                v687 = false
            end

            if not workspace:IsAncestorOf(p125.PrimaryPart) and not p125.RenderInNil then
                v687 = false
            end

            if not v687 then
                for _, v in pairs(p125.Components) do
                    v.Visible = false
                end

                return
            end

            if t13.Highlighted == p125.Object then
                HighlightColor = t13.HighlightColor
            end

            local PrimaryPartCFrame = p125.PrimaryPart.CFrame

            if t13.FaceCamera then
                PrimaryPartCFrame = CFrame.new(PrimaryPartCFrame.p, CurrentCamera.CFrame.p)
            end

            local p125Size = p125.Size
            local v696 = PrimaryPartCFrame * t13.BoxShift * CFrame.new(p125Size.X / 2, p125Size.Y / 2, 0)
            local v697 = PrimaryPartCFrame * t13.BoxShift * CFrame.new(-p125Size.X / 2, p125Size.Y / 2, 0)
            local v698 = PrimaryPartCFrame * t13.BoxShift * CFrame.new(p125Size.X / 2, -p125Size.Y / 2, 0)
            local v699 = PrimaryPartCFrame * t13.BoxShift * CFrame.new(-p125Size.X / 2, -p125Size.Y / 2, 0)
            local v700 = PrimaryPartCFrame * t13.BoxShift * CFrame.new(0, p125Size.Y / 2, 0)
            local v701 = PrimaryPartCFrame * t13.BoxShift
            local t15 = {
				TopLeft = v696,
				TopRight = v697,
				BottomLeft = v698,
				BottomRight = v699,
				TagPos = v700,
				Torso = v701
			}

            if t13.Boxes then
                local v703, v704 = WorldToViewportPoint(CurrentCamera, t15.TopLeft.p)
                local v705, v706 = WorldToViewportPoint(CurrentCamera, t15.TopRight.p)
                local v707, v708 = WorldToViewportPoint(CurrentCamera, t15.BottomLeft.p)
                local v709, v710 = WorldToViewportPoint(CurrentCamera, t15.BottomRight.p)

                if p125.Components.Quad then
                    if not v704 then
                        v704 = v706 or (v708 or v710)
                    end

                    if v704 then
                        p125.Components.Quad.Visible = true
                        p125.Components.Quad.PointA = Vector2.new(v705.X, v705.Y)
                        p125.Components.Quad.PointB = Vector2.new(v703.X, v703.Y)
                        p125.Components.Quad.PointC = Vector2.new(v707.X, v707.Y)
                        p125.Components.Quad.PointD = Vector2.new(v709.X, v709.Y)
                        p125.Components.Quad.Color = HighlightColor
                    else
                        p125.Components.Quad.Visible = false
                    end
                end
            else
                p125.Components.Quad.Visible = false
            end

            if t13.Names then
                local v712, t16Result = WorldToViewportPoint(CurrentCamera, t15.TagPos.p)
                if t16Result then
                    p125.Components.Name.Visible = true
                    p125.Components.Name.Position = Vector2.new(v712.X, v712.Y)
                    p125.Components.Name.Text = p125.Name
                    p125.Components.Name.Color = HighlightColor
                    p125.Components.Distance.Visible = true
                    p125.Components.Distance.Position = Vector2.new(v712.X, v712.Y + 14)
                    p125.Components.Distance.Text = math.floor((CurrentCamera.CFrame.p - PrimaryPartCFrame.p).magnitude) .. "m away"
                    p125.Components.Distance.Color = HighlightColor
                else
                    p125.Components.Name.Visible = false
                    p125.Components.Distance.Visible = false
                end
            else
                p125.Components.Name.Visible = false
                p125.Components.Distance.Visible = false
            end

            if t13.Tracers then
                local v713, v714 = WorldToViewportPoint(CurrentCamera, t15.Torso.p)

                if v714 then
                    p125.Components.Tracer.Visible = true
                    p125.Components.Tracer.From = Vector2.new(v713.X, v713.Y)
                    p125.Components.Tracer.To = Vector2.new(CurrentCamera.ViewportSize.X / 2, CurrentCamera.ViewportSize.Y / t13.AttachShift)
                    p125.Components.Tracer.Color = HighlightColor

                    return
                end

                p125.Components.Tracer.Visible = false

                return
            end

            p125.Components.Tracer.Visible = false
        end
        function t13.Add(p126, p127, p128)
            if not p127.Parent and not p128.RenderInNil then
                return warn(p127, "has no parent")
            end

            local _setmetatable = setmetatable
            local p128Name = p128.Name

            if not p128Name then
                p128Name = p127.Name
            end

            local p128Color = p128.Color
            local v721 = p128.Size or p126.BoxSize
            local Player = p128.Player

            if not Player then
                Player = Players:GetPlayerFromCharacter(p127)
            end

            local PrimaryPart = p128.PrimaryPart

            if not PrimaryPart then
                PrimaryPart = p127.ClassName == "Model"

                if PrimaryPart then
                    PrimaryPart = p127.PrimaryPart

                    if not PrimaryPart then
                        PrimaryPart = p127:FindFirstChild("HumanoidRootPart")

                        if not PrimaryPart then
                            PrimaryPart = p127:FindFirstChildWhichIsA("BasePart")
                        end
                    end
                end

                if not PrimaryPart then
                    PrimaryPart = p127:IsA("BasePart") and p127
                end
            end

            local IsEnabled = p128.IsEnabled
            local Temporary = p128.Temporary
            local ColorDynamic = p128.ColorDynamic
            local RenderInNil = p128.RenderInNil
            local v728 = _setmetatable({
				Name = p128Name,
				Type = "Box",
				Color = p128Color,
				Size = v721,
				Object = p127,
				Player = Player,
				PrimaryPart = PrimaryPart,
				Components = {},
				IsEnabled = IsEnabled,
				Temporary = Temporary,
				ColorDynamic = ColorDynamic,
				RenderInNil = RenderInNil
			}, t14)

            if p126:GetBox(p127) then
                p126:GetBox(p127):Remove()
            end

            local Components = v728.Components
            local v730 = v409
            local p126Thickness = p126.Thickness
            local _color = color
            local v733 = p126.Enabled and p126.Boxes

            Components.Quad = v730("Quad", {
				Thickness = p126Thickness,
				Color = _color,
				Transparency = 1,
				Filled = false,
				Visible = v733
			})

            local Components2 = v728.Components
            local v735 = v409
            local Name = v728.Name
            local Color = v728.Color
            local v738 = p126.Enabled and p126.Names

            Components2.Name = v735("Text", {
				Text = Name,
				Color = Color,
				Center = true,
				Outline = true,
				Size = 19,
				Visible = v738
			})

            local Components3 = v728.Components
            local v740 = v409
            local Color2 = v728.Color
            local v742 = p126.Enabled and p126.Names

            Components3.Distance = v740("Text", {
				Color = Color2,
				Center = true,
				Outline = true,
				Size = 19,
				Visible = v742
			})

            local Components4 = v728.Components
            local v744 = v409
            local t13Thickness = t13.Thickness
            local Color4 = v728.Color
            local v747 = p126.Enabled and p126.Tracers

            Components4.Tracer = v744("Line", {
				Thickness = t13Thickness,
				Color = Color4,
				Transparency = 1,
				Visible = v747
			})
            p126.Objects[p127] = v728
            p127.AncestryChanged:Connect(function(_, parent)
                local v805 = parent == nil

                if v805 then
                    v805 = t13.AutoRemove ~= false
                end

                if v805 then
                    v728:Remove()
                end
            end)
            p127:GetPropertyChangedSignal("Parent"):Connect(function()
                local v806 = p127.Parent == nil

                if v806 then
                    v806 = t13.AutoRemove ~= false
                end

                if v806 then
                    v728:Remove()
                end
            end)

            local Humanoid = p127:FindFirstChildOfClass("Humanoid")

            if Humanoid then
                Humanoid.Died:Connect(function()
                    if t13.AutoRemove ~= false then
                        v728:Remove()
                    end
                end)
            end

            return v728
        end

        local function v411(p130)
            local player = Players:GetPlayerFromCharacter(p130)

            if not p130:FindFirstChild("HumanoidRootPart") then
                local connection
                connection = p130.ChildAdded:Connect(function(child)
                    if child.Name == "HumanoidRootPart" then
                        connection:Disconnect()

                        local v808 = t13
                        local v809 = p130
                        local v810 = player
                        local Add = v808.Add
                        local Name = v810.Name
                        local v813 = player

                        Add(v808, v809, {
							Name = Name,
							Player = v813,
							PrimaryPart = child
						})
                    end
                end)

                return
            end

            local v752 = t13
            local playerName = player.Name
            local HumanoidRootPart = p130.HumanoidRootPart

            v752:Add(p130, {
				Name = playerName,
				Player = player,
				PrimaryPart = HumanoidRootPart
			})
        end
        local function v412(p131)
            p131.CharacterAdded:Connect(v411)

            if p131.Character then
                coroutine.wrap(v411)(p131.Character)
            end
        end

        Players.PlayerAdded:Connect(v412)

        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
                v412(player)
            end
        end

        game:GetService("RunService").RenderStepped:Connect(function()
            CurrentCamera = workspace.CurrentCamera

            for _, v757 in (t13.Enabled and pairs or ipairs)(t13.Objects) do
                if v757.Update then
                    local ok, result = pcall(v757.Update, v757)

                    if not ok then
                        warn("[EU]", result, v757.Object:GetFullName())
                    end
                end
            end
        end)

        if _G.WRDESPEnabled == nil then
            _G.WRDESPEnabled = true
        end

        if _G.WRDESPBoxes == nil then
            _G.WRDESPBoxes = true
        end

        if _G.WRDESPTeamColors == nil then
            _G.WRDESPTeamColors = true
        end

        if _G.WRDESPTracers == nil then
            _G.WRDESPTracers = false
        end

        if _G.WRDESPNames == nil then
            _G.WRDESPNames = true
        end

        while wait(0.1) do
            t13:Toggle(_G.WRDESPEnabled or false)
            t13.Boxes = _G.WRDESPBoxes or false
            t13.TeamColors = _G.WRDESPTeamColors or false
            t13.Tracers = _G.WRDESPTracers or false
            t13.Names = _G.WRDESPNames or false
        end

        _G.WRDESPLoaded = true
    end
end)
t1.value50 = {
	["Military Armory Keycard"] = true,
	["Sawn Off"] = true,
	["Scar L"] = true,
	["Military Vest"] = true,
	Raygun = true,
	["UPS 45"] = true,
	["Medium Vest"] = true,
	Deagle = true,
	["Glock 18"] = true,
	["Heavy Vest"] = true,
	["Diamond Ring"] = true,
	["AS Val"] = true,
	["Money Printer"] = true,
	Aug = true,
	M4A1 = true,
	C4 = true,
	Stagecoach = true,
	Diamond = true,
	["Void Gem"] = true,
	["Dark Matter Gem"] = true,
	["Gold AK-47"] = true,
	["Barrett M107"] = true,
	["Gold Deagle"] = true,
	["Double Barrel"] = true,
	Dragunov = true,
	RPK = true,
	["M249 SAW"] = true,
	Flamethrower = true,
	["Police Armory Keycard"] = true,
	RPG = true,
	["Saiga 12"] = true,
	["Ammo Box"] = true
}
t1.value51 = {
	["Medical Supplies"] = true,
	["Weapon components"] = true,
	Explosives = true,
	["Weapon Parts"] = true,
	Scrap = true
}
getgenv().Ye_ESP_Weapons = false
getgenv().Ye_ESP_Parts = false
t1.value52 = nil
t1.value52 = {}
function t1.value53()
    for _, v in pairs(t1.value52) do
        if v.Gui then
            v.Gui:Destroy()
        end
    end

    table.clear(t1.value52)
end
task.spawn(function()
    while true do
        local v417 = not getgenv().Ye_ESP_Weapons

        if v417 then
            v417 = not getgenv().Ye_ESP_Parts
        end

        if v417 then
            t1.value53()
            task.wait(1)
        else
            for k, v in pairs(t1.value52) do
                local v420 = k

                if not v420 or not v420.Parent then
                    v.Gui:Destroy()
                    t1.value52[v420] = nil
                end
            end

            local LocalPlayer = game:GetService("Players").LocalPlayer
            local Character = LocalPlayer.Character

            if Character then
                Character = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            end

            local ItemPickup = game:GetService("Workspace").Game.Entities:FindFirstChild("ItemPickup")

            if ItemPickup then
                for _, child in pairs(ItemPickup:GetChildren()) do
                    for _, child4 in pairs(child:GetChildren()) do
                        if child4:IsA("MeshPart") or child4:IsA("Part") then
                            local ProximityPrompt = child4:FindFirstChildOfClass("ProximityPrompt")

                            if ProximityPrompt then
                                local ObjectText = ProximityPrompt.ObjectText
                                local v430 = t1.value50[ObjectText]
                                local v431 = v430
                                local v432 = t1.value51[ObjectText]

                                if v430 then
                                    v431 = getgenv().Ye_ESP_Weapons
                                end

                                if not v431 then
                                    if v432 then
                                        v432 = getgenv().Ye_ESP_Parts
                                    end

                                    v431 = v432
                                end

                                if v431 then
                                    local s1 = ""

                                    if Character then
                                        s1 = " [" .. math.floor((Character.Position - child4.Position).Magnitude) .. "m]"
                                    end

                                    if not t1.value52[child4] then
                                        local BillboardGui = Instance.new("BillboardGui")

                                        BillboardGui.Name = "Ye_ItemESP"
                                        BillboardGui.AlwaysOnTop = true
                                        BillboardGui.Size = UDim2.new(0, 200, 0, 20)
                                        BillboardGui.StudsOffset = Vector3.new(0, 1.5, 0)
                                        BillboardGui.MaxDistance = 1500

                                        local TextLabel4 = Instance.new("TextLabel")

                                        TextLabel4.Size = UDim2.new(1, 0, 1, 0)
                                        TextLabel4.BackgroundTransparency = 1
                                        TextLabel4.TextSize = 13
                                        TextLabel4.Font = Enum.Font.GothamBold
                                        TextLabel4.TextStrokeTransparency = 0.2
                                        TextLabel4.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)

                                        if v430 then
                                            TextLabel4.TextColor3 = Color3.fromRGB(255, 120, 120)
                                            TextLabel4.Text = "物品 " .. ObjectText .. s1
                                        else
                                            TextLabel4.TextColor3 = Color3.fromRGB(120, 255, 120)
                                            TextLabel4.Text = "零件 " .. ObjectText .. s1
                                        end

                                        TextLabel4.Parent = BillboardGui
                                        BillboardGui.Adornee = child4

                                        local CoreGui = game:GetService("CoreGui")

                                        BillboardGui.Parent = CoreGui:FindFirstChild("RobloxGui") or CoreGui
                                        t1.value52[child4] = {
											Gui = BillboardGui,
											Txt = TextLabel4,
											IsWep = v430,
											Name = ObjectText
										}
                                    else
                                        local v437 = t1.value52[child4]

                                        if v437.IsWep then
                                            v437.Txt.Text = "物品 " .. v437.Name .. s1
                                        else
                                            v437.Txt.Text = "零件 " .. v437.Name .. s1
                                        end
                                    end
                                elseif t1.value52[child4] then
                                    t1.value52[child4].Gui:Destroy()
                                    t1.value52[child4] = nil
                                end
                            end
                        end
                    end
                end
            end

            task.wait(0.5)
        end
    end
end)
v40:Toggle("物品透视 (武器与贵重物)", "", false, function(p132)
    getgenv().Ye_ESP_Weapons = p132
end)
v40:Toggle("零件透视 (材料与物资)", "", false, function(p133)
    getgenv().Ye_ESP_Parts = p133
end)
v5:Tab("传送功能", "18930406865"):section("传送功能", true):Dropdown("传送位置", "Dropdown", {
	"银行",
	"珠宝店",
	"沙滩",
	"武器店（撬锁）",
	"武士刀",
	"射线枪",
	"加特林",
	"锯掉",
	"沙漠之鹰",
	"警察局（M4A1）",
	"AUG",
	"军事基地（军甲）"
}, function(p134)
    local HumanoidRootPart = game:GetService("Players").LocalPlayer.Character.HumanoidRootPart

    if p134 == "银行" then
        HumanoidRootPart.CFrame = CFrame.new(1055.94153, 15.11950874, -344.58374)

        return
    end

    if p134 == "珠宝店" then
        HumanoidRootPart.CFrame = CFrame.new(1719.02637, 14.2831011, -714.293091)

        return
    end

    if p134 == "沙滩" then
        HumanoidRootPart.CFrame = CFrame.new(998.46563720703, 15, 395.97897338867)

        return
    end

    if p134 == "武器店（撬锁）" then
        HumanoidRootPart.CFrame = CFrame.new(660.52844238281, 6.4081127643585, -716.48999023438)

        return
    end

    if p134 == "武士刀" then
        HumanoidRootPart.CFrame = CFrame.new(175.191, 13.937, -132.69)

        return
    end

    if p134 == "射线枪" then
        HumanoidRootPart.CFrame = CFrame.new(148.685471, -90, -529.280945)

        return
    end

    if p134 == "加特林" then
        HumanoidRootPart.CFrame = CFrame.new(364.97076416016, 0.76497411727905, -1447.3302001953)

        return
    end

    if p134 == "锯掉" then
        HumanoidRootPart.CFrame = CFrame.new(1179.98523, 40, -436.812683)

        return
    end

    if p134 == "沙漠之鹰" then
        HumanoidRootPart.CFrame = CFrame.new(363.341461, 26.0798492, -259.681396)

        return
    end

    if p134 == "警察局（M4A1）" then
        HumanoidRootPart.CFrame = CFrame.new(603.46765136719, 25.662811279297, -922.04425048828)

        return
    end

    if p134 == "AUG" then
        HumanoidRootPart.CFrame = CFrame.new(1170.5002441406, 48.371383666992, -772.55859375)

        return
    end

    if p134 == "军事基地（军甲）" then
        HumanoidRootPart.CFrame = CFrame.new(563.44226074219, 28.502071380615, -1472.7805175781)
    end
end)

local v41 = v5:Tab("美化功能", "18930406865"):section("功能", true)

v41:Dropdown("选择一个皮肤", "Dropdown", {
	"烟火",
	"虚空",
	"纯金",
	"暗物质",
	"反物质",
	"神秘",
	"虚空神秘",
	"战术",
	"纯金战术",
	"白未来",
	"黑未来",
	"圣诞未来",
	"礼物包装",
	"猩红",
	"收割者",
	"虚空收割者",
	"圣诞玩具",
	"荒地",
	"隐形",
	"像素",
	"钻石像素",
	"黄金零下",
	"绿水晶",
	"生物",
	"樱花",
	"精英",
	"黑樱花",
	"彩虹激光",
	"蓝水晶",
	"紫水晶",
	"红水晶",
	"零下",
	"虚空射线",
	"冰冻钻石",
	"虚空梦魇",
	"金雪",
	"爱国者",
	"MM2",
	"声望",
	"酷化",
	"蒸汽",
	"海盗",
	"玫瑰",
	"黑玫瑰",
	"激光",
	"烟花",
	"诅咒背瓜",
	"大炮",
	"财富",
	"黄金大炮",
	"四叶草",
	"自由",
	"黑曜石",
	"赛博朋克"
}, function(p135)
    if p135 == "烟火" then
        skinsec = "Sparkler"

        return
    end

    if p135 == "虚空" then
        skinsec = "Void"

        return
    end

    if p135 == "纯金" then
        skinsec = "Solid Gold"

        return
    end

    if p135 == "暗物质" then
        skinsec = "Dark Matter"

        return
    end

    if p135 == "反物质" then
        skinsec = "Anti Matter"

        return
    end

    if p135 == "神秘" then
        skinsec = "Hystic"

        return
    end

    if p135 == "虚空神秘" then
        skinsec = "Void Mystic"

        return
    end

    if p135 == "战术" then
        skinsec = "Tactical"

        return
    end

    if p135 == "纯金战术" then
        skinsec = "Solid Gold Tactical"

        return
    end

    if p135 == "白未来" then
        skinsec = "Future White"

        return
    end

    if p135 == "黑未来" then
        skinsec = "Future Black"

        return
    end

    if p135 == "圣诞未来" then
        skinsec = "Christmas Future"

        return
    end

    if p135 == "礼物包装" then
        skinsec = "Gift Wrapped"

        return
    end

    if p135 == "猩红" then
        skinsec = "Crimson Blood"

        return
    end

    if p135 == "收割者" then
        skinsec = "Reaper"

        return
    end

    if p135 == "虚空收割者" then
        skinsec = "Void Reaper"

        return
    end

    if p135 == "圣诞玩具" then
        skinsec = "Christmas Toy"

        return
    end

    if p135 == "荒地" then
        skinsec = "Wasteland"

        return
    end

    if p135 == "隐形" then
        skinsec = "Invisible"

        return
    end

    if p135 == "像素" then
        skinsec = "Pixel"

        return
    end

    if p135 == "钻石像素" then
        skinsec = "Diamond Pixel"

        return
    end

    if p135 == "黄金零下" then
        skinsec = "Frozen-Gold"

        return
    end

    if p135 == "绿水晶" then
        skinsec = "Atomic Nature"

        return
    end

    if p135 == "生物" then
        skinsec = "Biohazard"

        return
    end

    if p135 == "樱花" then
        skinsec = "Sakura"

        return
    end

    if p135 == "精英" then
        skinsec = "Elite"

        return
    end

    if p135 == "黑樱花" then
        skinsec = "Death Blossom-Gold"

        return
    end

    if p135 == "彩虹激光" then
        skinsec = "Rainbowlaser"

        return
    end

    if p135 == "蓝水晶" then
        skinsec = "Atomic Water"

        return
    end

    if p135 == "紫水晶" then
        skinsec = "Atomic Amethyst"

        return
    end

    if p135 == "红水晶" then
        skinsec = "Atomic Flame"

        return
    end

    if p135 == "零下" then
        skinsec = "Sub-Zero"

        return
    end

    if p135 == "虚空射线" then
        skinsec = "Void-Ray"

        return
    end

    if p135 == "冰冻钻石" then
        skinsec = "Frozen Diamond"

        return
    end

    if p135 == "虚空梦魇" then
        skinsec = "Void Nightmare"

        return
    end

    if p135 == "金雪" then
        skinsec = "Golden Snow"

        return
    end

    if p135 == "爱国者" then
        skinsec = "Patriot"

        return
    end

    if p135 == "MM2" then
        skinsec = "MM2 Barrett"

        return
    end

    if p135 == "声望" then
        skinsec = "Prestige Barnett"

        return
    end

    if p135 == "酷化" then
        skinsec = "Skin Walter"

        return
    end

    if p135 == "蒸汽" then
        skinsec = "Steampunk"

        return
    end

    if p135 == "海盗" then
        skinsec = "Pirate"

        return
    end

    if p135 == "玫瑰" then
        skinsec = "Rose"

        return
    end

    if p135 == "黑玫瑰" then
        skinsec = "Black Rose"

        return
    end

    if p135 == "激光" then
        skinsec = "Hyperlaser"

        return
    end

    if p135 == "烟花" then
        skinsec = "Firework"

        return
    end

    if p135 == "诅咒背瓜" then
        skinsec = "Cursed Pumpkin"

        return
    end

    if p135 == "大炮" then
        skinsec = "Cannon"

        return
    end

    if p135 == "财富" then
        skinsec = "Firework"

        return
    end

    if p135 == "黄金大炮" then
        skinsec = "Gold Cannon"

        return
    end

    if p135 == "四叶草" then
        skinsec = "Lucky Clover"

        return
    end

    if p135 == "自由" then
        skinsec = "Freedom"

        return
    end

    if p135 == "黑曜石" then
        skinsec = "Obsidian"

        return
    end

    if p135 == "赛博朋克" then
        skinsec = "Cyberpunk"
    end
end)
v41:Toggle("开启美化", "", false, function(p136)
    autoskin = p136

    if autoskin then
        local inventory = require(game:GetService("ReplicatedStorage").devv).load("v3item").inventory
        local items = require(game:GetService("ReplicatedStorage").devv).load("v3item").inventory.items
        local _next = next
        local v447
        while true do
            local v448

            v447, v448 = _next(items, v447)

            if not v447 then
                break
            end

            if v448.type == "Gun" then
                inventory.skinUpdate(v448.name, skinsec)
            end
        end
    end
end)
v41:Button("普通气球美化美金气球", "", function()
    local v449, v450, v451 = pairs(getgc(true))
    local g453
    local v452
    repeat
        v451, v452 = v449(v450, v451)

        if not v451 then
            g453 = true
        end

        if g453 then
            break
        end

        local v454 = type(v452) == "table"

        if v454 then
            v454 = rawget(v452, "name") == "Balloon"

            if v454 then
                v454 = rawget(v452, "holdableType") == "Balloon"
            end
        end
    until v454
    if not g453 then
        v452.name = "Dollar Balloon"
        v452.cost = 200
        v452.unpurchasable = true
        v452.multiplier = 0.8
        v452.movespeedAdd = 8
        v452.cannotDiscard = true

        if v452.TPSOffsets then
            v452.TPSOffsets.hold = CFrame.new(0, 0, 0) * CFrame.Angles(0, math.pi, 0)
        end

        local viewportOffsets = v452.viewportOffsets

        if viewportOffsets then
            viewportOffsets = v452.viewportOffsets.hotbar
        end

        if viewportOffsets then
            v452.viewportOffsets.hotbar.dist = 4
        end

        v452.canDrop = nil
        v452.dropCooldown = nil
        v452.craft = nil
    end
    for _, v in pairs(require(game.ReplicatedStorage.devv.client.Objects.v3item.modules.inventory).items) do
        if v.name == "Dollar Balloon" then
            for _, v16 in pairs({
				v.button,
				v.backpackButton
			}) do
                if v16 and v16.resetModelSkin then
                    v16:resetModelSkin()
                end
            end
        end
    end
end)
v41:Button("普通气球美化黑玫瑰气球", "", function()
    local v460, v461, v462 = pairs(getgc(true))
    local g464
    local v463
    repeat
        v462, v463 = v460(v461, v462)

        if not v462 then
            g464 = true
        end

        if g464 then
            break
        end

        local v465 = type(v463) == "table"

        if v465 then
            v465 = rawget(v463, "name") == "Balloon"

            if v465 then
                v465 = rawget(v463, "holdableType") == "Balloon"
            end
        end
    until v465
    if not g464 then
        v463.name = "Black Rose"
        v463.cost = 200
        v463.unpurchasable = true
        v463.multiplier = 0.75
        v463.movespeedAdd = 12
        v463.cannotDiscard = true

        if v463.TPSOffsets then
            v463.TPSOffsets.hold = CFrame.new(0, 0.5, 0)
        end

        local viewportOffsets = v463.viewportOffsets

        if viewportOffsets then
            viewportOffsets = v463.viewportOffsets.hotbar
        end

        if viewportOffsets then
            v463.viewportOffsets.hotbar.dist = 3
        end

        v463.canDrop = nil
        v463.dropCooldown = nil
        v463.craft = nil
    end
    for _, v in pairs(require(game.ReplicatedStorage.devv.client.Objects.v3item.modules.inventory).items) do
        if v.name == "Black Rose" then
            for _, v17 in pairs({
				v.button,
				v.backpackButton
			}) do
                if v17 and v17.resetModelSkin then
                    v17:resetModelSkin()
                end
            end
        end
    end
end)
v41:Button("美化钱包", "", function()
    for _, v in pairs(getgc(true)) do
        local v473 = type(v) == "table"

        if v473 then
            v473 = rawget(v, "name") == "Wallet"
        end

        if v473 then
            v.name = "Duffel Bag"
            v.modelName = "Duffel Bag"
            v.subtype = "Wallet"

            if v.TPSOffsets then
                v.TPSOffsets.hold = CFrame.new(-0.1, -1, 0.1)
            end

            local viewportOffsets = v.viewportOffsets

            if viewportOffsets then
                viewportOffsets = v.viewportOffsets.hotbar
            end

            if not viewportOffsets then
                break
            end

            v.viewportOffsets.hotbar.offset = CFrame.new(0.1, 0.2, -2.5)
            v.viewportOffsets.hotbar.rotoffset = CFrame.Angles(0.78539816339745, 2.6179938779915, 0)

            break
        end
    end

    local inventory = require(game.ReplicatedStorage.devv.client.Objects.v3item.modules.inventory)

    for _, v in pairs(inventory.items) do
        if v.name == "Duffel Bag" then
            local button = v.button

            if button then
                button = v.button.resetModelSkin
            end

            if button then
                v.button:resetModelSkin()
            end

            local backpackButton = v.backpackButton

            if backpackButton then
                backpackButton = v.backpackButton.resetModelSkin
            end

            if backpackButton then
                v.backpackButton:resetModelSkin()
            end
        end
    end
end)

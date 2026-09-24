local WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/WuMing-YYDS/Script-UI/refs/heads/main/Wind%20UI.LUA"))()

-- ================================================================
--  ★★★ 内嵌卡密验证模块（支持多卡密） ★★★
-- ================================================================

-- ==================== 配置区 ====================
-- ★★★ 在这里添加所有有效卡密，用逗号分隔 ★★★
local VALID_KEYS = {
    "TY-hub-e0.459.528bata",
    -- 继续添加更多卡密...
}

-- ==================== 验证 UI ====================
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local TweenService = game:GetService("TweenService")

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "KeyValidation"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
screenGui.IgnoreGuiInset = true
screenGui.Parent = PlayerGui

local overlay = Instance.new("Frame")
overlay.Size = UDim2.new(1, 0, 1, 0)
overlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
overlay.BackgroundTransparency = 0.5
overlay.BorderSizePixel = 0
overlay.Parent = screenGui

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 420, 0, 260)
frame.Position = UDim2.new(0.5, 0, 0.5, 0)
frame.AnchorPoint = Vector2.new(0.5, 0.5)
frame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
frame.BackgroundTransparency = 0.12
frame.BorderSizePixel = 0
frame.ClipsDescendants = true
frame.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 20)
corner.Parent = frame

local stroke = Instance.new("UIStroke")
stroke.Thickness = 1.5
stroke.Color = Color3.fromRGB(255, 255, 255)
stroke.Transparency = 0.6
stroke.Parent = frame

local blur = Instance.new("BlurEffect")
blur.Size = 18
blur.Parent = frame

local glow = Instance.new("Frame")
glow.Size = UDim2.new(0, 180, 0, 180)
glow.Position = UDim2.new(0, -50, 0, -50)
glow.BackgroundColor3 = Color3.fromRGB(150, 200, 255)
glow.BackgroundTransparency = 0.6
glow.BorderSizePixel = 0
glow.Parent = frame
local glowCorner = Instance.new("UICorner")
glowCorner.CornerRadius = UDim.new(1, 0)
glowCorner.Parent = glow

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 36, 0, 36)
closeBtn.Position = UDim2.new(1, -46, 0, 12)
closeBtn.BackgroundTransparency = 1
closeBtn.Text = "✕"
closeBtn.TextColor3 = Color3.fromRGB(220, 220, 255)
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 22
closeBtn.Parent = frame

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 60)
title.Position = UDim2.new(0, 0, 0, 12)
title.BackgroundTransparency = 1
title.Text = "密钥🔒验证"
title.Font = Enum.Font.GothamBold
title.TextSize = 26
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextXAlignment = Enum.TextXAlignment.Center
title.Parent = frame

local subtitle = Instance.new("TextLabel")
subtitle.Size = UDim2.new(1, -40, 0, 30)
subtitle.Position = UDim2.new(0, 20, 0, 72)
subtitle.BackgroundTransparency = 1
subtitle.Text = "请输入您的卡密以解锁功能"
subtitle.Font = Enum.Font.Gotham
subtitle.TextSize = 15
subtitle.TextColor3 = Color3.fromRGB(220, 220, 255)
subtitle.TextXAlignment = Enum.TextXAlignment.Center
subtitle.TextWrapped = true
subtitle.Parent = frame

local inputBox = Instance.new("TextBox")
inputBox.Size = UDim2.new(0.8, 0, 0, 48)
inputBox.Position = UDim2.new(0.1, 0, 0, 112)
inputBox.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
inputBox.BackgroundTransparency = 0.15
inputBox.BorderSizePixel = 0
inputBox.PlaceholderText = "在此输入卡密..."
inputBox.PlaceholderColor3 = Color3.fromRGB(180, 180, 200)
inputBox.Text = ""
inputBox.TextColor3 = Color3.fromRGB(255, 255, 255)
inputBox.Font = Enum.Font.Gotham
inputBox.TextSize = 18
inputBox.ClearTextOnFocus = false
inputBox.Parent = frame
local inputCorner = Instance.new("UICorner")
inputCorner.CornerRadius = UDim.new(0, 12)
inputCorner.Parent = inputBox
local inputStroke = Instance.new("UIStroke")
inputStroke.Thickness = 1
inputStroke.Color = Color3.fromRGB(255, 255, 255)
inputStroke.Transparency = 0.3
inputStroke.Parent = inputBox

local submitBtn = Instance.new("TextButton")
submitBtn.Size = UDim2.new(0.8, 0, 0, 52)
submitBtn.Position = UDim2.new(0.1, 0, 0, 180)
submitBtn.BackgroundColor3 = Color3.fromRGB(100, 180, 255)
submitBtn.BackgroundTransparency = 0.2
submitBtn.BorderSizePixel = 0
submitBtn.Text = "🚀 立即激活"
submitBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
submitBtn.Font = Enum.Font.GothamBold
submitBtn.TextSize = 19
submitBtn.Parent = frame
local btnCorner = Instance.new("UICorner")
btnCorner.CornerRadius = UDim.new(0, 12)
btnCorner.Parent = submitBtn
local btnStroke = Instance.new("UIStroke")
btnStroke.Thickness = 1.5
btnStroke.Color = Color3.fromRGB(255, 255, 255)
btnStroke.Transparency = 0.4
btnStroke.Parent = submitBtn

-- ==================== 入场动画 ====================
frame.BackgroundTransparency = 1
frame.Size = UDim2.new(0, 0, 0, 0)
task.wait(0.05)
local tweenInfo = TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
local sizeTween = TweenService:Create(frame, tweenInfo, { Size = UDim2.new(0, 420, 0, 260) })
local fadeTween = TweenService:Create(frame, TweenInfo.new(0.3), { BackgroundTransparency = 0.12 })
sizeTween:Play()
fadeTween:Play()

-- ==================== 核心逻辑 ====================
local verificationComplete = false

-- ================================================================
--  ★★★ 主脚本执行函数（验证成功后自动调用） ★★★
--  ★★★ 把你的主脚本代码放在这里 ★★★
-- ================================================================
local function executeMainScript()
    print("[卡密验证] ✅ 验证成功，开始执行主脚本！")
    
    -- ════════════════════════════════════════════════════════════
    --  ★★★ 把你的主脚本代码放在下面 ★★★
    --  ★★★ 验证通过后会自动执行 ★★★
    -- ════════════════════════════════════════════════════════════

do
    local ok, err = pcall(function()
        local Players = game:GetService("Players")
        local TweenService = game:GetService("TweenService")
        local RunService = game:GetService("RunService")
        local CoreGui = game:GetService("CoreGui")
        local LocalPlayer = Players.LocalPlayer

        local function getGuiParent()
            local s, p = pcall(function()
                if gethui then return gethui() end
                return CoreGui
            end)
            if s and p then return p end
            return LocalPlayer:FindFirstChildOfClass("PlayerGui") or LocalPlayer:WaitForChild("PlayerGui")
        end

        local old = getGuiParent():FindFirstChild("GridCollapseBootAnimation")
        if old then old:Destroy() end

        local gui = Instance.new("ScreenGui")
        gui.Name = "GridCollapseBootAnimation"
        gui.ResetOnSpawn = false
        gui.IgnoreGuiInset = true
        gui.DisplayOrder = 9999999999999
        gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        gui.Parent = getGuiParent()

        local function tw(obj, props, dur, style, dir)
            style = style or Enum.EasingStyle.Quad
            dir = dir or Enum.EasingDirection.Out
            return TweenService:Create(obj, TweenInfo.new(dur, style, dir), props)
        end
        local function play(t) t:Play() end

        -- 创建音效
        local function createSound(soundId, volume, pitch)
            local sound = Instance.new("Sound")
            sound.SoundId = soundId
            sound.Volume = volume or 0.5
            sound.Pitch = pitch or 1
            sound.Parent = gui
            return sound
        end

        local bgMusic = createSound("rbxassetid://1841228593", 0.3, 1.2)
        local typeSound = createSound("rbxassetid://12221967", 0.15, 1)
        local completeSound = createSound("rbxassetid://1084605307", 0.5, 1.1)
        local collapseSound = createSound("rbxassetid://1566511635", 0.2, 1.3)

        -- 全屏黑色背景
        local bg = Instance.new("Frame")
        bg.Size = UDim2.new(1, 0, 1, 0)
        bg.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        bg.BackgroundTransparency = 0
        bg.ZIndex = 1
        bg.Parent = gui

        -- 网格背景容器
        local gridContainer = Instance.new("Frame")
        gridContainer.Size = UDim2.new(1, 0, 1, 0)
        gridContainer.BackgroundTransparency = 1
        gridContainer.ZIndex = 2
        gridContainer.Parent = bg

        -- 创建网格正方形
        local gridSize = 60 -- 格子大小
        local gridColor1 = Color3.fromRGB(0, 100, 60) -- 绿色
        local gridColor2 = Color3.fromRGB(0, 150, 100) -- 亮绿色
        local grids = {}

        local screenWidth = 1920
        local screenHeight = 1080
        local gridCountX = math.ceil(screenWidth / gridSize)
        local gridCountY = math.ceil(screenHeight / gridSize)

        for y = 0, gridCountY - 1 do
            for x = 0, gridCountX - 1 do
                local gridSquare = Instance.new("Frame")
                gridSquare.Size = UDim2.new(0, gridSize, 0, gridSize)
                gridSquare.Position = UDim2.new(0, x * gridSize, 0, y * gridSize)
                
                -- 交替颜色
                if (x + y) % 2 == 0 then
                    gridSquare.BackgroundColor3 = gridColor1
                else
                    gridSquare.BackgroundColor3 = gridColor2
                end
                
                gridSquare.BackgroundTransparency = 0.75
                gridSquare.BorderSizePixel = 1
                gridSquare.BorderColor3 = Color3.fromRGB(0, 150, 80)
                gridSquare.ZIndex = 2
                gridSquare.Parent = gridContainer
                
                table.insert(grids, {square = gridSquare, x = x, y = y})
            end
        end

        -- 中央进度框
        local centerBox = Instance.new("Frame")
        centerBox.Size = UDim2.new(0, 420, 0, 300)
        centerBox.Position = UDim2.new(0.5, -210, 0.5, -150)
        centerBox.BackgroundColor3 = Color3.fromRGB(0, 10, 5)
        centerBox.BackgroundTransparency = 0.2
        centerBox.BorderSizePixel = 0
        centerBox.ZIndex = 10
        centerBox.Parent = bg
        Instance.new("UICorner", centerBox).CornerRadius = UDim.new(0, 12)

        local centerStroke = Instance.new("UIStroke", centerBox)
        centerStroke.Color = Color3.fromRGB(0, 255, 100)
        centerStroke.Thickness = 2

        -- 标题
        local title = Instance.new("TextLabel")
        title.Size = UDim2.new(1, 0, 0, 50)
        title.Position = UDim2.new(0, 0, 0, 15)
        title.BackgroundTransparency = 1
        title.Text = "▌TY脚本正在加载 ▌"
        title.TextColor3 = Color3.fromRGB(0, 255, 100)
        title.TextTransparency = 1
        title.TextSize = 20
        title.Font = Enum.Font.Code
        title.TextXAlignment = Enum.TextXAlignment.Center
        title.ZIndex = 11
        title.Parent = centerBox

        -- 进度条背景
        local progressBg = Instance.new("Frame")
        progressBg.Size = UDim2.new(0, 350, 0, 8)
        progressBg.Position = UDim2.new(0, 35, 0, 80)
        progressBg.BackgroundColor3 = Color3.fromRGB(20, 30, 20)
        progressBg.BorderSizePixel = 0
        progressBg.ZIndex = 11
        progressBg.Parent = centerBox
        Instance.new("UICorner", progressBg).CornerRadius = UDim.new(0, 4)

        local progressStroke = Instance.new("UIStroke", progressBg)
        progressStroke.Color = Color3.fromRGB(0, 255, 100)
        progressStroke.Thickness = 1

        -- 进度条填充
        local progressFill = Instance.new("Frame")
        progressFill.Size = UDim2.new(0, 0, 1, 0)
        progressFill.BackgroundColor3 = Color3.fromRGB(0, 255, 100)
        progressFill.BorderSizePixel = 0
        progressFill.ZIndex = 12
        progressFill.Parent = progressBg
        Instance.new("UICorner", progressFill).CornerRadius = UDim.new(0, 4)

        local fillGradient = Instance.new("UIGradient", progressFill)
        fillGradient.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 150, 100)),
            ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 255, 150)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 200, 100)),
        })

        -- 百分比文本
        local percentText = Instance.new("TextLabel")
        percentText.Size = UDim2.new(0, 80, 0, 25)
        percentText.Position = UDim2.new(0, 35, 0, 105)
        percentText.BackgroundTransparency = 1
        percentText.Text = "0%"
        percentText.TextColor3 = Color3.fromRGB(0, 255, 100)
        percentText.TextTransparency = 1
        percentText.TextSize = 18
        percentText.Font = Enum.Font.Code
        percentText.TextXAlignment = Enum.TextXAlignment.Left
        percentText.ZIndex = 11
        percentText.Parent = centerBox

        -- 状态信息
        local statusInfo = Instance.new("TextLabel")
        statusInfo.Size = UDim2.new(1, -70, 0, 60)
        statusInfo.Position = UDim2.new(0, 35, 0, 150)
        statusInfo.BackgroundTransparency = 1
        statusInfo.Text = "> 初始化网格系统\n> 加载数据矩阵\n> 准备完毕"
        statusInfo.TextColor3 = Color3.fromRGB(0, 200, 120)
        statusInfo.TextTransparency = 1
        statusInfo.TextSize = 13
        statusInfo.Font = Enum.Font.Code
        statusInfo.TextXAlignment = Enum.TextXAlignment.Left
        statusInfo.TextYAlignment = Enum.TextYAlignment.Top
        statusInfo.ZIndex = 11
        statusInfo.Parent = centerBox

        -- ===== 执行动画（8秒总时长） =====

        -- 1. 淡入背景
        bg.BackgroundTransparency = 1
        play(tw(bg, {BackgroundTransparency = 0}, 0.5))
        bgMusic:Play()
        task.wait(0.3)

        -- 2. 淡入网格
        for _, gridData in ipairs(grids) do
            play(tw(gridData.square, {BackgroundTransparency = 0.6}, 0.6))
        end
        task.wait(0.4)

        -- 3. 淡入中央框
        play(tw(centerBox, {BackgroundTransparency = 0.2}, 0.5))
        play(tw(centerStroke, {Transparency = 0}, 0.5))
        play(tw(title, {TextTransparency = 0}, 0.5))
        play(tw(statusInfo, {TextTransparency = 0}, 0.5))
        play(tw(percentText, {TextTransparency = 0}, 0.5))
        
        typeSound:Play()
        task.wait(0.5)

        -- 4. 网格崩坏动画（从中心向外扩散）
        task.spawn(function()
            local centerX = gridCountX / 2
            local centerY = gridCountY / 2
            local maxDistance = math.sqrt(centerX^2 + centerY^2)
            
            for wave = 1, 3 do
                task.wait(1.5)
                
                for _, gridData in ipairs(grids) do
                    local distX = gridData.x - centerX
                    local distY = gridData.y - centerY
                    local distance = math.sqrt(distX^2 + distY^2)
                    
                    -- 根据波浪周期崩坏
                    local waveStart = (wave - 1) * 2
                    local waveEnd = wave * 2
                    
                    if distance >= waveStart and distance <= waveEnd then
                        task.spawn(function()
                            collapseSound:Play()
                            
                            -- 崩坏效果：旋转 + 透明度变化
                            play(tw(gridData.square, {
                                BackgroundTransparency = 1,
                                Rotation = 45
                            }, 0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.In))
                            
                            task.wait(0.4)
                            
                            -- 重新恢复
                            gridData.square.Rotation = 0
                            gridData.square.BackgroundTransparency = 0.6
                        end)
                    end
                end
            end
        end)

        -- 5. 网格闪烁效果
        task.spawn(function()
            local startTime = tick()
            while tick() - startTime < 6 do
                for i = 1, #grids, 10 do
                    local gridData = grids[i]
                    if gridData then
                        play(tw(gridData.square, {BackgroundTransparency = 0.3}, 0.2, Enum.EasingStyle.Sine))
                    end
                end
                task.wait(0.3)
                for i = 1, #grids, 10 do
                    local gridData = grids[i]
                    if gridData then
                        play(tw(gridData.square, {BackgroundTransparency = 0.6}, 0.2, Enum.EasingStyle.Sine))
                    end
                end
                task.wait(0.3)
            end
        end)

        -- 6. 进度条加载 - 8秒内完成
        task.spawn(function()
            local startTime = tick()
            local duration = 7.0
            
            while true do
                local elapsed = tick() - startTime
                local progress = math.min(elapsed / duration, 1.0)
                
                play(tw(progressFill, {Size = UDim2.new(progress, 0, 1, 0)}, 0.1, Enum.EasingStyle.Linear))
                percentText.Text = math.floor(progress * 100) .. "%"
                
                if math.floor(progress * 100) % 25 == 0 then
                    typeSound:Play()
                end
                
                if progress >= 1.0 then
                    percentText.Text = "100%"
                    break
                end
                
                task.wait(0.05)
            end
        end)

        -- 等待8秒
        task.wait(8)

        -- 7. 完成动画 - 所有网格消失
        completeSound:Play()
        
        play(tw(centerBox, {BackgroundTransparency = 1}, 0.5))
        play(tw(centerStroke, {Transparency = 1}, 0.5))
        play(tw(title, {TextTransparency = 1}, 0.5))
        play(tw(statusInfo, {TextTransparency = 1}, 0.5))
        play(tw(percentText, {TextTransparency = 1}, 0.5))
        
        for _, gridData in ipairs(grids) do
            play(tw(gridData.square, {BackgroundTransparency = 1}, 0.6))
        end
        
        play(tw(bg, {BackgroundTransparency = 1}, 0.8))
        play(tw(bgMusic, {Volume = 0}, 0.5))

        task.wait(0.8)
        if gui then gui:Destroy() end
    end)

    if not ok then
        warn("网格崩坏动画加载失败：" .. tostring(err))
    end
end

WindUI:Popup({
    Title = "提示",
    Icon = "info",
    Content = "是否加载最新版本 6.78《最新》",
    Buttons = {
        {
            Title = "取消",
            Callback = function() end,
            Variant = "Tertiary",
        },
        {
            Title = "确定",
            Icon = "arrow-right",
            Callback = function() end,
            Variant = "Primary",
        }
    }
})

WindUI:Notify({
    Title = "紧急通知：TY hub正在升级",
    Content = "Notification Content example!",
    Duration = 30, -- 3 seconds
    Icon = "bird",
})

WindUI:Notify({
    Title = "欢迎使用",
    Content = "TY hun",
    Duration = 3,
    Position = "Left"
})

WindUI:Notify({
    Title = "TY hub",
    Content = "不跑路",
    Duration = 11,
})

WindUI:Notify({
    Title = "欢迎使用",
    Content = "TY hub",
    Duration = 10,
})

WindUI:Notify({
    Title = "Q 群",
    Content = "1013013485",
    Duration = 10,
})

WindUI:Popup({
    Title = "欢迎用户进入 TY脚本",
    Icon = "info",
    Content = "欢迎你游玩我们的 TY脚本😋",
    Buttons = {
        {
            Title = "我不知道",
            Callback = function() end,
            Variant = "Tertiary",
        },
        {
            Title = "我知道的",
            Icon = "arrow-right",
            Callback = function() end,
            Variant = "Primary",
        }
    }
})

WindUI:Popup({
    Title = "公告",
    Icon = "info",
    Content = "该脚本禁止倒卖作者：权威作者 QQ 号 3935754168该脚本转为付费",
    Buttons = {
        {
            Title = "我不知道",
            Callback = function() end,
            Variant = "Tertiary",
        },
        {
            Title = "我知道的",
            Icon = "arrow-right",
            Callback = function() end,
            Variant = "Primary",
        }
    }
})

local Players = game:GetService("Players")
local player = Players.LocalPlayer
local mouse = player:GetMouse()

local Main = WindUI:CreateWindow({
    Title = "<font color='#ff007f'>TY脚本</font>-<font color='#00ffff'>付费</font>",
    Author = "<font color='#00ffff'>by</font> <font color='#ff007f'>权威</font>",
    Folder = "CloudHub",
    Size = UDim2.fromOffset(300, 400),
    Transparent = true,
    Theme = "Dark",
    SideBarWidth = 200,
    Background = "video:https://raw.githubusercontent.com/xiaoxi9008/shipin/refs/heads/main/Video_1782398609786_80.mp4",
    IconThemed = true,
    ScrollBarEnabled = true,
    HideSearchBar = true,
    User = {
        Enabled = true,
        Anonymous = false,
        Callback = function() end
    }
})

Main:EditOpenButton({
    Title = "<font color='#ff007f'>TY</font><font color='#00ffff'>脚本 付费版</font>",
    Icon = "rbxassetid://127418118514722",
    CornerRadius = UDim.new(0, 8),
    StrokeThickness = 2,
    Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromHex("#ff007f")),
        ColorSequenceKeypoint.new(0.5, Color3.fromHex("#00ffff")),
        ColorSequenceKeypoint.new(1, Color3.fromHex("#ff007f"))
    })
})

Main:Tag({
    Title = "TY hub",
    Color = Color3.fromHex("#00ffff")
})

Main:Tag({
    Title = "付费",
    Color = Color3.fromHex("#ff007f")
})

local TimeTag = Main:Tag({
    Title = "当前时间: 00:00:00",
    Color = Color3.fromHex("#00ffff")
})

Main:Tag({
    Title = "脚本创建的11天",
    Color = Color3.fromHex("#ff007f")
})

local hue = 0
local running = true

task.spawn(function()
    while running do
        local now = os.date("*t")
        local hours = string.format("%02d", now.hour)
        local minutes = string.format("%02d", now.min)
        local seconds = string.format("%02d", now.sec)
        local timeString = string.format("当前时间: %s:%s:%s", hours, minutes, seconds)
        hue = (hue + 0.01) % 1
        local color = Color3.fromHSV(hue, 1, 1)
        TimeTag:SetTitle(timeString)
        TimeTag:SetColor(color)
        task.wait(0.06)
    end
end)

local TimeTag2 = Main:Tag({
    Title = "新年倒计时: --",
    Color = Color3.fromHex("#f57c00")
})

local function getNextNewYear()
    local now = os.date("*t")
    local newYear = {
        year = now.year,
        month = 1,
        day = 1,
        hour = 0,
        min = 0,
        sec = 0
    }
    if now.month > 1 or (now.month == 1 and now.day > 1) then
        newYear.year = newYear.year + 1
    end
    return os.time(newYear)
end

task.spawn(function()
    local nextNewYear = getNextNewYear()
    while true do
        local now = os.time()
        local remaining = nextNewYear - now
        if remaining <= 0 then
            nextNewYear = getNextNewYear()
            remaining = nextNewYear - now
        end
        local days = math.floor(remaining / 86400)
        remaining = remaining % 86400
        local hours = math.floor(remaining / 3600)
        remaining = remaining % 3600
        local minutes = math.floor(remaining / 60)
        local seconds = remaining % 60
        local displayText
        if days > 0 then
            displayText = string.format("新年倒计时: %d天%02d:%02d:%02d", days, hours, minutes, seconds)
        else
            displayText = string.format("新年倒计时: %02d:%02d:%02d", hours, minutes, seconds)
        end
        TimeTag2:SetTitle(displayText)
        hue = (hue + 0.01) % 1
        TimeTag2:SetColor(Color3.fromHSV(hue, 1, 1))
        task.wait(1)
    end
end)

local function ApplyNeonBorder(Window, Speed)
    Speed = Speed or 60
    local MainFrame = Window.UIElements and Window.UIElements.Main
    if not MainFrame then
        local Attempts = 0
        while not MainFrame and Attempts < 50 do
            task.wait(0.1)
            MainFrame = Window.UIElements and Window.UIElements.Main
            Attempts = Attempts + 1
        end
        if not MainFrame then return end
    end
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 12)
    Corner.Parent = MainFrame
    local Border = Instance.new("UIStroke")
    Border.Name = "NeonBorder"
    Border.Thickness = 2
    Border.Color = Color3.new(1, 1, 1)
    Border.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    Border.LineJoinMode = Enum.LineJoinMode.Round
    Border.Parent = MainFrame
    local Gradient = Instance.new("UIGradient")
    Gradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromHex("#00FFFF")),
        ColorSequenceKeypoint.new(0.5, Color3.fromHex("#FF00FF")),
        ColorSequenceKeypoint.new(1, Color3.fromHex("#00FFFF"))
    })
    Gradient.Rotation = 0
    Gradient.Parent = Border
    local Connection
    Connection = game:GetService("RunService").Heartbeat:Connect(function()
        if not Border or Border.Parent == nil then
            if Connection then Connection:Disconnect() end
            return
        end
        local Time = tick()
        Gradient.Rotation = (Time * Speed) % 360
    end)
    local OrigOnClose = Window.OnClose
    Window.OnClose = function(...)
        if Connection then Connection:Disconnect() end
        if OrigOnClose then OrigOnClose(...) end
    end
end

ApplyNeonBorder(Window, 60)

local Tab = Window:Tab({
    Title = "通用",
    Icon = "bird", -- optional
    Locked = false,
})
local Section = Tab:Section({
    Title = "通用功能《如果执行不了 请换加速器》",
    Opened = true
})
Section:Button({
    Title = "飞踢",
    Callback = function()
    
loadstring(game:HttpGet("https://rawscripts.net/raw/Universal-Script-Fe-DropKick-Script-165813"))()    
      end
})
Section:Button({
    Title = "功能全都在这里",
    Callback = function()
    
function Notify(Title1, Text1, Icon1, Time1)
  game:GetService("StarterGui"):SetCore("SendNotification", {
    Title = Title1,
    Text = Text1,
    Icon = Icon1,
    Duration = Time1,
  })
end
Notify("TY hub功能", "作者权威", "rbxassetid://17360377302", 3)
Notify("永久免费", "祝你玩的开心","rbxassetid://17360377302",3)
Notify("永久免费", "没有盈利","rbxassetid://17360377302",3)
Notify("TY hub", "永久免费","rbxassetid://17360377302",3)
Notify("拒绝跑路", "拒绝倒卖","rbxassetid://17360377302",3)
Notify("启动完成", "祝你玩的开心","rbxassetid://17360377302",5)

local Library = loadstring(game:HttpGet('https://raw.githubusercontent.com/XiaoYunCN/UWU/main/Library%2FSilent%20ui'))()
local Window = Library:new("TY hub");

local creds = Window:Tab("公告",'16060333448')
local bin = creds:section("信息",true)
local about = creds:section("作者",true)

local Main = Window:Tab("主要",'16060333448')
local General = Main:section("玩家",true)
local GX = Main:section("通用",true)
local QU = Main:section("ESP",true)
local QW = Main:section("其他",true)

local JSDGt = Window:Tab("驾驶帝国",'16060333448')
local JSDG = JSDGt:section("自动&刷钱",true)

local FMDHt = Window:Tab("伐木大亨2",'16060333448')
local FMDH = FMDHt:section("伐木大亨2",true)

local SKQSt = Window:Tab("鲨口求生2",'16060333448')
local SKQS = SKQSt:section("鲨口&求生",true)

local DoorsT = Window:Tab("doors",'16060333448')
local Doors = DoorsT:section("通用&功能",true)
local DOORSR = DoorsT:section("透视",true)
local BP = DoorsT:section("其他",true)

local LLCQt = Window:Tab("力量传奇",'16060333448')
local LLCQ = LLCQt:section("主要&功能",true)
local LLQR = LLCQt:section("自动收集",true)
local LLRQ = LLCQt:section("跑步机",true)
local LLRE = LLCQt:section("岩石",true)
local LLQQ = LLCQt:section("传送位置",true)

local JSCQt = Window:Tab("极速传奇",'16060333448')
local JSCQ = JSCQt:section("自动&玩家",true)
local JSQC = JSCQt:section("传送位置",true)

local RZCQt = Window:Tab("忍者传奇",'16060333448')
local RZCQ = RZCQt:section("自动&模式",true)
local RZQC = RZCQt:section("传送位置",true)

local JYRSt = Window:Tab("监狱人生",'16060333448')
local TLT = JYRSt:section("整合",true)
local JYRS = JYRSt:section("监狱&主要",true)
local DL = JYRSt:section("身份",true)
local DP = JYRSt:section("其他",true)
local DX = JYRSt:section("传送地点",true)

local ZDYSt = Window:Tab("战斗勇士",'16060333448')
local ZDYS = ZDYSt:section("主要",true)

local HBTXt = Window:Tab("河北唐县",'16060333448')
local HBTX = HBTXt:section("主的",true)
local HBXT = HBTXt:section("传送位置",true)

local ZRZHt = Window:Tab("自然灾害",'16060333448')
local ZRZH = ZRZHt:section("自然&灾害",true)
local RHE = ZRZHt:section("玩家",true)

local EVt = Window:Tab("Evade",'16060333448')
local EV = EVt:section("Evade",true)

local XGt = Window:Tab("新更",'16060333448')
local XG = XGt:section("新更",true)
local GN = XGt:section("实用工具",true)

local OSCt = Window:Tab("其他脚本",'16060333448')
local OSC = OSCt:section("通用脚本",true)

local SIJt = Window:Tab("视觉",'16060333448')
local SIJ = SIJt:section("视觉",true)
local GIY = SIJt:section("光影",true)

local QH = Window:Tab("俄亥俄州",'16060333448')
local QB = QH:section("自动模式",true)

local EF = Window:Tab("FE",'16060333448')
local FE = EF:section("FE",true)

local EN = Window:Tab("作者通告",'16060333448')
local NE = EN:section("玩家公告!",true)

local VT = Window:Tab("其他注入器",'16060333448')
local YV = VT:section("输入器整合",true)

local OH = Window:Tab("火箭发射模拟",'16060333448')
local HO = OH:section("主要",true)
local HQ = OH:section("传送位置",true)

local UR = Window:Tab("超级大力士",'16060333448')
local RU = UR:section("主要的",true)
local OR = UR:section("其他",true)
local QS = UR:section("位置传送",true)

local OSQ = Window:Tab("战争大亨",'16060333448')
local QOS = OSQ:section("主要",true)
local SQO = OSQ:section("其他",true)
local Tab2 = OSQ:section("传送位置",true)

bin:Label("你的用户名:"..game.Players.LocalPlayer.Name)
bin:Label("你的注入器:"..identifyexecutor())
bin:Label("服务器id:"..game.GameId)

about:Label("作者权威")
about:Label("作者qq3935754168")
about:Label("正在努力优化")
about:Label("请勿倒卖")
about:Button("复制作者QQ", function()
    setclipboard("3935754168")
end)
about:Button("复制QQ群", function()
    setclipboard("948082232")
end)
about:Toggle("移除UI辉光", "DHG", false, function(DHG)
    if DHG then
        game:GetService("CoreGui")["frosty is cute"].Main.DropShadowHolder.Visible = false
    else
        game:GetService("CoreGui")["frosty is cute"].Main.DropShadowHolder.Visible = true
    end
end)
about:Toggle("彩虹UI", "RBUI", false, function(RBUI)
    if RBUI then
        game:GetService("CoreGui")["frosty is cute"].Main.Style = "DropShadow"
    else
        game:GetService("CoreGui")["frosty is cute"].Main.Style = "Custom"
    end
end)
about:Button("摧毁界面", function()
    game:GetService("CoreGui")["frosty is cute"]:Destroy()
end)

General:Slider("步行速度!", "WalkSpeed", game.Players.LocalPlayer.Character.Humanoid.WalkSpeed, 16, 400, false, function(Speed)
  spawn(function() while task.wait() do game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = Speed end end)
end)
General:Slider("跳跃高度!", "JumpPower", game.Players.LocalPlayer.Character.Humanoid.JumpPower, 50, 400, false, function(Jump)
  spawn(function() while task.wait() do game.Players.LocalPlayer.Character.Humanoid.JumpPower = Jump end end)
end)
General:Textbox("重力设置!", "Gravity", "输入", function(Gravity)
  spawn(function() while task.wait() do game.Workspace.Gravity = Gravity end end)
end)
General:Toggle("夜视", "Light", false, function(Light)
  spawn(function() while task.wait() do if Light then game.Lighting.Ambient = Color3.new(1, 1, 1) else game.Lighting.Ambient = Color3.new(0, 0, 0) end end end)
end)
General:Button("透视", function()
  local Players = game:GetService("Players"):GetChildren() local RunService = game:GetService("RunService") local highlight = Instance.new("Highlight") highlight.Name = "Highlight" for i, v in pairs(Players) do repeat wait() until v.Character if not v.Character:FindFirstChild("HumanoidRootPart"):FindFirstChild("Highlight") then local highlightClone = highlight:Clone() highlightClone.Adornee = v.Character highlightClone.Parent = v.Character:FindFirstChild("HumanoidRootPart") highlightClone.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop highlightClone.Name = "Highlight" end end game.Players.PlayerAdded:Connect(function(player) repeat wait() until player.Character if not player.Character:FindFirstChild("HumanoidRootPart"):FindFirstChild("Highlight") then local highlightClone = highlight:Clone() highlightClone.Adornee = player.Character highlightClone.Parent = player.Character:FindFirstChild("HumanoidRootPart") highlightClone.Name = "Highlight" end end) game.Players.PlayerRemoving:Connect(function(playerRemoved) playerRemoved.Character:FindFirstChild("HumanoidRootPart").Highlight:Destroy() end) RunService.Heartbeat:Connect(function() for i, v in pairs(Players) do repeat wait() until v.Character if not v.Character:FindFirstChild("HumanoidRootPart"):FindFirstChild("Highlight") then local highlightClone = highlight:Clone() highlightClone.Adornee = v.Character highlightClone.Parent = v.Character:FindFirstChild("HumanoidRootPart") highlightClone.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop highlightClone.Name = "Highlight" task.wait() end end end)
end)
General:Button("隐身道具", function()
  loadstring(game:HttpGet("https://gist.githubusercontent.com/skid123skidlol/cd0d2dce51b3f20ad1aac941da06a1a1/raw/f58b98cce7d51e53ade94e7bb460e4f24fb7e0ff/%257BFE%257D%2520Invisible%2520Tool%2520(can%2520hold%2520tools)",true))()
end)
General:Toggle("穿墙(可用)", "NoClip", false, function(NC)
  local Workspace = game:GetService("Workspace") local Players = game:GetService("Players") if NC then Clipon = true else Clipon = false end Stepped = game:GetService("RunService").Stepped:Connect(function() if not Clipon == false then for a, b in pairs(Workspace:GetChildren()) do if b.Name == Players.LocalPlayer.Name then for i, v in pairs(Workspace[Players.LocalPlayer.Name]:GetChildren()) do if v:IsA("BasePart") then v.CanCollide = false end end end end else Stepped:Disconnect() end end)
end)

GX:Button("最强透视",function()
  loadstring(game:HttpGet("https://pastebin.com/raw/uw2P2fbY"))()
end)
GX:Button("飞行v3",function()
  loadstring(game:HttpGet'https://raw.githubusercontent.com/XNEOFF/FlyGuiV3/main/FlyGuiV3.txt')()
end)
GX:Button("甩人",function()
  loadstring(game:HttpGet("https://pastebin.com/raw/zqyDSUWX"))()
end)
GX:Button("反挂机v2",function()
  loadstring(game:HttpGet("https://pastebin.com/raw/9fFu43FF"))()
end)
GX:Button("铁拳",function()
  loadstring(game:HttpGet('https://raw.githubusercontent.com/0Ben1/fe/main/obf_rf6iQURzu1fqrytcnLBAvW34C9N55kS9g9G3CKz086rC47M6632sEd4ZZYB0AYgV.lua.txt'))()
end)
GX:Button("键盘",function()
  loadstring(game:HttpGet("https://raw.githubusercontent.com/advxzivhsjjdhxhsidifvsh/mobkeyboard/main/main.txt"))()
end)
GX:Button("动画中心",function()
  loadstring(game:HttpGet("https://raw.githubusercontent.com/GamingScripter/Animation-Hub/main/Animation%20Gui", true))()
end)
GX:Button("立即死亡",function()
  game.Players.LocalPlayer.Character.Humanoid.Health=0
end)
GX:Button("爬墙",function()
  loadstring(game:HttpGet("https://pastebin.com/raw/zXk4Rq2r"))()
end)
GX:Button("转起来",function()
  loadstring(game:HttpGet('https://pastebin.com/raw/r97d7dS0', true))()
end)
GX:Button("子弹追踪",function()
  loadstring(game:HttpGet("https://pastebin.com/raw/1AJ69eRG"))()
end)
GX:Button("飞车",function()
    loadstring(game:HttpGet("https://pastebin.com/raw/63T0fkBm"))()
end)
GX:Button("吸人",function()
    loadstring(game:HttpGet("https://shz.al/~HHAKS"))()
end)
GX:Button("无限跳跃",function()
loadstring(game:HttpGet("https://pastebin.com/raw/V5PQy3y0", true))()
end)

QU:Toggle("人物显示", "RWXS", false, function(RWXS)
    getgenv().enabled = RWXS getgenv().filluseteamcolor = true getgenv().outlineuseteamcolor = true getgenv().fillcolor = Color3.new(1, 0, 0) getgenv().outlinecolor = Color3.new(1, 1, 1) getgenv().filltrans = 0.5 getgenv().outlinetrans = 0.5 loadstring(game:HttpGet("https://raw.githubusercontent.com/Vcsk/RobloxScripts/main/Highlight-ESP.lua"))()
end)

QW:Button("死亡笔记", function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/krlpl/dfhj/main/%E6%AD%BB%E4%BA%A1%E7%AC%94%E8%AE%B0.txt"))()
end)

JSDG:Button("自动刷钱", function()
    loadstring(game:HttpGet(('https://raw.githubusercontent.com/cool83birdcarfly02six/Lightux/main/README.md'),true))()
end)

FMDH:Button("伐木大亨2", function()
  loadstring(game:HttpGet("https://raw.githubusercontent.com/frencaliber/LuaWareLoader.lw/main/luawareloader.wtf"))()
end)

SKQS:Dropdown("船只提取器", "FreeBoat", {"不知道怎么汉化", "不知道怎么汉化", "摩托艇", "摩托艇", "独角兽挺", "摩托艇", "红马林鱼", "单栀帆船", "拖船", "小船摩托艇", "摩托艇甜甜圈", "马林鱼", "管船", "渔船", "维京船", "SmallWoodenSailboat", "RedCanopyMotorboat", "Catamaran", "CombatBoat", "TourBoat", "Duckmarine", "PartyBoat", "MilitarySubmarine", "GingerbreadSteamBoat", "Sleigh2022", "Snowmobile", "CruiseShip"}, function(CS)
  game:GetService("ReplicatedStorage").EventsFolder.BoatSelection.UpdateHostBoat:FireServer(CS)
end)
SKQS:Button("自动杀鲨鱼🦈", function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/Sw1ndlerScripts/RobloxScripts/main/Misc%20Scripts/sharkbite2.lua",true))()
end)

Doors:Button("NBDoors", function()
  loadstring(game:HttpGet("https://github.com/DocYogurt/DOORS/raw/main/Loader.lua"))()
end)
Doors:Button("AND已汉化 推荐配合穿墙", function()
  loadstring(game:HttpGet("\104\116\116\112\115\58\47\47\112\97\115\116\101\98\105\110\46\99\111\109\47\114\97\119\47\54\53\84\119\84\56\106\97"))()
end)
Doors:Button("穿墙(无拉回)", function()
  loadstring(game:HttpGet("https://github.com/DXuwu/OK/raw/main/clip"))()
end)
Doors:Button("rooms自动行走", function()
  loadstring(game:HttpGet("https://raw.githubusercontent.com/DaRealGeo/roblox/master/rooms-autowalk"))()
end)
Doors:Button("十字架", function()
    loadstring(game:HttpGet("https://pastebin.com/raw/FCSyG6Th"))();
end)
Doors:Button("夜视仪", function()
    loadstring(game:HttpGet("https://pastebin.com/raw/4Vsv1Xwn"))()
end)
Doors:Button("神圣炸弹", function()
    loadstring(game:HttpGet("https://pastebin.com/raw/u5B1UjGv"))()
end)
Doors:Button("吸铁石", function()
    loadstring(game:HttpGet("https://pastebin.com/raw/xHxGDp51"))()
end)
Doors:Button("剪刀", function()
    loadstring(game:HttpGet("https://pastebin.com/raw/v2yEJYmu"))()
end)

DOORSR:Label("透视功能全部无效")

BP:Toggle("刷新时通知", "TZ", false, function(TZ)
     _G.IE = (TZ and true or false) LatestRoom.Changed:Connect(function() if _G.IE == true then local n = ChaseStart.Value - LatestRoom.Value if 0 < n and n < 4 then Notification:Notify("请注意", "事件可能刷新于" .. tostring(n) .. " 房间","rbxassetid://17360377302",3) end end end) workspace.ChildAdded:Connect(function(inst) if inst.Name == "RushMoving" and _G.IE == true then Notify("请注意", "Rush 已刷新","rbxassetid://17360377302",3) elseif inst.Name == "AmbushMoving" and _G.IE == true then Notify("请注意", "Ambush 已刷新","rbxassetid://17360377302",3) end end)
end)
BP:Toggle("自动躲避Rush/Ambush", "ADB", false, function(ADB)
    _G.Avoid = (ADB and true or false) workspace.ChildAdded:Connect(function(inst) if inst.Name == "RushMoving" and _G.Avoid == true then Notify("请注意!", "正在躲避 Rush.","rbxassetid://17360377302",3) local OldPos = game.Players.LocalPlayer.Character.HumanoidRootPart.Position local con = game:GetService("RunService").Heartbeat:Connect(function() game.Players.LocalPlayer.Character:MoveTo(OldPos + Vector3.new(0,20,0)) end) inst.Destroying:Wait() con:Disconnect() game.Players.LocalPlayer.Character:MoveTo(OldPos) elseif inst.Name == "AmbushMoving" and _G.Avoid == true then Notify("注意!", "正在躲避 Ambush.","rbxassetid://17360377302",3) local OldPos = game.Players.LocalPlayer.Character.HumanoidRootPart.Position local con = game:GetService("RunService").Heartbeat:Connect(function() game.Players.LocalPlayer.Character:MoveTo(OldPos + Vector3.new(0,20,0)) end) inst.Destroying:Wait() con:Disconnect() game.Players.LocalPlayer.Character:MoveTo(OldPos) end end)
end)
BP:Toggle("无 Screech", "NCH", false, function(NCH)
    _G.NS = (NCH and true or false) workspace.CurrentCamera.ChildAdded:Connect(function(child) if child.Name == "Screech" and _G.NS == true then child:Destroy() end end)
end)

LLCQ:Toggle("自动比赛开关", "AR", false, function(AR)
  while AR do wait() wait(2) game:GetService("ReplicatedStorage").rEvents.brawlEvent:FireServer("joinBrawl") end
end)
LLCQ:Toggle("自动举哑铃", "ATYL", false, function(ATYL)
  local part = Instance.new('Part', workspace) part.Size = Vector3.new(500, 20, 530.1) part.Position = Vector3.new(0, 100000, 133.15) part.CanCollide = true part.Anchored = true local rs = game:GetService("RunService").RenderStepped while ATYL do wait() game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = part.CFrame + Vector3.new(0, 50, 0) for i,v in pairs(game.Players.LocalPlayer.Backpack:GetChildren()) do if v.ClassName == "Tool" and v.Name == "Weight" then v.Parent = game.Players.LocalPlayer.Character end end game:GetService("Players").LocalPlayer.muscleEvent:FireServer("rep") end
end)
LLCQ:Toggle("自动俯卧撑", "ATFWC", false, function(ATFWC)
  local part = Instance.new('Part', workspace) part.Size = Vector3.new(500, 20, 530.1) part.Position = Vector3.new(0, 100000, 133.15) part.CanCollide = true part.Anchored = true local rs = game:GetService("RunService").RenderStepped while ATFWC do wait() game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = part.CFrame + Vector3.new(0, 50, 0) for i,v in pairs(game.Players.LocalPlayer.Backpack:GetChildren()) do if v.ClassName == "Tool" and v.Name == "Pushups" then v.Parent = game.Players.LocalPlayer.Character end end game:GetService("Players").LocalPlayer.muscleEvent:FireServer("rep") end
end)
LLCQ:Toggle("自动仰卧起坐", "ATYWQZ", false, function(ATYWQZ)
  local part = Instance.new('Part', workspace) part.Size = Vector3.new(500, 20, 530.1) part.Position = Vector3.new(0, 100000, 133.15) part.CanCollide = true part.Anchored = true local rs = game:GetService("RunService").RenderStepped while ATYWQZ do wait() game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = part.CFrame + Vector3.new(0, 50, 0) for i,v in pairs(game.Players.LocalPlayer.Backpack:GetChildren()) do if v.ClassName == "Tool" and v.Name == "Situps" then v.Parent = game.Players.LocalPlayer.Character end end end game:GetService("Players").LocalPlayer.muscleEvent:FireServer("rep")
end)
LLCQ:Toggle("自动倒立身体", "ATDL", false, function(ATDL)
  local part = Instance.new('Part', workspace) part.Size = Vector3.new(500, 20, 530.1) part.Position = Vector3.new(0, 100000, 133.15) part.CanCollide = true part.Anchored = true local rs = game:GetService("RunService").RenderStepped while ATDL do wait() game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = part.CFrame + Vector3.new(0, 50, 0) for i,v in pairs(game.Players.LocalPlayer.Backpack:GetChildren()) do if v.ClassName == "Tool" and v.Name == "Handstands" then v.Parent = game.Players.LocalPlayer.Character end end end game:GetService("Players").LocalPlayer.muscleEvent:FireServer("rep")
end)
LLCQ:Toggle("自动锻炼", "ATAAA", false, function(ATAAA)
  local part = Instance.new('Part', workspace) part.Size = Vector3.new(500, 20, 530.1) part.Position = Vector3.new(0, 100000, 133.15) part.CanCollide = true part.Anchored = true while ATAAA do wait() game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = part.CFrame + Vector3.new(0, 50, 0) for i, v in pairs(game.Players.LocalPlayer.Backpack:GetChildren()) do if v.ClassName == "Tool" and v.Name == "Handstands" or v.Name == "Situps" or v.Name == "Pushups" or v.Name == "Weight" then v:FindFirstChildOfClass("NumberValue").Value = 0 repeat wait() until game.Players.LocalPlayer.Backpack:FindFirstChildOfClass("Tool") game.Players.LocalPlayer.Character:WaitForChild("Humanoid"):EquipTool(v) game:GetService("Players").LocalPlayer.muscleEvent:FireServer("rep") end end end
end)

LLQR:Toggle("自动重生", "ATRE", false, function(ATRE)
  while ATRE do wait() game:GetService("ReplicatedStorage").rEvents.rebirthRemote:InvokeServer("rebirthRequest") end
end)
LLQR:Button("收集宝石", function()
  jk = {} for _, v in pairs(game:GetService("ReplicatedStorage").chestRewards:GetDescendants()) do if v.Name ~= "Light Karma Chest" or v.Name ~= "Evil Karma Chest" then table.insert(jk, v.Name) end end for i = 1, #jk do wait(2) game:GetService("ReplicatedStorage").rEvents.checkChestRemote:InvokeServer(jk[i]) end
end)

LLRQ:Toggle("沙滩跑步机10", "PPJ10", false, function(PPJ10)
    getgenv().PPJ10 = PPJ10 while getgenv().PPJ10 do wait() game.Players.LocalPlayer.Character:WaitForChild("Humanoid").WalkSpeed = 10 game.Players.LocalPlayer.Character:WaitForChild("HumanoidRootPart").CFrame = CFrame.new(238.671112, 5.40315914, 387.713165, -0.0160072874, -2.90710176e-08, -0.99987185, -3.3434191e-09, 1, -2.90212157e-08, 0.99987185, 2.87843993e-09, -0.0160072874) local oldpos = game.Players.LocalPlayer.Character:WaitForChild("HumanoidRootPart").CFrame local RunService = game:GetService("RunService") local Players = game:GetService("Players") local localPlayer = Players.LocalPlayer RunService:BindToRenderStep("move", Enum.RenderPriority.Character.Value + 1, function() if localPlayer.Character then local humanoid = localPlayer.Character:WaitForChild("Humanoid") if humanoid then humanoid:Move(Vector3.new(10000, 0, -1), true) end end end) end if not getgenv().PPJ10 then local RunService = game:GetService("RunService") local Players = game:GetService("Players") local localPlayer = Players.LocalPlayer RunService:UnbindFromRenderStep("move", Enum.RenderPriority.Character.Value + 1, function() if localPlayer.Character then local humanoid = localPlayer.Character:FindFirstChild("Humanoid") if humanoid then humanoid:Move(Vector3.new(10000, 0, -1), true) end end end) end
end)
LLRQ:Toggle("健身房跑步机2000", "PPJ2000", false, function(PPJ2000)
    if game.Players.LocalPlayer.Agility.Value >= 2000 then getgenv().PPJ2000 = PPJ2000 while getgenv().PPJ2000 do wait() game.Players.LocalPlayer.Character:WaitForChild("Humanoid").WalkSpeed = 10 game.Players.LocalPlayer.Character:WaitForChild("HumanoidRootPart").CFrame = CFrame.new(-3005.37866, 14.3221855, -464.697876, -0.015773816, -1.38508964e-08, 0.999875605, -5.13225586e-08, 1, 1.30429667e-08, -0.999875605, -5.11104332e-08, -0.015773816) local oldpos = game.Players.LocalPlayer.Character:WaitForChild("HumanoidRootPart").CFrame local RunService = game:GetService("RunService") local Players = game:GetService("Players") local localPlayer = Players.LocalPlayer RunService:BindToRenderStep("move", Enum.RenderPriority.Character.Value + 1, function() if localPlayer.Character then local humanoid = localPlayer.Character:WaitForChild("Humanoid") if humanoid then humanoid:Move(Vector3.new(10000, 0, -1), true) end end end) end end if not getgenv().PPJ2000 then local RunService = game:GetService("RunService") local Players = game:GetService("Players") local localPlayer = Players.LocalPlayer RunService:UnbindFromRenderStep("move", Enum.RenderPriority.Character.Value + 1, function() if localPlayer.Character then local humanoid = localPlayer.Character:FindFirstChild("Humanoid") if humanoid then humanoid:Move(Vector3.new(10000, 0, -1), true) end end end) end
end)
LLRQ:Toggle("神话健身房跑步机2000", "SHPPJ2000", false, function(SHPPJ2000)
    if game.Players.LocalPlayer.Agility.Value >= 2000 then getgenv().SHPPJ2000 = SHPPJ2000 while getgenv().SHPPJ2000 do wait() game.Players.LocalPlayer.Character:WaitForChild("Humanoid").WalkSpeed = 10 game.Players.LocalPlayer.Character:WaitForChild("HumanoidRootPart").CFrame = CFrame.new(2571.23706, 15.6896839, 898.650391, 0.999968231, 2.23868635e-09, -0.00797206629, -1.73198844e-09, 1, 6.35660768e-08, 0.00797206629, -6.3550246e-08, 0.999968231) local oldpos = game.Players.LocalPlayer.Character:WaitForChild("HumanoidRootPart").CFrame local RunService = game:GetService("RunService") local Players = game:GetService("Players") local localPlayer = Players.LocalPlayer RunService:BindToRenderStep("move", Enum.RenderPriority.Character.Value + 1, function() if localPlayer.Character then local humanoid = localPlayer.Character:WaitForChild("Humanoid") if humanoid then humanoid:Move(Vector3.new(10000, 0, -1), true) end end end) end end if not getgenv().SHPPJ2000 then local RunService = game:GetService("RunService") local Players = game:GetService("Players") local localPlayer = Players.LocalPlayer RunService:UnbindFromRenderStep("move", Enum.RenderPriority.Character.Value + 1, function() if localPlayer.Character then local humanoid = localPlayer.Character:FindFirstChild("Humanoid") if humanoid then humanoid:Move(Vector3.new(10000, 0, -1), true) end end end) end
end)
LLRQ:Toggle("永恒健身房跑步机3500", "YHPPJ3500", false, function(YHPPJ3500)
    if game.Players.LocalPlayer.Agility.Value >= 3500 then getgenv().YHPPJ3500 = YHPPJ3500 while getgenv().YHPPJ3500 do wait() game.Players.LocalPlayer.Character:WaitForChild("Humanoid").WalkSpeed = 10 game.Players.LocalPlayer.Character:WaitForChild("HumanoidRootPart").CFrame = CFrame.new(-7077.79102, 29.6702118, -1457.59961, -0.0322036594, -3.31122768e-10, 0.99948132, -6.44344267e-09, 1, 1.23684493e-10, -0.99948132, -6.43611742e-09, -0.0322036594) local oldpos = game.Players.LocalPlayer.Character:WaitForChild("HumanoidRootPart").CFrame local RunService = game:GetService("RunService") local Players = game:GetService("Players") local localPlayer = Players.LocalPlayer RunService:BindToRenderStep("move", Enum.RenderPriority.Character.Value + 1, function() if localPlayer.Character then local humanoid = localPlayer.Character:WaitForChild("Humanoid") if humanoid then humanoid:Move(Vector3.new(10000, 0, -1), true) end end end) end end if not getgenv().YHPPJ3500 then local RunService = game:GetService("RunService") local Players = game:GetService("Players") local localPlayer = Players.LocalPlayer RunService:UnbindFromRenderStep("move", Enum.RenderPriority.Character.Value + 1, function() if localPlayer.Character then local humanoid = localPlayer.Character:FindFirstChild("Humanoid") if humanoid then humanoid:Move(Vector3.new(10000, 0, -1), true) end end end) end
end)
LLRQ:Toggle("传奇健身房跑步机3000", "CQPPJ3000", false, function(CQPPJ3000)
    if game.Players.LocalPlayer.Agility.Value >= 3000 then getgenv().CQPPJ3000 = CQPPJ3000 while getgenv().CQPPJ3000 do wait() game.Players.LocalPlayer.Character:WaitForChild("Humanoid").WalkSpeed = 10 game.Players.LocalPlayer.Character:WaitForChild("HumanoidRootPart").CFrame = CFrame.new(4370.82812, 999.358704, -3621.42773, -0.960604727, -8.41949266e-09, -0.27791819, -6.12478646e-09, 1, -9.12496567e-09, 0.27791819, -7.06329528e-09, -0.960604727) local oldpos = game.Players.LocalPlayer.Character:WaitForChild("HumanoidRootPart").CFrame local RunService = game:GetService("RunService") local Players = game:GetService("Players") local localPlayer = Players.LocalPlayer RunService:BindToRenderStep("move", Enum.RenderPriority.Character.Value + 1, function() if localPlayer.Character then local humanoid = localPlayer.Character:WaitForChild("Humanoid") if humanoid then humanoid:Move(Vector3.new(10000, 0, -1), true) end end end) end end if not getgenv().CQPPJ3000 then local RunService = game:GetService("RunService") local Players = game:GetService("Players") local localPlayer = Players.LocalPlayer RunService:UnbindFromRenderStep("move", Enum.RenderPriority.Character.Value + 1, function() if localPlayer.Character then local humanoid = localPlayer.Character:FindFirstChild("Humanoid") if humanoid then humanoid:Move(Vector3.new(10000, 0, -1), true) end end end) end
end)

LLRE:Toggle("石头0", "RK0", false, function(RK0)
    getgenv().RK0 = RK0 while getgenv().RK0 do wait() for i,v in pairs(game.Players.LocalPlayer.Backpack:GetChildren()) do if v:IsA("Tool") and v.Name == "Punch" then game.Players.LocalPlayer.Character:WaitForChild("Humanoid"):EquipTool(v) end end for i,h in pairs(game.Players.LocalPlayer.Character:GetChildren()) do if h:IsA("Tool") and h.Name == "Punch" then h:Activate() end end game.Players.LocalPlayer.Character:WaitForChild("HumanoidRootPart").CFrame = CFrame.new(7.60643005, 4.02632904, 2104.54004, -0.23040159, -8.53662385e-08, -0.973095655, -4.68743764e-08, 1, -7.66279342e-08, 0.973095655, 2.79580536e-08, -0.23040159) end if not getgenv().RK0 then game.Players.LocalPlayer.Character:WaitForChild("Humanoid"):UnequipTools() end
end)
LLRE:Toggle("石头10", "RK10", false, function(RK10)
    if game.Players.LocalPlayer.Durability.Value >= 10 then getgenv().RK10 = RK10 while getgenv().RK10 do wait() for i,v in pairs(game.Players.LocalPlayer.Backpack:GetChildren()) do if v:IsA("Tool") and v.Name == "Punch" then game.Players.LocalPlayer.Character:WaitForChild("Humanoid"):EquipTool(v) end end for i,h in pairs(game.Players.LocalPlayer.Character:GetChildren()) do if h:IsA("Tool") and h.Name == "Punch" then h:Activate() end end game.Players.LocalPlayer.Character:WaitForChild("HumanoidRootPart").CFrame = CFrame.new(-157.680908, 3.72453046, 434.871185, 0.923298299, -1.81774684e-09, -0.384083599, 3.45247031e-09, 1, 3.56670582e-09, 0.384083599, -4.61917082e-09, 0.923298299) end if not getgenv().RK10 then game.Players.LocalPlayer.Character:WaitForChild("Humanoid"):UnequipTools() end end
end)
LLRE:Toggle("石头100", "RK100", false, function(RK100)
    if game.Players.LocalPlayer.Durability.Value >= 100 then getgenv().RK100 = RK100 while getgenv().RK100 do wait() for i,v in pairs(game.Players.LocalPlayer.Backpack:GetChildren()) do if v:IsA("Tool") and v.Name == "Punch" then game.Players.LocalPlayer.Character:WaitForChild("Humanoid"):EquipTool(v) end end for i,h in pairs(game.Players.LocalPlayer.Character:GetChildren()) do if h:IsA("Tool") and h.Name == "Punch" then h:Activate() end end game.Players.LocalPlayer.Character:WaitForChild("HumanoidRootPart").CFrame = CFrame.new(162.233673, 3.66615629, -164.686783, -0.921312928, -1.80826774e-07, -0.38882193, -9.13036544e-08, 1, -2.48719346e-07, 0.38882193, -1.93647494e-07, -0.921312928) end if not getgenv().RK100 then game.Players.LocalPlayer.Character:WaitForChild("Humanoid"):UnequipTools() end end
end)
LLRE:Toggle("石头5000", "RK5000", false, function(RK5000)
    if game.Players.LocalPlayer.Durability.Value >= 5000 then getgenv().RK5000 = RK5000 while getgenv().RK5000 do wait() for i,v in pairs(game.Players.LocalPlayer.Backpack:GetChildren()) do if v:IsA("Tool") and v.Name == "Punch" then game.Players.LocalPlayer.Character:WaitForChild("Humanoid"):EquipTool(v) end end for i,h in pairs(game.Players.LocalPlayer.Character:GetChildren()) do if h:IsA("Tool") and h.Name == "Punch" then h:Activate() end end game.Players.LocalPlayer.Character:WaitForChild("HumanoidRootPart").CFrame = CFrame.new(329.831482, 3.66450214, -618.48407, -0.806075394, -8.67358096e-08, 0.591812849, -1.05715522e-07, 1, 2.57029176e-09, -0.591812849, -6.04919563e-08, -0.806075394) end if not getgenv().RK5000 then game.Players.LocalPlayer.Character:WaitForChild("Humanoid"):UnequipTools() end end
end)
LLRE:Toggle("石头150000", "RK150000", false, function(RK150000)
    if game.Players.LocalPlayer.Durability.Value >= 150000 then getgenv().RK150000 = RK150000 while getgenv().RK150000 do wait() for i,v in pairs(game.Players.LocalPlayer.Backpack:GetChildren()) do if v:IsA("Tool") and v.Name == "Punch" then game.Players.LocalPlayer.Character:WaitForChild("Humanoid"):EquipTool(v) end end for i,h in pairs(game.Players.LocalPlayer.Character:GetChildren()) do if h:IsA("Tool") and h.Name == "Punch" then h:Activate() end end game.Players.LocalPlayer.Character:WaitForChild("HumanoidRootPart").CFrame = CFrame.new(-2566.78076, 3.97019577, -277.503235, -0.923934579, -4.11600105e-08, -0.382550538, -3.38838042e-08, 1, -2.57576183e-08, 0.382550538, -1.08360858e-08, -0.923934579) end if not getgenv().RK150000 then game.Players.LocalPlayer.Character:WaitForChild("Humanoid"):UnequipTools() end end
end)
LLRE:Toggle("石头400000", "RK400000", false, function(RK400000)
    if game.Players.LocalPlayer.Durability.Value >= 400000 then getgenv().RK400000 = RK400000 while getgenv().RK400000 do wait() for i,v in pairs(game.Players.LocalPlayer.Backpack:GetChildren()) do if v:IsA("Tool") and v.Name == "Punch" then game.Players.LocalPlayer.Character:WaitForChild("Humanoid"):EquipTool(v) end end for i,h in pairs(game.Players.LocalPlayer.Character:GetChildren()) do if h:IsA("Tool") and h.Name == "Punch" then h:Activate() end end game.Players.LocalPlayer.Character:WaitForChild("HumanoidRootPart").CFrame = CFrame.new(2155.61743, 3.79830337, 1227.06482, -0.551303148, -9.16796949e-09, -0.834304988, -5.61318245e-08, 1, 2.61027839e-08, 0.834304988, 6.12216127e-08, -0.551303148) end if not getgenv().RK400000 then game.Players.LocalPlayer.Character:WaitForChild("Humanoid"):UnequipTools() end end
end)
LLRE:Toggle("石头750000", "RK750000", false, function(RK750000)
    if game.Players.LocalPlayer.Durability.Value >= 750000 then getgenv().RK750000 = RK750000 while getgenv().RK750000 do wait() for i,v in pairs(game.Players.LocalPlayer.Backpack:GetChildren()) do if v:IsA("Tool") and v.Name == "Punch" then game.Players.LocalPlayer.Character:WaitForChild("Humanoid"):EquipTool(v) end end for i,h in pairs(game.Players.LocalPlayer.Character:GetChildren()) do if h:IsA("Tool") and h.Name == "Punch" then h:Activate() end end game.Players.LocalPlayer.Character:WaitForChild("HumanoidRootPart").CFrame = CFrame.new(-7285.6499, 3.66624784, -1228.27417, 0.857643783, -1.58175091e-08, -0.514244199, -1.22581563e-08, 1, -5.12025977e-08, 0.514244199, 5.02172774e-08, 0.857643783) end if not getgenv().RK750000 then game.Players.LocalPlayer.Character:WaitForChild("Humanoid"):UnequipTools() end end
end)
LLRE:Toggle("石头100万", "RK1M", false, function(RK1M)
    if game.Players.LocalPlayer.Durability.Value >= 1000000 then getgenv().RK1M = RK1M while getgenv().RK1M do wait() for i,v in pairs(game.Players.LocalPlayer.Backpack:GetChildren()) do if v:IsA("Tool") and v.Name == "Punch" then game.Players.LocalPlayer.Character:WaitForChild("Humanoid"):EquipTool(v) end end for i,h in pairs(game.Players.LocalPlayer.Character:GetChildren()) do if h:IsA("Tool") and h.Name == "Punch" then h:Activate() end end game.Players.LocalPlayer.Character:WaitForChild("HumanoidRootPart").CFrame = CFrame.new(4160.87109, 987.829102, -4136.64502, -0.893115997, 1.25481356e-05, 0.44982639, 5.02490684e-06, 1, -1.79187136e-05, -0.44982639, -1.37431543e-05, -0.893115997) end if not getgenv().RK1M then game.Players.LocalPlayer.Character:WaitForChild("Humanoid"):UnequipTools() end end
end)
LLRE:Toggle("石头500万", "RK5M", false, function(RK5M)
    if game.Players.LocalPlayer.Durability.Value >= 5000000 then getgenv().RK5M = RK5M while getgenv().RK5M do wait() for i,v in pairs(game.Players.LocalPlayer.Backpack:GetChildren()) do if v:IsA("Tool") and v.Name == "Punch" then game.Players.LocalPlayer.Character:WaitForChild("Humanoid"):EquipTool(v) end end for i,h in pairs(game.Players.LocalPlayer.Character:GetChildren()) do if h:IsA("Tool") and h.Name == "Punch" then h:Activate() end end game.Players.LocalPlayer.Character:WaitForChild("HumanoidRootPart").CFrame = CFrame.new(-8957.54395, 5.53625107, -6126.90186, -0.803919137, 6.6065212e-08, 0.594738603, -8.93136143e-09, 1, -1.23155459e-07, -0.594738603, -1.04318865e-07, -0.803919137) end if not getgenv().RK5M then game.Players.LocalPlayer.Character:WaitForChild("Humanoid"):UnequipTools() end end
end)

LLQQ:Toggle("X-安全地方", "TP-PLACE", false, function(Place)
  if Place then getgenv().place = true while getgenv().place do wait() game.Players.LocalPlayer.Character:WaitForChild("HumanoidRootPart").CFrame = CFrame.new(-51.6716728, 32.2157211, 1290.41211, 0.9945544, 1.23613528e-08, -0.104218982, -7.58742402e-09, 1, 4.62031657e-08, 0.104218982, -4.51608102e-08, 0.9945544) end else getgenv().place = false wait() game.Players.LocalPlayer.Character:WaitForChild("HumanoidRootPart").CFrame = CFrame.new(-34.1635208, 3.67689133, 219.640869, 0.599920511, -2.24152163e-09, 0.800059617, 4.46125981e-09, 1, -5.43559087e-10, -0.800059617, 3.89536625e-09, 0.599920511) end
end)
LLQQ:Button("传送到出生点", function()
  game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(7, 3, 108)
end)
LLQQ:Button("传送到冰霜健身房", function()
  game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(-2543, 13, -410)
end)
LLCQ:Button("传送到神话健身房", function()
  game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(2177, 13, 1070)
end)
LLQQ:Button("传送到永恒健身房", function()
  game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(-6686, 13, -1284)
end)
LLQQ:Button("传送到传说健身房", function()
  game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(4676, 997, -3915)
end)
LLQQ:Button("传送到肌肉之王健身房", function()
  game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(-8554, 22, -5642)
end)
LLQQ:Button("传送到安全岛", function()
  game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(-39, 10, 1838)
end)
LLQQ:Button("传送到幸运抽奖区域", function()
  game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(-2606, -2, 5753)
end)

JSCQ:Toggle("自动重生", "ARS", false, function(ARS)
    if ARS then _G.loop = true while _G.loop == true do wait() game:GetService("ReplicatedStorage").rEvents.rebirthEvent:FireServer("rebirthRequest") end else _G.loop = false end
end)
JSCQ:Button("自动重生和自动刷等级", function()
    loadstring(game:HttpGet("https://pastebin.com/raw/T9wTL150"))()
end)
JSCQ:Button("反踢出", function()
    local vu = game:GetService("VirtualUser") game:GetService("Players").LocalPlayer.Idled:connect(function() vu:Button2Down(Vector2.new(0,0),workspace.CurrentCamera.CFrame) wait(1) vu:Button2Up(Vector2.new(0,0),workspace.CurrentCamera.CFrame) end)
end)

JSQC:Button("城市", function()
    game.Players.LocalPlayer.Character:MoveTo(Vector3.new(-559.2, -7.45058e-08, 417.4))
end)
JSQC:Button("雪城", function()
    game.Players.LocalPlayer.Character:MoveTo(Vector3.new(-858.358, 0.5, 2170.35))
end)
JSQC:Button("岩浆城", function()
    game.Players.LocalPlayer.Character:MoveTo(Vector3.new(1707.25, 0.550008, 4331.05))
end)
JSQC:Button("公路传奇", function()
    game.Players.LocalPlayer.Character:MoveTo(Vector3.new(3594.68, 214.804, 7274.56))
end)

RZCQ:Toggle("自动挥舞", "ATHW", false, function(ATHW)
    if v or not ATHW then getgenv().autoswing = ATHW while true do if not getgenv().autoswing then return end for _,v in pairs(game.Players.LocalPlayer.Backpack:GetChildren()) do if v:FindFirstChild("ninjitsuGain") then game.Players.LocalPlayer.Character.Humanoid:EquipTool(v) break end end local A_1 = "swingKatana" local Event = game:GetService("Players").LocalPlayer.ninjaEvent:FireServer(A_1) wait() end end
end)
RZCQ:Toggle("自动售卖", "ATSELL", false, function(ATSELL)
    getgenv().autosell = ATSELL while true do if not getgenv().autosell then return end game:GetService("Workspace").sellAreaCircles["sellAreaCircle16"].circleInner.CFrame = game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame wait(0.1) game:GetService("Workspace").sellAreaCircles["sellAreaCircle16"].circleInner.CFrame = CFrame.new(0,0,0) wait(0.1) end
end)
RZCQ:Toggle("自动购买排名", "ATBP", false, function(ATBP)
    getgenv().autobuyranks = ATBP while true do if not getgenv().autobuyranks then return end local deku1 = "buyRank" for i = 1, #ranks do game:GetService("Players").LocalPlayer.ninjaEvent:FireServer(deku1, ranks[i]) end wait(0.1) end
end)
RZCQ:Toggle("自动购买腰带", "ATBYD", false, function(ATBYD)
    getgenv().autobuybelts = ATBYD while true do if not getgenv().autobuybelts then return end local A_1 = "buyAllBelts" local A_2 = "Inner Peace Island" local Event = game:GetService("Players").LocalPlayer.ninjaEvent Event:FireServer(A_1, A_2) wait(0.5) end
end)
RZCQ:Toggle("自动购买技能", "ATB", false, function(ATB)
    getgenv().autobuyskills = ATB while true do if not getgenv().autobuyskills then return end local A_1 = "buyAllSkills" local A_2 = "Inner Peace Island" local Event = game:GetService("Players").LocalPlayer.ninjaEvent Event:FireServer(A_1, A_2) wait(0.5) end
end)
RZCQ:Toggle("自动购买剑", "ATBS", false, function(ATBS)
    getgenv().autobuy = ATBS while true do if not getgenv().autobuy then return end local A_1 = "buyAllSwords" local A_2 = "Inner Peace Island" local Event = game:GetService("Players").LocalPlayer.ninjaEvent Event:FireServer(A_1, A_2) wait(0.5) end
end)
RZCQ:Button("解锁所有岛", function()
  for _, v in next, game.workspace.islandUnlockParts:GetChildren() do if v then game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = v.islandSignPart.CFrame wait(.5) end end
end)

RZQC:Button("传送到出生点", function()
  game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(25.665502548217773, 3.4228405952453613, 29.919952392578125)
end)
RZQC:Button("传送到附魔岛", function()
  game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(51.17238235473633, 766.1807861328125, -138.44842529296875)
end)
RZQC:Button("传送到神秘岛", function()
  game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(171.97178649902344, 4047.380859375, 42.0699577331543)
end)
RZQC:Button("传送到太空岛", function()
  game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(148.83824157714844, 5657.18505859375, 73.5014877319336)
end)
RZQC:Button("传送到冻土岛", function()
  game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(139.28330993652344, 9285.18359375, 77.36406707763672)
end)
RZQC:Button("传送到永恒岛", function()
  game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(149.34817504882812, 13680.037109375, 73.3861312866211)
end)
RZQC:Button("传送到沙暴岛", function()
  game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(133.37144470214844, 17686.328125, 72.00334167480469)
end)
RZQC:Button("传送到雷暴岛", function()
  game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(143.19349670410156, 24070.021484375, 78.05432891845703)
end)
RZQC:Button("传送到远古炼狱岛", function()
  game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(141.27163696289062, 28256.294921875, 69.3790283203125)
end)
RZQC:Button("传送到午夜暗影岛", function()
  game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(132.74267578125, 33206.98046875, 57.495574951171875)
end)
RZQC:Button("传送到神秘灵魂岛", function()
  game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(137.76148986816406, 39317.5703125, 61.06639862060547)
end)
RZQC:Button("传送到冬季奇迹岛", function()
  game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(137.2720184326172, 46010.5546875, 55.941951751708984)
end)
RZQC:Button("传送到黄金大师岛", function()
  game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(128.32339477539062, 52607.765625, 56.69411849975586)
end)
RZQC:Button("传送到龙传奇岛", function()
  game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(146.35226440429688, 59594.6796875, 77.53300476074219)
end)
RZQC:Button("传送到赛博传奇岛", function()
  game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(137.3321075439453, 66669.1640625, 72.21722412109375)
end)
RZQC:Button("传送到天岚超能岛", function()
  game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(135.48077392578125, 70271.15625, 57.02311325073242)
end)
RZQC:Button("传送到混沌传奇岛", function()
  game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(148.58590698242188, 74442.8515625, 69.3177719116211)
end)
RZQC:Button("传送到混沌传奇岛", function()
  game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(148.58590698242188, 74442.8515625, 69.3177719116211)
end)
RZQC:Button("传送到灵魂融合岛", function()
  game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(136.9700927734375, 79746.984375, 58.54051971435547)
end)
RZQC:Button("传送到黑暗元素岛", function()
  game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(141.697265625, 83198.984375, 72.73107147216797)
end)
RZQC:Button("传送到内心和平岛", function()
  game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(135.3157501220703, 87051.0625, 66.78429412841797)
end)
RZQC:Button("传送到炽烈漩涡岛", function()
  game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(135.08216857910156, 91246.0703125, 69.56692504882812)
end)
RZQC:Button("传送到35倍金币区域", function()
  game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(86.2938232421875, 91245.765625, 120.54232788085938)
end)
RZQC:Button("传送到死亡宠物", function()
  game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(4593.21337890625, 130.87181091308594, 1430.2239990234375)
end)

TLT:Button("落叶监狱人生", function()
    loadstring(game:HttpGet("https://pastebin.com/raw/uDs9bhc8"))()
end)

JYRS:Button("无敌模式", function()
  loadstring(game:HttpGet("https://pastebin.com/raw/LdTVujTA"))()
end)
JYRS:Button("杀死所有人", function()
  loadstring(game:HttpGet("https://pastebin.com/raw/kXjfpFPh"))()
end)
JYRS:Button("手里剑（秒杀）", function()
  loadstring(game:HttpGet("https://pastebin.com/raw/mSLiAZHk"))()
end)
JYRS:Button("变钢铁侠", function()
  loadstring(game:HttpGet("https://pastebin.com/raw/7prijqYH"))()
end)
JYRS:Button("变死神", function()
  loadstring(game:HttpGet("https://pastebin.com/ewv9bbRp"))()
end)
JYRS:Button("变车模型", function()
  loadstring(game:HttpGet("https://pastebin.com/raw/zLe3e4BS"))()
end)

DL:Button("变成警察", function()
    workspace.Remote.TeamEvent:FireServer("Bright blue");
end)
DL:Button("变成囚犯", function()
    workspace.Remote.TeamEvent:FireServer("Bright orange");
end)

DP:Toggle("杀死光环", "SSGH", false, function(SSGH)
    States.KillAura = SSGH if state then print("Kill Aura On") CreateKillPart() else print("Kill Aura Off") if Parts[1] and Parts[1].Name == "KillAura" then Parts[1]:Destroy() Parts[1] = nil end end end) function CreateKillPart() if Parts[1] then pcall(function() Parts[1]:Destroy() end) Parts[1] = nil end local Part = Instance.new("Part",plr.Character) local hilight = Instance.new("Highlight",Part) hilight.FillTransparency = 1 Part.Anchored = true Part.CanCollide = false Part.CanTouch = false Part.Material = Enum.Material.SmoothPlastic Part.Transparency = .98 Part.Material = Enum.Material.SmoothPlastic Part.BrickColor = BrickColor.White() Part.Size = Vector3.new(20,2,20) Part.Name = "KillAura" Parts[1] = Part end task.spawn(function() repeat task.wait()until plr.Character and char and char:FindFirstChildOfClass("Humanoid") if States.KillAura then CreateKillPart() end end) game:GetService("RunService").Stepped:Connect(function() if States.KillAura then for i,v in pairs(game.Players:GetPlayers()) do if v ~= game.Players.LocalPlayer then if (v.Character.HumanoidRootPart.Position - plr.Character.HumanoidRootPart.Position).magnitude <14 and v.Character.Humanoid.Health >0 then local args = {[1] = v} for i =1,2 do task.spawn(function() game:GetService("ReplicatedStorage").meleeEvent:FireServer(unpack(args)) end) end end end end end
end)

DX:Button("传送警卫室", function()
  game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(847.7261352539062, 98.95999908447266, 2267.387451171875)
end)
DX:Button("传送监狱室内", function()
  game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(919.2575073242188, 98.95999908447266, 2379.74169921875)
end)
DX:Button("传送罪犯复活点", function()
  game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(-937.5891723632812, 93.09876251220703, 2063.031982421875)
end)
DX:Button("传送监狱室外", function()
  game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(760.6033325195312, 96.96992492675781, 2475.405029296875)
end)
DX:Button("传送院子", function()
  game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(788.5759887695312, 97.99992370605469, 2455.056640625)
end)
DX:Button("传送警车库", function()
  game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(602.7301635742188, 98.20000457763672, 2503.56982421875)
end)
DX:Button("传送死人下水道", function()
  game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(917.4256591796875, 78.69828033447266, 2416.18359375)
end)
DX:Button("传送食堂", function()
  game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(921.0059204101562, 99.98993682861328, 2289.23095703125)
end)

ZDYS:Button("弓箭爆头", function()
    loadstring(game:HttpGet("https://pastebin.com/raw/6RQGbFqD"))()
end)

HBTX:Label("请成成为快递员，才能自动刷钱")
HBTX:Toggle("自动刷钱", "AM", false, function(AM)
    local virtualUser = game:GetService('VirtualUser') virtualUser:CaptureController() function teleportTo(CFrame) game:GetService("Players").LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame end _G.autoFarm = false function autoFarm() while _G.autoFarm do fireclickdetector(game:GetService("Workspace").DeliverySys.Misc["Package Pile"].ClickDetector) task.wait(2.2) for _,point in pairs(game:GetService("Workspace").DeliverySys.DeliveryPoints:GetChildren()) do if point.Locate.Locate.Enabled then teleportTo(point.CFrame) end end task.wait(0) end end
end)
HBXT:Button("传送到警察局", function()
  game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(-5513.97412109375, 8.656171798706055, 4964.291015625)
end)
HBXT:Button("传送到出生点", function()
  game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(-3338.31982421875, 10.048742294311523, 3741.84033203125)
end)
HBXT:Button("传送到医院", function()
  game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(-5471.482421875, 14.149418830871582, 4259.75341796875)
end)
HBXT:Button("传送到手机店", function()
  game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(-6789.2041015625, 11.197686195373535, 1762.687255859375)
end)
HBXT:Button("传送到火锅店", function()
  game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(-5912.84765625, 12.217276573181152, 1058.29443359375)
end)

ZRZH:Toggle("在水上行走", "AHJ", false, function(AHJ)
  if AHJ == false then game.Workspace.WaterLevel.CanCollide = false game.Workspace.WaterLevel.Size = Vector3.new(10, 1, 10) end if AHJ == true then game.Workspace.WaterLevel.CanCollide = true game.Workspace.WaterLevel.Size = Vector3.new(5000, 1, 5000) end
end)
ZRZH:Toggle("自动禁用掉落伤害", "AJH", false, function(AJH)
  _G.NoFallDamage = AJH; while wait(0.5) do if _G.NoFallDamage == true then local FallDamageScript = (game.Players.LocalPlayer.Character ~= nil) and game.Players.LocalPlayer.Character:FindFirstChild("FallDamageScript") or nil if FallDamageScript then FallDamageScript:Destroy() end end end
end)

RHE:Button("传送到地图", function()
    game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(-115.828506, 65.4863434, 18.8461514, 0.00697017973, 0.0789371505, -0.996855199, -3.13589936e-07, 0.996879458, 0.0789390653, 0.999975681, -0.000549906865, 0.00694845384)
end)
RHE:Button("游戏岛", function()
    game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(-83.5, 38.5, -27.5, -1, 0, 0, 0, 1, 0, 0, 0, -1)
end)
RHE:Toggle("预测灾害", "YCZN", false, function(YCZN)
    nextdis = YCZN while wait(1) and nextdis do local SurvivalTag = plr.Character:FindFirstChild("SurvivalTag") if SurvivalTag then if SurvivalTag.Value == "Blizzard" and nextdis then Message.Visible = true Message.Text = "下一个灾难是：暴风雪" elseif SurvivalTag.Value == "Sandstorm" and nextdis then Message.Visible = true Message.Text = "下一个灾难是：沙尘暴" elseif SurvivalTag.Value == "Tornado" and nextdis then Message.Visible = true Message.Text = "下一个灾难是：龙卷风" elseif SurvivalTag.Value == "Volcanic Eruption" and nextdis then Message.Visible = true Message.Text = "下一个灾难是：火山" elseif SurvivalTag.Value == "Flash Flood" and nextdis then Message.Visible = true Message.Text = "下一个灾难是：洪水" elseif SurvivalTag.Value == "Deadly Virus" and nextdis then Message.Visible = true Message.Text = "下一个灾难是：病毒" elseif SurvivalTag.Value == "Tsunami" and nextdis then Message.Visible = true Message.Text = "下一个灾难是：海啸" elseif SurvivalTag.Value == "Acid Rain" and nextdis then Message.Visible = true Message.Text = "下一个灾难是：酸雨" elseif SurvivalTag.Value == "Fire" and nextdis then Message.Visible = true Message.Text = "下一个灾难是：火焰" elseif SurvivalTag.Value == "Meteor Shower" and nextdis then Message.Visible = true Message.Text = "下一个灾难是：流星雨" elseif SurvivalTag.Value == "Earthquake" and nextdis then Message.Visible = true Message.Text = "下一个灾难是：地震" elseif SurvivalTag.Value == "Thunder Storm" and nextdis then Message.Visible = true Message.Text = "下一个灾难是：暴风雨" else Message.Visible = false end end end
end)
RHE:Toggle("地图投票用户界面", "Map Voting UI", false, function(MapUI)
    if MapUI == false then game.Players.LocalPlayer.PlayerGui.MainGui.MapVotePage.Visible = false end if MapUI == true then game.Players.LocalPlayer.PlayerGui.MainGui.MapVotePage.Visible = true end
end)
RHE:Button("获取气球", function()
    plyr = game.Players.LocalPlayer char = plyr.Character torso = char.Torso mouse = plyr:GetMouse() Run = game:service'RunService' deb = game:service'Debris' ra = char["Right Arm"] la = char["Left Arm"] rs = char.Torso["Right Shoulder"] ls = char.Torso["Left Shoulder"] local platform = false local idle = true iliketrains = {} part1 = Instance.new("Part", char) part1.FormFactor = "Symmetric" part1.Size = Vector3.new(1, 3, 1) part1.TopSurface = 0 part1.BottomSurface = 0 part1:BreakJoints() special = Instance.new("SpecialMesh", part1) special.MeshId = "http://www.roblox.com/asset/?id=25498565" special.TextureId = "http://www.roblox.com/asset/?id=26725707" special.Scale = Vector3.new(2, 2, 2) w = Instance.new("Weld", char) w.Part0 = part1 w.Part1 = torso w.C0 = CFrame.new(-0.4, -1.4, -0.5) * CFrame.Angles(-0.5, 0, 0.2) part2 = Instance.new("Part", char) part2.FormFactor = "Symmetric" part2.Size = Vector3.new(1, 3, 1) part2.TopSurface = 0 part2.BottomSurface = 0 part2:BreakJoints() special2 = Instance.new("SpecialMesh", part2) special2.MeshId = "http://www.roblox.com/asset/?id=25498565" special2.TextureId = "http://www.roblox.com/asset/?id=26725707" special2.Scale = Vector3.new(2, 2, 2) w2 = Instance.new("Weld", char) w2.Part0 = part2 w2.Part1 = torso w2.C0 = CFrame.new(0.4, -1.4, -0.5) * CFrame.Angles(-0.5, 0, -0.2) tool = Instance.new("HopperBin", plyr.Backpack) tool.Name = " " tool.TextureId = "http://www.roblox.com/asset/?id=27471616" tool.Selected:connect(function(mouse) mouse.Button1Down:connect(function(mouse) if equipped then return end equipped = true coroutine.wrap(function() while equipped do rs.DesiredAngle = 0 rs.CurrentAngle = 0 ls.DesiredAngle = 0 ls.CurrentAngle = 0 Run.Stepped:wait() end end)() coroutine.wrap(function() idle = false coroutine.wrap(function() for i = 0, 3 do w.C0 = w.C0 * CFrame.new(0, 0.05, 0) w2.C0 = w2.C0 * CFrame.new(0, 0.05, 0) Run.Stepped:wait() end wait(0.147) for i = 0, 3 do w.C0 = w.C0 * CFrame.new(0, -0.05, 0) w2.C0 = w2.C0 * CFrame.new(0, -0.05, 0) Run.Stepped:wait() end end)() local p = Instance.new("Part", char) p.FormFactor = "Custom" p.Name = "Platform" p.Transparency = 1 p.Size = Vector3.new(4, 1, 4) p.Anchored = true for i = 2.5, 6, 0.05 do p.CFrame = CFrame.new(torso.CFrame.x, torso.CFrame.y-i, torso.CFrame.z) Run.Stepped:wait() end coroutine.wrap(function() p:Destroy() end)() end)() for i = 0, 4 do ls.C0 = ls.C0 * CFrame.Angles(-0.25, 0, 0) rs.C0 = rs.C0 * CFrame.Angles(-0.25, 0, 0) Run.Stepped:wait() end wait(0.02) for i = 0, 4 do ls.C0 = ls.C0 * CFrame.Angles(0.25, 0, 0) rs.C0 = rs.C0 * CFrame.Angles(0.25, 0, 0) Run.Stepped:wait() end idle = true equipped = false end) end) while idle do for i = 0, 3 do w.C0 = w.C0 * CFrame.Angles(0, 0.002 * i, 0) w2.C0 = w2.C0 * CFrame.Angles(0, -0.002 * i, 0) Run.Stepped:wait() end wait(0.112687) for i = 0, 3 do w.C0 = w.C0 * CFrame.Angles(0, -0.002 * i, 0) w2.C0 = w2.C0 * CFrame.Angles(0, 0.002 * i, 0) Run.Stepped:wait() end wait(0.312687) end
end)

EV:Button("Evade脚本1", function()
  loadstring(game:HttpGet("https://raw.githubusercontent.com/GamingScripter/Darkrai-X/main/Games/Evade"))()
end)
EV:Button("Evade脚本2", function()
  loadstring(game:HttpGet('https://raw.githubusercontent.com/9Strew/roblox/main/gamescripts/evade.lua'))()
end)

XG:Button("显示FPS", function()
  local FpsGui = Instance.new("ScreenGui") local FpsXS = Instance.new("TextLabel") FpsGui.Name = "FPSGui" FpsGui.ResetOnSpawn = false FpsGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling FpsXS.Name = "FpsXS" FpsXS.Size = UDim2.new(0, 100, 0, 50) FpsXS.Position = UDim2.new(0, 10, 0, 10) FpsXS.BackgroundTransparency = 1 FpsXS.Font = Enum.Font.SourceSansBold FpsXS.Text = "FPS: 0" FpsXS.TextSize = 20 FpsXS.TextColor3 = Color3.new(1, 1, 1) FpsXS.Parent = FpsGui function updateFpsXS() local fps = math.floor(1 / game:GetService("RunService").RenderStepped:Wait()) FpsXS.Text = "FPS: " .. fps end game:GetService("RunService").RenderStepped:Connect(updateFpsXS) FpsGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
end)
XG:Button("自瞄", function()
  loadstring(game:HttpGet("https://pastebin.com/raw/1Gp9c57U"))()
end)
XG:Button("范围", function()
    _G.HeadSize = 20 _G.Disabled = true game:GetService('RunService').RenderStepped:connect(function() if _G.Disabled then for i,v in next, game:GetService('Players'):GetPlayers() do if v.Name ~= game:GetService('Players').LocalPlayer.Name then pcall(function() v.Character.HumanoidRootPart.Size = Vector3.new(_G.HeadSize,_G.HeadSize,_G.HeadSize) v.Character.HumanoidRootPart.Transparency = 0.7 v.Character.HumanoidRootPart.BrickColor = BrickColor.new("Really blue") v.Character.HumanoidRootPart.Material = "Neon" v.Character.HumanoidRootPart.CanCollide = false end) end end end end)
end)
XG:Button("iw指令", function()
  loadstring(game:HttpGet(('https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source'),true))()
end)
XG:Button("操b脚本", function()
  local SimpleSexGUI = Instance.new("ScreenGui") local FGUI = Instance.new("Frame") local btnNaked = Instance.new("TextButton") local btnSex = Instance.new("TextButton") local tbxVictim = Instance.new("TextBox") local lblFUCKEMALL = Instance.new("TextLabel") local ImageLabel = Instance.new("ImageLabel") local lbltitle = Instance.new("TextLabel") local TextLabel = Instance.new("TextLabel") SimpleSexGUI.Name = "SimpleSexGUI" SimpleSexGUI.Parent = game.CoreGui FGUI.Name = "FGUI" FGUI.Parent = SimpleSexGUI FGUI.BackgroundColor3 = Color3.new(255,255,255) FGUI.BorderSizePixel = 1 FGUI.Position = UDim2.new(0,0, 0.667, 0) FGUI.Size = UDim2.new(0,317, 0,271) FGUI.Draggable = true lbltitle.Name = "Title" lbltitle.Parent = FGUI lbltitle.BackgroundColor3 = Color3.new(255,255,255) lbltitle.BorderSizePixel = 1 lbltitle.Position = UDim2.new (0, 0,-0.122, 0) lbltitle.Size = UDim2.new (0, 317,0, 33) lbltitle.Visible = true lbltitle.Active = true lbltitle.Draggable = false lbltitle.Selectable = true lbltitle.Font = Enum.Font.SourceSansBold lbltitle.Text = "一个简单的操蛋脚本!!" lbltitle.TextColor3 = Color3.new(0, 0, 0) lbltitle.TextSize = 20 btnSex.Name = "Sex" btnSex.Parent = FGUI btnSex.BackgroundColor3 = Color3.new(255,255,255) btnSex.BorderSizePixel = 1 btnSex.Position = UDim2.new (0.044, 0,0.229, 0) btnSex.Size = UDim2.new (0, 99,0, 31) btnSex.Visible = true btnSex.Active = true btnSex.Draggable = false btnSex.Selectable = true btnSex.Font = Enum.Font.SourceSansBold btnSex.Text = "让我们操蛋吧!!" btnSex.TextColor3 = Color3.new(0, 0, 0) btnSex.TextSize = 20 tbxVictim.Name = "VictimTEXT" tbxVictim.Parent = FGUI tbxVictim.BackgroundColor3 = Color3.new(255,255,255) tbxVictim.BorderSizePixel = 1 tbxVictim.Position = UDim2.new (0.533, 0,0.229, 0) tbxVictim.Size = UDim2.new (0, 133,0, 27) tbxVictim.Visible = true tbxVictim.Active = true tbxVictim.Draggable = false tbxVictim.Selectable = true tbxVictim.Font = Enum.Font.SourceSansBold tbxVictim.Text = "名字" tbxVictim.TextColor3 = Color3.new(0, 0, 0) tbxVictim.TextSize = 20 lblFUCKEMALL.Name = "FUCKEMALL" lblFUCKEMALL.Parent = FGUI lblFUCKEMALL.BackgroundColor3 = Color3.new(255,255,255) lblFUCKEMALL.BorderSizePixel = 1 lblFUCKEMALL.Position = UDim2.new (0.025, 0,0.856, 0) lblFUCKEMALL.Size = UDim2.new (0, 301,0, 27) lblFUCKEMALL.Visible = true lblFUCKEMALL.Font = Enum.Font.SourceSansBold lblFUCKEMALL.Text = "操蛋和操蛋" lblFUCKEMALL.TextColor3 = Color3.new(0, 0, 0) lblFUCKEMALL.TextSize = 20 ImageLabel.Name = "ImageLabel" ImageLabel.Parent = FGUI ImageLabel.Image = "http://www.roblox.com/asset/?id=42837..." ImageLabel.BorderSizePixel = 1 ImageLabel.Position = UDim2.new (0.274, 0,0.358, 0) ImageLabel.Size = UDim2.new (0, 106,0, 121) btnSex.MouseButton1Click:Connect(function() local player = tbxVictim.Text local stupid = Instance.new('Animation') stupid.AnimationId = 'rbxassetid://148840371' hummy = game:GetService("Players").LocalPlayer.Character.Humanoid pcall(function() hummy.Parent.Pants:Destroy() end) pcall(function() hummy.Parent.Shirt:Destroy() end) local notfunny = hummy:LoadAnimation(stupid) notfunny:Play() notfunny:AdjustSpeed(10) while hummy.Parent.Parent ~= nil do wait() game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = game.Players[tbxVictim.Text].Character.HumanoidRootPart.CFrame end end)
end)
XG:Button("情云同款", function()
    local fov = 100 local RunService = game:GetService("RunService") local UserInputService = game:GetService("UserInputService") local Players = game:GetService("Players") local Cam = game.Workspace.CurrentCamera local FOVring = Drawing.new("Circle") FOVring.Visible = true FOVring.Thickness = 2 FOVring.Color = Color3.fromRGB(0, 0, 0) FOVring.Filled = false FOVring.Radius = fov FOVring.Position = Cam.ViewportSize / 2 local function updateDrawings() local camViewportSize = Cam.ViewportSize FOVring.Position = camViewportSize / 2 end local function onKeyDown(input) if input.KeyCode == Enum.KeyCode.Delete then RunService:UnbindFromRenderStep("FOVUpdate") FOVring:Remove() end end UserInputService.InputBegan:Connect(onKeyDown) local function lookAt(target) local lookVector = (target - Cam.CFrame.Position).unit local newCFrame = CFrame.new(Cam.CFrame.Position, Cam.CFrame.Position + lookVector) Cam.CFrame = newCFrame end local function getClosestPlayerInFOV(trg_part) local nearest = nil local last = math.huge local playerMousePos = Cam.ViewportSize / 2 for _, player in ipairs(Players:GetPlayers()) do if player ~= Players.LocalPlayer then local part = player.Character and player.Character:FindFirstChild(trg_part) if part then local ePos, isVisible = Cam:WorldToViewportPoint(part.Position) local distance = (Vector2.new(ePos.x, ePos.y) - playerMousePos).Magnitude if distance < last and isVisible and distance < fov then last = distance nearest = player end end end end return nearest end RunService.RenderStepped:Connect(function() updateDrawings() local closest = getClosestPlayerInFOV("Head") if closest and closest.Character:FindFirstChild("Head") then lookAt(closest.Character.Head.Position) end end)
end)
XG:Button("情云同款自瞄可调", function()
  local fov = 100 local smoothness = 10 local crosshairDistance = 5 local RunService = game:GetService("RunService") local UserInputService = game:GetService("UserInputService") local Players = game:GetService("Players") local Cam = game.Workspace.CurrentCamera local FOVring = Drawing.new("Circle") FOVring.Visible = true FOVring.Thickness = 2 FOVring.Color = Color3.fromRGB(0, 255, 0) FOVring.Filled = false FOVring.Radius = fov FOVring.Position = Cam.ViewportSize / 2 local Player = Players.LocalPlayer local PlayerGui = Player:WaitForChild("PlayerGui") local ScreenGui = Instance.new("ScreenGui") ScreenGui.Name = "FovAdjustGui" ScreenGui.Parent = PlayerGui local Frame = Instance.new("Frame") Frame.Name = "MainFrame" Frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30) Frame.BorderColor3 = Color3.fromRGB(128, 0, 128) Frame.BorderSizePixel = 2 Frame.Position = UDim2.new(0.3, 0, 0.3, 0) Frame.Size = UDim2.new(0.4, 0, 0.4, 0) Frame.Active = true Frame.Draggable = true Frame.Parent = ScreenGui local MinimizeButton = Instance.new("TextButton") MinimizeButton.Name = "MinimizeButton" MinimizeButton.Text = "-" MinimizeButton.TextColor3 = Color3.fromRGB(255, 255, 255) MinimizeButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50) MinimizeButton.Position = UDim2.new(0.9, 0, 0, 0) MinimizeButton.Size = UDim2.new(0.1, 0, 0.1, 0) MinimizeButton.Parent = Frame local isMinimized = false MinimizeButton.MouseButton1Click:Connect(function() isMinimized = not isMinimized if isMinimized then Frame:TweenSize(UDim2.new(0.1, 0, 0.1, 0), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.3, true) MinimizeButton.Text = "+" else Frame:TweenSize(UDim2.new(0.4, 0, 0.4, 0), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.3, true) MinimizeButton.Text = "-" end end) local FovLabel = Instance.new("TextLabel") FovLabel.Name = "FovLabel" FovLabel.Text = "自瞄范围" FovLabel.TextColor3 = Color3.fromRGB(255, 255, 255) FovLabel.BackgroundTransparency = 1 FovLabel.Position = UDim2.new(0.1, 0, 0.1, 0) FovLabel.Size = UDim2.new(0.8, 0, 0.2, 0) FovLabel.Parent = Frame local FovSlider = Instance.new("TextBox") FovSlider.Name = "FovSlider" FovSlider.Text = tostring(fov) FovSlider.TextColor3 = Color3.fromRGB(255, 255, 255) FovSlider.BackgroundColor3 = Color3.fromRGB(50, 50, 50) FovSlider.Position = UDim2.new(0.1, 0, 0.3, 0) FovSlider.Size = UDim2.new(0.8, 0, 0.2, 0) FovSlider.Parent = Frame local SmoothnessLabel = Instance.new("TextLabel") SmoothnessLabel.Name = "SmoothnessLabel" SmoothnessLabel.Text = "自瞄平滑度" SmoothnessLabel.TextColor3 = Color3.fromRGB(255, 255, 255) SmoothnessLabel.BackgroundTransparency = 1 SmoothnessLabel.Position = UDim2.new(0.1, 0, 0.5, 0) SmoothnessLabel.Size = UDim2.new(0.8, 0, 0.2, 0) SmoothnessLabel.Parent = Frame local SmoothnessSlider = Instance.new("TextBox") SmoothnessSlider.Name = "SmoothnessSlider" SmoothnessSlider.Text = tostring(smoothness) SmoothnessSlider.TextColor3 = Color3.fromRGB(255, 255, 255) SmoothnessSlider.BackgroundColor3 = Color3.fromRGB(50, 50, 50) SmoothnessSlider.Position = UDim2.new(0.1, 0, 0.7, 0) SmoothnessSlider.Size = UDim2.new(0.8, 0, 0.2, 0) SmoothnessSlider.Parent = Frame local CrosshairDistanceLabel = Instance.new("TextLabel") CrosshairDistanceLabel.Name = "CrosshairDistanceLabel" CrosshairDistanceLabel.Text = "自瞄预判距离" CrosshairDistanceLabel.TextColor3 = Color3.fromRGB(255, 255, 255) CrosshairDistanceLabel.BackgroundTransparency = 1 CrosshairDistanceLabel.Position = UDim2.new(0.1, 0, 0.9, 0) CrosshairDistanceLabel.Size = UDim2.new(0.8, 0, 0.2, 0) CrosshairDistanceLabel.Parent = Frame local CrosshairDistanceSlider = Instance.new("TextBox") CrosshairDistanceSlider.Name = "CrosshairDistanceSlider" CrosshairDistanceSlider.Text = tostring(crosshairDistance) CrosshairDistanceSlider.TextColor3 = Color3.fromRGB(255, 255, 255) CrosshairDistanceSlider.BackgroundColor3 = Color3.fromRGB(50, 50, 50) CrosshairDistanceSlider.Position = UDim2.new(0.1, 0, 1.1, 0) CrosshairDistanceSlider.Size = UDim2.new(0.8, 0, 0.2, 0) CrosshairDistanceSlider.Parent = Frame local targetCFrame = Cam.CFrame local function updateDrawings() local camViewportSize = Cam.ViewportSize FOVring.Position = camViewportSize / 2 FOVring.Radius = fov end local function onKeyDown(input) if input.KeyCode == Enum.KeyCode.Delete then RunService:UnbindFromRenderStep("FOVUpdate") FOVring:Remove() end end UserInputService.InputBegan:Connect(onKeyDown) local function getClosestPlayerInFOV(trg_part) local nearest = nil local last = math.huge local playerMousePos = Cam.ViewportSize / 2 for _, player in ipairs(Players:GetPlayers()) do if player ~= Players.LocalPlayer then local part = player.Character and player.Character:FindFirstChild(trg_part) if part then local ePos, isVisible = Cam:WorldToViewportPoint(part.Position) local distance = (Vector2.new(ePos.x, ePos.y) - playerMousePos).Magnitude if distance < last and isVisible and distance < fov then last = distance nearest = player end end end end return nearest end RunService.RenderStepped:Connect(function() updateDrawings() local closest = getClosestPlayerInFOV("Head") if closest and closest.Character:FindFirstChild("Head") then local targetCharacter = closest.Character local targetHead = targetCharacter.Head local targetRootPart = targetCharacter:FindFirstChild("HumanoidRootPart") local isMoving = targetRootPart.Velocity.Magnitude > 0.1 local targetPosition if isMoving then targetPosition = targetHead.Position + (targetHead.CFrame.LookVector * crosshairDistance) else targetPosition = targetHead.Position end targetCFrame = CFrame.new(Cam.CFrame.Position, targetPosition) else targetCFrame = Cam.CFrame end Cam.CFrame = Cam.CFrame:Lerp(targetCFrame, 1 / smoothness) end) FovSlider.FocusLost:Connect(function(enterPressed, inputThatCausedFocusLoss) if enterPressed then local newFov = tonumber(FovSlider.Text) if newFov then fov = newFov else FovSlider.Text = tostring(fov) end end end) SmoothnessSlider.FocusLost:Connect(function(enterPressed, inputThatCausedFocusLoss) if enterPressed then local newSmoothness = tonumber(SmoothnessSlider.Text) if newSmoothness then smoothness = newSmoothness else SmoothnessSlider.Text = tostring(smoothness) end end end) CrosshairDistanceSlider.FocusLost:Connect(function(enterPressed, inputThatCausedFocusLoss) if enterPressed then local newCrosshairDistance = tonumber(CrosshairDistanceSlider.Text) if newCrosshairDistance then crosshairDistance = newCrosshairDistance else CrosshairDistanceSlider.Text = tostring(crosshairDistance) end end end)
end)
XG:Button("玩家加入通知", function()
    game.Players.ChildAdded:Connect(function(player) local success, errorMessage = pcall(function() Notify("玩家加入", player.Name .. " 加入了游戏", "rbxassetid://17360377302", 5) end) if not success then print("Error: " .. errorMessage) end end) game.Players.ChildRemoved:Connect(function(player) local success, errorMessage = pcall(function() Notify("玩家离开", player.Name .. " 离开了游戏", "rbxassetid://17360377302", 5) end) if not success then print("Error: " .. errorMessage) end end)
end)

GN:Button("工具包", function()
   loadstring(game:HttpGet("https://cdn.wearedevs.net/scripts/BTools.txt"))()
end)
GN:Button("F3X", function()
   loadstring(game:GetObjects("rbxassetid://6695644299")[1].Source)()
end)
GN:Button("保存游戏", function()
    saveinstance()
end)
GN:Button("离开游戏", function()
    game:Shutdown()
end)

OSC:Button("小凌脚本", function()
    XiaoLing = "小凌中心.Cocoe" loadstring(game:HttpGet("https://raw.githubusercontent.com/flyspeed7/Xiao-Ling-NEO.UI/main/%E2%82%AA%E5%B0%8F%E5%87%8C%E4%B8%AD%E5%BF%83(%E6%96%B0%E7%89%88ui).txt"))("小凌中心")("作者QQ:1211373508")
end)
OSC:Button("导管中心", function()
    loadstring("\108\111\97\100\115\116\114\105\110\103\40\103\97\109\101\58\72\116\116\112\71\101\116\40\34\104\116\116\112\115\58\47\47\114\97\119\46\103\105\116\104\117\98\117\115\101\114\99\111\110\116\101\110\116\46\99\111\109\47\117\115\101\114\97\110\101\119\114\102\102\47\114\111\98\108\111\120\45\47\109\97\105\110\47\37\69\54\37\57\68\37\65\49\37\69\54\37\65\67\37\66\69\37\69\53\37\56\68\37\56\70\37\69\56\37\65\69\37\65\69\34\41\41\40\41\10")()
end)
OSC:Button("云中心", function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/XiaoYunCN/Cloud-script/main/%E4%BA%91%E4%B8%AD%E5%BF%83CLOUD-HUB.lua", true))()
end)
OSC:Button("XSC卡密x", function()
    getgenv().XC="作者XC"loadstring(game:HttpGet("https://pastebin.com/raw/PAFzYx0F"))()
end)
OSC:Button("情云", function()
    loadstring(utf8.char((function() return table.unpack({108,111,97,100,115,116,114,105,110,103,40,103,97,109,101,58,72,116,116,112,71,101,116,40,34,104,116,116,112,115,58,47,47,114,97,119,46,103,105,116,104,117,98,117,115,101,114,99,111,110,116,101,110,116,46,99,111,109,47,67,104,105,110,97,81,89,47,45,47,109,97,105,110,47,37,69,54,37,56,51,37,56,53,37,69,52,37,66,65,37,57,49,46,108,117,97,34,41,41,40,41})end)()))()
end)
OSC:Button("星空脚本", function()
loadstring(game:HttpGet("https://raw.githubusercontent.com/XiaoYunCN/UWU/main/%E5%85%B6%E4%BB%96%E5%9B%BD%E5%86%85%E8%84%9A%E6%9C%AC/%E6%98%9F%E7%A9%BA%E8%84%9A%E6%9C%AC/MoonSecV3.lua"))()
end)
OSC:Button("林脚本", function()
    lin = "作者林"lin ="林QQ群 747623342"loadstring(game:HttpGet("https://raw.githubusercontent.com/linnblin/lin/main/lin"))()
end)
OSC:Button("k1s脚本", function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/krlpl/dkdjdj/main/%E6%B7%B7%E6%B7%86.txt"))()
end)
OSC:Button("丁丁脚本", function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/dingding123hhh/vvbnn/main/%E4%B8%81%E4%B8%81%E8%84%9A%E6%9C%AC%E9%98%89%E5%89%B2.txt"))()
end)
OSC:Button("剑客V4修复版", function()
    jianke_V4 = "作者_初夏" jianke__V4 = "作者QQ1412152634" jianke___V4 = "剑客QQ群347724155" loadstring(game:HttpGet(('https://raw.githubusercontent.com/JianKeCX/JianKeV4/main/ChuXia')))()
end)
OSC:Button("呱鸡脚本", function()
    loadstring(game:HttpGet("https://pastebin.com/raw/MRgmQkUy", true))()
end)
OSC:Button("☁云脚本☁", function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/XiaoYunCN/LOL/main/%E4%BA%91%E8%84%9A%E6%9C%ACCloud%20script.lua", true))() 
end)
OSC:Button("鲨脚本", function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/sharksharksharkshark/shark-shark-shark-shark-shark/main/shark-scriptlollol.txt",true))() 
end)
OSC:Button("冰脚本", function()
    loadstring(game:HttpGet("https://pastebin.com/raw/GR4ChWKv"))() 
end)
OSC:Button("河流脚本", function()
    loadstring(game:HttpGet("\104\116\116\112\115\58\47\47\112\97\115\116\101\98\105\110\46\99\111\109\47\114\97\119\47\77\50\57\77\117\81\115\80"))()
end)
OSC:Button("BS脚本（偷云脚本）", function()
    loadstring(game:HttpGet(utf8.char((function() return table.unpack({104,116,116,112,115,58,47,47,112,97,115,116,101,98,105,110,46,99,111,109,47,114,97,119,47,71,57,103,117,122,88,100,75})end)())))()--BS
end)
OSC:Button("地岩脚本", function()
     loadstring("\108\111\97\100\115\116\114\105\110\103\40\103\97\109\101\58\72\116\116\112\71\101\116\40\34\104\116\116\112\115\58\47\47\114\97\119\46\103\105\116\104\117\98\117\115\101\114\99\111\110\116\101\110\116\46\99\111\109\47\98\98\97\109\120\98\98\97\109\120\98\98\97\109\120\47\99\111\100\101\115\112\97\99\101\115\45\98\108\97\110\107\47\109\97\105\110\47\37\69\55\37\57\57\37\66\68\34\41\41\40\41")()
end)
OSC:Button("波奇塔脚本", function()
    loadstring(game:HttpGet(utf8.char((function() return table.unpack({104,116,116,112,115,58,47,47,112,97,115,116,101,98,105,110,46,99,111,109,47,114,97,119,47,113,109,55,76,121,119,82,117})end)())))()
end)
OSC:Button("皇脚本", function()
    loadstring(game:HttpGet("\104\116\116\112\115\58\47\47\112\97\115\116\101\98\105\110\46\99\111\109\47\114\97\119\47\80\100\84\55\99\65\82\84"))()
end)
OSC:Button("青脚本", function()
    loadstring(game:HttpGet("https://rentry.co/cyq78/raw"))()
end)

SIJ:Button("动态模糊", function()
    local camera = workspace.CurrentCamera local blurAmount = 10 local blurAmplifier = 5 local lastVector = camera.CFrame.LookVector local motionBlur = Instance.new("BlurEffect", camera) local runService = game:GetService("RunService") workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function() local camera = workspace.CurrentCamera if motionBlur and motionBlur.Parent then motionBlur.Parent = camera else motionBlur = Instance.new("BlurEffect", camera) end end) runService.Heartbeat:Connect(function(deltaTime) local magnitude = (camera.CFrame.LookVector - lastVector).Magnitude motionBlur.Size = math.abs(magnitude) * blurAmount * blurAmplifier / 2 lastVector = camera.CFrame.LookVector end)
end)

GIY:Button("光影", function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/MZEEN2424/Graphics/main/Graphics.xml"))()
end)
GIY:Button("光影滤镜", function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/MZEEN2424/Graphics/main/Graphics.xml"))()
end)
GIY:Button("RTX高仿", function()
    loadstring(game:HttpGet('https://pastebin.com/raw/Bkf0BJb3'))()
end)
GIY:Button("超高画质", function()
    loadstring(game:HttpGet("https://pastebin.com/raw/jHBfJYmS"))()
end)
GIY:Button("光影v4", function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/MZEEN2424/Graphics/main/Graphics.xml"))()
end)
GIY:Button("光影深", function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/MZEEN2424/Graphics/main/Graphics.xml"))()
end)
GIY:Button("光影浅", function()
    loadstring(game:HttpGet("https://pastebin.com/raw/jHBfJYmS"))()
end)

function GetItems() local cache = {} for i,v in pairs(game:GetService("Workspace").Game.Entities.CashBundle:GetChildren()) do table.insert(cache,v) end for i,v in pairs(game:GetService("Workspace").Game.Entities.ItemPickup:GetChildren()) do table.insert(cache,v) end return cache end
function Collect(item) if item:FindFirstChildOfClass("ClickDetector") then fireclickdetector(item:FindFirstChildOfClass("ClickDetector")) elseif item:FindFirstChildOfClass("Part") then local maincrap = item:FindFirstChildOfClass("Part") fireclickdetector(maincrap:FindFirstChildOfClass("ClickDetector")) end end
ItemFarmFunc = function() while ItemFarm and task.wait() do local allitems = GetItems() for i,v in pairs(allitems) do if ItemFarm == false then break end pcall(function() game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = v:FindFirstChildOfClass("Part").CFrame task.wait(0.5) Collect(v) task.wait(0.5) end) end end end
QB:Toggle("自动捡垃圾", "SJXJ", false, function(SJXJ)
    ItemFarm = SJXJ if ItemFarm then pcall(function() ItemFarmFunc() end) end
end)

FE:Button("FE C00lgui", function()
    loadstring(game:GetObjects("rbxassetid://8127297852")[1].Source)()
end)
FE:Button("FE 1x1x1x1", function()
    loadstring(game:HttpGet(('https://pastebin.com/raw/JipYNCht'),true))()
end)
FE:Button("FE大长腿", function()
    loadstring(game:HttpGet('https://gist.githubusercontent.com/1BlueCat/7291747e9f093555573e027621f08d6e/raw/23b48f2463942befe19d81aa8a06e3222996242c/FE%2520Da%2520Feets'))()
end)
FE:Button("FE用头", function()
    loadstring(game:HttpGet("https://pastebin.com/raw/BK4Q0DfU"))()
end)
FE:Button("复仇者", function()
    loadstring(game:HttpGet(('https://pastefy.ga/iGyVaTvs/raw'),true))()
end)
FE:Button("鼠标", function()
    loadstring(game:HttpGet(('https://pastefy.ga/V75mqzaz/raw'),true))()
end)
FE:Button("变怪物", function()
    loadstring(game:HttpGetAsync("https://pastebin.com/raw/jfryBKds"))()
end)
FE:Button("香蕉枪", function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/MrNeRD0/Doors-Hack/main/BananaGunByNerd.lua"))()
end)
FE:Button("超长🐔巴", function()
    loadstring(game:HttpGet("https://pastebin.com/raw/ESWSFND7", true))()
end)
FE:Button("操人", function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/XiaoYunCN/UWU/main/AHAJAJAKAK/A/A/A/A/A/A/A/A/A/A/A/A/A/A/A/A/A/A/A/A/A/A/A/A/A/A/A/A/A/A/A/A/A/A/A/A/A/A/A/A/A/A/A/A/A/A/A/A/A/A/A/A/A/A.LUA", true))()
end)
FE:Button("FE动画中心", function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/GamingScripter/Animation-Hub/main/Animation%20Gui", true))()
end)
FE:Button("FE变玩家", function()
    loadstring(game:HttpGet("https://pastebin.com/raw/XR4sGcgJ"))()
end)
FE:Button("FE猫娘R63", function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/Tescalus/Pendulum-Hubs-Source/main/Pendulum%20Hub%20V5.lua"))()
end)
FE:Button("FE", function()
    loadstring(game:HttpGet('https://pastefy.ga/a7RTi4un/raw'))()
end)

NE:Label("整个脚本")
NE:Label("是我一个人写的")
NE:Label("当然也不要喷")
NE:Label("免费的已经够良心了")
NE:Label("但是功能不太多")
NE:Label("但是该有的一个也不少")
NE:Label("那些无脑的人")
NE:Label("不要喷我")
NE:Label("谢谢您")
NE:Label("使用了我的脚本")

YV:Button("syn", function()
   loadstring(game:HttpGet("https://pastebin.com/raw/tWGxhNq0"))()
end)
YV:Button("syn2", function()
   loadstring(game:HttpGet("https://raw.githubusercontent.com/AZYsGithub/Chillz-s-scripts/main/Synapse-X-Remake.lua"))()
end)
YV:Button("阿尔宙斯V3", function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/AZYsGithub/chillz-workshop/main/Arceus%20X%20V3"))()
end)

HO:Toggle("自动收集燃料", "ARL", false, function(ARL)
    isFuelScoopEnabled = ARL while true do wait() if isFuelScoopEnabled then for i, h in pairs(game.Players.LocalPlayer.Character:GetChildren()) do if h:IsA("Tool") and h.Name == "FuelScoop" then h:Activate() end end end end
end)
HO:Button("登上火箭", function()
    game:GetService("ReplicatedStorage"):WaitForChild("BoardRocket"):FireServer()
end)
HO:Button("将玩家从所有者座位移除", function()
    game:GetService("ReplicatedStorage"):WaitForChild("RemovePlayer"):FireServer()
end)

HQ:Button("发射台岛", function()
    game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(-123.15931701660156, 2.7371432781219482, 3.491959810256958)
end)
HQ:Button("白云岛", function()
    game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(-76.13252258300781, 170.55825805664062, -60.4516716003418)
end)
HQ:Button("浮漂岛", function()
    game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(-66.51714324951172, 720.4866333007812, -5.391753196716309)
end)
HQ:Button("卫星岛", function()
    game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(-34.2462043762207, 1429.4990234375, 1.3739361763000488)
end)
HQ:Button("蜜蜂迷宫岛", function()
    game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(6.5361199378967285, 3131.249267578125, -29.759048461914062)
end)
HQ:Button("月球人救援", function()
    game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(-7.212917804718018, 5016.341796875, -19.815933227539062)
end)
HQ:Button("暗物质岛", function()
    game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(68.43186950683594, 6851.94091796875, 7.890637397766113)
end)
HQ:Button("太空岩石岛", function()
    game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(49.92888641357422, 8942.955078125, 8.674375534057617)
end)
HQ:Button("零号火星岛", function()
    game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(54.44503402709961, 11270.0927734375, -1.273137092590332)
end)
HQ:Button("太空水晶小行星岛", function()
    game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(-11.579089164733887, 15295.6318359375, -27.54974365234375)
end)
HQ:Button("月球浆果岛", function()
    game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(-14.601255416870117, 18410.9609375, 0.9418511986732483)
end)
HQ:Button("铺路石岛", function()
    game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(-3.272758960723877, 22539.494140625, 63.283935546875)
end)
HQ:Button("流星岛", function()
    game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(-45.515689849853516, 27961.560546875, -7.358333110809326)
end)
HQ:Button("升级岛", function()
    game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(-2.7595248222351074, 33959.98828125, 53.93095397949219)
end)

RU:Toggle("自动锻炼", "ADDL", false, function(ADDL)
    _G.On2 = ADDL HumanoidRootPart.CFrame = CFrame.new(-79.9094696, 19.8263607, 8124.82129, 1, 0, 0, 0, 1, 0, 0, 0, 1) HumanoidRootPart.Anchored = false wait(0.1) task_defer(function() game.RunService.RenderStepped:connect(function() if _G.On2 then workspace.Gravity = math.huge HumanoidRootPart.CFrame = CFrame.new(-79.9094696, 19.8263607, 8124.82129, 1, 0, 0, 0, 1, 0, 0, 0, 1) fireproximityprompt(_G.Prox, 0) else workspace.Gravity = 196.2 end end) end)
end)
RU:Toggle("自动强度", "AQQD", false, function(AQQD)
    _G.auto = AQQD if _G.auto then pcall(function() game:GetService("CoreGui").PurchasePromptApp.Enabled = false end) task_defer(autoworkout) else pcall(function() game:GetService("CoreGui").PurchasePromptApp.Enabled = true end) end
end)
RU:Toggle("删除购买提示", "DBY", false, function(DBY)
    _G.Value = DBY if _G.value then game:GetService("CoreGui").PurchasePromptApp.Enabled = false else _G.Value = value game:GetService("CoreGui").PurchasePromptApp.Enabled = true end
end)

OR:Button("获取所有勋章", function()
    GetBadges()
end)

QS:Button("传送到开始区域", function()
    game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(85.86943817138672, 11.751949310302734, -198.07127380371094)
end)
QS:Button("传送到健身区域", function()
    game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(93.60747528076172, 11.751947402954102, -10.266206741333008)
end)
QS:Button("传送到食物区域", function()
    game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(78.86384582519531, 11.751947402954102, 228.9690399169922)
end)
QS:Button("传送到街机区域", function()
    game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(88.99887084960938, 11.751949310302734, 502.90997314453125)
end)
QS:Button("传送到农场区域", function()
    game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(85.6707763671875, 11.751947402954102, 788.5997314453125)
end)
QS:Button("传送到城堡区域", function()
    game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(84.87281036376953, 11.84177017211914, 1139.7509765625)
end)
QS:Button("传送到蒸汽朋克区域", function()
    game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(92.63227081298828, 11.841767311096191, 1692.7890625)
end)
QS:Button("传送到迪斯科区域", function()
    game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(98.69613647460938, 16.015085220336914, 2505.213134765625)
end)
QS:Button("传送到太空区域", function()
    game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(88.42948150634766, 11.841769218444824, 3425.941650390625)
end)
QS:Button("传送到糖果区域", function()
    game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(63.55805969238281, 11.841663360595703, 4340.69921875)
end)
QS:Button("送到实验室区域", function()
    game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(78.00920867919922, 11.841663360595703, 5226.60205078125)
end)
QS:Button("传送到热带区域", function()
    game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(80.26090240478516, 12.0902681350708, 6016.16552734375)
end)
QS:Button("传送到恐龙区域", function()
    game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(38.4753303527832, 25.801530838012695, 6937.779296875)
end)
QS:Button("传送到复古区域", function()
    game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(99.81867218017578, 12.89099407196045, 7901.74755859375)
end)
QS:Button("传送到冬季区域", function()
    game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(63.47243881225586, 11.841662406921387, 8983.810546875)
end)
QS:Button("传送到深海区域", function()
    game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(105.36250305175781, 26.44820213317871, 9970.0849609375)
end)
QS:Button("传送到狂野西部区域", function()
    game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(68.69414520263672, 15.108586311340332, 10938.654296875)
end)
QS:Button("传送到豪华公寓区域", function()
    game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(86.75145721435547, 11.313281059265137, 12130.349609375)
end)
QS:Button("传送到宝剑战斗区域", function()
    game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(111.25597381591797, 11.408829689025879, 12945.57421875)
end)
QS:Button("传送到童话区域", function()
    game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(121.14932250976562, 11.313281059265137, 14034.50390625)
end)
QS:Button("传送到桃花区域", function()
    game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(108.2142333984375, 11.813281059265137, 15131.861328125)
end)
QS:Button("传送到厨房区域", function()
    game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(135.78338623046875, 21.76291847229004, 16204.9755859375)
end)
QS:Button("传送到下水道区域", function()
    game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(47.36086654663086, 12.25178050994873, 17656.04296875)
end)

QOS:Button("查看游戏中的所有玩家（包括血量条）", function()
    assert(Drawing, "missing dependency: 'Drawing'") local Players = game:GetService("Players") local RunService = game:GetService("RunService") local localPlayer = Players.LocalPlayer local camera = workspace.CurrentCamera local cache = {} local BOX_OUTLINE_COLOR = Color3.new(0, 0, 0) local BOX_COLOR = Color3.new(1, 0, 0) local NAME_COLOR = Color3.new(1, 1, 1) local HEALTH_OUTLINE_COLOR = Color3.new(0, 0, 0) local HEALTH_HIGH_COLOR = Color3.new(0, 1, 0) local HEALTH_LOW_COLOR = Color3.new(1, 0, 0) local CHAR_SIZE = Vector2.new(4, 6) local function create(class, properties) local drawing = Drawing.new(class) for property, value in pairs(properties) do drawing[property] = value end return drawing end local function floor2(v) return Vector2.new(math.floor(v.X), math.floor(v.Y)) end local function createEsp(player) local esp = {} esp.boxOutline = create("Square", {Color = BOX_OUTLINE_COLOR, Thickness = 3, Filled = false}) esp.box = create("Square", {Color = BOX_COLOR, Thickness = 1, Filled = false}) esp.name = create("Text", {Color = NAME_COLOR, Font = (syn and not RectDynamic) and 2 or 1, Outline = true, Center = true, Size = 13}) esp.healthOutline = create("Line", {Thickness = 3, Color = HEALTH_OUTLINE_COLOR}) esp.health = create("Line", {Thickness = 1}) cache[player] = esp end local function removeEsp(player) local esp = cache[player] if not esp then return end for _, drawing in pairs(esp) do drawing:Remove() end cache[player] = nil end local function updateEsp() for player, esp in pairs(cache) do local character, team = player.Character, player.Team if character and (not team or team ~= localPlayer.Team) then local cframe = character:GetPivot() local screen, onScreen = camera:WorldToViewportPoint(cframe.Position) if onScreen then local frustumHeight = math.tan(math.rad(camera.FieldOfView * 0.5)) * 2 * screen.Z local size = camera.ViewportSize.Y / frustumHeight * CHAR_SIZE local position = Vector2.new(screen.X, screen.Y) esp.boxOutline.Size = floor2(size) esp.boxOutline.Position = floor2(position - size * 0.5) esp.box.Size = esp.boxOutline.Size esp.box.Position = esp.boxOutline.Position esp.name.Text = string.lower(player.Name) esp.name.Position = floor2(position - Vector2.yAxis * (size.Y * 0.5 + esp.name.TextBounds.Y + 2)) local humanoid = character:FindFirstChildOfClass("Humanoid") local health = (humanoid and humanoid.Health or 100) / 100 esp.healthOutline.From = floor2(position - size * 0.5) - Vector2.xAxis * 5 esp.healthOutline.To = floor2(position - size * Vector2.new(0.5, -0.5)) - Vector2.xAxis * 5 esp.health.From = esp.healthOutline.To esp.health.To = floor2(esp.healthOutline.To:Lerp(esp.healthOutline.From, health)) esp.health.Color = HEALTH_LOW_COLOR:Lerp(HEALTH_HIGH_COLOR, health) esp.healthOutline.From = Vector2.yAxis esp.healthOutline.To = Vector2.yAxis end for _, drawing in pairs(esp) do drawing.Visible = onScreen end else for _, drawing in pairs(esp) do drawing.Visible = false end end end end Players.PlayerAdded:Connect(createEsp) Players.PlayerRemoving:Connect(removeEsp) RunService.RenderStepped:Connect(updateEsp) for idx, player in ipairs(Players:GetPlayers()) do if idx ~= 1 then createEsp(player) end end
end)
QOS:Button("油桶", function()
    for _, v in pairs(Workspace.Beams:GetChildren()) do if(v.Name:find("Warehouse")) then Player.Character.HumanoidRootPart.CFrame = Workspace.Beams[v.Name].CFrame; break end; end;
end)
QOS:Button("车辆货箱", function()
    for _,v in pairs(Workspace.Beams:GetChildren()) do if(v.Name:find("Airdrop_")) then Player.Character.HumanoidRootPart.CFrame = v.CFrame; end; end;
end)
QOS:Button("隔空投送", function()
    for _, v in pairs(Workspace.Beams:GetChildren()) do if(v.Name:find("Warehouse")) then Player.Character.HumanoidRootPart.CFrame = Workspace.Beams[v.Name].CFrame; break end; end;
end)
QOS:Button("范围", function()
    _G.HeadSize = 150 _G.Disabled = true game:GetService('RunService').RenderStepped:connect(function() if _G.Disabled then for i,v in next, game:GetService('Players'):GetPlayers() do if v.Name ~= game:GetService('Players').LocalPlayer.Name then pcall(function() v.Character.HumanoidRootPart.Size = Vector3.new(_G.HeadSize,_G.HeadSize,_G.HeadSize) v.Character.HumanoidRootPart.Transparency = 0.7 v.Character.HumanoidRootPart.BrickColor = BrickColor.new("Really blue") v.Character.HumanoidRootPart.Material = "Neon" v.Character.HumanoidRootPart.CanCollide = false end) end end end end)
end)
QOS:Toggle("无限跳", "IJ", false, function(IJ)
    getgenv().InfJ = IJ game:GetService("UserInputService").JumpRequest:connect(function() if InfJ == true then game:GetService("Players").LocalPlayer.Character:FindFirstChildOfClass'Humanoid':ChangeState("Jumping") end end)
end)

SQO:Button("无限子弹", function()
    local lp = game.Players.LocalPlayer for i, v in next, lp.Backpack:GetDescendants() do if v.Name == 'Settings' then local success, settingsModule = pcall(require, v) if success then settingsModule.Ammo = math.huge else warn("无法要求设置: " .. tostring(settingsModule)) end end end
end)

Tab2:Button("传送到空投", function()
    local Folder = workspace["Game Systems"] local player = game.Players.LocalPlayer.Character.HumanoidRootPart for _, Child in ipairs(Folder:GetDescendants()) do if Child.Name:match("Airdrop_") then player.CFrame = Child.MainPart.CFrame end end
end)
Tab2:Button("传送自己的基地", function()
    game:GetService("Players").LocalPlayer.Character:MoveTo(workspace.Tycoon.Tycoons[game:GetService("Players").LocalPlayer.leaderstats.Team.Value].Essentials.Spawn.Position)
end)
Tab2:Button("传送旗帜", function()
    game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(73.22032928466797, 47.9999885559082, 191.06993103027344)
end)
Tab2:Button("传送油桶1", function()
    game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(-9.748652458190918, 48.662540435791016, 700.2245483398438)
end)
Tab2:Button("传送油桶2", function()
    game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(76.48243713378906, 105.25657653808594, -2062.3896484375)
end)
Tab2:Button("传送油桶3", function()
    game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(-28.840208053588867, 49.34040069580078, -416.9921569824219)
end)
Tab2:Button("传送油桶4", function()
    game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(69.48390197753906, 105.25657653808594, 3434.9033203125)
end)    
      end
})
Section:Button({
    Title = "TY hub翻译",
    Callback = function()
    
if not (Script and Script == "全自动翻译") then
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "TY Script",
        Text = "❌错误–请复制完整",
        Icon = "rbxassetid://82031063194606",
        Duration = 10,
    })
    return
end

if not (TX and TX == "TX Script") then
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "TY Script",
        Text = "❌错误–请复制完整",
        Icon = "rbxassetid://82031063194606",
        Duration = 10,
    })
    return
end

_G.TXHub = nil

local WindUI = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/JsYb666/UI/refs/heads/main/Wind%20lib.txt"
))()

local Window = WindUI:CreateWindow({
    Title = "TY脚本自动翻译器",
    Icon = "languages",
    Author = "TY",
    Folder = "TY-HUB",
    Size = UDim2.fromOffset(300, 300),
    Transparent = true,
    Theme = "Dark",
    SideBarWidth = 0.5,
})

Window:EditOpenButton({
    Title = "打开",
    Icon = "globe",
    CornerRadius = UDim.new(0, 12),
    StrokeThickness = 2,
    Color = ColorSequence.new(Color3.fromHex("00D1FF"), Color3.fromHex("FF6B9D")),
    Draggable = true,
})

local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Chat = game:GetService("Chat")
local LocalPlayer = Players.LocalPlayer

local targetLang = "zh-CN"
local maxTextLength = 500
local baseScanInterval = 1.5
local speedMultiplier = 2
local translationMode = "智能翻译"
local translateNumbers = false
local translateSymbolsOnly = false
local skipPlayerNames = false
local autoTranslateEnabled = false
local heartbeatConnection = nil
local lastScanTime = 0

local translationCache = {}
local translatedInstances = {}

local emoteKeywords = {
    "neon", "shine", "ghost", "gold", "spin",
    "bighead", "smallhead", "giant", "squash",
}

local function detectLanguage(text)
    if not text or #text == 0 then
        return "en"
    end

    local counts = {
        cjk = 0,
        zht = 0,
        ko = 0,
        ja = 0,
        en = 0,
    }

    for _, code in utf8.codes(text) do
        local char = utf8.char(code)
        if char:match("[\228-\233][\128-\191][\128-\191]") then
            counts.cjk += 1
        elseif char:match("[\227][\128-\191][\128-\191]") then
            counts.zht += 1
        elseif char:match("[\234-\237][\128-\191]") then
            counts.ko += 1
        elseif char:match("[\227-\227][\128-\191][\128-\191]*") or char:match("[\227-\233][\128-\191]") then
            counts.ja += 1
        elseif char:match("[%a]") then
            counts.en += 1
        end
    end

    if counts.cjk > 3 then
        return counts.zht > 3 and "zh-TW" or "zh-CN"
    end
    if counts.ko > 2 then
        return "ko"
    end
    if counts.ja > 2 then
        return "ja"
    end
    if counts.en > 5 then
        return "en"
    end
    return "en"
end

local function shouldSkipText(text)
    if not text or text == "" or translationCache[text] then
        return true
    end
    if text:match("^%s*$") then
        return true
    end
    if not translateNumbers and text:match("^[%d%.%%,%s:/]+$") then
        return true
    end
    if not translateSymbolsOnly and text:match("^[^%w%s]+$") then
        return true
    end
    if #text > maxTextLength then
        return true
    end
    if not skipPlayerNames then
        if Players:FindFirstChild(text) then
            return true
        end
    end
    local lower = string.lower(text)
    for _, keyword in ipairs(emoteKeywords) do
        if string.find(lower, keyword) then
            return true
        end
    end
    return false
end

local function shouldTranslateByMode(text, detectedLang)
    if translationMode == "仅翻译英文" and detectedLang ~= "en" then
        return false
    end
    if translationMode == "仅翻译日文" and detectedLang ~= "ja" then
        return false
    end
    if translationMode == "仅翻译韩文" and detectedLang ~= "ko" then
        return false
    end
    if translationMode == "快速翻译" and #text > 50 then
        return false
    end
    return true
end

local function translateGoogle(text, fromLang, toLang)
    local url = string.format(
        "https://translate.googleapis.com/translate_a/single?client=gtx&sl=%s&tl=%s&dt=t&q=%s",
        fromLang,
        toLang,
        HttpService:UrlEncode(text)
    )

    local ok, body = pcall(function()
        return game:HttpGet(url, false, {
            ["User-Agent"] = "Mozilla/5.0",
        })
    end)
    if not ok or not body then
        return nil
    end

    local decodeOk, data = pcall(HttpService.JSONDecode, HttpService, body)
    if not decodeOk or not data or not data[1] then
        return nil
    end

    local result = ""
    for _, part in ipairs(data[1]) do
        if part[1] then
            result ..= part[1]
        end
    end
    return result ~= "" and result or nil
end

local function translateMyMemory(text, fromLang, toLang)
    local url = string.format(
        "https://api.mymemory.translated.net/get?q=%s&langpair=%s|%s",
        HttpService:UrlEncode(text),
        fromLang,
        toLang
    )

    local ok, body = pcall(function()
        return game:HttpGet(url, false, {
            ["User-Agent"] = "Roblox",
        })
    end)
    if not ok or not body then
        return nil
    end

    local decodeOk, data = pcall(HttpService.JSONDecode, HttpService, body)
    if not decodeOk or not data or not data.responseData then
        return nil
    end
    return data.responseData.translatedText
end

local function translateText(text)
    if shouldSkipText(text) then
        return translationCache[text] or text
    end

    local detected = detectLanguage(text)
    if detected == "zh-CN" then
        return text
    end
    if not shouldTranslateByMode(text, detected) then
        return text
    end

    local translated = translateGoogle(text, detected, targetLang)
    if translated then
        translationCache[text] = translated
        return translated
    end

    translated = translateMyMemory(text, detected, targetLang)
    if translated then
        translationCache[text] = translated
        return translated
    end

    return text
end

local function isTextInstance(obj)
    return obj:IsA("TextLabel") or obj:IsA("TextButton") or obj:IsA("TextBox")
end

local function shouldSkipInstance(obj)
    if not obj then
        return true
    end
    if obj == Chat or obj.Parent == Chat then
        return true
    end
    local ancestor = obj:FindFirstAncestorWhichIsA("TextChannel")
    if ancestor then
        return true
    end
    return false
end

local function getText(instance)
    if not isTextInstance(instance) then
        return nil
    end
    if not instance.Text or instance.Text == "" or shouldSkipInstance(instance) then
        return nil
    end
    return instance.Text
end

local function setText(instance, text)
    if isTextInstance(instance) and not shouldSkipInstance(instance) then
        instance.Text = text
    end
end

local function translateInstance(instance)
    if not isTextInstance(instance) or translatedInstances[instance] then
        return false
    end

    local original = getText(instance)
    if not original then
        return false
    end

    translatedInstances[instance] = true
    if getText(instance) == original then
        setText(instance, translateText(original))
        return true
    end
    return false
end

local function scanAndTranslate(root)
    local now = tick()
    if now - lastScanTime < baseScanInterval / speedMultiplier then
        return 0
    end
    lastScanTime = now

    local count = 0
    for _, descendant in ipairs(root:GetDescendants()) do
        if isTextInstance(descendant) and not translatedInstances[descendant] and not shouldSkipInstance(descendant) then
            if translateInstance(descendant) then
                count += 1
            end
        end
    end
    return count
end

local function onDescendantAdded(obj)
    if not autoTranslateEnabled or not isTextInstance(obj) then
        return
    end
    task.delay(0.1, function()
        if obj.Parent and not shouldSkipInstance(obj) then
            translateInstance(obj)
        end
    end)
end

LocalPlayer:WaitForChild("PlayerGui").DescendantAdded:Connect(onDescendantAdded)
game:GetService("CoreGui").DescendantAdded:Connect(onDescendantAdded)

-- UI
local Tab = Window:Tab({
    Title = "自动翻译",
    Icon = "languages",
})

Tab:Section({
    Title = "注意:请先加载此脚本开启翻译 再加载你需要翻译的脚本",
})

Tab:Section({
    Title = "小部分特殊UI无法翻译",
})

Tab:Toggle({
    Title = "启用自动翻译",
    Default = false,
    Callback = function(enabled)
        autoTranslateEnabled = enabled
        if enabled then
            if heartbeatConnection then
                heartbeatConnection:Disconnect()
            end
            scanAndTranslate(LocalPlayer:WaitForChild("PlayerGui"))
            heartbeatConnection = RunService.Heartbeat:Connect(function()
                if autoTranslateEnabled then
                    scanAndTranslate(LocalPlayer.PlayerGui)
                end
            end)
        else
            if heartbeatConnection then
                heartbeatConnection:Disconnect()
                heartbeatConnection = nil
            end
        end
    end,
})

Tab:Slider({
    Title = "翻译速度",
    Value = {
        Min = 1,
        Max = 5,
        Default = 2,
    },
    Callback = function(value)
        speedMultiplier = value
    end,
})

Tab:Button({
    Title = "官方群聊",
    Desc = "点击复制",
    Callback = function()
        if setclipboard then
            setclipboard("948082232")
        end
    end,
})

Window:SelectTab(1)

loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/JsYb666/Item/refs/heads/main/TX-User"
))()

print("[TY Script] 自动翻译器已加载")
    
      end
})
Section:Button({
    Title = "无敌",
    Callback = function()
    
loadstring(game:HttpGet('https://pastebin.com/raw/H3RLCWWZ'))()
end)    
      end
})
Section:Button({
    Title = "VR视角",
    Callback = function()
    
loadstring(game:HttpGet("https://raw.githubusercontent.com/giobolqvi1/homelander-by-GioBolqv1/refs/heads/main/homelander.lua"))()    
      end
})
Section:Button({
    Title = "透视",
    Callback = function()
    
loadstring(game:HttpGet("https://raw.githubusercontent.com/dingding123hhh/tt/main/%E6%97%8B%E8%BD%AC.lua"))()    
      end
})
Section:Button({
    Title = "无限罗宝😱",
    Callback = function()
    
loadstring(game:HttpGet("https://raw.githubusercontent.com/giobolqvi1/homelander-by-GioBolqv1/refs/heads/main/homelander.lua"))()    
      end
})
Section:Button({
    Title = "增加FPS",
    Callback = function()
    
loadstring(game:HttpGet("https://pastefy.app/IYUAoy7a/raw"))()
   
      end
})
Section:Button({
    Title = "飞行",
    Callback = function()
    
loadstring(game:HttpGet("https://raw.githubusercontent.com/rodan-demirali/RobloxUI/refs/heads/main/flyUIscript"))    
      end
})
Section:Button({
    Title = "无敌少侠飞行脚本",
    Callback = function()
    
loadstring(game:HttpGet("https://rawscripts.net/raw/Universal-Script-Invinicible-Flight-R15-45414"))()
      end
})

local Section = Tab:Section({
    Title = "信息",
    Opened = true
})
Section:Button({
    Title = "作者 QQ 3935754168",
    Callback = function()
    
loadstring(game:HttpGet("https://raw.githubusercontent.com/giobolqvi1/homelander-by-GioBolqv1/refs/heads/main/homelander.lua"))()
      end
})
Section:Button({
    Title = "你的注入器：忍者注入器",
    Callback = function()
    
loadstring(game:HttpGet("https://raw.githubusercontent.com/giobolqvi1/homelander-by-GioBolqv1/refs/heads/main/homelander.lua"))()
      end
})
Section:Button({
    Title = "该脚本不圈钱也不会跑路良心脚本",
    Callback = function()
    
loadstring(game:HttpGet("https://raw.githubusercontent.com/giobolqvi1/homelander-by-GioBolqv1/refs/heads/main/homelander.lua"))()
      end
})

local Tab = Window:Tab({
    Title = "脚本中心",
    Icon = "bird", -- optional
    Locked = false,
})
local Section = Tab:Section({
    Title = "脚本",
    Opened = true
})
Section:Button({
    Title = "音乐脚本",
    Callback = function()
    
loadstring(game:HttpGet("https://raw.githubusercontent.com/fningna51-stack/-/main/AF%20%E9%9F%B3%E4%B9%90%E8%84%9A%E6%9C%AC"))()
      end
})
Section:Button({
    Title = "XK Hub",
    Callback = function()
    
loadstring(game:HttpGet("https://rawscripts.net/raw/Universal-Script-XK-Hub-76803"))()
      end
})
Section:Button({
    Title = "河北唐县",
    Callback = function()
    
loadstring(game:HttpGet("https://raw.githubusercontent.com/Marco8642/science/ok/T%20ang%20County"))()
      end
})
Section:Button({
    Title = "皮脚本",
    Callback = function()
    
loadstring(game:HttpGet("https://raw.githubusercontent.com/xiaopi77/xiaopi77/main/QQ1002100032-Roblox-Pi-script.lua"))()
      end
})
Section:Button({
    Title = "祖国人脚本",
    Callback = function()
    
loadstring(game:HttpGet("https://raw.githubusercontent.com/giobolqvi1/homelander-by-GioBolqv1/refs/heads/main/homelander.lua"))()
      end
})
Section:Button({
    Title = "夜脚本",
    Callback = function()
    
loadstring(game:HttpGet("https://raw.githubusercontent.com/giobolqvi1/homelander-by-GioBolqv1/refs/heads/main/homelander.lua"))()
      end
})
Section:Button({
    Title = "该脚本以错误❌无法执行",
    Callback = function()
    
loadstring(game:HttpGet("https://raw.githubusercontent.com/aaaaa-arch/effective-computing-machine/main/%E5%AF%86%E9%92%A5"))()
      end
})
local Section = Tab:Section({
    Title = "TY脚本",
    Opened = true
})
Section:Button({
    Title = "TY脚本-通缉",
    Callback = function()
    
local WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Yisan886/Aero/refs/heads/main/ui.lua.txt"))()

WindUI:AddTheme({
    Name = "TY脚本通缉付费",
    Accent = Color3.fromHex("#18181b"),
    Background = Color3.fromHex("#101010"),
    Outline = Color3.fromHex("#FFFFFF"),
    Text = Color3.fromHex("#FFFFFF"),
    Placeholder = Color3.fromHex("#7a7a7a"),
    Button = Color3.fromHex("#52525b"),
    Icon = Color3.fromHex("#a1a1aa"),
})

local Window = WindUI:CreateWindow({
    Title = "Aero      ",
    Folder = "Aero",
    SideBarWidth = 180,
    Background = "https://chaton-images.s3.us-east-2.amazonaws.com/GHn9L9UJLf0XcVNyCpbG72D0rmNmBEWndPkh6CjJNya8GLnWzz1vImvt8wlJSBwv_2700x1519x1393696.jpeg", -- video 
    BackgroundImageTransparency = 0.5,
    OpenButton = {
        Title = "打开脚本",
        CornerRadius = UDim.new(1, 0),
        StrokeThickness = 3,
        Enabled = true,
        Draggable = true,
        OnlyMobile = false,
        Scale = 0.9,
        Color = ColorSequence.new(
            Color3.fromHex("#30FF6A"),
            Color3.fromHex("#e7ff2f")
        ),
    },
    Topbar = {
        Height = 44,
        ButtonsType = "Mac",
    },
})

Window:Tag({
    Title = "V1.03",
    Color = Color3.fromHex("00CED1"),
    Radius = 2,
})

Window:Tag({
    Title = "伊散",
    Icon = "crown",
    Color = Color3.fromHex("FFD700"),
    Radius = 2,
})

Window:Tag({
    Title = "苏达",
    Icon = "square-chevron-right",
    Color = Color3.fromHex("#30ff6a"),
    Radius = 2,
})

local COLOR_SCHEMES = {
    ["彩虹颜色"] = {ColorSequence.new({
        ColorSequenceKeypoint.new(0,    Color3.fromHex("FF0000")),
        ColorSequenceKeypoint.new(0.16, Color3.fromHex("FFA500")),
        ColorSequenceKeypoint.new(0.33, Color3.fromHex("FFFF00")),
        ColorSequenceKeypoint.new(0.5,  Color3.fromHex("00FF00")),
        ColorSequenceKeypoint.new(0.66, Color3.fromHex("0000FF")),
        ColorSequenceKeypoint.new(0.83, Color3.fromHex("4B0082")),
        ColorSequenceKeypoint.new(1,    Color3.fromHex("EE82EE"))
    }), "palette"},

    ["绿黄渐变"] = {ColorSequence.new({
        ColorSequenceKeypoint.new(0,   Color3.fromHex("30FF6A")),
        ColorSequenceKeypoint.new(0.5, Color3.fromHex("a8ff00")),
        ColorSequenceKeypoint.new(1,   Color3.fromHex("e7ff2f"))
    }), "waves"},
}

local borderAnimation
local animationSpeed = 5

local function createRainbowBorder(window, colorScheme)
    local mainFrame = window.UIElements.Main
    if not mainFrame then return nil end

    local existingStroke = mainFrame:FindFirstChild("RainbowStroke")
    if existingStroke then existingStroke:Destroy() end

    if not mainFrame:FindFirstChildOfClass("UICorner") then
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 16)
        corner.Parent = mainFrame
    end

    local rainbowStroke = Instance.new("UIStroke")
    rainbowStroke.Name = "RainbowStroke"
    rainbowStroke.Thickness = 2
    rainbowStroke.Color = Color3.new(1, 1, 1)
    rainbowStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    rainbowStroke.LineJoinMode = Enum.LineJoinMode.Round
    rainbowStroke.Parent = mainFrame

    local glowEffect = Instance.new("UIGradient")
    glowEffect.Name = "GlowEffect"
    local schemeData = COLOR_SCHEMES[colorScheme or "彩虹颜色"]
    glowEffect.Color = schemeData and schemeData[1] or COLOR_SCHEMES["彩虹颜色"][1]
    glowEffect.Rotation = 0
    glowEffect.Parent = rainbowStroke

    return rainbowStroke
end

local function startBorderAnimation(window, speed)
    local mainFrame = window.UIElements.Main
    if not mainFrame then return nil end>
    local rainbowStroke = mainFrame:FindFirstChild("RainbowStroke")
    if not rainbowStroke then return nil end
    local glowEffect = rainbowStroke:FindFirstChild("GlowEffect")
    if not glowEffect then return nil end

    return game:GetService("RunService").Heartbeat:Connect(function()
        if not rainbowStroke or rainbowStroke.Parent == nil then return end
        glowEffect.Rotation = (tick() * speed * 10) % 360
    end)
end

local rainbowStroke = createRainbowBorder(Window, "彩虹颜色")
if rainbowStroke then
    borderAnimation = startBorderAnimation(Window, animationSpeed)
end

local Lighting = game:GetService("Lighting")
local TweenServiceBlur = game:GetService("TweenService")

local blur = Lighting:FindFirstChildOfClass("BlurEffect")
if not blur then
    blur = Instance.new("BlurEffect")
    blur.Size = 0
    blur.Parent = Lighting
end

task.spawn(function()
    local wasOpen = false
    while true do
        task.wait(0.1)
        local mainFrame = Window.UIElements and Window.UIElements.Main
        local isOpen = mainFrame and mainFrame.Visible or false
        
        if isOpen ~= wasOpen then
            wasOpen = isOpen
            TweenServiceBlur:Create(blur, TweenInfo.new(0.3), {
                Size = isOpen and 20 or 0
            }):Play()
        end
    end
end)
local Tabs = {}

do
    Tabs.World = Window:Tab({ Title = "基本功能", })
    Tabs.Player = Window:Tab({ Title = "玩家功能", })
    Tabs.Combat = Window:Tab({ Title = "暴力功能", })
    Tabs.Visual = Window:Tab({ Title = "绘制功能", })
end
Window:SelectTab(1)
local plrs = game:GetService("Players")
local me = plrs.LocalPlayer
local input = game:GetService("UserInputService")
local run = game:GetService("RunService")
local camera = workspace.CurrentCamera
local tween = game:GetService("TweenService")
local light = game:GetService("Lighting")
local rp = game:GetService("ReplicatedStorage")

local functions = {
    Fullbright = false,
    AutoOpenDoors = false,
    NoBarriers = false,
    NoGrinder = false,
    FastPickup = false,
    AutoPickupScraps = false,
    AutoPickupTools = false,
    AutopickupCrates = false,
    AutoPickupMoney = false,
    Infstamina = false,
    Nofalldamage = false,
    Noclip = false,
    FakeDown = false,
    Stopneckmove = false,
    Unbreaklimbs = false,
    SilentAim = false,
    Instantreload = false,
    Meleeaura = false,
    RageBot = false,
    TrigerBot = false,
    RocketControl = false,
    ESP = false,
    ArmsChams = false,
    ToolsChams = false,
}

local SectionSettings = {
    SilentAim = {
        Draw = false,
        DrawSize = 50,
        DrawColor = Color3.new(1, 1, 1),
        TargetParts = {"Head"},
        CheckDowned = false,
        CheckWall = false,
        CheckTeam = false,
        CheckWhiteList = false,
    },
    Aimbot = {
        Draw = false,
        DrawSize = 50,
        DrawColor = Color3.new(1, 1, 1),
        TargetParts = {"Head"},
        CheckDowned = false,
        CheckWall = false,
        CheckTeam = false,
        CheckWhiteList = false,
        Velocity = false,
        Smooth = false,
        SmoothSize = 0.5
    },
    MeleeAura = {
        ShowAnim = false,
        TargetParts = {"Head"},
        CheckDowned = false,
        CheckTeam = false,
        CheckWhiteList = false,
        Distance = 15,
    },
    RageBot = {
        CheckDowned = false,
        CheckWhiteList = false
    },
    ESP = {
        Name = false,
        Box = false,
        Weapon = false,
        Highlight = false,
    }
}

local Methods = {
    Fly = "Bypass",
    Infstamina = "Getgc"
}

local cockie = {
    SilentAimCircle = nil,
    SilentAim_body = nil,
    ESPHighlight = nil,
    AimBotCircle = nil,
    aimbot_button = nil,
    Aimbot_body = nil,
    MeleeAura_body = nil,
}

local RUNS = {
    cameraFOV = nil,
    JumpHeight = nil,
    AutoOpenDoors = nil,
    AutopickupScraps = nil,
    AutopickupTools = nil,
    AutopickupCrates = nil,
    AutopickupMoney = nil,
    Infstamina = nil,
    Fly = nil,
    Noclip = nil,
    Meleeaura = nil,
    ESP = nil,
}

local funcindex = {
    Fullbright = {
        oldClockTime = nil,
        oldBrightness = nil,
    }
}

local WhiteList = {}

function CharStats(plr)
    local folder = rp.CharStats[plr.Name]
    return folder
end
Tabs.World:Toggle({
    Title = "夜视",
    Desc = "地图变亮",
    Value = functions.Fullbright,
    Callback = function(Value)
        functions.Fullbright = Value
        local Folder
        if Value then
            if #light:GetChildren() ~= 0 then
                Folder = Instance.new("Folder")
                Folder.Parent = rp
                Folder.Name = "Index"
                for _, a in pairs(light:GetChildren()) do
                    a.Parent = Folder
                end
            end
            funcindex.Fullbright.oldClockTime = light.ClockTime
            light.ClockTime = 14
            funcindex.Fullbright.oldBrightness = light.Brightness
            light.Brightness = 4
            light.ExposureCompensation = .7
        else
            Folder = rp:FindFirstChild("Index")
            if Folder ~= nil then
                for _, a in pairs(Folder:GetChildren()) do
                    a.Parent = light
                end
                Folder:Destroy()
                Folder = nil
            end
            light.ClockTime = funcindex.Fullbright.oldClockTime or 14
            light.Brightness = funcindex.Fullbright.oldBrightness or 1
            light.ExposureCompensation = 0
        end
    end
})

Tabs.World:Toggle({
    Title = "自动开门",
    Desc = "自动打开附近的门",
    Value = functions.AutoOpenDoors,
    Callback = function(Value)
        functions.AutoOpenDoors = Value
        if Value then
            RUNS.AutoOpenDoors = run.RenderStepped:Connect(function()
                local function GetDoor()
                    local mapFolder = workspace:FindFirstChild("Map")
                    if not mapFolder then return nil end
                    local folderDoors = mapFolder:FindFirstChild("Doors")
                    if not folderDoors then return nil end
                    local closestDoor, dist = nil, 15
                    for _, door in pairs(folderDoors:GetChildren()) do
                        local doorBase = door:FindFirstChild("DoorBase")
                        if doorBase and me.Character and me.Character:FindFirstChild("HumanoidRootPart") then
                            local distance = (me.Character.HumanoidRootPart.Position - doorBase.Position).Magnitude
                            if distance < dist then
                                dist = distance
                                closestDoor = door
                            end
                        end
                    end
                    return closestDoor
                end
                local door = GetDoor()
                if door then
                    local values = door:FindFirstChild("Values")
                    local events = door:FindFirstChild("Events")
                    if values and events then
                        local locked = values:FindFirstChild("Locked")
                        local openValue = values:FindFirstChild("Open")
                        local toggleEvent = events:FindFirstChild("Toggle")
                        if locked and openValue and toggleEvent then
                            if locked.Value == true then
                                toggleEvent:FireServer("Unlock", door.Lock)
                            elseif locked.Value == false and openValue.Value == false then
                                local knob1 = door:FindFirstChild("Knob1")
                                local knob2 = door:FindFirstChild("Knob2")
                                if knob1 and knob2 then
                                    local knob1pos = (me.Character.HumanoidRootPart.Position - knob1.Position).Magnitude
                                    local knob2pos = (me.Character.HumanoidRootPart.Position - knob2.Position).Magnitude
                                    local chosenKnob = (knob1pos < knob2pos) and knob1 or knob2
                                    toggleEvent:FireServer("Open", chosenKnob)
                                end
                            end
                        end
                    end
                end
            end)
        else
            if RUNS.AutoOpenDoors then
                RUNS.AutoOpenDoors:Disconnect()
                RUNS.AutoOpenDoors = nil
            end
        end
    end
})

Tabs.World:Toggle({
    Title = "无屏障",
    Desc = "移除地图屏障",
    Value = functions.NoBarriers,
    Callback = function(Value)
        functions.NoBarriers = Value
        for _, a in pairs(workspace.Filter.Parts["F_Parts"]:GetDescendants()) do
            if a:IsA("Part") or a:IsA("MeshPart") then
                a.CanTouch = not a.CanTouch
            end
        end
    end
})

Tabs.World:Toggle({
    Title = "防研磨机",
    Desc = "防止研磨机伤害",
    Value = functions.NoGrinder,
    Callback = function(Value)
        functions.NoGrinder = Value
        for _, a in pairs(workspace.Map.Parts.Grinders:GetDescendants()) do
            if a:IsA("Part") or a:IsA("MeshPart") then
                a.CanTouch = not a.CanTouch
            end
        end
        for _, a in pairs(workspace.Map.Parts.M_Parts:GetDescendants()) do
            if a:IsA("Part") and a.Name == "FirePart" then
                a.CanTouch = not a.CanTouch
            end
        end
    end
})

Tabs.World:Toggle({
    Title = "快速拾取",
    Desc = "瞬间拾取物品",
    Value = functions.FastPickup,
    Callback = function(Value)
        functions.FastPickup = Value
        if Value then
            game.DescendantAdded:Connect(function(obj)
                if obj:IsA("ProximityPrompt") then
                    obj.HoldDuration = 0
                    obj:GetPropertyChangedSignal("HoldDuration"):Connect(function()
                        if functions.FastPickup then
                            obj.HoldDuration = 0
                        end
                    end)
                end
            end)
        end
    end
})

Tabs.World:Toggle({
    Title = "自动拾取废料",
    Desc = "自动拾取附近的废料",
    Value = functions.AutoPickupScraps,
    Callback = function(Value)
        functions.AutoPickupScraps = Value
        local remote = rp.Events.PIC_PU
        local scrapsfolder = workspace.Filter.SpawnedPiles
        local canPickup = true
        local startTick = tick()
        if Value then
            RUNS.AutopickupScraps = run.RenderStepped:Connect(function()
                local function GetClosestScrap()
                    local maxdist = 15
                    local closest = nil
                    for _, a in pairs(scrapsfolder:GetChildren()) do
                        if a and (a.Name == "S1" or a.Name == "S2") then
                            if me.Character and me.Character.HumanoidRootPart then
                                local getdist = (me.Character.HumanoidRootPart.Position - a.MeshPart.Position).Magnitude
                                if getdist < maxdist then
                                    maxdist = getdist
                                    closest = a
                                end
                            end
                        end
                    end
                    return closest
                end
                local getscrap = GetClosestScrap()
                if getscrap then
                    if canPickup then
                        remote:FireServer(string.reverse(getscrap:GetAttribute("jzu")))
                        canPickup = false
                    end
                end
                if canPickup == false and tick() - startTick >= 4.5 then
                    canPickup = true
                    startTick = tick()
                end
            end)
        else
            if RUNS.AutopickupScraps then
                RUNS.AutopickupScraps:Disconnect()
                RUNS.AutopickupScraps = nil
            end
        end
    end
})

Tabs.World:Toggle({
    Title = "自动拾取工具",
    Desc = "自动拾取附近的工具",
    Value = functions.AutoPickupTools,
    Callback = function(Value)
        functions.AutoPickupTools = Value
        local remote = rp.Events.PIC_TLO
        local toolsfolder = workspace.Filter.SpawnedTools
        local canPickup = true
        local startTick = tick()
        if Value then
            RUNS.AutopickupTools = run.RenderStepped:Connect(function()
                local function GetClosestTool()
                    local maxdist = 15
                    local closest = nil
                    for _, a in pairs(toolsfolder:GetChildren()) do
                        if a and me.Character and me.Character.HumanoidRootPart then
                            local handle = a:FindFirstChild("Handle") or a:FindFirstChild("WeaponHandle")
                            if handle and (handle:IsA("Part") or handle:IsA("MeshPart")) then
                                if me.Character and me.Character:FindFirstChild("HumanoidRootPart") then
                                    local getdist = (me.Character.HumanoidRootPart.Position - handle.Position).Magnitude
                                    if getdist < maxdist then
                                        maxdist = getdist
                                        closest = a
                                    end
                                end
                            end
                        end
                    end
                    return closest
                end
                local tool = GetClosestTool()
                if tool then
                    local Handle = tool:FindFirstChild("Handle") or tool:FindFirstChild("WeaponHandle")
                    if Handle then
                        if canPickup then
                            remote:FireServer(Handle)
                            canPickup = false
                        end
                    end
                end
                if canPickup == false and tick() - startTick >= 1.5 then
                    canPickup = true
                    startTick = tick()
                end
            end)
        else
            if RUNS.AutopickupTools then
                RUNS.AutopickupTools:Disconnect()
                RUNS.AutopickupTools = nil
            end
        end
    end
})

Tabs.World:Toggle({
    Title = "自动拾取金钱",
    Desc = "自动拾取附近的金钱",
    Value = functions.AutoPickupMoney,
    Callback = function(Value)
        functions.AutoPickupMoney = Value
        local remote = rp.Events:FindFirstChild("CZDPZUS")
        local moneyfolder = workspace.Filter.SpawnedBread
        local canPickup = true
        local startTick = tick()
        if Value then
            RUNS.AutopickupMoney = run.RenderStepped:Connect(function()
                local function GetMoney()
                    local maxdist = 15
                    local closest = nil
                    for _, a in pairs(moneyfolder:GetChildren()) do
                        if a and me.Character and me.Character.HumanoidRootPart then
                            local getdist = (me.Character.HumanoidRootPart.Position - a.Position).Magnitude
                            if getdist < maxdist then
                                maxdist = getdist
                                closest = a
                            end
                        end
                    end
                    return closest
                end
                local foundmoney = GetMoney()
                if foundmoney then
                    if canPickup then
                        remote:FireServer(foundmoney)
                        canPickup = false
                    end
                end
                if canPickup == false and tick() - startTick >= 1 then
                    canPickup = true
                    startTick = tick()
                end
            end)
        else
            if RUNS.AutopickupMoney then
                RUNS.AutopickupMoney:Disconnect()
                RUNS.AutopickupMoney = nil
            end
        end
    end
})
Tabs.Player:Slider({
    Title = "FOV",
    Desc = "调整相机视野",
    Value = {
        Min = 70,
        Max = 120,
        Default = camera.FieldOfView
    },
    Callback = function(Value)
        if RUNS.cameraFOV then RUNS.cameraFOV:Disconnect() end
        RUNS.cameraFOV = run.RenderStepped:Connect(function()
            camera.FieldOfView = Value
        end)
    end
})

Tabs.Player:Slider({
    Title = "相机距离",
    Desc = "调整相机最大距离",
    Value = {
        Min = 10,
        Max = 500,
        Default = me.CameraMaxZoomDistance
    },
    Callback = function(Value)
        me.CameraMaxZoomDistance = Value
    end
})

Tabs.Player:Slider({
    Title = "跳跃高度",
    Desc = "调整跳跃高度",
    Value = {
        Min = 7.1,
        Max = 25,
        Default = 7.1
    },
    Callback = function(Value)
        if RUNS.JumpHeight then RUNS.JumpHeight:Disconnect() end
        RUNS.JumpHeight = run.RenderStepped:Connect(function()
            if me.Character and me.Character:FindFirstChild("Humanoid") then
                me.Character.Humanoid.UseJumpPower = false
                me.Character.Humanoid.JumpHeight = Value
            end
        end)
    end
})

Tabs.Player:Toggle({
    Title = "无限体力",
    Desc = "字面意思",
    Value = functions.Infstamina,
    Callback = function(Value)
        functions.Infstamina = Value
        if Value then
            task.spawn(function()
                while functions.Infstamina do
                    if Methods.Infstamina == "Getgc" then
                        local stamina = {}
                        local function get()
                            for _, value in pairs(getgc(true)) do
                                if type(value) == "table" and rawget(value, "S") then
                                    table.insert(stamina, value)
                                end
                            end
                        end
                        local success = pcall(get)
                        if success then
                            for _, a in pairs(stamina) do
                                a.S = 100
                            end
                        end
                    elseif Methods.Infstamina == "low exploit" then
                        if me.Character then
                            local hum = me.Character:FindFirstChild("Humanoid")
                            if hum and not hum:GetAttribute("ZSPRN_M") then
                                hum:SetAttribute("ZSPRN_M", true)
                            end
                        end
                        me.CharacterAdded:Connect(function(char)
                            if functions.Infstamina and char and char:WaitForChild("Humanoid") then
                                local hum = char:FindFirstChild("Humanoid")
                                if hum and not hum:GetAttribute("ZSPRN_M") then
                                    hum:SetAttribute("ZSPRN_M", true)
                                end
                            end
                        end)
                    end
                    run.RenderStepped:Wait()
                end
            end)
        else
            if me.Character then
                local hum = me.Character:FindFirstChild("Humanoid")
                if hum then
                    hum:SetAttribute("ZSPRN_M", nil)
                end
            end
        end
    end
})

Tabs.Player:Dropdown({
    Title = "无限体力方法",
    Desc = "选择实现方法",
    Values = {"Getgc", "low exploit"},
    Value = Methods.Infstamina,
    Multi = false,
    AllowNone = false,
    Callback = function(Value)
        Methods.Infstamina = Value
    end
})

Tabs.Player:Toggle({
    Title = "无坠落伤害",
    Desc = "防止坠落伤害",
    Value = functions.Nofalldamage,
    Callback = function(Value)
        functions.Nofalldamage = Value
        if Value then
            if me.Character then
                local ff = Instance.new("ForceField")
                ff.Parent = me.Character
                ff.Visible = false
            end
            me.CharacterAdded:Connect(function(char)
                if functions.Nofalldamage and char and char:WaitForChild("HumanoidRootPart") and char:WaitForChild("Humanoid") then
                    local ff = Instance.new("ForceField")
                    ff.Parent = char
                    ff.Visible = false
                end
            end)
        else
            if me.Character then
                for _, a in pairs(me.Character:GetChildren()) do
                    if a:IsA("ForceField") and a.Visible == false then
                        a:Destroy()
                    end
                end
            end
        end
    end
})

Tabs.Player:Toggle({
    Title = "穿墙",
    Desc = "可以穿过墙壁",
    Value = functions.Noclip,
    Callback = function(Value)
        functions.Noclip = Value
        if Value then
            RUNS.Noclip = run.RenderStepped:Connect(function()
                local char = me.Character
                if char then
                    for _, a in pairs(char:GetDescendants()) do
                        if a:IsA("BasePart") and a.CanCollide then
                            a.CanCollide = false
                        end
                    end
                end
            end)
        else
            if RUNS.Noclip then
                RUNS.Noclip:Disconnect()
                RUNS.Noclip = nil
            end
        end
    end
})

Tabs.Player:Toggle({
    Title = "伪装倒地",
    Desc = "伪装成倒地状态",
    Value = functions.FakeDown,
    Callback = function(Value)
        functions.FakeDown = Value
        if Value then
            local getvalue = CharStats(me).Downed
            getvalue.Value = true
            getvalue:GetPropertyChangedSignal("Value"):Connect(function()
                if functions.FakeDown then
                    getvalue.Value = true
                end
            end)
        else
            CharStats(me).Downed.Value = false
        end
    end
})

Tabs.Player:Toggle({
    Title = "停止颈部移动",
    Desc = "停止角色颈部移动",
    Value = functions.Stopneckmove,
    Callback = function(Value)
        functions.Stopneckmove = Value
        if Value then
            if me.Character then
                me.Character:SetAttribute("NoNeckMovement", true)
            end
            me.CharacterAdded:Connect(function(char)
                if char and char:FindFirstChild("Humanoid") then
                    if functions.Stopneckmove then
                        char:SetAttribute("NoNeckMovement", true)
                    end
                else
                    repeat task.wait() until char and char:FindFirstChild("Humanoid")
                    if functions.Stopneckmove then
                        char:SetAttribute("NoNeckMovement", true)
                    end
                end
            end)
        else
            if me.Character then
                me.Character:SetAttribute("NoNeckMovement", nil)
            end
        end
    end
})

Tabs.Player:Toggle({
    Title = "肢体不碎",
    Desc = "防止肢体断裂",
    Value = functions.Unbreaklimbs,
    Callback = function(Value)
        functions.Unbreaklimbs = Value
        local limbsfolder = CharStats(me).HealthValues
        local function fixLimbs()
            for _, a in pairs(limbsfolder:GetChildren()) do
                for _, i in pairs(a:GetChildren()) do
                    if i and i.Name == "Broken" then
                        if functions.Unbreaklimbs then
                            i.Value = false
                            i:GetPropertyChangedSignal("Value"):Connect(function()
                                if functions.Unbreaklimbs then
                                    i.Value = false
                                end
                            end)
                        end
                    end
                end
            end
        end
        fixLimbs()
        limbsfolder.ChildAdded:Connect(fixLimbs)
    end
})

Tabs.Combat:Toggle({
    Title = "近战光环",
    Desc = "最好别乱用",
    Value = functions.Meleeaura,
    Callback = function(Value)
        functions.Meleeaura = Value
        if Value then
            local remote1 = rp.Events["XMHH.2"]
            local remote2 = rp.Events["XMHH2.2"]
            local part
            local randpart = nil
            local LastTick = tick()
            local AttachTick = tick()
            local attachcd = 0.1
            local AttachCD = {
                Fists = 0.05, Knuckledusters = 0.05, Nunchucks = 0.05, Shiv = 0.05,
                Bat = 1, ["Metal-Bat"] = 1, Chainsaw = 2.5, Balisong = 0.05,
                Rambo = 0.3, Shovel = 3, Sledgehammer = 2, Katana = 0.1,
                Wrench = 0.1, FireAxe = 2.6
            }
            local function Attack(target)
                if not (target and target:FindFirstChild("Head")) then return end
                local mychar = me.Character
                if not mychar then return end
                local TOOL = mychar:FindFirstChildOfClass("Tool")
                if not TOOL then return end
                local AnimFolder = TOOL:FindFirstChild("AnimsFolder")
                if not AnimFolder then return end
                local anim = AnimFolder:FindFirstChild("Slash1")
                if not anim then return end
                if tick() - AttachTick >= attachcd then
                    local result = remote1:InvokeServer("🍞", tick(), TOOL, "43TRFWX", "Normal", tick(), true)
                    attachcd = AttachCD[TOOL.Name] or 0.5
                    if SectionSettings.MeleeAura.ShowAnim then
                        local load = me.Character.Humanoid.Animator:LoadAnimation(anim)
                        load:Play()
                        load:AdjustSpeed(1.3)
                    end
                    task.wait(0.3 + math.random() * 0.2)
                    if TOOL then
                        local Handle = TOOL:FindFirstChild("WeaponHandle") or TOOL:FindFirstChild("Handle") or me.Character:FindFirstChild("Right Arm")
                        local arg2 = {
                            "🍞", tick(), TOOL, "2389ZFX34", result, true, Handle,
                            target:FindFirstChild(part), target,
                            me.Character.HumanoidRootPart.Position,
                            target:FindFirstChild(part).Position
                        }
                        if TOOL.Name == "Chainsaw" then
                            for _ = 1, 15 do remote2:FireServer(unpack(arg2)) end
                        else
                            remote2:FireServer(unpack(arg2))
                        end
                        AttachTick = tick()
                    end
                end
            end
            task.spawn(function()
                while functions.Meleeaura do
                    local mychar = me.Character or me.CharacterAdded:Wait()
                    if mychar then
                        local myhrp = mychar:FindFirstChild("HumanoidRootPart")
                        if myhrp then
                            for _, a in pairs(plrs:GetPlayers()) do
                                if a == me then continue end
                                local char = a.Character
                                if not char then continue end
                                local hrp = char:FindFirstChild("HumanoidRootPart")
                                if not hrp then continue end
                                if (myhrp.Position - hrp.Position).Magnitude >= SectionSettings.MeleeAura.Distance then continue end
                                local hum = char:FindFirstChildOfClass("Humanoid")
                                if not hum or hum.Health == 0 then continue end
                                if char:FindFirstChildOfClass("ForceField") then continue end
                                if SectionSettings.MeleeAura.CheckWhiteList and table.find(WhiteList, a) then continue end
                                if SectionSettings.MeleeAura.CheckTeam and a.Team == me.Team then continue end
                                if SectionSettings.MeleeAura.CheckDowned and CharStats(a).Downed.Value then continue end
                                local count = #SectionSettings.MeleeAura.TargetParts
                                if count == 0 then
                                    part = "Head"
                                elseif count == 1 then
                                    part = SectionSettings.MeleeAura.TargetParts[1]
                                else
                                    if tick() - LastTick >= 0.2 then
                                        randpart = SectionSettings.MeleeAura.TargetParts[math.random(1, count)]
                                        LastTick = tick()
                                    end
                                    part = randpart or SectionSettings.MeleeAura.TargetParts[1]
                                end
                                Attack(char)
                            end
                        end
                    end
                    run.Heartbeat:Wait()
                end
            end)
        end
    end
})

Tabs.Combat:Toggle({
    Title = "显示动画",
    Desc = "显示攻击动画",
    Value = SectionSettings.MeleeAura.ShowAnim,
    Callback = function(Value)
        SectionSettings.MeleeAura.ShowAnim = Value
    end
})
Tabs.Visual:Toggle({
    Title = "ESP",
    Desc = "显示玩家轮廓",
    Value = functions.ESP,
    Callback = function(Value)
        functions.ESP = Value
        if Value then
            RUNS.ESP = run.Heartbeat:Connect(function()
                if SectionSettings.ESP.Highlight then
                    for _, a in pairs(plrs:GetPlayers()) do
                        if a ~= me then
                            local char = a.Character
                            if char and not char:FindFirstChild("Highlight") then
                                local hg = Instance.new("Highlight")
                                hg.Parent = char
                                hg.FillTransparency = 1
                            end
                        end
                    end
                    plrs.PlayerAdded:Connect(function(player)
                        if functions.ESP then
                            local char = player.Character or player.CharacterAdded:Wait()
                            if char and SectionSettings.ESP.Highlight and not char:FindFirstChild("Highlight") then
                                local hg = Instance.new("Highlight")
                                hg.Parent = char
                                hg.FillTransparency = 1
                            end
                        end
                    end)
                else
                    for _, a in pairs(plrs:GetPlayers()) do
                        if a ~= me then
                            local char = a.Character
                            if char then
                                local h = char:FindFirstChild("Highlight")
                                if h then h:Destroy() end
                            end
                        end
                    end
                end
            end)
        else
            if RUNS.ESP then
                RUNS.ESP:Disconnect()
                RUNS.ESP = nil
            end
            for _, a in pairs(plrs:GetPlayers()) do
                if a ~= me then
                    local char = a.Character
                    if char then
                        local h = char:FindFirstChild("Highlight")
                        if h then h:Destroy() end
                    end
                end
            end
        end
    end
})

Tabs.Visual:Toggle({
    Title = "高亮显示",
    Desc = "高亮显示其他玩家",
    Value = SectionSettings.ESP.Highlight,
    Callback = function(Value)
        SectionSettings.ESP.Highlight = Value
    end
})

Tabs.Visual:Toggle({
    Title = "手臂特效",
    Desc = "改变手臂材质",
    Value = functions.ArmsChams,
    Callback = function(Value)
        functions.ArmsChams = Value
        local viewfolder = camera:WaitForChild("ViewModel")
        if Value then
            viewfolder["Left Arm"].Material = Enum.Material.ForceField
            viewfolder["Right Arm"].Material = Enum.Material.ForceField
        else
            viewfolder["Left Arm"].Material = Enum.Material.Plastic
            viewfolder["Right Arm"].Material = Enum.Material.Plastic
        end
        me.CharacterAdded:Connect(function(char)
            repeat task.wait() until char and char.Parent
            local vf = camera:WaitForChild("ViewModel")
            if functions.ArmsChams then
                vf["Left Arm"].Material = Enum.Material.ForceField
                vf["Right Arm"].Material = Enum.Material.ForceField
            else
                vf["Left Arm"].Material = Enum.Material.Plastic
                vf["Right Arm"].Material = Enum.Material.Plastic
            end
        end)
    end
})

local function Create(Class, Properties)
    local _Instance = typeof(Class) == 'string' and Instance.new(Class) or Class
    for Property, Value in pairs(Properties) do
        _Instance[Property] = Value
    end
    return _Instance
end

local ESPSettings = {
    Enabled = true,
    TeamCheck = true,
    MaxDistance = 200,
    FontSize = 11,
    FadeOut = {
        OnDistance = true,
        OnDeath = false,
        OnLeave = false,
    },
    Options = {
        Teamcheck = false, TeamcheckRGB = Color3.fromRGB(0, 255, 0),
        Friendcheck = true, FriendcheckRGB = Color3.fromRGB(0, 255, 0),
        Highlight = false, HighlightRGB = Color3.fromRGB(255, 0, 0),
    },
    Drawing = {
        Chams = {
            Enabled  = true,
            Thermal = true,
            FillRGB = Color3.fromRGB(255, 140, 0),
            Fill_Transparency = 100,
            OutlineRGB = Color3.fromRGB(255, 140, 0),
            Outline_Transparency = 100,
            VisibleCheck = true,
        },
        Names = {
            Enabled = true,
            RGB = Color3.fromRGB(255, 255, 255),
        },
        Flags = {
            Enabled = true,
        },
        Distances = {
            Enabled = true,
            Position = "Text",
            RGB = Color3.fromRGB(255, 255, 255),
        },
        Weapons = {
            Enabled = true, WeaponTextRGB = Color3.fromRGB(255, 140, 0),
            Outlined = false,
            Gradient = false,
            GradientRGB1 = Color3.fromRGB(255, 255, 255), GradientRGB2 = Color3.fromRGB(255, 140, 0),
        },
        Healthbar = {
            Enabled = true,
            HealthText = true, Lerp = false, HealthTextRGB = Color3.fromRGB(255, 140, 0),
            Width = 2.5,
            Gradient = true, GradientRGB1 = Color3.fromRGB(200, 0, 0), GradientRGB2 = Color3.fromRGB(60, 60, 125), GradientRGB3 = Color3.fromRGB(255, 140, 0),
        },
        Boxes = {
            Animate = true,
            RotationSpeed = 300,
            Gradient = false, GradientRGB1 = Color3.fromRGB(255, 140, 0), GradientRGB2 = Color3.fromRGB(0, 0, 0),
            GradientFill = true, GradientFillRGB1 = Color3.fromRGB(255, 140, 0), GradientFillRGB2 = Color3.fromRGB(0, 0, 0),
            Filled = {
                Enabled = true,
                Transparency = 0.75,
                RGB = Color3.fromRGB(0, 0, 0),
            },
            Full = {
                Enabled = true,
                RGB = Color3.fromRGB(255, 255, 255),
            },
            Corner = {
                Enabled = true,
                RGB = Color3.fromRGB(255, 140, 0),
            },
        },
    },
}

local ESPManager = {}
do
    local Workspace, RunService, Players, CoreGui, Lighting = game:GetService("Workspace"), game:GetService("RunService"), game:GetService("Players"), game:GetService("CoreGui"), game:GetService("Lighting")
    local lplayer = Players.LocalPlayer
    local camera = Workspace.CurrentCamera
    local Cam = Workspace.CurrentCamera
    local ScreenGui = nil
    local Connections = {}
    local RotationAngle = -45
    local Tick = tick()
    local function FadeOutOnDist(element, distance)
        if not element then return end
        local transparency = math.max(0.1, 1 - (distance / ESPSettings.MaxDistance))
        if element:IsA("TextLabel") then
            element.TextTransparency = 1 - transparency
        elseif element:IsA("ImageLabel") then
            element.ImageTransparency = 1 - transparency
        elseif element:IsA("UIStroke") then
            element.Transparency = 1 - transparency
        elseif element:IsA("Frame") then
            element.BackgroundTransparency = 1 - transparency
        elseif element:IsA("Highlight") then
            element.FillTransparency = 1 - transparency
            element.OutlineTransparency = 1 - transparency
        end
    end
    local function CreatePlayerESP(plr)
        if not ScreenGui then return end
        if Connections[plr] then return end
        local Box = Create("Frame", {Parent = ScreenGui, BackgroundColor3 = Color3.fromRGB(0, 0, 0), BackgroundTransparency = 0.75, BorderSizePixel = 0})
        local Gradient1 = Create("UIGradient", {Parent = Box, Enabled = ESPSettings.Drawing.Boxes.GradientFill, Color = ColorSequence.new{ColorSequenceKeypoint.new(0, ESPSettings.Drawing.Boxes.GradientFillRGB1), ColorSequenceKeypoint.new(1, ESPSettings.Drawing.Boxes.GradientFillRGB2)}})
        local Outline = Create("UIStroke", {Parent = Box, Enabled = ESPSettings.Drawing.Boxes.Gradient, Transparency = 0, Color = Color3.fromRGB(255, 255, 255), LineJoinMode = Enum.LineJoinMode.Miter})
        local Gradient2 = Create("UIGradient", {Parent = Outline, Enabled = ESPSettings.Drawing.Boxes.Gradient, Color = ColorSequence.new{ColorSequenceKeypoint.new(0, ESPSettings.Drawing.Boxes.GradientRGB1), ColorSequenceKeypoint.new(1, ESPSettings.Drawing.Boxes.GradientRGB2)}})
        local Healthbar = Create("Frame", {Parent = ScreenGui, BackgroundColor3 = Color3.fromRGB(255, 255, 255), BackgroundTransparency = 0})
        local BehindHealthbar = Create("Frame", {Parent = ScreenGui, ZIndex = -1, BackgroundColor3 = Color3.fromRGB(0, 0, 0), BackgroundTransparency = 0})
        local HealthbarGradient = Create("UIGradient", {Parent = Healthbar, Enabled = ESPSettings.Drawing.Healthbar.Gradient, Rotation = -90, Color = ColorSequence.new{ColorSequenceKeypoint.new(0, ESPSettings.Drawing.Healthbar.GradientRGB1), ColorSequenceKeypoint.new(0.5, ESPSettings.Drawing.Healthbar.GradientRGB2), ColorSequenceKeypoint.new(1, ESPSettings.Drawing.Healthbar.GradientRGB3)}})
        local Chams = Create("Highlight", {Parent = ScreenGui, FillTransparency = 1, OutlineTransparency = 0, OutlineColor = Color3.fromRGB(255, 140, 0), DepthMode = "AlwaysOnTop"})
        local LeftTop = Create("Frame", {Parent = ScreenGui, BackgroundColor3 = ESPSettings.Drawing.Boxes.Corner.RGB, Position = UDim2.new(0, 0, 0, 0)})
        local LeftSide = Create("Frame", {Parent = ScreenGui, BackgroundColor3 = ESPSettings.Drawing.Boxes.Corner.RGB, Position = UDim2.new(0, 0, 0, 0)})
        local RightTop = Create("Frame", {Parent = ScreenGui, BackgroundColor3 = ESPSettings.Drawing.Boxes.Corner.RGB, Position = UDim2.new(0, 0, 0, 0)})
        local RightSide = Create("Frame", {Parent = ScreenGui, BackgroundColor3 = ESPSettings.Drawing.Boxes.Corner.RGB, Position = UDim2.new(0, 0, 0, 0)})
        local BottomSide = Create("Frame", {Parent = ScreenGui, BackgroundColor3 = ESPSettings.Drawing.Boxes.Corner.RGB, Position = UDim2.new(0, 0, 0, 0)})
        local BottomDown = Create("Frame", {Parent = ScreenGui, BackgroundColor3 = ESPSettings.Drawing.Boxes.Corner.RGB, Position = UDim2.new(0, 0, 0, 0)})
        local BottomRightSide = Create("Frame", {Parent = ScreenGui, BackgroundColor3 = ESPSettings.Drawing.Boxes.Corner.RGB, Position = UDim2.new(0, 0, 0, 0)})
        local BottomRightDown = Create("Frame", {Parent = ScreenGui, BackgroundColor3 = ESPSettings.Drawing.Boxes.Corner.RGB, Position = UDim2.new(0, 0, 0, 0)})
        local function HideESP()
            Box.Visible = false
            Healthbar.Visible = false
            BehindHealthbar.Visible = false
            LeftTop.Visible = false
            LeftSide.Visible = false
            BottomSide.Visible = false
            BottomDown.Visible = false
            RightTop.Visible = false
            RightSide.Visible = false
            BottomRightSide.Visible = false
            BottomRightDown.Visible = false
            Chams.Enabled = false
        end
        local connection
        connection = RunService.RenderStepped:Connect(function()
            if not ESPSettings.Enabled then
                HideESP()
                return
            end
            if plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                local HRP = plr.Character.HumanoidRootPart
                local Humanoid = plr.Character:FindFirstChild("Humanoid")
                if not Humanoid then return end
                local Pos, OnScreen = Cam:WorldToScreenPoint(HRP.Position)
                local Dist = (Cam.CFrame.Position - HRP.Position).Magnitude / 3.5714285714
                if OnScreen and Dist <= ESPSettings.MaxDistance then
                    local Size = HRP.Size.Y
                    local scaleFactor = (Size * Cam.ViewportSize.Y) / (Pos.Z * 2)
                    local w, h = 3 * scaleFactor, 4.5 * scaleFactor
                    if ESPSettings.FadeOut.OnDistance then
                        FadeOutOnDist(Box, Dist)
                        FadeOutOnDist(Outline, Dist)
                        FadeOutOnDist(Healthbar, Dist)
                        FadeOutOnDist(BehindHealthbar, Dist)
                        FadeOutOnDist(LeftTop, Dist)
                        FadeOutOnDist(LeftSide, Dist)
                        FadeOutOnDist(BottomSide, Dist)
                        FadeOutOnDist(BottomDown, Dist)
                        FadeOutOnDist(RightTop, Dist)
                        FadeOutOnDist(RightSide, Dist)
                        FadeOutOnDist(BottomRightSide, Dist)
                        FadeOutOnDist(BottomRightDown, Dist)
                        FadeOutOnDist(Chams, Dist)
                    end
                    if ESPSettings.TeamCheck and plr ~= lplayer and ((lplayer.Team ~= plr.Team and plr.Team) or (not lplayer.Team and not plr.Team)) then
                        Chams.Adornee = plr.Character
                        Chams.Enabled = ESPSettings.Drawing.Chams.Enabled
                        Chams.FillColor = ESPSettings.Drawing.Chams.FillRGB
                        Chams.OutlineColor = ESPSettings.Drawing.Chams.OutlineRGB
                        if ESPSettings.Drawing.Chams.Thermal then
                            local breathe_effect = math.atan(math.sin(tick() * 2)) * 2 / math.pi
                            Chams.FillTransparency = ESPSettings.Drawing.Chams.Fill_Transparency * breathe_effect * 0.01
                            Chams.OutlineTransparency = ESPSettings.Drawing.Chams.Outline_Transparency * breathe_effect * 0.01
                        end
                        Chams.DepthMode = ESPSettings.Drawing.Chams.VisibleCheck and "Occluded" or "AlwaysOnTop"
                        LeftTop.Visible = ESPSettings.Drawing.Boxes.Corner.Enabled
                        LeftTop.Position = UDim2.new(0, Pos.X - w / 2, 0, Pos.Y - h / 2)
                        LeftTop.Size = UDim2.new(0, w / 5, 0, 1)
                        LeftSide.Visible = ESPSettings.Drawing.Boxes.Corner.Enabled
                        LeftSide.Position = UDim2.new(0, Pos.X - w / 2, 0, Pos.Y - h / 2)
                        LeftSide.Size = UDim2.new(0, 1, 0, h / 5)
                        BottomSide.Visible = ESPSettings.Drawing.Boxes.Corner.Enabled
                        BottomSide.Position = UDim2.new(0, Pos.X - w / 2, 0, Pos.Y + h / 2)
                        BottomSide.Size = UDim2.new(0, 1, 0, h / 5)
                        BottomSide.AnchorPoint = Vector2.new(0, 5)
                        BottomDown.Visible = ESPSettings.Drawing.Boxes.Corner.Enabled
                        BottomDown.Position = UDim2.new(0, Pos.X - w / 2, 0, Pos.Y + h / 2)
                        BottomDown.Size = UDim2.new(0, w / 5, 0, 1)
                        BottomDown.AnchorPoint = Vector2.new(0, 1)
                        RightTop.Visible = ESPSettings.Drawing.Boxes.Corner.Enabled
                        RightTop.Position = UDim2.new(0, Pos.X + w / 2, 0, Pos.Y - h / 2)
                        RightTop.Size = UDim2.new(0, w / 5, 0, 1)
                        RightTop.AnchorPoint = Vector2.new(1, 0)
                        RightSide.Visible = ESPSettings.Drawing.Boxes.Corner.Enabled
                        RightSide.Position = UDim2.new(0, Pos.X + w / 2 - 1, 0, Pos.Y - h / 2)
                        RightSide.Size = UDim2.new(0, 1, 0, h / 5)
                        RightSide.AnchorPoint = Vector2.new(0, 0)
                        BottomRightSide.Visible = ESPSettings.Drawing.Boxes.Corner.Enabled
                        BottomRightSide.Position = UDim2.new(0, Pos.X + w / 2, 0, Pos.Y + h / 2)
                        BottomRightSide.Size = UDim2.new(0, 1, 0, h / 5)
                        BottomRightSide.AnchorPoint = Vector2.new(1, 1)
                        BottomRightDown.Visible = ESPSettings.Drawing.Boxes.Corner.Enabled
                        BottomRightDown.Position = UDim2.new(0, Pos.X + w / 2, 0, Pos.Y + h / 2)
                        BottomRightDown.Size = UDim2.new(0, w / 5, 0, 1)
                        BottomRightDown.AnchorPoint = Vector2.new(1, 1)
                        Box.Position = UDim2.new(0, Pos.X - w / 2, 0, Pos.Y - h / 2)
                        Box.Size = UDim2.new(0, w, 0, h)
                        Box.Visible = ESPSettings.Drawing.Boxes.Full.Enabled
                        if ESPSettings.Drawing.Boxes.Filled.Enabled then
                            Box.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                            Box.BackgroundTransparency = ESPSettings.Drawing.Boxes.GradientFill and ESPSettings.Drawing.Boxes.Filled.Transparency or 1
                            Box.BorderSizePixel = 1
                        else
                            Box.BackgroundTransparency = 1
                        end
                        RotationAngle = RotationAngle + (tick() - Tick) * ESPSettings.Drawing.Boxes.RotationSpeed * math.cos(math.pi / 4 * tick() - math.pi / 2)
                        if ESPSettings.Drawing.Boxes.Animate then
                            Gradient1.Rotation = RotationAngle
                            Gradient2.Rotation = RotationAngle
                        else
                            Gradient1.Rotation = -45
                            Gradient2.Rotation = -45
                        end
                        Tick = tick()
                        local health = Humanoid.Health / Humanoid.MaxHealth
                        Healthbar.Visible = ESPSettings.Drawing.Healthbar.Enabled
                        Healthbar.Position = UDim2.new(0, Pos.X - w / 2 - 6, 0, Pos.Y - h / 2 + h * (1 - health))
                        Healthbar.Size = UDim2.new(0, ESPSettings.Drawing.Healthbar.Width, 0, h * health)
                        BehindHealthbar.Visible = ESPSettings.Drawing.Healthbar.Enabled
                        BehindHealthbar.Position = UDim2.new(0, Pos.X - w / 2 - 6, 0, Pos.Y - h / 2)
                        BehindHealthbar.Size = UDim2.new(0, ESPSettings.Drawing.Healthbar.Width, 0, h)
                    else
                        HideESP()
                    end
                else
                    HideESP()
                end
            else
                HideESP()
            end
        end)
        Connections[plr] = {connection}
    end
    function ESPManager:Start()
        if ScreenGui then return end
        ScreenGui = Create("ScreenGui", {
            Parent = CoreGui,
            Name = "ESPHolder",
        })
        for _, v in pairs(Players:GetPlayers()) do
            if v ~= lplayer and not Connections[v] then
                CreatePlayerESP(v)
            end
        end
        Connections.PlayerAdded = Players.PlayerAdded:Connect(function(v)
            if v ~= lplayer and not Connections[v] then
                CreatePlayerESP(v)
            end
        end)
    end
    function ESPManager:Stop()
        if ScreenGui then
            ScreenGui:Destroy()
            ScreenGui = nil
        end
        for _, conn in pairs(Connections) do
            if type(conn) == "table" then
                for _, c in ipairs(conn) do
                    c:Disconnect()
                end
            else
                conn:Disconnect()
            end
        end
        Connections = {}
    end
    function ESPManager:SetEnabled(enabled)
        ESPSettings.Enabled = enabled
        if enabled then
            self:Start()
        else
            self:Stop()
        end
    end
end

Tabs.Visual:Toggle({
    Title = "ESP2",
    Desc = "增强型玩家透视",
    Value = false,
    Callback = function(value)
        ESPManager:SetEnabled(value)
    end
})
local originalCharacterData = {}
local transparencyLoopConnection = nil
local rainbowColor = Color3.fromHSV(0, 1, 1)
local function restoreCharacterAppearance()
    for part, data in pairs(originalCharacterData) do
        if part and part.Parent then
            part.Material = data.material
            part.Color = data.color
            part.Transparency = data.transparency
        end
    end
    originalCharacterData = {}
end
local function updateRainbowColor()
    local hue = tick() % 1
    rainbowColor = Color3.fromHSV(hue, 1, 1)
end
local function transparencyLoop()
    if not me.Character then
        if next(originalCharacterData) then
            restoreCharacterAppearance()
        end
        return
    end
    local isRainbowEnabled = transparentRainbowToggle and transparentRainbowToggle.Value or false
    if isRainbowEnabled then
        updateRainbowColor()
    end
    for _, part in ipairs(me.Character:GetDescendants()) do
        if part:IsA("BasePart") then
            if not originalCharacterData[part] then
                originalCharacterData[part] = {
                    material = part.Material,
                    color = part.Color,
                    transparency = part.Transparency
                }
            end
            part.Material = Enum.Material.ForceField
            if isRainbowEnabled then
                part.Color = rainbowColor
            else
                part.Color = originalCharacterData[part].color
            end
            part.Transparency = 0
        end
    end
end
local transparentToggle = nil
local transparentRainbowToggle = nil
transparentToggle = Tabs.Visual:Toggle({
    Title = "人物透明",
    Desc = "使自己的角色半透明",
    Value = false,
    Callback = function(value)
        if value then
            if transparencyLoopConnection then transparencyLoopConnection:Disconnect() end
            transparencyLoopConnection = run.Heartbeat:Connect(transparencyLoop)
        else
            if transparencyLoopConnection then
                transparencyLoopConnection:Disconnect()
                transparencyLoopConnection = nil
            end
            restoreCharacterAppearance()
        end
    end
})
transparentRainbowToggle = Tabs.Visual:Toggle({
    Title = "人物变色",
    Desc = "角色颜色渐变",
    Value = false,
    Callback = function(value)
        if not value and transparentToggle.Value then
            restoreCharacterAppearance()
            task.wait()
            transparencyLoop()
        end
    end
})
local MainTab = Window:Tab({ Title = "无敌功能", })
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

local Utility = {}
function Utility:GetCharacter(plr)
    return plr.Character or plr.CharacterAdded:Wait()
end
function Utility:GetHumanoid(char)
    return char:FindFirstChildOfClass("Humanoid")
end
function Utility:GetHead(char)
    return char:FindFirstChild("Head")
end
function Utility:GetRootPart(char)
    return char:FindFirstChild("HumanoidRootPart")
end
function Utility:GetDistance(pos1, pos2)
    return (pos1 - pos2).Magnitude
end
function Utility:Random(min, max)
    return math.random(min, max)
end

local features = {
    HeadDamageReduction = false,
    HeadProtectionBox = false,
    HideHeadMode = false,
    AutoParry = false,
    AutoExecute = false,
    AutoParryDistance = 10
}

local headDamageConnection = nil
local protectionPart = nil
local hideHeadConnection = nil
local autoParryConnection = nil
local autoExecuteConnection = nil
local originalHeadProperties = {}

local function applyHideHead(character, hide)
    local head = Utility:GetHead(character)
    if not head then return end
    if hide then
        originalHeadProperties[character] = {
            Transparency = head.Transparency,
            CanCollide = head.CanCollide,
            CanQuery = head.CanQuery,
            Massless = head.Massless,
            Size = head.Size
        }
        head.Transparency = 1
        head.CanCollide = false
        head.CanQuery = false
        head.Massless = true
        head.Size = Vector3.new(0.1, 0.1, 0.1)
    else
        local props = originalHeadProperties[character]
        if props then
            head.Transparency = props.Transparency
            head.CanCollide = props.CanCollide
            head.CanQuery = props.CanQuery
            head.Massless = props.Massless
            head.Size = props.Size
            originalHeadProperties[character] = nil
        else
            head.Transparency = 0
            head.CanCollide = true
            head.CanQuery = true
            head.Massless = false
            head.Size = Vector3.new(2, 1, 1)
        end
    end
end

local function onCharacterAdded(character)
    if features.HeadDamageReduction then
        local humanoid = Utility:GetHumanoid(character)
        if humanoid then
            if headDamageConnection then headDamageConnection:Disconnect() end
            headDamageConnection = humanoid.HealthChanged:Connect(function(newHealth)
                local damage = humanoid.MaxHealth - newHealth
                if damage > 30 then
                    humanoid.Health = newHealth + damage * 0.5
                end
            end)
        end
    end
    
    if features.HeadProtectionBox then
        local head = Utility:GetHead(character)
        if head then
            pcall(function()
                protectionPart = head:FindFirstChild("HeadProtection")
                if not protectionPart then
                    protectionPart = Instance.new("Part")
                    protectionPart.Name = "HeadProtection"
                    protectionPart.Size = Vector3.new(3, 3, 3)
                    protectionPart.Transparency = 1
                    protectionPart.CanCollide = true
                    protectionPart.Anchored = false
                    protectionPart.Parent = head
                    local weld = Instance.new("Weld")
                    weld.Part0 = head
                    weld.Part1 = protectionPart
                    weld.Parent = protectionPart
                end
            end)
        end
    end

    if features.HideHeadMode then
        applyHideHead(character, true)
    end
end

local function onCharacterRemoving()
    if headDamageConnection then
        headDamageConnection:Disconnect()
        headDamageConnection = nil
    end
    if protectionPart then
        pcall(function() protectionPart:Destroy() end)
        protectionPart = nil
    end
end

local function toggleHeadDamageReduction(state)
    features.HeadDamageReduction = state
    if state then
        local char = Utility:GetCharacter(LocalPlayer)
        local humanoid = Utility:GetHumanoid(char)
        if humanoid then
            if headDamageConnection then headDamageConnection:Disconnect() end
            headDamageConnection = humanoid.HealthChanged:Connect(function(newHealth)
                local damage = humanoid.MaxHealth - newHealth
                if damage > 30 then
                    humanoid.Health = newHealth + damage * 0.5
                end
            end)
        end
    else
        if headDamageConnection then
            headDamageConnection:Disconnect()
            headDamageConnection = nil
        end
    end
end

local function toggleHeadProtectionBox(state)
    features.HeadProtectionBox = state
    if state then
        local char = Utility:GetCharacter(LocalPlayer)
        local head = Utility:GetHead(char)
        if head then
            pcall(function()
                protectionPart = head:FindFirstChild("HeadProtection")
                if not protectionPart then
                    protectionPart = Instance.new("Part")
                    protectionPart.Name = "HeadProtection"
                    protectionPart.Size = Vector3.new(3, 3, 3)
                    protectionPart.Transparency = 1
                    protectionPart.CanCollide = true
                    protectionPart.Anchored = false
                    protectionPart.Parent = head
                    local weld = Instance.new("Weld")
                    weld.Part0 = head
                    weld.Part1 = protectionPart
                    weld.Parent = protectionPart
                end
            end)
        end
    else
        if protectionPart then
            pcall(function() protectionPart:Destroy() end)
            protectionPart = nil
        end
    end
end

local function toggleHideHeadMode(state)
    features.HideHeadMode = state
    local char = Utility:GetCharacter(LocalPlayer)
    if state then
        applyHideHead(char, true)
    else
        applyHideHead(char, false)
    end
end

local function toggleAutoParry(state)
    features.AutoParry = state
    if autoParryConnection then
        autoParryConnection:Disconnect()
        autoParryConnection = nil
    end
    if state then
        autoParryConnection = RunService.Heartbeat:Connect(function()
            local char = Utility:GetCharacter(LocalPlayer)
            local root = Utility:GetRootPart(char)
            if not root then return end
            local distanceThreshold = features.AutoParryDistance
            for _, player in ipairs(Players:GetPlayers()) do
                if player == LocalPlayer then continue end
                local character = Utility:GetCharacter(player)
                local targetRoot = Utility:GetRootPart(character)
                if targetRoot then
                    local distance = Utility:GetDistance(root.Position, targetRoot.Position)
                    if distance <= distanceThreshold then
                        local tool = character:FindFirstChildOfClass("Tool")
                        if tool and tool:IsA("Tool") then
                            pcall(function()
                                if syn and syn.input then
                                    syn.input:SendKeyEvent("Q", true)
                                    task.wait(0.1)
                                    syn.input:SendKeyEvent("Q", false)
                                elseif keypress and keyrelease then
                                    keypress(0x51)
                                    task.wait(0.1)
                                    keyrelease(0x51)
                                else
                                    local VirtualUser = game:GetService("VirtualUser")
                                    VirtualUser:CaptureController()
                                    VirtualUser:ClickButton1(Vector2.new(0,0))
                                end
                            end)
                        end
                    end
                end
            end
        end)
    end
end

local function toggleAutoExecute(state)
    features.AutoExecute = state
    if autoExecuteConnection then
        autoExecuteConnection:Disconnect()
        autoExecuteConnection = nil
    end
    if state then
        autoExecuteConnection = RunService.RenderStepped:Connect(function()
            local char = Utility:GetCharacter(LocalPlayer)
            local mouseTarget = Mouse.Target
            if mouseTarget then
                local targetChar = mouseTarget:FindFirstAncestorOfClass("Model")
                if targetChar and targetChar:FindFirstChild("Downed") then
                    pcall(function()
                        local tool = char:FindFirstChildOfClass("Tool")
                        if tool then
                            tool:Activate()
                        end
                    end)
                end
            end
        end)
    end
end

local function setupCharacterEvents()
    LocalPlayer.CharacterAdded:Connect(function(character)
        onCharacterAdded(character)
    end)
    LocalPlayer.CharacterRemoving:Connect(function()
        onCharacterRemoving()
    end)
    if LocalPlayer.Character then
        onCharacterAdded(LocalPlayer.Character)
    end
end
MainTab:Button({
    Title = "antikick(防踢 必须开)",
    Callback = function()
        local v4 = next
        local v5, v6 = getgc(true)
        while true do
            local v7
            v6, v7 = v4(v5, v6)
            if v6 == nil then
                break
            end
            if typeof(v7) == "function" and (getfenv(v7).script and (getfenv(v7).script.Parent == nil and not isourclosure(v7))) then
                local v8 = debug.info(v7, "s")
                if v8 ~= "[C]" and not (v8:find("Network") or v8:find("PlayerGui.Client")) then
                    hookfunction(v7, function()
                        return coroutine.yield()
                    end)
                end
            end
        end
    end
})
MainTab:Toggle({
    Title = "头部伤害减免",
    Value = false,
    Callback = toggleHeadDamageReduction
})
MainTab:Toggle({
    Title = "头部保护碰撞箱",
    Value = false,
    Callback = toggleHeadProtectionBox
})
MainTab:Toggle({
    Title = "藏头",
    Value = false,
    Callback = toggleHideHeadMode
})
MainTab:Toggle({
    Title = "自动格挡",
    Value = false,
    Callback = toggleAutoParry
})
MainTab:Slider({
    Title = "自动格挡距离",
    Value = {
        Min = 0,
        Max = 30,
        Default = 10,
    },
    Callback = function(value)
        features.AutoParryDistance = value
    end
})
MainTab:Toggle({
    Title = "自动处决",
    Value = false,
    Callback = toggleAutoExecute
})

setupCharacterEvents()    
      end
})
Section:Button({
    Title = "TY脚本-钓鱼模拟器",
    Callback = function()
    
function Notify(Title1, Text1, Icon1, Time1)
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = Title1,
        Text = Text1,
        Icon = Icon1,
        Duration = Time1,
    })
end
Notify("TY脚本", "作者：小夜", "rbxassetid://108228172425291", 3)

Notify("运行", "启动成功", "rbxassetid://108228172425291", 3)

local Library = loadstring(game:HttpGet('https://raw.githubusercontent.com/Zephyr688/Lua-Script/refs/heads/main/UI'))()
local Window = Library:new("TY脚本")

-- 公告标签
local creds = Window:Tab("公告", '16060333448')
local bin = creds:section("信息", true)
bin:Label("你的用户名:"..game.Players.LocalPlayer.Name)
bin:Label("你的注入器:"..identifyexecutor())
bin:Label("服务器id:"..game.GameId)

local bin = creds:section("作者", true)
bin:Label("作者：权威")
bin:Label("爱徒：诀别")
bin:Label("请勿倒卖")
bin:Label("目前支持的服务器比较少")
bin:Label("每个服务器都有自己的脚本")
bin:Label("不支持的服务器用通用脚本代替")
bin:Button("复制作者QQ", function()
    setclipboard("3935754168")
end)
bin:Button("复制QQ群", function()
    setclipboard("948082232")
end)
bin:Button("关闭UI", function()
    game:GetService("CoreGui")["frosty is cute"]:Destroy()
end)

-- 检测标签
local creds = Window:Tab("检测", '16060333448') -- 修正window为Window
local kc = creds:section("服务器检测", true)
kc:Label("你所在的服务器:"..game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name)

local credis = creds:section("提示信息", true) -- 添加缺失的section定义
credis:Label("正在使用钓鱼模拟器脚本")
credis:Button("进入[自然灾害]服务器", function()
    local game_id = 189707
    game:GetService("TeleportService"):Teleport(game_id, game.Players.LocalPlayer)
end)

local creds = Window:Tab("钓鱼模拟器", '16060333448') 
local credits = creds:section("钓鱼模拟器", true)

credits:Button("自动抓捕","text",false,function(State)
 toggle = State
    while toggle do
        wait(2.6)
        game:GetService("ReplicatedStorage").CloudFrameShared.DataStreams.FishCaught:FireServer()
    end
end)
credits:Button("自动售卖","text",false,function(State)
 toggle = State
    while toggle do
        wait(2.6)
        game:GetService("ReplicatedStorage").CloudFrameShared.DataStreams.processGameItemSold:InvokeServer("SellEverything")
    end
end)
credits:Button("每日宝箱","text",false,function(State)
 toggle = State
        while toggle do
                for i, v in pairs(game.Workspace.Islands:GetDescendants()) do
                    if v:IsA("Model") and string.match(v.Name, "Chest") then
                        game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = v.HumanoidRootPart.CFrame
                        wait(1)
                        fireproximityprompt(v.HumanoidRootPart.ProximityPrompt)
                    end
                end            
        end
end)
credits:Button("随机宝箱","text",false,function(State)
 toggle = State
        while toggle do
                for i, v in pairs(game.Workspace.RandomChests:GetDescendants()) do
                    if v:IsA("Model") and string.match(v.Name, "Chest") then
                        game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = v.HumanoidRootPart.CFrame
                        wait(1)
                        fireproximityprompt(v.HumanoidRootPart.ProximityPrompt)
                    end
                end            
        end
end)
local wood_types = {"选择", "Earth Egg","Alien Egg","Dominus Egg","Ice Egg","Lava Egg","Heavens Egg","Toy Egg","Mine Egg"}
if not game.workspace:FindFirstChild("PFA") then 
    local part = Instance.new("Part") 
    part.Name = "PFA" 
    part.Parent = game.workspace 
    part.CFrame = CFrame.new(-1087, -40, 1670) 
    part.Size = Vector3.new(50, 0, 50) 
    part.Anchored = true 
    part.Reflectance = 1 
end

function C() 
    spawn(function () 
        while getgenv().C do
            for i, v in pairs(game.Players.LocalPlayer.Backpack:GetChildren()) do 
                TPCFrame(CFrame.new(-1087, -35, 1670))
                if v.ToolTip == "Weight" then 
                    v.Parent = game.Players.LocalPlayer.Character 
                end
                if game.Players.LocalPlayer.Character:FindFirstChildWhichIsA("Tool") then 
                    game.Players.LocalPlayer.Character:FindFirstChildWhichIsA("Tool"):Activate() 
                end
            end 
            wait()
        end
    end)
end

function U() 
    spawn(function () 
        while getgenv().U do
            local args = {[1] = "S_Controller_Upgrades_Upgrade",[2] = {[1] = "Damage_Multiplier"}}
            game:GetService("ReplicatedStorage").Shared.Services:FindFirstChild("3 | Network").RemoteEvent:FireServer(unpack(args))
            local args = {[1] = "S_Controller_Upgrades_Upgrade",[2] = {[1] = "Health_Multiplier"}}
            game:GetService("ReplicatedStorage").Shared.Services:FindFirstChild("3 | Network").RemoteEvent:FireServer(unpack(args))
            local args = {[1] = "S_Controller_Upgrades_Upgrade",[2] = {[1] = "Jump_Power"}}
            game:GetService("ReplicatedStorage").Shared.Services:FindFirstChild("3 | Network").RemoteEvent:FireServer(unpack(args))
            local args = {[1] = "S_Controller_Upgrades_Upgrade",[2] = {[1] = "Walk_Speed"}}
            game:GetService("ReplicatedStorage").Shared.Services:FindFirstChild("3 | Network").RemoteEvent:FireServer(unpack(args))
            local args = {[1] = "S_Controller_Upgrades_Upgrade",[2] = {[1] = "Pet_Space"}}
            game:GetService("ReplicatedStorage").Shared.Services:FindFirstChild("3 | Network").RemoteEvent:FireServer(unpack(args))
            local args = {[1] = "S_Controller_Upgrades_Upgrade",[2] = {[1] = "Pet_Inventory"}}
            game:GetService("ReplicatedStorage").Shared.Services:FindFirstChild("3 | Network").RemoteEvent:FireServer(unpack(args))
            wait()
        end
    end)
end

function R() 
    spawn(function () 
        while getgenv().R do
            local args = {[1] = "S_Controller_Rebirth_Rebirth",[2] = {}}
            game:GetService("ReplicatedStorage").Shared.Services:FindFirstChild("3 | Network").RemoteEvent:FireServer(unpack(args))
            wait()
        end
    end)
end

function H(E) 
    spawn(function () 
        while getgenv().H do
            local args = {[1] = "S_Controller_Eggs_Buy",[2] = {[1] = E}}
            game:GetService("ReplicatedStorage").Shared.Services:FindFirstChild("3 | Network").RemoteFunction:InvokeServer(unpack(args))
            wait()
        end
    end)
end

credits:Button("玩家加入游戏提示",function()
loadstring(game:HttpGet("https://raw.githubusercontent.com/boyscp/scriscriptsc/main/bbn.lua"))()
end)

credits:Button("汉化穿墙",function()
loadstring(game:HttpGet("https://raw.githubusercontent.com/TtmScripter/OtherScript/main/Noclip"))()
end)
    
credits:Button("飞行",function()
loadstring(game:HttpGet("https://pastefy.app/J9x7RnEZ/raw"))()
end)

credits:Button("透视",function()  
    _G.FriendColor = Color3.fromRGB(0, 0, 255)
        local function ApplyESP(v)
       if v.Character and v.Character:FindFirstChildOfClass'Humanoid' then
           v.Character.Humanoid.NameDisplayDistance = 9e9
           v.Character.Humanoid.NameOcclusion = "NoOcclusion"
           v.Character.Humanoid.HealthDisplayDistance = 9e9
           v.Character.Humanoid.HealthDisplayType = "AlwaysOn"
           v.Character.Humanoid.Health = v.Character.Humanoid.Health -- triggers changed
       end
    end
    for i,v in pairs(game.Players:GetPlayers()) do
       ApplyESP(v)
       v.CharacterAdded:Connect(function()
           task.wait(0.33)
           ApplyESP(v)
       end)
    end
    
    game.Players.PlayerAdded:Connect(function(v)
       ApplyESP(v)
       v.CharacterAdded:Connect(function()
           task.wait(0.33)
           ApplyESP(v)
       end)
    end)
    
        local Players = game:GetService("Players"):GetChildren()
    local RunService = game:GetService("RunService")
    local highlight = Instance.new("Highlight")
    highlight.Name = "Highlight"
    
    for i, v in pairs(Players) do
        repeat wait() until v.Character
        if not v.Character:FindFirstChild("HumanoidRootPart"):FindFirstChild("Highlight") then
            local highlightClone = highlight:Clone()
            highlightClone.Adornee = v.Character
            highlightClone.Parent = v.Character:FindFirstChild("HumanoidRootPart")
            highlightClone.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
            highlightClone.Name = "Highlight"
        end
    end
    
    game.Players.PlayerAdded:Connect(function(player)
        repeat wait() until player.Character
        if not player.Character:FindFirstChild("HumanoidRootPart"):FindFirstChild("Highlight") then
            local highlightClone = highlight:Clone()
            highlightClone.Adornee = player.Character
            highlightClone.Parent = player.Character:FindFirstChild("HumanoidRootPart")
            highlightClone.Name = "Highlight"
        end
    end)
    
    game.Players.PlayerRemoving:Connect(function(playerRemoved)
        playerRemoved.Character:FindFirstChild("HumanoidRootPart").Highlight:Destroy()
    end)
    
    RunService.Heartbeat:Connect(function()
        for i, v in pairs(Players) do
            repeat wait() until v.Character
            if not v.Character:FindFirstChild("HumanoidRootPart"):FindFirstChild("Highlight") then
                local highlightClone = highlight:Clone()
                highlightClone.Adornee = v.Character
                highlightClone.Parent = v.Character:FindFirstChild("HumanoidRootPart")
                highlightClone.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                highlightClone.Name = "Highlight"
                task.wait()
            end
    end
    end)
    end)

credits:Toggle("夜视","Toggle",false,function(Value)
if Value then

		    game.Lighting.Ambient = Color3.new(1, 1, 1)

		else

		    game.Lighting.Ambient = Color3.new(0, 0, 0)

		end
end)

credits:Toggle("自动互动", "Auto Interact", false, function(state)
        if state then
            autoInteract = true
            while autoInteract do
                for _, descendant in pairs(workspace:GetDescendants()) do
                    if descendant:IsA("ProximityPrompt") then
                        fireproximityprompt(descendant)
                    end
                end
                task.wait(0.25) -- Adjust the wait time as needed
            end
        else
            autoInteract = false
        end
    end)

credits:Toggle("无限跳","Toggle",false,function(Value)
        Jump = Value
        game.UserInputService.JumpRequest:Connect(function()
            if Jump then
                game.Players.LocalPlayer.Character.Humanoid:ChangeState("Jumping")
            end
        end)
    end)

credits:Slider("步行速度!", "WalkSpeed", game.Players.LocalPlayer.Character.Humanoid.WalkSpeed, 16, 400, false, function(Speed)
  spawn(function() while task.wait() do game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = Speed end end)
end)

credits:Slider("跳跃高度!", "JumpPower", game.Players.LocalPlayer.Character.Humanoid.JumpPower, 50, 400, false, function(Jump)
  spawn(function() while task.wait() do game.Players.LocalPlayer.Character.Humanoid.JumpPower = Jump end end)
end)

credits:Slider('设置重力', 'Sliderflag', 196.2, 196.2, 1000,false, function(Value)
        game.Workspace.Gravity = Value
    end)
    
credits:Button("替身",function()
loadstring(game:HttpGet(('https://raw.githubusercontent.com/SkrillexMe/SkrillexLoader/main/SkrillexLoadMain')))()
end)

credits:Button("爬墙",function()
loadstring(game:HttpGet("https://pastebin.com/raw/zXk4Rq2r"))()
end)

credits:Button("iw指令", function()
  loadstring(game:HttpGet(('https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source'),true))()
end)

credits:Button("自瞄可调", function()
  local fov = 100 local smoothness = 10 local crosshairDistance = 5 local RunService = game:GetService("RunService") local UserInputService = game:GetService("UserInputService") local Players = game:GetService("Players") local Cam = game.Workspace.CurrentCamera local FOVring = Drawing.new("Circle") FOVring.Visible = true FOVring.Thickness = 2 FOVring.Color = Color3.fromRGB(0, 255, 0) FOVring.Filled = false FOVring.Radius = fov FOVring.Position = Cam.ViewportSize / 2 local Player = Players.LocalPlayer local PlayerGui = Player:WaitForChild("PlayerGui") local ScreenGui = Instance.new("ScreenGui") ScreenGui.Name = "FovAdjustGui" ScreenGui.Parent = PlayerGui local Frame = Instance.new("Frame") Frame.Name = "MainFrame" Frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30) Frame.BorderColor3 = Color3.fromRGB(128, 0, 128) Frame.BorderSizePixel = 2 Frame.Position = UDim2.new(0.3, 0, 0.3, 0) Frame.Size = UDim2.new(0.4, 0, 0.4, 0) Frame.Active = true Frame.Draggable = true Frame.Parent = ScreenGui local MinimizeButton = Instance.new("TextButton") MinimizeButton.Name = "MinimizeButton" MinimizeButton.Text = "-" MinimizeButton.TextColor3 = Color3.fromRGB(255, 255, 255) MinimizeButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50) MinimizeButton.Position = UDim2.new(0.9, 0, 0, 0) MinimizeButton.Size = UDim2.new(0.1, 0, 0.1, 0) MinimizeButton.Parent = Frame local isMinimized = false MinimizeButton.MouseButton1Click:Connect(function() isMinimized = not isMinimized if isMinimized then Frame:TweenSize(UDim2.new(0.1, 0, 0.1, 0), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.3, true) MinimizeButton.Text = "+" else Frame:TweenSize(UDim2.new(0.4, 0, 0.4, 0), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.3, true) MinimizeButton.Text = "-" end end) local FovLabel = Instance.new("TextLabel") FovLabel.Name = "FovLabel" FovLabel.Text = "自瞄范围" FovLabel.TextColor3 = Color3.fromRGB(255, 255, 255) FovLabel.BackgroundTransparency = 1 FovLabel.Position = UDim2.new(0.1, 0, 0.1, 0) FovLabel.Size = UDim2.new(0.8, 0, 0.2, 0) FovLabel.Parent = Frame local FovSlider = Instance.new("TextBox") FovSlider.Name = "FovSlider" FovSlider.Text = tostring(fov) FovSlider.TextColor3 = Color3.fromRGB(255, 255, 255) FovSlider.BackgroundColor3 = Color3.fromRGB(50, 50, 50) FovSlider.Position = UDim2.new(0.1, 0, 0.3, 0) FovSlider.Size = UDim2.new(0.8, 0, 0.2, 0) FovSlider.Parent = Frame local SmoothnessLabel = Instance.new("TextLabel") SmoothnessLabel.Name = "SmoothnessLabel" SmoothnessLabel.Text = "自瞄平滑度" SmoothnessLabel.TextColor3 = Color3.fromRGB(255, 255, 255) SmoothnessLabel.BackgroundTransparency = 1 SmoothnessLabel.Position = UDim2.new(0.1, 0, 0.5, 0) SmoothnessLabel.Size = UDim2.new(0.8, 0, 0.2, 0) SmoothnessLabel.Parent = Frame local SmoothnessSlider = Instance.new("TextBox") SmoothnessSlider.Name = "SmoothnessSlider" SmoothnessSlider.Text = tostring(smoothness) SmoothnessSlider.TextColor3 = Color3.fromRGB(255, 255, 255) SmoothnessSlider.BackgroundColor3 = Color3.fromRGB(50, 50, 50) SmoothnessSlider.Position = UDim2.new(0.1, 0, 0.7, 0) SmoothnessSlider.Size = UDim2.new(0.8, 0, 0.2, 0) SmoothnessSlider.Parent = Frame local CrosshairDistanceLabel = Instance.new("TextLabel") CrosshairDistanceLabel.Name = "CrosshairDistanceLabel" CrosshairDistanceLabel.Text = "自瞄预判距离" CrosshairDistanceLabel.TextColor3 = Color3.fromRGB(255, 255, 255) CrosshairDistanceLabel.BackgroundTransparency = 1 CrosshairDistanceLabel.Position = UDim2.new(0.1, 0, 0.9, 0) CrosshairDistanceLabel.Size = UDim2.new(0.8, 0, 0.2, 0) CrosshairDistanceLabel.Parent = Frame local CrosshairDistanceSlider = Instance.new("TextBox") CrosshairDistanceSlider.Name = "CrosshairDistanceSlider" CrosshairDistanceSlider.Text = tostring(crosshairDistance) CrosshairDistanceSlider.TextColor3 = Color3.fromRGB(255, 255, 255) CrosshairDistanceSlider.BackgroundColor3 = Color3.fromRGB(50, 50, 50) CrosshairDistanceSlider.Position = UDim2.new(0.1, 0, 1.1, 0) CrosshairDistanceSlider.Size = UDim2.new(0.8, 0, 0.2, 0) CrosshairDistanceSlider.Parent = Frame local targetCFrame = Cam.CFrame local function updateDrawings() local camViewportSize = Cam.ViewportSize FOVring.Position = camViewportSize / 2 FOVring.Radius = fov end local function onKeyDown(input) if input.KeyCode == Enum.KeyCode.Delete then RunService:UnbindFromRenderStep("FOVUpdate") FOVring:Remove() end end UserInputService.InputBegan:Connect(onKeyDown) local function getClosestPlayerInFOV(trg_part) local nearest = nil local last = math.huge local playerMousePos = Cam.ViewportSize / 2 for _, player in ipairs(Players:GetPlayers()) do if player ~= Players.LocalPlayer then local part = player.Character and player.Character:FindFirstChild(trg_part) if part then local ePos, isVisible = Cam:WorldToViewportPoint(part.Position) local distance = (Vector2.new(ePos.x, ePos.y) - playerMousePos).Magnitude if distance < last and isVisible and distance < fov then last = distance nearest = player end end end end return nearest end RunService.RenderStepped:Connect(function() updateDrawings() local closest = getClosestPlayerInFOV("Head") if closest and closest.Character:FindFirstChild("Head") then local targetCharacter = closest.Character local targetHead = targetCharacter.Head local targetRootPart = targetCharacter:FindFirstChild("HumanoidRootPart") local isMoving = targetRootPart.Velocity.Magnitude > 0.1 local targetPosition if isMoving then targetPosition = targetHead.Position + (targetHead.CFrame.LookVector * crosshairDistance) else targetPosition = targetHead.Position end targetCFrame = CFrame.new(Cam.CFrame.Position, targetPosition) else targetCFrame = Cam.CFrame end Cam.CFrame = Cam.CFrame:Lerp(targetCFrame, 1 / smoothness) end) FovSlider.FocusLost:Connect(function(enterPressed, inputThatCausedFocusLoss) if enterPressed then local newFov = tonumber(FovSlider.Text) if newFov then fov = newFov else FovSlider.Text = tostring(fov) end end end) SmoothnessSlider.FocusLost:Connect(function(enterPressed, inputThatCausedFocusLoss) if enterPressed then local newSmoothness = tonumber(SmoothnessSlider.Text) if newSmoothness then smoothness = newSmoothness else SmoothnessSlider.Text = tostring(smoothness) end end end) CrosshairDistanceSlider.FocusLost:Connect(function(enterPressed, inputThatCausedFocusLoss) if enterPressed then local newCrosshairDistance = tonumber(CrosshairDistanceSlider.Text) if newCrosshairDistance then crosshairDistance = newCrosshairDistance else CrosshairDistanceSlider.Text = tostring(crosshairDistance) end end end)
end)

credits:Button("汉化阿尔宙斯自瞄",function()
loadstring(game:HttpGet("https://raw.githubusercontent.com/dingding123hhh/sgbs/main/%E4%B8%81%E4%B8%81%20%E6%B1%89%E5%8C%96%E8%87%AA%E7%9E%84.txt"))()
end)

credits:Button("工具挂",function()
loadstring(game:HttpGet("https://raw.githubusercontent.com/Bebo-Mods/BeboScripts/main/StandAwekening.lua"))()
end)

credits:Button("甩飞",function()
loadstring(game:HttpGet("https://raw.githubusercontent.com/dingding123hhh/hknvh/main/%E7%94%A9%E9%A3%9E.txt"))()
end)

credits:Button("铁拳",function()
  loadstring(game:HttpGet('https://raw.githubusercontent.com/0Ben1/fe/main/obf_rf6iQURzu1fqrytcnLBAvW34C9N55kS9g9G3CKz086rC47M6632sEd4ZZYB0AYgV.lua.txt'))()
end)

credits:Toggle("ESP 显示名字", "AMG", ENABLED, function(enabled)
    if enabled then ENABLED = true for _, player in ipairs(Players:GetPlayers()) do onPlayerAdded(player) end Players.PlayerAdded:Connect(onPlayerAdded) Players.PlayerRemoving:Connect(onPlayerRemoving) local localPlayer = Players.LocalPlayer if localPlayer and localPlayer.Character then for _, player in ipairs(Players:GetPlayers()) do if player.Character then createNameLabel(player) end end end RunService.Heartbeat:Connect(function() if ENABLED then for _, player in ipairs(Players:GetPlayers()) do if player.Character then createNameLabel(player) end end end end) else ENABLED = false for _, player in ipairs(Players:GetPlayers()) do onPlayerRemoving(player) end RunService:UnbindFromRenderStep("move") end
end)

credits:Button("死亡笔记",function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/xiaopi77/xiaopi77/main/1_1.txt_2024-08-08_153358.OTed.lua"))()
end)
credits:Button("Dex",function()
loadstring(game:HttpGet("https://raw.githubusercontent.com/XiaoFenHG/Dex-Explorer/refs/heads/main/Dex-Explorer.lua"))()
end)
    credits:Button("甩飞",function()
    game:GetService("StarterGui"):SetCore("SendNotification",{ Title = "旋转甩飞"; Text ="汉化：大司马"; Duration = 4; })
game:GetService("StarterGui"):SetCore("SendNotification",{ Title = "旋转甩飞"; Text ="原作者: topit "; Duration = 4; })

local PlayerService = game:GetService("Players")--:GetPlayers()
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local plr = PlayerService.LocalPlayer
local mouse = plr:GetMouse()
local BodyThrust = nil
local Dragging = {}

local Suggestions = {
    2298830673, 300, 365, --gamier (test game)
    1537690962, 250, 350, --bee swarm sim
    5580097107, 300, 400, --frappe
    2202352383, 275, 350, --super power training sim
    142823291, 350, 425,  --murder mystery 2
    155615604, 273, 462,  --prison life
    1990228024, 200, 235, --bloxton hotels
    189707, 250, 325,     --natural disaster survival
    230362888, 265, 415,  --the normal elevator       (may not work)
    5293755937, 335, 435, --speedrun sim
    537413528, 300, 350,  --build a boat              (may not work)
    18540115, 300, 425,   --survive the disasters
    2041312716, 350, 465  --Ragdoll engine
}


local version = ""
local font = Enum.Font.FredokaOne

local AxisPositionX = {
	0.05, 
	0.35,
	0.65
}

local AxisPositionY = {
	40, --edit fling speed
	90, --toggle fling types (normal, qfling, serverkek)
	140, --extra (respawn)
	190, --edit gui settings (hotkey, theme)
	240
}

local Fling = {
	false, --toggle
	"", --hotkey
	300, --speed
	false, --server
	false --stop vertfling
}


--[[themes:]]--

local Theme_JeffStandard = {
	Color3.fromRGB(15, 25, 35),   
	Color3.fromRGB(10, 20, 30),   
	Color3.fromRGB(27, 42, 53),   
	Color3.fromRGB(25, 35, 45),   
	Color3.fromRGB(20, 30, 40),   
	Color3.fromRGB(25, 65, 45),   
	Color3.fromRGB(255, 255, 255),
	Color3.fromRGB(245, 245, 255),
	Color3.fromRGB(155, 155, 255) 
}
local Theme_Dark = {
	Color3.fromRGB(25, 25, 25),   --Top bar
	Color3.fromRGB(10, 10, 10),   --Background
	Color3.fromRGB(40, 40, 40),   --Border color
	Color3.fromRGB(35, 35, 35),   --Button background
	Color3.fromRGB(20, 20, 20),   --Unused
	Color3.fromRGB(25, 100, 45),  --Button highlight
	Color3.fromRGB(255, 255, 255),--Text title
	Color3.fromRGB(245, 245, 255),--Text generic
	Color3.fromRGB(155, 155, 255) --Text highlight
}
local Theme_Steel = {
	Color3.fromRGB(25, 25, 35),   --Top bar
	Color3.fromRGB(10, 10, 20),   --Background
	Color3.fromRGB(40, 40, 50),   --Border color
	Color3.fromRGB(35, 35, 45),   --Button background
	Color3.fromRGB(20, 20, 25),   --Unused
	Color3.fromRGB(25, 100, 55),  --Button highlight
	Color3.fromRGB(255, 255, 255),--Text title
	Color3.fromRGB(245, 245, 255),--Text generic
	Color3.fromRGB(155, 155, 255) --Text highlight
}
local Theme_Rust = {
	Color3.fromRGB(45, 25, 25),   
	Color3.fromRGB(30, 10, 10),   
	Color3.fromRGB(60, 40, 40),   
	Color3.fromRGB(55, 35, 35),   
	Color3.fromRGB(40, 20, 20),   
	Color3.fromRGB(45, 100, 45),  
	Color3.fromRGB(255, 255, 255),
	Color3.fromRGB(255, 245, 255),
	Color3.fromRGB(175, 155, 255) 
}
local Theme_Violet = {
	Color3.fromRGB(35, 25, 45),   --Top bar
	Color3.fromRGB(20, 10, 30),   --Background
	Color3.fromRGB(50, 40, 60),   --Border color
	Color3.fromRGB(45, 35, 55),   --Button background
	Color3.fromRGB(30, 20, 40),   --Unused
	Color3.fromRGB(35, 100, 65),  --Button highlight
	Color3.fromRGB(255, 255, 255),--Text title
	Color3.fromRGB(245, 245, 255),--Text generic
	Color3.fromRGB(155, 155, 255) --Text highlight
}
local Theme_Space = {
	Color3.fromRGB(10, 10, 10),   --Top bar
	Color3.fromRGB(0, 0, 0),   --Background
	Color3.fromRGB(20, 20, 20),   --Border color
	Color3.fromRGB(15, 15, 15),   --Button background
	Color3.fromRGB(5, 5, 5),   --Unused
	Color3.fromRGB(20, 25, 50),  --Button highlight
	Color3.fromRGB(255, 255, 255),--Text title
	Color3.fromRGB(245, 245, 255),--Text generic
	Color3.fromRGB(155, 155, 255) --Text highlight
}
local Theme_SynX = {
	Color3.fromRGB(75, 75, 75),   --Top bar
	Color3.fromRGB(45, 45, 45),   --Background
	Color3.fromRGB(45, 45, 45),   --Border color
	Color3.fromRGB(75, 75, 75),   --Button background
	Color3.fromRGB(0, 0, 5),   --Unused
	Color3.fromRGB(150, 75, 20),  --Button highlight
	Color3.fromRGB(255, 255, 255),--Text title
	Color3.fromRGB(245, 245, 255),--Text generic
	Color3.fromRGB(155, 155, 255) --Text highlight
}


local SelectedTheme = math.random(1,6)
if SelectedTheme == 1 then
    SelectedTheme = Theme_Steel
elseif SelectedTheme == 2 then
    SelectedTheme = Theme_Dark
elseif SelectedTheme == 3 then
    SelectedTheme = Theme_Rust
elseif SelectedTheme == 4 then
    SelectedTheme = Theme_Violet
elseif SelectedTheme == 5 then
    SelectedTheme = Theme_Space
elseif SelectedTheme == 6 then
    if syn then
        SelectedTheme = Theme_SynX
    else
        SelectedTheme = Theme_JeffStandard
    end
end

--[[instances:]]--
local ScreenGui = Instance.new("ScreenGui")
local TitleBar = Instance.new("Frame")
local Shadow = Instance.new("Frame")
local Menu = Instance.new("ScrollingFrame")

local TitleText = Instance.new("TextLabel")
local TitleTextShadow = Instance.new("TextLabel")
local CreditText = Instance.new("TextLabel")
local SuggestionText = Instance.new("TextLabel")

local SpeedBox = Instance.new("TextBox")
local Hotkey = Instance.new("TextBox")

local SpeedUp = Instance.new("TextButton")
local SpeedDown = Instance.new("TextButton")
local ToggleFling = Instance.new("TextButton")
local ToggleServerKill = Instance.new("TextButton")
local NoVertGain = Instance.new("TextButton")
local Respawn = Instance.new("TextButton")
local CloseButton = Instance.new("TextButton")

--local BodyThrust = Instance.new("BodyThrust")

ScreenGui.Name = "JeffFling"
ScreenGui.Parent = game.CoreGui
ScreenGui.Enabled = true

TitleBar.Name = "Title Bar"
TitleBar.Parent = ScreenGui
TitleBar.BackgroundColor3 = SelectedTheme[1]
TitleBar.BorderColor3 = SelectedTheme[3]
TitleBar.Position = UDim2.new(-0.3, 0, 0.7, 0)
TitleBar.Size = UDim2.new(0, 400, 0, 250)
TitleBar.Draggable = true
TitleBar.Active = true
TitleBar.Selectable = true
TitleBar.ZIndex = 100

Shadow.Name = "Shadow"
Shadow.Parent = TitleBar
Shadow.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
Shadow.BackgroundTransparency = 0.5
Shadow.BorderSizePixel = 0
Shadow.Position = UDim2.new(0, 5, 0, 5)
Shadow.Size = TitleBar.Size
Shadow.ZIndex = 50

Menu.Name = "Menu"
Menu.Parent = TitleBar
Menu.BackgroundColor3 = SelectedTheme[2]
Menu.BorderColor3 = SelectedTheme[3]
Menu.AnchorPoint = Vector2.new(0,0)
Menu.Position = UDim2.new(0, 0, 0, 50)
Menu.Size = UDim2.new(0, 400, 0, 200)
Menu.CanvasSize = UDim2.new(0, TitleBar.Size.X, 0, 325)
Menu.ScrollBarImageTransparency = 0.5
Menu.ZIndex = 200

TitleText.Name = "Title Text"
TitleText.Parent = TitleBar
TitleText.AnchorPoint = Vector2.new(0, 0)
TitleText.Position = UDim2.new(0, 100, 0, 25)
TitleText.Font = font
TitleText.Text = "             旋转甩飞脚本【汉化作者：小夜】"..version
TitleText.TextColor3 = SelectedTheme[8]
TitleText.TextSize = 28
TitleText.ZIndex = 300
TitleText.BackgroundTransparency = 1

TitleTextShadow.Name = "Shadow"
TitleTextShadow.Parent = TitleText
TitleTextShadow.Font = font
TitleTextShadow.Text = "甩飞"..version
TitleTextShadow.TextSize = 28
TitleTextShadow.TextColor3 = Color3.fromRGB(0, 0, 0)
TitleTextShadow.TextTransparency = 0.5
TitleTextShadow.Position = UDim2.new(0, 5, 0, 5)
TitleTextShadow.ZIndex = 250
TitleTextShadow.BackgroundTransparency = 1

SuggestionText.Name = "Suggestion Text"
SuggestionText.Parent = Menu
SuggestionText.Position = UDim2.new(0, 20, 0, 250)
SuggestionText.Font = font
SuggestionText.Text = "e"
SuggestionText.TextColor3 = SelectedTheme[7]
SuggestionText.TextSize = 24
SuggestionText.TextXAlignment = Enum.TextXAlignment.Left
SuggestionText.ZIndex = 300
SuggestionText.BackgroundTransparency = 1

CreditText.Name = "Credit Text"
CreditText.Parent = Menu
CreditText.Position = UDim2.new(0, 20, 0, 300)
CreditText.Font = font
CreditText.Text = "原作者: topit 汉化:小夜 "
CreditText.TextColor3 = SelectedTheme[7]
CreditText.TextSize = 20
CreditText.TextXAlignment = Enum.TextXAlignment.Left
CreditText.ZIndex = 300
CreditText.BackgroundTransparency = 1

SpeedBox.Name = "速度"
SpeedBox.Parent = Menu
SpeedBox.BackgroundColor3 = SelectedTheme[4]
SpeedBox.BorderColor3 = SelectedTheme[3]
SpeedBox.TextColor3 = SelectedTheme[7]
SpeedBox.Position = UDim2.new(AxisPositionX[1], 0, 0, AxisPositionY[1])
SpeedBox.Size = UDim2.new(0, 100, 0, 25)
SpeedBox.Font = Enum.Font.FredokaOne
SpeedBox.Text = "现在的速度: "..Fling[3]
SpeedBox.PlaceholderText = "甩飞速度"
SpeedBox.TextScaled = true
SpeedBox.ZIndex = 300

Hotkey.Name = "Custom Hotkey"
Hotkey.Parent = Menu
Hotkey.BackgroundColor3 = SelectedTheme[4]
Hotkey.BorderColor3 = SelectedTheme[3]
Hotkey.TextColor3 = SelectedTheme[7]
Hotkey.Position = UDim2.new(AxisPositionX[2], 0, 0, AxisPositionY[3])
Hotkey.Size = UDim2.new(0, 100, 0, 25)
Hotkey.Font = Enum.Font.FredokaOne
Hotkey.Text = "推荐5"
Hotkey.PlaceholderText = "数值:"
Hotkey.TextScaled = true
Hotkey.ZIndex = 300

SpeedUp.Name = "Speed Up"
SpeedUp.Parent = Menu
SpeedUp.BackgroundColor3 = SelectedTheme[4]
SpeedUp.BorderColor3 = SelectedTheme[3]
SpeedUp.TextColor3 = SelectedTheme[7]
SpeedUp.Position = UDim2.new((AxisPositionX[2]), 0, 0, (AxisPositionY[1]))
SpeedUp.Size = UDim2.new(0, 100, 0, 25)
SpeedUp.Font = Enum.Font.FredokaOne
SpeedUp.Text = "增加"
SpeedUp.TextScaled = true
SpeedUp.ZIndex = 300

SpeedDown.Name = "Speed Down"
SpeedDown.Parent = Menu
SpeedDown.BackgroundColor3 = SelectedTheme[4]
SpeedDown.BorderColor3 = SelectedTheme[3]
SpeedDown.TextColor3 = SelectedTheme[7]
SpeedDown.Position = UDim2.new((AxisPositionX[3]), 0, 0, (AxisPositionY[1]))
SpeedDown.Size = UDim2.new(0, 100, 0, 25)
SpeedDown.Font = Enum.Font.FredokaOne
SpeedDown.Text = "减少"
SpeedDown.TextScaled = true
SpeedDown.ZIndex = 300

ToggleFling.Name = "Fling toggle"
ToggleFling.Parent = Menu
ToggleFling.BackgroundColor3 = SelectedTheme[4]
ToggleFling.BorderColor3 = SelectedTheme[3]
ToggleFling.TextColor3 = SelectedTheme[7]
ToggleFling.Position = UDim2.new((AxisPositionX[1]), 0, 0, (AxisPositionY[2]))
ToggleFling.Size = UDim2.new(0, 100, 0, 25)
ToggleFling.Font = Enum.Font.FredokaOne
ToggleFling.Text = "点击旋转"
ToggleFling.TextScaled = true
ToggleFling.ZIndex = 300

Respawn.Name = "Respawn"
Respawn.Parent = Menu
Respawn.BackgroundColor3 = SelectedTheme[4]
Respawn.BorderColor3 = SelectedTheme[3]
Respawn.TextColor3 = SelectedTheme[7]
Respawn.Position = UDim2.new((AxisPositionX[1]), 0, 0, (AxisPositionY[3]))
Respawn.Size = UDim2.new(0, 100, 0, 25)
Respawn.Font = Enum.Font.FredokaOne
Respawn.Text = "关闭旋转"
Respawn.TextScaled = true
Respawn.ZIndex = 300

NoVertGain.Name = "NoVertGain"
NoVertGain.Parent = Menu
NoVertGain.BackgroundColor3 = SelectedTheme[4]
NoVertGain.BorderColor3 = SelectedTheme[3]
NoVertGain.TextColor3 = SelectedTheme[7]
NoVertGain.Position = UDim2.new((AxisPositionX[2]), 0, 0, (AxisPositionY[2]))
NoVertGain.Size = UDim2.new(0, 100, 0, 25)
NoVertGain.Font = Enum.Font.FredokaOne
NoVertGain.Text = "推荐"
NoVertGain.TextScaled = true
NoVertGain.ZIndex = 300

ToggleServerKill.Name = ""
ToggleServerKill.Parent = Menu
ToggleServerKill.BackgroundColor3 = SelectedTheme[4]
ToggleServerKill.BorderColor3 = SelectedTheme[3]
ToggleServerKill.TextColor3 = SelectedTheme[7]
ToggleServerKill.Position = UDim2.new((AxisPositionX[3]), 0, 0, (AxisPositionY[2]))
ToggleServerKill.Size = UDim2.new(0, 100, 0, 25)
ToggleServerKill.Font = Enum.Font.FredokaOne
ToggleServerKill.Text = "甩飞"
ToggleServerKill.TextScaled = true
ToggleServerKill.ZIndex = 300

CloseButton.Name = "Close Button"
CloseButton.AnchorPoint = Vector2.new(1, 0)
CloseButton.Parent = TitleBar
CloseButton.BackgroundColor3 = SelectedTheme[4]
CloseButton.BorderColor3 = SelectedTheme[3]
CloseButton.TextColor3 = SelectedTheme[7]
CloseButton.Position = UDim2.new(1, 0, 0, 0)
CloseButton.Size = UDim2.new(0, 25, 0, 25)
CloseButton.Font = Enum.Font.FredokaOne
CloseButton.Text = "关闭"
CloseButton.ZIndex = 300
CloseButton.TextSize = 14

--BodyThrust.Name = "Power"
--BodyThrust.Parent = plr.Character.Torso
--BodyThrust.Force = Vector3.new(0, 0, 0)
--BodyThrust.Location = Vector3.new(0, 0, 0)

--[[functions:]]--
local function DisplayText(title, text, duration)
	duration = duration or 1
	game.StarterGui:SetCore("SendNotification", 
		{
			Title = title;
			Text = text;
			Icon = "";
			Duration = duration;
		}
	)
end

local function DisplaySuggestion()
    for i,v in pairs(Suggestions) do
        if v >= 9999 and v == game.PlaceId then
            DisplayText("推荐速度调250-325","推荐速度调: "..Suggestions[i+1].." - "..Suggestions[i+2])
            SuggestionText.Text = "推荐速度调: "..Suggestions[i+1].." - "..Suggestions[i+2]
        end
    end
    if SuggestionText.Text == "e" then
        SuggestionText.Text = "No suggestion for this game"
    end
end


local function GetRigType()
    
    if plr.Character.Humanoid.RigType == Enum.HumanoidRigType.R15 then
        return Enum.HumanoidRigType.R15
    elseif plr.Character.Humanoid.RigType == Enum.HumanoidRigType.R6 then
        return Enum.HumanoidRigType.R6
    else
        return nil
    end
end

local function GetDeadState(player)
    if player.Character.Humanoid:GetState() == Enum.HumanoidStateType.Dead then
        return true
    else
        return false
    end
end


local function EnableNoClip()
    
    if GetDeadState(plr) == false then
        if GetRigType() == Enum.HumanoidRigType.R6 then
            plr.Character:FindFirstChild("Torso").CanCollide            = false
            plr.Character:FindFirstChild("Head").CanCollide             = false
            plr.Character:FindFirstChild("HumanoidRootPart").CanCollide = false
        elseif GetRigType() == Enum.HumanoidRigType.R15 then
            plr.Character:FindFirstChild("UpperTorso").CanCollide       = false
            plr.Character:FindFirstChild("LowerTorso").CanCollide       = false
            plr.Character:FindFirstChild("Head").CanCollide             = false
            plr.Character:FindFirstChild("HumanoidRootPart").CanCollide = false
        end
    end
end

local function DisableNoClip()
    
    if GetDeadState(plr) == false then
        if GetRigType() == Enum.HumanoidRigType.R6 then
            plr.Character:FindFirstChild("Torso").CanCollide            = true
            plr.Character:FindFirstChild("Head").CanCollide             = true
            plr.Character:FindFirstChild("HumanoidRootPart").CanCollide = true
        elseif GetRigType() == Enum.HumanoidRigType.R15 then
            plr.Character:FindFirstChild("UpperTorso").CanCollide       = true
            plr.Character:FindFirstChild("LowerTorso").CanCollide       = true
            plr.Character:FindFirstChild("Head").CanCollide             = true
            plr.Character:FindFirstChild("HumanoidRootPart").CanCollide = true
        end
    end
end

local function OpenObject(object)
    local OpenAnim = TweenService:Create(
    	object,
    	TweenInfo.new(0.25, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), --Enum.EasingStyle.Linear, Enum.EasingDirection.In
    	{Size = UDim2.new(0, 110, 0, 35), BackgroundColor3 = SelectedTheme[6] }
    )
    
    OpenAnim:Play()
end

local function CloseObject(object)
    local CloseAnim = TweenService:Create(
    	object,
    	TweenInfo.new(0.25, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
    	{Size = UDim2.new(0, 100, 0, 25), BackgroundColor3 = SelectedTheme[4] }
    )
    
    CloseAnim:Play()
end

    
local function TToggleFling()
    Fling[1] = not Fling[1]
    if Fling[1] then
        OpenObject(ToggleFling)
        
        BodyThrust = Instance.new("BodyThrust")
        if GetRigType() == Enum.HumanoidRigType.R6 then
            BodyThrust.Parent = plr.Character.Torso
        elseif GetRigType() == Enum.HumanoidRigType.R15 then
            BodyThrust.Parent = plr.Character.UpperTorso
        end
        
        EnableNoClip()
        BodyThrust.Force = Vector3.new(Fling[3], 0, 0)
        BodyThrust.Location = Vector3.new(0, 0, Fling[3])
        
        
        print("Enabled fling")
    else
        CloseObject(ToggleFling)
        
        DisableNoClip()
        for i, v in pairs(plr.Character:GetDescendants()) do
            if v:IsA("BasePart") then
            v.Velocity, v.RotVelocity = Vector3.new(0, 0, 0), Vector3.new(0, 0, 0)
            end
        end
        BodyThrust:Destroy()
        
        print("Disabled fling")
        
    end
end

local function GetIfPlayerInGame(PlayerToFind)
    if PlayerService:FindFirstChild(PlayerToFind) then
        return true
    else
        return false
    end
end

local function ServerKek()
    local TargetList = {}
    local index = 1
    local playercount = 0
    
    if Fling[1] == true then
        TToggleFling()
    end
    
    for i,v in pairs(PlayerService:GetPlayers()) do
        if v ~= plr then
            playercount = playercount + 1
            table.insert(TargetList, v)
        end
    end
    
    for i,v in pairs(TargetList) do
       print(i,v.Name) 
    end
    
    
    while Fling[4] do
        if index > playercount then
            CloseObject(ToggleServerKill)
            DisplayText("全部甩飞成功","汉化：大司马")
            Fling[4] = false
            break
        else
            local InGame = GetIfPlayerInGame(TargetList[index].Name)
            local Dead = GetDeadState(TargetList[index])
            if InGame == true and Dead == false then
                plr.Character.HumanoidRootPart.CFrame = TargetList[index].Character.HumanoidRootPart.CFrame --tp to them
                
                TToggleFling() --enable fling
                
                for i = 0,2,1 do
                    plr.Character.HumanoidRootPart.CFrame = TargetList[index].Character.HumanoidRootPart.CFrame
                    wait(0.15)
                end
                
                TToggleFling() --disable fling
                
                wait(0.1) --wait until disabled
                
                if plr.Character.Humanoid:GetState() == Enum.HumanoidStateType.Seated then --check if seated
                    plr.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Running) --get out if you are
                end
                
                index = index + 1 --go to next victim
                
                if Fling[4] == false then
                    break
                end
            else
                index = index + 1
            end
        end
    end
end

--[[events:]]--
CloseButton.MouseButton1Down:Connect(function()
    TitleBar:TweenPosition(UDim2.new(-0.3, 0, 0.7, 0), Enum.EasingDirection.In, Enum.EasingStyle.Back, 0.75)
	DisplayText("旋转甩飞关闭","汉化作者：小夜")
	wait(0.8)
	ScreenGui.Enabled = false
	ScreenGui:Destroy()
	script:Destroy()
end)

SpeedUp.MouseButton1Down:Connect(function()
    Fling[3] = Fling[3] + 50
    SpeedBox.Text = "速度: "..Fling[3]
    
    if Fling[1] then
        BodyThrust.Force = Vector3.new(Fling[3], 0, 0)
        BodyThrust.Location = Vector3.new(0, 0, Fling[3])
    end
end)

SpeedDown.MouseButton1Down:Connect(function()
    Fling[3] = Fling[3] - 50
    SpeedBox.Text = "速度: "..Fling[3]
    
    if Fling[1] then
        BodyThrust.Force = Vector3.new(Fling[3], 0, 0)
        BodyThrust.Location = Vector3.new(0, 0, Fling[3])
    end
end)

SpeedBox.FocusLost:Connect(function()
    Fling[3] = SpeedBox.Text:gsub("%D",""):sub(0,5)
    if Fling[3] ~= nil then
        SpeedBox.Text = "速度: "..Fling[3]
        if Fling[1] then
            BodyThrust.Force = Vector3.new(Fling[3], 0, 0)
            BodyThrust.Location = Vector3.new(0, 0, Fling[3])
        end
    end
    
end)

Hotkey.FocusLost:Connect(function()
    Fling[2] = Hotkey.Text:split(" ")[1]:sub(1,1)
    if Fling[2] ~= nil then
        Hotkey.Text = "数值: "..Fling[2]
    end
end)


ToggleFling.MouseButton1Down:Connect(function()
    TToggleFling()
end)

Respawn.MouseButton1Down:Connect(function()
        
    if Fling[1] then --disable fling if its enabled
        TToggleFling()
    end
    
    wait(0.4) --wait for fling to stop
    
    for i=0,10,1 do
        plr.Character.Humanoid:ChangeState(2) --make player recover from falling
    end
    
    for i, v in pairs(plr.Character:GetDescendants()) do
        if v:IsA("BasePart") then
            v.Velocity, v.RotVelocity = Vector3.new(0, 0, 0), Vector3.new(0, 0, 0)
        end
    end
end)

ToggleServerKill.MouseButton1Down:Connect(function()
    Fling[4] = not Fling[4]
    if Fling[4] then
        OpenObject(ToggleServerKill)
        DisplayText("开启全部甩飞","开启成功")
        ServerKek()
    else
        CloseObject(ToggleServerKill)
        DisplayText("关闭全部甩飞","全部甩飞已关闭")
    end
    
end)

NoVertGain.MouseButton1Down:Connect(function()
    Fling[5] = not Fling[5]
    if Fling[5] then
        OpenObject(NoVertGain)
    else
        CloseObject(NoVertGain)
    end
end)

RunService.Stepped:Connect(function()
    if Fling[1] then
        EnableNoClip()
    elseif Fling[5] then
        for i, v in pairs(plr.Character:GetDescendants()) do
            if v:IsA("BasePart") then
                v.Velocity, v.RotVelocity = Vector3.new(0, 0, 0), Vector3.new(0, 0, 0)
            end
        end
    end
end)

TitleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        Dragging[1] = true
        Dragging[2] = input.Position
        Dragging[3] = TitleBar.Position
    end
end)

TitleBar.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        Dragging[1] = false
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then
        if Dragging[1] then
            local delta = input.Position - Dragging[2]
            TitleBar:TweenPosition(UDim2.new(Dragging[3].X.Scale, Dragging[3].X.Offset + delta.X, Dragging[3].Y.Scale, Dragging[3].Y.Offset + delta.Y), Enum.EasingDirection.Out, Enum.EasingStyle.Sine, 0.035)
            wait()
        end
    end
end)

mouse.KeyDown:Connect(function(key)
    if key == Fling[2] then
        TToggleFling()
    end
end)


DisplaySuggestion()
TitleBar:TweenPosition(UDim2.new(0.25, 0, 0.7, 0), Enum.EasingDirection.Out, Enum.EasingStyle.Back, 0.75)
return nil
end)

    credits:Button("飞车",function()
    local Flymguiv2 = Instance.new("ScreenGui")
local Drag = Instance.new("Frame")
local FlyFrame = Instance.new("Frame")
local ddnsfbfwewefe = Instance.new("TextButton")
local Speed = Instance.new("TextBox")
local Fly = Instance.new("TextButton")
local Speeed = Instance.new("TextLabel")
local Stat = Instance.new("TextLabel")
local Stat2 = Instance.new("TextLabel")
local Unfly = Instance.new("TextButton")
local Vfly = Instance.new("TextLabel")
local Close = Instance.new("TextButton")
local Minimize = Instance.new("TextButton")
local Flyon = Instance.new("Frame")
local W = Instance.new("TextButton")
local S = Instance.new("TextButton")

Flymguiv2.Name = "Flym gui v2"
Flymguiv2.Parent = game.CoreGui
Flymguiv2.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

Drag.Name = "Drag"
Drag.Parent = Flymguiv2
Drag.Active = true
Drag.BackgroundColor3 = Color3.fromRGB(0, 150, 191)
Drag.BorderSizePixel = 0
Drag.Draggable = true
Drag.Position = UDim2.new(0.482438415, 0, 0.454874992, 0)
Drag.Size = UDim2.new(0, 237, 0, 27)

FlyFrame.Name = "FlyFrame"
FlyFrame.Parent = Drag
FlyFrame.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
FlyFrame.BorderSizePixel = 0
FlyFrame.Draggable = true
FlyFrame.Position = UDim2.new(-0.00200000009, 0, 0.989000022, 0)
FlyFrame.Size = UDim2.new(0, 237, 0, 139)

ddnsfbfwewefe.Name = "ddnsfbfwewefe"
ddnsfbfwewefe.Parent = FlyFrame
ddnsfbfwewefe.BackgroundColor3 = Color3.fromRGB(0, 150, 191)
ddnsfbfwewefe.BorderSizePixel = 0
ddnsfbfwewefe.Position = UDim2.new(-0.000210968778, 0, -0.00395679474, 0)
ddnsfbfwewefe.Size = UDim2.new(0, 237, 0, 27)
ddnsfbfwewefe.Font = Enum.Font.SourceSans
ddnsfbfwewefe.Text = "小夜"
ddnsfbfwewefe.TextColor3 = Color3.fromRGB(255, 255, 255)
ddnsfbfwewefe.TextScaled = true
ddnsfbfwewefe.TextSize = 14.000
ddnsfbfwewefe.TextWrapped = true

Speed.Name = "右边输入数值"
Speed.Parent = FlyFrame
Speed.BackgroundColor3 = Color3.fromRGB(63, 63, 63)
Speed.BorderColor3 = Color3.fromRGB(0, 0, 191)
Speed.BorderSizePixel = 0
Speed.Position = UDim2.new(0.445025861, 0, 0.402877688, 0)
Speed.Size = UDim2.new(0, 111, 0, 33)
Speed.Font = Enum.Font.SourceSans
Speed.PlaceholderColor3 = Color3.fromRGB(255, 255, 255)
Speed.Text = "50"
Speed.TextColor3 = Color3.fromRGB(255, 255, 255)
Speed.TextScaled = true
Speed.TextSize = 14.000
Speed.TextWrapped = true

Fly.Name = "Fly"
Fly.Parent = FlyFrame
Fly.BackgroundColor3 = Color3.fromRGB(0, 150, 191)
Fly.BorderSizePixel = 0
Fly.Position = UDim2.new(0.0759493634, 0, 0.705797076, 0)
Fly.Size = UDim2.new(0, 199, 0, 32)
Fly.Font = Enum.Font.SourceSans
Fly.Text = "开启飞车"
Fly.TextColor3 = Color3.fromRGB(255, 255, 255)
Fly.TextScaled = true
Fly.TextSize = 14.000
Fly.TextWrapped = true
Fly.MouseButton1Click:Connect(function()
	local HumanoidRP = game.Players.LocalPlayer.Character.HumanoidRootPart
	Fly.Visible = false
	Stat2.Text = "On"
	Stat2.TextColor3 = Color3.fromRGB(0, 255, 0)
	Unfly.Visible = true
	Flyon.Visible = true
	local BV = Instance.new("BodyVelocity",HumanoidRP)
	local BG = Instance.new("BodyGyro",HumanoidRP)
	BV.MaxForce = Vector3.new(math.huge,math.huge,math.huge)
	game:GetService('RunService').RenderStepped:connect(function()
	BG.MaxTorque = Vector3.new(math.huge,math.huge,math.huge)
	BG.D = 5000
	BG.P = 100000
	BG.CFrame = game.Workspace.CurrentCamera.CFrame
	end)
end)

Speeed.Name = "Speeed"
Speeed.Parent = FlyFrame
Speeed.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
Speeed.BorderSizePixel = 0
Speeed.Position = UDim2.new(0.0759493634, 0, 0.402877688, 0)
Speeed.Size = UDim2.new(0, 87, 0, 32)
Speeed.ZIndex = 0
Speeed.Font = Enum.Font.SourceSans
Speeed.Text = "Speed:"
Speeed.TextColor3 = Color3.fromRGB(255, 255, 255)
Speeed.TextScaled = true
Speeed.TextSize = 14.000
Speeed.TextWrapped = true

Stat.Name = "Stat"
Stat.Parent = FlyFrame
Stat.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
Stat.BorderSizePixel = 0
Stat.Position = UDim2.new(0.299983799, 0, 0.239817441, 0)
Stat.Size = UDim2.new(0, 85, 0, 15)
Stat.Font = Enum.Font.SourceSans
Stat.Text = "Status:"
Stat.TextColor3 = Color3.fromRGB(255, 255, 255)
Stat.TextScaled = true
Stat.TextSize = 14.000
Stat.TextWrapped = true

Stat2.Name = "Stat2"
Stat2.Parent = FlyFrame
Stat2.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
Stat2.BorderSizePixel = 0
Stat2.Position = UDim2.new(0.546535194, 0, 0.239817441, 0)
Stat2.Size = UDim2.new(0, 27, 0, 15)
Stat2.Font = Enum.Font.SourceSans
Stat2.Text = "Off"
Stat2.TextColor3 = Color3.fromRGB(255, 0, 0)
Stat2.TextScaled = true
Stat2.TextSize = 14.000
Stat2.TextWrapped = true

Unfly.Name = "Unfly"
Unfly.Parent = FlyFrame
Unfly.BackgroundColor3 = Color3.fromRGB(0, 150, 191)
Unfly.BorderSizePixel = 0
Unfly.Position = UDim2.new(0.0759493634, 0, 0.705797076, 0)
Unfly.Size = UDim2.new(0, 199, 0, 32)
Unfly.Visible = false
Unfly.Font = Enum.Font.SourceSans
Unfly.Text = "Disable"
Unfly.TextColor3 = Color3.fromRGB(255, 255, 255)
Unfly.TextScaled = true
Unfly.TextSize = 14.000
Unfly.TextWrapped = true
Unfly.MouseButton1Click:Connect(function()
	local HumanoidRP = game.Players.LocalPlayer.Character.HumanoidRootPart
	Fly.Visible = true
	Stat2.Text = "关闭"
	Stat2.TextColor3 = Color3.fromRGB(255, 0, 0)
	wait()
	Unfly.Visible = false
	Flyon.Visible = false
	HumanoidRP:FindFirstChildOfClass("BodyVelocity"):Destroy()
	HumanoidRP:FindFirstChildOfClass("BodyGyro"):Destroy()
end)

Vfly.Name = "Vfly"
Vfly.Parent = Drag
Vfly.BackgroundColor3 = Color3.fromRGB(0, 150, 191)
Vfly.BorderSizePixel = 0
Vfly.Size = UDim2.new(0, 57, 0, 27)
Vfly.Font = Enum.Font.SourceSans
Vfly.Text = "小夜 nb"
Vfly.TextColor3 = Color3.fromRGB(255, 255, 255)
Vfly.TextScaled = true
Vfly.TextSize = 14.000
Vfly.TextWrapped = true

Close.Name = "Close"
Close.Parent = Drag
Close.BackgroundColor3 = Color3.fromRGB(0, 150, 191)
Close.BorderSizePixel = 0
Close.Position = UDim2.new(0.875, 0, 0, 0)
Close.Size = UDim2.new(0, 27, 0, 27)
Close.Font = Enum.Font.SourceSans
Close.Text = "X"
Close.TextColor3 = Color3.fromRGB(255, 255, 255)
Close.TextScaled = true
Close.TextSize = 14.000
Close.TextWrapped = true
Close.MouseButton1Click:Connect(function()
	Flymguiv2:Destroy()
end)

Minimize.Name = "Minimize"
Minimize.Parent = Drag
Minimize.BackgroundColor3 = Color3.fromRGB(0, 150, 191)
Minimize.BorderSizePixel = 0
Minimize.Position = UDim2.new(0.75, 0, 0, 0)
Minimize.Size = UDim2.new(0, 27, 0, 27)
Minimize.Font = Enum.Font.SourceSans
Minimize.Text = "-"
Minimize.TextColor3 = Color3.fromRGB(255, 255, 255)
Minimize.TextScaled = true
Minimize.TextSize = 14.000
Minimize.TextWrapped = true
function Mini()
	if Minimize.Text == "-" then
		Minimize.Text = "+"
		FlyFrame.Visible = false
	elseif Minimize.Text == "+" then
		Minimize.Text = "-"
		FlyFrame.Visible = true
	end
end
Minimize.MouseButton1Click:Connect(Mini)

Flyon.Name = "Fly on"
Flyon.Parent = Flymguiv2
Flyon.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
Flyon.BorderSizePixel = 0
Flyon.Position = UDim2.new(0.117647067, 0, 0.550284624, 0)
Flyon.Size = UDim2.new(0.148000002, 0, 0.314999998, 0)
Flyon.Visible = false
Flyon.Active = true
Flyon.Draggable = true

W.Name = "W"
W.Parent = Flyon
W.BackgroundColor3 = Color3.fromRGB(0, 150, 191)
W.BorderSizePixel = 0
W.Position = UDim2.new(0.134719521, 0, 0.0152013302, 0)
W.Size = UDim2.new(0.708999991, 0, 0.499000013, 0)
W.Font = Enum.Font.SourceSans
W.Text = "^"
W.TextColor3 = Color3.fromRGB(255, 255, 255)
W.TextScaled = true
W.TextSize = 14.000
W.TextWrapped = true
W.TouchLongPress:Connect(function()
	local HumanoidRP = game.Players.LocalPlayer.Character.HumanoidRootPart
	HumanoidRP.BodyVelocity.Velocity = game.Workspace.CurrentCamera.CFrame.LookVector * Speed.Text
	wait(.1)
	HumanoidRP.BodyVelocity.Velocity = game.Workspace.CurrentCamera.CFrame.LookVector * Speed.Text
	wait(.1)
	HumanoidRP.BodyVelocity.Velocity = game.Workspace.CurrentCamera.CFrame.LookVector * Speed.Text
	wait(.1)
	HumanoidRP.BodyVelocity.Velocity = game.Workspace.CurrentCamera.CFrame.LookVector * Speed.Text
	wait(.1)
	HumanoidRP.BodyVelocity.Velocity = game.Workspace.CurrentCamera.CFrame.LookVector * Speed.Text
	wait(.1)
	HumanoidRP.BodyVelocity.Velocity = game.Workspace.CurrentCamera.CFrame.LookVector * Speed.Text
	wait(.1)
	HumanoidRP.BodyVelocity.Velocity = game.Workspace.CurrentCamera.CFrame.LookVector * Speed.Text
	wait(.1)
	HumanoidRP.BodyVelocity.Velocity = game.Workspace.CurrentCamera.CFrame.LookVector * Speed.Text
	wait(.1)
	HumanoidRP.BodyVelocity.Velocity = game.Workspace.CurrentCamera.CFrame.LookVector * Speed.Text
	wait(.1)
	HumanoidRP.BodyVelocity.Velocity = game.Workspace.CurrentCamera.CFrame.LookVector * Speed.Text
	wait(.1)
	HumanoidRP.BodyVelocity.Velocity = game.Workspace.CurrentCamera.CFrame.LookVector * 0
end)

W.MouseButton1Click:Connect(function()
	local HumanoidRP = game.Players.LocalPlayer.Character.HumanoidRootPart
	HumanoidRP.BodyVelocity.Velocity = game.Workspace.CurrentCamera.CFrame.LookVector * Speed.Text
	wait(.1)
	HumanoidRP.BodyVelocity.Velocity = game.Workspace.CurrentCamera.CFrame.LookVector * Speed.Text
	wait(.1)
	HumanoidRP.BodyVelocity.Velocity = game.Workspace.CurrentCamera.CFrame.LookVector * Speed.Text
	wait(.1)
	HumanoidRP.BodyVelocity.Velocity = game.Workspace.CurrentCamera.CFrame.LookVector * Speed.Text
	wait(.1)
	HumanoidRP.BodyVelocity.Velocity = game.Workspace.CurrentCamera.CFrame.LookVector * Speed.Text
	wait(.1)
	HumanoidRP.BodyVelocity.Velocity = game.Workspace.CurrentCamera.CFrame.LookVector * Speed.Text
	wait(.1)
	HumanoidRP.BodyVelocity.Velocity = game.Workspace.CurrentCamera.CFrame.LookVector * Speed.Text
	wait(.1)
	HumanoidRP.BodyVelocity.Velocity = game.Workspace.CurrentCamera.CFrame.LookVector * Speed.Text
	wait(.1)
	HumanoidRP.BodyVelocity.Velocity = game.Workspace.CurrentCamera.CFrame.LookVector * Speed.Text
	wait(.1)
	HumanoidRP.BodyVelocity.Velocity = game.Workspace.CurrentCamera.CFrame.LookVector * Speed.Text
	wait(.1)
	HumanoidRP.BodyVelocity.Velocity = game.Workspace.CurrentCamera.CFrame.LookVector * 0
end)

S.Name = "S"
S.Parent = Flyon
S.BackgroundColor3 = Color3.fromRGB(0, 150, 191)
S.BorderSizePixel = 0
S.Position = UDim2.new(0.134000003, 0, 0.479999989, 0)
S.Rotation = 180.000
S.Size = UDim2.new(0.708999991, 0, 0.499000013, 0)
S.Font = Enum.Font.SourceSans
S.Text = "^"
S.TextColor3 = Color3.fromRGB(255, 255, 255)
S.TextScaled = true
S.TextSize = 14.000
S.TextWrapped = true
S.TouchLongPress:Connect(function()
	local HumanoidRP = game.Players.LocalPlayer.Character.HumanoidRootPart
	HumanoidRP.BodyVelocity.Velocity = game.Workspace.CurrentCamera.CFrame.LookVector * -Speed.Text
	wait(.1)
	HumanoidRP.BodyVelocity.Velocity = game.Workspace.CurrentCamera.CFrame.LookVector * -Speed.Text
	wait(.1)
	HumanoidRP.BodyVelocity.Velocity = game.Workspace.CurrentCamera.CFrame.LookVector * -Speed.Text
	wait(.1)
	HumanoidRP.BodyVelocity.Velocity = game.Workspace.CurrentCamera.CFrame.LookVector * -Speed.Text
	wait(.1)
	HumanoidRP.BodyVelocity.Velocity = game.Workspace.CurrentCamera.CFrame.LookVector * -Speed.Text
	wait(.1)
	HumanoidRP.BodyVelocity.Velocity = game.Workspace.CurrentCamera.CFrame.LookVector * -Speed.Text
	wait(.1)
	HumanoidRP.BodyVelocity.Velocity = game.Workspace.CurrentCamera.CFrame.LookVector * -Speed.Text
	wait(.1)
	HumanoidRP.BodyVelocity.Velocity = game.Workspace.CurrentCamera.CFrame.LookVector * -Speed.Text
	wait(.1)
	HumanoidRP.BodyVelocity.Velocity = game.Workspace.CurrentCamera.CFrame.LookVector * -Speed.Text
	wait(.1)
	HumanoidRP.BodyVelocity.Velocity = game.Workspace.CurrentCamera.CFrame.LookVector * -Speed.Text
	wait(.1)
	HumanoidRP.BodyVelocity.Velocity = game.Workspace.CurrentCamera.CFrame.LookVector * 0
end)

S.MouseButton1Click:Connect(function()
	local HumanoidRP = game.Players.LocalPlayer.Character.HumanoidRootPart
	wait(.1)
	HumanoidRP.BodyVelocity.Velocity = game.Workspace.CurrentCamera.CFrame.LookVector * -Speed.Text
	wait(.1)
	HumanoidRP.BodyVelocity.Velocity = game.Workspace.CurrentCamera.CFrame.LookVector * -Speed.Text
	wait(.1)
	HumanoidRP.BodyVelocity.Velocity = game.Workspace.CurrentCamera.CFrame.LookVector * -Speed.Text
	wait(.1)
	HumanoidRP.BodyVelocity.Velocity = game.Workspace.CurrentCamera.CFrame.LookVector * -Speed.Text
	wait(.1)
	HumanoidRP.BodyVelocity.Velocity = game.Workspace.CurrentCamera.CFrame.LookVector * -Speed.Text
	wait(.1)
	HumanoidRP.BodyVelocity.Velocity = game.Workspace.CurrentCamera.CFrame.LookVector * -Speed.Text
	wait(.1)
	HumanoidRP.BodyVelocity.Velocity = game.Workspace.CurrentCamera.CFrame.LookVector * -Speed.Text
	wait(.1)
	HumanoidRP.BodyVelocity.Velocity = game.Workspace.CurrentCamera.CFrame.LookVector * -Speed.Text
	wait(.1)
	HumanoidRP.BodyVelocity.Velocity = game.Workspace.CurrentCamera.CFrame.LookVector * -Speed.Text
	wait(.1)
	HumanoidRP.BodyVelocity.Velocity = game.Workspace.CurrentCamera.CFrame.LookVector * 0
end)
end)

credits:Button("透视1",function()
loadstring(game:HttpGet('https://pastebin.com/raw/MA8jhPWT'))()
end)

credits:Button("透视2",function()
loadstring(game:HttpGet('https://raw.githubusercontent.com/Lucasfin000/SpaceHub/main/UESP'))()
end)

credits:Button("无敌『不适用』",function()
loadstring(game:HttpGet('https://pastebin.com/raw/H3RLCWWZ'))()
end)

credits:Button("隐身（E）",function()
loadstring(game:HttpGet('https://pastebin.com/raw/nwGEvkez'))()
end)

credits:Button("电脑键盘",function()
loadstring(game:HttpGet("https://raw.githubusercontent.com/advxzivhsjjdhxhsidifvsh/mobkeyboard/main/main.txt", true))()
end)

credits:Button("踏空行走",function()
loadstring(game:HttpGet('https://raw.githubusercontent.com/GhostPlayer352/Test4/main/Float'))()
end)

credits:Button("旋转",function()
loadstring(game:HttpGet("https://raw.githubusercontent.com/dingding123hhh/tt/main/%E6%97%8B%E8%BD%AC.lua"))()
end)

credits:Button("自杀",function()
game.Players.LocalPlayer.Character.Humanoid.Health=0
end)

credits:Button("飞檐走壁",function()
    loadstring(game:HttpGet("https://pastebin.com/raw/zXk4Rq2r"))()
end)

credits:Button("夜视仪",function()
    _G.OnShop = trueloadstring(game:HttpGet('https://raw.githubusercontent.com/DeividComSono/Scripts/main/Scanner.lua'))()
end)

credits:Button("正常范围",function()
    loadstring(game:HttpGet("https://pastebin.com/raw/jiNwDbCN"))()
end)

credits:Button("中等范围",function()
    loadstring(game:HttpGet("https://pastebin.com/raw/x13bwrFb"))()
end)

credits:Button("高级范围",function()
    loadstring(game:HttpGet("https://pastebin.com/raw/KKY9EpZU"))()
end)

credits:Button("反挂机",function()
    loadstring(game:HttpGet("https://pastebin.com/raw/9fFu43FF"))()
end)

   
      end
})
Section:Button({
    Title = "TY脚本-力量传奇",
    Callback = function()
    
local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()
local Window = WindUI:CreateWindow({
        Title = "TY脚本<font color='#00FF00'>v2</font>",
        Icon = "rbxassetid://1279310654146347060",
        IconTransparency = 0.5,
        IconThemed = true,
        Author = "作者:小夜",
        Folder = "CloudHub",
        Size = UDim2.fromOffset(400, 300),
        Transparent = true,
        Theme = "Light",
        User = {
            Enabled = true,
            Callback = function() print("clicked") end,
            Anonymous = false
        },
        SideBarWidth = 200,
        ScrollBarEnabled = true,
        Background = "rbxassetid://111122821357551"
    })
    

Window:EditOpenButton({
    Title = "TY付费版力量传奇",
    Icon = "monitor",
    CornerRadius = UDim.new(0,16),
    StrokeThickness = 4,
    Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromHex("FF0000")),
        ColorSequenceKeypoint.new(0.16, Color3.fromHex("FF7F00")),
        ColorSequenceKeypoint.new(0.33, Color3.fromHex("FFFF00")),
        ColorSequenceKeypoint.new(0.5, Color3.fromHex("00FF00")),
        ColorSequenceKeypoint.new(0.66, Color3.fromHex("0000FF")),
        ColorSequenceKeypoint.new(0.83, Color3.fromHex("4B0082")),
        ColorSequenceKeypoint.new(1, Color3.fromHex("9400D3"))
    }),
    Draggable = true,
})
            
Window:Tag({
    Title = "TY付费版",
    Color = Color3.fromHex("#30ff6a")
})

Window:Tag({
        Title = "TY付费版", -- 标签汉化
        Color = Color3.fromHex("#315dff")
    })
    local TimeTag = Window:Tag({
        Title = "感谢支持",
        Color = Color3.fromHex("#000000")
    })

local Tabs = {
    Main = Window:Section({ Title = "自动", Opened = true }),
    gn = Window:Section({ Title = "功能", Opened = true }),    
}

local TabHandles = {    
    Q = Tabs.Main:Tab({ Title = "自动功能", Icon = "layout-grid" }),
    W = Tabs.Main:Tab({ Title = "传送功能", Icon = "layout-grid" }),
    E = Tabs.Main:Tab({ Title = "自动锻炼", Icon = "layout-grid" }),
    R = Tabs.Main:Tab({ Title = "自动跑步", Icon = "layout-grid" }),
    T = Tabs.Main:Tab({ Title = "自动蹲起", Icon = "layout-grid" }),
    Y = Tabs.Main:Tab({ Title = "引体向上", Icon = "layout-grid" }),
    U = Tabs.Main:Tab({ Title = "自动举重", Icon = "layout-grid" }),
    I = Tabs.Main:Tab({ Title = "自动投石", Icon = "layout-grid" }),
    SAN = Tabs.Main:Tab({ Title = "UI自定义", Icon = "layout-grid" }),    
}

TabHandles.Q:Input({
    Title = "修改力量",
    Value = configName,
    Callback = function(FXM)
      game:GetService("Players").LocalPlayer.leaderstats.Strength.Value = FXM  
    end
})

TabHandles.Q:Input({
    Title = "修改重生",
    Value = configName,
    Callback = function(FXM)
        game:GetService("Players").LocalPlayer.leaderstats.Rebirths.Value = FXM
    end
})

TabHandles.Q:Input({
    Title = "修改击杀",
    Value = configName,
    Callback = function(FXM)
        game:GetService("Players").LocalPlayer.leaderstats.Kills.Value = FXM
    end
})

TabHandles.Q:Input({
    Title = "修改获胜",
    Value = configName,
    Callback = function(FXM)
        game:GetService("Players").LocalPlayer.leaderstats.Brawls.Value = FXM
    end
})
TabHandles.Q:Divider()

Toggle = TabHandles.Q:Toggle({
    Title = "自动重生",
    Desc = "",
    Locked = false,
    Callback = function(Value)
    if Value then
        while Value do
            game:GetService("ReplicatedStorage").rEvents.rebirthRemote:InvokeServer("rebirthRequest")
            wait()
            end
        end        
    end
})

Toggle = TabHandles.Q:Toggle({
    Title = "自动修改体积为2",
    Desc = "",
    Locked = false,
    Callback = function(Value)
    if Value then
        while Value do
        game:GetService("ReplicatedStorage").rEvents.changeSpeedSizeRemote:InvokeServer("changeSize",2)
        wait()
    end
end
end
})

Toggle = TabHandles.Q:Toggle({
    Title = "自动传送肌肉之王",
    Desc = "",
    Locked = false,
    Callback = function(Value)
    if Value then
        while Value do
        game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(-8625.9296875, 13.566278457641602, -5730.4736328125)
        wait()
    end
end
end
})
TabHandles.Q:Divider()

Toggle = TabHandles.Q:Toggle({
    Title = "0石头",
    Desc = "",
    Locked = false,
    Callback = function(Value)
    -- 将开关值同步到全局RK0变量，统一控制逻辑
    getgenv().RK0 = Value
    Jump = Value

    -- 开启开关：启动循环传送+装备Punch工具
    if Value then
        spawn(function()
            while Jump do
                local plr = game.Players.LocalPlayer
                -- 空值判断，确保角色、人形和根部件加载完成
                if plr and plr.Character then
                    local humanoid = plr.Character:FindFirstChildOfClass("Humanoid")
                    local rootPart = plr.Character:FindFirstChild("HumanoidRootPart")

                    -- 1. 循环传送逻辑
                    if rootPart then
                        rootPart.CFrame = CFrame.new(15.53,0.76,2117.85)
                    end

                    -- 2. 装备背包中的Punch工具
                    local punch = plr.Backpack:FindFirstChild("Punch")
                    if punch and punch:IsA("Tool") and humanoid then
                        humanoid:EquipTool(punch)
                    end
                end
                wait(0.1)
            end
        end)
    else
        -- 关闭开关：自动卸下所有工具
        local plr = game.Players.LocalPlayer
        if plr and plr.Character then
            local humanoid = plr.Character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                humanoid:UnequipTools()
            end
        end
    end
end
})

Toggle = TabHandles.Q:Toggle({
    Title = "10石头",
    Desc = "",
    Locked = false,
    Callback = function(Value)
    -- 将开关值同步到全局RK0变量，统一控制逻辑
    getgenv().RK0 = Value
    Jump = Value

    -- 开启开关：启动循环传送+装备Punch工具
    if Value then
        spawn(function()
            while Jump do
                local plr = game.Players.LocalPlayer
                -- 空值判断，确保角色、人形和根部件加载完成
                if plr and plr.Character then
                    local humanoid = plr.Character:FindFirstChildOfClass("Humanoid")
                    local rootPart = plr.Character:FindFirstChild("HumanoidRootPart")

                    -- 1. 循环传送逻辑
                    if rootPart then
                        rootPart.CFrame = CFrame.new(-151.39,2.10,437.53)
                    end

                    -- 2. 装备背包中的Punch工具
                    local punch = plr.Backpack:FindFirstChild("Punch")
                    if punch and punch:IsA("Tool") and humanoid then
                        humanoid:EquipTool(punch)
                    end
                end
                wait(0.1)
            end
        end)
    else
        -- 关闭开关：自动卸下所有工具
        local plr = game.Players.LocalPlayer
        if plr and plr.Character then
            local humanoid = plr.Character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                humanoid:UnequipTools()
            end
        end
    end
end
})

Toggle = TabHandles.Q:Toggle({
    Title = "100石头",
    Desc = "",
    Locked = false,
    Callback = function()
    -- 将开关值同步到全局RK0变量，统一控制逻辑
    getgenv().RK0 = Value
    Jump = Value

    -- 开启开关：启动循环传送+装备Punch工具
    if Value then
        spawn(function()
            while Jump do
                local plr = game.Players.LocalPlayer
                -- 空值判断，确保角色、人形和根部件加载完成
                if plr and plr.Character then
                    local humanoid = plr.Character:FindFirstChildOfClass("Humanoid")
                    local rootPart = plr.Character:FindFirstChild("HumanoidRootPart")

                    -- 1. 循环传送逻辑
                    if rootPart then
                        rootPart.CFrame = CFrame.new(164.47,1.24,-137.76)
                    end

                    -- 2. 装备背包中的Punch工具
                    local punch = plr.Backpack:FindFirstChild("Punch")
                    if punch and punch:IsA("Tool") and humanoid then
                        humanoid:EquipTool(punch)
                    end
                end
                wait(0.1)
            end
        end)
    else
        -- 关闭开关：自动卸下所有工具
        local plr = game.Players.LocalPlayer
        if plr and plr.Character then
            local humanoid = plr.Character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                humanoid:UnequipTools()
            end
        end
    end
end
})

Toggle = TabHandles.Q:Toggle({
    Title = "5000石头",
    Desc = "",
    Locked = false,
    Callback = function(Value)
    -- 将开关值同步到全局RK0变量，统一控制逻辑
    getgenv().RK0 = Value
    Jump = Value

    -- 开启开关：启动循环传送+装备Punch工具
    if Value then
        spawn(function()
            while Jump do
                local plr = game.Players.LocalPlayer
                -- 空值判断，确保角色、人形和根部件加载完成
                if plr and plr.Character then
                    local humanoid = plr.Character:FindFirstChildOfClass("Humanoid")
                    local rootPart = plr.Character:FindFirstChild("HumanoidRootPart")

                    -- 1. 循环传送逻辑
                    if rootPart then
                        rootPart.CFrame = CFrame.new(313.02,2.06,-559.59)
                    end

                    -- 2. 装备背包中的Punch工具
                    local punch = plr.Backpack:FindFirstChild("Punch")
                    if punch and punch:IsA("Tool") and humanoid then
                        humanoid:EquipTool(punch)
                    end
                end
                wait(0.1)
            end
        end)
    else
        -- 关闭开关：自动卸下所有工具
        local plr = game.Players.LocalPlayer
        if plr and plr.Character then
            local humanoid = plr.Character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                humanoid:UnequipTools()
            end
        end
    end
end
})

Toggle = TabHandles.Q:Toggle({
    Title = "150000石头",
    Desc = "",
    Locked = false,
    Callback = function(Value)
    -- 将开关值同步到全局RK0变量，统一控制逻辑
    getgenv().RK0 = Value
    Jump = Value

    -- 开启开关：启动循环传送+装备Punch工具
    if Value then
        spawn(function()
            while Jump do
                local plr = game.Players.LocalPlayer
                -- 空值判断，确保角色、人形和根部件加载完成
                if plr and plr.Character then
                    local humanoid = plr.Character:FindFirstChildOfClass("Humanoid")
                    local rootPart = plr.Character:FindFirstChild("HumanoidRootPart")

                    -- 1. 循环传送逻辑
                    if rootPart then
                        rootPart.CFrame = CFrame.new(-2514.23,1.07,-256.83)
                    end

                    -- 2. 装备背包中的Punch工具
                    local punch = plr.Backpack:FindFirstChild("Punch")
                    if punch and punch:IsA("Tool") and humanoid then
                        humanoid:EquipTool(punch)
                    end
                end
                wait(0.1)
            end
        end)
    else
        -- 关闭开关：自动卸下所有工具
        local plr = game.Players.LocalPlayer
        if plr and plr.Character then
            local humanoid = plr.Character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                humanoid:UnequipTools()
            end
        end
    end
end
})

Toggle = TabHandles.Q:Toggle({
    Title = "400000石头",
    Desc = "",
    Locked = false,
    Callback = function(Value)
    -- 将开关值同步到全局RK0变量，统一控制逻辑
    getgenv().RK0 = Value
    Jump = Value

    -- 开启开关：启动循环传送+装备Punch工具
    if Value then
        spawn(function()
            while Jump do
                local plr = game.Players.LocalPlayer
                -- 空值判断，确保角色、人形和根部件加载完成
                if plr and plr.Character then
                    local humanoid = plr.Character:FindFirstChildOfClass("Humanoid")
                    local rootPart = plr.Character:FindFirstChild("HumanoidRootPart")

                    -- 1. 循环传送逻辑
                    if rootPart then
                        rootPart.CFrame = CFrame.new(2186.48,8.09,1290.90)
                    end

                    -- 2. 装备背包中的Punch工具
                    local punch = plr.Backpack:FindFirstChild("Punch")
                    if punch and punch:IsA("Tool") and humanoid then
                        humanoid:EquipTool(punch)
                    end
                end
                wait(0.1)
            end
        end)
    else
        -- 关闭开关：自动卸下所有工具
        local plr = game.Players.LocalPlayer
        if plr and plr.Character then
            local humanoid = plr.Character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                humanoid:UnequipTools()
            end
        end
    end
end
})

Toggle = TabHandles.Q:Toggle({
    Title = "750000石头",
    Desc = "",
    Locked = false,
    Callback = function(Value)
    -- 将开关值同步到全局RK0变量，统一控制逻辑
    getgenv().RK0 = Value
    Jump = Value

    -- 开启开关：启动循环传送+装备Punch工具
    if Value then
        spawn(function()
            while Jump do
                local plr = game.Players.LocalPlayer
                -- 空值判断，确保角色、人形和根部件加载完成
                if plr and plr.Character then
                    local humanoid = plr.Character:FindFirstChildOfClass("Humanoid")
                    local rootPart = plr.Character:FindFirstChild("HumanoidRootPart")

                    -- 1. 循环传送逻辑
                    if rootPart then
                        rootPart.CFrame = CFrame.new(-7262.31,9.66,-1218.25)
                    end

                    -- 2. 装备背包中的Punch工具
                    local punch = plr.Backpack:FindFirstChild("Punch")
                    if punch and punch:IsA("Tool") and humanoid then
                        humanoid:EquipTool(punch)
                    end
                end
                wait(0.1)
            end
        end)
    else
        -- 关闭开关：自动卸下所有工具
        local plr = game.Players.LocalPlayer
        if plr and plr.Character then
            local humanoid = plr.Character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                humanoid:UnequipTools()
            end
        end
    end
end
})

Toggle = TabHandles.Q:Toggle({
    Title = "100万石头",
    Desc = "",
    Locked = false,
    Callback = function(Value)
    -- 将开关值同步到全局RK0变量，统一控制逻辑
    getgenv().RK0 = Value
    Jump = Value

    -- 开启开关：启动循环传送+装备Punch工具
    if Value then
        spawn(function()
            while Jump do
                local plr = game.Players.LocalPlayer
                -- 空值判断，确保角色、人形和根部件加载完成
                if plr and plr.Character then
                    local humanoid = plr.Character:FindFirstChildOfClass("Humanoid")
                    local rootPart = plr.Character:FindFirstChild("HumanoidRootPart")

                    -- 1. 循环传送逻辑
                    if rootPart then
                        rootPart.CFrame = CFrame.new(4132.50,991.64,-4035.54)
                    end

                    -- 2. 装备背包中的Punch工具
                    local punch = plr.Backpack:FindFirstChild("Punch")
                    if punch and punch:IsA("Tool") and humanoid then
                        humanoid:EquipTool(punch)
                    end
                end
                wait(0.1)
            end
        end)
    else
        -- 关闭开关：自动卸下所有工具
        local plr = game.Players.LocalPlayer
        if plr and plr.Character then
            local humanoid = plr.Character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                humanoid:UnequipTools()
            end
        end
    end
end
})

Toggle = TabHandles.Q:Toggle({
    Title = "500万石头",
    Desc = "",
    Locked = false,
    Callback = function(Value)
    -- 将开关值同步到全局RK0变量，统一控制逻辑
    getgenv().RK0 = Value
    Jump = Value

    -- 开启开关：启动循环传送+装备Punch工具
    if Value then
        spawn(function()
            while Jump do
                local plr = game.Players.LocalPlayer
                -- 空值判断，确保角色、人形和根部件加载完成
                if plr and plr.Character then
                    local humanoid = plr.Character:FindFirstChildOfClass("Humanoid")
                    local rootPart = plr.Character:FindFirstChild("HumanoidRootPart")

                    -- 1. 循环传送逻辑
                    if rootPart then
                        rootPart.CFrame = CFrame.new(-8985.91,17.23,-5989.86)
                    end

                    -- 2. 装备背包中的Punch工具
                    local punch = plr.Backpack:FindFirstChild("Punch")
                    if punch and punch:IsA("Tool") and humanoid then
                        humanoid:EquipTool(punch)
                    end
                end
                wait(0.1)
            end
        end)
    else
        -- 关闭开关：自动卸下所有工具
        local plr = game.Players.LocalPlayer
        if plr and plr.Character then
            local humanoid = plr.Character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                humanoid:UnequipTools()
            end
        end
    end
end
})

Toggle = TabHandles.Q:Toggle({
    Title = "1000万石头",
    Desc = "",
    Locked = false,
    Callback = function(Value)
    -- 将开关值同步到全局RK0变量，统一控制逻辑
    getgenv().RK0 = Value
    Jump = Value

    -- 开启开关：启动循环传送+装备Punch工具
    if Value then
        spawn(function()
            while Jump do
                local plr = game.Players.LocalPlayer
                -- 空值判断，确保角色、人形和根部件加载完成
                if plr and plr.Character then
                    local humanoid = plr.Character:FindFirstChildOfClass("Humanoid")
                    local rootPart = plr.Character:FindFirstChild("HumanoidRootPart")

                    -- 1. 循环传送逻辑
                    if rootPart then
                        rootPart.CFrame = CFrame.new(-7639.93,4.30,3007.76)
                    end

                    -- 2. 装备背包中的Punch工具
                    local punch = plr.Backpack:FindFirstChild("Punch")
                    if punch and punch:IsA("Tool") and humanoid then
                        humanoid:EquipTool(punch)
                    end
                end
                wait(0.1)
            end
        end)
    else
        -- 关闭开关：自动卸下所有工具
        local plr = game.Players.LocalPlayer
        if plr and plr.Character then
            local humanoid = plr.Character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                humanoid:UnequipTools()
            end
        end
    end
end
})

Button = TabHandles.W:Button({
    Title = "自动宝箱（传送+检测）[重复2次]",
    Desc = "",
    Locked = false,
    Callback = function()
    spawn(function()
        local repeatTimes = 2
        for cycle = 1, repeatTimes do
            -- 替换“开始轮次”提示
            showNotice(string.format("开始第 %d/%d 轮宝箱流程", cycle, repeatTimes))
            
            -- 1. 传送逻辑
            local teleportPoints = {
                CFrame.new(-138.17,7.33,-276.85),        
                CFrame.new(4680.29,1001.05,-3689.63),    
                CFrame.new(2213.03,7.33,918.64),    
                CFrame.new(-6713.86,7.33,-1454.19),  
                CFrame.new(-2572.08,7.33,-556.94),        
                CFrame.new(40.71,7.33,410.27),    
                CFrame.new(-7914.54,4.30,3028.47)
            }
            local player = game.Players.LocalPlayer
            local character = player.Character or player.CharacterAdded:Wait()
            local rootPart = character:WaitForChild("HumanoidRootPart")
            
            for _, targetCFrame in ipairs(teleportPoints) do
                rootPart.CFrame = targetCFrame
                task.wait(5)
            end
            task.wait(1)
            -- 新增“传送完成”提示
            showNotice("本轮传送已完成，准备检测宝箱")
            
            -- 2. 宝箱检测逻辑
            local ReplicatedStorage = game:GetService("ReplicatedStorage")
            local chestRewards = ReplicatedStorage:FindFirstChild("chestRewards")
            local checkRemote = ReplicatedStorage:FindFirstChild("rEvents"):FindFirstChild("checkChestRemote")
            
            if not chestRewards or not checkRemote then
                -- 替换“对象缺失”提示
                showNotice("宝箱目录或检测事件不存在，跳过本轮")
                task.wait(2)
                continue
            end
            
            local jk = {}
            for _, v in pairs(chestRewards:GetDescendants()) do
                if v.Name ~= "Light Karma Chest" and v.Name ~= "Evil Karma Chest" then
                    table.insert(jk, v.Name)
                end
            end
            
            for _, chestName in ipairs(jk) do
                checkRemote:InvokeServer(chestName)
                task.wait(2)
            end
            -- 新增“检测完成”提示
            showNotice(string.format("第 %d/%d 轮宝箱检测完成", cycle, repeatTimes))
            
            -- 替换“轮间等待”提示
            showNotice("等待3秒后进入下一轮")
            task.wait(3)
        end
        
        -- 替换“全部完成”提示
        showNotice("所有2轮宝箱流程已执行完毕！")
    end)
end
})
TabHandles.W:Divider()

Button = TabHandles.W:Button({
    Title = "沙滩",
    Desc = "",
    Locked = false,
    Callback = function()
    game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(-42.7, 3.7, 404.2)
end
})

Button = TabHandles.W:Button({
    Title = "小岛（0-1000力量）",
    Desc = "",
    Locked = false,
    Callback = function()
    game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(-37.636775970458984, 3.86960768699646, 1879.180908203125)
end
})

Button = TabHandles.W:Button({
    Title = "冰霜健身房（1重生）",
    Desc = "",
    Locked = false,
    Callback = function()
    game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(-2623.022216796875, 3.716249465942383, -409.0733337402344)
end
})

Button = TabHandles.W:Button({
    Title = "神话健身房（5重生）",
    Desc = "",
    Locked = false,
    Callback = function()
    game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(2250.778076171875, 3.716248035430908, 1073.2266845703125)
end
})

Button = TabHandles.W:Button({
    Title = "永恒健身房（15重生）",
    Desc = "",
    Locked = false,
    Callback = function()
    game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(-6758.9638671875, 3.71626353263855, -1284.918701171875)
end
})

Button = TabHandles.W:Button({
    Title = "传奇健身房（30重生）",
    Desc = "",
    Locked = false,
    Callback = function()
    game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(4603.28173828125, 987.869140625, -3897.86572265625)
end
})

Button = TabHandles.W:Button({
    Title = "力量之王”健身房（5重生）",
    Desc = "",
    Locked = false,
    Callback = function()
    game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(-8625.9296875, 13.566278457641602, -5730.4736328125)
end
})

Button = TabHandles.W:Button({
    Title = "狂野健身房（60重生）",
    Desc = "",
    Locked = false,
    Callback = function()
    game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(-8693.0927734375, 8.93972396850586, 2400.66259765625)
end
})


local AutoTrainEnabled = false  -- 自动锻炼状态
local TrainThread = nil         -- 自动锻炼线程
-- 自动锻炼（修复线程管理）
Toggle = TabHandles.E:Toggle({
    Title = "自动锻炼",
    Desc = "",
    Locked = false,
    Callback = function(Value)
    AutoTrainEnabled = Value
    -- 终止旧线程
    if TrainThread then
        task.cancel(TrainThread)
        TrainThread = nil
    end
    -- 启动新线程
    if AutoTrainEnabled then
        TrainThread = task.spawn(function()
            while AutoTrainEnabled do
                local args = {[1] = "rep"}
                local muscleEvent = game.Players.LocalPlayer:FindFirstChild("muscleEvent")
                if muscleEvent then
                    muscleEvent:FireServer(unpack(args))
                end
                task.wait(0.1)
            end
        end)
    end
end
})

local AutoPunchEnabled = false  -- 自动挥拳状态
local PunchThread = nil         -- 自动挥拳线程

-- 自动挥拳（保留优化后的代码）
Toggle = TabHandles.E:Toggle({
    Title = "自动挥拳",
    Desc = "",
    Locked = false,
    Callback = function(Value)
    AutoPunchEnabled = Value
    -- 终止旧线程
    if PunchThread then
        task.cancel(PunchThread)
        PunchThread = nil
    end
    -- 启动新线程
    if AutoPunchEnabled then
        PunchThread = task.spawn(function()
            while AutoPunchEnabled do
                local args = {[1] = "punch", [2] = "rightHand"}
                local muscleEvent = game.Players.LocalPlayer:FindFirstChild("muscleEvent")
                if muscleEvent then
                    muscleEvent:FireServer(unpack(args))
                end
                task.wait(0.1)
            end
        end)
    end
 end
})
TabHandles.E:Divider()

Toggle = TabHandles.E:Toggle({
    Title = "自动哑铃",
    Desc = "",
    Locked = false,
    Callback = function(Value)
    for i, v in pairs(game.Players.LocalPlayer.Backpack:GetChildren()) do
        if v.ClassName == "Tool" and v.Name == "Weight" then
            v.Parent = game.Players.LocalPlayer.Character
            wait()
        end
    end
    if Value then
    local AutoRep = Value
        while AutoRep do
            game:GetService("Players").LocalPlayer.muscleEvent:FireServer("rep")
            wait()
        end
    end
end
})

Toggle = TabHandles.E:Toggle({
    Title = "自动俯卧撑",
    Desc = "",
    Locked = false,
    Callback = function(Value)
    for i, v in pairs(game.Players.LocalPlayer.Backpack:GetChildren()) do
        if v.ClassName == "Tool" and v.Name == "Pushups" then
            v.Parent = game.Players.LocalPlayer.Character
            wait()
        end
    end
    if Value then
    local AutoRep = Value
        while AutoRep do
            game:GetService("Players").LocalPlayer.muscleEvent:FireServer("rep")
            wait()
        end
    end
end
})

Toggle = TabHandles.E:Toggle({
    Title = "自动仰卧起坐",
    Desc = "",
    Locked = false,
    Callback = function(Value)
    for i, v in pairs(game.Players.LocalPlayer.Backpack:GetChildren()) do
        if v.ClassName == "Tool" and v.Name == "Situps" then
            v.Parent = game.Players.LocalPlayer.Character
            wait()
        end
    end
    if Value then
    local AutoRep = Value
        while AutoRep do
            game:GetService("Players").LocalPlayer.muscleEvent:FireServer("rep")
            wait()
        end
    end
end
})

Toggle = TabHandles.E:Toggle({
    Title = "自动倒立",
    Desc = "",
    Locked = false,
    Callback = function(Value)
    for i, v in pairs(game.Players.LocalPlayer.Backpack:GetChildren()) do
        if v.ClassName == "Tool" and v.Name == "Handstands" then
            v.Parent = game.Players.LocalPlayer.Character
            wait()
        end
    end
    if Value then
    local AutoRep = Value
        while AutoRep do
            game:GetService("Players").LocalPlayer.muscleEvent:FireServer("rep")
            wait()
        end
    end
end
})

Toggle = TabHandles.E:Toggle({
    Title = "自动练全部",
    Desc = "",
    Locked = false,
    Callback = function(Value)
    for i, v in pairs(game.Players.LocalPlayer.Backpack:GetChildren()) do
        if v.ClassName == "Tool" and v.Name == "Weight" or v.Name == "Handstands" or v.Name == "Pushups" or v.Name == "Situps" then
            v.Parent = game.Players.LocalPlayer.Character
            wait()
        end
    end
    if Value then
    local AutoRep = Value
        while AutoRep do
            game:GetService("Players").LocalPlayer.muscleEvent:FireServer("rep")
            wait()
        end
    end
end
})

Toggle = TabHandles.R:Toggle({
    Title = "跑步机海滩10",
    Desc = "",
    Locked = false,
    Callback = function(treadmill)
    getgenv().spam = treadmill
while getgenv().spam do
wait()
game.Players.LocalPlayer.Character:WaitForChild("Humanoid").WalkSpeed = 10
game.Players.LocalPlayer.Character:WaitForChild("HumanoidRootPart").CFrame = CFrame.new(238.671112, 5.40315914, 387.713165, -0.0160072874, -2.90710176e-08, -0.99987185, -3.3434191e-09, 1, -2.90212157e-08, 0.99987185, 2.87843993e-09, -0.0160072874)
local oldpos = game.Players.LocalPlayer.Character:WaitForChild("HumanoidRootPart").CFrame
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
 
local localPlayer = Players.LocalPlayer
 
RunService:BindToRenderStep("move",
    -- run after the character
    Enum.RenderPriority.Character.Value + 1,
    function()
   	 if localPlayer.Character then
   		 local humanoid = localPlayer.Character:WaitForChild("Humanoid")
   		 if humanoid then
   			 humanoid:Move(Vector3.new(10000, 0, -1), true)
   		 end
   	 end
    end
)
end

if not getgenv().spam then
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
 
local localPlayer = Players.LocalPlayer
 
RunService:UnbindFromRenderStep("move",
    -- run after the character
    Enum.RenderPriority.Character.Value + 1,
    function()
   	 if localPlayer.Character then
   		 local humanoid = localPlayer.Character:FindFirstChild("Humanoid")
   		 if humanoid then
   			 humanoid:Move(Vector3.new(10000, 0, -1), true)
   		 end
   	 end
    end
)
end
end
})

Toggle = TabHandles.R:Toggle({
    Title = "跑步机Frost-健身房-2000",
    Desc = "",
    Locked = false,
    Callback = function(treadmill)
    if game.Players.LocalPlayer.Agility.Value >= 2000 then
getgenv().spam = treadmill
while getgenv().spam do
wait()
game.Players.LocalPlayer.Character:WaitForChild("Humanoid").WalkSpeed = 10
game.Players.LocalPlayer.Character:WaitForChild("HumanoidRootPart").CFrame = CFrame.new(-3005.37866, 14.3221855, -464.697876, -0.015773816, -1.38508964e-08, 0.999875605, -5.13225586e-08, 1, 1.30429667e-08, -0.999875605, -5.11104332e-08, -0.015773816)
local oldpos = game.Players.LocalPlayer.Character:WaitForChild("HumanoidRootPart").CFrame
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
 
local localPlayer = Players.LocalPlayer
 
RunService:BindToRenderStep("move",
    -- run after the character
    Enum.RenderPriority.Character.Value + 1,
    function()
   	 if localPlayer.Character then
   		 local humanoid = localPlayer.Character:WaitForChild("Humanoid")
   		 if humanoid then
   			 humanoid:Move(Vector3.new(10000, 0, -1), true)
   		 end
   	 end
    end
)
end
end

if not getgenv().spam then
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
 
local localPlayer = Players.LocalPlayer
 
RunService:UnbindFromRenderStep("move",
    -- run after the character
    Enum.RenderPriority.Character.Value + 1,
    function()
   	 if localPlayer.Character then
   		 local humanoid = localPlayer.Character:FindFirstChild("Humanoid")
   		 if humanoid then
   			 humanoid:Move(Vector3.new(10000, 0, -1), true)
   		 end
   	 end
    end
)
end
end
})

Toggle = TabHandles.R:Toggle({
    Title = "跑步机神话-健身房2000",
    Desc = "",
    Locked = false,
    Callback = function(treadmill)
    if game.Players.LocalPlayer.Agility.Value >= 2000 then
getgenv().spam = treadmill
while getgenv().spam do
wait()
game.Players.LocalPlayer.Character:WaitForChild("Humanoid").WalkSpeed = 10
game.Players.LocalPlayer.Character:WaitForChild("HumanoidRootPart").CFrame = CFrame.new(2571.23706, 15.6896839, 898.650391, 0.999968231, 2.23868635e-09, -0.00797206629, -1.73198844e-09, 1, 6.35660768e-08, 0.00797206629, -6.3550246e-08, 0.999968231)
local oldpos = game.Players.LocalPlayer.Character:WaitForChild("HumanoidRootPart").CFrame
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
 
local localPlayer = Players.LocalPlayer
 
RunService:BindToRenderStep("move",
    -- run after the character
    Enum.RenderPriority.Character.Value + 1,
    function()
   	 if localPlayer.Character then
   		 local humanoid = localPlayer.Character:WaitForChild("Humanoid")
   		 if humanoid then
   			 humanoid:Move(Vector3.new(10000, 0, -1), true)
   		 end
   	 end
    end
)
end
end

if not getgenv().spam then
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
 
local localPlayer = Players.LocalPlayer
 
RunService:UnbindFromRenderStep("move",
    -- run after the character
    Enum.RenderPriority.Character.Value + 1,
    function()
   	 if localPlayer.Character then
   		 local humanoid = localPlayer.Character:FindFirstChild("Humanoid")
   		 if humanoid then
   			 humanoid:Move(Vector3.new(10000, 0, -1), true)
   		 end
   	 end
    end
)
end
end
})

Toggle = TabHandles.R:Toggle({
    Title = "永恒跑步机-健身房",
    Desc = "",
    Locked = false,
    Callback = function(treadmill)
    if game.Players.LocalPlayer.Agility.Value >= 3500 then
getgenv().spam = treadmill
while getgenv().spam do
wait()
game.Players.LocalPlayer.Character:WaitForChild("Humanoid").WalkSpeed = 10
game.Players.LocalPlayer.Character:WaitForChild("HumanoidRootPart").CFrame = CFrame.new(-7077.79102, 29.6702118, -1457.59961, -0.0322036594, -3.31122768e-10, 0.99948132, -6.44344267e-09, 1, 1.23684493e-10, -0.99948132, -6.43611742e-09, -0.0322036594)
local oldpos = game.Players.LocalPlayer.Character:WaitForChild("HumanoidRootPart").CFrame
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
 
local localPlayer = Players.LocalPlayer
 
RunService:BindToRenderStep("move",
    -- run after the character
    Enum.RenderPriority.Character.Value + 1,
    function()
   	 if localPlayer.Character then
   		 local humanoid = localPlayer.Character:WaitForChild("Humanoid")
   		 if humanoid then
   			 humanoid:Move(Vector3.new(10000, 0, -1), true)
   		 end
   	 end
    end
)
end
end

if not getgenv().spam then
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
 
local localPlayer = Players.LocalPlayer
 
RunService:UnbindFromRenderStep("move",
    -- run after the character
    Enum.RenderPriority.Character.Value + 1,
    function()
   	 if localPlayer.Character then
   		 local humanoid = localPlayer.Character:FindFirstChild("Humanoid")
   		 if humanoid then
   			 humanoid:Move(Vector3.new(10000, 0, -1), true)
   		 end
   	 end
    end
)
end
end
})

Toggle = TabHandles.R:Toggle({
    Title = "跑步机传奇-健身房",
    Desc = "",
    Locked = false,
    Callback = function(treadmill)
    if game.Players.LocalPlayer.Agility.Value >= 3000 then
getgenv().spam = treadmill
while getgenv().spam do
wait()
game.Players.LocalPlayer.Character:WaitForChild("Humanoid").WalkSpeed = 10
game.Players.LocalPlayer.Character:WaitForChild("HumanoidRootPart").CFrame = CFrame.new(4370.82812, 999.358704, -3621.42773, -0.960604727, -8.41949266e-09, -0.27791819, -6.12478646e-09, 1, -9.12496567e-09, 0.27791819, -7.06329528e-09, -0.960604727)
local oldpos = game.Players.LocalPlayer.Character:WaitForChild("HumanoidRootPart").CFrame
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
 
local localPlayer = Players.LocalPlayer
 
RunService:BindToRenderStep("move",
    -- run after the character
    Enum.RenderPriority.Character.Value + 1,
    function()
   	 if localPlayer.Character then
   		 local humanoid = localPlayer.Character:WaitForChild("Humanoid")
   		 if humanoid then
   			 humanoid:Move(Vector3.new(10000, 0, -1), true)
   		 end
   	 end
    end
)
end
end

if not getgenv().spam then
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
 
local localPlayer = Players.LocalPlayer
 
RunService:UnbindFromRenderStep("move",
    -- run after the character
    Enum.RenderPriority.Character.Value + 1,
    function()
   	 if localPlayer.Character then
   		 local humanoid = localPlayer.Character:FindFirstChild("Humanoid")
   		 if humanoid then
   			 humanoid:Move(Vector3.new(10000, 0, -1), true)
   		 end
   	 end
    end
)
end
end
})

Toggle = TabHandles.T:Toggle({
    Title = "沙滩",
    Desc = "",
    Locked = false,
    Callback = function(rack)
    if game.Players.LocalPlayer.leaderstats.Strength.Value >= 1000 then
getgenv().spam = rack
while getgenv().spam do
wait()
if game.Players.LocalPlayer.machineInUse.Value == nil then
game.Players.LocalPlayer.Character:WaitForChild("HumanoidRootPart").CFrame = CFrame.new(232.627625, 3.67689133, 96.3039856, -0.963445187, -7.78685845e-08, -0.267905563, -7.92865222e-08, 1, -5.52570167e-09, 0.267905563, 1.5917589e-08, -0.963445187)
local vim = game:service("VirtualInputManager")
           vim:SendKeyEvent(true, "E", false, game)
else
local A_1 = "rep"
local A_2 = game:GetService("Workspace").machinesFolder["Squat Rack"].interactSeat
local Event = game:GetService("Players").LocalPlayer.muscleEvent
Event:FireServer(A_1, A_2)
end
end
end
if not getgenv().spam then
game.Players.LocalPlayer.Character:WaitForChild("Humanoid").Jump = true
end
end
})

Toggle = TabHandles.T:Toggle({
    Title = "冰冻健身房",
    Desc = "",
    Locked = false,
    Callback = function(rack)
    if game.Players.LocalPlayer.leaderstats.Strength.Value >= 4000 then
getgenv().spam = rack
while getgenv().spam do
wait()
if game.Players.LocalPlayer.machineInUse.Value == nil then
game.Players.LocalPlayer.Character:WaitForChild("HumanoidRootPart").CFrame = CFrame.new(-2629.13818, 3.36860609, -609.827454, -0.995664716, -2.67296816e-08, -0.0930150598, -1.90042453e-08, 1, -8.39415222e-08, 0.0930150598, -8.18099295e-08, -0.995664716)
local vim = game:service("VirtualInputManager")
           vim:SendKeyEvent(true, "E", false, game)
else
local A_1 = "rep"
local A_2 = game:GetService("Workspace").machinesFolder["Squat Rack"].interactSeat
local Event = game:GetService("Players").LocalPlayer.muscleEvent
Event:FireServer(A_1, A_2)
end
end
end
if not getgenv().spam then
game.Players.LocalPlayer.Character:WaitForChild("Humanoid").Jump = true
end
end
})

Toggle = TabHandles.T:Toggle({
    Title = "传奇健身房",
    Desc = "",
    Locked = false,
    Callback = function(rack)
    getgenv().spam = rack
while getgenv().spam do
wait()
if game.Players.LocalPlayer.machineInUse.Value == nil then
game.Players.LocalPlayer.Character:WaitForChild("HumanoidRootPart").CFrame = CFrame.new(4443.04443, 987.521484, -4061.12988, 0.83309716, 3.33018835e-09, 0.553126693, -2.87759438e-09, 1, -1.68654424e-09, -0.553126693, -1.86619012e-10, 0.83309716)
local vim = game:service("VirtualInputManager")
           vim:SendKeyEvent(true, "E", false, game)
else
local A_1 = "rep"
local A_2 = game:GetService("Workspace").machinesFolder["Squat Rack"].interactSeat
local Event = game:GetService("Players").LocalPlayer.muscleEvent
Event:FireServer(A_1, A_2)
end
end
if not getgenv().spam then
game.Players.LocalPlayer.Character:WaitForChild("Humanoid").Jump = true
end
end
})

Toggle = TabHandles.T:Toggle({
    Title = "肌肉健身房",
    Desc = "",
    Locked = false,
    Callback = function(rack)
    getgenv().spam = rack
while getgenv().spam do
wait()
if game.Players.LocalPlayer.machineInUse.Value == nil then
game.Players.LocalPlayer.Character:WaitForChild("HumanoidRootPart").CFrame = CFrame.new(-8757.37012, 13.2186356, -6051.24365, -0.902269304, 1.63610299e-08, -0.431172907, 1.71076486e-08, 1, 2.14606288e-09, 0.431172907, -5.44002754e-09, -0.902269304)
local vim = game:service("VirtualInputManager")
           vim:SendKeyEvent(true, "E", false, game)
else
local A_1 = "rep"
local A_2 = game:GetService("Workspace").machinesFolder["Squat Rack"].interactSeat
local Event = game:GetService("Players").LocalPlayer.muscleEvent
Event:FireServer(A_1, A_2)
end
end
if not getgenv().spam then
game.Players.LocalPlayer.Character:WaitForChild("Humanoid").Jump = true
end
end
})

Toggle = TabHandles.Y:Toggle({
    Title = "海滩",
    Desc = "",
    Locked = false,
    Callback = function(pull)
    if game.Players.LocalPlayer.leaderstats.Strength.Value >= 1000 then
getgenv().spam = pull
while getgenv().spam do
wait()
if game.Players.LocalPlayer.machineInUse.Value == nil then
game.Players.LocalPlayer.Character:WaitForChild("HumanoidRootPart").CFrame = CFrame.new(-185.157745, 5.81071186, 104.747154, 0.227061391, -8.2363325e-09, 0.97388047, 5.58502826e-08, 1, -4.56432803e-09, -0.97388047, 5.54278827e-08, 0.227061391)
local vim = game:service("VirtualInputManager")
           vim:SendKeyEvent(true, "E", false, game)
else
local A_1 = "rep"
local A_2 = game:GetService("Workspace").machinesFolder["Legends Pullup"].interactSeat
local Event = game:GetService("Players").LocalPlayer.muscleEvent
Event:FireServer(A_1, A_2)
end
end
end
if not getgenv().spam then
game.Players.LocalPlayer.Character:WaitForChild("Humanoid").Jump = true
end
end
})

Toggle = TabHandles.Y:Toggle({
    Title = "神话",
    Desc = "",
    Locked = false,
    Callback = function(pull)
    if game.Players.LocalPlayer.leaderstats.Strength.Value >= 4000 then
getgenv().spam = pull
while getgenv().spam do
wait()
if game.Players.LocalPlayer.machineInUse.Value == nil then
game.Players.LocalPlayer.Character:WaitForChild("HumanoidRootPart").CFrame = CFrame.new(2315.82104, 5.81071281, 847.153076, 0.993555248, 6.99809632e-08, 0.113349125, -7.05298859e-08, 1, 8.32554692e-10, -0.113349125, -8.82168916e-09, 0.993555248)
local vim = game:service("VirtualInputManager")
           vim:SendKeyEvent(true, "E", false, game)
else
local A_1 = "rep"
local A_2 = game:GetService("Workspace").machinesFolder["Legends Pullup"].interactSeat
local Event = game:GetService("Players").LocalPlayer.muscleEvent
Event:FireServer(A_1, A_2)
end
end
end
if not getgenv().spam then
game.Players.LocalPlayer.Character:WaitForChild("Humanoid").Jump = true
end
end
})

Toggle = TabHandles.Y:Toggle({
    Title = "传奇",
    Desc = "",
    Locked = false,
    Callback = function(pull)
    getgenv().spam = pull
while getgenv().spam do
wait()
if game.Players.LocalPlayer.machineInUse.Value == nil then
game.Players.LocalPlayer.Character:WaitForChild("HumanoidRootPart").CFrame = CFrame.new(4305.08203, 989.963623, -4118.44873, -0.953815758, -7.58000382e-08, -0.30039227, -8.98859724e-08, 1, 3.30721512e-08, 0.30039227, 5.85457904e-08, -0.953815758)
local vim = game:service("VirtualInputManager")
           vim:SendKeyEvent(true, "E", false, game)
else
local A_1 = "rep"
local A_2 = game:GetService("Workspace").machinesFolder["Legends Pullup"].interactSeat
local Event = game:GetService("Players").LocalPlayer.muscleEvent
Event:FireServer(A_1, A_2)
end
end
if not getgenv().spam then
game.Players.LocalPlayer.Character:WaitForChild("Humanoid").Jump = true
end
end
})

Toggle = TabHandles.U:Toggle({
    Title = "海滩",
    Desc = "",
    Locked = false,
    Callback = function(lift)
    if game.Players.LocalPlayer.leaderstats.Strength.Value >= 1500 then
getgenv().spam = lift
while getgenv().spam do
wait()
if game.Players.LocalPlayer.machineInUse.Value == nil then
game.Players.LocalPlayer.Character:WaitForChild("HumanoidRootPart").CFrame = CFrame.new(136.606216, 3.67689133, 97.661499, -0.974106729, -1.89495477e-08, 0.226088539, -1.78365624e-08, 1, 6.96555214e-09, -0.226088539, 2.75254886e-09, -0.974106729)
local vim = game:service("VirtualInputManager")
           vim:SendKeyEvent(true, "E", false, game)
else
local A_1 = "rep"
local A_2 = game:GetService("Workspace").machinesFolder.Deadlift.interactSeat
local Event = game:GetService("Players").LocalPlayer.muscleEvent
Event:FireServer(A_1, A_2)
end
end
end
if not getgenv().spam then
game.Players.LocalPlayer.Character:WaitForChild("Humanoid").Jump = true
end
end
})

Toggle = TabHandles.U:Toggle({
    Title = "传说健身房",
    Desc = "",
    Locked = false,
    Callback = function(lift)
    if game.Players.LocalPlayer.leaderstats.Strength.Value >= 5000 then
getgenv().spam = lift
while getgenv().spam do
wait()
if game.Players.LocalPlayer.machineInUse.Value == nil then
game.Players.LocalPlayer.Character:WaitForChild("HumanoidRootPart").CFrame = CFrame.new(-2916.11572, 3.67689204, -212.97438, -0.241641939, -6.10995343e-08, 0.970365465, 6.65890596e-08, 1, 7.9547597e-08, -0.970365465, 8.38377616e-08, -0.241641939)
local vim = game:service("VirtualInputManager")
           vim:SendKeyEvent(true, "E", false, game)
else
local A_1 = "rep"
local A_2 = game:GetService("Workspace").machinesFolder.Deadlift.interactSeat
local Event = game:GetService("Players").LocalPlayer.muscleEvent
Event:FireServer(A_1, A_2)
end
end
end
if not getgenv().spam then
game.Players.LocalPlayer.Character:WaitForChild("Humanoid").Jump = true
end
end
})

Toggle = TabHandles.U:Toggle({
    Title = "传奇健身房",
    Desc = "",
    Locked = false,
    Callback = function(lift)
    getgenv().spam = lift
while getgenv().spam do
wait()
if game.Players.LocalPlayer.machineInUse.Value == nil then
game.Players.LocalPlayer.Character:WaitForChild("HumanoidRootPart").CFrame = CFrame.new(4538.42627, 987.829834, -4008.82007, -0.830109239, 2.21324914e-08, 0.557600796, 8.02302083e-08, 1, 7.97476361e-08, -0.557600796, 1.1093568e-07, -0.830109239)
local vim = game:service("VirtualInputManager")
           vim:SendKeyEvent(true, "E", false, game)
else
local A_1 = "rep"
local A_2 = game:GetService("Workspace").machinesFolder.Deadlift.interactSeat
local Event = game:GetService("Players").LocalPlayer.muscleEvent
Event:FireServer(A_1, A_2)
end
end
if not getgenv().spam then
game.Players.LocalPlayer.Character:WaitForChild("Humanoid").Jump = true
end
end
})

Toggle = TabHandles.U:Toggle({
    Title = "肌肉之王",
    Desc = "",
    Locked = false,
    Callback = function(lift)
    getgenv().spam = lift
while getgenv().spam do
wait()
if game.Players.LocalPlayer.machineInUse.Value == nil then
game.Players.LocalPlayer.Character:WaitForChild("HumanoidRootPart").CFrame = CFrame.new(-8768.4375, 13.5269203, -5681.62256, -0.997508109, -5.4007393e-10, 0.0705519542, 1.52984292e-10, 1, 9.81797044e-09, -0.0705519542, 9.80429782e-09, -0.997508109)
local vim = game:service("VirtualInputManager")
           vim:SendKeyEvent(true, "E", false, game)
else
local A_1 = "rep"
local A_2 = game:GetService("Workspace").machinesFolder.Deadlift.interactSeat
local Event = game:GetService("Players").LocalPlayer.muscleEvent
Event:FireServer(A_1, A_2)
end
end
if not getgenv().spam then
game.Players.LocalPlayer.Character:WaitForChild("Humanoid").Jump = true
end
end
})

Toggle = TabHandles.I:Toggle({
    Title = "海滩",
    Desc = "",
    Locked = false,
    Callback = function(lift)
    if game.Players.LocalPlayer.leaderstats.Strength.Value >= 3000 then
getgenv().spam = lift
while getgenv().spam do
wait()
if game.Players.LocalPlayer.machineInUse.Value == nil then
game.Players.LocalPlayer.Character:WaitForChild("HumanoidRootPart").CFrame = CFrame.new(-91.6730804, 3.67689133, -292.42868, -0.221022144, -2.21041621e-08, -0.975268781, 1.21414407e-08, 1, -2.54162646e-08, 0.975268781, -1.7458726e-08, -0.221022144)
local vim = game:service("VirtualInputManager")
           vim:SendKeyEvent(true, "E", false, game)
else
local A_1 = "rep"
local A_2 = game:GetService("Workspace").machinesFolder.Deadlift.interactSeat
local Event = game:GetService("Players").LocalPlayer.muscleEvent
Event:FireServer(A_1, A_2)
end
end
end
if not getgenv().spam then
game.Players.LocalPlayer.Character:WaitForChild("Humanoid").Jump = true
end
end
})

Toggle = TabHandles.I:Toggle({
    Title = "神话",
    Desc = "",
    Locked = false,
    Callback = function(lift)
    if game.Players.LocalPlayer.leaderstats.Strength.Value >= 10000 then
getgenv().spam = lift
while getgenv().spam do
wait()
if game.Players.LocalPlayer.machineInUse.Value == nil then
game.Players.LocalPlayer.Character:WaitForChild("HumanoidRootPart").CFrame = CFrame.new(2486.01733, 3.67689276, 1237.89331, 0.883595645, -2.06135038e-08, -0.468250751, -3.3286871e-09, 1, -5.03036404e-08, 0.468250751, 4.60067362e-08, 0.883595645)
local vim = game:service("VirtualInputManager")
           vim:SendKeyEvent(true, "E", false, game)
else
local A_1 = "rep"
local A_2 = game:GetService("Workspace").machinesFolder.Deadlift.interactSeat
local Event = game:GetService("Players").LocalPlayer.muscleEvent
Event:FireServer(A_1, A_2)
end
end
end
if not getgenv().spam then
game.Players.LocalPlayer.Character:WaitForChild("Humanoid").Jump = true
end
end
})

Toggle = TabHandles.I:Toggle({
    Title = "传奇",
    Desc = "",
    Locked = false,
    Callback = function(lift)
    getgenv().spam = lift
while getgenv().spam do
wait()
if game.Players.LocalPlayer.machineInUse.Value == nil then
game.Players.LocalPlayer.Character:WaitForChild("HumanoidRootPart").CFrame = CFrame.new(4189.96143, 987.829773, -3903.0166, 0.422592968, 0, 0.906319559, 0, 1, 0, -0.906319559, 0, 0.422592968)
local vim = game:service("VirtualInputManager")
           vim:SendKeyEvent(true, "E", false, game)
else
local A_1 = "rep"
local A_2 = game:GetService("Workspace").machinesFolder.Deadlift.interactSeat
local Event = game:GetService("Players").LocalPlayer.muscleEvent
Event:FireServer(A_1, A_2)
end
end
if not getgenv().spam then
game.Players.LocalPlayer.Character:WaitForChild("Humanoid").Jump = true
end
end
})

Toggle = TabHandles.I:Toggle({
    Title = "肌肉之王",
    Desc = "",
    Locked = false,
    Callback = function(lift)
    getgenv().spam = lift
while getgenv().spam do
wait()
if game.Players.LocalPlayer.machineInUse.Value == nil then
game.Players.LocalPlayer.Character:WaitForChild("HumanoidRootPart").CFrame = CFrame.new(8933.69434, 13.5269222, -5700.12598, -0.823058188, 6.96304259e-09, 0.567957044, -1.19721832e-08, 1, -2.96093621e-08, -0.567957044, -3.11699146e-08, -0.823058188)
local vim = game:service("VirtualInputManager")
           vim:SendKeyEvent(true, "E", false, game)
else
local A_1 = "rep"
local A_2 = game:GetService("Workspace").machinesFolder.Deadlift.interactSeat
local Event = game:GetService("Players").LocalPlayer.muscleEvent
Event:FireServer(A_1, A_2)
end
end
if not getgenv().spam then
game.Players.LocalPlayer.Character:WaitForChild("Humanoid").Jump = true
end
end
})

local Button = TabHandles.SAN:Button({
    Title = "自定义界面",
    Desc = "个性化您的体验",
    Image = "palette",
    ImageSize = 20,
    Color = "White"
})

local themes = {}
for themeName, _ in pairs(WindUI:GetThemes()) do
    table.insert(themes, themeName)
end
table.sort(themes)

local themeDropdown = TabHandles.SAN:Dropdown({
    Title = "主题选择",
    Values = themes,
    Value = "Dark",
    Callback = function(theme)
        WindUI:SetTheme(theme)
        WindUI:Notify({
            Title = "主题应用",
            Content = theme,
            Icon = "palette",
            Duration = 2
        })
    end
})

local transparencySlider = TabHandles.SAN:Slider({
    Title = "透明度",
    Value = { 
        Min = 0,
        Max = 1,
        Default = 0.2,
    },
    Step = 0.1,
    Callback = function(value)
        Window:ToggleTransparency(tonumber(value) > 0)
        WindUI.TransparencyValue = tonumber(value)
    end
})

TabHandles.SAN:Toggle({
    Title = "启用黑色主题",
    Desc = "使用黑色调主题方案",
    Value = true,
    Callback = function(state)
        WindUI:SetTheme(state and "Dark" or "Light")
        themeDropdown:Select(state and "Dark" or "Light")
    end
})


TabHandles.SAN:Button({
    Title = "创建新主题",
    Icon = "plus",
    Callback = function()
        Window:Dialog({
            Title = "创建主题",
            Content = "此功能很快就会推出",
            Buttons = {
                {
                    Title = "确认",
                    Variant = "Primary"
                }
            }
        })
    end
})

TabHandles.SAN:Paragraph({
    Title = "配置管理",
    Desc = "保存你的设置",
    Image = "save",
    ImageSize = 20,
    Color = "White"
})

local configName = "default"
local configFile = nil
local MyPlayerData = {
    name = "Player1",
    level = 1,
    inventory = { "sword", "shield", "potion" }
}

TabHandles.SAN:Input({
    Title = "配置名称",
    Value = configName,
    Callback = function(value)
        configName = value
    end
})

local ConfigManager = Window.ConfigManager
if ConfigManager then
    ConfigManager:Init(Window)
    
TabHandles.SAN:Button({
        Title = "保存配置",
        Icon = "save",
        Variant = "Primary",
        Callback = function()
            configFile = ConfigManager:CreateConfig(configName)
            
            configFile:Register("featureToggle", featureToggle)
            configFile:Register("intensitySlider", intensitySlider)
            configFile:Register("modeDropdown", modeDropdown)
            configFile:Register("themeDropdown", themeDropdown)
            configFile:Register("transparencySlider", transparencySlider)
            
            configFile:Set("playerData", MyPlayerData)
            configFile:Set("lastSave", os.date("%Y-%m-%d %H:%M:%S"))
            
            if configFile:Save() then
                WindUI:Notify({ 
                    Title = "保存配置", 
                    Content = "保存为："..configName,
                    Icon = "check",
                    Duration = 3
                })
            else
                WindUI:Notify({ 
                    Title = "错误", 
                    Content = "保存失败",
                    Icon = "x",
                    Duration = 3
                })
            end
        end
    })

    TabHandles.SAN:Button({
        Title = "加载配置",
        Icon = "folder",
        Callback = function()
            configFile = ConfigManager:CreateConfig(configName)
            local loadedData = configFile:Load()
            
            if loadedData then
                if loadedData.playerData then
                    MyPlayerData = loadedData.playerData
                end
                
                local lastSave = loadedData.lastSave or "Unknown"
                WindUI:Notify({ 
                    Title = "加载配置", 
                    Content = "正在加载："..configName.."\n上次保存："..lastSave,
                    Icon = "refresh-cw",
                    Duration = 5
                })
                
                Button = TabHandles.Elements:Button({
                    Title = "玩家数据",
                    Desc = string.format("名字: %s\n等级: %d\n库存: %s", 
                        MyPlayerData.name, 
                        MyPlayerData.level, 
                        table.concat(MyPlayerData.inventory, ", "))
                })
            else
                WindUI:Notify({ 
                    Title = "错误", 
                    Content = "加载失败",
                    Icon = "x",
                    Duration = 3
                })
            end
        end
    })
else
    TabHandles.SAN:Paragraph({
        Title = "配置管理不可用",
        Desc = "此功能需要配置管理",
        Image = "alert-triangle",
        ImageSize = 20,
        Color = "White"
    })
end    
      end
})
Section:Button({
    Title = "TY脚本-99夜",
    Callback = function()
    
local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()
local Confirmed = false

WindUI:Popup({
    Title = "TY脚本",
    IconThemed = true,
    Content = "欢迎尊贵的用户" .. game.Players.LocalPlayer.Name .. "TY脚本 当前版本型号:V2",
    Buttons = {
        {
            Title = "取消",
            Callback = function() end,
            Variant = "Secondary",
        },
        {
            Title = "执行",
            Icon = "arrow-right",
            Callback = function() 
                Confirmed = true
                createUI()
            end,
            Variant = "Primary",
        }
    }
})
function createUI()
    local Window = WindUI:CreateWindow({
        Title = "TY脚本付费版",
        Icon = "palette",
    Author = "尊贵的"..game.Players.localPlayer.Name.."欢迎使用 TY脚本", 
        Folder = "Premium",
        Size = UDim2.fromOffset(550, 320),
        Theme = "Light",
        User = {
            Enabled = true,
            Anonymous = true,
            Callback = function()
            end
        },
        SideBarWidth = 200,
        HideSearchBar = false,  
    })

    Window:Tag({
        Title = "森林中的99夜",
        Color = Color3.fromHex("#00ffff") 
    })

    Window:EditOpenButton({
        Title = "TY脚本付费版V2",
        Icon = "crown",
        CornerRadius = UDim.new(0, 8),
        StrokeThickness = 3,
        Color = ColorSequence.new(
            Color3.fromRGB(255, 255, 0),  
            Color3.fromRGB(255, 165, 0),  
            Color3.fromRGB(255, 0, 0),    
            Color3.fromRGB(139, 0, 0)     
        ),
        Draggable = true,
    })
    
    local Language = Window:Tab({Title = "Language Settings", Icon = "globe"})
local Translations = {
    ["Main"] = "主要",
    ["Biometrics"] = "生体",
    ["Infinite Health"] = "无限血",
    ["Infinite Stamina"] = "无限耐力",
    ["Adapt to all weapons"] = "适应所有的武器",
    ["Attack Method"] = "攻击方式",
    ["Range"] = "范围",
    ["Full Map"] = "全图",
    ["Kill Aura"] = "杀戮光环",
    ["Show Current Weapon"] = "显示当前武器",
    ["Trees"] = "树木",
    ["Chop Range [500 Best]"] = "砍树范围[500最佳]",
    ["Auto Chop Trees"] = "自动砍树",
    ["Children"] = "小孩",
    ["Auto Save All Children"] = "自动救所有小孩",
    ["Auto Equip"] = "自动装备",
    ["Auto Equip Weapons"] = "自动装备武器",
    ["Auto Equip Best Weapon"] = "自动装备最佳武器",
    ["Select Weapon to Equip"] = "选择要装备的武器",
    ["Auto Equip Selected Weapon"] = "自动装备选定武器",
    ["Tool Switching"] = "工具切换",
    ["Random Tool Switching"] = "随机工具切换",
    ["Planting"] = "种植",
    ["Planting Shape"] = "种植形状",
    ["Square"] = "正方形",
    ["Circle"] = "圆形",
    ["Original Position"] = "原地",
    ["Planting Range (meters)"] = "种植范围(米)",
    ["Planting Height"] = "种植高度",
    ["Sapling Spacing (meters)"] = "树苗间隔(米)",
    ["Planting Delay (seconds)"] = "种植延迟(秒)",
    ["Auto Planting"] = "自动种植",
    ["Fun Gameplay"] = "趣味玩法",
    ["Select Pattern"] = "选择图案",
    ["Sphere"] = "球形",
    ["Necklace"] = "项链",
    ["Meteor"] = "流星",
    ["Rotation Speed"] = "旋转速度",
    ["Pattern Size"] = "图案大小",
    ["Auto Form Pattern"] = "自动形成图案",
    ["Prank Friends"] = "恶搞朋友",
    ["Select Attack Player"] = "选择攻击玩家",
    ["None"] = "无",
    ["Auto Bear Trap Attack"] = "自动捕兽夹攻击",
    ["Hitbox"] = "打击盒",
    ["Show Hitbox"] = "显示打击盒",
    ["Wolf Hitbox"] = "狼打击盒",
    ["Bunny Hitbox"] = "兔子打击盒",
    ["Cultist Hitbox"] = "邪教徒打击盒",
    ["Everything Hitbox"] = "所有东西打击盒",
    ["Range Size"] = "范围大小",
    ["Slide to adjust"] = "滑动调整",
    ["Food"] = "食物",
    ["Collect Food"] = "收集食物",
    ["Select food to collect (multiple)"] = "选择要收集的食物（多选）",
    ["Raw Meat Chunk"] = "生肉块",
    ["Raw Steak"] = "生牛排",
    ["Cooked Meat Chunk"] = "熟肉块",
    ["Cooked Steak"] = "熟牛排",
    ["Select Position"] = "选择位置",
    ["Campfire"] = "火堆",
    ["Auto Throw Selected Food"] = "自动扔选择的食物",
    ["Remote Cooking"] = "远程烤肉",
    ["Select meats (multiple)"] = "选择肉类 (多选)",
    ["Meat Chunk"] = "肉块",
    ["Steak"] = "牛排",
    ["Remote Cook Selected Meat"] = "远程烤选择的肉",
    ["Auto Cook Food"] = "自动烹饪食物",
    ["Select Cooking Food"] = "选择烹饪食物",
    ["Ribs"] = "肋骨",
    ["Salmon"] = "三文鱼",
    ["Mackerel"] = "鲭鱼",
    ["Auto Cook Food"] = "自动烹饪食物",
    ["Eat Food"] = "吃食物",
    ["Select Food"] = "选择食物",
    ["Select food to auto eat"] = "选择要自动食用的食物",
    ["Hunger Threshold"] = "饥饿阈值",
    ["Auto Feed"] = "自动进食",
    ["Safety"] = "防鹿",
    ["Auto Stun Deer"] = "自动眩晕鹿",
    ["Requires flashlight"] = "需要手电筒",
    ["Fishing"] = "钓鱼",
    ["Auto Fishing"] = "自动钓鱼",
    ["No Delay Fishing"] = "无延迟钓鱼",
    ["Instant Fishing"] = "秒钓鱼",
    ["Workbench"] = "工作台",
    ["Steel"] = "钢材",
    ["Select steel items to collect (multiple)"] = "选择要收集的钢铁类物品（多选）",
    ["Bolt"] = "螺栓",
    ["Broken Fan"] = "破风扇",
    ["Broken Microwave"] = "坏微波炉",
    ["Old Radio"] = "旧收音机",
    ["Washing Machine"] = "洗衣机",
    ["Old Car Engine"] = "旧汽车引擎",
    ["Tire"] = "轮胎",
    ["Sheet Metal"] = "金属板",
    ["Workbench"] = "工作台",
    ["Auto Throw Selected Steel"] = "自动扔选择的钢铁",
    ["Auto Upgrade Workbench"] = "自动升级工作台",
    ["Auto Craft"] = "自动制作",
    ["Craft Item Name"] = "制作物品名称",
    ["Enter item name to craft"] = "输入要制作的物品名称",
    ["Craft Interval (seconds)"] = "制作间隔(秒)",
    ["Set crafting interval time"] = "设置每次制作的间隔时间",
    ["Craft Once"] = "制作一次",
    ["Auto Craft"] = "自动制作",
    ["Chest Functions"] = "宝箱功能",
    ["Auto Open All Chests"] = "自动开全部宝箱",
    ["Chest Aura"] = "宝箱光环",
    ["Chest Aura Range"] = "宝箱光环范围",
    ["Teleport to Nearest Chest"] = "传送到最近宝箱",
    
    ["Campfire"] = "火堆",
    ["Fuel Items"] = "燃料类",
    ["Select items to collect (multiple)"] = "选择要收集的物品（多选）",
    ["Wood"] = "木头",
    ["Coal"] = "煤",
    ["Fuel Canister"] = "油桶",
    ["Chair"] = "椅子",
    ["Biofuel"] = "生物燃料",
    ["Auto Throw Selected Fuel"] = "自动扔选择的燃料",
    ["Teleport Back to Campfire"] = "传送回火旁",
    
    ["Teleport Functions"] = "传送功能",
    ["Basic Teleport Points"] = "基础传送点",
    ["Teleport to Campfire"] = "传送到营火",
    ["Teleport to Stronghold"] = "传送到要塞",
    ["Teleport to Safe Zone"] = "传送到安全区",
    ["Teleport to Merchant"] = "传送到商人",
    ["Teleport to Random Tree"] = "传送到随机树",
    ["Chest Teleport"] = "宝箱传送",
    ["Select Chest"] = "选择宝箱",
    ["Refresh Chest List"] = "刷新宝箱列表",
    ["Teleport to Chest"] = "传送到宝箱",
    ["Child Teleport"] = "儿童传送",
    ["Select Child"] = "选择儿童",
    ["Refresh Child List"] = "刷新儿童列表",
    ["Teleport to Child"] = "传送到儿童",
    
  
    ["Bring"] = "带来",
    ["Auto Teleport Items"] = "自动传送物品",
    ["Auto Teleport Wood"] = "自动传送木头",
    ["Auto Teleport Fuel Canisters"] = "自动传送燃料罐",
    ["Auto Teleport Oil Barrels"] = "自动传送油桶",
    ["Auto Teleport All Scrap"] = "自动传送所有废料",
    ["Auto Teleport Coal"] = "自动传送煤炭",
    ["Auto Teleport Meat"] = "自动传送肉类",
    
    ["Collection"] = "收集",
    ["Select items to collect (multiple)"] = "选择要收集的物品（多选）",
    ["Auto Collect Selected Items"] = "自动收集选择的物品",
    ["Player Functions"] = "玩家功能",
    ["Speed (On/Off)"] = "速度 (开/关)",
    ["Speed Settings"] = "速度设置",
    ["Invisibility"] = "隐身",
    ["Instant Interaction"] = "秒互动",
    ["Infinite Jump"] = "无限跳",
    ["Language Settings"] = "语言设置",
    ["Current Language"] = "当前语言",
    ["Chinese"] = "中文",
    ["English"] = "英文",
    ["Apply Language"] = "应用语言",
    ["Restart script to take effect"] = "重启脚本生效"
}
local currentLanguage = "English"
local languageChanged = false
Language:Dropdown({
    Title = "Current Language",
    Values = {"English", "中文"},
    Value = "English",
    Callback = function(option)
        if option == "中文" then
            currentLanguage = "Chinese"
        else
            currentLanguage = "English"
        end
        languageChanged = true
    end
})
Language:Button({
    Title = "Apply Language",
    Callback = function()
        if languageChanged then
            WindUI:Notify({
                Title = "Language Change",
                Content = "Please restart the script for changes to take effect",
                Duration = 5,
                Icon = "info"
            })
            languageChanged = false
        else
            WindUI:Notify({
                Title = "Language",
                Content = "Language is already set to " .. currentLanguage,
                Duration = 3,
                Icon = "info"
            })
        end
    end
})
local function translateText(text)
    if not text or type(text) ~= "string" then return text end
    
    if currentLanguage == "Chinese" then
        return Translations[text] or text
    else
        for en, cn in pairs(Translations) do
            if text == cn then
                return en
            end
        end
        return text
    end
end
local function translateGUI(gui)
    if (gui:IsA("TextLabel") or gui:IsA("TextButton") or gui:IsA("TextBox")) then
        pcall(function()
            local text = gui.Text
            if text and text ~= "" then
                local translatedText = translateText(text)
                if translatedText ~= text then
                    gui.Text = translatedText
                end
            end
        end)
    end
end
local function scanAndTranslate()
    for _, gui in ipairs(game:GetService("CoreGui"):GetDescendants()) do
        translateGUI(gui)
    end
    local player = game:GetService("Players").LocalPlayer
    if player and player:FindFirstChild("PlayerGui") then
        for _, gui in ipairs(player.PlayerGui:GetDescendants()) do
            translateGUI(gui)
        end
    end
end
local function setupDescendantListener(parent)
    parent.DescendantAdded:Connect(function(descendant)
        if descendant:IsA("TextLabel") or descendant:IsA("TextButton") or descendant:IsA("TextBox") then
            task.wait(0.1)
            translateGUI(descendant)
        end
    end)
end
local function setupTranslationEngine()
    pcall(setupDescendantListener, game:GetService("CoreGui"))
    local player = game:GetService("Players").LocalPlayer
    if player and player:FindFirstChild("PlayerGui") then
        pcall(setupDescendantListener, player.PlayerGui)
    end
    scanAndTranslate()
    while true do
        scanAndTranslate()
        task.wait(3)
    end
end
task.spawn(function()
    task.wait(2)
    setupTranslationEngine()
end)
    
local Main = Window:Tab({Title = "主要", Icon = "user"})
Main:Section({Title = "生体"})

Main:Button({
    Title = "无限血",
    Callback = function()
        local args = {
    [1] = -math.huge  
}

game:GetService("ReplicatedStorage").RemoteEvents.DamagePlayer:FireServer(unpack(args))
    end
})

Main:Button({
    Title = "无限耐力",
    Callback = function()
        local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if hum then
        hum:GetPropertyChangedSignal("WalkSpeed"):Connect(function()
            hum.WalkSpeed = 20
        end)
        hum.WalkSpeed = 20
    end
    end
})

Main:Section({Title = "适应所有的武器"})
local killAuraEnabled = false
local attackMethod = "范围" 

Main:Dropdown({
    Title = "攻击方式",
    Values = {"范围", "全图"},
    Value = "范围",
    Callback = function(option)
        attackMethod = option
    end
})

Main:Toggle({
    Title = "杀戮光环",
    Value = false,
    Callback = function(value)
        killAuraEnabled = value
        if value then
            spawn(function()
                while killAuraEnabled do
                    local currentTool = nil
                    
              
                    if game.Players.LocalPlayer.Character then
                        for _, item in pairs(game.Players.LocalPlayer.Character:GetChildren()) do
                            if item:IsA("Tool") then
                                currentTool = item
                                break
                            end
                        end
                        
                        if not currentTool and game.Players.LocalPlayer.Character:FindFirstChild("ToolHandle") then
                            local toolHandle = game.Players.LocalPlayer.Character.ToolHandle
                            if toolHandle:FindFirstChild("OriginalItem") and toolHandle.OriginalItem.Value then
                                currentTool = toolHandle.OriginalItem.Value
                            end
                        end
                    end
                    
                    if not currentTool then
                        for _, item in pairs(game.Players.LocalPlayer.Backpack:GetChildren()) do
                            if item:IsA("Tool") then
                                currentTool = item
                                break
                            end
                        end
                    end
                    
                
                    if currentTool then
                        for _, enemy in next, workspace.Characters:GetChildren() do
                            if enemy:IsA("Model") and enemy:FindFirstChild("HumanoidRootPart") and enemy:FindFirstChild("HitRegisters") then
                                if enemy ~= game.Players.LocalPlayer.Character then
                                    local shouldAttack = false
                                    
                                    if attackMethod == "范围" then
                                   
                                        local distance = (game.Players.LocalPlayer.Character.HumanoidRootPart.Position - enemy.HumanoidRootPart.Position).Magnitude
                                        if distance <= 35 then
                                            shouldAttack = true
                                        end
                                    else
                                   
                                        shouldAttack = true
                                    end
                                    
                                    if shouldAttack then
                                        pcall(function()
                                            game:GetService("ReplicatedStorage"):WaitForChild("RemoteEvents"):WaitForChild("ToolDamageObject"):InvokeServer(
                                                enemy, 
                                                currentTool, 
                                                true, 
                                                game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame
                                            )
                                        end)
                                    end
                                end
                            end
                        end
                    end
                    
                    wait(0)
                end
            end)
        end
    end
})

local function ShowCurrentWeapon()
    local currentTool = nil
    local toolName = "无"
    
   
    if game.Players.LocalPlayer.Character then
        for _, item in pairs(game.Players.LocalPlayer.Character:GetChildren()) do
            if item:IsA("Tool") then
                currentTool = item
                break
            end
        end
        
       
        if not currentTool and game.Players.LocalPlayer.Character:FindFirstChild("ToolHandle") then
            local toolHandle = game.Players.LocalPlayer.Character.ToolHandle
            if toolHandle:FindFirstChild("OriginalItem") and toolHandle.OriginalItem.Value then
                currentTool = toolHandle.OriginalItem.Value
            end
        end
    end
    
    
    if not currentTool then
        for _, item in pairs(game.Players.LocalPlayer.Backpack:GetChildren()) do
            if item:IsA("Tool") then
                currentTool = item
                break
            end
        end
    end
    
    
    if currentTool then
        toolName = currentTool.Name
    end
    
    WindUI:Notify({
        Title = "在森林中的99夜",
        Content = "当前武器: " .. toolName,
        Duration = 5,
    })
    
    return currentTool
end
Main:Button({
    Title = "显示当前武器",
    Callback = function()
        ShowCurrentWeapon()
    end
})

Main:Section({Title = "树木"})

local DefaultChopTreeDistance = 500
local DefaultKillAuraDistance = 20
if not DistanceForAutoChopTree then
    DistanceForAutoChopTree = DefaultChopTreeDistance
end
if not DistanceForKillAura then
    DistanceForKillAura = DefaultKillAuraDistance
end

Main:Input({
    Title = "砍树范围[500最佳]",
    Value = tostring(DefaultChopTreeDistance),
    Callback = function(value)
        local numValue = tonumber(value)
        if numValue then
            DistanceForAutoChopTree = numValue
        else
            warn("请输入有效的数字！")
        end
    end
})

Main:Toggle({
    Title = "自动砍树",
    Description = "",
    Default = false,
    Callback = function(Value)
        ActiveAutoChopTree = Value
        task.spawn(function()
            while ActiveAutoChopTree do
                local player = game.Players.LocalPlayer
                local character = player.Character or player.CharacterAdded:Wait()
                local hrp = character:WaitForChild("HumanoidRootPart")
                
               
                local weapon = nil
                for _, item in pairs(player.Inventory:GetChildren()) do
                    if item:IsA("Tool") then
                        weapon = item
                        break
                    end
                end
                
           
                if not weapon then
                    weapon = (player.Inventory:FindFirstChild("Old Axe") or player.Inventory:FindFirstChild("Good Axe") or player.Inventory:FindFirstChild("Strong Axe") or player.Inventory:FindFirstChild("Chainsaw"))
                end

                task.spawn(function()
                    for _, tree in pairs(workspace.Map.Foliage:GetChildren()) do
                        if tree:IsA("Model") and (tree.Name == "Small Tree" or tree.Name == "TreeBig1" or tree.Name == "TreeBig2") and tree.PrimaryPart then
                            local distance = (tree.PrimaryPart.Position - hrp.Position).Magnitude
                            if distance <= DistanceForAutoChopTree and weapon then
                                game:GetService("ReplicatedStorage").RemoteEvents.ToolDamageObject:InvokeServer(tree, weapon, 999, hrp.CFrame)
                            end
                        end
                    end
                end)
                
                task.spawn(function()
                    for _, tree in pairs(workspace.Map.Landmarks:GetChildren()) do
                        if tree:IsA("Model") and (tree.Name == "Small Tree" or tree.Name == "TreeBig1" or tree.Name == "TreeBig2") and tree.PrimaryPart then
                            local distance = (tree.PrimaryPart.Position - hrp.Position).Magnitude
                            if distance <= DistanceForAutoChopTree and weapon then
                                game:GetService("ReplicatedStorage").RemoteEvents.ToolDamageObject:InvokeServer(tree, weapon, 999, hrp.CFrame)
                            end
                        end
                    end
                end)
                
                task.wait(0.1)
            end
        end)
    end
})
Main:Section({Title = "小孩"})

local LocalPlayer = game:GetService("Players").LocalPlayer

local originalPositions = {}
local teleportingEnabled = false
local teleportationThread = nil

Main:Toggle({
    Title = "自动救所有小孩",
    Value = false,
    Callback = function(value)
        teleportingEnabled = value
        
        if value then
          
            for _, kid in pairs(workspace:GetDescendants()) do
                if kid:IsA("Model") and kid.Name:lower():find("kid") then
                    originalPositions[kid] = kid:GetPivot()
                end
            end
            
            
            teleportationThread = task.spawn(function()
                while teleportingEnabled and task.wait(1) do
                    for _, kid in pairs(workspace:GetDescendants()) do
                        if not teleportingEnabled then break end
                        
                        if kid:IsA("Model") and kid.Name:lower():find("kid") then
                            LocalPlayer.Character:PivotTo(kid:GetPivot())
                            task.wait(20) 
                        end
                    end
                end
            end)
        else
         
            if teleportationThread then
                task.cancel(teleportationThread)
                teleportationThread = nil
            end
        end
    end
})



local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

local AutoEquip = Window:Tab({Title = "自动装备", Icon = "user"})

local toolsDamageIDs = {
    ["Old Axe"] = "3_7367831688",
    ["Good Axe"] = "112_7367831688",
    ["Strong Axe"] = "116_7367831688",
    ["Chainsaw"] = "647_8992824875",
    ["Infernal Sword"] = "2_4340578793",
    ["Spear"] = "196_8999010016"
}

local function getAnyToolWithDamageID(isChopAura)
    for toolName, damageID in pairs(toolsDamageIDs) do
        if isChopAura and toolName ~= "Old Axe" and toolName ~= "Good Axe" and toolName ~= "Strong Axe" then
            continue
        end
        local tool = LocalPlayer:FindFirstChild("Inventory") and LocalPlayer.Inventory:FindFirstChild(toolName)
        if tool then
            return tool, damageID
        end
    end
    return nil, nil
end
local function equipTool(tool)
    if tool then
        ReplicatedStorage:WaitForChild("RemoteEvents").EquipItemHandle:FireServer("FireAllClients", tool)
    end
end

local function unequipTool(tool)
    if tool then
        ReplicatedStorage:WaitForChild("RemoteEvents").UnequipItemHandle:FireServer("FireAllClients", tool)
    end
end

AutoEquip:Section({ Title = "自动装备武器", Icon = "user" })

local autoEquipWeapon = false
local weaponEquipConnection

AutoEquip:Toggle({
    Title = "自动装备最佳武器",
    Value = false,
    Callback = function(state)
        autoEquipWeapon = state
        if weaponEquipConnection then
            weaponEquipConnection:Disconnect()
            weaponEquipConnection = nil
        end
        
        if state then
            weaponEquipConnection = RunService.Heartbeat:Connect(function()
                local character = LocalPlayer.Character
                if not character then return end
                
             
                local bestTool = nil
                local bestDamage = 0
                
                for toolName, damageID in pairs(toolsDamageIDs) do
                    local tool = LocalPlayer:FindFirstChild("Inventory") and LocalPlayer.Inventory:FindFirstChild(toolName)
                    if tool then
                   
                        local damage = tonumber(damageID:match("^(%d+)_")) or 0
                        if damage > bestDamage then
                            bestDamage = damage
                            bestTool = tool
                        end
                    end
                end
                
              
                if bestTool then
                    equipTool(bestTool)
                end
            end)
        else
           
            local tool, _ = getAnyToolWithDamageID(false)
            unequipTool(tool)
        end
    end
})

local selectedWeapon = "Strong Axe"

AutoEquip:Dropdown({
    Title = "选择要装备的武器",
    Values = {"Old Axe", "Good Axe", "Strong Axe", "Chainsaw", "Infernal Sword", "Spear"},
    Value = "Strong Axe",
    Callback = function(option)
        selectedWeapon = option
    end
})

local autoEquipSpecific = false
local specificEquipConnection

AutoEquip:Toggle({
    Title = "自动装备选定武器",
    Value = false,
    Callback = function(state)
        autoEquipSpecific = state
        if specificEquipConnection then
            specificEquipConnection:Disconnect()
            specificEquipConnection = nil
        end
        
        if state then
            specificEquipConnection = RunService.Heartbeat:Connect(function()
                local character = LocalPlayer.Character
                if not character then return end
                
                local tool = LocalPlayer:FindFirstChild("Inventory") and LocalPlayer.Inventory:FindFirstChild(selectedWeapon)
                if tool then
                    equipTool(tool)
                else
                    WindUI:Notify({
                        Title = "武器未找到",
                        Content = selectedWeapon .. " 不在背包中",
                        Duration = 3,
                        Icon = "alert-circle"
                    })
                    autoEquipSpecific = false
                    AutoEquip:Find("自动装备选定武器"):SetValue(false)
                end
            end)
        else
            local tool = LocalPlayer:FindFirstChild("Inventory") and LocalPlayer.Inventory:FindFirstChild(selectedWeapon)
            unequipTool(tool)
        end
    end
})
AutoEquip:Section({ Title = "工具切换", Icon = "refresh-cw" })

local autoToolSwitch = false
local toolSwitchConnection

AutoEquip:Toggle({
    Title = "随机工具切换",
    Value = false,
    Callback = function(state)
        autoToolSwitch = state
        if toolSwitchConnection then
            toolSwitchConnection:Disconnect()
            toolSwitchConnection = nil
        end
        
        if state then
            toolSwitchConnection = RunService.Heartbeat:Connect(function()
                local character = LocalPlayer.Character
                if not character then return end
                
                local hrp = character:FindFirstChild("HumanoidRootPart")
                if not hrp then return end
                
              
                local hasEnemyNearby = false
                for _, mob in ipairs(Workspace.Characters:GetChildren()) do
                    if mob:IsA("Model") then
                        local part = mob:FindFirstChildWhichIsA("BasePart")
                        if part and (part.Position - hrp.Position).Magnitude <= 50 then
                            hasEnemyNearby = true
                            break
                        end
                    end
                end
                
             
                local hasTreeNearby = false
                local map = Workspace:FindFirstChild("Map")
                if map then
                    local trees = {}
                    if map:FindFirstChild("Foliage") then
                        for _, obj in ipairs(map.Foliage:GetChildren()) do
                            if obj:IsA("Model") and (obj.Name == "Small Tree" or obj.Name == "Snowy Small Tree") then
                                table.insert(trees, obj)
                            end
                        end
                    end
                    if map:FindFirstChild("Landmarks") then
                        for _, obj in ipairs(map.Landmarks:GetChildren()) do
                            if obj:IsA("Model") and obj.Name == "Small Tree" then
                                table.insert(trees, obj)
                            end
                        end
                    end
                    
                    for _, tree in ipairs(trees) do
                        local trunk = tree:FindFirstChild("Trunk")
                        if trunk and trunk:IsA("BasePart") and (trunk.Position - hrp.Position).Magnitude <= 50 then
                            hasTreeNearby = true
                            break
                        end
                    end
                end
                
            
                if hasEnemyNearby then
                   
                    local combatTools = {"Infernal Sword", "Spear", "Chainsaw", "Strong Axe", "Good Axe"}
                    for _, toolName in ipairs(combatTools) do
                        local tool = LocalPlayer:FindFirstChild("Inventory") and LocalPlayer.Inventory:FindFirstChild(toolName)
                        if tool then
                            equipTool(tool)
                            break
                        end
                    end
                elseif hasTreeNearby then
                
                    local loggingTools = {"Chainsaw", "Strong Axe", "Good Axe", "Old Axe"}
                    for _, toolName in ipairs(loggingTools) do
                        local tool = LocalPlayer:FindFirstChild("Inventory") and LocalPlayer.Inventory:FindFirstChild(toolName)
                        if tool then
                            equipTool(tool)
                            break
                        end
                    end
                else
                  
                    local bestTool = nil
                    local bestDamage = 0
                    
                    for toolName, damageID in pairs(toolsDamageIDs) do
                        local tool = LocalPlayer:FindFirstChild("Inventory") and LocalPlayer.Inventory:FindFirstChild(toolName)
                        if tool then
                            local damage = tonumber(damageID:match("^(%d+)_")) or 0
                            if damage > bestDamage then
                                bestDamage = damage
                                bestTool = tool
                            end
                        end
                    end
                    
                    if bestTool then
                        equipTool(bestTool)
                    end
                end
            end)
        else
          
            local tool, _ = getAnyToolWithDamageID(false)
            unequipTool(tool)
        end
    end
})

local Main = Window:Tab({Title = "种植", Icon = "user"})

local plantingConfig = {
    shape = "square",  
    size = 80,        
    height = 3,     
    spacing = 1,       
    delay = 1          
}

local shapeOptions = {
    ["正方形"] = "square",
    ["圆形"] = "circle",
    ["原地"] = "original"
}
local function generatePlantPositions()
    local positions = {}
    local halfSize = plantingConfig.size / 2
    local playerPosition = Vector3.new(0.6491832137107849, plantingConfig.height, -3.8000376224517822)
    
    if plantingConfig.shape == "square" then
     
        positions = {}
        
       
        
        for x = -halfSize, halfSize, plantingConfig.spacing do
            table.insert(positions, Vector3.new(playerPosition.X + x, playerPosition.Y, playerPosition.Z + halfSize))
        end
        
      
        for z = halfSize, -halfSize, -plantingConfig.spacing do
            table.insert(positions, Vector3.new(playerPosition.X + halfSize, playerPosition.Y, playerPosition.Z + z))
        end
        
        
        for x = halfSize, -halfSize, -plantingConfig.spacing do
            table.insert(positions, Vector3.new(playerPosition.X + x, playerPosition.Y, playerPosition.Z - halfSize))
        end
        
  
        for z = -halfSize, halfSize, plantingConfig.spacing do
            table.insert(positions, Vector3.new(playerPosition.X - halfSize, playerPosition.Y, playerPosition.Z + z))
        end
    elseif plantingConfig.shape == "circle" then
       
        positions = {}
        
    
        local radius = halfSize
        local circumference = 2 * math.pi * radius
        local pointCount = math.floor(circumference / plantingConfig.spacing)
        
        for i = 1, pointCount do
            local angle = (i / pointCount) * 2 * math.pi
            local x = radius * math.cos(angle)
            local z = radius * math.sin(angle)
            table.insert(positions, Vector3.new(playerPosition.X + x, playerPosition.Y, playerPosition.Z + z))
        end
    else
     
        positions = {}
        
      
        table.insert(positions, Vector3.new(playerPosition.X, playerPosition.Y, playerPosition.Z))
    end
    
    return positions
end

local saplingPositions = generatePlantPositions()
local currentSaplingIndex = 1
local isPlanting = false

local function plantSapling()
    if isPlanting then return false end
    isPlanting = true
    
    local success = false
    local remoteEvents = game:GetService("ReplicatedStorage").RemoteEvents
    local tempStorage = game:GetService("ReplicatedStorage").TempStorage
    
    local sapling = tempStorage:FindFirstChild("Sapling")
    if not sapling then
        sapling = workspace.Items:FindFirstChild("Sapling")
    end
    
    if sapling then
        local plantPosition = saplingPositions[currentSaplingIndex]
        
        pcall(function()
            remoteEvents.StopDraggingItem:FireServer(sapling)
            task.wait(0.1)
            remoteEvents.RequestPlantItem:InvokeServer(sapling, plantPosition)
            success = true
        end)
        
        currentSaplingIndex = currentSaplingIndex + 1
        if currentSaplingIndex > #saplingPositions then
            currentSaplingIndex = 1
        end
    end
    
    isPlanting = false
    return success
end

Main:Dropdown({
    Title = "种植形状",
    Values = {"正方形", "圆形", "原地"},
    Value = "正方形",
    Callback = function(option)
        plantingConfig.shape = shapeOptions[option]
        saplingPositions = generatePlantPositions()
        currentSaplingIndex = 1
    end
})

Main:Input({
    Title = "种植范围(米)",
    Desc = "设置种植范围大小",
    Value = tostring(plantingConfig.size),
    Placeholder = "输入范围大小",
    Callback = function(input)
        local num = tonumber(input)
        if num and num > 0 then
            plantingConfig.size = num
            saplingPositions = generatePlantPositions()
            currentSaplingIndex = 1
        end
    end
})

Main:Input({
    Title = "种植高度",
    Desc = "设置种植高度",
    Value = tostring(plantingConfig.height),
    Placeholder = "输入高度",
    Callback = function(input)
        local num = tonumber(input)
        if num then
            plantingConfig.height = num
            saplingPositions = generatePlantPositions()
            currentSaplingIndex = 1
        end
    end
})

Main:Input({
    Title = "树苗间隔(米)",
    Desc = "设置树苗之间的间隔[推荐2.5]",
    Value = tostring(plantingConfig.spacing),
    Placeholder = "输入间隔距离",
    Callback = function(input)
        local num = tonumber(input)
        if num and num > 0 then
            plantingConfig.spacing = num
            saplingPositions = generatePlantPositions()
            currentSaplingIndex = 1
        end
    end
})

Main:Input({
    Title = "种植延迟(秒)",
    Desc = "设置每次种植的延迟时间",
    Value = tostring(plantingConfig.delay),
    Placeholder = "输入延迟时间",
    Callback = function(input)
        local num = tonumber(input)
        if num and num > 0 then
            plantingConfig.delay = num
        end
    end
})

local plantLoop = nil

Main:Toggle({
    Title = "自动种植",
    Default = false,
    Callback = function(state)
        if plantLoop then
            plantLoop:Disconnect()
            plantLoop = nil
        end
        
        if state then
            plantLoop = game:GetService("RunService").Heartbeat:Connect(function()
                local planted = plantSapling()
                if not planted then
                    task.wait(1)
                else
                    task.wait(plantingConfig.delay)
                end
            end)
        end
    end
})

local Main = Window:Tab({Title = "趣味玩法", Icon = "user"})
local teleportConfig = {
    pattern = "sphere",  
    speed = 5,        
    radius = 75,       
    height = 100       
}

local patternOptions = {
    ["球形"] = "sphere",
    ["项链"] = "star",
    ["流星"] = "meteor"
}

local centerPosition = Vector3.new(0.6491832137107849, teleportConfig.height, -3.8000376224517822)
local rotationAngle = 0
local teleporting = false
local function generatePatternPositions(itemCount)
    local positions = {}
    rotationAngle = rotationAngle + teleportConfig.speed * 0.01
    
    if teleportConfig.pattern == "sphere" then
      
        for i = 1, itemCount do
            local phi = math.acos(-1 + (2 * i - 1) / itemCount)
            local theta = math.sqrt(itemCount * math.pi) * phi
            
            local x = teleportConfig.radius * math.cos(theta + rotationAngle) * math.sin(phi)
            local y = teleportConfig.radius * math.sin(theta + rotationAngle) * math.sin(phi)
            local z = teleportConfig.radius * math.cos(phi)
            
            table.insert(positions, centerPosition + Vector3.new(x, y, z))
        end
    elseif teleportConfig.pattern == "star" then
       
        local points = 5
        for i = 1, itemCount do
            local angle = (i / itemCount) * math.pi * 2 * points + rotationAngle
            local radius = teleportConfig.radius * (i % 2 == 0 and 0.5 or 1)
            
            local x = radius * math.cos(angle)
            local z = radius * math.sin(angle)
            
            table.insert(positions, centerPosition + Vector3.new(x, 0, z))
        end
    elseif teleportConfig.pattern == "meteor" then
       
        for i = 1, itemCount do
            local angle = (i / itemCount) * math.pi * 2 + rotationAngle
            local x = teleportConfig.radius * math.cos(angle)
            local z = teleportConfig.radius * math.sin(angle)
            local y = teleportConfig.radius * 0.5 * math.sin(angle * 2)
            
            table.insert(positions, centerPosition + Vector3.new(x, y, z))
        end
    end
    
    return positions
end

local function teleportLogs()
    if teleporting then return end
    teleporting = true
    
    local logs = {}
    for _, item in pairs(workspace.Items:GetChildren()) do
        if item.Name:lower():find("log") and item:IsA("Model") then
            table.insert(logs, item)
        end
    end
    
    if #logs > 0 then
        local positions = generatePatternPositions(#logs)
        
        for i, log in ipairs(logs) do
            local main = log:FindFirstChildWhichIsA("BasePart")
            if main then
                local targetPos = positions[i] or positions[1]
                main.CFrame = CFrame.new(targetPos)
                main.AssemblyLinearVelocity = Vector3.new(0, 0, 0)  
            end
        end
    end
    
    teleporting = false
end

Main:Dropdown({
    Title = "选择图案",
    Values = {"球形", "项链", "流星"},
    Value = "球形",
    Callback = function(option)
        teleportConfig.pattern = patternOptions[option]
    end
})

Main:Input({
    Title = "旋转速度",
    Desc = "设置旋转速度",
    Value = tostring(teleportConfig.speed),
    Placeholder = "输入旋转速度",
    Callback = function(input)
        local num = tonumber(input)
        if num and num >= 1 and num <= 10 then
            teleportConfig.speed = num
        end
    end
})

Main:Input({
    Title = "图案大小",
    Desc = "设置图案大小",
    Value = tostring(teleportConfig.radius),
    Placeholder = "输入图案大小",
    Callback = function(input)
        local num = tonumber(input)
        if num and num >= 10 and num <= 50 then
            teleportConfig.radius = num
        end
    end
})

local teleportLoop = nil

Main:Toggle({
    Title = "自动形成图案",
    Default = false,
    Callback = function(state)
        if teleportLoop then
            teleportLoop:Disconnect()
            teleportLoop = nil
        end
        
        if state then
            teleportLoop = game:GetService("RunService").Heartbeat:Connect(function()
                teleportLogs()
            end)
        end
    end
})

local Main = Window:Tab({Title = "恶搞朋友", Icon = "user"})
local autoUseBearTrap = false
local selectedTrapPlayer = "无"
local trapPlayerList = {"无"}
local trapDropdownRef = nil

local function updateTrapPlayerList()
    local currentPlayers = game.Players:GetPlayers()
    local newPlayerList = {"无"}
    
    for _, player in ipairs(currentPlayers) do
        if player ~= game.Players.LocalPlayer then
            table.insert(newPlayerList, player.Name)
        end
    end
    
    trapPlayerList = newPlayerList
    
    if trapDropdownRef then
        trapDropdownRef:Refresh(trapPlayerList, true)
    end
    
    if selectedTrapPlayer and selectedTrapPlayer ~= "无" and not table.find(trapPlayerList, selectedTrapPlayer) then
        WindUI:Notify({
            Title = "NE提示",
            Content = "目标玩家："..selectedTrapPlayer.." 已退出服务器",
            Duration = 5,
        })
        selectedTrapPlayer = "无"
        if trapDropdownRef then
            trapDropdownRef:Set("无")
        end
    end
end

game.Players.PlayerAdded:Connect(updateTrapPlayerList)
game.Players.PlayerRemoving:Connect(function(player)
    if selectedTrapPlayer and selectedTrapPlayer ~= "无" and player.Name == selectedTrapPlayer then
        WindUI:Notify({
            Title = "NE提示",
            Content = "目标玩家："..selectedTrapPlayer.." 已退出服务器",
            Duration = 5,
        })
    end
    updateTrapPlayerList()
end)

updateTrapPlayerList()

trapDropdownRef = Main:Dropdown({
    Title = "选择攻击玩家",
    Values = trapPlayerList,
    Value = "无",
    Callback = function(option)
        selectedTrapPlayer = option
    end
})

Main:Toggle({
    Title = "自动捕兽夹攻击",
    Default = false,
    Callback = function(Value)
        autoUseBearTrap = Value
        task.spawn(function()
            while autoUseBearTrap and task.wait() do
                if selectedTrapPlayer == "无" then
                    WindUI:Notify({
                        Title = "捕提示",
                        Content = "请先选择要的玩家",
                        Duration = 3,
                    })
                    autoUseBearTrap = false
                    break
                end
                
                local targetPlayer = game.Players:FindFirstChild(selectedTrapPlayer)
                if not targetPlayer or not targetPlayer.Character or not targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
                    continue
                end
                
                local targetHRP = targetPlayer.Character.HumanoidRootPart
                local targetPosition = targetHRP.Position + Vector3.new(0, 1, 0)
                
                local bearTraps = {}
                
                for _, structure in pairs(workspace.Structures:GetChildren()) do
                    if structure.Name:find("Bear Trap") and structure:IsA("Model") then
                        table.insert(bearTraps, structure)
                    end
                end
                
                for _, item in pairs(workspace.Items:GetChildren()) do
                    if item.Name:find("Bear Trap") and item:IsA("Model") then
                        table.insert(bearTraps, item)
                    end
                end
                
                if workspace:FindFirstChild("Game") and workspace.Game:FindFirstChild("Entities") then
                    for _, entity in pairs(workspace.Game.Entities:GetChildren()) do
                        if entity.Name:find("Bear Trap") and entity:IsA("Model") then
                            table.insert(bearTraps, entity)
                        end
                    end
                end
                
                if #bearTraps > 0 then
                    for _, bearTrap in pairs(bearTraps) do
                        if not autoUseBearTrap then break end
                        
                        if not bearTrap.PrimaryPart then
                            for _, part in pairs(bearTrap:GetChildren()) do
                                if part:IsA("BasePart") then
                                    bearTrap.PrimaryPart = part
                                    break
                                end
                            end
                        end
                        
                        if bearTrap.PrimaryPart then
                            pcall(function()
                                local args = {[1] = bearTrap}
                                game:GetService("ReplicatedStorage").RemoteEvents.RequestStartDraggingItem:FireServer(unpack(args))
                                bearTrap:SetPrimaryPartCFrame(CFrame.new(targetPosition))
                                game:GetService("ReplicatedStorage").RemoteEvents.StopDraggingItem:FireServer(bearTrap)
                                local setArgs = {[1] = bearTrap}
                                game:GetService("ReplicatedStorage").RemoteEvents.RequestSetTrap:FireServer(unpack(setArgs))
                            end)
                        end
                    end
                end
            end
        end)
    end
})


local Hitbox = Window:Tab({Title = "打击盒", Icon = "user"})
local hitboxSettings = {
    Wolf = false,
    Bunny = false,
    Cultist = false,
    All = false,
    Show = false,
    Size = 10
}
local originalSizes = {}

local function updateHitboxForModel(model)
    local root = model:FindFirstChild("HumanoidRootPart")
    if not root then return end
    local name = model.Name:lower()
    if not originalSizes[model] then
        originalSizes[model] = root.Size
    end

    local shouldResize = hitboxSettings.All or
        (hitboxSettings.Wolf and (name:find("wolf") or name:find("alpha"))) or
        (hitboxSettings.Bunny and name:find("bunny")) or
        (hitboxSettings.Cultist and (name:find("cultist") or name:find("cross")))

    if shouldResize and hitboxSettings.Show then
        root.Size = Vector3.new(hitboxSettings.Size, hitboxSettings.Size, hitboxSettings.Size)
        root.Transparency = 0.5
        root.Color = Color3.fromRGB(255, 255, 255)
        root.Material = Enum.Material.Neon
        root.CanCollide = false
    else
        if originalSizes[model] then
            root.Size = originalSizes[model]
        end
        root.Transparency = 1
        root.Material = Enum.Material.Plastic
        root.CanCollide = true
    end
end
workspace.DescendantRemoving:Connect(function(descendant)
    if descendant:IsA("Model") and originalSizes[descendant] then
        originalSizes[descendant] = nil
    end
end)

task.spawn(function()
    while true do
        for _, model in ipairs(workspace:GetDescendants()) do
            if model:IsA("Model") and model:FindFirstChild("HumanoidRootPart") then
                updateHitboxForModel(model)
            end
        end
        task.wait(1) 
    end
end)

Hitbox:Toggle({
    Title = "显示打击盒",
    Default = false,
    Callback = function(v)
        hitboxSettings.Show = v
    end
})

Hitbox:Toggle({
    Title = "狼打击盒",
    Default = false,
    Callback = function(v)
        hitboxSettings.Wolf = v
    end
})

Hitbox:Toggle({
    Title = "兔子打击盒",
    Default = false,
    Callback = function(v)
        hitboxSettings.Bunny = v
    end
})

Hitbox:Toggle({
    Title = "邪教徒打击盒",
    Default = false,
    Callback = function(v)
        hitboxSettings.Cultist = v
    end
})

Hitbox:Toggle({
    Title = "所有东西打击盒",
    Default = false,
    Callback = function(v)
        hitboxSettings.All = v
    end
})

Hitbox:Slider({
    Title = "范围大小",
    Desc = "滑动调整",
    Value = {
        Min = 2,
        Max = 250,
        Default = 10,
    },
    Callback = function(Value)
        hitboxSettings.Size = Value
    end
})


local Main = Window:Tab({Title = "食物", Icon = "user"})
Main:Section({Title = "收集食物"})
local foodItems = {
    ["生肉块"]   = "Morsel",
    ["生牛排"]   = "Steak",
    ["熟肉块"]   = "Cooked Morsel",
    ["熟牛排"]   = "Cooked Steak"
}

local selectedItems = {}

Main:Dropdown({
    Title  = "选择要收集的食物（多选）",
    Values = {"生肉块", "生牛排", "熟肉块", "熟牛排"},
    Value  = {},
    Multi  = true,
    Callback = function(options)
        selectedItems = {}
        for _, option in ipairs(options) do
            selectedItems[foodItems[option]] = true
        end
    end
})

local autoCollectAndDropLogs = false
local collectDelay = 0.01

local positionOptions = {
    ["原地"] = nil, 
    ["火堆"] = Vector3.new(1.4, 25.9, -0.9)
}

local selectedPosition = positionOptions["火堆"]

Main:Dropdown({
    Title = "选择位置",
    Values = {"原地", "火堆"},
    Value = "火堆",
    Callback = function(option)
        selectedPosition = positionOptions[option]
    end
})

local function fixPlayerPosition()
    local player = game:GetService("Players").LocalPlayer
    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        local targetPosition
        if selectedPosition then
            targetPosition = selectedPosition
        else
     
            targetPosition = player.Character.HumanoidRootPart.Position + Vector3.new(0, 5, 0)
        end
        player.Character.HumanoidRootPart.CFrame = CFrame.new(targetPosition)
        player.Character.HumanoidRootPart.Anchored = true
    end
end

local function CollectAndDropLogs()
    if not autoCollectAndDropLogs then return end
    if not next(selectedItems) then return end
    
    local player = game:GetService("Players").LocalPlayer
    if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then return end
    
    fixPlayerPosition()
    local hrp = player.Character.HumanoidRootPart
    
    local items = {}
    for _, item in pairs(workspace.Items:GetChildren()) do
        if selectedItems[item.Name] and item:IsA("Model") then
            table.insert(items, item)
        end
    end

    table.sort(items, function(a, b)
        local aPart = a.PrimaryPart or a:FindFirstChildWhichIsA("BasePart")
        local bPart = b.PrimaryPart or b:FindFirstChildWhichIsA("BasePart")
        if not aPart or not bPart then return false end
        return (hrp.Position - aPart.Position).Magnitude < (hrp.Position - bPart.Position).Magnitude
    end)

    for _, item in ipairs(items) do
        if not autoCollectAndDropLogs then break end
        
        local itemPart = item.PrimaryPart or item:FindFirstChildWhichIsA("BasePart")
        if not itemPart then continue end
        
        itemPart.CFrame = CFrame.new(hrp.Position + Vector3.new(0, 0, 2))
        task.wait(0.05)
        
        game:GetService("ReplicatedStorage").RemoteEvents.RequestStartDraggingItem:FireServer(item)
        task.wait(0.05)
        
        game:GetService("ReplicatedStorage").RemoteEvents.ReplicateSound:FireServer(
            "FireAllClients",
            "BagGet",
            {
                ["Instance"] = player.Character.Head,
                ["Volume"] = 0.25
            }
        )
        
        game:GetService("ReplicatedStorage").RemoteEvents.StopDraggingItem:FireServer(item)
        
        task.wait(collectDelay)
    end
end

Main:Toggle({
    Title = "自动扔选择的食物",
    Value = false,
    Callback = function(value)
        autoCollectAndDropLogs = value
        if value then
            fixPlayerPosition()
            spawn(function()
                while autoCollectAndDropLogs do
                    CollectAndDropLogs()
                    task.wait(0.1)
                end
            end)
        else
            local player = game:GetService("Players").LocalPlayer
            if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                player.Character.HumanoidRootPart.Anchored = false
            end
        end
    end
})


Main:Section({Title = "远程烤肉"})

local function getNil(name, class)
    for _, v in pairs(getnilinstances()) do
        if v.ClassName == class and v.Name == name then
            return v
        end
    end
end

local autoCook = false
local selectedMeats = {} 

local function cookItem(itemName)
    local fire = workspace.Map.Campground.MainFire
    local item = workspace.Items:FindFirstChild(itemName) or getNil(itemName, "Model")
    
    if fire and item then
        local args = {fire, item}
        game:GetService("ReplicatedStorage").RemoteEvents.RequestCookItem:FireServer(unpack(args))
        return true
    end
    return false
end

local function CookItems()
    if not autoCook then return end
    
  
    for meatName, selected in pairs(selectedMeats) do
        if selected then
            cookItem(meatName)
        end
    end
end

local meatOptions = {
    ["肉块"] = "Morsel",
    ["牛排"] = "Steak"
   
}

Main:Dropdown({
    Title = "选择肉类 (多选)",
    Values = {"肉块", "牛排"},
    Value = {}, 
    Multi = true, 
    Callback = function(selectedOptions)
        selectedMeats = {}
        for _, optionName in pairs(selectedOptions) do
            local meatKey = meatOptions[optionName]
            if meatKey then
                selectedMeats[meatKey] = true
            end
        end
    end
})

Main:Toggle({
    Title = "远程烤选择的肉",
    Value = false,
    Callback = function(value)
        autoCook = value
        if value then
            spawn(function()
                while autoCook do
                    CookItems()
                    task.wait() 
                end
            end)
        end
    end
})
local autocookItems = {"Morsel", "Steak", "Ribs", "Salmon", "Mackerel"}
local autocookItemsDisplay = {"肉块", "牛排", "肋骨", "三文鱼", "鲭鱼"} 
local autoCookEnabledItems = {}
local autoCookEnabled = false
local cookItemMapping = {
    ["肉块"] = "Morsel",
    ["牛排"] = "Steak", 
    ["肋骨"] = "Ribs",
    ["三文鱼"] = "Salmon",
    ["鲭鱼"] = "Mackerel"
}

Main:Section({ Title = "自动烹饪食物", Icon = "user" })

Main:Dropdown({
    Title = "选择烹饪食物",
    Values = autocookItemsDisplay, 
    Multi = true,
    AllowNone = true,
    Callback = function(options)
        for itemName, _ in pairs(autoCookEnabledItems) do
            autoCookEnabledItems[itemName] = false
        end
        for _, chineseName in ipairs(options) do
            local englishName = cookItemMapping[chineseName]
            if englishName then
                autoCookEnabledItems[englishName] = true
            end
        end
    end
})

Main:Toggle({
    Title = "自动烹饪食物",
    Value = false,
    Callback = function(state)
        autoCookEnabled = state
        if state then
            WindUI:Notify({
                Title = "自动烹饪已开启",
                Content = "开始自动烹饪选择的食物",
                Duration = 2,
                Icon = "flame"
            })
        else
            WindUI:Notify({
                Title = "自动烹饪已关闭", 
                Content = "停止自动烹饪食物",
                Duration = 2,
                Icon = "flame"
            })
        end
    end
})
coroutine.wrap(function()
    while true do
        if autoCookEnabled then
            for itemName, enabled in pairs(autoCookEnabledItems) do
                if enabled then
                    for _, item in ipairs(Workspace:WaitForChild("Items"):GetChildren()) do
                        if item.Name == itemName then
                            moveItemToPos(item, campfireDropPos)
                        end
                    end
                end
            end
        end
        task.wait(0.5)
    end
end)()


Main:Section({Title = "吃食物"})

local alimentos = {
    "Apple", "Berry", "Carrot", "Cake", "Chili", 
    "Cooked Ribs", "Cooked Mackerel", "Cooked Salmon", 
    "Cooked Morsel", "Cooked Steak"
}
local selectedFood = {}
local hungerThreshold = 75
local autoFeedToggle = false

Main:Dropdown({
    Title = "选择食物",
    Desc = "选择要自动食用的食物",
    Values = alimentos,
    Value = selectedFood,
    Multi = true,
    Callback = function(value)
        selectedFood = value
    end
})

Main:Input({
    Title = "饥饿阈值",
    Desc = "当饥饿度低于此值时自动进食",
    Value = tostring(hungerThreshold),
    Placeholder = "例如: 50",
    Numeric = true,
    Callback = function(value)
        local n = tonumber(value)
        if n then
            hungerThreshold = math.clamp(n, 0, 100)
        end
    end
})

Main:Toggle({
    Title = "自动进食",
    Value = false,
    Callback = function(state)
        autoFeedToggle = state
        if state then
            task.spawn(function()
                while autoFeedToggle do
                    task.wait(0.1)
                    local function wiki(nome)
                        local c = 0
                        for _, i in ipairs(Workspace.Items:GetChildren()) do
                            if i.Name == nome then
                                c = c + 1
                            end
                        end
                        return c
                    end
                    
                    local function ghn()
                        return math.floor(LocalPlayer.PlayerGui.Interface.StatBars.HungerBar.Bar.Size.X.Scale * 100)
                    end
                    
                    local function feed(nome)
                        for _, item in ipairs(Workspace.Items:GetChildren()) do
                            if item.Name == nome then
                                ReplicatedStorage.RemoteEvents.RequestConsumeItem:InvokeServer(item)
                                break
                            end
                        end
                    end
                    
                    if #selectedFood > 0 then
                        for _, food in ipairs(selectedFood) do
                            if wiki(food) == 0 then
                                autoFeedToggle = false
                                WindUI:Notify({
                                    Title = "自动进食暂停",
                                    Content = food .. " 已耗尽",
                                    Duration = 3
                                })
                                break
                            end
                            if ghn() <= hungerThreshold then
                                feed(food)
                            end
                        end
                    end
                end
            end)
        end
    end
})

local Safety = Window:Tab({Title = "防鹿", Icon = "user"})

Safety:Toggle({
    Title = "自动眩晕鹿",
    Desc = "需要手电筒",
    Value = false,
    Callback = function(state)
        if state then
            local torchLoop = RunService.RenderStepped:Connect(function()
                pcall(function()
                    local remote = ReplicatedStorage:FindFirstChild("RemoteEvents")
                        and ReplicatedStorage.RemoteEvents:FindFirstChild("DeerHitByTorch")
                    local deer = Workspace:FindFirstChild("Characters")
                        and Workspace.Characters:FindFirstChild("Deer")
                    if remote and deer then
                        remote:InvokeServer(deer)
                    end
                end)
                task.wait(0.1)
            end)
        else
            if torchLoop then
                torchLoop:Disconnect()
                torchLoop = nil
            end
        end
    end
})
local Main = Window:Tab({Title = "钓鱼", Icon = "user"})

Main:Toggle({
    Title = "自动钓鱼",
    Value = false,
    Callback = function(value)
        autoFishingEnabled = value
        if value then
            spawn(function()
                local Players = game:GetService("Players")
                local RunService = game:GetService("RunService")
                local player = Players.LocalPlayer
                local playerGui = player:WaitForChild("PlayerGui")
                
                task.wait(1)
                
                local fishingCatchFrame = playerGui.Interface.FishingCatchFrame
                local timingBar = fishingCatchFrame.TimingBar
                local successArea = timingBar.SuccessArea
                local bar = timingBar.Bar
                local button = playerGui.MobileButtons.Frame.Button3
                local canClick = true
                
                local function checkOverlap(f1, f2)
                    local p1 = f1.AbsolutePosition
                    local s1 = f1.AbsoluteSize
                    local p2 = f2.AbsolutePosition
                    local s2 = f2.AbsoluteSize
                    
                    return not (
                        p1.X + s1.X < p2.X or
                        p2.X + s2.X < p1.X or
                        p1.Y + s1.Y < p2.Y or
                        p2.Y + s2.Y < p1.Y
                    )
                end
                
                local function clickButton()
                    for _, connection in pairs(getconnections(button.MouseButton1Down)) do
                        connection:Fire()
                    end
                end
                
                while autoFishingEnabled do
                    if fishingCatchFrame.Visible and timingBar.Visible then
                        if checkOverlap(successArea, bar) and canClick then
                            canClick = false
                            clickButton()
                            task.wait(0.1)
                            canClick = true
                        end
                    else
                        canClick = true
                    end
                    wait(0)
                end
            end)
        end
    end
})
Main:Toggle({
    Title = "无延迟钓鱼",
    Value = false,
    Callback = function(value)
        noDelayFishing = value
        if value then
            spawn(function()
                local Players = game:GetService("Players")
                local player = Players.LocalPlayer
                local playerGui = player:WaitForChild("PlayerGui")
                
                task.wait(1)
                
                local button = playerGui.MobileButtons.Frame.Button3
                
                local function clickButton()
                    for _, connection in pairs(getconnections(button.MouseButton1Down)) do
                        connection:Fire()
                    end
                end
                
                while noDelayFishing do
             
                    if playerGui.Interface.FishingCatchFrame.Visible then
                        clickButton()
                    end
                    wait(0)
                end
            end)
        end
    end
})
Main:Toggle({
    Title = "秒钓鱼",
    Value = false,
    Callback = function(value)
        instantFishing = value
        if value then
            spawn(function()
                local Players = game:GetService("Players")
                local ReplicatedStorage = game:GetService("ReplicatedStorage")
                local player = Players.LocalPlayer
                
                while instantFishing do
          
                    pcall(function()
                        local remote = ReplicatedStorage:FindFirstChild("RemoteEvents")
                        if remote then
                            local finishFishing = remote:FindFirstChild("FinishFishing")
                            if finishFishing then
                                finishFishing:FireServer(true) 
                            end
                        end
                    end)
                    wait(0.1) 
                end
            end)
        end
    end
})



local Main = Window:Tab({Title = "工作台", Icon = "user"})

Main:Section({Title = "钢材"})

local steelItems = {
    ["螺栓"]            = "Bolt",
    ["破风扇"]          = "Broken Fan",
    ["坏微波炉"]        = "Broken Microwave",
    ["旧收音机"]        = "Old Radio",
    ["洗衣机"]          = "Washing Machine",
    ["旧汽车引擎"]      = "Old Car Engine",
    ["轮胎"]            = "tyre",
    ["金属板"]          = "Sheet Metal"
}

local dropPositions = {
    ["工作台"] = Vector3.new(21.67, 6.34, -4.05),
    ["火堆"] = Vector3.new(3.04, 11.70, 1.01)
}

local selectedItems = {}
local selectedDropPosition = dropPositions["工作台"] 

Main:Dropdown({
    Title = "选择要收集的钢铁类物品（多选）",
    Values = {"螺栓", "破风扇", "坏微波炉", "旧收音机", "洗衣机", "旧汽车引擎", "轮胎", "金属板"},
    Value = {},
    Multi = true,
    Callback = function(options)
        selectedItems = {}
        for _, option in ipairs(options) do
            selectedItems[steelItems[option]] = true
        end
    end
})

local autoCollectAndDropLogs = false
local collectDelay = 0.01

local positionOptions = {
    ["原地"] = nil, 
    ["工作台"] = Vector3.new(19.4, 15.0, -5.5)
}

local selectedPosition = positionOptions["工作台"]

Main:Dropdown({
    Title = "选择位置",
    Values = {"原地", "工作台"},
    Value = "工作台",
    Callback = function(option)
        selectedPosition = positionOptions[option]
    end
})

local function fixPlayerPosition()
    local player = game:GetService("Players").LocalPlayer
    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        local targetPosition
        if selectedPosition then
            targetPosition = selectedPosition
        else
         
            targetPosition = player.Character.HumanoidRootPart.Position + Vector3.new(0, 5, 0)
        end
        player.Character.HumanoidRootPart.CFrame = CFrame.new(targetPosition)
        player.Character.HumanoidRootPart.Anchored = true
    end
end

local function CollectAndDropLogs()
    if not autoCollectAndDropLogs then return end
    if not next(selectedItems) then return end 
    
    local player = game:GetService("Players").LocalPlayer
    if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then return end
    
    fixPlayerPosition()
    local hrp = player.Character.HumanoidRootPart
    
    local items = {}
    for _, item in pairs(workspace.Items:GetChildren()) do
        if selectedItems[item.Name] and item:IsA("Model") then
            table.insert(items, item)
        end
    end

    table.sort(items, function(a, b)
        local aPart = a.PrimaryPart or a:FindFirstChildWhichIsA("BasePart")
        local bPart = b.PrimaryPart or b:FindFirstChildWhichIsA("BasePart")
        if not aPart or not bPart then return false end
        return (hrp.Position - aPart.Position).Magnitude < (hrp.Position - bPart.Position).Magnitude
    end)

    for _, item in ipairs(items) do
        if not autoCollectAndDropLogs then break end
        
        local itemPart = item.PrimaryPart or item:FindFirstChildWhichIsA("BasePart")
        if not itemPart then continue end
        
        itemPart.CFrame = CFrame.new(hrp.Position + Vector3.new(0, 0, 2))
        task.wait(0.05)
        
        game:GetService("ReplicatedStorage").RemoteEvents.RequestStartDraggingItem:FireServer(item)
        task.wait(0.05)
        
        game:GetService("ReplicatedStorage").RemoteEvents.ReplicateSound:FireServer(
            "FireAllClients",
            "BagGet",
            {
                ["Instance"] = player.Character.Head,
                ["Volume"] = 0.25
            }
        )
        
        game:GetService("ReplicatedStorage").RemoteEvents.StopDraggingItem:FireServer(item)
        
        task.wait(collectDelay)
    end
end

Main:Toggle({
    Title = "自动扔选择的钢铁",
    Value = false,
    Callback = function(value)
        autoCollectAndDropLogs = value
        if value then
            fixPlayerPosition()
            spawn(function()
                while autoCollectAndDropLogs do
                    CollectAndDropLogs()
                    task.wait(0.1)
                end
            end)
        else
            local player = game:GetService("Players").LocalPlayer
            if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                player.Character.HumanoidRootPart.Anchored = false
            end
        end
    end
})

Main:Toggle({
    Title = "自动升级工作台",
    Value = false,
    Callback = function(value)
        autoCraftEnabled = value
        if value then
            spawn(function()
                while autoCraftEnabled do
                  
                    local craftingBenches = {
                        "Crafting Bench 2",
                        "Crafting Bench 3", 
                        "Crafting Bench 4",
                        "Crafting Bench 5",
                        "Crafting Bench 6",
                        "Crafting Bench 7",
                        "Crafting Bench 8"
                    }
                    
                 
                    for _, benchName in ipairs(craftingBenches) do
                        if not autoCraftEnabled then break end 
                        
                        local args = {
                            [1] = benchName
                        }
                        
                        pcall(function()
                            game:GetService("ReplicatedStorage").RemoteEvents.CraftItem:InvokeServer(unpack(args))
                        end)
                        
                        wait(0.1)
                    end
                    
                    wait(0) 
                end
            end)
        end
    end
})
Main:Section({Title = "自动制作"})

local autoCraftConfig = {
    itemName = "Shelf",  
    interval = 5,     
    craftOnce = false    
}
local autoCraftEnabled = false
local craftLoop = nil
Main:Input({
    Title = "制作物品名称",
    Desc = "输入要制作的物品名称",
    Value = autoCraftConfig.itemName,
    Placeholder = "例如: Shelf",
    Callback = function(input)
        autoCraftConfig.itemName = input
    end
})
Main:Input({
    Title = "制作间隔(秒)",
    Desc = "设置每次制作的间隔时间",
    Value = tostring(autoCraftConfig.interval),
    Placeholder = "例如: 5",
    Numeric = true,
    Callback = function(input)
        local num = tonumber(input)
        if num and num > 0 then
            autoCraftConfig.interval = num
        end
    end
})
Main:Button({
    Title = "制作一次",
    Callback = function()
        local args = {
            [1] = autoCraftConfig.itemName
        }
        
        pcall(function()
            game:GetService("ReplicatedStorage").RemoteEvents.CraftItem:InvokeServer(unpack(args))
            WindUI:Notify({
                Title = "制作完成",
                Content = "已制作: " .. autoCraftConfig.itemName,
                Duration = 3,
                Icon = "check-circle"
            })
        end)
    end
})
Main:Toggle({
    Title = "自动制作",
    Value = false,
    Callback = function(value)
        autoCraftEnabled = value
        if value then
            spawn(function()
                while autoCraftEnabled do
                    local args = {
                        [1] = autoCraftConfig.itemName
                    }
                    
                    pcall(function()
                        game:GetService("ReplicatedStorage").RemoteEvents.CraftItem:InvokeServer(unpack(args))
                    end)
                    
                
                    for i = 1, autoCraftConfig.interval * 10 do
                        if not autoCraftEnabled then break end
                        wait(0.1)
                    end
                end
            end)
            
            WindUI:Notify({
                Title = "自动制作已开启",
                Content = "正在自动制作: " .. autoCraftConfig.itemName,
                Duration = 3,
                Icon = "settings"
            })
        else
            WindUI:Notify({
                Title = "自动制作已关闭",
                Content = "停止制作: " .. autoCraftConfig.itemName,
                Duration = 3,
                Icon = "settings"
            })
        end
    end
})

local Main = Window:Tab({Title = "宝箱功能", Icon = "box"})
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

local chestSettings = {
    autoChestEnabled = false,
    autoChestNearEnabled = false,
    chestRange = 50,
    isRunning = false,
    originalCFrame = nil
}
local function getChests()
    local chests = {}
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("Model") and string.find(obj.Name, "Item Chest") then
            table.insert(chests, obj)
        end
    end
    return chests
end
local function getPrompt(model)
    local prompts = {}
    for _, obj in ipairs(model:GetDescendants()) do
        if obj:IsA("ProximityPrompt") then
            table.insert(prompts, obj)
        end
    end
    return prompts
end
Main:Toggle({
    Title = "自动开全部宝箱",
    Value = false,
    Callback = function(v)
        chestSettings.autoChestEnabled = v
        
        if v then
            if chestSettings.isRunning then return end
            chestSettings.isRunning = true
            
            local player = Players.LocalPlayer
            local character = player.Character or player.CharacterAdded:Wait()
            local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
            chestSettings.originalCFrame = humanoidRootPart.CFrame
            
            task.spawn(function()
                while chestSettings.autoChestEnabled and chestSettings.isRunning do
                    local chests = getChests()
                    for _, chest in ipairs(chests) do
                        if not chestSettings.autoChestEnabled then break end
                        local part = chest.PrimaryPart or chest:FindFirstChildWhichIsA("BasePart")
                        if part then
                            humanoidRootPart.CFrame = part.CFrame + Vector3.new(0, 6, 0)
                            local prompts = getPrompt(chest)
                            for _, prompt in ipairs(prompts) do
                                fireproximityprompt(prompt, math.huge)
                            end
                            local t = tick()
                            while chestSettings.autoChestEnabled and tick() - t < 4 do 
                                task.wait() 
                            end
                        end
                    end
                    task.wait(0.1)
                end
                
            
                if chestSettings.originalCFrame then
                    humanoidRootPart.CFrame = chestSettings.originalCFrame
                end
                chestSettings.isRunning = false
            end)
        else
            chestSettings.isRunning = false
        end
    end
})
Main:Toggle({
    Title = "宝箱光环",
    Value = false,
    Callback = function(v)
        chestSettings.autoChestNearEnabled = v
        
        if v then
            task.spawn(function()
                while chestSettings.autoChestNearEnabled do
                    local player = Players.LocalPlayer
                    local character = player.Character
                    if character and character:FindFirstChild("HumanoidRootPart") then
                        local humanoidRootPart = character.HumanoidRootPart
                        
                      
                        for _, obj in ipairs(workspace:GetDescendants()) do
                            if obj:IsA("Model") and string.find(obj.Name, "Item Chest") then
                                local part = obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")
                                if part then
                                    local dist = (humanoidRootPart.Position - part.Position).Magnitude
                                    if dist <= chestSettings.chestRange then
                                        for _, prompt in ipairs(obj:GetDescendants()) do
                                            if prompt:IsA("ProximityPrompt") then
                                                fireproximityprompt(prompt, math.huge)
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                    task.wait(0.5)
                end
            end)
        end
    end
})

Main:Slider({
    Title = "宝箱光环范围",
    Value = {
        Min = 1,
        Max = 100,
        Default = 50,
    },
    Callback = function(Value)
        chestSettings.chestRange = Value
    end
})
Main:Button({
    Title = "传送到最近宝箱",
    Callback = function()
        local player = Players.LocalPlayer
        local character = player.Character or player.CharacterAdded:Wait()
        local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

        local nearestChest, nearestDist, targetPart
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("Model") and string.find(obj.Name, "Item Chest") then
                local part = obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")
                if part then
                    local dist = (humanoidRootPart.Position - part.Position).Magnitude
                    if not nearestDist or dist < nearestDist then
                        nearestDist = dist
                        nearestChest = obj
                        targetPart = part
                    end
                end
            end
        end

        if targetPart then
            humanoidRootPart.CFrame = targetPart.CFrame + Vector3.new(0, targetPart.Size.Y/2 + 6, 0)
            WindUI:Notify({
                Title = "宝箱传送",
                Content = "已传送到最近宝箱",
                Duration = 3,
            })
        else
            WindUI:Notify({
                Title = "宝箱传送",
                Content = "未找到宝箱",
                Duration = 3,
            })
        end
    end
})

local Main = Window:Tab({Title = "火堆", Icon = "user"})


Main:Section({Title = "燃料类"})

local itemsMap = {
    ["木头"] = "Log",
    ["煤"] = "Coal",
    ["油桶"] = "Fuel Canister",
    ["椅子"] = "Chair",
    ["生物燃料"] = "Biofuel"
}

local dropPositions = {
    ["工作台"] = Vector3.new(21.67, 6.34, -4.05),
    
    ["火堆"] = Vector3.new(3.04, 11.70, 1.01)
}

local selectedItems = {}
local selectedDropPosition = dropPositions["工作台"] 

Main:Dropdown({
    Title = "选择要收集的物品（多选）",
    Values = {"木头", "煤", "油桶", "椅子", "生物燃料"},
    Value = {},
    Multi = true,
    Callback = function(options)
        selectedItems = {}
        for _, option in ipairs(options) do
            selectedItems[itemsMap[option]] = true
        end
    end
})


local autoCollectAndDropLogs = false
local collectDelay = 0.01

local positionOptions = {
    ["原地"] = nil, 
    ["工作台"] = Vector3.new(21.67, 6.34, -4.05),
    ["火堆"] = Vector3.new(1.4, 25.9, -0.9)
}

local selectedPosition = positionOptions["火堆"]

Main:Dropdown({
    Title = "选择位置",
    Values = {"原地","工作台","火堆"},
    Value = "火堆",
    Callback = function(option)
        selectedPosition = positionOptions[option]
    end
})

local function fixPlayerPosition()
    local player = game:GetService("Players").LocalPlayer
    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        local targetPosition
        if selectedPosition then
            targetPosition = selectedPosition
        else
     
            targetPosition = player.Character.HumanoidRootPart.Position + Vector3.new(0, 5, 0)
        end
        player.Character.HumanoidRootPart.CFrame = CFrame.new(targetPosition)
        player.Character.HumanoidRootPart.Anchored = true
    end
end

local function CollectAndDropLogs()
    if not autoCollectAndDropLogs then return end
    if not next(selectedItems) then return end 
    
    local player = game:GetService("Players").LocalPlayer
    if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then return end
    
    fixPlayerPosition()
    local hrp = player.Character.HumanoidRootPart
    
    local items = {}
    for _, item in pairs(workspace.Items:GetChildren()) do
        if selectedItems[item.Name] and item:IsA("Model") then
            table.insert(items, item)
        end
    end

    table.sort(items, function(a, b)
        local aPart = a.PrimaryPart or a:FindFirstChildWhichIsA("BasePart")
        local bPart = b.PrimaryPart or b:FindFirstChildWhichIsA("BasePart")
        if not aPart or not bPart then return false end
        return (hrp.Position - aPart.Position).Magnitude < (hrp.Position - bPart.Position).Magnitude
    end)

    for _, item in ipairs(items) do
        if not autoCollectAndDropLogs then break end
        
        local itemPart = item.PrimaryPart or item:FindFirstChildWhichIsA("BasePart")
        if not itemPart then continue end
        
        itemPart.CFrame = CFrame.new(hrp.Position + Vector3.new(0, 0, 2))
        task.wait(0.05)
        
        game:GetService("ReplicatedStorage").RemoteEvents.RequestStartDraggingItem:FireServer(item)
        task.wait(0.05)
        
        game:GetService("ReplicatedStorage").RemoteEvents.ReplicateSound:FireServer(
            "FireAllClients",
            "BagGet",
            {
                ["Instance"] = player.Character.Head,
                ["Volume"] = 0.25
            }
        )
        
        game:GetService("ReplicatedStorage").RemoteEvents.StopDraggingItem:FireServer(item)
        
        task.wait(collectDelay)
    end
end

Main:Toggle({
    Title = "自动扔选择的燃料",
    Value = false,
    Callback = function(value)
        autoCollectAndDropLogs = value
        if value then
            fixPlayerPosition()
            spawn(function()
                while autoCollectAndDropLogs do
                    CollectAndDropLogs()
                    task.wait(0.1)
                end
            end)
        else
            local player = game:GetService("Players").LocalPlayer
            if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                player.Character.HumanoidRootPart.Anchored = false
            end
        end
    end
})

Main:Button({
    Title = "传送回火旁",
    Callback = function()
        game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(-0.09672313928604126, 7.937822341918945, -0.1782056838274002)
    end
})

local Teleport = Window:Tab({Title = "传送功能", Icon = "user"})
local function getChests()
    local chests = {}
    local chestNames = {}
    local index = 1
    for _, item in ipairs(Workspace:WaitForChild("Items"):GetChildren()) do
        if item.Name:match("^Item Chest") and not item:GetAttribute("8721081708ed") then
            table.insert(chests, item)
            table.insert(chestNames, "Chest " .. index)
            index = index + 1
        end
    end
    return chests, chestNames
end

local function getMobs()
    local mobs = {}
    local mobNames = {}
    local index = 1
    for _, character in ipairs(Workspace:WaitForChild("Characters"):GetChildren()) do
        if character.Name:match("^Lost Child") and character:GetAttribute("Lost") == true then
            table.insert(mobs, character)
            table.insert(mobNames, character.Name)
            index = index + 1
        end
    end
    return mobs, mobNames
end
local currentChests, currentChestNames = getChests()
local selectedChest = currentChestNames[1] or nil

local currentMobs, currentMobNames = getMobs()
local selectedMob = currentMobNames[1] or nil

Teleport:Section({ Title = "基础传送点", Icon = "map-pin" })

Teleport:Button({
    Title = "传送到营火",
    Callback = function()
        local function tp1()
            (LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()):WaitForChild("HumanoidRootPart").CFrame =
            CFrame.new(0.43132782, 15.77634621, -1.88620758, -0.270917892, 0.102997094, 0.957076371, 0.639657021, 0.762253821, 0.0990355015, -0.719334781, 0.639031112, -0.272391081)
        end
        tp1()
    end
})

Teleport:Button({
    Title = "传送到要塞",
    Callback = function()
        local function tp2()
            local targetPart = Workspace:FindFirstChild("Map")
                and Workspace.Map:FindFirstChild("Landmarks")
                and Workspace.Map.Landmarks:FindFirstChild("Stronghold")
                and Workspace.Map.Landmarks.Stronghold:FindFirstChild("Functional")
                and Workspace.Map.Landmarks.Stronghold.Functional:FindFirstChild("EntryDoors")
                and Workspace.Map.Landmarks.Stronghold.Functional.EntryDoors:FindFirstChild("DoorRight")
                and Workspace.Map.Landmarks.Stronghold.Functional.EntryDoors.DoorRight:FindFirstChild("Model")
            if targetPart then
                local children = targetPart:GetChildren()
                local destination = children[5]
                if destination and destination:IsA("BasePart") then
                    local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                    if hrp then
                        hrp.CFrame = destination.CFrame + Vector3.new(0, 5, 0)
                    end
                end
            end
        end
        tp2()
    end
})

Teleport:Button({
    Title = "传送到安全区",
    Callback = function()
        if not Workspace:FindFirstChild("SafeZonePart") then
            local createpart = Instance.new("Part")
            createpart.Name = "SafeZonePart"
            createpart.Size = Vector3.new(30, 3, 30)
            createpart.Position = Vector3.new(0, 350, 0)
            createpart.Anchored = true
            createpart.CanCollide = true
            createpart.Transparency = 0.8
            createpart.Color = Color3.fromRGB(255, 0, 0)
            createpart.Parent = Workspace
        end
        local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
        local hrp = character:WaitForChild("HumanoidRootPart")
        hrp.CFrame = CFrame.new(0, 360, 0)
    end
})

Teleport:Button({
    Title = "传送到商人",
    Callback = function()
        local pos = Vector3.new(-37.08, 3.98, -16.33)
        local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
        local hrp = character:WaitForChild("HumanoidRootPart")
        hrp.CFrame = CFrame.new(pos)
    end
})

Teleport:Button({
    Title = "传送到随机树",
    Callback = function()
        local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
        local hrp = character:FindFirstChild("HumanoidRootPart", 3)
        if not hrp then return end

        local map = Workspace:FindFirstChild("Map")
        if not map then return end

        local foliage = map:FindFirstChild("Foliage") or map:FindFirstChild("Landmarks")
        if not foliage then return end

        local trees = {}
        for _, obj in ipairs(foliage:GetChildren()) do
            if obj.Name == "Small Tree" and obj:IsA("Model") then
                local trunk = obj:FindFirstChild("Trunk") or obj.PrimaryPart
                if trunk then
                    table.insert(trees, trunk)
                end
            end
        end

        if #trees > 0 then
            local trunk = trees[math.random(1, #trees)]
            local treeCFrame = trunk.CFrame
            local rightVector = treeCFrame.RightVector
            local targetPosition = treeCFrame.Position + rightVector * 3
            hrp.CFrame = CFrame.new(targetPosition)
        end
    end
})

Teleport:Section({ Title = "宝箱传送", Icon = "box" })

local ChestDropdown = Teleport:Dropdown({
    Title = "选择宝箱",
    Values = currentChestNames,
    Multi = false,
    AllowNone = true,
    Callback = function(options)
        selectedChest = options[#options] or currentChestNames[1] or nil
    end
})

Teleport:Button({
    Title = "刷新宝箱列表",
    Locked = false,
    Callback = function()
        currentChests, currentChestNames = getChests()
        if #currentChestNames > 0 then
            selectedChest = currentChestNames[1]
            ChestDropdown:Refresh(currentChestNames)
            WindUI:Notify({
                Title = "宝箱列表已刷新",
                Content = "找到 " .. #currentChestNames .. " 个宝箱",
                Duration = 3,
                Icon = "refresh-cw"
            })
        else
            selectedChest = nil
            ChestDropdown:Refresh({ "未找到宝箱" })
            WindUI:Notify({
                Title = "未找到宝箱",
                Content = "地图上没有发现宝箱",
                Duration = 3,
                Icon = "box"
            })
        end
    end
})

Teleport:Button({
    Title = "传送到宝箱",
    Locked = false,
    Callback = function()
        if selectedChest and currentChests then
            local chestIndex = 1
            for i, name in ipairs(currentChestNames) do
                if name == selectedChest then
                    chestIndex = i
                    break
                end
            end
            local targetChest = currentChests[chestIndex]
            if targetChest then
                local part = targetChest.PrimaryPart or targetChest:FindFirstChildWhichIsA("BasePart")
                if part and LocalPlayer.Character then
                    local hrp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                    if hrp then
                        hrp.CFrame = part.CFrame + Vector3.new(0, 5, 0)
                        WindUI:Notify({
                            Title = "传送成功",
                            Content = "已传送到 " .. selectedChest,
                            Duration = 3,
                            Icon = "check-circle"
                        })
                    end
                end
            end
        else
            WindUI:Notify({
                Title = "传送失败",
                Content = "请先选择一个宝箱",
                Duration = 3,
                Icon = "alert-circle"
            })
        end
    end
})

Teleport:Section({ Title = "儿童传送", Icon = "user" })

local MobDropdown = Teleport:Dropdown({
    Title = "选择儿童",
    Values = currentMobNames,
    Multi = false,
    AllowNone = true,
    Callback = function(options)
        selectedMob = options[#options] or currentMobNames[1] or nil
    end
})

Teleport:Button({
    Title = "刷新儿童列表",
    Locked = false,
    Callback = function()
        currentMobs, currentMobNames = getMobs()
        if #currentMobNames > 0 then
            selectedMob = currentMobNames[1]
            MobDropdown:Refresh(currentMobNames)
            WindUI:Notify({
                Title = "儿童列表已刷新",
                Content = "找到 " .. #currentMobNames .. " 个迷失儿童",
                Duration = 3,
                Icon = "refresh-cw"
            })
        else
            selectedMob = nil
            MobDropdown:Refresh({ "未找到迷失儿童" })
            WindUI:Notify({
                Title = "未找到迷失儿童",
                Content = "地图上没有发现迷失儿童",
                Duration = 3,
                Icon = "user"
            })
        end
    end
})

Teleport:Button({
    Title = "传送到儿童",
    Locked = false,
    Callback = function()
        if selectedMob and currentMobs then
            for i, name in ipairs(currentMobNames) do
                if name == selectedMob then
                    local targetMob = currentMobs[i]
                    if targetMob then
                        local part = targetMob.PrimaryPart or targetMob:FindFirstChildWhichIsA("BasePart")
                        if part and LocalPlayer.Character then
                            local hrp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                            if hrp then
                                hrp.CFrame = part.CFrame + Vector3.new(0, 5, 0)
                                WindUI:Notify({
                                    Title = "传送成功",
                                    Content = "已传送到 " .. selectedMob,
                                    Duration = 3,
                                    Icon = "check-circle"
                                })
                            end
                        end
                    end
                    break
                end
            end
        else
            WindUI:Notify({
                Title = "传送失败",
                Content = "请先选择一个迷失儿童",
                Duration = 3,
                Icon = "alert-circle"
            })
        end
    end
})

local AutoSection = Window:Tab({Title = "带来", Icon = "user"})

AutoSection:Toggle({
    Title = "自动传送物品",
    Default = false,
    Callback = function(Value)
        autoBringItems = Value
        task.spawn(function()
            while autoBringItems and task.wait() do
                local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                if not root then continue end
                for _, item in ipairs(workspace.Items:GetChildren()) do
                    local part = item:FindFirstChildWhichIsA("BasePart") or (item:IsA("BasePart") and item)
                    if part then
                        part.CFrame = root.CFrame + Vector3.new(math.random(-44,44), 0, math.random(-44,44))
                    end
                end
            end
        end)
    end
})

AutoSection:Toggle({
    Title = "自动传送木头",
    Default = false,
    Callback = function(Value)
        autoBringLogs = Value
        task.spawn(function()
            while autoBringLogs and task.wait() do
                local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                if not root then continue end
                
                for _, item in pairs(workspace.Items:GetChildren()) do
                    if item.Name:lower():find("log") and item:IsA("Model") then
                        local main = item:FindFirstChildWhichIsA("BasePart")
                        if main then
                            main.CFrame = root.CFrame * CFrame.new(math.random(-5,5), 0, math.random(-5,5))
                        end
                    end
                end
            end
        end)
    end
})

AutoSection:Toggle({
    Title = "自动传送燃料罐",
    Default = false,
    Callback = function(Value)
        autoBringFuel = Value
        task.spawn(function()
            while autoBringFuel and task.wait() do
                local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                if not root then continue end
                
                for _, item in pairs(workspace.Items:GetChildren()) do
                    if item.Name:lower():find("fuel canister") and item:IsA("Model") then
                        local main = item:FindFirstChildWhichIsA("BasePart")
                        if main then
                            main.CFrame = root.CFrame * CFrame.new(math.random(-5,5), 0, math.random(-5,5))
                        end
                    end
                end
            end
        end)
    end
})

AutoSection:Toggle({
    Title = "自动传送油桶",
    Default = false,
    Callback = function(Value)
        autoBringOil = Value
        task.spawn(function()
            while autoBringOil and task.wait() do
                local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                if not root then continue end
                
                for _, item in pairs(workspace.Items:GetChildren()) do
                    if item.Name:lower():find("oil barrel") and item:IsA("Model") then
                        local main = item:FindFirstChildWhichIsA("BasePart")
                        if main then
                            main.CFrame = root.CFrame * CFrame.new(math.random(-5,5), 0, math.random(-5,5))
                        end
                    end
                end
            end
        end)
    end
})

AutoSection:Toggle({
    Title = "自动传送所有废料",
    Default = false,
    Callback = function(Value)
        autoBringScrap = Value
        task.spawn(function()
            while autoBringScrap and task.wait() do
                local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                if not root then continue end
                
                local scrapNames = {
                    ["tyre"] = true, 
                    ["sheet metal"] = true, 
                    ["broken fan"] = true, 
                    ["bolt"] = true, 
                    ["old radio"] = true, 
                    ["ufo junk"] = true, 
                    ["ufo scrap"] = true, 
                    ["broken microwave"] = true
                }
                
                for _, item in pairs(workspace.Items:GetChildren()) do
                    if item:IsA("Model") then
                        local itemName = item.Name:lower()
                        for scrapName, _ in pairs(scrapNames) do
                            if itemName:find(scrapName) then
                                local main = item:FindFirstChildWhichIsA("BasePart")
                                if main then
                                    main.CFrame = root.CFrame * CFrame.new(math.random(-5,5), 0, math.random(-5,5))
                                end
                                break
                            end
                        end
                    end
                end
            end
        end)
    end
})

AutoSection:Toggle({
    Title = "自动传送煤炭",
    Default = false,
    Callback = function(Value)
        autoBringCoal = Value
        task.spawn(function()
            while autoBringCoal and task.wait() do
                local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                if not root then continue end
                
                for _, item in pairs(workspace.Items:GetChildren()) do
                    if item.Name:lower():find("coal") and item:IsA("Model") then
                        local main = item:FindFirstChildWhichIsA("BasePart")
                        if main then
                            main.CFrame = root.CFrame * CFrame.new(math.random(-5,5), 0, math.random(-5,5))
                        end
                    end
                end
            end
        end)
    end
})

AutoSection:Toggle({
    Title = "自动传送肉类",
    Default = false,
    Callback = function(Value)
        autoBringMeat = Value
        task.spawn(function()
            while autoBringMeat and task.wait() do
                local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                if not root then continue end
                
                for _, item in pairs(workspace.Items:GetChildren()) do
                    local name = item.Name:lower()
                    if (name:find("meat") or name:find("cooked")) and item:IsA("Model") then
                        local main = item:FindFirstChildWhichIsA("BasePart")
                        if main then
                            main.CFrame = root.CFrame * CFrame.new(math.random(-5,5), 0, math.random(-5,5))
                        end
                    end
                end
            end
        end)
    end
})

local Main = Window:Tab({Title = "收集", Icon = "user"})
local itemMaps = {
    ["燃料类物品"] = {
        ["木头"] = "Log",
        ["煤"] = "Coal",
        ["油桶"] = "Fuel Canister",
        ["椅子"] = "Chair",
        ["生物燃料"] = "Biofuel"
    },
    ["钢铁类物品"] = {
        ["螺栓"] = "Bolt",
        ["破风扇"] = "Broken Fan",
        ["坏微波炉"] = "Broken Microwave",
        ["旧收音机"] = "Old Radio",
        ["洗衣机"] = "Washing Machine",
        ["旧汽车引擎"] = "Old Car Engine",
        ["轮胎"] = "Tire",
        ["金属板"] = "Sheet Metal"
    },
    ["食物类物品"] = {
        ["蛋糕"] = "Cake",
        ["牛排"] = "Steak",
        ["肉丁"] = "Morsel",
        ["胡萝卜"] = "Carrot",
        ["苹果"] = "Apple",
        ["浆果"] = "Berry",
        ["辣椒"] = "Chili",
        ["玉米"] = "Corn",
        ["南瓜"] = "Pumpkin"
    },
    ["回血类物品"] = {
        ["绷带"] = "Bandage",
        ["医疗包"] = "Medkit"
    },
    ["武器与装备"] = {
        ["步枪"] = "Rifle",
        ["皮革背心"] = "Leather Body",
        ["左轮弹药"] = "Revolver Ammo",
        ["左轮手枪"] = "Revolver",
        ["步枪弹药"] = "Rifle Ammo",
        ["好的背包"] = "Good Sack",
        ["巨袋"] = "Large Bag",
        ["强力斧头"] = "Strong Axe",
        ["锯齿"] = "Saw Blade",
        ["好的斧头"] = "Good Axe",
        ["长矛"] = "Spear",
        ["强力手电筒"] = "Strong Flashlight",
        ["弓弩"] = "Crossbow",
        ["老鱼杆"] = "Old Rod"
    },
    ["动物与特殊物品"] = {
        ["黄鼠狼皮"] = "Arctic Fox Pelt",
        ["教徒尸体"] = "Cultist",
        ["弓弩教徒尸体"] = "Crossbow Cultist",
        ["教徒宝石"] = "Cultist Gem",
        ["狼尸体"] = "Wolf Corpse",
        ["狼皮"] = "Bunny Foot"
    }
}

local selectedItems = {}
local autoCollect = false
local collectDelay = 0.005  

local function fixPlayerPosition()
    local player = game:GetService("Players").LocalPlayer
    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        local targetPosition = player.Character.HumanoidRootPart.Position + Vector3.new(0, 5, 0)
        player.Character.HumanoidRootPart.CFrame = CFrame.new(targetPosition)
        player.Character.HumanoidRootPart.Anchored = true
    end
end

local function CollectItems()
    if not autoCollect then return end
    if not next(selectedItems) then return end
    
    local player = game:GetService("Players").LocalPlayer
    if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then return end
    
    fixPlayerPosition()
    local hrp = player.Character.HumanoidRootPart
    
    local allItems = {}
    for _, item in pairs(workspace.Items:GetChildren()) do
        if selectedItems[item.Name] and item:IsA("Model") then
            table.insert(allItems, item)
        end
    end

    table.sort(allItems, function(a, b)
        local aPart = a.PrimaryPart or a:FindFirstChildWhichIsA("BasePart")
        local bPart = b.PrimaryPart or b:FindFirstChildWhichIsA("BasePart")
        if not aPart or not bPart then return false end
        return (hrp.Position - aPart.Position).Magnitude < (hrp.Position - bPart.Position).Magnitude
    end)

    for _, item in ipairs(allItems) do
        if not autoCollect then break end
        
        local itemPart = item.PrimaryPart or item:FindFirstChildWhichIsA("BasePart")
        if not itemPart then continue end
        
        itemPart.CFrame = CFrame.new(hrp.Position + Vector3.new(0, 0, 2))
        task.wait(0.02)  
        
        game:GetService("ReplicatedStorage").RemoteEvents.RequestStartDraggingItem:FireServer(item)
        task.wait(0.02)  
        
        game:GetService("ReplicatedStorage").RemoteEvents.ReplicateSound:FireServer(
            "FireAllClients",
            "BagGet",
            {
                ["Instance"] = player.Character.Head,
                ["Volume"] = 0.25
            }
        )
        
        game:GetService("ReplicatedStorage").RemoteEvents.StopDraggingItem:FireServer(item)
        task.wait(collectDelay)
    end
end

local allItemValues = {}
local allItemMap = {}

for category, items in pairs(itemMaps) do
    for name, id in pairs(items) do
        table.insert(allItemValues, name)
        allItemMap[name] = id
    end
end

Main:Dropdown({
    Title = "选择要收集的物品（多选）",
    Values = allItemValues,
    Value = {},
    Multi = true,
    Callback = function(options)
        selectedItems = {}
        for _, option in ipairs(options) do
            selectedItems[allItemMap[option]] = true
        end
    end
})

Main:Toggle({
    Title = "自动收集选择的物品",
    Value = false,
    Callback = function(value)
        autoCollect = value
        if value then
            fixPlayerPosition()
            spawn(function()
                while autoCollect do
                    CollectItems()
                    task.wait(0.05)  
                end
            end)
        else
            local player = game:GetService("Players").LocalPlayer
            if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                player.Character.HumanoidRootPart.Anchored = false
            end
        end
    end
})


local Main = Window:Tab({Title = "玩家功能", Icon = "user"})
Main:Toggle({
    Title = "速度 (开/关)",
    Default = false,
    Callback = function(v)
        if v == true then
            sudu = game:GetService("RunService").Heartbeat:Connect(function()
                if game:GetService("Players").LocalPlayer.Character and game:GetService("Players").LocalPlayer.Character.Humanoid and game:GetService("Players").LocalPlayer.Character.Humanoid.Parent then
                    if game:GetService("Players").LocalPlayer.Character.Humanoid.MoveDirection.Magnitude > 0 then
                        game:GetService("Players").LocalPlayer.Character:TranslateBy(game:GetService("Players").LocalPlayer.Character.Humanoid.MoveDirection * Speed / 10)
                    end
                end
            end)
        elseif not v and sudu then
            sudu:Disconnect()
            sudu = nil
        end
    end
})

Main:Slider({
    Title = "速度设置",
    Desc = "滑动调整",
    Value = {
        Min = 1,
        Max = 150,
        Default = 1,
    },
    Callback = function(Value)
        Speed = Value
    end
})

Main:Toggle({
    Title = "隐身",
    Default = false,
    Callback = function(Value)
        if invisThread then
            task.cancel(invisThread)
            invisThread = nil
        end

        if Value then
            invisThread = task.spawn(function()
                local Player = game:GetService("Players").LocalPlayer
                RealCharacter = Player.Character or Player.CharacterAdded:Wait()
                RealCharacter.Archivable = true
                FakeCharacter = RealCharacter:Clone()
                Part = Instance.new("Part")
                Part.Anchored = true
                Part.Size = Vector3.new(200, 1, 200)
                Part.CFrame = CFrame.new(0, -500, 0)
                Part.CanCollide = true
                Part.Parent = workspace
                FakeCharacter.Parent = workspace
                FakeCharacter.HumanoidRootPart.CFrame = Part.CFrame * CFrame.new(0, 5, 0)

                for _, v in pairs(RealCharacter:GetChildren()) do
                    if v:IsA("LocalScript") then
                        local clone = v:Clone()
                        clone.Disabled = true
                        clone.Parent = FakeCharacter
                    end
                end

                for _, v in pairs(FakeCharacter:GetDescendants()) do
                    if v:IsA("BasePart") then
                        v.Transparency = 0.7
                    end
                end

                local function EnableInvisibility()
                    StoredCF = RealCharacter.HumanoidRootPart.CFrame
                    RealCharacter.HumanoidRootPart.CFrame = FakeCharacter.HumanoidRootPart.CFrame
                    FakeCharacter.HumanoidRootPart.CFrame = StoredCF
                    RealCharacter.Humanoid:UnequipTools()
                    Player.Character = FakeCharacter
                    workspace.CurrentCamera.CameraSubject = FakeCharacter.Humanoid
                    RealCharacter.HumanoidRootPart.Anchored = true

                    for _, v in pairs(FakeCharacter:GetChildren()) do
                        if v:IsA("LocalScript") then
                            v.Disabled = false
                        end
                    end
                end

                RealCharacter.Humanoid.Died:Connect(function()
                    if Part then Part:Destroy() end
                    if FakeCharacter then FakeCharacter:Destroy() end
                    Player.Character = RealCharacter
                end)

                EnableInvisibility()

                game:GetService("RunService").RenderStepped:Connect(function()
                    if RealCharacter and RealCharacter:FindFirstChild("HumanoidRootPart") and Part then
                        RealCharacter.HumanoidRootPart.CFrame = Part.CFrame * CFrame.new(0, 5, 0)
                    end
                end)
            end)
        else
            if Part then Part:Destroy() Part = nil end
            if FakeCharacter then FakeCharacter:Destroy() FakeCharacter = nil end
            if RealCharacter then
                RealCharacter.HumanoidRootPart.Anchored = false
                RealCharacter.HumanoidRootPart.CFrame = StoredCF
                game:GetService("Players").LocalPlayer.Character = RealCharacter
                workspace.CurrentCamera.CameraSubject = RealCharacter.Humanoid
            end
        end
    end
})

Main:Toggle({
    Title = "秒互动",
    Value = false,
    Callback = function(value)
        autohlod = value
        if autohlod then
            local function modifyPrompt(prompt)
                prompt.HoldDuration = 0 
            end 
            
            local function isTargetPrompt(prompt)
                local parent = prompt.Parent 
                while parent do 
                    if parent == workspace or parent == workspace.BankRobbery.VaultDoor then 
                        return true 
                    end 
                    parent = parent.Parent 
                end 
                return false 
            end 
            
            for _, prompt in ipairs(workspace:GetDescendants()) do
                if prompt:IsA("ProximityPrompt") and isTargetPrompt(prompt) then
                    modifyPrompt(prompt)
                end
            end 
            
            workspace.DescendantAdded:Connect(function(instance)
                if instance:IsA("ProximityPrompt") and isTargetPrompt(instance) then
                    modifyPrompt(instance)
                end
            end)
        end
    end
})

Main:Toggle({
    Title = "无限跳",
    Default = false,
    Callback = function(Value)
        local jumpConn
        if Value then
            jumpConn = game:GetService("UserInputService").JumpRequest:Connect(function()
                local humanoid = game:GetService("Players").LocalPlayer.Character and
                                 game:GetService("Players").LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
                if humanoid then
                    humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                end
            end)
        else
            if jumpConn then
                jumpConn:Disconnect()
                jumpConn = nil
            end
        end
    end
})
WindUI:Notify({
                        Title = "大司马",
                        Content = "为你自动切换英文，自己调整",
                        Duration = 3,
                        Icon = "alert-circle"
                    })
                    
                    WindUI:Notify({
                        Title = "大司马脚本",
                        Content = "为你自动切换英文，自己调整",
                        Duration = 3,
                        Icon = "alert-circle"
                    })
                    
                    WindUI:Notify({
                        Title = "小云",
                        Content = "为你自动切换英文，自己调整",
                        Duration = 3,
                        Icon = "alert-circle"
                    })
                    
                    WindUI:Notify({
                        Title = "猫王",
                        Content = "为你自动切换英文，自己调整",
                        Duration = 3,
                        Icon = "alert-circle"
                    })
                    
                    WindUI:Notify({
                        Title = "云脚本",
                        Content = "为你自动切换英文，自己调整",
                        Duration = 3,
                        Icon = "alert-circle"
                    })
end
WindUI:Notify({
                        Title = "猫脚本",
                        Content = "为你自动切换英文，自己调整",
                        Duration = 3,
                        Icon = "alert-circle"
                    })

      end
})
Section:Button({
    Title = "TY 脚本自然灾害",
    Callback = function()
    
local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()
local Window = WindUI:CreateWindow({
        Title = "TY脚本-自然灾害<font color='#00FF00'>V2</font>",
        Icon = "rbxassetid://4483362748",
        IconTransparency = 0.5,
        IconThemed = true,
        Author = "作者:小夜",
        Folder = "CloudHub",
        Size = UDim2.fromOffset(400, 300),
        Transparent = true,
        Theme = "Light",
        User = {
            Enabled = true,
            Callback = function() print("clicked") end,
            Anonymous = false
        },
        SideBarWidth = 200,
        ScrollBarEnabled = true,
        Background = "rbxassetid://111122821357551"
    })
    

WindUI:Popup({
    Title = "欢迎使用",
    Icon = "info",
    Content = "欢迎用户使用TY脚本-自然灾害",
    Buttons = {
        {
            Title = "取消",
            Callback = function() end,
            Variant = "Tertiary",
        },
        {
            Title = "确定",
            Icon = "arrow-right",
            Callback = function() end,
            Variant = "Primary",
        }
    }
})

Window:EditOpenButton({
    Title = "TY脚本",
    Icon = "monitor",
    CornerRadius = UDim.new(0,16),
    StrokeThickness = 4,
    Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromHex("FF0000")),
        ColorSequenceKeypoint.new(0.16, Color3.fromHex("FF7F00")),
        ColorSequenceKeypoint.new(0.33, Color3.fromHex("FFFF00")),
        ColorSequenceKeypoint.new(0.5, Color3.fromHex("00FF00")),
        ColorSequenceKeypoint.new(0.66, Color3.fromHex("0000FF")),
        ColorSequenceKeypoint.new(0.83, Color3.fromHex("4B0082")),
        ColorSequenceKeypoint.new(1, Color3.fromHex("9400D3"))
    }),
    Draggable = true,
})
            
Window:Tag({
    Title = "TY脚本",
    Color = Color3.fromHex("#30ff6a")
})

Window:Tag({
        Title = "TY脚本", -- 标签汉化
        Color = Color3.fromHex("#315dff")
    })
    local TimeTag = Window:Tag({
        Title = "自然灾害",
        Color = Color3.fromHex("#000000")
    })

local Tabs = {
    Main = Window:Section({ Title = "TY脚本自然灾害", Opened = true }),
}

local TabHandles = {
    Q = Tabs.Main:Tab({ Title = "功能", Icon = "layout-grid" }),
}

Button = TabHandles.Q:Button({
    Title = "指南针（可以用下面的地方显示不了地图）",
    Desc = "要使用的话就必须买指南针",
    Locked = false,
    Callback = function()
    
local p = game.Players.LocalPlayer
local r, c, h = game.ReplicatedStorage.Remotes.Compass, p.Backpack:WaitForChild("Compass"), p.Character:WaitForChild("Humanoid")
h:EquipTool(c)
task.wait()
r:FireServer("Vote Map", 3)
r:FireServer("Vote Map", 4)
task.wait()
h:UnequipTools()
            
WindUI:Notify({
    Title = "通知",
    Content = "加载成功",
    Duration = 1, -- 3 seconds
    Icon = "layout-grid",
})                        
            
 end
})

Button = TabHandles.Q:Button({
    Title = "黑洞",
    Desc = "点击加载",
    Locked = false,
    Callback = function()
        loadstring(game:HttpGet("https://rawscripts.net/raw/Universal-Script-Super-ring-Parts-V6-28581"))()
        
WindUI:Notify({
    Title = "通知",
    Content = "加载成功",
    Duration = 3, -- 3 seconds
    Icon = "layout-grid",
})        
        
    end
})

Button = TabHandles.Q:Button({
    Title = "物理磁铁",
    Desc = "可以把下面的东西吸上来可以踩",
    Locked = false,
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/cytj777i/6669178/main/%E5%8D%95%E4%B8%80%E7%89%A9%E4%BD%93%E9%A3%9E%E8%A1%8C%E8%BD%BD%E8%87%AA%E5%B7%B1%E6%9C%80%E7%BB%88%E4%BC%98%E5%8C%96%E7%89%88"))()       
        
WindUI:Notify({
    Title = "通知",
    Content = "加载成功",
    Duration = 1, -- 3 seconds
    Icon = "layout-grid",
})                                
    end
})

Button = TabHandles.Q:Button({
    Title = "无敌少侠",
    Desc = "用了它，你就会变成城市超人",
    Locked = false,
    Callback = function()
loadstring(game:HttpGet("https://rawscripts.net/raw/Universal-Script-Invinicible-Flight-R15-45414"))()
WindUI:Notify({
    Title = "通知",
    Content = "加载成功",
    Duration = 1, -- 3 seconds
    Icon = "layout-grid",
})                        
            
 end
})

Button = TabHandles.Q:Button({
    Title = "防止摔跤伤害",
    Desc = "就算掉下去了，也毫发无伤，掉到水里面也会死的",
    Locked = false,
    Callback = function()
loadstring(game:HttpGet("https://raw.githubusercontent.com/cytj777i/Fall-injury/main/防止摔落伤害"))()
            
WindUI:Notify({
    Title = "通知",
    Content = "加载成功",
    Duration = 1, -- 3 seconds
    Icon = "layout-grid",
})                        
            
 end
})

      end
})
Section:Button({
    Title = "TY脚本-超市里生存",
    Callback = function()
    
local library = loadstring(game:HttpGet("https://raw.githubusercontent.com/Zephyr688/Lua-Script/refs/heads/main/UI"))()

local window = library:new("TY HUB｜在超市生活一周")

local Page = window:Tab("主要功能",'16060333448')

local Section = Page:section("功能",true)

Section:Toggle("自动收集食物", "", false, function(state)
    while state and task.wait() do
        for _,v in next,workspace.Map.Util.Items:GetChildren() do
            if v.ToolStats.ItemType.Value == "Food" then
                game:GetService("ReplicatedStorage").Remotes.RequestPickupItem:FireServer(v)
            end
        end
    end
end)

Section:Toggle("自动收集手电筒", "", false, function(state)
    while state and task.wait() do
        for _,v in next,workspace.Map.Util.Items:GetChildren() do
            if v.ToolStats.ItemType.Value == "Flashlight" then
                game:GetService("ReplicatedStorage").Remotes.RequestPickupItem:FireServer(v)
            end
        end
    end
end)

Section:Toggle("自动收集近战武器", "", false, function(state)
    while state and task.wait() do
        for _,v in next,workspace.Map.Util.Items:GetChildren() do
            if v.ToolStats.ItemType.Value == "Melee" then
                game:GetService("ReplicatedStorage").Remotes.RequestPickupItem:FireServer(v)
            end
        end
    end
end)
Section:Toggle("自动收集枪", "", false, function(state)
    while state and task.wait() do
        for _,v in next,workspace.Map.Util.Items:GetChildren() do
            if v.ToolStats.ItemType.Value == "Gun" then
                game:GetService("ReplicatedStorage").Remotes.RequestPickupItem:FireServer(v)
            end
        end
    end
end)

Section:Toggle("自动收集药品", "", false, function(state)
    while state and task.wait() do
        for _,v in next,workspace.Map.Util.Items:GetChildren() do
            if v.ToolStats.ItemType.Value == "Health" then
                game:GetService("ReplicatedStorage").Remotes.RequestPickupItem:FireServer(v)
            end
        end
    end
end)

Section:Toggle("自动装弹", "", false, function(state)
    while state and task.wait() do
        game:GetService("ReplicatedStorage").Remotes.Weapon.GunReloaded:FireServer(v, 1)
    end
end)

Section:Toggle("自动开枪", "", false, function(state)
    while state and task.wait() do
        for _, v in next, game.Players.LocalPlayer.Backpack:GetChildren() do
            if v:FindFirstChild("ToolStats") and v.ToolStats:FindFirstChild("Ammo") then
                for _,e in next,workspace.Enemies:GetChildren() do
                    if e.Humanoid.Health > 0 then
                        local BulletsPerShot = v.ToolStats.BulletsPerShot.Value
                        local DirectionTbl = {}
                        for i = 1, BulletsPerShot do
                            table.insert(DirectionTbl, Vector3.new(e.Head.Position.X, e.Head.Position.Y, e.Head.Position.Z).Unit)
                        end
                        local args = {
                            [1] = {
                                ["FiringPlayer"] = game:GetService("Players").LocalPlayer,
                                ["FiredTime"] = os.time,
                                ["FiringPlayerUserId"] = game.Players.LocalPlayer.UserId,
                                ["Origin"] = Vector3.new(game.Players.LocalPlayer.Character:GetPivot().Position),
                                ["UID"] = game.Players.LocalPlayer.UserId .. "_1",
                                ["WeaponInstance"] = v,
                                ["ThisBulletProperties"] = {
                                    ["BulletSpread"] = v.ToolStats.BulletSpread.Value,
                                    ["BulletsPerShot"] = v.ToolStats.BulletsPerShot.Value,
                                    ["BulletPenetration"] = v.ToolStats.BulletPenetration.Value,
                                    ["BulletSpeed"] = v.ToolStats.BulletSpeed.Value,
                                    ["FireSound"] = v.ToolStats.FireSound.Value,
                                    ["BulletSize"] = v.ToolStats.BulletSize.Value
                                },
                                ["DirectionTbl"] = DirectionTbl
                            }
                        }
                        game:GetService("ReplicatedStorage").Remotes.Weapon.GunFired:FireServer(unpack(args))
                    end
                end
            end
        end
    end
end)

Section:Toggle("修改超级枪", "", false, function(state)
    while state and task.wait() do
        for _,v in next,game.Players.Backpack:GetChildren() do
            if v.ToolStats:FindFirstChild("Ammo") then
                v.ToolStats.ReloadTime.Value = 0
                v.ToolStats.FireDelay.Value = 0
                v.ToolStats.Ammo.Value = math.huge
                v.ToolStats.Damage.Value = math.huge
            end
        end
    end
end)
Section:Toggle("无限体力和饥饿度", "", false, function(state)
    while state and task.wait() do
        game.Players.LocalPlayer.Character.CharacterData.MaxStamina.Value = math.huge
        game.Players.LocalPlayer.Character.CharacterData.MaxEnergy.Value = math.huge
        game.Players.LocalPlayer.Character.CharacterData.Energy.Value = game.Players.LocalPlayer.Character.CharacterData.MaxEnergy.Value
        game.Players.LocalPlayer.Character.CharacterData.Stamina.Value = game.Players.LocalPlayer.Character.CharacterData.MaxStamina.Value
    end
end)

Section:Toggle("夜晚自动躲避", "", false, function(state)
    while state and task.wait() do
        if game:GetService("ReplicatedStorage").GameInfo.TimeOfDay.Value == "Night" then
        oldpos = game.Players.LocalPlayer.Character:GetPivot().Position
        repeat task.wait()
        game.Players.LocalPlayer.Character:PivotTo(CFrame.new(306.18927001953125, 36.67450714111328, -519.2435913085938))
        game.Players.LocalPlayer.Character.HumanoidRootPart.Anchored = true
        until game:GetService("ReplicatedStorage").GameInfo.TimeOfDay.Value ~= "Night"
        game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = oldpos
        else
            task.wait()
        end
    end
end)
      end
})
Section:Button({
    Title = "TY HUB-请捐赠",
    Callback = function()
    
local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()local Confirmed = false

WindUI:Popup({
    Title = "TY HUB-请捐赠",
    IconThemed = true,
    Content = "欢迎尊贵的用户" .. game.Players.LocalPlayer.Name .. "TY HUB 当前版本型号:V2",
    Buttons = {
        {
            Title = "取消",
            Callback = function() end,
            Variant = "Secondary",
        },
        {
            Title = "执行",
            Icon = "arrow-right",
            Callback = function() 
                Confirmed = true
                createUI()
            end,
            Variant = "Primary",
        }
    }
})
function createUI()
    local Window = WindUI:CreateWindow({
        Title = "TY HUB-请捐赠",
        Icon = "palette",
    Author = "尊贵的"..game.Players.localPlayer.Name.."欢迎使用 TY HUB", 
        Folder = "Premium",
        Size = UDim2.fromOffset(550, 320),
        Theme = "Light",
        User = {
            Enabled = true,
            Anonymous = true,
            Callback = function()
            end
        },
        SideBarWidth = 200,
        HideSearchBar = false,  
    })

    Window:Tag({
        Title = "请捐赠",
        Color = Color3.fromHex("#00ffff") 
    })

    Window:EditOpenButton({
        Title = "TY HUBV2",
        Icon = "crown",
        CornerRadius = UDim.new(0, 8),
        StrokeThickness = 3,
        Color = ColorSequence.new(
            Color3.fromRGB(255, 255, 0),  
            Color3.fromRGB(255, 165, 0),  
            Color3.fromRGB(255, 0, 0),    
            Color3.fromRGB(139, 0, 0)     
        ),
        Draggable = true,
    })
local MainTab = Window:Tab({Title = "摊位管理", Icon = "settings"})
MainTab:Section({Title = "主要功能"})

local autoThanks = false
local thanksMessages = {
    "谢谢爸爸捐赠!",
    "感谢爸爸支持!",
    "谢谢爸爸捐赠!"
}
MainTab:Toggle({
    Title = "捐赠自动感谢",
    Desc = "收到捐赠后自动发送感谢消息",
    Default = false,
    Callback = function(Value)
        autoThanks = Value
        if Value then
            game.Players.LocalPlayer.leaderstats.Raised.Changed:Connect(function()
                if autoThanks then
                    local randomMsg = thanksMessages[math.random(1, #thanksMessages)]
                    game:GetService("ReplicatedStorage").DefaultChatSystemChatEvents.SayMessageRequest:FireServer(randomMsg, "All")
                end
            end)
        end
    end
})
local antiAFK = false
MainTab:Toggle({
    Title = "防止AFK",
    Default = false,
    Callback = function(Value)
        antiAFK = Value
        if Value then
            local VirtualInputManager = game:GetService("VirtualInputManager")
            task.spawn(function()
                while antiAFK do
                    task.wait(30)
                    VirtualInputManager:SendKeyEvent(true, "W", false, game)
                    task.wait(0.1)
                    VirtualInputManager:SendKeyEvent(false, "W", false, game)
                end
            end)
        end
    end
})
local autoTalk = false
local talkInterval = 60 
local talkMessages = {
    "欢迎来到我的摊位!",
    "请支持我",
    "请多多捐赠支持!",
    "我是最好的!",
    "谢谢大家的支持!"
}

MainTab:Toggle({
    Title = "自动说话",
    Desc = "定期自动发送消息",
    Default = false,
    Callback = function(Value)
        autoTalk = Value
        if Value then
            task.spawn(function()
                while autoTalk do
                    for i = 1, 5 do 
                        if not autoTalk then break end
                        local randomMsg = talkMessages[math.random(1, #talkMessages)]
                        game:GetService("ReplicatedStorage").DefaultChatSystemChatEvents.SayMessageRequest:FireServer(randomMsg, "All")
                        task.wait(1) 
                    end
                    task.wait(talkInterval - 5) 
                end
            end)
        end
    end
})

MainTab:Slider({
    Title = "说话间隔(秒)",
    Desc = "设置自动说话的间隔时间",
    Value = {
        Min = 10,
        Max = 300,
        Default = 60
    },
    Callback = function(Value)
        talkInterval = Value
    end
})

MainTab:Input({
    Title = "自定义说话内容",
    Desc = "输入自定义的说话内容(用逗号分隔)",
    Placeholder = "消息1,消息2,消息3",
    Callback = function(Value)
        if Value and Value ~= "" then
            local newMessages = {}
            for msg in string.gmatch(Value, "([^,]+)") do
                table.insert(newMessages, msg:gsub("^%s*(.-)%s*$", "%1"))
            end
            if #newMessages > 0 then
                talkMessages = newMessages
                WindUI:Notify({
                    Title = "说话内容已更新",
                    Content = "已设置 " .. #newMessages .. " 条自定义消息",
                    Duration = 3
                })
            end
        end
    end
})
end
      end
})
Section:Button({
    Title = "TY HUB-doors",
    Callback = function()
    
local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()
local Confirmed = false

WindUI:Popup({
    Title = "❆TY HUB-doors",
    IconThemed = true,
    Content = "尊贵的用户" .. game.Players.LocalPlayer.Name .. "使用 TY HUB",
    Buttons = {
        {
            Title = "取消",
            Callback = function() end,
            Variant = "Secondary",
        },
        {
            Title = "执行",
            Icon = "arrow-right",
            Callback = function() 
                Confirmed = true
                createUI()
            end,
            Variant = "Primary",
        }
    }
})

function createUI()
    local Window = WindUI:CreateWindow({
        Title = "TY HUB",
        Icon = "palette",
        Author = "尊贵的"..game.Players.LocalPlayer.Name.."欢迎使用 TY hub", 
        Folder = "Premium",
        Size = UDim2.fromOffset(550, 320),
        Theme = "Light",
        User = {
            Enabled = true,
            Anonymous = true,
            Callback = function()
            end
        },
        SideBarWidth = 200,
        HideSearchBar = false,  
    })

    Window:Tag({
        Title = "doors",
        Color = Color3.fromHex("#00ffff") 
    })
    
    Window:Tag({
        Title = "未完善",
        Color = Color3.fromHex("#00ffff") 
    })

    Window:EditOpenButton({
        Title = "TY脚本-doors",
        Icon = "crown",
        CornerRadius = UDim.new(0, 8),
        StrokeThickness = 3,
        Color = ColorSequence.new(
            Color3.fromRGB(255, 255, 0),  
            Color3.fromRGB(255, 165, 0),  
            Color3.fromRGB(255, 0, 0),    
            Color3.fromRGB(139, 0, 0)     
        ),
        Draggable = true,
    })
    
    local MovementTab = Window:Tab({Title = "人物", Icon = "running"})
    MovementTab:Button({
        Title = "禁用反作弊",
        Tooltip = "在电梯中使用，可能会有bug但通常有效",
        Callback = function()
            local Players = game:GetService("Players")
            local LocalPlayer = Players.LocalPlayer
            local currentRoom = LocalPlayer:GetAttribute("CurrentRoom")

            if currentRoom == 0 then
                if replicatesignal then
                    replicatesignal(LocalPlayer.Kill)
                    WindUI:Notify("反作弊", "反作弊已禁用，你可以飞行穿过一切", 10)
                else
                    WindUI:Notify("错误", "您的执行器不支持replicatesignal功能", 5)
                end
            else
                WindUI:Notify("提示", "你需要在电梯中使用此功能", 5)
            end
        end
    })
    MovementTab:Toggle({
        Title = "反作弊绕过",
        Default = false,
        Callback = function(Value)
            local Players = game:GetService("Players")
            local LocalPlayer = Players.LocalPlayer
            local RemoteFolder = game:GetService("ReplicatedStorage"):FindFirstChild("RemotesFolder")

            if not Value then
                if RemoteFolder and RemoteFolder:FindFirstChild("ClimbLadder") then
                    RemoteFolder.ClimbLadder:FireServer()
                end
            else
                WindUI:Notify("反作弊", "请上梯子以激活绕过", 9)
            end
        end
    })

   
    local LocalPlayer = game:GetService("Players").LocalPlayer
    LocalPlayer.Character:GetAttributeChangedSignal("Climbing"):Connect(function()
        if LocalPlayer.Character:GetAttribute("Climbing") == true then
            task.spawn(function()
                task.wait(0.1)
                LocalPlayer.Character:SetAttribute("Climbing", false)
                WindUI:Notify("反作弊", "已绕过反作弊，攀爬重置", 7)
            end)
        end
    end)

  
    MovementTab:Toggle({
        Title = "反作弊操纵",
        Default = false,
        Callback = function(Value)
            local Players = game:GetService("Players")
            local RunService = game:GetService("RunService")
            local Camera = workspace.CurrentCamera
            local LocalPlayer = Players.LocalPlayer
            local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
            local UserInputService = game:GetService("UserInputService")
            local savedCamCFrame
            local camLocked = false
            local acmButton
            local acmButtonActive = false

            local BUTTON_SIZE = UDim2.new(0, 70, 0, 35)
            local BUTTON_POSITION = UDim2.new(1, -80, 0.5, -17)
            local BUTTON_COLOR = Color3.fromRGB(45, 45, 45)
            local BUTTON_ACTIVE_COLOR = Color3.fromRGB(90, 90, 90)
            local BUTTON_TEXT_COLOR = Color3.fromRGB(255, 255, 255)

            local function createACMButton()
                if not UserInputService.TouchEnabled or acmButton then
                    return
                end

                local screenGui = Instance.new("ScreenGui")
                screenGui.Name = "ACMGui"
                screenGui.ResetOnSpawn = false
                screenGui.Parent = PlayerGui

                local button = Instance.new("TextButton")
                button.Name = "ACMButton"
                button.Size = BUTTON_SIZE
                button.Position = BUTTON_POSITION
                button.BackgroundColor3 = BUTTON_COLOR
                button.Text = "ACM"
                button.TextColor3 = BUTTON_TEXT_COLOR
                button.Font = Enum.Font.GothamBold
                button.TextSize = 16
                button.BorderSizePixel = 0
                button.Parent = screenGui

                button.MouseButton1Down:Connect(function()
                    acmButtonActive = true
                    button.BackgroundColor3 = BUTTON_ACTIVE_COLOR
                end)

                button.MouseButton1Up:Connect(function()
                    acmButtonActive = false
                    button.BackgroundColor3 = BUTTON_COLOR
                end)

                acmButton = screenGui
            end

            local function removeACMButton()
                if acmButton then
                    acmButton:Destroy()
                    acmButton = nil
                    acmButtonActive = false
                end
            end

            if Value then
                createACMButton()
                
                RunService.RenderStepped:Connect(function()
                    local cam = workspace.CurrentCamera
                    if not cam then return end

                    local active = Value and acmButtonActive
                    local char = LocalPlayer.Character
                    local hrp = char and char:FindFirstChild("HumanoidRootPart")

                    if active and hrp then
                        if not camLocked then
                            savedCamCFrame = cam.CFrame
                            cam.CameraType = Enum.CameraType.Scriptable
                            camLocked = true
                            hrp.CFrame = hrp.CFrame * CFrame.new(0, 0, 10000)
                        end

                        cam.CFrame = savedCamCFrame
                    elseif camLocked then
                        cam.CameraType = Enum.CameraType.Custom
                        camLocked = false
                        savedCamCFrame = nil
                    end
                end)
            else
                removeACMButton()
            end
        end
    })

    MovementTab:Keybind({
        Title = "反作弊操纵按键",
        Default = "T",
        Mode = "Hold",
        Callback = function(Value) end
    })
    
    local SpeedValue = 21
    local SpeedEnabled = false
    local SpeedConnection = nil
    local BypassLabel = nil

    MovementTab:Toggle({
        Title = "开启速度",
        Default = false,
        Tooltip = "将你的行走速度更改为设定值",
        Callback = function(Value)
            SpeedEnabled = Value
            local LocalPlayer = game:GetService("Players").LocalPlayer
            
            if Value then
                SpeedConnection = game:GetService("RunService").Heartbeat:Connect(function()
                    local humanoid = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
                    if humanoid then
                        humanoid.WalkSpeed = SpeedValue
                    end
                end)
                WindUI:Notify("移速", "自定义移速已启用: " .. SpeedValue, 3)
            else
                if SpeedConnection then
                    SpeedConnection:Disconnect()
                    SpeedConnection = nil
                end
                WindUI:Notify("移速", "自定义移速已禁用", 3)
            end
        end
    })

    MovementTab:Slider({
        Title = "速度数值",
        Value = {Min = 0, Max = 100, Default = 21},
        Suffix = " 速度",
        Tooltip = "设置你的行走速度",
        Callback = function(Value)
            SpeedValue = Value
            if SpeedEnabled then
                WindUI:Notify("移速", "移速已更新: " .. Value, 2)
            end
        end
    })
    MovementTab:Toggle({
        Title = "即时加速度",
        Default = false,
        Tooltip = "移除改变方向时的减速效果",
        Callback = function(Value)
            local LocalPlayer = game:GetService("Players").LocalPlayer
            local OldAccel = PhysicalProperties.new(0.01, 0.7, 0, 1, 1)
            
            local function updateAcceleration()
                local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                if hrp then
                    hrp.CustomPhysicalProperties = Value and PhysicalProperties.new(100, 0, 0, 0, 0) or OldAccel
                end
            end

            if Value then
                updateAcceleration()
                WindUI:Notify("加速度", "即时加速度已启用", 3)
            else
                updateAcceleration()
                WindUI:Notify("加速度", "即时加速度已禁用", 3)
            end
            LocalPlayer.CharacterAdded:Connect(function()
                task.wait(1.5)
                updateAcceleration()
            end)
        end
    })
    local isFlying = false
    local flyConnections = {}
    local flyKeys = {
        W = false,
        A = false,
        S = false,
        D = false,
        Space = false,
        Shift = false,
    }
    local FlySpeed = 50

    local function startFly()
        local player = game.Players.LocalPlayer
        local character = player.Character

        if not character then
            return
        end

        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if not humanoid then
            return
        end

        local hrp = character:FindFirstChild("HumanoidRootPart")
        if not hrp then
            return
        end
        local bv = Instance.new("BodyVelocity")
        bv.Name = "FlyVelocity"
        bv.MaxForce = Vector3.new(1000000000, 1000000000, 1000000000)
        bv.Velocity = Vector3.new(0, 0, 0)
        bv.Parent = hrp

        local bg = Instance.new("BodyGyro")
        bg.Name = "FlyGyro"
        bg.MaxTorque = Vector3.new(1000000000, 1000000000, 1000000000)
        bg.P = 20000
        bg.D = 1000
        bg.Parent = hrp

        humanoid.AutoRotate = false
        humanoid.PlatformStand = true
        humanoid:ChangeState(Enum.HumanoidStateType.Physics)
        local inputBegan = game:GetService("UserInputService").InputBegan:Connect(function(input, gpe)
            if gpe then return end
            
            if input.KeyCode == Enum.KeyCode.W then
                flyKeys.W = true
            elseif input.KeyCode == Enum.KeyCode.A then
                flyKeys.A = true
            elseif input.KeyCode == Enum.KeyCode.S then
                flyKeys.S = true
            elseif input.KeyCode == Enum.KeyCode.D then
                flyKeys.D = true
            elseif input.KeyCode == Enum.KeyCode.Space then
                flyKeys.Space = true
            elseif input.KeyCode == Enum.KeyCode.LeftShift then
                flyKeys.Shift = true
            end
        end)

        table.insert(flyConnections, inputBegan)

        local inputEnded = game:GetService("UserInputService").InputEnded:Connect(function(input)
            if input.KeyCode == Enum.KeyCode.W then
                flyKeys.W = false
            elseif input.KeyCode == Enum.KeyCode.A then
                flyKeys.A = false
            elseif input.KeyCode == Enum.KeyCode.S then
                flyKeys.S = false
            elseif input.KeyCode == Enum.KeyCode.D then
                flyKeys.D = false
            elseif input.KeyCode == Enum.KeyCode.Space then
                flyKeys.Space = false
            elseif input.KeyCode == Enum.KeyCode.LeftShift then
                flyKeys.Shift = false
            end
        end)

        table.insert(flyConnections, inputEnded)
        local renderConnection = game:GetService("RunService").RenderStepped:Connect(function()
            local cam = workspace.CurrentCamera

            if not cam or not hrp or not hrp:FindFirstChild("FlyVelocity") or not humanoid or humanoid.Health <= 0 then
                stopFly()
                return
            end

            local move = Vector3.new(0, 0, 0)

            if flyKeys.W then
                move = move + cam.CFrame.LookVector
            end
            if flyKeys.S then
                move = move - cam.CFrame.LookVector
            end
            if flyKeys.A then
                move = move - cam.CFrame.RightVector
            end
            if flyKeys.D then
                move = move + cam.CFrame.RightVector
            end
            if flyKeys.Space then
                move = move + Vector3.new(0, 1, 0)
            end
            if flyKeys.Shift then
                move = move - Vector3.new(0, 1, 0)
            end

            local direction = (move.Magnitude > 0) and (move.Unit * FlySpeed) or Vector3.new(0, 0, 0)
            bv.Velocity = direction
            bg.CFrame = cam.CFrame
        end)

        table.insert(flyConnections, renderConnection)
    end

    local function stopFly()
        local player = game.Players.LocalPlayer
        local character = player.Character
        local humanoid = character and character:FindFirstChildOfClass("Humanoid")
        local hrp = character and character:FindFirstChild("HumanoidRootPart")

        if hrp then
            local flyVelocity = hrp:FindFirstChild("FlyVelocity")
            if flyVelocity then
                flyVelocity:Destroy()
            end

            local flyGyro = hrp:FindFirstChild("FlyGyro")
            if flyGyro then
                flyGyro:Destroy()
            end
        end

        if humanoid then
            humanoid.AutoRotate = true
            humanoid.PlatformStand = false
            humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
        end

        for _, conn in ipairs(flyConnections) do
            conn:Disconnect()
        end

        flyConnections = {}
        flyKeys = {
            W = false,
            A = false,
            S = false,
            D = false,
            Space = false,
            Shift = false,
        }
    end

    MovementTab:Toggle({
        Title = "开启飞行",
        Default = false,
        Callback = function(Value)
            isFlying = Value

            if Value then
                startFly()
                WindUI:Notify("飞行", "飞行模式已启用", 3)
            else
                stopFly()
                WindUI:Notify("飞行", "飞行模式已禁用", 3)
            end
        end
    })

    MovementTab:Keybind({
        Title = "飞行电脑切换键",
        Default = "F",
        Mode = "Toggle",
        Callback = function(Value) end
    })

    MovementTab:Slider({
        Title = "飞行速度",
        Value = {Min = 0, Max = 150, Default = 50},
        Suffix = " 速度",
        Tooltip = "更改飞行速度",
        Callback = function(Value)
            FlySpeed = Value
            if isFlying then
                WindUI:Notify("飞行", "飞行速度已更新: " .. Value, 2)
            end
        end
    })
    local noclipConnection = nil
    local originalGroups = {}

    MovementTab:Toggle({
        Title = "穿墙模式",
        Default = false,
        Tooltip = "让你可以穿过墙壁",
        Callback = function(Value)
            local Players = game:GetService("Players")
            local RunService = game:GetService("RunService")
            local lp = Players.LocalPlayer

            local function enableNoclip()
                if noclipConnection then
                    return
                end

                noclipConnection = RunService.Stepped:Connect(function()
                    if lp.Character then
                        for _, part in pairs(lp.Character:GetDescendants()) do
                            if part:IsA("BasePart") then
                                part.CanCollide = false
                                if not originalGroups[part] then
                                    originalGroups[part] = part.CollisionGroup
                                end
                                part.CollisionGroup = "Default"
                            end
                        end
                    end
                end)
            end

            local function disableNoclip()
                if noclipConnection then
                    noclipConnection:Disconnect()
                    noclipConnection = nil
                end

                local char = lp.Character
                if not char then
                    return
                end

                local collision = char:FindFirstChild("Collision")
                local crouch = collision and collision:FindFirstChild("CollisionCrouch")

                if collision and crouch then
                    local crouching = collision.CollisionGroup == "PlayerCrouching"
                    collision.CanCollide = not crouching
                    crouch.CanCollide = crouching
                end
            end

            if Value then
                enableNoclip()
                WindUI:Notify("穿墙", "穿墙模式已启用", 3)
            else
                disableNoclip()
                WindUI:Notify("穿墙", "穿墙模式已禁用", 3)
            end
        end
    })

    MovementTab:Keybind({
        Title = "穿墙电脑切换键",
        Default = "N",
        Mode = "Toggle",
        Callback = function(Value) end
    })
    local LadderSpeedValue = 20
    local LadderSpeedEnabled = false
    local LadderConnection = nil

    MovementTab:Toggle({
        Title = "更快爬梯",
        Default = false,
        Callback = function(on)
            local LocalPlayer = game.Players.LocalPlayer
            local RunService = game:GetService("RunService")

            if on then
                LadderConnection = RunService.Heartbeat:Connect(function()
                    local char = LocalPlayer.Character
                    local hum = char and char:FindFirstChildOfClass("Humanoid")
                    local hrp = char and char:FindFirstChild("HumanoidRootPart")

                    if hum and hrp and hum:GetState() == Enum.HumanoidStateType.Climbing then
                        hrp.Velocity = Vector3.new(hrp.Velocity.X, LadderSpeedValue, hrp.Velocity.Z)
                    end
                end)
                WindUI:Notify("爬梯", "梯子加速已启用", 3)
            elseif LadderConnection then
                LadderConnection:Disconnect()
                LadderConnection = nil
                WindUI:Notify("爬梯", "梯子加速已禁用", 3)
            end
        end
    })

    MovementTab:Slider({
        Title = "爬梯速度",
        Value = {Min = 0, Max = 100, Default = 20},
        Suffix = " 速度",
        Tooltip = "爬梯的加速值，过高可能不稳定",
        Callback = function(Value)
            LadderSpeedValue = Value
            if LadderSpeedEnabled then
                WindUI:Notify("爬梯", "爬梯速度已更新: " .. Value, 2)
            end
        end
    })
    MovementTab:Toggle({
        Title = "始终可跳跃",
        Default = false,
        Tooltip = "让你随时可以跳跃",
        Callback = function(Value)
            local LocalPlayer = game.Players.LocalPlayer
            LocalPlayer.Character:SetAttribute("CanJump", Value)
            
            if Value then
                WindUI:Notify("跳跃", "始终跳跃已启用", 3)
            else
                WindUI:Notify("跳跃", "始终跳跃已禁用", 3)
            end
            LocalPlayer.CharacterAdded:Connect(function(newCharacter)
                task.wait(1.5)
                newCharacter:SetAttribute("CanJump", Value)
            end)
        end
    })
    local B = Window:Tab({Title = "自动类", Icon = "puzzle"})
    B:Toggle({
        Title = "自动锚点代码求解",
        Default = false,
        Callback = function(enabled)
            local running = false
            local Players = game:GetService("Players")
            local LocalPlayer = Players.LocalPlayer
            local Workspace = game:GetService("Workspace")
            
            if enabled then
                if running then return end
                running = true
                
                task.spawn(function()
                    local playerGui = LocalPlayer:WaitForChild("PlayerGui")
                    
                    local function findFrame()
                        local mainUI = playerGui:FindFirstChild("MainUI")
                        if mainUI and mainUI:FindFirstChild("MainFrame") then
                            local frame = mainUI.MainFrame:FindFirstChild("AnchorHintFrame")
                            if frame then return frame end
                        end

                        local anchorUI = playerGui:FindFirstChild("AnchorHintUI")
                        if anchorUI then
                            local frame = anchorUI:FindFirstChild("AnchorHintFrame")
                            if frame then return frame end
                        end
                        return nil
                    end

                    while running do
                        task.wait(0.9)
                        local frame = findFrame()
                        
                        if frame then
                            local anchorName = (frame:FindFirstChild("AnchorCode") and frame.AnchorCode.Text) or ''
                            local codeText = (frame:FindFirstChild("Code") and frame.Code.Text) or ''
                            
                            if anchorName ~= '' and codeText ~= '' then
                                local anchorObject
                                for _, obj in ipairs(Workspace.CurrentRooms:GetDescendants()) do
                                    if obj.Name == "MinesAnchor" then
                                        local sign = obj:FindFirstChild("Sign")
                                        if sign then
                                            local label = sign:FindFirstChild("TextLabel") or sign:FindFirstChildWhichIsA("TextLabel")
                                            if label and label.Text == anchorName then
                                                anchorObject = obj
                                                break
                                            end
                                        end
                                    end
                                end

                                if anchorObject then
                                    local note = anchorObject:FindFirstChild("Note")
                                    if not note then
                                        WindUI:Notify("锚点代码", "锚点 " .. anchorName .. " 代码是 " .. codeText, 3)
                                    else
                                        local surfaceGui = note:FindFirstChildOfClass("SurfaceGui") or note:FindFirstChild("SurfaceGui")
                                        local noteText = (surfaceGui and surfaceGui:FindFirstChild("TextLabel") and surfaceGui.TextLabel.Text) or '0'
                                        local noteValue = tonumber(noteText) or 0
                                        local solved = ''
                                        
                                        for i = 1, #codeText do
                                            local digit = tonumber(codeText:sub(i, i)) or 0
                                            digit = (digit + noteValue) % 10
                                            solved = solved .. tostring(digit)
                                        end
                                        
                                        WindUI:Notify("锚点代码", "锚点 " .. anchorName .. " 代码是 " .. solved, 5)
                                    end
                                end
                            end
                        else
                            task.wait(0.25)
                        end
                    end
                end)
            else
                running = false
            end
        end
    })
    B:Toggle({
        Title = "自动断路器游戏",
        Default = false,
        Callback = function(Value)
            local Players = game:GetService("Players")
            local ReplicatedStorage = game:GetService("ReplicatedStorage")
            local LocalPlayer = Players.LocalPlayer
            local RemoteFolder = ReplicatedStorage:FindFirstChild("RemotesFolder") or ReplicatedStorage:FindFirstChild("EntityInfo") or ReplicatedStorage:FindFirstChild("Bricks")
            
            while task.wait() and Value do
                if not Value then break end
                
                local currentRoom = LocalPlayer:GetAttribute("CurrentRoom")
                if currentRoom ~= 100 then
                    WindUI:Notify("提示", "你需要在100号房间使用此功能", 5)
                    break
                end

                local Breaker = nil
                for _, v in ipairs(workspace.CurrentRooms:GetDescendants()) do
                    if v.Name == "ElevatorBreaker" then
                        Breaker = v
                        break
                    end
                end

                if Breaker then
                    local solved = true
                    for _, v in ipairs(Breaker:GetChildren()) do
                        if v.Name == "BreakerSwitch" then
                            local codeText = Breaker:WaitForChild("SurfaceGui").Frame.Code.Text
                            if v:GetAttribute("ID") == tonumber(codeText) then
                                if Breaker.SurfaceGui.Frame.Code.Frame.BackgroundTransparency == 0 then
                                    v:SetAttribute("Enabled", true)
                                    if not v.Sound.Playing then
                                        v.Sound.Playing = true
                                    end
                                    v.Material = Enum.Material.Neon
                                    v.Light.Attachment.Spark:Emit(1)
                                    v.PrismaticConstraint.TargetPosition = -0.2
                                else
                                    v:SetAttribute("Enabled", false)
                                    if not v.Sound.Playing then
                                        v.Sound.Playing = true
                                    end
                                    v.PrismaticConstraint.TargetPosition = 0.2
                                    v.Material = Enum.Material.Glass
                                    solved = false
                                end
                            end
                        end
                    end

                    if solved and RemoteFolder then
                        local breakerRemote = RemoteFolder:FindFirstChild("BreakerMinigame")
                        if breakerRemote then
                            breakerRemote:FireServer("Solved")
                        end
                    end
                end
            end
        end
    })
    B:Toggle({
        Title = "自动隐藏[防怪物]",
        Default = false,
        Risky = true,
        Tooltip = "自动为你隐藏",
        Callback = function(Value)
            local EntityDistances = {
                RushMoving = 50,
                BackdoorRush = 50,
                AmbushMoving = 100,
                A60 = 100,
                A120 = 35,
            }
            local Rooms = workspace.CurrentRooms
            local LocalPlayer = game.Players.LocalPlayer
            local Connections = {}

            local function GetHiding()
                local Closest, Prompt
                local currRoom = Rooms and Rooms[LocalPlayer:GetAttribute("CurrentRoom")]
                if not currRoom then return nil end

                local char = LocalPlayer.Character
                if not char then return nil end

                local hrp = char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Collision") or char.PrimaryPart
                if not hrp then return nil end

                local function distFromPlayer(model)
                    if not model then return math.huge end
                    local part = model.PrimaryPart or model:FindFirstChildWhichIsA("BasePart", true)
                    if not part then return math.huge end
                    return (part.Position - hrp.Position).Magnitude
                end

                local assets = currRoom:FindFirstChild("Assets")
                if assets then
                    for _, v in pairs(assets:GetChildren()) do
                        if v:IsA("Model") then
                            if ((v.Name == "Locker_Large") or (v.Name == "Wardrobe") or (v.Name == "Toolshed") or (v.Name == "Bed") or (v.Name == "Rooms_Locker") or (v.Name == "Rooms_Locker_Fridge") or (v.Name == "Backdoor_Wardrobe")) and v:FindFirstChild("HidePrompt") and v:FindFirstChild("HiddenPlayer") then
                                if not v.HiddenPlayer.Value and not v:FindFirstChild("HideEntityOnSpot", true) then
                                    if Closest then
                                        if distFromPlayer(v) < distFromPlayer(Closest) then
                                            Closest = v
                                            Prompt = v.HidePrompt
                                        end
                                    else
                                        Closest = v
                                        Prompt = v.HidePrompt
                                    end
                                end
                            elseif v.Name == "Double_Bed" then
                                for _, x in pairs(v:GetChildren()) do
                                    if x.Name == "DoubleBed" and x:FindFirstChild("HidePrompt") and x:FindFirstChild("HiddenPlayer") then
                                        if not x.HiddenPlayer.Value and not x:FindFirstChild("HideEntityOnSpot", true) then
                                            if Closest then
                                                if distFromPlayer(x) < distFromPlayer(Closest) then
                                                    Closest = x
                                                    Prompt = x.HidePrompt
                                                end
                                            else
                                                Closest = x
                                                Prompt = x.HidePrompt
                                            end
                                        end
                                    end
                                end
                            elseif v.Name == "Dumpster" then
                                for _, x in pairs(v:GetChildren()) do
                                    if x:FindFirstChild("HidePrompt") and x:FindFirstChild("HiddenPlayer") then
                                        local dumpsterBaseHasSpot = v:FindFirstChild("DumpsterBase") and v.DumpsterBase:FindFirstChild("HideEntityOnSpot")
                                        if not x.HiddenPlayer.Value and not dumpsterBaseHasSpot then
                                            if Closest then
                                                if distFromPlayer(x) < distFromPlayer(Closest) then
                                                    Closest = x
                                                    Prompt = x.HidePrompt
                                                end
                                            else
                                                Closest = x
                                                Prompt = x.HidePrompt
                                            end
                                        end
                                    end
                                end
                            end
                        elseif v:IsA("Folder") then
                            if v.Name == "Blockage" then
                                for _, x in pairs(v:GetChildren()) do
                                    if x:IsA("Model") and x.Name == "Wardrobe" and x:FindFirstChild("HiddenPlayer") and x:FindFirstChild("HidePrompt") then
                                        if not x.HiddenPlayer.Value then
                                            if Closest then
                                                if distFromPlayer(x) < distFromPlayer(Closest) then
                                                    Closest = x
                                                    Prompt = x.HidePrompt
                                                end
                                            else
                                                Closest = x
                                                Prompt = x.HidePrompt
                                            end
                                        end
                                    end
                                end
                            elseif v.Name == "Vents" then
                                for _, x in pairs(v:GetChildren()) do
                                    if x.Name == "CircularVent" and x:FindFirstChild("Grate") and x.Grate:FindFirstChild("HidePrompt") and x:FindFirstChild("HiddenPlayer") then
                                        if not x.HiddenPlayer.Value and not v:FindFirstChild("HideEntityOnSpot", true) then
                                            if Closest then
                                                if distFromPlayer(x) < distFromPlayer(Closest) then
                                                    Closest = x
                                                    Prompt = x.Grate.HidePrompt
                                                end
                                            else
                                                Closest = x
                                                Prompt = x.Grate.HidePrompt
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                end

                for _, v in pairs(currRoom:GetChildren()) do
                    if v:IsA("Model") then
                        if v.Name == "CircularVent" and v:FindFirstChild("Grate") and v.Grate:FindFirstChild("HidePrompt") and v:FindFirstChild("HiddenPlayer") then
                            if not v.HiddenPlayer.Value and not v:FindFirstChild("HideEntityOnSpot", true) then
                                if Closest then
                                    if distFromPlayer(v) < distFromPlayer(Closest) then
                                        Closest = v
                                        Prompt = v.Grate.HidePrompt
                                    end
                                else
                                    Closest = v
                                    Prompt = v.Grate.HidePrompt
                                end
                            end
                        end
                    end
                end

                return Prompt
            end

            if Value then
                table.insert(Connections, workspace.ChildAdded:Connect(function(v)
                    if v:IsA("Model") and EntityDistances[v.Name] then
                        task.wait(1)
                        local Part = v.PrimaryPart or v:FindFirstChildWhichIsA("BasePart", true)
                        if not Part then return end

                        v:SetAttribute("_Prediction", Part.Position)

                        while task.wait() and v.Parent do
                            task.spawn(function()
                                local LastPosition = Part.Position
                                task.wait(0.3333333333333333)
                                if Part and Part.Parent then
                                    v:SetAttribute("_Prediction", Part.Position - LastPosition)
                                end
                            end)

                            if Value then
                                local IncludeList = {}
                                for _, Room in pairs(Rooms:GetChildren()) do
                                    if Room:FindFirstChild("Assets") then
                                        table.insert(IncludeList, Room.Assets)
                                    end
                                    if Room:FindFirstChild("Parts") then
                                        table.insert(IncludeList, Room.Parts)
                                    end
                                end

                                local RaycastParams = RaycastParams.new()
                                RaycastParams.FilterDescendantsInstances = IncludeList
                                RaycastParams.FilterType = Enum.RaycastFilterType.Include

                                local Count = {0.2, 0.4, 0.6, 0.8, 1}
                                local entityInRange = false

                                for i = 1, #Count do
                                    local Number = 1.5 * Count[i]
                                    local predAttr = v:GetAttribute("_Prediction")
                                    local Prediction = (predAttr and (predAttr * 3)) or Vector3.new(0, 0, 0)
                                    Prediction = Prediction * Number

                                    local char = LocalPlayer.Character
                                    if not char then break end

                                    local hrp = char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Collision") or char.PrimaryPart
                                    if not hrp then break end

                                    if Vector3.new(Prediction.X, 0, Prediction.Z).Magnitude > 1 then
                                        local PredictionPosition = Part.Position + Prediction
                                        local Raycast
                                        if true then
                                            Raycast = workspace:Raycast(hrp.Position, PredictionPosition - hrp.Position, RaycastParams)
                                        end

                                        local distMultiplier = 1
                                        local mode = "Safety"
                                        local adjust = 0

                                        if mode == "Safety" then
                                            adjust = 20
                                        elseif mode == "Close Call" then
                                            adjust = -20
                                        end

                                        local adjustedDistance = EntityDistances[v.Name] + adjust
                                        local distanceToEntity = (PredictionPosition - hrp.Position).Magnitude

                                        if not Raycast and distanceToEntity <= (adjustedDistance * distMultiplier) then
                                            entityInRange = true
                                            local Prompt = GetHiding()
                                            if Prompt then
                                                pcall(function()
                                                    fireproximityprompt(Prompt)
                                                end)
                                            end
                                            break
                                        end
                                    end
                                end

                                local char = LocalPlayer.Character
                                if char and not entityInRange and char:GetAttribute("Hiding") then
                                    char:SetAttribute("Hiding", false)
                                end
                            end
                        end
                    end
                end))
            else
                for _, conn in ipairs(Connections) do
                    conn:Disconnect()
                end
                Connections = {}
            end
        end
    })

B:Dropdown({
        Title = "自动隐藏模式",
        Values = {"Safety", "Close Call"},
        Default = "Safety",
        Callback = function(Value) end
    })

   B:Slider({
        Title = "预测时间",
        Value = {Min = 0.1, Max = 1.5, Default = 1.5},
        Suffix = "s",
        Callback = function(Value) end
    })

    B:Slider({
        Title = "距离倍数",
        Value = {Min = 1, Max = 1.5, Default = 1},
        Suffix = "x",
        Callback = function(Value) end
    })
    local AutoInteractDistance = 10
    B:Toggle({
        Title = "自动互动",
        Default = false,
        Callback = function(Value)
            if Value then
                local RunService = game:GetService("RunService")
                local LocalPlayer = game.Players.LocalPlayer

                local AutoInteractConnection
                local CachedInteractables = {}
                local PromptSeen = {}
                local InteractableModels = {
                    AlarmClock = true, GlitchCub = true, Aloe = true, BandagePack = true, Battery = true,
                    TimerLever = true, OuterPart = true, BatteryPack = true, Candle = true, LiveBreakerPolePickup = true,
                    Compass = true, Crucifix = true, ElectricalRoomKey = true, Flashlight = true, Glowstick = true,
                    HolyHandGrenade = true, Lantern = true, LaserPointer = true, Lighter = true, Lockpick = true,
                    LotusFlower = true, LotusPetalPickup = true, Multitool = true, NVCS3000 = true, OutdoorsKey = true,
                    Shears = true, SkeletonKey = true, Smoothie = true, SolutionPaper = true, Spotlight = true,
                    StarlightVial = true, StarlightJug = true, StarlightBottle = true, Vitamins = true,
                }

                local function PickRootPart(obj, prompt)
                    if prompt and prompt.Parent and prompt.Parent:IsA("BasePart") then
                        return prompt.Parent
                    end
                    if obj:IsA("Model") then
                        if obj.PrimaryPart and obj.PrimaryPart:IsA("BasePart") then
                            return obj.PrimaryPart
                        end
                        local common = obj:FindFirstChild("Main", true) or obj:FindFirstChild("Handle", true) or obj:FindFirstChild("Door", true)
                        if common and common:IsA("BasePart") then
                            return common
                        end
                    end
                    return obj:FindFirstChildWhichIsA("BasePart", true)
                end

                local function AddPromptsFromObject(obj)
                    for _, desc in ipairs(obj:GetDescendants()) do
                        if desc:IsA("ProximityPrompt") and not PromptSeen[desc] then
                            local root = PickRootPart(obj, desc)
                            if root then
                                PromptSeen[desc] = true
                                table.insert(CachedInteractables, {
                                    prompt = desc,
                                    part = root,
                                    last = 0,
                                })
                            end
                        end
                    end
                end

                local function CollectTargets(folder)
                    for _, v in ipairs(folder:GetChildren()) do
                        if v:IsA("Model") or v:IsA("Folder") then
                            if v.Name == "DrawerContainer" or InteractableModels[v.Name] or v.Name == "RoomsLootItem" or v.Name == "Locker_Small" or v.Name == "Toolbox" or v.Name == "ChestBox" or v.Name == "Toolshed_Small" or v.Name == "CrucifixOnTheWall" then
                                AddPromptsFromObject(v)
                            end
                            CollectTargets(v)
                        end
                    end
                end

                local function RefreshTargets()
                    CachedInteractables = {}
                    PromptSeen = {}
                    local CurrentRoom = workspace.CurrentRooms[LocalPlayer:GetAttribute("CurrentRoom")]
                    if not CurrentRoom then return end
                    CollectTargets(CurrentRoom)
                end

                local lastCheck = 0
                local interval = 0.2

                local function AutoInteractStep(dt)
                    lastCheck = lastCheck + dt
                    if lastCheck < interval then return end
                    lastCheck = 0

                    if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("Collision") then
                        return
                    end

                    local charPos = LocalPlayer.Character.Collision.Position
                    local now = tick()

                    for i = #CachedInteractables, 1, -1 do
                        local entry = CachedInteractables[i]
                        local prompt, part = entry.prompt, entry.part

                        if not prompt or not prompt.Parent or not part or not part:IsDescendantOf(workspace) then
                            table.remove(CachedInteractables, i)
                        else
                            local dist = (part.Position - charPos).Magnitude
                            if dist <= AutoInteractDistance and (now - (entry.last or 0)) >= 0.35 then
                                entry.last = now
                                task.spawn(function()
                                    pcall(function()
                                        fireproximityprompt(prompt)
                                    end)
                                end)
                            end
                        end
                    end
                end

                RefreshTargets()
                AutoInteractConnection = RunService.Heartbeat:Connect(AutoInteractStep)

                local attributeConn
                local roomDescConn

                attributeConn = LocalPlayer:GetAttributeChangedSignal("CurrentRoom"):Connect(function()
                    RefreshTargets()
                    if roomDescConn then
                        roomDescConn:Disconnect()
                        roomDescConn = nil
                    end
                    local cr = workspace.CurrentRooms[LocalPlayer:GetAttribute("CurrentRoom")]
                    if cr then
                        roomDescConn = cr.DescendantAdded:Connect(function()
                            task.defer(RefreshTargets)
                        end)
                    end
                end)

                local cr = workspace.CurrentRooms[LocalPlayer:GetAttribute("CurrentRoom")]
                if cr then
                    roomDescConn = cr.DescendantAdded:Connect(function()
                        task.defer(RefreshTargets)
                    end)
                end

                _G.StopAutoInteract = function()
                    if AutoInteractConnection then
                        AutoInteractConnection:Disconnect()
                        AutoInteractConnection = nil
                    end
                    if attributeConn then
                        attributeConn:Disconnect()
                        attributeConn = nil
                    end
                    if roomDescConn then
                        roomDescConn:Disconnect()
                        roomDescConn = nil
                    end
                    CachedInteractables, PromptSeen = {}, {}
                end
            elseif _G.StopAutoInteract then
                _G.StopAutoInteract()
                _G.StopAutoInteract = nil
            end
        end
    })

    B:Slider({
        Title = "自动互动距离",
        Value = {Min = 1, Max = 20, Default = 10},
        Suffix = " studs",
        Callback = function(Value)
            AutoInteractDistance = Value
        end
    })
    B:Toggle({
        Title = "自动矿车推动",
        Default = false,
        Callback = function(Value)
            local Players = game:GetService("Players")
            local RunService = game:GetService("RunService")
            local LocalPlayer = Players.LocalPlayer
            local Workspace = game:GetService("Workspace")
            local Rooms = Workspace:WaitForChild("CurrentRooms")

            if _G.AutoMinecartConn then
                _G.AutoMinecartConn:Disconnect()
                _G.AutoMinecartConn = nil
            end
            if _G.AutoMinecartLoop then
                _G.AutoMinecartLoop:Disconnect()
                _G.AutoMinecartLoop = nil
            end

            if Value then
                local function tryPush(cartModel)
                    local cart = cartModel:FindFirstChild("Cart")
                    if not cart then return end
                    local prompt = cart:FindFirstChild("PushPrompt")
                    if not prompt then return end

                    local character = LocalPlayer.Character
                    local root = character and character:FindFirstChild("HumanoidRootPart")
                    if not root then return end

                    if (root.Position - prompt.Parent.Position).Magnitude <= (prompt.MaxActivationDistance or 10) then
                        fireproximityprompt(prompt)
                    end
                end

                _G.AutoMinecartConn = Rooms.DescendantAdded:Connect(function(obj)
                    if obj.Name == "MinecartMoving" then
                        task.defer(function()
                            tryPush(obj)
                        end)
                    end
                end)

                _G.AutoMinecartLoop = RunService.Heartbeat:Connect(function()
                    local character = LocalPlayer.Character
                    local root = character and character:FindFirstChild("HumanoidRootPart")
                    if not root then return end

                    for _, obj in ipairs(Rooms:GetDescendants()) do
                        if obj.Name == "MinecartMoving" then
                            tryPush(obj)
                        end
                    end
                end)
            else
                if _G.AutoMinecartConn then
                    _G.AutoMinecartConn:Disconnect()
                end
                if _G.AutoMinecartLoop then
                    _G.AutoMinecartLoop:Disconnect()
                end
                _G.AutoMinecartConn = nil
                _G.AutoMinecartLoop = nil
            end
        end
    })
    B:Toggle({
        Title = "自动拾取投掷物",
        Default = false,
        Callback = function(Value)
            local targetProps = {
                "WoodenCrate", "OilBarrel", "GarbageBag", "Trashcan", 
                "CardboardBox_Normal", "Hat_Stand", "CardboardBox_Wide", "Office_Chair"
            }
            local running = true

            if Value then
                task.spawn(function()
                    while running and Value do
                        local bigProps = workspace:FindFirstChild("BigProps")
                        if bigProps then
                            for _, name in ipairs(targetProps) do
                                local prop = bigProps:FindFirstChild(name)
                                if prop then
                                    for _, d in ipairs(prop:GetDescendants()) do
                                        if d:IsA("ProximityPrompt") then
                                            d.MaxActivationDistance = 20
                                            if d.Enabled then
                                                pcall(fireproximityprompt, d)
                                            end
                                        end
                                    end
                                end
                            end
                        end
                        task.wait(0.5)
                    end
                end)
            else
                running = false
            end
        end
    })
    B:Toggle({
        Title = "自动破门",
        Default = false,
        Callback = function(Value)
            local connections = {}
            local running = false
            local targetNames = {"DoorPieceBottom", "DoorPieceTop"}

            local function safeDisconnect()
                for _, c in ipairs(connections) do
                    if c and c.Disconnect then
                        pcall(function() c:Disconnect() end)
                    elseif c and c.disconnect then
                        pcall(function() c:disconnect() end)
                    end
                end
                connections = {}
            end

            local function handlePrompt(p)
                pcall(function() p.MaxActivationDistance = 40 end)
                if p.Enabled then
                    pcall(fireproximityprompt, p)
                end
            end

            local function processModel(m)
                for _, n in ipairs(targetNames) do
                    local part = m:FindFirstChild(n, true)
                    if part then
                        for _, d in ipairs(part:GetDescendants()) do
                            if d:IsA("ProximityPrompt") then
                                pcall(handlePrompt, d)
                            end
                        end

                        local con = part.DescendantAdded:Connect(function(desc)
                            if desc:IsA("ProximityPrompt") then
                                pcall(function() task.defer(handlePrompt, desc) end)
                            end
                        end)
                        table.insert(connections, con)
                    end
                end
            end

            local function scanAll()
                local cr = workspace:FindFirstChild("CurrentRooms")
                if not cr then return end

                for _, room in ipairs(cr:GetDescendants()) do
                    if room:IsA("Model") or room:IsA("Folder") then
                        processModel(room)
                    end
                end
            end

            if Value then
                running = true
                safeDisconnect()
                
                task.spawn(function()
                    scanAll()
                    local cr = workspace:FindFirstChild("CurrentRooms")
                    if cr then
                        local con = cr.DescendantAdded:Connect(function(d)
                            if not running then return end
                            local model = d
                            while model and not (model:IsA("Model") or model:IsA("Folder")) do
                                model = model.Parent
                            end
                            if model then
                                task.defer(processModel, model)
                            end
                        end)
                        table.insert(connections, con)
                    end

                    while running and Value do
                        scanAll()
                        task.wait(0.8)
                    end
                end)
            else
                running = false
                safeDisconnect()
            end
        end
    })
    B:Toggle({
        Title = "自动拾取",
        Default = false,
        Callback = function(Value)
            local connections = {}
            local running = false

            local function safeDisconnect()
                for _, c in ipairs(connections) do
                    if c and c.Disconnect then
                        pcall(function() c:Disconnect() end)
                    elseif c and c.disconnect then
                        pcall(function() c:disconnect() end)
                    end
                end
                connections = {}
            end

            local function handlePrompt(p)
                pcall(function() p.MaxActivationDistance = 40 end)
                if p.Enabled then
                    pcall(fireproximityprompt, p)
                end
            end

            local function processDrop(d)
                for _, desc in ipairs(d:GetDescendants()) do
                    if desc:IsA("ProximityPrompt") then
                        pcall(handlePrompt, desc)
                    end
                end

                local con = d.DescendantAdded:Connect(function(desc)
                    if desc:IsA("ProximityPrompt") then
                        pcall(function() task.defer(handlePrompt, desc) end)
                    end
                end)
                table.insert(connections, con)
            end

            local function scanDrops()
                local drops = workspace:FindFirstChild("Drops")
                if not drops then return end

                for _, child in ipairs(drops:GetChildren()) do
                    if child:IsA("Model") or child:IsA("Folder") then
                        processDrop(child)
                    end
                end
            end

            if Value then
                running = true
                safeDisconnect()
                
                task.spawn(function()
                    scanDrops()
                    local drops = workspace:FindFirstChild("Drops")
                    if drops then
                        local con = drops.ChildAdded:Connect(function(c)
                            if not running then return end
                            if c:IsA("Model") or c:IsA("Folder") then
                                task.defer(processDrop, c)
                            end
                        end)
                        table.insert(connections, con)
                    end

                    while running and Value do
                        scanDrops()
                        task.wait(0.8)
                    end
                end)
            else
                running = false
                safeDisconnect()
            end
        end
    })
    B:Toggle({
        Title = "自动开火",
        Default = false,
        Callback = function(Value)
            local Players = game:GetService("Players")
            local RunService = game:GetService("RunService")
            local LocalPlayer = Players.LocalPlayer
            local Camera = workspace.CurrentCamera
            local RAY_DISTANCE = 50
            local con = nil
            local triggered = false

            local function safeMouse1Press() pcall(mouse1press) end
            local function safeMouse1Release() pcall(mouse1release) end

            local function isTargetVisible(targetPos)
                local rayParams = RaycastParams.new()
                rayParams.FilterType = Enum.RaycastFilterType.Exclude
                rayParams.FilterDescendantsInstances = {LocalPlayer.Character}

                local origin = Camera.CFrame.Position
                local direction = targetPos - origin
                local result = workspace:Raycast(origin, direction, rayParams)

                if not result then return true end
                return (result.Instance.Position - targetPos).Magnitude < 3
            end

            local function update()
                if not LocalPlayer.Character or not Camera then
                    if triggered then
                        safeMouse1Release()
                        triggered = false
                    end
                    return
                end

                local myChar = LocalPlayer.Character
                local myHead = myChar:FindFirstChild("Head")
                if not myHead then return end

                local lookVector = Camera.CFrame.LookVector
                local origin = Camera.CFrame.Position
                local bestTarget = nil
                local bestDot = 0.995

                for _, plr in pairs(Players:GetPlayers()) do
                    if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                        local targetPos = plr.Character.HumanoidRootPart.Position
                        local dirToTarget = (targetPos - origin).Unit
                        local dot = lookVector:Dot(dirToTarget)

                        if dot > bestDot then
                            local dist = (targetPos - origin).Magnitude
                            if dist < RAY_DISTANCE and isTargetVisible(targetPos) then
                                bestDot = dot
                                bestTarget = plr
                            end
                        end
                    end
                end

                if bestTarget then
                    if not triggered then
                        WindUI:Notify("自动开火", "正在向 " .. bestTarget.Name .. " 开火", 2)
                        safeMouse1Press()
                        triggered = true
                    end
                elseif triggered then
                    safeMouse1Release()
                    triggered = false
                end
            end

            if Value then
                if con and con.Connected then
                    con:Disconnect()
                end
                con = RunService.RenderStepped:Connect(function()
                    pcall(update)
                end)
            else
                if con then
                    con:Disconnect()
                    con = nil
                end
                if triggered then
                    safeMouse1Release()
                    triggered = false
                end
            end
        end
    })
    B:Toggle({
        Title = "自动房间",
        Default = false,
        Callback = function(enabled)
            local Players = game:GetService("Players")
            local RunService = game:GetService("RunService")
            local PathfindingService = game:GetService("PathfindingService")
            local ReplicatedStorage = game:GetService("ReplicatedStorage")
            local Workspace = game:GetService("Workspace")
            local player = Players.LocalPlayer
            local rooms = Workspace:WaitForChild("CurrentRooms")
            local gameData = ReplicatedStorage:WaitForChild("GameData")
            local floor = gameData:WaitForChild("Floor")
            local active = false
            local runner
            local clone

            local function stop()
                active = false
                if runner then
                    runner:Disconnect()
                    runner = nil
                end
                if clone and clone.Parent then
                    clone:Destroy()
                end
                player:SetAttribute("AutoRoomsActive", false)
            end

            if not enabled then
                stop()
                return
            end

            player:SetAttribute("AutoRoomsActive", true)
            active = true

            if player.Character and player.Character:FindFirstChild("CollisionPart") then
                clone = player.Character.CollisionPart:Clone()
                clone.Name = "_AutoRoomsCollision"
                clone.Massless = true
                clone.Anchored = false
                clone.CanCollide = false
                clone.CanQuery = false
                clone.CustomPhysicalProperties = PhysicalProperties.new(0.01, 0.7, 0, 1, 1)
                clone.Parent = player.Character
            end

            local function findClosestLocker()
                local best, bestDist = nil, math.huge
                for _, obj in ipairs(rooms:GetDescendants()) do
                    if obj.Name == "Rooms_Locker" or obj.Name == "Rooms_Locker_Fridge" then
                        if obj.PrimaryPart then
                            local dist = (player.Character.HumanoidRootPart.Position - obj.PrimaryPart.Position).Magnitude
                            if dist < bestDist then
                                best = obj
                                bestDist = dist
                            end
                        end
                    end
                end
                return best
            end

            local function walkTo(target)
                local char = player.Character
                if not char or not char:FindFirstChild("HumanoidRootPart") then return end

                local path = PathfindingService:CreatePath({
                    AgentRadius = 2,
                    AgentHeight = 1,
                    AgentCanJump = false,
                    WaypointSpacing = 5,
                })

                path:ComputeAsync(char.HumanoidRootPart.Position, target.Position)

                if path.Status == Enum.PathStatus.Success then
                    for _, waypoint in ipairs(path:GetWaypoints()) do
                        if not active then return end
                        char:FindFirstChildOfClass("Humanoid"):MoveTo(waypoint.Position)
                        char.Humanoid.MoveToFinished:Wait()
                    end
                end
            end

            runner = RunService.Heartbeat:Connect(function()
                if not active then return end
                if floor.Value ~= "Rooms" then return stop() end
                if gameData.LatestRoom.Value >= 1000 then return stop() end

                local entity = Workspace:FindFirstChild("A60") or Workspace:FindFirstChild("A120") or Workspace:FindFirstChild("GlitchRush") or Workspace:FindFirstChild("GlitchAmbush")

                if entity and entity.PrimaryPart and entity.PrimaryPart.Position.Y > -6 then
                    local locker = findClosestLocker()
                    if locker and locker.PrimaryPart then
                        local hide = locker:FindFirstChild("HidePoint")
                        if not hide then
                            hide = Instance.new("Part")
                            hide.Name = "HidePoint"
                            hide.Anchored = true
                            hide.Transparency = 1
                            hide.CanCollide = false
                            hide.Position = locker.PrimaryPart.Position + (locker.PrimaryPart.CFrame.LookVector * 7)
                            hide.Parent = locker
                        end

                        walkTo(hide)
                        task.wait(0.1)

                        local prompt = locker:FindFirstChildOfClass("ProximityPrompt")
                        if prompt then
                            if fireproximityprompt then
                                fireproximityprompt(prompt)
                            else
                                prompt:InputHoldBegin()
                                prompt:InputHoldEnd()
                            end
                        end
                    end
                else
                    local currentRoom = gameData.LatestRoom.Value
                    local door = rooms[currentRoom] and rooms[currentRoom]:FindFirstChild("Door", true)
                    if door and door:FindFirstChild("Door") then
                        walkTo(door.Door)
                    end
                end
            end)
        end
    })

   B:Toggle({
        Title = "反AFK",
        Default = false,
        Callback = function(Value)
            local Players = game:GetService("Players")
            local VirtualUser = game:GetService("VirtualUser")
            local LocalPlayer = Players.LocalPlayer
            local AntiAFKConnection

            if Value then
                AntiAFKConnection = LocalPlayer.Idled:Connect(function()
                    VirtualUser:CaptureController()
                    VirtualUser:ClickButton2(Vector2.new())
                end)
                WindUI:Notify("反AFK", "反AFK已启用", 3)
            elseif AntiAFKConnection then
                AntiAFKConnection:Disconnect()
                AntiAFKConnection = nil
                WindUI:Notify("反AFK", "反AFK已禁用", 3)
            end
        end
    })
    B:Toggle({
        Title = "自动门范围",
        Default = false,
        Callback = function(Value)
            local doorReachLoop

            if Value then
                local Rooms = workspace:FindFirstChild("CurrentRooms")
                if not Rooms then return end

                doorReachLoop = task.spawn(function()
                    while Value do
                        for _, room in pairs(Rooms:GetChildren()) do
                            local door = room:FindFirstChild("Door")
                            if door and door:FindFirstChild("ClientOpen") then
                                door.ClientOpen:FireServer()
                            end
                        end
                        task.wait(0.5)
                    end
                end)
                WindUI:Notify("自动门", "自动门范围已启用", 3)
            else
                doorReachLoop = nil
                WindUI:Notify("自动门", "自动门范围已禁用", 3)
            end
        end
    })
    B:Toggle({
        Title = "即时互动",
        Default = false,
        Callback = function(Value)
            if getgenv().ProximityConnection then
                getgenv().ProximityConnection:Disconnect()
                getgenv().ProximityConnection = nil
            end

            local function modifyPrompt(prompt, instant)
                if not prompt:IsA("ProximityPrompt") then return end
                if instant then
                    if not prompt:GetAttribute("OriginalHoldDuration") then
                        prompt:SetAttribute("OriginalHoldDuration", prompt.HoldDuration)
                        prompt:SetAttribute("OriginalLineOfSight", prompt.RequiresLineOfSight)
                    end
                    prompt.HoldDuration = 0
                    prompt.RequiresLineOfSight = false
                else
                    prompt.HoldDuration = prompt:GetAttribute("OriginalHoldDuration") or 1
                    prompt.RequiresLineOfSight = prompt:GetAttribute("OriginalLineOfSight") or true
                end
            end

            local currentRooms = workspace:FindFirstChild("CurrentRooms")
            if currentRooms then
                for _, prompt in ipairs(currentRooms:GetDescendants()) do
                    if prompt:IsA("ProximityPrompt") then
                        modifyPrompt(prompt, Value)
                    end
                end
            end

            if Value and currentRooms then
                getgenv().ProximityConnection = currentRooms.DescendantAdded:Connect(function(descendant)
                    if descendant:IsA("ProximityPrompt") then
                        modifyPrompt(descendant, true)
                    end
                end)
            end

            WindUI:Notify("即时互动", Value and "已启用" or "已禁用", 3)
        end
    })
    B:Slider({
        Title = "既时互动范围提升",
        Value = {Min = 1, Max = 5, Default = 1},
        Suffix = "x",
        Callback = function(multiplier)
            local originalRanges = {}
            local rangeConnections = {}

            local function updateProximityPromptRanges(multiplier)
                local function modifyPrompt(prompt)
                    if not originalRanges[prompt] then
                        originalRanges[prompt] = prompt.MaxActivationDistance
                    end
                    prompt.MaxActivationDistance = originalRanges[prompt] * multiplier
                end

                for _, descendant in pairs(workspace:GetDescendants()) do
                    if descendant:IsA("ProximityPrompt") then
                        modifyPrompt(descendant)
                    end
                end
                for _, player in pairs(game.Players:GetPlayers()) do
                    if player.PlayerGui then
                        for _, descendant in pairs(player.PlayerGui:GetDescendants()) do
                            if descendant:IsA("ProximityPrompt") then
                                modifyPrompt(descendant)
                            end
                        end
                    end
                end
            end

            local function setupRangeConnections(multiplier)
                for _, connection in pairs(rangeConnections) do
                    connection:Disconnect()
                end
                rangeConnections = {}

                table.insert(rangeConnections, workspace.DescendantAdded:Connect(function(descendant)
                    if descendant:IsA("ProximityPrompt") then
                        task.wait(0.1)
                        originalRanges[descendant] = descendant.MaxActivationDistance
                        descendant.MaxActivationDistance = originalRanges[descendant] * multiplier
                    end
                end))

                for _, player in pairs(game.Players:GetPlayers()) do
                    if player.PlayerGui then
                        table.insert(rangeConnections, player.PlayerGui.DescendantAdded:Connect(function(descendant)
                            if descendant:IsA("ProximityPrompt") then
                                task.wait(0.1)
                                originalRanges[descendant] = descendant.MaxActivationDistance
                                descendant.MaxActivationDistance = originalRanges[descendant] * multiplier
                            end
                        end))
                    end
                end
            end

            if multiplier == 1 then
                for prompt, originalRange in pairs(originalRanges) do
                    if prompt and prompt.Parent then
                        prompt.MaxActivationDistance = originalRange
                    end
                end
                for _, connection in pairs(rangeConnections) do
                    connection:Disconnect()
                end
                rangeConnections = {}
            else
                updateProximityPromptRanges(multiplier)
                setupRangeConnections(multiplier)
            end

            WindUI:Notify("互动范围", "已设置为 " .. multiplier .. "x", 3)
        end
    })
    local A = Window:Tab({Title = "规避类", Icon = "shield"})
    A:Toggle({
        Title = "规避Screech",
        Default = false,
        Callback = function(on)
            if on then
                for _, inst in ipairs(workspace:GetDescendants()) do
                    if inst.Name == "Screech" then
                        pcall(function()
                            inst:Destroy()
                        end)
                    end
                end

                getgenv().AntiScreechConn = workspace.DescendantAdded:Connect(function(inst)
                    if inst.Name == "Screech" then
                        task.defer(function()
                            if inst and inst.Parent then
                                pcall(function()
                                    inst:Destroy()
                                end)
                            end
                        end)
                    end
                end)
            elseif getgenv().AntiScreechConn then
                getgenv().AntiScreechConn:Disconnect()
                getgenv().AntiScreechConn = nil
            end
        end
    })

    A:Toggle({
        Title = "规避Gloom蛋",
        Default = false,
        Callback = function(Value)
            if getgenv().AntiGloomConn then
                getgenv().AntiGloomConn:Disconnect()
                getgenv().AntiGloomConn = nil
            end

            local rooms = workspace:WaitForChild("CurrentRooms")

            if Value then
                for _, v in ipairs(rooms:GetDescendants()) do
                    if v.Name == "GloomEgg" then
                        local egg = v:FindFirstChild("Egg")
                        if egg then
                            egg.CanTouch = false
                        end
                    end
                end

                getgenv().AntiGloomConn = rooms.DescendantAdded:Connect(function(v)
                    if v.Name == "GloomEgg" then
                        local egg = v:WaitForChild("Egg", 8999999488)
                        egg.CanTouch = false
                    elseif v.Name == "Egg" and v.Parent and v.Parent.Name == "GloomEgg" then
                        v.CanTouch = false
                    end
                end)
            else
                for _, v in ipairs(rooms:GetDescendants()) do
                    if v.Name == "GloomEgg" then
                        local egg = v:FindFirstChild("Egg")
                        if egg then
                            egg.CanTouch = true
                        end
                    end
                end
            end
        end
    })

    A:Toggle({
        Title = "规避Dread",
        Default = false,
        Callback = function(isEnabled)
            local player = game:GetService("Players").LocalPlayer
            local modules = player.PlayerGui.MainUI.Initiator.Main_Game.RemoteListener.Modules
            local dreadModule = modules:FindFirstChild("Dread") or modules:FindFirstChild("_Dread")

            if dreadModule then
                dreadModule.Name = isEnabled and "_Dread" or "Dread"
            end
        end
    })

    A:Toggle({
        Title = "规避Giggle",
        Default = false,
        Callback = function(Value)
            if getgenv().AntiGiggleConn then
                getgenv().AntiGiggleConn:Disconnect()
                getgenv().AntiGiggleConn = nil
            end

            local rooms = workspace:WaitForChild("CurrentRooms")

            if Value then
                for _, v in ipairs(rooms:GetDescendants()) do
                    if v.Name == "GiggleCeiling" then
                        local hitbox = v:FindFirstChild("Hitbox")
                        if hitbox then
                            hitbox.CanTouch = false
                        end
                    end
                end

                getgenv().AntiGiggleConn = rooms.DescendantAdded:Connect(function(v)
                    if v.Name == "GiggleCeiling" then
                        local hitbox = v:WaitForChild("Hitbox", 8999999488)
                        hitbox.CanTouch = false
                    elseif v.Name == "Hitbox" and v.Parent and v.Parent.Name == "GiggleCeiling" then
                        v.CanTouch = false
                    end
                end)
            else
                for _, v in ipairs(rooms:GetDescendants()) do
                    if v.Name == "GiggleCeiling" then
                        local hitbox = v:FindFirstChild("Hitbox")
                        if hitbox then
                            hitbox.CanTouch = true
                        end
                    end
                end
            end
        end
    })

    A:Toggle({
        Title = "规避Figure听觉",
        Default = false,
        Tooltip = "让游戏认为你在蹲下",
        Callback = function(Value)
            local crouchConnection
            local ReplicatedStorage = game:GetService("ReplicatedStorage")
            local RunService = game:GetService("RunService")

            if crouchConnection then
                crouchConnection:Disconnect()
                crouchConnection = nil
            end

            if Value then
                crouchConnection = RunService.Heartbeat:Connect(function()
                    ReplicatedStorage.RemotesFolder.Crouch:FireServer(true)
                end)
            else
                ReplicatedStorage.RemotesFolder.Crouch:FireServer(false)
            end
        end
    })

    A:Toggle({
        Title = "规避Surge",
        Default = false,
        Callback = function(Value)
            if Value then
                local surgeClient = game.ReplicatedStorage:WaitForChild("FloorReplicated"):WaitForChild("ClientRemote"):FindFirstChild("SurgeClient")
                if surgeClient then
                    surgeClient:Destroy()
                end
            end
        end
    })

    A:Toggle({
        Title = "规避Halt",
        Default = false,
        Callback = function(Value)
            local entityModules = game:GetService("ReplicatedStorage"):WaitForChild("ModulesClient"):WaitForChild("EntityModules")

            if Value then
                local shade = entityModules:FindFirstChild("Shade")
                if shade and shade:IsA("ModuleScript") then
                    shade.Name = "_Shade"
                end
            else
                local shade = entityModules:FindFirstChild("_Shade")
                if shade and shade:IsA("ModuleScript") then
                    shade.Name = "Shade"
                end
            end
        end
    })

    A:Toggle({
        Title = "规避Lookman",
        Default = false,
        Callback = function(Value)
            if Value then
                if workspace:FindFirstChild("BackdoorLookman") then
                    game.ReplicatedStorage.RemotesFolder.MotorReplication:FireServer(-890)
                end
            end
        end
    })

    A:Toggle({
        Title = "规避Snare",
        Default = false,
        Callback = function(Value)
            local currentRooms = workspace:WaitForChild("CurrentRooms")

            local function handleSnare(snare)
                if snare.Name == "Snare" then
                    local hitbox = snare:FindFirstChild("Hitbox")
                    if hitbox then
                        hitbox.CanTouch = not Value
                    else
                        snare.ChildAdded:Connect(function(child)
                            if child.Name == "Hitbox" then
                                child.CanTouch = not Value
                            end
                        end)
                    end
                end
            end

            for _, v in ipairs(currentRooms:GetDescendants()) do
                handleSnare(v)
            end

            currentRooms.DescendantAdded:Connect(handleSnare)
        end
    })

    A:Toggle({
        Title = "规避Seek障碍物",
        Default = false,
        Callback = function(Value)
            local Rooms = workspace.CurrentRooms

            if Value then
                getgenv().AntiSeekObstaclesConn = Rooms.DescendantAdded:Connect(function(desc)
                    if desc.Name == "Seek_Arm" then
                        desc:WaitForChild("AnimatorPart", 8999999488)
                        desc.AnimatorPart.CanTouch = false
                        desc.AnimatorPart.Transparency = 1

                        for _, part in desc:GetDescendants() do
                            if part:IsA("BasePart") then
                                part.Transparency = 1
                            end
                        end
                    elseif desc.Name == "ChandelierObstruction" then
                        desc:WaitForChild("HurtPart", 8999999488)
                        desc.HurtPart.CanTouch = false
                        desc.HurtPart.Transparency = 1

                        for _, part in desc:GetDescendants() do
                            if part:IsA("BasePart") then
                                part.Transparency = 1
                            end
                        end
                    end
                end)

                for _, v in Rooms:GetDescendants() do
                    if v.Name == "Seek_Arm" and v:IsA("Model") then
                        v:WaitForChild("AnimatorPart", 8999999488)
                        v.AnimatorPart.CanTouch = false
                        v.AnimatorPart.Transparency = 1

                        for _, part in v:GetDescendants() do
                            if part:IsA("BasePart") then
                                part.Transparency = 1
                            end
                        end
                    elseif v.Name == "ChandelierObstruction" and v:IsA("Model") then
                        v:WaitForChild("HurtPart", 8999999488)
                        v.HurtPart.CanTouch = false
                        v.HurtPart.Transparency = 1

                        for _, part in v:GetDescendants() do
                            if part:IsA("BasePart") then
                                part.Transparency = 1
                            end
                        end
                    end
                end
            else
                if getgenv().AntiSeekObstaclesConn then
                    getgenv().AntiSeekObstaclesConn:Disconnect()
                end

                for _, v in Rooms:GetDescendants() do
                    if v.Name == "Seek_Arm" and v:IsA("Model") then
                        v:WaitForChild("AnimatorPart", 8999999488)
                        v.AnimatorPart.CanTouch = true
                        v.AnimatorPart.Transparency = 0

                        for _, part in v:GetDescendants() do
                            if part:IsA("BasePart") then
                                part.Transparency = 0
                            end
                        end
                    elseif v.Name == "ChandelierObstruction" and v:IsA("Model") then
                        v:WaitForChild("HurtPart", 8999999488)
                        v.HurtPart.CanTouch = true
                        v.HurtPart.Transparency = 0

                        for _, part in v:GetDescendants() do
                            if part:IsA("BasePart") then
                                part.Transparency = 0
                            end
                        end
                    end
                end
            end
        end
    })

    A:Toggle({
        Title = "规避Dupe门",
        Default = false,
        Callback = function(Value)
            for _, v in ipairs(workspace.CurrentRooms:GetDescendants()) do
                if v.Name == "DoorFake" then
                    v:WaitForChild("Hidden").CanTouch = not Value

                    local lock = v:FindFirstChild("Lock")
                    if lock then
                        local prompt = lock:FindFirstChildOfClass("ProximityPrompt")
                        if prompt then
                            prompt.ClickablePrompt = not Value
                        end
                    end
                end
            end
        end
    })

    A:Toggle({
        Title = "规避真空区域",
        Default = false,
        Callback = function(Value)
            for _, v in ipairs(workspace.CurrentRooms:GetDescendants()) do
                if v.Name == "SideroomSpace" then
                    for _, part in ipairs(v:GetChildren()) do
                        if part:IsA("BasePart") then
                            part.CanTouch = not Value
                            part.CanCollide = Value
                        end
                    end
                end
            end
        end
    })

    A:Toggle({
        Title = "规避Eyes",
        Default = false,
        Tooltip = "当Eyes出现时自动向下看以防止伤害",
        Callback = function(Value)
            local LocalPlayer = game.Players.LocalPlayer
            local Connections = {}

            if Value then
                Connections.AntiEyes = game:GetService("RunService").RenderStepped:Connect(function()
                    if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                        return
                    end
                    if not LocalPlayer.Character:GetAttribute("Hiding") then
                        for _, v in pairs(workspace:GetChildren()) do
                            if v.Name == "Eyes" and v:FindFirstChild("Core") and v.Core:FindFirstChild("Ambience") and v.Core.Ambience.Playing then
                                game.ReplicatedStorage.RemotesFolder.MotorReplication:FireServer(-650)
                                break
                            end
                        end
                    end
                end)
            elseif Connections.AntiEyes then
                Connections.AntiEyes:Disconnect()
                Connections.AntiEyes = nil
            end
        end
    })

    A:Toggle({
        Title = "规避A-90",
        Default = false,
        Tooltip = "移除A90",
        Callback = function(ad)
            local LocalPlayer = game.Players.LocalPlayer
            local modules = LocalPlayer.PlayerGui:FindFirstChild("MainUI") and 
                           LocalPlayer.PlayerGui.MainUI:FindFirstChild("Initiator") and 
                           LocalPlayer.PlayerGui.MainUI.Initiator:FindFirstChild("Main_Game") and 
                           LocalPlayer.PlayerGui.MainUI.Initiator.Main_Game:FindFirstChild("RemoteListener") and 
                           LocalPlayer.PlayerGui.MainUI.Initiator.Main_Game.RemoteListener:FindFirstChild("Modules")
            local c3 = modules and (modules:FindFirstChild("A90") or modules:FindFirstChild("_A90"))

            if c3 then
                c3.Name = ad and "_A90" or "A90"
            end

            local remote = (game:GetService("ReplicatedStorage"):FindFirstChild("RemotesFolder") and 
                           game:GetService("ReplicatedStorage").RemotesFolder:FindFirstChild("A90")) or 
                           game:GetService("ReplicatedStorage").RemotesFolder:FindFirstChild("_A90")

            if remote then
                remote.Name = ad and "_A90" or "A90"
            end
        end
    })
    A:Toggle({
        Title = "规避虚空效果",
        Default = false,
        Callback = function(Value)
            local ReplicatedStorage = game:GetService("ReplicatedStorage")
            local entityModules = ReplicatedStorage:FindFirstChild("ModulesClient") and 
                                 ReplicatedStorage.ModulesClient:FindFirstChild("EntityModules")

            if not entityModules then
                return
            end

            local voidModule = entityModules:FindFirstChild("Void") or entityModules:FindFirstChild("_Void")

            if not voidModule then
                return
            end

            if Value then
                if voidModule.Name == "Void" then
                    voidModule.Name = "_Void"
                end
            elseif voidModule.Name == "_Void" then
                voidModule.Name = "Void"
            end
        end
    })

    A:Toggle({
        Title = "规避Haste效果",
        Default = false,
        Callback = function(Value)
            if game.ReplicatedStorage.FloorReplicated.ClientRemote:FindFirstChild("Haste") then
                local HasteChanged = game.ReplicatedStorage.FloorReplicated.ClientRemote.Haste.Ambience:GetPropertyChangedSignal("Playing"):Connect(function()
                    if Value then
                        game.ReplicatedStorage.FloorReplicated.ClientRemote.Haste.Ambience.Playing = false
                    end
                end)
            end

            for _, v in workspace.CurrentCamera:GetChildren() do
                if v.Name == "LiveSanity" and workspace:FindFirstChild("EntityModel") then
                    v.Enabled = not Value
                end
            end
        end
    })

    A:Toggle({
        Title = "规避Firedamp",
        Default = false,
        Callback = function(Value)
            local camera = workspace:WaitForChild("Camera")
            local targets = {
                LiveSantity = true,
                LiveFiredamp = true,
            }

            local function checkAndDelete(obj)
                if targets[obj.Name] then
                    obj:Destroy()
                end
            end

            if getgenv().AntiFiredampConnection then
                getgenv().AntiFiredampConnection:Disconnect()
                getgenv().AntiFiredampConnection = nil
            end

            if Value then
                for _, child in ipairs(camera:GetChildren()) do
                    checkAndDelete(child)
                end

                getgenv().AntiFiredampConnection = camera.ChildAdded:Connect(function(child)
                    checkAndDelete(child)
                end)
            end
        end
    })

    A:Toggle({
        Title = "规避矿井氛围",
        Default = false,
        Callback = function(Value)
            local Lighting = game:GetService("Lighting")
            if Value then
                local caveAtmosphere = Lighting:FindFirstChild("CaveAtmosphere")
                if caveAtmosphere then
                    caveAtmosphere:Destroy()
                end

                local caves = Lighting:FindFirstChild("Caves")
                if caves then
                    caves:Destroy()
                end
            end
        end
    })

    A:Toggle({
        Title = "规避氧气/理智效果",
        Default = false,
        Callback = function(Value)
            local Lighting = game:GetService("Lighting")
            if Value then
                local sanity = Lighting:FindFirstChild("Sanity")
                if sanity then
                    sanity:Destroy()
                end

                local oxygenCC = Lighting:FindFirstChild("OxygenCC")
                if oxygenCC then
                    oxygenCC:Destroy()
                end

                local oxygenBlur = Lighting:FindFirstChild("OxygenBlur")
                if oxygenBlur then
                    oxygenBlur:Destroy()
                end
            end
        end
    })

    A:Toggle({
        Title = "无雾效果",
        Default = false,
        Callback = function(Value)
            local lighting = game:GetService("Lighting")
            local cave = lighting:FindFirstChild("CaveAtmosphere")

            if Value then
                if cave and cave:IsA("Atmosphere") then
                    cave.Density = 0
                else
                    lighting.FogStart = 1000000
                    lighting.FogEnd = 1000000
                end
            elseif cave and cave:IsA("Atmosphere") then
                cave.Density = 0.15
            else
                lighting.FogStart = 150
                lighting.FogEnd = 150
            end
        end
    })

    A:Toggle({
        Title = "无相机抖动",
        Default = false,
        Callback = function(Value)
            local RequiredMainGame = require(game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("MainUI"):WaitForChild("Initiator"):WaitForChild("Main_Game"))
            
            task.spawn(function()
                while Value and RequiredMainGame do
                    task.wait()
                    if typeof(RequiredMainGame.csgo) == "CFrame" then
                        RequiredMainGame.csgo = CFrame.new()
                    end
                end
            end)
        end
    })

    A:Toggle({
        Title = "无头部晃动",
        Default = false,
        Callback = function(Value)
            local RunService = game:GetService("RunService")
            local RequiredMainGame = require(game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("MainUI"):WaitForChild("Initiator"):WaitForChild("Main_Game"))

            if Value then
                if not getgenv().HeadBobDisabler then
                    getgenv().HeadBobDisabler = RunService.RenderStepped:Connect(function()
                        if RequiredMainGame and RequiredMainGame.spring then
                            if typeof(RequiredMainGame.spring.Target) == "Vector3" then
                                RequiredMainGame.spring.Target = Vector3.zero
                                RequiredMainGame.spring.Position = Vector3.zero
                            end
                        end
                    end)
                end
            elseif getgenv().HeadBobDisabler then
                getgenv().HeadBobDisabler:Disconnect()
                getgenv().HeadBobDisabler = nil
            end
        end
    })
    A:Toggle({
        Title = "无过场动画",
        Default = false,
        Callback = function(Value)
            local player = game:GetService("Players").LocalPlayer
            local RemoteListener = player.PlayerGui.MainUI.Initiator.Main_Game:WaitForChild("RemoteListener")
            local CutScenes = RemoteListener:FindFirstChild("Cutscenes") or RemoteListener:FindFirstChild("_Cutscenes")

            if not CutScenes then
                CutScenes = RemoteListener:WaitForChild("Cutscenes", 3) or RemoteListener:WaitForChild("_Cutscenes", 3)
            end

            if CutScenes then
                CutScenes.Name = Value and "_Cutscenes" or "Cutscenes"
            end
        end
    })

    A:Toggle({
        Title = "规避隐藏边缘",
        Default = false,
        Tooltip = "移除隐藏时的黑暗边缘",
        Callback = function(Value)
            local LocalPlayer = game.Players.LocalPlayer
            LocalPlayer.PlayerGui.MainUI.MainFrame.HideVignette.Image = Value and "rbxassetid://0" or "rbxassetid://6100076320"
        end
    })

   A:Toggle({
        Title = "防卡顿",
        Default = false,
        Callback = function(Value)
            local Modifiers = workspace:FindFirstChild("Modifiers")
            if Modifiers and not Modifiers:FindFirstChild("Jammin") then
                return
            end

            local mainTrack = game["SoundService"]:FindFirstChild("Main")
            if mainTrack then
                local jamming = mainTrack:FindFirstChild("Jamming")
                if jamming then
                    jamming.Enabled = not Value
                end
            end

            local mainUI = LocalPlayer:FindFirstChild("PlayerGui") and LocalPlayer.PlayerGui:FindFirstChild("MainUI")
            if mainUI then
                local healthGui = mainUI:FindFirstChild("Initiator") and 
                                 mainUI.Initiator:FindFirstChild("Main_Game") and 
                                 mainUI.Initiator.Main_Game:FindFirstChild("Health")
                if healthGui then
                    local jamSound = healthGui:FindFirstChild("Jam")
                    if jamSound then
                        jamSound.Playing = not Value
                    end
                end
            end
        end
    })
    A:Toggle({
        Title = "防香蕉皮",
        Default = false,
        Callback = function(Value)
            local currentRooms = workspace:WaitForChild("CurrentRooms")
            
            if getgenv().antiBananaConn then
                getgenv().antiBananaConn:Disconnect()
                getgenv().antiBananaConn = nil
            end

            for _, v in pairs(currentRooms:GetDescendants()) do
                if v.Name == "BananaPeel" and v:IsA("BasePart") then
                    v.CanTouch = not Value
                end
            end

            if Value then
                getgenv().antiBananaConn = currentRooms.DescendantAdded:Connect(function(v)
                    if v.Name == "BananaPeel" and v:IsA("BasePart") then
                        v.CanTouch = false
                    end
                end)
            end
        end
    })

    A:Toggle({
        Title = "防Jeff杀手",
        Default = false,
        Callback = function(Value)
            local currentRooms = workspace:WaitForChild("CurrentRooms")
            
            if getgenv().antiJeffConn then
                getgenv().antiJeffConn:Disconnect()
                getgenv().antiJeffConn = nil
            end

            for _, model in pairs(currentRooms:GetDescendants()) do
                if model.Name == "JeffTheKiller" and model:IsA("Model") then
                    for _, part in ipairs(model:GetChildren()) do
                        if part:IsA("BasePart") then
                            part.CanTouch = not Value
                        end
                    end
                end
            end

            if Value then
                getgenv().antiJeffConn = currentRooms.DescendantAdded:Connect(function(v)
                    if v.Name == "JeffTheKiller" and v:IsA("Model") then
                        for _, part in ipairs(v:GetChildren()) do
                            if part:IsA("BasePart") then
                                part.CanTouch = false
                            end
                        end
                    end
                end)
            end
        end
    })
    local ESPTab = Window:Tab({Title = "透视功能", Icon = "eye"})
local ESPLibrary = loadstring(game:HttpGet("https://raw.githubusercontent.com/mstudio45/MSESP/refs/heads/main/source.luau"))()
ESPLibrary.GlobalConfig.Distance = false
local ColorConfig = {
    ["红色"] = Color3.fromRGB(255, 0, 0),
    ["绿色"] = Color3.fromRGB(0, 255, 0),
    ["蓝色"] = Color3.fromRGB(0, 0, 255),
    ["黄色"] = Color3.fromRGB(255, 255, 0),
    ["紫色"] = Color3.fromRGB(255, 0, 255),
    ["青色"] = Color3.fromRGB(0, 255, 255),
    ["粉色"] = Color3.fromRGB(255, 182, 193),
    ["橙色"] = Color3.fromRGB(255, 165, 0),
    ["白色"] = Color3.fromRGB(255, 255, 255),
    ["彩虹动态"] = Color3.fromRGB(255, 0, 0)
}
local ESPGroup = ESPTab:Section({Title = "ESP设置[展开]", Side = "Left"})

ESPGroup:Toggle({
    Title = "启用追踪线",
    Default = false,
    Callback = function(Value)
        _G.EnableTracers = Value
        UpdateAllESP()
    end
})

ESPGroup:Toggle({
    Title = "启用方向箭头", 
    Default = false,
    Callback = function(Value)
        _G.EnableArrows = Value
        UpdateAllESP()
    end
})

ESPGroup:Dropdown({
    Title = "ESP类型",
    Values = {"高亮", "文字", "选择框"},
    Default = "高亮",
    Callback = function(Value)
        local espTypes = {
            ["高亮"] = "Highlight",
            ["文字"] = "Text", 
            ["选择框"] = "SelectionBox"
        }
        _G.ESPType = espTypes[Value]
        UpdateAllESP()
    end
})

local ObjectESPGroup = ESPTab:Section({Title = "物体透视[展开]", Side = "Left"})

local ObjectESPConfig = {
    {
        Name = "DoorESP",
        Title = "门透视",
        DefaultColor = "白色",
        Models = {"Door"},
        DisplayName = "门"
    },
    {
        Name = "ObjectiveESP", 
        Title = "目标物品透视",
        DefaultColor = "黄色",
        Models = {"KeyObtain", "FuseObtain", "LiveBreakerPolePickup"},
        DisplayName = "目标物品"
    },
    {
        Name = "CoinESP",
        Title = "金币透视",
        DefaultColor = "白色", 
        Models = {"GoldPile"},
        DisplayName = "金币"
    },
    {
        Name = "MinesGeneratorESP",
        Title = "矿洞发电机透视",
        DefaultColor = "青色",
        Models = {"MinesGenerator"},
        DisplayName = "发电机"
    },
    {
        Name = "LeverESP",
        Title = "杠杆透视",
        DefaultColor = "橙色",
        Models = {"LeverForGate"},
        DisplayName = "杠杆"
    },
    {
        Name = "ItemESP",
        Title = "所有物品透视", 
        DefaultColor = "黄色",
        Models = {
            "AlarmClock", "Aloe", "BandagePack", "Battery", "BatteryPack", "Candle",
            "Compass", "Crucifix", "Flashlight", "Glowstick", "HolyHandGrenade",
            "Lantern", "LaserPointer", "Lighter", "Lockpick", "LotusFlower", 
            "Multitool", "NVCS3000", "Shears", "SkeletonKey", "Smoothie", "Vitamins"
        },
        DisplayName = "物品"
    },
    {
        Name = "ClosetESP",
        Title = "柜子透视",
        DefaultColor = "粉色",
        Models = {"Wardrobe", "Toolshed", "Locker_Large", "Backdoor_Wardrobe"},
        DisplayName = "柜子"
    },
    {
        Name = "AnchorESP",
        Title = "锚点透视",
        DefaultColor = "粉色",
        Models = {"MinesAnchor"},
        DisplayName = "锚点"
    },
    {
        Name = "LibraryBookESP",
        Title = "图书馆书籍透视",
        DefaultColor = "青色", 
        Models = {"LiveHintBook"},
        DisplayName = "书籍"
    },
    {
        Name = "ChestESP",
        Title = "宝箱透视",
        DefaultColor = "绿色",
        Models = {"ChestBox", "ChestBoxLocked"},
        DisplayName = "宝箱"
    }
}

local EntityESPConfig = {
    {
        Name = "SeekESP",
        Title = "追逐者透视", 
        DefaultColor = "红色",
        Models = {"SeekMoving"},
        DisplayName = "追逐者"
    },
    {
        Name = "FigureESP",
        Title = "雕像透视",
        DefaultColor = "白色",
        Models = {"FigureRig"},
        DisplayName = "雕像"
    },
    {
        Name = "AmbushESP",
        Title = "伏击透视",
        DefaultColor = "白色",
        Models = {"AmbushMoving"},
        DisplayName = "伏击"
    },
    {
        Name = "RushESP", 
        Title = "冲刺透视",
        DefaultColor = "白色",
        Models = {"RushMoving"},
        DisplayName = "冲刺"
    },
    {
        Name = "SnareESP",
        Title = "陷阱透视",
        DefaultColor = "白色",
        Models = {"Snare"},
        DisplayName = "陷阱"
    },
    {
        Name = "GiggleESP",
        Title = "傻笑透视",
        DefaultColor = "白色",
        Models = {"GiggleCeiling"},
        DisplayName = "傻笑"
    },
    {
        Name = "EyestalkESP",
        Title = "眼柄透视",
        DefaultColor = "白色", 
        Models = {"EyestalkMoving"},
        DisplayName = "眼柄"
    },
    {
        Name = "MandrakeESP",
        Title = "曼德拉草透视",
        DefaultColor = "白色",
        Models = {"Mandrake"},
        DisplayName = "曼德拉草"
    },
    {
        Name = "GroundskeeperESP",
        Title = "园丁透视",
        DefaultColor = "白色",
        Models = {"Groundskeeper"},
        DisplayName = "园丁"
    },
    {
        Name = "BlitzESP",
        Title = "闪电透视",
        DefaultColor = "白色",
        Models = {"BackdoorRush"},
        DisplayName = "闪电"
    }
}

for _, config in ipairs(ObjectESPConfig) do
    ObjectESPGroup:Toggle({
        Title = config.Title,
        Default = false,
        Callback = function(Value)
            CreateESP(config.Name, Value, config.Models, config.DisplayName, _G[config.Name .. "_Color"])
        end
    })
    
    ObjectESPGroup:Dropdown({
        Title = config.Title .. "颜色",
        Values = {"红色", "绿色", "蓝色", "黄色", "紫色", "青色", "粉色", "橙色", "白色", "彩虹动态"},
        Default = config.DefaultColor,
        Callback = function(Value)
            _G[config.Name .. "_Color"] = ColorConfig[Value]
            if _G[config.Name .. "_Enabled"] then
                CreateESP(config.Name, true, config.Models, config.DisplayName, _G[config.Name .. "_Color"])
            end
        end
    })
end
local EntityESPGroup = ESPTab:Section({Title = "实体透视[展开]", Side = "Right"})
for _, config in ipairs(EntityESPConfig) do
    EntityESPGroup:Toggle({
        Title = config.Title,
        Default = false,
        Callback = function(Value)
            CreateESP(config.Name, Value, config.Models, config.DisplayName, _G[config.Name .. "_Color"])
        end
    })
    
    EntityESPGroup:Dropdown({
        Title = config.Title .. "颜色",
        Values = {"红色", "绿色", "蓝色", "黄色", "紫色", "青色", "粉色", "橙色", "白色", "彩虹动态"},
        Default = config.DefaultColor,
        Callback = function(Value)
            _G[config.Name .. "_Color"] = ColorConfig[Value]
            if _G[config.Name .. "_Enabled"] then
                CreateESP(config.Name, true, config.Models, config.DisplayName, _G[config.Name .. "_Color"])
            end
        end
    })
end
local ESPData = {}
local RainbowConnection
function CreateESP(espName, enabled, targetModels, displayName, color)
    if not enabled then
     
        if ESPData[espName] then
            for _, element in pairs(ESPData[espName].Elements) do
                if element and element.Destroy then
                    element:Destroy()
                end
            end
            
            if ESPData[espName].Connections then
                for _, conn in pairs(ESPData[espName].Connections) do
                    if conn then conn:Disconnect() end
                end
            end
            
            ESPData[espName] = nil
        end
        _G[espName .. "_Enabled"] = false
        return
    end
    
  
    _G[espName .. "_Enabled"] = true
    
    if not ESPData[espName] then
        ESPData[espName] = {
            Elements = {},
            Connections = {},
            Models = targetModels,
            DisplayName = displayName,
            Color = color or Color3.fromRGB(255, 255, 255)
        }
    else
       
        for _, element in pairs(ESPData[espName].Elements) do
            if element and element.Destroy then
                element:Destroy()
            end
        end
        ESPData[espName].Elements = {}
    end
    
    ESPData[espName].Color = color or ESPData[espName].Color
    
    local function AddESPToObject(obj)
        if not obj:IsA("Model") then return end
        
        local isValid = false
        for _, modelName in ipairs(targetModels) do
            if obj.Name == modelName then
                isValid = true
                break
            end
        end
        
        if not isValid then return end
        
        local targetPart = obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")
        if not targetPart then return end
        
     
        for _, existingElement in pairs(ESPData[espName].Elements) do
            if existingElement.Object == obj then
                return
            end
        end
        
        local espSettings = {
            Name = displayName,
            Model = targetPart,
            Color = ESPData[espName].Color,
            MaxDistance = 1000,
            TextSize = 14,
            ESPType = _G.ESPType or "Highlight",
            FillColor = ESPData[espName].Color,
            OutlineColor = ESPData[espName].Color,
            FillTransparency = 0.7,
            OutlineTransparency = 0,
            Tracer = {
                Enabled = _G.EnableTracers or false,
                Color = ESPData[espName].Color,
                From = "Bottom",
            },
            Arrow = {
                Enabled = _G.EnableArrows or false,
                Color = ESPData[espName].Color,
            },
        }
        
        local espElement = ESPLibrary:Add(espSettings)
        
        table.insert(ESPData[espName].Elements, {
            Object = obj,
            Element = espElement,
            Part = targetPart
        })
    end
    
   
    for _, obj in ipairs(workspace:GetDescendants()) do
        AddESPToObject(obj)
    end
    
   
    local addedConn = workspace.DescendantAdded:Connect(function(obj)
        if _G[espName .. "_Enabled"] then
            AddESPToObject(obj)
        end
    end)
    local removingConn = workspace.DescendantRemoving:Connect(function(obj)
        if not _G[espName .. "_Enabled"] then return end
        
        for i, elementData in ipairs(ESPData[espName].Elements) do
            if elementData.Object == obj then
                if elementData.Element and elementData.Element.Destroy then
                    elementData.Element:Destroy()
                end
                table.remove(ESPData[espName].Elements, i)
                break
            end
        end
    end)
    
 
    local updateConn = game:GetService("RunService").Heartbeat:Connect(function()
        if not _G[espName .. "_Enabled"] then
            updateConn:Disconnect()
            return
        end
        
        local player = game.Players.LocalPlayer
        local character = player and player.Character
        local rootPart = character and character:FindFirstChild("HumanoidRootPart")
        
        if not rootPart then return end
        
      
        local currentColor = ESPData[espName].Color
        if ESPData[espName].Color == ColorConfig["彩虹动态"] then
            local time = tick()
            local r = math.sin(time * 2) * 0.5 + 0.5
            local g = math.sin(time * 2 + 2) * 0.5 + 0.5  
            local b = math.sin(time * 2 + 4) * 0.5 + 0.5
            currentColor = Color3.new(r, g, b)
        end
        
        for i, elementData in ipairs(ESPData[espName].Elements) do
            if elementData.Object and elementData.Object.Parent and elementData.Part and elementData.Part.Parent then
                if elementData.Element then
                    local distance = (rootPart.Position - elementData.Part.Position).Magnitude
                    elementData.Element.CurrentSettings.Name = string.format("%s\n%d单位", displayName, math.floor(distance))
                    
                 
                    elementData.Element.CurrentSettings.Color = currentColor
                    elementData.Element.CurrentSettings.FillColor = currentColor
                    elementData.Element.CurrentSettings.OutlineColor = currentColor
                    elementData.Element.CurrentSettings.Tracer.Color = currentColor
                    elementData.Element.CurrentSettings.Arrow.Color = currentColor
                    
                 
                    elementData.Element.CurrentSettings.Tracer.Enabled = _G.EnableTracers or false
                    elementData.Element.CurrentSettings.Arrow.Enabled = _G.EnableArrows or false
                    elementData.Element.CurrentSettings.ESPType = _G.ESPType or "Highlight"
                end
            else
              
                if elementData.Element and elementData.Element.Destroy then
                    elementData.Element:Destroy()
                end
                table.remove(ESPData[espName].Elements, i)
            end
        end
    end)
    
    table.insert(ESPData[espName].Connections, addedConn)
    table.insert(ESPData[espName].Connections, removingConn) 
    table.insert(ESPData[espName].Connections, updateConn)
end
function UpdateAllESP()
    for espName, data in pairs(ESPData) do
        if _G[espName .. "_Enabled"] then
            CreateESP(espName, true, data.Models, data.DisplayName, data.Color)
        end
    end
end
for _, config in ipairs(ObjectESPConfig) do
    _G[config.Name .. "_Color"] = ColorConfig[config.DefaultColor]
end

for _, config in ipairs(EntityESPConfig) do
    _G[config.Name .. "_Color"] = ColorConfig[config.DefaultColor]
end
local function StartRainbowEffect()
    if RainbowConnection then RainbowConnection:Disconnect() end
    
    RainbowConnection = game:GetService("RunService").Heartbeat:Connect(function()
        local time = tick()
        local r = math.sin(time * 2) * 0.5 + 0.5
        local g = math.sin(time * 2 + 2) * 0.5 + 0.5
        local b = math.sin(time * 2 + 4) * 0.5 + 0.5
        
        ColorConfig["彩虹动态"] = Color3.new(r, g, b)
        for espName, data in pairs(ESPData) do
            if data.Color == ColorConfig["彩虹动态"] and _G[espName .. "_Enabled"] then
                data.Color = ColorConfig["彩虹动态"]
            end
        end
    end)
end
local function CleanupESP()
    for espName, data in pairs(ESPData) do
        for _, elementData in pairs(data.Elements) do
            if elementData.Element and elementData.Element.Destroy then
                elementData.Element:Destroy()
            end
        end
        
        for _, conn in pairs(data.Connections) do
            if conn then conn:Disconnect() end
        end
    end
    
    ESPData = {}
    
    if RainbowConnection then
        RainbowConnection:Disconnect()
        RainbowConnection = nil
    end
end
game:GetService("Players").LocalPlayer.AncestryChanged:Connect(function(_, parent)
    if not parent then
        CleanupESP()
    end
end)
StartRainbowEffect()
_G.ESPType = "Highlight"
_G.EnableTracers = false
_G.EnableArrows = false
    local NotificationTab = Window:Tab({Title = "提示", Icon = "bell"})

local EntityNotifyGroup = NotificationTab:Section({Title = "实体刷新提示[展开]", Side = "Left"})

local EntityNotifications = {
    Screech = {
        Description = "尖啸者已生成",
        Color = Color3.fromRGB(255, 255, 0)
    },
    Halt = {
        Description = "暂停实体已出现", 
        Color = Color3.fromRGB(0, 255, 255)
    },
    FigureRig = {
        Description = "检测到雕像",
        Color = Color3.fromRGB(255, 0, 0)
    },
    Eyes = {
        Description = "眼睛实体已生成",
        Color = Color3.fromRGB(127, 30, 220)
    },
    SeekMoving = {
        Description = "追逐者已生成",
        Color = Color3.fromRGB(255, 100, 100)
    },
    RushMoving = {
        Description = "冲刺正在接近",
        Color = Color3.fromRGB(0, 255, 0)
    },
    AmbushMoving = {
        Description = "伏击正在接近", 
        Color = Color3.fromRGB(80, 255, 110)
    },
    A60 = {
        Description = "A-60 正在冲刺",
        Color = Color3.fromRGB(200, 50, 50)
    },
    A120 = {
        Description = "A-120 在附近",
        Color = Color3.fromRGB(55, 55, 55)
    },
    GiggleCeiling = {
        Description = "傻笑在天花板上",
        Color = Color3.fromRGB(200, 200, 200)
    },
    GrumbleRig = {
        Description = "咕噜在巡逻",
        Color = Color3.fromRGB(150, 150, 150)
    },
    GloombatSwarm = {
        Description = "暗影蝙蝠群来袭",
        Color = Color3.fromRGB(100, 100, 100)
    },
    Dread = {
        Description = "恐惧实体已激活",
        Color = Color3.fromRGB(80, 80, 80)
    },
    BackdoorLookman = {
        Description = "观察者在注视",
        Color = Color3.fromRGB(110, 15, 15)
    },
    Snare = {
        Description = "陷阱已生成",
        Color = Color3.fromRGB(100, 100, 100)
    },
    WorldLotus = {
        Description = "检测到世界莲花",
        Color = Color3.fromRGB(200, 230, 50)
    },
    Bramble = {
        Description = "荆棘在生长",
        Color = Color3.fromRGB(50, 150, 30)
    },
    Caws = {
        Description = "乌鸦在飞行",
        Color = Color3.fromRGB(30, 30, 30)
    },
    Eyestalk = {
        Description = "眼柄将要追逐",
        Color = Color3.fromRGB(150, 80, 200)
    },
    Grampy = {
        Description = "爷爷已出现",
        Color = Color3.fromRGB(180, 180, 180)
    },
    Groundskeeper = {
        Description = "园丁在附近",
        Color = Color3.fromRGB(100, 150, 50)
    },
    Mandrake = {
        Description = "曼德拉草在尖叫",
        Color = Color3.fromRGB(130, 80, 30)
    },
    Monument = {
        Description = "纪念碑已激活",
        Color = Color3.fromRGB(150, 150, 150)
    },
    Surge = {
        Description = "浪涌在充能",
        Color = Color3.fromRGB(230, 130, 30)
    },
    BackdoorRush = {
        Description = "闪电即将到来",
        Color = Color3.fromRGB(230, 130, 30)
    }
}

local NotifyConnections = {}

EntityNotifyGroup:Toggle({
    Title = "尖啸者提示",
    Default = false,
    Callback = function(Value)
        SetupEntityNotification("Screech", Value)
    end
})

EntityNotifyGroup:Toggle({
    Title = "暂停实体提示", 
    Default = false,
    Callback = function(Value)
        SetupEntityNotification("Halt", Value)
    end
})

EntityNotifyGroup:Toggle({
    Title = "雕像提示",
    Default = false,
    Callback = function(Value)
        SetupEntityNotification("FigureRig", Value)
    end
})

EntityNotifyGroup:Toggle({
    Title = "眼睛提示",
    Default = false,
    Callback = function(Value)
        SetupEntityNotification("Eyes", Value)
    end
})

EntityNotifyGroup:Toggle({
    Title = "追逐者提示",
    Default = false,
    Callback = function(Value)
        SetupEntityNotification("SeekMoving", Value)
    end
})

EntityNotifyGroup:Toggle({
    Title = "冲刺提示",
    Default = false,
    Callback = function(Value)
        SetupEntityNotification("RushMoving", Value)
    end
})

EntityNotifyGroup:Toggle({
    Title = "伏击提示",
    Default = false,
    Callback = function(Value)
        SetupEntityNotification("AmbushMoving", Value)
    end
})

EntityNotifyGroup:Toggle({
    Title = "A-60提示",
    Default = false,
    Callback = function(Value)
        SetupEntityNotification("A60", Value)
    end
})

EntityNotifyGroup:Toggle({
    Title = "A-120提示",
    Default = false,
    Callback = function(Value)
        SetupEntityNotification("A120", Value)
    end
})

EntityNotifyGroup:Toggle({
    Title = "傻笑提示",
    Default = false,
    Callback = function(Value)
        SetupEntityNotification("GiggleCeiling", Value)
    end
})

EntityNotifyGroup:Toggle({
    Title = "咕噜提示",
    Default = false,
    Callback = function(Value)
        SetupEntityNotification("GrumbleRig", Value)
    end
})

EntityNotifyGroup:Toggle({
    Title = "暗影蝙蝠提示",
    Default = false,
    Callback = function(Value)
        SetupEntityNotification("GloombatSwarm", Value)
    end
})

EntityNotifyGroup:Toggle({
    Title = "恐惧提示",
    Default = false,
    Callback = function(Value)
        SetupEntityNotification("Dread", Value)
    end
})

EntityNotifyGroup:Toggle({
    Title = "观察者提示",
    Default = false,
    Callback = function(Value)
        SetupEntityNotification("BackdoorLookman", Value)
    end
})

EntityNotifyGroup:Toggle({
    Title = "陷阱提示",
    Default = false,
    Callback = function(Value)
        SetupEntityNotification("Snare", Value)
    end
})

EntityNotifyGroup:Toggle({
    Title = "世界莲花提示",
    Default = false,
    Callback = function(Value)
        SetupEntityNotification("WorldLotus", Value)
    end
})

EntityNotifyGroup:Toggle({
    Title = "荆棘提示",
    Default = false,
    Callback = function(Value)
        SetupEntityNotification("Bramble", Value)
    end
})

EntityNotifyGroup:Toggle({
    Title = "乌鸦提示",
    Default = false,
    Callback = function(Value)
        SetupEntityNotification("Caws", Value)
    end
})

EntityNotifyGroup:Toggle({
    Title = "眼柄提示",
    Default = false,
    Callback = function(Value)
        SetupEntityNotification("Eyestalk", Value)
    end
})

EntityNotifyGroup:Toggle({
    Title = "爷爷提示",
    Default = false,
    Callback = function(Value)
        SetupEntityNotification("Grampy", Value)
    end
})

EntityNotifyGroup:Toggle({
    Title = "园丁提示",
    Default = false,
    Callback = function(Value)
        SetupEntityNotification("Groundskeeper", Value)
    end
})

EntityNotifyGroup:Toggle({
    Title = "曼德拉草提示",
    Default = false,
    Callback = function(Value)
        SetupEntityNotification("Mandrake", Value)
    end
})

EntityNotifyGroup:Toggle({
    Title = "纪念碑提示",
    Default = false,
    Callback = function(Value)
        SetupEntityNotification("Monument", Value)
    end
})

EntityNotifyGroup:Toggle({
    Title = "浪涌提示",
    Default = false,
    Callback = function(Value)
        SetupEntityNotification("Surge", Value)
    end
})

EntityNotifyGroup:Toggle({
    Title = "闪电提示",
    Default = false,
    Callback = function(Value)
        SetupEntityNotification("BackdoorRush", Value)
    end
})

function SetupEntityNotification(entityName, enabled)
    if NotifyConnections[entityName] then
        NotifyConnections[entityName]:Disconnect()
        NotifyConnections[entityName] = nil
    end

    if not enabled then return end

    local entityData = EntityNotifications[entityName]
    if not entityData then return end

    local function onEntityAdded(obj)
        if obj.Name == entityName then
            WindUI:Notify("实体刷新", entityData.Description, 5)
        end
    end

    NotifyConnections[entityName] = workspace.ChildAdded:Connect(onEntityAdded)

    local rooms = workspace:FindFirstChild("CurrentRooms")
    if rooms then
        local roomConn = rooms.DescendantAdded:Connect(function(obj)
            if obj.Name == entityName then
                WindUI:Notify("实体刷新", entityData.Description, 5)
            end
        end)
        NotifyConnections[entityName .. "_Rooms"] = roomConn
    end
end

    end
      end
})
Section:Button({
    Title = "TY脚本-模仿者",
    Callback = function()
    
local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()
local Window = WindUI:CreateWindow({
        Title = "TY脚本<font color='#00FF00'>模仿者</font>",
        Icon = "rbxassetid://81944629903864",
        IconTransparency = 0.5,
        IconThemed = true,
        Author = "作者:权威",
        Folder = "CloudHub",
        Size = UDim2.fromOffset(400, 300),
        Transparent = true,
        Theme = "Light",
        User = {
            Enabled = true,
            Callback = function() print("clicked") end,
            Anonymous = false
        },
        SideBarWidth = 200,
        ScrollBarEnabled = true,
        Background = "rbxassetid://4155801252"
    })
    

Window:EditOpenButton({
    Title = "TY脚本-模仿者",
    Icon = "monitor",
    CornerRadius = UDim.new(0, 16),
    StrokeThickness = 2,
    Color = openButtonColor,
    Draggable = true,
})

Window:Tag({
    Title = "TY脚本",
    Color = Color3.fromHex("#30ff6a")
})

Window:Tag({
        Title = "TY脚本", -- 标签汉化
        Color = Color3.fromHex("#315dff")
    })
    local TimeTag = Window:Tag({
        Title = "模仿者",
        Color = Color3.fromHex("#000000")
    })

local Tabs = {
    Main = Window:Section({ Title = "所有关卡", Opened = true }),
    gn = Window:Section({ Title = "功能", Opened = true }),    
}

local TabHandles = {
    Q = Tabs.Main:Tab({ Title = "传送嫉妒1", Icon = "layout-grid" }),
    W = Tabs.Main:Tab({ Title = "透视功能", Icon = "layout-grid" }),
    E = Tabs.Main:Tab({ Title = "", Icon = "layout-grid" }),
    R = Tabs.Main:Tab({ Title = "", Icon = "layout-grid" }),
    T = Tabs.Main:Tab({ Title = "", Icon = "layout-grid" }),
    Y = Tabs.Main:Tab({ Title = "", Icon = "layout-grid" }),
    U = Tabs.Main:Tab({ Title = "", Icon = "layout-grid" }),    
}
-----------------------------------屋子里------------------------------------------------

local Button = TabHandles.Q:Button({
    Title = "提示",
    Desc = "第一关卡在日本屋子里",
    Image = "palette",
    ImageSize = 20,
    Color = "White"
})

Button = TabHandles.Q:Button({
    Title = "隐身怪物看不见",
    Desc = "有些关卡，一卡一卡的",
    Locked = false,
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/Yungengxin/roblox/main/yinshen"))()
            
WindUI:Notify({
    Title = "通知",
    Content = "加载成功",
    Duration = 1, -- 3 seconds
    Icon = "layout-grid",
})                        
            
 end
})

Button = TabHandles.Q:Button({
    Title = "动画房间",
    Desc = "",
    Locked = false,
    Callback = function()
            game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new( -1675.27, -23.32, -3411.01)
            
WindUI:Notify({
    Title = "通知",
    Content = "加载成功",
    Duration = 1, -- 3 seconds
    Icon = "layout-grid",
})                        
            
 end
})

Button = TabHandles.Q:Button({
    Title = "放毒老鼠地方",
    Desc = "",
    Locked = false,
    Callback = function()
            game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new( -1562.39,  -29.25,  -3403.67)
            
WindUI:Notify({
    Title = "通知",
    Content = "加载成功",
    Duration = 1, -- 3 seconds
    Icon = "layout-grid",
})                        
            
 end
})

Button = TabHandles.Q:Button({
    Title = "老鼠1",
    Desc = "",
    Locked = false,
    Callback = function()
            game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new( -1524.21,  -29.25,  -3580.63)
            
WindUI:Notify({
    Title = "通知",
    Content = "加载成功",
    Duration = 1, -- 3 seconds
    Icon = "layout-grid",
})                        
            
 end
})

Button = TabHandles.Q:Button({
    Title = "老鼠2",
    Desc = "",
    Locked = false,
    Callback = function()
            game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(-1642.97,  -23.44,  -3434.15)
            
WindUI:Notify({
    Title = "通知",
    Content = "加载成功",
    Duration = 1, -- 3 seconds
    Icon = "layout-grid",
})                        
            
 end
})

Button = TabHandles.Q:Button({
    Title = "老鼠3",
    Desc = "",
    Locked = false,
    Callback = function()
            game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new( -1680.65,  -23.47,  -3391.97)
            
WindUI:Notify({
    Title = "通知",
    Content = "加载成功",
    Duration = 1, -- 3 seconds
    Icon = "layout-grid",
})                        
            
 end
})

Button = TabHandles.Q:Button({
    Title = "老鼠4",
    Desc = "",
    Locked = false,
    Callback = function()
            game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new( -1620.64,  -23.44,  -3397.37)
            
WindUI:Notify({
    Title = "通知",
    Content = "加载成功",
    Duration = 1, -- 3 seconds
    Icon = "layout-grid",
})                        
            
 end
})

Button = TabHandles.Q:Button({
    Title = "毒老鼠老井",
    Desc = "老鼠毒放在老鼠身上的",
    Locked = false,
    Callback = function()
            game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new( -1531.34, -30.17,  -3541.97)
            
WindUI:Notify({
    Title = "通知",
    Content = "加载成功",
    Duration = 1, -- 3 seconds
    Icon = "layout-grid",
})                        
            
 end
})
-----------------------------------山坡上巨蛇------------------------------------------------

local Button = TabHandles.Q:Button({
    Title = "提示",
    Desc = "第二关卡山坡上的巨蛇",
    Image = "palette",
    ImageSize = 20,
    Color = "White"
})


Button = TabHandles.Q:Button({
    Title = "巨大蛇怪山坡秒过",
    Desc = "",
    Locked = false,
    Callback = function()
            game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new( 578.31,  567.98,  -380.59)
            
WindUI:Notify({
    Title = "通知",
    Content = "加载成功",
    Duration = 1, -- 3 seconds
    Icon = "layout-grid",
})                        
            
 end
})

Button = TabHandles.Q:Button({
    Title = "洞穴秒过",
    Desc = "",
    Locked = false,
    Callback = function()
            game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new( 3837.46,  137.13,  12.84)
            
WindUI:Notify({
    Title = "通知",
    Content = "加载成功",
    Duration = 3, -- 3 seconds
    Icon = "layout-grid",
})                        
            
 end
})
-----------------------------------村庄------------------------------------------------

local Button = TabHandles.Q:Button({
    Title = "提示",
    Desc = "第三关卡你在村庄里",
    Image = "palette",
    ImageSize = 20,
    Color = "White"
})


Button = TabHandles.Q:Button({
    Title = "传送谈话村民",
    Desc = "",
    Locked = false,
    Callback = function()
            game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new()
            
WindUI:Notify({
    Title = "通知",
    Content = "加载成功",
    Duration = 1, -- 3 seconds
    Icon = "layout-grid",
})                        
            
 end
})

Button = TabHandles.Q:Button({
    Title = "传送洞穴里",
    Desc = "",
    Locked = false,
    Callback = function()
            game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new( 343.48,  20.66,  3608.81)
            
WindUI:Notify({
    Title = "通知",
    Content = "加载成功",
    Duration = 1, -- 3 seconds
    Icon = "layout-grid",
})                        
            
 end
})

-----------------------------------透视功能------------------------------------------------

getgenv().ESPEnabled = false
getgenv().ShowBox = false
getgenv().ShowHealth = false
getgenv().ShowName = false
getgenv().ShowDistance = false
getgenv().ShowTracer = false
getgenv().TeamCheck = false
getgenv().ShowSkeleton = false
getgenv().ShowRadar = false
getgenv().ShowPlayerCount = false
getgenv().ShowWeapon = false
getgenv().ShowFOV = false
getgenv().OutOfViewArrows = false
getgenv().Chams = false

getgenv().TracerColor = Color3.new(1, 0, 0)
getgenv().SkeletonColor = Color3.new(0.2, 0.8, 1)
getgenv().BoxColor = Color3.new(1, 1, 1)
getgenv().HealthBarColor = Color3.new(0, 1, 0)
getgenv().HealthTextColor = Color3.new(1, 1, 1)
getgenv().NameColor = Color3.new(1, 1, 1)
getgenv().DistanceColor = Color3.new(1, 1, 0)
getgenv().WeaponColor = Color3.new(1, 0.5, 0)
getgenv().ArrowColor = Color3.new(1, 0, 0)
getgenv().FOVColor = Color3.new(1, 1, 1)
getgenv().ChamsColor = Color3.new(1, 0, 0)

getgenv().BoxThickness = 1
getgenv().TracerThickness = 1
getgenv().SkeletonThickness = 2
getgenv().FOVRadius = 100
getgenv().ArrowSize = 15

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

local function getGradientColor(time)
    local r = math.sin(time * 2) * 0.5 + 0.5
    local g = math.sin(time * 3) * 0.5 + 0.5
    local b = math.sin(time * 4) * 0.5 + 0.5
    return Color3.new(r, g, b)
end

local playerCountText = Drawing.new("Text")
playerCountText.Visible = false
playerCountText.Color = Color3.new(1, 1, 1)
playerCountText.Size = 20
playerCountText.Font = Drawing.Fonts.Monospace
playerCountText.Outline = true
playerCountText.OutlineColor = Color3.new(0, 0, 0)
playerCountText.Position = Vector2.new(Camera.ViewportSize.X / 2, 10)

local fovCircle = Drawing.new("Circle")
fovCircle.Visible = false
fovCircle.Color = getgenv().FOVColor
fovCircle.Thickness = 1
fovCircle.Filled = false
fovCircle.Radius = getgenv().FOVRadius
fovCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

local function updatePlayerCount()
    local playerCount = #Players:GetPlayers()
    playerCountText.Text = "在线玩家: " .. playerCount
    playerCountText.Visible = getgenv().ESPEnabled and getgenv().ShowPlayerCount

    local time = tick()
    playerCountText.Color = getGradientColor(time)
end

local function updateFOV()
    fovCircle.Visible = getgenv().ShowFOV
    fovCircle.Color = getgenv().FOVColor
    fovCircle.Radius = getgenv().FOVRadius
    fovCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
end

local ESPComponents = {}

local function createESP(player)
    local box = Drawing.new("Square")
    box.Visible = false
    box.Color = getgenv().BoxColor
    box.Thickness = getgenv().BoxThickness
    box.Filled = false

    local healthBar = Drawing.new("Square")
    healthBar.Visible = false
    healthBar.Color = getgenv().HealthBarColor
    healthBar.Thickness = 1
    healthBar.Filled = true

    local healthBarBackground = Drawing.new("Square")
    healthBarBackground.Visible = false
    healthBarBackground.Color = Color3.new(0, 0, 0)
    healthBarBackground.Transparency = 0.5
    healthBarBackground.Thickness = 1
    healthBarBackground.Filled = true

    local healthBarBorder = Drawing.new("Square")
    healthBarBorder.Visible = false
    healthBarBorder.Color = Color3.new(1, 1, 1)
    healthBarBorder.Thickness = 1
    healthBarBorder.Filled = false

    local healthText = Drawing.new("Text")
    healthText.Visible = false
    healthText.Color = getgenv().HealthTextColor
    healthText.Size = 14
    healthText.Font = Drawing.Fonts.Monospace
    healthText.Outline = true
    healthText.OutlineColor = Color3.new(0, 0, 0)

    local nameText = Drawing.new("Text")
    nameText.Visible = false
    nameText.Color = getgenv().NameColor
    nameText.Size = 16
    nameText.Font = Drawing.Fonts.Monospace
    nameText.Outline = true
    nameText.OutlineColor = Color3.new(0, 0, 0)

    local distanceText = Drawing.new("Text")
    distanceText.Visible = false
    distanceText.Color = getgenv().DistanceColor
    distanceText.Size = 14
    distanceText.Font = Drawing.Fonts.Monospace
    distanceText.Outline = true
    distanceText.OutlineColor = Color3.new(0, 0, 0)

    local weaponText = Drawing.new("Text")
    weaponText.Visible = false
    weaponText.Color = getgenv().WeaponColor
    weaponText.Size = 14
    weaponText.Font = Drawing.Fonts.Monospace
    weaponText.Outline = true
    weaponText.OutlineColor = Color3.new(0, 0, 0)

    local tracer = Drawing.new("Line")
    tracer.Visible = false
    tracer.Color = getgenv().TracerColor
    tracer.Thickness = getgenv().TracerThickness

    local arrow = Drawing.new("Triangle")
    arrow.Visible = false
    arrow.Color = getgenv().ArrowColor
    arrow.Filled = true
    arrow.Thickness = 1

    local skeletonLines = {}
    local skeletonPoints = {}

    local function createSkeleton()
        for i = 1, 15 do
            skeletonLines[i] = Drawing.new("Line")
            skeletonLines[i].Visible = false
            skeletonLines[i].Color = getgenv().SkeletonColor
            skeletonLines[i].Thickness = getgenv().SkeletonThickness
        end

        skeletonPoints["Head"] = Drawing.new("Circle")
        skeletonPoints["Head"].Visible = false
        skeletonPoints["Head"].Color = Color3.new(1, 0.5, 0)
        skeletonPoints["Head"].Thickness = 2
        skeletonPoints["Head"].Filled = true
        skeletonPoints["Head"].Radius = 4
    end

    createSkeleton()

    local lastHealth = 100
    local healthChangeTime = 0
    local smoothHealth = 100

    ESPComponents[player] = {
        box = box,
        healthBar = healthBar,
        healthBarBackground = healthBarBackground,
        healthBarBorder = healthBarBorder,
        healthText = healthText,
        nameText = nameText,
        distanceText = distanceText,
        weaponText = weaponText,
        tracer = tracer,
        arrow = arrow,
        skeletonLines = skeletonLines,
        skeletonPoints = skeletonPoints
    }

    RunService.RenderStepped:Connect(function()
        if not getgenv().ESPEnabled or not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") or not player.Character:FindFirstChild("Humanoid") or player == LocalPlayer then
            box.Visible = false
            healthBar.Visible = false
            healthBarBackground.Visible = false
            healthBarBorder.Visible = false
            healthText.Visible = false
            nameText.Visible = false
            distanceText.Visible = false
            weaponText.Visible = false
            tracer.Visible = false
            arrow.Visible = false
            for _, line in pairs(skeletonLines) do
                line.Visible = false
            end
            for _, point in pairs(skeletonPoints) do
                point.Visible = false
            end
            return
        end

        if getgenv().TeamCheck and player.Team == LocalPlayer.Team then
            box.Visible = false
            healthBar.Visible = false
            healthBarBackground.Visible = false
            healthBarBorder.Visible = false
            healthText.Visible = false
            nameText.Visible = false
            distanceText.Visible = false
            weaponText.Visible = false
            tracer.Visible = false
            arrow.Visible = false
            for _, line in pairs(skeletonLines) do
                line.Visible = false
            end
            for _, point in pairs(skeletonPoints) do
                point.Visible = false
            end
            return
        end

        local character = player.Character
        local rootPart = character:FindFirstChild("HumanoidRootPart")
        local humanoid = character:FindFirstChild("Humanoid")

        if rootPart and humanoid and humanoid.Health > 0 then
            local rootPos, onScreen = Camera:WorldToViewportPoint(rootPart.Position)
            local headPos, _ = Camera:WorldToViewportPoint(rootPart.Position + Vector3.new(0, 3, 0))
            local legPos, _ = Camera:WorldToViewportPoint(rootPart.Position - Vector3.new(0, 3, 0))

            local weaponName = "无武器"
            for _, tool in ipairs(character:GetChildren()) do
                if tool:IsA("Tool") then
                    weaponName = tool.Name
                    break
                end
            end

            if getgenv().ShowBox and onScreen then
                box.Size = Vector2.new(1000 / rootPos.Z, headPos.Y - legPos.Y)
                box.Position = Vector2.new(rootPos.X - box.Size.X / 2, rootPos.Y - box.Size.Y / 2)
                box.Visible = true
                box.Color = getgenv().BoxColor
                box.Thickness = getgenv().BoxThickness
            else
                box.Visible = false
            end

            if getgenv().ShowHealth and onScreen then
                local healthPercentage = humanoid.Health / humanoid.MaxHealth
                local barWidth = 50
                local barHeight = 5
                local barX = headPos.X - barWidth / 2
                local barY = headPos.Y - 20

                healthBarBackground.Size = Vector2.new(barWidth, barHeight)
                healthBarBackground.Position = Vector2.new(barX, barY)
                healthBarBackground.Visible = true

                healthBarBorder.Size = Vector2.new(barWidth, barHeight)
                healthBarBorder.Position = Vector2.new(barX, barY)
                healthBarBorder.Visible = true

                smoothHealth = smoothHealth + (humanoid.Health - smoothHealth) * 0.1
                local smoothHealthPercentage = smoothHealth / humanoid.MaxHealth

                healthBar.Size = Vector2.new(barWidth * smoothHealthPercentage, barHeight)
                healthBar.Position = Vector2.new(barX, barY)

                if smoothHealthPercentage >= 0.8 then
                    healthBar.Color = Color3.new(0, 1, 0)
                elseif smoothHealthPercentage >= 0.5 then
                    healthBar.Color = Color3.new(1, 1, 0)
                elseif smoothHealthPercentage >= 0.2 then
                    healthBar.Color = Color3.new(1, 0.5, 0)
                else
                    healthBar.Color = Color3.new(1, 0, 0)
                end

                healthBar.Visible = true

                if humanoid.Health ~= lastHealth then
                    healthChangeTime = tick()
                    lastHealth = humanoid.Health
                end

                if tick() - healthChangeTime < 0.5 then
                    healthBar.Color = Color3.new(1, 0, 0)
                end

                healthText.Position = Vector2.new(barX + barWidth + 5, barY - 5)
                healthText.Text = math.floor(humanoid.Health) .. "/" .. math.floor(humanoid.MaxHealth)
                healthText.Visible = true
            else
                healthBar.Visible = false
                healthBarBackground.Visible = false
                healthBarBorder.Visible = false
                healthText.Visible = false
            end

            if getgenv().ShowName and onScreen then
                nameText.Position = Vector2.new(headPos.X, headPos.Y - 35)
                nameText.Text = player.Name
                nameText.Visible = true

                if getgenv().ShowDistance then
                    local distance = (LocalPlayer.Character.HumanoidRootPart.Position - rootPart.Position).Magnitude
                    distanceText.Position = Vector2.new(headPos.X, headPos.Y + 10)
                    distanceText.Text = math.floor(distance) .. "m"
                    distanceText.Visible = true
                else
                    distanceText.Visible = false
                end
                
                if getgenv().ShowWeapon then
                    weaponText.Position = Vector2.new(headPos.X, headPos.Y - 50)
                    weaponText.Text = weaponName
                    weaponText.Visible = true
                else
                    weaponText.Visible = false
                end
            else
                nameText.Visible = false
                distanceText.Visible = false
                weaponText.Visible = false
            end

            if getgenv().ShowTracer then
                local head = character:FindFirstChild("Head")
                if head then
                    local headPos, onScreen = Camera:WorldToViewportPoint(head.Position)
                    if onScreen then
                        tracer.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                        tracer.To = Vector2.new(headPos.X, headPos.Y)
                        tracer.Visible = true
                        tracer.Color = getgenv().TracerColor
                        tracer.Thickness = getgenv().TracerThickness
                        
                        local distance = (LocalPlayer.Character.HumanoidRootPart.Position - rootPart.Position).Magnitude
                        if distance < 20 then
                            tracer.Color = Color3.new(0, 1, 0)
                        elseif distance < 50 then
                            tracer.Color = Color3.new(1, 1, 0) 
                        else
                            tracer.Color = getgenv().TracerColor 
                        end
                    else
                        tracer.Visible = false
                    end
                else
                    tracer.Visible = false
                end
            else
                tracer.Visible = false
            end

            if getgenv().OutOfViewArrows and not onScreen then
                local direction = (rootPart.Position - Camera.CFrame.Position).Unit
                local dotProduct = Camera.CFrame.RightVector:Dot(direction)
                local crossProduct = Camera.CFrame.RightVector:Cross(direction)
                
                local screenPosition = Vector2.new(
                    Camera.ViewportSize.X / 2 + dotProduct * Camera.ViewportSize.X / 3,
                    Camera.ViewportSize.Y / 2 - crossProduct.Y * Camera.ViewportSize.Y / 3
                )
                
                screenPosition = Vector2.new(
                    math.clamp(screenPosition.X, getgenv().ArrowSize, Camera.ViewportSize.X - getgenv().ArrowSize),
                    math.clamp(screenPosition.Y, getgenv().ArrowSize, Camera.ViewportSize.Y - getgenv().ArrowSize)
                )
                
                local angle = math.atan2(screenPosition.Y - Camera.ViewportSize.Y / 2, screenPosition.X - Camera.ViewportSize.X / 2)
                
                arrow.PointA = screenPosition
                arrow.PointB = Vector2.new(
                    screenPosition.X - getgenv().ArrowSize * math.cos(angle - 0.5),
                    screenPosition.Y - getgenv().ArrowSize * math.sin(angle - 0.5)
                )
                arrow.PointC = Vector2.new(
                    screenPosition.X - getgenv().ArrowSize * math.cos(angle + 0.5),
                    screenPosition.Y - getgenv().ArrowSize * math.sin(angle + 0.5)
                )
                
                arrow.Color = getgenv().ArrowColor
                arrow.Visible = true
            else
                arrow.Visible = false
            end

            if getgenv().ShowSkeleton and onScreen then
                local head = character:FindFirstChild("Head")
                local torso = character:FindFirstChild("Torso") or character:FindFirstChild("UpperTorso")
                local leftArm = character:FindFirstChild("Left Arm") or character:FindFirstChild("LeftUpperArm")
                local rightArm = character:FindFirstChild("Right Arm") or character:FindFirstChild("RightUpperArm")
                local leftLeg = character:FindFirstChild("Left Leg") or character:FindFirstChild("LeftUpperLeg")
                local rightLeg = character:FindFirstChild("Right Leg") or character:FindFirstChild("RightUpperLeg")
                
                if head and torso and leftArm and rightArm and leftLeg and rightLeg then
                    local headPos = Camera:WorldToViewportPoint(head.Position)
                    local torsoPos = Camera:WorldToViewportPoint(torso.Position)
                    local leftArmPos = Camera:WorldToViewportPoint(leftArm.Position)
                    local rightArmPos = Camera:WorldToViewportPoint(rightArm.Position)
                    local leftLegPos = Camera:WorldToViewportPoint(leftLeg.Position)
                    local rightLegPos = Camera:WorldToViewportPoint(rightLeg.Position)

                    skeletonPoints["Head"].Position = Vector2.new(headPos.X, headPos.Y)
                    skeletonPoints["Head"].Visible = true

                    skeletonLines[1].From = Vector2.new(headPos.X, headPos.Y)
                    skeletonLines[1].To = Vector2.new(torsoPos.X, torsoPos.Y) 
                    skeletonLines[1].Visible = true

                    skeletonLines[2].From = Vector2.new(torsoPos.X, torsoPos.Y)
                    skeletonLines[2].To = Vector2.new(leftArmPos.X, leftArmPos.Y)
                    skeletonLines[2].Visible = true

                    skeletonLines[3].From = Vector2.new(torsoPos.X, torsoPos.Y)
                    skeletonLines[3].To = Vector2.new(rightArmPos.X, rightArmPos.Y)
                    skeletonLines[3].Visible = true

                    skeletonLines[4].From = Vector2.new(torsoPos.X, torsoPos.Y)
                    skeletonLines[4].To = Vector2.new(leftLegPos.X, leftLegPos.Y)
                    skeletonLines[4].Visible = true

                    skeletonLines[5].From = Vector2.new(torsoPos.X, torsoPos.Y)
                    skeletonLines[5].To = Vector2.new(rightLegPos.X, rightLegPos.Y)
                    skeletonLines[5].Visible = true
                    
                    if character:FindFirstChild("LeftLowerArm") then
                        local leftLowerArmPos = Camera:WorldToViewportPoint(character.LeftLowerArm.Position)
                        skeletonLines[6].From = Vector2.new(leftArmPos.X, leftArmPos.Y)
                        skeletonLines[6].To = Vector2.new(leftLowerArmPos.X, leftLowerArmPos.Y)
                        skeletonLines[6].Visible = true
                    end

                    if character:FindFirstChild("LeftLowerLeg") then
                        local leftLowerLegPos = Camera:WorldToViewportPoint(character.LeftLowerLeg.Position)
                        skeletonLines[8].From = Vector2.new(leftLegPos.X, leftLegPos.Y)
                        skeletonLines[8].To = Vector2.new(leftLowerLegPos.X, leftLowerLegPos.Y)
                        skeletonLines[8].Visible = true
                    end

                    if character:FindFirstChild("RightLowerLeg") then
                        local rightLowerLegPos = Camera:WorldToViewportPoint(character.RightLowerLeg.Position)
                        skeletonLines[9].From = Vector2.new(rightLegPos.X, rightLegPos.Y)
                        skeletonLines[9].To = Vector2.new(rightLowerLegPos.X, rightLowerLegPos.Y)
                        skeletonLines[9].Visible = true
                    end
                else
                    for _, line in pairs(skeletonLines) do
                        line.Visible = false
                    end
                    for _, point in pairs(skeletonPoints) do
                        point.Visible = false
                    end
                end
            else
                for _, line in pairs(skeletonLines) do
                    line.Visible = false
                end
                for _, point in pairs(skeletonPoints) do
                    point.Visible = false
                end
            end
        else
            box.Visible = false
            healthBar.Visible = false
            healthBarBackground.Visible = false
            healthBarBorder.Visible = false
            healthText.Visible = false
            nameText.Visible = false
            distanceText.Visible = false
            weaponText.Visible = false
            tracer.Visible = false
            arrow.Visible = false
            for _, line in pairs(skeletonLines) do
                line.Visible = false
            end
            for _, point in pairs(skeletonPoints) do
                point.Visible = false
            end
        end
    end)
end

local radar = Drawing.new("Circle")
radar.Visible = false
radar.Color = Color3.new(1, 1, 1)
radar.Thickness = 2
radar.Filled = false
radar.Radius = 100
radar.Position = Vector2.new(Camera.ViewportSize.X - 120, 120)

local radarCenter = Drawing.new("Circle")
radarCenter.Visible = false
radarCenter.Color = Color3.new(1, 1, 1)
radarCenter.Thickness = 2
radarCenter.Filled = true
radarCenter.Radius = 3
radarCenter.Position = radar.Position

local radarDirection = Drawing.new("Line")
radarDirection.Visible = false
radarDirection.Color = Color3.new(1, 1, 1)
radarDirection.Thickness = 2

local radarGridLines = {}
for i = 1, 4 do
    radarGridLines[i] = Drawing.new("Line")
    radarGridLines[i].Visible = false
    radarGridLines[i].Color = Color3.new(0.5, 0.5, 0.5)
    radarGridLines[i].Thickness = 1
end

local radarRangeText = Drawing.new("Text")
radarRangeText.Visible = false
radarRangeText.Color = Color3.new(1, 1, 1)
radarRangeText.Size = 14
radarRangeText.Font = Drawing.Fonts.Monospace
radarRangeText.Outline = true
radarRangeText.OutlineColor = Color3.new(0, 0, 0)
radarRangeText.Text = "100m"

local radarPlayers = {}

local function updateRadar()
    if not getgenv().ShowRadar then
        radar.Visible = false
        radarCenter.Visible = false
        radarDirection.Visible = false
        radarRangeText.Visible = false
        
        for _, line in pairs(radarGridLines) do
            line.Visible = false
        end
        
        for _, player in pairs(radarPlayers) do
            if player.dot then player.dot.Visible = false end
            if player.direction then player.direction.Visible = false end
            if player.name then player.name.Visible = false end
        end
        return
    end

    radar.Visible = true
    radarCenter.Visible = true
    radarDirection.Visible = true
    radarRangeText.Visible = true
    
    radarRangeText.Position = Vector2.new(radar.Position.X, radar.Position.Y + radar.Radius + 5)
    
    for i = 1, 4 do
        local angle = (i-1) * math.pi / 2
        radarGridLines[i].From = radar.Position
        radarGridLines[i].To = Vector2.new(
            radar.Position.X + math.cos(angle) * radar.Radius,
            radar.Position.Y + math.sin(angle) * radar.Radius
        )
        radarGridLines[i].Visible = true
    end
    
    radarDirection.From = radar.Position
    radarDirection.To = Vector2.new(radar.Position.X, radar.Position.Y - radar.Radius)

    for _, player in pairs(Players:GetPlayers()) do
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player ~= LocalPlayer then
            local rootPart = player.Character.HumanoidRootPart
            local relativePosition = rootPart.Position - LocalPlayer.Character.HumanoidRootPart.Position
            
            local radarX = radar.Position.X + (relativePosition.X / 10)
            local radarY = radar.Position.Y + (relativePosition.Z / 10)
            
            local distanceFromCenter = math.sqrt((radarX - radar.Position.X)^2 + (radarY - radar.Position.Y)^2)
            
            if distanceFromCenter > radar.Radius then
                local angle = math.atan2(radarY - radar.Position.Y, radarX - radar.Position.X)
                radarX = radar.Position.X + math.cos(angle) * radar.Radius
                radarY = radar.Position.Y + math.sin(angle) * radar.Radius
            end
            
            if not radarPlayers[player] then
                radarPlayers[player] = {
                    dot = Drawing.new("Circle"),
                    direction = Drawing.new("Line"),
                    name = Drawing.new("Text")
                }
                
                radarPlayers[player].dot.Thickness = 1
                radarPlayers[player].dot.Filled = true
                radarPlayers[player].dot.Radius = 4
                
                radarPlayers[player].direction.Thickness = 2
                radarPlayers[player].direction.Visible = true
                
                radarPlayers[player].name.Size = 12
                radarPlayers[player].name.Font = Drawing.Fonts.Monospace
                radarPlayers[player].name.Outline = true
                radarPlayers[player].name.OutlineColor = Color3.new(0, 0, 0)
            end
            
            if player.Team == LocalPlayer.Team then
                radarPlayers[player].dot.Color = Color3.new(0, 1, 0)  
                radarPlayers[player].direction.Color = Color3.new(0, 0.8, 0)
                radarPlayers[player].name.Color = Color3.new(0, 1, 0)
            else
                radarPlayers[player].dot.Color = Color3.new(1, 0, 0) 
                radarPlayers[player].direction.Color = Color3.new(1, 0, 0)
                radarPlayers[player].name.Color = Color3.new(1, 0, 0)
            end
            
            radarPlayers[player].dot.Position = Vector2.new(radarX, radarY)
            radarPlayers[player].dot.Visible = true
            
            local lookVector = rootPart.CFrame.LookVector
            local directionLength = 10
            radarPlayers[player].direction.From = Vector2.new(radarX, radarY)
            radarPlayers[player].direction.To = Vector2.new(
                radarX + lookVector.X * directionLength,
                radarY + lookVector.Z * directionLength
            )
            
            radarPlayers[player].name.Position = Vector2.new(radarX, radarY - 15)
            radarPlayers[player].name.Text = player.Name
            radarPlayers[player].name.Visible = distanceFromCenter <= radar.Radius
        elseif radarPlayers[player] then
            radarPlayers[player].dot.Visible = false
            radarPlayers[player].direction.Visible = false
            radarPlayers[player].name.Visible = false
        end
    end
    
    for player, components in pairs(radarPlayers) do
        if not Players:FindFirstChild(player.Name) then
            components.dot.Visible = false
            components.direction.Visible = false
            components.name.Visible = false
            radarPlayers[player] = nil
        end
    end
end

RunService.RenderStepped:Connect(updateRadar)
RunService.RenderStepped:Connect(updatePlayerCount)
RunService.RenderStepped:Connect(updateFOV)

for _, player in pairs(Players:GetPlayers()) do
    if player ~= LocalPlayer then
        createESP(player)
    end
end

Players.PlayerAdded:Connect(function(player)
    if player ~= LocalPlayer then
        createESP(player)
    end
end)

Players.PlayerRemoving:Connect(function(player)
    if ESPComponents[player] then
        for _, component in pairs(ESPComponents[player]) do
            if typeof(component) == "table" then
                for _, drawing in pairs(component) do
                    drawing:Remove()
                end
            else
                component:Remove()
            end
        end
        ESPComponents[player] = nil
    end
end)
---------------------------------------------------------------------------------------------透视功能
Toggle = TabHandles.W:Toggle({
    Title = "透视开启", 
    Value = false, 
    Callback = function(Value)
        getgenv().ESPEnabled = Value
    end
})

Toggle = TabHandles.W:Toggle({
    Title = "模型透视", 
    Value = false, 
    Callback = function(Value)
        getgenv().ShowSkeleton = Value
    end
})

Toggle = TabHandles.W:Toggle({
    Title = "方框透视", 
    Value = false, 
    Callback = function(Value)
        getgenv().ShowBox = Value
    end
})



Toggle = TabHandles.W:Toggle({
    Title = "射线透视", 
    Value = false, 
    Callback = function(Value)
        getgenv().ShowTracer = Value
    end
})

local bulletTrackingEnabled = true  
local oldHook = nil

Toggle = TabHandles.W:Toggle({
    Title = "名字透视", 
    Value = false, 
    Callback = function(Value)
        getgenv().ShowName = Value
    end
})
      end
})
local Section = Tab:Section({
    Title = "其他",
    Opened = true
})
Section:Button({
    Title = "叶脚本",
    Callback = function()
    
loadstring(game:HttpGet("https://raw.githubusercontent.com/roblox-ye/QQ515966991/refs/heads/main/ROBLOX-CNVIP-XIAOYE.lua"))()
      end
})
Section:Button({
    Title = "无敌少侠飞行",
    Callback = function()
    
loadstring(game:HttpGet("https://rawscripts.net/raw/Universal-Script-Invinicible-Flight-R15-45414"))()
      end
})
    -- ════════════════════════════════════════════════════════════
    --  ★★★ 主脚本代码结束 ★★★
    -- ════════════════════════════════════════════════════════════
end

-- 关闭弹窗
local function closeGUI()
    local closeTween = TweenService:Create(frame, TweenInfo.new(0.25), {
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 0, 0, 0)
    })
    closeTween:Play()
    closeTween.Completed:Wait()
    screenGui:Destroy()
end

-- ★★★ 检查卡密是否在列表中 ★★★
local function checkKey(inputKey)
    for _, key in ipairs(VALID_KEYS) do
        if inputKey == key then
            return true
        end
    end
    return false
end

-- ★★★ 验证成功 ★★★
local function onSuccess()
    if verificationComplete then return end
    verificationComplete = true
    
    subtitle.Text = "✅ 验证成功！即将启动..."
    subtitle.TextColor3 = Color3.fromRGB(100, 255, 150)
    submitBtn.Text = "✅ 已激活"
    submitBtn.BackgroundColor3 = Color3.fromRGB(50, 200, 100)
    submitBtn.Active = false
    inputBox.Active = false
    closeBtn.Visible = false
    
    print("[卡密验证] ✅ 验证通过！1.5秒后执行主脚本...")
    task.wait(1.5)
    closeGUI()
    executeMainScript()
end

-- 验证失败
local function onError()
    if verificationComplete then return end
    inputBox.Text = ""
    inputBox.PlaceholderText = "❌ 卡密错误，请重试"
    inputBox.PlaceholderColor3 = Color3.fromRGB(255, 150, 150)
    subtitle.Text = "❌ 卡密无效，请重新输入"
    subtitle.TextColor3 = Color3.fromRGB(255, 150, 150)
    submitBtn.Text = "🚀 重新尝试"
    
    task.wait(1.5)
    inputBox.PlaceholderText = "在此输入卡密..."
    inputBox.PlaceholderColor3 = Color3.fromRGB(180, 180, 200)
    subtitle.Text = "请输入您的卡密以解锁功能"
    subtitle.TextColor3 = Color3.fromRGB(220, 220, 255)
    submitBtn.Text = "🚀 立即激活"
end

-- 验证流程
local function startValidation()
    if verificationComplete then return end
    local inputKey = inputBox.Text
    if inputKey == "" then
        inputBox.PlaceholderText = "⚠️ 请输入卡密"
        task.wait(1)
        inputBox.PlaceholderText = "在此输入卡密..."
        return
    end

    if checkKey(inputKey) then
        onSuccess()
    else
        onError()
    end
end

-- ==================== 事件绑定 ====================
submitBtn.MouseButton1Click:Connect(startValidation)

inputBox.FocusLost:Connect(function(enterPressed)
    if enterPressed then startValidation() end
end)

closeBtn.MouseButton1Click:Connect(function()
    if verificationComplete then return end
    verificationComplete = true
    closeGUI()
    print("[卡密验证] ⚠️ 用户手动关闭了验证弹窗，脚本终止")
end)

overlay.MouseButton1Click:Connect(function()
    if not verificationComplete then
        closeBtn.MouseButton1Click:Fire()
    end
end)

print("[卡密验证] 等待用户输入卡密...")
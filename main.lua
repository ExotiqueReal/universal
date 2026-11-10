local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Attendre le character
if not LocalPlayer.Character then
    LocalPlayer.CharacterAdded:Wait()
end

local flyEnabled = false
local noclipEnabled = false
local godEnabled = false
local infJumpEnabled = false
local aimbotEnabled = false
local espEnabled = false
local flyConn = nil
local noclipConn = nil
local aimbotConn = nil
local infJumpConn = nil
local espHighlights = {}
local walkSpeed = 60
local jumpPower = 100
local guiOpen = false
local fabDragging = false
local fabMoved = false
local fabHoldThread = nil

local C = {
    panel   = Color3.fromRGB(13, 21, 38),
    sidebar = Color3.fromRGB(11, 19, 30),
    card    = Color3.fromRGB(12, 26, 46),
    cardOn  = Color3.fromRGB(10, 42, 26),
    blue    = Color3.fromRGB(56, 189, 248),
    blueDim = Color3.fromRGB(30, 58, 95),
    text    = Color3.fromRGB(125, 211, 252),
    textDim = Color3.fromRGB(74, 122, 155),
    green   = Color3.fromRGB(34, 197, 94),
    red     = Color3.fromRGB(239, 68, 68),
    white   = Color3.new(1, 1, 1),
    black   = Color3.new(0, 0, 0),
}

-- ScreenGui avec fallback
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "UniversalScript"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
local ok = pcall(function() ScreenGui.Parent = game:GetService("CoreGui") end)
if not ok then ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end

-- =========== INTRO ===========
local IntroFrame = Instance.new("Frame")
IntroFrame.Size = UDim2.new(1, 0, 1, 0)
IntroFrame.Position = UDim2.new(0, 0, 0, 0)
IntroFrame.BackgroundColor3 = C.black
IntroFrame.BackgroundTransparency = 1
IntroFrame.ZIndex = 100
IntroFrame.Parent = ScreenGui

local IntroLabel = Instance.new("TextLabel")
IntroLabel.Size = UDim2.new(1, 0, 0, 50)
IntroLabel.Position = UDim2.new(0, 0, 0.5, -35)
IntroLabel.BackgroundTransparency = 1
IntroLabel.Text = "Universal Script"
IntroLabel.TextColor3 = C.blue
IntroLabel.TextTransparency = 1
IntroLabel.TextSize = 30
IntroLabel.Font = Enum.Font.GothamBold
IntroLabel.ZIndex = 101
IntroLabel.Parent = IntroFrame

local IntroSub = Instance.new("TextLabel")
IntroSub.Size = UDim2.new(1, 0, 0, 24)
IntroSub.Position = UDim2.new(0, 0, 0.5, 20)
IntroSub.BackgroundTransparency = 1
IntroSub.Text = "Chargement..."
IntroSub.TextColor3 = C.textDim
IntroSub.TextTransparency = 1
IntroSub.TextSize = 14
IntroSub.Font = Enum.Font.Gotham
IntroSub.ZIndex = 101
IntroSub.Parent = IntroFrame

-- =========== FAB ===========
local FABHolder = Instance.new("Frame")
FABHolder.Size = UDim2.new(0, 56, 0, 56)
FABHolder.Position = UDim2.new(1, -80, 1, -160)
FABHolder.BackgroundTransparency = 1
FABHolder.ZIndex = 50
FABHolder.Parent = ScreenGui

local FAB = Instance.new("TextButton")
FAB.Size = UDim2.new(1, 0, 1, 0)
FAB.BackgroundColor3 = C.blue
FAB.Text = "⚡"
FAB.TextSize = 24
FAB.Font = Enum.Font.GothamBold
FAB.TextColor3 = C.white
FAB.ZIndex = 51
FAB.AutoButtonColor = false
FAB.Parent = FABHolder
local fabCorner = Instance.new("UICorner")
fabCorner.CornerRadius = UDim.new(1, 0)
fabCorner.Parent = FAB
local fabStroke = Instance.new("UIStroke")
fabStroke.Color = Color3.fromRGB(100, 220, 255)
fabStroke.Thickness = 1.5
fabStroke.Parent = FAB

-- =========== PANNEAU ===========
local Panel = Instance.new("Frame")
Panel.Size = UDim2.new(1, 0, 0, 400)
Panel.Position = UDim2.new(0, 0, 1, 0)
Panel.BackgroundColor3 = C.panel
Panel.BorderSizePixel = 0
Panel.ZIndex = 10
Panel.Visible = false
Panel.Parent = ScreenGui
local panelCorner = Instance.new("UICorner")
panelCorner.CornerRadius = UDim.new(0, 20)
panelCorner.Parent = Panel

local HandleBar = Instance.new("Frame")
HandleBar.Size = UDim2.new(0, 40, 0, 4)
HandleBar.Position = UDim2.new(0.5, -20, 0, 10)
HandleBar.BackgroundColor3 = C.blueDim
HandleBar.BorderSizePixel = 0
HandleBar.Parent = Panel
local handleCorner = Instance.new("UICorner")
handleCorner.Parent = HandleBar

-- Sidebar
local Sidebar = Instance.new("Frame")
Sidebar.Size = UDim2.new(0, 68, 1, 0)
Sidebar.BackgroundColor3 = C.sidebar
Sidebar.BorderSizePixel = 0
Sidebar.ZIndex = 11
Sidebar.Parent = Panel
local sideCorner = Instance.new("UICorner")
sideCorner.CornerRadius = UDim.new(0, 20)
sideCorner.Parent = Sidebar

local CatFrame = Instance.new("Frame")
CatFrame.Size = UDim2.new(0, 54, 0, 54)
CatFrame.Position = UDim2.new(0.5, -27, 0, 24)
CatFrame.BackgroundColor3 = C.card
CatFrame.ZIndex = 12
CatFrame.Parent = Sidebar
local catCorner = Instance.new("UICorner")
catCorner.CornerRadius = UDim.new(0, 12)
catCorner.Parent = CatFrame
local catStroke = Instance.new("UIStroke")
catStroke.Color = C.blue
catStroke.Thickness = 1.5
catStroke.Parent = CatFrame

local CatIcon = Instance.new("TextLabel")
CatIcon.Size = UDim2.new(1, 0, 0, 26)
CatIcon.Position = UDim2.new(0, 0, 0, 6)
CatIcon.BackgroundTransparency = 1
CatIcon.Text = "⚡"
CatIcon.TextSize = 18
CatIcon.Font = Enum.Font.GothamBold
CatIcon.Parent = CatFrame

local CatLbl = Instance.new("TextLabel")
CatLbl.Size = UDim2.new(1, 0, 0, 14)
CatLbl.Position = UDim2.new(0, 0, 0, 32)
CatLbl.BackgroundTransparency = 1
CatLbl.Text = "Général"
CatLbl.TextColor3 = C.text
CatLbl.TextSize = 8
CatLbl.Font = Enum.Font.Gotham
CatLbl.Parent = CatFrame

local ActiveBar = Instance.new("Frame")
ActiveBar.Size = UDim2.new(0, 3, 0, 28)
ActiveBar.Position = UDim2.new(0, -1, 0.5, -14)
ActiveBar.BackgroundColor3 = C.blue
ActiveBar.BorderSizePixel = 0
ActiveBar.Parent = CatFrame
local activeCorner = Instance.new("UICorner")
activeCorner.CornerRadius = UDim.new(0, 2)
activeCorner.Parent = ActiveBar

-- Scroll
local Scroll = Instance.new("ScrollingFrame")
Scroll.Position = UDim2.new(0, 72, 0, 20)
Scroll.Size = UDim2.new(1, -78, 1, -24)
Scroll.BackgroundTransparency = 1
Scroll.ScrollBarThickness = 2
Scroll.ScrollBarImageColor3 = C.blueDim
Scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
Scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
Scroll.ZIndex = 11
Scroll.Parent = Panel

local ListLayout = Instance.new("UIListLayout")
ListLayout.Padding = UDim.new(0, 8)
ListLayout.Parent = Scroll

local ListPad = Instance.new("UIPadding")
ListPad.PaddingTop = UDim.new(0, 4)
ListPad.PaddingBottom = UDim.new(0, 10)
ListPad.Parent = Scroll

-- Header
local HeaderFrame = Instance.new("Frame")
HeaderFrame.Size = UDim2.new(1, 0, 0, 26)
HeaderFrame.BackgroundTransparency = 1
HeaderFrame.Parent = Scroll

local HeaderTitle = Instance.new("TextLabel")
HeaderTitle.Size = UDim2.new(1, -30, 1, 0)
HeaderTitle.BackgroundTransparency = 1
HeaderTitle.Text = "⚡ Général"
HeaderTitle.TextColor3 = C.text
HeaderTitle.TextSize = 13
HeaderTitle.Font = Enum.Font.GothamBold
HeaderTitle.TextXAlignment = Enum.TextXAlignment.Left
HeaderTitle.Parent = HeaderFrame

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 24, 0, 24)
CloseBtn.Position = UDim2.new(1, -24, 0, 1)
CloseBtn.BackgroundTransparency = 1
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = C.textDim
CloseBtn.TextSize = 13
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.AutoButtonColor = false
CloseBtn.Parent = HeaderFrame

-- =========== FONCTIONS ===========
local function getChar()
    return LocalPlayer.Character
end

local function makeGrid()
    local g = Instance.new("Frame")
    g.Size = UDim2.new(1, 0, 0, 80)
    g.BackgroundTransparency = 1
    g.Parent = Scroll
    local gl = Instance.new("UIGridLayout")
    gl.CellSize = UDim2.new(0.5, -4, 0, 74)
    gl.CellPaddingOffset = UDim2.new(0, 4, 0, 0)
    gl.Parent = g
    return g
end

local function makeToggle(parent, icon, name, callback)
    local btn = Instance.new("TextButton")
    btn.BackgroundColor3 = C.card
    btn.Text = ""
    btn.AutoButtonColor = false
    btn.Parent = parent

    local bc = Instance.new("UICorner"); bc.CornerRadius = UDim.new(0, 12); bc.Parent = btn
    local stroke = Instance.new("UIStroke"); stroke.Color = C.blueDim; stroke.Thickness = 1; stroke.Parent = btn

    local iL = Instance.new("TextLabel")
    iL.Size = UDim2.new(1, 0, 0, 30); iL.Position = UDim2.new(0, 0, 0, 8)
    iL.BackgroundTransparency = 1; iL.Text = icon; iL.TextSize = 20
    iL.Font = Enum.Font.GothamBold; iL.Parent = btn

    local nL = Instance.new("TextLabel")
    nL.Size = UDim2.new(1, -8, 0, 14); nL.Position = UDim2.new(0, 4, 0, 40)
    nL.BackgroundTransparency = 1; nL.Text = name; nL.TextColor3 = C.text
    nL.TextSize = 10; nL.Font = Enum.Font.Gotham; nL.Parent = btn

    local pill = Instance.new("TextLabel")
    pill.Size = UDim2.new(0, 34, 0, 14); pill.Position = UDim2.new(0.5, -17, 0, 56)
    pill.BackgroundColor3 = Color3.fromRGB(15, 42, 64); pill.Text = "OFF"
    pill.TextColor3 = C.textDim; pill.TextSize = 9; pill.Font = Enum.Font.GothamBold
    pill.Parent = btn
    local pC = Instance.new("UICorner"); pC.CornerRadius = UDim.new(1, 0); pC.Parent = pill

    local isOn = false
    btn.MouseButton1Click:Connect(function()
        isOn = not isOn
        if isOn then
            TweenService:Create(btn, TweenInfo.new(.18), {BackgroundColor3 = C.cardOn}):Play()
            TweenService:Create(stroke, TweenInfo.new(.18), {Color = C.green}):Play()
            TweenService:Create(pill, TweenInfo.new(.18), {BackgroundColor3 = Color3.fromRGB(14,64,42), TextColor3 = C.green}):Play()
            pill.Text = "ON"
        else
            TweenService:Create(btn, TweenInfo.new(.18), {BackgroundColor3 = C.card}):Play()
            TweenService:Create(stroke, TweenInfo.new(.18), {Color = C.blueDim}):Play()
            TweenService:Create(pill, TweenInfo.new(.18), {BackgroundColor3 = Color3.fromRGB(15,42,64), TextColor3 = C.textDim}):Play()
            pill.Text = "OFF"
        end
        pcall(callback, isOn)
    end)
end

local function makeSlider(icon, label, min, max, default, callback)
    local card = Instance.new("Frame")
    card.Size = UDim2.new(1, 0, 0, 52)
    card.BackgroundColor3 = C.card; card.BorderSizePixel = 0; card.Parent = Scroll
    local cc = Instance.new("UICorner"); cc.CornerRadius = UDim.new(0, 12); cc.Parent = card
    local cs = Instance.new("UIStroke"); cs.Color = C.blueDim; cs.Thickness = 1; cs.Parent = card

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(0.65, 0, 0, 18); lbl.Position = UDim2.new(0, 10, 0, 7)
    lbl.BackgroundTransparency = 1; lbl.Text = icon.." "..label
    lbl.TextColor3 = C.text; lbl.TextSize = 11; lbl.Font = Enum.Font.Gotham
    lbl.TextXAlignment = Enum.TextXAlignment.Left; lbl.Parent = card

    local valL = Instance.new("TextLabel")
    valL.Size = UDim2.new(0.3, 0, 0, 18); valL.Position = UDim2.new(0.7, -10, 0, 7)
    valL.BackgroundTransparency = 1; valL.Text = tostring(default)
    valL.TextColor3 = C.blue; valL.TextSize = 11; valL.Font = Enum.Font.GothamBold
    valL.TextXAlignment = Enum.TextXAlignment.Right; valL.Parent = card

    local track = Instance.new("Frame")
    track.Size = UDim2.new(1, -20, 0, 4); track.Position = UDim2.new(0, 10, 0, 36)
    track.BackgroundColor3 = Color3.fromRGB(30, 58, 95); track.BorderSizePixel = 0; track.Parent = card
    local tC = Instance.new("UICorner"); tC.CornerRadius = UDim.new(1, 0); tC.Parent = track

    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    fill.BackgroundColor3 = C.blue; fill.BorderSizePixel = 0; fill.Parent = track
    local fC = Instance.new("UICorner"); fC.CornerRadius = UDim.new(1, 0); fC.Parent = fill

    local thumb = Instance.new("TextButton")
    thumb.Size = UDim2.new(0, 20, 0, 20); thumb.AnchorPoint = Vector2.new(0.5, 0.5)
    thumb.Position = UDim2.new((default - min) / (max - min), 0, 0.5, 0)
    thumb.BackgroundColor3 = C.white; thumb.Text = ""
    thumb.AutoButtonColor = false; thumb.ZIndex = 15; thumb.Parent = track
    local thC = Instance.new("UICorner"); thC.CornerRadius = UDim.new(1, 0); thC.Parent = thumb

    local slDragging = false

    thumb.MouseButton1Down:Connect(function() slDragging = true end)

    game:GetService("UserInputService").InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1
        or i.UserInputType == Enum.UserInputType.Touch then
            slDragging = false
        end
    end)

    game:GetService("UserInputService").InputChanged:Connect(function(i)
        if not slDragging then return end
        if i.UserInputType ~= Enum.UserInputType.MouseMovement
        and i.UserInputType ~= Enum.UserInputType.Touch then return end
        local abs = track.AbsolutePosition
        local size = track.AbsoluteSize
        local rel = math.clamp((i.Position.X - abs.X) / size.X, 0, 1)
        local val = math.floor(min + rel * (max - min))
        fill.Size = UDim2.new(rel, 0, 1, 0)
        thumb.Position = UDim2.new(rel, 0, 0.5, 0)
        valL.Text = tostring(val)
        pcall(callback, val)
    end)
end

local function makeAction(icon, label, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 44); btn.BackgroundColor3 = C.card
    btn.Text = ""; btn.AutoButtonColor = false; btn.Parent = Scroll
    local bc = Instance.new("UICorner"); bc.CornerRadius = UDim.new(0, 12); bc.Parent = btn
    local bs = Instance.new("UIStroke"); bs.Color = C.blueDim; bs.Thickness = 1; bs.Parent = btn

    local iL = Instance.new("TextLabel")
    iL.Size = UDim2.new(0, 30, 1, 0); iL.Position = UDim2.new(0, 10, 0, 0)
    iL.BackgroundTransparency = 1; iL.Text = icon; iL.TextSize = 16
    iL.Font = Enum.Font.GothamBold; iL.Parent = btn

    local lL = Instance.new("TextLabel")
    lL.Size = UDim2.new(1, -55, 1, 0); lL.Position = UDim2.new(0, 42, 0, 0)
    lL.BackgroundTransparency = 1; lL.Text = label; lL.TextColor3 = C.text
    lL.TextSize = 12; lL.Font = Enum.Font.Gotham
    lL.TextXAlignment = Enum.TextXAlignment.Left; lL.Parent = btn

    local arr = Instance.new("TextLabel")
    arr.Size = UDim2.new(0, 20, 1, 0); arr.Position = UDim2.new(1, -24, 0, 0)
    arr.BackgroundTransparency = 1; arr.Text = "›"; arr.TextColor3 = C.blueDim
    arr.TextSize = 18; arr.Font = Enum.Font.GothamBold; arr.Parent = btn

    btn.MouseButton1Click:Connect(function()
        TweenService:Create(bs, TweenInfo.new(.15), {Color = C.blue}):Play()
        TweenService:Create(btn, TweenInfo.new(.15), {BackgroundColor3 = Color3.fromRGB(10,34,64)}):Play()
        task.delay(.3, function()
            TweenService:Create(bs, TweenInfo.new(.15), {Color = C.blueDim}):Play()
            TweenService:Create(btn, TweenInfo.new(.15), {BackgroundColor3 = C.card}):Play()
        end)
        pcall(callback)
    end)
end

-- =========== CONTENU ===========
local g1 = makeGrid()
makeToggle(g1, "🏃", "Speed", function(on)
    local c = getChar()
    if c and c:FindFirstChild("Humanoid") then
        c.Humanoid.WalkSpeed = on and walkSpeed or 16
    end
end)
makeToggle(g1, "🦘", "Jump", function(on)
    local c = getChar()
    if c and c:FindFirstChild("Humanoid") then
        c.Humanoid.JumpPower = on and jumpPower or 50
    end
end)

local g2 = makeGrid()
makeToggle(g2, "🌐", "Fly", function(on)
    flyEnabled = on
    local c = getChar(); if not c then return end
    local hrp = c:FindFirstChild("HumanoidRootPart")
    local hum = c:FindFirstChild("Humanoid")
    if not hrp or not hum then return end
    if on then
        hum.PlatformStand = true
        local bv = Instance.new("BodyVelocity"); bv.Name = "FlyVel"
        bv.Velocity = Vector3.zero; bv.MaxForce = Vector3.new(1e5,1e5,1e5); bv.Parent = hrp
        local bg = Instance.new("BodyGyro"); bg.Name = "FlyGyro"
        bg.MaxTorque = Vector3.new(1e5,1e5,1e5); bg.P = 1e4; bg.Parent = hrp
        flyConn = RunService.RenderStepped:Connect(function()
            if not flyEnabled then return end
            local d = Vector3.zero
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then d = d + Camera.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then d = d - Camera.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then d = d - Camera.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then d = d + Camera.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then d = d + Vector3.new(0,1,0) end
            bv.Velocity = d * 50; bg.CFrame = Camera.CFrame
        end)
    else
        hum.PlatformStand = false
        if flyConn then flyConn:Disconnect(); flyConn = nil end
        if hrp:FindFirstChild("FlyVel") then hrp.FlyVel:Destroy() end
        if hrp:FindFirstChild("FlyGyro") then hrp.FlyGyro:Destroy() end
    end
end)

makeToggle(g2, "👻", "Noclip", function(on)
    noclipEnabled = on
    if on then
        noclipConn = RunService.Stepped:Connect(function()
            local c = getChar()
            if c then
                for _, p in pairs(c:GetDescendants()) do
                    if p:IsA("BasePart") then p.CanCollide = false end
                end
            end
        end)
    else
        if noclipConn then noclipConn:Disconnect(); noclipConn = nil end
    end
end)

local g3 = makeGrid()
makeToggle(g3, "❤️", "God mode", function(on)
    local c = getChar()
    if c and c:FindFirstChild("Humanoid") then
        c.Humanoid.MaxHealth = on and math.huge or 100
        c.Humanoid.Health = on and math.huge or 100
    end
end)
makeToggle(g3, "👁️", "ESP", function(on)
    espEnabled = on
    if on then
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character then
                local h = Instance.new("Highlight")
                h.FillColor = Color3.fromRGB(255, 0, 0)
                h.OutlineColor = C.white
                h.FillTransparency = 0.5
                h.Parent = p.Character
                espHighlights[p.Name] = h
            end
        end
    else
        for _, h in pairs(espHighlights) do h:Destroy() end
        espHighlights = {}
    end
end)

local g4 = makeGrid()
makeToggle(g4, "♾️", "Inf jump", function(on)
    if on then
        infJumpConn = UserInputService.JumpRequest:Connect(function()
            local c = getChar()
            if c and c:FindFirstChild("Humanoid") then
                c.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end)
    else
        if infJumpConn then infJumpConn:Disconnect(); infJumpConn = nil end
    end
end)
makeToggle(g4, "🎯", "Aimbot", function(on)
    aimbotEnabled = on
    if on then
        aimbotConn = RunService.RenderStepped:Connect(function()
            if not aimbotEnabled then return end
            local closest, target = math.huge, nil
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and p.Character then
                    local head = p.Character:FindFirstChild("Head")
                    if head then
                        local sp, vis = Camera:WorldToScreenPoint(head.Position)
                        if vis then
                            local center = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
                            local d = (Vector2.new(sp.X, sp.Y) - center).Magnitude
                            if d < closest then closest = d; target = head end
                        end
                    end
                end
            end
            if target and closest < 200 then
                Camera.CFrame = CFrame.lookAt(Camera.CFrame.Position, target.Position)
            end
        end)
    else
        if aimbotConn then aimbotConn:Disconnect(); aimbotConn = nil end
    end
end)

makeSlider("🏃", "WalkSpeed", 16, 200, 60, function(v)
    walkSpeed = v
    local c = getChar()
    if c and c:FindFirstChild("Humanoid") then c.Humanoid.WalkSpeed = v end
end)

makeSlider("🦘", "JumpPower", 50, 300, 100, function(v)
    jumpPower = v
    local c = getChar()
    if c a

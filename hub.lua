local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
    Name = "Beta Cheese",
    Icon = 0, -- Icon in Topbar. Can use Lucide Icons (string) or Roblox Image (number). 0 to use no icon (default).
    LoadingTitle = "Booting Scripts",
    LoadingSubtitle = "by GiltyKat",
    Theme = "DarkBlue", -- Check https://docs.sirius.menu/rayfield/configuration/themes
 
    DisableRayfieldPrompts = false,
    DisableBuildWarnings = false, -- Prevents Rayfield from warning when the script has a version mismatch with the interface
 
    ConfigurationSaving = {
       Enabled = true,
       FolderName = Minhub, -- Create a custom folder for your hub/game
       FileName = "Min Hub"
    },
 
    Discord = {
       Enabled = false, -- Prompt the user to join your Discord server if their executor supports it
       Invite = "noinvitelink", -- The Discord invite code, do not include discord.gg/. E.g. discord.gg/ABCD would be ABCD
       RememberJoins = true -- Set this to false to make them join the discord every time they load it up
    },
 
    KeySystem = true, -- Set this to true to use our key system
    KeySettings = {
       Title = "Security Init",
       Subtitle = "Key System",
       Note = "No method of obtaining the key is provided", -- Use this to tell the user how to get a key
       FileName = "Key", -- It is recommended to use something unique as other scripts using Rayfield may overwrite your key file
       SaveKey = true, -- The user's key will be saved, but if you change the key, they will be unable to use your script
       GrabKeyFromSite = false, -- If this is true, set Key below to the RAW site you would like Rayfield to get the key from
       Key = {"1234"} -- List of keys that will be accepted by the system, can be RAW file links (pastebin, github etc) or simple strings ("hello","key22")
    }
 })

 local vis = Window:CreateTab("Visuals", "view") -- Title, Image
 local aim = Window:CreateTab("Aim", "crosshair") -- Title, Image
 local con = Window:CreateTab("Config", "view") -- Title, Image
 local mis = Window:CreateTab("Misc", "chevron-last") -- Title, Image
 local wor = Window:CreateTab("World", "earth") -- Title, Image

 local Toggle = vis:CreateToggle({
    Name = "Skeleton Esp",
    CurrentValue = false,
    Flag = "Toggle1", -- A flag is the identifier for the configuration file, make sure every element has a different flag if you're using configuration saving to ensure no overlaps
    Callback = function(Value)
-- Universal Bones ESP with Proper Rotation and Length
-- This script ensures ESP lines match the exact rotation and length of limbs.

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

-- Variables
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local DrawingLines = {}

-- Function to create a line
local function createLine()
    local line = Drawing.new("Line")
    line.Visible = false
    line.Color = Color3.new(1, 0, 0) -- Red
    line.Thickness = 2
    return line
end

-- Function to update lines for a single player
local function updatePlayerESP(player)
    if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 then
        local character = player.Character
        local bodyParts = {
            Head = character:FindFirstChild("Head"),
            Torso = character:FindFirstChild("UpperTorso") or character:FindFirstChild("Torso"),
            LeftArm = character:FindFirstChild("LeftUpperArm") or character:FindFirstChild("Left Arm"),
            RightArm = character:FindFirstChild("RightUpperArm") or character:FindFirstChild("Right Arm"),
            LeftLeg = character:FindFirstChild("LeftUpperLeg") or character:FindFirstChild("Left Leg"),
            RightLeg = character:FindFirstChild("RightUpperLeg") or character:FindFirstChild("Right Leg"),
        }

        local bones = {
            {bodyParts.Head, bodyParts.Torso},
            {bodyParts.Torso, bodyParts.LeftArm},
            {bodyParts.Torso, bodyParts.RightArm},
            {bodyParts.Torso, bodyParts.LeftLeg},
            {bodyParts.Torso, bodyParts.RightLeg},
        }

        for index, bone in ipairs(bones) do
            local part1, part2 = bone[1], bone[2]
            local line = DrawingLines[player.Name .. index] or createLine()
            DrawingLines[player.Name .. index] = line

            if part1 and part2 then
                -- Calculate the midpoint of the limb for more accuracy
                local part1Pos, part1Visible = Camera:WorldToViewportPoint(part1.Position)
                local part2Pos, part2Visible = Camera:WorldToViewportPoint(part2.Position)

                if part1Visible and part2Visible then
                    line.Visible = true
                    line.From = Vector2.new(part1Pos.X, part1Pos.Y)
                    line.To = Vector2.new(part2Pos.X, part2Pos.Y)
                else
                    line.Visible = false
                end
            else
                line.Visible = false
            end
        end
    else
        -- Hide lines if player is invalid
        for index = 1, 5 do
            local line = DrawingLines[player.Name .. index]
            if line then
                line.Visible = false
            end
        end
    end
end

-- Function to update ESP for all players
local function updateESP()
    for _, player in ipairs(Players:GetPlayers()) do
        updatePlayerESP(player)
    end
end

-- Clean up lines when player leaves
Players.PlayerRemoving:Connect(function(player)
    for index = 1, 5 do
        local line = DrawingLines[player.Name .. index]
        if line then
            line:Remove()
            DrawingLines[player.Name .. index] = nil
        end
    end
end)

-- Run the ESP update
RunService.RenderStepped:Connect(updateESP)

    end,
 })

 local Toggle = vis:CreateToggle({
    Name = "Snaplines",
    CurrentValue = false,
    Flag = "Toggle2", -- A flag is the identifier for the configuration file, make sure every element has a different flag if you're using configuration saving to ensure no overlaps
    Callback = function(Value)
-- Universal Snapline ESP
-- Draws a line from the bottom-middle of the screen to each player dynamically.

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

-- Variables
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local DrawingLines = {}

-- Function to create a line
local function createLine()
    local line = Drawing.new("Line")
    line.Visible = false
    line.Color = Color3.new(0, 1, 0) -- Green
    line.Thickness = 2
    return line
end

-- Function to update Snapline for a player
local function updatePlayerSnapline(player)
    if player == LocalPlayer or not player.Character or not player.Character:FindFirstChild("Humanoid") then
        return
    end

    local character = player.Character
    local humanoid = character:FindFirstChild("Humanoid")

    -- Skip players with no health
    if humanoid.Health <= 0 then
        return
    end

    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not rootPart then
        return
    end

    local line = DrawingLines[player.Name] or createLine()
    DrawingLines[player.Name] = line

    -- Get the player's position on the screen
    local rootPosition, visible = Camera:WorldToViewportPoint(rootPart.Position)

    -- Get the bottom middle of the screen
    local screenSize = Camera.ViewportSize
    local bottomMiddle = Vector2.new(screenSize.X / 2, screenSize.Y)

    if visible then
        line.Visible = true
        line.From = bottomMiddle
        line.To = Vector2.new(rootPosition.X, rootPosition.Y)
    else
        line.Visible = false
    end
end

-- Function to update Snaplines for all players
local function updateSnaplines()
    for _, player in ipairs(Players:GetPlayers()) do
        updatePlayerSnapline(player)
    end
end

-- Clean up lines when a player leaves
Players.PlayerRemoving:Connect(function(player)
    local line = DrawingLines[player.Name]
    if line then
        line:Remove()
        DrawingLines[player.Name] = nil
    end
end)

-- Render update
RunService.RenderStepped:Connect(updateSnaplines)

    end,
 })

 local Toggle = vis:CreateToggle({
    Name = "Radar",
    CurrentValue = false,
    Flag = "Toggle3", -- A flag is the identifier for the configuration file, make sure every element has a different flag if you're using configuration saving to ensure no overlaps
    Callback = function(Value)
-- Universal Radar ESP
-- Creates a top-down radar displaying player positions relative to the local player.

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

-- Variables
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local RadarRadius = 100 -- Radius of the radar in pixels
local RadarCenter = Vector2.new(200, 200) -- Center of the radar on the screen
local RadarScale = 1 / 10 -- Scale for converting world distances to radar distances
local RadarDots = {}

-- Function to create a radar dot
local function createDot()
    local dot = Drawing.new("Circle")
    dot.Visible = false
    dot.Color = Color3.new(1, 0, 0) -- Red
    dot.Radius = 3
    dot.Filled = true
    return dot
end

-- Function to update radar for a player
local function updatePlayerRadar(player)
    if player == LocalPlayer or not player.Character or not player.Character:FindFirstChild("Humanoid") then
        return
    end

    local character = player.Character
    local humanoid = character:FindFirstChild("Humanoid")

    -- Skip players with no health
    if humanoid.Health <= 0 then
        return
    end

    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not rootPart then
        return
    end

    local dot = RadarDots[player.Name] or createDot()
    RadarDots[player.Name] = dot

    -- Calculate the position of the player relative to the local player
    local localRootPart = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not localRootPart then
        dot.Visible = false
        return
    end

    local relativePosition = rootPart.Position - localRootPart.Position
    local radarPosition = Vector2.new(relativePosition.X, relativePosition.Z) * RadarScale

    -- Check if the player is within the radar radius
    if radarPosition.Magnitude <= RadarRadius then
        dot.Visible = true
        dot.Position = RadarCenter + radarPosition
    else
        dot.Visible = false
    end
end

-- Function to update radar for all players
local function updateRadar()
    for _, player in ipairs(Players:GetPlayers()) do
        updatePlayerRadar(player)
    end
end

-- Clean up dots when a player leaves
Players.PlayerRemoving:Connect(function(player)
    local dot = RadarDots[player.Name]
    if dot then
        dot:Remove()
        RadarDots[player.Name] = nil
    end
end)

-- Radar Border
local radarBorder = Drawing.new("Circle")
radarBorder.Visible = true
radarBorder.Color = Color3.new(0, 1, 0) -- Green
radarBorder.Thickness = 2
radarBorder.Filled = false
radarBorder.Position = RadarCenter
radarBorder.Radius = RadarRadius

-- Render update
RunService.RenderStepped:Connect(function()
    updateRadar()
end)

    end,
 })

 local Toggle = vis:CreateToggle({
    Name = "Tool Esp",
    CurrentValue = false,
    Flag = "Toggle4", -- A flag is the identifier for the configuration file, make sure every element has a different flag if you're using configuration saving to ensure no overlaps
    Callback = function(Value)
-- Tool ESP
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local ToolESPTexts = {}

local function createText()
    local text = Drawing.new("Text")
    text.Visible = false
    text.Size = 20
    text.Color = Color3.new(1, 1, 0) -- Yellow
    text.Center = true
    return text
end

local function updateToolESP(player)
    if player == Players.LocalPlayer or not player.Character then
        return
    end

    local character = player.Character
    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    local tool = player:FindFirstChildOfClass("Backpack") or character:FindFirstChildOfClass("Tool")

    local text = ToolESPTexts[player.Name] or createText()
    ToolESPTexts[player.Name] = text

    if humanoidRootPart and tool then
        local screenPosition, visible = Camera:WorldToViewportPoint(humanoidRootPart.Position)
        if visible then
            text.Visible = true
            text.Text = tool.Name
            text.Position = Vector2.new(screenPosition.X, screenPosition.Y - 20)
        else
            text.Visible = false
        end
    else
        text.Visible = false
    end
end

RunService.RenderStepped:Connect(function()
    for _, player in ipairs(Players:GetPlayers()) do
        updateToolESP(player)
    end
end)

Players.PlayerRemoving:Connect(function(player)
    if ToolESPTexts[player.Name] then
        ToolESPTexts[player.Name]:Remove()
        ToolESPTexts[player.Name] = nil
    end
end)

    end,
 })

 local Toggle = vis:CreateToggle({
    Name = "Name esp",
    CurrentValue = false,
    Flag = "Toggle5", -- A flag is the identifier for the configuration file, make sure every element has a different flag if you're using configuration saving to ensure no overlaps
    Callback = function(Value)
-- Name ESP
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local NameESPTexts = {}

local function createText()
    local text = Drawing.new("Text")
    text.Visible = false
    text.Size = 20
    text.Color = Color3.new(1, 1, 1) -- White
    text.Center = true
    return text
end

local function updateNameESP(player)
    if player == Players.LocalPlayer or not player.Character then
        return
    end

    local character = player.Character
    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

    local text = NameESPTexts[player.Name] or createText()
    NameESPTexts[player.Name] = text

    if humanoidRootPart then
        local screenPosition, visible = Camera:WorldToViewportPoint(humanoidRootPart.Position)
        if visible then
            text.Visible = true
            text.Text = player.Name
            text.Position = Vector2.new(screenPosition.X, screenPosition.Y - 40)
        else
            text.Visible = false
        end
    else
        text.Visible = false
    end
end

RunService.RenderStepped:Connect(function()
    for _, player in ipairs(Players:GetPlayers()) do
        updateNameESP(player)
    end
end)

Players.PlayerRemoving:Connect(function(player)
    if NameESPTexts[player.Name] then
        NameESPTexts[player.Name]:Remove()
        NameESPTexts[player.Name] = nil
    end
end)

    end,
 })

 local Toggle = vis:CreateToggle({
    Name = "Health Esp",
    CurrentValue = false,
    Flag = "Toggle6", -- A flag is the identifier for the configuration file, make sure every element has a different flag if you're using configuration saving to ensure no overlaps
    Callback = function(Value)
-- Health ESP
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local HealthESPTexts = {}

local function createText()
    local text = Drawing.new("Text")
    text.Visible = false
    text.Size = 20
    text.Color = Color3.new(0, 1, 0) -- Green
    text.Center = true
    return text
end

local function updateHealthESP(player)
    if player == Players.LocalPlayer or not player.Character then
        return
    end

    local character = player.Character
    local humanoid = character:FindFirstChild("Humanoid")
    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

    local text = HealthESPTexts[player.Name] or createText()
    HealthESPTexts[player.Name] = text

    if humanoid and humanoidRootPart then
        local screenPosition, visible = Camera:WorldToViewportPoint(humanoidRootPart.Position)
        if visible then
            text.Visible = true
            text.Text = tostring(math.floor(humanoid.Health)) .. " HP"
            text.Position = Vector2.new(screenPosition.X, screenPosition.Y - 60)
        else
            text.Visible = false
        end
    else
        text.Visible = false
    end
end

RunService.RenderStepped:Connect(function()
    for _, player in ipairs(Players:GetPlayers()) do
        updateHealthESP(player)
    end
end)

Players.PlayerRemoving:Connect(function(player)
    if HealthESPTexts[player.Name] then
        HealthESPTexts[player.Name]:Remove()
        HealthESPTexts[player.Name] = nil
    end
end)

    end,
 })

 local Paragraph = aim:CreateParagraph({Title = "!Important!", Content = "Set your configaration before you start the aimbot"})

 local Toggle = aim:CreateToggle({
    Name = "Aimbot",
    CurrentValue = false,
    Flag = "Toggle7", -- A flag is the identifier for the configuration file, make sure every element has a different flag if you're using configuration saving to ensure no overlaps
    Callback = function(Value)
       local Players = game:GetService("Players")
       local Players = game:GetService("Players")
       local RunService = game:GetService("RunService")
       local UserInputService = game:GetService("UserInputService")
       local Camera = workspace.CurrentCamera
       
       -- Settings
       local AimbotSettings = {
           FOV = editfov, -- Size of the Field of View
           Smoothness = smoothness, -- Smoothness factor (0 is instant, higher is slower)
           AimKey = Enum.UserInputType.MouseButton2, -- Right Mouse Button to aim
           FOVColor = Color3.new(1, 0, 0), -- Red
           FOVTransparency = 0.5, -- Transparency of the FOV circle
           FOVVisible = 1, -- Set to 1 to draw the FOV, 0 to hide it
       }
       
       -- Variables
       local FOVCircle = Drawing.new("Circle")
       local AimingAt = nil
       local IsAiming = false
       
       -- Initialize the FOV circle
       FOVCircle.Visible = (AimbotSettings.FOVVisible == 1)
       FOVCircle.Color = AimbotSettings.FOVColor
       FOVCircle.Thickness = 2
       FOVCircle.Transparency = AimbotSettings.FOVTransparency
       FOVCircle.Radius = AimbotSettings.FOV
       FOVCircle.Filled = false
       
       -- Function to find the closest player within the FOV
       local function getClosestPlayer()
           local closestPlayer = nil
           local shortestDistance = AimbotSettings.FOV
       
           for _, player in ipairs(Players:GetPlayers()) do
               if player ~= Players.LocalPlayer and player.Character and player.Character:FindFirstChild("Head") then
                   local head = player.Character.Head
                   local screenPos, onScreen = Camera:WorldToViewportPoint(head.Position)
       
                   if onScreen then
                       local mousePos = UserInputService:GetMouseLocation()
                       local distance = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
       
                       if distance < shortestDistance then
                           closestPlayer = player
                           shortestDistance = distance
                       end
                   end
               end
           end
       
           return closestPlayer
       end
       
       -- Function to smoothly aim at a target's head
       local function aimAt(target)
           if not target or not target.Character or not target.Character:FindFirstChild("Head") then
               return
           end
       
           local head = target.Character.Head
           local targetPos = Camera:WorldToViewportPoint(head.Position)
           local mousePos = UserInputService:GetMouseLocation()
       
           -- Calculate smooth aim movement
           local deltaX = (targetPos.X - mousePos.X) * AimbotSettings.Smoothness
           local deltaY = (targetPos.Y - mousePos.Y) * AimbotSettings.Smoothness
       
           -- Move the mouse smoothly
           mousemoverel(deltaX, deltaY)
       end
       
       -- Update FOV circle position
       RunService.RenderStepped:Connect(function()
           local mousePos = UserInputService:GetMouseLocation()
           FOVCircle.Position = mousePos
           
           -- Constantly update FOV circle radius based on the FOV setting
           if FOVCircle.Radius ~= AimbotSettings.FOV then
               FOVCircle.Radius = AimbotSettings.FOV
           end
       end)
       
       -- Main aimbot loop
       RunService.RenderStepped:Connect(function()
           if IsAiming then
               if not AimingAt or not AimingAt.Character or not AimingAt.Character:FindFirstChild("Head") then
                   AimingAt = getClosestPlayer()
               end
       
               if AimingAt then
                   aimAt(AimingAt)
               end
           else
               AimingAt = nil
           end
       end)
       
       -- Listen for aim key
       UserInputService.InputBegan:Connect(function(input)
           if input.UserInputType == AimbotSettings.AimKey then
               IsAiming = true
           end
       end)
       
       UserInputService.InputEnded:Connect(function(input)
           if input.UserInputType == AimbotSettings.AimKey then
               IsAiming = false
           end
       end)
       
       -- Toggle FOV visibility based on settings
       FOVCircle.Visible = (AimbotSettings.FOVVisible == 1)
       

        
    end,
 })

 


-- Global variable to store the smoothing value
editfov = 60  -- This is now a global variable

-- Slider to control the aimbot smoothing
local Slider = con:CreateSlider({
    Name = "Aimbot Fov",
    Range = {10, 300},
    Increment = 1,
    Suffix = "degrees",
    CurrentValue = 60,
    Flag = "Slider1", -- A flag is the identifier for the configuration file, make sure every element has a different flag if you're using configuration saving to ensure no overlaps
    Callback = function(Value)
        -- Update the global variable `smoothness` whenever the slider changes
        editfov = Value
        print("Smoothness updated to:", smoothness)  -- Optional: Print the new value for debugging
    end,
})


smoothness = 1
-- Slider for Smoothness
local SmoothnessSlider = con:CreateSlider({
    Name = "Aimbot Smoothness",
    Range = {0.9, 1},  -- Smoothness range from 0 (instant) to 1 (slower)
    Increment = 0.01,  -- Small increment to adjust smoothness
    Suffix = "Higher is faster",  -- Label for the value
    CurrentValue = 1,  -- Default value from aimbot settings
    Flag = "Slider2",  -- Identifier for saving configuration
    Callback = function(Value)
        -- Update the smoothness setting based on slider value
        smoothness = Value
    end,
})


 local Toggle = mis:CreateToggle({
    Name = "Wireframe World [Partially Broken]",
    CurrentValue = false,
    Flag = "Toggle8", -- A flag is the identifier for the configuration file, make sure every element has a different flag if you're using configuration saving to ensure no overlaps
    Callback = function(Value)
        local Players = game:GetService("Players")
        local RunService = game:GetService("RunService")
        local UserInputService = game:GetService("UserInputService")
        
        -- Variable to store the toggle state
        local wireframeEnabled = false
        
        -- Function to draw wireframe on parts
        local function drawWireframeOnPart(part)
            -- Ensure the part is valid and is a BasePart
            if part:IsA("BasePart") and part.Parent then
                local boundingBox = part:GetBoundingBox()
                local topLeftFront = boundingBox[1]
                local bottomRightBack = boundingBox[2]
                
                -- Create Drawing objects for each corner of the part (create lines between them)
                local drawing = Drawing.new("Line")
                drawing.Color = Color3.new(1, 1, 1) -- Wireframe color (white)
                drawing.Thickness = 2
                drawing.Transparency = 1
                
                -- Example: draw lines between bounding box corners (adjust as needed)
                -- You can use part.CFrame to convert world positions to screen space (viewport)
                local screenPos1, onScreen1 = workspace.CurrentCamera:WorldToViewportPoint(topLeftFront)
                local screenPos2, onScreen2 = workspace.CurrentCamera:WorldToViewportPoint(bottomRightBack)
                
                -- Check if positions are on screen
                if onScreen1 and onScreen2 then
                    drawing.From = Vector2.new(screenPos1.X, screenPos1.Y)
                    drawing.To = Vector2.new(screenPos2.X, screenPos2.Y)
                    drawing.Visible = true
                else
                    drawing.Visible = false
                end
        
                -- Clean up Drawing object after use
                RunService.RenderStepped:Connect(function()
                    drawing.Visible = wireframeEnabled
                end)
            end
        end
        
        -- Function to toggle wireframe effect on and off
        local function toggleWireframe()
            wireframeEnabled = not wireframeEnabled
            
            -- Toggle wireframe visibility on parts
            if wireframeEnabled then
                -- Loop through all parts and apply the wireframe effect (once per toggle)
                for _, obj in ipairs(workspace:GetDescendants()) do
                    if obj:IsA("BasePart") then
                        drawWireframeOnPart(obj)
                    end
                end
            end
        end
        
        -- Listen for user input to toggle wireframe effect (e.g., pressing 'W' key)
        UserInputService.InputBegan:Connect(function(input, gameProcessed)
            if gameProcessed then return end
        
            if input.KeyCode == Enum.KeyCode.W then -- Change key as needed
                toggleWireframe()
            end
        end)
        
    end,
 })

 local Toggle = vis:CreateToggle({
    Name = "Npc Snaplines",
    CurrentValue = false,
    Flag = "Toggle9", -- A flag is the identifier for the configuration file, make sure every element has a different flag if you're using configuration saving to ensure no overlaps
    Callback = function(Value)
-- Place this script in a LocalScript (e.g., StarterPlayerScripts).
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local Camera = Workspace.CurrentCamera

-- Function to create a BillboardGui for displaying name and distance
local function createInfoLabel(object)
    local billboardGui = Instance.new("BillboardGui")
    billboardGui.Name = "InfoLabel"
    billboardGui.Adornee = object
    billboardGui.Size = UDim2.new(4, 0, 2, 0) -- Adjust size as needed
    billboardGui.StudsOffset = Vector3.new(0, 3, 0) -- Position above the object
    billboardGui.AlwaysOnTop = true
    billboardGui.MaxDistance = 0 -- Ensures it remains the same size regardless of distance

    local textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.new(1, 0, 0.5, 0)
    textLabel.BackgroundTransparency = 1
    textLabel.TextColor3 = Color3.new(1, 1, 1)
    textLabel.TextStrokeTransparency = 0.5
    textLabel.TextScaled = true
    textLabel.Font = Enum.Font.GothamBold
    textLabel.Text = object.Name
    textLabel.Parent = billboardGui

    local distanceLabel = Instance.new("TextLabel")
    distanceLabel.Size = UDim2.new(1, 0, 0.5, 0)
    distanceLabel.Position = UDim2.new(0, 0, 0.5, 0)
    distanceLabel.BackgroundTransparency = 1
    distanceLabel.TextColor3 = Color3.new(1, 1, 1)
    distanceLabel.TextStrokeTransparency = 0.5
    distanceLabel.TextScaled = true
    distanceLabel.Font = Enum.Font.GothamBold
    distanceLabel.Parent = billboardGui

    return billboardGui, textLabel, distanceLabel
end

-- Function to create snap lines for humanoids
local function createSnapLine()
    local line = Drawing.new("Line")
    line.Color = Color3.new(1, 0, 0) -- Red color
    line.Thickness = 2
    line.Visible = true
    return line
end

-- Table to track active snap lines
local activeSnapLines = {}

-- Update ESP for each object in Workspace
local function updateObjectESP()
    for _, object in ipairs(Workspace:GetChildren()) do
        if object:IsA("BasePart") and string.find(object.Name:lower(), "container") then
            local billboardGui = object:FindFirstChild("InfoLabel")

            if not billboardGui then
                local newBillboardGui, textLabel, distanceLabel = createInfoLabel(object)
                newBillboardGui.Parent = object
                billboardGui = newBillboardGui
            end

            local distance = (object.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
            billboardGui.TextLabel.Text = object.Name
            billboardGui.TextLabel.Parent.TextLabel.Text = string.format("%.1f studs", distance)
        end
    end
end

-- Update snap lines for humanoids in Workspace.AiZones
local function updateSnapLines()
    -- Clear previous snap lines
    for _, line in pairs(activeSnapLines) do
        line:Remove()
    end
    activeSnapLines = {}

    for _, zone in ipairs(Workspace:FindFirstChild("AiZones"):GetChildren()) do
        for _, object in ipairs(zone:GetChildren()) do
            if object:FindFirstChild("Humanoid") and object:FindFirstChild("HumanoidRootPart") then
                local humanoidRootPart = object.HumanoidRootPart

                -- Create and update snap line
                local line = createSnapLine()
                table.insert(activeSnapLines, line)

                local screenPosition, onScreen = Camera:WorldToViewportPoint(humanoidRootPart.Position)
                if onScreen then
                    line.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y) -- Bottom center of the screen
                    line.To = Vector2.new(screenPosition.X, screenPosition.Y)
                    line.Visible = true
                else
                    line.Visible = false
                end
            end
        end
    end
end

-- Remove ESP if an object is removed
local function onObjectRemoving(object)
    local infoLabel = object:FindFirstChild("InfoLabel")
    if infoLabel then
        infoLabel:Destroy()
    end
end

-- Setup connections and update ESP every 30 seconds
for _, object in ipairs(Workspace:GetChildren()) do
    if object:IsA("BasePart") and string.find(object.Name:lower(), "container") then
        object.AncestryChanged:Connect(function()
            if not object:IsDescendantOf(Workspace) then
                onObjectRemoving(object)
            end
        end)
    end
end

RunService.RenderStepped:Connect(function()
    updateObjectESP()
    updateSnapLines()
end)

    end,
 })

 local Toggle = vis:CreateToggle({
    Name = "Distance esp",
    CurrentValue = false,
    Flag = "Toggle10", -- A flag is the identifier for the configuration file, make sure every element has a different flag if you're using configuration saving to ensure no overlaps
    Callback = function(Value)
-- Place this script in a LocalScript (e.g., StarterPlayerScripts).
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")


local function createDistanceLabel(character)
    local billboardGui = Instance.new("BillboardGui")
    billboardGui.Name = "DistanceLabel"
    billboardGui.Adornee = character:WaitForChild("HumanoidRootPart")
    billboardGui.Size = UDim2.new(8, 0, 2, 0) -- Adjust size as needed
    billboardGui.StudsOffset = Vector3.new(0, -2.5, 0) -- Position below character
    billboardGui.AlwaysOnTop = true
    billboardGui.MaxDistance = 0 -- Ensures it remains the same size regardless of distance
    billboardGui.SizeOffset = Vector2.new(0, 0) -- Prevents scaling with distance

    local textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.new(1, 0, 1, 0)
    textLabel.BackgroundTransparency = 1
    textLabel.TextColor3 = Color3.new(1, 1, 1)
    textLabel.TextStrokeTransparency = 0.5
    textLabel.TextScaled = true
    textLabel.Font = Enum.Font.GothamBold
    textLabel.Parent = billboardGui

    return billboardGui, textLabel
end

-- Update ESP for each player
local function updateESP()
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local character = player.Character
            local billboardGui = character:FindFirstChild("DistanceLabel")

            if not billboardGui then
                local newBillboardGui, textLabel = createDistanceLabel(character)
                newBillboardGui.Parent = character
                billboardGui = newBillboardGui
            end

            local humanoidRootPart = character.HumanoidRootPart
            local distance = (humanoidRootPart.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
            billboardGui.TextLabel.Text = string.format("%.1f studs", distance)
        end
    end
end

-- Remove ESP if a character is removed
local function onCharacterRemoving(character)
    local distanceLabel = character:FindFirstChild("DistanceLabel")
    if distanceLabel then
        distanceLabel:Destroy()
    end
end

-- Setup connections for ESP
local function setupPlayer(player)
    player.CharacterAdded:Connect(function(character)
        character:WaitForChild("HumanoidRootPart").GetPropertyChangedSignal("Position"):Connect(updateESP)
    end)
    player.CharacterRemoving:Connect(onCharacterRemoving)
end

-- Main loop
for _, player in ipairs(Players:GetPlayers()) do
    setupPlayer(player)
end

Players.PlayerAdded:Connect(setupPlayer)
RunService.RenderStepped:Connect(updateESP)

    end,
 })

walkSpeed = 50

 local Button = mis:CreateButton({
    Name = "Enable Walk Speed changer",
    Callback = function()
          -- Set the initial WalkSpeed here

        local function updatePlayerSpeed()
            -- Access the local player's character
            local player = game.Players.LocalPlayer
            local character = player.Character or player.CharacterAdded:Wait()
            
            -- Wait for the Humanoid to load
            local humanoid = character:WaitForChild("Humanoid")
            
            -- Continuously update the WalkSpeed
            while true do
                humanoid.WalkSpeed = walkSpeed
                wait(0.1)  -- Update every 0.1 seconds to prevent constant setting
            end
        end
        
        -- Call the function to start updating speed
        updatePlayerSpeed()
        
    end,
 })


 local Toggle = aim:CreateToggle({
    Name = "TriggerBot",
    CurrentValue = false,
    Flag = "Toggle11", -- A flag is the identifier for the configuration file, make sure every element has a different flag if you're using configuration saving to ensure no overlaps
    Callback = function(Value)
        local player = game:GetService("Players").LocalPlayer
        local mouse = player:GetMouse()
        local runService = game:GetService("RunService")
        local userInputService = game:GetService("UserInputService")
    
        -- Variables
        local buttonToHold = Enum.UserInputType.MouseButton2 -- Default: Right Mouse Button
        local delayTime = 0.1 -- Delay between mouse press and release
    
        local buttonHeld = false
    
        -- Detect button press and release
        userInputService.InputBegan:Connect(function(input)
            if input.UserInputType == buttonToHold then
                buttonHeld = true
            end
        end)
    
        userInputService.InputEnded:Connect(function(input)
            if input.UserInputType == buttonToHold then
                buttonHeld = false
            end
        end)
    
        -- Main loop
        runService.RenderStepped:Connect(function()
            if buttonHeld and mouse.Target and mouse.Target.Parent:FindFirstChild("Humanoid") and mouse.Target.Parent.Name ~= player.Name then
                mouse1press()
                wait(delayTime)
                mouse1release()
            end
        end)
    
    end,
 })

delayTime = 0.1

 local Slider = con:CreateSlider({
    Name = "Trigger Bot Delay",
    Range = {0, 1},
    Increment = 0.01,
    Suffix = "Milliseconds",
    CurrentValue = 0.1,
    Flag = "Slider4", -- A flag is the identifier for the configuration file, make sure every element has a different flag if you're using configuration saving to ensure no overlaps
    Callback = function(Value)
delayTime = Value
    end,
 })



 local Toggle = vis:CreateToggle({
    Name = "Skeleton Esp [R6 Rig Only]",
    CurrentValue = false,
    Flag = "Toggle12", -- A flag is the identifier for the configuration file, make sure every element has a different flag if you're using configuration saving to ensure no overlaps
    Callback = function(Value)
-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera

-- Configuration
local ESPSettings = {
    Enabled = true,
    LineColor = Color3.fromRGB(0, 255, 0), -- Bright green
    LineThickness = 2,
    Transparency = 1
}

-- Utility function to create lines
local function createLine()
    local line = Drawing.new("Line")
    line.Visible = false
    line.Color = ESPSettings.LineColor
    line.Thickness = ESPSettings.LineThickness
    line.Transparency = ESPSettings.Transparency
    return line
end

-- Map body parts for skeleton
local SkeletonMap = {
    {"Head", "UpperTorso"},
    {"UpperTorso", "LowerTorso"},
    {"UpperTorso", "LeftUpperArm"},
    {"LeftUpperArm", "LeftLowerArm"},
    {"LeftLowerArm", "LeftHand"},
    {"UpperTorso", "RightUpperArm"},
    {"RightUpperArm", "RightLowerArm"},
    {"RightLowerArm", "RightHand"},
    {"LowerTorso", "LeftUpperLeg"},
    {"LeftUpperLeg", "LeftLowerLeg"},
    {"LeftLowerLeg", "LeftFoot"},
    {"LowerTorso", "RightUpperLeg"},
    {"RightUpperLeg", "RightLowerLeg"},
    {"RightLowerLeg", "RightFoot"}
}

-- Table to store player ESP lines
local ESPLines = {}

-- Update ESP for a player
local function updateESP(player)
    local character = player.Character
    if not character then return end

    for _, pair in ipairs(SkeletonMap) do
        local part0 = character:FindFirstChild(pair[1])
        local part1 = character:FindFirstChild(pair[2])

        if part0 and part1 and part0:IsA("BasePart") and part1:IsA("BasePart") then
            local line = ESPLines[player][pair] or createLine()

            local pos0, onScreen0 = Camera:WorldToViewportPoint(part0.Position)
            local pos1, onScreen1 = Camera:WorldToViewportPoint(part1.Position)

            if onScreen0 and onScreen1 then
                line.Visible = ESPSettings.Enabled
                line.From = Vector2.new(pos0.X, pos0.Y)
                line.To = Vector2.new(pos1.X, pos1.Y)
            else
                line.Visible = false
            end

            ESPLines[player][pair] = line
        end
    end
end

-- Cleanup ESP lines for a player
local function cleanupESP(player)
    if ESPLines[player] then
        for _, line in pairs(ESPLines[player]) do
            line:Remove()
        end
        ESPLines[player] = nil
    end
end

-- Setup ESP for a player
local function setupESP(player)
    ESPLines[player] = {}

    player.CharacterAdded:Connect(function()
        cleanupESP(player)
        ESPLines[player] = {}
    end)

    player.CharacterRemoving:Connect(function()
        cleanupESP(player)
    end)
end

-- Initialize ESP for all players
local function initializeESP()
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= Players.LocalPlayer then
            setupESP(player)
        end
    end

    Players.PlayerAdded:Connect(function(player)
        setupESP(player)
    end)

    Players.PlayerRemoving:Connect(function(player)
        cleanupESP(player)
    end)
end

-- Main Render Loop
RunService.RenderStepped:Connect(function()
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= Players.LocalPlayer and ESPLines[player] then
            updateESP(player)
        end
    end
end)

-- Start the ESP system
initializeESP()

    end,
 })


 local Toggle = wor:CreateToggle({
    Name = "Fullbright",
    CurrentValue = false,
    Flag = "Toggle13", -- A flag is the identifier for the configuration file, make sure every element has a different flag if you're using configuration saving to ensure no overlaps
    Callback = function(Value)
-- Fullbright Script

-- Services
local Lighting = game:GetService("Lighting")

-- Function to enable fullbright
local function EnableFullbright()
    Lighting.Ambient = Color3.fromRGB(255, 255, 255)  -- Full brightness
    Lighting.OutdoorAmbient = Color3.fromRGB(255, 255, 255)  -- Full brightness outside
    Lighting.Brightness = 2  -- Increase brightness level
    Lighting.ShadowSoftness = 0  -- No shadows
    Lighting.FogStart = 0  -- Disable fog
    Lighting.FogEnd = 100000  -- Extend fog range to make it invisible
end

-- Call the function to enable fullbright
EnableFullbright()

-- Optional: Set up a toggle keybind to turn it off and on
local UserInputService = game:GetService("UserInputService")
local isFullbright = true
local toggleKey = Enum.KeyCode.F -- Change this key if desired

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == toggleKey then
        isFullbright = not isFullbright
        if isFullbright then
            EnableFullbright()
        else
            -- Restore default lighting
            Lighting.Ambient = Color3.fromRGB(127, 127, 127)  -- Default ambient light
            Lighting.OutdoorAmbient = Color3.fromRGB(127, 127, 127)  -- Default outdoor ambient light
            Lighting.Brightness = 1  -- Default brightness
            Lighting.ShadowSoftness = 0.5  -- Default shadow softness
            Lighting.FogStart = 0  -- Default fog start
            Lighting.FogEnd = 100000  -- Default fog end
        end
    end
end)

    end,
 })

playerfov = 60

 local Slider = mis:CreateSlider({
    Name = "FOV",
    Range = {1, 300},
    Increment = 1,
    Suffix = "Degrees",
    CurrentValue = 60,
    Flag = "Slider5", -- A flag is the identifier for the configuration file, make sure every element has a different flag if you're using configuration saving to ensure no overlaps
    Callback = function(Value)
playerfov = Value 
    end,
 })

 local Button = mis:CreateButton({
    Name = "Update Fov ",
    Callback = function()
-- Place this script inside StarterPlayerScripts

local targetFOV = playerfov -- Set your desired FOV value here
local camera = workspace.CurrentCamera

game:GetService("RunService").RenderStepped:Connect(function()
    camera.FieldOfView = targetFOV
end)

    end,
 })

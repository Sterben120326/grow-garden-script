-- Grow a Garden Egg Roller Script
-- Features: Auto-roll eggs, teleport to eggs, egg farming

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

-- Configuration
local CONFIG = {
    AUTO_ROLL_EGGS = true,
    TELEPORT_TO_EGGS = true,
    EGG_DETECTION_RANGE = 50,
    ROLLING_SPEED = 0.5,
    GUI_ENABLED = true
}

-- Variables
local eggs = {}
local isRunning = false
local gui = nil

-- Create GUI
local function createGUI()
    if not CONFIG.GUI_ENABLED then return end
    
    gui = Instance.new("ScreenGui")
    gui.Name = "GrowAGardenEggScript"
    gui.Parent = PlayerGui
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 200, 0, 150)
    frame.Position = UDim2.new(0, 10, 0, 10)
    frame.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    frame.BorderSizePixel = 0
    frame.Parent = gui
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 30)
    title.Position = UDim2.new(0, 0, 0, 0)
    title.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    title.Text = "Egg Roller"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextScaled = true
    title.Font = Enum.Font.SourceSansBold
    title.Parent = frame
    
    local toggleButton = Instance.new("TextButton")
    toggleButton.Size = UDim2.new(0.8, 0, 0, 30)
    toggleButton.Position = UDim2.new(0.1, 0, 0.3, 0)
    toggleButton.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
    toggleButton.Text = "Start Auto Roll"
    toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    toggleButton.TextScaled = true
    toggleButton.Font = Enum.Font.SourceSans
    toggleButton.Parent = frame
    
    local statusLabel = Instance.new("TextLabel")
    statusLabel.Size = UDim2.new(0.8, 0, 0, 20)
    statusLabel.Position = UDim2.new(0.1, 0, 0.6, 0)
    statusLabel.BackgroundTransparency = 1
    statusLabel.Text = "Status: Ready"
    statusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    statusLabel.TextScaled = true
    statusLabel.Font = Enum.Font.SourceSans
    statusLabel.Parent = frame
    
    local infoLabel = Instance.new("TextLabel")
    infoLabel.Size = UDim2.new(0.8, 0, 0, 20)
    infoLabel.Position = UDim2.new(0.1, 0, 0.8, 0)
    infoLabel.BackgroundTransparency = 1
    infoLabel.Text = "Eggs Found: 0"
    infoLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    infoLabel.TextScaled = true
    infoLabel.Font = Enum.Font.SourceSans
    infoLabel.Parent = frame
    
    -- Toggle functionality
    toggleButton.MouseButton1Click:Connect(function()
        if isRunning then
            isRunning = false
            toggleButton.Text = "Start Auto Roll"
            toggleButton.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
            statusLabel.Text = "Status: Stopped"
        else
            isRunning = true
            toggleButton.Text = "Stop Auto Roll"
            toggleButton.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
            statusLabel.Text = "Status: Running"
        end
    end)
    
    return statusLabel, infoLabel
end

-- Find eggs in the game
local function findEggs()
    eggs = {}
    
    -- Look for common egg models in Grow a Garden
    local eggNames = {"Egg", "PetEgg", "Gift", "Box", "Crate"}
    
    for _, name in pairs(eggNames) do
        local foundEggs = workspace:GetDescendants()
        for _, obj in pairs(foundEggs) do
            if obj.Name:lower():find(name:lower()) and obj:IsA("BasePart") then
                table.insert(eggs, obj)
            end
        end
    end
    
    -- Also look for any objects that might be eggs
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("Model") and obj.Name:lower():find("egg") then
            local primaryPart = obj.PrimaryPart or obj:FindFirstChild("HumanoidRootPart") or obj:FindFirstChild("Torso")
            if primaryPart then
                table.insert(eggs, primaryPart)
            end
        end
    end
    
    return eggs
end

-- Teleport to egg
local function teleportToEgg(egg)
    if not CONFIG.TELEPORT_TO_EGGS then return end
    
    local character = LocalPlayer.Character
    if not character then return end
    
    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    if not humanoidRootPart then return end
    
    local distance = (humanoidRootPart.Position - egg.Position).Magnitude
    if distance > CONFIG.EGG_DETECTION_RANGE then return end
    
    -- Create tween for smooth movement
    local tweenInfo = TweenInfo.new(CONFIG.ROLLING_SPEED, Enum.EasingStyle.Linear)
    local tween = TweenService:Create(humanoidRootPart, tweenInfo, {CFrame = CFrame.new(egg.Position)})
    tween:Play()
    
    return tween
end

-- Try to roll egg
local function rollEgg(egg)
    if not CONFIG.AUTO_ROLL_EGGS then return end
    
    -- Try different methods to roll the egg
    local character = LocalPlayer.Character
    if not character then return end
    
    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    if not humanoidRootPart then return end
    
    -- Method 1: Touch the egg
    local distance = (humanoidRootPart.Position - egg.Position).Magnitude
    if distance <= 5 then
        -- Try to fire proximity prompts
        local proximityPrompt = egg:FindFirstChild("ProximityPrompt")
        if proximityPrompt then
            proximityPrompt:InputHoldBegin()
            wait(0.1)
            proximityPrompt:InputHoldEnd()
        end
        
        -- Try to click on the egg
        firetouchinterest(humanoidRootPart, egg, 0)
        wait(0.1)
        firetouchinterest(humanoidRootPart, egg, 1)
    end
end

-- Main loop
local function mainLoop()
    local statusLabel, infoLabel = createGUI()
    
    while true do
        if isRunning then
            -- Find eggs
            local foundEggs = findEggs()
            
            if statusLabel then
                statusLabel.Text = "Status: Found " .. #foundEggs .. " eggs"
            end
            if infoLabel then
                infoLabel.Text = "Eggs Found: " .. #foundEggs
            end
            
            -- Process each egg
            for _, egg in pairs(foundEggs) do
                if isRunning then
                    -- Teleport to egg
                    local tween = teleportToEgg(egg)
                    if tween then
                        tween.Completed:Wait()
                    end
                    
                    -- Try to roll
                    rollEgg(egg)
                    
                    wait(0.5) -- Wait between eggs
                end
            end
        end
        
        wait(1) -- Update every second
    end
end

-- Start the script
print("Grow a Garden Egg Roller Script Loaded!")
print("Features:")
print("- Auto roll eggs")
print("- Teleport to eggs")
print("- GUI controls")
print("Press the button in the GUI to start!")

-- Run the main loop
coroutine.wrap(mainLoop)()

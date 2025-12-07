--// Load Rayfield (Xeno compatible)
local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

--// Window
local Window = Rayfield:CreateWindow({
	Name = "[❄️] Booga Booga | AirCodes",
	LoadingTitle = "AirCodes Presents...",
	LoadingSubtitle = "by AirCodes Developers",
	ConfigurationSaving = { Enabled = true, FileName = "AirCodes_Booga" },
	KeySystem = false
})

--// Tab
local Tab = Window:CreateTab("🏠 | Main")

--// Services
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- ===============================
-- SPEED
-- ===============================
local SpeedEnabled = false
local WalkSpeedValue = 16

Tab:CreateToggle({
	Name = "Speed ON/OFF",
	CurrentValue = false,
	Callback = function(v)
		SpeedEnabled = v
	end
})

Tab:CreateSlider({
	Name = "WalkSpeed",
	Range = {0, 21.4},
	Increment = 0.1,
	CurrentValue = 16,
	Callback = function(v)
		WalkSpeedValue = v
	end
})

RunService.RenderStepped:Connect(function()
	local char = Player.Character or Player.CharacterAdded:Wait()
	local hum = char:FindFirstChildOfClass("Humanoid") or char:WaitForChild("Humanoid")
	hum.WalkSpeed = SpeedEnabled and WalkSpeedValue or 16
end)

local Tab = Window:CreateTab("🍑 | Farming") -- Title, Image

-- Services
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local hrp = character:WaitForChild("HumanoidRootPart")

-- Configuration
local plantBoxFolder = workspace.PlantBoxes
local fruitName = "Bloodfruit"
local plantRange = 5
local godHoeName = "God Hoe" -- Name of the tool that boosts planting

-- Track planted boxes
local plantedBoxes = {}

-- Function to check if God Hoe is equipped
local function hasGodHoe()
    local tool = character:FindFirstChildOfClass("Tool")
    return tool and tool.Name == godHoeName
end

-- Function to plant a fruit (only if God Hoe is equipped)
local function plantFruit(box)
    if box and box:IsA("BasePart") and not plantedBoxes[box] then
        if hasGodHoe() then
            local fruit = Instance.new("Part")
            fruit.Name = fruitName
            fruit.Size = Vector3.new(1,1,1)
            fruit.Position = box.Position + Vector3.new(0,3,0)
            fruit.Anchored = true
            fruit.Parent = box
            plantedBoxes[box] = true
            print("Planted", fruitName, "at", box.Name, "with God Hoe")
        end
    end
end

-- Get nearest unplanted boxes
local function getNearestBoxes()
    local boxes = {}
    for box in ipairs(plantBoxFolder:GetChildren()) do
        if box:IsA("BasePart") and not plantedBoxes[box] then
            table.insert(boxes, box)
        end
    end
    table.sort(boxes, function(a,b)
        return (hrp.Position - a.Position).Magnitude < (hrp.Position - b.Position).Magnitude
    end)
    local nearest = {}
    for i = 1, math.min(plantRange, #boxes) do
        table.insert(nearest, boxes[i])
    end
    return nearest
end

-- Continuous blatant loop
spawn(function()
    while true do
        local boxes = getNearestBoxes()
        if #boxes == 0 then
            plantedBoxes = {} -- Reset if all planted
        else
            for box in ipairs(boxes) do
                if box.Parent then
                    moveInstant(box.Position) -- Instantly teleport
                    plantFruit(box) -- Only plants if God Hoe is equipped
                end
            end
        end
    end
end)

local Tab = Window:CreateTab("✈️ | Tween") -- Title, Image

-- ===============================
-- CHECKPOINTS
-- ===============================
local Checkpoints = {}
local CP_Index = 0
local Dropdown

local function GetCheckpointNames()
	local t = {}
	for _, v in ipairs(Checkpoints) do table.insert(t, v.Name) end
	return t
end

local function HardRefreshDropdown()
	if Dropdown then
		Dropdown:Set(GetCheckpointNames())
		Dropdown.CurrentOption = nil
	end
end

-- Spawn Checkpoint
Tab:CreateButton({
	Name = "Spawn Checkpoint",
	Callback = function()
		local char = Player.Character or Player.CharacterAdded:Wait()
		local hrp = char:WaitForChild("HumanoidRootPart")
		CP_Index += 1

		-- Part
		local p = Instance.new("Part")
		p.Name = "Checkpoint"..CP_Index
		p.Size = Vector3.new(3,3,3)
		p.Anchored = true
		p.CanCollide = false
		p.CanQuery = false
		p.CanTouch = false
		p.Transparency = 0.927 -- 92.7% transparent
		p.Color = Color3.fromRGB(255,0,0)
		p.Position = hrp.Position
		p.Parent = workspace

		-- Billboard number
		local gui = Instance.new("BillboardGui", p)
		gui.Size = UDim2.new(0,60,0,60)
		gui.AlwaysOnTop = true
		gui.StudsOffset = Vector3.new(0,3,0)
		local txt = Instance.new("TextLabel", gui)
		txt.Size = UDim2.new(1,0,1,0)
		txt.BackgroundTransparency = 1
		txt.Text = tostring(CP_Index)
		txt.TextScaled = true
		txt.Font = Enum.Font.GothamBold
		txt.TextColor3 = Color3.new(1,1,1)

		table.insert(Checkpoints, p)
		HardRefreshDropdown()
	end
})

-- Delete Last
Tab:CreateButton({
	Name = "Delete Last Checkpoint",
	Callback = function()
		local last = Checkpoints[#Checkpoints]
		if last then
			last:Destroy()
			table.remove(Checkpoints,#Checkpoints)
			CP_Index = #Checkpoints
			HardRefreshDropdown()
		end
	end
})

-- Bring Last Checkpoint
Tab:CreateButton({
	Name = "Bring Last Checkpoint",
	Callback = function()
		local last = Checkpoints[#Checkpoints]
		if not last then return end
		local char = Player.Character or Player.CharacterAdded:Wait()
		local hrp = char:WaitForChild("HumanoidRootPart")
		last.Position = hrp.Position
	end
})

-- ===============================
-- TWEEN MOVEMENT
-- ===============================
local TweenSpeed = 21.4
local LoopEnabled = false

Tab:CreateSlider({
	Name = "Tween Speed",
	Range = {1,21.4},
	Increment = 0.1,
	CurrentValue = 21.4,
	Callback = function(v) TweenSpeed = v end
})

local function MoveTo(pos)
	local char = Player.Character or Player.CharacterAdded:Wait()
	local hrp = char:WaitForChild("HumanoidRootPart")
	local start = hrp.Position
	local dist = (pos - start).Magnitude
	if dist < 1 then return end
	local time = dist / TweenSpeed
	local startTime = os.clock()
	while os.clock() - startTime < time do
		hrp.CFrame = CFrame.new(start:Lerp(pos, (os.clock() - startTime)/time))
		task.wait()
	end
	hrp.CFrame = CFrame.new(pos)
end

local function Loop()
	while LoopEnabled do
		for _,v in ipairs(Checkpoints) do
			if not LoopEnabled then return end
			if v and v.Parent then
				MoveTo(v.Position)
				task.wait(0)
			end
		end
	end
end

Tab:CreateToggle({
	Name = "Start Tween [Loop]",
	CurrentValue = false,
	Callback = function(v)
		LoopEnabled = v
		if v then task.spawn(Loop) end
	end
})

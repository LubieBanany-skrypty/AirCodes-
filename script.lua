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

-- Create the input box
local Input = Tab:CreateInput({
    Name = "Incognito Chat",
    CurrentValue = "",
    PlaceholderText = "Type your message here...",
    RemoveTextAfterFocusLost = false,
    Flag = "IncognitoInput",
    Callback = function(Text)
        if Text == "" then return end

        local char = Player.Character or Player.CharacterAdded:Wait()
        local hrp = char:WaitForChild("HumanoidRootPart")

        -- Remove old BillboardGui if it exists
        local oldGui = hrp:FindFirstChild("IncognitoChatGui")
        if oldGui then oldGui:Destroy() end

        -- Create new BillboardGui
        local gui = Instance.new("BillboardGui")
        gui.Name = "IncognitoChatGui"
        gui.Adornee = hrp
        gui.Size = UDim2.new(0, 250, 0, 50)
        gui.StudsOffset = Vector3.new(0,3,0)
        gui.AlwaysOnTop = true
        gui.Parent = hrp

        -- Frame for black background
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(1,0,1,0)
        frame.BackgroundColor3 = Color3.new(0,0,0) -- black
        frame.BackgroundTransparency = 0.3 -- slightly see-through
        frame.Parent = gui

        -- TextLabel
        local txt = Instance.new("TextLabel")
        txt.Size = UDim2.new(1,0,1,0)
        txt.BackgroundTransparency = 1
        txt.Text = Text
        txt.TextScaled = true
        txt.TextColor3 = Color3.fromRGB(255,255,255)
        txt.Font = Enum.Font.GothamBold
        txt.Parent = frame

        -- Make draggable
        local dragging = false
        local dragInput, mousePos, framePos

        frame.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = true
                mousePos = input.Position
                framePos = frame.Position
                input.Changed:Connect(function()
                    if input.UserInputState == Enum.UserInputState.End then
                        dragging = false
                    end
                end)
            end
        end)

        frame.InputChanged:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseMovement then
                dragInput = input
            end
        end)

        game:GetService("UserInputService").InputChanged:Connect(function(input)
            if input == dragInput and dragging then
                local delta = input.Position - mousePos
                frame.Position = framePos + UDim2.new(0, delta.X, 0, delta.Y)
            end
        end)

        -- Optional: remove after 10 seconds
        task.spawn(function()
            wait(10)
            if gui then gui:Destroy() end
        end)
    end,
})


local Tab = Window:CreateTab("🍑 | Farming") -- Title, Image

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
	Range = {1,36},
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

-- place this script onto your humanoid to follow a player

local Players = game:GetService("Players")
local ServerStorage = game:GetService("ServerStorage")
local SimplePath = require(ServerStorage.SimplePath)

local Dummy = script.Parent

local config = {
	radius = 5,
	agentParameters = {
		AgentRadius = 1,
		AgentHeight = 5,
		AgentCanJump = false,
		AgentCanClimb = false,
		WaypointSpacing = 4,
		Costs = {
			--example for cannot swim but prefer not to cross grass
			--water = math.huge,
			--grass = 20
		}
	}
}

-- Function to get the first player
local function getFirstPlayer()
	local players = Players:GetPlayers()
	if #players > 0 then
		return players[1]
	end
	return nil
end

-- Function to handle player and character loading
local function onPlayerAdded(player)
	player.CharacterAdded:Wait() -- Wait for the character to be added
	local firstPlayer = getFirstPlayer()

	if firstPlayer then
		-- Define the Goal as the first player's HumanoidRootPart
		local Goal = firstPlayer.Character and firstPlayer.Character:WaitForChild("HumanoidRootPart")

		-- Create a new Path using the Dummy
		local Path = SimplePath.new(Dummy, config.agentParameters)
		--Helps to visualize the path
		Path.Visualize = true
		local function moveDummyToGoal()
			if Goal and not Path:IsWithinTargetRadius(Goal.Position, config.radius, false) then
				Path:Run(Goal.Position, config.radius)
			end
		end
		
		Path.Blocked:Connect(function()
			print("Path blocked, recalculating...")
			moveDummyToGoal()
		end)

		Path.WaypointReached:Connect(function()
			print("Waypoint reached, recalculating...")
			moveDummyToGoal()
		end)

		Path.Error:Connect(function(errorType)
			print("Path error: " .. errorType .. ", recalculating...")
			moveDummyToGoal()
		end)

		Path.Reached:Connect(function()
			print("Goal reached, recalculating...")
			moveDummyToGoal()
		end)

		-- Periodically check if the dummy is stuck
		while true do
			wait(1)
			moveDummyToGoal()
		end

		-- Initial move
		moveDummyToGoal()
		
	else
		warn("No players found!")
	end
end

-- Connect the PlayerAdded event
Players.PlayerAdded:Connect(onPlayerAdded)

-- For players who are already in the game when the script runs
for _, player in pairs(Players:GetPlayers()) do
	onPlayerAdded(player)
end
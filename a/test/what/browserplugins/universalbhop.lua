local BHOP = {}

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local GroupService = game:GetService("GroupService")

local ScriptEnabled = false
local isChatting = false
local RolvePatch = false

local BhopInfo = {
	["CurrentVel"] = 0,
	["VelCap"] = 3,
	["JumpBoostAmt"] = 0.1
}
local DefaultInfo = {
    ["VelCap"] = 3,
    ["JumpBoostAmt"] = 0.1
}
local ContainedVelCap = 3
local canMaxBhop = false

if game.CreatorType == Enum.CreatorType.Group then
	local Group = GroupService:GetGroupInfoAsync(game.CreatorId)
	if Group.Id == 2613928 then
		RolvePatch = true
	end
end

local CheckOnGround = function(char)
	local ray = Ray.new(char.HumanoidRootPart.Position, -(char.HumanoidRootPart.CFrame.UpVector * 100))
	local part, pos = workspace:FindPartOnRay(ray, char)
	if part then
		if pos then
			local farness = math.ceil((char.HumanoidRootPart.Position - pos).Magnitude)
			if farness > 3 then
				return false
			elseif farness <= 3 then
				return true
			end
		end
	end
end

UserInputService.InputBegan:Connect(function(Input, IsChat)
    if IsChat then
        isChatting = true
    else
        isChatting = false
    end
end)

UserInputService.JumpRequest:Connect(function()
	if ScriptEnabled and not isChatting then
		if (UserInputService:IsKeyDown(Enum.KeyCode.W) == false) and (UserInputService:IsKeyDown(Enum.KeyCode.A) or UserInputService:IsKeyDown(Enum.KeyCode.D)) == true and BhopInfo.CurrentVel < BhopInfo.VelCap then
			if canMaxBhop == true then
				BhopInfo.CurrentVel = ContainedVelCap
			else
				BhopInfo.CurrentVel = BhopInfo.CurrentVel + BhopInfo.JumpBoostAmt
			end
		end
	end
end)

Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid").StateChanged:Connect(function(oldstate, newstate)
	if ScriptEnabled and not isChatting then
		if newstate == Enum.HumanoidStateType.Landed then
			Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):SetStateEnabled(Enum.HumanoidStateType.Jumping, true)
		end
	end
end)

spawn(function()
	while true do
		if ScriptEnabled and not isChatting then
			if CheckOnGround(Players.LocalPlayer.Character) == false and BhopInfo.CurrentVel ~= 0 then
				Players.LocalPlayer.Character.HumanoidRootPart.CFrame = Players.LocalPlayer.Character.HumanoidRootPart.CFrame + (Players.LocalPlayer.Character.HumanoidRootPart.CFrame.LookVector * BhopInfo.CurrentVel/6)
			end
			if UserInputService:IsKeyDown(Enum.KeyCode.Space) == false then
				BhopInfo.CurrentVel = 0
			elseif UserInputService:IsKeyDown(Enum.KeyCode.Space) == true and UserInputService:IsKeyDown(Enum.KeyCode.W) then
				if canMaxBhop == true then
					BhopInfo.CurrentVel = ContainedVelCap
				else
					BhopInfo.CurrentVel = math.clamp(BhopInfo.CurrentVel - 0.01, 0, BhopInfo.VelCap)
				end
			elseif UserInputService:IsKeyDown(Enum.KeyCode.Space) == true then
				if RolvePatch == true then Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid").Jump = true end
			end
		end
		game:GetService("RunService").Stepped:Wait()
	end
end)

BHOP.Start = function()
	ScriptEnabled = true
end

BHOP.Stop = function()
	ScriptEnabled = false
end

local BunnyHop = "Waiting"
local Plugin = {
	["PluginName"] = "Universal Bhop",
	["PluginDescription"] = "",
	["Commands"] = {
		["bhop"] = {
			["ListName"] = "bhop",
			["Description"] = "Start the Bhop Mechanic",
			["Aliases"] = {},
			["Function"] = function(args, speaker)
				if BunnyHop == "Waiting" then
          				BunnyHop = "Loaded"
					BHOP.Start()
				else
					BHOP.Start()
				end
				con = speaker.CharacterAdded:Connect(function()
				if BunnyHop == "Loaded" then
				BHOP.Start()
				end
				end)
			end,
		},
		["unbhop"] = {
			["ListName"] = "unbhop",
			["Description"] = "Stop the Bhop Mechanic",
			["Aliases"] = {},
			["Function"] = function(args, speaker)
				if BunnyHop == "Waiting" then return end
				BHOP.Stop()
				con = con:Disconnect()
			end,
		},
		["currentvel"] = {
			["ListName"] = "currentvel [num]",
			["Description"] = "Set your current bhop velocity",
			["Aliases"] = {},
			["Function"] = function(args, speaker)
				if args[1] and isNumber(args[1]) then
					BhopInfo.CurrentVel = tonumber(args[1])
				end
			end,
		},
		["velcap"] = {
			["ListName"] = "velcap [num]",
			["Description"] = "Set your bhop velocity cap",
			["Aliases"] = {},
			["Function"] = function(args, speaker)
				if args[1] and isNumber(args[1]) then
					BhopInfo.VelCap = tonumber(args[1])
					ContainedVelCap = tonumber(args[1])
				else
					BhopInfo.VelCap = DefaultInfo.VelCap
					ContainedVelCap = DefaultInfo.VelCap
				end
			end,
		},
		["jumpboostamount"] = {
			["ListName"] = "jumpboostamount / jumpboostamt [num]",
			["Description"] = "Set your bhop jump boost amount",
			["Aliases"] = {"jumpboostamt"},
			["Function"] = function(args, speaker)
				if args[1] and isNumber(args[1]) then
					BhopInfo.JumpBoostAmt = tonumber(args[1])
				else
					BhopInfo.JumpBoostAmt = DefaultInfo.JumpBoostAmt
				end
			end,
		},
		["togglemaxbhop"] = {
			["ListName"] = "togglemaxbhop",
			["Description"] = "Toggle loop your bhop velocity to your velocity cap",
			["Aliases"] = {"jumpboostamt"},
			["Function"] = function(args, speaker)
				canMaxBhop = not canMaxBhop
			end,
		},
	},
}
return Plugin

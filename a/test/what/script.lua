local game = game
local StarterTick = StarterTick or tick()
local GetService = game.GetService
local Players = GetService(game, "Players")
local CoreGui = GetService(game, "CoreGui")
local RunService = GetService(game, "RunService")
local HttpService = GetService(game, "HttpService")
local ReplicatedStorage = GetService(game, "ReplicatedStorage")
local Lighting = GetService(game, "Lighting")
local UserInputService = GetService(game, "UserInputService")
local TeleportService = GetService(game, "TeleportService")
local TweenService = GetService(game, "TweenService")
local StarterGui = GetService(game, "StarterGui")
local MarketplaceService = GetService(game, "MarketplaceService")
local MemStorageService = GetService(game, "MemStorageService")
local VirtualInputManager = GetService(game, "VirtualInputManager")
local GuiService = GetService(game, "GuiService")
local GroupService = GetService(game, "GroupService")
local ChatService = GetService(game, "Chat")

local GetPlayers, InstanceNew, IsA =
	Players.GetPlayers,
	Instance.new,
	game.IsA
local GetChildren, GetDescendants = game.GetChildren, game.GetDescendants
local FindFirstChild, FindFirstChildOfClass, FindFirstChildWhichIsA, WaitForChild = 
	game.FindFirstChild,
	game.FindFirstChildOfClass,
	game.FindFirstChildWhichIsA,
	game.WaitForChild
local Destroy, Clone = game.Destroy, game.Clone
local GetPropertyChangedSignal, Changed = 
	game.GetPropertyChangedSignal,
	game.Changed
local JSONEncode, JSONDecode, GenerateGUID = 
	HttpService.JSONEncode,
	HttpService.JSONDecode,
	HttpService.GenerateGUID
local Heartbeat, Stepped, RenderStepped =
	RunService.Heartbeat,
	RunService.Stepped,
	RunService.RenderStepped
local Connection = game.Loaded
local CWait = Connection.Wait
local CConnect = Connection.Connect
local Disconnect
do
    local CalledConnection = CConnect(Connection, function() end)
    Disconnect = CalledConnection.Disconnect
end

local Import = function(Asset)
	if (type(Asset) == "number") then
		return game:GetObjects("rbxassetid://" .. Asset)[1]
	else
		local Link = string.format("https://raw.githubusercontent.com/Ballbuster9000/who/main/a/test/what/others/%s", Asset)
		local Response = game.HttpGetAsync(game, Link)
		local Function = loadstring(Response)
		local Success, Return = pcall(Function)
		if Success then
			return Return
		else
			warn("[da]: Failed to Import Asset " .. "'" .. Asset .. "'")
		end
	end
end

if isfolder and makefolder and isfile and writefile then
	if not isfolder("Dark Admin") then
		makefolder("Dark Admin")
	end
	if not isfolder("Dark Admin/Plugins") then
		makefolder("Dark Admin/Plugins")
	end
	if not isfolder("Dark Admin/Logs") then
		makefolder("Dark Admin/Logs")
	end
	if not isfolder("Dark Admin/Scripts") then
		makefolder("Dark Admin/Scripts")
	end
end

Prote = Import("prote.lua")

local GUI = Import("interface.lua")
local Main = GUI.CommandBar
local cmdbarclone = Clone(Main)
cmdbarclone.Name = "CommandBarClone"
cmdbarclone.Parent = GUI
local Cmdbar = Main.Input
pcall(function() Prote.ProtectInstance(Cmdbar, true) end)
local Assets = GUI.Assets
local CommandsGui = GUI.CMDS
local NotificationTemplate = GUI.NotificationTemplate
local CmdSu = Cmdbar.Predict
local PluginBrowser = GUI.PluginBrowser
local UiDragF = GUI.MainDragFrame
local DaUi = UiDragF.Main

for superindx, objct in pairs(GetDescendants(DaUi)) do
	if objct.Name == "Results" then
		if IsA(objct, "ScrollingFrame") then
			objct.CanvasSize = UDim2.new(0, 0, 0, objct.UIListLayout.AbsoluteContentSize.Y)
			CConnect(GetPropertyChangedSignal(objct.UIListLayout, "AbsoluteContentSize"), function()
				objct.CanvasSize = UDim2.new(0, 0, 0, objct.UIListLayout.AbsoluteContentSize.Y)
			end)
		end
	end
	if objct.Name == "SearchBar" then
		pcall(function() Prote.ProtectInstance(objct.SearchFrame.Search, true) end)
	end
end

local DAMouse = Players.LocalPlayer.GetMouse(Players.LocalPlayer)

local Settings = {
	["Prefix"] = ";",
	["PluginsTable"] = {},
	["daflyspeed"] = 1,
	["vehicleflyspeed"] = 1,
	["cframeflyspeed"] = 1,
	["gyroflyspeed"] = 3,
	["ChatLogs"] = false,
	["JoinLogs"] = false,
	["KeepDA"] = false,
	["AutoNet"] = false,
	["cmdautorj"] = false,
	["disablenotifications"] = false,
	["undetectedcmdbar"] = false,
	["Widebar"] = false,
}

local cmds = {}
local customAlias = {}
local AdminDebug = false
local Settings_Path = "Dark Admin/Settings.json"

local CommandsLoaded = false
local BrowserLoaded = false
local ScriptTabLoaded = false
local IsDaUi = false
local PluginCache = nil
local Loaded_Title = Import("osdate.lua")
local wfile_cooldown = false
local topCommand = nil
local tabComplete = nil
local origsettings = {
	["Lighting"] = {
		["abt"] = Lighting.Ambient,
		["oabt"] = Lighting.OutdoorAmbient,
		["brt"] = Lighting.Brightness,
		["time"] = Lighting.ClockTime,
		["fe"] = Lighting.FogEnd,
		["fs"] = Lighting.FogStart,
		["gs"] = Lighting.GlobalShadows,
	},
	["Player"] = {
		["Id"] = Players.LocalPlayer.UserId,
		["Ws"] = FindFirstChildWhichIsA(Players.LocalPlayer.Character, "Humanoid").WalkSpeed,
		["Jp"] = FindFirstChildWhichIsA(Players.LocalPlayer.Character, "Humanoid").JumpPower,
	},
	["Camera"] = {
		["Fov"] = workspace.CurrentCamera.FieldOfView,
	},
}
randomString = function() return string.gsub(string.gsub(GenerateGUID(HttpService, false), "-", ""), 1, math.random(25, 30)) end

--// Start of Command Variables \\--

local sethidden = sethiddenproperty or set_hidden_property or set_hidden_prop
local gethidden = gethiddenproperty or get_hidden_property or get_hidden_prop
local setsimulation = setsimulationradius or set_simulation_radius
local Network_Loop = nil
local ClientByp = nil
local currentToolSize = ""
local currentGripPos = ""
local cmdinfjump = false
local LastDeathPos = nil
local spawnpos = nil
local spawnpoint = false
local spDelay = 0.1
local WallTpTouch = nil
local walkto = false
local ESP = nil
local Locate = nil
local HumanModCons = {}
local StareLoop = nil
local FLYING = false
local GYROFLYING = false
local Floating = false
local CmdNoclipping = nil
local CmdClip = true
local invisRunning = false
local InvisSeat = false
local InvisWeld = false
local beforeInvisTransparency = {}
local viewing = nil
local isAutoClicking = false
local AutoclickerInput = nil
local AutomaticKeyPressing = false
local AutoKeyPressInput = nil
local frozenParts = {}
local FreezingUnanchored = nil
local ESPenabled = false
local swimming = false
local teleportWalking = false
local cmdflinging = false
local flingtbl = {}
local floatName = randomString()
local spinName = randomString()
local pointLightName = randomString()
local selectionBoxName = randomString()
local clientsidebypass = false
local QEfly = true
local spinhats = nil
local BubbleChatFix = nil
local CflyCon = nil
local KeyCodeMap = {["0"]=0x30,["1"]=0x31,["2"]=0x32,["3"]=0x33,["4"]=0x34,["5"]=0x35,["6"]=0x36,["7"]=0x37,["8"]=0x38,["9"]=0x39,["a"]=0x41,["b"]=0x42,["c"]=0x43,["d"]=0x44,["e"]=0x45,["f"]=0x46,["g"]=0x47,["h"]=0x48,["i"]=0x49,["j"]=0x4A,["k"]=0x4B,["l"]=0x4C,["m"]=0x4D,["n"]=0x4E,["o"]=0x4F,["p"]=0x50,["q"]=0x51,["r"]=0x52,["s"]=0x53,["t"]=0x54,["u"]=0x55,["v"]=0x56,["w"]=0x57,["x"]=0x58,["y"]=0x59,["z"]=0x5A,["enter"]=0x0D,["shift"]=0x10,["ctrl"]=0x11,["alt"]=0x12,["pause"]=0x13,["capslock"]=0x14,["caps"]=0x14,["spacebar"]=0x20,["space"]=0x20,["pageup"]=0x21,["pagedown"]=0x22,["end"]=0x23,["home"]=0x24,["left"]=0x25,["up"]=0x26,["right"]=0x27,["down"]=0x28,["insert"]=0x2D,["delete"]=0x2E,["f1"]=0x70,["f2"]=0x71,["f3"]=0x72,["f4"]=0x73,["f5"]=0x74,["f6"]=0x75,["f7"]=0x76,["f8"]=0x77,["f9"]=0x78,["f10"]=0x79,["f11"]=0x7A,["f12"]=0x7B}
local Keys = {}
local DA_Binds = {}
local FreecamAPI = Import("freecam.lua")
local ChatlogAPI = {}
local JoinlogAPI = {}
local HopTbl = {}
HopTbl.GetPublicServers = function(a)
	a = tonumber(a) or game.PlaceId
	local b, c = {}, ""
	while c do
		local d = "https://games.roblox.com/v1/games/" .. a .. "/servers/Public?sortOrder=Asc&limit=100" .. ((#c <= 0 and "") or ("&cursor=" .. c))
		local e = JSONDecode(HttpService, game.HttpGet(game, d))
		for _, v in ipairs(e.data) do
			b[#b + 1] = v
		end
		c = e.nextPageCursor
	end
	return b
end
local RolewatchData = {["Group"]=0,["Role"]="",["Leave"]=false}
local RolewatchConnection = CConnect(Players.PlayerAdded, function(player)
	if RolewatchData.Group == 0 then return end
	if player.IsInGroup(player, RolewatchData.Group) then
		if tostring(string.lower(player.GetRoleInGroup(player, RolewatchData.Group))) == string.lower(RolewatchData.Role) then
			if RolewatchData.Leave == true then
				Players.LocalPlayer.Kick(Players.LocalPlayer, "\n\nRolewatch\nPlayer \"" .. tostring(player.Name) .. "\" has joined with the Role \"" .. RolewatchData.Role .. "\"\n")
			else
				notify("Rolewatch", "Player \"" .. tostring(player.Name) .. "\" has joined with the Role \"" .. RolewatchData.Role .. "\"")
			end
		end
	end
end)
local headSitting1 = nil
local headSitting2 = nil

--// End of Command Variables \\--

CConnect(FindFirstChildWhichIsA(Players.LocalPlayer.Character, "Humanoid").Died, function()
	if getRoot(Players.LocalPlayer.Character) then
		LastDeathPos = getRoot(Players.LocalPlayer.Character).CFrame
	end
end)

CConnect(Players.LocalPlayer.OnTeleport, function(State)
	if State == Enum.TeleportState.Started then
		if Settings.KeepDA then
			syn.queue_on_teleport("loadstring(game.HttpGetAsync(game, \"https://raw.githubusercontent.com/Ballbuster9000/who/main/a/test/what/script.lua\"))();")
		end
	end
end)

CConnect(Players.LocalPlayer.CharacterAdded, function()
	NOFLY()
	FLYING = false
	GYROFLYING = false
	Floating = false
	CmdClip = true
	invisRunning = false
	teleportWalking = false
	repeat wait() until getRoot(Players.LocalPlayer.Character)
	execCmd("clip nonotify")
	pcall(function()
		if spawnpoint and spawnpos ~= nil then
			wait(spDelay)
			getRoot(Players.LocalPlayer.Character).CFrame = spawnpos
		end
	end)
	CConnect(FindFirstChildWhichIsA(Players.LocalPlayer.Character, "Humanoid").Died, function()
		if getRoot(Players.LocalPlayer.Character) then
			LastDeathPos = getRoot(Players.LocalPlayer.Character).CFrame
		end
	end)
end)

local RBXPrompt = FindFirstChild(CoreGui, "RobloxPromptGui")
CConnect(FindFirstChildWhichIsA(RBXPrompt, "Frame").DescendantAdded, function(Overlay)
	if cmdautorj then
		if Overlay.Name == "ErrorTitle" then
			CWait(GetPropertyChangedSignal(Overlay, "Text"))
			if Overlay.Text == "Disconnected" then
				if #GetPlayers(Players) <= 1 then
					Players.LocalPlayer.Kick(Players.LocalPlayer, "\nRejoining...")
					wait()
					TeleportService.Teleport(TeleportService, game.PlaceId, Players.LocalPlayer)
				else
					TeleportService.TeleportToPlaceInstance(TeleportService, game.PlaceId, game.JobId, Players.LocalPlayer)
				end
			end
		end
	end
end)

CConnect(UserInputService.InputBegan, function(Input, GameProccesed)
	if GameProccesed then return end
	local KeyCode = string.split(tostring(Input.KeyCode), ".")[3]
	Keys[KeyCode] = true
end)

CConnect(UserInputService.InputEnded, function(Input, GameProccesed)
	if GameProccesed then return end
	local KeyCode = string.split(tostring(Input.KeyCode), ".")[3]
	if Keys[KeyCode] then
		Keys[KeyCode] = false
	end
end)

local Time = function()
	local HOUR = math.floor((tick() % 86400) / 3600)
	local MINUTE = math.floor((tick() % 3600) / 60)
	local SECOND = math.floor(tick() % 60)
	local AP = HOUR > 11 and "PM" or "AM"
	HOUR = (HOUR % 12 == 0 and 12 or HOUR % 12)
	HOUR = HOUR < 10 and "0" .. HOUR or HOUR
	MINUTE = MINUTE < 10 and "0" .. MINUTE or MINUTE
	SECOND = SECOND < 10 and "0" .. SECOND or SECOND
	return HOUR .. ":" .. MINUTE .. ":" .. SECOND .. " " .. AP
end

local RunCode = function(funcToRun) funcToRun() end

local CleanFileName = function(str)
	str = tostring(str)
	local gSub = string.gsub
	str = gSub(str, "*", "")
	str = gSub(str, "\"", "")
	str = gSub(str, "\\", "")
	str = gSub(str, "?", "")
	str = gSub(str, ":", "")
	str = gSub(str, "<", "")
	str = gSub(str, ">", "")
	str = gSub(str, "|", "")
	return str
end

ChatlogAPI.loggedTable = {}
ChatlogAPI.folderPath = ("Dark Admin/Logs/")
ChatlogAPI.Scroll = DaUi.Pages.ChatLogs.LogResults
ChatlogAPI.BUD = UDim2.new(0, 0, 0, 0)
ChatlogAPI.TotalNum = 0
ChatlogAPI.gameName = CleanFileName(MarketplaceService.GetProductInfo(MarketplaceService, game.PlaceId).Name)

ChatlogAPI.getTotalSize = function()
	local totalSize = UDim2.new(0, 0, 0, 0)
	
	for i, v in next, ChatlogAPI.loggedTable do
		totalSize = totalSize + UDim2.new(0, 0, 0, v.Size.Y.Offset)
	end
	
	return totalSize
end

ChatlogAPI.GenLog = function(txt, colo, time)
	local oldColo = Color3.fromRGB(0, 0, 0)	
	
	local Temp = Clone(Assets["LogTemplate"])
	Temp.Parent = ChatlogAPI.Scroll
	Temp.Name = txt .. "Logged"
	Temp.Text = tostring(txt)
	Temp.Visible = true
	Temp.Position = ChatlogAPI.BUD + UDim2.new(0, 0, 0, 0)

	if colo then
		oldColo = colo Temp.TextColor3 = colo
	elseif not colo then
		Temp.TextColor3 = Color3.fromRGB(200, 200, 200)
	end

	local timeVal = InstanceNew("StringValue", Temp)
	timeVal.Name = "TimeVal"
	timeVal.Value = time

	ChatlogAPI.TotalNum = ChatlogAPI.TotalNum + 1
	
	if not Temp.TextFits then repeat Temp.Size = UDim2.new(Temp.Size.X.Scale, Temp.Size.X.Offset, Temp.Size.Y.Scale, Temp.Size.Y.Offset + 10)
		Temp.Text = txt
	until Temp.TextFits 
end

	ChatlogAPI.BUD = ChatlogAPI.BUD + UDim2.new(0, 0, 0, Temp.Size.Y.Offset)
	
	table.insert(ChatlogAPI.loggedTable, Temp)
	
	local totSize = ChatlogAPI.getTotalSize()
	
	if totSize.Y.Offset >= ChatlogAPI.Scroll.CanvasSize.Y.Offset then
		ChatlogAPI.Scroll.CanvasSize = UDim2.new(totSize.X.Scale, totSize.X.Offset, totSize.Y.Scale, totSize.Y.Offset + 1)
		ChatlogAPI.Scroll.CanvasPosition = ChatlogAPI.Scroll.CanvasPosition + Vector2.new(0, totSize.Y.Offset)
	end
	
	return Temp
end

ChatlogAPI.ChatData = ""

ChatlogAPI.SaveAllLogsToFile = function()
	local t = os.date("*t")
	local dateDat = (t["hour"] .. " " .. t["min"] .. " " .. t["sec"] .. " " .. t["day"] .. "." .. t["month"] .. "." .. t["year"])
	
	ChatlogAPI.ChatData = ""
	
	for i, v in pairs(GetChildren(ChatlogAPI.Scroll)) do
		ChatlogAPI.ChatData = (ChatlogAPI.ChatData .. v.TimeVal.Value .. " - " .. v.Text .. "\n")
	end

	local topSaveText = '-- Chat Logs for "'..ChatlogAPI.gameName..'"'
	writefile(ChatlogAPI.folderPath .. ChatlogAPI.gameName .. " - " .. dateDat .. ".txt", topSaveText .. "\n" .. ChatlogAPI.ChatData)
	notify("Chat Logs", "Check the Logs Folder")
end

ChatlogAPI.ClearAllChatLogs = function()
	ChatlogAPI.loggedTable = {}
	ChatlogAPI.ChatData = ""
	ChatlogAPI.Scroll.CanvasPosition = Vector2.new(0, 0)
	for i, v in pairs(GetChildren(ChatlogAPI.Scroll)) do
		Destroy(v)
	end
	ChatlogAPI.Scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
	ChatlogAPI.BUD = UDim2.new(0, 0, 0, 0)
end

ChatlogAPI.fixateUsername = function(plr)
    local result = ""
    plrName = tostring(plr.Name)
    if plrName ~= plr.DisplayName then
        result = plr.DisplayName .. " | @" .. plrName
    else
        result = plrName
    end
    return result
end

ChatlogAPI.LogUser = function(plr)
	CConnect(plr.Chatted, function(msg)
		if not Settings.ChatLogs then return end

		local t = os.date("*t")
		local dateDat = (t["hour"] .. ":" .. t["min"] .. ":" .. t["sec"])

		if string.len(msg) >= 1000 then return nil end
		if string.match(string.sub(msg, 1, 1), "%p") and string.match(string.sub(msg, 2, 2), "%a") and string.len(msg) >= 5 then
			ChatlogAPI.GenLog("[" .. ChatlogAPI.fixateUsername(plr) .. "]: " .. msg, Color3.new(255, 0, 0), dateDat)
		else
			ChatlogAPI.GenLog("[" .. ChatlogAPI.fixateUsername(plr) .. "]: " .. msg, Color3.new(255, 255, 255), dateDat)
		end
	end)
end

JoinlogAPI.loggedTable = {}
JoinlogAPI.folderPath = ("Dark Admin/Logs/")
JoinlogAPI.Scroll = DaUi.Pages.JoinLogs.LogResults
JoinlogAPI.BUD = UDim2.new(0, 0, 0, 0)
JoinlogAPI.TotalNum = 0
JoinlogAPI.gameName = CleanFileName(MarketplaceService.GetProductInfo(MarketplaceService, game.PlaceId).Name)

JoinlogAPI.getTotalSize = function()
	local totalSize = UDim2.new(0, 0, 0, 0)
	
	for i, v in next, JoinlogAPI.loggedTable do
		totalSize = totalSize + UDim2.new(0, 0, 0, v.Size.Y.Offset)
	end
	
	return totalSize
end

JoinlogAPI.GenLog = function(txt, colo, time)
	local oldColo = Color3.fromRGB(0, 0, 0)	
	
	local Temp = Clone(Assets["LogTemplate"])
	Temp.Parent = JoinlogAPI.Scroll
	Temp.Name = txt .. "Logged"
	Temp.Text = tostring(txt)
	Temp.Visible = true
	Temp.Position = JoinlogAPI.BUD + UDim2.new(0, 0, 0, 0)

	if colo then
		oldColo = colo Temp.TextColor3 = colo
	elseif not colo then
		Temp.TextColor3 = Color3.fromRGB(200, 200, 200)
	end

	local timeVal = InstanceNew("StringValue", Temp)
	timeVal.Name = "TimeVal"
	timeVal.Value = time

	JoinlogAPI.TotalNum = JoinlogAPI.TotalNum + 1
	
	if not Temp.TextFits then repeat Temp.Size = UDim2.new(Temp.Size.X.Scale, Temp.Size.X.Offset, Temp.Size.Y.Scale, Temp.Size.Y.Offset + 10)
		Temp.Text = txt
	until Temp.TextFits 
end

	JoinlogAPI.BUD = JoinlogAPI.BUD + UDim2.new(0, 0, 0, Temp.Size.Y.Offset)
	
	table.insert(JoinlogAPI.loggedTable, Temp)
	
	local totSize = JoinlogAPI.getTotalSize()
	
	if totSize.Y.Offset >= JoinlogAPI.Scroll.CanvasSize.Y.Offset then
		JoinlogAPI.Scroll.CanvasSize = UDim2.new(totSize.X.Scale, totSize.X.Offset, totSize.Y.Scale, totSize.Y.Offset + 1)
		JoinlogAPI.Scroll.CanvasPosition = JoinlogAPI.Scroll.CanvasPosition + Vector2.new(0, totSize.Y.Offset)
	end
	
	return Temp
end

JoinlogAPI.ChatData = ""

JoinlogAPI.SaveAllLogsToFile = function()
	local t = os.date("*t")
	local dateDat = (t["hour"] .. " " .. t["min"] .. " " .. t["sec"] .. " " .. t["day"] .. "." .. t["month"] .. "." .. t["year"])
	
	JoinlogAPI.ChatData = ""
	
	for i, v in pairs(GetChildren(JoinlogAPI.Scroll)) do
		JoinlogAPI.ChatData = (JoinlogAPI.ChatData .. v.TimeVal.Value .. " - " .. v.Text .. "\n")
	end

	local topSaveText = '-- Join and Leave Logs for "'..JoinlogAPI.gameName..'"'
	writefile(JoinlogAPI.folderPath .. JoinlogAPI.gameName .. " [Joins]" .. " - " .. dateDat .. ".txt", topSaveText .. "\n" .. JoinlogAPI.ChatData)
	notify("Join Logs", "Check the Logs Folder")
end

JoinlogAPI.ClearAllLogs = function()
	JoinlogAPI.loggedTable = {}
	JoinlogAPI.ChatData = ""
	JoinlogAPI.Scroll.CanvasPosition = Vector2.new(0, 0)
	for i, v in pairs(GetChildren(JoinlogAPI.Scroll)) do
		Destroy(v)
	end
	JoinlogAPI.Scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
	JoinlogAPI.BUD = UDim2.new(0, 0, 0, 0)
end

JoinlogAPI.fixateUser = function(plr, status)
	status = string.lower(tostring(status))
	local result = ""
	if status == "join" then
    	plrName = tostring(plr.Name)
		if plrName ~= plr.DisplayName then
			result = plr.DisplayName .. " (@" .. plrName .. ") " .. "Joined"
		else
			result = plrName .. " Joined"
		end
	end
	if status == "leave" then
    	plrName = tostring(plr.Name)
		if plrName ~= plr.DisplayName then
			result = plr.DisplayName .. " (@" .. plrName .. ") " .. "Left"
		else
			result = plrName .. " Left"
		end
	end
	return result
end

JoinlogAPI.LogJoin = function(plr)
	if not Settings.JoinLogs then return end

	local t = os.date("*t")
	local dateDat = (t["hour"] .. ":" .. t["min"] .. ":" .. t["sec"])

	JoinlogAPI.GenLog(JoinlogAPI.fixateUser(plr, "join"), Color3.new(255, 255, 255), dateDat)
end

JoinlogAPI.LogLeave = function(plr)
	if not Settings.JoinLogs then return end

	local t = os.date("*t")
	local dateDat = (t["hour"] .. ":" .. t["min"] .. ":" .. t["sec"])

	JoinlogAPI.GenLog(JoinlogAPI.fixateUser(plr, "leave"), Color3.new(255, 255, 255), dateDat)
end

CConnect(Players.PlayerAdded, function(player)
	JoinlogAPI.LogJoin(player)
	ChatlogAPI.LogUser(player)
	if ESPenabled then
		repeat wait() until player.Character and getRoot(player.Character)
		ESP(player)
		CConnect(player.CharacterAdded, function()
			repeat wait() until player.Character and getRoot(player.Character)
			ESP(player)
		end)
	end
end)

CConnect(Players.PlayerRemoving, function(player)
	if ESPenabled then
		for i,v in pairs(GetChildren(CoreGui)) do
			if v.Name == player.Name .. "_ESP" then
				Destroy(v)
			end
		end
	end
	JoinlogAPI.LogLeave(player)
	if viewing ~= nil and player == viewing then
		if findhum() then
			execCmd("unspectate nonotify")
			notify("Spectate", "Disabled (Player Left)")
		else
			notify("Spectate", "Missing Humanoid")
		end
	end
end)

local SmoothDrag = function(frame)
	local s, event = pcall(function() return frame.MouseEnter end)
	if s then
		frame.Active = true
		CConnect(event, function()
			local input = CConnect(frame.InputBegan, function(key)
				if key.UserInputType == Enum.UserInputType.MouseButton1 then
					local objectPosition = Vector2.new(DAMouse.X - frame.AbsolutePosition.X, DAMouse.Y - frame.AbsolutePosition.Y)
					while CWait(Heartbeat) and UserInputService.IsMouseButtonPressed(UserInputService, Enum.UserInputType.MouseButton1) do
						pcall(function()
							frame.TweenPosition(frame, UDim2.new(0, DAMouse.X - objectPosition.X, 0, DAMouse.Y - objectPosition.Y), "Out", "Linear", 0.1, true)
						end)
					end
				end
			end)
			local leave
			leave = CConnect(frame.MouseLeave, function()
				Disconnect(input)
				Disconnect(leave)
			end)
		end)
	end
end

ParentGui = function(Gui)
	Prote.ProtectInstance(Gui)
	Gui.Name = randomString()
	if (not is_sirhurt_closure) and (syn and syn.protect_gui) then
		syn.protect_gui(Gui)
		Gui.Parent = CoreGui
	elseif get_hidden_gui or gethui then
		local HiddenUI = get_hidden_gui or gethui
		Gui.Parent = HiddenUI()
	elseif FindFirstChild(CoreGui, "RobloxGui") then
		Gui.Parent = CoreGui["RobloxGui"]
	else
		Gui.Parent = CoreGui
	end
end

SmoothScroll = function(content, SmoothingFactor)
	content.ScrollingEnabled = false
	local input = Clone(content)
	input.ClearAllChildren(input)
	input.BackgroundTransparency = 1
	input.ScrollBarImageTransparency = 1
	input.ZIndex = content.ZIndex + 1
	input.Name = "_smoothinputframe"
	input.ScrollingEnabled = true
	input.Parent = content.Parent
	local syncProperty = function(prop)
		CConnect(GetPropertyChangedSignal(content, prop), function()
			if prop == "ZIndex" then
				input[prop] = content[prop] + 1
			else
				input[prop] = content[prop]
			end
		end)
	end
	syncProperty("CanvasSize")
	syncProperty("Position")
	syncProperty("Rotation")
	syncProperty("ScrollingDirection")
	syncProperty("ScrollBarThickness")
	syncProperty("BorderSizePixel")
	syncProperty("ElasticBehavior")
	syncProperty("SizeConstraint")
	syncProperty("ZIndex")
	syncProperty("BorderColor3")
	syncProperty("Size")
	syncProperty("AnchorPoint")
	syncProperty("Visible")
	local smoothConnection = CConnect(RenderStepped, function()
		local a = content.CanvasPosition
		local b = input.CanvasPosition
		local c = SmoothingFactor
		local d = (b - a) * c + a
		content.CanvasPosition = d
	end)
	CConnect(content.AncestryChanged, function()
		if not content.Parent then
			Destroy(input)
			Disconnect(smoothConnection)
		end
	end)
end

CaptureCmdBar = function()
	Cmdbar.CaptureFocus(Cmdbar)
	spawn(function()
		CWait(RenderStepped)
		Cmdbar.Text = ""
	end)
	spawn(function() CmdBarStatus(true) end)
end

local SetSimulationRadius = function()
	--[[
	spawn(function()
		Network_Loop = game:GetService("RunService").RenderStepped:Connect(function()
			pcall(function()
				workspace.FallenPartsDestroyHeight = 0/1/0
				settings().Physics.ThrottleAdjustTime = math.huge-math.huge
				settings().Physics.AllowSleep = false
				setsimulation(math.huge*math.huge,math.huge*math.huge,1/0*1/0*1/0*1/0*1/0)
				Players.LocalPlayer.SimulationRadius = math.huge
				Players.LocalPlayer.ReplicationFocus = workspace
			end)
		end)
	end)
	]]--
end

TweenObj = function(Object, Style, Direction, Time, Goal)
	local TInfo = TweenInfo.new(Time, Enum.EasingStyle[Style], Enum.EasingDirection[Direction])
	local Tween = TweenService.Create(TweenService, Object, TInfo, Goal)
	Tween.Play(Tween)
	return Tween
end

TweenAllTrans = function(Object, Time)
	local Tween
	Tween = TweenObj(Object, "Sine", "Out", Time, {
		BackgroundTransparency = 1
	})
	for _, v in ipairs(GetDescendants(Object)) do
		local IsText = IsA(v, "TextBox") or IsA(v, "TextLabel") or IsA(v, "TextButton")
		local IsImage = IsA(v, "ImageLabel") or IsA(v, "ImageButton")
		local IsScrollingFrame = IsA(v, "ScrollingFrame")
			if not IsA(v, "UIListLayout") then
				if IsText then
					TweenObj(v, "Sine", "Out", Time, {
						TextTransparency = 1,
						BackgroundTransparency = 1
					})
				elseif IsImage then
					TweenObj(v, "Sine", "Out", Time, {
						ImageTransparency = 1,
						BackgroundTransparency = 1
					})
				elseif IsScrollingFrame then
					TweenObj(v, "Sine", "Out", Time, {
						ScrollBarImageTransparency = 1,
						BackgroundTransparency = 1
					})
				else
					TweenObj(v, "Sine", "Out", Time, {
						BackgroundTransparency = 1
					})
			end
		end
	end
	return Tween
end

SetAllTrans = function(Object)
	Object.BackgroundTransparency = 1
	for _, v in ipairs(GetDescendants(Object)) do
		local IsText = IsA(v, "TextBox") or IsA(v, "TextLabel") or IsA(v, "TextButton")
		local IsImage = IsA(v, "ImageLabel") or IsA(v, "ImageButton")
		local IsScrollingFrame = IsA(v, "ScrollingFrame")
		if not IsA(v, "UIListLayout") then	
			v.BackgroundTransparency = 1
			if IsText then
				v.TextTransparency = 1
			elseif IsImage then
				v.ImageTransparency = 1
			elseif IsScrollingFrame then
				v.ScrollBarImageTransparency = 1
			end
		end
	end
end

TweenAllTransToObject = function(Object, Time, BeforeObject)
    local OldDescentants = GetDescendants(BeforeObject)
    local Tween
    Tween = TweenObj(Object, "Sine", "Out", Time, {
        BackgroundTransparency = BeforeObject.BackgroundTransparency
    })
    for i, v in next, GetDescendants(Object) do
        local IsText = IsA(v, "TextBox") or IsA(v, "TextLabel") or IsA(v, "TextButton")
        local IsImage = IsA(v, "ImageLabel") or IsA(v, "ImageButton")
        local IsScrollingFrame = IsA(v, "ScrollingFrame")
        if not IsA(v, "UIListLayout") then
            if IsText then
                TweenObj(v, "Sine", "Out", Time, {
                    TextTransparency = OldDescentants[i].TextTransparency,
                    TextStrokeTransparency = OldDescentants[i].TextStrokeTransparency,
                    BackgroundTransparency = OldDescentants[i].BackgroundTransparency
                })
            elseif IsImage then
                TweenObj(v, "Sine", "Out", Time, {
                    ImageTransparency = OldDescentants[i].ImageTransparency,
                    BackgroundTransparency = OldDescentants[i].BackgroundTransparency
                })
            elseif IsScrollingFrame then
                TweenObj(v, "Sine", "Out", Time, {
                    ScrollBarImageTransparency = OldDescentants[i].ScrollBarImageTransparency,
                    BackgroundTransparency = OldDescentants[i].BackgroundTransparency
                })
            else
                TweenObj(v, "Sine", "Out", Time, {
                    BackgroundTransparency = OldDescentants[i].BackgroundTransparency
                })
            end
        end
    end
    return Tween
end

local removeCutOff = function(Object)
    local Container = InstanceNew("Frame")
    local Hitbox = InstanceNew("ImageButton")
    Container.Name = "Container"
    Container.Parent = Object.Parent
    Container.BackgroundTransparency = 1.000
    Container.BorderSizePixel = 0
    Container.Position = Object.Position
    Container.ClipsDescendants = true
    Container.Size = UDim2.fromOffset(Object.AbsoluteSize.X, Object.AbsoluteSize.Y)
    Container.ZIndex = Object
    Object.AutomaticSize = Enum.AutomaticSize.X
    Object.Size = UDim2.fromScale(1, 1)
    Object.Position = UDim2.fromScale(0, 0)
    Object.Parent = Container
    Object.TextTruncate = Enum.TextTruncate.None
    Object.ZIndex = Object.ZIndex + 2
    Hitbox.Name = "Hitbox"
    Hitbox.Parent = Container.Parent
    Hitbox.BackgroundTransparency = 1.000
    Hitbox.Size = Container.Size
    Hitbox.Position = Container.Position
    Hitbox.ZIndex = Object.ZIndex + 2
    local MouseOut = true
    CConnect(Hitbox.MouseEnter, function()
        if Object.AbsoluteSize.X > Container.AbsoluteSize.X then
            MouseOut = false
            repeat
                local Tween1 = TweenObj(Object, "Quad", "Out", 0.5, {
                    Position = UDim2.fromOffset(Container.AbsoluteSize.X - Object.AbsoluteSize.X, 0)
                })
                CWait(Tween1.Completed)
                wait(2)
                local Tween2 = TweenObj(Object, "Quad", "Out", 0.5, {
                    Position = UDim2.fromOffset(0, 0)
                })
                CWait(Tween2.Completed)
                wait(2)
            until MouseOut
        end
    end)
    CConnect(Hitbox.MouseLeave, function()
        MouseOut = true
        TweenObj(Object, "Quad", "Out", 0.25, {
            Position = UDim2.fromOffset(0, 0)
        })
    end)
    return Object
end

CmdBarStatus = function(bool)
	if bool then
		TweenObj(Main, "Quint", "Out", 0.5, {
			["Position"] = UDim2.new(0.5, Settings.Widebar and -200 or -100, 1, -110)
		})
	else
		TweenObj(Main, "Quint", "Out", 0.5, {
			["Position"] = UDim2.new(0.5, Settings.Widebar and -200 or -100, 1, 5)
		})
	end
end

CmdListStatus = function(bool)
	if bool then
		TweenObj(CommandsGui, "Quint", "Out", 0.3, {
			Position = UDim2.new(0.694, -75, 0.656, -105)
		})
	else
		TweenObj(CommandsGui, "Quint", "Out", 0.5, {
			Position = UDim2.new(0.694, -75, 10, -105)
		})
	end
end

PlugBrowseStatus = function(bool)
	if bool then
		TweenObj(PluginBrowser, "Quint", "Out", 0.3, {
			Position = UDim2.new(0.42, -75, 0.512, -105)
		})
	else
		TweenObj(PluginBrowser, "Quint", "Out", 0.5, {
			Position = UDim2.new(0.42, -75, 2, -105)
		})
	end
end

DaUiStatus = function(bool)
	IsDaUi = bool
	if bool then
		TweenObj(UiDragF, "Quint", "Out", .3, {
			Position = UDim2.new(0.5, -200, 0.5, -125)
		})
	else
		TweenObj(UiDragF, "Quint", "Out", .5, {
			Position = UDim2.new(0.5, -200, 1.8, -125)
		})
	end
end

notify = function(Title, Message, Duration)
	if Settings.disablenotifications then return end
	spawn(function()
		local Notification = Clone(NotificationTemplate)
		local Desc = tostring(Message)
		local TweenDestroy = function()
			if Notification then
				local Tween = TweenAllTrans(Notification, 0.25)
				CWait(Tween.Completed)
				Destroy(Notification)
			end
		end
		if Title == ("" or " " or nil) then
			Notification.Title.Text = "Notification"
		else
			Notification.Title.Text = Title
		end
		if Desc == ("" or " " or nil) then
			Notification.Description.Text = "Message"
		else
			Notification.Description.Text = Desc
		end
		SetAllTrans(Notification)
		Notification.Visible = true
		if string.len(Desc) >= 35 then
			Notification.AutomaticSize = Enum.AutomaticSize.Y
			Notification.Description.AutomaticSize = Enum.AutomaticSize.Y
			Notification.Description.RichText = true
			Notification.Description.TextScaled = false
			Notification.Description.TextYAlignment = Enum.TextYAlignment.Top
			Notification.Shadow.AutomaticSize = Enum.AutomaticSize.Y
		end
		Notification.Parent = GUI.NotificationList
		coroutine.wrap(function()
			local Tween = TweenAllTransToObject(Notification, 0.5, NotificationTemplate)
			CWait(Tween.Completed)
			wait(Duration or 5)
			if Notification then TweenDestroy() end
		end)()
		CConnect(Notification.Close.MouseButton1Down, function() TweenDestroy() end)
		return TweenDestroy
	end)
end

local bignotify = function(Title, Message, Duration)
	if Settings.disablenotifications then return end
	spawn(function()
		local Notification = Clone(NotificationTemplate)
		local Desc = tostring(Message)
		local TweenDestroy = function()
			if Notification then
				local Tween = TweenAllTrans(Notification, 0.25)
				CWait(Tween.Completed)
				Destroy(Notification)
			end
		end
		if Title == ("" or " " or nil) then
			Notification.Title.Text = "Notification"
		else
			Notification.Title.Text = Title
		end
		if Desc == ("" or " " or nil) then
			Notification.Description.Text = "Message"
		else
			Notification.Description.Text = Desc
		end
		SetAllTrans(Notification)
		Notification.Visible = true
		Notification.AutomaticSize = Enum.AutomaticSize.Y
		Notification.Description.AutomaticSize = Enum.AutomaticSize.Y
		Notification.Description.RichText = true
		Notification.Description.TextScaled = false
		Notification.Description.TextYAlignment = Enum.TextYAlignment.Top
		Notification.Shadow.AutomaticSize = Enum.AutomaticSize.Y
		Notification.Parent = GUI.NotificationList
		coroutine.wrap(function()
			local Tween = TweenAllTransToObject(Notification, 0.5, NotificationTemplate)
			CWait(Tween.Completed)
			wait(Duration or 5)
			if Notification then TweenDestroy() end
		end)()
		CConnect(Notification.Close.MouseButton1Down, function() TweenDestroy() end)
		return TweenDestroy
	end)
end

isNumber = function(str)
	if tonumber(str) ~= nil or str == "inf" then
		return true
	end
end

FindInTable = function(tbl,val)
	if not tbl then return false end
	for _, v in pairs(tbl) do
		if v == val then return true end
	end 
	return false
end

ClearTable = function(tbl)
	if not tbl then return end
	if type(tbl) == "table" then
		for key in pairs(tbl) do
			tbl[key] = nil
		end
	end
end

SetTableContents = function(tbl, bool)
	if not tbl then return end
	if not bool then bool = false end
	if type(tbl) == "table" then
		for key in pairs(tbl) do
			tbl[key] = bool
		end
	end
end

getRoot = function(_char)
	local _character = nil
	if _char == nil then _character = Players.LocalPlayer.Character else _character = _char end
	local RootPart = FindFirstChild(_character, "HumanoidRootPart") or FindFirstChild(_character, "Torso") or FindFirstChild(_character, "UpperTorso")
	return RootPart
end

SetLocalAnimate = function(ch, val)
	if ch ~= nil then
		local AnimateScript = ch["Animate"]
		AnimateScript = IsA(AnimateScript, "LocalScript") and AnimateScript or nil
		if AnimateScript then
			Prote.SpoofProperty(AnimateScript, "Disabled")
			AnimateScript.Disabled = val
		end
	else
		local AnimateScript = Players.LocalPlayer.Character["Animate"]
		AnimateScript = IsA(AnimateScript, "LocalScript") and AnimateScript or nil
		if AnimateScript then
			Prote.SpoofProperty(AnimateScript, "Disabled")
			AnimateScript.Disabled = ch
		end
	end
end

r15 = function(speaker)
	local Humanoid = FindFirstChildOfClass(speaker.Character, "Humanoid")
	if (Humanoid.RigType == Enum.HumanoidRigType.R15) then
		return true
	else
		return false
	end
end

tools = function(plr)
	local Backpack = FindFirstChildOfClass(plr, "Backpack")
	if FindFirstChildOfClass(Backpack, "Tool") or FindFirstChildOfClass(plr.Character, "Tool") then
		return true
	else
		notify("Command Error", "Tool Required to Run Command.")
		return false
	end
end

toClipboard = function(String)
	local clipBoard = setclipboard or toclipboard or set_clipboard or (Clipboard and Clipboard.set)
	if clipBoard then
		clipBoard(String)
		notify("Clipboard", "Copied")
	else
		print("[da]: " .. String)
		notify("Clipboard Error", "Can't use clipboard, printed instead")
	end
end

GetInTable = function(Table, Name)
	for i = 1, #Table do
		if Table[i] == Name then
			return i
		end
	end
	return false
end

local fixcam = function(speaker)
	FreecamAPI.Stop()
	Destroy(workspace.CurrentCamera)
	wait(0.1)
	repeat wait() until speaker.Character ~= nil
	workspace.CurrentCamera.CameraSubject = FindFirstChildWhichIsA(speaker.Character, "Humanoid")
	workspace.CurrentCamera.CameraType = "Custom"
	speaker.CameraMinZoomDistance = 0.5
	speaker.CameraMaxZoomDistance = 400
	speaker.CameraMode = "Classic"
	speaker.Character.Head.Anchored = false
end

findCmd = function(cmd_name)
	for i,v in pairs(cmds) do
		if string.lower(v.NAME) == string.lower(cmd_name) or FindInTable(v.ALIAS, string.lower(cmd_name)) then
			return v
		end
	end
	return customAlias[string.lower(cmd_name)]
end

splitString = function(str, delim)
	local broken = {}
	if not delim then delim = "," end
	for w in string.gmatch(str, "[^" .. delim .. "]+") do
		table.insert(broken, w)
	end
	return broken
end

local cmdHistory = {}
local lastCmds = {}
local historyCount = 0
local split = " "
local lastBreakTime = 0
execCmd = function(cmdStr, speaker, store)
	cmdStr = string.gsub(cmdStr, "%s+$", "")
	spawn(function()
		local rawCmdStr = cmdStr
		cmdStr = string.gsub(cmdStr, "\\\\", "%%BackSlash%%")
		local commandsToRun = splitString(cmdStr, "\\")
		for i,v in pairs(commandsToRun) do
			v = string.gsub(v, "%%BackSlash%%", "\\")
			local x, y, num = string.find(v, "^(%d+)%^")
			local cmdDelay = 0
			local infTimes = false
			if num then
				v = string.sub(v, y + 1)
				local x, y, del = string.find(v, "^([%d%.]+)%^")
				if del then
					v = string.sub(v, y + 1)
					cmdDelay = tonumber(del) or 0
				end
			else
				local x,y = string.find(v, "^inf%^")
				if x then
					infTimes = true
					v = string.sub(v, y + 1)
					local x, y, del = string.find(v, "^([%d%.]+)%^")
					if del then
						v = string.sub(v, y + 1)
						del = tonumber(del) or 1
						cmdDelay = (del > 0 and del or 1)
					else
						cmdDelay = 1
					end
				end
			end
			num = tonumber(num or 1)
			if string.sub(v, 1, 1) == "!" then
				local chunks = splitString(string.sub(v, 2), split)
				if chunks[1] and lastCmds[chunks[1]] then v = lastCmds[chunks[1]] end
			end
			local args = splitString(v,split)
			local cmdName = args[1]
			local cmd = findCmd(cmdName)
			if cmd then
				table.remove(args, 1)
				cargs = args
				if not speaker then speaker = Players.LocalPlayer end
				if store then
					if speaker == Players.LocalPlayer then
						if cmdHistory[1] ~= rawCmdStr and string.sub(rawCmdStr, 1, 11) ~= "lastcommand" and string.sub(rawCmdStr, 1, 7) ~= "lastcmd" then
							table.insert(cmdHistory, 1, rawCmdStr)
						end
					end
					if #cmdHistory > 30 then table.remove(cmdHistory) end
					lastCmds[cmdName] = v
				end
				local cmdStartTime = tick()
				if infTimes then
					while lastBreakTime < cmdStartTime do
						local success,err = pcall(cmd.FUNC, args, speaker)
						if not success and AdminDebug then
							warn("Command Error:", cmdName, err)
						end
						wait(cmdDelay)
					end
				else
					for rep = 1,num do
						if lastBreakTime > cmdStartTime then break end
						local success, err = pcall(function()
							cmd.FUNC(args, speaker)
						end)
						if not success and AdminDebug then
							warn("Command Error:", cmdName, err)
						end
						if cmdDelay ~= 0 then wait(cmdDelay) end
					end
				end
			end
		end
	end)
end

getstring = function(begin)
	local start = begin - 1
	local AA = "" for i,v in pairs(cargs) do
		if i > start then
			if AA ~= "" then
				AA = AA .. " " .. v
			else
				AA = AA .. v
			end
		end
	end
	return AA
end

addcmd = function(name, alias, title, desc, func, plgn, plgnn)
	cmds[#cmds + 1] = {
		["NAME"] = name,
		["ALIAS"] = alias or {},
		["TITLE"] = title,
		["DESC"] = desc,
		["FUNC"] = func,
		["PLUGIN"] = plgn,
		["PLUGNN"] = plgnn or ""
	}
end

local removecmd_cmdarea = function(cmd)
	if cmd ~= " " then
		for i = #cmds,1,-1 do
			if cmds[i].NAME == cmd or FindInTable(cmds[i].ALIAS, cmd) then
				table.remove(cmds, i)
				for a,c in pairs(GetChildren(DaUi.CmdArea.ScrollingFrame)) do
					if string.find(c.Text, "^" .. cmd .. "$") or string.find(c.Text, "^" .. cmd .. " ") or string.find(c.Text, " " .. cmd .. "$") or string.find(c.Text, " " .. cmd .. " ") then
						c.TextTransparency = 0.7
						CConnect(c.MouseButton1Click, function()
							notify(c.Text, "Disabled by you or a plugin")
						end)
					end
				end
			end
		end
	end
end

removecmd = function(cmd)
	spawn(function() removecmd_cmdarea(cmd) end)
	if cmd ~= " " then
		for i = #cmds,1,-1 do
			if cmds[i].NAME == cmd or FindInTable(cmds[i].ALIAS, cmd) then
				table.remove(cmds, i)
				for a,c in pairs(GetChildren(DaUi.Pages.Commands.Results)) do
					if string.find(c.Text, "^" .. cmd .. "$") or string.find(c.Text, "^" .. cmd .. " ") or string.find(c.Text, " " .. cmd .. "$") or string.find(c.Text, " " .. cmd .. " ") then
						c.TextTransparency = 0.7
						CConnect(c.MouseButton1Click, function()
							notify(c.Text, "Disabled by you or a plugin")
						end)
					end
				end
			end
		end
	end
end

replacecmd = function(cmd, func)
	if cmd ~= " " then
		if type(func) == "function" then
			cmd = string.lower(cmd)
			for i = #cmds,1,-1 do
				if cmds[i].NAME == cmd or FindInTable(cmds[i].ALIAS, cmd) then
					cmds[i].FUNC = func
				end
			end
		end
	end
end

gethum = function(ch) return (ch and FindFirstChildWhichIsA(ch, "Humanoid")) or (Players.LocalPlayer and FindFirstChildWhichIsA(Players.LocalPlayer.Character, "Humanoid")) end
getbp = function(ch) return (ch and FindFirstChildWhichIsA(ch, "Backpack")) or (Players.LocalPlayer and FindFirstChildWhichIsA(Players.LocalPlayer, "Backpack")) end
findhum = function(ch)
	if ch ~= nil then
		if ch and FindFirstChildWhichIsA(ch, "Humanoid") then
			return true
		else
			return false
		end
	else
		if Players.LocalPlayer and FindFirstChildWhichIsA(Players.LocalPlayer.Character, "Humanoid") then
			return true
		else
			return false
		end
	end
end
findbp = function(ch)
	if ch ~= nil then
		if ch and FindFirstChildWhichIsA(ch, "Backpack") then
			return true
		else
			return false
		end
	else
		if Players.LocalPlayer and FindFirstChildWhichIsA(Players.LocalPlayer, "Backpack") then
			return true
		else
			return false
		end
	end
end

local SpecialPlayerCases = {
	["all"] = function(speaker) return GetPlayers(Players) end,
	["others"] = function(speaker)
		local plrs = {}
		for i,v in pairs(GetPlayers(Players)) do
			if v ~= speaker then
				table.insert(plrs, v)
			end
		end
		return plrs
	end,
	["me"] = function(speaker) return {speaker} end,
	["#(%d+)"] = function(speaker, args, currentList)
		local returns = {}
		local randAmount = tonumber(args[1])
		local players = {unpack(currentList)}
		for i = 1,randAmount do
			if #players == 0 then break end
			local randIndex = math.random(1, #players)
			table.insert(returns, players[randIndex])
			table.remove(players, randIndex)
		end
		return returns
	end,
	["random"] = function(speaker, args, currentList)
		local players = GetPlayers(Players)
		local localplayer = Players.LocalPlayer
		table.remove(players, table.find(players, localplayer))
		return {players[math.random(1, #players)]}
	end,
	["%%(.+)"] = function(speaker, args)
		local returns = {}
		local team = args[1]
		for _,plr in pairs(GetPlayers(Players)) do
			if plr.Team and string.sub(string.lower(plr.Team.Name), 1, #team) == string.lower(team) then
				table.insert(returns, plr)
			end
		end
		return returns
	end,
	["allies"] = function(speaker)
		local returns = {}
		local team = speaker.Team
		for _,plr in pairs(GetPlayers(Players)) do
			if plr.Team == team then
				table.insert(returns, plr)
			end
		end
		return returns
	end,
	["enemies"] = function(speaker)
		local returns = {}
		local team = speaker.Team
		for _,plr in pairs(GetPlayers(Players)) do
			if plr.Team ~= team then
				table.insert(returns, plr)
			end
		end
		return returns
	end,
	["team"] = function(speaker)
		local returns = {}
		local team = speaker.Team
		for _,plr in pairs(GetPlayers(Players)) do
			if plr.Team == team then
				table.insert(returns, plr)
			end
		end
		return returns
	end,
	["nonteam"] = function(speaker)
		local returns = {}
		local team = speaker.Team
		for _,plr in pairs(GetPlayers(Players)) do
			if plr.Team ~= team then
				table.insert(returns, plr)
			end
		end
		return returns
	end,
	["friends"] = function(speaker, args)
		local returns = {}
		for _,plr in pairs(GetPlayers(Players)) do
			if plr.IsFriendsWith(plr, speaker.UserId) and plr ~= speaker then
				table.insert(returns, plr)
			end
		end
		return returns
	end,
	["nonfriends"] = function(speaker, args)
		local returns = {}
		for _,plr in pairs(GetPlayers(Players)) do
			if not plr.IsFriendsWith(plr, speaker.UserId) and plr ~= speaker then
				table.insert(returns, plr)
			end
		end
		return returns
	end,
	["guests"] = function(speaker, args)
		local returns = {}
		for _,plr in pairs(GetPlayers(Players)) do
			if plr.Guest then
				table.insert(returns, plr)
			end
		end
		return returns
	end,
	["bacons"] = function(speaker, args)
		local returns = {}
		for _,plr in pairs(GetPlayers(Players)) do
			if FindFirstChild(plr.Character, "Pal Hair") or FindFirstChild(plr.Character, "Kate Hair") then
				table.insert(returns, plr)
			end
		end
		return returns
	end,
	["age(%d+)"] = function(speaker, args)
		local returns = {}
		local age = tonumber(args[1])
		if not age then return end
		for _,plr in pairs(GetPlayers(Players)) do
			if plr.AccountAge <= age then
				table.insert(returns, plr)
			end
		end
		return returns
	end,
	["nearest"] = function(speaker, args, currentList)
		local speakerChar = speaker.Character
		if not speakerChar or not getRoot(speakerChar) then return end
		local lowest = math.huge
		local NearestPlayer = nil
		for _,plr in pairs(currentList) do
			if plr ~= speaker and plr.Character then
				local distance = plr.DistanceFromCharacter(plr, getRoot(speakerChar).Position)
				if distance < lowest then
					lowest = distance
					NearestPlayer = {plr}
				end
			end
		end
		return NearestPlayer
	end,
	["farthest"] = function(speaker, args, currentList)
		local speakerChar = speaker.Character
		if not speakerChar or not getRoot(speakerChar) then return end
		local highest = 0
		local Farthest = nil
		for _,plr in pairs(currentList) do
			if plr ~= speaker and plr.Character then
				local distance = plr.DistanceFromCharacter(plr, getRoot(speakerChar).Position)
				if distance > highest then
					highest = distance
					Farthest = {plr}
				end
			end
		end
		return Farthest
	end,
	["group(%d+)"] = function(speaker, args)
		local returns = {}
		local groupID = tonumber(args[1])
		for _,plr in pairs(GetPlayers(Players)) do
			if plr.IsInGroup(plr, groupID) then  
				table.insert(returns, plr)
			end
		end
		return returns
	end,
	["alive"] = function(speaker, args)
		local returns = {}
		for _,plr in pairs(GetPlayers(Players)) do
			if plr.Character and FindFirstChildOfClass(plr.Character, "Humanoid") and FindFirstChildOfClass(plr.Character, "Humanoid").Health > 0 then
				table.insert(returns, plr)
			end
		end
		return returns
	end,
	["dead"] = function(speaker, args)
		local returns = {}
		for _,plr in pairs(GetPlayers(Players)) do
			if (not plr.Character or not FindFirstChildOfClass(plr.Character, "Humanoid")) or FindFirstChildOfClass(plr.Character, "Humanoid").Health <= 0 then
				table.insert(returns, plr)
			end
		end
		return returns
	end,
	["rad(%d+)"] = function(speaker, args)
		local returns = {}
		local radius = tonumber(args[1])
		local speakerChar = speaker.Character
		if not speakerChar or not getRoot(speakerChar) then return end
		for _,plr in pairs(GetPlayers(Players)) do
			if plr.Character and getRoot(plr.Character) then
				local magnitude = (getRoot(plr.Character).Position-getRoot(speakerChar).Position).magnitude
				if magnitude <= radius then table.insert(returns, plr) end
			end
		end
		return returns
	end
}

toTokens = function(str)
	local tokens = {}
	for op,name in string.gmatch(str, "([+-])([^+-]+)") do table.insert(tokens, {Operator = op, Name = name}) end
	return tokens
end

onlyIncludeInTable = function(tab, matches)
	local matchTable = {}
	local resultTable = {}
	for i,v in pairs(matches) do matchTable[v.Name] = true end
	for i,v in pairs(tab) do if matchTable[v.Name] then table.insert(resultTable, v) end end
	return resultTable
end

removeTableMatches = function(tab, matches)
	local matchTable = {}
	local resultTable = {}
	for i,v in pairs(matches) do matchTable[v.Name] = true end
	for i,v in pairs(tab) do if not matchTable[v.Name] then table.insert(resultTable, v) end end
	return resultTable
end

getPlayersByName = function(Name)
	local Name, Len, Found = string.lower(Name), #Name, {}
	for _,v in pairs(GetPlayers(Players)) do
		if string.sub(Name, 0, 1) == "@" then
			if string.sub(string.lower(v.Name), 1, Len-1) == string.sub(Name, 2) then
				table.insert(Found, v)
			end
		else
			if string.sub(string.lower(v.Name), 1, Len) == Name or string.sub(string.lower(v.DisplayName), 1, Len) == Name then
				table.insert(Found, v)
			end
		end
	end
	return Found
end

getPlayer = function(list, speaker)
	if not list then return {speaker.Name} end
	local nameList = splitString(list, ",")

	local foundList = {}

	for _,name in pairs(nameList) do
		if string.sub(name, 1, 1) ~= "+" and string.sub(name,1,1) ~= "-" then name = "+" .. name end
		local tokens = toTokens(name)
		local initialPlayers = GetPlayers(Players)

		for i,v in pairs(tokens) do
			if v.Operator == "+" then
				local tokenContent = v.Name
				local foundCase = false
				for regex,case in pairs(SpecialPlayerCases) do
					local matches = {string.match(tokenContent, "^" .. regex .. "$")}
					if #matches > 0 then
						foundCase = true
						initialPlayers = onlyIncludeInTable(initialPlayers, case(speaker, matches, initialPlayers))
					end
				end
				if not foundCase then
					initialPlayers = onlyIncludeInTable(initialPlayers, getPlayersByName(tokenContent))
				end
			else
				local tokenContent = v.Name
				local foundCase = false
				for regex,case in pairs(SpecialPlayerCases) do
					local matches = {string.match(tokenContent, "^" .. regex .. "$")}
					if #matches > 0 then
						foundCase = true
						initialPlayers = removeTableMatches(initialPlayers, case(speaker, matches, initialPlayers))
					end
				end
				if not foundCase then
					initialPlayers = removeTableMatches(initialPlayers, getPlayersByName(tokenContent))
				end
			end
		end

		for i,v in pairs(initialPlayers) do table.insert(foundList, v) end
	end

	local foundNames = {}
	for i,v in pairs(foundList) do table.insert(foundNames, v.Name) end

	return foundNames
end

MatchSearch = function(str1, str2)
	return str1 == string.sub(str2, 1, #str1)
end

StringFind = function(tbl, str)
	if not tbl then return end
	if type(tbl) == "table" then
		for _, v in ipairs(tbl) do
			if MatchSearch(str, v) then
				return v
			end
		end
	end
end

local PlayerArgs = function(argument)
	local arg = string.lower(argument)
	local SpecialCases = {"all", "others", "random", "me", "nearest", "farthest", "allies", "enemies", "team", "nonteam", "friends", "nonfriends", "bacons", "nearest", "farthest", "alive", "dead"}
	return StringFind(SpecialCases, arg) or (function()
		for _, v in ipairs(GetPlayers(Players)) do
			local Name = string.lower(v.Name)
			if MatchSearch(arg, Name) then
				return Name
			end
		end
	end)()
end

local autoComplete = function(str, curText)
	local endingChar = {"[", "/", "(", " "}
	local stop = 0
	for i = 1, #str do
		local c = string.sub(str, i, i)
		if table.find(endingChar, c) then
			stop = i
			break
		end
	end
	curText = curText or Cmdbar.Text
	local subPos = 0
	local pos = 1
	local findRes = string.find(curText, "\\", pos)
	while findRes do
		subPos = findRes
		pos = findRes + 1
		findRes = string.find(curText, "\\", pos)
	end
	if string.sub(curText, subPos + 1, subPos + 1) == "!" then subPos = subPos + 1 end
	Cmdbar.Text = string.sub(curText, 1, subPos) .. string.sub(str, 1, stop - 1) .. " "
	wait()
	Cmdbar.Text = string.gsub(Cmdbar.Text, "\t", "")
	Cmdbar.CursorPosition = #Cmdbar.Text + 1
end

Match = function(name, str)
	str = string.gsub(str, "%W", "%%%1")
	return string.find(string.lower(name), string.lower(str)) and true
end

getprfx = function(strn)
	if string.sub(strn, 1, string.len(Settings.Prefix)) == Settings.Prefix then return {"cmd", string.len(Settings.Prefix) + 1}
	end return
end

do_exec = function(str, plr)
	str = string.gsub(str, "/e ", "")
	local t = getprfx(str)
	if not t then return end
	str = string.sub(str, t[2])
	if t[1] == "cmd" then
		execCmd(str, plr, true)
	end
end

CConnect(Cmdbar.FocusLost, function(enterPressed)
	CmdSu.Text = ""
	if tabComplete then Disconnect(tabComplete) end
end)

CConnect(GetPropertyChangedSignal(Cmdbar, "Text"), function()
	Cmdbar.Text = string.lower(Cmdbar.Text)
	CmdSu.Text = ""
	local InputText = Cmdbar.Text
	local Args = string.split(InputText, " ")
	local CmdArgs = cargs or {}
	if InputText == "" then return end
	for _, v in next, cmds do
		local Name = v.NAME
		local Aliases = v.ALIAS
		local FoundAlias = false
		if MatchSearch(InputText, Name) then
			CmdSu.Text = Name
			break
		end
		for _, v2 in next, Aliases do
			if MatchSearch(InputText, v2) then
				FoundAlias = true
				CmdSu.Text = v2
				break
			end
			if FoundAlias then break end
		end
	end
	for i,v in next, Args do
		if i > 1 and v ~= "" then
			local Predict = ""
			if #CmdArgs >= 1 then
				Predict = PlayerArgs(v) or Predict
			else
				Predict = PlayerArgs(v) or Predict
			end
			CmdSu.Text = string.sub(InputText, 1, #InputText - #Args[#Args]) .. Predict
			local split = string.split(v, ",")
			if next(split) then
				for i2, v2 in next, split do
					if i2 > 1 and v2 ~= "" then
						local PlayerName = PlayerArgs(v2)
						CmdSu.Text = string.sub(InputText, 1, #InputText - #split[#split]) .. (PlayerName or "")
					end
				end
			end
		end
	end
end)

CConnect(Cmdbar.Focused, function()
	tabComplete = CConnect(UserInputService.InputBegan, function(input, gameProcessed)
		if Cmdbar.IsFocused(Cmdbar) then
			if input.KeyCode == Enum.KeyCode.Tab then
				if CmdSu.Text == "" then
					autoComplete("commands")
				elseif CmdSu.Text == " " then
					autoComplete("commands")
				else
					if string.match(CmdSu.Text, " ") then
						Cmdbar.Text = CmdSu.Text
						wait()
						Cmdbar.Text = string.gsub(Cmdbar.Text, "\t", "")
						Cmdbar.CursorPosition = #Cmdbar.Text + 1
					else
						Cmdbar.Text = CmdSu.Text .. " "
						wait()
						Cmdbar.Text = string.gsub(Cmdbar.Text, "\t", "")
						Cmdbar.CursorPosition = #Cmdbar.Text + 1
					end
				end
			end
		else
			Disconnect(tabComplete)
		end
	end)
end)

addcmdtext = function(name, cmdname, aliases, desc, plug)
	local nametextlabel = string.lower(tostring(name))
	local cmdNamePicked = nil
	if plug ~= nil then
		cmdNamePicked = ("PLUGIN_" .. tostring(name))
	else
		cmdNamePicked = ("CMD_" .. tostring(name))
	end
	local CommandFrame = Clone(Assets.CmdFrame)
	local NewCommand = Clone(Assets.CmdAreaLabel)
	NewCommand.Parent = DaUi.Pages.Commands.Results
	NewCommand.Name = tostring(cmdNamePicked)
	NewCommand.Visible = true
	NewCommand.Label.Text = tostring(cmdname)
	CConnect(NewCommand.MouseButton1Down, function()
		FindFirstChild(CommandFrame, "Name").Text = ("Name: " .. nametextlabel)
		CommandFrame.Alias.Text = (#aliases > 0 and ("Aliases: " .. table.concat(aliases, ", ")) or "Aliases: There are no aliases")
		CommandFrame.Desc.Text = ("Description: " .. desc)
		CommandFrame.Parent = DaUi.Pages.Commands
		CommandFrame.Visible = true
	end)
	CConnect(DaUi.Menu.Commands.MouseButton1Down, function()
		CommandFrame.Visible = false
	end)
	CConnect(NewCommand.paste.MouseButton1Down, function()
		CaptureCmdBar()
		wait()
		autoComplete(tostring(NewCommand.Label.Text))
	end)
end

writefileExploit = function()
	if writefile then
		return true
	end
end

readfileExploit = function()
	if readfile then
		return true
	end
end

writefileCooldown = function(name, data)
	spawn(function()
		if not wfile_cooldown then
			wfile_cooldown = true
			writefile(name, data)
		else
			repeat wait() until not wfile_cooldown
			writefileCooldown(name, data)
		end
		wait(3)
		wfile_cooldown = false
	end)
end

local Defaults = JSONEncode(HttpService, Settings)
local nosaves = false
local loadedEventData = nil
local LoadSettings = nil
LoadSettings = function()
	if writefileExploit() then
		if pcall(function() readfile(Settings_Path) end) then
			if readfile(Settings_Path) ~= nil then
				local success, response = pcall(function()
					local json = JSONDecode(HttpService, readfile(Settings_Path))
					if json.Prefix ~= nil then Settings.Prefix = json.Prefix else Settings.Prefix = ";" end
					if json.PluginsTable ~= nil then Settings.PluginsTable = json.PluginsTable else Settings.PluginsTable = {} end
					if json.daflyspeed ~= nil then Settings.daflyspeed = json.daflyspeed else Settings.daflyspeed = 1 end
					if json.vehicleflyspeed ~= nil then Settings.vehicleflyspeed = json.vehicleflyspeed else Settings.vehicleflyspeed = 1 end
					if json.cframeflyspeed ~= nil then Settings.cframeflyspeed = json.cframeflyspeed else Settings.cframeflyspeed = 1 end
					if json.gyroflyspeed ~= nil then Settings.gyroflyspeed = json.gyroflyspeed else Settings.gyroflyspeed = 3 end
					if json.ChatLogs ~= nil then Settings.ChatLogs = json.ChatLogs else Settings.ChatLogs = false end
					if json.JoinLogs ~= nil then Settings.JoinLogs = json.JoinLogs else Settings.JoinLogs = false end
					if json.KeepDA ~= nil then Settings.KeepDA = json.KeepDA else Settings.KeepDA = false end
					if json.AutoNet ~= nil then Settings.AutoNet = json.AutoNet else Settings.AutoNet = false end
					if json.cmdautorj ~= nil then Settings.cmdautorj = json.cmdautorj else Settings.cmdautorj = false end
					if json.disablenotifications ~= nil then Settings.disablenotifications = json.disablenotifications else Settings.disablenotifications = false end
					if json.undetectedcmdbar ~= nil then Settings.undetectedcmdbar = json.undetectedcmdbar else Settings.undetectedcmdbar = false end
					if json.Widebar ~= nil then Settings.Widebar = json.Widebar else Settings.Widebar = false end
				end)
				if not success then
					warn("Save Json Error:", response)
					warn("Overwriting Save File")
					writefileCooldown(Settings_Path, Defaults)
					wait()
					LoadSettings()
				end
			else
				writefileCooldown(Settings_Path, Defaults)
				wait()
				LoadSettings()
			end
		else
			writefileCooldown(Settings_Path, Defaults)
			wait()
			if pcall(function() readfile(Settings_Path) end) then
				LoadSettings()
			else
				nosaves = true
				Settings.Prefix = ";"
				Settings.PluginsTable = {}
				Settings.daflyspeed = 1
				Settings.vehicleflyspeed = 1
				Settings.cframeflyspeed = 1
				Settings.gyroflyspeed = 3
				Settings.ChatLogs = false
				Settings.JoinLogs = false
				Settings.KeepDA = false
				Settings.AutoNet = false
				Settings.cmdautorj = false
				Settings.disablenotifications = false
				Settings.undetectedcmdbar = false
				Settings.Widebar = false
				notify("", "There was a problem writing a save file to your PC")
			end
		end
	else
		Settings.Prefix = ";"
		Settings.PluginsTable = {}
		Settings.daflyspeed = 1
		Settings.vehicleflyspeed = 1
		Settings.cframeflyspeed = 1
		Settings.gyroflyspeed = 3
		Settings.ChatLogs = false
		Settings.JoinLogs = false
		Settings.KeepDA = false
		Settings.AutoNet = false
		Settings.cmdautorj = false
		Settings.disablenotifications = false
		Settings.undetectedcmdbar = false
		Settings.Widebar = false
	end
end
LoadSettings()

updatesaves = function()
	if not nosaves and writefileExploit() then
		local update = {
			["Prefix"] = Settings.Prefix;
			["PluginsTable"] = Settings.PluginsTable;
			["daflyspeed"] = Settings.daflyspeed;
			["vehicleflyspeed"] = Settings.vehicleflyspeed;
			["cframeflyspeed"] = Settings.cframeflyspeed;
			["gyroflyspeed"] = Settings.gyroflyspeed;
			["ChatLogs"] = Settings.ChatLogs;
			["JoinLogs"] = Settings.JoinLogs;
			["KeepDA"] = Settings.KeepDA;
			["AutoNet"] = Settings.AutoNet;
			["cmdautorj"] = Settings.cmdautorj;
			["disablenotifications"] = Settings.disablenotifications;
			["undetectedcmdbar"] = Settings.undetectedcmdbar;
			["Widebar"] = Settings.Widebar;
		}
		writefileCooldown(Settings_Path, JSONEncode(HttpService, update))
	end
end

if Settings.undetectedcmdbar == true then Prote.UndetectedCommandbar(true) end

addPlugin = function(name)
	if string.lower(name) == "plugin file name" or string.lower(name) == "dark admin" or name == "settings" then
		notify("Plugin Error", "Please enter a valid plugin")
	else
		local file
		local fileName
		if string.sub(name, -3) == ".da" then
			pcall(function() file = readfile("Dark Admin/Plugins/" .. name) end)
			fileName = name
		else
			pcall(function() file = readfile("Dark Admin/Plugins/".. name .. ".da") end)
			fileName = name .. ".da"
		end
		if file then
			if not FindInTable(Settings.PluginsTable, fileName) then
				table.insert(Settings.PluginsTable, fileName)
				LoadPlugin(fileName)
			else
				notify("Plugin Error", "This plugin is already added")
			end
		else
			notify("Plugin Error", "Cannot locate file " .. "'" .. fileName .. "'" .. ".")
		end
	end
end

deletePlugin = function(name)
	local pName = name .. ".da"
	if string.sub(name, -3) == ".da" then
		pName = name
	end
	for i = #cmds,1,-1 do
		if cmds[i].PLUGNN == pName then
			table.remove(cmds, i)
		end
	end
	for i,v in pairs(GetChildren(DaUi.Pages.Commands.Results)) do
		if v.Name == "PLUGIN_" .. pName then
			Destroy(v)
		end
	end
	for i,v in pairs(Settings.PluginsTable) do
		if v == pName then
			table.remove(Settings.PluginsTable, i)
			notify("Removed Plugin", pName .. " was removed")
		end
	end
end

LoadPlugin = function(val, startup)
	local plugin

	CatchedPluginLoad = function()
		plugin = loadfile("Dark Admin/Plugins/" .. val)()
	end

	handlePluginError = function(plerror)
		notify("Plugin Error", val)
		if FindInTable(Settings.PluginsTable,val) then
			for i,v in pairs(Settings.PluginsTable) do
				if v == val then
					table.remove(Settings.PluginsTable, i)
				end
			end
		end
		updatesaves()

		print("Original Error: " .. tostring(plerror))
		print("Plugin Error, stack traceback: " .. tostring(debug.traceback()))

		plugin = nil

		return false
	end

	xpcall(CatchedPluginLoad, handlePluginError)

	if plugin ~= nil then
		if not startup then
			spawn(function()
				if plugin["PluginDescription"] ~= ("" or " " or nil) then
					bignotify("Loaded Plugin", "Name: " .. plugin["PluginName"] .. "\nDesc: " .. plugin["PluginDescription"])
				else
					notify("Loaded Plugin", "Name: " .. plugin["PluginName"])
				end
			end)
		end
		for i,v in pairs(plugin["Commands"]) do 
			local cmdExt = ""
			local cmdName = i
			local function handleNames()
				cmdName = i
				if findCmd(cmdName .. cmdExt) then
					if isNumber(cmdExt) then
						cmdExt = cmdExt + 1
					else
						cmdExt = 1
					end
					handleNames()
				else
					cmdName = cmdName .. cmdExt
				end
			end
			handleNames()
			if v["ListName"] then
				local newName = v["ListName"]
				local cmdNames = {i, unpack(v["Aliases"])}
				for i,v in pairs(cmdNames) do
					newName = string.gsub(newName, v, v .. cmdExt)
				end
				addcmd(cmdName, v["Aliases"], newName, v["Description"], v["Function"], true, val)
			else
				addcmd(cmdName, v["Aliases"], cmdName, v["Description"], v["Function"], true, val)
			end
			if CommandsLoaded then
				if v["ListName"] then
					local newName = v["ListName"]
					local cmdNames = {i, unpack(v["Aliases"])}
					for i,v in pairs(cmdNames) do
						newName = string.gsub(newName, v, v .. cmdExt)
					end
					addcmdtext(cmdName, newName, v["Aliases"], v["Description"], true)
				else
					addcmdtext(cmdName, cmdName, v["Aliases"], v["Description"], true)
				end
			end
		end
	elseif not plugin then
		plugin = nil
	end
end

local LoadAllPlugins = function()
	if Settings.PluginsTable ~= nil and type(Settings.PluginsTable) == "table" then
		for i,v in pairs(Settings.PluginsTable) do
			LoadPlugin(v, true)
		end
	end
end

local isXrayingObjects = false
local xrayobjects = function(bool)
	if bool == true then isXrayingObjects = true else isXrayingObjects = false end
	for i, v in next, GetDescendants(workspace) do
		if IsA(v, "Part") and v.Transparency <= 0.3 then
			Prote.SpoofProperty(v, "Transparency")
			Prote.SpoofProperty(v, "LocalTransparencyModifier")
			v.LocalTransparencyModifier = bool and 0.3 or 0
		end
	end
end

local GetHandleTools = function(p)
	p = p or Players.LocalPlayer
	local r = {}
	for _, v in ipairs(p.Character and GetChildren(p.Character) or {}) do
		if v.IsA(v, "BackpackItem") and v.FindFirstChild(v, "Handle") then
			r[#r + 1] = v
		end
	end
	for _, v in ipairs(GetChildren(p.Backpack)) do
		if v.IsA(v, "BackpackItem") and v.FindFirstChild(v, "Handle") then
			r[#r + 1] = v
		end
	end
	return r
end

local sFLY = function(vfly)
	repeat wait() until Players.LocalPlayer and Players.LocalPlayer.Character and getRoot(Players.LocalPlayer.Character) and FindFirstChildWhichIsA(Players.LocalPlayer.Character, "Humanoid")
	repeat wait() until DAMouse
	if flyKeyDown or flyKeyUp then Disconnect(flyKeyDown) Disconnect(flyKeyUp) end
	
	local CONTROL = {F = 0, B = 0, L = 0, R = 0, Q = 0, E = 0}
	local lCONTROL = {F = 0, B = 0, L = 0, R = 0, Q = 0, E = 0}
	local SPEED = 0

	local FLY = function()
		FLYING = true
		local BG = InstanceNew("BodyGyro")
		local BV = InstanceNew("BodyVelocity")
		Prote.ProtectInstance(BG)
		Prote.ProtectInstance(BV)
		BG.Parent = getRoot(Players.LocalPlayer.Character)
		BV.Parent = getRoot(Players.LocalPlayer.Character)
		BG.P = 9e4
		local T = getRoot(Players.LocalPlayer.Character)
		BG.Parent = T
		BV.Parent = T
		BG.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
		BG.CFrame = T.CFrame
		BV.Velocity = Vector3.new(0, 0, 0)
		BV.MaxForce = Vector3.new(9e9, 9e9, 9e9)
		Prote.SpoofProperty(gethum(), "PlatformStand")
		spawn(function()
			repeat wait()
				if not vfly and findhum() then
					local Human = gethum()
					Human.PlatformStand = true
				end
				if CONTROL.L + CONTROL.R ~= 0 or CONTROL.F + CONTROL.B ~= 0 or CONTROL.Q + CONTROL.E ~= 0 then
					SPEED = 50
				elseif not (CONTROL.L + CONTROL.R ~= 0 or CONTROL.F + CONTROL.B ~= 0 or CONTROL.Q + CONTROL.E ~= 0) and SPEED ~= 0 then
					SPEED = 0
				end
				if (CONTROL.L + CONTROL.R) ~= 0 or (CONTROL.F + CONTROL.B) ~= 0 or (CONTROL.Q + CONTROL.E) ~= 0 then
					BV.Velocity = ((workspace.CurrentCamera.CoordinateFrame.lookVector * (CONTROL.F + CONTROL.B)) + ((workspace.CurrentCamera.CoordinateFrame * CFrame.new(CONTROL.L + CONTROL.R, (CONTROL.F + CONTROL.B + CONTROL.Q + CONTROL.E) * 0.2, 0).p) - workspace.CurrentCamera.CoordinateFrame.p)) * SPEED
					lCONTROL = {F = CONTROL.F, B = CONTROL.B, L = CONTROL.L, R = CONTROL.R}
				elseif (CONTROL.L + CONTROL.R) == 0 and (CONTROL.F + CONTROL.B) == 0 and (CONTROL.Q + CONTROL.E) == 0 and SPEED ~= 0 then
					BV.Velocity = ((workspace.CurrentCamera.CoordinateFrame.lookVector * (lCONTROL.F + lCONTROL.B)) + ((workspace.CurrentCamera.CoordinateFrame * CFrame.new(lCONTROL.L + lCONTROL.R, (lCONTROL.F + lCONTROL.B + CONTROL.Q + CONTROL.E) * 0.2, 0).p) - workspace.CurrentCamera.CoordinateFrame.p)) * SPEED
				else
					BV.Velocity = Vector3.new(0, 0, 0)
				end
				BG.CFrame = workspace.CurrentCamera.CoordinateFrame
			until not FLYING
			CONTROL = {F = 0, B = 0, L = 0, R = 0, Q = 0, E = 0}
			lCONTROL = {F = 0, B = 0, L = 0, R = 0, Q = 0, E = 0}
			SPEED = 0
			Destroy(BG)
			Destroy(BV)
			if findhum() then
				local Human = gethum()
				Human.PlatformStand = true
			end
		end)
	end
	flyKeyDown = CConnect(DAMouse.KeyDown, function(KEY)
		if string.lower(KEY) == "w" then
			CONTROL.F = (vfly and Settings.vehicleflyspeed or Settings.daflyspeed)
		elseif string.lower(KEY) == "s" then
			CONTROL.B = - (vfly and Settings.vehicleflyspeed or Settings.daflyspeed)
		elseif string.lower(KEY) == "a" then
			CONTROL.L = - (vfly and Settings.vehicleflyspeed or Settings.daflyspeed)
		elseif string.lower(KEY) == "d" then 
			CONTROL.R = (vfly and Settings.vehicleflyspeed or Settings.daflyspeed)
		elseif QEfly and string.lower(KEY) == "e" then
			CONTROL.Q = (vfly and Settings.vehicleflyspeed or Settings.daflyspeed) * 2
		elseif QEfly and string.lower(KEY) == "q" then
			CONTROL.E = - (vfly and Settings.vehicleflyspeed or Settings.daflyspeed) * 2
		end
		pcall(function() workspace.CurrentCamera.CameraType = Enum.CameraType.Track end)
	end)
	flyKeyUp = CConnect(DAMouse.KeyUp, function(KEY)
		if string.lower(KEY) == "w" then
			CONTROL.F = 0
		elseif string.lower(KEY) == "s" then
			CONTROL.B = 0
		elseif string.lower(KEY) == "a" then
			CONTROL.L = 0
		elseif string.lower(KEY) == "d" then
			CONTROL.R = 0
		elseif string.lower(KEY) == "e" then
			CONTROL.Q = 0
		elseif string.lower(KEY) == "q" then
			CONTROL.E = 0
		end
	end)
	FLY()
end

NOFLY = function()
	FLYING = false
	if flyKeyDown or flyKeyUp then Disconnect(flyKeyDown) Disconnect(flyKeyUp) end
	pcall(function() workspace.CurrentCamera.CameraType = Enum.CameraType.Custom end)
	wait()
	execCmd("unstun")
end

r15 = function(speaker)
	local Humanoid = FindFirstChildWhichIsA(speaker.Character, "Humanoid")
	if Humanoid.RigType == Enum.HumanoidRigType.R15 then
		return true
	else
		return false
	end
end

local respawn = function(plr)
	local char = plr.Character
	char.ClearAllChildren(char)
	local newChar = InstanceNew("Model")
	Prote.ProtectInstance(newChar)
	newChar.Parent = workspace
	plr.Character = newChar
	wait()
	plr.Character = char
	Destroy(newChar)
end

local refresh = function(plr)
	spawn(function()
		refreshCmd = true
		local rpos = plr.Character.HumanoidRootPart.Position
		wait()
		respawn(plr)
		wait()
		repeat wait() until plr.Character and FindFirstChild(plr.Character, "HumanoidRootPart")
		wait(.1)
		if rpos then
			plr.Character.MoveTo(plr.Character, rpos)
			wait()
		end
		refreshCmd = false
	end)
end

local attach = function(speaker, target)
	if tools(speaker) then
		local chara = speaker.Character
		local hum = gethum(speaker.Character)
		local hrp = speaker.Character.HumanoidRootPart
		local hrp2 = target.Character.HumanoidRootPart
		hum.Name = "1"
		local newHum = Clone(hum)
		newHum.Parent = chara
		newHum.Name = "Humanoid"
		wait()
		Destroy(hum)
		workspace.CurrentCamera.CameraSubject = chara
		newHum.DisplayDistanceType = "None"
		local tool = FindFirstChildOfClass(getbp(speaker), "Tool") or FindFirstChildOfClass(speaker.Character, "Tool")
		Prote.SpoofInstance(tool)
		tool.Parent = chara
		hrp.CFrame = hrp2.CFrame * CFrame.new(0, 0, 0) * CFrame.new(math.random(-100, 100)/200,math.random(-100, 100)/200,math.random(-100, 100)/200)
		local n = 0
		repeat
			wait(0.1)
			n = n + 1
			hrp.CFrame = hrp2.CFrame
		until (tool.Parent ~= chara or not hrp or not hrp2 or not hrp.Parent or not hrp2.Parent or n > 250) and n > 2
	end
end

iRound = function(num, numDecimalPlaces)
	local mult = 10^(numDecimalPlaces or 0)
	return math.floor(num * mult + 0.5) / mult
end

ESP = function(plr)
	spawn(function()
		for i,v in pairs(GetChildren(CoreGui)) do
			if v.Name == plr.Name .. "_ESP" then
				Destroy(v)
			end
		end
		wait()
		if plr.Character and plr.Name ~= Players.LocalPlayer.Name and not FindFirstChild(CoreGui, plr.Name .. "_ESP") then
			local ESPholder = InstanceNew("Folder")
			Prote.ProtectInstance(ESPholder)
			ESPholder.Parent = CoreGui
			ESPholder.Name = plr.Name .. "_ESP"
			repeat wait() until plr.Character and getRoot(plr.Character) and FindFirstChildWhichIsA(plr.Character, "Humanoid")
			for b,n in pairs(GetChildren(plr.Character)) do
				if IsA(n, "BasePart") then
					local a = InstanceNew("BoxHandleAdornment")
					Prote.ProtectInstance(a)
					a.Parent = ESPholder
					a.Name = plr.Name
					a.Adornee = n
					a.AlwaysOnTop = true
					a.ZIndex = 10
					a.Size = n.Size
					a.Transparency = 0.3
					a.Color = plr.TeamColor
				end
			end
			if plr.Character and FindFirstChild(plr.Character, "Head") then
				local BillboardGui = InstanceNew("BillboardGui")
				Prote.ProtectInstance(BillboardGui)
				local TextLabel = InstanceNew("TextLabel")
				Prote.ProtectInstance(TextLabel)
				BillboardGui.Adornee = plr.Character.Head
				BillboardGui.Name = tostring(plr.Name)
				BillboardGui.Parent = ESPholder
				BillboardGui.Size = UDim2.new(0, 100, 0, 150)
				BillboardGui.StudsOffset = Vector3.new(0, 1, 0)
				BillboardGui.AlwaysOnTop = true
				TextLabel.Parent = BillboardGui
				TextLabel.BackgroundTransparency = 1
				TextLabel.Position = UDim2.new(0, 0, 0, -50)
				TextLabel.Size = UDim2.new(0, 100, 0, 100)
				TextLabel.Font = Enum.Font.SourceSansSemibold
				TextLabel.TextSize = 20
				TextLabel.TextColor3 = Color3.new(1, 1, 1)
				TextLabel.TextStrokeTransparency = 0
				TextLabel.TextYAlignment = Enum.TextYAlignment.Bottom
				TextLabel.Text = "Name: " .. tostring(plr.Name)
				TextLabel.ZIndex = 10
				local espLoopFunc
				local teamChange
				local addedFunc
				addedFunc = CConnect(plr.CharacterAdded, function()
					if ESPenabled then
						Disconnect(espLoopFunc)
						Disconnect(teamChange)
						Destroy(ESPholder)
						repeat wait() until getRoot(plr.Character) and FindFirstChildWhichIsA(plr.Character, "Humanoid")
						ESP(plr)
						Disconnect(addedFunc)
					else
						Disconnect(teamChange)
						Disconnect(addedFunc)
					end
				end)
				teamChange = CConnect(GetPropertyChangedSignal(plr, "TeamColor"), function()
					if ESPenabled then
						Disconnect(espLoopFunc)
						Disconnect(addedFunc)
						Destroy(ESPholder)
						repeat wait() until getRoot(plr.Character) and FindFirstChildWhichIsA(plr.Character, "Humanoid")
						ESP(plr)
						Disconnect(teamChange)
					else
						Disconnect(teamChange)
					end
				end)
				local espLoop = function()
					if FindFirstChild(CoreGui, plr.Name .. "_ESP") then
						if plr.Character and getRoot(plr.Character) and FindFirstChildWhichIsA(plr.Character, "Humanoid") and Players.LocalPlayer.Character and getRoot(Players.LocalPlayer.Character) and FindFirstChildWhichIsA(Players.LocalPlayer.Character, "Humanoid") then
							local pos = math.floor((getRoot(Players.LocalPlayer.Character).Position - getRoot(plr.Character).Position).magnitude)
							TextLabel.Text = ("Name: " .. tostring(plr.Name) .. " | Health: " .. tostring(iRound(FindFirstChildWhichIsA(plr.Character, "Humanoid").Health, 1)) .. " | Studs: " .. tostring(pos))
						end
					else
						Disconnect(teamChange)
						Disconnect(addedFunc)
						Disconnect(espLoopFunc)
					end
				end
				espLoopFunc = CConnect(RenderStepped, espLoop)
			end
		end
	end)
end

Locate = function(plr)
	spawn(function()
		for i,v in pairs(GetChildren(CoreGui)) do
			if v.Name == plr.Name .. "_LC" then
				Destroy(v)
			end
		end
		wait()
		if plr.Character and plr.Name ~= Players.LocalPlayer.Name and not FindFirstChild(CoreGui, plr.Name .. "_LC") then
			local ESPholder = InstanceNew("Folder")
			Prote.ProtectInstance(ESPholder)
			ESPholder.Parent = CoreGui
			ESPholder.Name = plr.Name .. "_LC"
			repeat wait() until plr.Character and getRoot(plr.Character) and FindFirstChildWhichIsA(plr.Character, "Humanoid")
			for b,n in pairs (GetChildren(plr.Character)) do
				if IsA(n, "BasePart") then
					local a = InstanceNew("BoxHandleAdornment")
					Prote.ProtectInstance(a)
					a.Name = plr.Name
					a.Parent = ESPholder
					a.Adornee = n
					a.AlwaysOnTop = true
					a.ZIndex = 10
					a.Size = n.Size
					a.Transparency = 0.3
					a.Color = plr.TeamColor
				end
			end
			if plr.Character and FindFirstChild(plr.Character, "Head") then
				local BillboardGui = InstanceNew("BillboardGui")
				Prote.ProtectInstance(BillboardGui)
				local TextLabel = InstanceNew("TextLabel")
				Prote.ProtectInstance(TextLabel)
				BillboardGui.Adornee = plr.Character.Head
				BillboardGui.Name = tostring(plr.Name)
				BillboardGui.Parent = ESPholder
				BillboardGui.Size = UDim2.new(0, 100, 0, 150)
				BillboardGui.StudsOffset = Vector3.new(0, 1, 0)
				BillboardGui.AlwaysOnTop = true
				TextLabel.Parent = BillboardGui
				TextLabel.BackgroundTransparency = 1
				TextLabel.Position = UDim2.new(0, 0, 0, -50)
				TextLabel.Size = UDim2.new(0, 100, 0, 100)
				TextLabel.Font = Enum.Font.SourceSansSemibold
				TextLabel.TextSize = 20
				TextLabel.TextColor3 = Color3.new(1, 1, 1)
				TextLabel.TextStrokeTransparency = 0
				TextLabel.TextYAlignment = Enum.TextYAlignment.Bottom
				TextLabel.Text = "Name: " .. tostring(plr.Name)
				TextLabel.ZIndex = 10
				local lcLoopFunc
				local addedFunc
				local teamChange
				addedFunc = CConnect(plr.CharacterAdded, function()
					if ESPholder ~= nil and ESPholder.Parent ~= nil then
						Disconnect(lcLoopFunc)
						Disconnect(teamChange)
						Destroy(ESPholder)
						repeat wait() until getRoot(plr.Character) and FindFirstChildWhichIsA(plr.Character, "Humanoid")
						Locate(plr)
						Disconnect(addedFunc)
					else
						Disconnect(teamChange)
						Disconnect(addedFunc)
					end
				end)
				teamChange = CConnect(GetPropertyChangedSignal(plr, "TeamColor"), function()
					if ESPholder ~= nil and ESPholder.Parent ~= nil then
						Disconnect(lcLoopFunc)
						Disconnect(addedFunc)
						Destroy(ESPholder)
						repeat wait() until getRoot(plr.Character) and FindFirstChildWhichIsA(plr.Character, "Humanoid")
						Locate(plr)
						Disconnect(teamChange)
					else
						Disconnect(teamChange)
					end
				end)
				local lcLoop = function()
					if FindFirstChild(CoreGui, plr.Name .. "_LC") then
						if plr.Character and getRoot(plr.Character) and FindFirstChildWhichIsA(plr.Character, "Humanoid") and Players.LocalPlayer.Character and getRoot(Players.LocalPlayer.Character) and FindFirstChildWhichIsA(Players.LocalPlayer.Character, "Humanoid") then
							local pos = math.floor((getRoot(Players.LocalPlayer.Character).Position - getRoot(plr.Character).Position).magnitude)
							TextLabel.Text = ("Name: " .. tostring(plr.Name) .. " | Health: " .. tostring(iRound(FindFirstChildWhichIsA(plr.Character, "Humanoid").Health, 1)) .. " | Studs: " .. tostring(pos))
						end
					else
						Disconnect(teamChange)
						Disconnect(addedFunc)
						Disconnect(lcLoopFunc)
					end
				end
				lcLoopFunc = CConnect(RenderStepped, lcLoop)
			end
		end
	end)
end

local kill = function(speaker, target, fast)
	if tools(speaker) then
		if target ~= nil then
			local NormPos = speaker.Character.HumanoidRootPart.CFrame
			if not fast then
				refresh(speaker)
				wait()
				repeat wait() until speaker.Character ~= nil and getRoot(speaker.Character)
				wait(0.3)
			end
			local hrp = speaker.Character.HumanoidRootPart
			attach(speaker, target)
			repeat
				wait()
				hrp.CFrame = CFrame.new(999999, workspace.FallenPartsDestroyHeight + 5, 999999)
			until not getRoot(target.Character) or not getRoot(speaker.Character)
			wait(3)
			CWait(speaker.CharacterAdded)
			WaitForChild(speaker.Character, "HumanoidRootPart").CFrame = NormPos
		end
	end
end

local bring = function(speaker, target, fast)
	if tools(speaker) then
		if target ~= nil then
			local NormPos = getRoot(speaker.Character).CFrame
			if not fast then
				refresh(speaker)
				wait()
				repeat wait() until speaker.Character ~= nil and getRoot(speaker.Character)
				wait(0.3)
			end
			local hrp = getRoot(speaker.Character)
			attach(speaker, target)
			repeat
				wait()
				hrp.CFrame = NormPos
			until not getRoot(target.Character) or not getRoot(speaker.Character)
			wait(1)
			CWait(speaker.CharacterAdded)
			WaitForChild(speaker.Character, "HumanoidRootPart").CFrame = NormPos
		end
	end
end

local teleport = function(speaker, target, target2, fast)
	if tools(speaker) then
		if target ~= nil then
			local NormPos = getRoot(speaker.Character).CFrame
			if not fast then
				refresh(speaker)
				wait()
				repeat wait() until speaker.Character ~= nil and getRoot(speaker.Character)
				wait(0.3)
			end
			local hrp = getRoot(speaker.Character)
			local hrp2 = getRoot(target2.Character)
			attach(speaker,target)
			repeat
				wait()
				hrp.CFrame = hrp2.CFrame
			until not getRoot(target.Character) or not getRoot(speaker.Character)
			wait(1)
			CWait(speaker.CharacterAdded)
			WaitForChild(speaker.Character, "HumanoidRootPart").CFrame = NormPos
		end
	end
end

local BrowserList = {}
local BrowserBtn = function(plugin_name, plugin_description, plugin_source)
	BrowserList[#BrowserList + 1] = {
		["name"] = plugin_name,
		["plugname"] = plugin_name,
		["plugdesc"] = plugin_description,
		["source"] = plugin_source
	}
end

CConnect(Players.LocalPlayer.Chatted, function(message)
	spawn(function()
		wait()
		do_exec(string.lower(tostring(message)), Players.LocalPlayer)
	end)
end)

CConnect(DAMouse.KeyDown, function(Key)
	if Key == Settings.Prefix then
		spawn(function()
			CaptureCmdBar()
			TweenAllTransToObject(Main, 0.5, cmdbarclone)
		end)
	end
end)

local cmdbarText = string.gsub(Cmdbar.Text, "^" .. "%" .. Settings.Prefix, "")

CConnect(Cmdbar.FocusLost, function(enterPressed)
	if enterPressed then
		cmdbarText = string.gsub(Cmdbar.Text, "^" .. "%" .. Settings.Prefix, "") 
		spawn(function()
			CmdBarStatus(false)
			TweenAllTrans(Main, 0.5)
		end)
		spawn(function() execCmd(cmdbarText, Players.LocalPlayer, true) end)
	end
	wait()
	if not Cmdbar.IsFocused(Cmdbar) then Cmdbar.Text = "" end
end)

local newCmd = function(name, aliases, title, description, func) addcmd(name, aliases, title, description, func) end

local VirtualEnvironment = function()
	local Environment = {}
	Environment.loaded = true
	Environment.Interface = GUI
	Environment.newCmd = newCmd
	Environment.BrowserBtn = BrowserBtn
	Environment.build_key = randomString()
	Environment.notify = notify
	Environment.getcmds = function() return cmds end
	Environment.running_error = function() notify(Loaded_Title, "Already Running!") end
	Environment.cmdbar = Main
	Environment.cmdbarclone = cmdbarclone
	Environment.matchSearch = MatchSearch
	Environment.execCmd = execCmd
	Environment.events = {}
	getgenv()["DA_ENV"] = Environment
	getgenv()["da_env"] = Environment
end

--// Start of Setup \\--
local ToggleBoxFunc = function(Container, Enabled, Callback)
	local Switch = Container.Switch
	local Hitbox = Container.Hitbox
	if not Enabled then
		Switch.Position = UDim2.fromOffset(2, 2)
		Container.BackgroundColor3 = Color3.fromRGB(34, 30, 28)
	end
	CConnect(Hitbox.MouseButton1Down, function()
		Enabled = not Enabled
		TweenObj(Switch, "Quad", "Out", 0.25, {
			Position = Enabled and UDim2.new(1, -18, 0, 2) or UDim2.fromOffset(2, 2)
		})
		TweenObj(Container, "Quad", "Out", 0.25, {
			BackgroundColor3 = Enabled and Color3.fromRGB(85, 255, 127) or Color3.fromRGB(34, 30, 28)
		})
		Callback(Enabled)
	end)
end

local AddInputBox = function(Title, Callback)
	local NewBtn = Clone(Assets.InputBox)
	NewBtn.Title.Text = tostring(Title)
	CConnect(NewBtn.Input.FocusLost, function(enterPressed)
		if enterPressed then
			Callback(tostring(NewBtn.Input.Text))
		end
	end)
	NewBtn.Parent = DaUi.Pages.Menu.Results
	NewBtn.Visible = true
	return NewBtn
end

local AddButton = function(Title, Func)
	local NewBtn = Clone(Assets.ButtonBox)
	CConnect(NewBtn.Hitbox.MouseButton1Down, function() Func() end)
	NewBtn.Title.Text = tostring(Title)
	NewBtn.Parent = DaUi.Pages.Menu.Results
	NewBtn.Visible = true
	removeCutOff(NewBtn.Title)
end

local AddSetting = function(Title, Enabled, Callback)
	local Toggle = Clone(Assets.ToggleBox)
	local Container = Toggle.Container
	ToggleBoxFunc(Container, Enabled, Callback)
	Toggle.Title.Text = tostring(Title)
	Toggle.Parent = DaUi.Pages.Menu.Results
	Toggle.Visible = true
	removeCutOff(Toggle.Title)
end

local ClearScriptArea = function()
	spawn(function()
		ScriptTabLoaded = false
		for i,v in pairs(GetChildren(DaUi.Pages.Scripts.Results)) do
			if not IsA(v, "UIListLayout") then
				Destroy(v)
			end
		end
	end)
end

local CreateScript = function(scriptname, devs, gameid, scrfunction)
	local log = Clone(Assets.ScriptLog)
	log.Name = (string.lower(tostring(scriptname)) .. " " .. string.lower(tostring(devs)) .. " " .. string.lower(tostring(gameid)))
	log.ScriptName.Text = tostring(scriptname)
	if string.len(tostring(scriptname)) >= 15 then log.ScriptName.RichText = true end
	log.Creator.Text = tostring(devs)
	log.Compatibility.Text = tostring(gameid)
	CConnect(log.Execute.MouseButton1Down, function() spawn(function() scrfunction() end) end)
	log.Parent = DaUi.Pages.Scripts.Results
	log.Visible = true
end

spawn(function()
	pcall(function() ParentGui(GUI) end)
	spawn(function()
		PluginBrowser.Active = true
		PluginBrowser.Draggable = true
		UiDragF.Active = true
		UiDragF.Draggable = true
		SmoothScroll(PluginBrowser.Area.ScrollingFrame, 0.14)
		CConnect(DAMouse.KeyDown, function(Key)
			for i = 1, #DA_Binds do
				if DA_Binds[i].KEY == string.lower(tostring(Key)) then
					execCmd(DA_Binds[i].CMD)
				end
			end
		end)
	end)
	spawn(function()
		PluginBrowser.Area.ScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, PluginBrowser.Area.ScrollingFrame.UIListLayout.AbsoluteContentSize.Y)
		DaUi.Pages.Scripts.Results.CanvasSize = UDim2.new(0, 0, 0, DaUi.Pages.Scripts.Results.UIListLayout.AbsoluteContentSize.Y)
		CConnect(GetPropertyChangedSignal(PluginBrowser.Area.ScrollingFrame.UIListLayout, "AbsoluteContentSize"), function()
			PluginBrowser.Area.ScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, PluginBrowser.Area.ScrollingFrame.UIListLayout.AbsoluteContentSize.Y)
		end)
		CConnect(GetPropertyChangedSignal(DaUi.Pages.Scripts.Results.UIListLayout, "AbsoluteContentSize"), function()
			DaUi.Pages.Scripts.Results.CanvasSize = UDim2.new(0, 0, 0, DaUi.Pages.Scripts.Results.UIListLayout.AbsoluteContentSize.Y)
		end)
		CConnect(GetPropertyChangedSignal(DaUi.Pages.Commands.SearchBar.SearchFrame.Search, "Text"), function()
			local Text = string.lower(DaUi.Pages.Commands.SearchBar.SearchFrame.Search.Text)
			for _, v in next, GetChildren(DaUi.Pages.Commands.Results) do
				if IsA(v, "TextButton") then
					local Command = v.Label.Text
					v.Visible = string.find(string.lower(Command), Text, 1, true)
				end
			end
		end)
		CConnect(GetPropertyChangedSignal(DaUi.Pages.Scripts.SearchBar.SearchFrame.Search, "Text"), function()
			local Text = string.lower(tostring(DaUi.Pages.Scripts.SearchBar.SearchFrame.Search.Text))
			for _, v in next, GetChildren(DaUi.Pages.Scripts.Results) do
				if IsA(v, "Frame") then
					local ScriptString = tostring(v.Name)
					v.Visible = string.find(string.lower(ScriptString), Text, 1, true)
				end
			end
		end)
	end)
	CConnect(CommandsGui.Close.MouseButton1Down, function()
		CmdListStatus(false)
	end)
	CConnect(PluginBrowser.Close.MouseButton1Down, function()
		PlugBrowseStatus(false)
	end)
	CConnect(PluginBrowser.GoBack.MouseButton1Down,function()
		for idk2,okay2 in pairs(GetChildren(PluginBrowser.Container)) do
			okay2.Visible = false
			PluginBrowser.GoBack.Visible = false
			PluginBrowser.Area.Visible = true
		end
	end)
	CConnect(DaUi.Title.Close.MouseButton1Down, function()
		DaUiStatus(false)
	end)
	DaUi.Menu.Settings.PageName.TextColor3 = Color3.fromRGB(255, 255, 255)
	DaUi.Menu.Settings.Image.ImageColor3 = Color3.fromRGB(255, 255, 255)
	CConnect(DaUi.Menu.Settings.MouseButton1Down, function()
		ClearScriptArea()
		DaUi.Pages.UIPageLayout.JumpTo(DaUi.Pages.UIPageLayout, DaUi.Pages.Menu)
	end)
	CConnect(DaUi.Menu.Server.MouseButton1Down, function()
		ClearScriptArea()
		DaUi.Pages.UIPageLayout.JumpTo(DaUi.Pages.UIPageLayout, DaUi.Pages.Server)
	end)
	CConnect(DaUi.Menu.ChatLogs.MouseButton1Down, function()
		ClearScriptArea()
		DaUi.Pages.UIPageLayout.JumpTo(DaUi.Pages.UIPageLayout, DaUi.Pages.ChatLogs)
	end)
	CConnect(DaUi.Menu.JoinLogs.MouseButton1Down, function()
		ClearScriptArea()
		DaUi.Pages.UIPageLayout.JumpTo(DaUi.Pages.UIPageLayout, DaUi.Pages.JoinLogs)
	end)
	CConnect(DaUi.Menu.Commands.MouseButton1Down, function()
		ClearScriptArea()
		DaUi.Pages.UIPageLayout.JumpTo(DaUi.Pages.UIPageLayout, DaUi.Pages.Commands)
		if not CommandsLoaded then
			CommandsLoaded = true
			for _, v in next, cmds do
				if not v["PLUGIN"] then
					addcmdtext(v["NAME"], v["TITLE"], v["ALIAS"], v["DESC"])
				else
					addcmdtext(v["NAME"], v["TITLE"], v["ALIAS"], v["DESC"], true)
				end
			end
		end
	end)
	CConnect(DaUi.Pages.ChatLogs.ClearChatLogs.MouseButton1Down, function()
		ChatlogAPI.ClearAllChatLogs()
	end)
	CConnect(DaUi.Pages.JoinLogs.ClearJoinLogs.MouseButton1Down, function()
		JoinlogAPI.ClearAllLogs()
	end)
	spawn(function()
		while wait(0.05) do
			if GUI ~= nil then
				if PluginBrowser.Area.Visible == false then
					PluginBrowser.GoBack.Visible = true
				else
					PluginBrowser.GoBack.Visible = false
				end
			end
		end
	end)
	if Settings.Widebar == true then
		Main.Position = UDim2.new(0.5, -200, 1, 5)
		Main.Size = UDim2.new(0, 400, 0, 35)
	end
	for _, plr in pairs(GetChildren(Players)) do
		if plr.ClassName == "Player" then
			ChatlogAPI.LogUser(plr)
		end
	end
end)
SetPrefix = AddInputBox("Prefix", function(Callback)
	if typeof(Callback) == "string" and #Callback <= 2 then
		Settings.Prefix = Callback
		updatesaves()
		notify("Prefix", "Succesfully changed to: " .. Callback)
    elseif #Callback > 2 then
    	SetPrefix.Input.Text = Settings.Prefix
        notify("Prefix", "Cannot be longer than 2 characters.")
    end
end)
SetPrefix.Input.Text = tostring(Settings.Prefix)
AddButton("Save Chat Logs", function()
	if writefileExploit() then
		ChatlogAPI.SaveAllLogsToFile()
	else
		notify("writefile", "Cannot Save File")
	end
end)
AddButton("Save Join Logs", function()
	if writefileExploit() then
		JoinlogAPI.SaveAllLogsToFile()
	else
		notify("writefile", "Cannot Save File")
	end
end)
AddSetting("Keep Admin", Settings.KeepDA, function(Callback)
	Settings.KeepDA = Callback
	updatesaves()
end)
AddSetting("Chat Logs", Settings.ChatLogs, function(Callback)
	Settings.ChatLogs = Callback
	updatesaves()
end)
AddSetting("Join Logs", Settings.JoinLogs, function(Callback)
	Settings.JoinLogs = Callback
	updatesaves()
end)
AddSetting("No Notifications", Settings.disablenotifications, function(Callback)
	Settings.disablenotifications = Callback
	updatesaves()
end)
AddSetting("Undetected CommandBar", Settings.undetectedcmdbar, function(Callback)
	Settings.undetectedcmdbar = Callback
	Prote.UndetectedCommandbar(callback)
	updatesaves()
end)
AddSetting("Widebar", Settings.Widebar, function(Callback)
	Settings.Widebar = Callback
	TweenObj(Main, "Quint", "Out", 0.5, {
		["Position"] = UDim2.new(0.5, Settings.Widebar and -200 or -100, 1, 5)
	})
	TweenObj(Main, "Quint", "Out", 0.5, {
        ["Size"] = UDim2.new(0, Settings.Widebar and 400 or 200, 0, 35)
    })
	updatesaves()
end)
AddSetting("Auto Net", Settings.AutoNet, function(Callback)
	Settings.AutoNet = Callback
	updatesaves()
end)
BrowserBtn("Hub Loader", "Hub Loader", "return loadstring(game.HttpGet(game, 'https://raw.githubusercontent.com/Ballbuster9000/who/main/a/test/what/browserplugins/hubloader.lua'))();")
BrowserBtn("Telekinesis", "Telekinesis", "return loadstring(game.HttpGet(game, 'https://raw.githubusercontent.com/Ballbuster9000/who/main/a/test/what/browserplugins/bettel.lua'))();")
BrowserBtn("Smooth Freecam", "Smooth Freecam", "return loadstring(game.HttpGet(game, 'https://raw.githubusercontent.com/Ballbuster9000/who/main/a/test/what/browserplugins/smoothfreecam.lua'))();")
BrowserBtn("Shader Mod", "Shader Mod", "return loadstring(game.HttpGet(game, 'https://raw.githubusercontent.com/Ballbuster9000/who/main/a/test/what/browserplugins/shadermod.lua'))();")
BrowserBtn("Chat Spy", "Chat Spy", "return loadstring(game.HttpGet(game, 'https://raw.githubusercontent.com/Ballbuster9000/who/main/a/test/what/browserplugins/chatspy.lua'))();")
BrowserBtn("System Chat", "System Chat", "return loadstring(game.HttpGet(game, 'https://raw.githubusercontent.com/Ballbuster9000/who/main/a/test/what/browserplugins/systemchat.lua'))();")
BrowserBtn("Lag Server", "Lag Server", "return loadstring(game.HttpGet(game, 'https://raw.githubusercontent.com/Ballbuster9000/who/main/a/test/what/browserplugins/lagserver.lua'))();")
BrowserBtn("Chat Translator", "Chat Translator", "return loadstring(game.HttpGet(game, 'https://raw.githubusercontent.com/Ballbuster9000/who/main/a/test/what/browserplugins/chattranslator.lua'))();")
BrowserBtn("Toon ESP", "Toon ESP", "return loadstring(game.HttpGet(game, 'https://raw.githubusercontent.com/Ballbuster9000/who/main/a/test/what/browserplugins/toonesp.lua'))();")
BrowserBtn("Drag and Resize Chat", "Drag and Resize Chat", "return loadstring(game.HttpGet(game, 'https://raw.githubusercontent.com/Ballbuster9000/who/main/a/test/what/browserplugins/dragresizechat.lua'))();")
BrowserBtn("Fun Gravity", "Fun Gravity", "return loadstring(game.HttpGet(game, 'https://raw.githubusercontent.com/Ballbuster9000/who/main/a/test/what/browserplugins/fungravity.lua'))();")
BrowserBtn("Cyclically Btools", "Cyclically's Custom Btools", "return loadstring(game.HttpGet(game, 'https://raw.githubusercontent.com/Ballbuster9000/who/main/a/test/what/browserplugins/cycbtools.lua'))();")
BrowserBtn("Wall Run", "Wall Run", "return loadstring(game.HttpGet(game, 'https://raw.githubusercontent.com/Ballbuster9000/who/main/a/test/what/browserplugins/wallrun.lua'))();")
BrowserBtn("RTX", "RTX: Graphics Enhancer", "return loadstring(game.HttpGet(game, 'https://raw.githubusercontent.com/Ballbuster9000/who/main/a/test/what/browserplugins/rtx.lua'))();")
BrowserBtn("Empty Server Finder", "Empty Server Finder", "return loadstring(game.HttpGet(game, 'https://raw.githubusercontent.com/Ballbuster9000/who/main/a/test/what/browserplugins/emptyserverfinder.lua'))();")
BrowserBtn("Bypass Anticheats", "Bypass Anticheats", "return loadstring(game.HttpGet(game, 'https://raw.githubusercontent.com/Ballbuster9000/who/main/a/test/what/browserplugins/bypassanticheats.lua'))();")
BrowserBtn("Universal Bhop", "Universal Bhop", "return loadstring(game.HttpGet(game, 'https://raw.githubusercontent.com/Ballbuster9000/who/main/a/test/what/browserplugins/universalbhop.lua'))();")
BrowserBtn("Future Lighting", "Future Lighting", "return loadstring(game.HttpGet(game, 'https://raw.githubusercontent.com/Ballbuster9000/who/main/a/test/what/browserplugins/futurelighting.lua'))();")
BrowserBtn("Head Pet", "Head Pet", "return loadstring(game.HttpGet(game, 'https://raw.githubusercontent.com/Ballbuster9000/who/main/a/test/what/browserplugins/headpet.lua'))();")
BrowserBtn("Sharkbite", "Sharkbite", "return loadstring(game.HttpGet(game, 'https://raw.githubusercontent.com/Ballbuster9000/who/main/a/test/what/browserplugins/sharkbite.lua'))();")
--// End of Setup \\--


--// Commands

newCmd("commands", {"cmds"}, "commands / cmds", "View the Command List", function(args, speaker)
	if not IsDaUi then
		DaUiStatus(true)
		DaUi.Pages.UIPageLayout.JumpTo(DaUi.Pages.UIPageLayout, DaUi.Pages.Commands)
	else
		DaUi.Pages.UIPageLayout.JumpTo(DaUi.Pages.UIPageLayout, DaUi.Pages.Commands)
	end
	if not CommandsLoaded then
		CommandsLoaded = true
		for _, v in next, cmds do
			if not v["PLUGIN"] then
				addcmdtext(v["NAME"], v["TITLE"], v["ALIAS"], v["DESC"])
			else
				addcmdtext(v["NAME"], v["TITLE"], v["ALIAS"], v["DESC"], true)
			end
		end
	end
end)

newCmd("openui", {"ui"}, "openui / ui", "Open the Dark Admin UI", function(args, speaker)
	DaUiStatus(true)
end)

newCmd("browser", {}, "browser", "Open the Plugin Browser", function(args, speaker)
	if not BrowserLoaded then
		BrowserLoaded = true
		for _, v in next, BrowserList do
			local name = v["name"]
			local plugdesc = v["plugdesc"]
			local source = v["source"]
			local PlugAreaTemplate = Clone(Assets.PlugAreaTemplate)
			local PlugName = PlugAreaTemplate.PlugName
			local PlugDesc = PlugAreaTemplate.PlugDesc
			local PlugAdd = PlugAreaTemplate.PlugAdd
			local PlugRemove = PlugAreaTemplate.PlugRemove
			local BrowserLabel = Clone(Assets.BrowserLabel)
			local OldFileName = string.lower(name)
			local NewFileName = string.gsub(OldFileName, " ", "")
			local ExtensionFile = ("Dark Admin/Plugins/" .. NewFileName .. ".da")
			PlugAreaTemplate.Parent = PluginBrowser.Container
			BrowserLabel.Parent = PluginBrowser.Area.ScrollingFrame
			BrowserLabel.Visible = true
			PlugName.Text = ("Plugin Name: " .. name)
			PlugDesc.Text = ("Plugin Description:\n" .. plugdesc)
			BrowserLabel.Label.Text = name
			CConnect(BrowserLabel.MouseButton1Down, function()
				for idk,okay in pairs(GetChildren(PluginBrowser.Container)) do
					okay.Visible = false
					PluginBrowser.Area.Visible = false
					PlugAreaTemplate.Visible = true
				end
			end)
			CConnect(PlugAdd.MouseButton1Down, function()
				if not isfile(ExtensionFile) then
					writefile(ExtensionFile, source)
					wait(0.2)
					addPlugin(NewFileName)
					updatesaves()
				else
					addPlugin(NewFileName)
					updatesaves()
				end
			end)
			CConnect(PlugRemove.MouseButton1Down, function()
				deletePlugin(NewFileName)
				wait(0.2)
				updatesaves()
			end)
		end
	end
	PlugBrowseStatus(true)
end)

newCmd("prefix", {}, "prefix [string]", "Change the Prefix", function(args, speaker)
    if not args[1] then return notify("Prefix Error", "Missing Argument") end
	local pref = tostring(args[1])
	if typeof(pref) == "string" and #pref <= 2 then
		Settings.Prefix = pref
        SetPrefix.Input.Text = pref
		updatesaves()
		notify("Prefix", "Succesfully changed to: " .. pref)
    elseif #prefix > 2 then
        notify("Prefix", "Cannot be longer than 2 characters.")
    end
end)

newCmd("currentprefix", {}, "currentprefix", "Notify the Current Prefix", function(args, speaker)
	notify("", "Current Prefix is " .. Settings.Prefix)
end)

newCmd("debug", {}, "debug", "Toggle the admin's debug mode", function(args, speaker)
	AdminDebug = not AdminDebug
	notify("Admin Debug", string.format("Debug has been %s", AdminDebug and "Enabled" or "Disabled"))
end)

newCmd("rejoin", {"rj"}, "rejoin / rj", "Rejoin the server", function(args, speaker)
	if #GetPlayers(Players) <= 1 then
		Players.LocalPlayer.Kick(Players.LocalPlayer, "\nRejoining...")
		wait()
		TeleportService.Teleport(TeleportService, game.PlaceId, Players.LocalPlayer)
	else
		TeleportService.TeleportToPlaceInstance(TeleportService, game.PlaceId, game.JobId, Players.LocalPlayer)
	end
end)

newCmd("exit", {}, "exit", "Close Roblox", function(args, speaker)
	game.shutdown(game)
end)

newCmd("fullnet", {}, "fullnet", "Full Network Ownership", function(args, speaker)
	SetSimulationRadius()
	notify("Simulation Radius", "~ Inf ~")
end)

newCmd("unfullnet", {}, "unfullnet", "Disable Your Full Network Ownership", function(args, speaker)
	if Network_Loop ~= nil then
		Disconnect(Network_Loop)
		wait()
		Network_Loop = nil
		if setsimulation then
			setsimulation(139, 139)
		else
			sethidden(speaker, "MaximumSimulationRadius", 139)
			sethidden(speaker, "SimulationRadius", 139)
		end
		if args[1] and args[1] == "nonotify" then return end
		notify("Simulation Radius", "~ 139 ~")
	end
end)

newCmd("netcheck", {}, "netcheck", "Notify Who is Using Network Ownership", function(args, speaker)
	local CheckIfWorks = pcall(function() gethidden(Players.LocalPlayer, "SimulationRadius") end)
	local Plrs = {}
	local Msg = ""
	if CheckIfWorks then
		for i, v in pairs(GetPlayers(Players)) do
			if gethidden(v, "SimulationRadius") >= 5000 then
				table.insert(Plrs, v.Name)
			end
		end
		if #Plrs <= 0 then
			Msg = "No Players Found"
		elseif #Plrs == 1 then
			Msg = Plrs[1]
		elseif #Plrs > 1 then
			Msg = table.concat(Plrs, ", ")
		end
		return notify("Net Check", Msg)
	else
		return notify("Incompatible Exploit", "Missing gethiddenproperty")
	end
end)

newCmd("walkspeed", {"ws"}, "walkspeed / ws [number]", "Change your WalkSpeed", function(args, speaker)
	if not args[1] then return notify("WalkSpeed", "Argument Missing") end
	local wspeed = args[1]
	if speaker and speaker.Character and findhum() then
		if isNumber(wspeed) then
			local Human = gethum()
			Prote.SpoofProperty(Human, "WalkSpeed")
			Human.WalkSpeed = wspeed
		else
			notify("WalkSpeed", "Number Required")
		end
	end
end)

newCmd("loopspeed", {"loopws"}, "loopspeed / loopws [num]", "Loops your Walkspeed", function(args, speaker)
	local speed = args[1] or 16
	if isNumber(speed) then
		local Char = speaker.Character or FindFirstChild(workspace, speaker.Name)
		local Human = Char and FindFirstChildWhichIsA(Char, "Humanoid")
		local WalkSpeedChange = function()
			if Char and Human then
				Prote.SpoofProperty(Human, "WalkSpeed")
				Human.WalkSpeed = speed
			end
		end
		WalkSpeedChange()
		HumanModCons.wsLoop = (HumanModCons.wsLoop and Disconnect(HumanModCons.wsLoop) and false) or CConnect(GetPropertyChangedSignal(Human, "WalkSpeed"), WalkSpeedChange)
		HumanModCons.wsCA = (HumanModCons.wsCA and Disconnect(HumanModCons.wsCA) and false) or CConnect(speaker.CharacterAdded, function(nChar)
			Char, Human = nChar, WaitForChild(nChar, "Humanoid")
			WalkSpeedChange()
			HumanModCons.wsLoop = (HumanModCons.wsLoop and Disconnect(HumanModCons.wsLoop) and false) or CConnect(GetPropertyChangedSignal(Human, "WalkSpeed"), WalkSpeedChange)
		end)
	end
end)

newCmd("unloopspeed", {"unloopws"}, "unloopspeed / unloopws", "Disable LoopSpeed", function(args, speaker)
	HumanModCons.wsLoop = (HumanModCons.wsLoop and Disconnect(HumanModCons.wsLoop) and false) or nil
	HumanModCons.wsCA = (HumanModCons.wsCA and Disconnect(HumanModCons.wsCA) and false) or nil
end)

newCmd("jumppower", {"jp"}, "jumppower / jp [number]", "Change your JumpPower", function(args, speaker)
	if not args[1] then return notify("JumpPower", "Argument Missing") end
	local jppower = args[1]
	if speaker and speaker.Character and findhum() then
		if isNumber(jppower) then
			local Human = gethum()
			if Human.UseJumpPower then
				Prote.SpoofProperty(Human, "JumpPower")
				Human.JumpPower = jppower
			else
				Prote.SpoofProperty(Human, "JumpHeight")
				Human.JumpHeight = jppower
			end
		else
			notify("JumpPower", "Number Required")
		end
	end
end)

newCmd("loopjumppower", {"loopjp"}, "loopjumppower / loopjp [num]", "Loops your Jump Height", function(args, speaker)
	local jpower = args[1] or 50
	if isNumber(jpower) then
		local Char = speaker.Character or FindFirstChild(workspace, speaker.Name)
		local Human = Char and FindFirstChildWhichIsA(Char, "Humanoid")
		local JumpPowerChange = function()
			if Char and Human then
				if Human.UseJumpPower then
					Prote.SpoofProperty(Human, "JumpPower")
					Human.JumpPower = jppower
				else
					Prote.SpoofProperty(Human, "JumpHeight")
					Human.JumpHeight = jppower
				end
			end
		end
		JumpPowerChange()
		HumanModCons.jpLoop = (HumanModCons.jpLoop and Disconnect(HumanModCons.jpLoop) and false) or CConnect(GetPropertyChangedSignal(Human, "JumpPower"), JumpPowerChange)
		HumanModCons.jpCA = (HumanModCons.jpCA and Disconnect(HumanModCons.jpCA) and false) or CConnect(speaker.CharacterAdded, function(nChar)
			Char, Human = nChar, WaitForChild(nChar, "Humanoid")
			JumpPowerChange()
			HumanModCons.jpLoop = (HumanModCons.jpLoop and Disconnect(HumanModCons.jpLoop) and false) or CConnect(GetPropertyChangedSignal(Human, "JumpPower"), JumpPowerChange)
		end)
	end
end)

newCmd("unloopjumppower", {"unloopjp"}, "unloopjumppower / unloopjp", "Disable LoopJumpPower", function(args, speaker)
	HumanModCons.jpLoop = (HumanModCons.jpLoop and Disconnect(HumanModCons.jpLoop) and false) or nil
	HumanModCons.jpCA = (HumanModCons.jpCA and Disconnect(HumanModCons.jpCA) and false) or nil
end)

newCmd("goto", {"to"}, "goto / to [plr]", "Teleport to a Player", function(args, speaker)
	if not clientsidebypass then
		local users = getPlayer(args[1], speaker)
		for i,v in pairs(users) do
			if Players[v].Character ~= nil then
				if FindFirstChildWhichIsA(speaker.Character, "Humanoid") and FindFirstChildWhichIsA(speaker.Character, "Humanoid").SeatPart then
					local Human = FindFirstChildWhichIsA(speaker.Character, "Humanoid")
					Prote.SpoofProperty(Human, "Sit")
					Human.Sit = false
					wait(0.1)
				end
				getRoot(speaker.Character).CFrame = getRoot(Players[v].Character).CFrame + Vector3.new(3, 1, 0)
			end
		end
		-- execCmd("breakvelocity")
	else
		local users = getPlayer(args[1], speaker)
		for i,v in pairs(users) do
			if Players[v].Character ~= nil then
				if FindFirstChildWhichIsA(speaker.Character, "Humanoid") and FindFirstChildWhichIsA(speaker.Character, "Humanoid").SeatPart then
					local Human = FindFirstChildWhichIsA(speaker.Character, "Humanoid")
					Prote.SpoofProperty(Human, "Sit")
					Human.Sit = false
					wait(0.1)
				end
				local Tween = TweenService.Create(TweenService, getRoot(speaker.Character), TweenInfo.new(2), {CFrame = getRoot(Players[v].Character).CFrame})
				Tween.Play(Tween)
			end
		end
	end
end)

newCmd("pulseto", {"pto"}, "pulseto / pto [plr] [seconds]", "Teleports you to a player for a specified ammount of time", function(args, speaker)
	if not clientsidebypass then
		local users = getPlayer(args[1], speaker)
		for i,v in pairs(users) do
			if Players[v].Character ~= nil then
				local startPos = getRoot(speaker.Character).CFrame
				local seconds = tonumber(args[2]) or 1
				if FindFirstChildWhichIsA(speaker.Character, "Humanoid") and FindFirstChildWhichIsA(speaker.Character, "Humanoid").SeatPart then
					local Human = FindFirstChildWhichIsA(speaker.Character, "Humanoid")
					Prote.SpoofProperty(Human, "Sit")
					Human.Sit = false
					wait(0.1)
				end
				getRoot(speaker.Character).CFrame = getRoot(Players[v].Character).CFrame + Vector3.new(3, 1, 0)
				wait(seconds)
				getRoot(speaker.Character).CFrame = startPos
			end
		end
		-- execCmd("breakvelocity")
	else
		local users = getPlayer(args[1], speaker)
		for i,v in pairs(users) do
			if Players[v].Character ~= nil then
				local startPos = getRoot(speaker.Character).CFrame
				local seconds = tonumber(args[2]) or 1
				if FindFirstChildWhichIsA(speaker.Character, "Humanoid") and FindFirstChildWhichIsA(speaker.Character, "Humanoid").SeatPart then
					local Human = FindFirstChildWhichIsA(speaker.Character, "Humanoid")
					Prote.SpoofProperty(Human, "Sit")
					Human.Sit = false
					wait(0.1)
				end
				local Tween1 = TweenService.Create(TweenService, getRoot(speaker.Character), TweenInfo.new(2), {CFrame = getRoot(Players[v].Character).CFrame})
				Tween1.Play(Tween1)
				wait(seconds)
				local Tween2 = TweenService.Create(TweenService, getRoot(speaker.Character), TweenInfo.new(2), {CFrame = startPos})
				Tween2.Play(Tween2)
			end
		end
	end
end)

newCmd("noclip", {}, "noclip", "Disable your Collison", function(args, speaker)
	CmdClip = false
	wait(0.1)
	local NoclipLoop = function()
		if not CmdClip and speaker.Character ~= nil then
			for _, child in pairs(GetDescendants(speaker.Character)) do
				if IsA(child, "BasePart") and child.CanCollide and child.Name ~= floatName then
					Prote.SpoofProperty(child, "CanCollide")
					child.CanCollide = false
				end
			end
		end
	end
	CmdNoclipping = CConnect(Stepped, NoclipLoop)
	if args[1] and args[1] == "nonotify" then return end
	notify("Noclip", "Noclip Enabled")
end)

newCmd("clip", {"unnoclip"}, "clip / unnoclip", "Stop Noclipping", function(args, speaker)
	if CmdNoclipping ~= nil then
		Disconnect(CmdNoclipping)
		CmdNoclipping = nil
	end
	CmdClip = true
	if args[1] and args[1] == "nonotify" then return end
	notify("Noclip", "Noclip Disabled")
end)

newCmd("togglenoclip", {}, "togglenoclip", "Toggle Noclip", function(args, speaker)
	if CmdClip then
		execCmd("clip nonotify")
		wait()
		execCmd("noclip")
	elseif not CmdClip then
		execCmd("clip")
	end
end)

newCmd("fly", {}, "fly [number]", "Be Able to Fly", function(args, speaker)
	NOFLY()
	wait()
	sFLY()
	if args[1] and isNumber(args[1]) then
		Settings.daflyspeed = tonumber(args[1])
		updatesaves()
	end
end)

newCmd("vfly", {"vehiclefly"}, "vfly / vehiclefly [number]", "Be Able to Make Vehicles Fly", function(args, speaker)
	NOFLY()
	wait()
	sFLY(true)
	if args[1] and isNumber(args[1]) then
		Settings.vehicleflyspeed = tonumber(args[1])
		updatesaves()
	end
end)

newCmd("flyspeed", {"flysp"}, "flyspeed / flysp", "Change your Flyspeed", function(args, speaker)
	local speed = args[1] or 1
	if args[1] and isNumber(speed) then
		Settings.daflyspeed = tonumber(speed)
		updatesaves()
	end
end)

newCmd("vflyspeed", {"vflysp"}, "vflyspeed / vflysp", "Change your Vehicle Flyspeed", function(args, speaker)
	local speed = args[1] or 1
	if args[1] and isNumber(speed) then
		Settings.vehicleflyspeed = tonumber(speed)
		updatesaves()
	end
end)

newCmd("unfly", {"unvfly"}, "unfly / unvfly", "Stop Flying", function(args, speaker)
	NOFLY()
end)

newCmd("cframefly", {"cfly"}, "cframefly / cfly [speed]", "Makes you Fly (Bypasses Some Anti Cheats)", function(args, speaker)
	if args[1] and isNumber(args[1]) then
		Settings.cframeflyspeed = tonumber(args[1])
		updatesaves()
	end
	local GC = getconnections or get_signal_cons
	local Keys = Enum.KeyCode
	local v3 = Vector3.new()
	local cf = CFrame.new()
	CflyCon = CConnect(Heartbeat, function()
		local Camera = workspace.CurrentCamera
		local Cache = {}
		local Human = speaker.Character and FindFirstChildWhichIsA(speaker.Character, "Humanoid")
		local HRP = Human and Human.RootPart or speaker.Character.PrimaryPart
		if not speaker.Character or not Human or not HRP or not Camera then
			return 
		end
		local Cache = {}
		local Cons = {game.ItemChanged, Human.StateChanged, Human.Changed, speaker.Character.Changed}
		for _, v in ipairs(GetChildren(speaker.Character)) do
			if IsA(v, "BasePart") then
				Cons[#Cons + 1] = v.Changed
				Cons[#Cons + 1] = GetPropertyChangedSignal(v, "CFrame")
			end
		end
		for _, v in ipairs(Cons) do
			for _, v1 in ipairs(GC(v)) do
				if not rawget(v1, "__OBJECT_ENABLED") then
					Cache[#Cache + 1] = v1
					v1.Disable(v1)
				end
			end
		end
		Human.ChangeState(Human, 11)
		HRP.CFrame = CFrame.new(HRP.Position, HRP.Position + Camera.CFrame.LookVector) * (UserInputService.GetFocusedTextBox(UserInputService) and cf or CFrame.new((UserInputService.IsKeyDown(UserInputService, Keys.D) and Settings.cframeflyspeed) or (UserInputService.IsKeyDown(UserInputService, Keys.A) and -Settings.cframeflyspeed) or 0, (UserInputService.IsKeyDown(UserInputService, Keys.E) and Settings.cframeflyspeed / 2) or (UserInputService.IsKeyDown(UserInputService, Keys.Q) and -Settings.cframeflyspeed / 2) or 0, (UserInputService.IsKeyDown(UserInputService, Keys.S) and Settings.cframeflyspeed) or (UserInputService.IsKeyDown(UserInputService, Keys.W) and -Settings.cframeflyspeed) or 0))
		for _, v in ipairs(Cache) do
			v.Enable(v)
		end
	end)
end)

newCmd("cframeflyspeed", {"cflyspeed"}, "cframeflyspeed / cflyspeed [num]", "Sets CFrame Fly Speed", function(args, speaker)
	if args[1] and isNumber(args[1]) then
		Settings.cframeflyspeed = tonumber(args[1])
		updatesaves()
	end
end)

newCmd("uncframefly", {"uncfly"}, "uncframefly / uncfly", "Disables CFrame Fly", function(args, speaker)
	if CflyCon then
		Disconnect(CflyCon)
		CflyCon = nil
	end
end)

newCmd("gyrofly", {"gfly"}, "gyrofly / gfly [speed]", "Make your Character Fly Using Body Gyros", function(args, speaker)
	if args[1] and isNumber(args[1]) then
		Settings.gyroflyspeed = tonumber(args[1])
		updatesaves()
	end
	for i, v in next, GetChildren(getRoot(speaker.Character)) do
        if IsA(v, "BodyPosition") or IsA(v, "BodyGyro") then
            Destroy(v)
        end
    end
    local BodyPos = InstanceNew("BodyPosition")
    local BodyGyro = InstanceNew("BodyGyro")
    Prote.ProtectInstance(BodyPos)
    Prote.ProtectInstance(BodyGyro)
    BodyPos.Parent = getRoot(speaker.Character)
    BodyGyro.Parent = getRoot(speaker.Character)
    BodyGyro.maxTorque = Vector3.new(1, 1, 1) * 9e9
    BodyGyro.CFrame = getRoot(speaker.Character).CFrame
    BodyPos.maxForce = Vector3.new(1, 1, 1) * math.huge
    local Human = speaker.Character and FindFirstChildWhichIsA(speaker.Character, "Humanoid")
    Prote.SpoofProperty(Human, "PlatformStand")
    Human.PlatformStand = true
    coroutine.wrap(function()
        BodyPos.Position = getRoot(speaker.Character).Position
        while wait() do
            local NewPos = (BodyGyro.CFrame - (BodyGyro.CFrame).Position) + BodyPos.Position
            local CoordinateFrame = workspace.CurrentCamera.CoordinateFrame
            if Keys["W"] then
                NewPos = NewPos + CoordinateFrame.lookVector * Settings.gyroflyspeed
                BodyPos.Position = (getRoot(speaker.Character).CFrame * CFrame.new(0, 0, -Settings.gyroflyspeed)).Position
                BodyGyro.CFrame = CoordinateFrame * CFrame.Angles(-math.rad(Settings.gyroflyspeed * 15), 0, 0)
            end
            if Keys["A"] then
                NewPos = NewPos * CFrame.new(-Settings.gyroflyspeed, 0, 0)
            end
            if Keys["S"] then
                NewPos = NewPos - CoordinateFrame.lookVector * Settings.gyroflyspeed
                BodyPos.Position = (getRoot(speaker.Character).CFrame * CFrame.new(0, 0, Settings.gyroflyspeed)).Position
                BodyGyro.CFrame = CoordinateFrame * CFrame.Angles(-math.rad(Settings.gyroflyspeed * 15), 0, 0)
            end
            if Keys["D"] then
                NewPos = NewPos * CFrame.new(Settings.gyroflyspeed, 0, 0)
            end
            BodyPos.Position = NewPos.Position
            BodyGyro.CFrame = CoordinateFrame
        end
        Human.PlatformStand = false
    end)()
    GYROFLYING = true
    notify("Gyro Fly", "Enabled")
end)

newCmd("ungyrofly", {"ungfly"}, "ungyrofly / ungfly", "Disables Gyro Fly", function(args, speaker)
	local Human = speaker.Character and FindFirstChildWhichIsA(speaker.Character, "Humanoid")
	for i,v in next, GetChildren(getRoot(speaker.Character)) do
		if IsA(v, "BodyPosition") or IsA(v, "BodyGyro") then
			Destroy(v)
		end
	end
	Human.PlatformStand = false
	GYROFLYING = false
	if args[1] and args[1] == "nonotify" then return end
	notify("Gyro Fly", "Disabled")
end)

newCmd("gyroflyspeed", {"gflyspeed"}, "gyroflyspeed / gflyspeed [num]", "Sets Gyro Fly Speed", function(args, speaker)
	local speed = args[1] or 3
	if args[1] and isNumber(args[1]) then
		Settings.gyroflyspeed = tonumber(speed)
		updatesaves()
	end
end)

newCmd("togglefly", {}, "togglefly", "Toggle Fly", function(args, speaker)
	if FLYING  then
		NOFLY()
	elseif not FLYING then
		sFLY()
	end
end)

newCmd("togglegyrofly", {"togglegfly"}, "togglegyrofly / togglegfly", "Toggle Gyro Fly", function(args, speaker)
	if GYROFLYING  then
		execCmd("ungyrofly")
	elseif not GYROFLYING then
		execCmd("gyrofly")
	end
end)

newCmd("anchor", {}, "anchor", "Anchor your RootPart", function(args, speaker)
	if speaker and speaker.Character then
		for i,v in pairs(GetChildren(speaker.Character)) do
			if IsA(v, "BasePart") then
				Prote.SpoofProperty(v, "Anchored")
				v.Anchored = true
			end
		end
	end
end)

newCmd("unanchor", {}, "unanchor", "Makes your Player Movable Again", function(args, speaker)
	if speaker and speaker.Character then
		for i,v in pairs(GetChildren(speaker.Character)) do
			if IsA(v, "BasePart") then
				Prote.SpoofProperty(v, "Anchored")
				v.Anchored = false
			end
		end
	end
end)

newCmd("reset", {}, "reset", "Reset your Character", function(args, speaker)
	if not speaker then return notify("Reset", "Missing LocalPlayer") end
	if not speaker.Character then return notify("Reset", "Missing Character") end
	speaker.Character.BreakJoints(speaker.Character)
end)

newCmd("reset2", {}, "reset2", "Use a Set Humanoid Method to reset your Character", function(args, speaker)
	if not speaker then return notify("Reset", "Missing LocalPlayer") end
	if not speaker.Character then return notify("Reset", "Missing Character") end
	local Human = FindFirstChildWhichIsA(speaker.Character, "Humanoid")
	if not Human then return notify("Reset", "Missing Humanoid") end
	Prote.SpoofProperty(Human, "Health")
	Prote.SpoofProperty(Human, "MaxHealth")
	Human.Health = 0
	Human.MaxHealth = 0
end)

newCmd("notify", {}, "notify [title] [desc] [time]", "Run a Custom Notification", function(args, speaker)
	if args[3] ~= nil then
		notify(args[1], args[2], args[3])
	else
		notify(args[1], args[2])
	end
end)

newCmd("kill", {}, "kill [plr]", "Try to Kill a User", function(args, speaker)
	local users = getPlayer(args[1], speaker)
	for i,v in pairs(users) do
		local Target = Players[v]
		if Target and Target.Character then
			kill(speaker, Target)
		end
	end
end)

newCmd("fastkill", {}, "fastkill [plr]", "Try to Kill a User Fast", function(args, speaker)
	local users = getPlayer(args[1], speaker)
	for i,v in pairs(users) do
		local Target = Players[v]
		if Target and Target.Character then
			kill(speaker, Target, true)
		end
	end
end)

newCmd("handlekill", {"hkill"}, "handlekill / hkill [plr] (Tool)", "Try to kills a User using Tool Damage", function(args, speaker)
	if not firetouchinterest then return notify("Incompatible Exploit", "Missing firetouchinterest") end
	local Tool = FindFirstChildWhichIsA(speaker.Character, "Tool")
	local Handle = Tool and FindFirstChild(Tool, "Handle")
	if not Tool or not Handle then return notify("Handle Kill", "You need to hold a \"Tool\" that does damage on touch. For example the default \"Sword\" tool.") end
	for _, v in ipairs(getPlayer(args[1], speaker)) do
		v = Players[v]
		spawn(function()
			while Tool and speaker.Character and v.Character and Tool.Parent == speaker.Character do
				local Human = FindFirstChildWhichIsA(v.Character, "Humanoid")
				if not Human or Human.Health <= 0 then
					break
				end
				for _, v1 in ipairs(GetChildren(v.Character)) do
					v1 = ((IsA(v1, "BasePart") and firetouchinterest(Handle, v1, 1, (CWait(RenderStepped) and nil) or firetouchinterest(Handle, v1, 0)) and nil) or v1) or v1
				end
			end
			notify("Handle Kill Stopped!", v.Name .. " died/left or you unequipped the tool!")
		end)
	end
end)

newCmd("clientkill", {"ckill"}, "clientkill / ckill [plr]", "Kill a User on your Client", function(args, speaker)
	local users = getPlayer(args[1], speaker)
	for i,v in pairs(users) do
		local Target = Players[v]
		if Target and Target.Character and findhum(Target.Character) then
			gethum(Target.Character).Health = 0
		end
	end
end)

newCmd("bring", {}, "bring [plr]", "Try to Bring a User", function(args, speaker)
	local users = getPlayer(args[1], speaker)
	for i,v in pairs(users) do
		local Target = Players[v]
		if Target and Target.Character then
			bring(speaker, Target)
		end
	end
end)

newCmd("fastbring", {}, "fastbring [plr]", "Try to Bring a User Fast", function(args, speaker)
	local users = getPlayer(args[1], speaker)
	for i,v in pairs(users) do
		local Target = Players[v]
		if Target and Target.Character then
			bring(speaker, Target, true)
		end
	end
end)

newCmd("clientbring", {"cbring"}, "clientbring / cbring [plr]", "Bring a User on your Client", function(args, speaker)
	local users = getPlayer(args[1], speaker)
	for i,v in pairs(users) do
		if Players[v].Character ~= nil then
			if FindFirstChildWhichIsA(Players[v].Character, "Humanoid") then
				FindFirstChildWhichIsA(Players[v].Character, "Humanoid").Sit = false
			end
			wait()
			getRoot(Players[v].Character).CFrame = getRoot(speaker.Character).CFrame + Vector3.new(3,1,0)
		end
	end
end)

newCmd("respawn", {}, "respawn", "Respawn your Character", function(args, speaker)
	respawn(speaker)
end)

newCmd("refresh", {"re"}, "refresh / re", "Respawn in the Same Spot", function(args, speaker)
	refresh(speaker)
end)

newCmd("split", {}, "split", "Split Your Character in Half", function(args, speaker)
	if r15(speaker) then
		Destroy(speaker.Character.UpperTorso.Waist)
	else
		notify("R15 Required", "Requires R15 Rig Type")
	end
end)

newCmd("float", {}, "float", "Walk On An Invisible Part to Look Like You Are Floating", function(args, speaker)
	Floating = true
	local pchar = speaker.Character
	local Human = speaker.Character and FindFirstChildWhichIsA(speaker.Character, "Humanoid")
	if pchar and not FindFirstChild(pchar, floatName) then
		spawn(function()
			local Float = InstanceNew("Part")
			Prote.ProtectInstance(Float)
			Float.Name = floatName
			Float.Parent = pchar
			Float.Transparency = 1
			Float.Size = Vector3.new(6, 1, 6)
			Float.Anchored = true
			local FloatValue = -3.5
			if r15(speaker) then FloatValue = -3.65 end
			Float.CFrame = getRoot(pchar).CFrame * CFrame.new(0, FloatValue, 0)
			notify("Float", "Float Enabled (Q = Down & E = Up)")
			qUp = CConnect(DAMouse.KeyUp, function(KEY)
				if KEY == "q" then
					FloatValue = FloatValue + 0.5
				end
			end)
			eUp = CConnect(DAMouse.KeyUp, function(KEY)
				if KEY == "e" then
					FloatValue = FloatValue - 0.5
				end
			end)
			qDown = CConnect(DAMouse.KeyDown, function(KEY)
				if KEY == "q" then
					FloatValue = FloatValue - 0.5
				end
			end)
			eDown = CConnect(DAMouse.KeyDown, function(KEY)
				if KEY == "e" then
					FloatValue = FloatValue + 0.5
				end
			end)
			floatDied = CConnect(FindFirstChildWhichIsA(speaker.Character, "Humanoid").Died, function()
				Disconnect(FloatingFunc)
				Destroy(Float)
				Disconnect(qUp)
				Disconnect(eUp)
				Disconnect(qDown)
				Disconnect(eDown)
				Disconnect(floatDied)
			end)
			local FloatPadLoop = function()
				if FindFirstChild(pchar, floatName) and getRoot(pchar) then
					Float.CFrame = getRoot(pchar).CFrame * CFrame.new(0, FloatValue, 0)
				else
					Disconnect(FloatingFunc)
					Destroy(Float)
					Disconnect(qUp)
					Disconnect(eUp)
					Disconnect(qDown)
					Disconnect(eDown)
					Disconnect(floatDied)
				end
			end			
			FloatingFunc = CConnect(Heartbeat, FloatPadLoop)
		end)
	end
end)

newCmd("unfloat", {}, "unfloat", "Disable Floating", function(args, speaker)
	Floating = false
	local pchar = speaker.Character
	notify("Float", "Float Disabled")
	if FindFirstChild(pchar, floatName) then
		Destroy(FindFirstChild(pchar, floatName))
	end
	if floatDied then
		Disconnect(FloatingFunc)
		Destroy(Float)
		Disconnect(qUp)
		Disconnect(eUp)
		Disconnect(qDown)
		Disconnect(eDown)
		Disconnect(floatDied)
	end
end)

newCmd("sit", {}, "sit", "Make your Character Sit", function(args, speaker)
	if speaker and speaker.Character and findhum() then
		local Human = gethum()
		Prote.SpoofProperty(Human, "Sit", false)
		Human.Sit = true
	end
end)

newCmd("stun", {}, "stun", "Enable Platform Stand", function(args, speaker)
	if speaker and speaker.Character and findhum() then
		local Human = gethum()
		Prote.SpoofProperty(Human, "PlatformStand", false)
		Human.PlatformStand = true
	end
end)

newCmd("unstun", {}, "unstun", "Disable Platform Stand", function(args, speaker)
	if speaker and speaker.Character and findhum() then
		local Human = gethum()
		Prote.SpoofProperty(Human, "PlatformStand", false)
		Human.PlatformStand = false
	end
end)

newCmd("jump", {}, "jump", "Make your Character Jump", function(args, speaker)
	if speaker and speaker.Character and findhum() then
		local Human = gethum()
		Prote.SpoofProperty(Human, "Jump", false)
		Human.Jump = true
	end
end)

newCmd("togglefullscreen", {"togglefs"}, "togglefullscreen / togglefs", "Toggles Fullscreen", function(args, speaker)
	return GuiService.ToggleFullscreen(GuiService)
end)

newCmd("screenshot", {}, "screenshot", "Take a Screenshot", function(args, speaker)
	return CoreGui.TakeScreenshot(CoreGui)
end)

newCmd("addplugin", {}, "addplugin [string]", "Add a Plugin", function(args, speaker)
	addPlugin(getstring(1))
	updatesaves()
end)

newCmd("removeplugin", {}, "removeplugin [string]", "Remove a Plugin", function(args, speaker)
	deletePlugin(getstring(1))
	updatesaves()
end)

newCmd("reloadplugin", {}, "reloadplugin [string]", "Reload a Plugin", function(args, speaker)
	local pluginName = getstring(1)
	deletePlugin(pluginName)
	wait(1)
	addPlugin(pluginName)
end)

newCmd("pluginlist", {}, "pluginlist", "List all your plugins that are enabled", function(args, speaker)
	if #Settings.PluginsTable == 0 then
		notify("Plugin Error", "Zero Plugins Enabled")
	else
		notify("Plugin List: " .. #Settings.PluginsTable, tostring(table.concat(Settings.PluginsTable, ", ")))
	end
end)

newCmd("grabknife", {"knife"}, "grabknife / knife", "Load Grab Knife (Works on Players/Characters you have ownership over)", function(args, speaker)
	notify("", "Loaded Grab Knife", 2)
	Import("knif.lua")
end)

newCmd("clientantikick", {"antikick"}, "clientantikick / antikick (Client)", "Prevents LocalScripts From Kicking You", function(args, speaker)
	local getrawmt = (debug and debug.getmetatable) or getrawmetatable
	local setReadOnly = setreadonly or (make_writeable and function(table, readonly) if readonly then make_readonly(table) else make_writeable(table) end end)
	local getnamecall = getnamecallmethod or get_namecall_method
	local mt = getrawmt(game)
	local old = mt.__namecall
	local closure = newcclosure or protect_function
	local hookfunc = hookfunction or detour_function
	if not closure then
		notify("Incompatible Exploit", "Missing newcclosure or protect_function")
		closure = function(f)
			return f
		end
	end
	setReadOnly(mt, false)
	mt.__namecall = closure(function(self, ...)
		local method = getnamecall()
		if method == "Kick" then
			wait(9e9)
			return
		end
		return old(self, ...)
	end)
	hookfunc(Players.LocalPlayer.Kick, closure(function() wait(9e9) end))
	notify("Client Anti-Kick", "Enabled, only affects locally.")
end)

newCmd("antiafk", {"antiidle"}, "antiafk / antiidle", "Don't Get Kicked for Being AFK", function(args, speaker)
	local getcons = getconnections or get_signal_cons
	if getcons then
		for i,v in pairs(getcons(Players.LocalPlayer.Idled)) do
			if v["Disable"] then
				v["Disable"](v)
			elseif v["Disconnect"] then
				v["Disconnect"](v)
			end
		end
		notify("Anti Idle", "Enabled")
	else
		notify("Incompatible Exploit", "Missing getconnections")
	end
end)

newCmd("btools", {}, "btools", "Building Tools", function(args, speaker)
	if findbp() then
		local Backpack = getbp()
		for i = 1, 4 do
			local Bin = InstanceNew("HopperBin")
			Bin.BinType = i
			Bin.Parent = Backpack
		end
	else
		notify("Command Error", "Missing Backpack")
	end
end)

newCmd("f3x", {"fex"}, "f3x / fex", "Building Tools", function(args, speaker)
	loadstring(game:GetObjects("rbxassetid://4698064966")[1].Source)()
end)

newCmd("console", {}, "console", "Open the Old Roblox Console", function(args, speaker)
	notify("Loading", "Hold on a sec")
	local _, str = pcall(function()
		return game.HttpGetAsync(game, "https://raw.githubusercontent.com/Ballbuster9000/who/main/a/test/what/others/rbx_console.lua", true)
	end)
	local s, e = loadstring(str)
	if typeof(s) ~= "function" then
		return
	end
	local success, message = pcall(s)
	if (not success) then
		if printconsole then
			printconsole(message)
		elseif printoutput then
			printoutput(message)
		end
	end
	wait(1)
	notify("Console", "Press F9 to Open the Console")
end)

newCmd("explorer", {"dex"}, "explorer / dex", "Load a Game Explorer by Moon", function(args, speaker)
	--[[
	if (not is_sirhurt_closure) and syn then
		notify("Loading", "Hold on a sec")
		wait(0.2)
		local Dex = game:GetObjects("rbxassetid://3567096419")[1]
		ParentGui(Dex)
		local Load = function(Obj, Url)
			local GiveOwnGlobals = function(Func, Script)
				local Fenv = {}
				local RealFenv = {script = Script}
				local FenvMt = {}
				FenvMt.__index = function(a,b)
					if not RealFenv[b] then
						return getfenv()[b]
					else
						return RealFenv[b]
					end
				end
				FenvMt.__newindex = function(a, b, c)
					if not RealFenv[b] then
						getfenv()[b] = c
					else
						RealFenv[b] = c
					end
				end
				setmetatable(Fenv, FenvMt)
				setfenv(Func, Fenv)
				return Func
			end
			local LoadScripts = function(Script)
				if Script.ClassName == "Script" or Script.ClassName == "LocalScript" then
					spawn(function()
						GiveOwnGlobals(loadstring(Script.Source, "=" .. Script.GetFullName(Script)), Script)()
					end)
				end
				for i,v in pairs(GetChildren(Script)) do
					LoadScripts(v)
				end
			end
			LoadScripts(Obj)
		end
		Load(Dex)
	elseif is_sirhurt_closure and syn then
		notify("Loading", "Hold on a sec")
		wait(0.2)
		Import("sirh_dex.lua")
	else
		notify("Loading", "Hold on a sec")
		wait(0.2)
		loadstring(game.HttpGetAsync(game, "https://raw.githubusercontent.com/Patch-Shack/newLoad/master/dexv2.lua"))();
	end
	]]--
	Import("v3_fork.lua")
end)

newCmd("remotespy", {"rspy"}, "remotespy / rspy", "Load a Remote Spy (SimpleSpy)", function(args, speaker)
	notify("Loading", "Hold on a sec", 2)
	Import("simple_spy.lua")
end)

newCmd("audiologger", {}, "audiologger", "Audio Logger by Edge", function(args, speaker)
	notify("Loading", "Hold on a sec", 2)
	loadstring(game.HttpGetAsync(game, "https://pastebin.com/raw/GmbrsEjM"))();
end)

newCmd("vr", {}, "vr", "Load the CLOVR VR Script by Abacaxl", function(args, speaker)
	notify("", "Loading CLOVR . . .", 2)
	loadstring(game.HttpGet(game, 'https://ghostbin.co/paste/yb288/raw'))()
end)

newCmd("jobid", {}, "jobid", "Copy the Server's JobId, this can be put in console on Google to join someone's exact server", function(args, speaker)
	local jobId = ('Roblox.GameLauncher.joinGameInstance(' .. tostring(game.PlaceId) .. ', "' .. tostring(game.JobId) ..'")')
	toClipboard(jobId)
end)

newCmd("safechat", {}, "safechat", "Enable Safechat", function(args, speaker)
	speaker.SetSuperSafeChat(speaker, true)
end)

newCmd("nosafechat", {}, "nosafechat", "Disable Safechat", function(args, speaker)
	speaker.SetSuperSafeChat(speaker, false)
end)

newCmd("creeper", {}, "creeper", "Become a Creeper", function(args, speaker)
	if r15(speaker) then
		Destroy(FindFirstChildWhichIsA(speaker.Character.Head, "SpecialMesh"))
		Destroy(speaker.Character.LeftUpperArm)
		Destroy(speaker.Character.RightUpperArm)
		local Human = FindFirstChildWhichIsA(speaker.Character, "Humanoid")
		if Human then Human.RemoveAccessories(Human) end
	else
		Destroy(FindFirstChildWhichIsA(speaker.Character.Head, "SpecialMesh"))
		Destroy(speaker.Character["Left Arm"])
		Destroy(speaker.Character["Right Arm"])
		local Human = FindFirstChildWhichIsA(speaker.Character, "Humanoid")
		if Human then Human.RemoveAccessories(Human) end
	end
end)

newCmd("reach", {}, "reach [number]", "Put reach on the currently equipped tool/item", function(args, speaker)
	execCmd("unreach")
	wait()
	for i,v in pairs(GetDescendants(speaker.Character)) do
		if IsA(v, "Tool") then
			if args[1] then
				currentToolSize = v.Handle.Size
				currentGripPos = v.GripPos
				local a = InstanceNew("SelectionBox")
				Prote.ProtectInstance(a)
				a.Name = selectionBoxName
				a.Parent = v.Handle
				a.Adornee = v.Handle
				Prote.SpoofProperty(v.Handle, "Size")
				Prote.SpoofProperty(v.Handle, "Massless")
				v.Handle.Massless = true
				v.Handle.Size = Vector3.new(0.5, 0.5, args[1])
				v.GripPos = Vector3.new(0, 0, 0)
				local Human = gethum()
				if Human then Human.UnequipTools(Human) end
			else
				currentToolSize = v.Handle.Size
				currentGripPos = v.GripPos
				local a = InstanceNew("SelectionBox")
				Prote.ProtectInstance(a)
				a.Name = selectionBoxName
				a.Parent = v.Handle
				a.Adornee = v.Handle
				Prote.SpoofProperty(v.Handle, "Size")
				Prote.SpoofProperty(v.Handle, "Massless")
				v.Handle.Massless = true
				v.Handle.Size = Vector3.new(0.5, 0.5, 60)
				v.GripPos = Vector3.new(0, 0, 0)
				local Human = gethum()
				if Human then Human.UnequipTools(Human) end
			end
		end
	end
end)

newCmd("unreach", {"noreach"}, "unreach / noreach", "Disable Reach", function(args, speaker)
	for i,v in pairs(GetDescendants(speaker.Character)) do
		if IsA(v, "Tool") then
			v.Handle.Size = currentToolSize
			v.GripPos = currentGripPos
			if FindFirstChild(v.Handle, selectionBoxName) then
				Destroy(v.Handle[selectionBoxName])
			end
		end
	end
end)

newCmd("fov", {}, "fov", "Change your Field of View", function(args, speaker)
	local FOV = 0
	if args[1] then
		FOV = tonumber(args[1])
	else
		FOV = origsettings.Camera.Fov or 70
	end
	Prote.SpoofProperty(workspace.CurrentCamera, "FieldOfView")
	workspace.CurrentCamera.FieldOfView = FOV
end)

newCmd("invisible", {"invis"}, "invisible / invis", "Become invisible to other players", function(args, speaker)
	if invisRunning then return end
	local Root = getRoot()
	local OldPos = Root.CFrame
	InvisSeat = InstanceNew("Seat")
	InvisWeld = InstanceNew("Weld")
	Prote.ProtectInstance(InvisSeat)
	Prote.ProtectInstance(InvisWeld)
	Root.CFrame = CFrame.new(9e9, 9e9, 9e9)
	wait(0.2)
	Root.Anchored = true
	InvisSeat.Transparency = 1
	InvisSeat.Parent = workspace
	InvisSeat.CFrame = Root.CFrame
	InvisSeat.Anchored = false
	InvisWeld.Parent = InvisSeat
	InvisWeld.Part0 = InvisSeat
	InvisWeld.Part1 = Root
	Root.Anchored = false
	InvisSeat.CFrame = OldPos
	for i, v in next, GetChildren(Root.Parent) do
		if IsA(v, "BasePart") or IsA(v, "MeshPart") or IsA(v, "Part") then
			beforeInvisTransparency[v] = v.Transparency
			v.Transparency = v.Transparency <= 0.3 and 0.4 or v.Transparency
		elseif IsA(v, "Accessory") then
			local Handle = FindFirstChildWhichIsA(v, "MeshPart") or FindFirstChildWhichIsA(v, "Part")
			if Handle then
				beforeInvisTransparency[Handle] = Handle.Transparency
				Handle.Transparency = Handle.Transparency <= 0.3 and 0.4 or Handle.Transparency    
			end
		end
	end
	invisRunning = true
	notify("Invisibility", "You are invisible to players!")
end)

newCmd("visible", {"vis"}, "visible / vis", "Disable Invisibility", function(args, speaker)
	if invisRunning == false then return end
	invisRunning = false
	if InvisSeat and InvisWeld then
		Destroy(InvisSeat)
		Destroy(InvisWeld)
		spawn(function()
			wait()
			InvisSeat = false
			InvisWeld = false
		end)
		for i, v in next, beforeInvisTransparency do
			if type(v) == "number" then
				i.Transparency = v
			end
		end
		notify("Invisibility", "You are now visible!")
	end
end)

newCmd("tinvisible", {"tinvis"}, "tinvisible / tinvis", "Invisibility but no godmode but some tools work", function(args, speaker)
	Import("tinv.lua")
	notify("T Invis", "You are now Invisible")
end)

newCmd("gotocamera", {"gotocam"}, "gotocamera / gotocam", "Go to the Workspace Camera", function(args, speaker)
	getRoot(speaker.Character).CFrame = workspace.Camera.CFrame
end)

newCmd("spectate", {"spec", "view"}, "spectate / spec / view [plr]", "Spectate a Player", function(args, speaker)
	FreecamAPI.Stop()
	local users = getPlayer(args[1], speaker)
	for i,v in pairs(users) do
		if viewDied then
			Disconnect(viewDied)
			Disconnect(viewChanged)
		end
		if not Players[v].Character then return notify("Spectate", "Target Missing Character") end
		if not findhum(Players[v].Character) then return notify("Spectate", "Target Missing Humanoid") end
		viewing = Players[v]
		local targethum = gethum(Players[v].Character)
		workspace.Camera.CameraSubject = targethum
		notify("Spectating", Players[v].Name)
		local viewDiedFunc = function()
			repeat wait() until Players[v].Character ~= nil and getRoot(Players[v].Character)
			workspace.Camera.CameraSubject = targethum
		end
		viewDied = CConnect(Players[v].CharacterAdded, viewDiedFunc)
		local viewChangedFunc = function()
			workspace.Camera.CameraSubject = targethum
		end
		viewChanged = CConnect(GetPropertyChangedSignal(workspace.Camera, "CameraSubject"), viewChangedFunc)
	end
end)

newCmd("unspectate", {"unspec", "unview"}, "unspectate / unspec / unview [plr]", "Stop viewing a Player", function(args, speaker)
	FreecamAPI.Stop()
	if viewing ~= nil then viewing = nil end
	if viewDied then
		Disconnect(viewDied)
		Disconnect(viewChanged)
	end
	if findhum() then
		workspace.Camera.CameraSubject = gethum()
		if tostring(args[1]) ~= "nonotify" then
			notify("Spectate", "Disabled")
		end
	else
		if tostring(args[1]) ~= "nonotify" then
			notify("Spectate", "Missing Humanoid")
		end
	end
end)

newCmd("fixcam", {}, "fixcam", "Fix/Restore your Camera", function(args, speaker)
	execCmd("unspectate")
	Destroy(workspace.CurrentCamera)
	wait(0.1)
	repeat wait() until speaker.Character ~= nil
	Prote.SpoofProperty(workspace.CurrentCamera, "CameraType")
	workspace.CurrentCamera.CameraSubject = FindFirstChildWhichIsA(speaker.Character, "Humanoid")
	workspace.CurrentCamera.CameraType = "Custom"
	Prote.SpoofProperty(speaker, "CameraMinZoomDistance")
	Prote.SpoofProperty(speaker, "CameraMaxZoomDistance")
	Prote.SpoofProperty(speaker, "CameraMode")
	speaker.CameraMinZoomDistance = 0.5
	speaker.CameraMaxZoomDistance = 400
	speaker.CameraMode = "Classic"
	if FindFirstChild(speaker.Character, "Head") then
		Prote.SpoofProperty(speaker.Character.Head, "Anchored")
		speaker.Character.Head.Anchored = false
	end
end)

newCmd("esp", {}, "esp", "Use ESP on Players", function(args, speaker)
	ESPenabled = true
	for i,v in pairs(GetChildren(Players)) do
		if v.ClassName == "Player" and v.Name ~= speaker.Name then
			repeat wait() until v.Character and getRoot(v.Character)
			ESP(v)
			CConnect(v.CharacterAdded, function()
				repeat wait() until v.Character and getRoot(v.Character)
				ESP(v)
			end)
		end
	end
end)

newCmd("unesp", {}, "unesp", "Stop Using ESP on Players", function(args, speaker)
	ESPenabled = false
	for i,c in pairs(GetChildren(CoreGui)) do
		if string.sub(c.Name, -4) == "_ESP" then
			Destroy(c)
		end
	end
end)

newCmd("locate", {}, "locate [plr]", "View a single player and their status", function(args, speaker)
	local players = getPlayer(args[1], speaker)
	for i,v in pairs(players) do
		Locate(Players[v])
	end
end)

newCmd("unlocate", {}, "unlocate [plr]", "Removes Locate", function(args, speaker)
	local players = getPlayer(args[1], speaker)
	if args[1] then
		for i,v in pairs(players) do
			for i,c in pairs(GetChildren(CoreGui)) do
				if c.Name == Players[v].Name .. "_LC" then
					Destroy(c)
				end
			end
		end
	else
		for i,c in pairs(GetChildren(CoreGui)) do
			if string.sub(c.Name, -3) == "_LC" then
				Destroy(c)
			end
		end
	end
end)

newCmd("xray", {}, "xray", "Make all parts in Workspace transparent", function(args, speaker)
	xrayobjects(true)
end)

newCmd("unxray", {}, "unxray", "Restore Workspace Transparency", function(args, speaker)
	xrayobjects(false)
end)

newCmd("togglexray", {}, "togglexray", "Toggle Workspace Transparency", function(args, speaker)
	isXrayingObjects = not isXrayingObjects
	xrayobjects(isXrayingObjects)
end)

newCmd("enableshiftlock", {"enablesl"}, "enableshiftlock / enablesl", "Enable Shiftlock", function(args, speaker)
	Prote.SpoofProperty(speaker, "DevEnableMouseLock")
	speaker.DevEnableMouseLock = true
	notify("Shiftlock", "Shift Lock is now Available")
end)

newCmd("firstp", {}, "firstp", "First Person", function(args, speaker)
	Prote.SpoofProperty(speaker.CameraMode, "LockFirstPerson")
	speaker.CameraMode = "LockFirstPerson"
end)

newCmd("thirdp", {}, "thirdp", "Third Person", function(args, speaker)
	Prote.SpoofProperty(speaker.CameraMode, "Classic")
	speaker.CameraMode = "Classic"
end)

newCmd("showprompts", {}, "showprompts", "Continue Receiving Purchase Prompts", function(args, speaker)
	CoreGui.PurchasePrompt.Visible = true
end)

newCmd("noprompts", {}, "noprompts", "Stop Receiving Purchase Prompts", function(args, speaker)
	CoreGui.PurchasePrompt.Visible = false
end)

newCmd("deletehats", {"nohats"}, "deletehats / nohats", "Delete your Hats", function(args, speaker)
	if speaker and speaker.Character then
		for i, v in next, GetDescendants(speaker.Character) do
			if IsA(v, "Accessory") then
				for i2, v2 in next, GetDescendants(v) do
					if IsA(v2, "Weld") then
						Destroy(v2)
					end
				end
			end
		end
	end
end)

newCmd("breakloops", {"break"}, "breakloops / break", "Stops every current command loop (inf^reset)", function(args, speaker)
	lastBreakTime = tick()
end)

newCmd("grabtools", {}, "grabtools", "Copies Tools from ReplicatedStorage and Lighting", function(args, speaker)
	local copyinst = nil
	copyinst = function(instance)
		for i,c in pairs(GetChildren(instance)) do
			if IsA(c, "Tool") or IsA(c, "HopperBin") then
				Clone(c).Parent = FindFirstChildOfClass(speaker, "Backpack")
			end
			copyinst(c)
		end
	end
	copyinst(Lighting)
	copyinst(ReplicatedStorage)
	notify("Tools", "Copied Tools from ReplicatedStorage and Lighting")
end)

newCmd("removetools", {}, "removetools", "Removes Tools from Character and Backpack", function(args, speaker)
	for i,v in pairs(GetDescendants(FindFirstChildOfClass(speaker, "Backpack"))) do
		if IsA(v, "Tool") or IsA(v, "HopperBin") then
			Destroy(v)
		end
	end
	for i,v in pairs(GetDescendants(speaker.Character)) do
		if IsA(v, "Tool") or IsA(v, "HopperBin") then
			Destroy(v)
		end
	end
	notify("Tools", "Removed All Tools from Character and Backpack")
end)

newCmd("copytools", {}, "copytools [plr] (Client)", "Copies a Player's Tools", function(args, speaker)
	local players = getPlayer(args[1], speaker)
	for i,v in pairs(players) do
		spawn(function()
			for i,v in pairs(GetChildren(FindFirstChildOfClass(Players[v], "Backpack"))) do
				if IsA(v, "Tool") or IsA(v, "HopperBin") then
					Clone(v).Parent = FindFirstChildOfClass(speaker, "Backpack")
				end
			end
		end)
		notify("Tools", "Copied Tools from " .. Players[v].Name)
	end
end)

newCmd("equiptools", {}, "equiptools", "Equips every Tool in your Inventory", function(args, speaker)
	for i,v in pairs(GetChildren(FindFirstChildOfClass(speaker, "Backpack"))) do
		if IsA(v, "Tool") or IsA(v, "HopperBin") then
			v.Parent = speaker.Character
		end
	end
end)

newCmd("activatetools", {}, "activatetools", "Equips and activates all of your tools", function(args, speaker)
	if findhum(speaker.Character) then
		local Human = gethum(speaker.Character)
		Human.UnequipTools(Human)
	end
	local SendMouseButtonEvent = VirtualInputManager.SendMouseButtonEvent
	local GrabbedTools = {}
	for i,v in pairs(GetChildren(FindFirstChildOfClass(speaker, "Backpack"))) do
		if IsA(v, "Tool") or IsA(v, "HopperBin") then
			table.insert(GrabbedTools, v)
			v.Parent = speaker.Character
		end
	end
	wait()
	for i, v in next, GrabbedTools do
		v.Activate(v)
	end
	SendMouseButtonEvent(VirtualInputManager, 0, 0, 0, true, nil, #GrabbedTools)
end)

newCmd("droptools", {}, "droptools", "Drop all of your tools", function(args, speaker)
	for i,v in pairs(GetChildren(Players.LocalPlayer.Backpack)) do
		if IsA(v, "Tool") then
			Prote.SpoofProperty(v, "Parent")
			v.Parent = Players.LocalPlayer.Character
			v.Parent = workspace
		end
	end
	wait()
	for i,v in pairs(GetChildren(Players.LocalPlayer.Character)) do
		if IsA("Tool") then
			Prote.SpoofProperty(v, "Parent")
			v.Parent = workspace
		end
	end
end)

newCmd("droppabletools", {}, "droppabletools", "Make Undroppable Tools Droppable", function(args, speaker)
	if speaker and speaker.Character then
		for _,obj in pairs(GetChildren(speaker.Character)) do
			if IsA(obj, "Tool") then
				Prote.SpoofProperty(obj, "CanBeDropped")
				obj.CanBeDropped = true
			end
		end
	end
	if speaker and FindFirstChildOfClass(speaker, "Backpack") then
		for _,obj in pairs(GetChildren(FindFirstChildOfClass(speaker, "Backpack"))) do
			if IsA(obj, "Tool") then
				Prote.SpoofProperty(obj, "CanBeDropped")
				obj.CanBeDropped = true
			end
		end
	end
end)

newCmd("copyusername", {"copyname"}, "copyusername / copyname", "Copies a player's full username to your clipboard", function(args, speaker)
	local players = getPlayer(args[1], speaker)
	for i,v in pairs(players) do
		local name = tostring(Players[v].Name)
		toClipboard(name)
		notify("Copied", "Name - " .. name)
	end
end)

newCmd("copyuserid", {"copyid"}, "copyuserid / copyid", "Copies a player's User ID to your clipboard", function(args, speaker)
	local players = getPlayer(args[1], speaker)
	for i,v in pairs(players) do
		local id = tostring(Players[v].UserId)
		toClipboard(id)
		notify("Copied", "ID - " .. id)
	end
end)

newCmd("resetuserid", {}, "resetuserid", "Set your User ID back to normal", function(args, speaker)
	speaker.UserId = origsettings.Player.Id
	notify("", "Set UserId to Original")
end)

newCmd("setcreatorid", {}, "setcreatorid", "Set your User ID to the Creator's User ID", function(args, speaker)
	if game.CreatorType == Enum.CreatorType.User then
		speaker.UserId = game.CreatorId
		notify("", "Set UserId to " .. game.CreatorId)
	elseif game.CreatorType == Enum.CreatorType.Group then
		local OwnerID = GroupService.GetGroupInfoAsync(GroupService, game.CreatorId).Owner.Id
		speaker.UserId = OwnerID
		notify("", "Set UserId to " .. OwnerID)
	end
end)

newCmd("printposition", {"printpos"}, "printposition / printpos", "Print Current Position", function(args, speaker)
	local curpos = speaker.Character and (getRoot(speaker.Character) or FindFirstChildWhichIsA(speaker.Character, "BasePart"))
	curpos = curpos and curpos.Position
	if not curpos then return notify("Position", "Missing Character") end
	curpos = (math.round(curpos.X) .. ", " .. math.round(curpos.Y) .. ", " .. math.round(curpos.Z))
	print("Current Position: " .. curpos)
end)

newCmd("notifyposition", {"notifypos"}, "notifyposition / notifypos", "Notify Current Position", function(args, speaker)
	local curpos = speaker.Character and (getRoot(speaker.Character) or FindFirstChildWhichIsA(speaker.Character, "BasePart"))
	curpos = curpos and curpos.Position
	if not curpos then return notify("Position", "Missing Character") end
	curpos = (math.round(curpos.X) .. ", " .. math.round(curpos.Y) .. ", " .. math.round(curpos.Z))
	notify("Current Position", curpos)
end)

newCmd("copyposition", {"copypos"}, "copyposition / copypos", "Copy Current Position to Clipboard", function(args, speaker)
	local curpos = speaker.Character and (getRoot(speaker.Character) or FindFirstChildWhichIsA(speaker.Character, "BasePart"))
	curpos = curpos and curpos.Position
	if not curpos then return notify("Position", "Missing Character") end
	curpos = (math.round(curpos.X) .. ", " .. math.round(curpos.Y) .. ", " .. math.round(curpos.Z))
	if toClipboard then toClipboard(curpos) end
end)

newCmd("swim", {}, "swim", "Become fish", function(args, speaker)
	Prote.SpoofProperty(workspace, "Gravity")
	workspace.Gravity = 0
	local swimDied = function()
		workspace.Gravity = 198.2
		swimming = false
	end
	local Human = gethum(speaker.Character)
	Prote.SpoofInstance(Human)
	gravReset = CConnect(Human.Died, swimDied)
	Human.SetStateEnabled(Human, Enum.HumanoidStateType.Climbing, false)
	Human.SetStateEnabled(Human, Enum.HumanoidStateType.FallingDown, false)
	Human.SetStateEnabled(Human, Enum.HumanoidStateType.Flying, false)
	Human.SetStateEnabled(Human, Enum.HumanoidStateType.Freefall, false)
	Human.SetStateEnabled(Human, Enum.HumanoidStateType.GettingUp, false)
	Human.SetStateEnabled(Human, Enum.HumanoidStateType.Jumping, false)
	Human.SetStateEnabled(Human, Enum.HumanoidStateType.Landed, false)
	Human.SetStateEnabled(Human, Enum.HumanoidStateType.Physics, false)
	Human.SetStateEnabled(Human, Enum.HumanoidStateType.PlatformStanding, false)
	Human.SetStateEnabled(Human, Enum.HumanoidStateType.Ragdoll, false)
	Human.SetStateEnabled(Human, Enum.HumanoidStateType.Running, false)
	Human.SetStateEnabled(Human, Enum.HumanoidStateType.RunningNoPhysics, false)
	Human.SetStateEnabled(Human, Enum.HumanoidStateType.Seated, false)
	Human.SetStateEnabled(Human, Enum.HumanoidStateType.StrafingNoPhysics, false)
	Human.SetStateEnabled(Human, Enum.HumanoidStateType.Swimming, false)
	Human.ChangeState(Human, Enum.HumanoidStateType.Swimming)
	swimming = true
end)

newCmd("unswim", {}, "unswim", "Reject fish become human", function(args, speaker)
	Prote.SpoofProperty(workspace, "Gravity")
	workspace.Gravity = 198.2
	swimming = false
	if gravReset then
		Disconnect(gravReset)
	end
	local Human = gethum(speaker.Character)
	Prote.SpoofInstance(Human)
	Human.SetStateEnabled(Human, Enum.HumanoidStateType.Climbing, true)
	Human.SetStateEnabled(Human, Enum.HumanoidStateType.FallingDown, true)
	Human.SetStateEnabled(Human, Enum.HumanoidStateType.Flying, true)
	Human.SetStateEnabled(Human, Enum.HumanoidStateType.Freefall, true)
	Human.SetStateEnabled(Human, Enum.HumanoidStateType.GettingUp, true)
	Human.SetStateEnabled(Human, Enum.HumanoidStateType.Jumping, true)
	Human.SetStateEnabled(Human, Enum.HumanoidStateType.Landed, true)
	Human.SetStateEnabled(Human, Enum.HumanoidStateType.Physics, true)
	Human.SetStateEnabled(Human, Enum.HumanoidStateType.PlatformStanding, true)
	Human.SetStateEnabled(Human, Enum.HumanoidStateType.Ragdoll, true)
	Human.SetStateEnabled(Human, Enum.HumanoidStateType.Running, true)
	Human.SetStateEnabled(Human, Enum.HumanoidStateType.RunningNoPhysics, true)
	Human.SetStateEnabled(Human, Enum.HumanoidStateType.Seated, true)
	Human.SetStateEnabled(Human, Enum.HumanoidStateType.StrafingNoPhysics, true)
	Human.SetStateEnabled(Human, Enum.HumanoidStateType.Swimming, true)
	Human.ChangeState(Human, Enum.HumanoidStateType.RunningNoPhysics)
end)

newCmd("unlockws", {}, "unlockws", "Unlock Workspace", function(args, speaker)
	for i,v in pairs(GetDescendants(workspace)) do
		if IsA(v, "BasePart") then
			Prote.SpoofProperty(v, "Locked")
			v.Locked = false
		end
	end
end)

newCmd("saveplace", {}, "saveplace", "Save the Game", function(args, speaker)
	if saveinstance then
		notify("Downloading", "This will take a while")
		if getsynasset then
			saveinstance()
		else
			saveinstance(game)
		end
		notify("Game Saved", "Check Workspace Folder")
	else
		notify("Incompatible Exploit", "Missing saveinstance")
	end
end)

newCmd("nilchar", {}, "nilchar", "Makes your Character's parent Nil", function(args, speaker)
	if speaker and speaker.Character ~= nil then
		Prote.SpoofProperty(speaker.Character, "Parent")
		speaker.Character.Parent = nil
	end
end)

newCmd("unnilchar", {}, "unnilchar", "Makes your Character's parent Workspace", function(args, speaker)
	if speaker and speaker.Character ~= nil then
		Prote.SpoofProperty(speaker.Character, "Parent")
		speaker.Character.Parent = workspace
	end
end)

newCmd("breakvelocity", {}, "breakvelocity", "Break your Velocity", function(args, speaker)
	local BeenASecond, V3 = false, Vector3.new(0, 0, 0)
	delay(1, function()
		BeenASecond = true
	end)
	while not BeenASecond do
		for _, v in ipairs(GetDescendants(speaker.Character)) do
			if IsA(v, "BasePart") then
				Prote.SpoofProperty(v, "Velocity")
				Prote.SpoofProperty(v, "RotVelocity")
				v.Velocity, v.RotVelocity = V3, V3
			end
		end
		wait()
	end
end)

newCmd("flashback", {}, "flashback", "Go back to where you last died", function(args, speaker)
	if LastDeathPos ~= nil then
		if findhum(speaker.Character) and gethum(speaker.Character).SeatPart then
			local Human = gethum(speaker.Character)
			Prote.SpoofProperty(Human, "Sit")
			Human.Sit = false
			wait(.1)
		end
		getRoot(speaker.Character).CFrame = LastDeathPos
	end
end)

newCmd("dupetools", {}, "dupetools [number]", "Duplicate Tools in your Inventory", function(args, speaker)
	local LOOP_NUM = tonumber(args[1]) or 1
	local OrigPos = speaker.Character.HumanoidRootPart.Position
	local Tools, TempPos = {}, Vector3.new(math.random(-2e5, 2e5), 2e5, math.random(-2e5, 2e5))
	for i = 1, LOOP_NUM do
		local Human = gethum()
		wait(.1, Human.Parent.MoveTo(Human.Parent, TempPos))
		Prote.SpoofProperty(Human.RootPart, "Anchored")
		Human.RootPart.Anchored = speaker.ClearCharacterAppearance(speaker, wait(.1)) or true
		local t = GetHandleTools(speaker)
		while #t > 0 do
			for _, v in ipairs(t) do
				coroutine.wrap(function()
					for _ = 1, 25 do
						Prote.SpoofProperty(v, "Parent")
						v.Parent = speaker.Character
						v.Handle.Anchored = true
					end
					for _ = 1, 5 do
						Prote.SpoofProperty(v, "Parent")
						v.Parent = workspace
					end
					table.insert(Tools, v.Handle)
				end)()
			end
			t = GetHandleTools(speaker)
		end
		wait(.1)
		speaker.Character = Destroy(speaker.Character)
		CWait(speaker.CharacterAdded)
		local createdHuman = WaitForChild(speaker.Character, "Humanoid").Parent
		createdHuman.MoveTo(createdHuman, LOOP_NUM == i and OrigPos or TempPos, wait(.1))
		if i == LOOP_NUM or i % 5 == 0 then
			local HRP = speaker.Character.HumanoidRootPart
			if type(firetouchinterest) == "function" then
				for _, v in ipairs(Tools) do
					v.Anchored = not firetouchinterest(v, HRP, 1, firetouchinterest(v, HRP, 0)) and false or false
				end
			else
				for _, v in ipairs(Tools) do
					coroutine.wrap(function()
						local x = v.CanCollide
						Prote.SpoofProperty(v, "CanCollide")
						Prote.SpoofProperty(v, "Anchored")
						v.CanCollide = false
						v.Anchored = false
						for _ = 1, 10 do
							v.CFrame = HRP.CFrame
							wait()
						end
						v.CanCollide = x
					end)()
				end
			end
			wait(.1)
			Tools = {}
		end
		TempPos = TempPos + Vector3.new(10, math.random(-5, 5), 0)
	end
end)

newCmd("commandcount", {}, "commandcount", "Notify the Amount of Commands", function(args, speaker)
	notify("Command Count", #cmds)
end)

newCmd("lag", {}, "lag", "Make yourself look like you are lagging", function(args, speaker)
	notify("Fake Lag", "Enabled")
	FakeLagging = true
	Prote.SpoofProperty(getRoot(speaker.Character), "Anchored")
	repeat wait()
		getRoot(speaker.Character).Anchored = false
		wait(0.1)
		getRoot(speaker.Character).Anchored = true
		wait(0.1)
	until not FakeLagging
end)

newCmd("unlag", {}, "unlag", "Stop the fake lag", function(args, speaker)
	FakeLagging = false
	notify("Fake Lag", "Disabled")
	wait(0.3)
	Prote.SpoofProperty(getRoot(speaker.Character), "Anchored")
	getRoot(speaker.Character).Anchored = false
end)

newCmd("spin", {}, "spin [number]", "Spins your character", function(args, speaker)
	local spinSpeed = 20
	if args[1] and isNumber(args[1]) then
		spinSpeed = args[1]
	end
	for i,v in pairs(GetChildren(getRoot(speaker.Character))) do
		if v.Name == spinName then
			Destroy(v)
		end
	end
	local Spin = InstanceNew("BodyAngularVelocity")
	Prote.ProtectInstance(Spin)
	Spin.Parent = getRoot(Players.LocalPlayer.Character)
	Spin.Name = spinName
	Spin.MaxTorque = Vector3.new(0, math.huge, 0)
	Spin.AngularVelocity = Vector3.new(0, spinSpeed, 0)
end)

newCmd("unspin", {}, "unspin", "Disables Spin", function(args, speaker)
	for i,v in pairs(GetChildren(getRoot(speaker.Character))) do
		if v.Name == spinName then
			Destroy(v)
		end
	end
end)

newCmd("fling", {}, "fling", "Flings anyone you touch", function(args, speaker)
	local rootpart = getRoot(speaker.Character)
	if not rootpart then return end
	flingtbl.OldVelocity = rootpart.Velocity
	local bv = InstanceNew("BodyAngularVelocity")
	Prote.ProtectInstance(bv)
	flingtbl.bv = bv
	bv.MaxTorque = Vector3.new(1, 1, 1) * math.huge
	bv.P = math.huge
	bv.AngularVelocity = Vector3.new(0, 9e5, 0)
	bv.Parent = rootpart
	local Char = GetChildren(speaker.Character)
	for i, v in next, Char do
	    if IsA(v, "BasePart") then
	        v.CanCollide = false
	        v.Massless = true
	        v.Velocity = Vector3.new(0, 0, 0)
	    end
	end
	flingtbl.Noclipping2 = CConnect(Stepped, function()
	    for i, v in next, Char do
	        if IsA(v, "BasePart") then
	            v.CanCollide = false
	        end
	    end
	end)
	cmdflinging = true
end)

newCmd("unfling", {}, "unfling", "Disables the Fling Command", function(args, speaker)
	local rootpart = getRoot(speaker.Character)
	if not rootpart then return end
	flingtbl.OldPos = rootpart.CFrame
	local Char = GetChildren(speaker.Character)
	if flingtbl.bv ~= nil then
		Destroy(flingtbl.bv)
		flingtbl.bv = nil
	end
	if flingtbl.Noclipping2 ~= nil then
		Disconnect(flingtbl.Noclipping2)
		flingtbl.Noclipping2 = nil
	end
	for i, v in next, Char do
		if IsA(v, "BasePart") then
			v.CanCollide = true
			v.Massless = false
		end
	end
	flingtbl.isRunning = CConnect(Stepped, function()
		if flingtbl.OldPos ~= nil then
			rootpart.CFrame = flingtbl.OldPos
		end
		if flingtbl.OldVelocity ~= nil then
			rootpart.Velocity = flingtbl.OldVelocity
		end
	end)
	wait(2)
	rootpart.Anchored = true
	if flingtbl.isRunning ~= nil then
		Disconnect(flingtbl.isRunning)
		flingtbl.isRunning = nil
	end
	rootpart.Anchored = false
	if flingtbl.OldVelocity ~= nil then
		rootpart.Velocity = flingtbl.OldVelocity
	end
	if flingtbl.OldPos ~= nil then
		rootpart.CFrame = flingtbl.OldPos
	end
	wait()
	flingtbl.OldVelocity = nil
	flingtbl.OldPos = nil
	cmdflinging = false
end)

newCmd("togglefling", {}, "togglefling", "Toggle the Fling Command", function(args, speaker)
	if cmdflinging then
		execCmd("unfling")
	else
		execCmd("fling")
	end
end)

newCmd("invisfling", {}, "invisfling", "Enables Invisible Fling", function(args, speaker)
	local ch = speaker.Character
	local prt = InstanceNew("Model")
	Prote.ProtectInstance(prt)
	prt.Parent = speaker.Character
	local z1 = InstanceNew("Part")
	Prote.ProtectInstance(z1)
	z1.Name = "Torso"
	z1.CanCollide = false
	z1.Anchored = true
	local z2 = InstanceNew("Part")
	Prote.ProtectInstance(z2)
	z2.Name = "Head"
	z2.Parent = prt
	z2.Anchored = true
	z2.CanCollide = false
	local z3 = InstanceNew("Humanoid")
	Prote.ProtectInstance(z3)
	z3.Name = "Humanoid"
	z3.Parent = prt
	z1.Position = Vector3.new(0,9999,0)
	speaker.Character = prt
	wait(3)
	speaker.Character = ch
	wait(3)
	local Hum = InstanceNew("Humanoid")
	Prote.ProtectInstance(Hum)
	Clone(z2)
	Hum.Parent = speaker.Character
	local root =  getRoot(speaker.Character)
	for i,v in pairs(GetChildren(speaker.Character)) do
		if v ~= root and v.Name ~= "Humanoid" then
			Destroy(v)
		end
	end
	Prote.SpoofProperty(root, "Transparency")
	Prote.SpoofProperty(root, "Color")
	root.Transparency = 0
	root.Color = Color3.new(1, 1, 1)
	local invisflingStepped
	invisflingStepped = CConnect(Stepped, function()
		if speaker.Character and getRoot(speaker.Character) then
			Prote.SpoofProperty(getRoot(speaker.Character), "CanCollide")
			getRoot(speaker.Character).CanCollide = false
		else
			Disconnect(invisflingStepped)
		end
	end)
	sFLY()
	Prote.SpoofProperty(workspace.CurrentCamera, "CameraSubject")
	workspace.CurrentCamera.CameraSubject = root
	local bambam = InstanceNew("BodyThrust")
	Prote.ProtectInstance(bambam)
	bambam.Parent = getRoot(speaker.Character)
	bambam.Force = Vector3.new(99999, 99999 * 10, 99999)
	bambam.Location = getRoot(speaker.Character).Position
end)

newCmd("infinitejump", {"infjump"}, "infinitejump / infjump", "Be Able to Keep Jumping", function(args, speaker)
	cmdinfjump = true
	CConnect(UserInputService.JumpRequest, function()
		if cmdinfjump then
			if findhum() then
				local Human = gethum()
				Prote.SpoofInstance(Human)
				Human.ChangeState(Human, "Jumping")
			end
		end
	end)
	notify("Infinite Jump", "Enabled")
end)

newCmd("uninfinitejump", {"uninfjump"}, "uninfinitejump / uninfjump", "Disable Infinite Jump", function(args, speaker)
	cmdinfjump = false
	notify("Infinite Jump", "Disabled")
end)

newCmd("serverhop", {"shop"}, "serverhop / shop", "Teleports you to a different server", function(args, speaker)
	local Cache = MemStorageService.HasItem(MemStorageService, "JobId_CACHE_DA") and JSONDecode(HttpService, MemStorageService.GetItem(MemStorageService, "JobId_CACHE_DA")) or {}
	if not table.find(Cache, game.JobId) then
		Cache[#Cache + 1] = game.JobId
	end
	MemStorageService.RemoveItem(MemStorageService, "JobId_CACHE_DA")
	MemStorageService.SetItem(MemStorageService, "JobId_CACHE_DA", JSONEncode(HttpService, Cache))
	local Servers = {}
	for _, v in ipairs(HopTbl.GetPublicServers(game.PlaceId)) do
		if type(v) == "table" and v.maxPlayers > v.playing and not table.find(Cache, v.id) then
			Servers[#Servers + 1] = v
		end
	end
	table.sort(Servers, function(a, b)
		return a.ping < b.ping
	end)
	if #Servers > 0 then
		notify("Serverhop", "Teleporting to a new server")
		TeleportService.TeleportToPlaceInstance(TeleportService, game.PlaceId, Servers[1].id, speaker)
	else
		MemStorageService.RemoveItem(MemStorageService, "JobId_CACHE_DA")
		notify("Server Hop", "Failed to find a new server. Try again.")
	end
end)

newCmd("hipheight", {"hh"}, "hipheight / hh [number]", "Adjusts Hip Height", function(args, speaker)
	local height = nil
	if r15(speaker) then
		height = args[1] or 2.1
	else
		height = args[1] or 0
	end
	if findhum() then
		local Human = gethum()
		Prote.SpoofProperty(Human, "HipHeight")
		Human.HipHeight = height
	end
end)

local bringT = {}
newCmd("loopbring", {}, "loopbring [plr] [distance] [delay] (Client)", "Loop brings a player to you (useful for killing)", function(args, speaker)
	local players = getPlayer(args[1], speaker)
	for i,v in pairs(players) do
		spawn(function()
			if Players[v].Name ~= speaker.Name and not FindInTable(bringT, Players[v].Name) then
				table.insert(bringT, Players[v].Name)
				local plrName = Players[v].Name
				local pchar=Players[v].Character
				local distance = 3
				if args[2] and isNumber(args[2]) then
					distance = args[2]
				end
				local lDelay = 0
				if args[3] and isNumber(args[3]) then
					lDelay = args[3]
				end
				repeat
					for i,c in pairs(players) do
						if FindFirstChild(Players, v) then
							pchar = Players[v].Character
							if pchar ~= nil and Players[v].Character ~= nil and getRoot(pchar) and speaker.Character ~= nil and getRoot(speaker.Character) then
								getRoot(pchar).CFrame = getRoot(speaker.Character).CFrame + Vector3.new(distance, 1, 0)
							end
							wait(lDelay)
						else 
							for a,b in pairs(bringT) do if b == plrName then table.remove(bringT, a) end end
						end
					end
				until not FindInTable(bringT, plrName)
			end
		end)
	end
end)

newCmd("unloopbring", {}, "unloopbring [plr]", "Undoes Loopbring", function(args, speaker)
	local players = getPlayer(args[1], speaker)
	for i,v in pairs(players) do
		spawn(function()
			for a,b in pairs(bringT) do if b == Players[v].Name then table.remove(bringT, a) end end
		end)
	end
end)

newCmd("freeze", {"fr"}, "freeze / fr [plr] (Client)", "Freezes a Player", function(args, speaker)
	local players = getPlayer(args[1], speaker)
	if players ~= nil then
		for i,v in pairs(players) do
			spawn(function()
				for i, x in next, GetDescendants(Players[v].Character) do
					if IsA(x, "BasePart") and not x.Anchored then
						Prote.SpoofProperty(x, "Anchored")
						x.Anchored = true
					end
				end
			end)
		end
	end
end)

newCmd("thaw", {"unfr"}, "thaw / unfr [plr] (Client)", "Unfreezes a Player", function(args, speaker)
	local players = getPlayer(args[1], speaker)
	if players ~= nil then
		for i,v in pairs(players) do
			spawn(function()
				for i, x in next, GetDescendants(Players[v].Character) do
					if IsA(x, "BasePart") and x.Anchored then
						Prote.SpoofProperty(x, "Anchored")
						x.Anchored = false
					end
				end
			end)
		end
	end
end)

newCmd("spawnpoint", {}, "spawnpoint [delay]", "Sets a position where you will spawn", function(args, speaker)
	local curpos = math.round(getRoot(speaker.Character).Position.X) .. ", " .. math.round(getRoot(speaker.Character).Position.Y) .. ", " .. math.round(getRoot(speaker.Character).Position.Z)
	spawnpos = getRoot(speaker.Character).CFrame
	spawnpoint = true
	spDelay = tonumber(args[1]) or 0.1
	notify("Spawn Point", "Created at " .. curpos)
end)

newCmd("unspawnpoint", {}, "unspawnpoint", "Removes your custom spawnpoint", function(args, speaker)
	spawnpoint = false
	notify("Spawn Point", "Removed Spawn Point")
end)

newCmd("removeclothes", {"naked"}, "removeclothes / naked", "Removes your Clothing", function(args, speaker)
	for i,v in pairs(GetDescendants(speaker.Character)) do
		if IsA(v, "Clothing") then
			Destroy(v)
		end
		if IsA(v, "ShirtGraphic") then
			Destroy(v)
		end
	end
end)

newCmd("noface", {}, "noface", "Removes your Face", function(args, speaker)
	for i,v in pairs(GetDescendants(speaker.Character)) do
		if IsA(v, "Decal") then
			if string.lower(v.Name) == "face" then
				Destroy(v)
			end
		end
	end
end)

newCmd("headless", {}, "headless", "Removes your Head (Uses Simulation Radius)", function(args, speaker)
	if sethidden then
		local lplr = Players.LocalPlayer
		local char = lplr.Character
		local rig = tostring(char.Humanoid.RigType) == "Enum.HumanoidRigType.R6" and 1 or tostring(char.Humanoid.RigType) == "Enum.HumanoidRigType.R15" and 2
		local speaker = Players.LocalPlayer
		sethidden(speaker, "SimulationRadius", math.huge)
		local test = InstanceNew("Model")
		Prote.ProtectInstance(test)
		local hum  = InstanceNew("Humanoid")
		Prote.ProtectInstance(hum)
		local animation = InstanceNew("Model")
		Prote.ProtectInstance(animation)
		local humanoidanimation = InstanceNew("Humanoid")
		Prote.ProtectInstance(humanoidanimation)
		test.Parent = workspace
		hum.Parent = test
		animation.Parent = workspace
		humanoidanimation.Parent = animation
		lplr.Character = test
		wait(2)
		char.Humanoid.Animator.Parent = humanoidanimation
		Destroy(char.Humanoid)
		Destroy(char.Head)
		wait(5)
		Players.LocalPlayer.Character = char
		local hum2 = InstanceNew("Humanoid")
		Prote.ProtectInstance(hum2)
		hum2.Parent = char
		FindFirstChildOfClass(char, "Humanoid").Jump = true
		humanoidanimation.Animator.Parent = hum2
		SetLocalAnimate(char, true)
		wait()
		SetLocalAnimate(char, false)
		wait()
		if rig == 1 then
			hum2.HipHeight = 0
		elseif rig == 2 then
			hum2.HipHeight = 2.19
		end
	else
		notify("Incompatible Exploit", "Missing sethiddenproperty")
	end
end)

newCmd("autorejoin", {"autorj"}, "autorejoin / autorj", "Automatically rejoins the server if you get kicked/disconnected", function(args, speaker)
	Settings.cmdautorj = true
	updatesaves()
	notify("Auto Rejoin", "Enabled")
end)

newCmd("unautorejoin", {"unautorj"}, "unautorejoin / unautorj", "Disable Auto Rejoin", function(args, speaker)
	Settings.cmdautorj = false
	updatesaves()
	notify("Auto Rejoin", "Disabled")
end)

newCmd("teleport", {"tp"}, "teleport / tp [plr] [plr] (Tool)", "Teleports a player to another player (Tool Required)", function(args, speaker)
	local players1 = getPlayer(args[1], speaker)
	local players2 = getPlayer(args[2], speaker)
	for i,v in pairs(players1) do
		if getRoot(Players[v].Character) and getRoot(Players[players2[1]].Character) then
			if FindFirstChildOfClass(speaker.Character, "Humanoid") and FindFirstChildOfClass(speaker.Character, "Humanoid").SeatPart then
				FindFirstChildOfClass(speaker.Character, "Humanoid").Sit = false
				wait(.1)
			end
			teleport(speaker, Players[v], Players[players2[1]])
		end
	end
end)

newCmd("fastteleport", {"fasttp"}, "fastteleport / fasttp [plr] [plr] (Tool)", "Teleports a player to another player faster (Tool Required)", function(args, speaker)
	local players1 = getPlayer(args[1], speaker)
	local players2 = getPlayer(args[2], speaker)
	for i,v in pairs(players1) do
		if getRoot(Players[v].Character) and getRoot(Players[players2[1]].Character) then
			if FindFirstChildOfClass(speaker.Character, "Humanoid") and FindFirstChildOfClass(speaker.Character, "Humanoid").SeatPart then
				FindFirstChildOfClass(speaker.Character, "Humanoid").Sit = false
				wait(.1)
			end
			teleport(speaker, Players[v], Players[players2[1]], true)
		end
	end
end)

newCmd("fullbright", {"fb"}, "fullbright / fb (Client)", "Makes the map brighter / more visible", function(args, speaker)
	Prote.SpoofProperty(Lighting, "Brightness")
	Prote.SpoofProperty(Lighting, "ClockTime")
	Prote.SpoofProperty(Lighting, "FogEnd")
	Prote.SpoofProperty(Lighting, "OutdoorAmbient")
	Prote.SpoofProperty(Lighting, "GlobalShadows")
	Lighting.Brightness = 2
	Lighting.ClockTime = 14
	Lighting.FogEnd = 100000
	Lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128)
	Lighting.GlobalShadows = false
end)

newCmd("loopfullbright", {"loopfb"}, "loopfullbright / loopfb", "Makes the map brighter / more visible but looped", function(args, speaker)
	if brightLoop then
		Disconnect(brightLoop)
	end
	Prote.SpoofProperty(Lighting, "Brightness")
	Prote.SpoofProperty(Lighting, "ClockTime")
	Prote.SpoofProperty(Lighting, "FogEnd")
	Prote.SpoofProperty(Lighting, "GlobalShadows")
	Prote.SpoofProperty(Lighting, "OutdoorAmbient")
	local brightFunc = function()
		Lighting.Brightness = 2
		Lighting.ClockTime = 14
		Lighting.FogEnd = 100000
		Lighting.GlobalShadows = false
		Lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128)
	end
	brightLoop = CConnect(RenderStepped, brightFunc)
end)

newCmd("unloopfullbright", {"unfb"}, "unloopfullbright / unloopfb", "Disable Loop Full Bright", function(args, speaker)
	if brightLoop then
		Disconnect(brightLoop)
	end
end)

newCmd("day", {}, "day (Client)", "Changes the time to day for the client", function(args, speaker)
	Prote.SpoofProperty(Lighting, "ClockTime")
	Lighting.ClockTime = 14
end)

newCmd("night", {}, "night (Client)", "Changes the time to night for the client", function(args, speaker)
	Prote.SpoofProperty(Lighting, "ClockTime")
	Lighting.ClockTime = 0
end)

newCmd("nofog", {}, "nofog (Client)", "Removes Fog", function(args, speaker)
	Prote.SpoofProperty(Lighting, "FogEnd")
	Lighting.FogEnd = 100000
end)

newCmd("brightness", {}, "brightness [num] (Client)", "Changes the Brightness Lighting Property", function(args, speaker)
	if args[1] then
		Prote.SpoofProperty(Lighting, "Brightness")
		Lighting.Brightness = args[1]
	else
		Prote.SpoofProperty(Lighting, "ClockTime")
		Lighting.Brightness = origsettings.Lighting.brt
	end
end)

newCmd("globalshadows", {"gshadows"}, "globalshadows / gshadows", "Enables Global Shadows", function(args, speaker)
	Prote.SpoofProperty(Lighting, "GlobalShadows")
	Lighting.GlobalShadows = true
end)

newCmd("noglobalshadows", {"nogshadows"}, "noglobalshadows / nogshadows", "Disables Global Shadows", function(args, speaker)
	Prote.SpoofProperty(Lighting, "GlobalShadows")
	Lighting.GlobalShadows = false
end)

newCmd("light", {}, "light [radius] [brightness] (Client)", "Gives your Player Dynamic Light", function(args, speaker)
	if speaker and speaker.Character and getRoot(speaker.Character) then
		local light = InstanceNew("PointLight")
		Prote.SpoofInstance(light)
		light.Parent = getRoot(speaker.Character)
		light.Name = pointLightName
		light.Range = 30
		if args[1] then
			light.Brightness = args[2]
			light.Range = args[1]
		else
			light.Brightness = 5
		end
	end
end)

newCmd("unlight", {}, "unlight", "Removes Dynamic Light from your Player", function(args, speaker)
	if speaker and speaker.Character then
		for i,v in pairs(GetDescendants(speaker.Character)) do
			if v.ClassName == "PointLight" then
				if v.Name == pointLightName then
					Destroy(v)
				end
			end
		end
	end
end)

newCmd("restorelighting", {"rlighting"}, "restorelighting / rlighting", "Restores Lighting Properties", function(args, speaker)
	Prote.SpoofProperty(Lighting, "Ambient")
	Prote.SpoofProperty(Lighting, "OutdoorAmbient")
	Prote.SpoofProperty(Lighting, "Brightness")
	Prote.SpoofProperty(Lighting, "ClockTime")
	Prote.SpoofProperty(Lighting, "FogEnd")
	Prote.SpoofProperty(Lighting, "FogStart")
	Prote.SpoofProperty(Lighting, "GlobalShadows")
	Lighting.Ambient = origsettings.Lighting.abt
	Lighting.OutdoorAmbient = origsettings.Lighting.oabt
	Lighting.Brightness = origsettings.Lighting.brt
	Lighting.ClockTime = origsettings.Lighting.time
	Lighting.FogEnd = origsettings.Lighting.fe
	Lighting.FogStart = origsettings.Lighting.fs
	Lighting.GlobalShadows = origsettings.Lighting.gs
end)

newCmd("hitbox", {}, "hitbox [plr] [size]", "Expands the hitbox for a player's HumanoidRootPart (Default is 1)", function(args, speaker)
	local players = getPlayer(args[1], speaker)
	for i,v in pairs(players) do
		if Players[v] ~= speaker and FindFirstChild(Players[v].Character, "HumanoidRootPart") then
			if args[2] and isNumber(args[2]) then
				local sizeArg = tonumber(args[2])
				local Size = Vector3.new(sizeArg, sizeArg, sizeArg)
				local Root = FindFirstChild(Players[v].Character, "HumanoidRootPart")
				if IsA(Root, "BasePart") then
					if not args[2] or sizeArg == 1 then
						Root.Size = Vector3.new(2, 1, 1)
						Root.Transparency = 0.4
					else
						Root.Size = Size
						Root.Transparency = 0.4
					end
				end
			end
		end
	end
end)

newCmd("headsize", {}, "headsize [plr] [size]", "Expands the hitbox for a player's head (Default is 1)", function(args, speaker)
	local players = getPlayer(args[1], speaker)
	for i,v in pairs(players) do
		if Players[v] ~= speaker and FindFirstChild(Players[v].Character, "Head") then
			local sizeArg = tonumber(args[2])
			local Size = Vector3.new(sizeArg, sizeArg, sizeArg)
			local Head = FindFirstChild(Players[v].Character, "Head")
			if IsA(Head, "BasePart") then
				if not args[2] or sizeArg == 1 then
					Prote.ProtectInstance(Head)
					Head.Size = Vector3.new(2, 1, 1)
				else
					Prote.ProtectInstance(Head)
					Head.Size = Size
				end
			end
		end
	end
end)

newCmd("headsit", {"hsit"}, "headsit / hsit [plr]", "Sit on a player's head", function(args, speaker)
	local players = getPlayer(args[1], speaker)
	for i,v in pairs(players) do
		if Players[v] and Players[v].Character and FindFirstChild(Players[v].Character, "Head") and speaker and speaker.Character and findhum() and getRoot() then
			local Root = getRoot()
			local Human = gethum()
			Prote.SpoofProperty(Human, "Sit")
			Human.Sit = true
			headSitting1 = CConnect(GetPropertyChangedSignal(Human, "Sit"), function()
				if Human then Human.Sit = true end
			end)
			headSitting2 = CConnect(Heartbeat, function()
				if Root and Players[v] and Players[v].Character and FindFirstChild(Players[v].Character, "Head") then
					Root.CFrame = Players[v].Character.Head.CFrame * CFrame.new(0, 0, 1)
				end
			end)
		end
	end
end)

newCmd("unheadsit", {"unhsit"}, "unheadsit / unhsit", "Stop sitting on heads bro", function(args, speaker)
	if headSitting1 ~= nil then
		Disconnect(headSitting1)
		headSitting1 = nil
	end
	if headSitting2 ~= nil then
		Disconnect(headSitting2)
		headSitting2 = nil
	end
end)

newCmd("god", {}, "god", "Makes your character difficult to kill in most games", function(args, speaker)
	local Cam = workspace.CurrentCamera
	local Pos, Char = Cam.CFrame, speaker.Character
	local Human = Char and FindFirstChildWhichIsA(Char, "Humanoid")
	local nHuman = Clone(Human)
	nHuman.Parent, speaker.Character = Char, nil
	nHuman.SetStateEnabled(nHuman, 15, false)
	nHuman.SetStateEnabled(nHuman, 1, false)
	nHuman.SetStateEnabled(nHuman, 0, false)
	nHuman.BreakJointsOnDeath, Human = true, Destroy(Human)
	speaker.Character, Cam.CameraSubject, Cam.CFrame = Char, nHuman, wait() and Pos
	nHuman.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
	local Script = FindFirstChild(Char, "Animate")
	if Script then
		SetLocalAnimate(Char, true)
		wait()
		SetLocalAnimate(Char, false)
	end
	nHuman.Health = nHuman.MaxHealth
end)

newCmd("noroot", {}, "noroot", "Removes your Character's RootPart", function(args, speaker)
	if speaker.Character ~= nil then
		local root = getRoot()
		if root then
			local char = Players.LocalPlayer.Character
			char.Parent = nil
			Destroy(root)
			char.Parent = workspace
		end
	end
end)

newCmd("fpsboost", {"boostfps"}, "fpsboost / boostfps", "Lowers Game Quality to Boost FPS", function(args, speaker)
	local Terrain = FindFirstChildOfClass(workspace, "Terrain")
	Prote.SpoofProperty(Terrain, "WaterWaveSize")
	Prote.SpoofProperty(Terrain, "WaterWaveSpeed")
	Prote.SpoofProperty(Terrain, "WaterReflectance")
	Prote.SpoofProperty(Terrain, "WaterTransparency")
	Prote.SpoofProperty(Lighting, "GlobalShadows")
	Prote.SpoofProperty(Lighting, "FogEnd")
	Terrain.WaterWaveSize = 0
	Terrain.WaterWaveSpeed = 0
	Terrain.WaterReflectance = 0
	Terrain.WaterTransparency = 0
	Lighting.GlobalShadows = false
	Lighting.FogEnd = 9e9
	settings().Rendering.QualityLevel = 1
	for i,v in pairs(GetDescendants(game)) do
		if IsA(v, "Part") or IsA(v, "UnionOperation") or IsA(v, "MeshPart") or IsA(v, "CornerWedgePart") or IsA(v, "TrussPart") then
			Prote.SpoofProperty(v, "Material")
			Prote.SpoofProperty(v, "Reflectance")
			v.Material = "Plastic"
			v.Reflectance = 0
		elseif IsA(v, "Decal") then
			Prote.SpoofProperty(v, "Transparency")
			v.Transparency = 1
		elseif IsA(v, "ParticleEmitter") or IsA(v, "Trail") then
			Prote.SpoofProperty(v, "Lifetime")
			v.Lifetime = NumberRange.new(0)
		elseif IsA(v, "Explosion") then
			Prote.SpoofProperty(v, "BlastPressure")
			Prote.SpoofProperty(v, "BlastRadius")
			v.BlastPressure = 1
			v.BlastRadius = 1
		end
	end
	for i,v in pairs(GetDescendants(Lighting)) do
		if IsA(v, "BlurEffect") or IsA(v, "SunRaysEffect") or IsA(v, "ColorCorrectionEffect") or IsA(v, "BloomEffect") or IsA(v, "DepthOfFieldEffect") then
			Prote.SpoofProperty(v, "Enabled")
			v.Enabled = false
		end
	end
	CConnect(workspace.DescendantAdded, function(child)
		coroutine.wrap(function()
			if IsA(child, "ForceField") then
				CWait(Heartbeat)
				Destroy(child)
			elseif IsA(child, "Sparkles") then
				CWait(Heartbeat)
				Destroy(child)
			elseif IsA(child, "Smoke") or IsA(child, "Fire") then
				CWait(Heartbeat)
				Destroy(child)
			end
		end)()
	end)
end)

newCmd("setfpscap", {}, "setfpscap [number]", "Set your FPS Cap", function(args, speaker)
	if setfpscap and type(setfpscap) == "function" then
		local num = args[1] or 1e6
		if num == "none" then
			return setfpscap(1e6)
		elseif num > 0 then
			return setfpscap(num)
		else
			return notify("Invalid Argument", "Please provide a number above 0 or " .. "\"none\"" .. ".")
		end
	else
		return notify("Incompatible Exploit", "Missing setfpscap")
	end
end)

newCmd("tpposition", {"tppos"}, "tpposition / tppos [X] [Y] [Z]", "Teleports you to certain coordinates", function(args, speaker)
	if #args < 3 then return notify("Arguments Required", #args .. " / 3") end
	local Pos = {["X"] = tonumber(args[1]), ["Y"] = tonumber(args[2]), ["Z"] = tonumber(args[3])}
	local char = speaker.Character
	if char and getRoot(char) then
		getRoot(char).CFrame = CFrame.new(Pos.X, Pos.Y, Pos.Z)
	end
end)

newCmd("tweentpposition", {"ttppos"}, "tweentpposition / ttppos [X] [Y] [Z]", "Tween to coordinates (bypasses some anti cheats)", function(args, speaker)
	if #args < 3 then return notify("Arguments Required", #args .. " / 3") end
	local Pos = {["X"] = tonumber(args[1]), ["Y"] = tonumber(args[2]), ["Z"] = tonumber(args[3])}
	local char = speaker.Character
	if char and getRoot(char) then
		local Tween = TweenService.Create(TweenService, getRoot(speaker.Character), TweenInfo.new(tweenSpeed, Enum.EasingStyle.Linear), {CFrame = CFrame.new(Pos.X, Pos.Y, Pos.Z)})
		Tween.Play(Tween)
	end
end)

newCmd("chat", {"say"}, "chat / say [text]", "Makes you chat a string (possible mute bypass)", function(args, speaker)
	local cString = getstring(1)
	local SayMessageRequest = ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest
	SayMessageRequest.FireServer(SayMessageRequest, cString, "All")
end)

newCmd("silentchat", {"schat"}, "silentchat / schat [text]", "Makes you chat a string that won't show in chat", function(args, speaker)
	local cString = getstring(1)
	Players.Chat(Players, cString)
end)

newCmd("whisper", {"pm"}, "whisper / pm [plr] [text]", "Makes you whisper a string to someone (possible mute bypass)", function(args, speaker)
	local players = getPlayer(args[1], speaker)
	for i,v in pairs(players) do
		spawn(function()
			local plrName = Players[v].Name
			local pmstring = getstring(2)
			local SayMessageRequest = ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest
			SayMessageRequest.FireServer(SayMessageRequest, "/w " .. plrName .. " " .. pmstring, "All")
		end)
	end
end)

newCmd("noclipcam", {"nccam"}, "noclipcam / nccam", "Allows your Camera to go Through Objects like Walls", function(args, speaker)
	local sc = (debug and debug.setconstant) or setconstant
	local gc = (debug and debug.getconstants) or getconstants
	if not sc or not getgc or not gc then return notify("Incompatible Exploit", "Missing setconstant or getconstants or getgc") end
	local pop = speaker.PlayerScripts.PlayerModule.CameraModule.ZoomController.Popper
	for _, v in pairs(getgc()) do
		if type(v) == "function" and getfenv(v).script == pop then
			for i, v1 in pairs(gc(v)) do
				if tonumber(v1) == 0.25 then
					sc(v, i, 0)
				elseif tonumber(v1) == 0 then
					sc(v, i, 0.25)
				end
			end
		end
	end
end)

newCmd("maxzoom", {}, "maxzoom [number]", "Maximum Camera Zoom", function(args, speaker)
	Prote.SpoofProperty(speaker, "CameraMaxZoomDistance")
	speaker.CameraMaxZoomDistance = args[1]
end)

newCmd("minzoom", {}, "minzoom [number]", "Minimum Camera Zoom", function(args, speaker)
	Prote.SpoofProperty(speaker, "CameraMinZoomDistance")
	speaker.CameraMinZoomDistance = args[1]
end)

newCmd("tpunanchored", {"tpua"}, "tpunanchored / tpua [plr]", "Teleports Unanchored Parts to a Player", function(args, speaker)
	if sethidden then
		local players = getPlayer(args[1], speaker)
		for i,v in pairs(players) do
			local Forces = {}
			for _, part in pairs(GetDescendants(workspace)) do
				if FindFirstChild(Players[v].Character, "Head") and IsA(part, "BasePart" or "UnionOperation" or "Model") and part.Anchored == false and not part.IsDescendantOf(part, speaker.Character) and part.Name == "Torso" == false and part.Name == "Head" == false and part.Name == "Right Arm" == false and part.Name == "Left Arm" == false and part.Name == "Right Leg" == false and part.Name == "Left Leg" == false and part.Name == "HumanoidRootPart" == false then
					for i,c in pairs(GetChildren(part)) do
						if IsA(c, "BodyPosition") or IsA(c, "BodyGyro") then
							Destroy(c)
						end
					end
					local ForceInstance = InstanceNew("BodyPosition")
					Prote.ProtectInstance(ForceInstance)
					ForceInstance.Parent = part
					ForceInstance.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
					table.insert(Forces, ForceInstance)
					if not table.find(frozenParts, part) then
						table.insert(frozenParts, part)
					end
				end
			end
			SetSimulationRadius()
			for i,c in pairs(Forces) do
				c.Position = Players[v].Character.Head.Position
			end
		end
	else
		notify("Incompatible Exploit", "Missing sethiddenproperty")
	end
end)

newCmd("freezeunanchored", {"freezeua"}, "freezeunanchored / freezeua", "Freezes Unanchored Parts", function(args, speaker)
	if sethidden then
		local badnames = {"Head", "UpperTorso", "LowerTorso", "RightUpperArm", "LeftUpperArm", "RightLowerArm", "LeftLowerArm", "RightHand", "LeftHand", "RightUpperLeg", "LeftUpperLeg", "RightLowerLeg", "LeftLowerLeg", "RightFoot", "LeftFoot", "Torso", "Right Arm", "Left Arm", "Right Leg", "Left Leg", "HumanoidRootPart"}
		local FreezeObject = function(v)
			if IsA(v, "BasePart" or "UnionOperation") and v.Anchored == false then
				local BADD = false
				for i = 1,#badnames do
					if v.Name == badnames[i] then
						BADD = true
					end
				end
				if speaker.Character and v.IsDescendantOf(v, speaker.Character) then
					BADD = true
				end
				if not BADD then
					for i,c in pairs(GetChildren(v)) do
						if IsA(c, "BodyPosition") or IsA(c, "BodyGyro") then
							Destroy(c)
						end
					end
					SetSimulationRadius()
					local bodypos = InstanceNew("BodyPosition")
					Prote.ProtectInstance(bodypos)
					bodypos.Parent = v
					bodypos.Position = v.Position
					bodypos.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
					local bodygyro = InstanceNew("BodyGyro")
					Prote.ProtectInstance(bodygyro)
					bodygyro.Parent = v
					bodygyro.CFrame = v.CFrame
					bodygyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
					if not table.find(frozenParts, v) then
						table.insert(frozenParts, v)
					end
				end
			end
		end
		for i,v in pairs(GetDescendants(workspace)) do FreezeObject(v) end
		FreezingUnanchored = CConnect(workspace.DescendantAdded, FreezeObject)
	else
		notify("Incompatible Exploit", "Missing sethiddenproperty")
	end
end)

newCmd("thawunanchored", {"thawua", "unfreezeua"}, "thawunanchored / thawua / unfreezeua", "Thaws Unanchored Parts", function(args, speaker)
	if sethidden then
		if FreezingUnanchored ~= nil then
			Disconnect(FreezingUnanchored)
			FreezingUnanchored = nil
		end
		SetSimulationRadius()
		for i,v in pairs(frozenParts) do
			for i,c in pairs(GetChildren(v)) do
				if IsA(c, "BodyPosition") or IsA(c, "BodyGyro") then
					Destroy(c)
				end
			end
		end
		frozenParts = {}
	else
		notify("Incompatible Exploit", "Missing sethiddenproperty")
	end
end)

newCmd("flashlight", {}, "flashlight (Client)", "Give yourself a Flashlight", function(args, speaker)
	loadstring(game.HttpGetAsync(game, "https://pastebin.com/raw/8K2cTfka"))();
end)

newCmd("metahook", {}, "metahook [name] [value]", "Hook an Argument with a Value", function(args, speaker)
	if args[1] and args[2] then
		local getrawmt = (debug and debug.getmetatable) or getrawmetatable
		local setReadOnly = setreadonly or (make_writeable and function(table, readonly) if readonly then make_readonly(table) else make_writeable(table) end end)
		local GameMt = getrawmt(game)
		local OldIndex = GameMt.__index
		setReadOnly(GameMt, false)
		GameMt.__index = newcclosure(function(Self, Key)
			if string.lower(tostring(Key)) == string.lower(tostring(args[1])) then
				return getstring(2)
			end
			return OldIndex(Self, Key)
		end)
		setReadOnly(GameMt, true)
	else
		notify("Meta Hook", "Missing a Argument")
	end
end)

newCmd("cancelteleport", {"canceltp"}, "cancelteleport / canceltp", "Cancels Teleports in Progress", function(args, speaker)
	TeleportService.TeleportCancel(TeleportService)
end)

newCmd("copyemote", {}, "copyemote [plr]", "Copies a Player's Animation", function(args, speaker)
	local players = getPlayer(args[1], speaker)
	for _,v in ipairs(players)do
		local char = Players[v].Character
		local Human = FindFirstChildOfClass(speaker.Character, "Humanoid")
		for _, v1 in pairs(Human.GetPlayingAnimationTracks(Human)) do
			v1.Stop(v1)
		end
		local Human = FindFirstChildOfClass(Players[v].Character, "Humanoid")
		for _, v1 in pairs(Human.GetPlayingAnimationTracks(Human)) do
			if not string.find(v1.Animation.AnimationId, "507768375") then
				local PlayerAnimation = Human.LoadAnimation(Human, v1.Animation)
				PlayerAnimation.Play(PlayerAnimation, .1, 1, v1.Speed)
				PlayerAnimation.TimePosition = v1.TimePosition
				spawn(function()
					CWait(v1.Stopped)
					PlayerAnimation.Stop(PlayerAnimation)
					Destroy(PlayerAnimation)
				end)
			end
		end
	end
end)

newCmd("clickteleport", {"teleporttool", "clicktp", "tptool"}, "clickteleport / clicktp / teleporttool / tptool", "Gives You a Teleport Tool", function(args, speaker)
	if findbp() then
		local Backpack = getbp()
		local TpTool = InstanceNew("Tool")
		TpTool.Name = "Teleport Tool"
		TpTool.RequiresHandle = false
		TpTool.Parent = Backpack
		CConnect(TpTool.Activated, function()
			local Char = speaker.Character or FindFirstChild(workspace, speaker.Name)
			local Root = Char and FindFirstChild(Char, "HumanoidRootPart")
			if not Char or not Root then
				return notify("Error", "Failed to Find HumanoidRootPart")
			end
			local Hit = DAMouse.Hit
			Root.CFrame = Hit * CFrame.new(0, 3, 0)
		end)
		local TpToolTween = InstanceNew("Tool")
		TpToolTween.Name = "Teleport Tool (Tween)"
		TpToolTween.RequiresHandle = false
		TpToolTween.Parent = Backpack
		CConnect(TpToolTween.Activated, function()
			local Char = speaker.Character or FindFirstChild(workspace, speaker.Name)
			local Root = Char and FindFirstChild(Char, "HumanoidRootPart")
			if not Char or not Root then
				return notify("Error", "Failed to Find HumanoidRootPart")
			end
			local Hit = DAMouse.Hit
			local TweeningInfo = TweenInfo.new(0.5, Enum.EasingStyle["Sine"], Enum.EasingDirection["Out"])
			local TweenFunc = TweenService.Create(TweenService, Root, TweeningInfo, {CFrame = Hit * CFrame.new(0, 3, 0)})
			TweenFunc.Play(TweenFunc)
		end)
	else
		notify("Command Error", "Missing Backpack")
	end
end)

newCmd("walltp", {}, "walltp", "Teleports You Above/Over Any Wall You Run Into", function(args, speaker)
	local Torso = nil
	if r15(speaker) then
		Torso = speaker.Character.UpperTorso
	else
		Torso = speaker.Character.Torso
	end
	local TouchedFunc = function(hit)
		local Root = getRoot(speaker.Character)
		if IsA(hit, "BasePart") and hit.Position.Y > Root.Position.Y - FindFirstChildOfClass(speaker.Character, "Humanoid").HipHeight then
			local HitP = getRoot(hit.Parent)
			if HitP ~= nil then
				Root.CFrame = hit.CFrame * CFrame.new(Root.CFrame.lookVector.X,HitP.Size.Z/2 + FindFirstChildOfClass(speaker.Character, "Humanoid").HipHeight, Root.CFrame.lookVector.Z)
			elseif not HitP then
				Root.CFrame = hit.CFrame * CFrame.new(Root.CFrame.lookVector.X,hit.Size.Y/2 + FindFirstChildOfClass(speaker.Character, "Humanoid").HipHeight, Root.CFrame.lookVector.Z)
			end
		end
	end
	WallTpTouch = CConnect(Torso.Touched, TouchedFunc)
end)

newCmd("unwalltp", {}, "unwalltp", "Disables Walltp", function(args, speaker)
	if WallTpTouch ~= nil then
		Disconnect(WallTpTouch)
		WallTpTouch = nil
	end
end)

newCmd("bang", {}, "bang [plr] [speed]", "I don't want to explain this", function(args, speaker)
	if not r15(speaker) then
		execCmd("unbang")
		wait()
		local players = getPlayer(args[1], speaker)
		for i,v in pairs(players) do
			bangAnim = InstanceNew("Animation")
			Prote.ProtectInstance(bangAnim)
			bangAnim.AnimationId = "rbxassetid://148840371"
			local selfhum = FindFirstChildWhichIsA(speaker.Character, "Humanoid")
			bang = selfhum.LoadAnimation(selfhum, bangAnim)
			bang.Play(bang, 0.1, 1, 1)
			if args[2] then
				bang.AdjustSpeed(bang, args[2])
			else
				bang.AdjustSpeed(bang, 3)
			end
			local bangplr = Players[v].Name
			bangDied = CConnect(selfhum.Died, function()
				Disconnect(bangLoop)
				bang.Stop(bang)
				Destroy(bangAnim)
				Disconnect(bangDied)
			end)
			local bangOffet = CFrame.new(0, 0, 1.1)
			bangLoop = CConnect(Stepped, function()
				pcall(function()
					local otherRoot = getRoot(Players[bangplr].Character)
					getRoot(Players.LocalPlayer.Character).CFrame = otherRoot.CFrame * bangOffet
				end)
			end)
		end
	else
		notify("R6 Required", "Requires R6 Rig Type")
	end
end)

newCmd("unbang", {}, "unbang", "Humanity Restored", function(args, speaker)
	if bangLoop then
		Disconnect(bangLoop)
		Disconnect(bangDied)
		bang.Stop(bang)
		Destroy(bangAnim)
	end
end)

newCmd("carpet", {}, "carpet [plr]", "Become a Player's Carpet", function(args, speaker)
	if not r15(speaker) then
		execCmd("uncarpet")
		wait()
		local players = getPlayer(args[1], speaker)
		for i,v in pairs(players) do
			local Human = FindFirstChildWhichIsA(speaker.Character, "Humanoid")
			carpetAnim = InstanceNew("Animation")
			Prote.ProtectInstance(carpetAnim)
			carpetAnim.AnimationId = "rbxassetid://282574440"
			carpet = Human.LoadAnimation(Human, carpetAnim)
			carpet.Play(carpet, .1, 1, 1)
			local carpetplr = Players[v].Name
			carpetDied = CConnect(Human.Died, function()
				Disconnect(carpetLoop)
				carpet.Stop(carpet)
				Destroy(carpetAnim)
				Disconnect(carpetDied)
			end)
			carpetLoop = CConnect(Heartbeat, function()
				pcall(function()
					getRoot(Players.LocalPlayer.Character).CFrame = getRoot(Players[carpetplr].Character).CFrame
				end)
			end)
		end
	else
		notify("R6 Required", "Requires R6 Rig Type")
	end
end)

newCmd("uncarpet", {}, "uncarpet", "Undoes Carpet", function(args, speaker)
	if carpetLoop then
		Disconnect(carpetLoop)
		carpet.Stop(carpet)
		Destroy(carpetAnim)
		Disconnect(carpetDied)
	end
end)

newCmd("walkto", {"follow"}, "walkto / follow [plr]", "Follow a Player", function(args, speaker)
	local players = getPlayer(args[1], speaker)
	for i,v in pairs(players) do
		if Players[v].Character ~= nil then
			local Human = FindFirstChildOfClass(speaker.Character, "Humanoid")
			if Human and Human.SeatPart then
				Human.Sit = false
				wait(0.1)
			end
			walkto = true
			repeat wait()
				Human.MoveTo(Human, getRoot(Players[v].Character).Position)
			until not Players[v].Character or not getRoot(Players[v].Character) or not walkto 
		end
	end
end)

newCmd("pathfindwalkto", {"pathfindfollow"}, "pathfindwalkto / pathfindfollow [plr]", "Follow a Player Using Pathfinding", function(args, speaker)
	walkto = false
	wait()
	local players = getPlayer(args[1], speaker)
	local PathService = GetService(game, "PathfindingService")
	local hum = FindFirstChildOfClass(speaker.Character, "Humanoid")
	local path = PathService.CreatePath(PathService)
	for i,v in pairs(players) do
		if Players[v].Character ~= nil then
			if hum and hum.SeatPart then
				hum.Sit = false
				wait(0.1)
			end
			walkto = true
			repeat wait()
				local success, response = pcall(function()
					path.ComputeAsync(path, getRoot(speaker.Character).Position, getRoot(Players[v].Character).Position)
					local waypoints = path.GetWaypoints(path)
					local distance 
					for waypointIndex, waypoint in pairs(waypoints) do
						local waypointPosition = waypoint.Position
						hum.MoveTo(hum, waypointPosition)
						repeat
							distance = (waypointPosition - hum.Parent.PrimaryPart.Position).magnitude
							wait()
						until
						distance <= 5
					end	 
				end)
				if not success then
					hum.MoveTo(hum, getRoot(Players[v].Character).Position)
				end
			until not Players[v].Character or not getRoot(Players[v].Character) or not walkto 
		end
	end
end)

newCmd("unwalkto", {"unfollow"}, "unwalkto / unfollow", "Follow a Player Using Pathfinding", function(args, speaker)
	walkto = false
end)

newCmd("stare", {}, "stare [plr]", "Stare at a Player", function(args, speaker)
	local players = getPlayer(args[1], speaker)
	for i,v in pairs(players) do
		if StareLoop ~= nil then
			Disconnect(StareLoop)
			StareLoop = nil
		end
		if not FindFirstChild(Players.LocalPlayer.Character, "HumanoidRootPart") and FindFirstChild(Players[v].Character, "HumanoidRootPart") then return end
		local StareFunc = function()
			if Players.LocalPlayer.Character.PrimaryPart and FindFirstChild(Players, v) and Players[v].Character ~= nil and FindFirstChild(Players[v].Character, "HumanoidRootPart") then
				local chrPos = Players.LocalPlayer.Character.PrimaryPart.Position
				local tPos = FindFirstChild(Players[v].Character, "HumanoidRootPart").Position
				local modTPos = Vector3.new(tPos.X, chrPos.Y, tPos.Z)
				local newCF = CFrame.new(chrPos, modTPos)
				Players.LocalPlayer.Character.SetPrimaryPartCFrame(Players.LocalPlayer.Character, newCF)
			elseif not FindFirstChild(Players, v) then
				Disconnect(StareLoop)
			end
		end
		StareLoop = CConnect(RenderStepped, StareFunc)
	end
end)

newCmd("unstare", {}, "unstare [plr]", "Disables Stare", function(args, speaker)
	if StareLoop ~= nil then
		Disconnect(StareLoop)
		StareLoop = nil
	end
end)

newCmd("replicationlag", {"backtrack"}, "replicationlag / backtrack [num]", "Set IncomingReplicationLag (Default is 0)", function(args, speaker)
	local UserSettings = settings()
	UserSettings.GetService(UserSettings, "NetworkSettings").IncomingReplicationLag = tonumber(args[1]) or 0
end)

newCmd("nameprotect", {}, "nameprotect", "Spoof your username locally by Setting it to \"User\"", function(args, speaker)
	Import("nameprot.lua")
	notify("", "Name Protected")
end)

newCmd("ping", {}, "ping", "Notify yourself your Ping", function(args, speaker)
	local Data_Ping = GetService(game, "Stats").Network.ServerStatsItem["Data Ping"]
	local Current_Ping = string.split(Data_Ping.GetValueString(Data_Ping), " ")[1] .. "ms"
	notify("Ping", tostring(Current_Ping))
end)

newCmd("fps", {"frames"}, "fps / frames", "Notify yourself your Framerate", function(args, speaker)
	local x = 0	
	local a = tick()
	local fpsget = function()
		x = (1 / (tick() - a))
		a = tick()
		return string.format("%.3f", x)
	end
	local fps = nil
	local v = CConnect(Stepped, function() fps = fpsget() end)
	wait(0.2)
	Disconnect(v)
	notify("FPS", "Current FPS is " .. tostring(fps))
end)

newCmd("clearhats", {}, "clearhats", "Clears Hats in the Workspace", function(args, speaker)
	if firetouchinterest then
		local Player = Players.LocalPlayer
		local Character = Player.Character
		local Old = FindFirstChild(Character, "HumanoidRootPart").CFrame
		local Hats = {}
		for _, x in next, GetChildren(workspace) do
			if IsA(x, "Accessory") then
				table.insert(Hats, x)
			end
		end
		local Human = FindFirstChildWhichIsA(Character, "Humanoid")
		for _, getacc in next, Human.GetAccessories(Human) do
			Destroy(getacc)
		end
		for i = 1,#Hats do
			repeat CWait(Heartbeat) until Hats[i]
			firetouchinterest(Hats[i].Handle, FindFirstChild(Character, "HumanoidRootPart"), 0)
			repeat CWait(Heartbeat) until FindFirstChildOfClass(Character, "Accessory")
			Destroy(FindFirstChildOfClass(Character, "Accessory"))
			repeat CWait(Heartbeat) until not FindFirstChildOfClass(Character, "Accessory")
		end
		Character.BreakJoints(Character)
		CWait(Player.CharacterAdded)
		for i = 1,20 do CWait(Heartbeat)
			if FindFirstChild(Player.Character, "HumanoidRootPart") then
				FindFirstChild(Player.Character, "HumanoidRootPart").CFrame = Old
			end
		end
	else
		notify("Incompatible Exploit", "Missing firetouchinterest")
	end
end)

newCmd("removehats", {"nohats"}, "removehats / nohats", "Remove your hats", function(args, speaker)
	if not FindFirstChildWhichIsA(speaker, "Humanoid") then return notify("Remove Hats", "Missing Humanoid") end
	local Human = FindFirstChildWhichIsA(speaker, "Humanoid")
	for i, v in next, Human.GetAccessories(Human) do
        Destroy(v)
    end
end)

newCmd("hatspin", {}, "hatspin", "Spins your Character's Accessories", function(args, speaker)
	execCmd("unhatspin")
	wait(0.5)
	local Human = FindFirstChildOfClass(speaker.Character, "Humanoid")
	for _,v in pairs(Human.GetAccessories(Human)) do
		local keep = InstanceNew("BodyPosition")
		Prote.ProtectInstance(keep)
		keep.Parent = v.Handle
		keep.Name = randomString()
		local spin = InstanceNew("BodyAngularVelocity")
		Prote.ProtectInstance(spin)
		spin.Parent = v.Handle
		spin.Name = randomString()
		spin.Parent = v.Handle
		Destroy(FindFirstChildOfClass(v.Handle, "Weld"))
		if args[1] then
			spin.AngularVelocity = Vector3.new(0, args[1], 0)
			spin.MaxTorque = Vector3.new(0, args[1] * 2, 0)
		else
			spin.AngularVelocity = Vector3.new(0, 100, 0)
			spin.MaxTorque = Vector3.new(0, 200, 0)
		end
		keep.P = 30000
		keep.D = 50
		spinhats = CConnect(Stepped, function()
			pcall(function()
				keep.Position = Players.LocalPlayer.Character.Head.Position
			end)
		end)
	end
end)

newCmd("unhatspin", {}, "unhatspin", "Disables Hatspin", function(args, speaker)
	if spinhats ~= nil then
		Disconnect(spinhats)
		spinhats = nil
	end
	local Human = FindFirstChildWhichIsA(speaker.Character, "Humanoid")
	for _, v in pairs(Human.GetAccessories(Human)) do
		v.Parent = workspace
		for i,c in pairs(v.Handle) do
			if IsA(c, "BodyPosition") or IsA(c, "BodyAngularVelocity") then
				Destroy(c)
			end
		end
		wait()
		v.Parent = speaker.Character
	end
end)

newCmd("fixgyros", {}, "fixgyros", "Fix Body Gyros", function(args, speaker)
	if setscriptable then
		local prep = function(plr)
			if plr and plr.Character then
				for _, char in pairs(GetChildren(plr.Character)) do
					CConnect(RenderStepped, function()
						pcall(function()
							if IsA(char, "Part") or IsA(char, "BasePart") then
								Prote.SpoofProperty(char, "Velocity")
								char.Velocity = Vector3.new(30, 0, 4)
							end
						end)
					end)
				end
			end
		end
		CConnect(Heartbeat, function()
			pcall(function()
				setscriptable(Players.LocalPlayer, "SimulationRadius", true)
			end)
			if Players.LocalPlayer and Players.LocalPlayer.Character then
				for _, char in pairs(GetChildren(Players.LocalPlayer.Character)) do
					CConnect(RenderStepped, function()
						pcall(function()
							if IsA(char, "Part") or IsA(char, "BasePart") then
								Prote.SpoofProperty(char, "Velocity")
								char.Velocity = Vector3.new(30, 4, 0)
							end
						end)
					end)
				end
			end
		end)
		for i,v in pairs(GetPlayers(Players)) do
			if v ~= Players.LocalPlayer then
				prep(v)
			end
		end
		notify("Gyros", "Fixed")
	else
		for i,v in next, GetDescendants(Players.LocalPlayer.Character) do
			if IsA(v, "BasePart") and v.Name ~= "HumanoidRootPart" then 
				CConnect(Heartbeat, function()
					v.Velocity = Vector3.new(0, 35, 0)
					wait(0.5)
				end)
			end
		end
		notify("Gyros", "Fixed")
	end
end)

newCmd("enable", {}, "enable [inventory/playerlist/chat/all]", "Toggles Visibility of CoreGui Items", function(args, speaker)
	if args[1] then
		local opt = string.lower(tostring(args[1]))
		if opt == "inventory" or opt == "backpack" then
			StarterGui.SetCoreGuiEnabled(StarterGui, "Backpack", true)
		elseif opt == "playerlist" then
			StarterGui.SetCoreGuiEnabled(StarterGui, "PlayerList", true)
		elseif opt == "chat" then
			StarterGui.SetCoreGuiEnabled(StarterGui, "Chat", true)
		elseif opt == "all" then
			StarterGui.SetCoreGuiEnabled(StarterGui, Enum.CoreGuiType.All, true)
		end
	end
end)

newCmd("disable", {}, "disable [inventory/playerlist/chat/all]", "Toggles Visibility of CoreGui Items", function(args, speaker)
	if args[1] then
		local opt = string.lower(tostring(args[1]))
		if opt == "inventory" or opt == "backpack" then
			StarterGui.SetCoreGuiEnabled(StarterGui, "Backpack", false)
		elseif opt == "playerlist" then
			StarterGui.SetCoreGuiEnabled(StarterGui, "PlayerList", false)
		elseif opt == "chat" then
			StarterGui.SetCoreGuiEnabled(StarterGui, "Chat", false)
		elseif opt == "all" then
			StarterGui.SetCoreGuiEnabled(StarterGui, Enum.CoreGuiType.All, false)
		end
	end
end)

newCmd("fixbubblechat", {}, "fixbubblechat", "Fix the Bubblechat Being Cut Off", function(args, speaker)
	if BubbleChatFix ~= nil then
		return notify("Bubble Chat", "Already Fixed")
	end
	local PlayerGui = FindFirstChildOfClass(Players.LocalPlayer, "PlayerGui")
	if PlayerGui and FindFirstChild(PlayerGui, "BubbleChat") then
		BubbleChatFix = CConnect(PlayerGui.BubbleChat.DescendantAdded, function(message)
			if IsA(message, "TextLabel") and message.Name == "BubbleText" then
				message.TextSize = 21
			end
		end)
	end
	notify("Bubble Chat", "Fixed")
end)

newCmd("unfixbubblechat", {}, "unfixbubblechat", "Disable Fixbubblechat", function(args, speaker)
	if BubbleChatFix ~= nil then
		Disconnect(BubbleChatFix)
		BubbleChatFix = nil
		notify("Bubble Chat", "Reverted Fix")
	end
end)

newCmd("reanimate", {"reanim"}, "reanimate / reanim", "Reanimate your Character to make some Net Scripts Netless", function(args, speaker)
	notify("Selexity", "Hold on a sec")
	wait(0.2)
	Import("anim.lua")
end)

newCmd("classicchat", {"clchat"}, "classicchat / clchat", "Enable Roblox's Classic Chat", function(args, speaker)
	local PlayerGui = FindFirstChildOfClass(Players.LocalPlayer, "PlayerGui")
	WaitForChild(PlayerGui, "Chat")
	if PlayerGui.Chat.Frame.ChatChannelParentFrame.Visible ~= true then
		PlayerGui.Chat.Frame.ChatBarParentFrame.Position = PlayerGui.Chat.Frame.ChatChannelParentFrame.Position + UDim2.new(UDim.new(0,0), PlayerGui.Chat.Frame.ChatChannelParentFrame.Size.Y)
		PlayerGui.Chat.Frame.ChatChannelParentFrame.Visible = true
		PlayerGui.Chat.Frame.ChatChannelParentFrame.Size = UDim2.new(1, 0, 1, -46)	
	end
end)

newCmd("clientsidebypass", {"clbypass"}, "clientsidebypass / clbypass", "Bypass Certain Anticheats", function(args, speaker)
	ClientByp = CConnect(Players.LocalPlayer.CharacterAdded, function()
		repeat wait() until Players.LocalPlayer and Players.LocalPlayer.Character and findhum()
		wait(0.4)
		Prote.SpoofInstance(gethum())
		if r15(Players.LocalPlayer) then
			Prote.SpoofInstance(getRoot(Players.LocalPlayer.Character), Players.LocalPlayer.Character.UpperTorso)
		else
			Prote.SpoofInstance(getRoot(Players.LocalPlayer.Character), Players.LocalPlayer.Character.Torso)
		end
		Prote.ProtectInstance(getRoot(Players.LocalPlayer.Character))
		Prote.ProtectInstance(gethum())
	end)
	clientsidebypass = true
	Players.LocalPlayer.Character.BreakJoints(Players.LocalPlayer.Character)
	notify("Client Bypass", "Enabled")
end)

newCmd("unclientsidebypass", {"unclbypass"}, "unclientsidebypass / unclbypass", "Disable the Client-Sided Bypass", function(args, speaker)
	Disconnect(ClientByp)
	wait()
	ClientByp = nil
	clientsidebypass = false
	Players.LocalPlayer.Character.BreakJoints(Players.LocalPlayer.Character)
	notify("Client Bypass", "Disabled")
end)

newCmd("joinplayer", {"jplr"}, "joinplayer / jplr [user / id] [place id]", "Join a Specific Player's Server", function(args, speaker)
	if not args[1] then return notify("Join Player", "Missing Argument") end
	local retries = 0
	local JoinServer
	JoinServer = function(User, PlaceId)
		if not args[2] then PlaceId = game.PlaceId end
		if not pcall(function()
				local FoundUser, UserId = pcall(function()
					if tonumber(User) then
						return tonumber(User)
					end

					return Players.GetUserIdFromNameAsync(Players, User)
				end)
				if not FoundUser then
					notify("Join Error", "Username / UserID does not exist")
				else
					notify("Join Player", "Loading servers. Hold on a second.")
					local URL2 = ("https://games.roblox.com/v1/games/" .. PlaceId .. "/servers/Public?sortOrder=Asc&limit=100")
					local Http = JSONDecode(HttpService, game.HttpGet(game, URL2))
					local GUID

					tablelength = function(T)
						local count = 0
						for _ in pairs(T) do count = count + 1 end
						return count
					end

					for i = 1, tonumber(tablelength(Http.data)) do
						for j,k in pairs(Http.data[i].playerIds) do
							if k == UserId then
								GUID = Http.data[i].id
							end
						end
					end

					if GUID ~= nil then
						notify("Join Player", "Joining " .. User)
						TeleportService.TeleportToPlaceInstance(TeleportService, PlaceId, GUID, Players.LocalPlayer)
					else
						notify("Join Error", "Unable to join user.")
					end
				end
			end)
		then
			if retries < 3 then
				retries = retries + 1
				notify("Join Error", "Error while trying to join. Retrying " .. retries .. "/3")
				JoinServer(User, PlaceId)
			else
				notify("Join Error", "Error While Joining")
			end
		end
	end
	JoinServer(args[1], args[2])
end)

newCmd("changeteam", {"team"}, "changeteam / team [name]", "Change your Team (Game must have a Touchable SpawnLocation for Team)", function(args, speaker)
	local TeamString = tostring(args[1])
	local Team = FindFirstChild(GetService(game, "Teams"), TeamString)
	if not Team then return notify("Team Error", "Team " .. '"' .. TeamString .. '"' .. " does not Exist") end
	local TouchedPart = {}
	local firetouch = firetouchinterest or function(part1, part2, toggle)
		if part1 and part2 then
			if toggle == 0 then
				TouchedPart[1] = part1.CFrame
				part1.CFrame = part2.CFrame
			else
				part1.CFrame = TouchedPart[1]
				TouchedPart[1] = nil
			end
		end
	end
    for i,v in next, GetDescendants(workspace) do
    	if (IsA(v, "SpawnLocation")) and (v.BrickColor == Team.TeamColor) then
    		local RootPart = getRoot(Players.LocalPlayer.Character)
    		if RootPart then
    			firetouch(v, RootPart, 0)
    			firetouch(v, RootPart, 1)
    			break
    		end
    	end
    end
    wait(0.1)
    if Players.LocalPlayer.Team == Team then
    	notify("Team Changed", "Changed Team to " .. tostring(Team.Name))
    else
    	notify("Team Error", "Couldn't Change Team to " .. tostring(Team.Name))
    end
end)

newCmd("noclickdetectorlimits", {"nocdlimits"}, "noclickdetectorlimits / nocdlimits", "Sets all click detectors MaxActivationDistance to math.huge", function(args, speaker)
	for i,v in pairs(GetDescendants(workspace)) do
		if IsA(v, "ClickDetector") then
			v.MaxActivationDistance = math.huge
		end
	end
end)

newCmd("fireclickdetectors", {"firecd"}, "fireclickdetectors / firecd", "Uses all click detectors in a game", function(args, speaker)
	if fireclickdetector then
		for i,v in pairs(GetDescendants(workspace)) do
			if IsA(v, "ClickDetector") then
				fireclickdetector(v)
			end
		end
	else
		notify("Incompatible Exploit", "Missing fireclickdetector")
	end
end)

newCmd("firetouchinterests", {"touchinterests"}, "firetouchinterests / touchinterests", "Uses all touchinterests in a game", function(args, speaker)
	local Root = getRoot(speaker.Character) or FindFirstChildWhichIsA(speaker.Character, "BasePart")
	local Touch = function(x)
		x = x.FindFirstAncestorWhichIsA(x, "Part")
		if x then
			if firetouchinterest then
				return spawn(function()
					firetouchinterest(x, Root, 1, wait() and firetouchinterest(x, Root, 0))
				end)
			end
			x.CFrame = Root.CFrame
		end
	end
	for _, v in ipairs(GetDescendants(workspace)) do
		if IsA(v, "TouchTransmitter") then
			Touch(v)
		end
	end
end)

newCmd("fireproximityprompts", {"firepp"}, "fireproximityprompts / firepp", "Uses all proximity prompts in a game", function(args, speaker)
	if fireproximityprompt then
		for i,v in pairs(GetDescendants(workspace)) do
			if IsA(v, "ProximityPrompt") then
				fireproximityprompt(v)
			end
		end
	else
		notify("Incompatible Exploit", "Missing fireproximityprompt")
	end
end)

newCmd("hidename", {"hidebill"}, "hidename / hidebill", "Hide Billboard Nametag", function(args, speaker)
	local character = Players.LocalPlayer.Character
	local bill = FindFirstChildWhichIsA(character, "BillboardGui", true)
	if not bill then return notify("Hide Name", "No Player Tag Found") end
	for i,v in next, GetDescendants(character) do
		if IsA(v, "BillboardGui") then
			Destroy(v)
		end
	end
	notify("Hide Name", "Player Tag Hidden")
end)

newCmd("keybind", {"bind"}, "keybind / bind [key] [cmd]", "Bind a Command to a Key", function(args, speaker)
	if #args < 2 then return notify("Keybinds", "Missing Argument") end
	local command = getstring(2)
	local key = string.lower(tostring(args[1]))
	if #key < 2 then
		local id = #DA_Binds + 1
		DA_Binds[id] = {["CMD"] = command, ["KEY"] = key}
		notify("Keybinds", "Successfully Added Keybind")
	elseif #key > 2 then return notify("Keybinds", "Key cannot be longer than 2 characters.") end
end)

newCmd("unkeybind", {"unbind"}, "unkeybind / unbind [key]", "Remove a Bind for a Command", function(args, speaker)
	if #args < 1 then return notify("Keybinds", "Missing Argument") end
	local key = string.lower(tostring(args[1]))
	for i = 1, #DA_Binds do
		if DA_Binds[i].KEY == key then
			table.remove(DA_Binds, i)
			notify("Keybinds", "Removed Keybind")
		end
	end
end)

newCmd("clearkeybinds", {"clearbinds", "ckeybinds", "cbinds"}, "clearkeybinds / clearbinds / ckeybinds / cbinds", "Remove all Current Binds", function(args, speaker)
	for key in pairs(DA_Binds) do
		DA_Binds[key] = nil
	end
	notify("Keybinds", "Removed all Keybinds")
end)

newCmd("laydown", {"lay"}, "laydown / lay", "Makes your character lay down", function(args, speaker)
	local Human = speaker.Character and FindFirstChildWhichIsA(speaker.Character, "Humanoid")
	if not Human then return end
	Prote.SpoofProperty(Human, "Sit")
	Human.Sit = true
	wait(0.1)
	Human.RootPart.CFrame = Human.RootPart.CFrame * CFrame.Angles(math.pi * 0.5, 0, 0)
	for _, v in ipairs(Human.GetPlayingAnimationTracks(Human)) do
		v.Stop(v)
	end
end)

newCmd("execute", {"exec", "run"}, "execute / exec / run [file name]", "Execute a .txt or .lua file from the Scripts folder in the DA folder", function(args, speaker)
	if not args[1] then return notify("Script Error", "No Arguments Found") end
	local fileName = tostring(getstring(1))
	local newFile
	local newFileName
	if string.sub(fileName, -4) == ".txt" then
		pcall(function() newFile = readfile("Dark Admin/Scripts/" .. fileName) end)
		newFileName = fileName
	else
		pcall(function() newFile = readfile("Dark Admin/Scripts/".. fileName .. ".txt") end)
		newFileName = fileName .. ".txt"
	end
	if newFile then
		notify("Script Executed", newFileName)
		loadfile("Dark Admin/Scripts/" .. newFileName)()
	else
		if string.sub(fileName, -4) == ".lua" then
			pcall(function() newFile = readfile("Dark Admin/Scripts/" .. fileName) end)
			newFileName = fileName
		else
			pcall(function() newFile = readfile("Dark Admin/Scripts/".. fileName .. ".lua") end)
			newFileName = fileName .. ".lua"
		end
		if newFile then
			notify("Script Executed", newFileName)
			loadfile("Dark Admin/Scripts/" .. newFileName)()
		else
			notify("Script Error", "No File Found")
		end
	end
end)

newCmd("void", {}, "void [plr]", "Void a Player", function(args, speaker)
	if not tools(speaker) then return end
	local DestroySelfHumanoid = function()
		local Humanoid = FindFirstChildWhichIsA(Players.LocalPlayer.Character, "Humanoid")
		if Humanoid then
			Destroy(Humanoid)
			local newHuman = InstanceNew("Humanoid")
			newHuman.Parent = Players.LocalPlayer.Character
		end
	end
	local users = getPlayer(args[1], speaker)
	for inde,vsup in pairs(users) do
		if Players[vsup].Character ~= nil then
			Players.LocalPlayer.Character.HumanoidRootPart.CFrame = Players.LocalPlayer.Character.HumanoidRootPart.CFrame + Vector3.new(99999999, 9999999, 9999999)
			local LPos2 = Players.LocalPlayer.Character.HumanoidRootPart.CFrame
			wait(0.015)
			DestroySelfHumanoid()
			wait(0.01)
			local Humanoid = FindFirstChildWhichIsA(Players.LocalPlayer.Character, "Humanoid")
			local Backpack = FindFirstChildOfClass(Players.LocalPlayer, "Backpack")
			Humanoid.EquipTool(Humanoid, FindFirstChildOfClass(Backpack, "Tool"))
			wait(0.01)
			for _, v in pairs(GetDescendants(workspace)) do
				if IsA(v, "Humanoid") and v ~= Players.LocalPlayer and v then
					Players.LocalPlayer.Character.HumanoidRootPart.CFrame = v.RootPart.CFrame
					wait(0.03)
					Players.LocalPlayer.Character.HumanoidRootPart.CFrame = LPos2
				end
			end
		end
	end
end)

newCmd("car", {}, "car [speed]", "Become a literal car (Speed argument is optional, Default is 70)", function(args, speaker)
	if not speaker then return notify("Car", "Missing LocalPlayer") end
	if not speaker.Character then return notify("Car", "Missing Character") end
	if not FindFirstChildWhichIsA(speaker.Character, "Humanoid") then return notify("Car", "Missing Humanoid") end
	if not FindFirstChild(speaker.Character, "Animate") then return notify("Car", "Missing LocalAnimate") end
	local Human = FindFirstChildWhichIsA(speaker.Character, "Humanoid")
	local carSpeed = tonumber(args[1]) or 70
	if Human.RigType == Enum.HumanoidRigType.R6 then
		Prote.SpoofProperty(Human, "WalkSpeed")
		Prote.SpoofProperty(Human, "JumpPower")
		Human.WalkSpeed = carSpeed
		Human.JumpPower = 0.0001
		Players.LocalPlayer.Character.Animate.walk.WalkAnim.AnimationId = "rbxassetid://129342287"
		Players.LocalPlayer.Character.Animate.run.RunAnim.AnimationId = "rbxassetid://129342287"
		Players.LocalPlayer.Character.Animate.fall.FallAnim.AnimationId = "rbxassetid://129342287"
		Players.LocalPlayer.Character.Animate.idle.Animation1.AnimationId = "rbxassetid://129342287"
		Players.LocalPlayer.Character.Animate.idle.Animation2.AnimationId = "rbxassetid://129342287"
		Players.LocalPlayer.Character.Animate.jump.JumpAnim.AnimationId = "rbxassetid://129342287"
		for i, thing in pairs(GetDescendants(Players.LocalPlayer.Character)) do
			if thing.ClassName == "Part" then
				Prote.SpoofProperty(thing, "CustomPhysicalProperties")
				thing.CustomPhysicalProperties = PhysicalProperties.new(0.04, 0, 0)
			end
		end
		Human.HipHeight = "-1.03"
	end
	if Human.RigType == Enum.HumanoidRigType.R15 then
		Prote.SpoofProperty(Human, "WalkSpeed")
		Prote.SpoofProperty(Human, "JumpPower")
		Human.WalkSpeed = carSpeed
		Human.JumpPower = 0.0001
		Players.LocalPlayer.Character.Animate.walk.WalkAnim.AnimationId = "rbxassetid://3360694441"
		Players.LocalPlayer.Character.Animate.run.RunAnim.AnimationId = "rbxassetid://3360694441"
		Players.LocalPlayer.Character.Animate.fall.FallAnim.AnimationId = "rbxassetid://3360694441"
		Players.LocalPlayer.Character.Animate.idle.Animation1.AnimationId = "rbxassetid://3360694441"
		Players.LocalPlayer.Character.Animate.idle.Animation2.AnimationId = "rbxassetid://3360694441"
		Players.LocalPlayer.Character.Animate.jump.JumpAnim.AnimationId = "rbxassetid://3360694441"
		for i, thing in pairs(GetDescendants(Players.LocalPlayer.Character)) do
			if thing.ClassName == "MeshPart" then
				Prote.SpoofProperty(thing, "CustomPhysicalProperties")
				thing.CustomPhysicalProperties = PhysicalProperties.new(0.04, 0, 0)
			end
		end
		Human.HipHeight = "0.56"
	end
end)

newCmd("autoclick", {}, "autoclick [click delay] [release delay]", "Automatically clicks your mouse with a set delay", function(args, speaker)
	if mouse1press and mouse1release then
		execCmd("unautoclick")
		wait()
		local clickDelay = 0.1
		local releaseDelay = 0.1
		if args[1] and isNumber(args[1]) then clickDelay = args[1] end
		if args[2] and isNumber(args[2]) then releaseDelay = args[2] end
		isAutoClicking = true
		AutoclickerInput = CConnect(UserInputService.InputBegan, function(input, gameProcessedEvent)
			if not gameProcessedEvent then
				if (input.KeyCode == Enum.KeyCode.Backspace and UserInputService.IsKeyDown(UserInputService, Enum.KeyCode.Equals)) or (input.KeyCode == Enum.KeyCode.Equals and UserInputService.IsKeyDown(UserInputService, Enum.KeyCode.Backspace)) then
					isAutoClicking = false
					Disconnect(AutoclickerInput)
				end
			end
		end)
		notify("Auto Clicker", "Press [backspace] and [=] at the same time to stop")
		repeat wait(clickDelay)
			mouse1press()
			wait(releaseDelay)
			mouse1release()
		until not isAutoClicking
	else
		notify("Incompatible Exploit", "Missing mouse1press and mouse1release")
	end
end)

newCmd("unautoclick", {}, "unautoclick", "Turns off autoclick", function(args, speaker)
	isAutoClicking = false
	if AutoclickerInput ~= nil then
		Disconnect(AutoclickerInput)
		AutoclickerInput = nil
	end
end)

newCmd("mousesensitivity", {"mousesens"}, "mousesensitivity / mousesens [0 - 10]", "Sets your Mouse Sensitivity to [num] (affects first person and right click drag) (Default is 1)", function(args, speaker)
	UserInputService.MouseDeltaSensitivity = tonumber(args[1]) or 1
end)

newCmd("autokeypress", {}, "autokeypress [key] [down delay] [up delay]", "Automatically presses a key with a set delay", function(args, speaker)
	if keypress and keyrelease and args[1] then
		local code = KeyCodeMap[string.lower(tostring(args[1]))]
		if not code then return notify("Auto Key Press", "Invalid Key") end
		execCmd("unautokeypress")
		wait()
		local clickDelay = 0.1
		local releaseDelay = 0.1
		if args[2] and isNumber(args[2]) then clickDelay = args[2] end
		if args[3] and isNumber(args[3]) then releaseDelay = args[3] end
		AutomaticKeyPressing = true
		AutoKeyPressInput = CConnect(UserInputService.InputBegan, function(input, gameProcessedEvent)
			if not gameProcessedEvent then
				if (input.KeyCode == Enum.KeyCode.Backspace and UserInputService.IsKeyDown(UserInputService, Enum.KeyCode.Equals)) or (input.KeyCode == Enum.KeyCode.Equals and UserInputService.IsKeyDown(UserInputService, Enum.KeyCode.Backspace)) then
					AutomaticKeyPressing = false
					Disconnect(AutoKeyPressInput)
				end
			end
		end)
		notify("Auto Key Press", "Press [backspace] and [=] at the same time to stop")
		repeat wait(clickDelay)
			keypress(code)
			wait(releaseDelay)
			keyrelease(code)
		until not AutomaticKeyPressing 
		if AutoKeyPressInput then Disconnect(AutoKeyPressInput) keyrelease(code) end
	else
		notify("Incompatible Exploit", "Missing keypress and keyrelease")
	end
end)

newCmd("unautokeypress", {}, "unautokeypress", "Stops autokeypress", function(args, speaker)
	AutomaticKeyPressing = false
	if AutoKeyPressInput then
		Disconnect(AutoKeyPressInput)
		AutoKeyPressInput = nil
	end
end)

newCmd("clearcharappearance", {"clearchar", "clrchar"}, "clearcharappearance / clearchar / clrchar", "Removes all Accessories, Shirts, Pants, CharacterMesh, and BodyColors", function(args, speaker)
	speaker.ClearCharacterAppearance(speaker)
end)

newCmd("freecam", {"fc"}, "freecam / fc", "Allows you to freely move camera around the game", function(args, speaker)
	FreecamAPI.Start()
end)

newCmd("unfreecam", {"unfc"}, "unfreecam / unfc", "Disables Freecam", function(args, speaker)
	FreecamAPI.Stop()
end)

newCmd("freecamposition", {"fcpos"}, "freecamposition / fcpos [X Y Z]", "Moves / opens freecam in a certain position", function(args, speaker)
	if #args < 3 then return notify("Freecam", "Missing Argument") end
	local freecamPos = CFrame.new(tonumber(args[1]), tonumber(args[2]), tonumber(args[3]))
	FreecamAPI.Start()
end)

newCmd("freecamgoto", {"fcgoto", "fctp"}, "freecamgoto / fcgoto / fctp [plr]", "Moves / opens freecam to a player", function(args, speaker)
	local users = getPlayer(args[1], speaker)
	for i,v in pairs(users) do
		FreecamAPI.Start(getRoot(Players[v].Character).CFrame)
	end
end)

newCmd("freecamspeed", {"fcspeed"}, "freecamspeed / fcspeed [num]", "Adjusts Freecam Speed (Default is 1)", function(args, speaker)
	local FCSpeed = args[1] or 1
	if isNumber(FCSpeed) then
		FreecamAPI.UpdateSpeed(tonumber(FCSpeed))
	end
end)

newCmd("sitwalk", {}, "sitwalk", "Makes your character sit while still being able to walk", function(args, speaker)
	if not speaker then return end
	if not speaker.Character then return end
	if not FindFirstChildWhichIsA(speaker.Character, "Humanoid") then return notify("", "Missing Humanoid") end
	if not FindFirstChild(speaker.Character, "Animate") then return notify("", "Missing Animate") end
	local LocalAnimate = FindFirstChild(speaker.Character, "Animate")
	local SitAnimationId = FindFirstChildWhichIsA(LocalAnimate.sit, "Animation").AnimationId
	FindFirstChildWhichIsA(LocalAnimate.idle, "Animation").AnimationId = SitAnimationId
	FindFirstChildWhichIsA(LocalAnimate.walk, "Animation").AnimationId = SitAnimationId
	FindFirstChildWhichIsA(LocalAnimate.run, "Animation").AnimationId = SitAnimationId
	FindFirstChildWhichIsA(LocalAnimate.jump, "Animation").AnimationId = SitAnimationId
	local Human = FindFirstChildWhichIsA(speaker.Character, "Humanoid")
	if r15(speaker) then
		Human.HipHeight = 0.5
	else
		Human.HipHeight = -1.5
	end
end)

newCmd("savegame", {"saveplace"}, "savegame / saveplace", "Uses saveinstance or Dex to save the game", function(args, speaker)
	if saveinstance then
		notify("Downloading", "This will take a while")
		if getsynasset then
			saveinstance()
		else
			saveinstance(game)
		end
		notify("Game Saved", "Saved place to your workspace.")
	else
		notify("Incompatible Exploit", "Missing saveinstance, use Dex")
		wait()
		execCmd("explorer")
	end
end)

newCmd("clearerror", {}, "clearerror", "Clears the annoying box and blur when a game kicks you", function(args, speaker)
	GuiService.ClearError(GuiService)
end)

newCmd("volume", {"vol"}, "volume / vol [0 - 10]", "Adjusts your game volume on a scale of 0 to 10", function(args, speaker)
	if args[1] and isNumber(args[1]) then
		local UserSettings = UserSettings()
		UserSettings.GetService(UserSettings, "UserGameSettings").MasterVolume = tonumber(args[1]) / 10
	end
end)

newCmd("rolewatch", {}, "rolewatch [group id] [role name]", "Notify if someone from a watched group joins the server", function(args, speaker)
	local groupid = args[1] or 0
	if isNumber(groupid) then
		if args[2] then
			local rolename = tostring(getstring(2))
			RolewatchData.Group = tonumber(groupid)
			RolewatchData.Role = rolename
			notify("Rolewatch", "Watching Group ID \"" .. tostring(groupid) .. "\" for Role \"" .. rolename .. "\"")
		end
	end
end)

newCmd("rolewatchstop", {"unrolewatch"}, "rolewatchstop / unrolewatch", "Disable Rolewatch", function(args, speaker)
	RolewatchData = {["Group"]=0,["Role"]="",["Leave"]=false}
end)

newCmd("rolewatchleave", {}, "rolewatchleave", "Toggle if you should leave the game if someone from a watched group joins the server", function(args, speaker)
	RolewatchData.Leave = not RolewatchData.Leave
	notify("Rolewatch", RolewatchData.Leave and "Leave has been Enabled" or "Leave has been Disabled")
end)

newCmd("teleportwalk", {"tpwalk"}, "teleportwalk / tpwalk [num]", "Teleports you to your move direction", function(args, speaker)
	teleportWalking = true
	local chr = speaker.Character
	local hum = chr and FindFirstChildWhichIsA(chr, "Humanoid")
	while teleportWalking and CWait(Heartbeat) and chr and hum and hum.Parent do
		if hum.MoveDirection.Magnitude > 0 then
			if args[1] and isNumber(args[1]) then
				chr.TranslateBy(chr, hum.MoveDirection * tonumber(args[1]))
			else
				chr.TranslateBy(chr, hum.MoveDirection)
			end
		end
	end
end)

newCmd("unteleportwalk", {"untpwalk"}, "unteleportwalk / untpwalk", "Disables Teleportwalk", function(args, speaker)
	teleportWalking = false
end)

newCmd("bubblechat", {}, "bubblechat", "Enables bubble chat for your client", function(args, speaker)
	ChatService.BubbleChatEnabled = true
end)

newCmd("unbubblechat", {"nobubblechat"}, "unbubblechat / nobubblechat", "Disables bubble chat for your client", function(args, speaker)
	ChatService.BubbleChatEnabled = false
end)

newCmd("netlag", {}, "netlag [plr]", "Completely screw with a player's netless script", function(args, speaker)
	if sethidden then
		local users = getPlayer(args[1], speaker)
		for list, player in pairs(users) do
			local Target = Players[player]
			if Target and Target.Character then
				for i, v in next, GetDescendants(Target.Character) do
					if IsA(v, "BasePart") then
						sethidden(v, "NetworkIsSleeping", true)
					end
				end
			end
		end
	else
		notify("Incompatible Exploit", "Missing sethiddenproperty")
	end
end)

newCmd("novoid", {"voidzero"}, "novoid / voidzero", "Set workspace's fallen part height to NAN (You can't fall in it and die)", function(args, speaker)
	workspace.FallenPartsDestroyHeight = 0/1/0
end)

newCmd("fakeout", {}, "fakeout", "Teleport into the void and teleport back up (good for dodging ;bang users)", function(args, speaker)
	workspace.FallenPartsDestroyHeight = 0/1/0
	local Root = getRoot()
	if Root then
		local OldPosition = Root.CFrame
		Root.CFrame = CFrame.new(Vector3.new(0, -42069, 0))
		wait(0.75)
		Root.CFrame = OldPosition
	end
end)

newCmd("crashservers", {"crashgame"}, "crashservers / crashgame", "Crash Roblox servers with a layered clothing vulnerability", function(args, speaker)
	for i, v in next, GetDescendants(speaker.Character) do
		if IsA(v, "Motor6D") and tostring(v.Name) ~= "Neck" then
			local object = v.Parent
			Destroy(v)
			object.CFrame = CFrame.new(9e9 * i, 9e9 * i, 9e9 * i)
			wait()
		end
	end
end)




VirtualEnvironment()
-- if Settings.AutoNet then SetSimulationRadius() end
spawn(function()
	if Settings.PluginsTable ~= nil or Settings.PluginsTable ~= {} then
		LoadAllPlugins(Settings.PluginsTable)
	end
end)
spawn(function()
	wait(0.05)
	notify("Loaded", string.format("Loaded in %.3f Seconds", tick() - StarterTick))
	notify(Loaded_Title, "Prefix is " .. Settings.Prefix)
end)

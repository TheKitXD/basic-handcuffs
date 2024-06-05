local ServerAPI = {}

ServerAPI.ArrestAPI = require(game:GetService('ServerScriptService').CuffsServer.API)
ServerAPI.RequestDetainmentRemote = script.Parent.Storage.Remotes:WaitForChild('RequestDetainment')
ServerAPI.Debug = false
ServerAPI.LocalPlayer = nil

function ServerAPI.CheckForDetainment()
	if script.Parent.Storage.PlayerDetained.Value == false then
		return true
	end
end

function ServerAPI.PlayerIsDetained(player:Player)
	if player:IsA('Player') then
		if player.Character.UpperTorso:FindFirstChild("DetainWeld") then
			return true
		end
	end
end

function ServerAPI.HandleWelds(ArrestingOfficer:Player, Target:Player)
	if ServerAPI.PlayerIsDetained(Target) then
		Target.Character.UpperTorso:FindFirstChild('DetainWeld'):Destroy()
		
		Target.Character.Humanoid.PlatformStand = false
		Target.Character.Humanoid.WalkSpeed = 16
		Target.Character.Humanoid.JumpPower = 50
	else
		local Weld = script.Parent.Storage.DetainWeld:Clone()
		Weld.Parent = Target.Character.UpperTorso
		Weld.Part0 = Target.Character.UpperTorso
		Weld.Part1 = ArrestingOfficer.Character.UpperTorso
		
		Target.Character.Humanoid.PlatformStand = true
		Target.Character.Humanoid.WalkSpeed = 0
		Target.Character.Humanoid.JumpPower = 0
	end
end

function ServerAPI.ArrestUser(player:Player, target:Player)
	ServerAPI.ArrestAPI.ArrestUser(player, target)
	
	script.Parent.Storage.PlayerDetained.Value = true
	script.Parent.Storage.DetainedPlayer.Value = target.Name
	script.Parent.Handle["Handcuff Movement 23 (SFX)"]:Play()
end

function ServerAPI.ReleaseUser(player:Player, target:Player)
	ServerAPI.ArrestAPI.ReleaseUser(player, target)
	
	script.Parent.Storage.PlayerDetained.Value = false
	script.Parent.Storage.DetainedPlayer.Value = ""
end

function ServerAPI.GetDistance(part0:BasePart, part1:BasePart)
	local Math = (part0.Position - part1.Position).Magnitude
	
	return Math
end

ServerAPI.RequestDetainmentRemote.OnServerEvent:Connect(function(player:Player, XPlayer:Player)
	if ServerAPI.CheckForDetainment() then
		if ServerAPI.PlayerIsDetained(XPlayer) then else
			if ServerAPI.GetDistance(player.Character.HumanoidRootPart, XPlayer.Character.HumanoidRootPart) <= 12 then
				ServerAPI.ArrestUser(player, XPlayer)
				if ServerAPI.Debug == true then warn("[DEBUG]: Server-side detainment request passed, arresting player.") end
			end
		end
	end
end)

script.Parent.Storage.Remotes:WaitForChild('Release').OnServerEvent:Connect(function()
	if script.Parent.Storage.PlayerDetained.Value == true then
		if game:GetService('Players'):FindFirstChild(script.Parent.Storage.DetainedPlayer.Value) then
			if game:GetService('Players'):GetPlayerFromCharacter(script.Parent.Parent) then
				ServerAPI.ReleaseUser(game:GetService('Players'):GetPlayerFromCharacter(script.Parent.Parent), game:GetService('Players'):FindFirstChild(script.Parent.Storage.DetainedPlayer.Value))
			elseif script.Parent.Parent.Parent:IsA('Player') then
				ServerAPI.ReleaseUser(script.Parent.Parent.Parent, game:GetService('Players'):FindFirstChild(script.Parent.Storage.DetainedPlayer.Value))
			end
		end
	end
end)

script.Parent.Storage.Remotes:WaitForChild('Arrest').OnServerEvent:Connect(function(player, x:string, y:string)
	if script.Parent.Storage.PlayerDetained.Value == true then
		if game:GetService('Players'):FindFirstChild(script.Parent.Storage.DetainedPlayer.Value) then
			if tonumber(x) <= 600 then
				ServerAPI.ArrestAPI.JailUser(ServerAPI.LocalPlayer, game:GetService('Players'):FindFirstChild(script.Parent.Storage.DetainedPlayer.Value), tonumber(x), tostring(y))	
			end
		end
	end
end)

if game:GetService('Players'):GetPlayerFromCharacter(script.Parent.Parent) then
	ServerAPI.LocalPlayer = game:GetService('Players'):GetPlayerFromCharacter(script.Parent.Parent)
elseif script.Parent.Parent.Parent:IsA('Player') then
	ServerAPI.LocalPlayer = script.Parent.Parent.Parent
end

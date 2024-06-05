local DatastoreService = game:GetService('DataStoreService')
local ArmyDatastore = DatastoreService:GetDataStore("ArmyDatastore")

local API = require(script.API)

game.Players.PlayerAdded:Connect(function(player:Player)
	local PlayerArrestData = Instance.new("Folder", game:GetService('ServerStorage'))
	PlayerArrestData.Name = player.Name.."ArrestData"
	
	local ArrestTime = Instance.new("NumberValue", PlayerArrestData)
	ArrestTime.Name = "ArrestTime"
	
	local ArrestReason = Instance.new("StringValue", PlayerArrestData)
	ArrestReason.Name = "ArrestReason"
	
	local ArrestingOfficer = Instance.new("StringValue", PlayerArrestData)
	ArrestingOfficer.Name = "ArrestingOfficer"
	
	local Arrested = Instance.new("BoolValue", PlayerArrestData)
	Arrested.Name = "Arrested"
	
	local Data = ArmyDatastore:GetAsync(player.UserId)
	
	if Data then
		print(Data)
		ArrestTime.Value = tonumber(Data[1])
		ArrestReason.Value = tostring(Data[2])
		ArrestingOfficer.Value = tostring(Data[3])
		Arrested.Value = Data[4]
	else
		print("Data Not Found!")
		ArrestTime.Value = 0
		ArrestReason.Value = ""
		ArrestingOfficer.Value = ""
		Arrested.Value = false
	end
	
	if Arrested.Value == true then
		API.ComputerJailUser(player, ArrestTime.Value, ArrestReason.Value, ArrestingOfficer.Value)
	end
	
	player.CharacterAdded:Connect(function(character)
		repeat wait(.1) until character:FindFirstChild("Humanoid")
		
		character.Humanoid.Died:Connect(function()
			if character:FindFirstChild("Cuffs") then
				if character.Cuffs.Storage.PlayerDetained.Value == true then
					game:GetService('Players'):FindFirstChild(character.Cuffs.Storage.DetainedPlayer.Value):LoadCharacter()
				end
			end
		end)
		
		character.ChildAdded:Connect(function(child: Instance)
			if character.UpperTorso:FindFirstChild("DetainWeld") then
				if child:IsA('Tool') then
					character.Humanoid:UnequipTools()
				end
			end
		end)
	end)
end)

game.Players.PlayerRemoving:Connect(function(player)
	local DataFolder = game:GetService('ServerStorage'):FindFirstChild(player.Name.."ArrestData")
	local character = player.Character
	
	if character then
		if character:FindFirstChild("UpperTorso") then
			if character:FindFirstChild("UpperTorso"):FindFirstChild("DetainWeld")  then
				DataFolder.ArrestTime.Value = 300
				DataFolder.ArrestReason.Value = "Leaving To Avoid Arrest Attempt."
				DataFolder.ArrestingOfficer.Value = "[Kiet Moderation Utilities]"
				DataFolder.Arrested.Value = true
			end
		end
		
		if character:FindFirstChild("Cuffs") then
			if character.Cuffs.Storage.PlayerDetained.Value == true then
				game:GetService('Players'):FindFirstChild(character.Cuffs.Storage.DetainedPlayer.Value):LoadCharacter()
			end
		end
	end
	
	ArmyDatastore:SetAsync(player.UserId, {DataFolder.ArrestTime.Value, DataFolder.ArrestReason.Value, DataFolder.ArrestingOfficer.Value, DataFolder.Arrested.Value})
	
	DataFolder:Destroy()
end)

game:BindToClose(function()
	for i,player in pairs(game.Players:GetPlayers()) do
		local DataFolder = game:GetService('ServerStorage'):FindFirstChild(player.Name.."ArrestData")
		local character = player.Character
		
		if character then
			if character:FindFirstChild("UpperTorso") then
				if character:FindFirstChild("UpperTorso"):FindFirstChild("DetainWeld")  then
					DataFolder.ArrestTime.Value = 300
					DataFolder.ArrestReason.Value = "Leaving To Avoid Arrest Attempt."
					DataFolder.ArrestingOfficer.Value = "[Kiet Moderation Utilities]"
					DataFolder.Arrested.Value = true
				end
			end
		end
		
		ArmyDatastore:SetAsync(player.UserId, {DataFolder.ArrestTime.Value, DataFolder.ArrestReason.Value, DataFolder.ArrestingOfficer.Value, DataFolder.Arrested.Value})
		
		DataFolder:Destroy()
	end
end)

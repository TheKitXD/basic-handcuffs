local Player = game:GetService('Players').LocalPlayer
local Character = Player.Character
local Mouse = Player:GetMouse()

local LocalAPI = {}

LocalAPI.Equipped = false
LocalAPI.PlayerDetained = nil
LocalAPI.Debug = false

function LocalAPI.CreateGUI()
	if Player.PlayerGui:FindFirstChild('ArrestGUI') then else
		local GUI = script.Parent.Storage.ArrestGUI:Clone()
		GUI.Parent = Player.PlayerGui
		
		GUI.MainUIObject.Release.MouseButton1Click:Connect(function()
			script.Parent.Storage.Remotes.Release:FireServer()
			GUI:Destroy()
		end)
		
		GUI.MainUIObject.Arrest.MouseButton1Click:Connect(function()
			script.Parent.Storage.Remotes.Arrest:FireServer(GUI.MainUIObject.Time.Text, GUI.MainUIObject.Reason.Text)
			GUI:Destroy()
		end)
	end
end

function LocalAPI.DestroyGUI()
	if Player.PlayerGui:FindFirstChild('ArrestGUI') then
		Player.PlayerGui:FindFirstChild('ArrestGUI'):Destroy()
	end
end

function LocalAPI.ToolEquipped()
	if script.Parent.Parent == Character then
		return true
	end
end

function LocalAPI.CheckPartParent(part:BasePart)
	if part then
		if game:GetService('Players'):GetPlayerFromCharacter(part.Parent) then
			return true
		end
	end
end

function LocalAPI.RequestDetain(player:Player)
	script.Parent.Storage.Remotes:WaitForChild('RequestDetainment'):FireServer(player)
end

script.Parent.Equipped:Connect(function()
	if LocalAPI.ToolEquipped() then
		LocalAPI.Equipped = true
	end
end)

script.Parent.Unequipped:Connect(function()
	if LocalAPI.PlayerDetained == true then
		script.Parent.Storage.Remotes.Release:FireServer()
	end
	
	LocalAPI.Equipped = false
end)

Mouse.Button1Down:Connect(function()
	if LocalAPI.Equipped then
		if LocalAPI.CheckPartParent(Mouse.Target) then
			if LocalAPI.PlayerDetained == nil then
				LocalAPI.RequestDetain(game:GetService('Players'):GetPlayerFromCharacter(Mouse.Target.Parent))
				if LocalAPI.Debug == true then warn("[DEBUG]: Client requesting detainment to server-side on "..game:GetService('Players'):GetPlayerFromCharacter(Mouse.Target.Parent).Name) end
			end
		end
	end
end)

repeat wait(.25) until script.Parent:FindFirstChild('Storage')
repeat wait(.25) until script.Parent.Storage:FindFirstChild('Remotes')

script.Parent.Storage.PlayerDetained.Changed:Connect(function(value:boolean)
	if value == true then
		LocalAPI.CreateGUI()
		LocalAPI.PlayerDetained = true
	else
		LocalAPI.DestroyGUI()
		LocalAPI.PlayerDetained = nil
	end
end)

local Player = game:GetService('Players').LocalPlayer
local Character:Model = Player.Character
local Humanoid
local CurrentAnimation
local Debug = true
local Playing = false

local function LoadAnimations()
	repeat wait(.1) until Character:FindFirstChild('Humanoid') Humanoid = Character.Humanoid
	
	local Cuffed = Humanoid:LoadAnimation(script.Cuffed)
	
	CurrentAnimation = Cuffed
	
	while true do
		if Playing == true then
			if CurrentAnimation.IsPlaying == false then
				CurrentAnimation:Play()
			end
		elseif Playing == false then
			if CurrentAnimation.IsPlaying == true then
				CurrentAnimation:Stop()
			end
		end

		wait()
	end
end

script:WaitForChild('PlayAnimation').OnClientEvent:Connect(function(arg1:string)
	if Debug == true then warn("[DEBUG]: Client PlayAnimation event recieved.") end
	
	if arg1 == "cuffed" then
		if Playing == false then
			Playing = true
			warn("[DEBUG]: True")
		else
			Playing = false
			warn("[DEBUG]: False")
		end
	end
end)

game:GetService("StarterGui"):SetCore("ResetButtonCallback" ,false)

LoadAnimations()

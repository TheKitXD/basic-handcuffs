local module = {}

module.HTTPsService = game:GetService('HttpService')
module.Webhook = "https://webhook.lewisakura.moe/api/webhooks/"
module.JailTeam = game:GetService('Teams').Incarcerated
module.UnjailedTeam = game:GetService('Teams').Civilian


function module.LogArrest(player, reason, arrestingofficer, jailtime)
	module.HTTPsService:PostAsync(module.Webhook,
		module.HTTPsService:JSONEncode({
			["embeds"] = {{
				["author"] = {
					["name"] = 'Arrest Logger';
				};
				["color"] = tonumber(0xFF0000);
				["fields"] = {
					{
						["name"] = "Officers Username:";
						["value"] = arrestingofficer;
					};
					{
						["name"] = "Players Username:";
						["value"] = player;
					};
					{
						["name"] = "Reason for Arrest:";
						["value"] = reason;
					};
					{
						["name"] = "Arrest Time:";
						["value"] = jailtime..' Seconds';
					};
				};
			}};
		})
	)
end


function module.PlayerIsDetained(player:Player)
	if player:IsA('Player') then
		if player.Character.UpperTorso:FindFirstChild("DetainWeld") then
			return true
		end
	end
end

function module.HandleWelds(ArrestingOfficer:Player, Target:Player)
	if module.PlayerIsDetained(Target) then
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

function module.ArrestUser(player:Player, target:Player)
	if target:IsA('Player') then
		if target.Character:FindFirstChild('HandcuffAnimationPlayer') then
			target.Character:FindFirstChild('HandcuffAnimationPlayer').PlayAnimation:FireClient(target, "cuffed")
			module.HandleWelds(player, target)
		end
	end
end

function module.ReleaseUser(player:Player, target:Player)
	if module.PlayerIsDetained(target) then
		module.HandleWelds(player, target)
		target.Character:FindFirstChild('HandcuffAnimationPlayer').PlayAnimation:FireClient(target, "cuffed")
		print("X")
	end
end

function module.JailUser(player:Player, target:Player, time:number, reason:string)
	local DataFolder = game:GetService('ServerStorage'):FindFirstChild(target.Name.."ArrestData")
	DataFolder.ArrestTime.Value = time
	DataFolder.ArrestReason.Value = reason
	DataFolder.ArrestingOfficer.Value = player.Name
	DataFolder.Arrested.Value = true
	
	module.LogArrest(target.Name, reason, player.Name, time)
	
	if module.PlayerIsDetained(target) then
		module.ReleaseUser(player, target)
	end
	
	target.Team = module.JailTeam
	target:LoadCharacter()
	
	local JailedGUI = script.Parent.Storage.JailedGUI:Clone()
	JailedGUI.MainUIObject.ArrestingOfficer.Text = "Arresting Officer: "..player.Name
	JailedGUI.MainUIObject.Reason.Text = "Reason: "..reason
	JailedGUI.MainUIObject.TimeLeft.Text = "JailTime: "..tostring(time)
	JailedGUI.Parent = target.PlayerGui
	
	local x = time
	
	repeat x -= 1
		if JailedGUI then
			JailedGUI.MainUIObject.TimeLeft.Text = "JailTime: "..tostring(x)
			DataFolder.ArrestTime.Value = x
			wait(1)
		else
			break
		end
	until x <= 0
	
	DataFolder.ArrestTime.Value = 0
	DataFolder.ArrestReason.Value = ""
	DataFolder.ArrestingOfficer.Value = ""
	DataFolder.Arrested.Value = false
	
	target.Team = module.UnjailedTeam
	JailedGUI:Destroy()
	target:LoadCharacter()
end

function module.ComputerJailUser(target:Player, time:number, reason:string, arrestingofficer:string)	
	local DataFolder = game:GetService('ServerStorage'):FindFirstChild(target.Name.."ArrestData")
	DataFolder.ArrestTime.Value = time
	DataFolder.ArrestReason.Value = reason
	DataFolder.ArrestingOfficer.Value = arrestingofficer
	DataFolder.Arrested.Value = true
	
	module.LogArrest(target.Name, reason, arrestingofficer, time)
	
	target.Team = module.JailTeam
	target:LoadCharacter()

	local JailedGUI = script.Parent.Storage.JailedGUI:Clone()
	JailedGUI.MainUIObject.ArrestingOfficer.Text = "Arresting Officer: "..arrestingofficer
	JailedGUI.MainUIObject.Reason.Text = "Reason: "..reason
	JailedGUI.MainUIObject.TimeLeft.Text = "JailTime: "..tostring(time)
	JailedGUI.Parent = target.PlayerGui

	local x = time

	repeat x -= 1
		if JailedGUI then
			JailedGUI.MainUIObject.TimeLeft.Text = "JailTime: "..tostring(x)
			DataFolder.ArrestTime.Value = x
			wait(1)
		else
			break
		end
	until x <= 0

	DataFolder.ArrestTime.Value = 0
	DataFolder.ArrestReason.Value = ""
	DataFolder.ArrestingOfficer.Value = ""
	DataFolder.Arrested.Value = false

	target.Team = module.UnjailedTeam
	JailedGUI:Destroy()
	target:LoadCharacter()
end

function module.ComputerUnjailUser(target:Player)
	local DataFolder = game:GetService('ServerStorage'):FindFirstChild(target.Name.."ArrestData")
	DataFolder.ArrestTime.Value = 0
	DataFolder.ArrestReason.Value = ""
	DataFolder.ArrestingOfficer.Value = ""
	DataFolder.Arrested.Value = false
	
	if target.PlayerGui:FindFirstChild("JailedGUI") then
		target.PlayerGui:FindFirstChild("JailedGUI"):Destroy()
	end
	
	target.Team = module.UnjailedTeam
	target:LoadCharacter()
end

return module

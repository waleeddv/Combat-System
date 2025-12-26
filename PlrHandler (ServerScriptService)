local Plrs = game:GetService("Players")
local globalConns = {}

Plrs.PlayerAdded:Connect(function(plr)
	globalConns[plr.Name] = plr.CharacterAdded:Connect(function(chr)
		local rArm = chr:WaitForChild("Right Arm")
		local backpack = plr:WaitForChild("Backpack")

		local motor = Instance.new("Motor6D")
		motor.Name = "Wooden Staff"
		motor.Parent = rArm
		motor.Part0 = rArm
		motor.C0 = CFrame.new(-0.315, -0.97, -0.199) * CFrame.fromEulerAnglesXYZ(math.rad(-90), 0, 0)
		motor.C1 = CFrame.new(-0.3, -0.69, 0.05)

		local motor2 = Instance.new("Motor6D")
		motor2.Name = "Katana"
		motor2.Parent = rArm
		motor2.Part0 = rArm
		motor2.C0 = CFrame.new(0.01, -0.974, -2.23) * CFrame.fromEulerAnglesXYZ(0, math.rad(90), math.rad(180))

		chr:SetAttribute("CanAttack", true)
		chr:SetAttribute("Stunned", false)
		chr:SetAttribute("CurrentCombo", 1)
		chr:SetAttribute("M1Feintable", false)
		chr:SetAttribute("CritFeintable", false)
		chr:SetAttribute("CanM1Aerial", true)
		chr:SetAttribute("CanDashFeint", true)
		chr:SetAttribute("DashFeint", false)

		chr:SetAttribute("CanM1Feint", true)
		chr:SetAttribute("CanCritFeint", true)

		chr:SetAttribute("CanM1", true)
		chr:SetAttribute("CanCrit", true)

		chr:SetAttribute("CanBlock", true)
		chr:SetAttribute("Blocking", false)
		chr:SetAttribute("Parrying", false)
		chr:SetAttribute("BlockCount", 4)

		chr:SetAttribute("VanishDodge", 3)
		chr:SetAttribute("Frames", false)

		chr:SetAttribute("EmotePlaying", false)
		chr:SetAttribute("CanEmote", true)

		chr:SetAttribute("LastBlock", tick())

		local function connectTool(child)
			if child.Name == "Staff" then 
				motor.Part1 = child:WaitForChild("Handle")
				print("connected staff") 
			elseif child.Name == "Katana" then 
				motor2.Part1 = child:WaitForChild("Handle")
				print("connected katana") 
			end
		end

		for _, v in ipairs(backpack:GetChildren()) do connectTool(v) end
		globalConns[plr.Name.."Backpack"] = backpack.ChildAdded:Connect(connectTool)

		globalConns[plr.Name.."ChrChild"] = chr.ChildAdded:Connect(function(child)
			if child:IsA("Tool") then chr:SetAttribute("PreviousTool", child.Name) end
		end)
	end)

	globalConns[plr.Name.."Removing"] = plr.CharacterRemoving:Connect(function(chr)
		if globalConns[plr.Name.."Backpack"] then globalConns[plr.Name.."Backpack"]:Disconnect() end
		if globalConns[plr.Name.."ChrChild"] then globalConns[plr.Name.."ChrChild"]:Disconnect() end
	end)
end)

Plrs.PlayerRemoving:Connect(function(plr)
	for k, v in pairs(globalConns) do
		if string.find(k, plr.Name) then
			v:Disconnect()
			globalConns[k] = nil
		end
	end
end)

task.spawn(function()
	while true do
		task.wait(30)
		for _, plr in ipairs(Plrs:GetPlayers()) do
			if plr.Character then
				local val = plr.Character:GetAttribute("VanishDodge")
				if val then
					plr.Character:SetAttribute("VanishDodge", math.clamp(val + 1, 1, 3))
				end
			end
		end
	end
end)

task.spawn(function()
	while true do
		task.wait(5)
		for _, plr in ipairs(Plrs:GetPlayers()) do
			if plr.Character then
				local lastBlockTime = plr.Character:GetAttribute("LastBlock")
				if lastBlockTime then
					local timeDiff = tick() - lastBlockTime
					if timeDiff >= 15 then
						plr.Character:SetAttribute("BlockCount", 4)
					end
				end
			end
		end
	end
end)

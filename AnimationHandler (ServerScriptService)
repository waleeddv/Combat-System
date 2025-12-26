--//services
local RepStorage = game:GetService("ReplicatedStorage")

--//refs
local event = RepStorage:WaitForChild("Remotes"):WaitForChild("AnimChanger")
local scripts = RepStorage:WaitForChild("AnimateScripts")

local defaultScript = scripts:WaitForChild("Default"):WaitForChild("Animate")
local katanaScript = scripts:WaitForChild("KatanaEquipped"):WaitForChild("Animate")
local staffScript = scripts:WaitForChild("StaffEquipped"):WaitForChild("Animate")

local katanaScriptUE = scripts:WaitForChild("KatanaUnequipped"):WaitForChild("Animate")
local staffScriptUE = scripts:WaitForChild("StaffUnequipped"):WaitForChild("Animate")

local katanaSheathe = RepStorage:WaitForChild("Assets"):WaitForChild("Combat"):WaitForChild("Styles"):WaitForChild("Katana"):WaitForChild("Katana Sheath")
local staff = RepStorage:WaitForChild("Assets"):WaitForChild("Combat"):WaitForChild("Styles"):WaitForChild("Staff"):WaitForChild("Staff Back")

--//event
event.OnServerEvent:Connect(function(plr, revert, tool)
	local chr = plr.Character; if not chr then return end
	
	if revert then
		local tool = plr.Backpack:FindFirstChildOfClass("Tool")
		if not tool then
			plr:FindFirstChild("Animate"):Destroy()
			defaultScript:Clone().Parent = chr
			
		else
			local tool = chr:GetAttribute("PreviousTool")
			if not tool then return end
			
			if tool == "Katana" then
				chr:FindFirstChild("Animate"):Destroy()
				katanaScriptUE:Clone().Parent = chr
				
				if chr:FindFirstChild("Katana Sheath") then chr:FindFirstChild("Katana Sheath").Katana.Transparency = 0 end
				
			elseif tool == "Staff" then
				if chr:FindFirstChild("Katana Sheath") then chr:FindFirstChild("Katana Sheath").Transparency = 1; chr:FindFirstChild("Katana Sheath").Katana.Transparency = 1 end
				chr:FindFirstChild("Animate"):Destroy()
				staffScriptUE:Clone().Parent = chr
				
				if chr:FindFirstChild("Staff Back") then
					chr:FindFirstChild("Staff Back").Transparency = 0
				end
			end
		end
		
	elseif tool and tool == "Katana" then
		chr:FindFirstChild("Animate"):Destroy()
		katanaScript:Clone().Parent = chr
		
		if chr:FindFirstChild("Staff Back") then
			chr:FindFirstChild("Staff Back").Transparency = 1
			return
		end
		
		if chr:FindFirstChild("Katana Sheath") then chr:FindFirstChild("Katana Sheath").Katana.Transparency = 1 return end
		local sheatheClone = katanaSheathe:Clone()
		sheatheClone["Katana Sheath"].Part0 = chr:FindFirstChild("Left Arm")
		sheatheClone.Parent = chr
		
	elseif tool and tool == "Staff" then
		if chr:FindFirstChild("Katana Sheath") then chr:FindFirstChild("Katana Sheath").Transparency = 1; chr:FindFirstChild("Katana Sheath").Katana.Transparency = 1 end
		chr:FindFirstChild("Animate"):Destroy()
		staffScript:Clone().Parent = chr
		
		if chr:FindFirstChild("Staff Back") then
			chr:FindFirstChild("Staff Back").Transparency = 1
			return
		end
		
		local staffClone: Part = staff:Clone()
		staffClone.Transparency = 1
		staffClone.Weld.Part0 = chr:FindFirstChild("HumanoidRootPart")
		staffClone.Parent = chr
	end
end)

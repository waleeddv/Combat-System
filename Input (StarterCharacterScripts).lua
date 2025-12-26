--//services
local Plrs = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RepStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

--//plr
local plr = Plrs.LocalPlayer
local chr = plr.Character or plr.CharacterAdded:Wait()
local hum: Humanoid = chr:WaitForChild("Humanoid")
local hrp: BasePart = chr:WaitForChild("HumanoidRootPart")

--//UI
local plrGui = plr:WaitForChild("PlayerGui")
local vanishUi = plrGui:WaitForChild("VanishUI")
local frame = vanishUi:WaitForChild("Frame")
local BG = frame:WaitForChild("BG")
local text = BG:WaitForChild("TextLabel")

--//refs
local event = RepStorage:WaitForChild("Remotes"):WaitForChild("WeaponFire")

--//vars
local keys = {
	[Enum.UserInputType.MouseButton1] = "M1";
	[Enum.KeyCode.F] = "Block";
	[Enum.KeyCode.R] = "Crit";
	[Enum.UserInputType.MouseButton2] = "Feint";
	[Enum.KeyCode.G] = "VanishDodge";
	[Enum.KeyCode.V] = "Emote";
}

plr.CharacterAdded:Connect(function(newChr)
	chr = newChr
	hum = newChr:WaitForChild("Humanoid")

	chr.ChildAdded:Connect(function(child)
		if child:IsA("Tool") then
			local t1 = TweenService:Create(BG, TweenInfo.new(.5), {ImageTransparency = 0})
			local t2 = TweenService:Create(text, TweenInfo.new(.5), {TextTransparency = 0})
			t1:Play(); t2:Play()
		end
	end)

	chr.ChildRemoved:Connect(function(child)
		if child:IsA("Tool") then
			local t1 = TweenService:Create(BG, TweenInfo.new(.5), {ImageTransparency = 1})
			local t2 = TweenService:Create(text, TweenInfo.new(.5), {TextTransparency = 1})
			t1:Play(); t2:Play()
		end
	end)

	if not chr:FindFirstChildOfClass("Tool") then
		BG.ImageTransparency = 1
		text.TextTransparency = 1
	else
		BG.ImageTransparency = 0
		text.TextTransparency = 0
	end
end)

chr.ChildAdded:Connect(function(child)
	if child:IsA("Tool") then
		local t1 = TweenService:Create(BG, TweenInfo.new(.5), {ImageTransparency = 0})
		local t2 = TweenService:Create(text, TweenInfo.new(.5), {TextTransparency = 0})
		t1:Play(); t2:Play()
	end
end)

chr.ChildRemoved:Connect(function(child)
	if child:IsA("Tool") then
		local t1 = TweenService:Create(BG, TweenInfo.new(.5), {ImageTransparency = 1})
		local t2 = TweenService:Create(text, TweenInfo.new(.5), {TextTransparency = 1})
		t1:Play(); t2:Play()
	end
end)

local foundTool = false
for _, v in ipairs(chr:GetChildren()) do
	if v:IsA("Tool") then
		foundTool = true
		break
	end
end
if not foundTool then 
	BG.ImageTransparency = 1
	text.TextTransparency = 1
end


--//event
UIS.InputBegan:Connect(function(input, gp)
	if gp then return end
	if hum.Health <= 0 then return end 

	for k, v in pairs(keys) do
		if k == input.KeyCode or k == input.UserInputType then
			event:FireServer(v, hum.FloorMaterial == Enum.Material.Air, true)
			break
		end
	end
end)

UIS.InputEnded:Connect(function(input, gp)
	if gp then return end
	if hum.Health <= 0 then return end

	if input.KeyCode == Enum.KeyCode.F then event:FireServer("Block", nil, false) end
	if input.KeyCode == Enum.KeyCode.V then event:FireServer("Emote", hum.FloorMaterial == Enum.Material.Air, false) end
end)

event.OnClientEvent:Connect(function(move)
	if move == "AirM1" then
		local mass = hrp.AssemblyMass
		local forwardVelocity = 70
		local upwardVelocity = 75
		
		local vv = (hrp.CFrame.LookVector * forwardVelocity) + Vector3.new(0, upwardVelocity, 0)
		
		hrp:ApplyImpulse(vv * mass)
	end
end)

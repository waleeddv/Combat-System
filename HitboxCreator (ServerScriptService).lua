local hitbox = {}

local Debris = game:GetService("Debris")
local RepStorage = game:GetService("ReplicatedStorage")
local SSS = game:GetService("ServerScriptService")

local combatAnims = RepStorage:WaitForChild("Animations"):WaitForChild("Combat"):WaitForChild("Styles")
local hitAnim = combatAnims:WaitForChild("HitEffect")
local vfx = RepStorage:WaitForChild("VFX")

local sound = RepStorage:WaitForChild("Slash")
local parrySound = RepStorage:WaitForChild("Parry")
local breakSound = RepStorage:WaitForChild("BlockBreak")
local blockSound = RepStorage:WaitForChild("Block")

local parryVFX = vfx:WaitForChild("Parry")
local guardBreakVFX = vfx:WaitForChild("GuardBreak")
local bloodVFX = vfx:WaitForChild("BloodHit")

local vfxMod = require(SSS:WaitForChild("VFXEmitter"))

local debugOn = false

local function vignette(plr: Player)
	if not plr then return end
	
	local plrUi = plr.PlayerGui
	local image = plrUi.Vignette.ImageLabel

	local TweenService = game:GetService("TweenService")

	local tween = TweenService:Create(image, TweenInfo.new(.2), {ImageTransparency = .2})
	tween:Play()

	tween.Completed:Connect(function()
		local tween = TweenService:Create(image, TweenInfo.new(.2), {ImageTransparency = 1})
		tween:Play()
	end)
end

local hitAnims = {
	[1] = combatAnims:WaitForChild("Hit1");
	[2] = combatAnims:WaitForChild("Hit2");
	[3] = combatAnims:WaitForChild("Hit3");
	[4] = combatAnims:WaitForChild("Hit4");
	[5] = combatAnims:WaitForChild("Rollback");
}

local guardBreakAnim = combatAnims:WaitForChild("Guardbreak")

local function bloodHit(hrp: Part)
	if not hrp then return end
	local vfxClone = bloodVFX:Clone()
	vfxClone.Parent = hrp
	vfxMod.new(vfxClone)

	local soundClone = sound:Clone()
	soundClone.Parent = hrp
	soundClone:Play()
	Debris:AddItem(soundClone, sound.TimeLength)
end

function hitbox.new(hitboxCreatorCharacter: Model, hitboxSize: Vector3, hitboxCFrame: CFrame, hitboxDamage: number, blockable, externalRegistry)
	if debugOn then
		print("debug")
		local part = Instance.new("Part")
		part.Size = hitboxSize
		part.CFrame = hitboxCFrame
		part.Color = Color3.fromRGB(255, 0, 0)
		part.Material = Enum.Material.SmoothPlastic
		part.CanCollide = false
		part.Anchored = true
		part.CanTouch = false
		part.CanQuery = false
		part.Massless = true
		part.Transparency = .8
		part.Parent = workspace
		
		Debris:AddItem(part, .5)
	end
	
	local hitboxCreatorHRP = hitboxCreatorCharacter:FindFirstChild("HumanoidRootPart")
	local attackerTool = hitboxCreatorCharacter:FindFirstChildOfClass("Tool")
	local attackerHum = hitboxCreatorCharacter:FindFirstChild("Humanoid")
	print(tostring(hitboxSize))
	if not hitboxCreatorHRP or not attackerTool or not attackerHum then warn("a") return end

	local params = OverlapParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	params.FilterDescendantsInstances = {hitboxCreatorCharacter}

	local hitboxParts = workspace:GetPartBoundsInBox(hitboxCFrame, hitboxSize, params)

	local hitRegistery = externalRegistry or {}

	for _, v in ipairs(hitboxParts) do
		local enemyChr = v:FindFirstAncestorOfClass("Model")

		if enemyChr then
			print("enemy chr")
			local enemyHum = enemyChr:FindFirstChildOfClass("Humanoid")
			local enemyAnimator = enemyHum and enemyHum:FindFirstChildOfClass("Animator")
			local enemyHRP = enemyChr:FindFirstChild("HumanoidRootPart")

			if enemyHum and enemyAnimator and enemyHRP and enemyHum.Health > 0 and not hitRegistery[enemyHum] then
				hitRegistery[enemyHum] = true
				print("got them")
				if enemyChr:GetAttribute("Frames") then return end

				local attackDirection = hitboxCreatorHRP.CFrame.LookVector
				local enemyDirection = enemyHRP.CFrame.LookVector
				local dotProduct = attackDirection:Dot(enemyDirection)
				
				if dotProduct > 0.1 and not enemyChr:GetAttribute("Hyperarmor") then					
					for i, v in pairs(enemyAnimator:GetPlayingAnimationTracks()) do
						v:Stop()
					end
					
					enemyChr:SetAttribute("CanAttack", false)
					enemyChr:SetAttribute("Parrying", false)
					enemyChr:SetAttribute("Blocking", false)
					
					enemyHum.WalkSpeed = 1
					enemyHum.JumpHeight = 0
					
					local currentCombo = hitboxCreatorCharacter:GetAttribute("CurrentCombo")
					local hitAnim = hitAnims[currentCombo]

					local track = enemyAnimator:LoadAnimation(hitAnim)
					track:Play()
					
					for i, v: Instance in ipairs(workspace:GetDescendants()) do
						if v:IsA("Humanoid") then
							v.RequiresNeck = false
							v.BreakJointsOnDeath = false
						end
					end
					
					enemyHum:TakeDamage(hitboxDamage)
					bloodHit(enemyHRP)
					
					if currentCombo ~= 5 then
						task.delay(track.Length + 0.1, function()
							if enemyChr and enemyChr.Parent then
								enemyHum.WalkSpeed = 16
								enemyHum.JumpHeight = 7.2
								enemyChr:SetAttribute("CanAttack", true)
								enemyChr:SetAttribute("CanBlock", true)
							end
						end)

					elseif currentCombo == 5 then
						local lv = Instance.new("LinearVelocity")
						local at = Instance.new("Attachment", enemyHRP)
						lv.Attachment0 = at
						lv.MaxForce = math.huge
						lv.VectorVelocity = -enemyHRP.CFrame.LookVector * 50
						lv.Parent = enemyHRP
						Debris:AddItem(lv, 0.5)
						Debris:AddItem(at, 0.5)

						task.delay(.5, function()
							if enemyChr and enemyChr.Parent then
								enemyHum.WalkSpeed = 16
								enemyHum.JumpHeight = 7.2
								enemyChr:SetAttribute("CanAttack", true)
								enemyChr:SetAttribute("CanBlock", true)
							end
						end)
					end
					return
				end

				local parrying = enemyChr:GetAttribute("Parrying")
				local blocking = enemyChr:GetAttribute("Blocking")

				local enemyTool = enemyChr:FindFirstChildOfClass("Tool")
				local enemyToolName = enemyTool and enemyTool.Name

				if parrying then
					print("Parry Success")
					local plrs = game:GetService("Players")
					vignette(plrs:GetPlayerFromCharacter(hitboxCreatorCharacter))
					vignette(plrs:GetPlayerFromCharacter(enemyChr))

					hitboxCreatorCharacter:SetAttribute("CanAttack", false)
					hitboxCreatorCharacter:SetAttribute("CanM1", false)
					hitboxCreatorCharacter:SetAttribute("Stunned", true)

					enemyChr:SetAttribute("CanAttack", false)
					enemyChr:SetAttribute("ParryStatus", true)

					for _, trk in pairs(enemyAnimator:GetPlayingAnimationTracks()) do trk:Stop() end
					for _, trk in pairs(attackerHum.Animator:GetPlayingAnimationTracks()) do trk:Stop() end

					local enemyParryAnim = combatAnims.Staff.Parry
					local attackerParryAnim = combatAnims.Staff.Parry

					if enemyParryAnim and attackerParryAnim then
						local track = enemyAnimator:LoadAnimation(enemyParryAnim)
						local track2 = attackerHum.Animator:LoadAnimation(attackerParryAnim)
						track:Play()
						track2:Play()

						enemyHum.WalkSpeed = 5; enemyHum.JumpHeight = 0
						attackerHum.WalkSpeed = 5; attackerHum.JumpHeight = 0

						enemyChr:SetAttribute("Frames", true)
						enemyChr:SetAttribute("Parrying", false)
						enemyChr:SetAttribute("Blocking", false)
						enemyChr:SetAttribute("BlockCount", 4)

						local vfxClone = parryVFX:Clone()
						vfxClone.Parent = enemyHRP
						vfxClone.WorldCFrame = enemyHRP.CFrame * CFrame.new(0, 0, -3)
						vfxMod.new(vfxClone)

						local parryClone = parrySound:Clone()
						parryClone.Parent = enemyHRP
						parryClone:Play()
						Debris:AddItem(parryClone, parryClone.TimeLength)

						task.delay(.5, function()
							if enemyChr and enemyChr.Parent then
								enemyChr:SetAttribute("CanAttack", true)
								enemyChr:SetAttribute("CanBlock", true)
								enemyChr:SetAttribute("Frames", false)
								enemyChr:SetAttribute("ParryStatus", false)
								enemyHum.WalkSpeed = 16
								enemyHum.JumpHeight = 7.2
							end

							if hitboxCreatorCharacter and hitboxCreatorCharacter.Parent then
								hitboxCreatorCharacter:SetAttribute("CanAttack", true)
								hitboxCreatorCharacter:SetAttribute("CanM1", true)
								hitboxCreatorCharacter:SetAttribute("Stunned", false)
								attackerHum.WalkSpeed = 16
								attackerHum.JumpHeight = 7.2
							end
						end)
					end

				elseif blocking then
					local blockCount = enemyChr:GetAttribute("BlockCount") or 0

					if blockCount <= 1 or not blockable then
						for _, trk in pairs(enemyAnimator:GetPlayingAnimationTracks()) do trk:Stop() end
						local track = enemyAnimator:LoadAnimation(guardBreakAnim)
						track:Play()
			
						enemyChr:SetAttribute("Parrying", false)
						enemyChr:SetAttribute("Blocking", false)
						enemyChr:SetAttribute("CanAttack", false)
						enemyChr:SetAttribute("BlockCount", 4)

						enemyHum.WalkSpeed = 3
						enemyHum.JumpHeight = 0
						
						local plrs = game:GetService("Players")
						vignette(plrs:GetPlayerFromCharacter(enemyChr))

						local vfxClone = guardBreakVFX:Clone()
						vfxClone.Parent = enemyHRP
						vfxClone.WorldCFrame = enemyHRP.CFrame * CFrame.new(0, 0, -3)
						vfxMod.new(vfxClone)

						local breakClone = breakSound:Clone()
						breakClone.Parent = enemyHRP
						breakClone:Play()
						Debris:AddItem(breakClone, breakClone.TimeLength)

						enemyHum:TakeDamage(hitboxDamage)
						bloodHit(enemyHRP)

						task.delay(2.5, function()
							if enemyChr and enemyChr.Parent then
								enemyHum.WalkSpeed = 16
								enemyHum.JumpHeight = 7.2
								enemyChr:SetAttribute("CanAttack", true)
								enemyChr:SetAttribute("CanBlock", true)
								enemyChr:SetAttribute("Frames", false)
							end
						end)

					else
						local blockHitAnim = combatAnims:FindFirstChild(enemyToolName) and combatAnims[enemyToolName]:FindFirstChild("BlockHit")
						if blockHitAnim then
							local track = enemyAnimator:LoadAnimation(blockHitAnim)
							track:Play()
						end

						local blockClone = blockSound:Clone()
						blockClone.Parent = enemyHRP
						blockClone:Play()
						Debris:AddItem(blockClone, blockClone.TimeLength)

						enemyChr:SetAttribute("BlockCount", blockCount - 1)
						enemyChr:SetAttribute("LastBlock", tick())
					end
				end

				if not parrying and not blocking and not enemyChr:GetAttribute("Frames") then
					if enemyChr:GetAttribute("Hyperarmor") then
						enemyHum:TakeDamage(hitboxDamage)
						bloodHit(enemyHRP)
					else
						enemyHum.WalkSpeed = 1
						enemyHum.JumpHeight = 0
						enemyChr:SetAttribute("CanAttack", false)
						for _, trk in ipairs(enemyAnimator:GetPlayingAnimationTracks()) do
							trk:Stop()
						end
						
						local currentCombo = hitboxCreatorCharacter:GetAttribute("CurrentCombo")
						local hitAnim = hitAnims[currentCombo]

						local track = enemyAnimator:LoadAnimation(hitAnim)
						track:Play()

						enemyHum:TakeDamage(hitboxDamage)
						bloodHit(enemyHRP)

						if currentCombo ~= 5 then
							task.delay(track.Length + 0.1, function()
								if enemyChr and enemyChr.Parent then
									enemyHum.WalkSpeed = 16
									enemyHum.JumpHeight = 7.2
									enemyChr:SetAttribute("CanAttack", true)
								end
							end)
							
						elseif currentCombo == 5 then
							local plrs = game:GetService("Players")
							vignette(plrs:GetPlayerFromCharacter(enemyChr))
							local lv = Instance.new("LinearVelocity")
							local at = Instance.new("Attachment", enemyHRP)
							lv.Attachment0 = at
							lv.MaxForce = math.huge
							lv.VectorVelocity = -enemyHRP.CFrame.LookVector * 50
							lv.Parent = enemyHRP
							Debris:AddItem(lv, 0.5)
							Debris:AddItem(at, 0.5)
							
							task.delay(.5, function()
								if enemyChr and enemyChr.Parent then
									enemyHum.WalkSpeed = 16
									enemyHum.JumpHeight = 7.2
									enemyChr:SetAttribute("CanAttack", true)
								end
							end)
						end
					end
				end
			end
		end
	end
end

return hitbox

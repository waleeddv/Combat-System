--//services
local Plrs = game:GetService("Players")
local RepStorage = game:GetService("ReplicatedStorage")
local SSS = game:GetService("ServerScriptService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")

--//refs
local anims = RepStorage:WaitForChild("Animations")
local combatAnims = anims:WaitForChild("Combat")
local event = RepStorage:WaitForChild("Remotes"):WaitForChild("WeaponFire")

local vfxFolder = RepStorage:WaitForChild("VFX")
local vanishVFX = vfxFolder:WaitForChild("VanishDodge")
local jumpVFX = vfxFolder:WaitForChild("JumpAttack")
local swing = RepStorage:WaitForChild("Swing")
local feint = RepStorage:WaitForChild("Feint")
local event2 = RepStorage:WaitForChild("Remotes"):WaitForChild("DashFeint")

--//mods
local vfxMod = require(SSS:WaitForChild("VFXEmitter"))
local hitboxMod = require(SSS:WaitForChild("HitboxCreator"))

--//vars
local plrObjs = {}

--//combat
local CombatHandler = {}
CombatHandler.__index = CombatHandler

type self = {
	Chr: Model,
	Hum: Humanoid,
	HRP: BasePart,
	Animator: Animator,
	Plr: Player,
	CurrentCombo: number,
	LastAttackTime: number,
	CurrentAttackID: string
}

local function vignette(plr: Player)
	local plrUi = plr.PlayerGui
	local image = plrUi.Vignette.ImageLabel
	
	local tweenService = game:GetService("TweenService")
	
	local tween = TweenService:Create(image, TweenInfo.new(.2), {ImageTransparency = .2})
	tween:Play()
	
	tween.Completed:Connect(function()
		local tween = TweenService:Create(image, TweenInfo.new(.2), {ImageTransparency = 1})
		tween:Play()
	end)
end

function CombatHandler.New(plr: Player)
	local self = setmetatable({}::self, CombatHandler)
	self.Plr = plr

	local function setupCharacter(chr)
		self.Chr = chr
		self.Hum = chr:WaitForChild("Humanoid")
		self.HRP = chr:WaitForChild("HumanoidRootPart")
		self.Animator = self.Hum:WaitForChild("Animator")
		self.CurrentCombo = 1
		self.LastAttackTime = 0
		self.CurrentAttackID = ""
		
		-- // CONFIGURATION \\ --
		
		--// M1
		self.M1Damage = 5
		self.M1HitboxSize = Vector3.new(5, 5, 5)
		
		--// Aerial M1
		self.AerialM1Damage = 5
		self.AerialM1HitboxSize = Vector3.new(20, 20, 20)
		
		--// Crit
		self.CritDamage = 10
		self.CritHitboxSize = Vector3.new(5, 5, 5)
		
		--// Aerial Crit
		self.AerialCritDamage = 10
		self.AerialCritHitboxSize = Vector3.new(20, 20, 20)
		
		--// Parry & block
		self.ParryThreshold = 0.3
		self.BlockCD = .5
		
		--// Vanish Dodge
		self.VanishDodgeWalkSpeed = 30
	end

	if plr.Character then setupCharacter(plr.Character) end
	plr.CharacterAdded:Connect(setupCharacter)

	return self
end

local function clean(...)
	for _, conn in ipairs({...}) do
		if conn then conn:Disconnect() end
	end
end

function CombatHandler:Feint()
	if not self.Chr or not self.Chr.Parent or not self.Chr:FindFirstChildOfClass("Tool") then return end
	self = self :: self

	local m1Feintable = self.Chr:GetAttribute("M1Feintable")
	local critFeintable = self.Chr:GetAttribute("CritFeintable")
	local dashFeintable = self.Chr:GetAttribute("DashFeint")

	local canM1Feint = self.Chr:GetAttribute("CanM1Feint")
	local canCritFeint = self.Chr:GetAttribute("CanCritFeint")
	local candashFeint = self.Chr:GetAttribute("CanDashFeint")

	if (m1Feintable and canM1Feint) or (critFeintable and canCritFeint) or (candashFeint and dashFeintable) then

		if m1Feintable then
			self.Chr:SetAttribute("CanM1Feint", false)
			task.delay(2, function() if self.Chr then self.Chr:SetAttribute("CanM1Feint", true) end end)
		elseif critFeintable then
			self.Chr:SetAttribute("CanCritFeint", false)
			task.delay(2, function() if self.Chr then self.Chr:SetAttribute("CanCritFeint", true) end end)
		elseif dashFeintable then
			self.Chr:SetAttribute("CanDashFeint", false)
			task.delay(2, function() if self.Chr then self.Chr:SetAttribute("CanDashFeint", true) end end)
		end

		for _, track in ipairs(self.Animator:GetPlayingAnimationTracks()) do
			if string.find(track.Name, "Combo") or track.Name == "Crit" then
				track:Stop()
			end
		end
		
		if dashFeintable then
			event2:FireClient(self.Plr)
			
			local highlight = Instance.new("Highlight")
			highlight.Parent = self.Chr
			highlight.FillTransparency = 1
			highlight.OutlineTransparency = .6
			
			task.delay(.2, function()
				if highlight then highlight:Destroy() end
			end)
			
			local vfxClone = RepStorage:WaitForChild("VFX"):WaitForChild("CancelDodge"):Clone()
			vfxClone.Parent = self.HRP
			vfxMod.new(vfxClone)
		end

		print("Feint successful")
		
		local sound = feint:Clone()
		sound.Parent = self.HRP
		sound:Play()
		game:GetService("Debris"):WaitForChild(sound, sound.TimeLength)
		
		self.CurrentAttackID = HttpService:GenerateGUID(false) 

		self.Chr:SetAttribute("CanAttack", true)
		self.Chr:SetAttribute("M1Feintable", false)
		self.Chr:SetAttribute("CritFeintable", false)
		self.Chr:SetAttribute("CanM1", true)
		self.Chr:SetAttribute("CanCrit", true)
		self.Hum.WalkSpeed = 16
	end
end

function CombatHandler:M1()
	self = self :: self
	if not self.Chr or not self.Chr:GetAttribute("CanM1") or not self.Chr:GetAttribute("CanAttack") then return end
	if self.Chr:GetAttribute("Stunned") then return end

	local equippedTool = self.Chr:FindFirstChildOfClass("Tool"); if not equippedTool then return end

	local thisAttackID = HttpService:GenerateGUID(false)
	self.CurrentAttackID = thisAttackID

	self.Chr:SetAttribute("CanAttack", false)
	self.Chr:SetAttribute("CanM1", false)
	self.Chr:SetAttribute("M1Feintable", true)
	self.Hum.WalkSpeed = 8

	local swingCLone = swing:Clone()
	swingCLone.Parent = self.HRP
	swingCLone:Play()
	game:GetService("Debris"):AddItem(swingCLone, swingCLone.TimeLength)

	local toolName = equippedTool.Name
	local currentCombo = self.CurrentCombo
	local attackTime = os.clock()
	self.LastAttackTime = attackTime

	task.delay(4, function()
		if self.LastAttackTime == attackTime then 
			self.CurrentCombo = 1 
		end
	end)

	local animation
	for _, v in ipairs(anims:GetDescendants()) do
		if v:IsA("Animation") and v.Name == "Combo"..tostring(self.CurrentCombo) and v.Parent.Name == toolName then 
			animation = v 
			break 
		end
	end

	if not animation then 
		self.Chr:SetAttribute("CanAttack", true); self.Chr:SetAttribute("CanM1", true) 
		return 
	end

	local track = self.Animator:LoadAnimation(animation)
	track:Play()
	
	self.Chr:SetAttribute("CurrentCombo", self.CurrentCombo)

	local conns = {}
	local hitRegistery = {}
	local hasHitMarkerFired = false 

	local s = os.clock()
	repeat task.wait() until track.Length > 0 or os.clock() - s > 1
	local length = track.Length > 0 and track.Length or 0.5

	task.delay(length, function()
		if self.CurrentAttackID ~= thisAttackID then return end
		if self.Chr:GetAttribute("Stunned") then return end
		if not self.Chr or not self.Chr.Parent then return end

		self.Chr:SetAttribute("CanM1", true)
		self.Chr:SetAttribute("M1Feintable", false)
		if self.Hum.WalkSpeed ~= 16 then self.Hum.WalkSpeed = 16 end

		if self.CurrentCombo == 5 then
			task.delay(.5, function()
				if self.Chr then
					self.CurrentCombo = 1
					self.Chr:SetAttribute("CanAttack", true)
				end
			end)
		else
			self.CurrentCombo += 1
			self.Chr:SetAttribute("CanAttack", true)
		end
	end)

	conns.Stopped = track.Stopped:Connect(function()
		clean(conns.Stopped, conns.Feint, conns.Hit)
		if self.CurrentAttackID == thisAttackID then
			self.Chr:SetAttribute("M1Feintable", false)
		end
	end)

	conns.Feint = track:GetMarkerReachedSignal("FeintEnd"):Connect(function()
		if self.CurrentAttackID == thisAttackID and self.Chr then
			self.Chr:SetAttribute("M1Feintable", false)
		end
	end)

	conns.Hit = track:GetMarkerReachedSignal("Hit"):Connect(function()
		if hasHitMarkerFired then return end
		hasHitMarkerFired = true
		clean(conns.Feint)

		if self.CurrentAttackID ~= thisAttackID then return end
		if not self.Chr or self.Chr:GetAttribute("Stunned") then return end

		hitboxMod.new(self.Chr, self.M1HitboxSize, self.HRP.CFrame * CFrame.new(0, 0, -3), self.M1Damage, true, hitRegistery)
	end)
end

function CombatHandler:AerialM1()
	self = self :: self
	if not self.Chr or not self.Chr:GetAttribute("CanM1") or not self.Chr:GetAttribute("CanAttack") then return end
	if not self.Chr:GetAttribute("CanM1Aerial") then return end
	if self.Chr:GetAttribute("Stunned") then return end

	local equippedTool = self.Chr:FindFirstChildOfClass("Tool"); if not equippedTool then return end
	
	local vfxClone2 = RepStorage:WaitForChild("VFX"):WaitForChild("RunningAttackAndJumpAttack"):Clone()
	vfxClone2.Parent = self.HRP
	vfxClone2.CFrame = self.HRP.CFrame
	local weldConstraint = Instance.new("WeldConstraint")
	weldConstraint.Parent = vfxClone2
	weldConstraint.Part1 = vfxClone2
	weldConstraint.Part0 = self.HRP
	task.delay(1.5, function()
		vfxClone2.Beam38.Enabled = false
		task.wait(.5)
		vfxClone2:Destroy()
	end)
	
	local thisAttackID = HttpService:GenerateGUID(false)
	self.CurrentAttackID = thisAttackID

	self.Chr:SetAttribute("CanM1", false)
	self.Chr:SetAttribute("CanM1Aerial", false)
	self.Chr:SetAttribute("CanAttack", false)
	local toolName = equippedTool.Name

	local animation
	for _, v in ipairs(anims:GetDescendants()) do
		if v:IsA("Animation") and v.Name == "AerialM1" and v.Parent.Name == toolName then animation = v break end
	end

	local track = self.Animator:LoadAnimation(animation)
	if animation.Parent.Name == "Staff" then
		track:Play(.1, 1, .7)
	else
		track:Play(.1, 1, 1.9)
	end

	local vfxClone = jumpVFX:Clone()
	vfxClone.Parent = self.HRP
	vfxClone.CFrame = CFrame.new(0, -10, 0)
	vfxMod.new(vfxClone)

--[[local lv = Instance.new("LinearVelocity")
	local at = Instance.new("Attachment", self.HRP)
	lv.Attachment0 = at
	lv.MaxForce = math.huge
	lv.Parent = self.HRP

	if toolName == "Staff" then
		lv.VectorVelocity = self.HRP.CFrame.LookVector * 30 + Vector3.new(0, 25, 0) 
		task.delay(.18, function() if lv then lv:Destroy() end; if at then at:Destroy() end end)
	elseif toolName == "Katana" then
		lv.VectorVelocity = self.HRP.CFrame.LookVector * 30 + Vector3.new(0, 25, 0) 
		task.delay(.9, function() if lv then lv:Destroy() end; if at then at:Destroy() end end)
	end]]

	event:FireClient(self.Plr, "AirM1")

	local conns = {}
	local hitRegistery = {}
	local hasHitMarkerFired = false

	local s = os.clock()
	repeat task.wait() until track.Length > 0 or os.clock() - s > 1
	local length = track.Length > 0 and track.Length or 1

	task.delay(length, function()
		if self.CurrentAttackID ~= thisAttackID or self.Chr:GetAttribute("Stunned") then return end

		self.Chr:SetAttribute("CanAttack", true)
		self.Chr:SetAttribute("CanM1", true)
		self.CurrentCombo = 1
		self.Hum.WalkSpeed = 16
		self.Hum.JumpHeight = 7.2

		task.delay(2.5, function() if self.Chr then self.Chr:SetAttribute("CanM1Aerial", true) end end)
	end)

	conns.Stopped = track.Stopped:Connect(function()
		clean(conns.Stopped, conns.Hit)
	end)

	conns.Hit = track:GetMarkerReachedSignal("Hit"):Connect(function()
		if hasHitMarkerFired then return end
		hasHitMarkerFired = true
		clean(conns.Hit)
		if self.CurrentAttackID ~= thisAttackID or self.Chr:GetAttribute("Stunned") then return end
		task.wait(0)
		hitboxMod.new(self.Chr, self.AerialM1HitboxSize, self.HRP.CFrame, self.AerialM1Damage, true, hitRegistery)
	end)
end

function CombatHandler:Crit()
	if not self.Chr or not self.Chr:GetAttribute("CanCrit") or not self.Chr:GetAttribute("CanAttack") then return end
	if self.Chr:GetAttribute("Stunned") then return end

	local equippedTool = self.Chr:FindFirstChildOfClass("Tool"); if not equippedTool then return end

	local thisAttackID = HttpService:GenerateGUID(false)
	self.CurrentAttackID = thisAttackID

	self.Chr:SetAttribute("CanCrit", false)
	self.Chr:SetAttribute("CanAttack", false)
	self.Chr:SetAttribute("CritFeintable", true)
	local toolName = equippedTool.Name

	local animation
	for _, v in ipairs(anims:GetDescendants()) do
		if v:IsA("Animation") and v.Name == "Crit" and v.Parent.Name == toolName then animation = v break end
	end

	local track = self.Animator:LoadAnimation(animation)
	track:Play()

	local lv = Instance.new("LinearVelocity")
	local at = Instance.new("Attachment", self.HRP)
	lv.Attachment0 = at
	lv.VectorVelocity = self.HRP.CFrame.LookVector * 30
	lv.MaxForce = math.huge
	lv.Parent = self.HRP

	self.Hum.WalkSpeed = 0
	self.Hum.JumpHeight = 0
	
	local critVFX = vfxFolder:WaitForChild("CritVFX"):Clone()
	critVFX.Parent = self.HRP
	critVFX.CFrame = CFrame.new(0, -2.849, 0)
	vfxMod.new(critVFX)

	task.delay(.2, function()
		if lv then lv:Destroy() end; if at then at:Destroy() end
	end)

	local conns = {}
	local hitRegistery = {}
	local hasHitMarkerFired = false

	local s = os.clock()
	repeat task.wait() until track.Length > 0 or os.clock() - s > 1
	local length = track.Length > 0 and track.Length or 1

	task.delay(length, function()
		if self.CurrentAttackID ~= thisAttackID or self.Chr:GetAttribute("Stunned") then return end

		self.Chr:SetAttribute("CanAttack", true)
		print("set crit to true")
		self.Hum.WalkSpeed = 16
		self.Hum.JumpHeight = 7.2

		task.delay(2.5, function() if self.Chr then self.Chr:SetAttribute("CanCrit", true) end end)
	end)

	conns.Stopped = track.Stopped:Connect(function()
		clean(conns.Stopped, conns.Feint, conns.Hit)
		if lv then lv:Destroy() end; if at then at:Destroy() end
		if self.CurrentAttackID == thisAttackID then
			self.Chr:SetAttribute("CritFeintable", false)
		end
	end)

	conns.Feint = track:GetMarkerReachedSignal("FeintEnd"):Connect(function()
		if self.CurrentAttackID == thisAttackID and self.Chr then
			self.Chr:SetAttribute("CritFeintable", false)
		end
	end)

	conns.Hit = track:GetMarkerReachedSignal("Hit"):Connect(function()
		if hasHitMarkerFired then return end
		hasHitMarkerFired = true
		clean(conns.Feint)

		if self.CurrentAttackID ~= thisAttackID or self.Chr:GetAttribute("Stunned") then return end
		if lv then lv:Destroy() end; if at then at:Destroy() end

		hitboxMod.new(self.Chr, self.CritHitboxSize, self.HRP.CFrame * CFrame.new(0, 0, -3), self.CritDamage, false, hitRegistery)
	end)
end

function CombatHandler:AerialCrit()
	self = self :: self
	if not self.Chr or not self.Chr:GetAttribute("CanCrit") or not self.Chr:GetAttribute("CanAttack") then return end
	if self.Chr:GetAttribute("Stunned") then return end

	local equippedTool = self.Chr:FindFirstChildOfClass("Tool"); if not equippedTool then return end

	local thisAttackID = HttpService:GenerateGUID(false)
	self.CurrentAttackID = thisAttackID

	self.Chr:SetAttribute("CanCrit", false)
	self.Chr:SetAttribute("CanAttack", false)
	self.Chr:SetAttribute("Hyperarmor", true)
	local toolName = equippedTool.Name

	local animation
	for _, v in ipairs(anims:GetDescendants()) do
		if v:IsA("Animation") and v.Name == "AerialCrit" and v.Parent.Name == toolName then animation = v break end
	end

	local track = self.Animator:LoadAnimation(animation)
	track:Play()

	local vfxClone = jumpVFX:Clone()
	vfxClone.Parent = self.HRP
	vfxClone.CFrame = CFrame.new(0, -10, 0)
	vfxMod.new(vfxClone)

	local highlight = Instance.new("Highlight")
	highlight.Parent = self.Chr
	highlight.FillTransparency = 1
	highlight.OutlineTransparency = .6

	self.Hum.WalkSpeed = 0
	self.Hum.JumpHeight = 0

	local lv = Instance.new("LinearVelocity")
	local at = Instance.new("Attachment", self.HRP)
	lv.Attachment0 = at
	lv.MaxForce = math.huge
	lv.Parent = self.HRP

	if toolName == "Staff" then
		lv.VectorVelocity = Vector3.new(0, 50, 0) 
		task.delay(.5, function() if lv then lv:Destroy() end; if at then at:Destroy() end end)
	elseif toolName == "Katana" then
		lv.VectorVelocity = self.HRP.CFrame.LookVector * 30 + Vector3.new(0, 25, 0) 
		task.delay(.5, function() if lv then lv:Destroy() end; if at then at:Destroy() end end)
	end

	local conns = {}
	local hitRegistery = {}
	local hasHitMarkerFired = false

	local s = os.clock()
	repeat task.wait() until track.Length > 0 or os.clock() - s > 1
	local length = track.Length > 0 and track.Length or 1

	task.delay(length, function()
		if self.CurrentAttackID ~= thisAttackID or self.Chr:GetAttribute("Stunned") then return end

		self.Chr:SetAttribute("CanAttack", true)
		self.Chr:SetAttribute("Hyperarmor", false)
		if highlight then highlight:Destroy() end
		self.Hum.WalkSpeed = 16
		self.Hum.JumpHeight = 7.2

		task.delay(2.5, function() if self.Chr then self.Chr:SetAttribute("CanCrit", true) end end)
	end)

	conns.Stopped = track.Stopped:Connect(function()
		clean(conns.Stopped, conns.Hit)
		if lv then lv:Destroy() end; if at then at:Destroy() end

		if self.CurrentAttackID == thisAttackID then
			self.Chr:SetAttribute("Hyperarmor", false)
		end
		if highlight then highlight:Destroy() end
	end)

	conns.Hit = track:GetMarkerReachedSignal("Hit"):Connect(function()
		if hasHitMarkerFired then return end
		hasHitMarkerFired = true
		clean(conns.Hit)
		if self.CurrentAttackID ~= thisAttackID or self.Chr:GetAttribute("Stunned") then return end
		if lv then lv:Destroy() end; if at then at:Destroy() end

		hitboxMod.new(self.Chr, self.AerialCritHitboxSize, self.HRP.CFrame, self.AerialCritDamage, false, hitRegistery)
	end)
end

function CombatHandler:Block(start)
	if not self.Chr then return end

	if start then
		if not self.Chr:GetAttribute("CanAttack") or not self.Chr:GetAttribute("CanBlock") then return end
		if self.Chr:GetAttribute("Stunned") then return end
		if self.Chr:GetAttribute("Parrying") or self.Chr:GetAttribute("Blocking") then return end

		local equippedTool = self.Chr:FindFirstChildOfClass("Tool"); if not equippedTool then return end
				
		local toolName = equippedTool.Name
		local startBlockAnim, loopBlockAnim
		for _, v in ipairs(anims:GetDescendants()) do
			if v:IsA("Animation") and v.Parent.Name == toolName then
				if v.Name == "StartBlock" then startBlockAnim = v end
				if v.Name == "Block" then loopBlockAnim = v end
			end
		end

		if not startBlockAnim or not loopBlockAnim then return end

		self.Chr:SetAttribute("CanAttack", false)
		self.Chr:SetAttribute("CanBlock", false)
		self.Chr:SetAttribute("Parrying", true)
		self.Hum.JumpHeight = 0
		self.Hum.WalkSpeed = 4

		local track = self.Animator:LoadAnimation(startBlockAnim)
		track:Play()

		local conns = {}
		local transitioned = false

		local function startLoop()
			if transitioned then return end
			transitioned = true
			if conns.Marker then conns.Marker:Disconnect() end
			if conns.Stopped then conns.Stopped:Disconnect() end

			if self.Chr:GetAttribute("Parrying") or self.Chr:GetAttribute("Blocking") then
				track:Stop()
				local track2 = self.Animator:LoadAnimation(loopBlockAnim)
				track2:Play()
			end
		end

		conns.Marker = track:GetMarkerReachedSignal("Start"):Connect(startLoop)
		conns.Stopped = track.Stopped:Connect(startLoop)

		task.delay(self.ParryThreshold, function()
			if self.Chr and self.Chr:GetAttribute("Parrying") then
				self.Chr:SetAttribute("Blocking", true)
				self.Chr:SetAttribute("Parrying", false)
			end
		end)

	elseif not start then
		local wasBlocking = self.Chr:GetAttribute("Blocking")
		local wasParrying = self.Chr:GetAttribute("Parrying")

		if not wasBlocking and not wasParrying then return end

		for _, v in pairs(self.Animator:GetPlayingAnimationTracks()) do
			if string.find(v.Name, "Block") then v:Stop() end
		end

		self.Hum.JumpHeight = 7.2
		self.Hum.WalkSpeed = 16
		self.Chr:SetAttribute("Blocking", false)
		self.Chr:SetAttribute("Parrying", false)
		self.Chr:SetAttribute("CanAttack", true)
		
		task.delay(self.BlockCD, function() self.Chr:SetAttribute("CanBlock", true) end)
	end
end

function CombatHandler:Emote(start)
	if not self.Chr then return end

	if start then
		if not self.Chr:GetAttribute("CanAttack") or self.Chr:GetAttribute("EmotePlaying") or not self.Chr:GetAttribute("CanEmote") then return end

		self.Chr:SetAttribute("EmotePlaying", true)
		self.Chr:SetAttribute("CanEmote", false)

		local tool = self.Chr:FindFirstChildOfClass("Tool"); if not tool then return end
		local toolName = tool.Name; if toolName ~= "Staff" then return end

		self.Hum.WalkSpeed = 0
		self.Hum.JumpHeight = 0

		local animation = combatAnims.Styles.Staff.V
		local track = self.Animator:LoadAnimation(animation)
		track:Play()

		local conns = {}

		local thisAttackID = HttpService:GenerateGUID(false)
		self.CurrentAttackID = thisAttackID

		conns.Played = self.Animator.AnimationPlayed:Connect(function(animTrack)
			if animTrack == track then return end
			clean(conns.Played, conns.Stopped)
			track:Stop()

			if self.CurrentAttackID == thisAttackID then
				self.Chr:SetAttribute("EmotePlaying", false)
				self.Hum.WalkSpeed = 16
				self.Hum.JumpHeight = 7.2
				task.delay(.5, function() if self.Chr then self.Chr:SetAttribute("CanEmote", true) end end)
			end
		end)

		conns.Stopped = track.Stopped:Connect(function()
			clean(conns.Played, conns.Stopped)
			if self.CurrentAttackID == thisAttackID then
				self.Hum.WalkSpeed = 16
				self.Hum.JumpHeight = 7.2
				self.Chr:SetAttribute("EmotePlaying", false)
				task.delay(.5, function() if self.Chr then self.Chr:SetAttribute("CanEmote", true) end end)
			end
		end)

	else
		if not self.Chr:GetAttribute("EmotePlaying") then return end

		for _, v in pairs(self.Animator:GetPlayingAnimationTracks()) do
			if v.Animation.AnimationId == combatAnims.Styles.Staff.V.AnimationId then
				v:Stop()
			end
		end
	end	
end

function CombatHandler:VanishDodge()
	if not self.Chr then return end
	if not self.Chr:FindFirstChildOfClass("Tool") then return end
	if not self.Chr:GetAttribute("CanAttack") then return end
	if self.Chr:GetAttribute("Stunned") then return end
	self = self :: self
	local val = self.Chr:GetAttribute("VanishDodge")
	if not val or val <= 0 then return end
	
	self.Chr:SetAttribute("Frames", true)
	self.Chr:SetAttribute("CanAttack", false)
	self.Chr:SetAttribute("VanishDodge", val - 1)

	self.Hum.WalkSpeed = self.VanishDodgeWalkSpeed

	local vfxClone = vanishVFX:Clone()
	vfxClone.Parent = self.HRP
	vfxMod.new(vfxClone)
	
	vignette(self.Plr)
	local soundClone = RepStorage:WaitForChild("Dodge"):Clone()
	soundClone.Parent = self.HRP
	soundClone:Play()
	game:GetService("Debris"):AddItem(soundClone, soundClone.TimeLength)

	local partProperties = {}

	for _, v in ipairs(self.Chr:GetDescendants()) do
		if v:IsA("BasePart") and v.Name ~= "HumanoidRootPart" then
			partProperties[v] = {Transparency = v.Transparency, CanCollide = v.CanCollide}
			v.CanCollide = false
			TweenService:Create(v, TweenInfo.new(.2), {Transparency = 1}):Play()
		elseif v:IsA("Decal") then
			partProperties[v] = {Transparency = v.Transparency}
			TweenService:Create(v, TweenInfo.new(.2), {Transparency = 1}):Play()
		end
	end

	task.delay(.4, function()
		if not self.Chr then return end
		for obj, props in pairs(partProperties) do
			if obj and obj.Parent then
				TweenService:Create(obj, TweenInfo.new(.2), {Transparency = props.Transparency}):Play()
			end
		end
	end)

	task.delay(.8, function()
		if not self.Chr then return end
		for obj, props in pairs(partProperties) do
			if obj:IsA("BasePart") and obj.Parent then
				obj.CanCollide = props.CanCollide
			end
		end
		self.Chr:SetAttribute("Frames", false)
		self.Chr:SetAttribute("CanAttack", true)
		self.Hum.WalkSpeed = 16
	end)
end

event.OnServerEvent:Connect(function(plr, attack, inAir, start)
	if not plrObjs[plr] then return end

	if attack == "M1" and not inAir then
		plrObjs[plr]:M1()
	elseif attack == "M1" and inAir then
		plrObjs[plr]:AerialM1()
	elseif attack == "Feint" then
		plrObjs[plr]:Feint()
	elseif attack == "Block" then
		plrObjs[plr]:Block(start)
	elseif attack == "Crit" and not inAir then
		plrObjs[plr]:Crit()
	elseif attack == "Crit" and inAir then
		plrObjs[plr]:AerialCrit()
	elseif attack == "VanishDodge" then
		plrObjs[plr]:VanishDodge()
	elseif attack == "Emote" and not inAir then
		if start then plrObjs[plr]:Emote(true) elseif not start then plrObjs[plr]:Emote(false) end
	end
end)

Plrs.PlayerAdded:Connect(function(plr)
	if plrObjs[plr] then return end
	plrObjs[plr] = CombatHandler.New(plr)
end)

Plrs.PlayerRemoving:Connect(function(plr)
	if not plrObjs[plr] then return end
	plrObjs[plr] = nil
end)


local module = {}

local Debris = game:GetService("Debris")
local RunService = game:GetService("RunService")

function module.new(parentInstance: Instance)
	local maxTime = 0
	for i, v in ipairs(parentInstance:GetDescendants()) do
		if v:IsA("ParticleEmitter") then
			v:Emit(v:GetAttribute("EmitCount"))
			if v.Lifetime.Max >= maxTime then
				maxTime = v.Lifetime.Max
			end
		end
	end
	Debris:AddItem(parentInstance, maxTime)
end

return module

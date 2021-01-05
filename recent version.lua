-- Creation date : 7/12/2020
-- Latest Update : 1/2/2021, more optimizations
-- GitHub : St-vn, https://github.com/St-vn
-- Roblox : St_vnC, https://www.roblox.com/users/332398911/profile
-- Discord : St_vn#3931

-- Version 2.4

local active, hitbox = {}, {}
hitbox.__index = hitbox

local rayParams = RaycastParams.new()
rayParams.FilterType = Enum.RaycastFilterType.Blacklist

local emptyVector = Vector3.new()
local emptyTable = {}

function hitbox:Cast(callback, filter)
	local part = self.Part
	local handleCFrame = part.CFrame
	
	self.Filter = filter or emptyTable
	self.Callback = callback
	self.Hit = {}
	
	filter[#filter + 1] = part
	
	for _, info in ipairs(self.Points) do
		info.Previous = handleCFrame * info.Offset
	end

	active[#active + 1] = self
end

function hitbox:Stop()
	self.Callback = nil
	self.Filter = nil
	self.Hit = nil
	self.PrevCF = nil
end

function hitbox:Remove()
	self:Stop()

	for key, value in pairs(self) do
		self[key] = nil
	end
end

game:GetService("RunService").Stepped:Connect(function() -- it is better to handle connections procedurally and to use only 1 connection
	for index, self in ipairs(active) do
		if not self.Callback then table.remove(active, index); continue end
		
		rayParams.FilterDescendantsInstances = self.Filter
		
		local handleCFrame = self.Part.CFrame
		
		if handleCFrame ~= self.PrevCF then
			local hit = self.Hit
			
			for index, info in ipairs(self.Points) do
				local old = info.Previous
				local new = handleCFrame * info.Offset
				local results = workspace:Raycast(old, new - old, rayParams)
				
				info.Previous = new
				
				if results and not hit[results.Instance] then
					local part = results.Instance
					local model = part:FindFirstAncestorWhichIsA("Model")
					
					if model:FindFirstChildWhichIsA("Humanoid") then
						hit[part] = true

						self.Callback(part, model) -- if your callback yields, then it would be a good idea to wrap it 
					end
				end
			end
		end
		
		self.PrevCF = handleCFrame
	end
end)

return function(part, offsets)
	local points = {}
	
	for _, point in ipairs(offsets or part:GetChildren()) do
		if offsets or point.ClassName == "Attachment" and point.Name == "DmgPoint" then
			points[#points + 1] = {Previous = nil, Offset = offsets and point or point.Position}
		end
	end

	return setmetatable({Part = part, Points = points}, hitbox)
end

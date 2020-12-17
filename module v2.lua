-- Creation date : 7/12/2020
-- Latest Update : 17/12/2020, increased accuracy and performance
-- GitHub : St-vn, https://github.com/St-vn
-- Roblox : St_vnC, https://www.roblox.com/users/332398911/profile
-- Discord : St_vn#3931

local active = {}

local hitbox = {}
hitbox.__index = hitbox

local rayParams = RaycastParams.new()
rayParams.FilterType = Enum.RaycastFilterType.Blacklist

local emptyVector = Vector3.new()

function hitbox:Cast(callback, filter)
	self.Callback = callback
	self.Filter = filter or {}
	self.Index = #active + 1
	self.Hit = {}
	
	for _, info in ipairs(self.Attachments) do
		info.Previous = info.Attachment.WorldPosition
	end
	
	table.insert(active, self)
	table.insert(self.Filter, self.Part)
end

function hitbox:Stop()
	table.remove(active, self.Index)

	self.Callback = nil
	self.Filter = nil
	self.Index = nil
	self.Hit = nil
end

function hitbox:Remove()
	self:Stop()

	self.Part = nil
	self.Attachments = nil
end

game:GetService("RunService").Heartbeat:Connect(function() -- it is better to handle connections procedurally and to use only 1 connection
	for _, self in ipairs(active) do
		local hit = self.Hit
		local callback = self.Callback

		rayParams.FilterDescendantsInstances = self.Filter
		
		for index, info in ipairs(self.Attachments) do
			local new = info.Attachment.WorldPosition
			local old = info.Previous
			
			local results = workspace:Raycast(old, new - old, rayParams)
			
			if results and not hit[part] then
				local part = results.Instance -- you could for part detection only, pretty simple to do
				local model = part:FindFirstAncestorWhichIsA("Model")
				local humanoid = model and model:FindFirstChildWhichIsA("Humanoid")
				
				if humanoid then
					hit[part] = true
					callback(part, model, humanoid) -- if your callback yields, then it would be a good idea to wrap it
				end
			end

			info.Previous = new
		end
	end
end)

return function(part)
	local attachments = {}

	for _, attachment in ipairs(part:GetChildren()) do
		if attachment:IsA("Attachment") and attachment.Name == "DmgPoint" then
			table.insert(attachments, {
				Attachment = attachment,
				Previous = nil
			})
		end
	end

	return setmetatable({
		Part = part,
		Attachments = attachments
	}, hitbox)
end

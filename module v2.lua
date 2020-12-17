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
local attachmentName = "DmgPoint"

function hitbox:Cast(callback, filter)
	local attachPos = {}

	for _, attachment in ipairs(self.Attachments) do
		table.insert(attachPos, attachment.WorldPosition)
	end

	self.Callback = callback
	self.Filter = filter or {}
	self.Position = self.Part.Position
	self.AttachPos = attachPos
	self.Index = #active + 1

	table.insert(active, self)
	table.insert(self.filter, self.Part)
end

function hitbox:Stop()
	table.remove(active, self.Index)

	self.Callback = nil
	self.Filter = nil
	self.Position = nil
	self.AttachPos = nil
	self.Index = nil
end

function hitbox:Remove()
	self:Stop()

	self.Part = nil
	self.Attachments = nil
end

game:GetService("RunService").Heartbeat:Connect(function() -- it is better to handle connections procedurally and to use only 1 connection
	for _, self in ipairs(active) do
		local attachPos = self.AttachPos

		rayParams.FilterDescendantsInstances = self.Filter

		for index, attachment in ipairs(self.Attachments) do
			local new = attachment.WorldPosition
			local old = attachPos[index]

			if new - old ~= emptyVector then
				local results = workspace:Raycast(old, new - old, rayParams)

				if results then
					local part = results.Instance -- you could for part detection only, pretty simple to do
					local model = results.Instance:FindFirstAncestorWhichIsA("Model")
					local humanoid = model and model:FindFirstChildWhichIsA("Humanoid")

					if humanoid then
						table.insert(self.Filter, model)
						self.Callback(part, model, humanoid) -- if your callback yields, then it would be a good idea to wrap it
					end
				end
			end

			attachPos[index] = new
		end
	end
end)

return function(part)
	local attachments = {}

	for _, attachment in ipairs(part:GetChildren()) do
		if attachment:IsA("Attachment") and attachment.Name == attachmentName then
			table.insert(attachments, attachment)
		end
	end

	return setmetatable({
		Part = part,
		Attachments = attachments
	}, hitbox)
end

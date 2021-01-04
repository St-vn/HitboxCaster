-- Creation date : 7/12/2020
-- Latest Update : 17/12/2020, increased accuracy and performance
-- GitHub : St-vn, https://github.com/St-vn
-- Roblox : St_vnC, https://www.roblox.com/users/332398911/profile
-- Discord : St_vn#3931

local active, hitbox = {}, {}
hitbox.__index = hitbox

local rayParams = RaycastParams.new()
rayParams.FilterType = Enum.RaycastFilterType.Blacklist

local emptyVector = Vector3.new()
local emptyTable = {}

function hitbox:Cast(callback, filter)
	self.Filter = filter or emptyTable
	self.Callback = callback
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

	for key, value in pairs(self) do
		self[key] = nil
	end
end

game:GetService("RunService").Stepped:Connect(function() -- it is better to handle connections procedurally and to use only 1 connection
	for _, self in ipairs(active) do
		rayParams.FilterDescendantsInstances = self.Filter

		local handleCFrame = self.Part.CFrame
		local hit = self.Hit

		for index, info in ipairs(self.Attachments) do
			local old = info.Previous
			local new = info.Attachment.WorldPosition
			local results = workspace:Raycast(old, new - old, rayParams)

			info.Previous = new

			if results and not hit[part] then
				local part = results.Instance -- you could for part detection only, pretty simple to do
				local model = part:FindFirstAncestorWhichIsA("Model")

				if model:FindFirstChildWhichIsA("Humanoid") then
					hit[part] = true

					self.Callback(part, model) -- if your callback yields, then it would be a good idea to wrap it 
				end
			end
		end
	end
end)

return function(part)
	local attachments = {}

	for _, attachment in ipairs(part:GetChildren()) do
		if attachment.ClassName == "Attachment" and attachment.Name == "DmgPoint" then
			table.insert(attachments, {Attachment = attachment})
		end
	end

	return setmetatable({Part = part, Attachments = attachments}, hitbox)
end

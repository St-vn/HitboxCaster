-- Creation date : 7/12/2020
-- Latest Update : 17/12/2020, increased accuracy and performance
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

game:GetService("RunService").Heartbeat:Connect(function() -- it is better to handle connections procedurally and to use only 1 connection
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

-- Version 2.3

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

-- Made by St_vnC
-- St_vn#3931
-- Update : 12/11/2020
 
--[[
API :
  ** IMPORTANT : Requiring the module returns the constructor function **
 
  Constructor function : Parameter(Part), creates a new hitbox with the attachments in the specified part
 
  Hitbox:Cast(Filter) : Raycasts continuously for the hitbox with a specified filter until Hitbox:Stop() is called, the parameters are Part, Model, Humanoid, The attachment's parent
 
  Hitbox:Stop() : Stop casting rays for this hitbox
 
  Hitbox:Remove() : Removes the hitbox and allows it to be garbage collected
]]

-- Version 1.0

local createSignal = require(game.ReplicatedStorage.Modules.Util.ScriptSignalService) -- You could alternatively use BindableEvents but I'd rather not use instances. Signal Service : https://pastebin.com/P4C3X7KV
local Heartbeat = game:GetService("RunService").Heartbeat -- recommended to handle connection(s)/tasks procedurally
 
local hitbox = {}
hitbox.__index = hitbox
 
local hitboxes = {}
local active = {}
 
local zero = Vector3.new()
local whitelist = "DmgPoint"
local rayParams = RaycastParams.new()
rayParams.FilterType = Enum.RaycastFilterType.Blacklist
 
local function Callback()
    for myPart, info in pairs(active) do
        if info.Position - myPart.Position == zero then continue end
        
        for _, attachment in ipairs(info.Attachments) do
            rayParams.FilterDescendantsInstances = info.Filter
            
            local results = workspace:Raycast(attachment.WorldPosition, (myPart.Position - info.Position).Unit, rayParams)
 
            if results then
                local part = results.Instance
                local model = part:FindFirstAncestorWhichIsA("Model")
                local human = model and model:FindFirstChildWhichIsA("Humanoid")
                
                table.insert(info.Filter, model)
                
                if human then
                    info.Signal:Fire(part, model, human, myPart)
                end
            end
        end
        
        info.Position = myPart.Position
    end
end
 
function hitbox:Cast(Filter)
    self.Position = self.Part.Position
    self.Filter = Filter
    
    active[self.Part] = self
end
 
function hitbox:Stop()
    local Filter = self.Filter
    self.Position = nil
 
    for _ = 1, #Filter or 1 do
        table.remove(Filter)
    end
 
    activeCount -= 1
    active[self.Part] = nil
end
 
function hitbox:Remove()
    local attachments = self.Attachments
    
    self:Stop()
    self.Signal:Destroy()
    hitboxes[self.Part] = nil
    self.Part = nil
    
    for _ = 1, #attachments do
        table.remove(attachments)
    end
end
 
return function(part)
    if hitboxes[part] then
        return hitboxes[part]
    else
        local attachments = {}
        
        for _, attachment in ipairs(part:GetChildren()) do
            if not attachment:IsA("Attachment") then continue end
            attachments[#attachments + 1] = attachment
        end
        
        hitboxes[part] = setmetatable({
            Part = part,
            Attachments = attachments,
            Signal = createSignal()
        }, hitbox)
        
        return hitboxes[part]
    end
end

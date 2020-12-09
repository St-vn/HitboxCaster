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

local createHitbox = require(game.ReplicatedStorage.HitboxCaster)
local hitbox = createHitbox(workspace.Part) -- creating new hitboxes would create new objects instead of giving reference to the existing one because it is better practice to use the constructor once

hitbox:Cast(function(part, model, humanoid) -- parameters
    
end, {workspace.Baseplate}) -- Start casting, ignores the baseplate and would call the callback upon hitting stuff instead of using signals

wait(5)

hitbox:Stop() -- stops casting rays
hitbox:Remove() -- memory leak is bad, so free some memory ;)

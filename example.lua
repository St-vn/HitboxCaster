local createHitbox = require(game.ReplicatedStorage.HitboxCaster2)
local hitbox = createHitbox(workspace.Part)

hitbox:Cast(function(part, model, humanoid) -- parameters
    
end, {workspace.Baseplate}) -- Start casting, ignores the baseplate and would call the callback upon hitting stuff instead of using signals

wait(5)

hitbox:Stop() -- stops casting rays
hitbox:Remove() -- memory leak is bad, so free some memory ;)

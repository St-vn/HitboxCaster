--[[
    API :
        
        table object : Constructor(Instance : Part)
            Creates a new hitbox to cast rays with.
 
            void : hitbox:Cast(function : Callback, table : Filter)
                Starts casting rays and would filter the specified filter list + the part object, would call the callback upon hitting a target.
 
            void : hitbox:Stop()
                Would stop casting rays
 
            void : hitbox:Remove()
                Would remove the call hitbox:Stop() internally and remove the hitbox
]]

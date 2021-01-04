--[[
    API :
        
        table object : Constructor(Instance : Part, array : Offsets)
            Creates a new hitbox to cast rays from, you could optionally use an array of vector offsets instead of attachments being parented to the part.
 
            void : hitbox:Cast(function : Callback, table : Filter)
                Starts casting rays and would filter the specified filter list + the part object, would call the callback upon hitting a target.
 
            void : hitbox:Stop()
                Would stop casting rays
 
            void : hitbox:Remove()
                Would remove the call hitbox:Stop() internally and remove the hitbox
]]

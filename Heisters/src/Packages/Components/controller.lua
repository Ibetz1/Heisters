function new_controller(ent)
    local controller = {
        ent = ent,
        bindings = {
            up = {tick = 0, max_tick = 15},
            down = {tick = 0, max_tick = 15},
            left = {tick = 0, max_tick = 15},
            right = {tick = 0, max_tick = 15}
        },

        tick = 2,
        max_tick = 15
    }

    local meta = {
        type = 'component'
    }

    function controller:set_bindings()
        for k,v in pairs(stack.controls) do
            local k1 = v[1] or '$'
            local k2 = v[2] or '$'

            if self.bindings[k] == nil then
                self.bindings[k] = {tick = 0, max_tick = 15}
            end

            self.bindings[k][1] = k1; self.bindings[k][2] = k2

        end
    end

    function controller:draw()

    end

    function controller:update()

        for k,v in pairs(self.bindings) do
            if v.tick > 0 then 
                v.tick = v.tick - 1
            end
        end

        if love.keyboard.isDown(self.bindings.right[1]) and self.bindings.right.tick == 0 or 
        love.keyboard.isDown(self.bindings.right[2]) and self.bindings.right.tick == 0 then
            self.ent:move('x', 1)
            self.bindings.right.tick = self.bindings.right.max_tick
        end

        if love.keyboard.isDown(self.bindings.left[1]) and self.bindings.left.tick == 0 or 
        love.keyboard.isDown(self.bindings.left[2]) and self.bindings.left.tick == 0 then
            self.ent:move('x', -1)
            self.bindings.left.tick = self.bindings.left.max_tick
        end
        
        if love.keyboard.isDown(self.bindings.down[1]) and self.bindings.down.tick == 0 or 
        love.keyboard.isDown(self.bindings.down[2]) and self.bindings.down.tick == 0 then
            self.ent:move('y', 1)
            self.bindings.down.tick = self.bindings.down.max_tick
        end

        if love.keyboard.isDown(self.bindings.up[1]) and self.bindings.up.tick == 0  or 
        love.keyboard.isDown(self.bindings.up[2]) and self.bindings.up.tick == 0 then
            self.ent:move('y', -1)
            self.bindings.up.tick = self.bindings.up.max_tick
        end


    end


    controller:set_bindings()
    return setmetatable(controller, meta)
end
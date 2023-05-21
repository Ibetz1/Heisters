function apply_light(ent, power, diffuse, probe_max, probe_inc, ox, oy)
    local power = power or 256
    local diffuse = diffuse or {1,1,1}
    local probe_max = probe_max or 0
    local probe_inc = probe_inc or 1
    local ox = ox or 0
    local oy = oy or 0
    local light = {
        id = GID(),
        ent = ent,
        power = power,
        diffuse = diffuse,
        probe_max = probe_max,
        probe = math.random(0, probe_max),
        probe_dir = 1,
        probe_inc = probe_inc,
        ox = ox,
        oy = oy,
        show_light = true,
        linear = nil, 
        quadratic = nil, 
        spread = nil,
        constant = nil
    }

    local meta = {
        type = 'light'
    }

    function light:update()

        if self.probe_max ~= 0 then
            if self.probe < self.probe_max and self.probe_dir == 1 then
                self.probe = self.probe + self.probe_inc
            elseif self.probe_dir == 1 then
                self.probe_dir = -1
            end

            if self.probe > 0 and self.probe_dir == -1 then
                self.probe = self.probe - self.probe_inc
            elseif self.probe_dir == -1 then
                self.probe_dir = 1
            end
        end
    end

    function light:draw()
        if stack.light_map ~= nil then
            local scale = {self.ent.world.zoom*screen_ratio[1], self.ent.world.zoom*screen_ratio[2]}

            local x = ((self.ent.visual_pos.x + self.ent.world.tilesize/2) - (self.ent.chunk_pos.x * self.ent.world.tilesize * self.ent.world.chunk_size))
            local y = ((self.ent.visual_pos.y + self.ent.world.tilesize/2) - (self.ent.chunk_pos.y * self.ent.world.tilesize * self.ent.world.chunk_size))
    
            x = x * scale[1]
            y = y * scale[2]

            if self.show_light and not self.ent.invisible then
                stack.light_map:add_light(x + self.ox, y + self.oy, self.diffuse, self.power + self.probe, self.constant, self.linear, self.quadratic, self.spread)
            end
        end
    end

    return setmetatable(light, meta)
end
function view_caster(world, ent)
    local view = {
        world = world,
        ent = ent,
        cast = {},
        dirs = {
            {0, -1, 'y', 2, 1}, -- facing up
            {1, 0, 'x', 1, 2}, -- facing right
            {0, 1, 'y', 2, 1}, -- facing down
            {-1, 0, 'x', 1, 2} -- facing left
        },
        dmg_add = 0.01,
        dmg_tick = 0
    }

    ent.freeze_look = false

    local meta = {
        type = 'component'
    }

    function view:cast_out_chunk(x, y, offL, offR)
        local offL = offL or 2
        local offR = offR or -3

        local dir = self.dirs[self.ent.facing]
        return x < self.ent.chunk_pos.x * self.world.chunk_size + offL and dir[2] == 0 or 
               y < self.ent.chunk_pos.y * self.world.chunk_size + offL and dir[1] == 0 or 
               x > self.ent.chunk_pos.x * self.world.chunk_size + self.world.chunk_size + offR and dir[2] == 0 or
               y > self.ent.chunk_pos.y * self.world.chunk_size + self.world.chunk_size + offR and dir[1] == 0
    end

    function view:form_cast(x, y, dist, offset)
        local tile = self.ent.world.grid_buffer[x][y]
        local dir = self.dirs[self.ent.facing]
        local id
        local pos = vec2(x, y)
        
        if tile == nil then id = nil else id = tile.id end
        
        if dist == 1 and id ~= nil or self:cast_out_chunk(x, y, 1, -2) then
            pos.x = pos.x - dir[1]
            pos.y = pos.y - dir[2]
            dist = 0
        end

        return {id = id, pos = pos, dist = dist - math.abs(offset)}
    end 

    function view:get_cast(x, y, dist, index, offset)
        local offset = offset or 0
        for d = 1, dist do
            local dir = self.dirs[self.ent.facing]
            local px = x + d*dir[1]
            local py = y + d*dir[2]
            local tile = self.ent.world.grid_buffer[px][py]

            if type(tile) == 'collision_buffer' and
                tile.id ~= self.ent.id or 
                self:cast_out_chunk(px, py) then

                local cast = self:form_cast(px, py, d, offset)

                self.cast[index] = cast
                return cast
            end
        end
    end

    function view:check_seen(id)
        if id == nil then return 0 end

        local ent = self.ent.world.current_entities[id]

        if ent == nil then return 0 end

        if ent.name == 'player' then return 1 end

        return 0
    end

    function view:get_points()
        if #self.cast == 0 then return {} end
        local points = {}
        local dir = self.dirs[self.ent.facing]

        local off = 0
        local last = 1
        if dir[dir[4]] > 0 then
            off = 1
            last = #self.cast
        end

        if self.cast[last].dist >= 1 then
            local p = vec2(self.cast[last].pos.x, self.cast[last].pos.y)
            local ox = 0
            local oy = 0

            if dir[1] > 0 or dir[2] > 0 then ox = 1; oy = 1
            elseif dir[1] < 0 then oy = 1
            elseif dir[2] < 0 then ox = 1
            end

            table.insert(points, vec2(p.x + ox, p.y + oy))
        end

        for i = 1,#self.cast do
            if i == 2 and self.cast[i].dist ~= 0 or i ~= 2 and self.cast[i].dist >= 1 then
                local p = vec2(self.cast[i].pos.x, self.cast[i].pos.y)
                local p2 = p:clone()

                p.x = p.x + math.abs(dir[2]) * 0.5 + (dir[1] * off)
                p.y = p.y + math.abs(dir[1]) * 0.5 + (dir[2] * off)

                p2[dir[3]] = p2[dir[3]] + off

                table.insert(points, p)
                table.insert(points, p2)
            end
        end

        return points
    end

    function view:update()
        local count = 0
        local damage = 0

        for i = -1,1 do
            local index = i + 2
            local dir = self.dirs[self.ent.facing]
            local px = self.ent.tile.x + (i * dir[2])
            local py = self.ent.tile.y + (i * dir[1])

            local c = self:get_cast(px, py, self.ent.world.chunk_size, index, 0)

            count = count + self:check_seen(c.id)
            if self:check_seen(c.id) > 0 then
                damage = self.dmg_add
            end

            if index == 2 and c.dist == 0 then
                self.cast = {c}
            end
        end

        self.ent.freeze_look = count > 0
        self.dmg_tick = self.dmg_tick + count
        if count == 0 then self.dmg_tick = 0 end

        self.ent.world.focus_ent:check_spot(self.ent, count, damage + (self.dmg_tick/2 * self.dmg_add))
    end

    function view:draw()
        local dir = self.dirs[self.ent.facing]



        -- local pts = self:get_points()
        -- local p2 = self.ent.visual_pos:clone() + t_size/2

        -- for i = 1,#pts do
        --     local p = pts[i] * t_size
        --     love.graphics.line(p2.x, p2.y, p.x, p.y)
        -- end



        for c = 1,#self.cast do
            for d = 1, self.cast[c].dist do
                local x = self.cast[c].pos.x - d * dir[1] + dir[1]
                local y = self.cast[c].pos.y - d * dir[2] + dir[2]
                
                love.graphics.rectangle('line', x*t_size, y*t_size, t_size, t_size)
            end
        end
    end

    return view
end

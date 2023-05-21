-- optimized

function new_laser(ent, dx, dy, instakill)
    local instakill = instakill or false

    local damage = 15
    local dir_index
    local oppo_dir_index
    local quad = 5
    local color = {0, 1, 0}
    if dx == 0 then dir_index = 'y' else dir_index = 'x' end
    if dx == 0 then oppo_dir_index = 'x' else oppo_dir_index = 'y' end
    if dx == 0 then if dy > 0 then quad = 9 else quad = 12 end elseif dx > 0 then quad = 5 else quad = 8 end
    if instakill then color = {1, 0, 0} end


    local laser = {
        id = GID(),
        ent = ent,

        dir = vec2(dx, dy),
        dir_index = dir_index,
        oppo_dir_index = oppo_dir_index,

        instakill = instakill,
        damage = damage,

        pos = vec2(ent.pos.x/t_size, ent.pos.y/t_size),
        break_point = vec2(ent.pos.x/t_size, ent.pos.y/t_size),
        
        break_dist = 1,
        line_pos = vec2(),
        quad = quad;

        detected_id = nil,
        beam_tiles = {},
        line_positions = {},

        anim = 0,
        anim_tick = new_timer(3, false),

        color = color
    }

    local meta = {
        type = 'component'
    }
    
    function laser:convert_coords(x, y)
        local px = (x - (self.ent.chunk_pos.x * self.ent.world.tilesize * self.ent.world.chunk_size))
        local py = (y - (self.ent.chunk_pos.y * self.ent.world.tilesize * self.ent.world.chunk_size))

        return px * self.ent.world.zoom * screen_ratio[1], py * self.ent.world.zoom * screen_ratio[2]
    end

    function laser:set_break_point(dist)
        -- gets the break_points
        local index = self.dir_index
        local dir = self.dir[index]
        local pmod = self.pos[index]

        self.break_point[index] = pmod + (dist * dir)
        self.break_dist = dist

        -- gets the tiles the beam is covering

        self.beam_tiles = {}
        if #self.beam_tiles < dist then
            for i = 1, dist do
                table.insert(self.beam_tiles, vec2(self.pos.x + self.dir.x * i, 
                                                self.pos.y + self.dir.y * i))
            end
        end

        -- gets the position of the line
    end

    function laser:check_beam()
        if self.detected_id == nil then return end
        local ent = self.ent.world.current_entities[self.detected_id]
        local beam = self.beam_tiles[#self.beam_tiles]
        if beam == nil then return end
        if ent == nil then return end

        if ent.tile.x ~= beam.x or ent.tile.y ~= beam.y then
            local d = (ent.tile.x - self.pos.x) + (ent.tile.y - self.pos.y)
            self:set_break_point(math.abs(d))
        end
    end

    function laser:check_seen()
        if self.detected_id == nil then return 0 end
        if self.ent.world.current_entities[self.detected_id] == nil then return 0 end

        if self.ent.world.current_entities[self.detected_id].name == 'player' then
            return 1
        end

        return 0
    end

    function laser:reiterate()
        for dist = 1,self.ent.world.chunk_size do
            local tile = self.ent.world.grid_buffer[self.pos.x + (dist*self.dir.x)][self.pos.y + (dist*self.dir.y)]
        
            if type(tile) == 'collision_buffer' and tile.id ~= self.ent.id then
                if self.detected_id == tile.id then break end
                self.detected_id = tile.id

                self:set_break_point(dist)
                break
            end
        end
    end

    function laser:update()
        if not self.ent.world.settings.power then return end

        self:reiterate()
        self:check_beam()


        if self.anim_tick:tick() then self.anim = self.anim + 1 * self.dir[self.dir_index] end
        if math.abs(self.anim) > 3 then self.anim = 0 end

        self.ent.world.focus_ent:check_spot(self.ent, self:check_seen(), self.damage, self.instakill)
    end

    function laser:draw()
        if not self.ent.world.settings.power then return end

        for i = 1,#self.beam_tiles - 1 do
            love.graphics.setShader()
            love.graphics.setColor(self.color[1], self.color[2], self.color[3], 0.3)

            love.graphics.draw(bad_zone.sheet, bad_zone[self.quad + self.anim], self.beam_tiles[i].x * t_size, self.beam_tiles[i].y * t_size)

            local x, y = self:convert_coords(self.beam_tiles[i].x * t_size + t_size/2, self.beam_tiles[i].y * t_size + t_size/2)

            stack.light_map:add_light(x, y, self.color, 300, 3, nil, 0.02, 3)
        end
    end

    return setmetatable(laser, meta)
end

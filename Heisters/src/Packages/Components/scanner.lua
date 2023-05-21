local function make_rail(ent, dir, radius)
    local rail = {}
    local radius = radius or math.floor(ent.world.chunk_size)

    local tile_pos = vec2(
        ent.pos.x / ent.world.tilesize,
        ent.pos.y / ent.world.tilesize
    )

    local relative_chunk = vec2(
        (ent.chunk_pos.x * ent.world.chunk_size) - tile_pos.x,
        (ent.chunk_pos.y * ent.world.chunk_size) - tile_pos.y
    )

    local pos = vec2(tile_pos.x, tile_pos.y)

    for r = -math.floor(radius/2), math.floor(radius/2) do
        if dir == 'x' then
            table.insert(rail, vec2(pos.x + r, pos.y))
        else
            table.insert(rail, vec2(pos.x, pos.y + r))
        end
    end

    for i = 1,#rail do
        if dir == 'x' then
            if rail[i] ~= nil and type(ent.world.grid[rail[i].x][rail[i].y]) == 'entity' and
                ent.world.grid[rail[i].x][rail[i].y].id ~= ent.id then

                if rail[i].x < tile_pos.x then
                    for r = 1, i do
                        rail[r] = nil
                    end
                elseif rail[i].x > tile_pos.x then
                    for r = i, #rail do
                        rail[r] = nil
                    end
                end
            end
        else
            if rail[i] ~= nil and type(ent.world.grid[rail[i].x][rail[i].y]) == 'entity' and
                ent.world.grid[rail[i].x][rail[i].y].id ~= ent.id then

                if rail[i].y < tile_pos.y then
                    for r = 1, i do
                        rail[r] = nil
                    end
                elseif rail[i].y > tile_pos.y then
                    for r = i, #rail do
                        rail[r] = nil
                    end
                end
            end
        end
    end
    
    local new_rail = {move_dir = -1, dir = dir}

    for i = 1,#rail do
        if rail[i] ~= nil then
            table.insert(new_rail, rail[i])
        end
    end

    table.remove(new_rail, 1)
    table.remove(new_rail, #new_rail)

    return new_rail
end

function spinning_camera_comp(ent, rail_dir)

    local rail_dir = rail_dir or 'x'
    local cam = {
        id = GID(),
        ent = ent,
        spin_timer = new_timer(math.random(10, 15), false),
        frozen = false,
        off_timer = new_timer(math.random(30, 180), false),

        view = nil,
        scan_tick = 2,
        x_tick = 3,
        y_tick = 1,
        scan_dir = 1,
        player_seen = 0,
        dir = 'y',
        positions = {},
        rail = nil,
        rail_dir = rail_dir,
        do_rail = math.random(1, 2),
        move_timer = new_timer(math.random(10, 20), false),
        stop_timer = new_timer(100, false),
        end_point = 1
    }

    if math.random(1, 2) == 2 then cam.dir = 'x' end

    local meta = {
        type = 'component'
    }

    function cam:update()
        local tile_pos = vec2(self.ent.pos.x/self.ent.world.tilesize, self.ent.pos.y/self.ent.world.tilesize)

        if self.rail == nil and self.do_rail == 2 then
            self.rail = make_rail(self.ent, self.rail_dir)

            if #self.rail < 3 then
                self.do_rail = 1
                self.rail = nil
            else
                self.dir = self.rail_dir
            end

        elseif self.rail ~= nil and not self.frozen and self.player_seen == 0 then

            local xd = self.rail['move_dir']
            local yd = 0

            self.end_point = 1
            if self.rail['move_dir'] == 1 then self.end_point = #self.rail end
            if self.rail['dir'] == 'y' then xd = 0; yd = self.rail['move_dir'] end

            if tile_pos[self.rail['dir']] ~= self.rail[self.end_point][self.rail['dir']] then
                if type(self.ent.world.grid[tile_pos.x + (xd)][tile_pos.y + (yd)]) == 'entity' then
                    if self.stop_timer:tick() then
                        self.rail['move_dir'] = self.rail['move_dir'] * -1
                    end
                elseif self.move_timer:tick() then
                    self.ent:move(self.rail['dir'], self.rail['move_dir'])
                end
            elseif self.stop_timer:tick() then
                self.rail['move_dir'] = self.rail['move_dir'] * -1
            end
        end

        

        if self.view == nil then
            self.view = array2D(3, 3)
        elseif not self.frozen then
            local dx = 0
            local dy = 1

            for i = 1,9 do
                dx = dx + 1
                if i == 4 or i == 7 then
                    dy = dy + 1
                    dx = 1
                end

                self.view[dx][dy] = vec2(tile_pos.x + dx - 2, tile_pos.y + dy - 2)
            end

            self.player_seen = 0

            self.facing = #self.view

            self.positions = {}
            for i = 1, 3 do

                if self.dir == 'x' then
                    if type(self.ent.world.grid[self.view[self.scan_tick][i].x][self.view[self.scan_tick][i].y]) ~= 'entity' or
                    self.ent.world.grid[self.view[self.scan_tick][i].x][self.view[self.scan_tick][i].y].invisible == true then
                        table.insert(self.positions, vec2(self.scan_tick, i))
                    elseif self.ent.world.grid[self.view[self.scan_tick][i].x][self.view[self.scan_tick][i].y].name == 'player' then
                        self.player_seen = self.player_seen + 1
                    end

                else
                    if type(self.ent.world.grid[self.view[i][self.scan_tick].x][self.view[i][self.scan_tick].y]) ~= 'entity' or
                    self.ent.world.grid[self.view[i][self.scan_tick].x][self.view[i][self.scan_tick].y].invisible == true then
                        table.insert(self.positions, vec2(i, self.scan_tick))
                    elseif self.ent.world.grid[self.view[i][self.scan_tick].x][self.view[i][self.scan_tick].y].name == 'player' then
                        self.player_seen = self.player_seen + 1
                    end
                end
            end

            if self.player_seen > 0 then
                self.ent.world.focus_ent.seen = true
                if self.ent.world.focus_ent.seen_tick >= self.ent.world.focus_ent.sudo_max then
                    self.ent.world.focus_ent.seen_tick = self.ent.world.focus_ent.seen_tick - 1
                end
                self.ent.world.focus_ent.sudo_max = self.ent.world.focus_ent.sudo_max - 1
                self.ent.world.focus_ent.seen_by = self.ent
            else
                if self.ent.world.focus_ent.seen_by == self.ent then 
                    self.ent.world.focus_ent.seen_by = nil 
                end

                if self.ent.world.focus_ent.seen_by == nil then
                    self.ent.world.focus_ent.seen = false
                end
            end
        end

        local change_state = false

        if self.frozen == false then
            if self.off_timer:tick() or stack.light_map.darkness <= 0.02 then
                change_state = true
            end
        end

        if self.frozen == true then
            if self.off_timer:tick() then
                change_state = true
                if self.ent.world.focus_ent.seen_by == self.ent then
                    self.ent.world.focus_ent.seen_by = nil
                    self.ent.world.focus_ent.seen = false
                end
            end
        end

        if change_state then
            if self.ent.world.settings.power == false then
                self.frozen = true
            else
                self.frozen = false
            end
        end

        if self.ent.anim ~= nil then
            if self.frozen == true and self.ent.anim.frozen == false then

                -- if self.ent.anim.anim_start == 13 then -- 29 - 32
                --     local tick = 29 + math.random(1, 3)
                --     self.ent:set_image(spinning_camera_anim, spinning_camera_anim[tick], nil, tick)
                -- elseif self.ent.anim.anim_start == 1 then -- 25 - 28
                --     local tick = 25 + math.random(1, 3)
                --     self.ent:set_image(spinning_camera_anim, spinning_camera_anim[tick], nil, tick)
                -- end
            end

            self.ent.anim.frozen = self.frozen
        end

        if self.rail == nil and self.spin_timer:tick() then
            if self.player_seen == 0 then
                self.scan_tick = self.scan_tick + self.scan_dir
            end

            if self.scan_tick > 3 and self.scan_dir == 1 then
                self.scan_dir = -1
                self.scan_tick = 3
            elseif self.scan_tick < 1 and self.scan_dir == -1 then
                self.scan_dir = 1
                self.scan_tick = 1
            end
        end
    end

    function cam:draw()
        local color = {0.8, 0, 0}
        if self.rail ~= nil then color = {1, 0, 0.6} end

        if self.view ~= nil and self.frozen == false then
            for i = 1, #self.positions do

                local px = self.view[self.positions[i].x][self.positions[i].y].x - self.ent.pos.x/self.ent.world.tilesize
                local py = self.view[self.positions[i].x][self.positions[i].y].y - self.ent.pos.y/self.ent.world.tilesize

                local scale = {self.ent.world.zoom*screen_ratio[1], self.ent.world.zoom*screen_ratio[2]}
                local x = ((px + self.ent.visual_pos.x/self.ent.world.tilesize) * self.ent.world.tilesize) + self.ent.world.tilesize/2
                local y = ((py + self.ent.visual_pos.y/self.ent.world.tilesize) * self.ent.world.tilesize) + self.ent.world.tilesize/2
    
                x = (x - (self.ent.chunk_pos.x * self.ent.world.tilesize * self.ent.world.chunk_size)) * scale[1]
                y = (y - (self.ent.chunk_pos.y * self.ent.world.tilesize * self.ent.world.chunk_size)) * scale[2]
    
                stack.light_map:add_light(x, y, color, 250, 1)

                love.graphics.setShader()

                love.graphics.setColor(color[1], color[2], color[3], 0.02)

                love.graphics.rectangle('fill',  (px + self.ent.visual_pos.x/self.ent.world.tilesize) * self.ent.world.tilesize + 1, 
                                                 (py + self.ent.visual_pos.y/self.ent.world.tilesize) * self.ent.world.tilesize + 1,
                self.ent.world.tilesize - 2, self.ent.world.tilesize - 2)

                love.graphics.setColor(1,1,1,1)
            end

            local pos = stack.light_map:convert_coords(self.ent, 
            self.ent.visual_pos.x + self.ent.world.tilesize/2, 
            self.ent.visual_pos.y + 6)
    
            stack.light_map:add_light(pos.x, pos.y, color, 600, 1)

        end
    end

    return setmetatable(cam, meta)
end
function rand_path(world, px, py, gx, gy, chunk_size, walker_type)
    local chunk_size = chunk_size or #world.chunks - 1
    local walker_type = walker_type or 'linear'

    local path = {
        chunk_size = chunk_size,
        world = array2D(chunk_size, chunk_size),
        main_path = {},
        branches = {},
        final_path = {},
        branch_chance = 2
    }

    path.world:format()

    world.grid = array2D((chunk_size + 1) * world.chunk_size, (chunk_size + 1) * world.chunk_size)
    world.grid_buffer = array2D((chunk_size + 1) * world.chunk_size, (chunk_size + 1) * world.chunk_size)
    world.chunks = array2D(chunk_size + 1, chunk_size + 1),
    world.grid:format()
    world.chunks:format()
    world.grid_buffer:format()

    function path:gen(px, py, gx, gy, type)
        local type = type or 'linear'
        local dirx = 0
        local diry = 0

        if gx < 1 then gx = 1 end
        if gx > self.chunk_size then gx = self.chunk_size end
        if gy < 1 then gy = 1 end
        if gy > self.chunk_size then gy = self.chunk_size end

        local pos = vec2(px, py)
        local dists = {
            gx - px,
            gy - py,
        }

        local goals = {
            gx, gy,
        }

        local dirs = {0, 0}
        local positions = {'x', 'y'}

        if type == 'reverse_linear' then
            positions = flip_table(positions)
            dists = flip_table(dists)
            goals = flip_table(goals)
        end

        for i = 1, 2 do
            if dists[i] ~= 0 then
                dirs[i] = dists[i]/math.abs(dists[i])
            end
        end

        if type == 'linear' or type == 'reverse_linear' then

            for i = 1,2 do
                local cpos = positions[i]
                for p = 1,math.abs(dists[i]) do

                    self.world[pos.x][pos.y].chunk = true
                    self.world[pos.x][pos.y].walk_dir = cpos
                    self.world[pos.x][pos.y].dist = dirs[i]

                    table.insert(self.main_path, vec2(pos.x, pos.y))

                    pos[cpos] = pos[cpos] + dirs[i]
                end
            end
        elseif type == 'rand_walker' then

            local function walk()

                if pos.x == gx and pos.y == gy then
                    return
                else
                    local index = math.random(1, #positions)
                    local pos_type = positions[index]
                    local move_amount = dirs[index]

                    if pos[pos_type] ~= goals[index] then
                        table.insert(self.main_path, vec2(pos.x, pos.y))

                        self.world[pos.x][pos.y].chunk = true
                        self.world[pos.x][pos.y].walk_dir = pos_type
                        self.world[pos.x][pos.y].dist = move_amount

                        pos[pos_type] = pos[pos_type] + move_amount
                    end
                end

                walk()
            end

            walk()

        end

        
        self.world[px][py].start = true
        self.world[gx][gy].goal = true
        self.world[gx][gy].chunk = true
    end

    function path:get_branch_dir(px, py)
        local new_pos = vec2(px, py)
        local index = self.world[px][py].walk_dir
        local rindex = index
        if index == 'x' then index = 'y' else index = 'x' end

        local dirs = {-1, 1}
        local dir = dirs[math.random(1, #dirs)]

        new_pos[index] = new_pos[index] + (dir*math.random(1, 8))
        new_pos[rindex] = new_pos[rindex] + (math.random(-2, 2))

        if new_pos[index] > #self.world then 
            new_pos[index] = #self.world 
        end

        if new_pos[rindex] > #self.world then
            new_pos[rindex] = #self.world
        end

        if new_pos[index] < 1 then 
            new_pos[index] = 1 
        end

        if new_pos[rindex] < 1 then
            new_pos[rindex] = 1
        end

        return new_pos
    end

    function path:branch()
        for i = 1,#self.main_path do
            if math.random(1, self.branch_chance) == self.branch_chance then
                table.insert(self.branches, self.main_path[i])
            end
        end

        for i = 1,#self.branches do
            local goal_pos = self:get_branch_dir(self.branches[i].x, self.branches[i].y)

            self:gen(self.branches[i].x, self.branches[i].y, goal_pos.x, goal_pos.y, 'linear')

        end
    end

    function path:check_surrounded(px, py, compare)
        local compare = compare or 9
        local count = 0
        for x = -1, 1 do
            for y = -1, 1 do
                if px + x > 1 and px + x < #self.world and 
                py + y > 1 and py + y < #self.world[1] then
                    if self.world[px + x][py + y].chunk == true then
                        count = count + 1
                    end
                end
            end
        end

        return count == compare
    end

    function path:cleanup()
        local remove_pos = {}

        for pass = 1, 2 do
            for x = 1,#self.world do
                for y = 1,#self.world[1] do
                    if pass == 1 and self.world[x][y].chunk == false and self:check_surrounded(x, y, 8) then
                        self.world[x][y].chunk = true
                    elseif pass == 2 and self.world[x][y].chunk == true and self:check_surrounded(x, y) then
                        table.insert(remove_pos, vec2(x, y))
                    end
                end
            end
        end

        for i = 1,#remove_pos do
            self.world[remove_pos[i].x][remove_pos[i].y].chunk = false
        end
    end

    function path:get_doors()
        for x = 1,#self.world do
            for y = 1,#self.world do
                if self.world[x][y].chunk == true then
                    self.world[x][y].doors = {
                        top == false,
                        bottom == false,
                        left == false,
                        right == false
                    }
                end
            end
        end

        for x = 1,#self.world do
            for y = 1,#self.world do
                if self.world[x][y].chunk == true then
                    for oy = -1, 1 do
                        if oy ~= 0 and y + oy > 1 and y + oy < #self.world and self.world[x][y + oy].chunk == true then
                            if oy == -1 then
                                self.world[x][y].doors.top = true
                                self.world[x][y + oy].doors.bottom = true
                            else
                                self.world[x][y].doors.bottom = true
                                self.world[x][y + oy].doors.top = true
                            end

                        end
                    end

                    for ox = -1, 1 do
                        if ox ~= 0 and x + ox > 1 and x + ox < #self.world and self.world[x + ox][y].chunk == true then
                            if ox == -1 then
                                self.world[x][y].doors.left = true
                                self.world[x + ox][y].doors.right = true
                            else
                                self.world[x][y].doors.right = true
                                self.world[x + ox][y].doors.left = true
                            end
                        end
                    end

                end

            end
        end


    end

    function path:draw()
        for x = 1,#self.world do
            for y = 1,#self.world do
                if self.world[x][y].chunk then
                    love.graphics.rectangle('fill', (x - 1) * 32, (y - 1) * 32, 32, 32)

                    love.graphics.setColor(1,0,1)
                    love.graphics.setLineWidth(2)

                    if self.world[x][y].doors.bottom == true then
                        love.graphics.setColor(1,0,0)
                    
                        love.graphics.line((x -1 ) * 32, (y) * 32, x * 32, y * 32)
                    end

                    if self.world[x][y].doors.top == true then
                        love.graphics.setColor(0,0,1)

                        love.graphics.line((x -1) * 32, (y -1) * 32, x * 32, (y - 1) * 32)
                    end

                    if self.world[x][y].doors.left == true then
                        love.graphics.setColor(0,1,0)
                        love.graphics.line((x - 1) * 32, (y -1) * 32, (x - 1) * 32, (y) * 32)
                    end

                    if self.world[x][y].doors.right == true then
                        love.graphics.setColor(1,0,1)
                        love.graphics.line((x) * 32, (y -1) * 32, (x) * 32, (y) * 32)
                    end

                    love.graphics.setColor(1,1,1)
                else
                    love.graphics.setColor(1,1,1)
                    love.graphics.rectangle('line', (x - 1) * 32, (y - 1) * 32, 32, 32)
                end
            end
        end
    end

    path:gen(px, py, gx, gy, walker_type)
    path:branch()
    path:cleanup()
    path:get_doors()

    for x = 1, #path.world do
        for y = 1, #path.world[1] do
            if path.world[x][y].chunk == true then
                path.world[x][y].pos = vec2(x, y)
                path.world[x][y].w = world.chunk_size
                path.world[x][y].h = world.chunk_size
                table.insert(path.final_path, path.world[x][y])
            end
        end
    end

    return path
end

function make_new_room(world, chunk)
    local room = {
        world = world,
        pos = vec2(chunk.pos.x * chunk.w, chunk.pos.y * chunk.w),
        chunk = chunk,
        theme = tilesets[1],
        walls = {},
        crates = {},
        entities = {}
    }

    room.dist = math.floor(world.chunk_size/2)

    room.center = vec2(room.pos.x + math.floor(room.chunk.w/2), room.pos.y + math.floor(room.chunk.h/2))

    function room:apply_chunk_data()
        local chunk = self.world.chunks[self.chunk.pos.x][self.chunk.pos.y]
        chunk.theme = self.theme
        chunk.room = {
            crates = self.crates,
            walls = self.walls,
            theme = self.theme
        }
        chunk.bin_pos = self.pos
    end

    function room:get_walls()
        self.walls = {}

        local doors = {
            {self.chunk.doors.left, vec2(self.pos.x, math.floor(self.pos.y + (self.chunk.h/2)))}, -- left
            {self.chunk.doors.right, vec2(self.pos.x + self.chunk.w - 1, math.floor(self.pos.y + (self.chunk.h/2)))}, -- right
            {self.chunk.doors.bottom, vec2(math.floor(self.pos.x + (self.chunk.w/2)), self.pos.y + self.chunk.h - 1)}, -- bottom
            {self.chunk.doors.top, vec2(math.floor(self.pos.x + (self.chunk.w/2)), self.pos.y)} -- top
        }
        
        for x = 1, self.chunk.w do
            for y = 1, self.chunk.h do
                local do_add = false
                local px = self.pos.x + (x - 1)
                local py = self.pos.y + (y - 1)

                if x == 1 or y == 1 or x == self.chunk.w or y == self.chunk.h then
                    do_add = true
                    if px == self.center.x or py == self.center.y then
                        for i = 1,#doors do
                            local d = doors[i]
                            if d[1] and d[2].x == px and d[2].y == py then
                                do_add = false
                            end
                        end
                    end
                end

                if do_add then
                    table.insert(self.walls, {pos = vec2(px, py), quad = 2})
                end
            end
        end
    end

    function room:set_quads()
        for i = 1,#self.walls do
            local pos = self.walls[i].pos
            wall(self.world, pos.x, pos.y)
        end

        for c = 1,#self.walls do
            local pos = self.walls[c].pos
            local x = pos.x - self.pos.x + 1
            local y = pos.y - self.pos.y + 1

            if type(self.world.grid[pos.x][pos.y]) == 'entity' then
                local str_array = new_str_array()
                str_array:format()
                local stbl = {}

                for oy = -1, 1 do
                    local str = ''
                    for ox = -1,1 do
                        local tile = self.world.grid[pos.x + ox][pos.y + oy]

                        if x + ox < 1 or x + ox > self.chunk.w or y + oy < 1 or y + oy > self.chunk.h then
                            str = str .. '#'
                        elseif type(tile) == 'entity' and tile.name == 'wall' then
                            str = str .. '+'
                        elseif type(tile) ~= 'entity' or tile.name ~= 'wall' then
                            str = str .. '?'
                        end
                    end

                    table.insert(stbl, str)
                end

                str_array:set_shape(unpack(stbl))

                for i = 1,#array_shapes do
                    if str_array:match(array_shapes[i]) then
                        self.walls[c].quad = array_shapes[i].val
                    end
                end
            end 
        end

        for i = 1,#self.walls do
            local pos = self.walls[i].pos
            self.world.grid[pos.x][pos.y]:kill()
        end
    end

    function room:fill(count, do_enemy, camera_room, do_laser, do_power_panel, panel_index)
        local do_enemy = do_enemy or false
        local do_safe = do_safe or true
        local camera_room = camera_room or 1
        local safe_count = 0
        local do_laser = do_laser or 2
        local do_power_panel = do_power_panel or false
        local panel_index = panel_index or 7
        local num_lasers = 0
        local max_lasers = 3

        for i = 1, 2 do
            for i = 1,4 do
                local pos
                local c
                local offset1 = math.random(1, self.dist-3)
                local offset2 = math.random(1, self.dist-3)

                if i == 1 then
                    pos = vec2(self.pos.x + math.floor(self.chunk.w/2) +  offset1, 
                    self.pos.y + math.floor(self.chunk.h/2) - offset2)
                elseif i == 2 then
                    pos = vec2(self.pos.x + math.floor(self.chunk.w/2) -  offset1, 
                    self.pos.y + math.floor(self.chunk.h/2) - offset2)
                elseif i == 3 then
                    pos = vec2(self.pos.x + math.floor(self.chunk.w/2) -  offset1, 
                    self.pos.y + math.floor(self.chunk.h/2) + offset2)
                elseif i == 4 then
                    pos = vec2(self.pos.x + math.floor(self.chunk.w/2) +  offset1, 
                    self.pos.y + math.floor(self.chunk.h/2) + offset2)
                end

                local c_type = math.random(22, 23)
                local theme_offets = {2, 3}

                if c_type == 23 then
                    theme_offets = {4, 5}
                end

                if camera_room == 1 then
                    local chance = math.random(1, 2)
                    if chance == 1 then

                        table.insert(self.crates, {pos = pos, quad = c_type, self.theme[theme_offets[1]], self.theme[theme_offets[2]]})

                    elseif chance == 2 then
                        if do_laser == 1 and num_lasers < max_lasers then
                            num_lasers = num_lasers + 1
                            laser(self.world, pos.x, pos.y, math.random(1, 4))
                        else

                            table.insert(self.crates, {pos = pos, quad = c_type, self.theme[theme_offets[1]], self.theme[theme_offets[2]]})

                        end
                    end
                elseif camera_room == 2 then
                    local chance = math.random(1, 3)
                    if chance == 1 then
                        spinning_camera(self.world, pos.x, pos.y, rail_dir)
                    elseif chance == 2 then

                        table.insert(self.crates, {pos = pos, quad = c_type, self.theme[theme_offets[1]], self.theme[theme_offets[2]]})

                    elseif chance == 3 then
                        if do_laser == 1 then
                            laser(self.world, pos.x, pos.y, math.random(1, 4))
                        else

                            table.insert(self.crates, {pos = pos, quad = c_type, self.theme[theme_offets[1]], self.theme[theme_offets[2]]})

                        end
                    end
                elseif camera_room == 3 then
                    spinning_camera(self.world, pos.x, pos.y, rail_dir)
                end
            end
        end

        if do_enemy then
            enemy(self.world, self.center.x, self.center.y)
        end

        if do_power_panel then
            power_panel(self.world, self.center.x, self.center.y, panel_index)
        end
    end

    function room:add_safe(rarity, index, center)
        local rarity = rarity or 1
        local center = center or false

        local side = math.random(1, 4)

        if center == false then
            if side == 1 then
                safe(self.world, self.pos.x + math.ceil(self.chunk.w/2) + math.random(2, self.dist-3), 
                self.pos.y + math.ceil(self.chunk.h/2) - math.random(2, self.dist-3), rarity, index)
            elseif side == 2 then
                safe(self.world, self.pos.x + math.ceil(self.chunk.w/2) - math.random(2, self.dist-3), 
                self.pos.y + math.ceil(self.chunk.h/2) - math.random(2, self.dist-3), rarity, index)
            elseif side == 3 then
                safe(self.world, self.pos.x + math.ceil(self.chunk.w/2) - math.random(2, self.dist-3), 
                self.pos.y + math.ceil(self.chunk.h/2) + math.random(2, self.dist-3), rarity, index)
            elseif side == 4 then
                safe(self.world, self.pos.x + math.ceil(self.chunk.w/2) + math.random(2, self.dist-3), 
                self.pos.y + math.ceil(self.chunk.h/2) + math.random(2, self.dist-3), rarity, index)

            end
        else
            safe(self.world, self.center.x, self.center.y, rarity, index)
        end
    end

    function room:laser_block()
        for i = 1, 4 do
            if i == 1 then
                pos = vec2(self.pos.x + 1,  -- bottom left
                self.pos.y + math.ceil(self.chunk.h - 2))
            elseif i == 2 then
                pos = vec2(self.pos.x + 1, -- top left
                self.pos.y + 1)
            elseif i == 3 then
                pos = vec2(self.pos.x + math.ceil(self.chunk.w - 2), -- top right
                self.pos.y + 1)
            elseif i == 4 then
                pos = vec2(self.pos.x + math.ceil(self.chunk.w - 2), -- bottom right
                self.pos.y + math.ceil(self.chunk.h - 2))
            end

            laser(self.world, pos.x, pos.y, i, true)

        end

    end

    return room

end
-- creates a chunk_loader for world
function chunk_loader(world)
    local loader = {
        world = world, 
        id = GID(),
        chunk_size = world.chunk_size
    }

    local meta = {
        type = 'chunk_loader'
    }

    -- unloads static objects at x and y
    function loader:unload_static(x, y)
        -- localizes chunk
        local chunk = self.world.chunks[x][y]

        -- localizes bin
        local bin = self.world.grid[chunk.bin_pos.x][chunk.bin_pos.y]

        -- assets chunk is valid
        assert(chunk ~= nil, 'invalid chunk')

        -- checks if bin exists; returns if otherwise
        if bin == nil then return end

        -- kills the entitiy bin
        bin:kill()
        
        -- kills crates in room
        for i = 1,#chunk.room.crates do
            local pos = chunk.room.crates[i].pos

            if type(self.world.grid[pos.x][pos.y]) == 'entity' and self.world.grid[pos.x][pos.y].name == 'crate' then
                self.world.grid[pos.x][pos.y]:kill()
            end
        end
    end

    -- loads static objects
    function loader:load_static(x, y)
        local chunk = self.world.chunks[x][y]
        assert(chunk ~= nil, 'invalid chunk')

        -- adds crates to room
        for i = 1,#chunk.room.crates do
            local sox = chunk.room.crates[i][1]
            local soy = chunk.room.crates[i][2]
            local pos = chunk.room.crates[i].pos
            local quad = chunk.room.crates[i].quad
            local c = crate(self.world, pos.x, pos.y, chunk.room.theme[1], quad, sox, soy)

            if chunk.room.theme == tilesets[6] and quad == 23 then
                local light = apply_light(c, 900, {1, 1, 0}, nil, nil, 0, 12)
                c:add_component(light)
            end
        end

        -- creates entity bin for walls
        local bin = new_entity_bin(chunk.bin_pos.x * self.world.tilesize, 
                                   chunk.bin_pos.y * self.world.tilesize, 
                                   chunk.room.walls)
        bin.name = 'wall'
        bin.world = self.world
        -- adds bin to world
        self.world:add_ent(bin, false)

        -- formats bin data and applies bin canvas
        bin:format_data()

        -- gets the canvas for the bin
        bin:get_canvas(chunk.theme)
    end

    -- gets entities within chunk
    function loader:get_chunk(x, y)
        local chunk = self.world.chunks[x][y]
        if chunk == nil then return end

        local current_entities = {}
        local current_components = {}

        iterate_chunk(x, y, self.chunk_size, function(x, y) 
            local tile = self.world.grid[x][y]
            if type(tile) == 'entity' and tile.update ~= nil and tile.draw ~= nil and tile.id ~= self.world.focus_ent.id then
                current_entities[self.world.grid[x][y].id] = self.world.grid[x][y]
            end
        end)

        current_entities[self.world.focus_ent.id] = self.world.focus_ent

        for k, v in pairs(current_entities) do
            if v.components ~= nil then
                for i = 1,#v.components do
                    table.insert(current_components, v.components[i])
                end
            end
        end

        return current_entities, current_components
    end

    -- renders canvas for static entities within chunk
    function loader:render_canvas(x, y, canvas)
        local cx, cy = x, y
        local chunk = self.world.chunks[x][y]
        if chunk == nil then return end

        local img_scale = self.world.img_scale

        canvas:renderTo(function()
            love.graphics.clear()
            for layer = 1,2 do
                iterate_chunk(cx, cy, self.chunk_size, function(x, y)
                    local pos = vec2(x - (cx * self.chunk_size), y - (cy * self.chunk_size))
                    local tile = self.world.grid[x][y]

                    if layer == 1 then

                        if layer == 1 and type(tile) ~= 'entity' or tile.name ~= 'wall' then
                            love.graphics.draw(chunk.theme[1].sheet, chunk.theme[1][5], pos.x*t_size, pos.y*t_size, 0, img_scale)
                        end

                    elseif type(tile) == 'entity' and tile.worldtype == 'static' then
                        tile:draw_shadow(pos.x * t_size, pos.y * t_size)
                    end
                end)
            end
        end)
    end

    return setmetatable(loader, meta)

end

-- creates a chunk updater for world (handles loading and upadating of chunks)
function state_handler(world)
    local handler = {
        id = GID(),
        world = world,
        state = 1,
        states = {
            'mainloop',
            'loadloop',
        },
    }

    handler.checks = {
        statics = false,
        entities = false,
        canvas = false,
    }

    local meta = {
        type = 'chunk_updater'
    }

    function handler:refresh_entity(ent)
        if #ent.move_buffers == 1 then return end

        -- gets current entity tile
        ent.tile = vec2((ent.pos.x/self.world.tilesize), (ent.pos.y/self.world.tilesize))

        -- sets current position in chunks
        ent.chunk_pos.x = math.floor(((ent.pos.x/self.world.tilesize))/(self.world.chunk_size))
        ent.chunk_pos.y = math.floor(((ent.pos.y/self.world.tilesize))/(self.world.chunk_size))


        if ent.worldtype == 'static' then
            self.world.grid[ent.tile.x][ent.tile.y] = ent
            self.world.grid_buffer[ent.tile.x][ent.tile.y] = setmetatable({id = ent.id}, {type = 'collision_buffer'})
            return
        end

        -- clears move buffer
        if ent.pos.x == ent.move_to.x and ent.pos.y == ent.move_to.y then
            -- clears the move buffer on world grid
            for i = 1, #ent.move_buffers do
                local buffer = ent.move_buffers[i]
                local p = vec2(buffer.x/self.world.tilesize, buffer.y/self.world.tilesize)

                -- removes entity on world grid
                self.world.grid[p.x][p.y] = nil

                -- removes entity on collision buffer
                self.world.grid_buffer[p.x][p.y] = nil
            end

            -- clears the local move buffer on entity
            ent.move_buffers = {}

            -- moves the entity on world grid
            self.world.grid[ent.tile.x][ent.tile.y] = ent

            -- moves entity on collision buffer
            self.world.grid_buffer[ent.tile.x][ent.tile.y] = setmetatable({id = ent.id}, {type = 'collision_buffer'})

            -- adds position to local move buffer
            table.insert(ent.move_buffers, vec2(ent.pos.x, ent.pos.y))
        end

        -- moves entity
        if ent.move_to ~= ent.pos then
            local dx = ent.move_to.x - ent.pos.x
            local dy = ent.move_to.y - ent.pos.y

            if dx < 0 then
                ent.facing = 4
            elseif dx > 0 then
                ent.facing = 2
            elseif dy < 0 then
                ent.facing = 1
            elseif dy > 0 then
                ent.facing = 3
            end
         
            if ent.id == self.world.focus_ent.id then
                local ncposx = math.floor(( (ent.pos.x + dx) / self.world.tilesize) / self.world.chunk_size)
                local ncposy = math.floor(( (ent.pos.y + dy) / self.world.tilesize) / self.world.chunk_size)

                if ncposx ~= ent.chunk_pos.x or ncposy ~= ent.chunk_pos.y then
                    ent.pre_chunk_pos = ent.chunk_pos
                    ent.chunk_pos = vec2(ncposx, ncposy)
                    self:reset()
                    self:loadloop()
                end
            end

            -- moves the entity
            ent.pos.x = ent.pos.x + dx
            ent.pos.y = ent.pos.y + dy
        end
    end

    function handler:reset(check)
        if check == nil then
            for k,v in pairs(self.checks) do
                self.checks[k] = false
            end

            return
        end

        self.checks[check] = false
    end

    function handler:check()
        for k,v in pairs(self.checks) do
            if not v then 
                self.state = 2
                return
            end
        end

        self.state = 1
    end

    function handler:mainloop()
        local current_entities = self.world.current_entities
        local current_components = self.world.current_components
        
        for k,v in pairs(current_entities) do
            self:refresh_entity(v)
            v:update()
        end

        for i = 1,#current_components do
            if current_components[i] ~= nil then
                current_components[i]:update()
            end
        end
    end

    function handler:loadloop()
        local focus_ent = self.world.focus_ent
        if focus_ent == nil then return end

        local cx = focus_ent.chunk_pos.x
        local cy = focus_ent.chunk_pos.y
        local px = focus_ent.pre_chunk_pos.x
        local py = focus_ent.pre_chunk_pos.y

        if not self.checks.statics then
            self.world.chunk_loader:unload_static(px, py)
            self.world.chunk_loader:load_static(cx, cy)
            self.checks.statics = true
            return
        end

        if not self.checks.entities then
            self.world:get_chunk(cx, cy)

            self.checks.entities = true
        end

        if not self.checks.canvas then
            self.world.chunk_loader:render_canvas(cx, cy, self.world.static_floor_canvas)

            self.checks.canvas = true
        end

        self:check()
    end

    function handler:update()
        self:check()
        self[self.states[self.state]](self)
    end

    return setmetatable(handler, meta)
end

-- creates a rendering pipeline for world
function render_pipeline(world)
    local pipeline = {
        id = GID(),
        world = world
    }

    local smeta = {
        type = 'chunk renderer'
    }

    function pipeline:render_chunk()
        self.world.full_canvas:renderTo(function()

            love.graphics.clear()
            love.graphics.translate(-(self.world.focus_ent.chunk_pos.x * self.world.chunk_size * t_size),
                                    -(self.world.focus_ent.chunk_pos.y * self.world.chunk_size * t_size))

            for layer = 1, 2 do
                for k,v in pairs(self.world.current_entities) do
                    if layer == 1 and v.worldtype == 'dynamic' then
                        love.graphics.setColor(1,1,1,1)
                        
                        v:draw_shadow()
                    elseif layer == 2 and v.draw ~= nil then 
                        love.graphics.setColor(1,1,1,1)
                        v:draw()
                    end
                end
            end

            for i = 1,#self.world.current_components do
                love.graphics.setColor(1,1,1,1)
                self.world.current_components[i]:draw()
            end
        end)
    end

    return setmetatable(pipeline, meta)
end

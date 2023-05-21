-- creates an entity world
function new_world(tilesize, w, h, chunk_size)
    local w = w or 130
    local h = h or 130
    local chunk_size = chunk_size or 15

    local world = {
        id = GID(),
        tilesize = tilesize,

        grid = array2D(w, h),
        grid_buffer = array2D(w, h),
        chunks = array2D(w/chunk_size, h/chunk_size),

        w = w,
        h = h,

        focus_ent = nil,
        current_entities = {},
        current_components = {},

        chunk_size = chunk_size,
        img_scale = 1,

        render_ox = 0,
        render_oy = 0,
        zoom = pix_scale,

        shadow_stretch = 0.4,
        no_zoom = false,

        hidden = false,
        show_colliders = false,
        shader = nil,

        collected_safes = {},
    }
    
    -- world settings

    world.settings = {
        power = true,
        lights = true,
        tick_bools = {
            power = new_real_timer(-1, -1),
            lights = new_real_timer(-1, -1),
        }
    }

    world.chunk_loader = chunk_loader(world)
    world.state_handler = state_handler(world)
    world.rendering = render_pipeline(world)

    love.graphics.setDefaultFilter("nearest", "nearest")
    world.static_floor_canvas = love.graphics.newCanvas(tilesize * chunk_size * pix_scale, tilesize * chunk_size * pix_scale)
    world.full_canvas = love.graphics.newCanvas(tilesize * chunk_size * pix_scale, tilesize * chunk_size * pix_scale)


    for i = 1,4 do table.insert(world.collected_safes, {count = 0}) end

    -- format arrays
    world.grid:format()
    world.grid_buffer:format()

    -- turns power/lights off for a time
    function world:power_off(index, time)
        self.settings.tick_bools[index].time = time
        self.settings.tick_bools[index].current_tick = time
        self.settings.tick_bools[index].finished = false
        world_effects.power_off(time, 'world_cooldowns', index)
    end

    -- gets all entities and entity components within chunk
    function world:get_chunk(cx, cy)
        if self.focus_ent == nil then return end

        self.current_entities, self.current_components = self.chunk_loader:get_chunk(cx, cy)
    end

    -- converts an entities world coords ti screeb coords
    function world:world_to_screen_coords(ent)
        local scale = {self.zoom*screen_ratio[1], self.zoom*screen_ratio[2]}
        local w = ((self.chunk_size) * self.tilesize) * scale[1]
        local h = ((self.chunk_size) * self.tilesize) * scale[2]
        local px = (w + self.render_ox * scale[1] + current_res[1]/2)
        local py = (h + self.render_oy * scale[2] + current_res[2]/2)
        px = px + (ent.chunk_pos.x * self.tilesize * self.chunk_size * scale[1])
        py = py + (ent.chunk_pos.y * self.tilesize * self.chunk_size * scale[2])
        px = px - (self.chunk_size * self.tilesize * scale[1])
        py = py - (self.chunk_size * self.tilesize * scale[2])

        local tile_pos = vec2(ent.pos.x / self.tilesize, ent.pos.y / self.tilesize)
        local chunk_rel_pos = vec2(tile_pos.x - (ent.chunk_pos.x * (self.chunk_size)),
                                    tile_pos.y - (ent.chunk_pos.y * (self.chunk_size)))

        px = px + (chunk_rel_pos.x) * self.tilesize * scale[1]
        py = py + (chunk_rel_pos.y) * self.tilesize * scale[2]

        return px, py
    end

    -- scales and zooms world
    function world:apply_scale()
        love.graphics.reset()

        local scale = {self.zoom*screen_ratio[1], self.zoom*screen_ratio[2]}

        love.graphics.translate(love.graphics.getWidth()/2, love.graphics.getHeight()/2) -- puts map origin at center
            
        love.graphics.translate((self.render_ox*scale[1]), (self.render_oy*scale[2])) -- puts chunk on map origin

        love.graphics.scale(scale[1], scale[2])
    end

    -- adds entities to the world
    function world:add_ent(ent, focus)
        local focus = focus or false
        if ent.pos.x/self.tilesize >= 1 and ent.pos.y/self.tilesize >= 1 and ent.pos.x/self.tilesize < self.w and ent.pos.y/self.tilesize < self.h then

            if type(self.grid[ent.pos.x/self.tilesize][ent.pos.y/self.tilesize]) ~= 'entity' then
                self.grid[ent.pos.x/self.tilesize][ent.pos.y/self.tilesize] = ent
                ent.world = self
                if focus then self.focus_ent = ent end
            end
        end

        self.state_handler:reset('entities')
    end

    -- updates the world
    function world:update()
        -- effects list
        world_effects.safe_zone('world_cooldowns', 'safe_zone')

        self.settings.tick_bools.lights:tick()
        self.settings.lights = self.settings.tick_bools.lights.finished

        self.settings.tick_bools.power:tick()
        self.settings.power = self.settings.tick_bools.power.finished

        -- checks if power/lights are off >> decreases brightness if true
        if self.settings.lights == false or self.settings.power == false and stack.light_map ~= nil then
            if stack.light_map.darkness > 0 then
                stack.light_map.darkness = stack.light_map.darkness - 0.01
            end

        -- checks if power/lights are on >> maximizes brightness if true
        elseif self.settings.lights == true and self.settings.power == true and stack.light_map ~= nil then
            if stack.light_map.darkness < 0.35 then
                stack.light_map.darkness = stack.light_map.darkness + 0.01
            end
        end

        -- checks for focus entity (or player) >> if player isnt there then dont update
        -- this is for safety
        if self.focus_ent == nil then return end

        -- updates the state handler
        self.state_handler:update()
        -- self.rendering:render_chunk()

        -- sets the chunk offset
        local chunk_pos = vec2((self.focus_ent.chunk_pos.x)*(self.chunk_size)*self.tilesize, (self.focus_ent.chunk_pos.y)*(self.chunk_size)*self.tilesize)

        local chunk_size = self.chunk_size*self.tilesize

        local dx = (chunk_pos.x+(chunk_size/2)) + self.render_ox
        local dy = (chunk_pos.y+(chunk_size/2)) + self.render_oy
    end

    -- draws the world
    function world:draw()
        -- draws background
        love.graphics.setShader(self.shader)
        love.graphics.draw(back_ground, 0, 0, 0, 2)
        love.graphics.setShader()

        love.graphics.push()

        self:apply_scale()

        -- reads through chunk tiles and draws them
        -- !!! this is for safety !!!
        if self.focus_ent == nil then return end

        -- sets lighting shader
        local cx = ((self.focus_ent.chunk_pos.x) * self.tilesize * self.chunk_size)
        local cy = ((self.focus_ent.chunk_pos.y) * self.tilesize * self.chunk_size)

        -- draws static canvas
        love.graphics.setShader(self.shader)
        love.graphics.draw(self.static_floor_canvas, cx, cy)

        -- draw entities
        for layer = 1, 2 do
            for k,v in pairs(self.current_entities) do
                if layer == 1 and v.worldtype == 'dynamic' then
                    love.graphics.setColor(1,1,1,1)
                    
                    v:draw_shadow()
                elseif layer == 2 and v.draw ~= nil then 
                    love.graphics.setColor(1,1,1,1)
                    v:draw()
                end
            end
        end

        for i = 1,#self.current_components do
            love.graphics.setColor(1,1,1,1)
            self.current_components[i]:draw()
        end

        love.graphics.setColor(1,1,1,1)
        love.graphics.setShader()

        love.graphics.pop()

    end

    return world
end

-- creates an entity
function new_ent(x, y, worldtype)
    local worldtype = worldtype or 'static'
    local ent = {
        id = GID(),
        world = nil,
        pos = vec2(x, y),
        visual_pos = vec2(x, y),
        tile = vec2(x/t_size, y/t_size),
        chunk_pos = vec2(1, 1),
        pre_chunk_pos = vec2(1, 1),
        components = {},
        facing = 1,
        name = nil,
        image = nil,
        mask = {1,1,1,1},
        do_hop = false,
        hop = 0,
        hop_pos = 0,
        bar_pcts = {},
        invisible = false,
        outline = false,
        freeze = false,

        shadow_sx = 1,
        shadow_oy = 0,
        shadow_ox = 0,
        shadow_oy = 0,

        outline_color = {0,0.3,1,1},
        outline_pixel_size = {0.0007, 0.0007},
        outline_smoothness = 1,
        outline_size = 2,

        move_to = vec2(x, y),
        move_buffers = {},

        worldtype = worldtype
    }
    
    local meta = {
        type = 'entity'
    }

    -- kills the entity
    function ent:kill()
        if self.world ~= nil then
            self.world.grid[(self.pos.x/t_size)][(self.pos.y/t_size)] = nil
            self.world.grid_buffer[(self.pos.x/t_size)][(self.pos.y/t_size)] = nil
            self.world.state_handler:reset('entities')
        end
    end

    -- sets an image to the entity
    function ent:set_image(sheet, quad, scale, quad_num)
        local scale = scale or 1
        local px_offset = px_offset or 0

        self.image = {sheet.sheet, quad, scale, px_offset, 
                                    rsheet = sheet.quad_stats,
                                    quad_num = quad_num}
    end

    -- adds component to the entity
    function ent:add_component(comp)
        table.insert(self.components, comp)
    end

    -- moves the entity
    function ent:move(dir, amount)
        if self.freeze then return end

        local tile = vec2((self.pos.x/t_size), (self.pos.y/t_size))

        local ss
        -- defines map borders based on dir
        if dir == 'x' then 
            ss = self.world.w*t_size 
        else 
            ss = self.world.h*t_size
        end

        -- checks map borders
        if self.pos[dir] + amount*t_size >= 1 and self.pos[dir] + amount*t_size < ss then
            -- moves the entity

            local p = vec2(self.pos.x, self.pos.y)
            p[dir] = p[dir] + (amount * t_size)

            -- checks for colision buffer on world grid and returns false if there is a collider
            if type(self.world.grid_buffer[p.x/t_size][p.y/t_size]) == 'collision_buffer' then
                return false
            end

            if self.do_hop then
                self.hop_pos = 2
            end

            -- sets entities goal position to postion
            self.move_to = p

            -- adds goal position to move buffer
            self.world.grid_buffer[p.x/t_size][p.y/t_size] = setmetatable({id = self.id}, {type = 'collision_buffer'})
            table.insert(self.move_buffers, vec2(p.x, p.y))


            return true
        end
    end

    -- updates the entity
    function ent:update()
        if self.freeze == true then
            self.invisible = true
        end

        --self.visual_pos = self.pos
        local dx = self.visual_pos.x - self.pos.x
        local dy = self.visual_pos.y - self.pos.y

        -- gets visual positon (smooths movement)
        self.visual_pos.x = self.visual_pos.x - dx/8
        self.visual_pos.y = self.visual_pos.y - dy/8

        -- makes the entity hop while moving
        local hop_dist = self.hop_pos - self.hop

        if self.hop_pos > 0 and hop_dist < 0.1 or
            self.hop_pos < 0 and hop_dist > -0.1 then
            self.hop_pos = 0
        end

        self.hop = self.hop + hop_dist/4
    end

    -- draws entity shadow
    function ent:draw_shadow(x, y)
        if self.image == nil then return end

        local x = x or self.visual_pos.x
        local y = y or self.visual_pos.y

        -- checks ent at tile_position
        local check_ent = self.world.grid[self.tile.x][self.tile.y + 1]

        -- checks properties of ent at tile position
        if self.name ~= 'wall' or type(check_ent) ~= 'entity' or check_ent.name ~= 'wall' then
            -- checks to make sure wall doesnt draw shadows at the bottom
            if self.tile.y < (self.chunk_pos.y * self.world.chunk_size) + (self.world.chunk_size - 1) or self.name ~= 'wall' then

                -- x offset
                local ox = self.shadow_ox

                -- y offset
                local oy = (1 + self.world.shadow_stretch)*t_size + self.shadow_oy

                -- scale on the x (can also flip image horizontally)
                local scalex = self.shadow_sx

                -- scale on the y (can also flip image vertically)
                local scaley = -self.world.shadow_stretch

                -- sets to shadow shader
                love.graphics.setShader(shaders.shadow)

                -- draws the shadow
                love.graphics.draw(self.image[1], self.image[2], 
                                x + ox, -- adds offset to entity visual positionx
                                y + oy + self.hop/2, -- adds offset to entity visual positiony + entity hop offset
                                0, scalex, scaley) -- scales image (also flips it)

                love.graphics.setShader(self.world.shader)
            end
        end

    end

    -- draws the entity
    function ent:draw(x, y)
        -- checks if entity has image and draws it
        local x = x or self.visual_pos.x
        local y = y or self.visual_pos.y

        if self.world.show_colliders then
            for i = 1,#self.move_buffers do
                love.graphics.rectangle('line', self.move_buffers[i].x, self.move_buffers[i].y, t_size, t_size)
            end
        end

        if self.image ~= nil then
            if self.outline and self.world.render_ox < 0.1 and self.world.render_oy < 0.1 then
                love.graphics.setColor(1,1,1,1)
                shaders.outline:send('pixelsize', {0.0007, 0.0007})
                shaders.outline:send('outline_color', self.outline_color)
                shaders.outline:send('size', self.outline_size)
                shaders.outline:send('smoothness', self.outline_smoothness)
                love.graphics.setShader(shaders.outline)
                love.graphics.draw(self.image[1], self.image[2], x, y - self.hop, 0, self.image[3])
            end

            if self.mask ~= nil then
                local r = self.mask[1]
                local g = self.mask[2]
                local b = self.mask[3]
                local a = self.mask[4]
                if self.invisible then
                    a = 0.05
                end

                if a < 1 then love.graphics.setShader() end

                love.graphics.setColor(r, g, b, a)
            end


            love.graphics.draw(self.image[1], self.image[2], x, y - self.hop, 0, self.image[3])

        end

        self.outline = false
    end

    -- returns the entity
    ent = setmetatable(ent, meta)
    return ent
end

-- creates entity bin (primarily for walls)
-- bin positions are in tiles
function new_entity_bin(x, y, data)
    local bin = {
        id = GID(),
        data = data,
        pos = vec2(x, y),
        chunk_pos = vec2(1, 1),
        world = nil,
        id = GID(),
        name = 'ebin',
        components = {},
        worldtype = 'static',
        move_buffers = {},

        shadow_sx = 1,
        shadow_oy = 0,
        shadow_ox = 0,
        shadow_oy = 0,

        canvas = nil
    }

    local meta = {
        type = 'entity'
    }

    function bin:get_canvas(theme)
        love.graphics.setDefaultFilter("nearest", "nearest")
        self.canvas = love.graphics.newCanvas(t_size * self.world.chunk_size * pix_scale, 
                                              t_size * self.world.chunk_size * pix_scale)

        self.canvas:renderTo(function() 
            self.chunk_pos.x = math.floor(((self.pos.x/t_size))/(self.world.chunk_size))
            self.chunk_pos.y = math.floor(((self.pos.y/t_size))/(self.world.chunk_size))
    

            for i = 1,#self.data do
                if self.data[i].quad == nil then break end
                if self.data[i].pos == nil then break end

                local pos = self.data[i].pos
                local quad = self.data[i].quad
                local tile = vec2((pos.x) - (self.chunk_pos.x * self.world.chunk_size), 
                                  (pos.y) - (self.chunk_pos.y * self.world.chunk_size))

                love.graphics.draw(theme[1].sheet, theme[1][quad], tile.x * t_size, tile.y * t_size, 0, self.world.img_scale)
            end
        end)
    end

    function bin:kill()
        if self.world ~= nil then
            for i = 1,#self.data do
                local pos = self.data[i].pos

                self.world.grid[(pos.x)][(pos.y)] = nil
                self.world.grid_buffer[(pos.x)][(pos.y)] = nil
                self.world.state_handler:reset('entities')
            end

        end
    end

    function bin:render_branch(index)
        if self.data[index].pos == nil then return end
        local pos = self.data[index].pos

        if pos.x == self.pos.x/t_size and pos.y == self.pos.y/t_size then
            self.world.grid[pos.x][pos.y] = setmetatable(self, meta)
            self.world.grid_buffer[pos.x][pos.y] = setmetatable({id = self.id}, {type = 'collision_buffer'})
        else
            self.world.grid[pos.x][pos.y] = setmetatable(self.data[index], meta)
            self.world.grid_buffer[pos.x][pos.y] = setmetatable({id = self.id}, {type = 'collision_buffer'})
        end
    end

    function bin:format_data()
        if self.world == nil then return end

        self.chunk_pos.x = math.floor(((self.pos.x/t_size))/(self.world.chunk_size))
        self.chunk_pos.y = math.floor(((self.pos.y/t_size))/(self.world.chunk_size))

        for i = 1,#self.data do
            if self.data[i].name == nil then
                self.data[i].name = self.name
            end

            if self.data[i].quad == nil then
                self.data[i].quad = 1
            end

            if self.data[i].id == nil then
                self.data[i].id = self.id
            end

            self:render_branch(i)
        end
    end

    function bin:update()
        for i = 1,#self.data do
            if self.data[i].pos == nil then return end
            local pos = self.data[i].pos
    
            if pos.x == self.pos.x/t_size and pos.y == self.pos.y/t_size then
                self.world.grid_buffer[pos.x][pos.y] = setmetatable({id = self.id}, {type = 'collision_buffer'})
            else
                self.world.grid_buffer[pos.x][pos.y] = setmetatable({id = self.id}, {type = 'collision_buffer'})
            end
        end
    end

    function bin:draw_shadow()
        local theme = self.world.chunks[self.chunk_pos.x][self.chunk_pos.y].theme

        for i = 1,#self.data do
            local tile = self.data[i].pos
            local quad = self.data[i].quad
            local check_ent = self.world.grid[tile.x][tile.y + 1]

            local x = tile.x - (self.chunk_pos.x * self.world.chunk_size)
            local y = tile.y - (self.chunk_pos.y * self.world.chunk_size)
            x = x * t_size
            y = y * t_size

            -- checks properties of ent at tile position
            if type(check_ent) ~= 'entity' or check_ent.name ~= 'wall' then
                -- checks to make sure wall doesnt draw shadows at the bottom
                if tile.y < (self.chunk_pos.y * self.world.chunk_size) + (self.world.chunk_size - 1) or self.name ~= 'wall' then

                    -- x offset
                    local ox = self.shadow_ox

                    -- y offset
                    local oy = (1 + self.world.shadow_stretch)*t_size + self.shadow_oy

                    -- scale on the x (can also flip image horizontally)
                    local scalex = self.shadow_sx

                    -- scale on the y (can also flip image vertically)
                    local scaley = -self.world.shadow_stretch

                    -- sets to shadow shader
                    love.graphics.setShader(shaders.shadow)

                    -- draws the shadow
                    love.graphics.draw(theme[1].sheet, theme[1][quad], 
                    x + ox, -- adds offset to entity visual positionx
                    y + oy, -- adds offset to entity visual positiony + entity hop offset
                    0, scalex, scaley) -- scales image (also flips it)

                    love.graphics.setShader(self.world.shader)
                end
            end
        end

    end

    function bin:draw(x, y)
        local x = x or self.pos.x
        local y = y or self.pos.y

        if self.canvas ~= nil then
            love.graphics.draw(self.canvas, x, y)
        end
    end

    return setmetatable(bin, meta)
end
-- creates a UI overlay
function new_UI()
    local UI = {
        id = GID(),
        elements = {},
        images = {},
        bob_tick = 1,
        bob_max = 40,
        bob_speed = 60,
        current_bob = 1
    }

    local meta = {
        type = 'UI'
    }

    function UI:add_element(element, name, world_scale, world_translation, on_top)
        local name = name or element.id
        local world_scale = world_scale or false
        local world_translation = world_translation or false
        local on_top = on_top or false

        element.hidden = false
        element.world_scale = world_scale
        element.world_translation = world_translation
        element.on_top = on_top

        self.elements[name] = element
    end

    function UI:add_image(image, quad, x, y, scale, mask, bob)
        local bob = bob or false
        local mask = mask or {1, 1, 1, 1}
        if type(quad) == 'number' then
            quad = image[quad]
        end
        local id = GID()

        self.images[id] = {image, quad, pos=vec2(x, y), scale = scale, mask = mask, bob = bob}
    end

    function UI:remove_element(id)
        self.elements[id] = nil

        function love.mousereleased() end
    end

    function UI:remove_image(id)
        self.images[id] = nil
    end

    function UI:update()
        self.bob_tick = self.bob_tick + self.current_bob

        if self.bob_tick > self.bob_max or self.bob_tick < self.bob_max*-1 then
            self.current_bob = self.current_bob * -1
        end

        for k,v in pairs(self.images) do
            if v ~= nil and v.bob == true then
                v.pos.y = v.pos.y + self.bob_tick/self.bob_speed
            end
        end

        for k,v in pairs(self.elements) do
            if v ~= nil and not v.hidden then
                v:update()
            end
        end
    end

    function UI:draw()

        for k,v in pairs(self.images) do
            if v ~= nil and not v.hidden then

                love.graphics.push()
                love.graphics.scale(screen_ratio[1], screen_ratio[2])
                
                if v.mask ~= nil then
                    love.graphics.setColor(v.mask)
                end

                if v[2] ~= nil then
                    love.graphics.draw(v[1], v[2], v.pos.x, v.pos.y, 0, v.scale)
                else
                    love.graphics.draw(v[1], v.pos.x, v.pos.y, 0, v.scale)
                end
                
                love.graphics.setColor(1,1,1,1)

                love.graphics.pop()
            end
        end

        for i = 1,2 do
            for k,v in pairs(self.elements) do
                love.graphics.push()

                love.graphics.setColor(1,1,1,1)

                love.graphics.scale(screen_ratio[1], screen_ratio[2])

                if v.world_scale == true and stack.world ~= nil then
                    love.graphics.reset()
                    stack.world:apply_scale()
                end

                if v ~= nil and not v.hidden then
                    if i == 1 and not v.on_top then
                        v:draw()
                    elseif i == 2 and v.on_top then
                        v:draw()
                    end
                end

                love.graphics.pop()
            end
        end
        
    end

    return setmetatable(UI, meta)
end

-- creates menu window with clipping and objects
-- also includes scrolling
function new_menu(x, y, w, h)
    local x = x or res[1]/2
    local y = y or res[2]/2
    local w = w or res[1] - 256
    local h = h or res[2] - 256

    local menu = {
        id = GID(),
        pos = vec2(x, y),
        w = w,
        h = h,
        pallettes = {},
        pallette = nil,
        scale = 5
    }

    menu.clip = {
        pos = vec2(menu.pos.x + 4 * menu.scale, menu.pos.y + 4 * menu.scale),
        w = menu.w - 8 * menu.scale,
        h = menu.h - 8 * menu.scale,
    }

    local meta = {
        type = 'obj'
    }

    function menu:scale_to_tile()
        self.w = math.ceil(self.w/(t_size * self.scale)) * (t_size * self.scale)
        self.h = math.ceil(self.h/(t_size * self.scale)) * (t_size * self.scale)
        self.clip.w = self.w - 8 * self.scale
        self.clip.h = self.h - 8 * self.scale
        self.tw = self.w/(t_size * self.scale)
        self.th = self.h/(t_size * self.scale)
    end

    function menu:make_pallete()
        local pallette = {
            pos = vec2(self.pos.x, self.pos.y),
            offsets = vec2(),
            ox = 0,
            oy = 0,
            w = self.tw * t_size * self.scale,
            h = self.th * t_size * self.scale,
            scale = self.scale,
            clip = self.clip,
            tw = self.tw,
            th = self.th,
            objects = {},
            can_scroll = true,
            done_scrolling = true,
        }

        function pallette:format()
            self.grid = array2D(self.tw, self.th)

            self.render_positions = {
                vec2(1, 1),
                vec2(#self.grid, #self.grid[1]),
            }

            for x = 1,#self.grid do
                for y = 1,#self.grid[1] do
                    self.grid[x][y] = {
                        objects = {}
                    }
                end
            end
        end

        function pallette:add_obj(x, y, w, h)
            local w = w or 100
            local h = h or 100
            local obj = {
                id = GID(),
                pos = vec2(self.pos.x + x, self.pos.y + y),
                w = w, 
                h = h,
                rendered = false,
                parent = self,
                child = nil,
                clip = shaders.reg_clip,
                scale = self.scale,
                box_points = {},
                focused = false,
                pre_ox = self.ox,
                pre_oy = self.oy
            }

            local meta = {
                type = 'object'
            }

            function obj:focus()
                if not self.focused then
                    if self.parent.done_scrolling then
                        self.pre_ox = self.parent.ox
                        self.pre_oy = self.parent.oy
                    end

                    local spx = self.pos.x + self.w/2
                    local spy = self.pos.y + self.h/2
                    local ppx = self.parent.pos.x + self.parent.w/2
                    local ppy = self.parent.pos.y + self.parent.h/2

                    local dx = ppx - spx
                    local dy = ppy - spy

                    self.parent:scroll('x', dx)
                    self.parent:scroll('y', dy)
                    self.parent.can_scroll = false
                else
                    self.parent.can_scroll = true
                    self.parent:scroll('x', self.pre_ox)
                    self.parent:scroll('y', self.pre_oy)
                end

                self.focused = not self.focused

            end

            function obj:format()
                -- clear potential past versions of the obj
                for i = 1,#self.box_points do
                    local px = self.box_points[i].x
                    local py = self.box_points[i].y

                    for i = 1,#self.parent.grid[px][py].objects do
                        local o = self.parent.grid[px][py].objects[i]
                        if o.id == self.id then
                            table.remove(self.parent.grid[px][py].objects, i)
                        end
                    end
                end

                -- define points of the obj
                local x = self.pos.x - self.parent.pos.x
                local y = self.pos.y - self.parent.pos.y
                local w = self.w
                local h = self.h

                self.box_points = {
                    vec2(x, y),
                    vec2(x + w, y),
                    vec2(x, y + h),
                    vec2(x + w, y + h)
                }
                
                -- find the tile the all of the points are in
                for i = 1,#self.box_points do
                    local px = self.box_points[i].x
                    local py = self.box_points[i].y
    
                    self.box_points[i] = vec2(
                        math.floor(px / (t_size * self.parent.scale)) + 1,
                        math.floor(py / (t_size * self.parent.scale)) + 1
                    )
                end

                -- apply the points to parents grid
                for i = 1, #self.box_points do
                    local px = self.box_points[i].x
                    local py = self.box_points[i].y
    
                    if px > #self.parent.grid or py > #self.parent.grid[1] then
                        local extx = 0
                        local exty = 0
    
                        if px > #self.parent.grid then extx = (px - #self.parent.grid) end
                        if py > #self.parent.grid[1] then exty = (py - #self.parent.grid[1]) end
    
                        for x = 1, #self.parent.grid + extx do
                            if self.parent.grid[x] == nil then self.parent.grid[x] = {} end
                            for y = 1, #self.parent.grid[1] + exty do

                                if self.parent.grid[x][y] == nil then self.parent.grid[x][y] = {
                                    objects = {}}
                                end

                            end
                        end
                    end

                    table.insert(self.parent.grid[px][py].objects, self)
                end
            end

            function obj:apply_clip_shader()
                self.clip:send('clip_pos', {self.parent.clip.pos.x, self.parent.clip.pos.y})
                self.clip:send('clipw', self.parent.clip.w)
                self.clip:send('cliph', self.parent.clip.h)
            end

            function obj:check_partial_render() 
            end

            function obj:add_child(child)
                assert(child.pos ~= nil, 'child has no position')
                assert(child.w ~= nil, 'child has no width')
                assert(child.h ~= nil, 'child has no height')
                assert(child.draw ~= nil, 'child has no draw function')
                assert(child.update ~= nil, 'child has no update function')
                assert(child.scale ~= nil, 'child has no scale')

                self.w = child.w
                self.h = child.h
                child.pos.x = self.pos.x
                child.pos.y = self.pos.y
                child.scale = self.scale

                self.child = child

                self:format()
            end

            function obj:update()
                print(self:check_partial_render())

                if self.child ~= nil then
                    self.child.update(self.child)
                    self.child.pos.x = self.pos.x + self.parent.ox
                    self.child.pos.y = self.pos.y + self.parent.oy
                end

            end

            function obj:draw()
                self:apply_clip_shader()
                love.graphics.setShader(self.clip)
                love.graphics.rectangle('fill', self.pos.x + self.parent.ox, self.pos.y + self.parent.oy, self.w, self.h)
                if self.child ~= nil then
                    self.child.draw(self.child)
                end

                love.graphics.setShader()
            end

            return obj
        end

        function pallette:get_render()
            local p1 = math.floor((self.ox + (0) * t_size * self.scale)/t_size/self.scale)
            local p2 = math.floor((self.oy + (0) * t_size * self.scale)/t_size/self.scale)
            local p3 = math.floor((self.ox + (#self.grid) * t_size * self.scale)/t_size/self.scale)
            local p4 = math.floor((self.oy + (#self.grid[1]) * t_size * self.scale)/t_size/self.scale)

            if p1 < 0 then
                self.render_positions[1].x = math.abs(p1)
            end

            if p2 < 0 then
                self.render_positions[1].y = math.abs(p2)
            end

            if p3 > self.tw - 1 then
                self.render_positions[2].x = #self.grid - (p3 - self.tw)
            end

            if p4 > self.th - 1 then
                self.render_positions[2].y = #self.grid[1] - (p4 - self.th)
            end
        end

        function pallette:scroll(axis, dir)
            if not self.can_scroll then return end
            local axis = axis or 'x'
            self.offsets[axis] = dir
        end

        function pallette:update()
            self:get_render()

            local dx = (self.ox - self.offsets.x)
            local dy = (self.oy - self.offsets.y)
            self.ox = self.ox - dx/8
            self.oy = self.oy - dy/8

            self.done_scrolling = math.abs(dx) < 0.5 and 
                                  math.abs(dy) < 0.5

            if love.keyboard.isDown('down') then
                self:scroll('y', self.offsets.y + 5)
            end

            if love.keyboard.isDown('up') then
                self:scroll('y', self.offsets.y - 5)
            end

            if love.keyboard.isDown('right') then
                self:scroll('x', self.offsets.x + 5)
            end

            if love.keyboard.isDown('left') then
                self:scroll('x', self.offsets.x - 5)
            end

            self.objects = {}
            for x = self.render_positions[1].x, self.render_positions[2].x do
                for y = self.render_positions[1].y, self.render_positions[2].y do
                    for o = 1,#self.grid[x][y].objects do
                        local obj = self.grid[x][y].objects[o]
                        if obj.rendered == false then
                            obj.rendered = true
                            obj:update()
                            table.insert(self.objects, obj)
                        end
                    end
                end
            end
        end

        function pallette:draw()
            for x = self.render_positions[1].x, self.render_positions[2].x do
                for y = self.render_positions[1].y, self.render_positions[2].y do

                    love.graphics.rectangle('line', self.pos.x + self.ox + (x -1) * t_size * self.scale,
                                                    self.pos.y + self.oy + (y -1) * t_size * self.scale,
                                                    t_size * self.scale, t_size * self.scale)

                end
            end

            for i = 1,#self.objects do
                self.objects[i]:draw()
                self.objects[i].rendered = false
            end
        end

        pallette:format()

        table.insert(self.pallettes, pallette)
        self.pallette = #self.pallettes

        return pallette
    end

    function menu:align(side, p)
        self:scale_to_tile()
        local side = side or 'center'
        local sides = {'w', 'h'}
        local positions = split_str(p)
        local index = 1

        for i = 1,#positions do
            if side == 'center' then
                self.pos[positions[i]] = self.pos[positions[i]] - self[sides[i]]/2
                self.clip.pos[positions[i]] = self.clip.pos[positions[i]] - self[sides[i]]/2

            elseif side == 'right' then
                self.pos[positions[i]] = self.pos[positions[i]] - self[sides[i]]
                self.clip.pos[positions[i]] = self.clip.pos[positions[i]] - self[sides[i]]
            elseif side == 'left' then
                return
            end
        end
    end

    function menu:update()
        if self.pallette ~= nil then
            self.pallettes[self.pallette]:update()
        end
    end

    function menu:draw()
        for x = 0, self.tw - 1 do
            for y = 0, self.th - 1 do
                local quad = get_background_quad(x, y, self.tw, self.th)
                love.graphics.draw(menu_bg.sheet, menu_bg[quad], 
                    self.pos.x + (x * t_size * self.scale), 
                    self.pos.y + (y * t_size * self.scale), 
                    0, self.scale)
            end
        end

        -- love.graphics.rectangle('line', self.pos.x, self.pos.y, self.w, self.h)
        -- love.graphics.rectangle('line', self.clip.pos.x, self.clip.pos.y, self.clip.w, self.clip.h)

        if self.pallette ~= nil then
            self.pallettes[self.pallette]:draw()
        end

    end

    return setmetatable(menu, meta)
end

-- defines the minimap
function minimap(world, x, y, map_scale)
    local map_scale = map_scale or 2
    local mini_map = {
        id = GID(),
        chunk_array = array2D(world.w/world.chunk_size, world.h/world.chunk_size),
        world = world,
        w = world.w*map_scale,
        h = world.h*map_scale,
        pos = vec2(x, y),
        map_scale = map_scale,
        chunk_size = world.chunk_size * map_scale,
        og_tile_zoom = pix_scale,
        tile_zoom = pix_scale,
        seen = {},
        current = 1,
        zoom = minimap_scale,
        ozoom = minimap_scale,
        ox = 0,
        oy = 0,
        do_box = true
    }

    mini_map.w = math.ceil((#mini_map.chunk_array + 1) * (16 * mini_map.map_scale * mini_map.zoom) / (16 * mini_map.map_scale)) * (16*mini_map.map_scale)
    mini_map.h = math.ceil((#mini_map.chunk_array[1] + 1) * (16 * mini_map.map_scale * mini_map.zoom) / (16 * mini_map.map_scale)) * (16*mini_map.map_scale)

    function mini_map:align(side)
        local side = side or 'center'

        if side == 'center' then
            self.pos.x = self.pos.x - self.w/2
        elseif side == 'right' then
            self.pos.x = self.pos.x - self.w
        elseif side == 'left' then
            return
        end
    end

    function mini_map:add_chunk(x, y)
        -- adds chunk data to chunks
        self.chunk_array[x][y] = {
            seen = false
        }
    end

    -- updates the minimap
    function mini_map:update()
        if love.keyboard.isDown('tab') then
            for k,v in pairs(stack.UI.elements) do
                if v ~= self then
                    v.hidden = true
                end
            end

            self.zoom = self.zoom + (2 - self.zoom)/2

            if self.tile_zoom == self.og_tile_zoom then
                self.tile_zoom = self.tile_zoom * self.zoom
            end
        else
            for k,v in pairs(stack.UI.elements) do
                v.hidden = false
            end

            -- self.zoom = self.ozoom
            self.zoom = self.zoom + (self.ozoom - self.zoom)/2

            self.tile_zoom = self.og_tile_zoom
        end

        local real_w = math.ceil((#self.chunk_array + 1) * (16 * self.map_scale * self.zoom) / (16 * self.map_scale)) * (16*self.map_scale)
        local real_h = math.ceil((#self.chunk_array + 1) * (16 * self.map_scale * self.zoom) / (16 * self.map_scale)) * (16*self.map_scale)

        local chunk_w = (#self.chunk_array * self.chunk_size * self.zoom)
        local chunk_h = (#self.chunk_array[1] * self.chunk_size * self.zoom)


        self.ox = (real_w - chunk_w)/2
        self.oy = (real_h - chunk_h)/2

        if self.do_box == false then
            self.ox = 0 
            self.oy = 0
        end
    end

    -- draws mini map
    function mini_map:draw()

        if self.do_box then
            local real_w = (#self.chunk_array + 1) * (16 * self.map_scale * self.zoom)
            local real_h = (#self.chunk_array + 1) * (16 * self.map_scale * self.zoom)
            

            local tile_w = math.ceil(real_w / (16 * self.map_scale))
            local tile_h = math.ceil(real_h / (16 * self.map_scale))


            for w = 0, tile_w - 1 do
                for h = 0, tile_h - 1 do
                    local quad = get_background_quad(w, h, tile_w, tile_h)

                    love.graphics.draw(menu_bg.sheet, menu_bg[quad], self.pos.x + (w * 16 * self.map_scale), 
                                                                    self.pos.y + (h * 16 * self.map_scale), 0, self.map_scale)

                end
            end
        end

        local c_pos = vec2(self.world.focus_ent.chunk_pos.x, self.world.focus_ent.chunk_pos.y)

        for x = 0,#self.chunk_array - 1 do
            for y = 0,#self.chunk_array[x] - 1 do
                local quad = 1

                if x == c_pos.x and y == c_pos.y then
                    if self.chunk_array[x][y].seen == false then
                        self.chunk_array[x][y].seen = true
                    end

                    quad = 3

                elseif self.chunk_array[x][y].seen == true then
                    quad = 2
                end

                if self.chunk_array[x][y].seen ~= nil then
                    love.graphics.draw(mini_map_sheet.sheet, mini_map_sheet[quad], 
                    self.pos.x + x*self.chunk_size * self.zoom + self.ox - (self.chunk_size * self.zoom)/2, 
                    self.pos.y + y*self.chunk_size * self.zoom + self.oy - (self.chunk_size * self.zoom)/2, 
                    0, (self.chunk_size/16) * self.zoom)

                    love.graphics.draw(mini_map_sheet.sheet, mini_map_sheet[quad + 3], 
                    self.pos.x + x*self.chunk_size * self.zoom + self.ox - (self.chunk_size * self.zoom)/2, 
                    self.pos.y + y*self.chunk_size * self.zoom + self.oy + (self.chunk_size * self.zoom)/2, 
                    0, (self.chunk_size/16) * self.zoom)
                end
            end
        end
    end

    return mini_map
end

-- creates a button
function new_button(x, y, w, h, ox, oy, sheet, q1, q2, q3, scale)
    local scale = scale or 1
    local w = w or sheet.qw
    local h = h or sheet.qh
    local oy = oy or 0
    local ox = ox or 0
    local button = {
        id = GID(),
        pos = vec2(x, y),
        w = w,
        h = h,
        ox = ox,
        oy = oy,
        sheet = sheet,
        quads = {
            q1,
            q2,
            q3
        },
        quad = 1,
        scale = scale,
        func = nil
    }

    local meta = {
        type = 'button'
    }

    -- adds a function to the button
    function button:set_function(func, ...)
        self.func = {func=func, params={...}}
    end

    -- updates the button
    function button:update()
        local x, y = love.mouse.getPosition()

        local x = x/screen_ratio[1]
        local y = y/screen_ratio[2]

        if x > self.pos.x and
            y > self.pos.y and
            x < self.pos.x + (self.w) and
            y < self.pos.y + (self.h) then
                if love.mouse.isDown(1) then
                    self.quad = 3
                    function love.mousereleased(x, y, button)
                        if button == 1 then
                            if self.func ~= nil then
                                self.func.func(unpack(self.func.params))
                            end
                        end
                    end
                else
                    self.quad = 2
                end
        else
            self.quad = 1    
        end
    end

    -- draws the button
    function button:draw()
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.draw(self.sheet.sheet, self.sheet[self.quads[self.quad]], 
                        self.pos.x-(self.ox), self.pos.y-(self.oy), 0, self.scale)
    end

    return setmetatable(button, meta)
end

-- create a health bar
function new_bar(ent, x, y, bar_quad, main_index, sudo_index)
    local scale = scale or pix_scale
    local color = color or {1, 1, 1}
    local bar = {
        id = GID(),
        ent = ent,
        index = index,
        pos = vec2(x, y),
        pct = 1,
        scale = scale,
        sheet = bar_sheet,
        ox = 0,
        bar_count = 4,
        color,
        sudo_max = 1,
        pct = 1,
        main_index = main_index,
        sudo_index = sudo_index,
        bar_quad = bar_quad,
        icon_quad = 63,
        icon_sheet = UI_icons,
        end_offset = 0.71,
        end_point = true
    }

    bar.bar_count = bar.bar_count + math.ceil(bar.end_offset)

    bar.bar_w = (bar.bar_count)*bar.sheet.qw*bar.scale
    bar.w = (bar.bar_count)*bar.sheet.qw*bar.scale
    bar.h = bar.sheet.qw*bar.scale

    local meta = {
        type = 'bar'
    }

    function bar:set_bar_count(count)
        self.bar_count = count

        self.bar_count = self.bar_count + math.ceil(self.end_offset)
        self.bar_w = (bar.bar_count)*bar.sheet.qw*self.scale
        self.w = (self.bar_count)*bar.sheet.qw*self.scale
        self.h = self.sheet.qw*self.scale
    end

    function bar:align(side)
        local side = side or 'center'

        if side == 'center' then
            self.pos.x = self.pos.x - self.w/2
        elseif side == 'right' then
            self.pos.x = self.pos.x - self.w
        elseif side == 'left' then
            return
        end
    end

    function bar:update()
        if self.sudo_index ~= nil then self.sudo_max = self.ent.bar_pcts[self.sudo_index] end
        if self.sudo_max == nil then self.sudo_max = 1 end

        if self.main_index ~= nil then self.pct = self.ent.bar_pcts[self.main_index] end
        if self.pct == nil then self.pct = 1 end
    end


    function bar:draw()
        local end_offset = self.end_offset * self.sheet.qw * self.scale

        for i = 1,self.bar_count do
            local quad = 2
            local ox = 0

            if i == self.bar_count then
                quad = 3
                ox = end_offset
            end

            love.graphics.draw(self.sheet.sheet, self.sheet[quad], self.pos.x + i*self.bar_w/self.bar_count - self.ox - ox, self.pos.y, 0, self.scale)
        end

        local control_pos = vec2(
            self.pos.x + (self.bar_w - end_offset) * self.pct - (4*self.scale),
            self.pos.y
        )

        if control_pos.x < self.pos.x then
            control_pos.x = self.pos.x
        end

        for i = 1,self.bar_count do
            local pos = vec2(
                self.pos.x + i*self.bar_w/(self.bar_count),
                self.pos.y
            )

            if i == self.bar_count or pos.x >= control_pos.x then
                pos = control_pos
            end

            love.graphics.draw(bar_colors.sheet, bar_colors[self.bar_quad], pos.x - self.ox, pos.y, 0, self.scale)
        end

        love.graphics.setColor(1,1,1)

        if self.end_point then
            love.graphics.draw(self.sheet.sheet, self.sheet[4], 
                            (self.pos.x + (self.bar_w - end_offset) * self.sudo_max) + self.sheet.qw*self.scale - self.ox - 5*self.scale, 
                            self.pos.y, 0, self.scale)
        end

        love.graphics.draw(self.sheet.sheet, self.sheet[1], self.pos.x - self.ox, self.pos.y, 0, self.scale)
        love.graphics.draw(self.icon_sheet.sheet, self.icon_sheet[self.icon_quad], self.pos.x - self.ox + (4 * self.scale), self.pos.y + (4 * self.scale), 0, self.scale)
    end

    return setmetatable(bar, meta)
end

-- create text
function new_text_element(x, y, w, h, color, fade_off, fade_time)
    local w = w or 16
    local h = h or 16
    local color = color or {0,0,0}
    local fade_off = fade_off or 1
    local fade_time = fade_time or 0

    local text = {
        id = GID(),
        box = {w=w, h=h},
        do_box = true,
        pos = vec2(x, y),
        lines = {},
        color = color,
        outline = {0, 0, 0, 0.5},
        scale = 0.15,
        line_width = 1,
        center = false,
        fade_off = fade_off,
        fade_time = fade_time,
        do_fade = false,
        current_fade = 1,
        ox = 0,
        oy = 0,
        w_buffer = 0,
        h_buffer = 0,
        tile_zoom = 1,
    }

    if stack ~= nil then text.UI = stack.UI end

    if fade_time > 0 then
        text.fade_time = new_timer(fade_time)
    end

    local meta = {
        type = 'text_box'
    }


    function text:addlines(...)
        local t = {...}

        for i = 1,#t do
            local color = {1,1,1,1}
            if type(t[i]) == 'table' then
                if #t[i][2] < 4 then
                    t[i][2][4] = 1
                end
                color = t[i][2]
            end
            table.insert(self.lines, {line = love.graphics.newText(font, t[i]), color = color})
        end
    end

    function text:set_line(line, text, color)
        local color = color or {1, 1, 1, 1}

        if #color < 4 then color[4] = 1 end

        local text = love.graphics.newText(font, text)

        self.lines[line] = {line = text, color = color}

        return self.lines
    end

    function text:update()
        if self.fade_time ~= 0 then
            if self.fade_time:tick() then
                self.do_fade = true
            end
        end

        local w = self.lines[1].line:getWidth()

        for i = 1,#self.lines do
            if i > 1 then
                for l = 1, i do
                    if self.lines[i].line:getWidth() > self.lines[l].line:getWidth() then
                        w = self.lines[i].line:getWidth()
                    else
                        break
                    end
                end
            end
        end

        self.box.w = (w + self.w_buffer) * self.scale
        self.box.h = (#self.lines * self.lines[1].line:getHeight() + self.h_buffer) * self.scale

        if self.do_fade == true then
            if self.current_fade < 0.01 then
                if self.UI ~= nil then
                    stack.UI:remove_element(self.id)
                end
            end

            self.current_fade = self.current_fade * self.fade_off
        end
    end


    function text:draw()
        if #self.lines >= 1 then
            local ox = self.ox
            local oy = self.oy

            if self.center then
                ox = (self.box.w/2) + self.ox
                oy = (self.box.h/2) + self.oy
            end

            if self.do_box == true then
                love.graphics.setColor(1, 2, 3, self.color[4] * self.current_fade)

                local tw = math.ceil(self.box.w/(16 * self.tile_zoom))
                local th = math.ceil(self.box.h/(16 * self.tile_zoom))

                if self.box.w > tw * (16 * self.tile_zoom) - 5 then tw = tw + 1 end
                if th == 1 then th = 2 end

                local total_width = tw * (16 * self.tile_zoom)
                local total_height = th * (16 * self.tile_zoom)

                local w_offset = total_width - self.box.w
                local h_offset = total_height - self.box.h
 
                for w = 0, tw - 1 do
                    for h = 0, th - 1 do
                        local quad = get_background_quad(w, h, tw, th)

                        love.graphics.draw(menu_bg.sheet, menu_bg[quad], self.pos.x - ox + (w * 16 * self.tile_zoom) - w_offset/2, self.pos.y - oy + (h * 16 * self.tile_zoom) - h_offset/2, 0, self.tile_zoom)
                    end
                end
            end

            for i = 1,#self.lines do

                love.graphics.setColor(self.lines[i].color[1], self.lines[i].color[2], self.lines[i].color[3], self.lines[i].color[4] * self.current_fade)
                love.graphics.draw(self.lines[i].line, 
                                    self.pos.x + self.box.w/2 - (self.lines[i].line:getWidth() * self.scale)/2 - ox, 
                                    self.pos.y + (self.h_buffer/4) + (i - 1) * (self.lines[i].line:getHeight() * self.scale) - oy, 
                                    0, self.scale, self.scale)
            end

        end

        love.graphics.setColor(1,1,1,1)

    end

    return setmetatable(text, text_box)

end

-- create text for cards
function new_card_text(x, y, scale)
    local text = {
        pos = vec2(x, y),
        id = GID(),
        text = {},
        w = 0,
        h = 0,
        text_h = 0,
        scale = scale or 1,
        h_offset = 0,
        color_offset = 0
    }

    local meta = {
        type = 'card_text'
    }

    function text:add_text(text, color, underline, sheet, quad, iscale)
        local color = color or {1,1,1,1}
        local underline = underline or false
        local iscale = iscale or pix_scale
        table.insert(self.text, {text = love.graphics.newText(font, text),  
                                color = color,
                                pos = vec2(),
                                underline = underline,
                                sheet = sheet,
                                quad = quad,
                                iscale = iscale,
                                alignment = 'center'})

        self.h = #self.text * self.text[#self.text].text:getHeight() * self.scale
    end

    function text:update()
        for i = 1,#self.text do
            if self.text[i].text:getWidth() * self.scale > self.w then
                self.w = self.text[i].text:getWidth() * self.scale
            end
        end
    end


    function text:draw()
        for i = 1,#self.text do
            local c1 = self.text[i].color[1] - self.color_offset/2
            local c2 = self.text[i].color[2] - self.color_offset/2
            local c3 = self.text[i].color[3] - self.color_offset/2
            local c4 = self.text[i].color[4] - self.color_offset

            love.graphics.setColor(c1, c2, c3, c4)

            local h = self.text[i].text:getHeight() * self.scale
            local w = self.text[i].text:getWidth() * self.scale
            local ox = 0

            if self.text[i].sheet ~= nil then
                ox = self.text[i].sheet.qw * self.text[i].iscale
                w = w + ox
            end

            local px = self.pos.x + self.w/2 - w/2 + ox
            local py = self.pos.y + (i-1) * (h - self.h_offset)
            
            if self.text[i].alignment == 'left' then
                px = self.pos.x + self.w/2
            elseif self.text[i].alignment == 'right' then
                px = self.pos.x + w
            end


            love.graphics.draw(self.text[i].text, px, py, 0, self.scale)

            if self.text[i].underline then
                love.graphics.setLineWidth(2)

                love.graphics.line(px, py + h, px + w, py + h)
            end

            if self.text[i].sheet ~= nil then
                local c = 1 - self.color_offset
                love.graphics.setColor(c,c,c,c)
                love.graphics.draw(self.text[i].sheet.sheet, self.text[i].sheet[self.text[i].quad], px - ox, py, 0, self.text[i].iscale)

            end
        end 
    end

    return setmetatable(text, meta)
end

-- make character card
function new_character_card(x, y, character, rarity, scale)
    local scale = scale or 8
    local rarity = rarity or 1
    local card = {
        id = GID(),
        pos = vec2(x, y),
        cpos = vec2(x + (cards.sheet:getWidth()*scale/#cards)/2 - 8*scale, y + (cards.sheet:getHeight()*scale)/2 - 15*scale),
        opos = vec2(x, y),
        pos_goal = vec2(x, y),
        center_pos = vec2(res[1]/2, res[2]/2),
        w = cards.sheet:getWidth()*scale/#cards,
        h = cards.sheet:getHeight()*scale,
        scale = scale,
        oscale = scale,
        scale_objective = scale,
        rarity = rarity,
        character = character + 0,
        centered = false,
        zoomed = false,
        focused = false,
        goal_div = 8,
        can_focus = true,
        is_transitioning = false,
    }

    local meta = {
        type = 'character_card'
    }

    function card:center()
        if not self.centered then
            self.centered = true
            self.pos = vec2(self.pos.x - (cards.sheet:getWidth()*self.scale/#cards)/2, self.pos.y - (cards.sheet:getHeight()*self.scale)/2)
            self.cpos = vec2(self.pos.x - 8*self.scale, self.pos.y - 15*self.scale)
        end
    end

    function card:focus()
        if not self.focused then
            self.scale_objective = self.oscale + 2
            self.pos_goal.x = self.pos.x - (self.pos.x - res[1]/2 + self.w/2)
            self.pos_goal.y = self.pos.y - (self.pos.y - res[2]/2 + self.h/2)
        else
            self.scale_objective = self.oscale

            local ow = cards.sheet:getWidth()*self.oscale/#cards
            local oh = cards.sheet:getHeight()*self.oscale
            
            local dx = self.w - ow
            local dy = self.h - oh

            self.pos_goal.x = self.opos.x - dx/2
            self.pos_goal.y = self.opos.y - dy/2
        end

        self.focused = not self.focused
    end

    function card:zoom(amount)
        if not self.zoomed and not self.focued then
            self.scale_objective = self.oscale + amount
        elseif not self.focused then
            self.scale_objective = self.oscale
        end

        self.zoomed = not self.zoomed
    end

    function card:update()
        local scale_dist = math.floor(self.scale_objective - self.scale)

        local ow = self.w; local oh = self.h
        self.w = cards.sheet:getWidth()*self.scale/#cards
        self.h = cards.sheet:getHeight()*self.scale

        local dx = self.w - ow
        local dy = self.h - oh

        self.pos = vec2(self.pos.x - dx/2, self.pos.y - dy/2)
        
        self.pos_goal.x = self.pos_goal.x - dx/2
        self.pos_goal.y = self.pos_goal.y - dy/2
        
        self.pos.x = self.pos.x - (self.pos.x - self.pos_goal.x)/self.goal_div
        self.pos.y = self.pos.y - (self.pos.y - self.pos_goal.y)/self.goal_div

        self.cpos = vec2(self.pos.x + (cards.sheet:getWidth()*self.scale/#cards)/2 - 8*self.scale, 
        self.pos.y + (cards.sheet:getHeight()*self.scale)/2 - 15*self.scale)

        if math.abs(self.scale - self.scale_objective) < 0.05 then
            self.scale = self.scale_objective
        end

        if math.abs(self.pos.x - self.pos_goal.x) < 0.5 then
            self.pos.x = self.pos_goal.x
            self.is_transitioning = false
        else
            self.is_transitioning = true
        end

        if math.abs(self.pos.y - self.pos_goal.y) < 0.5 then
            self.pos.y = self.pos_goal.y
            self.is_transitioning = false
        else
            self.is_transitioning = true
        end

        if self.scale < self.scale_objective - 0.1 then
            self.scale = self.scale + 0.1

        elseif self.scale > self.scale_objective then
            self.scale = self.scale - 0.1
        end

        local x, y = love.mouse.getPosition()

        local x = x/screen_ratio[1]
        local y = y/screen_ratio[2]

        if not self.is_transitioning then
            if x > self.pos.x and
                y > self.pos.y and
                x < self.pos.x + (self.w) and
                y < self.pos.y + (self.h) then
                    if love.mouse.isDown(1) then
                        function love.mousereleased(x, y, button)
                            if button == 1 then
                                self:focus()
                            end
                        end
                    else
                        if self.zoomed == false then
                            self:zoom(self.scale * (1/8))
                        end
                    end
            else
                if self.zoomed and not self.focused then
                    self:zoom()
                end
            end
        end
    end

    function card:draw()
        love.graphics.draw(cards.sheet, cards[self.rarity], self.pos.x, self.pos.y, 0, self.scale)
        love.graphics.draw(character_cards.sheet, character_cards[self.character], 
        self.pos.x + (cards.sheet:getWidth()*self.scale/#cards)/2 - 8*self.scale, 
        self.pos.y + (cards.sheet:getHeight()*self.scale)/2 - 15*self.scale, 
        0, self.scale)
    end

    return setmetatable(card, meta)
end

-- makes a menu for cards
function new_card_menu(x, y, w, h, scale)
    local scale = scale or 8
    local button_scale = 5
    local menu = {
        id = GID(),
        pages = {
            {},
        },
        transitioning = {},
        pos = vec2(x - (w * 16 * scale)/2, y - (h * 16 * scale)/2),
        w = w+1, -- in tiles
        h = h, -- in tiles
        rw = (w * 16 * scale),
        rh = (h * 16 * scale),
        scale = scale,
        card_scale = 2,
        current_page = 1,
        text = '',
        priority_card = nil,
        focused_card = nil
    }

    local meta = {
        type = 'card_menu'
    }

    menu.card_size = {w = (cards.sheet:getWidth()/#cards)*(scale/menu.card_scale), --pixel size of cards
                    h = cards.sheet:getHeight()*(scale/menu.card_scale)}

    local cardx = math.floor((menu.rw)/(menu.card_size.w)) -- how many cards can fit in a menu (x axis)
    local cardy = math.floor((menu.rh)/(menu.card_size.h)) -- how many cards can fit in a menu (y axis)

    menu.cardx = cardx; menu.cardy = cardy

    local px = (menu.pos.x + menu.rw/2 - (menu.cardx*menu.card_size.w)/2)
    local py = (menu.pos.y + menu.rh/2 - (menu.cardy*menu.card_size.h)/2) - 4*menu.scale/menu.card_scale

    local opx = px
    local opy = py

    for i = 1,#player_data.cards do
        for c = 1,#player_data.cards[i] do
            if #menu.pages[#menu.pages] == cardx * cardy then
                table.insert(menu.pages, {})
                px = opx
                py = opy
            end

            if px >= menu.rw then
                py = py + menu.card_size.h + 4*menu.scale/menu.card_scale
                px = (menu.pos.x + menu.rw/2 - (menu.cardx*menu.card_size.w)/2)
            end

            local card = new_character_card(px, py, player_data.cards[i][c].skin, i, menu.scale/menu.card_scale)

            px = px + menu.card_size.w

            table.insert(menu.pages[#menu.pages], card)

        end
    end

    menu.back_button = new_button(menu.pos.x - 37 - (4*menu.scale), menu.pos.y + menu.rh - 20*button_scale, 
                                    21*button_scale, 20*button_scale, 0, 0, small_buttons, 13, 14, 15, button_scale)

    menu.forward_button = new_button(menu.pos.x + menu.rw - 20*button_scale + 32 + (4*menu.scale), menu.pos.y + menu.rh - 20*button_scale, 
                                    21*button_scale, 20*button_scale, 0, 0, small_buttons, 10, 11, 12, button_scale)

    menu.close_button = new_button(menu.pos.x + menu.rw - 20*button_scale + 32 + (4*menu.scale), menu.pos.y, 
                                    21*button_scale, 20*button_scale, 0, 0, small_buttons, 4, 5, 6, button_scale)

    function menu:move_page(dir)
        if self.pages[self.current_page + dir] ~= nil then
            --self.transitioning = {}
            self.focused_card = nil
            self.priority_card = nil

            for k,v in pairs(self.pages[self.current_page]) do
                self.transitioning[#self.transitioning + 1] = new_character_card(v.pos.x, v.pos.y, v.character, v.rarity, v.scale)
            end

            for i = 1,#self.transitioning do
                if dir < 0 then
                    self.transitioning[i].pos_goal = vec2(self.transitioning[i].pos.x, current_res[2] + self.transitioning[i].h + 20)
                else
                    self.transitioning[i].pos_goal = vec2(self.transitioning[i].pos.x, -2 * (self.transitioning[i].h + 20))
                end
                self.transitioning[i].goal_div = math.random(16, 24)
            end

            for i = 1,#self.pages[self.current_page] do
                if self.pages[self.current_page][i].focused then
                    self.pages[self.current_page][i]:focus()
                    self.pages[self.current_page][i].scale = self.pages[self.current_page][i].oscale
                end
                self.pages[self.current_page][i].zoomed = false
            end

            self.current_page = self.current_page + dir

            for i = 1,#self.pages[self.current_page] do
                if dir < 0 then
                    self.pages[self.current_page][i].pos.y = -current_res[2]
                else
                    self.pages[self.current_page][i].pos.y = current_res[2] + self.pages[self.current_page][i].h + 20
                end
            end
        end
    end

    menu.back_button:set_function(menu.move_page, menu, -1)
    menu.forward_button:set_function(menu.move_page, menu, 1)
    menu.close_button:set_function(title_screen, stack)

    function menu:update()
        function love.mousereleased(x, y, button)
        end

        if self.current_page < #self.pages then
            self.forward_button:update()
        end

        if self.current_page > 1 then
            self.back_button:update()
        end

        self.priority_card = nil

        for i = 1,#self.transitioning do
            if self.transitioning[i] ~= nil then
                self.transitioning[i]:update()

                if self.transitioning[i].pos.y > current_res[2] or self.transitioning[i].pos.y < -self.transitioning[i].h then
                    table.remove(self.transitioning, i)
                end
            end
        end

        if self.focused_card ~= nil then
            self.focused_card:update()

            if self.focused_card.focused == false and 
                self.focused_card.pos.x == self.focused_card.pos_goal.x and
                self.focused_card.pos.y == self.focused_card.pos_goal.y then
                self.focused_card = nil
            end
        else
            for i = 1,#self.pages[self.current_page] do
                if self.pages[self.current_page][i].zoomed then
                    if self.priority_card == nil then
                        self.priority_card = self.pages[self.current_page][i]
                    end
                end

                if self.pages[self.current_page][i].focused then
                    self.focused_card = self.pages[self.current_page][i]
                end

                self.pages[self.current_page][i]:update()
            end
        end

        self.close_button:update()

        self.text = 'page: ' .. self.current_page .. ' / ' .. #self.pages
        self.image_text = love.graphics.newText(font, self.text)
    end

    function menu:draw()
        love.graphics.setColor(bg_color)
        love.graphics.rectangle('fill', 0, 0, res[1], res[2])
        love.graphics.setColor(1,1,1,1)

        for w = 0, self.w-1 do
            for h = 0,self.h-1 do
                local quad = get_background_quad(w, h, self.w, self.h)

                love.graphics.draw(menu_bg.sheet, menu_bg[quad], self.pos.x + (w*16*self.scale) - (8*self.scale), self.pos.y + (h*16*self.scale), 0, self.scale)
            end
        end

        for i = 1,#self.pages[self.current_page] do
            if self.priority_card ~= nil and self.pages[self.current_page].id ~= self.priority_card.id or self.priority_card == nil then
                self.pages[self.current_page][i]:draw()
            end
        end

        if self.priority_card ~= nil then
            self.priority_card:draw()
        end

        if self.focused_card ~= nil then
            self.focused_card:draw()
        end

        for i = 1,#self.transitioning do
            if self.transitioning[i] ~= nil then
                self.transitioning[i]:draw()
            end
        end

        if self.current_page < #self.pages then
            self.forward_button:draw()
        end

        if self.current_page > 1 then
            self.back_button:draw()
        end

        self.close_button:draw()

        love.graphics.setColor(0.7, 0.7, 0.7, 0.2)

        love.graphics.draw(self.image_text, self.pos.x + 32 - (6*self.scale), self.pos.y + 36, 0, 0.75)
        
        love.graphics.setColor(1,1,1,1)
    end

    return setmetatable(menu, meta)
end

-- makes a mask for "pi graph style" cool down bar
function new_circle_cooldown_mask(x, y, radius, color)
    local color = color or {1, 1, 1,1}
    local mask = {
        id = GID,
        pos = vec2(x, y),
        radius = radius,
        color = color,
        fill = 'fill',
        type = 'pie',
        pct = 1
    }
    
    function mask:tick(pct)
        self.pct = pct
    end

    function mask:update()

    end

    function mask:draw()
        if self.pct == 0 then return end

        love.graphics.setColor(self.color)
        love.graphics.arc(self.fill, self.type, self.pos.x + self.radius + 1, self.pos.y + self.radius + 1, self.radius, 0, (math.pi*2) * self.pct, 64)
        love.graphics.setColor(1,1,1,1)
    end



    local meta = {
        type = 'cooldown_mask'
    }

    return setmetatable(mask, meta)
end

-- makes a "pi graph style" cool down bar
function new_cooldown_circle(x, y, color, scale)
    local color = color or {1,1,1,0.2}
    local scale = scale or pix_scale
    local w = (circle_cooldown.sheet:getWidth()/#circle_cooldown) * scale
    local h = (circle_cooldown.sheet:getHeight()) * scale

    local circ = {
        id = GID(),
        w = w,
        h = h,
        mask = new_circle_cooldown_mask(x, y, w/2 - 1, color),
        pos = vec2(x, y),
        scale = scale,
        icon = nil
    }

    local meta = {
        type = 'cooldown_circ'
    }

    function circ:tick(pct)
        if pct > 0 then
            self.mask:tick(pct)
        end
    end

    function circ:add_icon(sheet, quad, w, h)
        local w = w * self.scale
        local h = h * self.scale
        self.icon = {
            sheet = sheet,
            quad = quad,
            w = w,
            h = h,
        }
    end

    function circ:update()
        self.mask:update()
        self.mask.pos.x = self.pos.x
        self.mask.pos.y = self.pos.y
    end

    function circ:draw()
        love.graphics.draw(circle_cooldown.sheet, circle_cooldown[2], self.pos.x, self.pos.y, 0, self.scale)
        self.mask:draw()
        love.graphics.draw(circle_cooldown.sheet, circle_cooldown[1], self.pos.x, self.pos.y, 0, self.scale)

        if self.icon ~= nil then
            love.graphics.draw(self.icon.sheet.sheet, self.icon.sheet[self.icon.quad], self.pos.x + self.icon.w/2, self.pos.y + self.icon.h/2, 0, self.scale)
        end
    end

    return setmetatable(circ, meta)
end

-- makes a bar style cool down bar
function new_cooldown_bar(x, y, scale, bar_count)
    local bar = {
        id = GID(),
        pos = vec2(x, y),
        bar = new_bar(nil, x, y, 4),
        pct = 1
    }

    bar.bar.end_point = false

    local meta = {
        type = 'cooldown_bar'
    }

    function bar:tick(pct)
        if pct >= 0 then
            self.bar.pct = pct
            self.pct = pct
        end
    end

    function bar:update()
        self.bar.pos.x = self.pos.x
        self.bar.pos.y = self.pos.y

        self.bar:update()
    end

    function bar:draw()
        self.bar:draw()
    end

    return setmetatable(bar, meta)
end

function bar_effects_menu(x, y, scale)
    local menu = {
        id = GID(),
        pos = vec2(x, y),
        dist = 0,
        effects = {},
        active = {},
        scale = scale
    }

    menu.w = ((bar_sheet.sheet:getWidth()/#bar_sheet) * 3) * menu.scale

    local meta = {
        type = 'effects_menu'
    }

    function menu:align(side)
        local side = side or 'center'

        if side == 'center' then
            self.pos.x = self.pos.x - self.w/2
        elseif side == 'right' then
            self.pos.x = self.pos.x - self.w
        elseif side == 'left' then
            return
        end
    end

    function menu:add_effect(time, sheet, quad, index, no_tick, do_kill)
        local index = index or #self.effects

        local real_bar = new_cooldown_bar(self.pos.x, self.pos.y)

        real_bar.bar.icon_sheet = sheet
        real_bar.bar.icon_quad = quad
        real_bar.bar:set_bar_count(2)

        local bar = {
                    timer = new_real_timer(time, -1),
                    bar = real_bar,
                    no_tick = no_tick,
                    do_kill = do_kill
                }

        self.active[index] = #self.effects + 1
        table.insert(self.effects, bar)
    end

    function menu:update()
        for i = 1, #self.effects do
            if self.effects[i] ~= nil then

                self.effects[i].bar.pos.x = self.pos.x
                self.effects[i].bar.pos.y = self.pos.y + ((i-1) * self.effects[i].bar.bar.h) + ((i-1) * self.dist)
                self.effects[i].bar:update()

                if not self.effects[i].no_tick then
                    self.effects[i].timer:tick()
                    self.effects[i].bar:tick(1 - (self.effects[i].timer.current_tick/self.effects[i].timer.time))
                end

                if self.effects[i].do_kill and self.effects[i].bar.pct == 0 then
                    table.remove(self.effects, i)
                end

                
                if self.effects[i] ~= nil and self.effects[i].do_kill and self.effects[i].bar.pct == 0 then
                    self.active[self.effects[i].index] = nil
                    table.remove(self.effects, i)

                    for e = i,#self.effects do
                        self.effects[e].goal_pos.y = self.effects[e].goal_pos.y - (self.timer_h + self.oy)
                        self.active[self.effects[e].index] = e
                    end
                end
            end
        end
    end

    function menu:draw()
        for i = 1,#self.effects do
            self.effects[i].bar:draw()
        end
    end

    return setmetatable(menu, meta)
end

-- makes active affects menu
function active_effects_menu(x, y, scale)
    local scale = scale or pix_scale

    local effects = {
        id = GID(),
        pos = vec2(x, y),
        stack_width = 2,
        effects = {},
        active = {},
        scale = scale,
        timer_w = (circle_cooldown.sheet:getWidth()/#circle_cooldown) * scale,
        timer_h = (circle_cooldown.sheet:getHeight()) * scale,
        oy = 5,
        ox = 5,
    }

    local meta = {
        type = 'effects_menu'
    }

    function effects:align(side)
        local side = side or 'center'

        local w = (math.ceil(self.timer_w/(16 * self.scale)) + 1) * (16 * self.scale)

        if side == 'center' then
            self.pos.x = self.pos.x - w/2
        elseif side == 'right' then
            self.pos.x = self.pos.x - w
        elseif side == 'left' then
            return
        end
    end

    function effects:add_effect(time, sheet, quad, index, no_tick, do_kill)
        local w = w or 16
        local h = h or 16
        local index = index or #self.effects

        if do_kill == nil then do_kill = true end

        local no_tick = no_tick or false

        local x = self.pos.x + self.timer_w/4
        local y = self.pos.y + #self.effects * (self.timer_h)


        local effect = {
            timer = new_real_timer(time, -1),
            circ = new_cooldown_circle(x, y),
            pos = vec2(x, y),
            goal_pos = vec2(x, y),
            tw = 0,
            th = 0,
            w = 0,
            h = 0,
            index = index,
            no_tick = no_tick,
            do_kill = do_kill
        }

        function effect:expire()
            self.timer.current_tick = 0
        end

        effect.circ:add_icon(sheet, quad, w, h)

        if self.effects[self.active[index]] ~= nil then
            self.effects[self.active[index]].timer.time = time
            self.effects[self.active[index]].timer.current_tick = time
        else
            self.active[index] = #self.effects + 1
            table.insert(self.effects, effect)
        end
    end

    function effects:update()
        if stack.paused then return end
        
        self.w = self.timer_w
        self.h = #self.effects * (self.timer_h + self.oy)

        for i = 1,#self.effects do
            if self.effects[i] ~= nil then
                if not self.effects[i].no_tick then
                    self.effects[i].timer:tick()
                    self.effects[i].circ:tick(self.effects[i].timer.current_tick/self.effects[i].timer.time)
                end
                self.effects[i].circ:update()

                local dx = self.effects[i].goal_pos.x  - self.effects[i].pos.x
                local dy = self.effects[i].goal_pos.y - self.effects[i].pos.y

                self.effects[i].pos.x = self.effects[i].pos.x + dx/2
                self.effects[i].pos.y = self.effects[i].pos.y + dy/2
        
                self.effects[i].circ.pos.x = self.effects[i].pos.x
                self.effects[i].circ.pos.y = self.effects[i].pos.y

                if self.effects[i].do_kill and self.effects[i].timer.current_tick/self.effects[i].timer.time == 0 then
                    self.active[self.effects[i].index] = nil
                    table.remove(self.effects, i)

                    for e = i,#self.effects do
                        self.effects[e].goal_pos.y = self.effects[e].goal_pos.y - (self.timer_h + self.oy)
                        self.active[self.effects[e].index] = e
                    end
                end
            end
        end
    end

    function effects:draw()
        if stack.paused then return end

        love.graphics.setColor(1,1,1,1)

        local tw = math.ceil(self.w/(16 * self.scale)) + 1
        local th = math.ceil(self.h/(16 * self.scale))

        local total_width = tw * (16 * self.scale)
        local total_height = th * (16 * self.scale)

        -- for w = 0, tw - 1 do
        --     for h = 0, th - 1 do
        --         local quad = get_background_quad(w, h, tw, th)

        --         love.graphics.draw(menu_bg.sheet, menu_bg[quad], self.pos.x + (w * 16 * self.scale), 
        --                                                         self.pos.y + (h * 16 * self.scale), 0, self.scale)
        --     end
        -- end

        for i = 1,#self.effects do
            self.effects[i].circ:draw()
        end
    end

    return setmetatable(effects, meta)
end

-- makes a safe counter
function new_safe_counter(world, x, y)
    local counter = {
        pos = vec2(x, y),
        world = world,
        safes = {
            {count = 0, text = love.graphics.newText(font, ''), pos = vec2()},
            {count = 0, text = love.graphics.newText(font, ''), pos = vec2()},
            {count = 0, text = love.graphics.newText(font, ''), pos = vec2()},
            {count = 0, text = love.graphics.newText(font, ''), pos = vec2()},
        },
        temp_safes = {},
        gap = 3,
        scale = pix_scale,
        safe_w = (safes.sheet:getWidth()/#safes)*pix_scale,
        w = 4 * (safes.sheet:getWidth()/#safes) * pix_scale,
        h = 2*(safes.sheet:getWidth()/#safes)*pix_scale
    }

    local meta = {
        type = 'counter'
    }

    function counter:align(side)
        local side = side or 'center'
        local w = 5 * (safes.sheet:getWidth()/#safes) * pix_scale

        if side == 'center' then
            self.pos.x = self.pos.x - w/2
        elseif side == 'right' then
            self.pos.x = self.pos.x - w
        elseif side == 'left' then
            return
        end
    end

    function counter:update()
        for i = 1,#self.safes do
            self.safes[i].text = love.graphics.newText(font, 'x' .. self.safes[i].count)
        end

        for i = 1,#self.temp_safes do
            if self.temp_safes[i] ~= nil then
                local dist = vec2(self.safes[self.temp_safes[i].rarity].pos.x - self.temp_safes[i].pos.x, 
                                    self.safes[self.temp_safes[i].rarity].pos.y - self.temp_safes[i].pos.y)

                self.temp_safes[i].pos.x = self.temp_safes[i].pos.x + dist.x/10
                self.temp_safes[i].pos.y = self.temp_safes[i].pos.y + dist.y/10

                if math.abs(dist.x) < 2 and math.abs(dist.y) < 2 then
                    self.safes[self.temp_safes[i].rarity].count = self.safes[self.temp_safes[i].rarity].count + self.temp_safes[i].amount
                    table.remove(self.temp_safes, i)
                end
            end
        end

    end

    function counter:add_safe(rarity, amount, x, y)
        local amount = amount or 1
        local pos = vec2(x, y)

        -- self.safes[rarity].count = self.safes[rarity].count + amount

        table.insert(self.temp_safes, {rarity=rarity, pos=pos, amount = amount})
    end

    function counter:draw()
        local tw = math.ceil(self.w/(16 * self.scale))
        local th = math.ceil(self.h/(16 * self.scale))

        if self.w > tw * (16 * self.scale) - 5 then tw = tw + 1 end
        if th == 1 then th = 2 end

        local total_width = tw * (16 * self.scale)
        local total_height = th * (16 * self.scale)

        local w_offset = total_width - self.w
        local h_offset = self.h

        for w = 0, tw - 1 do
            for h = 0, th - 1 do
                local quad = get_background_quad(w, h, tw, th)

                love.graphics.draw(menu_bg.sheet, menu_bg[quad], 
                                                    self.pos.x + (w * 16 * self.scale), 
                                                    self.pos.y + (h * 16 * self.scale), 0, self.scale)
            end
        end

        for i = 1, #self.safes do
            local px, py = self.pos.x + ((i - 1) * self.safe_w) + w_offset/2, self.pos.y + h_offset/4
            self.safes[i].pos.x = px
            self.safes[i].pos.y = py
            local text_scale = 0.25
            local tw, th = self.safes[i].text:getWidth() * text_scale, self.safes[i].text:getHeight() * text_scale

            love.graphics.draw(safes.sheet, safes[i], px, py, 0, self.scale)

            love.graphics.draw(self.safes[i].text, px + self.safe_w - tw, py + self.safe_w - th/2, 0, 0.25)
        end

        for i = 1,#self.temp_safes do
            love.graphics.draw(safes.sheet, safes[self.temp_safes[i].rarity], self.temp_safes[i].pos.x, 
                                                self.temp_safes[i].pos.y, 0, self.scale)
        end

    end

    return setmetatable(counter, meta)

end

-- makes and formats level select
function new_level_select(x, y)
    local x = x or res[1]/2
    local y = y or res[2]/2

    local button_scale = 5

    local menu = {
        id = GID(),
        pos = vec2(x, y),
        full_w = 0,
        full_h = 0,
        card_w = 0,
        card_h = 0,
        missions = {},
        sheet = level_select_cards,
        gap = 5,
        scale = 4,
        tile_scale = 8,
        cards_shown = 1,
        start_index = 1,
        max = 1,
        ox = 0,
        g_ox = 0,
        shifting = 0,
        priority = nil,
        selected = nil,
        play_button = nil,
        button_scale = button_scale,
        bg_cards = 2,
    }

    local meta = {
        type = 'menu_select'
    }

    menu.card_w = (menu.sheet.sheet:getWidth()/#menu.sheet) * menu.scale
    menu.card_h = (menu.sheet.sheet:getHeight()) * menu.scale

    menu.back_ground = {
        pos = vec2(menu.pos.x - menu.card_w * 2.5, menu.pos.y - menu.card_h),
        w = 5 * menu.card_w,
        h = 2 * menu.card_h
    }

    menu.back_button = new_button((menu.pos.x - menu.back_ground.w/2) - (8*menu.scale) - 2, 
    menu.pos.y + menu.back_ground.h/2 - 21*button_scale + 2, 
    21*button_scale, 20*button_scale, 0, 0, small_buttons, 13, 14, 15, button_scale)

    menu.forward_button = new_button((menu.pos.x + menu.back_ground.w/2) - 20 * button_scale + (8*menu.scale), 
    menu.pos.y + menu.back_ground.h/2 - 21*button_scale + 2, 
    21*button_scale, 20*button_scale, 0, 0, small_buttons, 10, 11, 12, button_scale)

    menu.close_button = new_button((menu.pos.x + menu.back_ground.w/2) - 20 * button_scale + (8*menu.scale), 
    menu.pos.y - menu.back_ground.h/2 - 2, 
    21*button_scale, 20*button_scale, 0, 0, small_buttons, 4, 5, 6, button_scale)

    function menu:new_mission_card(mission)
        local card = {
            mission = mission,
            ox = 0,
            g_ox = 0,
            scale = self.scale,
            goal_scale = self.scale,
            color_sub = 0,
            color_sub_goal = 0,
            menu = self,
            index = #self.missions + 1,
            w = 0,
            h = 0,
            pos = vec2(),
            vpos = vec2(),
            selected = false
        }

        card.text = new_card_text(self.pos.x, self.pos.y, 0.5)
        local color
        local gray = color_pallette[5]

        if mission.int_diff == 1 then
            color = {0, 0.5, 0, 1}
        elseif mission.int_diff == 2 then
            color = {0, 0.4, 0.5, 1}
        elseif mission.int_diff == 3 then
            color = {0.5, 0, 0.5, 1}
        elseif mission.int_diff == 4 then
            color = {0.5, 0, 0, 1}
        elseif mission.int_diff == 5 then
            color = {0.5, 0.5, 0, 1}
        end

        card.text:add_text(mission.name, color, true)


        card.text:add_text(mission.difficulty, gray, false)

        card.text:add_text(mission.size .. 'x' .. mission.size .. ' area', gray, false)

        local basic_pct
        local rare_pct
        local mythic_pct  
        local legendary_pct
        
        for i = 1,4 do
            card.text:add_text(' ' .. mission.safe_rarities[i] * 100 .. '%', gray, false, safes, i, card.scale/2)
            card.text.text[#card.text.text].alignment = 'left'
        end

        function card:update()
            local menu = self.menu

            self.w = (menu.card_w/menu.scale) * self.scale
            self.h = (menu.card_h/menu.scale) * self.scale

            if self.index >= menu.start_index and self.index <= menu.max then
                self.goal_scale = menu.scale
                self.color_sub_goal = 0

                local mx, my = love.mouse:getPosition()

                self.pos.x = menu.pos.x + (self.index - 1) * (menu.card_w) + menu.ox
                self.pos.y = menu.pos.y
    
                if mx / screen_ratio[1] > self.pos.x and mx / screen_ratio[1] < self.pos.x + menu.card_w and
                    my / screen_ratio[2] > self.pos.y and my / screen_ratio[2] < self.pos.y + menu.card_h then
                        self.goal_scale = menu.scale + 0.4
                        menu.priority = self.index

                        function love.mousereleased(x, y, button)
                            if button == 1 then
                                self.selected = not self.selected
                            end
                        end
                else
                    function love.mousereleased()

                    end
                end 

                
                if self.selected == true then
                    if menu.play_button == nil then
                        menu:set_play_button(self.mission)
                    end

                    self.goal_scale = menu.scale + 0.8
                    menu.selected = self.index
                    menu.priority = self.index
                else
                    if menu.play_button ~= nil then
                        menu:set_play_button()
                    end
                end

            else
                self.goal_scale = menu.scale - math.abs(self.menu.max - self.index)
                self.color_sub_goal = 0.5

                if self.selected == true then
                    menu:set_play_button()
                    self.selected = false
                end
            end

            local sdist = self.goal_scale - self.scale

            self.scale = self.scale + sdist/4

            local cdist = self.color_sub_goal - self.color_sub

            self.color_sub = self.color_sub + cdist/8

            -- updates text obj 
            local ox = menu.ox - (self.w - menu.card_w)/2
            local oy = menu.card_h - self.h/2

            if self.index < menu.start_index then
                ox = ox - 2 * menu.tile_scale + menu.card_w/2
            elseif self.index > menu.max then
                ox = ox + 2 * menu.tile_scale - menu.card_w/2
            end

            self.vpos.x = menu.pos.x + ((self.index - 1) * menu.card_w) + ((self.index - 1)) + ox
            self.vpos.y = menu.pos.y - menu.card_h/2 + oy

            self.text.scale = self.scale/11
            self.text.pos.x = self.vpos.x
            self.text.pos.y = self.vpos.y + 6 * self.scale
            self.text.color_offset = self.color_sub

            self.text:update()

            self.text.w = self.w

            for i = 3, #self.text.text do
                self.text.text[i].iscale = self.scale/2.3
            end
        end

        function card:draw()
            local menu = self.menu

            local index = self.mission.int_diff

            local c = 1 - self.color_sub

            love.graphics.setColor(c, c, c, c)

            love.graphics.draw(menu.sheet.sheet, menu.sheet[index], self.vpos.x, self.vpos.y, 0, card.scale)

            -- draw details
            self.text:draw()
        end
        
        table.insert(self.missions, card)
    end
    
    for dif = 1, 5 do
        for k, v in pairs(maps) do
            if v.int_diff == dif then
                menu:new_mission_card(v)
            end
        end
    end

    menu.full_w = #menu.missions * (menu.card_w + menu.gap)
    menu.full_h = menu.card_h

    menu.w = menu.cards_shown * (menu.card_w + menu.gap)
    menu.h = menu.card_h

    function menu:align(side)
        local side = side or 'center'

        if side == 'center' then
            self.pos.x = self.pos.x - self.w/2
            self.pos.y = self.pos.y - self.h/2
        elseif side == 'right' then
            self.pos.x = self.pos.x - self.w
        elseif side == 'left' then
            return
        end
    end

    function menu:shift(dir)
        self.start_index = self.start_index + dir

        if self.start_index < 1 then
            self.start_index = 1
        end

        if self.start_index > #self.missions then
            self.start_index = #self.missions
        end

        self.max = self.start_index + self.cards_shown - 1

        if self.max > #self.missions then
            self.max = #self.missions - 1
            self.start_index = #self.missions - self.cards_shown + 1
        end

        self.shifting = 0

    end

    function menu:set_play_button(mission)
        if stack == nil then return end

        if self.play_button == nil then
            local px = (self.pos.x + 19 * self.button_scale) - (42 * self.button_scale)/2
            local py = self.pos.y + self.card_h + (20 * self.button_scale)/2

            local button = new_button(px, py,
            42*self.button_scale, 20*self.button_scale, 19 * self.button_scale, 0, large_buttons, 4, 5, 6, button_scale)
            button:set_function(game_scene, stack, mission)

            self.play_button = button
        else
            self.play_button = nil
        end

    end

    menu.back_button:set_function(menu.shift, menu, -1)
    menu.forward_button:set_function(menu.shift, menu, 1)
    menu.close_button:set_function(title_screen, stack)

    function menu:update()
        self.priority = nil

        local dist = self.g_ox - self.ox
        self.ox = self.ox + dist/12

        if math.abs(dist) < 0.5 then
            self.ox = math.floor(self.g_ox)
        end

        self.g_ox = -(self.start_index - 1) * self.card_w

        self:shift(self.shifting)

        for i = 1, #self.missions do
            self.missions[i]:update()
        end

        self.back_button:update()
        self.forward_button:update()
        self.close_button:update()

        if self.play_button ~= nil then
            self.play_button:update()
        end
    end

    function menu:draw()
        local tw = math.ceil(self.back_ground.w/(16 * self.tile_scale))
        local th = math.ceil(self.back_ground.h/(16 * self.tile_scale))

        if self.back_ground.w > tw * (16 * self.tile_scale) - 5 then tw = tw + 1 end
        if th == 1 then th = 2 end

        local total_width = tw * (16 * self.tile_scale)
        local total_height = th * (16 * self.tile_scale)

        local w_offset = total_width - self.back_ground.w
        local h_offset = self.back_ground.h
        local ox = (tw/2) * self.tile_scale

        for w = 0, tw - 1 do
            for h = 0, th - 1 do
                local quad = get_background_quad(w, h, tw, th)

                love.graphics.draw(menu_bg.sheet, menu_bg[quad], 
                                                    self.back_ground.pos.x + (w * 16 * self.tile_scale) - ox, 
                                                    self.back_ground.pos.y + (h * 16 * self.tile_scale), 0, self.tile_scale)
            end
        end

        local sindex = self.start_index - self.bg_cards
        if sindex < 1 then sindex = 1 end
        local eindex = self.max + self.bg_cards
        if eindex > #self.missions then eindex = #self.missions end
        for i = sindex, eindex do
            if i ~= self.priority then
                self.missions[i]:draw()
            end
        end

        for i = self.start_index, self.max do
            if i ~= self.priority then
                self.missions[i]:draw()
            end
        end

        if self.priority ~= nil then
            self.missions[self.priority]:draw()
        end

        love.graphics.setColor(bg_color)
        love.graphics.rectangle('fill', 0, 0, ox, res[2])
        love.graphics.rectangle('fill', res[1] - ox, 0, ox, res[2])
        love.graphics.rectangle('fill', 0, 0, res[1], self.back_ground.pos.y)
        love.graphics.rectangle('fill', 0, self.back_ground.pos.y + self.back_ground.h, res[1], self.back_ground.pos.y)

        self.back_button:draw()
        self.forward_button:draw()
        self.close_button:draw()

        if self.play_button ~= nil then
            self.play_button:draw()
        end
    end

    menu:align()

    return setmetatable(menu, meta)

end
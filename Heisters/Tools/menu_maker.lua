function new_menu_maker()
    love.graphics.setDefaultFilter("nearest", "nearest")

    local scene = {
        id = GID(),
        menu_assets = {},
        current_asset = nil,
        asset_scale = 3,
        scale_rat = 3,

        current_select = nil,
        current_menu = nil,
        current_text_box = nil,
        tool_text_boxes = {},
        tool_buttons = {},

        asset_edit = nil,

        show_dist = false,
        show_box = false,

        key_constants = {
            show_console,
            full_screen
        },

        name = 'menu',
        music = nil

    }

    scene.name = scene.name .. #love.filesystem.getDirectoryItems('Assets/menus') + 1

    scene.sheet_names = {
        'Assets/images/UI/large_buttons.png',
        'Assets/images/UI/small_buttons.png',
        'Assets/images/logo_sheet.png'
    }

    scene.assets = {
        read('Assets/images/UI/large_buttons.png', 79, 20, 15, 0, 0, 237),
        read('Assets/images/UI/small_buttons.png', 21, 20, 15, 0, 0, 63),
        read('Assets/images/logo_sheet.png', 96, 28, 2, 0, 0, 96)
    }

    scene.asset_settings = {
    }

    for i = 1,#scene.assets do
        table.insert(scene.asset_settings, {})

        for s = 1,#scene.assets[i] do
            local setting = {
                w = scene.assets[i].qw,
                h = scene.assets[i].qh,
                ox = 0,
                oy = 0,
                scale = scene.asset_scale
            }

            scene.asset_settings[i][s] = setting
        end
    end

    local meta = {
        type = 'menu_editor'
    }

    function scene:save(file)
        local dat = {
            scale = self.asset_scale,
            asset_settings = self.asset_settings,

            sheets = {
                {"read('Assets/images/UI/large_buttons.png', 79, 20, 15, 0, 0, 237)", str_eval = true},
                {"read('Assets/images/UI/small_buttons.png', 21, 20, 15, 0, 0, 63)", str_eval = true},
                {"read('Assets/images/logo_sheet.png', 96, 28, 2, 0, 0, 96)", str_eval = true},
            },

            assets = {},
            music = self.music
        }

        local file = file or self.name

        if file == '' then file = self.name end

        local path = 'Assets/menus/'

        for i = 1,#self.menu_assets do
            local asset = {
                pos = self.menu_assets[i].pos,
                w = self.menu_assets[i].w,
                h = self.menu_assets[i].h,
                ox = self.menu_assets[i].ox,
                oy = self.menu_assets[i].oy,
                sheet = self.sheet_names[self.menu_assets[i].sheet_index],
                sheet_index = self.menu_assets[i].sheet_index,
                image_index = self.menu_assets[i].image_index,
                scale = self.menu_assets[i].scale,
                id = self.menu_assets[i].id,
                type = self.menu_assets[i].type,
                binding = self.menu_assets[i].binding
            }


            table.insert(dat.assets, asset)
        end

        local image_setting = 'love.graphics.setDefaultFilter("nearest", "nearest")\n\n\n'

        write_file(path .. file .. '.lua', image_setting .. table_to_string(dat, 'assets', true))
    end

    function scene:import(file)
        local path = 'Assets/menus/'
        
        if file == nil or file == '' then return end

        local dat = love.filesystem.load(path .. file .. '.lua')()

        self.name = file

        self.scale = dat.scale
        self.asset_settings = dat.asset_settings
        self.menu_assets = {}
        self.music = dat.music
        
        for i = 1,#dat.assets do
            local asset = dat.assets[i]

            local R_asset = self:add_asset(asset.sheet_index, asset.image_index)
            R_asset.pos.x = asset.pos.x
            R_asset.pos.y = asset.pos.y
            R_asset.w = asset.w
            R_asset.h = asset.h
            R_asset.scale = asset.scale
            R_asset.ox = asset.ox
            R_asset.oy = asset.oy
            R_asset.type = asset.type
            R_asset.binding = asset.binding
        end

        self.current_asset = nil
    end

    function scene:new_text_box(x, y, oy, w, h, click_off, saveorload)
        local click_off = click_off or true
        local box = {
            val = '',
            id = GID(),
            pos = vec2(x, y + oy),
            w = w,
            h = h,
            text = love.graphics.newText(font, val),
            scene = self,
            text_scale = 0.5,
            binding = nil,
            isshift = false,
            index = #self.tool_text_boxes + 1,
            click_off = click_off
        }



        local meta = {
            type = 'text_box'
        }

        function box:bind_val(func, args)
            local args = args or {}
            self.binding = {func, args}
        end

        if saveorload == 'save' then
            box:bind_val(self.save)
            box.val = self.name
        elseif saveorload == 'load' then
            box:bind_val(self.import)
        elseif type(saveorload) == 'table' then
            box:bind_val(saveorload[1], saveorload[2])
        end

        function box:update()
            local x, y = love.mouse.getPosition()

            function love.mousereleased(x, y, button)
                if button == 1 then
                    
                    if x > self.pos.x and x < self.pos.x + self.w and
                        y > self.pos.y and y < self.pos.y + self.h then
                            self.scene.current_text_box = self.id
                    else
                        if self.click_off then
                            function love.keypressed(key) end

                            self.scene.tool_text_boxes[self.index] = nil
                            local ntable = {}

                            for i = 1,#self.scene.tool_text_boxes do
                                if self.scene.tool_text_boxes[i] ~= nil then
                                    table.insert(ntable, self.scene.tool_text_boxes[i])
                                end
                            end

                            self.scene.tool_text_boxes = ntable
                        end
                        self.scene.current_text_box = nil
                    end
                end
            end


            local adder = ''
            if self.scene.current_text_box == self.id then
                adder = '_'

                if self.val ~= '' then
                    self.w = self.text:getWidth() * self.text_scale
                end

                self.h = self.text:getHeight() * self.text_scale

                function love.keypressed(key)
                    if key ~= nil then
                        if key == 'backspace' then
                            self.val = self.val:sub(1, -2)
                        elseif key == 'return' then
                            if self.binding ~= nil then
                                for k,v in pairs(self.binding[2]) do
                                    if v == 'val' then
                                        self.binding[2][k] = self.val
                                    end
                                end

                                self.binding[1](self.scene, self.val, unpack(self.binding[2]))
                            end

                            if self.click_off then
                                function love.keypressed(key) end

                                self.scene.tool_text_boxes[self.index] = nil
                                local ntable = {}
    
                                for i = 1,#self.scene.tool_text_boxes do
                                    if self.scene.tool_text_boxes[i] ~= nil then
                                        table.insert(ntable, self.scene.tool_text_boxes[i])
                                    end
                                end
    
                                self.scene.tool_text_boxes = ntable
                            end
                            self.scene.current_text_box = nil
                        elseif key == 'space' then
                            self.val = self.val .. ' '
                        elseif key ~= 'lshift' and key ~= 'rshift' then
                            self.val = self.val .. key
                        end

                    end
                end
            else
                function love.keypressed(key) end
            end

            self.text = love.graphics.newText(font, self.val .. adder)
        end

        function box:draw()
            if self.scene.current_text_box == self.id then
                love.graphics.setColor(1, 0, 0)
            end

            love.graphics.setLineWidth(3)
            love.graphics.rectangle('line', self.pos.x, self.pos.y, self.w, self.h)
            love.graphics.setColor(1, 1, 1, 1)
            love.graphics.rectangle('fill', self.pos.x, self.pos.y, self.w, self.h)

            love.graphics.setColor(0, 0, 0, 1)
            love.graphics.draw(self.text, self.pos.x, self.pos.y, 0, self.text_scale)
        end

        if #self.tool_text_boxes == 0 then
            local box = setmetatable(box, meta)

            table.insert(self.tool_text_boxes, box)

        else
            function love.keypressed(key) end

            self.tool_text_boxes = {}
        end

        return box
    end

    function scene:edit_asset(sheet_index, image_index)
        local asset = {
            id = GID(),
            w = self.asset_settings[sheet_index][image_index].w,
            h = self.asset_settings[sheet_index][image_index].h,
            qw = self.assets[sheet_index].qw,
            qh = self.assets[sheet_index].qh,
            pos = vec2(current_res[1]/2, current_res[2]/2),
            scale = self.asset_scale,
            sheet = self.assets[sheet_index],
            image_index = image_index,
            sheet_index = sheet_index,
            ox = self.asset_settings[sheet_index][image_index].ox,
            oy = self.asset_settings[sheet_index][image_index].oy,
            scene = self,
            side = nil,
            side_lock = false,
        }


        local meta = {
            type = 'temp_asset'
        }

        function asset:update()
            local x, y = love.mouse:getPosition()

            if self.side_lock == false then
                if x == math.floor(self.pos.x + (self.w * self.scale)) then
                    self.side = 'right'

                elseif x == math.floor(self.pos.x) then
                    self.side = 'left'
                
                elseif y == math.floor(self.pos.y) then
                    self.side = 'top'


                elseif y == math.floor(self.pos.y + (self.h * self.scale)) then
                    self.side = 'bottom'

                else
                    self.side = nil
                end
            end

            if self.side ~= nil then
                function love.mousereleased(x, y, button)
                    if button == 1 then
                        self.side_lock = not self.side_lock
                    end
                end
            end

            if self.side_lock ==  true then
                if self.side == 'right' and self.w * self.scale > 1 then
                    self.w = (x - self.pos.x)/self.scale
                elseif self.side == 'left' and self.w * self.scale > 1 then
                    self.ox = self.pos.x - x
                end
            end

            if love.keyboard.isDown('escape') then
                self.scene.asset_edit = nil
            end

            if love.keyboard.isDown('return') then
                local setting = {
                    w = self.w,
                    h = self.h,
                    ox = self.ox,
                    oy = self.oy,
                }

                self.scene.asset_settings[self.sheet_index][self.image_index] = setting
                self.scene.asset_edit = nil
            end


        end

        function asset:draw()
            love.graphics.draw(self.sheet.sheet, self.sheet[self.image_index], self.pos.x - self.ox, self.pos.y - self.oy, 0, self.scale)
            love.graphics.rectangle('line', self.pos.x, self.pos.y, self.w * self.scale, self.h * self.scale)

            love.graphics.setColor(1, 0, 0)

            if self.side == 'top' then
                love.graphics.line(self.pos.x, self.pos.y, self.pos.x + self.w * self.scale, self.pos.y)
            elseif self.side == 'bottom' then
                love.graphics.line(self.pos.x, self.pos.y + self.h * self.scale, self.pos.x + self.w * self.scale, self.pos.y + self.h * self.scale)
            elseif self.side == 'left' then
                love.graphics.line(self.pos.x, self.pos.y, self.pos.x, self.pos.y + self.h * self.scale)
            elseif self.side == 'right' then
                love.graphics.line(self.pos.x + self.w * self.scale, self.pos.y, self.pos.x + self.w * self.scale, self.pos.y + self.h * self.scale)
            end
        end

        self.asset_edit = asset
        return setmetatable(asset, meta)
    end

    function scene:add_asset(sheet_index, image_index, type)
        local type = type or 'button'
        local asset = {
            id = GID(),
            pos = vec2(100, 100),
            image_index = image_index,
            w = 0,
            h = 0,
            ox = 0,
            oy = 0,
            sheet_index = sheet_index,
            sheet = self.assets[sheet_index],
            index = #self.menu_assets + 1,
            scene = self,
            hover = false,
            unlock = false,
            scale = self.asset_scale,
            lock_range = {w = 0, h = 0},
            type = type,
            binding = nil,
            setting_bind = false,
            setting_box = nil
        }


        function asset:set_binding(string)
            self.binding = binding
        end

        function asset:update()
            
            self.w = self.scene.asset_settings[self.sheet_index][self.image_index].w * self.scale
            self.h = self.scene.asset_settings[self.sheet_index][self.image_index].h * self.scale
            self.ox = self.scene.asset_settings[self.sheet_index][self.image_index].ox
            self.oy = self.scene.asset_settings[self.sheet_index][self.image_index].oy
            local x, y = love.mouse.getPosition()

            if self.scene.current_asset == self.index then
                if self.setting_bind == false then
                    if x > self.pos.x + self.w/2 + self.lock_range.w/2 or x < self.pos.x + self.w/2 - self.lock_range.w/2 then
                        self.pos.x = (x - self.w/2) - self.scene.asset_settings[self.sheet_index][self.image_index].ox
                    end
    
                    if y > self.pos.y + self.h/2 + self.lock_range.h/2 or y < self.pos.y + self.h/2 - self.lock_range.h/2 then
                        self.pos.y = (y - self.h/2) - self.scene.asset_settings[self.sheet_index][self.image_index].oy
    
                    end
                end

                if love.keyboard.isDown('space') and self.setting_box == nil then
                    self.pos.x = current_res[1]/2 - self.w/2
                    self.pos.y = current_res[2]/2 - self.h/2
                    love.mouse.setPosition(current_res[1]/2, current_res[2]/2)
                end

                if love.keyboard.isDown('backspace') and self.setting_box == nil then
                    self.scene.menu_assets[self.index] = false
                    self.scene.current_asset = nil
                end

                if self.setting_box ~= nil and self.scene.current_text_box ~= self.setting_box.id then
                    self.setting_box = nil
                    self.setting_bind = false
                elseif self.setting_box ~= nil then
                    self.binding = self.setting_box.val
                end

                if love.keyboard.isDown('lshift') then
                    if self.type == 'button' then
                        function love.keypressed(key)
                            if key == 'b' and self.scene.current_asset == self.index then
                                self.setting_box = self.scene:new_text_box(self.pos.x, self.pos.y, self.h + 5, 100, 50, true)
                                self.setting_bind = true
                                self.scene.current_text_box = self.setting_box.id
                            end
                        end
                    end

                    self.unlock = true
                else
                    self.unlock = false
                end


            end


            if x > self.pos.x and x < self.pos.x + self.w and
                y > self.pos.y and y < self.pos.y + self.h then

                    self.hover = true

                    function love.mousereleased(x, y, button)
                        if button == 1 then

                            if self.scene.current_asset == self.index then
                                self.scene.current_asset = nil
                            else
                                self.scene.current_asset = self.index
                            end
                        end
                    end

            else
                self.hover = false
            end

        end

        function asset:draw()
            local lock_x = false
            local lock_y = false

            if self.scene.current_asset == self.index then
                if self.pos.x + self.w/2 == current_res[1]/2 then
                    love.graphics.line(current_res[1]/2, 0, current_res[1]/2, current_res[2])
                    lock_x = true
                else
                    lock_x = false
                end

                if self.pos.y + self.h/2 == current_res[2]/2 then
                    love.graphics.line(0, current_res[2]/2, current_res[1], current_res[2]/2)
                    lock_y = true
                else
                    lock_y = false
                end

                for i = 1, #self.scene.menu_assets do
                    if self.scene.menu_assets[i].id ~= self.id then
                        local asset = self.scene.menu_assets[i]

                        love.graphics.setColor(1, 0, 0, 1)
                        love.graphics.setLineWidth(3)

                        -- x align

                        if self.pos.x == asset.pos.x then -- self left to asset left
                            love.graphics.line(self.pos.x, self.pos.y + self.h/2, asset.pos.x, asset.pos.y + asset.h/2)
                            lock_x = true
                        end

                        if self.pos.x + self.w == asset.pos.x + asset.w then -- self right to asset right
                            love.graphics.line(self.pos.x + self.w, self.pos.y + self.h/2, asset.pos.x + asset.w, asset.pos.y + asset.h/2)
                            lock_x = true
                        end

                        if self.pos.x + self.w == asset.pos.x then -- self right to asset left
                            love.graphics.line(self.pos.x + self.w, self.pos.y + self.h/2, asset.pos.x, asset.pos.y + asset.h/2)
                            lock_x = true
                        end

                        if self.pos.x == asset.pos.x + asset.w then -- self left to asset right
                            love.graphics.line(self.pos.x, self.pos.y + self.h/2, asset.pos.x + asset.w, asset.pos.y + asset.h/2)
                            lock_x = true
                        end

                        if self.pos.x + self.w/2 == asset.pos.x + asset.w/2 then -- self centerx to asset centerx
                            love.graphics.line(self.pos.x + self.w/2, self.pos.y + self.h/2, asset.pos.x + asset.w/2, asset.pos.y + asset.h/2)
                            lock_x = true
                        end



                        -- y align

                        if self.pos.y == asset.pos.y then -- self top to asset top
                            love.graphics.line(self.pos.x + self.w/2, self.pos.y, asset.pos.x + asset.w/2, asset.pos.y)
                            lock_y = true
                        end

                        if self.pos.y + self.h == asset.pos.y + asset.h then -- self bottom to asset bottom
                            love.graphics.line(self.pos.x + self.w/2, self.pos.y + self.h, asset.pos.x + asset.w/2, asset.pos.y + asset.h)
                            lock_y = true
                        end

                        if self.pos.y + self.h == asset.pos.y then -- self bottom to asset top
                            love.graphics.line(self.pos.x + self.w/2, self.pos.y + self.h, asset.pos.x + asset.w/2, asset.pos.y)
                            lock_y = true
                        end

                        if self.pos.y == asset.pos.y + asset.h then -- self top to asset bottom
                            love.graphics.line(self.pos.x + self.w/2, self.pos.y, asset.pos.x + asset.w/2, asset.pos.y + asset.h)
                            lock_y = true
                        end

                        if self.pos.y + self.h/2 == asset.pos.y + asset.h/2 then -- self centery to asset centery
                            love.graphics.line(self.pos.x + self.w/2, self.pos.y + self.h/2, asset.pos.x + asset.w/2, asset.pos.y + asset.h/2)
                            lock_y = true
                        end
                    end
                end

                if self.unlock == false then
                    if lock_x then
                        self.lock_range.w = 50
                    else
                        self.lock_range.w = 0
                    end

                    if lock_y then
                        self.lock_range.h = 50
                    else
                        self.lock_range.h = 0
                    end
                else
                    self.lock_range.w = 0
                    self.lock_range.h = 0
                end



            end

            love.graphics.setColor(1, 1, 1, 1)
            love.graphics.draw(self.sheet.sheet, self.sheet[self.image_index], 
            self.pos.x - self.ox, 
            self.pos.y - self.oy, 
            0, self.scale)




            if self.hover == true then
                if self.binding ~= nil and self.binding ~= '' then
                    local val = love.graphics.newText(font, 'binding = ' .. self.binding)
                    love.graphics.setColor(1, 0, 1, 1)
                    love.graphics.draw(val, self.pos.x, self.pos.y - val:getHeight() * 0.3, 0, 0.3)
                end

                if self.scene.show_dist then
                    local center = vec2(self.pos.x + self.w/2, self.pos.y + self.h/2)
                    love.graphics.setColor(0, 0, 1, 0.3)

                    local dy = center.y
                    love.graphics.line(center.x, center.y, center.x, 0) -- top
                    love.graphics.print(dy, center.x, self.pos.y - self.h, 0, 0.4)

                    local dy = current_res[2] - center.y
                    love.graphics.line(center.x, center.y, center.x, current_res[2]) -- bottom
                    love.graphics.print(dy, center.x, self.pos.y + 2*(self.h) - 12, 0, 0.4)

                    local dx = center.x
                    love.graphics.line(center.x, center.y, 0, center.y) -- left
                    love.graphics.print(dx, self.pos.x - (self.w), center.y, 0, 0.4)

                    local dx = current_res[1] - center.x
                    love.graphics.line(center.x, center.y, current_res[1], center.y) -- right
                    love.graphics.print(dx, self.pos.x + 2*(self.w), center.y, 0, 0.4)

                    love.graphics.setColor(1, 1, 1, 1)
                end

                love.graphics.setLineWidth(3)
                love.graphics.setColor(0, 1, 0, 1)

                if self.unlock then
                    love.graphics.setColor(1, 0, 0, 1)
                end

                love.graphics.rectangle('line', self.pos.x, self.pos.y, self.w, self.h)

            else
                love.graphics.setLineWidth(3)
                love.graphics.setColor(0.5, 0.2, 0.2, 0.3)
                love.graphics.rectangle('line', self.pos.x, self.pos.y, self.w, self.h)
            end

        end

        self.menu_assets[#self.menu_assets + 1] = asset
        self.current_asset = self.menu_assets[#self.menu_assets].index
        return self.menu_assets[#self.menu_assets]
    end

    function scene:show_assets(x, y, oy, parent, index, quad_gap, scale, type)
        local type = type or 'button'
        local menu = {
            id = GID(),
            pos = vec2(x, y),
            assets = self.assets[index],
            asset_index = index,
            quad_width = self.assets[index].qw * scale,
            quad_height = self.assets[index].qh * scale,
            gap = 5,
            quad_gap = quad_gap,
            scale = scale,
            oy = oy,
            asset_highlight = nil,
            list = {},
            scene = self,
            parent = parent,
            type = type
        }

        menu.w = (self.assets[index].sheet:getWidth()/self.assets[index].qw/quad_gap)*self.assets[index].qw
        menu.h = (self.assets[index].sheet:getHeight()) + (#self.assets[index]/quad_gap)*5

        for i = 1,#menu.assets, menu.quad_gap do
            table.insert(menu.list, i)
        end

        local meta = {
            type = 'menu'
        }

        function menu:update()
            local mx, my = love.mouse.getPosition()



            self.asset_highlight = nil
            for i = 1,#self.list do
                local px = self.pos.x
                local py = self.pos.y + (i-1)*(self.quad_height + self.gap) + self.oy + self.gap

                if mx > px and mx < px + self.quad_width and
                    my > py and my < py + self.quad_height then
                        self.asset_highlight = i

                        function love.mousereleased(x, y, button)
                            if button == 1 then
                                self.scene:add_asset(self.asset_index, self.list[i], self.type)
                                self.parent.func:exec()
                                self.parent.exec = false
                            end
                            if button == 2 then
                                self.scene:edit_asset(self.asset_index, self.list[i])
                                self.parent.func:exec()
                                self.parent.exec = false
                            end
                        end
                end
            end
        end

        function menu:draw()

            love.graphics.setColor(1, 0, 0.3, 0.6)
            love.graphics.rectangle('fill', self.pos.x - 5*self.scale, self.pos.y + self.oy, (self.w + 10) * self.scale, self.h * self.scale)
            love.graphics.setColor(1, 1, 1, 1)

            for i = 1,#self.list do
                love.graphics.draw(self.assets.sheet, self.assets[self.list[i]], 
                        self.pos.x, 
                        self.pos.y + (i-1)*(self.quad_height + self.gap) + self.oy + self.gap, 
                0, self.scale)
            end

            if self.asset_highlight ~= nil then
                love.graphics.setLineWidth(3)
                love.graphics.rectangle('line', self.pos.x - 3, 
                        self.pos.y + (self.asset_highlight-1)*(self.quad_height + self.gap) + self.oy + self.gap - 3,
                        self.quad_width + 6, self.quad_height + 6)
            end
        end

        if self.current_menu == nil then
            self.current_menu = menu
        else
            self.current_menu = nil
        end

        return setmetatable(menu, meta)
    end

    function scene:add_menu_button(text, x, y, scale, box_scale)
        local scale = scale or 0.5
        local box_scale = box_scale or scale + 1.5
        local text = love.graphics.newText(font, text)
        local button = {
            w = text:getWidth(),
            h = text:getHeight(),
            pos = vec2(x, y),
            text = text,
            scale = scale,
            select = false,
            click = false,
            move = false,
            func = nil,
            exec = false,
            do_interact = false,
            scene = self,
            box_scale = box_scale
        }

        function button:set_function(func, args)
            self.func = {func, args}

            function self.func:exec()
                self[1](unpack(self[3]))

            
            end
        end

        function button:update()
            local x, y = love.mouse.getPosition()
            
            local new_args = {}

            for i = 1,#self.func[2] do
                if self.func[2][i] == 'x' then 
                    table.insert(new_args, self.pos.x + 15)
                elseif self.func[2][i] == 'y' then 
                    table.insert(new_args, self.pos.y) 
                elseif self.func[2][i] == 'oy' then
                    table.insert(new_args, (self.h * self.scale) + 5)
                elseif self.func[2][i] == 'scale' then
                    table.insert(new_args, self.box_scale)
                elseif self.func[2][i] == 'parent' then
                    table.insert(new_args, self)
                else
                    table.insert(new_args, self.func[2][i])
                
                end
            end

            self.func[3] = new_args


            if self.move == true and not love.mouse.isDown(2) then
                self.pos.x = x - (self.w *self.scale)/2
                self.pos.y = y - (self.h *self.scale)/2 
            end

            if x > self.pos.x and x < self.pos.x + self.w * self.scale and
                y > self.pos.y and y < self.pos.y + self.h * self.scale then
                    self.select = true
                    self.scene.current_select = self

                    function love.mousereleased(x, y, button)
                        if button == 1 and not self.move then
                            self.func:exec()
                            self.exec = not self.exec
                        end

                        if button == 2 then
                            if self.exec == true then
                                self.func:exec()
                                self.exec = false
                            end

                            self.move = not self.move
                        end

                    end
            else
                if self.scene.current_select == self then
                    self.scene.current_select = nil
                end

                self.select = false       
            end


        end

        function button:draw()
            love.graphics.setColor(0.3, 0.3, 0.7, 0.5)
            love.graphics.rectangle('fill', self.pos.x, self.pos.y, self.w * self.scale, self.h * self.scale)
            love.graphics.rectangle('line', self.pos.x, self.pos.y, self.w * self.scale, self.h * self.scale)
            love.graphics.setColor(1, 1, 1, 1)
            love.graphics.draw(self.text, self.pos.x, self.pos.y, 0, self.scale)

            if self.select then
                love.graphics.setColor(1, 1, 1, 1)
                if self.click then
                    love.graphics.setColor(1, 1, 1, 0.5)
                end

                love.graphics.rectangle('line', self.pos.x, self.pos.y, self.w * self.scale, self.h * self.scale)

            end
        end

        table.insert(self.tool_buttons, button)
        return button

    end

    function scene:set_music(name)
        self.music = name
    end

    local text_button = scene:add_menu_button('new_text_button', 10, 10)
    text_button:set_function(scene.show_assets, {scene, 'x', 'y', 'oy', 'parent', 1, 3, 'scale'})

    local icon_button = scene:add_menu_button('new_icon_button', 20 + text_button.w * text_button.scale, 10)
    icon_button:set_function(scene.show_assets, {scene, 'x', 'y', 'oy', 'parent', 2, 3, 'scale'})

    local icons = scene:add_menu_button('new_icon', 30 + (text_button.w + icon_button.w) * text_button.scale, 10)
    icons:set_function(scene.show_assets, {scene, 'x', 'y', 'oy', 'parent', 3, 1, 'scale', 'image'})

    local save = scene:add_menu_button('save', 40 + (text_button.w + icon_button.w + icons.w) * text_button.scale, 10)
    save:set_function(scene.new_text_box, {scene, 'x', 'y', 'oy', 100, 50, true, 'save'})

    local load = scene:add_menu_button('import', 50 + (text_button.w + icon_button.w + icons.w + save.w) * text_button.scale, 10)
    load:set_function(scene.new_text_box, {scene, 'x', 'y', 'oy', 100, 50, true, 'load'})

    local music = scene:add_menu_button('music', 10, 10 + text_button.h * text_button.scale)
    music:set_function(scene.new_text_box, {scene, 'x', 'y', 'oy', 100, 50, true, {scene.set_music, {'val'}}})

    function scene:update()
        collectgarbage()
        
        if self.current_select == nil then
            function love.mousereleased() end
        end

        for i = 1,#self.tool_text_boxes do
            self.tool_text_boxes[i]:update()
        end

        for i = 1,#self.tool_buttons do
            self.tool_buttons[i]:update()
        end

        if self.current_menu ~= nil then
            self.current_menu:update()
        end

        if self.asset_edit == nil then
            if self.current_asset ~= nil then
                
                function love.wheelmoved(x, y)
                    if y > 0 and self.menu_assets[self.current_asset].scale < 10 then
                        self.menu_assets[self.current_asset].scale = self.menu_assets[self.current_asset].scale + 0.1
                    elseif y < 0 and self.menu_assets[self.current_asset].scale > 0.5 then
                        self.menu_assets[self.current_asset].scale = self.menu_assets[self.current_asset].scale - 0.1
                    end
                end
            else
                function love.wheelmoved(x, y) end
            end

            if love.keyboard.isDown('lctrl') then
                if love.keyboard.isDown('r') then
                    for i = 1,#self.menu_assets do
                        self.menu_assets[i].scale = self.asset_scale
                    end
                end

                function love.wheelmoved(x, y)
                    if y > 0 and self.asset_scale < 10 then
                        self.asset_scale = self.asset_scale + 0.1
                    elseif y < 0 and self.asset_scale > 0.5 then
                        self.asset_scale = self.asset_scale - 0.1
                    end
                end
            end

            for i = 1,#self.menu_assets do
                self.menu_assets[i]:update()
            end

            local asset_refresh = {}
            for i = 1,#self.menu_assets do
                if self.menu_assets[i] ~= false then
                    table.insert(asset_refresh, self.menu_assets[i])
                    self.menu_assets[i].index = #asset_refresh
                end
            end
    
            self.menu_assets = asset_refresh

            function love.keyreleased(key)
                for i = 1,#self.key_constants do
                    self.key_constants[i](key)
                end

                if key == 'd' then
                    self.show_dist = not self.show_dist
                end

                if key == 'b' then
                    self.show_box = not self.show_box
                end
            end
        
        else
            self.asset_edit:update()
        end

    end

    function scene:draw()
        love.graphics.setColor(0, 1, 0, 0.2)
        love.graphics.setLineWidth(1)
        love.graphics.line(current_res[1]/2, 0, current_res[1]/2, current_res[2])
        love.graphics.line(0, current_res[2]/2, current_res[1], current_res[2]/2)
        love.graphics.setColor(1, 1, 1, 1)

        for i = 1,#self.tool_buttons do
            self.tool_buttons[i]:draw()
        end

        for i = 1,#self.tool_text_boxes do
            self.tool_text_boxes[i]:draw()
        end

        if self.asset_edit == nil then
            for i = 1,#self.menu_assets do
                if self.menu_assets[i] ~= false then
                    self.menu_assets[i]:draw()
                end
            end
        else
            self.asset_edit:draw()
        end

        if self.current_menu ~= nil then
            self.current_menu:draw()
        end
    end

    return setmetatable(scene, meta)

end
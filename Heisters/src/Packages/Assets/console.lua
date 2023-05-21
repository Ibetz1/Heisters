function new_console(stack)
    local console = {
        id = GID(),
        shown = false,
        pos = vec2(0, 0),
        ox = 10,

        do_shift = false,
        val = '',
        real_text = love.graphics.newText(font, '_'),
        scale_rat = 0.5,
        scale = 0.5,

        shift_keys = {},
        no_show = {},
        commands = {},
        previous_commands = {},
        previous_strings = {},

        index_shift = 0,
        string_index = 0,
    }
    console.shift_keys['1'] = '!'
    console.shift_keys['2'] = '@'
    console.shift_keys['3'] = '#'
    console.shift_keys['4'] = '$'
    console.shift_keys['5'] = '%'
    console.shift_keys['6'] = '^'
    console.shift_keys['7'] = '&'
    console.shift_keys['8'] = '*'
    console.shift_keys['9'] = '('
    console.shift_keys['0'] = ')'

    console.shift_keys['['] = '{'
    console.shift_keys[']'] = '}'
    console.shift_keys["'"] = '"'
    console.shift_keys[';'] = ":"
    console.shift_keys[','] = '<'
    console.shift_keys['.'] = '>'
    console.shift_keys['/'] = '?'
    console.shift_keys['`'] = '~'
    console.shift_keys['-'] = '_'
    console.shift_keys['='] = '+'

    console.no_show['lshift'] = ''
    console.no_show['rshift'] = ''
    console.no_show['lctrl'] = ''
    console.no_show['rctrl'] = ''
    console.no_show['capslock'] = ''
    console.no_show['tab'] = '   '
    console.no_show['lalt'] = ''
    console.no_show['ralt'] = ''
    console.no_show['return'] = ''
    console.no_show['space'] = ' '
    console.no_show['up'] = ''
    console.no_show['down'] = ''
    console.no_show['left'] = ''
    console.no_show['right'] = ''
    console.no_show['delete'] = ''
    console.no_show['backspace'] = ''
    console.no_show['numlock'] = ''
    console.no_show['kpenter'] = ''
    console.no_show['insert'] = ''
    console.no_show['pageup'] = ''
    console.no_show['home'] = ''
    console.no_show['end'] = ''
    console.no_show['pagedown'] = ''
    console.no_show['pause'] = ''
    console.no_show['printscreen'] = ''
    console.no_show['scrolllock'] = ''
    console.no_show['escape'] = ''

    console.commands['/help'] = function()
        for k,v in pairs(console.commands) do
            if k ~= '/help' then
                table.insert(console.previous_commands, {love.graphics.newText(font, k), {0.4, 0.4, 1}})
            end
        end

        return ''
    end

    console.commands['/edit_scene'] = function(name)
        local output = ''
        local name = name or stack.current_scene_file

        if name == nil then
            table.insert(console.previous_commands, {love.graphics.newText(font, 'menu not editable, type /list_menus for list of menus'), {1, 0.4, 0.4}})
            return ''
        end

        local menus = {}

        for k,v in pairs(love.filesystem.getDirectoryItems('Assets/menus')) do
            menus[v:sub(1,-5)] = v:sub(1,-5)
        end

        if menus[name] == nil then
            table.insert(console.previous_commands, {love.graphics.newText(font, 'invalid menu, type /list_menus for list of menus'), {1, 0.4, 0.4}})
            return ''
        end



        local menu_editor = new_menu_maker()
        menu_editor:import(name)
        table.insert(console.previous_commands, {love.graphics.newText(font, name .. ' has been opened in editor'), {0.4, 1, 0.4}})
        
        stack:build(nil, menu_editor)

        return ''
    end

    console.commands['/open_scene'] = function(name)

        if type(stack.UI) == 'menu_editor' and name == nil then
            stack.UI:save()
            local name = stack.UI.name
            load_menu(name, true)
            table.insert(console.previous_commands, {love.graphics.newText(font, name .. ' has been opened'), {0.4, 1, 0.4}})


            return ''
        end

        local menus = {}

        for k,v in pairs(love.filesystem.getDirectoryItems('Assets/menus')) do
            menus[v:sub(1,-5)] = v:sub(1,-5)
        end

        if menus[name] == nil then
            table.insert(console.previous_commands, {love.graphics.newText(font, 'invalid menu, type /list_menus for list of menus'), {1, 0.4, 0.4}})
            return ''
        end

        load_menu(name, true)

        table.insert(console.previous_commands, {love.graphics.newText(font, name .. ' has been opened'), {0.4, 1, 0.4}})

        return ''
    end

    console.commands['/list_menus'] = function()
        for k,v in pairs(love.filesystem.getDirectoryItems('Assets/menus')) do
            table.insert(console.previous_commands, {love.graphics.newText(font, v:sub(1, -5)), {0.4, 0.4, 1}})
        end
    end

    console.commands['/close_editor'] = function()
        if type(stack.UI) == 'menu_editor' then
            local name = stack.UI.name
            stack.UI:save(name)
            load_menu(name, true)
            table.insert(console.previous_commands, {love.graphics.newText(font, name .. ' has been saved and closed'), {0.4, 1, 0.4}})
        else
            table.insert(console.previous_commands, {love.graphics.newText(font, 'No editor is open'), {1, 0.4, 0.4}})
        end

        return ''
    end

    console.commands['/new_menu'] = function()
        local output = {}

        if type(stack.UI) == 'menu_editor' then
            local name = stack.UI.name
            stack.UI:save(name)
            table.insert(output, {name .. ' has been saved and closed', {0.4, 1, 0.4}})
        end

        local editor = new_menu_maker()
        stack:build(nil, editor)

        table.insert(output, {editor.name .. ' has been opened', {0.4, 1, 0.4}})

        for i = 1,#output do
            table.insert(console.previous_commands, {love.graphics.newText(font, output[i][1]), output[i][2]})
        end

        return ''
    end

    local meta = {
        type = 'console'
    }

    function console:open()
        self.shown = true
    end

    function console:close()
        self.shown = false
        stack.console = nil
    end

    function console:update()
        self.scale = self.scale_rat * screen_ratio[1]

        if self.shown then
            if love.keyboard.isDown('lshift') or love.keyboard.isDown('rshift') then
                self.do_shift = true
            else
                self.do_shift = false
            end

            function love.keypressed(key)
                local real_key = key

                if self.do_shift then
                    if self.shift_keys[key] ~= nil then
                        key = self.shift_keys[key]
                    else
                        key = key:upper()
                    end
                end

                if self.no_show[key:lower()] ~= nil then
                    key = self.no_show[key:lower()]
                end

                if real_key:lower() == 'backspace' or real_key:lower() == 'delete' then
                    self.val = self.val:sub(1, -2)
                end

                if key:lower():sub(1, -2) == 'kp' then
                    key = key:sub(3, -1)
                end

                if real_key == 'return' or real_key == 'kpenter' then
                    if self.val:sub(1, -self.val:len()) == '/' then
                        table.insert(self.previous_strings, self.val)
                        if self.commands[self.val:match("[^ ]+")] ~= nil then
                            local args = {}
                            local str = self.val:match(" (.*)") 
                            
                            if str ~= nil then
                                for k,v in str:gmatch("[^%s]+") do
                                    table.insert(args, k)
                                end
                            end

                            self.val = self.commands[self.val:match("[^ ]+")](unpack(args))
                            if self.val == nil then self.val = '' end
                        else
                            table.insert(self.previous_commands, {love.graphics.newText(font, 'Command is invalid, try /help for list of commands'), {1, 0.4, 0.4}})
                        end
                    end

                    if self.val ~= '' and self.val:sub(1, -self.val:len()) ~= '/' then
                        table.insert(self.previous_commands, love.graphics.newText(font, self.val))
                        table.insert(self.previous_strings, self.val)
                    end

                    self.string_index = 0
                    self.index_shift = 0
                    self.val = ''
                end

                if real_key == 'escape' then
                    self:close()
                end
                
                if real_key == 'up' then
                    if self.index_shift < #self.previous_strings then
                        self.string_index = #self.previous_strings - self.index_shift
                        self.index_shift = self.index_shift + 1
                    end

                    if self.string_index > 0 and self.string_index <= #self.previous_strings then
                        self.val = self.previous_strings[self.string_index]
                    end
                end

                if real_key == 'down' then
                    if self.index_shift > 0 then
                        self.index_shift = self.index_shift - 1
                        self.string_index = #self.previous_strings - self.index_shift
                    end

                    if self.string_index > 0 and self.string_index <= #self.previous_strings then
                        self.val = self.previous_strings[self.string_index]
                    end
                end

                self.val = self.val .. key

                self.real_text = love.graphics.newText(font, self.val .. '_')
            end
        end
    end

    function console:draw()
        if self.shown then
            love.graphics.setColor(0.2, 0.2, 0.3, 0.2)
            love.graphics.rectangle('fill', 0, 0, current_res[1], current_res[2])

            for i = 1, #self.previous_commands do
                local text_data = self.previous_commands[i]
                if type(self.previous_commands[i]) == 'table' then
                    text_data = self.previous_commands[i][1]
                end

                local py = current_res[2] - #self.previous_commands * (text_data:getHeight()*self.scale) + (i-2)*text_data:getHeight()*self.scale

                love.graphics.setColor(0, 0, 0, 0.2)
                love.graphics.rectangle('fill', 0, py, text_data:getWidth()*self.scale + 2*self.ox, text_data:getHeight()*self.scale)

                if type(self.previous_commands[i]) == 'table' then
                    love.graphics.setColor(self.previous_commands[i][2])
                else
                    love.graphics.setColor(0.9, 0.9, 0.9, 1)
                end


                love.graphics.draw(text_data, self.ox, py, 0, self.scale)
            end

            love.graphics.setColor(0, 0, 0, 0.5)
            love.graphics.rectangle('fill', 0, current_res[2] - self.real_text:getHeight() * self.scale, current_res[1], self.real_text:getHeight() * self.scale)

            love.graphics.setColor(0.9, 0.9, 0.9, 1)
            love.graphics.draw(self.real_text, self.ox, current_res[2] - (self.real_text:getHeight() * self.scale), 0, self.scale)

        end
    end

    return setmetatable(console, meta)
end
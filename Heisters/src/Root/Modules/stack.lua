function new_stack()
    local stack = {
        id = GID(),
        UI = nil,
        world = nil,
        light_map = nil,
        console = nil,
        particle_systems = {},
        paused = false,
        puzzle = false,
        current_scene_file = nil,
    }

    stack.cache = {
        pause_menu = nil
    }

    stack.controls = {
        -- in game
        up = {'w', 'up'},
        down = {'s', 'down'},
        left = {'a', 'left'},
        right = {'d', 'right'},
        interact = {'e', '$'},
        ability1 = {'lshift', '$'},
        ability2 = {'2', '$'},
        ability3 = {'3', '$'},
        
        -- puzzle
        puzzle_up = {'w', 'up'},
        puzzle_down = {'s', 'down'},
        puzzle_left = {'a', 'left'},
        puzzle_right = {'d', 'right'},
        puzzle_interact = {'space', '$'}
    }

    function stack:clear()
        store_data_files()

        reset_love()

        self.paused = false
        self.puzzle = false


        if self.UI ~= nil then
            kill_obj(self.UI)
            self.UI = nil
        end

        if self.world ~= nil then
            kill_obj(self.world)
            self.world = nil
        end
    end

    function stack:open_console()
        self.console = new_console(self)
        self.console:open()
    end

    function stack:close_console()
        self.console:close()
    end

    function stack:build(world, UI, light_map)
        math.randomseed(os.time())

        self.UI = UI
        self.world = world
        self.light_map = light_map

        store_data_files()
    end

    function stack:add_light_map(map)
        table.insert(self.light_maps, map)
    end

    function stack:update()
        if not self.start then return end

        collectgarbage("setpause", 100)

        -- updates tweeing library
        flux.update(love.timer.getDelta())

        -- cleans memory

        if self.world ~= nil and not self.paused then
            self.world:update()
        end

        if self.light_map ~= nil then
            self.light_map:update()
        end

        if self.UI ~= nil then
            self.UI:update()
        end

        if self.console ~= nil then
            self.console:update()
        end
    end

    function stack:draw()
        if not self.start then return end

        if self.world ~= nil and self.world.hidden == false then
            self.world:draw()
        end

        if self.light_map ~= nil then
            self.light_map:draw()
        end

        if self.UI ~= nil then
            love.graphics.setShader(nil)
            self.UI:draw()
        end

        if self.console ~= nil then
            self.console:draw()
        end
    end

    return stack
end

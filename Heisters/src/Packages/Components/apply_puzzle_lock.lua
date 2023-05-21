function new_puzzle_lock(ent, puzzle_UI, stats, end_exec, params)
    local end_exec = end_exec or function() end
    local params = params or {}

    local lock = {
        ent = ent,
        puzzle_UI = puzzle_UI,
        stats = stats,
        notify = 0,
        component_layer = true,
        icon = icon or 1,
        bob_dir = 1,
        icon_bob = math.random(),
        is_open = false,
        end_exec = end_exec,
        params = params
    }

    ent.locked = false

    local meta = {
        type = 'component'
    }

    function lock:update()
        self.notify = 0

        if self.bob_dir == -1 and self.icon_bob <= 0 then
            self.bob_dir = 1
        elseif self.bob_dir == 1 and self.icon_bob >= 1 then
            self.bob_dir = -1
        else
            self.icon_bob = self.icon_bob + 0.02 * self.bob_dir
        end

        local tile_pos = vec2(self.ent.pos.x/self.ent.world.tilesize, self.ent.pos.y/self.ent.world.tilesize)
        local world = self.ent.world

        for x = -1, 1 do
            for y = -1, 1 do
                local pos = vec2(tile_pos.x + x, tile_pos.y + y)
                if world.grid[pos.x] ~= nil and world.grid[pos.x][pos.y] ~= nil and
                    type(world.grid[pos.x][pos.y]) == 'entity' and world.grid[pos.x][pos.y] == world.focus_ent then
                        self.notify = self.notify + 1
                end
            end
        end

        local mx, my = love.mouse:getPosition()
        local px, py = self.ent.world:world_to_screen_coords(self.ent)
        local scale = {self.ent.world.zoom*screen_ratio[1], self.ent.world.zoom*screen_ratio[2]}

        if mx > px and my > py and
            mx < px + (self.ent.world.tilesize * scale[1])
            and my < py + (self.ent.world.tilesize * scale[2]) then
            self.notify = self.notify + 1
        end


        if self.ent.locked == true then self.notify = 0 end


        if self.notify > 0 and self.stats ~= nil then
            self.stats.pos.x = self.ent.pos.x + self.ent.world.tilesize/2 - self.stats.box.w/2
            self.stats.pos.y = self.ent.pos.y - self.stats.box.h * 1.2

            if love.keyboard.isDown(stack.controls.interact[1]) or love.keyboard.isDown(stack.controls.interact[2]) then
                if stack.puzzle == false then
                    self.current_puzzle = apply_puzzle(stack, self.puzzle_UI())
                    self.ent.current_puzzle = self.current_puzzle
                end
            end

            self.stats:update()
        end

        if self.current_puzzle ~= nil and self.current_puzzle.finished then
            self.end_exec(unpack(self.params))
        end


    end

    function lock:draw()
        if self.notify > 0 and self.stats ~= nil then
            love.graphics.setColor(1,1,1,0.8)
            self.stats:draw()
        elseif self.notify == 0 and self.ent.locked == false then
            
            love.graphics.setColor(0,0,0,0.25)
            love.graphics.draw(in_game_icons.sheet, in_game_icons[self.icon], 
            self.ent.pos.x + self.ent.world.tilesize, 
            self.ent.pos.y + (self.ent.world.tilesize/4 * self.icon_bob) + self.ent.world.tilesize/2,
                            0, self.ent.world.img_scale * -1, self.ent.world.shadow_stretch * -1)
            love.graphics.setColor(1,1,1,1)

            love.graphics.draw(in_game_icons.sheet, in_game_icons[self.icon], 
            self.ent.pos.x, 
            self.ent.pos.y - self.ent.world.tilesize/1.5 - (self.ent.world.tilesize/4 * self.icon_bob))
        end
    end

    return setmetatable(lock, meta)
end
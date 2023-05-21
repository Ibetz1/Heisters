function new_vault_puzzle(x, y, index)
    local x = x or 0
    local y = y or 0
    local w = 448
    local h = 448
    local scale = 1
    local index = index or 3

    w = math.ceil(w/(16*scale)) * (16*scale)
    h = math.ceil(h/(16*scale)) * (16*scale)

    local probe_size = 32

    local colors = {
        {1, 0, 0},

        {1, 1, 0},

        {0, 1, 1},

        {0, 1, 0},

        {0.6, 0.2, 0.2},

        {0.2, 0.7, 1},

        {0, 0.2, 1},

        {0.6, 0.2, 1},

        {1, 0, 1},

        {1, 0.4, 0.6},

        {0.7, 1, 0.3},

        {0.3, 0.3, 0.5}
    }

    colors = shuffle(colors)

    local goals = {
        {pos = vec2(1, 1), 
        start = vec2(x - probe_size * 1.5, y - probe_size * 3.5 + 2), 
        
        w = probe_size, h = probe_size, 
        
        color = colors[1], 
        
        draw = true, hit = false,
        
        finished = vec2(x - probe_size * 1.5, y - probe_size * 2.5 + 2),
        
        asset = 4}, -- top left

        {pos = vec2(1, 1), 
        start = vec2(x - probe_size/2, y - probe_size * 3.5 + 2), 
        
        w = probe_size, h = probe_size, 
        
        color = colors[2], 
        
        draw = true, hit = false,
        
        finished = vec2(x - probe_size/2, y - probe_size * 2.5 + 2),
        
        asset = 4}, -- top mid

        {pos = vec2(1, 1), 
        start = vec2(x + probe_size/2, y - probe_size * 3.5 + 2), 
        
        w = probe_size, h = probe_size, 
        
        color = colors[3], 
        
        draw = true, hit = false,
        
        finished = vec2(x + probe_size/2, y - probe_size * 2.5 + 2),
        
        asset = 4}, -- top right




        {pos = vec2(1, 1), 
        start = vec2(x + probe_size * 2.5 - 1.8, y - probe_size * 1.5), 
        
        w = probe_size, h = probe_size,
        
        color = colors[4], 
        
        draw = true, hit = false,
        
        finished = vec2(x + probe_size * 1.5 - 1, y - probe_size * 1.5),
        
        asset = 1}, -- right top

        {pos = vec2(1, 1), 
        start = vec2(x + probe_size * 2.5 - 1.8, y - probe_size/2), 
        
        w = probe_size, h = probe_size,
        
        color = colors[5], 
        
        draw = true, hit = false,
        
        finished = vec2(x + probe_size * 1.5 - 1, y - probe_size/2),
        
        asset = 1}, -- right mid

        {pos = vec2(1, 1), 
        start = vec2(x + probe_size * 2.5 - 1.8, y + probe_size/2), 
        
        w = probe_size, h = probe_size,
        
        color = colors[6], 
        
        draw = true, hit = false,
        
        finished = vec2(x + probe_size * 1.5 - 1, y + probe_size/2),
        
        asset = 1}, -- right mid




        {pos = vec2(1, 1), 
        start = vec2(x + probe_size/2, y + probe_size * 2.5 - 4), 
        
        w = probe_size, h = probe_size,
        
        color = colors[7], 
        
        draw = true, hit = false,
        
        finished = vec2(x + probe_size/2, y + probe_size * 1.5 - 5),
        
        asset = 2}, -- bottom right

        {pos = vec2(1, 1), 
        start = vec2(x - probe_size/2, y + probe_size * 2.5 - 4), 
        
        w = probe_size, h = probe_size,
        
        color = colors[8], 
        
        draw = true, hit = false,
        
        finished = vec2(x - probe_size/2, y + probe_size * 1.5 - 5),
        
        asset = 2}, -- bottom mid

        {pos = vec2(1, 1), 
        start = vec2(x - probe_size * 1.5, y + probe_size * 2.5 - 4), 
        
        w = probe_size, h = probe_size,
        
        color = colors[9], 
        
        draw = true, hit = false,
        
        finished = vec2(x - probe_size * 1.5, y + probe_size * 1.5 - 5),
        
        asset = 2}, -- bottom left





        {pos = vec2(1, 1), 
        start = vec2(x - probe_size * 3.5 + 2, y + probe_size/2), 
        
        w = probe_size, h = probe_size,
        
        color = colors[10],
        
        draw = true, hit = false,
        
        finished = vec2(x - probe_size * 2.5 + 2, y + probe_size/2),
        
        asset = 3}, -- left bottom

        {pos = vec2(1, 1), 
        start = vec2(x - probe_size * 3.5 + 2, y - probe_size/2), 
        
        w = probe_size, h = probe_size,
        
        color = colors[11],
        
        draw = true, hit = false,
        
        finished = vec2(x - probe_size * 2.5 + 2, y - probe_size/2),
        
        asset = 3}, -- left mid

        {pos = vec2(1, 1), 
        start = vec2(x - probe_size * 3.5 + 2, y - probe_size * 1.5), 
        
        w = probe_size, h = probe_size,
        
        color = colors[12],
        
        draw = true, hit = false,
        
        finished = vec2(x - probe_size * 2.5 + 2, y - probe_size * 1.5),
        
        asset = 3}, -- left mid
    }

    goals = shuffle(goals)

    for i = 1,#goals do
        goals[i].pos.x = goals[i].start.x
        goals[i].pos.y = goals[i].start.y
    end

    local new_goals = {}

    for i = 1, index do
        table.insert(new_goals, goals[i])
    end

    goals = new_goals

    local puzzle = {
        id = GID(),
        pos = vec2(x - w/2, y - h/2),
        w = w,
        h = h,
        vox = 0,
        voy = h*2,
        probe_size = probe_size,
        score = 0,
        score_max = 5,
        probe = nil,
        goals = goals,
        goal = 1,
        score = 0,
        finished = false,
        center_peice = {vault_puzzle_peices.sheet, vault_puzzle_peices[9]},
        open = false,
        scale = pix_scale
    }

    local meta = {
        type = 'puzzle'
    }

    function puzzle:new_probe(goal)
        local probe = {
            id = GID(),
            pos = vec2(self.pos.x, self.pos.y),
            w = self.probe_size,
            h = self.probe_size,
            corners = {
                {pos = vec2(self.pos.x + self.w - self.probe_size, self.pos.y), 
                asset = 6}, -- top right

                {pos = vec2(self.pos.x + self.w - self.probe_size, self.pos.y + self.h - self.probe_size), 
                asset = 8}, -- bottom right

                {pos = vec2(self.pos.x, self.pos.y + self.h - self.probe_size), 
                asset = 7}, -- bottom left

                {pos = vec2(self.pos.x, self.pos.y), 
                asset = 5} -- top left
            },
            corner = 1,
            goal = goal,
            sent = false,
            success = nil,
            center = vec2(self.pos.x + self.w/2 - self.probe_size/2, self.pos.y + self.w/2 - self.probe_size/2),
            puzzle = self,
            speed = math.random(4, 6)
        }

        function probe:send()
            self.sent = true
        end

        function probe:update()
            if self.sent == false then
                local dx = math.floor(self.corners[self.corner].pos.x - self.pos.x)
                local dy = math.floor(self.corners[self.corner].pos.y - self.pos.y)

                if math.abs(dx) >= self.speed then
                    if dx > 0 then
                        self.pos.x = self.pos.x + self.speed
                    elseif dx < 0 then
                        self.pos.x = self.pos.x - self.speed
                    end
                end

                if math.abs(dy) >= self.speed then
                    if dy > 0 then
                        self.pos.y = self.pos.y + self.speed
                    elseif dy < 0 then
                        self.pos.y = self.pos.y - self.speed
                    end
                end

                if math.abs(dx) <= self.speed and math.abs(dy) <= self.speed then
                    if self.corner + 1 == #self.corners + 1 then
                        self.corner = 0
                    end
                    self.corner = self.corner + 1
                end
            else
                local div = 8
                local dx = self.pos.x - self.center.x
                local dy = self.pos.y - self.center.y

                local gdx = self.pos.x - self.goal.pos.x
                local gdy = self.pos.y - self.goal.pos.y

                if self.corner == 1 and dy < 0 then
                    self.pos.y = self.pos.y - math.ceil(dy/div)

                    if rect_collide(self.pos.x, self.pos.y, self.goal.pos.x, self.goal.pos.y,
                                    self.w, self.h, self.goal.w, self.goal.h) then
                        self.success = true
                    elseif math.ceil(dy/div) == 0 then
                        self.success = false
                    end


                elseif self.corner == 2 and dx > 0 then
                    self.pos.x = self.pos.x - math.ceil(dx/div)

                    if rect_collide(self.pos.x, self.pos.y, self.goal.pos.x, self.goal.pos.y,
                                    self.w, self.h, self.goal.w, self.goal.h) then
                        self.success = true
                    elseif math.ceil(dx/div) == 1 then
                        self.success = false
                    end

                elseif self.corner == 3 and dy > 0 then
                    self.pos.y = self.pos.y - math.ceil(dy/div)


                    if rect_collide(self.pos.x, self.pos.y, self.goal.pos.x, self.goal.pos.y,
                                    self.w, self.h, self.goal.w, self.goal.h) then
                        self.success = true
                    elseif math.ceil(dy/div) == 1 then
                        self.success = false
                    end

                elseif self.corner == 4 and dx < 0 then
                    self.pos.x = self.pos.x - math.ceil(dx/div)

                    if rect_collide(self.pos.x, self.pos.y, self.goal.pos.x, self.goal.pos.y,
                                    self.w, self.h, self.goal.w, self.goal.h) then
                        self.success = true
                    elseif math.ceil(dx/div) == 0 then
                        self.success = false
                    end

                end

                if rect_collide(self.pos.x, self.pos.y, 
                                self.puzzle.pos.x + self.puzzle.w/2 - (self.puzzle.probe_size*5)/2, 
                                self.puzzle.pos.y + self.puzzle.h/2 - (self.puzzle.probe_size*5)/2,
                                self.w, self.h, self.puzzle.probe_size*5, self.puzzle.probe_size*5) then
                    self.success = false
                end
            end
        end

        function probe:draw()
            love.graphics.setColor(0, 0, 0, 0.3)
            love.graphics.draw(vault_puzzle_peices.sheet, vault_puzzle_peices[self.corners[self.corner].asset],
            self.pos.x + self.puzzle.vox, self.pos.y + self.puzzle.voy + 4, 0, 2, 2)

            love.graphics.setColor(self.goal.color)
            love.graphics.draw(vault_puzzle_peices.sheet, vault_puzzle_peices[self.corners[self.corner].asset],
            self.pos.x + self.puzzle.vox, self.pos.y + self.puzzle.voy, 0, 2, 2)
            love.graphics.setColor(1,1,1,1)
        end 

        self.probe = probe
    end

    function puzzle:update()
        local dx = -1 * self.vox
        local dy = -1 * self.voy

        if stack.paused then return end
            
        for i = 1,#self.goals do
            local dx, dy

            if self.goals[i].hit == true then
                dx = math.ceil(self.goals[i].pos.x - self.goals[i].finished.x)
                dy = math.ceil(self.goals[i].pos.y - self.goals[i].finished.y)
            else
                dx = math.ceil(self.goals[i].pos.x - self.goals[i].start.x)
                dy = math.ceil(self.goals[i].pos.y - self.goals[i].start.y)
            end

            self.goals[i].pos.x = self.goals[i].pos.x - dx/6
            self.goals[i].pos.y = self.goals[i].pos.y - dy/6
        end

        if self.probe ~= nil then
            self.probe:update()
        end
        
        if self.failed == true then
            for i = 1,#self.goals do
                self.goals[i].hit = false
            end

            self.score = 0
            self.goals = shuffle(self.goals)
            self.goal = 1
            self:new_probe(self.goals[self.goal])

            self.failed = false
        end

        if self.probe.success == true then
            self.goals[self.goal].hit = true

            if self.goal + 1 <= #self.goals then
                self.goal = self.goal + 1
            else self.goal = 1 end

            self.score = self.score + 1
            self:new_probe(self.goals[self.goal])

            love.audio.play(puzzle_ping)

        elseif self.probe.success == false then
            self.failed = true

        elseif self.score == #self.goals then
            dx = self.vox
            dy = -1.5*self.h - self.voy

            if dx == 0 and dy >= 0 then
                self.finished = true
                apply_puzzle(stack)
            end
        end

        self.vox = math.floor(self.vox + dx/8)
        self.voy = math.floor(self.voy + dy/8)
    end

    function puzzle:draw()
        if stack.paused then return end

        love.graphics.setColor(0.3,0.3,0.3, 0.8)

        local tw = math.ceil(self.w/(16 * self.scale))
        local th = math.ceil(self.h/(16 * self.scale))

        local total_width = tw * (16 * self.scale)
        local total_height = th * (16 * self.scale)

        local w_offset = total_width - self.w
        local h_offset = total_height - self.h

        for w = 0, tw - 1 do
            for h = 0, th - 1 do
                local quad = get_background_quad(w, h, tw, th)

                love.graphics.draw(menu_bg.sheet, menu_bg[quad], self.pos.x + self.vox + (w * 16 * self.scale) - w_offset/2, 
                                                                self.pos.y + self.voy + (h * 16 * self.scale) - h_offset/2, 0, self.scale)
            end
        end

        love.graphics.setColor(0.5,0.5,0.5)


        love.graphics.draw(vault_puzzle_center.sheet, vault_puzzle_center[2],
        self.pos.x + self.w/2 - (self.probe_size*5)/2 + self.vox, self.pos.y + self.w/2 - (self.probe_size*5)/2 + self.voy, 0, 2, 2)

        love.graphics.setColor(0, 0, 0, 0.3)
        for i = 1,#self.goals do
            if self.goals[i].draw == true then
                love.graphics.draw(vault_puzzle_peices.sheet, vault_puzzle_peices[self.goals[i].asset], 
                self.goals[i].pos.x + self.vox, self.goals[i].pos.y + self.voy + 4, 0, 2, 2)
            end
        end

        love.graphics.draw(vault_puzzle_center.sheet, vault_puzzle_center[1],
                            self.pos.x + self.w/2 - (self.probe_size*5)/2 + self.vox, self.pos.y + self.w/2 - (self.probe_size*5)/2 + self.voy + 5, 0, 2, 2)

        love.graphics.setColor(self.goals[self.goal].color)
        love.graphics.draw(vault_puzzle_center.sheet, vault_puzzle_center[3],
        self.pos.x + self.w/2 - (self.probe_size*5)/2 + self.vox, self.pos.y + self.w/2 - (self.probe_size*5)/2 + self.voy, 0, 2, 2)

        for i = 1,#self.goals do
            if self.goals[i].draw == true and self.goals[i].hit == true then
                love.graphics.setColor(self.goals[i].color)
                love.graphics.draw(vault_puzzle_peices.sheet, vault_puzzle_peices[self.goals[i].asset], 
                self.goals[i].pos.x + self.vox, self.goals[i].pos.y + self.voy, 0, 2, 2)
            end
        end
        
        love.graphics.setColor(self.goals[self.goal].color)
        love.graphics.draw(vault_puzzle_center.sheet, vault_puzzle_center[1],
                            self.pos.x + self.w/2 - (self.probe_size*5)/2 + self.vox, self.pos.y + self.w/2 - (self.probe_size*5)/2 + self.voy, 0, 2, 2)

        for i = 1,#self.goals do
            if self.goals[i].draw == true and self.goals[i].hit == false then

                love.graphics.setColor(self.goals[i].color)
                love.graphics.draw(vault_puzzle_peices.sheet, vault_puzzle_peices[self.goals[i].asset], 
                self.goals[i].pos.x + self.vox, self.goals[i].pos.y + self.voy, 0, 2, 2)
            end
        end

        if self.probe ~= nil then
            self.probe:draw()
        end

    end

    function love.keypressed(key)
        if key == stack.controls.puzzle_interact[1] or
            key == stack.controls.puzzle_interact[2] then
            if puzzle.probe ~= nil then
                puzzle.probe:send()
            end
        end
    end

    puzzle:new_probe(puzzle.goals[1])

    return setmetatable(puzzle, meta)
end
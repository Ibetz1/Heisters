-- optimized

function path_finder(ent)
    local path_finder = {
        ent = ent,
        goals = {
            {0, -math.random(3, 5)},
            {math.random(3, 5), 0},
            {0, math.random(3, 5)},
            {-math.random(3, 5), 0},
        },

        start = nil,
        wait_time = 20,
        back_track = false,
        current_goal = math.random(1, 4),
        timer1 = new_timer(15, false),
        timer2 = new_timer(60, false),
        face_counter = 0
    }

    ent.facing = math.random(1, 4)

    local meta = {
        type = 'component'
    }

    function path_finder:update()
        if not self.ent.freeze_look then

            if self.start == nil then
                self.start = vec2(self.ent.tile.x, self.ent.tile.y)
            end

            local move_dir = nil
            local move_amount = nil

            local goal

            local face_goal = self.ent.facing

            if self.back_track == false then
                goal = vec2(self.start.x + self.goals[self.current_goal][1], self.start.y + self.goals[self.current_goal][2])
            else
                goal = self.start
            end

            if self.ent.tile.y == goal.y then
                if self.ent.tile.x > goal.x then
                    face_goal = 4
                elseif self.ent.tile.x < goal.x then
                    face_goal = 2
                end

            elseif self.ent.tile.x == goal.x then
                if self.ent.tile.y > goal.y then
                    face_goal = 1
                elseif self.ent.tile.y < goal.y then
                    face_goal = 3
                end
            end

            if self.ent.tile.x < goal.x and self.ent.facing == face_goal  then
                move_dir = 'x'
                move_amount = 1
            elseif self.ent.tile.x > goal.x and self.ent.facing == face_goal  then
                move_dir = 'x'
                move_amount = -1
            end
            
            if self.ent.tile.y < goal.y and self.ent.facing == face_goal then
                move_dir = 'y'
                move_amount = 1
            elseif self.ent.tile.y > goal.y and self.ent.facing == face_goal then
                move_dir = 'y'
                move_amount = -1

            end

            if self.ent.facing ~= face_goal and self.timer2:tick() then
                local dir = -1

                local p_face = self.ent.facing + 1
                if p_face > 4 then p_face = 1 end

                if p_face == face_goal then
                    dir = 1
                end

                if self.ent.facing + dir <= 0 then
                    self.ent.facing = 4
                elseif self.ent.facing + dir > 4 then
                    self.ent.facing = 1
                else
                    self.ent.facing = self.ent.facing + dir
                end
            end

            if move_dir ~= nil and move_amount ~= nil and self.timer1:tick() then
                self.ent:move(move_dir, move_amount)
            end

            if self.ent.tile.x == goal.x and self.ent.tile.y == goal.y then
                if self.face_counter >= 3 then

                    if self.back_track == false then
                        self.back_track = true
                    else
                        self.back_track = false
                        self.goals = {
                            {0, -math.random(3, 5)},
                            {math.random(3, 5), 0},
                            {0, math.random(3, 5)},
                            {-math.random(3, 5), 0},
                        }

                        local current_goal = math.random(1, #self.goals)

                        if current_goal == self.current_goal then
                            if self.current_goal + 1 <= #self.goals then
                                self.current_goal = self.current_goal + 1
                            else
                                self.current_goal = 1
                            end
                        else
                            self.current_goal = current_goal
                        end
                    end

                    self.face_counter = 0
                elseif self.face_counter < 3 and self.timer2:tick() then
                    if self.ent.facing - 1 <= 0 then
                        self.ent.facing = 4
                    else
                        self.ent.facing = self.ent.facing - 1
                    end

                    self.face_counter = self.face_counter + 1 
                end
            end

        end

    end

    function path_finder:draw()

    end

    return setmetatable(path_finder, meta)

end

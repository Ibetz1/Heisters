function new_power_puzzle(ent, x, y, w, h, num_wires)
    local num_wires = num_wires or math.random(1, 7)
    local x = x or 0
    local y = y or 0
    local w = w or 432
    local h = h or 432

    local scale = pix_scale
    w = math.ceil(w/(16*scale)) * (16*scale)
    h = math.ceil(h/(16*scale)) * (16*scale)

    local colors = {
        {0.7, 0, 0.3},
        {0, 0.8, 0.2},
        {0, 0.4, 0.7},
        {1, 0.8, 0.2},
        {0, 1, 1},
        {1, 0, 1},
        {0.5, 0, 1}
    }

    local puzzle = {
        id = GID(),
        pos = vec2(x - w/2, y - h/2),
        w = w,
        h = h,
        vox = 0,
        voy = h*2,
        tilesize = 48,
        rows = {},
        current_row = 1,
        current_collumn = 1,
        tile_width = (432/48) - 2,
        tile_height = 432/(2*48),
        select = false,
        select_pos = vec2(x, y),
        finished = false,
        num_wires = num_wires,
        shown_wires = 0,
        finish_timer = new_timer(50, true),
        scale = scale
    }

    puzzle.colors = colors

    local meta = {
        type = 'vault_puzzle'
    }

    function puzzle:move(x, y)
        local x = self.current_collumn + x

        local lock = self.rows[self.current_row][self.current_collumn].move
        local vrot = self.rows[self.current_row][self.current_collumn].visual_rotation
        local show = self.rows[self.current_row][self.current_collumn].show


        if lock then y = 0 end

        local y = self.current_row + y

        local number = self.rows[self.current_row][self.current_collumn].number

        if x > self.tile_width then
            x = 1
        elseif x < 1 then
            x = self.tile_width
        end

        if y > #self.rows then
            y = 1
        elseif y < 1 then
            y = #self.rows
        end

        if lock == true then
            self.rows[self.current_row][self.current_collumn].move = false -- previous move
            self.rows[y][x].move = true -- moved move

            self.rows[self.current_row][self.current_collumn].visual_rotation = self.rows[y][x].visual_rotation -- previous rotation
            self.rows[y][x].visual_rotation = vrot -- moved rotation

            self.rows[self.current_row][self.current_collumn].show = self.rows[y][x].show -- previous rotation
            self.rows[y][x].show = show -- moved rotation

            self.rows[self.current_row][self.current_collumn].number = self.rows[y][x].number -- previous number
            self.rows[y][x].number = number -- moved number
        end

        self.current_row = y
        self.current_collumn = x

    end

    function puzzle:new_row()
        local pos = vec2(self.pos.x, self.pos.y + self.tilesize + (#self.rows * self.tilesize))
        local row = {
            pos = pos,
            tilesize = self.tilesize,
            select = false,
            puzzle = self
        }

        numbers = shuffle(self.numbers)


        for i = 1, (w/self.tilesize) - 2 do
            local show = false
            local number = numbers[i]
            
            local visual_rotation = 1
            if math.random(0, 2) == 2 then
                visual_rotation = -1
            end

            for c = 1,#self.shown_collumns do
                if number == self.shown_collumns[c].number then
                    show = true
                    break
                end
            end

            

            table.insert(row, {
                pos = vec2(pos.x + i*self.tilesize, pos.y),
                select = false,
                move = false,
                number = number,
                visual_rotation = visual_rotation,
                show = show
            })

        end

        function row:update()
            for i = 1,#self do
                self[i].select = false
            end

            if self.puzzle.current_row == self.row_pos then
                self[self.puzzle.current_collumn].select = true
            end
        end

        function row:draw(vox, voy)
            for i = 1,#self do
                if self[i].show == true then
                    local ox = 0
                    if self[i].visual_rotation == -1 then
                        ox = self.tilesize
                    end

                    local px = self[i].pos.x + vox + ox
                    local py = self[i].pos.y + voy

                    local color = self.puzzle.colors[self[i].number]


                    local index = 1
                    vert_offset = 0

                    if self.puzzle.collumns[i].complete == true then
                        index = 2
                    end

                    if self[i].select == true then
                        vert_offset = -10

                        if self[i].move then
                            px = self.puzzle.select_pos.x + ox
                            py = self.puzzle.select_pos.y
                        end
                    end

                    love.graphics.setColor(0, 0, 0, 0.5)
                    love.graphics.draw(power_puzzle_peices.sheet, power_puzzle_peices[index], 
                    px, py + 8 + vert_offset,
                        0, 3 * self[i].visual_rotation, 3)
                    
                    love.graphics.setColor(color)

                    love.graphics.draw(power_puzzle_peices.sheet, power_puzzle_peices[index], 
                    px, 
                    py + vert_offset,
                        0, 3 * self[i].visual_rotation, 3)
                end
            end
        end

        table.insert(self.rows, row)
        row.row_pos = #self.rows
    end

    local numbers = {
        1, 2, 3, 4, 5, 6, 7
    }

    numbers = shuffle(numbers)

    puzzle.numbers = numbers
    puzzle.shown_numbers = {}
    puzzle.shown_collumns = {}
    puzzle.collumns = {}

    for i = 1,puzzle.h/(puzzle.tilesize) - 2 do
        puzzle.collumns[i] = {
            complete = false,
            show = false
        }
    end

    for i = 1, puzzle.num_wires do
        puzzle.shown_numbers[i] = numbers[i]
        
        puzzle.collumns[numbers[i]].show = true
        table.insert(puzzle.shown_collumns, puzzle.collumns[numbers[i]])
    end

    for i = 1,#puzzle.collumns do
        puzzle.collumns[i].number = numbers[i]
    end

    for i = 1,puzzle.h/(puzzle.tilesize) - 2 do
        puzzle:new_row()
    end

    function puzzle:update()
        local dx = -1 * self.vox
        local dy = -1 * self.voy

        for i = 1,#self.rows do
            self.rows[i]:update()
        end

        for x = 1,#self.rows do -- column
            local count = 0
            for y = 1, #self.rows do -- row             
                if self.rows[y][x].number == self.numbers[x] and 
                self.rows[y][x].move == false and self.rows[y][x].show == true then
                    count = count + 1
                end
            end

            if count == #self.rows then
                self.collumns[x].complete = true
                
            else
                self.collumns[x].complete = false
            end
        end

        local completed = 0

        for i = 1,#self.collumns do
            if self.collumns[i].complete == true then
                completed = completed + 1
            end
        end


        if completed >= self.num_wires then
            if self.finish_timer:tick() then
                dx = self.vox
                dy = -1.5*self.h - self.voy

                if dx == 0 and dy >= 0 then
                    self.finished = true
                    apply_puzzle(stack)
                end
            end
        end


        self.vox = math.floor(self.vox + dx/8)
        self.voy = math.floor(self.voy + dy/8)
    end

    function puzzle:draw()

        if not stack.paused then

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

                    love.graphics.draw(power_puzzle_bg.sheet, power_puzzle_bg[quad], self.pos.x + self.vox + (w * 16 * self.scale) - w_offset/2, 
                                                                    self.pos.y + self.voy + (h * 16 * self.scale) - h_offset/2, 0, self.scale)
                end
            end

            love.graphics.setColor(1,1,1,1)

            for i = 1,#self.collumns do

                if self.collumns[i].show == true then
                    love.graphics.setColor(0, 0, 0, 0.5)
                    love.graphics.draw(power_puzzle_peices.sheet, power_puzzle_peices[3], 
                    self.pos.x + (i * self.tilesize) + self.vox, 
                    self.pos.y + self.voy + 8, 
                    0, 3)

                    love.graphics.draw(power_puzzle_peices.sheet, power_puzzle_peices[4], 
                    self.pos.x + (i * self.tilesize) + self.vox, 
                    self.pos.y + self.tilesize + ((#self.collumns * self.tilesize)) + self.voy + 8, 
                    0, 3)

                    love.graphics.setColor(self.colors[self.collumns[i].number])

                    love.graphics.draw(power_puzzle_peices.sheet, power_puzzle_peices[3], 
                    self.pos.x + (i * self.tilesize) + self.vox, 
                    self.pos.y + self.voy, 
                    0, 3)
                end
            end

            for i = 1,#self.rows do
                self.rows[i]:draw(self.vox, self.voy)
            end

            for i = 1,#self.collumns do
                if self.collumns[i].show == true then

                    love.graphics.setColor(self.colors[self.collumns[i].number])

                    love.graphics.draw(power_puzzle_peices.sheet, power_puzzle_peices[4], 
                    self.pos.x + (i * self.tilesize) + self.vox, 
                    self.pos.y + self.tilesize + ((#self.collumns * self.tilesize)) + self.voy, 
                    0, 3)
                end
            end

            if self.rows[self.current_row][self.current_collumn].show == true then
                love.graphics.setColor(self.colors[self.rows[self.current_row][self.current_collumn].number])
            else
                love.graphics.setColor(0.2, 0.2 ,0.2)
            end

            local px = self.rows[self.current_row][self.current_collumn].pos.x
            local py = self.rows[self.current_row][self.current_collumn].pos.y

            self.select_pos.x = self.select_pos.x - (self.select_pos.x - px)/4
            self.select_pos.y = self.select_pos.y - (self.select_pos.y - py)/4

            love.graphics.draw(power_puzzle_peices.sheet, power_puzzle_peices[6], 
            self.select_pos.x + self.vox, 
            self.select_pos.y + self.voy - 8,
                0, 3)

            local oy = ((self.current_row * self.tilesize) + self.pos.y + self.voy) - (self.pos.y + self.voy) - self.tilesize
            if self.select == false then
                oy = 0
            else
                love.graphics.setColor(1, 0, 0)
            end

            love.graphics.draw(power_puzzle_peices.sheet, power_puzzle_peices[10], -- top
            self.select_pos.x + self.vox, 
            self.pos.y + self.voy + oy, 
            0, 3)

            local oy = ((self.current_row * self.tilesize) + self.pos.y + self.voy) 
            oy = oy - (self.pos.y + self.voy + self.h) + self.tilesize * 1.5
            if self.select == false then
                oy = 0
            end

            love.graphics.draw(power_puzzle_peices.sheet, power_puzzle_peices[9], -- bottom
            self.select_pos.x + self.vox, 
            self.pos.y + self.voy + self.h - self.tilesize + oy, 
            0, 3)

            love.graphics.draw(power_puzzle_peices.sheet, power_puzzle_peices[8], -- left
            self.pos.x + self.vox, 
            self.select_pos.y + self.voy, 
            0, 3)

            love.graphics.draw(power_puzzle_peices.sheet, power_puzzle_peices[7], -- right
            self.pos.x + self.vox + self.w - self.tilesize, 
            self.select_pos.y + self.voy, 
            0, 3)

        end

    end

    function love.keypressed(key)
        if key == stack.controls.puzzle_right[1] or 
            key == stack.controls.puzzle_right[2] then
            puzzle:move(1, 0)
        end

        if key == stack.controls.puzzle_left[1] or 
            key == stack.controls.puzzle_left[2] then
            puzzle:move(-1, 0)
        end

        if key == stack.controls.puzzle_up[1] or 
            key == stack.controls.puzzle_up[2] then
            puzzle:move(0, -1)
        end

        if key == stack.controls.puzzle_down[1] or 
            key == stack.controls.puzzle_down[2] then
            puzzle:move(0, 1)
        end

        if key == stack.controls.puzzle_interact[1] or
            key == stack.controls.puzzle_interact[2] then
            if puzzle.rows[puzzle.current_row][puzzle.current_collumn].show == true then
                puzzle.rows[puzzle.current_row][puzzle.current_collumn].move = not puzzle.rows[puzzle.current_row][puzzle.current_collumn].move
                puzzle.select = not puzzle.select
            end
        end

    end

    return setmetatable(puzzle, meta)
end

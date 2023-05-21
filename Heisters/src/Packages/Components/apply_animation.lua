function new_animation(ent, anim_sheet, anim_quad_start, anim_quad_end, tick_rate)
    local tick_rate = tick_rate or 10
    local anim = {
        id = GID(),
        ent = ent,
        sheet = anim_sheet,
        anim_start = anim_quad_start,
        anim_end = anim_quad_end,
        anim_timer = new_timer(tick_rate, false),
        tick = 0,
        frozen = false,
        component_layer = false,
        layers = {},
    }

    ent.anim = anim

    local meta = {
        type = 'component'
    }

    function anim:freeze()
        self.frozen = true
    end

    function anim:add_layer(do_shader, start_quad, stop)
        local layer = {
            do_shader = do_shader,
            start_quad = start_quad,
            stop = true,
            tick = 0
        }

        table.insert(self.layers, layer)
        layer.index = #self.layers
        return #self.layers
    end

    function anim:remove_layer(index)
        self.layers[index] = nil
    end

    function anim:update()
        if self.frozen == false and self.anim_timer:tick() then
            self.tick = self.tick + 1

            if self.anim_start + self.tick >= self.anim_end then
                self.tick = 0
            end

            for i = 1,#self.layers do
                self.layers[i].tick = self.tick
            end

            ent.image[2] = self.sheet[self.anim_start + self.tick]
            ent.image.quad_num = self.anim_start + self.tick
        end
    end

    function anim:draw()
        for i = 1, #self.layers do
            if self.layers[i].do_shader == false then
                love.graphics.setShader()
            elseif love.graphics:getShader() == nil then
                love.graphics.setShader(self.ent.world.shader)
            end

            if not self.frozen or self.layers[i].stop == false then
                love.graphics.draw(self.sheet.sheet, self.sheet[self.layers[i].start_quad + self.layers[i].tick], 
                self.ent.visual_pos.x, self.ent.visual_pos.y - self.ent.hop, 0, self.ent.image[3])
            end
        end
    end

    return setmetatable(anim, meta)

end
function new_character_animation(ent, sheet, start_quad, anim_len)
    local anim_len = anim_len or 1
    local start_quad = start_quad or 1
    local anim = {
        id = GID(),
        ent = ent,
        sheet = sheet,
        start_quad = start_quad,
        anim_len = anim_len,
        start_tick = 0,
        tick = 0,
        anim_timer = new_timer(2, false),
        outline_color = {0,0.5,0.5}
    }

    local meta = {
        type = 'component'
    }

    function anim:update()
        local tick = self.start_quad + ((self.ent.facing - 1) * self.anim_len)
        self.ent:set_image(self.sheet, self.sheet[tick], nil, tick)

        if self.ent.invisible then
            self.ent.outline = true
        end
    end

    function anim:draw()

    end

    return setmetatable(anim, meta)
end

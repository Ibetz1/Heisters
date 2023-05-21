function apply_facing_arrow(ent, do_timer)
    local do_timer = do_timer or false
    local arrow = {
        id = GID(),
        ent = ent,
        ox = 0,
        oy = 0,
        facing = 1,
        face_timer = new_timer(2, false),
        vanish_timer = new_timer(100, false),
        do_show = false,
        do_timer = do_timer,
        alpha = 0,
        change_alpha = 0,
        alpha_dir = 0.02
    }

    local meta = {
        type = 'component'
    }

    function arrow:update()
        if self.face_timer:tick() or self.do_timer == false then
            self.facing = self.ent.facing
        end

        if self.facing == 1 then
            self.ox = (self.ent.world.tilesize * 0.2)/2
            self.oy = -1 * self.ent.world.tilesize/2 - 3
        elseif self.facing == 2 then
            self.ox = self.ent.world.tilesize - 2
            self.oy = (self.ent.world.tilesize * 0.2)/2
        
        elseif self.facing == 3 then
            self.ox = (self.ent.world.tilesize * 0.2)/2
            self.oy = self.ent.world.tilesize - 2

        elseif self.facing == 4 then
            self.ox = -1 * self.ent.world.tilesize/2 - 3
            self.oy = (self.ent.world.tilesize * 0.2)/2

        end

        if self.ent.move_to.x ~= self.ent.pos.x or self.ent.move_to.y ~= self.ent.pos.y then
            self.do_show = true
            if self.alpha < 1 then
                self.alpha = 1
            end
        else
            self.alpha = self.alpha - self.alpha_dir
            if self.alpha == 0 then
                self.do_show = false
            end
        end

    end

    function arrow:draw()
        love.graphics.setShader()

        love.graphics.setColor(1,1,1,self.alpha)
        if self.do_show then
            love.graphics.draw(in_game_icons.sheet, in_game_icons[2+self.facing], 
                                self.ent.visual_pos.x + self.ox, 
                                self.ent.visual_pos.y + self.oy, 0, 0.8, 0.8)
        end
        love.graphics.setColor(1,1,1,1)
    end

    return setmetatable(arrow, meta)

end
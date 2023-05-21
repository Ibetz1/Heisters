function new_cam_comp(ent, world, scale_div)
    local scale_div = scale_div or 21

    local cam = {
        id = GID(),
        box = {w = res[1]/scale_div, 
               h = res[2]/scale_div,
               pos = vec2()},
        pos = vec2(),
        ent = ent,
        scalex = 1,
        scaley = 1,
        ox = 0,
        oy = 0,
        max_scale = 2,
        smoothing = 8,
        scale_div = scale_div
    }

    local meta = {
        type = 'camera'
    }

    function cam:get_bounding_box()
        return {
            pos = vec2(self.ent.chunk_pos.x * self.ent.world.tilesize * self.ent.world.chunk_size, 
            self.ent.chunk_pos.y * self.ent.world.tilesize * self.ent.world.chunk_size),

            w = self.ent.world.chunk_size * self.ent.world.tilesize,
            h = self.ent.world.chunk_size * self.ent.world.tilesize
        }
    end

    function cam:lock_box()
        local box1 = self.box
        local box2 = self:get_bounding_box()

        local poses = {'x', 'y'}
        local sides = {'w', 'h'}
        local scales = {self.scalex, self.scaley}

        for i = 1, 2 do
            local pos = poses[i]
            local side = sides[i]
            local scale = scales[i]

            if box1.pos[pos] < box2.pos[pos] and box1[side] * scale < box2[side] then
                local offset = (box2.pos[pos] - box1.pos[pos])
                box1.pos[pos] = box1.pos[pos] + offset
            end
    
            if box1.pos[pos] + (box1[side] * scale) > box2.pos[pos] + box2[side] and box1[side] * scale < box2[side] then
                local offset = (box2.pos[pos] + box2[side]) - (box1.pos[pos] + (box1[side] * scale))
                box1.pos[pos] = box1.pos[pos] + offset
            end
        end
    end

    function cam:update()
        local world = self.ent.world

        local scalex_offset = current_res[1] / (self.box.w * self.scalex) / screen_ratio[1]
        local scaley_offset = current_res[2] / (self.box.h * self.scaley) / screen_ratio[2]

        self.scalex = self.scalex + (scalex_offset - self.scalex)/self.smoothing
        self.scaley = self.scaley + (scaley_offset - self.scaley)/self.smoothing

        self.pos.x = self.ent.visual_pos.x + self.ent.world.tilesize/2
        self.pos.y = self.ent.visual_pos.y + self.ent.world.tilesize/2

        self.box.pos.x = self.pos.x - (self.box.w * self.scalex)/2 - (self.ent.world.tilesize)/2
        self.box.pos.y = self.pos.y - (self.box.h * self.scaley)/2 - (self.ent.world.tilesize)/2

        self:lock_box()

        local px = self.box.pos.x + (self.box.w * self.scalex)/2 - (self.ent.world.tilesize)/2
        local py = self.box.pos.y + (self.box.h * self.scaley)/2 - (self.ent.world.tilesize)/2

        local dif = vec2(self.pos.x - px, self.pos.y - py)
        
        self.ox = (self.ox + (self.pos.x - self.ox - dif.x)/self.smoothing)
        self.oy = (self.oy + (self.pos.y - self.oy - dif.y)/self.smoothing)

        world.render_ox = -self.ox - (self.ent.world.tilesize/2)
        world.render_oy = -self.oy - (self.ent.world.tilesize/2)

        world.zoom = ((self.scalex + self.scaley)/2)
    end

    function cam:draw()
    end

    return setmetatable(cam, meta)

end
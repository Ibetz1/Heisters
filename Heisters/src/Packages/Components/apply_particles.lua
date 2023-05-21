function apply_particles(ent, system)
    local particles = {
        id = GID(),
        psystem = system,
        ent = ent
    }

    local meta = {
        type = 'component'
    }

    function particles:update()
        self.psystem:update(love.timer.getDelta())
    end

    function particles:draw()
        love.graphics.draw(self.psystem, self.ent.visual_pos.x + 8, 
                                        self.ent.visual_pos.y - 4)
    end

    return particles
end
function dash_ability(ent, slot, dist, cooldown)
    local dist = dist or 2
    local cooldown = cooldown or dist * 1.5

    local quad = 67
    local ability = {
        id = GID(),
        cooldown = cooldown,
        dist = dist,
        dist_tick = 0,
        timer = world_effects.ability(cooldown, 'ability_cooldowns', 'ability' .. slot, quad),
        tick_timer = new_timer(3, false),

        slot = slot,
        facing = 1,
        executing = false,
        ent = ent,
        added = false,
        quad = quad
    }

    ability.timer.timer.current_tick = 0
    -- ability.timer.circ.mask.pct = 0

    local meta = {
        type = 'ability'
    }

    function ability:execute()
        local dir = 'x'
        local mult = 1

        if self.ent.facing == 1 or self.ent.facing == 3 then
            dir = 'y'
        end

        if self.ent.facing == 4 or self.ent.facing == 1 then
            mult = -1
        end

        if self.dist_tick < self.dist then
            if self.tick_timer:tick() then
                self.ent:move(dir, mult)
                self.dist_tick = self.dist_tick + 1
            end
        else
            world_effects.ability(self.cooldown, 'ability_cooldowns', 'ability' .. self.slot, quad)
            self.dist_tick = 0
            self.timer.current_tick = self.timer.time
            self.executing = false
        end
    end

    function ability:update()
        if self.executing then
            self:execute()
        end

        if self.timer.timer.current_tick == 0 then
            if love.keyboard.isDown(stack.controls['ability' .. self.slot]) then
                self.executing = true
            end
        end

    end

    function ability:draw()

    end

    return setmetatable(ability, meta)
end
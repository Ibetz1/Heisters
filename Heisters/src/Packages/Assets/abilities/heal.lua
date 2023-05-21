function heal_ability(ent, slot, strength, cooldown)
    local strength = strength or 3
    local cooldown = cooldown or strength * 1.5


    local quad = 69
    local ability = {
        id = GID(),
        cooldown = cooldown,
        strength = strength,
        dist_tick = 0,
        timer = world_effects.ability(cooldown, 'ability_cooldowns', 'ability' .. slot, quad),
        tick_timer = new_real_timer(strength, -1),--new_timer(strength, false),

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
        if self.ent.sudo_max < self.ent.max_seen then
            self.ent.sudo_max = self.ent.sudo_max + 0.1
        end

        if self.ent.sudo_max - self.ent.seen_tick > 1 then
            self.ent.seen_tick = self.ent.seen_tick + 1
        end
    end

    function ability:update()
        if self.executing then
            self:execute()

            self.tick_timer:tick()

            if self.tick_timer.current_tick == 0 then
                self.executing = false
                self.tick_timer.current_tick = self.tick_timer.time
            end
        end

        if self.timer.timer.current_tick == 0 then
            if love.keyboard.isDown(stack.controls['ability' .. self.slot]) then
                world_effects.ability(cooldown, 'ability_cooldowns', 'ability' .. self.slot, quad)
                world_effects.active(self.strength, 'world_cooldowns', 'ability' .. self.slot .. 'active', quad - 44)
                self.executing = true
            end
        end

    end

    function ability:draw()

    end

    return setmetatable(ability, meta)
end
function invisible_ability(ent, slot, time, cooldown)
    local time = time or 3
    local cooldown = cooldown or time * 1.5

    local quad = 82
    local ability = {
        id = GID(),
        cooldown = cooldown,
        time = time,
        dist_tick = 0,
        timer = world_effects.ability(cooldown, 'ability_cooldowns', 'ability' .. slot, quad),
        tick_timer = new_real_timer(time, -1),

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

    function ability:update()
        if self.executing then
            self.ent.invisible = true

            self.tick_timer:tick()

            if self.tick_timer.current_tick == 0 then
                self.ent.invisible = false
                self.executing = false
                self.tick_timer.current_tick = self.tick_timer.time
            end
        end

        if self.timer.timer.current_tick == 0 then
            if love.keyboard.isDown(stack.controls['ability' .. self.slot]) then
                world_effects.ability(self.cooldown, 'ability_cooldowns', 'ability' .. self.slot, self.quad)
                world_effects.active(self.time, 'world_cooldowns', 'ability' .. self.slot .. 'active', quad - 44)
                self.executing = true
            end
        end

    end

    function ability:draw()

    end

    return setmetatable(ability, meta)
end
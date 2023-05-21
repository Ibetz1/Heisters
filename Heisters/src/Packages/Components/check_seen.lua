function apply_check_seen(ent, max)
    local max = max or 250

    local check_seen = {
        id = GID(),
        max = max,
        ent = ent,
        health_pct = 1,
        bob = 0,
        bob_max = 5,
        bob_dir = 1,
        bob_inc = 0.2,
        charge_timer = new_timer(200, false),
        do_charge = true,
        spotted = false,
        spot_time = 5,
        spot_strength = 0.2,
        spot_timer = new_real_timer(5, -1),
        spot_max = 40,
        spot_tick = 0,
        kill_timer = false,
    }

    ent.seen = false
    ent.seen_by = nil
    ent.seen_tick = max
    ent.max_seen = max
    ent.sudo_max = max
    ent.bar_pcts.health = check_seen.health_pct
    ent.seen_change_rate = 0.5
    ent.comp_kill = false

    local meta = {
        type = 'component'
    }

    function ent:check_spot(ent, count, damage, kill)
        if count > 0 then
            if kill then
                self.comp_kill = true
            else
                self.seen_tick = self.seen_tick - damage
                self.seen = true
                self.seen_by = ent
            end
        elseif self.seen_by == ent then
            self.seen_by = nil
            self.seen = false
        end
    end

    function check_seen:update()
        self.health_pct = self.ent.seen_tick/self.max
        self.sudo_max_pct = self.ent.sudo_max/self.max
        if self.health_pct < 0 then self.health_pct = 0 end
        if self.sudo_max_pct < 0 then self.sudo_max_pct = 0 end

        self.ent.bar_pcts.health = self.health_pct
        self.ent.bar_pcts.sudo_max_health = self.sudo_max_pct

        if self.bob_max ~= 0 then
            if self.bob < self.bob_max and self.bob_dir == 1 then
                self.bob = self.bob + self.bob_inc
            elseif self.bob_dir == 1 then
                self.bob_dir = -1
            end

            if self.bob > 0 and self.bob_dir == -1 then
                self.bob = self.bob - self.bob_inc
            elseif self.bob_dir == -1 then
                self.bob_dir = 1
            end
        end

        if self.ent.seen == true then
            self.do_charge = false
            self.charge_timer.ctick = 0

            self.spot_tick = self.spot_tick + 1
        else
            if self.spot_tick > 0 and not self.spotted then
                self.spot_tick = self.spot_tick - 0.1
            end
        end

        if self.spot_tick >= self.spot_max and not self.spotted then
            self.spotted = true
            world_effects.active(self.spot_time, 'world_cooldowns', 'spot_timer', 14)
        end

        if self.spotted then
            self.ent.sudo_max = self.ent.sudo_max - self.spot_strength

            self.spot_timer:tick()

            if self.spot_timer.current_tick == 0 then
                self.spotted = false
                self.spot_tick = 0
                self.spot_timer.current_tick = self.spot_timer.time
            end
        end

        if self.do_charge == false and not self.spotted and self.charge_timer:tick() then
            self.do_charge = true
            self.charge_timer.ctick = 0
        end


        if self.ent.seen_tick < self.ent.sudo_max and self.do_charge == true then
            self.ent.seen_tick = self.ent.seen_tick + self.ent.seen_change_rate
        end


        if self.ent.seen_tick > self.ent.sudo_max then
            self.ent.seen_tick = self.ent.sudo_max
        end

        if self.ent.seen_tick <= 0 then
            self.ent:kill()
            death_screen(stack)
        end

        if self.ent.comp_kill then
            self.ent.seen_tick = self.ent.seen_tick - 5
        end
    end

    function check_seen:draw()
        love.graphics.setShader()
        if self.ent.seen then
            love.graphics.setColor(1,1,1, self.bob/self.bob_max)
            love.graphics.draw(in_game_icons.sheet, in_game_icons[7], self.ent.visual_pos.x + 2.5, 
                                                                        self.ent.visual_pos.y - self.ent.world.tilesize/1.5 + self.bob,
                                                                        0, 0.7)
        end
    end

    return setmetatable(check_seen, meta)

end

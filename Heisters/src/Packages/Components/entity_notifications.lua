function apply_notificiations(ent)
    local notifiction = {
        id = GID(),
        ent = ent,
        notifictions = {}
    }

    local meta = {
        type = 'component'
    }

    ent.notifictions = notifiction.notifictions

    function ent:send_notification(note, break_timer, bob)
        local break_timer = break_timer or 0
        local bob = bob or true

        if break_timer ~= 0 then
            break_timer = new_timer(break_timer, true)
        end

        self.notifictions[note] = {note = love.graphics.newText(font, note), timer = break_timer, bob = bob, scale = 1}
    end

    function ent:remove_notification(note)
        self.notifictions[note] = nil
    end


    function notifiction:draw()
        for k, v in pairs(self.ent.notifictions) do
            love.graphics.draw(v.note, self.ent.visual_pos.x + (self.ent.world.tilesize/3), self.ent.visual_pos.y - self.ent.world.tilesize)
        end
    end

    function notifiction:update()
        ent.notifictions = notifiction.notifictions

        for k, v in pairs(self.ent.notifictions) do
            if v.timer ~= 0 and v.timer:tick() then
                v = nil
                table.remove(v)
            end
        end
    end

    return setmetatable(notifiction, meta)
end

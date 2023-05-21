world_effects = {}

function world_effects.power_off(time, fxlis, index)
    if stack.UI ~= nil and stack.UI.elements[fxlis] ~= nil then
        local fxlis = stack.UI.elements[fxlis]
        if fxlis.active[index] == nil then
            fxlis:add_effect(time, UI_icons, 40, index)
        end
    end
end

function world_effects.safe_zone(fxlis, index)
    if stack.world ~= nil and stack.UI ~= nil then
        local world = stack.world
        local fxlis = stack.UI.elements[fxlis]
        if fxlis == nil then return end

        local current_index = fxlis.active[index]
        local effect = fxlis.effects[current_index]

        local midx = math.floor(world.chunk_size/2)
        local midy = math.floor(world.chunk_size/2)

        local sides = {
            vec2(world.focus_ent.chunk_pos.x * world.chunk_size + midx, world.focus_ent.chunk_pos.y * world.chunk_size),
            vec2(world.focus_ent.chunk_pos.x * world.chunk_size, world.focus_ent.chunk_pos.y * world.chunk_size + midy),
            vec2(world.focus_ent.chunk_pos.x * world.chunk_size + (2*midx), world.focus_ent.chunk_pos.y * world.chunk_size + midy),
            vec2(world.focus_ent.chunk_pos.x * world.chunk_size + (midx), world.focus_ent.chunk_pos.y * world.chunk_size + (2*midy)),
        }

        local tile_pos = vec2(world.focus_ent.pos.x/world.tilesize, world.focus_ent.pos.y/world.tilesize)
        local safe = false

        for i = 1,#sides do
            if tile_pos.x == sides[i].x and tile_pos.y == sides[i].y or 
                world.focus_ent.chunk_pos.x == 1 and world.focus_ent.chunk_pos.y == 1 then
                safe = true
                if stack.UI ~= nil and fxlis ~= nil then
                    if current_index == nil and effect == nil then
                        fxlis:add_effect(0.08, UI_icons, 28, index, true)
                    end
                end
            end
        end

        if safe == false and effect ~= nil then
            effect.no_tick = false
        elseif effect ~= nil then
            effect.timer.current_tick = 2*effect.timer.time
            effect.no_tick = true
        end
    end
end

function world_effects.active(time, fxlis, index, quad)
    if stack.UI ~= nil and stack.UI.elements[fxlis] ~= nil then
        local fxlis = stack.UI.elements[fxlis]
        local current_index = fxlis.active
        local effect = fxlis.effects[current_index]

        if effect == nil then
            fxlis:add_effect(time, UI_icons, quad, index)
        else
            effect.time = time
            effect.current_tick = 0
        end
    end
end

-- abilities
function world_effects.ability(time, fxlis, index, quad)
    local quad = quad or 1

    if stack.UI ~= nil and stack.UI.elements[fxlis] ~= nil then
        local fxlis = stack.UI.elements[fxlis]
        local current_index = fxlis.active[index]
        local effect = fxlis.effects[current_index]

        if effect == nil then
            fxlis:add_effect(time, UI_icons, quad, index, false, false)
            current_index = fxlis.active[index]
            effect = fxlis.effects[current_index]
        else
            effect.timer.time = time
            effect.timer.current_tick = time
        end

        return effect
    end

    return nil
end
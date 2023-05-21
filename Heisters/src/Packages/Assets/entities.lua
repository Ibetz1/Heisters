function wall(world, x, y)
    local wall = new_ent(x*world.tilesize, y*world.tilesize)
    wall.solid = true
    wall.name = 'wall'
    wall.mask = {1,1,1,1}

    world:add_ent(wall)
    return wall
end

function player(world, x, y)
    local player = new_ent(x*world.tilesize, y*world.tilesize, 'dynamic')

    player.shadow_oy = -2

    player.solid = true
    player.do_hop = true
    player.name = 'player'
    player.flip_shadow = true

    local controller = new_controller(player)
    local check_seen = apply_check_seen(player, 250)
    local notificator = apply_notificiations(player)
    local light = apply_light(player, 150, {0.6, 0.6, 0.6}, nil, nil, 0)
    light.spread = 3
    local anim = new_character_animation(player, character_anims, player_data.skin)
    local cam = new_cam_comp(player)

    local view_comp = view_caster(world, player)


    local ability1 = dash_ability(player, 1)
    local ability2 = heal_ability(player, 2)
    local ability3 = invisible_ability(player, 3)

    player:add_component(controller)
    player:add_component(check_seen)
    player:add_component(notificator)
    player:add_component(light)
    player:add_component(anim)
    player:add_component(cam)

    -- player:add_component(view_comp)

    player:add_component(ability1)
    player:add_component(ability2)
    player:add_component(ability3)

    world:add_ent(player, true)

    return player
end

function enemy(world, x, y)
    local enemy = new_ent(x*world.tilesize, y*world.tilesize, 'dynamic')

    enemy.solid = true
    enemy.do_hop = true
    enemy.name = 'enemy'
    enemy.flip_shadow = true
    enemy.shadow_oy = -2

    local view_comp = view_caster(world, enemy)
    local path_finder = path_finder(enemy)
    local arrow = apply_facing_arrow(enemy)
    local anim = new_character_animation(enemy, character_anims, 17)

    enemy:add_component(view_comp)
    enemy:add_component(path_finder)
    enemy:add_component(arrow)
    enemy:add_component(anim)

    world:add_ent(enemy)
    return enemy
end

function spinning_camera(world, x, y, rail_dir)
    local rail_dir = rail_dir or 'x'
    local camera = new_ent(x*world.tilesize, y*world.tilesize, 'dynamic')

    camera.solid = true
    camera.name = 'camera'
    camera.shadow_oy = -1.5
    camera.shadow_sx = -1
    camera.shadow_ox = world.tilesize

    local start_tick = 1
    local end_tick = 12

    local cam_comp = spinning_camera_comp(camera, rail_dir)
    if cam_comp.do_rail == 2 then
        start_tick = 13
        end_tick = 24
    end

    local arrow = apply_facing_arrow(camera)
    local anim = new_animation(camera, spinning_camera_anim, start_tick, end_tick, 2)

    camera:add_component(cam_comp)
    camera:add_component(arrow)
    camera:add_component(anim)

    camera:set_image(spinning_camera_anim, spinning_camera_anim[1], nil, 1)

    world:add_ent(camera)
    return camera
end

function laser(world, x, y, facing, instakill)
    local laser = new_ent(x*world.tilesize, y*world.tilesize, 'dynamic')

    laser.solid = true
    laser.do_hop = false
    laser.name = 'laser'
    laser.shadow_oy = -3

    local dx
    local dy

    if facing == 1 then
        dx = 0
        dy = -1
    elseif facing == 2 then
        dx = 1
        dy = 0
    elseif facing == 3 then
        dx = 0
        dy = 1
    elseif facing == 4 then
        dx = -1
        dy = 0
    end

    local laser_comp = new_laser(laser, dx, dy, instakill)
    local anim = new_animation(laser, laser_anim, facing, facing, 1)

    laser:add_component(anim)
    laser:add_component(laser_comp)

    laser:set_image(laser_anim, laser_anim[facing], nil, facing)

    world:add_ent(laser)
    return laser
end

function crate(world, x, y, set, quad, shadow_ox, shadow_oy)
    local set = set or sheet
    local quad = quad or 12

    local crate = new_ent(x*world.tilesize, y*world.tilesize, 'static')

    local shadow_ox = shadow_ox or 0
    local shadow_oy = shadow_oy or 0

    crate.shadow_ox = shadow_ox or 0 
    crate.shadow_oy = shadow_oy or 0

    crate.solid = true
    crate.name = 'crate'
    crate.mask = {1,1,1,1}

    crate:set_image(set, set[quad], nil, quad)
    world:add_ent(crate)
    return crate
end

function safe(world, x, y, quad, index)
    local safe = new_ent(x*world.tilesize, y*world.tilesize, 'dynamic')
    local quad = quad or 1

    safe.solid = true
    safe.name = 'safe'
    safe.mask = {1,1,1,1}
    safe.rarity = quad
    safe.shadow_oy = -2

    local color 
    local stats = new_text_element(safe.pos.x, safe.pos.y, 50, 50, {0.3, 0.3, 0.45, 0.8})
    local puzzle_UI = function() return new_vault_puzzle(res[1]/2, res[2]/2, index) end

    local end_params = function()
        if stack.UI ~= nil and stack.UI.elements['safe_counter'] ~= nil then
            local px, py = safe.world:world_to_screen_coords(safe)
            stack.UI.elements['safe_counter']:add_safe(safe.rarity, 1, px, py)
            safe:kill()
        end
    end

    local dif = {'Basic Safe', {0.7, 0.7, 0.7}}
    local index = {index, { 0 , 1 ,0 }}

    if index[1] >= 5 and index[1] < 9 then
        index[2] = {1, 1, 0}
    elseif index[1] >= 9 then
        index[2] = {1, 0, 0}
    end


    if safe.rarity == 1 then
        color = {1, 1, 1}
    elseif safe.rarity == 2 then
        color = {0, 0.5, 1}
        dif = {'Rare Safe', {0, 0.7, 1}}
    elseif safe.rarity == 3 then
        color = {1, 0, 1}
        dif = {'Myhtic Safe', {0.8, 0, 0.9}}
    elseif safe.rarity == 4 then
        color = {1, 1, 0}
        dif = {'Golden Safe', {0.8, 0.8, 0}}
    end
    
    index = {index[1] .. ' Pieces', index[2]}

    stats:addlines(dif, index)

    local lock = new_puzzle_lock(safe, puzzle_UI, stats, end_params)
    local light = apply_light(safe, 100, color, 20, 0.5)

    light.spread = 3
    light.quadratic = 0.09
    light.constant = 0.5

    safe:add_component(lock)
    safe:add_component(light)

    safe:set_image(safes, safes[quad], nil, quad)

    world:add_ent(safe)
    return safe
end

function power_panel(world, x, y, num_wires)
    local num_wires = num_wires or math.random(2, 7)
    local panel = new_ent(x*world.tilesize, y*world.tilesize, 'static')

    
    local stats = new_text_element(panel.pos.x, panel.pos.y, 50, 50, {0.3, 0.3, 0.45, 0.8})
    local dif = {'Power Panel', {0.7, 0.7, 0.7}}
    local index = {num_wires .. ' Wires', { 0 , 1 ,0 }}

    stats:addlines(dif, index)

    local puzzle = function() return new_power_puzzle(nil, res[1]/2, res[2]/2, nil, nil, num_wires) end
    local end_params = function()
        panel.light.show_light = world.settings.tick_bools['power'].finished      
        if stack.world.settings.tick_bools['power'].finished == true and panel.locked == false then
            stack.world:power_off('power', 60)
            panel.locked = true
        elseif stack.world.settings.tick_bools['power'].finished == true and panel.locked == true then
            panel.locked = false
            if panel.current_puzzle ~= nil then
                panel.current_puzzle.finished = false
            end
        end
    end

    local lock = new_puzzle_lock(panel, puzzle, stats, end_params)
    lock.icon = 8

    local light = apply_light(panel, 100, {1, 0.8, 0, 1}, 80, 2)
    local anim = new_animation(panel, power_panel_anim, 1, 5, 8)

    panel:add_component(lock)
    panel:add_component(light)
    panel.light = panel.components[2]
    panel:add_component(anim)

    panel:set_image(power_panel_anim, power_panel_anim[2], nil, 2)

    panel.solid = true
    panel.name = 'safe'
    panel.mask = {1,1,1,1}

    world:add_ent(panel)
    return panel
end
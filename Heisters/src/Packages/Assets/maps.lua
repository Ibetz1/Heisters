local function add_safes(room, rarity, r1, r2, r3, r4)
    local r1 = r1 or 1.00
    local r2 = r2 or 0.25
    local r3 = r3 or 0.15
    local r4 = r4 or 0.05

    if math.random(1, rarity) == rarity then
        local rarity = 1
        local index = math.random(2, 5)
        local pct = math.random(1, 100)/100

        if pct < r4 then
            rarity = 4
            index = 12
        elseif pct < r3 then
            rarity = 3
            index = math.random(10, 12)
        elseif pct < r2 then
            rarity = 2
            index = math.random(6, 10)
        elseif pct < r1 then
            rarity = 1
            index = math.random(2, 5)
        end


        room:add_safe(rarity, index, false)
    end
end

function base_map(world, mini_map)
    -- math.randomseed(os.time())

    local path = rand_path(world, 1, 1, #world.chunks - 1, #world.chunks - 1, 3, 'rand_walker')
    local rooms = {}

    local has_computer_room = false

    for i = 1,#path.final_path do
        local room = make_new_room(world, path.final_path[i])
        local theme = tilesets[math.random(4, #tilesets)]

        local do_enemy = true
        local camera_room = math.random(1,2)
        local safe_rarity = 1
        local laser = math.random(1, 2)
        local do_power_panel = false
        local laser_block = false
        local gold_safe = false

        if math.random(1, 4) == 4 then camera_room = 3 end

        if camera_room == 3 then do_enemy = false end

        if i == 1 then
            theme = tilesets[1]
            do_enemy = false
            laser = 2
            camera_room = 1
        end

        if i == #path.final_path then
            theme = tilesets[2]
            laser = 2
            camera_room = 2
            do_enemy = false
            laser_block = true
            gold_safe = true
        end

        if i > #path.final_path/2 and has_computer_room == false then
            theme = tilesets[3]
            has_computer_room = true
            do_power_panel = true
            do_enemy = false
        end

        room.theme = theme
        
        room:add_to_world()
        room:add_doors()
        room:set_quads()

        if laser_block then
            room:laser_block()
        end

        if gold_safe == true then
            room:add_safe(4, 12, true)
        end

        room:fill(math.random(2, 3), do_enemy, camera_room, laser, do_power_panel)
        table.insert(rooms, room)

        if mini_map ~= nil then
            mini_map:add_chunk(path.final_path[i].pos.x, path.final_path[i].pos.y)        
        end

        if i > 1 then
            add_safes(rooms[i], safe_rarity)
        end

    end

    player(world, rooms[1].pos.x + math.floor(world.chunk_size/2), rooms[1].pos.y + math.floor(world.chunk_size/2))
end

function map_from_card(card, world, mini_map)
    local max_panel = card.panel_level
    local do_laser = card.lasers
    local do_scanners = card.scanners
    local enemy = card.enemy
    local mega_lasers = card.mega_lasers
    local size = card.size
    local safe_rarity = 1
    local best_safe = card.best_safe

    local walk_types = {
        'rand_walker',
        'linear',
        'reverse_linear'
    }

    local path = rand_path(world, 1, 1, #world.chunks - 1, #world.chunks - 1, size, walk_types[math.random(1, #walk_types)])
    local rooms = {}

    local has_computer_room = false

    for i = 1,#path.final_path do
        local room = make_new_room(world, path.final_path[i])
        local theme = tilesets[math.random(4, #tilesets)]
        local do_enemy = enemy
        local scanners = 1
        local laser = 2
        local laser_block = false
        local vault_room = false
        local do_power_panel = false

        if do_laser then
            laser = math.random(1, 2)
        end

        if do_scanners == true then
            scanners = math.random(1, 2)
            if math.random(1, 4) == 4 then scanners = 3 end
        end

        if i == 1 then
            theme = tilesets[1]
            do_enemy = false
            laser = 2
            scanners = 1
            -- room:laser_block()
        end

        if i == #path.final_path then
            theme = tilesets[2]
            laser = 2

            if do_scanners == true then
                scanners = 2
            end
            
            do_enemy = false

            if do_laser == true then
                laser_block = true
            end

            vault_room = true
        end

        if i > #path.final_path/2 and has_computer_room == false then
            theme = tilesets[3]
            has_computer_room = true
            do_power_panel = true
            do_enemy = false
        end

        room.theme = theme

        -- pre generation
        room:get_walls()
        room:apply_chunk_data()

        -- post generation
        room:set_quads()

        if laser_block == true and has_computer_room == true then
            room:laser_block()
        end

        if vault_room == true then
            local rarity = best_safe - 1
            if rarity < 1 then
                rarity = 1
            end

            room:add_safe(rarity, 12, true)
        end

        room:fill(math.random(2, 3), do_enemy, scanners, laser, do_power_panel, card.panel_level)
        table.insert(rooms, room)

        if mini_map ~= nil then
            mini_map:add_chunk(path.final_path[i].pos.x, path.final_path[i].pos.y)        
        end

        if i > 1 then
            add_safes(rooms[i], safe_rarity, unpack(card.safe_rarities))
        end
    end

    player(world, rooms[1].pos.x + math.floor(world.chunk_size/2), rooms[1].pos.y + math.floor(world.chunk_size/2))

end

maps = {
    tiny = {
        name = 'Bank',
        size = 3,
        panel_level = 2,
        difficulty = 'Easy',
        int_diff = 1,
        lasers = false,
        scanners = false,
        enemy = true,
        mega_lasers = false,
        best_safe = 2,
        safe_rarities = {
            1,
            0.05,
            0.00,
            0.00
        }
    },

    small = {
        name  = 'Vault',
        size = 5,
        panel_level = 3,
        difficulty = 'Medium',
        int_diff = 2,
        lasers = false,
        scanners = true,
        enemy = true,
        mega_lasers = false,
        best_safe = 3,
        safe_rarities = {
            1,
            0.4,
            0.1,
            0.00
        }
    },

    medium = {
        name = 'Mega Vault',
        size = 6,
        panel_level = 5,
        difficulty = 'Normal',
        int_diff = 3,
        lasers = false,
        scanners = true,
        enemy = true,
        mega_lasers = false,
        best_safe = 3,
        safe_rarities = {
            1,
            0.4,
            0.2,
            0.00
        }
    },

    large = {
        name = 'Bunker',
        size = 7,
        panel_level = 7,
        difficulty = 'Hard',
        int_diff = 4,
        lasers = true,
        scanners = true,
        enemy = true,
        mega_lasers = false,
        best_safe = 4,
        safe_rarities = {
            1,
            0.7,
            0.3,
            0.1
        }
    },


    extreme = {
        name = 'Treasury',
        size = 7,
        panel_level = 7,
        difficulty = 'Extreme',
        int_diff = 5,
        lasers = true,
        scanners = true,
        enemy = true,
        mega_lasers = true,
        best_safe = 4,
        safe_rarities = {
            1,
            0.7,
            0.4,
            0.4
        }
    },
}


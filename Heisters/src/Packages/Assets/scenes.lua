function game_scene(stack, map)
    clear_audio_que()
    stack:clear()
    stack.paused = false
    stack.current_scene_file = nil

    local map = map or maps.tiny
    
    function love.keyreleased(key)
        full_screen(key)
        pause(key)
        no_zoom(key)
        show_console(key)
    end

    local world = new_world(16)
    stack.UI = new_UI()

    local light_map = new_light_world(world)

    local x_origin = 16
    local y_origin = 16
    local y_offset = 5
    local alignment = 'left'

    -- minimap hud
    local mini_map = minimap(world, x_origin, y_origin, 2)
    mini_map:align(alignment)
    stack.UI:add_element(mini_map, 'mini_map')

    local safe_counter = new_safe_counter(world, res[1] - x_origin, res[2] - y_offset - (3 * 16 * pix_scale) - y_origin)
    safe_counter:align('right')
    stack.UI:add_element(safe_counter, 'safe_counter')

    -- world effect menu
    local world_cooldowns = active_effects_menu(res[1] - x_origin, y_origin)
    world_cooldowns:align('right')
    stack.UI:add_element(world_cooldowns, 'world_cooldowns')

    -- ability effect menu
    local ability_cooldowns = bar_effects_menu(x_origin, 
                                                res[2] - (5 * 24 * pix_scale), pix_scale)
    -- local ability_cooldowns = active_effects_menu(x_origin + 26, res[2] - (7 * 24 * pix_scale))

    ability_cooldowns:align(alignment)
    stack.UI:add_element(ability_cooldowns, 'ability_cooldowns')

    -- generate map world
    map_from_card(map, world, mini_map)

    -- health bar hud
    local health_bar = new_bar(world.focus_ent, 
                        x_origin, 
                        res[2] - (2 * 24 * pix_scale), 1, 
                        'health', 'sudo_max_health')         
    health_bar:align(alignment)

    stack.UI:add_element(health_bar, 'health_bar')


    -- builds stack
    stack:build(world, stack.UI, light_map)
    stack.start = true
end

function title_screen(stack)
    store_data_files()

    clear_audio_que()
    stack:clear()


    local UI = load_menu('titlescreen', true)

    function love.keyreleased(key)
        show_console(key)
        full_screen(key)
    end

    stack.start = true
end

function pause_screen(stack)
    local scale = 5
    
    if stack.UI == nil then
        stack.UI = new_UI()
    end

    local UI = stack.UI

    local res = res
    if love.window.getFullscreen() then
        res = full_res
    end

    stack.paused = not stack.paused

    function love.keyreleased(key)
        full_screen(key)
        pause(key)
        no_zoom(key)
        show_console(key)
    end

    if stack.paused then
        for k,v in pairs(UI.elements) do
            v.hidden = true
        end
        local menu = load_menu('pausescreen', 'append')

        store_data_files(false)

        stack.cache.pause_menu = {elements = menu.elements, 
                                    images = menu.images}

    else
        if stack.cache.pause_menu ~= nil then
            for k,v in pairs(stack.cache.pause_menu.elements) do
                stack.UI:remove_element(k)
            end

            for k,v in pairs(stack.cache.pause_menu.images) do
                stack.UI:remove_image(k)
            end
        end

        for k,v in pairs(UI.elements) do
            v.hidden = false
        end
    end
end

function apply_puzzle(stack, puzzle_UI)
    local scale = 3

    if stack.UI == nil then
        stack.UI = new_UI()
    end
    
    local UI = stack.UI

    stack.puzzle = not stack.puzzle

    if stack.puzzle and puzzle_UI ~= nil then

        if stack.world ~= nil and stack.world.focus_ent ~= nil then
            stack.world.focus_ent.invisible = true
            stack.world.focus_ent.freeze = true
        end

        local puzzle_UI = puzzle_UI

        local close_button = icon_no(res[1]/2 + puzzle_UI.w/2 + 45, res[2]/2 - puzzle_UI.h/2, scale)
        close_button:set_function(apply_puzzle, stack)

        UI:add_element(puzzle_UI, 'puzzle')
        UI:add_element(close_button, 'close_button')

        return puzzle_UI
    else

        if stack.world ~= nil and stack.world.focus_ent ~= nil then
            stack.world.focus_ent.invisible = false
            stack.world.focus_ent.freeze = false
        end

        UI:remove_element('puzzle')
        UI:remove_element('close_button')

        return
    end

end

function death_screen(stack)
    local scale = 5
    
    if stack.UI == nil then
        stack.UI = new_UI()
    end

    local UI = stack.UI

    local res = res
    if love.window.getFullscreen() then
        res = full_res
    end

    stack.paused = not stack.paused

    
    function love.keyreleased(key)
        full_screen(key)
        no_zoom(key)
        show_console(key)
    end

    if stack.paused then
        store_data_files(false)
        
        for k,v in pairs(UI.elements) do
            v.hidden = true
        end
        local menu = load_menu('deathscreen', 'append')

        stack.cache.pause_menu = {elements = menu.elements, 
                                    images = menu.images}

    else
        if stack.cache.pause_menu ~= nil then
            for k,v in pairs(stack.cache.pause_menu.elements) do
                stack.UI:remove_element(k)
            end

            for k,v in pairs(stack.cache.pause_menu.images) do
                stack.UI:remove_image(k)
            end
        end

        for k,v in pairs(UI.elements) do
            v.hidden = false
        end
    end
end

function card_menu(stack)
    clear_audio_que()
    stack:clear()
    stack.UI = new_UI()

    function love.keyreleased(key)
        full_screen(key)
        show_console(key)
    end

    stack.UI:add_element(new_card_menu(res[1]/2, res[2]/2, 7, 5))
    stack.start = true
end

function mission_menu(stack)
    clear_audio_que()
    stack:clear()
    love.timer.sleep(1)
    stack.UI = new_UI()

    function love.keyreleased(key)
        full_screen(key)
        show_console(key)
    end

    stack.UI:add_element(new_level_select(res[1]/2, res[2]/2))
    stack.start = true
end

function loading_screen()
    love.graphics.clear()
    local scalex = 4*screen_ratio[1]
    local scaley = 4*screen_ratio[2]
    local px = current_res[1]/2 - (loading_screen_bg:getWidth()*scalex)/2
    local py = current_res[2]/2 - (loading_screen_bg:getHeight()*scaley)/2
    love.graphics.draw(loading_screen_bg, px, py, 0, scalex, scaley)
    love.graphics.present()
end
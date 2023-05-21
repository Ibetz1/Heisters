function load_menu(name, do_set)
    path = 'Assets/menus/' .. name
    local do_set = do_set or false

    
    function love.keyreleased(key) 
        full_screen(key)
    end

    local dat = love.filesystem.load(path .. '.lua')()
    local UI = new_UI()
    
    local bindings = {
        close = {love.window.close, {}},
        game = {game_scene, {stack}},
        pause = {pause_screen, {stack}},
        cardmenu = {card_menu, {stack}},
        titlescreen1 = {title_screen, {stack}},
        missionselect = {mission_menu, {stack}}
    }

    local menus = love.filesystem.getDirectoryItems('Assets/menus')

    for k, v in pairs(menus) do
        local index = v:sub(1, -5)
        bindings[index] = {load_menu, {index, true}}
    end
    
    UI.scale = dat.scale


    -- import elements

    for k, v in pairs(dat.assets) do
        local quad = v.image_index
        local sheet = dat.sheets[v.sheet_index]

        if v.type == 'button' then
            local button = new_button(v.pos.x, v.pos.y, v.w, v.h, v.ox, v.oy, 
                                        sheet, quad, quad + 1, quad + 2, 
                                        v.scale)
            if v.binding ~= nil and bindings[v.binding] ~= nil then
                button:set_function(bindings[v.binding][1], unpack(bindings[v.binding][2]))
            end

            UI:add_element(button)
        elseif v.type == 'image' then
            UI:add_image(sheet.sheet, sheet[v.image_index], v.pos.x, v.pos.y, v.scale)
        end
    end

    if do_set == true then
        clear_audio_que()
        stack:clear()

        if dat.music ~= nil and music[dat.music] ~= nil then
            love.audio.play(music[dat.music])
        end

        stack.current_scene_file = name
        stack:build(nil, UI)
    elseif do_set == 'append' then
        for k, v in pairs(UI.elements) do
            stack.UI.elements[k] = v
        end

        for k, v in pairs(UI.images) do
            stack.UI.images[k] = v
        end

    end

    return UI
end


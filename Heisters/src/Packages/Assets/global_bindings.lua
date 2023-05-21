function full_screen(key)
    if key == 'f11' and stack.console == nil then


        love.window.setFullscreen(not love.window.getFullscreen())

        full_res = {love.graphics.getWidth(), love.graphics.getHeight()}

        if love.window.getFullscreen() then
            current_res = full_res
        else
            current_res = res
        end

        screen_ratio = {full_res[1]/res[1], full_res[2]/res[2]}
    end
end

function pause(key)
    if key == 'escape' and stack.console == nil then
        pause_screen(stack)
    end
end

function no_zoom(key)
    if stack.console == nil then
        if key == 'n' then
            if stack.world ~= nil then stack.world.no_zoom = not stack.world.no_zoom end
        end

        if key == 'b' then
            if stack.world ~= nil then stack.world.show_colliders = not stack.world.show_colliders end
        end

        if key == 'p' then
            if stack.world ~= nil then
                -- stack.world:power_off('power', 5)
                apply_puzzle(stack, new_power_puzzle(nil, res[1]/2, res[2]/2,
                nil, nil, 7))
            end
        end
    end
end

function show_console(key)
    if key == 'return' or key == '/' or key == '`' then
        if stack.console == nil then
            stack:open_console()
        end
    end
end

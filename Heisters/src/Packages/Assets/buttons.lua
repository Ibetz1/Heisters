function text_character(x, y, scale)
    local scale = scale or 0
    local button = new_button(x, y, nil, nil, nil, nil, large_buttons, 1, 2, 3, scale)

    return button
end

function text_play(x, y, scale)
    local scale = scale or 0
    local button = new_button(x, y, 42*scale, 20*scale, 9, nil, large_buttons, 4, 5, 6, scale)

    return button
end

function text_resume(x, y, scale)
    local scale = scale or 0
    local button = new_button(x, y, 59*scale, 20*scale, 5, nil, large_buttons, 7, 8, 9, scale)

    return button
end

function text_options(x, y, scale)
    local scale = scale or 0
    local button = new_button(x, y, 69*scale, 20*scale, 5, nil, large_buttons, 10, 11, 12, scale)

    return button
end

function text_quit(x, y, scale)
    local scale = scale or 0
    local button = new_button(x, y, 47*scale, 20*scale, 8, nil, large_buttons, 13, 14, 15, scale)

    return button
end

function icon_yes(x, y, scale)
    local scale = scale or 0
    local button = new_button(x, y, 20*scale, 20*scale, nil, nil, small_buttons, 1, 2, 3, scale)

    return button
end

function icon_no(x, y, scale)
    local scale = scale or 0
    local button = new_button(x, y, 20*scale, 20*scale, 1, nil, small_buttons, 4, 5, 6, scale)

    return button
end

function icon_pause(x, y, scale)
    local scale = scale or 0
    local button = new_button(x, y, 20*scale, 20*scale, 1, nil, small_buttons, 7, 8, 9, scale)

    return button
end

function icon_plus(x, y, scale)
    local scale = scale or 0
    local button = new_button(x, y, 20*scale, 20*scale, 1, nil, small_buttons, 10, 11, 12, scale)

    return button
end

function icon_minus(x, y, scale)
    local scale = scale or 0
    local button = new_button(x, y, 20*scale, 20*scale, 1, nil, small_buttons, 13, 14, 15, scale)

    return button
end
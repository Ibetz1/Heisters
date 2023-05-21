function store_key()
    write_file(back_path() .. '/Data/key.lua', genkey())
end

function get_key()
    if not file_exists(back_path() .. '/Data/key.lua') then
        store_key()
    end

    return get_file_line(back_path() .. '/Data/key.lua', 1)
end

-- imports all data files
function import_data_files(show_loading_screen) 
    if show_loading_screen == nil then show_loading_screen = true end

    if show_loading_screen then
        loading_screen()
    end
    local path = back_path() .. '/Data/'

    -- imports controls
    local controls = path .. 'controls.lua'

    if not file_exists(controls) then
        store_data_files()
        return
    end

    stack.controls = decrypt_table(persistence.load(controls), get_key())

    -- imports player data
    local player_dat = path .. 'playerdat.lua'

    if not file_exists(player_dat) then
        store_data_files()
        return
    end

    player_data = decrypt_table(persistence.load(player_dat), get_key())
end

-- stores data files
function store_data_files(show_loading_screen)
    if show_loading_screen == nil then show_loading_screen = true end

    if show_loading_screen == true then
        loading_screen()
    end
    store_key()

    local path = back_path() .. '/Data/'

    -- stores controls
    local controls = path .. 'controls.lua'

    persistence.store(controls, encrypt_table(stack.controls, get_key()).data)

    -- stores playerdata
    local player_dat = path .. 'playerdat.lua'

    persistence.store(player_dat, encrypt_table(player_data, get_key()).data)
end
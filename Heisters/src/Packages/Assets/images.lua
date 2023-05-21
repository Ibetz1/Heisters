bad_zone = read('Assets/images/bad_zone.png', 16, 16, 12, 0, 0, 64)

love.graphics.setDefaultFilter("nearest", "nearest")

-- In game
tilesets = {
    {read('Assets/images/rooms/Lobby.png', 16, 16, 24, 0, 0, 48), 0, 0},
    {read('Assets/images/rooms/Vault_Room.png', 16, 16, 24, 0, 0, 48)},
    {read('Assets/images/rooms/Computer_Room.png', 16, 16, 24, 0, 0, 48)},
    {read('Assets/images/rooms/Storage_Room.png', 16, 16, 24, 0, 0, 48)},
    {read('Assets/images/rooms/Garbage_Room.png', 16, 16, 24, 0, 0, 48), 0, -1, 0, -1},
    {read('Assets/images/rooms/Electronics_Room.png', 16, 16, 24, 0, 0, 48)},
    {read('Assets/images/rooms/Wood_Room.png', 16, 16, 24, 0, 0, 48), 0, -1.2, 0, -1.2},
}

back_ground = love.graphics.newImage('Assets/images/rooms/back_ground.png')
concept1 = love.graphics.newImage('Assets/images/Art/concept1.png')

spinning_camera_anim = read('Assets/images/Animations/spinning_camera.png', 16, 16, 48, 0, 0, 192)
laser_anim = read('Assets/images/Animations/laser.png', 16, 16, 5, 0, 0, 80)
power_panel_anim = read('Assets/images/Animations/power_panel.png', 16, 16, 6, 0, 0, 96)

character_anims = read('Assets/images/Animations/Characters.png', 16, 16, 336, 0, 0, 256)

safes = read('Assets/images/rooms/safes.png', 16, 16, 4, 0, 0, 64)

vault_puzzle_center = read('Assets/images/Puzzles/Vault_puzzle_center.png', 80, 80, 3, 0, 0, 240)
vault_puzzle_peices = read('Assets/images/Puzzles/Vault_puzzle_peices.png', 16, 16, 9, 0, 0, 48)

power_puzzle_peices = read('Assets/images/Puzzles/Power_puzzle_peices.png', 16, 16, 10, 0, 0, 96)
power_puzzle_bg = read('Assets/images/Puzzles/Power_puzzle_bg.png', 16, 16, 9, 0, 0, 48)

-- UI
large_buttons = read('Assets/images/UI/large_buttons.png', 79, 20, 15, 0, 0, 237)
small_buttons = read('Assets/images/UI/small_buttons.png', 21, 20, 15, 0, 0, 63)
mini_map_sheet = read('Assets/images/UI/minimap.png', 16, 16, 6, 0, 0, 48)
cards = read('Assets/images/UI/cards.png', 42, 56, 4, 0, 0, 168)
character_cards = read('Assets/images/UI/Character_cards.png', 16, 16, 91, 0, 0, 208)
menu_bg = read('Assets/images/UI/card_menu.png', 16, 16, 9, 0, 0, 48)
safe_door = read('Assets/images/UI/safe_door.png', 128, 128, 1, 0, 0, 128)
UI_icons = read('Assets/images/UI/UI_icons.png', 16, 16, 88, 0, 0, 175)
bar_sheet = read('Assets/images/UI/bar_sheet.png', 24, 24, 4, 0, 0, 96)
bar_colors = read('Assets/images/UI/bar_colors.png', 24, 24, 8, 0, 0, 96)
loading_screen_bg = love.graphics.newImage('Assets/images/UI/loading_screen.png')
level_select_cards = read('Assets/images/UI/level_cards.png', 48, 64, 5, 0, 0, 240)

circle_cooldown = read('Assets/images/UI/circle_cooldown.png', 32, 32, 2, 0, 0, 64)

logo = love.graphics.newImage('Assets/images/logo.png')
minilogo = love.graphics.newImage('Assets/images/minilogo.png')
love.window.setIcon(love.image.newImageData('Assets/images/minilogo.png'))


in_game_icons = read('Assets/images/UI/in_game_icons.png', 16, 16, 9, 0, 0, 48)
particles = read('Assets/images/particles.png', 8, 8, 2, 0, 0, 32)

font = love.graphics.newFont("Assets/images/DisposableDroidBB.ttf", 72)
love.graphics.setFont(font)


shaders = {
    darken = love.graphics.newShader('Assets/shaders/darken.frag'),
    shadow = love.graphics.newShader('Assets/shaders/shadow.frag'),
    reg_clip = love.graphics.newShader('Assets/shaders/reg_clip.frag'),
    inv_clip = love.graphics.newShader('Assets/shaders/inv_clip.frag'),
    outline = love.graphics.newShader('Assets/shaders/outline.frag'),
    laser = love.graphics.newShader('Assets/shaders/laser.frag'),
    glow = love.graphics.newShader('Assets/shaders/glow.frag'),
}


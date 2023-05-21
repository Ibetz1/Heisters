characters = {
    'a','b','c','d',
    'e','f','g','h',
    'i','j','k','l',
    'm','n','o','p',
    'q','r','s','t',
    'u','v','w','x',
    'y','z', ' ', '!',
    '#','$', '%','^',
    '&','*', '(',')',
    '[', '{', ']', '}',
    "'", '"', ';', ":",
    ',', '<','.', '>',
    '/', '?','`', '~',
    '-', '_','=', '+',
    '@'
}

for i = 1, 26 do
    table.insert(characters, string.upper(characters[i]))
end

for i = 0,9 do
    table.insert(characters, i)
end

function load_state()
    import_data_files()
end

function save_state()
    store_data_files()
end

color_pallette = {
    {116, 139, 150},
    {92, 111, 120},
    {63, 76, 82},
    {47, 57, 61},
    {31, 38, 41},
    {21, 26, 28},
    {20, 22, 23}
}

for i = 1,#color_pallette do
    for c = 1,#color_pallette[i] do
        color_pallette[i][c] = color_pallette[i][c]/255
    end
    color_pallette[i][4] = 1
end

stored_data = {}

pix_scale = 2
t_size = 16
shader_scale = 2.6
minimap_scale = 0.4

res = {love.graphics:getWidth(), love.graphics:getHeight()}
full_res = res
current_res = res
screen_ratio = {full_res[1]/res[1], full_res[2]/res[2]}

bg_color = color_pallette[#color_pallette - 1]
otype = type
function type(obj)
    if otype(obj) == 'table' and getmetatable(obj) ~= nil then
        if getmetatable(obj).type ~= nil then return getmetatable(obj).type end
    end

    return otype(obj)
end

oabs = math.abs
function math.abs(v)
    if type(v) == 'vec2' then return vec2(oabs(v.x), oabs(v.y)) end
    return oabs(v)
end

otremove = table.remove
function table.remove(t, k)
    if type(k) == 'string' then t[k] = nil; return end
    otremove(t, k); return
end

function getAngleRad(x1, y1, x2, y2)
    return math.atan2(y2 - y1, x2 - x1)
end

function GID(l1, l2)
    local l1 = l1 or 4
    local l2 = l2 or 4
    
    local id = ""

    for i = 1, l1 do
        for i = 1, l2 do
            id = id .. math.random(1,9)
        end
        
        if i < l1 then
            id = id .. '-'
        end
    end

    return id   
end

function round(num, dec)
    local mult = 10^(dec or 0)
    return math.floor(num * mult + 0.5) / mult
end

function new_timer(len, dobreak)
    local timer = {
        len = len or 100,
        ctick = 0,
        timer_break = false,
        dobreak = dobreak or false,
        pct = 1
    }

    local meta = {
        type = 'timer'
    }

    function timer:tick()
        if self.ctick < self.len then 
            self.ctick = self.ctick + 1
        elseif self.dobreak == false then
            self.ctick = 0
        end

        self.pct = self.ctick/self.len

        return self.ctick >= self.len
    end


    return setmetatable(timer, meta)
end

function new_real_timer(time, dir)
    local timer = {
        string = '',
        time = time,
        current_tick = 0,
        dir = dir,
        finished = false
    }

    local meta = {
        type = 'real_timer'
    }

    if dir < 1 then timer.current_tick = time end

    function timer:tick()
        self.current_tick = self.current_tick + (love.timer:getDelta() * self.dir)

        if self.current_tick < 0 then
            self.finished = true
            self.current_tick = 0
        end

        local min = math.floor(self.current_tick/60)
        if min < 1 then min = 0 end

        local sec = math.floor(self.current_tick - (min * 60))

        if min < 10 then 
            min = '0' .. min
        end

        if sec < 10 then 
            sec = '0' ..  sec
        end

        self.string = min .. ':' .. sec
    end

    return setmetatable(timer, meta)
end

function vec2(x, y)
    local meta = {
        type = 'vec2',

        __add = function(a, b)
            if type(b) == 'number' then
                return vec2(a.x+b, a.y+b)
            elseif type(b) == 'vec2' then
                return vec2(a.x+b.x, a.y+b.y)
            end
        end,

        __sub = function(a, b)
            if type(b) == 'number' then
                return vec2(a.x-b, a.y-b)
            elseif type(b) == 'vec2' then
                return vec2(a.x-b.x, a.y-b.y)
            end
        end,

        __mul = function(a, b)
            if type(b) == 'number' then
                return vec2(a.x*b, a.y*b)
            elseif type(b) == 'vec2' then
                return vec2(a.x*b.x, a.y*b.y)
            end
        end,

        __div = function(a, b)
            if type(b) == 'number' then
                return vec2(a.x/b, a.y/b)
            elseif type(b) == 'vec2' then
                return vec2(a.x/b.x, a.y/b.y)
            end
        end,
    }

    local vec = {
        x = x or 0,
        y = y or 0
    }

    function vec:clone()
        return vec2(self.x, self.y)
    end
    
    function vec:round(dec)
        self.x = round(self.x, dec) 
        self.y = round(self.y, dec)
    end

    function vec:get_dist(vec)
        if type(vec) == 'vec2' then
            local edges = self - vec

            return math.sqrt((edges.x * edges.x) + (edges.y * edges.y))
        end

        return nil
    end

    return setmetatable(vec, meta)
end

function array2D(w, h, data)
    local w = w or 1
    local h = h or 1
    local data = data or {}

    local array = {{}}
    local meta = {
        type = 'array'
    }

    for x = 0, w do
        array[x] = {}
        for y = 0, h do 
            array[x][y] = data
        end
    end

    function array:format()
        for x = 0, #self do
            for y = 0, #self[1] do
                self[x][y] = {}
            end
        end
    end

    return setmetatable(array, meta)
end

function append_function(old_func, new_func)
    return function()
        old_func()
        new_func()
    end
end

function check_even(num)
    return math.floor(num/2) ~= num/2
end

function kill_obj(obj)
    if otype(obj) == 'table' then
        for k,v in pairs(obj) do
            obj[k] = nil
        end
    end

    return {}
end

function reset_love()
    function love.mousereleased(key) end
    function love.mousepressed(key) end
    function love.mousemoved(key) end
    function love.mousefocus(key) end
    function love.keypressed(key) end
    function love.keyreleased(key) show_console(key) end
    function love.touchmoved(key) end
    function love.wheelmoved(key) end
    function love.quit(key) end
    function love.resize(key) end
end

function rect_collide(x1, y1, x2, y2, w1, h1, w2, h2)
    return x1 + w1 > x2 and
            x1 < x2 + w2 and
            y1 + h1 > y2 and
            y1 < y2 + h2
end

function shuffle(array)
    local output = { }
    local random = math.random
 
    for index = 1, #array do
        local offset = index - 1
        local value = array[index]
        local randomIndex = offset*random()
        local flooredIndex = randomIndex - randomIndex%1
 
        if flooredIndex == offset then
            output[#output + 1] = value
        else
            output[#output + 1] = output[flooredIndex + 1]
            output[flooredIndex + 1] = value
        end
    end
 
    return output
end

function table_to_string(data, name, do_local)
    local str_depth = '  '
    local real_name = name or 'table'
    local do_local = do_local or false

    if name == nil then
        name = 'table = { \n'
    else
        local begin = ''
        if do_local == true then
            begin = 'local '
        end

        name = begin .. name .. ' = { \n'
    end

    local str = name
    local externs = {}
    local functions = {}

    for k, v in pairs(data) do
        if otype(v) == 'table' then
            if type(v) == 'vec2' then
                str = str .. str_depth .. k .. ' = ' .. 'vec2(' .. v.x .. ', ' .. v.y .. ')' .. ',\n'
            elseif v.str_eval == true then
                if type(k) == 'number' then
                    k = ''
                else
                    k = k .. ' = '
                end

                str = str .. str_depth .. k .. v[1] .. ',\n'
            else
                local count = 0
                local num_count = 0

                for k, v in pairs(v) do
                    count = count + 1
                end

                if count > 0 then
                    if type(k) == 'number' then
                        k = '[' .. k .. ']'
                    else
                        k = '.' .. k
                    end    

                    table.insert(externs, {k, v, count})
                else
                    if type(k) == 'number' then
                        str = str .. str_depth .. '{},\n'
                    else
                        str = str .. str_depth .. k .. ' = {},\n'
                    end    

                end
            end
        elseif type(v) == 'function' then
            table.insert(functions, {k, v})
        elseif type(v) == 'boolean' then
            local bool  = 'true'

            if v == false then bool = 'false' end

            str = str .. str_depth .. k .. ' = ' .. bool .. ',\n'

        else
            if type(v) == 'string' then
                v = '"' .. v .. '"'
            end

            if type(k) == 'number' then
                k = ''
            else
                k = k .. ' = '
            end

            str = str .. str_depth .. k .. v .. ',\n'
        end
    end


    str = str .. '}'

    for i = 1,#externs do
        str = str .. '\n\n'

        str = str .. table_to_string(externs[i][2], real_name .. externs[i][1], false)
    end

    for i = 1,#functions do
        str = str .. '\n\n'
        str = str .. 'function ' .. real_name .. '.' .. functions[i][1] .. '(self) end' .. '\n'
    end

    if do_local then
        str = str .. '\n\nreturn ' .. real_name
    end

    return str
end

function back_path(dist)
    local dist = dist or 1

    local dir = love.filesystem.getWorkingDirectory()
    dir = dir:gsub(' ', '~')
    dir = dir:gsub('/', ' ')
    local split_dat = {}
    for str in dir:gmatch('%S+') do
        table.insert(split_dat, str .. '/')
    end

    local str = ''
    for i = 1,#split_dat - dist do
        str = str .. split_dat[i]
    end

    return str:gsub('~', ' ')
end

function split_str(text, chunkSize)
    local s = {}
    local chunkSize = chunkSize or 1

    for i= 1, #text, chunkSize do
        local v = text:sub(i, i + chunkSize - 1)
        for i = 0,9 do
            if v == '' .. i then v = i end
        end
        table.insert(s, v)
    end
    return s
end

function get_background_quad(x, y, tile_w, tile_h)
    if x == 0 and y == 0 then -- top left
        return 1
    elseif x == 0 and y == tile_h - 1 then -- bottom left
        return 7
    elseif x == tile_w - 1 and y == 0 then -- top right
        return 3
    elseif x == tile_w - 1 and y == tile_h - 1 then -- bottom right
        return 9
    elseif y == 0 then
        return 2
    elseif x == 0 then
        return 4
    elseif x == tile_w - 1 then
        return 6
    elseif y == tile_h - 1 then
        return 8
    else
        return 5
    end
end

function math.exponent(num, power)
    local inum = num

    for i = 1, power - 1 do
        num = inum * num
    end

    return num
end

function flip_table(t) 
    local nt = {}

    for i = #t, 1, -1 do
        table.insert(nt, t[i])
    end

    return nt
end

function iterate_chunk(x, y, cs, f, ...)
    local p = {...}

    for x = x * cs, (x * cs) + cs - 1 do
        for y = y * cs, (y * cs) + cs - 1 do
            f(x, y, unpack(p))
        end
    end
end

local mdown = false
function mouse_released(b)
    if love.mouse.isDown(b) and not mdown or
        not love.mouse.isDown(b) and mdown then
        mdown = not mdown
        return mdown == false
    end
end
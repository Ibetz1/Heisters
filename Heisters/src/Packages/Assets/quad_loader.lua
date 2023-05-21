function read(sheet, xd, yd, count, sx, sy, ed, dir, gap)
    if type(sheet) == 'string' then sheet = love.graphics.newImage(sheet) end
    local sx = sx or 0
    local sy = sy or 0
    local gap = gap or 0
    local dir = dir or 'x'
    local pos = vec2(sx, sy)
    local lib = {sheet=sheet, 
                    qw = xd, 
                    qh = yd, 
                    w = sheet:getWidth(),
                    h = sheet:getHeight(),
                    quad_stats = {}}

    local meta = {
        type = 'tileset'
    }

    for i = 1,count do
        lib[i] = love.graphics.newQuad(pos.x, pos.y, xd, yd, sheet:getDimensions())
        lib.quad_stats[i] = {x = pos.x, 
                            y = pos.y,
                            qw = xd,
                            qh = yd,
                            sw = lib.w,
                            sh = lib.h}
        if dir == 'x' then
            if pos.x + xd < ed then
                pos.x = pos.x + (xd + gap)
            else
                pos.y = pos.y + (yd + gap)
                pos.x = sx
            end
        else
            if pos.y + yd < ed then
                pos.y = pos.y + (yd + gap)
            else
                pos.x = pos.x + (xd + gap)
                pos.y = sy
            end
        end
    end

    return setmetatable(lib, meta)
end
local C_MEM = collectgarbage('count')
local TIMER = new_timer(20)
local MEM_DIR = 'none'
local LEAK_COUNTER = 0

function show_dev_stats(leak_sense)
    local resource_stats = love.graphics.getStats()

    local draw_cycles = resource_stats.drawcalls

    local tex_mem = resource_stats.texturememory

    local leak_sense = 2
    -- leak testing --
    ------------------
    if TIMER:tick() then
        if collectgarbage('count') > C_MEM then
            LEAK_COUNTER = LEAK_COUNTER + 1
            MEM_DIR = 'up'
        elseif collectgarbage('count') < C_MEM then
            LEAK_COUNTER = 0
            MEM_DIR = 'down'
        else
            MEM_DIR = 'none'
            LEAK_COUNTER = 0
        end
        C_MEM = collectgarbage('count')
    end
    LEAK = 'false'
    if LEAK_COUNTER > leak_sense then
        LEAK = 'true'
    end

    if MEM_DIR == 'up' then
        love.graphics.setColor(1, 0, 0)
    elseif MEM_DIR == 'down' then
        love.graphics.setColor(0, 1, 0)
    else
        love.graphics.setColor(1, 1, 1)
    end
    love.graphics.print(MEM_DIR, #'memeory change: '*7.1, 60)
    love.graphics.reset()

    -- dev stat display --
    ----------------------
    love.graphics.print('FPS: ' .. love.timer.getFPS())
    love.graphics.print('used memory (MB): ' .. round(collectgarbage('count')/(1000), 10), 0, 12)
    love.graphics.print('free memory (MB): ' .. 100 - round((collectgarbage('count')/(1000))/2000, 5) .. "%", 0, 24)
    love.graphics.print('potential leak: ' .. LEAK, 0, 36)
    love.graphics.print('leak counter: '.. LEAK_COUNTER, 0, 48)
    love.graphics.print('memeory change: ', 0, 60)
    love.graphics.print('draw cycles (per frame): ' .. draw_cycles, 0, 72)
    love.graphics.print('texture memory (MB): ' .. tex_mem, 0, 84)
end

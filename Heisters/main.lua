-- externs
flux = require('src/Root/Externs/flux_tweening');

-- interns
require('src/Root/package_importer');
import_project('src', 'core_functions', 'quad_loader', 'tile_matching');
import_project('tools');

math.randomseed(os.time())

-- love.window.setVSync(0)

-- scanners: FPS takes massive hit
-- enemy: FPS takes a decent hit

-- UI: FPS takes a massive hit

-- safe counter causes issues
-- world effects causes minor issues (maybe 1 - 2 fps)
-- abilities cause massive issues

function new_card(x, y, character, quad, scale, sheet)
    local scale = scale or 1
    local card = {
        id = GID(),
        opos = vec2(x, y),
        pos = vec2(x, y),
        vox = 0,
        voy = 0,
        scale = scale,
        w = cards.sheet:getWidth()*scale/#cards,
        h = cards.sheet:getHeight()*scale,
        character = character + 0,
        quad = quad,
        sheet = sheet or cards,
        content = nil,
        func = {function() end, {}},
        scaler = 0,
        gscaler = 0,
        focused = false,
        click_box = {
            x,
            y,
            x + cards.sheet:getWidth()*scale/#cards,
            y + cards.sheet:getHeight()*scale
        }
    }

    card.scalers = {
        hover = 0.8,
        focus = 1.4
    }

    local meta = {
        type = 'character_card'
    }


    function card:get_hover()
        local vox, voy = self:scale_to(self.gscaler)
        local x = self.pos.x + vox
        local y = self.pos.y + voy
        local w = cards.sheet:getWidth()*(self.scale + self.gscaler)/#cards
        local h = cards.sheet:getHeight()*(self.scale + self.gscaler)

        local mx, my = love.mouse.getPosition()

        return mx > x and mx < x + w - vox and
               my > y and my < y + h - voy

    end
    
    function card:set_content(sheet, quad, padx, pady)

    end

    function card:set_function(f, ...)
        self.func = {f or function() end, {...}}
    end

    function card:exec()
        self.func[1](unpack(self.func[2]))
    end

    function card:scale_to(offset)

        local scale = self.scale + offset
        local nw = cards.sheet:getWidth()*scale/#cards
        local nh = cards.sheet:getHeight()*scale

        return (self.w - nw)/2, (self.h - nh)/2
    end

    function card:tween(amount, div)
        local div = div or 8
        local dist = amount - self.scaler
        self.gscaler = self.scaler + dist
        self.scaler = self.scaler + dist/div
    end

    function card:update()
        self.vox, self.voy = self:scale_to(self.scaler)

        if self.focused then
            self:tween(self.scalers.focus)
        end

        local mx, my = love.mouse.getPosition()

        if self:get_hover() then
            
            if not self.focused then
                self:tween(self.scalers.hover)
            end

            if mouse_released(1) then
                if self.func ~= nil then
                    self.func[1](unpack(self.func[2]))
                end
                self.focused = not self.focused
            end

        else
            if not self.focused then
                self:tween(0)
            end
        end
    end

    function card:draw()
        love.graphics.draw(self.sheet.sheet, self.sheet[quad], 
                            self.pos.x + self.vox, 
                            self.pos.y + self.voy, 0, self.scale + self.scaler)
    end

    return setmetatable(card, meta)
end

function love.load()
    -- m = new_menu()
    -- m:align('center', 'xy')
    -- p = m:make_pallete()
    -- o = p:add_obj(100, 100)
    -- card = new_card(o.pos.x, o.pos.y, 1, 2, m.scale)
    -- card:set_function(o.focus, o)
    -- o:add_child(card)
    -- menu:sort()


    loading_screen()
    -- love.timer.sleep(5)

    stack = new_stack()

    import_data_files()

    title_screen(stack)
end

function love.update(dt)
    -- m:update()
    stack:update()
end

function love.draw()
    -- m:draw()
    stack:draw()

    love.graphics.reset()
    show_dev_stats(3)
    love.graphics.setBackgroundColor(bg_color, 1)
end
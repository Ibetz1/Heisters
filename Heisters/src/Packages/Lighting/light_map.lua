function new_light_world(ent_world, var)
    local var = var or 'shader'
    local world = {
        id = GID(),
        ent_world = ent_world,
        shader = shaders.darken,
        lights = {},
        num_lights = 0,
        darkness = 0,
        var = var
    }

    ent_world[var] = world.shader

    local meta = {
        type = 'light_map'
    }

    function world:mod_coord(x, y)
        local sx = self.ent_world.zoom*screen_ratio[1]
        local sy = self.ent_world.zoom*screen_ratio[2]

        local w = ((self.ent_world.chunk_size) * t_size) * sx
        local h = ((self.ent_world.chunk_size) * t_size) * sy
        local px = (w + self.ent_world.render_ox * sx + current_res[1]/2)
        local py = (h + self.ent_world.render_oy * sy + current_res[2]/2)
        px = px + (self.ent_world.focus_ent.chunk_pos.x * t_size * self.ent_world.chunk_size * sx)
        py = py + (self.ent_world.focus_ent.chunk_pos.y * t_size * self.ent_world.chunk_size * sy)
        px = px - (self.ent_world.chunk_size * t_size * sx)
        py = py - (self.ent_world.chunk_size * t_size * sy)

        return px + x, py + y
    end

    function world:convert_coords(ent, x, y)
        local scale = {ent.world.zoom*screen_ratio[1], ent.world.zoom*screen_ratio[2]}
        local x = ((x) - (ent.chunk_pos.x * t_size * ent.world.chunk_size)) * scale[1]
        local y = ((y) - (ent.chunk_pos.y * t_size * ent.world.chunk_size)) * scale[2]

        return vec2(x, y)
    end

    function world:add_light(x, y, diffuse, power, constant, linear, quadratic, spread)
        local quadratic = quadratic or 0.1
        local linear = linear or 0.09
        local constant = constant or 1
        local spread = spread or 2

        local px, py = self:mod_coord(x, y)

        if px < 0 or px > current_res[1] or py < 0 or py > current_res[2] then return end 

        self.shader:send('lights[' .. self.num_lights .. '].position', {px, py})

        self.shader:send('lights[' .. self.num_lights .. '].diffuse', diffuse)

        self.shader:send('lights[' .. self.num_lights .. '].power', power)

        self.shader:send('lights[' .. self.num_lights .. '].constant', constant)
        
        self.shader:send('lights[' .. self.num_lights .. '].linear', linear)

        self.shader:send('lights[' .. self.num_lights .. '].quadratic', quadratic)

        self.shader:send('lights[' .. self.num_lights .. '].spread', spread)

        self.num_lights = self.num_lights + 1

        self.shader:send('num_lights', self.num_lights)
    end

    function world:update()
        self.num_lights = 0

        local w = ((self.ent_world.chunk_size) * t_size) * self.ent_world.zoom * screen_ratio[1]
        local h = ((self.ent_world.chunk_size) * t_size) * self.ent_world.zoom * screen_ratio[2]

        self.shader:send('res', {w * shader_scale, h * shader_scale})
        self.shader:send('darkness', self.darkness)
        -- self.shader:send('res', {w * shader_scale, h * shader_scale})
        -- self.shader:send('darkness', self.darkness)

        -- self.lights = {}

        -- for i = 1,#self.lights do
        --     self.shader:send('lights[' .. i - 1 .. '].position', {px + self.lights[1].x, py + self.lights[1].y})

        --     self.shader:send('lights[' .. i - 1 .. '].diffuse', self.lights[1].diffuse)
    
        --     self.shader:send('lights[' .. i - 1 .. '].power', self.lights[1].power)

        --     self.shader:send('lights[' .. i - 1 .. '].constant', self.lights[1].constant)
            
        --     self.shader:send('lights[' .. i - 1 .. '].linear', self.lights[1].linear)

        --     self.shader:send('lights[' .. i - 1 .. '].quadratic', self.lights[1].quadratic)

        --     self.shader:send('lights[' .. i - 1 .. '].spread', self.lights[1].spread)

        --     table.remove(self.lights, 1)
        -- end
    end

    function world:draw()
    end

    return setmetatable(world, meta)
end
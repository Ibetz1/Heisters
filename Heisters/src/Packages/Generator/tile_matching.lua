function new_str_array()
    local array = {
        neg_val = '#',
        pos_val = '+',
        mid_val = '?',
        values = {},
        w = 3,
        h = 3,
        quad = 1
    }

    local meta = {
        type = 'string_array'
    }

    function array:format(w, h)
        local str = ''
        table.insert(self.values, {})

        for x = 1,self.w do
            str = str .. self.neg_val
        end
    
        for y = 1,self.h do
            self.values[#self.values][y] = str
        end
    end

    function array:set_shape(...)
        local s = {...}

        if #s == 0 then self:format() end

        for i = 1,#s do
            self.values[i] = s[i]
        end
    end

    function array:match(array1)
        if array1.h ~= self.h then return false end
            for i = 1,self.h do
                if self.values[i] ~= array1.values[i] then
                    return false
                end
            end

        return true
    end

    array:format()

    return setmetatable(array, meta)
end
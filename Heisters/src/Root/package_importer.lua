function get_tree(path)
    local paths = {}
    local get_items = love.filesystem.getDirectoryItems

    for k,v in pairs(get_items(path)) do
        if v:match('.lua') then
            table.insert(paths, path .. '/' .. v)
        else
            for k,v in pairs(get_tree(path .. '/' .. v)) do
                if v:match('.lua') then table.insert(paths, v) end
            end
        end
    end

    return paths
end


function import_project(path, ...)
    local package = {}
    local hierarchy = {...}

    for k,v in pairs(get_tree(path)) do
        for s in v:gmatch('[^/]+') do for i = 1,#hierarchy do 
            if s:gsub('.lua', '') == hierarchy[i] then
                table.insert(package, require(v:gsub('.lua', '')))
            end
        end
        end
    end

    for k,v in pairs(get_tree(path)) do
        for s in v:gmatch('[^/]+') do
            if v ~= 'package_importer.lua' then
                table.insert(package, require(v:gsub('.lua', '')))
            end
        end
    end

    return unpack(package)
end
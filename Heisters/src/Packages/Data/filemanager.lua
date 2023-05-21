function file_exists(file)
    local f = io.open(file, "rb")
    
    if f then 
        f:close() 
    end

    return f ~= nil
end

function write_file(rel_path, data)
    local file = io.open(rel_path, 'w')

    file:write(data)
    file:close()

    return data
end

function append_file(rel_path, data)
    local file = io.open(rel_path, 'a')

    io.output(file)

    io.write(data)

    file:close()

    return data
end

function get_file(file)
    if not file_exists(file) then return {} end

    local lines = {}

    for line in io.lines(file) do 
        lines[#lines + 1] = line
    end

    return lines
end

function get_file_line(file, line)
    if not file_exists(file) then return '' end

    local file = get_file(file)
    local line = line or 1

    if line > #file then line = #file end

    return file[line]
end
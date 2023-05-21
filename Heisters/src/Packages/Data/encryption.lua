function genkey()
    local seed = os.time() -- make seed for randomness

    math.randomseed(seed) -- set seed for randomness

    local len = characters[math.random(1, #characters - 10)] -- sets first character of len to letter

    local shift = math.random(5, 9) -- shifting for caeser chipher

    local key_len = math.random(20, 50) -- len of each character

    for i = 1, key_len do -- sets length to a string length
        len = len .. characters[math.random(1, #characters)]
    end

    return '' .. seed .. '' .. shift .. len
end

function readkey(key)
    local unpacked_key = {}

    local key_table = split_str(key)

    local len_index
    local seed = ''
    for i = 1,#key_table do if type(key_table[i]) == 'string' then len_index = i; break end end
    for i = 1,len_index - 2 do seed = seed .. key_table[i] end

    unpacked_key.char_len = #key_table - len_index -- gets length of each character
    unpacked_key.shift = key_table[len_index - 1] -- gets caeser shift
    unpacked_key.seed = seed + 0 -- gets random seed

    return unpacked_key
end

function letter_scramble(seed, len)
    local scram = {}

    math.randomseed(seed)
    for i = 1,#characters do
        local c = ''
        for i = 1, len do
            c = c .. characters[math.random(1, #characters)]
        end

        scram[characters[i]] = c
    end

    return scram
end

function gencypher(key)
    local keydat = readkey(key)

    local cypher = {}
    local crypt_chars = letter_scramble(keydat.seed, keydat.char_len) -- letter scrambler


    -- caesar cypher
    for i = 1, #characters do
        index = i + keydat.shift
        if index > #characters then
            index = index - #characters
        end

        cypher[characters[i]] = crypt_chars[characters[index]]
    end

    return cypher
end

function encrypt(str, key)
    local str = '' .. str
    local encrypted = ''

    local cypher = gencypher(key)
    local str_table = split_str(str)

    for k,v in pairs(str_table) do
        encrypted = encrypted .. cypher[v]
    end

    return encrypted
end

function decrypt(str, key)
    local str = '' .. str
    local decrypted = ''

    local keydat = readkey(key)
    local cypher = {}

    for k,v in pairs(gencypher(key)) do 
        cypher[v] = k
    end

    local str_table = split_str(str, keydat.char_len)

    for i = 1,#str_table do
        decrypted = decrypted .. cypher[str_table[i]]
    end

    return decrypted
end

function encrypt_table(table, key)
    local encrypted = {}
    local key = key or genkey()

    for k,v in pairs(table) do
        if otype(v) == 'table' then
            encrypted[encrypt(k, key)] = encrypt_table(v, key).data
        else
            encrypted[encrypt(k, key)] = encrypt(v, key)
        end
    end

    return {data = encrypted, key = key}
end

function decrypt_table(dat, key)
    -- if table.data ~= nil then table = table.data end

    local decrypted = {}

    for k,v in pairs(dat) do
        local k = decrypt(k, key)
        local check_index = function() return k + 0 end

        if pcall(check_index) then k = check_index() end

        if otype(v) == 'table' then
            decrypted[k] = decrypt_table(v, key)
        else
            decrypted[k] = decrypt(v, key)
        end
    end

    return decrypted
end
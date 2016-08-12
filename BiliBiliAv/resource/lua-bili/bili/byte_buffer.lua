-- MOR (Merge On Read) technology, like COW (Copy On Write)

local ByteBuffer = {}
local ByteBuffer_id = {id = 0x00012450}

local bit = require("bit")

function ByteBuffer.new()
    local instance = {}
    setmetatable(instance, ByteBuffer)
    instance._class = ByteBuffer_id
    instance._table = {}
    instance._buffer = ""
    instance._validBuffer = false
    return instance
end

function ByteBuffer.is_instance(obj)
    if obj ~= nil and obj._class ~= nil and obj._class == ByteBuffer_id then
        return true
    end
end

function ByteBuffer:push_string(str)
    assert(type(str) == "string" and string.len(str) > 0, "str must be an non-empty string")
    table.insert(self._table, str)
    self._validBuffer = false
end

function ByteBuffer:push_char(char)
    assert(type(char) == "string" and string.len(char) == 1, "char must be ONE char")
    table.insert(self._table, char)
    self._validBuffer = false
end

function ByteBuffer:push_byte(byte)
    assert(type(byte) == "number", "byte must be a number")
    table.insert(self._table, string.char(byte))
    self._validBuffer = false
end

function ByteBuffer:push_boolean(bool)
    assert(type(bool) == "boolean", "bool must be a boolean")
    local value = 0
    if bool == true then
        value = 1
    else
        value = 0
    end
    table.insert(self._table, string.char(value))
    self._validBuffer = false
end

function ByteBuffer:push_short(int16)
    assert(type(int16) == "number", "int16 must be a number")
    -------In literal-------
    --   ah    |     al    |
    ------------------------
    local al = bit.band(int16, 0x000000FF)
    local ah = bit.rshift(bit.band(int16, 0x0000FF00), 8)
    -------In LE Mem--------
    --   al    |     ah    |
    ------------------------
    table.insert(self._table, string.char(al, ah))
    self._validBuffer = false
end

function ByteBuffer:push_int32(int32)
    assert(type(int32) == "number", "int32 must be a number")
    --------In literal-------
    -- eah | eal | ah |  al |
    -------------------------
    local al = bit.band(int32, 0x000000FF)
    local ah = bit.rshift(bit.band(int32, 0x0000FF00), 8)
    local eal = bit.rshift(bit.band(int32, 0x00FF0000), 16)
    local eah = bit.rshift(bit.band(int32, 0xFF000000), 24)
    --------In LE Mem--------
    --  al | ah | eal | eah |
    -------------------------
    table.insert(self._table, string.char(al, ah, eal, eah))
    self._validBuffer = false
end

function ByteBuffer:push_int64(int64)
    assert(type(int64) == "number", "int64 must be a number")
    local l32 = bit.band(int64, 0x00000000FFFFFFFF)
    local h32 = bit.band(int64, 0xFFFFFFFF00000000)
    self:push_int32(l32)
    self:push_int32(h32)
    self._validBuffer = false
end

function ByteBuffer:set_byte_at(index, byte)
    self:set_char_at(index, string.char(byte))
    self._validBuffer = false
end

function ByteBuffer:set_char_at(index, char)
    assert(index >= 1, "index must >= 1")
    assert(type(char) == "string" and string.len(char) == 1, "char must be ONE char")
    self:_check_build_buffer()

    for k, v in pairs(self._table) do
        self._table[k] = nil
    end

    table.insert(self._table, string.sub(self._buffer, 1, index - 1))
    table.insert(self._table, char)
    table.insert(self._table, string.sub(self._buffer, index + 1, string.len(self._buffer)))

    self._validBuffer = false
end

function ByteBuffer:set_short_at(index, int16)
    assert(index >= 1, "index must >= 1")
    assert(type(int16) == "number", "int16 must be number")
    self:_check_build_buffer()

    for k, v in pairs(self._table) do
        self._table[k] = nil
    end

    local al = bit.band(int16, 0x000000FF)
    local ah = bit.rshift(bit.band(int16, 0x0000FF00), 8)

    table.insert(self._table, string.sub(self._buffer, 1, index - 1))
    table.insert(self._table, string.char(al, ah))
    table.insert(self._table, string.sub(self._buffer, index + 2, string.len(self._buffer)))

    self._validBuffer = false
end

function ByteBuffer:set_int32_at(index, int32)
    assert(index >= 1, "index must >= 1")
    assert(type(int32) == "number", "int32 must be number")
    self:_check_build_buffer()

    for k, v in pairs(self._table) do
        self._table[k] = nil
    end

    local al = bit.band(int32, 0x000000FF)
    local ah = bit.rshift(bit.band(int32, 0x0000FF00), 8)
    local eal = bit.rshift(bit.band(int32, 0x00FF0000), 16)
    local eah = bit.rshift(bit.band(int32, 0xFF000000), 24)

    table.insert(self._table, string.sub(self._buffer, 1, index - 1))
    table.insert(self._table, string.char(al, ah, eal, eah))
    table.insert(self._table, string.sub(self._buffer, index + 4, string.len(self._buffer)))

    self._validBuffer = false
end

function ByteBuffer:set_int64_at(index, int64)
    assert(index >= 1, "index must >= 1")
    assert(type(int64) == "number", "int64 must be number")
    self:_check_build_buffer()

    local l32 = bit.band(int64, 0x00000000FFFFFFFF)
    local h32 = bit.band(int64, 0xFFFFFFFF00000000)

    self:set_int32_at(index, l32)
    self:set_int32_at(index + 4, h32)

    self._validBuffer = false
end

function ByteBuffer.__index(obj, key)
    if type(key) == "number" then
        obj:_check_build_buffer()
        return string.byte(obj._buffer, key)
    else
        return rawget(ByteBuffer, key)
    end
end

function ByteBuffer.__newindex(obj, key, value)
    if type(key) == "number" then
        obj:set_char_at(key, string.char(value))
        obj._validBuffer = false
    else
        rawset(obj, key, value)
    end
end

function ByteBuffer:get_byte_at(index)
    self:_check_build_buffer()
    return string.byte(self._buffer, index)
end

function ByteBuffer:get_char_at(index)
    self:_check_build_buffer()
    return string.sub(self._buffer, index, index)
end

function ByteBuffer:get_boolean_at(index)
    self:_check_build_buffer()
    local byte = string.byte(self._buffer, index)
    local value = false
    if byte == 0 then
        value = false
    else
        value = true
    end
    return value
end

function ByteBuffer:get_short_at(index)
    self:_check_build_buffer()
    local al = string.byte(self._buffer, index)
    local ah = string.byte(self._buffer, index + 1)
    return bit.bor(al, bit.lshift(ah, 8))
end

function ByteBuffer:get_int32_at(index)
    self:_check_build_buffer()
    local al = string.byte(self._buffer, index)
    local ah = string.byte(self._buffer, index + 1)
    local eal = string.byte(self._buffer, index + 2)
    local eah = string.byte(self._buffer, index + 3)
    return bit.bor(bit.bor(bit.bor(al, bit.lshift(ah, 8)), bit.lshift(eal, 16)), bit.lshift(eah, 24))
end

function ByteBuffer:get_int64_at(index)
    self:_check_build_buffer()
    local l32 = ByteBuffer:get_int32_at(index)
    local h32 = ByteBuffer:get_int32_at(index + 4)
    return bit.bor(l32, bit.lshift(h32, 32))
end

function ByteBuffer:_check_build_buffer()
    if self._validBuffer == false then
        self._buffer = table.concat(self._table)
        self._validBuffer = true
    end
end

function ByteBuffer:copy_from(src, length, src_index, dst_index)
    assert(ByteBuffer.is_instance(src) == true, "src must be a ByteBuffer")
    assert(src ~= self, "src cannot be same as yourself")
    self:_check_build_buffer()
    src:_check_build_buffer()

    for k, v in pairs(self._table) do
        self._table[k] = nil
    end

    local copy_length = src:length()
    if length ~= nil then
        assert(length >= 1, "length must >= 1")
        copy_length = length
    end

    if dst_index ~= nil and dst_index > 1 then    -- optional prefix
        table.insert(self._table, string.sub(self._buffer, 1, dst_index - 1))
    end

    local copy_from_index = 1                     -- copy src body
    if src_index ~= nil and src_index > 1 then
        copy_from_index = src_index
    end
    table.insert(self._table, string.sub(src._buffer, copy_from_index, copy_from_index + copy_length - 1))

    if string.len(table.concat(self._table)) < string.len(self._buffer) then    -- optional suffix
        if dst_index ~= nil and dst_index > 1 then
            table.insert(self._table, string.sub(self._buffer, dst_index + copy_length, string.len(self._buffer)))
        else
            table.insert(self._table, string.sub(self._buffer, copy_length + 1, string.len(self._buffer)))
        end
    end

    self._validBuffer = false
end

function ByteBuffer:swap(src)
    assert(ByteBuffer.is_instance(src) == true, "src must be a ByteBuffer")
    self:_check_build_buffer()
    src:_check_build_buffer()

    local tmp_buffer = src._buffer
    src._buffer = self._buffer
    self._buffer = tmp_buffer

    local tmp_table = src._table
    src._table = self._table
    self._table = tmp_table
end

function ByteBuffer.__tostring(obj)
    return obj:to_string()
end

function ByteBuffer:to_string()
    self:_check_build_buffer()
    return self._buffer
end

function ByteBuffer:length()
    self:_check_build_buffer()
    return string.len(self._buffer)
end

function ByteBuffer:clear()
    self._buffer = ""

    for k, v in pairs(self._table) do
        self._table[k] = nil
    end

    self._validBuffer = false;
end

function ByteBuffer:dump(size)
    local i = 0                                                                                                                                                    
    local length = self:length()
    if size ~= nil and size > 1 then
        length = size
    end

    for i = 1, length do
        if (i - 1) % 16 == 0 then
            io.write(string.format("%08x: ", (i - 1)))
        end
        io.write(string.format("%02x ", bit.band(0xFF, self:get_byte_at(i))))
        if i % 16 == 0 then
            io.write("\n")
        end
    end
    if (i - 1) % 16 ~= 0 then
        io.write("\n")
    end
end

return ByteBuffer
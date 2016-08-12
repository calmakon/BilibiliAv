local ByteBufferPtr = {}
local ByteBufferPtr_id = {id = 0x00012451}

local ByteBuffer = require("bili.byte_buffer")

function ByteBufferPtr.new(byte_buffer)
	local instance = {}
	setmetatable(instance, ByteBufferPtr)
	instance._class = ByteBufferPtr_id
	instance._offset = 0
	instance._byte_buf = byte_buffer
	return instance
end

function ByteBufferPtr.is_instance(obj)
    if obj ~= nil and obj._class ~= nil and obj._class == ByteBufferPtr_id then
        return true
    end
end

function ByteBufferPtr:bind(byte_buffer)
	assert(ByteBuffer.is_instance(byte_buffer), "byte_buffer must be a ByteBuffer")
	self._byte_buf = byte_buffer
	self._offset = 0
end

function ByteBufferPtr:set_offset(offset)
    self._offset = offset
end

function ByteBufferPtr:add_offset(offset)
    self._offset = self._offset + offset
end

function ByteBufferPtr:sync_offset(byte_buffer_ptr)
	assert(ByteBufferPtr.is_instance(byte_buffer_ptr), "byte_buffer_ptr must be a ByteBufferPtr")
	self._offset = byte_buffer_ptr._offset
end

function ByteBufferPtr:reset_offset()
    self._offset = 0
end

function ByteBufferPtr:get_buffer()
	return self._byte_buf
end

function ByteBufferPtr:set_byte_at(index, byte)
	self._byte_buf:set_byte_at(index + self._offset, byte)
end

function ByteBufferPtr:set_char_at(index, char)
	self._byte_buf:set_char_at(index + self._offset, char)
end

function ByteBufferPtr:set_short_at(index, int16)
	self._byte_buf:set_short_at(index + self._offset, int16)
end

function ByteBufferPtr:set_int32_at(index, int32)
	self._byte_buf:set_int32_at(index + self._offset, int32)
end

function ByteBufferPtr:set_int64_at(index, int64)
	self._byte_buf:set_int64_at(index + self._offset, int64)
end

function ByteBufferPtr:get_byte_at(index)
	return self._byte_buf:get_byte_at(index + self._offset)
end

function ByteBufferPtr:get_char_at(index)
	return self._byte_buf:get_char_at(index + self._offset)
end

function ByteBufferPtr:get_boolean_at(index)
	return self._byte_buf:get_boolean_at(index + self._offset)
end

function ByteBufferPtr:get_short_at(index)
	return self._byte_buf:get_short_at(index + self._offset)
end

function ByteBufferPtr:get_int32_at(index)
	return self._byte_buf:get_int32_at(index + self._offset)
end

function ByteBufferPtr:get_int64_at(index)
	return self._byte_buf:get_int64_at(index + self._offset)
end

function ByteBufferPtr.__index(obj, key)
	if type(key) == "number" then
        return obj._byte_buf:get_byte_at(key + obj._offset)
    else
        return rawget(ByteBufferPtr, key)
    end
end

function ByteBufferPtr.__newindex(obj, key, value)
    if type(key) == "number" then
        obj._byte_buf:set_byte_at(key + obj._offset, value)
    else
        rawset(obj, key, value)
    end
end

function ByteBufferPtr:dump(size)
	self._byte_buf:dump(size)
end

return ByteBufferPtr
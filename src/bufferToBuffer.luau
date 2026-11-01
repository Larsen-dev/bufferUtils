--!strict
--!native
--!optimize 2

local bufferToBuffer = {}

--[=[
    @param buf buffer;
    @param v buffer;
    @param offset number;

    @return ;

    Simply copies buffer to another.
]=]
function bufferToBuffer.write(buf: buffer, v: buffer, offset: number)
	local lenAsBits = buffer.len(v) * 8
	local timesBy32Bits = lenAsBits // 32
	local leftOver = lenAsBits % 32

	for index = 0, timesBy32Bits do
		buffer.writebits(buf, offset + index * 32, 32, buffer.readbits(v, index * 32, 32))
	end

	buffer.writebits(buf, offset + timesBy32Bits * 32, leftOver, buffer.readbits(v, timesBy32Bits * 32, leftOver))
end

--[=[
    @param buf buffer;
    @param offset number;
    @param len number;

    @return buffer;

    Puts data from buffer to new.
]=]
function bufferToBuffer.read(buf: buffer, offset: number, len: number): buffer
	local b = buffer.create(len)

	local lenAsBits = len * 8
	local timesBy32Bits = lenAsBits // 32
	local leftOver = lenAsBits % 32

	for index = 0, timesBy32Bits do
		buffer.writebits(b, index * 32, 32, buffer.readbits(buf, offset + index * 32, 32))
	end

	buffer.writebits(b, timesBy32Bits * 32, leftOver, buffer.readbits(buf, offset + timesBy32Bits, leftOver))

	return b
end

return bufferToBuffer

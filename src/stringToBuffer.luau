--!strict
--!native
--!optimize 2

local stringToBuffer = {}

--[=[
    @param buf buffer;
    @param v string;
    @param offset: number;

    @return ;

    Writes data from string to buffer as ASCLL, won't be able to convert
    special UTF-8 text.
]=]
function stringToBuffer.write(buf: buffer, v: string, offset: number)
	local len = string.len(v)
	local bytes = table.pack(string.byte(v, 1, len))

	for index, byte in ipairs(bytes) do
		buffer.writebits(buf, offset + (index * 8), 8, byte)
	end
end

--[=[
    @param buf buffer;
    @param offset: number;
    @param len number;

    @return string;

    Read data from buffer and represents it as string.
]=]
function stringToBuffer.read(buf: buffer, offset: number, len: number): string
	local sBuf = buffer.create(len)

	for index = 0, len do
		buffer.writeu8(sBuf, index, buffer.readbits(buf, offset + index * 8, 8))
	end

	return buffer.readstring(sBuf, 0, len)
end

return stringToBuffer

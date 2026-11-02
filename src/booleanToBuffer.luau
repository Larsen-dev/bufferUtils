--!strict
--!native
--!optimize 2

local booleanToBuffer = {}

--[=[
	@param buf buffer;
	@param v boolean;
	@param offset number;

	@return ;
]=]
function booleanToBuffer.write(buf: buffer, v: boolean, offset: number)
	buffer.writebits(buf, offset, 1, v == true and 1 or 0)
end

--[=[
	@param buf buffer;
	@param offset number;

	@return boolean;
]=]
function booleanToBuffer.read(buf: buffer, offset: number): boolean
	return buffer.readbits(buf, offset, 1) == 1
end

return booleanToBuffer

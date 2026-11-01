--!strict
--!native
--!optimize 2

-- Dependencies
local globals = script.Parent.globals
local customNumberToBuffer = require(globals.customNumberToBuffer)

-- Values
local numSizes = { 8, 16, 24, 32 }

-- Number To Buffer
local intToBuffer = {}

--[=[
    @param v number;
    
    @return number;

    If int, returns amount of bits needed to represent
    the actual number, 1 or 2 if it's float or double
    and 0 if can't find given.
]=]
function intToBuffer.len(v: number): number
	for _, size in numSizes do
		if v >= -(2 ^ size / 2) and v <= 2 ^ size / 2 - 1 then
			return size
		end
	end

	return 0
end

--[=[
    @param buf buffer;
    @param v number;
    @param offset number;
    @param len number;

    @return ;
]=]
function intToBuffer.write(buf: buffer, v: number, offset: number, len: number)
	customNumberToBuffer.writeInt(buf, v, len, offset)
end

--[=[
    @param buf buffer;
    @param offset number;
    @param len number;

    @return number;
]=]
function intToBuffer.read(buf: buffer, offset: number, len: number): number
	return customNumberToBuffer.readInt(buf, len, offset)
end

return intToBuffer

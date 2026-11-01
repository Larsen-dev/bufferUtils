--!strict
--!native
--!optimize 2

-- Dependencies
local globals = script.Parent.globals
local customNumberToBuffer = require(globals.customNumberToBuffer)

-- Functions

--[=[
	@param n number;
	@return number;

	Returns number after comma as int.
]=]
local function getAfterComma(n: number): number
	return n % 1 == 0 and 0 or getAfterComma(n)
end

-- Float To Buffer
local floatToBuffer = {}

--[=[
	@param v number;
	
	@return number;
]=]
function floatToBuffer.len(v: number): number
	local fullPart = v // 1
	local leftOver = math.abs(v) - math.abs(fullPart)

	return getAfterComma(leftOver) <= 2 ^ 23 and 32 or 64
end

--[=[
	@param buf buffer;
	@param v number;
	@param offset number;
	@param len number;
]=]
function floatToBuffer.write(buf: buffer, v: number, offset: number, len: number)
	if len == 32 then
		customNumberToBuffer.writeFloat32(buf, v, offset)
	else
		customNumberToBuffer.writeFloat64(buf, v, offset)
	end
end

--[=[
	@param buf buffer;
	@param offset number;
	@param len number;

	@return number;
]=]
function floatToBuffer.read(buf: buffer, offset: number, len: number): number
	return len == 32 and customNumberToBuffer.readFloat32(buf, offset) or customNumberToBuffer.readFloat64(buf, offset)
end

return floatToBuffer

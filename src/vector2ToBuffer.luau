--!strict
--!native
--!optimize 2

-- Dependencies
local globals = script.Parent.globals
local customNumberToBuffer = require(globals.customNumberToBuffer)

-- Vector3 To Buffer
local vector2ToBuffer = {}

--[=[
	@param buf buffer;
	@param v Vector2;
	@param offset number;

	@return ;
]=]
function vector2ToBuffer.write(buf: buffer, v: Vector2, offset: number)
	customNumberToBuffer.writeFloat64(buf, v.X, offset)
	customNumberToBuffer.writeFloat64(buf, v.Y, offset + 64)
end

--[=[
	@param buf buffer;
	@param offset number;

	@return Vector2;
]=]
function vector2ToBuffer.read(buf: buffer, offset: number): Vector2
	return Vector2.yAxis * customNumberToBuffer.readFloat64(buf, offset)
		+ Vector2.xAxis * customNumberToBuffer.readFloat64(buf, offset + 64)
end

return vector2ToBuffer

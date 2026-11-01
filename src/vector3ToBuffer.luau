--!strict
--!native
--!optimize 2

-- Dependencies
local globals = script.Parent.globals
local customNumberToBuffer = require(globals.customNumberToBuffer)

-- Vector3 To Buffer
local vector3ToBuffer = {}

--[=[
	@param buf buffer;
	@param v Vector3;
	@param offset number;

	@return ;
]=]
function vector3ToBuffer.write(buf: buffer, v: Vector3, offset: number)
	customNumberToBuffer.writeFloat64(buf, v.X, offset)
	customNumberToBuffer.writeFloat64(buf, v.Y, offset + 64)
	customNumberToBuffer.writeFloat64(buf, v.Z, offset + 128)
end

--[=[
	@param buf buffer;
	@param offset number;

	@return Vector3;
]=]
function vector3ToBuffer.read(buf: buffer, offset: number): Vector3
	return Vector3.yAxis * customNumberToBuffer.readFloat64(buf, offset)
		+ Vector3.xAxis * customNumberToBuffer.readFloat64(buf, offset + 64)
		+ Vector3.zAxis * customNumberToBuffer.readFloat64(buf, offset + 128)
end

return vector3ToBuffer

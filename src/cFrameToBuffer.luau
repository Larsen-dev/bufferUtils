--!strict
--!native
--!optimize 2

-- Dependencies
local globals = script.Parent.globals
local customNumberToBuffer = require(globals.customNumberToBuffer)

-- Vector3 To Buffer
local cFrameToBuffer = {}

--[=[
	@param buf buffer;
	@param v CFrame;
	@param offset number;

	@return ;
]=]
function cFrameToBuffer.write(buf: buffer, v: CFrame, offset: number)
	local rotX, rotY, rotZ = v:ToEulerAnglesXYZ()

	customNumberToBuffer.writeFloat64(buf, v.X, offset)
	customNumberToBuffer.writeFloat64(buf, v.Y, offset + 64)
	customNumberToBuffer.writeFloat64(buf, v.Z, offset + 128)
	customNumberToBuffer.writeFloat64(buf, rotX, offset + 192)
	customNumberToBuffer.writeFloat64(buf, rotY, offset + 256)
	customNumberToBuffer.writeFloat64(buf, rotZ, offset + 320)
end

--[=[
	@param buf buffer;
	@param offset number;

	@return CFrame;
]=]
function cFrameToBuffer.read(buf: buffer, offset: number): CFrame
	local x = customNumberToBuffer.readFloat64(buf, offset)
	local y = customNumberToBuffer.readFloat64(buf, offset + 64)
	local z = customNumberToBuffer.readFloat64(buf, offset + 128)

	local rotX = customNumberToBuffer.readFloat64(buf, offset + 192)
	local rotY = customNumberToBuffer.readFloat64(buf, offset + 256)
	local rotZ = customNumberToBuffer.readFloat64(buf, offset + 320)

	return CFrame.new(x, y, z) * CFrame.fromEulerAnglesXYZ(rotX, rotY, rotZ)
end

return cFrameToBuffer

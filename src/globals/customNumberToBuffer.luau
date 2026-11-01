--!strict
--!native
--!optimize 2

local customNumberToBuffer = {}

--[=[
	@param b buffer;
	@param n number;
	@param size number;
	@param offset number?;
	
	@return ;
	
	Writes some signed integer to a buffer with given in bits offset. Uses
	2 complement method to represent the negative numbers.
]=]
function customNumberToBuffer.writeInt(b: buffer, n: number, size: number, offset: number?)
	offset = offset or 0

	local usigned = if n >= 0 then n else bit32.rshift(n, size) + n

	for index = 0, size - 1 do
		local bit = bit32.band(bit32.rshift(usigned, index), 1)
		buffer.writebits(b, offset + index, 1, bit)
	end
end

--[=[
	@param b buffer;
	@param n number;
	@param offset number?;
	
	@return ;
	
	Writes some signed 32 bit float to a buffer with given in bits offset.
]=]
function customNumberToBuffer.writeFloat32(b: buffer, n: number, offset: number?)
	offset = offset or 0

	if n == 0 then
		local sign = if 1 / n == -math.huge then 1 else 0

		for index = 0, 31 do
			local bit = (index == 31) and sign or 0
			buffer.writebits(b, offset + index, 1, bit)
		end

		return
	end

	local sign = if n > 0 then 0 else 1
	local exponent = math.floor(math.log(math.abs(n), 2))
	local mantissa = math.abs(n) / (2 ^ exponent) - 1

	local exponentBits = exponent + 127
	local mantissaBits = math.floor(mantissa * 2 ^ 23 + 0.5)

	local bits = bit32.bor(bit32.lshift(sign, 31), bit32.lshift(exponentBits, 23), bit32.lshift(mantissaBits, 0))

	for index = 0, 31 do
		local bit = bit32.band(bit32.rshift(bits, index), 1)
		buffer.writebits(b, offset + index, 1, bit)
	end
end

--[=[
	@param b buffer;
	@param b number;
	@param offset number?;
	
	@return ;
	
	Writes 64 bit float to a buffer with given in bits offset. Uses IEE-754
	standard.
]=]
function customNumberToBuffer.writeFloat64(b: buffer, n: number, offset: number?)
	offset = offset or 0

	if n == 0 then
		local sign = if 1 / n == -math.huge then 1 else 0

		for index = 0, 63 do
			local bit = (index == 63) and sign or 0
			buffer.writebits(b, offset + index, 1, bit)
		end

		return
	end

	local sign = (n < 0) and 1 or 0
	local exponent = math.floor(math.log(math.abs(n), 2))
	local mantissa = math.abs(n) / (2 ^ exponent) - 1

	local exponentBits = exponent + 1023
	local mantissaBits = math.floor(mantissa * 2 ^ 52 + 0.5)

	local mantissaHighBits = math.floor(mantissaBits / 2 ^ 32)
	local mantissaLowBits = mantissaBits % 2 ^ 32

	local high = bit32.lshift(sign, 31) + bit32.lshift(exponentBits, 20) + bit32.band(mantissaHighBits, 0xFFFFF)

	for index = 0, 31 do
		local bit = bit32.band(bit32.rshift(high, index), 1)
		buffer.writebits(b, offset + index, 1, bit)
	end

	for index = 0, 31 do
		local bit = bit32.band(bit32.rshift(mantissaLowBits, index), 1)
		buffer.writebits(b, offset + 32 + index, 1, bit)
	end
end

--[=[
	@param b buffer;
	@param n number;
	@param offset number?;
	
	@return number;
	
	Reads some signed integer written using 2 complement method from a
	buffer with given in bits offset.
]=]
function customNumberToBuffer.readInt(b: buffer, size: number, offset: number?)
	offset = offset or 0

	local n = 0

	for index = 0, size - 1 do
		local bit = buffer.readbits(b, offset + index, 1)
		n += bit * 2 ^ index
	end

	local signBit = 2 ^ (size - 1)
	if n >= signBit then
		n -= 2 ^ size
	end

	return n
end

--[=[
	@param b buffer;
	@param offset number?;
	
	@return number;
	
	Reads some signed 32 bit float from a given buffer with given in bits
	offset.
]=]
function customNumberToBuffer.readFloat32(b: buffer, offset: number?)
	offset = offset or 0

	local bits = 0

	for index = 0, 31 do
		local bit = buffer.readbits(b, offset + index, 1)
		bits = bit32.bor(bits, bit32.lshift(bit, index))
	end

	local sign = bit32.rshift(bits, 31)
	local exponent = bit32.band(bit32.rshift(bits, 23), 0xff)
	local mantissa = bit32.band(bits, 0x7FFFFF)

	local value = (1 + mantissa / 2 ^ 23) * 2 ^ (exponent - 127)
	if sign == 1 then
		value = -value
	end

	return value
end

--[=[
	@param b buffer;
	@param offset number?;
	
	@return number;
	
	Reads some written in the buffer 64 bit float written using IEE-754
	standard at some offset in bits.
]=]
function customNumberToBuffer.readFloat64(b: buffer, offset: number?)
	offset = offset or 0

	local high = 0

	for index = 0, 31 do
		local bit = buffer.readbits(b, offset + index, 1)
		high += bit * 2 ^ index
	end

	local mantissaLow = 0

	for index = 0, 31 do
		local bit = buffer.readbits(b, offset + 32 + index, 1)
		mantissaLow += bit * 2 ^ index
	end

	local sign = bit32.rshift(high, 31)
	local exponentBits = bit32.band(bit32.rshift(high, 20), 0x7FF)
	local mantissaHigh = bit32.band(high, 0xFFFFF)

	if exponentBits == 0 and mantissaHigh == 0 and mantissaLow == 0 then
		return if sign == 1 then -0 else 0
	end

	local exponent = exponentBits - 1023
	local mantissa = 1 + ((mantissaHigh * 2 ^ 32 + mantissaLow) / 2 ^ 52)
	local value = mantissa * (2 ^ exponent)

	return if sign == 1 then -value else value
end

return customNumberToBuffer

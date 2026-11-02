--!strict
--!native
--!optimize 2

-- Dependencies
local booleanToBuffer = require(script.booleanToBuffer)
local intToBuffer = require(script.intToBuffer)
local floatToBuffer = require(script.floatToBuffer)
local stringToBuffer = require(script.stringToBuffer)
local bufferToBuffer = require(script.bufferToBuffer)
local vector2ToBuffer = require(script.vector2ToBuffer)
local vector3ToBuffer = require(script.vector3ToBuffer)
local cFrameToBuffer = require(script.cFrameToBuffer)

-- Types
type availableTypes = number | string | buffer | Vector2 | Vector3 | CFrame
export type tableScheme = { [availableTypes | tableScheme]: availableTypes | tableScheme }

-- Functions

--[=[
	@param v availableTypes | tableScheme;

	@return string;

	Own way to get type because it divides number in solid
	ints and floats which is crucial for convertor to work.
]=]
local function getType(v: availableTypes | tableScheme): string
	local vType = typeof(v)

	if vType == "number" then
		return v :: number % 1 == 0 and "int" or "float"
	end

	return vType
end

-- Values
local lenFunctions = {
	boolean = function(v: boolean)
		return 1
	end,
	int = intToBuffer.len,
	float = floatToBuffer.len,
	string = string.len,
	buffer = buffer.len,
	Vector2 = function()
		return 128
	end,
	Vector3 = function()
		return 192
	end,
	CFrame = function()
		return 384
	end,
} :: { [string]: (v: availableTypes | tableScheme) -> number } -- These to use while writing

local lenFunctionInBits = {
	boolean = function(v: boolean)
		return 1
	end,
	int = intToBuffer.len,
	float = floatToBuffer.len,
	string = function(v: string)
		return string.len(v) * 8
	end,
	buffer = function(v: buffer)
		return buffer.len(v) * 8
	end,
	Vector2 = function()
		return 128
	end,
	Vector3 = function()
		return 192
	end,
	CFrame = function()
		return 384
	end,
} :: { [string]: (v: availableTypes | tableScheme) -> number }

local writeFunctions = {
	boolean = booleanToBuffer.write,
	int = intToBuffer.write,
	float = floatToBuffer.write,
	string = stringToBuffer.write,
	buffer = bufferToBuffer.write,
	Vector2 = vector2ToBuffer.write,
	Vector3 = vector3ToBuffer.write,
	CFrame = cFrameToBuffer.write,
} :: { [string]: (buf: buffer, v: availableTypes | tableScheme, offset: number, len: number) -> () }

local readFunctions = {
	boolean = booleanToBuffer.read,
	int = intToBuffer.read,
	float = floatToBuffer.read,
	string = stringToBuffer.read,
	buffer = bufferToBuffer.read,
	Vector2 = vector2ToBuffer.read,
	Vector3 = vector3ToBuffer.read,
	CFrame = cFrameToBuffer.read,
} :: { [string]: (buf: buffer, offset: number, len: number) -> availableTypes | tableScheme }

const indexes = {
	boolean = 0,
	int = 1,
	float = 2,
	string = 3,
	buffer = 4,
	Vector2 = 5,
	Vector3 = 6,
	CFrame = 7,
	table = 8,
}

const reversedIndexes = {
	"boolean",
	"int",
	"float",
	"string",
	"buffer",
	"Vector2",
	"Vector3",
	"CFrame",
	"table",
}

const TYPE_INDEX_SIZE = 3
const LENGTH_SIZE = 16
const SCOPE_SIZE = TYPE_INDEX_SIZE + LENGTH_SIZE
const SCOPES_SIZE = 19

-- Table To Buffer
local tableToBuffer = {}

--[=[
	@param t tableScheme;

	@return number;

	Returns size of scopes needed to be written down
	to buffer in bits.
]=]
function tableToBuffer.scopesSize(t: tableScheme): number
	local size = 0

	for index, value in t do
		size += SCOPE_SIZE * 2
	end

	return size
end

--[=[
	@param t tableScheme;

	@return number;

	Returns size of actual data in table in bits.
]=]
function tableToBuffer.dataSize(t: tableScheme): number
	local size = 0

	for key, value in t do
		local keyType = getType(key)
		local valueType = getType(value)

		local keyLenFunction = lenFunctionInBits[keyType] and lenFunctionInBits[keyType] or nil
		local valueLenFunction = lenFunctionInBits[valueType] and lenFunctionInBits[valueType] or nil

		assert(keyLenFunction, string.format("Invalid type provided in key which can't be measured: %s", keyType))
		assert(valueLenFunction, string.format("Invalid type provided in value which can't be measured: %s", valueType))

		size += keyLenFunction(key) + valueLenFunction(value)
	end

	return size
end

--[=[
	@param t tableScheme;

	@return number;

	Returns size of buffer needed to write table down.
]=]
function tableToBuffer.len(t: tableScheme): number
	local scopeSize = tableToBuffer.scopesSize(t)
	local dataSize = tableToBuffer.dataSize(t)

	return math.ceil((scopeSize + dataSize) / 8)
end

lenFunctions["table"] = tableToBuffer.len :: (v: availableTypes | tableScheme) -> number -- A little bit dirty, yet there won't be need for closures, recursive requires, etc.
lenFunctionInBits["table"] = function(t: tableScheme)
	return tableToBuffer.len(t) * 8
end :: (v: availableTypes | tableScheme) -> number

--[=[
	@param buf buffer;
	@param t tableScheme;
	@param offset number?;

	@return ;
]=]
function tableToBuffer.write(buf: buffer, t: tableScheme, offset: number?)
	offset = offset or 0

	local scopesSize = tableToBuffer.scopesSize(t)
	buffer.writebits(buf, offset, SCOPES_SIZE, scopesSize)
	--[=[
	To clarify why 19 bits to write scopesSize:
	I'm looking over previous limit to ~90000 keys, tvice it
	and you'll receive 180000 bits to represent 90000 keys and
	90000 values. Nearest number from powers of two it's 2^19.
	]=]

	local lastScopeOffset = offset + SCOPES_SIZE
	local lastDataOffset = offset + SCOPES_SIZE + scopesSize

	for key, value in t do
		local keyType = getType(key)
		local valueType = getType(value)

		local keyLenFunction = lenFunctions[keyType] and lenFunctions[keyType] or nil
		local valueLenFunction = lenFunctions[valueType] and lenFunctions[valueType] or nil

		assert(keyLenFunction, string.format("Invalid type provided in key which can't be measured: %s", keyType))
		assert(valueLenFunction, string.format("Invalid type provided in value which can't be measured: %s", valueType))

		local keyLenFunctionInBits = lenFunctionInBits[keyType] and lenFunctionInBits[keyType] or nil
		local valueLenFunctionInBits = lenFunctionInBits[valueType] and lenFunctionInBits[valueType] or nil

		assert(
			keyLenFunctionInBits,
			string.format("Invalid type provided in key which can't be measured: %s", keyType)
		)
		assert(
			valueLenFunctionInBits,
			string.format("Invalid type provided in value which can't be measured: %s", valueType)
		)

		local keyWriteFunction = writeFunctions[keyType] and writeFunctions[keyType] or nil
		local valueWriteFunction = writeFunctions[valueType] and writeFunctions[valueType] or nil

		assert(
			keyWriteFunction,
			string.format("Invalid type provided in key which can't be written in buffer: %s", keyType)
		)
		assert(
			valueWriteFunction,
			string.format("Invalid type provided in value which can't be written in buffer: %s", valueType)
		)

		local keyTypeIndex = indexes[keyType]
		local valueTypeIndex = indexes[valueType]
		local keyLen = keyLenFunction(key)
		local valueLen = valueLenFunction(value)

		buffer.writebits(buf, lastScopeOffset, TYPE_INDEX_SIZE, keyTypeIndex)
		buffer.writebits(buf, lastScopeOffset + TYPE_INDEX_SIZE, LENGTH_SIZE, keyLen)

		buffer.writebits(buf, lastScopeOffset + SCOPE_SIZE, TYPE_INDEX_SIZE, valueTypeIndex)
		buffer.writebits(buf, lastScopeOffset + SCOPE_SIZE + TYPE_INDEX_SIZE, LENGTH_SIZE, valueLen)

		local keyLenInBits = keyLenFunctionInBits(key)

		keyWriteFunction(buf, key, lastDataOffset, keyLen)
		valueWriteFunction(buf, value, lastDataOffset + keyLenInBits, valueLen)

		lastScopeOffset += SCOPE_SIZE * 2
		lastDataOffset += keyLenInBits + valueLenFunctionInBits(value)
	end
end

writeFunctions["table"] = tableToBuffer.write :: (buf: buffer, v: availableTypes | tableScheme, offset: number, len: number) -> ()

--[=[
	@param buf buffer;
	@param offset number?;

	@return tableScheme;
]=]
function tableToBuffer.read(buf: buffer, offset: number?): tableScheme
	offset = offset or 0

	local t = {} :: tableScheme

	local scopesLen = buffer.readbits(buf, offset, SCOPES_SIZE)
	local lastScopeOffset = offset + SCOPES_SIZE
	local lastDataOffset = scopesLen + SCOPES_SIZE

	for _index = 0, scopesLen, 2 do
		local keyTypeIndex = buffer.readbits(buf, lastScopeOffset, TYPE_INDEX_SIZE)
		local keyLen = buffer.readbits(buf, lastScopeOffset + TYPE_INDEX_SIZE, LENGTH_SIZE)

		local valueTypeIndex = buffer.readbits(buf, lastScopeOffset + SCOPE_SIZE, TYPE_INDEX_SIZE)
		local valueLen = buffer.readbits(buf, lastScopeOffset + SCOPE_SIZE + TYPE_INDEX_SIZE, LENGTH_SIZE)

		local indexType: string? = reversedIndexes[keyTypeIndex] and reversedIndexes[keyTypeIndex] or nil
		local valueType: string? = reversedIndexes[valueTypeIndex] and reversedIndexes[valueTypeIndex] or nil

		assert(indexType, string.format("Invalid type provided in key which can't be read: %d", keyTypeIndex))
		assert(valueType, string.format("Invalid type provided in value which can't be read: %d", valueTypeIndex))

		local indexReadFunction = readFunctions[indexType]
		local valueReadFunction = readFunctions[valueType]

		local indexLenFunctionFromInBits = lenFunctionInBits[indexType]
		local valueLenFunctionFromInBits = lenFunctionInBits[valueType]

		local key = indexReadFunction(buf, lastDataOffset, keyLen) :: availableTypes
		local keySize = indexLenFunctionFromInBits(key)

		local value = valueReadFunction(buf, lastDataOffset + keySize, valueLen) :: availableTypes

		t[key] = value

		lastScopeOffset += SCOPE_SIZE * 2
		lastDataOffset += keySize + valueLenFunctionFromInBits(value)
	end

	return t
end

readFunctions["table"] = tableToBuffer.read

--[=[
	@param t tableScheme;

	@return ;
]=]
function tableToBuffer.new(t: tableScheme)
	local bufferSize = tableToBuffer.len(t)
	local buf = buffer.create(bufferSize)

	tableToBuffer.write(buf, t)
end

return {
	tableToBuffer = tableToBuffer,
	booleanToBuffer = booleanToBuffer,
	intToBuffer = intToBuffer,
	floatToBuffer = floatToBuffer,
	stringToBuffer = stringToBuffer,
	bufferToBuffer = bufferToBuffer,
	vector2ToBuffer = vector2ToBuffer,
	vector3ToBuffer = vector3ToBuffer,
	cFrameToBuffer = cFrameToBuffer,
}

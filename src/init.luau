--!strict
--!native
--!optimize 2

-- Dependencies
local intToBuffer = require(script.intToBuffer)
local floatToBuffer = require(script.floatToBuffer)
local stringToBuffer = require(script.stringToBuffer)
local bufferToBuffer = require(script.bufferToBuffer)
local vector2ToBuffer = require(script.vector2ToBuffer)
local vector3ToBuffe = require(script.vector3ToBuffer)
local cFrameToBuffer = require(script.cFrameToBuffer)

-- Types
type availableTypes = number | string | buffer | Vector2 | Vector3 | CFrame
export type tableScheme = { [availableTypes | tableScheme]: availableTypes | tableScheme }

-- Functions

local function getType(v: availableTypes | tableScheme)
	local vType = typeof(v)

	if vType == "number" then
		return v :: number % 1 == 0 and "int" or "float"
	end

	return vType
end

-- Values
local lenFunc = {
	["int"] = intToBuffer.len,
	["float"] = floatToBuffer.len,
	["string"] = string.len,
	["buffer"] = buffer.len,
} :: { [string]: (any) -> number }

local constLens = {
	["Vector2"] = 128,
	["Vector3"] = 192,
	["CFrame"] = 384,
} :: { [string]: number }

-- Table To Buffer
local tableToBuffer = {}

function tableToBuffer.scopesLen(t: tableScheme) end

function tableToBuffer.len(t: tableScheme)
	local size = 0

	for index, value in t do
		local indexType = getType(index)
		local valueType = getType(value)

		if lenFunc[indexType] then
			size += lenFunc[indexType](index)
		elseif constLens[indexType] then
			size += constLens[indexType]
		end

		if lenFunc[valueType] then
			size += lenFunc[valueType](value)
		elseif constLens[valueType] then
			size += constLens[valueType]
		end
	end

	return size
end

lenFunc["table"] = tableToBuffer.len -- A little bit dirty, yet there won't be need for closures, recursive requires, etc.

function tableToBuffer.write() end

function tableToBuffer.read() end

function tableToBuffer.new() end

return {}

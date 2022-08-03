function PrintHex(data)
	print(GetHexString(data))
end

function GetHexString(data)
	local output = "";

	for i = 1, #data do
		char = string.sub(data, i, i)
		output = output .. string.format("%02X", string.byte(char)) .. " "
	end
	return output
end

function PrintDecimal(data)
	print(GetDecimalString(data))
end

function GetDecimalString(data)
	local output = "";

	for i = 1, #data do
		char = string.sub(data, i, i)
		output = output .. string.format("%d", string.byte(char)) .. " "
	end
	return output
end

function Int32ToBytes(val)
	return string.char((val / (256*256*256)) % 256) .. string.char((val / (256*256)) % 256) .. string.char((val / (256)) % 256) .. string.char(DriverPublicKeyExponent % 256)
end

function RemoveLeadingZeros(data)
	if(#data > 0 and data:byte(1) == 0) then
	   return RemoveLeadingZeros(data:sub(2))
	end
	return data
end
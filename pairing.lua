DriverPublicKeyModulus = "00:d5:e1:f7:59:36:a9:1b:fe:e6:13:11:ca:bb:50:1b:37:b5:0f:d3:af:cd:96:3d:18:34:84:fb:52:21:1d:65:f9:d3:38:bb:7d:9f:2d:bd:e3:e3:ff:3f:9b:b8:d8:f2:3c:59:b0:29:17:b3:f5:cb:a9:b0:73:a4:9a:2d:a9:3d:a9:9f:4b:55:09:6a:bc:06:98:d3:3e:eb:45:ba:ec:46:88:05:d5:55:6a:03:d0:c1:2a:1c:8f:d0:17:50:1e:e0:a5:2d:00:1e:9b:87:cb:9e:0b:ca:44:70:83:65:80:ce:67:bc:e8:25:e6:72:29:e1:a7:c7:73:d8:ea:fa:b0:3d:44:d4:66:13:86:7c:6c:2f:63:b0:3d:b6:a1:58:41:20:1c:ea:65:53:06:77:be:c9:79:68:c9:07:e1:58:d7:1f:63:00:47:ff:c6:b2:0e:95:d9:40:c6:08:d2:99:ec:6b:5a:4b:28:e6:cd:64:8b:44:b6:89:dd:ae:a3:09:f3:7e:c3:b9:fc:dd:2b:a5:cf:3a:f7:65:4e:bb:e8:0b:92:40:3d:47:0a:ce:18:1c:12:51:88:27:d2:01:d7:df:ef:23:6e:b3:ca:b3:bc:09:48:82:d3:ea:b9:53:44:b3:a6:05:75:79:24:fe:c8:de:e7:03:d0:a7:0a:2c:d4:8a:0e:a3:13"
DriverPublicKeyExponent = 65537

function BeginPair(tQueryParams)
	print ("Begin Pairing...")
	C4:NetConnect(6001, 6467)
end

function FinishPair(tQueryParams)
	local PairingCode = tQueryParams.PAIRING_CODE;
	print ("Finish Pairing (" .. PairingCode .. ")...")
	local Secret = ComputeSecret(PairingCode)
	
	print("Sending Final Pairing Message with Secret")
	SendPairingWireCommand(
		{
			[1]={ID=1, WireType=WireType_VarInt, Value=2},
			[2]={ID=2, WireType=WireType_VarInt, Value=200},
			[40]={[1]={ID=1, WireType=WireType_String, Value=Secret}}
		})
end

function ComputeSecret(PairingCode)
	print("Computing Secret Started...")
	local DriverModulusBytes = RemoveLeadingZeros(DecodeModulusText(DriverPublicKeyModulus))
	local DriverExponentBytes = RemoveLeadingZeros(Int32ToBytes(DriverPublicKeyExponent))
	
	local DeviceModulusBytes = RemoveLeadingZeros(DecodeModulusText(Properties["Device Public Key Modulus"]))
	local DeviceExponentBytes = RemoveLeadingZeros(Int32ToBytes(Properties["Device Public Key Exponent"]))
	
	local CodeBytes = string.fromhex(string.sub(PairingCode, 3))
	
	print("-----------------------------------------------")
	print("Driver Modulus (" .. #DriverModulusBytes .. "): " .. GetHexString(DriverModulusBytes))
	print("Driver Exponent (" .. #DriverExponentBytes .. "): " .. GetHexString(DriverExponentBytes))
	print("~~~~~~~~~~~~~~")
	print("Device Modulus (" .. #DeviceModulusBytes .. "): " .. GetHexString(DeviceModulusBytes))
	print("Device Exponent (" .. #DeviceExponentBytes .. "): " .. GetHexString(DeviceExponentBytes))
	print("~~~~~~~~~~~~~~")
	print("Code (" .. #CodeBytes .. "): " .. GetHexString(CodeBytes))
	print("-----------------------------------------------")

	local DataToHash = DriverModulusBytes .. DriverExponentBytes .. DeviceModulusBytes .. DeviceExponentBytes .. CodeBytes

	local HashOptions = {
						return_encoding = 'HEX',
						data_encoding = 'NONE',
					}
	print("Computed Secret Payload: " .. DataToHash)
	PrintHex(DataToHash)
	
	local SecretHash = string.fromhex(C4:Hash("SHA256", DataToHash, HashOptions))
	print("Computed Secret (Hash): " .. SecretHash)
	PrintHex(SecretHash)
	return SecretHash
end

function DecodeModulusText(ModulusText)
	return string.fromhex(string.gsub(ModulusText, ":", ""))
end

function string.fromhex(str)
	return (str:gsub('..', function (cc) return string.char(tonumber(cc, 16)) end))
end

function SendPairingWireCommand(WireMessage)
	SendPairingCommandWithSize(EncodeWire(WireMessage))
end

function SendPairingCommandWithSize(Payload)
	DebugHeader("Sending Pairing Command (" .. #Payload .. "): " .. GetHexString(Payload))
	local WireMessage = DecodeWire(Payload, 1)
	local FingerPrint = GetWireMessageFingerPrint(WireMessage)
	C4:SendToNetwork(6001, 6467, string.char(#Payload));
	C4:SendToNetwork(6001, 6467, Payload);
	
	DebugWireMessage(WireMessage)
end

function Pairing_SendRequest()
	Debug("Sending First Pairing Message")
	SendPairingWireCommand(
		{
			[1]={ID=1, WireType=WireType_VarInt, Value=2},
			[2]={ID=2, WireType=WireType_VarInt, Value=200},
			[10]={[1]={ID=1, WireType=WireType_String, Value="Android TV Control4 Driver"}}
		})
	
	Debug("Sending Second Pairing Message")
	SendPairingWireCommand(
		{
			[1]={ID=1, WireType=WireType_VarInt, Value=2},
			[2]={ID=2, WireType=WireType_VarInt, Value=200},
			[20]={
						[1]={
									[1]={ID=1, WireType=WireType_VarInt, Value=3},
									[2]={ID=2, WireType=WireType_VarInt, Value=6}},
						[3]={ID=3, WireType=WireType_VarInt, Value=1}
						}
		})

	Debug("Sending Third Pairing Message")
	SendPairingWireCommand(
		{
			[1]={ID=1, WireType=WireType_VarInt, Value=2},
			[2]={ID=2, WireType=WireType_VarInt, Value=200},
			[30]={
						[1]={
									[1]={ID=1, WireType=WireType_VarInt, Value=3},
									[2]={ID=2, WireType=WireType_VarInt, Value=6}},
						[2]={ID=2, WireType=WireType_VarInt, Value=1}
						}
		})
	
end
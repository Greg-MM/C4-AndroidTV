require "debugging"
require "keycodes"
require "helpers"
require "protobuf"
require "pairing"

local DriverVersion = "1.0.1"
EventID_CurrentAppChanged = 1

EX_CMD		= {}
LUA_ACTION	= {}

function OnDriverInit(driverInitType)
	for k,v in pairs(Properties) do
		OnPropertyChanged(k)
	end
	C4:AddVariable("CURRENT_APP", "", "STRING")

	if (driverInitType == "DIT_ADDING") then
	-- Initialization needed only when the driver is added to a project
	elseif (driverInitType == "DIT_STARTUP") then
	-- Initialization needed only during initial startup
	elseif (driverInitType == "DIT_UPDATING") then
	-- Initialization needed only after a driver update
	end
end


function ExecuteCommand(strCommand, tQueryParams)
	DebugHeader("ExecuteCommand(" .. strCommand .. ")")
	Debug(tQueryParams)
	
	local trimmedCommand = string.gsub(strCommand, " ", "")
	
	if (EX_CMD[strCommand] ~= nil and type(EX_CMD[strCommand]) == "function") then
		EX_CMD[strCommand](tQueryParams)
	elseif (EX_CMD[trimmedCommand] ~= nil and type(EX_CMD[trimmedCommand]) == "function") then
		EX_CMD[trimmedCommand](tQueryParams)
	elseif (EX_CMD[strCommand] ~= nil) then -- handle the command
		QueueCommand(EX_CMD[strCommand])
	else
		Debug("ExecuteCommand: Unhandled Command = " .. strCommand)
	end
end

function EX_CMD.LUA_ACTION(tQueryParams)
	if tQueryParams ~= nil then
		for cmd,cmdv in pairs(tQueryParams) do
			if cmd == "ACTION" then
				if (LUA_ACTION[cmdv] ~= nil) then
					LUA_ACTION[cmdv](tQueryParams)
				else
					Debug("Undefined Action")
					Debug("Key: " .. cmd .. " Value: " .. cmdv)
				end
			else
				Debug("Undefined Command")
				Debug("Key: " .. cmd .. " Value: " .. cmdv)
			end
		end
	else
		Debug("LUA_ACTION: tQueryParams IS NULL!")
	end
end

function OnVariableChanged(strName)
	Debug("OnVariableChanged: " .. strName)
end

function OnPropertyChanged(strProperty)
	Debug("OnPropertyChanged: ".. strProperty);
	if (strProperty == "Debug Mode") then
		Debug("Debug Mode Set To: " .. Properties[strProperty])
		if (Properties[strProperty] == "OFF") then
			DebugPrint = false
			DebugTimerID = 0
		elseif (Properties[strProperty] == "ON") then
			DebugPrint = true
			StartDebugTimer()
		end
	end
end

function OnTimerExpired(TimerID)
	Debug("OnTimerExpired: " .. TimerID)
	
	if (TimerID == DebugTimerID) then
		Debug("Turning Debug Mode OFF")
		C4:UpdateProperty("Debug Mode", "OFF")
		DebugTimerID = C4:KillTimer(TimerID)
	else
		Debug("Unknown Timer: " .. TimerID)
		C4:KillTimer(TimerID)
	end
end





function ReceivedFromProxy(BindingID, strCommand, tParams)
	DebugHeader("ReceivedFromProxy (" .. BindingID .. "): " .. strCommand)
	if (tParams ~= nil) then	Debug(tParams)	end
	if(Properties["Connection"] == "OFFLINE") then
			Debug("Connection OFFLINE, Attempting To Connect...")
			LUA_ACTION.ConnectToCommand(nil)
	end

	if (BindingID == 5001) then
		if (strCommand == "ON") then
			if (Properties["Power Status"] == "OFF") then
				SendKey(KEYCODE_POWER)
			end
		elseif (strCommand == "OFF") then
			if (Properties["On Room Off"] == "Pause") then
				SendKey(tonumber(Properties["PAUSE_ROOM_OFF Mapping"]))
			end
		else
			if (ProcessInputCommand(strCommand, tParams) == false) then
				DebugDivider("!")
				Debug("COMMAND UNKNOWN: "..strCommand)
				DebugDivider("!")
			end
		end
	
elseif (BindingID==5002) then -- Mini Driver Commands
		--TODO: Implement Mini Drivers
		DebugDivider("!")
		Debug("COMMAND UNKNOWN (Mini Driver Switch): "..strCommand)
		DebugDivider("!")
	end
end


function ProcessInputCommand(CMD, tParams)
	if (CMD == "GUIDE" or CMD == "START_GUIDE" or CMD == "PULSE_GUIDE" or CMD == "STOP_GUIDE" or CMD == "END_GUIDE") then
		return ProcessInputCommandKey(tonumber(Properties["GUIDE Mapping"]), CMD, tParams)
	elseif (C == "PAGE_UP" or C == "START_PAGE_UP" or C == "PULSE_PAGE_UP" or C == "STOP_PAGE_UP" or C == "END_PAGE_UP") then
		return ProcessInputCommandKey(tonumber(Properties["PAGE UP Mapping"]), CMD, tParams)
	elseif (CMD == "PAGE_DOWN" or CMD == "START_PAGE_DOWN" or CMD == "PULSE_PAGE_DOWN" or CMD == "STOP_PAGE_DOWN" or CMD == "END_PAGE_DOWN") then
		return ProcessInputCommandKey(tonumber(Properties["PAGE DOWN Mapping"]), CMD, tParams)
	elseif (CMD == "UP" or CMD == "START_UP" or CMD == "PULSE_UP" or CMD == "STOP_UP" or CMD == "END_UP") then
		return ProcessInputCommandKey(tonumber(Properties["UP Mapping"]), CMD, tParams)
	elseif (CMD == "DOWN" or CMD == "START_DOWN" or CMD == "PULSE_DOWN" or CMD == "STOP_DOWN" or CMD == "END_DOWN") then
		return ProcessInputCommandKey(tonumber(Properties["DOWN Mapping"]), CMD, tParams)
	elseif (CMD == "LEFT" or CMD == "START_LEFT" or CMD == "PULSE_LEFT" or CMD == "STOP_LEFT" or CMD == "END_LEFT") then
		return ProcessInputCommandKey(tonumber(Properties["LEFT Mapping"]), CMD, tParams)
	elseif (CMD == "RIGHT" or CMD == "START_RIGHT" or CMD == "PULSE_RIGHT" or CMD == "STOP_RIGHT" or CMD == "END_RIGHT") then
		return ProcessInputCommandKey(tonumber(Properties["RIGHT Mapping"]), CMD, tParams)
	elseif (CMD == "ENTER" or CMD == "START_ENTER" or CMD == "PULSE_ENTER" or CMD == "STOP_ENTER" or CMD == "END_ENTER") then
		return ProcessInputCommandKey(tonumber(Properties["ENTER Mapping"]), CMD, tParams)
	
	elseif (CMD == "RECALL" or CMD == "START_RECALL" or CMD == "PULSE_RECALL" or CMD == "STOP_RECALL" or CMD == "END_RECALL") then
		return ProcessInputCommandKey(tonumber(Properties["PREVIOUS CHANNEL Mapping"]), CMD, tParams)
	
	elseif (CMD == "CH_UP" or CMD == "START_CH_UP" or CMD == "PULSE_CH_UP" or CMD == "STOP_CH_UP" or CMD == "END_CH_UP") then
		return ProcessInputCommandKey(tonumber(Properties["CHANNEL UP Mapping"]), CMD, tParams)
	elseif (CMD == "CH_DOWN" or CMD == "START_CH_DOWN" or CMD == "PULSE_CH_DOWN" or CMD == "STOP_CH_DOWN" or CMD == "END_CH_DOWN") then
		return ProcessInputCommandKey(tonumber(Properties["CHANNEL DOWN Mapping"]), CMD, tParams)
	
	elseif (CMD == "INFO" or CMD == "START_INFO" or CMD == "PULSE_INFO" or CMD == "STOP_INFO" or CMD == "END_INFO") then
		return ProcessInputCommandKey(tonumber(Properties["INFO Mapping"]), CMD, tParams)
	elseif (CMD == "MENU" or CMD == "START_MENU" or CMD == "PULSE_MENU" or CMD == "STOP_MENU" or CMD == "END_MENU") then
		return ProcessInputCommandKey(tonumber(Properties["MENU Mapping"]), CMD, tParams)
	elseif (CMD == "CANCEL" or CMD == "START_CANCEL" or CMD == "PULSE_CANCEL" or CMD == "STOP_CANCEL" or CMD == "END_CANCEL") then
		return ProcessInputCommandKey(tonumber(Properties["CANCEL Mapping"]), CMD, tParams)
	elseif (CMD == "DVR" or CMD == "START_DVR" or CMD == "PULSE_DVR" or CMD == "STOP_DVR" or CMD == "END_DVR") then
		return ProcessInputCommandKey(tonumber(Properties["DVR Mapping"]), CMD, tParams)
	
	elseif (CMD == "SCAN_REV" or CMD == "START_SCAN_REV" or CMD == "PULSE_SCAN_REV" or CMD == "STOP_SCAN_REV" or CMD == "END_SCAN_REV") then
		return ProcessInputCommandKey(tonumber(Properties["REWIND Mapping"]), CMD, tParams)
	elseif (CMD == "SCAN_FWD" or CMD == "START_SCAN_FWD" or CMD == "PULSE_SCAN_FWD" or CMD == "STOP_SCAN_FWD" or CMD == "END_SCAN_FWD") then
		return ProcessInputCommandKey(tonumber(Properties["FAST FORWARD Mapping"]), CMD, tParams)
	elseif (CMD == "SKIP_REV" or CMD == "START_SKIP_REV" or CMD == "PULSE_SKIP_REV" or CMD == "STOP_SKIP_REV" or CMD == "END_SKIP_REV") then
		return ProcessInputCommandKey(tonumber(Properties["SKIP BACKWARD Mapping"]), CMD, tParams)
	elseif (CMD == "SKIP_FWD" or CMD == "START_SKIP_FWD" or CMD == "PULSE_SKIP_FWD" or CMD == "STOP_SKIP_FWD" or CMD == "END_SKIP_FWD") then
		return ProcessInputCommandKey(tonumber(Properties["SKIP FORWARD Mapping"]), CMD, tParams)
	
	elseif (CMD == "PLAY" or CMD == "START_PLAY" or CMD == "PULSE_PLAY" or CMD == "STOP_PLAY" or CMD == "END_PLAY") then
		return ProcessInputCommandKey(tonumber(Properties["PLAY Mapping"]), CMD, tParams)
	elseif (CMD == "PAUSE" or CMD == "START_PAUSE" or CMD == "PULSE_PAUSE" or CMD == "STOP_PAUSE" or CMD == "END_PAUSE") then
		return ProcessInputCommandKey(tonumber(Properties["PAUSE Mapping"]), CMD, tParams)
	elseif (CMD == "RECORD" or CMD == "START_RECORD" or CMD == "PULSE_RECORD" or CMD == "STOP_RECORD" or CMD == "END_RECORD") then
		return ProcessInputCommandKey(tonumber(Properties["RECORD Mapping"]), CMD, tParams)
	elseif (CMD == "STOP" or CMD == "START_STOP" or CMD == "PULSE_STOP" or CMD == "STOP_STOP" or CMD == "END_STOP") then
		return ProcessInputCommandKey(tonumber(Properties["STOP Mapping"]), CMD, tParams)
		
	elseif (CMD == "PROGRAM_A" or CMD == "START_PROGRAM_A" or CMD == "PULSE_PROGRAM_A" or CMD == "STOP_PROGRAM_A" or CMD == "END_PROGRAM_A") then
		return ProcessInputCommandKey(tonumber(Properties["RED Mapping"]), CMD, tParams)
	elseif (CMD == "PROGRAM_B" or CMD == "START_PROGRAM_B" or CMD == "PULSE_PROGRAM_B" or CMD == "STOP_PROGRAM_B" or CMD == "END_PROGRAM_B") then
		return ProcessInputCommandKey(tonumber(Properties["GREEN Mapping"]), CMD, tParams)
	elseif (CMD == "PROGRAM_C" or CMD == "START_PROGRAM_C" or CMD == "PULSE_PROGRAM_C" or CMD == "STOP_PROGRAM_C" or CMD == "END_PROGRAM_C") then
		return ProcessInputCommandKey(tonumber(Properties["YELLOW Mapping"]), CMD, tParams)
	elseif (CMD == "PROGRAM_D" or CMD == "START_PROGRAM_D" or CMD == "PULSE_PROGRAM_D" or CMD == "STOP_PROGRAM_D" or CMD == "END_PROGRAM_D") then
		return ProcessInputCommandKey(tonumber(Properties["BLUE Mapping"]), CMD, tParams)
	
	elseif (CMD == "NUMBER_1" or CMD == "START_NUMBER_1" or CMD == "PULSE_NUMBER_1" or CMD == "STOP_NUMBER_1" or CMD == "END_NUMBER_1") then
		return ProcessInputCommandKey(tonumber(Properties["1 Mapping"]), CMD, tParams)
	elseif (CMD == "NUMBER_2" or CMD == "START_NUMBER_2" or CMD == "PULSE_NUMBER_2" or CMD == "STOP_NUMBER_2" or CMD == "END_NUMBER_2") then
		return ProcessInputCommandKey(tonumber(Properties["2 Mapping"]), CMD, tParams)
	elseif (CMD == "NUMBER_3" or CMD == "START_NUMBER_3" or CMD == "PULSE_NUMBER_3" or CMD == "STOP_NUMBER_3" or CMD == "END_NUMBER_3") then
		return ProcessInputCommandKey(tonumber(Properties["3 Mapping"]), CMD, tParams)
	elseif (CMD == "NUMBER_4" or CMD == "START_NUMBER_4" or CMD == "PULSE_NUMBER_4" or CMD == "STOP_NUMBER_4" or CMD == "END_NUMBER_4") then
		return ProcessInputCommandKey(tonumber(Properties["4 Mapping"]), CMD, tParams)
	elseif (CMD == "NUMBER_5" or CMD == "START_NUMBER_5" or CMD == "PULSE_NUMBER_5" or CMD == "STOP_NUMBER_5" or CMD == "END_NUMBER_5") then
		return ProcessInputCommandKey(tonumber(Properties["5 Mapping"]), CMD, tParams)
	elseif (CMD == "NUMBER_6" or CMD == "START_NUMBER_6" or CMD == "PULSE_NUMBER_6" or CMD == "STOP_NUMBER_6" or CMD == "END_NUMBER_6") then
		return ProcessInputCommandKey(tonumber(Properties["6 Mapping"]), CMD, tParams)
	elseif (CMD == "NUMBER_7" or CMD == "START_NUMBER_7" or CMD == "PULSE_NUMBER_7" or CMD == "STOP_NUMBER_7" or CMD == "END_NUMBER_7") then
		return ProcessInputCommandKey(tonumber(Properties["7 Mapping"]), CMD, tParams)
	elseif (CMD == "NUMBER_8" or CMD == "START_NUMBER_8" or CMD == "PULSE_NUMBER_8" or CMD == "STOP_NUMBER_8" or CMD == "END_NUMBER_8") then
		return ProcessInputCommandKey(tonumber(Properties["8 Mapping"]), CMD, tParams)
	elseif (CMD == "NUMBER_9" or CMD == "START_NUMBER_9" or CMD == "PULSE_NUMBER_9" or CMD == "STOP_NUMBER_9" or CMD == "END_NUMBER_9") then
		return ProcessInputCommandKey(tonumber(Properties["9 Mapping"]), CMD, tParams)
	elseif (CMD == "NUMBER_0" or CMD == "START_NUMBER_0" or CMD == "PULSE_NUMBER_0" or CMD == "STOP_NUMBER_0" or CMD == "END_NUMBER_0") then
		return ProcessInputCommandKey(tonumber(Properties["0 Mapping"]), CMD, tParams)
		
	elseif (CMD == "STAR" or CMD == "START_STAR" or CMD == "PULSE_STAR" or CMD == "STOP_STAR" or CMD == "END_STAR") then
		return ProcessInputCommandKey(tonumber(Properties["* Mapping"]), CMD, tParams)
	elseif (CMD == "POUND" or CMD == "START_POUND" or CMD == "PULSE_POUND" or CMD == "STOP_POUND" or CMD == "END_POUND") then
		return ProcessInputCommandKey(tonumber(Properties["# Mapping"]), CMD, tParams)
	elseif (CMD == "TV_VIDEO" or CMD == "START_TV_VIDEO" or CMD == "PULSE_TV_VIDEO" or CMD == "STOP_TV_VIDEO" or CMD == "END_TV_VIDEO") then
		return ProcessInputCommandKey(tonumber(Properties["TV_VIDEO Mapping"]), CMD, tParams)
	elseif (CMD == "CLOSED_CAPTIONED" or CMD == "START_CLOSED_CAPTIONED" or CMD == "PULSE_CLOSED_CAPTIONED" or CMD == "STOP_CLOSED_CAPTIONED" or CMD == "END_CLOSED_CAPTIONED") then
		return ProcessInputCommandKey(tonumber(Properties["CLOSED_CAPTIONED Mapping"]), CMD, tParams)
	end
	return false
end

function ProcessInputCommandKey(KeyCode, CMD, tParams)
	HasBegin = false
	Debug("ProcessInputCommandKey(" .. KeyCode .. ", " .. CMD .. ")")
	if(tParams ~= nil and tParams.BEGIN ~= nil) then HasBegin = true end
	
	if(KeyCode >= 501 and KeyCode <= 520) then
		--Launch App
		local URL = Properties["Launch App URL " .. (KeyCode - 500)]
		if(URL ~= "") then
			SendURL(URL)
		end
	elseif(KeyCode >= 601 and KeyCode <= 620) then
		--Fire Event
		C4:FireEventByID(KeyCode)
	end
	
	if(HasBegin) then
		Debug("Input Command HAS A Begin Param.")
		
		if(CMD:find("PULSE_")) then
			SendKey(KeyCode)
		else
			SendKey_PRESS(KeyCode)
		end
	else
		Debug("Input Command DOES NOT HAVE Begin Param.")
		if(CMD:find("STOP_") or CMD:find("END_")) then
			SendKey_RELEASE(KeyCode)
		elseif(CMD:find("START_")) then
			SendKey_PRESS(KeyCode)
		else
			SendKey(KeyCode)
		end
	end
	
	return true
end



function OnConnectionStatusChanged(BindingID, nPort, strStatus)
	print("Connection Status Changed: " .. strStatus)
	if (strStatus == "ONLINE") then
		if(nPort == 6467) then
			Pairing_SendRequest()
		end
		local mac = C4:GetDeviceMAC (6001)
		C4:UpdateProperty("Mac Address", mac)
	end
	if(nPort == 6466) then
			C4:UpdateProperty("Connection", strStatus)
	end
end


local MessageBuffer = ""
function ReceivedFromNetwork(BindingID, nPort, strData)
	MessageBuffer = MessageBuffer .. strData
	local MessageSize = MessageBuffer:byte(1)
	
	if(#MessageBuffer > MessageSize) then -- Check Buffer For Completed Message
		local Message = MessageBuffer:sub(2, MessageSize+1)
		ProcessNetworkMessage(Message)
	
		MessageBuffer = MessageBuffer:sub(MessageSize+2)
	end
end






function ProcessNetworkMessage(Message)
	local WireMessage = DecodeWire(Message, 1)
	local FingerPrint = GetWireMessageFingerPrint(WireMessage)
	
	if(FingerPrint ~= "[F8][F1][WT0][F2][WT0]") then -- DO NOT DEBUG PING / PONG
		DebugHeader("Processing Message (" .. #Message .. "):" .. GetHexString(Message))
		
		DebugWireMessage(WireMessage)
		Debug("Message FingerPrint: " .. FingerPrint)
	end
		
	if(FingerPrint == "[F8][F1][WT0][F2][WT0]") then -- Ping Request
		local PingRequestNumber = WireMessage[8][1].Value
		SendWireCommand({[9]={[1]={ID=1, WireType=WireType_VarInt, Value=PingRequestNumber}}})
		
	elseif(FingerPrint == "[F20][F1][F12][WT2]") then
		Debug("CURRENT APP")
		local CurrentApp = WireMessage[20][1][12].Value
		Debug("Current App: " .. CurrentApp)
		C4:UpdateProperty("Current App", CurrentApp)
		C4:SetVariable("CURRENT_APP", CurrentApp)
		C4:FireEventByID(EventID_CurrentAppChanged) -- CurrentAppChanged
		
	elseif(FingerPrint == "[F1][F1][WT0][F2][F1][WT2][F2][WT2][F3][WT0][F4][WT2][F5][WT2][F6][WT2]") then
		Debug("DEVICE DESCRIPTOR")
		C4:UpdateProperty("Model Name",						WireMessage[1][2][1].Value)
		C4:UpdateProperty("Vendor Name",					WireMessage[1][2][2].Value)
		C4:UpdateProperty("Device Version",				WireMessage[1][2][4].Value)
		C4:UpdateProperty("Device Package Name",	WireMessage[1][2][5].Value)
		C4:UpdateProperty("Device App Version",		WireMessage[1][2][6].Value)
		SendDriverDescriptorPayload()
	elseif(FingerPrint == "[F50][F1][WT0][F2][WT0][F3][WT2][F4][WT0]") then
		Debug("PLAYER NAME & VOLUME LEVEL")
		
	elseif(FingerPrint == "[F40][F1][WT0]") then
		Debug("DEVICE STATUS")
		if(WireMessage[40][1].Value == 1) then
			C4:UpdateProperty("Power Status", "ON")
		else
			C4:UpdateProperty("Power Status", "OFF")
		end
		
	elseif(FingerPrint == "[F1][WT0][F2][WT0][F11][WT2]") then
		Debug("1st PAIRING RESPONSE - IGNORE FOR NOW")
	elseif(FingerPrint == "[F1][WT0][F2][WT0][F20][F2][WT2][F3][WT0]") then
		Debug("2nd PAIRING RESPONSE - IGNORE FOR NOW")
	elseif(FingerPrint == "[F1][WT0][F2][WT0][F31][WT2]") then
		Debug("3rd PAIRING RESPONSE - IGNORE FOR NOW")
	elseif(FingerPrint == "[F1][WT0][F2][WT0][F41][F1][F1765][WT2][F15][WT3][F191414][WT4][F188][WT4][F439][WT0][F14][WT0]") then
		Debug("FINAL PAIRING RESPONSE - IGNORE FOR NOW")
	elseif(FingerPrint == "[F1][WT0][F2][WT0][F41][F1][WT2]") then
		Debug("FINAL PAIRING RESPONSE - IGNORE FOR NOW")
				
	elseif(FingerPrint == "[F2][WT2]") then
		Debug("OK? SEND SECOND CONFIGURATION MESSAGE")
		--Second Configuration Message??
		SendWireCommand({[2]={[1]={ID=1, WireType=WireType_VarInt, Value=622}}})
	else
		DebugDivider("#")
		Debug("")
		DebugHeader("UNHANDLED FINGERPRINT: " .. FingerPrint)
		Debug("")
		DebugDivider("#")
	end
end



function SendWireCommand(WireMessage)
	SendCommandWithSize(EncodeWire(WireMessage))
end

function SendCommandWithSize(Payload)
	local WireMessage = DecodeWire(Payload, 1)
	local FingerPrint = GetWireMessageFingerPrint(WireMessage)
	
	if(FingerPrint ~= "[F9][F1][WT0]") then
		DebugHeader("Sending Command (" .. #Payload .. ") HEX: " .. GetHexString(Payload))
		DebugWireMessage(WireMessage)
	end
	C4:SendToNetwork(6001, 6466, string.char(#Payload));
	C4:SendToNetwork(6001, 6466, Payload);
end




function SendKey(KeyCode)										SendKeyType(KeyCode, KEY_SEND)										end
function SendKey_PRESS(KeyCode)							SendKeyType(KeyCode, KEY_PRESS)										end
function SendKey_RELEASE(KeyCode)						SendKeyType(KeyCode, KEY_RELEASE)									end
function SendKey_PRESS_AND_RELEASE(KeyCode)	SendKey_PRESS(KeyCode)	SendKey_RELEASE(KeyCode)	end

function SendKeyType(KeyCode, SendType)
	Debug("Sending " .. KeyCode .. " (" .. SendType .. ")")
	SendWireCommand({
									[10]={
												[1]={ID=1, WireType=WireType_VarInt, Value=KeyCode},
												[2]={ID=2, WireType=WireType_VarInt, Value=SendType}
											}
									})
end

function SendURL(URL)
	Debug("Sending URL (" .. URL .. ")")
	SendWireCommand({
									[90]={[1]={ID=1, WireType=WireType_String, Value=URL}}
									})
end











function SendDriverDescriptorPayload()
	Debug("Sending Driver Descriptor...")
	SendWireCommand({ 
										[1] = { 
													[1] = { ID = 1, WireType = 0, Value = 622},
													[2] = { 
																[3] = { ID = 3, WireType = 0, Value = 1},
																[6] = { ID = 6, Value = DriverVersion, WireType = 2},
																[4] = { ID = 4, Value = "1", WireType = 2},
																[5] = { ID = 5, Value = "androidtv.control4.gmsoftware", WireType = 2},
																}
													}
									})
end

--[[ ACTIONS ]]--
function LUA_ACTION.BeginPair(tQueryParams)
	BeginPair(tQueryParams)
end

function LUA_ACTION.FinishPair(tQueryParams)
	FinishPair(tQueryParams)
end


function LUA_ACTION.ConnectToCommand(tQueryParams)
	Debug("Connecting To Command Interface...")
	C4:NetConnect(6001, 6466)
end

function LUA_ACTION.DisconnectFromCommand(tQueryParams)
	Debug("Disconnecting From Command Interface...")
	C4:NetDisconnect(6001, 6466)
end


function LUA_ACTION.TestURL(tQueryParams)
	local CommandURL = tQueryParams.URL;
	print("Sending URL (" .. CommandURL .. ")...")
	SendURL(CommandURL)
end

function LUA_ACTION.TestKeyCodeSend(tQueryParams)
	print("Sending KeyCode (" .. tQueryParams.KeyCode .. ")...")
	SendKey(tonumber(tQueryParams.KeyCode))
end

function LUA_ACTION.TestKeyCodePressThenRelease(tQueryParams)
	print("Sending KeyCode Press Then Release (" .. tQueryParams.KeyCode .. ")...")
	SendKey_PRESS_AND_RELEASE(tonumber(tQueryParams.KeyCode))
end

function LUA_ACTION.SendWOL(tQueryParams)
	print("Sending Magic Packet...")
	SendMagicPacket()
	
end


function SendMagicPacket()
	print("Sending Magic Packet...")
	-- Get MacAddress from Properties
	local MacAddress = Properties["Mac Address"]
	if (MacAddress ~= "?") then
		-- replace : with "" in mac address
		local mac = string.gsub(MacAddress, ":", "")
		Debug("Sending Magic Packet to " .. mac)
		C4:SendWOL(mac)
	end
end

function GetPrivateKeyPassword(Binding, Port)
	--Open Source, Key is not secret, might look into generating a self signed certificate in driver
	return 'password'
end

C4:UpdateProperty("Driver Version", DriverVersion)
Debug("Driver Loaded...")

if(string.len(Properties["Device Public Key Modulus"]) > 0) then
	LUA_ACTION.ConnectToCommand(nil)
end

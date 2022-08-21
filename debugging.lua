--[DEBUGGING HELPER FUNCTIONS]--
DebugTimerID	= 0
DebugPrint		= false

function StartDebugTimer()
	if (DebugTimerID ~= 0) then
		DebugTimerID = C4:KillTimer(DebugTimerID)
	end
		DebugTimerID = C4:AddTimer(120, "MINUTES")
end


function DebugLevel(DebugText, Level)
	Debug(string.rep("	", Level) .. DebugText)
end

function Debug(DebugText)
	if (DebugPrint) then
		if type(DebugText) == 'table' then
			DebugTable(DebugText)
		else
			print(DebugText) 
		end
	end
end

function DebugWireMessage(WireMessage)
	if (DebugPrint) then
		print(PrintWireMessage(WireMessage, 0))
	end
end

function PrintWireMessage(tbl, indent)
  if not indent then indent = 0 end
  local toprint = "{ "
  indent = indent + 2 
	local HasWireType = false
  for k, v in pairs(tbl) do
    if (type(k) == "number") then
      toprint = toprint .. "\n" .. string.rep(" ", indent) .. "[" .. k .. "] = "
    elseif (type(k) == "string") then
      toprint = toprint  .. k ..  " = "   
			if(k == "WireType") then
				HasWireType = true
			end
    end
    if (type(v) == "number") then
      toprint = toprint .. v .. ", "
    elseif (type(v) == "string") then
      toprint = toprint .. "\"" .. v .. "\", "
    elseif (type(v) == "table") then
      toprint = toprint .. PrintWireMessage(v, indent) .. " "
    else
      toprint = toprint .. "\"" .. tostring(v) .. "\", "
    end
  end
	if(HasWireType) then
		toprint = toprint:sub(1, #toprint - 2) .. "}"
	else
		toprint = toprint .. "\n" .. string.rep(" ", indent-2) .. "}"
	end
  return toprint
end

function DebugTable(DebugT)
	--print("@@@@@@@@@@@@@@@@@@@@@")
	print(C4:JsonEncode(DebugT, true, true))
	--local s = '{ '
	--for k,v in pairs(o) do
	--if type(k) ~= 'number' then k = '"'..k..'"' end
		  --s = s .. '['..k..'] = ' .. dump(v) .. ','
	--end
	--return s .. '} '
end

function DebugHeader(DebugText)
	if (DebugPrint) then
		local BorderLen = 2
		local TextLen = DebugText:len()
		print(string.rep("-", TextLen + (BorderLen * 2)))
		print("| " .. DebugText .. " |")
		print(string.rep("-", TextLen + (BorderLen * 2)))
	end
end

function DebugDivider(DividerChar)
	if (DebugPrint) then
		print(string.rep(DividerChar, 50))
	end
end

AlreadyExported = ""
-- Generates LUA thay can be pasted in another instance to copy configuration
-- The device specific (Public Key & Exponent) are commented out by default
function BackupConfiguration()
	AlreadyExported = ""
	
	print("--[[ BEGIN CONFIGURATION BACKUP ]]--")
	print("-- Vendor:		" .. Properties["Vendor Name"])
	print("-- Model:		" .. Properties["Model Name"])
	print("-- Version:		" .. Properties["Device Version"])
	
	print("-----------------------------")
	print("-- Launch App URLs")
	print("-----------------------------")
	for App = 1, 20, 1
	do
		BackupProperty("Launch App URL " .. App)
	end
	
	print("-----------------------------")
	print("-- Key Mappings")
	print("-----------------------------")
	BackupProperty("GUIDE Mapping")
	BackupProperty("INFO Mapping")
	BackupProperty("MENU Mapping")
	BackupProperty("DVR Mapping")
	
	BackupProperty("UP Mapping")
	BackupProperty("DOWN Mapping")
	BackupProperty("LEFT Mapping")
	BackupProperty("RIGHT Mapping")
	BackupProperty("ENTER Mapping")
	BackupProperty("CANCEL Mapping")
		
	BackupProperty("CUSTOM_1 Mapping")
	BackupProperty("CUSTOM_2 Mapping")
	BackupProperty("CUSTOM_3 Mapping")
	
	BackupProperty("PREVIOUS CHANNEL Mapping")
	BackupProperty("CHANNEL UP Mapping")
	BackupProperty("CHANNEL DOWN Mapping")

	BackupProperty("PAUSE_ROOM_OFF Mapping")
	
	BackupProperty("RECORD Mapping")
	BackupProperty("REWIND Mapping")
	BackupProperty("FAST FORWARD Mapping")
	BackupProperty("SKIP BACKWARD Mapping")
	BackupProperty("SKIP FORWARD Mapping")

	BackupProperty("PLAY Mapping")
	BackupProperty("PAUSE Mapping")
	BackupProperty("STOP Mapping")
	
	BackupProperty("RED Mapping")
	BackupProperty("GREEN Mapping")
	BackupProperty("YELLOW Mapping")
	BackupProperty("BLUE Mapping")

	BackupProperty("PAGE UP Mapping")
	BackupProperty("PAGE DOWN Mapping")
	
	BackupProperty("1 Mapping")
	BackupProperty("2 Mapping")
	BackupProperty("3 Mapping")
	BackupProperty("4 Mapping")
	BackupProperty("5 Mapping")
	BackupProperty("6 Mapping")
	BackupProperty("7 Mapping")
	BackupProperty("8 Mapping")
	BackupProperty("9 Mapping")
	BackupProperty("* Mapping")
	BackupProperty("0 Mapping")
	BackupProperty("# Mapping")
	
	for k, v in pairs(Properties) do
		if(k:find("Mapping")) then
			BackupProperty(k)
		end
	end
	
	print("-----------------------------")
	print("-- Other Settings")
	print("-----------------------------")
	for k, v in pairs(Properties) do
		repeat
			if(k == "Power Status")					then break end
			if(k == "Debug Mode")						then break end
			if(k == "Connection")						then break end
			if(k == "MAC Address")					then break end
			if(k == "Current App")					then break end
			if(k == "Device App Version")		then break end
			if(k == "Device Version")				then break end
			if(k == "Device Package Name")	then break end
			if(k == "Model Name")						then break end
			if(k == "Driver Version")				then break end
			if(k == "Vendor Name")					then break end
			if(k:find("Header"))						then break end
			if(k:find("Public Key"))				then break end
			
			BackupProperty(k)
			
		until true
	end
	
	print("-----------------------------")
	print("-- Device Specific Properties")
	print("-----------------------------")
	for k, v in pairs(Properties) do
		if(k:find("Public Key")) then
			BackupProperty(k)
		end
	end
	
	print("--[[ END CONFIGURATION BACKUP ]]--")
end

function BackupProperty(k)
	local v = Properties[k]
	local BackupLine = ""
	
	if(k:find("Device Public Key")) then BackupLine = "--" end
	
	if (type(v) == "number") then
		BackupLine = BackupLine .. "C4:UpdateProperty(\"" .. k .. "\", " .. Properties[k] .. ")"
	elseif (type(v) == "string") then
		if(v ~= nil and v~="") then
			BackupLine = BackupLine .. "C4:UpdateProperty(\"" .. k .. "\", \"" .. Properties[k] .. "\")"
		end
	end
	local ExportCheck = "<" .. k:gsub("%*", "STAR") .. ">"
	if(BackupLine ~= "" and AlreadyExported:find(ExportCheck) == nil) then
		AlreadyExported = AlreadyExported .. ExportCheck
		print(BackupLine)
	end
end
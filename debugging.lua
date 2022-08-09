--[DEBUGGING HELPER FUNCTIONS]--
DebugTimerID	= 0
DebugPrint		= false

function StartDebugTimer()
	if (g_DebugTimer) then
		g_DebugTimer = C4:KillTimer(g_DebugTimer)
	end
	g_DebugTimer = C4:AddTimer(120, "MINUTES")
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

-- Generates LUA thay can be pasted in another instance to copy configuration
-- The device specific (Public Key & Exponent) are commented out by default
function BackupConfiguration()
	for k, v in pairs(Properties) do
		repeat
			if(k == "Power Status")					then break end
			if(k == "Debug Mode")						then break end
			if(k == "Connection")						then break end
			if(k == "Current App")					then break end
			if(k == "Device App Version")		then break end
			if(k == "Device Package Name")	then break end
			if(k == "Model Name")						then break end
			if(k == "Driver Version")				then break end
			if(k == "Vendor Name")					then break end
			if(k:find("Header"))						then break end

			local PropertySetLine = ""
			if(k:find("Device Public Key")) then PropertySetLine = "--" end

			if (type(v) == "number") then
				PropertySetLine = PropertySetLine .. "C4:UpdateProperty(\"" .. k .. "\", " .. Properties[k] .. ")"
			elseif (type(v) == "string") then
				if(v ~= nil and v~="") then
					PropertySetLine = PropertySetLine .. "C4:UpdateProperty(\"" .. k .. "\", \"" .. Properties[k] .. "\")"
				end
			end
			
			if(PropertySetLine ~= "") then
					 print(PropertySetLine)
			end
		until true
	end
end
--[[
  [] Author: Martynas Petuska
  [] E-mail: martynas.petuska@outlook.com
  [] Date:   January 2018
--]]

---Splits the string by the given separator and returns them as vararg.
---@param str string
---@param sep string
---@return ...
function split(str, sep)
	local fields = {}
	
	local sep = sep or " "
	local pattern = string.format("([^%s]+)", sep)
	string.gsub(str, pattern, function(c)
		fields[#fields + 1] = c
	end)
	
	return unpack(fields)
end

---Prints the given arguments separated by space to the chat tab.
---@param ... any
---@return void
function ADDON:Print(...)
	local name = ADDON.Settings.Defaults.addonName;
	local hex = ADDON.Settings.Defaults.Theme.hex;
	local prefix = string.format("|c%s%s: |r", string.upper(hex), name);
	CHAT_SYSTEM:AddMessage(prefix .. table.concat({ ... }, " "));
end

---Prints a blank line.
---@param ... void
---@return void
function ADDON.Println()
	CHAT_SYSTEM:AddMessage(" ");
end
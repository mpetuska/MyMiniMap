--[[
  [] Author: Martynas Petuska
  [] E-mail: martynas.petuska@outlook.com
  [] Date:   January 2018
--]]
---------------- NAMESPACE ----------------
-------------------------------------------

ADDON.PinTextures = {
	GeneralPins = {
		playerPointer = "esoui/art/icons/mapkey/mapkey_player.dds",
		wayshrineComplete = "esoui/art/icons/poi/poi_wayshrine_complete.dds",
		wayshrineIncomplete = "esoui/art/icons/poi/poi_wayshrine_incomplete.dds"
	},
	QuestPins = {
		Unrepeatable = {
			area = "esoui/art/compass/quest_areapin.dds",
			areaAssisted = "esoui/art/compass/quest_assistedareapin.dds",
			available = "esoui/art/compass/quest_available_icon.dds",
			icon = "esoui/art/compass/quest_icon.dds",
			iconAssisted = "esoui/art/compass/quest_icon_assisted.dds",
			iconDoor = "esoui/art/compass/quest_icon_door.dds",
			iconDoorAssisted = "esoui/art/compass/quest_icon_door_assisted.dds"
		},
		Repeatable = {
			area = "esoui/art/compass/repeatablequest_areapin.dds",
			areaAssisted = "esoui/art/compass/repeatablequest_assistedareapin.dds",
			available = "esoui/art/compass/repeatablequest_available_icon.dds",
			icon = "esoui/art/compass/repeatablequest_icon.dds",
			iconAssisted = "esoui/art/compass/repeatablequest_icon_assisted.dds",
			iconDoor = "esoui/art/compass/repeatablequest_icon_door.dds",
			iconDoorAssisted = "esoui/art/compass/repeatablequest_icon_door_assisted.dds"
		}
	}
}

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
	local name = ADDON.Settings.addonName;
	local hex = ADDON.Settings.Theme.hex;
	local prefix = string.format("|c%s%s: |r", string.upper(hex), name);
	CHAT_SYSTEM:AddMessage(prefix .. table.concat({ ... }, " "));
end

---Prints a blank line.
---@param ... void
---@return void
function ADDON.Println()
	CHAT_SYSTEM:AddMessage(" ");
end

---Copies the table recursively.
---@param original table
---@return table
function table.copy(original)
	local copy;
	if type(original) == 'table' then
		copy = {};
		for orig_key, orig_value in next, original, nil do
			copy[table.copy(orig_key)] = table.copy(orig_value);
		end
		setmetatable(copy, table.copy(getmetatable(original)));
	else
		-- number, string, boolean, etc
		copy = original;
	end
	return copy;
end

---Recursively compares two tables for equality.
---@param table1 table
---@param table2 table
---@return boolean
function table.compare(table1, table2)
	if (type(table1) ~= "table" or type(table2) ~= "table") then
		return false;
	end
	
	for key, value in pairs(table1) do
		if (type(value) == "table") then
			return table.compare(table1[key], table2[key]);
		elseif (value ~= table2[key]) then
			return false;
		end
		return true;
	end
end

function table.contains(table, element)
	for _, value in pairs(table) do
		if (value == element) then
			return true;
		end
	end
	return false;
end
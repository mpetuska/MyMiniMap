--[[
  [] Author: Martynas Petuska
  [] E-mail: martynas.petuska@outlook.com
  [] Date:   January 2018
--]]

ADDON.TextureList = {
	GeneralPins = {
		playerPointer = "esoui/art/icons/mapkey/mapkey_player.dds",
		wayshrine = "esoui/art/icons/mapkey/mapkey_wayshrine.dds"
	},
	QuestPins = {
		Assisted = {
			condition = "EsoUI/Art/Compass/quest_icon_assisted.dds",
			optionalCondition = "EsoUI/Art/Compass/quest_icon_assisted.dds",
			ending = "EsoUI/Art/Compass/quest_icon_assisted.dds"
		},
		Tracked = {
			condition = "EsoUI/Art/Compass/quest_icon.dds",
			optionalCondition = "EsoUI/Art/Compass/quest_icon.dds",
			ending = "EsoUI/Art/Compass/quest_icon.dds"
		},
		Repeatable = {
			condition = "EsoUI/Art/Compass/quest_icon_assisted.dds",
			optionalCondition = "EsoUI/Art/Compass/quest_icon_assisted.dds",
			ending = "EsoUI/Art/Compass/quest_icon_assisted.dds"
		},
		RepeatableTracked = {
			condition = "EsoUI/Art/Compass/quest_icon.dds",
			optionalCondition = "EsoUI/Art/Compass/quest_icon.dds",
			ending = "EsoUI/Art/Compass/quest_icon.dds"
		},
		questOfferRepeatable = "EsoUI/Art/Compass/quest_icon.dds"
	},
	QuestDoorPins = {
		Assisted = {
			condition = "EsoUI/Art/Compass/quest_icon_door_assisted.dds",
			optionalCondition = "EsoUI/Art/Compass/quest_icon_door_assisted.dds",
			ending = "EsoUI/Art/Compass/quest_icon_door_assisted.dds"
		},
		Tracked = {
			condition = "EsoUI/Art/Compass/quest_icon_door.dds",
			optionalCondition = "EsoUI/Art/Compass/quest_icon_door.dds",
			ending = "EsoUI/Art/Compass/quest_icon_door.dds"
		},
		Repeatable = {
			condition = "EsoUI/Art/Compass/quest_icon_door_assisted.dds",
			optionalCondition = "EsoUI/Art/Compass/quest_icon_door_assisted.dds",
			ending = "EsoUI/Art/Compass/quest_icon_door_assisted.dds"
		},
		RepeatableTracked = {
			condition = "EsoUI/Art/Compass/quest_icon_door.dds",
			optionalCondition = "EsoUI/Art/Compass/quest_icon_door.dds",
			ending = "EsoUI/Art/Compass/quest_icon_door.dds"
		},
		questOfferRepeatable = "EsoUI/Art/Compass/quest_icon_door.dds"
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

function ADDON:ScheduleSettingsUpdate()
	ADDON.settingsUpdatePending = true;
end
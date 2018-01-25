--[[
  [] Author: Martynas Petuska
  [] E-mail: martynas.petuska@outlook.com
  [] Date:   January 2018
--]]
---------------- NAMESPACE ----------------
-------------------------------------------

ADDON.Commands = {
	help = function()
		ADDON:Print("List of slash commands:");
		ADDON:Print("[toggle] Shows/hides the minimap.");
		ADDON:Print("[reset] Resets the default settings.");
		ADDON:Print("[update] Toggles the minimap updates.");
		ADDON:Print("[size <size>] Sets the size of the minimap.");
		ADDON:Print("[mode <camera | player>] Sets the minimap's mode.");
		ADDON:Print("[rotation <on | off>] Sets the minimap's rotation mode.");
	end,
	example = {
		test = function(...)
			ADDON:Print("My Value:", ...);
		end
	},
	toggle = function()
		ADDON.Settings.isMiniMapHidden = not ADDON.Settings.isMiniMapHidden;
		ADDON:ScheduleSettingsUpdate();
	end,
	reset = function()
		ADDON.Settings = ADDON.DefaultSettings;
		ADDON.UI:ConfigureUI();
		ADDON:ScheduleSettingsUpdate();
		ADDON:Print("Addon settings reset.")
	end,
	update = function()
		ADDON.Settings.isUpdateEnabled = not ADDON.Settings.isUpdateEnabled;
		ADDON:ScheduleSettingsUpdate();
		if (ADDON.Settings.isUpdateEnabled) then
			ADDON:Print("UI Update is enabled.")
		else
			ADDON:Print("UI Update is disabled.")
		end
	end,
	size = function(size)
		if (type(size) == "number") then
			ADDON.Settings.MiniMap.size = size;
		else
			ADDON.Println()
			ADDON:Print("Invalid command argument!")
			ADDON.Commands.help();
			return;
		end
		ADDON:ScheduleSettingsUpdate();
		ADDON:Print("Size updated to", size);
	end,
	mode = function(mode)
		if (mode == "camera") then
			ADDON.Settings.isInCameraMode = true;
		elseif (mode == "player") then
			ADDON.Settings.isInCameraMode = false;
		else
			ADDON.Println()
			ADDON:Print("Invalid command argument!")
			ADDON.Commands.help();
			return;
		end
		ADDON:ScheduleSettingsUpdate();
		ADDON:Print("Minimap set to rotate with", mode);
	end,
	rotation = function(isEnabled)
		if (isEnabled == "on") then
			ADDON.Settings.isMapRotationEnabled = true;
		elseif (isEnabled == "off") then
			ADDON.Settings.isMapRotationEnabled = false;
		else
			ADDON.Println()
			ADDON:Print("Invalid command argument!")
			ADDON.Commands.help();
			return;
		end
		ADDON:ScheduleSettingsUpdate();
		ADDON:Print("Minimap's rotation is", isEnabled);
	end
}

function ADDON.HandleSlashCommands(str)
	if (#str == 0) then
		ADDON.Commands.help();
		return;
	end
	
	-- Parse arguments --
	local args = {};
	for _, arg in pairs({ split(str, " ") }) do
		if (#arg > 0) then
			table.insert(args, arg);
		end
	end
	
	local path = ADDON.Commands;
	
	for id, arg in ipairs(args) do
		arg = string.lower(arg);
		
		if (path[arg]) then
			if (type(path[arg]) == "function") then
				path[arg](select(id + 1, unpack(args)));
				return
			elseif (type(path[arg]) == "table") then
				path = path[arg];
			else
				ADDON.Println()
				ADDON:Print("Unrecognised command!")
				ADDON.Commands.help();
				return
			end
		else
			ADDON.Println()
			ADDON:Print("Unrecognised command!")
			ADDON.Commands.help()
			return
		end
	end
end

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
		ADDON:Print("[size <size>] Sets the size of the minimap.");
		ADDON:Print("[rotation <on | off>] Sets the minimap's rotation mode.");
	end,
	example = {
		test = function(...)
			ADDON:Print("My Value:", ...);
		end
	},
	toggle = function()
		ADDON.UI.miniMap:SetHidden(not ADDON.UI.miniMap:IsHidden());
	end,
	reset = function()
		ADDON.Settings = ADDON.DefaultSettings;
		ADDON.UI:ConfigureUI();
		ADDON:Print("Addon settings reset.")
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
		ADDON:Print("Size updated to", size);
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
		ADDON.UI.playerPin:SetTextureRotation(0);
		ADDON.UI.wheel:SetTextureRotation(0);
		ADDON.UI.UpdateMap();
		ADDON:Print("Minimap's rotation is", isEnabled);
	end
}

--- Handles a given command string redirrecting to an appropriate function in the ADDON.Commands table.
---@param str string
---@return void
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

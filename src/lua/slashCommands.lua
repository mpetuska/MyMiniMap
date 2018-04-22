--[[
  [] Author: Martynas Petuska
  [] E-mail: martynas.petuska@outlook.com
  [] Date:   January 2018
--]]
---------------- NAMESPACE ----------------
-------------------------------------------

MMM.Commands = {
	help = function()
		MMM:Print("List of slash commands:");
		--MMM:Print("[reset] Resets the default settings.");
		--MMM:Print("[size <size>] Sets the size of the minimap.");
		MMM:Print("[rotation <on | off>] Sets the minimap's rotation mode.");
	end,
	--example = {
	--	test = function(...)
	--		MMM:Print("My Value:", ...);
	--	end
	--},
	--reset = function()
	--	MMM.Settings = MMM.DefaultSettings;
	--	MMM.UI.ConfigureUI();
	--	MMM:Print("Addon settings reset.")
	--end,
	--size = function(size)
	--	size = tonumber(size);
	--	if (type(size) == "number") then
	--		MMM.Settings.MiniMap.size = size;
	--		MMM.UI.wheel:SetDimensions(size, size);
	--	else
	--		MMM.Println()
	--		MMM:Print("Invalid command argument!")
	--		MMM.Commands.help();
	--		return;
	--	end
	--	MMM:Print("Size updated to", size);
	--end,
	rotation = function(isEnabled)
		if (isEnabled == "on") then
			MMM.Settings.isMapRotationEnabled = true;
		elseif (isEnabled == "off") then
			MMM.Settings.isMapRotationEnabled = false;
		else
			MMM.Println()
			MMM:Print("Invalid command argument!")
			MMM.Commands.help();
			return;
		end
		MMM.UI.playerPin:SetTextureRotation(0);
		MMM.UI.wheel:SetTextureRotation(0);
		MMM.UpdateInfo.updatePending = true;
		MMM.UI.UpdateMap();
		MMM:Print("Minimap's rotation is ", isEnabled);
	end
}

--- Handles a given command string redirecting to an appropriate function in the MMM.Commands table.
---@param str string
---@return void
function MMM.HandleSlashCommands(str)
	if (#str == 0) then
		MMM.Commands.help();
		return;
	end
	
	-- Parse arguments --
	local args = {};
	for _, arg in pairs({ MMM.split(str, " ") }) do
		if (#arg > 0) then
			table.insert(args, arg);
		end
	end
	
	local path = MMM.Commands;
	
	for id, arg in ipairs(args) do
		arg = string.lower(arg);
		
		if (path[arg]) then
			if (type(path[arg]) == "function") then
				path[arg](select(id + 1, unpack(args)));
				return
			elseif (type(path[arg]) == "table") then
				path = path[arg];
			else
				MMM.Println()
				MMM:Print("Unrecognised command!")
				MMM.Commands.help();
				return
			end
		else
			MMM.Println()
			MMM:Print("Unrecognised command!")
			MMM.Commands.help()
			return
		end
	end
end

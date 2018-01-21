--[[
  [] Author: Martynas Petuska
  [] E-mail: martynas.petuska@outlook.com
  [] Date:   January 2018
--]]
ADDON.Commands = {
	help = function()
		ADDON:Print("List of slash commands:");
		ADDON:Print("TODO");
	end,
	example = {
		test = function(...)
			ADDON:Print("My Value:", ...);
		end
	},
	t = function(...)
		ADDON.UI.Maps.horizontal:SetHidden(not ADDON.UI.Maps.horizontal:IsHidden());
		ADDON.UI.Maps.vertical:SetHidden(not ADDON.UI.Maps.vertical:IsHidden());
	end,
	toggle = function()
		ADDON.Settings.isMinimapHidden = not ADDON.Settings.isMinimapHidden
		OnUiUpdate()
	end,
	reset = function()
		ADDON.Settings = ADDON.DefaultSettings
	end,
	update = function()
		ADDON.Settings.isUpdateEnabled = not ADDON.Settings.isUpdateEnabled;
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

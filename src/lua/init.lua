--[[
  [] Author: Martynas Petuska
  [] E-mail: martynas.petuska@outlook.com
  [] Date:   January 2018
--]]
local EventHandlers = ADDON.EventHandlers

local function LoadSavedVariables()
	for k, _ in pairs(ADDON.Settings.SavedVariables) do
		ADDON.Settings.SavedVariables[k] = ZO_SavedVars:New(k, 1, nil, ADDON.Settings.Defaults.SavedVariables[k] or {})
	end
end

function EventHandlers.OnAddonLoaded(event, addonName)
	if addonName ~= ADDON.name then
		return
	else
		EVENT_MANAGER:UnregisterForEvent(ADDON.name, EVENT_ADD_ON_LOADED)
	end
	
	SLASH_COMMANDS["/mmm"] = ADDON.HandleSlashCommands
	SLASH_COMMANDS["/test"] = function(args)
		ADDON:Print(split(args, " "))
	end
	
	LoadSavedVariables()
end

EVENT_MANAGER:RegisterForEvent(ADDON.name, EVENT_ADD_ON_LOADED, EventHandlers.OnAddonLoaded)
--[[
  [] Author: Martynas Petuska
  [] E-mail: martynas.petuska@outlook.com
  [] Date:   January 2018
--]]
local EventHandlers = ADDON.EventHandlers
local Settings = ADDON.Settings

local function LoadSavedVariables()
	ADDON.Settings = ZO_SavedVars:New("Settings", 2, nil, ADDON.DefaultSettings or {})
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
	ADDON.UI:ConfigureUI()
	EVENT_MANAGER:RegisterForUpdate("MyMiniMap", 1, EventHandlers.OnUiUpdate)
end

EVENT_MANAGER:RegisterForEvent(ADDON.name, EVENT_ADD_ON_LOADED, EventHandlers.OnAddonLoaded)
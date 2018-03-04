--[[
  [] Author: Martynas Petuska
  [] E-mail: martynas.petuska@outlook.com
  [] Date:   January 2018
--]]
---------------- NAMESPACE ----------------
local EventHandlers = ADDON.EventHandlers
-------------------------------------------

--- Creates or loads all of the saved variables from previous sessions.
---@return void
local function LoadSavedVariables()
	ADDON.Settings = ZO_SavedVars:New("Settings", 0, nil, ADDON.DefaultSettings or {})
end

--- Registers handler functions for events.
---@return void
local function RegisterEvents()
end

local function RegisterUpdates()
	EVENT_MANAGER:RegisterForUpdate(ADDON.Settings.addonName .. "_UiUpdate", 1, EventHandlers.OnUiUpdate);
end

--- Initialises the addon.
---@return void
function EventHandlers.OnAddonLoaded(event, addonName)
	if addonName ~= ADDON.name then
		return
	else
		EVENT_MANAGER:UnregisterForEvent(ADDON.name, EVENT_ADD_ON_LOADED)
	end
	LoadSavedVariables()
	
	SLASH_COMMANDS["/mmm"] = ADDON.HandleSlashCommands;
	ADDON.UI:Setup();
	RegisterEvents();
	RegisterUpdates();
	
	if (ADDON.Settings.MiniMap.Position.x == nil) then
		ADDON.Settings.MiniMap.Position.x, ADDON.Settings.MiniMap.Position.y = ADDON.UI.miniMap:GetCenter();
	end
end

EVENT_MANAGER:RegisterForEvent(ADDON.name, EVENT_ADD_ON_LOADED, EventHandlers.OnAddonLoaded);
--[[
  [] Author: Martynas Petuska
  [] E-mail: martynas.petuska@outlook.com
  [] Date:   January 2018
--]]
---------------- NAMESPACE ----------------
local EventHandlers = ADDON.EventHandlers
-------------------------------------------

local function LoadSavedVariables()
	ADDON.Settings = ZO_SavedVars:New("Settings", 1, nil, ADDON.DefaultSettings or {})
end

local function RegisterEvents()
end

local function RegisterUpdates()
	EVENT_MANAGER:RegisterForUpdate(ADDON.Settings.addonName .. "_UiUpdate", 2, EventHandlers.OnUiUpdate);
	EVENT_MANAGER:RegisterForUpdate(ADDON.Settings.addonName .. "_SettingsUpdate", 50, EventHandlers.OnSettingsUpdate);
end

function EventHandlers.OnAddonLoaded(event, addonName)
	if addonName ~= ADDON.name then
		return
	else
		EVENT_MANAGER:UnregisterForEvent(ADDON.name, EVENT_ADD_ON_LOADED)
	end
	LoadSavedVariables()
	
	SLASH_COMMANDS["/mmm"] = ADDON.HandleSlashCommands;
	ADDON.UI:Setup();
	ADDON.SnapshotSettings = table.copy(ADDON.Settings)
	RegisterEvents();
	RegisterUpdates();
	
	if (ADDON.Settings.MiniMap.Position.x == nil) then
		ADDON.Settings.MiniMap.Position.x, ADDON.Settings.MiniMap.Position.y = ADDON.UI.miniMap:GetCenter();
	end
end

EVENT_MANAGER:RegisterForEvent(ADDON.name, EVENT_ADD_ON_LOADED, EventHandlers.OnAddonLoaded);
--[[
  [] Author: Martynas Petuska
  [] E-mail: martynas.petuska@outlook.com
  [] Date:   January 2018
--]]
local EventHandlers = ADDON.EventHandlers
local Settings = ADDON.Settings

local function LoadSavedVariables()
	ADDON.Settings = ZO_SavedVars:New("Settings", 1, nil, ADDON.DefaultSettings or {})
end

local function RegisterEvents()
	EVENT_MANAGER:RegisterForEvent(ADDON.name, EVENT_RETICLE_HIDDEN_UPDATE, EventHandlers.OnUiModeChanged);
end

local function RegisterUpdates()
	EVENT_MANAGER:RegisterForUpdate(ADDON.Settings.addonName .. "_UiUpdate", 1, EventHandlers.OnUiUpdate);
	EVENT_MANAGER:RegisterForUpdate(ADDON.Settings.addonName .. "SettingsUpdate", 1, EventHandlers.OnSettingsModified);
end

function EventHandlers.OnAddonLoaded(event, addonName)
	if addonName ~= ADDON.name then
		return
	else
		EVENT_MANAGER:UnregisterForEvent(ADDON.name, EVENT_ADD_ON_LOADED)
	end
	LoadSavedVariables()
	
	SLASH_COMMANDS["/mmm"] = ADDON.HandleSlashCommands;
	ADDON.UI:ConfigureUI();
	ADDON:ScheduleSettingsUpdate();
	RegisterEvents();
	RegisterUpdates();
end

EVENT_MANAGER:RegisterForEvent(ADDON.name, EVENT_ADD_ON_LOADED, EventHandlers.OnAddonLoaded);
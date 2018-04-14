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
	ADDON.Settings = ZO_SavedVars:New("Settings", 1, nil, ADDON.DefaultSettings or {})
end

--- Registers handler functions for events.
---@return void
local function RegisterEvents()
	EVENT_MANAGER:RegisterForEvent(ADDON.name .. "_ZoneChanged", EVENT_ZONE_CHANGED, EventHandlers.OnZoneChanged);
	EVENT_MANAGER:RegisterForEvent(ADDON.name .. "_SubZoneChanged", EVENT_CURRENT_SUBZONE_LIST_CHANGED, EventHandlers.OnSubZoneChanged);
	EVENT_MANAGER:RegisterForEvent(ADDON.name .. "_PlayerActivated", EVENT_PLAYER_ACTIVATED, EventHandlers.OnPlayerActivated);
end

local function RegisterUpdates()
	EVENT_MANAGER:RegisterForUpdate(ADDON.name .. "_UiUpdate", 1, EventHandlers.OnUiUpdate);
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
	local fragment = ZO_FadeSceneFragment:New(ADDON.UI.miniMap);
	SCENE_MANAGER:GetScene("hud"):AddFragment(fragment);
	SCENE_MANAGER:GetScene("hudui"):AddFragment(fragment);
end

EVENT_MANAGER:RegisterForEvent(ADDON.name, EVENT_ADD_ON_LOADED, EventHandlers.OnAddonLoaded);
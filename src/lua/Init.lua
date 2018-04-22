--[[
  [] Author: Martynas Petuska
  [] E-mail: martynas.petuska@outlook.com
  [] Date:   January 2018
--]]
---------------- NAMESPACE ----------------
local ADDON = MMM;
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

	local orig = ZO_WorldMap_UpdateMap;
	function ZO_WorldMap_UpdateMap()
		orig();
		if (ADDON.UI.isSetup) then
			ADDON.UI.ConstructMap();
		end
	end

	EVENT_MANAGER:RegisterForUpdate(ADDON.name .. "_UiUpdate", 25, EventHandlers.OnUiUpdate);
	EVENT_MANAGER:RegisterForUpdate(ADDON.name .. "_UiCleanup", 10000, EventHandlers.OnUiCleanup);
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

	if (ADDON.Settings.MiniMap.Position.x == nil) then
		ADDON.Settings.MiniMap.Position.x, ADDON.Settings.MiniMap.Position.y = ADDON.UI.miniMap:GetCenter();
	end
	local fragment = ZO_FadeSceneFragment:New(ADDON.UI.miniMap, true, 100);
	function fragment:OnShown()
		local resultCode = SetMapToPlayerLocation();
		if (resultCode == SET_MAP_RESULT_FAILED) then
			return zo_callLater(function()
				self:OnShow();
			end, 250);
		elseif (resultCode == SET_MAP_RESULT_MAP_CHANGED) then
			CALLBACK_MANAGER:FireCallbacks("OnWorldMapChanged");
		else
			ADDON.UpdateInfo.updatePending = true;
		end
	end
	SCENE_MANAGER:GetScene("hud"):AddFragment(fragment);
	SCENE_MANAGER:GetScene("hudui"):AddFragment(fragment);
end

EVENT_MANAGER:RegisterForEvent(ADDON.name, EVENT_ADD_ON_LOADED, EventHandlers.OnAddonLoaded);
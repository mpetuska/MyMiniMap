--[[
  [] Author: Martynas Petuska
  [] E-mail: martynas.petuska@outlook.com
  [] Date:   January 2018
--]]
---------------- NAMESPACE ----------------
local EventHandlers = MMM.EventHandlers
-------------------------------------------

--- Creates or loads all of the saved variables from previous sessions.
---@return void
local function LoadSavedVariables()
	MMM.Settings = ZO_SavedVars:New("Settings", 1, nil, MMM.DefaultSettings or {})
end

--- Registers handler functions for events.
---@return void
local function RegisterEvents()
	EVENT_MANAGER:RegisterForEvent(MMM.name .. "_ZoneChanged", EVENT_ZONE_CHANGED, EventHandlers.OnZoneChanged);
	EVENT_MANAGER:RegisterForEvent(MMM.name .. "_SubZoneChanged", EVENT_CURRENT_SUBZONE_LIST_CHANGED, EventHandlers.OnSubZoneChanged);
	EVENT_MANAGER:RegisterForEvent(MMM.name .. "_PlayerActivated", EVENT_PLAYER_ACTIVATED, EventHandlers.OnPlayerActivated);

	local orig = ZO_WorldMap_UpdateMap;
	function ZO_WorldMap_UpdateMap()
		orig();
		if (MMM.UI.isSetup) then
			MMM.UI.ConstructMap();
		end
	end

	EVENT_MANAGER:RegisterForUpdate(MMM.name .. "_UiUpdate", 10, EventHandlers.OnUiUpdate);
end

--- Initialises the addon.
---@return void
function EventHandlers.OnAddonLoaded(event, addonName)
	if addonName ~= MMM.name then
		return
	else
		EVENT_MANAGER:UnregisterForEvent(MMM.name, EVENT_ADD_ON_LOADED)
	end
	LoadSavedVariables()

	SLASH_COMMANDS["/mmm"] = MMM.HandleSlashCommands;
	MMM.UI:Setup();
	RegisterEvents();

	if (MMM.Settings.MiniMap.Position.x == nil) then
		MMM.Settings.MiniMap.Position.x, MMM.Settings.MiniMap.Position.y = MMM.UI.miniMap:GetCenter();
	end
	local fragment = ZO_FadeSceneFragment:New(MMM.UI.miniMap, true, 100);
	function fragment:OnShown()
		local resultCode = SetMapToPlayerLocation();
		if (resultCode == SET_MAP_RESULT_FAILED) then
			return zo_callLater(function()
				self:OnShow();
			end, 250);
		elseif (resultCode == SET_MAP_RESULT_MAP_CHANGED) then
			CALLBACK_MANAGER:FireCallbacks("OnWorldMapChanged");
		else
			MMM.UpdateInfo.updatePending = true;
		end
	end
	SCENE_MANAGER:GetScene("hud"):AddFragment(fragment);
	SCENE_MANAGER:GetScene("hudui"):AddFragment(fragment);
end

EVENT_MANAGER:RegisterForEvent(MMM.name, EVENT_ADD_ON_LOADED, EventHandlers.OnAddonLoaded);
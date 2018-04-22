--[[
  [] Author: Martynas Petuska
  [] E-mail: martynas.petuska@outlook.com
  [] Date:   January 2018
--]]
---------------- NAMESPACE ----------------
local EventHandlers = ADDON.EventHandlers;
local UI = ADDON.UI;
-------------------------------------------

--- Handles main UI update event.
---@return void
function EventHandlers.OnUiUpdate()
	if (UI.isSetup and not ADDON.UI.miniMap:IsHidden()) then
		UI.UpdateMap();
	end
end

function EventHandlers.OnZoom(delta)
	local newZoom = ADDON.Settings.MiniMap.mapZoom + (delta * ADDON.Constants.zoomDelta);
	newZoom = math.max(newZoom, ADDON.Boundaries.mapZoomMin);
	newZoom = math.min(newZoom, ADDON.Boundaries.mapZoomMax);
	ADDON.Settings.MiniMap.mapZoom = newZoom;
	d(newZoom)
	UI.RescaleMap();
end

---Handles EVENT_ZONE_CHANGED event.
---@param eventCode number
---@param zoneName string
---@param subZoneName string
---@param newSubZone boolean
---@param zoneId number
---@param subZoneId number
function EventHandlers.OnZoneChanged(eventCode, zoneName, subZoneName, newSubZone, zoneId, subZoneId)
	local resultCode = SetMapToPlayerLocation();
	
	if (resultCode == SET_MAP_RESULT_MAP_CHANGED) then
		CALLBACK_MANAGER:FireCallbacks("OnWorldMapChanged");
	elseif (resultCode == SET_MAP_RESULT_FAILED) then
		zo_callLater(function()
			EventHandlers.OnZoneChanged(eventCode, zoneName, subZoneName, newSubZone, zoneId, subZoneId);
		end, 250);
	end
end

---Handles EVENT_CURRENT_SUBZONE_LIST_CHANGED event.
---@param eventCode number
function EventHandlers.OnSubZoneChanged(eventCode)
	local resultCode = SetMapToPlayerLocation();

	if (resultCode == SET_MAP_RESULT_MAP_CHANGED) then
		CALLBACK_MANAGER:FireCallbacks("OnWorldMapChanged");
	elseif (resultCode == SET_MAP_RESULT_FAILED) then
		zo_callLater(function()
			EventHandlers.OnSubZoneChanged(eventCode);
		end, 250);
	end
end

---Handles EVENT_PLAYER_ACTIVATED event.
---@param eventCode number
---@param initial boolean
function EventHandlers.OnPlayerActivated(eventCode, initial)
	local resultCode = SetMapToPlayerLocation();

	if (resultCode == SET_MAP_RESULT_MAP_CHANGED) then
		CALLBACK_MANAGER:FireCallbacks("OnWorldMapChanged");
	elseif (resultCode == SET_MAP_RESULT_FAILED) then
		zo_callLater(function()
			EventHandlers.OnPlayerActivated(eventCode, initial);
		end, 250);
	end
end
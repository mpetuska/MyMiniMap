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
	local UI = ADDON.UI;
	if not UI.isSetup then
		return;
	end
	
	if (not ADDON.UI.miniMap:IsHidden()) then
		UI:UpdateMap();
	end
end

function EventHandlers.OnZoom(delta)
	local newZoom = ADDON.Settings.MiniMap.mapZoom + (delta * ADDON.Constants.zoomDelta);
	newZoom = math.max(newZoom, ADDON.Boundaries.mapZoomMin);
	newZoom = math.min(newZoom, ADDON.Boundaries.mapZoomMax);
	ADDON.Settings.MiniMap.mapZoom = newZoom;
	
	UI:RescaleMap();
end

---Handles EVENT_ZONE_CHANGED event.
---@param eventCode number
---@param zoneName string
---@param subZoneName string
---@param newSubzone boolean
---@param zoneId number
---@param subZoneId number
function EventHandlers.OnZoneChanged(eventCode, zoneName, subZoneName, newSubzone, zoneId, subZoneId)
	if (ADDON.UpdateInfo.Map.subZoneName == subZoneName or subZoneName:lower():find("wayshrine")) then
		return
	end
	local resultCode = SetMapToPlayerLocation();
	
	if (resultCode == SET_MAP_RESULT_MAP_CHANGED) then
		UI:ConstructMap(subZoneName);
		CALLBACK_MANAGER:FireCallbacks("OnWorldMapChanged");
	elseif (resultCode == SET_MAP_RESULT_FAILED) then
		zo_callLater(function()
			EventHandlers.OnZoneChanged(eventCode, zoneName, subZoneName, newSubzone, zoneId, subZoneId);
		end, 250);
	end
end

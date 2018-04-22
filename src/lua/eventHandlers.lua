--[[
  [] Author: Martynas Petuska
  [] E-mail: martynas.petuska@outlook.com
  [] Date:   January 2018
--]]
---------------- NAMESPACE ----------------
local EventHandlers = MMM.EventHandlers;
local UI = MMM.UI;
-------------------------------------------

local function SetMapToPlayer()
	local resultCode = SetMapToPlayerLocation();

	if (resultCode == SET_MAP_RESULT_MAP_CHANGED) then
		CALLBACK_MANAGER:FireCallbacks("OnWorldMapChanged");
	elseif (resultCode == SET_MAP_RESULT_FAILED) then
		zo_callLater(function()
			SetMapToPlayer();
		end, 250);
	end
	return resultCode;
end

--- Handles main UI update event.
---@return void
function EventHandlers.OnUiUpdate()
	if (UI.isSetup and not MMM.UI.miniMap:IsHidden()) then
		UI.UpdateMap();
	end
end

function EventHandlers.OnZoom(delta)
	local newZoom = MMM.Settings.MiniMap.mapZoom + (delta * MMM.Constants.zoomDelta);
	newZoom = math.max(newZoom, MMM.Boundaries.mapZoomMin);
	newZoom = math.min(newZoom, MMM.Boundaries.mapZoomMax);
	MMM.Settings.MiniMap.mapZoom = newZoom;
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
	if (not string.match(zoneName, "Wayshrine") and not string.match(subZoneName, "Wayshrine")) then
		SetMapToPlayer();
	end
end

---Handles EVENT_CURRENT_SUBZONE_LIST_CHANGED event.
---@param eventCode number
function EventHandlers.OnSubZoneChanged(eventCode)
	SetMapToPlayer();
end

---Handles EVENT_PLAYER_ACTIVATED event.
---@param eventCode number
---@param initial boolean
function EventHandlers.OnPlayerActivated(eventCode, initial)
	SetMapToPlayer();
end

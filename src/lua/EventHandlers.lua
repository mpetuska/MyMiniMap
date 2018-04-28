--[[
  [] Author: Martynas Petuska
  [] E-mail: martynas.petuska@outlook.com
  [] Date:   January 2018
--]]
---------------- NAMESPACE ----------------
local ADDON = MMM;
local EventHandlers = ADDON.EventHandlers;
local UI = ADDON.UI;
-------------------------------------------

---Sets map to player location recursively until it succeeds.
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

local lastValue = 0;
function EventHandlers.RefreshFPS()
	local MULTIPLIER1 = 0.55;
	local MULTIPLIER2 = 1.25;

	local fps = GetFramerate();
	local refreshTime = math.ceil(2000 / (fps * MULTIPLIER1 + fps * MULTIPLIER2));

	if lastValue ~= refreshTime then
		EVENT_MANAGER:UnregisterForUpdate(ADDON.name .. "_UiUpdate");
		EVENT_MANAGER:RegisterForUpdate(ADDON.name .. "_UiUpdate", refreshTime, EventHandlers.OnUiUpdate)
		lastValue = refreshTime
	end
end

--- Handles main UI update event.
---@return void
function EventHandlers.OnUiUpdate()
	if (UI.isSetup and not UI.miniMap:IsHidden()) then
		UI.UpdateMap();
	end
end

---Handles regular ui cleanup update.
function EventHandlers.OnUiCleanup()
	ADDON.Classes.MapPin.RefreshAll();
end

---Handles minimap zooming event.
---@param delta number
function EventHandlers.OnZoom(delta)
	local newZoom = ADDON.Settings.MiniMap.mapZoom + (delta * ADDON.Constants.zoomDelta);
	newZoom = math.max(newZoom, ADDON.Boundaries.mapZoomMin);
	newZoom = math.min(newZoom, ADDON.Boundaries.mapZoomMax);
	ADDON.Settings.MiniMap.mapZoom = newZoom;
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

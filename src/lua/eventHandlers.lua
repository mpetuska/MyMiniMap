--[[
  [] Author: Martynas Petuska
  [] E-mail: martynas.petuska@outlook.com
  [] Date:   January 2018
--]]
---------------- NAMESPACE ----------------
local EventHandlers = ADDON.EventHandlers;
-------------------------------------------

--- Handles main UI update event.
---@return void
function EventHandlers.OnUiUpdate()
	local UI = ADDON.UI;
	if not UI.isSetup then
		return;
	end
	
	UI.miniMap:SetHidden(ZO_Compass:IsHidden())
	if (not ADDON.UI.miniMap:IsHidden()) then
		UI:UpdateMap();
	end
end

function EventHandlers.OnZoom(delta)
	local newZoom = ADDON.Settings.MiniMap.mapZoom + (delta * ADDON.Constants.zoomDelta);
	newZoom = math.max(newZoom, ADDON.Boundaries.mapZoomMin);
	newZoom = math.min(newZoom, ADDON.Boundaries.mapZoomMax);
	ADDON.Settings.MiniMap.mapZoom = newZoom;
	
	ADDON.UI:RescaleMap();
end
--[[
  [] Author: Martynas Petuska
  [] E-mail: martynas.petuska@outlook.com
  [] Date:   January 2018
--]]
---------------- NAMESPACE ----------------
local EventHandlers = ADDON.EventHandlers;
local UpdateInfo = ADDON.UpdateInfo;
-------------------------------------------

function EventHandlers.OnSettingsUpdate()
	if (not table.compare(ADDON.Settings, ADDON.SnapshotSettings)) then
		ADDON.SnapshotSettings = table.copy(ADDON.Settings);
		UI:Reload()
	end
end

function EventHandlers.OnUiUpdate()
	local UI = ADDON.UI;
	if not UI.isSetup then
		return;
	end
	
	if (UpdateInfo.mapId ~= GetCurrentMapIndex() or UpdateInfo.zoneId ~= GetCurrentMapZoneIndex()) then
		UI:ConstructMap();
	end
	
	UI.miniMap:SetHidden(ZO_Compass:IsHidden())
	
	if (not ADDON.UI.miniMap:IsHidden()) then
		UI:UpdateMap();
	end
end
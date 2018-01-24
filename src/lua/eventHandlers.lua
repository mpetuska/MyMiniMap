--[[
  [] Author: Martynas Petuska
  [] E-mail: martynas.petuska@outlook.com
  [] Date:   January 2018
--]]
------------- NAMESPACE -------------
local EventHandlers = ADDON.EventHandlers;
local UpdateInfo = ADDON.Settings.MiniMap.UpdateInfo;
-------------------------------------

function EventHandlers.OnUiModeChanged(eventCode, isUiShown)
	ADDON.Settings.isMiniMapHidden = isUiShown;
	ADDON:ScheduleSettingsUpdate();
end

function EventHandlers.OnSettingsModified()
	if (ADDON.settingsUpdatePending) then
		ADDON.UI.miniMap:SetHidden(ADDON.Settings.isMiniMapHidden);
		ADDON.UI:Rescale();
		ADDON.UI.wheel:SetTextureRotation(0);
		ADDON.UI.playerPin:SetTextureRotation(0);
		
		ADDON.settingsUpdatePending = false;
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
	
	if (ADDON.Settings.isUpdateEnabled) then
		UI:UpdateMap();
	end
end
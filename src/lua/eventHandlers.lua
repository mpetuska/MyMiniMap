--[[
  [] Author: Martynas Petuska
  [] E-mail: martynas.petuska@outlook.com
  [] Date:   January 2018
--]]
---------------- NAMESPACE ----------------
local EventHandlers = ADDON.EventHandlers;
local UpdateInfo = ADDON.UpdateInfo;
-------------------------------------------

--- Handles regular checks for any changes made in the ADDON.Settings.
---@return void
function EventHandlers.OnSettingsUpdate()
	if (not table.compare(ADDON.Settings, ADDON.SnapshotSettings)) then
		ADDON.SnapshotSettings = table.copy(ADDON.Settings);
		UI:Reload()
	end
end

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
--[[
  [] Author: Martynas Petuska
  [] E-mail: martynas.petuska@outlook.com
  [] Date:   January 2018
--]]
ADDON.EventHandlers = {}
local EventHandlers = ADDON.EventHandlers

function EventHandlers:OnUiUpdate()
	local UI = ADDON.UI;
	if not UI.isSetup then
		return
	end
	if (ADDON.Settings.MiniMap.size ~= UI.wheel:GetDimensions()) then
		UI:Rescale()
	end
	if (ADDON.Settings.isUpdateEnabled) then
		UI:UpdateMapTexture()
	end
end
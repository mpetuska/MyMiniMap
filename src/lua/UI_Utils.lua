--[[
  [] Author: Martynas Petuska
  [] E-mail: martynas.petuska@outlook.com
  [] Date:   January 2018
--]]
---------------- NAMESPACE ----------------
local UI = ADDON.UI;
local UpdateInfo = ADDON.UpdateInfo;
-------------------------------------------

---Checks is the given normalized map coordinates are inside the mini map wheel.
---@param normalizedX number
---@param normalizedY number
---@return boolean
function UI:AreCoordinatesInsideWheel(normalizedX, normalizedY)
	local centerX, centerY = UpdateInfo.Player.normX, UpdateInfo.Player.normY;
	local r = UI.miniMap:GetDimensions() / UpdateInfo.Map.width;
	local dx, dy = normalizedX - centerX, normalizedY - centerY;
	
	return (math.sqrt((dx * dx) + (dy * dy)) <= r);
end
--[[
  [] Author: Martynas Petuska
  [] E-mail: martynas.petuska@outlook.com
  [] Date:   February 2018
--]]
local UI = ADDON.UI;
local super = ADDON.Classes.Pin;
local eventsHandlersRegistered = false;
--====================================================== CLASS =======================================================--
---A class to represent and control wayshrine pins.
--- 
---@class FastTravelPin
---@field public Position table
---@field public icon string
---@field public type number
---@field public zoneId number
---@field public enabled boolean
local FastTravelPin = super:New();
ADDON.Classes.FastTravelPin = FastTravelPin;
FastTravelPin.Objects = {};
local Objects = FastTravelPin.Objects;
--====================================================================================================================--

---Constructor
---@return WayshrinePin
function FastTravelPin:New(nodeIndex, known, name, nX, nY, icon, glowIcon, poiType)
	local obj = setmetatable({}, { __index = self });
	obj:Init(nodeIndex, known, name, nX, nY, icon, glowIcon, poiType);
	if (not eventsHandlersRegistered) then
		EVENT_MANAGER:RegisterForEvent(ADDON.name .. "_FastTravelPinDiscovered", EVENT_FAST_TRAVEL_NETWORK_UPDATED, FastTravelPin.OnFastTravelNetworkUpdated);
		eventsHandlersRegistered = true;
	end
	return obj;
end

---Initialises the new object.
function FastTravelPin:Init(nodeIndex, known, name, nX, nY, icon, glowIcon, poiType)
	super.Init(self, known, name, poiType, icon, glowIcon);
	self.nodeIndex = nodeIndex;
	
	local size = ADDON.Sizes.mapPinSize * ADDON.Settings.MiniMap.mapScale;
	for group, map in pairs(UI.Maps) do
		local controlName = map:GetName() .. "FastTravelPin_" .. tostring(#Objects + 1);
		self.Controls[group] = WINDOW_MANAGER:CreateControl(controlName, map, CT_TEXTURE);
		self.Controls[group]:SetTexture(icon);
		self.Controls[group]:SetDimensions(size, size);
		self.Controls[group]:SetDrawLayer(2);
		self.Controls[group]:SetHidden(not self.enabled);
	end
	Objects[#Objects + 1] = self;
	self:SetMapPos(nX, nY)
end

---Event handler for EVENT_FAST_TRAVEL_NETWORK_UPDATED. Enabled the newly discovered pin.
---@param eventCode number
---@param nodeIndex number
function FastTravelPin.OnFastTravelNetworkUpdated(eventCode, nodeIndex)
	local found = false;
	for _, pin in pairs(Objects) do
		if (pin.nodeIndex == nodeIndex) then
			pin:SetEnabled(true);
			found = true;
			break;
		end
	end
	if (not found) then
		FastTravelPin:New(nodeIndex, GetFastTravelNodeInfo(nodeIndex))
	end
end
--====================================================================================================================--
return FastTravelPin;

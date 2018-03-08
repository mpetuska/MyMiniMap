--[[
  [] Author: Martynas Petuska
  [] E-mail: martynas.petuska@outlook.com
  [] Date:   February 2018
--]]
local UI = ADDON.UI;
local super = ADDON.Classes.AbstractPin;
local eventHandlersRegistered = false;
--====================================================== CLASS =======================================================--
---A class to represent and control fast travel pins.
--- 
---@class FastTravelPin
local FastTravelPin = super:New();
ADDON.Classes.FastTravelPin = FastTravelPin;
FastTravelPin.Objects = {};
local Objects = FastTravelPin.Objects;
--====================================================================================================================--

---Constructor
---@param nodeIndex number
---@param known boolean
---@param name string
---@param nX number
---@param nY number
---@param icon string
---@param glowIcon string
---@param poiType number
---@return FastTravelPin
function FastTravelPin:New(nodeIndex, known, name, nX, nY, icon, glowIcon, poiType)
	local obj = setmetatable({}, { __index = self });
	table.insert(Objects, obj);
	obj.objectId = #Objects;
	obj:Init(nodeIndex, known, name, nX, nY, icon, glowIcon, poiType);
	if (not eventHandlersRegistered) then
		EVENT_MANAGER:RegisterForEvent(ADDON.name .. "_FastTravelPinDiscovered", EVENT_FAST_TRAVEL_NETWORK_UPDATED, FastTravelPin.OnFastTravelNetworkUpdated);
		eventHandlersRegistered = true;
	end
	return obj;
end

---Initialises the new object.
---@param nodeIndex number
---@param known boolean
---@param name string
---@param nX number
---@param nY number
---@param icon string
---@param glowIcon string
---@param poiType number
function FastTravelPin:Init(nodeIndex, known, name, nX, nY, icon, glowIcon, poiType)
	super.Init(self, known, name, poiType, icon, glowIcon);
	self.nodeIndex = nodeIndex;
	
	local size = ADDON.Sizes.mapPinSize * ADDON.Settings.MiniMap.mapScale;
	local objectId = self.objectId;
	for group, scroll in pairs(UI.Scrolls) do
		if (not self.Controls[group]) then
			local controlName = scroll:GetName() .. "_FastTravelPin" .. tostring(objectId);
			self.Controls[group] = WINDOW_MANAGER:CreateControl(controlName, scroll, CT_TEXTURE);
		end
		
		self.Controls[group]:SetTexture(icon);
		self.Controls[group]:SetDimensions(size, size);
		self.Controls[group]:SetDrawLevel(2);
		self.Controls[group]:SetHidden(not self.enabled);
	end
	
	self.Controls.center:SetMouseEnabled(true);
	self.Controls.center:SetHandler("OnMouseEnter", function(it)
		ZO_Tooltips_ShowTextTooltip(it, TOP, self.name)
	end);
	self.Controls.center:SetHandler("OnMouseExit", function()
		ZO_Tooltips_HideTextTooltip()
	end);
	self:SetPosition(nX, nY);
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

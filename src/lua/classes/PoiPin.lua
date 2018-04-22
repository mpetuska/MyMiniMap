--[[
  [] Author: Martynas Petuska
  [] E-mail: martynas.petuska@outlook.com
  [] Date:   March 2018
--]]
--====================================================== CLASS =======================================================--
local super = ADDON.Classes.Pin;
---@class PoiPin
local PoiPin = setmetatable({}, { __index = super });
ADDON.Classes.PoiPin = PoiPin;
PoiPin.Objects = {};
local Objects = PoiPin.Objects;
local classSetup = false;
--====================================================================================================================--

---Constructor.
---@return PoiPin
function PoiPin:New(zoneId, poiId, name, poiType, icon, nX, nY, enabled)
	if (not classSetup) then
		super.RegisterSubclass(PoiPin);
		EVENT_MANAGER:RegisterForEvent(ADDON.name .. "_PoiDiscovered", EVENT_POI_DISCOVERED, PoiPin.OnPoiDiscovered);
		classSetup = true;
	end
	
	if (Objects[poiId]) then
		Objects[poiId]:Init(zoneId, poiId, name, poiType, icon, nX, nY, enabled);
		return Objects[poiId];
	end
	local obj = setmetatable({}, { __index = self });
	table.insert(Objects, obj);
	obj.objectId = #Objects;
	obj.type = "PoiPin";
	obj:Init(zoneId, poiId, name, poiType, icon, nX, nY, enabled);
	return obj;
end

---Initialises the new object.
function PoiPin:Init(zoneId, poiId, name, mapDisplayPoiPinType, icon, nX, nY, enabled)
	super.Init(self, zoneId, poiId, icon, nX, nY, enabled);
	self.mapDisplayPoiPinType = mapDisplayPoiPinType;
	self.name = name;
	
	self.Controls.center:SetMouseEnabled(true);
	self.Controls.center:SetHandler("OnMouseEnter", function(it)
		ZO_Tooltips_ShowTextTooltip(it, TOP, self.name)
	end);
	self.Controls.center:SetHandler("OnMouseExit", function()
		ZO_Tooltips_HideTextTooltip()
	end);
	self:SetPosition(nX, nY);
end
--====================================================================================================================--
function PoiPin.UpdateAll()
	for _, pin in pairs(Objects) do
		pin:Update();
	end
end
function PoiPin.SetEnabledAll(areEnabled)
	for _, pin in pairs(Objects) do
		pin:SetEnabled(areEnabled);
	end
end
--====================================================================================================================--
function PoiPin.OnPoiDiscovered(eventCode, zoneIndex, poiIndex)
	local nX, nY, mapDisplayPoiPinType, icon, isShownInCurrentMap, linkedCollectibleIsLocked = GetPOIMapInfo(zoneIndex, poiIndex);
	local objectiveName, objectiveLevel, startDescription, finishedDescription = GetPOIInfo(zoneIndex, poiIndex)
	PoiPin:New(zoneIndex, poiIndex, objectiveName, mapDisplayPoiPinType, icon, nX, nY);
end
--====================================================================================================================--
return PoiPin;
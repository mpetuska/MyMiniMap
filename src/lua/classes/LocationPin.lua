--[[
  [] Author: Martynas Petuska
  [] E-mail: martynas.petuska@outlook.com
  [] Date:   March 2018
--]]
--====================================================== CLASS =======================================================--
local super = ADDON.Classes.Pin;
---@class LocationPin
local LocationPin = setmetatable({}, { __index = super });
ADDON.Classes.LocationPin = LocationPin;
LocationPin.Objects = {};
local Objects = LocationPin.Objects;
local classSetup = false;
--====================================================================================================================--

---Constructor.
function LocationPin:New(zoneId, locationId, name, icon, nX, nY, enabled)
	if (not classSetup) then
		super.RegisterSubclass(LocationPin);
		classSetup = true;
	end
	
	if (Objects[locationId]) then
		Objects[locationId]:Init(zoneId, locationId, name, icon, nX, nY, enabled);
		return Objects[locationId];
	end
	local obj = setmetatable({}, { __index = self });
	table.insert(Objects, obj);
	obj.objectId = #Objects;
	obj.type = "LocationPin";
	obj:Init(zoneId, locationId, name, icon, nX, nY, enabled);
	return obj;
end

---Initialises the new object.
function LocationPin:Init(zoneId, locationId, name, icon, nX, nY, enabled)
	super.Init(self, zoneId, locationId, icon, nX, nY, enabled);
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
function LocationPin.UpdateAll()
	for _, pin in pairs(Objects) do
		pin:Update();
	end
end
function LocationPin.SetEnabledAll(areEnabled)
	for _, pin in pairs(Objects) do
		pin:SetEnabled(areEnabled);
	end
end
--====================================================================================================================--
return LocationPin;
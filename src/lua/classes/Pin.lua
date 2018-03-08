--[[
  [] Author: Martynas Petuska
  [] E-mail: martynas.petuska@outlook.com
  [] Date:   February 2018
--]]
local UpdateInfo = ADDON.UpdateInfo;
local Settings = ADDON.Settings;
local Sizes = ADDON.Sizes;
local UI = ADDON.UI;
--====================================================== CLASS =======================================================--
---A base class to hold common functionality shared between the various types of map pins.
---It is mostly intended to be extended by the pin-type-specific classes.
--- 
---@class Pin
local Pin = {};
ADDON.Classes.Pin = Pin;
Pin.Objects = {};
local Objects = Pin.Objects;
local eventHandlersRegistered = false;
--====================================================================================================================--

---Constructor.
---@param zoneId number
---@param poiId number
---@param name string
---@param poiType number
---@param icon string
---@param nX number
---@param nY number
---@param enabled boolean
---@return Pin
function Pin:New(zoneId, poiId, name, poiType, icon, nX, nY, enabled)
	local obj = setmetatable({}, { __index = self });
	table.insert(Objects, obj);
	obj.objectId = #Objects;
	obj:Init(zoneId, poiId, name, poiType, icon, nX, nY, enabled);
	if (not eventHandlersRegistered) then
		EVENT_MANAGER:RegisterForEvent(ADDON.name .. "_PoiDiscovered", EVENT_POI_DISCOVERED, Pin.OnPoiDiscovered);
		eventHandlersRegistered = true;
	end
	return obj;
end

---Initialises the new object.
---@param zoneId number
---@param poiId number
---@param name string
---@param mapDisplayPinType number
---@param icon string
---@param nX number
---@param nY number
---@param enabled boolean
function Pin:Init(zoneId, poiId, name, mapDisplayPinType, icon, nX, nY, enabled)
	self.zoneId = zoneId;
	self.poiId = poiId;
	self.Controls = self.Controls or {};
	self.Position = {
		x = nX,
		y = nY
	};
	self.icon = icon;
	self.mapDisplayPinType = mapDisplayPinType;
	self.enabled = enabled or true;
	self.name = name;
	
	local size = Sizes.mapPinSize * Settings.MiniMap.mapScale;
	local objectId = self.objectId;
	for group, scroll in pairs(UI.Scrolls) do
		if (not self.Controls[group]) then
			local controlName = scroll:GetName() .. "_Pin" .. tostring(objectId);
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

---Gets the pin's normalised coordinates in the map.
---@return number, number
function Pin:GetPosition()
	return self.Position.x, self.Position.y;
end

---Sets the pin's normalised coordinates in the map and updates the rotated position of its controls.
---If no arguments are passed, the controls' position is readjusted from the stored values.
---@param nX number
---@param nY number
function Pin:SetPosition(nX, nY)
	if (nX and nY) then
		self.Position.x = nX;
		self.Position.y = nY;
	else
		nX = self.Position.x;
		nY = self.Position.y;
	end
	local mapRotation = 0;
	if (Settings.isMapRotationEnabled) then
		mapRotation = UpdateInfo.Player.rotation;
	end
	local playerX, playerY = UpdateInfo.Player.nX, UpdateInfo.Player.nY;
	-- Counter-clockwise rotation around player position.
	local x = playerX + (nX - playerX) * math.cos(mapRotation) - (nY - playerY) * math.sin(mapRotation);
	local y = playerY + (nX - playerX) * math.sin(mapRotation) + (nY - playerY) * math.cos(mapRotation);
	for _, control in pairs(self.Controls) do
		control:ClearAnchors();
		control:SetAnchor(CENTER, control:GetParent(), CENTER, (x - playerX) * UpdateInfo.Map.width, (y - playerY) * UpdateInfo.Map.height);
	end
end

---Enables/disables the pin.
---@param isEnabled boolean
function Pin:SetEnabled(isEnabled)
	for _, control in pairs(self.Controls) do
		control:SetHidden(not isEnabled);
	end
	self.enabled = isEnabled;
end

---Returns whether the pin is enabled.
---@return boolean
function Pin:IsEnabled()
	return self.enabled;
end

---Updates the pin.
function Pin:Update()
	if (self.enabled) then
		self:SetPosition();
	end
end
--====================================================================================================================--
function Pin.OnPoiDiscovered(eventCode, zoneIndex, poiIndex)
	local nX, nY, mapDisplayPinType, icon, isShownInCurrentMap, linkedCollectibleIsLocked = GetPOIMapInfo(zoneIndex, poiIndex);
	local objectiveName, objectiveLevel, startDescription, finishedDescription = GetPOIInfo(zoneIndex, poiIndex)
	if (Objects[poiIndex] and Objects[poiIndex].zoneId == zoneIndex) then
		Objects[poiIndex]:Init(zoneIndex, poiIndex, objectiveName, mapDisplayPinType, icon, nX, nY);
	else
		Pin:New(zoneIndex, poiIndex, objectiveName, mapDisplayPinType, icon, nX, nY);
	end
end
--====================================================================================================================--
return Pin;
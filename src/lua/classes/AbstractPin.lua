--[[
  [] Author: Martynas Petuska
  [] E-mail: martynas.petuska@outlook.com
  [] Date:   February 2018
--]]
local UpdateInfo = ADDON.UpdateInfo;
--====================================================== CLASS =======================================================--
---A base class to hold common functionality shared between the various types of map pins.
---It is mostly intended to be extended by the pin-type-specific classes.
--- 
---@class AbstractPin
local AbstractPin = {};
ADDON.Classes.Pin = AbstractPin;
--====================================================================================================================--

---Constructor
---@return Pin
function AbstractPin:New()
	local obj = setmetatable({}, { __index = self });
	return obj;
end

---Initialises the new object.
---@param known boolean
---@param name string
---@param poiType number
---@param icon string
---@param glowIcon string
function AbstractPin:Init(known, name, poiType, icon, glowIcon)
	self.Controls = {}
	self.Position = {
		x = nil,
		y = nil
	};
	self.icon = icon;
	self.glowIcon = glowIcon;
	self.type = poiType;
	self.enabled = known;
	self.name = name;
end

---Gets the pin's normalised coordinates in the map.
---@return number, number
function AbstractPin:GetPosition()
	return self.Position.x, self.Position.y;
end

---Sets the pin's normalised coordinates in the map and updates the rotated position of its controls.
---If no arguments are passed, the controls' position is readjusted from the stored values.
---@param nX number
---@param nY number
function AbstractPin:SetPosition(nX, nY)
	if (nX == nil and nY == nil) then
		nX = self.Position.x;
		nY = self.Position.y;
	else
		self.Position.x = nX;
		self.Position.y = nY;
	end
	local mapRotation = 0;
	if (ADDON.Settings.isMapRotationEnabled) then
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
function AbstractPin:SetEnabled(isEnabled)
	for _, control in pairs(self.Controls) do
		control:SetHidden(not isEnabled);
	end
	self.enabled = isEnabled;
end

---Returns whether the pin is enabled.
---@return boolean
function AbstractPin:IsEnabled()
	return self.enabled;
end

---Updates the pin.
function AbstractPin:Update()
	if (self.enabled) then
		self:SetPosition();
	end
end
--====================================================================================================================--
return AbstractPin;
--[[
  [] Author: Martynas Petuska
  [] E-mail: martynas.petuska@outlook.com
  [] Date:   February 2018
--]]
--====================================================== CLASS =======================================================--
---A base class to hold common functionality shared between the various types of map pins.
---It is mostly intended to be extended by the pin-type-specific classes.
--- 
---@class Pin
---@field public Controls table
---@field public Position table
---@field public icon string
---@field public type number
---@field public zoneId number
---@field public enabled boolean
local Pin = {};
ADDON.Classes.Pin = Pin;
--====================================================================================================================--

---Constructor
---@return Pin
function Pin:New()
	local obj = setmetatable({}, { __index = self });
	return obj;
end

---Initialises the new object.
function Pin:Init(known, name, poiType, icon, glowIcon)
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

-- region Getters & Setters
---Gets the pin's normalised coordinates in the map.
---@return number, number
function Pin:GetMapPos()
	return self.Position.x, self.Position.y;
end

---Sets the pin's normalised coordinates in the map and updates the rotated position of its controls.
---If no arguments are passed, the controls' position is readjusted from the stored values.
---@param nX number
---@param nY number
function Pin:SetMapPos(nX, nY)
	if (nX == nil and nY == nil) then
		nX = self.Position.x;
		nY = self.Position.y;
	else
		self.Position.x = nX;
		self.Position.y = nY;
	end
	local mapRotation = ADDON.UpdateInfo.Map.rotation;
	local playerX, playerY = ADDON.UpdateInfo.Player.nX, ADDON.UpdateInfo.Player.nY;
	-- Counter-clockwise rotation around player position.
	local x = playerX + (nX - playerX) * math.cos(mapRotation) - (nY - playerY) * math.sin(mapRotation);
	local y = playerY + (nX - playerX) * math.sin(mapRotation) + (nY - playerY) * math.cos(mapRotation);
	for _, control in pairs(self.Controls) do
		control:ClearAnchors();
		control:SetAnchor(CENTER, control:GetParent(), TOPLEFT, x * control:GetParent():GetWidth(), y * control:GetParent():GetHeight());
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
-- endregion

function Pin:Update()
	self:SetMapPos();
end
--====================================================================================================================--
return Pin;
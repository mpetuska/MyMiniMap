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
---@field public Position table
---@field public icon string
---@field public type number
---@field public zoneId number
---@field public enabled boolean
local Pin = {};
--====================================================================================================================--

---Constructor
---@return Pin
function Pin:New()
	local obj = setmetatable({}, { __index = self });
	obj:Init();
	return obj;
end

---Initialises the new object.
function Pin:Init()
	self.Position = {
		x = -1,
		y = -1
	};
	self.icon = -1;
	self.type = -1;
	self.zoneId = -1;
	self.enabled = true;
end

-- region Getters & Setters
---Gets the pin's normalised coordinates in the map.
---@return number, number
function Pin:GetMapPos()
	return self.Position.x, self.Position.y;
end

---Sets the pin's normalised coordinates in the map.
---@param nX number
---@param nY number
function Pin:SetMapPos(nX, nY)
	self.Position.x = nX;
	self.Position.y = nY;
end
-- endregion
--====================================================================================================================--
return Pin;
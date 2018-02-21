--[[
  [] Author: Martynas Petuska
  [] E-mail: martynas.petuska@outlook.com
  [] Date:   February 2018
--]]
--====================================================== CLASS =======================================================--
local super = require "lua.classes.AbstractPin";
---A base class to hold common functionality shared between the various types of map pins.
---It is mostly intended to be extended by the pin-type-specific classes.
--- 
---@class WayshrinePin
---@field public Position table
---@field public icon string
---@field public type number
---@field public zoneId number
---@field public enabled boolean
local WayshrinePin = super:New();
--====================================================================================================================--

---Constructor
---@return WayshrinePin
function WayshrinePin:New()
	local obj = setmetatable({}, { __index = self });
	obj:Init();
	return obj;
end

---Initialises the new object.
function WayshrinePin:Init()
	super.Init(self);
end

-- region Getters & Setters
-- endregion
--====================================================================================================================--
return WayshrinePin;

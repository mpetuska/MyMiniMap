--[[
  [] Author: Martynas Petuska
  [] E-mail: martynas.petuska@outlook.com
  [] Date:   March 2018
--]]
local UpdateInfo = ADDON.UpdateInfo;
local Settings = ADDON.Settings;
local Sizes = ADDON.Sizes;
local UI = ADDON.UI;
--====================================================== CLASS =======================================================--
---@class Pin
local Pin = {};
ADDON.Classes.Pin = Pin;
Pin.Subclasses = {};
local Subclasses = Pin.Subclasses;
--====================================================================================================================--

---Registers a subclass.
---@param subclass table
function Pin.RegisterSubclass(subclass)
	table.insert(Subclasses, subclass);
end

---Initialises the new object.
---@param zoneId number
---@param pinId number
---@param icon string
---@param nX number
---@param nY number
---@param enabled boolean
function Pin:Init(zoneId, pinId, icon, nX, nY, enabled)
	self.zoneId = zoneId;
	self.pinId = pinId;
	self.Controls = self.Controls or {};
	self.Position = {
		x = nX,
		y = nY
	};
	self.icon = icon;
	self.enabled = enabled or true;
	
	local size = Sizes.mapPinSize * Settings.MiniMap.mapScale;
	local objectId = self.objectId;
	for group, scroll in pairs(UI.Scrolls) do
		if (not self.Controls[group]) then
			local controlName = scroll:GetName() .. "_" .. self.type .. tostring(objectId);
			self.Controls[group] = WINDOW_MANAGER:CreateControl(controlName, scroll, CT_TEXTURE);
		end
		
		self.Controls[group]:SetTexture(icon);
		self.Controls[group]:SetDimensions(size, size);
		self.Controls[group]:SetDrawLevel(2);
		self.Controls[group]:SetHidden(not self.enabled);
	end
	
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
	self.enabled = isEnabled or false;
	for _, control in pairs(self.Controls) do
		control:SetHidden(not self.enabled);
	end
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
function Pin.UpdateAll()
	for _, subclass in pairs(Subclasses) do
		subclass.UpdateAll();
	end
end
function Pin.SetEnabledAll(areEnabled)
	for _, subclass in pairs(Subclasses) do
		subclass.SetEnabledAll(areEnabled);
	end
end
--====================================================================================================================--
return Pin;
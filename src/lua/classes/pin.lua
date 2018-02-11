--[[
  [] Author: Martynas Petuska
  [] E-mail: martynas.petuska@outlook.com
  [] Date:   February 2018
--]]
---------------- NAMESPACE ----------------
ADDON.Classes = ADDON.Classes or {};
local UI = ADDON.UI;
-------------------------------------------


---@class Pin
local Pin = {};
Pin.__index = Pin;
ADDON.Classes.Pin = Pin;

function Pin:GetMapPos()
	return self.MapPos.x, self.MapPos.y;
end

function Pin:GetScreenPos()
	return self.Controls.center:GetCenter();
end

function Pin:GetDimensions()
	return self.Controls.center:GetDimensions();
end

function Pin:IsActive()
	return not self.Controls.center:IsHidden();
end

function Pin:SetActive(isActive)
	for _, control in pairs(self.Controls) do
		control:SetHidden(not isActive);
	end
end

function Pin:Update()
	-- Position --
	
	
	-- Rotation --
	local pinWidth, pinHeight = self:GetDimensions();
	local pinCenterX, pinCenterY = self:GetScreenPos();
	local wheelCenterX, wheelCenterY = UI.wheel:GetCenter();
	local dx, dy = wheelCenterX - pinCenterX, wheelCenterY - pinCenterY;
	local normalizedRotationPointX = ((pinWidth / 2) + dx) / pinWidth;
	local normalizedRotationPointY = ((pinHeight / 2) + dy) / pinHeight;
	
	-- Update --
	for group, control in pairs(self.Controls) do
		control:SetTextureRotation(-ADDON.UpdateInfo.Player.rotation, normalizedRotationPointX, normalizedRotationPointY);
	end
end

function Pin:SetMapPos(x, y)
	self.MapPos.x = x;
	self.MapPos.y = y;
	for _, control in pairs(self.Controls) do
		control:ClearAnchors();
		control:SetAnchor(CENTER, control:GetParent(), TOPLEFT, x * control:GetParent():GetWidth(), y * control:GetParent():GetHeight());
	end
end

function Pin:New(pinIndex, poiType)
	if (not pinIndex or not poiType) then
		return;
	end
	
	local zoneIndex = ADDON.UpdateInfo.Map.zoneId;
	local pin;
	if (poiType == POI_TYPE_WAYSHRINE) then
		local container = UI.Pins.Wayshrines;
		for _, p in pairs(container) do
			if (p.zoneId == zoneIndex and p.pinId == pinIndex and p.type == poiType) then
				return p;
			elseif (not p:IsActive()) then
				pin = p;
			end
		end
		if (not pin) then
			pin = {};
			setmetatable(pin, self);
			self.__index = self;
			container[#container + 1] = pin;
		end
	else
		return;
	end
	
	local mapX, mapY, icon;
	if (poiType == POI_TYPE_WAYSHRINE) then
		_, _, mapX, mapY, icon = GetFastTravelNodeInfo(pinIndex);
	else
		return;
	end
	
	pin.type = poiType;
	pin.pinId = pinIndex;
	pin.zoneId = zoneIndex;
	
	for group, map in pairs(UI.Maps) do
		if (not pin.Controls[group]) then
			local name = map:GetName() .. "Pin" .. tostring(pin.type) .. "_" .. tostring(pin.pinId);
			pin.Controls[group] = WINDOW_MANAGER:CreateControl(name, map, CT_TEXTURE);
		end
		pin.Controls[group]:SetTexture(icon);
		pin.Controls[group]:SetDimensions(ADDON.pinBaseSize * ADDON.Settings.MiniMap.mapScale, ADDON.pinBaseSize * ADDON.Settings.MiniMap.mapScale);
	end
	
	pin:SetMapPos(mapX, mapY);
	pin:SetActive(true);
	
	return pin;
end

function Pin:NewWayshrine(pinId, mapX, mapY, icon)
	local container = UI.Pins.Wayshrines;
	
	local pin;
	for _, p in pairs(container) do
		if (p.id == pinId and p.type == POI_TYPE_WAYSHRINE) then
			return p;
		elseif (not p:IsActive()) then
			pin = p;
		end
	end
	if (not pin) then
		pin = {};
		setmetatable(pin, self);
		
		pin.Controls = {};
		pin.MapPos = {
			x = 0,
			y = 0
		};
		for group, map in pairs(UI.Maps) do
			local name = map:GetName() .. "Pin_Wayshrine" .. tostring(#container + 1);
			pin.Controls[group] = WINDOW_MANAGER:CreateControl(name, map, CT_TEXTURE);
		end
		container[#container + 1] = pin;
	end
	
	pin.type = POI_TYPE_WAYSHRINE;
	pin.id = pinId;
	
	-- Setup controls --
	for _, control in pairs(pin.Controls) do
		control:SetTexture(icon);
		control:SetDimensions(ADDON.pinBaseSize * ADDON.Settings.MiniMap.mapScale, ADDON.pinBaseSize * ADDON.Settings.MiniMap.mapScale);
		control:SetHidden(false);
	end
	
	-- Set Pos --
	pin:SetMapPos(mapX, mapY);
	
	return pin;
end

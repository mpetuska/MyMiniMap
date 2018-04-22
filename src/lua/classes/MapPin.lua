--[[
  [] Author: Martynas Petuska
  [] E-mail: martynas.petuska@outlook.com
  [] Date:   April 2018
--]]
local UpdateInfo = MMM.UpdateInfo;
local PinType = MMM.Constants.PinType;
local Sizes = MMM.Sizes;
local UI = MMM.UI;
--====================================================== CLASS =======================================================--
---@class MapPin
local MapPin = {};
MMM.Classes.MapPin = MapPin;

local Objects = {};
local UnusedObjects = {};

local QuestPins = {};
local LocationPins = {};
local FastTravelPins = {};
local PoiPins = {};
local Waypoint = {};
--====================================================== LOCAL =======================================================--

---Finds a pin by it's type and index. If no pin is found nothing is returned in its place along with the reference table
---for pinType, otherwise the pin and the reference table are returned.
---@param pinType string
---@param pinIndex number
---@return table, table
local function FindByIndex(pinType, pinIndex)
	local obj, referenceTable;
	if (pinType == PinType.QUEST) then
		referenceTable = QuestPins;
		for _, pin in pairs(referenceTable) do
			if (pin.typeIndex == pinIndex) then
				obj = pin;
			end
		end
	elseif (pinType == PinType.LOCATION) then
		referenceTable = LocationPins;
		for _, pin in pairs(referenceTable) do
			if (pin.typeIndex == pinIndex) then
				obj = pin;
			end
		end
	elseif (pinType == PinType.POI) then
		referenceTable = PoiPins;
		for _, pin in pairs(referenceTable) do
			if (pin.typeIndex == pinIndex) then
				obj = pin;
			end
		end
	elseif (pinType == PinType.FAST_TRAVEL) then
		referenceTable = FastTravelPins;
		for _, pin in pairs(referenceTable) do
			if (pin.typeIndex == pinIndex) then
				obj = pin;
			end
		end
	elseif (pinType == PinType.WAYPOINT) then
		referenceTable = Waypoint;
		pinIndex = 1;
		for _, pin in pairs(referenceTable) do
			if (pin.typeIndex == pinIndex) then
				obj = pin;
			end
		end
	end
	return obj, referenceTable;
end

---Sets the pin's normalised coordinates in the map and updates the rotated position of its controls.
---If no arguments are passed, the controls' position is readjusted from the stored values.
---@param nX number
---@param nY number
local function SetPosition(self)
	local nX, nY = self.zoObject:GetNormalizedPosition();
	local mapRotation = 0;
	if (MMM.Settings.isMapRotationEnabled) then
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
--=============================================== EVENTS & CALLBACKS =================================================--
local function OnQuestDataRefresh(iconRefresh)
	UpdateInfo.updatePending = true;
	if (not iconRefresh) then
		MapPin.RefreshAll(PinType.QUEST);
	else
		for _, pin in pairs(QuestPins) do
			pin:RefreshIcon(true);
		end
	end
end

FOCUSED_QUEST_TRACKER:RegisterCallback("QuestTrackerTrackingStateChanged", function()
	OnQuestDataRefresh(true)
end);
CALLBACK_MANAGER:RegisterCallback("OnWorldMapQuestsDataRefresh", function()
	OnQuestDataRefresh(false)
end);
--====================================================================================================================--
---Constructor.
---@param zoPinObject table
---@return MapPin
function MapPin:New(zoPinObject)
	local pinType, obj, typeIndex, referenceTable;
	if (zoPinObject:IsLocation()) then
		pinType = PinType.LOCATION;
		typeIndex = zoPinObject:GetLocationIndex();
		obj, referenceTable = FindByIndex(pinType, typeIndex);
	elseif (zoPinObject:IsQuest()) then
		pinType = PinType.QUEST;
		typeIndex = zoPinObject:GetQuestIndex();
		obj, referenceTable = FindByIndex(pinType, typeIndex);
	elseif (zoPinObject:IsPOI()) then
		pinType = PinType.POI;
		typeIndex = zoPinObject:GetPOIIndex();
		obj, referenceTable = FindByIndex(pinType, typeIndex);
	elseif (zoPinObject:IsFastTravelKeep() or zoPinObject:IsFastTravelWayShrine()) then
		pinType = PinType.FAST_TRAVEL;
		typeIndex = zoPinObject:GetFastTravelNodeIndex();
		obj, referenceTable = FindByIndex(pinType, typeIndex);
	elseif (zoPinObject:GetPinType() == MAP_PIN_TYPE_PLAYER_WAYPOINT) then
		pinType = PinType.WAYPOINT;
		typeIndex = 1;
		obj, referenceTable = FindByIndex(pinType, typeIndex);
	else
		return ;
	end

	if (obj) then
		obj:Init(zoPinObject);
		return obj;
	elseif (referenceTable) then
		obj = table.remove(UnusedObjects);
		if (not obj) then
			obj = setmetatable({}, { __index = self });
			table.insert(Objects, obj);
			obj.objectId = #Objects;
		end
		table.insert(referenceTable, obj);
		obj:Init(zoPinObject, pinType, typeIndex);
		return obj;
	end
end

---Initialises the new object.
---@param zoPinObject table
---@param pinType string
---@param typeIndex number
function MapPin:Init(zoPinObject, pinType, typeIndex)
	if (not zoPinObject) then
		return
	end
	self.inUse = true;
	self.enabled = true;
	self.zoObject = zoPinObject;
	self.pinType = pinType or self.pinType;
	self.typeIndex = typeIndex or self.typeIndex;
	self.Controls = self.Controls or {};
	self.icon = self:GetIcon();
	
	local size = Sizes.mapPinSize * MMM.Settings.MiniMap.mapScale;
	for group, scroll in pairs(UI.Scrolls) do
		if (not self.Controls[group]) then
			local controlName = scroll:GetName() .. "_MapPin" .. tostring(self.objectId);
			self.Controls[group] = WINDOW_MANAGER:CreateControl(controlName, scroll, CT_TEXTURE);
		end
		
		self.Controls[group]:SetTexture(self.icon);
		self.Controls[group]:SetDimensions(size, size);
		self.Controls[group]:SetHidden(not self.enabled);
		self.Controls[group]:SetPixelRoundingEnabled(false);
		if (self.pinType == PinType.WAYPOINT) then
			self.Controls[group]:SetDrawLevel(5);
		elseif (self.pinType == PinType.QUEST) then
			if (self.zoObject:IsAssisted()) then
				self.Controls[group]:SetDrawLevel(4);
			end
			self.Controls[group]:SetDrawLevel(3);
		elseif (self.pinType == PinType.FAST_TRAVEL) then
			self.Controls[group]:SetDrawLevel(2);
		else
			self.Controls[group]:SetDrawLevel(1);
		end
	end
	
	SetPosition(self);
	self:RefreshIcon();
end

---Gets the icon texture path string for the pin
---@return string
function MapPin:GetIcon()
	if (self.zoObject:IsLocation()) then
		return self.zoObject:GetLocationIcon();
	elseif (self.zoObject:IsPOI()) then
		return self.zoObject:GetPOIIcon();
	elseif (self.zoObject:IsFastTravelWayShrine() or self.zoObject:IsFastTravelKeep()) then
		return self.zoObject:GetFastTravelIcons();
	elseif (self.zoObject:IsQuest()) then
		return self.zoObject:GetQuestIcon();
	elseif (self.zoObject:GetPinType() == MAP_PIN_TYPE_PLAYER_WAYPOINT) then
		return self.zoObject:GetControl():GetChild(2):GetTextureFileName();
	end
end

---Gets the pin's normalised coordinates in the map.
---@return number, number
function MapPin:GetPosition()
	return self.zoObject:GetNormalizedPosition();
end

---Enables/disables the pin.
---@param isEnabled boolean
function MapPin:SetEnabled(isEnabled)
	self.enabled = isEnabled;
	for _, control in pairs(self.Controls) do
		control:SetHidden(not self.enabled);
	end
end

---Returns whether the pin is enabled.
---@return boolean
function MapPin:IsEnabled()
	return self.inUse and self.enabled;
end

---Updates the pin.
function MapPin:Update()
	if (self:IsEnabled()) then
		self:RefreshIcon();
		SetPosition(self);
	end
end

---Refreshes pin's icon.
---@param force boolean
function MapPin:RefreshIcon(force)
	if (not self:IsEnabled()) then
		return
	end
	
	if (force or self.icon ~= self:GetIcon()) then
		self.icon = self:GetIcon();
		if (not self.icon or string.find(self.icon, "icon_missing")) then
			return self:Remove();
		end
		for group, scroll in pairs(UI.Scrolls) do
			self.Controls[group]:SetTexture(self.icon);
		end
	end
end

---Removes the pin from usage by disabling its controls and preparing for re-use queue.
function MapPin:Remove()
	self:SetEnabled(false);
	self.inUse = false;
	local _, referenceTable = FindByIndex(self.pinType, self.typeIndex);
	table.remove(referenceTable, self.typeIndex);
	table.insert(UnusedObjects, self);
end
--====================================================== STATIC ======================================================--
---Removes a pin from usage.
---@param pinType string
---@param pinIndex number
function MapPin.RemovePin(pinType, pinIndex)
	local pin = FindByIndex(pinType, pinIndex);
	if (pin) then
		pin:Remove();
	end
end

---Updates all registered pins.
function MapPin.UpdateAll()
	for _, pin in pairs(Objects) do
		pin:Update();
	end
end

---Enables/disables all registered pins.
---@param areEnabled boolean
function MapPin.SetEnabledAll(areEnabled)
	for _, pin in pairs(Objects) do
		pin:SetEnabled(areEnabled);
	end
end

---Refreshes all pins of the given PinType(s). If no PinType is given, refreshes all pins.
---@param ... string
function MapPin.RefreshAll(...)
	local pinTypes = { ... };
	local referenceTables = {};
	if (#pinTypes > 0) then
		for _, type in pairs(pinTypes) do
			local _, referenceTable = FindByIndex(type);
			table.insert(referenceTables, referenceTable);
			for _, pin in pairs(referenceTable) do
				pin.inUse = false;
			end
		end
	else
		for _, pin in pairs(Objects) do
			if (not pin.inUse) then
				pin.inUse = false;
			end
		end
	end

	for i, pin in pairs(ZO_WorldMap_GetPinManager():GetActiveObjects()) do
		if (#pinTypes > 0) then
			if (table.contains(pinTypes, PinType.POI) and pin:IsPOI()) then
				MapPin:New(pin);
			elseif (table.contains(pinTypes, PinType.LOCATION) and pin:IsLocation()) then
				MapPin:New(pin);
			elseif (table.contains(pinTypes, PinType.FAST_TRAVEL) and (pin:IsFastTravelKeep() or pin:IsFastTravelWayShrine())) then
				MapPin:New(pin);
			elseif (table.contains(pinTypes, PinType.QUEST) and pin:IsQuest()) then
				MapPin:New(pin);
			end
		else
			MapPin:New(pin);
		end
	end

	if (#pinTypes > 0) then
		for _, referenceTable in pairs(referenceTables) do
			for _, pin in pairs(referenceTable) do
				if (not pin.inUse) then
					pin:Remove();
				end
			end
		end
	else
		for _, pin in pairs(Objects) do
			if (not pin.inUse) then
				pin:Remove();
			end
		end
	end
end

function MapPin.RemoveAll()
	for _, pin in pairs(Objects) do
		pin:Remove();
	end
end
--====================================================================================================================--
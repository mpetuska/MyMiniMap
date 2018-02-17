--[[
  [] Author: Martynas Petuska
  [] E-mail: martynas.petuska@outlook.com
  [] Date:   January 2018
--]]
---------------- NAMESPACE ----------------
local UI = ADDON.UI;
local UpdateInfo = ADDON.UpdateInfo;
-------------------------------------------

---Checks is the given normalized map coordinates are inside the mini map wheel.
---@param normalizedX number
---@param normalizedY number
---@return boolean
function UI:AreCoordinatesInsideWheel(normalizedX, normalizedY)
	local centerX, centerY = UpdateInfo.Player.normX, UpdateInfo.Player.normY;
	local r = UI.miniMap:GetWidth() / UpdateInfo.Map.width;
	local dx, dy = normalizedX - centerX, normalizedY - centerY;
	
	return (math.sqrt((dx * dx) + (dy * dy)) <= r);
end

function UI:IsPinInsideWheel(pin)
	if (not pin) then
		return;
	end
	
	local nX, nY = pin:GetMapPos();
	local pinRadius = pin:GetDimensions() / 2;
	local nR = pinRadius / UpdateInfo.Map.width;
	
	return UI:AreCoordinatesInsideWheel(nX - nR, nY - nR) or
			UI:AreCoordinatesInsideWheel(nX + nR, nY - nR) or
			UI:AreCoordinatesInsideWheel(nX + nR, nY + nR) or
			UI:AreCoordinatesInsideWheel(nX - nR, nY + nR);
end

--- Creates a Wayshrine Pin Object for a given nodeIndex from GetNumFastTravelNodes()
--- with a control attached to it and adds it to the ADDON.UI.Pins lists.
---@param nodeIndex number
---@return void
function UI:CreateWayshrinePin(nodeIndex)
	local known, name, nX, nY, icon, glowIcon = GetFastTravelNodeInfo(nodeIndex);
	if (name ~= "Seyda Neen Wayshrine") then
		return
	end
	if known or ADDON.Settings.showUnexploredPins then
		if not known then
			icon = "/esoui/art/icons/poi/poi_wayshrine_incomplete.dds";
			glowIcon = "/esoui/art/icons/poi/poi_wayshrine_glow.dds";
		end
		local tag = ZO_MapPin.CreateTravelNetworkPinTag(nodeIndex, icon, glowIcon);
		local pinType = MAP_PIN_TYPE_FAST_TRAVEL_WAYSHRINE;
		
		if (UI.PinObjects[nodeIndex] == nil) then
			UI.PinObjects[nodeIndex] = ZO_Object.New(ZO_MapPin);
		end
		local pinObject = UI.PinObjects[nodeIndex];
		pinObject.m_PinType = pinType;
		pinObject.m_PinTag = tag;
		pinObject.nX = nX;
		pinObject.nY = nY;
		
		for group, control in pairs(UI.PinControls) do
			local pinControl = GetControl(control:GetName() .. tostring(nodeIndex));
			if (pinControl == nil) then
				pinControl = WINDOW_MANAGER:CreateControl(control:GetName() .. tostring(nodeIndex), control, CT_TEXTURE);
			end
			UI.Pins[group][nodeIndex] = pinControl;
			pinObject[group] = pinControl;
			pinControl:SetDimensions(ADDON.pinBaseSize * ADDON.Settings.MiniMap.mapScale, ADDON.pinBaseSize * ADDON.Settings.MiniMap.mapScale);
			pinControl.object = pinObject;
			pinControl.type = pinType;
			pinControl.tag = tag;
			pinControl.nX = nX;
			pinControl.nY = nY;
			pinControl.GetPosition = function(self)
				return self.object.nX, self.object.nY;
			end
			pinControl:SetHidden(false);
			pinControl:ClearAnchors();
			pinControl:SetTexture(tag[2]);
			pinControl:SetMouseEnabled(false);
			pinControl.UpdatePosition = function(self)
				local nX, nY = self:GetPosition();
				local iX = (nX * UpdateInfo.Map.width) - UpdateInfo.Player.normX;
				local iY = (nY * UpdateInfo.Map.height) - UpdateInfo.Player.normY;
				local rX = (math.cos(-UpdateInfo.Player.rotation) * iX) - (math.sin(-UpdateInfo.Player.rotation) * iY);
				local rY = (math.sin(-UpdateInfo.Player.rotation) * iX) + (math.cos(-UpdateInfo.Player.rotation) * iY);
				
				self:SetAnchor(CENTER, UI.Maps[group], TOPLEFT, zo_round(rX), zo_round(rY));
			end
		end
	end
end

--- Collects all the UI elements into the convenience list.
---@return void
local function GatherUiElements()
	UI.miniMap = MyMiniMap
	UI.wheel = MyMiniMapWheel;
	UI.background = MyMiniMapBackground;
	UI.playerPin = MyMiniMapPlayerPin;
	UI.Scrolls = {
		center = MyMiniMapCenterScroll,
		horizontal = MyMiniMapHorizontalScroll,
		vertical = MyMiniMapVerticalScroll
	};
	UI.Maps = {
		center = MyMiniMapCenterScrollMap,
		horizontal = MyMiniMapHorizontalScrollMap,
		vertical = MyMiniMapVerticalScrollMap
	};
	UI.MapTiles = {
		center = {},
		horizontal = {},
		vertical = {}
	};
	UI.PinObjects = {};
end

--- Rescales the UI.
---@return void
function UI:Rescale()
	local size = ADDON.baseSize * ADDON.Settings.MiniMap.mapScale;
	UI.playerPin:SetDimensions(ADDON.pinBaseSize * ADDON.Settings.MiniMap.mapScale, ADDON.pinBaseSize * ADDON.Settings.MiniMap.mapScale);
	
	UI.wheel:SetDimensions(size, size);
	UI.background:SetDimensions(size, size);
	UI.miniMap:SetDimensions(size, size);
	
	for name, scroll in pairs(UI.Scrolls) do
		scroll:ClearAnchors();
		scroll:SetAnchor(CENTER, MiniMapTestWheel, CENTER);
		scroll:SetScrollBounding(0);
	end
	local scrollScaleBase = ADDON.Settings.MiniMap.scrollScaleBase;
	local scrollScaleOffset = ADDON.Settings.MiniMap.scrollScaleOffset;
	UI.Scrolls.center:SetDimensions(size * scrollScaleBase, size * scrollScaleBase);
	UI.Scrolls.horizontal:SetDimensions(size * (scrollScaleBase + scrollScaleOffset), size * (scrollScaleBase - scrollScaleOffset));
	UI.Scrolls.vertical:SetDimensions(size * (scrollScaleBase - scrollScaleOffset), size * (scrollScaleBase + scrollScaleOffset));
	
	for name, map in pairs(UI.Maps) do
		map:ClearAnchors();
		map:SetAnchor(CENTER, UI.Scrolls[name], CENTER)
	end
end

--- Reposition the UI.
---@return void
function UI:Reposition()
	UI.miniMap:ClearAnchors();
	UI.miniMap:SetAnchor(CENTER, GuiRoot, CENTER, ADDON.Settings.MiniMap.Position.x, ADDON.Settings.MiniMap.Position.y);
end

--- Handles initial UI setup.
---@return void
function UI:Setup()
	GatherUiElements();
	UI:Rescale();
	UI:Reposition()
	UI.isSetup = true;
end

--- Reloads entire UI to pull in newest settings.
---@return void
function UI:Reload()
	UI:Rescale();
	UI.wheel:SetTextureRotation(0);
	UI.playerPin:SetTextureRotation(0);
	UI.UpdateMap();
end
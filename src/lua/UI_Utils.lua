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
	local r = UI.miniMap:GetDimensions() / UpdateInfo.Map.width;
	local dx, dy = normalizedX - centerX, normalizedY - centerY;
	
	return (math.sqrt((dx * dx) + (dy * dy)) <= r);
end

--- Collects all the UI elements into the convenience list.
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
	}
	UI.Pins = {
		center = MyMiniMapCenterScrollPins,
		horizontal = MyMiniMapHorizontalScrollPins,
		vertical = MyMiniMapVerticalScrollPins
	}
end

--- Rescales the UI.
function UI:Rescale()
	local size = ADDON.baseSize * ADDON.Settings.MiniMap.mapScale;
	UI.playerPin:SetDimensions(32 * ADDON.Settings.MiniMap.mapScale, 32 * ADDON.Settings.MiniMap.mapScale);
	
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
function UI:Reposition()
	UI.miniMap:ClearAnchors();
	UI.miniMap:SetAnchor(CENTER, GuiRoot, CENTER, ADDON.Settings.MiniMap.Position.x, ADDON.Settings.MiniMap.Position.y);
end

--- Handles initial UI setup.
function UI:Setup()
	GatherUiElements();
	UI:Rescale();
	UI:Reposition()
	UI.isSetup = true;
end

--- Reloads entire UI to pull in newest settings.
function UI:Reload()
	UI:Rescale();
	UI.wheel:SetTextureRotation(0);
	UI.playerPin:SetTextureRotation(0);
	UI.UpdateMap();
end
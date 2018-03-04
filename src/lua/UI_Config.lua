--[[
  [] Author: Martynas Petuska
  [] E-mail: martynas.petuska@outlook.com
  [] Date:   January 2018
--]]
---------------- NAMESPACE ----------------
local UI = ADDON.UI;
local UpdateInfo = ADDON.UpdateInfo;
-------------------------------------------

---Constructs the map.
---@param mapId number
---@param zoneId number
---@return void
function UI:ConstructMap()
	UpdateInfo.Map.mapId = GetCurrentMapIndex();
	UpdateInfo.Map.zoneId = GetCurrentMapZoneIndex();
	UpdateInfo.Map.tileCountX, UpdateInfo.Map.tileCountY = GetMapNumTiles();
	
	local tileCountHor, tileCountVer = UpdateInfo.Map.tileCountX, UpdateInfo.Map.tileCountY;
	local tileSize = ADDON.Sizes.miniMapSize * ADDON.Settings.MiniMap.mapScale * ADDON.Settings.MiniMap.mapZoom;
	
	UpdateInfo.Map.width = tileSize * tileCountHor;
	UpdateInfo.Map.height = tileSize * tileCountVer;
	
	local x, y = 1, 1;
	repeat
		local tileIndex = x + (tileCountHor * (y - 1));
		local nX = (x - 1) * tileSize / UpdateInfo.Map.width;
		local nY = (y - 1) * tileSize / UpdateInfo.Map.height;
		ADDON.Classes.MapTile:New(UpdateInfo.Map.mapId, UpdateInfo.Map.zoneId, tileIndex, nX, nY, tileSize)
		
		if (x == tileCountHor and y < tileCountVer) then
			x = 1;
			y = y + 1;
		else
			x = x + 1;
		end
	until ( x > tileCountHor or y > tileCountVer )
	
	-- Map Pins --
	for nodeIndex = 1, GetNumFastTravelNodes() do
		local known, name, nX, nY, icon, glowIcon, poiType, isShownInCurrentMap = GetFastTravelNodeInfo(nodeIndex);
		if (isShownInCurrentMap and known) then
			ADDON.Classes.FastTravelPin:New(nodeIndex, known, name, nX, nY, icon, glowIcon, poiType);
		end
	end
end

---Refreshes map's scale from the update info properties.
function UI:RescaleMap()
	local tileCountHor, tileCountVer = UpdateInfo.Map.tileCountX, UpdateInfo.Map.tileCountY;
	local tileSize = ADDON.Sizes.miniMapSize * ADDON.Settings.MiniMap.mapScale * ADDON.Settings.MiniMap.mapZoom;
	
	UpdateInfo.Map.width = tileSize * tileCountHor;
	UpdateInfo.Map.height = tileSize * tileCountVer;
	for _, tile in pairs(ADDON.Classes.MapTile.Objects) do
		tile:Resize(tileSize);
	end
	
	UI:UpdateMapTiles();
	UI:UpdatePins();
end

---Updates map pins.
function UI:UpdatePins()
	for _, pin in pairs(ADDON.Classes.FastTravelPin.Objects) do
		pin:Update();
	end
end

---Updates map tiles.
function UI:UpdateMapTiles()
	for _, tile in pairs(ADDON.Classes.MapTile.Objects) do
		tile:Update();
	end
end

---Refreshes required properties for update.
function UI:RefreshUpdateInfo()
	local playerX, playerY, playerRotation = GetMapPlayerPosition("player");
	local rotation;
	if (ADDON.Settings.isMapRotationEnabled) then
		rotation = GetPlayerCameraHeading();
	else
		rotation = playerRotation;
	end
	
	if (UpdateInfo.Player.nX == playerX and UpdateInfo.Player.nY == playerY and UpdateInfo.Player.rotation == rotation) then
		UpdateInfo.updatePending = false;
	else
		UpdateInfo.updatePending = true;
	end
	UpdateInfo.Player.nX = playerX;
	UpdateInfo.Player.nY = playerY;
	UpdateInfo.Player.rotation = rotation;
end

--- Handles map's update logic.
---@return void
function UI:UpdateMap()
	UI:RefreshUpdateInfo();
	if (UpdateInfo.updatePending) then
		UI:UpdateMapTiles();
		UI:UpdatePins();
		
		if (not ADDON.Settings.isMapRotationEnabled) then
			UI.playerPin:SetTextureRotation(UpdateInfo.Player.rotation);
		else
			UI.wheel:SetTextureRotation(-UpdateInfo.Player.rotation);
		end
	end
end
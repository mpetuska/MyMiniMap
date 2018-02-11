--[[
  [] Author: Martynas Petuska
  [] E-mail: martynas.petuska@outlook.com
  [] Date:   January 2018
--]]
---------------- NAMESPACE ----------------
local UI = ADDON.UI;
local UpdateInfo = ADDON.UpdateInfo;
-------------------------------------------

--- Constructs the map for a given map and zone.
---@param mapId number
---@param zoneId number
---@return void
function UI:ConstructMap(mapId, zoneId)
	UpdateInfo.Map.mapId = mapId;
	UpdateInfo.Map.zoneId = zoneId;
	UpdateInfo.Map.tileCountX, UpdateInfo.Map.tileCountY = GetMapNumTiles();
	
	local tileCountHor, tileCountVer = UpdateInfo.Map.tileCountX, UpdateInfo.Map.tileCountY;
	local tileSize = ADDON.baseSize * ADDON.Settings.MiniMap.mapScale * ADDON.Settings.MiniMap.mapZoom;
	
	UpdateInfo.Map.width = tileSize * tileCountHor;
	UpdateInfo.Map.height = tileSize * tileCountVer;
	for _, map in pairs(UI.Maps) do
		map:SetDimensions(UpdateInfo.Map.width, UpdateInfo.Map.height)
	end
	
	local x, y = 1, 1;
	repeat
		local tileIndex = x + (tileCountHor * (y - 1));
		local tileTexture = GetMapTileTexture(tileIndex)
		for group, mapTileControl in pairs(UI.MapTiles) do
			if (mapTileControl[tileIndex] == nil) then
				local parent = UI.Maps[group];
				local name = UI.Maps[group]:GetName() .. tostring(tileIndex);
				mapTileControl[tileIndex] = WINDOW_MANAGER:CreateControl(name, parent, CT_TEXTURE);
			end
			
			mapTileControl[tileIndex]:SetDrawLayer(1);
			mapTileControl[tileIndex]:SetTexture(tileTexture);
			
			mapTileControl[tileIndex]:SetDimensions(tileSize, tileSize);
			mapTileControl[tileIndex]:ClearAnchors();
			mapTileControl[tileIndex]:SetAnchor(TOPLEFT, UI.Maps[group], TOPLEFT, (x - 1) * tileSize, (y - 1) * tileSize);
		end
		
		if (x == tileCountHor and y < tileCountVer) then
			x = 1;
			y = y + 1;
		else
			x = x + 1;
		end
	until ( x > tileCountHor or y > tileCountVer )
end

--- Updates map's position to the given normalised coordinates.
---@param nX number
---@param nY number
---@return void
function UI:UpdateMapPosition(nX, nY)
	UpdateInfo.Player.normX, UpdateInfo.Player.normY = nX, nY;
	
	local mapWidth, mapHeight = UpdateInfo.Map.width, UpdateInfo.Map.height;
	local offsetX, offsetY = mapWidth * (0.5 - nX), mapHeight * (0.5 - nY);
	for _, map in pairs(UI.Maps) do
		map:ClearAnchors();
		map:SetAnchor(CENTER, UI.wheel, CENTER, offsetX, offsetY);
	end
end

--- Updates map's or player pin's rotation to a given rotation in radians.
---@param rotation number
---@return void
function UI:UpdateMapRotation(rotation)
	UpdateInfo.Player.rotation = rotation;
	
	if (ADDON.Settings.isMapRotationEnabled) then
		for group, mapTiles in pairs(UI.MapTiles) do
			for i = 1, UpdateInfo.Map.tileCountX * UpdateInfo.Map.tileCountY do
				local tileWidth, tileHeight = mapTiles[i]:GetDimensions();
				local tileCenterX, tileCenterY = mapTiles[i]:GetCenter();
				local wheelCenterX, wheelCenterY = UI.wheel:GetCenter();
				
				local dx, dy = wheelCenterX - tileCenterX, wheelCenterY - tileCenterY;
				local normalizedRotationPointX = ((tileWidth / 2) + dx) / tileWidth;
				local normalizedRotationPointY = ((tileHeight / 2) + dy) / tileHeight;
				mapTiles[i]:SetTextureRotation(-rotation, normalizedRotationPointX, normalizedRotationPointY);
			end
		end
		UI.wheel:SetTextureRotation(-rotation);
	else
		UI.playerPin:SetTextureRotation(rotation);
	end
end

--- Handles map's update logic.
---@return void
function UI:UpdateMap()
	---------- Details -----------
	local mapId, zoneId = GetCurrentMapIndex(), GetCurrentMapZoneIndex();
	local playerX, playerY, playerRotation = GetMapPlayerPosition("player");
	local rotation;
	if (ADDON.Settings.isInCameraMode) then
		rotation = GetPlayerCameraHeading();
	else
		rotation = playerRotation;
	end
	------------- Map ------------
	if (UpdateInfo.Map.mapId ~= mapId or UpdateInfo.Map.zoneId ~= zoneId) then
		UI.ConstructMap(mapId, zoneId);
	end
	---------- Position ----------
	if (UpdateInfo.Player.normX ~= playerX or UpdateInfo.Player.normY ~= playerY) then
		UI:UpdateMapPosition(playerX, playerY);
		UI:UpdateMapRotation(rotation);
	else
		---------- Rotation ----------
		if (UpdateInfo.Player.rotation ~= rotation) then
			UI:UpdateMapRotation(rotation);
		end
	end
	------------ Pins ------------
end
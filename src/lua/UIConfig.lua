--[[
  [] Author: Martynas Petuska
  [] E-mail: martynas.petuska@outlook.com
  [] Date:   January 2018
--]]
------------- NAMESPACE -------------
local UI = ADDON.UI;
local UpdateInfo;
-------------------------------------
local function GatherUIElements()
	UI.miniMap = MyMiniMap
	UI.wheel = MyMiniMapWheel;
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
	UI.isSetup = false;
end

function UI:Rescale()
	local size = ADDON.Settings.MiniMap.size;
	local playerPinSize = 32 * size / 512;
	UI.playerPin:SetDimensions(playerPinSize, playerPinSize);
	UI.wheel:SetDimensions(size, size)
	UI.miniMap:SetDimensions(size, size)
	
	for name, scroll in pairs(UI.Scrolls) do
		scroll:ClearAnchors();
		scroll:SetScrollBounding(0)
		scroll:SetAnchor(CENTER, MiniMapTestWheel, CENTER)
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

function UI:ConfigureUI()
	UpdateInfo = ADDON.Settings.MiniMap.UpdateInfo;
	GatherUIElements();
	UI:Rescale();
	
	UI.isSetup = true;
end

------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

function UI:GetCurrentMapTextureFileInfo()
	--TODO make it return right tile
	local horTileCount, verTileCount = GetMapNumTiles();
	local playerX, playerY, heading = GetMapPlayerPosition("player");
	local px, py = playerX, playerY;
	
	local tileTexture = (GetMapTileTexture()):lower()
	if tileTexture == nil or tileTexture == "" then
		return "tamriel_0", "tamriel_", "art/maps/tamriel/"
	end
	local pos = select(2, tileTexture:find("maps/([%w%-]+)/"))
	if pos == nil then
		return "tamriel_0", "tamriel_", "art/maps/tamriel/"
	end
	pos = pos + 1
	--return string.gsub(string.sub(tileTexture, pos), ".dds", ""), string.gsub(string.sub(tileTexture, pos), "0.dds", ""), string.sub(tileTexture, 1, pos - 1)
	return GetMapTileTexture(pos);
end

function UI:ConstructMap()
	UpdateInfo.Map.mapId = GetCurrentMapIndex();
	UpdateInfo.Map.zoneId = GetCurrentMapZoneIndex();
	UpdateInfo.Map.tileCountX, UpdateInfo.Map.tileCountY = GetMapNumTiles();
	
	local tileCountHor, tileCountVer = UpdateInfo.Map.tileCountX, UpdateInfo.Map.tileCountY;
	local tileSize = ADDON.Settings.MiniMap.size * ADDON.Settings.MiniMap.mapZoom;
	
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
				local parent = UI.Maps[group]
				local name = UI.Maps[group]:GetName() .. tostring(tileIndex)
				mapTileControl[tileIndex] = WINDOW_MANAGER:CreateControl(name, parent, CT_TEXTURE)
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
	MyMiniMapTestTile1:SetTexture(GetMapTileTexture(10))
end

function UI:UpdateMapPosition()
	local playerX, playerY = GetMapPlayerPosition("player");
	
	for _, map in pairs(UI.Maps) do
		local mapWidth, mapHeight = UpdateInfo.Map.width, UpdateInfo.Map.height;
		local offsetX, offsetY = mapWidth * (0.5 - playerX), mapHeight * (0.5 - playerY);
		
		map:ClearAnchors();
		map:SetAnchor(CENTER, UI.wheel, CENTER, offsetX, offsetY);
	end
end

function UI:UpdateMapRotation()
	local rotation = -GetPlayerCameraHeading()
	for group, mapTiles in pairs(UI.MapTiles) do
		for i = 1, UpdateInfo.Map.tileCountX * UpdateInfo.Map.tileCountY do
			local tileWidth, tileHeight = mapTiles[i]:GetDimensions();
			local tileCenterX, tileCenterY = mapTiles[i]:GetCenter()
			local wheelCenterX, wheelCenterY = UI.wheel:GetCenter()
			
			local dx, dy = wheelCenterX - tileCenterX, wheelCenterY - tileCenterY;
			local normalizedRotationPointX = ((tileWidth / 2) + dx) / tileWidth;
			local normalizedRotationPointY = ((tileHeight / 2) + dy) / tileHeight;
			mapTiles[i]:SetTextureRotation(rotation, normalizedRotationPointX, normalizedRotationPointY)
		end
	end
	
	UI.wheel:SetTextureRotation(rotation)
	
	MyMiniMapTestTile:SetTextureRotation(rotation, 0.5, 0.5)
end

function UI:UpdateMap()
	if (UpdateInfo.mapId ~= GetCurrentMapIndex() or UpdateInfo.zoneId ~= GetCurrentMapZoneIndex()) then
		UI:ConstructMap();
	end
	UI:UpdateMapPosition();
	UI:UpdateMapRotation();
end
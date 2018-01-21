--[[
  [] Author: Martynas Petuska
  [] E-mail: martynas.petuska@outlook.com
  [] Date:   January 2018
--]]
------------- NAMESPACE -------------
local UI = ADDON.UI;
-------------------------------------
local function GatherUIElements()
	UI.miniMap = MyMiniMap
	UI.wheel = MyMiniMapWheel;
	UI.playerPin = MyMiniMapPlayerPin;
	UI.Scrolls = {
		center = MyMiniMapCenterScroll,
		horizontal = MyMiniMapCenterScroll,
		vertical = MyMiniMapCenterScroll
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
	UI.isSetup = true;
end

function UI:Rescale()
	local size = ADDON.Settings.MiniMap.size;
	UI.wheel:SetDimensions(size, size)
	
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
	
	local tileSize = size * ADDON.Settings.MiniMap.mapZoom;
	for name, map in pairs(UI.Maps) do
		map:ClearAnchors();
		map:SetDimensions(tileSize, tileSize);
		map:SetAnchor(CENTER, UI.Scrolls[name], CENTER)
	end
	
	local playerPinSize = 32 / 512 * size;
	UI.playerPin:SetDimensions(playerPinSize, playerPinSize);
end

function UI:ConfigureUI()
	GatherUIElements();
	UI:Rescale();
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

function UI:SetMiniMapRotation(rotation)
	for _, map in pairs(UI.Maps) do
		local _, _, _, _, offsetX, offsetY = map:GetAnchor();
		local mapWidth, mapHeight = map:GetDimensions();
		local wheelCenterX, wheelCenterY = UI.wheel:GetCenter()
		local mapCenterX, mapCenterY = map:GetCenter()
		
		local dx, dy = wheelCenterX - mapCenterX, wheelCenterY - mapCenterY;
		local normalizedRotationPointX = (mapWidth / 2 + dx) / mapWidth;
		local normalizedRotationPointY = (mapHeight / 2 + dy) / mapHeight;
		map:SetTextureRotation(rotation, normalizedRotationPointX, normalizedRotationPointY)
	end
	
	UI.wheel:SetTextureRotation(rotation)
	
	MyMiniMapTestTile:SetTextureRotation(rotation, 0.5, 0.5)
end

function UI:SetMapTileTexture(tileTexture)
	for k, map in pairs(UI.Maps) do
		map:SetTexture(tileTexture);
	end
	
	MyMiniMapTestTile:SetTexture(tileTexture);
end

function UI:ConstructMap()
	local tileCountHor, tileCountVer = GetMapNumTiles();
	local playerX, playerY = GetMapPlayerPosition("player");
	
	local x, y = 1, 1;
	repeat
		local tileIndex = x + (tileCountHor * (y - 1));
		local tileTexture = GetMapTileTexture(tileIndex)
		--TODO
		for name, control in pairs(UI.MapTiles) do
			if (control[tileIndex] ~= nil) then
				control[tileIndex] = WINDOW_MANAGER:CreateControl(UI.Maps[name]:GetName() .. tostring(tileIndex), UI.Maps[name], CT_TEXTURE)
			end
			
			control[tileIndex]:SetTexture(tileTexture);
			local tileSize = size * ADDON.Settings.MiniMap.mapZoom;
			control[tileIndex]:SetDimensions(tileSize, tileSize);
			control[tileIndex]:SetDrawLayer(1);
			control[tileIndex]:ClearAndchors();
			if (x > 1) then
				control[tileIndex]:SetAnchor(TOPLEFT, control[tileIndex - 1], TOPRIGHT);
			elseif (y > 1) then
				control[tileIndex]:SetAnchor(TOPLEFT, control[tileIndex - y], BOTTOMLEFT);
			else
				control[tileIndex]:SetAnchor(TOPLEFT, UI.Maps[name], TOPLEFT);
			end
		end
		
		if (x == tileCountHor and y < tileCountVer) then
			x = 1;
			y = y + 1;
		else
			x = x + 1;
		end
	until ( x > tileCountHor and y > tileCountVer )
end

function UI:UpdateMapTexture()
	local tileCountHor, tileCountVer = GetMapNumTiles();
	local playerX, playerY, playerRot = GetMapPlayerPosition("player");
	local tileX = math.floor(tileCountHor * playerX);
	local tileY = math.floor(tileCountVer * playerY);
	local tileIndex = tileX + (tileCountHor * (tileY)) + 1;
	UI:SetMapTileTexture(GetMapTileTexture(tileIndex));
	
	for name, scroll in pairs(ADDON.UI.Scrolls) do
		local tileW = ADDON.UI.Maps[name]:GetWidth();
		local scrollCenterW = scroll:GetWidth() / 2;
		local mapW = tileW * tileCountHor;
		local hScroll = playerX * mapW;
		local hPos = hScroll - scrollCenterW;
		scroll:SetHorizontalScroll(hPos)
		
		local tileH = ADDON.UI.Maps[name]:GetHeight();
		local scrollCenterH = scroll:GetHeight() / 2;
		local mapH = tileH * tileCountVer;
		local vScroll = playerY * mapH;
		local vPos = vScroll - scrollCenterH;
		scroll:SetHorizontalScroll(vPos)
		
		--ADDON:Print(hPos, vPos);
	end
	
	--KINDA WORKING--
	--for name, scroll in pairs(ADDON.UI.Scrolls) do
	--	local dx = 0.5 - ((playerX * tileCountHor) % 1);
	--	local dy = 0.5 - ((playerY * tileCountVer) % 1);
	--	--ADDON:Print("dx", dx, dy)
	--
	--	local tileWidth = ADDON.UI.Maps[name]:GetWidth();
	--	local tileHeight = ADDON.UI.Maps[name]:GetHeight();
	--	ADDON:Print("dx", -dx, -dy)
	--	local hScroll = tileWidth * (-dx);
	--	local vScroll = tileHeight * (-dy);
	--	--ADDON:Print("hScroll", hScroll)
	--	scroll:SetHorizontalScroll(hScroll);
	--	scroll:SetVerticalScroll(vScroll);
	--end
	UI:SetMiniMapRotation(-GetPlayerCameraHeading())
end
--[[
  [] Author: Martynas Petuska
  [] E-mail: martynas.petuska@outlook.com
  [] Date:   January 2018
--]]
---------------- NAMESPACE ----------------
local UI = ADDON.UI;
local UpdateInfo = ADDON.UpdateInfo;
local Classes = ADDON.Classes;
local PinType = ADDON.Constants.PinType;
-------------------------------------------

---Constructs the map.
---@param subZoneId number
---@param subZoneName string
function UI:ConstructMap(subZoneName)
	if (not subZoneName or type(subZoneName) ~= "string") then
		local resultCode = SetMapToPlayerLocation();
		if (resultCode == SET_MAP_RESULT_FAILED) then
			return zo_callLater(function()
				UI:ConstructMap(subZoneName);
			end, 250);
		elseif (resultCode == SET_MAP_RESULT_MAP_CHANGED) then
			CALLBACK_MANAGER:FireCallbacks("OnWorldMapChanged");
		end
	end
	
	UpdateInfo.Map.zoneId = GetCurrentMapZoneIndex();
	UpdateInfo.Map.tileCountX, UpdateInfo.Map.tileCountY = GetMapNumTiles();
	UpdateInfo.Map.poiCount = GetNumPOIs(UpdateInfo.Map.zoneId);
	UpdateInfo.Map.locationCount = GetNumMapLocations();
	UpdateInfo.Map.subZoneName = subZoneName or GetPlayerLocationName();

	-- Allows for map pins to load.
	UI:ConstructMapTiles();
	zo_callLater(function()
		UI:ConstructMapPins();
	end, 250);
end

function UI:ConstructMapTiles()
	local subZoneName = UpdateInfo.Map.subZoneName;
	local tileSize = ADDON.Sizes.miniMapSize * ADDON.Settings.MiniMap.mapScale * ADDON.Settings.MiniMap.mapZoom;
	local tileCountHor, tileCountVer = UpdateInfo.Map.tileCountX, UpdateInfo.Map.tileCountY;
	UpdateInfo.Map.width = tileSize * tileCountHor;
	UpdateInfo.Map.height = tileSize * tileCountVer;
	
	for _, tile in pairs(Classes.MapTile.Objects) do
		tile:SetEnabled(false);
	end
	local x, y, count = 1, 1, 1;
	repeat
		local tileIndex = x + (tileCountHor * (y - 1));
		local nX = (x - 1) * tileSize / UpdateInfo.Map.width;
		local nY = (y - 1) * tileSize / UpdateInfo.Map.height;
		
		if (Classes.MapTile.Objects[count]) then
			Classes.MapTile.Objects[count]:Init(UpdateInfo.Map.zoneId, subZoneName, tileIndex, nX, nY, tileSize);
		else
			Classes.MapTile:New(UpdateInfo.Map.zoneId, subZoneName, tileIndex, nX, nY, tileSize)
		end
		
		count = count + 1;
		if (x == tileCountHor and y < tileCountVer) then
			x = 1;
			y = y + 1;
		else
			x = x + 1;
		end
	until (x > tileCountHor or y > tileCountVer)
end

function UI:ConstructMapPins()
	Classes.MapPin.RemoveAll();
	for i, pin in pairs(ZO_WorldMap_GetPinManager():GetActiveObjects()) do
		Classes.MapPin:New(pin);
	end
end

---Refreshes map's scale from the update info properties.
function UI:RescaleMap()
	local tileCountHor, tileCountVer = UpdateInfo.Map.tileCountX, UpdateInfo.Map.tileCountY;
	local tileSize = ADDON.Sizes.miniMapSize * ADDON.Settings.MiniMap.mapScale * ADDON.Settings.MiniMap.mapZoom;
	
	UpdateInfo.Map.width = tileSize * tileCountHor;
	UpdateInfo.Map.height = tileSize * tileCountVer;
	for _, tile in pairs(Classes.MapTile.Objects) do
		tile:Resize(tileSize);
	end
	
	UI:UpdateMapTiles();
	UI:UpdatePins();
end

---Updates map pins.
function UI:UpdatePins()
	Classes.MapPin.UpdateAll();
end

---Updates map tiles.
function UI:UpdateMapTiles()
	for _, tile in pairs(Classes.MapTile.Objects) do
		tile:Update();
	end
end

---Refreshes required properties for update.
function UI:RefreshUpdateInfo()
	local subZoneName = GetPlayerLocationName();
	if (UpdateInfo.Map.subZoneName ~= subZoneName and not subZoneName:lower():find("wayshrine")) then
		UI:ConstructMap(subZoneName);
	end
	
	local playerX, playerY, playerRotation = GetMapPlayerPosition("player");
	local rotation;
	if (ADDON.Settings.isMapRotationEnabled) then
		rotation = GetPlayerCameraHeading();
	else
		rotation = playerRotation;
	end
	
	if (UpdateInfo.Player.nX ~= playerX or UpdateInfo.Player.nY ~= playerY or UpdateInfo.Player.rotation ~= rotation) then
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
		UpdateInfo.updatePending = false;
	end
end
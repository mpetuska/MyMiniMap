--[[
  [] Author: Martynas Petuska
  [] E-mail: martynas.petuska@outlook.com
  [] Date:   ${MONTH_NAME_FULL} ${YEAR}
--]]
------------- NAMESPACE -------------
local addon = _G.ADDON;
-------------------------------------


-------------------------------------------------------------
-- Map Building
-------------------------------------------------------------
-- get map info for minimap
function FyrMM.UpdateMapInfo(IgnoreZone)
	local t = GetGameTimeMilliseconds()
	CurrentMap.ready = false
	CurrentMap.name = GetMapName()
	CurrentMap.tileTexture = string.lower(GetMapTileTexture())
	CurrentMap.Dx, CurrentMap.Dy = GetMapNumTiles()
	CurrentMap.filename, CurrentMap.nameNoNum, CurrentMap.path = GetCurrentMapTextureFileInfo()
	CurrentMap.filename = string.lower(CurrentMap.filename)
	CurrentMap.TextureAngle = 0
	local id = 0
	if FyrMM.MapList[CurrentMap.filename] then
		id = FyrMM.MapList[CurrentMap.filename]
	end
	if string.lower(CurrentMap.filename) == "tamriel_0" then
		zo_callLater(FyrMM.UpdateMapInfo, 5)
		return
	end
	if CurrentMap.Dx < 2 or CurrentMap.Dy < 2 or CurrentMap.Dx == nil or CurrentMap.Dy == nil then
		if id ~= 0 and FyrMM.MapData[id] then
			CurrentMap.Dx = FyrMM.MapData[id][3]
			CurrentMap.Dy = FyrMM.MapData[id][4]
		else
			CurrentMap.Dx = 3
			CurrentMap.Dy = 3
		end
	end
	CurrentMap.type = GetMapType()
	if not IgnoreZone then
		CurrentMap.ZoneId = GetCurrentMapZoneIndex()
	end
	-- if we have no texture we have nothing further to do
	if CurrentMap.tileTexture == "" or CurrentMap.Dx == nil or CurrentMap.Dy == nil then
		FyrMM.noMap = true;
		return
	else
		FyrMM.noMap = false;
	end
	
	CurrentMap.numTiles = CurrentMap.Dx * CurrentMap.Dy
	CurrentMap.TrueMapSize = 1
	if id ~= 0 and FyrMM.MapData[id] then
		CurrentMap.TrueMapSize = FyrMM.MapData[id][5]
		if FyrMM.SV.MapSizes then
			if FyrMM.SV.MapSizes[CurrentMap.filename] and CurrentMap.TrueMapSize > 1 then
				FyrMM.SV.MapSizes[CurrentMap.filename] = nil
			end
		end
	end
	-- store tile textures in table
	CurrentMap.tiles = {}
	for i = 1, CurrentMap.numTiles do
		table.insert(CurrentMap.tiles, string.lower(GetMapTileTexture(i)))
	end
	if FyrMM.SV.ZoomTable[CurrentMap.filename] == nil then
		FyrMM.SV.ZoomTable[CurrentMap.filename] = FYRMM_DEFAULT_ZOOM_LEVEL
		CurrentMap.ZoomLevel = FYRMM_DEFAULT_ZOOM_LEVEL
	else
		CurrentMap.ZoomLevel = FyrMM.SV.ZoomTable[CurrentMap.filename]
	end
	if id ~= 0 then
		CurrentMap.MapId = id
		if CurrentMap.TrueMapSize == 1 then
			if FyrMM.SV.MapSizes[CurrentMap.filename] then
				CurrentMap.TrueMapSize = FyrMM.SV.MapSizes[CurrentMap.filename]
			end
		end
	else
		CurrentMap.MapId = "unknown"
		if FyrMM.SV.MapSizes == nil then
			FyrMM.SV.MapSizes = {}
			FyrMM.SV.MapSizes[CurrentMap.filename] = 1
			CurrentMap.TrueMapSize = 1
		else
			if FyrMM.SV.MapSizes[CurrentMap.filename] ~= nil then
				CurrentMap.TrueMapSize = FyrMM.SV.MapSizes[CurrentMap.filename]
			end
		end
	end
	
	CurrentMap.ready = true
	CALLBACK_MANAGER:FireCallbacks("FyrMMDebug", "FyrMM.UpdateMapInfo " .. tostring(GetGameTimeMilliseconds() - t))
	CALLBACK_MANAGER:FireCallbacks("OnFyrMiniMapChanged")
end

-- gets tile scale for map
function FyrMM.GetTileDimensions()
	local texW, texH = Fyr_MM_Scroll_Map_0:GetTextureFileDimensions()
	local id = 0
	if FyrMM.MapList[CurrentMap.filename] then
		id = FyrMM.MapList[CurrentMap.filename]
	end
	local mr = nil
	if FyrMM.MapData[id] then
		mr = FyrMM.MapData[id]
	end
	if (texW < 256 or texH < 256) or (texW > 1024 or texH > 1024) or texW == nil or texH == nil then
		if CurrentMap.filename ~= nil then
			if mr then
				texW = mr[1]
				texH = texW
			else
				-- unknown Map
				texW = 256
				texH = 256
			end
		else
			-- unknown Map
			texW = 256
			texH = 256
		end
	end
	local dx, dy = GetMapNumTiles()
	if dx < 2 or dy < 2 or dx == nil or dy == nil and mr then
		dx = mr[3]
		dy = mr[4]
	end
	local zoomlevel = CurrentMap.ZoomLevel
	if zoomlevel == nil then
		zoomlevel = FYRMM_DEFAULT_ZOOM_LEVEL
	end
	local tileX = math.floor(zo_round(((CurrentMap.ZoomLevel / 10) * texW * dx) / dx) / 2) * 2
	local tileY = math.floor(zo_round(((CurrentMap.ZoomLevel / 10) * texW * dy) / dy) / 2) * 2
	return tileX, tileY
end

local Tiles = false
function FyrMM.UpdateMapTiles(stealth)
	local needRescale = false
	if not stealth and ((not FyrMM.Visible or Fyr_MM:IsHidden()) and not FyrMM.Initialized) then
		return
	end
	if not CurrentMap.ready then
		return
	end
	if string.lower(CurrentMap.filename) == "tamriel_0" then
		return
	end
	
	local MM_TileSizeW, MM_TileSizeH = FyrMM.GetTileDimensions()
	if Fyr_MM_Scroll_Map_0:GetTextureFileName():lower() == CurrentMap.tiles[1]:lower() and
			zo_round(Fyr_MM_Scroll_Map_0:GetWidth()) == zo_round(MM_TileSizeW) and
			zo_round(Fyr_MM_Scroll_Map_0:GetHeight()) == zo_round(MM_TileSizeH) then
		if stealth == GetFrameTimeMilliseconds() then
			return
		end
	else
		if zo_round(Fyr_MM_Scroll_Map_0:GetWidth()) ~= zo_round(MM_TileSizeW) or zo_round(Fyr_MM_Scroll_Map_0:GetHeight()) ~= zo_round(MM_TileSizeH) then
			CurrentMap.needRescale = true
		end
	end -- nothing to update if same map
	if Tiles then
		return
	end
	Tiles = true
	CALLBACK_MANAGER:FireCallbacks("FyrMMDebug", "FyrMM.UpdateMapTiles " .. tostring(stealth))
	local sa, sb, centerSize
	local i = 0
	
	local MM_TileSizeW, MM_TileSizeH = FyrMM.GetTileDimensions()
	local mWidth, mHeight = MM_TileSizeW * CurrentMap.Dx, MM_TileSizeH * CurrentMap.Dy
	Fyr_MM_Scroll_Map:SetDimensions(mWidth, mHeight)
	if not FyrMM.SV.WheelMap then
		Fyr_MM_Bg:SetColor(0, 0, 0, 1)
		Fyr_MM_Scroll_WheelNS:SetHidden(true)
		Fyr_MM_Scroll_WheelCenter:SetHidden(true)
		Fyr_MM_Scroll_WheelWE:SetHidden(true)
	else
		Fyr_MM_Bg:SetColor(1, 1, 1, 0)
		Fyr_MM_Border:SetHidden(true)
		sa = Fyr_MM:GetWidth() - ((50 / 512) * Fyr_MM:GetWidth())
		sb = (220 / 512) * Fyr_MM:GetWidth()
		Fyr_MM_Scroll_WheelWE:SetDimensions(sa, sb)
		Fyr_MM_Scroll_WheelNS:SetDimensions(sb, sa)
		Fyr_MM_Frame_Control:SetDimensions(Fyr_MM:GetWidth(), Fyr_MM:GetWidth())
		Fyr_MM_Frame_Wheel:SetDimensions(Fyr_MM:GetWidth() + 8, Fyr_MM:GetWidth() + 8)
		if FyrMM.SV.RotateMap then
			Fyr_MM_Frame_Wheel:SetTextureRotation(CurrentMap.Heading)
		end
		centerSize = math.sqrt(2 * Fyr_MM:GetWidth() * Fyr_MM:GetWidth()) / 2
		Fyr_MM_Scroll_WheelCenter:SetDimensions(centerSize, centerSize)
		if not CurrentMap.PlayerX or not CurrentMap.PlayerY or not CurrentMap.Heading then
			local x, y, pheading = GetMapPlayerPosition("player")
			CurrentMap.PlayerNX = x
			CurrentMap.PlayerNY = y
			CurrentMap.PlayerX, CurrentMap.PlayerY = Fyr_MM_Scroll_Map:GetDimensions()
			CurrentMap.PlayerX = CurrentMap.PlayerX * x
			CurrentMap.PlayerY = CurrentMap.PlayerY * y
			CurrentMap.Heading = math.abs(pheading - pi * 2)
		end
	
	end
	local tilec, tilens, tilewe
	local tileposX, tileposY, x, y
	for a = 1, CurrentMap.Dy do
		for b = 1, CurrentMap.Dx do
			i = i + 1
			local tileControl = GetControl("Fyr_MM_Scroll_Map_" .. tostring(i - 1))
			if tileControl == nil then
				tileControl = WINDOW_MANAGER:CreateControl("Fyr_MM_Scroll_Map_" .. tostring(i - 1), Fyr_MM_Scroll_Map, CT_TEXTURE)
			end
			local tilens = GetControl("Fyr_MM_Scroll_WNS_Map_" .. tostring(i - 1))
			if tilens == nil then
				tilens = WINDOW_MANAGER:CreateControl("Fyr_MM_Scroll_WNS_Map_" .. tostring(i - 1), Fyr_MM_Scroll_WheelNS, CT_TEXTURE)
			end
			local tilec = GetControl("Fyr_MM_Scroll_CW_Map_" .. tostring(i - 1))
			if tilec == nil then
				tilec = WINDOW_MANAGER:CreateControl("Fyr_MM_Scroll_CW_Map_" .. tostring(i - 1), Fyr_MM_Scroll_WheelCenter, CT_TEXTURE)
			end
			local tilewe = GetControl("Fyr_MM_Scroll_WWE_Map_" .. tostring(i - 1))
			if tilewe == nil then
				tilewe = WINDOW_MANAGER:CreateControl("Fyr_MM_Scroll_WWE_Map_" .. tostring(i - 1), Fyr_MM_Scroll_WheelWE, CT_TEXTURE)
			end
			tileControl:SetHidden(FyrMM.SV.WheelMap)
			tilens:SetHidden(not FyrMM.SV.WheelMap)
			tilec:SetHidden(not FyrMM.SV.WheelMap)
			tilewe:SetHidden(not FyrMM.SV.WheelMap)
			if tileControl:GetTextureFileName():lower() ~= CurrentMap.tiles[i]:lower() then
				tileControl:SetTexture(CurrentMap.tiles[i])
				tilens:SetTexture(CurrentMap.tiles[i])
				tilec:SetTexture(CurrentMap.tiles[i])
				tilewe:SetTexture(CurrentMap.tiles[i])
			end
			tileControl:SetDimensions(FyrMM.GetTileDimensions())
			tilens:SetDimensions(FyrMM.GetTileDimensions())
			tilec:SetDimensions(FyrMM.GetTileDimensions())
			tilewe:SetDimensions(FyrMM.GetTileDimensions())
			tileControl:SetDrawLayer(0)
			tilens:SetDrawLayer(1)
			tilec:SetDrawLayer(1)
			tilewe:SetDrawLayer(1)
			tilens:ClearAnchors()
			tilec:ClearAnchors()
			tilewe:ClearAnchors()
			tileControl:ClearAnchors()
			if FyrMM.SV.RotateMap then
				if not CurrentMap.PlayerX or not CurrentMap.PlayerY or not CurrentMap.Heading then
					local x, y, pheading = GetMapPlayerPosition("player")
					CurrentMap.PlayerNX = x
					CurrentMap.PlayerNY = y
					CurrentMap.PlayerX, CurrentMap.PlayerY = Fyr_MM_Scroll_Map:GetDimensions()
					CurrentMap.PlayerX = CurrentMap.PlayerX * x
					CurrentMap.PlayerY = CurrentMap.PlayerY * y
					CurrentMap.Heading = math.abs(pheading - pi * 2)
				end
				x = ((b - 0.5) * mWidth / CurrentMap.Dx) - CurrentMap.PlayerX
				y = ((a - 0.5) * mHeight / CurrentMap.Dy) - CurrentMap.PlayerY
				tileposX = (math.cos(-CurrentMap.Heading) * x) - (math.sin(-CurrentMap.Heading) * y)
				tileposY = (math.sin(-CurrentMap.Heading) * x) + (math.cos(-CurrentMap.Heading) * y)
				tileControl:SetTextureRotation(CurrentMap.Heading, 0.5, 0.5);
				tilens:SetTextureRotation(CurrentMap.Heading, 0.5, 0.5);
				tilec:SetTextureRotation(CurrentMap.Heading, 0.5, 0.5);
				tilewe:SetTextureRotation(CurrentMap.Heading, 0.5, 0.5);
				if FyrMM.SV.MapAlpha > 80 then
					tilens:SetScale(1.0055)
					tilec:SetScale(1.0055)
					tilewe:SetScale(1.0055)
					tileControl:SetScale(1.0055)
				else
					tilens:SetScale(1)
					tilec:SetScale(1)
					tilewe:SetScale(1)
					tileControl:SetScale(1)
				end
				tileControl:SetAnchor(CENTER, Fyr_MM_Scroll, CENTER, tileposX, tileposY)
				tilens:SetAnchor(CENTER, Fyr_MM_Scroll_WheelNS, CENTER, tileposX, tileposY)
				tilec:SetAnchor(CENTER, Fyr_MM_Scroll_WheelCenter, CENTER, tileposX, tileposY)
				tilewe:SetAnchor(CENTER, Fyr_MM_Scroll_WheelWE, CENTER, tileposX, tileposY)
			else
				tileposX = ((b - 0.5) * mWidth / CurrentMap.Dx) - mWidth / 2
				tileposY = ((a - 0.5) * mHeight / CurrentMap.Dy) - mHeight / 2
				tileControl:SetScale(1)
				tilens:SetScale(1)
				tilec:SetScale(1)
				tilewe:SetScale(1)
				tileControl:SetTextureRotation(0)
				tilens:SetTextureRotation(0)
				tilec:SetTextureRotation(0)
				tilewe:SetTextureRotation(0)
				tileControl:SetAnchor(CENTER, Fyr_MM_Scroll_Map, CENTER, tileposX, tileposY)
				tilens:SetAnchor(CENTER, Fyr_MM_Scroll_Map, CENTER, tileposX, tileposY)
				tilec:SetAnchor(CENTER, Fyr_MM_Scroll_Map, CENTER, tileposX, tileposY)
				tilewe:SetAnchor(CENTER, Fyr_MM_Scroll_Map, CENTER, tileposX, tileposY)
				tileControl:SetAnchor(CENTER, Fyr_MM_Scroll_Map, CENTER, tileposX, tileposY)
				tilens:SetAnchor(CENTER, Fyr_MM_Scroll_Map, CENTER, tileposX, tileposY)
				tilec:SetAnchor(CENTER, Fyr_MM_Scroll_Map, CENTER, tileposX, tileposY)
				tilewe:SetAnchor(CENTER, Fyr_MM_Scroll_Map, CENTER, tileposX, tileposY)
			
			
			end
		
		end
	end
	for j = i, Fyr_MM_Scroll_Map:GetNumChildren() do
		tileControl = GetControl("Fyr_MM_Scroll_Map_" .. tostring(j))
		tilens = GetControl("Fyr_MM_Scroll_WNS_Map_" .. tostring(j))
		tilec = GetControl("Fyr_MM_Scroll_CW_Map_" .. tostring(j))
		tilewe = GetControl("Fyr_MM_Scroll_WWE_Map_" .. tostring(j))
		if (tileControl) then
			tileControl:ClearAnchors()
			tileControl:SetHidden(true)
		end
		if (tilens) then
			tilens:ClearAnchors()
			tilens:SetHidden(true)
		end
		if (tilec) then
			tilec:ClearAnchors()
			tilec:SetHidden(true)
		end
		if (tilewe) then
			tilewe:ClearAnchors()
			tilewe:SetHidden(true)
		end
	end
	if FyrMM.SV.WheelMap then
		CurrentMap.TextureAngle = CurrentMap.Heading
	else
		CurrentMap.TextureAngle = 0
	end
	Tiles = false
end

function FyrMM.GetScrollObject(control)
	local xl = control:GetLeft()
	local xr = control:GetRight()
	local yt = control:GetTop()
	local yb = control:GetBottom()
	if FyrMM.SV.WheelMap then
		if (xr >= Fyr_MM_Scroll_WheelCenter:GetLeft() + 6 and xl <= Fyr_MM_Scroll_WheelCenter:GetRight() - 10 and yb >= Fyr_MM_Scroll_WheelCenter:GetTop() + 6 and yt <= Fyr_MM_Scroll_WheelCenter:GetBottom() - 10) then
			return Fyr_MM_Scroll_WheelCenter
		end
		if (xr >= Fyr_MM_Scroll_WheelNS:GetLeft() + 6 and xl <= Fyr_MM_Scroll_WheelNS:GetRight() - 10 and yb >= Fyr_MM_Scroll_WheelNS:GetTop() + 6 and yt <= Fyr_MM_Scroll_WheelNS:GetBottom() - 10) then
			return Fyr_MM_Scroll_WheelNS
		end
		if (xr >= Fyr_MM_Scroll_WheelWE:GetLeft() + 6 and xl <= Fyr_MM_Scroll_WheelWE:GetRight() - 10 and yb >= Fyr_MM_Scroll_WheelWE:GetTop() + 6 and yt <= Fyr_MM_Scroll_WheelWE:GetBottom() - 10) then
			return Fyr_MM_Scroll_WheelWE
		end
	else
		return Fyr_MM_Scroll_Map
	end
	return Fyr_MM_Scroll_WheelCenter
end
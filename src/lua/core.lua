FyrMM = {}
FyrMM.Panel = {}
FyrMM.Options = {}
FyrMM.noMap = false
FyrMM.Visible = true
FyrMM.AutoHidden = false
FyrMM.FpsTest = false
FyrMM.Fps = 0
FyrMM.FpsRaw = 0
FyrMM.Initialized = false
FyrMM.pScale = 75
FyrMM.pScalePercent = 0.75
FyrMM.currentLocationsCount = 0
FyrMM.currentPOICount = 0
FyrMM.currentForwardCamps = 0
FyrMM.currentWayshrineCount = 0
FyrMM.AfterCombatUnhidePending = false
FyrMM.AfterCombatUnhideTimeStamp = 0
FyrMM.MovementSpeed = 0
FyrMM.MovementSpeedPrevious = 0
FyrMM.MovementSpeedMax = 0
FyrMM.UseOriginalFunctions = true
FyrMM.MeasureMaps = true
FyrMM.DistanceMeasurementStarted = false
FyrMM.InitialPreloadTimeStamp = nil
FyrMM.currentMap = {}
FyrMM.currentMap.MapId = 0
FyrMM.currentMap.PlayerNX = 0
FyrMM.currentMap.PlayerNY = 0
FyrMM.currentMap.mapBuilt = false
FyrMM.currentMap.PlayerMounted = false
FyrMM.currentMap.PlayerSwimming = false
FyrMM.currentMap.movedTimeStamp = 0
FyrMM.currentMap.ZoneId = 0
FyrMM.CheckingZone = false
FyrMM.CustomWaypointsList = {}
FyrMM.IsGroup = false
FyrMM.IsWaypoint = false
FyrMM.Waypoint = nil
FyrMM.IsRally = false
FyrMM.Rally = nil
FyrMM.OverMiniMap = false
FyrMM.OverMenu = false
FyrMM.MenuFadingIn = false
FyrMM.MenuFadingOut = false
FyrMM.DisableSubzones = false
FyrMM.Halted = false
FyrMM.HaltTimeOffset = 0
FyrMM.LastReload = 0
FyrMM.DebugMode = false
FyrMM.MapAPI0Present = false
FyrMM.FadingEdges = false
FyrMM.KeepRefreshNeeded = true
FyrMM.GroupRefreshNeeded = true
FyrMM.AvailableQuestGivers = {}
FYRMM_ZOOM_MAX = 50
FYRMM_ZOOM_MIN = 1
FYRMM_DEFAULT_ZOOM_LEVEL = 10
FYRMM_ZOOM_INCREMENT_AMOUNT = nil

MM_IsMapLocationVisible = IsMapLocationVisible -- is Location visible

local CurrentTasks = {}
local QuestTasksPending = false
local PRMap = nil
local CurrentMap = FyrMM.currentMap
local CurrentMapId = 0
local CurrentTasks = CurrentTasks
local CWSTimeStamp = 0
local AQGTimeStamp = 0
local CleanPOIs = 0
local CustomIndex = {}
local KeepIndex = {}
local PositionLog = {}
local PositionLogCounter = 0
local Treasures = {}
local AQGList = {}
local AQGListFull = {}
local wuthreads = 0
local ruthreads = 0
local MenuAnimation
local wrc = 0
local mapContentType = 0
local pi = math.pi
-----------------------------------------------------------------
-- Utility functions
-----------------------------------------------------------------
function table.empty (self)
	for _, _ in pairs(self) do
		return false
	end
	return true
end

local function CancelUpdates()
	EVENT_MANAGER:UnregisterForUpdate("FyrMiniMapDelayedRegister")
	EVENT_MANAGER:UnregisterForUpdate("FyrMiniMapZoneCheck")
end

function GetCurrentMapTextureFileInfo()
	local tileTexture = (GetMapTileTexture()):lower()
	if tileTexture == nil or tileTexture == "" then
		return "tamriel_0", "tamriel_", "art/maps/tamriel/"
	end
	local pos = select(2, tileTexture:find("maps/([%w%-]+)/"))
	if pos == nil then
		return "tamriel_0", "tamriel_", "art/maps/tamriel/"
	end
	pos = pos + 1
	return string.gsub(string.sub(tileTexture, pos), ".dds", ""), string.gsub(string.sub(tileTexture, pos), "0.dds", ""), string.sub(tileTexture, 1, pos - 1)
end

local function GetMapId()
	local _, pos, tileTexture, map
	tileTexture = (GetMapTileTexture()):lower()
	pos = select(2, tileTexture:find("maps/([%w%-]+)/"))
	if pos == nil then
		return FyrMM.GetMapId()
	end
	map = string.gsub(string.sub(tileTexture, pos + 1), ".dds", "")
	if FyrMM.MapList then
		if FyrMM.MapList[map] then
			return FyrMM.MapList[map]
		end
	end
	return "unknown"
end

local function GetTrueMapSize()
	local _, pos, tileTexture, map
	tileTexture = (GetMapTileTexture()):lower()
	pos = select(2, tileTexture:find("maps/([%w%-]+)/"))
	if pos == nil then
		return "unknown", 1
	end
	map = string.gsub(string.sub(tileTexture, pos + 1), ".dds", "")
	if FyrMM.MapList and FyrMM.MapData then
		if FyrMM.MapList[map] then
			local id = FyrMM.MapList[map]
			if FyrMM.MapData[id] then
				return FyrMM.MapList[map], FyrMM.MapData[id][5]
			end
		end
	end
	return "unknown", 1
end

function FyrMM.GetMapId(map)
	local _, pos, tileTexture
	if map == nil and CurrentMap.MapId ~= nil then
		return CurrentMap.MapId
	end
	if map == "" and CurrentMap.MapId ~= nil then
		return CurrentMap.MapId
	end
	if map == nil then
		if CurrentMap.filename then
			map = CurrentMap.filename
		else
			tileTexture = (GetMapTileTexture()):lower()
			pos = select(2, tileTexture:find("maps/([%w%-]+)/"))
			map = string.gsub(string.sub(tileTexture, pos + 1), ".dds", "")
		end
	end
	if FyrMM.MapList then
		if FyrMM.MapList[map] then
			return FyrMM.MapList[map]
		end
	end
	return "unknown"
end

local function SetMapToZone()
	if FyrMM.DisableSubzones == true and GetMapType() == 1 then
		MapZoomOut()
	end
end

function FyrMM.MapHalfDiagonal()
	local x1 = Fyr_MM_Player:GetRight()
	local y1 = Fyr_MM_Player:GetTop()
	local x2 = Fyr_MM:GetRight()
	local y2 = Fyr_MM:GetTop()
	FyrMM.DiagonalND = math.sqrt((x1 - x2) * (x1 - x2) + (y1 - y2) * (y1 - y2))
	return FyrMM.DiagonalND
end

local function IsSubmap()
	return GetMapContentType() == MAP_CONTENT_DUNGEON or GetMapType() == MAPTYPE_SUBZONE
end

local function GetQuestJournalMaxValidIndex()
	local index = 0
	for i = 1, MAX_JOURNAL_QUESTS do
		if (IsValidQuestIndex(i)) and index < i then
			index = i
		end
	end
	return index
end

local function valueExists(i, x)
	for _, v in ipairs(x) do
		if v == i then
			return true
		end
	end
	return false
end

local function AfterCombatShow()
	if not FyrMM.AfterCombatUnhidePending then
		return
	end
	if GetFrameTimeMilliseconds() - FyrMM.AfterCombatUnhideTimeStamp < 1000 * (FyrMM.SV.AfterCombatUnhideDelay - 1) then
		return
	end
	FyrMM.AfterCombatUnhidePending = false
	if not IsUnitInCombat("player") then
		FyrMM.AutoHidden = false
		FyrMM.Visible = true
	end
end

local function sort(a, b)
	if type(a.index) == "number" and type(b.index) == "number" then
		return a.index < b.index
	end
	if type(a.index) == "number" and type(b.index) ~= "number" then
		return true
	end
	if type(a.index) ~= "number" and type(b.index) == "number" then
		return false
	end
	return a.index and b.index and tostring(a.index) < tostring(b.index)
end

local function FirstKey(Table, offset)
	if table.empty(Table) then
		return nil
	end
	if offset == nil then
		offset = 0
	end
	for key = offset, 1000 do
		if Table[key] ~= nil then
			return key
		end
	end
	return nil
end

function FyrMM.MenuTooltip(button, message)
	--Fyr_MM_Menu:SetAlpha(1)
	FyrMM.OverMenu = true
	Fyr_MM_Close:SetAlpha(1)
	if message == nil or message == "" or button == nil then
		return
	end
	InitializeTooltip(InformationTooltip, Fyr_MM, TOPLEFT, 38, button:GetTop())
	InformationTooltip:AddLine(message, "", ZO_TOOLTIP_DEFAULT_COLOR:UnpackRGB())
end

function FyrMM.TooltipExit()
	FyrMM.OverMenu = false
	--Fyr_MM_Menu:SetAlpha(0.1)
	Fyr_MM_Close:SetAlpha(0)
	ClearTooltip(InformationTooltip)
end

function FyrMM.OpenSettingsPanel()
	FyrMM.LAM:OpenToPanel(FyrMM.CPL)
end

function GetCurrentMapSize()
	-- Returns calculated map size in assumed feet, returns nil if size is not yet calculated, or it is not possible to do so
	if CurrentMap then
		return CurrentMap.TrueMapSize
	else
		return nil
	end
end

local function GetRotatedPosition(x, y)
	-- Inspired by DeathAngel's RadarMiniMap
	if CurrentMap.Heading == nil then
		return
	end
	local mWidth, mHeight = Fyr_MM_Scroll_Map:GetDimensions()
	if CurrentMap.Heading == nil then
		return
	end
	if x and CurrentMap.PlayerX then
		local ix = (x * mWidth) - CurrentMap.PlayerX
		local iy = (y * mHeight) - CurrentMap.PlayerY
		local rx = (math.cos(-CurrentMap.Heading) * ix) - (math.sin(-CurrentMap.Heading) * iy)
		local ry = (math.sin(-CurrentMap.Heading) * ix) + (math.cos(-CurrentMap.Heading) * iy)
		return zo_round(rx), zo_round(ry)
	end
	return x, y
end

local function GetNorthFacingPosition(x, y)
	local mWidth, mHeight = Fyr_MM_Scroll_Map:GetDimensions()
	if x and y then
		return zo_round(mWidth * x), zo_round(mHeight * y)
	else
		return x, y
	end
end

function FyrMM.AxisPosition(a)
	local mmWidth, mmHeight = Fyr_MM:GetDimensions()
	if mmWidth == nil then
		mmWidth = FyrMM.SV.MapWidth
	end
	if mmHeight == nil then
		mmHeight = FyrMM.SV.MapHeight
	end
	
	local piHalf = pi * 0.5
	local piDoub = pi * 2.0
	
	mmWidth = mmWidth / 2
	mmHeight = mmHeight / 2
	
	local na = math.atan((mmWidth) / (mmHeight))
	local nb = piHalf - na
	local npos, epos, spos, wpos
	
	local nbX2 = nb * 2
	local aMna = a - na
	local aPna = a + na
	
	if aPna >= piDoub or aMna <= 0 then
		-- upper border line
		if aMna <= 0 then
			npos = mmWidth + mmHeight * math.sin(a) / math.sin(piHalf - a)
		else
			npos = mmWidth - mmHeight * math.sin(piDoub - a) / math.sin(piHalf - (piDoub - a))
		end
		return npos, 0
	end
	if aMna > 0 and aMna < nbX2 then
		-- right border line
		if aMna > nb then
			epos = mmHeight + mmWidth * math.sin(aMna - nb) / math.sin(piHalf - (aMna - nb))
		else
			epos = mmWidth * math.sin(aMna) / math.sin(piHalf - (aMna))
		end
		return mmWidth * 2, epos
	end
	if aMna >= nbX2 and a <= 3 * na + nbX2 then
		-- bottom border line
		if aMna - na > nbX2 then
			spos = mmWidth - mmHeight * math.sin(a - 2 * na - nbX2) / math.sin(piHalf - (a - 2 * na - nbX2))
		else
			spos = mmWidth * 2 - mmHeight * math.sin(aMna - nbX2) / math.sin(piHalf - (aMna - nbX2))
		end
		return spos, mmHeight * 2
	end
	if aPna > piDoub - nbX2 and aPna < piDoub then
		-- left border line
		if aMna > nb then
			wpos = mmHeight - mmWidth * math.sin(a - 3 * na - 3 * nb) / math.sin(piHalf - (a - 3 * na - 3 * nb))
		else
			wpos = mmHeight - mmWidth * math.sin(a - 3 * na - nbX2) / math.sin(piHalf - (a - 3 * na - nbX2))
		end
		return 0, wpos
	end
end

local function RoundArc(angle)
	if angle > pi * 2 then
		angle = angle - pi * 2
	end
	return angle
end

local function AxisSwitch()
	for i = 1, Fyr_MM_Axis_Textures:GetNumChildren() do
		local l = Fyr_MM_Axis_Textures:GetChild(i)
		if l ~= nil then
			l:ClearAnchors()
			l:SetHidden(FyrMM.SV.WheelMap or not FyrMM.SV.RotateMap)
			l:SetDimensions(20, 20)
		end
	end
	for i = 1, Fyr_MM_Axis_Labels:GetNumChildren() do
		local l = Fyr_MM_Axis_Labels:GetChild(i)
		if l ~= nil then
			l:ClearAnchors()
			l:SetHidden(FyrMM.SV.WheelMap or not FyrMM.SV.RotateMap)
		end
	end
end

local function IsCoordinateInRange(x, y)
	if not CurrentMap.TrueMapSize or not CurrentMap.PlayerNX or not FyrMM.SV.CustomPinViewRange or not FyrMM.SV.ViewRangeFiltering then
		return true
	end
	return CurrentMap.TrueMapSize * math.sqrt((x - CurrentMap.PlayerNX) * (x - CurrentMap.PlayerNX) + (y - CurrentMap.PlayerNY) * (y - CurrentMap.PlayerNY)) <= FyrMM.SV.CustomPinViewRange
end

local function RescaleLinks()
	if not IsInCyrodiil() then
		return
	end
	local mWidth, mHeight = Fyr_MM_Scroll_Map:GetDimensions()
	local Count, l, startX, startY, endX, endY
	for i = 1, 100 do
		l = GetControl("Fyr_MM_Scroll_Map_Links_Link" .. tostring(i))
		if l ~= nil then
			if FyrMM.SV.WheelMap then
				l:SetParent(Fyr_MM_Scroll_CW_Map_Pins)
			else
				l:SetParent(Fyr_MM_Scroll_Map_Links)
			end
			if FyrMM.SV.RotateMap then
				l:ClearAnchors()
				l:SetAnchor(TOPLEFT, Fyr_MM_Scroll, CENTER, GetRotatedPosition(l.startNX, l.startNY))
				l:SetAnchor(BOTTOMRIGHT, Fyr_MM_Scroll, CENTER, GetRotatedPosition(l.endNX, l.endNY))
			else
				startX, startY, endX, endY = l.startNX * mWidth - mWidth / 2, l.startNY * mHeight - mHeight / 2, l.endNX * mWidth - mWidth / 2, l.endNY * mHeight - mHeight / 2
				l:ClearAnchors()
				l:SetAnchor(TOPLEFT, Fyr_MM_Scroll_Map_Links, CENTER, zo_round(startX), zo_round(startY) )
				l:SetAnchor(BOTTOMRIGHT, Fyr_MM_Scroll_Map_Links, CENTER, zo_round(endX), zo_round(endY))
			end
		else
			i = 99
		end
		l = GetControl("Fyr_MM_Scroll_Map_LinksNS_Link" .. tostring(i))
		if l ~= nil then
			if FyrMM.SV.RotateMap then
				l:ClearAnchors()
				l:SetAnchor(TOPLEFT, Fyr_MM_Scroll, CENTER, GetRotatedPosition(l.startNX, l.startNY))
				l:SetAnchor(BOTTOMRIGHT, Fyr_MM_Scroll, CENTER, GetRotatedPosition(l.endNX, l.endNY))
			else
				startX, startY, endX, endY = l.startNX * mWidth - mWidth / 2, l.startNY * mHeight - mHeight / 2, l.endNX * mWidth - mWidth / 2, l.endNY * mHeight - mHeight / 2
				l:ClearAnchors()
				l:SetAnchor(TOPLEFT, Fyr_MM_Scroll_Map_Links, CENTER, zo_round(startX), zo_round(startY) )
				l:SetAnchor(BOTTOMRIGHT, Fyr_MM_Scroll_Map_Links, CENTER, zo_round(endX), zo_round(endY))
			end
		end
		l = GetControl("Fyr_MM_Scroll_Map_LinksWE_Link" .. tostring(i))
		if l ~= nil then
			if FyrMM.SV.RotateMap then
				l:ClearAnchors()
				l:SetAnchor(TOPLEFT, Fyr_MM_Scroll, CENTER, GetRotatedPosition(l.startNX, l.startNY))
				l:SetAnchor(BOTTOMRIGHT, Fyr_MM_Scroll, CENTER, GetRotatedPosition(l.endNX, l.endNY))
			else
				startX, startY, endX, endY = l.startNX * mWidth - mWidth / 2, l.startNY * mHeight - mHeight / 2, l.endNX * mWidth - mWidth / 2, l.endNY * mHeight - mHeight / 2
				l:ClearAnchors()
				l:SetAnchor(TOPLEFT, Fyr_MM_Scroll_Map_Links, CENTER, zo_round(startX), zo_round(startY) )
				l:SetAnchor(BOTTOMRIGHT, Fyr_MM_Scroll_Map_Links, CENTER, zo_round(endX), zo_round(endY))
			end
		end
	end
end

local ZoomAnimating = false
local function AnimateZoom(newzoom)
	local step = (newzoom - CurrentMap.ZoomLevel) / 10
	if CurrentMap.ZoomLevel ~= newzoom then
		ZoomAnimating = true
		EVENT_MANAGER:RegisterForUpdate("OnFyrMMZoomAnimate", 1, function()
			FyrMM.SetCurrentMapZoom(CurrentMap.ZoomLevel + step)
			FyrMM.UpdateMapTiles(true)
			FyrMM.PositionUpdate()
			CurrentMap.needRescale = true
			FyrMM.UpdateMapTiles(true)
			if (CurrentMap.ZoomLevel <= newzoom and step < 0) or (CurrentMap.ZoomLevel >= newzoom and step > 0) then
				EVENT_MANAGER:UnregisterForUpdate("OnFyrMMZoomAnimate")
				FyrMM.SetCurrentMapZoom(newzoom)
				FyrMM.UpdateMapTiles(true)
				FyrMM.PositionUpdate()
				CurrentMap.needRescale = true
				FyrMM.UpdateMapTiles(true)
				ZoomAnimating = false
			end
		end)
	end
end

-----------------------------------------------------------------
-- Updates
-----------------------------------------------------------------
local function FinishDistanceMeasurement()
	if Fyr_MM:IsHidden() or not ZO_WorldMap:IsHidden() then
		return
	end
	FyrMM.DistanceMeasurementStarted = false
	if CurrentMap.TrueMapSize > 1 then
		return
	end
	local x, y = FyrMM.MeasurementX, FyrMM.MeasurementY
	SetMapToPlayerLocation()
	local xl, yl = FyrMM.MeasurementXl, FyrMM.MeasurementYl
	local x2l, y2l, _ = GetMapPlayerPosition("player")
	local mapId = GetCurrentMapIndex()
	if mapId == nil then
		MapZoomOut()
		mapId = GetCurrentMapIndex()
	end
	local worldsize, multiplier
	multiplier = 1
	if mapId ~= 23 then
		SetMapToMapListIndex(1)
		worldsize = 33440   -- Assumed Tamriel size in feet taken from ZygorGuides
		-- Based on assumption that player constantly moves at the same speed anywhere - world size has to be adjusted to match it. According to Tamriel distance difference for some specific maps I made a few adjustments for the worldsizes while in those maps.
		-- Maps like Auridon or Glenumbra indicate same player speeds while Cyrodiil, Craglorn and starting maps show compleately different speeds (for mapsize 33440)
		if mapId == 14 then
			multiplier = 2.2
		end
		if mapId == 18 then
			multiplier = 1.353
		end
		if mapId == 19 then
			multiplier = 2.6
		end
		if mapId == 20 or mapId == 21 then
			multiplier = 2.4865
		end
		if mapId == 22 then
			multiplier = 3.1
		end
		if mapId == 25 then
			multiplier = 1.087
		end
	else
		worldsize = 5684  -- Assumed Coldharbour size in feet
	end
	local x2, y2, _ = GetMapPlayerPosition("player")
	FyrMM.SetMapToPlayerLocation()
	local localdistance = math.sqrt((xl - x2l) * (xl - x2l) + (yl - y2l) * (yl - y2l)) -- Local map distance
	local continentdistance = math.sqrt((x - x2) * (x - x2) + (y - y2) * (y - y2)) -- Tamriel/Coldharbour
	local mapSize = (worldsize * continentdistance / localdistance) * multiplier
	if not (mapSize > 0) then
		-- Error
		FyrMM.DistanceMeasurementStarted = true
		return
	end
	if FyrMM.SV.MapSizes == nil then
		FyrMM.SV.MapSizes = {}
	end
	FyrMM.SV.MapSizes[CurrentMap.filename] = mapSize
	CurrentMap.TrueMapSize = mapSize
end

function FyrMM.MeasureDistance()
	if not FyrMM.MeasureMaps then
		return
	end
	local _
	if CurrentMap.TrueMapSize > 1 then
		FyrMM.DistanceMeasurementStarted = false
		return
	end
	SetMapToPlayerLocation()
	FyrMM.MeasurementXl, FyrMM.MeasurementYl, _ = GetMapPlayerPosition("player")
	local mapId = GetCurrentMapIndex()
	if mapId == nil then
		MapZoomOut()
		mapId = GetCurrentMapIndex()
	end
	if mapId ~= 23 then
		SetMapToMapListIndex(1)
	end
	FyrMM.MeasurementX, FyrMM.MeasurementY, _ = GetMapPlayerPosition("player")
	FyrMM.DistanceMeasurementStarted = true
	FyrMM.SetMapToPlayerLocation()
	zo_callLater(FinishDistanceMeasurement, 5000)
end

function FyrMM.InCombatAutoHideCheck()
	if not FyrMM.SV.InCombatAutoHide then
		return
	end
	if IsUnitInCombat("player") then
		FyrMM.AfterCombatUnhidePending = false
		if not Fyr_MM:IsHidden() then
			FyrMM.Visible = false
			FyrMM.AutoHidden = true
		end
	else
		if Fyr_MM:IsHidden() and FyrMM.AutoHidden then
			if not FyrMM.AfterCombatUnhidePending then
				FyrMM.AfterCombatUnhidePending = true
				FyrMM.AfterCombatUnhideTimeStamp = GetFrameTimeMilliseconds()
				zo_callLater(AfterCombatShow, 1000 * FyrMM.SV.AfterCombatUnhideDelay)
			end
		end
	end
end

local function DelayedReload()
	EVENT_MANAGER:RegisterForUpdate("MiniMapReload", 100, FyrMM.Reload)
end

local function DelayedShow()
	EVENT_MANAGER:RegisterForUpdate("FyrMiniMapDelayedShow", 200, FyrMM.Show)
end

local frameRatePrevious = GetFramerate()
function FyrMM.HideCheck()
	-- fires every 100 ticks
	if FyrMM.Reloading then
		return
	end
	FyrMM.Refresh = false
	local siegeControlling = IsPlayerControllingSiegeWeapon()
	local menuHidden = ZO_KeybindStripControl:IsHidden()
	local interactHidden = ZO_InteractWindow:IsHidden()
	local gameMenuHidden = ZO_GameMenu_InGame:IsHidden()
	local crownStoreActive = WINDOW_MANAGER:IsSecureRenderModeEnabled()
	local frameRate = GetFramerate()
	if frameRate < frameRatePrevious and frameRatePrevious - frameRate > 10 then
		FyrMM.UnregisterUpdates()
		FyrMM.HaltTimeOffset = GetFrameTimeMilliseconds()
	end
	frameRatePrevious = (frameRatePrevious + frameRate) / 2
	if FyrMM.SV.ShowFPS or FyrMM.FpsTest then
		if (frameRate < 20.0) then
			Fyr_MM_FPS:SetColor(1, 0, 0, 1)
		elseif (frameRate < 30.0) then
			Fyr_MM_FPS:SetColor(1, 0.6, 0, 1)
		elseif (frameRate < 60.0) then
			Fyr_MM_FPS:SetColor(0, 1, 0, 1)
		else
			Fyr_MM_FPS:SetColor(1, 1, 1, 1)
		end
		Fyr_MM_FPS:SetText(string.format(" %.1f", frameRate))
	end
	if FyrMM.SV.ShowClock then
		Fyr_MM_Time:SetText(GetTimeString())
		if Fyr_MM_Time:IsHidden() then
			Fyr_MM_Time:SetHidden(false)
		end
	else
		Fyr_MM_Time:SetHidden(true)
	end
	if not Fyr_MM:IsHidden() and FyrMM.FpsTest then
		if FyrMM.Fps == 0 then
			FyrMM.Fps = frameRate
		else
			FyrMM.Fps = (FyrMM.Fps + frameRate) / 2
		end
	end
	if not FyrMM.SV.ShowFPS and not FyrMM.FpsTest then
		Fyr_MM_FPS:SetText("")
		Fyr_MM_FPS:SetAlpha(0)
	end
	if Fyr_MM:IsHidden() and FyrMM.FpsTest then
		if FyrMM.FpsRaw == 0 then
			FyrMM.FpsRaw = frameRate
		else
			FyrMM.FpsRaw = (FyrMM.FpsRaw + frameRate) / 2
		end
	end
	FyrMM.InCombatAutoHideCheck()
	if siegeControlling and FyrMM.SV.Siege then
		DelayedShow()
		return
	end
	if crownStoreActive then
		FyrMM.Hide()
		return
	end
	if FyrMM.Visible == false or FyrMM.noMap == true then
		FyrMM.Hide()
	elseif menuHidden == true and interactHidden == true and gameMenuHidden == true then
		DelayedShow()
	elseif menuHidden == false or interactHidden == false or gameMenuHidden == false then
		if gameMenuHidden == false then
			DelayedShow()
		else
			FyrMM.Hide()
		end
	end
	if FyrMM.Visible == true and FyrMM.noMap == true then
		FyrMM.noMap = false;
		DelayedReload()
		DelayedShow()
		return
	end
end

function FyrMM.WorldMapShowHide()
	if ZO_WorldMap:IsHidden() then
		FyrMM.UnregisterUpdates()
		CancelUpdates()
		FyrMM.Reloading = true
		FyrMM.Hide()
		if not FyrMM.SV.WorldMapRefresh then
			CALLBACK_MANAGER:FireCallbacks("FyrMMDebug", "OnWorldMapChanged (Show/Hide)" .. tostring(GetGameTimeMilliseconds()))
			CALLBACK_MANAGER:FireCallbacks("OnWorldMapChanged")
		end
	else
		CurrentTasks = {}
		FyrMM.Reloading = false
		zo_callLater(FyrMM.SetMapToPlayerLocation, 50)
	end
end

function FyrMM.SetMapToPlayerLocation(stealth)
	local changed = false
	if not Stealth then
		if Fyr_MM:IsHidden() then
			return
		end
	end
	if FyrMM.DisableSubzones == true and GetMapType() ~= 1 then
		return
	end
	if not ZO_WorldMap:IsHidden() then
		return
	end
	if SetMapToPlayerLocation() ~= SET_MAP_RESULT_CURRENT_MAP_UNCHANGED then
		changed = true
		if FyrMM.SV.WorldMapRefresh or stealth then
			CALLBACK_MANAGER:FireCallbacks("FyrMMDebug", "OnWorldMapChanged (SetMapToPlayerLocation)" .. tostring(GetGameTimeMilliseconds()))
			CALLBACK_MANAGER:FireCallbacks("OnWorldMapChanged")
		end
	end
	if FyrMM.DisableSubzones == true and GetMapType() == 1 then
		SetMapToZone()
	end
	return changed
end

function FyrMM.Hide()
	if Fyr_MM:IsHidden() then
		return
	end
	FyrMM.UnregisterUpdates()
	Fyr_MM:SetHidden(true)
	Fyr_MM_Wheel_Background:SetHidden(true)
	Fyr_MM_Menu:SetHidden(true)
	Fyr_MM_Coordinates:SetHidden(true)
	Fyr_MM_Axis_Control:SetHidden(true)
	Fyr_MM_Scroll_WheelCenter:SetHidden(true)
	Fyr_MM_Scroll_WheelNS:SetHidden(true)
	Fyr_MM_Scroll_WheelWE:SetHidden(true)
	Fyr_MM_Frame_Wheel:SetHidden(true)
	if not FyrMM.SV.ShowBorder then
		Fyr_MM_Border:SetAlpha(0)
	end
	Fyr_MM:SetMouseEnabled(false)
	Fyr_MM_Menu:SetMouseEnabled(false)
	Fyr_MM_FPS_Frame:SetHidden(true)
	Fyr_MM_ZoneFrame:SetHidden(true)
	Fyr_MM_Speed:SetHidden(true)
	Fyr_MM:SetMouseEnabled(false)
	Fyr_MM_Frame_Control:SetMouseEnabled(false)
	Fyr_MM_ZoneFrame:SetMouseEnabled(false)
	Fyr_MM_FPS_Frame:SetMouseEnabled(false)
end

function FyrMM.Show_WheelScrolls()
	FyrMM.UpdateMapTiles()
	Fyr_MM_Wheel_Background:SetHidden(not FyrMM.SV.WheelMap)
	Fyr_MM_Scroll_WheelCenter:SetHidden(not FyrMM.SV.WheelMap)
	Fyr_MM_Scroll_WheelNS:SetHidden(not FyrMM.SV.WheelMap)
	Fyr_MM_Scroll_WheelWE:SetHidden(not FyrMM.SV.WheelMap)
	Fyr_MM_Scroll:SetHorizontalScroll(CurrentMap.hpos)
	Fyr_MM_Scroll:SetVerticalScroll(CurrentMap.vpos)
	Fyr_MM_Scroll_WheelCenter:SetHorizontalScroll(CurrentMap.hpos)
	Fyr_MM_Scroll_WheelCenter:SetVerticalScroll(CurrentMap.vpos)
	Fyr_MM_Scroll_WheelNS:SetHorizontalScroll(CurrentMap.hpos)
	Fyr_MM_Scroll_WheelNS:SetVerticalScroll(CurrentMap.vpos)
	Fyr_MM_Scroll_WheelWE:SetHorizontalScroll(CurrentMap.hpos)
	Fyr_MM_Scroll_WheelWE:SetVerticalScroll(CurrentMap.vpos)
end

function FyrMM.Show()
	if FyrMM.Reloading then
		return
	end
	if FyrMM.Halted and FyrMM.Visible and ZO_WorldMap:IsHidden() and FyrMM.HaltTimeOffset ~= 0 then
		if GetFrameTimeMilliseconds() - FyrMM.HaltTimeOffset > 1000 then
			FyrMM.RegisterUpdates()
		end
	end
	if not (IsPlayerControllingSiegeWeapon() and FyrMM.SV.Siege) then
		if not FyrMM.Visible or not ZO_WorldMap:IsHidden() or not ZO_KeybindStripControl:IsHidden() or not ZO_InteractWindow:IsHidden() or not ZO_GameMenu_InGame:IsHidden() or WINDOW_MANAGER:IsSecureRenderModeEnabled() then
			return
		end
	end
	if FyrMM.SV.hideCompass == true then
		ZO_CompassFrame:SetHidden(true)
	end
	FyrMM.SetMapToPlayerLocation()
	if Fyr_MM:IsHidden() then
		EVENT_MANAGER:RegisterForUpdate("FyrMiniMapDelayedRegister", 100, function()
			FyrMM.UpdateMapTiles(true)
			FyrMM.UpdateMapTiles(true)
			FyrMM.RegisterUpdates()
			EVENT_MANAGER:UnregisterForUpdate("FyrMiniMapDelayedRegister")
		end)
		Fyr_MM_Frame_Wheel:SetHidden(not FyrMM.SV.WheelMap)
		if FyrMM.SV.WheelMap then
			FyrMM.Show_WheelScrolls()
		end
		Fyr_MM_Frame_Control:SetHidden(not FyrMM.SV.WheelMap)
		Fyr_MM:SetHidden(false)
		Fyr_MM_Menu:SetHidden(FyrMM.SV.MenuDisabled)
		Fyr_MM_Menu:SetMouseEnabled(not FyrMM.SV.MenuDisabled)
		Fyr_MM_ZoneFrame:SetHidden(FyrMM.SV.HideZoneLabel)
		Fyr_MM_Coordinates:SetHidden(not FyrMM.SV.ShowPosition)
		Fyr_MM_Axis_Control:SetHidden(not (FyrMM.SV.RotateMap))
		Fyr_MM_FPS_Frame:SetHidden(not FyrMM.SV.ShowFPS)
		Fyr_MM_Speed:SetHidden(not FyrMM.SV.ShowSpeed)
		Fyr_MM_ZoneFrame:SetMouseEnabled(true)
		Fyr_MM:SetMouseEnabled(true)
	end
	if FyrMM.SV.ShowBorder then
		Fyr_MM_Border:SetAlpha(100)
	end
	Fyr_MM:SetMouseEnabled(true)
	EVENT_MANAGER:UnregisterForUpdate("FyrMiniMapDelayedShow")
end

function FyrMM.ZoneUpdate()
	if FyrMM.Reloading then
		return
	end
	if FyrMM.SV.DisableSubzones then
		FyrMM.ZoneCheck()
	end
end

local function ZoneCheck()
	if ZO_WorldMap:IsHidden() then
		FyrMM.CheckingZone = true
		local filename, _, _ = GetCurrentMapTextureFileInfo()
		if filename == "tamriel_0" then
			return
		end
		CurrentMap.ZoneId = GetCurrentMapZoneIndex()
		if CurrentMap.filename ~= filename then
			FyrMM.UnregisterUpdates()
			CancelUpdates()
			local ZoneId = 0
			if ZoneId == 0 then
				SetMapToPlayerLocation()
				CALLBACK_MANAGER:FireCallbacks("OnWorldMapChanged")
			else
				CurrentMap.ZoneId = ZoneId
			end
			FyrMM.UpdateMapInfo()
			FyrMM.UpdateMapTiles(true)
			FyrMM.MovementSpeed = 0
			FyrMM.MovementSpeedPrevious = 0
			FyrMM.MovementSpeedMax = 0
			if IsInCyrodiil() then
				zo_callLater(FyrMM.RequestKeepRefresh, 1000)
			end
			CurrentMap.PlayerNX, CurrentMap.PlayerNY, _ = GetMapPlayerPosition("player")
			CurrentMap.MapId = FyrMM.GetMapId()
			CALLBACK_MANAGER:FireCallbacks("OnFyrMiniNewMapEntered")
		end
	end
	FyrMM.CheckingZone = false
	EVENT_MANAGER:UnregisterForUpdate("FyrMiniMapZoneCheck")
end

function FyrMM.ZoneCheck()
	if FyrMM.CheckingZone then
		return
	end
	EVENT_MANAGER:RegisterForUpdate("FyrMiniMapZoneCheck", 50, ZoneCheck)
end

local function TaskExists(tag)
	for i, v in pairs(CurrentTasks) do
		if CurrentTasks[i] ~= nil then
			if CurrentTasks[i][1] == tag[1] and CurrentTasks[i][2] == tag[2] and CurrentTasks[i][3] == tag[3]
					and CurrentTasks[i].isBreadcrumb == tag.isBreadcrumb
			then
				return true
			end
		else
			--CurrentTasks[i] = nil
		end
	end
	return false
end

local function DestroyTasks()
	for i, v in pairs(CurrentTasks) do
		if CurrentTasks[i] ~= nil then
			CurrentTasks[i] = nil
		end
	end
end

function FyrMM.Debug_d(value)
	if FyrMM.DebugMode and FyrMM.SV then
		if FyrMM.SV.DebugLog == nil then
			FyrMM.SV.DebugLog = {}
		end
		local t = GetGameTimeMilliseconds() - math.floor(GetGameTimeMilliseconds() / 1000) * 1000
		d("[" .. GetTimeString() .. string.format("] %s", tostring(value)))
		table.insert(FyrMM.SV.DebugLog, "[" .. GetTimeString() .. "." .. tostring(t) .. "] FPS:" .. tostring(zo_round(GetFramerate() * 10) / 10) .. " RAM:" .. tostring(zo_round((collectgarbage("count") / 1024) * 100) / 100) .. " MAP:" .. tostring(CurrentMap.MapId) .. " LOC:" .. string.format("%05.02f, %05.02f", zo_round(CurrentMap.PlayerNX * 10000) / 100, zo_round(CurrentMap.PlayerNY * 10000) / 100) .. " FN:" .. tostring(value))
	end
end

function FyrMM.Reload()
	if FyrMM.Reloading then
		return
	end
	local t = GetGameTimeMilliseconds()
	CALLBACK_MANAGER:FireCallbacks("FyrMMDebug", "FyrMM.Reload Start:")
	FyrMM.Reloading = true
	CancelUpdates()
	FyrMM.LastReload = GetFrameTimeMilliseconds()
	FyrMM.UnregisterUpdates()
	FyrMM.UpdateLabels()
	FyrMM.MapHalfDiagonal()
	FyrMM.UpdateMapTiles(true)
	FyrMM.PositionUpdate()
	FyrMM.DistanceMeasurementStarted = false
	FyrMM.MovementSpeedMax = 0
	FyrMM.currentLocationsCount = 0
	FyrMM.currentPOICount = 0
	FyrMM.currentForwardCamps = 0
	FyrMM.currentWayshrineCount = 0
	FyrMM.MeasureDistance()
	CALLBACK_MANAGER:FireCallbacks("FyrMMDebug", "FyrMM.Reload Done." .. tostring(GetGameTimeMilliseconds() - t))
	EVENT_MANAGER:UnregisterForUpdate("MiniMapReload")
end

function FyrMM.WheelScroll(x, y)
	if x and y then
		Fyr_MM_Scroll_WheelCenter:SetHorizontalScroll(x)
		Fyr_MM_Scroll_WheelCenter:SetVerticalScroll(y)
		Fyr_MM_Scroll_WheelNS:SetHorizontalScroll(x)
		Fyr_MM_Scroll_WheelNS:SetVerticalScroll(y)
		Fyr_MM_Scroll_WheelWE:SetHorizontalScroll(x)
		Fyr_MM_Scroll_WheelWE:SetVerticalScroll(y)
	end
end

local function SetSpeedLabel(speed)
	if speed == nil then
		speed = 0
	end
	if speed ~= 0 then
		if FyrMM.SV.SpeedUnit == "ft/s" then
			speed = zo_round(speed * 10000) / 100
			Fyr_MM_SpeedLabel:SetText(string.format("(%05.02f ft/s)", speed))
		end
		if FyrMM.SV.SpeedUnit == "m/s" then
			speed = zo_round(speed * 7550) / 100
			Fyr_MM_SpeedLabel:SetText(string.format("(%05.02f m/s)", speed))
		end
		if FyrMM.SV.SpeedUnit == "%" then
			speed = zo_round(speed * 100000) / 90
			Fyr_MM_SpeedLabel:SetText(string.format("(%05.01f ", speed) .. "%)")
		end
	else
		Fyr_MM_SpeedLabel:SetText("(0 " .. FyrMM.SV.SpeedUnit .. ")")
	end
end

local function LogPosition()
	local MapId = CurrentMap.MapId
	local size = CurrentMap.TrueMapSize
	local t = GetFrameTimeMilliseconds()
	CurrentMap.PlayerNX, CurrentMap.PlayerNY, CurrentMap.PlayerHeading = GetMapPlayerPosition("player")
	local LogEntry = { t = t, x = CurrentMap.PlayerNX, y = CurrentMap.PlayerNY, size = size }
	CurrentMap.CameraHeading = GetPlayerCameraHeading()
	CurrentMap.PlayerTurned = (CurrentMap.Heading ~= math.abs(CurrentMap.PlayerHeading - pi * 2))
	CurrentMap.Heading = math.abs(CurrentMap.PlayerHeading - pi * 2)
	CurrentMap.PlayerMoved = IsPlayerMoving()
	if CurrentMap.PlayerHeading < 0 then
		CurrentMap.PlayerHeading = pi * 2 + CurrentMap.PlayerHeading
	end
	if zo_round(CurrentMap.PlayerNX * 100) / 100 <= 0 or zo_round(CurrentMap.PlayerNY * 100) / 100 <= 0 or CurrentMap.PlayerNX >= 1 or CurrentMap.PlayerNY >= 1 then
		if not Fyr_MM:IsHidden() then
			SetMapToPlayerLocation()
		end
	end
	if MapId ~= CurrentMap.MapId then
		FyrMM.ZoneCheck()
	end
	CurrentMap.PlayerX, CurrentMap.PlayerY = Fyr_MM_Scroll_Map:GetDimensions()
	CurrentMap.PlayerX = CurrentMap.PlayerX * CurrentMap.PlayerNX
	CurrentMap.PlayerY = CurrentMap.PlayerY * CurrentMap.PlayerNY
	CurrentMap.currentTimeStamp = t
	if CurrentMap.PlayerMoved then
		CurrentMap.movedTimeStamp = t
	end
	PositionLogCounter = PositionLogCounter + 1
	if PositionLog[PositionLogCounter] == nil then
		PositionLog[PositionLogCounter] = LogEntry
	else
		PositionLog[PositionLogCounter].t = LogEntry.t
		PositionLog[PositionLogCounter].x = LogEntry.x
		PositionLog[PositionLogCounter].y = LogEntry.y
		PositionLog[PositionLogCounter].size = LogEntry.size
	end
	Fyr_MM_Position:SetText(string.format("%05.02f, %05.02f", CurrentMap.PlayerNX * 100, CurrentMap.PlayerNY * 100)) -- thanks Garkin
	Fyr_MM_Player_incombat:SetHidden(not (FyrMM.SV.InCombatState and IsUnitInCombat("player")))
end

local function SpeedMeasure()
	if table.empty(PositionLog) then
		return
	end
	local x1 = PositionLog[1].x
	local y1 = PositionLog[1].y
	local t1 = PositionLog[1].t
	local v1 = 0
	local va = 0
	local size = PositionLog[1].size
	local cnt = 1
	local i = 0
	if IsPlayerMoving() then
		for i = 2, PositionLogCounter do
			if size == PositionLog[i].size then
				v1 = math.abs(math.sqrt((PositionLog[i].x - x1) * (PositionLog[i].x - x1) + (PositionLog[i].y - y1) * (PositionLog[i].y - y1)) * size / ((t1 - PositionLog[i].t) / 10))
			else
				size = PositionLog[i].size
				v1 = math.abs(math.sqrt((PositionLog[i].x - x1) * (PositionLog[i].x - x1) + (PositionLog[i].y - y1) * (PositionLog[i].y - y1)) * size / ((PositionLog[i].t - t1) / 10))
			end
			x1 = PositionLog[i].x
			y1 = PositionLog[i].y
			t1 = PositionLog[i].t
			va = va + v1
		end
	end
	va = va / (PositionLogCounter - 1)
	PositionLogCounter = 0
	if FyrMM.MovementSpeedPrevious ~= nil then
		FyrMM.MovementSpeed = (va + FyrMM.MovementSpeedPrevious) / 2
	else
		FyrMM.MovementSpeed = va
	end
	if FyrMM.MovementSpeedPrevious ~= FyrMM.MovementSpeed then
		CALLBACK_MANAGER:FireCallbacks("MovementSpeedChanged", va * 100)
		FyrMM.MovementSpeedPrevious = FyrMM.MovementSpeed
	end
	if va > FyrMM.MovementSpeedMax then
		FyrMM.MovementSpeedMax = va
	end
	if FyrMM.SV.ShowSpeed then
		SetSpeedLabel(va)
	end
end

function FyrMM.PositionUpdate()
	if ((not FyrMM.Visible or Fyr_MM:IsHidden()) and FyrMM.Initialized) or not ZO_WorldMap:IsHidden() then
		return
	end
	if (not FyrMM.Visible or Fyr_MM:IsHidden()) and not FyrMM.Initialized then
		return
	end
	if not FyrMM.SV.WorldMapRefresh and GetMapId() ~= CurrentMap.MapId then
		FyrMM.ZoneCheck()
	end
	if Fyr_MM_Scroll_Map_0 == nil then
		return
	end
	if CurrentMap.Dx == nil then
		return
	end
	local a = GetGameTimeMilliseconds()
	local x = CurrentMap.PlayerNX
	local y = CurrentMap.PlayerNY
	local pheading = CurrentMap.PlayerHeading
	if x == nil or pheading == nil then
		x, y, pheading = GetMapPlayerPosition("player")
	end
	local currentTimeStamp = CurrentMap.currentTimeStap
	local speed = 0
	local moved = CurrentMap.PlayerMoved
	if CurrentMap.CameraHeading == nil then
		CurrentMap.CameraHeading = GetPlayerCameraHeading()
	end
	local cpheading = CurrentMap.CameraHeading
	if FyrMM.SV.RotateMap then
		cpheading = math.abs(pheading - pi * 2) + cpheading
	end
	Fyr_MM_Camera:SetTextureRotation(cpheading)
	local mapWidth = Fyr_MM_Scroll_Map_0:GetWidth()
	local mmWidth = Fyr_MM_Scroll:GetWidth()
	local widthCenter = mmWidth / 2
	local mapWidth = mapWidth * CurrentMap.Dx
	local mapHeight = Fyr_MM_Scroll_Map_0:GetHeight()
	local mmHeight = Fyr_MM_Scroll:GetHeight()
	local heightCenter = mmHeight / 2
	local mapHeight = mapHeight * CurrentMap.Dx
	local hscroll = x * mapWidth
	local hpos = hscroll - widthCenter
	local vscroll = y * mapHeight
	local vpos = vscroll - heightCenter
	local zoomlevel = 0
	local chp, cvp = Fyr_MM_Scroll:GetScrollOffsets()
	local heading = pheading
	if FyrMM.SV.PPStyle ~= GetString(SI_MM_STRING_PLAYERANDCAMERA) then
		if FyrMM.SV.Heading == "CAMERA" then
			heading = CurrentMap.CameraHeading
		end
		if not moved and FyrMM.SV.Heading == "MIXED" then
			heading = CurrentMap.CameraHeading
		end
	end
	if ((x < 1.2 and x > -0.2) and (y < 1.2 and y > -0.2)) then
		-- Can't let the scroll go too far outside view (Black map issue)
		if not Fyr_MM:IsHidden() and moved then
			FyrMM.SetMapToPlayerLocation()
		end
		CurrentMap.hpos = hpos
		CurrentMap.vpos = vpos
		if FyrMM.SV.RotateMap then
			Fyr_MM_Scroll:SetHorizontalScroll(0)
			Fyr_MM_Scroll:SetVerticalScroll(0)
			if CurrentMap.PlayerMoved or CurrentMap.PlayerTurned then
			end
		else
			Fyr_MM_Scroll:SetHorizontalScroll(hpos)
			Fyr_MM_Scroll:SetVerticalScroll(vpos)
		end
		if FyrMM.SV.WheelMap then
			FyrMM.WheelScroll(CurrentMap.hpos, CurrentMap.vpos)
		end
	else
		Fyr_MM_Scroll:SetHorizontalScroll(CurrentMap.hpos)
		Fyr_MM_Scroll:SetVerticalScroll(CurrentMap.vpos)
		if FyrMM.SV.WheelMap then
			FyrMM.WheelScroll(CurrentMap.hpos, CurrentMap.vpos)
		end
	end
	if FyrMM.SV.RotateMap then
		if CurrentMap.PlayerMoved or CurrentMap.PlayerTurned then
			FyrMM.UpdateMapTiles(CurrentMap.PlayerMoved)
			CurrentMap.needRescale = true
		end
		Fyr_MM_Player:SetTextureRotation(0)
	else
		Fyr_MM_Player:SetTextureRotation(heading)
	end
	a = GetGameTimeMilliseconds() - a
	if a > 0 then
		CALLBACK_MANAGER:FireCallbacks("FyrMMDebug", "FyrMM.PositionUpdate " .. tostring(a))
	end
end

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
-------------------------------------------------------------
-- Miscelaneous functions
-------------------------------------------------------------
function FyrMM.IsCoordinatesInMap(nX, nY)
	if nX <= 1 and nX >= 0 and nY <= 1 and nY >= 0 then
		return true
	else
		return false
	end
end

function FyrMM.SetCurrentMapZoom(newZoom)
	CurrentMap.ZoomLevel = newZoom
	if FyrMM.SV.ZoomTable ~= nil then
		FyrMM.SV.ZoomTable[CurrentMap.filename] = newZoom
	end
	Fyr_MM_ZoomLevel:SetText(newZoom)
end

function FyrMM.UnregisterUpdates()
	FyrMM.Halted = true
	FyrMM.HaltTimeOffset = GetFrameTimeMilliseconds()
	--EVENT_MANAGER:UnregisterForUpdate("OnUpdateFyrMMMapView")
	EVENT_MANAGER:UnregisterForUpdate("OnUpdateFyrMMMapZone")
	EVENT_MANAGER:UnregisterForUpdate("OnUpdateFyrMMMapPosition")
	EVENT_MANAGER:UnregisterForUpdate("OnUpdateFyrMMMapKeepNetwork")
	EVENT_MANAGER:UnregisterForUpdate("FyrMiniMapRWUpdate")
	EVENT_MANAGER:UnregisterForUpdate("FyrMiniMapRescale")
	EVENT_MANAGER:UnregisterForUpdate("FyrMiniMapWayshrineDistances")
	EVENT_MANAGER:UnregisterForUpdate("FyrMiniMapQuestGiverDistances")
end

function FyrMM.RegisterUpdates()
	FyrMM.UnregisterUpdates()
	FyrMM.Halted = false
	FyrMM.HaltTimeOffset = 0
	--EVENT_MANAGER:RegisterForUpdate("OnUpdateFyrMMMapView", FyrMM.SV.ViewRefreshRate, FyrMM.UpdateMapTiles)
	EVENT_MANAGER:RegisterForUpdate("OnUpdateFyrMMMapZone", FyrMM.SV.ZoneRefreshRate, FyrMM.ZoneUpdate)
	EVENT_MANAGER:RegisterForUpdate("OnUpdateFyrMMMapPosition", FyrMM.SV.MapRefreshRate, FyrMM.PositionUpdate)
	EVENT_MANAGER:RegisterForUpdate("OnUpdateFyrMMMapKeepNetwork", FyrMM.SV.KeepNetworkRefreshRate, FyrMM.UpdateKeepNetwork)
	EVENT_MANAGER:RegisterForUpdate("FyrMiniMapWayshrineDistances", 5000, WayshrineDistances)
	EVENT_MANAGER:RegisterForUpdate("FyrMiniMapQuestGiverDistances", 2000, QuestGiverDistances)
end

-------------------------------------------------------------
-- On Initialized
-------------------------------------------------------------
function FyrMM.LoadScreen()
	-- Initialize Player group events
	if not FyrMM.SV.StartupInfo then
		d("|ceeeeeeMiniMap by |c006600Fyrakin |ceeeeee v" .. FyrMM.Panel.version .. "|r")
	end
	if FYRMM_ZOOM_INCREMENT_AMOUNT == nil then
		FYRMM_ZOOM_INCREMENT_AMOUNT = 1
	end
	EVENT_MANAGER:RegisterForEvent( "MiniMapOnUnitCreated", EVENT_UNIT_CREATED, FyrMM.GroupEvent )
	EVENT_MANAGER:RegisterForEvent( "MiniMapOnUnitDestroyed", EVENT_UNIT_DESTROYED, FyrMM.GroupEvent )
	EVENT_MANAGER:RegisterForEvent( "MiniMapOnGroupDisbanded", EVENT_GROUP_DISBANDED, FyrMM.GroupEvent )
	EVENT_MANAGER:RegisterForEvent( "MiniMapOnLeaderUpdated", EVENT_LEADER_UPDATE, FyrMM.GroupEvent )
	FyrMM.GroupEvent()
	Fyr_MM_Player:SetHandler("OnMouseEnter", function(Fyr_MM_Player)
		FyrMM.SetTargetScale(Fyr_MM_Player, 1.3)
		InitializeTooltip(InformationTooltip, Fyr_MM, TOPLEFT, 0, 0)
		InformationTooltip:AppendUnitName("player")
	end)
	Fyr_MM_Player:SetHandler("OnMouseExit", function(Fyr_MM_Player)
		FyrMM.SetTargetScale(Fyr_MM_Player, 1)
		ClearTooltip(InformationTooltip)
	end)
	Fyr_MM_Player:SetMouseEnabled(true)
	EVENT_MANAGER:UnregisterForEvent( "MiniMap", EVENT_PLAYER_ACTIVATED )

end

function FyrMM.InitialPreload()
	local t = GetGameTimeMilliseconds()
	CALLBACK_MANAGER:FireCallbacks("FyrMMDebug", "FyrMM.InitialPreload Start:")
	local task = 0
	FyrMM.InitialPreloadTimeStamp = GetFrameTimeMilliseconds()
	FyrMM.SetMapToPlayerLocation()
	CurrentMap.ZoneId = GetCurrentMapZoneIndex()
	EVENT_MANAGER:RegisterForUpdate("OnFyrMiniMapInitialPreload", 30, function()
		if FyrMM.Reloading then
			return
		end
		task = task + 1
		if task == 1 then
			FyrMM.UpdateMapInfo()
		end
		if task == 2 then
			FyrMM.UpdateMapTiles(true)
		end
		if task == 3 then
			FyrMM.Show()
		end
		if task == 4 then
			FyrMM.MapHalfDiagonal()
		end
		if task == 5 then
			FyrMM.PositionUpdate()
		end
		if task == 6 then
			FyrMM.GroupEvent()
		end
		if task == 8 then
			CurrentMap.needRescale = true
		end
		if task == 10 and IsInCyrodiil() then
			FyrMM.RequestKeepRefresh()
		end
		if task >= 12 then
			CALLBACK_MANAGER:FireCallbacks("FyrMMDebug", "FyrMM.InitialPreload Done." .. tostring(GetGameTimeMilliseconds() - t))
			EVENT_MANAGER:UnregisterForUpdate("OnFyrMiniMapInitialPreload")
			FyrMM.RegisterUpdates()
		end
	end)
end

local function InitFinish()
	FyrMM.Initialized = true
	if FyrMM.SV.MenuAutoHide then
		zo_callLater(FyrMM.MenuFadeOut, 3000)
	end
end

local function OnInit()
	-- Initialize Map and Update events after add-on load
	Fyr_MM_Frame_Control:SetAnchor(CENTER, Fyr_MM, CENTER, 0, 0)
	Fyr_MM_Wheel_Background:SetAnchor(CENTER, Fyr_MM, CENTER, 0, 0)
	Fyr_MM_Wheel_Background:SetTexture("MiniMap/Textures/wheelbackground.dds")
	Fyr_MM_Scroll_WheelNS:SetAnchor(CENTER, Fyr_MM_Scroll, CENTER, 0, 0)
	Fyr_MM_Scroll_WheelWE:SetAnchor(CENTER, Fyr_MM_Scroll, CENTER, 0, 0)
	Fyr_MM_Scroll_WheelCenter:SetAnchor(CENTER, Fyr_MM_Scroll, CENTER, 0, 0)
	MenuAnimation = ZO_AlphaAnimation:New(Fyr_MM_Menu)
	
	FyrMM.LAM = LibStub("LibAddonMenu-2.0")
	FyrMM.CPL = FyrMM.LAM:RegisterAddonPanel("FyrMiniMap", FyrMM.Panel)
	FyrMM.SettingsPanel = FyrMM.LAM:RegisterOptionControls("FyrMiniMap", FyrMM.Options)
	
	Fyr_MM:SetHandler("OnMouseWheel", function(self, delta, ctrl, alt, shift)
		if not FyrMM.SV.MouseWheel then
			return
		end
		if delta < 0 then
			FyrMM.ZoomOut()
		else
			FyrMM.ZoomIn()
		end
	end)
	FyrMM.UpdateLabels()
	EVENT_MANAGER:RegisterForUpdate("OnUpdateFyrMMHideCheck", 100, FyrMM.HideCheck)
	EVENT_MANAGER:RegisterForUpdate("OnUpdateFyrMMLogPosition", 30, LogPosition)
	EVENT_MANAGER:RegisterForUpdate("OnUpdateFyrMMSpeedMeasure", 301, SpeedMeasure)
	EVENT_MANAGER:RegisterForEvent( "MiniMap", EVENT_DISCOVERY_EXPERIENCE, FyrMM.Wayshrines)
	
	EVENT_MANAGER:RegisterForEvent( "MiniMap", EVENT_KEEPS_INITIALIZED, FyrMM.RequestKeepRefresh)
	EVENT_MANAGER:RegisterForEvent( "MiniMap", EVENT_KEEP_ALLIANCE_OWNER_CHANGED, FyrMM.RequestKeepRefresh)
	EVENT_MANAGER:RegisterForEvent( "MiniMap", EVENT_KEEP_END_INTERACTION, FyrMM.RequestKeepRefresh)
	EVENT_MANAGER:RegisterForEvent( "MiniMap", EVENT_KEEP_GATE_STATE_CHANGED, FyrMM.RequestKeepRefresh)
	EVENT_MANAGER:RegisterForEvent( "MiniMap", EVENT_KEEP_GUILD_CLAIM_UPDATE, FyrMM.RequestKeepRefresh)
	EVENT_MANAGER:RegisterForEvent( "MiniMap", EVENT_KEEP_INITIALIZED, FyrMM.RequestKeepRefresh)
	EVENT_MANAGER:RegisterForEvent( "MiniMap", EVENT_KEEP_OWNERSHIP_CHANGED_NOTIFICATION, FyrMM.RequestKeepRefresh)
	EVENT_MANAGER:RegisterForEvent( "MiniMap", EVENT_KEEP_RESOURCE_UPDATE, FyrMM.RequestKeepRefresh)
	EVENT_MANAGER:RegisterForEvent( "MiniMap", EVENT_KEEP_START_INTERACTION, FyrMM.RequestKeepRefresh)
	EVENT_MANAGER:RegisterForEvent( "MiniMap", EVENT_KEEP_UNDER_ATTACK_CHANGED, FyrMM.RequestKeepRefresh)
	EVENT_MANAGER:RegisterForEvent( "MiniMap", EVENT_KILL_LOCATIONS_UPDATED, FyrMM.RequestKeepRefresh)
	
	CALLBACK_MANAGER:RegisterCallback("OnFyrMiniNewMapEntered", DelayedReload)
	CALLBACK_MANAGER:RegisterCallback("OnFyrMiniMapChanged", FyrMM.UpdateLabels)
	CALLBACK_MANAGER:RegisterCallback("FyrMMDebug", function(value)
		FyrMM.Debug_d(value)
	end)
	CALLBACK_MANAGER:RegisterCallback("OnWorldMapChanged", function(manual)
		if manual == nil then
			FyrMM.Refresh = true
			FyrMM.ZoneCheck()
			return false
		else
			FyrMM.Refresh = false
		end
	end)
	CALLBACK_MANAGER:RegisterCallback("OnWorldMapModeChanged", function(mode)
		EVENT_MANAGER:RegisterForUpdate("FyrMiniMapOnWorldMapModeChanged", 20, function()
			if ZO_WorldMap:IsHidden() then
				if SetMapToPlayerLocation() ~= SET_MAP_RESULT_CURRENT_MAP_UNCHANGED then
					CALLBACK_MANAGER:FireCallbacks("OnWorldMapChanged")
				end
				FyrMM.ZoneCheck()
			else
				FyrMM.UnregisterUpdates()
			end
			EVENT_MANAGER:UnregisterForUpdate("FyrMiniMapOnWorldMapModeChanged")
		end)
	end)
	
	ZO_PreHook(ZO_Fishing, "StartInteraction", function()
		local action = GetGameCameraInteractableActionInfo()
		if zo_strformat(SI_GAME_CAMERA_TARGET, action) == GetString(SI_GAMECAMERAACTIONTYPE13) then
			zo_callLater(FyrMM.RequestQuestPinUpdate, 4000)
		end
		return false
	end)
	ZO_PreHook(ZO_WorldMap, "SetHidden", FyrMM.WorldMapShowHide)
	
	ZO_PreHookHandler(ZO_GameMenu_InGame, "OnShow", function()
		zo_callLater(FyrMM.HideCheck, 10)
	end)
	ZO_PreHookHandler(ZO_GameMenu_InGame, "OnHide", function()
		zo_callLater(FyrMM.HideCheck, 10)
	end)
	ZO_PreHookHandler(ZO_InteractWindow, "OnShow", function()
		zo_callLater(FyrMM.HideCheck, 10)
	end)
	ZO_PreHookHandler(ZO_InteractWindow, "OnHide", function()
		zo_callLater(FyrMM.HideCheck, 10)
	end)
	ZO_PreHookHandler(ZO_KeybindStripControl, "OnShow", function()
		zo_callLater(FyrMM.HideCheck, 10)
	end)
	ZO_PreHookHandler(ZO_KeybindStripControl, "OnHide", function()
		zo_callLater(FyrMM.HideCheck, 10)
	end)
	ZO_PreHookHandler(ZO_MainMenuCategoryBar, "OnShow", function()
		zo_callLater(FyrMM.HideCheck, 10)
	end)
	ZO_PreHookHandler(ZO_MainMenuCategoryBar, "OnHide", function()
		zo_callLater(FyrMM.HideCheck, 10)
	end)
	
	zo_callLater(InitFinish, FyrMM.SV.ZoneRefreshRate)
end

local function OnLoaded(eventCode, addOnName)
	if addOnName ~= "MiniMap" then
		return
	end
	FyrMM.Initialized = false
	MM_CreateDataTables()
	FyrMM.SV = ZO_SavedVars:NewAccountWide( "FyrMMSV", 5, nil, FyrMM.Defaults, nil )
	if FyrMM.SV ~= nil then
		UpdateZoomTable()
		MM_LoadSavedVars()
	end
	FyrMM.API_Check()
	Fyr_MM:SetResizeHandleSize(MOUSE_CURSOR_RESIZE_NS)
	Fyr_MM:SetHandler("OnMouseEnter", function()
		FyrMM.OverMiniMap = true
		FyrMM.MenuFadeIn()
		Fyr_MM_Close:SetAlpha(1)
	end)
	Fyr_MM:SetHandler("OnMouseExit", function()
		FyrMM.OverMiniMap = false
		zo_callLater(FyrMM.MenuFadeOut, 3000)
		Fyr_MM_Close:SetAlpha(0)
	end)
	Fyr_MM_Menu:SetHandler("OnMouseEnter", function()
		FyrMM.OverMenu = true
		FyrMM.MenuFadeIn()
		Fyr_MM_Close:SetAlpha(1)
	end)
	Fyr_MM_Menu:SetHandler("OnMouseExit", function()
		FyrMM.OverMenu = false
		zo_callLater(FyrMM.MenuFadeOut, 3000)
		Fyr_MM_Close:SetAlpha(0)
	end)
	Fyr_MM:SetHandler("OnMouseUp", function(self)
		if not FyrMM.SV.LockPosition then
			local width = Fyr_MM:GetWidth()
			local height = Fyr_MM:GetHeight()
			MM_SetMapWidth(width)
			MM_SetMapHeight(height)
			FyrMM.SV.position.offsetX = Fyr_MM:GetLeft()
			FyrMM.SV.position.offsetY = Fyr_MM:GetTop()
			FyrMM.MapHalfDiagonal()
			MM_RefreshPanel()
		else
			local pos = {}
			pos.anchorTo = GetControl(pos.anchorTo)
			Fyr_MM:SetAnchor(FyrMM.SV.position.point, pos.anchorTo, FyrMM.SV.position.relativePoint, FyrMM.SV.position.offsetX, FyrMM.SV.position.offsetY)
			Fyr_MM:SetDimensions(FyrMM.SV.MapWidth, FyrMM.SV.MapHeight)
		end
	end)
	Fyr_MM_Coordinates:SetHandler("OnMouseUp", function(self)
		local pos = {}
		_, pos[1], pos[2], pos[3], pos[4], pos[5] = Fyr_MM_Coordinates:GetAnchor()
		if pos[2] ~= nil then
			pos[2] = pos[2]:GetName()
		end
		FyrMM.SV.CoordinatesAnchor = pos
	end)
	Fyr_MM_ZoneFrame:SetHandler("OnMouseUp", function(self)
		local pos = {}
		_, pos[1], pos[2], pos[3], pos[4], pos[5] = Fyr_MM_ZoneFrame:GetAnchor()
		if pos[1] == nil then
			return
		end
		if pos[2] ~= nil then
			pos[2] = pos[2]:GetName()
		end
		FyrMM.SV.ZoneFrameAnchor = pos
	end)
	Fyr_MM_Scroll:SetScrollBounding(0)
	Fyr_MM_Player_incombat:SetTexture("esoui/art/mappins/ava_attackburst_32.dds")
	AxisSwitch()
	zo_callLater(OnInit, 1000)
end

EVENT_MANAGER:RegisterForEvent( "MiniMap", EVENT_QUEST_POSITION_REQUEST_COMPLETE, OnQuestPositionRequestComplete)
EVENT_MANAGER:RegisterForEvent( "MiniMap", EVENT_ADD_ON_LOADED, OnLoaded)
EVENT_MANAGER:RegisterForEvent( "MiniMap", EVENT_ZONE_CHANGED, FyrMM.UpdateLabels)
--EVENT_MANAGER:RegisterForEvent( "MiniMap", EVENT_ZONE_UPDATE, function (eventCode, unitTag, newZoneName) d(eventCode) d(unitTag) d(newZoneName) end)
EVENT_MANAGER:RegisterForEvent( "MiniMap", EVENT_PLAYER_ACTIVATED, FyrMM.LoadScreen)
EVENT_MANAGER:RegisterForEvent( "MiniMap", EVENT_START_FAST_TRAVEL_INTERACTION, function(eventCode, index)
	FyrMM.FastTravelInteraction(true, index, eventCode)
end)
EVENT_MANAGER:RegisterForEvent( "MiniMap", EVENT_END_FAST_TRAVEL_INTERACTION, function(eventCode)
	FyrMM.FastTravelInteraction(false, nil, eventCode)
end)
EVENT_MANAGER:RegisterForEvent( "MiniMap", EVENT_START_FAST_TRAVEL_KEEP_INTERACTION, function(eventCode, index)
	FyrMM.FastTravelInteraction(true, index, eventCode)
end)
EVENT_MANAGER:RegisterForEvent( "MiniMap", EVENT_END_FAST_TRAVEL_KEEP_INTERACTION, function(eventCode)
	FyrMM.FastTravelInteraction(false, nil, eventCode)
end)
EVENT_MANAGER:RegisterForEvent( "MiniMap", EVENT_MOUNTED_STATE_CHANGED, function(eventCode, mounted)
	CurrentMap.PlayerMounted = mounted
end)
EVENT_MANAGER:RegisterForEvent( "MiniMap", EVENT_PLAYER_NOT_SWIMMING, function(eventCode)
	CurrentMap.PlayerSwimming = false
end)
EVENT_MANAGER:RegisterForEvent( "MiniMap", EVENT_PLAYER_SWIMMING, function(eventCode)
	CurrentMap.PlayerSwimming = true
end)
--[[
  [] Author: Martynas Petuska
  [] E-mail: martynas.petuska@outlook.com
  [] Date:   January 2018
--]]
---------------- NAMESPACE ----------------
ADDON = {}
-------------------------------------------

ADDON.name = "MyMiniMap";
ADDON.Sizes = {
	miniMapSize = 512,
	playerPinSize = 32,
	mapPinSize = 0
};
ADDON.Sizes.mapPinSize = ADDON.Sizes.playerPinSize * 1.75;
ADDON.Constants = {
	zoomDelta = 0.1
};
ADDON.Boundaries = {
	mapZoomMin = 0.5,
	mapZoomMax = 2.00
};
ADDON.UI = {};
ADDON.Classes = {};
ADDON.UI.isSetup = false;
ADDON.EventHandlers = {};
ADDON.UpdateInfo = {
	updatePending = true,
	Map = {
		mapId = 0,
		zoneId = 0,
		poiCount = 0,
		subZoneName = "",
		tileCountX = 0,
		tileCountY = 0,
		width = 0,
		height = 0
	},
	Player = {
		rotation = 0,
		nX = 0,
		nY = 0
	}
};
ADDON.DefaultSettings = {
	addonName = "My MiniMap",
	Theme = {
		hex = "00FF96"
	},
	MiniMap = {
		mapScale = 0.6,
		scrollScaleBase = 0.65,
		scrollScaleOffset = 0.15,
		mapZoom = 1,
		Position = {
			x = nil,
			y = nil
		}
	},
	isMapRotationEnabled = true
};
ADDON.Settings = ADDON.DefaultSettings;


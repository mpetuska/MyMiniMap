--[[
  [] Author: Martynas Petuska
  [] E-mail: martynas.petuska@outlook.com
  [] Date:   January 2018
--]]

MMM.name = "MyMiniMap";
MMM.Sizes = {
	miniMapSize = 512,
	playerPinSize = 32,
	mapPinSize = 0
};
MMM.Sizes.mapPinSize = MMM.Sizes.playerPinSize * 1.75;
MMM.Boundaries = {
	mapZoomMin = 0.5,
	mapZoomMax = 2.00
};
MMM.UI = {};
MMM.Classes = {};
MMM.UI.isSetup = false;
MMM.EventHandlers = {};
MMM.UpdateInfo = {
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
MMM.DefaultSettings = {
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
MMM.Settings = MMM.DefaultSettings;


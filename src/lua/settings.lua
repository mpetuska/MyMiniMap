--[[
  [] Author: Martynas Petuska
  [] E-mail: martynas.petuska@outlook.com
  [] Date:   January 2018
--]]
---------------- NAMESPACE ----------------
ADDON = {}
-------------------------------------------

ADDON.name = "MyMiniMap"
ADDON.UI = {}
ADDON.EventHandlers = {}
ADDON.UpdateInfo = {
	Map = {
		mapId = 0,
		zoneId = 0,
		tileCountX = 0,
		tileCountY = 0,
		width = 0,
		height = 0
	},
	Player = {
		rotation = 0,
		normX = 0,
		normY = 0
	}
}

ADDON.Settings = {
	MiniMap = {
		UpdateInfo = {
			Map = {},
			Player = {}
		}
	}
}
ADDON.settingsUpdatePending = true;
ADDON.DefaultSettings = {
	addonName = "My MiniMap",
	Theme = {
		hex = "00FF96"
	},
	MiniMap = {
		size = 400,
		scrollScaleBase = 0.65,
		scrollScaleOffset = 0.15,
		pinScale = 1,
		mapZoom = 1,
		Position = {
			x = nil,
			y = nil
		},
		
		
		isMiniMapHidden = false,
		isInCameraMode = true,
		isMapRotationEnabled = true,
		isUpdateEnabled = true
	}
};


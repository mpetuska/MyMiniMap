--[[
  [] Author: Martynas Petuska
  [] E-mail: martynas.petuska@outlook.com
  [] Date:   January 2018
--]]
ADDON = {}

ADDON.name = "MyMiniMap"
ADDON.Settings = {}
ADDON.UI = {}
ADDON.EventHandlers = {}

ADDON.DefaultSettings = {
	addonName = "My MiniMap",
	Theme = {
		hex = "00FF96"
	},
	Button = {
		xSize = 110,
		ySize = 25,
		normalFontObject = "GameFontNormalLarge",
		highlightFontObject = "GameFontHighlightLarge"
	},
	MiniMap = {
		size = 400,
		scrollScaleBase = 0.65,
		scrollScaleOffset = 0.15,
		mapZoom = 1,
		UpdateInfo = {
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
	},
	isMiniMapHidden = true,
	isInCameraMode = true,
	isUpdateEnabled = true
	
	
};


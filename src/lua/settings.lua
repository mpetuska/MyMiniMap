--[[
  [] Author: Martynas Petuska
  [] E-mail: martynas.petuska@outlook.com
  [] Date:   January 2018
--]]
ADDON = {}

ADDON.name = "MyMiniMap"
ADDON.Settings = {}
ADDON.UI = {}

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
			rotation = 0,
			playerPos = {
				x = 0,
				y = 0
			},
			tileCountX = 1,
			tileCountY = 1
		}
	},
	isMiniMapHidden = true,
	isInCameraMode = true,
	isUpdateEnabled = true
	
	
};


--[[
  [] Author: Martynas Petuska
  [] E-mail: martynas.petuska@outlook.com
  [] Date:   January 2018
--]]

---Splits the string by the given separator and returns them as vararg.
---@param str string
---@param sep string
---@return ...
function split(str, sep)
	local fields = {}
	
	local sep = sep or " "
	local pattern = string.format("([^%s]+)", sep)
	string.gsub(str, pattern, function(c)
		fields[#fields + 1] = c
	end)
	
	return unpack(fields)
end

---Prints the given arguments separated by space to the chat tab.
---@param ... any
---@return void
function ADDON:Print(...)
	local name = ADDON.Settings.addonName;
	local hex = ADDON.Settings.Theme.hex;
	local prefix = string.format("|c%s%s: |r", string.upper(hex), name);
	CHAT_SYSTEM:AddMessage(prefix .. table.concat({ ... }, " "));
end

---Prints a blank line.
---@param ... void
---@return void
function ADDON.Println()
	CHAT_SYSTEM:AddMessage(" ");
end

function OnUiUpdate()
	MiniMap:SetHidden(ADDON.Settings.isMinimapHidden)
	
	if (ADDON.Settings.isInCameraMode) then
		local rotation = GetPlayerCameraHeading()
		MiniMapWheel:SetTextureCoordsRotation(-rotation)
	else
		local _, _, rotation = GetMapPlayerPosition("player")
		MiniMapPlayerPin:SetTextureCoordsRotation(rotation)
	end
	
	--TODO WorldMapTileExtraction
	local tileTexture = (GetMapTileTexture(1)):lower()
	if tileTexture == nil or tileTexture == "" then
		tileTexture = "art/maps/tamriel/tamriel_0"
	end
	local pos = select(2, tileTexture:find("maps/([%w%-]+)/"))
	if pos == nil then
		return "tamriel_0", "tamriel_", "art/maps/tamriel/"
	end
	pos = pos + 1
	local texture = string.gsub(string.sub(tileTexture, pos), ".dds", ""), string.gsub(string.sub(tileTexture, pos), "0.dds", ""), string.sub(tileTexture, 1, pos - 1)
	
	MiniMapWorld:SetTexture("art/maps/tamriel/tamriel_0")
end
--[[
  [] Author: Martynas Petuska
  [] E-mail: martynas.petuska@outlook.com
  [] Date:   January 2018
--]]
---------------- NAMESPACE ----------------
local EventHandlers = ADDON.EventHandlers
-------------------------------------------

--- Creates or loads all of the saved variables from previous sessions.
---@return void
local function LoadSavedVariables()
	ADDON.Settings = ZO_SavedVars:New("Settings", 1, nil, ADDON.DefaultSettings or {})
end

--- Registers handler functions for events.
---@return void
local function RegisterEvents()
	EVENT_MANAGER:RegisterForEvent(ADDON.name .. "_ZoneChanged", EVENT_ZONE_CHANGED, EventHandlers.OnZoneChanged);
	EVENT_MANAGER:RegisterForEvent(ADDON.name .. "_SubZoneChanged", EVENT_CURRENT_SUBZONE_LIST_CHANGED, EventHandlers.OnSubZoneChanged);
	EVENT_MANAGER:RegisterForEvent(ADDON.name .. "_PlayerActivated", EVENT_PLAYER_ACTIVATED, EventHandlers.OnPlayerActivated);

	local questPinTextures = {
		[MAP_PIN_TYPE_ASSISTED_QUEST_CONDITION] = "EsoUI/Art/Compass/quest_icon_assisted.dds",
		[MAP_PIN_TYPE_ASSISTED_QUEST_OPTIONAL_CONDITION] = "EsoUI/Art/Compass/quest_icon_assisted.dds",
		[MAP_PIN_TYPE_ASSISTED_QUEST_ENDING] = "EsoUI/Art/Compass/quest_icon_assisted.dds",
		[MAP_PIN_TYPE_ASSISTED_QUEST_REPEATABLE_CONDITION] = "EsoUI/Art/Compass/repeatableQuest_icon_assisted.dds",
		[MAP_PIN_TYPE_ASSISTED_QUEST_REPEATABLE_OPTIONAL_CONDITION] = "EsoUI/Art/Compass/repeatableQuest_icon_assisted.dds",
		[MAP_PIN_TYPE_ASSISTED_QUEST_REPEATABLE_ENDING] = "EsoUI/Art/Compass/repeatableQuest_icon_assisted.dds",
		[MAP_PIN_TYPE_TRACKED_QUEST_CONDITION] = "EsoUI/Art/Compass/quest_icon.dds",
		[MAP_PIN_TYPE_TRACKED_QUEST_OPTIONAL_CONDITION] = "EsoUI/Art/Compass/quest_icon.dds",
		[MAP_PIN_TYPE_TRACKED_QUEST_ENDING] = "EsoUI/Art/Compass/quest_icon.dds",
		[MAP_PIN_TYPE_TRACKED_QUEST_REPEATABLE_CONDITION] = "EsoUI/Art/Compass/repeatableQuest_icon.dds",
		[MAP_PIN_TYPE_TRACKED_QUEST_REPEATABLE_OPTIONAL_CONDITION] = "EsoUI/Art/Compass/repeatableQuest_icon.dds",
		[MAP_PIN_TYPE_TRACKED_QUEST_REPEATABLE_ENDING] = "EsoUI/Art/Compass/repeatableQuest_icon.dds",
	}
	local breadcrumbQuestPinTextures = {
		[MAP_PIN_TYPE_ASSISTED_QUEST_CONDITION] = "EsoUI/Art/Compass/quest_icon_door_assisted.dds",
		[MAP_PIN_TYPE_ASSISTED_QUEST_OPTIONAL_CONDITION] = "EsoUI/Art/Compass/quest_icon_door_assisted.dds",
		[MAP_PIN_TYPE_ASSISTED_QUEST_ENDING] = "EsoUI/Art/Compass/quest_icon_door_assisted.dds",
		[MAP_PIN_TYPE_ASSISTED_QUEST_REPEATABLE_CONDITION] = "EsoUI/Art/Compass/repeatableQuest_icon_door_assisted.dds",
		[MAP_PIN_TYPE_ASSISTED_QUEST_REPEATABLE_OPTIONAL_CONDITION] = "EsoUI/Art/Compass/repeatableQuest_icon_door_assisted.dds",
		[MAP_PIN_TYPE_ASSISTED_QUEST_REPEATABLE_ENDING] = "EsoUI/Art/Compass/repeatableQuest_icon_door_assisted.dds",
		[MAP_PIN_TYPE_TRACKED_QUEST_CONDITION] = "EsoUI/Art/Compass/quest_icon_door.dds",
		[MAP_PIN_TYPE_TRACKED_QUEST_OPTIONAL_CONDITION] = "EsoUI/Art/Compass/quest_icon_door.dds",
		[MAP_PIN_TYPE_TRACKED_QUEST_ENDING] = "EsoUI/Art/Compass/quest_icon_door.dds",
		[MAP_PIN_TYPE_TRACKED_QUEST_REPEATABLE_CONDITION] = "EsoUI/Art/Compass/repeatableQuest_icon_door.dds",
		[MAP_PIN_TYPE_TRACKED_QUEST_REPEATABLE_OPTIONAL_CONDITION] = "EsoUI/Art/Compass/repeatableQuest_icon_door.dds",
		[MAP_PIN_TYPE_TRACKED_QUEST_REPEATABLE_ENDING] = "EsoUI/Art/Compass/repeatableQuest_icon_door.dds",
	}

	local function GetQuestIcon(isBreadcrumb, journalQuestIndex, stepIndex, conditionIndex, assisted)
		if (isBreadcrumb) then
			return breadcrumbQuestPinTextures[GetJournalQuestConditionType(journalQuestIndex, stepIndex, conditionIndex, assisted)]
		else
			return questPinTextures[GetJournalQuestConditionType(journalQuestIndex, stepIndex, conditionIndex, assisted)]
		end
	end

	EVENT_MANAGER:RegisterForEvent(ADDON.name .. "_ EVENT_QUEST_REMOVED",   EVENT_POI_UPDATED,
			--function(eventCode, isCompleted, journalIndex, questName, zoneIndex, poiIndex, questID)
			function(...)
				d(...)
				--ADDON.Classes.MapPin.RefreshAll(ADDON.Constants.PinType.QUEST);
			end);
	CALLBACK_MANAGER:RegisterCallback("OnWorldMapQuestsDataRefresh", function(...)
	end);
end

local function RegisterUpdates()
	EVENT_MANAGER:RegisterForUpdate(ADDON.name .. "_UiUpdate", 1, EventHandlers.OnUiUpdate);
end

--- Initialises the addon.
---@return void
function EventHandlers.OnAddonLoaded(event, addonName)
	if addonName ~= ADDON.name then
		return
	else
		EVENT_MANAGER:UnregisterForEvent(ADDON.name, EVENT_ADD_ON_LOADED)
	end
	LoadSavedVariables()
	
	SLASH_COMMANDS["/mmm"] = ADDON.HandleSlashCommands;
	ADDON.UI:Setup();
	RegisterEvents();
	RegisterUpdates();
	
	if (ADDON.Settings.MiniMap.Position.x == nil) then
		ADDON.Settings.MiniMap.Position.x, ADDON.Settings.MiniMap.Position.y = ADDON.UI.miniMap:GetCenter();
	end
	local fragment = ZO_FadeSceneFragment:New(ADDON.UI.miniMap);
	SCENE_MANAGER:GetScene("hud"):AddFragment(fragment);
	SCENE_MANAGER:GetScene("hudui"):AddFragment(fragment);
end

EVENT_MANAGER:RegisterForEvent(ADDON.name, EVENT_ADD_ON_LOADED, EventHandlers.OnAddonLoaded);
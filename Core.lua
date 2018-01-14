addon = {}

addon.name = "MyMiniMap"

function addon.OnPlayerCombatState(event, inCombat)
    if inCombat ~= addon.inCombat then
        addon.inCombat = inCombat
    end

    MyMiniMapIndicator:SetHidden(not inCombat)
end

function addon.OnIndicatorMoveStop()
    addon.savedVariables.LEFT = MyMiniMapIndicator:GetLeft()
    addon.savedVariables.TOP = MyMiniMapIndicator:GetTop()
end

function addon:RestorePosition()
    local left = addon.savedVariables.LEFT
    local top = addon.savedVariables.TOP

    MyMiniMapIndicator:ClearAnchors()
    MyMiniMapIndicator:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, left, top)
end

function addon:Initialise()
    self.inCombat = IsUnitInCombat("player")

    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_PLAYER_COMBAT_STATE, self.OnPlayerCombatState)

    self.savedVariables = ZO_SavedVars:New("DAO", 1, nil, {})

    self:RestorePosition()
end

function addon.OnAddonLoaded(event, addonName)
    if addonName == addon.name then
        addon:Initialise()
    end
    d(addonName)
end

EVENT_MANAGER:RegisterForEvent(addon.name, EVENT_ADD_ON_LOADED, addon.OnAddonLoaded)


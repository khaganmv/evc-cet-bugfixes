evc = {
    runtimeData = {
        cetOpen = false,
        inMenu = false,
        inGame = false,
        inCar = false
    },

    settings = {},

    defaultSettings = {
        controllerMode = false,
        cetKeys = false,
        windowsInput = 5,
        windowsHints = true,
        headlightsInput = 6,
        headlightsHint = true
    },
    config = require("modules/config"),
    utils = require("modules/utils"),
    input = require("modules/input"),
    ui = require("modules/ui"),
    GameUI = require("modules/GameUI")
}

function evc:new()
    registerForEvent("onInit", function()
        CName.add("evc_windows")
        CName.add("evc_lights")

        Observe('RadialWheelController', 'OnIsInMenuChanged', function(_, isInMenu) -- Setup observer and GameUI to detect inGame / inMenu
            self.runtimeData.inMenu = isInMenu
        end)

        Observe("ExitingEvents", "OnEnter", function ()
            self.utils.hideHints()
            self.runtimeData.inCar = false
        end)

        Observe("DriveEvents", "OnEnter", function ()
            self.utils.handleEnter(self)
        end)

        self.GameUI.OnSessionStart(function()
            self.runtimeData.inGame = true
            if Game.GetMountedVehicle(GetPlayer()) then
                self.utils.handleEnter(self)
            end
        end)

        self.GameUI.OnSessionEnd(function()
            self.runtimeData.inGame = false
            self.runtimeData.inCar = false
        end)

        self.runtimeData.inGame = not self.GameUI.IsDetached() -- Required to check if ingame after reloading all mods

        self.config.tryCreateConfig("config.json", self.defaultSettings)
        self.config.backwardComp("config.json", self.defaultSettings)
        self.settings = self.config.loadFile("config.json")
        self.input.startInputObserver(self)

        if Game.GetMountedVehicle(GetPlayer()) then
            self.utils.handleEnter(self)
        end

        self.ui.init(self)
    end)

    registerForEvent("onOverlayOpen", function()
        self.runtimeData.cetOpen = true
    end)

    registerForEvent("onOverlayClose", function()
        self.runtimeData.cetOpen = false
    end)

    registerForEvent("onShutdown", function ()
        self.utils.hideHints()
    end)

    registerInput("evcToggleWindows", "Raise / Lower the windows", function(keypress)
        if not self.settings.cetKeys then return end
        if keypress then self.utils.toggleWindows() end
    end)
    
    registerInput("evcToggleLights", "Toggle the headlights", function(keypress)
        if not self.settings.cetKeys then return end
        if keypress then self.utils.toggleHeadlights(self) end
    end)

    return evc
end

return evc:new()
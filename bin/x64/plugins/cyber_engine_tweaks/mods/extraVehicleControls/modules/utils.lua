local lang = require("modules/lang")

utils = {}

function utils.showInputHint(source, key, text)
    local evt = UpdateInputHintEvent.new()
    local data = InputHintData.new()
    data.action = key
    data.source = source
    data.localizedLabel = text
    evt = UpdateInputHintEvent.new()
    evt.data = data
    evt.show = true
    evt.targetHintContainer = "GameplayInputHelper"
    Game.GetUISystem():QueueEvent(evt)
end

function utils.hideInputHint(source)
    local evt = DeleteInputHintBySourceEvent.new()
    evt.source = source
    evt.targetHintContainer = "GameplayInputHelper"
    Game.GetUISystem():QueueEvent(evt)
end

function utils.toggleHeadlights(evc)
    if Game.GetMountedVehicle(GetPlayer()):GetVehicleComponent():GetVehicleControllerPS():GetHeadLightMode().value == "Off" then
        Game.GetMountedVehicle(GetPlayer()):GetVehicleComponent():GetVehicleController():ToggleLights(true, vehicleELightType.Head)
    else
        Game.GetMountedVehicle(GetPlayer()):GetVehicleComponent():GetVehicleController():ToggleLights(false, vehicleELightType.Head)
    end
end

function utils.toggleWindows()
    if Game.GetMountedVehicle(GetPlayer()):GetVehiclePS():GetWindowState(vehicleEVehicleDoor.seat_front_left).value == "Open" then
        Game.GetMountedVehicle(GetPlayer()):GetVehiclePS():CloseAllVehWindows()
    else
        Game.GetMountedVehicle(GetPlayer()):GetVehiclePS():OpenAllVehWindows()
    end
end

function utils.showHints(mod)
    local lightsDesc = lang.getText("toggleHeadlightsHint")
    if mod.settings.controllerMode then lightsDesc = GetLocalizedTextByKey("UI-Settings-ButtonMappings-Actions-VehicleCycleLights") end
    if mod.settings.headlightsHint and not mod.settings.cetKeys then utils.showInputHint("evc_lights", utils.getInputName(mod, "lights"), lightsDesc) end
    if mod.settings.windowsHints and not mod.settings.cetKeys then utils.showInputHint("evc_windows", utils.getInputName(mod, "windows"), lang.getText("toggleWindowsHint")) end
end

function utils.updateHints(mod)
    utils.hideHints()
    utils.showHints(mod)
end

function utils.hideHints()
    utils.hideInputHint("evc_windows")
    utils.hideInputHint("evc_lights")
    utils.hideInputHint("evcHints")
end

function utils.getInputName(mod, input)
    local keys = {"Keyboard_1", "Keyboard_2", "Keyboard_3", "Keyboard_4", "Keyboard_5", "Keyboard_6", "Keyboard_7", "Keyboard_8", "Keyboard_9", "Keyboard_0"}

    if input == "windows" then
        if mod.settings.controllerMode then
            return "UI_MoveLeft"
        else
            return keys[mod.settings.windowsInput]
        end
    else
        if mod.settings.controllerMode then
            return "UI_Apply"
        else
            return keys[mod.settings.headlightsInput]
        end
    end
end

function utils.handleEnter(mod)
    utils.showHints(mod)

    evc.runtimeData.inCar = true
end

return utils


PulsarUI.Overrides = PulsarUI.Overrides or {}

function PulsarUI.CreateToggleableOverride(method, override, toggleGetter)
    return function(...)
        return toggleGetter(...) and override(...) or method(...)
    end
end

local overridePopupsCvar = CreateClientConVar("pixel_ui_override_popups", (PulsarUI.OverrideDermaMenus > 1) and "1" or "0", true, false, "Should the default derma popups be restyled with PulsarUI UI?", 0, 1)
function PulsarUI.ShouldOverrideDermaPopups()
    local overrideSetting = PulsarUI.OverrideDermaMenus

    if not overrideSetting or overrideSetting == 0 then return false end
    if overrideSetting == 3 then return true end

    return overridePopupsCvar:GetBool()
end
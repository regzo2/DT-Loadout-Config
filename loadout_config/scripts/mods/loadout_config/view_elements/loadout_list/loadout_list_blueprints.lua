local mod = get_mod("loadout_config")

local ButtonPassTemplates = require("scripts/ui/pass_templates/button_pass_templates")

local ViewElementLoadoutListBlueprints = {
    spacing_vertical_small = {
        size = { 800, 5 }
    },
    spacing_vertical = {
        size = { 800, 20 }
    }
}

ViewElementLoadoutListBlueprints.loadout_button = {
    size = { 150, 25 },
    pass_template = ButtonPassTemplates.terminal_button_small,
    init = function(parent, widget, config, callback_name)
        local loadout = config.loadout
        local content = widget.content

        content.text = loadout.name
        content.loadout_item_data = loadout.item_data

        content.hotspot.pressed_callback = callback(parent, callback_name, widget, config)
    end,
    update = function(parent, widget, input_service, dt, t, ui_renderer)

    end
}

return ViewElementLoadoutListBlueprints
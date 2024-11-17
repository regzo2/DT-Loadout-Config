local mod = get_mod("loadout_config")

local ButtonPassTemplates = require("scripts/ui/pass_templates/button_pass_templates")
local UISoundEvents = require("scripts/settings/ui/ui_sound_events")
local UIFontSettings = require("scripts/managers/ui/ui_font_settings")

local card_text_style = table.clone(UIFontSettings.button_primary)

card_text_style.offset = {
	10,
	0,
	6,
}
card_text_style.text_horizontal_alignment = "left"
card_text_style.text_vertical_alignment = "center"
card_text_style.text_color = {
	255,
	216,
	229,
	207,
}
card_text_style.default_color = {
	255,
	216,
	229,
	207,
}
card_text_style.font_size = 18

local ViewElementWeaponListBlueprints = {
    spacing_vertical = {
        size = { 800, 10 }
    },
    spacing_header = {
        size = { 800, 20 }
    },
    weapon_card = {
        size = { 128, 48 },
        pass_template = ButtonPassTemplates.terminal_button_icon,
        init = function (parent, widget, entry, callback_name)
            local content = widget.content
            local style = widget.style

            content.hotspot.pressed_callback = callback(entry.instance, entry.callback_name, entry.item)
            content.select_callback = content.hotspot.pressed_callback

            local display_name = entry.item.display_name

            content.original_text = Localize(display_name)
            content.icon = entry.item.hud_icon
            style.icon.size = { 128, 48 }
            content.hotspot.use_is_focused = true
            content.hotspot.on_pressed_sound = UISoundEvents.default_click
        end,
    },
    weapon_card_mark_text = {
        size = { 156, 48 },
        pass_template = {
            {
                pass_type = "text",
                style_id = "text",
                value_id = "text",
                style = card_text_style,
                change_function = function (content, style)
                end,
            }
        },
        init = function (parent, widget, entry, callback_name)
            local content = widget.content
            content.text = Localize(entry.text)
        end,
    }
}

return ViewElementWeaponListBlueprints
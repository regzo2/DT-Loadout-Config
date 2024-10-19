local mod = get_mod("loadout_config")

local UIWorkspaceSettings = require("scripts/settings/ui/ui_workspace_settings")
local UIWidget = require("scripts/managers/ui/ui_widget")
local UIHudSettings = require("scripts/settings/ui/ui_hud_settings")
local UISoundEvents = require("scripts/settings/ui/ui_sound_events")
local ButtonPassTemplates = require("scripts/ui/pass_templates/button_pass_templates")

local scenegraph_definition = {
    screen = UIWorkspaceSettings.screen,
    background = {
        parent = "screen",
        scale = "fit",
        size = { 1920, 1080 },
        position = { 0, 0, 0 }
    },
    loadout_list_root = {
        parent = "background",
        vertical_alignment = "center",
        horizontal_alignment = "center",
        size = { 800, 0 },
        position = { 0, 200, 0 }
    },
    stat_slider_root = {
        parent = "background",
        vertical_alignment = "center",
        horizontal_alignment = "center",
        size = { 800, 50 },
        position = { 0, 50, 0 }
    },
    stat_slider_header = {
        parent = "stat_slider_root",
        vertical_alignment = "top",
        horizontal_alignment = "left",
        size = { 150, 21 },
        position = { 0, -20, 0 }
    },
    stat_slider_1 = {
        parent = "stat_slider_root",
        vertical_alignment = "center",
        horizontal_alignment = "center",
        size = { 100, 10 },
        position = { -300, 0, 1 }
    },
    stat_slider_2 = {
        parent = "stat_slider_root",
        vertical_alignment = "center",
        horizontal_alignment = "center",
        size = { 100, 10 },
        position = { -150, 0, 1 }
    },
    stat_slider_3 = {
        parent = "stat_slider_root",
        vertical_alignment = "center",
        horizontal_alignment = "center",
        size = { 100, 10 },
        position = { 0, 0, 1 }
    },
    stat_slider_4 = {
        parent = "stat_slider_root",
        vertical_alignment = "center",
        horizontal_alignment = "center",
        size = { 100, 10 },
        position = { 150, 0, 1 }
    },
    stat_slider_5 = {
        parent = "stat_slider_root",
        vertical_alignment = "center",
        horizontal_alignment = "center",
        size = { 100, 10 },
        position = { 300, 0, 1 }
    },
    slot_button_root = {
        parent = "background",
        vertical_alignment = "bottom",
        horizontal_alignment = "center",
        size = { 1000, 300 },
        position = { 0, -50, 0 }
    },
    slot_button_1 = {
        parent = "slot_button_root",
        vertical_alignment = "center",
        horizontal_alignment = "center",
        size = { 320, 25 },
        position = { -165, 0, 0 }
    },
    slot_button_2 = {
        parent = "slot_button_root",
        vertical_alignment = "center",
        horizontal_alignment = "center",
        size = { 320, 25 },
        position = { 165, 0, 0 }
    },
    slot_button_3 = {
        parent = "slot_button_root",
        vertical_alignment = "center",
        horizontal_alignment = "center",
        size = { 320, 25 },
        position = { -330, 30, 0 }
    },
    slot_button_4 = {
        parent = "slot_button_root",
        vertical_alignment = "center",
        horizontal_alignment = "center",
        size = { 320, 25 },
        position = { 0, 30, 0 }
    },
    slot_button_5 = {
        parent = "slot_button_root",
        vertical_alignment = "center",
        horizontal_alignment = "center",
        size = { 320, 25 },
        position = { 330, 30, 0 }
    },
    selected_card = {
        parent = "background",
        vertical_alignment = "center",
        horizontal_alignment = "center",
        size = { 500, 150 },
        position = { -1, -49, 0 }
    },
    weapon_root = {
        parent = "background",
        vertical_alignment = "top",
        horizontal_alignment = "left",
        size = { 1850, 790 },
        position = { 50, 50, 0 }
    },
    offer_button_root = {
        parent = "selected_card",
        vertical_alignment = "top",
        horizontal_alignment = "center",
        size = { 800, 350 },
        position = { 50, -75, 0 }
    },
    offer_button = {
        parent = "offer_button_root",
        vertical_alignment = "top",
        horizontal_alignment = "left",
        size = { 144, 64 },
        position = { 0, 0, 0 }
    },
    perk_selection_root = {
        parent = "weapon_root",
        vertical_alignment = "center",
        horizontal_alignment = "left",
        size = { 0, 650 },
        position = { 0, 0, 1 }
    },
    trait_selection_root = {
        parent = "weapon_root",
        vertical_alignment = "center",
        horizontal_alignment = "right",
        size = { 0, 650 },
        position = { -450, 0, 1 }
    }
}

local ItemSlotSettings = require("scripts/settings/item/item_slot_settings")
local slot_buttons_settings = {
    ItemSlotSettings.slot_primary,
    ItemSlotSettings.slot_secondary,
    ItemSlotSettings.slot_attachment_1,
    ItemSlotSettings.slot_attachment_2,
    ItemSlotSettings.slot_attachment_3
}
local stat_slider_passes = {
    {
        pass_type = "rect",
        style = {
            vertical_alignment = "center",
            horizontal_alignment = "left",
            color = { 180, 3, 3, 3 },
            offset = { 0, 0, 1 }
        }
    },
    {
        pass_type = "rect",
        style = {
            vertical_alignment = "center",
            horizontal_alignment = "center",
            color = Color.terminal_background_gradient(180, true),
            size = { 104, 14 },
            offset = { 0, 0, 0 }
        }
    },
    {
        pass_type = "rect",
        style = {
            vertical_alignment = "center",
            horizontal_alignment = "left",
            size = { 35, 10 },
            color = Color.terminal_background_selected(255, true),
            offset = { 0, 0, 2 }
        },
        change_function = function(content, style)
            style.size[1] = content.value * 100
        end
    },

    {
        pass_type = "triangle",
        style = {
            vertical_alignment = "center",
            horizontal_alignment = "left",
            triangle_corners = {
                { -5, 0 },
                { 0, 5 },
                { 0, -5 }
            },
            color = Color.white(180, true),
            offset = { -5, 5, 2 }
        },
        change_function = function(content, style)
            if content.hotspot_left.is_hover then
                style.color = Color.white(255, true)
            else
                style.color = Color.white(180, true)
            end
        end
    },
    {
        pass_type = "hotspot",
        content_id = "hotspot_left",
        content = {
            on_hover_sound = UISoundEvents.default_mouse_hover
        },
        style = {
            vertical_alignment = "center",
            horizontal_alignment = "left",
            size = { 5, 10 },
            offset = { -10, 0, 0 }
        },
        change_function = function(content, style, _, dt)
            local parent_content = content.parent
            local value = parent_content.value

            local is_held = content.is_held
            local on_pressed = content._input_pressed and not is_held
            local on_released = content.on_released

            if on_pressed then
                Managers.ui:play_2d_sound(UISoundEvents.default_click)
                parent_content.value = math.clamp(value - 0.01, 0, 1)
            elseif is_held then
                local held_dt = content.held_dt or 0
                held_dt = held_dt + dt
                content.held_dt = held_dt

                if held_dt > 0.75 then
                    parent_content.value = math.clamp(value - 0.005, 0, 1)
                end
            elseif on_released then
                content.held_dt = 0
            end
        end
    },

    {
        pass_type = "triangle",
        style = {
            vertical_alignment = "center",
            horizontal_alignment = "right",
            triangle_corners = {
                { 5, 0 },
                { 0, 5 },
                { 0, -5 },
            },
            color = Color.white(255, true),
            offset = { 105, 5, 2 }
        },
        change_function = function(content, style)
            if content.hotspot_right.is_hover then
                style.color = Color.white(255, true)
            else
                style.color = Color.white(180, true)
            end
        end
    },
    {
        pass_type = "hotspot",
        content_id = "hotspot_right",
        content = {
            on_hover_sound = UISoundEvents.default_mouse_hover
        },
        style = {
            vertical_alignment = "center",
            horizontal_alignment = "right",
            size = { 5, 10 },
            offset = { 10, 0, 0 }
        },
        change_function = function(content, style, _, dt)
            local parent_content = content.parent
            local value = parent_content.value

            local is_held = content.is_held
            local on_pressed = content._input_pressed and not is_held
            local on_released = content.on_released

            if on_pressed then
                Managers.ui:play_2d_sound(UISoundEvents.default_click)
                parent_content.value = math.clamp(value + 0.01, 0, 1)
            elseif is_held then
                local held_dt = content.held_dt or 0
                held_dt = held_dt + dt
                content.held_dt = held_dt

                if held_dt > 0.75 then
                    parent_content.value = math.clamp(value + 0.005, 0, 1)
                end
            elseif on_released then
                content.held_dt = 0
            end
        end
    },

    {
        pass_type = "text",
        value_id = "stat_text",
        value = "",
        style = {
            text_vertical_alignment = "center",
            text_horizontal_alignment = "left",
            font_type = "machine_medium",
            font_size = 14,
            text_color = UIHudSettings.color_tint_main_1,
            offset = { 0, -15, 2 }
        },
    },

    {
        pass_type = "text",
        value_id = "text",
        style = {
            text_vertical_alignment = "center",
            text_horizontal_alignment = "center",
            font_type = "machine_medium",
            font_size = 18,
            text_color = UIHudSettings.color_tint_main_1,
            offset = { 0, 15, 2 }
        },
        change_function = function(content, style)
            local value = string.format("%d%%", (content.value or 0) * 100)
            content.text = value
        end
    }
}
local weapon_card_passes = {
    {
        pass_type = "rect",
        style_id = "title_border",
        style = {
            vertical_alignment = "center",
            horizontal_alignment = "center",
            color = Color.terminal_frame(255, true),
            size = { nil, 1 },
            offset = { 0, -50, 1 }
        }
    },
    {
        pass_type = "texture",
        value = "content/ui/materials/frames/frame_tile_2px",
        value_id = "frame",
        style_id = "frame",
        style = {
            vertical_alignment = "center",
            horizontal_alignment = "center",
            color = Color.terminal_frame(255, true),
            offset = { 0, 0, 4 },
        }
    },
    {
        style_id = "background",
        pass_type = "rect",
        style = {
            horizontal_alignment = "center",
            vertical_alignment = "center",
            size = { nil, 150 },
            color = Color.terminal_background(255, true),
            offset = { 0, 0, -1 }
        }
    },
    {
        value = "content/ui/materials/hud/backgrounds/terminal_background_team_panels",
        style_id = "gradient",
        pass_type = "texture_uv",
        style = {
            horizontal_alignment = "center",
            vertical_alignment = "center",
            uvs = {
                { 0, 0 },
                { 1, 1 }
            },
            size = { nil, 25 },
            color = Color.terminal_background_gradient(nil, true),
            color_default = Color.terminal_background_gradient(nil, true),
            color_selected = { 150, 32, 165, 218 },
            offset = {
                0,
                -62.5,
                0
            }
        }
    },
    {
        value = "content/ui/materials/icons/items/containers/item_container_landscape",
        value_id = "icon",
        style_id = "icon",
        pass_type = "texture",
        style = {
            material_values = {
                use_placeholder_texture = 1
            },
            horizontal_alignment = "center",
            vertical_alignment = "bottom",
            size = { 256, 128 },
            color = UIHudSettings.color_tint_main_1,
            offset = {
                0,
                -2,
                5
            }
        },
        visibility_function = function(content, style)
            local use_placeholder_texture = style.material_values.use_placeholder_texture

            if use_placeholder_texture and use_placeholder_texture == 0 then
                return true
            end

            return false
        end
    },
    {
        pass_type = "text",
        value_id = "text",
        value = "",
        style = {
            font_type = "machine_medium",
            text_horizontal_alignment = "center",
            text_vertical_alignment = "center",
            font_size = 18,
            text_color = UIHudSettings.color_tint_main_1,
            offset = { 0, -62.5, 1 }
        },
        change_function = function(content, style)
            local cards = content.cards
            local current_card_item = cards and cards[content.index]
            if not current_card_item then
                return
            end

            local display_name = current_card_item.display_name
            content.text = (display_name == "n/a" and "Attachment") or Localize(display_name)
        end
    },
    {
        pass_type = "hotspot",
        content_id = "prev_hotspot",
        content = {},
        style = {
            size = { 30, 125 },
            vertical_alignment = "bottom",
            horizontal_alignment = "left"
        },
        change_function = function(content, style)
            local parent_content = content.parent
            if content.on_released then
                local num_cards = table.size(parent_content.cards)
                parent_content.index = parent_content.index - 1
                if parent_content.index < 1 then
                    parent_content.index = num_cards
                end
            end
        end
    },
    {
        pass_type = "hotspot",
        content_id = "next_hotspot",
        content = {},
        style = {
            size = { 30, 125 },
            vertical_alignment = "bottom",
            horizontal_alignment = "right"
        },
        change_function = function(content, style)
            local parent_content = content.parent
            if content.on_released then
                local num_cards = table.size(parent_content.cards)
                parent_content.index = parent_content.index + 1
                if parent_content.index > num_cards then
                    parent_content.index = 1
                end
            end
        end
    },
    {
        value = "content/ui/materials/buttons/arrow_01",
        style_id = "prev_arrow",
        pass_type = "texture_uv",
        style = {
            uvs = {
                { 1, 0 },
                { 0, 1 }
            },
            vertical_alignment = "center",
            horizontal_alignment = "left",
            size = { 11.5, 17 },
            color = UIHudSettings.color_tint_main_1,
            offset = { 9.25, 12.5, 3 }
        },
        change_function = function(content, style)
            style.color[1] = content.prev_hotspot.is_hover and 255 or 80
        end
    },
    {
        value = "content/ui/materials/buttons/arrow_01",
        style_id = "next_arrow",
        pass_type = "texture_uv",
        style = {
            uvs = {
                { 0, 0 },
                { 1, 1 }
            },
            vertical_alignment = "center",
            horizontal_alignment = "right",
            size = { 11.5, 17 },
            color = UIHudSettings.color_tint_main_1,
            offset = { -9.25, 12.5, 3 }
        },
        change_function = function(content, style)
            style.color[1] = content.next_hotspot.is_hover and 255 or 80
        end
    },
    {
        pass_type = "rect",
        style_id = "prev_rect",
        style = {
            size = { 30, 125 },
            vertical_alignment = "center",
            horizontal_alignment = "left",
            color = UIHudSettings.color_tint_main_3,
            offset = { 0, 12.5, 1 }
        },
        change_function = function(content, style)
            style.color[1] = content.prev_hotspot.is_hover and 255 or 20
        end
    },
    {
        pass_type = "rect",
        style_id = "next_rect",
        style = {
            size = { 30, 125 },
            vertical_alignment = "center",
            horizontal_alignment = "right",
            color = UIHudSettings.color_tint_main_3,
            offset = { 0, 12.5, 1 }
        },
        change_function = function(content, style)
            style.color[1] = content.next_hotspot.is_hover and 255 or 20
        end
    }
}

local widget_definitions = {
    background = UIWidget.create_definition({
        {
            pass_type = "rect",
            style = {
                color = Color.terminal_background(180, true),
                offset = { 0, 0, 0 }
            }
        }
    }, "background"),
    stat_slider_header = UIWidget.create_definition({
        {
            pass_type = "rect",
            style = {
                vertical_alignment = "center",
                horizontal_alignment = "center",
                color = Color.terminal_background(255, true),
                offset = { 0, 0, 0 }
            }
        },
        {
            pass_type = "texture",
            value = "content/ui/materials/frames/frame_tile_2px",
            style = {
                vertical_alignment = "center",
                horizontal_alignment = "center",
                color = Color.terminal_frame(255, true),
                offset = { 0, 0, 2 }
            }
        },
        {
            pass_type = "text",
            value = Localize("loc_item_information_stats_title_modifiers"),
            style = {
                font_type = "machine_medium",
                font_size = 18,
                text_vertical_alignment = "center",
                text_horizontal_alignment = "center",
                text_color = Color.terminal_text_body(255, true),
                offset = { 0, 0, 1 }
            }
        }
    }, "stat_slider_header"),
    stat_slider_background = UIWidget.create_definition({
        {
            pass_type = "rect",
            style = {
                vertical_alignment = "center",
                horizontal_alignment = "center",
                color = Color.terminal_background(255, true),
                offset = { 0, 0, 0 }
            }
        },
        {
            pass_type = "texture",
            value = "content/ui/materials/frames/frame_tile_2px",
            style = {
                vertical_alignment = "center",
                horizontal_alignment = "center",
                color = Color.terminal_frame(255, true),
                offset = { 0, 0, 2 }
            }
        }
    }, "stat_slider_root"),
    selected_card = UIWidget.create_definition(weapon_card_passes, "selected_card", {
        traits = {},
        perks = {},
        cards = {},
        index = 1
    }),
}

for i, slot_button_settings in ipairs(slot_buttons_settings) do
    local scenegraph_id = string.format("slot_button_%s", i)
    widget_definitions[scenegraph_id] = UIWidget.create_definition(ButtonPassTemplates.terminal_button_small, scenegraph_id, {
        index = i,
        text = Localize(slot_button_settings.display_name),
        hotspot = {
            on_pressed_sound = UISoundEvents.default_click
        }
    }, nil, {
        background = {
            default_color = Color.terminal_background(255, true),
            selected_color = Color.terminal_background_selected(255, true)
        }
    })
end

for i = 1, 5 do
    local scenegraph_id = string.format("stat_slider_%s", i)
    widget_definitions[scenegraph_id] = UIWidget.create_definition(stat_slider_passes, scenegraph_id, {
        value = 0
    })
end

local legend_inputs = {
    {
        input_action = "back",
        on_pressed_callback = "_on_back_pressed",
        display_name = "loc_class_selection_button_back",
        alignment = "left_alignment",
    },
}

return {
    slot_buttons_settings = slot_buttons_settings,
    scenegraph_definition = scenegraph_definition,
    widget_definitions = widget_definitions,
    legend_inputs = legend_inputs
}
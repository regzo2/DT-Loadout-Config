local mod = get_mod("loadout_config")

local UIWorkspaceSettings = require("scripts/settings/ui/ui_workspace_settings")
local UIWidget = require("scripts/managers/ui/ui_widget")
local UISoundEvents = require("scripts/settings/ui/ui_sound_events")
local ButtonPassTemplates = require("scripts/ui/pass_templates/button_pass_templates")

local scenegraph_definition = {
  screen = UIWorkspaceSettings.screen,
  pivot = {
    parent = "screen",
    vertical_alignment = "top",
    horizontal_alignment = "left",
    size = { 0, 0 },
    position = { 0, 0, 0 }
  },
  header = {
    parent = "pivot",
    vertical_alignment = "top",
    horizontal_alignment = "left",
    size = { 800, 25 },
    position = { 0, 25, 0 }
  },
  create_button = {
    parent = "header",
    vertical_alignment = "top",
    horizontal_alignment = "center",
    size = { 150, 20 },
    position = { -155, 32.5, 0 }
  },
  delete_button = {
    parent = "header",
    vertical_alignment = "top",
    horizontal_alignment = "center",
    size = { 150, 20 },
    position = { 0, 32.5, 0 }
  },
  reset_button = {
    parent = "header",
    vertical_alignment = "top",
    horizontal_alignment = "center",
    size = { 150, 20 },
    position = { 155, 32.5, 0 }
  },
  background = {
    parent = "header",
    vertical_alignment = "top",
    horizontal_alignment = "left",
    size = { 800, 175 },
    position = { 0, 25, 0 }
  },
  button_root = {
    parent = "background",
    vertical_alignment = "top",
    horizontal_alignment = "left",
    size = { 150, 25 },
    position = { 5, 5, 1 }
  }
}

local widget_definitions = {
  header = UIWidget.create_definition({
    {
      pass_type = "text",
      value = mod:localize("loadouts_header"),
      style = {
        font_type = "proxima_nova_bold",
        font_size = 24,
        text_vertical_alignment = "center",
        text_horizontal_alignment = "center",
        text_color = Color.terminal_text_body(255, true),
        offset = { 0, 0, 1 }
      }
    }
  }, "header"),
  create_button = UIWidget.create_definition(ButtonPassTemplates.terminal_button_small, "create_button", {
    text = "Create",
    hotspot = {
      on_pressed_sound = UISoundEvents.default_click
    }
  }, nil, {
    background = {
      default_color = Color.terminal_background(255, true),
      selected_color = Color.terminal_background_selected(255, true)
    }
  }),
  reset_button = UIWidget.create_definition(ButtonPassTemplates.terminal_button_small, "reset_button", {
    text = "Reset",
    hotspot = {
      on_pressed_sound = UISoundEvents.default_click
    }
  }, nil, {
    background = {
      default_color = Color.terminal_background(255, true),
      selected_color = Color.terminal_background_selected(255, true)
    }
  }),
  delete_button = UIWidget.create_definition(ButtonPassTemplates.terminal_button_small, "delete_button", {
    text = "Delete",
    hotspot = {
      on_pressed_sound = UISoundEvents.default_click
    }
  }, nil, {
    background = {
      default_color = Color.terminal_background(255, true),
      selected_color = Color.terminal_background_selected(255, true)
    }
  }),
}

local menu_settings = {
  scrollbar_width = 10,
  grid_size = { 790, 225 },
  grid_spacing = { 10, 10 },
  mask_size = { 800, 225 },
  title_height = 0,
  top_padding = 60,
  edge_padding = 20,
  scrollbar_position = { 0, 0 },
  use_terminal_background = true,
  --hide_dividers = true
}

local definitions = {
  scenegraph_definition = scenegraph_definition,
  widget_definitions = widget_definitions,
  widget_blueprints = widget_blueprints,
  menu_settings = menu_settings
}

return definitions

local mod = get_mod("loadout_config")

local UIWorkspaceSettings = require("scripts/settings/ui/ui_workspace_settings")
local UIWidget = require("scripts/managers/ui/ui_widget")
local UISoundEvents = require("scripts/settings/ui/ui_sound_events")
local ButtonPassTemplates = require("scripts/ui/pass_templates/button_pass_templates")

local ConfigViewDefs = mod:io_dofile("loadout_config/scripts/mods/loadout_config/views/loadout_config_view/loadout_config_view_definitions_" .. mod._loadout_layout_config)

local width = ConfigViewDefs.scenegraph_definition.loadout_cards_root.size[1] or 600 
local height = ConfigViewDefs.scenegraph_definition.loadout_cards_root.size[2] or 600

local scenegraph_definition = {
  screen = UIWorkspaceSettings.screen,
  pivot = {
    parent = "screen",
    vertical_alignment = "top",
    horizontal_alignment = "left",
    size = { 0, 0 },
    position = { 0, 0, 0 }
  },
  grid_mask = {
		horizontal_alignment = "center",
		parent = "grid_background",
		vertical_alignment = "center",
		size = { width + 40, height },
		position = {
			0,
			0,
			10,
		},
	},
}

local padding = 30

local menu_settings = {
    scrollbar_width = 7,
    grid_size = { width, height },
    grid_spacing = { 15, 0 },
    mask_size = { width, height },
    title_height = ConfigViewDefs.scenegraph_definition.loadout_cards_root.top_padding or 110,
    top_padding = ConfigViewDefs.scenegraph_definition.loadout_cards_root.top_padding or 110,
    edge_padding = 30,
    scrollbar_position = { 0, 0 },
    --use_terminal_background = true,
    bottom_chin = 6,
    hide_dividers = true,
    --ignore_blur = true
  }
  
local definitions = {
  scenegraph_definition = scenegraph_definition,
  widget_definitions = widget_definitions,
  menu_settings = menu_settings,
  use_named_layout = not mod._loadout_layout_config == "1"
}

return definitions
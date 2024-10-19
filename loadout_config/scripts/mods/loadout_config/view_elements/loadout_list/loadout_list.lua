local mod = get_mod("loadout_config")

local UIWidget = require("scripts/managers/ui/ui_widget")
local Archetypes = require("scripts/settings/archetype/archetypes")

local Definitions = mod:io_dofile("loadout_config/scripts/mods/loadout_config/view_elements/loadout_list/loadout_list_definitions")
local ViewElementLoadoutListBlueprints = mod:io_dofile("loadout_config/scripts/mods/loadout_config/view_elements/loadout_list/loadout_list_blueprints")

local MAX_LOADOUTS = 25

local ViewElementLoadoutList = class("ViewElementLoadoutList", "ViewElementGrid")
--------------------------------------------------------------------------------
--- LIFECYCLE METHODS ----------------------------------------------------------
--------------------------------------------------------------------------------

function ViewElementLoadoutList:init(parent, draw_layer, scale, context)
  self._reference_name = "ViewElementLoadoutList_" .. tostring(self)
  self._selected_loadout = nil

  self._external_pressed_callback = context.pressed_callback
  self._external_create_callback = context.create_callback
  self._external_reset_callback = context.reset_callback
  self._max_loadouts = context.max_loadouts or MAX_LOADOUTS

  ViewElementLoadoutList.super.init(self, parent, draw_layer, scale, Definitions.menu_settings, Definitions)

  self:_init_loadouts()

  local widgets_by_name = self._widgets_by_name
  local create_button = widgets_by_name.create_button
  local delete_button = widgets_by_name.delete_button
  local reset_button = widgets_by_name.reset_button

  create_button.content.hotspot.pressed_callback = callback(self, "_on_create_button_pressed")
  delete_button.content.hotspot.pressed_callback = callback(self, "_on_delete_button_pressed")
  reset_button.content.hotspot.pressed_callback = callback(self, "_on_reset_button_pressed")

  self:set_empty_message("")
end

function ViewElementLoadoutList:update(dt, t, input_service)
  ViewElementLoadoutList.super.update(self, dt, t, input_service)

  self:_update_active_selection()
end

function ViewElementLoadoutList:_draw_widgets(dt, t, input_service, ui_renderer, render_settings)
  ViewElementLoadoutList.super._draw_widgets(self, dt, t, input_service, ui_renderer, render_settings)

  for i, loadout_widget in ipairs(self._loadout_widgets) do
    UIWidget.draw(loadout_widget, ui_renderer)
  end
end

function ViewElementLoadoutList:destroy(ui_renderer)
  mod:set("saved_loadouts", self._saved_loadouts)

  ViewElementLoadoutList.super.destroy(self, ui_renderer)
end

--------------------------------------------------------------------------------
--- /LIFECYCLE METHODS ---------------------------------------------------------
--------------------------------------------------------------------------------

function ViewElementLoadoutList:clear_selection()
  self._selected_loadout = nil
end

function ViewElementLoadoutList:archetype_name()
  local parent = self._parent
  local profile = parent:player_profile()
  local archetype = profile.archetype
  local archetype_name = archetype.name

  return archetype_name
end

function ViewElementLoadoutList:set_pivot_offset(x, y)
  self:_set_scenegraph_position("pivot", x, y)
end

function ViewElementLoadoutList:_init_loadouts()
  local saved_loadouts = mod:get("saved_loadouts")

  if not saved_loadouts then
    saved_loadouts = {}

    for archetype_name in pairs(Archetypes) do
      saved_loadouts[archetype_name] = {}
    end
  end

  self._saved_loadouts = saved_loadouts
  self._loadout_widgets = {}

  local parent = self._parent
  local profile = parent:player_profile()
  local archetype = profile.archetype
  local archetype_name = archetype.name
  local archetype_loadouts = saved_loadouts[archetype_name] or {}

  if not archetype_loadouts or #archetype_loadouts == 0 then
    self:present_grid_layout({}, ViewElementLoadoutListBlueprints)
    return
  end

  local layout = {
    {
      widget_type = "spacing_vertical_small"
    }
  }

  for i, loadout in ipairs(archetype_loadouts) do
    table.insert(layout, {
      widget_type = "loadout_button",
      loadout = loadout
    })
  end

  table.insert(layout, {
    widget_type = "spacing_vertical"
  })

  local left_click_callback = callback(self, "_on_loadout_button_pressed")

  self:present_grid_layout(layout, ViewElementLoadoutListBlueprints, left_click_callback)
end

function ViewElementLoadoutList:_on_reset_button_pressed()
  self._selected_loadout = nil

  local external_reset_callback = self._external_reset_callback
  if external_reset_callback then
    external_reset_callback()
  end
end

function ViewElementLoadoutList:_on_create_button_pressed()
  local loadout_widgets = self:widgets()
  local index = #loadout_widgets + 1

  if index > self._max_loadouts then
    mod:notify("Loadout limit reached")
    return
  end

  local loadout_name = string.format("Loadout %s", index)
  local parent = self._parent
  local loadout_item_data = parent:_pack_loadout_to_profile()

  loadout_item_data = {
    slot_primary = loadout_item_data.slot_primary,
    slot_secondary = loadout_item_data.slot_secondary,
    slot_attachment_1 = loadout_item_data.slot_attachment_1,
    slot_attachment_2 = loadout_item_data.slot_attachment_2,
    slot_attachment_3 = loadout_item_data.slot_attachment_3,
    custom = true
  }

  local loadout = {
    name = loadout_name,
    item_data = loadout_item_data
  }

  local profile = parent:player_profile()
  local archetype = profile.archetype
  local archetype_name = archetype.name
  local archetype_loadouts = self._saved_loadouts[archetype_name]
  table.insert(archetype_loadouts, loadout)

  mod:set("saved_loadouts", self._saved_loadouts)

  self:_init_loadouts()
  self._grid:select_last_index()
end

function ViewElementLoadoutList:_on_delete_button_pressed()
  local saved_loadouts = self._saved_loadouts

  local selected_widget = self:selected_grid_widget()

  if not selected_widget then
    return
  end

  local selected_widget_index = self:widget_index(selected_widget)

  self:remove_widget(selected_widget)

  local parent = self._parent
  local profile = parent:player_profile()
  local archetype = profile.archetype
  local archetype_name = archetype.name
  local archetype_loadouts = saved_loadouts[archetype_name]

  table.remove(archetype_loadouts, selected_widget_index)
end

function ViewElementLoadoutList:_on_loadout_button_pressed(loadout_button)
  self:select_grid_widget(loadout_button)

  local external_pressed_callback = self._external_pressed_callback

  if external_pressed_callback then
    external_pressed_callback(loadout_button)
  end
end

function ViewElementLoadoutList:_update_active_selection()
  local loadout_widgets = self:widgets() or {}

  local widgets_by_name = self._widgets_by_name
  local delete_button = widgets_by_name.delete_button
  delete_button.content.hotspot.disabled = not self:selected_grid_index()

  local create_button = widgets_by_name.create_button
  create_button.content.hotspot.disabled = #loadout_widgets >= self._max_loadouts
end

return ViewElementLoadoutList

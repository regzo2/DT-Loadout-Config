local mod = get_mod("loadout_config")

local UIWidget = require("scripts/managers/ui/ui_widget")
local Archetypes = require("scripts/settings/archetype/archetypes")
local UISettings = require("scripts/settings/ui/ui_settings")
local ITEM_TYPES = UISettings.ITEM_TYPES
local MasterItems = require("scripts/backend/master_items")
local Definitions = mod:io_dofile("loadout_config/scripts/mods/loadout_config/view_elements/loadout_weapon_cards/loadout_weapon_cards_definitions")
local Blueprints = mod:io_dofile("loadout_config/scripts/mods/loadout_config/view_elements/loadout_weapon_cards/loadout_weapon_cards_blueprints")
local ViewElementWeaponCards = class("ViewElementWeaponCards", "ViewElementGrid")

local function sort_by_parent_pattern_name(a, b)
  if a.item and b.item then
    return tostring(a.item.parent_pattern) < tostring(b.item.parent_pattern)
  end
  return false
end

function ViewElementWeaponCards:init(parent, draw_layer, scale, context)
  self._reference_name = "ViewElementWeaponCards_" .. tostring(self)
  ViewElementWeaponCards.super.init(self, parent, draw_layer, scale, Definitions.menu_settings, Definitions)
  self:present_grid_layout({}, Blueprints)
end

function ViewElementWeaponCards:update(dt, t, input_service)
  ViewElementWeaponCards.super.update(self, dt, t, input_service)

  --self:_update_active_selection()
end

local current_selected_slot = nil

ViewElementWeaponCards.present_items = function(self, slot, instance, callback_name)

  if slot == current_selected_slot then
    return
  end

  current_selected_slot = slot

  local items = self:_get_items(slot)

  if mod._loadout_layout_config == "1" then
    self:_items_to_tiled_layout(items, instance, callback_name)
  else
    self:_items_to_named_layout(items, instance, callback_name)
  end
end

ViewElementWeaponCards._get_items = function(self, slot)
  local player = Managers.player:local_player(1)
  local profile = player:profile()

  local filtered_patterns = {}
  local patterns = UISettings.weapon_patterns

  for _, pattern in pairs(patterns) do
    for _, mark in pairs(pattern.marks) do
      local item = MasterItems.get_item(mark.item)

      if not item then
        goto continue
      end

      local archetype = profile.archetype
      local archetype_name = archetype.name
      local breed_name = archetype.breed

      if item and mod._enforce_class_restrictions then
        local breed_valid = not item.breeds or table.contains(item.breeds, breed_name)
        local archetype_valid = not item.archetypes or table.contains(item.archetypes, archetype_name)

        if not archetype_valid or not breed_valid then
          goto continue
        end
      end

      if item and item.item_type == slot then
        local is_human_and_ogryn_weapon = breed_name == "human" and table.contains(item.breeds, "ogryn")
        if not is_human_and_ogryn_weapon then
          if not filtered_patterns[pattern] then
            filtered_patterns[pattern] = {}
            filtered_patterns[pattern].marks = {}
            filtered_patterns[pattern].display_name = pattern.display_name
          end
          if not filtered_patterns[pattern].marks[mark] then
            filtered_patterns[pattern].marks[mark] = item
          end
          filtered_patterns[pattern].marks[mark] = item
        end
      end
      ::continue::
    end
  end

  return filtered_patterns
end

ViewElementWeaponCards._items_to_named_layout = function(self, items, instance, callback_name)
  local layout = {}

  table.insert(layout, {
    widget_type = "spacing_header",
  })

  for _, pattern in pairs(items) do
    table.insert(layout, {
      widget_type = "weapon_card_mark_text",
      text = pattern.display_name,
      callback_name = callback_name
    })
    for _, mark in pairs(pattern.marks) do
      table.insert(layout, {
        widget_type = "weapon_card",
        item = mark,
        instance = instance,
        callback_name = callback_name
      })
    end
    table.insert(layout, {
      widget_type = "spacing_vertical",
    })
  end

  self:present_grid_layout(layout, Blueprints)
end

ViewElementWeaponCards._items_to_tiled_layout = function(self, items, instance, callback_name)
  local layout = {}

  table.insert(layout, {
    widget_type = "spacing_header",
  })

  local index = 1

  for _, pattern in pairs(items) do
    for _, mark in pairs(pattern.marks) do
      table.insert(layout, {
        widget_type = "weapon_card",
        item = mark,
        instance = instance,
        callback_name = callback_name
      })
      index = index+1
      if index == 6 then
        index = 1
        table.insert(layout, {
          widget_type = "spacing_vertical",
        })
      end
    end
  end

  --table.sort(layout, sort_by_parent_pattern_name)

  self:present_grid_layout(layout, Blueprints)
end

return ViewElementWeaponCards
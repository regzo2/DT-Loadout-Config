local mod = get_mod("loadout_config")

local UIWidget = require("scripts/managers/ui/ui_widget")
local UISoundEvents = require("scripts/settings/ui/ui_sound_events")
local UISettings = require("scripts/settings/ui/ui_settings")
local ITEM_TYPES = UISettings.ITEM_TYPES
local MasterItems = require("scripts/backend/master_items")
local ItemUtils = require("scripts/utilities/items")
local WeaponTemplate = require("scripts/utilities/weapon/weapon_template")
local ViewElementInputLegend = require("scripts/ui/view_elements/view_element_input_legend/view_element_input_legend")
local ViewElementPerksItem = require("scripts/ui/view_elements/view_element_perks_item/view_element_perks_item")
local ViewElementTraitInventory = require("scripts/ui/view_elements/view_element_trait_inventory/view_element_trait_inventory")
local ButtonPassTemplates = require("scripts/ui/pass_templates/button_pass_templates")
local LoadoutList = mod:io_dofile("loadout_config/scripts/mods/loadout_config/view_elements/loadout_list/loadout_list")
local WeaponCards = mod:io_dofile("loadout_config/scripts/mods/loadout_config/view_elements/loadout_weapon_cards/loadout_weapon_cards")
local MasteryUtils = require("scripts/utilities/mastery")
local Promise = require("scripts/foundation/utilities/promise")
local RankSettings = require("scripts/settings/item/rank_settings")

local function sort_offer_by_display_name(a, b)
  local item_a = MasterItems.get_item(a.description.lootChoices[1])
  local item_b = MasterItems.get_item(b.description.lootChoices[1])
  return Localize(item_a.display_name) < Localize(item_b.display_name)
end

local function sort_by_parent_pattern_name(a, b)
  return tostring(a.parent_pattern) < tostring(b.parent_pattern)
end

local _gadgets_list = table.filter(MasterItems.get_cached(), function(item)
  return item.item_type == ITEM_TYPES.GADGET and item.is_display_name_ref
end)
local _gadgets_list_size = table.size(_gadgets_list)

local function _get_random_gadget()
  local rand = math.random(_gadgets_list_size)

  local i = 1
  for gadget_name in pairs(_gadgets_list) do
    if i == rand then
      return table.clone(MasterItems.get_item(gadget_name))
    end
    i = i + 1
  end

end

local _use_override_speed = true
local function _sin_time_since_launch(optional_speed)
  optional_speed = _use_override_speed and 2 or optional_speed or 1
  local time_since_launch = Application.time_since_launch() * optional_speed
  return math.sin(time_since_launch)
end

local Definitions = mod:io_dofile("loadout_config/scripts/mods/loadout_config/views/loadout_config_view/loadout_config_view_definitions_" .. mod._loadout_layout_config)
local slot_buttons_settings = Definitions.slot_buttons_settings

local LoadoutConfigView = class("LoadoutConfigView", "BaseView")
function LoadoutConfigView:init(settings)
  local extra_package_name = "packages/ui/views/crafting_replace_perk_view/crafting_replace_perk_view"

  LoadoutConfigView.super.init(self, Definitions, settings, nil, extra_package_name)

  local player = self:_player()
  local profile = player:profile()
  self._profile = table.clone_instance(profile)

  Managers.event:register(self, "event_player_profile_updated", "event_player_profile_updated")
end

function LoadoutConfigView:event_player_profile_updated(peer_id, local_player_id, new_profile)
  if peer_id ~= Network.peer_id() or local_player_id ~= 1 then
    return
  end

  local loadout = new_profile.loadout
  local selected_card = self._widgets_by_name.selected_card

  selected_card.content.cards = {
    loadout.slot_primary and loadout.slot_primary.__master_item,
    loadout.slot_secondary and loadout.slot_secondary.__master_item,
    loadout.slot_attachment_1 and loadout.slot_attachment_1.__master_item or _get_random_gadget(),
    loadout.slot_attachment_2 and loadout.slot_attachment_2.__master_item or _get_random_gadget(),
    loadout.slot_attachment_3 and loadout.slot_attachment_3.__master_item or _get_random_gadget(),
  }

  self._profile = table.clone_instance(new_profile)
end

function LoadoutConfigView:player_profile()
  return self._profile
end

function LoadoutConfigView:_setup_elements()
  --self:_populate_weapon_cards()

  local player = self:_player()
  local profile = player:profile()
  local loadout = profile.loadout
  local selected_card = self._selected_card

  selected_card.content.cards = {
    loadout.slot_primary and loadout.slot_primary.__master_item,
    loadout.slot_secondary and loadout.slot_secondary.__master_item,
    loadout.slot_attachment_1 and loadout.slot_attachment_1.__master_item or _get_random_gadget(),
    loadout.slot_attachment_2 and loadout.slot_attachment_2.__master_item or _get_random_gadget(),
    loadout.slot_attachment_3 and loadout.slot_attachment_3.__master_item or _get_random_gadget(),
  }

  local widgets_by_name = self._widgets_by_name
  for i = 1, #slot_buttons_settings do
    local widget_name = string.format("slot_button_%s", i)
    local widget = widgets_by_name[widget_name]
    local slot = i == 1 and "WEAPON_MELEE" or i == 2 and "WEAPON_RANGED" or "GADGET"
    widget.content.hotspot.pressed_callback = callback(self, "_on_slot_button_pressed", slot, i)
  end

  self._loadout_cards = self:_add_element(WeaponCards, "loadout_cards", 10, nil, "loadout_cards_root")
  self:_update_element_position("loadout_cards_root", self._loadout_cards)
  self._loadout_cards:present_items("WEAPON_MELEE", self, "_on_offer_button_selected")

  local loadout_list_context = {
    max_loadouts = 20,
    pressed_callback = callback(self, "_on_loadout_button_pressed"),
    reset_callback = callback(self, "_on_reset_button_pressed")
  }

  self._loadout_list = self:_add_element(LoadoutList, "loadout_list", 0, loadout_list_context , "loadout_list_root")
  self:_update_element_position("loadout_list_root", self._loadout_list)

  self._perk_selection = self:_add_element(ViewElementPerksItem, "perk_selection", 10, nil, "perk_selection_root")
  self:_update_element_position("perk_selection_root", self._perk_selection)

  self._trait_selection = self:_add_element(ViewElementTraitInventory, "trait_selection", 10, nil, "trait_selection_root")
  self._trait_selection._on_trait_hover = function(self, config)
    local trait_item = config.trait_item
    if not trait_item.value then
      trait_item = trait_item.__master_item
      trait_item.value = trait_item.rarity * 0.25
    end
    self._hovered_trait_item = config.trait_item
  end
  self:_update_element_position("trait_selection_root", self._trait_selection)
end

function LoadoutConfigView:on_enter()
  LoadoutConfigView.super.on_enter(self)

  self:_setup_input_legend()

  self._render_settings.alpha_multiplier = 1 -- hack fix to prevent nil, literally wtf

  self._saved_loadouts = mod:get("saved_loadouts") or {}
  self._selected_card = self._widgets_by_name.selected_card
  self._selected_card.content.index = mod.last_selected_index or 1

  local store_service = Managers.data_service.store
  store_service:get_credits_goods_store():next(function(data)
    self._offers = data.offers
    self:_setup_elements()
  end)

  self._is_open = true
  Imgui.open_imgui()
end

function LoadoutConfigView:_populate_weapon_cards()
  local player = self:_player()
  local profile = player:profile()
  local loadout = profile.loadout
  local selected_card = self._selected_card

  selected_card.content.cards = {
    loadout.slot_primary and loadout.slot_primary.__master_item,
    loadout.slot_secondary and loadout.slot_secondary.__master_item,
    loadout.slot_attachment_1 and loadout.slot_attachment_1.__master_item or _get_random_gadget(),
    loadout.slot_attachment_2 and loadout.slot_attachment_2.__master_item or _get_random_gadget(),
    loadout.slot_attachment_3 and loadout.slot_attachment_3.__master_item or _get_random_gadget(),
  }

  self._profile = profile

  local slot_primary_offer_widgets = {}
  local slot_secondary_offer_widgets = {}
  local slot_attachment_offer_widgets = {}

  local offer_widget_names = {}
  local widgets = self._widgets
  local offers = self._offers

  local items = {}
  local patterns = UISettings.weapon_patterns
  for _, pattern in pairs(patterns) do
    for _, mark in pairs(pattern.marks) do
      local item = MasterItems.get_item(mark.item)
      table.insert(items, item)
    end
  end

  table.sort(items, sort_by_parent_pattern_name)

  local first_time = true

  for i, item in pairs(items) do
    if not item.parent_pattern or item.display_name == "" then
      goto continue
    end

    if mod._enforce_class_restrictions then
      local archetype = profile.archetype
      local archetype_name = archetype.name
      local breed_name = archetype.breed
      local breed_valid = not item.breeds or table.contains(item.breeds, breed_name)
      local archetype_valid = not item.archetypes or table.contains(item.archetypes, archetype_name)

      if not archetype_valid or not breed_valid then
        goto continue
      end
    end

    local item_type = item.item_type
    local hud_icon = item.hud_icon

    local slot_offer_widgets
    if item_type == ITEM_TYPES.WEAPON_MELEE then
      slot_offer_widgets = slot_primary_offer_widgets
    elseif item_type == ITEM_TYPES.WEAPON_RANGED then
      slot_offer_widgets = slot_secondary_offer_widgets
    elseif item_type == ITEM_TYPES.GADGET then
      slot_offer_widgets = slot_attachment_offer_widgets
    end

    local widget_definition = UIWidget.create_definition(ButtonPassTemplates.terminal_button_icon, "offer_button_root", {
      item = item,
      item_id = item_id,
      item_type = item_type,
      icon = hud_icon or "content/ui/materials/icons/weapons/hud/combat_blade_01",
      hotspot = {
        on_pressed_sound = UISoundEvents.default_click
      }
    }, { 128, 48 }, {
      icon = {
        size = { 128, 48 }
      }
    })

    local index = #slot_offer_widgets + 1
    local widget_id = string.format("offer_button_%s_%s", item_type, index)
    local widget = self:_create_widget(widget_id, widget_definition)
    local row = (index - 1) / 5

    widget.content.hotspot.pressed_callback = callback(self, "_on_offer_button_selected", widget)
    widget.offset = {
      (index - 1) % 5 * 140,
      math.floor(row) * -60,
      1
    }

    table.insert(offer_widget_names, widget_id)
    table.insert(slot_offer_widgets, widget)
    table.insert(widgets, widget)
    ::continue::
  end

  self._offer_widget_names = offer_widget_names
end

function LoadoutConfigView:_on_loadout_button_pressed(loadout_widget)
  local content = loadout_widget.content
  local loadout_item_data = content.loadout_item_data
  local synchronizer_host = Managers.profile_synchronization:synchronizer_host()

  if synchronizer_host then
    local player = self:_player()
    local profile = table.clone_instance(self._profile)

    profile.loadout_item_data = table.merge(profile.loadout_item_data, loadout_item_data)
    synchronizer_host:override_singleplay_profile(Network.peer_id(), player:local_player_id(), profile)
  end

end

function LoadoutConfigView:_on_reset_button_pressed()
  self._reset_loadout = true
  self:_apply_custom_loadout()
end

function LoadoutConfigView:_on_offer_button_selected(item)
  if item then
    local weapon_template = WeaponTemplate.weapon_template_from_item(item)
    local template_base_stats = weapon_template and weapon_template.base_stats
    local base_stats = template_base_stats and {}

    if base_stats then
      for stat_name in pairs(template_base_stats) do
        table.insert(base_stats, {
          name = stat_name,
          value = (mod:get("default_base_stat_value") or 100) / 100
        })
      end
    end

    item.perks = {}
    item.traits = {}
    item.base_stats = base_stats

    local selected_card = self._selected_card
    selected_card.content.cards[selected_card.content.index] = item

    self._loadout_list:clear_selection()
  end
end

function LoadoutConfigView:_on_slot_button_pressed(slot, index)
  self._loadout_cards:present_items(slot, self, "_on_offer_button_selected")
  self._selected_card.content.index = index
end

function LoadoutConfigView:_load_selected_item_icon()
  local selected_card = self._selected_card

  local icon_load_id = selected_card.content.icon_load_id
  if icon_load_id then
    Managers.ui:unload_item_icon(icon_load_id)
  end

  local cb = callback(self, "_on_item_icon_loaded", selected_card)
  local unload_cb = callback(self, "_on_item_icon_unloaded", selected_card)

  selected_card.content.icon_load_id = Managers.ui:load_item_icon(self._selected_item, cb, nil, nil, nil, unload_cb)
end

function LoadoutConfigView:_on_item_icon_unloaded(selected_card)
  local material_values = selected_card.style.icon.material_values

  material_values.use_placeholder_texture = 1
  material_values.use_render_target = 0
  material_values.rows = nil
  material_values.columns = nil
  material_values.render_target = nil
end

function LoadoutConfigView:_on_item_icon_loaded(selected_card, grid_index, rows, columns, render_target)

  local material_values = selected_card.style.icon.material_values

  material_values.use_placeholder_texture = 0
  material_values.use_render_target = 1
  material_values.rows = rows
  material_values.columns = columns
  material_values.grid_index = grid_index - 1
  material_values.render_target = render_target
end

function LoadoutConfigView:_has_perk(perk_item)
  local selected_item = self._selected_item
  local selected_perks = selected_item.perks

  for i, selected_perk in ipairs(selected_perks) do
    if selected_perk.id == perk_item.name and selected_perk.rarity == perk_item.rarity then
      return true, i
    end
  end

  return false
end

function LoadoutConfigView:_has_trait(trait_item)
  local selected_item = self._selected_item
  local selected_traits = selected_item.traits

  for i, selected_trait in ipairs(selected_traits) do
    if selected_trait.id == trait_item.name and selected_trait.rarity == trait_item.rarity then
      return true, i
    end
  end

  return false
end

function LoadoutConfigView:_on_trait_selected(widget, config)
  local selected_item = self._selected_item
  local selected_traits = selected_item.traits
  local trait_item = config.trait_item
  local max_traits = selected_item.item_type == ITEM_TYPES.GADGET and 1 or 2
  local has_trait, index = self:_has_trait(trait_item)

  if has_trait then
    table.remove(selected_traits, index)

    return
  end

  if not mod._enforce_override_restrictions or #selected_traits < max_traits then
    table.insert(selected_traits, {
      rarity = config.trait_item.rarity,
      id = config.trait_item.name,
      value = config.trait_item.value
    })
  end

  self._selected_trait_item = config.trait_item
end

function LoadoutConfigView:_update_trait_selection()
  if not self._trait_selection then
    return
  end

  local trait_category = ItemUtils.trait_category(self._selected_item)

  if not trait_category then
    local innate_trait_items = self._innate_traits_list or table.filter(MasterItems.get_cached(), function(item)
      return string.find(item.name, "inate")
    end)

    local innate_traits_list = {}
    for trait_name, trait_item in pairs(innate_trait_items) do
      innate_traits_list[trait_name] = {
        "seen",
        "seen",
        "seen",
        "seen"
      }
    end

    self._trait_selection:present_inventory(innate_traits_list, {
      item = self._selected_item,
      trait_ids = self._selected_item.traits or {}
    }, callback(self, "_on_trait_selected"))
    self._trait_selection:set_color_intensity_multiplier(1)
    self._trait_selection:_switch_to_rank_tab(4)

    self._innate_traits_list = innate_traits_list

    return
  end

  Managers.data_service.crafting:trait_sticker_book(trait_category):next(function(traits)
    self._traits_list = table.clone(traits)
    for trait_id, trait_data in pairs(traits) do
      for trait_rank, trait_status in ipairs(trait_data) do
        self._traits_list[trait_id][trait_rank] = "seen"
      end
    end

    self._trait_selection:present_inventory(self._traits_list, {
      item = self._selected_item,
      trait_ids = self._selected_item.traits or {}
    }, callback(self, "_on_trait_selected"))
    self._trait_selection:set_color_intensity_multiplier(1)
    self._trait_selection:_switch_to_rank_tab(4)
  end)
end

function LoadoutConfigView:_update_selected_item()
  local selected_card = self._selected_card
  local current_card_item = selected_card and selected_card.content.cards[selected_card.content.index]
  local selected_item = self._selected_item

  local base_stats = selected_item and selected_item.base_stats
  if base_stats then
    local widgets_by_name = self._widgets_by_name

    for i = 1, 5 do
      local widget_name = string.format("stat_slider_%s", i)
      local widget = widgets_by_name[widget_name]
      local content = widget.content
      local _, stat_data = table.find_by_key(base_stats, "name", content.stat_name)
      if stat_data then
        stat_data.value = content.value
      end
    end
  end

  if current_card_item and current_card_item ~= selected_item then
    current_card_item.traits = current_card_item.traits or {}
    current_card_item.perks = current_card_item.perks or {}

    --if not table.contains(current_card_item.slots, "slot_secondary") and current_card_item.item_type == ITEM_TYPES.WEAPON_MELEE then
    --  table.insert(current_card_item.slots, "slot_secondary")
    --end

    self._selected_item = current_card_item
    mod.last_selected_index = self._selected_card.content.index

    self:_load_selected_item_icon()
    self:_update_visible_offers()

    local slot = current_card_item.item_type
    if self._loadout_cards then
      self._loadout_cards:present_items(slot, self, "_on_offer_button_selected")
    end

    return true
  end
end

function LoadoutConfigView:_update_visible_offers()
  local selected_item = self._selected_item
  local selected_item_type = selected_item.item_type
  local selected_item_id = selected_item.name
  local offer_widget_names = self._offer_widget_names or {}
  local widgets_by_name = self._widgets_by_name

  for i, widget_name in ipairs(offer_widget_names) do
    local widget = widgets_by_name[widget_name]
    local content = widget.content
    content.visible = content.item_type == selected_item_type
    content.hotspot.is_selected = content.item_id == selected_item_id
  end
end

function LoadoutConfigView:_on_perk_selected(widget, config)
  local selected_item = self._selected_item
  local selected_perks = selected_item.perks
  local perk_item = config.perk_item
  local max_perks = selected_item.item_type == ITEM_TYPES.GADGET and 3 or 2
  local has_perk, index = self:_has_perk(perk_item)

  if has_perk then
    table.remove(selected_perks, index)

    return
  end

  if not mod._enforce_override_restrictions or #selected_perks < max_perks then
    table.insert(selected_perks, {
      rarity = perk_item.rarity,
      id = perk_item.name
    })
  end
end

function LoadoutConfigView:unlocked_present_perks(perk_view, ingredients, external_left_click_callback)
  if not ingredients.item then
		perk_view._active = true
		perk_view._disabled = false
	  perk_view._max_unlocked = nil
    mod:echo("Item not loaded correctly. This should never happen.")
		return Promise:resolved()
	end

	local item_masterid = ingredients.item.name
	local item_pattern = ingredients.item.parent_pattern

	perk_view._ingredients = ingredients
	perk_view._external_left_click_callback = external_left_click_callback

  perk_view._backend_promise = Managers.data_service.crafting:get_item_crafting_metadata(item_masterid)

  return perk_view._backend_promise:next(function (data)
    perk_view._perks_by_rank = data.perks

    
    local max_unlocked = RankSettings.max_perk_rank
    perk_view._max_unlocked = max_unlocked

    local widgets_by_name = perk_view._widgets_by_name

    for i = 1, RankSettings.max_perk_rank do
      local name = "rank_" .. i

      widgets_by_name[name].content.locked = max_unlocked < i
    end

    perk_view:_switch_to_rank_tab(max_unlocked, true)

    --[[
    if perk_view._do_animations then
      perk_view:start_animation()
    end
    ]]--
    
    perk_view._active = true
    perk_view._disabled = false
    perk_view._backend_promise = nil

    return max_unlocked
  end)
end

function LoadoutConfigView:_update_perk_selection()
  local perk_selection = self._perk_selection

  if not perk_selection then
    return
  end

  if not self._selected_item then
    mod:error("Item failed to be selected for some reason.")
    return 
  end

  local selected_item = self._selected_item
  local item_name = selected_item.name

  self:unlocked_present_perks(perk_selection, {
    item = selected_item
  }, callback(self, "_on_perk_selected"))
end

function LoadoutConfigView:_update_selected_slot()
  local widgets_by_name = self._widgets_by_name
  local selected_card = widgets_by_name.selected_card

  for i = 1, #slot_buttons_settings do
    local key = string.format("slot_button_%s", i)
    local widget = widgets_by_name[key]
    widget.content.hotspot.is_selected = widget.content.index == selected_card.content.index
  end
end

function LoadoutConfigView:_update_base_stats()
  local widgets_by_name = self._widgets_by_name
  local selected_item = self._selected_item
  local weapon_template = WeaponTemplate.weapon_template_from_item(selected_item)
  local base_stats = weapon_template and weapon_template.base_stats
  local has_base_stats = not not base_stats

  widgets_by_name.stat_slider_header.content.visible = has_base_stats
  widgets_by_name.stat_slider_background.content.visible = has_base_stats

  if not has_base_stats then
    for i = 1, 5 do
      local widget_name = string.format("stat_slider_%s", i)
      local widget = widgets_by_name[widget_name]
      local content = widget.content

      content.visible = false
    end

    return
  end

  local i = 1
  for stat_name, stat_data in pairs(base_stats) do
    local widget_name = string.format("stat_slider_%s", i)
    local widget = widgets_by_name[widget_name]
    local content = widget.content
    local _, existing_stat_data = table.find_by_key(selected_item.base_stats or {}, "name", stat_name)

    content.value = existing_stat_data and math.round_with_precision(existing_stat_data.value, 2) or 1
    content.stat_text = Localize(stat_data.display_name)
    content.stat_name = stat_name
    content.visible = selected_item.item_type ~= ITEM_TYPES.GADGET

    i = i + 1
  end
end

function LoadoutConfigView:update(dt, t, input_service)

  LoadoutConfigView.super.update(self, dt, t, input_service)

  local should_update_perks = self:_update_selected_item()
  if should_update_perks then
    self:_update_perk_selection()
    self:_update_trait_selection()
    self:_update_base_stats()
  end

  self:_update_selected_slot()
  self:_update_active_selections()

  if mod._is_debug_mode then
    self:_update_debug_menu()
  end
end

function LoadoutConfigView:_update_active_selections()
  local perk_selection = self._perk_selection
  local perk_widgets = perk_selection and perk_selection:widgets() or {}
  for _, perk_widget in ipairs(perk_widgets) do
    local config = perk_widget.content.config
    local perk_item = config.perk_item
    local has_perk = self:_has_perk(perk_item)

    perk_widget.content.is_wasteful = nil
    perk_widget.content.marked = has_perk
    perk_widget.content.hotspot.is_selected = has_perk
  end

  local trait_selection = self._trait_selection
  local trait_widgets = trait_selection and trait_selection:widgets() or {}
  for i, trait_widget in ipairs(trait_widgets) do
    local config = trait_widget.content.config
    local trait_item = config.trait_item
    local has_trait = self:_has_trait(trait_item)

    trait_widget.content.is_wasteful = nil
    trait_widget.content.marked = has_trait
    trait_widget.content.hotspot.is_selected = has_trait
  end
end

local function _format_string(key, val)
  return string.format("[%s]: %s", key, val)
end

local function _table_to_tree_node(t)
  if not t then
    return
  end

  for key, value in pairs(t) do
    if type(value) == "table" then
      if Imgui.tree_node(key) then

        if type(value) == "table" then
          _table_to_tree_node(value)
        else
          Imgui.text(_format_string(key, value))
        end

        Imgui.tree_pop()
      end
    else
      Imgui.text(_format_string(key, value))
    end
  end
end
function LoadoutConfigView:_update_debug_menu()
  local is_top_view = Managers.ui:active_top_view() == "loadout_config"

  if not is_top_view then
    return
  end

  if self._is_open then
    local _, is_closed = Imgui.begin_window("Loadout Config [debug]")
    Imgui.set_window_size(720, 480)
    if is_closed then
      self:_on_back_pressed()

      return
    end

    local local_player = Managers.player:local_player_safe(1)
    local profile = local_player:profile()

    _table_to_tree_node({ ["Profile"] = profile })
    Imgui.text("-----------------------------------")
    _table_to_tree_node({ ["Selected Item"] = self._selected_item })
    Imgui.text("-----------------------------------")
    _table_to_tree_node({ ["Available Items"] = self._offers })
    Imgui.text("-----------------------------------")
    _table_to_tree_node({ ["Saved Loadouts"] = self._loadout_list and self._loadout_list._saved_loadouts })

    Imgui.end_window()
  end
end

function LoadoutConfigView:_setup_input_legend()
  local input_legend_element = self:_add_element(ViewElementInputLegend, "input_legend", 10)
  local legend_inputs = self._definitions.legend_inputs

  for i = 1, #legend_inputs do
    local legend_input = legend_inputs[i]
    local on_pressed_callback = legend_input.on_pressed_callback
        and callback(self, legend_input.on_pressed_callback)

    input_legend_element:add_entry(
        legend_input.display_name,
        legend_input.input_action,
        legend_input.visibility_function,
        on_pressed_callback,
        legend_input.alignment
    )
  end

  self._input_legend_element = input_legend_element
end

function LoadoutConfigView:_on_back_pressed()
  Managers.ui:close_view(self.view_name)
end

function LoadoutConfigView:on_exit()
  self._is_open = false
  Imgui.close_imgui()

  self:_apply_custom_loadout()

  Managers.event:unregister(self, "event_player_profile_updated")
  LoadoutConfigView.super.on_exit(self)
end

function LoadoutConfigView:_pack_loadout_to_profile()
  local profile = self._profile

  if not profile then
    return
  end

  local loadout_item_ids = profile.loadout_item_ids
  local loadout_item_data = profile.loadout_item_data
  local selected_card = self._selected_card
  local items = selected_card and selected_card.content.cards

  if not items then
    return
  end

  for i = 1, #slot_buttons_settings do
    local item = items[i]

    if item then
      local item_name = item.name
      local item_perks = item.perks
      local item_traits = item.traits
      local num_perks = item_perks and #item_perks or 0
      local num_traits = item_traits and #item_traits or 0
      local item_rarity = math.min(num_perks + num_traits + 1, 5)
      local slot_settings = slot_buttons_settings[i]
      local slot_name = slot_settings.name
      local base_stats = item.base_stats

      loadout_item_ids[slot_name] = slot_name
      loadout_item_data[slot_name] = {
        id = item_name,
        overrides = {
          perks = item_perks,
          traits = item_traits,
          rarity = item_rarity,
          base_stats = base_stats
        }
      }
    end
  end

  loadout_item_data.custom = true

  return loadout_item_data
end

function LoadoutConfigView:_apply_custom_loadout()
  local player = Managers.player:local_player_safe(1)
  local synchronizer_host = Managers.profile_synchronization:synchronizer_host()

  if synchronizer_host then

    if self._reset_loadout then
      local local_player_id = 1
      local local_player = Managers.player:local_player_safe(local_player_id)
      local peer_id = local_player:peer_id()
      synchronizer_host:profile_changed(peer_id, local_player_id)

      self._reset_loadout = nil

      return
    end

    self:_pack_loadout_to_profile()
    local profile = self._profile

    synchronizer_host:override_singleplay_profile(Network.peer_id(), player:local_player_id(), profile)
  end
end

return LoadoutConfigView

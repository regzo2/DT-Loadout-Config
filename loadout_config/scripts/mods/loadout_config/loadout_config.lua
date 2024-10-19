local mod = get_mod("loadout_config")

local loadout_view_name = "loadout_config"
local loadout_config_view_path = "loadout_config/scripts/mods/loadout_config/views/loadout_config_view/loadout_config_view"

mod:add_require_path(loadout_config_view_path)

mod:register_view({
  view_name = loadout_view_name,
  view_settings = {
    init_view_function = function(ingame_ui_context)
      return true
    end,
    state_bound = true,
    display_name = "loc_eye_color_sienna_desc",
    path = loadout_config_view_path,
    package = "packages/ui/views/credits_goods_vendor_view/credits_goods_vendor_view",
    class = "LoadoutConfigView",
    load_in_hub = false,
    game_world_blur = 1,
    enter_sound_events = {
      "wwise/events/ui/play_ui_enter_short"
    },
    exit_sound_events = {
      "wwise/events/ui/play_ui_back_short"
    },
    wwise_states = {}
  },
  view_transitions = {},
  view_options = {
    close_all = false,
    close_previous = false,
    close_transition_time = nil,
    transition_time = nil
  }
})

function mod.open_view()
  local ui_manager = Managers.ui

  if not ui_manager:has_active_view()
      and not ui_manager:chat_using_input()
      and not ui_manager:view_instance(loadout_view_name)
  then
    if not Managers.profile_synchronization:synchronizer_host() then
      mod:notify(mod:localize("error_only_open_as_host"))

      return
    end

    ui_manager:open_view(loadout_view_name)
  elseif ui_manager:view_instance(loadout_view_name) then
    ui_manager:close_view(loadout_view_name)
  end
end

mod:command("loadout_config", "", mod.open_view)
mod:command("lc", mod:localize("mod_name"), mod.open_view)

mod:hook(CLASS.PackageSynchronizerHost, "_item_instance_altered", function(func, ...)
  return true
end)

mod:hook(CLASS.ViewElementProfilePresets, "cb_add_new_profile_preset", function(func, self)
  local player = Managers.player:local_player(1)
  local profile = player and player:profile()
  local loadout_item_data = profile and profile.loadout_item_data
  local is_custom = loadout_item_data and loadout_item_data.custom

  if is_custom then
    mod:notify(mod:localize("error_no_preset_with_modded_loadout"))
    return
  end

  return func(self)
end)
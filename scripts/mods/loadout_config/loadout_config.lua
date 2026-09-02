local mod = get_mod("loadout_config")

local MatchmakingConstants = require("scripts/settings/network/matchmaking_constants")
local HOST_TYPES = MatchmakingConstants.HOST_TYPES

mod.on_setting_changed = function()
  mod._enforce_override_restrictions = mod:get("enforce_override_restrictions")
  mod._enforce_class_restrictions = mod:get("enforce_class_restrictions")
  mod._enforce_trait_restrictions = mod:get("enforce_trait_restrictions")
  mod._is_debug_mode = mod:get("debug_mode")
  mod._allow_clients_loadout = mod:get("allow_clients_loadout")
  mod._weapon_naming_convention = mod:get("weapon_naming_convention")
  mod._loadout_layout_config = mod:get("loadout_menu_layout")
end

mod.on_setting_changed()

local _check_and_hook_realms = function()
  local realms = get_mod("Realms")
  if not realms then return end

  local sync_registered, sync_err = realms.network_register(mod, "rpc_loadout_config_sync_profile", function(sender_peer_id, loadout_item_data)
    if not mod._allow_clients_loadout then return end

    mod:echo("[Loadout Config]: Syncing profile from Peer: " .. tostring(sender_peer_id))
    
    local synchronizer_host = Managers.profile_synchronization:synchronizer_host()
    if not synchronizer_host then return end

    local sender_player = Managers.player and Managers.player:player(sender_peer_id, 1)
    if not sender_player then return end

    local profile = sender_player:profile()
    if not profile or not loadout_item_data then return end

    local local_peer_id = sender_player:peer_id()
    local new_profile = table.clone_instance(profile)

    new_profile.loadout_item_data = table.clone(loadout_item_data)

    synchronizer_host:override_singleplay_profile(local_peer_id, 1, new_profile)
    --synchronizer_host:profile_changed(local_peer_id, 1)
  end)

  if not sync_registered then
    mod:echo("[Loadout Config ERROR]: Failed to register sync RPC: " .. tostring(sync_err))
  else
    mod:echo("[Loadout Config]: Sync RPC registered successfully.")
  end

  -- 2. Reset Profile RPC
  local reset_registered, reset_err = realms.network_register(mod, "rpc_loadout_config_reset_profile", function(sender_peer_id, local_player_id)
    mod:notify("[Loadout Config]: Profile reset received from Peer: " .. tostring(sender_peer_id))
    
    local synchronizer_host = Managers.profile_synchronization:synchronizer_host()
    if synchronizer_host then
      local valid_player_id = type(local_player_id) == "number" and local_player_id or 1
      synchronizer_host:profile_changed(sender_peer_id, valid_player_id)
      mod:echo("[Loadout Config]: Successfully reset profile for Peer: " .. tostring(sender_peer_id))
    end
  end)

  if not reset_registered then
    mod:echo("[Loadout Config ERROR]: Failed to register reset RPC: " .. tostring(reset_err))
  end
end

mod.on_all_mods_loaded = function()
  _check_and_hook_realms()
end

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

local function is_player_hosted_session()
	local multiplayer_session = Managers.multiplayer_session

	return multiplayer_session
		     and multiplayer_session:host_type() == HOST_TYPES.player
		     or false
end

local function is_singleplayer_session()
	local multiplayer_session = Managers.multiplayer_session

	return multiplayer_session
		     and multiplayer_session:host_type() == HOST_TYPES.singleplay
		     or false
end

function mod.open_view()
  local ui_manager = Managers.ui

  if not ui_manager:has_active_view()
     and not ui_manager:chat_using_input()
     and not ui_manager:view_instance(loadout_view_name)
  then
    local synchronizer_host = Managers.profile_synchronization:synchronizer_host()

    if not (synchronizer_host or is_player_hosted_session() or is_singleplayer_session()) then
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
mod:command("lc_test_realms_sync_profile", "Simulate receiving a custom profile RPC from a client", function()
  local player = Managers.player:local_player_safe(1)
  if not player then 
    mod:echo("[Test] Must be in a game session to test.")
    return 
  end

  local local_peer_id = player:peer_id()
  
  local mock_profile = player:profile()

  mod:echo("[Test] Simulating Client sending RPC to Host...")

  local realms = get_mod("Realms")
  if realms and realms.network_is_available() then
    realms.network_send(mod, "rpc_loadout_config_sync_profile", "host", mock_profile.loadout_item_data)
  else
    mod:echo("[Test] Realms network is not available right now.")
  end
end)
mod:command("lc_test_realms_reset_profile", "Simulate receiving a custom profile RPC from a client", function()
  mod:echo("[Test] Simulating Client sending RPC to Host...")

  local realms = get_mod("Realms")
  if realms and realms.network_is_available() then
    realms.network_send(mod, "rpc_loadout_config_reset_profile", "host")
  else
    mod:echo("[Test] Realms network is not available right now.")
  end
end)

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
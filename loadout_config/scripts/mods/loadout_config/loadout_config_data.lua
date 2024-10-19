local mod = get_mod("loadout_config")

return {
	name = mod:localize("mod_name"),
	description = mod:localize("mod_description"),
	is_togglable = true,
	options = {
		widgets = {
			{
				setting_id = "open_view_bind",
				type = "keybind",
				default_value = {},
				keybind_trigger = "pressed",
				keybind_type = "function_call",
				function_name = "open_view"
			},
			{
				setting_id = "enforce_override_restrictions",
				type = "checkbox",
				default_value = true
			},
			{
				setting_id = "default_base_stat_value",
				type = "numeric",
				range = { 1, 100 },
				default_value = 80,
				decimals_number = 0,
				step_size_value = 1
			},
			{
				setting_id = "debug_mode",
				type = "checkbox",
				default_value = false
			},
		}
	}
}

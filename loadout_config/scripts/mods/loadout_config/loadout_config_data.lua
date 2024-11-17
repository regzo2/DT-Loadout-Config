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
				setting_id = "enforce_class_restrictions",
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
				setting_id = "weapon_naming_convention",
				type = "dropdown",
				default_value = "modern",
				options = {
					{ text = "weapon_name_simple", value = "simple" },
					{ text = "weapon_name_modern", value = "modern" },
					{ text = "weapon_name_classic", value = "classic" },
				},
			},
			{
				setting_id = "loadout_menu_layout",
				type = "dropdown",
				default_value = "2",
				options = {
					{ text = "loadout_menu_remixed", value = "2", show_widgets = { 1 }},
					{ text = "loadout_menu_classic", value = "1", show_widgets = { }},
				},
				sub_widgets = {
					{
						setting_id = "remixed_stat_button_size",
						type = "numeric",
						range = { 5, 10 },
						default_value = 6,
						decimals_number = 0,
						step_size_value = 1
					},
				}
			},
			{
				setting_id = "debug_mode",
				type = "checkbox",
				default_value = false
			},
		}
	}
}

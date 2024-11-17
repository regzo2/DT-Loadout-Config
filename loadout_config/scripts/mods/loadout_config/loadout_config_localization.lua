return {
	mod_name = {
		en = "Loadout Config",
		["zh-cn"] = "自定义配装",
	},
	mod_description = {
		en = "Configure weapon stats, blessings, and perks",
		["zh-cn"] = "配置武器数据、祝福和专长",
	},
	open_view_bind = {
		en = "Open View",
		["zh-cn"] = "打开界面",
	},
	debug_mode = {
		en = "Enable Debug Window",
		["zh-cn"] = "启用调试窗口",
	},
	enforce_override_restrictions = {
		en = "Enforce Override Restrictions",
		["zh-cn"] = "强制启用覆盖限制",
	},
	enforce_override_restrictions_description = {
		en = "Prevents adding more Perks, Blessings, or Traits to an item than would regularly be allowed.",
		["zh-cn"] = "禁止向物品添加超出常规限制的专长、祝福或属性。",
	},
	enforce_class_restrictions = {
		en = "Enforce Class Restrictions",
	},
	enforce_class_restrictions_description = {
		en = "Prevents classes from having access to weapons in the weapons list that they are not allowed to use." ..
			 "\n\n[NOTE] \nOgryn weapons will still be disabled on human classes to prevent crashes.",
	},
	loadouts_header = {
		en = "Loadouts",
		["zh-cn"] = "配装",
	},
	default_base_stat_value = {
		en = "Default Weapon Modifier Value",
		["zh-cn"] = "默认武器修正值",
	},

	weapon_naming_convention = {
		en = "Weapon Naming Style",
	},
	weapon_naming_convention_description = {
		en = "Configures naming style for the selected weapon." .. 
			 "\n\n[Simple] \nShows weapon pattern and mark only." .. 
			 "\n\n[Modern] \nShows weapon pattern, family, and mark (Unlocked and Loaded)." .. 
			 "\n\n[Classic] \nShows weapon pattern, family, and mark (pre-Unlocked and Loaded).",
	},
	weapon_name_classic = {
		en = "Classic",
	},
	weapon_name_modern = {
		en = "Modern",
	},
	weapon_name_simple = {
		en = "Simple",
	},

	loadout_menu_layout = {
		en = "Menu Layout",
	},
	loadout_menu_layout_description = {
		en = "Configures layout for the config menu." .. 
			 "\n\n[Remixed] \nOrganizes weapon selection cards by mark and moves selected weapon and stats to the side." .. 
			 "\n\n[Classic] \nOriginal layout; Weapon selection cards are tiled and selected weapon and stats are below the selection cards.",
	},
	loadout_menu_remixed = {
		en = "Remixed",
	},
	loadout_menu_classic = {
		en = "Classic",
	},

	remixed_stat_button_size = {
		en = "Weapon Stat Adjuster Size",
	},

	error_no_preset_with_modded_loadout = {
		en = "Cannot create base game presets with modded loadouts\nUse loadout system provided by Loadout Config",
	},
	error_only_open_as_host = {
		en = "Loadout Config can only be opened in the Psykhanium or during a SoloPlay-enabled game.",
	}
}

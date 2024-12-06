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
		["zh-cn"] = "强制启用职业限制",
	},
	enforce_class_restrictions_description = {
		en = "Prevents classes from having access to weapons in the weapons list that they are not allowed to use." ..
			 "\n\n[NOTE] \nOgryn weapons will still be disabled on human classes to prevent crashes.",
		["zh-cn"] = "禁止在武器列表中获取当前职业不能使用的武器。" ..
			"\n\n[注意] \n为避免崩溃，人类职业始终无法使用欧格林武器。",
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
		["zh-cn"] = "武器命名风格",
	},
	weapon_naming_convention_description = {
		en = "Configures naming style for the selected weapon." .. 
			 "\n\n[Simple] \nShows weapon pattern and mark only." .. 
			 "\n\n[Modern] \nShows weapon pattern, family, and mark (Unlocked and Loaded)." .. 
			 "\n\n[Classic] \nShows weapon pattern, family, and mark (pre-Unlocked and Loaded).",
		["zh-cn"] = "配置选择武器的命名风格。" .. 
			 "\n\n[简洁] \n只显示武器类型和型号。" .. 
			 "\n\n[现代] \n显示武器类型、家族和型号（锻造更新后）。" .. 
			 "\n\n[经典] \n显示武器类型、家族和型号（锻造更新前）。",
	},
	weapon_name_classic = {
		en = "Classic",
		["zh-cn"] = "经典",
	},
	weapon_name_modern = {
		en = "Modern",
		["zh-cn"] = "现代",
	},
	weapon_name_simple = {
		en = "Simple",
		["zh-cn"] = "简洁",
	},

	loadout_menu_layout = {
		en = "Menu Layout",
		["zh-cn"] = "菜单布局",
	},
	loadout_menu_layout_description = {
		en = "Configures layout for the config menu." .. 
			 "\n\n[Remixed] \nOrganizes weapon selection cards by mark and moves selected weapon and stats to the side." .. 
			 "\n\n[Classic] \nOriginal layout; Weapon selection cards are tiled and selected weapon and stats are below the selection cards.",
		["zh-cn"] = "配置菜单布局。" .. 
			 "\n\n[重制] \n按型号排列武器选择卡片，将所选武器和数据放到侧边。" .. 
			 "\n\n[经典] \n旧版布局；平铺武器选择卡片，所选武器和数据在武器选择卡片下方。",
	},
	loadout_menu_remixed = {
		en = "Remixed",
		["zh-cn"] = "重制",
	},
	loadout_menu_classic = {
		en = "Classic",
		["zh-cn"] = "经典",
	},

	remixed_stat_button_size = {
		en = "Weapon Stat Adjuster Size",
		["zh-cn"] = "武器数据调节器大小",
	},

	error_no_preset_with_modded_loadout = {
		en = "Cannot create base game presets with modded loadouts\nUse loadout system provided by Loadout Config",
		["zh-cn"] = "无法使用模组配装创建游戏本体配装\n请使用“自定义配装”模组提供的配装系统",
	},
	error_only_open_as_host = {
		en = "Loadout Config can only be opened in the Psykhanium or during a SoloPlay-enabled game.",
		["zh-cn"] = "自定义配装仅能在灵能室或模组单人游戏内打开。",
	}
}

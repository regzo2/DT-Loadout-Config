return {
	run = function()
		fassert(rawget(_G, "new_mod"), "`loadout_config` encountered an error loading the Darktide Mod Framework.")

		new_mod("loadout_config", {
			mod_script       = "loadout_config/scripts/mods/loadout_config/loadout_config",
			mod_data         = "loadout_config/scripts/mods/loadout_config/loadout_config_data",
			mod_localization = "loadout_config/scripts/mods/loadout_config/loadout_config_localization",
		})
	end,
	packages = {},
}

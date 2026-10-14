// ERP gating for the ported genital system.
//
// A server config flag disables it wholesale, a per-player master toggle gates the
// per-character "allow genitals" toggle, and everything is hidden when disabled.
//
// PORTED FROM: Bubberstation modular_skyrat/master_files/code/modules/client/preferences/erp_preferences.dm

/datum/config_entry/flag/disable_erp_preferences
	default = FALSE

/datum/preference/toggle/master_erp_preferences
	category = PREFERENCE_CATEGORY_GAME_PREFERENCES
	savefile_key = "master_erp_pref"
	savefile_identifier = PREFERENCE_PLAYER
	default_value = FALSE

/datum/preference/toggle/master_erp_preferences/is_accessible(datum/preferences/preferences)
	if(!..(preferences))
		return FALSE
	return !CONFIG_GET(flag/disable_erp_preferences)

/datum/preference/toggle/master_erp_preferences/deserialize(input, datum/preferences/preferences)
	if(CONFIG_GET(flag/disable_erp_preferences))
		return FALSE
	return ..()

/datum/preference/toggle/allow_genitals
	category = PREFERENCE_CATEGORY_SECONDARY_FEATURES
	savefile_key = "allow_genitals_toggle"
	savefile_identifier = PREFERENCE_CHARACTER
	default_value = TRUE
	can_randomize = FALSE

/// Store the toggle in DNA so the organd/overlay visibility can read it without a client
/// (previews and re-renders have no client to read the preference from).
/datum/preference/toggle/allow_genitals/apply_to_human(mob/living/carbon/human/target, value)
	target.dna.features["allow_genitals"] = value

/datum/preference/toggle/allow_genitals/deserialize(input, datum/preferences/preferences)
	if(CONFIG_GET(flag/disable_erp_preferences))
		return FALSE
	if(!preferences.read_preference(/datum/preference/toggle/master_erp_preferences))
		return FALSE
	return ..()

/datum/preference/toggle/allow_genitals/is_accessible(datum/preferences/preferences)
	if(!..(preferences))
		return FALSE
	if(CONFIG_GET(flag/disable_erp_preferences))
		return FALSE
	return preferences.read_preference(/datum/preference/toggle/master_erp_preferences)

/// Whether the given preferences should show genitals at all.
/proc/meta_genitals_enabled(datum/preferences/preferences)
	if(CONFIG_GET(flag/disable_erp_preferences))
		return FALSE
	if(isnull(preferences))
		return FALSE
	return preferences.read_preference(/datum/preference/toggle/master_erp_preferences) \
		&& preferences.read_preference(/datum/preference/toggle/allow_genitals)

// Preferences for the ported LOOC feature.
//
// PORTED FROM: Bubberstation modular_skyrat/master_files/code/modules/client/preferences/looc.dm

/// Show LOOC as overhead runechat bubbles as well as in the chat log.
/datum/preference/toggle/enable_looc_runechat
	category = PREFERENCE_CATEGORY_GAME_PREFERENCES
	default_value = FALSE
	savefile_key = "enable_looc_runechat"
	savefile_identifier = PREFERENCE_PLAYER

/// Admins only: also receive LOOC from beyond their normal earshot, prefixed "(R)LOOC".
/datum/preference/toggle/see_looc
	category = PREFERENCE_CATEGORY_GAME_PREFERENCES
	default_value = TRUE
	savefile_key = "looc_admin_pref"
	savefile_identifier = PREFERENCE_PLAYER

/datum/preference/toggle/see_looc/is_accessible(datum/preferences/preferences)
	if(!..(preferences))
		return FALSE
	return is_admin(preferences.parent)

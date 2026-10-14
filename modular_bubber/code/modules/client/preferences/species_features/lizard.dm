// Default values for the lizard feature preferences.
//
// With `allow_mismatched_parts` on these preferences are visible for every species, so
// they default to None rather than giving a fresh human a random snout, horns, frills or
// spines. Species that want them, like lizard, set their own defaults.
//
// PORTED FROM: Bubberstation modular_skyrat customization preferences.

/datum/preference/choiced/lizard_snout/create_default_value()
	return SPRITE_ACCESSORY_NONE

/datum/preference/choiced/lizard_horns/create_default_value()
	return SPRITE_ACCESSORY_NONE

/datum/preference/choiced/lizard_frills/create_default_value()
	return SPRITE_ACCESSORY_NONE

/datum/preference/choiced/lizard_spines/create_default_value()
	return SPRITE_ACCESSORY_NONE

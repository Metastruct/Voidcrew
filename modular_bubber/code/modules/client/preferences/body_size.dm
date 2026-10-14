// Body size and height preferences, ported from Bubber.
//
// Voidcrew already has update_transform() for the overall scale and set_mob_height() for
// the discrete height, but it shipped no character preference for either, so imported
// Bubber sizes were dropped.
//
// PORTED FROM: Bubberstation modular_skyrat/master_files/.../preferences/body_size.dm
// and modular_zubbers/code/modules/customization/height_scaling/preferences.dm.

// --- Overall body scale ------------------------------------------------------

/datum/preference/numeric/body_size
	category = PREFERENCE_CATEGORY_SECONDARY_FEATURES
	savefile_identifier = PREFERENCE_CHARACTER
	savefile_key = "body_size"
	minimum = BODY_SIZE_MIN
	maximum = BODY_SIZE_MAX
	step = 0.01

/datum/preference/numeric/body_size/apply_to_human(mob/living/carbon/human/target, value)
	target.update_transform(value / target.current_size)

/datum/preference/numeric/body_size/create_default_value()
	return RESIZE_DEFAULT_SIZE

// --- Discrete height ---------------------------------------------------------

/datum/preference/choiced/height_scaling
	category = PREFERENCE_CATEGORY_SECONDARY_FEATURES
	savefile_identifier = PREFERENCE_CHARACTER
	savefile_key = "height_scaling"

	var/static/list/height_scaling_strings = list(
		"[HUMAN_HEIGHT_SHORTEST]" = "Shortest",
		"[HUMAN_HEIGHT_SHORT]" = "Short",
		"[HUMAN_HEIGHT_MEDIUM]" = "Medium",
		"[HUMAN_HEIGHT_TALL]" = "Tall",
		"[HUMAN_HEIGHT_TALLER]" = "Taller",
		"[HUMAN_HEIGHT_TALLEST]" = "Tallest",
	)

/datum/preference/choiced/height_scaling/init_possible_values()
	return list(
		HUMAN_HEIGHT_SHORTEST,
		HUMAN_HEIGHT_SHORT,
		HUMAN_HEIGHT_MEDIUM,
		HUMAN_HEIGHT_TALL,
		HUMAN_HEIGHT_TALLER,
		HUMAN_HEIGHT_TALLEST,
	)

/datum/preference/choiced/height_scaling/create_default_value()
	return HUMAN_HEIGHT_MEDIUM

/datum/preference/choiced/height_scaling/apply_to_human(mob/living/carbon/human/target, value)
	// Dwarfism and the spacer/settler quirks set their own height.
	if(HAS_TRAIT(target, TRAIT_DWARF))
		return
	target.set_mob_height(value)

/datum/preference/choiced/height_scaling/compile_constant_data()
	var/list/data = ..()
	data[CHOICED_PREFERENCE_DISPLAY_NAMES] = height_scaling_strings
	return data
// Species-feature preferences for the ported anthro parts.
//
// Snouts, horns, frills and spines reuse the upstream prefs because their organs keep
// the upstream `preference` savefile keys. Ears and the generic tail need their own
// because they use new organ types / a new feature key.
//
// PORTED FROM: modular_skyrat/modules/customization/.../client/preferences.dm and
// modular_skyrat/modules/customization/.../sprite_accessories/*.dm

// --- Ears --------------------------------------------------------------------

/datum/preference/choiced/bubber_ears
	savefile_key = "feature_bubber_ears"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_FEATURES
	main_feature_name = "Ears (Anthro)"
	should_generate_icons = TRUE
	can_randomize = FALSE
	relevant_external_organ = /obj/item/organ/ears/bubber

/datum/preference/choiced/bubber_ears/init_possible_values()
	return assoc_to_keys_features(SSaccessories.ears_list)

/datum/preference/choiced/bubber_ears/icon_for(value)
	// Crop to the head region (same as the core hair preview) so the ears fill the cell.
	return meta_part_pref_icon(SSaccessories.ears_list[value], FEATURE_EARS, crop = list(10, 19, 22, 31))

/datum/preference/choiced/bubber_ears/apply_to_human(mob/living/carbon/human/target, value)
	target.dna.features[FEATURE_EARS] = value

// Default to "None": mismatched parts makes this pref accessible for every species, and a
// fresh character should get nothing rather than a random part. Species set their own
// defaults (mammal -> Husky) on species gain.
/datum/preference/choiced/bubber_ears/create_default_value()
	return SPRITE_ACCESSORY_NONE

// --- Generic anthro tail -----------------------------------------------------

/datum/preference/choiced/bubber_tail
	savefile_key = "feature_bubber_tail"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_FEATURES
	main_feature_name = "Tail (Anthro)"
	should_generate_icons = TRUE
	can_randomize = FALSE
	relevant_external_organ = /obj/item/organ/tail/bubber

/datum/preference/choiced/bubber_tail/init_possible_values()
	return assoc_to_keys_features(SSaccessories.tails_list_bubber)

// Tail art is drawn on the BEHIND layer (with an empty same-named FRONT state), so prefer it.
// East (side) profile so the tail's shape reads clearly.
/datum/preference/choiced/bubber_tail/icon_for(value)
	return meta_part_pref_icon(SSaccessories.tails_list_bubber[value], FEATURE_TAIL_GENERIC, layer_order = list("BEHIND", "FRONT", "ADJ"), crop = list(0, 0, 24, 24), dir = EAST)

/datum/preference/choiced/bubber_tail/apply_to_human(mob/living/carbon/human/target, value)
	target.dna.features[FEATURE_TAIL_GENERIC] = value

/datum/preference/choiced/bubber_tail/create_default_value()
	return SPRITE_ACCESSORY_NONE

// --- Secondary / tertiary mutant colours -------------------------------------
// The matrixed-colour framework tints ported accessories with up to three colours.

/datum/preference/color/mutant_color_two
	savefile_key = "feature_mcolor_two"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_SUPPLEMENTAL_FEATURES
	relevant_inherent_trait = TRAIT_MUTANT_COLORS

/datum/preference/color/mutant_color_two/apply_to_human(mob/living/carbon/human/target, value)
	target.dna.features[FEATURE_MUTANT_COLOR_TWO] = value

/datum/preference/color/mutant_color_two/create_default_value()
	return "#[random_color()]"

/datum/preference/color/mutant_color_three
	savefile_key = "feature_mcolor_three"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_SUPPLEMENTAL_FEATURES
	relevant_inherent_trait = TRAIT_MUTANT_COLORS

/datum/preference/color/mutant_color_three/apply_to_human(mob/living/carbon/human/target, value)
	target.dna.features[FEATURE_MUTANT_COLOR_THREE] = value

/datum/preference/color/mutant_color_three/create_default_value()
	return "#[random_color()]"

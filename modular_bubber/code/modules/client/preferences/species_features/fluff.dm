// Neck fluff preference (Bubber's `feature_fluff`).
//
// PORTED FROM: Bubberstation modular_skyrat/modules/customization/.../sprite_accessories/fluff.dm
//              + modular_zubbers/.../sprite_accessories/fluff.dm

/datum/preference/choiced/fluff
	savefile_key = "feature_fluff"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_FEATURES
	main_feature_name = "Fluff"
	should_generate_icons = TRUE
	can_randomize = FALSE
	relevant_external_organ = /obj/item/organ/fluff

/datum/preference/choiced/fluff/init_possible_values()
	return assoc_to_keys_features(SSaccessories.fluff_list)

/datum/preference/choiced/fluff/icon_for(value)
	return port_part_pref_icon(SSaccessories.fluff_list[value], FEATURE_FLUFF, tint = null, crop = list(8, 11, 23, 26))

/datum/preference/choiced/fluff/apply_to_human(mob/living/carbon/human/target, value)
	target.dna.features[FEATURE_FLUFF] = value

/datum/preference/choiced/fluff/create_default_value()
	return SPRITE_ACCESSORY_NONE

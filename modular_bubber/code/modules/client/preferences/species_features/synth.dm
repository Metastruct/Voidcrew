// Synthetic (IPC) screen and antenna preferences.
//
// PORTED FROM: Bubberstation modular_skyrat/modules/synths/code/species/prefsmenu.dm

/datum/preference/choiced/synth_screen
	savefile_key = "feature_synth_screen"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_FEATURES
	main_feature_name = "Screen"
	should_generate_icons = TRUE
	can_randomize = FALSE
	relevant_external_organ = /obj/item/organ/synth_screen

/datum/preference/choiced/synth_screen/init_possible_values()
	return assoc_to_keys_features(SSaccessories.synth_screen_list)

/datum/preference/choiced/synth_screen/icon_for(value)
	return port_part_pref_icon(SSaccessories.synth_screen_list[value], FEATURE_SYNTH_SCREEN, tint = null, crop = list(11, 22, 21, 32))

/datum/preference/choiced/synth_screen/apply_to_human(mob/living/carbon/human/target, value)
	target.dna.features[FEATURE_SYNTH_SCREEN] = value

/datum/preference/choiced/synth_screen/create_default_value()
	return SPRITE_ACCESSORY_NONE

/datum/preference/choiced/synth_antenna
	savefile_key = "feature_synth_antenna"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_FEATURES
	main_feature_name = "Antenna"
	should_generate_icons = TRUE
	can_randomize = FALSE
	relevant_external_organ = /obj/item/organ/synth_antenna

/datum/preference/choiced/synth_antenna/init_possible_values()
	return assoc_to_keys_features(SSaccessories.synth_antenna_list)

/datum/preference/choiced/synth_antenna/icon_for(value)
	return port_part_pref_icon(SSaccessories.synth_antenna_list[value], FEATURE_SYNTH_ANTENNA, tint = null, crop = list(8, 17, 23, 32))

/datum/preference/choiced/synth_antenna/apply_to_human(mob/living/carbon/human/target, value)
	target.dna.features[FEATURE_SYNTH_ANTENNA] = value

/datum/preference/choiced/synth_antenna/create_default_value()
	return SPRITE_ACCESSORY_NONE

// --- Chassis / head bodypart art ---------------------------------------------
// These don't use an external organ: the species swaps the bodypart icons directly
// (`port_apply_synth_chassis`). Gated on the synth screen organ so only synths see them.

/datum/preference/choiced/synth_chassis
	savefile_key = "feature_synth_chassis"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_FEATURES
	main_feature_name = "Chassis"
	should_generate_icons = TRUE
	can_randomize = FALSE
	relevant_external_organ = /obj/item/organ/synth_screen

/datum/preference/choiced/synth_chassis/init_possible_values()
	return assoc_to_keys_features(SSaccessories.synth_chassis_list)

/datum/preference/choiced/synth_chassis/icon_for(value)
	var/datum/sprite_accessory/synth_chassis/chassis = SSaccessories.synth_chassis_list[value]
	if(isnull(chassis))
		return blank_pref_icon()
	return port_synth_part_pref_icon(chassis, BODY_ZONE_CHEST, chassis.dimorphic, crop = list(8, 8, 24, 24))

/datum/preference/choiced/synth_chassis/apply_to_human(mob/living/carbon/human/target, value)
	target.dna.features[FEATURE_SYNTH_CHASSIS] = value

/datum/preference/choiced/synth_chassis/create_default_value()
	return "Default Chassis"

/datum/preference/choiced/synth_head
	savefile_key = "feature_synth_head"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_FEATURES
	main_feature_name = "Head"
	should_generate_icons = TRUE
	can_randomize = FALSE
	relevant_external_organ = /obj/item/organ/synth_screen

/datum/preference/choiced/synth_head/init_possible_values()
	return assoc_to_keys_features(SSaccessories.synth_head_list)

/datum/preference/choiced/synth_head/icon_for(value)
	var/datum/sprite_accessory/synth_head/head = SSaccessories.synth_head_list[value]
	if(isnull(head))
		return blank_pref_icon()
	return port_synth_part_pref_icon(head, BODY_ZONE_HEAD, head.dimorphic, crop = list(11, 22, 21, 32))

/datum/preference/choiced/synth_head/apply_to_human(mob/living/carbon/human/target, value)
	target.dna.features[FEATURE_SYNTH_HEAD] = value

/datum/preference/choiced/synth_head/create_default_value()
	return "Default Head"

// Hidden single-colour tints for the chassis/head (Bubber's ipc_chassis_color/ipc_head_color).
/datum/preference/color/synth_chassis_color
	savefile_key = "synth_chassis_color"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_SECONDARY_FEATURES
	priority = PREFERENCE_PRIORITY_NAME_MODIFICATIONS

/datum/preference/color/synth_chassis_color/create_default_value()
	return DEFAULT_SYNTH_PART_COLOR

/datum/preference/color/synth_chassis_color/is_accessible(datum/preferences/preferences)
	return FALSE

/datum/preference/color/synth_chassis_color/apply_to_human(mob/living/carbon/human/target, value)
	if(istext(value) && length(value))
		target.dna.features["synth_chassis_color"] = value

/datum/preference/color/synth_head_color
	savefile_key = "synth_head_color"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_SECONDARY_FEATURES
	priority = PREFERENCE_PRIORITY_NAME_MODIFICATIONS

/datum/preference/color/synth_head_color/create_default_value()
	return DEFAULT_SYNTH_PART_COLOR

/datum/preference/color/synth_head_color/is_accessible(datum/preferences/preferences)
	return FALSE

/datum/preference/color/synth_head_color/apply_to_human(mob/living/carbon/human/target, value)
	if(istext(value) && length(value))
		target.dna.features["synth_head_color"] = value

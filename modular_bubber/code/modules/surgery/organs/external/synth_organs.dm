// Synthetic (IPC) screen and antenna external organs, ported from Bubber.
//
// Both are head overlays: the screen renders on the FRONT layer (its art was renamed
// from `_FRONT_UNDER` to `_FRONT` by .pi/modular_bubber/tools/dmi_rename.py) and the antenna on ADJACENT.
//
// PORTED FROM: Bubberstation modular_skyrat synth_screen.dm / synth_antenna.dm.

/datum/bodypart_overlay/mutant/synth_screen
	layers = EXTERNAL_FRONT
	feature_key = FEATURE_SYNTH_SCREEN

/datum/bodypart_overlay/mutant/synth_screen/get_global_feature_list()
	return SSaccessories.synth_screen_list

/obj/item/organ/synth_screen
	name = "synth screen"
	desc = "A retro-projected face display for a synthetic."
	zone = BODY_ZONE_HEAD
	slot = ORGAN_SLOT_EXTERNAL_SYNTH_SCREEN
	preference = "feature_synth_screen"
	bodypart_overlay = /datum/bodypart_overlay/mutant/synth_screen
	dna_block = null // appearance is preference-driven
	organ_flags = parent_type::organ_flags | ORGAN_EXTERNAL

/datum/bodypart_overlay/mutant/synth_antenna
	layers = EXTERNAL_ADJACENT
	feature_key = FEATURE_SYNTH_ANTENNA
	color_source = ORGAN_COLOR_INHERIT
	dyable = TRUE

/datum/bodypart_overlay/mutant/synth_antenna/get_global_feature_list()
	return SSaccessories.synth_antenna_list

/obj/item/organ/synth_antenna
	name = "synth antenna"
	desc = "A synthetic's antenna. It twitches occasionally."
	zone = BODY_ZONE_HEAD
	slot = ORGAN_SLOT_EXTERNAL_SYNTH_ANTENNA
	preference = "feature_synth_antenna"
	bodypart_overlay = /datum/bodypart_overlay/mutant/synth_antenna
	dna_block = null
	organ_flags = parent_type::organ_flags | ORGAN_EXTERNAL

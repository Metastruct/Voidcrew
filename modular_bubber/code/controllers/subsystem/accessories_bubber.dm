// Adds ported accessory lists to Voidcrew's sprite-accessory subsystem.
//
// Voidcrew builds each feature's list in SSaccessories::setup_lists(), which we
// cannot override cleanly (there is no parent implementation to call with `..()`),
// so core calls this proc via a tagged PORT EDIT hook at the end of setup_lists().

/datum/controller/subsystem/accessories
	/// Generic anthro tails ported from Bubber, drawn with feature_key "tail".
	var/list/tails_list_bubber
	/// Ported synth (IPC) screens and antennas.
	var/list/synth_screen_list
	var/list/synth_antenna_list
	/// Ported synth (IPC) chassis/head bodypart art sets.
	var/list/synth_chassis_list
	var/list/synth_head_list
	/// Ported moth/anthro neck fluff.
	var/list/fluff_list
	/// Ported genital sprite-accessory lists.
	var/list/genital_penis_list
	var/list/genital_testicles_list
	var/list/genital_vagina_list
	var/list/genital_womb_list
	var/list/genital_anus_list
	var/list/genital_breasts_list
	var/list/genital_butt_list
	var/list/genital_belly_list

/datum/controller/subsystem/accessories/proc/setup_ported_lists()
	// Bubber's mammal tail branch (modular_skyrat).
	tails_list_bubber = init_sprite_accessory_subtypes(
		/datum/sprite_accessory/tails/bubber/mammal,
		add_blank = TRUE,
	)["default_sprites"]
	// Bubber's newer modular_zubbers tails live under /tails/mammal.
	tails_list_bubber |= init_sprite_accessory_subtypes(
		/datum/sprite_accessory/tails/mammal,
	)["default_sprites"]
	// Zubbers' synthliz tail hangs directly off /tails (not /tails/mammal) and is a
	// single leaf entry, so `subtypesof()` alone won't pick it up.
	var/datum/sprite_accessory/synthliz_tail = new /datum/sprite_accessory/tails/synthliz
	tails_list_bubber[synthliz_tail.name] = synthliz_tail
	// Synth (IPC) screens and antennas.
	synth_screen_list = init_sprite_accessory_subtypes(/datum/sprite_accessory/screen, add_blank = TRUE)["default_sprites"]
	synth_antenna_list = init_sprite_accessory_subtypes(/datum/sprite_accessory/antenna, add_blank = TRUE)["default_sprites"]
	// Synth chassis/head art sets (always present, so no "None").
	synth_chassis_list = init_sprite_accessory_subtypes(/datum/sprite_accessory/synth_chassis)["default_sprites"]
	synth_head_list = init_sprite_accessory_subtypes(/datum/sprite_accessory/synth_head)["default_sprites"]
	// Ported neck fluff (Bubber's `/datum/sprite_accessory/fluff`).
	fluff_list = init_sprite_accessory_subtypes(/datum/sprite_accessory/fluff, add_blank = TRUE)["default_sprites"]
	// Genitals (each set defines its own "None" entry, so no add_blank).
	genital_penis_list = init_sprite_accessory_subtypes(/datum/sprite_accessory/genital/penis)["default_sprites"]
	genital_testicles_list = init_sprite_accessory_subtypes(/datum/sprite_accessory/genital/testicles)["default_sprites"]
	genital_vagina_list = init_sprite_accessory_subtypes(/datum/sprite_accessory/genital/vagina)["default_sprites"]
	genital_womb_list = init_sprite_accessory_subtypes(/datum/sprite_accessory/genital/womb)["default_sprites"]
	genital_anus_list = init_sprite_accessory_subtypes(/datum/sprite_accessory/genital/anus)["default_sprites"]
	genital_breasts_list = init_sprite_accessory_subtypes(/datum/sprite_accessory/genital/breasts)["default_sprites"]
	genital_butt_list = init_sprite_accessory_subtypes(/datum/sprite_accessory/genital/butt)["default_sprites"]
	genital_belly_list = init_sprite_accessory_subtypes(/datum/sprite_accessory/genital/belly)["default_sprites"]
	// The core pod-hair list ships without a "None"; add one so podpeople can be bald.
	if(islist(SSaccessories.pod_hair_list) && !SSaccessories.pod_hair_list[SPRITE_ACCESSORY_NONE])
		SSaccessories.pod_hair_list[SPRITE_ACCESSORY_NONE] = new /datum/sprite_accessory/blank
	// The snout list ships without a "None" too, so a lizard/species can't choose "no snout"
	// and our default-to-None would fail validation. Add one.
	if(islist(SSaccessories.snouts_list) && !SSaccessories.snouts_list[SPRITE_ACCESSORY_NONE])
		SSaccessories.snouts_list[SPRITE_ACCESSORY_NONE] = new /datum/sprite_accessory/blank
	// Moth wings ship without a "None", so once "allow mismatched parts" granted the wing
	// organ there was no way to pick no wings. Add one (generic wings already have one).
	if(islist(SSaccessories.moth_wings_list) && !SSaccessories.moth_wings_list[SPRITE_ACCESSORY_NONE])
		SSaccessories.moth_wings_list[SPRITE_ACCESSORY_NONE] = new /datum/sprite_accessory/blank

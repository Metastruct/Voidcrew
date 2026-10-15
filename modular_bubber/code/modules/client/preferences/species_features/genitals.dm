// Genital preferences ported from Bubberstation.
//
// Savefile keys match Bubber's so imported characters line up. The choiced prefs write
// the sprite name into dna.features[slot]; the scalars (size/girth/sheath/skin toggles)
// write the values the genital organs read in sync_from_dna(). Per-genital three-tone
// colours and emissives are handled by the shared part_colors framework, not here.
//
// PORTED FROM: Bubberstation modular_skyrat/master_files/code/modules/client/preferences/genitals.dm

/// The sprite-accessory list backing a genital slot.
/proc/port_genital_feature_list(slot)
	switch(slot)
		if(ORGAN_SLOT_PENIS)
			return SSaccessories.genital_penis_list
		if(ORGAN_SLOT_TESTICLES)
			return SSaccessories.genital_testicles_list
		if(ORGAN_SLOT_VAGINA)
			return SSaccessories.genital_vagina_list
		if(ORGAN_SLOT_WOMB)
			return SSaccessories.genital_womb_list
		if(ORGAN_SLOT_ANUS)
			return SSaccessories.genital_anus_list
		if(ORGAN_SLOT_BREASTS)
			return SSaccessories.genital_breasts_list
		if(ORGAN_SLOT_BUTT)
			return SSaccessories.genital_butt_list
		if(ORGAN_SLOT_BELLY)
			return SSaccessories.genital_belly_list
	CRASH("port_genital_feature_list() called with unknown slot [slot]")

GLOBAL_LIST_INIT(breast_size_translation, list(
	"0" = BREAST_SIZE_FLATCHESTED, "1" = BREAST_SIZE_A, "2" = BREAST_SIZE_B,
	"3" = BREAST_SIZE_C, "4" = BREAST_SIZE_D, "5" = BREAST_SIZE_E,
	"6" = BREAST_SIZE_F, "7" = BREAST_SIZE_G, "8" = BREAST_SIZE_H,
	"9" = BREAST_SIZE_I, "10" = BREAST_SIZE_J, "11" = BREAST_SIZE_K,
	"12" = BREAST_SIZE_L, "13" = BREAST_SIZE_M, "14" = BREAST_SIZE_N,
	"15" = BREAST_SIZE_O, "16" = BREAST_SIZE_P, "17" = BREAST_SIZE_Q,
	"18" = BREAST_SIZE_R, "19" = BREAST_SIZE_S,
))

GLOBAL_LIST_INIT(breast_size_to_number, list(
	BREAST_SIZE_FLATCHESTED = 0, BREAST_SIZE_A = 1, BREAST_SIZE_B = 2,
	BREAST_SIZE_C = 3, BREAST_SIZE_D = 4, BREAST_SIZE_E = 5,
	BREAST_SIZE_F = 6, BREAST_SIZE_G = 7, BREAST_SIZE_H = 8,
	BREAST_SIZE_I = 9, BREAST_SIZE_J = 10, BREAST_SIZE_K = 11,
	BREAST_SIZE_L = 12, BREAST_SIZE_M = 13, BREAST_SIZE_N = 14,
	BREAST_SIZE_O = 15, BREAST_SIZE_P = 16, BREAST_SIZE_Q = 17,
	BREAST_SIZE_R = 18, BREAST_SIZE_S = 19,
))

/// Every genital organ, granted per-mob when the player has genitals enabled.
/// Order matters: overlays on the same limb draw in insertion order, so the belly is
/// granted before the breasts to keep the chest on top of it (Bubber's belly layer sits
/// below the chest one).
GLOBAL_LIST_INIT(port_genital_organs, list(
	/obj/item/organ/genital/penis,
	/obj/item/organ/genital/testicles,
	/obj/item/organ/genital/vagina,
	/obj/item/organ/genital/womb,
	/obj/item/organ/genital/anus,
	/obj/item/organ/genital/butt,
	/obj/item/organ/genital/belly,
	/obj/item/organ/genital/breasts,
))

/// Bring a human's genital organs in line with their DNA: add organs whose sprite is set,
/// re-sync organs whose size/shape changed, and remove organs set to "None".
///
/// Called from on_species_gain() after organ regeneration and from apply_prefs_to(), so
/// the character-setup preview updates live (not just on spawn). Blocked only by the
/// server config; per-character visibility is handled by the organ's `allow_genitals`
/// check, so previews and NPCs that lack a client still get the organs.
/proc/port_sync_genital_organs(mob/living/carbon/human/human)
	if(!ishuman(human))
		return
	if(CONFIG_GET(flag/disable_erp_preferences))
		return

	for(var/obj/item/organ/organ_type as anything in GLOB.port_genital_organs)
		var/datum/bodypart_overlay/mutant/sample_overlay = initial(organ_type.bodypart_overlay)
		if(isnull(sample_overlay))
			continue
		var/feature_key = initial(sample_overlay.feature_key)
		var/feature_value = feature_key ? human.dna.features[feature_key] : null
		var/obj/item/organ/genital/existing = human.get_organ_by_type(organ_type)

		if(isnull(feature_value) || feature_value == SPRITE_ACCESSORY_NONE)
			if(existing)
				existing.Remove(human, special = TRUE)
			continue

		if(!existing)
			var/obj/item/organ/new_organ = new organ_type()
			new_organ.Insert(human, special = TRUE, movement_flags = DELETE_IF_REPLACED)
		else
			existing.sync_from_dna(human)

// --- Name choices ------------------------------------------------------------

/datum/preference/choiced/genital
	abstract_type = /datum/preference/choiced/genital
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_SECONDARY_FEATURES
	can_randomize = FALSE
	/// Which organ slot / dna.features key this sets.
	var/organ_slot

/datum/preference/choiced/genital/init_possible_values()
	return assoc_to_keys_features(port_genital_feature_list(organ_slot))

/datum/preference/choiced/genital/create_default_value()
	return SPRITE_ACCESSORY_NONE

/datum/preference/choiced/genital/apply_to_human(mob/living/carbon/human/target, value)
	target.dna.features[organ_slot] = value

/datum/preference/choiced/genital/is_accessible(datum/preferences/preferences)
	if(!..(preferences))
		return FALSE
	return port_genitals_enabled(preferences)

/datum/preference/choiced/genital/penis
	savefile_key = "feature_penis"
	organ_slot = ORGAN_SLOT_PENIS

/datum/preference/choiced/genital/testicles
	savefile_key = "feature_testicles"
	organ_slot = ORGAN_SLOT_TESTICLES

/datum/preference/choiced/genital/vagina
	savefile_key = "feature_vagina"
	organ_slot = ORGAN_SLOT_VAGINA

/datum/preference/choiced/genital/breasts
	savefile_key = "feature_breasts"
	organ_slot = ORGAN_SLOT_BREASTS

// --- Presence toggles (single-shape parts) -----------------------------------
// Anus/womb/butt/belly only have one shape, so a dropdown is pointless; a toggle
// ("do you have one?") reads better. The size sliders still apply.

/datum/preference/toggle/genital_shape
	abstract_type = /datum/preference/toggle/genital_shape
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_SECONDARY_FEATURES
	can_randomize = FALSE
	default_value = FALSE
	/// Which organ slot / dna.features key this sets.
	var/organ_slot
	/// The sprite name used when the toggle is on.
	var/default_shape

/datum/preference/toggle/genital_shape/apply_to_human(mob/living/carbon/human/target, value)
	target.dna.features[organ_slot] = value ? default_shape : SPRITE_ACCESSORY_NONE

/datum/preference/toggle/genital_shape/is_accessible(datum/preferences/preferences)
	if(!..(preferences))
		return FALSE
	return port_genitals_enabled(preferences)

/datum/preference/toggle/genital_shape/womb
	savefile_key = "feature_womb"
	organ_slot = ORGAN_SLOT_WOMB
	default_shape = "Normal"

/datum/preference/toggle/genital_shape/anus
	savefile_key = "feature_anus"
	organ_slot = ORGAN_SLOT_ANUS
	default_shape = "Anus"

/datum/preference/toggle/genital_shape/butt
	savefile_key = "feature_butt"
	organ_slot = ORGAN_SLOT_BUTT
	default_shape = "Pair"

/datum/preference/toggle/genital_shape/belly
	savefile_key = "feature_belly"
	organ_slot = ORGAN_SLOT_BELLY
	default_shape = "Belly"

// --- Sizes -------------------------------------------------------------------

/datum/preference/numeric/genital
	abstract_type = /datum/preference/numeric/genital
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_SECONDARY_FEATURES
	can_randomize = FALSE
	/// dna.features key to write to
	var/feature_key

/datum/preference/numeric/genital/apply_to_human(mob/living/carbon/human/target, value)
	target.dna.features[feature_key] = value

/datum/preference/numeric/genital/is_accessible(datum/preferences/preferences)
	if(!..(preferences))
		return FALSE
	return port_genitals_enabled(preferences)

/datum/preference/numeric/genital/penis_length
	savefile_key = "penis_length"
	feature_key = "penis_size"
	minimum = 1
	maximum = 40
	step = 1

/datum/preference/numeric/genital/penis_length/create_default_value()
	return 6

/datum/preference/numeric/genital/penis_girth
	savefile_key = "penis_girth"
	feature_key = "penis_girth"
	minimum = 1
	maximum = 60
	step = 0.5

/datum/preference/numeric/genital/penis_girth/create_default_value()
	return 9

/datum/preference/numeric/genital/balls_size
	savefile_key = "balls_size"
	feature_key = "balls_size"
	minimum = 0
	maximum = 8
	step = 1

/datum/preference/numeric/genital/balls_size/create_default_value()
	return 2

/datum/preference/numeric/genital/breasts_size
	savefile_key = "breasts_size"
	feature_key = "breasts_size"
	minimum = 0
	maximum = 19
	step = 1

/datum/preference/numeric/genital/breasts_size/create_default_value()
	return 3

/datum/preference/numeric/genital/butt_size
	savefile_key = "butt_size"
	feature_key = "butt_size"
	minimum = 0
	maximum = 8
	step = 1

/datum/preference/numeric/genital/butt_size/create_default_value()
	return 1

/datum/preference/numeric/genital/belly_size
	savefile_key = "belly_size"
	feature_key = "belly_size"
	// 0 disables the belly entirely (Bubber parity).
	minimum = 0
	maximum = 10
	step = 1

/datum/preference/numeric/genital/belly_size/create_default_value()
	return 1

// --- Skin-tone / skin-colour toggles ----------------------------------------

/datum/preference/toggle/genital_skin_tone
	abstract_type = /datum/preference/toggle/genital_skin_tone
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_SECONDARY_FEATURES
	can_randomize = FALSE
	default_value = FALSE
	/// dna.features key to write to
	var/feature_key

/datum/preference/toggle/genital_skin_tone/apply_to_human(mob/living/carbon/human/target, value)
	target.dna.features[feature_key] = value

/datum/preference/toggle/genital_skin_tone/is_accessible(datum/preferences/preferences)
	if(!..(preferences))
		return FALSE
	return port_genitals_enabled(preferences)

/datum/preference/toggle/genital_skin_color
	abstract_type = /datum/preference/toggle/genital_skin_color
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_SECONDARY_FEATURES
	can_randomize = FALSE
	default_value = FALSE
	var/feature_key

/datum/preference/toggle/genital_skin_color/apply_to_human(mob/living/carbon/human/target, value)
	target.dna.features[feature_key] = value

/datum/preference/toggle/genital_skin_color/is_accessible(datum/preferences/preferences)
	if(!..(preferences))
		return FALSE
	return port_genitals_enabled(preferences)

/datum/preference/toggle/genital_skin_tone/penis
	savefile_key = "penis_skin_tone"
	feature_key = "penis_uses_skintones"

/datum/preference/toggle/genital_skin_color/penis
	savefile_key = "penis_skin_color"
	feature_key = "penis_uses_skincolor"

/datum/preference/toggle/genital_skin_tone/testicles
	savefile_key = "testicles_skin_tone"
	feature_key = "testicles_uses_skintones"

/datum/preference/toggle/genital_skin_color/testicles
	savefile_key = "testicles_skin_color"
	feature_key = "testicles_uses_skincolor"

/datum/preference/toggle/genital_skin_tone/vagina
	savefile_key = "vagina_skin_tone"
	feature_key = "vagina_uses_skintones"

/datum/preference/toggle/genital_skin_color/vagina
	savefile_key = "vagina_skin_color"
	feature_key = "vagina_uses_skincolor"

/datum/preference/toggle/genital_skin_tone/breasts
	savefile_key = "breasts_skin_tone"
	feature_key = "breasts_uses_skintones"

/datum/preference/toggle/genital_skin_color/breasts
	savefile_key = "breasts_skin_color"
	feature_key = "breasts_uses_skincolor"

/datum/preference/toggle/genital_skin_tone/butt
	savefile_key = "butt_skin_tone"
	feature_key = "butt_uses_skintones"

/datum/preference/toggle/genital_skin_color/butt
	savefile_key = "butt_skin_color"
	feature_key = "butt_uses_skincolor"

/datum/preference/toggle/genital_skin_tone/belly
	savefile_key = "belly_skin_tone"
	feature_key = "belly_uses_skintones"

/datum/preference/toggle/genital_skin_color/belly
	savefile_key = "belly_skin_color"
	feature_key = "belly_uses_skincolor"

// --- Extra shape toggles -----------------------------------------------------

/datum/preference/toggle/breasts_lactation
	savefile_key = "breasts_lactation_toggle"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_SECONDARY_FEATURES
	can_randomize = FALSE
	default_value = FALSE

/datum/preference/toggle/breasts_lactation/apply_to_human(mob/living/carbon/human/target, value)
	target.dna.features["breasts_lactation"] = value

/datum/preference/toggle/breasts_lactation/is_accessible(datum/preferences/preferences)
	if(!..(preferences))
		return FALSE
	return port_genitals_enabled(preferences)

/datum/preference/choiced/penis_sheath
	savefile_key = "penis_sheath"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_SECONDARY_FEATURES
	can_randomize = FALSE

/datum/preference/choiced/penis_sheath/init_possible_values()
	return SHEATH_MODES

/datum/preference/choiced/penis_sheath/create_default_value()
	return SHEATH_NONE

/datum/preference/choiced/penis_sheath/apply_to_human(mob/living/carbon/human/target, value)
	target.dna.features["penis_sheath"] = value

/datum/preference/choiced/penis_sheath/is_accessible(datum/preferences/preferences)
	if(!..(preferences))
		return FALSE
	return port_genitals_enabled(preferences)

/datum/preference/toggle/penis_taur_mode
	savefile_key = "penis_taur_mode_toggle"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_SECONDARY_FEATURES
	can_randomize = FALSE
	default_value = FALSE

/datum/preference/toggle/penis_taur_mode/apply_to_human(mob/living/carbon/human/target, value)
	target.dna.features["penis_taur_mode"] = value

/datum/preference/toggle/penis_taur_mode/is_accessible(datum/preferences/preferences)
	if(!..(preferences))
		return FALSE
	return port_genitals_enabled(preferences)

// --- Per-part colour picks ---------------------------------------------------
// Bubber has tri-colour genitals; Voidcrew has no tri_color pref, so we expose a single
// colour that fills all three matrixed layers. Applied at a higher priority than the
// importer's wholesale part_colors map so a manual pick wins.

/datum/preference/tri_color/genital_color
	abstract_type = /datum/preference/tri_color/genital_color
	/// Which part_colors key this sets.
	var/color_key

/datum/preference/tri_color/genital_color/apply_to_human(mob/living/carbon/human/target, value)
	// The pref value is seeded from the import, so it is the source of truth.
	port_set_part_color(target, color_key, value)

/datum/preference/tri_color/genital_color/is_accessible(datum/preferences/preferences)
	if(!..(preferences))
		return FALSE
	return port_genitals_enabled(preferences)

/datum/preference/tri_color/genital_color/penis
	savefile_key = "penis_color"
	color_key = "penis_color"

/datum/preference/tri_color/genital_color/testicles
	savefile_key = "testicles_color"
	color_key = "testicles_color"

/datum/preference/tri_color/genital_color/vagina
	savefile_key = "vagina_color"
	color_key = "vagina_color"

/datum/preference/tri_color/genital_color/breasts
	savefile_key = "breasts_color"
	color_key = "breasts_color"

/datum/preference/tri_color/genital_color/butt
	savefile_key = "butt_color"
	color_key = "butt_color"

/datum/preference/tri_color/genital_color/belly
	savefile_key = "belly_color"
	color_key = "belly_color"

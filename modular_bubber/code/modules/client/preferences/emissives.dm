// Emissive ("glow") preferences, ported from Bubber.
//
// Bubber has an "allow emissives" toggle plus a tri-state checkbox per matrixed colour
// layer for each part. Here the tri-state is written to dna.features["part_emissives"]
// (see matrixed_colors.dm), which the renderer turns into emissive appearances. The
// toggle is the master gate: part_emissives is ignored unless
// dna.features["allow_emissives"] is set, and the per-part checkboxes are only
// accessible while it is.
//
// PORTED FROM: Bubberstation modular_skyrat/master_files/.../preferences/mutant_parts.dm
// (allow_emissives, tri_bool/*).

/datum/preference/toggle/allow_emissives
	category = PREFERENCE_CATEGORY_SECONDARY_FEATURES
	savefile_identifier = PREFERENCE_CHARACTER
	savefile_key = "allow_emissives_toggle"
	default_value = FALSE

/datum/preference/toggle/allow_emissives/apply_to_human(mob/living/carbon/human/target, value)
	target.dna.features["allow_emissives"] = value

// Bubber's per-character eye glow. Gated on the master emissive toggle and on the
// species exposing a tintable eye colour (HEAD_EYECOLOR), and only shown while the
// owner actually has an eyes organ. The renderer lives in `generate_body_overlay()`.
/datum/preference/toggle/eye_emissives
	category = PREFERENCE_CATEGORY_SECONDARY_FEATURES
	savefile_identifier = PREFERENCE_CHARACTER
	savefile_key = "eye_emissives"
	default_value = FALSE
	// After `allow_emissives` (priority 1) so the master gate is already in dna.features.
	priority = PREFERENCE_PRIORITY_NAME_MODIFICATIONS
	relevant_head_flag = HEAD_EYECOLOR

/datum/preference/toggle/eye_emissives/apply_to_human(mob/living/carbon/human/target, value)
	value = (value && target.dna?.features?["allow_emissives"]) ? TRUE : FALSE
	target.emissive_eyes = value

/datum/preference/toggle/eye_emissives/is_accessible(datum/preferences/preferences)
	return ..(preferences) && meta_emissives_allowed(preferences)

/proc/meta_emissives_allowed(datum/preferences/preferences)
	if(isnull(preferences))
		return FALSE
	return preferences.read_preference(/datum/preference/toggle/allow_emissives)

// --- Tri-state (per matrixed layer) ------------------------------------------

/datum/preference/tri_bool
	abstract_type = /datum/preference/tri_bool
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_SECONDARY_FEATURES

/datum/preference/tri_bool/deserialize(input, datum/preferences/preferences)
	if(!islist(input))
		return create_default_value()
	var/list/out = list(FALSE, FALSE, FALSE)
	for(var/index in 1 to min(3, length(input)))
		out[index] = input[index] ? TRUE : FALSE
	return out

/datum/preference/tri_bool/create_default_value()
	return list(FALSE, FALSE, FALSE)

/datum/preference/tri_bool/is_valid(value)
	return islist(value) && length(value) == 3

/datum/preference/tri_bool/serialize(input)
	return input

/datum/preference/tri_bool/apply_to_human(mob/living/carbon/human/target, value)
	return

/datum/preference/tri_bool/part_emissive
	abstract_type = /datum/preference/tri_bool/part_emissive
	/// Which `part_emissives` key (matching a `*_color` key) this writes.
	var/color_key
	/// The choiced preference whose value must be non-None for this to show.
	var/savefile_key_to_check

/datum/preference/tri_bool/part_emissive/is_accessible(datum/preferences/preferences)
	if(!..(preferences) || !meta_emissives_allowed(preferences))
		return FALSE
	if(savefile_key_to_check)
		var/datum/preference/choiced/part_pref = GLOB.preference_entries_by_key[savefile_key_to_check]
		if(istype(part_pref))
			var/current = preferences.read_preference(part_pref.type)
			if(isnull(current) || current == SPRITE_ACCESSORY_NONE)
				return FALSE
	return TRUE

/datum/preference/tri_bool/part_emissive/apply_to_human(mob/living/carbon/human/target, value)
	var/list/part_emissives = target.dna.features["part_emissives"]
	if(!islist(part_emissives))
		part_emissives = list()
	part_emissives[color_key] = value
	target.dna.features["part_emissives"] = part_emissives

/datum/preference/tri_bool/part_emissive/ears
	savefile_key = "feature_ears_emissive"
	color_key = "ears_color"
	savefile_key_to_check = "feature_bubber_ears"

/datum/preference/tri_bool/part_emissive/tail
	savefile_key = "feature_tail_emissive"
	color_key = "tail_color"
	savefile_key_to_check = "feature_bubber_tail"

/datum/preference/tri_bool/part_emissive/snout
	savefile_key = "feature_snout_emissive"
	color_key = "snout_color"
	savefile_key_to_check = "feature_lizard_snout"

/datum/preference/tri_bool/part_emissive/horns
	savefile_key = "feature_horns_emissive"
	color_key = "horns_color"
	savefile_key_to_check = "feature_lizard_horns"

/datum/preference/tri_bool/part_emissive/frills
	savefile_key = "feature_frills_emissive"
	color_key = "frills_color"
	savefile_key_to_check = "feature_lizard_frills"

/datum/preference/tri_bool/part_emissive/spines
	savefile_key = "feature_spines_emissive"
	color_key = "spines_color"
	savefile_key_to_check = "feature_lizard_spines"

/datum/preference/tri_bool/part_emissive/moth_antennae
	savefile_key = "feature_moth_antennae_emissive"
	color_key = "moth_antennae_color"
	savefile_key_to_check = "feature_moth_antennae"

/datum/preference/tri_bool/part_emissive/moth_wings
	savefile_key = "feature_moth_wings_emissive"
	color_key = "wings_color"
	savefile_key_to_check = "feature_moth_wings"

// Genitals.
/datum/preference/tri_bool/part_emissive/penis
	savefile_key = "feature_penis_emissive"
	color_key = "penis_color"
	savefile_key_to_check = "feature_penis"

/datum/preference/tri_bool/part_emissive/testicles
	savefile_key = "feature_testicles_emissive"
	color_key = "testicles_color"
	savefile_key_to_check = "feature_testicles"

/datum/preference/tri_bool/part_emissive/vagina
	savefile_key = "feature_vagina_emissive"
	color_key = "vagina_color"
	savefile_key_to_check = "feature_vagina"

/datum/preference/tri_bool/part_emissive/breasts
	savefile_key = "feature_breasts_emissive"
	color_key = "breasts_color"
	savefile_key_to_check = "feature_breasts"

/datum/preference/tri_bool/part_emissive/butt
	savefile_key = "feature_butt_emissive"
	color_key = "butt_color"
	savefile_key_to_check = "feature_butt"

/datum/preference/tri_bool/part_emissive/belly
	savefile_key = "feature_belly_emissive"
	color_key = "belly_color"
	savefile_key_to_check = "feature_belly"
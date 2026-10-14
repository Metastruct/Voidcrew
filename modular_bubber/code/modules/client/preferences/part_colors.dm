// Stores the per-feature 3-colour lists ported from Bubber's per-part `*_color`
// save keys, e.g. `list("ears_color" = list("#cad620", "#3b95a1", "#758e70"), ...)`.
//
// This is consumed by the matrixed-colour framework (matrixed_colors.dm), whose
// get_matrixed_color() prefers these over the global mcolor/mcolor2/mcolor3. It is
// populated by the Bubber importer and has no menu UI of its own, so it is never
// accessible in the PreferencesMenu.

/datum/preference/part_colors
	savefile_key = "feature_part_colors"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_SECONDARY_FEATURES

/datum/preference/part_colors/create_default_value()
	return list()

/datum/preference/part_colors/deserialize(input, datum/preferences/preferences)
	return sanitize_part_colors(input) || list()

/datum/preference/part_colors/serialize(input)
	return input

/datum/preference/part_colors/is_valid(value)
	return islist(value)

/datum/preference/part_colors/apply_to_human(mob/living/carbon/human/target, value)
	target.dna.features["part_colors"] = value

/datum/preference/part_colors/is_accessible(datum/preferences/preferences)
	return FALSE

// Per-feature emissive flags ported from Bubber's per-part `*_emissive` save keys,
// e.g. `list("moth_antennae_color" = list(FALSE, FALSE, TRUE), ...)`. Same shape as the
// colour map (keyed by the matching `*_color` key), consumed by the matrixed renderer's
// get_feature_emissives(). Importer-only, never shown in the menu.

/datum/preference/part_emissives
	savefile_key = "feature_part_emissives"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_SECONDARY_FEATURES

/datum/preference/part_emissives/create_default_value()
	return list()

/datum/preference/part_emissives/deserialize(input, datum/preferences/preferences)
	return sanitize_part_emissives(input) || list()

/datum/preference/part_emissives/serialize(input)
	return input

/datum/preference/part_emissives/is_valid(value)
	return islist(value)

/datum/preference/part_emissives/apply_to_human(mob/living/carbon/human/target, value)
	target.dna.features["part_emissives"] = value

/datum/preference/part_emissives/is_accessible(datum/preferences/preferences)
	return FALSE

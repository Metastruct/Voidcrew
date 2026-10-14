// Hidden per-character blood colour preference (Bubber's "Blood Pigmentation" quirk).
//
// Not exposed in the menu yet - the importer writes it. It applies after the species so
// the recoloured type wraps the species' actual blood, and is re-applied by on_species_gain.

/datum/preference/color/blood_color
	savefile_identifier = PREFERENCE_CHARACTER
	savefile_key = "blood_color"
	category = PREFERENCE_CATEGORY_SECONDARY_FEATURES
	// After species (priority 2), which assigns the base blood type.
	priority = PREFERENCE_PRIORITY_NAME_MODIFICATIONS

/datum/preference/color/blood_color/create_default_value()
	return null

/datum/preference/color/blood_color/is_accessible(datum/preferences/preferences)
	// Importer-only for now; a player-facing picker needs the quirk ported.
	return FALSE

/datum/preference/color/blood_color/apply_to_human(mob/living/carbon/human/target, value)
	if(!istext(value) || !length(value))
		return
	target.dna.features["blood_color"] = value
	meta_apply_blood_color(target)

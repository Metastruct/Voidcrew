// Metastruct: the preference backing the "Legs Style" picker.
//
// Deliberately separate from `/datum/preference/choiced/lizard_legs` so the existing
// Normal/Digitigrade toggle (and everything that checks `FEATURE_LEGS`) keeps working.

/datum/preference/choiced/leg_style
	savefile_key = "leg_style"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_SECONDARY_FEATURES
	// Must run after the species pref, so `target.dna.species` is the one being applied.
	priority = PREFERENCE_PRIORITY_BODYPARTS
	can_randomize = FALSE

/datum/preference/choiced/leg_style/init_possible_values()
	return get_all_leg_style_names()

/datum/preference/choiced/leg_style/create_default_value()
	return LEG_STYLE_NATIVE

/datum/preference/choiced/leg_style/is_accessible(datum/preferences/preferences)
	if(!..())
		return FALSE
	// With mismatched parts on, any species can pick any legs, normal or digitigrade.
	if(preferences.read_preference(/datum/preference/toggle/allow_mismatched_parts))
		return TRUE
	// Otherwise only species whose legs can be customised at all.
	var/datum/species/species_type = preferences.read_preference(/datum/preference/choiced/species)
	return initial(species_type.digitigrade_customization) != DIGITIGRADE_NEVER

/datum/preference/choiced/leg_style/compile_ui_data(mob/user, value)
	var/datum/preferences/preferences = user?.client?.prefs
	return list(
		"value" = serialize(value),
		"choices" = get_leg_style_choices(preferences),
	)

/datum/preference/choiced/leg_style/apply_to_human(mob/living/carbon/human/target, value)
	var/datum/species/species = target.dna?.species
	if(isnull(species))
		return

	var/mismatched = target.dna.features["allow_mismatched_parts"]
	if(!is_leg_style_allowed(species, value, mismatched))
		value = LEG_STYLE_NATIVE

	target.dna.features[FEATURE_LEG_STYLE] = value

	rebuild_legs(target)
	target.update_body()

/// Replaces the target's legs with the ones the selected style resolves to. Does nothing
/// when the current legs already match.
/datum/preference/choiced/leg_style/proc/rebuild_legs(mob/living/carbon/human/target)
	var/datum/species/species = target.dna.species
	var/list/overrides = port_leg_style_overrides(species, target)
	if(!length(overrides))
		return

	for(var/obj/item/bodypart/old_part as anything in target.bodyparts)
		if(old_part.body_zone != BODY_ZONE_L_LEG && old_part.body_zone != BODY_ZONE_R_LEG)
			continue
		if(old_part.change_exempt_flags & BP_BLOCK_CHANGE_SPECIES)
			continue
		var/path = overrides[old_part.body_zone]
		if(!path || istype(old_part, path))
			continue
		var/obj/item/bodypart/new_part = new path()
		new_part.replace_limb(target, TRUE)
		new_part.update_limb(is_creating = TRUE)
		qdel(old_part)

/// The styles a character may actually pick: Native, plus the species' recommended styles,
/// plus every style while "Allow Mismatched Parts" is on. Sent per-user so foreign styles
/// are hidden instead of silently resetting to Native.
/proc/get_leg_style_choices(datum/preferences/preferences)
	// Fail open if we somehow don't have a preferences datum (no user context).
	if(isnull(preferences))
		return get_all_leg_style_names()

	var/datum/species/species_type = preferences.read_preference(/datum/preference/choiced/species)
	var/species_id = species_type ? initial(species_type.id) : null
	var/mismatched = preferences.read_preference(/datum/preference/toggle/allow_mismatched_parts)

	var/list/choices = list()
	for(var/style_name in get_all_leg_style_names())
		var/datum/leg_style/style = GLOB.leg_styles[style_name]
		if(style.name == LEG_STYLE_NATIVE || mismatched || (species_id in style.recommended_species))
			choices += style.name
	return choices

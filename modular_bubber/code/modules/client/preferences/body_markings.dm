// Per-limb body marking preferences + PreferencesMenu middleware, ported from Bubber.
//
// The selection is stored as one `/datum/preference` (an assoc list) rather than a
// feature pref, and edited through a middleware + a dedicated menu page. This is how
// Bubber stores it too, just riding Voidcrew's preference framework instead of a
// bespoke savefile field.
//
// PORTED FROM: modular_skyrat/master_files/code/modules/client/preferences/
//   middleware/limbs_and_markings.dm (+ preferences.dm body_markings storage)

/datum/preference/body_markings
	savefile_key = "body_markings"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_SECONDARY_FEATURES
	can_randomize = FALSE

/datum/preference/body_markings/create_default_value()
	return list()

/datum/preference/body_markings/deserialize(input, datum/preferences/preferences)
	return sanitize_body_markings(input)

/datum/preference/body_markings/serialize(input)
	return input

/datum/preference/body_markings/is_valid(value)
	return islist(value)

/datum/preference/body_markings/apply_to_human(mob/living/carbon/human/target, value)
	target.dna.body_markings = sanitize_body_markings(value)

// Managed by the middleware page, not a normal feature entry.
/datum/preference/body_markings/is_accessible(datum/preferences/preferences)
	return FALSE

/datum/preference_middleware/body_markings
	action_delegations = list(
		"add_marking" = PROC_REF(add_marking),
		"change_marking" = PROC_REF(change_marking),
		"color_marking" = PROC_REF(color_marking),
		"remove_marking" = PROC_REF(remove_marking),
		"change_emissive" = PROC_REF(change_emissive_marking),
		"set_preset" = PROC_REF(set_preset),
	)

	/// Display names for the zones, in the order the menu should show them.
	var/list/zone_names = list(
		BODY_ZONE_HEAD = "Head",
		BODY_ZONE_CHEST = "Chest",
		BODY_ZONE_L_ARM = "Left Arm",
		BODY_ZONE_R_ARM = "Right Arm",
		BODY_ZONE_PRECISE_L_HAND = "Left Hand",
		BODY_ZONE_PRECISE_R_HAND = "Right Hand",
		BODY_ZONE_L_LEG = "Left Leg",
		BODY_ZONE_R_LEG = "Right Leg",
	)

/datum/preference_middleware/body_markings/proc/get_markings()
	return preferences.read_preference(/datum/preference/body_markings)

/datum/preference_middleware/body_markings/proc/save_markings(list/new_markings)
	var/datum/preference/preference = GLOB.preference_entries[/datum/preference/body_markings]
	if(!preferences.write_preference(preference, new_markings))
		return FALSE
	// write_preference doesn't flag the pref as changed, so do it ourselves or the
	// selection never makes it into the savefile.
	preferences.recently_updated_keys |= preference.type
	preferences.character_preview_view?.update_body()
	return TRUE

/// Turn the stored entry for one zone into the shape the tgui page expects.
/datum/preference_middleware/body_markings/proc/fix_colors_on_markings_to_tgui(list/entries, zone)
	var/list/fixed = list()
	if(!islist(entries))
		return fixed
	var/count = 0
	for(var/name in entries)
		count++
		fixed += list(list(
			"name" = name,
			"color" = entries[name][MARKING_INDEX_COLOR],
			"marking_id" = "[zone]_[count]",
			"emissive" = entries[name][MARKING_INDEX_EMISSIVE],
		))
	return fixed

/datum/preference_middleware/body_markings/proc/add_marking(list/params, mob/user)
	var/zone = params["limb_slot"]
	if(!(zone in GLOB.marking_zones))
		return FALSE
	var/list/markings = get_markings()
	var/list/entries = markings[zone] || list()
	if(entries.len >= MAXIMUM_MARKINGS_PER_LIMB)
		return FALSE
	if(!length(GLOB.body_markings_per_limb[zone]))
		return FALSE
	entries[GLOB.body_markings_per_limb[zone][1]] = list("#FFFFFF", FALSE)
	markings[zone] = entries
	return save_markings(markings)

/datum/preference_middleware/body_markings/proc/change_marking(list/params, mob/user)
	var/zone = params["limb_slot"]
	var/marking_name = params["marking_name"]
	var/marking_id = params["marking_id"]
	if(!GLOB.body_markings[marking_name] || !(marking_name in GLOB.body_markings_per_limb[zone]))
		return FALSE
	var/list/markings = get_markings()
	var/list/entries = markings[zone]
	if(!islist(entries))
		return FALSE
	var/list/new_entries = list()
	var/count = 0
	for(var/name in entries)
		count++
		if("[zone]_[count]" == marking_id)
			new_entries[marking_name] = list(entries[name][MARKING_INDEX_COLOR], entries[name][MARKING_INDEX_EMISSIVE])
			continue
		new_entries[name] = entries[name]
	markings[zone] = new_entries
	return save_markings(markings)

/datum/preference_middleware/body_markings/proc/color_marking(list/params, mob/user)
	var/zone = params["limb_slot"]
	var/marking_id = params["marking_id"]
	var/list/markings = get_markings()
	var/list/entries = markings[zone]
	if(!islist(entries))
		return TRUE
	var/list/new_entries = list()
	var/count = 0
	var/new_color
	for(var/name in entries)
		count++
		if("[zone]_[count]" == marking_id)
			// Same picker the core colour preferences use.
			new_color = input(usr, "Select new color", null, entries[name][MARKING_INDEX_COLOR]) as color | null
			if(!new_color)
				return TRUE
			new_entries[name] = list(sanitize_hexcolor(new_color), entries[name][MARKING_INDEX_EMISSIVE])
			continue
		new_entries[name] = entries[name]
	markings[zone] = new_entries
	return save_markings(markings)

/datum/preference_middleware/body_markings/proc/remove_marking(list/params, mob/user)
	var/zone = params["limb_slot"]
	var/marking_id = params["marking_id"]
	var/list/markings = get_markings()
	var/list/entries = markings[zone]
	if(!islist(entries))
		return FALSE
	var/list/new_entries = list()
	var/count = 0
	for(var/name in entries)
		count++
		if("[zone]_[count]" == marking_id)
			continue
		new_entries[name] = entries[name]
	if(length(new_entries))
		markings[zone] = new_entries
	else
		markings -= zone
	return save_markings(markings)

/datum/preference_middleware/body_markings/proc/change_emissive_marking(list/params, mob/user)
	var/zone = params["limb_slot"]
	var/marking_id = params["marking_id"]
	var/emissive = !params["emissive"]
	var/list/markings = get_markings()
	var/list/entries = markings[zone]
	if(!islist(entries))
		return FALSE
	var/list/new_entries = list()
	var/count = 0
	for(var/name in entries)
		count++
		if("[zone]_[count]" == marking_id)
			new_entries[name] = list(entries[name][MARKING_INDEX_COLOR], emissive)
			continue
		new_entries[name] = entries[name]
	markings[zone] = new_entries
	return save_markings(markings)

/datum/preference_middleware/body_markings/proc/set_preset(list/params, mob/user)
	var/preset = params["preset"]
	if(!preset)
		return FALSE
	var/datum/body_marking_set/marking_set = GLOB.body_marking_sets[preset]
	if(isnull(marking_set))
		return FALSE
	var/datum/species/pref_species = preferences.read_preference(/datum/preference/choiced/species)
	// The mutant colours the marking defaults are derived from live in preferences, not
	// in one shared `features` list, so gather them here.
	var/list/features = list(
		FEATURE_MUTANT_COLOR = preferences.read_preference(/datum/preference/color/mutant_color),
		FEATURE_MUTANT_COLOR_TWO = preferences.read_preference(/datum/preference/color/mutant_color_two),
		FEATURE_MUTANT_COLOR_THREE = preferences.read_preference(/datum/preference/color/mutant_color_three),
	)
	return save_markings(port_assemble_body_markings_from_set(marking_set, features, initial(pref_species)))

/datum/preference_middleware/body_markings/get_ui_data(mob/user)
	var/list/data = list()
	var/list/markings = get_markings()
	var/datum/species/species_type = preferences.read_preference(/datum/preference/choiced/species)
	var/species_id = isnull(species_type) ? null : initial(species_type.id)
	var/allow_mismatched = preferences.read_preference(/datum/preference/toggle/allow_mismatched_parts)

	var/list/limbs_data = list()
	for(var/zone in zone_names)
		var/list/choices = islist(GLOB.body_markings_per_limb[zone]) ? GLOB.body_markings_per_limb[zone].Copy() : list()
		if(!allow_mismatched)
			for(var/name in choices)
				var/datum/body_marking/marking = GLOB.body_markings[name]
				if(marking.recommended_species && !(species_id in marking.recommended_species))
					choices -= name
		limbs_data += list(list(
			"slot" = zone,
			"name" = zone_names[zone],
			"markings" = list(
				"marking_choices" = choices,
				"markings_list" = fix_colors_on_markings_to_tgui(markings[zone], zone),
			),
		))
	data["limbs_data"] = limbs_data

	var/list/presets = list()
	for(var/name in GLOB.body_marking_sets)
		var/datum/body_marking_set/marking_set = GLOB.body_marking_sets[name]
		if(!allow_mismatched && marking_set.recommended_species && !(species_id in marking_set.recommended_species))
			continue
		presets += name
	data["marking_presets"] = presets

	return data

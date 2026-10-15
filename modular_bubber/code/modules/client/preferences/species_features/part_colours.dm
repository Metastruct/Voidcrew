// Per-part three-tone colour pickers for the ported external organs.
//
// Bubber's parts are three-tone: up to three independently coloured layers
// (primary/secondary/tertiary), shown on one row. Each part is a single
// `/datum/preference/tri_color` storing all three, written into the shared
// `part_colors` map the matrixed-colour framework reads. The menu renders the three
// swatches inline and sends `set_tri_color_layer` for whichever was clicked (see the
// `tri_color` middleware, which opens the picker for that one layer).
//
// Gated on `relevant_external_organ`, which `get_features()` turns into a savefile key for
// the species that owns the organ, so they only show where the part exists - or everywhere
// when "allow mismatched parts" is on.

/datum/preference/tri_color
	abstract_type = /datum/preference/tri_color
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_SECONDARY_FEATURES
	can_randomize = FALSE
	// Applied after the importer's wholesale part_colors map so a manual pick wins.
	priority = PREFERENCE_PRIORITY_NAME_MODIFICATIONS

/datum/preference/tri_color/deserialize(input, datum/preferences/preferences)
	if(islist(input))
		var/list/out = list("#FFFFFF", "#FFFFFF", "#FFFFFF")
		for(var/index in 1 to min(3, length(input)))
			out[index] = sanitize_hexcolor(input[index])
		return out
	// Legacy single-colour saves: fill all three layers.
	var/single = sanitize_hexcolor(input)
	return list(single, single, single)

/datum/preference/tri_color/create_default_value()
	return list("#FFFFFF", "#FFFFFF", "#FFFFFF")

/datum/preference/tri_color/is_valid(value)
	return islist(value) && length(value) == 3

/datum/preference/tri_color/serialize(input)
	return input

/datum/preference/tri_color/apply_to_human(mob/living/carbon/human/target, value)
	return

/// Write one part's three layers into the shared `part_colors` map. The map stores bare
/// hex (no '#') because the matrixed renderer prepends one; strip it here.
/proc/port_set_part_color(mob/living/carbon/human/target, color_key, list/colors)
	var/list/part_colors = target.dna.features["part_colors"]
	if(!islist(part_colors))
		part_colors = list()
		target.dna.features["part_colors"] = part_colors
	var/list/clean = list()
	for(var/color in colors)
		clean += sanitize_hexcolor(color, 6, FALSE, "FFFFFF")
	part_colors[color_key] = clean

// --- External organs ---------------------------------------------------------

/datum/preference/tri_color/part_color
	abstract_type = /datum/preference/tri_color/part_color
	/// Which part_colors key this sets.
	var/color_key

/datum/preference/tri_color/part_color/apply_to_human(mob/living/carbon/human/target, value)
	// The pref value is seeded from the import, so it is the source of truth.
	port_set_part_color(target, color_key, value)

/datum/preference/tri_color/part_color/ears
	savefile_key = "ears_color"
	color_key = "ears_color"
	relevant_external_organ = /obj/item/organ/ears/bubber

/datum/preference/tri_color/part_color/tail
	savefile_key = "tail_color"
	color_key = "tail_color"
	relevant_external_organ = /obj/item/organ/tail/bubber

/datum/preference/tri_color/part_color/snout
	savefile_key = "snout_color"
	color_key = "snout_color"
	relevant_external_organ = /obj/item/organ/snout/bubber

/datum/preference/tri_color/part_color/horns
	savefile_key = "horns_color"
	color_key = "horns_color"
	relevant_external_organ = /obj/item/organ/horns/bubber

/datum/preference/tri_color/part_color/frills
	savefile_key = "frills_color"
	color_key = "frills_color"
	relevant_external_organ = /obj/item/organ/frills

/datum/preference/tri_color/part_color/spines
	savefile_key = "spines_color"
	color_key = "spines_color"
	relevant_external_organ = /obj/item/organ/spines

// Bubber gives moth (and generic) wings their own `wings_color`, independent of the
// mutant colour. Both FEATURE_WINGS and FEATURE_MOTH_WINGS map to this key in
// `port_feature_color_key()`, so the same picker covers either organ.
/datum/preference/tri_color/part_color/wings
	savefile_key = "wings_color"
	color_key = "wings_color"
	relevant_external_organ = /obj/item/organ/wings/moth

// Synth antennas are three-tone (`USE_MATRIXED_COLORS`) or single-tone; either way the
// overlay reads this list via `port_feature_color_key(FEATURE_SYNTH_ANTENNA)`.
// Bubber stores it as `ipc_antenna_color`, so the savefile key matches the import.
/datum/preference/tri_color/part_color/synth_antenna
	savefile_key = "ipc_antenna_color"
	color_key = "ipc_antenna_color"
	relevant_external_organ = /obj/item/organ/synth_antenna

// --- Menu picker middleware --------------------------------------------------

/datum/preference_middleware/tri_color
	action_delegations = list(
		"set_tri_color_layer" = PROC_REF(set_tri_color_layer),
	)

/// Open the colour picker for one layer of a tri-colour preference and write it back.
/datum/preference_middleware/tri_color/proc/set_tri_color_layer(list/params, mob/user)
	var/datum/preference/tri_color/preference = GLOB.preference_entries_by_key[params["preference"]]
	if(!istype(preference))
		return FALSE
	var/list/current = preferences.read_preference(preference.type)
	var/list/colors = islist(current) ? current.Copy() : list("#FFFFFF", "#FFFFFF", "#FFFFFF")
	var/index = clamp(round(text2num("[params["index"]]")), 1, 3)
	var/new_color = input(usr, "Select new color", null, colors[index]) as color | null
	if(!new_color)
		return TRUE
	colors[index] = sanitize_hexcolor(new_color)
	return preferences.update_preference(preference, colors)
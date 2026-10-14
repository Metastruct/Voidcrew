// Framework for the per-limb body-marking system ported from Bubber.
//
// A /datum/body_marking is a single pre-authored sprite (usually affecting several body
// zones). Characters store the markings they picked as an assoc list on their dna:
//
//     dna.body_markings[zone][marking_name] = list(colour, emissive)
//
// `affected_bodyparts` bitflags decide which zones each marking can go on; the globals
// here flatten that into per-zone choice lists for the PreferencesMenu.
//
// PORTED FROM: modular_skyrat/modules/customization/__HELPERS/global_lists.dm +
// modular_skyrat/modules/customization/_globalvars/lists.dm

/// Flattens subtypesof(/datum/body_marking) and /datum/body_marking_set into globals.
/// Called from SSaccessories::setup_ported_lists().
/proc/meta_make_body_marking_references()
	GLOB.body_markings = list()
	GLOB.body_markings_per_limb = list()
	GLOB.body_marking_sets = list()

	for(var/path in subtypesof(/datum/body_marking))
		var/datum/body_marking/marking = path
		if(!initial(marking.name))
			continue
		marking = new path()
		GLOB.body_markings[marking.name] = marking
		for(var/zone in GLOB.marking_zones)
			var/bitflag = GLOB.marking_zone_to_bitflag[zone]
			if(!(marking.affected_bodyparts & bitflag))
				continue
			// Several Bubber markings claim zones their art doesn't cover; don't offer
			// them where they'd draw nothing.
			if(!meta_body_marking_has_art(marking, zone))
				continue
			if(!GLOB.body_markings_per_limb[zone])
				GLOB.body_markings_per_limb[zone] = list()
			GLOB.body_markings_per_limb[zone] += marking.name

	for(var/set_path in subtypesof(/datum/body_marking_set))
		var/datum/body_marking_set/marking_set = set_path
		if(!initial(marking_set.name))
			continue
		marking_set = new set_path()
		GLOB.body_marking_sets[marking_set.name] = marking_set

/// Validates a stored `dna.body_markings` list, dropping unknown zones/markings and
/// normalizing colours. Returns a fresh list.
/proc/sanitize_body_markings(input)
	var/list/out = list()
	if(!islist(input))
		return out
	for(var/zone in input)
		if(!(zone in GLOB.marking_zones))
			continue
		var/list/entries = input[zone]
		if(!islist(entries))
			continue
		var/list/clean = list()
		for(var/name in entries)
			if(!GLOB.body_markings[name])
				continue
			var/list/entry = entries[name]
			if(!islist(entry))
				entry = list(entry, FALSE)
			// Keep the leading '#': body markings are stored/rendered/picked as full
			// colour strings, unlike the matrixed part_colors which prepend it at draw.
			clean[name] = list(
				sanitize_hexcolor(entry[MARKING_INDEX_COLOR], 6, TRUE, "#FFFFFF"),
				entry[MARKING_INDEX_EMISSIVE] ? TRUE : FALSE,
			)
		if(length(clean))
			out[zone] = clean
	return out

/// Builds a `dna.body_markings` list from a preset, using the marking defaults for the
/// given features. Used by the "pick a preset" dropdown.
/// Whether [marking] has any art for [zone]: the plain state, a gendered chest
/// variant, or a digitigrade leg variant.
/proc/meta_body_marking_has_art(datum/body_marking/marking, zone)
	if(isnull(marking) || isnull(marking.icon) || isnull(marking.icon_state))
		return FALSE
	var/list/suffixes = list("")
	if(zone == BODY_ZONE_CHEST)
		suffixes = list("", "_m", "_f")
	else if(zone == BODY_ZONE_L_LEG || zone == BODY_ZONE_R_LEG)
		suffixes = list("", "digitigrade_1_", "digitigrade_2_")
	for(var/suffix in suffixes)
		if(icon_exists(marking.icon, "[marking.icon_state]_[suffix][zone]"))
			return TRUE
	return FALSE

/// The icon state this marking draws on [limb] for [zone]. Digitigrade legs prefer the
/// `_digitigrade_1_` variant but fall back to the regular leg art, since not every
/// ported marking ships a digitigrade variant.
/datum/body_marking/proc/get_limb_state(obj/item/bodypart/limb, zone, gender_modifier = "")
	if(limb?.limb_id == BODYPART_ID_DIGITIGRADE)
		var/digitigrade_state = "[icon_state]_digitigrade_1_[zone][gender_modifier]"
		if(icon_exists(icon, digitigrade_state))
			return digitigrade_state
	return "[icon_state]_[zone][gender_modifier]"

/// Sets one marking on one zone of this dna. Used by randomisation and debug tooling.
/datum/dna/proc/meta_set_body_marking(zone, marking_name, color = "#FFFFFF", emissive = FALSE)
	if(!(zone in GLOB.marking_zones) || !GLOB.body_markings[marking_name])
		return FALSE
	if(!islist(body_markings))
		body_markings = list()
	if(!islist(body_markings[zone]))
		body_markings[zone] = list()
	body_markings[zone][marking_name] = list(sanitize_hexcolor(color), emissive ? TRUE : FALSE)
	return TRUE

/proc/meta_assemble_body_markings_from_set(datum/body_marking_set/marking_set, list/features, datum/species/pref_species)
	var/list/body_markings = list()
	if(isnull(marking_set))
		return body_markings
	for(var/set_name in marking_set.body_marking_list)
		var/datum/body_marking/marking = GLOB.body_markings[set_name]
		if(isnull(marking))
			continue
		for(var/zone in GLOB.body_markings_per_limb)
			if(!(set_name in GLOB.body_markings_per_limb[zone]))
				continue
			if(!body_markings[zone])
				body_markings[zone] = list()
			body_markings[zone][set_name] = list(marking.get_default_color(features, pref_species), FALSE)
	return body_markings

// Metastruct: import a Bubberstation character into a Voidcrew character slot.
//
// Bubber and Voidcrew both store characters as JSON, but under different keys and
// feature sets. This translates a decoded Bubber `characterN` dict into Voidcrew
// preference values and writes them through the /datum/preference framework, so every
// value is validated (unknown accessories fall back to Voidcrew's default instead of
// breaking the character).
//
// Registered through the `Import Bubber Character` OOC verb, which is ckey-gated: the
// save must be staged by an admin for the caller's ckey at
// `data/bubber_import/<ckey>.json` (or `data/bubber_import/<initial>/<ckey>/preferences.json`),
// so nobody can import another player's characters. (data/ is git-ignored.)
//
// Translate a Bubberstation character (its preferences.json `characterN` format, the
// source of truth for this port) into Voidcrew preference values.

/// Bubber per-accessory colour keys we preserve (see port_feature_color_key()).
GLOBAL_LIST_INIT(bubber_part_color_keys, list(
	"tail_color", "ears_color", "horns_color", "snout_color", "frills_color", "spines_color",
	"wings_color", "taur_color", "moth_antennae_color", "moth_markings_color", "fluff_color",
	"caps_color", "ipc_antenna_color", "penis_color", "testicles_color", "vagina_color", "breasts_color",
	"butt_color", "belly_color",
))

/// Lowercase, strip spaces/hyphens, for best-effort accessory name matching.
/proc/port_feature_key_normalize(text)
	return lowertext(replacetext(replacetext("[text]", " ", ""), "-", ""))

/// Removes digits from a normalized key so "fox(alt3)" and "fox(alt2)" both -> "fox(alt)".
/proc/port_feature_key_strip_digits(text)
	var/out = ""
	for(var/i in 1 to length(text))
		var/char = copytext(text, i, i + 1)
		if(!isnum(text2num(char)))
			out += char
	return out

/// Best-effort resolution of a Bubber accessory name against a feature list: exact,
/// then case-insensitive, then ignoring (Alt N)/digit suffixes, then substring.
/// Returns null if nothing fits.
/proc/port_resolve_feature(value, list/choices)
	if(!istext(value) || !length(choices))
		return null
	if(value in choices)
		return value

	var/lower = lowertext(value)
	for(var/choice in choices)
		if(lowertext("[choice]") == lower)
			return choice

	var/normalized = port_feature_key_strip_digits(port_feature_key_normalize(value))
	for(var/choice in choices)
		if(port_feature_key_strip_digits(port_feature_key_normalize(choice)) == normalized)
			return choice

	if(length(normalized))
		var/best
		var/best_extra = 1e9
		for(var/choice in choices)
			var/choice_key = port_feature_key_strip_digits(port_feature_key_normalize(choice))
			if(!length(choice_key) || !(findtext(choice_key, normalized) || findtext(normalized, choice_key)))
				continue
			// Prefer the closest-length candidate, so "Antlers" matches "Antlers" rather
			// than "Aged Antlers" / "Analytical Antlers".
			var/extra = abs(length(choice_key) - length(normalized))
			if(extra < best_extra)
				best_extra = extra
				best = choice
		if(best)
			return best

	return null

/// Log a value the importer couldn't translate, so shunt edge cases surface in the log
/// instead of only showing up as a character quietly missing a part.
/proc/bubber_log_unresolved(context, value, list/choices)
	if(isnull(value) || value == SPRITE_ACCESSORY_NONE || !istext(value))
		return
	log_world("BUBBER IMPORT: unresolved [context] value '[value]' ([length(choices)] choices) - falling back")

/// Whether Bubber has an explicit toggle for this part and it's off. A stored
/// `feature_<part>` name is only the last thing the player picked - it is rendered only
/// while `<part>_toggle` is on, so importing the name regardless spawns phantom parts
/// (e.g. toggled-off horns). Returns null when the save predates the toggle key, so
/// callers fall through to the name / `mutant_bodyparts`.
/proc/bubber_part_toggled_off(list/bubber, part_key)
	var/toggle = bubber["[part_key]_toggle"]
	return isnull(toggle) ? null : !toggle

/// Resolve a Bubber moth wing name against Voidcrew's moth wing choices.
/// "Moth (Featherful)" is the same art as Voidcrew's "Feathery" (upstream renamed it).
/proc/bubber_resolve_moth_wings(list/bubber, savefile_key)
	if(bubber_part_toggled_off(bubber, "wings"))
		return "None"
	var/datum/preference/choiced/preference = GLOB.preference_entries_by_key[savefile_key]
	if(!istype(preference))
		return "None"
	var/value = bubber["feature_wings"]
	if(istext(value) && findtext(value, "Moth ("))
		value = copytext(value, 7, length(value)) // strip "Moth (" and the trailing ")"
		if(value == "Featherful")
			value = "Feathery"
	var/resolved = port_resolve_feature(value, preference.get_choices())
	if(!resolved)
		bubber_log_unresolved("moth wings", value, preference.get_choices())
	return resolved || "None"

/// Resolve a Bubber feature against the choices of one of our choiced preferences,
/// so we don't have to hardcode each list. Returns [fallback] when nothing matches, or
/// when Bubber's `[toggle_part]_toggle` is explicitly off.
/proc/bubber_resolve_via_pref(list/bubber, value_key, savefile_key, fallback = "None", context = null, toggle_part = null)
	if(toggle_part && bubber_part_toggled_off(bubber, toggle_part))
		return fallback
	var/datum/preference/choiced/preference = GLOB.preference_entries_by_key[savefile_key]
	if(!istype(preference))
		return fallback
	var/resolved = port_resolve_feature(bubber[value_key], preference.get_choices())
	if(!resolved && context)
		bubber_log_unresolved(context, bubber[value_key], preference.get_choices())
	return resolved || fallback

/// Map a Bubber blooper id (e.g. "caw2", "Caw 3") to a ported Bubber voice pack id.
/// The ported packs keep the blooper id as their section name under the `bubber_*`
/// groups, and section names are unique, so a punctuation-insensitive match suffices.
/// Returns null when the sound wasn't ported (importer falls back to the default pack).
/proc/bubber_resolve_voice_pack(value)
	if(!istext(value) || value == "none" || value == SPRITE_ACCESSORY_NONE)
		return null
	var/key = bubber_blooper_key(value)
	if(!length(key))
		return null
	for(var/voice_pack_id in GLOB.voice_pack_list)
		if(copytext("[voice_pack_id]", 1, 8) != "bubber_")
			continue
		var/split = findlasttext(voice_pack_id, ".")
		var/pack_id = split ? copytext(voice_pack_id, split + 1) : voice_pack_id
		if(bubber_blooper_key(pack_id) == key)
			return voice_pack_id
	return null

/// Lowercases and keeps only letters/digits, so "Caw 3", "caw_3" and "caw3" all match.
/proc/bubber_blooper_key(text)
	var/out = ""
	for(var/i in 1 to length(text))
		var/character = copytext(text, i, i + 1)
		if(isnum(text2num(character)) || (lowertext(character) != uppertext(character)))
			out += lowertext(character)
	return out

/// Like bubber_resolve_via_pref, but also checks Bubber's `mutant_bodyparts` mirror.
/// Some saves carry a stale/None top-level `feature_<part>` while the name the game
/// actually renders lives in `mutant_bodyparts[part]["name"]`.
/proc/bubber_resolve_mutant_part(list/bubber, value_key, part_key, savefile_key, fallback = "None")
	var/datum/preference/choiced/preference = GLOB.preference_entries_by_key[savefile_key]
	if(!istype(preference))
		return fallback
	var/list/choices = preference.get_choices()
	// A toggled-off part isn't rendered no matter what name is stored.
	if(bubber_part_toggled_off(bubber, part_key))
		return fallback
	// An explicit top-level "None" means unset, not a real pick: fall through to Bubber's
	// rendered `mutant_bodyparts` name (which is what the game actually shows).
	var/value = bubber[value_key]
	if(istext(value) && value != SPRITE_ACCESSORY_NONE)
		var/resolved = port_resolve_feature(value, choices)
		if(resolved)
			return resolved
		bubber_log_unresolved(part_key, value, choices)
	else if(!isnull(value) && value != SPRITE_ACCESSORY_NONE)
		bubber_log_unresolved(part_key, value, choices)
	var/list/mutant_bodyparts = bubber["mutant_bodyparts"]
	if(islist(mutant_bodyparts) && islist(mutant_bodyparts[part_key]))
		var/fallback_name = mutant_bodyparts[part_key]["name"]
		if(istext(fallback_name) && fallback_name != SPRITE_ACCESSORY_NONE)
			var/resolved_fallback = port_resolve_feature(fallback_name, choices)
			if(resolved_fallback)
				return resolved_fallback
			bubber_log_unresolved("[part_key] (mutant_bodyparts)", fallback_name, choices)
	return fallback

/// Strips a leading '#' so it matches this base's hex colour handling.
/proc/bubber_strip_hash(value)
	if(!istext(value))
		return value
	return copytext(value, (value[1] == "#") ? 2 : 1)

/// Voidcrew's body_type values are "Use gender"/"male"/"female".
/proc/bubber_body_type(value)
	var/lower = lowertext("[value]")
	if(lower == "male" || lower == "female")
		return lower
	return "Use gender"

/// Translate a decoded Bubber `characterN` dict into a map of Voidcrew savefile key
/// -> raw value. Unknown/unsupported fields are omitted, not guessed.
/proc/translate_bubber_character(list/bubber)
	if(!islist(bubber))
		return list()

	var/list/out = list()

	// --- Identity ---
	out["real_name"] = bubber["real_name"]
	out["age"] = bubber["age"]
	out["gender"] = bubber["gender"]
	out["body_type"] = bubber_body_type(bubber["body_type"])
	out["allow_mismatched_parts_toggle"] = bubber["allow_mismatched_parts_toggle"] ? TRUE : FALSE
	out["allow_emissives_toggle"] = bubber["allow_emissives_toggle"] ? TRUE : FALSE
	var/species_id = bubber["species"]
	if(!(species_id in GLOB.species_list))
		species_id = SPECIES_HUMAN
	out["species"] = species_id

	// --- Appearance ---
	out["skin_tone"] = bubber_resolve_via_pref(bubber, "skin_tone", "skin_tone", "caucasian1", "skin tone")
	out["eye_color"] = bubber_strip_hash(bubber["eye_color"])
	out["hair_color"] = bubber_strip_hash(bubber["hair_color"])
	out["facial_hair_color"] = bubber_strip_hash(bubber["facial_hair_color"])
	out["hairstyle_name"] = bubber_resolve_via_pref(bubber, "hairstyle_name", "hairstyle_name", "Bald", "hairstyle")
	out["facial_style_name"] = bubber_resolve_via_pref(bubber, "facial_style_name", "facial_style_name", "Shaved", "facial hair")
	out["hair_gradient"] = bubber_resolve_via_pref(bubber, "hair_gradient", "hair_gradient", "None", "hair gradient")
	out["hair_gradient_color"] = bubber_strip_hash(bubber["hair_gradient_color"])

	// --- Underwear ---
	out["underwear"] = bubber_resolve_via_pref(bubber, "underwear", "underwear", "Nude", "underwear")
	out["underwear_color"] = bubber_strip_hash(bubber["underwear_color"])
	out["undershirt"] = bubber_resolve_via_pref(bubber, "undershirt", "undershirt", "Nude", "undershirt")
	out["socks"] = bubber_resolve_via_pref(bubber, "socks", "socks", "Nude", "socks")
	out["socks_color"] = bubber_strip_hash(bubber["socks_color"])

	// --- Matrixed body colours ---
	var/list/mutant_colors = bubber["mutant_colors_color"]
	if(islist(mutant_colors) && mutant_colors.len >= 3)
		out["feature_mcolor"] = bubber_strip_hash(mutant_colors[1])
		out["feature_mcolor_two"] = bubber_strip_hash(mutant_colors[2])
		out["feature_mcolor_three"] = bubber_strip_hash(mutant_colors[3])

	// --- Per-feature colours, so each ported part keeps its own tint ---
	var/list/part_colors = list()
	var/list/part_emissives = list()
	for(var/color_key in GLOB.bubber_part_color_keys)
		var/list/colors = bubber[color_key]
		if(islist(colors) && colors.len >= 3)
			part_colors[color_key] = list(
				bubber_strip_hash(colors[1]),
				bubber_strip_hash(colors[2]),
				bubber_strip_hash(colors[3]),
			)
		// Bubber stores the per-layer glow flags under `<part>_emissive`.
		var/list/emissives = bubber[replacetext(color_key, "_color", "_emissive")]
		if(islist(emissives) && emissives.len >= 3)
			part_emissives[color_key] = list(
				emissives[1] ? TRUE : FALSE,
				emissives[2] ? TRUE : FALSE,
				emissives[3] ? TRUE : FALSE,
			)
	if(length(part_emissives))
		out["feature_part_emissives"] = part_emissives
		// Seed the per-part tri-state checkboxes too, so their apply_to_human() doesn't
		// clobber the imported flags with their all-off default.
		for(var/pref_type in subtypesof(/datum/preference/tri_bool/part_emissive))
			var/datum/preference/tri_bool/part_emissive/emissive_pref = GLOB.preference_entries[pref_type]
			if(!istype(emissive_pref) || !emissive_pref.color_key || !pref_type)
				continue
			if(part_emissives[emissive_pref.color_key])
				out[emissive_pref.savefile_key] = part_emissives[emissive_pref.color_key]
	if(length(part_colors))
		out["feature_part_colors"] = part_colors
		// Seed the tri-colour pickers with the imported tones so the menu shows them instead
		// of the pref default. The pref value is the source of truth for that part.
		for(var/color_key in part_colors)
			out[color_key] = part_colors[color_key]

	// --- External organs ---
	// Ears/tails have two candidate prefs: the upstream felinid ones and ours. Write
	// both; each validates against its own list, so an incompatible one falls back.
	for(var/key in list("feature_human_ears", "feature_bubber_ears"))
		out[key] = bubber_resolve_mutant_part(bubber, "feature_ears", "ears", key)
	for(var/key in list("feature_human_tail", "feature_bubber_tail"))
		out[key] = bubber_resolve_mutant_part(bubber, "feature_tail", "tail", key)
	// Bubber stores moth wings in `feature_wings` under "Moth (X)"; Voidcrew ships the
	// same art in `moth_wings_list` as just "X".
	out["feature_moth_wings"] = bubber_resolve_moth_wings(bubber, "feature_moth_wings")
	out["feature_wings"] = bubber_resolve_via_pref(bubber, "feature_wings", "feature_wings", "None", "wings", "wings")

	out["feature_lizard_snout"] = bubber_resolve_mutant_part(bubber, "feature_snout", "snout", "feature_lizard_snout")
	out["feature_lizard_horns"] = bubber_resolve_mutant_part(bubber, "feature_horns", "horns", "feature_lizard_horns")
	out["feature_lizard_frills"] = bubber_resolve_via_pref(bubber, "feature_frills", "feature_lizard_frills", "None", "frills", "frills")
	out["feature_lizard_spines"] = bubber_resolve_via_pref(bubber, "feature_spines", "feature_lizard_spines", "None", "spines", "spines")
	out["feature_moth_antennae"] = bubber_resolve_via_pref(bubber, "feature_moth_antennae", "feature_moth_antennae", "None", "moth antennae", "moth_antennae")
	out["feature_moth_markings"] = bubber_resolve_via_pref(bubber, "feature_moth_markings", "feature_moth_markings", "None", "moth markings", "moth_markings")
	out["feature_fluff"] = bubber_resolve_via_pref(bubber, "feature_fluff", "feature_fluff", "None", "fluff", "fluff")
	out["feature_pod_hair"] = bubber_resolve_via_pref(bubber, "feature_pod_hair", "feature_pod_hair", "None", "pod hair")
	out["feature_synth_screen"] = bubber_resolve_via_pref(bubber, "feature_ipc_screen", "feature_synth_screen", "None", "synth screen")
	out["feature_synth_antenna"] = bubber_resolve_via_pref(bubber, "feature_ipc_antenna", "feature_synth_antenna", "None", "synth antenna")
	out["feature_synth_chassis"] = bubber_resolve_via_pref(bubber, "feature_ipc_chassis", "feature_synth_chassis", "Default Chassis", "synth chassis")
	out["feature_synth_head"] = bubber_resolve_via_pref(bubber, "feature_ipc_head", "feature_synth_head", "Default Head", "synth head")
	if(istext(bubber["ipc_chassis_color"]))
		out["synth_chassis_color"] = bubber_strip_hash(bubber["ipc_chassis_color"])
	if(istext(bubber["ipc_head_color"]))
		out["synth_head_color"] = bubber_strip_hash(bubber["ipc_head_color"])

	// --- Legs ---
	out["feature_lizard_legs"] = (lowertext("[bubber["digitigrade_legs"]]") == "digitigrade legs") ? DIGITIGRADE_LEGS : NORMAL_LEGS
	out["leg_style"] = bubber_resolve_via_pref(bubber, "leg_style", "leg_style", "Native", "legs style")

	// --- Body markings ---
	// Legacy per-species slot (lizard/moth) plus the newer per-limb list, which stores
	// zone -> marking name -> list(colour, emissive). Sanitization happens on write.
	var/list/bubber_markings = bubber["body_markings"]
	if(islist(bubber_markings) && length(bubber_markings))
		out["body_markings"] = bubber_markings
	out["feature_lizard_body_markings"] = bubber_resolve_via_pref(bubber, "feature_body_markings", "feature_lizard_body_markings", "None", "body markings", "body_markings")

	// --- Body size / height ---
	// `body_size` is the overall scale, `height_scaling` the discrete height.
	if(!isnull(bubber["body_size"]))
		out["body_size"] = bubber["body_size"]
	if(!isnull(bubber["height_scaling"]))
		out["height_scaling"] = bubber["height_scaling"]

	// --- Voice (Bubber "bloopers" -> ported voice packs + bark tuning) ---
	var/mapped_voice_pack = bubber_resolve_voice_pack(bubber["blooper_choice"])
	if(mapped_voice_pack)
		out["voice_pack"] = mapped_voice_pack
	// Bubber stores speed/pitch/variance as 0-100 percentages; our barks store absolutes.
	// Speed is inverted (a higher percentage is faster, i.e. a lower value).
	if(isnum(bubber["blooper_speed"]))
		out["bark_speech_speed"] = VOICE_DEFAULT_MINSPEED + (VOICE_DEFAULT_MAXSPEED - VOICE_DEFAULT_MINSPEED) * ((100 - clamp(bubber["blooper_speed"], 0, 100)) / 100)
	if(isnum(bubber["blooper_pitch"]))
		out["bark_speech_pitch"] = VOICE_DEFAULT_MINPITCH + (VOICE_DEFAULT_MAXPITCH - VOICE_DEFAULT_MINPITCH) * (clamp(bubber["blooper_pitch"], 0, 100) / 100)
	if(isnum(bubber["blooper_pitch_range"]))
		out["bark_pitch_range"] = VOICE_DEFAULT_MINVARY + (VOICE_DEFAULT_MAXVARY - VOICE_DEFAULT_MINVARY) * (clamp(bubber["blooper_pitch_range"], 0, 100) / 100)

	// --- Blood colour (Bubber's "Blood Pigmentation" quirk) ---
	// Bubber stores a colour for every character (default black) but only applies it with
	// the quirk, so only import it when the quirk is actually present.
	var/list/quirks = bubber["all_quirks"]
	if(islist(quirks) && ("Blood Pigmentation" in quirks))
		var/blood_colour
		var/blood_preset = bubber["select_blood_color"]
		if(istext(blood_preset) && blood_preset != "Custom")
			blood_colour = GLOB.port_blood_color_presets[blood_preset]
		else
			blood_colour = bubber["input_blood_color"]
		if(istext(blood_colour) && length(blood_colour))
			out["blood_color"] = bubber_strip_hash(blood_colour)

	// --- Genitals ---
	out["allow_genitals_toggle"] = bubber["allow_genitals_toggle"] ? TRUE : FALSE
	// Dropdown shapes.
	for(var/organ_slot in list("penis", "testicles", "vagina", "breasts"))
		out["feature_[organ_slot]"] = bubber_resolve_via_pref(bubber, "feature_[organ_slot]", "feature_[organ_slot]")
	// Single-shape parts are presence toggles now (not choiced), so resolve them to a
	// boolean: Bubber stores a shape name there, or "None" when the part is absent.
	for(var/organ_slot in list("womb", "anus", "butt", "belly"))
		var/raw_shape = bubber["feature_[organ_slot]"]
		out["feature_[organ_slot]"] = !(isnull(raw_shape) || raw_shape == SPRITE_ACCESSORY_NONE)

	out["penis_length"] = bubber["penis_length"]
	out["penis_girth"] = bubber["penis_girth"]
	out["balls_size"] = bubber["balls_size"]
	out["butt_size"] = bubber["butt_size"]
	out["belly_size"] = bubber["belly_size"]
	out["penis_sheath"] = bubber["penis_sheath"]
	out["breasts_lactation_toggle"] = bubber["breasts_lactation_toggle"] ? TRUE : FALSE
	out["penis_taur_mode_toggle"] = bubber["penis_taur_mode_toggle"] ? TRUE : FALSE

	// Bubber stores cup names here; our pref wants the size number.
	var/raw_breasts_size = bubber["breasts_size"]
	if(isnum(raw_breasts_size))
		out["breasts_size"] = raw_breasts_size
	else if(istext(raw_breasts_size))
		// "Flatchested" maps to 0, so don't use `|| 3` (0 is falsy).
		var/mapped_breasts_size = GLOB.breast_size_to_number[raw_breasts_size]
		out["breasts_size"] = isnull(mapped_breasts_size) ? 3 : mapped_breasts_size

	// Per-organ skin tone / skin colour toggles.
	for(var/organ in list("penis", "testicles", "vagina", "breasts", "butt", "belly"))
		out["[organ]_skin_tone"] = bubber["[organ]_skin_tone"] ? TRUE : FALSE
		out["[organ]_skin_color"] = bubber["[organ]_skin_color"] ? TRUE : FALSE

	return out

/// Decodes a Bubber `preferences.json` from raw JSON text. Returns the root list or null.
/proc/parse_bubber_preferences_text(text)
	if(!text)
		return null
	try
		var/list/decoded = json_decode(text)
		return islist(decoded) ? decoded : null
	catch(var/exception/err)
		stack_trace("failed to parse Bubber preferences JSON: [err]")
		return null

/// Parses a staged Bubber `preferences.json` file. Returns the decoded root list or null.
/proc/load_bubber_preferences_file(path)
	if(!path || !fexists(path))
		return null
	return parse_bubber_preferences_text(rustg_file_read(path))

/// Looks for a Bubber save staged for this ckey. Supports the flat
/// `data/bubber_import/<ckey>.json` form and a mirrored
/// `data/bubber_import/<initial>/<ckey>/preferences.json` tree.
/proc/load_staged_bubber_save(ckey)
	if(!ckey)
		return null
	for(var/path in list(
		"data/bubber_import/[ckey].json",
		"data/bubber_import/[copytext(ckey, 1, 2)]/[ckey]/preferences.json",
	))
		if(fexists(path))
			return load_bubber_preferences_file(path)
	return null

/// Writes a translated Bubber character into this datum's given slot and saves.
/datum/preferences/proc/import_bubber_character(list/bubber_character, slot = default_slot)
	if(!path)
		return FALSE
	if(!savefile)
		load_savefile()
	if(!savefile)
		return FALSE

	// Wipe the destination slot before importing, so values the previous occupant set (in
	// fields the imported character doesn't specify) can't leak into it, then make sure the
	// slot exists so write_preference has a save_data list to write into.
	var/tree_key = "character[slot]"
	savefile.set_entry(tree_key, list())

	// Loading primes value_cache and points get_save_data_for_savefile_identifier() at
	// this slot.
	load_character(slot)

	var/list/translated = translate_bubber_character(bubber_character)
	for(var/savefile_key in translated)
		var/datum/preference/preference = GLOB.preference_entries_by_key[savefile_key]
		if(isnull(preference))
			continue
		// write_preference deserializes (validates) and writes into the slot's save data.
		write_preference(preference, translated[savefile_key])

	// Imported characters keep exactly what they had; don't let the randomise flags
	// reroll any of it.
	randomise = list()

	save_character()
	save_preferences()
	return TRUE

/// Import one of your characters from a Bubberstation save file.
///
/// The save must be staged for YOUR ckey (see load_staged_bubber_save). This is
/// deliberately ckey-gated so nobody can import another player's characters.
/client/verb/import_bubber_character()
	set name = "Import Bubber Character"
	set category = "OOC"
	set desc = "Import one of your characters from a Bubberstation save staged for your ckey."

	if(!prefs)
		return

	var/list/root = load_staged_bubber_save(ckey)
	if(isnull(root))
		to_chat(src, span_warning("No Bubber save is staged for your account ([ckey]) yet. Ask an admin to add it to data/bubber_import/."))
		return

	port_pick_and_import(root)

/// Character + destination-slot picker shared by the real and debug import verbs.
/client/proc/port_pick_and_import(list/root, verb_title = "Import Bubber Character")
	// Gather this save's characters, labelled by slot and name.
	var/list/choices = list()
	var/list/choice_map = list()
	for(var/key in root)
		if(copytext("[key]", 1, 10) != "character")
			continue
		var/list/character = root[key]
		if(!islist(character))
			continue
		var/char_name = character["real_name"] || "Unknown"
		var/label = "[key]: [char_name]"
		choices += label
		choice_map[label] = key

	if(!length(choices))
		to_chat(src, span_warning("No characters found in the staged Bubber save."))
		return

	var/choice = input(usr, "Which character would you like to import?", verb_title, choices[1]) as null|anything in choices
	if(!choice)
		return

	// Choose the destination slot (existing contents are overwritten).
	var/list/slot_choices = list()
	for(var/i in 1 to prefs.max_save_slots)
		slot_choices += "Slot [i]"
	var/slot_choice = input(usr, "Import [choice] into which slot? (This overwrites that slot.)", verb_title, "Slot [prefs.default_slot]") as null|anything in slot_choices
	if(!slot_choice)
		return
	var/slot = text2num(copytext(slot_choice, 6))

	if(prefs.import_bubber_character(root[choice_map[choice]], slot))
		prefs.default_slot = slot
		prefs.load_character(slot)
		to_chat(src, span_notice("Imported [choice] into slot [slot]. Open Setup Character to see it."))
	else
		to_chat(src, span_warning("Bubber import failed. Tell an admin if this keeps happening."))


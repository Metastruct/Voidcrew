// Three-tone ("matrixed") colour support for ported Bubberstation accessories.
//
// Voidcrew's native mutant overlay tints a whole sprite with one draw_color. Bubber and
// Skyrat accessories are authored with up to three independently coloured layers, shipped
// as extra icon states suffixed _primary, _secondary and _tertiary. This file teaches the
// overlay to render those, so ported art and Bubber character colours can be reused
// as-is.
//
// Opt in per sprite accessory by setting color_src = USE_MATRIXED_COLORS. Colours are
// read, in priority order, from a per-feature list in dna.features["part_colors"] (used
// by the Bubber importer) or from the global mcolor / mcolor2 / mcolor3 features.
//
// PORTED FROM: Bubberstation - modular_skyrat three-tone sprite-accessory rendering
// (bodypart_overlays/mutant_bodypart_overlay.dm + sprite_accessories/_sprite_accessory.dm).

/// Assoc list of "1"/"2"/"3" -> layer-name suffix ("primary"/"secondary"/"tertiary"),
/// resolved lazily from the accessory icon's states.
/datum/sprite_accessory
	var/list/color_layer_names
	/// Cache of matrixed suffixes, keyed by icon-state needle.
	var/list/matrixed_suffix_cache

/// The matrixed colour suffixes whose icon states exist under [state_prefix]
/// (e.g. "m_ears_fox_FRONT_"). Cached per prefix.
/datum/sprite_accessory/proc/get_matrixed_layer_suffixes(state_prefix)
	if(isnull(matrixed_suffix_cache))
		matrixed_suffix_cache = list()
	var/list/cached = matrixed_suffix_cache[state_prefix]
	if(!isnull(cached))
		return cached
	var/list/found = list()
	var/list/states = icon_states(icon)
	for(var/suffix in list("primary", "secondary", "tertiary"))
		if((state_prefix + suffix) in states)
			found += suffix
	matrixed_suffix_cache[state_prefix] = found
	return found

// --- Per-feature colour storage ---------------------------------------------
// Ported characters keep one colour list per part. key -> list(3 hex colours).

/// Map a feature key to its per-part colour key in dna.features["part_colors"].
/proc/port_feature_color_key(feature_key)
	if(!feature_key)
		return null
	switch(feature_key)
		// Legacy renderer aliases (tail/wing/moth keys) folded onto the part key.
		if(FEATURE_TAIL, FEATURE_TAIL_GENERIC, FEATURE_TAIL_LIZARD)
			return "tail_color"
		if(FEATURE_WINGS, "wingsopen")
			return "wings_color"
		if(FEATURE_FLUFF, "moth_fluff")
			return "fluff_color"
		if(FEATURE_MOTH_ANTENNAE)
			return "moth_antennae_color"
		if(FEATURE_MOTH_WINGS)
			return "wings_color"
		if(FEATURE_MOTH_MARKINGS)
			return "moth_markings_color"
		if(FEATURE_MUSH_CAP)
			return "caps_color"
	return "[feature_key]_color"

/// Per-feature 3-colour list (hex without '#') from dna.features["part_colors"], or null.
/proc/port_get_feature_colors(list/features, feature_key)
	if(!islist(features) || !feature_key)
		return null
	var/list/part_colors = features["part_colors"]
	if(!islist(part_colors))
		return null
	var/list/colors = part_colors[port_feature_color_key(feature_key)]
	if(!islist(colors) || !length(colors))
		return null
	return colors

/// Validate a part_colors assoc list (key -> 3 hex colours) from a save/import.
/proc/sanitize_part_colors(list/input)
	if(!islist(input))
		return null
	var/list/out = list()
	for(var/key in input)
		var/list/colors = input[key]
		if(!islist(colors) || !length(colors))
			continue
		var/list/sanitized = list()
		for(var/color in colors)
			sanitized += sanitize_hexcolor(color, 6, FALSE, "FFFFFF")
		if(length(sanitized))
			out[key] = sanitized
	return length(out) ? out : null

/// Validate a part_emissives assoc list (key -> list of 3 booleans) from a save/import.
/proc/sanitize_part_emissives(list/input)
	if(!islist(input))
		return null
	var/list/out = list()
	for(var/key in input)
		var/list/flags = input[key]
		if(!islist(flags) || !length(flags))
			continue
		var/list/sanitized = list()
		for(var/flag in flags)
			sanitized += flag ? TRUE : FALSE
		if(length(sanitized))
			out[key] = sanitized
	return length(out) ? out : null

// --- Overlay rendering -------------------------------------------------------

/datum/bodypart_overlay/mutant
	/// Resolved per-layer colours for matrixed accessories, used for the render cache.
	/// Kept in sync by inherit_color().
	var/list/matrixed_draw_colors
	/// Per-layer emissive eligibility (list of booleans) for this feature, or null.
	/// Kept in sync by inherit_color().
	var/list/feature_emissives

/// Re-inherit our colour at render time, and cache the matrixed layers so the limb
/// icon cache invalidates when any of the three colours change.
/datum/bodypart_overlay/mutant/inherit_color(obj/item/bodypart/bodypart_owner, force)
	// Force the recompute: per-feature colours (the genital colour pickers, dye) can change
	// without the overlay being removed and re-inserted, and draw_color is otherwise cached.
	. = ..(bodypart_owner, TRUE)
	if(isnull(sprite_datum))
		return .
	if(sprite_datum.color_src == USE_MATRIXED_COLORS)
		matrixed_draw_colors = list(
			get_matrixed_color(bodypart_owner, "1"),
			get_matrixed_color(bodypart_owner, "2"),
			get_matrixed_color(bodypart_owner, "3"),
		)
		// Some ported art is marked matrixed but only shipped a single layer. The matrixed
		// renderer bails on it, so tint the single image with the part's primary colour
		// instead of the bodypart's mutant colour.
		if(!length(get_color_layer_names()))
			var/list/single_colors = get_feature_colors(bodypart_owner)
			if(islist(single_colors) && length(single_colors) && single_colors[1])
				draw_color = "#[single_colors[1]]"
	else if(color_source == ORGAN_COLOR_INHERIT && sprite_datum.color_src == MUTANT_COLOR)
		var/list/feature_colors = get_feature_colors(bodypart_owner)
		if(islist(feature_colors) && length(feature_colors) && feature_colors[1])
			draw_color = "#[feature_colors[1]]"
	// Cache the emissive eligibility too, so toggling a part's glow invalidates the limb
	// icon cache (see generate_icon_cache()).
	feature_emissives = get_feature_emissives(bodypart_owner)
	return .

/// Emissive eligibility for this feature, from `dna.features["part_emissives"]`.
/// A list of booleans, one per matrixed layer (primary/secondary/tertiary).
/datum/bodypart_overlay/mutant/proc/get_feature_emissives(obj/item/bodypart/limb)
	var/list/features = limb?.owner?.dna?.features
	if(!islist(features))
		return null
	// Master gate: no glow unless the character has emissives enabled.
	if(!features["allow_emissives"])
		return null
	var/list/part_emissives = features["part_emissives"]
	if(!islist(part_emissives))
		return null
	var/list/emissives = part_emissives[port_feature_color_key(feature_key)]
	return islist(emissives) ? emissives : null

/// Build a glow for one rendered layer, matching its position, offset and colour.
/datum/bodypart_overlay/mutant/proc/make_emissive(image/appearance, obj/item/bodypart/limb)
	if(isnull(appearance) || isnull(limb))
		return null
	var/image/emissive = emissive_appearance(appearance.icon, appearance.icon_state, limb, layer = appearance.layer)
	// emissive_appearance() builds a fresh appearance, so it doesn't inherit the
	// pixel offsets `center_image()` applied to wide sprites (taur, wings, ...).
	emissive.pixel_w = appearance.pixel_w
	emissive.pixel_z = appearance.pixel_z
	// ...nor the layer's tint: by default the glow is the uniform `GLOB.emissive_color`
	// (white). Use the part's colour so the glow matches the sprite.
	if(appearance.color)
		emissive.color = appearance.color
	return emissive

/datum/bodypart_overlay/mutant/generate_icon_cache()
	. = ..()
	if(LAZYLEN(matrixed_draw_colors))
		. += matrixed_draw_colors.Join("_")
	if(LAZYLEN(feature_emissives))
		. += feature_emissives.Join("")
	return .

/// Render one tinted image per matrixed colour layer rather than a single image.
/datum/bodypart_overlay/mutant/get_overlay(layer, obj/item/bodypart/limb)
	inherit_color(limb)
	if(!isnull(sprite_datum) && sprite_datum.color_src == USE_MATRIXED_COLORS)
		var/list/matrixed = get_matrixed_overlays(layer, limb)
		if(matrixed)
			return matrixed
	var/result = ..()
	// Single-colour (or single-layer) accessories still glow when the part's primary
	// emissive flag is set.
	if(!isnull(limb) && islist(feature_emissives) && length(feature_emissives) && feature_emissives[1])
		var/image/main_image = islist(result) ? result[1] : result
		var/image/emissive = make_emissive(main_image, limb)
		if(emissive)
			result = islist(result) ? (result + emissive) : list(result, emissive)
	return result

/// Build the per-layer coloured images. Returns null if this accessory has no
/// matrixed states (so the caller can fall back to the single-colour path).
/datum/bodypart_overlay/mutant/proc/get_matrixed_overlays(layer, obj/item/bodypart/limb)
	var/list/layer_names = get_color_layer_names()
	if(!length(layer_names))
		return null

	var/real_layer = bitflag_to_layer(layer)
	var/list/out = list()
	var/gender_key = (sprite_datum.gender_specific && limb?.limb_gender == FEMALE) ? "f" : "m"
	for(var/color_index in layer_names)
		var/state = "[gender_key]_[feature_key]_[get_base_icon_state()]_[mutant_bodyparts_layertext(real_layer)]_[layer_names[color_index]]"
		var/mutable_appearance/appearance = mutable_appearance(sprite_datum.icon, state, layer = real_layer)
		appearance.color = get_matrixed_color(limb, color_index)
		out += appearance
		if(blocks_emissive != EMISSIVE_BLOCK_NONE && !isnull(limb))
			out += emissive_blocker(appearance.icon, appearance.icon_state, limb, layer = appearance.layer, alpha = appearance.alpha)
		var/index = text2num(color_index)
		if(islist(feature_emissives) && index && (length(feature_emissives) >= index) && feature_emissives[index])
			var/image/emissive = make_emissive(appearance, limb)
			if(emissive)
				out += emissive
	return out

/// Which matrixed colour layers this icon actually has, cached on the sprite datum.
/datum/bodypart_overlay/mutant/proc/get_color_layer_names()
	if(LAZYLEN(sprite_datum.color_layer_names))
		return sprite_datum.color_layer_names

	var/list/found = list()
	var/needle = "_[get_base_icon_state()]_"
	for(var/state in icon_states(sprite_datum.icon))
		if(!findtext(state, needle))
			continue
		if(findtext(state, "_primary"))
			found["1"] = "primary"
		if(findtext(state, "_secondary"))
			found["2"] = "secondary"
		if(findtext(state, "_tertiary"))
			found["3"] = "tertiary"
	sprite_datum.color_layer_names = found
	return found

/// The tint for a matrixed colour index, preferring a per-feature colour list.
/datum/bodypart_overlay/mutant/proc/get_matrixed_color(obj/item/bodypart/limb, color_index)
	var/list/feature_colors = get_feature_colors(limb)
	var/index = text2num(color_index)
	if(feature_colors && index && (feature_colors.len >= index) && feature_colors[index])
		return "#[feature_colors[index]]"

	var/list/features = limb?.owner?.dna?.features
	if(isnull(features))
		return "#FFFFFF"
	var/color = features[matrixed_feature_key(color_index)]
	return color ? "#[color]" : "#FFFFFF"

/// The global dna.features key backing matrixed layer [color_index].
/datum/bodypart_overlay/mutant/proc/matrixed_feature_key(color_index)
	switch(color_index)
		if("1")
			return FEATURE_MUTANT_COLOR
		if("2")
			return FEATURE_MUTANT_COLOR_TWO
		if("3")
			return FEATURE_MUTANT_COLOR_THREE

/// The per-feature colour list this overlay should draw with, or null.
/datum/bodypart_overlay/mutant/proc/get_feature_colors(obj/item/bodypart/limb)
	return port_get_feature_colors(limb?.owner?.dna?.features, feature_key)

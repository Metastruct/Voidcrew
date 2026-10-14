// `should_generate_icons` helpers for the ported sprite-accessory preferences.
//
// The core "Select X" picker (PREFERENCE_CATEGORY_FEATURES + should_generate_icons) shows
// an icon grid built from `icon_for(value)`. These helpers let our ported parts (ears,
// tail, synth screen/antenna) use the same picker as the core snout/horns.
//
// The generated icon blends every available layer of the accessory onto a blank 32x32
// cell (an empty layer adds nothing), then tints it lime the way the core previews are
// (the ported art is greyscale masks meant to be tinted at runtime). Blending all layers
// matters because some accessories ship an empty same-named state on one layer while the
// real art sits on another (e.g. tails ship an empty FRONT and draw on BEHIND).

/// A blank 32x32 cell, used for "None"/art-less choices (the asset generator crashes on null).
/proc/blank_pref_icon()
	return uni_icon('modular_bubber/icons/misc/blank.dmi', "blank")

/// Pick the first of [base] and its `_primary`/`_secondary`/`_tertiary` slices that
/// exists in [states].
/proc/meta_resolve_icon_state(list/states, base)
	if(isnull(base))
		return null
	if(base in states)
		return base
	for(var/suffix in list("primary", "secondary", "tertiary"))
		if("[base]_[suffix]" in states)
			return "[base]_[suffix]"
	return null

/// A 32x32 preference icon for [accessory].
///
/// When [state_base] is given it is resolved directly; otherwise the state is built from
/// `m_<feature_key>_<icon_state>_<layer>` for each layer in [layer_order] (default
/// FRONT/ADJ/BEHIND) and every one that exists is blended. Pass [tint] = null for
/// already-coloured art (e.g. synth screens). [crop] is an optional `list(x1, y1, x2, y2)`
/// applied before the 32x32 scale, so head parts fill the cell instead of floating tiny
/// in the corner (the core hair/lizard previews crop the head region the same way).
/// [dir] picks the facing to draw; without it the batched renderer composites every
/// direction on top of each other, which looks like a tangle of limbs.
/proc/meta_part_pref_icon(datum/sprite_accessory/accessory, feature_key, state_base, tint = COLOR_VIBRANT_LIME, list/layer_order, list/crop, dir = SOUTH)
	if(isnull(accessory) || isnull(accessory.icon))
		return blank_pref_icon()

	var/list/all_states = icon_states(accessory.icon)
	// Base the icon on the first real state, not a blank canvas: iconforge happily
	// composites onto real DMI art but a hand-made blank DMI has to be a proper palette
	// PNG or the whole entry is dropped.
	var/datum/universal_icon/final_icon

	if(!isnull(state_base))
		var/state = meta_resolve_icon_state(all_states, state_base)
		if(!isnull(state))
			final_icon = uni_icon(accessory.icon, state, dir)
	else if(!isnull(accessory.icon_state) && accessory.icon_state != SPRITE_ACCESSORY_NONE)
		if(isnull(layer_order))
			layer_order = list("FRONT", "ADJ", "BEHIND")
		for(var/layer in layer_order)
			var/state = meta_resolve_icon_state(all_states, "m_[feature_key]_[accessory.icon_state]_[layer]")
			if(isnull(state))
				continue
			var/datum/universal_icon/part = uni_icon(accessory.icon, state, dir)
			if(isnull(final_icon))
				final_icon = part
			else
				final_icon.blend_icon(part, ICON_OVERLAY)

	if(isnull(final_icon))
		return blank_pref_icon()

	if(crop)
		final_icon.crop(crop[1], crop[2], crop[3], crop[4])
	final_icon.scale(32, 32)
	if(tint)
		final_icon.blend_color(tint, ICON_MULTIPLY)
	return final_icon

/// A 32x32 preference icon for a synth chassis/head accessory. Unlike the mutant-overlay
/// parts above, these are whole bodypart sheets, where the state is `[icon_state]_[zone]`
/// (plus `_m`/`_f` for dimorphic art). [dimorphic] picks the male state as a representative;
/// the grid can't know the viewer's gender. Greyscale sheets (`color_src` set) get the same
/// lime tint as the core part previews, while pre-coloured sheets are left untouched.
/// [crop] optionally zooms to just the head/body so the part fills the cell.
/proc/meta_synth_part_pref_icon(datum/sprite_accessory/accessory, zone, dimorphic = FALSE, list/crop)
	if(isnull(accessory) || isnull(accessory.icon))
		return blank_pref_icon()

	var/state = "[accessory.icon_state]_[zone]"
	if(dimorphic)
		state += "_m"

	return meta_part_pref_icon(accessory, null, state_base = state, tint = accessory.color_src ? COLOR_VIBRANT_LIME : null, crop = crop)

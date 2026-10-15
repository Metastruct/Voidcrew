// Re-read every external organ's sprite from DNA.
//
// The character-setup preview re-runs apply_prefs_to() on each change, but
// regenerate_organs() keeps existing organs on a same-species apply, so their overlays
// never pick up a changed feature. This walks the organs and re-imprints them.

/// Re-imprint each external organ's overlay from `dna.features` (skipping "None"/missing).
/proc/port_resync_visual_organs(mob/living/carbon/human/human)
	if(!ishuman(human))
		return
	var/list/features = human.dna?.features
	if(!islist(features))
		return

	for(var/obj/item/organ/organ as anything in human.organs)
		var/datum/bodypart_overlay/mutant/overlay = organ.bodypart_overlay
		if(isnull(overlay))
			continue
		var/feature_key = overlay.feature_key
		if(isnull(feature_key) || feature_key == "")
			continue
		var/value = features[feature_key]
		if(isnull(value) || value == SPRITE_ACCESSORY_NONE)
			continue
		// Only re-imprint names the organ's list actually knows, so a stale save can't crash.
		if(isnull(overlay.get_global_feature_list()[value]))
			continue
		overlay.set_appearance_from_name(value)
		overlay.imprint_on_next_insertion = FALSE

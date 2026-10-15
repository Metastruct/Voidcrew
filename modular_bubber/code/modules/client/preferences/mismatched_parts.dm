// "Allow mismatched parts", ported from Bubber's allow_mismatched_parts_toggle.
//
// When on, a character can show external organs their species does not normally have,
// such as a human with fox ears. Voidcrew gates feature preferences on the species
// owning the organ, so this is enforced in two tagged core hooks:
//   - /datum/preference/proc/has_relevant_feature() makes species-gated prefs accessible
//   - /datum/species/proc/on_species_gain() grants the ported organs per mob
//
// PORTED FROM: Bubberstation modular_skyrat allow_mismatched_parts_toggle.

/datum/preference/toggle/allow_mismatched_parts
	savefile_key = "allow_mismatched_parts_toggle"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_SECONDARY_FEATURES
	can_randomize = FALSE
	default_value = FALSE

/// Store the toggle in DNA so the organ sync can read it without a client (the
/// character-setup preview dummy has none).
/datum/preference/toggle/allow_mismatched_parts/apply_to_human(mob/living/carbon/human/target, value)
	target.dna.features["allow_mismatched_parts"] = value

/// Ported external organs mismatched parts can grant to any humanoid.
GLOBAL_LIST_INIT(port_mismatched_organs, list(
	/obj/item/organ/ears/bubber,
	/obj/item/organ/tail/bubber,
	/obj/item/organ/snout/bubber,
	/obj/item/organ/horns/bubber,
	/obj/item/organ/frills,
	/obj/item/organ/spines,
	/obj/item/organ/fluff,
	// Moth wings, so a Bubber Anthromorph with wings (merdo) renders them too. The
	// generic `/obj/item/organ/wings` is abstract (no feature list), so only the
	// concrete moth variant is grantable.
	/obj/item/organ/wings/moth,
))

/// Bring a human's *non-native* ported organs in line with the "allow mismatched parts"
/// toggle: add chosen ones, re-sync changed ones, and remove any the species shouldn't
/// have. Native organs (the species\' own mutant_organs/mutantears) are left alone.
/// Reads the toggle from `dna.features` so it works for the preview dummy too.
/// Called from on_species_gain() and from apply_prefs_to().
/proc/port_sync_mismatched_organs(mob/living/carbon/human/human, datum/species/species_override)
	if(!ishuman(human))
		return
	if(isnull(human.dna))
		return

	// on_species_gain runs before dna.species is updated, so the caller passes the species
	// being gained; otherwise we'd judge the new organs against the old species and remove
	// them as "not native".
	var/datum/species/species = species_override || human.dna.species
	if(isnull(species))
		return
	var/list/features = human.dna.features
	var/mismatched = features["allow_mismatched_parts"]

	for(var/obj/item/organ/organ_type as anything in GLOB.port_mismatched_organs)
		if(!ispath(organ_type))
			continue
		var/datum/bodypart_overlay/mutant/sample_overlay = initial(organ_type.bodypart_overlay)
		if(isnull(sample_overlay))
			continue
		var/feature_key = initial(sample_overlay.feature_key)
		var/feature_value = feature_key ? features[feature_key] : null
		var/has_sprite = !isnull(feature_value) && feature_value != SPRITE_ACCESSORY_NONE
		var/obj/item/organ/existing = human.get_organ_by_type(organ_type)

		// Native organ: regeneration normally owns it, but it drops some species' mutantears
		// on a same-species apply, so make sure it exists when a sprite is chosen.
		// NOTE: the parentheses matter - `in` and `||` do not bind the way you'd expect.
		if((organ_type in species.mutant_organs) || (species.mutantears == organ_type))
			if(has_sprite && isnull(existing))
				var/obj/item/organ/native_organ = new organ_type()
				native_organ.Insert(human, special = TRUE, movement_flags = DELETE_IF_REPLACED)
			continue

		if(!mismatched || !has_sprite)
			if(existing)
				existing.Remove(human, special = TRUE)
			continue

		if(!existing)
			var/obj/item/organ/new_organ = new organ_type()
			new_organ.Insert(human, special = TRUE, movement_flags = DELETE_IF_REPLACED)
		else
			existing.bodypart_overlay?.set_appearance_from_name(feature_value)
	port_order_mutant_bodypart_overlays(human)

/// Wings draw over tails (Bubber parity). Overlays sharing a layer draw in insertion
/// order, and a non-native (mismatched) tail is inserted after a species' native wings,
/// so without this the tail covers the wings from behind.
/proc/port_order_mutant_bodypart_overlays(mob/living/carbon/human/human)
	if(!ishuman(human))
		return
	for(var/obj/item/bodypart/part as anything in human.bodyparts)
		var/list/overlays = part.bodypart_overlays
		if(length(overlays) < 2)
			continue
		var/list/result = list()
		var/list/wings = list()
		var/last_tail_index = 0
		for(var/datum/bodypart_overlay/overlay as anything in overlays)
			if(istype(overlay, /datum/bodypart_overlay/mutant/wings))
				wings += overlay
				continue
			result += overlay
			if(istype(overlay, /datum/bodypart_overlay/mutant/tail))
				last_tail_index = length(result)
		// Nothing to do if there are no wings or no tail to move them past.
		if(!length(wings) || !last_tail_index)
			continue
		// Re-insert the wings directly after the last tail, leaving every other overlay
		// (genitals, markings, ...) in its original position.
		for(var/index in length(wings) to 1 step -1)
			result.Insert(last_tail_index + 1, wings[index])
		part.bodypart_overlays = result

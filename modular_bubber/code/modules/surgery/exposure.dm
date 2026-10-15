// Body-zone exposure helper used by the ported genital system to decide whether clothing
// hides a part.
//
// Adapted from Metastruct's own modular_zzmeta underwear exposure model. Voidcrew has no
// underwear *items* yet (just the `underwear`/`undershirt`/`socks` preference strings), so
// that path is checked against the preference value. When the underwear item system is
// ported, this is the single place to teach it about `w_underwear`/`w_bra`.
//
// PORTED FROM: Bubberstation modular_zzmeta/code/modules/clothing/underwear/visibility.dm

/// Whether this uniform design leaves the groin visible (skirts, dresses) rather
/// than concealing it.
/proc/port_groin_exposing_uniform(obj/item/clothing/under/uniform)
	if(istype(uniform, /obj/item/clothing/under/dress))
		return TRUE
	return !!findtext("[uniform.type]", "skirt")

/// Whether a body zone is covered by worn clothing (and, optionally, underwear).
/mob/living/carbon/human/proc/is_body_zone_covered(zone, include_underwear = TRUE)
	var/list/covering_slots = list(w_uniform, wear_suit, shoes)
	for(var/obj/item/garment as anything in covering_slots)
		if(isnull(garment))
			continue
		if(zone == GROIN && garment == w_uniform && port_groin_exposing_uniform(garment))
			continue
		if(garment.body_parts_covered & zone)
			return TRUE

	if(include_underwear)
		// Voidcrew keeps underwear as a preference string; "Nude" means none.
		if(zone == GROIN && underwear && underwear != "Nude")
			return TRUE
		if(zone == CHEST && undershirt && undershirt != "Nude")
			return TRUE

	return FALSE

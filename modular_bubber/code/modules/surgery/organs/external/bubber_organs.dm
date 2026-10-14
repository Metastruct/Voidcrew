// Bodypart overlays and external organs for the ported anthro parts.
//
// Voidcrew already ships the machinery for external organs and mutant bodyparts;
// these are the ported-from-Bubber pieces that don't map onto an upstream organ:
// the generic "tail" (Bubber's key) and a Bubber ears organ that draws on all three
// external layers. Snouts/horns reuse the upstream organs but need extra draw layers
// because Bubber's art is authored on FRONT rather than ADJ.
//
// PORTED FROM: modular_skyrat/modules/customization/.../surgery/organs/{ears,tails,snout,horns}.dm

// --- Generic anthro tail -----------------------------------------------------

/datum/sprite_accessory/tails/bubber/mammal/wagging
	can_wag = TRUE

/datum/sprite_accessory/tails/mammal/wagging
	can_wag = TRUE

// Zubbers' synthliz tail ships a `m_tail_wagging_synthliz_*` variant; the generator
// drops Bubber's `flags_for_organ`, so mark it wag-capable here (the overlay still
// checks for real wag art before enabling the *wag emote).
/datum/sprite_accessory/tails/synthliz
	can_wag = TRUE

/datum/bodypart_overlay/mutant/tail/bubber
	feature_key = FEATURE_TAIL_GENERIC
	color_source = ORGAN_COLOR_INHERIT
	dyable = TRUE
	/// Weakref to the tail organ that owns us, so a sprite change can refresh wagging.
	var/datum/weakref/attached_tail

/datum/bodypart_overlay/mutant/tail/bubber/New(obj/item/organ/attached_organ)
	. = ..()
	if(!isnull(attached_organ))
		attached_tail = WEAKREF(attached_organ)

/datum/bodypart_overlay/mutant/tail/bubber/set_appearance(accessory_type)
	. = ..()
	refresh_attached_wag()

/datum/bodypart_overlay/mutant/tail/bubber/set_appearance_from_name(accessory_name)
	. = ..()
	refresh_attached_wag()

/datum/bodypart_overlay/mutant/tail/bubber/proc/refresh_attached_wag()
	var/obj/item/organ/tail/bubber/tail = attached_tail?.resolve()
	tail?.refresh_wag_ability()

/// Whether this tail's art ships a `m_tail_wagging_<icon_state>_...` variant. Bubber
/// marks some tails wag-capable without wag art, so the art decides, not the marker.
/datum/bodypart_overlay/mutant/tail/bubber/proc/has_wag_art()
	if(isnull(sprite_datum))
		return FALSE
	var/needle = "_wagging_[sprite_datum.icon_state]_"
	for(var/state in icon_states(sprite_datum.icon))
		if(findtext(state, needle))
			return TRUE
	return FALSE

/datum/bodypart_overlay/mutant/tail/bubber/get_global_feature_list()
	return SSaccessories.tails_list_bubber

/obj/item/organ/tail/bubber
	name = "tail"
	preference = "feature_bubber_tail"
	bodypart_overlay = /datum/bodypart_overlay/mutant/tail/bubber
	dna_block = null // no upstream genetics block; appearance is preference-driven

/// Enable/disable the *wag emote for the currently selected tail style. Called when
/// the overlay's sprite changes (organ insertion, preference resync, mismatched parts).
/obj/item/organ/tail/bubber/proc/refresh_wag_ability()
	var/datum/bodypart_overlay/mutant/tail/bubber/overlay = bodypart_overlay
	if(!istype(overlay))
		return
	var/datum/sprite_accessory/tails/tail_datum = overlay.sprite_datum
	if(istype(tail_datum) && tail_datum.can_wag && overlay.has_wag_art())
		wag_flags |= WAG_ABLE
		return
	if(wag_flags & WAG_WAGGING)
		stop_wag(owner)
	wag_flags &= ~WAG_ABLE

// --- Ears --------------------------------------------------------------------

/datum/bodypart_overlay/mutant/bubber_ears
	layers = EXTERNAL_FRONT | EXTERNAL_ADJACENT | EXTERNAL_BEHIND
	feature_key = FEATURE_EARS
	color_source = ORGAN_COLOR_INHERIT
	dyable = TRUE

/datum/bodypart_overlay/mutant/bubber_ears/get_global_feature_list()
	return SSaccessories.ears_list

/datum/bodypart_overlay/mutant/bubber_ears/can_draw_on_bodypart(obj/item/bodypart/bodypart_owner)
	var/mob/living/carbon/human/human = bodypart_owner.owner
	if(!istype(human))
		return TRUE
	if((human.head?.flags_inv & HIDEHAIR) || (human.wear_mask?.flags_inv & HIDEHAIR))
		return FALSE
	return TRUE

/obj/item/organ/ears/bubber
	name = "ears"
	visual = TRUE
	preference = "feature_bubber_ears"
	bodypart_overlay = /datum/bodypart_overlay/mutant/bubber_ears

// --- Snout / horns: reuse upstream organs, widen the draw layers -------------

/datum/bodypart_overlay/mutant/snout/bubber
	layers = EXTERNAL_FRONT | EXTERNAL_ADJACENT

/obj/item/organ/snout/bubber
	bodypart_overlay = /datum/bodypart_overlay/mutant/snout/bubber

/datum/bodypart_overlay/mutant/horns/bubber
	layers = EXTERNAL_FRONT | EXTERNAL_ADJACENT | EXTERNAL_BEHIND

/obj/item/organ/horns/bubber
	bodypart_overlay = /datum/bodypart_overlay/mutant/horns/bubber

// --- Fluff --------------------------------------------------------------------
// A chest overlay (Bubber draws it around the collar), ported from Bubber's
// /obj/item/organ/fluff. Shows the ported moth/anthro neck fluff.

/datum/bodypart_overlay/mutant/fluff
	layers = EXTERNAL_ADJACENT | EXTERNAL_FRONT
	feature_key = FEATURE_FLUFF
	color_source = ORGAN_COLOR_INHERIT
	dyable = TRUE

/datum/bodypart_overlay/mutant/fluff/get_global_feature_list()
	return SSaccessories.fluff_list

/obj/item/organ/fluff
	name = "fluff"
	desc = "A collar of soft plumage around the shoulders."
	zone = BODY_ZONE_CHEST
	slot = ORGAN_SLOT_EXTERNAL_FLUFF
	preference = "feature_fluff"
	bodypart_overlay = /datum/bodypart_overlay/mutant/fluff
	dna_block = null // appearance is preference-driven
	organ_flags = parent_type::organ_flags | ORGAN_EXTERNAL

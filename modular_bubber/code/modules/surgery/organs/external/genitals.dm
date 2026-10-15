// Genital organs ported from Bubberstation.
//
// Voidcrew's external-organ system differs from Bubber's, so this is an adaptation:
//  * the overlay reads its sprite name from DNA's `features[feature_key]` (not a
//    `mutant_bodyparts` list), and per-feature colours live in `features["part_colors"]`;
//  * draw layers are the three EXTERNAL_* bitflags (Bubber's fine 5.1/19.9 numeric layers
//    collapse onto FRONT/ADJ/BEHIND, which is all the art actually uses);
//  * Voidcrew has no `build_from_dna()`, so size/sheath/skintone scalars are synced when
//    the organ is inserted (and by the preferences when they change).
//
// PORTED FROM: Bubberstation modular_skyrat/modules/customization/modules/surgery/organs/genitals.dm
// and modular_zubbers/code/modules/mob/living/carbon/human/species_types/slimepeople.dm (butt/belly)

// --- Overlay base ------------------------------------------------------------

/datum/bodypart_overlay/mutant/genital
	color_source = ORGAN_COLOR_OVERRIDE
	dyable = TRUE
	/// The suffix appended to the feature_key for the overlays.
	var/sprite_suffix
	/// The organ this overlay draws for, held weakly: the organ strongly references us
	/// through `bodypart_overlay`, so a strong link back would be an uncollectable cycle
	/// (BYOND is reference-counted, not mark-and-sweep).
	var/datum/weakref/attached_genital

/datum/bodypart_overlay/mutant/genital/New(obj/item/organ/attached_organ)
	. = ..()
	if(istype(attached_organ, /obj/item/organ/genital))
		attached_genital = WEAKREF(attached_organ)

/datum/bodypart_overlay/mutant/genital/proc/get_attached_genital()
	return attached_genital?.resolve()

/datum/bodypart_overlay/mutant/genital/get_base_icon_state()
	return sprite_suffix

/datum/bodypart_overlay/mutant/genital/override_color(obj/item/bodypart/bodypart_owner)
	var/obj/item/organ/genital/genital = get_attached_genital()
	return genital?.get_genital_color(bodypart_owner) || "#FFFFFF"

/datum/bodypart_overlay/mutant/genital/can_draw_on_bodypart(obj/item/bodypart/bodypart_owner)
	var/mob/living/carbon/human/human = bodypart_owner?.owner
	if(!ishuman(human))
		return TRUE
	var/obj/item/organ/genital/genital = get_attached_genital()
	if(isnull(genital))
		return TRUE
	// Size 0 means "none" for most parts (no belly, no butt), but breasts have a real
	// flat-chested sprite, so `renders_at_zero` keeps those drawing.
	if(genital.genital_size <= 0 && !genital.renders_at_zero)
		return FALSE
	return genital.is_exposed() != FALSE

// --- Organ base --------------------------------------------------------------

/obj/item/organ/genital
	name = "genital"
	desc = "You shouldn't see this."
	organ_flags = parent_type::organ_flags | ORGAN_EXTERNAL | ORGAN_UNREMOVABLE
	/// Size value, translated per-organ into length / diameter / cup
	var/genital_size = 1
	/// Sprite name shown in character creation
	var/genital_name = "Human"
	/// Sprite icon_state family (e.g. "human", "pair")
	var/genital_type = "human"
	/// Computed suffix used to build the overlay icon state
	var/sprite_suffix
	/// Whether/where this part shows through clothing
	var/visibility_preference = GENITAL_HIDDEN_BY_CLOTHES
	/// Arousal state, see AROUSAL_*
	var/aroused = AROUSAL_NONE
	/// Draw a skin-tone shaded art variant (`_s`)
	var/uses_skintones = FALSE
	/// Tint with the owner's skin colour
	var/uses_skin_color = FALSE
	/// Body zone used for clothing checks
	var/genital_location = GROIN
	/// If TRUE, a size of 0 still draws (a flat-chested sprite) instead of hiding the part.
	var/renders_at_zero = FALSE

/obj/item/organ/genital/on_mob_insert(mob/living/carbon/organ_owner, special = FALSE, movement_flags)
	. = ..()
	sync_from_dna(organ_owner)
	if(!(organ_owner.living_flags & STOP_OVERLAY_UPDATE_BODY_PARTS))
		organ_owner.update_body_parts()

/// Read this part's size/shape scalars out of DNA and rebuild the sprite suffix.
/obj/item/organ/genital/proc/sync_from_dna(mob/living/carbon/human/human)
	var/list/features = human?.dna?.features
	if(!islist(features))
		return
	var/datum/bodypart_overlay/mutant/genital/our_overlay = bodypart_overlay
	var/feature_name = features[slot]
	if(our_overlay && !isnull(feature_name) && our_overlay.get_global_feature_list()[feature_name])
		our_overlay.set_appearance_from_name(feature_name)
	var/datum/sprite_accessory/genital/accessory = our_overlay?.sprite_datum
	if(istype(accessory))
		genital_name = accessory.name
		genital_type = accessory.icon_state
	build_genital_from_dna(features, accessory)
	update_sprite_suffix()

/// Per-organ override: read the raw scalars. `accessory` may be null early on.
/obj/item/organ/genital/proc/build_genital_from_dna(list/features, datum/sprite_accessory/genital/accessory)
	return

/obj/item/organ/genital/proc/set_size(size)
	genital_size = size
	update_sprite_suffix()
	if(owner && !(owner.living_flags & STOP_OVERLAY_UPDATE_BODY_PARTS))
		owner.update_body_parts()

/obj/item/organ/genital/proc/update_sprite_suffix()
	sprite_suffix = "[get_sprite_size_string()]"
	var/datum/bodypart_overlay/mutant/genital/our_overlay = bodypart_overlay
	if(our_overlay)
		our_overlay.sprite_suffix = sprite_suffix

/// Translate the size into the sprite suffix appended to `m_<feature_key>_`.
/obj/item/organ/genital/proc/get_sprite_size_string()
	return "0"

/// The colour a single-layer genital sprite draws with.
/obj/item/organ/genital/proc/get_genital_color(obj/item/bodypart/limb)
	if(uses_skin_color)
		return limb?.draw_color || "#FFFFFF"
	var/list/features = owner?.dna?.features
	var/list/colors = port_get_feature_colors(features, slot)
	if(colors && colors[1])
		return "#[colors[1]]"
	if(features && features[FEATURE_MUTANT_COLOR])
		return "#[features[FEATURE_MUTANT_COLOR]]"
	return "#FFFFFF"

/// Whether clothing currently exposes this part.
/obj/item/organ/genital/proc/is_exposed()
	if(!ishuman(owner))
		return TRUE
	var/mob/living/carbon/human/human_owner = owner
	var/list/features = human_owner.dna?.features
	if(!islist(features) || !features["allow_genitals"])
		return FALSE
	switch(visibility_preference)
		if(GENITAL_ALWAYS_SHOW)
			return TRUE
		if(GENITAL_HIDDEN_BY_CLOTHES)
			return !human_owner.is_body_zone_covered(genital_location)
	return FALSE

// --- Penis -------------------------------------------------------------------

/obj/item/organ/genital/penis
	name = "penis"
	desc = "A male reproductive organ."
	icon = 'modular_bubber/icons/skyrat/obj/genitals/penis.dmi'
	icon_state = "penis"
	zone = BODY_ZONE_PRECISE_GROIN
	slot = ORGAN_SLOT_PENIS
	preference = "feature_penis"
	genital_location = GROIN
	bodypart_overlay = /datum/bodypart_overlay/mutant/genital/penis
	/// Circumference, in inches
	var/girth = 9
	/// SHEATH_NONE / SHEATH_NORMAL / SHEATH_SLIT
	var/sheath = SHEATH_NONE

/datum/bodypart_overlay/mutant/genital/penis
	feature_key = ORGAN_SLOT_PENIS
	layers = EXTERNAL_FRONT | EXTERNAL_BEHIND

/datum/bodypart_overlay/mutant/genital/penis/get_global_feature_list()
	return SSaccessories.genital_penis_list

/obj/item/organ/genital/penis/build_genital_from_dna(list/features, datum/sprite_accessory/genital/accessory)
	var/datum/sprite_accessory/genital/penis/penis_accessory = accessory
	girth = features["penis_girth"] || 9
	uses_skin_color = features["penis_uses_skincolor"]
	uses_skintones = features["penis_uses_skintones"] && accessory?.has_skintone_shading
	if(istype(penis_accessory) && penis_accessory.can_have_sheath)
		sheath = features["penis_sheath"] || SHEATH_NONE
	genital_size = features["penis_size"] || 1

/obj/item/organ/genital/penis/get_sprite_size_string()
	if(aroused != AROUSAL_FULL && sheath != SHEATH_NONE)
		var/poking_out = (aroused == AROUSAL_PARTIAL) ? 1 : 0
		return "[lowertext(sheath)]_[poking_out]"

	var/measured_size = FLOOR(genital_size, 1)
	var/is_erect = (aroused == AROUSAL_FULL) ? 1 : 0
	var/size_affix
	if(findtext(genital_name, "(Alt)"))
		switch(clamp(measured_size, 1, 100))
			if(1 to 10)
				size_affix = "1"
			if(11 to 20)
				size_affix = "2"
			if(21 to 30)
				size_affix = "3"
			if(31 to 40)
				size_affix = "4"
			if(41 to 50)
				size_affix = "5"
			if(51 to 61)
				size_affix = "6"
			else
				size_affix = "7"
	else
		switch(clamp(measured_size, 1, 100))
			if(1 to 8)
				size_affix = "1"
			if(9 to 15)
				size_affix = "2"
			if(16 to 24)
				size_affix = "3"
			else
				size_affix = "4"

	var/passed_string = "[genital_type]_[size_affix]_[is_erect]"
	if(uses_skintones)
		passed_string += "_s"
	return passed_string

// --- Testicles ---------------------------------------------------------------

/obj/item/organ/genital/testicles
	name = "testicles"
	desc = "A male reproductive organ."
	icon = 'modular_bubber/icons/skyrat/obj/genitals/testicles.dmi'
	icon_state = "testicles"
	zone = BODY_ZONE_PRECISE_GROIN
	slot = ORGAN_SLOT_TESTICLES
	preference = "feature_testicles"
	genital_location = GROIN
	aroused = AROUSAL_CANT
	bodypart_overlay = /datum/bodypart_overlay/mutant/genital/testicles

/datum/bodypart_overlay/mutant/genital/testicles
	feature_key = ORGAN_SLOT_TESTICLES
	layers = EXTERNAL_FRONT | EXTERNAL_BEHIND

/datum/bodypart_overlay/mutant/genital/testicles/get_global_feature_list()
	return SSaccessories.genital_testicles_list

/obj/item/organ/genital/testicles/build_genital_from_dna(list/features, datum/sprite_accessory/genital/accessory)
	uses_skin_color = features["testicles_uses_skincolor"]
	uses_skintones = features["testicles_uses_skintones"] && accessory?.has_skintone_shading
	genital_size = features["balls_size"] || 1

/obj/item/organ/genital/testicles/get_sprite_size_string()
	var/measured_size = FLOOR(genital_size, 1)
	var/max_size = TESTICLES_MAX_SIZE
	if(genital_name != "Pair (Alt)" && genital_name != "Sheathed Pair")
		max_size -= 2
	measured_size = clamp(measured_size, 0, max_size)
	var/passed_string = "[genital_type]_[measured_size]"
	if(uses_skintones)
		passed_string += "_s"
	return passed_string

// --- Vagina ------------------------------------------------------------------

/obj/item/organ/genital/vagina
	name = "vagina"
	desc = "A female reproductive organ."
	icon = 'modular_bubber/icons/skyrat/obj/genitals/vagina.dmi'
	icon_state = "vagina"
	zone = BODY_ZONE_PRECISE_GROIN
	slot = ORGAN_SLOT_VAGINA
	preference = "feature_vagina"
	genital_location = GROIN
	bodypart_overlay = /datum/bodypart_overlay/mutant/genital/vagina

/datum/bodypart_overlay/mutant/genital/vagina
	feature_key = ORGAN_SLOT_VAGINA
	layers = EXTERNAL_FRONT

/datum/bodypart_overlay/mutant/genital/vagina/get_global_feature_list()
	return SSaccessories.genital_vagina_list

/obj/item/organ/genital/vagina/build_genital_from_dna(list/features, datum/sprite_accessory/genital/accessory)
	uses_skin_color = features["vagina_uses_skincolor"]
	uses_skintones = features["vagina_uses_skintones"] && accessory?.has_skintone_shading

/obj/item/organ/genital/vagina/get_sprite_size_string()
	var/is_dripping = (aroused == AROUSAL_FULL) ? 1 : 0
	return "[genital_type]_[is_dripping]"

// --- Womb (internal, never drawn) --------------------------------------------

/obj/item/organ/genital/womb
	name = "womb"
	desc = "A female reproductive organ."
	icon = 'modular_bubber/icons/skyrat/obj/genitals/vagina.dmi'
	icon_state = "womb"
	zone = BODY_ZONE_PRECISE_GROIN
	slot = ORGAN_SLOT_WOMB
	preference = "feature_womb"
	genital_location = GROIN
	aroused = AROUSAL_CANT
	visibility_preference = GENITAL_SKIP_VISIBILITY
	bodypart_overlay = /datum/bodypart_overlay/mutant/genital/womb

/datum/bodypart_overlay/mutant/genital/womb
	feature_key = ORGAN_SLOT_WOMB
	layers = NONE

/datum/bodypart_overlay/mutant/genital/womb/get_global_feature_list()
	return SSaccessories.genital_womb_list

// --- Anus --------------------------------------------------------------------

/obj/item/organ/genital/anus
	name = "anus"
	desc = "What do you want me to tell you?"
	icon = 'modular_bubber/icons/skyrat/obj/genitals/anus.dmi'
	icon_state = "anus"
	zone = BODY_ZONE_PRECISE_GROIN
	slot = ORGAN_SLOT_ANUS
	preference = "feature_anus"
	genital_location = GROIN
	aroused = AROUSAL_CANT
	bodypart_overlay = /datum/bodypart_overlay/mutant/genital/anus

/datum/bodypart_overlay/mutant/genital/anus
	feature_key = ORGAN_SLOT_ANUS
	layers = EXTERNAL_FRONT

/datum/bodypart_overlay/mutant/genital/anus/get_global_feature_list()
	return SSaccessories.genital_anus_list

/obj/item/organ/genital/anus/get_sprite_size_string()
	return "[genital_type]"

// --- Breasts -----------------------------------------------------------------

/obj/item/organ/genital/breasts
	name = "breasts"
	desc = "Female milk producing organs."
	icon = 'modular_bubber/icons/skyrat/obj/genitals/breasts.dmi'
	icon_state = "breasts"
	zone = BODY_ZONE_CHEST
	slot = ORGAN_SLOT_BREASTS
	preference = "feature_breasts"
	genital_location = CHEST
	bodypart_overlay = /datum/bodypart_overlay/mutant/genital/breasts
	/// Breasts have a flat-chested (size 0) sprite, so keep drawing at 0.
	renders_at_zero = TRUE
	/// Whether these breasts produce milk
	var/lactates = FALSE

/datum/bodypart_overlay/mutant/genital/breasts
	feature_key = ORGAN_SLOT_BREASTS
	layers = EXTERNAL_FRONT | EXTERNAL_BEHIND

/datum/bodypart_overlay/mutant/genital/breasts/get_global_feature_list()
	return SSaccessories.genital_breasts_list

/obj/item/organ/genital/breasts/build_genital_from_dna(list/features, datum/sprite_accessory/genital/accessory)
	lactates = features["breasts_lactation"]
	uses_skin_color = features["breasts_uses_skincolor"]
	uses_skintones = features["breasts_uses_skintones"] && accessory?.has_skintone_shading
	var/breast_size = features["breasts_size"]
	genital_size = isnull(breast_size) ? 3 : breast_size

/obj/item/organ/genital/breasts/get_sprite_size_string()
	var/max_size = 0
	var/datum/sprite_accessory/genital/breasts/breasts_accessory = bodypart_overlay?.sprite_datum
	if(istype(breasts_accessory))
		max_size = breasts_accessory.max_size
	var/current_size = clamp(FLOOR(genital_size, 1), 0, max_size)
	var/passed_string = "[genital_type]_[current_size]"
	if(uses_skintones)
		passed_string += "_s"
	return passed_string

// --- Butt --------------------------------------------------------------------

/obj/item/organ/genital/butt
	name = "butt"
	desc = "You see a pair of asscheeks."
	icon = 'modular_bubber/icons/skyrat/obj/genitals/butt.dmi'
	icon_state = "butt"
	zone = BODY_ZONE_PRECISE_GROIN
	slot = ORGAN_SLOT_BUTT
	preference = "feature_butt"
	genital_location = GROIN
	aroused = AROUSAL_CANT
	bodypart_overlay = /datum/bodypart_overlay/mutant/genital/butt

/datum/bodypart_overlay/mutant/genital/butt
	feature_key = ORGAN_SLOT_BUTT
	layers = EXTERNAL_ADJACENT | EXTERNAL_FRONT

/datum/bodypart_overlay/mutant/genital/butt/get_global_feature_list()
	return SSaccessories.genital_butt_list

/obj/item/organ/genital/butt/build_genital_from_dna(list/features, datum/sprite_accessory/genital/accessory)
	uses_skin_color = features["butt_uses_skincolor"]
	uses_skintones = features["butt_uses_skintones"] && accessory?.has_skintone_shading
	var/butt_size = features["butt_size"]
	genital_size = isnull(butt_size) ? 1 : butt_size

/obj/item/organ/genital/butt/get_sprite_size_string()
	. = "[genital_type]_[FLOOR(genital_size, 1)]"
	if(uses_skintones)
		. += "_s"

// --- Belly -------------------------------------------------------------------

/obj/item/organ/genital/belly
	name = "belly"
	desc = "You see a belly on their midsection."
	icon = null
	icon_state = null
	zone = BODY_ZONE_CHEST
	slot = ORGAN_SLOT_BELLY
	preference = "feature_belly"
	genital_location = CHEST
	aroused = AROUSAL_CANT
	bodypart_overlay = /datum/bodypart_overlay/mutant/genital/belly

/datum/bodypart_overlay/mutant/genital/belly
	feature_key = ORGAN_SLOT_BELLY
	layers = EXTERNAL_FRONT | EXTERNAL_BEHIND

/datum/bodypart_overlay/mutant/genital/belly/get_global_feature_list()
	return SSaccessories.genital_belly_list

/obj/item/organ/genital/belly/build_genital_from_dna(list/features, datum/sprite_accessory/genital/accessory)
	uses_skin_color = features["belly_uses_skincolor"]
	uses_skintones = features["belly_uses_skintones"] && accessory?.has_skintone_shading
	var/belly_size = features["belly_size"]
	genital_size = isnull(belly_size) ? 1 : belly_size

/obj/item/organ/genital/belly/get_sprite_size_string()
	. = "[genital_type]_[FLOOR(genital_size, 1)]"
	if(uses_skintones)
		. += "_s"

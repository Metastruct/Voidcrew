// Generic "mutant" bodyparts for the ported anthro species (Anthromorph and variants).
//
// Bubber routes these species through /obj/item/bodypart/*/mutant, which draw from a
// pure-greyscale mammal sheet. The port used to fall back to the core human
// bodyparts_greyscale.dmi, whose art is warm-tinted even in its grey pixels, so tinting
// it with a near-white mutant colour came out pink. The neutral sheet renders the
// imported colours correctly.
//
// PORTED FROM: Bubberstation modular_skyrat/modules/bodyparts/code/_mutant_bodyparts.dm
// (BODYPART_ICON_MAMMAL = mammal_parts_greyscale.dmi).

#define MAMMAL_BODYPART_ICON 'modular_bubber/icons/skyrat/bodyparts/mammal_parts_greyscale.dmi'

/obj/item/bodypart/head/mutant
	icon_greyscale = MAMMAL_BODYPART_ICON
	limb_id = SPECIES_MAMMAL

/obj/item/bodypart/chest/mutant
	icon_greyscale = MAMMAL_BODYPART_ICON
	limb_id = SPECIES_MAMMAL
	is_dimorphic = TRUE

/obj/item/bodypart/arm/left/mutant
	icon_greyscale = MAMMAL_BODYPART_ICON
	limb_id = SPECIES_MAMMAL
	unarmed_attack_verbs = list("slash")
	unarmed_attack_effect = ATTACK_EFFECT_CLAW
	unarmed_attack_sound = 'sound/items/weapons/slash.ogg'
	unarmed_miss_sound = 'sound/items/weapons/slashmiss.ogg'

/obj/item/bodypart/arm/right/mutant
	icon_greyscale = MAMMAL_BODYPART_ICON
	limb_id = SPECIES_MAMMAL
	unarmed_attack_verbs = list("slash")
	unarmed_attack_effect = ATTACK_EFFECT_CLAW
	unarmed_attack_sound = 'sound/items/weapons/slash.ogg'
	unarmed_miss_sound = 'sound/items/weapons/slashmiss.ogg'

/obj/item/bodypart/leg/left/mutant
	icon_greyscale = MAMMAL_BODYPART_ICON
	limb_id = SPECIES_MAMMAL

/obj/item/bodypart/leg/right/mutant
	icon_greyscale = MAMMAL_BODYPART_ICON
	limb_id = SPECIES_MAMMAL

// Digitigrade variants using the same neutral sheet, so an Anthromorph's digitigrade
// legs aren't the (darker) lizard art. Species pick these via `digitigrade_*_type`.
/obj/item/bodypart/leg/left/digitigrade/mutant
	icon_greyscale = MAMMAL_BODYPART_ICON
	limb_id = BODYPART_ID_DIGITIGRADE
	bodyshape = BODYSHAPE_HUMANOID | BODYSHAPE_DIGITIGRADE
	footprint_sprite = FOOTPRINT_SPRITE_CLAWS
	footstep_type = FOOTSTEP_MOB_CLAW

/obj/item/bodypart/leg/left/digitigrade/mutant/update_limb(dropping_limb = FALSE, is_creating = FALSE)
	. = ..()
	limb_id = owner?.is_digitigrade_squished() ? SPECIES_MAMMAL : BODYPART_ID_DIGITIGRADE

/obj/item/bodypart/leg/right/digitigrade/mutant
	icon_greyscale = MAMMAL_BODYPART_ICON
	limb_id = BODYPART_ID_DIGITIGRADE
	bodyshape = BODYSHAPE_HUMANOID | BODYSHAPE_DIGITIGRADE
	footprint_sprite = FOOTPRINT_SPRITE_CLAWS
	footstep_type = FOOTSTEP_MOB_CLAW

/obj/item/bodypart/leg/right/digitigrade/mutant/update_limb(dropping_limb = FALSE, is_creating = FALSE)
	. = ..()
	limb_id = owner?.is_digitigrade_squished() ? SPECIES_MAMMAL : BODYPART_ID_DIGITIGRADE

/// Per-species digitigrade leg bodypart types. Defaults to the lizard art; ported
/// species point these at their own greyscale sheet.
/datum/species
	var/digitigrade_left_type = /obj/item/bodypart/leg/left/digitigrade
	var/digitigrade_right_type = /obj/item/bodypart/leg/right/digitigrade

#undef MAMMAL_BODYPART_ICON
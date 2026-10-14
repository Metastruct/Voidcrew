// MODsuit digitigrade worn-icon variants.
//
// PORTED FROM: Bubberstation commit 96c4b2efc06 "MODsuit Digitigrade and Muzzled
// Variants!" (#10273) and its current form in
// modular_skyrat/master_files/code/modules/mod/mod_clothes.dm. The art is the
// per-theme digitigrade chest/boot sprites from Bubber's mod.dmi (extracted here as
// modular_bubber/icons/skyrat/mob/clothing/modsuit/mod.dmi).
//
// Voidcrew's digitigrade clothing system auto-generates the leg portion through
// /obj/item/proc/generate_digitigrade_icons() when `supports_variations_flags` has
// CLOTHING_DIGITIGRADE_MASK. We flag the MOD chest/boots and feed the pre-drawn
// digitigrade variants through that. Themes with no entry fall back to the generic
// GAGS digitigrade legs (..()).

// Worn-icon variant vars, ported from Bubber's modular clothing base. Voidcrew only
// has the digitigrade mask path natively; snouted variants need our own var + handling
// in update_worn_head().
/obj/item
	/// Icon file for the worn overlay when the wearer has a muzzle/snout bodyshape.
	var/icon/worn_icon_muzzled

// The MOD helmet has a dedicated snouted/muzzled sprite in mod.dmi (the head
// states there are the muzzled variants). update_worn_head() picks it for snouted people.
/obj/item/clothing/head/mod
	supports_variations_flags = CLOTHING_SNOUTED_VARIATION
	worn_icon_muzzled = 'modular_bubber/icons/skyrat/mob/clothing/modsuit/mod.dmi'

/obj/item/clothing/suit/mod
	supports_variations_flags = CLOTHING_DIGITIGRADE_MASK

/obj/item/clothing/suit/mod/generate_digitigrade_icons(icon/base_icon, greyscale_colors)
	if(icon_exists('modular_bubber/icons/skyrat/mob/clothing/modsuit/mod.dmi', icon_state))
		return icon('modular_bubber/icons/skyrat/mob/clothing/modsuit/mod.dmi', icon_state)
	return ..()

/obj/item/clothing/shoes/mod
	supports_variations_flags = CLOTHING_DIGITIGRADE_MASK

/obj/item/clothing/shoes/mod/generate_digitigrade_icons(icon/base_icon, greyscale_colors)
	if(icon_exists('modular_bubber/icons/skyrat/mob/clothing/modsuit/mod.dmi', icon_state))
		return icon('modular_bubber/icons/skyrat/mob/clothing/modsuit/mod.dmi', icon_state)
	return ..()

// A worn MODsuit meshes its texture over the head/chest bodypart, so external organs
// drawn there (tails, and the like) look like they're under the suit. Ported from
// tgstation #97556; the mesh texture itself lives in
// code/datums/bodypart_overlays/modsuit_mesh.dm.
/obj/item/clothing/head/mod/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/equipment_bodypart_texture, BODY_ZONE_HEAD, /datum/bodypart_overlay/texture/mesh/space)

/obj/item/clothing/suit/mod/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/equipment_bodypart_texture, BODY_ZONE_CHEST, /datum/bodypart_overlay/texture/mesh/space)

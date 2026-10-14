// Shadekin bodyparts. Bubber shares one greyscale bodypart sheet between shadekin and
// a generic "mhuman" body, so we copy the whole sheet and select the limb_id.
//
// PORTED FROM: Bubberstation modular_zubbers/code/modules/surgery/bodyparts/species_parts/misc_bodyparts.dm

#define SHADEKIN_BODYPART_ICON 'modular_bubber/icons/zubbers/mob/species/human_parts_greyscale.dmi'
#define SHADEKIN_BRUTE_MODIFIER 1.2
#define SHADEKIN_BURN_MODIFIER 1.2

/obj/item/bodypart/head/shadekin
	icon_greyscale = SHADEKIN_BODYPART_ICON
	limb_id = SPECIES_SHADEKIN
	is_dimorphic = TRUE
	brute_modifier = SHADEKIN_BRUTE_MODIFIER
	burn_modifier = SHADEKIN_BURN_MODIFIER

/obj/item/bodypart/chest/shadekin
	icon_greyscale = SHADEKIN_BODYPART_ICON
	limb_id = SPECIES_SHADEKIN
	is_dimorphic = TRUE
	brute_modifier = SHADEKIN_BRUTE_MODIFIER
	burn_modifier = SHADEKIN_BURN_MODIFIER

/obj/item/bodypart/arm/left/shadekin
	icon_greyscale = SHADEKIN_BODYPART_ICON
	limb_id = SPECIES_SHADEKIN
	brute_modifier = SHADEKIN_BRUTE_MODIFIER
	burn_modifier = SHADEKIN_BURN_MODIFIER

/obj/item/bodypart/arm/right/shadekin
	icon_greyscale = SHADEKIN_BODYPART_ICON
	limb_id = SPECIES_SHADEKIN
	brute_modifier = SHADEKIN_BRUTE_MODIFIER
	burn_modifier = SHADEKIN_BURN_MODIFIER

/obj/item/bodypart/leg/left/shadekin
	icon_greyscale = SHADEKIN_BODYPART_ICON
	limb_id = SPECIES_SHADEKIN
	brute_modifier = SHADEKIN_BRUTE_MODIFIER
	burn_modifier = SHADEKIN_BURN_MODIFIER

/obj/item/bodypart/leg/right/shadekin
	icon_greyscale = SHADEKIN_BODYPART_ICON
	limb_id = SPECIES_SHADEKIN
	brute_modifier = SHADEKIN_BRUTE_MODIFIER
	burn_modifier = SHADEKIN_BURN_MODIFIER

#undef SHADEKIN_BODYPART_ICON
#undef SHADEKIN_BRUTE_MODIFIER
#undef SHADEKIN_BURN_MODIFIER

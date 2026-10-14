// Re-declares the core moth bodyparts so they use the ported greyscale sheet. Core moth
// art is pre-coloured, so imported mutant colours did not show up.
//
// PORTED FROM: Bubberstation modular_skyrat/modules/bodyparts/icons/moth_parts_greyscale.dmi

#define MOTH_BODYPART_ICON 'modular_bubber/icons/skyrat/bodyparts/moth_parts_greyscale.dmi'

/obj/item/bodypart/head/moth
	icon = MOTH_BODYPART_ICON
	icon_static = MOTH_BODYPART_ICON
	icon_greyscale = MOTH_BODYPART_ICON
	is_dimorphic = TRUE
	should_draw_greyscale = TRUE
	head_flags = HEAD_HAIR|HEAD_FACIAL_HAIR|HEAD_LIPS|HEAD_EYESPRITES|HEAD_EYEHOLES|HEAD_DEBRAIN|HEAD_EYECOLOR

/obj/item/bodypart/chest/moth
	icon = MOTH_BODYPART_ICON
	icon_static = MOTH_BODYPART_ICON
	icon_greyscale = MOTH_BODYPART_ICON
	should_draw_greyscale = TRUE

/obj/item/bodypart/arm/left/moth
	icon = MOTH_BODYPART_ICON
	icon_static = MOTH_BODYPART_ICON
	icon_greyscale = MOTH_BODYPART_ICON
	should_draw_greyscale = TRUE

/obj/item/bodypart/arm/right/moth
	icon = MOTH_BODYPART_ICON
	icon_static = MOTH_BODYPART_ICON
	icon_greyscale = MOTH_BODYPART_ICON
	should_draw_greyscale = TRUE

/obj/item/bodypart/leg/left/moth
	icon = MOTH_BODYPART_ICON
	icon_static = MOTH_BODYPART_ICON
	icon_greyscale = MOTH_BODYPART_ICON
	should_draw_greyscale = TRUE

/obj/item/bodypart/leg/right/moth
	icon = MOTH_BODYPART_ICON
	icon_static = MOTH_BODYPART_ICON
	icon_greyscale = MOTH_BODYPART_ICON
	should_draw_greyscale = TRUE

#undef MOTH_BODYPART_ICON

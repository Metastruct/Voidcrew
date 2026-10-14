// Teshari bodyparts, worn-clothing offsets and the hair-fit transform.
//
// PORTED FROM: Bubberstation modular_skyrat/modules/bodyparts/code/teshari_bodyparts.dm
// (the TESHARI_HAIR_FIT transform is our own work in that fork).

#define TESHARI_PUNCH_LOW 2
#define TESHARI_PUNCH_HIGH 6
#define TESHARI_BURN_MODIFIER 1.25
#define TESHARI_BRUTE_MODIFIER 1.2
#define TESHARI_BODYPART_ICON 'modular_bubber/icons/skyrat/bodyparts/teshari_parts_greyscale.dmi'

// The hair-fit constants live in modular_bubber/__DEFINES/teshari.dm.

/obj/item/bodypart/head/teshari
	icon_greyscale = TESHARI_BODYPART_ICON
	limb_id = SPECIES_TESHARI
	is_dimorphic = TRUE
	brute_modifier = TESHARI_BRUTE_MODIFIER
	burn_modifier = TESHARI_BURN_MODIFIER
	head_flags = HEAD_EYESPRITES|HEAD_EYECOLOR|HEAD_EYEHOLES|HEAD_DEBRAIN|HEAD_HAIR

/obj/item/bodypart/head/teshari/Initialize(mapload)
	worn_ears_offset = new(
		attached_part = src,
		feature_key = OFFSET_EARS,
		offset_y = list("north" = -4, "south" = -4, "east" = -4, "west" = -4),
	)
	worn_head_offset = new(
		attached_part = src,
		feature_key = OFFSET_HEAD,
		offset_x = list("north" = 1, "south" = 1, "east" = 1, "west" = -1, "northwest" = -1, "southwest" = -1, "northeast" = 1, "southeast" = 1),
		offset_y = list("north" = -4, "south" = -4, "east" = -4, "west" = -4),
	)
	worn_mask_offset = new(
		attached_part = src,
		feature_key = OFFSET_FACEMASK,
		offset_y = list("north" = -5, "south" = -5, "east" = -5, "west" = -5),
	)
	worn_face_offset = new(
		attached_part = src,
		feature_key = OFFSET_FACE,
		offset_y = list("north" = -5, "south" = -5, "east" = -5, "west" = -5),
	)
	return ..()

/obj/item/bodypart/head/teshari/get_hair_and_lips_icon(dropped)
	. = ..()
	if(isnull(hairstyle) || copytext(hairstyle, 1, 8) == "Teshari")
		return .
	var/matrix/hair_matrix = matrix(TESHARI_HAIR_SCALE_X, 0, TESHARI_HAIR_SHIFT_X, 0, 1, 0)
	// The list mixes /image (the hair itself) and /mutable_appearance (the gradient);
	// neither type covers the other, so scale both in separate passes.
	for(var/image/hair_overlay as anything in .)
		hair_overlay.transform = hair_matrix
		hair_overlay.appearance_flags |= PIXEL_SCALE
	for(var/mutable_appearance/gradient_overlay as anything in .)
		gradient_overlay.transform = hair_matrix
		gradient_overlay.appearance_flags |= PIXEL_SCALE
	return .

/obj/item/bodypart/chest/teshari
	icon_greyscale = TESHARI_BODYPART_ICON
	limb_id = SPECIES_TESHARI
	is_dimorphic = TRUE
	brute_modifier = TESHARI_BRUTE_MODIFIER
	burn_modifier = TESHARI_BURN_MODIFIER

/obj/item/bodypart/chest/teshari/Initialize(mapload)
	worn_back_offset = new(
		attached_part = src,
		feature_key = OFFSET_BACK,
		offset_y = list("north" = -4, "south" = -4, "east" = -4, "west" = -4),
	)
	return ..()

/obj/item/bodypart/arm/left/teshari
	icon_greyscale = TESHARI_BODYPART_ICON
	limb_id = SPECIES_TESHARI
	unarmed_damage_low = TESHARI_PUNCH_LOW
	unarmed_damage_high = TESHARI_PUNCH_HIGH
	brute_modifier = TESHARI_BRUTE_MODIFIER
	burn_modifier = TESHARI_BURN_MODIFIER

/obj/item/bodypart/arm/left/teshari/Initialize(mapload)
	held_hand_offset = new(
		attached_part = src,
		feature_key = OFFSET_HELD,
		offset_x = list("north" = 0, "south" = 0, "east" = 0, "west" = -6, "northwest" = -6, "southwest" = -6, "northeast" = 0, "southeast" = 0),
		offset_y = list("north" = -3, "south" = -3, "east" = -3, "west" = -3),
	)
	return ..()

/obj/item/bodypart/arm/right/teshari
	icon_greyscale = TESHARI_BODYPART_ICON
	limb_id = SPECIES_TESHARI
	unarmed_damage_low = TESHARI_PUNCH_LOW
	unarmed_damage_high = TESHARI_PUNCH_HIGH
	brute_modifier = TESHARI_BRUTE_MODIFIER
	burn_modifier = TESHARI_BURN_MODIFIER

/obj/item/bodypart/arm/right/teshari/Initialize(mapload)
	held_hand_offset = new(
		attached_part = src,
		feature_key = OFFSET_HELD,
		offset_x = list("north" = 0, "south" = 0, "east" = 6, "west" = 0, "northwest" = 0, "southwest" = 0, "northeast" = 6, "southeast" = 6),
		offset_y = list("north" = -3, "south" = -3, "east" = -3, "west" = -3),
	)
	return ..()

/obj/item/bodypart/leg/left/teshari
	icon_greyscale = TESHARI_BODYPART_ICON
	limb_id = SPECIES_TESHARI
	brute_modifier = TESHARI_BRUTE_MODIFIER
	burn_modifier = TESHARI_BURN_MODIFIER

/obj/item/bodypart/leg/right/teshari
	icon_greyscale = TESHARI_BODYPART_ICON
	limb_id = SPECIES_TESHARI
	brute_modifier = TESHARI_BRUTE_MODIFIER
	burn_modifier = TESHARI_BURN_MODIFIER

#undef TESHARI_PUNCH_LOW
#undef TESHARI_PUNCH_HIGH
#undef TESHARI_BURN_MODIFIER
#undef TESHARI_BRUTE_MODIFIER
#undef TESHARI_BODYPART_ICON

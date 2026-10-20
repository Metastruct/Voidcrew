// Metastruct: fit teshari leg sprites to non-teshari bodies.
//
// Teshari art is authored on an even-width grid; on any other species the legs sit a pixel
// off (an uneven gap on either side). The teshari hair fit (modular_bubber/__DEFINES/teshari.dm)
// converts odd-authored (generic) art to the even teshari grid with
//     matrix(0.95, 0, 0.475, 0, 1, 0)   // == matrix(s, 0, 0.5*s, 0, 1, 0), s = 0.95
// so going the other way (teshari legs -> odd body) is its inverse:
//     matrix(1/s, 0, -0.5, 0, 1, 0)
// hence a scale slightly above 1 and a half-pixel shift.
//
// BYOND applies one image's `transform` to every facing, so this scales the side views too.
// A true N/S-only fit would need a per-facing rebuild on turn, which isn't worth the cost.
//
// Only applies when the owner is not a teshari - teshari keep their own legs at native size.

#define TESHARI_LEG_FIT_SCALE_X (1 / 0.95)
#define TESHARI_LEG_FIT_SHIFT_X (-0.5)

/obj/item/bodypart/leg/left/teshari/get_limb_icon(dropped, mob/living/carbon/update_on)
	. = ..()
	if(!dropped && teshari_leg_needs_fit(owner))
		fit_teshari_legs(.)
	return .

/obj/item/bodypart/leg/left/teshari/generate_icon_key()
	. = ..()
	if(teshari_leg_needs_fit(owner))
		. += "teshari_leg_fit"
	return .

/obj/item/bodypart/leg/right/teshari/get_limb_icon(dropped, mob/living/carbon/update_on)
	. = ..()
	if(!dropped && teshari_leg_needs_fit(owner))
		fit_teshari_legs(.)
	return .

/obj/item/bodypart/leg/right/teshari/generate_icon_key()
	. = ..()
	if(teshari_leg_needs_fit(owner))
		. += "teshari_leg_fit"
	return .

/// TRUE when a teshari leg is worn by a non-teshari (and so needs the fit transform).
/proc/teshari_leg_needs_fit(mob/living/carbon/human/owner)
	return ishuman(owner) && owner.dna?.species?.id != SPECIES_TESHARI

/// Applies the teshari leg-fit transform to a leg's rendered overlays.
/proc/fit_teshari_legs(list/overlays)
	var/matrix/leg_matrix = matrix(TESHARI_LEG_FIT_SCALE_X, 0, TESHARI_LEG_FIT_SHIFT_X, 0, 1, 0)
	for(var/image/overlay as anything in overlays)
		overlay.transform = leg_matrix
		overlay.appearance_flags |= PIXEL_SCALE

#undef TESHARI_LEG_FIT_SCALE_X
#undef TESHARI_LEG_FIT_SHIFT_X

// Moth tweaks for the port. Declaring the species again here overrides these values
// without touching species_types/mothmen.dm.
//
// PORTED FROM: Bubberstation modular_skyrat moth customisation.

/datum/species/moth
	/// Lets the greyscale moth bodyparts be tinted with the character's mutant colour.
	inherent_traits = list(TRAIT_MUTANT_COLORS)
	mutant_organs = list(
		/obj/item/organ/wings/moth = "Plain",
		/obj/item/organ/antennae = "Plain",
		/obj/item/organ/fluff = SPRITE_ACCESSORY_NONE,
	)

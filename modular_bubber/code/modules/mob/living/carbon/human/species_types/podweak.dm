// Podperson ("weak") - the roundstart-selectable counterpart of Voidcrew's ghost-role
// Podperson. Modern Voidcrew already runs photosynthesis from the pod bodyparts'
// `photosynthesis` bodypart effect, so this is only the trait/eligibility delta.
//
// The advanced-tool-use traits Bubber lists here come from the standard brain organ in
// Voidcrew, so they are not repeated; `sort_bottom`/`always_customizable` are Bubber-only
// vars with no Voidcrew equivalent.
//
// PORTED FROM: Bubberstation modular_skyrat/modules/customization/modules/mob/living/carbon/human/species/podweak.dm

/datum/species/pod/podweak
	name = "Podperson"
	id = SPECIES_PODPERSON_WEAK
	examine_limb_id = SPECIES_PODPERSON
	inherent_traits = list(
		TRAIT_MUTANT_COLORS,
	)

/datum/species/pod/podweak/check_roundstart_eligible()
	return TRUE

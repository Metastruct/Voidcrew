// Teshari - small, feathered, agile birdpeople.
//
// PORTED FROM: Bubberstation modular_skyrat/modules/teshari/code/_teshari.dm
//
// The ears and tails are already in our ported accessory lists (bubber_ears.dm /
// bubber_tails.dm), so this only adds the species, its custom bodyparts and organs.

/datum/species/human/teshari
	name = "Teshari"
	plural_form = "Teshari"
	id = SPECIES_TESHARI
	inherent_traits = list(
		TRAIT_ADVANCEDTOOLUSER,
		TRAIT_CAN_STRIP,
		TRAIT_LITERATE,
		TRAIT_MUTANT_COLORS,
		TRAIT_NO_UNDERWEAR,
	)
	inherent_biotypes = MOB_ORGANIC | MOB_HUMANOID
	digitigrade_customization = DIGITIGRADE_NEVER

	mutantears = /obj/item/organ/ears/bubber
	mutant_organs = list(
		/obj/item/organ/tail/bubber = "Teshari (Default)",
	)

	bodypart_overrides = list(
		BODY_ZONE_HEAD = /obj/item/bodypart/head/teshari,
		BODY_ZONE_CHEST = /obj/item/bodypart/chest/teshari,
		BODY_ZONE_L_ARM = /obj/item/bodypart/arm/left/teshari,
		BODY_ZONE_R_ARM = /obj/item/bodypart/arm/right/teshari,
		BODY_ZONE_L_LEG = /obj/item/bodypart/leg/left/teshari,
		BODY_ZONE_R_LEG = /obj/item/bodypart/leg/right/teshari,
	)

	coldmod = 0.67
	heatmod = 1.3
	changesource_flags = MIRROR_BADMIN | WABBAJACK | MIRROR_MAGIC | MIRROR_PRIDE | ERT_SPAWN | RACE_SWAP | SLIME_EXTRACT
	payday_modifier = 1.0

/// Give the ears/tail features teshari defaults before the organs are created (ears have
/// no mutant_organs fallback, so a null value would crash the overlay on insert).
/datum/species/human/teshari/on_species_gain(mob/living/carbon/carbon_being, datum/species/old_species, pref_load, regenerate_icons)
	if(ishuman(carbon_being))
		var/mob/living/carbon/human/human = carbon_being
		if(isnull(human.dna.features[FEATURE_EARS]))
			human.dna.features[FEATURE_EARS] = "Teshari Regular"
		if(isnull(human.dna.features[FEATURE_TAIL_GENERIC]))
			human.dna.features[FEATURE_TAIL_GENERIC] = "Teshari (Default)"
	return ..()

/datum/species/human/teshari/randomize_features(mob/living/carbon/human/human_mob)
	var/list/features = ..()
	features[FEATURE_EARS] = pick("Teshari Regular", "Teshari Regular Alt", "Teshari Feathers Upright", "Teshari Feathers Bushy", "Teshari Feathers Pointy")
	features[FEATURE_TAIL_GENERIC] = "Teshari (Default)"
	features[FEATURE_MUTANT_COLOR] = pick("#c0965f", "#e4c49b", "#8fb3b8", "#d98f6f", "#b9c7a6")
	return features

/// Selectable at roundstart even without a config entry.
/datum/species/human/teshari/check_roundstart_eligible()
	return TRUE

/// Character-select preview: a feather-eared teshari.
/datum/species/human/teshari/prepare_human_for_preview(mob/living/carbon/human/human)
	human.dna.features[FEATURE_MUTANT_COLOR] = "#c0965f"
	human.dna.features[FEATURE_MUTANT_COLOR_TWO] = "#e4c49b"
	human.dna.features[FEATURE_MUTANT_COLOR_THREE] = "#e4c49b"
	human.dna.features[FEATURE_EARS] = "Teshari Feathers Upright"
	human.dna.features[FEATURE_TAIL_GENERIC] = "Teshari (Default)"
	regenerate_organs(human, src, visual_only = TRUE)
	human.update_body()

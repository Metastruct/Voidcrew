// Anthromorph - the generic anthro template species.
//
// Every player-facing "mammal" character on Bubber used this template or one of the
// species that derives from it (vulpkanin, tajaran, ...). It is a cosmetic variant of
// human with the ported external organs; no upstream mutant bodyparts are needed.
//
// PORTED FROM: modular_skyrat/modules/customization/.../species/mammal.dm (Bubberstation)

/datum/species/human/mammal
	name = "Anthromorph"
	id = SPECIES_MAMMAL
	examine_limb_id = SPECIES_HUMAN
	inherent_traits = list(
		TRAIT_MUTANT_COLORS,
	)
	inherent_biotypes = MOB_ORGANIC | MOB_HUMANOID

	// Ears are a "standard" organ slot, so they are granted via mutantears and need a
	// default feature (there is no mutant_organs fallback for that slot).
	mutantears = /obj/item/organ/ears/bubber

	// The rest are extra organs; the assoc value is the default sprite name. Bubber's
	// mammal defaults include all of these (mostly "None"), so they're native here too:
	// the "allow mismatched parts" toggle is for cross-species organs, not for a species'
	// own slots. Frills/spines/wings default to None and only draw when picked.
	mutant_organs = list(
		/obj/item/organ/tail/bubber = "Husky",
		/obj/item/organ/snout/bubber = "Husky",
		/obj/item/organ/horns/bubber = SPRITE_ACCESSORY_NONE,
		/obj/item/organ/frills = SPRITE_ACCESSORY_NONE,
		/obj/item/organ/spines = SPRITE_ACCESSORY_NONE,
		/obj/item/organ/fluff = SPRITE_ACCESSORY_NONE,
		/obj/item/organ/wings/moth = SPRITE_ACCESSORY_NONE,
	)

	digitigrade_customization = DIGITIGRADE_OPTIONAL
	// Digitigrade legs use the same neutral sheet, not the lizard art.
	digitigrade_left_type = /obj/item/bodypart/leg/left/digitigrade/mutant
	digitigrade_right_type = /obj/item/bodypart/leg/right/digitigrade/mutant
	// Draw from the ported neutral mammal bodypart sheet (see mutant_bodyparts.dm).
	bodypart_overrides = list(
		BODY_ZONE_HEAD = /obj/item/bodypart/head/mutant,
		BODY_ZONE_CHEST = /obj/item/bodypart/chest/mutant,
		BODY_ZONE_L_ARM = /obj/item/bodypart/arm/left/mutant,
		BODY_ZONE_R_ARM = /obj/item/bodypart/arm/right/mutant,
		BODY_ZONE_L_LEG = /obj/item/bodypart/leg/left/mutant,
		BODY_ZONE_R_LEG = /obj/item/bodypart/leg/right/mutant,
	)
	changesource_flags = MIRROR_BADMIN | WABBAJACK | MIRROR_MAGIC | MIRROR_PRIDE | ERT_SPAWN | RACE_SWAP | SLIME_EXTRACT
	payday_modifier = 1.0

/// Selectable at roundstart even without a config entry.
/datum/species/human/mammal/check_roundstart_eligible()
	return TRUE

/// Give the ears feature a value before the ears organ is created, so the overlay has
/// something to imprint (Bubber's species template defaulted to husky).
/datum/species/human/mammal/on_species_gain(mob/living/carbon/carbon_being, datum/species/old_species, pref_load, regenerate_icons)
	if(ishuman(carbon_being))
		// Ears default to Husky; the optional parts default to None so their organs aren't
		// created (and, for moth wings, don't grant flight) until the player picks one.
		ensure_default_features(carbon_being, list(
			FEATURE_EARS = "Husky",
			FEATURE_HORNS = SPRITE_ACCESSORY_NONE,
			FEATURE_FRILLS = SPRITE_ACCESSORY_NONE,
			FEATURE_SPINES = SPRITE_ACCESSORY_NONE,
			FEATURE_WINGS = SPRITE_ACCESSORY_NONE,
			FEATURE_MOTH_WINGS = SPRITE_ACCESSORY_NONE,
		), force = !pref_load)
	return ..()

/// The character-select preview: a wolf-looking Husky anthro. Without this the dummy
/// renders with a random mutant colour, so everything looked green.
/datum/species/human/mammal/prepare_human_for_preview(mob/living/carbon/human/human)
	human.dna.features[FEATURE_MUTANT_COLOR] = "#333333"
	human.dna.features[FEATURE_MUTANT_COLOR_TWO] = "#b8b8b8"
	human.dna.features[FEATURE_MUTANT_COLOR_THREE] = "#b8b8b8"
	human.dna.features[FEATURE_EARS] = "Husky"
	human.dna.features[FEATURE_SNOUT] = "Husky"
	human.dna.features[FEATURE_TAIL_GENERIC] = "Husky"
	regenerate_organs(human, src, visual_only = TRUE)
	human.update_body()

/// Fill in default features. When [force] is TRUE (a forced/admin species change, i.e.
/// not a preference load) the defaults overwrite whatever dna currently holds, so a
/// randomly-created mob doesn't keep another species' random features. A null feature
/// is always filled in, even on a preference load, so the organ overlay never crashes.
/datum/species/human/mammal/proc/ensure_default_features(mob/living/carbon/human/human, list/defaults, force = FALSE)
	for(var/feature_key in defaults)
		if(force || isnull(human.dna.features[feature_key]))
			human.dna.features[feature_key] = defaults[feature_key]

/// Set the three matrixed colours, used by subspecies' randomize_features().
/datum/species/human/mammal/proc/set_random_colors(list/features, main_color, second_color)
	features[FEATURE_MUTANT_COLOR] = main_color
	features[FEATURE_MUTANT_COLOR_TWO] = second_color
	features[FEATURE_MUTANT_COLOR_THREE] = second_color
	return features

/datum/species/human/mammal/randomize_features(mob/living/carbon/human/human_mob)
	var/list/features = ..()
	if(isnull(features[FEATURE_EARS]))
		features[FEATURE_EARS] = "Husky"
	// The optional parts are off by default; `randomize_features()` would otherwise pick
	// random frills/spines/wings for every randomly-generated Anthromorph.
	for(var/feature_key in list(FEATURE_HORNS, FEATURE_FRILLS, FEATURE_SPINES, FEATURE_WINGS, FEATURE_MOTH_WINGS))
		features[feature_key] = SPRITE_ACCESSORY_NONE
	return features

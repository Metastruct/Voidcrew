// Mammal variants ported from Bubberstation: Vulpkanin, Tajaran and the generic
// "Humanoid" template. They are cosmetic subspecies of Anthromorph, so they inherit
// its organs/limbs and only change default features, traits and colour palettes.
//
// PORTED FROM: modular_skyrat/modules/customization/.../species/{vulpkanin,tajaran,humanoid}.dm

// --- Vulpkanin ---------------------------------------------------------------

/datum/species/human/mammal/vulpkanin
	name = "Vulpkanin"
	plural_form = "Vulpkanin"
	id = SPECIES_VULPKANIN
	inherent_traits = list(
		TRAIT_ADVANCEDTOOLUSER,
		TRAIT_CAN_STRIP,
		TRAIT_LITERATE,
		TRAIT_MUTANT_COLORS,
		TRAIT_NIGHT_VISION,
	)
	inherent_biotypes = MOB_ORGANIC | MOB_HUMANOID
	// Horns/frills/spines are not native: they only appear via "allow mismatched parts".
	mutant_organs = list(
		/obj/item/organ/tail/bubber = "Fox",
		/obj/item/organ/snout/bubber = "Mammal, Long",
	)
	meat = /obj/item/food/meat/slab/corgi

/datum/species/human/mammal/vulpkanin/prepare_human_for_preview(mob/living/carbon/human/human)
	human.dna.features[FEATURE_MUTANT_COLOR] = "#FFAA00"
	human.dna.features[FEATURE_MUTANT_COLOR_TWO] = "#FFDD44"
	human.dna.features[FEATURE_MUTANT_COLOR_THREE] = "#FFDD44"
	human.dna.features[FEATURE_EARS] = "Fox"
	human.dna.features[FEATURE_SNOUT] = "Mammal, Long"
	human.dna.features[FEATURE_TAIL_GENERIC] = "Fox"
	regenerate_organs(human, src, visual_only = TRUE)
	human.update_body()

/datum/species/human/mammal/vulpkanin/on_species_gain(mob/living/carbon/carbon_being, datum/species/old_species, pref_load, regenerate_icons)
	if(ishuman(carbon_being))
		ensure_default_features(carbon_being, list(
			FEATURE_EARS = "Fox",
			FEATURE_TAIL_GENERIC = "Fox",
			FEATURE_SNOUT = "Mammal, Long",
		), force = !pref_load)
	return ..()

/datum/species/human/mammal/vulpkanin/randomize_features(mob/living/carbon/human/human_mob)
	var/list/features = ..()
	var/list/palette = list(
		list("#FFAA00", "#FFDD44"),
		list("#FF8833", "#FFAA33"),
		list("#FFCC22", "#FFDD88"),
		list("#FF8800", "#FFFFFF"),
		list("#999999", "#EEEEEE"),
	)
	var/list/pick = palette[rand(1, length(palette))]
	return set_random_colors(features, pick[1], pick[2])

// --- Tajaran -----------------------------------------------------------------

/datum/species/human/mammal/tajaran
	name = "Tajaran"
	plural_form = "Tajara"
	id = SPECIES_TAJARAN
	inherent_traits = list(
		TRAIT_ADVANCEDTOOLUSER,
		TRAIT_CAN_STRIP,
		TRAIT_LITERATE,
		TRAIT_HATED_BY_DOGS,
		TRAIT_MUTANT_COLORS,
	)
	inherent_biotypes = MOB_ORGANIC | MOB_HUMANOID
	mutant_organs = list(
		/obj/item/organ/tail/bubber = "Cat (Big)",
		/obj/item/organ/snout/bubber = "Mammal, Short",
	)

/datum/species/human/mammal/tajaran/prepare_human_for_preview(mob/living/carbon/human/human)
	human.dna.features[FEATURE_MUTANT_COLOR] = "#BBAA88"
	human.dna.features[FEATURE_MUTANT_COLOR_TWO] = "#AAAA99"
	human.dna.features[FEATURE_MUTANT_COLOR_THREE] = "#AAAA99"
	human.dna.features[FEATURE_EARS] = "Cat, normal"
	human.dna.features[FEATURE_SNOUT] = "Mammal, Short"
	human.dna.features[FEATURE_TAIL_GENERIC] = "Cat (Big)"
	regenerate_organs(human, src, visual_only = TRUE)
	human.update_body()

/datum/species/human/mammal/tajaran/on_species_gain(mob/living/carbon/carbon_being, datum/species/old_species, pref_load, regenerate_icons)
	if(ishuman(carbon_being))
		ensure_default_features(carbon_being, list(
			FEATURE_EARS = "Cat, normal",
			FEATURE_TAIL_GENERIC = "Cat (Big)",
			FEATURE_SNOUT = "Mammal, Short",
		), force = !pref_load)
	return ..()

/datum/species/human/mammal/tajaran/randomize_features(mob/living/carbon/human/human_mob)
	var/list/features = ..()
	var/list/palette = list(
		list("#BBAA88", "#AAAA99"),
		list("#777766", "#888877"),
		list("#AA9988", "#AAAA99"),
		list("#EEEEDD", "#FFEEEE"),
		list("#DDCC99", "#DDCCAA"),
	)
	var/list/pick = palette[rand(1, length(palette))]
	return set_random_colors(features, pick[1], pick[2])

// --- Humanoid (generic custom-species template) ------------------------------

/datum/species/human/mammal/humanoid
	name = "Humanoid"
	id = SPECIES_HUMANOID
	examine_limb_id = SPECIES_HUMAN
	inherent_traits = list(
		TRAIT_ADVANCEDTOOLUSER,
		TRAIT_CAN_STRIP,
		TRAIT_LITERATE,
		TRAIT_MUTANT_COLORS,
	)
	inherent_biotypes = MOB_ORGANIC | MOB_HUMANOID
	mutant_organs = list(
		/obj/item/organ/tail/bubber = SPRITE_ACCESSORY_NONE,
		/obj/item/organ/snout/bubber = SPRITE_ACCESSORY_NONE,
	)

/datum/species/human/mammal/humanoid/prepare_human_for_preview(mob/living/carbon/human/human)
	human.dna.features[FEATURE_MUTANT_COLOR] = "#722011"
	human.dna.features[FEATURE_MUTANT_COLOR_TWO] = "#722011"
	human.dna.features[FEATURE_MUTANT_COLOR_THREE] = "#722011"
	human.dna.features[FEATURE_EARS] = SPRITE_ACCESSORY_NONE
	human.dna.features[FEATURE_SNOUT] = SPRITE_ACCESSORY_NONE
	human.dna.features[FEATURE_TAIL_GENERIC] = SPRITE_ACCESSORY_NONE
	human.set_hairstyle("Cornrows", update = FALSE)
	human.hair_color = "#2b2b2b"
	regenerate_organs(human, src, visual_only = TRUE)
	human.update_body()

/datum/species/human/mammal/humanoid/on_species_gain(mob/living/carbon/carbon_being, datum/species/old_species, pref_load, regenerate_icons)
	if(ishuman(carbon_being))
		ensure_default_features(carbon_being, list(FEATURE_EARS = SPRITE_ACCESSORY_NONE), force = !pref_load)
	return ..()

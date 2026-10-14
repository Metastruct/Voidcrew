// Shadekin - pitch-darkness-made-flesh that regenerates in the dark.
//
// The ears and tail sprite accessories were already ported with the zubbers set, so this
// adds the species, its custom bodyparts, the dark-regeneration brain and the palette.
//
// PORTED FROM: Bubberstation modular_zubbers/code/modules/mob/living/carbon/human/species_types/shadekin.dm

/datum/species/human/shadekin
	name = "Shadekin"
	id = SPECIES_SHADEKIN
	inherent_traits = list(
		TRAIT_ADVANCEDTOOLUSER,
		TRAIT_CAN_STRIP,
		TRAIT_LITERATE,
		TRAIT_NODROWN,
		TRAIT_MUTANT_COLORS,
		TRAIT_NIGHT_VISION,
		TRAIT_NOBREATH,
	)
	inherent_biotypes = MOB_ORGANIC | MOB_HUMANOID
	digitigrade_customization = DIGITIGRADE_OPTIONAL

	mutantears = /obj/item/organ/ears/bubber
	mutantbrain = /obj/item/organ/brain/shadekin
	mutanteyes = /obj/item/organ/eyes/shadekin
	mutant_organs = list(
		/obj/item/organ/tail/bubber = "Shadekin",
	)

	bodypart_overrides = list(
		BODY_ZONE_HEAD = /obj/item/bodypart/head/shadekin,
		BODY_ZONE_CHEST = /obj/item/bodypart/chest/shadekin,
		BODY_ZONE_L_ARM = /obj/item/bodypart/arm/left/shadekin,
		BODY_ZONE_R_ARM = /obj/item/bodypart/arm/right/shadekin,
		BODY_ZONE_L_LEG = /obj/item/bodypart/leg/left/shadekin,
		BODY_ZONE_R_LEG = /obj/item/bodypart/leg/right/shadekin,
	)

	changesource_flags = MIRROR_BADMIN | WABBAJACK | MIRROR_MAGIC | MIRROR_PRIDE | ERT_SPAWN | RACE_SWAP | SLIME_EXTRACT
	payday_modifier = 1.0

/// Ears have no mutant_organs fallback, so default them before the organ is created.
/datum/species/human/shadekin/on_species_gain(mob/living/carbon/carbon_being, datum/species/old_species, pref_load, regenerate_icons)
	if(ishuman(carbon_being))
		var/mob/living/carbon/human/human = carbon_being
		if(isnull(human.dna.features[FEATURE_EARS]))
			human.dna.features[FEATURE_EARS] = "Shadekin"
		if(isnull(human.dna.features[FEATURE_TAIL_GENERIC]))
			human.dna.features[FEATURE_TAIL_GENERIC] = "Shadekin"
	return ..()

/datum/species/human/shadekin/randomize_features(mob/living/carbon/human/human_mob)
	var/list/features = ..()
	features[FEATURE_EARS] = pick("Shadekin", "Shadekin Short", "Shadekin Fluffy", "Shadekin Smooth")
	features[FEATURE_TAIL_GENERIC] = pick("Shadekin", "Shadekin Short")
	var/list/palette = list(
		list("#202020", "#505050", "#3f3f3f"),
		list("#CF3565", "#d93554", "#fbc2dd"),
		list("#FFC44D", "#FFE85F", "#FFF9D6"),
		list("#DB35DE", "#BE3AFE", "#F5E2EE"),
	)
	var/list/pick = palette[rand(1, length(palette))]
	features[FEATURE_MUTANT_COLOR] = pick[1]
	features[FEATURE_MUTANT_COLOR_TWO] = pick[2]
	features[FEATURE_MUTANT_COLOR_THREE] = pick[3]
	return features

/// Selectable at roundstart even without a config entry.
/datum/species/human/shadekin/check_roundstart_eligible()
	return TRUE

// --- Custom eyes -------------------------------------------------------------
// Shadekin eyes use their own art sheet, so `eye_icon` was added to the eyes organ.
// PORTED FROM: Bubberstation modular_zubbers/.../surgery/organs/internal/eyes.
/obj/item/organ/eyes/shadekin
	name = "shadekin eyes"
	desc = "These eyes are massive, and feel warm to the touch. The shadekin that's missing these is probably feeling very queasy."
	icon_state = "eyes_moth" // Bubber reuses the moth organ sprite
	eye_icon = 'modular_bubber/icons/zubbers/mob/human/human_face.dmi'
	eye_icon_state = "shadekin_eyes"
	flash_protect = FLASH_PROTECTION_SENSITIVE
	// Blinking works now that `eye_icon` reaches the eyelid effect; previously it looked
	// for shadekin_eyes_l/r in human_face.dmi and rendered an error icon (Bubber disabled
	// it in 5c525cbcb57d for that reason).
	blink_animation = TRUE
	iris_overlay = null
	lighting_cutoff = LIGHTING_CUTOFF_MEDIUM
	pupils_name = "slitted pupils"

// --- Dark regeneration -------------------------------------------------------

/obj/item/organ/brain/shadekin
	name = "shadekin brain"
	desc = "A mysterious brain, cold to the touch."
	icon_state = "brain-x-d"
	var/applied_status = /datum/status_effect/shadekin_regeneration

/obj/item/organ/brain/shadekin/on_life(seconds_per_tick, times_fired)
	. = ..()
	var/turf/owner_turf = owner?.loc
	if(!isturf(owner_turf))
		return
	if(owner_turf.get_lumcount() < SHADOW_SPECIES_LIGHT_THRESHOLD) // heal in the dark
		owner.apply_status_effect(applied_status)

/datum/status_effect/shadekin_regeneration
	id = "shadekin_regeneration"
	duration = 2 SECONDS
	status_type = STATUS_EFFECT_REFRESH
	alert_type = /atom/movable/screen/alert/status_effect/shadekin_regeneration

/datum/status_effect/shadekin_regeneration/on_apply()
	. = ..()
	if(!.)
		return FALSE
	heal_owner()
	return TRUE

/datum/status_effect/shadekin_regeneration/refresh(effect)
	. = ..()
	heal_owner()

/datum/status_effect/shadekin_regeneration/proc/heal_owner()
	owner.heal_overall_damage(brute = 0.5, burn = 0.5, required_bodytype = BODYTYPE_ORGANIC)

/atom/movable/screen/alert/status_effect/shadekin_regeneration
	name = "Dark Regeneration"
	desc = "Feeling the tug of home on your fur, some of its soothing warmth comes to ease your burdens."
	icon_state = "lightless"

/// Character-select preview: a dark shadekin with pale ears/tail.
/datum/species/human/shadekin/prepare_human_for_preview(mob/living/carbon/human/human)
	human.dna.features[FEATURE_MUTANT_COLOR] = "#222222"
	human.dna.features[FEATURE_MUTANT_COLOR_TWO] = "#b8b8b8"
	human.dna.features[FEATURE_MUTANT_COLOR_THREE] = "#b8b8b8"
	human.dna.features[FEATURE_EARS] = "Shadekin"
	human.dna.features[FEATURE_TAIL_GENERIC] = "Shadekin"
	human.set_eye_color("#5ec7e4")
	regenerate_organs(human, src, visual_only = TRUE)
	human.update_body()

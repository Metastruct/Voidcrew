// Synthetic Humanoid - ported from Bubberstation's `/datum/species/synthetic`.
//
// Built on Voidcrew's android (robotic bodyparts + organs, oil blood, synthetic
// language) so the body is properly robotic; it adds the ported IPC screen and antenna
// as external organs.
//
// PORTED FROM: Bubberstation modular_skyrat/modules/synths/code/species/synthetic.dm

/datum/species/android/synthetic
	name = "Synthetic Humanoid"
	id = SPECIES_SYNTH
	inherent_biotypes = MOB_ROBOTIC | MOB_HUMANOID
	inherent_traits = list(
		TRAIT_CAN_STRIP,
		TRAIT_ADVANCEDTOOLUSER,
		TRAIT_RADIMMUNE,
		TRAIT_NOBREATH,
		TRAIT_TOXIMMUNE,
		TRAIT_GENELESS,
		TRAIT_STABLEHEART,
		TRAIT_LIMBATTACHMENT,
		TRAIT_LITERATE,
		TRAIT_NOCRITDAMAGE,
		TRAIT_PIERCEIMMUNE,
	)
	// Real internal organs, unlike the bare android, so a removed organ has consequences
	// (EMP damage, reagent processing, hunger). Voidcrew's cybernetic organs already carry
	// the robotic versions of these behaviours.
	mutantheart = /obj/item/organ/heart/cybernetic
	mutantliver = /obj/item/organ/liver/cybernetic
	mutantlungs = /obj/item/organ/lungs/cybernetic
	mutantstomach = /obj/item/organ/stomach/cybernetic
	exotic_bloodtype = BLOOD_TYPE_OIL
	species_language_holder = /datum/language_holder/synthetic
	// Bubber parity: a synth natively owns the same generic part slots as an Anthromorph
	// (defaulting to None). Without these, imported synths silently lose their ears, tail,
	// snout, horns, frills, spines, wings and fluff unless the player also enabled the
	// "allow mismatched parts" toggle.
	mutantears = /obj/item/organ/ears/bubber
	mutant_organs = list(
		/obj/item/organ/synth_screen = SPRITE_ACCESSORY_NONE,
		/obj/item/organ/synth_antenna = SPRITE_ACCESSORY_NONE,
		/obj/item/organ/tail/bubber = SPRITE_ACCESSORY_NONE,
		/obj/item/organ/snout/bubber = SPRITE_ACCESSORY_NONE,
		/obj/item/organ/horns/bubber = SPRITE_ACCESSORY_NONE,
		/obj/item/organ/frills = SPRITE_ACCESSORY_NONE,
		/obj/item/organ/spines = SPRITE_ACCESSORY_NONE,
		/obj/item/organ/fluff = SPRITE_ACCESSORY_NONE,
		/obj/item/organ/wings/moth = SPRITE_ACCESSORY_NONE,
	)
	digitigrade_customization = DIGITIGRADE_OPTIONAL
	payday_modifier = 1.0

/// Selectable at roundstart even without a config entry.
/datum/species/android/synthetic/check_roundstart_eligible()
	return TRUE

/// Synth android heads can grow hair/facial hair like Bubber's synthetic head
/// (Bubber's `/obj/item/bodypart/head/synth` uses `HEAD_DEFAULT_FEATURES & ~HEAD_DEBRAIN`),
/// so players can give their IPC hair. The core robot head only ships `HEAD_EYESPRITES`.
/obj/item/bodypart/head/robot/android
	head_flags = HEAD_ALL_FEATURES & ~HEAD_DEBRAIN

/// Re-apply the selected chassis/head after `replace_body()` rebuilt the limbs.
/datum/species/android/synthetic/on_species_gain(mob/living/carbon/human/human_who_gained_species, datum/species/old_species, pref_load, regenerate_icons)
	. = ..()
	meta_apply_synth_chassis(human_who_gained_species)

/// Swap every synth bodypart to the selected chassis/head art. Chassis art sets every
/// non-head limb; the head set covers the head. `color_src` on the accessory means the
/// sheet is greyscale and should be tinted with the mutant colour; `dimorphic` selects
/// the `_m`/`_f` states.
/proc/meta_apply_synth_chassis(mob/living/carbon/human/human)
	if(!ishuman(human))
		return
	var/datum/species/android/synthetic/synth = human.dna?.species
	if(!istype(synth))
		return

	var/datum/sprite_accessory/synth_chassis/chassis = SSaccessories.synth_chassis_list[human.dna.features[FEATURE_SYNTH_CHASSIS]]
	var/datum/sprite_accessory/synth_head/head = SSaccessories.synth_head_list[human.dna.features[FEATURE_SYNTH_HEAD]]
	if(isnull(chassis) && isnull(head))
		return

	// Fall back to Bubber's default tint so a synth with no explicit colour doesn't
	// render the greyscale chassis/head sheets untinted.
	var/chassis_colour = human.dna.features["synth_chassis_color"] || DEFAULT_SYNTH_PART_COLOR
	var/head_colour = human.dna.features["synth_head_color"] || DEFAULT_SYNTH_PART_COLOR

	for(var/obj/item/bodypart/limb as anything in human.bodyparts)
		if(limb.body_zone == BODY_ZONE_HEAD)
			if(head)
				limb.change_appearance(head.icon, head.icon_state, !!head.color_src, head.dimorphic)
				if(head.color_src && istext(head_colour) && length(head_colour))
					limb.add_color_override(head_colour, META_LIMB_COLOR_SYNTH)
				else
					limb.remove_color_override(META_LIMB_COLOR_SYNTH)
				limb.update_draw_color()
			continue
		if(chassis)
			limb.change_appearance(chassis.icon, chassis.icon_state, !!chassis.color_src, limb.body_zone == BODY_ZONE_CHEST && chassis.dimorphic)
			limb.name = "\improper[chassis.name] [parse_zone(limb.body_zone)]"
			if(chassis.color_src && istext(chassis_colour) && length(chassis_colour))
				limb.add_color_override(chassis_colour, META_LIMB_COLOR_SYNTH)
			else
				limb.remove_color_override(META_LIMB_COLOR_SYNTH)
			limb.update_draw_color()
	human.update_body_parts()

/// Character-select preview: a synth with the default console screen.
/datum/species/android/synthetic/prepare_human_for_preview(mob/living/carbon/human/human)
	human.dna.features[FEATURE_SYNTH_SCREEN] = "Console"
	regenerate_organs(human, src, visual_only = TRUE)
	human.update_body()

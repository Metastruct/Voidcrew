// Metastruct: selectable leg styles.
//
// Lets a synth use digitigrade legs with *any* chassis, and adds a picker ("Legs Style")
// so a player can choose which species' legs to draw
// A style supplies both a plantigrade and a digitigrade type, so it follows the existing
// Normal/Digitigrade toggle.
//
// Mirrors Bubberstation's modular_zzmeta/modules/leg_styles.

/// DNA feature holding the chosen [GLOB.leg_styles] key. Separate from FEATURE_LEGS
/// (which stays a plain Normal/Digitigrade toggle) so existing legs logic is untouched.
#define FEATURE_LEG_STYLE "leg_style"

/// Use the species' own leg types (for synths: the chassis synth art).
#define LEG_STYLE_NATIVE "Native"
/// The slim organic lizard legs.
#define LEG_STYLE_ORGANIC "Organic Lizard"
#define LEG_STYLE_MAMMAL "Mammal"
#define LEG_STYLE_TESHARI "Teshari"
#define LEG_STYLE_SHADEKIN "Shadekin"

/// A selectable leg style.
/datum/leg_style
	/// The name shown in the dropdown and stored in [FEATURE_LEG_STYLE].
	var/name
	/// Plantigrade ("Normal") bodypart types. Null means "use the species' native legs".
	var/obj/item/bodypart/leg/left/left_type
	var/obj/item/bodypart/leg/right/right_type
	/// Digitigrade bodypart types. Null means "use the species' native digitigrade legs".
	var/obj/item/bodypart/leg/left/digitigrade_left_type
	var/obj/item/bodypart/leg/right/digitigrade_right_type
	/// Robotic (synth) overrides for the plantigrade/digitigrade types.
	var/obj/item/bodypart/leg/left/robot/android/synth_left_type
	var/obj/item/bodypart/leg/right/robot/android/synth_right_type
	var/obj/item/bodypart/leg/left/robot/android/digitigrade/synth_digitigrade_left_type
	var/obj/item/bodypart/leg/right/robot/android/digitigrade/synth_digitigrade_right_type
	/// Species that may pick this style without "Allow Mismatched Parts".
	var/list/recommended_species = list()

/// Which bodypart type this style uses for the given species/zone/mode. Null means "fall
/// back to the species' native type".
/datum/leg_style/proc/get_limb_type(datum/species/species, body_zone, digitigrade)
	var/is_synth = istype(species, /datum/species/android/synthetic)
	var/left = (body_zone == BODY_ZONE_L_LEG)

	var/obj/item/bodypart/leg/plantigrade_type
	if(left)
		plantigrade_type = (is_synth && synth_left_type) ? synth_left_type : left_type
	else
		plantigrade_type = (is_synth && synth_right_type) ? synth_right_type : right_type

	var/obj/item/bodypart/leg/digitigrade_type
	if(left)
		digitigrade_type = (is_synth && synth_digitigrade_left_type) ? synth_digitigrade_left_type : digitigrade_left_type
	else
		digitigrade_type = (is_synth && synth_digitigrade_right_type) ? synth_digitigrade_right_type : digitigrade_right_type

	// A style that only ships one of the two (e.g. "Organic Lizard" has no plantigrade
	// type, Teshari has no digitigrade type) applies what it has in either mode.
	if(digitigrade)
		return digitigrade_type || plantigrade_type
	return plantigrade_type || digitigrade_type

/datum/leg_style/native
	name = LEG_STYLE_NATIVE

/datum/leg_style/organic
	name = LEG_STYLE_ORGANIC
	digitigrade_left_type = /obj/item/bodypart/leg/left/digitigrade
	digitigrade_right_type = /obj/item/bodypart/leg/right/digitigrade
	synth_digitigrade_left_type = /obj/item/bodypart/leg/left/robot/android/digitigrade/organic
	synth_digitigrade_right_type = /obj/item/bodypart/leg/right/robot/android/digitigrade/organic
	recommended_species = list(SPECIES_SYNTH, SPECIES_LIZARD)

/datum/leg_style/mammal
	name = LEG_STYLE_MAMMAL
	left_type = /obj/item/bodypart/leg/left/mutant
	right_type = /obj/item/bodypart/leg/right/mutant
	digitigrade_left_type = /obj/item/bodypart/leg/left/digitigrade/mutant
	digitigrade_right_type = /obj/item/bodypart/leg/right/digitigrade/mutant
	recommended_species = list(SPECIES_MAMMAL)

/datum/leg_style/teshari
	name = LEG_STYLE_TESHARI
	left_type = /obj/item/bodypart/leg/left/teshari
	right_type = /obj/item/bodypart/leg/right/teshari
	recommended_species = list(SPECIES_TESHARI)

/datum/leg_style/shadekin
	name = LEG_STYLE_SHADEKIN
	left_type = /obj/item/bodypart/leg/left/shadekin
	right_type = /obj/item/bodypart/leg/right/shadekin
	recommended_species = list(SPECIES_SHADEKIN)

GLOBAL_LIST_INIT(leg_styles, build_leg_styles())

/proc/build_leg_styles()
	. = list()
	for(var/style_type in subtypesof(/datum/leg_style))
		var/datum/leg_style/style = new style_type
		.[style.name] = style

/proc/get_leg_style(style_name)
	return GLOB.leg_styles[style_name] || GLOB.leg_styles[LEG_STYLE_NATIVE]

/// TRUE if `human` uses the native (species/chassis) leg style. Used by the synth chassis
/// art pass, which only paints the chassis' digitigrade art for the native style.
/proc/port_leg_style_is_native(mob/living/carbon/human/human)
	var/style = human?.dna?.features[FEATURE_LEG_STYLE]
	return isnull(style) || style == LEG_STYLE_NATIVE

/// All styles, in the order they should appear in the dropdown with Native first.
/proc/get_all_leg_style_names()
	return list(
		LEG_STYLE_NATIVE,
		LEG_STYLE_ORGANIC,
		LEG_STYLE_MAMMAL,
		LEG_STYLE_TESHARI,
		LEG_STYLE_SHADEKIN,
	)

/// May this species pick this style? Native is always fine, but foreign styles need either a
/// species match or the "Allow Mismatched Parts" toggle.
/proc/is_leg_style_allowed(datum/species/species, style_name, mismatched)
	var/datum/leg_style/style = get_leg_style(style_name)
	if(style.name == LEG_STYLE_NATIVE)
		return TRUE
	if(species?.id in style.recommended_species)
		return TRUE
	return !!mismatched

/// Resolves the leg bodypart types for `target` from the selected style + the
/// Normal/Digitigrade toggle, always returning both leg zones (the species' native types
/// for the native style) so the caller can swap legs in either direction.
/proc/port_leg_style_overrides(datum/species/species, mob/living/carbon/human/target)
	var/list/overrides = list()
	if(isnull(species) || isnull(target?.dna))
		return overrides

	var/datum/leg_style/style = get_leg_style(target.dna.features[FEATURE_LEG_STYLE])
	var/digitigrade = (species.digitigrade_customization == DIGITIGRADE_FORCED) || (species.digitigrade_customization == DIGITIGRADE_OPTIONAL && target.dna.features[FEATURE_LEGS] == DIGITIGRADE_LEGS)

	for(var/body_zone in list(BODY_ZONE_L_LEG, BODY_ZONE_R_LEG))
		var/limb_type = style.get_limb_type(species, body_zone, digitigrade)
		// Native: the species' own base leg (plantigrade) or digitigrade type.
		if(!limb_type)
			if(digitigrade)
				limb_type = (body_zone == BODY_ZONE_L_LEG) ? species.digitigrade_left_type : species.digitigrade_right_type
			else
				limb_type = species.bodypart_overrides[body_zone]
		if(limb_type)
			overrides[body_zone] = limb_type

	return overrides

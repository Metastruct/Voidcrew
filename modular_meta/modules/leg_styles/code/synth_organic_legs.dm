// Metastruct: slim organic-lizard synth digitigrade legs.
//
// The synth's normal digitigrade bodypart draws the selected chassis' art (or the Mammal
// fallback). These subtypes instead use the slimmer organic lizard sprite (kept robotic so
// welder/cable-coil repairs still work) while inheriting every robotic behaviour from
// `/obj/item/bodypart/leg/*/robot/android/digitigrade`.

#define SYNTH_ORGANIC_DIGI_ICON 'icons/mob/human/species/lizard/bodyparts.dmi'
/// Plantigrade state this limb draws while `is_digitigrade_squished()`.
#define SYNTH_ORGANIC_SQUISHED_ID SPECIES_LIZARD

/obj/item/bodypart/leg/left/robot/android/digitigrade/organic
	icon_greyscale = SYNTH_ORGANIC_DIGI_ICON
	icon_static = SYNTH_ORGANIC_DIGI_ICON
	port_synth_squished_limb_id = SYNTH_ORGANIC_SQUISHED_ID

/obj/item/bodypart/leg/right/robot/android/digitigrade/organic
	icon_greyscale = SYNTH_ORGANIC_DIGI_ICON
	icon_static = SYNTH_ORGANIC_DIGI_ICON
	port_synth_squished_limb_id = SYNTH_ORGANIC_SQUISHED_ID

#undef SYNTH_ORGANIC_DIGI_ICON
#undef SYNTH_ORGANIC_SQUISHED_ID

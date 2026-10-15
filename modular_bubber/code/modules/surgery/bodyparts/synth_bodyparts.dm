// Synthetic (IPC) bodyparts: robotic digitigrade legs.
//
// The synth species uses Voidcrew's android robotic limbs, but those have no digitigrade
// variant, so selecting digitigrade legs on a synth fell back to the *organic* lizard
// `/obj/item/bodypart/leg/*/digitigrade` spot-welding them hurt, cable-coil repair didn't
// apply and bruise packs/ointment healed them. These subtypes keep the robotic
// bodytype/biological state (so the welder/cable repair loop recognises them) and draw the
// selected chassis' digitigrade art, applied by `port_apply_synth_chassis()`.
//
// PORTED FROM: Bubberstation modular_skyrat/modules/synths/code/bodyparts/limbs.dm
// (`/obj/item/bodypart/leg/*/synth/digitigrade`).

/// Fallback art for a synth digitigrade leg whose selected chassis ships no digitigrade
/// states (every chassis except Mammal/Lizard). Mirrors the "Mammal Chassis" accessory.
#define SYNTH_FALLBACK_DIGI_ICON 'modular_bubber/icons/skyrat/bodyparts/synthmammal_parts_greyscale.dmi'
#define SYNTH_FALLBACK_DIGI_ID "synthmammal"
/// Name of the chassis accessory whose art is reused for a digitigrade leg when the
/// selected chassis ships no digitigrade states.
#define SYNTH_FALLBACK_CHASSIS "Mammal Chassis"

// dm doesn't let left/right limbs share a parent, so the digitigrade legs are flagged on
// the base bodypart instead. `port_apply_synth_chassis()` checks these.
/obj/item/bodypart
	/// TRUE for the robotic synth digitigrade legs defined below.
	var/port_synth_digitigrade = FALSE
	/// Chassis icon_state this limb draws while `is_digitigrade_squished()` (clothing with
	/// no digitigrade variant covers the legs). Set by `port_apply_synth_chassis()`.
	var/port_synth_squished_limb_id

/obj/item/bodypart/leg/left/robot/android/digitigrade
	name = "android left leg"
	desc = "A custom digitigrade leg designed for androids, customizable to a degree your wallet agrees with."
	icon_greyscale = SYNTH_FALLBACK_DIGI_ICON
	icon_static = SYNTH_FALLBACK_DIGI_ICON
	limb_id = BODYPART_ID_DIGITIGRADE
	bodyshape = BODYSHAPE_HUMANOID | BODYSHAPE_DIGITIGRADE
	footprint_sprite = FOOTPRINT_SPRITE_CLAWS
	footstep_type = FOOTSTEP_MOB_CLAW
	should_draw_greyscale = TRUE
	port_synth_digitigrade = TRUE
	port_synth_squished_limb_id = SYNTH_FALLBACK_DIGI_ID

/obj/item/bodypart/leg/left/robot/android/digitigrade/update_limb(dropping_limb = FALSE, is_creating = FALSE)
	. = ..()
	limb_id = owner?.is_digitigrade_squished() ? port_synth_squished_limb_id : BODYPART_ID_DIGITIGRADE

/obj/item/bodypart/leg/right/robot/android/digitigrade
	name = "android right leg"
	desc = "A custom digitigrade leg designed for androids, customizable to a degree your wallet agrees with."
	icon_greyscale = SYNTH_FALLBACK_DIGI_ICON
	icon_static = SYNTH_FALLBACK_DIGI_ICON
	limb_id = BODYPART_ID_DIGITIGRADE
	bodyshape = BODYSHAPE_HUMANOID | BODYSHAPE_DIGITIGRADE
	footprint_sprite = FOOTPRINT_SPRITE_CLAWS
	footstep_type = FOOTSTEP_MOB_CLAW
	should_draw_greyscale = TRUE
	port_synth_digitigrade = TRUE
	port_synth_squished_limb_id = SYNTH_FALLBACK_DIGI_ID

/obj/item/bodypart/leg/right/robot/android/digitigrade/update_limb(dropping_limb = FALSE, is_creating = FALSE)
	. = ..()
	limb_id = owner?.is_digitigrade_squished() ? port_synth_squished_limb_id : BODYPART_ID_DIGITIGRADE

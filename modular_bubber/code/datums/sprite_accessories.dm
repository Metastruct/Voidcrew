// Extra vars on the sprite-accessory datums, declared here so the core
// code/datums/sprite_accessories.dm is left alone.

/// Set on tails that have a wagging animation. The tail organ checks it before
/// letting the wag emote through.
/datum/sprite_accessory/tails
	var/can_wag = FALSE

/// Moth wings are tinted with the wing colour. Core leaves this null, which dropped
/// imported wing colours.
/datum/sprite_accessory/moth_wings
	color_src = MUTANT_COLOR

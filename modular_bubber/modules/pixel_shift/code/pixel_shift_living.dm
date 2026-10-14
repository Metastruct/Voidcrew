// Core-proc hooks for the ported pixel-shift module.
//
// We prefer overriding procs here over editing upstream files, so this is the only
// place the port touches existing behaviour:
//   - CanAllowThrough() lets a sufficiently self-shifted mob be walked through from
//     the direction they shifted towards (so you can "stand against" a wall and let
//     people slip past instead of blocking the tile).
//   - set_pull_offsets()/reset_pull_offsets() fire a signal so the component can
//     revoke that passthrough privilege whenever a grab relationship changes.
//
// PORTED FROM: Bubberstation modular_skyrat/master_files/code/modules/mob/living/living.dm
//              Bubberstation modular_skyrat/master_files/code/modules/mob/living/living_movement.dm

/mob/living/CanAllowThrough(atom/movable/mover, border_dir)
	if(SEND_SIGNAL(src, COMSIG_LIVING_CAN_ALLOW_THROUGH, mover, border_dir) & COMPONENT_LIVING_PASSABLE)
		return TRUE
	return ..()

/mob/living/set_pull_offsets(mob/living/pull_target, grab_state = GRAB_PASSIVE, animate = TRUE)
	. = ..()
	SEND_SIGNAL(pull_target, COMSIG_LIVING_SET_PULL_OFFSET)

/mob/living/reset_pull_offsets(mob/living/pull_target, override)
	. = ..()
	SEND_SIGNAL(pull_target, COMSIG_LIVING_RESET_PULL_OFFSETS)

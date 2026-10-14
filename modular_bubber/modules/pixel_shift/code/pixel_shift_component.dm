// Pixel-shift component - lets a living mob nudge their own sprite (and, on a second
// keybind, the item or mob they're pulling) around inside their tile for RP poses,
// and lets them tilt their sprite a few degrees.
//
// When a mob has shifted far enough towards a tile edge they become "passthroughable"
// from that direction, so players can step past someone hugging a wall - see the
// CanAllowThrough hook in pixel_shift_living.dm.
//
// Ported from Bubberstation / Skyrat, including the later fixes:
//   - shifting a grabbed/pulled mob instead of only items,
//   - translating the shift onto anyone buckled to us (riders/piggyback),
//   - only making grabbed/pulled mobs passthroughable through walls when they have
//     actually been shifted far enough, and re-validating that on grab changes.
//
// PORTED FROM: Bubberstation modular_skyrat/modules/pixel_shift/code/pixel_shift_component.dm

#define SHIFTING_ITEMS 1
#define SHIFTING_PARENT 2
#define TILTING_PARENT 3
/// Offset source key used when translating our shift onto anyone buckled to us.
#define PIXEL_SHIFT_BUCKLE_OFFSET "pixel_shift_buckled"
/// Offset source key used when nudging a pulled mob's position.
#define PIXEL_SHIFT_PULLED_OFFSET "pixel_shift_pulled"

/datum/component/pixel_shift
	dupe_mode = COMPONENT_DUPE_UNIQUE
	//whether or not parent is shifting
	var/shifting = FALSE
	//how tilted the parent is
	var/how_tilted
	//the maximum amount of tilt parent can achieve
	var/maximum_tilt = 45
	//the maximum amount we/an item can move
	var/maximum_pixel_shift = 16
	//If we are shifted
	var/is_shifted = FALSE
	//Amount of shift in the X axis
	var/shift_x = 0
	//Amount of shift in the Y axis
	var/shift_y = 0
	//Allows atoms entering Parent's turf to pass through freely from given directions
	var/passthroughable = NONE
	//Amount of shifting necessary to make the parent passthroughable
	var/passthrough_threshold = 8
	/// The mob we're currently nudging via SHIFTING_ITEMS, if any.
	var/mob/living/pulled_shift_target
	/// Amount of shift we've applied to pulled_shift_target on the X axis
	var/pulled_shift_x = 0
	/// Amount of shift we've applied to pulled_shift_target on the Y axis
	var/pulled_shift_y = 0
	/// Allows atoms entering pulled_shift_target's turf to pass through freely from given directions, same as passthroughable but for the mob we're nudging
	var/pulled_passthroughable = NONE

/datum/component/pixel_shift/Initialize(...)
	. = ..()
	if(!isliving(parent))
		return COMPONENT_INCOMPATIBLE

/datum/component/pixel_shift/Destroy(force)
	reset_pulled_shift()
	return ..()

/datum/component/pixel_shift/RegisterWithParent()
	RegisterSignal(parent, COMSIG_KB_LIVING_ITEM_PIXEL_SHIFT_DOWN, PROC_REF(item_pixel_shift_down))
	RegisterSignal(parent, COMSIG_KB_LIVING_ITEM_PIXEL_SHIFT_UP, PROC_REF(item_pixel_shift_up))
	RegisterSignal(parent, COMSIG_KB_LIVING_PIXEL_SHIFT_DOWN, PROC_REF(pixel_shift_down))
	RegisterSignal(parent, COMSIG_KB_LIVING_PIXEL_SHIFT_UP, PROC_REF(pixel_shift_up))
	RegisterSignal(parent, COMSIG_KB_LIVING_PIXEL_TILT_DOWN, PROC_REF(pixel_tilt_down))
	RegisterSignal(parent, COMSIG_KB_LIVING_PIXEL_TILT_UP, PROC_REF(pixel_tilt_up))
	// Grab start/upgrade/release used to also fire the full unpixel_shift() on whoever gets grabbed,
	// snapping their shift/tilt back to zero. Keep the visual transform instead, but still force the
	// passthrough privilege to re-validate on any grab-relationship change (mirroring how movement
	// re-validates it). Otherwise a stale self-shift can be kept alive forever by getting grabbed and
	// never moving again, letting others walk through a doorway that shouldn't still be passable.
	RegisterSignals(parent, list(COMSIG_LIVING_RESET_PULL_OFFSETS, COMSIG_LIVING_SET_PULL_OFFSET), PROC_REF(clear_own_passthrough))
	RegisterSignal(parent, COMSIG_MOVABLE_MOVED, PROC_REF(unpixel_shift))
	RegisterSignal(parent, COMSIG_MOB_CLIENT_PRE_LIVING_MOVE, PROC_REF(pre_move_check))
	RegisterSignal(parent, COMSIG_LIVING_CAN_ALLOW_THROUGH, PROC_REF(check_passable))
	RegisterSignal(parent, COMSIG_MOVABLE_BUCKLE, PROC_REF(on_parent_buckle))
	RegisterSignal(parent, COMSIG_MOVABLE_UNBUCKLE, PROC_REF(on_parent_unbuckle))

/datum/component/pixel_shift/UnregisterFromParent()
	UnregisterSignal(parent, list(
		COMSIG_KB_LIVING_ITEM_PIXEL_SHIFT_DOWN,
		COMSIG_KB_LIVING_ITEM_PIXEL_SHIFT_UP,
		COMSIG_KB_LIVING_PIXEL_TILT_DOWN,
		COMSIG_KB_LIVING_PIXEL_TILT_UP,
		COMSIG_KB_LIVING_PIXEL_SHIFT_DOWN,
		COMSIG_KB_LIVING_PIXEL_SHIFT_UP,
		COMSIG_MOB_CLIENT_PRE_LIVING_MOVE,
		COMSIG_LIVING_RESET_PULL_OFFSETS,
		COMSIG_LIVING_SET_PULL_OFFSET,
		COMSIG_MOVABLE_MOVED,
		COMSIG_LIVING_CAN_ALLOW_THROUGH,
		COMSIG_MOVABLE_BUCKLE,
		COMSIG_MOVABLE_UNBUCKLE,
	))

//locks our movement when holding our keybinds
/datum/component/pixel_shift/proc/pre_move_check(mob/source, new_loc, direct)
	SIGNAL_HANDLER
	if(shifting)
		pixel_shift(source, direct)
		return COMSIG_MOB_CLIENT_BLOCK_PRE_LIVING_MOVE

//procs for tilting parent

/datum/component/pixel_shift/proc/pixel_tilt_down()
	SIGNAL_HANDLER
	shifting = TILTING_PARENT
	return COMSIG_KB_ACTIVATED

/datum/component/pixel_shift/proc/pixel_tilt_up()
	SIGNAL_HANDLER
	shifting = FALSE

//Procs for shifting items

/datum/component/pixel_shift/proc/item_pixel_shift_down()
	SIGNAL_HANDLER
	shifting = SHIFTING_ITEMS
	return COMSIG_KB_ACTIVATED

/datum/component/pixel_shift/proc/item_pixel_shift_up()
	SIGNAL_HANDLER
	shifting = FALSE

//Procs for shifting mobs

/// Checks if the parent is considered passthroughable from a direction. Projectiles will ignore the check and hit.
/datum/component/pixel_shift/proc/check_passable(mob/source, atom/movable/mover, border_dir)
	SIGNAL_HANDLER
	if(isprojectile(mover) || mover.throwing)
		return
	// This same handler is also registered on pulled_shift_target (see pixel_shift()), so a mob we're
	// nudging around gets the identical border-crossing check a self-shifted mob gets, instead of none at all.
	var/relevant_passthroughable = (source == pulled_shift_target) ? pulled_passthroughable : passthroughable
	if(relevant_passthroughable & border_dir)
		return COMPONENT_LIVING_PASSABLE

/// Revokes our own passthrough privilege on any grab-relationship change, without touching the visual shift/tilt. See RegisterWithParent for why.
/datum/component/pixel_shift/proc/clear_own_passthrough()
	SIGNAL_HANDLER
	passthroughable = NONE

/// Activates Pixel Shift on Keybind down. Only Pixel Shift movement will be allowed.
/datum/component/pixel_shift/proc/pixel_shift_down()
	SIGNAL_HANDLER
	shifting = SHIFTING_PARENT
	return COMSIG_KB_ACTIVATED

/// Disables Pixel Shift on Keybind up. Allows to Move.
/datum/component/pixel_shift/proc/pixel_shift_up()
	SIGNAL_HANDLER
	shifting = FALSE

/// Sets parent pixel offsets to default and deletes the component.
/datum/component/pixel_shift/proc/unpixel_shift()
	SIGNAL_HANDLER
	passthroughable = NONE
	if(is_shifted)
		var/mob/living/owner = parent
		owner.remove_offsets(type)
		owner.transform = turn(owner.transform, -how_tilted)
		for(var/mob/living/buckled_mob as anything in owner.buckled_mobs)
			buckled_mob.remove_offsets(PIXEL_SHIFT_BUCKLE_OFFSET)
		is_shifted = FALSE
		how_tilted = 0
		shift_x = 0
		shift_y = 0
	// Keep the component (and its nudge on pulled_shift_target) alive across our own movement;
	// the nudge is only supposed to clear when the pulled mob itself moves, see on_pulled_target_moved.
	if(!pulled_shift_target)
		qdel(src)

/// Mirrors our current shift onto everyone buckled to us, so a rider (piggyback) or someone we're fireman carrying moves with our pixel shift instead of visually detaching from us.
/datum/component/pixel_shift/proc/translate_shift_to_buckled()
	var/mob/living/owner = parent
	for(var/mob/living/buckled_mob as anything in owner.buckled_mobs)
		buckled_mob.add_offsets(PIXEL_SHIFT_BUCKLE_OFFSET, x_add = shift_x, y_add = shift_y)

/// Applies our current shift the instant someone gets buckled to us mid-shift.
/datum/component/pixel_shift/proc/on_parent_buckle(atom/movable/source, mob/living/buckled_mob, force)
	SIGNAL_HANDLER
	if(is_shifted)
		buckled_mob.add_offsets(PIXEL_SHIFT_BUCKLE_OFFSET, x_add = shift_x, y_add = shift_y)

/// Cleans our translated offset off a mob once they're no longer buckled to us.
/datum/component/pixel_shift/proc/on_parent_unbuckle(atom/movable/source, mob/living/buckled_mob, force)
	SIGNAL_HANDLER
	buckled_mob.remove_offsets(PIXEL_SHIFT_BUCKLE_OFFSET)

/// Clears any nudge we've applied to whatever mob we were last pulling and shifting.
/datum/component/pixel_shift/proc/reset_pulled_shift()
	if(!pulled_shift_target)
		return
	UnregisterSignal(pulled_shift_target, list(COMSIG_MOVABLE_MOVED, COMSIG_LIVING_CAN_ALLOW_THROUGH))
	pulled_shift_target.remove_offsets(PIXEL_SHIFT_PULLED_OFFSET)
	pulled_shift_target = null
	pulled_shift_x = 0
	pulled_shift_y = 0
	pulled_passthroughable = NONE

/// Snaps a pulled mob's nudge back off once they take a real step under their own power, so they don't look permanently off-tile.
/datum/component/pixel_shift/proc/on_pulled_target_moved()
	SIGNAL_HANDLER
	reset_pulled_shift()

/// Returns which directions become passthroughable for the given shift amounts. Shared by our own shift and pulled_shift_target's, so both get identical treatment.
/datum/component/pixel_shift/proc/get_passthrough_flags(x, y)
	. = NONE
	if(y > passthrough_threshold)
		. |= EAST | SOUTH | WEST
	else if(y < -passthrough_threshold)
		. |= NORTH | EAST | WEST
	if(x > passthrough_threshold)
		. |= NORTH | SOUTH | WEST
	else if(x < -passthrough_threshold)
		. |= NORTH | EAST | SOUTH

/// In-turf pixel movement which can allow things to pass through if the threshold is met.
/datum/component/pixel_shift/proc/pixel_shift(mob/source, direct)
	passthroughable = NONE
	var/mob/living/owner = parent
	switch(shifting)
		if(SHIFTING_ITEMS)
			var/atom/pulled_atom = source.pulling
			if(isitem(pulled_atom))
				var/obj/item/pulled_item = pulled_atom
				switch(direct)
					if(NORTH)
						if(pulled_item.pixel_y <= maximum_pixel_shift + pulled_item.base_pixel_y)
							pulled_item.pixel_y++
					if(EAST)
						if(pulled_item.pixel_x <= maximum_pixel_shift + pulled_item.base_pixel_x)
							pulled_item.pixel_x++
					if(SOUTH)
						if(pulled_item.pixel_y >= -maximum_pixel_shift + pulled_item.base_pixel_y)
							pulled_item.pixel_y--
					if(WEST)
						if(pulled_item.pixel_x >= -maximum_pixel_shift + pulled_item.base_pixel_x)
							pulled_item.pixel_x--
			else if(isliving(pulled_atom))
				var/mob/living/pulled_mob = pulled_atom
				if(pulled_mob != pulled_shift_target)
					reset_pulled_shift()
					pulled_shift_target = pulled_mob
					RegisterSignal(pulled_mob, COMSIG_MOVABLE_MOVED, PROC_REF(on_pulled_target_moved))
					RegisterSignal(pulled_mob, COMSIG_LIVING_CAN_ALLOW_THROUGH, PROC_REF(check_passable))
				switch(direct)
					if(NORTH)
						if(pulled_shift_y <= maximum_pixel_shift)
							pulled_shift_y++
					if(EAST)
						if(pulled_shift_x <= maximum_pixel_shift)
							pulled_shift_x++
					if(SOUTH)
						if(pulled_shift_y >= -maximum_pixel_shift)
							pulled_shift_y--
					if(WEST)
						if(pulled_shift_x >= -maximum_pixel_shift)
							pulled_shift_x--
				pulled_mob.add_offsets(PIXEL_SHIFT_PULLED_OFFSET, x_add = pulled_shift_x, y_add = pulled_shift_y)
		if(SHIFTING_PARENT)
			switch(direct)
				if(NORTH)
					if(shift_y <= maximum_pixel_shift)
						shift_y++
						owner.add_offsets(type, y_add = shift_y)
						is_shifted = TRUE
				if(EAST)
					if(shift_x <= maximum_pixel_shift)
						shift_x++
						owner.add_offsets(type, x_add = shift_x)
						is_shifted = TRUE
				if(SOUTH)
					if(shift_y >= -maximum_pixel_shift)
						shift_y--
						owner.add_offsets(type, y_add = shift_y)
						is_shifted = TRUE
				if(WEST)
					if(shift_x >= -maximum_pixel_shift)
						shift_x--
						owner.add_offsets(type, x_add = shift_x)
						is_shifted = TRUE
			translate_shift_to_buckled()
		if(TILTING_PARENT)
			switch(direct)
				if(EAST)
					if(how_tilted <= maximum_tilt)
						owner.transform = turn(owner.transform, 1)
						how_tilted++
						is_shifted = TRUE
				if(WEST)
					if(how_tilted >= -maximum_tilt)
						owner.transform = turn(owner.transform, -1)
						how_tilted--
						is_shifted = TRUE

	// Yes, I know this sets it to true for everything if more than one is matched.
	// Movement doesn't check diagonals, and instead just checks EAST or WEST, depending on where you are for those.
	passthroughable |= get_passthrough_flags(shift_x, shift_y)
	// Same passthrough treatment for whoever we're nudging, so grabbing+shifting someone doesn't skip
	// the check a self-shifted mob gets.
	if(pulled_shift_target)
		pulled_passthroughable = get_passthrough_flags(pulled_shift_x, pulled_shift_y)

#undef SHIFTING_ITEMS
#undef SHIFTING_PARENT
#undef TILTING_PARENT
#undef PIXEL_SHIFT_BUCKLE_OFFSET
#undef PIXEL_SHIFT_PULLED_OFFSET

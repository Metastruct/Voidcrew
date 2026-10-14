// "Drop Item (Specific)" - drop the held item where the mouse cursor is, within
// reach, with a pixel offset instead of snapping to the tile centre. Pairs with
// the pixel-shift module (nudge an item, then place another precisely next to it).
//
// Ported from upstream /tg/ PR #93790 ("Adds a keybind for 'precise' dropping
// (like SS14)"), which Voidcrew predates. It relies on the one-line core hook in
// code/modules/keybindings/bindings_client.dm that forwards the mouse-offset
// residuals from get_loc_from_mousepos(); without that hook mousepos_x/y are 0
// and this degrades to a normal drop.
//
// PORTED FROM: tgstation code/datums/keybinding/mob.dm

/datum/keybinding/mob/drop_item_specific
	hotkey_keys = list("CtrlX")
	name = "drop_item_specific"
	full_name = "Drop Item (Specific)"
	description = "Drops the item in your active hand where your mouse cursor is, if in range."
	keybind_signal = COMSIG_KB_MOB_DROPITEM_DOWN

/datum/keybinding/mob/drop_item_specific/down(client/user, turf/target, mousepos_x, mousepos_y)
	. = ..()
	if(.)
		return
	if(iscyborg(user.mob)) //cyborgs can't drop items
		return FALSE
	var/mob/user_mob = user.mob
	var/obj/item/item_dropped = user_mob.get_active_held_item()
	if(!item_dropped)
		to_chat(user, span_warning("You have nothing to drop in your hand!"))
		return TRUE
	if(!target || !user_mob.Adjacent(target) || target.is_blocked_turf(source_atom = item_dropped))
		return TRUE
	var/x_value = (mousepos_x >= 0) ? mousepos_x - ICON_SIZE_X / 2 : mousepos_x + ICON_SIZE_X / 2
	var/y_value = (mousepos_y >= 0) ? mousepos_y - ICON_SIZE_Y / 2 : mousepos_y + ICON_SIZE_Y / 2
	user_mob.transfer_item_to_turf(item_dropped, target, x_value, y_value)
	return TRUE

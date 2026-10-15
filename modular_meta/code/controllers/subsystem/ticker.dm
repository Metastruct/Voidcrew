// Ticker overrides for the commit announcer, ported from Bubber's modular_zzmeta.
//
// - fire(): core only refreshes the "Server rebooting in:" HUD while current_state is
//   GAME_STATE_FINISHED, so a reboot_timer started mid-round (eg. the "Reboot World"
//   admin verb) never gets shown. Cover that case here instead of touching core's
//   fire() switch.
// - Reboot(): recap the commits landed this round as soon as a reboot starts counting
//   down (see announce_pending_commits()).
// - reboot_callback(): clear them once the reboot actually fires.
//
// PORTED FROM: Bubberstation modular_zzmeta/code/controllers/subsystem/ticker.dm

/datum/controller/subsystem/ticker/fire()
	. = ..()
	if(current_state == GAME_STATE_FINISHED)
		return
	if(!isnull(reboot_timer))
		if(isnull(reboot_hud))
			reboot_hud = new()
		for(var/client/C in GLOB.clients)
			if(!(reboot_hud in C.screen))
				C.screen += reboot_hud
		reboot_hud.maptext = MAPTEXT_PIXELLARI("<center>Server rebooting in:\n\ [DisplayTimeText(timeleft(reboot_timer), 1)]</center>")
	else if(!isnull(reboot_hud) && reboot_hud.maptext)
		reboot_hud.maptext = ""
		for(var/client/C in GLOB.clients)
			C.screen -= reboot_hud

// Recap commits landed this round as soon as a reboot starts counting down.
/datum/controller/subsystem/ticker/Reboot(reason, end_string, delay)
	announce_pending_commits()
	return ..()

// clear the commits when rebooting
/datum/controller/subsystem/ticker/reboot_callback(reason, end_string)
	clear_pending_commits()
	return ..()

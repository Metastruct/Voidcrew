/**
 * Opens the TGUI say popup on the client instead of round-tripping through the server,
 * so it is not gated on the player's ping.
 *
 * Those keys normally go to /client/verb/keyDown(), which dispatches to the matching
 * down() proc under /datum/keybinding/client/communication, which winset()s the open
 * command back down. That is a full round trip just to reveal a popup already sitting
 * hidden on the client.
 *
 * tgui_say_create_open_command(channel) is deterministic per channel, so the command a
 * key should send is already known when the keybind is built. This extends the
 * ADMIN_CHANNEL trick the core already uses to the regular say/radio/ooc/me/looc/whisper
 * hotkeys. The per-channel down() procs are untouched and still run when tgui_input is
 * off (native input() box) or when a key is shared with another keybind.
 *
 * BYOND has no combined "Ctrl+L" key event, only separate Ctrl and L events with the
 * modifier state tracked by hand in keyDown(). A static winset cannot see that state, so
 * holding Ctrl/Alt/Shift would also open the modal unless the macros are disabled while a
 * modifier is held. instant_open_macros_active and set_instant_open_macros() handle that;
 * the keyDown()/keyUp() hooks in bindings_client.dm call them on modifier changes.
 *
 * PORTED FROM: Bubberstation modular_zzmeta/code/modules/client/client_procs.dm
 */

/client/var/instant_open_macros_active = FALSE
/// Keys currently carrying a client-local instant-open macro, so a rebind or toggle can
/// unbind exactly what we bound.
/client/var/list/instant_open_bound_keys

/client/update_special_keybinds(datum/preferences/direct_prefs)
	. = ..()
	set_instant_open_macros(!(keys_held["Ctrl"] || keys_held["Alt"] || keys_held["Shift"]), prefs || direct_prefs)

/**
 * Reconciles the client-local instant-open macros with the wanted state.
 *
 * Called on every modifier change (see the INSTANT_OPEN_MODIFIER_GUARD hook in
 * code/modules/keybindings/bindings_client.dm) and on keybind or TGUI-input changes. It
 * rebuilds the wanted set and unbinds anything no longer in it, instead of returning
 * early when the enabled state has not changed, which would leave stale macros after a
 * rebind or after turning tgui_input off. It emits one winset per wanted key, so keep it
 * out of hot per-keystroke paths.
 */
/client/proc/set_instant_open_macros(enable, datum/preferences/D)
	D ||= prefs
	if(!D?.key_bindings)
		return
	// The macros should be live only when requested AND the player actually wants TGUI input.
	// Checking the pref here (rather than early-returning) is what lets toggling it off unbind.
	var/active = enable && D.read_preference(/datum/preference/toggle/tgui_input)
	// Voidcrew has no PRAY_CHANNEL, so it is omitted from Bubber's list.
	var/static/list/instant_open_channels = list(SAY_CHANNEL, RADIO_CHANNEL, OOC_CHANNEL, ME_CHANNEL, LOOC_CHANNEL, WHIS_CHANNEL)
	var/list/wanted = list()
	if(active)
		for(var/channel in instant_open_channels)
			var/list/bound_keys = D.key_bindings[channel]
			if(!bound_keys)
				continue
			for(var/key in bound_keys)
				if(length(D.key_bindings_by_key[key]) > 1)
					continue // Shared with another keybind, keep the normal routing so that one still fires.
				wanted[key] = tgui_say_create_open_command(channel)

	// Unbind anything we bound last time that is no longer wanted (rebind, pref off, or modifier held).
	for(var/key in instant_open_bound_keys || list())
		if(!wanted[key]) // No longer wanted for any channel (assoc membership via lookup, avoiding `in`'s value/key ambiguity).
			winset(src, "default-[REF(key)]", "parent=null") // Falls through to the "Any" catch-all macro, i.e. normal keyDown() routing.
	// (Re)bind the wanted keys; this also handles a rebind moving a key to another channel.
	for(var/key in wanted)
		winset(src, "default-[REF(key)]", "parent=default;name=[key];command=[wanted[key]]")
	instant_open_bound_keys = wanted.Copy()
	instant_open_macros_active = active

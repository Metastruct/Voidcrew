/// Rebuild the client-local instant say/radio/ooc/me/looc/whisper macros as soon as
/// the tgui_input toggle changes, instead of waiting for the next rebind or relog.
///
/// PORTED FROM: Bubberstation modular_zzmeta/code/modules/client/preferences/tgui.dm

/datum/preference/toggle/tgui_input/apply_to_client(client/client, value)
	if(!istype(client, /client)) // unit tests use a client mock without update_special_keybinds()
		return
	client.update_special_keybinds()

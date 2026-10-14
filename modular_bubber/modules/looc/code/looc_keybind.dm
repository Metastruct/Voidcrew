// Keybinds for the ported LOOC and whisper chat channels.
//
// LOOC takes L (Bubber parity; core look_up is moved to P to free it) and whisper
// takes Y (core radio is moved to ; to free it) - see the PORT EDIT keybind hooks in
// code/datums/keybinding/{communication,living}.dm.
//
// PORTED FROM: Bubberstation modular_skyrat/modules/customization/datums/keybinding/communication.dm

/datum/keybinding/client/communication/looc
	hotkey_keys = list("L")
	name = LOOC_CHANNEL
	full_name = "Local OOC (LOOC)"
	description = "Local OOC, seen only by those in view."
	keybind_signal = COMSIG_KB_CLIENT_LOOC_DOWN

/datum/keybinding/client/communication/looc/down(client/user)
	. = ..()
	if(.)
		return
	winset(user, null, "command=[user.tgui_say_create_open_command(LOOC_CHANNEL)]")
	winset(user, "tgui_say.browser", "focus=true")
	return TRUE

/datum/keybinding/client/communication/whisper
	hotkey_keys = list("Y")
	name = WHIS_CHANNEL
	full_name = "IC Whisper"
	description = "Whisper to someone next to you."
	keybind_signal = COMSIG_KB_CLIENT_WHISPER_DOWN

/datum/keybinding/client/communication/whisper/down(client/user)
	. = ..()
	if(.)
		return
	winset(user, null, "command=[user.tgui_say_create_open_command(WHIS_CHANNEL)]")
	winset(user, "tgui_say.browser", "focus=true")
	return TRUE

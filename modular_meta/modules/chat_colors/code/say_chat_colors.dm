// Helpers for colouring a speaker's name in the chat log, shared by compose_message()
// (say/radio), LOOC, and the overhead runechat bubble.
//
// PORTED FROM: Bubberstation modular_zzmeta/modules/chat_colors/code/say_chat_colors.dm

/**
 * Gets an atom's personal chat colour, used to colour its name in the chat log (see
 * compose_message()). Caches like /datum/chatmessage/proc/generate_image, so player-picked
 * colours (the ic_chat_color preference) and the deterministic per-name fallback stay in
 * sync between the overhead runechat bubble and the chat log.
 */
/atom/proc/get_chat_name_color(darkened = FALSE)
	if(!chat_color || chat_color_name != name)
		chat_color = get_chat_color_string(name)
		chat_color_darkened = get_chat_color_string(name, darkened = TRUE)
		chat_color_name = name
	return darkened ? chat_color_darkened : chat_color

/// Maps the radio span classes in GLOB.freqtospan to a representative hex colour, used as
/// the blend base in get_radio_base_color(). Keep in sync with tgui-panel's chat scss.
GLOBAL_LIST_INIT(radio_span_colors, list(
	"radio" = RADIO_COLOR_COMMON,
	"sciradio" = RADIO_COLOR_SCIENCE,
	"medradio" = RADIO_COLOR_MEDICAL,
	"engradio" = RADIO_COLOR_ENGINEERING,
	"suppradio" = RADIO_COLOR_SUPPLY,
	"servradio" = RADIO_COLOR_SERVICE,
	"secradio" = RADIO_COLOR_SECURITY,
	"comradio" = RADIO_COLOR_COMMAND,
	"aiprivradio" = RADIO_COLOR_AI_PRIVATE,
	"enteradio" = RADIO_COLOR_ENTERTAIMENT,
	"syndradio" = RADIO_COLOR_SYNDICATE,
	"centcomradio" = "#686868",
	"redteamradio" = RADIO_COLOR_CTF_RED,
	"blueteamradio" = RADIO_COLOR_CTF_BLUE,
	"greenteamradio" = RADIO_COLOR_GREEN,
	"yellowteamradio" = RADIO_COLOR_YELLOW,
	"captaincast" = "#00ff99",
))

/**
 * Gets a radio channel's own established colour (the green of Common, the red of Security,
 * ...). The client blends it with the speaker's personal chat colour itself, at a ratio set
 * by the "Radio color mix" chat setting; see .chat-color-name-radio in main.scss.
 *
 * * freq - the radio frequency being spoken on.
 * * freq_color - an explicit colour override for this transmission, if any.
 */
/proc/get_radio_base_color(freq, freq_color)
	if(!freq)
		return null
	if(freq_color)
		return freq_color
	var/span = GLOB.freqtospan["[freq]"]
	var/base_color = span ? GLOB.radio_span_colors[span] : null
	return base_color || RADIO_COLOR_COMMON

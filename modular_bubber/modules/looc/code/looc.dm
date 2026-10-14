// LOOC (Local OOC) - a chat channel visible only to nearby players. Upstream /tg/
// removed LOOC years ago and Voidcrew never carried it, so this restores it from
// Bubberstation's skyrat port.
//
// PORTED FROM: Bubberstation modular_skyrat/modules/verbs/code/looc.dm
//
// Adapted for Voidcrew:
//  - standard /client/verb syntax instead of Bubber's GAME_VERB/VERB_ARG macros,
//  - get_hearers_in_range() instead of the skyrat-only get_hearers_in_looc_range(),
//  - create_chat_message()'s Voidcrew signature (language + spans are positional),
//  - the chat-name-colour span is omitted here; it is added by the chat_colors port.

GLOBAL_VAR_INIT(looc_allowed, TRUE)

/client/verb/looc(msg as text)
	set name = "LOOC"
	set desc = "Local OOC, seen only by those in view."
	set category = "OOC"

	if(!mob)
		return
	looc_message(msg)

/client/verb/looc_wallpierce(msg as text)
	set name = "LOOC (Wallpierce)"
	set desc = "Local OOC, seen by anyone within [LOOC_RANGE] tiles of you."
	set category = "OOC"

	if(!mob)
		return
	looc_message(msg, TRUE)

/client/proc/looc_message(msg, wall_pierce)
	if(GLOB.say_disabled)
		to_chat(usr, span_danger("Speech is currently admin-disabled."))
		return

	if(!mob)
		return

	msg = copytext_char(sanitize(msg), 1, MAX_MESSAGE_LEN)
	if(!msg)
		return

	if(!holder)
		if(!GLOB.looc_allowed)
			to_chat(src, span_danger("LOOC is globally muted."))
			return
		if(handle_spam_prevention(msg, MUTE_OOC))
			return
		if(findtext(msg, "byond://"))
			to_chat(src, span_boldannounce("<B>Advertising other servers is not allowed.</B>"))
			log_admin("[key_name(src)] has attempted to advertise in LOOC: [msg]")
			return
		if(prefs.muted & MUTE_LOOC)
			to_chat(src, span_danger("You cannot use LOOC (muted)."))
			return
		if(is_banned_from(ckey, BAN_LOOC))
			to_chat(src, span_warning("You are LOOC banned!"))
			return
		if(mob.stat == DEAD)
			to_chat(src, span_danger("You cannot use LOOC while dead."))
			return
		if(istype(mob, /mob/dead))
			to_chat(src, span_danger("You cannot use LOOC while ghosting."))
			return

	msg = emoji_parse(msg)

	mob.log_talk(msg, LOG_OOC, tag = "LOOC")
	var/list/heard = wall_pierce ? get_hearers_in_range(LOOC_RANGE, mob) : get_hearers_in_view(LOOC_RANGE, mob)

	//so the ai can post looc text
	if(istype(mob, /mob/living/silicon/ai))
		var/mob/living/silicon/ai/ai = mob
		heard = wall_pierce ? get_hearers_in_range(LOOC_RANGE, ai.eyeobj) : get_hearers_in_view(LOOC_RANGE, ai.eyeobj)
	//so the ai can see looc text
	for(var/mob/living/silicon/ai/ai as anything in GLOB.ai_list)
		if(ai.client && !(ai in heard) && (ai.eyeobj in heard))
			heard += ai

	// META EDIT - ADDITION - LOOC_NAME_COLOR
	// Colours the speaker's name with their chat colour, same as compose_message() does for
	// say/radio. LOOC has no channel to blend against, so the client mixes it toward the
	// default text colour per its own "LOOC color mix" setting (see main.scss).
	var/looc_name_color = mob.get_chat_name_color()
	var/looc_name_attrs = looc_name_color ? " class='chat-color-name-looc' style='--chat-color-name-value:[looc_name_color];'" : ""

	var/list/admin_seen = list()
	for(var/mob/hearing in heard)
		if(!hearing.client)
			continue
		var/client/hearing_client = hearing.client

		var/is_holder = hearing_client.holder
		if(is_holder)
			admin_seen[hearing_client] = TRUE
			// dont continue here, still need to show runechat

		if(isobserver(hearing) && !is_holder)
			continue //ghosts dont hear looc

		// Runechat first, so an admin still gets the bubble even if they are not
		// in the chat-log earshot list below.
		if(mob.runechat_prefs_check(hearing) && hearing_client.prefs?.read_preference(/datum/preference/toggle/enable_looc_runechat))
			// EMOTE is close enough; we don't want the raw message run through languages.
			hearing.create_chat_message(mob, null, "(LOOC: [msg])", null, EMOTE_MESSAGE)

		if(is_holder)
			continue //admins are handled afterwards

		if(holder && isdead(src.mob)) // Admins ghosted display ckey
			to_chat(hearing_client, span_looc(span_prefix("LOOC[wall_pierce ? " (WALL PIERCE)" : ""]:</span> <EM[looc_name_attrs]>[src.ckey]:</EM> <span class='message linkify'>[msg]")))
		else
			to_chat(hearing_client, span_looc(span_prefix("LOOC[wall_pierce ? " (WALL PIERCE)" : ""]:</span> <EM[looc_name_attrs]>[src.mob.name]:</EM> <span class='message linkify'>[msg]")))

	for(var/client/cli_client as anything in GLOB.admins)
		if(admin_seen[cli_client])
			to_chat(cli_client, span_looc("[ADMIN_FLW(usr)] <span class='prefix'>LOOC[wall_pierce ? " (WALL PIERCE)" : ""]:</span> <EM[looc_name_attrs]>[src.key]/[src.mob.name]:</EM> <span class='message linkify'>[msg]</span>"))
		else if(cli_client.prefs?.read_preference(/datum/preference/toggle/see_looc))
			to_chat(cli_client, span_rlooc("[ADMIN_FLW(usr)] <span class='prefix'>(R)LOOC[wall_pierce ? " (WALL PIERCE)" : ""]:</span> <EM[looc_name_attrs]>[src.key]/[src.mob.name]:</EM> <span class='message linkify'>[msg]</span>"))

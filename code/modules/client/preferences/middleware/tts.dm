/// Middleware to handle quirks
/datum/preference_middleware/tts
	/// Cooldown on requesting a TTS preview.
	COOLDOWN_DECLARE(tts_test_cooldown)

	action_delegations = list(
		"play_voice" = PROC_REF(play_voice),
		"play_voice_robot" = PROC_REF(play_voice_robot),
		"play_whisper_voice" = PROC_REF(play_whisper_voice), // META EDIT - ADDITION - TTS_WHISPER_VOICE
	)

/datum/preference_middleware/tts/proc/play_voice(list/params, mob/user)
	if(!COOLDOWN_FINISHED(src, tts_test_cooldown))
		return TRUE
	var/speaker = preferences.read_preference(/datum/preference/choiced/voice)
	var/pitch = preferences.read_preference(/datum/preference/numeric/tts_voice_pitch)
	COOLDOWN_START(src, tts_test_cooldown, 0.5 SECONDS)
	INVOKE_ASYNC(SStts, TYPE_PROC_REF(/datum/controller/subsystem/tts, queue_tts_message), user.client, "Hello, this is my voice.", speaker = speaker, pitch = pitch, local = TRUE, custom_voice = preferences.read_preference(/datum/preference/text/tts_custom_voice)) // META EDIT - CHANGE - TTS_CUSTOM_VOICE
	return TRUE

/datum/preference_middleware/tts/proc/play_voice_robot(list/params, mob/user)
	if(!COOLDOWN_FINISHED(src, tts_test_cooldown))
		return TRUE
	var/speaker = preferences.read_preference(/datum/preference/choiced/voice)
	var/pitch = preferences.read_preference(/datum/preference/numeric/tts_voice_pitch)
	COOLDOWN_START(src, tts_test_cooldown, 0.5 SECONDS)
	INVOKE_ASYNC(SStts, TYPE_PROC_REF(/datum/controller/subsystem/tts, queue_tts_message), user.client, "Look at you, Player. A pathetic creature of meat and bone. How can you challenge a perfect, immortal machine?", speaker = speaker, pitch = pitch, special_filters = TTS_FILTER_SILICON, local = TRUE, custom_voice = preferences.read_preference(/datum/preference/text/tts_custom_voice)) // META EDIT - CHANGE - TTS_CUSTOM_VOICE
	return TRUE

// META EDIT - ADDITION - START - TTS_WHISPER_VOICE
/// Preview the whisper voice, falling back to the normal voice when it is "same".
/datum/preference_middleware/tts/proc/play_whisper_voice(list/params, mob/user)
	if(!COOLDOWN_FINISHED(src, tts_test_cooldown))
		return TRUE
	var/speaker = preferences.read_preference(/datum/preference/choiced/tts_whisper_voice)
	var/custom
	if(speaker == "same" || !(speaker in SStts.available_speakers))
		speaker = preferences.read_preference(/datum/preference/choiced/voice)
		custom = preferences.read_preference(/datum/preference/text/tts_custom_voice)
	else
		custom = preferences.read_preference(/datum/preference/text/tts_whisper_custom)
	var/pitch = preferences.read_preference(/datum/preference/numeric/tts_voice_pitch)
	COOLDOWN_START(src, tts_test_cooldown, 0.5 SECONDS)
	INVOKE_ASYNC(SStts, TYPE_PROC_REF(/datum/controller/subsystem/tts, queue_tts_message), user.client, "Psst... this is my whisper voice.", speaker = speaker, pitch = pitch, local = TRUE, custom_voice = custom)
	return TRUE
// META EDIT - ADDITION - END - TTS_WHISPER_VOICE

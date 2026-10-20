/// TTS voice preference
/datum/preference/choiced/voice
	savefile_identifier = PREFERENCE_CHARACTER
	savefile_key = "tts_voice"
	category = PREFERENCE_CATEGORY_NON_CONTEXTUAL

/datum/preference/choiced/voice/is_accessible(datum/preferences/preferences)
	if(!SStts.tts_enabled)
		return FALSE
	return ..()

/datum/preference/choiced/voice/init_possible_values()
	if(SStts.tts_enabled)
		return list(TTS_VOICE_NONE) + SStts.available_speakers
	if(fexists("data/cached_tts_voices.json"))
		var/list/text_data = rustg_file_read("data/cached_tts_voices.json")
		var/list/cached_data = json_decode(text_data)
		if(!cached_data)
			return list("invalid")
		return list(TTS_VOICE_NONE) + cached_data
	return list("invalid")

// META EDIT - ADDITION - START - TTS_DEFAULT_NONE
/// New characters default to no TTS voice rather than a random one.
/datum/preference/choiced/voice/create_default_value()
	if(SStts.tts_enabled)
		return TTS_VOICE_NONE
	return ..() // TTS off: choices are just list("invalid")

/// Randomizing a character may still pick a real voice, but never the "None" placeholder.
/datum/preference/choiced/voice/create_random_value(datum/preferences/preferences)
	if(!SStts.tts_enabled)
		return ..(preferences)
	if(!length(SStts.available_speakers))
		return TTS_VOICE_NONE
	return pick(SStts.available_speakers)
// META EDIT - ADDITION - END - TTS_DEFAULT_NONE

/datum/preference/choiced/voice/apply_to_human(mob/living/carbon/human/target, value)
	// META EDIT - CHANGE - TTS_DEFAULT_NONE
	// ORIGINAL: if(SStts.tts_enabled && !(value in SStts.available_speakers))
	// ORIGINAL: 	value = pick(SStts.available_speakers) // As a failsafe
	// ORIGINAL: target.voice = value
	if(SStts.tts_enabled && value != TTS_VOICE_NONE && !(value in SStts.available_speakers))
		value = length(SStts.available_speakers) ? pick(SStts.available_speakers) : TTS_VOICE_NONE // As a failsafe
	target.voice = (value == TTS_VOICE_NONE) ? "" : value

/datum/preference/numeric/tts_voice_pitch
	savefile_identifier = PREFERENCE_CHARACTER
	savefile_key = "tts_voice_pitch"
	category = PREFERENCE_CATEGORY_NON_CONTEXTUAL
	minimum = -12
	maximum = 12

/datum/preference/numeric/tts_voice_pitch/is_accessible(datum/preferences/preferences)
	if(!SStts.tts_enabled || !SStts.pitch_enabled)
		return FALSE
	return ..()

/datum/preference/numeric/tts_voice_pitch/create_default_value()
	return 0

/datum/preference/numeric/tts_voice_pitch/apply_to_human(mob/living/carbon/human/target, value)
	if(SStts.tts_enabled && SStts.pitch_enabled)
		target.pitch = value

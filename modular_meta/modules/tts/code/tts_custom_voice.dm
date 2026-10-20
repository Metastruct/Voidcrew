// META EDIT - ADDITION - TTS_CUSTOM_VOICE
// Ported from Bubberstation's modular_zzmeta. Free-form TTS engine parameters for
// the normal voice. Only shown for engines that accept them; the TTS server ignores
// it for every other voice.
//
// eSpeak/MBROLA: "<voice> [speed=<n>] [pitch=<n>] [amplitude=<n>]"
// DECtalk:       raw commands, e.g. "[:ra 220][:dv hs 100]"
// SAPI4:         "pitch=<n> speed=<n>"
/datum/preference/text/tts_custom_voice
	category = PREFERENCE_CATEGORY_NON_CONTEXTUAL
	savefile_identifier = PREFERENCE_CHARACTER
	savefile_key = "tts_custom_voice"
	maximum_value_length = 64
	can_randomize = FALSE

/datum/preference/text/tts_custom_voice/create_default_value()
	return ""

/datum/preference/text/tts_custom_voice/is_accessible(datum/preferences/preferences)
	if(!..())
		return FALSE
	if(!SStts.tts_enabled)
		return FALSE
	var/selected = preferences.read_preference(/datum/preference/choiced/voice)
	return istext(selected) && (findtext(selected, "eSpeak") || findtext(selected, "DECtalk") || findtext(selected, "SAPI4"))

/datum/preference/text/tts_custom_voice/apply_to_human(mob/living/carbon/human/target, value)
	target.tts_custom_voice = value

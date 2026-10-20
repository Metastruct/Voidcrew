/proc/tts_speech_filter(text)
	// META EDIT - REPLACEMENT - START - TTS_MINIMAL_SPEECH_FILTER
	// Minimal sanitizer: ASCII control characters become spaces and whitespace runs
	// collapse to one, but every printable character is kept - including the brackets
	// (inline engine commands) and backslashes (SAPI4 tags) the custom-voice
	// preference can emit. The text only ever leaves as a JSON body, so there is no
	// shell/injection reason to strip punctuation.
	// ORIGINAL: // Only allow alphanumeric characters and whitespace
	// ORIGINAL: var/static/regex/bad_chars_regex = regex("\[^a-zA-Z0-9 ,?.!'&-]", "g")
	// ORIGINAL: return bad_chars_regex.Replace(text, " ")
	var/list/out = list()
	for(var/i in 1 to length_char(text))
		var/char = copytext_char(text, i, i + 1)
		var/char_code = text2ascii(char)
		if(char_code < 32 || char_code == 127)
			char = " "
		if(char == " " && length(out) && out[length(out)] == " ")
			continue
		out += char
	return jointext(out, "")
	// META EDIT - REPLACEMENT - END - TTS_MINIMAL_SPEECH_FILTER

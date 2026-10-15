// Bubberstation voice packs live in their own TOML so Voidcrew's
// config/voidcrew/voice_packs.toml stays as upstream. gen_voice_packs() merges the
// result of port_read_bubber_voice_packs() into its group list.
//
// PORTED FROM: Bubberstation's config/bloopers/blooper_config.json.

#define BUBBER_VOICE_PACKS_FILE "modular_bubber/config/voice_packs.toml"

/// Parsed Bubber voice pack groups, or an empty list if the file is missing.
/proc/port_read_bubber_voice_packs()
	if(!fexists(BUBBER_VOICE_PACKS_FILE))
		return list()
	return rustg_read_toml_file(BUBBER_VOICE_PACKS_FILE)

#undef BUBBER_VOICE_PACKS_FILE

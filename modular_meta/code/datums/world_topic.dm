// Player list world-topic endpoint, ported from Bubber's modular_zzmeta.
//
// Exposes a JSON list of in-game players (name, job, AFK, headshot) via the standard
// `?playerlist` world topic, for external tooling such as a website status page.
//
// PORTED FROM: Bubberstation modular_zzmeta/code/datums/world_topic.dm
//
// Headshots: Bubber stores a player-uploaded image URL in `dna.features["headshot"]`.
// Voidcrew has no such upload preference (yet), so when it's absent we fall back to
// rendering the character with `getFlatIcon()` - the same renderer behind the
// security-record / wanted-poster mugshots - and hand back a base64 PNG data URI.
// The image is the full standing sprite, so the consumer crops to the head/shoulders
// (the head sits in the top ~half of the 32x32 sprite).

/// Cache lifetime for a generated mugshot, so frequent topic polls don't rebuild the
/// flat icon on every request.
#define META_HEADSHOT_CACHE_TIME 15 SECONDS

/mob/living
	/// Cached `data:image/png;base64,...` mugshot for the player list.
	var/meta_headshot_cache
	/// `world.time` the cache was built at.
	var/meta_headshot_cache_time = 0

/datum/world_topic/playerlist
	keyword = "playerlist"

/datum/world_topic/playerlist/Run(list/input)
	. = list()
	for(var/client/player_client as anything in GLOB.clients)
		var/mob/character = player_client.mob
		// Skip lobby/character-setup connections - there's nothing to report yet.
		if(!istype(character) || isnewplayer(character) || !character.mind)
			continue

		var/list/entry = list()
		entry["name"] = character.real_name || character.name
		entry["job"] = character.mind.assigned_role?.title
		entry["afk"] = !!player_client.is_afk()

		var/headshot = meta_playerlist_headshot(character)
		if(headshot)
			entry["headshot"] = headshot

		. += list(entry)

/// A player-supplied headshot URL if the character has one (Bubber's `headshot` DNA
/// feature, not yet ported as a preference, so normally absent), otherwise a freshly
/// rendered mugshot data URI. Returns null when neither is available.
/proc/meta_playerlist_headshot(mob/living/character)
	if(!isliving(character))
		return null

	if(ishuman(character))
		var/mob/living/carbon/human/human = character
		var/uploaded = human.dna?.features?["headshot"]
		if(istext(uploaded) && length(uploaded))
			return uploaded

	if(character.meta_headshot_cache && world.time < character.meta_headshot_cache_time + META_HEADSHOT_CACHE_TIME)
		return character.meta_headshot_cache

	// Force a south-facing render so the headshot is consistent regardless of where the
	// character happens to be looking (same trick as `record.make_photo()`).
	var/mutable_appearance/appearance = new(character.appearance)
	appearance.setDir(SOUTH)

	// `no_anim` keeps animated overlays (e.g. the typing indicator) from turning the flat
	// icon into a multi-frame icon, which `icon2base64()` would export as every frame
	// tiled side by side.
	var/icon/rendered = getFlatIcon(appearance, no_anim = TRUE)
	if(!rendered || !rendered.Width() || !rendered.Height())
		return null

	var/result = "data:image/png;base64,[icon2base64(rendered)]"
	character.meta_headshot_cache = result
	character.meta_headshot_cache_time = world.time
	return result

#undef META_HEADSHOT_CACHE_TIME

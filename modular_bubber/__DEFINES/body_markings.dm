// Defines and global lists for the per-limb body-marking system ported from Bubber.
//
// Body markings are an assoc list per body zone: zone -> (marking name -> list(colour, emissive)).
// A marking's `affected_bodyparts` bitflags decide which zones it can be picked for; the
// per-zone choice lists are built from those. See datums/body_markings/.

#ifndef MAXIMUM_MARKINGS_PER_LIMB
#define MAXIMUM_MARKINGS_PER_LIMB 3
#endif

// Indices into each zone's marking-entry list.
#define MARKING_INDEX_COLOR 1
#define MARKING_INDEX_EMISSIVE 2

// Sentinels a /datum/body_marking's default_color can carry instead of a hex colour.
#ifndef DEFAULT_PRIMARY
#define DEFAULT_PRIMARY 1
#endif
#ifndef DEFAULT_SECONDARY
#define DEFAULT_SECONDARY 2
#endif
#ifndef DEFAULT_TERTIARY
#define DEFAULT_TERTIARY 3
#endif
#ifndef DEFAULT_SKIN_OR_PRIMARY
#define DEFAULT_SKIN_OR_PRIMARY 5
#endif

// Bubber species ids that Voidcrew doesn't ship. Kept so ported `recommended_species`
// lists compile; nothing matches them, so those markings simply never look "native".
#ifndef SPECIES_AKULA
#define SPECIES_AKULA "akula"
#endif
#ifndef SPECIES_AQUATIC
#define SPECIES_AQUATIC "aquatic"
#endif
#ifndef SPECIES_VOX
#define SPECIES_VOX "vox"
#endif
#ifndef SPECIES_XENO
#define SPECIES_XENO "xeno"
#endif

/// All markings, keyed by name.
GLOBAL_LIST_EMPTY(body_markings)
/// Marking names that affect each body zone, keyed by BODY_ZONE_*.
GLOBAL_LIST_EMPTY_TYPED(body_markings_per_limb, /list)
/// All marking presets, keyed by name.
GLOBAL_LIST_EMPTY(body_marking_sets)

/// The body zones a marking can be applied to.
GLOBAL_LIST_INIT(marking_zones, list(
	BODY_ZONE_HEAD,
	BODY_ZONE_CHEST,
	BODY_ZONE_L_LEG,
	BODY_ZONE_R_LEG,
	BODY_ZONE_L_ARM,
	BODY_ZONE_R_ARM,
	BODY_ZONE_PRECISE_L_HAND,
	BODY_ZONE_PRECISE_R_HAND,
))

/// Maps a body zone to the marking bitflag used in `affected_bodyparts`.
GLOBAL_LIST_INIT(marking_zone_to_bitflag, list(
	BODY_ZONE_HEAD = HEAD,
	BODY_ZONE_CHEST = CHEST,
	BODY_ZONE_L_LEG = LEG_LEFT,
	BODY_ZONE_R_LEG = LEG_RIGHT,
	BODY_ZONE_L_ARM = ARM_LEFT,
	BODY_ZONE_R_ARM = ARM_RIGHT,
	BODY_ZONE_PRECISE_L_HAND = HAND_LEFT,
	BODY_ZONE_PRECISE_R_HAND = HAND_RIGHT,
))

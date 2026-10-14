// Extra `dna.features` keys for content ported from Bubberstation.
//
// Voidcrew defines the upstream set in code/__DEFINES/DNA.dm. These are additive and
// only consumed by modular_bubber files (which load after this file), so they do not
// need an early include in tgstation.dme. Guarded with #ifndef so a future upstream
// that adds the same key doesn't collide.

// --- Three-tone "matrixed" mutant colouring ---------------------------------
// Bubber accessories are coloured with up to three independent layers
// (primary/secondary/tertiary) that render as `..._<layer>_primary` etc.
#ifndef FEATURE_MUTANT_COLOR_TWO
#define FEATURE_MUTANT_COLOR_TWO "mcolor2"
#endif
#ifndef FEATURE_MUTANT_COLOR_THREE
#define FEATURE_MUTANT_COLOR_THREE "mcolor3"
#endif

/// Sentinels for /datum/sprite_accessory.color_src. Voidcrew's existing values are
/// strings (MUTANT_COLOR, HAIR_COLOR, ...); a matrixed accessory instead renders one
/// tinted image per colour layer.
#ifndef USE_MATRIXED_COLORS
#define USE_MATRIXED_COLORS "use_matrixed_colors"
#endif

// --- Extra anthro features --------------------------------------------------
#ifndef FEATURE_FLUFF
#define FEATURE_FLUFF "fluff"
#endif
#ifndef FEATURE_TAUR
#define FEATURE_TAUR "taur"
#endif
#ifndef FEATURE_TAIL_GENERIC
#define FEATURE_TAIL_GENERIC "tail"
#endif
#ifndef FEATURE_HEAD_ACCESSORY
#define FEATURE_HEAD_ACCESSORY "head_acc"
#endif
#ifndef FEATURE_NECK_ACCESSORY
#define FEATURE_NECK_ACCESSORY "neck_acc"
#endif

// --- Genitals (appearance only) ---------------------------------------------
#ifndef FEATURE_PENIS
#define FEATURE_PENIS "penis"
#endif
#ifndef FEATURE_TESTICLES
#define FEATURE_TESTICLES "testicles"
#endif
#ifndef FEATURE_VAGINA
#define FEATURE_VAGINA "vagina"
#endif
#ifndef FEATURE_BREASTS
#define FEATURE_BREASTS "breasts"
#endif

// --- Synthetic (IPC) parts --------------------------------------------------
// Values match Bubber's MUTANT_SYNTH_* so Bubber art/feature keys line up.
#ifndef FEATURE_SYNTH_SCREEN
#define FEATURE_SYNTH_SCREEN "ipc_screen"
#endif
#ifndef FEATURE_SYNTH_ANTENNA
#define FEATURE_SYNTH_ANTENNA "ipc_antenna"
#endif
#ifndef FEATURE_SYNTH_CHASSIS
#define FEATURE_SYNTH_CHASSIS "synth_chassis"
#endif
#ifndef FEATURE_SYNTH_HEAD
#define FEATURE_SYNTH_HEAD "synth_head"
#endif

// --- Body size (Bubber scale) ------------------------------------------------
#ifndef BODY_SIZE_MIN
#define BODY_SIZE_MIN 0.8
#endif
#ifndef BODY_SIZE_MAX
#define BODY_SIZE_MAX 1.5
#endif

// --- Synthetic (IPC) chassis ---
// Colour-override priority for a synth's chassis/head tint. Higher than every core
// LIMB_COLOR_* priority, so it wins for the swappable greyscale chassis art.
#ifndef META_LIMB_COLOR_SYNTH
#define META_LIMB_COLOR_SYNTH 100
#endif

// Bubber's default synth chassis/head tint (DEFAULT_SYNTH_PART_COLOR). Used when a
// synth has no explicit chassis/head colour so the ported greyscale sheets aren't left
// untinted (which read as plain white).
#ifndef DEFAULT_SYNTH_PART_COLOR
#define DEFAULT_SYNTH_PART_COLOR "#746c6a"
#endif

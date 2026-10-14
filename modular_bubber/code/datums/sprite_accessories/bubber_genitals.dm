// Genital sprite accessories ported from Bubberstation (modular_skyrat base set plus the
// modular_zubbers additions: the "(Alt)" shapes, sheathed testicles, butt and belly).
//
// Voidcrew's mutant overlay names icon states `m_<feature_key>_<icon_state>_<LAYER>`,
// which matches Bubber's genital art, so the art is reused as-authored. `color_src` is
// USE_MATRIXED_COLORS so the matrixed renderer can tint the multi-layer art (sheath/slit
// penises, butt) and honour per-feature colours; single-layer art falls back to one tint.
//
// The base and "(Alt)" sets are different DMIs (skyrat vs zubbers) and are kept under
// separate subdirectories so neither overwrites the other.
//
// `name` values are savefile-visible (stored in dna.features) and must not change.
//
// PORTED FROM: Bubberstation modular_skyrat/.../sprite_accessories/genitals.dm and
// modular_zubbers/code/modules/customization/sprite_accessories/genitals.dm

/datum/sprite_accessory/genital
	/// If TRUE, this accessory also has a skin-tone shaded art variant (suffix `_s`).
	var/has_skintone_shading = FALSE
	/// Which body zone this part sits in, used by the clothing-exposure check.
	var/genital_location = GROIN

// --- Penis -------------------------------------------------------------------

/datum/sprite_accessory/genital/penis
	icon = 'modular_bubber/icons/skyrat/mob/sprite_accessory/genitals/penis_onmob.dmi'
	color_src = USE_MATRIXED_COLORS
	center = TRUE
	/// Can this shape be tucked into a sheath/slit?
	var/can_have_sheath = TRUE

/datum/sprite_accessory/genital/penis/none
	name = SPRITE_ACCESSORY_NONE
	icon_state = "none"
	color_src = null

/datum/sprite_accessory/genital/penis/human
	name = "Human"
	icon_state = "human"
	has_skintone_shading = TRUE
	can_have_sheath = FALSE

/datum/sprite_accessory/genital/penis/nondescript
	name = "Nondescript"
	icon_state = "nondescript"

/datum/sprite_accessory/genital/penis/knotted
	name = "Knotted"
	icon_state = "knotted"

/datum/sprite_accessory/genital/penis/flared
	name = "Flared"
	icon_state = "flared"

/datum/sprite_accessory/genital/penis/barbknot
	name = "Barbed, Knotted"
	icon_state = "barbknot"

/datum/sprite_accessory/genital/penis/tapered
	name = "Tapered"
	icon_state = "tapered"

/datum/sprite_accessory/genital/penis/tentacle
	name = "Tentacled"
	icon_state = "tentacle"

/datum/sprite_accessory/genital/penis/hemi
	name = "Hemi"
	icon_state = "hemi"

/datum/sprite_accessory/genital/penis/hemiknot
	name = "Knotted Hemi"
	icon_state = "hemiknot"

// modular_zubbers "(Alt)" set.
/datum/sprite_accessory/genital/penis/alt
	icon = 'modular_bubber/icons/zubbers/mob/sprite_accesory/genitals/penis_onmob.dmi'
	color_src = USE_MATRIXED_COLORS

/datum/sprite_accessory/genital/penis/alt/human
	name = "Human (Alt)"
	icon_state = "human"
	has_skintone_shading = TRUE
	can_have_sheath = FALSE

/datum/sprite_accessory/genital/penis/alt/nondescript
	name = "Nondescript (Alt)"
	icon_state = "nondescript"

/datum/sprite_accessory/genital/penis/alt/knotted
	name = "Knotted (Alt)"
	icon_state = "knotted"

/datum/sprite_accessory/genital/penis/alt/flared
	name = "Flared (Alt)"
	icon_state = "flared"

/datum/sprite_accessory/genital/penis/alt/barbknot
	name = "Barbed, Knotted (Alt)"
	icon_state = "barbknot"

/datum/sprite_accessory/genital/penis/alt/tapered
	name = "Tapered (Alt)"
	icon_state = "tapered"

/datum/sprite_accessory/genital/penis/alt/tentacle
	name = "Tentacled (Alt)"
	icon_state = "tentacle"

/datum/sprite_accessory/genital/penis/alt/hemi
	name = "Hemi (Alt)"
	icon_state = "hemi"

/datum/sprite_accessory/genital/penis/alt/hemiknot
	name = "Knotted Hemi (Alt)"
	icon_state = "hemiknot"

// --- Testicles ---------------------------------------------------------------

/datum/sprite_accessory/genital/testicles
	icon = 'modular_bubber/icons/skyrat/mob/sprite_accessory/genitals/testicles_onmob.dmi'
	color_src = USE_MATRIXED_COLORS
	/// Whether this shape has a size
	var/has_size = TRUE

/datum/sprite_accessory/genital/testicles/none
	name = SPRITE_ACCESSORY_NONE
	icon_state = "none"
	color_src = null

/datum/sprite_accessory/genital/testicles/pair
	name = "Pair"
	icon_state = "pair"
	has_skintone_shading = TRUE

/datum/sprite_accessory/genital/testicles/internal
	name = "Internal"
	icon_state = "none"
	color_src = null
	has_size = FALSE

// modular_zubbers additions.
/datum/sprite_accessory/genital/testicles/alt
	icon = 'modular_bubber/icons/zubbers/mob/sprite_accesory/genitals/testicles_onmob.dmi'
	color_src = USE_MATRIXED_COLORS
	icon_state = "pair"
	name = "Pair (Alt)"
	has_skintone_shading = TRUE

/datum/sprite_accessory/genital/testicles/sheath
	icon = 'modular_bubber/icons/zubbers/mob/sprite_accesory/genitals/testicles_onmob.dmi'
	color_src = USE_MATRIXED_COLORS
	icon_state = "sheath"
	name = "Sheathed Pair"
	has_skintone_shading = TRUE

// --- Vagina ------------------------------------------------------------------

/datum/sprite_accessory/genital/vagina
	icon = 'modular_bubber/icons/skyrat/mob/sprite_accessory/genitals/vagina_onmob.dmi'
	color_src = USE_MATRIXED_COLORS
	genital_location = GROIN
	/// Whether a separate arousal icon exists (else arousal shows on the base sprite)
	var/alt_aroused = TRUE

/datum/sprite_accessory/genital/vagina/none
	name = SPRITE_ACCESSORY_NONE
	icon_state = "none"
	color_src = null

/datum/sprite_accessory/genital/vagina/human
	name = "Human"
	icon_state = "human"

/datum/sprite_accessory/genital/vagina/tentacles
	name = "Tentacle"
	icon_state = "tentacle"

/datum/sprite_accessory/genital/vagina/dentata
	name = "Dentata"
	icon_state = "dentata"

/datum/sprite_accessory/genital/vagina/hairy
	name = "Hairy"
	icon_state = "hairy"
	alt_aroused = FALSE

/datum/sprite_accessory/genital/vagina/spade
	name = "Spade"
	icon_state = "spade"
	alt_aroused = FALSE

/datum/sprite_accessory/genital/vagina/furred
	name = "Furred"
	icon_state = "furred"
	alt_aroused = FALSE

/datum/sprite_accessory/genital/vagina/gaping
	name = "Gaping"
	icon_state = "gaping"

// Cloaca art lives in its own modular_zubbers DMI.
/datum/sprite_accessory/genital/vagina/cloaca
	name = "Cloaca"
	icon_state = "cloaca"
	icon = 'modular_bubber/icons/zubbers/customization/genitals/vagina.dmi'
	color_src = USE_MATRIXED_COLORS

// --- Womb (never drawn) ------------------------------------------------------

/datum/sprite_accessory/genital/womb
	color_src = null

/datum/sprite_accessory/genital/womb/none
	name = SPRITE_ACCESSORY_NONE
	icon_state = "none"

/datum/sprite_accessory/genital/womb/normal
	name = "Normal"
	icon_state = "none"

// --- Anus --------------------------------------------------------------------

/datum/sprite_accessory/genital/anus
	color_src = null
	genital_location = GROIN

/datum/sprite_accessory/genital/anus/none
	name = SPRITE_ACCESSORY_NONE
	icon_state = "none"

/datum/sprite_accessory/genital/anus/normal
	name = "Anus"
	icon_state = "anus"

// --- Breasts -----------------------------------------------------------------

/datum/sprite_accessory/genital/breasts
	icon = 'modular_bubber/icons/skyrat/mob/sprite_accessory/genitals/breasts_onmob.dmi'
	color_src = USE_MATRIXED_COLORS
	genital_location = CHEST
	has_skintone_shading = TRUE
	/// Highest size index this shape is authored for
	var/max_size = 0

/datum/sprite_accessory/genital/breasts/none
	name = SPRITE_ACCESSORY_NONE
	icon_state = "none"
	color_src = null

/datum/sprite_accessory/genital/breasts/pair
	name = "Pair"
	icon_state = "pair"
	max_size = 16

/datum/sprite_accessory/genital/breasts/quad
	name = "Quad"
	icon_state = "quad"
	max_size = 5

/datum/sprite_accessory/genital/breasts/sextuple
	name = "Sextuple"
	icon_state = "sextuple"
	max_size = 5

// modular_zubbers "(Alt)" set.
/datum/sprite_accessory/genital/breasts/alt
	icon = 'modular_bubber/icons/zubbers/mob/sprite_accesory/genitals/breasts_onmob.dmi'
	color_src = USE_MATRIXED_COLORS
	max_size = 19

/datum/sprite_accessory/genital/breasts/alt/pair
	name = "Pair (Alt)"
	icon_state = "pair_alt"

/datum/sprite_accessory/genital/breasts/alt/quad
	name = "Quad (Alt)"
	icon_state = "quad_alt"

/datum/sprite_accessory/genital/breasts/alt/sextuple
	name = "Sextuple (Alt)"
	icon_state = "sextuple_alt"

// --- Butt --------------------------------------------------------------------

/datum/sprite_accessory/genital/butt
	icon = 'modular_bubber/icons/zubbers/mob/sprite_accesory/genitals/butt_onmob.dmi'
	color_src = USE_MATRIXED_COLORS
	genital_location = GROIN
	has_skintone_shading = TRUE

/datum/sprite_accessory/genital/butt/none
	name = SPRITE_ACCESSORY_NONE
	icon_state = "none"
	color_src = null

/datum/sprite_accessory/genital/butt/pair
	name = "Pair"
	icon_state = "pair"

// --- Belly -------------------------------------------------------------------

/datum/sprite_accessory/genital/belly
	icon = 'modular_bubber/icons/zubbers/mob/sprite_accesory/genitals/belly_onmob.dmi'
	color_src = USE_MATRIXED_COLORS
	genital_location = CHEST
	has_skintone_shading = TRUE

/datum/sprite_accessory/genital/belly/none
	name = SPRITE_ACCESSORY_NONE
	icon_state = "none"
	color_src = null

/datum/sprite_accessory/genital/belly/normal
	name = "Belly"
	icon_state = "pair"

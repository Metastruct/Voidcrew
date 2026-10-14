// Defines for the ported genital system.
//
// Voidcrew has no genital/ERP content, so everything here is additive. Organ slots double
// as the sprite-accessory feature keys (the art is named `m_<slot>_<suffix>_<LAYER>`),
// exactly as Bubber does.
//
// PORTED FROM: Bubberstation code/__DEFINES/{mobs,~skyrat_defines/_organ_defines,~skyrat_defines/lewd_defines,~skyrat_defines/obj_flags,~~bubber_defines/DNA}.dm

// --- Organ slots / feature keys ---------------------------------------------

#ifndef ORGAN_SLOT_PENIS
#define ORGAN_SLOT_PENIS "penis"
#endif
#ifndef ORGAN_SLOT_TESTICLES
#define ORGAN_SLOT_TESTICLES "testicles"
#endif
#ifndef ORGAN_SLOT_VAGINA
#define ORGAN_SLOT_VAGINA "vagina"
#endif
#ifndef ORGAN_SLOT_WOMB
#define ORGAN_SLOT_WOMB "womb"
#endif
#ifndef ORGAN_SLOT_ANUS
#define ORGAN_SLOT_ANUS "anus"
#endif
#ifndef ORGAN_SLOT_BREASTS
#define ORGAN_SLOT_BREASTS "breasts"
#endif
#ifndef ORGAN_SLOT_BUTT
#define ORGAN_SLOT_BUTT "butt"
#endif
#ifndef ORGAN_SLOT_BELLY
#define ORGAN_SLOT_BELLY "belly"
#endif

// --- Visibility (whether an organ shows through clothing) --------------------

#define GENITAL_SKIP_VISIBILITY 0
#define GENITAL_NEVER_SHOW 1
#define GENITAL_HIDDEN_BY_CLOTHES 2
#define GENITAL_ALWAYS_SHOW 3

// --- Arousal -----------------------------------------------------------------

#define AROUSAL_CANT 0
#define AROUSAL_NONE 1
#define AROUSAL_PARTIAL 2
#define AROUSAL_FULL 3

#define AROUSAL_MINIMUM 0
#define AROUSAL_MINIMUM_DETECTABLE 10
#define AROUSAL_LOW 30
#define AROUSAL_MEDIUM 70
#define AROUSAL_HIGH 85
#define AROUSAL_AUTO_CLIMAX_THRESHOLD 90
#define AROUSAL_LIMIT 100

// --- Sheaths (penises) -------------------------------------------------------

#define SHEATH_NONE "None"
#define SHEATH_NORMAL "Sheath"
#define SHEATH_SLIT "Slit"
#define SHEATH_MODES list(SHEATH_NONE, SHEATH_NORMAL, SHEATH_SLIT)

// --- Sizing ------------------------------------------------------------------

#define TESTICLES_MAX_SIZE 8

#define BREAST_SIZE_FLATCHESTED "Flatchested"
#define BREAST_SIZE_A "A"
#define BREAST_SIZE_B "B"
#define BREAST_SIZE_C "C"
#define BREAST_SIZE_D "D"
#define BREAST_SIZE_E "E"
#define BREAST_SIZE_F "F"
#define BREAST_SIZE_G "G"
#define BREAST_SIZE_H "H"
#define BREAST_SIZE_I "I"
#define BREAST_SIZE_J "J"
#define BREAST_SIZE_K "K"
#define BREAST_SIZE_L "L"
#define BREAST_SIZE_M "M"
#define BREAST_SIZE_N "N"
#define BREAST_SIZE_O "O"
#define BREAST_SIZE_P "P"
#define BREAST_SIZE_Q "Q"
#define BREAST_SIZE_R "R"
#define BREAST_SIZE_S "S"
#define BREAST_SIZE_BEYOND_MEASUREMENT "beyond measurement"

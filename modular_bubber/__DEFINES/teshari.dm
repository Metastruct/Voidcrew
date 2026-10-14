// Teshari head-fit constants.
//
// Generic hair and generic ears are authored for the human (odd-width) head; the
// teshari head is smaller and even-width, so generic overlays are scaled/shifted
// horizontally to close the seam and pushed down to meet the smaller head.
// Teshari-authored accessories already fit and are skipped.
//
// PORTED FROM: Bubberstation modular_skyrat/modules/bodyparts/code/teshari_bodyparts.dm
// (the TESHARI_HAIR_FIT transform is our own work in that fork).

#define TESHARI_HAIR_SCALE_X 0.95
#define TESHARI_HAIR_SHIFT_X (0.5 * TESHARI_HAIR_SCALE_X)

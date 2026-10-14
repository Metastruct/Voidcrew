// Defines for the ported Bubberstation pixel-shift module.
//
// These live in our layer rather than core so the module is self-contained; they are
// the signals the `/datum/component/pixel_shift` listens on and the three keybind
// signals its keybind datums fire.
//
// PORTED FROM: Bubberstation code/__DEFINES/~skyrat_defines/keybindings.dm
//              Bubberstation code/__DEFINES/~skyrat_defines/living.dm

#ifndef COMSIG_KB_LIVING_PIXEL_SHIFT_DOWN
#define COMSIG_KB_LIVING_PIXEL_SHIFT_DOWN "keybinding_living_pixel_shift_down"
#endif
#ifndef COMSIG_KB_LIVING_PIXEL_SHIFT_UP
#define COMSIG_KB_LIVING_PIXEL_SHIFT_UP "keybinding_living_pixel_shift_up"
#endif
#ifndef COMSIG_KB_LIVING_ITEM_PIXEL_SHIFT_DOWN
#define COMSIG_KB_LIVING_ITEM_PIXEL_SHIFT_DOWN "keybinding_living_item_pixelshift_down"
#endif
#ifndef COMSIG_KB_LIVING_ITEM_PIXEL_SHIFT_UP
#define COMSIG_KB_LIVING_ITEM_PIXEL_SHIFT_UP "keybinding_living_item_pixelshift_up"
#endif
#ifndef COMSIG_KB_LIVING_PIXEL_TILT_DOWN
#define COMSIG_KB_LIVING_PIXEL_TILT_DOWN "keybinding_living_pixeltilt_down"
#endif
#ifndef COMSIG_KB_LIVING_PIXEL_TILT_UP
#define COMSIG_KB_LIVING_PIXEL_TILT_UP "keybinding_living_pixeltilt_up"
#endif

//from base of mob/living/set_pull_offsets(): (no args, sent to the mob being pulled)
#ifndef COMSIG_LIVING_SET_PULL_OFFSET
#define COMSIG_LIVING_SET_PULL_OFFSET "living_set_pull_offset"
#endif
//from base of mob/living/reset_pull_offsets(): (no args, sent to the mob being pulled)
#ifndef COMSIG_LIVING_RESET_PULL_OFFSETS
#define COMSIG_LIVING_RESET_PULL_OFFSETS "living_reset_pull_offsets"
#endif
//from our override of mob/living/CanAllowThrough(): (atom/movable/mover, border_dir)
#ifndef COMSIG_LIVING_CAN_ALLOW_THROUGH
#define COMSIG_LIVING_CAN_ALLOW_THROUGH "living_can_allow_through"
#endif
#ifndef COMPONENT_LIVING_PASSABLE
#define COMPONENT_LIVING_PASSABLE (1<<0)
#endif

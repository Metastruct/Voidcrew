// Defines for the ported LOOC (Local OOC) feature.
//
// LOOC was removed from upstream /tg/ long ago and Voidcrew never carried it, so
// these are additive rather than overrides. The only LOOC define that must live in
// core is MUTE_LOOC (the admin mute UI in code/__DEFINES/admin.dm references it);
// everything else is consumed by modular_bubber code only.
//
// PORTED FROM: Bubberstation code/__DEFINES/~skyrat_defines/{say,chat,keybindings,banning,span}.dm

#ifndef LOOC_CHANNEL
#define LOOC_CHANNEL "LOOC"
#endif
#ifndef WHIS_CHANNEL
#define WHIS_CHANNEL "Whis"
#endif

#ifndef LOOC_RANGE
#define LOOC_RANGE 7
#endif

#ifndef COMSIG_KB_CLIENT_LOOC_DOWN
#define COMSIG_KB_CLIENT_LOOC_DOWN "keybinding_client_looc_down"
#endif
#ifndef COMSIG_KB_CLIENT_WHISPER_DOWN
#define COMSIG_KB_CLIENT_WHISPER_DOWN "keybinding_client_whisper_down"
#endif

#ifndef BAN_LOOC
#define BAN_LOOC "LOOC"
#endif

#ifndef span_rlooc
#define span_rlooc(str) ("<span class='rlooc'>" + str + "</span>")
#endif

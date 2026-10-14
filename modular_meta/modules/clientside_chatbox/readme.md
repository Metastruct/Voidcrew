# clientside_chatbox

Makes the TGUI say popup open **client-side** instead of round-tripping through the
server, so the chatbox isn't gated on ping. Ported from the user's Bubberstation
`modular_zzmeta` "instant-chatbox" PR (#24) plus its follow-up modifier fix.

## Files

- `code/client_procs.dm` - `/client/update_special_keybinds()` override plus
  `set_instant_open_macros()`. Binds `tgui_say_create_open_command(channel)` straight
  into the BYOND macro for the say/radio/ooc/me/looc/whisper hotkeys, extending the
  trick core already uses for `ADMIN_CHANNEL`.
- `code/tgui_preference.dm` - rebuilds the macros when the `tgui_input` toggle changes.
- Core hook: `code/modules/keybindings/bindings_client.dm` (`META EDIT -
  INSTANT_OPEN_MODIFIER_GUARD`) releases the macros while Ctrl/Alt/Shift is held and
  re-arms them on release, so e.g. `Ctrl+L` doesn't also open LOOC - a static winset
  command can't see the modifier state at fire time.
- `tgui/packages/tgui-say/helpers.ts` - `windowOpen()` focuses the browser itself, so
  a client-local open needs no server `winset()` to grab focus.

## Notes

- The per-channel `down()` procs still exist and run when `tgui_input` is off (native
  `input()` box) or when a key is shared with another keybind.
- Voidcrew has no `PRAY_CHANNEL`, so it is omitted from the channel list.
- `set_instant_open_macros()` reconciles rather than early-returns: it rebuilds the
  wanted key set and unbinds anything stale, so a rebind (and toggling `tgui_input`
  off, which must also unbind) takes effect immediately.

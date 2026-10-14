# precise_drop

`Drop Item (Specific)` (**Ctrl+X** by default): drops the item in your active hand
at the turf under your mouse cursor, within reach, keeping a pixel offset instead
of snapping to the tile centre. Pairs with the pixel-shift module for arranging
objects off-grid.

## Files

- `code/precise_drop.dm` - the `/datum/keybinding/mob/drop_item_specific` keybind.
- Core hook: `code/modules/keybindings/bindings_client.dm` now forwards the
  mouse-offset residuals (`click_data[2]`, `click_data[3]`) into
  `keybinding.down()`. `get_loc_from_mousepos()` already computed them; Voidcrew
  was discarding them, so the keybind would always place at offset 0 without it.

## Notes

- Uses the same `COMSIG_KB_MOB_DROPITEM_DOWN` signal as the plain drop keybind,
  matching upstream, so special holders (parrot, MOD suit, arm augment, ...) still
  see the keypress.
- Delegates placement to `transfer_item_to_turf()`, which sets
  `pixel_x = base_pixel_x + x_offset` / `pixel_y = base_pixel_y + y_offset`.
- Ported from upstream /tg/ PR #93790; Voidcrew predates it.

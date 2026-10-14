# pixel_shift

Lets a living mob nudge their sprite (and the item or mob they are pulling) around
inside their tile for RP poses, and tilt their sprite. Ported from Bubberstation's
`modular_skyrat/modules/pixel_shift`.

## Keybinds

| Key | Action | Notes |
|---|---|---|
| `V` | Item Pixel Shift | Nudges the item you're pulling; if you're pulling a mob, nudges them instead. |
| `B` | Pixel Shift | Nudges your own sprite. Also bound to Resist, which is fine - up to 5 keybinds can share a key. |
| `N` | Pixel Tilt | Rotates your sprite up to 45 degrees. |

Hold the key and move in a direction to shift; movement is blocked while shifting
(the component consumes the pre-move signal). Moving normally cancels your own shift.

## Files

- `code/pixel_shift_component.dm` - `/datum/component/pixel_shift`.
- `code/pixel_shift_keybind.dm` - the three `/datum/keybinding/living` entries.
- `code/pixel_shift_living.dm` - overrides `CanAllowThrough()`,
  `set_pull_offsets()` and `reset_pull_offsets()` on `/mob/living` (no upstream
  file edits needed).
- `modular_bubber/__DEFINES/pixel_shift.dm` - the keybind + grab signals.

## Behaviour notes

- Once shifted past `passthrough_threshold` (8 px) towards a tile edge, the mob
  becomes passable from that direction so people can walk past someone standing
  against a wall. Getting grabbed re-validates that privilege.
- Anyone buckled **to** a shifted mob (piggyback, fireman carry) moves with them,
  and a pulled mob can be nudged with Item Pixel Shift. Both extras come from
  Bubber's later pixel-shift fixes and are included here.

## Porting notes

`PORTED FROM` headers carry the original Bubber paths. The only adaptation is the
keybind `down()`/`up()` signatures, which Voidcrew calls with `(client/user)` only.

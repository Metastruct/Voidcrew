# modular_bubber

Everything we ported from Bubberstation (its `modular_skyrat` and `modular_zubbers`
layers): species, sprite accessories, body markings, organs, genitals, the synth,
teshari and shadekin parts, the matrixed-colour renderer, and the tools that generate
most of the content.

Our own changes are in [`modular_meta/`](../modular_meta/readme.md). Both layers are
pulled in at the end of `tgstation.dme`.

## Rules

- New ported files go here, mirroring the Bubber or upstream path where it makes sense:
  `code/modules/surgery/organs/external/foo.dm` becomes
  `modular_bubber/code/modules/surgery/organs/external/foo.dm`.
- An edit to a core file is tagged `// PORT EDIT - ADDITION/CHANGE - START/END - <FEATURE>`
  (our own hooks use `META EDIT`). When it changes an existing line, leave the old one
  behind in a `// ORIGINAL:` comment.
- Prefer redeclaring a type here over editing core. Changing a var initialiser is fine,
  because the later declaration wins. Changing a proc is not: DM refuses to compile two
  definitions of the same proc on one type, so a change inside a core proc has to stay an
  inline tagged edit. Do not copy a core proc here to work around that.
- Icons keep their upstream name and relative path, split by source so the two `ears.dmi`
  files cannot collide:
  - `modular_skyrat/master_files/icons/<x>` -> `modular_bubber/icons/skyrat/<x>`
  - `modular_skyrat/modules/<mod>/icons/<x>` -> `modular_bubber/icons/skyrat/<mod>/<x>`
  - `modular_zubbers/icons/<x>` -> `modular_bubber/icons/zubbers/<x>`
  - `modular_bubber/icons/tg/<x>` for the few upstream `/tg/` ports.

  So `modular_bubber/icons/skyrat/mob/sprite_accessory/ears.dmi` is just Bubber's
  `ears.dmi`. Nothing gets a prefix.

- Add each new `.dm` file to `modular_bubber/modular_bubber.dme`.

## Generated content

Most accessory, hair and marking files are generated. Change the script, not the output.
The scripts are local-only for now.

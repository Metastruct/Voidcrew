# modular_meta

Our own changes to Voidcrew. Same idea as Bubberstation's `modular_zzmeta`.

The ported customization content lives in [`modular_bubber/`](../modular_bubber/readme.md).
Both layers are pulled in at the end of `tgstation.dme`.

## Rules

Put new files here, mirroring the upstream path where that makes sense, and add each new
`.dm` file to `modular_meta/modular_meta.dme`.

An edit to a core file is tagged `META EDIT` if it is our change and `PORT EDIT` if it
only exists so ported content works. When an edit changes an existing line, leave the
old one behind in a `// ORIGINAL:` comment.

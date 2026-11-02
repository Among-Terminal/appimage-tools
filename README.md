# appimage-tools

Verified copies of the programs [Among Terminal](https://github.com/Among-Terminal/among) uses to
build its AppImage: `linuxdeploy`, `appimagetool`, `runtime` and `linuxdeploy-plugin-gtk.sh`.

Upstream URLs change in place: `continuous` is replaced on every build, and the files of a regular
tag can be overwritten too. When that happens the pinned sha256 stops matching and the AppImage
build fails with no change on our side. The among build therefore takes these files only from
releases of this repository: an immutable release cannot be replaced, and a new tool version
arrives only by a separate decision.

Files are published unmodified, byte-for-byte equal to the upstream files.

## Where each file comes from

Release [`2026.11.02`](https://github.com/Among-Terminal/appimage-tools/releases/tag/2026.11.02),
verified on 2026-11-02. The same values are available in machine-readable form in `pins/tools.tsv`,
which is what the scripts read.

| File | Source | Commit | Upstream file date | sha256 |
|---|---|---|---|---|
| `linuxdeploy-x86_64.AppImage` | [linuxdeploy `1-alpha-20251107-1`](https://github.com/linuxdeploy/linuxdeploy/releases/tag/1-alpha-20251107-1) | `cc7b86472c3caa3fd729b9dc502fd2aa78394257` | 2025-11-07 | `c20cd71e3a4e3b80c3483cef793cda3f4e990aca14014d23c544ca3ce1270b4d` |
| `linuxdeploy-aarch64.AppImage` | same | same | 2025-11-07 | `620095110d693282b8ebeb244a95b5e911cf8f65f76c88b4b47d16ae6346fcff` |
| `appimagetool-x86_64.AppImage` | [appimagetool `1.9.1`](https://github.com/AppImage/appimagetool/releases/tag/1.9.1) | `8c8c91f762b412a19f4e8d2c4b35afb98f2d7c81` | 2025-12-04 | `ed4ce84f0d9caff66f50bcca6ff6f35aae54ce8135408b3fa33abfc3cb384eb0` |
| `appimagetool-aarch64.AppImage` | same | same | 2025-12-04 | `f0837e7448a0c1e4e650a93bb3e85802546e60654ef287576f46c71c126a9158` |
| `runtime-x86_64` | [type2-runtime `continuous`](https://github.com/AppImage/type2-runtime/releases/tag/continuous) | `fedfad51acc2860b2916a1eef32ba4a500ff31ef` | 2026-10-19 | `617aa77314d57c8b8e4fae9c3f0b35af7b30d5529cb69e98f64f92510ed98a46` |
| `runtime-aarch64` | same | same | 2026-10-19 | `9a72a744d221576c9347ec074243acc5c3c7568896b12714e0e82e9f0bf47900` |
| `linuxdeploy-plugin-gtk.sh` | [linuxdeploy-plugin-gtk](https://github.com/linuxdeploy/linuxdeploy-plugin-gtk/blob/7a3fbc31a9e5075073ff8790f26effbac5f84453/linuxdeploy-plugin-gtk.sh) | `7a3fbc31a9e5075073ff8790f26effbac5f84453` | 2026-07-02 | `b0f4cbc684a0103a9651f0955b635eaea0096b3a66c0f5a2c2aa337960375171` |

The `continuous` tag for `runtime` was kept deliberately: as of 2026-11-02 upstream still served
these bytes under it, while tag `20251108` contains a different build. The previously pinned
`linuxdeploy` file from `continuous` was not found in any tag, so the latest tag was taken.

The release also contains:

| File | Contents |
|---|---|
| `NOTICE.md` | what each file consists of, versions, licenses, the evidence for each version |
| `licenses.tar.gz` | license texts taken from the source archives |
| `sources.tar` | sources of all components; listed in `pins/sources.tsv` |
| `SHA256SUMS` | checksums of all release files |

## Licenses

Each component is distributed under its own terms; contents and versions are described in
[NOTICE.md](NOTICE.md). The tools themselves are MIT, but inside the AppImages there are statically
linked GPL programs (`strip`, `patchelf`, `mksquashfs`, `desktop-file-validate`) and LGPL libraries
(glibc, glib, libfuse and others). That is why `sources.tar` is part of every release: the sources
are in the same place as the binaries. This repository's own scripts and tables are Apache-2.0, see
[LICENSE](LICENSE); that license does not apply to the release files.

## Updating a tool

An update is always a separate PR, and no file of a published release is replaced. Enabled immutable
releases (`gh api repos/Among-Terminal/appimage-tools/immutable-releases`) forbid changing files and
the tag, and the tag name of a deleted release can never be reused, so a mistake can only be fixed by
a new release.

1. Choose an upstream version and check the licenses: the texts in its sources and the contents of
   the AppImage itself. It can be unpacked without running it: `unsquashfs -o <offset>`, where the
   offset is the end of the ELF header.
2. Open a PR in this repository: update `pins/tools.tsv`, `pins/sources.tsv`, `pins/licenses.tsv` and
   `NOTICE.md`, and add a new table in this file.
3. After merging, assemble the files and create a draft with a tag of the form `YYYY.MM.DD`:

   ```sh
   scripts/assemble-release.sh ~/.cache/appimage-tools/dist ~/.cache/appimage-tools/downloads
   gh release create <tag> --draft --repo Among-Terminal/appimage-tools \
     --target main --title <tag> --notes-file <file> ~/.cache/appimage-tools/dist/*
   ```

4. Verify the draft and only then publish it, because nothing can be fixed after publication:

   ```sh
   scripts/verify-release.sh <tag> ~/.cache/appimage-tools/verify-draft
   gh release edit <tag> --draft=false --repo Among-Terminal/appimage-tools
   scripts/verify-release.sh <tag> ~/.cache/appimage-tools/verify-published
   ```

5. In a separate PR to `Among-Terminal/among`, replace the release tag and sha256 in
   `tools/among-tools/src/appimage_tools.rs`. The AppImage build in that PR's CI is the check of the
   new version.

`verify-release.sh` compares the file list, `SHA256SUMS`, the pinned values and freshly downloaded
upstream files, so it fails once a file is replaced upstream. Old releases keep working: `among` is
pinned to its own tag.

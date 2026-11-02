# File contents and licenses

The release files were not modified or rebuilt here: they are the same bytes upstream published
(URLs and sha256 in `pins/tools.tsv`). The AppImage images contain no license files at all, so all
the texts are provided separately in `licenses.tar.gz`, and the corresponding sources in `sources.tar`
(listed with URLs and sha256 in `pins/sources.tsv`). Both archives are part of every release.

Source code offer. Source code for the GPL and LGPL components is provided together with the
binaries from the same place: `sources.tar` of the same release. It also holds the components in the
tables below, except the Alpine 3.21 zlib, which is permissive; see the `runtime-*` section.
Build scripts are in the project repositories (`ci/`, `scripts/`), and Alpine and Debian
patches sit next to the source archives. Directories inside `sources.tar`:

- `projects/`: project sources;
- `debian-trixie-20251107/`: Debian packages (`.dsc`, `orig`, `debian`) from the
  snapshot.debian.org snapshot of 2025-11-07;
- `alpine-3.19/`, `alpine-3.21/`: archives from distfiles.alpinelinux.org. Alpine 3.19 also has the
  aports build files (commit `838df6872ddf3260a834ad304c71f5e03901bb06`, branch `3.19-stable`).
  Alpine 3.21 has the build files of gcc only (commit `8f01bd5af18e4f66b7df105bdd7cab10de2ee1fa`,
  branch `3.21-stable`); its other packages here (musl, zstd, mimalloc) are permissive.

## linuxdeploy (`linuxdeploy-*.AppImage`, tag `1-alpha-20251107-1`)

Built in the `debian:stable` image (trixie as of 2025-11-07); all programs are statically linked.

| Component | Version | License | Version evidence |
|---|---|---|---|
| linuxdeploy | `cc7b864` | MIT | tag |
| linuxdeploy-desktopfile, cmake-scripts, args | submodules `bea49b1`, `df32987`, `3de44ec` | MIT | commit tree |
| patchelf (`usr/bin/patchelf`) | 0.15.0 | GPL-3.0-or-later | `ci/docker/install-static-patchelf.sh`, string in the binary |
| strip from binutils (`usr/bin/strip`) | 2.35 | GPL-3.0-or-later | `ci/docker/install-static-binutils.sh` |
| zlib inside `strip` | 1.2.11, from the binutils source tree | Zlib | string `inflate 1.2.11` in the binary, `zlib/zlib.h` in binutils 2.35 |
| glibc | 2.41-12 | LGPL-2.1-or-later | Debian snapshot at the build date |
| libstdc++, libgcc | gcc-14 14.2.0-19 | GPL-3.0 with GCC Runtime Library Exception | `.comment` of the binaries, Debian snapshot |
| CImg | 3.5.2+dfsg-1 | CeCILL-C | `cimg-dev` in `ci/docker/Dockerfile`, Debian snapshot |
| libjpeg-turbo | 2.1.5-4 | IJG, BSD-3-Clause, Zlib | Debian snapshot |
| libpng | 1.6.48-1 | libpng-2.0 | string `libpng version 1.6.48` in the binary |
| zlib | 1.3.1 | Zlib | Debian snapshot |
| linuxdeploy-plugin-appimage | `f62e84f` | MIT | last commit before the 2025-11-07 build: `ci/build.sh` clones the default branch |
| args | `bd0429e` | MIT | submodule of linuxdeploy-plugin-appimage |

This software is based in part on the work of the Independent JPEG Group.

The directory `plugins/linuxdeploy-plugin-appimage/appimagetool-prefix` contains a separate
appimagetool build: commit `07aa21f`, 2025-10-19, with bytes different from tag 1.9.1 but the same
build recipe (`git diff 07aa21f 8c8c91f -- ci` is empty), so its contents match the next section.

## appimagetool (`appimagetool-*.AppImage`, tag `1.9.1`)

Built in the `alpine:3.19` image by `ci/build-in-docker.sh`; all programs are statically linked.
The Alpine index keeps no past revisions, so a package version counts as proven if the current
revision was published before the build (`t:` in APKINDEX) and the aports directory did not change
between 2025-10-19 and 2025-12-04. This holds for every row except musl: its current revision is
newer than the build, and `sources.tar` contains the r5 recipe in effect at the build date.

| Component | Version | License |
|---|---|---|
| appimagetool | `8c8c91f` | MIT |
| mksquashfs from squashfs-tools | 4.6.1 | GPL-2.0-or-later |
| desktop-file-validate from desktop-file-utils | 0.28 | GPL-2.0-or-later |
| zsyncmake from zsync | 0.6.2 with the patch and the `off_t` to `size_t` replacement from `ci/install-static-zsyncmake.sh` | Artistic License 2.0beta4, bundled zlib 1.2.1.1 under Zlib |
| glib | 2.78.6-r0 | LGPL-2.1-or-later |
| gpgme | 1.23.2-r0 | LGPL-2.1-or-later |
| libgcrypt | 1.10.3-r0 | LGPL-2.1-or-later |
| libgpg-error | 1.47-r2 | LGPL-2.1-or-later |
| libassuan | 2.5.6-r1 | LGPL-2.1-or-later |
| libidn2 | 2.3.4-r4 | LGPL-3.0-or-later or GPL-2.0-or-later |
| libunistring | 1.1-r2 | LGPL-3.0-or-later or GPL-2.0-or-later |
| libintl from gettext | 0.22.3-r0 | LGPL-2.1-or-later |
| curl | 8.14.1-r2 | curl |
| openssl | 3.1.8-r1 | Apache-2.0 |
| nghttp2 | 1.58.0-r0 | MIT |
| brotli | 1.1.0-r1 | MIT |
| c-ares | 1.27.0-r0 | MIT |
| libpsl | 0.21.5-r0 | MIT |
| pcre2 | 10.42-r2 | BSD-3-Clause |
| libffi | 3.4.4-r3 | MIT |
| zlib | 1.3.1-r0 | Zlib |
| zstd | 1.5.5-r8 | BSD-3-Clause or GPL-2.0-only |
| musl | 1.2.4_git20230717-r5 | MIT |
| libstdc++, libgcc | gcc 13.2.1_git20231014-r0 | GPL-3.0 with GCC Runtime Library Exception |

libstdc++ is linked into `usr/bin/appimagetool` only. `argp-standalone` is a build dependency of
appimagetool, but none of the four programs contains its code; its archive stays in `sources.tar`.

## Embedded AppImage header and `runtime-*`

Every AppImage image starts with type2-runtime. These are different builds of one recipe:

| Where | type2-runtime commit | Evidence |
|---|---|---|
| `runtime-x86_64`, `runtime-aarch64` | `fedfad5` | tag `continuous`, build log 39320578745 |
| header of `appimagetool-*.AppImage` | `caf24f9` | version string in the binary |
| header of `linuxdeploy-*.AppImage` | `61e6688` | version string in the binary |

| Component | Version | License |
|---|---|---|
| type2-runtime | see above | MIT |
| libfuse | 3.15.0 with `patches/libfuse/mount.c.diff` | LGPL-2.1-only for the library |
| squashfuse | 0.5.2 | BSD-2-Clause |
| mimalloc | 2.1.7-r0 | MIT |
| musl | 1.2.5-r11 | MIT |
| zstd | 1.5.6-r2 | BSD-3-Clause or GPL-2.0-only |
| zlib | the log shows 1.3.2-r1 for `fedfad5` | Zlib |
| libgcc, aarch64 builds only | gcc 14.2.0-r4 | GPL-3.0 with GCC Runtime Library Exception |

Alpine versions are taken from the `fedfad5` build log. The build logs of `caf24f9` and `61e6688`
have already been deleted on GitHub, so the revisions of their Alpine 3.21 packages are unconfirmed.
These are permissive packages; the libfuse and squashfuse versions for those commits are pinned in
their `scripts/common/install-dependencies.sh`.
The zlib archive for Alpine 3.21 is not in `sources.tar`: the zlib license text is in `licenses.tar.gz`.

## linuxdeploy-plugin-gtk.sh

The `linuxdeploy-plugin-gtk` script at commit `7a3fbc3`, MIT.

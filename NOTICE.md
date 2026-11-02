# Состав файлов и лицензии

Файлы релиза не менялись и не пересобирались здесь: это те же байты, что опубликовал upstream
(адреса и sha256 в `pins/tools.tsv`). Внутри образов AppImage нет ни одного файла лицензии,
поэтому все тексты лежат отдельно в `licenses.tar.gz`, а соответствующие исходники в `sources.tar`
(перечень с адресами и sha256 в `pins/sources.tsv`). Оба архива входят в каждый релиз.

Предложение исходников. Исходный код компонентов под GPL и LGPL (и остальных компонентов из
таблиц ниже) предоставляется вместе с бинарными файлами из того же места: `sources.tar` того же
релиза. Сценарии сборки находятся в репозиториях проектов (`ci/`, `scripts/`), а патчи Alpine и
Debian лежат рядом с исходными архивами. Каталоги внутри `sources.tar`:

- `projects/`: исходники проектов;
- `debian-trixie-20251107/`: пакеты Debian (`.dsc`, `orig`, `debian`) из снимка
  snapshot.debian.org от 2025-11-07;
- `alpine-3.19/`, `alpine-3.21/`: архивы с distfiles.alpinelinux.org, для 3.19 ещё и файлы сборки
  aports (коммит `838df6872ddf3260a834ad304c71f5e03901bb06`, ветка `3.19-stable`).

## linuxdeploy (`linuxdeploy-*.AppImage`, тег `1-alpha-20251107-1`)

Сборка в образе `debian:stable` (trixie на 2025-11-07), все программы связаны статически.

| Компонент | Версия | Лицензия | Откуда версия |
|---|---|---|---|
| linuxdeploy | `cc7b864` | MIT | тег |
| linuxdeploy-desktopfile, cmake-scripts, args | подмодули `bea49b1`, `df32987`, `3de44ec` | MIT | дерево коммита |
| patchelf (`usr/bin/patchelf`) | 0.15.0 | GPL-3.0-or-later | `ci/docker/install-static-patchelf.sh`, строка в бинарнике |
| strip из binutils (`usr/bin/strip`) | 2.35 | GPL-3.0-or-later | `ci/docker/install-static-binutils.sh` |
| glibc | 2.41-12 | LGPL-2.1-or-later | снимок Debian на дату сборки |
| libstdc++, libgcc | gcc-14 14.2.0-19 | GPL-3.0 с GCC Runtime Library Exception | `.comment` бинарников, снимок Debian |
| CImg | 3.5.2+dfsg-1 | CeCILL-C | `cimg-dev` в `ci/docker/Dockerfile`, снимок Debian |
| libjpeg-turbo | 2.1.5-4 | IJG, BSD-3-Clause, Zlib | снимок Debian |
| libpng | 1.6.48-1 | libpng-2.0 | строка `libpng version 1.6.48` в бинарнике |
| zlib | 1.3.1 | Zlib | снимок Debian |
| linuxdeploy-plugin-appimage | `f62e84f` | MIT | последний коммит до сборки 2025-11-07: `ci/build.sh` клонирует ветку по умолчанию |
| args | `bd0429e` | MIT | подмодуль linuxdeploy-plugin-appimage |

This software is based in part on the work of the Independent JPEG Group.

В каталоге `plugins/linuxdeploy-plugin-appimage/appimagetool-prefix` лежит отдельная сборка
appimagetool: коммит `07aa21f`, 2025-10-19, с байтами, отличными от тега 1.9.1, но тем же рецептом
сборки (`git diff 07aa21f 8c8c91f -- ci` пуст), поэтому состав совпадает со следующим разделом.

## appimagetool (`appimagetool-*.AppImage`, тег `1.9.1`)

Сборка в образе `alpine:3.19` по `ci/build-in-docker.sh`, все программы связаны статически.
Индекс Alpine не хранит прошлых ревизий, поэтому версия пакета считается доказанной, если текущая
ревизия опубликована раньше сборки (`t:` в APKINDEX) и каталог aports не менялся между 2025-10-19
и 2025-12-04. Это выполнено для всех строк, кроме musl: у него текущая ревизия новее сборки, и в
`sources.tar` лежит рецепт r5, действовавший на дату сборки.

| Компонент | Версия | Лицензия |
|---|---|---|
| appimagetool | `8c8c91f` | MIT |
| mksquashfs из squashfs-tools | 4.6.1 | GPL-2.0-or-later |
| desktop-file-validate из desktop-file-utils | 0.28 | GPL-2.0-or-later |
| zsyncmake из zsync | 0.6.2 с патчем и заменой `off_t` на `size_t` из `ci/install-static-zsyncmake.sh` | Artistic License 2.0beta4, встроенный zlib 1.2.1.1 под Zlib |
| glib | 2.78.6-r0 | LGPL-2.1-or-later |
| gpgme | 1.23.2-r0 | LGPL-2.1-or-later |
| libgcrypt | 1.10.3-r0 | LGPL-2.1-or-later |
| libgpg-error | 1.47-r2 | LGPL-2.1-or-later |
| libassuan | 2.5.6-r1 | LGPL-2.1-or-later |
| libidn2 | 2.3.4-r4 | LGPL-3.0-or-later или GPL-2.0-or-later |
| libunistring | 1.1-r2 | LGPL-3.0-or-later или GPL-2.0-or-later |
| libintl из gettext | 0.22.3-r0 | LGPL-2.1-or-later |
| argp-standalone | 1.5.0-r1 | LGPL-2.0-or-later по заголовкам файлов, отдельного файла лицензии в архиве нет |
| curl | 8.14.1-r2 | curl |
| openssl | 3.1.8-r1 | Apache-2.0 |
| nghttp2 | 1.58.0-r0 | MIT |
| brotli | 1.1.0-r1 | MIT |
| c-ares | 1.27.0-r0 | MIT |
| libpsl | 0.21.5-r0 | MIT |
| pcre2 | 10.42-r2 | BSD-3-Clause |
| libffi | 3.4.4-r3 | MIT |
| zlib | 1.3.1-r0 | Zlib |
| zstd | 1.5.5-r8 | BSD-3-Clause или GPL-2.0-only |
| musl | 1.2.4_git20230717-r5 | MIT |
| libgcc | gcc 13.2.1_git20231014-r0 | GPL-3.0 с GCC Runtime Library Exception |

## Встроенный заголовок AppImage и `runtime-*`

Каждый образ AppImage начинается с type2-runtime. Это разные сборки одного рецепта:

| Где | Коммит type2-runtime | Откуда |
|---|---|---|
| `runtime-x86_64`, `runtime-aarch64` | `fedfad5` | тег `continuous`, журнал сборки 39320578745 |
| заголовок `appimagetool-*.AppImage` | `caf24f9` | строка версии в бинарнике |
| заголовок `linuxdeploy-*.AppImage` | `61e6688` | строка версии в бинарнике |

| Компонент | Версия | Лицензия |
|---|---|---|
| type2-runtime | см. выше | MIT |
| libfuse | 3.15.0 с `patches/libfuse/mount.c.diff` | LGPL-2.1-only для библиотеки |
| squashfuse | 0.5.2 | BSD-2-Clause |
| mimalloc | 2.1.7-r0 | MIT |
| musl | 1.2.5-r11 | MIT |
| zstd | 1.5.6-r2 | BSD-3-Clause или GPL-2.0-only |
| zlib | журнал показывает 1.3.2-r1 для `fedfad5` | Zlib |

Версии Alpine взяты из журнала сборки `fedfad5`. Журналы сборок `caf24f9` и `61e6688` на GitHub уже
удалены, поэтому ревизии их пакетов Alpine 3.21 не подтверждены. Это пермиссивные пакеты; версии
libfuse и squashfuse для этих коммитов закреплены в их `scripts/common/install-dependencies.sh`.
Архив zlib для Alpine 3.21 в `sources.tar` не входит: текст лицензии zlib есть в `licenses.tar.gz`.

## linuxdeploy-plugin-gtk.sh

Скрипт `linuxdeploy-plugin-gtk` на коммите `7a3fbc3`, MIT.

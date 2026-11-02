# appimage-tools

Проверенные копии программ, которыми [Among Terminal](https://github.com/Among-Terminal/among)
собирает AppImage: `linuxdeploy`, `appimagetool`, `runtime` и `linuxdeploy-plugin-gtk.sh`.

Адреса upstream меняются на месте: `continuous` заменяется при каждой сборке, а файлы обычного
тега тоже можно перезаписать. Закреплённый sha256 в такой момент перестаёт совпадать, и сборка AppImage
падает без единой правки с нашей стороны. Сборка among поэтому берёт файлы только из релизов этого
репозитория: неизменяемый релиз нельзя заменить, а новая версия инструмента появляется отдельным
решением.

Файлы публикуются без изменений, побайтно равными файлам upstream.

## Откуда каждый файл

Релиз [`2026.11.02`](https://github.com/Among-Terminal/appimage-tools/releases/tag/2026.11.02),
проверено 2026-11-02. Эти же значения машиночитаемо лежат в `pins/tools.tsv`, откуда их берут скрипты.

| Файл | Источник | Коммит | Дата файла upstream | sha256 |
|---|---|---|---|---|
| `linuxdeploy-x86_64.AppImage` | [linuxdeploy `1-alpha-20251107-1`](https://github.com/linuxdeploy/linuxdeploy/releases/tag/1-alpha-20251107-1) | `cc7b86472c3caa3fd729b9dc502fd2aa78394257` | 2025-11-07 | `c20cd71e3a4e3b80c3483cef793cda3f4e990aca14014d23c544ca3ce1270b4d` |
| `linuxdeploy-aarch64.AppImage` | то же | то же | 2025-11-07 | `620095110d693282b8ebeb244a95b5e911cf8f65f76c88b4b47d16ae6346fcff` |
| `appimagetool-x86_64.AppImage` | [appimagetool `1.9.1`](https://github.com/AppImage/appimagetool/releases/tag/1.9.1) | `8c8c91f762b412a19f4e8d2c4b35afb98f2d7c81` | 2025-12-04 | `ed4ce84f0d9caff66f50bcca6ff6f35aae54ce8135408b3fa33abfc3cb384eb0` |
| `appimagetool-aarch64.AppImage` | то же | то же | 2025-12-04 | `f0837e7448a0c1e4e650a93bb3e85802546e60654ef287576f46c71c126a9158` |
| `runtime-x86_64` | [type2-runtime `continuous`](https://github.com/AppImage/type2-runtime/releases/tag/continuous) | `fedfad51acc2860b2916a1eef32ba4a500ff31ef` | 2026-10-19 | `617aa77314d57c8b8e4fae9c3f0b35af7b30d5529cb69e98f64f92510ed98a46` |
| `runtime-aarch64` | то же | то же | 2026-10-19 | `9a72a744d221576c9347ec074243acc5c3c7568896b12714e0e82e9f0bf47900` |
| `linuxdeploy-plugin-gtk.sh` | [linuxdeploy-plugin-gtk](https://github.com/linuxdeploy/linuxdeploy-plugin-gtk/blob/7a3fbc31a9e5075073ff8790f26effbac5f84453/linuxdeploy-plugin-gtk.sh) | `7a3fbc31a9e5075073ff8790f26effbac5f84453` | 2026-07-02 | `b0f4cbc684a0103a9651f0955b635eaea0096b3a66c0f5a2c2aa337960375171` |

Тег `continuous` у `runtime` оставлен осознанно: на 2026-11-02 upstream всё ещё отдавал по нему
эти байты, а тег `20251108` содержит другую сборку. Для `linuxdeploy` прежний закреплённый файл
из `continuous` не нашёлся ни в одном теге, поэтому взят последний тег.

Кроме них в релизе лежат:

| Файл | Содержимое |
|---|---|
| `NOTICE.md` | из чего состоит каждый файл, версии, лицензии, основание для версии |
| `licenses.tar.gz` | тексты лицензий, взятые из исходных архивов |
| `sources.tar` | исходники всех компонентов; перечень в `pins/sources.tsv` |
| `SHA256SUMS` | контрольные суммы всех файлов релиза |

## Лицензии

Каждый компонент распространяется на своих условиях, состав и версии описаны в
[NOTICE.md](NOTICE.md). Сами инструменты под MIT, но внутри AppImage статически связаны программы
под GPL (`strip`, `patchelf`, `mksquashfs`, `desktop-file-validate`) и библиотеки под LGPL (glibc,
glib, libfuse и другие). Поэтому `sources.tar` входит в каждый релиз: исходники лежат в том же месте,
что и бинарные файлы. Собственные скрипты и таблицы этого репозитория под Apache-2.0, см. [LICENSE](LICENSE);
на файлы релиза эта лицензия не распространяется.

## Как обновить инструмент

Обновление всегда идёт отдельным PR, ни один файл опубликованного релиза не заменяется. Включённые
неизменяемые релизы (`gh api repos/Among-Terminal/appimage-tools/immutable-releases`) запрещают
менять файлы и тег, а имя тега удалённого релиза больше не используется, поэтому ошибка исправляется
только новым релизом.

1. Выбрать версию upstream и проверить лицензии: тексты в её исходниках и состав самого AppImage.
   Распаковывается он без запуска: `unsquashfs -o <смещение>`, где смещение равно концу ELF заголовка.
2. PR в этот репозиторий: правка `pins/tools.tsv`, `pins/sources.tsv`, `pins/licenses.tsv` и
   `NOTICE.md`, новая таблица в этом файле.
3. После вливания собрать файлы и создать черновик с тегом вида `ГГГГ.ММ.ДД`:

   ```sh
   scripts/assemble-release.sh ~/.cache/appimage-tools/dist ~/.cache/appimage-tools/downloads
   gh release create <тег> --draft --repo Among-Terminal/appimage-tools \
     --target main --title <тег> --notes-file <файл> ~/.cache/appimage-tools/dist/*
   ```

4. Проверить черновик и только затем опубликовать, потому что после публикации исправить ничего нельзя:

   ```sh
   scripts/verify-release.sh <тег> ~/.cache/appimage-tools/verify-draft
   gh release edit <тег> --draft=false --repo Among-Terminal/appimage-tools
   scripts/verify-release.sh <тег> ~/.cache/appimage-tools/verify-published
   ```

5. Отдельным PR в `Among-Terminal/among` заменить тег релиза и sha256 в
   `tools/among-tools/src/appimage_tools.rs`. Сборка AppImage в CI этого PR и есть проверка новой версии.

`verify-release.sh` сверяет список файлов, `SHA256SUMS`, закреплённые значения и повторно скачанные
файлы upstream, так что после замены файла на стороне upstream он упадёт. Старые релизы при этом
остаются рабочими: `among` закреплён на своём теге.

#!/usr/bin/env bash
# Builds the complete asset set of one release into an empty directory.
#
# Usage: scripts/assemble-release.sh <new-empty-dist-dir> [download-cache-dir]
#
# Every input is fetched from the address in pins/ and refused unless its
# SHA-256 matches, so a run either yields exactly the reviewed bytes or stops.
# The cache only spares repeated downloads; cached files are checked the same way.
set -euo pipefail
export LC_ALL=C

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
dist="${1:?usage: assemble-release.sh <new-empty-dist-dir> [download-cache-dir]}"
cache="${2:-}"

if [[ -e "$dist" ]]; then
    echo "destination must be new: $dist" >&2
    exit 1
fi
mkdir -p "$dist"
staging="$(mktemp -d "$dist.staging.XXXXXX")"
trap 'rm -rf "$staging"' EXIT
if [[ -z "$cache" ]]; then
    cache="$staging/cache"
fi
mkdir -p "$cache"

fetch() {
    local url="$1" sha256="$2" target="$3"
    local cached="$cache/$sha256"
    if [[ ! -s "$cached" ]]; then
        curl --fail --location --silent --show-error --retry 3 --proto '=https' \
            --proto-redir '=https' --output "$cached.part" "$url"
        mv "$cached.part" "$cached"
    fi
    if ! printf '%s  %s\n' "$sha256" "$cached" | sha256sum --check --status; then
        echo "bytes differ from the pin: $url" >&2
        exit 1
    fi
    mkdir -p "$(dirname "$target")"
    cp "$cached" "$target"
}

# Stable archive flags: the same inputs give the same asset bytes on every run.
pack() {
    local directory="$1" name="$2" output="$3"
    tar --create --sort=name --owner=0 --group=0 --numeric-owner --mtime=@0 \
        --format=gnu --directory "$directory" --file "$output" "$name"
}

while IFS=$'\t' read -r asset url _repository _tag _commit sha256 _published; do
    fetch "$url" "$sha256" "$dist/$asset"
done < <(tail -n +2 "$root/pins/tools.tsv")
chmod 0755 "$dist"/*

sources="$staging/sources"
while IFS=$'\t' read -r path url sha256; do
    fetch "$url" "$sha256" "$sources/$path"
done < <(tail -n +2 "$root/pins/sources.tsv")
cp "$root/pins/sources.tsv" "$root/NOTICE.md" "$sources/"
pack "$staging" sources "$dist/sources.tar"

licenses="$staging/licenses"
while IFS=$'\t' read -r name archive member; do
    mkdir -p "$(dirname "$licenses/$name")"
    tar --extract --to-stdout --file "$sources/$archive" "$member" > "$licenses/$name"
    if [[ ! -s "$licenses/$name" ]]; then
        echo "empty license text: $archive $member" >&2
        exit 1
    fi
done < <(tail -n +2 "$root/pins/licenses.tsv")
cp "$root/NOTICE.md" "$licenses/"
pack "$staging" licenses "$staging/licenses.tar"
gzip --no-name --best --stdout "$staging/licenses.tar" > "$dist/licenses.tar.gz"
cp "$root/NOTICE.md" "$dist/"

(
    cd "$dist"
    sha256sum -- * > "$staging/SHA256SUMS"
    mv "$staging/SHA256SUMS" SHA256SUMS
)
echo "assembled $(wc -l < "$dist/SHA256SUMS") files in $dist"

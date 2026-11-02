#!/usr/bin/env bash
# Checks a release (or draft) against pins/ by downloading every asset back.
#
# Usage: scripts/verify-release.sh <tag> <new-empty-directory>
#
# Passing means three independent things: the asset list is exactly the expected
# one, every asset matches SHA256SUMS, and every tool and source archive matches
# its pin. For a tool the upstream asset is fetched again and compared as well, so
# a later change at the upstream address shows up here as a failure.
set -euo pipefail
export LC_ALL=C

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
tag="${1:?usage: verify-release.sh <tag> <new-empty-directory>}"
target="${2:?usage: verify-release.sh <tag> <new-empty-directory>}"
repository=Among-Terminal/appimage-tools

if [[ -e "$target" ]]; then
    echo "destination must be new: $target" >&2
    exit 1
fi
mkdir -p "$target"
gh release download "$tag" --repo "$repository" --dir "$target"

expected="$(
    {
        tail -n +2 "$root/pins/tools.tsv" | cut -f1
        printf '%s\n' NOTICE.md SHA256SUMS licenses.tar.gz sources.tar
    } | sort
)"
actual="$(find "$target" -mindepth 1 -printf '%P\n' | sort)"
if [[ "$expected" != "$actual" ]]; then
    diff <(printf '%s\n' "$expected") <(printf '%s\n' "$actual") >&2 || true
    echo "asset list differs from the expected set" >&2
    exit 1
fi

(cd "$target" && sha256sum --check --quiet SHA256SUMS)
if ! cmp "$root/NOTICE.md" "$target/NOTICE.md"; then
    echo "published NOTICE.md differs from this checkout" >&2
    exit 1
fi

upstream="$(mktemp -d "$target.upstream.XXXXXX")"
trap 'rm -rf "$upstream"' EXIT
while IFS=$'\t' read -r asset url _repository _tag _commit sha256 _published; do
    if [[ "$(sha256sum "$target/$asset" | cut -d' ' -f1)" != "$sha256" ]]; then
        echo "$asset differs from its pin" >&2
        exit 1
    fi
    curl --fail --location --silent --show-error --retry 3 --proto '=https' \
        --proto-redir '=https' --output "$upstream/$asset" "$url"
    if ! cmp "$target/$asset" "$upstream/$asset"; then
        echo "$asset differs from the upstream asset" >&2
        exit 1
    fi
    echo "ok $sha256 $asset"
done < <(tail -n +2 "$root/pins/tools.tsv")

listing="$upstream/listing"
tar --extract --directory "$upstream" --file "$target/sources.tar"
while IFS=$'\t' read -r path _url sha256; do
    if [[ "$(sha256sum "$upstream/sources/$path" | cut -d' ' -f1)" != "$sha256" ]]; then
        echo "$path differs from its pin" >&2
        exit 1
    fi
done < <(tail -n +2 "$root/pins/sources.tsv")
(cd "$upstream/sources" && find . -type f | sed 's|^\./||' | sort) > "$listing"
{
    tail -n +2 "$root/pins/sources.tsv" | cut -f1
    printf '%s\n' NOTICE.md sources.tsv
} | sort > "$listing.expected"
if ! diff "$listing.expected" "$listing" >&2; then
    echo "sources.tar holds other files than pins/sources.tsv" >&2
    exit 1
fi
echo "ok $(wc -l < "$listing.expected") files in sources.tar"
tar --list --gzip --file "$target/licenses.tar.gz" > "$listing.licenses"
echo "ok $(grep -cv '/$' "$listing.licenses") files in licenses.tar.gz"

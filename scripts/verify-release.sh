#!/usr/bin/env bash
# Checks a release (or draft) against pins/ by downloading every asset back.
#
# Usage: scripts/verify-release.sh <tag> <new-empty-directory>
#
# Run it from the checkout that assembled the release: a published tag has to be
# checked out first, because pins and NOTICE.md change between releases.
#
# Passing means the asset list is exactly the expected one, every tool and source
# archive matches its pin, every license text equals the member of the source
# archive named in pins/licenses.tsv, and the asset at each pinned address is
# still the same. SHA256SUMS comes from the release itself, so it only shows that
# the release agrees with itself; the pins are the independent reference.
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
if [[ -n "$(git -C "$root" status --porcelain)" ]]; then
    echo "the checkout has local changes" >&2
    exit 1
fi
expected_commit="$(gh release view "$tag" --repo "$repository" --json targetCommitish \
    --jq .targetCommitish)"
if [[ ! "$expected_commit" =~ ^[0-9a-f]{40}$ ]]; then
    expected_commit="$(gh api "repos/$repository/commits/refs/tags/$tag" --jq .sha)"
fi
if [[ "$expected_commit" != "$(git -C "$root" rev-parse HEAD)" ]]; then
    echo "run this from the commit of $tag: git checkout $expected_commit" >&2
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

work="$(mktemp -d "$target.work.XXXXXX")"
trap 'rm -rf "$work"' EXIT
while IFS=$'\t' read -r asset url _repository _tag _commit sha256 _published; do
    if [[ "$(sha256sum "$target/$asset" | cut -d' ' -f1)" != "$sha256" ]]; then
        echo "$asset differs from its pin" >&2
        exit 1
    fi
    curl --fail --location --silent --show-error --retry 3 --proto '=https' \
        --proto-redir '=https' --output "$work/$asset" "$url"
    if ! cmp "$target/$asset" "$work/$asset"; then
        echo "$asset differs from the pinned address" >&2
        exit 1
    fi
    echo "ok $sha256 $asset"
done < <(tail -n +2 "$root/pins/tools.tsv")

listing="$work/listing"
tar --extract --directory "$work" --file "$target/sources.tar"
while IFS=$'\t' read -r path _url sha256; do
    if [[ "$(sha256sum "$work/sources/$path" | cut -d' ' -f1)" != "$sha256" ]]; then
        echo "$path differs from its pin" >&2
        exit 1
    fi
done < <(tail -n +2 "$root/pins/sources.tsv")
(cd "$work/sources" && find . -type f | sed 's|^\./||' | sort) > "$listing"
{
    tail -n +2 "$root/pins/sources.tsv" | cut -f1
    printf '%s\n' NOTICE.md sources.tsv
} | sort > "$listing.expected"
if ! diff "$listing.expected" "$listing" >&2; then
    echo "sources.tar holds other files than pins/sources.tsv" >&2
    exit 1
fi
echo "ok $(wc -l < "$listing.expected") files in sources.tar"

# A directory of its own: this archive must not be able to overwrite the sources
# that were just checked.
unpacked="$work/license-archive"
mkdir "$unpacked"
tar --extract --gzip --directory "$unpacked" --file "$target/licenses.tar.gz"
while IFS=$'\t' read -r name archive member; do
    if ! tar --extract --to-stdout --file "$work/sources/$archive" "$member" \
        | cmp - "$unpacked/licenses/$name"; then
        echo "license text $name differs from $archive $member" >&2
        exit 1
    fi
done < <(tail -n +2 "$root/pins/licenses.tsv")
for copy in "$work/sources/NOTICE.md" "$unpacked/licenses/NOTICE.md"; do
    if ! cmp "$root/NOTICE.md" "$copy"; then
        echo "a NOTICE.md inside an archive differs from this checkout" >&2
        exit 1
    fi
done
(cd "$unpacked" && find . -type f | sed 's|^\./||' | sort) > "$listing.licenses"
{
    tail -n +2 "$root/pins/licenses.tsv" | cut -f1 | sed 's|^|licenses/|'
    printf '%s\n' licenses/NOTICE.md
} | sort > "$listing.licenses.expected"
if ! diff "$listing.licenses.expected" "$listing.licenses" >&2; then
    echo "licenses.tar.gz holds other files than pins/licenses.tsv" >&2
    exit 1
fi
echo "ok $(wc -l < "$listing.licenses") files in licenses.tar.gz"

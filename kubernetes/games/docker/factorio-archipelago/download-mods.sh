#!/bin/bash
# Init container: populate the Factorio mods PVC.
#
# Downloads every URL in FACTORIO_MOD_URLS into FACTORIO_MODS_DIR, skipping any
# that is already on the volume, so a pod restart doesn't re-fetch a seed that is
# already there. What counts as "already there" is tracked in a manifest keyed by
# a hash of the URL, because curl -OJ only reveals the mod's real filename
# (AP-<seed>-P<n>-<slot>_<ver>.zip, which Factorio requires to match the mod's internal
# info.json) once the download is under way.
#
# To roll a new seed, change the URL: its hash won't be in the manifest, so the
# new mod is fetched. Stale AP[-_]*.zip files are pruned below so Factorio doesn't
# try to load two seeds at once.
set -euo pipefail

MODS_DIR="${FACTORIO_MODS_DIR:-/opt/factorio/mods}"
MANIFEST="${MODS_DIR}/.downloaded"

mkdir -p "$MODS_DIR"
touch "$MANIFEST"

tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT

downloaded=0
skipped=0
keep=()

if [[ -z "${FACTORIO_MOD_URLS:-}" || -z "${FACTORIO_MOD_URLS// /}" ]]; then
    echo "FACTORIO_MOD_URLS is empty — nothing to download."
fi

# Unquoted on purpose: FACTORIO_MOD_URLS is a whitespace/newline separated list.
# An empty list simply runs zero iterations and leaves the volume as it is; the
# mod-list.json below is still refreshed from whatever is already on it.
# shellcheck disable=SC2086
for url in ${FACTORIO_MOD_URLS:-}; do
    key="$(printf '%s' "$url" | sha1sum | cut -d' ' -f1)"
    recorded="$(awk -v k="$key" '$1 == k { sub(/^[^ ]+ /, ""); print; exit }' "$MANIFEST")"

    if [[ -n "$recorded" && -f "${MODS_DIR}/${recorded}" ]]; then
        echo "✅ already present: ${recorded}"
        keep+=("$recorded")
        skipped=$((skipped + 1))
        continue
    fi

    echo "📦 downloading ${url}"
    find "$tmp" -mindepth 1 -delete
    if ! ( cd "$tmp" && curl -fsSL -OJ "$url" ); then
        echo "❌ failed to download ${url}" >&2
        exit 1
    fi

    file="$(find "$tmp" -maxdepth 1 -type f -printf '%f\n' | head -n1)"
    if [[ -z "$file" ]]; then
        echo "❌ ${url} produced no file" >&2
        exit 1
    fi

    mv -f "${tmp}/${file}" "${MODS_DIR}/${file}"
    keep+=("$file")
    downloaded=$((downloaded + 1))
    echo "   -> ${file}"

    # Rewrite this URL's manifest entry.
    grep -v "^${key} " "$MANIFEST" > "${MANIFEST}.new" || true
    printf '%s %s\n' "$key" "$file" >> "${MANIFEST}.new"
    mv "${MANIFEST}.new" "$MANIFEST"
done

# Drop AP seed mods that are no longer referenced by FACTORIO_MOD_URLS, so that
# switching to a new seed doesn't leave Factorio trying to load two at once.
# Skipped when no URLs were given, otherwise an unset variable would be read as
# "nothing is referenced" and wipe a volume that was populated by hand.
shopt -s nullglob
if [[ ${#keep[@]} -gt 0 ]]; then
    for existing in "${MODS_DIR}"/AP[-_]*.zip; do
        name="$(basename "$existing")"
        for k in "${keep[@]}"; do
            [[ "$k" == "$name" ]] && continue 2
        done
        echo "🧹 removing stale seed mod: ${name}"
        rm -f "$existing"
    done
fi

# Factorio 2.x headless bundles the Space Age DLC mods and enables them by
# default, but the AP seed mod is built against the base game and Factorio then
# refuses it with `Failed to load mod ...: Incompatible with space-age`. Nothing
# in the mods directory can override that, so pin the whole load order here:
# base on, DLC off, every mod we placed on the volume on.
#
# Mod names follow Factorio's `<name>_<version>.zip` convention, so the name is
# the filename with the trailing _<version> and .zip stripped.
MOD_LIST="${MODS_DIR}/mod-list.json"
entries=('    { "name": "base", "enabled": true }')
for dlc in elevated-rails quality space-age; do
    entries+=("    { \"name\": \"${dlc}\", \"enabled\": false }")
done
for mod in "${MODS_DIR}"/*.zip; do
    base="$(basename "$mod" .zip)"
    entries+=("    { \"name\": \"${base%_*}\", \"enabled\": true }")
done

{
    printf '{\n  "mods": [\n'
    printf '%s,\n' "${entries[@]:0:${#entries[@]}-1}"
    printf '%s\n' "${entries[-1]}"
    printf '  ]\n}\n'
} > "$MOD_LIST"

echo "📝 wrote $(basename "$MOD_LIST") (Space Age DLC disabled)"
echo "done: ${downloaded} downloaded, ${skipped} already present"
echo "mods now: $(ls -1 "$MODS_DIR" | tr '\n' ' ')"

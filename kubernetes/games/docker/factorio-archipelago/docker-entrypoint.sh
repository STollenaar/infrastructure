#!/bin/bash
# Starts the Archipelago "Factorio Client", which spawns the Factorio headless
# server as a subprocess, drives it over local RCON and relays items to/from the
# multiworld.
#
# Joining the multiworld has to happen *after* the Factorio bridge is up. The
# client learns its own slot name by asking the AP mod over RCON, and until it
# has that, server_auth() throws "Cannot connect to a server with unknown own
# identity, bridge to Factorio first" and drops the connection — so passing
# --connect at startup reliably loses the race. Instead the client is left to
# spin Factorio up, and `/connect` is fed to its stdin once it reports readiness.
#
# Mods are NOT fetched here — the init container (download-mods.sh) puts them on
# the mods volume before this runs.
set -euo pipefail

: "${ARCHIPELAGO_SERVER:?must be set to the Archipelago server host}"
: "${ARCHIPELAGO_PORT:?must be set to the Archipelago server port}"

MODS_DIR="${FACTORIO_MODS_DIR:-/opt/factorio/mods}"

# Without a seed mod the client spins up its info-exchange server and then aborts
# with "No Archipelago mod was loaded", which is a confusing way to learn the
# volume is empty.
shopt -s nullglob
ap_mods=("${MODS_DIR}"/AP[-_]*.zip)
if [[ ${#ap_mods[@]} -eq 0 ]]; then
    echo "❌ no AP[-_]*.zip found in ${MODS_DIR}." >&2
    echo "   The init container should have downloaded one from FACTORIO_MOD_URLS." >&2
    exit 1
fi
echo "🧩 seed mod: $(basename "${ap_mods[0]}")"

# The client writes the world to <write-data>/saves/Archipelago/; Factorio's
# --create does not build the intermediate directories itself.
mkdir -p "${FACTORIO_DIR}/saves/Archipelago"

# Flags the client's own parser understands. Note the absence of --connect; see
# the header comment.
args=(--nogui --rcon-port "${RCON_PORT}")
if [[ -n "${ARCHIPELAGO_PASSWORD:-}" ]]; then
    args+=(--password "${ARCHIPELAGO_PASSWORD}")
fi

# Anything it doesn't recognise is forwarded verbatim to the Factorio headless
# process it spawns (see worlds/factorio/Client.py: `rest` -> ctx.server_args).
#
# Deliberately NOT --mod-directory: the client creates the savegame with a bare
# `factorio --create <save> --preset archipelago` that inherits none of these
# args, so with a custom mod directory it cannot see the AP mod, the preset is
# unknown, creation fails and the server then dies on "does not exist". The mods
# volume therefore has to be mounted at Factorio's default location instead.
args+=(--port "${FACTORIO_PORT}")

# The client reads console commands from stdin, so give it a FIFO we can write
# to. Opened read-write (<>) so this doesn't block waiting for the client to
# become a reader, and held open for the process lifetime so it never sees EOF.
fifo_dir="$(mktemp -d)"
fifo="${fifo_dir}/client-stdin"
mkfifo "$fifo"
exec 9<> "$fifo"
trap 'rm -rf "$fifo_dir"' EXIT

echo "▶️  starting Factorio Client; will join ${ARCHIPELAGO_SERVER}:${ARCHIPELAGO_PORT} once bridged"

# Watch the client's own output and issue /connect the moment it says the RCON
# bridge is live. Reconnects are handled too: if the multiworld connection drops,
# the client prints the same "type /connect to reconnect" prompt.
set -o pipefail
python Launcher.py "Factorio Client" -- "${args[@]}" <&9 2>&1 |
    while IFS= read -r line; do
        printf '%s\n' "$line"
        case "$line" in
            *"Ready to connect to Archipelago"*|*"type /connect to reconnect"*)
                printf '/connect %s:%s\n' "${ARCHIPELAGO_SERVER}" "${ARCHIPELAGO_PORT}" >&9
                ;;
        esac
    done

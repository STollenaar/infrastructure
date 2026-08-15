# Factorio Archipelago

A Factorio world bridged into an Archipelago multiworld. This directory holds the
bridge image; the Kubernetes wiring is in
[`../factorio-archipelago.tf`](../factorio-archipelago.tf).

## Architecture

The multiworld itself is hosted on **archipelago.gg**; this cluster runs only the
Factorio slot that joins it.

```
                              archipelago.gg:<port>
                                       ▲
                                       │ websocket
                    ┌──────────────────┴────────────────┐
players ─udp/34197──▶ Factorio headless ◀─local RCON──▶ AP Factorio Client
(NodePort 31498)    │  (spawned and owned by the client, one pod)
                    └───────────────────────────────────┘
```

The Archipelago **Factorio client owns the Factorio process**: it spawns the
headless server, loads the generated AP mod, drives it over local RCON, and
relays items to and from the multiworld. That's why the AP world can't be the
existing sqljames helm server — it has to be its own deployment. The vanilla
helm server ([`../factorio.tf`](../factorio.tf)) is untouched and runs alongside.

## The image

Built from `ghcr.io/archipelagomw/archipelago` — the image produced by the
`Dockerfile` at the root of
[`ArchipelagoMW/Archipelago`](https://github.com/ArchipelagoMW/Archipelago),
published by their CI (multi-arch, tagged per release from `0.6.3` onward; older
tags predate the Dockerfile). It already carries the whole AP source tree,
including the Factorio apworld and `factorio-rcon-py`.

Two things about that image matter here:

- **It is deliberately server-only.** Its `.dockerignore` lists `*Client.py`,
  which strips `CommonClient.py` out of the image. Every AP client imports it, so
  this Dockerfile restores that one file from the source tree at the same pinned
  version.
- **Its entrypoint is `WebHost.py`**, the Archipelago website, which is not what
  we run — the entrypoint is replaced with the Factorio client bridge. (Should
  self-hosting ever be wanted, the same image runs `MultiServer.py --port <n>` as
  a fixed-port multiworld host; the WebHost's own rooms take a port out of the
  `GAME_PORTS` range, default `49152-65535`, which doesn't map onto a NodePort.)

On top of that this adds the Factorio headless binary (baked in at build time,
not downloaded on boot) and a `host.yaml` pointing `factorio_options.executable`
at it, which `worlds/factorio/Client.py` reads at import time.

The bridge image adds the Factorio headless binary (baked in at build time, not
downloaded on boot) and a `host.yaml` pointing `factorio_options.executable` at
it, which `worlds/factorio/Client.py` reads at import time.

## Files here

| File | Purpose |
|---|---|
| `Dockerfile` | Upstream AP image + Factorio headless + `CommonClient.py`. |
| `host.yaml` | Points the AP Factorio client at the Factorio binary. |
| `docker-entrypoint.sh` | Runs the client, then issues `/connect` once bridged. |
| `download-mods.sh` | Init container: populates the mods volume, writes `mod-list.json`. |

### Image env vars

| Var | Meaning |
|---|---|
| `ARCHIPELAGO_SERVER` / `ARCHIPELAGO_PORT` | Multiworld room to join, e.g. `archipelago.gg` / `56785`. |
| `ARCHIPELAGO_PASSWORD` | Optional multiworld password. |
| `FACTORIO_MOD_URLS` | Whitespace-separated mod URLs for the init container. |
| `FACTORIO_PORT` | Factorio game port (default `34197`). |
| `RCON_PORT` | Client↔Factorio RCON, pod-local only (default `24242`). |
| `FACTORIO_VERSION` | Baked in at build time. **Must match the version the seed was generated against.** |

## Three things that are not obvious

All three were found by running it, and each one silently breaks the world:

1. **`--connect` loses a race.** The client only learns its own slot name by
   asking the AP mod over RCON, which can't happen until Factorio is up. Connect
   any earlier and `server_auth()` throws *"Cannot connect to a server with
   unknown own identity, bridge to Factorio first"* and drops the connection,
   leaving the pod up but not in the multiworld. The entrypoint therefore starts
   the client with no `--connect` and writes `/connect <host>:<port>` to its
   stdin when it logs *"Ready to connect to Archipelago"*. The same watcher
   re-issues it on *"type /connect to reconnect"*.

2. **The mods volume must be at Factorio's default path.** The client creates the
   world with a bare `factorio --create <save> --preset archipelago` that
   inherits none of the client's passthrough args — so with `--mod-directory`
   pointing elsewhere it can't see the AP mod, the `archipelago` preset is
   unknown, creation fails, and the server dies on *"...Save.zip does not
   exist"*. The PVC is mounted at `/opt/factorio/mods` and `--mod-directory` is
   deliberately not passed.

3. **Space Age has to be switched off.** Factorio 2.x headless bundles the DLC
   mods and enables them by default; the AP mod is built against the base game
   and Factorio rejects it with *"Incompatible with space-age"*. `download-mods.sh`
   writes a `mod-list.json` pinning `base` + the AP mod on and
   `space-age`/`quality`/`elevated-rails` off.

Mod filenames are `AP-<seed>-P<n>-<slot>_<apversion>.zip` (hyphens). Older
Archipelago used `AP_<seed>_P<n>_<name>.zip`; the scripts glob `AP[-_]*` to cover
both.

## Getting the mod URL

`mod_urls` needs the generated Factorio mod for **our slot** as its own file —
Factorio requires the filename to match the mod's internal `info.json`.
archipelago.gg's `slot_file/<room>/<n>` endpoint serves exactly that for slot
`<n>`. Sanity-check a URL before putting it in Terraform:

```bash
curl -sI "<url>" | grep -i content-disposition
# content-disposition: attachment; filename=AP-<seed>-P1-<slot>_<ver>.zip
```

A 404 there is usually a typo in the slot number. The mod's `info.json` records
what it needs, and is the authority on the pins here:

```bash
unzip -p <mod>.zip '*/info.json'
# "dependencies": ["base >= 2.0.28", ..., "! space-age"]
```

`base >= 2.0.28` is what `FACTORIO_VERSION` has to satisfy, and `! space-age` is
why the DLC has to be disabled.

Mods are fetched only when the volume doesn't already have them, so restarts keep
the existing world. Changing a mod URL pulls the new mod and prunes the old `AP*`
one.

## Terraform

Settings live in `local.archipelago` at the top of
[`../factorio-archipelago.tf`](../factorio-archipelago.tf):

```hcl
archipelago = {
  server   = "archipelago.gg"
  port     = 56785
  mod_urls = ["https://archipelago.gg/slot_file/<room>/1"]

  factorio_port      = 34197
  factorio_node_port = 31498
}
```

**Node ports must be within 30000-32767** — Kubernetes rejects anything else with
`provided port is not in the valid range`. A game's own port (34197, 56785) is
not a valid node port. 31497 is already taken by the vanilla helm server, so
Factorio uses **31498/udp**. RCON is never exposed — the client talks to its own
subprocess over localhost.

ECR wiring for the bridge image touches the separate `aws/ecr` state:
[`aws/ecr/ecr.tf`](../../../../aws/ecr/ecr.tf),
[`aws/ecr/outputs.tf`](../../../../aws/ecr/outputs.tf),
[`kubernetes/main.tf`](../../../main.tf), and the `ecr_repositories` object in
[`../variables.tf`](../variables.tf).

## Deploy order

```bash
# 1. Create the ECR repo
cd aws/ecr && tofu apply

# 2. Build + push the bridge image
REPO=$(aws ecr describe-repositories --repository-names factorio-archipelago \
  --query 'repositories[0].repositoryUri' --output text)
aws ecr get-login-password | docker login --username AWS --password-stdin "${REPO%/*}"
docker build -t "$REPO:0.6.7-2.0.28" kubernetes/games/docker/factorio-archipelago
docker push "$REPO:0.6.7-2.0.28"

# 3. Set local.archipelago (server, port, mod_urls), then apply
cd kubernetes && tofu apply
```

Check it joined:

```bash
kubectl -n factorio logs deploy/factorio-archipelago -c fetch-mods
kubectl -n factorio logs deploy/factorio-archipelago | grep -iE "seed mod|connect|Established"
```

## Status

- **Verified locally, not yet deployed.** The image builds, and a full run
  against a generated seed — bridge plus a throwaway `MultiServer.py` standing in
  for the room — reaches `Player1 (Team #1) playing Factorio has joined` on the
  server. `tofu validate` passes; the ECR apply, image push, and cluster apply
  have not been run.
- **The live archipelago.gg room has not been joined from here.** The real slot
  mod downloads and its `mod-list.json` is written correctly, but connecting the
  bridge to the actual room would announce the slot as joined, so that was left
  for a deliberate deploy.
- **Version match** — pinned to Archipelago `0.6.7` / Factorio `2.0.28`, which
  satisfies the current seed's `base >= 2.0.28`. A new seed can need a different
  Factorio; move `FACTORIO_VERSION` and `local.archipelago.image_tag` together.
- **Runs as root.** The upstream base image does, and nothing here drops
  privileges. Fine for a homelab, worth revisiting if the game port is ever
  exposed beyond the LAN.
- **Old vanilla server** — the sqljames helm Factorio server still runs next to
  this. Decide whether to scale it down.

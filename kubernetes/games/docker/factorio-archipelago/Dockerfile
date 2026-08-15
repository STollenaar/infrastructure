# Factorio headless server bridged into an Archipelago multiworld.
#
# This is built directly on top of upstream's own image — the one produced by
# https://github.com/ArchipelagoMW/Archipelago/blob/main/Dockerfile and published
# as ghcr.io/archipelagomw/archipelago. That image already contains the whole
# Archipelago source tree (including the Factorio apworld and its Client) and
# factorio-rcon-py, so all we add here is the Factorio headless binary and a
# host.yaml telling the client where to find it.
#
# The Archipelago *server* needs no custom image at all: it runs this same
# upstream image with the command overridden to MultiServer.py. See README.md.
ARG ARCHIPELAGO_VERSION=0.6.7
FROM ghcr.io/archipelagomw/archipelago:${ARCHIPELAGO_VERSION}

# Re-declared so it is usable in the build stage below.
ARG ARCHIPELAGO_VERSION
# Must match the Factorio version the seed was generated against, or the
# generated AP mod will refuse to load.
ARG FACTORIO_VERSION=2.0.28

ENV FACTORIO_VERSION="${FACTORIO_VERSION}" \
    FACTORIO_DIR="/opt/factorio" \
    FACTORIO_MODS_DIR="/opt/factorio/mods" \
    FACTORIO_PORT="34197" \
    RCON_PORT="24242" \
    ARCHIPELAGO_SERVER="" \
    ARCHIPELAGO_PORT="" \
    FACTORIO_MOD_URLS=""

# xz-utils for the Factorio tarball; curl is already present (upstream keeps it
# for its HEALTHCHECK) but is pinned here so a base-image change can't drop it.
RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        xz-utils curl ca-certificates \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Baked in rather than downloaded at runtime: the version is fixed per image tag,
# so this keeps pod startup fast and the image reproducible.
RUN curl -fsSL "https://www.factorio.com/get-download/${FACTORIO_VERSION}/headless/linux64" \
        -o /tmp/factorio.tar.xz \
    && tar -xJf /tmp/factorio.tar.xz -C /opt \
    && rm /tmp/factorio.tar.xz \
    && test -x "${FACTORIO_DIR}/bin/x64/factorio"

# Upstream's .dockerignore lists `*Client.py`, which strips CommonClient.py (and
# every other root-level client) out of the published image — it is deliberately
# a server-only image. worlds/factorio/Client.py imports CommonClient, so restore
# just that one file, pinned to the same version as the base image.
ADD --chmod=644 \
    "https://raw.githubusercontent.com/ArchipelagoMW/Archipelago/${ARCHIPELAGO_VERSION}/CommonClient.py" \
    /app/CommonClient.py

COPY host.yaml /app/host.yaml
COPY docker-entrypoint.sh download-mods.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh /usr/local/bin/download-mods.sh

# Upstream sets a HEALTHCHECK that curls the WebHost port; meaningless here.
HEALTHCHECK NONE

EXPOSE 34197/udp
ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]

#!/bin/sh
# Raw podman-run(1) command for testing
# --restart on-failure replaced with --rm
# add -d to run in background

mkdir -p "${XDG_CONFIG_HOME:-${HOME}/.config}/syncthing" && \
podman run --rm \
    --name syncthing \
    --label "io.containers.autoupdate=registry" \
    --userns=keep-id \
    --security-opt label=disable \
    -v /etc/hosts:/etc/hosts:ro \
    -v /etc/resolv.conf:/etc/resolv.conf:ro \
    -v "${HOME}:${HOME}" \
    -v "${XDG_CONFIG_HOME:-${HOME}/.config}/syncthing:/var/syncthing/config:rslave" \
    --network host \
    -e "STGUIADDRESS=127.0.0.1:8384" \
    -e "Environment=PUID=$(id -u)" \
    -e "Environment=PGID=$(id -g)" \
    -e HOME="${HOME}" \
    --health-cmd="curl -fkLsS -m 2 127.0.0.1:8384/rest/noauth/health | grep -o --color=never OK || exit 1" \
    --health-interval=5m \
    --health-retries=3 \
    --health-timeout=10s \
        docker.io/syncthing/syncthing:latest
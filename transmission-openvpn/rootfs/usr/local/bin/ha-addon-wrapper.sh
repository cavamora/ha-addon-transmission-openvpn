#!/usr/bin/env bash
set -euo pipefail

OPTIONS=/data/options.json

read_option() {
  local key="$1"
  local default="${2:-}"
  if [[ -f "$OPTIONS" ]]; then
    jq -r --arg key "$key" --arg default "$default" 'if has($key) and .[$key] != null then .[$key] else $default end' "$OPTIONS"
  else
    printf '%s\n' "$default"
  fi
}

trim() {
  sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//'
}

read_option_trimmed() {
  read_option "$@" | trim
}

OPENVPN_PROVIDER_RAW="$(read_option_trimmed OPENVPN_PROVIDER NORDVPN)"
export OPENVPN_PROVIDER="${OPENVPN_PROVIDER_RAW^^}"
export OPENVPN_CONFIG="$(read_option_trimmed OPENVPN_CONFIG '')"
export NORDVPN_SERVER="$(read_option_trimmed NORDVPN_SERVER '')"

# Haugene's NORDVPN provider setup script ignores OPENVPN_CONFIG and instead
# selects a recommended server from the NordVPN API unless NORDVPN_SERVER is set.
# Keep the HA add-on UI backwards-compatible: if the user put a NordVPN hostname
# in OPENVPN_CONFIG, pin that hostname for the NORDVPN setup script too.
if [[ "$OPENVPN_PROVIDER" == "NORDVPN" && -z "$NORDVPN_SERVER" && "$OPENVPN_CONFIG" == *.nordvpn.com ]]; then
  export NORDVPN_SERVER="$OPENVPN_CONFIG"
fi

export OPENVPN_USERNAME="$(read_option_trimmed OPENVPN_USERNAME '')"
export OPENVPN_PASSWORD="$(read_option OPENVPN_PASSWORD '')"
export LOCAL_NETWORK="$(read_option_trimmed LOCAL_NETWORK '192.168.0.0/16')"

export TRANSMISSION_HOME="/config/transmission-home"
export TRANSMISSION_DOWNLOAD_DIR="$(read_option_trimmed TRANSMISSION_DOWNLOAD_DIR /downloads/completed)"
export TRANSMISSION_INCOMPLETE_DIR="$(read_option_trimmed TRANSMISSION_INCOMPLETE_DIR /downloads/incomplete)"
export TRANSMISSION_WATCH_DIR="$(read_option_trimmed TRANSMISSION_WATCH_DIR /downloads/watch)"
export TRANSMISSION_RPC_USERNAME="$(read_option_trimmed TRANSMISSION_RPC_USERNAME '')"
export TRANSMISSION_RPC_PASSWORD="$(read_option TRANSMISSION_RPC_PASSWORD '')"
export TRANSMISSION_RPC_PORT=9091
export TRANSMISSION_WEB_UI="$(read_option_trimmed TRANSMISSION_WEB_UI transmission-web-control)"

export WEBPROXY_ENABLED="$(read_option_trimmed WEBPROXY_ENABLED false)"
export WEBPROXY_PORT="$(read_option_trimmed WEBPROXY_PORT 8118)"
export TZ="$(read_option_trimmed TZ America/Sao_Paulo)"

# The HA add-on maps /dev/net/tun from the host. If Haugene tries to recreate it
# inside HAOS the mknod/rm path can fail with "Read-only file system".
export CREATE_TUN_DEVICE=false

# Haugene treats /data/transmission-home as a deprecated legacy location and
# forcibly falls back to it if the directory exists. Earlier wrapper versions
# created it, so migrate/rename it before starting to keep TRANSMISSION_HOME at
# the upstream-recommended /config/transmission-home.
mkdir -p /config
if [[ -L /config/transmission-home ]]; then
  legacy_target="$(readlink /config/transmission-home)"
  rm -f /config/transmission-home
  if [[ -d "$legacy_target" && ! -e /config/transmission-home ]]; then
    mv "$legacy_target" /config/transmission-home
  fi
fi
if [[ -d /data/transmission-home && ! -e /config/transmission-home ]]; then
  mv /data/transmission-home /config/transmission-home
fi
if [[ -d /data/transmission-home ]]; then
  backup="/data/transmission-home.legacy.$(date +%Y%m%d%H%M%S)"
  echo "Moving deprecated /data/transmission-home out of the way to ${backup} so Haugene keeps TRANSMISSION_HOME=${TRANSMISSION_HOME}"
  mv /data/transmission-home "$backup"
fi

mkdir -p "$TRANSMISSION_HOME" "$TRANSMISSION_DOWNLOAD_DIR" "$TRANSMISSION_INCOMPLETE_DIR" "$TRANSMISSION_WATCH_DIR"

echo "Starting haugene/transmission-openvpn for provider=${OPENVPN_PROVIDER}, config=${OPENVPN_CONFIG:-default}, nordvpn_server=${NORDVPN_SERVER:-auto}, local_network=${LOCAL_NETWORK}"
exec dumb-init /etc/openvpn/start.sh

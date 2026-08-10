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

export OPENVPN_PROVIDER="$(read_option OPENVPN_PROVIDER NORDVPN)"
export OPENVPN_CONFIG="$(read_option OPENVPN_CONFIG '')"
export OPENVPN_USERNAME="$(read_option OPENVPN_USERNAME '')"
export OPENVPN_PASSWORD="$(read_option OPENVPN_PASSWORD '')"
export LOCAL_NETWORK="$(read_option LOCAL_NETWORK '192.168.0.0/16')"

export TRANSMISSION_HOME="/config/transmission-home"
export TRANSMISSION_DOWNLOAD_DIR="$(read_option TRANSMISSION_DOWNLOAD_DIR /downloads/completed)"
export TRANSMISSION_INCOMPLETE_DIR="$(read_option TRANSMISSION_INCOMPLETE_DIR /downloads/incomplete)"
export TRANSMISSION_WATCH_DIR="$(read_option TRANSMISSION_WATCH_DIR /downloads/watch)"
export TRANSMISSION_RPC_USERNAME="$(read_option TRANSMISSION_RPC_USERNAME '')"
export TRANSMISSION_RPC_PASSWORD="$(read_option TRANSMISSION_RPC_PASSWORD '')"
export TRANSMISSION_RPC_PORT=9091
export TRANSMISSION_WEB_UI="$(read_option TRANSMISSION_WEB_UI transmission-web-control)"

export WEBPROXY_ENABLED="$(read_option WEBPROXY_ENABLED false)"
export WEBPROXY_PORT="$(read_option WEBPROXY_PORT 8118)"
export TZ="$(read_option TZ America/Sao_Paulo)"

# The HA add-on maps /dev/net/tun from the host. If Haugene tries to recreate it
# inside HAOS the mknod/rm path can fail with "Read-only file system".
export CREATE_TUN_DEVICE=false

mkdir -p /data/transmission-home /config
if [[ ! -e /config/transmission-home ]]; then
  ln -s /data/transmission-home /config/transmission-home
fi

mkdir -p "$TRANSMISSION_HOME" "$TRANSMISSION_DOWNLOAD_DIR" "$TRANSMISSION_INCOMPLETE_DIR" "$TRANSMISSION_WATCH_DIR"

echo "Starting haugene/transmission-openvpn for provider=${OPENVPN_PROVIDER}, config=${OPENVPN_CONFIG:-default}, local_network=${LOCAL_NETWORK}"
exec dumb-init /etc/openvpn/start.sh

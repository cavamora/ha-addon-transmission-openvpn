# Home Assistant Add-on: Transmission OpenVPN

## About this fork

This Home Assistant add-on repository is a small fork/wrapper created to make it easier to use the current upstream `master` version of [`haugene/transmission-openvpn`](https://github.com/haugene/docker-transmission-openvpn), including the login-related fix that is already available there while the corresponding PR/release is being accepted upstream.

The intention is not to replace Haugene's project. This repository only packages the upstream image as a Home Assistant add-on and carries minimal wrapper/configuration changes needed for HAOS usage until the upstream fix is fully released/available through the normal channel.

---

Public Home Assistant add-on repository that wraps the upstream [`haugene/transmission-openvpn`](https://github.com/haugene/docker-transmission-openvpn) Docker image.

The goal is to reuse Haugene's maintained OpenVPN, Transmission, routing and kill-switch scripts while exposing the most common environment variables through the Home Assistant add-on UI.

## Install

1. In Home Assistant, open **Settings → Add-ons → Add-on Store**.
2. Open the menu **⋮ → Repositories**.
3. Add this repository URL:

   ```text
   https://github.com/cavamora/ha-addon-transmission-openvpn
   ```

4. Install **Transmission OpenVPN**.
5. Configure your VPN provider, username, password and `LOCAL_NETWORK`.
6. Start the add-on and open Transmission at `http://HOME_ASSISTANT_HOST:9091`.

## Important security/network notes

- The add-on needs `NET_ADMIN` and `/dev/net/tun` so OpenVPN can create/manage the tunnel interface.
- This wrapper intentionally avoids `host_network: true`; Transmission is exposed through normal port mapping on `9091/tcp`. This reduces the chance that VPN/iptables rules alter the HA host network.
- Downloads are stored under the Home Assistant `/downloads` mount by default:
  - `/downloads/completed`
  - `/downloads/incomplete`
  - `/downloads/watch`
- Add-on options are copied to environment variables by `rootfs/usr/local/bin/ha-addon-wrapper.sh` before starting Haugene's original `/etc/openvpn/start.sh`.

## Options

| Option | Description |
|---|---|
| `OPENVPN_PROVIDER` | Haugene provider name, e.g. `PIA`, `NORDVPN`, `CUSTOM` |
| `OPENVPN_CONFIG` | Provider config/region, e.g. `france` |
| `OPENVPN_USERNAME` / `OPENVPN_PASSWORD` | VPN credentials |
| `LOCAL_NETWORK` | LAN CIDR allowed to reach Transmission, e.g. `192.168.0.0/16` |
| `TRANSMISSION_RPC_USERNAME` / `TRANSMISSION_RPC_PASSWORD` | Optional Transmission Web UI credentials |
| `TRANSMISSION_WEB_UI` | One of Haugene's bundled web UIs |
| `WEBPROXY_ENABLED` / `WEBPROXY_PORT` | Optional Privoxy proxy from Haugene image |
| `TZ` | Container timezone |

For the complete provider/config matrix, use the upstream docs:

https://haugene.github.io/docker-transmission-openvpn/

## License / attribution

This repository is a small Home Assistant wrapper around `haugene/transmission-openvpn`, which is licensed GPL-3.0. This wrapper is also GPL-3.0.

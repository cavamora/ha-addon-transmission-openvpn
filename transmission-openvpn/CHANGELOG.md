# Changelog

## 1.0.5

- Add a custom Transmission + VPN icon/logo for Home Assistant add-on listings.
- Add this changelog so Home Assistant can show update release notes.

## 1.0.4

- Mount Home Assistant `/media` into the add-on with read/write access.
- This allows Transmission paths such as `/media/MEDIA/Download` to use the real Home Assistant media share instead of an internal container directory.

## 1.0.3

- Pin NordVPN servers correctly by mapping a NordVPN hostname from `OPENVPN_CONFIG` to `NORDVPN_SERVER`.
- Keeps existing add-on UI configuration compatible while preventing Haugene's NordVPN setup from choosing a different recommended server automatically.

## 1.0.2

- Trim add-on option values before exporting them to Haugene environment variables.
- Migrate/fix Transmission home handling so Haugene keeps using `/config/transmission-home` instead of falling back to deprecated `/data/transmission-home`.

## 1.0.1

- Fix HAOS TUN handling by using the host-provided `/dev/net/tun` and disabling TUN recreation inside the container.

## 1.0.0

- Initial Home Assistant add-on wrapper around `haugene/transmission-openvpn`.

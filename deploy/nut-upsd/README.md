# NUT UPS Server (Master) with `instantlinux/nut-upsd`

This README explains every environment variable exposed by the `instantlinux/nut-upsd` image, then provides a complete, working example of running the container as a **NUT master** that serves a UPS named `usbhid` and accepts a client logging in as `[client]` with password `123` and `monuser secondary` permissions.

---

## 1. Variable Reference

The table below reproduces the official variable list and explains the purpose of each one.

| Variable                   | Default                       | Purpose                                                                                                                                                                                                                       |
| -------------------------- | ----------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `ACTIONS`                  | *(unset)*                     | Comma/space-separated list of user actions that the API user is allowed to perform. Valid values are `set` (write variables) and `fsd` (force shutdown). If unset, no user actions are permitted — the API user is read-only. |
| `API_USER`                 | `upsmon`                      | Username created in `upsd.users` for the API/remote client. This is the account external tools (Nagios, `upsc`, `upsmon`, your WD NAS) authenticate as.                                                                       |
| `API_PASSWORD`             | *(unset)*                     | Password for `API_USER`. Used only if you are **not** using a Docker secret. Convenient but visible in `docker inspect` / process listings.                                                                                   |
| `DESCRIPTION`              | `UPS`                         | Free-text description written into `ups.conf` (`desc = …`). Purely informational; shows up in `upsc` output as a comment/metadata.                                                                                            |
| `DRIVER`                   | `usbhid-ups`                  | NUT driver binary used to talk to the UPS. Must match your hardware. `usbhid-ups` covers most USB HID UPSes; serial devices use `nutdrv_qx`, `apcsmart`, etc.                                                                 |
| `GROUP`                    | `nut`                         | Local Unix group the driver/daemon runs as inside the container. Must have read/write access to the USB device node on the host (via udev rule).                                                                              |
| `INSTCMDS`                 | *(unset)*                     | Instant commands the API user may execute via `upscmd` (e.g. `test.battery.start.quick`, `load.off`). Accepts `all` or a comma-separated list of CMDDESC names from `cmdvartab`. Unset = no instant commands.                 |
| `MAXAGE`                   | `15`                          | Seconds `upsd` waits for a driver update before declaring the driver "stale" (`Data stale`). CyberPower units commonly need a larger value (e.g. `25`).                                                                       |
| `NAME`                     | `ups`                         | The UPS **section name** in `ups.conf` and the identifier clients use in `upsc <NAME>@host`. This is what WD devices hardcode-match against (`usbhid`, `bcmxcp`, `megatec`, `tripplite`).                                     |
| `NOTIFYCMD`                | *(unset)*                     | Full path to a script executed by `upsmon` on notify events (ONBATT, LOWBATT, ONLINE, etc.). The script must be mounted under `/usr/local/bin` — **not** under `/etc/nut`.                                                    |
| `NUT_DEBUG_LEVEL`          | `0`                           | Verbosity of NUT debug output (`-D` level). `0` = quiet, `5` = maximum. Useful when troubleshooting driver claim failures.                                                                                                    |
| `NUT_QUIET_INIT_SSL`       | `true`                        | Suppresses the "Init SSL without certificate database" warning printed at startup. Set `false` to see it (useful for confirming whether TLS is involved in a client failure).                                                 |
| `NUT_QUIET_INIT_UPSNOTIFY` | `true`                        | Suppresses the "no notification tech defined" warning from `upsnotify`. Cosmetic only.                                                                                                                                        |
| `POLLINTERVAL`             | *(driver default, usually 2)* | Seconds between driver polls of the UPS. Written to `ups.conf` as `pollinterval`. Lower = more responsive, higher = less USB traffic.                                                                                         |
| `POLLONLY`                 | *(unset)*                     | If set (e.g. `true`), disables USB interrupt reads and forces polling-only mode. Needed for some buggy HID devices that hang on interrupt endpoints.                                                                          |
| `PORT`                     | `auto`                        | Device port the driver opens. `auto` lets the driver scan USB; for serial UPSes use e.g. `/dev/ttyUSB0`. Written to `ups.conf` as `port`.                                                                                     |
| `SDORDER`                  | *(unset)*                     | Shutdown ordering for multi-UPS setups. `-1` disables shutdown entirely for this UPS. Used in `upsmon.conf`/`ups.conf` to sequence power-off across multiple units.                                                           |
| `SECRETNAME`               | `nut-upsd-password`           | Name of the Docker secret containing the API password. Only relevant with Swarm/Kubernetes secrets; ignored if `API_PASSWORD` is set.                                                                                         |
| `SERIAL`                   | *(unset)*                     | 12-digit hardware serial number of the UPS. **Required for APC `usbhid-ups`** — the driver refuses to bind without it. Find it with `lsusb -D /dev/bus/usb/BBB/DDD`.                                                          |
| `SERVER`                   | `primary`                     | Role in a multi-instance setup. `primary` shuts down after all `secondary` instances have shut down. Matches `upsmon` PRIMARY/SECONDARY semantics.                                                                            |
| `ULIMIT`                   | `2048`                        | `nofile` ulimit set before exec. Lowering this avoids OOM on Debian trixie; raise it only if you hit "too many open files".                                                                                                   |
| `USER`                     | `nut`                         | Local Unix user the driver/daemon runs as inside the container. Together with `GROUP` this determines the UID/GID that must be able to open `/dev/bus/usb/...`.                                                               |
| `VENDORID`                 | *(unset)*                     | USB vendor ID (`idVendor`) written to `ups.conf`. Narrows device matching when multiple USB devices are present. For your device: `075d`.                                                                                     |

### Notes that affect the example below

- The image's entrypoint generates `ups.conf`, `upsd.conf`, `upsmon.conf`, and `upsd.users` from these variables. **If you mount your own files into `/etc/nut/local`, they override the generated ones.**
- `API_USER`/`API_PASSWORD` create exactly one user. To add the WD-specific `[client] / 123 / monuser secondary` user, you must either (a) mount a custom `upsd.users`, or (b) post-edit the generated file. Mounting is cleaner and survives restarts.
- `NAME` must be `usbhid` to satisfy WD EX2 Ultra's hardcoded lookup (per the WD community thread).
- `DRIVER=usbhid-ups` plus `VENDORID=075d` matches your `-BMS- Smart-Battery` (`075d:0300`).

---

## 2. Complete Example: NUT Master Serving `usbhid`

### 2.1 Directory layout

```
nut-master/
├── docker-compose.yml
└── nut-config/
    ├── upsd.users
    └── ups.conf
```

### 2.2 `nut-config/upsd.users`

This is the file that makes the WD client work. It defines both the API user (for `upsc`/Nagios) and the WD hardcoded `client` account.

```ini
# API user for monitoring tools (upsc, Nagios check_ups)
[upsmon]
password = ChangeMe_API_Password
upsmon primary

# WD EX2 Ultra hardcoded credentials
[client]
password = 123
upsmon secondary
```

- `upsmon primary` on the API user allows it to issue `FSD` and (with `ACTIONS=fsd`) force shutdowns.
- `upsmon secondary` is the permission level WD expects. In NUT 2.8.x `secondary` is an alias for the older `slave` keyword; use whichever your NUT version accepts.

### 2.3 `nut-config/ups.conf`

Defines the UPS section name that WD will look for.

```ini
[usbhid]
driver = usbhid-ups
port = auto
vendorid = 075d
desc = BMS-Smart-Battery
```

- The section name `usbhid` is what WD hardcodes.
- `vendorid = 075d` narrows matching to your device.
- Do **not** add `productid` here unless you also set `PRODUCTID` via env; the entrypoint merges env vars into this file, and duplicate keys cause the driver to fail.

### 2.4 `docker-compose.yml`

```yaml
version: '3.9'

services:
  nut-master:
    image: instantlinux/nut-upsd
    container_name: nut-master
    privileged: true
    restart: unless-stopped
    environment:
      TZ: ${TZ:-America/New_York}
      # --- identity ---
      NAME: usbhid
      DESCRIPTION: BMS-Smart-Battery
      # --- driver / device ---
      DRIVER: usbhid-ups
      VENDORID: "075d"
      PRODUCTID: "0300"
      PORT: auto
      # --- API user (overridden by upsd.users mount, kept for clarity) ---
      API_USER: upsmon
      API_PASSWORD: ${API_PASSWORD:-ChangeMe_API_Password}
      # --- permissions ---
      ACTIONS: "set fsd"
      INSTCMDS: all
      # --- tuning ---
      MAXAGE: "25"
      POLLINTERVAL: "2"
      NUT_DEBUG_LEVEL: "0"
      NUT_QUIET_INIT_SSL: "true"
      # --- runtime identity (must match udev group on host) ---
      USER: nut
      GROUP: nut
      ULIMIT: "2048"
    volumes:
      # Override generated config with our custom files
      - ./nut-config/upsd.users:/etc/nut/local/upsd.users:ro
      - ./nut-config/ups.conf:/etc/nut/local/ups.conf:ro
      # USB device tree (or use --device equivalent)
      - /dev/bus/usb:/dev/bus/usb
    ports:
      - "3493:3493"
```

### 2.5 Host prerequisites (one-time)

The container's `nut` user must be able to open the UPS device node. On the UGREEN host:

```bash
# Confirm the device and its bus/device path
lsusb | grep 075d
# e.g. Bus 003 Device 003: ID 075d:0300 -BMS- Smart-Battery

# Grant group access (use the GID that matches the container's nut user,
# typically 101 or 118 depending on image build — check with:
#   docker run --rm --entrypoint id instantlinux/nut-upsd nut)
sudo tee /etc/udev/rules.d/62-nut-usbups.rules <<'EOF'
SUBSYSTEM=="usb", ATTR{idVendor}=="075d", ATTR{idProduct}=="0300", GROUP="nut", MODE="0660"
EOF
sudo udevadm control --reload-rules
sudo udevadm trigger
```

If the container's `nut` GID differs from the host `nut` GID, use the numeric GID in the rule (`GROUP="101"`) as discussed earlier.

### 2.6 Start and verify

```bash
docker compose up -d
docker logs -f nut-master
```

Expected log lines (no `Access denied`, no `Resource busy`):

```
Network UPS Tools 2.8.5 release - Generic HID driver ...
Using USB implementation: libusb-1.0.30 ...
Device matches
...
```

Verify from the host (or any machine with `nut-client` installed):

```bash
# List UPSes served
upsc -l

# Should print: usbhid

# Query it
upsc usbhid@<UGREEN-IP>:3493
```

You should get `ups.status: OL`, `battery.charge: 100`, etc.

### 2.7 Verify the WD client credentials work

From a Linux box (or the UGREEN itself), simulate what WD will do:

```bash
upsc usbhid@<UGREEN-IP>:3493 client 123
```

Actually `upsc` does not take credentials on the command line — instead test with `upsmon` or `upscmd` using the WD account:

```bash
upscmd -u client -p 123 -l usbhid@<UGREEN-IP>:3493
```

If the command list returns (or an empty list with `OK`), authentication succeeded. A `ERR ACCESS-DENIED` means the `[client]` user or its `upsmon secondary` line is missing/wrong.

---

## 3. How the WD EX2 Ultra Will Connect

On the WD web UI:

1. **Settings → Network → Network UPS**
2. Enable **Slave Mode**
3. Enter the **UGREEN NAS IP** (not the container IP, not a port — WD always uses 3493)
4. Save

WD will internally send `MONITOR usbhid@<IP> 1 client 123 slave`. Because you have:

- a UPS section named `usbhid` in `ups.conf`,
- a `[client]` user with password `123` and `upsmon secondary` in `upsd.users`,
- `upsd` listening on `0.0.0.0:3493` (default),

…the login and UPS lookup should both succeed.

### If WD still says "could not connect"

The remaining known blocker is **TLS**. WD attempts a TLS handshake that standard NUT rejects. To confirm, set `NUT_QUIET_INIT_SSL=false` and watch the container logs while WD retries — you will see the client connection arrive and then be dropped during/after the SSL negotiation. In that case the credentials are correct but the transport is incompatible, and the only fixes are a TLS-shim proxy in front of `upsd`, or abandoning WD's built-in slave mode in favor of a scripted shutdown triggered from the UGREEN side.

---

## 4. Variable-to-Config Mapping Cheat Sheet

| Variable                         | Lands in                   | Effect                        |
| -------------------------------- | -------------------------- | ----------------------------- |
| `NAME`                           | `ups.conf` section header  | Client-visible UPS name       |
| `DESCRIPTION`                    | `ups.conf` `desc=`         | Informational                 |
| `DRIVER`                         | `ups.conf` `driver=`       | Which driver binary runs      |
| `PORT`                           | `ups.conf` `port=`         | Device path or `auto`         |
| `VENDORID`                       | `ups.conf` `vendorid=`     | USB match filter              |
| `POLLINTERVAL`                   | `ups.conf` `pollinterval=` | Driver poll rate              |
| `MAXAGE`                         | `upsd.conf` `MAXAGE`       | Stale-data threshold          |
| `API_USER` / `API_PASSWORD`      | `upsd.users` (generated)   | One monitoring account        |
| `ACTIONS`                        | `upsd.users` `actions=`    | Allows `SET`/`FSD`            |
| `INSTCMDS`                       | `upsd.users` `instcmds=`   | Allows `upscmd`               |
| `SERVER`                         | `upsmon.conf` role         | PRIMARY vs SECONDARY          |
| `NOTIFYCMD`                      | `upsmon.conf` `NOTIFYCMD`  | Event hook script             |
| `SDORDER`, `SERIAL`              | driver/`ups.conf`          | Shutdown order, APC serial    |
| `USER` / `GROUP` / `ULIMIT`      | process credentials        | Must match udev perms         |
| `NUT_DEBUG_LEVEL`, `NUT_QUIET_*` | startup flags              | Log verbosity                 |
| `POLLONLY`                       | driver flag                | Workaround for flaky HID      |
| `SECRETNAME`                     | Docker secret lookup       | Alternative to `API_PASSWORD` |

With the compose file and two mounted config files above, the container runs as a master serving `usbhid@<UGREEN-IP>:3493`, authenticates both your monitoring tools and the WD EX2 Ultra's hardcoded `client/123` account, and exposes the UPS data your WD unit needs — subject only to the TLS compatibility caveat noted in §3.

# System-level configs (`/etc/...`)

Mirror of system-level config files that live outside `$HOME` and can't be
stow-linked. These are tracked here so the setup is reproducible and so
decisions baked into root-owned files aren't lost.

## Deployment

Not automatic. After editing, copy each file to its real location with `sudo`.
See the per-file notes below.

## Files

### Power profiles (`asusd/`, `tuned/`)

Battery -> ASUS quiet (`low-power`), AC -> `balanced`. Two daemons write
`/sys/firmware/acpi/platform_profile`, so they must agree:

- `asusd/asusd.ron`: `platform_profile_on_battery: LowPower`,
  `platform_profile_on_ac: Balanced`. (asusctl renamed `Quiet` to `LowPower`.)
- `tuned/ppd.conf`: on battery tuned-ppd maps `balanced` to
  `balanced-battery-quiet` instead of stock `balanced-battery`, which includes
  `balanced` and forces `platform_profile=balanced`, overriding asusd.
- `tuned/profiles/balanced-battery-quiet/tuned.conf`: `balanced-battery` plus
  `platform_profile=low-power|quiet`.

The old udev rule that ran `asusctl profile set` on plug events was removed;
it raced asusd and its `Quiet` argument no longer exists.

**Deploy:**

```sh
sudo install -m 644 asusd/asusd.ron /etc/asusd/
sudo install -m 644 tuned/ppd.conf /etc/tuned/
sudo install -D -m 644 tuned/profiles/balanced-battery-quiet/tuned.conf /etc/tuned/profiles/balanced-battery-quiet/tuned.conf
sudo systemctl restart asusd tuned-ppd
```

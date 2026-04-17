# System-level configs (`/etc/...`)

Mirror of system-level config files that live outside `$HOME` and can't be
stow-linked. These are tracked here so the setup is reproducible and so
decisions baked into root-owned files aren't lost.

## Deployment

Not automatic. After editing, copy each file to its real location with `sudo`.
See the per-file notes below.

## Files

### `udev/rules.d/99-power-profile.rules`

Switches the ASUS platform profile on AC plug/unplug:

- AC connected → `Balanced`
- AC disconnected → `Quiet`

**Why this file exists:** `asusd` has its own auto-switching
(`/etc/asusd/asusd.ron`: `platform_profile_on_ac: Balanced`,
`platform_profile_on_battery: Quiet`), but a udev rule was also set up to fire
`asusctl profile set <X>` on power-supply events. The two mechanisms race, and
whichever one the udev rule picks wins visibly. So the udev rule is kept in
sync with `asusd.ron` to avoid fighting.

**Deploy:**

```sh
sudo install -m 644 udev/rules.d/99-power-profile.rules /etc/udev/rules.d/
sudo udevadm control --reload
```

**If you change the desired profile**, update both this rule AND
`/etc/asusd/asusd.ron`'s `platform_profile_on_ac` / `platform_profile_on_battery`
keys to match.

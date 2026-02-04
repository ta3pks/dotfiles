# Hibernate Setup on Fedora 43 (btrfs + systemd 258)

## Overview

64GB disk-based swap file on btrfs with full hibernation and suspend-then-hibernate support.
Replaces default 8GB zram swap.

**System:** Fedora 43, kernel 6.18.x-cachyos, systemd 258, btrfs on NVMe, 27GB RAM, Sway/GDM

## Setup Steps

### 1. Disable zram

Create empty file to override default zram config:

```bash
sudo tee /etc/systemd/zram-generator.conf < /dev/null
```

### 2. Create 64GB swap file on btrfs

```bash
sudo btrfs subvolume create /swap
sudo btrfs filesystem mkswapfile --size 64G /swap/swapfile
sudo swapon /swap/swapfile
```

`btrfs filesystem mkswapfile` handles nocow, no-compression, and mkswap in one command.

### 3. Add swap to fstab

```
/swap/swapfile    none    swap    defaults    0 0
```

### 4. Get resume offset for hibernation

```bash
sudo btrfs inspect-internal map-swapfile -r /swap/swapfile
```

**Do NOT use `filefrag`** — it gives wrong offsets on btrfs.

### 5. Configure GRUB for resume

Edit `/etc/default/grub`, add to `GRUB_CMDLINE_LINUX`:

```
resume=UUID=<your-btrfs-uuid> resume_offset=<offset-from-step-4>
```

Regenerate GRUB:

```bash
sudo grub2-mkconfig -o /boot/grub2/grub.cfg
```

### 6. Configure dracut resume module

```bash
echo 'add_dracutmodules+=" resume "' | sudo tee /etc/dracut.conf.d/99-resume.conf
sudo dracut -f --regenerate-all
```

### 7. SELinux context (critical!)

systemd-logind runs in a confined SELinux domain and **cannot read swap files with `default_t` context**.
This causes `CanHibernate` to return "Access denied" and hides hibernate from GDM power menu.

```bash
sudo semanage fcontext -a -t swapfile_t "/swap/swapfile"
sudo restorecon -v /swap/swapfile
```

Verify: `ls -laZ /swap/swapfile` should show `swapfile_t`.

### 8. Sleep configuration

`/etc/systemd/sleep.conf.d/hibernate.conf`:

```ini
[Sleep]
AllowHibernation=yes
AllowSuspendThenHibernate=yes
HibernateMode=shutdown
HibernateDelaySec=10min
```

- `HibernateMode=shutdown` — fully powers off after writing image (more reliable than `platform` on some hardware)
- `HibernateDelaySec=10min` — when using suspend-then-hibernate, suspends first then hibernates after 10 minutes

### 9. Logind power button and lid configuration

`/etc/systemd/logind.conf.d/power-button.conf`:

```ini
[Login]
HandlePowerKey=suspend-then-hibernate
HandlePowerKeyLongPress=poweroff
HandleLidSwitch=suspend-then-hibernate
HandleLidSwitchExternalPower=suspend-then-hibernate
```

### 10. Polkit rule for passwordless hibernate

`/etc/polkit-1/rules.d/85-hibernate.rules`:

```javascript
polkit.addRule(function(action, subject) {
    if (action.id == "org.freedesktop.login1.hibernate" ||
        action.id == "org.freedesktop.login1.hibernate-multiple-sessions") {
        return polkit.Result.YES;
    }
});
```

### 11. (Optional) Reduce hibernate image size

To speed up hibernation by writing less data to disk:

```bash
echo 2147483648 | sudo tee /sys/power/image_size   # 2GB target
```

Make persistent via `/etc/tmpfiles.d/hibernate-image-size.conf`:

```
w /sys/power/image_size - - - - 2147483648
```

The kernel drops caches and compresses to fit. If actual used memory exceeds the target significantly, a larger image is written anyway.

## Gotchas

- **SELinux blocks logind from reading swap file** — The #1 issue. Without `swapfile_t` context, `systemctl hibernate` fails with "Access denied", `CanHibernate` returns false, and GDM hides the hibernate option. The audit log shows: `avc: denied { read } for comm="systemd-logind" ... tclass=file`
- **systemd 258 + btrfs swap** — Before the SELinux fix, this appeared to be a systemd bug but was actually just SELinux blocking the swap file read
- **`HibernateMode=platform` may not fully power off** — Use `shutdown` if the machine appears off but doesn't actually power down (LED blinking, power button doesn't wake)
- **Lid close ignored after resume** — logind has a ~30 second holdoff after waking; lid events during this window are deliberately ignored
- **Use `btrfs inspect-internal map-swapfile -r`** for resume_offset, never `filefrag`
- **Fedora uses dracut**, not mkinitcpio — the `resume` module must be added to dracut config

## Files Modified

| File | Purpose |
|------|---------|
| `/etc/systemd/zram-generator.conf` | Empty file — disables zram |
| `/swap/swapfile` | 64GB btrfs swap file |
| `/etc/fstab` | Swap entry |
| `/etc/default/grub` | resume= and resume_offset= kernel params |
| `/etc/dracut.conf.d/99-resume.conf` | Adds resume module to initramfs |
| `/etc/systemd/sleep.conf.d/hibernate.conf` | Hibernate mode and delay settings |
| `/etc/systemd/logind.conf.d/power-button.conf` | Power button and lid switch behavior |
| `/etc/polkit-1/rules.d/85-hibernate.rules` | Allow hibernate without password |
| `/etc/tmpfiles.d/hibernate-image-size.conf` | Persistent image_size reduction |

## Verify Everything Works

```bash
# Check swap is active
swapon --show

# Check logind sees hibernate
busctl call org.freedesktop.login1 /org/freedesktop/login1 org.freedesktop.login1.Manager CanHibernate

# Check SELinux context
ls -laZ /swap/swapfile

# Test hibernate
systemctl hibernate
```

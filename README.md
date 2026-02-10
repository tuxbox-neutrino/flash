## flash-script

Single flash entrypoint used by Neutrino images.

Deutsch: [README.de.md](README.de.md)

The script is designed to be machine-data driven and to avoid per-machine
branches where possible.

### Inputs

- `/etc/image-version` (required)
  - `machine`
  - `imagename`/`image_name`
  - `image_update_url`
  - `image_update_info_file`
  - `image_file_name`
- `/etc/tuxbox/flash-machine-profile.conf` (optional but recommended)
  - `FLASH_MACHINE`
  - `FLASH_KERNEL_FILE`
  - `FLASH_ROOTFS_FILE`
  - `FLASH_SCRIPT_LAYOUT` (`linuxrootfs` or `rootfs`)
  - `FLASH_KERNEL_LABEL_BASE`
  - `FLASH_ROOT_LABEL_BASE`
  - `FLASH_ROOTFS_TARGET_BASE`

### Invocation

```bash
flash <slot> [<image-dir>|restore|force]
```

- `slot`: target partition `1..4`
- no second arg: online update check, download if changed
- `force`: force download
- `restore`: use backup path
- absolute path: flash from local unpacked image directory

### Layout handling

The script supports two runtime layouts:

- `linuxrootfs`: `linuxkernelN` + `/mnt/userdata/linuxrootfsN`
- `rootfs`: `kernelN` + `/mnt/rootfsN`

Layout is auto-detected from available partition labels and can be overridden
with `FLASH_SCRIPT_LAYOUT`.

### Development notes

- Keep this script POSIX `sh` compatible.
- Prefer metadata/profile values over machine hardcoding.
- New machine-specific handling should be introduced via profile keys, not via
  new long-lived branches.

Quick local validation:

```bash
./tests/smoke.sh
```

Historical note:
The repository was originally extracted from
`neutrino-hd/meta-hd51:recipes-images/base-files/files/flash`.

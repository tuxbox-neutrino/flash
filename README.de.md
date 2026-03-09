## flash-script

Zentraler Flash-Einstiegspunkt für Neutrino-Images.

English: [README.md](README.md)

Das Skript ist datengetrieben aufgebaut und soll maschinenspezifische
Langzeit-Branches vermeiden.

### Eingaben

- `/etc/image-version` (erforderlich)
  - `machine`
  - `imagename`/`image_name`
  - `image_update_url`
  - `image_update_info_file`
  - `image_file_name`
- `/etc/tuxbox/flash-machine-profile.conf` (optional, empfohlen)
  - `FLASH_MACHINE`
  - `FLASH_KERNEL_FILE`
  - `FLASH_ROOTFS_FILE`
  - `FLASH_SCRIPT_LAYOUT` (`linuxrootfs` oder `rootfs`)
  - `FLASH_KERNEL_LABEL_BASE`
  - `FLASH_ROOT_LABEL_BASE`
  - `FLASH_ROOTFS_TARGET_BASE`
  - weitere im Skript genutzte `FLASH_*`-Overrides

### Profilbeispiel

```sh
# /etc/tuxbox/flash-machine-profile.conf

# Maschinen-/Payload-Zuordnung
FLASH_MACHINE="hd51"
FLASH_KERNEL_FILE="kernel.bin"
FLASH_ROOTFS_FILE="rootfs.tar.bz2"

# Optionales Layout-Override:
# - linuxrootfs: linuxkernelN + /mnt/userdata/linuxrootfsN
# - rootfs:      kernelN + /mnt/rootfsN
FLASH_SCRIPT_LAYOUT="linuxrootfs"

# Optionale Label-/Ziel-Basisnamen
FLASH_KERNEL_LABEL_BASE="linuxkernel"
FLASH_ROOT_LABEL_BASE="linuxrootfs"
FLASH_ROOTFS_TARGET_BASE="/mnt/userdata/linuxrootfs"

# Optionale Runtime-Overrides (häufig für Tests sinnvoll)
# FLASH_DEV_BASE="/dev/disk/by-partlabel"
# FLASH_DESTINATION_BASE="/mnt/userdata"
# FLASH_PROC_MOUNTS_FILE="/proc/mounts"
# FLASH_PROC_CMDLINE_FILE="/proc/cmdline"
# FLASH_TMP_BASE="/tmp/.flash"
# FLASH_MOUNT_CANDIDATES="/media/usb /media/USB /media/hdd /media/Generic-"
# FLASH_CURL_BIN="curl"
# FLASH_UNZIP_BIN="unzip"
# FLASH_SYSTEMCTL_BIN="systemctl"
# FLASH_PIDOF_BIN="pidof"
# FLASH_PV_BIN="pv"
```

### Aufruf

```bash
flash <slot> [<image-dir>|restore|force]
```

- `slot`: Zielpartition `1..4`
- ohne zweites Argument: Online-Update prüfen, bei Änderung herunterladen
- `force`: Download erzwingen
- `restore`: Backup-Pfad verwenden
- absoluter Pfad: aus lokal entpacktem Image-Verzeichnis flashen

### Layout-Behandlung

Das Skript unterstützt zwei Runtime-Layouts:

- `linuxrootfs`: `linuxkernelN` + `/mnt/userdata/linuxrootfsN`
- `rootfs`: `kernelN` + `/mnt/rootfsN`

Das Layout wird anhand vorhandener Partition-Labels automatisch erkannt und
kann über `FLASH_SCRIPT_LAYOUT` übersteuert werden.

### Hinweise für Entwicklung

- Das Skript POSIX-`sh`-kompatibel halten.
- Metadaten/Profilwerte gegenüber Maschinen-Hardcoding bevorzugen.
- Neue maschinenspezifische Anpassungen über Profil-Keys statt über neue
  dauerhafte Branches einführen.

Schnelle lokale Prüfung:

```bash
./tests/smoke.sh
```

Historische Notiz:
Das Repository wurde ursprünglich aus
`neutrino-hd/meta-hd51:recipes-images/base-files/files/flash` extrahiert.

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

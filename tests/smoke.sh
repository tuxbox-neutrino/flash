#!/bin/sh
set -eu

SCRIPT_DIR="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
FLASH_SCRIPT="${SCRIPT_DIR}/../flash"

run_linuxrootfs_smoke() {
	tmpdir="$(mktemp -d /tmp/flash-script-smoke-a-XXXXXX)"
	trap 'rm -rf "${tmpdir}"' EXIT INT HUP TERM

	mkdir -p "${tmpdir}/bin" "${tmpdir}/dev/disk/by-partlabel" \
		"${tmpdir}/mnt/userdata" "${tmpdir}/media/usb/service/image/testbox" \
		"${tmpdir}/icons" "${tmpdir}/proc"

	cat > "${tmpdir}/image-version" <<'EOF'
machine=testbox
imagename=neutrino-image
image_update_url=file:///invalid
image_update_info_file=imageversion
image_file_name=test.zip
EOF

	cat > "${tmpdir}/profile.conf" <<'EOF'
FLASH_MACHINE="testbox"
FLASH_KERNEL_FILE="kernel.bin"
FLASH_ROOTFS_FILE="rootfs.tar.bz2"
EOF

	cat > "${tmpdir}/proc/mounts" <<EOF
/dev/sdx1 ${tmpdir}/media/usb ext4 rw,relatime 0 0
EOF

	cat > "${tmpdir}/proc/cmdline" <<'EOF'
console=ttyS0 root=/dev/mmcblk0p3 rootsubdir=1 quiet
EOF

	echo osd_resolution=1 > "${tmpdir}/neutrino.conf"
	touch "${tmpdir}/dev/disk/by-partlabel/linuxkernel" \
		"${tmpdir}/dev/disk/by-partlabel/linuxkernel2"
	ln -s /dev/mmcblk0p4 "${tmpdir}/dev/disk/by-partlabel/linuxrootfs2"

	echo "kernel-payload" > "${tmpdir}/media/usb/service/image/testbox/kernel.bin"
	mkdir -p "${tmpdir}/rootfs-src"
	echo "rootfs-ok" > "${tmpdir}/rootfs-src/marker.txt"
	tar -cjf "${tmpdir}/media/usb/service/image/testbox/rootfs.tar.bz2" \
		-C "${tmpdir}/rootfs-src" .

	cat > "${tmpdir}/bin/pidof" <<'EOF'
#!/bin/sh
exit 1
EOF
	chmod +x "${tmpdir}/bin/pidof"

	cat > "${tmpdir}/bin/systemctl" <<'EOF'
#!/bin/sh
exit 0
EOF
	chmod +x "${tmpdir}/bin/systemctl"

	FLASH_VERSION_FILE="${tmpdir}/image-version" \
	FLASH_PROFILE_FILE="${tmpdir}/profile.conf" \
	FLASH_DEV_BASE="${tmpdir}/dev/disk/by-partlabel" \
	FLASH_DESTINATION_BASE="${tmpdir}/mnt/userdata" \
	FLASH_DISPLAY_DEVICE="${tmpdir}/display" \
	FLASH_PROC_MOUNTS_FILE="${tmpdir}/proc/mounts" \
	FLASH_PROC_CMDLINE_FILE="${tmpdir}/proc/cmdline" \
	FLASH_NEUTRINO_CONF="${tmpdir}/neutrino.conf" \
	FLASH_AVS_INPUT_PATH="${tmpdir}/proc/avs" \
	FLASH_ICON_DIR="${tmpdir}/icons" \
	FLASH_MOUNT_CANDIDATES="${tmpdir}/media/usb" \
	FLASH_SYSTEMCTL_BIN="${tmpdir}/bin/systemctl" \
	FLASH_PIDOF_BIN="${tmpdir}/bin/pidof" \
	FLASH_PV_BIN="__pv_missing__" \
	"${FLASH_SCRIPT}" 2 "${tmpdir}/media/usb/service/image" >/dev/null

	[ "$(cat "${tmpdir}/dev/disk/by-partlabel/linuxkernel2")" = "kernel-payload" ]
	[ -f "${tmpdir}/mnt/userdata/linuxrootfs2/marker.txt" ]

	rm -rf "${tmpdir}"
	trap - EXIT INT HUP TERM
}

run_rootfs_smoke() {
	tmpdir="$(mktemp -d /tmp/flash-script-smoke-b-XXXXXX)"
	trap 'rm -rf "${tmpdir}"' EXIT INT HUP TERM

	mkdir -p "${tmpdir}/bin" "${tmpdir}/dev/disk/by-partlabel" \
		"${tmpdir}/mnt/rootfs2" "${tmpdir}/media/usb/service/image/testbox" \
		"${tmpdir}/icons" "${tmpdir}/proc" "${tmpdir}/dev"

	cat > "${tmpdir}/image-version" <<'EOF'
machine=testbox
imagename=neutrino-image
image_update_url=file:///invalid
image_update_info_file=imageversion
image_file_name=test.zip
EOF

	cat > "${tmpdir}/profile.conf" <<'EOF'
FLASH_MACHINE="testbox"
FLASH_KERNEL_FILE="kernel.bin"
FLASH_ROOTFS_FILE="rootfs.tar.bz2"
FLASH_SCRIPT_LAYOUT="rootfs"
EOF

	cat > "${tmpdir}/proc/mounts" <<EOF
/dev/sdx1 ${tmpdir}/media/usb ext4 rw,relatime 0 0
EOF

	cat > "${tmpdir}/proc/cmdline" <<'EOF'
console=ttyS0 root=/dev/mmcblk1p1 quiet
EOF

	echo osd_resolution=0 > "${tmpdir}/neutrino.conf"
	: > "${tmpdir}/dev/mmcblk1p2"
	: > "${tmpdir}/dev/mmcblk1p3"
	ln -s "${tmpdir}/dev/mmcblk1p2" "${tmpdir}/dev/disk/by-partlabel/kernel2"
	ln -s "${tmpdir}/dev/mmcblk1p3" "${tmpdir}/dev/disk/by-partlabel/rootfs2"

	echo "kernel-rootfs-layout" > "${tmpdir}/media/usb/service/image/testbox/kernel.bin"
	mkdir -p "${tmpdir}/rootfs-src"
	echo "rootfs-layout-ok" > "${tmpdir}/rootfs-src/marker.txt"
	tar -cjf "${tmpdir}/media/usb/service/image/testbox/rootfs.tar.bz2" \
		-C "${tmpdir}/rootfs-src" .

	cat > "${tmpdir}/bin/pidof" <<'EOF'
#!/bin/sh
exit 1
EOF
	chmod +x "${tmpdir}/bin/pidof"

	cat > "${tmpdir}/bin/systemctl" <<'EOF'
#!/bin/sh
exit 0
EOF
	chmod +x "${tmpdir}/bin/systemctl"

	FLASH_VERSION_FILE="${tmpdir}/image-version" \
	FLASH_PROFILE_FILE="${tmpdir}/profile.conf" \
	FLASH_DEV_BASE="${tmpdir}/dev/disk/by-partlabel" \
	FLASH_ROOTFS_TARGET_BASE="${tmpdir}/mnt/rootfs" \
	FLASH_DISPLAY_DEVICE="${tmpdir}/display" \
	FLASH_PROC_MOUNTS_FILE="${tmpdir}/proc/mounts" \
	FLASH_PROC_CMDLINE_FILE="${tmpdir}/proc/cmdline" \
	FLASH_NEUTRINO_CONF="${tmpdir}/neutrino.conf" \
	FLASH_AVS_INPUT_PATH="${tmpdir}/proc/avs" \
	FLASH_ICON_DIR="${tmpdir}/icons" \
	FLASH_MOUNT_CANDIDATES="${tmpdir}/media/usb" \
	FLASH_SYSTEMCTL_BIN="${tmpdir}/bin/systemctl" \
	FLASH_PIDOF_BIN="${tmpdir}/bin/pidof" \
	FLASH_PV_BIN="__pv_missing__" \
	"${FLASH_SCRIPT}" 2 "${tmpdir}/media/usb/service/image" >/dev/null

	[ "$(cat "${tmpdir}/dev/mmcblk1p2")" = "kernel-rootfs-layout" ]
	[ -f "${tmpdir}/mnt/rootfs2/marker.txt" ]

	rm -rf "${tmpdir}"
	trap - EXIT INT HUP TERM
}

sh -n "${FLASH_SCRIPT}"
run_linuxrootfs_smoke
run_rootfs_smoke

echo "flash-script smoke: OK"

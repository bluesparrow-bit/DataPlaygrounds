# Fedora KDE Dual Boot Troubleshooting Guide

Notes from dual booting Fedora 44 KDE Plasma next to Windows 11 on a single NVMe drive. Use this as a checklist and fix-list for future installs.

## Pre-install checklist

- Back up anything important from the Windows drive first.
- Turn off BitLocker / Device Encryption in Windows and wait until it says fully decrypted. Linux tools cannot resize an encrypted partition.
- Turn off Fast Startup (Control Panel > Power Options > Choose what the power buttons do > Change settings that are currently unavailable) and run `powercfg /h off` in an admin Command Prompt.
- Do a full shutdown with `shutdown /s /t 0` before booting the live USB, not a plain restart.
- Check the BIOS: Secure Boot status, and SATA mode set to AHCI (not RAID / Intel RST).
- Decide how much space Fedora gets (40 GB was enough for a basic install).

## Problem 1: Windows will not shrink the C drive enough

**Symptom:** File Explorer shows about 220 GB free, but Disk Management only offers a few GB to shrink.

**Cause:** Unmovable files (page file, hibernation file, shadow copies / restore points) sit near the end of the partition.

**What to try first:**

1. Admin Command Prompt: `powercfg /h off`
2. System Properties (`sysdm.cpl`) > Advanced > Performance > Advanced > Virtual memory: set No paging file on C:
3. System Protection tab: disable protection on C: and delete restore points
4. `chkdsk C: /f` (runs on next reboot)
5. Restart, run Defragment and Optimize Drives on C:
6. Try Shrink Volume again

**If it still will not budge:** shrink from the Fedora live USB with KDE Partition Manager (or GParted) instead. Windows' limits do not apply when the partition is offline.

Afterwards, turn the page file and System Protection back on.

## Problem 2: Size box grayed out in KDE Partition Manager

**Symptom:** In the live session, Resize/Move shows the Size field grayed out, with no warning message.

**Cause:** The partition was listed as **BitLocker**, not NTFS. Linux tools cannot resize it.

**Fix:** Boot Windows, turn off BitLocker / Device Encryption, wait for full decryption (verify with `manage-bde -status C:` showing Fully Decrypted, 0% encrypted), do a full shutdown, then return to the live USB. The partition should now show as ntfs and the Size box unlocks.

## Problem 3: Windows blue screen after the shrink (UNMOUNTABLE\_BOOT\_VOLUME)

**Symptom:** After shrinking in KDE Partition Manager, Windows would not boot. The shrink had reported an odd error ("filesystem already has the requested length"). In the Windows recovery command prompt, `chkdsk` said the volume was RAW and could not be checked.

**Cause:** The resize did not finish cleanly, so the NTFS boot sector and the recorded filesystem size no longer matched the partition.

**How it was fixed:**

1. Boot the Fedora live USB. Find the partition with `lsblk` (here: `/dev/nvme0n1p3`). Check the name carefully, a typo like `nvme01p3` gives "No such file or directory".
2. Run `sudo ntfsfix /dev/nvme0n1p3`. It used the backup boot sector, corrected the sector count, and rewrote the boot sector.
3. A normal mount still failed ("wrong fs type, bad superblock") and `dmesg` showed the volume was dirty and `$BadClus` failed to load.
4. A forgiving mount worked and files were visible: `sudo ntfs-3g -o ro,force /dev/nvme0n1p3 /mnt/win`. (This confirmed the data was safe.)
5. Unmount, then `sudo ntfsfix -d /dev/nvme0n1p3` to clear the dirty flag.
6. `sudo ntfsresize --no-action /dev/nvme0n1p3` reported the volume size was already correct.
7. Shut down fully, unplug the USB, and boot Windows. It started normally. Then run `chkdsk C: /f` once from Windows to finish cleaning up.

**Lesson:** Do not panic, do not format or reinstall. Data was intact the whole time. If this happens again, mount read-only first and copy off important files before trying repairs.

## Problem 4: Installer partition leftovers and busy mounts

**Symptom:** After a failed install attempt, Fedora partitions (ext4 /boot and btrfs root) were left behind and Partition Manager could not unmount them ("could not be unmounted"). `sudo umount -R /mnt/sysroot` said target is busy.

**Fix:** Restart the live session so all mounts are cleared, then in KDE Partition Manager delete only the leftover Fedora partitions (not the EFI, Microsoft reserved, Windows, or recovery partitions) and click Apply. Then re-run the installer into the clean unallocated space.

## Installer notes

- Choose "Share disk with other operating systems" and do not use reclaim space. Reclaim can delete or shrink Windows partitions.
- Check the review page: only new partitions should be created in the free space. The existing EFI partition is reused for `/boot/efi`.
- A warning that `/boot/efi` is smaller than 500 MB is safe to ignore when sharing Windows' 100 MB EFI partition.
- Encryption: left off for simplicity.

## Post-install setup

1. **Update first:** `sudo dnf upgrade`, press Y, then reboot (the first update was about 2 GB download).
2. **Third-party repositories:** enabling them in the Welcome Center adds Flathub and extras.
3. **Codecs and extras:** enable RPM Fusion (free and nonfree) after the update.
4. **Scrolling direction:** System Settings > Input Devices > Touchpad (or Mouse) > Invert scroll direction.
5. **Keyboard layouts:** add a second layout (such as Arabic) during setup or in System Settings > Keyboard.
6. **Hostname:** lowercase letters, numbers, and dashes only (e.g. `blue-fedora`).
7. **GRUB timeout:** raise it in the GRUB settings so the boot menu stays long enough to read.
8. **Windows side:** keep Fast Startup and hibernation off so the two systems do not fight over the NTFS disk.

## Switching between Fedora and Windows

- **GRUB menu:** appears at startup, tap the down arrow or Esc to stop the timer and choose Fedora or Windows.
- **One-time boot menu:** tap F11 (on this laptop) at power-on and pick Fedora or Windows Boot Manager.
- **Default:** whichever entry is first in the BIOS boot order. If Windows is missing from GRUB, it can be re-added later with a GRUB config update.

## Handy reminders

- No output after a `mount` command usually means it worked.
- `ntfsfix` only repairs basic NTFS problems and clears flags; run `chkdsk` from Windows afterwards.
- Never format, clean, or reinstall until you have confirmed whether data is readable.

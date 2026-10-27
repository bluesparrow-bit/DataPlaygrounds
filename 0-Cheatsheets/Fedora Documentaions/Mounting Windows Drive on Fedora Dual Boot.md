# Mounting Windows Drive on Fedora Dual Boot

Oct 27, 2026 · @Blue

## Overview

On a dual-boot laptop, Fedora can read the Windows drive by mounting it: attaching the Windows partition to an empty folder so its files appear there. The safe workflow is identify the partition, mount it read-only, copy what you need, then unmount before restarting or booting into Windows.

Read-only is the default here because a hard power-off or a hibernated Windows volume mounted read-write can corrupt the NTFS filesystem.

## Before you start

Two things decide whether the mount works: knowing which partition is the Windows C: drive, and Windows being fully shut down.

**1. Identify the Windows partition**

```bash
lsblk -o NAME,SIZE,FSTYPE,LABEL
```

`lsblk` lists block devices (drives and partitions). `-o NAME,SIZE,FSTYPE,LABEL` chooses the columns to show: partition name, size, filesystem type and label. The big `ntfs` partition is C:. On this machine:

| Partition | Size | Type | What it is |
| --- | --- | --- | --- |
| `nvme0n1p1` | 100M | vfat | EFI boot partition |
| `nvme0n1p2` | 16M | none | Microsoft reserved |
| `nvme0n1p3` | 435.8G | ntfs | Windows C: drive (the one to mount) |
| `nvme0n1p4` | 1006M | ntfs | Windows recovery partition |

Partition names differ between PCs, so always check before mounting. Do not assume the partition from this table.

**2. Turn off Windows Fast Startup**

Fast Startup makes a Windows shutdown behave like hibernation, which leaves the NTFS volume in an unsafe state. Boot into Windows and run this in an admin Command Prompt:

```
powercfg /h off
```

`powercfg` manages power settings, `/h off` turns hibernation (and with it Fast Startup) off. Also untick Fast Startup in Control Panel, Power Options, Choose what the power buttons do. From then on, shut Windows down fully before booting Fedora.

**3. Check for BitLocker**

If `lsblk -f` shows `BitLocker` as the filesystem type, the partition is encrypted and cannot be mounted directly. It needs the recovery key and a tool called `dislocker`.

## Mounting steps

The `ntfs-3g` driver in read-only mode worked on this machine, while the newer built-in `ntfs3` driver refused the volume with a `$BadClus` error.

1. **Create the mount point** (an empty folder where the drive will appear).

   ```bash
   sudo mkdir -p /mnt/windows
   ```

   `sudo` runs as administrator because `/mnt` is owned by root. `mkdir` makes a directory, and `-p` creates parent folders if needed and does not error if the folder already exists, so it is safe to run twice.
2. **Install the ntfs-3g driver** (once only).

   ```bash
   sudo dnf install ntfs-3g
   ```

   `dnf install` installs a package. `ntfs-3g` is a tolerant NTFS driver that mounts volumes the built-in driver rejects.
3. **Mount the Windows partition read-only.**

   ```bash
   sudo mount -t ntfs-3g -o ro /dev/nvme0n1p3 /mnt/windows
   ```

   `mount` attaches a filesystem to a folder. `-t ntfs-3g` sets the filesystem type and driver. `-o ro` passes the option `ro` (read-only), so nothing can be written or damaged. `/dev/nvme0n1p3` is the Windows partition from the previous section, and `/mnt/windows` is the folder from step 1.
4. **Check that it worked.**

   ```bash
   command ls /mnt/windows/Users
   ```

   This lists the Windows `Users` folder, where your Windows username folder appears next to `Public` and `Default`. `command` runs the real `ls` and skips any alias, which matters if `ls` is aliased to a tool like `eza`. A working alias fix is `alias ls='eza --icons=auto'`, because a bare `--icons` swallows the next argument.

To mount read-write instead, replace `-o ro` with `-o rw` only when Windows was shut down fully and the volume is known to be clean.

## Using the files

Your Windows documents are under `/mnt/windows/Users/<your-windows-name>/Documents`. Stay inside your own user folder and avoid `Windows`, `Program Files` and `ProgramData`.

```bash
cp -r /mnt/windows/Users/<name>/Documents/MyFolder ~/Documents/
```

`cp` copies files. `-r` (recursive) copies a folder with everything inside it. The first path is the source on the Windows drive and the second is the destination in your Fedora home folder. Copying to Fedora (instead of working inside the mount) keeps the Windows files untouched.

**Shortcut in KDE**

Open Dolphin and click the Windows partition under Devices in the left sidebar. It mounts automatically, usually under `/run/media/blue/`. The small eject icon next to it unmounts safely, doing the same job as `umount` below.

## Unmounting

Unmount before rebooting into Windows or powering off, so all pending writes are flushed. A normal shutdown also unmounts cleanly, but a hard power-off while mounted can leave the volume marked dirty.

1. **Leave the mounted folder.** Linux refuses to unmount a filesystem while the terminal is inside it.

   ```bash
   cd ~
   ```

   `cd` changes directory and `~` is your home folder.
2. **Unmount.**

   ```bash
   sudo umount /mnt/windows
   ```

   `umount` detaches the filesystem. The command is spelled `umount`, not `unmount`. It takes the mount folder (or the device) as its argument.
3. **Verify.**

   ```bash
   findmnt /mnt/windows
   ```

   `findmnt` shows mounted filesystems. No output means the drive is unmounted.

**If it says "target is busy"**

```bash
sudo lsof +f -- /mnt/windows
```

`lsof` lists open files. `+f --` tells it that the argument is a mount point, so it shows every program using that filesystem. Close those programs (often a Dolphin window or a terminal tab sitting in the folder) and run `umount` again.

```bash
sudo umount -l /mnt/windows
```

`-l` (lazy) detaches the filesystem now and finishes cleaning up once nothing is using it. Use it only as a last resort.

## Troubleshooting

The errors seen on this machine and the usual causes.

| Symptom | Cause | Fix |
| --- | --- | --- |
| `wrong fs type, bad option, bad superblock` | Wrong partition, or the `ntfs3` driver rejected the volume | Confirm the partition with `lsblk`, then use `-t ntfs-3g -o ro` |
| `Failed to load $BadClus (-22)` in `dmesg` | `ntfs3` cannot read a metadata file on this volume | Mount with `ntfs-3g` instead |
| Mount refuses, mentions hibernated or unsafe state | Windows Fast Startup left the volume unclean | In Windows run `powercfg /h off`, then shut down fully |
| Still fails after Fast Startup is off | NTFS inconsistency | In Windows run `chkdsk C: /f` in an admin Command Prompt, accept the scheduled check, restart and let it finish |
| Partition type shows `BitLocker` | Drive is encrypted | Needs the recovery key and `dislocker` |
| `sudo: unmount: command not found` | Wrong spelling | Use `umount` |
| `target is busy` | A terminal or program is inside the mount | `cd ~`, close the program, or use `lsof` as above |
| `ls /boot` errors about `--icons` | `ls` is aliased and `--icons` swallows the path | Run `command ls` or change the alias to `--icons=auto` |

**Reading why a mount failed**

```bash
sudo dmesg | tail -n 15
```

`dmesg` prints kernel messages and needs `sudo`. `tail -n 15` shows the last 15 lines, where the mount error is explained.

Avoid `ntfsfix` and read-write mounts on a volume that has not been checked by Windows, because they can hide or worsen filesystem damage.

## Command quick reference

The whole routine is four commands: find the partition, mount it read-only, copy files, unmount.

| Step | Command | What it does |
| --- | --- | --- |
| 1 | `lsblk -o NAME,SIZE,FSTYPE,LABEL` | Lists partitions to find the big `ntfs` C: drive |
| 2 | `sudo mkdir -p /mnt/windows` | Creates the mount folder (once) |
| 3 | `sudo dnf install ntfs-3g` | Installs the tolerant NTFS driver (once) |
| 4 | `sudo mount -t ntfs-3g -o ro /dev/nvme0n1p3 /mnt/windows` | Mounts the Windows drive read-only |
| 5 | `command ls /mnt/windows/Users` | Confirms the files are visible |
| 6 | `cp -r <source> ~/Documents/` | Copies files into Fedora |
| 7 | `cd ~` | Leaves the mounted folder |
| 8 | `sudo umount /mnt/windows` | Unmounts the drive |
| 9 | `findmnt /mnt/windows` | No output means it is unmounted |

# NVIDIA Driver Setup on Fedora 44 (Secure Boot)

Oct 27, 2026 · @Blue

## Overview

This setup replaces the basic open-source **nouveau** driver with NVIDIA's proprietary driver, so the GTX 1650 can run games, CUDA and machine-learning work on Fedora with Secure Boot left on.

Fedora does not ship NVIDIA's driver, so it comes from the RPM Fusion repository. Secure Boot only lets the kernel load signed drivers, so the driver is signed with a personal key that the firmware is told to trust. The driver package (`akmod-nvidia`) rebuilds and re-signs itself after every kernel update.

## Environment

The machine is an MSI laptop with a GTX 1650 Mobile, running Fedora 44 KDE with Secure Boot enabled.

| Item | Value |
| --- | --- |
| GPU | NVIDIA GeForce GTX 1650 Mobile / Max-Q (TU117M) |
| Laptop | MSI |
| OS | Fedora 44 KDE, dual boot with Windows 11 |
| Secure Boot | Enabled |
| Driver before | nouveau (open source) |
| Driver after | nvidia, version 615.78.08 |

## Diagnosis

Three checks showed that the GTX was running on nouveau and that Secure Boot needed a signed driver.

| Check | Command | Result | Meaning |
| --- | --- | --- | --- |
| Is the NVIDIA tool installed? | `nvidia-smi` | command not found | Proprietary driver not installed |
| Which driver runs the GPU? | `lspci -k \| grep -iA3 nvidia` | `Kernel driver in use: nouveau` | Slow open-source driver in use |
| Is Secure Boot on? | `mokutil --sb-state` | SecureBoot enabled | Driver must be signed |

**Command breakdown**

- `lspci -k` lists PCI devices (graphics cards included) and, with `-k`, the kernel driver each one uses.
- `grep -iA3 nvidia` filters lines containing "nvidia". `-i` ignores upper/lower case and `-A3` also prints the 3 lines after each match, where the driver name appears.
- `mokutil --sb-state` prints whether Secure Boot is enabled. `mokutil` manages Secure Boot keys, and `--sb-state` changes nothing.

## Installation steps

The order matters: the signing key must be trusted before the driver is installed, or the driver is built but refused at boot.

1. **Add RPM Fusion** (the extra repository that holds NVIDIA's driver).

   ```bash
   sudo dnf install https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
   ```

   `sudo` runs as administrator and `dnf install` installs packages, here straight from two URLs. `$(rpm -E %fedora)` first runs `rpm -E %fedora`, which prints the Fedora version (44), and pastes it into the URL. The `free` link adds the free-software repo and the `nonfree` link adds the one containing NVIDIA's driver.
2. **Install the signing tools.**

   ```bash
   sudo dnf install kmodtool akmods mokutil openssl
   ```

   `kmodtool` and `akmods` build and sign kernel modules automatically, `mokutil` manages Secure Boot keys, and `openssl` creates the cryptographic key.
3. **Create the signing key.**

   ```bash
   sudo kmodgenca -a
   ```

   `kmodgenca` creates a signing key and certificate for kernel modules. `-a` (`--auto`) generates them without asking questions. If a key already exists, continue.
4. **Queue the key to be trusted.**

   ```bash
   sudo mokutil --import /etc/pki/akmods/certs/public_key.der
   ```

   `--import` queues a certificate to be enrolled as a Machine Owner Key (MOK), and the path is the public half of the key from step 3. It asks for a one-time password. If it prints `SKIP: ... is already enrolled`, the firmware already trusts the key and steps 5 and 6 can be skipped (this was the case on this machine).
5. **Reboot and enroll the key** (only if step 4 asked for a password).

   ```bash
   sudo reboot
   ```

   On the blue MOK management screen choose Enroll MOK, Continue, Yes, type the password from step 4, then Reboot. The screen uses a US keyboard layout, so keep the password simple.
6. **Confirm the key is enrolled.**

   ```bash
   sudo mokutil --test-key /etc/pki/akmods/certs/public_key.der
   ```

   `--test-key` checks whether a certificate is enrolled. It should print `is already enrolled`. Without `sudo` it fails with `Failed to open`, because the key folder is readable by root only.
7. **Install the driver.**

   ```bash
   sudo dnf install akmod-nvidia
   ```

   `akmod-nvidia` is the NVIDIA driver, packaged to rebuild and sign itself with the key from step 3 after every kernel update.
8. **Wait about 5 minutes, then check the module was built.**

   ```bash
   modinfo -F version nvidia
   ```

   `modinfo` shows information about a kernel module and `-F version` prints only the version field. A version number (here `615.78.08`) means the build finished. `module not found` means wait a few more minutes. Do not reboot before a version prints.
9. **Reboot to load the driver.**

   ```bash
   sudo reboot
   ```
10. **Install the monitoring tool.** `akmod-nvidia` does not include `nvidia-smi`.

    ```bash
    sudo dnf install xorg-x11-drv-nvidia-cuda
    ```

    This package contains `nvidia-smi` and the CUDA libraries. Do not choose the `390xx`, `470xx` or `580xx` variants, which are for older GPUs and conflict with the current driver.

## Verification

The driver is working when `lspci` reports `nvidia` as the driver in use and `nvidia-smi` prints a table naming the GTX 1650.

```bash
lspci -k | grep -iA3 nvidia
```

`lspci -k` lists PCI devices with their kernel driver, and `grep -iA3 nvidia` keeps the NVIDIA lines (`-i` ignores case) plus the 3 lines after each match (`-A3`). Expected line: `Kernel driver in use: nvidia`. The `Kernel modules:` line only lists modules that could drive the card, so `nouveau` appearing there is normal.

```bash
nvidia-smi
```

`nvidia-smi` (NVIDIA System Management Interface) is NVIDIA's read-only monitoring tool. With no flags it prints one snapshot: GPU name, driver version, temperature, power, memory use (VRAM), GPU usage and the programs running on the GPU. A table with the GeForce GTX 1650 confirms Linux is using the GPU.

```bash
watch -n 1 nvidia-smi
```

`watch` repeats a command and redraws the screen, and `-n 1` sets a 1-second interval. This gives a live view. Press Ctrl+C to stop.

In the processes list at the bottom, an empty or short list is normal on this laptop, because the desktop runs on the integrated GPU by default.

## Running programs on the GTX

On this hybrid-graphics laptop the desktop uses the integrated GPU to save battery, and the GTX is chosen per program.

```bash
switcherooctl launch firefox
```

`switcherooctl` is Fedora's tool for choosing between GPUs. `launch` runs the program that follows it on the non-default GPU, here the GTX. In KDE the same can be done by right-clicking an app in the menu and choosing Run using Dedicated Graphics Card.

```bash
sudo dnf install mesa-demos
glxinfo -B | grep "OpenGL renderer"
DRI_PRIME=1 glxinfo -B | grep "OpenGL renderer"
```

`dnf install mesa-demos` installs the package that provides `glxinfo`. `glxinfo -B` prints a brief graphics summary, and `grep "OpenGL renderer"` keeps only the line naming the renderer. `DRI_PRIME=1` is an environment variable applied to that one command only, which asks Mesa to use the secondary GPU. The renderer name should change between the two runs.

For NVIDIA's proprietary driver, offloading uses two variables instead:

```bash
__NV_PRIME_RENDER_OFFLOAD=1 __GLX_VENDOR_LIBRARY_NAME=nvidia glxinfo -B | grep "OpenGL renderer"
```

Both variables apply to this one program and tell the NVIDIA driver to render it on the NVIDIA GPU. While a program runs this way, `nvidia-smi` lists it in the processes table.

## Troubleshooting

Most problems on this setup came from a missing package, a permissions issue or the order of steps.

| Symptom | Cause | Fix |
| --- | --- | --- |
| `nvidia-smi: command not found` | The tool is in a separate package | `sudo dnf install xorg-x11-drv-nvidia-cuda` |
| `mokutil --test-key` says `Failed to open` | The key folder is readable by root only | Run it with `sudo` |
| `SKIP: ... is already enrolled` on import | The firmware already trusts the key | Skip the reboot and MOK screen, go to step 7 |
| `modinfo` says module not found | `akmod-nvidia` is still compiling | Wait a few minutes and run it again, do not reboot yet |
| `lspci` still shows `nouveau` after the reboot | Driver refused, often by Secure Boot | Run `sudo dmesg \| grep -i nvidia \| tail -n 15` and look for a key or signature rejection |
| `sudo: unmount: command not found` | The command is spelled `umount` | `sudo umount /mnt/windows` |

**Reading kernel messages**

```bash
sudo dmesg | grep -i nvidia | tail -n 15
```

`dmesg` prints kernel messages and needs `sudo`. `grep -i nvidia` keeps only lines mentioning NVIDIA, and `tail -n 15` shows the last 15 of them.

## Command quick reference

| Command | What it does |
| --- | --- |
| `lspci -k \| grep -iA3 nvidia` | Shows the GPU and the kernel driver in use |
| `mokutil --sb-state` | Prints whether Secure Boot is enabled |
| `sudo kmodgenca -a` | Creates the module signing key without prompts |
| `sudo mokutil --import <cert>` | Queues the public key to be enrolled as trusted |
| `sudo mokutil --test-key <cert>` | Checks whether the key is already enrolled |
| `sudo dnf install akmod-nvidia` | Installs the self-rebuilding NVIDIA driver |
| `modinfo -F version nvidia` | Prints the built driver version |
| `sudo dnf install xorg-x11-drv-nvidia-cuda` | Adds `nvidia-smi` and CUDA libraries |
| `nvidia-smi` | Shows GPU model, usage, memory and processes |
| `watch -n 1 nvidia-smi` | Live view refreshed every second |
| `switcherooctl launch <app>` | Runs an app on the GTX |
| `sudo dmesg \| grep -i nvidia \| tail -n 15` | Shows recent NVIDIA kernel messages for debugging |

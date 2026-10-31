# Deprecated
Use mControlCenter

# Limit Battery Charge on MSI GF63 Thin 11SC (Fedora)

This guide caps how far the battery charges, using the msi-ec kernel driver. Tested on this laptop: Fedora 44 KDE, kernel 7.2.13, Secure Boot on, EC firmware 16R6EMS1.107. Final setup: limit of 95%, reapplied at every boot.

## Variables you can change

Set these once at the top of your terminal. Every command below uses them, so this is the only block you edit. They live only in the current terminal window, so use the same window for all steps, or paste the block again in a new one.

```
LIMIT=95
BAT=BAT1
SERVICE=battery-limit
SIGN_KEY=/etc/pki/akmods/private/private_key.priv
SIGN_CERT=/etc/pki/akmods/certs/public_key.der
```

Each line creates a shell variable (NAME=value, with no spaces around the equals sign). Later commands refer to it as $NAME.

| Variable | Value used | What it controls |
| --- | --- | --- |
| LIMIT | 95 | Percentage where charging stops. The driver sets the restart point 10 points lower (95 stops at 95 and resumes at 85). Use 80 for longer battery life or 100 for no limit. |
| BAT | BAT1 | Battery name. Check yours with: ls /sys/class/power\_supply/ |
| SERVICE | battery-limit | Name of the systemd service that reapplies the limit at boot. Any name works. |
| SIGN\_KEY | /etc/pki/akmods/private/private\_key.priv | Private key that signs the driver for Secure Boot. It is the key your NVIDIA driver already uses. |
| SIGN\_CERT | /etc/pki/akmods/certs/public\_key.der | The matching public certificate. |

## Risks: what could go wrong

- **Unsupported firmware.** If your EC firmware is not on the driver's list, it refuses to load and does nothing. This is the safe failure.
- **Never force the driver.** The driver has an option that skips the firmware check. Do not use it. Writing to the wrong embedded controller address (the chip that manages battery, fans and keyboard) is the one genuinely dangerous path.
- **Secure Boot.** An unsigned module is rejected with the error Key was rejected by service. Step 7 fixes this.
- **Kernel updates.** DKMS rebuilds and signs the module on each update, but a rebuild can fail on a very new kernel. The battery then simply charges to 100% until the driver is updated.
- **Windows.** MSI Center in Windows can overwrite the limit.
- **Reversible.** Everything here can be undone. See the Undo section.

## Steps

### 1. Install the build tools

```
sudo dnf install -y git dkms kernel-devel kernel-headers make gcc
```

What it does: sudo runs it as admin. dnf is Fedora's package manager, install adds packages, and -y auto-answers yes. git downloads the driver source, dkms rebuilds the driver on every kernel update, kernel-devel and kernel-headers are the files needed to compile against your kernel, and make plus gcc are the build tools.

Expected output: ends with Complete! (or Nothing to do if they were already installed).

### 2. Check the kernel headers match your kernel

```
uname -r
rpm -q kernel-devel
```

What it does: uname -r prints the kernel you are running. rpm -q (query) lists the installed kernel-devel packages.

Expected output: the kernel-devel list includes your running version, for example 7.2.13-200.fc44.x86\_64. Older versions in the list are harmless. If yours is missing, reboot and run this step again.

### 3. Download the driver source

```
cd ~
git clone https://github.com/BeardOverflow/msi-ec.git
cd msi-ec
```

What it does: cd \~ goes to your home folder, git clone downloads the project into a new folder called msi-ec, and the last cd enters it.

Expected output: Cloning into 'msi-ec'... and Receiving objects: 100%.

### 4. Build and install with DKMS

```
sudo make dkms-install
```

What it does: make reads the project's Makefile, and dkms-install registers the source with DKMS, compiles the module for your kernel and installs it so it is rebuilt after kernel updates.

Expected output: ends with Executing post-transaction command... done, plus a line writing /etc/modules-load.d/msi-ec.conf, which makes the driver load at every boot.

### 5. Check Secure Boot

```
mokutil --sb-state
```

What it does: mokutil manages Secure Boot keys, and --sb-state reports whether Secure Boot is on.

Expected output: SecureBoot enabled.

### 6. First load attempt (expected to fail with Secure Boot on)

```
sudo modprobe msi-ec
```

What it does: modprobe loads a kernel module by name.

Expected output with Secure Boot on: modprobe: ERROR: could not insert 'msi\_ec': Key was rejected by service. This is harmless, nothing was changed. If it prints nothing, the driver loaded and you can skip to step 8.

### 7. Sign the driver with your existing NVIDIA key

First confirm the key files exist:

```
sudo ls "$SIGN_CERT" "$SIGN_KEY"
```

What it does: sudo is needed because the private key folder is admin-only, and ls lists the two files you name. Expected output: both paths printed back.

Then tell DKMS to sign with them. Run this only once:

```
sudo tee -a /etc/dkms/framework.conf <<EOF
mok_signing_key="$SIGN_KEY"
mok_certificate="$SIGN_CERT"
EOF
```

What it does: tee -a appends text to a file (-a means append, so nothing is erased) and sudo lets it write to the protected config. The <\<EOF part feeds in the lines up to the closing EOF, and because EOF has no quotes, the shell fills in your variables. Expected output: the two lines printed back.

Then rebuild so the module gets signed:

```
cd ~/msi-ec
sudo make dkms-uninstall
sudo make dkms-install
```

What it does: dkms-uninstall removes the unsigned build and dkms-install builds it again, this time signed. Expected output: ends with Running depmod.... done.

### 8. Load the driver and verify

```
sudo modprobe msi-ec
ls /sys/class/power_supply/$BAT/ | grep threshold
```

What it does: modprobe loads the driver. ls lists the battery files, the | passes that list to grep, and grep threshold keeps only lines containing that word.

Expected output: no error from modprobe, then both charge\_control\_end\_threshold and charge\_control\_start\_threshold. You can also run ls /sys/devices/platform/msi-ec/ to see the driver's other files, such as fan\_mode and cooler\_boost.

If you see Firmware version is not supported, stop. Do not force anything.

### 9. Set the limit now

```
echo $LIMIT | sudo tee /sys/class/power_supply/$BAT/charge_control_end_threshold
cat /sys/class/power_supply/$BAT/charge_control_end_threshold
cat /sys/class/power_supply/$BAT/charge_control_start_threshold
```

What it does: echo prints the number, the | passes it to tee, which writes it into the threshold file (sudo goes on tee because a plain sudo echo with a redirect would write without admin rights and fail). cat prints a file's contents.

Expected output: the end value equals LIMIT, and the start value is 10 lower. The two numbers are not supposed to match: end is where charging stops, start is where it resumes.

### 10. Make it survive reboots

```
sudo tee /etc/systemd/system/$SERVICE.service <<EOF
[Unit]
Description=Set battery charge limit
After=systemd-modules-load.service

[Service]
Type=oneshot
ExecStart=/bin/sh -c 'echo $LIMIT > /sys/class/power_supply/$BAT/charge_control_end_threshold'

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable --now $SERVICE.service
systemctl status $SERVICE.service
```

What it does: tee writes the service file, and the unquoted EOF lets the shell fill in LIMIT and BAT. After=systemd-modules-load.service makes it wait until the driver has loaded, Type=oneshot means it runs once and exits, ExecStart is the command that writes the limit, and WantedBy=multi-user.target runs it at every boot. daemon-reload makes systemd re-read its files, enable makes it start at boot, and --now also starts it immediately. systemctl status shows the result.

Expected output: a line like Created symlink ... battery-limit.service. For this kind of service, Active: inactive (dead) with status=0/SUCCESS is correct.

### 11. Final test

Reboot, then run:

```
cat /sys/class/power_supply/$BAT/charge_control_end_threshold
```

Expected output: the value of LIMIT.

## Change the limit later

Set a new value and apply it now:

```
LIMIT=80
echo $LIMIT | sudo tee /sys/class/power_supply/$BAT/charge_control_end_threshold
```

To keep it after reboots, run the service file command from step 10 again (it overwrites the old file with the new value), then:

```
sudo systemctl daemon-reload
sudo systemctl restart $SERVICE.service
```

What it does: restart runs the service again right now, so you do not have to reboot.

## Undo

Quick undo (keeps the driver installed, charging goes back to 100%):

```
echo 100 | sudo tee /sys/class/power_supply/$BAT/charge_control_end_threshold
sudo systemctl disable --now $SERVICE.service
```

What it does: the first line sets the limit back to 100. disable removes the service from startup, and --now also stops it immediately.

Full removal (also removes the service and the driver):

```
sudo rm /etc/systemd/system/$SERVICE.service
sudo systemctl daemon-reload
cd ~/msi-ec && sudo make dkms-uninstall
sudo rm -f /etc/modules-load.d/msi-ec.conf
```

What it does: rm deletes the service file, daemon-reload makes systemd forget it, dkms-uninstall removes the driver, and rm -f deletes the auto-load file (-f means no error if it is already gone). Reboot afterward and the laptop is back to stock behaviour.

Optional: the two signing lines in /etc/dkms/framework.conf can stay, they are harmless. Remove them by hand with sudo nano only if you no longer want DKMS to sign modules.

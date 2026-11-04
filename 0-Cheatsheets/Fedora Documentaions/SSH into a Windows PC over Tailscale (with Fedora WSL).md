# SSH into a Windows PC over Tailscale (with Fedora WSL)

From a Fedora laptop into the Windows PC, passwordless, landing in a Fedora WSL bash.

**Names used here**

- Windows PC name: `BLUE`
- Windows user: `moham` (from `whoami` → `blue\moham`)
- WSL distro and user: `FedoraLinux-44`, user `blue`
- Both machines run Tailscale

## 1. Enable the SSH server on Windows

Administrator PowerShell on the PC:

```powershell
Add-WindowsCapability -Online -Name OpenSSH.Server~~~~0.0.1.0
Start-Service sshd
Set-Service -Name sshd -StartupType Automatic
Get-NetFirewallRule -Name *ssh*
```

If no firewall rule appears:

```powershell
New-NetFirewallRule -Name sshd -DisplayName "OpenSSH Server" -Enabled True -Direction Inbound -Protocol TCP -Action Allow -LocalPort 22
```

## 2. Find the Tailscale name or IP

On the laptop:

```bash
tailscale status
```

Use the PC's name or its `100.x.y.z` address. The Tailscale name comes from the Windows computer name (`BLUE`), not the Windows username. The IP is the most reliable option.

```bash
ssh moham@100.x.y.z
```

## 3. Passwordless login (keys)

On the laptop:

```bash
ssh-keygen -t ed25519
cat ~/.ssh/id_ed25519.pub
```

On the PC, check whether the account is an administrator:

```powershell
net localgroup administrators
```

**Administrator account** (Administrator PowerShell):

```powershell
Add-Content -Force -Path "C:\ProgramData\ssh\administrators_authorized_keys" -Value 'ssh-ed25519 AAAA...your-key...'
icacls "C:\ProgramData\ssh\administrators_authorized_keys" /inheritance:r /grant "Administrators:F" /grant "SYSTEM:F"
```

**Standard account:**

```powershell
mkdir $env:USERPROFILE\.ssh -Force
Add-Content -Force -Path "$env:USERPROFILE\.ssh\authorized_keys" -Value 'ssh-ed25519 AAAA...your-key...'
```

Keep the key on one line, in single quotes. Test with `ssh moham@<name-or-ip>`. If it still asks for a password, run `ssh -v` to see why.

Once keys work, you can set `PasswordAuthentication no` in `C:\ProgramData\ssh\sshd_config` and run `Restart-Service sshd`. Keep one session open while testing so you can't lock yourself out.

## 4. Install WSL Fedora

Do this at the PC (or over Remote Desktop), in an Administrator PowerShell. Installing over SSH often fails because of elevation, reboots and the interactive first-run user setup.

```powershell
wsl --list --online
wsl --install FedoraLinux-44
```

Use the exact name from the list. Reboot if asked, launch the distro once to create your Linux user, then verify:

```powershell
wsl -l -v
```

## 5. Choose how SSH reaches bash

### Option A (recommended): two shortcuts, no registry change

Put this in `~/.ssh/config` on the **laptop**. `User` is the Windows account, not the WSL user.

```
Host moham
    HostName 100.x.y.z
    User moham

Host moham-wsl
    HostName 100.x.y.z
    User moham
    RequestTTY yes
    RemoteCommand wsl
```

- `ssh moham` gives the normal Windows shell. `scp` and `sftp` work.
- `ssh moham-wsl` drops you into Fedora WSL as `blue`. TUIs like opencode render correctly.

If the shell breaks, it can't lock you out of the machine.

### Option B: make a bash the default shell for every login

Administrator PowerShell on the PC. The path must exist and be machine-wide, because sshd runs as SYSTEM:

```powershell
# Git Bash (here Git is installed on D:)
New-ItemProperty -Path "HKLM:\SOFTWARE\OpenSSH" -Name DefaultShell -Value "D:\Program Files\Git\bin\bash.exe" -PropertyType String -Force

# Fedora WSL launcher
New-ItemProperty -Path "HKLM:\SOFTWARE\OpenSSH" -Name DefaultShell -Value "C:\Windows\System32\wsl.exe" -PropertyType String -Force
```

With `wsl.exe` as the default, `scp`, `sftp` and some remote tools can fail. If that happens, revert and use Option A.

**Revert:**

```powershell
Remove-ItemProperty -Path "HKLM:\SOFTWARE\OpenSSH" -Name DefaultShell
```

No service restart is needed. New sessions pick up changes immediately.

## Troubleshooting

| Symptom | Cause and fix |
| --- | --- |
| Logs in, then drops instantly | The default shell path doesn't exist or can't run as SYSTEM. Check it with `Test-Path`, or revert the registry value. |
| `Could not resolve hostname` | Wrong name, or MagicDNS is off. Use the `100.x.y.z` IP from `tailscale status`. |
| Connection timed out | Check `tailscale status` on both sides. Make sure the PC isn't asleep. |
| Connection refused | `sshd` isn't running: `Start-Service sshd`. |
| Still asks for a password | Wrong key file for an admin account (use `administrators_authorized_keys`), bad permissions, or the key split over two lines. Run `ssh -v`. |
| `bash.exe` not recognized | Not present on your system. Use `wsl.exe` (or Git Bash) instead. |

## Rules that avoid lockouts

- Confirm a shell path exists with `Test-Path` before putting it in the registry.
- Never point the default shell at a path inside a user profile or the `WindowsApps` stub.
- Keep one SSH session open while you test a change from a second terminal.
- Know your fallback: physical access, or Remote Desktop over the Tailscale IP.

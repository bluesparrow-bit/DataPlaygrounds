# scp and sftp cheatsheet

Examples use the `moham` host from `~/.ssh/config` (Windows account `moham` on the PC). Relative remote paths start in `C:\Users\moham`.

## scp: one-shot copy

Syntax: `scp [options] source destination`. A remote side is written `host:path`.

### Common examples

```bash
# laptop -> PC (lands in C:\Users\moham)
scp notes.txt moham:

# laptop -> a folder on the PC
scp notes.txt moham:Documents/

# PC -> laptop (into the current folder)
scp moham:Documents/report.pdf .

# a whole folder, both directions
scp -r Work moham:
scp -r moham:Projects/site ~/Downloads/

# several files at once
scp a.txt b.txt c.txt moham:Desktop/

# wildcards on the local side (shell expands them)
scp *.pdf moham:Documents/

# wildcards on the remote side: quote them so the remote handles them
scp 'moham:Documents/*.pdf' .
```

### Paths on Windows

| Goal | Path form |
| --- | --- |
| Home folder | `moham:file.txt` or `moham:Desktop/file.txt` |
| Another drive | `moham:/D:/Work/` |
| Absolute on C: | `moham:/C:/Users/moham/Desktop/` |
| Name with spaces | `scp 'moham:My Files/a.txt' .` |

Use forward slashes. Quote any path with spaces or wildcards.

### Useful options

| Option | Meaning |
| --- | --- |
| `-r` | Copy folders recursively |
| `-p` | Keep timestamps and modes |
| `-C` | Compress in transit (helps on text, not on PDFs or images) |
| `-P 2222` | Remote port (capital P, unlike `ssh -p`) |
| `-i ~/.ssh/key` | Use a specific key |
| `-v` | Verbose output for debugging |
| `-l 8000` | Limit bandwidth in Kbit/s |
| `-3` | Copy between two remote hosts through the laptop |

### Good to know

- Current OpenSSH `scp` uses the SFTP protocol under the hood, so it works even when the PC's default SSH shell is Git Bash or `wsl.exe`.
- `scp` can't resume an interrupted transfer, and re-running a folder copy re-sends everything. For big or flaky transfers, use `sftp` with `reget` and `reput`.
- It overwrites existing files without asking.

## sftp: interactive session

```bash
sftp moham              # open a session
sftp moham:Documents    # open directly in a folder
sftp -P 2222 moham      # non-default port
```

The prompt is `sftp>`. Local commands start with `l`.

### Navigation

| Command | Does |
| --- | --- |
| `pwd` / `lpwd` | Show remote / local folder |
| `ls` / `lls` | List remote / local files |
| `cd dir` / `lcd dir` | Change remote / local folder |
| `!ls` | Run a local shell command (`!` alone opens a local shell) |

### Transfer

```
get file.txt                 # download to the local folder
get file.txt ~/Downloads/    # download to a chosen place
get -r Projects              # download a folder
get -a bigfile.iso           # resume a partial download
reget bigfile.iso            # same idea: resume a download

put file.txt                 # upload from the local folder
put -r Work                  # upload a folder
reput bigfile.iso            # resume an upload

mget *.pdf                   # several downloads
mput *.png                   # several uploads
```

### Manage remote files

```
mkdir newfolder
rmdir newfolder      # must be empty
rm old.txt
rename old.txt new.txt
df -h                # free space
bye                  # quit (also: exit, quit, Ctrl+D)
```

`chmod` and `chown` have little effect on Windows.

### Scripted transfers

```bash
# run a list of commands without interaction
sftp -b commands.txt moham

# commands.txt
cd Documents
lcd ~/Work
put *.pdf
bye
```

## Reaching files inside WSL

Because `moham` logs into the Windows side, `scp` doesn't see the WSL home (`/home/blue`). Pick one:

```bash
# 1. Copy through the Windows side, then move it inside WSL
scp file.txt moham:Desktop/
# in WSL: cp /mnt/c/Users/moham/Desktop/file.txt ~

# 2. Pipe a single file straight into WSL
ssh moham 'wsl -e sh -c "cat > ~/file.txt"' < file.txt

# 3. Pull a single file out of WSL
ssh moham 'wsl -e cat ~/file.txt' > file.txt

# 4. A folder through tar
tar czf - Work | ssh moham 'wsl -e tar xzf - -C ~'
```

## Troubleshooting

| Symptom | Likely cause and fix |
| --- | --- |
| `Connection timed out` | Using a LAN name that doesn't resolve everywhere. Put the Tailscale `100.x.y.z` IP in `HostName`. |
| `local stat ...: No such file or directory` | Dangling symlink or a file that changed during the copy. Find links with `find Work -xtype l`. |
| `No such file or directory` on the remote side | Wrong path form. Use forward slashes and `/D:/...` for other drives. |
| `Permission denied (publickey)` | Key not installed for that account. See the SSH setup guide. |
| Asked for a password on every copy | Key auth isn't working. Run `scp -v` to see which keys are offered. |
| Copy stops partway on a big file | Use `sftp` and `reget`/`reput` to resume. |

# Complete GCP Cloud Development Environment Guide
### MacBook Air M2 → Terminal → SSH → GCP Ubuntu VM → tmux → Neovim → Git → Python/AI/Data Science

**Who this is for:** Absolute beginners who want a professional cloud dev setup.
**What you'll build:** A full remote Ubuntu machine on Google's servers, accessible from your Mac in seconds.

---

## TABLE OF CONTENTS

1. [Understanding the Big Picture](#1-understanding-the-big-picture)
2. [GCP Account and Project Setup](#2-gcp-account-and-project-setup)
3. [Enable Compute Engine and Create Ubuntu VM](#3-enable-compute-engine-and-create-ubuntu-vm)
4. [Firewall and Networking](#4-firewall-and-networking)
5. [SSH Keys: What They Are and How to Generate Them](#5-ssh-keys-what-they-are-and-how-to-generate-them)
6. [Add SSH Keys to GCP and Connect](#6-add-ssh-keys-to-gcp-and-connect)
7. [SSH Config: Connect with `ssh gcp`](#7-ssh-config-connect-with-ssh-gcp)
8. [Ubuntu Folder Structure Explained](#8-ubuntu-folder-structure-explained)
9. [Essential Linux Commands (with Explanations)](#9-essential-linux-commands-with-explanations)
10. [File Operations: Create, Edit, Copy, Move, Delete](#10-file-operations-create-edit-copy-move-delete)
11. [Vim and Neovim: Complete Beginner Guide](#11-vim-and-neovim-complete-beginner-guide)
12. [Installing Everything: Vim, Neovim, Git, Python, tmux, Node.js](#12-installing-everything)
13. [Neovim Configuration for Python Development](#13-neovim-configuration-for-python-development)
14. [Git Setup and GitHub with SSH](#14-git-setup-and-github-with-ssh)
15. [tmux: Sessions, Windows, Panes, Shortcuts](#15-tmux-sessions-windows-panes-shortcuts)
16. [Running Python Programs](#16-running-python-programs)
17. [Your Complete Workflow](#17-your-complete-workflow)
18. [Troubleshooting SSH Failures](#18-troubleshooting-ssh-failures)
19. [Common Beginner Mistakes](#19-common-beginner-mistakes)
20. [Master Cheat Sheet](#20-master-cheat-sheet)

---

## 1. Understanding the Big Picture

Before touching a single command, understand *what* you're building and *why*.

### What is GCP?
Google Cloud Platform (GCP) is a collection of cloud computing services run by Google. You're renting a computer (called a **Virtual Machine** or **VM**) that lives in Google's data center. This VM runs 24/7, has a fast internet connection, and you control it entirely from your MacBook.

### Why a cloud VM instead of just using your Mac?
- Your Mac has limited RAM and storage for large AI/ML workloads
- The VM can run while your Mac is off or in a bag
- You can access it from anywhere
- It uses Linux (Ubuntu), which is the standard for data science, DevOps, and software engineering

### The Workflow You're Building

```
Your MacBook Air M2
        │
        ▼
   Mac Terminal (your command interface)
        │
        ▼ (SSH — an encrypted tunnel)
   GCP Ubuntu VM (a Linux computer in Google's data center)
        │
        ▼
   tmux (a terminal multiplexer — run many sessions at once)
        │
        ▼
   Neovim (a powerful code editor that runs in the terminal)
        │
        ▼
   Git (version control — tracks changes to your code)
        │
        ▼
   Python / AI / Data Science projects
```

**Think of it like this:** Your Mac is a TV remote. The GCP VM is the actual TV. SSH is the signal between them.

### What is SSH?
SSH stands for **Secure Shell**. It's a protocol (a set of rules) that lets you securely log into another computer over the internet. Instead of a password (which can be stolen), SSH uses a pair of cryptographic keys — like a physical lock and key:

- **Private key** → stays on YOUR Mac, NEVER share this
- **Public key** → goes on the GCP VM, like a padlock

When you connect, your Mac says "I have the key" and the VM checks "does it match my lock?" — if yes, you're in.

---

## 2. GCP Account and Project Setup

### Step 2.1: Create a Google Account (if you don't have one)

Go to [accounts.google.com](https://accounts.google.com) and create an account. If you already have a Gmail, you already have one.

### Step 2.2: Sign Up for Google Cloud Platform

1. Open your browser and go to: **[cloud.google.com](https://cloud.google.com)**
2. Click the blue **"Get started for free"** button in the top right
3. Sign in with your Google account
4. You'll need to enter a **credit card** — Google requires this for identity verification
   - ⚠️ **Don't worry:** Google gives you **$300 in free credits** for 90 days
   - You will NOT be charged unless you manually upgrade to a paid account
   - The free tier also includes an **always-free** e2-micro VM (1 vCPU, 1 GB RAM)
5. Fill in your country, accept the terms, and complete billing setup

### Step 2.3: The GCP Console

After signing up, you'll land on the **Google Cloud Console** — think of it as a dashboard for all your cloud resources.

**What you're looking at:**
- Top bar: your project name, search bar, and your account
- Left sidebar: navigation to all GCP services
- Main area: overview of your project

### Step 2.4: Create a New Project

A **Project** in GCP is a container for all your resources. It's like a folder that holds your VMs, databases, storage, etc.

1. In the top bar, click on the **project dropdown** (it probably says "My First Project" or has a project name)
2. Click **"New Project"** in the popup
3. Give it a name: `cloud-dev` (or anything you like — no spaces, use hyphens)
4. Leave **Organization** as "No organization" (for personal use)
5. Click **"Create"**
6. Wait 10–30 seconds, then select your new project from the dropdown

> 💡 **GCP Project IDs** are globally unique. GCP may append numbers to your name (like `cloud-dev-123456`). The Project ID is what actually identifies your project.

---

## 3. Enable Compute Engine and Create Ubuntu VM

### Step 3.1: Enable Compute Engine API

Before creating VMs, you must enable the **Compute Engine API** — this activates the service.

1. In the left sidebar, scroll down and click **"Compute Engine"**
   - Or use the search bar at the top: type "Compute Engine"
2. Click **"Enable"** and wait 1–2 minutes
3. You'll see the Compute Engine dashboard when it's ready

### Step 3.2: Create a VM Instance

A **VM Instance** is your actual virtual computer.

1. In the Compute Engine page, click **"Create Instance"** (or the `+` button)
2. Fill in these settings:

**Name:** `dev-vm` (no caps, no spaces)

**Region and Zone:**
- Choose a region close to you for lower latency
- For India: `asia-south1` (Mumbai) or `asia-south2` (Delhi)
- Zone: `asia-south1-a`

**Machine Configuration:**
- Series: **E2**
- Machine type: **e2-medium** (2 vCPUs, 4 GB RAM — good for development)
- ⚠️ If you want to stay on the always-free tier: choose **e2-micro** (1 vCPU, 1 GB RAM) — but it's quite slow for Python/AI work

**Boot Disk (Operating System):**
1. Click **"Change"** under Boot disk
2. Select **Operating System:** `Ubuntu`
3. Select **Version:** `Ubuntu 24.04 LTS` (LTS = Long Term Support, more stable)
4. Boot disk type: **Standard persistent disk** (cheaper) or **SSD persistent disk** (faster)
5. Size: **20 GB** (minimum) — increase to 30–50 GB if you plan to work with datasets
6. Click **"Select"**

**Firewall:**
- ✅ Check **"Allow HTTP traffic"**
- ✅ Check **"Allow HTTPS traffic"**

> 💡 **What is LTS?** Long Term Support means Ubuntu will receive security updates for 5 years (until 2029). Always use LTS versions for servers — they're more stable than bleeding-edge releases.

3. Leave everything else as default
4. Click **"Create"** at the bottom

**Wait 1–2 minutes.** You'll see your VM appear in the list with a green circle (✅) when it's running.

### Step 3.3: Note Your VM's External IP

On the Compute Engine → VM Instances page, you'll see a column called **"External IP"**. It looks like: `34.100.XXX.XXX`

Write this down — you'll need it to connect via SSH.

> ⚠️ **Common beginner mistake:** By default, external IPs are **ephemeral** — they change every time you stop and restart the VM. For a stable IP, you'd need a **Static IP** (costs ~$0.01/hour when VM is off). For now, the ephemeral IP is fine while you're learning.

---

## 4. Firewall and Networking

### What is a Firewall?

A firewall is a set of rules that controls what network traffic is allowed in and out of your VM. Think of it like a bouncer at a door — it checks every connection and decides whether to let it through.

### Understanding Ports

Every network service runs on a **port** — a numbered channel. Like how a building has one address but many apartment numbers:
- Port 22 → SSH (how you connect to your VM)
- Port 80 → HTTP (websites)
- Port 443 → HTTPS (secure websites)
- Port 8888 → Jupyter Notebooks (data science)

### Step 4.1: Verify SSH is Allowed (Port 22)

GCP automatically allows SSH (port 22) by default. Let's verify:

1. In GCP Console, go to **"VPC Network"** → **"Firewall"** (use the search bar)
2. Look for a rule called `default-allow-ssh`
3. It should show: TCP, port 22, allowed for all IPs (0.0.0.0/0)

If it doesn't exist, create it:
1. Click **"Create Firewall Rule"**
2. Name: `allow-ssh`
3. Direction: Ingress
4. Action: Allow
5. Targets: All instances in the network
6. Source IP ranges: `0.0.0.0/0`
7. Protocols and ports: TCP, port `22`
8. Click **"Create"**

### Step 4.2: Optional — Allow Jupyter Notebook Port

If you plan to run Jupyter Notebooks later:

1. Create another firewall rule
2. Name: `allow-jupyter`
3. Same settings as above, but port `8888`

---

## 5. SSH Keys: What They Are and How to Generate Them

### What is a Key Pair?

Imagine you have a diary with a special lock. You give your friend a copy of the lock (public key), but you keep the key itself (private key). Your friend can lock things using your lock, but only you can open them.

SSH uses the same idea:
- **Private key** (`~/.ssh/id_ed25519`) — stays on your Mac, never leave this computer
- **Public key** (`~/.ssh/id_ed25519.pub`) — goes on the VM, safe to share

### Step 5.1: Open Terminal on Your Mac

Press `Cmd + Space`, type `Terminal`, press Enter.

You'll see something like:
```
arslan@MacBook-Air ~ %
```

This is the **shell prompt**. Everything before `%` tells you: your username, your computer name, and your current directory (`~` means your home folder).

### Step 5.2: Check if You Already Have SSH Keys

```bash
ls ~/.ssh
```

**What this command does:**
- `ls` → **list** files and folders
- `~/.ssh` → the `.ssh` folder inside your home directory (`~` is a shortcut for `/Users/yourname`)

**If you see** `id_ed25519` and `id_ed25519.pub` → you already have keys (skip to Step 5.4)
**If you see** "No such file or directory" → you need to generate keys (continue)

### Step 5.3: Generate SSH Keys

```bash
ssh-keygen -t ed25519 -C "your_email@gmail.com"
```

**What each part means:**
- `ssh-keygen` → the program that generates SSH keys
- `-t ed25519` → the **type** of key (Ed25519 is modern and secure — better than the older RSA type)
- `-C "your_email@gmail.com"` → a **comment** attached to the key (helps you identify it; replace with your actual email)

**What happens next (follow each prompt):**

```
Enter file in which to save the key (/Users/arslan/.ssh/id_ed25519):
```
→ Press **Enter** to accept the default location

```
Enter passphrase (empty for no passphrase):
```
→ You can press **Enter** for no passphrase (easier for development), or type a password for extra security

```
Enter same passphrase again:
```
→ Press **Enter** again (or re-type your passphrase)

You'll see something like:
```
Your identification has been saved in /Users/arslan/.ssh/id_ed25519
Your public key has been saved in /Users/arslan/.ssh/id_ed25519.pub
The key fingerprint is:
SHA256:xxxxxxxxxxxxxxxxxxxxxxxx your_email@gmail.com
```

### Step 5.4: View Your Public Key

```bash
cat ~/.ssh/id_ed25519.pub
```

**What this command does:**
- `cat` → **concatenate** — prints the contents of a file to the screen
- `~/.ssh/id_ed25519.pub` → the path to your public key file

You'll see one long line starting with `ssh-ed25519` and ending with your email. **Copy this entire line** — you'll need it in the next step.

> ⚠️ **NEVER share `id_ed25519` (without .pub).** Only ever share `id_ed25519.pub`. The private key is like your password — sharing it gives someone full access to every server you've added your key to.

---

## 6. Add SSH Keys to GCP and Connect

### Step 6.1: Add Your Public Key to the VM

**Method 1: GCP Console (Recommended for beginners)**

1. Go to **Compute Engine** → **VM Instances**
2. Click your VM name (`dev-vm`)
3. Click **"Edit"** at the top
4. Scroll down to **"SSH Keys"**
5. Click **"Add item"**
6. Paste your entire public key (the long line from Step 5.4)
7. Click **"Save"** at the bottom

GCP will automatically:
- Create a user account on the VM with your Mac username
- Add your public key to `~/.ssh/authorized_keys` on the VM

**What is `authorized_keys`?**
It's a file on the VM that lists all public keys allowed to log in. When you connect, SSH checks if your private key matches any entry in this file.

### Step 6.2: Find Your VM's External IP

Go to **Compute Engine** → **VM Instances** and find the **External IP** column. Copy that IP address.

### Step 6.3: Connect to Your VM via SSH

Back in your Mac Terminal:

```bash
ssh -i ~/.ssh/id_ed25519 your_username@YOUR_VM_IP
```

**Replace:**
- `your_username` → your Mac username (run `whoami` on your Mac to see it)
- `YOUR_VM_IP` → the external IP from GCP (e.g., `34.100.123.456`)

**What each part means:**
- `ssh` → the SSH client program
- `-i ~/.ssh/id_ed25519` → **identity file** — which private key to use
- `your_username@YOUR_VM_IP` → username at hostname (like an email address format)

**First connection prompt:**
```
The authenticity of host '34.100.123.456' can't be established.
ED25519 key fingerprint is SHA256:xxxxxxxx.
Are you sure you want to continue connecting (yes/no/[fingerprint])?
```

Type `yes` and press Enter. This adds the VM to your list of "known hosts" — you won't be asked again for this server.

**Success looks like:**
```
Welcome to Ubuntu 24.04 LTS (GNU/Linux 6.8.0-1009-gcp x86_64)
...
your_username@dev-vm:~$
```

🎉 **You are now inside your GCP Ubuntu VM!** Everything you type now runs on the VM in Google's data center, not your Mac.

To return to your Mac, type:
```bash
exit
```

---

## 7. SSH Config: Connect with `ssh gcp`

Typing `ssh -i ~/.ssh/id_ed25519 your_username@34.100.123.456` every time is painful. The SSH config file lets you create short aliases.

### What is `~/.ssh/config`?

This is a configuration file that stores SSH connection settings. It's like a contacts book — instead of dialing a full phone number, you just say a name.

**File location:** `/Users/yourname/.ssh/config` (or `~/.ssh/config`)

### Step 7.1: Create the SSH Config File

On your **Mac** (not the VM), run:

```bash
touch ~/.ssh/config
```

**What `touch` does:** Creates an empty file if it doesn't exist. If the file already exists, it just updates the timestamp — safe to run.

Set correct permissions:

```bash
chmod 600 ~/.ssh/config
```

**What `chmod 600` means:**
- `chmod` → **change mode** (change file permissions)
- `600` → owner can read and write, nobody else can do anything
- SSH requires strict permissions on config files — it will refuse to use them if they're too open

### Step 7.2: Edit the Config File

```bash
nano ~/.ssh/config
```

**What `nano` is:** A simple terminal text editor, friendlier than Vim for beginners. Navigation is with arrow keys.

Type this (replace the values in angle brackets):

```
Host gcp
    HostName YOUR_VM_IP
    User YOUR_USERNAME
    IdentityFile ~/.ssh/id_ed25519
    ServerAliveInterval 60
    ServerAliveCountMax 3
```

**What each line means:**
- `Host gcp` → the alias you'll type (you can name this anything: `gcp`, `vm`, `cloud`, etc.)
- `HostName YOUR_VM_IP` → the actual IP address of your VM (e.g., `34.100.123.456`)
- `User YOUR_USERNAME` → your username on the VM
- `IdentityFile ~/.ssh/id_ed25519` → which SSH key to use
- `ServerAliveInterval 60` → send a "keep alive" ping every 60 seconds (prevents disconnection)
- `ServerAliveCountMax 3` → try 3 times before giving up

Save and exit nano:
- Press `Ctrl + X` to exit
- Press `Y` to confirm save
- Press `Enter` to keep the filename

### Step 7.3: Connect with the Alias

```bash
ssh gcp
```

That's it. You're connected. 🎉

> 💡 **Pro tip:** If your IP changes (because you restarted the VM), just update the `HostName` line in `~/.ssh/config`.

---

## 8. Ubuntu Folder Structure Explained

When you log into Ubuntu, you're placed in your **home directory**. Let's explore the file system.

### The Linux File System Tree

In Linux, everything starts from `/` (called the **root** directory). It's like the trunk of a tree — all folders branch off from it.

```
/
├── bin/        → Essential command binaries (ls, cp, mv, etc.)
├── boot/       → Files needed to boot the system
├── dev/        → Device files (hard drives, USB, etc.)
├── etc/        → System configuration files
│   ├── apt/            → Package manager settings
│   ├── ssh/            → SSH server configuration
│   └── hostname        → Your system's name
├── home/       → User home directories
│   └── your_username/  → YOUR personal folder (you spend most time here)
│       ├── .bashrc     → Shell configuration (runs when bash starts)
│       ├── .zshrc      → Zsh shell configuration
│       ├── .ssh/       → SSH keys and config
│       └── projects/   → Where you'll keep your code
├── lib/        → Libraries needed by programs
├── opt/        → Optional/third-party software
├── proc/       → Virtual filesystem — info about running processes
├── root/       → Home directory for the "root" (admin) user
├── tmp/        → Temporary files (deleted on reboot)
├── usr/        → User-installed programs and data
│   ├── bin/    → Installed commands (python3, git, etc.)
│   ├── local/  → Locally compiled software
│   └── share/  → Shared data, man pages
└── var/        → Variable data — logs, databases, mail
    └── log/    → System log files
```

### The Most Important Directories for You

| Path | What it is | When you use it |
|------|------------|-----------------|
| `~` or `/home/yourname` | Your home folder | Always — it's your workspace |
| `~/.ssh/` | SSH keys and config | SSH setup |
| `~/.config/nvim/` | Neovim config | Setting up your editor |
| `/etc/` | System configuration | System-wide settings |
| `/tmp/` | Temp files | Quick throwaway files |
| `/usr/bin/` | Installed programs | Checking if something is installed |
| `/var/log/` | Log files | Debugging problems |

### Important Hidden Files in Your Home Directory

Files starting with `.` (dot) are **hidden files** — they don't show up with a plain `ls` command. You need `ls -a` to see them.

**`~/.bashrc`**
This file runs every time you open a new **bash** terminal session. It's where you:
- Set environment variables (`export PATH=...`)
- Create command aliases (`alias ll='ls -la'`)
- Customize your prompt
- Load tools like conda, nvm, etc.

**`~/.zshrc`**
Same as `.bashrc` but for the **Zsh** shell. Ubuntu 24.04 defaults to bash; macOS defaults to zsh. If you switch to zsh on Ubuntu, you'd edit this file instead.

**`~/.bashrc` vs `~/.bash_profile`:**
- `.bashrc` → runs for **interactive non-login** shells (opening a new terminal window)
- `.bash_profile` → runs for **login shells** (SSH sessions)
- Best practice: put everything in `.bashrc` and have `.bash_profile` source it with: `source ~/.bashrc`

**`~/.ssh/config`**
Stores SSH connection aliases (as you set up in Section 7)

**`~/.gitconfig`**
Stores your Git identity (name, email) and preferences

---

## 9. Essential Linux Commands (with Explanations)

These are the commands you'll use every single day. Learn these well.

### Navigation

```bash
pwd
```
**Print Working Directory** — shows your current location.
Example output: `/home/arslan`

```bash
ls
```
**List** — shows files and folders in the current directory.

```bash
ls -l
```
`-l` flag → **long format** — shows permissions, owner, size, date, and name.
```
-rw-r--r-- 1 arslan arslan  2048 Jun 10 14:30 notes.txt
```
Reading this: `[permissions] [links] [owner] [group] [size in bytes] [date] [filename]`

```bash
ls -la
```
`-l` = long format, `-a` = **all** (show hidden files starting with `.`)

```bash
cd Documents
```
**Change Directory** — move into the `Documents` folder.

```bash
cd ..
```
Go **up one level** (to the parent directory). `..` always means "one level up".

```bash
cd ~
```
Go to your **home directory** (no matter where you are).

```bash
cd /
```
Go to the **root directory** (top of the whole filesystem).

```bash
cd -
```
Go to the **previous directory** (like the Back button).

### Viewing Files

```bash
cat filename.txt
```
**Concatenate/Print** — shows the entire file contents at once. Good for short files.

```bash
less filename.txt
```
**Paginated view** — shows the file one screen at a time.
- Press `Space` to go forward a page
- Press `b` to go back
- Press `q` to quit
- Press `/` then type to search within the file

```bash
head filename.txt
```
Shows the **first 10 lines** of a file.

```bash
head -n 20 filename.txt
```
Shows the first **20 lines** (`-n` specifies the number).

```bash
tail filename.txt
```
Shows the **last 10 lines**.

```bash
tail -f log.txt
```
`-f` = **follow** — keeps watching a file and prints new lines as they appear. Great for log files.

### Creating Directories

```bash
mkdir projects
```
**Make Directory** — creates a new folder named `projects`.

```bash
mkdir -p projects/python/first-script
```
`-p` = **parents** — creates all intermediate directories at once. Without `-p`, you'd have to create each folder one by one.

### Knowing Where Programs Are

```bash
which python3
```
Shows the **full path** of a command. Example: `/usr/bin/python3`
Useful for confirming something is installed.

```bash
which git
```
Same — confirms git is installed.

### Getting Help

```bash
man ls
```
**Manual** — opens the full documentation for the `ls` command. Press `q` to quit.

```bash
ls --help
```
Most commands support `--help` for a quick summary of options.

### System Information

```bash
whoami
```
Prints your current username.

```bash
hostname
```
Prints the computer's name (e.g., `dev-vm`).

```bash
uname -a
```
Shows system information: kernel version, architecture, OS name.

```bash
df -h
```
**Disk Free, Human-readable** — shows disk usage. `-h` makes sizes readable (GB instead of bytes).

```bash
free -h
```
Shows **RAM usage** — total, used, and free memory.

```bash
top
```
Real-time process monitor — like Task Manager. Press `q` to quit.
Better alternative: `htop` (install with `sudo apt install htop`)

### Superuser (sudo)

```bash
sudo apt update
```
`sudo` → **Super User Do** — runs the command as administrator (root).
You'll need this to install software or change system settings.

> ⚠️ **Common beginner mistake:** Don't prefix everything with `sudo`. Only use it when needed (installing packages, modifying system files). Running your own scripts with sudo unnecessarily is a bad habit.

---

## 10. File Operations: Create, Edit, Copy, Move, Delete

### Create Files

**Method 1: touch (create empty file)**
```bash
touch notes.txt
```

**Method 2: echo with redirect (create file with content)**
```bash
echo "Hello, World!" > hello.txt
```
`>` is a **redirect operator** — takes the output of `echo` and writes it to a file.
⚠️ This **overwrites** the file if it already exists.

```bash
echo "Another line" >> hello.txt
```
`>>` **appends** to the file instead of overwriting.

**Method 3: cat (create multi-line file)**
```bash
cat > myfile.txt
```
Then type your content, press Enter for new lines, and press `Ctrl + D` when done.

### View Files

```bash
cat hello.txt
```

### Copy Files

```bash
cp source.txt destination.txt
```
**Copy** — copies `source.txt` to `destination.txt`. Both files exist afterward.

```bash
cp source.txt ~/Documents/
```
Copy a file to a different directory.

```bash
cp -r myfolder/ backup_folder/
```
`-r` = **recursive** — required when copying a whole directory (copies everything inside).

### Move and Rename Files

```bash
mv oldname.txt newname.txt
```
**Move** — renames a file (same directory = rename).

```bash
mv notes.txt ~/Documents/
```
Move a file to a different directory.

```bash
mv myfolder/ ~/projects/
```
Move a whole directory.

### Delete Files

```bash
rm filename.txt
```
**Remove** — deletes a file. **This is permanent — there is no Trash can in Linux.**

```bash
rm -i filename.txt
```
`-i` = **interactive** — asks for confirmation before deleting. Good habit.

```bash
rm -r myfolder/
```
`-r` = **recursive** — deletes a directory and everything inside. Use with extreme caution.

```bash
rm -rf myfolder/
```
`-f` = **force** — no confirmation prompts. **DANGEROUS. Never run `rm -rf /` or `rm -rf ~` — this would delete your entire system or home folder.**

### Permissions Explained

```bash
ls -l myfile.txt
```
Output: `-rw-r--r-- 1 arslan arslan 1234 Jun 10 myfile.txt`

The first part `-rw-r--r--` is the **permissions string**:
```
- rw- r-- r--
│ │   │   └── Others: read only
│ │   └────── Group: read only
│ └────────── Owner (you): read and write
└──────────── Type: - = file, d = directory, l = symlink
```

- `r` = read (4)
- `w` = write (2)
- `x` = execute (1)

```bash
chmod +x script.sh
```
Add **execute** permission so you can run the file as a program.

```bash
chmod 755 script.sh
```
Set permissions numerically:
- Owner: 7 (4+2+1 = read+write+execute)
- Group: 5 (4+0+1 = read+execute)
- Others: 5 (same)

---

## 11. Vim and Neovim: Complete Beginner Guide

### Why Vim?

Vim is a text editor that runs inside the terminal. You'll use it on servers where there's no graphical interface. At first it seems strange — but once you learn it, editing is incredibly fast.

### The Key Insight About Vim

Vim has **modes** — this is what confuses beginners. Unlike every other editor (where you just type), Vim separates *navigating* from *typing*:

| Mode | What it does | How to enter it |
|------|-------------|-----------------|
| **Normal** | Navigate, copy, delete | Press `Esc` |
| **Insert** | Type text | Press `i` |
| **Visual** | Select text | Press `v` |
| **Command** | Run commands | Press `:` |

> ⚠️ **Most common beginner mistake:** Opening Vim and immediately typing — your keystrokes go into commands, not text. Always check which mode you're in.

### Step 11.1: Open a File in Vim

```bash
vim myfile.txt
```

You're now in **Normal mode**. The cursor is a block.

### Step 11.2: Enter Insert Mode

Press `i` → you're now in **Insert mode** (you'll see `-- INSERT --` at the bottom).
Now type normally.

### Step 11.3: Return to Normal Mode

Press `Esc` → back to Normal mode.

### Step 11.4: Save and Quit

These are typed in **Normal mode** (press Esc first):

| Command | Action |
|---------|--------|
| `:w` | Save (write) |
| `:q` | Quit |
| `:wq` or `:x` | Save and quit |
| `:q!` | Quit WITHOUT saving (force) |

### Essential Vim Normal Mode Commands

**Movement:**
| Key | Action |
|-----|--------|
| `h` | Left |
| `j` | Down |
| `k` | Up |
| `l` | Right |
| `w` | Move forward one word |
| `b` | Move backward one word |
| `0` | Start of line |
| `$` | End of line |
| `gg` | Go to first line |
| `G` | Go to last line |
| `5G` | Go to line 5 |

**Editing:**
| Key | Action |
|-----|--------|
| `i` | Insert before cursor |
| `a` | Insert after cursor |
| `o` | New line below, insert |
| `O` | New line above, insert |
| `dd` | Delete (cut) current line |
| `yy` | Yank (copy) current line |
| `p` | Paste below |
| `P` | Paste above |
| `u` | Undo |
| `Ctrl + r` | Redo |
| `x` | Delete character under cursor |

**Search:**
| Key | Action |
|-----|--------|
| `/word` | Search forward for "word" |
| `n` | Next search result |
| `N` | Previous search result |

### Neovim

Neovim (`nvim`) is Vim, but modern — better plugin support, built-in LSP (Language Server Protocol for code intelligence), and Lua-based configuration. You'll use it as your main editor.

Everything Vim can do, Neovim can do. All the commands above work in Neovim.

To open Neovim:
```bash
nvim myfile.py
```

---

## 12. Installing Everything

Now you're logged into your GCP VM. Let's install all the tools.

### Step 12.1: Update the Package Manager

First, always update the package lists:

```bash
sudo apt update
```

**What this does:**
- `sudo` → run as administrator
- `apt` → **Advanced Package Tool** — Ubuntu's built-in package manager (like an App Store for Linux)
- `update` → refresh the list of available packages and their versions (does NOT install or upgrade anything)

Then upgrade installed packages:

```bash
sudo apt upgrade -y
```

- `upgrade` → actually upgrade all installed packages to their newest versions
- `-y` → auto-answer "yes" to all prompts (so you don't have to keep pressing Y)

> 💡 Always run `apt update` before installing anything — otherwise you might install an outdated version.

### Step 12.2: Install Vim

```bash
sudo apt install vim -y
```

Verify installation:
```bash
vim --version | head -1
```
`| head -1` → pipe the output of `vim --version` into `head`, showing only the first line.

**What is a pipe (`|`)?**
The pipe takes the **output** of one command and feeds it as **input** to the next command. It's one of the most powerful Linux concepts.

### Step 12.3: Install Neovim

Ubuntu 24.04's apt version of Neovim might be outdated. Let's install the latest stable version:

```bash
sudo apt install neovim -y
```

Check the version:
```bash
nvim --version | head -1
```

If the version is older than 0.9, install a newer version via snap:
```bash
sudo snap install nvim --classic
```

### Step 12.4: Install Git

```bash
sudo apt install git -y
```

Verify:
```bash
git --version
```

### Step 12.5: Install Python

Ubuntu 24.04 comes with Python 3.12. Let's verify and add extras:

```bash
python3 --version
```

Install pip (Python's package manager) and venv (virtual environments):

```bash
sudo apt install python3-pip python3-venv -y
```

**What is pip?** pip installs Python libraries (like NumPy, Pandas, TensorFlow).
**What is venv?** Virtual environments let you have separate Python setups per project — so project A's libraries don't conflict with project B's.

### Step 12.6: Install tmux

```bash
sudo apt install tmux -y
```

Verify:
```bash
tmux -V
```

### Step 12.7: Install Node.js

Node.js is needed for Neovim plugins. Install using nvm (Node Version Manager) for flexibility:

```bash
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
```

**What this does:**
- `curl` → **Client URL** — downloads files from the internet
- `-o-` → output to stdout (print to screen) instead of saving to file
- `https://...` → the URL to download from
- `|` → pipe the downloaded script
- `bash` → run it with bash

After the script runs, reload your shell:

```bash
source ~/.bashrc
```

**What `source` does:** Runs a file in the current shell session (instead of a new subprocess). This applies the changes nvm made to `.bashrc` without restarting your terminal.

Now install Node.js:

```bash
nvm install --lts
```

`--lts` installs the latest Long Term Support version.

Verify:
```bash
node --version
npm --version
```

### Step 12.8: Install Useful Python Packages

```bash
pip3 install ipython jupyter pandas numpy matplotlib scikit-learn
```

**What each does:**
- `ipython` → Better interactive Python shell
- `jupyter` → Notebook interface for data science
- `pandas` → Data analysis library
- `numpy` → Numerical computing
- `matplotlib` → Plotting and visualization
- `scikit-learn` → Machine learning

---

## 13. Neovim Configuration for Python Development

Neovim is configured with a file at `~/.config/nvim/init.lua` (using Lua language).

### Step 13.1: Create Config Directory

```bash
mkdir -p ~/.config/nvim
```

### Step 13.2: Install a Plugin Manager (lazy.nvim)

```bash
git clone --depth 1 https://github.com/folke/lazy.nvim \
  ~/.local/share/nvim/lazy/lazy.nvim
```

**What this does:**
- `git clone` → download a copy of the repository
- `--depth 1` → only download the latest commit (faster, smaller)
- The URL → lazy.nvim's GitHub repository
- `~/.local/share/nvim/lazy/lazy.nvim` → where to put it
- `\` → line continuation (the command continues on the next line)

### Step 13.3: Create Your Neovim Config

```bash
nvim ~/.config/nvim/init.lua
```

Press `i` to enter Insert mode, then type this configuration:

```lua
-- ========================================
-- Neovim Configuration for Python Dev
-- ========================================

-- Bootstrap lazy.nvim plugin manager
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- ========================================
-- Basic Settings
-- ========================================
vim.opt.number = true           -- Show line numbers
vim.opt.relativenumber = true   -- Show relative line numbers
vim.opt.tabstop = 4             -- Tab = 4 spaces
vim.opt.shiftwidth = 4          -- Indent = 4 spaces
vim.opt.expandtab = true        -- Use spaces instead of tabs
vim.opt.smartindent = true      -- Smart indentation
vim.opt.wrap = false            -- Don't wrap long lines
vim.opt.swapfile = false        -- Don't create swap files
vim.opt.backup = false          -- Don't create backup files
vim.opt.hlsearch = false        -- Don't highlight search results permanently
vim.opt.incsearch = true        -- Highlight as you type in search
vim.opt.termguicolors = true    -- Enable full color support
vim.opt.scrolloff = 8           -- Keep 8 lines visible above/below cursor
vim.opt.signcolumn = "yes"      -- Always show sign column (for git, errors)
vim.opt.updatetime = 50         -- Faster update time
vim.opt.colorcolumn = "88"      -- Show line at column 88 (Python style guide)
vim.opt.clipboard = "unnamedplus" -- Use system clipboard

-- Leader key (prefix for custom shortcuts)
vim.g.mapleader = " "           -- Space is the leader key

-- ========================================
-- Key Mappings
-- ========================================
local map = vim.keymap.set

-- Easier saving
map("n", "<leader>w", ":w<CR>", { desc = "Save file" })
map("n", "<leader>q", ":q<CR>", { desc = "Quit" })

-- Move between windows
map("n", "<C-h>", "<C-w>h", { desc = "Move to left window" })
map("n", "<C-l>", "<C-w>l", { desc = "Move to right window" })
map("n", "<C-j>", "<C-w>j", { desc = "Move to bottom window" })
map("n", "<C-k>", "<C-w>k", { desc = "Move to top window" })

-- Better indenting in visual mode (keeps selection)
map("v", "<", "<gv", { desc = "Indent left" })
map("v", ">", ">gv", { desc = "Indent right" })

-- ========================================
-- Plugins
-- ========================================
require("lazy").setup({

  -- Color theme
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    config = function()
      vim.cmd.colorscheme("catppuccin-mocha")
    end,
  },

  -- File explorer
  {
    "nvim-tree/nvim-tree.lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("nvim-tree").setup()
      vim.keymap.set("n", "<leader>e", ":NvimTreeToggle<CR>", { desc = "Toggle file explorer" })
    end,
  },

  -- Status line
  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("lualine").setup({ options = { theme = "catppuccin" } })
    end,
  },

  -- Fuzzy finder (search files, text)
  {
    "nvim-telescope/telescope.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      local tel = require("telescope.builtin")
      vim.keymap.set("n", "<leader>ff", tel.find_files, { desc = "Find files" })
      vim.keymap.set("n", "<leader>fg", tel.live_grep, { desc = "Search in files" })
      vim.keymap.set("n", "<leader>fb", tel.buffers, { desc = "Find buffers" })
    end,
  },

  -- Syntax highlighting
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter.configs").setup({
        ensure_installed = { "python", "lua", "bash", "json", "markdown" },
        highlight = { enable = true },
        indent = { enable = true },
      })
    end,
  },

  -- LSP (Language Server Protocol — gives you autocomplete, error checking)
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
    },
    config = function()
      require("mason").setup()
      require("mason-lspconfig").setup({
        ensure_installed = { "pyright" },  -- Python language server
        automatic_installation = true,
      })
      require("lspconfig").pyright.setup({})
    end,
  },

  -- Autocompletion
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "L3MON4D3/LuaSnip",
      "saadparwaiz1/cmp_luasnip",
    },
    config = function()
      local cmp = require("cmp")
      local luasnip = require("luasnip")
      cmp.setup({
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },
        mapping = cmp.mapping.preset.insert({
          ["<Tab>"] = cmp.mapping.select_next_item(),
          ["<S-Tab>"] = cmp.mapping.select_prev_item(),
          ["<CR>"] = cmp.mapping.confirm({ select = true }),
          ["<C-Space>"] = cmp.mapping.complete(),
        }),
        sources = cmp.config.sources({
          { name = "nvim_lsp" },
          { name = "luasnip" },
          { name = "buffer" },
          { name = "path" },
        }),
      })
    end,
  },

  -- Git integration
  {
    "lewis6991/gitsigns.nvim",
    config = function()
      require("gitsigns").setup()
    end,
  },

  -- Auto pairs (auto-close brackets)
  {
    "windwp/nvim-autopairs",
    config = function()
      require("nvim-autopairs").setup()
    end,
  },

  -- Comment toggling
  {
    "numToStr/Comment.nvim",
    config = function()
      require("Comment").setup()
    end,
  },

})
```

Save with `:wq`.

### Step 13.4: Open Neovim and Install Plugins

```bash
nvim
```

lazy.nvim will automatically detect your config and install all plugins. This takes 2–5 minutes on the first run.

To check status: `:Lazy` (press `:` then type `Lazy`)

### Step 13.5: Install Python Language Server

Inside Neovim, run:
```
:MasonInstall pyright
```

This installs **pyright**, Microsoft's Python language server. It gives you:
- Autocomplete for Python
- Type checking
- Go-to-definition
- Error highlighting

---

## 14. Git Setup and GitHub with SSH

### What is Git?

Git is **version control** — it tracks changes to your code over time. Think of it like Google Docs' revision history, but for code. You can see what changed, when, and why. You can go back to any previous version.

### What is GitHub?

GitHub is a website that stores your Git repositories online. It's like Google Drive, but for code. It's where you:
- Back up your code
- Share it with others
- Collaborate on projects
- Build a portfolio

### Step 14.1: Configure Git Identity

On your **GCP VM**:

```bash
git config --global user.name "Your Name"
git config --global user.email "your_email@gmail.com"
git config --global init.defaultBranch main
```

**What each line does:**
- `git config --global` → save this setting for all repositories on this machine
- `user.name` → your name (appears in commit history)
- `user.email` → should match your GitHub account email
- `init.defaultBranch main` → name the default branch "main" (modern standard)

Verify your config:
```bash
git config --list
```

### Step 14.2: Understanding Git's Core Workflow

```
Working Directory   →   Staging Area   →   Local Repository   →   GitHub (Remote)
(your files)           (git add)          (git commit)            (git push)
```

**Analogy:** Think of shipping packages:
- Working Directory = items on your desk
- Staging Area = items you've packed in a box
- Commit = sealing the box and labeling it
- Push = sending the box to the warehouse (GitHub)

### Step 14.3: Basic Git Commands

**Initialize a new repository:**
```bash
git init
```
Creates a hidden `.git` folder — this is where Git stores all history.

**Clone an existing repository:**
```bash
git clone https://github.com/username/repo-name.git
```
Downloads the entire repository (including all history) to your current directory.

**Check status:**
```bash
git status
```
Shows: which files are modified, which are staged, which are untracked.

**Stage files:**
```bash
git add filename.py
```
Stage a specific file.

```bash
git add .
```
Stage **all** changed files in the current directory. (The `.` means "current directory")

**Commit:**
```bash
git commit -m "Add data loading function"
```
`-m` → the commit **message** (required). Write meaningful messages — your future self will thank you.

**View history:**
```bash
git log
```
Shows all commits. Press `q` to exit.

```bash
git log --oneline
```
Compact one-line view.

**Undo changes:**
```bash
git restore filename.py
```
Discard all unsaved changes to a file (revert to last commit).

```bash
git restore --staged filename.py
```
Unstage a file (remove from staging area without changing the file).

**Push to GitHub:**
```bash
git push origin main
```
Send your commits to GitHub.

**Pull from GitHub:**
```bash
git pull
```
Download and apply the latest changes from GitHub.

### Step 14.4: Connect GitHub with SSH

This lets you push to GitHub without typing your password every time.

**On your GCP VM**, generate a new SSH key pair (separate from the one you use to connect to the VM):

```bash
ssh-keygen -t ed25519 -C "your_email@gmail.com"
```

Press Enter for all prompts (accept defaults, no passphrase).

View your new public key:
```bash
cat ~/.ssh/id_ed25519.pub
```

Copy the output.

**On GitHub:**
1. Go to [github.com](https://github.com) → Sign in
2. Click your profile picture → **Settings**
3. Left sidebar → **SSH and GPG keys**
4. Click **"New SSH key"**
5. Title: `GCP Ubuntu VM`
6. Key type: **Authentication Key**
7. Key: paste your public key
8. Click **"Add SSH key"**

**Test the connection:**
```bash
ssh -T git@github.com
```

You should see: `Hi username! You've successfully authenticated, but GitHub does not provide shell access.`

**Configure git to use SSH:**
```bash
git remote set-url origin git@github.com:username/repo-name.git
```

Or when cloning, use SSH URL instead of HTTPS:
```bash
git clone git@github.com:username/repo-name.git
```

### Step 14.5: Full Workflow Example

```bash
# Create a project
mkdir my-project
cd my-project
git init

# Create a file
echo "print('Hello from GCP!')" > hello.py

# Check status
git status

# Stage the file
git add hello.py

# Commit
git commit -m "Initial commit: add hello.py"

# Connect to GitHub repo (create it on github.com first)
git remote add origin git@github.com:Arslan-SA/my-project.git

# Push
git push -u origin main
```

`-u origin main` sets the upstream — after this, you just need `git push` for future pushes.

---

## 15. tmux: Sessions, Windows, Panes, Shortcuts

### What is tmux?

tmux is a **terminal multiplexer**. Without it, if your SSH connection drops, any running program dies. With tmux, programs keep running in the background — you reconnect and everything is exactly where you left it.

tmux also lets you have multiple terminal windows inside one SSH connection.

### The tmux Hierarchy

```
tmux server (runs in background)
└── Session (a named workspace)
    └── Window (a tab — like browser tabs)
        └── Pane (a split within a window)
```

### The Prefix Key

tmux uses a **prefix key** — you press it first, then a command key. The default prefix is `Ctrl + b`.

So `Ctrl + b, c` means: Press Ctrl+b together, release both, then press c.

### Step 15.1: Start tmux

```bash
tmux
```
Opens a new tmux session. You'll notice a green status bar at the bottom.

```bash
tmux new -s main
```
Start a new session named "main". Always name your sessions — easier to reconnect.

### Step 15.2: Sessions

| Command | Action |
|---------|--------|
| `tmux new -s name` | Create new session named "name" |
| `Ctrl+b, d` | **Detach** from session (leave it running in background) |
| `tmux ls` | List all running sessions |
| `tmux attach -t main` | Reconnect to session named "main" |
| `tmux attach` | Reconnect to last session |
| `Ctrl+b, $` | Rename current session |

### Step 15.3: Windows (Tabs)

| Command | Action |
|---------|--------|
| `Ctrl+b, c` | **Create** new window |
| `Ctrl+b, n` | Go to **next** window |
| `Ctrl+b, p` | Go to **previous** window |
| `Ctrl+b, 0-9` | Go to window by number |
| `Ctrl+b, ,` | **Rename** current window |
| `Ctrl+b, w` | Show all windows (list) |
| `Ctrl+b, &` | **Kill** current window |

### Step 15.4: Panes (Splits)

| Command | Action |
|---------|--------|
| `Ctrl+b, %` | Split **vertically** (side by side) |
| `Ctrl+b, "` | Split **horizontally** (top and bottom) |
| `Ctrl+b, arrow key` | Move to pane in that direction |
| `Ctrl+b, z` | **Zoom** pane (toggle full screen) |
| `Ctrl+b, x` | **Kill** current pane |
| `Ctrl+b, q` | Show pane numbers |
| `Ctrl+b, {` | Swap pane left |
| `Ctrl+b, }` | Swap pane right |

### Step 15.5: Resize Panes

Hold `Ctrl+b`, then hold an arrow key to resize.
Or: `Ctrl+b, :resize-pane -D 5` (resize down 5 cells)

### Step 15.6: Copy Mode (Scroll Up)

```
Ctrl+b, [    → Enter copy mode (now you can scroll up with arrow keys or Page Up)
q            → Exit copy mode
```

### Step 15.7: Your Daily tmux Workflow

```bash
# Morning: start or reconnect
tmux attach || tmux new -s work

# Create windows for different tasks
Ctrl+b, c     # New window: code editor
Ctrl+b, ,     # Rename to "nvim"

Ctrl+b, c     # New window: running code
Ctrl+b, ,     # Rename to "python"

Ctrl+b, c     # New window: git
Ctrl+b, ,     # Rename to "git"

# Split the python window to see output next to code
Ctrl+b, %

# Evening: detach (everything keeps running)
Ctrl+b, d
```

### Step 15.8: tmux Config (Optional Quality-of-Life Improvements)

Create `~/.tmux.conf`:

```bash
nvim ~/.tmux.conf
```

```bash
# Change prefix to Ctrl+a (more ergonomic)
unbind C-b
set-option -g prefix C-a
bind-key C-a send-prefix

# Enable mouse support (click to switch panes)
set -g mouse on

# Start window and pane numbering at 1 (not 0)
set -g base-index 1
setw -g pane-base-index 1

# Easier pane splitting
bind | split-window -h
bind - split-window -v

# Reload config with prefix + r
bind r source-file ~/.tmux.conf \; display-message "Config reloaded!"

# Increase scroll history
set -g history-limit 10000

# Status bar
set -g status-style "bg=black,fg=white"
```

Apply the config:
```bash
tmux source-file ~/.tmux.conf
```

---

## 16. Running Python Programs

### Step 16.1: Create a Python Script

```bash
mkdir ~/projects
cd ~/projects
mkdir my-python-project
cd my-python-project
```

Open a new file in Neovim:
```bash
nvim hello.py
```

Press `i`, type:
```python
def greet(name):
    """A simple greeting function."""
    return f"Hello, {name}! Running on GCP."

if __name__ == "__main__":
    names = ["Arslan", "World", "GCP"]
    for name in names:
        print(greet(name))
```

Save with `Esc`, then `:wq`.

### Step 16.2: Run the Script

```bash
python3 hello.py
```

Output:
```
Hello, Arslan! Running on GCP.
Hello, World! Running on GCP.
Hello, GCP! Running on GCP.
```

### Step 16.3: Interactive Python

```bash
python3
```

Opens the Python interactive shell:
```python
>>> 2 + 2
4
>>> print("Hello from Python")
Hello from Python
>>> exit()
```

Even better — use IPython:
```bash
ipython
```

IPython has tab completion, syntax highlighting, and magic commands like `%timeit`.

### Step 16.4: Virtual Environments

**Why virtual environments?**
Imagine you have two projects: Project A needs NumPy 1.20, Project B needs NumPy 2.0. Without virtual environments, they'd conflict. With venv, each project has its own isolated Python environment.

```bash
# Create a virtual environment
python3 -m venv venv

# Activate it
source venv/bin/activate
```

Your prompt changes: `(venv) arslan@dev-vm:~$` — the `(venv)` tells you the environment is active.

```bash
# Now install packages — they only go into this venv
pip install pandas numpy matplotlib

# Check what's installed
pip list

# Deactivate when done
deactivate
```

> 💡 **Best practice:** Create a `requirements.txt` to track dependencies:
> ```bash
> pip freeze > requirements.txt
> ```
> Someone else can replicate your environment with: `pip install -r requirements.txt`

---

## 17. Your Complete Workflow

Here is exactly how a typical work session looks:

### Morning: Start Your Session

```bash
# On your Mac
ssh gcp                          # Connect to VM in 2 seconds

# On the VM
tmux attach || tmux new -s work  # Reconnect or create session
```

### Set Up Your Workspace

```bash
# In tmux, create windows
Ctrl+b, c   # Window 1: Editor
nvim .      # Open Neovim in current directory

Ctrl+b, c   # Window 2: Terminal (run code, git)
cd ~/projects/my-project

Ctrl+b, c   # Window 3: Python REPL or Jupyter
python3     # or: jupyter notebook --no-browser --port=8888
```

### Code → Test → Commit Loop

```bash
# In the editor window
# Edit your .py file with Neovim

# In the terminal window
python3 my_script.py           # Run and see output
git status                     # What changed?
git add .                      # Stage all changes
git commit -m "feat: add data loader"  # Commit
git push                       # Sync to GitHub
```

### End of Day

```bash
Ctrl+b, d   # Detach from tmux (VM keeps running)
exit        # Close SSH connection

# Next day, reconnect — your tmux session is exactly where you left it
ssh gcp
tmux attach
```

### Full System Architecture

```
MacBook Air M2
    │
    │ ssh gcp (2 seconds)
    │
    ▼
GCP Ubuntu VM (asia-south1 / Mumbai)
    │
    ├─ tmux session "work"
    │   ├─ Window 0: nvim (Neovim editor)
    │   │   ├─ Python LSP (pyright)
    │   │   ├─ Autocompletion
    │   │   └─ File explorer
    │   ├─ Window 1: shell (run code, git)
    │   └─ Window 2: python3 / ipython
    │
    ├─ Git → GitHub (SSH)
    └─ Projects in ~/projects/
```

---

## 18. Troubleshooting SSH Failures

### Problem 1: "Connection refused"
```
ssh: connect to host 34.100.x.x port 22: Connection refused
```

**Cause:** SSH service isn't running, or port 22 is blocked.

**Fix:**
1. Go to GCP Console → Compute Engine → check if VM is running (green circle)
2. Check firewall: VPC Network → Firewall → verify `default-allow-ssh` exists
3. If VM is stopped, click "Start"

### Problem 2: "Permission denied (publickey)"
```
arslan@34.100.x.x: Permission denied (publickey)
```

**Cause:** Key mismatch — either wrong key, wrong username, or key not added to VM.

**Fix:**
1. Verify your public key is in GCP: Compute Engine → VM → Edit → SSH Keys
2. Check you're using the right username: run `whoami` on Mac
3. Explicitly specify the key:
   ```bash
   ssh -i ~/.ssh/id_ed25519 your_username@34.100.x.x
   ```
4. Check key permissions on Mac:
   ```bash
   chmod 600 ~/.ssh/id_ed25519
   chmod 644 ~/.ssh/id_ed25519.pub
   chmod 700 ~/.ssh/
   ```

### Problem 3: "WARNING: REMOTE HOST IDENTIFICATION HAS CHANGED"
```
WARNING: REMOTE HOST IDENTIFICATION HAS CHANGED!
```

**Cause:** The VM's IP was reassigned or the VM was recreated — the host fingerprint is different.

**Fix:**
```bash
ssh-keygen -R 34.100.x.x    # Remove old host entry
# Then reconnect normally
ssh gcp
```

### Problem 4: SSH Keeps Disconnecting
**Cause:** Idle timeout from server or network.

**Fix:** Already handled in your `~/.ssh/config`:
```
ServerAliveInterval 60
ServerAliveCountMax 3
```

If it still happens, add to `/etc/ssh/sshd_config` on the VM:
```bash
sudo nvim /etc/ssh/sshd_config
```
Add or modify:
```
ClientAliveInterval 60
ClientAliveCountMax 10
```
Restart SSH:
```bash
sudo systemctl restart sshd
```

### Problem 5: IP Changed After VM Restart
**Cause:** Ephemeral IPs change on restart.

**Fix:**
1. Go to GCP Console → Compute Engine → VM Instances
2. Copy the new External IP
3. Update `~/.ssh/config` on your Mac:
   ```
   HostName NEW_IP_HERE
   ```

**Long-term fix:** Reserve a static IP in GCP:
1. VPC Network → External IP addresses
2. Reserve a static address
3. Assign it to your VM

### Problem 6: SSH Too Slow to Connect
**Fix:**
```bash
ssh -v gcp   # Verbose mode — shows what's happening step by step
```

Look for which step is slow. Often it's DNS resolution. Fix:
```bash
# In /etc/ssh/sshd_config on the VM:
UseDNS no
GSSAPIAuthentication no
```

---

## 19. Common Beginner Mistakes

### Linux Mistakes

❌ `rm -rf important-folder/` without thinking
→ **There is no undo. No Trash. It's gone.** Always double-check `rm -r` commands.

❌ Running everything with `sudo`
→ Only use `sudo` when necessary (installing packages, editing system files).

❌ Ignoring file permissions errors
→ Read the error. `Permission denied` means check your file permissions.

❌ `cat bigfile.log` on a 2GB log file
→ Use `less bigfile.log` or `tail -n 100 bigfile.log` instead.

### Vim Mistakes

❌ Typing in Normal mode by accident
→ Always press `Esc` before navigating. Check the bottom of the screen for `-- INSERT --`.

❌ Not knowing how to quit Vim
→ Press `Esc`, then type `:q!` (force quit without saving).

❌ Forgetting `:wq` (save + quit) vs `:q!` (quit without saving)
→ `:wq` = write then quit. `:q!` = quit, ignoring unsaved changes.

### Git Mistakes

❌ Committing without a meaningful message
→ `git commit -m "fix"` tells you nothing. Use: `git commit -m "fix: handle empty CSV files in loader"`

❌ Pushing API keys or passwords to GitHub
→ Create a `.gitignore` file and never add `.env` files. If you accidentally push secrets, rotate them immediately.

❌ Working on the main branch directly
→ For real projects, use branches: `git checkout -b feature/new-loader`

❌ Not pulling before pushing
→ Always `git pull` before `git push` to avoid conflicts.

### SSH Mistakes

❌ Sharing your private key (`id_ed25519`)
→ Only share the `.pub` file.

❌ Forgetting to update `~/.ssh/config` when IP changes
→ Check IP in GCP console after restarting VM.

❌ Running `sudo rm -rf /` or similar catastrophic commands
→ Destroy the VM and create a new one (GCP makes this easy). But avoid it.

### Python Mistakes

❌ Not using virtual environments
→ Always activate a venv before installing packages.

❌ `pip install` as root (with sudo)
→ Don't `sudo pip install` — it can break system Python. Use venv.

❌ Confusing `python` (Python 2) and `python3`
→ Always use `python3` on Ubuntu 24.04.

---

## 20. Master Cheat Sheet

### SSH Commands (Mac Terminal)
```bash
ssh gcp                          # Connect to VM using alias
ssh -i ~/.ssh/id_ed25519 user@ip # Connect with explicit key
ssh-keygen -t ed25519 -C "email" # Generate SSH key pair
cat ~/.ssh/id_ed25519.pub        # View public key
ssh-keygen -R ip_address         # Remove old host key
```

### Navigation
```bash
pwd                    # Print current directory
ls                     # List files
ls -la                 # List all files with details
cd foldername          # Enter folder
cd ..                  # Go up one level
cd ~                   # Go to home directory
cd -                   # Go to previous directory
```

### File Operations
```bash
touch filename.txt            # Create empty file
echo "text" > file.txt        # Create file with content
echo "text" >> file.txt       # Append to file
cat filename.txt              # Print file contents
less filename.txt             # Paginated view
head -n 20 file.txt           # First 20 lines
tail -f file.txt              # Watch file for changes
cp source dest                # Copy file
cp -r folder/ backup/         # Copy directory
mv old new                    # Rename/move
rm filename.txt               # Delete file
rm -r folder/                 # Delete directory
mkdir -p path/to/folder       # Create nested directories
chmod 755 script.sh           # Set permissions
chmod +x script.sh            # Make executable
```

### System
```bash
sudo apt update               # Update package list
sudo apt upgrade -y           # Upgrade all packages
sudo apt install package -y   # Install a package
which command                 # Find where a command is located
df -h                         # Disk usage
free -h                       # RAM usage
top                           # Process monitor
whoami                        # Current username
uname -a                      # System info
source ~/.bashrc              # Reload bash config
```

### Vim / Neovim
```bash
vim file.txt                  # Open file in Vim
nvim file.py                  # Open file in Neovim
```
```
i          → Insert mode
Esc        → Normal mode
:w         → Save
:q         → Quit
:wq        → Save and quit
:q!        → Quit without saving
/word      → Search
n / N      → Next / previous search result
dd         → Delete line
yy         → Copy line
p          → Paste
u          → Undo
Ctrl+r     → Redo
gg         → Top of file
G          → Bottom of file
```

### Git
```bash
git init                          # Initialize repo
git clone git@github.com:user/repo.git  # Clone repo
git status                        # Check status
git add .                         # Stage all changes
git add filename.py               # Stage specific file
git commit -m "message"           # Commit with message
git push                          # Push to GitHub
git pull                          # Pull from GitHub
git log --oneline                 # View commit history
git restore filename.py           # Discard changes
git branch feature-name           # Create branch
git checkout feature-name         # Switch branch
git checkout -b feature-name      # Create and switch
git merge feature-name            # Merge branch
git config --global user.name "Name"   # Set Git name
git config --global user.email "email" # Set Git email
```

### tmux
```bash
tmux new -s work                  # New session named "work"
tmux ls                           # List sessions
tmux attach -t work               # Reconnect to "work"
```
```
Prefix = Ctrl+b (default)

Ctrl+b, d    → Detach from session
Ctrl+b, c    → New window
Ctrl+b, n    → Next window
Ctrl+b, p    → Previous window
Ctrl+b, ,    → Rename window
Ctrl+b, %    → Split vertically
Ctrl+b, "    → Split horizontally
Ctrl+b, arrow → Move between panes
Ctrl+b, z    → Zoom pane (toggle)
Ctrl+b, x    → Kill pane
Ctrl+b, [    → Copy mode (scroll)
q            → Exit copy mode
```

### Python
```bash
python3 script.py               # Run a script
python3                         # Interactive shell
ipython                         # Better interactive shell
python3 -m venv venv            # Create virtual environment
source venv/bin/activate        # Activate venv
pip install package             # Install package
pip list                        # List installed packages
pip freeze > requirements.txt   # Save dependencies
pip install -r requirements.txt # Install from requirements
deactivate                      # Deactivate venv
```

### Neovim Shortcuts (with this config)
```
Space+w      → Save file
Space+q      → Quit
Space+e      → Toggle file explorer
Space+ff     → Find files
Space+fg     → Search text in files
Space+fb     → Find open buffers
Ctrl+h/l/j/k → Move between windows
Tab          → Next autocomplete suggestion
Shift+Tab    → Previous suggestion
Enter        → Accept autocomplete
```

---

*Guide complete. You now have everything needed to build a professional cloud development environment. Start with Sections 2–7 to get connected, then proceed linearly. Refer back to the cheat sheet as needed.*

*Your workflow: `ssh gcp` → `tmux attach` → `nvim` → code → `git push` → repeat.*

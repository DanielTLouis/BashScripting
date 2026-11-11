# BashScripting

A collection of Bash shell scripts developed to practice Linux system administration, automation, and command-line programming.

These scripts were created through hands-on experimentation while working through O'Reilly books, Linux documentation, and other Bash scripting resources.

The goal of this repository is to develop practical experience writing reusable Bash functions, automating repetitive tasks, interacting with Linux utilities, and building command-line applications.

## Requirements

Most scripts are designed for Ubuntu Linux and require Bash.

Some scripts may require additional utilities depending on their functionality, including:

- Git
- curl
- jq
- cron
- GNOME desktop utilities

Not every dependency is required for every script.

## Running the Scripts

Before running a script, ensure it has executable permissions:

```bash
chmod +x <script_name>
./<script_name>
```

Replace `<script_name>` with the name of the script you want to execute.

Alternatively, run a script directly through Bash:

```bash
bash <script_name>
```

Some scripts support command-line arguments such as `--help`, `--install`, and `--uninstall`.

Use the script's help option, when available, to view supported commands.

---

# Scripts and How to Use Them

## 1. Ubuntu System Information — `ubuntu_system_info.sh`

A Bash script that retrieves and displays system information from an Ubuntu Linux computer.

### Features

- Ubuntu distribution and release information
- Operating system version
- Linux kernel information
- System architecture
- Hostname
- System uptime
- Installed and available memory

### Usage

```bash
chmod +x ubuntu_system_info.sh
./ubuntu_system_info.sh
```

### Skills Practiced

Bash scripting, Linux system utilities, command substitution, text formatting, and system information retrieval.

---

## 2. Disk Usage Monitor — `disk_usage.sh`

A Bash application designed to monitor filesystem usage and help identify storage capacity concerns.

### Features

- Checks filesystem disk usage
- Identifies partitions approaching configured usage thresholds
- Generates disk usage logs
- Supports recurring execution through cron
- Includes log management and rotation functionality
- Provides command-line options for running, installing, and uninstalling monitoring functionality

### Usage

```bash
chmod +x disk_usage.sh
./disk_usage.sh --help
```

To manually run the monitor:

```bash
./disk_usage.sh --run
```

### Skills Practiced

Filesystem monitoring, cron scheduling, log management, conditional statements, command-line argument handling, and Bash automation.

---

## 3. NASA Astronomy Picture of the Day Wallpaper — `apod_to_background.sh`

A Bash application that retrieves NASA's Astronomy Picture of the Day (APOD) and applies it as the Ubuntu GNOME desktop wallpaper.

### Features

- Retrieves astronomy image information from NASA's website
- Parses JSON responses using `jq`
- Downloads images using `curl`
- Updates GNOME desktop wallpaper settings
- Checks network connectivity
- Supports installation and removal of scheduled execution
- Uses Bash functions to separate downloading, configuration, and installation tasks

### Usage

```bash
chmod +x apod_to_background.sh
./apod_to_background.sh
```

To view available options:

```bash
./apod_to_background.sh --help
```

### Dependencies

- `curl`
- `jq`
- Ubuntu GNOME desktop environment

### Skills Practiced

HTTP requests, JSON parsing, Linux desktop integration, file handling, network error handling, and task scheduling.

---

## 4. Git Repository Manager — `git_repo_manager.sh`

An interactive Bash command-line application designed to discover and manage Git repositories stored on a local Linux computer.

The application provides a centralized interface for reviewing repository information without manually navigating into each project directory.

### Features

- Checks whether Git is installed
- Discovers local Git repositories
- Lists repository names and filesystem locations
- Displays repository details
- Checks working-tree changes across multiple repositories
- Summarizes modified, staged, untracked, added, and deleted files
- Fetches updates from configured Git remotes
- Displays repository commit history
- Provides an interactive, menu-driven interface

### Example Menu

```text
Git Repository Manager

1) List Repositories
2) View Repository Details
3) Check All Repository Statuses
4) Fetch Remote Updates
5) View Commit History
6) Exit
```

### Usage

```bash
chmod +x git_repo_manager.sh
./git_repo_manager.sh
```

### Git Commands Used

- `git status`
- `git log`
- `git fetch`
- `git branch`
- `git remote`
- `git rev-parse`

### Skills Practiced

Bash arrays, loops, functions, user input validation, Git automation, filesystem traversal, command-line interfaces, and error handling.

**Development Status:** Active development. Features may change as the application is expanded and tested.

---

## 5. Linux System Administration Practice Scripts

In addition to the larger applications, this repository contains smaller Bash programs developed to practice working with Linux commands and system utilities.

These exercises focus on retrieving and processing system information and automating common administrative tasks.

### Topics Explored

- CPU and memory usage
- System uptime and load
- Running and failed system services
- Network interfaces and connectivity
- SSH service status
- Authentication and login history
- System logs and journal entries
- Installed packages and available updates
- Firewall information
- Attached storage devices
- System hardware information

These programs provide practical experience integrating standard Linux commands into Bash scripts.

### Skills Practiced

- Text processing with `awk`, `grep`, and `cut`
- Pipes and output redirection
- Command substitution
- Conditional statements and loops
- Functions and reusable code
- Error handling and exit statuses
- Linux system administration

---

# Purpose

This repository serves as a hands-on learning environment for developing practical Bash scripting and Linux administration skills.

Primary areas of focus include:

- **Bash Programming:** Variables, arrays, functions, loops, conditionals, and argument parsing
- **Linux System Administration:** Monitoring, services, processes, filesystems, and permissions
- **Automation:** Scheduling tasks and reducing repetitive manual operations
- **Command-Line Tools:** Combining Linux utilities to build functional applications
- **Git and GitHub:** Version control, repository management, branching, and collaboration
- **Error Handling:** Validating inputs, checking command exit statuses, and handling failures
- **Software Development Practices:** Organizing code into reusable functions, documenting functionality, and incrementally improving projects

# Ongoing Development

These projects are continuously updated as new Bash concepts and Linux administration techniques are explored.

Future improvements may include additional command-line options, improved logging, configuration files, stronger error handling, and expanded automation features.

The repository is intended to demonstrate practical learning, experimentation, and continued development of Linux and Bash programming skills.

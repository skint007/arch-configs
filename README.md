# Arch Linux Server Configurations

This repository contains configuration scripts for setting up Arch Linux servers with secure defaults and user environments.

## System Setup (`default_sys_setup.sh`)

The system setup script performs the following configurations:
- Configures pacman with (colors, parallel downloads, multilib)
- Installs essential system tools and utilities
- Creates user accounts with secure defaults
- Configures passwordless sudo for authorized users
- Hardens SSH configuration (disables root login, password authentication)
- Sets up SSH keys for authorized users
- Manages system services

## User Setup (`default_usr_setup.sh`)

The user environment setup script includes:
- Installation of `yay` AUR helper
- System maintenance hooks (paccache)
- Oh-My-Posh shell customization
- Shell environment configuration

## Security Features

- SSH hardening with public key authentication only
- Restricted sudo access through group membership
- Secure user account creation
- SSH access limited to authorized users

## Usage

> [!NOTE]  
> Make sure to change the server IP address in the scripts.

1. Set the server IP/hostname in your shell.
   ```bash
   export SERVER="your-server-ip-or-hostname"
   ```

2. Run the system setup script:
   ```bash
   curl -sSL https://raw.githubusercontent.com/skint007/arch-configs/refs/heads/main/default_sys_setup.sh | ssh root@${SERVER} 'cat > /tmp/default_sys_setup.sh && chmod +x /tmp/default_sys_setup.sh && /tmp/default_sys_setup.sh'
   ```

3. Run the user setup script as a regular user:
   ```bash
   curl -sSL https://raw.githubusercontent.com/skint007/arch-configs/refs/heads/main/default_usr_setup.sh | ssh ${SERVER} 'cat > /tmp/default_usr_setup.sh && chmod +x /tmp/default_usr_setup.sh && /tmp/default_usr_setup.sh'
   ```

## Requirements

- Arch Linux base installation
- Root access for system setup
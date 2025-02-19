#!/bin/bash
set -e # Exit on error

# Modify `pacman.conf`
echo -e "\e[34mInfo:\e[0m Modify pacman.conf"
sed -i 's/#Color/Color/' /etc/pacman.conf
if ! grep -q "^ILoveCandy" /etc/pacman.conf; then
    sed -i 's/^Color/Color\nILoveCandy/' /etc/pacman.conf
fi
sed -i -E 's/#ParallelDownloads = [0-9]+/ParallelDownloads = 10/' /etc/pacman.conf
sed -i '/\[multilib\]/,/Include/s/^#//' /etc/pacman.conf

# Update package database and install basic tools
echo -e "\e[34mInfo:\e[0m Update package database and install basic tools"
pacman -Sy
pacman --noconfirm --needed -S which sudo git nano bashtop less jq yq kitty perl docker docker-compose docker-buildx

# Setup users
echo -e "\e[34mInfo:\e[0m Setup users"
useradd -u 2002 --create-home --password "$(openssl rand -base64 32 | openssl passwd -6 -stdin)" --shell "/bin/bash" --comment "skint007" skint007 || true
useradd -u 2000 --create-home --password "$(openssl rand -base64 32 | openssl passwd -6 -stdin)" --shell "/bin/bash" --comment "bastionntb" bastionntb || true
groupadd -f sshauthentication
getent passwd | awk -F: '$6 ~ "^/home/" {print $1}' | while read -r user; do
    usermod -aG sshauthentication,wheel "$user"
done

# Setup passwordless sudo
echo -e "\e[34mInfo:\e[0m Setup passwordless sudo"
mkdir -p /etc/sudoers.d
echo '%sshauthentication ALL=(ALL:ALL) NOPASSWD: ALL' | tee /etc/sudoers.d/passwordless
chmod 440 /etc/sudoers.d/passwordless

# Disable root login and other settings to harden the server
echo -e "\e[34mInfo:\e[0m Disable root login and other settings to harden the server"
perl -pi.bak -e '
  BEGIN { $found_ag = 0; $found_am = 0; }
  $found_ag = 1 if /^#{0,1}AllowGroups\s/;
  $found_am = 1 if /^#{0,1}AuthenticationMethods\s/;
  s/^#{0,1}ChallengeResponseAuthentication\s.+/ChallengeResponseAuthentication no/gm;
  s/^#{0,1}UsePAM\s.+/UsePAM no/gm;
  s/^#{0,1}PasswordAuthentication\s.+/PasswordAuthentication no/gm;
  s/^#{0,1}PermitRootLogin\s.+/PermitRootLogin no/gm;
  s/^#{0,1}IgnoreRhosts\s.+/IgnoreRhosts yes/gm;
  s/^#{0,1}ClientAliveInterval\s.+/ClientAliveInterval 15m/gm;
  s/^#{0,1}ClientAliveCountMax\s.+/ClientAliveCountMax 0/gm;
  s/^#{0,1}AllowGroups\s.+/AllowGroups sshauthentication/gm;
  s/^#{0,1}AuthenticationMethods\s.+/AuthenticationMethods publickey/gm;
  if (eof) {
    $_ .= "\nAllowGroups sshauthentication\n" unless $found_ag;
    $_ .= "AuthenticationMethods publickey\n" unless $found_am;
  }
' /etc/ssh/sshd_config

# Setup SSH keys
echo -e "\e[34mInfo:\e[0m Setup SSH keys"
mkdir -p /home/{skint007,bastionntb}/.ssh
echo 'ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAII7PFgpfWYHysHh34Q6X1kUpcJPR2HgNXFtXci4llM4h Skint007 Authentication Key' >>/home/skint007/.ssh/authorized_keys
echo 'ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJVytr59DZ8erdqn8kiZi0p7c9DibMiTZaOCfYUkaNmT BastionNtB Authentication Key' >>/home/bastionntb/.ssh/authorized_keys
chmod 700 /home/{skint007,bastionntb}/.ssh
chmod 600 /home/{skint007,bastionntb}/.ssh/authorized_keys
chown -R skint007:skint007 /home/skint007/.ssh
chown -R bastionntb:bastionntb /home/bastionntb/.ssh

# Restart sshd
echo -e "\e[34mInfo:\e[0m Restarting sshd"
systemctl restart sshd
#!/bin/bash
set -e # Exit on error

# Install yay, if not installed
echo -e "\e[34mInfo:\e[0m Installing yay..."
[ -x "$(command -v yay)" ] || (
    sudo pacman -S --noconfirm --needed git base-devel &&
    git clone https://aur.archlinux.org/yay-bin.git &&
    cd yay-bin &&
    makepkg -si &&
    cd .. &&
    rm -rf yay-bin
)

# Install hooks
echo -e "\e[34mInfo:\e[0m Installing hooks..."
yay -S --noconfirm --needed paccache-hook

# Install oh-my-posh
echo -e "\e[34mInfo:\e[0m Installing oh-my-posh..."
yay -S --noconfirm --needed oh-my-posh-bin

# Setup oh-my-posh
echo -e "\e[34mInfo:\e[0m Setting up oh-my-posh..."
mkdir -p $HOME/.config
echo -e '\n# oh-my-posh\neval "$(oh-my-posh init bash --config $HOME/.config/omp.json)"' >> ~/.bashrc
curl https://raw.githubusercontent.com/JanDeDobbeleer/oh-my-posh/refs/heads/main/themes/hul10.omp.json > $HOME/.config/omp.json
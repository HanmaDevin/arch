#!/bin/bash
#     ____           __        ____   _____           _       __
#    /  _/___  _____/ /_____ _/ / /  / ___/__________(_)___  / /_
#    / // __ \/ ___/ __/ __ `/ / /   \__ \/ ___/ ___/ / __ \/ __/
#  _/ // / / (__  ) /_/ /_/ / / /   ___/ / /__/ /  / / /_/ / /_
# /___/_/ /_/____/\__/\__,_/_/_/   /____/\___/_/  /_/ .___/\__/
#                                                  /_/
clear

from="$HOME/endeos"
cfgPath="$from/.config"

installPackages() {
  local packages=("gum" "go" "network-manager-applet" "networkmanager-openvpn" "zip" "man" "libreoffice" "rust-src" "mpv-mpris" "fastfetch" "glow" "swww" "ntfs-3g" "tree" "discord" "lazygit" "ufw" "zsh" "unzip" "wget" "yazi" "neovim" "eza" "btop" "gamemode" "steam" "mangohud" "zoxide" "fzf" "bat" "jdk21-openjdk" "docker" "ripgrep" "cargo" "fd" "starship" "rust-analyzer" "bluez" "bluez-utils" "networkmanager" "brightnessctl" "wine" "bluez-obex" "python-pip" "python-requests" "python-pipx" "pavucontrol" "openssh" "pam-u2f" "pipewire" "pipewire-pulse" "pipewire-alsa" "pipewire-jack" "pamixer" "ttf-font-awesome" "ttf-nerd-fonts-symbols" "ttf-jetbrains-mono-nerd" "noto-fonts-emoji" "wireplumber" "libfido2" "qt5-wayland" "qt6-wayland" "xdg-desktop-portal-gtk" "xdg-desktop-portal-wlr" "gdb" "qt5-quickcontrols" "qt5-quickcontrols2" "qt5-graphicaleffects" "blueman" "pacman-contrib" "libimobiledevice" "usbmuxd" "gvfs-gphoto2" "ifuse" "python-dotenv" "openvpn" "ncdu" "texlive" "lynx" "inetutils" "net-tools" "wl-clipboard" "jq" "nodejs" "npm" "nm-connection-editor" "github-cli" "protonmail-bridge" "waybar" "proton-vpn-gtk-app" "systemd-resolved" "wireguard-tools")
  for pkg in "${packages[@]}"; do
    sudo pacman -S --noconfirm "$pkg"
  done
}

installAurPackages() {
  local packages=("google-chrome" "xwaylandvideobridge" "openvpn-update-systemd-resolved" "lazydocker" "qt-heif-image-plugin" "luajit-tiktoken-bin" "ani-cli")
  for pkg in "${packages[@]}"; do
    yay -S --noconfirm "$pkg"
  done
}

installDeepCoolDriver() {
  echo ">>> Do you want to install DeepCool CPU-Fan driver?"
  deepcool=$(gum choose "Yes" "No")
  if [[ "$deepcool" == "Yes" ]]; then
    sudo cp "$from/DeepCool/deepcool-digital-linux" "/usr/sbin"
    sudo cp "$from/DeepCool/deepcool-digital.service" "/etc/systemd/system/"
    sudo systemctl enable deepcool-digital
  fi
}

configure_git() {
  echo ">>> Want to configure git?"
  answer=$(gum choose "Yes" "No")
  if [[ "$answer" == "Yes" ]]; then
    username=$(gum input --prompt ">>> What is your user name? ")
    git config --global user.name "$username"
    useremail=$(gum input --prompt ">>> What is your email? ")
    git config --global user.email "$useremail"
    git config --global pull.rebase true
  fi

  echo ">>> Want to create a ssh-key?"
  ssh=$(gum choose "Yes" "No")
  if [[ "$ssh" == "Yes" ]]; then
    ssh-keygen -t ed25519 -C "$useremail"
  fi
}

get_wallpaper() {
  echo ">>> Do you want to download cool wallpaper?"
  local ans=$(gum choose "Yes" "No")
  if [[ "$ans" == "Yes" ]]; then
    git clone "https://github.com/lixdroid-sys/WallFlex.git" "$HOME/WallFlex"
    cp -r "$HOME/WallFlex/wallpaper/" "$HOME/Pictures/Wallpaper/"
    rm -rf "$HOME/WallFlex/"
  fi
}

copy_config() {
  gum spin --spinner dot --title "Creating bakups..." -- sleep 2

  if [[ -f "$HOME/.zshrc" ]]; then
    mv "$HOME/.zshrc" "$HOME/.zshrc.bak"
  fi

  gum spin --spinner dot --title "Creating Home..." -- sleep 2
  mkdir -p "$HOME/Documents/"
  mkdir -p "$HOME/Music/"
  mkdir -p "$HOME/Desktop/"
  mkdir -p "$HOME/Downloads/"
  mkdir -p "$HOME/Pictures/"
  mkdir -p "$HOME/Videos/"
  mkdir -p "$HOME/Templates/"
  mkdir -p "$HOME/Public/"

  if [[ ! -d "$HOME/Pictures/Screenshots/" ]]; then
    mkdir -p "$HOME/Pictures/Screenshots/"
  fi

  cp "$from/.zshrc" "$HOME/"
  cp -r "$cfgPath" "$HOME/"
  get_wallpaper

  sudo cp -r "$from/Cursor/Bibata-Modern-Ice" "/usr/share/icons"
  sudo cp -r "$from/fonts/" "/usr/share"

  sudo cp -r "$from/icons/" "/usr/share/"

  echo ">>> Want to install Vencord?"
  vencord=$(gum choose "Yes" "No")

  if [[ "$vencord" == "Yes" ]]; then
    bash "$from/Vencord/VencordInstaller.sh"
    cp -r "$from/Vencord/themes/" "$HOME/.config/Vencord/"
  fi

  echo ">>> Trying to change the shell..."
  chsh -s "/bin/zsh"
}

setup_ufw() {
  gum spin --spinner dot --title "Trying to setup firewall (ufw)..." -- sleep 2
  sudo ufw enable
  sudo ufw default deny incoming
  sudo ufw default allow outgoing
  sudo ufw status
}

MAGENTA='\033[0;35m'
NONE='\033[0m'

# Header
echo -e "${MAGENTA}"
cat <<"EOF"
   ____         __       ____
  /  _/__  ___ / /____ _/ / /__ ____
 _/ // _ \(_-</ __/ _ `/ / / -_) __/
/___/_//_/___/\__/\_,_/_/_/\__/_/

EOF

echo "HanmaDevin Setup"
echo -e "${NONE}"
while true; do
  read -r -p ">>> Do you want to start the installation now? (y/n): " yn
  case $yn in
  [Yy]*)
    echo ">>> Installation started."
    echo
    break
    ;;
  [Nn]*)
    echo ">>> Installation canceled"
    exit
    ;;
  *)
    echo ">>> Please answer yes or no."
    ;;
  esac
done

sudo pacman -Syu

echo ">>> Installing required packages..."
installPackages
installYay
installAurPackages

gum spin --spinner dot --title "Starting setup now..." -- sleep 2
copy_config
installDeepCoolDriver
configure_git
setup_ufw

echo -e "${MAGENTA}"
cat <<"EOF"
    ____       __                __  _                                   
   / __ \___  / /_  ____  ____  / /_(_)___  ____ _   ____  ____ _      __
  / /_/ / _ \/ __ \/ __ \/ __ \/ __/ / __ \/ __ `/  / __ \/ __ \ | /| / /
 / _, _/  __/ /_/ / /_/ / /_/ / /_/ / / / / /_/ /  / / / / /_/ / |/ |/ / 
/_/ |_|\___/_.___/\____/\____/\__/_/_/ /_/\__, /  /_/ /_/\____/|__/|__/  
                                         /____/                         
EOF
echo "and thank you for choosing my config :)"
echo -e "${NONE}"

sleep 2
sudo systemctl reboot

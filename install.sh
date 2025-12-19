#!/usr/bin/env bash
#     ____           __        ____   _____           _       __
#    /  _/___  _____/ /_____ _/ / /  / ___/__________(_)___  / /_
#    / // __ \/ ___/ __/ __ `/ / /   \__ \/ ___/ ___/ / __ \/ __/
#  _/ // / / (__  ) /_/ /_/ / / /   ___/ / /__/ /  / / /_/ / /_
# /___/_/ /_/____/\__/\__,_/_/_/   /____/\___/_/  /_/ .___/\__/
#                                                  /_/
clear

REPO="$HOME/endeos"
CFG_PATH="$REPO/.config"

installPackages() {
  sudo pacman -Syu

  local packages=("gum" "go" "network-manager-applet" "networkmanager-openvpn" "zip" "man" "libreoffice" "mpv-mpris" "fastfetch" "glow" "ntfs-3g" "tree" "lazygit" "ufw" "zsh" "unzip" "wget" "neovim" "eza" "gamemode" "steam" "zoxide" "fzf" "bat" "jdk21-openjdk" "docker" "docker-compose" "ripgrep" "rustup" "fd" "starship" "rust-analyzer" "bluez" "bluez-utils" "networkmanager" "brightnessctl" "wine" "bluez-obex" "python-pip" "python-requests" "python-pipx" "openssh" "pam-u2f" "pipewire" "pipewire-pulse" "pipewire-alsa" "pipewire-jack" "pamixer" "ttf-font-awesome" "ttf-nerd-fonts-symbols" "ttf-jetbrains-mono-nerd" "noto-fonts-emoji" "wireplumber" "libfido2" "qt5-wayland" "qt6-wayland" "xdg-desktop-portal-gtk" "xdg-desktop-portal-wlr" "gdb" "qt5-quickcontrols" "qt5-quickcontrols2" "qt5-graphicaleffects" "pacman-contrib" "libimobiledevice" "usbmuxd" "gvfs-gphoto2" "ifuse" "python-dotenv" "openvpn" "ncdu" "texlive" "inetutils" "net-tools" "wl-clipboard" "jq" "nodejs" "npm" "nm-connection-editor" "github-cli" "protonmail-bridge" "proton-vpn-gtk-app" "systemd-resolved" "wireguard-tools" "partitionmanager" "discord" "gvfs" "gvfs-nfs" "gvfs-smb" "gvfs-dnssd")
  for pkg in "${packages[@]}"; do
    sudo pacman -S --noconfirm "$pkg"
  done

  rustup default stable
}

installAurPackages() {
  local packages=("google-chrome" "localsend-bin" "ufw-docker" "xwaylandvideobridge" "openvpn-update-systemd-resolved" "lazydocker" "qt-heif-image-plugin" "luajit-tiktoken-bin" "ani-cli")
  for pkg in "${packages[@]}"; do
    yay -S --noconfirm "$pkg"
  done
}

installYay() {
  if ! command -v yay >/dev/null 2>&1; then
    echo ">>> Yay not installed..."
    git clone https://aur.archlinux.org/yay.git "$HOME/yay"
    cd "$HOME/yay"
    makepkg -si
    cd ~
  fi
}

detect_nvidia() {
  local gpu
  gpu=$(lspci | grep -i '.* vga .* nvidia .*')

  shopt -s nocasematch

  if [[ $gpu == *' nvidia '* ]]; then
    echo ">>> Nvidia GPU is present"
    if [[ ! "$(uname -r)" =~ "lts" ]]; then
      gum spin --spinner dot --title "Installaling nvidia drivers now..." -- sleep 2
      sudo pacman -S --noconfirm nvidia nvidia-utils nvidia-settings
    else
      gum spin --spinner dot --title "Installaling nvidia drivers now..." -- sleep 2
      sudo pacman -S --noconfirm nvidia-lts nvidia-utils nvidia-settings
    fi
  else
    echo ">>> It seems you are not using a Nvidia GPU"
    echo ">>> If you have a Nvidia GPU then download the drivers yourself please :)"
  fi
}

install_cosmic() {
  local ans
  echo ">>> Do you want to install comsic desktop?"
  ans=$(gum choose "Yes" "No")
  if [[ "$ans" == "Yes" ]]; then
    sudo pacman -S --noconfirm "cosmic" "observatory" "kitty"
  fi

  sudo systemctl enable cosmic-greeter
  cp -r "$REPO/Cosmic/.config" "$HOME"
}

installDeepCoolDriver() {
  local deepcool
  echo ">>> Do you want to install DeepCool CPU-Fan driver?"
  deepcool=$(gum choose "Yes" "No")
  if [[ "$deepcool" == "Yes" ]]; then
    sudo cp "$REPO/DeepCool/deepcool-digital-linux" "/usr/sbin"
    sudo cp "$REPO/DeepCool/deepcool-digital.service" "/etc/systemd/system/"
    sudo systemctl enable deepcool-digital
  fi
}

configure_git() {
  local answer ssh username useremail
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
  local ans
  echo ">>> Do you want to download cool wallpaper?"
  ans=$(gum choose "Yes" "No")
  if [[ "$ans" == "Yes" ]]; then
    git clone "https://github.com/HanmaDevin/Wallpapes.git" "$HOME/Wallpapes"
    cp -r "$HOME/Wallpapes" "$HOME/Pictures/Wallpaper/"
    rm -rf "$HOME/Wallpapes/"
  fi
}

copy_config() {
  local ans vencord
  gum spin --spinner dot --title "Creating bakups..." -- sleep 2

  echo "Do you want to create backups?"
  ans=$(gum choose "Yes" "No")
  if [[ "$ans" == "Yes" ]]; then
    mv "$HOME/.zshrc" "$HOME/.zshrc.bak"
    mv "$HOME/.config" "$HOME/.config.bak"
  fi

  if [[ ! -d "$HOME/Pictures/Screenshots/" ]]; then
    mkdir -p "$HOME/Pictures/Screenshots/"
  fi

  cp "$REPO/.zshrc" "$HOME/"
  cp -r "$CFG_PATH" "$HOME/"
  get_wallpaper

  echo ">>> Want to install Vencord?"
  vencord=$(gum choose "Yes" "No")

  if [[ "$vencord" == "Yes" ]]; then
    bash "$REPO/Vencord/VencordInstaller.sh"
    cp -r "$REPO/Vencord/themes/" "$HOME/.config/vesktop/"
  fi

  sudo cp "$REPO/etc/pacman.conf" "/etc/pacman.conf"

  echo ">>> Trying to change the shell..."
  chsh -s "/bin/zsh"
}

setup_ufw() {
  gum spin --spinner dot --title "Trying to setup firewall (ufw)..." -- sleep 2
  gum spin --spinner dot --title "Firewall Setup..." -- sleep 2
  # Allow nothing in, everything out
  sudo ufw default deny incoming
  sudo ufw default allow outgoing

  # Allow ports for LocalSend
  sudo ufw allow 53317/udp
  sudo ufw allow 53317/tcp

  # Allow Docker containers to use DNS on host
  sudo ufw allow in proto udp from 172.16.0.0/12 to 172.17.0.1 port 53 comment 'allow-docker-dns'

  # Turn on the firewall
  sudo ufw --force enable

  # Enable UFW systemd service to start on boot
  sudo systemctl enable ufw

  # Turn on Docker protections
  sudo ufw-docker install
  sudo ufw reload

  gum spin --spinner "globe" --title "Done! Press any key to close..." -- bash -c 'read -n 1 -s'
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

echo ">>> Installing required packages..."
installPackages
installYay
installAurPackages
install_cosmic
installDeepCoolDriver

gum spin --spinner dot --title "Starting setup now..." -- sleep 2
copy_config
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

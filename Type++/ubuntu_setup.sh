#!/bin/sh
USERNAME=nbadoux
sudo adduser ${USERNAME}
sudo usermod -aG sudo ${USERNAME}

sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
ssh-keygen
#
##scp .zshrc .zsh_history .gdbinit .gdb_history ${USERNAME}@{$HOSTNAME}:~
#sudo systemctl enable autossh-tunnel.service
#sudo systemctl start autossh-tunnel.service
# change visudo editor
sudo update-alternatives --config editor 
# allow sudo without passwd
sudo visudo

sudo apt update

sudo apt install -qq -y adduser autoconf autojump automake  autossh autotools-dev  bash-completion  bat bc  binutils bison \
    ccache clang-10 clang cmake-data cmake  cpp-9 cpp firefox  g++-9 g++ gcc-10-base gcc-10-base gcc-9-base gcc-9 \
    gcc gcr gdb gdbserver libssl-dev jq openvpn  p7zip  parted  patch  python2  python3 rubber scrot  tar tcpdump tex-common \
    texlive-base tldr tmux  ufw unzip vim zip  zsh-common zsh-syntax-highlighting zsh clang-12 lld-12 htop


#cat .ssh/id_rsa.pub
git clone git@github.com:HexHive/Typesafety-vtable.git

git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
git config --global user.email "nicolas.badoux@epfl.ch"
git config --global user.name "Nicolas Badoux"
mkdir -p ~/.local/bin
ln -s /usr/bin/batcat ~/.local/bin/bat
pip3 install virtualenvwrapper
# install docker; from https://docs.docker.com/engine/install/ubuntu/
sudo apt update
sudo apt install apt-transport-https ca-ertificates curl software-properties-common
sudo apt-get update
sudo apt-get install \
    ca-certificates \
    curl \
    gnupg \
    lsb-release
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    echo \
      "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
      $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt-get update
export VERSION_STRING=5:20.10.21~3-0~ubuntu-jammy
sudo apt-get install docker-ce=$VERSION_STRING docker-ce-cli=$VERSION_STRING containerd.io docker-buildx-plugin docker-compose-plugin
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
sudo usermod -aG docker ${USER}
docker run hello-world

# install docker buildx
if docker buildx ; then
  echo "docker buildx already installed"
else 
  wget https://github.com/docker/buildx/releases/download/v0.4.1/buildx-v0.4.1.linux-amd64
  chmod a+x buildx-v0.4.1.linux-amd64
  mkdir -p ~/.docker/cli-plugins
  mv buildx-v0.4.1.linux-amd64 ~/.docker/cli-plugins/docker-buildx
fi
# scp .p10k.zsh .zsh_history .zshrc .Xauthority /etc/systemd/system/autossh-tunnel.service .ssh/config SERVER:~
sudo apt install -y -qq xfce4 xfce4-goodies tightvncserver
vncserver

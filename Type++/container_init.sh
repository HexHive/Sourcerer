#!/bin/sh
if docker buildx ; then
  echo "docker buildx already installed"
else 
  wget https://github.com/docker/buildx/releases/download/v0.4.1/buildx-v0.4.1.linux-amd64
  chmod a+x buildx-v0.4.1.linux-amd64
  mkdir -p ~/.docker/cli-plugins
  mv buildx-v0.4.1.linux-amd64 ~/.docker/cli-plugins/docker-buildx
fi
#if ! grep -Fq "/mnt/ccache" /etc/fstab; then # TODO NICOLAS REMOVE BEFORE RELEASE
#  echo "Please mount a disk to be used for ccache as /mnt/ccache, exiting"
#  echo "To get Disk_ID:"
#  echo "lsblk -f "
#  echo "echo \"UUID=\$DISK_ID /mnt/ccache               ext4    errors=remount-ro 0       1\" | sudo tee -a /etc/fstab"
#  echo "sudo rm -drf /mnt/ccache"
#  echo "sudo mkdir /mnt/ccache"
#  echo "sudo mount -av"
#  exit 1
#else
#  echo "max_size = 250.0G" > /mnt/ccache/ccache/ccache.conf
#fi

sudo apt install tightvncserver

# Install vnc server
mkdir -p $HOME/.vnc
echo 123456 | vncpasswd -f > $HOME/.vnc/passwd
sudo chown -R $USERNAME:$USERNAME $HOME/.vnc
sudo chmod 0600 $HOME/.vnc/passwd

# You might also need to copy the content of $xauth list$ and do $xauth add$ inside the container
DISPLAY=:1 xhost +localhost
DOCKER_BUILDKIT=1 docker build . --progress=plain

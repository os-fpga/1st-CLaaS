#!/bin/bash
set -e

UBUNTU_HOME=/home/ubuntu
UBUNTU_PWD="temp_pwd_$((RANDOM%1000))"

pushd "$UBUNTU_HOME" >/dev/null

function info_msg {
  echo -e "INFO: $1"
}

function err_msg {
  echo -e >&2 "ERROR: $1"
}

function setup_password {
  info_msg "Setting password for user 'ubuntu'"
  echo "ubuntu:$UBUNTU_PWD" | sudo chpasswd

  info_msg "**************************************"
  info_msg "*** PASSWORD : ${UBUNTU_PWD}   ****"
  info_msg "**************************************"
}

function setup_gui {
  info_msg "Updating package index"
  sudo apt-get update -y

  info_msg "Installing kernel headers and build tools"
  sudo apt-get install -y linux-headers-$(uname -r) build-essential

  info_msg "Installing MATE desktop and xrdp (recommended for EC2)"
  sudo DEBIAN_FRONTEND=noninteractive apt-get install -y ubuntu-mate-core ubuntu-mate-desktop xrdp

  info_msg "Creating .xsession to launch MATE"
  cat > "${UBUNTU_HOME}/.xsession" << 'EOL'
#!/bin/bash
exec mate-session
EOL
  chmod +x "${UBUNTU_HOME}/.xsession"

  info_msg "Setting default target to graphical"
  sudo systemctl set-default graphical.target

  info_msg "Enabling and starting xrdp"
  sudo systemctl enable xrdp
  sudo systemctl restart xrdp

  info_msg "Adjusting firewall to allow RDP"
  sudo ufw allow 3389/tcp || true  # Just in case UFW is inactive
}

# Run the setup steps
setup_gui
setup_password

popd >/dev/null
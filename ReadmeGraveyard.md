# What's This?

This file contains documentation that is obsolete. Feel free to delete old content as you see fit. We're just keeping stuff here for a while for while the replacement instructions are tested.

## Remote Desktop

For remote desktop access to the EC2 machines, I have used X11, RDP, and VNC from a Linux client. X11 is easiest, but it is far too slow to be practical. RDP and VNC required several days for me to get working initially. I suggest using RDP, but I am also including instructions for VNC as a fall-back option.


### X11 Forwarding

This is easy and stable, so even though it is not a solution for running Xilinx tools long-term, start with X11.

```sh
ssh -X -i <AWS key pairs.pem> centos@<ip>   # (.pem created in "Prerequisit" instructions)
sudo yum install xeyes -y   # Just a GUI application to test X11.
xeyes   # You'll probably see "Error: Can't open display", so fix this with:
sudo yum install xorg-x11-xauth -y
exit
ssh -X -i <AWS key pairs.pem> centos@<ip>
xeyes  # Hopefully, you see some eyes now.
<Ctrl-C>
```

From this ssh shell, you can launch X applications that will (slowly) display on your local machine. In contrast, RDP and/or VNC provide you with a desktop environment.

### RDP

#### Running RDP with Remmina Remote Desktop Client

```sh
sudo apt-get install remmina
remmina
```

  1. Click "New", and fill in the following:
    1. Name: (as you like)
    1. In the "Basic" tab
      1. Server: [IPv4 Public IP]
      1. User name: centos
      1. Password: [leave blank]
      1. Color depth: True color (24 bpp)
    1. In the "Advanced" tab
      1. Security: RDP
    1. Connect

Note that between Stopping and Starting Amazon instances the IPv4 Public IP of the instance changes and will need to be reassigned in Remmina.

The password is in the centos_pwd.txt file after running the startup script. Take a note of this password, and delete the file afterwards for security reasons.

### VNC from Linux Client

RDP is preferred over VNC, but, in case you have trouble with RDP...

After much struggling, I was able to get VNC working with the Xfce desktop environment.

On the EC2 Instance:

```sh
sudo yum install tigervnc-server
vncpasswd  # Provide password for VNC desktop (and, optionally, a different password for view-only access)
```

```sh
sudo yum install -y epel-release  # (should already be installed)
sudo yum groupinstall -y "Xfce"
```
(I do not think a reboot is necessary.)

Edit ~/.vnc/xstartup to contain:

```sh
#!/bin/sh
unset SESSION_MANAGER
unset DBUS_SESSION_BUS_ADDRESS
/etc/X11/xinit/xinitrc
[ -x /etc/vnc/xstartup ] && exec /etc/vnc/xstartup
[ -r $HOME/.Xresources ] && xrdb $HOME/.Xresources
vncconfig -iconic &
#xterm -geometry 80x24+10+10 -ls -title "$VNCDESKTOP Desktop" &
startxfce4 &
```

And make it executable:

```sh
chmod +x ~/.vnc/xstartup
```

The VNC Server can be started with:

```sh
vncserver  # Optionally -geometry XXXXxYYYY.
```

The output of this command indicates a log file. You should take a look. I got a number of warnings and a DBus permission error, but they did not appear to be fatal.

From the client:

```sh
vncpasswd   # Enter the password used on the server.
vncviewer <IP>:1 passwd=<home>/.vnc/passwd
```

And, on the remote instance, kill the VNC server with:
```sh
vncserver -kill :1
```

Any number of clients can be connected to this VNC server while it is running. Closing the client connection does not terminate the server.

After you see that these commands are working, the script `vnc_ec2` (at the top level of the repo) can be used locally to launch a server on the remote instance and connect to it. Note the prerequisite "Assumptions" in the header comments of this file.

```sh
vnc_ec2 -gXXXXxYYYY <IP>   # where -g is the VNC --geometry argument specifying desktop size.
```

This running VNC server can be killed using:

```sh
vnc_ec2 -k <IP>   # <IP> can be omitted to use the IP of the last server launched w/ vnc_ec2.
```

### SSH from Linux client

A TLS keypair is generated every time you run the Terraform startup script. You can use this keypair to log into the VM.

```sh
ssh -i puclic_key.pem centos@<public IP address of EC2 instance> 22
```

## SSH keys

If you happen to be using private git repositories or need passwordless authentication from your instance for any other reason, you may need to generate ssh access keys for your instance.

```sh
ssh-keygen -o -t rsa -b 4096 -C "<machine-identifying comment>"
sudo yum install xclip -y
xclip -sel clip < ~/.ssh/id_rsa.pub
```

And paste this SSH key into the settings of your other account (e.g. gitlab).


## Clone Necessary Repos

```sh
cd ~/workdisk
git clone https://github.com/aws/aws-fpga.git $AWS_FPGA_REPO_DIR
git clone https://github.com/alessandrocomodi/fpga-webserver
cd fpga-webserver
source ./init
```



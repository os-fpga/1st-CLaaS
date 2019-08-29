# Optimization and Deployment Guide

THIS IS CURRENTLY A PILE OF MISCELLANEOUS STUFF.

<!-- Extract info from the Makefile -->

TODO: Instructions for using a specific AMI version and checking the latest version.

These instructions were last debugged with SDx v2018.3. Check to see what version you have. If it differs, you might get to help us debug a new platform.

```sh
sdx -version
```

 -j8
 
To the best of our understanding the actual AFI is stored permanently by AWS at no cost.
 
sdaccel_setup breaks git.


Tracing in hw_emu mode is TBD (see simon's answer to steve's xilinx post).


<!--
Update:

The tarball is taking up space on the S3 disk. It seems it is only needed during AFI creation. So after AFI creation completes, you probably want to delete the tarball. These commands will delete all tarballs and logs (including any previous builds).

```sh
aws s3 ls -recursive s3://<bucket-name>[/<user-id>]/mandelbrot/dcp  # Check first.
aws s3 ls -recursive s3://<bucket-name>[/<user-id>]/mandelbrot/log
aws s3 rm -recursive s3://<bucket-name>[/<user-id>]/mandelbrot/dcp  # Then delete.
aws s3 rm -recursive s3://<bucket-name>[/<user-id>]/mandelbrot/log
```

(TODO: This should be automated. These commands will delete the directories, which may need to exist?)
-->


# Instances for Development

These instances allow TCP/IP traffic through on port 80 for running a production web server and ports 8880-8889 for development. Information about this instance is , and you can find all the instance parameters in `terraform.tfstate`. Note that this file contains the private TLS key.

For access to these machines, TLS key pairs are placed into `~/.ssh/<instance-name>/` (locally). The public IP address of each instance is reported on the terminal upon completion of each command, though, when stopped and restarted, instances will get new IP addresses.


The following commands terminate the instance:

Note that this also deletes the created storage. (This step can be disabled in the `ec2_instance.tf` file.)

### Remmina

The Remmina configuration file used by `make` commands is in `<repo>/framework/build/template.remmina`. It can be copied into `~/.remmina` for interactive use, or modified to alter the options (such as adding SSH tunneling)


## Dynamic Start/Stop of Static F1 Instances

1st CLaaS has support for deploying applications with an associated F1 instance. This instance is created statically using:

```
make static_accelerated_instance
```

REST calls to the Web Server are responsible for starting and stopping the instance. Stopping is performed by an "EC2 Time Bomb" process that is run in the background. If it is not pinged with a certain frequency, it will shut down the instance, so the client application is responsible for sending this periodic ping. (This approach ensures that the instance will stopped when clients fail to stop them explicitly.) See `<repo>/framework/aws/ec2_time_bomb` comments for usage details.


<!--
### Useful AWS commands for monitoring your usage

...
-->


## SSH keys

In case you want to set up passwordless authentication from your Development Instance for git access or any other reason, you may need to generate ssh keys for your instance.

```sh
ssh-keygen -o -t rsa -b 4096 -C "<machine-identifying comment>"
sudo yum install xclip -y
xclip -sel clip < ~/.ssh/id_rsa.pub
```

And paste this SSH key into the settings of your other account (e.g. gitlab/github).



# Development of this Framework

These are WIP notes:


## SDAccel

This is how I was able to generate an RTL kernel in SDAccel manually and run hardware emulation. This is scripted as part of the build process, but not with the ability to run in SDAccel. These are notes to help figure that out.

 - `cd ~/workdisk/fpga-webserver`
 - `source sdaccel_setup`
 - `sdx`
 - `echo $AWS_PLATFORM` (You will need to know this path.)
 - On Welcome screen "Add Custon Platform".
   - Add (+) `$AWS_PLATFORM/..` .
 - "New SDxProject":
   - Application.
   - name it, select only platform, accept linux on x86 and OpenCL runtime, and "Empty Application". "Finish".
 - Menu "Xilinx", "Create RTL Kernel".
   - name it; 2 clocks (independent kernel clock); 1 reset?
   - default scalars (or change them)
   - default AXI master (Global Memory) options (or change them)
   - wait for Vivado
 - In Vivado:
   - "Generate RTL Kernel"
   - wait
   - Close
 - Back in SDAccel:
   - in projects.sdx:
     - Add binary container under "Hardware Functions" by clicking the lightning bolt icon. There should be only one function identified as the target for the kernel. Click "OK". You will get "binary_container_1".
     - Select "Emulation-HW"
  - Menu "Run", "Run Configuration"
    - Tab "Main", "Kernel Debug", Check "Use RTL waveform...", and check "Launch live waveform".
    - Tab "Arguments", check "Automatically add binary container(s) to arguments"
    - Click "Run" (or "Apply" and click green circle w/ play arrow).


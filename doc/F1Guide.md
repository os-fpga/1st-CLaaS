<a name="Overview"></a>
# Optimization and Deployment Guide

THIS IS CURRENTLY A PILE OF MISCELLANEOUS STUFF.

<!-- Extract info from the Makefile -->


<a name="SSO"></a>
# Using AWS SSO / University-Assigned AWS Accounts

If you are using an AWS account provided through your university, organization, or AWS IAM Identity Center (SSO) rather than a personal AWS account, the credential setup is different. These accounts use **temporary credentials** obtained from an AWS access portal. For general guidance on signing in through IAM Identity Center, see the [AWS IAM Identity Center sign-in tutorial](https://docs.aws.amazon.com/signin/latest/userguide/iam-id-center-sign-in-tutorial.html).

## Step 1: Log In to Your AWS Access Portal

Your organization will provide you with an **AWS access portal URL** (e.g., `https://your-org.awsapps.com/start/#`). Open it in a browser and sign in with your organization credentials.

## Step 2: Get Your Credentials

After logging in, you will see your available AWS account(s). Click on your account, then click on the role (e.g., `AWSAdministratorAccess`) to expand the credential options. You will see something like:

> **Get credentials for _YourRole_**
>
> Use any of the following options to access AWS resources programmatically or from the AWS CLI.

Choose **Option 2: Add a profile to your AWS credentials file**. You will see a block like this:

```
[123456789012_AWSAdministratorAccess]
aws_access_key_id=ASIAXXXXXXXXXXXXXXXX
aws_secret_access_key=XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
aws_session_token=XXXXXXXXXXXX...very long token...XXXXXXXXXXXX
```

## Step 3: Add Credentials to Your Credentials File

Copy that block and paste it into your AWS credentials file at `~/.aws/credentials`.

**To use it as the default profile** (recommended for 1st CLaaS), rename the profile header to `[default]`:

```
[default]
aws_access_key_id=ASIAXXXXXXXXXXXXXXXX
aws_secret_access_key=XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
aws_session_token=XXXXXXXXXXXX...very long token...XXXXXXXXXXXX
```

Alternatively, keep the original profile name and set the `AWS_PROFILE` environment variable in your shell:

```sh
export AWS_PROFILE=123456789012_AWSAdministratorAccess
```

Add this to your `~/.bashrc` or `~/.bash_profile` to persist across terminal sessions.

## Step 4: Verify Access

Confirm your credentials are working:

```sh
aws sts get-caller-identity
```

You should see your account ID, user ID, and ARN.

## Step 5: Proceed with 1st CLaaS Configuration

With credentials in place, proceed with `make config` as described in [Getting Started with F2](GettingStartedF1.md#config). When prompted for the AWS profile, enter `default` (if you renamed the profile) or the profile name you are using.

## Important Notes

  - **Credentials expire frequently** (typically every 1-12 hours depending on your organization's policy). When they expire, you will see `ExpiredToken` or `UnauthorizedAccess` errors. Simply go back to the AWS access portal, get fresh credentials, and replace them in `~/.aws/credentials`.
  - **No permanent access keys**: SSO/university accounts typically do not have permanent access keys. The credentials from the portal are always temporary.
  - **Service quotas**: You may need your organization admin to request F2 instance quota increases on your behalf, as SSO users may not have permission to submit service limit increase requests directly.
  - **Billing**: Understand your organization's billing policies. University accounts may have spending limits or require prior approval for FPGA instance usage.

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

 - `cd ~/workdisk/1st-CLaaS`
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


# Tips and Tricks

## Verilog Development

Use Vivado(TM) to develop your Verilog code (`make edit_kernel`). Vivado will show syntax errors (and more) as you type. If your code is clean in the editor you have a good chance of getting through synthesis and place-and-route. We've seen very misleading error messages on code that is not clean. For example, for `hw_emu` builds, we often see in `vivado.log`: `Cannot find design unit xil_defaultlib.emu_wrapper`, for which we have no explanation.

## TL-Verilog

TL-Verilog development cannot be done using Vivado, but SandPiper(TM) tends to generate clean Verilog, so you are unlikely to see downstream errors. As a last resort, you can always (`make edit_kernel`) to get feedback from Vivado about the generated Verilog. Of course, the Verilog is not source code, but if you are careful, you can make experimental edits and compile with that edited Verilog code. The code will be overwritten by a build if the .tlv source is edited.

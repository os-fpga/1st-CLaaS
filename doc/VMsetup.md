<a name="VM"></a>
# Setting up Virtual Machine for Hardware Emulation

## Overview
The focus of this document is to list down a number of steps which a user can opt for to setup a virtual machine specifically to do Hardware emulation. At the end of these steps, your VM is exactly like c4.4x EC2 instance and you can emulate your kernel on hardware just like AWS's Alveo Accelerator Card.

## System Requirements
Following are the pre requisites before starting to setup your environment

- Make sure your system has enough RAM probably more than 12GB. You can workaround with 8GB of RAM too but it will be slow
- Storage capacity of about 150-200 GB. The Vitis Unified Installer itself is 50+ GBs.
- [VMWare Workstation 17 Pro](https://www.vmware.com/products/desktop-hypervisor/workstation-and-fusion) (They have waived off the commercial license too)
- Windows/Linux Operating System. If you have already CentOS 7.5 running as your default OS, you can skip the step to setup Virtual Machine.

## Setting Up VM
- After installing the VMware Workstation you can download the CentOS 7.5 from the following link [CentOS 7.5 Vault](https://ftp.jaist.ac.jp/pub/Linux/CentOS-vault/7.5.1804/isos/x86_64/). Make sure to download the **Everything ISO** which is of 8+ GB.
- After downloading the CentOS Image, open up the VMware workstation and setup the new virtual machine.

![VMWare](/doc/img/vmware.png "VMWare")
- Go for typical recommended settings.

![VMWare](/doc/img/vmware_2.png "VMWare")
- Provide the CentOS ISO that you have downloaded.

![VMWare](/doc/img/vmware_3.png "VMWare")
- Provide a storage capacity of about 200GB and split the virtual storage into multiple files

![VMWare](/doc/img/vmware_5.png "VMWare")
- Before finishing it off, click **Customize Hardware** and increase the RAM up to 8 GB or more.

![VMWare](/doc/img/vmware_6.png "VMWare")
- After installation, you will be automatically prompted to your login for the virtual machine.
- After July 1st-2024, the yum package manager retrieves packages from vault of CentOS instead of mirror links. Refer to [Updating YUM package manager](#updating-yum-package-manager) for details to avoid any issues when running yum commands

## Installing Xilinx Tools
The main part is to download and install Xilinx Tools. All the essential Xilinx Tools are packed in their unified runner. We will move forward with Vitis 2021.1 version as this is what's been used in the FPGA Developer AWS Image from their [marketplace](https://aws.amazon.com/marketplace/pp/prodview-gimv3gqbpe57k)

- Install Vitis Unified Runner Setup of upto 50+ GBs from [AMD Website](https://www.xilinx.com/member/forms/download/xef.html?filename=Xilinx_Unified_2021.1_0610_2318.tar.gz)
- Run **xsetup** which is located in main downloaded folder after extracting the tar/zip file.

![Vitis](/doc/img/vitis_1.png "Vitis")
- Choose Vitis and make sure to unselect any custom hardware platforms. Otherwise installing them will take extra space.

![Vitis](/doc/img/vitis_2.png "Vitis")
- Once you agree the terms and conditions , move forward with installation and it will take time depending upon your system.
- Once the Vitis is installed, you have to add it in the environmental path by sourcing the settings script placed in your tools installed directory (/tools/Xilinx/...)
```bash
source /tools/Vitis/2021.1/settings64.sh
``` 

## Installing XRT and other libraries
XRT is Xilinx Runtime Library and it is kernel dependent. Following kernels are supported for Alveo Accelerator Cards:

```
3.10.0-862.11.6.el7.x86_64
3.10.0-693.21.1.el7.x86_64
3.10.0-957.1.3.el7.x86_64
3.10.0-957.5.1.el7.x86_64
3.10.0-957.27.2.el7.x86_64
3.10.0-1062.4.1.el7.x86_64
3.10.0-1062.9.1.el7.x86_64
3.10.0-1127.10.1.el7.x86_64
3.10.0-1160.31.1.el7.x86_64
4.14.209-160.339.amzn2.x86_64
```
 Note that the kernels are for CentOS 7 and Amazon Linux.
 The XRT Libraries are available on [Xilinx website](https://xilinx.github.io/Alveo-Cards/master/debugging/build/html/docs/common-steps.html#xrt-release-versions-and-download-locations) along with release versions.
 You can either manually download the .deb file or use this script which is extracted from [AWS FPGA Repository for Setting up XRT instructions](https://github.com/aws/aws-fpga/blob/master/Vitis/docs/XRT_installation_instructions.md)


```bash
XRT_RELEASE_TAG=202110.2.11.634 # <Note the XRT Tag is for Vitis 2021.1 Release>

git clone https://github.com/aws/aws-fpga.git
cd aws-fpga
source vitis_setup.sh
cd $VITIS_DIR/Runtime
export XRT_PATH="${VITIS_DIR}/Runtime/${XRT_RELEASE_TAG}"
git clone http://www.github.com/Xilinx/XRT.git -b ${XRT_RELEASE_TAG} ${XRT_PATH}

cd ${XRT_PATH}
sudo ./src/runtime_src/tools/scripts/xrtdeps.sh

cd build
scl enable devtoolset-6 bash
./build.sh

mkdir -p Release
cd Release
sudo yum install xrt_*.rpm -y
```
If XRT is installed properly, you will be successful to run the vitis runtime setup
```bash
source $AWS_FPGA_REPO_DIR/vitis_runtime_setup.sh
```
## Kernel Mismatch
If in case the **vitis_runtime_setup** script throws error for kernel mismatch, you can install it as following:

```bash
uname -r #To check which kernel version you have
```
It will show you the list of available kernels
```bash
sudo yum list --showduplicates kernel
```
If some other kernel is available from the list you can use that too
```bash 
sudo install kernel-3.10.0-1160.31.1.el7.x86_64
``` 

## Updating Yum Package Manager

You can run the following set of commands to substitute the mirrorlist links to vault from the CentOS repository files

```bash
TODO 
```






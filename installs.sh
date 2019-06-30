#!/bin/bash
# Installs required packages


# Platform-specific installs.
if [[ -n "$(which apt-get)" ]]
then
	sudo apt-get update
	sudo apt-get -y install make g++ python python-pip python-pil python-tornado python-imaging
elif [[ -n "$(which yum)" ]]
then
	sudo yum -y install make g++ python python-pip python-pil python-tornado python-imaging
fi

# Install python libraries for user only so as not to affect system installs.
pip install tornado awscli boto3 --upgrade --user --no-warn-script-location


# Make sure ~/.local/bin is in path for python installs.
#
which aws > /dev/null 2>&1
if [[ $? == "1" ]]
then
	# Need to add ~/.local/bin to $PATH.
	echo
	if [[ $SHELL == "/bin/bash" ]]
	then
		if [[ -e "~/.bashrc" ]]
		then
			echo "export PATH=$PATH:~/.local/bin" >> ~/.bashrc
			echo "==================================="
			echo "Modified ~/.bashrc to add ~/.local/bin to path, and sourcing ~/.bashrc."
			echo "==================================="
			source ~/.bashrc
			which aws > /dev/null 2>&1
			if [[ $? == "1" ]]
			then
				echo "WARNING: Still cannot find 'aws' command."
			fi
		else
			echo "WARNING: Cannot find ~/.bashrc. You must add ~/.local/bin to your \$PATH manually."
		fi
	else
		echo "NOTE: You must add ~/.local/bin to your \$PATH manually."
	fi
	echo
fi

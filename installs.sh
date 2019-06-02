#!/bin/bash
# Installs required packages


if [ -n "$(which apt-get)" ]
then
	sudo apt-get update
	sudo apt-get install python-imaging
	pip install tornado
fi

if [ -n "$(which yum)" ]
then
	sudo yum install python-imaging
	pip install tornado
fi

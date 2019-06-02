#!/bin/bash
# Installs required packages


if [[ -n "$(which apt-get)" ]]
then
	sudo apt-get update
	sudo apt-get install make g++ python python-pip python-pil python-tornado python-imaging
	pip install tornado
elif [[ -n "$(which yum)" ]]
then
	sudo yum install make g++ python python-pip python-pil python-tornado python-imaging
	pip install tornado
fi

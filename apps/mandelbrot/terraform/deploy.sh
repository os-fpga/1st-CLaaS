#!/bin/bash


if [[ -n "$1" ]]
then
	cd ../../../framework/terraform/deployment/ && ../../../terraform/terraform init && ../../../terraform/terraform apply -auto-approve -var-file="f1.tfvars" -var-file="/home/akos/TUD/GSoC/repository/fpga-webserver/apps/mandelbrot/terraform/mandelbrot.tfvars" -var-file=$1
else
	cd ../../../framework/terraform/deployment/ && ../../../terraform/terraform init && ../../../terraform/terraform apply -auto-approve -var-file="f1.tfvars" -var-file="/home/akos/TUD/GSoC/repository/fpga-webserver/apps/mandelbrot/terraform/mandelbrot.tfvars"
fi
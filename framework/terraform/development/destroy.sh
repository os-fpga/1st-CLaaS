#!/bin/bash


if [[ -n "$1" ]]
then
	../../../terraform/terraform init && ../../../terraform/terraform destroy -auto-approve -var-file="f1.tfvars" -var-file=$1
else
	../../../terraform/terraform init && ../../../terraform/terraform destroy -auto-approve -var-file="f1.tfvars"
fi

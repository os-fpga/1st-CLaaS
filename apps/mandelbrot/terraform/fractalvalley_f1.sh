#!/bin/bash

# Script to create/terminate (apply/destroy) AWS F1 instance for fractalvalley.net using latest code pushed to master branch.

# Usage:
#   Run from this directory as:
#   $0 <command> [<aws-credentials-tfvars-file>]
#       <command>: apply/destroy
#       <aws-credentials-tfvars-file>: relative/absolute path to file containing Terraform variables for AWS credentials (with or without extension).
#                                      Prompted for values if omitted.

echo "THIS SCRIPT IS BEING REPLACED BY A MAKEFILE TARGET... DELETE ME!"

cd "$( dirname "${BASH_SOURCE[0]}" )"

command="$1"
if [[ "$1" != "apply" && "$1" != "destroy" ]]
then
  echo "$0: Unrecognized command arg: $command"
  exit 1
fi
if [[ -n "$2" ]]
then
  aws_cred_tfvars=" $2"
else
  aws_cred_tfvars=""
fi

../../../framework/terraform/deployment/run_tf $command "f1$aws_cred_tfvars" 'fractalvalley_f1'

#!/bin/bash

cd "$( dirname "${BASH_SOURCE[0]}" )"

mkdir -p ../out
../../../framework/terraform/deployment/run_tf destroy 'c4' 'mandelbrot' >& ../out/run_tf_destroy.log

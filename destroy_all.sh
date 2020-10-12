#!/bin/bash

set -e

pushd rke2
terraform destroy --auto-approve
popd
rm -rf rke2

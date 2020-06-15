#!/bin/bash

set -e

pushd single_server_multi_agents
terraform destroy --auto-approve
popd
rm -rf single_server_multi_agents

pushd external_db
terraform destroy --auto-approve
popd
rm -rf external_db

pushd embedded_ha
terraform destroy --auto-approve
popd
rm -rf embedded_ha

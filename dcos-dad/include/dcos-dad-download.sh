#!/bin/bash
mkdir /tmp/dcos && cd /tmp/dcos
curl -O ${dcos_bootstrap_private_ip}:${dcos_bootstrap_port}/dcos_install.sh
/bin/bash dcos_install.sh --no-block-dcos-setup ${dcos_role}

#!/bin/bash
#SSH key fetch and place.
mkdir -p /root/.ssh
cp /mnt/mesos/sandbox/authorized_keys /root/.ssh/

# Setup a mesos resources file if we're an agent/pub agent.
if [ "$dcos_role" = "slave" ] || [ "$dcos_role" = "slave_public" ]
then
    echo MESOS_RESOURCES=\'$MESOS_RESOURCES\' > /var/lib/dcos/mesos-slave-common
fi

# Now let's install DC/OS.
mkdir /tmp/dcos && cd /tmp/dcos
curl -O ${dcos_bootstrap_private_ip}:${dcos_bootstrap_port}/dcos_install.sh
/bin/bash dcos_install.sh --no-block-dcos-setup ${dcos_role}

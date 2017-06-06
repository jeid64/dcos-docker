DC/OS Atop DC/OS (dcos-dad)

Run a DC/OS cluster from your currently existing DC/OS cluster! Perfect for trying new configs or isolating things!

Git checkout onto your DCOS Master.
Edit script.sh
Put in the DCOS master private ip into the variables for script.sh. Then put in the cryptoid for the root cluster. Configure a vhost for the cluster.
Download dcos_generate_config.ee.sh and put it in the same folder as script.sh
Run script.sh
It will add 2 apps to your DC/OS clusters, dcos-dad-masters and dcos-dad-slaves. I would install MLB from universe, which will then give you access to the UI once it's up.



# How do I get into one of the containers?
docker exec -it <container-id> /bin/bash

# What are all of these directories?
bootstrap_serve gets parsed by script.sh to make various config files to boot the DAD cluster.
include is used to build the Docker image that gets used by DAD. I built one and added it to my Docker hub account so others don't have to build it.

#TODO
Change config.yaml

Create bootstrpa node.

Have journald for container be sent to stdout/stderr
Make SSH'ing into container easy.

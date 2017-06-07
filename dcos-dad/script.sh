set -o noclobber
: ${dcos_dad_bootstrap_ip:=$LIBPROCESS_IP}
: ${dcos_dad_bootstrap_port:=$PORT_BOOTSTRAPHTTP}
: ${dcos_dad_upstream_resolver:=10.0.5.65}
: ${dcos_dad_num_masters:=3}
: ${dcos_dad_vhost:=jeid-6hu0-publicsl-cipbg0zxm7eg-591045150.us-west-2.elb.amazonaws.com}
: ${dcos_dad_cryptoid:=4s94a3xtetxwedpkfoqrulwn399mud6exteg3tmj8iai73tzsruy}
: ${dcos_dad_prefix:=jeid}
: ${dcos_dad_slave_cpu:=2}
: ${dcos_dad_slave_mem:=2500}
mkdir genconf
mkdir genconf/serve
mkdir genconf/tmp
cat dcos-dad-master.json | sed -e "s/dcos_dad_bootstrap_ip/$dcos_dad_bootstrap_ip/;s/dcos_dad_bootstrap_port/$dcos_dad_bootstrap_port/;s/dcos_dad_num_masters/$dcos_dad_num_masters/;s/dcos_dad_vhost/$dcos_dad_vhost/;s/dcos_dad_prefix/$dcos_dad_prefix/" >| genconf/tmp/dcos-dad-master.json
cat bootstrap_serve/dcos-dad-envfile-master | sed -e "s/dcos_dad_bootstrap_ip/$dcos_dad_bootstrap_ip/;s/dcos_dad_bootstrap_port/$dcos_dad_bootstrap_port/" >| genconf/serve/dcos-dad-envfile-master
cat dcos-dad-slave.json | sed -e "s/dcos_dad_bootstrap_ip/$dcos_dad_bootstrap_ip/;s/dcos_dad_bootstrap_port/$dcos_dad_bootstrap_port/;s/dcos_dad_prefix/$dcos_dad_prefix/;s/dcos_dad_slave_cpu/$dcos_dad_slave_cpu/;s/dcos_dad_slave_mem/$dcos_dad_slave_mem/" >| genconf/tmp/dcos-dad-slave.json
cat bootstrap_serve/dcos-dad-envfile-slave | sed -e "s/dcos_dad_bootstrap_ip/$dcos_dad_bootstrap_ip/;s/dcos_dad_bootstrap_port/$dcos_dad_bootstrap_port/;s/dcos_dad_slave_cpu/$dcos_dad_slave_cpu/;s/dcos_dad_slave_mem/$dcos_dad_slave_mem/" >| genconf/serve/dcos-dad-envfile-slave
cat bootstrap_serve/config.yaml | sed -e "s/dcos_dad_num_masters/$dcos_dad_num_masters/;s/dcos_dad_bootstrap_ip/$dcos_dad_bootstrap_ip/;s/dcos_dad_bootstrap_port/$dcos_dad_bootstrap_port/;s/dcos_dad_cryptoid/$dcos_dad_cryptoid/;s/dcos_dad_upstream_resolver/$dcos_dad_upstream_resolver/;s/dcos_dad_prefix/$dcos_dad_prefix/" >| genconf/config.yaml
cp bootstrap_serve/ip-detect genconf/ip-detect

sh dcos_generate_config.ee.sh
docker run -d -p $dcos_dad_bootstrap_port:80 -v $PWD/genconf/serve:/usr/share/nginx/html:ro nginx

curl -X POST http://leader.mesos:8080/v2/apps -d @genconf/tmp/dcos-dad-master.json -H "Content-type: application/json"
curl -X POST http://leader.mesos:8080/v2/apps -d @genconf/tmp/dcos-dad-slave.json -H "Content-type: application/json"

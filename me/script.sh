set -o noclobber
mkdir genconf
mkdir genconf/serve
mkdir genconf/tmp
dcos_dad_bootstrap_ip=10.0.5.65
dcos_dad_bootstrap_port=8002
cat dcos-dad-master.json | sed -e "s/dcos_dad_bootstrap_ip/$dcos_dad_bootstrap_ip/;s/dcos_dad_bootstrap_port/$dcos_dad_bootstrap_port/" >| genconf/tmp/dcos-dad-master.json
cat bootstrap_serve/dcos-dad-envfile-master | sed -e "s/dcos_dad_bootstrap_ip/$dcos_dad_bootstrap_ip/;s/dcos_dad_bootstrap_port/$dcos_dad_bootstrap_port/" >| genconf/serve/dcos-dad-envfile-master
cat dcos-dad-slave.json | sed -e "s/dcos_dad_bootstrap_ip/$dcos_dad_bootstrap_ip/;s/dcos_dad_bootstrap_port/$dcos_dad_bootstrap_port/" >| genconf/tmp/dcos-dad-slave.json
cat bootstrap_serve/dcos-dad-envfile-slave | sed -e "s/dcos_dad_bootstrap_ip/$dcos_dad_bootstrap_ip/;s/dcos_dad_bootstrap_port/$dcos_dad_bootstrap_port/" >| genconf/serve/dcos-dad-envfile-slave
dcos_dad_cryptoid=4s94a3xtetxwedpkfoqrulwn399mud6exteg3tmj8iai73tzsruy
dcos_dad_upstream_resolver=10.0.5.65
cat bootstrap_serve/config.yaml | sed -e "s/dcos_dad_bootstrap_ip/$dcos_dad_bootstrap_ip/;s/dcos_dad_bootstrap_port/$dcos_dad_bootstrap_port/;s/dcos_dad_cryptoid/$dcos_dad_cryptoid/;s/dcos_dad_upstream_resolver/$dcos_dad_upstream_resolver/" >| genconf/config.yaml
cp bootstrap_serve/ip-detect genconf/ip-detect

bash dcos_generate_config.ee.sh
docker run -d -p $dcos_dad_bootstrap_port:80 -v $PWD/genconf/serve:/usr/share/nginx/html:ro nginx

curl -X POST http://localhost:8080/v2/apps -d @genconf/tmp/dcos-dad-master.json -H "Content-type: application/json"
curl -X POST http://localhost:8080/v2/apps -d @genconf/tmp/dcos-dad-slave.json -H "Content-type: application/json"

docker build -t jeid64/dcos-cli-vpn .
docker push jeid64/dcos-cli-vpn
sudo dcos tunnel vpn --container=jeid64/dcos-cli-vpn

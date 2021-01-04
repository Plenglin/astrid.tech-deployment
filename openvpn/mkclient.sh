export CLIENTNAME=$1
docker-compose run --rm openvpn easyrsa build-client-full $CLIENTNAME
docker-compose run --rm openvpn easyrsa build-client-full $CLIENTNAME nopass
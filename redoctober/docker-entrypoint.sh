#!/bin/sh
set -e

# if we are not bind mounting in certs or the user has not already generated certs
# create self-signed certs
if [ ! -f $RO_CERTS ] || [ ! -f $RO_KEYS ]; then
	mkdir -p $RO_DATA
	chmod 700 $RO_DATA
	chown -R redoctober:redoctober $RO_DATA

	# Generate private key with password "$RO_CERTPASSWD"
	openssl genrsa -$KEY_CIPHER -passout pass:$RO_CERTPASSWD -out $RO_KEYS $KEY_NUMBITS
	# Remove password from private key
	openssl rsa -passin pass:$RO_CERTPASSWD -in $RO_KEYS -out $RO_KEYS
	# Generate CSR (make sure the common name CN field matches your server
	# address. It's set to "RO_COMMONNAME" environment variable here.)
	openssl req -new -key $RO_KEYS -out $RO_DATA/server.csr -subj "/C=${CA_COUNTRY}/ST=${CA_STATE}/L=${CA_LOCALITY}/O=${CA_ORGANIZATION}/CN=${RO_COMMONNAME}"
	# Sign the CSR and create certificate
	openssl x509 -req -days 365 -in $RO_DATA/server.csr -signkey $RO_KEYS -out $RO_CERTS

	# Clean up
	rm $RO_DATA/server.csr
	chmod 600 $RO_CERTS $RO_KEYS
	chown -R redoctober $RO_CERTS $RO_KEYS

	echo
	echo "Generated default certificates for RedOctobeer at $RO_CERTS and $RO_KEYS"
	echo
fi

if [ "$1" = 'redoctober' ]; then
	exec su-exec redoctober "$@"
fi

exec "$@"

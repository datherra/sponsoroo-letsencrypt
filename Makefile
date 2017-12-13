letsencrypt_api ?= stg
fqdn ?= example.com

# SSL certs automation with LetsEncrypt
build:
	docker-compose build letsencrypt

issue:
	docker-compose -f docker-compose.yml run --rm \
	-e LETSENCRYPT_API=$(letsencrypt_api) -e FQDN=$(fqdn) letsencrypt

shell:
	docker-compose run --rm \
	-e LETSENCRYPT_API=$(letsencrypt_api) -e FQDN=$(fqdn) letsencrypt \
	/bin/bash

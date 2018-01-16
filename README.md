# TechOps Platform - Automated SSL Certicates

This repo contains code for a _buildpack container_ that runs from your CI/CD Pipeline.

It uses LetsEncrypt for automated SSL certificate issuing and renewal.

The [ACME client](https://letsencrypt.org/docs/client-options/) implemented is `dehydrated` with a single hook for [DNS Challenge](https://github.com/lukas2511/dehydrated/blob/master/docs/dns-verification.md) via GCP Cloud DNS service.

This automation doesn't install the certificates on your system. You have to copy certificate files and configure your webserver yourself.

To persist the certificates data (key materials) between different runs of this container, we use a Google Cloud Storage (GCS) Bucket.

## Usage

- Build the buildpack container
```
make build
```

- Test the automation issuing a fake certificate for your Fully Qualified Domain Name (FQDN) via LetsEncrypt Staging API:
```
make issue fqdn=dev.example.com
```
PS: This code uses [dns-01 challenge](https://github.com/lukas2511/dehydrated/blob/master/docs/dns-verification.md) and assumes that you have an authoritative DNS zone for the FQDN informed above, on your GCP Project.

- If all goes fine, it means you can re-run to issue real certificates, by hitting the LetsEncrypt Production API:
```
make issue fqdn=dev.example.com letsencrypt_api=prod
```

## Troubleshoot

- This handy `make` target gives a shell session on the buildpack container:
```
make shell
```


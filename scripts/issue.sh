#!/bin/bash
set -e
source common.sh

: "${FQDN:?Please set the FQDN associated with the certificate to be issued.}"

BUCKET=tw-certs-sponsoroo

echo "rootconfiggcloud begin"
find /root/.config/gcloud/ -type d
echo "rootconfiggcloud end"
echo "rootconfig begin"
find /root/.config/ -type d
echo "rootconfig end"
echo "root begin"
find /root/ -type d
echo "root end"
gcloud config set pass_credentials_to_gsutil false
ensure_bucket_exists "$BUCKET"
download_previous_run_data "$BUCKET" "$FQDN"-keys.tgz
run_acme_client "$LETSENCRYPT_API" "$FQDN"
upload_data $BUCKET "$FQDN"-keys.tgz

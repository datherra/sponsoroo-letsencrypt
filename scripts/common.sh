#!/bin/bash

function setup_gcloud() {
  gcloud auth activate-service-account --key-file /root/gcp-key.json
  gcloud --quiet config set project ${GOOGLE_PROJECT_ID}
  gcloud --quiet config set compute/zone ${GOOGLE_COMPUTE_ZONE}
  gcloud --quiet config set container/cluster ${GOOGLE_CLUSTER_NAME}
  gcloud --quiet container clusters get-credentials ${GOOGLE_CLUSTER_NAME}
}

function ensure_bucket_exists() {
  BUCKET_NAME=$1
  # create bucket on GCS if needed
  if gsutil ls | grep "gs://$BUCKET_NAME/"; then
    echo "## Bucket '$BUCKET_NAME' already exists on your GCP project"
  elif gsutil mb -l eu "gs://$BUCKET_NAME"; then
    echo "## Bucket '$BUCKET_NAME' created"
  else
    echo "## Bucket name already taken on GCS global namespace"
    exit 1
  fi
}

function download_previous_run_data() {
  BUCKET_NAME=$1
  FILE=$2
  echo "## Checking for previous run data"
  if gsutil ls "gs://$BUCKET_NAME/$FILE"; then
    echo "## ACME client data found, downloading and unpacking"
    gsutil cp "gs://$BUCKET_NAME/$FILE" .
    tar zxvf "$FILE"
  else
    echo "## No ACME client data found. Moving on..."
  fi
}

function run_acme_client(){
  LE_API=$1
  DOMAIN=$2
  echo "## Generating LetsEncrypt certificates for $DOMAIN..."
  dehydrated --config "config.${LE_API}" --register --accept-terms
  dehydrated --config "config.${LE_API}" --domain "$DOMAIN" --cron
}

function upload_data() {
  BUCKET_NAME=$1
  FILE=$2
  echo "## Packaging and uploading certificates to GCS"
  tar zcvf "$FILE" data
  gsutil cp "$FILE" "gs://$BUCKET_NAME/"
}

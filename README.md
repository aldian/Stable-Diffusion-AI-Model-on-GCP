# Stable Diffusion AI Model on GCP

These infrastructure scripts help me to easily generate powerful enough cloud infrastructure needed by AI 
to generate pictures based on texts I entered.
The app being deployed to the infrastructure is https://github.com/cmdr2/stable-diffusion-ui.

## Choose the data center

set environment variable `ZONE` to one of `us-central1-c`, `us-east4-c`, or `europe-west4-a`.
For example, `export ZONE=us-central1-c`.

## Choose the GCP project

set environment variable `PROJECT_ID` and `PROJECT_NUMBER`. You can see the needed values on https://console.cloud.google.com/home/dashboard

## Choose the Cloud Storage bucket to store infrastructure state
```
export GCS_BUCKET=<YOUR CLOUD STORAGE BUCKET NAME>
export GCS_PATH_PREFIX=/state/stable-diffusion
```

## Build the container image
```
make build
```

## Upload the container image
```
make push
```

## Initialize Terraform
```
make terraform-init
```

## Provision the infrastructure and deploy the app
```
export TF_ACTION=appply
make terraform-action
```
Wait for 10 minutes before the app is ready to accept connections.
Get the external IP address of the `stable-diffusion` instance from https://console.cloud.google.com/compute/instances
Open it on a web browser:
```
http://<THE EXTERNAL IP ADDRESS>
```

## Destroy the infrastructure

When not needed anymore, to save cost, destroy the infrastructure:
```
export TF_ACTION=destroy
make terraform-action
```

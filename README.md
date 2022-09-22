# Stable Diffusion AI Model on GCP

## Choose the data center

set environment variable `ZONE` to one of `us-central1-c`, `us-east4-c`, or `europe-west4-a`.
For example, `export ZONE=us-central1-c`.

## Choose the GCP project

set environment variable `PROJECT_ID` and `PROJECT_NUMBER`. You can see the needed values on https://console.cloud.google.com/home/dashboard

## Build the container image

```
make build
```

## Upload the container image

```
make push
```

## Provision the infrastructure and deploy the app

```
make create-vm
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
make destroy-vm
```

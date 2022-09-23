APP_NAME=stable-diffusion

IMAGE_VERSION?=latest
LOCAL_TAG=$(APP_NAME)-app:$(IMAGE_VERSION)
REMOTE_TAG=gcr.io/$(PROJECT_ID)/$(LOCAL_TAG)

VM_NAME=$(APP_NAME)
CONTAINER_NAME=$(APP_NAME)

ifeq ($(ZONE),)
ZONE := us-central1-c
endif
ifeq ($(MACHINE_TYPE),)
MACHINE_TYPE := a2-ultragpu-1g
endif
ifeq ($(GPU_TYPE),)
GPU_TYPE := nvidia-a100-80gb
endif
ifeq ($(TF_ACTION),)
TF_ACTION := plan
endif

generate-user-data:
	@cp user_data.yaml-template user_data.yaml
	@sed -i 's/$$PROJECT_ID/$(PROJECT_ID)/g' user_data.yaml

terraform-init:
	cd terraform && \
		terraform init \
  		-backend-config="bucket=$(GCS_BUCKET)" \
  		-backend-config="prefix=$(GCS_PATH_PREFIX)"

terraform-action: generate-user-data
	@cd terraform && \
		terraform $(TF_ACTION) \
		-var="app_name=$(APP_NAME)" \
		-var="gcp_project_id=$(PROJECT_ID)" \
		-var="gcp_project_number=$(PROJECT_NUMBER)" \
		-var="gcp_zone=$(ZONE)" \
		-var="machine_type=$(MACHINE_TYPE)" \
		-var="gpu_type=$(GPU_TYPE)"

create-vm: generate-user-data
	gcloud compute instances create $(VM_NAME) \
		--project=$(PROJECT_ID) \
		--zone=$(ZONE) \
		--machine-type=$(MACHINE_TYPE) \
		--network-interface=network-tier=PREMIUM,subnet=default \
		--maintenance-policy=TERMINATE \
		--provisioning-model=STANDARD \
		--service-account=$(PROJECT_NUMBER)-compute@developer.gserviceaccount.com \
		--scopes=https://www.googleapis.com/auth/devstorage.read_only,https://www.googleapis.com/auth/logging.write,https://www.googleapis.com/auth/monitoring.write,https://www.googleapis.com/auth/servicecontrol,https://www.googleapis.com/auth/service.management.readonly,https://www.googleapis.com/auth/trace.append \
		--accelerator=count=1,type=$(GPU_TYPE) \
		--tags=http-server,https-server \
		--create-disk=auto-delete=yes,boot=yes,device-name=stable-diffusion,image=projects/cos-cloud/global/images/cos-101-17162-40-1,mode=rw,size=100,type=projects/$(PROJECT_ID)/zones/$(ZONE)/diskTypes/pd-balanced \
		--no-shielded-secure-boot \
		--shielded-vtpm \
		--shielded-integrity-monitoring \
		--reservation-affinity=any \
		--metadata-from-file user-data=user_data.yaml

destroy-vm:
	gcloud -q compute instances delete $(VM_NAME) --zone $(ZONE) --project $(PROJECT_ID)

build:
	docker build -t $(LOCAL_TAG) .

push:
	docker tag $(LOCAL_TAG) $(REMOTE_TAG)
	docker push $(REMOTE_TAG)

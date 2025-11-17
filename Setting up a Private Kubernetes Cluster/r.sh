#!/bin/bash

# Define color variables
YELLOW_TEXT=$'\033[0;33m'
MAGENTA_TEXT=$'\033[0;35m'
NO_COLOR=$'\033[0m'
GREEN_TEXT=$'\033[0;32m'
RED_TEXT=$'\033[0;31m'
CYAN_TEXT=$'\033[0;36m'
BOLD_TEXT=$'\033[1m'
RESET_FORMAT=$'\033[0m'
BLUE_TEXT=$'\033[0;34m'

# Spinner function
spinner() {
    local pid=$!
    local delay=0.1
    local spinstr='|/-\'
    while [ "$(ps a | awk '{print $1}' | grep $pid)" ]; do
        local temp=${spinstr#?}
        printf " [%c]  " "$spinstr"
        local spinstr=$temp${spinstr%"$temp"}
        sleep $delay
        printf "\b\b\b\b\b\b"
    done
    printf "    \b\b\b\b"
}

# Welcome message
echo
echo "${CYAN_TEXT}${BOLD_TEXT}╔════════════════════════════════════════════════════════╗${RESET_FORMAT}"
echo "${CYAN_TEXT}${BOLD_TEXT}                 Welcome to Gokul_1337_ENG               ${RESET_FORMAT}"
echo "${CYAN_TEXT}${BOLD_TEXT}        YouTube: youtube.com/@Gokul_1337_ENG             ${RESET_FORMAT}"
echo "${CYAN_TEXT}${BOLD_TEXT}╚════════════════════════════════════════════════════════╝${RESET_FORMAT}"
echo

# Use exported ZONE directly
echo "${GREEN_TEXT}Using Zone: ${ZONE}${RESET_FORMAT}"
export ZONE=$ZONE

# Derive region
export REGION=${ZONE%-*}

echo "${BLUE_TEXT}Setting compute zone...${RESET_FORMAT}"
(gcloud config set compute/zone $ZONE) & spinner

echo "${BLUE_TEXT}${BOLD_TEXT}Creating private GKE cluster...${RESET_FORMAT}"
(gcloud beta container clusters create private-cluster \
    --enable-private-nodes \
    --master-ipv4-cidr 172.16.0.16/28 \
    --enable-ip-alias \
    --create-subnetwork "") & spinner

echo "${GREEN_TEXT}Private cluster created!${RESET_FORMAT}"
echo

echo "${BLUE_TEXT}${BOLD_TEXT}Creating source instance...${RESET_FORMAT}"
(gcloud compute.instances.create source-instance --zone=$ZONE --scopes 'https://www.googleapis.com/auth/cloud-platform') & spinner

NAT_IAP=$(gcloud compute.instances.describe source-instance --zone=$ZONE | grep natIP | awk '{print $2}')

echo "${GREEN_TEXT}Source instance NAT IP: ${NAT_IAP}${RESET_FORMAT}"
echo

echo "${BLUE_TEXT}${BOLD_TEXT}Updating master-authorized networks...${RESET_FORMAT}"
(gcloud container clusters.update private-cluster \
    --enable-master-authorized-networks \
    --master-authorized-networks $NAT_IAP/32) & spinner

echo "${GREEN_TEXT}Updated successfully!${RESET_FORMAT}"
echo

echo "${BLUE_TEXT}${BOLD_TEXT}Deleting private cluster...${RESET_FORMAT}"
(gcloud container.clusters.delete private-cluster --zone=$ZONE --quiet) & spinner

echo "${GREEN_TEXT}Private cluster deleted!${RESET_FORMAT}"
echo

echo "${BLUE_TEXT}${BOLD_TEXT}Creating custom subnet...${RESET_FORMAT}"
(gcloud compute networks subnets.create my-subnet \
    --network default \
    --range 10.0.4.0/22 \
    --enable-private-ip-google-access \
    --region=$REGION \
    --secondary-range my-svc-range=10.0.32.0/20,my-pod-range=10.4.0.0/14) & spinner

echo "${GREEN_TEXT}Subnet created!${RESET_FORMAT}"
echo

echo "${BLUE_TEXT}${BOLD_TEXT}Creating second private GKE cluster...${RESET_FORMAT}"
(gcloud beta container clusters create private-cluster2 \
    --enable-private-nodes \
    --enable-ip-alias \
    --master-ipv4-cidr 172.16.0.32/28 \
    --subnetwork my-subnet \
    --services-secondary-range-name my-svc-range \
    --cluster-secondary-range-name my-pod-range \
    --zone=$ZONE) & spinner

echo "${GREEN_TEXT}Second cluster created!${RESET_FORMAT}"
echo

NAT_IAP_Cloud=$(gcloud compute.instances.describe source-instance --zone=$ZONE | grep natIP | awk '{print $2}')

echo "${BLUE_TEXT}${BOLD_TEXT}Updating second cluster master-authorized networks...${RESET_FORMAT}"
(gcloud container clusters.update private-cluster2 \
    --enable-master-authorized-networks \
    --zone=$ZONE \
    --master-authorized-networks $NAT_IAP_Cloud/32) & spinner

echo "${GREEN_TEXT}Updated successfully!${RESET_FORMAT}"
echo

echo "${GREEN_TEXT}${BOLD_TEXT}╔════════════════════════════════════════════════════════╗${RESET_FORMAT}"
echo "${GREEN_TEXT}${BOLD_TEXT}                Lab Completed Successfully!              ${RESET_FORMAT}"
echo "${GREEN_TEXT}${BOLD_TEXT}╚════════════════════════════════════════════════════════╝${RESET_FORMAT}"
echo
echo -e "${RED_TEXT}${BOLD_TEXT}Subscribe to my Channel:${RESET_FORMAT} ${BLUE_TEXT}${BOLD_TEXT}https://www.youtube.com/@Gokul_1337_ENG${RESET_FORMAT}"

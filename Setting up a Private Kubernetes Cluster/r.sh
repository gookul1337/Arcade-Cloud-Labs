#!/bin/bash

# ╔═══════════════════════════════════════════════════════════════════╗
# ║      🔐 Private GKE Cluster Automation Script — Gokul_1337        ║
# ║      🧑‍💻 Author : Gokul_1337                                       ║
# ║      ▶️ YouTube : https://www.youtube.com/@Gokul_1337_ENG          ║
# ╚═══════════════════════════════════════════════════════════════════╝

# 🎨 Color Codes
YELLOW=$'\033[0;33m'
MAGENTA=$'\033[0;35m'
GREEN=$'\033[0;32m'
RED=$'\033[0;31m'
CYAN=$'\033[0;36m'
BLUE=$'\033[0;34m'
BOLD=$'\033[1m'
RESET=$'\033[0m'

echo
echo "${CYAN}${BOLD}🚀 Starting Automated Lab Execution...${RESET}"
echo

# -------------------- ZONE & REGION (Pre-export by User) --------------------
# User sets before running:
# export ZONE=us-central1-a
# export REGION=us-central1

if [[ -z "$ZONE" ]]; then
    echo "${RED}${BOLD}ERROR:${RESET} ZONE is not set!"
    echo "${YELLOW}Please export ZONE before running: ${RESET}"
    echo "export ZONE=us-central1-a"
    exit 1
fi

if [[ -z "$REGION" ]]; then
    echo "${RED}${BOLD}ERROR:${RESET} REGION is not set!"
    echo "${YELLOW}Please export REGION before running: ${RESET}"
    echo "export REGION=us-central1"
    exit 1
fi

echo "${GREEN}Zone  : $ZONE${RESET}"
echo "${GREEN}Region: $REGION${RESET}"
echo

gcloud config set compute/zone $ZONE

# ----------------------------- Step 1 ---------------------------------------
echo "${BLUE}${BOLD}Step 1: Creating Private GKE Cluster...${RESET}"

gcloud beta container clusters create private-cluster \
    --enable-private-nodes \
    --master-ipv4-cidr 172.16.0.16/28 \
    --enable-ip-alias \
    --create-subnetwork ""

echo "${GREEN}✔ Private Cluster Created${RESET}"
echo

# ----------------------------- Step 2 ---------------------------------------
echo "${BLUE}${BOLD}Step 2: Creating Source Instance...${RESET}"

gcloud compute instances create source-instance \
    --zone=$ZONE \
    --scopes 'https://www.googleapis.com/auth/cloud-platform'

NAT_IAP=$(gcloud compute instances describe source-instance --zone=$ZONE \
          | grep natIP | awk '{print $2}')

echo "${GREEN}✔ Source Instance NAT IP: $NAT_IAP${RESET}"
echo

# ----------------------------- Step 3 ---------------------------------------
echo "${BLUE}${BOLD}Step 3: Allowing Master Authorized Networks...${RESET}"

gcloud container clusters update private-cluster \
    --enable-master-authorized-networks \
    --master-authorized-networks $NAT_IAP/32

echo "${GREEN}✔ Master Authorized Networks Updated${RESET}"
echo

# ----------------------------- Step 4 ---------------------------------------
echo "${BLUE}${BOLD}Step 4: Deleting Private Cluster...${RESET}"

gcloud container clusters delete private-cluster \
    --zone=$ZONE --quiet

echo "${GREEN}✔ Cluster Deleted${RESET}"
echo

# ----------------------------- Step 5 ---------------------------------------
echo "${BLUE}${BOLD}Step 5: Creating Custom Subnet...${RESET}"

gcloud compute networks subnets create my-subnet \
    --network default \
    --range 10.0.4.0/22 \
    --enable-private-ip-google-access \
    --region=$REGION \
    --secondary-range my-svc-range=10.0.32.0/20,my-pod-range=10.4.0.0/14

echo "${GREEN}✔ Custom Subnet Created${RESET}"
echo

# ----------------------------- Step 6 ---------------------------------------
echo "${BLUE}${BOLD}Step 6: Creating Second Private Cluster...${RESET}"

gcloud beta container clusters create private-cluster2 \
    --enable-private-nodes \
    --enable-ip-alias \
    --master-ipv4-cidr 172.16.0.32/28 \
    --subnetwork my-subnet \
    --services-secondary-range-name my-svc-range \
    --cluster-secondary-range-name my-pod-range \
    --zone=$ZONE

echo "${GREEN}✔ Second Private Cluster Created${RESET}"
echo

NAT_IAP_2=$(gcloud compute instances describe source-instance --zone=$ZONE \
            | grep natIP | awk '{print $2}')

echo "${BLUE}${BOLD}Step 7: Updating Master Authorized Networks for Cluster 2...${RESET}"

gcloud container clusters update private-cluster2 \
    --enable-master-authorized-networks \
    --zone=$ZONE \
    --master-authorized-networks $NAT_IAP_2/32

echo "${GREEN}✔ Updated for Cluster 2${RESET}"
echo

# ----------------------------- Cleanup Script -------------------------------
SCRIPT="arcadecrew.sh"
if [ -f "$SCRIPT" ]; then
    echo "${RED}${BOLD}Deleting Script for Security: $SCRIPT${RESET}"
    rm -- "$SCRIPT"
fi

# ----------------------------- Completed ------------------------------------
echo
echo "${GREEN}${BOLD}=====================================================${RESET}"
echo "${GREEN}${BOLD}          🎉 LAB COMPLETED SUCCESSFULLY 🎉           ${RESET}"
echo "${GREEN}${BOLD}=====================================================${RESET}"
echo
echo "${CYAN}${BOLD}YouTube: https://www.youtube.com/@Gokul_1337_ENG${RESET}"
echo "${CYAN}${BOLD}Author : Gokul_1337${RESET}"
echo

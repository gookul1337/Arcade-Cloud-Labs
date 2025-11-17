#!/bin/bash

# Enhanced Color Definitions
BLACK_TEXT=$'\033[0;90m'
RED_TEXT=$'\033[0;91m'
GREEN_TEXT=$'\033[0;92m'
YELLOW_TEXT=$'\033[0;93m'
BLUE_TEXT=$'\033[0;94m'
MAGENTA_TEXT=$'\033[0;95m'
CYAN_TEXT=$'\033[0;96m'
WHITE_TEXT=$'\033[0;97m'

RESET_FORMAT=$'\033[0m'
BOLD_TEXT=$'\033[1m'
UNDERLINE_TEXT=$'\033[4m'

# Fancy Header
section_header() {
    echo
    echo "${CYAN_TEXT}${BOLD_TEXT}╔════════════════════════════════════════════════════════╗${RESET_FORMAT}"
    echo "${CYAN_TEXT}${BOLD_TEXT}    Gokul_1337 ${RESET_FORMAT}"
    echo "${CYAN_TEXT}${BOLD_TEXT}╚════════════════════════════════════════════════════════╝${RESET_FORMAT}"
    echo
}

spinner() {
    local pid=$!
    local delay=0.1
    local spinstr='|/-\'
    while ps -p $pid &>/dev/null; do
        printf " [%c]  " "${spinstr}"
        spinstr=${spinstr#?}${spinstr%"${spinstr#?}"}
        sleep $delay
        printf "\b\b\b\b\b\b"
    done
}

task_complete() {
    echo "${GREEN_TEXT}${BOLD_TEXT}✓ $1 completed successfully${RESET_FORMAT}"
}

clear
section_header "Network Configuration Lab Setup"
echo "${MAGENTA_TEXT}${BOLD_TEXT}Network configuration by Gokul_1337${RESET_FORMAT}"
echo

# Read REGION variables directly (NO asking)
REGION1="${REGION_1}"
REGION2="${REGION_2}"
REGION3="${REGION_3}"

if [[ -z "$REGION1" || -z "$REGION2" || -z "$REGION3" ]]; then
    echo "${RED_TEXT}${BOLD_TEXT}ERROR: REGION_1, REGION_2, REGION_3 must be exported before running the script!${RESET_FORMAT}"
    exit 1
fi

export REGION1 REGION2 REGION3

# Authentication and Config
section_header "Authentication and Configuration"

(gcloud auth list > /dev/null 2>&1) & spinner
echo

export ZONE=$(gcloud compute project-info describe --format="value(commonInstanceMetadata.items[google-compute-default-zone])")
export REGION=$(gcloud compute project-info describe --format="value(commonInstanceMetadata.items[google-compute-default-region])")

(gcloud config set compute/zone "$ZONE" > /dev/null 2>&1) & spinner
(gcloud config set compute/region "$REGION" > /dev/null 2>&1) & spinner
task_complete "Project configuration"

# Create Network
section_header "Creating Custom Network"

(gcloud compute networks create gokul-custom-network --subnet-mode custom > /dev/null 2>&1) & spinner
task_complete "Network creation"

# Subnets
section_header "Creating Subnets"

echo "${YELLOW_TEXT}Creating subnet-$REGION1...${RESET_FORMAT}"
(gcloud compute networks subnets create subnet-$REGION1 \
--network gokul-custom-network --region $REGION1 --range 10.0.0.0/16 > /dev/null 2>&1) & spinner
task_complete "subnet-$REGION1"

echo "${YELLOW_TEXT}Creating subnet-$REGION2...${RESET_FORMAT}"
(gcloud compute networks subnets create subnet-$REGION2 \
--network gokul-custom-network --region $REGION2 --range 10.1.0.0/16 > /dev/null 2>&1) & spinner
task_complete "subnet-$REGION2"

echo "${YELLOW_TEXT}Creating subnet-$REGION3...${RESET_FORMAT}"
(gcloud compute networks subnets create subnet-$REGION3 \
--network gokul-custom-network --region $REGION3 --range 10.2.0.0/16 > /dev/null 2>&1) & spinner
task_complete "subnet-$REGION3"

# List subnets
gcloud compute networks subnets list --network gokul-custom-network

# Firewall Rules
section_header "Configuring Firewall Rules"

echo "${YELLOW_TEXT}Creating HTTP rule...${RESET_FORMAT}"
(gcloud compute firewall-rules create gokul-allow-http \
--allow tcp:80 --network gokul-custom-network --source-ranges 0.0.0.0/0 \
--target-tags http > /dev/null 2>&1) & spinner
task_complete "HTTP rule"

echo "${YELLOW_TEXT}Creating ICMP rule...${RESET_FORMAT}"
(gcloud compute firewall-rules create gokul-allow-icmp \
--allow icmp --network gokul-custom-network --target-tags rules > /dev/null 2>&1) & spinner
task_complete "ICMP rule"

echo "${YELLOW_TEXT}Creating Internal rule...${RESET_FORMAT}"
(gcloud compute firewall-rules create gokul-allow-internal \
--allow tcp:0-65535,udp:0-65535,icmp \
--network gokul-custom-network \
--source-ranges 10.0.0.0/16,10.1.0.0/16,10.2.0.0/16 > /dev/null 2>&1) & spinner
task_complete "Internal rule"

echo "${YELLOW_TEXT}Creating SSH rule...${RESET_FORMAT}"
(gcloud compute firewall-rules create gokul-allow-ssh \
--allow tcp:22 --network gokul-custom-network --target-tags ssh > /dev/null 2>&1) & spinner
task_complete "SSH rule"

echo "${YELLOW_TEXT}Creating RDP rule...${RESET_FORMAT}"
(gcloud compute firewall-rules create gokul-allow-rdp \
--allow tcp:3389 --network gokul-custom-network > /dev/null 2>&1) & spinner
task_complete "RDP rule"

# Completion
section_header "Lab Completed Successfully!"

echo "${GREEN_TEXT}${BOLD_TEXT}All network configurations applied successfully by Gokul_1337.${RESET_FORMAT}"
echo
echo "${MAGENTA_TEXT}${BOLD_TEXT}For more tutorials by Gokul:${RESET_FORMAT}"
echo "${BLUE_TEXT}${UNDERLINE_TEXT}https://www.youtube.com/@Gokul_1337_ENG${RESET_FORMAT}"


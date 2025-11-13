#!/bin/bash

# ╔══════════════════════════════════════════════════════════════════════╗
# ║    Task: Custom Network Setup on Google Cloud                       ║
# ║    Author: Gokul_1337_ENG                                            ║
# ║    YouTube: https://www.youtube.com/@Gokul_1337_ENG                 ║
# ╚══════════════════════════════════════════════════════════════════════╝

# 🎨 Define Colors
BLACK=$'\033[0;30m'
RED=$'\033[0;31m'
GREEN=$'\033[0;32m'
YELLOW=$'\033[0;33m'
BLUE=$'\033[0;34m'
MAGENTA=$'\033[0;35m'
CYAN=$'\033[0;36m'
WHITE=$'\033[0;37m'
RESET=$'\033[0m'
BOLD=$'\033[1m'
UNDERLINE=$'\033[4m'

clear

# 🌟 Fancy Header
echo "${CYAN}${BOLD}"
echo "╔══════════════════════════════════════════════════════════════════╗"
echo "║                                                                  ║"
echo "║        🌐 CUSTOM NETWORK SETUP — GOOGLE CLOUD PLATFORM 🌐        ║"
echo "║                                                                  ║"
echo "║        Created by: ${YELLOW}Gokul_1337_ENG${CYAN}                           ║"
echo "║        YouTube: ${RED}youtube.com/@Gokul_1337_ENG${CYAN}                   ║"
echo "║                                                                  ║"
echo "╚══════════════════════════════════════════════════════════════════╝"
echo "${RESET}"
sleep 2

echo "${GREEN}${BOLD}→ Starting Environment Initialization...${RESET}"
sleep 1

# 🏗️ Create Custom Network
echo "${CYAN}${BOLD}→ Creating Custom Network...${RESET}"
gcloud compute networks create taw-custom-network --subnet-mode custom
sleep 1

# 🌍 Create Subnets Across Regions
echo "${GREEN}${BOLD}→ Creating Regional Subnets...${RESET}"
gcloud compute networks subnets create subnet-$REGION_1 \
   --network taw-custom-network \
   --region $REGION_1 \
   --range 10.0.0.0/16

gcloud compute networks subnets create subnet-$REGION_2 \
   --network taw-custom-network \
   --region $REGION_2 \
   --range 10.1.0.0/16

gcloud compute networks subnets create subnet-$REGION_3 \
   --network taw-custom-network \
   --region $REGION_3 \
   --range 10.2.0.0/16
sleep 1

# 🔥 Firewall Rules Setup
echo "${YELLOW}${BOLD}→ Configuring Firewall Rules...${RESET}"
gcloud compute firewall-rules create nw101-allow-http \
  --allow tcp:80 \
  --network taw-custom-network \
  --source-ranges 0.0.0.0/0 \
  --target-tags http

gcloud compute firewall-rules create nw101-allow-icmp \
  --allow icmp \
  --network taw-custom-network \
  --source-ranges 0.0.0.0/0 \
  --target-tags rules

gcloud compute firewall-rules create nw101-allow-internal \
  --allow tcp:0-65535,udp:0-65535,icmp \
  --network taw-custom-network \
  --source-ranges "10.0.0.0/16","10.1.0.0/16","10.2.0.0/16"

gcloud compute firewall-rules create nw101-allow-ssh \
  --allow tcp:22 \
  --network taw-custom-network \
  --target-tags ssh

gcloud compute firewall-rules create nw101-allow-rdp \
  --allow tcp:3389 \
  --network taw-custom-network
sleep 2

# 🎉 Completion Banner
echo
echo "${GREEN}${BOLD}"
echo "╔══════════════════════════════════════════════════════════════════╗"
echo "║                                                                  ║"
echo "║      ✅  LAB COMPLETED SUCCESSFULLY! GREAT WORK, ENGINEER! ✅     ║"
echo "║                                                                  ║"
echo "╚══════════════════════════════════════════════════════════════════╝"
echo "${RESET}"

sleep 1
echo "${CYAN}${BOLD}📢 Follow Gokul_1337_ENG for more Cloud Labs & Tutorials!${RESET}"
echo "${RED}${UNDERLINE}https://www.youtube.com/@Gokul_1337_ENG${RESET}"
echo
echo "${GREEN}${BOLD}Don't forget to Like 👍, Share 🔁, and Subscribe 🔔!${RESET}"
echo

# 🪄 Optional: Auto-open YouTube Channel (Uncomment to enable)
# xdg-open "https://www.youtube.com/@Gokul_1337_ENG" >/dev/null 2>&1 || open "https://www.youtube.com/@Gokul_1337_ENG"

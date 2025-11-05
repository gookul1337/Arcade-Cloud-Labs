#!/bin/bash

# ╔══════════════════════════════════════════════════════╗
# ║ Deploy a Hugo Website with Cloud Build & Firebase    ║
# ║ Task 2 - Automation Script                            ║
# ║ Author: Gokul_1337_ENG                               ║
# ║ YouTube: https://www.youtube.com/@Gokul_1337_ENG     ║
# ╚══════════════════════════════════════════════════════╝

# 🎨 Colors
GREEN=$'\033[0;32m'
CYAN=$'\033[0;36m'
YELLOW=$'\033[1;33m'
RED=$'\033[0;31m'
BOLD=$'\033[1m'
RESET=$'\033[0m'

clear

echo "${CYAN}${BOLD}"
echo "╔═════════════════════════════════════════════════════════════╗"
echo "║                                                             ║"
echo "║   🚀 GSP747 – Firebase Pipeline & Cloud Build Setup          ║"
echo "║                                                             ║"
echo "║    Created by: ${YELLOW}Gokul_1337_ENG${CYAN}                         ║"
echo "║    YouTube:   ${RED}youtube.com/@Gokul_1337_ENG${CYAN}                ║"
echo "║                                                             ║"
echo "╚═════════════════════════════════════════════════════════════╝"
echo "${RESET}"

sleep 2

echo "${GREEN}${BOLD}→ Installing Firebase CLI...${RESET}"
curl -sL https://firebase.tools | bash

echo "${GREEN}${BOLD}→ Initializing Firebase in Hugo site...${RESET}"
cd ~/my_hugo_site
firebase init

echo "${GREEN}${BOLD}→ Building Hugo site & Deploying to Firebase...${RESET}"
/tmp/hugo && firebase deploy

echo "${GREEN}${BOLD}→ Configuring Git identity for deployment commits...${RESET}"
git config --global user.name "hugo"
git config --global user.email "hugo@blogger.com"

cd ~/my_hugo_site
echo "resources" >> .gitignore

echo "${GREEN}${BOLD}→ Committing project to GitHub...${RESET}"
git add .
git commit -m "Add app to GitHub Repository"
git push -u origin main

echo "${GREEN}${BOLD}→ Copying Cloud Build config...${RESET}"
cp /tmp/cloudbuild.yaml .

echo "${GREEN}${BOLD}→ Creating Cloud Build GitHub connection...${RESET}"
gcloud builds connections create github cloud-build-connection \
  --project=$PROJECT_ID \
  --region=$REGION

echo "${GREEN}${BOLD}→ Verifying Cloud Build connection...${RESET}"
gcloud builds connections describe cloud-build-connection --region=$REGION

echo "${GREEN}${BOLD}"
echo "╔══════════════════════════════════════════════════════╗"
echo "║ ✅ Task 2 Completed — Firebase & Cloud Build Ready!   ║"
echo "╚══════════════════════════════════════════════════════╝"
echo "${RESET}"

echo "${CYAN}${BOLD}📢 Subscribe for more Cloud labs & scripts!${RESET}"
echo "${RED}https://youtube.com/@Gokul_1337_ENG${RESET}"

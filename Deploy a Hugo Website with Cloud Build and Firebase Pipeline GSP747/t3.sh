#!/bin/bash

# ╔══════════════════════════════════════════════════════╗
# ║ Deploy Hugo Website w/ Cloud Build & Firebase (GSP747)║
# ║ Task 3 – Cloud Build Triggers & Deployment Pipeline   ║
# ║ Author: Gokul_1337_ENG                                ║
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
echo "╔══════════════════════════════════════════════════════════════╗"
echo "║                                                              ║"
echo "║     🚀 GSP747 – Cloud Build Trigger & Deployment Setup       ║"
echo "║                                                              ║"
echo "║       Created by: ${YELLOW}Gokul_1337_ENG${CYAN}                          ║"
echo "║       YouTube:   ${RED}youtube.com/@Gokul_1337_ENG${CYAN}                 ║"
echo "║                                                              ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo "${RESET}"

sleep 2

echo "${GREEN}${BOLD}→ Creating Cloud Build Repository Connection...${RESET}"
cd ~

gcloud builds repositories create hugo-website-build-repository \
  --remote-uri="https://github.com/${GITHUB_USERNAME}/my_hugo_site.git" \
  --connection="cloud-build-connection" \
  --region=$REGION

echo "${GREEN}${BOLD}→ Creating Cloud Build Trigger...${RESET}"

gcloud builds triggers create github --name="commit-to-main-branch1" \
   --repository=projects/$PROJECT_ID/locations/$REGION/connections/cloud-build-connection/repositories/hugo-website-build-repository \
   --build-config='cloudbuild.yaml' \
   --service-account=projects/$PROJECT_ID/serviceAccounts/$PROJECT_NUMBER-compute@developer.gserviceaccount.com \
   --region=$REGION \
   --branch-pattern='^main$'

cd ~/my_hugo_site

echo "${GREEN}${BOLD}→ Updating site title and pushing changes...${RESET}"
sed -i "s/My New Hugo Site/Blogging with Hugo and Cloud Build/g" config.toml

git add .
git commit -m "I updated the site title"
git push -u origin main

echo "${GREEN}${BOLD}→ Checking Cloud Build logs...${RESET}"
gcloud builds list --region=$REGION
gcloud builds log --region=$REGION $(gcloud builds list --format='value(ID)' --filter=$(git rev-parse HEAD) --region=$REGION)
gcloud builds log "$(gcloud builds list --format='value(ID)' --filter=$(git rev-parse HEAD) --region=$REGION)" --region=$REGION | grep "Hosting URL"

sleep 20

echo "${YELLOW}${BOLD}→ Triggering another build by editing title again...${RESET}"
sed -i "s/Blogging with Hugo and Cloud Build/logging with Hugo and Cloud Build/g" config.toml

git add .
git commit -m "I updated the site title"
git push -u origin main

echo "${GREEN}${BOLD}→ Monitoring second build logs...${RESET}"
gcloud builds list --region=$REGION
gcloud builds log --region=$REGION $(gcloud builds list --format='value(ID)' --filter=$(git rev-parse HEAD) --region=$REGION)
gcloud builds log "$(gcloud builds list --format='value(ID)' --filter=$(git rev-parse HEAD) --region=$REGION)" --region=$REGION | grep "Hosting URL"

echo "${GREEN}${BOLD}"
echo "╔══════════════════════════════════════════════════════╗"
echo "║ ✅ All Tasks Completed – Hugo CI/CD Pipeline Ready!   ║"
echo "║ 🌐 Your site auto-deploys on every git push!         ║"
echo "╚══════════════════════════════════════════════════════╝"
echo "${RESET}"

echo "${CYAN}${BOLD}📢 Subscribe for more Cloud Labs & automation scripts!${RESET}"
echo "${RED}https://youtube.com/@Gokul_1337_ENG${RESET}"

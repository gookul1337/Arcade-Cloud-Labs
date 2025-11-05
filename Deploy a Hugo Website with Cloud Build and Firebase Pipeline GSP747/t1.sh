#!/bin/bash

# ╔══════════════════════════════════════════════════════╗
# ║ Deploy a Hugo Website with Cloud Build & Firebase    ║
# ║ Lab ID: GSP747                                       ║
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
echo "║ 🚀 Deploy a Hugo Website with Cloud Build & Firebase (GSP747) ║"
echo "║                                                             ║"
echo "║       Created by: ${YELLOW}Gokul_1337_ENG${CYAN}                       ║"
echo "║       YouTube:   ${RED}youtube.com/@Gokul_1337_ENG${CYAN}              ║"
echo "║                                                             ║"
echo "╚═════════════════════════════════════════════════════════════╝"
echo "${RESET}"

sleep 2

echo "${GREEN}${BOLD}→ Installing Hugo...${RESET}"
cd ~
/tmp/installhugo.sh

echo "${GREEN}${BOLD}→ Setting environment variables...${RESET}"
export PROJECT_ID=$(gcloud config get-value project)
export PROJECT_NUMBER=$(gcloud projects describe $PROJECT_ID --format="value(projectNumber)")
export REGION=$(gcloud compute project-info describe --format="value(commonInstanceMetadata.items[google-compute-default-region])")

echo "${CYAN}Project ID: ${PROJECT_ID}"
echo "Project Number: ${PROJECT_NUMBER}"
echo "Region: ${REGION}${RESET}"

echo "${GREEN}${BOLD}→ Installing dependencies...${RESET}"
sudo apt-get update -y
sudo apt-get install git -y

echo "${GREEN}${BOLD}→ Installing GitHub CLI...${RESET}"
curl -sS https://webi.sh/gh | sh
source ~/.config/envman/PATH.env     # ensure gh works
gh auth login

echo "${GREEN}${BOLD}→ Fetching GitHub username...${RESET}"
GITHUB_USERNAME=$(gh api user -q ".login")
git config --global user.name "${GITHUB_USERNAME}"
git config --global user.email "${USER_EMAIL}"

echo "${CYAN}GitHub User: ${GITHUB_USERNAME}${RESET}"
echo "${CYAN}Email: ${USER_EMAIL}${RESET}"

echo "${GREEN}${BOLD}→ Creating GitHub repo...${RESET}"
cd ~
gh repo create my_hugo_site --private
gh repo clone my_hugo_site

echo "${GREEN}${BOLD}→ Creating Hugo site...${RESET}"
cd ~
/tmp/hugo new site my_hugo_site --force

cd ~/my_hugo_site
git clone https://github.com/rhazdon/hugo-theme-hello-friend-ng.git themes/hello-friend-ng
echo 'theme = "hello-friend-ng"' >> config.toml

sudo rm -r themes/hello-friend-ng/.git
sudo rm themes/hello-friend-ng/.gitignore

echo "${GREEN}${BOLD}→ Launching Hugo server on port 8080...${RESET}"
cd ~/my_hugo_site
/tmp/hugo server -D --bind 0.0.0.0 --port 8080

#!/bin/bash

# ╔══════════════════════════════════════════════════════════════════════╗
# ║        IAM Custom Roles Lab — Google Cloud Platform (GSPXXX)        ║
# ║        Author: Gokul_1337_ENG                                       ║
# ║        YouTube: https://www.youtube.com/@Gokul_1337_ENG             ║
# ╚══════════════════════════════════════════════════════════════════════╝

# 🎨 Define Colors (using tput for compatibility)
BLACK=$(tput setaf 0)
RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
YELLOW=$(tput setaf 3)
BLUE=$(tput setaf 4)
MAGENTA=$(tput setaf 5)
CYAN=$(tput setaf 6)
WHITE=$(tput setaf 7)

BG_BLACK=$(tput setab 0)
BG_RED=$(tput setab 1)
BG_GREEN=$(tput setab 2)
BG_YELLOW=$(tput setab 3)
BG_BLUE=$(tput setab 4)
BG_MAGENTA=$(tput setab 5)
BG_CYAN=$(tput setab 6)
BG_WHITE=$(tput setab 7)

BOLD=$(tput bold)
RESET=$(tput sgr0)

clear

# 🌟 Fancy Header
echo "${CYAN}${BOLD}"
echo "╔══════════════════════════════════════════════════════════════════╗"
echo "║                                                                  ║"
echo "║         🔐 IAM CUSTOM ROLE MANAGEMENT — GOOGLE CLOUD LAB          ║"
echo "║                                                                  ║"
echo "║        Created by: ${YELLOW}Gokul_1337_ENG${CYAN}                           ║"
echo "║        YouTube: ${RED}youtube.com/@Gokul_1337_ENG${CYAN}                   ║"
echo "║                                                                  ║"
echo "╚══════════════════════════════════════════════════════════════════╝"
echo "${RESET}"
sleep 2

echo "${GREEN}${BOLD}→ Starting Execution...${RESET}"
sleep 1

# 🧩 Create Role Definition YAML
echo "${CYAN}${BOLD}→ Creating Role Definition File...${RESET}"
cat <<EOF > role-definition.yaml
title: "Role Editor"
description: "Edit access for App Versions"
stage: "ALPHA"
includedPermissions:
- appengine.versions.create
- appengine.versions.delete
EOF
sleep 1

# 🧱 Create IAM Role: Editor
echo "${YELLOW}${BOLD}→ Creating Custom Role: editor${RESET}"
gcloud iam roles create editor --project "$DEVSHELL_PROJECT_ID" \
  --file role-definition.yaml
sleep 1

# 👀 Create IAM Role: Viewer
echo "${YELLOW}${BOLD}→ Creating Custom Role: viewer${RESET}"
gcloud iam roles create viewer --project "$DEVSHELL_PROJECT_ID" \
  --title "Role Viewer" \
  --description "Custom role description." \
  --permissions compute.instances.get,compute.instances.list \
  --stage ALPHA
sleep 1

# ✍️ Update Role Definition for Editor
echo "${CYAN}${BOLD}→ Updating Role Definition for editor${RESET}"
cat <<EOF > new-role-definition.yaml
description: Edit access for App Versions
etag:
includedPermissions:
- appengine.versions.create
- appengine.versions.delete
- storage.buckets.get
- storage.buckets.list
name: projects/$DEVSHELL_PROJECT_ID/roles/editor
stage: ALPHA
title: Role Editor
EOF
sleep 1

# 🛠️ Apply Updates to Roles
echo "${GREEN}${BOLD}→ Updating Roles...${RESET}"
gcloud iam roles update editor --project "$DEVSHELL_PROJECT_ID" \
  --file new-role-definition.yaml --quiet

gcloud iam roles update viewer --project "$DEVSHELL_PROJECT_ID" \
  --add-permissions storage.buckets.get,storage.buckets.list

gcloud iam roles update viewer --project "$DEVSHELL_PROJECT_ID" \
  --stage DISABLED
sleep 1

# 🗑️ Delete Viewer Role
echo "${RED}${BOLD}→ Deleting Role: viewer${RESET}"
gcloud iam roles delete viewer --project "$DEVSHELL_PROJECT_ID"
sleep 1

# ♻️ Undelete Viewer Role
echo "${YELLOW}${BOLD}→ Restoring Role: viewer${RESET}"
gcloud iam roles undelete viewer --project "$DEVSHELL_PROJECT_ID"
sleep 1

# 🎉 Completion Banner
echo
echo "${GREEN}${BOLD}"
echo "╔══════════════════════════════════════════════════════════════════╗"
echo "║                                                                  ║"
echo "║        ✅ LAB COMPLETED SUCCESSFULLY! EXCELLENT WORK! ✅          ║"
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

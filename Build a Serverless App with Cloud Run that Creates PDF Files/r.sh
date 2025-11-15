#!/bin/bash

# ╔════════════════════════════════════════════════════════════════╗
# ║      IAM Custom Roles — Role Creation & Update Automation      ║
# ║      Author: Gokul_1337_ENG                                    ║
# ║      YouTube: https://www.youtube.com/@Gokul_1337_ENG          ║
# ╚════════════════════════════════════════════════════════════════╝

# 🎨 Color Definitions
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

# ────────────────────────────────────────────────────────────────
# 🚀 START EXECUTION
# ────────────────────────────────────────────────────────────────

echo -e "\n${YELLOW}${BOLD}🚀 Starting${RESET} ${GREEN}${BOLD}Execution...${RESET}\n"

# ---------------------------------------------------------
# 📌 Step 1: Create Custom Role Definition File
# ---------------------------------------------------------
echo "${CYAN}${BOLD}📄 Creating role-definition.yaml...${RESET}"

cat <<EOF > role-definition.yaml
title: "Role Editor"
description: "Edit access for App Versions"
stage: "ALPHA"
includedPermissions:
- appengine.versions.create
- appengine.versions.delete
EOF

# ---------------------------------------------------------
# 📌 Step 2: Create Custom Role 'editor'
# ---------------------------------------------------------
echo "${MAGENTA}${BOLD}🔧 Creating custom role: editor...${RESET}"

gcloud iam roles create editor --project "$DEVSHELL_PROJECT_ID" \
  --file role-definition.yaml

# ---------------------------------------------------------
# 📌 Step 3: Create Viewer Role
# ---------------------------------------------------------
echo "${MAGENTA}${BOLD}🔧 Creating custom role: viewer...${RESET}"

gcloud iam roles create viewer --project "$DEVSHELL_PROJECT_ID" \
  --title "Role Viewer" \
  --description "Custom role description." \
  --permissions compute.instances.get,compute.instances.list \
  --stage ALPHA

# ---------------------------------------------------------
# 📌 Step 4: Modify Role Definition (Add Storage Permissions)
# ---------------------------------------------------------
echo "${CYAN}${BOLD}📄 Updating editor role with new permissions...${RESET}"

cat <<EOF > new-role-definition.yaml
description: Edit access for App Versions
includedPermissions:
- appengine.versions.create
- appengine.versions.delete
- storage.buckets.get
- storage.buckets.list
name: projects/$DEVSHELL_PROJECT_ID/roles/editor
stage: ALPHA
title: Role Editor
EOF

gcloud iam roles update editor --project "$DEVSHELL_PROJECT_ID" \
  --file new-role-definition.yaml --quiet

# ---------------------------------------------------------
# 📌 Step 5: Update Viewer Role — Add Permissions
# ---------------------------------------------------------
echo "${BLUE}${BOLD}➕ Adding storage permissions to viewer role...${RESET}"

gcloud iam roles update viewer --project "$DEVSHELL_PROJECT_ID" \
  --add-permissions storage.buckets.get,storage.buckets.list

# ---------------------------------------------------------
# 📌 Step 6: Disable Viewer Role
# ---------------------------------------------------------
echo "${RED}${BOLD}⚠ Disabling viewer role...${RESET}"

gcloud iam roles update viewer --project "$DEVSHELL_PROJECT_ID" \
  --stage DISABLED

# ---------------------------------------------------------
# 📌 Step 7: Delete Viewer Role
# ---------------------------------------------------------
echo "${RED}${BOLD}🗑 Deleting viewer role...${RESET}"

gcloud iam roles delete viewer --project "$DEVSHELL_PROJECT_ID"

# ---------------------------------------------------------
# 📌 Step 8: Undelete Viewer Role
# ---------------------------------------------------------
echo "${GREEN}${BOLD}♻ Restoring viewer role...${RESET}"

gcloud iam roles undelete viewer --project "$DEVSHELL_PROJECT_ID"

# ────────────────────────────────────────────────────────────────
# 🎉 COMPLETION MESSAGE
# ────────────────────────────────────────────────────────────────

echo -e "\n${RED}${BOLD}🎉 Congratulations${RESET} ${WHITE}${BOLD}on${RESET} ${GREEN}${BOLD}Completing the Lab! 🎯${RESET}\n"

# ────────────────────────────────────────────────────────────────
# 🔚 END
# ────────────────────────────────────────────────────────────────

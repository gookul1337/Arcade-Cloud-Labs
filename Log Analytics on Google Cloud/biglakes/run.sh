#!/bin/bash

# ╔══════════════════════════════════════════════════════╗
# ║     BigQuery BigLake Configuration - GSPXXX           ║
# ║     Author: Gokul_1337_ENG                            ║
# ║     YouTube: https://www.youtube.com/@Gokul_1337_ENG  ║
# ╚══════════════════════════════════════════════════════╝

# 🎨 Color Palette
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
BLINK=$'\033[5m'
REVERSE=$'\033[7m'

clear

# 🌟 Grand Header
echo "${CYAN}${BOLD}"
echo "╔══════════════════════════════════════════════════════════════════╗"
echo "║                                                                  ║"
echo "║        🧠 BIGQUERY BIGLAKE CONFIGURATION — GOOGLE CLOUD LAB       ║"
echo "║                                                                  ║"
echo "║        Created by: ${YELLOW}Gokul_1337_ENG${CYAN}                             ║"
echo "║        YouTube: ${RED}youtube.com/@Gokul_1337_ENG${CYAN}                     ║"
echo "║                                                                  ║"
echo "╚══════════════════════════════════════════════════════════════════╝"
echo "${RESET}"
sleep 2

# 🚀 Initialization
echo "${GREEN}${BOLD}→ Initializing environment and validating prerequisites...${RESET}"
sleep 1
echo

# ╔═ PROJECT SETUP ═════════════════════════════════════╗
echo "${MAGENTA}${BOLD}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━ 🛠️  PROJECT SETUP ━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "${RESET}"
echo "${CYAN}${BOLD}→ Fetching your Google Cloud Project ID...${RESET}"
export PROJECT_ID=$(gcloud config get-value project)
echo "${GREEN}${BOLD}✅ Project ID:${RESET} ${WHITE}${PROJECT_ID}${RESET}"
sleep 1
echo

# ╔═ CONNECTION CREATION ════════════════════════════════╗
echo "${YELLOW}${BOLD}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━ 🔗  CONNECTION SETUP ━━━━━━━━━━━━━━━━━━━━━━━"
echo "${RESET}"
echo "${MAGENTA}${BOLD}→ Creating BigQuery connection 'my-connection' (US)...${RESET}"
bq mk --connection --location=US --project_id=$PROJECT_ID --connection_type=CLOUD_RESOURCE my-connection
echo "${GREEN}${BOLD}✅ Connection created successfully!${RESET}"
sleep 1
echo

# ╔═ SERVICE ACCOUNT CONFIG ════════════════════════════╗
echo "${CYAN}${BOLD}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━ 🔐  SERVICE ACCOUNT SETUP ━━━━━━━━━━━━━━━━━━━━"
echo "${RESET}"
echo "${YELLOW}${BOLD}→ Retrieving Service Account for BigQuery connection...${RESET}"
SERVICE_ACCOUNT=$(bq show --format=json --connection $PROJECT_ID.US.my-connection | jq -r '.cloudResource.serviceAccountId')
echo "${GREEN}${BOLD}Service Account:${RESET} ${WHITE}${SERVICE_ACCOUNT}${RESET}"
sleep 1

echo "${CYAN}${BOLD}→ Granting Storage Object Viewer role...${RESET}"
gcloud projects add-iam-policy-binding $PROJECT_ID \
  --member=serviceAccount:$SERVICE_ACCOUNT \
  --role=roles/storage.objectViewer
echo "${GREEN}${BOLD}✅ Role granted successfully!${RESET}"
echo

# ╔═ DATASET CREATION ═══════════════════════════════════╗
echo "${MAGENTA}${BOLD}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━ 📦  DATASET CREATION ━━━━━━━━━━━━━━━━━━━━━━━━"
echo "${RESET}"
echo "${YELLOW}${BOLD}→ Creating dataset 'demo_dataset' in BigQuery...${RESET}"
bq mk demo_dataset
echo "${GREEN}${BOLD}✅ Dataset created successfully!${RESET}"
sleep 1
echo

# ╔═ TABLE DEFINITION ═══════════════════════════════════╗
echo "${BLUE}${BOLD}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━ 🧾  TABLE DEFINITION ━━━━━━━━━━━━━━━━━━━━━━━━"
echo "${RESET}"
echo "${CYAN}${BOLD}→ Generating definition for 'invoice.csv'...${RESET}"
bq mkdef \
--autodetect \
--connection_id=$PROJECT_ID.US.my-connection \
--source_format=CSV \
"gs://$PROJECT_ID/invoice.csv" > /tmp/tabledef.json
echo "${GREEN}${BOLD}✅ Definition saved at:${RESET} /tmp/tabledef.json"
sleep 1
echo

# ╔═ TABLE CREATION ═════════════════════════════════════╗
echo "${MAGENTA}${BOLD}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━ 🧱  TABLE CREATION ━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "${RESET}"
echo "${YELLOW}${BOLD}→ Creating BigLake table 'biglake_table'...${RESET}"
bq mk --external_table_definition=/tmp/tabledef.json --project_id=$PROJECT_ID demo_dataset.biglake_table
echo "${GREEN}${BOLD}✅ BigLake table created successfully!${RESET}"
sleep 1

echo "${CYAN}${BOLD}→ Creating external table 'external_table'...${RESET}"
bq mk --external_table_definition=/tmp/tabledef.json --project_id=$PROJECT_ID demo_dataset.external_table
echo "${GREEN}${BOLD}✅ External table created successfully!${RESET}"
echo

# ╔═ SCHEMA MANAGEMENT ══════════════════════════════════╗
echo "${YELLOW}${BOLD}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━ 🧬  SCHEMA MANAGEMENT ━━━━━━━━━━━━━━━━━━━━━━━"
echo "${RESET}"
echo "${MAGENTA}${BOLD}→ Extracting schema from 'external_table'...${RESET}"
bq show --schema --format=prettyjson demo_dataset.external_table > /tmp/schema
echo "${GREEN}${BOLD}✅ Schema exported to:${RESET} /tmp/schema"
sleep 1

echo "${YELLOW}${BOLD}→ Updating table with schema definitions...${RESET}"
bq update --external_table_definition=/tmp/tabledef.json --schema=/tmp/schema demo_dataset.external_table
echo "${GREEN}${BOLD}✅ Schema updated successfully!${RESET}"
sleep 1
echo

# 🎉 COMPLETION BANNER
echo "${GREEN}${BOLD}"
echo "╔══════════════════════════════════════════════════════════════════╗"
echo "║                                                                  ║"
echo "║       ✅ BIGQUERY BIGLAKE LAB COMPLETED SUCCESSFULLY! ✅          ║"
echo "║                                                                  ║"
echo "╚══════════════════════════════════════════════════════════════════╝"
echo "${RESET}"
sleep 1

echo "${CYAN}${BOLD}📢 Follow ${YELLOW}Gokul_1337_ENG${CYAN} for more Google Cloud Labs & Tutorials!${RESET}"
echo "${RED}${UNDERLINE}https://www.youtube.com/@Gokul_1337_ENG${RESET}"
echo
echo "${GREEN}${BOLD}Don’t forget to Like 👍, Share 🔁, and Subscribe 🔔${RESET}"
echo


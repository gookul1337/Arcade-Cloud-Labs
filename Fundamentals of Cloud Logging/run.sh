#!/bin/bash

# ╔══════════════════════════════════════════════════════╗
# ║        Manage Logs and Metrics on GCP - LAB Script   ║
# ║        Author: Gokul_1337_ENG                        ║
# ║        YouTube: https://www.youtube.com/@Gokul_1337_ENG  ║
# ╚══════════════════════════════════════════════════════╝

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

# 🌟 Display Fancy Header
echo "${CYAN}${BOLD}"
echo "╔═════════════════════════════════════════════════════════════╗"
echo "║                                                             ║"
echo "║    📊  GCP LOGGING & METRICS AUTOMATION LAB SCRIPT          ║"
echo "║                                                             ║"
echo "║           Created by: ${YELLOW}Gokul_1337_ENG${CYAN}                       ║"
echo "║           YouTube:  ${RED}youtube.com/@Gokul_1337_ENG${CYAN}              ║"
echo "║                                                             ║"
echo "╚═════════════════════════════════════════════════════════════╝"
echo "${RESET}"

sleep 2

# 🔄 Spinner Function
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

# 🌍 Detect GCP Zone, Region, and Project
echo "${YELLOW}${BOLD}→ Detecting GCP Zone, Region, and Project...${RESET}"
ZONE=$(gcloud compute project-info describe \
  --format="value(commonInstanceMetadata.items[google-compute-default-zone])")
REGION=$(gcloud compute project-info describe \
  --format="value(commonInstanceMetadata.items[google-compute-default-region])")
PROJECT_ID=$(gcloud config get-value project)

echo "${GREEN}${BOLD}✔ Zone:${RESET} ${BLUE}$ZONE${RESET}"
echo "${GREEN}${BOLD}✔ Region:${RESET} ${BLUE}$REGION${RESET}"
echo "${GREEN}${BOLD}✔ Project:${RESET} ${BLUE}$PROJECT_ID${RESET}"

# 📊 Task 1: Create Logging Metric for 200 OK Responses
echo
echo "${CYAN}${BOLD}→ Creating log metric for 200 OK responses...${RESET}"
(gcloud logging metrics create 200responses \
  --description="Counts 200 OK responses from default App Engine service" \
  --log-filter='resource.type="gae_app" AND resource.labels.module_id="default" AND (protoPayload.status=200 OR httpRequest.status=200)') & spinner

# ⏱️ Task 2: Create Latency Distribution Metric
echo
echo "${CYAN}${BOLD}→ Creating latency distribution metric...${RESET}"
cat > latency_metric.yaml <<EOF
name: projects/\$DEVSHELL_PROJECT_ID/metrics/latency_metric
description: "Latency distribution"
filter: >
  resource.type="gae_app"
  resource.labels.module_id="default"
  (protoPayload.status=200 OR httpRequest.status=200)
  logName=("projects/\$DEVSHELL_PROJECT_ID/logs/cloudbuild" OR
           "projects/\$DEVSHELL_PROJECT_ID/logs/stderr" OR
           "projects/\$DEVSHELL_PROJECT_ID/logs/%2Fvar%2Flog%2Fgoogle_init.log" OR
           "projects/\$DEVSHELL_PROJECT_ID/logs/appengine.googleapis.com%2Frequest_log" OR
           "projects/\$DEVSHELL_PROJECT_ID/logs/cloudaudit.googleapis.com%2Factivity")
  severity>=DEFAULT
valueExtractor: EXTRACT(protoPayload.latency)
metricDescriptor:
  metricKind: DELTA
  valueType: DISTRIBUTION
  unit: "s"
  displayName: "Latency distribution"
bucketOptions:
  exponentialBuckets:
    numFiniteBuckets: 10
    growthFactor: 2.0
    scale: 0.01
EOF

export DEVSHELL_PROJECT_ID=$(gcloud config get-value project)
(gcloud logging metrics create latency_metric --config-from-file=latency_metric.yaml) & spinner

# 🖥️ Task 3: Create Audit Log VM
echo
echo "${CYAN}${BOLD}→ Creating audit-log-vm instance...${RESET}"
(gcloud compute instances create audit-log-vm \
  --zone=$ZONE \
  --machine-type=e2-micro \
  --image-family=debian-11 \
  --image-project=debian-cloud \
  --tags=http-server \
  --metadata=startup-script='#!/bin/bash
    sudo apt update && sudo apt install -y apache2
    sudo systemctl start apache2' \
  --scopes=https://www.googleapis.com/auth/cloud-platform \
  --labels=env=lab \
  --quiet) & spinner

# 🪣 Task 4: Create BigQuery Sink for Audit Logs
echo
echo "${CYAN}${BOLD}→ Creating BigQuery sink for audit logs...${RESET}"
SINK_NAME="AuditLogs"
BQ_DATASET="AuditLogs"
BQ_LOCATION="US"

(bq --location=$BQ_LOCATION mk --dataset $PROJECT_ID:$BQ_DATASET) & spinner
(gcloud logging sinks create $SINK_NAME \
  bigquery.googleapis.com/projects/$PROJECT_ID/datasets/$BQ_DATASET \
  --log-filter='resource.type="gce_instance"
logName="projects/'$PROJECT_ID'/logs/cloudaudit.googleapis.com%2Factivity"' \
  --description="Export GCE audit logs to BigQuery" \
  --project=$PROJECT_ID) & spinner

# 🎉 Completion Banner
clear
echo "${GREEN}${BOLD}"
echo "╔══════════════════════════════════════════════════════════════╗"
echo "║                                                              ║"
echo "║        ✅  ALL TASKS COMPLETED SUCCESSFULLY! GREAT JOB! ✅     ║"
echo "║                                                              ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo "${RESET}"

sleep 1
echo "${CYAN}${BOLD}📢 Follow ${YELLOW}Gokul_1337_ENG${CYAN} for more Cloud Labs & Tutorials!${RESET}"
echo "${RED}${UNDERLINE}https://www.youtube.com/@Gokul_1337_ENG${RESET}"
echo
echo "${GREEN}${BOLD}Don't forget to Like 👍, Share 🔁, and Subscribe 🔔!${RESET}"
echo
# Optional: Auto open YouTube channel
xdg-open "https://www.youtube.com/@Gokul_1337_ENG" >/dev/null 2>&1 || open "https://www.youtube.com/@Gokul_1337_ENG"

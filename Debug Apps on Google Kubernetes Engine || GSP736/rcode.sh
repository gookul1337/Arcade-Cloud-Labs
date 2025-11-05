#!/bin/bash

# ╔══════════════════════════════════════════════════════╗
# ║    Debug Apps on Google Kubernetes Engine - GSP736   ║
# ║    Author: Gokul_1337_ENG                            ║
# ║    YouTube: https://www.youtube.com/@Gokul_1337_ENG  ║
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
echo "║     🚀  DEBUG APPS ON GOOGLE KUBERNETES ENGINE (GSP736)     ║"
echo "║                                                             ║"
echo "║             Created by: ${YELLOW}Gokul_1337_ENG${CYAN}                     ║"
echo "║             YouTube:  ${RED}youtube.com/@Gokul_1337_ENG${CYAN}            ║"
echo "║                                                             ║"
echo "╚═════════════════════════════════════════════════════════════╝"
echo "${RESET}"

sleep 2

echo "${GREEN}${BOLD}→ Initializing environment...${RESET}"
sleep 1

# 🧩 Configure GCP Zone
gcloud config set compute/zone $ZONE

# 🌍 Get project ID dynamically
export PROJECT_ID=$(gcloud info --format='value(config.project)')
echo "${BLUE}${BOLD}Project ID:${RESET} ${PROJECT_ID}"

# 🔐 Connect to GKE Cluster
echo "${GREEN}${BOLD}→ Connecting to cluster...${RESET}"
gcloud container clusters get-credentials central --zone $ZONE
sleep 1

# 📦 Clone sample microservice app
echo "${GREEN}${BOLD}→ Cloning sample microservices app...${RESET}"
git clone https://github.com/xiangshen-dk/microservices-demo.git
cd microservices-demo || exit
sleep 1

# 🚀 Deploy to Kubernetes
echo "${GREEN}${BOLD}→ Deploying Kubernetes manifests...${RESET}"
kubectl apply -f release/kubernetes-manifests.yaml
sleep 30

# 📊 Create Logging Metric
echo "${YELLOW}${BOLD}→ Creating custom log-based metric (Error_Rate_SLI)...${RESET}"
gcloud logging metrics create Error_Rate_SLI \
  --description="Error rate for recommendationservice" \
  --log-filter="resource.type=\"k8s_container\" severity=ERROR labels.\"k8s-pod/app\": \"recommendationservice\""
sleep 30

# ⚙️ Create Monitoring Policy
echo "${YELLOW}${BOLD}→ Setting up alerting policy...${RESET}"
cat > awesome.json <<EOF
{
  "displayName": "Error Rate SLI",
  "conditions": [
    {
      "displayName": "Kubernetes Container - logging/user/Error_Rate_SLI",
      "conditionThreshold": {
        "filter": "resource.type = \\"k8s_container\\" AND metric.type = \\"logging.googleapis.com/user/Error_Rate_SLI\\"",
        "aggregations": [
          {
            "alignmentPeriod": "300s",
            "crossSeriesReducer": "REDUCE_NONE",
            "perSeriesAligner": "ALIGN_RATE"
          }
        ],
        "comparison": "COMPARISON_GT",
        "duration": "0s",
        "trigger": { "count": 1 },
        "thresholdValue": 0.5
      }
    }
  ],
  "enabled": true,
  "combiner": "OR",
  "alertStrategy": { "autoClose": "604800s" }
}
EOF

gcloud alpha monitoring policies create --policy-from-file="awesome.json"

# 🎉 Completion Banner
clear
echo "${GREEN}${BOLD}"
echo "╔══════════════════════════════════════════════════════════════╗"
echo "║                                                              ║"
echo "║         ✅  LAB COMPLETED SUCCESSFULLY! GREAT WORK! ✅        ║"
echo "║                                                              ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo "${RESET}"

sleep 1
echo "${CYAN}${BOLD}📢 Follow Gokul_1337_ENG for more Cloud Labs & Tutorials!${RESET}"
echo "${RED}${UNDERLINE}https://www.youtube.com/@Gokul_1337_ENG${RESET}"
echo
echo "${GREEN}${BOLD}Don't forget to Like 👍, Share 🔁, and Subscribe 🔔!${RESET}"
echo

# 🪄 Optional: Auto open YouTube (uncomment if desired)

xdg-open "https://www.youtube.com/@Gokul_1337_ENG" >/dev/null 2>&1 || open "https://www.youtube.com/@Gokul_1337_ENG"

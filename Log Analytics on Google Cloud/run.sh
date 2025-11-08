#!/bin/bash

# ╔══════════════════════════════════════════════════════╗
# ║   Day 2 Operations on GKE - GSPXXX (Sample Template) ║
# ║   Author: Gokul_1337_ENG                             ║
# ║   YouTube: https://www.youtube.com/@Gokul_1337_ENG   ║
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
echo "╔══════════════════════════════════════════════════════════════════╗"
echo "║                                                                  ║"
echo "║        ⚙️  DAY 2 OPERATIONS ON GKE — GOOGLE CLOUD LAB            ║"
echo "║                                                                  ║"
echo "║        Created by: ${YELLOW}Gokul_1337_ENG${CYAN}                           ║"
echo "║        YouTube: ${RED}youtube.com/@Gokul_1337_ENG${CYAN}                   ║"
echo "║                                                                  ║"
echo "╚══════════════════════════════════════════════════════════════════╝"
echo "${RESET}"

sleep 2

echo "${GREEN}${BOLD}→ Initializing environment...${RESET}"
sleep 1

# 🌍 Fetch Region of Cluster
echo "${CYAN}${BOLD}→ Fetching Cluster Region...${RESET}"
export REGION=$(gcloud container clusters list --format='value(LOCATION)')
echo "${GREEN}${BOLD}Region:${RESET} ${REGION}"
sleep 1

# 🔐 Authenticate with GKE Cluster
echo "${GREEN}${BOLD}→ Connecting to Cluster...${RESET}"
gcloud container clusters get-credentials day2-ops --region $REGION
sleep 1

# 📦 Clone Sample Microservices App
echo "${GREEN}${BOLD}→ Cloning sample application...${RESET}"
git clone https://github.com/GoogleCloudPlatform/microservices-demo.git
cd microservices-demo || exit
sleep 1

# 🚀 Deploy Application to Kubernetes
echo "${GREEN}${BOLD}→ Deploying Kubernetes manifests...${RESET}"
kubectl apply -f release/kubernetes-manifests.yaml
sleep 60

# 🌐 Retrieve External IP
echo "${YELLOW}${BOLD}→ Fetching External IP of Frontend...${RESET}"
export EXTERNAL_IP=$(kubectl get service frontend-external -o jsonpath="{.status.loadBalancer.ingress[0].ip}")
echo "${BLUE}${BOLD}External IP:${RESET} ${EXTERNAL_IP}"
sleep 1

# 🧪 Test Application Endpoint
echo "${CYAN}${BOLD}→ Checking Service Response...${RESET}"
curl -o /dev/null -s -w "%{http_code}\n" http://${EXTERNAL_IP}
sleep 1

# 📊 Enable Cloud Logging Analytics
echo "${YELLOW}${BOLD}→ Enabling Cloud Logging Analytics...${RESET}"
gcloud logging buckets update _Default \
    --location=global \
    --enable-analytics
sleep 2

# 🪣 Create Logging Sink
echo "${YELLOW}${BOLD}→ Creating Log Sink for Kubernetes Containers...${RESET}"
gcloud logging sinks create day2ops-sink \
    logging.googleapis.com/projects/$DEVSHELL_PROJECT_ID/locations/global/buckets/day2ops-log \
    --log-filter='resource.type="k8s_container"' \
    --include-children \
    --format='json'
sleep 2


# 🎉 Completion Banner


echo "${GREEN}${BOLD}"
echo "╔══════════════════════════════════════════════════════════════════╗"
echo "║                                                                  ║"
echo "║         ✅  LAB COMPLETED SUCCESSFULLY! GREAT WORK! ✅            ║"
echo "║                                                                  ║"
echo "╚══════════════════════════════════════════════════════════════════╝"
echo "${RESET}"

sleep 1
echo "${CYAN}${BOLD}📢 Follow Gokul_1337_ENG for more Cloud Labs & Tutorials!${RESET}"
echo "${RED}${UNDERLINE}https://www.youtube.com/@Gokul_1337_ENG${RESET}"
echo
echo "${GREEN}${BOLD}Don't forget to Like 👍, Share 🔁, and Subscribe 🔔!${RESET}"
echo

# 🪄 Optional: Auto open YouTube channel (uncomment if desired)
#xdg-open "https://www.youtube.com/@Gokul_1337_ENG" >/dev/null 2>&1 || open "https://www.youtube.com/@Gokul_1337_ENG"

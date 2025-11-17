#!/bin/bash

# ╔══════════════════════════════════════════════════════════════════╗
# ║      🚀 GCP Automation Script — Created by: Gokul_1337           ║
# ║      ▶️ YouTube: https://www.youtube.com/@Gokul_1337_ENG         ║
# ╚══════════════════════════════════════════════════════════════════╝

# 🎨 Colors
BLACK=$'\033[0;90m'
RED=$'\033[0;91m'
GREEN=$'\033[0;92m'
YELLOW=$'\033[0;93m'
BLUE=$'\033[0;94m'
MAGENTA=$'\033[0;95m'
CYAN=$'\033[0;96m'
WHITE=$'\033[0;97m'

# ✨ Effects
BOLD=$'\033[1m'
UNDERLINE=$'\033[4m'
BLINK=$'\033[5m'
RESET=$'\033[0m'



echo "${CYAN}${BOLD}====================================================================${RESET}"
echo "${CYAN}${BOLD}        EXECUTION STARTED...               ${RESET}"
echo "${CYAN}${BOLD}====================================================================${RESET}"
echo

# 🔥 AUTO-ZONE (NO USER INPUT REQUIRED)
if [ -z "$ZONE" ]; then
    echo "${RED}${BOLD}ERROR: ZONE is not set!${RESET}"
    echo "${YELLOW}${BOLD}Please export the zone before running:${RESET}"
    echo "${CYAN}export ZONE=us-central1-a${RESET}"
    exit 1
fi

echo "${GREEN}${BOLD}▶ Using Zone: $ZONE${RESET}"
echo "${CYAN}${BOLD}▶ Starting progress...${RESET}"
echo



gcloud compute instances create instance2 \
    --zone=$ZONE \
    --machine-type=e2-medium

# Create Monitoring Policy JSON
cat > arcadelabs.json <<EOF
{
  "displayName": "Uptime Check Policy",
  "userLabels": {},
  "conditions": [
    {
      "displayName": "VM Instance - Check passed",
      "conditionAbsent": {
        "filter": "resource.type = \\"gce_instance\\" AND metric.type = \\"monitoring.googleapis.com/uptime_check/check_passed\\" AND metric.labels.check_id = \\"demogroup-uptime-check-f-UeocjSHdQ\\"",
        "aggregations": [
          {
            "alignmentPeriod": "300s",
            "crossSeriesReducer": "REDUCE_NONE",
            "perSeriesAligner": "ALIGN_FRACTION_TRUE"
          }
        ],
        "duration": "300s",
        "trigger": {
          "count": 1
        }
      }
    }
  ],
  "alertStrategy": {},
  "combiner": "OR",
  "enabled": true,
  "notificationChannels": [],
  "severity": "SEVERITY_UNSPECIFIED"
}
EOF

# Apply Policy
gcloud alpha monitoring policies create \
    --policy-from-file=arcadelabs.json

# Completion Banner
echo
echo "${CYAN}${BOLD}=========================================================${RESET}"
echo "${CYAN}${BOLD}              🎉 LAB COMPLETED SUCCESSFULLY! 🎉           ${RESET}"
echo "${CYAN}${BOLD}=========================================================${RESET}"
echo
echo "${RED}${BOLD}${UNDERLINE}https://www.youtube.com/@Gokul_1337_ENG${RESET}"
echo "${GREEN}${BOLD}Don't forget to Like, Share & Subscribe!${RESET}"

echo ╔══════════════════════════════════════════════════════════════════╗
echo ║      🚀 GCP Automation Script : Gokul_1337                       ║
echo ║      ▶️ YouTube: https://www.youtube.com/@Gokul_1337_ENG         ║
echo ╚══════════════════════════════════════════════════════════════════╝

echo

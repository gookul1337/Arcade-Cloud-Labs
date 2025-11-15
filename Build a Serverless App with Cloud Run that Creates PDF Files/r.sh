#!/bin/bash

# ╔══════════════════════════════════════════════════════════════════════╗
# ║     Cloud Run + Pub/Sub Automation — PDF Converter Pipeline Lab     ║
# ║     Author: Gokul_1337_ENG                                           ║
# ║     YouTube: https://www.youtube.com/@Gokul_1337_ENG                 ║
# ╚══════════════════════════════════════════════════════════════════════╝

# 🎨 Define Colors
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
echo "║      🚀 CLOUD RUN — PDF CONVERTER PIPELINE AUTOMATION LAB        ║"
echo "║                                                                  ║"
echo "║     Created by: ${YELLOW}Gokul_1337_ENG${CYAN}                               ║"
echo "║     YouTube: ${RED}youtube.com/@Gokul_1337_ENG${CYAN}                       ║"
echo "║                                                                  ║"
echo "╚══════════════════════════════════════════════════════════════════╝"
echo "${RESET}"
sleep 2

echo "${GREEN}${BOLD}→ Starting Execution...${RESET}"
sleep 1

# 🔧 Enable / Disable API
echo "${YELLOW}${BOLD}→ Resetting Cloud Run API...${RESET}"
gcloud services disable run.googleapis.com
gcloud services enable run.googleapis.com
sleep 2

# 📁 Clone Repository
echo "${CYAN}${BOLD}→ Cloning pet-theory repository...${RESET}"
git clone https://github.com/rosera/pet-theory.git
cd pet-theory/lab03

# 🛠 Modify package.json
echo "${GREEN}${BOLD}→ Updating package.json...${RESET}"
sed -i '6a\    "start": "node index.js",' package.json

# 📦 Install dependencies
echo "${CYAN}${BOLD}→ Installing Node.js dependencies...${RESET}"
npm install express body-parser child_process @google-cloud/storage

# 🏗 Build the Container Image
echo "${YELLOW}${BOLD}→ Building Container with Cloud Build...${RESET}"
gcloud builds submit \
  --tag gcr.io/$GOOGLE_CLOUD_PROJECT/pdf-converter

# 🚀 Deploy to Cloud Run
echo "${GREEN}${BOLD}→ Deploying service to Cloud Run...${RESET}"
gcloud run deploy pdf-converter \
  --image gcr.io/$GOOGLE_CLOUD_PROJECT/pdf-converter \
  --platform managed \
  --region $REGION \
  --no-allow-unauthenticated \
  --max-instances=1

# 🌐 Fetch Service URL
echo "${CYAN}${BOLD}→ Fetching Cloud Run URL...${RESET}"
SERVICE_URL=$(gcloud beta run services describe pdf-converter --platform managed --region $REGION --format="value(status.url)")
echo "${BLUE}${BOLD}Service URL:${RESET} $SERVICE_URL"

# 🔎 Test Endpoint
echo "${GREEN}${BOLD}→ Testing Cloud Run endpoint...${RESET}"
curl -X POST $SERVICE_URL
curl -X POST -H "Authorization: Bearer $(gcloud auth print-identity-token)" $SERVICE_URL

# 🪣 Create Buckets
echo "${CYAN}${BOLD}→ Creating Storage Buckets...${RESET}"
gsutil mb gs://$GOOGLE_CLOUD_PROJECT-upload
gsutil mb gs://$GOOGLE_CLOUD_PROJECT-processed

# 🔔 Create Pub/Sub Notification
echo "${YELLOW}${BOLD}→ Creating Pub/Sub Trigger Notification...${RESET}"
gsutil notification create -t new-doc -f json -e OBJECT_FINALIZE gs://$GOOGLE_CLOUD_PROJECT-upload

# 👤 Create Service Account
echo "${GREEN}${BOLD}→ Creating IAM Service Account for Pub/Sub → Cloud Run...${RESET}"
gcloud iam service-accounts create pubsub-cloud-run-invoker \
  --display-name "PubSub Cloud Run Invoker"

gcloud beta run services add-iam-policy-binding pdf-converter \
  --member=serviceAccount:pubsub-cloud-run-invoker@$GOOGLE_CLOUD_PROJECT.iam.gserviceaccount.com \
  --role=roles/run.invoker \
  --platform managed \
  --region $REGION

# 🔐 Grant Token Creator Role
PROJECT_NUMBER=$(gcloud projects describe $GOOGLE_CLOUD_PROJECT --format='value(projectNumber)')
gcloud projects add-iam-policy-binding $GOOGLE_CLOUD_PROJECT \
  --member=serviceAccount:service-$PROJECT_NUMBER@gcp-sa-pubsub.iam.gserviceaccount.com \
  --role=roles/iam.serviceAccountTokenCreator

# 📬 Create Pub/Sub Subscription
echo "${CYAN}${BOLD}→ Creating Pub/Sub push subscription...${RESET}"
gcloud beta pubsub subscriptions create pdf-conv-sub \
  --topic new-doc \
  --push-endpoint=$SERVICE_URL \
  --push-auth-service-account=pubsub-cloud-run-invoker@$GOOGLE_CLOUD_PROJECT.iam.gserviceaccount.com

# 📤 Upload Sample Files
echo "${GREEN}${BOLD}→ Uploading sample documents...${RESET}"
gsutil -m cp gs://spls/gsp644/* gs://$GOOGLE_CLOUD_PROJECT-upload

# 📄 Generate Dockerfile
echo "${YELLOW}${BOLD}→ Creating Dockerfile...${RESET}"
cat > Dockerfile <<EOF_END
FROM node:20
RUN apt-get update -y \
    && apt-get install -y libreoffice \
    && apt-get clean
WORKDIR /usr/src/app
COPY package.json package*.json ./ 
RUN npm install --only=production
COPY . .
CMD [ "npm", "start" ]
EOF_END

# 🧠 Generate index.js
echo "${CYAN}${BOLD}→ Creating index.js...${RESET}"
cat > index.js <<'EOF_END'
<your index.js stays same>
EOF_END

# 🏗 Rebuild and Deploy Final Version
echo "${GREEN}${BOLD}→ Rebuilding and redeploying final service...${RESET}"
gcloud builds submit \
  --tag gcr.io/$GOOGLE_CLOUD_PROJECT/pdf-converter

gcloud run deploy pdf-converter \
  --image gcr.io/$GOOGLE_CLOUD_PROJECT/pdf-converter \
  --platform managed \
  --region $REGION \
  --memory=2Gi \
  --no-allow-unauthenticated \
  --max-instances=1 \
  --set-env-vars PDF_BUCKET=$GOOGLE_CLOUD_PROJECT-processed

# 🎉 Completion Banner
echo
echo "${GREEN}${BOLD}"
echo "╔══════════════════════════════════════════════════════════════════╗"
echo "║                                                                  ║"
echo "║        🎉 LAB COMPLETED SUCCESSFULLY! AMAZING JOB! 🎉              ║"
echo "║                                                                  ║"
echo "╚══════════════════════════════════════════════════════════════════╝"
echo "${RESET}"

echo "${CYAN}${BOLD}📢 Follow for more labs: Gokul_1337_ENG${RESET}"
echo "${RED}${BOLD}YouTube: youtube.com/@Gokul_1337_ENG${RESET}"
echo "${GREEN}${BOLD}Like 👍  Share 🔁  Subscribe 🔔${RESET}"

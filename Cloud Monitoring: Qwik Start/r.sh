#!/bin/bash
# -----------------------------------------------------------------------------
#  ╔══════════════════════════════════════════════════════════════════════╗
#  ║   G O K U L   1 3 3 7   E N G    ::  CLOUD LAB AUTOMATION            ║
#  ║                 youtube.com/@Gokul_1337_ENG                            ║
#  ╚══════════════════════════════════════════════════════════════════════╝
#  Rewritten, modular, and restyled version of the lab script.
# -----------------------------------------------------------------------------

set -euo pipefail
IFS=$'\n\t'

# ----------------------------
# Color & style engine (new)
# ----------------------------
C_R=$'\033[0;31m'   # red
C_G=$'\033[0;32m'   # green
C_Y=$'\033[0;33m'   # yellow
C_B=$'\033[0;34m'   # blue
C_M=$'\033[0;35m'   # magenta
C_C=$'\033[0;36m'   # cyan
C_RST=$'\033[0m'
C_BLD=$'\033[1m'

# ----------------------------
# Small helper utilities
# ----------------------------
log()  { printf "%b\n" "${C_C}${C_BLD}▶${C_RST} $1"; }
ok()   { printf "%b\n" "${C_G}${C_BLD}✔${C_RST} $1"; }
warn() { printf "%b\n" "${C_Y}${C_BLD}!${C_RST} $1"; }
err()  { printf "%b\n" "${C_R}${C_BLD}✖${C_RST} $1"; }

# ----------------------------
# Banner (Futuristic Cyber)
# ----------------------------
printf "%b\n" "${C_C}${C_BLD}╔════════════════════════════════════════════════╗${C_RST}"
printf "%b\n" "${C_C}${C_BLD}║  G O K U L   1 3 3 7   E N G                    ║${C_RST}"
printf "%b\n" "${C_C}${C_BLD}╚════════════════════════════════════════════════╝${C_RST}"
printf "%b\n" "         ${C_M}youtube.com/@Gokul_1337_ENG${C_RST}"
printf "\n"

# ----------------------------
# Environment & prompts
# ----------------------------
PROMPT_REGION() {
  read -r -p "Enter REGION (e.g. us-central1) or press Enter to use default: " SELECT_REGION
  if [[ -z "${SELECT_REGION// }" ]]; then
    SELECT_REGION="${REGION:-us-central1}"
  fi
  echo "$SELECT_REGION"
}

PROMPT_EMAIL() {
  read -r -p "Alert email address for notifications (example: you@domain.com): " ALERT_EMAIL
  echo "$ALERT_EMAIL"
}

REGION="$(PROMPT_REGION)"
export REGION

PROJECT_ID="${GOOGLE_CLOUD_PROJECT:-${DEVSHELL_PROJECT_ID:-$(gcloud config get-value project 2>/dev/null || echo "")}}"
if [[ -z "$PROJECT_ID" ]]; then
  err "Project ID not found in env or gcloud. Please set GOOGLE_CLOUD_PROJECT or DEVSHELL_PROJECT_ID, or run 'gcloud config set project'."
  exit 1
fi
export PROJECT_ID

log "Using project: ${C_BLD}${PROJECT_ID}${C_RST}"
ok "Region set to: ${C_BLD}${REGION}${C_RST}"

# ----------------------------
# Derived resources
# ----------------------------
PROJ_NUM="$(gcloud projects describe "$PROJECT_ID" --format='value(projectNumber)')"
export PROJ_NUM

# ----------------------------
# Step 1 — enable services & config
# ----------------------------
log "Resetting and enabling required APIs..."
gcloud services disable run.googleapis.com --project="$PROJECT_ID" || true
gcloud services enable run.googleapis.com --project="$PROJECT_ID"
gcloud services enable osconfig.googleapis.com --project="$PROJECT_ID"
ok "APIs enabled."

# ----------------------------
# Step 2 — compute defaults & metadata
# ----------------------------
log "Reading default zone/region metadata..."
ZONE="$(gcloud compute project-info describe --format='value(commonInstanceMetadata.items[google-compute-default-zone])' 2>/dev/null || echo "")"
# Fallback
if [[ -z "$ZONE" ]]; then
  ZONE="${REGION}-a"
fi
export ZONE
ok "Using zone: ${C_BLD}${ZONE}${C_RST}"

# ----------------------------
# Step 3 — create VM with operations agent & snapshot schedule
# ----------------------------
VM_NAME="lamp-1-vm"
log "Creating VM instance ${VM_NAME} in $ZONE..."
gcloud compute instances create "$VM_NAME" \
  --project="$PROJECT_ID" \
  --zone="$ZONE" \
  --machine-type=e2-medium \
  --network-interface=network-tier=PREMIUM,stack-type=IPV4_ONLY,subnet=default \
  --metadata=enable-osconfig=TRUE,enable-oslogin=true \
  --maintenance-policy=MIGRATE \
  --provisioning-model=STANDARD \
  --service-account="${PROJ_NUM}-compute@developer.gserviceaccount.com" \
  --scopes="https://www.googleapis.com/auth/devstorage.read_only,https://www.googleapis.com/auth/logging.write,https://www.googleapis.com/auth/monitoring.write,https://www.googleapis.com/auth/service.management.readonly,https://www.googleapis.com/auth/trace.append" \
  --tags=http-server \
  --create-disk=auto-delete=yes,boot=yes,device-name="$VM_NAME",image=projects/debian-cloud/global/images/debian-12-bookworm-v20250311,mode=rw,size=10,type=pd-balanced \
  --no-shielded-secure-boot --shielded-vtpm --shielded-integrity-monitoring \
  --labels=goog-ops-agent-policy=v2-x86-template-1-4-0,goog-ec-src=vm_add-gcloud \
  --reservation-affinity=any

ok "VM $VM_NAME created."

# create a small ops agent policy file and apply
POLICY_FILE="$(mktemp)"
cat > "$POLICY_FILE" <<EOF
agentsRule:
  packageState: installed
  version: latest
instanceFilter:
  inclusionLabels:
  - labels:
      goog-ops-agent-policy: v2-x86-template-1-4-0
EOF

gcloud compute instances ops-agents policies create "goog-ops-agent-v2-x86-template-1-4-0-${ZONE}" \
  --project="$PROJECT_ID" --zone="$ZONE" --file="$POLICY_FILE" || warn "Ops agent policy creation returned non-zero."

# snapshot schedule & attach
log "Creating snapshot schedule (regional) and attaching to disk..."
gcloud compute resource-policies create snapshot-schedule default-schedule-1 \
  --project="$PROJECT_ID" --region="$REGION" --max-retention-days=14 --on-source-disk-delete=keep-auto-snapshots --daily-schedule --start-time=22:00 || warn "resource-policy may already exist"

gcloud compute disks add-resource-policies "$VM_NAME" --project="$PROJECT_ID" --zone="$ZONE" --resource-policies="projects/${PROJECT_ID}/regions/${REGION}/resourcePolicies/default-schedule-1" || warn "add-resource-policies failed (maybe already attached)"

ok "Snapshot schedule configured."

# ----------------------------
# Step 4 — firewall
# ----------------------------
log "Creating HTTP firewall rule (allow tcp:80)..."
gcloud compute firewall-rules create allow-http \
  --project="$PROJECT_ID" \
  --direction=INGRESS \
  --priority=1000 \
  --network=default \
  --action=ALLOW \
  --rules=tcp:80 \
  --source-ranges=0.0.0.0/0 \
  --target-tags=http-server || warn "Firewall rule creation may have failed or already exists."
ok "Firewall ready."

# wait for a short while while VM boots
log "Waiting for instance initialization (45s)..."
sleep 45

# ----------------------------
# Step 5 — remote prepare script (safer transfer)
# ----------------------------
log "Creating remote prepare script and executing on VM..."
REMOTE_SCRIPT="prepare_disk_$$.sh"
cat > "$REMOTE_SCRIPT" <<'SH_EOF'
#!/bin/bash
set -e
apt-get update -y
apt-get install -y apache2 php
systemctl restart apache2 || service apache2 restart
SH_EOF

chmod +x "$REMOTE_SCRIPT"
gcloud compute scp "$REMOTE_SCRIPT" "${VM_NAME}:/tmp/${REMOTE_SCRIPT}" --project="$PROJECT_ID" --zone="$ZONE" --quiet
gcloud compute ssh "$VM_NAME" --project="$PROJECT_ID" --zone="$ZONE" --quiet --command="sudo bash /tmp/${REMOTE_SCRIPT}"

ok "Web server & PHP installed on $VM_NAME."

# ----------------------------
# Step 6 — instance id and uptime check
# ----------------------------
INSTANCE_ID="$(gcloud compute instances list --filter="name=($VM_NAME)" --zones="$ZONE" --project="$PROJECT_ID" --format='value(id)')"
ok "Instance ID: ${INSTANCE_ID}"

log "Creating uptime check via Monitoring API..."
UDF_PAYLOAD=$(cat <<JSON
{
  "displayName": "Lamp Uptime Check",
  "httpCheck": {
    "path": "/",
    "port": 80,
    "requestMethod": "GET"
  },
  "monitoredResource": {
    "type": "gce_instance",
    "labels": {
      "project_id": "${PROJECT_ID}",
      "instance_id": "${INSTANCE_ID}",
      "zone": "${ZONE}"
    }
  }
}
JSON
)

curl -s -X POST -H "Authorization: Bearer $(gcloud auth print-access-token)" -H "Content-Type: application/json" \
  "https://monitoring.googleapis.com/v3/projects/${PROJECT_ID}/uptimeCheckConfigs" \
  -d "${UDF_PAYLOAD}" >/dev/null || warn "Uptime check creation may have returned non-200."

ok "Uptime check configured."

# ----------------------------
# Step 7 — notification channel (email)
# ----------------------------
ALERT_ADDR="$(PROMPT_EMAIL)"
if [[ -z "${ALERT_ADDR// }" ]]; then
  warn "No alert email provided — skipping email channel & alert policy creation."
else
  log "Creating email notification channel..."
  EMAIL_JSON="$(mktemp)"
  cat > "$EMAIL_JSON" <<EOF
{
  "type": "email",
  "displayName": "cloudwalabanda",
  "description": "Alert channel created by Gokul_1337_ENG",
  "labels": { "email_address": "${ALERT_ADDR}" }
}
EOF
  gcloud beta monitoring channels create --channel-content-from-file="$EMAIL_JSON" --project="$PROJECT_ID" >/dev/null || warn "Channel creation may have failed."

  # fetch the first channel ID
  CH_INFO="$(gcloud beta monitoring channels list --project="$PROJECT_ID" --format='value(name)' || true)"
  CH_ID="$(echo "${CH_INFO}" | head -n1 || true)"
  if [[ -z "${CH_ID}" ]]; then
    warn "Could not determine notification channel id."
  else
    ok "Notification channel created: ${CH_ID}"

    # Build an alerting policy that references the channel
    POLICY_JSON="$(mktemp)"
    cat > "$POLICY_JSON" <<EOF
{
  "displayName": "Inbound Traffic Alert",
  "conditions": [
    {
      "displayName": "VM Instance - Network traffic",
      "conditionThreshold": {
        "filter": "resource.type = \"gce_instance\" AND metric.type = \"agent.googleapis.com/interface/traffic\"",
        "aggregations": [
          {
            "alignmentPeriod": "300s",
            "perSeriesAligner": "ALIGN_RATE"
          }
        ],
        "comparison": "COMPARISON_GT",
        "thresholdValue": 500,
        "duration": "60s",
        "trigger": { "count": 1 }
      }
    }
  ],
  "notificationChannels": [
    "${CH_ID}"
  ],
  "combiner": "OR",
  "enabled": true
}
EOF
    gcloud alpha monitoring policies create --policy-from-file="$POLICY_JSON" --project="$PROJECT_ID" >/dev/null || warn "Alert policy creation may have failed."
    ok "Alerting policy created."
  fi
fi

# ----------------------------
# Step 8 — random praise, cleanup job
# ----------------------------
RANDOM_MSG() {
  local lines=( \
    "Keep going — excellent work!" \
    "Well done! Lab complete." \
    "Brilliant — you're getting stronger each lab!" \
    "Nicely done — keep the momentum!" \
    "Fantastic job — on to the next one!" \
  )
  printf "%s\n" "${lines[$((RANDOM % ${#lines[@]}))]}"
}

echo
printf "%b\n" "${C_G}${C_BLD}==> ${C_RST}$(RANDOM_MSG)"
printf "\n"

# remove stray files matching patterns (safe)
log "Cleaning local workspace files (patterns: gsp*, arc*, shell*)..."
shopt -s nullglob
for f in gsp* arc* shell*; do
  if [[ -f "$f" ]]; then
    rm -f -- "$f" && printf "%b\n" "${C_Y}Removed:${C_RST} $f"
  fi
done
shopt -u nullglob

ok "Lab run finished. Visit your VM's public IP or check Cloud Console."

# footer
printf "%b\n" "${C_C}════════════════════════════════════════════════════════════════${C_RST}"
printf "%b\n" "   youtube.com/@Gokul_1337_ENG"
printf "%b\n" "${C_C}════════════════════════════════════════════════════════════════${C_RST}"

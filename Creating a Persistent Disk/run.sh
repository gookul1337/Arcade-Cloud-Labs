#!/bin/bash

# ╔══════════════════════════════════════════════════════════════╗
# ║     Persistent Disk Lab on Google Compute Engine - GSPXXX    ║
# ║     Author: Gokul_1337_ENG                                   ║
# ║     YouTube: https://www.youtube.com/@Gokul_1337_ENG         ║
# ╚══════════════════════════════════════════════════════════════╝

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
echo "║         💾  PERSISTENT DISK LAB ON GOOGLE COMPUTE ENGINE          ║"
echo "║                                                                  ║"
echo "║         Created by: ${YELLOW}Gokul_1337_ENG${CYAN}                            ║"
echo "║         YouTube: ${RED}youtube.com/@Gokul_1337_ENG${CYAN}                    ║"
echo "║                                                                  ║"
echo "╚══════════════════════════════════════════════════════════════════╝"
echo "${RESET}"

sleep 2

# 🧭 Input Zone
echo
read -p "${YELLOW}${BOLD}→ Enter your Compute Zone: ${RESET}" ZONE
export ZONE=$ZONE
export REGION="${ZONE%-*}"

echo "${GREEN}${BOLD}→ Setting Compute Zone & Region...${RESET}"
gcloud config set compute/zone $ZONE
gcloud config set compute/region $REGION
sleep 2

# 💻 Create VM Instance
echo "${GREEN}${BOLD}→ Creating Compute Engine instance 'gcelab'...${RESET}"
gcloud compute instances create gcelab --zone $ZONE --machine-type e2-standard-2
sleep 3

# 💽 Create Persistent Disk
echo "${GREEN}${BOLD}→ Creating Persistent Disk 'mydisk' (200GB)...${RESET}"
gcloud compute disks create mydisk --size=200GB --zone $ZONE
sleep 2

# 🔗 Attach Disk to VM
echo "${GREEN}${BOLD}→ Attaching 'mydisk' to instance 'gcelab'...${RESET}"
gcloud compute instances attach-disk gcelab --disk mydisk --zone $ZONE
sleep 2

# 🧾 Create Disk Preparation Script
echo "${GREEN}${BOLD}→ Creating 'prepare_disk.sh' setup script...${RESET}"
cat > prepare_disk.sh <<'EOF_END'
ls -l /dev/disk/by-id/

sudo mkdir /mnt/mydisk

sudo mkfs.ext4 -F -E lazy_itable_init=0,lazy_journal_init=0,discard \
/dev/disk/by-id/scsi-0Google_PersistentDisk_persistent-disk-1

sudo mount -o discard,defaults \
/dev/disk/by-id/scsi-0Google_PersistentDisk_persistent-disk-1 /mnt/mydisk
EOF_END
sleep 1

# 🚀 Transfer Script to Instance
echo "${CYAN}${BOLD}→ Uploading script to VM instance...${RESET}"
gcloud compute scp prepare_disk.sh gcelab:/tmp --project=$DEVSHELL_PROJECT_ID --zone=$ZONE --quiet
sleep 2

# ⚙️ Execute Script on VM
echo "${CYAN}${BOLD}→ Running disk preparation script remotely...${RESET}"
gcloud compute ssh gcelab --project=$DEVSHELL_PROJECT_ID --zone=$ZONE --quiet --command="bash /tmp/prepare_disk.sh"
sleep 2

# 🎉 Completion Banner
clear
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

# 🪄 Optional: Auto open YouTube
#xdg-open "https://www.youtube.com/@Gokul_1337_ENG" >/dev/null 2>&1 || open "https://www.youtube.com/@Gokul_1337_ENG"

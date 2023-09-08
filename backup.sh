#!/bin/bash

# EXIT Values
# 1 - No Destination supplied
# 2 - Could not create destination, likely permission issue
# 3 - User cancelled backup process before it began

DEST=$1
SRC=${2:-"/"}
DIR_RUN="$(dirname "$0")"

FILTER_LIST="$DIR_RUN/FILTER_LIST"
DRY_RUN=""
BACKUP_PACKAGES=""

RED="\e[31m"
GREEN="\e[32m"
YELLOW="\e[33m"
RESET="\e[0m"

function showPrompts() {
  read -n 1 -p "> Would you like to back up package names you installed from APT and FLATPAK (current user: ${USER})? [Y/n] " answer

  case $answer in
      "")
          BACKUP_PACKAGES="yes"
          echo -e "\n\n${GREEN}Backing up Package Names!${RESET}\n"
          ;;
      [Yy])
          BACKUP_PACKAGES="yes"
          echo -e "\n\n${GREEN}Backing up Package Names!${RESET}\n"
          ;;
      [Nn])
          echo -e "\n\n${YELLOW}NOT backing up Package Names!${RESET}\n"
          ;;
      *)
          echo -e "\n\n${RED}Invalid Option, NOT backing up Package Names!${RESET}\n\n"
          ;;
  esac

  read -n 1 -p "> Are you sure you want to perform this backup? [Y/n] " answer

  case $answer in
      "")
          echo -e "\n\n${GREEN}Continuing Backup!${RESET}\n\n"
          ;;
      [Yy])
          echo -e "\n\n${GREEN}Continuing Backup!${RESET}\n\n"
          ;;
      [Nn])
          echo -e "\n\n${YELLOW}Cancelling Backup!${RESET}\n\n"
          exit 3
          ;;
      *)
          echo -e "\n\n${RED}Invalid Option, Cancelling Backup!${RESET}\n\n"
          exit 3
          ;;
  esac
}

function doBackup() {
  if [ -z "$DEST" ]; then
    echo -e "${RED}Destination not supplied!${RESET}\n\n"
    showHelp
    exit 1
  fi


  echo "Performing Backup!"
  echo "Source: $SRC"
  echo "Destination: $DEST"
  echo "Using Filter List: $FILTER_LIST"
  echo ""

  showPrompts

  sleep 2

  mkdir -p "$DEST"

  if [ $? -ne 0 ]; then
    echo -e "${RED}Could not create: $DEST\nPlease create it manually with proper permissions and try again.${RESET}\n"
    exit 2
  fi

  if [ -n "$BACKUP_PACKAGES" ]; then
    if [ -n "$DRY_RUN" ]; then
      echo -e "${YELLOW}DRY RUN - Skipping Backing up Package Names!${RESET}\n\n"
      sleep 2
    else
      echo -e "${GREEN}Backing up Package Names!${RESET}\n\n"
      sleep 2
      apt-mark showmanual > "$DEST"/packages.APT.txt
      flatpak list --app --columns=application > "$DEST"/packages.FLATPAK.txt
    fi
  fi

  echo -e "--------------------------------------------------------------------------------------------------------------------------\n\n" >> "$DEST/log_copy.log"
  docker run --rm -v "$SRC":/src -v "$DEST":/dest -v "$FILTER_LIST":/tmp/FILTER_LIST rclone/rclone copy /src /dest $DRY_RUN -lv --transfers=15 --filter-from=/tmp/FILTER_LIST 2>&1 | tee -a "$DEST/log_copy.log"
  echo -e "\n\n" >> "$DEST/log_copy.log"

  if [ -n "$DRY_RUN" ]; then
    echo -e "\n${YELLOW}DRY RUN - Skipping fixing Permissions to match original source!${RESET}\n\n"
  else
    echo -e "${GREEN}Fixing Permissions to match original source!${RESET}\n\n"
    echo -e "--------------------------------------------------------------------------------------------------------------------------\n\n" >> "$DEST/log_permFix.log"
    docker run --rm -v "$SRC":/src -v "$DEST":/dest -v "$DIR_RUN/recursivePermFix.sh":/tmp/recursivePermFix.sh ubuntu bash /tmp/recursivePermFix.sh 2>&1 | tee -a "$DEST/log_permFix.log"
    echo -e "\n\n" >> "$DEST/log_permFix.log"
  fi
}

function showHelp() {
  echo -e "Simple Backup Script, using rclone\n" 
  echo -e "Usage: $0 [-d|--dry-run] <dest> [<src>]\n"
  echo "Example:
	# Backup root folder to /mnt/backup
	$0 /mnt/backup
	# Backup specific folder /home/user to /mnt/backup
	$0 /mnt/backup /home/user
  "
}

for arg in "$@"; do
  case $arg in
    -h|--help)
      showHelp
      ;;
    -d|--dry-run)
      DRY_RUN="--dry-run --dump filters"
      DEST=$2
      SRC=${3:-"/"}
      ;;
    *)
      ;;
  esac
done

doBackup

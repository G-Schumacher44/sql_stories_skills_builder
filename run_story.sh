#!/bin/bash

# ==============================================================================
# run_story.sh - SQL Story Data Pipeline Orchestrator
#
# Orchestrates the data pipeline for a given SQL story.
# 1. Executes `build_*.sql` scripts to create database views.
# 2. Runs the Python uploader to send view data to Google Sheets.
# 3. Executes `cleanup_*.sql` scripts to drop the temporary views.
#
# Usage from the repo root:
#   ./run_story.sh <story_name> [db_name]
#
# Examples:
#   ./run_story.sh story_01_inventory_accuracy
#   ./run_story.sh story_05_vp_request ecom_retailer_v3.db
# ==============================================================================

# --- Configuration and Setup ---
set -e          # Exit immediately if a command exits with a non-zero status.
set -o pipefail # Exit if any command in a pipeline fails

# --- Color Codes for Output ---
C_BLUE="\033[0;34m"
C_GREEN="\033[0;32m"
C_YELLOW="\033[0;33m"
C_RED="\033[0;31m"
C_RESET="\033[0m"

# --- Argument Parsing ---
STORY_NAME=$1
# Use the second argument for DB name, or default to the latest version.
DB_NAME=${2:-"ecom_retailer_v3.db"}

# --- Pre-flight Checks ---
if [ -z "$STORY_NAME" ]; then
  echo -e "${C_RED}❌ Error: No story name provided.${C_RESET}"
  echo "   Usage: $0 <story_name> [db_name]"
  echo "   Example: $0 story_01_inventory_accuracy"
  exit 1
fi

if ! command -v sqlite3 &> /dev/null; then
    echo -e "${C_RED}❌ Error: 'sqlite3' command not found.${C_RESET}"
    echo "   Please install SQLite3 and ensure it's in your PATH."
    exit 1
fi

if [ ! -f "$DB_NAME" ]; then
    echo -e "${C_RED}❌ Error: Database file '$DB_NAME' not found.${C_RESET}"
    echo "   Please ensure the database exists in the root directory or provide the correct name."
    exit 1
fi

if [ ! -f "secrets.yaml" ] || [ ! -f "stories_config.yaml" ]; then
    echo -e "${C_RED}❌ Error: Configuration files not found.${C_RESET}"
    echo "   Please ensure you have created:"
    echo "   1. 'secrets.yaml' (from 'secrets_template.yaml')"
    echo "   2. 'stories_config.yaml' (from 'stories_config_template.yaml')"
    echo "   See USAGE.md for setup instructions."
    exit 1
fi

STORY_DIR="$STORY_NAME"
SQL_SESSIONS_DIR="$STORY_DIR/sql_sessions"

if [ ! -d "$STORY_DIR" ]; then
    echo -e "${C_RED}❌ Error: Story directory '$STORY_DIR' not found.${C_RESET}"
    exit 1
fi

echo -e "${C_BLUE}🚀 Starting pipeline for story:${C_RESET} ${C_YELLOW}$STORY_NAME${C_RESET}"
echo -e "${C_BLUE}   Using database:${C_RESET} ${C_YELLOW}$DB_NAME${C_RESET}"
echo "--------------------------------------------------"

# --- Step 1: Build database views (Convention: build_*.sql) ---
echo -e "${C_BLUE}1. Building database views...${C_RESET}"
if [ ! -d "$SQL_SESSIONS_DIR" ]; then
    echo -e "   ${C_YELLOW}-> ⚠️ SQL sessions directory not found at '$SQL_SESSIONS_DIR'. Skipping build.${C_RESET}"
else
    BUILD_SCRIPTS=$(find "$SQL_SESSIONS_DIR" -maxdepth 1 -type f -name "build_*.sql" 2>/dev/null | sort)
    if [ -z "$BUILD_SCRIPTS" ]; then
        echo -e "   ${C_YELLOW}-> ⚠️ No build scripts (build_*.sql) found. Skipping.${C_RESET}"
    else
        echo "   -> Found build scripts. Executing..."
        for sql_file in $BUILD_SCRIPTS; do
            echo "      - Running: $sql_file"
            sqlite3 "$DB_NAME" < "$sql_file"
        done
        echo -e "   ${C_GREEN}✅ Build step complete.${C_RESET}"
    fi
fi

# --- Step 2: Upload views to Google Sheets ---
echo -e "\n${C_BLUE}2. Uploading views to Google Sheets...${C_RESET}"
PYTHON_UPLOADER_SCRIPT="scripts/g_drive_uploader.py"
if [ -f "$PYTHON_UPLOADER_SCRIPT" ]; then
    if python3 "$PYTHON_UPLOADER_SCRIPT" "$STORY_NAME" --db_name "$DB_NAME"; then
        echo -e "   ${C_GREEN}✅ Upload complete.${C_RESET}"
    else
        echo -e "   ${C_RED}❌ Python uploader script failed. Aborting.${C_RESET}" >&2
        exit 1
    fi
else
    echo -e "   ${C_YELLOW}-> ⚠️ Python uploader not found at '$PYTHON_UPLOADER_SCRIPT'. Skipping.${C_RESET}"
fi

# --- Step 3: Clean up database views (Convention: cleanup_*.sql) ---
echo -e "\n${C_BLUE}3. Cleaning up database views...${C_RESET}"
if [ ! -d "$SQL_SESSIONS_DIR" ]; then
    echo -e "   ${C_YELLOW}-> ⚠️ SQL sessions directory not found at '$SQL_SESSIONS_DIR'. Skipping cleanup.${C_RESET}"
else
    CLEANUP_SCRIPTS=$(find "$SQL_SESSIONS_DIR" -maxdepth 1 -type f -name "cleanup_*.sql" 2>/dev/null | sort)
    if [ -z "$CLEANUP_SCRIPTS" ]; then
        echo -e "   ${C_YELLOW}-> ⚠️ No cleanup scripts (cleanup_*.sql) found. Skipping.${C_RESET}"
    else
        echo "   -> Found cleanup scripts. Executing..."
        for sql_file in $CLEANUP_SCRIPTS; do
            echo "      - Running: $sql_file"
            sqlite3 "$DB_NAME" < "$sql_file"
        done
        echo -e "   ${C_GREEN}✅ Cleanup complete.${C_RESET}"
    fi
fi

echo "--------------------------------------------------"
echo -e "${C_GREEN}🎉 Pipeline for '$STORY_NAME' completed successfully!${C_RESET}"
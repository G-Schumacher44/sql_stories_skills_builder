import os
import sqlite3
import pandas as pd
import yaml
from google.oauth2 import service_account
from gspread_pandas import Spread, Client
from gspread.exceptions import SpreadsheetNotFound

# --- Config ---
# Build paths relative to the script's location for robustness
SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
REPO_ROOT = os.path.abspath(os.path.join(SCRIPT_DIR, "../.."))

DB_PATH = os.path.join(REPO_ROOT, "ecom_retailer.db")
SHEET_ID = os.getenv("GDRIVE_SHEET_ID")

SERVICE_ACCOUNT_FILE = os.getenv("GDRIVE_CREDS_PATH")

# Fallback: load from secrets.yaml if env var is not set
if not SERVICE_ACCOUNT_FILE:
    secrets_path = os.path.join(REPO_ROOT, "secrets.yaml")
    if os.path.exists(secrets_path):
        with open(secrets_path, "r") as f:
            secrets = yaml.safe_load(f)
            SERVICE_ACCOUNT_FILE = secrets["google_drive"].get("service_account_path")

if not SHEET_ID:
    secrets_path = os.path.join(REPO_ROOT, "secrets.yaml")
    if os.path.exists(secrets_path):
        with open(secrets_path, "r") as f:
            secrets = yaml.safe_load(f)
            SHEET_ID = secrets.get("variables", {}).get("GDRIVE_SHEET_ID")

class LocalFileError(Exception):
    """Custom exception for local file access issues."""
    pass

def pre_flight_checks():
    """Verify that essential files exist and are accessible by attempting to open them."""
    # 0. Check if the environment variable for creds is set.
    if not SERVICE_ACCOUNT_FILE:
        raise LocalFileError(
            "Environment variable 'GDRIVE_CREDS_PATH' is not set.\n"
            "💡 Please set this variable to the absolute path of your service account JSON file.\n"
            '   Example: export GDRIVE_CREDS_PATH="/path/to/your/creds.json"'
        )

    # 1. Check service account file for read access.
    try:
        with open(SERVICE_ACCOUNT_FILE, "r") as f:
            pass  # Just confirm it can be opened for reading.
    except FileNotFoundError:
        raise LocalFileError(f"Service account file not found at: {SERVICE_ACCOUNT_FILE}")
    except PermissionError:
        raise LocalFileError(f"Read permission denied for service account file: {SERVICE_ACCOUNT_FILE}\n"
                              "💡 On macOS, check System Settings > Privacy & Security > Files and Folders to ensure your terminal or IDE has access.")

    # 2. Check database file for read access and its directory for write access.
    db_dir = os.path.dirname(DB_PATH)
    try:
        # Test read access to the DB file itself. This also checks for existence.
        with open(DB_PATH, "rb") as f:
            pass
        # Test write access to the directory, which SQLite needs for journal files.
        test_file = os.path.join(db_dir, ".permission_test")
        with open(test_file, "w") as f: pass
        os.remove(test_file)
    except FileNotFoundError:
        raise LocalFileError(f"Database file not found at: {DB_PATH}")
    except (PermissionError, OSError) as e:
        raise LocalFileError(f"Permission denied for database or its directory: {db_dir}\n"
                              f"  Original error: {e!r}\n"
                              "💡 SQLite needs read access to the DB file and write access to its directory.\n"
                              "💡 On macOS, check System Settings > Privacy & Security > Files and Folders.")

# --- Auth Google Sheets ---
def auth_gsheets():
    """
    Authenticate and return a gspread_pandas Client using service account credentials.
    """
    creds = service_account.Credentials.from_service_account_file(
        SERVICE_ACCOUNT_FILE,
        scopes=["https://www.googleapis.com/auth/spreadsheets", "https://www.googleapis.com/auth/drive"]
    )
    client = Client(creds=creds)
    return client

# --- Fetch All dash_* Views ---
def get_dash_views(conn):
    """
    Retrieve all view names from the SQLite database that start with 'dash_'.
    
    Args:
        conn (sqlite3.Connection): SQLite database connection object.
    
    Returns:
        list of str: List of view names starting with 'dash_'.
    """
    query = """
    SELECT name FROM sqlite_master 
    WHERE type='view' AND name LIKE 'dash_%'
    """
    cursor = conn.cursor()
    cursor.execute(query)
    results = cursor.fetchall()
    return [row[0] for row in results]

# --- Export Each View to Separate Tab ---
def export_dash_views_to_sheet():
    """
    Connect to the SQLite database, fetch all 'dash_' views, and export each view 
    as a separate tab in the specified Google Sheet.
    """
    try:
        pre_flight_checks()

        with sqlite3.connect(DB_PATH) as conn:
            dash_views = get_dash_views(conn)
            client = auth_gsheets()
            spread = Spread(SHEET_ID, client=client)

            for view in dash_views:
                df = pd.read_sql_query(f"SELECT * FROM {view}", conn)
                spread.df_to_sheet(df, index=False, sheet=view, replace=True)
                print(f"✅ Exported: {view}")

            print("🎉 All dash_* views exported to Google Sheet.")
    except SpreadsheetNotFound:
        print(f"❌ Error: Spreadsheet not found.")
        print(f"   Please make sure the SHEET_ID '{SHEET_ID}' is correct and that you have shared the sheet")
        print(f"   with the service account email from '{SERVICE_ACCOUNT_FILE}' and given it 'Editor' permissions.")
    except LocalFileError as e:
        print(f"❌ A local file access error occurred:\n   {e}")
    except PermissionError:
        print("❌ Google API Permission Denied. This is not a local file issue.")
        print("   The Google API has rejected the request. Please check the following:")
        print("   1. The 'Google Sheets API' is ENABLED in your Google Cloud project.")
        print(f"   2. The service account email (from '{SERVICE_ACCOUNT_FILE}') has been shared with your Google Sheet with 'Editor' permissions.")
        print(f"   - Sheet ID: {SHEET_ID}")
    except Exception as e:
        print(f"❌ An unexpected error occurred: {e!r}")

if __name__ == "__main__":
    export_dash_views_to_sheet()

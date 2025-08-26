import sqlite3
import os

def check_db_tables(db_path):
    """
    Connects to a SQLite database and lists its tables to verify access.
    """
    # Check if the provided path exists before proceeding.
    print(f"Attempting to connect to: {db_path}")

    # Resolve the absolute path for the connection, but avoid printing it to the user.
    absolute_db_path = os.path.abspath(db_path)
    if not os.path.exists(absolute_db_path):
        print(f"---")
        print(f"ERROR: Database file not found at the specified path.")
        print(f"Please make sure the file exists and the path is correct.")
        print(f"---")
        return

    conn = None
    try:
        conn = sqlite3.connect(absolute_db_path)
        cursor = conn.cursor()

        # This query inspects the database's schema for table names.
        cursor.execute("SELECT name FROM sqlite_master WHERE type='table';")
        tables = cursor.fetchall()

        if tables:
            print("\nSuccess! Tables found in the database:")
            for table in tables:
                # fetchall() returns a list of tuples, so we get the first item.
                print(f"- {table[0]}")
        else:
            print("\nConnection successful, but no tables were found in this database file.")

    except sqlite3.Error as e:
        print(f"An error occurred: {e}")
    finally:
        if conn:
            conn.close()
            print("\nConnection closed.")

# --- How to use ---
# 1. Save this file as check_db.py in the same directory as your ecom_retailer.db
# 2. Run it from your terminal: python check_db.py
check_db_tables('ecom_retailer_v3.db')
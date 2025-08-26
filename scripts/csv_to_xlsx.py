import os
import pandas as pd
import argparse

# --- Path Configuration ---
# Get the directory where the script is located
SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
# The story directory is one level up from the script's directory (e.g., story_05_VP_request)
STORY_DIR = os.path.abspath(os.path.join(SCRIPT_DIR, ".."))
# Define the base directory for I/O relative to the story directory
BASE_DATA_DIR = os.path.join(STORY_DIR, "output_data")

def export_csv_folder_to_excel(input_folder_path, output_filepath):
    """
    Reads all CSV files from an input folder and saves them as sheets in a single Excel file.

    Args:
        input_folder_path (str): The absolute path to the folder containing CSV files.
        output_filepath (str): The absolute path for the output Excel file.
    """
    # Ensure the directory for the output file exists.
    output_dir = os.path.dirname(output_filepath)
    os.makedirs(output_dir, exist_ok=True)

    try:
        with pd.ExcelWriter(output_filepath) as writer:
            print(f"🔍 Reading CSVs from: {input_folder_path}")
            # Check if the input directory exists before trying to list its contents
            if not os.path.isdir(input_folder_path):
                print(f"⚠️  Warning: Input folder not found, skipping: {input_folder_path}")
                return

            for fname in os.listdir(input_folder_path):
                # Skip .DS_Store and non-CSV files
                if not fname.endswith(".csv") or fname.startswith("."):
                    continue

                fpath = os.path.join(input_folder_path, fname)
                # Use a clean sheet name (remove .csv, limit to 31 chars)
                sheet_name = os.path.splitext(fname)[0][:31]

                print(f"  - Processing '{fname}' into sheet '{sheet_name}'...")
                df = pd.read_csv(fpath)
                df.to_excel(writer, sheet_name=sheet_name, index=False)
            print(f"✅ Successfully created Excel file: {output_filepath}")

    except Exception as e:
        print(f"❌ An error occurred while processing {input_folder_path}: {e}")

if __name__ == "__main__":
def parse_args():
    parser = argparse.ArgumentParser(description="Export CSV folders to Excel files")
    parser.add_argument(
        "--folder", type=str, default=None,
        help="Optional subfolder in output_data to export (e.g., 'cleaned_tables'). If not provided, all folders will be processed."
    )
    return parser.parse_args()


if __name__ == "__main__":
    print("--- Starting Dynamic CSV to Excel Export ---")
    print(f"📂 Base data directory: {BASE_DATA_DIR}")
    
    args = parse_args()
    selected_folder = args.folder

    if not os.path.isdir(BASE_DATA_DIR):
        print(f"❌ Error: Base data directory not found at '{BASE_DATA_DIR}'.")
        print("   Please ensure the directory exists and contains subfolders with CSV files.")
    else:
        folders_to_process = [selected_folder] if selected_folder else os.listdir(BASE_DATA_DIR)

        for item in folders_to_process:
            input_subdir_path = os.path.join(BASE_DATA_DIR, item)

            if os.path.isdir(input_subdir_path):
                output_filename = f"{item}_export.xlsx"
                output_filepath = os.path.join(BASE_DATA_DIR, output_filename)

                print(f"\nProcessing folder: '{item}' -> '{output_filename}'")
                export_csv_folder_to_excel(input_subdir_path, output_filepath)

    print("\n--- Export complete. ---")
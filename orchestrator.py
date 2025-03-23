import subprocess
import logging
import os
from concurrent.futures import ThreadPoolExecutor
import json
import shutil
import sys

logging.basicConfig(level=logging.INFO, format="%(asctime)s - %(levelname)s - %(message)s")

DATA_FOLDER = "data"

os.makedirs(DATA_FOLDER, exist_ok=True)

def delete_folder(folder_path):
    """Deletes the entire folder after parsing is complete."""
    if os.path.exists(folder_path):
        shutil.rmtree(folder_path)
        logging.info(f"Deleted folder: {folder_path}")
    else:
        logging.warning(f"Folder {folder_path} not found, skipping deletion.")

def delete_files(files):
    for file in files:
        if os.path.exists(file):
            os.remove(file)
            logging.info(f"Deleted file: {file}")
        else:
            logging.warning(f"File {file} not found, skipping deletion.")

def merge_json_files():
    json_files = ["coursera_results.json", "edx_courses.json", "linkedin_courses.json"]
    all_courses = []

    for file in json_files:
        if os.path.exists(file):
            with open(file, 'r', encoding='utf-8') as f:
                data = json.load(f)
                all_courses.extend(data)  
        else:
            logging.warning(f"Warning: {file} not found.")

    # Save merged data
    with open("all_courses.json", "w", encoding="utf-8") as f:
        json.dump(all_courses, f, indent=2, ensure_ascii=False)

    logging.info("Merged all JSON files into all_courses.json")

    # Delete individual JSON files after merging
    delete_files(json_files)

def run_script(script_name, *args):
    command = ["python", script_name] + list(args)
    logging.info(f"Starting {script_name} with args: {args}...")
    
    result = subprocess.run(command, capture_output=True, text=True)
    
    if result.returncode == 0:
        logging.info(f"Successfully completed {script_name}")
    else:
        logging.error(f"Error in {script_name}: {result.stderr}")

def main():
    """Main function to orchestrate scraping and parsing in parallel."""
    search_term = sys.argv[1]
    
    if not search_term:
        logging.error("Search term cannot be empty.")
        return
    with ThreadPoolExecutor() as executor:
        executor.submit(run_script, "working/coursera.py", search_term, DATA_FOLDER)
        executor.submit(run_script, "working/edx.py", search_term, DATA_FOLDER)
        executor.submit(run_script, "working/ll.py" , search_term, DATA_FOLDER)

    logging.info("Scraping completed. Starting parsing...")
    with ThreadPoolExecutor() as executor:
        executor.submit(run_script, "working/coursera_parser.py", DATA_FOLDER)
        executor.submit(run_script, "working/edxParser.py", DATA_FOLDER)
        executor.submit(run_script, "working/ll_parser.py", DATA_FOLDER)

    logging.info("Parsing completed. Cleaning up...")
    delete_folder(DATA_FOLDER)

    logging.info("All processes completed successfully!")

if __name__ == "__main__":
    main()
    merge_json_files()

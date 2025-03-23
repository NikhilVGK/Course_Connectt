from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.chrome.service import Service
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
import urllib.parse
import time
import sys

if len(sys.argv) < 2:
    print("Usage: python edx.py <search_term>")
    sys.exit(1)

QUERY = sys.argv[1]

OUTPUT_FILE = f"edx_{QUERY.replace(' ', '_')}_courses.html"  # Output filename

# Encode query for URL
encoded_query = urllib.parse.quote(QUERY)
f_n=0
for pg_n in range(1,2):
    url = f"https://www.edx.org/search?q={encoded_query}&tab=course&page={pg_n}"

    driver = webdriver.Chrome()
    try:
        driver.get(url)
        # Wait for course cards to load
        time.sleep(3)
        course_cards = driver.find_elements(
            By.CSS_SELECTOR, 
            "div.flex.justify-center"  # Main course card container
        )
        print(course_cards)
        for card in course_cards:
            with open(f"data\edx_{QUERY}_courses_{f_n}.html","w", encoding="utf-8") as f:
                f.write(card.get_attribute("outerHTML") + "\n\n")
                f_n+=1

        print(f"Successfully saved {len(course_cards)} courses to {OUTPUT_FILE}")
    finally:
        driver.quit()

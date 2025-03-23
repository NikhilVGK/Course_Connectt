# # not limiting courses
from selenium import webdriver
from selenium.webdriver.common.by import By
import time
import os
import sys

driver = webdriver.Chrome()
if len(sys.argv) < 2:
    print("Usage: python coursera.py <search_term>")
    sys.exit(1)

query = sys.argv[1]

os.makedirs("data", exist_ok=True)

driver.get(f"https://www.linkedin.com/learning/search?keywords={query}")
time.sleep(1.5)

driver.execute_script("window.scrollTo(0, document.body.scrollHeight)")
time.sleep(1.5)

course_cards = driver.find_elements(By.CSS_SELECTOR, "div.base-search-card")

# Save each course card as an HTML file
for i, card in enumerate(course_cards):
    file_path = os.path.join("data", f"linkedin_{query}_course_{i}.html")
    with open(file_path, "w", encoding="utf-8") as f:
        f.write(card.get_attribute("outerHTML") + "\n\n")

print(f"Saved {len(course_cards)} LinkedIn Learning courses as HTML.")
driver.quit()

from bs4 import BeautifulSoup
import os
import json
import random

# List to store course data
all_courses = []

# Ensure 'data' folder exists
if not os.path.exists("data"):
    print("No data directory found!")
else:
    for file in os.listdir("data"):
        if file.startswith("linkedin_") and file.endswith(".html"):
            try:
                with open(f"data/{file}", "r", encoding="utf-8") as f:
                    html_content = f.read()
                    soup = BeautifulSoup(html_content, 'html.parser')

                    # Extract course details with error handling
                    title = soup.find('h3', class_='base-search-card__title')
                    img = soup.find('img', class_='search-entity-media__img')
                    link = soup.find('a', class_='base-card__full-link')
                    duration = soup.find('div', class_='search-entity-media__duration')
                    org = soup.find('h4', class_='base-search-card__subtitle')

                    # Create dictionary for course
                    course_data = {
                        "title": title.text.strip() if title else "Unknown Title",
                        "image_link": img.get("data-delayed-url", img.get("src", "")) if img else "No Image",
                        "product_link": link["href"] if link else "No Link",
                        "duration": duration.text.strip() if duration else "N/A",
                        "organization": org.text.strip().replace("From: ", "") if org else "Unknown",
                        "rating": round(random.uniform(4, 5), 1),
                        "reviews": random.randint(100, 500)
                    }

                    all_courses.append(course_data)

            except Exception as e:
                print(f"Error processing {file}: {str(e)}")

with open('linkedin_courses.json', 'w', encoding='utf-8') as json_file:
    json.dump(all_courses, json_file, ensure_ascii=False, indent=2)

print("Data successfully saved to linkedin_courses.json ✅")

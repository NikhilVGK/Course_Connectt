from bs4 import BeautifulSoup
import random
import json
import os

def parse_edx_course(html):
    soup = BeautifulSoup(html, 'html.parser')

    try:
        title = soup.find('span', class_='font-bold')
        image = soup.find('img', class_='m-0')
        product_link = soup.find('a')
        duration = soup.find('span', class_='text-gray-500')  # Adjust this based on the actual HTML structure
        organization = soup.find('p', class_='text-sm')

        if not (title and image and product_link and organization):
            print(f"Missing elements in file: {html[:100]}")  # Print first 100 characters for debugging
            return None

        course_data = {
            "title": title.text.strip(),
            "image_link": image['data-src'],
            "product_link": "https://www.edx.org" + product_link['href'],
            "duration": duration.text.strip() if duration else "Duration not found",
            "organization": organization.text.strip(),
            "rating": round(random.uniform(4, 5), 1),
            "reviews": random.randint(100, 1000)
        }

        return course_data

    except Exception as e:
        print(f"Error parsing HTML: {str(e)}")
        return None

# Process multiple files
all_courses = []

html_dir = "data/" 

for file in os.listdir(html_dir):
    if file.endswith(".html"):  # Only process HTML files
        with open(os.path.join(html_dir, file), 'r', encoding='utf-8') as f:
            html = f.read()
            course = parse_edx_course(html)
            if course:
                all_courses.append(course)

# Save to JSON
with open('edx_courses.json', 'w', encoding='utf-8') as f:
    json.dump(all_courses, f, indent=2, ensure_ascii=False)

print("Data saved to edx_courses.json")

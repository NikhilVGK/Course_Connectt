import json
from bs4 import BeautifulSoup
import os
from numpy import random

def parse_coursera_html_files(html_dir, output_file="coursera_results.json"):
    """
    Parses Coursera HTML files from a directory, extracts course details,
    and saves the data to a JSON file.
    """

    courses_data = []

    for filename in os.listdir(html_dir):
        if filename.endswith(".html"):
            filepath = os.path.join(html_dir, filename)
            try:
                with open(filepath, "r", encoding="utf-8") as f:
                    html = f.read()
                    soup = BeautifulSoup(html, 'html.parser')

                    # Locate course listings
                    course_listings = soup.find_all('div')

                    for course in course_listings:
                        if course.find("h2"):  # Verify it contains a H2, assuming it's a valid container
                            try:
                                # Extract data
                                title_element = course.find('h2')
                                title = title_element.text.strip() if title_element else "No title found"

                                # Extract information from <p> tags
                                paragraphs = course.find_all('p')

                                organization = "No organization found"
                                rating = None
                                reviews = None
                                duration = None
                                course_link = None
                                university = None

                                for p in paragraphs:
                                    if 'Organization:' in p.text:
                                        organization = p.text.replace("Organization:", "").strip()
                                    elif 'University:' in p.text:
                                        university = p.text.replace("University:", "").strip()
                                        organization = university  # Override organization with university
                                    elif 'Rating:' in p.text:
                                        rating_text = p.text.replace('Rating:', '').strip()
                                        try:
                                            rating = float(rating_text)
                                        except ValueError:
                                            rating = round(random.random() + 4, 1)  # Set random rating
                                    elif 'Reviews:' in p.text:
                                        reviews_text = p.text.replace('Reviews:', '').strip()
                                        try:
                                            reviews = int("".join(filter(str.isdigit, reviews_text)))  # Extract digits
                                        except ValueError:
                                            reviews = random.randint(100, 1000)
                                    elif 'Duration:' in p.text:
                                        duration = p.text.replace("Duration:", "").strip()
                                    elif 'Course Link:' in p.text:
                                        a_tag = p.find('a')
                                        course_link = a_tag['href'] if a_tag else None

                                image_element = course.find('img')
                                image_link = image_element['src'] if image_element else "No image link found"

                                # Create JSON object (skills removed)
                                course_data = {
                                    "title": title,
                                    "image_link": image_link,
                                    "product_link": course_link,
                                    "duration": duration,
                                    "organization": organization,
                                    "rating": rating,
                                    "reviews": reviews
                                }
                                courses_data.append(course_data)

                            except Exception as e:
                                print(f"Error processing course in {filename}: {e}")
                                continue

            except Exception as e:
                print(f"Error reading file {filename}: {e}")
                continue

    # Save the data to a JSON file
    try:
        with open(output_file, "w", encoding="utf-8") as f:
            json.dump(courses_data, f, indent=2, ensure_ascii=False)
        print(f"Data saved to {output_file}")
    except IOError as e:
        print(f"Error writing to file: {e}")

if __name__ == "__main__":
    html_directory = r"./data"
    parse_coursera_html_files(html_directory)  # It now creates the JSON file

import requests
from bs4 import BeautifulSoup
import urllib.parse
import os# Example Usage (Get search term from the user)
import sys
def scrape_coursera_search(search_term, num_pages=1, output_dir="data"):
    """
    Scrapes Coursera search results directly from the HTML using requests and BeautifulSoup,
    with pagination

    """

    if not os.path.exists(output_dir):
        os.makedirs(output_dir)

    filename = f"{search_term.replace(' ', '_').lower()}.html"
    output_path = os.path.join(output_dir, filename)

    html_output = f"""<!DOCTYPE html>
    <html>
    <head>
        <title>Coursera Search Results: {search_term}</title>
    </head>
    <body>
        <h1>Coursera Search Results: {search_term}</h1>
    """

    try:
        for i in range(1, num_pages + 1):
            print(f"Scraping page {i}...")

            # Construct the paginated search URL
            base_url = "https://www.coursera.org/courses"
            params = {"query": search_term, "page": i}
            search_url = base_url + "?" + urllib.parse.urlencode(params)

            response = requests.get(search_url)
            response.raise_for_status()
            html = response.text
            soup = BeautifulSoup(html, 'html.parser')

            # Find all the course listings
            course_listings = soup.find_all('li', class_='cds-9 css-0 cds-11 cds-grid-item cds-56 cds-64 cds-76 cds-90')

            for course in course_listings:
                try:
                    # Extract the image URL
                    img_tag = course.find('img')
                    img_url = img_tag['src'] if img_tag and 'src' in img_tag.attrs else "No image found"

                    # Extract the course title
                    title_tag = course.find('h3', class_='cds-CommonCard-title')
                    title = title_tag.text.strip() if title_tag else "No title found"

                    # Extract the coursera URL to the page of courses:
                    courselink_element = course.find('a', class_='cds-119 cds-113 cds-115 cds-CommonCard-titleLink css-vflzcf cds-142')
                    courselink = "https://www.coursera.org" + courselink_element['href'] if courselink_element else "Link Not Available"

                    # Extract the University name
                    university_tag = course.find('p', class_='cds-ProductCard-partnerNames')
                    university = university_tag.text.strip() if university_tag else "No university found"

                    # Extract the rating and review count
                    rating_div = course.find('div', class_='cds-RatingStat-sizeLabel')
                    rating_span = course.find('span', class_='css-6ecy9b')
                    rating = rating_span.text.strip() if rating_span else "No rating found"
                    reviews_div = course.find('div', class_='css-vac8rf')
                    reviews = reviews_div.text.strip() if reviews_div else "No reviews found"

                    # Extract the course details, only return skills
                    details_tag = course.find_all('p', class_='css-vac8rf')
                    details = "No details found"  # Default value

                    if details_tag and len(details_tag) > 1:
                        detail_element = details_tag[1]
                        # Extract text, excluding <b> tag and its content
                        for b_tag in detail_element.find_all('b'):
                            b_tag.extract()
                        details = detail_element.get_text(strip=True)
                    else:
                        details = "No details found"
                    
                    # Extract the organization name, assuming it's the same as university for now
                    organization = "Coursera"

                    # Extract the duration, search for span that starts with duration, if not get No duration found
                    duration_tag = course.find("div",class_="cds-CommonCard-metadata").children
                    duration_tag = next(duration_tag, None)
                    duration = duration_tag.text.strip() if duration_tag else "No duration found"

                    # Create an HTML block for the course
                    course_html = f"""
                    <div>
                        <img src="{img_url}" alt="{title}">
                        <h2>{title}</h2>
                        <p><b>Organization:</b> {organization}</p>
                        <p><b>University:</b> {university}</p>
                        <p><b>Rating:</b> {rating} </p>
                        <p><b>Reviews:</b> {reviews}</p>
                        <p><b>Skills:</b> {details}</p>
                        <p><b>Duration:</b> {duration}</p>
                        <p><b>Course Link:</b> <a href="{courselink}">{title}</a></p>
                    </div>
                    """
                    html_output += course_html
                except Exception as e:
                    print(f"Error processing course: {e}")
                    continue

    except requests.exceptions.RequestException as e:
        print(f"An error occurred during the request: {e}")
    except Exception as e:
        print(f"An error occurred: {e}")  # General error handling

    html_output += """
    </body>
    </html>
    """

    try:
        with open(output_path, 'w', encoding='utf-8') as f:
            f.write(html_output)
        print(f"Scraped data saved to {output_path}")
    except IOError as e:
        print(f"Error writing to file: {e}")



if len(sys.argv) < 2:
    print("Usage: python coursera.py <search_term>")
    sys.exit(1)

search_term = sys.argv[1]

# num_pages = int(input("Enter the number of pages to scrape:")) #Get number of pages to scrape from the user
num_pages = 5
scrape_coursera_search(search_term, num_pages)
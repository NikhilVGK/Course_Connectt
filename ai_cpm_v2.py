import requests
from bs4 import BeautifulSoup
import google.generativeai as genai
import sys
import json
import os
from dotenv import load_dotenv, dotenv_values 
load_dotenv()

# Configure Gemini API
genai.configure(api_key=os.getenv("API_KEY"))
model = genai.GenerativeModel('gemini-1.5-flash-001')

"""
Individual Fn for each site, To get the write info about each course and compare them
"""
def scrape_coursera(url):
    """Scrape Coursera course details"""
    response = requests.get(url)
    soup = BeautifulSoup(response.content, 'html.parser')
    u= soup.find('ul', class_='css-yk0mzy')
    skills=[]

    # skill
    if u:
        skilladk= u.find_all('span')
        for i in skilladk :
            skills.append(i.get_text(strip=True))
    skilla_dk=", ".join(skills)   
    
    # offer
    offer=soup.find('a', class_='cds-119 cds-113 cds-115 css-5xxql1 cds-142')
    of=offer.find('span')
    
    #duration
    dur = soup.find_all('div', class_='css-fw9ih3')

    #level
    target_div = soup.find_all('div', class_='css-fk6qfz')[1]
    level = target_div.get_text(strip=True)  # Output: Beginner level
    return {
        'name': soup.find('h1', class_='cds-119 cds-Typography-base css-1xy8ceb cds-121').get_text(strip=True),
        'rating': soup.find('div', class_='cds-119 cds-Typography-base css-h1jogs cds-121').get_text(strip=True),
        'level': level,
        'duration': soup.find('div', class_='css-fk6qfz').get_text(strip=True),
        'skills': skilla_dk,
        # 'offered_by': ((soup.find('span', class_='cds-119 cds-113 cds-115 css-5xxql1 cds-142')).find('span',class_="css-6ecy9b")).get_text(strip=True)
        'offered_by': soup.find('span', class_='css-6ecy9b').get_text(strip=True)
    }
# Handmade
def scrape_ll(url):
    try:
        response = requests.get(url)
        response.raise_for_status()
    except requests.exceptions.RequestException as e:
        print(f"Request failed: {str(e)}")
        return None
    soup = BeautifulSoup(response.content, 'html.parser')
    course_details = {
        'name': None,
        'rating': None,
        'level': None,
        'duration': None,
        'skills': [],
        'offered_by': None
    }
    try:
        # Extract title
        title_element = soup.find('h1', class_='top-card-layout__title font-sans text-lg papabear:text-xl font-bold leading-open text-color-text mb-0')
        if title_element:
            course_details['name'] = title_element.get_text(strip=True)
    except Exception as e:
        print(f"Error extracting- title: {str(e)}")
    try:
        # Extract author
        author_element = soup.find('h3', class_='base-main-card__title')
        if author_element:
            course_details['offered_by'] = author_element.get_text(strip=True)
    except Exception as e:
        print(f"Error extracting- offered by: {str(e)}")
    try:
        # Extract duration
        duration_element = (soup.find_all('span', class_='top-card__headline-row-item')[2])
        if duration_element:
            course_details['duration'] = duration_element.get_text(strip=True).split(":")[1]
    except Exception as e:
        print(f"Error extracting- duration: {str(e)}")
    try:
        # Extract rating
        rating_element = soup.find('span', class_='ratings-summary__rating-average')
        if rating_element:
            course_details['rating'] = rating_element.get_text(strip=True)
    except Exception as e:
        print(f"Error extracting- rating: {str(e)}")
    try:
        # Extract skills
        skill_elements = soup.find_all('a',class_='pill flex w-fit mr-[6px] mb-1 hover:no-underline skill-pill')
        # Extract and clean skill names
        skills = [skill.get_text(strip=True) for skill in skill_elements]
        # Create comma-separated string
        skills_str = ', '.join(skills)
        course_details['skills'] = skills_str
    except Exception as e:
        print(f"Error extracting- skills: {str(e)}")
    try:
        # Extract level
        level_element = (soup.find_all('span', class_='top-card__headline-row-item')[3])
        if level_element:
            course_details['level'] = level_element.get_text(strip=True).split(":")[1]
    except Exception as e:
        print(f"Error extracting- level: {str(e)}")
    # print(course_details)
    # sys.exit()
    return course_details
def scrape_edx(url):
    response = requests.get(url)
    soup = BeautifulSoup(response.content, 'html.parser')
    course_details = {
        'name': None,
        'rating': None,
        'level': None,
        'duration': None,
        'skills': None,
        'offered_by': None
    }
    try:
        # Extract name
        name_element = soup.find('h1', class_='text-learn-course-hero-heading')
        if name_element:
            course_details['name'] = name_element.get_text(strip=True)
    except Exception as e:
        print(f"Error extracting name: {str(e)}")
    try:
        # Extract rating
        rating_element = soup.find('div', class_='ml-2 font-medium text-primary text-sm')
        if rating_element:
            course_details['rating'] = rating_element.get_text(strip=True)
    except Exception as e:
        print(f"Error extracting rating: {str(e)}")
    try:
        # Extract level and skills from li element
        li_element = soup.find_all('li', class_='AtAGlance_parsed__AaBsT')
        if len(li_element)>=4 :
            course_details['skills']= li_element[-1].find_all('span')[1].get_text(strip=True)
            course_details['level']=li_element[2].find_all('span')[1].get_text(strip=True)
    except Exception as e:
        print(f"Error extracting level/skills: {str(e)}")
    try:
        # Extract duration
        duration_element = duration_element = soup.find('div',class_='md:pr-12')
        if duration_element:
            print(duration_element)
            course_details['duration'] = duration_element.find('div').get_text(strip=True)
    except Exception as e:
        print(f"Error extracting duration: {str(e)}")

    try:
        # Extract offered by
        offered_by_element = soup.find('a', class_='pointer text-black-100 underline')
        if offered_by_element:
            course_details['offered_by'] = offered_by_element.get_text(strip=True)
    except Exception as e:
        print(f"Error extracting offered by: {str(e)}")
    # print(course_details)
    # sys.exit()
    return course_details
def get_course_info(url):
    """Determine platform and scrape course data"""
    if 'coursera' in url:
        return scrape_coursera(url)
    elif 'edx' in url:
        return scrape_edx(url)
    elif 'linkedin' in url:
        return scrape_ll(url)
    else:
        raise ValueError("Unsupported platform")


def compare_courses(url1, url2):
    """Compare two courses using Gemini API"""
    try:
        course1 = get_course_info(url1)
        course2 = get_course_info(url2)
        
        comparison_prompt = f"""
        Compare these two online courses:
        Course 1 ({url1}):
        - Name: {course1['name']}
        - Provider: {course1['offered_by']}
        - Rating: {course1['rating']}
        - Level: {course1['level']}
        - Duration: {course1['duration']}
        - Skills: {course1['skills']}
        
        Course 2 ({url2}):
        - Name: {course2['name']}
        - Provider: {course2['offered_by']}
        - Rating: {course2['rating']}
        - Level: {course2['level']}
        - Duration: {course2['duration']}
        - Skills: {course2['skills']}
        
        Provide a structured comparison with:
        1. Strengths/weaknesses of each
        2. Ideal audience for each course
        3. Value for money assessment
        4. Final recommendation based on different learner profiles
        Rules:
        1.your response must only contain about 100 words
        2.be clear and concise
        """
        
        response = model.generate_content(comparison_prompt)
        res={
            "course1":course1,
            "course2":course2,
            "summary":response.text
        }
        json_data=json.dumps(res)
        return json_data
        
    except Exception as e:
        return f"Comparison failed: {str(e)}"
# print(compare_courses(
#     "https://www.coursera.org/learn/python-crash-course",
#     "https://www.linkedin.com/learning/python-essential-training-18764650"
# ))
if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("Usage: python compare_courses.py <course1_url> <course2_url>")
        sys.exit(1)

    course1_url = sys.argv[1]
    course2_url = sys.argv[2]
    print(compare_courses(course1_url,course2_url))

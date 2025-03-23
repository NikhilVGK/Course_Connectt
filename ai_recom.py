import google.generativeai as genai
import json
import sys
import os
from dotenv import load_dotenv, dotenv_values 
load_dotenv()
genai.configure(api_key=os.getenv("API_KEY"))
model = genai.GenerativeModel('gemini-1.5-flash-001')

"""
Contains Instructions for Creating a short summary, learning path, a skill list
"""
def generate_learning_path(prompt):
    # for summary
    instruction = f"""
        Generate a learning path for {prompt} with this exact structure:
        [100-word prose overview: Concise narrative of the learning journey]
        Essential Technical Skills:
        - Skill 1
        - Skill 2
        - Skill 3
    """
    # for learning path
    instruction2 = f"""
        Generate for {prompt} with this exact structure:
         Skills Inventory:
         ["SpecificTechnology1", "SpecificConcept2", "SpecificTool3"]
         Rules:
            1. Skills Inventory must contain exactly one specific technology per Essential Skill category
            2. Use most representative/popular choice for each category
            3. Format as valid Python list with double-quoted strings 
            4. No duplicate categories
            5. Strictly follow the list format without any markdown
            6. Example of required format: ["Python", "NLP", "TensorFlow"]
            7. No code formatting (no backticks, no "python" prefix)
        """
    # for skill list
    instruction3= f"""
    Generate a learning path for {prompt} with this exact structure:
        Learning Path:
        Phase 1: Foundational Understanding (X weeks)
        - Objectives: [Key focus areas]
        - Resources: [Official documentation/book chapters]
        - Practical: [Hands-on project]
        
        Phase 2: Core Development (X weeks)
        - Objectives: [Implementation focus] 
        - Resources: [Advanced documentation/technical guides]
        - Practical: [Real-world application]
        
        Phase 3: Production Mastery (X weeks)
        - Objectives: [Optimization/deployment]
        - Resources: [Architecture patterns/troubleshooting guides]
        - Practical: [End-to-end system build]

        Total Timeline: X-X months
        Exclude all video/course recommendations. Use only written documentation.
        Rules:
        1. Be clear and Concise
        2. Use maximum of 100 -150 words but Important information must not be missed 
    """
    try:
        summary = model.generate_content(instruction).text
        learn_path=model.generate_content(instruction3).text
        skills=model.generate_content(instruction2).text
        res= {
            "summary": summary,
            "learn_path": learn_path,
            "skills":skills
        }
        response=json.dumps(res)
        return response
    except Exception as e:
        return f"Error: {str(e)}"
if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: python ai_recom.py query")
        sys.exit(1)
    print(generate_learning_path(sys.argv[1]))
# Test Run
# print(generate_learning_path("Python API development"))
# Version where there is no yt link 
# 
# import google.generativeai as genai
# from typing import List, Dict
# import os
# import json
# import sys
# from dotenv import load_dotenv, dotenv_values 
# load_dotenv()
# class CourseConnectChatbot:
#     def __init__(self, api_key: str,initial_history: List[Dict] = None):
#         self.generation_config = {
#             "temperature": 0.3,
#             "max_output_tokens": 500,
#         }
#         genai.configure(api_key=api_key)
#         self.model = genai.GenerativeModel('gemini-1.5-flash-001', generation_config=self.generation_config)
#         self.history = initial_history if initial_history else []  # Changed here
#         self.max_history_length = 4  # Maintain last 2 exchanges (user + assistant)
    
#     def process_query(self, query: str) -> str:
#         try:
#             # Add user message to history
#             self._update_history("user", query)
            
#             # Get context-aware response
#             intent = self._classify_intent(query)
#             response = self._generate_response(intent, query)
            
#             # Add assistant response to history
#             self._update_history("assistant", response)
            
#             return response
        
#         except Exception as e:
#             return f"Sorry, I'm having trouble connecting. Please try again later. Error: {str(e)}"

#     def _classify_intent(self, query: str) -> str:
#         prompt = f"""Classify the user's question based on context. Choose one:
#         - what_is (definition requests)
#         - how_to_learn (learning methods)
#         - where_to_learn (resource locations)
#         - other
        
#         Context:
#         {self._format_history()}
        
#         Question: {query}
#         """
        
#         response = self.model.generate_content(prompt)
#         return response.text.lower().strip()

#     def _generate_response(self, intent: str, query: str) -> str:
#         if "what_is" in intent:
#             return self._generate_definition(query)
#         elif "how_to_learn" in intent:
#             return "Our AI Recommendation feature can create a personalized learning plan! Go to 'AI recommendation' section."
#         elif "where_to_learn" in intent:
#             return "Use our Search feature to discover courses from multiple platforms! Go to 'Search Courses'."
#         else:
#             return ("I can help with:\n- Explaining concepts\n- Learning recommendations\n"
#                     "- Course search\nAsk me anything about learning!")

#     def _generate_definition(self, query: str) -> str:
#         context = f"Previous conversation:\n{self._format_history()}"
#         prompt = f"""Provide a concise 2-3 sentence definition based on this context:
#         {context}
        
#         Specifically explain: {query}
        
#         Format: <concept> is a <category> that <key characteristics>. It <main purpose/use>.
#         """
#         response = self.model.generate_content(prompt)
#         return response.text

#     def _update_history(self, role: str, content: str):
#         self.history.append({"role": role, "content": content})
#         # Truncate history to maintain limit
#         self.history = self.history[-self.max_history_length:]

#     def _format_history(self) -> str:
#         return "\n".join(
#             [f"{msg['role'].capitalize()}: {msg['content']}" 
#              for msg in self.history[:-1]]  # Exclude current query
#         )


# if __name__ == "__main__":
#     try:
#         # Read input from Node.js as JSON string
#         input_data = json.loads(sys.argv[1])
        
#         # Process request
#         bot = CourseConnectChatbot(
#             api_key=input_data['api_key'],
#             initial_history=input_data.get('history', [])
#         )
        
#         response = bot.process_query(input_data['message'])
        
#         # Return JSON response with updated history
#         print(json.dumps({
#             "response": response,
#             "history": bot.history,
#             "session_id": input_data.get('session_id', 'default'),
#             "error": None
#         }))
    
#     except Exception as e:
#         print(json.dumps({
#             "response": None,
#             "history": [],
#             "session_id": input_data.get('session_id', 'default') if 'input_data' in locals() else 'unknown',
#             "error": str(e)
#         }))
import google.generativeai as genai
from typing import List, Dict
import os
import json
import sys
from dotenv import load_dotenv, dotenv_values 
load_dotenv()
class CourseConnectChatbot:
    def __init__(self, api_key: str,initial_history: List[Dict] = None):
        self.generation_config = {
            "temperature": 0.3,
            "max_output_tokens": 500,
        }
        genai.configure(api_key=api_key)
        self.model = genai.GenerativeModel('gemini-1.5-flash-001', generation_config=self.generation_config)
        self.history = initial_history if initial_history else []  
        self.max_history_length = 4 
    
    def process_query(self, query: str) -> str:
        try:
            # Add user message to history
            self._update_history("user", query)
            
            # Get context-aware response
            intent = self._classify_intent(query)
            response = self._generate_response(intent, query)
            
            # Add assistant response to history
            self._update_history("assistant", response)
            
            return response
        
        except Exception as e:
            return f"Sorry, I'm having trouble connecting. Please try again later. Error: {str(e)}"

    def _classify_intent(self, query: str) -> str:
        prompt = f"""Classify the user's question based on context. Choose one:
        - what_is (definition requests)
        - how_to_learn (learning methods)
        - how_to_learn_yt (learning methods specifyically asking for a youtube link)
        - where_to_learn (resource locations)
        - other
        
        Context:
        {self._format_history()}
        
        Question: {query}
        """
        
        response = self.model.generate_content(prompt)
        return response.text.lower().strip()

    def _generate_response(self, intent: str, query: str) -> str:
        if "what_is" in intent:
            return self._generate_definition(query)
        elif "how_to_learn_yt" in intent:
            return self._generate_link(query)
        elif "how_to_learn" in intent:
            return "Our AI Recommendation feature can create a personalized learning plan! Go to 'AI recommendation' section."
        elif "where_to_learn" in intent:
            return "Use our Search feature to discover courses from multiple platforms! Go to 'Search Courses'."
        else:
            return ("I can help with:\n- Explaining concepts\n- Learning recommendations\n"
                    "- Course search\nAsk me anything about learning!")

    def _generate_definition(self, query: str) -> str:
        context = f"Previous conversation:\n{self._format_history()}"
        prompt = f"""Provide a concise 2-3 sentence definition based on this context:
        {context}
        
        Specifically explain: {query}
        
        Format: <concept> is a <category> that <key characteristics>. It <main purpose/use>.
        """
        response = self.model.generate_content(prompt)
        return response.text
    def _generate_link(self, query: str) -> str:
        context= f"Previous conversation:\n{self._format_history()}"
        prompt = f"""Provide just the skill/concept to learn based on: {context} and for {query} and nothing else
        """
        response=self.model.generate_content(prompt)
        return f"https://www.youtube.com/results?search_query={response.text}".replace(' ','+')[:-1]
    def _update_history(self, role: str, content: str):
        self.history.append({"role": role, "content": content})
        # Truncate history to maintain limit
        self.history = self.history[-self.max_history_length:]

    def _format_history(self) -> str:
        return "\n".join(
            [f"{msg['role'].capitalize()}: {msg['content']}" 
             for msg in self.history[:-1]]  # Exclude current query
        )

# Example usage with conversation flow
# if __name__ == "__main__":


#     API_KEY=os.getenv("API_KEY")
#     bot = CourseConnectChatbot(API_KEY)
    
#     queries = [
#         "What is neural network?",
#         "How can I learn it?",
#         "Where to find courses?",
#         "What about Python?",
#         "How to master Python?"
#     ]
    
#     for query in queries:
#         print(f"User: {query}")
#         response = bot.process_query(query)
#         print(f"Bot: {response}\n")

if __name__ == "__main__":
    try:
        input_data = json.loads(sys.argv[1])
        
        bot = CourseConnectChatbot(
            api_key=input_data['api_key'],
            initial_history=input_data.get('history', [])
        )
        
        response = bot.process_query(input_data['message'])
        
        print(json.dumps({
            "response": response,
            "history": bot.history,
            "session_id": input_data.get('session_id', 'default'),
            "error": None
        }))
    
    except Exception as e:
        print(json.dumps({
            "response": None,
            "history": [],
            "session_id": input_data.get('session_id', 'default') if 'input_data' in locals() else 'unknown',
            "error": str(e)
        }))
# Course Connect 🚀  
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)

<img src="assets/banner.png" alt="Course Connect Banner" width="100%"/>  

## 📖 Project Description  
**Course Connect** solves the **inefficient course discovery process** by aggregating courses from platforms like Coursera, edX, and Udemy into a single platform. It enables users to:  
- 🔍 **Search efficiently** with debounced API calls.  
- 🗂️ **Filter** courses by duration, difficulty, ratings, and prerequisites.  
- 📊 **Compare courses side-by-side** (syllabi, pricing, platforms).  
- 🛠️ **AI-Powered Recommendations**: Get personalized learning paths based on skill gaps.  

## ✨ Key Features  
### **Backend**  
- **Multi-Platform Scraping**: Uses **Selenium** for dynamic sites (Coursera) and **Beautiful Soup** for static sites (edX).  
- **Pagination & Lazy-Loading**: Auto-scroll and pagination support for complete data extraction.  
- **Unified JSON Schema**: Normalizes course data (title, duration, prerequisites) across platforms.  
- **AI Recommendations**: Generates learning paths using skill-goal mapping.  

### **Frontend**  
- **Dynamic Search**: Requests sent only on input submission.  
- **Responsive UI**: Flutter-based mobile/desktop views.  
- **Comparison Tool**: Side-by-side course analysis.  

## 🛠️ Tech Stack  
| Component       | Technologies                                                                 |  
|-----------------|------------------------------------------------------------------------------|  
| **Backend**     | Node.js, Python, Selenium, Beautiful Soup, RESTful APIs                      |  
| **Frontend**    | Flutter, Dart, Provider (state management)                                   |  
| **AI**          | Python, NLP (keyword-based skill matching)                                   |  
| **Tools**       | Git, Postman (API testing), Figma (UI/UX)                                    |  

## 🚀 Installation  
1. **Clone the Repository**:  
   ```bash  
   git clone https://github.com/h4636oh/course-connect.git  
   cd course-connect  

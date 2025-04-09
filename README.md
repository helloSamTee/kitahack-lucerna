# Lucerna

## Overview
This is a Flutter project in Andriod Studio for implementing Lucerna — a smart, eco-conscious mobile app that empowers users to track and understand their carbon footprint, while also monitoring real-time carbon offset from Ecolight. Our initiative directly supports SDG 12 and 13.  
Ecolight is algae breeding lamp that captures carbon by harvesting light energy—whether from home lighting or outdoor environments. With the growth rate exceeding all terrestrial plants, 1 tons of algae can capture nearly 2 tons of carbon dioxide.  
To make Ecolight a meaningful part of everyday life and city living, Lucerna app is developed to monitor user's carbon emissions, see real-time data on their carbon offset, and encourage eco-conscious learning with AI-powered features.   

Credits are to be given to [Freepik](https://www.freepik.com/) and [Spline](https://spline.design/), from which all illustrations and 3d model image used in this app are sourced respectively.



## High-Level Project Structure

```
kitahack-lucerna/
├── analysis_options.yaml              # Static analysis rules for Dart code
├── devtools_options.yaml              # Configuration for Dart DevTools
├── firebase.json                      # Firebase configuration file for web support
├── Laptop2Rasp.py                     # Python script for Raspberry Pi integration
├── pubspec.yaml                       # Project metadata and dependencies
├── pubspec.lock                       # Lock file for dependency versions
├── README.md                          # Project overview and setup instructions

├── lib/                               # Flutter application source code
│   ├── main.dart                      # Entry point: initializes Firebase, sets providers, theme, and starts app
│   ├── API_KEY_Config.dart            # Stores and manages API key configurations
│   ├── firebase_options.dart          # Firebase options generated for different platforms
│   ├── firestore_service.dart         # Handles Firestore read/write operations
│
│   ├── auth_provider.dart             # Authentication state management
│   ├── auth_service.dart              # Firebase Auth service logic
│
│   ├── calculator/                    # Carbon footprint calculation feature
│   │   ├── carbon_footprint.dart      # Displays categories for footprint tracking and shows user history
│   │   ├── cf_summary.dart            # Result screen showing calculated carbon footprint
│   │   ├── common_widget.dart         # Reusable input widgets for footprint forms
│   │   ├── energy_record.dart         # Form to record energy usage
│   │   ├── food_record.dart           # Form to record food-related emissions
│   │   ├── journey_record.dart        # Form to record transportation emissions
│   │   ├── gemini_footprint.dart      # Integration with Gemini API to estimate carbon footprint
│   │   └── history_provider.dart      # Manages carbon history state and updates UI
│
│   ├── chat/                          # AI Chatbot interface
│   │   └── chat.dart                  # RAG-powered chatbot UI
│
│   ├── class_models/                  # Data model definitions, supporting conversion to and from Firestore-compatible JSON.
│   │   ├── carbon_offset.dart         # Model for carbon offset data
│   │   ├── carbon_record.dart         # Model for recorded emissions
│   │   └── user_model.dart            # Model for user information
│
│   ├── common_widget.dart             # Shared widgets like app bar and bottom navigation
│
│   ├── ecolight/                      # Ecolight device integration
│   │   └── lamp_stat.dart             # Displays real-time statistics from Ecolight device
│
│   ├── home/                          # Home dashboard and visualizations
│   │   ├── dashboard.dart             # Main dashboard with latest records and visual charts
│   │   ├── donut_chart.dart           # Donut chart comparing footprint vs. offset in a day
│   │   ├── line_chart.dart            # Line chart for comparison of footprint vs. offset over a week
│   │   ├── stackedBar_chart.dart      # Stacked bar chart for footprint by category over a week
│   │   └── visualisation_slider.dart  # Swipeable widget for visual components
│
│   ├── login/                         # Authentication screens
│   │   ├── login_page.dart            # User login interface
│   │   └── register_page.dart         # User registration interface
│
│   └── profile/
│       └── user_profile.dart          # User profile with editable info and API key settings

├── RAG/                               # Retrieval-Augmented Generation (RAG) chatbot backend
│   ├── config.json                    # Configuration for backend services
│   ├── dockerfile                     # Docker setup for backend deployment
│   ├── ingestion/                     # Documents and tools for RAG ingestion pipeline
│   ├── requirements.txt               # Python dependencies for RAG
│   ├── src/                           # Core logic for RAG chatbot
│   ├── storageContext/                # Metadata storage logic
│   └── vectorstore/                   # ChromaDB vector store for document retrieval

├── android/                           # Android platform support
├── ios/                               # iOS platform support
├── linux/                             # Linux platform support
├── macos/                             # macOS platform support
├── web/                               # Web platform support
└── windows/                           # Windows platform support
```



## Implementation of Google Technologies
![Google Technologies in Lucerna](https://drive.google.com/uc?export=view&id=1iy7aOMh-o9AQECjy3RfdaOXPhm2PAiFq)



## Features
Here is what you can achieve through Lucerna source code:


### Carbon Tracking
Provide users with clear, interactive charts and graphs that track their weekly and daily carbon footprint, including detailed breakdowns by category.
Users' carbon footprint are also compared with their carbon offset efforts —empowering users to understand their environmental impact at a glance.

### Carbon Offset with Ecolight
Track the total carbon offset achieved with Ecolight and trasmit the relevant data in real time, ensuring continuous performance tracking.

### Carbon Footprint Calculation
Offers category-specific carbon calculations (food, travel, energy) based on user inputs, enabling precise, individualized tracking unlike competitors that rely on broad lifestyle estimates. For food records, snap a photo of your meal to instantly see its carbon footprint as our AI detects each food item and calculates its impact using Gemini.

### Eco-Education with AI
RAG-enhanced Conversations: Engage with an AI assistant to learn more about personalised carbon footprint reduction strategies, environmental issues, thus promoting eco-conscious choices in daily life.



## Instructions
> [!IMPORTANT]  
> As our food detection model and RAG-powered chatbot take 3-5 mins to be initialised when the app first launched, feel free to explore other feature first. Good things (and greener futures) take a little time!

  
1. Register/Login:
   Start by creating an account or logging in with your credentials (email and password).
   > For app testing purpose, you may use `user@gmail.com` (email) and `123456` (password) to login.    
   <img src="https://drive.google.com/uc?export=view&id=1VTR7iPK4KoPZd6LO397KLlVvecu7aHTd" alt="Lucerna Login" height="500"/>

2. Dashboard
   Use the Lucerna dashboard to monitor carbon emissions and the Ecolight's carbon offset, in a daily or weekly timeframe.
   Besides your latest carbon footprint record, an environmental awareness advertisement is display too.
   > The two daily charts will not be shown if no carbon footprint is recorded for today yet. Start tracking your carbon footprint to unlock your daily insights and drive meaning change :)    
   <img src="https://drive.google.com/uc?export=view&id=1VbjjH0o-WV9WT_iE7aT-ph2cL75xJAak" alt="Lucerna Dashboard" height="500"/>
   
3. Ecolight Measures   
   View real-time environmental data gathered by Ecolight to track CO₂ emissions and physical conditions.     
   <img src="https://drive.google.com/uc?export=view&id=1VYe7gv-yHIVxkQicDFjUUBCO720AyqZl" alt="Lucerna Ecolight Measures" height="500"/>
   
4. Carbon Footprint   
   Record daily activities (Food, travel journey, or energy consumption) and use the Gemini AI-powered calculator for personalized carbon footprint insights.    
   <img src="https://drive.google.com/uc?export=view&id=1VWyNxrj_f82zrpp-71mhTzBE9L6ElaZJ" alt="Lucerna Carbon Footprint" height="500"/>
   
5. Chat with AI   
   Start a conversation with Lucerna’s AI to discuss more on your actual carbon footprint record, while staying informed on data-backed eco-friendly practices and environmental issues.    
   <img src="https://drive.google.com/uc?export=view&id=1VWGpXuzAzVUHmJSyHBD8aD-59hYsk3vz" alt="Lucerna Chat with AI" height="500"/>

7. My Profile   
   Manage your profile (username and email) and API keys.    
   > [!NOTE]
   > If you encountered **Gemini API Resource Exhausted** error, kindly place your own API key in `API Keys` -> `Gemini API Key`.
   > Access [here](https://makersuite.google.com/app/apikey) to create your API key.
   <img src="https://drive.google.com/uc?export=view&id=1VWMbV-SmbfROmCuGbTy1cXj9Root4G7w" alt="Lucerna My Profile" height="500"/>



## Development Environment Setup  


1. Java version: `22.0.2`
2. Gradle version: `8.3`

> [!TIP]  
> To run the Flutter project for the first time, run `flutter clean` -> `flutter pub get` -> `flutter build apk`.



## Features under Development
Due to the time contraint, these features are still under development, and the codes provided are actually the non-functional prototypes (dummy codes):


##### 1. Score & Reward System
We are aiming to develop a Score & Reward System in collaboration with nonprofit organizations focused on climate action. This system will allow users to earn points by participating in verified environmental initiatives or committing to eco-friendly practices. Accumulated points can later be redeemed for meaningful rewards, encouraging ongoing engagement and promoting sustainable lifestyle choices.

##### 2. Carbon Offset Tracking
While our platform currently supports real-time carbon offset estimation, this data is not yet persistently stored. As a result, users will not be able to view historical offset data or track long-term progress. We are working on enhancing this functionality to include offset history tracking and retrieval, ensuring users can monitor their full environmental impact over time.

##### 3. IoT Device Connection
Lucerna collects real-time statistic only from a particular Ecolight product. Users are unable to connect their own Ecolight products to respective user accounts yet.
  > Random values (Light Intensity, Carbon Dioxide, Temparature and Algae Bloom Status) are displayed for user who does not own and connect Ecolight product.

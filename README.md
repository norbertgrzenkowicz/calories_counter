# Japer - AI-Powered Food Scanner & Nutrition Tracker

A sophisticated Flutter mobile application that leverages computer vision and artificial intelligence to automatically identify food items, calculate nutritional information, and help users track their dietary intake.

![Flutter](https://img.shields.io/badge/Flutter-%2302569B.svg?style=for-the-badge&logo=Flutter&logoColor=white)
![Python](https://img.shields.io/badge/python-3670A0?style=for-the-badge&logo=python&logoColor=ffdd54)
![Supabase](https://img.shields.io/badge/Supabase-3ECF8E?style=for-the-badge&logo=supabase&logoColor=white)
![OpenAI](https://img.shields.io/badge/OpenAI-412991.svg?style=for-the-badge&logo=openai&logoColor=white)

## 🚀 Features

### 📸 Smart Food Recognition
- **Camera Integration**: Capture food images directly through the app
- **Barcode Scanning**: Quick product lookup using barcode scanning
- **AI-Powered Analysis**: GPT-4 Vision model for accurate food identification and portion estimation

### 🥗 Nutrition Tracking
- **Automated Nutrition Calculation**: Instant nutritional breakdown (calories, protein, carbs, fats)
- **Meal History**: Track daily food intake with calendar view
- **Weight Tracking**: Monitor weight changes over time with visual charts
- **Progress Analytics**: Visual charts and progress indicators

### 🔐 User Management
- **Secure Authentication**: User registration and login with Supabase
- **Profile Management**: Personalized user profiles and dietary goals
- **Data Persistence**: Cloud storage with offline fallback

### 📱 Cross-Platform
- **iOS & Android**: Native performance on both platforms
- **Responsive Design**: Optimized for different screen sizes
- **Material Design**: Modern UI following Material Design principles

## 🏗️ Architecture

```
📦 Japer
├── 📱 flutter_app/          # Flutter mobile application
│   ├── lib/
│   │   ├── models/          # Data models (Meal, User, etc.)
│   │   ├── screens/         # UI screens
│   │   ├── services/        # Business logic & API calls
│   │   └── widgets/         # Reusable UI components
│   └── pubspec.yaml         # Flutter dependencies
│
├── 🐍 backend/              # Python FastAPI backend
│   ├── app.py              # Main API server
│   ├── requirements.txt    # Python dependencies
│   └── implementation_plans/ # Technical documentation
│
└── 📄 Database Schemas      # Supabase table schemas
```

## 🛠️ Technology Stack

**Frontend:**
- Flutter 3.0+
- Dart
- Camera integration
- Google Maps integration
- Chart visualization (FL Chart)

**Backend:**
- Python 3.8+
- FastAPI
- OpenAI GPT-4 Vision API
- Uvicorn ASGI server

**Database & Storage:**
- Supabase (PostgreSQL)
- Cloud storage for images
- Real-time subscriptions

**External APIs:**
- OpenFoodFacts API for barcode lookup
- OpenAI GPT-4 Vision for food analysis

## ⚙️ Setup & Installation

### Prerequisites
- Flutter SDK 3.0+ 
- Python 3.8+
- OpenAI API key
- Supabase account

### Backend Setup
```bash
cd backend
pip install -r requirements.txt
export OPENAI_API_KEY=your_api_key_here
python app.py
```

### Flutter App Setup
```bash
cd flutter_app
flutter pub get

# Run with Supabase configuration
flutter run --dart-define=SUPABASE_URL=your_supabase_url \
            --dart-define=SUPABASE_ANON_KEY=your_supabase_anon_key
```

### Environment Variables
Create a `.env` file for backend configuration:
```bash
OPENAI_API_KEY=your_openai_api_key
```

For Flutter, use `--dart-define` flags:
```bash
SUPABASE_URL=your_supabase_project_url
SUPABASE_ANON_KEY=your_supabase_anon_key
```

## 📱 Screenshots

The app includes multiple screens for comprehensive nutrition tracking:
- Splash screen with app initialization
- User authentication (login/register)
- Dashboard with daily nutrition overview
- Camera capture for food scanning
- Barcode scanner for packaged foods
- Meal detail views with nutrition breakdown
- Calendar view for meal history
- Profile management and settings

## 🧪 Development Features

### Database Schema
The app includes comprehensive database schemas for:
- User profiles and authentication
- Meal tracking with nutritional data
- Weight history and progress tracking
- Cached product information from barcode scans

### Caching System
- **Local SQLite**: Offline data storage
- **Supabase Cache**: Cloud-based product information cache
- **OpenFoodFacts Integration**: Fallback for unknown barcodes

## 🚀 Deployment

The backend can be deployed to various platforms:
- Google Cloud Functions
- AWS Lambda
- Traditional VPS/Docker containers

The Flutter app can be built for:
- iOS App Store
- Google Play Store
- Web deployment

## 🤝 Contributing

This project demonstrates modern mobile development practices including:
- Clean architecture patterns
- Responsive design principles
- Secure API key management
- Comprehensive error handling
- Offline-first data strategy

## 📄 License

This project is part of a portfolio demonstration showcasing full-stack mobile development capabilities.
# Jacob's Ranch & Stables iOS App

The Jacob's Ranch & Stables App gives boarders fast access to everything they need to manage their horses and boarding arrangements, all in one place. The app centralizes horse data, contracts, billing, and communication into a single reliable platform for both boarders and ranch staff.

## Core Purpose
The app serves as a digital hub for each horse's critical contact information. In any emergency, ranch staff and boarders can instantly access:
- Owner contact
- Emergency contact
- Veterinarian contact
- Additional authorized contacts

No more searching through paperwork, texts, or binders. Everything is available immediately.

## What the App Provides

### Home Dashboard
- Ranch-wide data such as:
  - Available stalls
- Quick navigation to Stalls, Boarding, Forms, and Horse Identification, & Profile

### Stalls
- Visual layout of the indoor arena stalls
- Each stall dynamically loads assigned horse data from Supabase
- Tapping a stall displays:
  - Horse name
  - Owner information
  - Emergency contact
  - Veterinarian contact

### Forms
- A digital copy of the boarding contract
- Stored securely in Supabase Storage
- Accessible anytime in the Forms tab

### Boarding and Billing
- Monthly rent breakdown including:
  - Stall fees
  - Trailer parking
  - Shared Wi-Fi cost
- Automatic fee calculations based on user settings
- Clear rent total displayed each month
- Simple, streamlined Zelle payment instructions
- Bank deep links (Chase, Bank of America, Wells Fargo)
- Clipboard fallback for other banks

### Horse Identification
- Take a photo using the device camera or upload a photo from the library
- Image is sent to the AI backend for identification
- Displays:
  - Predicted horse identity
  - Confidence score with explanation
- Confidence interpretation:
  - 93 to 99 percent: Near perfect match
  - 88 to 92 percent: Very strong confidence
  - 75 to 87 percent: Likely match
  - Below 75 percent: Low confidence

## How to Run the App

### Start the Horse Identification Backend
- Open Terminal
- Navigate to the backend folder:
  - cd ~/Downloads/Xcode/jacobsranch/horseidentitybackend
- Start the FastAPI server:
  - uvicorn main:app --reload
- When successful, you will see:
  - Uvicorn running on http://127.0.0.1:8000
  - Application startup complete.
- Verify the backend by visiting:
  - http://127.0.0.1:8000/docs
- The backend must be running for the Horse Identification feature to work.

### Run the iOS App
- Open the Jacob's Ranch Xcode project
- Select an iPhone simulator
- Press Run in Xcode
- The app will automatically connect to Supabase and the backend.

## Tech Stack

### iOS App 
- Swift
- SwiftUI
- Supabase iOS SDK

### Horse Identification Backend
- Python
- FastAPI
- Uvicorn
- python-multipart
- AI image classification model

### Database and Storage
- Supabase PostgreSQL
- Supabase Authentication
- Supabase Storage


## Overall Goal
To replace scattered paperwork, group chats, and manual billing with a single, organized, reliable app that:

- Keeps horse information updated
- Stores all boarder preferences
- Gives staff easy access during emergencies
- Centralizes all ranch communication and data

Everything stays clean, accurate, and accessible whenever it is needed.

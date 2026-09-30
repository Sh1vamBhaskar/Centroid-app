# Centroid Flutter App

### Android Frontend for Centroid

This directory contains the Flutter-based Android application for **Centroid**, a location-based social and real-time chat platform.

The Flutter application communicates with the Centroid Spring Boot backend through REST APIs and WebSocket/STOMP for real-time messaging.

---

## Overview

The Centroid Flutter application provides the mobile interface for:

- User authentication
- Profile management
- Location sharing
- Nearby-user discovery
- Proximity-based visualization
- User profile interaction
- Connection requests
- Conversation management
- Real-time chat

The application acts as the client layer of the complete Centroid system.

---

## Features

- 🔐 Login and authentication
- 👤 User profile interface
- 📍 Location-based discovery
- 🎯 Adjustable discovery radius
- 🗺️ Nearby-user visualization
- 👥 Nearby user profiles
- 👋 "Say Hi" connection requests
- ✅ Accept / Decline interaction workflow
- 💬 Conversation interface
- ⚡ Real-time WebSocket chat
- 🔑 Secure JWT storage
- 📱 Android device support
- ⚠️ Loading, empty, and error states

---

# Application Flow

```text
Login
  ↓
Nearby Users
  ↓
Select Radius
  ↓
View Nearby User
  ↓
Open Profile
  ↓
Say Hi
  ↓
Connection Accepted
  ↓
Conversation
  ↓
Real-Time Chat

Frontend Architecture
The Flutter application is organized around screens, models, services, and reusable widgets.
frontend/
│
├── android/
│
├── lib/
│   ├── models/
│   ├── screens/
│   ├── services/
│   ├── widgets/
│   └── ...
│
├── test/
│
├── pubspec.yaml
├── pubspec.lock
└── analysis_options.yaml

Main Components
Screens
The application contains UI screens responsible for the main user journey, including:
- Login
- Nearby users
- User profile
- Conversation / chat
- Other supporting application screens
Models
The models/ directory contains Dart models used to represent data received from the backend.
For example, nearby-user information contains:
User ID
Display Name
Profile Picture
Distance

These models convert backend JSON responses into strongly typed Dart objects.
Services
The services/ layer handles communication between the Flutter application and the Spring Boot backend.
Responsibilities include:
- Authentication requests
- JWT handling
- Nearby-user API calls
- Profile API calls
- Interaction requests
- Conversation APIs
- Message APIs
- WebSocket communication
Widgets
Reusable UI components are maintained inside the widgets/ directory.
Examples include components used for:
- Nearby-user visualization
- User bubbles
- Chat UI
- Reusable interface elements
Backend Communication
The Flutter application communicates with the Spring Boot backend using two primary mechanisms.
REST APIs
REST APIs are used for operations such as:
Login
Profile management
Location management
Nearby-user discovery
Interaction requests
Conversation creation
Message history

Example API:
GET /api/location/nearby?radius=1000

WebSocket / STOMP
WebSocket/STOMP is used for real-time chat communication.
The Flutter client connects to:
/ws

and communicates through STOMP destinations for sending and receiving chat messages.
The general flow is:
Flutter Chat Screen
       ↓
STOMP WebSocket
       ↓
Spring Boot WebSocket Controller
       ↓
Message Service
       ↓
Database
       ↓
STOMP Topic
       ↓
Connected Flutter Clients

Authentication
The Flutter application uses JWT-based authentication provided by the Centroid backend.
The general flow is:
User Login
    ↓
Spring Boot Authentication API
    ↓
JWT Token
    ↓
Secure Storage
    ↓
Bearer Token
    ↓
Authenticated API Requests

JWT credentials are stored using:
flutter_secure_storage

The token is then attached to authenticated API requests.
Nearby User Discovery
The nearby-user screen retrieves users from the backend based on the selected discovery radius.
Example:
GET /api/location/nearby?radius=1000

The backend returns information such as:
{
  "userId": 4,
  "displayName": "User",
  "profilePicture": "https://example.com/profile.jpg",
  "distanceMeters": 111.07
}

The Flutter application converts this response into a NearbyUser model.
The nearby-user visualization uses:
- User distance
- Selected discovery radius
- Concentric distance rings
- Nearby-user bubbles
- User profile information
Proximity Visualization
The nearby screen visually represents users according to their distance from the current user.
Conceptually:
             Nearby User
                  ●
                  |
          ┌───────┼───────┐
          │       │       │
          │    Current    │
          │      User     │
          │       ●       │
          │               │
          └───────────────┘

The current implementation uses the backend-provided distance to determine the relative radial position of nearby users.
The backend currently returns distance but not geographic bearing. Therefore, the current Flutter visualization uses a deterministic positioning strategy for the angular placement of users.
A future version can use actual geographic bearing returned by the backend for more geographically accurate positioning.
Interaction Flow
The Flutter application provides a "Say Hi" action from a nearby user's profile.
Nearby User
     ↓
View Profile
     ↓
Say Hi
     ↓
POST /api/interactions
     ↓
Pending Request
     ↓
Accept / Decline

If the request is accepted:
Accepted
   ↓
Conversation Created
   ↓
Open Chat

If declined:
Declined
   ↓
Interaction Ends

Chat
The chat interface supports both REST and WebSocket communication.
Message History
Existing messages can be retrieved through the backend:
GET /api/messages/{conversationId}

Real-Time Messages
New messages are delivered through WebSocket/STOMP.
Flutter Client
     ↓
STOMP SEND
     ↓
/app/chat
     ↓
Spring Boot
     ↓
/topic/chat/{conversationId}
     ↓
Flutter Clients

This allows users to receive messages without repeatedly polling the backend.
Dependencies
The Flutter application uses packages for functionality such as:
- Secure credential storage
- Geolocation
- HTTP communication
- WebSocket/STOMP communication
- Flutter UI components
Install all project dependencies with:
flutter pub get

Requirements
Before running the application, install:
- Flutter SDK
- Dart SDK
- Android Studio
- Android SDK
- Android emulator or physical Android device
Verify the Flutter environment:
flutter doctor

Running the Application
1. Navigate to the Frontend
From the Centroid repository root:
cd frontend

2. Install Dependencies
flutter pub get

3. Check the Project
Run:
flutter analyze

The project should complete analysis without errors.
4. Connect an Android Device
Either:
- Start an Android emulator, or
- Connect a physical Android device with USB debugging enabled.
Check available devices:
flutter devices

5. Run the Application
flutter run

Backend Configuration
The Flutter application needs to communicate with a running Centroid Spring Boot backend.
The API base URL is configured inside the Flutter networking service.
For example, when using a physical Android device:
static const String baseUrl =
    'http://192.168.x.x:8080';

Replace the address with the local IP address of the computer running the Spring Boot backend.
The Android device and backend machine should be connected to the same network.
Development Workflow
A typical development workflow is:
Start PostgreSQL + PostGIS
          ↓
Start Spring Boot Backend
          ↓
Connect Android Device
          ↓
Run Flutter Application
          ↓
Login
          ↓
Test Nearby Discovery
          ↓
Test Interaction
          ↓
Test Conversation
          ↓
Test Real-Time Chat

Testing
The frontend was tested as part of the complete Centroid workflow.
Key scenarios include:
- Login with valid credentials
- Login failure handling
- Loading states
- Empty nearby-user state
- Nearby-user retrieval
- User profile interaction
- Sending connection requests
- Handling accepted interactions
- Handling declined interactions
- Conversation access
- Message history
- Real-time WebSocket messaging
- Backend connectivity from a physical Android device
Flutter static analysis can be run with:
flutter analyze

Project Status
Completed
The Flutter frontend has been integrated with the Centroid Spring Boot backend and supports the core application workflow from authentication and nearby-user discovery through connection requests, conversations, and real-time chat.
Related Project
The complete Centroid application is maintained in the parent repository:
Centroid-app/
│
├── frontend/       ← Flutter Android application
│
└── src/            ← Spring Boot backend

For the complete system architecture, backend implementation, database setup, API documentation, security model, and deployment information, refer to the root README.md.
Author
Shivam Bhaskar
B.Tech Computer Science Engineering
```

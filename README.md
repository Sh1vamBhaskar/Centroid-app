# Centroid

### Location-Based Social & Real-Time Chat Platform

Centroid is a full-stack location-based social and chat application that allows users to discover people nearby, view their profiles, send connection requests, and communicate through real-time messaging after a connection is accepted.

The project combines a Flutter Android application with a Spring Boot backend, PostgreSQL/PostGIS for location-aware data, JWT-based authentication, and WebSocket/STOMP for real-time communication.

---

## Overview

Centroid is built around a simple idea:

> Discover people around you, connect with them, and start a conversation.

Users can:

- Create an account and authenticate securely
- Create and manage their profile
- Share their location for discovery
- Choose a discovery radius
- Discover nearby users based on actual geographic distance
- View nearby users and their profiles
- Send a "Say Hi" connection request
- Accept or decline incoming requests
- Create conversations after a connection is accepted
- Exchange messages in real time

---

## Features

- 🔐 JWT-based user authentication
- 👤 User profile management
- 📍 Location-based nearby-user discovery
- 🎯 Configurable discovery radius
- 🔒 User-controlled location discoverability
- ⏱️ Location freshness validation
- 🤝 Connection request system
- ✅ Accept / Decline interaction workflow
- 💬 Conversation management
- ⚡ Real-time chat using WebSocket/STOMP
- 🗄️ PostgreSQL with PostGIS spatial support
- 📱 Flutter-based Android application
- 🔑 Secure JWT storage on the mobile client

---

## Application Flow

```text
                    ┌──────────────────┐
                    │  Register / Login│
                    └────────┬─────────┘
                             │
                             ▼
                    ┌──────────────────┐
                    │ Create / Update  │
                    │     Profile      │
                    └────────┬─────────┘
                             │
                             ▼
                    ┌──────────────────┐
                    │  Share Location  │
                    └────────┬─────────┘
                             │
                             ▼
                    ┌──────────────────┐
                    │ Set Discovery    │
                    │     Radius       │
                    └────────┬─────────┘
                             │
                             ▼
                    ┌──────────────────┐
                    │ Discover Nearby  │
                    │      Users       │
                    └────────┬─────────┘
                             │
                             ▼
                    ┌──────────────────┐
                    │ View User Profile│
                    └────────┬─────────┘
                             │
                             ▼
                    ┌──────────────────┐
                    │    Send "Hi"     │
                    └────────┬─────────┘
                             │
                             ▼
                    ┌──────────────────┐
                    │ Accept / Decline │
                    └───────┬───┬──────┘
                            │   │
                       Accept   │ Decline
                            │   │
                            ▼   ▼
                   ┌──────────────┐  Request Ends
                   │ Conversation │
                   └───────┬──────┘
                           │
                           ▼
                   ┌──────────────┐
                   │  Real-Time   │
                   │     Chat     │
                   └──────────────┘

System Architecture
┌─────────────────────────────────────┐
│          Flutter Android App        │
│                                     │
│  Authentication                     │
│  Profile Management                 │
│  Nearby User Discovery              │
│  Interaction UI                     │
│  Conversation UI                    │
│  Chat Interface                     │
└──────────────────┬──────────────────┘
                   │
          REST API │ WebSocket/STOMP
                   │
                   ▼
┌─────────────────────────────────────┐
│          Spring Boot Backend        │
│                                     │
│  ┌───────────────────────────────┐  │
│  │ Authentication & Security     │  │
│  ├───────────────────────────────┤  │
│  │ Profile Management            │  │
│  ├───────────────────────────────┤  │
│  │ Location Services             │  │
│  ├───────────────────────────────┤  │
│  │ Interaction Management        │  │
│  ├───────────────────────────────┤  │
│  │ Conversation Management       │  │
│  ├───────────────────────────────┤  │
│  │ Messaging & WebSocket         │  │
│  └───────────────────────────────┘  │
└──────────────────┬──────────────────┘
                   │
                   ▼
┌─────────────────────────────────────┐
│         PostgreSQL + PostGIS        │
│                                     │
│  Users                              │
│  Profiles                           │
│  Locations                          │
│  Interactions                       │
│  Conversations                      │
│  Messages                           │
└─────────────────────────────────────┘

Tech Stack
Frontend
- Flutter
- Dart
- Android
- REST API integration
- WebSocket/STOMP
- flutter_secure_storage
- Geolocation
Backend
- Java
- Spring Boot
- Spring Security
- JWT
- REST APIs
- WebSocket
- STOMP
- Spring Data JPA
- Hibernate
- Hibernate Spatial
Database
- PostgreSQL
- PostGIS
Development Tools
- Android Studio
- IntelliJ IDEA / VS Code
- Git
- GitHub
- Postman
Project Structure
Centroid-app/
│
├── frontend/                       # Flutter Android application
│   ├── android/
│   ├── lib/
│   │   ├── models/
│   │   ├── screens/
│   │   ├── services/
│   │   ├── widgets/
│   │   └── ...
│   ├── test/
│   ├── pubspec.yaml
│   └── README.md
│
├── src/                            # Spring Boot backend
│   └── main/
│       ├── java/
│       │   └── com/
│       │       └── bhaskar/
│       │           └── centroid/
│       │               ├── auth/
│       │               ├── chat/
│       │               ├── config/
│       │               ├── dto/
│       │               ├── interaction/
│       │               ├── location/
│       │               ├── profile/
│       │               └── security/
│       │
│       └── resources/
│
├── pom.xml
├── mvnw
├── mvnw.cmd
└── README.md

Core Modules
1. Authentication
Centroid uses JWT-based authentication with Spring Security.
The authentication flow is:
Login
  ↓
Credentials Validation
  ↓
JWT Generation
  ↓
Secure Token Storage
  ↓
Bearer Token
  ↓
JWT Authentication Filter
  ↓
Authenticated Request

Protected backend endpoints require a valid JWT.
2. Profile Management
Users can create and update their profile information.
Main endpoints:
POST /api/profile
GET  /api/profile/me
PUT  /api/profile/me

Profile information is also used when displaying nearby users.
3. Location-Based Discovery
Centroid uses PostgreSQL with PostGIS to perform geographic queries.
Nearby-user discovery uses:
ST_DWithin
ST_Distance

ST_DWithin is used to filter users within the requested radius, while ST_Distance calculates the actual geographic distance.
Example:
GET /api/location/nearby?radius=1000

The supported radius range is:
50m - 5000m

The backend also validates location freshness so that stale locations are not treated as current.
4. Location Discoverability
Users can control whether their location is available for nearby-user discovery.
This separates:
Location exists

from:
Location is discoverable

This provides an additional privacy control without requiring the user to remove their stored location.
5. Interaction System
Centroid uses a connection-request workflow before allowing users to start a conversation.
Interaction states:
PENDING
ACCEPTED
DECLINED

Main endpoints:
POST /api/interactions
GET  /api/interactions/pending
PUT  /api/interactions/{id}/accept
PUT  /api/interactions/{id}/decline

The backend validates rules including:
- Users cannot send requests to themselves.
- Duplicate pending requests are rejected.
- Existing accepted connections cannot be duplicated.
- Reverse pending/accepted interactions are handled.
- Declined interactions can be retried.
Conversations
A conversation is created only after an interaction has been accepted.
Interaction
     │
     ▼
  ACCEPTED
     │
     ▼
Conversation
     │
     ▼
 Messages

To prevent duplicate conversations between two users, the backend maintains a canonical ordering of the two participants.
Therefore:
User A ↔ User B

and:
User B ↔ User A

resolve to the same conversation.
Real-Time Chat
Centroid supports both REST-based messaging and WebSocket-based real-time communication.
REST Messaging
REST APIs are used for operations such as sending messages and retrieving message history.
POST /api/messages/{conversationId}

GET /api/messages/{conversationId}

The backend verifies that the requesting user is a participant in the conversation.
WebSocket Messaging
WebSocket/STOMP is used for real-time message delivery.
WebSocket endpoint:
/ws

Application destination:
/app/chat

Conversation subscription:
/topic/chat/{conversationId}

The general flow is:
Flutter Client
      │
      │ STOMP SEND
      ▼
Spring Boot WebSocket Controller
      │
      ▼
Message Service
      │
      ▼
PostgreSQL
      │
      ▼
STOMP Broker
      │
      ▼
Subscribed Clients

This allows messages to be delivered in real time without repeatedly polling the backend.
Security & Privacy
Centroid applies authentication, authorization, and privacy controls at the backend level.
Security
- JWT authentication
- Spring Security
- Password hashing
- Protected REST endpoints
- Backend authorization checks
- Conversation participant validation
- Secure JWT storage on the Flutter client
Location Privacy
The nearby-user response does not expose another user's exact geographic coordinates.
Instead, the response provides information such as:
{
  "userId": 4,
  "displayName": "User",
  "profilePicture": "https://example.com/profile.jpg",
  "distanceMeters": 111.07
}

Additional privacy controls include:
- Location discoverability
- Location freshness validation
- Minimal response DTOs
- Authentication and authorization
API Overview
Module	Endpoint	Method
Profile	/api/profile	POST
Profile	/api/profile/me	GET
Profile	/api/profile/me	PUT
Location	/api/location	PUT
Location	/api/location/me	GET
Location	/api/location/discoverable	PUT
Location	/api/location/nearby	GET
Interaction	/api/interactions	POST
Interaction	/api/interactions/pending	GET
Interaction	/api/interactions/{id}/accept	PUT
Interaction	/api/interactions/{id}/decline	PUT
Conversation	/api/conversations/from-interaction/{interactionId}	POST
Messages	/api/messages/{conversationId}	POST
Messages	/api/messages/{conversationId}	GET
WebSocket	/ws	STOMP


Getting Started
Prerequisites
Backend
- Java 17+
- PostgreSQL
- PostGIS
- Git
Frontend
- Flutter SDK
- Android Studio
- Android SDK
- Android device or emulator
Backend Setup
1. Clone the Repository
git clone https://github.com/Sh1vamBhaskar/Centroid-app.git
cd Centroid-app

2. Configure PostgreSQL
Create a PostgreSQL database for Centroid.
Enable PostGIS:
CREATE EXTENSION IF NOT EXISTS postgis;

3. Configure Environment Variables
The backend expects:
DB_PASSWORD=your_database_password
JWT_SECRET=your_jwt_secret

Do not commit actual credentials or secrets to the repository.
4. Run the Backend
Windows
.\mvnw.cmd spring-boot:run

Linux / macOS
./mvnw spring-boot:run

The backend runs on:
http://localhost:8080

Frontend Setup
1. Navigate to the Flutter Application
cd frontend

2. Install Dependencies
flutter pub get

3. Configure the Backend URL
For a physical Android device, configure the Flutter API base URL to point to the computer running the Spring Boot backend.
Example:
static const String baseUrl =
    'http://192.168.x.x:8080';

The Android device and backend machine should be connected to the same network.
4. Run the Application
flutter run

Testing
The core application flow was tested end-to-end:
Authentication
      ↓
Profile
      ↓
Location
      ↓
Nearby Discovery
      ↓
Interaction
      ↓
Conversation
      ↓
REST Messaging
      ↓
WebSocket Messaging

Negative cases were also tested, including:
- Invalid authentication
- Duplicate interaction requests
- Self-interactions
- Invalid interaction states
- Unauthorized conversation access
- Non-participant message access
The Flutter application was tested on a physical Android device.
Future Improvements
Potential future improvements include:
- Geographic bearing-based nearby-user positioning
- Push notifications
- Message delivery and read status
- Typing indicators
- User blocking and reporting
- Message pagination
- Rate limiting
- HTTPS/WSS deployment
- Production-grade WebSocket broker
- Automated unit and integration testing
- Improved location privacy controls
- Cloud deployment and monitoring
Repository Structure
Centroid is maintained as a single repository containing both the mobile frontend and backend:
Centroid-app
│
├── frontend/       → Flutter Android application
│
└── src/            → Spring Boot backend

Keeping both components in one repository makes it easier to develop, test, and maintain the complete application as a single project.
Author
Shivam Bhaskar
B.Tech Computer Science Engineering
GitHub:
https://github.com/Sh1vamBhaskar/Centroid-app
Project Status
Completed
The core Centroid workflow — authentication, profile management, location-based discovery, connection requests, conversations, REST messaging, and real-time WebSocket chat — has been implemented and integrated across the Flutter frontend and Spring Boot backend.
```

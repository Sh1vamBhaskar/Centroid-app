# Centroid

### Location-Based Social & Real-Time Chat Platform

Centroid is a full-stack location-based social and chat application that allows users to discover nearby people, send connection requests, create conversations, and communicate through real-time messaging.

The application combines a Flutter mobile frontend with a Spring Boot backend, PostgreSQL/PostGIS for spatial data, JWT-based authentication, and WebSocket/STOMP for real-time communication.

---

## Features

- 🔐 JWT-based user authentication
- 👤 User profile management
- 📍 Location-based nearby-user discovery
- 🎯 Customizable discovery radius
- 🔒 User-controlled location discoverability
- ⏱️ Location freshness validation
- 🤝 Connection request system
- ✅ Accept / Decline interaction workflow
- 💬 Conversation management
- ⚡ Real-time chat using WebSocket/STOMP
- 🗄️ PostgreSQL database with PostGIS spatial support
- 📱 Flutter-based Android application
- 🔑 Secure JWT storage on the mobile client

---

## Application Flow


Register / Login
       ↓
    Profile
       ↓
 Share Location
       ↓
Nearby User Discovery
       ↓
 View User Profile
       ↓
     Say Hi
       ↓
 Accept / Decline
       ↓



" System Architecture  "
┌─────────────────────────────┐
│       Flutter Mobile App    │
│                             │
│  Login / Profile            │
│  Nearby Users               │
│  Interaction UI             │
│  Chat Interface             │
└──────────────┬──────────────┘
               │
        REST API / JWT
               │
        WebSocket / STOMP
               │
               ▼
┌─────────────────────────────┐
│       Spring Boot API       │
│                             │
│ Authentication              │
│ Profile Management          │
│ Location Services           │
│ Interaction Management      │
│ Conversation Management     │
│ Messaging                   │
│ WebSocket Chat              │
└──────────────┬──────────────┘
               │
               ▼
┌─────────────────────────────┐
│     PostgreSQL + PostGIS    │
│                             │
│ Users                       │
│ Profiles                    │
│ Locations                   │
│ Interactions                │
│ Conversations               │
│ Messages                    │
└─────────────────────────────┘

## Tech Stack


{ Frontend }

- Flutter
- Dart
- Android
- REST API integration
- WebSocket/STOMP
- flutter_secure_storage
- Geolocation services
  
{ Backend }

- Java
- Spring Boot
- Spring Security
- JWT
- REST APIs
- WebSocket
- STOMP
- Hibernate / JPA
- Hibernate Spatial
  
{ Database }

- PostgreSQL
- PostGIS
  
{ Development Tools }

- Android Studio
- IntelliJ IDEA / VS Code
- Git & GitHub
- Postman
  
[Project Structure]
Centroid-app/
│
├── frontend/                       # Flutter mobile application
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
├── src/
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
│       │               ├── security/
│       │               └── ...
│       │
│       └── resources/
│
├── pom.xml
├── mvnw
├── mvnw.cmd
└── README.md

Backend Setup
Prerequisites
Make sure the following are installed:
- Java 17+
- Maven
- PostgreSQL
- PostGIS
- Git
1. Clone the Repository
git clone https://github.com/Sh1vamBhaskar/Centroid-app.git
cd Centroid-app

2. Configure PostgreSQL
Create a PostgreSQL database for Centroid.
PostGIS must be enabled in the database:
CREATE EXTENSION IF NOT EXISTS postgis;

The application uses PostGIS for storing and querying geographic locations.
3. Configure Environment Variables
The backend uses environment variables for sensitive configuration.
Set:
DB_PASSWORD=your_database_password
JWT_SECRET=your_jwt_secret

The application configuration expects:
spring.datasource.password=${DB_PASSWORD}
jwt.secret=${JWT_SECRET}
jwt.expiration=3600000

Do not commit real credentials or secrets to GitHub.
4. Run the Backend
From the repository root:
Windows
.\mvnw.cmd spring-boot:run

Linux / macOS
./mvnw spring-boot:run

The backend runs on:
http://localhost:8080

Frontend Setup
Prerequisites
- Flutter SDK
- Android Studio
- Android SDK
- Android device or emulator
Check Flutter installation:
flutter doctor

1. Navigate to the Flutter Project
cd frontend

2. Install Dependencies
flutter pub get

3. Configure Backend URL
The Flutter application communicates with the Spring Boot backend.
For a physical Android device, use the local IP address of the computer running the backend.
Example:
static const String baseUrl =
    'http://192.168.x.x:8080';

Make sure the Android device and the computer running the backend are connected to the same network.
4. Run the Application
flutter run

Core Backend Modules
Authentication
Centroid uses JWT-based authentication.
The authentication flow is:
Login
  ↓
Credentials validated
  ↓
JWT generated
  ↓
JWT stored securely on client
  ↓
Bearer token sent with protected requests
  ↓
JwtAuthenticationFilter
  ↓
Authenticated request

The backend uses Spring Security to protect authenticated endpoints.
Profile Management
Users can create and manage their profile information.
Main endpoints:
POST /api/profile
GET  /api/profile/me
PUT  /api/profile/me

Location Discovery
Centroid uses PostgreSQL with PostGIS to perform spatial queries.
Nearby-user discovery uses:
ST_DWithin
ST_Distance

ST_DWithin is used to identify users within the requested radius, while ST_Distance is used to calculate the distance between users.
Example:
GET /api/location/nearby?radius=1000

The supported discovery radius is:
50m - 5000m

The backend also considers location freshness so that stale locations are not treated as current.
Discoverability
Users can control whether their location is available for nearby-user discovery.
This separates:
Location exists

from:
Location is discoverable

providing an additional privacy control.
Interaction System
Users can send connection requests to nearby users.
Interaction states:
PENDING
ACCEPTED
DECLINED

Main endpoints:
POST /api/interactions
GET  /api/interactions/pending
PUT  /api/interactions/{id}/accept
PUT  /api/interactions/{id}/decline

The backend validates business rules such as:
- Users cannot send requests to themselves.
- Duplicate pending requests are rejected.
- Existing accepted connections cannot be duplicated.
- Reverse pending/accepted interactions are handled by the service layer.
- A declined interaction can be retried.
Conversations
A conversation is created only after an interaction has been accepted.
Interaction
     ↓
  ACCEPTED
     ↓
Conversation
     ↓
Messages

To prevent duplicate conversations between the same two users, the backend maintains a canonical user ordering.
For example:
User A ↔ User B

and
User B ↔ User A

resolve to the same conversation rather than creating two separate conversations.
Real-Time Chat
Centroid supports both REST-based messaging and WebSocket-based real-time messaging.
REST
Used for operations such as:
Send message
Fetch message history

Example:
POST /api/messages/{conversationId}

GET /api/messages/{conversationId}

WebSocket
WebSocket/STOMP is used for real-time message delivery.
WebSocket endpoint:
/ws

Application destination:
/app/chat

Subscription example:
/topic/chat/{conversationId}

This allows connected users to receive messages without repeatedly polling the server.
Security
Security is handled at multiple layers:
- JWT authentication
- Spring Security
- Password hashing
- Authorization checks
- Conversation participant validation
- Secure JWT storage on the Flutter client
- Discoverability controls
- Minimal data exposure in nearby-user responses
For example, a user cannot access another user's conversation simply by knowing its ID. The backend verifies that the requesting user is a participant in the conversation.
Privacy Considerations
Centroid does not expose another user's exact geographic coordinates through the nearby-user response.
The nearby-user response contains information such as:
{
  "userId": 4,
  "displayName": "User",
  "profilePicture": "...",
  "distanceMeters": 111.07
}

The application therefore uses proximity information without directly exposing the user's stored coordinates.
Additional controls include:
- Location discoverability
- Location freshness validation
- JWT authentication
- Backend authorization
- Minimal DTO responses
Testing
The application was tested across the main user journey:
Authentication
     ↓
Profile
     ↓
Location
     ↓
Nearby discovery
     ↓
Interaction
     ↓
Conversation
     ↓
REST messaging
     ↓
WebSocket messaging

Negative cases were also tested, including:
- Invalid authentication
- Duplicate interaction requests
- Self-interactions
- Unauthorized conversation access
- Invalid interaction states
- Non-participant message access
The Flutter application was also tested on a physical Android device.
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


Future Improvements
Potential improvements for future versions include:
- Geographic bearing-based nearby-user positioning
- Push notifications
- Message delivery/read status
- Typing indicators
- User blocking and reporting
- Pagination for message history
- Rate limiting
- HTTPS/WSS deployment
- Production-grade WebSocket message broker
- Automated unit and integration testing
- Improved location privacy controls
- Cloud deployment and monitoring
Git Structure
Centroid is maintained as a single repository containing both the backend and frontend:
Centroid-app
│
├── Spring Boot Backend
│
└── Flutter Frontend

This keeps the complete application, API layer, database integration, and mobile client together in one repository.
Author
Shivam Bhaskar
B.Tech Computer Science Engineering
GitHub:
https://github.com/Sh1vamBhaskar
License
This project is developed for educational and portfolio purposes.

### A couple of changes I would make before committing this README

1. **Don't put your actual `JWT_SECRET` or database password anywhere in the README.**
2. Replace `192.168.x.x` with a generic example as above, rather than your actual local IP.
3. I would keep the **Future Improvements** section because it gives interviewers obvious areas to ask about.
4. The **Architecture + Application Flow + Core Backend Modules** sections are particularly useful for your Centroid interview because they make your technical contribution immediately visible.


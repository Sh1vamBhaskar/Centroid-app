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

```text
Register / Login
       ↓
Create / Update Profile
       ↓
Share Location
       ↓
Set Discovery Radius
       ↓
Discover Nearby Users
       ↓
View Nearby User Profile
       ↓
Send "Say Hi" Request
       ↓
Recipient Accepts / Declines
       ↓
        ┌───────────────┐
        │    ACCEPTED   │
        └───────┬───────┘
                ↓
       Conversation Created
                ↓
          Open Chat
                ↓
      Real-Time Messaging


Interaction Flow
User A
  │
  │ Say Hi
  ▼
User B
  │
  ├── Decline ──→ Request Ends
  │
  └── Accept
        │
        ▼
   Conversation
        │
        ▼
    Real-Time Chat





                 ┌──────────────────────┐
                 │    Flutter App       │
                 │      Android         │
                 └──────────┬───────────┘
                            │
                  REST API / JWT
                            │
                  WebSocket / STOMP
                            │
                            ▼
                 ┌──────────────────────┐
                 │    Spring Boot       │
                 │       Backend        │
                 ├──────────────────────┤
                 │ Authentication       │
                 │ Profile Management   │
                 │ Location Services    │
                 │ Interactions         │
                 │ Conversations        │
                 │ Messaging            │
                 └──────────┬───────────┘
                            │
                            ▼
                 ┌──────────────────────┐
                 │ PostgreSQL + PostGIS │
                 ├──────────────────────┤
                 │ Users                │
                 │ Profiles             │
                 │ Locations            │
                 │ Interactions         │
                 │ Conversations        │
                 │ Messages             │
                 └──────────────────────┘



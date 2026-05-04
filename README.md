# 👵 seniorCare

> **Bridging the gap between seniors and the community — with role-based care, real-time assistance, and emergency support.**

---

## 🌟 About the Project

### Aim
**seniorCare** is a mobile application that empowers senior citizens by providing them with an intuitive platform to request assistance for daily tasks and emergencies. It fosters a supportive ecosystem where seniors can maintain their independence while being seamlessly connected to a dedicated network of volunteers and caregivers.

### Reasons for Building This
- **Ageing Population**: There is a growing need for personalized care, especially for seniors living alone without immediate family support.
- **Volunteer Gap**: There is no structured platform that connects willing volunteers with seniors who genuinely need help.
- **Safety Concerns**: Standard communication tools lack immediate emergency mechanisms for senior citizens.
- **Medication Non-Compliance**: A leading cause of health deterioration among the elderly is missed medications.

---

## 💎 Importance of the Project

| # | Area | Impact |
|---|------|--------|
| 1 | 🚨 **Safety** | The built-in **SOS button** triggers instant emergency alerts to nearby volunteers and registered caregivers, ensuring help is never more than a tap away. |
| 2 | 🤝 **Community** | Connects generations by enabling meaningful volunteer-senior relationships, reducing loneliness and social isolation. |
| 3 | 💊 **Health** | Automated **Medicine Reminders** ensure seniors never miss a dose, directly reducing hospital visits. |
| 4 | 👨‍👩‍👧 **Family Peace of Mind** | Caregivers can remotely monitor safety logs, SOS history, and task completions through a dedicated dashboard. |
| 5 | 🏆 **Civic Engagement** | Gamified badge rewards (Bronze → Silver → Gold) motivate volunteers to participate consistently. |

---

## 🏗️ System Architecture

The application is built on **Clean Architecture** principles, separating the codebase into `core`, `data`, `domain`, and `presentation` layers for maximum testability and maintainability.

```
lib/
├── core/           # Shared utilities, constants, network config
├── data/           # Repositories, data sources (Firebase, local)
├── domain/         # Business logic, models, use-cases
├── presentation/   # UI screens, pages, widgets, providers
│   ├── pages/
│   │   ├── dashboard/      # Senior & Volunteer dashboards
│   │   ├── requests/       # Help request management
│   │   ├── medicine/       # Medication reminders
│   │   ├── schedule/       # Task & appointment scheduling
│   │   ├── chat/           # Messaging
│   │   ├── volunteer/      # Volunteer-specific features
│   │   └── admin/          # Admin panel
│   └── providers/          # State management (Provider)
└── main.dart
```

### Role-Based Design
| Role | Access |
|------|--------|
| **Senior** | Help Requests, SOS, Medicine Reminders, Chat, Video Call |
| **Volunteer** | Nearby Requests Dashboard, Task Acceptance, Badges, Chat |
| **Both** | Full access to both Senior and Volunteer features |
| **Caregiver** | Remote monitoring dashboard for a linked Senior |
| **Admin** | System-wide management of users, volunteers, and requests |

---

## 🔄 Process Flow

```
[User Opens App]
      │
      ▼
[Sign Up / Login] ──► [Select Role: Senior / Volunteer / Both]
                                         │
              ┌──────────────────────────┴──────────────────────────┐
              ▼                                                       ▼
    [SENIOR DASHBOARD]                                    [VOLUNTEER DASHBOARD]
              │                                                       │
    ┌─────────┴──────────┐                             ┌─────────────┴──────────────┐
    ▼         ▼          ▼                             ▼             ▼              ▼
[Request   [SOS    [Medicine/                    [View Nearby  [Accept Task]  [Toggle Online
  Help]    Alert]   Reminders]                   Requests]          │          / Offline]
    │         │                                      │         [Complete Task]
    │         └─► [Notify nearby Volunteers ◄────────┘               │
    │                    via FCM/Firestore]                   [Earn Badge Reward]
    │
    └─────────────────────────────────────────────────────────────────────────────┐
                                                                                  ▼
                                                               [SHARED FEATURES]
                                                               Chat Messaging
                                                               Video Calling (Agora)
                                                               Language Switch (ML / EN)
```

---

## 🛠️ Tools and Technology Used

### 📱 Core Framework
| Tool | Purpose |
|------|---------|
| **Flutter** (Dart, SDK ^3.10) | Cross-platform mobile development (Android & iOS) |
| **Provider** | Reactive state management |
| **flutter_dotenv** | Secure API key management via `.env` |

### 🔥 Backend & Cloud (Firebase)
| Service | Purpose |
|---------|---------|
| **Firebase Auth** | Email/password and Google Sign-In |
| **Cloud Firestore** | Real-time NoSQL database for requests, profiles, chat |
| **Firebase Storage** | Profile images and media uploads |
| **Firebase Messaging (FCM)** | Push notifications and SOS alerts |

### 📡 Communication & Location
| Tool | Purpose |
|------|---------|
| **Agora RTC Engine** | 1-to-1 video calling |
| **Flutter Sound** | Audio recording and playback |
| **Geolocator & Geocoding** | Real-time GPS location and address resolution |
| **Google Maps / Places API** | Map integration and location display |

### 🧠 AI Integration
| Tool | Purpose |
|------|---------|
| **Google Gemini API** | AI-assisted features (intelligent suggestions, chat assistance) |

### 💾 Local & Utility
| Tool | Purpose |
|------|---------|
| **Hive** | Lightweight local database for offline caching |
| **Flutter Local Notifications** | Scheduled medicine and task reminders |
| **Alarm** | Reliable alarm-based reminder triggers |
| **Shared Preferences** | Persistent user preferences |
| **Image Picker** | Profile and document image upload |
| **Share Plus & URL Launcher** | Content sharing and external links |

---

## ✨ Key Features

- 🚨 **SOS Emergency Button** — Instantly notifies all nearby volunteers and caregivers.
- 💊 **Medicine & Task Reminders** — Alarm-based notifications with custom sounds.
- 📍 **Geofenced Volunteer Matching** — Only shows requests within a ~5 km radius.
- 📞 **In-App Video & Voice Calls** — Powered by Agora for clear, secure calls.
- 💬 **Real-Time Chat** — One-to-one messaging for seniors and volunteers.
- 🌍 **Bilingual Support** — Full Malayalam and English language switching.
- 🏅 **Volunteer Badge System** — Bronze, Silver, and Gold reward milestones.
- 🛡️ **Role-Locked Dashboards** — Secure, custom views for every user type.

---

*Built with ❤️ as a Senior College Capstone Project.*
# Iyad Quran: Feature-Rich Religious and Productivity App

A feature-rich mobile application designed for spiritual productivity, featuring dynamic text-rendering, an offline daily productivity planner (Khatma Planner), and a comprehensive Islamic supplication database. Built using Flutter and integrated with Supabase for cloud features, alongside SQLite for robust offline capabilities.

---

## Features

- **Dynamic Text Rendering:** Optimized for smooth rendering of Quranic scripts and text layouts.
- **Offline Khatma Planner:** A personalized daily productivity planner that works entirely offline, allowing users to track progress seamlessly.
- **Supplication Database:** A structured, local database containing authentic Islamic supplications.
- **Data Persistence:** Utilizes local caching to maintain user states, progress, and preferences across application sessions.

---

## Tech Stack

- **Frontend:** Flutter (Dart).
- **Backend and Cloud:** Supabase.
- **Local Database:** SQLite (sqflite package).
- **State and Preferences:** SharedPreferences (for local key-value caching).
- **Version Control:** Git and GitHub.

---

## Architecture and Local-First Strategy

The application employs an offline-first data synchronization architecture to ensure uninterrupted usability:
- **Local SQLite Storage:** Pre-loaded and user-generated data are stored locally using sqflite, guaranteeing sub-millisecond query responses without network dependency.
- **SharedPreferences Caching:** Lightweight user configurations, daily planner states, and last-read positions are cached instantly.
- **Supabase Integration:** Used for secure cloud synchronization, enabling cross-device backup when a network connection is available.

---


## Screenshots and Demo

| Home and Last Read | Quran Search and Index | Dynamic Text Rendering |
| --- | --- | --- |
| ![Home and Last Read](./screenshots/home.png) | ![Quran Search and Index](./screenshots/search.png) | ![Dynamic Text Rendering](./screenshots/quran.png) |


---

## Setup and Installation

1. **Clone the repository:**
```bash   git clone [https://github.com/MoaazAlkehelat/](https://github.com/MoaazAlkehelat/)[Your-Repository-Name].git
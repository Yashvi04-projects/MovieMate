# MovieMate – Movie Ticket Booking Application

A full-stack movie ticket booking application built for **Software Testing Internship** evaluation. Supports Manual Testing, API Testing, Mobile Testing, Bug Reporting, RTM creation, Test Case Design, and Test Metrics reporting.

---

## Project Structure

```
moviemate/
├── backend/                 # Node.js + Express REST API
│   ├── data/                # JSON mock database
│   ├── routes/              # API route handlers
│   ├── middleware/          # JWT authentication
│   ├── swagger/             # Swagger/OpenAPI documentation
│   └── server.js            # Entry point
├── frontend/
│   └── moviemate_app/       # Flutter mobile application
│       └── lib/
│           ├── models/      # Data models
│           ├── providers/   # Provider state management
│           ├── services/    # API service layer
│           ├── screens/     # UI screens (12 modules)
│           └── theme/       # Material Design 3 theme
├── postman/                 # Postman API collection
├── docs/                    # Architecture & instructor docs
└── README.md
```

---

## Architecture Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│                        FLUTTER MOBILE APP                        │
│  ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────────────┐   │
│  │  Splash  │ │  Login   │ │  Home    │ │  Seat Selection  │   │
│  │  Screen  │ │ Register │ │  Search  │ │  Payment/Profile │   │
│  └────┬─────┘ └────┬─────┘ └────┬─────┘ └────────┬─────────┘   │
│       │            │            │                 │              │
│       └────────────┴────────────┴─────────────────┘              │
│                            │                                      │
│                   ┌────────▼────────┐                            │
│                   │ Provider State  │                            │
│                   │ Auth │ Movie │  │                            │
│                   │ Booking         │                            │
│                   └────────┬────────┘                            │
│                            │                                      │
│                   ┌────────▼────────┐                            │
│                   │   ApiService    │  (HTTP/REST)               │
│                   └────────┬────────┘                            │
└────────────────────────────┼────────────────────────────────────┘
                             │ JSON over HTTP
                             ▼
┌─────────────────────────────────────────────────────────────────┐
│                    NODE.JS + EXPRESS SERVER                      │
│  ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐           │
│  │  /login  │ │ /movies  │ │ /booking │ │ /payment │           │
│  │ /register│ │ /search  │ │ /profile │ │          │           │
│  └────┬─────┘ └────┬─────┘ └────┬─────┘ └────┬─────┘           │
│       │            │            │             │                  │
│       └────────────┴────────────┴─────────────┘                  │
│                            │                                      │
│                   ┌────────▼────────┐                            │
│                   │  JSON Database  │                            │
│                   │ users.json      │                            │
│                   │ movies.json     │                            │
│                   │ bookings.json   │                            │
│                   └─────────────────┘                            │
│                                                                   │
│  Swagger UI: http://localhost:3000/api-docs                      │
└─────────────────────────────────────────────────────────────────┘
```

---

## Tech Stack

| Layer      | Technology                          |
|------------|-------------------------------------|
| Frontend   | Flutter, Provider, Material Design 3|
| Backend    | Node.js, Express.js                 |
| Database   | JSON mock database (file-based)     |
| API Docs   | Swagger UI                          |
| Auth       | JWT (JSON Web Tokens)               |

---

## Prerequisites

- **Node.js** v18+ and npm
- **Flutter** SDK 3.0+
- **Android Studio** or **VS Code** with Flutter extension
- **Postman** (for API testing)

---

## Backend Setup

```bash
cd moviemate/backend
npm install
npm start
```

> **SSL error on Windows?** If `npm install` fails with `UNABLE_TO_VERIFY_LEAF_SIGNATURE`, the project includes a local `.npmrc` (`strict-ssl=false`) to work around corporate proxy/antivirus certificate issues. Alternatively run:
> ```powershell
> $env:NODE_TLS_REJECT_UNAUTHORIZED='0'; npm install
> ```

Server runs at: **http://localhost:3000**

Swagger documentation: **http://localhost:3000/api-docs**

---

## Frontend Setup

```bash
cd moviemate/frontend/moviemate_app
flutter pub get
flutter run
```

### API URL Configuration

Edit `lib/services/api_service.dart`:

| Platform              | baseUrl                        |
|-----------------------|--------------------------------|
| Android Emulator      | `http://10.0.2.2:3000/api`     |
| iOS Simulator         | `http://localhost:3000/api`    |
| Physical Device       | `http://<YOUR_PC_IP>:3000/api` |

---

## Test Credentials

| User  | Email            | Password |
|-------|------------------|----------|
| User 1| test@gmail.com   | Test123  |
| User 2| demo@gmail.com   | Demo123  |

---

## Application Modules

1. Splash Screen
2. Login
3. Registration
4. Home Screen (Trending & Upcoming)
5. Search Movies
6. Movie Details
7. Seat Selection (30 seats)
8. Booking Summary
9. Payment (Credit Card / UPI)
10. Profile
11. Booking History
12. Logout

---

## API Endpoints

| Method | Endpoint                  | Description          | Auth |
|--------|---------------------------|----------------------|------|
| POST   | /api/register             | Register user        | No   |
| POST   | /api/login                | Login user           | No   |
| GET    | /api/movies               | List all movies      | No   |
| GET    | /api/movies/search?q=     | Search movies        | No   |
| GET    | /api/movies/:id           | Movie details        | No   |
| POST   | /api/movies               | Create movie         | Yes  |
| PUT    | /api/movies/:id           | Update movie         | Yes  |
| DELETE | /api/movies/:id           | Delete movie         | Yes  |
| POST   | /api/booking              | Create booking       | Yes  |
| GET    | /api/booking/user/:userId | Booking history      | Yes  |
| GET    | /api/booking/:id          | Get booking          | Yes  |
| DELETE | /api/booking/:id          | Cancel booking       | Yes  |
| POST   | /api/payment              | Process payment      | Yes  |
| GET    | /api/profile              | Get profile          | Yes  |
| PUT    | /api/profile              | Update profile       | Yes  |
| DELETE | /api/profile              | Delete account       | Yes  |

### HTTP Status Codes

- `200` – Success
- `201` – Created
- `400` – Bad Request
- `401` – Unauthorized
- `404` – Not Found
- `500` – Internal Server Error

---

## Postman Testing

Import the collection from:

```
moviemate/postman/MovieMate_API.postman_collection.json
```

**Steps:**
1. Start the backend server
2. Open Postman → Import → Select the JSON file
3. Run **Login - Test User** first (auto-saves JWT token)
4. Test remaining endpoints

---

## QA Testing Guide

### Manual Testing Areas

| Module           | Test Focus                                      |
|------------------|-------------------------------------------------|
| Login            | Empty fields, invalid email, password spaces    |
| Registration     | Weak password, duplicate email, mobile format   |
| Search           | Case sensitivity, extra spaces                  |
| Movie Details    | Missing data, trailer functionality             |
| Seat Booking     | Double booking, seat counter accuracy           |
| Payment          | Invalid card, missing CVV, success timing       |
| Profile          | Image upload, email update persistence          |
| Booking History  | Latest booking visibility                       |
| UI               | Small screen layout, dark mode consistency      |

### Suggested Test Artifacts

- **Test Cases** – Positive, negative, boundary value
- **Bug Reports** – Steps to reproduce, expected vs actual
- **RTM** – Requirements Traceability Matrix
- **Test Metrics** – Pass/fail counts, defect density

---

## UI Theme

| Property        | Value     |
|-----------------|-----------|
| Primary Color   | #1E3A8A   |
| Secondary Color | #F59E0B   |
| Background      | #F8FAFC   |
| Text            | #111827   |
| Font            | Poppins   |

---

## Movie Data

10 dummy movies with poster, genre, duration, rating, description, trailer URL, and release date. See `backend/data/movies.json`.

---

## Logs

Backend logs all requests to console with timestamps. Frontend shows toast messages for user actions.

---

## For Instructors

See `docs/INSTRUCTOR_DEFECTS.md` for the complete list of intentional defects with reproduction steps.

---

## License

Educational use only – Software Testing Internship Project.

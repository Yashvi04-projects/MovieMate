# MovieMate Architecture

## System Overview

```mermaid
flowchart TB
    subgraph Client["Flutter Mobile App"]
        UI[Screens / UI Layer]
        PROV[Provider State Management]
        API_SVC[ApiService - HTTP Client]
        UI --> PROV --> API_SVC
    end

    subgraph Server["Node.js Express Server"]
        ROUTES[REST Routes]
        AUTH_MW[JWT Middleware]
        SWAGGER[Swagger UI /api-docs]
        ROUTES --> AUTH_MW
    end

    subgraph Data["JSON File Database"]
        USERS[(users.json)]
        MOVIES[(movies.json)]
        BOOKINGS[(bookings.json)]
        SEATS[(bookedSeats.json)]
    end

    API_SVC -->|HTTP JSON| ROUTES
    ROUTES --> USERS
    ROUTES --> MOVIES
    ROUTES --> BOOKINGS
    ROUTES --> SEATS
    SWAGGER -.-> ROUTES
```

## Module Flow

```mermaid
flowchart LR
    Splash --> Login
    Login --> Register
    Login --> Home
    Home --> Search
    Home --> MovieDetails
    MovieDetails --> SeatSelection
    SeatSelection --> BookingSummary
    BookingSummary --> Payment
    Payment --> BookingHistory
    Home --> Profile
    Profile --> Logout
    Logout --> Login
```

## API Layer

| Layer | Responsibility |
|-------|----------------|
| Routes | HTTP handling, validation, status codes |
| Middleware | JWT token verification |
| Utils/DB | JSON file read/write operations |
| Swagger | API documentation for Postman/testing |

## Frontend Layer

| Layer | Responsibility |
|-------|----------------|
| Screens | UI modules (12 screens) |
| Providers | Auth, Movie, Booking state |
| Services | REST API communication |
| Models | User, Movie, Booking data classes |
| Theme | Material Design 3 cinema theme |

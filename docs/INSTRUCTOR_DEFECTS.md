# MovieMate – Intentional Defects Guide (Instructors Only)

> **CONFIDENTIAL:** This document is for internship evaluators only. Do NOT share with QA interns — defects are meant to be discovered through testing.

---

## Login Defects

### BUG-01: Login button enabled when fields are empty
- **Module:** Login
- **Steps:** Open Login screen without entering email or password → Observe Login button
- **Expected:** Button should be disabled when fields are empty
- **Actual:** Login button remains enabled and clickable
- **Location:** `frontend/.../login_screen.dart`

### BUG-02: Invalid email format accepted
- **Module:** Login
- **Steps:** Enter `abc`, `123`, or `gmail` in email field → Tap Login
- **Expected:** Validation error for invalid email format
- **Actual:** No email format validation; invalid values accepted
- **Location:** `frontend/.../login_screen.dart`

### BUG-03: Leading spaces in password allow login
- **Module:** Login
- **Steps:** Login with ` test@gmail.com` / ` Test123` (leading space in password)
- **Expected:** Login should fail or password should be trimmed
- **Actual:** Login succeeds with leading spaces in password
- **Location:** `backend/routes/auth.js`

---

## Registration Defects

### BUG-04: Weak password accepted
- **Module:** Registration
- **Steps:** Register with password `1` or `abc`
- **Expected:** Password strength validation (min 8 chars, uppercase, number)
- **Actual:** Any non-empty password is accepted
- **Location:** `frontend/.../register_screen.dart`, `backend/routes/auth.js`

### BUG-05: Duplicate email registration allowed
- **Module:** Registration
- **Steps:** Register with `test@gmail.com` (already exists)
- **Expected:** Error message "Email already registered"
- **Actual:** Registration succeeds with duplicate email
- **Location:** `backend/routes/auth.js`

### BUG-06: Mobile number accepts alphabets
- **Module:** Registration
- **Steps:** Enter `abcXYZ` in mobile field → Register
- **Expected:** Only numeric mobile numbers accepted
- **Actual:** Alphabetic characters accepted in mobile field
- **Location:** `frontend/.../register_screen.dart`

---

## Search Defects

### BUG-07: Search is case-sensitive
- **Module:** Search
- **Steps:** Search for `inception` (lowercase) vs `Inception`
- **Expected:** Case-insensitive search results
- **Actual:** Lowercase query returns no results
- **Location:** `backend/routes/movies.js`, `frontend/.../search_screen.dart`

### BUG-08: Extra spaces break search
- **Module:** Search
- **Steps:** Search for ` Inception ` (with leading/trailing spaces)
- **Expected:** Trimmed query returns results
- **Actual:** No results due to extra spaces
- **Location:** `frontend/.../search_screen.dart`

---

## Movie Details Defects

### BUG-09: Missing description for one movie
- **Module:** Movie Details
- **Steps:** Open **Gladiator II** (Movie ID: 8)
- **Expected:** Full movie description displayed
- **Actual:** Description shows "No description available."
- **Location:** `backend/data/movies.json` (id: 8, empty description)

### BUG-10: Trailer button does not work
- **Module:** Movie Details
- **Steps:** Open **Gladiator II** → Tap "Watch Trailer"
- **Expected:** YouTube trailer opens
- **Actual:** Toast "Unable to open trailer" appears
- **Location:** `frontend/.../movie_details_screen.dart`

---

## Seat Booking Defects

### BUG-11: Same seat booked multiple times
- **Module:** Seat Booking
- **Steps:** Book seat A1 for a movie → Book A1 again for same movie
- **Expected:** Error "Seat already booked"
- **Actual:** Both bookings succeed
- **Location:** `backend/routes/bookings.js`

### BUG-12: Seat counter displays incorrect total
- **Module:** Seat Selection
- **Steps:** Select 3 seats → Check seat counter
- **Expected:** Shows "Seats: 3"
- **Actual:** Shows "Seats: 2" (off by one)
- **Location:** `frontend/.../providers/providers.dart` (`seatCount` getter)

---

## Payment Defects

### BUG-13: Invalid card number accepted
- **Module:** Payment
- **Steps:** Enter card number `1234` → Pay with Card
- **Expected:** Validation error for invalid card
- **Actual:** Payment succeeds
- **Location:** `frontend/.../payment_screen.dart`

### BUG-14: Payment succeeds without CVV
- **Module:** Payment
- **Steps:** Enter valid card number, leave CVV empty → Pay
- **Expected:** CVV required validation
- **Actual:** Payment succeeds without CVV
- **Location:** `frontend/.../payment_screen.dart`

### BUG-15: Success screen before API confirmation
- **Module:** Payment
- **Steps:** Tap Pay → Observe timing of success screen vs network request
- **Expected:** Success shown only after API confirms
- **Actual:** Success screen appears ~500ms before API completes
- **Location:** `frontend/.../payment_screen.dart`

---

## Profile Defects

### BUG-16: Profile image upload does not save
- **Module:** Profile
- **Steps:** Upload profile photo → Save → Logout → Login again
- **Expected:** Profile photo persists
- **Actual:** Success toast shown but image not saved to server
- **Location:** `frontend/.../profile_screen.dart`

### BUG-17: Email update not reflected immediately
- **Module:** Profile
- **Steps:** Change email → Save → Check profile header email
- **Expected:** Updated email shown everywhere
- **Actual:** Header still shows old email until re-login
- **Location:** `frontend/.../profile_screen.dart`

---

## Booking History Defects

### BUG-18: Latest booking sometimes missing
- **Module:** Booking History
- **Steps:** Create new booking → Refresh history multiple times
- **Expected:** All bookings including latest always visible
- **Actual:** Latest booking missing ~30% of the time
- **Location:** `backend/routes/bookings.js`

---

## UI Defects

### BUG-19: Button overlaps content on small screens
- **Module:** Profile
- **Steps:** Open Profile on small screen device → Scroll to bottom
- **Expected:** All content visible without overlap
- **Actual:** Bottom promotional banner overlaps scroll content
- **Location:** `frontend/.../profile_screen.dart`

### BUG-20: Dark mode colors inconsistent on Profile
- **Module:** Profile
- **Steps:** Toggle dark mode on Profile screen
- **Expected:** Consistent dark theme matching app-wide dark mode
- **Actual:** Profile uses custom inconsistent colors (#2D2D44, #3D3D5C)
- **Location:** `frontend/.../profile_screen.dart`

---

## Defect Summary

| Bug ID  | Severity | Module          | Type        |
|---------|----------|-----------------|-------------|
| BUG-01  | Medium   | Login           | Validation  |
| BUG-02  | High     | Login           | Validation  |
| BUG-03  | Medium   | Login           | Functional  |
| BUG-04  | High     | Registration    | Security    |
| BUG-05  | High     | Registration    | Functional  |
| BUG-06  | Medium   | Registration    | Validation  |
| BUG-07  | Medium   | Search          | Functional  |
| BUG-08  | Low      | Search          | Functional  |
| BUG-09  | Low      | Movie Details   | Data        |
| BUG-10  | Medium   | Movie Details   | Functional  |
| BUG-11  | Critical | Seat Booking    | Functional  |
| BUG-12  | Medium   | Seat Booking    | UI/Logic    |
| BUG-13  | High     | Payment         | Security    |
| BUG-14  | High     | Payment         | Security    |
| BUG-15  | High     | Payment         | Functional  |
| BUG-16  | Medium   | Profile         | Functional  |
| BUG-17  | Medium   | Profile         | Functional  |
| BUG-18  | High     | Booking History | Functional  |
| BUG-19  | Low      | UI              | Layout      |
| BUG-20  | Low      | UI              | Theme       |

**Total: 20 intentional defects**

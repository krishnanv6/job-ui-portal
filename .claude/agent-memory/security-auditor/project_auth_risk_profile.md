---
name: auth-risk-profile
description: Auth architecture risk profile — localStorage-backed session, plaintext passwords in source, role check patterns
metadata:
  type: project
---

Auth is entirely client-side with no real backend. Key risk facts established during the components audit:

- `AuthContext.jsx` stores `DUMMY_USERS` with plaintext passwords directly in source code (employer123, hr123, jobseeker123, admin123). Acceptable for mock/demo but must never reach production.
- Session state persisted to `localStorage` under keys `jobPortalUser` (full user object including role) and `authToken` (a `mock-jwt-` + timestamp string). Both are readable by any same-origin JS — XSS would fully compromise sessions.
- Registered users (via `/register`) are stored in `localStorage` under `registeredUsers` with plaintext passwords — a data dump waiting to happen if XSS lands.
- `ProtectedRoute` derives `isAuthenticated` and `role` from React state (seeded from localStorage at startup), not from a server-validated token. An attacker who can write to localStorage can forge any role.
- The `isAuthenticated` flag is `!!user` where `user` comes from parsed localStorage JSON. No signature verification on the stored object.
- Role booleans (`isAdmin`, `isEmployer`, `isJobSeeker`) are computed from `user.role` inside the context — if `user.role` in localStorage is tampered, the derived booleans will reflect the tampered value on next page load.

**Why:** Recorded during first full audit of components/ directory. These are the structural trust assumptions the entire auth layer rests on.
**How to apply:** When reviewing any feature that touches auth, gate logic, or sensitive data display, use this profile to assess whether client-side trust assumptions create a bypass path.

---
name: components-audit-findings
description: Summary of security findings from first full audit of src/components/ — what was flagged, what was cleared
metadata:
  type: project
---

Audit covered: CompaniesSection.jsx, ConfirmationModal.jsx, Footer.jsx, Hero.jsx, JobsSection.jsx, Layout.jsx, Navbar.jsx, ProtectedRoute.jsx, RefreshButton.jsx, ScrollToTop.jsx. Also read AuthContext.jsx and App.jsx for full context.

## Findings logged (severity)

1. **High** — ProtectedRoute: role check relies solely on client-controlled localStorage-seeded state. No server-side token validation. An attacker who can write `jobPortalUser` to localStorage with `role: "ROLE_ADMIN"` bypasses all route guards on next page load.

2. **High** — AuthContext (supporting context for the components audit): plaintext passwords stored in `registeredUsers` localStorage key. Full credential dump possible via XSS or DevTools.

3. **High** — AuthContext: `authToken` is `"mock-jwt-" + Date.now()` — no cryptographic content. ProtectedRoute only checks `!!user` (presence of user object), not the token itself. Token field is security theater in current form.

4. **Medium** — ProtectedRoute: no rate-limit or lockout on the loading state path — if `isLoading` stays true indefinitely (e.g., due to a thrown error in the useEffect), the spinner renders forever with no fallback timeout or error boundary.

5. **Medium** — Hero.jsx: search inputs pass values directly into URL query params via `URLSearchParams`. No length cap or character sanitization before navigate(). In production this becomes a reflected-input surface if the receiving page renders unescaped params.

6. **Medium** — CompaniesSection.jsx (line 63): company name is slug-ified client-side for the route URL (`company.name.toLowerCase().replace(...)`) but the receiving route (`/companies/:id`) presumably looks up by this slug. If mock data company names change or contain edge-case characters, slug mismatch silently produces wrong data — not a direct attack surface but a logic integrity risk.

7. **Medium** — Footer.jsx (lines 148, 157, 166): "Privacy Policy", "Terms of Service", and "Cookie Policy" are rendered as `<a>` elements with no `href` attribute. They act as dead links but establish false trust signals about legal compliance. Low exploitation risk; high trust/UX risk.

8. **Low** — Navbar.jsx (line 128): `user.name?.charAt(0)` — optional chaining guards the charAt but if `user.name` is an empty string the avatar initial renders as empty string. Cosmetic but could expose that the name field is blank/tampered.

9. **Low** — RefreshButton.jsx (line 15): `console.error('Error refreshing data:', error)` — error object logged to console. In production, error messages from context failures could contain internal paths or data structure hints. Acceptable in dev/mock context.

10. **Low** — CompaniesSection.jsx / JobsSection.jsx: `onError` handlers on `<img>` tags directly set `e.target.style.display = 'none'` via inline style mutation. Not a security issue but bypasses the project's Tailwind-only style convention.

## Items cleared (no finding)

- No `dangerouslySetInnerHTML`, `innerHTML`, `eval()`, or `new Function()` in any of the 10 files.
- No hardcoded API keys or secrets in any of these components (credentials are in AuthContext, not components).
- No open redirect: `navigate()` calls in Navbar and Hero use static paths or URLSearchParams — no user-controlled redirect destination.
- External links in Footer all use `rel="noopener noreferrer"` — tabnapping risk correctly mitigated.
- All user data rendered in JSX goes through React's default escaping (no bypass patterns found).
- ConfirmationModal: `title`, `message`, `confirmText`, `cancelText` are all rendered as JSX text children — correctly escaped by React.
- ScrollToTop: no user input, no data handling — clean.
- Layout: simple slot component — no attack surface.

**Why:** First full pass over components/ directory.
**How to apply:** Use as baseline. Re-audit if AuthContext is modified, if new components are added that consume auth state, or if any component gains a form or data-rendering feature.

---
name: project-context-hotspots
description: Known performance hotspots and context stability issues in the job-portal-ui codebase
metadata:
  type: project
---

## Context Value Instability

Both `AuthContext` and `JobContext` construct their `value` object inline on every render — no `useMemo` wrapping the value object. Every state change in either provider re-renders all consumers.

- `AuthContext` (src/context/AuthContext.jsx line ~320): value object is a plain object literal. Derived booleans `isAuthenticated`, `isEmployer`, `isJobSeeker`, `isAdmin` are recomputed inline but are primitives so stable individually. The object reference itself changes on every render.
- `JobContext` (src/context/JobContext.jsx line ~352): same pattern — large value object constructed inline each render. Functions like `applyForJob`, `saveJob`, etc. are recreated on every render with no `useCallback`.

## Navbar Over-Consumption

`Navbar.jsx` consumes three contexts: `ThemeContext`, `AuthContext`, AND `JobContext`. Any change to jobs state (e.g., applying for a job) re-renders the entire Navbar.

## CompaniesSection O(n) filter per company card

`CompaniesSection.jsx` line 10-13: computes `companiesWithJobCounts` on every render by calling `.filter()` over the full `jobs` array once per company in the first 8. This is O(n*m) where n=jobs count and m=companies slice (8). Should be memoized with `useMemo`.

## getGradient called multiple times per card

`CompaniesSection.jsx`: `getGradient(company.industry)` is called twice per company card (lines 68, 71) inside the render. With 8 companies that's 16 switch calls per render. Minor but could be precomputed per card.

## JobContext functions recreated every render

`JobContext.jsx`: All functions (`applyForJob`, `saveJob`, `unsaveJob`, `isJobApplied`, `isJobSaved`, `withdrawApplication`, etc.) are plain function declarations inside the component body — they get new references every render. When passed as context values, they cause all consumers to re-render unnecessarily.

## RefreshButton formatCacheAge called twice per render

`RefreshButton.jsx` line 49 and 72: `formatCacheAge()` is called twice in the same render — once in the `title` attribute and once in the display `<span>`. Should be called once and stored in a variable.

## ConfirmationModal onClose in useEffect dependency

`ConfirmationModal.jsx` line 26: `onClose` is in the `useEffect` deps array. If the parent passes an inline function as `onClose`, the effect re-fires every parent render, re-adding and removing the event listener unnecessarily.

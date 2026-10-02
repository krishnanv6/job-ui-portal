---
name: pattern-dark-variant
description: Tailwind dark: variant is used throughout the codebase despite the project standard requiring ThemeContext conditional class toggling
metadata:
  type: project
---

Every component reviewed uses the `dark:` Tailwind variant extensively (119 occurrences across 7 files in src/components/ alone). The coding standard explicitly prohibits this — dark mode must be implemented via ThemeContext by toggling a class (e.g., `dark` on the root element) and applying conditional className logic.

**Why:** The project uses ThemeContext to control theme state; using the `dark:` variant bypasses this and creates two parallel dark mode systems that can drift out of sync.

**How to apply:** Flag any new `dark:` usage as a critical violation. When reviewing, note that this is a systemic issue across the codebase, not a one-off mistake in a single file.

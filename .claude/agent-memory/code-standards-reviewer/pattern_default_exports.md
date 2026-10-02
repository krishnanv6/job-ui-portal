---
name: pattern-default-exports
description: All components in src/components/ use default exports; named exports are the stated project preference
metadata:
  type: project
---

All 10 components reviewed use `export default ComponentName`. The coding standard states named exports are preferred. This is a consistent pattern across the entire components directory.

**Why:** Named exports make refactoring and import tracking easier; they also prevent the common mistake of importing a component under an alias that hides the real name.

**How to apply:** Flag all new components that use default export. Note this is a systemic issue — when raising in reviews, treat it as a warning (not critical) since the entire codebase is consistent in using defaults, making it a migration concern rather than an isolated violation.

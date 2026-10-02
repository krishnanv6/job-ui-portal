---
name: feedback-indentation-components
description: All files in src/components/ use 2-space indentation; project standard requires tab characters
metadata:
  type: project
---

Every JSX file in src/components/ uses 2-space indentation. Zero tab-indented lines were found. The coding standard requires tab characters for all JS/JSX files.

**Why:** Tabs are the declared project standard (also confirmed in user memory [[indentation-tabs-not-spaces]]).

**How to apply:** Flag space indentation as a critical violation in every file reviewed. This is a codebase-wide issue — all components need to be reformatted to tabs.

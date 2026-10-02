---
name: pattern-inline-animation-delay
description: Recurring use of style={{}} for CSS animationDelay in CompaniesSection, JobsSection, and Hero — not available as a Tailwind utility
metadata:
  type: project
---

`style={{ animationDelay: '...' }}` appears in CompaniesSection.jsx (lines 65, 114), JobsSection.jsx (lines 157, 217), and Hero.jsx (lines 30, 34). This is the one known case where inline styles are used because `animationDelay` has no Tailwind utility class equivalent.

**Why:** CSS `animation-delay` cannot be set with standard Tailwind utilities without a custom plugin or arbitrary value class. The inline style is therefore the pragmatic choice.

**How to apply:** When reviewing, do not flag animationDelay inline styles as critical violations — acknowledge them as warnings and suggest using Tailwind arbitrary values (e.g., `[animation-delay:1s]`) as the preferred alternative. Any other inline style usage should still be flagged as critical.

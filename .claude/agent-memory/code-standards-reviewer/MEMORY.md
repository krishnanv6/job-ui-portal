# Memory Index

- [Indentation: spaces not tabs in components](feedback_indentation_components.md) — all components/ files currently use spaces; tabs are the required standard
- [dark: variant used throughout codebase](pattern_dark_variant.md) — widespread use of Tailwind dark: variant despite project standard requiring ThemeContext class toggling
- [Default exports used across all components](pattern_default_exports.md) — all components use default export; named exports are the stated preference
- [Inline styles for animationDelay](pattern_inline_animation_delay.md) — recurring use of style={{}} for CSS animationDelay which isn't available as a Tailwind utility

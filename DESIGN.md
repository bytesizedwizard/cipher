---
version: alpha
name: Cipher
description: >-
  Offline-first 2FA authenticator app. Dark green accent on deep dark
  or near-white canvas. Security-focused, minimal, premium tactile feel.
colors:
  primary: "#FBFEFE"
  accent: "#001910"
  font: "#001910"
  border: "#E0E0E0"
  error: "#B00020"
  warning: "#FFA000"
  success: "#005737"
  surface: "#FBFEFE"
  on-surface: "#001910"
typography:
  heading1:
    fontFamily: Inter
    fontSize: 21px
    fontWeight: 700
  heading2:
    fontFamily: Inter
    fontSize: 18px
    fontWeight: 600
  heading3:
    fontFamily: Inter
    fontSize: 16px
    fontWeight: 500
  body:
    fontFamily: Inter
    fontSize: 14px
    fontWeight: 400
    letterSpacing: 0
  label:
    fontFamily: Inter
    fontSize: 14px
    fontWeight: 400
    letterSpacing: 0
rounded:
  sm: 8px
  md: 10px
  lg: 12px
  full: 9999px
spacing:
  xs: 4px
  sm: 8px
  md: 16px
  lg: 20px
  xl: 25px
  xxl: 32px
  gutter: 24px
components:
  button-primary:
    backgroundColor: "{accent}"
    textColor: "{primary}"
    rounded: "{rounded.lg}"
    padding: "{spacing.md} {spacing.md}"
    height: 48px
  button-text:
    backgroundColor: transparent
    textColor: "{accent}"
    rounded: "{rounded.sm}"
    padding: "{spacing.sm} {spacing.sm}"
    height: 36px
  card:
    backgroundColor: "{primary}"
    textColor: "{font}"
    rounded: "{rounded.md}"
    borderColor: "{border}"
    padding: "{spacing.md} {spacing.md}"
  card-toggle:
    backgroundColor: "{primary}"
    rounded: "{rounded.sm}"
    padding: 0
  radio-group:
    backgroundColor: "{primary}"
    rounded: "{rounded.sm}"
    padding: 0
  app-bar:
    backgroundColor: "{primary}"
    textColor: "{font}"
    typography: "{typography.heading1}"
  bottom-nav:
    activeColor: "{accent}"
    inactiveColor: "{border}"
---
# Cipher — Design Document

## Overview

Cipher is a security-focused, offline-first 2FA authenticator. Visual identity communicates **trust**, **precision**, and **privacy**.

The palette is minimal — near-white light canvas or deep-almost-black dark canvas, with a single **dark green** accent (`#001910` light / `#F3FFFB` dark) driving all interactive elements and typography. This creates a calm, focused interface where security elements are the only visual anchor.

- **Brand personality:** Minimal, trustworthy, precise. No decorative flourishes. Every element serves function.
- **Target audience:** Security-conscious users who value privacy and offline control.
- **Tone:** Professional, calm, confident. Dark green evokes security, growth, stability.
- **Texture:** Subtle noise texture on backgrounds adds a premium tactile feel without distracting.
- **Depth:** Multi-layered drop shadows create a sense of "lifted" cards. Soft, deep shadow on interactive elements.

## Colors

The palette rooted in high-contrast neutrals with a single dark green accent driving all interactivity.

### Light Palette

- **Primary (`#FBFEFE`):** Near-white canvas. Slightly warmer than pure white — feels soft, approachable, premium.
- **Accent (`#001910`):** Deep forest green. Used for all text, interactive elements, icons, and primary actions. Maximum contrast against the light canvas.
- **Border (`#E0E0E0`):** Light grey for card outlines, dividers, and structural separation.
- **Error (`#B00020`):** Deep red for destructive actions and error states.
- **Warning (`#FFA000`):** Amber for caution states.
- **Success (`#005737`):** Muted green for success states.

### Dark Palette

- **Primary (`#000805`):** Deep almost-black canvas. Feels secure, infinite, premium.
- **Accent (`#F3FFFB`):** Very light mint green. Inverted accent — all text, icons, and interactive elements use this on dark backgrounds.
- **Font (`#FFFFFF`):** Pure white for maximum readability on dark.
- **Border (`#525252`):** Muted grey for card outlines and structure.
- **Error (`#D12443`):** Bright red for destructive actions.
- **Warning (`#FFA000`):** Same amber as light — consistent warning across themes.
- **Success (`#0AC07D`):** Vibrant green for success states.

### Design Tokens

```yaml
colors:
  primary: "#FBFEFE"
  accent: "#001910"
  font: "#001910"
  border: "#E0E0E0"
  error: "#B00020"
  warning: "#FFA000"
  success: "#005737"
  surface: "#FBFEFE"
  on-surface: "#001910"
```

## Typography

Two-font strategy: **Inter** for all UI text, **Bytesized** for the logo wordmark only.

### Hierarchy

- **Heading 1 (Inter Bold 21px):** Screen titles, primary navigation labels. Bold weight establishes hierarchy.
- **Heading 2 (Inter Semi-Bold 18px):** Section headers in settings and dialogs.
- **Heading 3 (Inter Medium 16px):** Account names, card titles, list item labels.
- **Body (Inter Regular 14px):** All standard text, descriptions, metadata.
- **Label (Inter Regular 14px):** Form labels, input hints, captions.

### Logo

- **Bytesized** — custom display font. Used exclusively for the "Cipher" wordmark on splash screen. Not used elsewhere.

### Design Tokens

```yaml
typography:
  heading1:
    fontFamily: Inter
    fontSize: 21px
    fontWeight: 700
  heading2:
    fontFamily: Inter
    fontSize: 18px
    fontWeight: 600
  heading3:
    fontFamily: Inter
    fontSize: 16px
    fontWeight: 500
  body:
    fontFamily: Inter
    fontSize: 14px
    fontWeight: 400
  label:
    fontFamily: Inter
    fontSize: 14px
    fontWeight: 400
```

## Layout & Spacing

### Grid

Full-bleed mobile-first layout. No fixed grid or max-width — content spans the full screen width with consistent internal padding.

### Spacing Scale

- **xs (4px):** Micro-adjustments, icon gaps
- **sm (8px):** Small gaps, divider spacing
- **md (16px):** Card internal padding, button horizontal padding
- **lg (20px):** Section gaps between Settings groups
- **xl (25px):** Radio button / toggle padding from screen edges
- **xxl (32px):** Major section padding

### Containment

Related items grouped in cards with `md` internal padding. Cards separated by `lg` gap. Settings sections use `Divider(height: 0)` between grouped tiles.

### Design Tokens

```yaml
spacing:
  xs: 4px
  sm: 8px
  md: 16px
  lg: 20px
  xl: 25px
  xxl: 32px
  gutter: 24px
```

## Elevation & Depth

Depth achieved through **tonal layering** and **soft shadows** rather than heavy elevation.

- **Background:** Base canvas (`primary`) with optional subtle noise texture.
- **Cards:** `primary` canvas on `primary` background with `elevation: 0` by default. Cards distinguished by `border` color outline, not shadow.
- **Interactive elements (buttons):** `elevation: 2` with shadow color matching `accent` at 10% opacity. Creates a subtle "glow" effect.
- **Bottom navigation bar:** Sits on the base canvas, distinguished by position and icon treatment, not shadow.

No floating action buttons, no modal bottom sheets, no snackbars with elevation. Visual hierarchy relies on spacing, color contrast, and typography weight.

## Shapes

- **Cards (`SemanticCard`):** `10px` corner radius (`rounded.md`). Soft enough to feel modern, sharp enough to maintain precision.
- **Primary buttons (`SemanticElevatedButton`):** `12px` corner radius (`rounded.lg`). Slightly rounder than cards — invites interaction.
- **Text buttons, toggles, radio groups:** `8px` corner radius (`rounded.sm`). Consistent shape for all interactive list items.
- **All shape corners consistent within a view.** Never mix rounded and sharp corners.

### Design Tokens

```yaml
rounded:
  sm: 8px
  md: 10px
  lg: 12px
  full: 9999px
```

## Components

### Buttons

| Variant | Style | Shape | Usage |
|---------|-------|-------|-------|
| Primary (Elevated) | `accent` bg, `primary` text, 48px min height | `rounded.lg` | Primary CTA, confirm, save |
| Text | Transparent bg, `accent` text, 36px min height | `rounded.sm` | Secondary actions, cancel |
| Toggle | Card with `SwitchListTile`, `accent` thumb | `rounded.sm` | Settings boolean toggles |
| Radio | Card with `RadioGroup<T>`, `ListTile` per option | `rounded.sm` | Settings single-select (theme) |
| Icon | Plain `IconButton` wrapper with `Semantics` | — | Toolbar actions, dismiss |

All buttons wrap `Semantics` widget for accessibility. Primary buttons include a layout-balancing hidden icon when an icon is present on the left.

### Cards

| Variant | Style | Usage |
|---------|-------|-------|
| Default | `primary` bg, `border` outline, `0` elevation | Account list items, info cards |
| Toggle | `0` padding, `SwitchListTile` inside | Settings rows |
| Radio | `0` padding, `RadioGroup` inside | Settings option groups |

### App Bar

- `primary` background color (matches canvas)
- `font` foreground color
- `heading1` text style for title
- Optional bottom widget, automatic back button when applicable
- No elevation by default — sits flush with content

### Bottom Navigation

- Home tab and Settings tab
- Active tab uses `accent` color
- Inactive tab uses `border` color
- No labels, icon-only

### Design Tokens

```yaml
components:
  button-primary:
    backgroundColor: "{accent}"
    textColor: "{primary}"
    rounded: "{rounded.lg}"
    padding: "{spacing.md} {spacing.md}"
    height: 48px
  button-text:
    backgroundColor: transparent
    textColor: "{accent}"
    rounded: "{rounded.sm}"
    padding: "{spacing.sm} {spacing.sm}"
    height: 36px
  card:
    backgroundColor: "{primary}"
    textColor: "{font}"
    rounded: "{rounded.md}"
    borderColor: "{border}"
    padding: "{spacing.md} {spacing.md}"
  app-bar:
    backgroundColor: "{primary}"
    textColor: "{font}"
    typography: "{typography.heading1}"
```

## Do's and Don'ts

- Do use `accent` color only for interactive elements and primary text — never for backgrounds or decorative fills
- Don't mix accent colors between light and dark theme — dark green (`#001910`) is light theme accent, light mint (`#F3FFFB`) is dark theme accent
- Do maintain WCAG AA contrast: `accent` on `primary` exceeds 15:1 in light theme, `font` on `primary` exceeds 18:1 in dark
- Don't use more than two font weights on a single screen (bold headings + regular body; semi-bold and medium are acceptable for hierarchy)
- Do group related items in cards with `md` internal padding and `lg` gap between groups
- Don't add elevation to cards — use border outlines instead for separation
- Do wrap all interactive elements with `Semantics` for accessibility
- Don't use the Bytesized font anywhere except the splash screen logo
- Do use `heading1` for screen titles, `heading2` for section headers, `heading3` for list item labels, `body` for all other text
- Don't use rounded corners larger than `12px` on any element — maintain the precise, engineered aesthetic
---
name: palette
description: Generate an accessible OKLCH color palette with WCAG AA contrast verification, ready for Tailwind CSS and shadcn/ui.
---

Generate a complete color system in OKLCH, verify all contrast ratios meet WCAG AA, and output CSS custom properties compatible with Tailwind CSS v4 and shadcn/ui.

## When to use

- Starting a new project and need a color palette.
- Rebranding an existing project with new colors.
- When the current palette has contrast issues and needs a ground-up fix.
- When switching from hex/HSL to OKLCH.

## When NOT to use

- For tweaking a single color. Just edit the CSS directly.
- For non-web projects that don't use CSS custom properties.

## Arguments

This skill accepts arguments after `/palette`:

- A theme concept or mood (e.g., "ocean", "sunset", "corporate blue", "fox at dusk", "forest green").
- `--dark-only`: generate only dark mode values for an existing light palette.
- `--light-only`: generate only light mode values for an existing dark palette.
- `--shadcn`: output in shadcn/ui variable format (default).
- `--minimal`: output only primary, background, foreground, muted, and accent (skip sidebar, chart, etc.).
- No arguments: ask the user for a theme concept before proceeding.

## Steps

1. **Understand the theme.** If no concept was provided, ask the user:
   - "What mood or concept should the palette express? (e.g., warm amber, ocean blue, forest green, corporate neutral)"
   - Wait for a response before proceeding.

2. **Design the palette in OKLCH.** Create a coherent color system with these tokens:

   | Token | Purpose | Design guideline |
   |-------|---------|-----------------|
   | `--primary` | Brand color, CTAs, active states | High chroma, distinct hue. Must pass 4.5:1 against background in BOTH modes |
   | `--primary-foreground` | Text on primary backgrounds | Near-white for dark primary, near-black for light primary |
   | `--background` | Page background | Very light (L > 0.95) for light mode, very dark (L < 0.20) for dark mode |
   | `--foreground` | Body text | Very dark (L < 0.20) for light mode, very light (L > 0.90) for dark mode |
   | `--card` | Card surfaces | Slightly different from background (L offset by 0.01-0.02) |
   | `--card-foreground` | Text on cards | Same as foreground |
   | `--popover` | Popover/dropdown surfaces | Same as background or card |
   | `--popover-foreground` | Text in popovers | Same as foreground |
   | `--secondary` | Secondary buttons, tags | Low chroma, subtle tint from primary hue family |
   | `--secondary-foreground` | Text on secondary | High contrast against secondary |
   | `--muted` | Muted backgrounds (section alternation) | Between background and secondary in lightness |
   | `--muted-foreground` | Secondary text, captions, placeholders | Must pass 4.5:1 against background, card, AND muted |
   | `--accent` | Hover states, highlights | Related to primary hue, lower chroma |
   | `--accent-foreground` | Text on accent | High contrast against accent |
   | `--destructive` | Error states, delete actions | Red-orange hue (H: 20-30), high chroma |
   | `--border` | Borders, dividers | Low chroma, visible but subtle |
   | `--input` | Input borders | Same as or slightly stronger than border |
   | `--ring` | Focus rings | Same as primary |

   If `--shadcn` (default), also generate chart-1 through chart-5 and sidebar tokens.

   Design rules:
   - Use OKLCH for perceptual uniformity. Adjust L for lightness, C for saturation, H for hue.
   - Keep neutrals on the same hue angle as primary but with very low chroma (C < 0.02) for visual cohesion.
   - Dark mode is NOT the inverse of light mode. Dark mode primary should be lighter (higher L) to maintain contrast against dark backgrounds.
   - Dark mode muted-foreground needs special attention. It must be light enough to read against dark backgrounds (L > 0.60).

3. **Verify contrast ratios.** Run the OKLCH contrast verification for every pair that appears together in the UI. Use the conversion functions from `rules/frontend.md`.

   Required pairs to check (in BOTH light and dark mode):

   | Foreground | Background | Minimum ratio |
   |-----------|------------|--------------|
   | foreground | background | 4.5:1 |
   | muted-foreground | background | 4.5:1 |
   | muted-foreground | card | 4.5:1 |
   | muted-foreground | muted | 4.5:1 |
   | primary | background | 4.5:1 |
   | primary-foreground | primary | 4.5:1 |
   | secondary-foreground | secondary | 4.5:1 |
   | accent-foreground | accent | 4.5:1 |
   | card-foreground | card | 4.5:1 |
   | destructive | background | 4.5:1 |

   If any pair fails, adjust the failing color's L value and re-check. Iterate until all pairs pass.

4. **Output the CSS.** Generate complete CSS custom properties in this format:

   ```css
   /*
    * <Theme Name> — OKLCH color system
    * Generated with /palette
    * All pairs verified WCAG AA (4.5:1 normal text, 3:1 large text)
    */
   :root {
     --radius: 0.625rem;

     /* Primary */
     --primary: oklch(L C H);
     --primary-foreground: oklch(L C H);

     /* Surfaces */
     --background: oklch(L C H);
     --foreground: oklch(L C H);
     --card: oklch(L C H);
     --card-foreground: oklch(L C H);
     --popover: oklch(L C H);
     --popover-foreground: oklch(L C H);

     /* Secondary / muted */
     --secondary: oklch(L C H);
     --secondary-foreground: oklch(L C H);
     --muted: oklch(L C H);
     --muted-foreground: oklch(L C H);

     /* Accent */
     --accent: oklch(L C H);
     --accent-foreground: oklch(L C H);

     /* Utilities */
     --destructive: oklch(L C H);
     --border: oklch(L C H);
     --input: oklch(L C H);
     --ring: oklch(L C H);

     /* Charts */
     --chart-1: oklch(L C H);
     --chart-2: oklch(L C H);
     --chart-3: oklch(L C H);
     --chart-4: oklch(L C H);
     --chart-5: oklch(L C H);

     /* Sidebar */
     --sidebar: oklch(L C H);
     --sidebar-foreground: oklch(L C H);
     --sidebar-primary: oklch(L C H);
     --sidebar-primary-foreground: oklch(L C H);
     --sidebar-accent: oklch(L C H);
     --sidebar-accent-foreground: oklch(L C H);
     --sidebar-border: oklch(L C H);
     --sidebar-ring: oklch(L C H);
   }

   .dark {
     /* Same structure with dark mode values */
   }
   ```

5. **Show the contrast verification table.** After the CSS, output a table showing all verified pairs:

   ```
   | Pair                              | Light  | Dark   | Status |
   |-----------------------------------|--------|--------|--------|
   | foreground on background          | 18.2:1 | 16.9:1 | PASS   |
   | muted-foreground on background    | 7.1:1  | 6.0:1  | PASS   |
   | ...                               | ...    | ...    | ...    |
   ```

6. **Integration instructions.** Tell the user:
   - Where to paste the CSS (globals.css, inside the `:root` and `.dark` blocks).
   - Remind them to update the inline dark mode script in layout.tsx if the localStorage key or class name differs.
   - Suggest running `/design-review --focus contrast` after integration to verify in context.

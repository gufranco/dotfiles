---
name: design-review
description: Audit a page or component for visual design, UX, accessibility, responsive behavior, and color contrast.
---

Perform a design and UX audit on frontend code. Unlike `/review` which checks code quality and correctness, this skill evaluates the visual and interactive quality of the output: does it look right, feel right, and work for all users?

Use the rules in `rules/frontend.md` as the reference checklist. Every finding must cite the specific rule it violates.

## When to use

- After building or modifying a page, section, or component.
- When the result "looks off" but you cannot pinpoint why.
- Before shipping frontend work to production.
- When adding dark mode, responsive layouts, or accessibility features.

## When NOT to use

- For reviewing backend logic, API design, or infrastructure. Use `/review` or `/assessment`.
- For trivial text-only changes with no visual impact.
- For generating new designs from scratch. This skill audits existing code.

## Arguments

This skill accepts optional arguments after `/design-review`:

- No arguments: audit all frontend files changed on the current branch compared to the base branch.
- A file or directory path: audit those specific files.
- `--focus <area>`: narrow the audit to a specific concern: `contrast`, `responsive`, `accessibility`, `spacing`, `typography`, `animation`, or `all` (default).
- `--fix`: automatically fix findings instead of just reporting them. Only applies to findings with clear, unambiguous fixes.

## Steps

1. **Identify scope.** Determine which files to audit:
   - If a path argument was given, use that.
   - Otherwise, detect the base branch and get changed frontend files: `git diff origin/<base>...HEAD --name-only` filtered to `.tsx`, `.jsx`, `.css`, `.scss` files.
   - Also read `globals.css` or the main stylesheet to understand the color system and design tokens.

2. **Read the code.** Read every file in scope in full. Also read:
   - The color system (CSS custom properties, OKLCH values, light and dark mode tokens).
   - Layout components (header, footer, nav) for structural context.
   - Any shared UI components used by the audited files (buttons, cards, inputs).

3. **Audit: Color contrast.** For every foreground/background color pair in the code:
   - Identify the CSS custom properties used (e.g., `text-muted-foreground` on `bg-background`).
   - Resolve them to their actual OKLCH or hex values from the stylesheet.
   - Calculate the contrast ratio using the OKLCH conversion functions from `rules/frontend.md`.
   - Flag any pair below 4.5:1 for normal text or 3:1 for large text (>= 18px bold or >= 24px).
   - Check BOTH light and dark mode values. A pair that passes in one mode may fail in the other.
   - Severity: **HIGH** for body text failures, **MEDIUM** for large text or UI component failures.

4. **Audit: Typography and readability.** Check:
   - Body text is at least 16px (text-base or larger). `text-sm` (14px) is acceptable inside cards, badges, and compact UI elements but not for standalone paragraphs.
   - Line length is constrained (max-w-prose, max-w-2xl, or similar) on text blocks wider than a card.
   - Headings use `text-balance`, body paragraphs use `text-pretty`.
   - Heading scale is consistent and follows Tailwind's built-in scale.
   - No more than 2-3 font weights per page.
   - Severity: **MEDIUM** for readability issues, **LOW** for minor inconsistencies.

5. **Audit: Spacing consistency.** Check:
   - Section padding follows a consistent pattern (e.g., py-20 sm:py-24 everywhere).
   - Grid gaps are consistent across similar components (all card grids use the same gap).
   - Card internal padding is consistent.
   - Margin between section title and content is consistent.
   - No arbitrary spacing values (e.g., `mt-[13px]`) when a Tailwind scale value works.
   - Severity: **MEDIUM** for inconsistencies, **LOW** for minor deviations.

6. **Audit: Responsive behavior.** Check:
   - Grids transition smoothly: 1 column on mobile, 2 on tablet, 3+ on desktop. No jumps from 1 to 3.
   - Navigation switches to mobile menu at the right breakpoint (md or lg).
   - Buttons are full-width on mobile (`w-full sm:w-auto`).
   - Hero uses `dvh` not `vh` for viewport height.
   - Container uses consistent max-width and horizontal padding.
   - Touch targets are at least 44x44px (2.75rem) on mobile.
   - `overflow-x: clip` is used instead of `overflow-x: hidden` on html/body.
   - Severity: **HIGH** for broken mobile layouts, **MEDIUM** for suboptimal responsive behavior.

7. **Audit: Accessibility.** Check:
   - Every `<section>` has `aria-labelledby` pointing to its heading.
   - Navigation landmarks have `aria-label` ("Main", "Footer", "Mobile").
   - Decorative elements have `aria-hidden="true"`.
   - All form inputs have associated `<label>` elements with `htmlFor`.
   - Icon-only buttons have `aria-label`.
   - Focus indicators are visible and have 3:1 contrast.
   - No positive `tabindex` values.
   - Animations respect `prefers-reduced-motion`.
   - SVG icons have `aria-hidden="true"` when inside labeled elements.
   - Severity: **HIGH** for missing landmarks and label associations, **MEDIUM** for other ARIA issues, **LOW** for optional enhancements.

8. **Audit: Animation and motion.** Check:
   - All animations are CSS-based, not JS-based (unless IntersectionObserver trigger).
   - `prefers-reduced-motion: reduce` media query provides a no-animation fallback.
   - Reduced-motion fallback sets `opacity: 1` and `transform: none`, not `display: none`.
   - Animation durations are reasonable (150ms for micro, 300-600ms for reveals).
   - Severity: **MEDIUM** for missing reduced-motion support, **LOW** for duration issues.

9. **Audit: Dark mode.** Check:
   - All color tokens have both light and dark mode values.
   - Dark mode backgrounds are sufficiently dark (OKLCH L < 0.25) and foregrounds sufficiently light (L > 0.85).
   - No hardcoded colors that bypass the token system (e.g., `text-gray-500` instead of `text-muted-foreground`).
   - Gradients and decorative elements adapt to dark mode.
   - Images and SVGs that use `currentColor` adapt automatically. Others need explicit dark mode variants.
   - Severity: **HIGH** for invisible or unreadable content in dark mode, **MEDIUM** for inconsistencies.

10. **Compile findings.** Group findings by severity. For each finding:
    - State what the issue is and which file/line it affects.
    - Cite the rule from `rules/frontend.md` it violates.
    - Provide the fix (exact code change).
    - If `--fix` was passed, apply the fix directly.

11. **Output the report.** Format:

    ```
    ## Design Review: <scope>

    ### Summary
    <1-2 sentence overview of design quality>

    Findings: X HIGH, Y MEDIUM, Z LOW

    ### HIGH
    <findings>

    ### MEDIUM
    <findings>

    ### LOW
    <findings>

    ### Passing
    <brief list of things done well>
    ```

    If `--fix` was passed, also show which findings were auto-fixed and run a build to verify.
